
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
8010005f:	ba 0c 35 10 80       	mov    $0x8010350c,%edx
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
80100073:	68 60 a7 10 80       	push   $0x8010a760
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 f3 49 00 00       	call   80104a75 <initlock>
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
801000c1:	68 67 a7 10 80       	push   $0x8010a767
801000c6:	50                   	push   %eax
801000c7:	e8 3c 48 00 00       	call   80104908 <initsleeplock>
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
80100109:	e8 8d 49 00 00       	call   80104a9b <acquire>
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
80100148:	e8 c0 49 00 00       	call   80104b0d <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 e9 47 00 00       	call   80104948 <acquiresleep>
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
801001c9:	e8 3f 49 00 00       	call   80104b0d <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 68 47 00 00       	call   80104948 <acquiresleep>
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
801001fd:	68 6e a7 10 80       	push   $0x8010a76e
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
80100239:	e8 2c a4 00 00       	call   8010a66a <iderw>
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
8010025a:	e8 a3 47 00 00       	call   80104a02 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 7f a7 10 80       	push   $0x8010a77f
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
80100288:	e8 dd a3 00 00       	call   8010a66a <iderw>
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
801002a7:	e8 56 47 00 00       	call   80104a02 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 86 a7 10 80       	push   $0x8010a786
801002bb:	e8 1e 03 00 00       	call   801005de <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 e1 46 00 00       	call   801049b0 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 bc 47 00 00       	call   80104a9b <acquire>
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
8010034a:	e8 be 47 00 00       	call   80104b0d <release>
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
8010042c:	e8 6a 46 00 00       	call   80104a9b <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 90 a7 10 80       	push   $0x8010a790
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
801004ce:	8b 04 85 a0 a7 10 80 	mov    -0x7fef5860(,%eax,4),%eax
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
8010052c:	c7 45 ec 99 a7 10 80 	movl   $0x8010a799,-0x14(%ebp)
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
801005d3:	e8 35 45 00 00       	call   80104b0d <release>
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
801005f7:	e8 61 26 00 00       	call   80102c5d <lapicid>
801005fc:	83 ec 08             	sub    $0x8,%esp
801005ff:	50                   	push   %eax
80100600:	68 f8 a7 10 80       	push   $0x8010a7f8
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
8010061f:	68 0c a8 10 80       	push   $0x8010a80c
80100624:	e8 e3 fd ff ff       	call   8010040c <cprintf>
80100629:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010062c:	83 ec 08             	sub    $0x8,%esp
8010062f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100632:	50                   	push   %eax
80100633:	8d 45 08             	lea    0x8(%ebp),%eax
80100636:	50                   	push   %eax
80100637:	e8 27 45 00 00       	call   80104b63 <getcallerpcs>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100646:	eb 1c                	jmp    80100664 <panic+0x86>
    cprintf(" %p", pcs[i]);
80100648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010064b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010064f:	83 ec 08             	sub    $0x8,%esp
80100652:	50                   	push   %eax
80100653:	68 0e a8 10 80       	push   $0x8010a80e
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
801006dd:	e8 1c 7e 00 00       	call   801084fe <graphic_scroll_up>
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
80100730:	e8 c9 7d 00 00       	call   801084fe <graphic_scroll_up>
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
80100796:	e8 d7 7d 00 00       	call   80108572 <font_render>
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
801007d6:	e8 4c 61 00 00       	call   80106927 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 3f 61 00 00       	call   80106927 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 32 61 00 00       	call   80106927 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 22 61 00 00       	call   80106927 <uartputc>
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
80100832:	e8 64 42 00 00       	call   80104a9b <acquire>
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
80100988:	e8 74 3c 00 00       	call   80104601 <wakeup>
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
801009ab:	e8 5d 41 00 00       	call   80104b0d <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 16 3d 00 00       	call   801046d4 <procdump>
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
801009d1:	e8 1b 12 00 00       	call   80101bf1 <iunlock>
801009d6:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d9:	8b 45 10             	mov    0x10(%ebp),%eax
801009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 20 d0 18 80       	push   $0x8018d020
801009e7:	e8 af 40 00 00       	call   80104a9b <acquire>
801009ec:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ef:	e9 ab 00 00 00       	jmp    80100a9f <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009f4:	e8 0e 32 00 00       	call   80103c07 <myproc>
801009f9:	8b 40 24             	mov    0x24(%eax),%eax
801009fc:	85 c0                	test   %eax,%eax
801009fe:	74 28                	je     80100a28 <consoleread+0x67>
        release(&cons.lock);
80100a00:	83 ec 0c             	sub    $0xc,%esp
80100a03:	68 20 d0 18 80       	push   $0x8018d020
80100a08:	e8 00 41 00 00       	call   80104b0d <release>
80100a0d:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a10:	83 ec 0c             	sub    $0xc,%esp
80100a13:	ff 75 08             	push   0x8(%ebp)
80100a16:	e8 bf 10 00 00       	call   80101ada <ilock>
80100a1b:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a23:	e9 ab 00 00 00       	jmp    80100ad3 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a28:	83 ec 08             	sub    $0x8,%esp
80100a2b:	68 20 d0 18 80       	push   $0x8018d020
80100a30:	68 40 2d 19 80       	push   $0x80192d40
80100a35:	e8 d8 3a 00 00       	call   80104512 <sleep>
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
80100ab3:	e8 55 40 00 00       	call   80104b0d <release>
80100ab8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100abb:	83 ec 0c             	sub    $0xc,%esp
80100abe:	ff 75 08             	push   0x8(%ebp)
80100ac1:	e8 14 10 00 00       	call   80101ada <ilock>
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
80100ae5:	e8 07 11 00 00       	call   80101bf1 <iunlock>
80100aea:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aed:	83 ec 0c             	sub    $0xc,%esp
80100af0:	68 20 d0 18 80       	push   $0x8018d020
80100af5:	e8 a1 3f 00 00       	call   80104a9b <acquire>
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
80100b37:	e8 d1 3f 00 00       	call   80104b0d <release>
80100b3c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b3f:	83 ec 0c             	sub    $0xc,%esp
80100b42:	ff 75 08             	push   0x8(%ebp)
80100b45:	e8 90 0f 00 00       	call   80101ada <ilock>
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
80100b69:	68 12 a8 10 80       	push   $0x8010a812
80100b6e:	68 20 d0 18 80       	push   $0x8018d020
80100b73:	e8 fd 3e 00 00       	call   80104a75 <initlock>
80100b78:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b7b:	c7 05 0c 37 19 80 d5 	movl   $0x80100ad5,0x8019370c
80100b82:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b85:	c7 05 08 37 19 80 c1 	movl   $0x801009c1,0x80193708
80100b8c:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b8f:	c7 45 f4 1a a8 10 80 	movl   $0x8010a81a,-0xc(%ebp)
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
80100bcc:	e8 99 1b 00 00       	call   8010276a <ioapicenable>
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
80100be4:	e8 1e 30 00 00       	call   80103c07 <myproc>
80100be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bec:	e8 de 25 00 00       	call   801031cf <begin_op>

  if((ip = namei(path)) == 0){
80100bf1:	83 ec 0c             	sub    $0xc,%esp
80100bf4:	ff 75 08             	push   0x8(%ebp)
80100bf7:	e8 49 1a 00 00       	call   80102645 <namei>
80100bfc:	83 c4 10             	add    $0x10,%esp
80100bff:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c06:	75 1f                	jne    80100c27 <exec+0x50>
    end_op();
80100c08:	e8 52 26 00 00       	call   8010325f <end_op>
    cprintf("exec: fail\n");
80100c0d:	83 ec 0c             	sub    $0xc,%esp
80100c10:	68 30 a8 10 80       	push   $0x8010a830
80100c15:	e8 f2 f7 ff ff       	call   8010040c <cprintf>
80100c1a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 36 04 00 00       	jmp    8010105d <exec+0x486>
  }
  ilock(ip);
80100c27:	83 ec 0c             	sub    $0xc,%esp
80100c2a:	ff 75 d8             	push   -0x28(%ebp)
80100c2d:	e8 a8 0e 00 00       	call   80101ada <ilock>
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
80100c4a:	e8 93 13 00 00       	call   80101fe2 <readi>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	83 f8 34             	cmp    $0x34,%eax
80100c55:	0f 85 9b 03 00 00    	jne    80100ff6 <exec+0x41f>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c5b:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c61:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c66:	0f 85 8d 03 00 00    	jne    80100ff9 <exec+0x422>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c6c:	e8 ca 6c 00 00       	call   8010793b <setupkvm>
80100c71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c78:	0f 84 7e 03 00 00    	je     80100ffc <exec+0x425>
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
80100caa:	e8 33 13 00 00       	call   80101fe2 <readi>
80100caf:	83 c4 10             	add    $0x10,%esp
80100cb2:	83 f8 20             	cmp    $0x20,%eax
80100cb5:	0f 85 44 03 00 00    	jne    80100fff <exec+0x428>
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
80100cd8:	0f 82 24 03 00 00    	jb     80101002 <exec+0x42b>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cde:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cea:	01 c2                	add    %eax,%edx
80100cec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 0b 03 00 00    	jb     80101005 <exec+0x42e>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d00:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	push   -0x20(%ebp)
80100d0f:	ff 75 d4             	push   -0x2c(%ebp)
80100d12:	e8 36 70 00 00       	call   80107d4d <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 e1 02 00 00    	je     80101008 <exec+0x431>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d32:	85 c0                	test   %eax,%eax
80100d34:	0f 85 d1 02 00 00    	jne    8010100b <exec+0x434>
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
80100d58:	e8 1f 6f 00 00       	call   80107c7c <loaduvm>
80100d5d:	83 c4 20             	add    $0x20,%esp
80100d60:	85 c0                	test   %eax,%eax
80100d62:	0f 88 a6 02 00 00    	js     8010100e <exec+0x437>
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
80100d91:	e8 81 0f 00 00       	call   80101d17 <iunlockput>
80100d96:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d99:	e8 c1 24 00 00       	call   8010325f <end_op>
  ip = 0;
80100d9e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  // sz를 커널 베이스로 이동 페이지를 할당해야 하기 때문에 그 크기만큼 빼줌
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한 단계 더 내린다.
  // Pagefault가 발생했을 때 스택의 바로 아래인지를 판단하기 위해 gaurd page도 할당한다.
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100da5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100da8:	8b 40 10             	mov    0x10(%eax),%eax
80100dab:	83 ec 04             	sub    $0x4,%esp
80100dae:	50                   	push   %eax
80100daf:	ff 75 e0             	push   -0x20(%ebp)
80100db2:	68 3c a8 10 80       	push   $0x8010a83c
80100db7:	e8 50 f6 ff ff       	call   8010040c <cprintf>
80100dbc:	83 c4 10             	add    $0x10,%esp
  sz = PGROUNDDOWN(KERNBASE - 2*PGSIZE);
80100dbf:	c7 45 e0 00 e0 ff 7f 	movl   $0x7fffe000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc9:	05 00 10 00 00       	add    $0x1000,%eax
80100dce:	83 ec 04             	sub    $0x4,%esp
80100dd1:	50                   	push   %eax
80100dd2:	ff 75 e0             	push   -0x20(%ebp)
80100dd5:	ff 75 d4             	push   -0x2c(%ebp)
80100dd8:	e8 70 6f 00 00       	call   80107d4d <allocuvm>
80100ddd:	83 c4 10             	add    $0x10,%esp
80100de0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100de3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100de7:	0f 84 24 02 00 00    	je     80101011 <exec+0x43a>
    goto bad;
  // 스택 포인터를 sz로
  sp = sz;
80100ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100df0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // 0xb98은 text, data영역의 윗 부분
  // sz는 사용 중인 유저 공간을 나타내주는데 스택을 kernbase로 옮겨서
  // 스택 외의 코드까지만 sz로 변경
  sz = PGROUNDUP(0xb98) /*+ 2*PGSIZE*/;
80100df3:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100dfa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dfd:	8b 40 10             	mov    0x10(%eax),%eax
80100e00:	83 ec 04             	sub    $0x4,%esp
80100e03:	50                   	push   %eax
80100e04:	ff 75 e0             	push   -0x20(%ebp)
80100e07:	68 3c a8 10 80       	push   $0x8010a83c
80100e0c:	e8 fb f5 ff ff       	call   8010040c <cprintf>
80100e11:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e1b:	e9 96 00 00 00       	jmp    80100eb6 <exec+0x2df>
    if(argc >= MAXARG)
80100e20:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e24:	0f 87 ea 01 00 00    	ja     80101014 <exec+0x43d>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e37:	01 d0                	add    %edx,%eax
80100e39:	8b 00                	mov    (%eax),%eax
80100e3b:	83 ec 0c             	sub    $0xc,%esp
80100e3e:	50                   	push   %eax
80100e3f:	e8 4f 41 00 00       	call   80104f93 <strlen>
80100e44:	83 c4 10             	add    $0x10,%esp
80100e47:	89 c2                	mov    %eax,%edx
80100e49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e4c:	29 d0                	sub    %edx,%eax
80100e4e:	83 e8 01             	sub    $0x1,%eax
80100e51:	83 e0 fc             	and    $0xfffffffc,%eax
80100e54:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e64:	01 d0                	add    %edx,%eax
80100e66:	8b 00                	mov    (%eax),%eax
80100e68:	83 ec 0c             	sub    $0xc,%esp
80100e6b:	50                   	push   %eax
80100e6c:	e8 22 41 00 00       	call   80104f93 <strlen>
80100e71:	83 c4 10             	add    $0x10,%esp
80100e74:	83 c0 01             	add    $0x1,%eax
80100e77:	89 c1                	mov    %eax,%ecx
80100e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e83:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e86:	01 d0                	add    %edx,%eax
80100e88:	8b 00                	mov    (%eax),%eax
80100e8a:	51                   	push   %ecx
80100e8b:	50                   	push   %eax
80100e8c:	ff 75 dc             	push   -0x24(%ebp)
80100e8f:	ff 75 d4             	push   -0x2c(%ebp)
80100e92:	e8 ba 72 00 00       	call   80108151 <copyout>
80100e97:	83 c4 10             	add    $0x10,%esp
80100e9a:	85 c0                	test   %eax,%eax
80100e9c:	0f 88 75 01 00 00    	js     80101017 <exec+0x440>
      goto bad;
    ustack[3+argc] = sp;
80100ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea5:	8d 50 03             	lea    0x3(%eax),%edx
80100ea8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eab:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100eb2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec3:	01 d0                	add    %edx,%eax
80100ec5:	8b 00                	mov    (%eax),%eax
80100ec7:	85 c0                	test   %eax,%eax
80100ec9:	0f 85 51 ff ff ff    	jne    80100e20 <exec+0x249>
  }
  ustack[3+argc] = 0;
80100ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed2:	83 c0 03             	add    $0x3,%eax
80100ed5:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100edc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ee0:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ee7:	ff ff ff 
  ustack[1] = argc;
80100eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eed:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ef3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef6:	83 c0 01             	add    $0x1,%eax
80100ef9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f03:	29 d0                	sub    %edx,%eax
80100f05:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f0e:	83 c0 04             	add    $0x4,%eax
80100f11:	c1 e0 02             	shl    $0x2,%eax
80100f14:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1a:	83 c0 04             	add    $0x4,%eax
80100f1d:	c1 e0 02             	shl    $0x2,%eax
80100f20:	50                   	push   %eax
80100f21:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f27:	50                   	push   %eax
80100f28:	ff 75 dc             	push   -0x24(%ebp)
80100f2b:	ff 75 d4             	push   -0x2c(%ebp)
80100f2e:	e8 1e 72 00 00       	call   80108151 <copyout>
80100f33:	83 c4 10             	add    $0x10,%esp
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 88 dc 00 00 00    	js     8010101a <exec+0x443>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f47:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f4a:	eb 17                	jmp    80100f63 <exec+0x38c>
    if(*s == '/')
80100f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4f:	0f b6 00             	movzbl (%eax),%eax
80100f52:	3c 2f                	cmp    $0x2f,%al
80100f54:	75 09                	jne    80100f5f <exec+0x388>
      last = s+1;
80100f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f59:	83 c0 01             	add    $0x1,%eax
80100f5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f66:	0f b6 00             	movzbl (%eax),%eax
80100f69:	84 c0                	test   %al,%al
80100f6b:	75 df                	jne    80100f4c <exec+0x375>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f70:	83 c0 6c             	add    $0x6c,%eax
80100f73:	83 ec 04             	sub    $0x4,%esp
80100f76:	6a 10                	push   $0x10
80100f78:	ff 75 f0             	push   -0x10(%ebp)
80100f7b:	50                   	push   %eax
80100f7c:	e8 c4 3f 00 00       	call   80104f45 <safestrcpy>
80100f81:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f84:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f87:	8b 40 04             	mov    0x4(%eax),%eax
80100f8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f93:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f96:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f99:	8b 40 18             	mov    0x18(%eax),%eax
80100f9c:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fa2:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->sz = sz;
80100fa5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fab:	89 10                	mov    %edx,(%eax)
  curproc->tf->esp = sp;
80100fad:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb0:	8b 40 18             	mov    0x18(%eax),%eax
80100fb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fb6:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("[exec] eip %x\n",curproc->tf->eip);
80100fb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fbc:	8b 40 18             	mov    0x18(%eax),%eax
80100fbf:	8b 40 38             	mov    0x38(%eax),%eax
80100fc2:	83 ec 08             	sub    $0x8,%esp
80100fc5:	50                   	push   %eax
80100fc6:	68 59 a8 10 80       	push   $0x8010a859
80100fcb:	e8 3c f4 ff ff       	call   8010040c <cprintf>
80100fd0:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d0             	push   -0x30(%ebp)
80100fd9:	e8 87 6a 00 00       	call   80107a65 <switchuvm>
80100fde:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fe1:	83 ec 0c             	sub    $0xc,%esp
80100fe4:	ff 75 cc             	push   -0x34(%ebp)
80100fe7:	e8 32 6f 00 00       	call   80107f1e <freevm>
80100fec:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fef:	b8 00 00 00 00       	mov    $0x0,%eax
80100ff4:	eb 67                	jmp    8010105d <exec+0x486>
    goto bad;
80100ff6:	90                   	nop
80100ff7:	eb 22                	jmp    8010101b <exec+0x444>
    goto bad;
80100ff9:	90                   	nop
80100ffa:	eb 1f                	jmp    8010101b <exec+0x444>
    goto bad;
80100ffc:	90                   	nop
80100ffd:	eb 1c                	jmp    8010101b <exec+0x444>
      goto bad;
80100fff:	90                   	nop
80101000:	eb 19                	jmp    8010101b <exec+0x444>
      goto bad;
80101002:	90                   	nop
80101003:	eb 16                	jmp    8010101b <exec+0x444>
      goto bad;
80101005:	90                   	nop
80101006:	eb 13                	jmp    8010101b <exec+0x444>
      goto bad;
80101008:	90                   	nop
80101009:	eb 10                	jmp    8010101b <exec+0x444>
      goto bad;
8010100b:	90                   	nop
8010100c:	eb 0d                	jmp    8010101b <exec+0x444>
      goto bad;
8010100e:	90                   	nop
8010100f:	eb 0a                	jmp    8010101b <exec+0x444>
    goto bad;
80101011:	90                   	nop
80101012:	eb 07                	jmp    8010101b <exec+0x444>
      goto bad;
80101014:	90                   	nop
80101015:	eb 04                	jmp    8010101b <exec+0x444>
      goto bad;
80101017:	90                   	nop
80101018:	eb 01                	jmp    8010101b <exec+0x444>
    goto bad;
8010101a:	90                   	nop

 bad:
  cprintf("bad \n");
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	68 68 a8 10 80       	push   $0x8010a868
80101023:	e8 e4 f3 ff ff       	call   8010040c <cprintf>
80101028:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
8010102b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010102f:	74 0e                	je     8010103f <exec+0x468>
    freevm(pgdir);
80101031:	83 ec 0c             	sub    $0xc,%esp
80101034:	ff 75 d4             	push   -0x2c(%ebp)
80101037:	e8 e2 6e 00 00       	call   80107f1e <freevm>
8010103c:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010103f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101043:	74 13                	je     80101058 <exec+0x481>
    iunlockput(ip);
80101045:	83 ec 0c             	sub    $0xc,%esp
80101048:	ff 75 d8             	push   -0x28(%ebp)
8010104b:	e8 c7 0c 00 00       	call   80101d17 <iunlockput>
80101050:	83 c4 10             	add    $0x10,%esp
    end_op();
80101053:	e8 07 22 00 00       	call   8010325f <end_op>
  }
  return -1;
80101058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010105d:	c9                   	leave
8010105e:	c3                   	ret

8010105f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010105f:	f3 0f 1e fb          	endbr32
80101063:	55                   	push   %ebp
80101064:	89 e5                	mov    %esp,%ebp
80101066:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101069:	83 ec 08             	sub    $0x8,%esp
8010106c:	68 6e a8 10 80       	push   $0x8010a86e
80101071:	68 60 2d 19 80       	push   $0x80192d60
80101076:	e8 fa 39 00 00       	call   80104a75 <initlock>
8010107b:	83 c4 10             	add    $0x10,%esp
}
8010107e:	90                   	nop
8010107f:	c9                   	leave
80101080:	c3                   	ret

80101081 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101081:	f3 0f 1e fb          	endbr32
80101085:	55                   	push   %ebp
80101086:	89 e5                	mov    %esp,%ebp
80101088:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010108b:	83 ec 0c             	sub    $0xc,%esp
8010108e:	68 60 2d 19 80       	push   $0x80192d60
80101093:	e8 03 3a 00 00       	call   80104a9b <acquire>
80101098:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010109b:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
801010a2:	eb 2d                	jmp    801010d1 <filealloc+0x50>
    if(f->ref == 0){
801010a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a7:	8b 40 04             	mov    0x4(%eax),%eax
801010aa:	85 c0                	test   %eax,%eax
801010ac:	75 1f                	jne    801010cd <filealloc+0x4c>
      f->ref = 1;
801010ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010b1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 60 2d 19 80       	push   $0x80192d60
801010c0:	e8 48 3a 00 00       	call   80104b0d <release>
801010c5:	83 c4 10             	add    $0x10,%esp
      return f;
801010c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010cb:	eb 23                	jmp    801010f0 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010cd:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010d1:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
801010d6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010d9:	72 c9                	jb     801010a4 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010db:	83 ec 0c             	sub    $0xc,%esp
801010de:	68 60 2d 19 80       	push   $0x80192d60
801010e3:	e8 25 3a 00 00       	call   80104b0d <release>
801010e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801010eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010f0:	c9                   	leave
801010f1:	c3                   	ret

801010f2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010f2:	f3 0f 1e fb          	endbr32
801010f6:	55                   	push   %ebp
801010f7:	89 e5                	mov    %esp,%ebp
801010f9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010fc:	83 ec 0c             	sub    $0xc,%esp
801010ff:	68 60 2d 19 80       	push   $0x80192d60
80101104:	e8 92 39 00 00       	call   80104a9b <acquire>
80101109:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010110c:	8b 45 08             	mov    0x8(%ebp),%eax
8010110f:	8b 40 04             	mov    0x4(%eax),%eax
80101112:	85 c0                	test   %eax,%eax
80101114:	7f 0d                	jg     80101123 <filedup+0x31>
    panic("filedup");
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	68 75 a8 10 80       	push   $0x8010a875
8010111e:	e8 bb f4 ff ff       	call   801005de <panic>
  f->ref++;
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	8b 40 04             	mov    0x4(%eax),%eax
80101129:	8d 50 01             	lea    0x1(%eax),%edx
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101132:	83 ec 0c             	sub    $0xc,%esp
80101135:	68 60 2d 19 80       	push   $0x80192d60
8010113a:	e8 ce 39 00 00       	call   80104b0d <release>
8010113f:	83 c4 10             	add    $0x10,%esp
  return f;
80101142:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101145:	c9                   	leave
80101146:	c3                   	ret

80101147 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101147:	f3 0f 1e fb          	endbr32
8010114b:	55                   	push   %ebp
8010114c:	89 e5                	mov    %esp,%ebp
8010114e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101151:	83 ec 0c             	sub    $0xc,%esp
80101154:	68 60 2d 19 80       	push   $0x80192d60
80101159:	e8 3d 39 00 00       	call   80104a9b <acquire>
8010115e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101161:	8b 45 08             	mov    0x8(%ebp),%eax
80101164:	8b 40 04             	mov    0x4(%eax),%eax
80101167:	85 c0                	test   %eax,%eax
80101169:	7f 0d                	jg     80101178 <fileclose+0x31>
    panic("fileclose");
8010116b:	83 ec 0c             	sub    $0xc,%esp
8010116e:	68 7d a8 10 80       	push   $0x8010a87d
80101173:	e8 66 f4 ff ff       	call   801005de <panic>
  if(--f->ref > 0){
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 40 04             	mov    0x4(%eax),%eax
8010117e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	89 50 04             	mov    %edx,0x4(%eax)
80101187:	8b 45 08             	mov    0x8(%ebp),%eax
8010118a:	8b 40 04             	mov    0x4(%eax),%eax
8010118d:	85 c0                	test   %eax,%eax
8010118f:	7e 15                	jle    801011a6 <fileclose+0x5f>
    release(&ftable.lock);
80101191:	83 ec 0c             	sub    $0xc,%esp
80101194:	68 60 2d 19 80       	push   $0x80192d60
80101199:	e8 6f 39 00 00       	call   80104b0d <release>
8010119e:	83 c4 10             	add    $0x10,%esp
801011a1:	e9 8b 00 00 00       	jmp    80101231 <fileclose+0xea>
    return;
  }
  ff = *f;
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 10                	mov    (%eax),%edx
801011ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011ae:	8b 50 04             	mov    0x4(%eax),%edx
801011b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011b4:	8b 50 08             	mov    0x8(%eax),%edx
801011b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011ba:	8b 50 0c             	mov    0xc(%eax),%edx
801011bd:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011c0:	8b 50 10             	mov    0x10(%eax),%edx
801011c3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011c6:	8b 40 14             	mov    0x14(%eax),%eax
801011c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011df:	83 ec 0c             	sub    $0xc,%esp
801011e2:	68 60 2d 19 80       	push   $0x80192d60
801011e7:	e8 21 39 00 00       	call   80104b0d <release>
801011ec:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011f2:	83 f8 01             	cmp    $0x1,%eax
801011f5:	75 19                	jne    80101210 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801011f7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011fb:	0f be d0             	movsbl %al,%edx
801011fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	52                   	push   %edx
80101205:	50                   	push   %eax
80101206:	e8 73 26 00 00       	call   8010387e <pipeclose>
8010120b:	83 c4 10             	add    $0x10,%esp
8010120e:	eb 21                	jmp    80101231 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101210:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101213:	83 f8 02             	cmp    $0x2,%eax
80101216:	75 19                	jne    80101231 <fileclose+0xea>
    begin_op();
80101218:	e8 b2 1f 00 00       	call   801031cf <begin_op>
    iput(ff.ip);
8010121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101220:	83 ec 0c             	sub    $0xc,%esp
80101223:	50                   	push   %eax
80101224:	e8 1a 0a 00 00       	call   80101c43 <iput>
80101229:	83 c4 10             	add    $0x10,%esp
    end_op();
8010122c:	e8 2e 20 00 00       	call   8010325f <end_op>
  }
}
80101231:	c9                   	leave
80101232:	c3                   	ret

80101233 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101233:	f3 0f 1e fb          	endbr32
80101237:	55                   	push   %ebp
80101238:	89 e5                	mov    %esp,%ebp
8010123a:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010123d:	8b 45 08             	mov    0x8(%ebp),%eax
80101240:	8b 00                	mov    (%eax),%eax
80101242:	83 f8 02             	cmp    $0x2,%eax
80101245:	75 40                	jne    80101287 <filestat+0x54>
    ilock(f->ip);
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	8b 40 10             	mov    0x10(%eax),%eax
8010124d:	83 ec 0c             	sub    $0xc,%esp
80101250:	50                   	push   %eax
80101251:	e8 84 08 00 00       	call   80101ada <ilock>
80101256:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 10             	mov    0x10(%eax),%eax
8010125f:	83 ec 08             	sub    $0x8,%esp
80101262:	ff 75 0c             	push   0xc(%ebp)
80101265:	50                   	push   %eax
80101266:	e8 2d 0d 00 00       	call   80101f98 <stati>
8010126b:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 10             	mov    0x10(%eax),%eax
80101274:	83 ec 0c             	sub    $0xc,%esp
80101277:	50                   	push   %eax
80101278:	e8 74 09 00 00       	call   80101bf1 <iunlock>
8010127d:	83 c4 10             	add    $0x10,%esp
    return 0;
80101280:	b8 00 00 00 00       	mov    $0x0,%eax
80101285:	eb 05                	jmp    8010128c <filestat+0x59>
  }
  return -1;
80101287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010128c:	c9                   	leave
8010128d:	c3                   	ret

8010128e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010128e:	f3 0f 1e fb          	endbr32
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010129f:	84 c0                	test   %al,%al
801012a1:	75 0a                	jne    801012ad <fileread+0x1f>
    return -1;
801012a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a8:	e9 9b 00 00 00       	jmp    80101348 <fileread+0xba>
  if(f->type == FD_PIPE)
801012ad:	8b 45 08             	mov    0x8(%ebp),%eax
801012b0:	8b 00                	mov    (%eax),%eax
801012b2:	83 f8 01             	cmp    $0x1,%eax
801012b5:	75 1a                	jne    801012d1 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012b7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ba:	8b 40 0c             	mov    0xc(%eax),%eax
801012bd:	83 ec 04             	sub    $0x4,%esp
801012c0:	ff 75 10             	push   0x10(%ebp)
801012c3:	ff 75 0c             	push   0xc(%ebp)
801012c6:	50                   	push   %eax
801012c7:	e8 67 27 00 00       	call   80103a33 <piperead>
801012cc:	83 c4 10             	add    $0x10,%esp
801012cf:	eb 77                	jmp    80101348 <fileread+0xba>
  if(f->type == FD_INODE){
801012d1:	8b 45 08             	mov    0x8(%ebp),%eax
801012d4:	8b 00                	mov    (%eax),%eax
801012d6:	83 f8 02             	cmp    $0x2,%eax
801012d9:	75 60                	jne    8010133b <fileread+0xad>
    ilock(f->ip);
801012db:	8b 45 08             	mov    0x8(%ebp),%eax
801012de:	8b 40 10             	mov    0x10(%eax),%eax
801012e1:	83 ec 0c             	sub    $0xc,%esp
801012e4:	50                   	push   %eax
801012e5:	e8 f0 07 00 00       	call   80101ada <ilock>
801012ea:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012f0:	8b 45 08             	mov    0x8(%ebp),%eax
801012f3:	8b 50 14             	mov    0x14(%eax),%edx
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	8b 40 10             	mov    0x10(%eax),%eax
801012fc:	51                   	push   %ecx
801012fd:	52                   	push   %edx
801012fe:	ff 75 0c             	push   0xc(%ebp)
80101301:	50                   	push   %eax
80101302:	e8 db 0c 00 00       	call   80101fe2 <readi>
80101307:	83 c4 10             	add    $0x10,%esp
8010130a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010130d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101311:	7e 11                	jle    80101324 <fileread+0x96>
      f->off += r;
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	8b 50 14             	mov    0x14(%eax),%edx
80101319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131c:	01 c2                	add    %eax,%edx
8010131e:	8b 45 08             	mov    0x8(%ebp),%eax
80101321:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101324:	8b 45 08             	mov    0x8(%ebp),%eax
80101327:	8b 40 10             	mov    0x10(%eax),%eax
8010132a:	83 ec 0c             	sub    $0xc,%esp
8010132d:	50                   	push   %eax
8010132e:	e8 be 08 00 00       	call   80101bf1 <iunlock>
80101333:	83 c4 10             	add    $0x10,%esp
    return r;
80101336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101339:	eb 0d                	jmp    80101348 <fileread+0xba>
  }
  panic("fileread");
8010133b:	83 ec 0c             	sub    $0xc,%esp
8010133e:	68 87 a8 10 80       	push   $0x8010a887
80101343:	e8 96 f2 ff ff       	call   801005de <panic>
}
80101348:	c9                   	leave
80101349:	c3                   	ret

8010134a <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010134a:	f3 0f 1e fb          	endbr32
8010134e:	55                   	push   %ebp
8010134f:	89 e5                	mov    %esp,%ebp
80101351:	53                   	push   %ebx
80101352:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101355:	8b 45 08             	mov    0x8(%ebp),%eax
80101358:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010135c:	84 c0                	test   %al,%al
8010135e:	75 0a                	jne    8010136a <filewrite+0x20>
    return -1;
80101360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101365:	e9 1b 01 00 00       	jmp    80101485 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 00                	mov    (%eax),%eax
8010136f:	83 f8 01             	cmp    $0x1,%eax
80101372:	75 1d                	jne    80101391 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101374:	8b 45 08             	mov    0x8(%ebp),%eax
80101377:	8b 40 0c             	mov    0xc(%eax),%eax
8010137a:	83 ec 04             	sub    $0x4,%esp
8010137d:	ff 75 10             	push   0x10(%ebp)
80101380:	ff 75 0c             	push   0xc(%ebp)
80101383:	50                   	push   %eax
80101384:	e8 a4 25 00 00       	call   8010392d <pipewrite>
80101389:	83 c4 10             	add    $0x10,%esp
8010138c:	e9 f4 00 00 00       	jmp    80101485 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8b 00                	mov    (%eax),%eax
80101396:	83 f8 02             	cmp    $0x2,%eax
80101399:	0f 85 d9 00 00 00    	jne    80101478 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010139f:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ad:	e9 a3 00 00 00       	jmp    80101455 <filewrite+0x10b>
      int n1 = n - i;
801013b2:	8b 45 10             	mov    0x10(%ebp),%eax
801013b5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013be:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013c1:	7e 06                	jle    801013c9 <filewrite+0x7f>
        n1 = max;
801013c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013c9:	e8 01 1e 00 00       	call   801031cf <begin_op>
      ilock(f->ip);
801013ce:	8b 45 08             	mov    0x8(%ebp),%eax
801013d1:	8b 40 10             	mov    0x10(%eax),%eax
801013d4:	83 ec 0c             	sub    $0xc,%esp
801013d7:	50                   	push   %eax
801013d8:	e8 fd 06 00 00       	call   80101ada <ilock>
801013dd:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013e0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013e3:	8b 45 08             	mov    0x8(%ebp),%eax
801013e6:	8b 50 14             	mov    0x14(%eax),%edx
801013e9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ef:	01 c3                	add    %eax,%ebx
801013f1:	8b 45 08             	mov    0x8(%ebp),%eax
801013f4:	8b 40 10             	mov    0x10(%eax),%eax
801013f7:	51                   	push   %ecx
801013f8:	52                   	push   %edx
801013f9:	53                   	push   %ebx
801013fa:	50                   	push   %eax
801013fb:	e8 3b 0d 00 00       	call   8010213b <writei>
80101400:	83 c4 10             	add    $0x10,%esp
80101403:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101406:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010140a:	7e 11                	jle    8010141d <filewrite+0xd3>
        f->off += r;
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	8b 50 14             	mov    0x14(%eax),%edx
80101412:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101415:	01 c2                	add    %eax,%edx
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010141d:	8b 45 08             	mov    0x8(%ebp),%eax
80101420:	8b 40 10             	mov    0x10(%eax),%eax
80101423:	83 ec 0c             	sub    $0xc,%esp
80101426:	50                   	push   %eax
80101427:	e8 c5 07 00 00       	call   80101bf1 <iunlock>
8010142c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010142f:	e8 2b 1e 00 00       	call   8010325f <end_op>

      if(r < 0)
80101434:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101438:	78 29                	js     80101463 <filewrite+0x119>
        break;
      if(r != n1)
8010143a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010143d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101440:	74 0d                	je     8010144f <filewrite+0x105>
        panic("short filewrite");
80101442:	83 ec 0c             	sub    $0xc,%esp
80101445:	68 90 a8 10 80       	push   $0x8010a890
8010144a:	e8 8f f1 ff ff       	call   801005de <panic>
      i += r;
8010144f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101452:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101458:	3b 45 10             	cmp    0x10(%ebp),%eax
8010145b:	0f 8c 51 ff ff ff    	jl     801013b2 <filewrite+0x68>
80101461:	eb 01                	jmp    80101464 <filewrite+0x11a>
        break;
80101463:	90                   	nop
    }
    return i == n ? n : -1;
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	3b 45 10             	cmp    0x10(%ebp),%eax
8010146a:	75 05                	jne    80101471 <filewrite+0x127>
8010146c:	8b 45 10             	mov    0x10(%ebp),%eax
8010146f:	eb 14                	jmp    80101485 <filewrite+0x13b>
80101471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101476:	eb 0d                	jmp    80101485 <filewrite+0x13b>
  }
  panic("filewrite");
80101478:	83 ec 0c             	sub    $0xc,%esp
8010147b:	68 a0 a8 10 80       	push   $0x8010a8a0
80101480:	e8 59 f1 ff ff       	call   801005de <panic>
}
80101485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101488:	c9                   	leave
80101489:	c3                   	ret

8010148a <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010148a:	f3 0f 1e fb          	endbr32
8010148e:	55                   	push   %ebp
8010148f:	89 e5                	mov    %esp,%ebp
80101491:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101494:	8b 45 08             	mov    0x8(%ebp),%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	6a 01                	push   $0x1
8010149c:	50                   	push   %eax
8010149d:	e8 67 ed ff ff       	call   80100209 <bread>
801014a2:	83 c4 10             	add    $0x10,%esp
801014a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ab:	83 c0 5c             	add    $0x5c,%eax
801014ae:	83 ec 04             	sub    $0x4,%esp
801014b1:	6a 1c                	push   $0x1c
801014b3:	50                   	push   %eax
801014b4:	ff 75 0c             	push   0xc(%ebp)
801014b7:	e8 35 39 00 00       	call   80104df1 <memmove>
801014bc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014bf:	83 ec 0c             	sub    $0xc,%esp
801014c2:	ff 75 f4             	push   -0xc(%ebp)
801014c5:	e8 c9 ed ff ff       	call   80100293 <brelse>
801014ca:	83 c4 10             	add    $0x10,%esp
}
801014cd:	90                   	nop
801014ce:	c9                   	leave
801014cf:	c3                   	ret

801014d0 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014d0:	f3 0f 1e fb          	endbr32
801014d4:	55                   	push   %ebp
801014d5:	89 e5                	mov    %esp,%ebp
801014d7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014da:	8b 55 0c             	mov    0xc(%ebp),%edx
801014dd:	8b 45 08             	mov    0x8(%ebp),%eax
801014e0:	83 ec 08             	sub    $0x8,%esp
801014e3:	52                   	push   %edx
801014e4:	50                   	push   %eax
801014e5:	e8 1f ed ff ff       	call   80100209 <bread>
801014ea:	83 c4 10             	add    $0x10,%esp
801014ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014f3:	83 c0 5c             	add    $0x5c,%eax
801014f6:	83 ec 04             	sub    $0x4,%esp
801014f9:	68 00 02 00 00       	push   $0x200
801014fe:	6a 00                	push   $0x0
80101500:	50                   	push   %eax
80101501:	e8 24 38 00 00       	call   80104d2a <memset>
80101506:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101509:	83 ec 0c             	sub    $0xc,%esp
8010150c:	ff 75 f4             	push   -0xc(%ebp)
8010150f:	e8 04 1f 00 00       	call   80103418 <log_write>
80101514:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101517:	83 ec 0c             	sub    $0xc,%esp
8010151a:	ff 75 f4             	push   -0xc(%ebp)
8010151d:	e8 71 ed ff ff       	call   80100293 <brelse>
80101522:	83 c4 10             	add    $0x10,%esp
}
80101525:	90                   	nop
80101526:	c9                   	leave
80101527:	c3                   	ret

80101528 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101528:	f3 0f 1e fb          	endbr32
8010152c:	55                   	push   %ebp
8010152d:	89 e5                	mov    %esp,%ebp
8010152f:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101532:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101539:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101540:	e9 13 01 00 00       	jmp    80101658 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101548:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010154e:	85 c0                	test   %eax,%eax
80101550:	0f 48 c2             	cmovs  %edx,%eax
80101553:	c1 f8 0c             	sar    $0xc,%eax
80101556:	89 c2                	mov    %eax,%edx
80101558:	a1 78 37 19 80       	mov    0x80193778,%eax
8010155d:	01 d0                	add    %edx,%eax
8010155f:	83 ec 08             	sub    $0x8,%esp
80101562:	50                   	push   %eax
80101563:	ff 75 08             	push   0x8(%ebp)
80101566:	e8 9e ec ff ff       	call   80100209 <bread>
8010156b:	83 c4 10             	add    $0x10,%esp
8010156e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101571:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101578:	e9 a6 00 00 00       	jmp    80101623 <balloc+0xfb>
      m = 1 << (bi % 8);
8010157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101580:	99                   	cltd
80101581:	c1 ea 1d             	shr    $0x1d,%edx
80101584:	01 d0                	add    %edx,%eax
80101586:	83 e0 07             	and    $0x7,%eax
80101589:	29 d0                	sub    %edx,%eax
8010158b:	ba 01 00 00 00       	mov    $0x1,%edx
80101590:	89 c1                	mov    %eax,%ecx
80101592:	d3 e2                	shl    %cl,%edx
80101594:	89 d0                	mov    %edx,%eax
80101596:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101599:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159c:	8d 50 07             	lea    0x7(%eax),%edx
8010159f:	85 c0                	test   %eax,%eax
801015a1:	0f 48 c2             	cmovs  %edx,%eax
801015a4:	c1 f8 03             	sar    $0x3,%eax
801015a7:	89 c2                	mov    %eax,%edx
801015a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015ac:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015b1:	0f b6 c0             	movzbl %al,%eax
801015b4:	23 45 e8             	and    -0x18(%ebp),%eax
801015b7:	85 c0                	test   %eax,%eax
801015b9:	75 64                	jne    8010161f <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015be:	8d 50 07             	lea    0x7(%eax),%edx
801015c1:	85 c0                	test   %eax,%eax
801015c3:	0f 48 c2             	cmovs  %edx,%eax
801015c6:	c1 f8 03             	sar    $0x3,%eax
801015c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015cc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015d1:	89 d1                	mov    %edx,%ecx
801015d3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015d6:	09 ca                	or     %ecx,%edx
801015d8:	89 d1                	mov    %edx,%ecx
801015da:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015dd:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015e1:	83 ec 0c             	sub    $0xc,%esp
801015e4:	ff 75 ec             	push   -0x14(%ebp)
801015e7:	e8 2c 1e 00 00       	call   80103418 <log_write>
801015ec:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015ef:	83 ec 0c             	sub    $0xc,%esp
801015f2:	ff 75 ec             	push   -0x14(%ebp)
801015f5:	e8 99 ec ff ff       	call   80100293 <brelse>
801015fa:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101603:	01 c2                	add    %eax,%edx
80101605:	8b 45 08             	mov    0x8(%ebp),%eax
80101608:	83 ec 08             	sub    $0x8,%esp
8010160b:	52                   	push   %edx
8010160c:	50                   	push   %eax
8010160d:	e8 be fe ff ff       	call   801014d0 <bzero>
80101612:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101615:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161b:	01 d0                	add    %edx,%eax
8010161d:	eb 57                	jmp    80101676 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010161f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101623:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010162a:	7f 17                	jg     80101643 <balloc+0x11b>
8010162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101632:	01 d0                	add    %edx,%eax
80101634:	89 c2                	mov    %eax,%edx
80101636:	a1 60 37 19 80       	mov    0x80193760,%eax
8010163b:	39 c2                	cmp    %eax,%edx
8010163d:	0f 82 3a ff ff ff    	jb     8010157d <balloc+0x55>
      }
    }
    brelse(bp);
80101643:	83 ec 0c             	sub    $0xc,%esp
80101646:	ff 75 ec             	push   -0x14(%ebp)
80101649:	e8 45 ec ff ff       	call   80100293 <brelse>
8010164e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101651:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101658:	8b 15 60 37 19 80    	mov    0x80193760,%edx
8010165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101661:	39 c2                	cmp    %eax,%edx
80101663:	0f 87 dc fe ff ff    	ja     80101545 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 ac a8 10 80       	push   $0x8010a8ac
80101671:	e8 68 ef ff ff       	call   801005de <panic>
}
80101676:	c9                   	leave
80101677:	c3                   	ret

80101678 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101678:	f3 0f 1e fb          	endbr32
8010167c:	55                   	push   %ebp
8010167d:	89 e5                	mov    %esp,%ebp
8010167f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101682:	83 ec 08             	sub    $0x8,%esp
80101685:	68 60 37 19 80       	push   $0x80193760
8010168a:	ff 75 08             	push   0x8(%ebp)
8010168d:	e8 f8 fd ff ff       	call   8010148a <readsb>
80101692:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101695:	8b 45 0c             	mov    0xc(%ebp),%eax
80101698:	c1 e8 0c             	shr    $0xc,%eax
8010169b:	89 c2                	mov    %eax,%edx
8010169d:	a1 78 37 19 80       	mov    0x80193778,%eax
801016a2:	01 c2                	add    %eax,%edx
801016a4:	8b 45 08             	mov    0x8(%ebp),%eax
801016a7:	83 ec 08             	sub    $0x8,%esp
801016aa:	52                   	push   %edx
801016ab:	50                   	push   %eax
801016ac:	e8 58 eb ff ff       	call   80100209 <bread>
801016b1:	83 c4 10             	add    $0x10,%esp
801016b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ba:	25 ff 0f 00 00       	and    $0xfff,%eax
801016bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c5:	99                   	cltd
801016c6:	c1 ea 1d             	shr    $0x1d,%edx
801016c9:	01 d0                	add    %edx,%eax
801016cb:	83 e0 07             	and    $0x7,%eax
801016ce:	29 d0                	sub    %edx,%eax
801016d0:	ba 01 00 00 00       	mov    $0x1,%edx
801016d5:	89 c1                	mov    %eax,%ecx
801016d7:	d3 e2                	shl    %cl,%edx
801016d9:	89 d0                	mov    %edx,%eax
801016db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e1:	8d 50 07             	lea    0x7(%eax),%edx
801016e4:	85 c0                	test   %eax,%eax
801016e6:	0f 48 c2             	cmovs  %edx,%eax
801016e9:	c1 f8 03             	sar    $0x3,%eax
801016ec:	89 c2                	mov    %eax,%edx
801016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f1:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016f6:	0f b6 c0             	movzbl %al,%eax
801016f9:	23 45 ec             	and    -0x14(%ebp),%eax
801016fc:	85 c0                	test   %eax,%eax
801016fe:	75 0d                	jne    8010170d <bfree+0x95>
    panic("freeing free block");
80101700:	83 ec 0c             	sub    $0xc,%esp
80101703:	68 c2 a8 10 80       	push   $0x8010a8c2
80101708:	e8 d1 ee ff ff       	call   801005de <panic>
  bp->data[bi/8] &= ~m;
8010170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101710:	8d 50 07             	lea    0x7(%eax),%edx
80101713:	85 c0                	test   %eax,%eax
80101715:	0f 48 c2             	cmovs  %edx,%eax
80101718:	c1 f8 03             	sar    $0x3,%eax
8010171b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010171e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101723:	89 d1                	mov    %edx,%ecx
80101725:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101728:	f7 d2                	not    %edx
8010172a:	21 ca                	and    %ecx,%edx
8010172c:	89 d1                	mov    %edx,%ecx
8010172e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101731:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101735:	83 ec 0c             	sub    $0xc,%esp
80101738:	ff 75 f4             	push   -0xc(%ebp)
8010173b:	e8 d8 1c 00 00       	call   80103418 <log_write>
80101740:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101743:	83 ec 0c             	sub    $0xc,%esp
80101746:	ff 75 f4             	push   -0xc(%ebp)
80101749:	e8 45 eb ff ff       	call   80100293 <brelse>
8010174e:	83 c4 10             	add    $0x10,%esp
}
80101751:	90                   	nop
80101752:	c9                   	leave
80101753:	c3                   	ret

80101754 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101754:	f3 0f 1e fb          	endbr32
80101758:	55                   	push   %ebp
80101759:	89 e5                	mov    %esp,%ebp
8010175b:	57                   	push   %edi
8010175c:	56                   	push   %esi
8010175d:	53                   	push   %ebx
8010175e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101761:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101768:	83 ec 08             	sub    $0x8,%esp
8010176b:	68 d5 a8 10 80       	push   $0x8010a8d5
80101770:	68 80 37 19 80       	push   $0x80193780
80101775:	e8 fb 32 00 00       	call   80104a75 <initlock>
8010177a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010177d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101784:	eb 2d                	jmp    801017b3 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101786:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101789:	89 d0                	mov    %edx,%eax
8010178b:	c1 e0 03             	shl    $0x3,%eax
8010178e:	01 d0                	add    %edx,%eax
80101790:	c1 e0 04             	shl    $0x4,%eax
80101793:	83 c0 30             	add    $0x30,%eax
80101796:	05 80 37 19 80       	add    $0x80193780,%eax
8010179b:	83 c0 10             	add    $0x10,%eax
8010179e:	83 ec 08             	sub    $0x8,%esp
801017a1:	68 dc a8 10 80       	push   $0x8010a8dc
801017a6:	50                   	push   %eax
801017a7:	e8 5c 31 00 00       	call   80104908 <initsleeplock>
801017ac:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017af:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017b3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017b7:	7e cd                	jle    80101786 <iinit+0x32>
  }

  readsb(dev, &sb);
801017b9:	83 ec 08             	sub    $0x8,%esp
801017bc:	68 60 37 19 80       	push   $0x80193760
801017c1:	ff 75 08             	push   0x8(%ebp)
801017c4:	e8 c1 fc ff ff       	call   8010148a <readsb>
801017c9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 78 37 19 80       	mov    0x80193778,%eax
801017d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017d4:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
801017da:	8b 35 70 37 19 80    	mov    0x80193770,%esi
801017e0:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
801017e6:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
801017ec:	8b 15 64 37 19 80    	mov    0x80193764,%edx
801017f2:	a1 60 37 19 80       	mov    0x80193760,%eax
801017f7:	ff 75 d4             	push   -0x2c(%ebp)
801017fa:	57                   	push   %edi
801017fb:	56                   	push   %esi
801017fc:	53                   	push   %ebx
801017fd:	51                   	push   %ecx
801017fe:	52                   	push   %edx
801017ff:	50                   	push   %eax
80101800:	68 e4 a8 10 80       	push   $0x8010a8e4
80101805:	e8 02 ec ff ff       	call   8010040c <cprintf>
8010180a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010180d:	90                   	nop
8010180e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101811:	5b                   	pop    %ebx
80101812:	5e                   	pop    %esi
80101813:	5f                   	pop    %edi
80101814:	5d                   	pop    %ebp
80101815:	c3                   	ret

80101816 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101816:	f3 0f 1e fb          	endbr32
8010181a:	55                   	push   %ebp
8010181b:	89 e5                	mov    %esp,%ebp
8010181d:	83 ec 28             	sub    $0x28,%esp
80101820:	8b 45 0c             	mov    0xc(%ebp),%eax
80101823:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101827:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010182e:	e9 9e 00 00 00       	jmp    801018d1 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101836:	c1 e8 03             	shr    $0x3,%eax
80101839:	89 c2                	mov    %eax,%edx
8010183b:	a1 74 37 19 80       	mov    0x80193774,%eax
80101840:	01 d0                	add    %edx,%eax
80101842:	83 ec 08             	sub    $0x8,%esp
80101845:	50                   	push   %eax
80101846:	ff 75 08             	push   0x8(%ebp)
80101849:	e8 bb e9 ff ff       	call   80100209 <bread>
8010184e:	83 c4 10             	add    $0x10,%esp
80101851:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101857:	8d 50 5c             	lea    0x5c(%eax),%edx
8010185a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185d:	83 e0 07             	and    $0x7,%eax
80101860:	c1 e0 06             	shl    $0x6,%eax
80101863:	01 d0                	add    %edx,%eax
80101865:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010186b:	0f b7 00             	movzwl (%eax),%eax
8010186e:	66 85 c0             	test   %ax,%ax
80101871:	75 4c                	jne    801018bf <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101873:	83 ec 04             	sub    $0x4,%esp
80101876:	6a 40                	push   $0x40
80101878:	6a 00                	push   $0x0
8010187a:	ff 75 ec             	push   -0x14(%ebp)
8010187d:	e8 a8 34 00 00       	call   80104d2a <memset>
80101882:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101885:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101888:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010188c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010188f:	83 ec 0c             	sub    $0xc,%esp
80101892:	ff 75 f0             	push   -0x10(%ebp)
80101895:	e8 7e 1b 00 00       	call   80103418 <log_write>
8010189a:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010189d:	83 ec 0c             	sub    $0xc,%esp
801018a0:	ff 75 f0             	push   -0x10(%ebp)
801018a3:	e8 eb e9 ff ff       	call   80100293 <brelse>
801018a8:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ae:	83 ec 08             	sub    $0x8,%esp
801018b1:	50                   	push   %eax
801018b2:	ff 75 08             	push   0x8(%ebp)
801018b5:	e8 fc 00 00 00       	call   801019b6 <iget>
801018ba:	83 c4 10             	add    $0x10,%esp
801018bd:	eb 30                	jmp    801018ef <ialloc+0xd9>
    }
    brelse(bp);
801018bf:	83 ec 0c             	sub    $0xc,%esp
801018c2:	ff 75 f0             	push   -0x10(%ebp)
801018c5:	e8 c9 e9 ff ff       	call   80100293 <brelse>
801018ca:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018d1:	8b 15 68 37 19 80    	mov    0x80193768,%edx
801018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018da:	39 c2                	cmp    %eax,%edx
801018dc:	0f 87 51 ff ff ff    	ja     80101833 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018e2:	83 ec 0c             	sub    $0xc,%esp
801018e5:	68 37 a9 10 80       	push   $0x8010a937
801018ea:	e8 ef ec ff ff       	call   801005de <panic>
}
801018ef:	c9                   	leave
801018f0:	c3                   	ret

801018f1 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018f1:	f3 0f 1e fb          	endbr32
801018f5:	55                   	push   %ebp
801018f6:	89 e5                	mov    %esp,%ebp
801018f8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018fb:	8b 45 08             	mov    0x8(%ebp),%eax
801018fe:	8b 40 04             	mov    0x4(%eax),%eax
80101901:	c1 e8 03             	shr    $0x3,%eax
80101904:	89 c2                	mov    %eax,%edx
80101906:	a1 74 37 19 80       	mov    0x80193774,%eax
8010190b:	01 c2                	add    %eax,%edx
8010190d:	8b 45 08             	mov    0x8(%ebp),%eax
80101910:	8b 00                	mov    (%eax),%eax
80101912:	83 ec 08             	sub    $0x8,%esp
80101915:	52                   	push   %edx
80101916:	50                   	push   %eax
80101917:	e8 ed e8 ff ff       	call   80100209 <bread>
8010191c:	83 c4 10             	add    $0x10,%esp
8010191f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101925:	8d 50 5c             	lea    0x5c(%eax),%edx
80101928:	8b 45 08             	mov    0x8(%ebp),%eax
8010192b:	8b 40 04             	mov    0x4(%eax),%eax
8010192e:	83 e0 07             	and    $0x7,%eax
80101931:	c1 e0 06             	shl    $0x6,%eax
80101934:	01 d0                	add    %edx,%eax
80101936:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101939:	8b 45 08             	mov    0x8(%ebp),%eax
8010193c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101943:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010194d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101950:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101954:	8b 45 08             	mov    0x8(%ebp),%eax
80101957:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010195b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101962:	8b 45 08             	mov    0x8(%ebp),%eax
80101965:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101970:	8b 45 08             	mov    0x8(%ebp),%eax
80101973:	8b 50 58             	mov    0x58(%eax),%edx
80101976:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101979:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101985:	83 c0 0c             	add    $0xc,%eax
80101988:	83 ec 04             	sub    $0x4,%esp
8010198b:	6a 34                	push   $0x34
8010198d:	52                   	push   %edx
8010198e:	50                   	push   %eax
8010198f:	e8 5d 34 00 00       	call   80104df1 <memmove>
80101994:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101997:	83 ec 0c             	sub    $0xc,%esp
8010199a:	ff 75 f4             	push   -0xc(%ebp)
8010199d:	e8 76 1a 00 00       	call   80103418 <log_write>
801019a2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019a5:	83 ec 0c             	sub    $0xc,%esp
801019a8:	ff 75 f4             	push   -0xc(%ebp)
801019ab:	e8 e3 e8 ff ff       	call   80100293 <brelse>
801019b0:	83 c4 10             	add    $0x10,%esp
}
801019b3:	90                   	nop
801019b4:	c9                   	leave
801019b5:	c3                   	ret

801019b6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019b6:	f3 0f 1e fb          	endbr32
801019ba:	55                   	push   %ebp
801019bb:	89 e5                	mov    %esp,%ebp
801019bd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019c0:	83 ec 0c             	sub    $0xc,%esp
801019c3:	68 80 37 19 80       	push   $0x80193780
801019c8:	e8 ce 30 00 00       	call   80104a9b <acquire>
801019cd:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d7:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
801019de:	eb 60                	jmp    80101a40 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e3:	8b 40 08             	mov    0x8(%eax),%eax
801019e6:	85 c0                	test   %eax,%eax
801019e8:	7e 39                	jle    80101a23 <iget+0x6d>
801019ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ed:	8b 00                	mov    (%eax),%eax
801019ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801019f2:	75 2f                	jne    80101a23 <iget+0x6d>
801019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f7:	8b 40 04             	mov    0x4(%eax),%eax
801019fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019fd:	75 24                	jne    80101a23 <iget+0x6d>
      ip->ref++;
801019ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a02:	8b 40 08             	mov    0x8(%eax),%eax
80101a05:	8d 50 01             	lea    0x1(%eax),%edx
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a0e:	83 ec 0c             	sub    $0xc,%esp
80101a11:	68 80 37 19 80       	push   $0x80193780
80101a16:	e8 f2 30 00 00       	call   80104b0d <release>
80101a1b:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a21:	eb 77                	jmp    80101a9a <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a27:	75 10                	jne    80101a39 <iget+0x83>
80101a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2c:	8b 40 08             	mov    0x8(%eax),%eax
80101a2f:	85 c0                	test   %eax,%eax
80101a31:	75 06                	jne    80101a39 <iget+0x83>
      empty = ip;
80101a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a39:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a40:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
80101a47:	72 97                	jb     801019e0 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a4d:	75 0d                	jne    80101a5c <iget+0xa6>
    panic("iget: no inodes");
80101a4f:	83 ec 0c             	sub    $0xc,%esp
80101a52:	68 49 a9 10 80       	push   $0x8010a949
80101a57:	e8 82 eb ff ff       	call   801005de <panic>

  ip = empty;
80101a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 55 08             	mov    0x8(%ebp),%edx
80101a68:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a70:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a76:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a80:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a87:	83 ec 0c             	sub    $0xc,%esp
80101a8a:	68 80 37 19 80       	push   $0x80193780
80101a8f:	e8 79 30 00 00       	call   80104b0d <release>
80101a94:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a9a:	c9                   	leave
80101a9b:	c3                   	ret

80101a9c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a9c:	f3 0f 1e fb          	endbr32
80101aa0:	55                   	push   %ebp
80101aa1:	89 e5                	mov    %esp,%ebp
80101aa3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aa6:	83 ec 0c             	sub    $0xc,%esp
80101aa9:	68 80 37 19 80       	push   $0x80193780
80101aae:	e8 e8 2f 00 00       	call   80104a9b <acquire>
80101ab3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab9:	8b 40 08             	mov    0x8(%eax),%eax
80101abc:	8d 50 01             	lea    0x1(%eax),%edx
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ac5:	83 ec 0c             	sub    $0xc,%esp
80101ac8:	68 80 37 19 80       	push   $0x80193780
80101acd:	e8 3b 30 00 00       	call   80104b0d <release>
80101ad2:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ad8:	c9                   	leave
80101ad9:	c3                   	ret

80101ada <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ada:	f3 0f 1e fb          	endbr32
80101ade:	55                   	push   %ebp
80101adf:	89 e5                	mov    %esp,%ebp
80101ae1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ae4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ae8:	74 0a                	je     80101af4 <ilock+0x1a>
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	8b 40 08             	mov    0x8(%eax),%eax
80101af0:	85 c0                	test   %eax,%eax
80101af2:	7f 0d                	jg     80101b01 <ilock+0x27>
    panic("ilock");
80101af4:	83 ec 0c             	sub    $0xc,%esp
80101af7:	68 59 a9 10 80       	push   $0x8010a959
80101afc:	e8 dd ea ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	83 c0 0c             	add    $0xc,%eax
80101b07:	83 ec 0c             	sub    $0xc,%esp
80101b0a:	50                   	push   %eax
80101b0b:	e8 38 2e 00 00       	call   80104948 <acquiresleep>
80101b10:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b19:	85 c0                	test   %eax,%eax
80101b1b:	0f 85 cd 00 00 00    	jne    80101bee <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	8b 40 04             	mov    0x4(%eax),%eax
80101b27:	c1 e8 03             	shr    $0x3,%eax
80101b2a:	89 c2                	mov    %eax,%edx
80101b2c:	a1 74 37 19 80       	mov    0x80193774,%eax
80101b31:	01 c2                	add    %eax,%edx
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	8b 00                	mov    (%eax),%eax
80101b38:	83 ec 08             	sub    $0x8,%esp
80101b3b:	52                   	push   %edx
80101b3c:	50                   	push   %eax
80101b3d:	e8 c7 e6 ff ff       	call   80100209 <bread>
80101b42:	83 c4 10             	add    $0x10,%esp
80101b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b4b:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 04             	mov    0x4(%eax),%eax
80101b54:	83 e0 07             	and    $0x7,%eax
80101b57:	c1 e0 06             	shl    $0x6,%eax
80101b5a:	01 d0                	add    %edx,%eax
80101b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b62:	0f b7 10             	movzwl (%eax),%edx
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b73:	8b 45 08             	mov    0x8(%ebp),%eax
80101b76:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b99:	8b 50 08             	mov    0x8(%eax),%edx
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	8d 50 0c             	lea    0xc(%eax),%edx
80101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bab:	83 c0 5c             	add    $0x5c,%eax
80101bae:	83 ec 04             	sub    $0x4,%esp
80101bb1:	6a 34                	push   $0x34
80101bb3:	52                   	push   %edx
80101bb4:	50                   	push   %eax
80101bb5:	e8 37 32 00 00       	call   80104df1 <memmove>
80101bba:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bbd:	83 ec 0c             	sub    $0xc,%esp
80101bc0:	ff 75 f4             	push   -0xc(%ebp)
80101bc3:	e8 cb e6 ff ff       	call   80100293 <brelse>
80101bc8:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101bdc:	66 85 c0             	test   %ax,%ax
80101bdf:	75 0d                	jne    80101bee <ilock+0x114>
      panic("ilock: no type");
80101be1:	83 ec 0c             	sub    $0xc,%esp
80101be4:	68 5f a9 10 80       	push   $0x8010a95f
80101be9:	e8 f0 e9 ff ff       	call   801005de <panic>
  }
}
80101bee:	90                   	nop
80101bef:	c9                   	leave
80101bf0:	c3                   	ret

80101bf1 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bf1:	f3 0f 1e fb          	endbr32
80101bf5:	55                   	push   %ebp
80101bf6:	89 e5                	mov    %esp,%ebp
80101bf8:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bfb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bff:	74 20                	je     80101c21 <iunlock+0x30>
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	83 c0 0c             	add    $0xc,%eax
80101c07:	83 ec 0c             	sub    $0xc,%esp
80101c0a:	50                   	push   %eax
80101c0b:	e8 f2 2d 00 00       	call   80104a02 <holdingsleep>
80101c10:	83 c4 10             	add    $0x10,%esp
80101c13:	85 c0                	test   %eax,%eax
80101c15:	74 0a                	je     80101c21 <iunlock+0x30>
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	8b 40 08             	mov    0x8(%eax),%eax
80101c1d:	85 c0                	test   %eax,%eax
80101c1f:	7f 0d                	jg     80101c2e <iunlock+0x3d>
    panic("iunlock");
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	68 6e a9 10 80       	push   $0x8010a96e
80101c29:	e8 b0 e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	83 c0 0c             	add    $0xc,%eax
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	50                   	push   %eax
80101c38:	e8 73 2d 00 00       	call   801049b0 <releasesleep>
80101c3d:	83 c4 10             	add    $0x10,%esp
}
80101c40:	90                   	nop
80101c41:	c9                   	leave
80101c42:	c3                   	ret

80101c43 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c43:	f3 0f 1e fb          	endbr32
80101c47:	55                   	push   %ebp
80101c48:	89 e5                	mov    %esp,%ebp
80101c4a:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	83 c0 0c             	add    $0xc,%eax
80101c53:	83 ec 0c             	sub    $0xc,%esp
80101c56:	50                   	push   %eax
80101c57:	e8 ec 2c 00 00       	call   80104948 <acquiresleep>
80101c5c:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c62:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c65:	85 c0                	test   %eax,%eax
80101c67:	74 6a                	je     80101cd3 <iput+0x90>
80101c69:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c70:	66 85 c0             	test   %ax,%ax
80101c73:	75 5e                	jne    80101cd3 <iput+0x90>
    acquire(&icache.lock);
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	68 80 37 19 80       	push   $0x80193780
80101c7d:	e8 19 2e 00 00       	call   80104a9b <acquire>
80101c82:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	8b 40 08             	mov    0x8(%eax),%eax
80101c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c8e:	83 ec 0c             	sub    $0xc,%esp
80101c91:	68 80 37 19 80       	push   $0x80193780
80101c96:	e8 72 2e 00 00       	call   80104b0d <release>
80101c9b:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c9e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ca2:	75 2f                	jne    80101cd3 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	ff 75 08             	push   0x8(%ebp)
80101caa:	e8 b5 01 00 00       	call   80101e64 <itrunc>
80101caf:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	ff 75 08             	push   0x8(%ebp)
80101cc1:	e8 2b fc ff ff       	call   801018f1 <iupdate>
80101cc6:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccc:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd6:	83 c0 0c             	add    $0xc,%eax
80101cd9:	83 ec 0c             	sub    $0xc,%esp
80101cdc:	50                   	push   %eax
80101cdd:	e8 ce 2c 00 00       	call   801049b0 <releasesleep>
80101ce2:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101ce5:	83 ec 0c             	sub    $0xc,%esp
80101ce8:	68 80 37 19 80       	push   $0x80193780
80101ced:	e8 a9 2d 00 00       	call   80104a9b <acquire>
80101cf2:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf8:	8b 40 08             	mov    0x8(%eax),%eax
80101cfb:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d04:	83 ec 0c             	sub    $0xc,%esp
80101d07:	68 80 37 19 80       	push   $0x80193780
80101d0c:	e8 fc 2d 00 00       	call   80104b0d <release>
80101d11:	83 c4 10             	add    $0x10,%esp
}
80101d14:	90                   	nop
80101d15:	c9                   	leave
80101d16:	c3                   	ret

80101d17 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d17:	f3 0f 1e fb          	endbr32
80101d1b:	55                   	push   %ebp
80101d1c:	89 e5                	mov    %esp,%ebp
80101d1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	ff 75 08             	push   0x8(%ebp)
80101d27:	e8 c5 fe ff ff       	call   80101bf1 <iunlock>
80101d2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d2f:	83 ec 0c             	sub    $0xc,%esp
80101d32:	ff 75 08             	push   0x8(%ebp)
80101d35:	e8 09 ff ff ff       	call   80101c43 <iput>
80101d3a:	83 c4 10             	add    $0x10,%esp
}
80101d3d:	90                   	nop
80101d3e:	c9                   	leave
80101d3f:	c3                   	ret

80101d40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d40:	f3 0f 1e fb          	endbr32
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d4a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d4e:	77 42                	ja     80101d92 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d56:	83 c2 14             	add    $0x14,%edx
80101d59:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d64:	75 24                	jne    80101d8a <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	8b 00                	mov    (%eax),%eax
80101d6b:	83 ec 0c             	sub    $0xc,%esp
80101d6e:	50                   	push   %eax
80101d6f:	e8 b4 f7 ff ff       	call   80101528 <balloc>
80101d74:	83 c4 10             	add    $0x10,%esp
80101d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d80:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8d:	e9 d0 00 00 00       	jmp    80101e62 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d92:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d96:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d9a:	0f 87 b5 00 00 00    	ja     80101e55 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101da9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101db0:	75 20                	jne    80101dd2 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 00                	mov    (%eax),%eax
80101db7:	83 ec 0c             	sub    $0xc,%esp
80101dba:	50                   	push   %eax
80101dbb:	e8 68 f7 ff ff       	call   80101528 <balloc>
80101dc0:	83 c4 10             	add    $0x10,%esp
80101dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcc:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 00                	mov    (%eax),%eax
80101dd7:	83 ec 08             	sub    $0x8,%esp
80101dda:	ff 75 f4             	push   -0xc(%ebp)
80101ddd:	50                   	push   %eax
80101dde:	e8 26 e4 ff ff       	call   80100209 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101df5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dff:	01 d0                	add    %edx,%eax
80101e01:	8b 00                	mov    (%eax),%eax
80101e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e0a:	75 36                	jne    80101e42 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0f:	8b 00                	mov    (%eax),%eax
80101e11:	83 ec 0c             	sub    $0xc,%esp
80101e14:	50                   	push   %eax
80101e15:	e8 0e f7 ff ff       	call   80101528 <balloc>
80101e1a:	83 c4 10             	add    $0x10,%esp
80101e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e2d:	01 c2                	add    %eax,%edx
80101e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e32:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e34:	83 ec 0c             	sub    $0xc,%esp
80101e37:	ff 75 f0             	push   -0x10(%ebp)
80101e3a:	e8 d9 15 00 00       	call   80103418 <log_write>
80101e3f:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e42:	83 ec 0c             	sub    $0xc,%esp
80101e45:	ff 75 f0             	push   -0x10(%ebp)
80101e48:	e8 46 e4 ff ff       	call   80100293 <brelse>
80101e4d:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e53:	eb 0d                	jmp    80101e62 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 76 a9 10 80       	push   $0x8010a976
80101e5d:	e8 7c e7 ff ff       	call   801005de <panic>
}
80101e62:	c9                   	leave
80101e63:	c3                   	ret

80101e64 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e64:	f3 0f 1e fb          	endbr32
80101e68:	55                   	push   %ebp
80101e69:	89 e5                	mov    %esp,%ebp
80101e6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e75:	eb 45                	jmp    80101ebc <itrunc+0x58>
    if(ip->addrs[i]){
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7d:	83 c2 14             	add    $0x14,%edx
80101e80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e84:	85 c0                	test   %eax,%eax
80101e86:	74 30                	je     80101eb8 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e8e:	83 c2 14             	add    $0x14,%edx
80101e91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e95:	8b 55 08             	mov    0x8(%ebp),%edx
80101e98:	8b 12                	mov    (%edx),%edx
80101e9a:	83 ec 08             	sub    $0x8,%esp
80101e9d:	50                   	push   %eax
80101e9e:	52                   	push   %edx
80101e9f:	e8 d4 f7 ff ff       	call   80101678 <bfree>
80101ea4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ead:	83 c2 14             	add    $0x14,%edx
80101eb0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101eb7:	00 
  for(i = 0; i < NDIRECT; i++){
80101eb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ebc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ec0:	7e b5                	jle    80101e77 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ecb:	85 c0                	test   %eax,%eax
80101ecd:	0f 84 aa 00 00 00    	je     80101f7d <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	8b 00                	mov    (%eax),%eax
80101ee1:	83 ec 08             	sub    $0x8,%esp
80101ee4:	52                   	push   %edx
80101ee5:	50                   	push   %eax
80101ee6:	e8 1e e3 ff ff       	call   80100209 <bread>
80101eeb:	83 c4 10             	add    $0x10,%esp
80101eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef4:	83 c0 5c             	add    $0x5c,%eax
80101ef7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101efa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f01:	eb 3c                	jmp    80101f3f <itrunc+0xdb>
      if(a[j])
80101f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f10:	01 d0                	add    %edx,%eax
80101f12:	8b 00                	mov    (%eax),%eax
80101f14:	85 c0                	test   %eax,%eax
80101f16:	74 23                	je     80101f3b <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f25:	01 d0                	add    %edx,%eax
80101f27:	8b 00                	mov    (%eax),%eax
80101f29:	8b 55 08             	mov    0x8(%ebp),%edx
80101f2c:	8b 12                	mov    (%edx),%edx
80101f2e:	83 ec 08             	sub    $0x8,%esp
80101f31:	50                   	push   %eax
80101f32:	52                   	push   %edx
80101f33:	e8 40 f7 ff ff       	call   80101678 <bfree>
80101f38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f42:	83 f8 7f             	cmp    $0x7f,%eax
80101f45:	76 bc                	jbe    80101f03 <itrunc+0x9f>
    }
    brelse(bp);
80101f47:	83 ec 0c             	sub    $0xc,%esp
80101f4a:	ff 75 ec             	push   -0x14(%ebp)
80101f4d:	e8 41 e3 ff ff       	call   80100293 <brelse>
80101f52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f61:	8b 12                	mov    (%edx),%edx
80101f63:	83 ec 08             	sub    $0x8,%esp
80101f66:	50                   	push   %eax
80101f67:	52                   	push   %edx
80101f68:	e8 0b f7 ff ff       	call   80101678 <bfree>
80101f6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f7a:	00 00 00 
  }

  ip->size = 0;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f87:	83 ec 0c             	sub    $0xc,%esp
80101f8a:	ff 75 08             	push   0x8(%ebp)
80101f8d:	e8 5f f9 ff ff       	call   801018f1 <iupdate>
80101f92:	83 c4 10             	add    $0x10,%esp
}
80101f95:	90                   	nop
80101f96:	c9                   	leave
80101f97:	c3                   	ret

80101f98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f98:	f3 0f 1e fb          	endbr32
80101f9c:	55                   	push   %ebp
80101f9d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	8b 00                	mov    (%eax),%eax
80101fa4:	89 c2                	mov    %eax,%edx
80101fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fa9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fac:	8b 45 08             	mov    0x8(%ebp),%eax
80101faf:	8b 50 04             	mov    0x4(%eax),%edx
80101fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbb:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc8:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fcf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd6:	8b 50 58             	mov    0x58(%eax),%edx
80101fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fdc:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fdf:	90                   	nop
80101fe0:	5d                   	pop    %ebp
80101fe1:	c3                   	ret

80101fe2 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fe2:	f3 0f 1e fb          	endbr32
80101fe6:	55                   	push   %ebp
80101fe7:	89 e5                	mov    %esp,%ebp
80101fe9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fec:	8b 45 08             	mov    0x8(%ebp),%eax
80101fef:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ff3:	66 83 f8 03          	cmp    $0x3,%ax
80101ff7:	75 5c                	jne    80102055 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102000:	66 85 c0             	test   %ax,%ax
80102003:	78 20                	js     80102025 <readi+0x43>
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010200c:	66 83 f8 09          	cmp    $0x9,%ax
80102010:	7f 13                	jg     80102025 <readi+0x43>
80102012:	8b 45 08             	mov    0x8(%ebp),%eax
80102015:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102019:	98                   	cwtl
8010201a:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102021:	85 c0                	test   %eax,%eax
80102023:	75 0a                	jne    8010202f <readi+0x4d>
      return -1;
80102025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010202a:	e9 0a 01 00 00       	jmp    80102139 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010202f:	8b 45 08             	mov    0x8(%ebp),%eax
80102032:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102036:	98                   	cwtl
80102037:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
8010203e:	8b 55 14             	mov    0x14(%ebp),%edx
80102041:	83 ec 04             	sub    $0x4,%esp
80102044:	52                   	push   %edx
80102045:	ff 75 0c             	push   0xc(%ebp)
80102048:	ff 75 08             	push   0x8(%ebp)
8010204b:	ff d0                	call   *%eax
8010204d:	83 c4 10             	add    $0x10,%esp
80102050:	e9 e4 00 00 00       	jmp    80102139 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102055:	8b 45 08             	mov    0x8(%ebp),%eax
80102058:	8b 40 58             	mov    0x58(%eax),%eax
8010205b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010205e:	77 0d                	ja     8010206d <readi+0x8b>
80102060:	8b 55 10             	mov    0x10(%ebp),%edx
80102063:	8b 45 14             	mov    0x14(%ebp),%eax
80102066:	01 d0                	add    %edx,%eax
80102068:	39 45 10             	cmp    %eax,0x10(%ebp)
8010206b:	76 0a                	jbe    80102077 <readi+0x95>
    return -1;
8010206d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102072:	e9 c2 00 00 00       	jmp    80102139 <readi+0x157>
  if(off + n > ip->size)
80102077:	8b 55 10             	mov    0x10(%ebp),%edx
8010207a:	8b 45 14             	mov    0x14(%ebp),%eax
8010207d:	01 c2                	add    %eax,%edx
8010207f:	8b 45 08             	mov    0x8(%ebp),%eax
80102082:	8b 40 58             	mov    0x58(%eax),%eax
80102085:	39 c2                	cmp    %eax,%edx
80102087:	76 0c                	jbe    80102095 <readi+0xb3>
    n = ip->size - off;
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	8b 40 58             	mov    0x58(%eax),%eax
8010208f:	2b 45 10             	sub    0x10(%ebp),%eax
80102092:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102095:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209c:	e9 89 00 00 00       	jmp    8010212a <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020a1:	8b 45 10             	mov    0x10(%ebp),%eax
801020a4:	c1 e8 09             	shr    $0x9,%eax
801020a7:	83 ec 08             	sub    $0x8,%esp
801020aa:	50                   	push   %eax
801020ab:	ff 75 08             	push   0x8(%ebp)
801020ae:	e8 8d fc ff ff       	call   80101d40 <bmap>
801020b3:	83 c4 10             	add    $0x10,%esp
801020b6:	8b 55 08             	mov    0x8(%ebp),%edx
801020b9:	8b 12                	mov    (%edx),%edx
801020bb:	83 ec 08             	sub    $0x8,%esp
801020be:	50                   	push   %eax
801020bf:	52                   	push   %edx
801020c0:	e8 44 e1 ff ff       	call   80100209 <bread>
801020c5:	83 c4 10             	add    $0x10,%esp
801020c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	ba 00 02 00 00       	mov    $0x200,%edx
801020d8:	29 c2                	sub    %eax,%edx
801020da:	8b 45 14             	mov    0x14(%ebp),%eax
801020dd:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020e0:	39 c2                	cmp    %eax,%edx
801020e2:	0f 46 c2             	cmovbe %edx,%eax
801020e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801020ee:	8b 45 10             	mov    0x10(%ebp),%eax
801020f1:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f6:	01 d0                	add    %edx,%eax
801020f8:	83 ec 04             	sub    $0x4,%esp
801020fb:	ff 75 ec             	push   -0x14(%ebp)
801020fe:	50                   	push   %eax
801020ff:	ff 75 0c             	push   0xc(%ebp)
80102102:	e8 ea 2c 00 00       	call   80104df1 <memmove>
80102107:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010210a:	83 ec 0c             	sub    $0xc,%esp
8010210d:	ff 75 f0             	push   -0x10(%ebp)
80102110:	e8 7e e1 ff ff       	call   80100293 <brelse>
80102115:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102118:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010211e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102121:	01 45 10             	add    %eax,0x10(%ebp)
80102124:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102127:	01 45 0c             	add    %eax,0xc(%ebp)
8010212a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010212d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102130:	0f 82 6b ff ff ff    	jb     801020a1 <readi+0xbf>
  }
  return n;
80102136:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102139:	c9                   	leave
8010213a:	c3                   	ret

8010213b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010213b:	f3 0f 1e fb          	endbr32
8010213f:	55                   	push   %ebp
80102140:	89 e5                	mov    %esp,%ebp
80102142:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102145:	8b 45 08             	mov    0x8(%ebp),%eax
80102148:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010214c:	66 83 f8 03          	cmp    $0x3,%ax
80102150:	75 5c                	jne    801021ae <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102152:	8b 45 08             	mov    0x8(%ebp),%eax
80102155:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102159:	66 85 c0             	test   %ax,%ax
8010215c:	78 20                	js     8010217e <writei+0x43>
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102165:	66 83 f8 09          	cmp    $0x9,%ax
80102169:	7f 13                	jg     8010217e <writei+0x43>
8010216b:	8b 45 08             	mov    0x8(%ebp),%eax
8010216e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102172:	98                   	cwtl
80102173:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010217a:	85 c0                	test   %eax,%eax
8010217c:	75 0a                	jne    80102188 <writei+0x4d>
      return -1;
8010217e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102183:	e9 3b 01 00 00       	jmp    801022c3 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102188:	8b 45 08             	mov    0x8(%ebp),%eax
8010218b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010218f:	98                   	cwtl
80102190:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102197:	8b 55 14             	mov    0x14(%ebp),%edx
8010219a:	83 ec 04             	sub    $0x4,%esp
8010219d:	52                   	push   %edx
8010219e:	ff 75 0c             	push   0xc(%ebp)
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	ff d0                	call   *%eax
801021a6:	83 c4 10             	add    $0x10,%esp
801021a9:	e9 15 01 00 00       	jmp    801022c3 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021ae:	8b 45 08             	mov    0x8(%ebp),%eax
801021b1:	8b 40 58             	mov    0x58(%eax),%eax
801021b4:	39 45 10             	cmp    %eax,0x10(%ebp)
801021b7:	77 0d                	ja     801021c6 <writei+0x8b>
801021b9:	8b 55 10             	mov    0x10(%ebp),%edx
801021bc:	8b 45 14             	mov    0x14(%ebp),%eax
801021bf:	01 d0                	add    %edx,%eax
801021c1:	39 45 10             	cmp    %eax,0x10(%ebp)
801021c4:	76 0a                	jbe    801021d0 <writei+0x95>
    return -1;
801021c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021cb:	e9 f3 00 00 00       	jmp    801022c3 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021d0:	8b 55 10             	mov    0x10(%ebp),%edx
801021d3:	8b 45 14             	mov    0x14(%ebp),%eax
801021d6:	01 d0                	add    %edx,%eax
801021d8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021dd:	76 0a                	jbe    801021e9 <writei+0xae>
    return -1;
801021df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021e4:	e9 da 00 00 00       	jmp    801022c3 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f0:	e9 97 00 00 00       	jmp    8010228c <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021f5:	8b 45 10             	mov    0x10(%ebp),%eax
801021f8:	c1 e8 09             	shr    $0x9,%eax
801021fb:	83 ec 08             	sub    $0x8,%esp
801021fe:	50                   	push   %eax
801021ff:	ff 75 08             	push   0x8(%ebp)
80102202:	e8 39 fb ff ff       	call   80101d40 <bmap>
80102207:	83 c4 10             	add    $0x10,%esp
8010220a:	8b 55 08             	mov    0x8(%ebp),%edx
8010220d:	8b 12                	mov    (%edx),%edx
8010220f:	83 ec 08             	sub    $0x8,%esp
80102212:	50                   	push   %eax
80102213:	52                   	push   %edx
80102214:	e8 f0 df ff ff       	call   80100209 <bread>
80102219:	83 c4 10             	add    $0x10,%esp
8010221c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010221f:	8b 45 10             	mov    0x10(%ebp),%eax
80102222:	25 ff 01 00 00       	and    $0x1ff,%eax
80102227:	ba 00 02 00 00       	mov    $0x200,%edx
8010222c:	29 c2                	sub    %eax,%edx
8010222e:	8b 45 14             	mov    0x14(%ebp),%eax
80102231:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102234:	39 c2                	cmp    %eax,%edx
80102236:	0f 46 c2             	cmovbe %edx,%eax
80102239:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010223c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010223f:	8d 50 5c             	lea    0x5c(%eax),%edx
80102242:	8b 45 10             	mov    0x10(%ebp),%eax
80102245:	25 ff 01 00 00       	and    $0x1ff,%eax
8010224a:	01 d0                	add    %edx,%eax
8010224c:	83 ec 04             	sub    $0x4,%esp
8010224f:	ff 75 ec             	push   -0x14(%ebp)
80102252:	ff 75 0c             	push   0xc(%ebp)
80102255:	50                   	push   %eax
80102256:	e8 96 2b 00 00       	call   80104df1 <memmove>
8010225b:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010225e:	83 ec 0c             	sub    $0xc,%esp
80102261:	ff 75 f0             	push   -0x10(%ebp)
80102264:	e8 af 11 00 00       	call   80103418 <log_write>
80102269:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010226c:	83 ec 0c             	sub    $0xc,%esp
8010226f:	ff 75 f0             	push   -0x10(%ebp)
80102272:	e8 1c e0 ff ff       	call   80100293 <brelse>
80102277:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010227a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102280:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102283:	01 45 10             	add    %eax,0x10(%ebp)
80102286:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102289:	01 45 0c             	add    %eax,0xc(%ebp)
8010228c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102292:	0f 82 5d ff ff ff    	jb     801021f5 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102298:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010229c:	74 22                	je     801022c0 <writei+0x185>
8010229e:	8b 45 08             	mov    0x8(%ebp),%eax
801022a1:	8b 40 58             	mov    0x58(%eax),%eax
801022a4:	39 45 10             	cmp    %eax,0x10(%ebp)
801022a7:	76 17                	jbe    801022c0 <writei+0x185>
    ip->size = off;
801022a9:	8b 45 08             	mov    0x8(%ebp),%eax
801022ac:	8b 55 10             	mov    0x10(%ebp),%edx
801022af:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022b2:	83 ec 0c             	sub    $0xc,%esp
801022b5:	ff 75 08             	push   0x8(%ebp)
801022b8:	e8 34 f6 ff ff       	call   801018f1 <iupdate>
801022bd:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022c0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022c3:	c9                   	leave
801022c4:	c3                   	ret

801022c5 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022c5:	f3 0f 1e fb          	endbr32
801022c9:	55                   	push   %ebp
801022ca:	89 e5                	mov    %esp,%ebp
801022cc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022cf:	83 ec 04             	sub    $0x4,%esp
801022d2:	6a 0e                	push   $0xe
801022d4:	ff 75 0c             	push   0xc(%ebp)
801022d7:	ff 75 08             	push   0x8(%ebp)
801022da:	e8 b0 2b 00 00       	call   80104e8f <strncmp>
801022df:	83 c4 10             	add    $0x10,%esp
}
801022e2:	c9                   	leave
801022e3:	c3                   	ret

801022e4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022e4:	f3 0f 1e fb          	endbr32
801022e8:	55                   	push   %ebp
801022e9:	89 e5                	mov    %esp,%ebp
801022eb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022ee:	8b 45 08             	mov    0x8(%ebp),%eax
801022f1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022f5:	66 83 f8 01          	cmp    $0x1,%ax
801022f9:	74 0d                	je     80102308 <dirlookup+0x24>
    panic("dirlookup not DIR");
801022fb:	83 ec 0c             	sub    $0xc,%esp
801022fe:	68 89 a9 10 80       	push   $0x8010a989
80102303:	e8 d6 e2 ff ff       	call   801005de <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102308:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010230f:	eb 7b                	jmp    8010238c <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102311:	6a 10                	push   $0x10
80102313:	ff 75 f4             	push   -0xc(%ebp)
80102316:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102319:	50                   	push   %eax
8010231a:	ff 75 08             	push   0x8(%ebp)
8010231d:	e8 c0 fc ff ff       	call   80101fe2 <readi>
80102322:	83 c4 10             	add    $0x10,%esp
80102325:	83 f8 10             	cmp    $0x10,%eax
80102328:	74 0d                	je     80102337 <dirlookup+0x53>
      panic("dirlookup read");
8010232a:	83 ec 0c             	sub    $0xc,%esp
8010232d:	68 9b a9 10 80       	push   $0x8010a99b
80102332:	e8 a7 e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102337:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010233b:	66 85 c0             	test   %ax,%ax
8010233e:	74 47                	je     80102387 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102340:	83 ec 08             	sub    $0x8,%esp
80102343:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102346:	83 c0 02             	add    $0x2,%eax
80102349:	50                   	push   %eax
8010234a:	ff 75 0c             	push   0xc(%ebp)
8010234d:	e8 73 ff ff ff       	call   801022c5 <namecmp>
80102352:	83 c4 10             	add    $0x10,%esp
80102355:	85 c0                	test   %eax,%eax
80102357:	75 2f                	jne    80102388 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102359:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010235d:	74 08                	je     80102367 <dirlookup+0x83>
        *poff = off;
8010235f:	8b 45 10             	mov    0x10(%ebp),%eax
80102362:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102365:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102367:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010236b:	0f b7 c0             	movzwl %ax,%eax
8010236e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102371:	8b 45 08             	mov    0x8(%ebp),%eax
80102374:	8b 00                	mov    (%eax),%eax
80102376:	83 ec 08             	sub    $0x8,%esp
80102379:	ff 75 f0             	push   -0x10(%ebp)
8010237c:	50                   	push   %eax
8010237d:	e8 34 f6 ff ff       	call   801019b6 <iget>
80102382:	83 c4 10             	add    $0x10,%esp
80102385:	eb 19                	jmp    801023a0 <dirlookup+0xbc>
      continue;
80102387:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102388:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010238c:	8b 45 08             	mov    0x8(%ebp),%eax
8010238f:	8b 40 58             	mov    0x58(%eax),%eax
80102392:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102395:	0f 82 76 ff ff ff    	jb     80102311 <dirlookup+0x2d>
    }
  }

  return 0;
8010239b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023a0:	c9                   	leave
801023a1:	c3                   	ret

801023a2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023a2:	f3 0f 1e fb          	endbr32
801023a6:	55                   	push   %ebp
801023a7:	89 e5                	mov    %esp,%ebp
801023a9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023ac:	83 ec 04             	sub    $0x4,%esp
801023af:	6a 00                	push   $0x0
801023b1:	ff 75 0c             	push   0xc(%ebp)
801023b4:	ff 75 08             	push   0x8(%ebp)
801023b7:	e8 28 ff ff ff       	call   801022e4 <dirlookup>
801023bc:	83 c4 10             	add    $0x10,%esp
801023bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023c6:	74 18                	je     801023e0 <dirlink+0x3e>
    iput(ip);
801023c8:	83 ec 0c             	sub    $0xc,%esp
801023cb:	ff 75 f0             	push   -0x10(%ebp)
801023ce:	e8 70 f8 ff ff       	call   80101c43 <iput>
801023d3:	83 c4 10             	add    $0x10,%esp
    return -1;
801023d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023db:	e9 9c 00 00 00       	jmp    8010247c <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023e7:	eb 39                	jmp    80102422 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ec:	6a 10                	push   $0x10
801023ee:	50                   	push   %eax
801023ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f2:	50                   	push   %eax
801023f3:	ff 75 08             	push   0x8(%ebp)
801023f6:	e8 e7 fb ff ff       	call   80101fe2 <readi>
801023fb:	83 c4 10             	add    $0x10,%esp
801023fe:	83 f8 10             	cmp    $0x10,%eax
80102401:	74 0d                	je     80102410 <dirlink+0x6e>
      panic("dirlink read");
80102403:	83 ec 0c             	sub    $0xc,%esp
80102406:	68 aa a9 10 80       	push   $0x8010a9aa
8010240b:	e8 ce e1 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102410:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102414:	66 85 c0             	test   %ax,%ax
80102417:	74 18                	je     80102431 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241c:	83 c0 10             	add    $0x10,%eax
8010241f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102422:	8b 45 08             	mov    0x8(%ebp),%eax
80102425:	8b 50 58             	mov    0x58(%eax),%edx
80102428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242b:	39 c2                	cmp    %eax,%edx
8010242d:	77 ba                	ja     801023e9 <dirlink+0x47>
8010242f:	eb 01                	jmp    80102432 <dirlink+0x90>
      break;
80102431:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102432:	83 ec 04             	sub    $0x4,%esp
80102435:	6a 0e                	push   $0xe
80102437:	ff 75 0c             	push   0xc(%ebp)
8010243a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010243d:	83 c0 02             	add    $0x2,%eax
80102440:	50                   	push   %eax
80102441:	e8 a3 2a 00 00       	call   80104ee9 <strncpy>
80102446:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102449:	8b 45 10             	mov    0x10(%ebp),%eax
8010244c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	6a 10                	push   $0x10
80102455:	50                   	push   %eax
80102456:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102459:	50                   	push   %eax
8010245a:	ff 75 08             	push   0x8(%ebp)
8010245d:	e8 d9 fc ff ff       	call   8010213b <writei>
80102462:	83 c4 10             	add    $0x10,%esp
80102465:	83 f8 10             	cmp    $0x10,%eax
80102468:	74 0d                	je     80102477 <dirlink+0xd5>
    panic("dirlink");
8010246a:	83 ec 0c             	sub    $0xc,%esp
8010246d:	68 b7 a9 10 80       	push   $0x8010a9b7
80102472:	e8 67 e1 ff ff       	call   801005de <panic>

  return 0;
80102477:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010247c:	c9                   	leave
8010247d:	c3                   	ret

8010247e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010247e:	f3 0f 1e fb          	endbr32
80102482:	55                   	push   %ebp
80102483:	89 e5                	mov    %esp,%ebp
80102485:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102488:	eb 04                	jmp    8010248e <skipelem+0x10>
    path++;
8010248a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010248e:	8b 45 08             	mov    0x8(%ebp),%eax
80102491:	0f b6 00             	movzbl (%eax),%eax
80102494:	3c 2f                	cmp    $0x2f,%al
80102496:	74 f2                	je     8010248a <skipelem+0xc>
  if(*path == 0)
80102498:	8b 45 08             	mov    0x8(%ebp),%eax
8010249b:	0f b6 00             	movzbl (%eax),%eax
8010249e:	84 c0                	test   %al,%al
801024a0:	75 07                	jne    801024a9 <skipelem+0x2b>
    return 0;
801024a2:	b8 00 00 00 00       	mov    $0x0,%eax
801024a7:	eb 77                	jmp    80102520 <skipelem+0xa2>
  s = path;
801024a9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024af:	eb 04                	jmp    801024b5 <skipelem+0x37>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 0a                	je     801024c9 <skipelem+0x4b>
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
801024c2:	0f b6 00             	movzbl (%eax),%eax
801024c5:	84 c0                	test   %al,%al
801024c7:	75 e8                	jne    801024b1 <skipelem+0x33>
  len = path - s;
801024c9:	8b 45 08             	mov    0x8(%ebp),%eax
801024cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024d6:	7e 15                	jle    801024ed <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024d8:	83 ec 04             	sub    $0x4,%esp
801024db:	6a 0e                	push   $0xe
801024dd:	ff 75 f4             	push   -0xc(%ebp)
801024e0:	ff 75 0c             	push   0xc(%ebp)
801024e3:	e8 09 29 00 00       	call   80104df1 <memmove>
801024e8:	83 c4 10             	add    $0x10,%esp
801024eb:	eb 26                	jmp    80102513 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f0:	83 ec 04             	sub    $0x4,%esp
801024f3:	50                   	push   %eax
801024f4:	ff 75 f4             	push   -0xc(%ebp)
801024f7:	ff 75 0c             	push   0xc(%ebp)
801024fa:	e8 f2 28 00 00       	call   80104df1 <memmove>
801024ff:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102502:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102505:	8b 45 0c             	mov    0xc(%ebp),%eax
80102508:	01 d0                	add    %edx,%eax
8010250a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010250d:	eb 04                	jmp    80102513 <skipelem+0x95>
    path++;
8010250f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102513:	8b 45 08             	mov    0x8(%ebp),%eax
80102516:	0f b6 00             	movzbl (%eax),%eax
80102519:	3c 2f                	cmp    $0x2f,%al
8010251b:	74 f2                	je     8010250f <skipelem+0x91>
  return path;
8010251d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102520:	c9                   	leave
80102521:	c3                   	ret

80102522 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102522:	f3 0f 1e fb          	endbr32
80102526:	55                   	push   %ebp
80102527:	89 e5                	mov    %esp,%ebp
80102529:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010252c:	8b 45 08             	mov    0x8(%ebp),%eax
8010252f:	0f b6 00             	movzbl (%eax),%eax
80102532:	3c 2f                	cmp    $0x2f,%al
80102534:	75 17                	jne    8010254d <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102536:	83 ec 08             	sub    $0x8,%esp
80102539:	6a 01                	push   $0x1
8010253b:	6a 01                	push   $0x1
8010253d:	e8 74 f4 ff ff       	call   801019b6 <iget>
80102542:	83 c4 10             	add    $0x10,%esp
80102545:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102548:	e9 ba 00 00 00       	jmp    80102607 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010254d:	e8 b5 16 00 00       	call   80103c07 <myproc>
80102552:	8b 40 68             	mov    0x68(%eax),%eax
80102555:	83 ec 0c             	sub    $0xc,%esp
80102558:	50                   	push   %eax
80102559:	e8 3e f5 ff ff       	call   80101a9c <idup>
8010255e:	83 c4 10             	add    $0x10,%esp
80102561:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102564:	e9 9e 00 00 00       	jmp    80102607 <namex+0xe5>
    ilock(ip);
80102569:	83 ec 0c             	sub    $0xc,%esp
8010256c:	ff 75 f4             	push   -0xc(%ebp)
8010256f:	e8 66 f5 ff ff       	call   80101ada <ilock>
80102574:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010257e:	66 83 f8 01          	cmp    $0x1,%ax
80102582:	74 18                	je     8010259c <namex+0x7a>
      iunlockput(ip);
80102584:	83 ec 0c             	sub    $0xc,%esp
80102587:	ff 75 f4             	push   -0xc(%ebp)
8010258a:	e8 88 f7 ff ff       	call   80101d17 <iunlockput>
8010258f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102592:	b8 00 00 00 00       	mov    $0x0,%eax
80102597:	e9 a7 00 00 00       	jmp    80102643 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010259c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025a0:	74 20                	je     801025c2 <namex+0xa0>
801025a2:	8b 45 08             	mov    0x8(%ebp),%eax
801025a5:	0f b6 00             	movzbl (%eax),%eax
801025a8:	84 c0                	test   %al,%al
801025aa:	75 16                	jne    801025c2 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025ac:	83 ec 0c             	sub    $0xc,%esp
801025af:	ff 75 f4             	push   -0xc(%ebp)
801025b2:	e8 3a f6 ff ff       	call   80101bf1 <iunlock>
801025b7:	83 c4 10             	add    $0x10,%esp
      return ip;
801025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025bd:	e9 81 00 00 00       	jmp    80102643 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025c2:	83 ec 04             	sub    $0x4,%esp
801025c5:	6a 00                	push   $0x0
801025c7:	ff 75 10             	push   0x10(%ebp)
801025ca:	ff 75 f4             	push   -0xc(%ebp)
801025cd:	e8 12 fd ff ff       	call   801022e4 <dirlookup>
801025d2:	83 c4 10             	add    $0x10,%esp
801025d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025dc:	75 15                	jne    801025f3 <namex+0xd1>
      iunlockput(ip);
801025de:	83 ec 0c             	sub    $0xc,%esp
801025e1:	ff 75 f4             	push   -0xc(%ebp)
801025e4:	e8 2e f7 ff ff       	call   80101d17 <iunlockput>
801025e9:	83 c4 10             	add    $0x10,%esp
      return 0;
801025ec:	b8 00 00 00 00       	mov    $0x0,%eax
801025f1:	eb 50                	jmp    80102643 <namex+0x121>
    }
    iunlockput(ip);
801025f3:	83 ec 0c             	sub    $0xc,%esp
801025f6:	ff 75 f4             	push   -0xc(%ebp)
801025f9:	e8 19 f7 ff ff       	call   80101d17 <iunlockput>
801025fe:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102604:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102607:	83 ec 08             	sub    $0x8,%esp
8010260a:	ff 75 10             	push   0x10(%ebp)
8010260d:	ff 75 08             	push   0x8(%ebp)
80102610:	e8 69 fe ff ff       	call   8010247e <skipelem>
80102615:	83 c4 10             	add    $0x10,%esp
80102618:	89 45 08             	mov    %eax,0x8(%ebp)
8010261b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010261f:	0f 85 44 ff ff ff    	jne    80102569 <namex+0x47>
  }
  if(nameiparent){
80102625:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102629:	74 15                	je     80102640 <namex+0x11e>
    iput(ip);
8010262b:	83 ec 0c             	sub    $0xc,%esp
8010262e:	ff 75 f4             	push   -0xc(%ebp)
80102631:	e8 0d f6 ff ff       	call   80101c43 <iput>
80102636:	83 c4 10             	add    $0x10,%esp
    return 0;
80102639:	b8 00 00 00 00       	mov    $0x0,%eax
8010263e:	eb 03                	jmp    80102643 <namex+0x121>
  }
  return ip;
80102640:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102643:	c9                   	leave
80102644:	c3                   	ret

80102645 <namei>:

struct inode*
namei(char *path)
{
80102645:	f3 0f 1e fb          	endbr32
80102649:	55                   	push   %ebp
8010264a:	89 e5                	mov    %esp,%ebp
8010264c:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010264f:	83 ec 04             	sub    $0x4,%esp
80102652:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102655:	50                   	push   %eax
80102656:	6a 00                	push   $0x0
80102658:	ff 75 08             	push   0x8(%ebp)
8010265b:	e8 c2 fe ff ff       	call   80102522 <namex>
80102660:	83 c4 10             	add    $0x10,%esp
}
80102663:	c9                   	leave
80102664:	c3                   	ret

80102665 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102665:	f3 0f 1e fb          	endbr32
80102669:	55                   	push   %ebp
8010266a:	89 e5                	mov    %esp,%ebp
8010266c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010266f:	83 ec 04             	sub    $0x4,%esp
80102672:	ff 75 0c             	push   0xc(%ebp)
80102675:	6a 01                	push   $0x1
80102677:	ff 75 08             	push   0x8(%ebp)
8010267a:	e8 a3 fe ff ff       	call   80102522 <namex>
8010267f:	83 c4 10             	add    $0x10,%esp
}
80102682:	c9                   	leave
80102683:	c3                   	ret

80102684 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102684:	f3 0f 1e fb          	endbr32
80102688:	55                   	push   %ebp
80102689:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010268b:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102690:	8b 55 08             	mov    0x8(%ebp),%edx
80102693:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102695:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010269a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010269d:	5d                   	pop    %ebp
8010269e:	c3                   	ret

8010269f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010269f:	f3 0f 1e fb          	endbr32
801026a3:	55                   	push   %ebp
801026a4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801026a6:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026ab:	8b 55 08             	mov    0x8(%ebp),%edx
801026ae:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801026b0:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801026b8:	89 50 10             	mov    %edx,0x10(%eax)
}
801026bb:	90                   	nop
801026bc:	5d                   	pop    %ebp
801026bd:	c3                   	ret

801026be <ioapicinit>:

void
ioapicinit(void)
{
801026be:	f3 0f 1e fb          	endbr32
801026c2:	55                   	push   %ebp
801026c3:	89 e5                	mov    %esp,%ebp
801026c5:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801026c8:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
801026cf:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801026d2:	6a 01                	push   $0x1
801026d4:	e8 ab ff ff ff       	call   80102684 <ioapicread>
801026d9:	83 c4 04             	add    $0x4,%esp
801026dc:	c1 e8 10             	shr    $0x10,%eax
801026df:	25 ff 00 00 00       	and    $0xff,%eax
801026e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801026e7:	6a 00                	push   $0x0
801026e9:	e8 96 ff ff ff       	call   80102684 <ioapicread>
801026ee:	83 c4 04             	add    $0x4,%esp
801026f1:	c1 e8 18             	shr    $0x18,%eax
801026f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801026f7:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026fe:	0f b6 c0             	movzbl %al,%eax
80102701:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102704:	74 10                	je     80102716 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102706:	83 ec 0c             	sub    $0xc,%esp
80102709:	68 c0 a9 10 80       	push   $0x8010a9c0
8010270e:	e8 f9 dc ff ff       	call   8010040c <cprintf>
80102713:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010271d:	eb 3f                	jmp    8010275e <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010271f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102722:	83 c0 20             	add    $0x20,%eax
80102725:	0d 00 00 01 00       	or     $0x10000,%eax
8010272a:	89 c2                	mov    %eax,%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	83 c0 08             	add    $0x8,%eax
80102732:	01 c0                	add    %eax,%eax
80102734:	83 ec 08             	sub    $0x8,%esp
80102737:	52                   	push   %edx
80102738:	50                   	push   %eax
80102739:	e8 61 ff ff ff       	call   8010269f <ioapicwrite>
8010273e:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102744:	83 c0 08             	add    $0x8,%eax
80102747:	01 c0                	add    %eax,%eax
80102749:	83 c0 01             	add    $0x1,%eax
8010274c:	83 ec 08             	sub    $0x8,%esp
8010274f:	6a 00                	push   $0x0
80102751:	50                   	push   %eax
80102752:	e8 48 ff ff ff       	call   8010269f <ioapicwrite>
80102757:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010275a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102764:	7e b9                	jle    8010271f <ioapicinit+0x61>
  }
}
80102766:	90                   	nop
80102767:	90                   	nop
80102768:	c9                   	leave
80102769:	c3                   	ret

8010276a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010276a:	f3 0f 1e fb          	endbr32
8010276e:	55                   	push   %ebp
8010276f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102771:	8b 45 08             	mov    0x8(%ebp),%eax
80102774:	83 c0 20             	add    $0x20,%eax
80102777:	89 c2                	mov    %eax,%edx
80102779:	8b 45 08             	mov    0x8(%ebp),%eax
8010277c:	83 c0 08             	add    $0x8,%eax
8010277f:	01 c0                	add    %eax,%eax
80102781:	52                   	push   %edx
80102782:	50                   	push   %eax
80102783:	e8 17 ff ff ff       	call   8010269f <ioapicwrite>
80102788:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010278b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010278e:	c1 e0 18             	shl    $0x18,%eax
80102791:	89 c2                	mov    %eax,%edx
80102793:	8b 45 08             	mov    0x8(%ebp),%eax
80102796:	83 c0 08             	add    $0x8,%eax
80102799:	01 c0                	add    %eax,%eax
8010279b:	83 c0 01             	add    $0x1,%eax
8010279e:	52                   	push   %edx
8010279f:	50                   	push   %eax
801027a0:	e8 fa fe ff ff       	call   8010269f <ioapicwrite>
801027a5:	83 c4 08             	add    $0x8,%esp
}
801027a8:	90                   	nop
801027a9:	c9                   	leave
801027aa:	c3                   	ret

801027ab <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801027ab:	f3 0f 1e fb          	endbr32
801027af:	55                   	push   %ebp
801027b0:	89 e5                	mov    %esp,%ebp
801027b2:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801027b5:	83 ec 08             	sub    $0x8,%esp
801027b8:	68 f2 a9 10 80       	push   $0x8010a9f2
801027bd:	68 e0 53 19 80       	push   $0x801953e0
801027c2:	e8 ae 22 00 00       	call   80104a75 <initlock>
801027c7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801027ca:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
801027d1:	00 00 00 
  freerange(vstart, vend);
801027d4:	83 ec 08             	sub    $0x8,%esp
801027d7:	ff 75 0c             	push   0xc(%ebp)
801027da:	ff 75 08             	push   0x8(%ebp)
801027dd:	e8 2e 00 00 00       	call   80102810 <freerange>
801027e2:	83 c4 10             	add    $0x10,%esp
}
801027e5:	90                   	nop
801027e6:	c9                   	leave
801027e7:	c3                   	ret

801027e8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801027e8:	f3 0f 1e fb          	endbr32
801027ec:	55                   	push   %ebp
801027ed:	89 e5                	mov    %esp,%ebp
801027ef:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801027f2:	83 ec 08             	sub    $0x8,%esp
801027f5:	ff 75 0c             	push   0xc(%ebp)
801027f8:	ff 75 08             	push   0x8(%ebp)
801027fb:	e8 10 00 00 00       	call   80102810 <freerange>
80102800:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102803:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
8010280a:	00 00 00 
}
8010280d:	90                   	nop
8010280e:	c9                   	leave
8010280f:	c3                   	ret

80102810 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102810:	f3 0f 1e fb          	endbr32
80102814:	55                   	push   %ebp
80102815:	89 e5                	mov    %esp,%ebp
80102817:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010281a:	8b 45 08             	mov    0x8(%ebp),%eax
8010281d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102822:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102827:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010282a:	eb 15                	jmp    80102841 <freerange+0x31>
    kfree(p);
8010282c:	83 ec 0c             	sub    $0xc,%esp
8010282f:	ff 75 f4             	push   -0xc(%ebp)
80102832:	e8 1b 00 00 00       	call   80102852 <kfree>
80102837:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010283a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102844:	05 00 10 00 00       	add    $0x1000,%eax
80102849:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010284c:	73 de                	jae    8010282c <freerange+0x1c>
}
8010284e:	90                   	nop
8010284f:	90                   	nop
80102850:	c9                   	leave
80102851:	c3                   	ret

80102852 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102852:	f3 0f 1e fb          	endbr32
80102856:	55                   	push   %ebp
80102857:	89 e5                	mov    %esp,%ebp
80102859:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010285c:	8b 45 08             	mov    0x8(%ebp),%eax
8010285f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102864:	85 c0                	test   %eax,%eax
80102866:	75 18                	jne    80102880 <kfree+0x2e>
80102868:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010286f:	72 0f                	jb     80102880 <kfree+0x2e>
80102871:	8b 45 08             	mov    0x8(%ebp),%eax
80102874:	05 00 00 00 80       	add    $0x80000000,%eax
80102879:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010287e:	76 0d                	jbe    8010288d <kfree+0x3b>
    panic("kfree");
80102880:	83 ec 0c             	sub    $0xc,%esp
80102883:	68 f7 a9 10 80       	push   $0x8010a9f7
80102888:	e8 51 dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010288d:	83 ec 04             	sub    $0x4,%esp
80102890:	68 00 10 00 00       	push   $0x1000
80102895:	6a 01                	push   $0x1
80102897:	ff 75 08             	push   0x8(%ebp)
8010289a:	e8 8b 24 00 00       	call   80104d2a <memset>
8010289f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801028a2:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a7:	85 c0                	test   %eax,%eax
801028a9:	74 10                	je     801028bb <kfree+0x69>
    acquire(&kmem.lock);
801028ab:	83 ec 0c             	sub    $0xc,%esp
801028ae:	68 e0 53 19 80       	push   $0x801953e0
801028b3:	e8 e3 21 00 00       	call   80104a9b <acquire>
801028b8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801028bb:	8b 45 08             	mov    0x8(%ebp),%eax
801028be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801028c1:	8b 15 18 54 19 80    	mov    0x80195418,%edx
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801028cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cf:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028d4:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d9:	85 c0                	test   %eax,%eax
801028db:	74 10                	je     801028ed <kfree+0x9b>
    release(&kmem.lock);
801028dd:	83 ec 0c             	sub    $0xc,%esp
801028e0:	68 e0 53 19 80       	push   $0x801953e0
801028e5:	e8 23 22 00 00       	call   80104b0d <release>
801028ea:	83 c4 10             	add    $0x10,%esp
}
801028ed:	90                   	nop
801028ee:	c9                   	leave
801028ef:	c3                   	ret

801028f0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028f0:	f3 0f 1e fb          	endbr32
801028f4:	55                   	push   %ebp
801028f5:	89 e5                	mov    %esp,%ebp
801028f7:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801028fa:	a1 14 54 19 80       	mov    0x80195414,%eax
801028ff:	85 c0                	test   %eax,%eax
80102901:	74 10                	je     80102913 <kalloc+0x23>
    acquire(&kmem.lock);
80102903:	83 ec 0c             	sub    $0xc,%esp
80102906:	68 e0 53 19 80       	push   $0x801953e0
8010290b:	e8 8b 21 00 00       	call   80104a9b <acquire>
80102910:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102913:	a1 18 54 19 80       	mov    0x80195418,%eax
80102918:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010291b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010291f:	74 0a                	je     8010292b <kalloc+0x3b>
    kmem.freelist = r->next;
80102921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102924:	8b 00                	mov    (%eax),%eax
80102926:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
8010292b:	a1 14 54 19 80       	mov    0x80195414,%eax
80102930:	85 c0                	test   %eax,%eax
80102932:	74 10                	je     80102944 <kalloc+0x54>
    release(&kmem.lock);
80102934:	83 ec 0c             	sub    $0xc,%esp
80102937:	68 e0 53 19 80       	push   $0x801953e0
8010293c:	e8 cc 21 00 00       	call   80104b0d <release>
80102941:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102944:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102947:	c9                   	leave
80102948:	c3                   	ret

80102949 <inb>:
{
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 14             	sub    $0x14,%esp
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102956:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010295a:	89 c2                	mov    %eax,%edx
8010295c:	ec                   	in     (%dx),%al
8010295d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102960:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102964:	c9                   	leave
80102965:	c3                   	ret

80102966 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102966:	f3 0f 1e fb          	endbr32
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102970:	6a 64                	push   $0x64
80102972:	e8 d2 ff ff ff       	call   80102949 <inb>
80102977:	83 c4 04             	add    $0x4,%esp
8010297a:	0f b6 c0             	movzbl %al,%eax
8010297d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102983:	83 e0 01             	and    $0x1,%eax
80102986:	85 c0                	test   %eax,%eax
80102988:	75 0a                	jne    80102994 <kbdgetc+0x2e>
    return -1;
8010298a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010298f:	e9 23 01 00 00       	jmp    80102ab7 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102994:	6a 60                	push   $0x60
80102996:	e8 ae ff ff ff       	call   80102949 <inb>
8010299b:	83 c4 04             	add    $0x4,%esp
8010299e:	0f b6 c0             	movzbl %al,%eax
801029a1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801029a4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801029ab:	75 17                	jne    801029c4 <kbdgetc+0x5e>
    shift |= E0ESC;
801029ad:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029b2:	83 c8 40             	or     $0x40,%eax
801029b5:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ba:	b8 00 00 00 00       	mov    $0x0,%eax
801029bf:	e9 f3 00 00 00       	jmp    80102ab7 <kbdgetc+0x151>
  } else if(data & 0x80){
801029c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029c7:	25 80 00 00 00       	and    $0x80,%eax
801029cc:	85 c0                	test   %eax,%eax
801029ce:	74 45                	je     80102a15 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029d0:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029d5:	83 e0 40             	and    $0x40,%eax
801029d8:	85 c0                	test   %eax,%eax
801029da:	75 08                	jne    801029e4 <kbdgetc+0x7e>
801029dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029df:	83 e0 7f             	and    $0x7f,%eax
801029e2:	eb 03                	jmp    801029e7 <kbdgetc+0x81>
801029e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801029ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029ed:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029f2:	0f b6 00             	movzbl (%eax),%eax
801029f5:	83 c8 40             	or     $0x40,%eax
801029f8:	0f b6 c0             	movzbl %al,%eax
801029fb:	f7 d0                	not    %eax
801029fd:	89 c2                	mov    %eax,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	21 d0                	and    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
80102a0b:	b8 00 00 00 00       	mov    $0x0,%eax
80102a10:	e9 a2 00 00 00       	jmp    80102ab7 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102a15:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a1a:	83 e0 40             	and    $0x40,%eax
80102a1d:	85 c0                	test   %eax,%eax
80102a1f:	74 14                	je     80102a35 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a21:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 bf             	and    $0xffffffbf,%eax
80102a30:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
80102a35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a38:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a3d:	0f b6 00             	movzbl (%eax),%eax
80102a40:	0f b6 d0             	movzbl %al,%edx
80102a43:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a48:	09 d0                	or     %edx,%eax
80102a4a:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a52:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a57:	0f b6 00             	movzbl (%eax),%eax
80102a5a:	0f b6 d0             	movzbl %al,%edx
80102a5d:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a62:	31 d0                	xor    %edx,%eax
80102a64:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a69:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a6e:	83 e0 03             	and    $0x3,%eax
80102a71:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a7b:	01 d0                	add    %edx,%eax
80102a7d:	0f b6 00             	movzbl (%eax),%eax
80102a80:	0f b6 c0             	movzbl %al,%eax
80102a83:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a86:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a8b:	83 e0 08             	and    $0x8,%eax
80102a8e:	85 c0                	test   %eax,%eax
80102a90:	74 22                	je     80102ab4 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a92:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a96:	76 0c                	jbe    80102aa4 <kbdgetc+0x13e>
80102a98:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a9c:	77 06                	ja     80102aa4 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a9e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102aa2:	eb 10                	jmp    80102ab4 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102aa4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102aa8:	76 0a                	jbe    80102ab4 <kbdgetc+0x14e>
80102aaa:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102aae:	77 04                	ja     80102ab4 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ab0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ab4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ab7:	c9                   	leave
80102ab8:	c3                   	ret

80102ab9 <kbdintr>:

void
kbdintr(void)
{
80102ab9:	f3 0f 1e fb          	endbr32
80102abd:	55                   	push   %ebp
80102abe:	89 e5                	mov    %esp,%ebp
80102ac0:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ac3:	83 ec 0c             	sub    $0xc,%esp
80102ac6:	68 66 29 10 80       	push   $0x80102966
80102acb:	e8 49 dd ff ff       	call   80100819 <consoleintr>
80102ad0:	83 c4 10             	add    $0x10,%esp
}
80102ad3:	90                   	nop
80102ad4:	c9                   	leave
80102ad5:	c3                   	ret

80102ad6 <inb>:
{
80102ad6:	55                   	push   %ebp
80102ad7:	89 e5                	mov    %esp,%ebp
80102ad9:	83 ec 14             	sub    $0x14,%esp
80102adc:	8b 45 08             	mov    0x8(%ebp),%eax
80102adf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ae3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ae7:	89 c2                	mov    %eax,%edx
80102ae9:	ec                   	in     (%dx),%al
80102aea:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102aed:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102af1:	c9                   	leave
80102af2:	c3                   	ret

80102af3 <outb>:
{
80102af3:	55                   	push   %ebp
80102af4:	89 e5                	mov    %esp,%ebp
80102af6:	83 ec 08             	sub    $0x8,%esp
80102af9:	8b 45 08             	mov    0x8(%ebp),%eax
80102afc:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102b03:	89 d0                	mov    %edx,%eax
80102b05:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b08:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102b0c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102b10:	ee                   	out    %al,(%dx)
}
80102b11:	90                   	nop
80102b12:	c9                   	leave
80102b13:	c3                   	ret

80102b14 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102b14:	f3 0f 1e fb          	endbr32
80102b18:	55                   	push   %ebp
80102b19:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102b1b:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b20:	8b 55 08             	mov    0x8(%ebp),%edx
80102b23:	c1 e2 02             	shl    $0x2,%edx
80102b26:	01 c2                	add    %eax,%edx
80102b28:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b2b:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102b2d:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b32:	83 c0 20             	add    $0x20,%eax
80102b35:	8b 00                	mov    (%eax),%eax
}
80102b37:	90                   	nop
80102b38:	5d                   	pop    %ebp
80102b39:	c3                   	ret

80102b3a <lapicinit>:

void
lapicinit(void)
{
80102b3a:	f3 0f 1e fb          	endbr32
80102b3e:	55                   	push   %ebp
80102b3f:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b41:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b46:	85 c0                	test   %eax,%eax
80102b48:	0f 84 0c 01 00 00    	je     80102c5a <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b4e:	68 3f 01 00 00       	push   $0x13f
80102b53:	6a 3c                	push   $0x3c
80102b55:	e8 ba ff ff ff       	call   80102b14 <lapicw>
80102b5a:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b5d:	6a 0b                	push   $0xb
80102b5f:	68 f8 00 00 00       	push   $0xf8
80102b64:	e8 ab ff ff ff       	call   80102b14 <lapicw>
80102b69:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b6c:	68 20 00 02 00       	push   $0x20020
80102b71:	68 c8 00 00 00       	push   $0xc8
80102b76:	e8 99 ff ff ff       	call   80102b14 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b7e:	68 80 96 98 00       	push   $0x989680
80102b83:	68 e0 00 00 00       	push   $0xe0
80102b88:	e8 87 ff ff ff       	call   80102b14 <lapicw>
80102b8d:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b90:	68 00 00 01 00       	push   $0x10000
80102b95:	68 d4 00 00 00       	push   $0xd4
80102b9a:	e8 75 ff ff ff       	call   80102b14 <lapicw>
80102b9f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102ba2:	68 00 00 01 00       	push   $0x10000
80102ba7:	68 d8 00 00 00       	push   $0xd8
80102bac:	e8 63 ff ff ff       	call   80102b14 <lapicw>
80102bb1:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102bb4:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bb9:	83 c0 30             	add    $0x30,%eax
80102bbc:	8b 00                	mov    (%eax),%eax
80102bbe:	c1 e8 10             	shr    $0x10,%eax
80102bc1:	25 fc 00 00 00       	and    $0xfc,%eax
80102bc6:	85 c0                	test   %eax,%eax
80102bc8:	74 12                	je     80102bdc <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102bca:	68 00 00 01 00       	push   $0x10000
80102bcf:	68 d0 00 00 00       	push   $0xd0
80102bd4:	e8 3b ff ff ff       	call   80102b14 <lapicw>
80102bd9:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102bdc:	6a 33                	push   $0x33
80102bde:	68 dc 00 00 00       	push   $0xdc
80102be3:	e8 2c ff ff ff       	call   80102b14 <lapicw>
80102be8:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102beb:	6a 00                	push   $0x0
80102bed:	68 a0 00 00 00       	push   $0xa0
80102bf2:	e8 1d ff ff ff       	call   80102b14 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102bfa:	6a 00                	push   $0x0
80102bfc:	68 a0 00 00 00       	push   $0xa0
80102c01:	e8 0e ff ff ff       	call   80102b14 <lapicw>
80102c06:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102c09:	6a 00                	push   $0x0
80102c0b:	6a 2c                	push   $0x2c
80102c0d:	e8 02 ff ff ff       	call   80102b14 <lapicw>
80102c12:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102c15:	6a 00                	push   $0x0
80102c17:	68 c4 00 00 00       	push   $0xc4
80102c1c:	e8 f3 fe ff ff       	call   80102b14 <lapicw>
80102c21:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102c24:	68 00 85 08 00       	push   $0x88500
80102c29:	68 c0 00 00 00       	push   $0xc0
80102c2e:	e8 e1 fe ff ff       	call   80102b14 <lapicw>
80102c33:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102c36:	90                   	nop
80102c37:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c3c:	05 00 03 00 00       	add    $0x300,%eax
80102c41:	8b 00                	mov    (%eax),%eax
80102c43:	25 00 10 00 00       	and    $0x1000,%eax
80102c48:	85 c0                	test   %eax,%eax
80102c4a:	75 eb                	jne    80102c37 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102c4c:	6a 00                	push   $0x0
80102c4e:	6a 20                	push   $0x20
80102c50:	e8 bf fe ff ff       	call   80102b14 <lapicw>
80102c55:	83 c4 08             	add    $0x8,%esp
80102c58:	eb 01                	jmp    80102c5b <lapicinit+0x121>
    return;
80102c5a:	90                   	nop
}
80102c5b:	c9                   	leave
80102c5c:	c3                   	ret

80102c5d <lapicid>:

int
lapicid(void)
{
80102c5d:	f3 0f 1e fb          	endbr32
80102c61:	55                   	push   %ebp
80102c62:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c64:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c69:	85 c0                	test   %eax,%eax
80102c6b:	75 07                	jne    80102c74 <lapicid+0x17>
    return 0;
80102c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80102c72:	eb 0d                	jmp    80102c81 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c74:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c79:	83 c0 20             	add    $0x20,%eax
80102c7c:	8b 00                	mov    (%eax),%eax
80102c7e:	c1 e8 18             	shr    $0x18,%eax
}
80102c81:	5d                   	pop    %ebp
80102c82:	c3                   	ret

80102c83 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c83:	f3 0f 1e fb          	endbr32
80102c87:	55                   	push   %ebp
80102c88:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c8a:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 0c                	je     80102c9f <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c93:	6a 00                	push   $0x0
80102c95:	6a 2c                	push   $0x2c
80102c97:	e8 78 fe ff ff       	call   80102b14 <lapicw>
80102c9c:	83 c4 08             	add    $0x8,%esp
}
80102c9f:	90                   	nop
80102ca0:	c9                   	leave
80102ca1:	c3                   	ret

80102ca2 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ca2:	f3 0f 1e fb          	endbr32
80102ca6:	55                   	push   %ebp
80102ca7:	89 e5                	mov    %esp,%ebp
}
80102ca9:	90                   	nop
80102caa:	5d                   	pop    %ebp
80102cab:	c3                   	ret

80102cac <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102cac:	f3 0f 1e fb          	endbr32
80102cb0:	55                   	push   %ebp
80102cb1:	89 e5                	mov    %esp,%ebp
80102cb3:	83 ec 14             	sub    $0x14,%esp
80102cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102cbc:	6a 0f                	push   $0xf
80102cbe:	6a 70                	push   $0x70
80102cc0:	e8 2e fe ff ff       	call   80102af3 <outb>
80102cc5:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102cc8:	6a 0a                	push   $0xa
80102cca:	6a 71                	push   $0x71
80102ccc:	e8 22 fe ff ff       	call   80102af3 <outb>
80102cd1:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102cd4:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102cdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cde:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce6:	c1 e8 04             	shr    $0x4,%eax
80102ce9:	89 c2                	mov    %eax,%edx
80102ceb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cee:	83 c0 02             	add    $0x2,%eax
80102cf1:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102cf4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf8:	c1 e0 18             	shl    $0x18,%eax
80102cfb:	50                   	push   %eax
80102cfc:	68 c4 00 00 00       	push   $0xc4
80102d01:	e8 0e fe ff ff       	call   80102b14 <lapicw>
80102d06:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102d09:	68 00 c5 00 00       	push   $0xc500
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 fc fd ff ff       	call   80102b14 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 7d ff ff ff       	call   80102ca2 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102d28:	68 00 85 00 00       	push   $0x8500
80102d2d:	68 c0 00 00 00       	push   $0xc0
80102d32:	e8 dd fd ff ff       	call   80102b14 <lapicw>
80102d37:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102d3a:	6a 64                	push   $0x64
80102d3c:	e8 61 ff ff ff       	call   80102ca2 <microdelay>
80102d41:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102d44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102d4b:	eb 3d                	jmp    80102d8a <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102d4d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d51:	c1 e0 18             	shl    $0x18,%eax
80102d54:	50                   	push   %eax
80102d55:	68 c4 00 00 00       	push   $0xc4
80102d5a:	e8 b5 fd ff ff       	call   80102b14 <lapicw>
80102d5f:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d65:	c1 e8 0c             	shr    $0xc,%eax
80102d68:	80 cc 06             	or     $0x6,%ah
80102d6b:	50                   	push   %eax
80102d6c:	68 c0 00 00 00       	push   $0xc0
80102d71:	e8 9e fd ff ff       	call   80102b14 <lapicw>
80102d76:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d79:	68 c8 00 00 00       	push   $0xc8
80102d7e:	e8 1f ff ff ff       	call   80102ca2 <microdelay>
80102d83:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d86:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d8a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d8e:	7e bd                	jle    80102d4d <lapicstartap+0xa1>
  }
}
80102d90:	90                   	nop
80102d91:	90                   	nop
80102d92:	c9                   	leave
80102d93:	c3                   	ret

80102d94 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d94:	f3 0f 1e fb          	endbr32
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	0f b6 c0             	movzbl %al,%eax
80102da1:	50                   	push   %eax
80102da2:	6a 70                	push   $0x70
80102da4:	e8 4a fd ff ff       	call   80102af3 <outb>
80102da9:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102dac:	68 c8 00 00 00       	push   $0xc8
80102db1:	e8 ec fe ff ff       	call   80102ca2 <microdelay>
80102db6:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102db9:	6a 71                	push   $0x71
80102dbb:	e8 16 fd ff ff       	call   80102ad6 <inb>
80102dc0:	83 c4 04             	add    $0x4,%esp
80102dc3:	0f b6 c0             	movzbl %al,%eax
}
80102dc6:	c9                   	leave
80102dc7:	c3                   	ret

80102dc8 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102dc8:	f3 0f 1e fb          	endbr32
80102dcc:	55                   	push   %ebp
80102dcd:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102dcf:	6a 00                	push   $0x0
80102dd1:	e8 be ff ff ff       	call   80102d94 <cmos_read>
80102dd6:	83 c4 04             	add    $0x4,%esp
80102dd9:	8b 55 08             	mov    0x8(%ebp),%edx
80102ddc:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102dde:	6a 02                	push   $0x2
80102de0:	e8 af ff ff ff       	call   80102d94 <cmos_read>
80102de5:	83 c4 04             	add    $0x4,%esp
80102de8:	8b 55 08             	mov    0x8(%ebp),%edx
80102deb:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102dee:	6a 04                	push   $0x4
80102df0:	e8 9f ff ff ff       	call   80102d94 <cmos_read>
80102df5:	83 c4 04             	add    $0x4,%esp
80102df8:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfb:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102dfe:	6a 07                	push   $0x7
80102e00:	e8 8f ff ff ff       	call   80102d94 <cmos_read>
80102e05:	83 c4 04             	add    $0x4,%esp
80102e08:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0b:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102e0e:	6a 08                	push   $0x8
80102e10:	e8 7f ff ff ff       	call   80102d94 <cmos_read>
80102e15:	83 c4 04             	add    $0x4,%esp
80102e18:	8b 55 08             	mov    0x8(%ebp),%edx
80102e1b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102e1e:	6a 09                	push   $0x9
80102e20:	e8 6f ff ff ff       	call   80102d94 <cmos_read>
80102e25:	83 c4 04             	add    $0x4,%esp
80102e28:	8b 55 08             	mov    0x8(%ebp),%edx
80102e2b:	89 42 14             	mov    %eax,0x14(%edx)
}
80102e2e:	90                   	nop
80102e2f:	c9                   	leave
80102e30:	c3                   	ret

80102e31 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102e31:	f3 0f 1e fb          	endbr32
80102e35:	55                   	push   %ebp
80102e36:	89 e5                	mov    %esp,%ebp
80102e38:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102e3b:	6a 0b                	push   $0xb
80102e3d:	e8 52 ff ff ff       	call   80102d94 <cmos_read>
80102e42:	83 c4 04             	add    $0x4,%esp
80102e45:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4b:	83 e0 04             	and    $0x4,%eax
80102e4e:	85 c0                	test   %eax,%eax
80102e50:	0f 94 c0             	sete   %al
80102e53:	0f b6 c0             	movzbl %al,%eax
80102e56:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e59:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e5c:	50                   	push   %eax
80102e5d:	e8 66 ff ff ff       	call   80102dc8 <fill_rtcdate>
80102e62:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e65:	6a 0a                	push   $0xa
80102e67:	e8 28 ff ff ff       	call   80102d94 <cmos_read>
80102e6c:	83 c4 04             	add    $0x4,%esp
80102e6f:	25 80 00 00 00       	and    $0x80,%eax
80102e74:	85 c0                	test   %eax,%eax
80102e76:	75 27                	jne    80102e9f <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e78:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e7b:	50                   	push   %eax
80102e7c:	e8 47 ff ff ff       	call   80102dc8 <fill_rtcdate>
80102e81:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e84:	83 ec 04             	sub    $0x4,%esp
80102e87:	6a 18                	push   $0x18
80102e89:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e8c:	50                   	push   %eax
80102e8d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e90:	50                   	push   %eax
80102e91:	e8 ff 1e 00 00       	call   80104d95 <memcmp>
80102e96:	83 c4 10             	add    $0x10,%esp
80102e99:	85 c0                	test   %eax,%eax
80102e9b:	74 05                	je     80102ea2 <cmostime+0x71>
80102e9d:	eb ba                	jmp    80102e59 <cmostime+0x28>
        continue;
80102e9f:	90                   	nop
    fill_rtcdate(&t1);
80102ea0:	eb b7                	jmp    80102e59 <cmostime+0x28>
      break;
80102ea2:	90                   	nop
  }

  // convert
  if(bcd) {
80102ea3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102ea7:	0f 84 b4 00 00 00    	je     80102f61 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ead:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102eb0:	c1 e8 04             	shr    $0x4,%eax
80102eb3:	89 c2                	mov    %eax,%edx
80102eb5:	89 d0                	mov    %edx,%eax
80102eb7:	c1 e0 02             	shl    $0x2,%eax
80102eba:	01 d0                	add    %edx,%eax
80102ebc:	01 c0                	add    %eax,%eax
80102ebe:	89 c2                	mov    %eax,%edx
80102ec0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ec3:	83 e0 0f             	and    $0xf,%eax
80102ec6:	01 d0                	add    %edx,%eax
80102ec8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102ecb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ece:	c1 e8 04             	shr    $0x4,%eax
80102ed1:	89 c2                	mov    %eax,%edx
80102ed3:	89 d0                	mov    %edx,%eax
80102ed5:	c1 e0 02             	shl    $0x2,%eax
80102ed8:	01 d0                	add    %edx,%eax
80102eda:	01 c0                	add    %eax,%eax
80102edc:	89 c2                	mov    %eax,%edx
80102ede:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ee1:	83 e0 0f             	and    $0xf,%eax
80102ee4:	01 d0                	add    %edx,%eax
80102ee6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102eec:	c1 e8 04             	shr    $0x4,%eax
80102eef:	89 c2                	mov    %eax,%edx
80102ef1:	89 d0                	mov    %edx,%eax
80102ef3:	c1 e0 02             	shl    $0x2,%eax
80102ef6:	01 d0                	add    %edx,%eax
80102ef8:	01 c0                	add    %eax,%eax
80102efa:	89 c2                	mov    %eax,%edx
80102efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102eff:	83 e0 0f             	and    $0xf,%eax
80102f02:	01 d0                	add    %edx,%eax
80102f04:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f0a:	c1 e8 04             	shr    $0x4,%eax
80102f0d:	89 c2                	mov    %eax,%edx
80102f0f:	89 d0                	mov    %edx,%eax
80102f11:	c1 e0 02             	shl    $0x2,%eax
80102f14:	01 d0                	add    %edx,%eax
80102f16:	01 c0                	add    %eax,%eax
80102f18:	89 c2                	mov    %eax,%edx
80102f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f1d:	83 e0 0f             	and    $0xf,%eax
80102f20:	01 d0                	add    %edx,%eax
80102f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102f25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f28:	c1 e8 04             	shr    $0x4,%eax
80102f2b:	89 c2                	mov    %eax,%edx
80102f2d:	89 d0                	mov    %edx,%eax
80102f2f:	c1 e0 02             	shl    $0x2,%eax
80102f32:	01 d0                	add    %edx,%eax
80102f34:	01 c0                	add    %eax,%eax
80102f36:	89 c2                	mov    %eax,%edx
80102f38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f3b:	83 e0 0f             	and    $0xf,%eax
80102f3e:	01 d0                	add    %edx,%eax
80102f40:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f46:	c1 e8 04             	shr    $0x4,%eax
80102f49:	89 c2                	mov    %eax,%edx
80102f4b:	89 d0                	mov    %edx,%eax
80102f4d:	c1 e0 02             	shl    $0x2,%eax
80102f50:	01 d0                	add    %edx,%eax
80102f52:	01 c0                	add    %eax,%eax
80102f54:	89 c2                	mov    %eax,%edx
80102f56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f59:	83 e0 0f             	and    $0xf,%eax
80102f5c:	01 d0                	add    %edx,%eax
80102f5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f61:	8b 45 08             	mov    0x8(%ebp),%eax
80102f64:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f67:	89 10                	mov    %edx,(%eax)
80102f69:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f6c:	89 50 04             	mov    %edx,0x4(%eax)
80102f6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f72:	89 50 08             	mov    %edx,0x8(%eax)
80102f75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f78:	89 50 0c             	mov    %edx,0xc(%eax)
80102f7b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f7e:	89 50 10             	mov    %edx,0x10(%eax)
80102f81:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f84:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f87:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8a:	8b 40 14             	mov    0x14(%eax),%eax
80102f8d:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f93:	8b 45 08             	mov    0x8(%ebp),%eax
80102f96:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f99:	90                   	nop
80102f9a:	c9                   	leave
80102f9b:	c3                   	ret

80102f9c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f9c:	f3 0f 1e fb          	endbr32
80102fa0:	55                   	push   %ebp
80102fa1:	89 e5                	mov    %esp,%ebp
80102fa3:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102fa6:	83 ec 08             	sub    $0x8,%esp
80102fa9:	68 fd a9 10 80       	push   $0x8010a9fd
80102fae:	68 20 54 19 80       	push   $0x80195420
80102fb3:	e8 bd 1a 00 00       	call   80104a75 <initlock>
80102fb8:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102fbb:	83 ec 08             	sub    $0x8,%esp
80102fbe:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102fc1:	50                   	push   %eax
80102fc2:	ff 75 08             	push   0x8(%ebp)
80102fc5:	e8 c0 e4 ff ff       	call   8010148a <readsb>
80102fca:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fd0:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102fd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102fd8:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102fe0:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102fe5:	e8 bf 01 00 00       	call   801031a9 <recover_from_log>
}
80102fea:	90                   	nop
80102feb:	c9                   	leave
80102fec:	c3                   	ret

80102fed <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102fed:	f3 0f 1e fb          	endbr32
80102ff1:	55                   	push   %ebp
80102ff2:	89 e5                	mov    %esp,%ebp
80102ff4:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ff7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ffe:	e9 95 00 00 00       	jmp    80103098 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103003:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010300c:	01 d0                	add    %edx,%eax
8010300e:	83 c0 01             	add    $0x1,%eax
80103011:	89 c2                	mov    %eax,%edx
80103013:	a1 64 54 19 80       	mov    0x80195464,%eax
80103018:	83 ec 08             	sub    $0x8,%esp
8010301b:	52                   	push   %edx
8010301c:	50                   	push   %eax
8010301d:	e8 e7 d1 ff ff       	call   80100209 <bread>
80103022:	83 c4 10             	add    $0x10,%esp
80103025:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010302b:	83 c0 10             	add    $0x10,%eax
8010302e:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103035:	89 c2                	mov    %eax,%edx
80103037:	a1 64 54 19 80       	mov    0x80195464,%eax
8010303c:	83 ec 08             	sub    $0x8,%esp
8010303f:	52                   	push   %edx
80103040:	50                   	push   %eax
80103041:	e8 c3 d1 ff ff       	call   80100209 <bread>
80103046:	83 c4 10             	add    $0x10,%esp
80103049:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010304c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010304f:	8d 50 5c             	lea    0x5c(%eax),%edx
80103052:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103055:	83 c0 5c             	add    $0x5c,%eax
80103058:	83 ec 04             	sub    $0x4,%esp
8010305b:	68 00 02 00 00       	push   $0x200
80103060:	52                   	push   %edx
80103061:	50                   	push   %eax
80103062:	e8 8a 1d 00 00       	call   80104df1 <memmove>
80103067:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010306a:	83 ec 0c             	sub    $0xc,%esp
8010306d:	ff 75 ec             	push   -0x14(%ebp)
80103070:	e8 d1 d1 ff ff       	call   80100246 <bwrite>
80103075:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103078:	83 ec 0c             	sub    $0xc,%esp
8010307b:	ff 75 f0             	push   -0x10(%ebp)
8010307e:	e8 10 d2 ff ff       	call   80100293 <brelse>
80103083:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103086:	83 ec 0c             	sub    $0xc,%esp
80103089:	ff 75 ec             	push   -0x14(%ebp)
8010308c:	e8 02 d2 ff ff       	call   80100293 <brelse>
80103091:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103094:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103098:	a1 68 54 19 80       	mov    0x80195468,%eax
8010309d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030a0:	0f 8c 5d ff ff ff    	jl     80103003 <install_trans+0x16>
  }
}
801030a6:	90                   	nop
801030a7:	90                   	nop
801030a8:	c9                   	leave
801030a9:	c3                   	ret

801030aa <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030aa:	f3 0f 1e fb          	endbr32
801030ae:	55                   	push   %ebp
801030af:	89 e5                	mov    %esp,%ebp
801030b1:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030b4:	a1 54 54 19 80       	mov    0x80195454,%eax
801030b9:	89 c2                	mov    %eax,%edx
801030bb:	a1 64 54 19 80       	mov    0x80195464,%eax
801030c0:	83 ec 08             	sub    $0x8,%esp
801030c3:	52                   	push   %edx
801030c4:	50                   	push   %eax
801030c5:	e8 3f d1 ff ff       	call   80100209 <bread>
801030ca:	83 c4 10             	add    $0x10,%esp
801030cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030d3:	83 c0 5c             	add    $0x5c,%eax
801030d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030dc:	8b 00                	mov    (%eax),%eax
801030de:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
801030e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030ea:	eb 1b                	jmp    80103107 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801030ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030f2:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801030f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030f9:	83 c2 10             	add    $0x10,%edx
801030fc:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103103:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103107:	a1 68 54 19 80       	mov    0x80195468,%eax
8010310c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010310f:	7c db                	jl     801030ec <read_head+0x42>
  }
  brelse(buf);
80103111:	83 ec 0c             	sub    $0xc,%esp
80103114:	ff 75 f0             	push   -0x10(%ebp)
80103117:	e8 77 d1 ff ff       	call   80100293 <brelse>
8010311c:	83 c4 10             	add    $0x10,%esp
}
8010311f:	90                   	nop
80103120:	c9                   	leave
80103121:	c3                   	ret

80103122 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103122:	f3 0f 1e fb          	endbr32
80103126:	55                   	push   %ebp
80103127:	89 e5                	mov    %esp,%ebp
80103129:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010312c:	a1 54 54 19 80       	mov    0x80195454,%eax
80103131:	89 c2                	mov    %eax,%edx
80103133:	a1 64 54 19 80       	mov    0x80195464,%eax
80103138:	83 ec 08             	sub    $0x8,%esp
8010313b:	52                   	push   %edx
8010313c:	50                   	push   %eax
8010313d:	e8 c7 d0 ff ff       	call   80100209 <bread>
80103142:	83 c4 10             	add    $0x10,%esp
80103145:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010314b:	83 c0 5c             	add    $0x5c,%eax
8010314e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103151:	8b 15 68 54 19 80    	mov    0x80195468,%edx
80103157:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010315a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010315c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103163:	eb 1b                	jmp    80103180 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103168:	83 c0 10             	add    $0x10,%eax
8010316b:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103175:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103178:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010317c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103180:	a1 68 54 19 80       	mov    0x80195468,%eax
80103185:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103188:	7c db                	jl     80103165 <write_head+0x43>
  }
  bwrite(buf);
8010318a:	83 ec 0c             	sub    $0xc,%esp
8010318d:	ff 75 f0             	push   -0x10(%ebp)
80103190:	e8 b1 d0 ff ff       	call   80100246 <bwrite>
80103195:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103198:	83 ec 0c             	sub    $0xc,%esp
8010319b:	ff 75 f0             	push   -0x10(%ebp)
8010319e:	e8 f0 d0 ff ff       	call   80100293 <brelse>
801031a3:	83 c4 10             	add    $0x10,%esp
}
801031a6:	90                   	nop
801031a7:	c9                   	leave
801031a8:	c3                   	ret

801031a9 <recover_from_log>:

static void
recover_from_log(void)
{
801031a9:	f3 0f 1e fb          	endbr32
801031ad:	55                   	push   %ebp
801031ae:	89 e5                	mov    %esp,%ebp
801031b0:	83 ec 08             	sub    $0x8,%esp
  read_head();
801031b3:	e8 f2 fe ff ff       	call   801030aa <read_head>
  install_trans(); // if committed, copy from log to disk
801031b8:	e8 30 fe ff ff       	call   80102fed <install_trans>
  log.lh.n = 0;
801031bd:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801031c4:	00 00 00 
  write_head(); // clear the log
801031c7:	e8 56 ff ff ff       	call   80103122 <write_head>
}
801031cc:	90                   	nop
801031cd:	c9                   	leave
801031ce:	c3                   	ret

801031cf <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801031cf:	f3 0f 1e fb          	endbr32
801031d3:	55                   	push   %ebp
801031d4:	89 e5                	mov    %esp,%ebp
801031d6:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801031d9:	83 ec 0c             	sub    $0xc,%esp
801031dc:	68 20 54 19 80       	push   $0x80195420
801031e1:	e8 b5 18 00 00       	call   80104a9b <acquire>
801031e6:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801031e9:	a1 60 54 19 80       	mov    0x80195460,%eax
801031ee:	85 c0                	test   %eax,%eax
801031f0:	74 17                	je     80103209 <begin_op+0x3a>
      sleep(&log, &log.lock);
801031f2:	83 ec 08             	sub    $0x8,%esp
801031f5:	68 20 54 19 80       	push   $0x80195420
801031fa:	68 20 54 19 80       	push   $0x80195420
801031ff:	e8 0e 13 00 00       	call   80104512 <sleep>
80103204:	83 c4 10             	add    $0x10,%esp
80103207:	eb e0                	jmp    801031e9 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103209:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
8010320f:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103214:	8d 50 01             	lea    0x1(%eax),%edx
80103217:	89 d0                	mov    %edx,%eax
80103219:	c1 e0 02             	shl    $0x2,%eax
8010321c:	01 d0                	add    %edx,%eax
8010321e:	01 c0                	add    %eax,%eax
80103220:	01 c8                	add    %ecx,%eax
80103222:	83 f8 1e             	cmp    $0x1e,%eax
80103225:	7e 17                	jle    8010323e <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103227:	83 ec 08             	sub    $0x8,%esp
8010322a:	68 20 54 19 80       	push   $0x80195420
8010322f:	68 20 54 19 80       	push   $0x80195420
80103234:	e8 d9 12 00 00       	call   80104512 <sleep>
80103239:	83 c4 10             	add    $0x10,%esp
8010323c:	eb ab                	jmp    801031e9 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
8010323e:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103243:	83 c0 01             	add    $0x1,%eax
80103246:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
8010324b:	83 ec 0c             	sub    $0xc,%esp
8010324e:	68 20 54 19 80       	push   $0x80195420
80103253:	e8 b5 18 00 00       	call   80104b0d <release>
80103258:	83 c4 10             	add    $0x10,%esp
      break;
8010325b:	90                   	nop
    }
  }
}
8010325c:	90                   	nop
8010325d:	c9                   	leave
8010325e:	c3                   	ret

8010325f <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010325f:	f3 0f 1e fb          	endbr32
80103263:	55                   	push   %ebp
80103264:	89 e5                	mov    %esp,%ebp
80103266:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103270:	83 ec 0c             	sub    $0xc,%esp
80103273:	68 20 54 19 80       	push   $0x80195420
80103278:	e8 1e 18 00 00       	call   80104a9b <acquire>
8010327d:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103280:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103285:	83 e8 01             	sub    $0x1,%eax
80103288:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010328d:	a1 60 54 19 80       	mov    0x80195460,%eax
80103292:	85 c0                	test   %eax,%eax
80103294:	74 0d                	je     801032a3 <end_op+0x44>
    panic("log.committing");
80103296:	83 ec 0c             	sub    $0xc,%esp
80103299:	68 01 aa 10 80       	push   $0x8010aa01
8010329e:	e8 3b d3 ff ff       	call   801005de <panic>
  if(log.outstanding == 0){
801032a3:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801032a8:	85 c0                	test   %eax,%eax
801032aa:	75 13                	jne    801032bf <end_op+0x60>
    do_commit = 1;
801032ac:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801032b3:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
801032ba:	00 00 00 
801032bd:	eb 10                	jmp    801032cf <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801032bf:	83 ec 0c             	sub    $0xc,%esp
801032c2:	68 20 54 19 80       	push   $0x80195420
801032c7:	e8 35 13 00 00       	call   80104601 <wakeup>
801032cc:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801032cf:	83 ec 0c             	sub    $0xc,%esp
801032d2:	68 20 54 19 80       	push   $0x80195420
801032d7:	e8 31 18 00 00       	call   80104b0d <release>
801032dc:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801032df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801032e3:	74 3f                	je     80103324 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801032e5:	e8 fa 00 00 00       	call   801033e4 <commit>
    acquire(&log.lock);
801032ea:	83 ec 0c             	sub    $0xc,%esp
801032ed:	68 20 54 19 80       	push   $0x80195420
801032f2:	e8 a4 17 00 00       	call   80104a9b <acquire>
801032f7:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801032fa:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
80103301:	00 00 00 
    wakeup(&log);
80103304:	83 ec 0c             	sub    $0xc,%esp
80103307:	68 20 54 19 80       	push   $0x80195420
8010330c:	e8 f0 12 00 00       	call   80104601 <wakeup>
80103311:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103314:	83 ec 0c             	sub    $0xc,%esp
80103317:	68 20 54 19 80       	push   $0x80195420
8010331c:	e8 ec 17 00 00       	call   80104b0d <release>
80103321:	83 c4 10             	add    $0x10,%esp
  }
}
80103324:	90                   	nop
80103325:	c9                   	leave
80103326:	c3                   	ret

80103327 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103327:	f3 0f 1e fb          	endbr32
8010332b:	55                   	push   %ebp
8010332c:	89 e5                	mov    %esp,%ebp
8010332e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103331:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103338:	e9 95 00 00 00       	jmp    801033d2 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010333d:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103346:	01 d0                	add    %edx,%eax
80103348:	83 c0 01             	add    $0x1,%eax
8010334b:	89 c2                	mov    %eax,%edx
8010334d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103352:	83 ec 08             	sub    $0x8,%esp
80103355:	52                   	push   %edx
80103356:	50                   	push   %eax
80103357:	e8 ad ce ff ff       	call   80100209 <bread>
8010335c:	83 c4 10             	add    $0x10,%esp
8010335f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103365:	83 c0 10             	add    $0x10,%eax
80103368:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010336f:	89 c2                	mov    %eax,%edx
80103371:	a1 64 54 19 80       	mov    0x80195464,%eax
80103376:	83 ec 08             	sub    $0x8,%esp
80103379:	52                   	push   %edx
8010337a:	50                   	push   %eax
8010337b:	e8 89 ce ff ff       	call   80100209 <bread>
80103380:	83 c4 10             	add    $0x10,%esp
80103383:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103386:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103389:	8d 50 5c             	lea    0x5c(%eax),%edx
8010338c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338f:	83 c0 5c             	add    $0x5c,%eax
80103392:	83 ec 04             	sub    $0x4,%esp
80103395:	68 00 02 00 00       	push   $0x200
8010339a:	52                   	push   %edx
8010339b:	50                   	push   %eax
8010339c:	e8 50 1a 00 00       	call   80104df1 <memmove>
801033a1:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801033a4:	83 ec 0c             	sub    $0xc,%esp
801033a7:	ff 75 f0             	push   -0x10(%ebp)
801033aa:	e8 97 ce ff ff       	call   80100246 <bwrite>
801033af:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801033b2:	83 ec 0c             	sub    $0xc,%esp
801033b5:	ff 75 ec             	push   -0x14(%ebp)
801033b8:	e8 d6 ce ff ff       	call   80100293 <brelse>
801033bd:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801033c0:	83 ec 0c             	sub    $0xc,%esp
801033c3:	ff 75 f0             	push   -0x10(%ebp)
801033c6:	e8 c8 ce ff ff       	call   80100293 <brelse>
801033cb:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033d2:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033da:	0f 8c 5d ff ff ff    	jl     8010333d <write_log+0x16>
  }
}
801033e0:	90                   	nop
801033e1:	90                   	nop
801033e2:	c9                   	leave
801033e3:	c3                   	ret

801033e4 <commit>:

static void
commit()
{
801033e4:	f3 0f 1e fb          	endbr32
801033e8:	55                   	push   %ebp
801033e9:	89 e5                	mov    %esp,%ebp
801033eb:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033ee:	a1 68 54 19 80       	mov    0x80195468,%eax
801033f3:	85 c0                	test   %eax,%eax
801033f5:	7e 1e                	jle    80103415 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
801033f7:	e8 2b ff ff ff       	call   80103327 <write_log>
    write_head();    // Write header to disk -- the real commit
801033fc:	e8 21 fd ff ff       	call   80103122 <write_head>
    install_trans(); // Now install writes to home locations
80103401:	e8 e7 fb ff ff       	call   80102fed <install_trans>
    log.lh.n = 0;
80103406:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
8010340d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103410:	e8 0d fd ff ff       	call   80103122 <write_head>
  }
}
80103415:	90                   	nop
80103416:	c9                   	leave
80103417:	c3                   	ret

80103418 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103418:	f3 0f 1e fb          	endbr32
8010341c:	55                   	push   %ebp
8010341d:	89 e5                	mov    %esp,%ebp
8010341f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103422:	a1 68 54 19 80       	mov    0x80195468,%eax
80103427:	83 f8 1d             	cmp    $0x1d,%eax
8010342a:	7f 12                	jg     8010343e <log_write+0x26>
8010342c:	a1 68 54 19 80       	mov    0x80195468,%eax
80103431:	8b 15 58 54 19 80    	mov    0x80195458,%edx
80103437:	83 ea 01             	sub    $0x1,%edx
8010343a:	39 d0                	cmp    %edx,%eax
8010343c:	7c 0d                	jl     8010344b <log_write+0x33>
    panic("too big a transaction");
8010343e:	83 ec 0c             	sub    $0xc,%esp
80103441:	68 10 aa 10 80       	push   $0x8010aa10
80103446:	e8 93 d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
8010344b:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103450:	85 c0                	test   %eax,%eax
80103452:	7f 0d                	jg     80103461 <log_write+0x49>
    panic("log_write outside of trans");
80103454:	83 ec 0c             	sub    $0xc,%esp
80103457:	68 26 aa 10 80       	push   $0x8010aa26
8010345c:	e8 7d d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103461:	83 ec 0c             	sub    $0xc,%esp
80103464:	68 20 54 19 80       	push   $0x80195420
80103469:	e8 2d 16 00 00       	call   80104a9b <acquire>
8010346e:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103478:	eb 1d                	jmp    80103497 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010347a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010347d:	83 c0 10             	add    $0x10,%eax
80103480:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103487:	89 c2                	mov    %eax,%edx
80103489:	8b 45 08             	mov    0x8(%ebp),%eax
8010348c:	8b 40 08             	mov    0x8(%eax),%eax
8010348f:	39 c2                	cmp    %eax,%edx
80103491:	74 10                	je     801034a3 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103493:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103497:	a1 68 54 19 80       	mov    0x80195468,%eax
8010349c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010349f:	7c d9                	jl     8010347a <log_write+0x62>
801034a1:	eb 01                	jmp    801034a4 <log_write+0x8c>
      break;
801034a3:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801034a4:	8b 45 08             	mov    0x8(%ebp),%eax
801034a7:	8b 40 08             	mov    0x8(%eax),%eax
801034aa:	89 c2                	mov    %eax,%edx
801034ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034af:	83 c0 10             	add    $0x10,%eax
801034b2:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
801034b9:	a1 68 54 19 80       	mov    0x80195468,%eax
801034be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034c1:	75 0d                	jne    801034d0 <log_write+0xb8>
    log.lh.n++;
801034c3:	a1 68 54 19 80       	mov    0x80195468,%eax
801034c8:	83 c0 01             	add    $0x1,%eax
801034cb:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
801034d0:	8b 45 08             	mov    0x8(%ebp),%eax
801034d3:	8b 00                	mov    (%eax),%eax
801034d5:	83 c8 04             	or     $0x4,%eax
801034d8:	89 c2                	mov    %eax,%edx
801034da:	8b 45 08             	mov    0x8(%ebp),%eax
801034dd:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	68 20 54 19 80       	push   $0x80195420
801034e7:	e8 21 16 00 00       	call   80104b0d <release>
801034ec:	83 c4 10             	add    $0x10,%esp
}
801034ef:	90                   	nop
801034f0:	c9                   	leave
801034f1:	c3                   	ret

801034f2 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801034f2:	55                   	push   %ebp
801034f3:	89 e5                	mov    %esp,%ebp
801034f5:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801034f8:	8b 55 08             	mov    0x8(%ebp),%edx
801034fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801034fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103501:	f0 87 02             	lock xchg %eax,(%edx)
80103504:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103507:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010350a:	c9                   	leave
8010350b:	c3                   	ret

8010350c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010350c:	f3 0f 1e fb          	endbr32
80103510:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103514:	83 e4 f0             	and    $0xfffffff0,%esp
80103517:	ff 71 fc             	push   -0x4(%ecx)
8010351a:	55                   	push   %ebp
8010351b:	89 e5                	mov    %esp,%ebp
8010351d:	51                   	push   %ecx
8010351e:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103521:	e8 14 4f 00 00       	call   8010843a <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103526:	83 ec 08             	sub    $0x8,%esp
80103529:	68 00 00 40 80       	push   $0x80400000
8010352e:	68 00 90 19 80       	push   $0x80199000
80103533:	e8 73 f2 ff ff       	call   801027ab <kinit1>
80103538:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010353b:	e8 ec 44 00 00       	call   80107a2c <kvmalloc>
  mpinit_uefi();
80103540:	e8 ae 4c 00 00       	call   801081f3 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103545:	e8 f0 f5 ff ff       	call   80102b3a <lapicinit>
  seginit();       // segment descriptors
8010354a:	e8 64 3f 00 00       	call   801074b3 <seginit>
  picinit();    // disable pic
8010354f:	e8 a9 01 00 00       	call   801036fd <picinit>
  ioapicinit();    // another interrupt controller
80103554:	e8 65 f1 ff ff       	call   801026be <ioapicinit>
  consoleinit();   // console hardware
80103559:	e8 f4 d5 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
8010355e:	e8 d9 32 00 00       	call   8010683c <uartinit>
  pinit();         // process table
80103563:	e8 e2 05 00 00       	call   80103b4a <pinit>
  tvinit();        // trap vectors
80103568:	e8 9c 2d 00 00       	call   80106309 <tvinit>
  binit();         // buffer cache
8010356d:	e8 f4 ca ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103572:	e8 e8 da ff ff       	call   8010105f <fileinit>
  ideinit();       // disk 
80103577:	e8 c3 70 00 00       	call   8010a63f <ideinit>
  startothers();   // start other processors
8010357c:	e8 92 00 00 00       	call   80103613 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103581:	83 ec 08             	sub    $0x8,%esp
80103584:	68 00 00 00 a0       	push   $0xa0000000
80103589:	68 00 00 40 80       	push   $0x80400000
8010358e:	e8 55 f2 ff ff       	call   801027e8 <kinit2>
80103593:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103596:	e8 12 51 00 00       	call   801086ad <pci_init>
  arp_scan();
8010359b:	e8 8b 5e 00 00       	call   8010942b <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801035a0:	e8 9b 07 00 00       	call   80103d40 <userinit>
  mpmain();        // finish this processor's setup
801035a5:	e8 1e 00 00 00       	call   801035c8 <mpmain>

801035aa <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801035aa:	f3 0f 1e fb          	endbr32
801035ae:	55                   	push   %ebp
801035af:	89 e5                	mov    %esp,%ebp
801035b1:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801035b4:	e8 8f 44 00 00       	call   80107a48 <switchkvm>
  seginit();
801035b9:	e8 f5 3e 00 00       	call   801074b3 <seginit>
  lapicinit();
801035be:	e8 77 f5 ff ff       	call   80102b3a <lapicinit>
  mpmain();
801035c3:	e8 00 00 00 00       	call   801035c8 <mpmain>

801035c8 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035c8:	f3 0f 1e fb          	endbr32
801035cc:	55                   	push   %ebp
801035cd:	89 e5                	mov    %esp,%ebp
801035cf:	53                   	push   %ebx
801035d0:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801035d3:	e8 94 05 00 00       	call   80103b6c <cpuid>
801035d8:	89 c3                	mov    %eax,%ebx
801035da:	e8 8d 05 00 00       	call   80103b6c <cpuid>
801035df:	83 ec 04             	sub    $0x4,%esp
801035e2:	53                   	push   %ebx
801035e3:	50                   	push   %eax
801035e4:	68 41 aa 10 80       	push   $0x8010aa41
801035e9:	e8 1e ce ff ff       	call   8010040c <cprintf>
801035ee:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801035f1:	e8 8d 2e 00 00       	call   80106483 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801035f6:	e8 90 05 00 00       	call   80103b8b <mycpu>
801035fb:	05 a0 00 00 00       	add    $0xa0,%eax
80103600:	83 ec 08             	sub    $0x8,%esp
80103603:	6a 01                	push   $0x1
80103605:	50                   	push   %eax
80103606:	e8 e7 fe ff ff       	call   801034f2 <xchg>
8010360b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010360e:	e8 dc 0c 00 00       	call   801042ef <scheduler>

80103613 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103613:	f3 0f 1e fb          	endbr32
80103617:	55                   	push   %ebp
80103618:	89 e5                	mov    %esp,%ebp
8010361a:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010361d:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103624:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103629:	83 ec 04             	sub    $0x4,%esp
8010362c:	50                   	push   %eax
8010362d:	68 18 f5 10 80       	push   $0x8010f518
80103632:	ff 75 f0             	push   -0x10(%ebp)
80103635:	e8 b7 17 00 00       	call   80104df1 <memmove>
8010363a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010363d:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
80103644:	eb 79                	jmp    801036bf <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103646:	e8 40 05 00 00       	call   80103b8b <mycpu>
8010364b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010364e:	74 67                	je     801036b7 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103650:	e8 9b f2 ff ff       	call   801028f0 <kalloc>
80103655:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010365b:	83 e8 04             	sub    $0x4,%eax
8010365e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103661:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103667:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366c:	83 e8 08             	sub    $0x8,%eax
8010366f:	c7 00 aa 35 10 80    	movl   $0x801035aa,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103675:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010367a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103683:	83 e8 0c             	sub    $0xc,%eax
80103686:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010368b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103694:	0f b6 00             	movzbl (%eax),%eax
80103697:	0f b6 c0             	movzbl %al,%eax
8010369a:	83 ec 08             	sub    $0x8,%esp
8010369d:	52                   	push   %edx
8010369e:	50                   	push   %eax
8010369f:	e8 08 f6 ff ff       	call   80102cac <lapicstartap>
801036a4:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801036a7:	90                   	nop
801036a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ab:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801036b1:	85 c0                	test   %eax,%eax
801036b3:	74 f3                	je     801036a8 <startothers+0x95>
801036b5:	eb 01                	jmp    801036b8 <startothers+0xa5>
      continue;
801036b7:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801036b8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801036bf:	a1 80 80 19 80       	mov    0x80198080,%eax
801036c4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801036ca:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801036cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036d2:	0f 82 6e ff ff ff    	jb     80103646 <startothers+0x33>
      ;
  }
}
801036d8:	90                   	nop
801036d9:	90                   	nop
801036da:	c9                   	leave
801036db:	c3                   	ret

801036dc <outb>:
{
801036dc:	55                   	push   %ebp
801036dd:	89 e5                	mov    %esp,%ebp
801036df:	83 ec 08             	sub    $0x8,%esp
801036e2:	8b 45 08             	mov    0x8(%ebp),%eax
801036e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801036e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801036ec:	89 d0                	mov    %edx,%eax
801036ee:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801036f1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801036f5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801036f9:	ee                   	out    %al,(%dx)
}
801036fa:	90                   	nop
801036fb:	c9                   	leave
801036fc:	c3                   	ret

801036fd <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801036fd:	f3 0f 1e fb          	endbr32
80103701:	55                   	push   %ebp
80103702:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103704:	68 ff 00 00 00       	push   $0xff
80103709:	6a 21                	push   $0x21
8010370b:	e8 cc ff ff ff       	call   801036dc <outb>
80103710:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103713:	68 ff 00 00 00       	push   $0xff
80103718:	68 a1 00 00 00       	push   $0xa1
8010371d:	e8 ba ff ff ff       	call   801036dc <outb>
80103722:	83 c4 08             	add    $0x8,%esp
}
80103725:	90                   	nop
80103726:	c9                   	leave
80103727:	c3                   	ret

80103728 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103728:	f3 0f 1e fb          	endbr32
8010372c:	55                   	push   %ebp
8010372d:	89 e5                	mov    %esp,%ebp
8010372f:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103739:	8b 45 0c             	mov    0xc(%ebp),%eax
8010373c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103742:	8b 45 0c             	mov    0xc(%ebp),%eax
80103745:	8b 10                	mov    (%eax),%edx
80103747:	8b 45 08             	mov    0x8(%ebp),%eax
8010374a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010374c:	e8 30 d9 ff ff       	call   80101081 <filealloc>
80103751:	8b 55 08             	mov    0x8(%ebp),%edx
80103754:	89 02                	mov    %eax,(%edx)
80103756:	8b 45 08             	mov    0x8(%ebp),%eax
80103759:	8b 00                	mov    (%eax),%eax
8010375b:	85 c0                	test   %eax,%eax
8010375d:	0f 84 c8 00 00 00    	je     8010382b <pipealloc+0x103>
80103763:	e8 19 d9 ff ff       	call   80101081 <filealloc>
80103768:	8b 55 0c             	mov    0xc(%ebp),%edx
8010376b:	89 02                	mov    %eax,(%edx)
8010376d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103770:	8b 00                	mov    (%eax),%eax
80103772:	85 c0                	test   %eax,%eax
80103774:	0f 84 b1 00 00 00    	je     8010382b <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010377a:	e8 71 f1 ff ff       	call   801028f0 <kalloc>
8010377f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103782:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103786:	0f 84 a2 00 00 00    	je     8010382e <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010378c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103796:	00 00 00 
  p->writeopen = 1;
80103799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801037a3:	00 00 00 
  p->nwrite = 0;
801037a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037a9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801037b0:	00 00 00 
  p->nread = 0;
801037b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801037bd:	00 00 00 
  initlock(&p->lock, "pipe");
801037c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c3:	83 ec 08             	sub    $0x8,%esp
801037c6:	68 55 aa 10 80       	push   $0x8010aa55
801037cb:	50                   	push   %eax
801037cc:	e8 a4 12 00 00       	call   80104a75 <initlock>
801037d1:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037d4:	8b 45 08             	mov    0x8(%ebp),%eax
801037d7:	8b 00                	mov    (%eax),%eax
801037d9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037df:	8b 45 08             	mov    0x8(%ebp),%eax
801037e2:	8b 00                	mov    (%eax),%eax
801037e4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037e8:	8b 45 08             	mov    0x8(%ebp),%eax
801037eb:	8b 00                	mov    (%eax),%eax
801037ed:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037f1:	8b 45 08             	mov    0x8(%ebp),%eax
801037f4:	8b 00                	mov    (%eax),%eax
801037f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037f9:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801037fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ff:	8b 00                	mov    (%eax),%eax
80103801:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103807:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380a:	8b 00                	mov    (%eax),%eax
8010380c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103810:	8b 45 0c             	mov    0xc(%ebp),%eax
80103813:	8b 00                	mov    (%eax),%eax
80103815:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103819:	8b 45 0c             	mov    0xc(%ebp),%eax
8010381c:	8b 00                	mov    (%eax),%eax
8010381e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103821:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103824:	b8 00 00 00 00       	mov    $0x0,%eax
80103829:	eb 51                	jmp    8010387c <pipealloc+0x154>
    goto bad;
8010382b:	90                   	nop
8010382c:	eb 01                	jmp    8010382f <pipealloc+0x107>
    goto bad;
8010382e:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010382f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103833:	74 0e                	je     80103843 <pipealloc+0x11b>
    kfree((char*)p);
80103835:	83 ec 0c             	sub    $0xc,%esp
80103838:	ff 75 f4             	push   -0xc(%ebp)
8010383b:	e8 12 f0 ff ff       	call   80102852 <kfree>
80103840:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	8b 00                	mov    (%eax),%eax
80103848:	85 c0                	test   %eax,%eax
8010384a:	74 11                	je     8010385d <pipealloc+0x135>
    fileclose(*f0);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	8b 00                	mov    (%eax),%eax
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	50                   	push   %eax
80103855:	e8 ed d8 ff ff       	call   80101147 <fileclose>
8010385a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010385d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103860:	8b 00                	mov    (%eax),%eax
80103862:	85 c0                	test   %eax,%eax
80103864:	74 11                	je     80103877 <pipealloc+0x14f>
    fileclose(*f1);
80103866:	8b 45 0c             	mov    0xc(%ebp),%eax
80103869:	8b 00                	mov    (%eax),%eax
8010386b:	83 ec 0c             	sub    $0xc,%esp
8010386e:	50                   	push   %eax
8010386f:	e8 d3 d8 ff ff       	call   80101147 <fileclose>
80103874:	83 c4 10             	add    $0x10,%esp
  return -1;
80103877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010387c:	c9                   	leave
8010387d:	c3                   	ret

8010387e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010387e:	f3 0f 1e fb          	endbr32
80103882:	55                   	push   %ebp
80103883:	89 e5                	mov    %esp,%ebp
80103885:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103888:	8b 45 08             	mov    0x8(%ebp),%eax
8010388b:	83 ec 0c             	sub    $0xc,%esp
8010388e:	50                   	push   %eax
8010388f:	e8 07 12 00 00       	call   80104a9b <acquire>
80103894:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103897:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010389b:	74 23                	je     801038c0 <pipeclose+0x42>
    p->writeopen = 0;
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801038a7:	00 00 00 
    wakeup(&p->nread);
801038aa:	8b 45 08             	mov    0x8(%ebp),%eax
801038ad:	05 34 02 00 00       	add    $0x234,%eax
801038b2:	83 ec 0c             	sub    $0xc,%esp
801038b5:	50                   	push   %eax
801038b6:	e8 46 0d 00 00       	call   80104601 <wakeup>
801038bb:	83 c4 10             	add    $0x10,%esp
801038be:	eb 21                	jmp    801038e1 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801038c0:	8b 45 08             	mov    0x8(%ebp),%eax
801038c3:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801038ca:	00 00 00 
    wakeup(&p->nwrite);
801038cd:	8b 45 08             	mov    0x8(%ebp),%eax
801038d0:	05 38 02 00 00       	add    $0x238,%eax
801038d5:	83 ec 0c             	sub    $0xc,%esp
801038d8:	50                   	push   %eax
801038d9:	e8 23 0d 00 00       	call   80104601 <wakeup>
801038de:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801038e1:	8b 45 08             	mov    0x8(%ebp),%eax
801038e4:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	75 2c                	jne    8010391a <pipeclose+0x9c>
801038ee:	8b 45 08             	mov    0x8(%ebp),%eax
801038f1:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038f7:	85 c0                	test   %eax,%eax
801038f9:	75 1f                	jne    8010391a <pipeclose+0x9c>
    release(&p->lock);
801038fb:	8b 45 08             	mov    0x8(%ebp),%eax
801038fe:	83 ec 0c             	sub    $0xc,%esp
80103901:	50                   	push   %eax
80103902:	e8 06 12 00 00       	call   80104b0d <release>
80103907:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010390a:	83 ec 0c             	sub    $0xc,%esp
8010390d:	ff 75 08             	push   0x8(%ebp)
80103910:	e8 3d ef ff ff       	call   80102852 <kfree>
80103915:	83 c4 10             	add    $0x10,%esp
80103918:	eb 10                	jmp    8010392a <pipeclose+0xac>
  } else
    release(&p->lock);
8010391a:	8b 45 08             	mov    0x8(%ebp),%eax
8010391d:	83 ec 0c             	sub    $0xc,%esp
80103920:	50                   	push   %eax
80103921:	e8 e7 11 00 00       	call   80104b0d <release>
80103926:	83 c4 10             	add    $0x10,%esp
}
80103929:	90                   	nop
8010392a:	90                   	nop
8010392b:	c9                   	leave
8010392c:	c3                   	ret

8010392d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010392d:	f3 0f 1e fb          	endbr32
80103931:	55                   	push   %ebp
80103932:	89 e5                	mov    %esp,%ebp
80103934:	53                   	push   %ebx
80103935:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103938:	8b 45 08             	mov    0x8(%ebp),%eax
8010393b:	83 ec 0c             	sub    $0xc,%esp
8010393e:	50                   	push   %eax
8010393f:	e8 57 11 00 00       	call   80104a9b <acquire>
80103944:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103947:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010394e:	e9 ad 00 00 00       	jmp    80103a00 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103953:	8b 45 08             	mov    0x8(%ebp),%eax
80103956:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010395c:	85 c0                	test   %eax,%eax
8010395e:	74 0c                	je     8010396c <pipewrite+0x3f>
80103960:	e8 a2 02 00 00       	call   80103c07 <myproc>
80103965:	8b 40 24             	mov    0x24(%eax),%eax
80103968:	85 c0                	test   %eax,%eax
8010396a:	74 19                	je     80103985 <pipewrite+0x58>
        release(&p->lock);
8010396c:	8b 45 08             	mov    0x8(%ebp),%eax
8010396f:	83 ec 0c             	sub    $0xc,%esp
80103972:	50                   	push   %eax
80103973:	e8 95 11 00 00       	call   80104b0d <release>
80103978:	83 c4 10             	add    $0x10,%esp
        return -1;
8010397b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103980:	e9 a9 00 00 00       	jmp    80103a2e <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103985:	8b 45 08             	mov    0x8(%ebp),%eax
80103988:	05 34 02 00 00       	add    $0x234,%eax
8010398d:	83 ec 0c             	sub    $0xc,%esp
80103990:	50                   	push   %eax
80103991:	e8 6b 0c 00 00       	call   80104601 <wakeup>
80103996:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103999:	8b 45 08             	mov    0x8(%ebp),%eax
8010399c:	8b 55 08             	mov    0x8(%ebp),%edx
8010399f:	81 c2 38 02 00 00    	add    $0x238,%edx
801039a5:	83 ec 08             	sub    $0x8,%esp
801039a8:	50                   	push   %eax
801039a9:	52                   	push   %edx
801039aa:	e8 63 0b 00 00       	call   80104512 <sleep>
801039af:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801039b2:	8b 45 08             	mov    0x8(%ebp),%eax
801039b5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801039bb:	8b 45 08             	mov    0x8(%ebp),%eax
801039be:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801039c4:	05 00 02 00 00       	add    $0x200,%eax
801039c9:	39 c2                	cmp    %eax,%edx
801039cb:	74 86                	je     80103953 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039d3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801039d6:	8b 45 08             	mov    0x8(%ebp),%eax
801039d9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801039df:	8d 48 01             	lea    0x1(%eax),%ecx
801039e2:	8b 55 08             	mov    0x8(%ebp),%edx
801039e5:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801039eb:	25 ff 01 00 00       	and    $0x1ff,%eax
801039f0:	89 c1                	mov    %eax,%ecx
801039f2:	0f b6 13             	movzbl (%ebx),%edx
801039f5:	8b 45 08             	mov    0x8(%ebp),%eax
801039f8:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801039fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a03:	3b 45 10             	cmp    0x10(%ebp),%eax
80103a06:	7c aa                	jl     801039b2 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103a08:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0b:	05 34 02 00 00       	add    $0x234,%eax
80103a10:	83 ec 0c             	sub    $0xc,%esp
80103a13:	50                   	push   %eax
80103a14:	e8 e8 0b 00 00       	call   80104601 <wakeup>
80103a19:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1f:	83 ec 0c             	sub    $0xc,%esp
80103a22:	50                   	push   %eax
80103a23:	e8 e5 10 00 00       	call   80104b0d <release>
80103a28:	83 c4 10             	add    $0x10,%esp
  return n;
80103a2b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a31:	c9                   	leave
80103a32:	c3                   	ret

80103a33 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103a33:	f3 0f 1e fb          	endbr32
80103a37:	55                   	push   %ebp
80103a38:	89 e5                	mov    %esp,%ebp
80103a3a:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a40:	83 ec 0c             	sub    $0xc,%esp
80103a43:	50                   	push   %eax
80103a44:	e8 52 10 00 00       	call   80104a9b <acquire>
80103a49:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a4c:	eb 3e                	jmp    80103a8c <piperead+0x59>
    if(myproc()->killed){
80103a4e:	e8 b4 01 00 00       	call   80103c07 <myproc>
80103a53:	8b 40 24             	mov    0x24(%eax),%eax
80103a56:	85 c0                	test   %eax,%eax
80103a58:	74 19                	je     80103a73 <piperead+0x40>
      release(&p->lock);
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	83 ec 0c             	sub    $0xc,%esp
80103a60:	50                   	push   %eax
80103a61:	e8 a7 10 00 00       	call   80104b0d <release>
80103a66:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a6e:	e9 be 00 00 00       	jmp    80103b31 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a73:	8b 45 08             	mov    0x8(%ebp),%eax
80103a76:	8b 55 08             	mov    0x8(%ebp),%edx
80103a79:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a7f:	83 ec 08             	sub    $0x8,%esp
80103a82:	50                   	push   %eax
80103a83:	52                   	push   %edx
80103a84:	e8 89 0a 00 00       	call   80104512 <sleep>
80103a89:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a95:	8b 45 08             	mov    0x8(%ebp),%eax
80103a98:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a9e:	39 c2                	cmp    %eax,%edx
80103aa0:	75 0d                	jne    80103aaf <piperead+0x7c>
80103aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103aab:	85 c0                	test   %eax,%eax
80103aad:	75 9f                	jne    80103a4e <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103aaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ab6:	eb 48                	jmp    80103b00 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80103abb:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103aca:	39 c2                	cmp    %eax,%edx
80103acc:	74 3c                	je     80103b0a <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103ace:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ad7:	8d 48 01             	lea    0x1(%eax),%ecx
80103ada:	8b 55 08             	mov    0x8(%ebp),%edx
80103add:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103ae3:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ae8:	89 c1                	mov    %eax,%ecx
80103aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103aed:	8b 45 0c             	mov    0xc(%ebp),%eax
80103af0:	01 c2                	add    %eax,%edx
80103af2:	8b 45 08             	mov    0x8(%ebp),%eax
80103af5:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103afa:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103afc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b03:	3b 45 10             	cmp    0x10(%ebp),%eax
80103b06:	7c b0                	jl     80103ab8 <piperead+0x85>
80103b08:	eb 01                	jmp    80103b0b <piperead+0xd8>
      break;
80103b0a:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0e:	05 38 02 00 00       	add    $0x238,%eax
80103b13:	83 ec 0c             	sub    $0xc,%esp
80103b16:	50                   	push   %eax
80103b17:	e8 e5 0a 00 00       	call   80104601 <wakeup>
80103b1c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b22:	83 ec 0c             	sub    $0xc,%esp
80103b25:	50                   	push   %eax
80103b26:	e8 e2 0f 00 00       	call   80104b0d <release>
80103b2b:	83 c4 10             	add    $0x10,%esp
  return i;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b31:	c9                   	leave
80103b32:	c3                   	ret

80103b33 <readeflags>:
{
80103b33:	55                   	push   %ebp
80103b34:	89 e5                	mov    %esp,%ebp
80103b36:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b39:	9c                   	pushf
80103b3a:	58                   	pop    %eax
80103b3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b41:	c9                   	leave
80103b42:	c3                   	ret

80103b43 <sti>:
{
80103b43:	55                   	push   %ebp
80103b44:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103b46:	fb                   	sti
}
80103b47:	90                   	nop
80103b48:	5d                   	pop    %ebp
80103b49:	c3                   	ret

80103b4a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103b4a:	f3 0f 1e fb          	endbr32
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b54:	83 ec 08             	sub    $0x8,%esp
80103b57:	68 5c aa 10 80       	push   $0x8010aa5c
80103b5c:	68 00 55 19 80       	push   $0x80195500
80103b61:	e8 0f 0f 00 00       	call   80104a75 <initlock>
80103b66:	83 c4 10             	add    $0x10,%esp
}
80103b69:	90                   	nop
80103b6a:	c9                   	leave
80103b6b:	c3                   	ret

80103b6c <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b6c:	f3 0f 1e fb          	endbr32
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b76:	e8 10 00 00 00       	call   80103b8b <mycpu>
80103b7b:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b80:	c1 f8 04             	sar    $0x4,%eax
80103b83:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b89:	c9                   	leave
80103b8a:	c3                   	ret

80103b8b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b8b:	f3 0f 1e fb          	endbr32
80103b8f:	55                   	push   %ebp
80103b90:	89 e5                	mov    %esp,%ebp
80103b92:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b95:	e8 99 ff ff ff       	call   80103b33 <readeflags>
80103b9a:	25 00 02 00 00       	and    $0x200,%eax
80103b9f:	85 c0                	test   %eax,%eax
80103ba1:	74 0d                	je     80103bb0 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103ba3:	83 ec 0c             	sub    $0xc,%esp
80103ba6:	68 64 aa 10 80       	push   $0x8010aa64
80103bab:	e8 2e ca ff ff       	call   801005de <panic>
  }

  apicid = lapicid();
80103bb0:	e8 a8 f0 ff ff       	call   80102c5d <lapicid>
80103bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103bb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bbf:	eb 2d                	jmp    80103bee <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bca:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bcf:	0f b6 00             	movzbl (%eax),%eax
80103bd2:	0f b6 c0             	movzbl %al,%eax
80103bd5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103bd8:	75 10                	jne    80103bea <mycpu+0x5f>
      return &cpus[i];
80103bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103be3:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103be8:	eb 1b                	jmp    80103c05 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103bea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bee:	a1 80 80 19 80       	mov    0x80198080,%eax
80103bf3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bf6:	7c c9                	jl     80103bc1 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103bf8:	83 ec 0c             	sub    $0xc,%esp
80103bfb:	68 8a aa 10 80       	push   $0x8010aa8a
80103c00:	e8 d9 c9 ff ff       	call   801005de <panic>
}
80103c05:	c9                   	leave
80103c06:	c3                   	ret

80103c07 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103c07:	f3 0f 1e fb          	endbr32
80103c0b:	55                   	push   %ebp
80103c0c:	89 e5                	mov    %esp,%ebp
80103c0e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103c11:	e8 01 10 00 00       	call   80104c17 <pushcli>
  c = mycpu();
80103c16:	e8 70 ff ff ff       	call   80103b8b <mycpu>
80103c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103c2a:	e8 39 10 00 00       	call   80104c68 <popcli>
  return p;
80103c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c32:	c9                   	leave
80103c33:	c3                   	ret

80103c34 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103c34:	f3 0f 1e fb          	endbr32
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	68 00 55 19 80       	push   $0x80195500
80103c46:	e8 50 0e 00 00       	call   80104a9b <acquire>
80103c4b:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c4e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c55:	eb 0e                	jmp    80103c65 <allocproc+0x31>
    if(p->state == UNUSED){
80103c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5a:	8b 40 0c             	mov    0xc(%eax),%eax
80103c5d:	85 c0                	test   %eax,%eax
80103c5f:	74 27                	je     80103c88 <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c61:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c65:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c6c:	72 e9                	jb     80103c57 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c6e:	83 ec 0c             	sub    $0xc,%esp
80103c71:	68 00 55 19 80       	push   $0x80195500
80103c76:	e8 92 0e 00 00       	call   80104b0d <release>
80103c7b:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c7e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c83:	e9 b6 00 00 00       	jmp    80103d3e <allocproc+0x10a>
      goto found;
80103c88:	90                   	nop
80103c89:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c90:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c97:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c9c:	8d 50 01             	lea    0x1(%eax),%edx
80103c9f:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ca8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103cab:	83 ec 0c             	sub    $0xc,%esp
80103cae:	68 00 55 19 80       	push   $0x80195500
80103cb3:	e8 55 0e 00 00       	call   80104b0d <release>
80103cb8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103cbb:	e8 30 ec ff ff       	call   801028f0 <kalloc>
80103cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cc3:	89 42 08             	mov    %eax,0x8(%edx)
80103cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc9:	8b 40 08             	mov    0x8(%eax),%eax
80103ccc:	85 c0                	test   %eax,%eax
80103cce:	75 11                	jne    80103ce1 <allocproc+0xad>
    p->state = UNUSED;
80103cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103cda:	b8 00 00 00 00       	mov    $0x0,%eax
80103cdf:	eb 5d                	jmp    80103d3e <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce4:	8b 40 08             	mov    0x8(%eax),%eax
80103ce7:	05 00 10 00 00       	add    $0x1000,%eax
80103cec:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103cef:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cf9:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103cfc:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103d00:	ba c3 62 10 80       	mov    $0x801062c3,%edx
80103d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d08:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d0a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d14:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d1d:	83 ec 04             	sub    $0x4,%esp
80103d20:	6a 14                	push   $0x14
80103d22:	6a 00                	push   $0x0
80103d24:	50                   	push   %eax
80103d25:	e8 00 10 00 00       	call   80104d2a <memset>
80103d2a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d30:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d33:	ba c8 44 10 80       	mov    $0x801044c8,%edx
80103d38:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d3e:	c9                   	leave
80103d3f:	c3                   	ret

80103d40 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d40:	f3 0f 1e fb          	endbr32
80103d44:	55                   	push   %ebp
80103d45:	89 e5                	mov    %esp,%ebp
80103d47:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103d4a:	83 ec 0c             	sub    $0xc,%esp
80103d4d:	68 9a aa 10 80       	push   $0x8010aa9a
80103d52:	e8 b5 c6 ff ff       	call   8010040c <cprintf>
80103d57:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d5a:	e8 d5 fe ff ff       	call   80103c34 <allocproc>
80103d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d65:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d6a:	e8 cc 3b 00 00       	call   8010793b <setupkvm>
80103d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d72:	89 42 04             	mov    %eax,0x4(%edx)
80103d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d78:	8b 40 04             	mov    0x4(%eax),%eax
80103d7b:	85 c0                	test   %eax,%eax
80103d7d:	75 0d                	jne    80103d8c <userinit+0x4c>
    panic("userinit: out of memory?");
80103d7f:	83 ec 0c             	sub    $0xc,%esp
80103d82:	68 aa aa 10 80       	push   $0x8010aaaa
80103d87:	e8 52 c8 ff ff       	call   801005de <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d8c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d94:	8b 40 04             	mov    0x4(%eax),%eax
80103d97:	83 ec 04             	sub    $0x4,%esp
80103d9a:	52                   	push   %edx
80103d9b:	68 ec f4 10 80       	push   $0x8010f4ec
80103da0:	50                   	push   %eax
80103da1:	e8 62 3e 00 00       	call   80107c08 <inituvm>
80103da6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dac:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db5:	8b 40 18             	mov    0x18(%eax),%eax
80103db8:	83 ec 04             	sub    $0x4,%esp
80103dbb:	6a 4c                	push   $0x4c
80103dbd:	6a 00                	push   $0x0
80103dbf:	50                   	push   %eax
80103dc0:	e8 65 0f 00 00       	call   80104d2a <memset>
80103dc5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcb:	8b 40 18             	mov    0x18(%eax),%eax
80103dce:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd7:	8b 40 18             	mov    0x18(%eax),%eax
80103dda:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de3:	8b 50 18             	mov    0x18(%eax),%edx
80103de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de9:	8b 40 18             	mov    0x18(%eax),%eax
80103dec:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103df0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df7:	8b 50 18             	mov    0x18(%eax),%edx
80103dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfd:	8b 40 18             	mov    0x18(%eax),%eax
80103e00:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e04:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0b:	8b 40 18             	mov    0x18(%eax),%eax
80103e0e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e18:	8b 40 18             	mov    0x18(%eax),%eax
80103e1b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e25:	8b 40 18             	mov    0x18(%eax),%eax
80103e28:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e32:	83 c0 6c             	add    $0x6c,%eax
80103e35:	83 ec 04             	sub    $0x4,%esp
80103e38:	6a 10                	push   $0x10
80103e3a:	68 c3 aa 10 80       	push   $0x8010aac3
80103e3f:	50                   	push   %eax
80103e40:	e8 00 11 00 00       	call   80104f45 <safestrcpy>
80103e45:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e48:	83 ec 0c             	sub    $0xc,%esp
80103e4b:	68 cc aa 10 80       	push   $0x8010aacc
80103e50:	e8 f0 e7 ff ff       	call   80102645 <namei>
80103e55:	83 c4 10             	add    $0x10,%esp
80103e58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e5b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e5e:	83 ec 0c             	sub    $0xc,%esp
80103e61:	68 00 55 19 80       	push   $0x80195500
80103e66:	e8 30 0c 00 00       	call   80104a9b <acquire>
80103e6b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e71:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	68 00 55 19 80       	push   $0x80195500
80103e80:	e8 88 0c 00 00       	call   80104b0d <release>
80103e85:	83 c4 10             	add    $0x10,%esp
}
80103e88:	90                   	nop
80103e89:	c9                   	leave
80103e8a:	c3                   	ret

80103e8b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e8b:	f3 0f 1e fb          	endbr32
80103e8f:	55                   	push   %ebp
80103e90:	89 e5                	mov    %esp,%ebp
80103e92:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e95:	e8 6d fd ff ff       	call   80103c07 <myproc>
80103e9a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea0:	8b 00                	mov    (%eax),%eax
80103ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ea5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ea9:	7e 2e                	jle    80103ed9 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eab:	8b 55 08             	mov    0x8(%ebp),%edx
80103eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb1:	01 c2                	add    %eax,%edx
80103eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb6:	8b 40 04             	mov    0x4(%eax),%eax
80103eb9:	83 ec 04             	sub    $0x4,%esp
80103ebc:	52                   	push   %edx
80103ebd:	ff 75 f4             	push   -0xc(%ebp)
80103ec0:	50                   	push   %eax
80103ec1:	e8 87 3e 00 00       	call   80107d4d <allocuvm>
80103ec6:	83 c4 10             	add    $0x10,%esp
80103ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ecc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ed0:	75 3b                	jne    80103f0d <growproc+0x82>
      return -1;
80103ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ed7:	eb 4f                	jmp    80103f28 <growproc+0x9d>
  } else if(n < 0){
80103ed9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103edd:	79 2e                	jns    80103f0d <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103edf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee5:	01 c2                	add    %eax,%edx
80103ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eea:	8b 40 04             	mov    0x4(%eax),%eax
80103eed:	83 ec 04             	sub    $0x4,%esp
80103ef0:	52                   	push   %edx
80103ef1:	ff 75 f4             	push   -0xc(%ebp)
80103ef4:	50                   	push   %eax
80103ef5:	e8 5c 3f 00 00       	call   80107e56 <deallocuvm>
80103efa:	83 c4 10             	add    $0x10,%esp
80103efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f04:	75 07                	jne    80103f0d <growproc+0x82>
      return -1;
80103f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f0b:	eb 1b                	jmp    80103f28 <growproc+0x9d>
  }
  curproc->sz = sz;
80103f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f13:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f15:	83 ec 0c             	sub    $0xc,%esp
80103f18:	ff 75 f0             	push   -0x10(%ebp)
80103f1b:	e8 45 3b 00 00       	call   80107a65 <switchuvm>
80103f20:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f28:	c9                   	leave
80103f29:	c3                   	ret

80103f2a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f2a:	f3 0f 1e fb          	endbr32
80103f2e:	55                   	push   %ebp
80103f2f:	89 e5                	mov    %esp,%ebp
80103f31:	57                   	push   %edi
80103f32:	56                   	push   %esi
80103f33:	53                   	push   %ebx
80103f34:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f37:	e8 cb fc ff ff       	call   80103c07 <myproc>
80103f3c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f3f:	e8 f0 fc ff ff       	call   80103c34 <allocproc>
80103f44:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f47:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f4b:	75 0a                	jne    80103f57 <fork+0x2d>
    return -1;
80103f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f52:	e9 48 01 00 00       	jmp    8010409f <fork+0x175>
  } 
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f5a:	8b 10                	mov    (%eax),%edx
80103f5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f5f:	8b 40 04             	mov    0x4(%eax),%eax
80103f62:	83 ec 08             	sub    $0x8,%esp
80103f65:	52                   	push   %edx
80103f66:	50                   	push   %eax
80103f67:	e8 94 40 00 00       	call   80108000 <copyuvm>
80103f6c:	83 c4 10             	add    $0x10,%esp
80103f6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f72:	89 42 04             	mov    %eax,0x4(%edx)
80103f75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f78:	8b 40 04             	mov    0x4(%eax),%eax
80103f7b:	85 c0                	test   %eax,%eax
80103f7d:	75 30                	jne    80103faf <fork+0x85>
    kfree(np->kstack);
80103f7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f82:	8b 40 08             	mov    0x8(%eax),%eax
80103f85:	83 ec 0c             	sub    $0xc,%esp
80103f88:	50                   	push   %eax
80103f89:	e8 c4 e8 ff ff       	call   80102852 <kfree>
80103f8e:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f94:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f9e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103faa:	e9 f0 00 00 00       	jmp    8010409f <fork+0x175>
  }
  np->sz = curproc->sz;
80103faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fb2:	8b 10                	mov    (%eax),%edx
80103fb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fb7:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fbc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103fbf:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fc5:	8b 48 18             	mov    0x18(%eax),%ecx
80103fc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fcb:	8b 40 18             	mov    0x18(%eax),%eax
80103fce:	89 c2                	mov    %eax,%edx
80103fd0:	89 cb                	mov    %ecx,%ebx
80103fd2:	b8 13 00 00 00       	mov    $0x13,%eax
80103fd7:	89 d7                	mov    %edx,%edi
80103fd9:	89 de                	mov    %ebx,%esi
80103fdb:	89 c1                	mov    %eax,%ecx
80103fdd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103fdf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe2:	8b 40 18             	mov    0x18(%eax),%eax
80103fe5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103fec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103ff3:	eb 3b                	jmp    80104030 <fork+0x106>
    if(curproc->ofile[i])
80103ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ffb:	83 c2 08             	add    $0x8,%edx
80103ffe:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104002:	85 c0                	test   %eax,%eax
80104004:	74 26                	je     8010402c <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104006:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010400c:	83 c2 08             	add    $0x8,%edx
8010400f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104013:	83 ec 0c             	sub    $0xc,%esp
80104016:	50                   	push   %eax
80104017:	e8 d6 d0 ff ff       	call   801010f2 <filedup>
8010401c:	83 c4 10             	add    $0x10,%esp
8010401f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104022:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104025:	83 c1 08             	add    $0x8,%ecx
80104028:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010402c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104030:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104034:	7e bf                	jle    80103ff5 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104039:	8b 40 68             	mov    0x68(%eax),%eax
8010403c:	83 ec 0c             	sub    $0xc,%esp
8010403f:	50                   	push   %eax
80104040:	e8 57 da ff ff       	call   80101a9c <idup>
80104045:	83 c4 10             	add    $0x10,%esp
80104048:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010404b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010404e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104051:	8d 50 6c             	lea    0x6c(%eax),%edx
80104054:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104057:	83 c0 6c             	add    $0x6c,%eax
8010405a:	83 ec 04             	sub    $0x4,%esp
8010405d:	6a 10                	push   $0x10
8010405f:	52                   	push   %edx
80104060:	50                   	push   %eax
80104061:	e8 df 0e 00 00       	call   80104f45 <safestrcpy>
80104066:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104069:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010406c:	8b 40 10             	mov    0x10(%eax),%eax
8010406f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104072:	83 ec 0c             	sub    $0xc,%esp
80104075:	68 00 55 19 80       	push   $0x80195500
8010407a:	e8 1c 0a 00 00       	call   80104a9b <acquire>
8010407f:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104082:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104085:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010408c:	83 ec 0c             	sub    $0xc,%esp
8010408f:	68 00 55 19 80       	push   $0x80195500
80104094:	e8 74 0a 00 00       	call   80104b0d <release>
80104099:	83 c4 10             	add    $0x10,%esp
  return pid;
8010409c:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010409f:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040a2:	5b                   	pop    %ebx
801040a3:	5e                   	pop    %esi
801040a4:	5f                   	pop    %edi
801040a5:	5d                   	pop    %ebp
801040a6:	c3                   	ret

801040a7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801040a7:	f3 0f 1e fb          	endbr32
801040ab:	55                   	push   %ebp
801040ac:	89 e5                	mov    %esp,%ebp
801040ae:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801040b1:	e8 51 fb ff ff       	call   80103c07 <myproc>
801040b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801040b9:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801040be:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040c1:	75 0d                	jne    801040d0 <exit+0x29>
    panic("init exiting");
801040c3:	83 ec 0c             	sub    $0xc,%esp
801040c6:	68 ce aa 10 80       	push   $0x8010aace
801040cb:	e8 0e c5 ff ff       	call   801005de <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801040d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801040d7:	eb 3f                	jmp    80104118 <exit+0x71>
    if(curproc->ofile[fd]){
801040d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040df:	83 c2 08             	add    $0x8,%edx
801040e2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040e6:	85 c0                	test   %eax,%eax
801040e8:	74 2a                	je     80104114 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801040ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040f0:	83 c2 08             	add    $0x8,%edx
801040f3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040f7:	83 ec 0c             	sub    $0xc,%esp
801040fa:	50                   	push   %eax
801040fb:	e8 47 d0 ff ff       	call   80101147 <fileclose>
80104100:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104106:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104109:	83 c2 08             	add    $0x8,%edx
8010410c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104113:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104114:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104118:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010411c:	7e bb                	jle    801040d9 <exit+0x32>
    }
  }

  begin_op();
8010411e:	e8 ac f0 ff ff       	call   801031cf <begin_op>
  iput(curproc->cwd);
80104123:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104126:	8b 40 68             	mov    0x68(%eax),%eax
80104129:	83 ec 0c             	sub    $0xc,%esp
8010412c:	50                   	push   %eax
8010412d:	e8 11 db ff ff       	call   80101c43 <iput>
80104132:	83 c4 10             	add    $0x10,%esp
  end_op();
80104135:	e8 25 f1 ff ff       	call   8010325f <end_op>
  curproc->cwd = 0;
8010413a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010413d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104144:	83 ec 0c             	sub    $0xc,%esp
80104147:	68 00 55 19 80       	push   $0x80195500
8010414c:	e8 4a 09 00 00       	call   80104a9b <acquire>
80104151:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104157:	8b 40 14             	mov    0x14(%eax),%eax
8010415a:	83 ec 0c             	sub    $0xc,%esp
8010415d:	50                   	push   %eax
8010415e:	e8 5a 04 00 00       	call   801045bd <wakeup1>
80104163:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104166:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010416d:	eb 37                	jmp    801041a6 <exit+0xff>
    if(p->parent == curproc){
8010416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104172:	8b 40 14             	mov    0x14(%eax),%eax
80104175:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104178:	75 28                	jne    801041a2 <exit+0xfb>
      p->parent = initproc;
8010417a:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104189:	8b 40 0c             	mov    0xc(%eax),%eax
8010418c:	83 f8 05             	cmp    $0x5,%eax
8010418f:	75 11                	jne    801041a2 <exit+0xfb>
        wakeup1(initproc);
80104191:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104196:	83 ec 0c             	sub    $0xc,%esp
80104199:	50                   	push   %eax
8010419a:	e8 1e 04 00 00       	call   801045bd <wakeup1>
8010419f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041a2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041a6:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801041ad:	72 c0                	jb     8010416f <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801041af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b2:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801041b9:	e8 0f 02 00 00       	call   801043cd <sched>
  panic("zombie exit");
801041be:	83 ec 0c             	sub    $0xc,%esp
801041c1:	68 db aa 10 80       	push   $0x8010aadb
801041c6:	e8 13 c4 ff ff       	call   801005de <panic>

801041cb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801041cb:	f3 0f 1e fb          	endbr32
801041cf:	55                   	push   %ebp
801041d0:	89 e5                	mov    %esp,%ebp
801041d2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801041d5:	e8 2d fa ff ff       	call   80103c07 <myproc>
801041da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801041dd:	83 ec 0c             	sub    $0xc,%esp
801041e0:	68 00 55 19 80       	push   $0x80195500
801041e5:	e8 b1 08 00 00       	call   80104a9b <acquire>
801041ea:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801041ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041f4:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801041fb:	e9 a1 00 00 00       	jmp    801042a1 <wait+0xd6>
      if(p->parent != curproc)
80104200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104203:	8b 40 14             	mov    0x14(%eax),%eax
80104206:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104209:	0f 85 8d 00 00 00    	jne    8010429c <wait+0xd1>
        continue;
      havekids = 1;
8010420f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104219:	8b 40 0c             	mov    0xc(%eax),%eax
8010421c:	83 f8 05             	cmp    $0x5,%eax
8010421f:	75 7c                	jne    8010429d <wait+0xd2>
        // Found one.
        pid = p->pid;
80104221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104224:	8b 40 10             	mov    0x10(%eax),%eax
80104227:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010422a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422d:	8b 40 08             	mov    0x8(%eax),%eax
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	50                   	push   %eax
80104234:	e8 19 e6 ff ff       	call   80102852 <kfree>
80104239:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010423c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104249:	8b 40 04             	mov    0x4(%eax),%eax
8010424c:	83 ec 0c             	sub    $0xc,%esp
8010424f:	50                   	push   %eax
80104250:	e8 c9 3c 00 00       	call   80107f1e <freevm>
80104255:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010426c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104276:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010427d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104280:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104287:	83 ec 0c             	sub    $0xc,%esp
8010428a:	68 00 55 19 80       	push   $0x80195500
8010428f:	e8 79 08 00 00       	call   80104b0d <release>
80104294:	83 c4 10             	add    $0x10,%esp
        return pid;
80104297:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010429a:	eb 51                	jmp    801042ed <wait+0x122>
        continue;
8010429c:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010429d:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042a1:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801042a8:	0f 82 52 ff ff ff    	jb     80104200 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801042ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042b2:	74 0a                	je     801042be <wait+0xf3>
801042b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042b7:	8b 40 24             	mov    0x24(%eax),%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	74 17                	je     801042d5 <wait+0x10a>
      release(&ptable.lock);
801042be:	83 ec 0c             	sub    $0xc,%esp
801042c1:	68 00 55 19 80       	push   $0x80195500
801042c6:	e8 42 08 00 00       	call   80104b0d <release>
801042cb:	83 c4 10             	add    $0x10,%esp
      return -1;
801042ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d3:	eb 18                	jmp    801042ed <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801042d5:	83 ec 08             	sub    $0x8,%esp
801042d8:	68 00 55 19 80       	push   $0x80195500
801042dd:	ff 75 ec             	push   -0x14(%ebp)
801042e0:	e8 2d 02 00 00       	call   80104512 <sleep>
801042e5:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801042e8:	e9 00 ff ff ff       	jmp    801041ed <wait+0x22>
  }
}
801042ed:	c9                   	leave
801042ee:	c3                   	ret

801042ef <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801042ef:	f3 0f 1e fb          	endbr32
801042f3:	55                   	push   %ebp
801042f4:	89 e5                	mov    %esp,%ebp
801042f6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801042f9:	e8 8d f8 ff ff       	call   80103b8b <mycpu>
801042fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104301:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104304:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010430b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010430e:	e8 30 f8 ff ff       	call   80103b43 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104313:	83 ec 0c             	sub    $0xc,%esp
80104316:	68 00 55 19 80       	push   $0x80195500
8010431b:	e8 7b 07 00 00       	call   80104a9b <acquire>
80104320:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104323:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010432a:	eb 61                	jmp    8010438d <scheduler+0x9e>
      if(p->state != RUNNABLE)
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432f:	8b 40 0c             	mov    0xc(%eax),%eax
80104332:	83 f8 03             	cmp    $0x3,%eax
80104335:	75 51                	jne    80104388 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010433d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104343:	83 ec 0c             	sub    $0xc,%esp
80104346:	ff 75 f4             	push   -0xc(%ebp)
80104349:	e8 17 37 00 00       	call   80107a65 <switchuvm>
8010434e:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104354:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104361:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104364:	83 c2 04             	add    $0x4,%edx
80104367:	83 ec 08             	sub    $0x8,%esp
8010436a:	50                   	push   %eax
8010436b:	52                   	push   %edx
8010436c:	e8 4d 0c 00 00       	call   80104fbe <swtch>
80104371:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104374:	e8 cf 36 00 00       	call   80107a48 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010437c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104383:	00 00 00 
80104386:	eb 01                	jmp    80104389 <scheduler+0x9a>
        continue;
80104388:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104389:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010438d:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104394:	72 96                	jb     8010432c <scheduler+0x3d>
    }
    release(&ptable.lock);
80104396:	83 ec 0c             	sub    $0xc,%esp
80104399:	68 00 55 19 80       	push   $0x80195500
8010439e:	e8 6a 07 00 00       	call   80104b0d <release>
801043a3:	83 c4 10             	add    $0x10,%esp
    sti();
801043a6:	e9 63 ff ff ff       	jmp    8010430e <scheduler+0x1f>

801043ab <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
801043ab:	f3 0f 1e fb          	endbr32
801043af:	55                   	push   %ebp
801043b0:	89 e5                	mov    %esp,%ebp
801043b2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043b5:	e8 4d f8 ff ff       	call   80103c07 <myproc>
801043ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
801043bd:	8b 55 08             	mov    0x8(%ebp),%edx
801043c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c3:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
801043c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043cb:	c9                   	leave
801043cc:	c3                   	ret

801043cd <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801043cd:	f3 0f 1e fb          	endbr32
801043d1:	55                   	push   %ebp
801043d2:	89 e5                	mov    %esp,%ebp
801043d4:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801043d7:	e8 2b f8 ff ff       	call   80103c07 <myproc>
801043dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801043df:	83 ec 0c             	sub    $0xc,%esp
801043e2:	68 00 55 19 80       	push   $0x80195500
801043e7:	e8 f6 07 00 00       	call   80104be2 <holding>
801043ec:	83 c4 10             	add    $0x10,%esp
801043ef:	85 c0                	test   %eax,%eax
801043f1:	75 0d                	jne    80104400 <sched+0x33>
    panic("sched ptable.lock");
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	68 e7 aa 10 80       	push   $0x8010aae7
801043fb:	e8 de c1 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
80104400:	e8 86 f7 ff ff       	call   80103b8b <mycpu>
80104405:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010440b:	83 f8 01             	cmp    $0x1,%eax
8010440e:	74 0d                	je     8010441d <sched+0x50>
    panic("sched locks");
80104410:	83 ec 0c             	sub    $0xc,%esp
80104413:	68 f9 aa 10 80       	push   $0x8010aaf9
80104418:	e8 c1 c1 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
8010441d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104420:	8b 40 0c             	mov    0xc(%eax),%eax
80104423:	83 f8 04             	cmp    $0x4,%eax
80104426:	75 0d                	jne    80104435 <sched+0x68>
    panic("sched running");
80104428:	83 ec 0c             	sub    $0xc,%esp
8010442b:	68 05 ab 10 80       	push   $0x8010ab05
80104430:	e8 a9 c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
80104435:	e8 f9 f6 ff ff       	call   80103b33 <readeflags>
8010443a:	25 00 02 00 00       	and    $0x200,%eax
8010443f:	85 c0                	test   %eax,%eax
80104441:	74 0d                	je     80104450 <sched+0x83>
    panic("sched interruptible");
80104443:	83 ec 0c             	sub    $0xc,%esp
80104446:	68 13 ab 10 80       	push   $0x8010ab13
8010444b:	e8 8e c1 ff ff       	call   801005de <panic>
  intena = mycpu()->intena;
80104450:	e8 36 f7 ff ff       	call   80103b8b <mycpu>
80104455:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010445b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010445e:	e8 28 f7 ff ff       	call   80103b8b <mycpu>
80104463:	8b 40 04             	mov    0x4(%eax),%eax
80104466:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104469:	83 c2 1c             	add    $0x1c,%edx
8010446c:	83 ec 08             	sub    $0x8,%esp
8010446f:	50                   	push   %eax
80104470:	52                   	push   %edx
80104471:	e8 48 0b 00 00       	call   80104fbe <swtch>
80104476:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104479:	e8 0d f7 ff ff       	call   80103b8b <mycpu>
8010447e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104481:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104487:	90                   	nop
80104488:	c9                   	leave
80104489:	c3                   	ret

8010448a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010448a:	f3 0f 1e fb          	endbr32
8010448e:	55                   	push   %ebp
8010448f:	89 e5                	mov    %esp,%ebp
80104491:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104494:	83 ec 0c             	sub    $0xc,%esp
80104497:	68 00 55 19 80       	push   $0x80195500
8010449c:	e8 fa 05 00 00       	call   80104a9b <acquire>
801044a1:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044a4:	e8 5e f7 ff ff       	call   80103c07 <myproc>
801044a9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044b0:	e8 18 ff ff ff       	call   801043cd <sched>
  release(&ptable.lock);
801044b5:	83 ec 0c             	sub    $0xc,%esp
801044b8:	68 00 55 19 80       	push   $0x80195500
801044bd:	e8 4b 06 00 00       	call   80104b0d <release>
801044c2:	83 c4 10             	add    $0x10,%esp
}
801044c5:	90                   	nop
801044c6:	c9                   	leave
801044c7:	c3                   	ret

801044c8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801044c8:	f3 0f 1e fb          	endbr32
801044cc:	55                   	push   %ebp
801044cd:	89 e5                	mov    %esp,%ebp
801044cf:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044d2:	83 ec 0c             	sub    $0xc,%esp
801044d5:	68 00 55 19 80       	push   $0x80195500
801044da:	e8 2e 06 00 00       	call   80104b0d <release>
801044df:	83 c4 10             	add    $0x10,%esp

  if (first) {
801044e2:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801044e7:	85 c0                	test   %eax,%eax
801044e9:	74 24                	je     8010450f <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801044eb:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801044f2:	00 00 00 
    iinit(ROOTDEV);
801044f5:	83 ec 0c             	sub    $0xc,%esp
801044f8:	6a 01                	push   $0x1
801044fa:	e8 55 d2 ff ff       	call   80101754 <iinit>
801044ff:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104502:	83 ec 0c             	sub    $0xc,%esp
80104505:	6a 01                	push   $0x1
80104507:	e8 90 ea ff ff       	call   80102f9c <initlog>
8010450c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010450f:	90                   	nop
80104510:	c9                   	leave
80104511:	c3                   	ret

80104512 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104512:	f3 0f 1e fb          	endbr32
80104516:	55                   	push   %ebp
80104517:	89 e5                	mov    %esp,%ebp
80104519:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010451c:	e8 e6 f6 ff ff       	call   80103c07 <myproc>
80104521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104528:	75 0d                	jne    80104537 <sleep+0x25>
    panic("sleep");
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	68 27 ab 10 80       	push   $0x8010ab27
80104532:	e8 a7 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
80104537:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010453b:	75 0d                	jne    8010454a <sleep+0x38>
    panic("sleep without lk");
8010453d:	83 ec 0c             	sub    $0xc,%esp
80104540:	68 2d ab 10 80       	push   $0x8010ab2d
80104545:	e8 94 c0 ff ff       	call   801005de <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010454a:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104551:	74 1e                	je     80104571 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104553:	83 ec 0c             	sub    $0xc,%esp
80104556:	68 00 55 19 80       	push   $0x80195500
8010455b:	e8 3b 05 00 00       	call   80104a9b <acquire>
80104560:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	ff 75 0c             	push   0xc(%ebp)
80104569:	e8 9f 05 00 00       	call   80104b0d <release>
8010456e:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104574:	8b 55 08             	mov    0x8(%ebp),%edx
80104577:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010457a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104584:	e8 44 fe ff ff       	call   801043cd <sched>

  // Tidy up.
  p->chan = 0;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104593:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010459a:	74 1e                	je     801045ba <sleep+0xa8>
    release(&ptable.lock);
8010459c:	83 ec 0c             	sub    $0xc,%esp
8010459f:	68 00 55 19 80       	push   $0x80195500
801045a4:	e8 64 05 00 00       	call   80104b0d <release>
801045a9:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045ac:	83 ec 0c             	sub    $0xc,%esp
801045af:	ff 75 0c             	push   0xc(%ebp)
801045b2:	e8 e4 04 00 00       	call   80104a9b <acquire>
801045b7:	83 c4 10             	add    $0x10,%esp
  }
}
801045ba:	90                   	nop
801045bb:	c9                   	leave
801045bc:	c3                   	ret

801045bd <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045bd:	f3 0f 1e fb          	endbr32
801045c1:	55                   	push   %ebp
801045c2:	89 e5                	mov    %esp,%ebp
801045c4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045c7:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801045ce:	eb 24                	jmp    801045f4 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
801045d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045d3:	8b 40 0c             	mov    0xc(%eax),%eax
801045d6:	83 f8 02             	cmp    $0x2,%eax
801045d9:	75 15                	jne    801045f0 <wakeup1+0x33>
801045db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045de:	8b 40 20             	mov    0x20(%eax),%eax
801045e1:	39 45 08             	cmp    %eax,0x8(%ebp)
801045e4:	75 0a                	jne    801045f0 <wakeup1+0x33>
      p->state = RUNNABLE;
801045e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045e9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045f0:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801045f4:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
801045fb:	72 d3                	jb     801045d0 <wakeup1+0x13>
}
801045fd:	90                   	nop
801045fe:	90                   	nop
801045ff:	c9                   	leave
80104600:	c3                   	ret

80104601 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104601:	f3 0f 1e fb          	endbr32
80104605:	55                   	push   %ebp
80104606:	89 e5                	mov    %esp,%ebp
80104608:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010460b:	83 ec 0c             	sub    $0xc,%esp
8010460e:	68 00 55 19 80       	push   $0x80195500
80104613:	e8 83 04 00 00       	call   80104a9b <acquire>
80104618:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	ff 75 08             	push   0x8(%ebp)
80104621:	e8 97 ff ff ff       	call   801045bd <wakeup1>
80104626:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104629:	83 ec 0c             	sub    $0xc,%esp
8010462c:	68 00 55 19 80       	push   $0x80195500
80104631:	e8 d7 04 00 00       	call   80104b0d <release>
80104636:	83 c4 10             	add    $0x10,%esp
}
80104639:	90                   	nop
8010463a:	c9                   	leave
8010463b:	c3                   	ret

8010463c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010463c:	f3 0f 1e fb          	endbr32
80104640:	55                   	push   %ebp
80104641:	89 e5                	mov    %esp,%ebp
80104643:	83 ec 18             	sub    $0x18,%esp
  cprintf("kill\n");
80104646:	83 ec 0c             	sub    $0xc,%esp
80104649:	68 3e ab 10 80       	push   $0x8010ab3e
8010464e:	e8 b9 bd ff ff       	call   8010040c <cprintf>
80104653:	83 c4 10             	add    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 00 55 19 80       	push   $0x80195500
8010465e:	e8 38 04 00 00       	call   80104a9b <acquire>
80104663:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104666:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010466d:	eb 45                	jmp    801046b4 <kill+0x78>
    if(p->pid == pid){
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	8b 40 10             	mov    0x10(%eax),%eax
80104675:	39 45 08             	cmp    %eax,0x8(%ebp)
80104678:	75 36                	jne    801046b0 <kill+0x74>
      p->killed = 1;
8010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104687:	8b 40 0c             	mov    0xc(%eax),%eax
8010468a:	83 f8 02             	cmp    $0x2,%eax
8010468d:	75 0a                	jne    80104699 <kill+0x5d>
        p->state = RUNNABLE;
8010468f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104692:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104699:	83 ec 0c             	sub    $0xc,%esp
8010469c:	68 00 55 19 80       	push   $0x80195500
801046a1:	e8 67 04 00 00       	call   80104b0d <release>
801046a6:	83 c4 10             	add    $0x10,%esp
      return 0;
801046a9:	b8 00 00 00 00       	mov    $0x0,%eax
801046ae:	eb 22                	jmp    801046d2 <kill+0x96>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046b0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046b4:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801046bb:	72 b2                	jb     8010466f <kill+0x33>
    }
  }
  release(&ptable.lock);
801046bd:	83 ec 0c             	sub    $0xc,%esp
801046c0:	68 00 55 19 80       	push   $0x80195500
801046c5:	e8 43 04 00 00       	call   80104b0d <release>
801046ca:	83 c4 10             	add    $0x10,%esp
  return -1;
801046cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046d2:	c9                   	leave
801046d3:	c3                   	ret

801046d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046d4:	f3 0f 1e fb          	endbr32
801046d8:	55                   	push   %ebp
801046d9:	89 e5                	mov    %esp,%ebp
801046db:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046de:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801046e5:	e9 d7 00 00 00       	jmp    801047c1 <procdump+0xed>
    if(p->state == UNUSED)
801046ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ed:	8b 40 0c             	mov    0xc(%eax),%eax
801046f0:	85 c0                	test   %eax,%eax
801046f2:	0f 84 c4 00 00 00    	je     801047bc <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fb:	8b 40 0c             	mov    0xc(%eax),%eax
801046fe:	83 f8 05             	cmp    $0x5,%eax
80104701:	77 23                	ja     80104726 <procdump+0x52>
80104703:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104706:	8b 40 0c             	mov    0xc(%eax),%eax
80104709:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104710:	85 c0                	test   %eax,%eax
80104712:	74 12                	je     80104726 <procdump+0x52>
      state = states[p->state];
80104714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104717:	8b 40 0c             	mov    0xc(%eax),%eax
8010471a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104721:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104724:	eb 07                	jmp    8010472d <procdump+0x59>
    else
      state = "???";
80104726:	c7 45 ec 44 ab 10 80 	movl   $0x8010ab44,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010472d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104730:	8d 50 6c             	lea    0x6c(%eax),%edx
80104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104736:	8b 40 10             	mov    0x10(%eax),%eax
80104739:	52                   	push   %edx
8010473a:	ff 75 ec             	push   -0x14(%ebp)
8010473d:	50                   	push   %eax
8010473e:	68 48 ab 10 80       	push   $0x8010ab48
80104743:	e8 c4 bc ff ff       	call   8010040c <cprintf>
80104748:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010474b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474e:	8b 40 0c             	mov    0xc(%eax),%eax
80104751:	83 f8 02             	cmp    $0x2,%eax
80104754:	75 54                	jne    801047aa <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104759:	8b 40 1c             	mov    0x1c(%eax),%eax
8010475c:	8b 40 0c             	mov    0xc(%eax),%eax
8010475f:	83 c0 08             	add    $0x8,%eax
80104762:	89 c2                	mov    %eax,%edx
80104764:	83 ec 08             	sub    $0x8,%esp
80104767:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010476a:	50                   	push   %eax
8010476b:	52                   	push   %edx
8010476c:	e8 f2 03 00 00       	call   80104b63 <getcallerpcs>
80104771:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010477b:	eb 1c                	jmp    80104799 <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104780:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104784:	83 ec 08             	sub    $0x8,%esp
80104787:	50                   	push   %eax
80104788:	68 51 ab 10 80       	push   $0x8010ab51
8010478d:	e8 7a bc ff ff       	call   8010040c <cprintf>
80104792:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104795:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104799:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010479d:	7f 0b                	jg     801047aa <procdump+0xd6>
8010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047a6:	85 c0                	test   %eax,%eax
801047a8:	75 d3                	jne    8010477d <procdump+0xa9>
    }
    cprintf("\n");
801047aa:	83 ec 0c             	sub    $0xc,%esp
801047ad:	68 55 ab 10 80       	push   $0x8010ab55
801047b2:	e8 55 bc ff ff       	call   8010040c <cprintf>
801047b7:	83 c4 10             	add    $0x10,%esp
801047ba:	eb 01                	jmp    801047bd <procdump+0xe9>
      continue;
801047bc:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047bd:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801047c1:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
801047c8:	0f 82 1c ff ff ff    	jb     801046ea <procdump+0x16>
  }
}
801047ce:	90                   	nop
801047cf:	90                   	nop
801047d0:	c9                   	leave
801047d1:	c3                   	ret

801047d2 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
801047d2:	f3 0f 1e fb          	endbr32
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	53                   	push   %ebx
801047da:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047dd:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801047e4:	eb 0f                	jmp    801047f5 <printpt+0x23>
    if (p->pid == pid)
801047e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e9:	8b 40 10             	mov    0x10(%eax),%eax
801047ec:	39 45 08             	cmp    %eax,0x8(%ebp)
801047ef:	74 0f                	je     80104800 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047f1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801047f5:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801047fc:	72 e8                	jb     801047e6 <printpt+0x14>
801047fe:	eb 01                	jmp    80104801 <printpt+0x2f>
      break;
80104800:	90                   	nop
  }
  if (p == 0){
80104801:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104805:	75 1a                	jne    80104821 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
80104807:	83 ec 0c             	sub    $0xc,%esp
8010480a:	68 57 ab 10 80       	push   $0x8010ab57
8010480f:	e8 f8 bb ff ff       	call   8010040c <cprintf>
80104814:	83 c4 10             	add    $0x10,%esp
    return -1;
80104817:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010481c:	e9 e2 00 00 00       	jmp    80104903 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
80104821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104824:	8b 40 04             	mov    0x4(%eax),%eax
80104827:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
8010482a:	83 ec 08             	sub    $0x8,%esp
8010482d:	ff 75 08             	push   0x8(%ebp)
80104830:	68 73 ab 10 80       	push   $0x8010ab73
80104835:	e8 d2 bb ff ff       	call   8010040c <cprintf>
8010483a:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010483d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104844:	e9 9a 00 00 00       	jmp    801048e3 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
80104849:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010484c:	83 ec 04             	sub    $0x4,%esp
8010484f:	6a 00                	push   $0x0
80104851:	50                   	push   %eax
80104852:	ff 75 ec             	push   -0x14(%ebp)
80104855:	e8 b3 2f 00 00       	call   8010780d <walkpgdir>
8010485a:	83 c4 10             	add    $0x10,%esp
8010485d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
80104860:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104863:	8b 00                	mov    (%eax),%eax
80104865:	83 e0 01             	and    $0x1,%eax
80104868:	85 c0                	test   %eax,%eax
8010486a:	74 6f                	je     801048db <printpt+0x109>
8010486c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104870:	74 69                	je     801048db <printpt+0x109>
    cprintf("pte: %x\n",pte);
80104872:	83 ec 08             	sub    $0x8,%esp
80104875:	ff 75 e8             	push   -0x18(%ebp)
80104878:	68 8f ab 10 80       	push   $0x8010ab8f
8010487d:	e8 8a bb ff ff       	call   8010040c <cprintf>
80104882:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104885:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104888:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
8010488a:	c1 e8 0c             	shr    $0xc,%eax
8010488d:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
8010488f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104892:	8b 00                	mov    (%eax),%eax
80104894:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
80104897:	85 c0                	test   %eax,%eax
80104899:	74 07                	je     801048a2 <printpt+0xd0>
8010489b:	bb 57 00 00 00       	mov    $0x57,%ebx
801048a0:	eb 05                	jmp    801048a7 <printpt+0xd5>
801048a2:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801048a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048aa:	8b 00                	mov    (%eax),%eax
801048ac:	83 e0 04             	and    $0x4,%eax
801048af:	85 c0                	test   %eax,%eax
801048b1:	74 07                	je     801048ba <printpt+0xe8>
801048b3:	b9 55 00 00 00       	mov    $0x55,%ecx
801048b8:	eb 05                	jmp    801048bf <printpt+0xed>
801048ba:	b9 4b 00 00 00       	mov    $0x4b,%ecx
801048bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c2:	c1 e8 0c             	shr    $0xc,%eax
801048c5:	83 ec 0c             	sub    $0xc,%esp
801048c8:	52                   	push   %edx
801048c9:	53                   	push   %ebx
801048ca:	51                   	push   %ecx
801048cb:	50                   	push   %eax
801048cc:	68 98 ab 10 80       	push   $0x8010ab98
801048d1:	e8 36 bb ff ff       	call   8010040c <cprintf>
801048d6:	83 c4 20             	add    $0x20,%esp
801048d9:	eb 01                	jmp    801048dc <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
801048db:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
801048dc:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801048e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e6:	85 c0                	test   %eax,%eax
801048e8:	0f 89 5b ff ff ff    	jns    80104849 <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	68 a7 ab 10 80       	push   $0x8010aba7
801048f6:	e8 11 bb ff ff       	call   8010040c <cprintf>
801048fb:	83 c4 10             	add    $0x10,%esp
  return 0;
801048fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104906:	c9                   	leave
80104907:	c3                   	ret

80104908 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104908:	f3 0f 1e fb          	endbr32
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104912:	8b 45 08             	mov    0x8(%ebp),%eax
80104915:	83 c0 04             	add    $0x4,%eax
80104918:	83 ec 08             	sub    $0x8,%esp
8010491b:	68 e1 ab 10 80       	push   $0x8010abe1
80104920:	50                   	push   %eax
80104921:	e8 4f 01 00 00       	call   80104a75 <initlock>
80104926:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104929:	8b 45 08             	mov    0x8(%ebp),%eax
8010492c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010492f:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104932:	8b 45 08             	mov    0x8(%ebp),%eax
80104935:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010493b:	8b 45 08             	mov    0x8(%ebp),%eax
8010493e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104945:	90                   	nop
80104946:	c9                   	leave
80104947:	c3                   	ret

80104948 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104948:	f3 0f 1e fb          	endbr32
8010494c:	55                   	push   %ebp
8010494d:	89 e5                	mov    %esp,%ebp
8010494f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104952:	8b 45 08             	mov    0x8(%ebp),%eax
80104955:	83 c0 04             	add    $0x4,%eax
80104958:	83 ec 0c             	sub    $0xc,%esp
8010495b:	50                   	push   %eax
8010495c:	e8 3a 01 00 00       	call   80104a9b <acquire>
80104961:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104964:	eb 15                	jmp    8010497b <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104966:	8b 45 08             	mov    0x8(%ebp),%eax
80104969:	83 c0 04             	add    $0x4,%eax
8010496c:	83 ec 08             	sub    $0x8,%esp
8010496f:	50                   	push   %eax
80104970:	ff 75 08             	push   0x8(%ebp)
80104973:	e8 9a fb ff ff       	call   80104512 <sleep>
80104978:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010497b:	8b 45 08             	mov    0x8(%ebp),%eax
8010497e:	8b 00                	mov    (%eax),%eax
80104980:	85 c0                	test   %eax,%eax
80104982:	75 e2                	jne    80104966 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104984:	8b 45 08             	mov    0x8(%ebp),%eax
80104987:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010498d:	e8 75 f2 ff ff       	call   80103c07 <myproc>
80104992:	8b 50 10             	mov    0x10(%eax),%edx
80104995:	8b 45 08             	mov    0x8(%ebp),%eax
80104998:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	83 c0 04             	add    $0x4,%eax
801049a1:	83 ec 0c             	sub    $0xc,%esp
801049a4:	50                   	push   %eax
801049a5:	e8 63 01 00 00       	call   80104b0d <release>
801049aa:	83 c4 10             	add    $0x10,%esp
}
801049ad:	90                   	nop
801049ae:	c9                   	leave
801049af:	c3                   	ret

801049b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801049b0:	f3 0f 1e fb          	endbr32
801049b4:	55                   	push   %ebp
801049b5:	89 e5                	mov    %esp,%ebp
801049b7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049ba:	8b 45 08             	mov    0x8(%ebp),%eax
801049bd:	83 c0 04             	add    $0x4,%eax
801049c0:	83 ec 0c             	sub    $0xc,%esp
801049c3:	50                   	push   %eax
801049c4:	e8 d2 00 00 00       	call   80104a9b <acquire>
801049c9:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801049cc:	8b 45 08             	mov    0x8(%ebp),%eax
801049cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801049df:	83 ec 0c             	sub    $0xc,%esp
801049e2:	ff 75 08             	push   0x8(%ebp)
801049e5:	e8 17 fc ff ff       	call   80104601 <wakeup>
801049ea:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801049ed:	8b 45 08             	mov    0x8(%ebp),%eax
801049f0:	83 c0 04             	add    $0x4,%eax
801049f3:	83 ec 0c             	sub    $0xc,%esp
801049f6:	50                   	push   %eax
801049f7:	e8 11 01 00 00       	call   80104b0d <release>
801049fc:	83 c4 10             	add    $0x10,%esp
}
801049ff:	90                   	nop
80104a00:	c9                   	leave
80104a01:	c3                   	ret

80104a02 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a02:	f3 0f 1e fb          	endbr32
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0f:	83 c0 04             	add    $0x4,%eax
80104a12:	83 ec 0c             	sub    $0xc,%esp
80104a15:	50                   	push   %eax
80104a16:	e8 80 00 00 00       	call   80104a9b <acquire>
80104a1b:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a21:	8b 00                	mov    (%eax),%eax
80104a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a26:	8b 45 08             	mov    0x8(%ebp),%eax
80104a29:	83 c0 04             	add    $0x4,%eax
80104a2c:	83 ec 0c             	sub    $0xc,%esp
80104a2f:	50                   	push   %eax
80104a30:	e8 d8 00 00 00       	call   80104b0d <release>
80104a35:	83 c4 10             	add    $0x10,%esp
  return r;
80104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a3b:	c9                   	leave
80104a3c:	c3                   	ret

80104a3d <readeflags>:
{
80104a3d:	55                   	push   %ebp
80104a3e:	89 e5                	mov    %esp,%ebp
80104a40:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a43:	9c                   	pushf
80104a44:	58                   	pop    %eax
80104a45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a4b:	c9                   	leave
80104a4c:	c3                   	ret

80104a4d <cli>:
{
80104a4d:	55                   	push   %ebp
80104a4e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a50:	fa                   	cli
}
80104a51:	90                   	nop
80104a52:	5d                   	pop    %ebp
80104a53:	c3                   	ret

80104a54 <sti>:
{
80104a54:	55                   	push   %ebp
80104a55:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a57:	fb                   	sti
}
80104a58:	90                   	nop
80104a59:	5d                   	pop    %ebp
80104a5a:	c3                   	ret

80104a5b <xchg>:
{
80104a5b:	55                   	push   %ebp
80104a5c:	89 e5                	mov    %esp,%ebp
80104a5e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a61:	8b 55 08             	mov    0x8(%ebp),%edx
80104a64:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a6a:	f0 87 02             	lock xchg %eax,(%edx)
80104a6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a73:	c9                   	leave
80104a74:	c3                   	ret

80104a75 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a75:	f3 0f 1e fb          	endbr32
80104a79:	55                   	push   %ebp
80104a7a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a82:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a85:	8b 45 08             	mov    0x8(%ebp),%eax
80104a88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a98:	90                   	nop
80104a99:	5d                   	pop    %ebp
80104a9a:	c3                   	ret

80104a9b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a9b:	f3 0f 1e fb          	endbr32
80104a9f:	55                   	push   %ebp
80104aa0:	89 e5                	mov    %esp,%ebp
80104aa2:	53                   	push   %ebx
80104aa3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104aa6:	e8 6c 01 00 00       	call   80104c17 <pushcli>
  if(holding(lk)){
80104aab:	8b 45 08             	mov    0x8(%ebp),%eax
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	50                   	push   %eax
80104ab2:	e8 2b 01 00 00       	call   80104be2 <holding>
80104ab7:	83 c4 10             	add    $0x10,%esp
80104aba:	85 c0                	test   %eax,%eax
80104abc:	74 0d                	je     80104acb <acquire+0x30>
    panic("acquire");
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	68 ec ab 10 80       	push   $0x8010abec
80104ac6:	e8 13 bb ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104acb:	90                   	nop
80104acc:	8b 45 08             	mov    0x8(%ebp),%eax
80104acf:	83 ec 08             	sub    $0x8,%esp
80104ad2:	6a 01                	push   $0x1
80104ad4:	50                   	push   %eax
80104ad5:	e8 81 ff ff ff       	call   80104a5b <xchg>
80104ada:	83 c4 10             	add    $0x10,%esp
80104add:	85 c0                	test   %eax,%eax
80104adf:	75 eb                	jne    80104acc <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104ae1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104ae6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104ae9:	e8 9d f0 ff ff       	call   80103b8b <mycpu>
80104aee:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104af1:	8b 45 08             	mov    0x8(%ebp),%eax
80104af4:	83 c0 0c             	add    $0xc,%eax
80104af7:	83 ec 08             	sub    $0x8,%esp
80104afa:	50                   	push   %eax
80104afb:	8d 45 08             	lea    0x8(%ebp),%eax
80104afe:	50                   	push   %eax
80104aff:	e8 5f 00 00 00       	call   80104b63 <getcallerpcs>
80104b04:	83 c4 10             	add    $0x10,%esp
}
80104b07:	90                   	nop
80104b08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b0b:	c9                   	leave
80104b0c:	c3                   	ret

80104b0d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b0d:	f3 0f 1e fb          	endbr32
80104b11:	55                   	push   %ebp
80104b12:	89 e5                	mov    %esp,%ebp
80104b14:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b17:	83 ec 0c             	sub    $0xc,%esp
80104b1a:	ff 75 08             	push   0x8(%ebp)
80104b1d:	e8 c0 00 00 00       	call   80104be2 <holding>
80104b22:	83 c4 10             	add    $0x10,%esp
80104b25:	85 c0                	test   %eax,%eax
80104b27:	75 0d                	jne    80104b36 <release+0x29>
    panic("release");
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	68 f4 ab 10 80       	push   $0x8010abf4
80104b31:	e8 a8 ba ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104b36:	8b 45 08             	mov    0x8(%ebp),%eax
80104b39:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b40:	8b 45 08             	mov    0x8(%ebp),%eax
80104b43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b4a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	8b 55 08             	mov    0x8(%ebp),%edx
80104b55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b5b:	e8 08 01 00 00       	call   80104c68 <popcli>
}
80104b60:	90                   	nop
80104b61:	c9                   	leave
80104b62:	c3                   	ret

80104b63 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b63:	f3 0f 1e fb          	endbr32
80104b67:	55                   	push   %ebp
80104b68:	89 e5                	mov    %esp,%ebp
80104b6a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b70:	83 e8 08             	sub    $0x8,%eax
80104b73:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b76:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b7d:	eb 38                	jmp    80104bb7 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b7f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b83:	74 53                	je     80104bd8 <getcallerpcs+0x75>
80104b85:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b8c:	76 4a                	jbe    80104bd8 <getcallerpcs+0x75>
80104b8e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104b92:	74 44                	je     80104bd8 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104b94:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba1:	01 c2                	add    %eax,%edx
80104ba3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba6:	8b 40 04             	mov    0x4(%eax),%eax
80104ba9:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bae:	8b 00                	mov    (%eax),%eax
80104bb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bb3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bb7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bbb:	7e c2                	jle    80104b7f <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104bbd:	eb 19                	jmp    80104bd8 <getcallerpcs+0x75>
    pcs[i] = 0;
80104bbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bcc:	01 d0                	add    %edx,%eax
80104bce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104bd4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bd8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bdc:	7e e1                	jle    80104bbf <getcallerpcs+0x5c>
}
80104bde:	90                   	nop
80104bdf:	90                   	nop
80104be0:	c9                   	leave
80104be1:	c3                   	ret

80104be2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104be2:	f3 0f 1e fb          	endbr32
80104be6:	55                   	push   %ebp
80104be7:	89 e5                	mov    %esp,%ebp
80104be9:	53                   	push   %ebx
80104bea:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104bed:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf0:	8b 00                	mov    (%eax),%eax
80104bf2:	85 c0                	test   %eax,%eax
80104bf4:	74 16                	je     80104c0c <holding+0x2a>
80104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf9:	8b 58 08             	mov    0x8(%eax),%ebx
80104bfc:	e8 8a ef ff ff       	call   80103b8b <mycpu>
80104c01:	39 c3                	cmp    %eax,%ebx
80104c03:	75 07                	jne    80104c0c <holding+0x2a>
80104c05:	b8 01 00 00 00       	mov    $0x1,%eax
80104c0a:	eb 05                	jmp    80104c11 <holding+0x2f>
80104c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c11:	83 c4 04             	add    $0x4,%esp
80104c14:	5b                   	pop    %ebx
80104c15:	5d                   	pop    %ebp
80104c16:	c3                   	ret

80104c17 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c17:	f3 0f 1e fb          	endbr32
80104c1b:	55                   	push   %ebp
80104c1c:	89 e5                	mov    %esp,%ebp
80104c1e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c21:	e8 17 fe ff ff       	call   80104a3d <readeflags>
80104c26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c29:	e8 1f fe ff ff       	call   80104a4d <cli>
  if(mycpu()->ncli == 0)
80104c2e:	e8 58 ef ff ff       	call   80103b8b <mycpu>
80104c33:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c39:	85 c0                	test   %eax,%eax
80104c3b:	75 14                	jne    80104c51 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104c3d:	e8 49 ef ff ff       	call   80103b8b <mycpu>
80104c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c45:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c4b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c51:	e8 35 ef ff ff       	call   80103b8b <mycpu>
80104c56:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c5c:	83 c2 01             	add    $0x1,%edx
80104c5f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c65:	90                   	nop
80104c66:	c9                   	leave
80104c67:	c3                   	ret

80104c68 <popcli>:

void
popcli(void)
{
80104c68:	f3 0f 1e fb          	endbr32
80104c6c:	55                   	push   %ebp
80104c6d:	89 e5                	mov    %esp,%ebp
80104c6f:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c72:	e8 c6 fd ff ff       	call   80104a3d <readeflags>
80104c77:	25 00 02 00 00       	and    $0x200,%eax
80104c7c:	85 c0                	test   %eax,%eax
80104c7e:	74 0d                	je     80104c8d <popcli+0x25>
    panic("popcli - interruptible");
80104c80:	83 ec 0c             	sub    $0xc,%esp
80104c83:	68 fc ab 10 80       	push   $0x8010abfc
80104c88:	e8 51 b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104c8d:	e8 f9 ee ff ff       	call   80103b8b <mycpu>
80104c92:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c98:	83 ea 01             	sub    $0x1,%edx
80104c9b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104ca1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ca7:	85 c0                	test   %eax,%eax
80104ca9:	79 0d                	jns    80104cb8 <popcli+0x50>
    panic("popcli");
80104cab:	83 ec 0c             	sub    $0xc,%esp
80104cae:	68 13 ac 10 80       	push   $0x8010ac13
80104cb3:	e8 26 b9 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104cb8:	e8 ce ee ff ff       	call   80103b8b <mycpu>
80104cbd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cc3:	85 c0                	test   %eax,%eax
80104cc5:	75 14                	jne    80104cdb <popcli+0x73>
80104cc7:	e8 bf ee ff ff       	call   80103b8b <mycpu>
80104ccc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104cd2:	85 c0                	test   %eax,%eax
80104cd4:	74 05                	je     80104cdb <popcli+0x73>
    sti();
80104cd6:	e8 79 fd ff ff       	call   80104a54 <sti>
}
80104cdb:	90                   	nop
80104cdc:	c9                   	leave
80104cdd:	c3                   	ret

80104cde <stosb>:
{
80104cde:	55                   	push   %ebp
80104cdf:	89 e5                	mov    %esp,%ebp
80104ce1:	57                   	push   %edi
80104ce2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ce6:	8b 55 10             	mov    0x10(%ebp),%edx
80104ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cec:	89 cb                	mov    %ecx,%ebx
80104cee:	89 df                	mov    %ebx,%edi
80104cf0:	89 d1                	mov    %edx,%ecx
80104cf2:	fc                   	cld
80104cf3:	f3 aa                	rep stos %al,%es:(%edi)
80104cf5:	89 ca                	mov    %ecx,%edx
80104cf7:	89 fb                	mov    %edi,%ebx
80104cf9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cfc:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104cff:	90                   	nop
80104d00:	5b                   	pop    %ebx
80104d01:	5f                   	pop    %edi
80104d02:	5d                   	pop    %ebp
80104d03:	c3                   	ret

80104d04 <stosl>:
{
80104d04:	55                   	push   %ebp
80104d05:	89 e5                	mov    %esp,%ebp
80104d07:	57                   	push   %edi
80104d08:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d0c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d12:	89 cb                	mov    %ecx,%ebx
80104d14:	89 df                	mov    %ebx,%edi
80104d16:	89 d1                	mov    %edx,%ecx
80104d18:	fc                   	cld
80104d19:	f3 ab                	rep stos %eax,%es:(%edi)
80104d1b:	89 ca                	mov    %ecx,%edx
80104d1d:	89 fb                	mov    %edi,%ebx
80104d1f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d22:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d25:	90                   	nop
80104d26:	5b                   	pop    %ebx
80104d27:	5f                   	pop    %edi
80104d28:	5d                   	pop    %ebp
80104d29:	c3                   	ret

80104d2a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d2a:	f3 0f 1e fb          	endbr32
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d31:	8b 45 08             	mov    0x8(%ebp),%eax
80104d34:	83 e0 03             	and    $0x3,%eax
80104d37:	85 c0                	test   %eax,%eax
80104d39:	75 43                	jne    80104d7e <memset+0x54>
80104d3b:	8b 45 10             	mov    0x10(%ebp),%eax
80104d3e:	83 e0 03             	and    $0x3,%eax
80104d41:	85 c0                	test   %eax,%eax
80104d43:	75 39                	jne    80104d7e <memset+0x54>
    c &= 0xFF;
80104d45:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d4c:	8b 45 10             	mov    0x10(%ebp),%eax
80104d4f:	c1 e8 02             	shr    $0x2,%eax
80104d52:	89 c1                	mov    %eax,%ecx
80104d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d57:	c1 e0 18             	shl    $0x18,%eax
80104d5a:	89 c2                	mov    %eax,%edx
80104d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5f:	c1 e0 10             	shl    $0x10,%eax
80104d62:	09 c2                	or     %eax,%edx
80104d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d67:	c1 e0 08             	shl    $0x8,%eax
80104d6a:	09 d0                	or     %edx,%eax
80104d6c:	0b 45 0c             	or     0xc(%ebp),%eax
80104d6f:	51                   	push   %ecx
80104d70:	50                   	push   %eax
80104d71:	ff 75 08             	push   0x8(%ebp)
80104d74:	e8 8b ff ff ff       	call   80104d04 <stosl>
80104d79:	83 c4 0c             	add    $0xc,%esp
80104d7c:	eb 12                	jmp    80104d90 <memset+0x66>
  } else
    stosb(dst, c, n);
80104d7e:	8b 45 10             	mov    0x10(%ebp),%eax
80104d81:	50                   	push   %eax
80104d82:	ff 75 0c             	push   0xc(%ebp)
80104d85:	ff 75 08             	push   0x8(%ebp)
80104d88:	e8 51 ff ff ff       	call   80104cde <stosb>
80104d8d:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d93:	c9                   	leave
80104d94:	c3                   	ret

80104d95 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d95:	f3 0f 1e fb          	endbr32
80104d99:	55                   	push   %ebp
80104d9a:	89 e5                	mov    %esp,%ebp
80104d9c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104da2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104da5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dab:	eb 30                	jmp    80104ddd <memcmp+0x48>
    if(*s1 != *s2)
80104dad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104db0:	0f b6 10             	movzbl (%eax),%edx
80104db3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104db6:	0f b6 00             	movzbl (%eax),%eax
80104db9:	38 c2                	cmp    %al,%dl
80104dbb:	74 18                	je     80104dd5 <memcmp+0x40>
      return *s1 - *s2;
80104dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dc0:	0f b6 00             	movzbl (%eax),%eax
80104dc3:	0f b6 d0             	movzbl %al,%edx
80104dc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dc9:	0f b6 00             	movzbl (%eax),%eax
80104dcc:	0f b6 c0             	movzbl %al,%eax
80104dcf:	29 c2                	sub    %eax,%edx
80104dd1:	89 d0                	mov    %edx,%eax
80104dd3:	eb 1a                	jmp    80104def <memcmp+0x5a>
    s1++, s2++;
80104dd5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104dd9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ddd:	8b 45 10             	mov    0x10(%ebp),%eax
80104de0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104de3:	89 55 10             	mov    %edx,0x10(%ebp)
80104de6:	85 c0                	test   %eax,%eax
80104de8:	75 c3                	jne    80104dad <memcmp+0x18>
  }

  return 0;
80104dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104def:	c9                   	leave
80104df0:	c3                   	ret

80104df1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104df1:	f3 0f 1e fb          	endbr32
80104df5:	55                   	push   %ebp
80104df6:	89 e5                	mov    %esp,%ebp
80104df8:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e01:	8b 45 08             	mov    0x8(%ebp),%eax
80104e04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e0a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e0d:	73 54                	jae    80104e63 <memmove+0x72>
80104e0f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e12:	8b 45 10             	mov    0x10(%ebp),%eax
80104e15:	01 d0                	add    %edx,%eax
80104e17:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e1a:	73 47                	jae    80104e63 <memmove+0x72>
    s += n;
80104e1c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e1f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e22:	8b 45 10             	mov    0x10(%ebp),%eax
80104e25:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e28:	eb 13                	jmp    80104e3d <memmove+0x4c>
      *--d = *--s;
80104e2a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e2e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e35:	0f b6 10             	movzbl (%eax),%edx
80104e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e3b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e3d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e40:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e43:	89 55 10             	mov    %edx,0x10(%ebp)
80104e46:	85 c0                	test   %eax,%eax
80104e48:	75 e0                	jne    80104e2a <memmove+0x39>
  if(s < d && s + n > d){
80104e4a:	eb 24                	jmp    80104e70 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e4c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e4f:	8d 42 01             	lea    0x1(%edx),%eax
80104e52:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e58:	8d 48 01             	lea    0x1(%eax),%ecx
80104e5b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e5e:	0f b6 12             	movzbl (%edx),%edx
80104e61:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e63:	8b 45 10             	mov    0x10(%ebp),%eax
80104e66:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e69:	89 55 10             	mov    %edx,0x10(%ebp)
80104e6c:	85 c0                	test   %eax,%eax
80104e6e:	75 dc                	jne    80104e4c <memmove+0x5b>

  return dst;
80104e70:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e73:	c9                   	leave
80104e74:	c3                   	ret

80104e75 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e75:	f3 0f 1e fb          	endbr32
80104e79:	55                   	push   %ebp
80104e7a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e7c:	ff 75 10             	push   0x10(%ebp)
80104e7f:	ff 75 0c             	push   0xc(%ebp)
80104e82:	ff 75 08             	push   0x8(%ebp)
80104e85:	e8 67 ff ff ff       	call   80104df1 <memmove>
80104e8a:	83 c4 0c             	add    $0xc,%esp
}
80104e8d:	c9                   	leave
80104e8e:	c3                   	ret

80104e8f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e8f:	f3 0f 1e fb          	endbr32
80104e93:	55                   	push   %ebp
80104e94:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104e96:	eb 0c                	jmp    80104ea4 <strncmp+0x15>
    n--, p++, q++;
80104e98:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e9c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ea0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ea4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ea8:	74 1a                	je     80104ec4 <strncmp+0x35>
80104eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80104ead:	0f b6 00             	movzbl (%eax),%eax
80104eb0:	84 c0                	test   %al,%al
80104eb2:	74 10                	je     80104ec4 <strncmp+0x35>
80104eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb7:	0f b6 10             	movzbl (%eax),%edx
80104eba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ebd:	0f b6 00             	movzbl (%eax),%eax
80104ec0:	38 c2                	cmp    %al,%dl
80104ec2:	74 d4                	je     80104e98 <strncmp+0x9>
  if(n == 0)
80104ec4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ec8:	75 07                	jne    80104ed1 <strncmp+0x42>
    return 0;
80104eca:	b8 00 00 00 00       	mov    $0x0,%eax
80104ecf:	eb 16                	jmp    80104ee7 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed4:	0f b6 00             	movzbl (%eax),%eax
80104ed7:	0f b6 d0             	movzbl %al,%edx
80104eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80104edd:	0f b6 00             	movzbl (%eax),%eax
80104ee0:	0f b6 c0             	movzbl %al,%eax
80104ee3:	29 c2                	sub    %eax,%edx
80104ee5:	89 d0                	mov    %edx,%eax
}
80104ee7:	5d                   	pop    %ebp
80104ee8:	c3                   	ret

80104ee9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104ee9:	f3 0f 1e fb          	endbr32
80104eed:	55                   	push   %ebp
80104eee:	89 e5                	mov    %esp,%ebp
80104ef0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104ef9:	90                   	nop
80104efa:	8b 45 10             	mov    0x10(%ebp),%eax
80104efd:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f00:	89 55 10             	mov    %edx,0x10(%ebp)
80104f03:	85 c0                	test   %eax,%eax
80104f05:	7e 2c                	jle    80104f33 <strncpy+0x4a>
80104f07:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f0a:	8d 42 01             	lea    0x1(%edx),%eax
80104f0d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f10:	8b 45 08             	mov    0x8(%ebp),%eax
80104f13:	8d 48 01             	lea    0x1(%eax),%ecx
80104f16:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f19:	0f b6 12             	movzbl (%edx),%edx
80104f1c:	88 10                	mov    %dl,(%eax)
80104f1e:	0f b6 00             	movzbl (%eax),%eax
80104f21:	84 c0                	test   %al,%al
80104f23:	75 d5                	jne    80104efa <strncpy+0x11>
    ;
  while(n-- > 0)
80104f25:	eb 0c                	jmp    80104f33 <strncpy+0x4a>
    *s++ = 0;
80104f27:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2a:	8d 50 01             	lea    0x1(%eax),%edx
80104f2d:	89 55 08             	mov    %edx,0x8(%ebp)
80104f30:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f33:	8b 45 10             	mov    0x10(%ebp),%eax
80104f36:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f39:	89 55 10             	mov    %edx,0x10(%ebp)
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	7f e7                	jg     80104f27 <strncpy+0x3e>
  return os;
80104f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f43:	c9                   	leave
80104f44:	c3                   	ret

80104f45 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f45:	f3 0f 1e fb          	endbr32
80104f49:	55                   	push   %ebp
80104f4a:	89 e5                	mov    %esp,%ebp
80104f4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f59:	7f 05                	jg     80104f60 <safestrcpy+0x1b>
    return os;
80104f5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f5e:	eb 31                	jmp    80104f91 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f68:	7e 1e                	jle    80104f88 <safestrcpy+0x43>
80104f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f6d:	8d 42 01             	lea    0x1(%edx),%eax
80104f70:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f73:	8b 45 08             	mov    0x8(%ebp),%eax
80104f76:	8d 48 01             	lea    0x1(%eax),%ecx
80104f79:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f7c:	0f b6 12             	movzbl (%edx),%edx
80104f7f:	88 10                	mov    %dl,(%eax)
80104f81:	0f b6 00             	movzbl (%eax),%eax
80104f84:	84 c0                	test   %al,%al
80104f86:	75 d8                	jne    80104f60 <safestrcpy+0x1b>
    ;
  *s = 0;
80104f88:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f91:	c9                   	leave
80104f92:	c3                   	ret

80104f93 <strlen>:

int
strlen(const char *s)
{
80104f93:	f3 0f 1e fb          	endbr32
80104f97:	55                   	push   %ebp
80104f98:	89 e5                	mov    %esp,%ebp
80104f9a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104f9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fa4:	eb 04                	jmp    80104faa <strlen+0x17>
80104fa6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104faa:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	01 d0                	add    %edx,%eax
80104fb2:	0f b6 00             	movzbl (%eax),%eax
80104fb5:	84 c0                	test   %al,%al
80104fb7:	75 ed                	jne    80104fa6 <strlen+0x13>
    ;
  return n;
80104fb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fbc:	c9                   	leave
80104fbd:	c3                   	ret

80104fbe <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fbe:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104fc2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104fc6:	55                   	push   %ebp
  pushl %ebx
80104fc7:	53                   	push   %ebx
  pushl %esi
80104fc8:	56                   	push   %esi
  pushl %edi
80104fc9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104fca:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104fcc:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104fce:	5f                   	pop    %edi
  popl %esi
80104fcf:	5e                   	pop    %esi
  popl %ebx
80104fd0:	5b                   	pop    %ebx
  popl %ebp
80104fd1:	5d                   	pop    %ebp
  ret
80104fd2:	c3                   	ret

80104fd3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104fd3:	f3 0f 1e fb          	endbr32
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104fda:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdd:	85 c0                	test   %eax,%eax
80104fdf:	78 0a                	js     80104feb <fetchint+0x18>
80104fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe4:	83 c0 04             	add    $0x4,%eax
80104fe7:	85 c0                	test   %eax,%eax
80104fe9:	79 07                	jns    80104ff2 <fetchint+0x1f>
    return -1;
80104feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff0:	eb 0f                	jmp    80105001 <fetchint+0x2e>
  *ip = *(int*)(addr);
80104ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff5:	8b 10                	mov    (%eax),%edx
80104ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffa:	89 10                	mov    %edx,(%eax)
  return 0;
80104ffc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105001:	5d                   	pop    %ebp
80105002:	c3                   	ret

80105003 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105003:	f3 0f 1e fb          	endbr32
80105007:	55                   	push   %ebp
80105008:	89 e5                	mov    %esp,%ebp
8010500a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
8010500d:	8b 45 08             	mov    0x8(%ebp),%eax
80105010:	85 c0                	test   %eax,%eax
80105012:	79 07                	jns    8010501b <fetchstr+0x18>
    return -1;
80105014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105019:	eb 42                	jmp    8010505d <fetchstr+0x5a>
  *pp = (char*)addr;
8010501b:	8b 55 08             	mov    0x8(%ebp),%edx
8010501e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105021:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80105023:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
8010502a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010502d:	8b 00                	mov    (%eax),%eax
8010502f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105032:	eb 1c                	jmp    80105050 <fetchstr+0x4d>
    if(*s == 0)
80105034:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105037:	0f b6 00             	movzbl (%eax),%eax
8010503a:	84 c0                	test   %al,%al
8010503c:	75 0e                	jne    8010504c <fetchstr+0x49>
      return s - *pp;
8010503e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105041:	8b 00                	mov    (%eax),%eax
80105043:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105046:	29 c2                	sub    %eax,%edx
80105048:	89 d0                	mov    %edx,%eax
8010504a:	eb 11                	jmp    8010505d <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
8010504c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105050:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105053:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105056:	72 dc                	jb     80105034 <fetchstr+0x31>
  }
  return -1;
80105058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010505d:	c9                   	leave
8010505e:	c3                   	ret

8010505f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010505f:	f3 0f 1e fb          	endbr32
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
80105066:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105069:	e8 99 eb ff ff       	call   80103c07 <myproc>
8010506e:	8b 40 18             	mov    0x18(%eax),%eax
80105071:	8b 40 44             	mov    0x44(%eax),%eax
80105074:	8b 55 08             	mov    0x8(%ebp),%edx
80105077:	c1 e2 02             	shl    $0x2,%edx
8010507a:	01 d0                	add    %edx,%eax
8010507c:	83 c0 04             	add    $0x4,%eax
8010507f:	83 ec 08             	sub    $0x8,%esp
80105082:	ff 75 0c             	push   0xc(%ebp)
80105085:	50                   	push   %eax
80105086:	e8 48 ff ff ff       	call   80104fd3 <fetchint>
8010508b:	83 c4 10             	add    $0x10,%esp
}
8010508e:	c9                   	leave
8010508f:	c3                   	ret

80105090 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105090:	f3 0f 1e fb          	endbr32
80105094:	55                   	push   %ebp
80105095:	89 e5                	mov    %esp,%ebp
80105097:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
8010509a:	83 ec 08             	sub    $0x8,%esp
8010509d:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050a0:	50                   	push   %eax
801050a1:	ff 75 08             	push   0x8(%ebp)
801050a4:	e8 b6 ff ff ff       	call   8010505f <argint>
801050a9:	83 c4 10             	add    $0x10,%esp
801050ac:	85 c0                	test   %eax,%eax
801050ae:	79 07                	jns    801050b7 <argptr+0x27>
    return -1;
801050b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b5:	eb 34                	jmp    801050eb <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801050b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050bb:	78 18                	js     801050d5 <argptr+0x45>
801050bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c0:	85 c0                	test   %eax,%eax
801050c2:	78 11                	js     801050d5 <argptr+0x45>
801050c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c7:	89 c2                	mov    %eax,%edx
801050c9:	8b 45 10             	mov    0x10(%ebp),%eax
801050cc:	01 d0                	add    %edx,%eax
801050ce:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801050d3:	76 07                	jbe    801050dc <argptr+0x4c>
    return -1;
801050d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050da:	eb 0f                	jmp    801050eb <argptr+0x5b>
  *pp = (char*)i;
801050dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050df:	89 c2                	mov    %eax,%edx
801050e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e4:	89 10                	mov    %edx,(%eax)
  return 0;
801050e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050eb:	c9                   	leave
801050ec:	c3                   	ret

801050ed <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801050ed:	f3 0f 1e fb          	endbr32
801050f1:	55                   	push   %ebp
801050f2:	89 e5                	mov    %esp,%ebp
801050f4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801050f7:	83 ec 08             	sub    $0x8,%esp
801050fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050fd:	50                   	push   %eax
801050fe:	ff 75 08             	push   0x8(%ebp)
80105101:	e8 59 ff ff ff       	call   8010505f <argint>
80105106:	83 c4 10             	add    $0x10,%esp
80105109:	85 c0                	test   %eax,%eax
8010510b:	79 07                	jns    80105114 <argstr+0x27>
    return -1;
8010510d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105112:	eb 12                	jmp    80105126 <argstr+0x39>
  return fetchstr(addr, pp);
80105114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105117:	83 ec 08             	sub    $0x8,%esp
8010511a:	ff 75 0c             	push   0xc(%ebp)
8010511d:	50                   	push   %eax
8010511e:	e8 e0 fe ff ff       	call   80105003 <fetchstr>
80105123:	83 c4 10             	add    $0x10,%esp
}
80105126:	c9                   	leave
80105127:	c3                   	ret

80105128 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105128:	f3 0f 1e fb          	endbr32
8010512c:	55                   	push   %ebp
8010512d:	89 e5                	mov    %esp,%ebp
8010512f:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105132:	e8 d0 ea ff ff       	call   80103c07 <myproc>
80105137:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010513a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513d:	8b 40 18             	mov    0x18(%eax),%eax
80105140:	8b 40 1c             	mov    0x1c(%eax),%eax
80105143:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105146:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010514a:	7e 2f                	jle    8010517b <syscall+0x53>
8010514c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010514f:	83 f8 17             	cmp    $0x17,%eax
80105152:	77 27                	ja     8010517b <syscall+0x53>
80105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105157:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010515e:	85 c0                	test   %eax,%eax
80105160:	74 19                	je     8010517b <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105165:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010516c:	ff d0                	call   *%eax
8010516e:	89 c2                	mov    %eax,%edx
80105170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105173:	8b 40 18             	mov    0x18(%eax),%eax
80105176:	89 50 1c             	mov    %edx,0x1c(%eax)
80105179:	eb 2c                	jmp    801051a7 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010517b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105184:	8b 40 10             	mov    0x10(%eax),%eax
80105187:	ff 75 f0             	push   -0x10(%ebp)
8010518a:	52                   	push   %edx
8010518b:	50                   	push   %eax
8010518c:	68 1a ac 10 80       	push   $0x8010ac1a
80105191:	e8 76 b2 ff ff       	call   8010040c <cprintf>
80105196:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519c:	8b 40 18             	mov    0x18(%eax),%eax
8010519f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051a6:	90                   	nop
801051a7:	90                   	nop
801051a8:	c9                   	leave
801051a9:	c3                   	ret

801051aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051aa:	f3 0f 1e fb          	endbr32
801051ae:	55                   	push   %ebp
801051af:	89 e5                	mov    %esp,%ebp
801051b1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051b4:	83 ec 08             	sub    $0x8,%esp
801051b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ba:	50                   	push   %eax
801051bb:	ff 75 08             	push   0x8(%ebp)
801051be:	e8 9c fe ff ff       	call   8010505f <argint>
801051c3:	83 c4 10             	add    $0x10,%esp
801051c6:	85 c0                	test   %eax,%eax
801051c8:	79 07                	jns    801051d1 <argfd+0x27>
    return -1;
801051ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051cf:	eb 4f                	jmp    80105220 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d4:	85 c0                	test   %eax,%eax
801051d6:	78 20                	js     801051f8 <argfd+0x4e>
801051d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051db:	83 f8 0f             	cmp    $0xf,%eax
801051de:	7f 18                	jg     801051f8 <argfd+0x4e>
801051e0:	e8 22 ea ff ff       	call   80103c07 <myproc>
801051e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051e8:	83 c2 08             	add    $0x8,%edx
801051eb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051f6:	75 07                	jne    801051ff <argfd+0x55>
    return -1;
801051f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051fd:	eb 21                	jmp    80105220 <argfd+0x76>
  if(pfd)
801051ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105203:	74 08                	je     8010520d <argfd+0x63>
    *pfd = fd;
80105205:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105208:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010520d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105211:	74 08                	je     8010521b <argfd+0x71>
    *pf = f;
80105213:	8b 45 10             	mov    0x10(%ebp),%eax
80105216:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105219:	89 10                	mov    %edx,(%eax)
  return 0;
8010521b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105220:	c9                   	leave
80105221:	c3                   	ret

80105222 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105222:	f3 0f 1e fb          	endbr32
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010522c:	e8 d6 e9 ff ff       	call   80103c07 <myproc>
80105231:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105234:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010523b:	eb 2a                	jmp    80105267 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010523d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105240:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105243:	83 c2 08             	add    $0x8,%edx
80105246:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010524a:	85 c0                	test   %eax,%eax
8010524c:	75 15                	jne    80105263 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010524e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105251:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105254:	8d 4a 08             	lea    0x8(%edx),%ecx
80105257:	8b 55 08             	mov    0x8(%ebp),%edx
8010525a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	eb 0f                	jmp    80105272 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105263:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105267:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010526b:	7e d0                	jle    8010523d <fdalloc+0x1b>
    }
  }
  return -1;
8010526d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105272:	c9                   	leave
80105273:	c3                   	ret

80105274 <sys_dup>:

int
sys_dup(void)
{
80105274:	f3 0f 1e fb          	endbr32
80105278:	55                   	push   %ebp
80105279:	89 e5                	mov    %esp,%ebp
8010527b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010527e:	83 ec 04             	sub    $0x4,%esp
80105281:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105284:	50                   	push   %eax
80105285:	6a 00                	push   $0x0
80105287:	6a 00                	push   $0x0
80105289:	e8 1c ff ff ff       	call   801051aa <argfd>
8010528e:	83 c4 10             	add    $0x10,%esp
80105291:	85 c0                	test   %eax,%eax
80105293:	79 07                	jns    8010529c <sys_dup+0x28>
    return -1;
80105295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529a:	eb 31                	jmp    801052cd <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010529c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529f:	83 ec 0c             	sub    $0xc,%esp
801052a2:	50                   	push   %eax
801052a3:	e8 7a ff ff ff       	call   80105222 <fdalloc>
801052a8:	83 c4 10             	add    $0x10,%esp
801052ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052b2:	79 07                	jns    801052bb <sys_dup+0x47>
    return -1;
801052b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b9:	eb 12                	jmp    801052cd <sys_dup+0x59>
  filedup(f);
801052bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052be:	83 ec 0c             	sub    $0xc,%esp
801052c1:	50                   	push   %eax
801052c2:	e8 2b be ff ff       	call   801010f2 <filedup>
801052c7:	83 c4 10             	add    $0x10,%esp
  return fd;
801052ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052cd:	c9                   	leave
801052ce:	c3                   	ret

801052cf <sys_read>:

int
sys_read(void)
{
801052cf:	f3 0f 1e fb          	endbr32
801052d3:	55                   	push   %ebp
801052d4:	89 e5                	mov    %esp,%ebp
801052d6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052d9:	83 ec 04             	sub    $0x4,%esp
801052dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052df:	50                   	push   %eax
801052e0:	6a 00                	push   $0x0
801052e2:	6a 00                	push   $0x0
801052e4:	e8 c1 fe ff ff       	call   801051aa <argfd>
801052e9:	83 c4 10             	add    $0x10,%esp
801052ec:	85 c0                	test   %eax,%eax
801052ee:	78 2e                	js     8010531e <sys_read+0x4f>
801052f0:	83 ec 08             	sub    $0x8,%esp
801052f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052f6:	50                   	push   %eax
801052f7:	6a 02                	push   $0x2
801052f9:	e8 61 fd ff ff       	call   8010505f <argint>
801052fe:	83 c4 10             	add    $0x10,%esp
80105301:	85 c0                	test   %eax,%eax
80105303:	78 19                	js     8010531e <sys_read+0x4f>
80105305:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105308:	83 ec 04             	sub    $0x4,%esp
8010530b:	50                   	push   %eax
8010530c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010530f:	50                   	push   %eax
80105310:	6a 01                	push   $0x1
80105312:	e8 79 fd ff ff       	call   80105090 <argptr>
80105317:	83 c4 10             	add    $0x10,%esp
8010531a:	85 c0                	test   %eax,%eax
8010531c:	79 07                	jns    80105325 <sys_read+0x56>
    return -1;
8010531e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105323:	eb 17                	jmp    8010533c <sys_read+0x6d>
  return fileread(f, p, n);
80105325:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105328:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010532b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532e:	83 ec 04             	sub    $0x4,%esp
80105331:	51                   	push   %ecx
80105332:	52                   	push   %edx
80105333:	50                   	push   %eax
80105334:	e8 55 bf ff ff       	call   8010128e <fileread>
80105339:	83 c4 10             	add    $0x10,%esp
}
8010533c:	c9                   	leave
8010533d:	c3                   	ret

8010533e <sys_write>:

int
sys_write(void)
{
8010533e:	f3 0f 1e fb          	endbr32
80105342:	55                   	push   %ebp
80105343:	89 e5                	mov    %esp,%ebp
80105345:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105348:	83 ec 04             	sub    $0x4,%esp
8010534b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010534e:	50                   	push   %eax
8010534f:	6a 00                	push   $0x0
80105351:	6a 00                	push   $0x0
80105353:	e8 52 fe ff ff       	call   801051aa <argfd>
80105358:	83 c4 10             	add    $0x10,%esp
8010535b:	85 c0                	test   %eax,%eax
8010535d:	78 2e                	js     8010538d <sys_write+0x4f>
8010535f:	83 ec 08             	sub    $0x8,%esp
80105362:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105365:	50                   	push   %eax
80105366:	6a 02                	push   $0x2
80105368:	e8 f2 fc ff ff       	call   8010505f <argint>
8010536d:	83 c4 10             	add    $0x10,%esp
80105370:	85 c0                	test   %eax,%eax
80105372:	78 19                	js     8010538d <sys_write+0x4f>
80105374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105377:	83 ec 04             	sub    $0x4,%esp
8010537a:	50                   	push   %eax
8010537b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010537e:	50                   	push   %eax
8010537f:	6a 01                	push   $0x1
80105381:	e8 0a fd ff ff       	call   80105090 <argptr>
80105386:	83 c4 10             	add    $0x10,%esp
80105389:	85 c0                	test   %eax,%eax
8010538b:	79 07                	jns    80105394 <sys_write+0x56>
    return -1;
8010538d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105392:	eb 17                	jmp    801053ab <sys_write+0x6d>
  return filewrite(f, p, n);
80105394:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105397:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010539a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539d:	83 ec 04             	sub    $0x4,%esp
801053a0:	51                   	push   %ecx
801053a1:	52                   	push   %edx
801053a2:	50                   	push   %eax
801053a3:	e8 a2 bf ff ff       	call   8010134a <filewrite>
801053a8:	83 c4 10             	add    $0x10,%esp
}
801053ab:	c9                   	leave
801053ac:	c3                   	ret

801053ad <sys_close>:

int
sys_close(void)
{
801053ad:	f3 0f 1e fb          	endbr32
801053b1:	55                   	push   %ebp
801053b2:	89 e5                	mov    %esp,%ebp
801053b4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053b7:	83 ec 04             	sub    $0x4,%esp
801053ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053bd:	50                   	push   %eax
801053be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053c1:	50                   	push   %eax
801053c2:	6a 00                	push   $0x0
801053c4:	e8 e1 fd ff ff       	call   801051aa <argfd>
801053c9:	83 c4 10             	add    $0x10,%esp
801053cc:	85 c0                	test   %eax,%eax
801053ce:	79 07                	jns    801053d7 <sys_close+0x2a>
    return -1;
801053d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d5:	eb 27                	jmp    801053fe <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801053d7:	e8 2b e8 ff ff       	call   80103c07 <myproc>
801053dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053df:	83 c2 08             	add    $0x8,%edx
801053e2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801053e9:	00 
  fileclose(f);
801053ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ed:	83 ec 0c             	sub    $0xc,%esp
801053f0:	50                   	push   %eax
801053f1:	e8 51 bd ff ff       	call   80101147 <fileclose>
801053f6:	83 c4 10             	add    $0x10,%esp
  return 0;
801053f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053fe:	c9                   	leave
801053ff:	c3                   	ret

80105400 <sys_fstat>:

int
sys_fstat(void)
{
80105400:	f3 0f 1e fb          	endbr32
80105404:	55                   	push   %ebp
80105405:	89 e5                	mov    %esp,%ebp
80105407:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010540a:	83 ec 04             	sub    $0x4,%esp
8010540d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105410:	50                   	push   %eax
80105411:	6a 00                	push   $0x0
80105413:	6a 00                	push   $0x0
80105415:	e8 90 fd ff ff       	call   801051aa <argfd>
8010541a:	83 c4 10             	add    $0x10,%esp
8010541d:	85 c0                	test   %eax,%eax
8010541f:	78 17                	js     80105438 <sys_fstat+0x38>
80105421:	83 ec 04             	sub    $0x4,%esp
80105424:	6a 14                	push   $0x14
80105426:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105429:	50                   	push   %eax
8010542a:	6a 01                	push   $0x1
8010542c:	e8 5f fc ff ff       	call   80105090 <argptr>
80105431:	83 c4 10             	add    $0x10,%esp
80105434:	85 c0                	test   %eax,%eax
80105436:	79 07                	jns    8010543f <sys_fstat+0x3f>
    return -1;
80105438:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543d:	eb 13                	jmp    80105452 <sys_fstat+0x52>
  return filestat(f, st);
8010543f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105445:	83 ec 08             	sub    $0x8,%esp
80105448:	52                   	push   %edx
80105449:	50                   	push   %eax
8010544a:	e8 e4 bd ff ff       	call   80101233 <filestat>
8010544f:	83 c4 10             	add    $0x10,%esp
}
80105452:	c9                   	leave
80105453:	c3                   	ret

80105454 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105454:	f3 0f 1e fb          	endbr32
80105458:	55                   	push   %ebp
80105459:	89 e5                	mov    %esp,%ebp
8010545b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010545e:	83 ec 08             	sub    $0x8,%esp
80105461:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105464:	50                   	push   %eax
80105465:	6a 00                	push   $0x0
80105467:	e8 81 fc ff ff       	call   801050ed <argstr>
8010546c:	83 c4 10             	add    $0x10,%esp
8010546f:	85 c0                	test   %eax,%eax
80105471:	78 15                	js     80105488 <sys_link+0x34>
80105473:	83 ec 08             	sub    $0x8,%esp
80105476:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105479:	50                   	push   %eax
8010547a:	6a 01                	push   $0x1
8010547c:	e8 6c fc ff ff       	call   801050ed <argstr>
80105481:	83 c4 10             	add    $0x10,%esp
80105484:	85 c0                	test   %eax,%eax
80105486:	79 0a                	jns    80105492 <sys_link+0x3e>
    return -1;
80105488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010548d:	e9 68 01 00 00       	jmp    801055fa <sys_link+0x1a6>

  begin_op();
80105492:	e8 38 dd ff ff       	call   801031cf <begin_op>
  if((ip = namei(old)) == 0){
80105497:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010549a:	83 ec 0c             	sub    $0xc,%esp
8010549d:	50                   	push   %eax
8010549e:	e8 a2 d1 ff ff       	call   80102645 <namei>
801054a3:	83 c4 10             	add    $0x10,%esp
801054a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ad:	75 0f                	jne    801054be <sys_link+0x6a>
    end_op();
801054af:	e8 ab dd ff ff       	call   8010325f <end_op>
    return -1;
801054b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b9:	e9 3c 01 00 00       	jmp    801055fa <sys_link+0x1a6>
  }

  ilock(ip);
801054be:	83 ec 0c             	sub    $0xc,%esp
801054c1:	ff 75 f4             	push   -0xc(%ebp)
801054c4:	e8 11 c6 ff ff       	call   80101ada <ilock>
801054c9:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801054cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054d3:	66 83 f8 01          	cmp    $0x1,%ax
801054d7:	75 1d                	jne    801054f6 <sys_link+0xa2>
    iunlockput(ip);
801054d9:	83 ec 0c             	sub    $0xc,%esp
801054dc:	ff 75 f4             	push   -0xc(%ebp)
801054df:	e8 33 c8 ff ff       	call   80101d17 <iunlockput>
801054e4:	83 c4 10             	add    $0x10,%esp
    end_op();
801054e7:	e8 73 dd ff ff       	call   8010325f <end_op>
    return -1;
801054ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f1:	e9 04 01 00 00       	jmp    801055fa <sys_link+0x1a6>
  }

  ip->nlink++;
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054fd:	83 c0 01             	add    $0x1,%eax
80105500:	89 c2                	mov    %eax,%edx
80105502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105505:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105509:	83 ec 0c             	sub    $0xc,%esp
8010550c:	ff 75 f4             	push   -0xc(%ebp)
8010550f:	e8 dd c3 ff ff       	call   801018f1 <iupdate>
80105514:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	ff 75 f4             	push   -0xc(%ebp)
8010551d:	e8 cf c6 ff ff       	call   80101bf1 <iunlock>
80105522:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105525:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105528:	83 ec 08             	sub    $0x8,%esp
8010552b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010552e:	52                   	push   %edx
8010552f:	50                   	push   %eax
80105530:	e8 30 d1 ff ff       	call   80102665 <nameiparent>
80105535:	83 c4 10             	add    $0x10,%esp
80105538:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010553b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010553f:	74 71                	je     801055b2 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105541:	83 ec 0c             	sub    $0xc,%esp
80105544:	ff 75 f0             	push   -0x10(%ebp)
80105547:	e8 8e c5 ff ff       	call   80101ada <ilock>
8010554c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010554f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105552:	8b 10                	mov    (%eax),%edx
80105554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105557:	8b 00                	mov    (%eax),%eax
80105559:	39 c2                	cmp    %eax,%edx
8010555b:	75 1d                	jne    8010557a <sys_link+0x126>
8010555d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105560:	8b 40 04             	mov    0x4(%eax),%eax
80105563:	83 ec 04             	sub    $0x4,%esp
80105566:	50                   	push   %eax
80105567:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010556a:	50                   	push   %eax
8010556b:	ff 75 f0             	push   -0x10(%ebp)
8010556e:	e8 2f ce ff ff       	call   801023a2 <dirlink>
80105573:	83 c4 10             	add    $0x10,%esp
80105576:	85 c0                	test   %eax,%eax
80105578:	79 10                	jns    8010558a <sys_link+0x136>
    iunlockput(dp);
8010557a:	83 ec 0c             	sub    $0xc,%esp
8010557d:	ff 75 f0             	push   -0x10(%ebp)
80105580:	e8 92 c7 ff ff       	call   80101d17 <iunlockput>
80105585:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105588:	eb 29                	jmp    801055b3 <sys_link+0x15f>
  }
  iunlockput(dp);
8010558a:	83 ec 0c             	sub    $0xc,%esp
8010558d:	ff 75 f0             	push   -0x10(%ebp)
80105590:	e8 82 c7 ff ff       	call   80101d17 <iunlockput>
80105595:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105598:	83 ec 0c             	sub    $0xc,%esp
8010559b:	ff 75 f4             	push   -0xc(%ebp)
8010559e:	e8 a0 c6 ff ff       	call   80101c43 <iput>
801055a3:	83 c4 10             	add    $0x10,%esp

  end_op();
801055a6:	e8 b4 dc ff ff       	call   8010325f <end_op>

  return 0;
801055ab:	b8 00 00 00 00       	mov    $0x0,%eax
801055b0:	eb 48                	jmp    801055fa <sys_link+0x1a6>
    goto bad;
801055b2:	90                   	nop

bad:
  ilock(ip);
801055b3:	83 ec 0c             	sub    $0xc,%esp
801055b6:	ff 75 f4             	push   -0xc(%ebp)
801055b9:	e8 1c c5 ff ff       	call   80101ada <ilock>
801055be:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055c8:	83 e8 01             	sub    $0x1,%eax
801055cb:	89 c2                	mov    %eax,%edx
801055cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055d4:	83 ec 0c             	sub    $0xc,%esp
801055d7:	ff 75 f4             	push   -0xc(%ebp)
801055da:	e8 12 c3 ff ff       	call   801018f1 <iupdate>
801055df:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801055e2:	83 ec 0c             	sub    $0xc,%esp
801055e5:	ff 75 f4             	push   -0xc(%ebp)
801055e8:	e8 2a c7 ff ff       	call   80101d17 <iunlockput>
801055ed:	83 c4 10             	add    $0x10,%esp
  end_op();
801055f0:	e8 6a dc ff ff       	call   8010325f <end_op>
  return -1;
801055f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055fa:	c9                   	leave
801055fb:	c3                   	ret

801055fc <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801055fc:	f3 0f 1e fb          	endbr32
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105606:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010560d:	eb 40                	jmp    8010564f <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010560f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105612:	6a 10                	push   $0x10
80105614:	50                   	push   %eax
80105615:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105618:	50                   	push   %eax
80105619:	ff 75 08             	push   0x8(%ebp)
8010561c:	e8 c1 c9 ff ff       	call   80101fe2 <readi>
80105621:	83 c4 10             	add    $0x10,%esp
80105624:	83 f8 10             	cmp    $0x10,%eax
80105627:	74 0d                	je     80105636 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105629:	83 ec 0c             	sub    $0xc,%esp
8010562c:	68 36 ac 10 80       	push   $0x8010ac36
80105631:	e8 a8 af ff ff       	call   801005de <panic>
    if(de.inum != 0)
80105636:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010563a:	66 85 c0             	test   %ax,%ax
8010563d:	74 07                	je     80105646 <isdirempty+0x4a>
      return 0;
8010563f:	b8 00 00 00 00       	mov    $0x0,%eax
80105644:	eb 1b                	jmp    80105661 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105649:	83 c0 10             	add    $0x10,%eax
8010564c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010564f:	8b 45 08             	mov    0x8(%ebp),%eax
80105652:	8b 50 58             	mov    0x58(%eax),%edx
80105655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105658:	39 c2                	cmp    %eax,%edx
8010565a:	77 b3                	ja     8010560f <isdirempty+0x13>
  }
  return 1;
8010565c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105661:	c9                   	leave
80105662:	c3                   	ret

80105663 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105663:	f3 0f 1e fb          	endbr32
80105667:	55                   	push   %ebp
80105668:	89 e5                	mov    %esp,%ebp
8010566a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010566d:	83 ec 08             	sub    $0x8,%esp
80105670:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105673:	50                   	push   %eax
80105674:	6a 00                	push   $0x0
80105676:	e8 72 fa ff ff       	call   801050ed <argstr>
8010567b:	83 c4 10             	add    $0x10,%esp
8010567e:	85 c0                	test   %eax,%eax
80105680:	79 0a                	jns    8010568c <sys_unlink+0x29>
    return -1;
80105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105687:	e9 bf 01 00 00       	jmp    8010584b <sys_unlink+0x1e8>

  begin_op();
8010568c:	e8 3e db ff ff       	call   801031cf <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105691:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105694:	83 ec 08             	sub    $0x8,%esp
80105697:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010569a:	52                   	push   %edx
8010569b:	50                   	push   %eax
8010569c:	e8 c4 cf ff ff       	call   80102665 <nameiparent>
801056a1:	83 c4 10             	add    $0x10,%esp
801056a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ab:	75 0f                	jne    801056bc <sys_unlink+0x59>
    end_op();
801056ad:	e8 ad db ff ff       	call   8010325f <end_op>
    return -1;
801056b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b7:	e9 8f 01 00 00       	jmp    8010584b <sys_unlink+0x1e8>
  }

  ilock(dp);
801056bc:	83 ec 0c             	sub    $0xc,%esp
801056bf:	ff 75 f4             	push   -0xc(%ebp)
801056c2:	e8 13 c4 ff ff       	call   80101ada <ilock>
801056c7:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056ca:	83 ec 08             	sub    $0x8,%esp
801056cd:	68 48 ac 10 80       	push   $0x8010ac48
801056d2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056d5:	50                   	push   %eax
801056d6:	e8 ea cb ff ff       	call   801022c5 <namecmp>
801056db:	83 c4 10             	add    $0x10,%esp
801056de:	85 c0                	test   %eax,%eax
801056e0:	0f 84 49 01 00 00    	je     8010582f <sys_unlink+0x1cc>
801056e6:	83 ec 08             	sub    $0x8,%esp
801056e9:	68 4a ac 10 80       	push   $0x8010ac4a
801056ee:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056f1:	50                   	push   %eax
801056f2:	e8 ce cb ff ff       	call   801022c5 <namecmp>
801056f7:	83 c4 10             	add    $0x10,%esp
801056fa:	85 c0                	test   %eax,%eax
801056fc:	0f 84 2d 01 00 00    	je     8010582f <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105702:	83 ec 04             	sub    $0x4,%esp
80105705:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105708:	50                   	push   %eax
80105709:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010570c:	50                   	push   %eax
8010570d:	ff 75 f4             	push   -0xc(%ebp)
80105710:	e8 cf cb ff ff       	call   801022e4 <dirlookup>
80105715:	83 c4 10             	add    $0x10,%esp
80105718:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010571b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010571f:	0f 84 0d 01 00 00    	je     80105832 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105725:	83 ec 0c             	sub    $0xc,%esp
80105728:	ff 75 f0             	push   -0x10(%ebp)
8010572b:	e8 aa c3 ff ff       	call   80101ada <ilock>
80105730:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105736:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010573a:	66 85 c0             	test   %ax,%ax
8010573d:	7f 0d                	jg     8010574c <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010573f:	83 ec 0c             	sub    $0xc,%esp
80105742:	68 4d ac 10 80       	push   $0x8010ac4d
80105747:	e8 92 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010574c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105753:	66 83 f8 01          	cmp    $0x1,%ax
80105757:	75 25                	jne    8010577e <sys_unlink+0x11b>
80105759:	83 ec 0c             	sub    $0xc,%esp
8010575c:	ff 75 f0             	push   -0x10(%ebp)
8010575f:	e8 98 fe ff ff       	call   801055fc <isdirempty>
80105764:	83 c4 10             	add    $0x10,%esp
80105767:	85 c0                	test   %eax,%eax
80105769:	75 13                	jne    8010577e <sys_unlink+0x11b>
    iunlockput(ip);
8010576b:	83 ec 0c             	sub    $0xc,%esp
8010576e:	ff 75 f0             	push   -0x10(%ebp)
80105771:	e8 a1 c5 ff ff       	call   80101d17 <iunlockput>
80105776:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105779:	e9 b5 00 00 00       	jmp    80105833 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010577e:	83 ec 04             	sub    $0x4,%esp
80105781:	6a 10                	push   $0x10
80105783:	6a 00                	push   $0x0
80105785:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105788:	50                   	push   %eax
80105789:	e8 9c f5 ff ff       	call   80104d2a <memset>
8010578e:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105791:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105794:	6a 10                	push   $0x10
80105796:	50                   	push   %eax
80105797:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010579a:	50                   	push   %eax
8010579b:	ff 75 f4             	push   -0xc(%ebp)
8010579e:	e8 98 c9 ff ff       	call   8010213b <writei>
801057a3:	83 c4 10             	add    $0x10,%esp
801057a6:	83 f8 10             	cmp    $0x10,%eax
801057a9:	74 0d                	je     801057b8 <sys_unlink+0x155>
    panic("unlink: writei");
801057ab:	83 ec 0c             	sub    $0xc,%esp
801057ae:	68 5f ac 10 80       	push   $0x8010ac5f
801057b3:	e8 26 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
801057b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057bb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057bf:	66 83 f8 01          	cmp    $0x1,%ax
801057c3:	75 21                	jne    801057e6 <sys_unlink+0x183>
    dp->nlink--;
801057c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057cc:	83 e8 01             	sub    $0x1,%eax
801057cf:	89 c2                	mov    %eax,%edx
801057d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057d8:	83 ec 0c             	sub    $0xc,%esp
801057db:	ff 75 f4             	push   -0xc(%ebp)
801057de:	e8 0e c1 ff ff       	call   801018f1 <iupdate>
801057e3:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801057e6:	83 ec 0c             	sub    $0xc,%esp
801057e9:	ff 75 f4             	push   -0xc(%ebp)
801057ec:	e8 26 c5 ff ff       	call   80101d17 <iunlockput>
801057f1:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801057f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057fb:	83 e8 01             	sub    $0x1,%eax
801057fe:	89 c2                	mov    %eax,%edx
80105800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105803:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105807:	83 ec 0c             	sub    $0xc,%esp
8010580a:	ff 75 f0             	push   -0x10(%ebp)
8010580d:	e8 df c0 ff ff       	call   801018f1 <iupdate>
80105812:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105815:	83 ec 0c             	sub    $0xc,%esp
80105818:	ff 75 f0             	push   -0x10(%ebp)
8010581b:	e8 f7 c4 ff ff       	call   80101d17 <iunlockput>
80105820:	83 c4 10             	add    $0x10,%esp

  end_op();
80105823:	e8 37 da ff ff       	call   8010325f <end_op>

  return 0;
80105828:	b8 00 00 00 00       	mov    $0x0,%eax
8010582d:	eb 1c                	jmp    8010584b <sys_unlink+0x1e8>
    goto bad;
8010582f:	90                   	nop
80105830:	eb 01                	jmp    80105833 <sys_unlink+0x1d0>
    goto bad;
80105832:	90                   	nop

bad:
  iunlockput(dp);
80105833:	83 ec 0c             	sub    $0xc,%esp
80105836:	ff 75 f4             	push   -0xc(%ebp)
80105839:	e8 d9 c4 ff ff       	call   80101d17 <iunlockput>
8010583e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105841:	e8 19 da ff ff       	call   8010325f <end_op>
  return -1;
80105846:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010584b:	c9                   	leave
8010584c:	c3                   	ret

8010584d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010584d:	f3 0f 1e fb          	endbr32
80105851:	55                   	push   %ebp
80105852:	89 e5                	mov    %esp,%ebp
80105854:	83 ec 38             	sub    $0x38,%esp
80105857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010585a:	8b 55 10             	mov    0x10(%ebp),%edx
8010585d:	8b 45 14             	mov    0x14(%ebp),%eax
80105860:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105864:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105868:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010586c:	83 ec 08             	sub    $0x8,%esp
8010586f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105872:	50                   	push   %eax
80105873:	ff 75 08             	push   0x8(%ebp)
80105876:	e8 ea cd ff ff       	call   80102665 <nameiparent>
8010587b:	83 c4 10             	add    $0x10,%esp
8010587e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105885:	75 0a                	jne    80105891 <create+0x44>
    return 0;
80105887:	b8 00 00 00 00       	mov    $0x0,%eax
8010588c:	e9 90 01 00 00       	jmp    80105a21 <create+0x1d4>
  ilock(dp);
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	ff 75 f4             	push   -0xc(%ebp)
80105897:	e8 3e c2 ff ff       	call   80101ada <ilock>
8010589c:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010589f:	83 ec 04             	sub    $0x4,%esp
801058a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058a5:	50                   	push   %eax
801058a6:	8d 45 de             	lea    -0x22(%ebp),%eax
801058a9:	50                   	push   %eax
801058aa:	ff 75 f4             	push   -0xc(%ebp)
801058ad:	e8 32 ca ff ff       	call   801022e4 <dirlookup>
801058b2:	83 c4 10             	add    $0x10,%esp
801058b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058bc:	74 50                	je     8010590e <create+0xc1>
    iunlockput(dp);
801058be:	83 ec 0c             	sub    $0xc,%esp
801058c1:	ff 75 f4             	push   -0xc(%ebp)
801058c4:	e8 4e c4 ff ff       	call   80101d17 <iunlockput>
801058c9:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058cc:	83 ec 0c             	sub    $0xc,%esp
801058cf:	ff 75 f0             	push   -0x10(%ebp)
801058d2:	e8 03 c2 ff ff       	call   80101ada <ilock>
801058d7:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801058da:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801058df:	75 15                	jne    801058f6 <create+0xa9>
801058e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058e8:	66 83 f8 02          	cmp    $0x2,%ax
801058ec:	75 08                	jne    801058f6 <create+0xa9>
      return ip;
801058ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f1:	e9 2b 01 00 00       	jmp    80105a21 <create+0x1d4>
    iunlockput(ip);
801058f6:	83 ec 0c             	sub    $0xc,%esp
801058f9:	ff 75 f0             	push   -0x10(%ebp)
801058fc:	e8 16 c4 ff ff       	call   80101d17 <iunlockput>
80105901:	83 c4 10             	add    $0x10,%esp
    return 0;
80105904:	b8 00 00 00 00       	mov    $0x0,%eax
80105909:	e9 13 01 00 00       	jmp    80105a21 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010590e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105915:	8b 00                	mov    (%eax),%eax
80105917:	83 ec 08             	sub    $0x8,%esp
8010591a:	52                   	push   %edx
8010591b:	50                   	push   %eax
8010591c:	e8 f5 be ff ff       	call   80101816 <ialloc>
80105921:	83 c4 10             	add    $0x10,%esp
80105924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010592b:	75 0d                	jne    8010593a <create+0xed>
    panic("create: ialloc");
8010592d:	83 ec 0c             	sub    $0xc,%esp
80105930:	68 6e ac 10 80       	push   $0x8010ac6e
80105935:	e8 a4 ac ff ff       	call   801005de <panic>

  ilock(ip);
8010593a:	83 ec 0c             	sub    $0xc,%esp
8010593d:	ff 75 f0             	push   -0x10(%ebp)
80105940:	e8 95 c1 ff ff       	call   80101ada <ilock>
80105945:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010594f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105956:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010595a:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010595e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105961:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105967:	83 ec 0c             	sub    $0xc,%esp
8010596a:	ff 75 f0             	push   -0x10(%ebp)
8010596d:	e8 7f bf ff ff       	call   801018f1 <iupdate>
80105972:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105975:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010597a:	75 6a                	jne    801059e6 <create+0x199>
    dp->nlink++;  // for ".."
8010597c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105983:	83 c0 01             	add    $0x1,%eax
80105986:	89 c2                	mov    %eax,%edx
80105988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	ff 75 f4             	push   -0xc(%ebp)
80105995:	e8 57 bf ff ff       	call   801018f1 <iupdate>
8010599a:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010599d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a0:	8b 40 04             	mov    0x4(%eax),%eax
801059a3:	83 ec 04             	sub    $0x4,%esp
801059a6:	50                   	push   %eax
801059a7:	68 48 ac 10 80       	push   $0x8010ac48
801059ac:	ff 75 f0             	push   -0x10(%ebp)
801059af:	e8 ee c9 ff ff       	call   801023a2 <dirlink>
801059b4:	83 c4 10             	add    $0x10,%esp
801059b7:	85 c0                	test   %eax,%eax
801059b9:	78 1e                	js     801059d9 <create+0x18c>
801059bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059be:	8b 40 04             	mov    0x4(%eax),%eax
801059c1:	83 ec 04             	sub    $0x4,%esp
801059c4:	50                   	push   %eax
801059c5:	68 4a ac 10 80       	push   $0x8010ac4a
801059ca:	ff 75 f0             	push   -0x10(%ebp)
801059cd:	e8 d0 c9 ff ff       	call   801023a2 <dirlink>
801059d2:	83 c4 10             	add    $0x10,%esp
801059d5:	85 c0                	test   %eax,%eax
801059d7:	79 0d                	jns    801059e6 <create+0x199>
      panic("create dots");
801059d9:	83 ec 0c             	sub    $0xc,%esp
801059dc:	68 7d ac 10 80       	push   $0x8010ac7d
801059e1:	e8 f8 ab ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801059e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e9:	8b 40 04             	mov    0x4(%eax),%eax
801059ec:	83 ec 04             	sub    $0x4,%esp
801059ef:	50                   	push   %eax
801059f0:	8d 45 de             	lea    -0x22(%ebp),%eax
801059f3:	50                   	push   %eax
801059f4:	ff 75 f4             	push   -0xc(%ebp)
801059f7:	e8 a6 c9 ff ff       	call   801023a2 <dirlink>
801059fc:	83 c4 10             	add    $0x10,%esp
801059ff:	85 c0                	test   %eax,%eax
80105a01:	79 0d                	jns    80105a10 <create+0x1c3>
    panic("create: dirlink");
80105a03:	83 ec 0c             	sub    $0xc,%esp
80105a06:	68 89 ac 10 80       	push   $0x8010ac89
80105a0b:	e8 ce ab ff ff       	call   801005de <panic>

  iunlockput(dp);
80105a10:	83 ec 0c             	sub    $0xc,%esp
80105a13:	ff 75 f4             	push   -0xc(%ebp)
80105a16:	e8 fc c2 ff ff       	call   80101d17 <iunlockput>
80105a1b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a21:	c9                   	leave
80105a22:	c3                   	ret

80105a23 <sys_open>:

int
sys_open(void)
{
80105a23:	f3 0f 1e fb          	endbr32
80105a27:	55                   	push   %ebp
80105a28:	89 e5                	mov    %esp,%ebp
80105a2a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a2d:	83 ec 08             	sub    $0x8,%esp
80105a30:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a33:	50                   	push   %eax
80105a34:	6a 00                	push   $0x0
80105a36:	e8 b2 f6 ff ff       	call   801050ed <argstr>
80105a3b:	83 c4 10             	add    $0x10,%esp
80105a3e:	85 c0                	test   %eax,%eax
80105a40:	78 15                	js     80105a57 <sys_open+0x34>
80105a42:	83 ec 08             	sub    $0x8,%esp
80105a45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a48:	50                   	push   %eax
80105a49:	6a 01                	push   $0x1
80105a4b:	e8 0f f6 ff ff       	call   8010505f <argint>
80105a50:	83 c4 10             	add    $0x10,%esp
80105a53:	85 c0                	test   %eax,%eax
80105a55:	79 0a                	jns    80105a61 <sys_open+0x3e>
    return -1;
80105a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5c:	e9 61 01 00 00       	jmp    80105bc2 <sys_open+0x19f>

  begin_op();
80105a61:	e8 69 d7 ff ff       	call   801031cf <begin_op>

  if(omode & O_CREATE){
80105a66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a69:	25 00 02 00 00       	and    $0x200,%eax
80105a6e:	85 c0                	test   %eax,%eax
80105a70:	74 2a                	je     80105a9c <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a75:	6a 00                	push   $0x0
80105a77:	6a 00                	push   $0x0
80105a79:	6a 02                	push   $0x2
80105a7b:	50                   	push   %eax
80105a7c:	e8 cc fd ff ff       	call   8010584d <create>
80105a81:	83 c4 10             	add    $0x10,%esp
80105a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8b:	75 75                	jne    80105b02 <sys_open+0xdf>
      end_op();
80105a8d:	e8 cd d7 ff ff       	call   8010325f <end_op>
      return -1;
80105a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a97:	e9 26 01 00 00       	jmp    80105bc2 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a9f:	83 ec 0c             	sub    $0xc,%esp
80105aa2:	50                   	push   %eax
80105aa3:	e8 9d cb ff ff       	call   80102645 <namei>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab2:	75 0f                	jne    80105ac3 <sys_open+0xa0>
      end_op();
80105ab4:	e8 a6 d7 ff ff       	call   8010325f <end_op>
      return -1;
80105ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abe:	e9 ff 00 00 00       	jmp    80105bc2 <sys_open+0x19f>
    }
    ilock(ip);
80105ac3:	83 ec 0c             	sub    $0xc,%esp
80105ac6:	ff 75 f4             	push   -0xc(%ebp)
80105ac9:	e8 0c c0 ff ff       	call   80101ada <ilock>
80105ace:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ad8:	66 83 f8 01          	cmp    $0x1,%ax
80105adc:	75 24                	jne    80105b02 <sys_open+0xdf>
80105ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	74 1d                	je     80105b02 <sys_open+0xdf>
      iunlockput(ip);
80105ae5:	83 ec 0c             	sub    $0xc,%esp
80105ae8:	ff 75 f4             	push   -0xc(%ebp)
80105aeb:	e8 27 c2 ff ff       	call   80101d17 <iunlockput>
80105af0:	83 c4 10             	add    $0x10,%esp
      end_op();
80105af3:	e8 67 d7 ff ff       	call   8010325f <end_op>
      return -1;
80105af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afd:	e9 c0 00 00 00       	jmp    80105bc2 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b02:	e8 7a b5 ff ff       	call   80101081 <filealloc>
80105b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b0e:	74 17                	je     80105b27 <sys_open+0x104>
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	ff 75 f0             	push   -0x10(%ebp)
80105b16:	e8 07 f7 ff ff       	call   80105222 <fdalloc>
80105b1b:	83 c4 10             	add    $0x10,%esp
80105b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b25:	79 2e                	jns    80105b55 <sys_open+0x132>
    if(f)
80105b27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b2b:	74 0e                	je     80105b3b <sys_open+0x118>
      fileclose(f);
80105b2d:	83 ec 0c             	sub    $0xc,%esp
80105b30:	ff 75 f0             	push   -0x10(%ebp)
80105b33:	e8 0f b6 ff ff       	call   80101147 <fileclose>
80105b38:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	ff 75 f4             	push   -0xc(%ebp)
80105b41:	e8 d1 c1 ff ff       	call   80101d17 <iunlockput>
80105b46:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b49:	e8 11 d7 ff ff       	call   8010325f <end_op>
    return -1;
80105b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b53:	eb 6d                	jmp    80105bc2 <sys_open+0x19f>
  }
  iunlock(ip);
80105b55:	83 ec 0c             	sub    $0xc,%esp
80105b58:	ff 75 f4             	push   -0xc(%ebp)
80105b5b:	e8 91 c0 ff ff       	call   80101bf1 <iunlock>
80105b60:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b63:	e8 f7 d6 ff ff       	call   8010325f <end_op>

  f->type = FD_INODE;
80105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b77:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b87:	83 e0 01             	and    $0x1,%eax
80105b8a:	85 c0                	test   %eax,%eax
80105b8c:	0f 94 c0             	sete   %al
80105b8f:	89 c2                	mov    %eax,%edx
80105b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b94:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b9a:	83 e0 01             	and    $0x1,%eax
80105b9d:	85 c0                	test   %eax,%eax
80105b9f:	75 0a                	jne    80105bab <sys_open+0x188>
80105ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ba4:	83 e0 02             	and    $0x2,%eax
80105ba7:	85 c0                	test   %eax,%eax
80105ba9:	74 07                	je     80105bb2 <sys_open+0x18f>
80105bab:	b8 01 00 00 00       	mov    $0x1,%eax
80105bb0:	eb 05                	jmp    80105bb7 <sys_open+0x194>
80105bb2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb7:	89 c2                	mov    %eax,%edx
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bc2:	c9                   	leave
80105bc3:	c3                   	ret

80105bc4 <sys_mkdir>:

int
sys_mkdir(void)
{
80105bc4:	f3 0f 1e fb          	endbr32
80105bc8:	55                   	push   %ebp
80105bc9:	89 e5                	mov    %esp,%ebp
80105bcb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bce:	e8 fc d5 ff ff       	call   801031cf <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105bd3:	83 ec 08             	sub    $0x8,%esp
80105bd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bd9:	50                   	push   %eax
80105bda:	6a 00                	push   $0x0
80105bdc:	e8 0c f5 ff ff       	call   801050ed <argstr>
80105be1:	83 c4 10             	add    $0x10,%esp
80105be4:	85 c0                	test   %eax,%eax
80105be6:	78 1b                	js     80105c03 <sys_mkdir+0x3f>
80105be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105beb:	6a 00                	push   $0x0
80105bed:	6a 00                	push   $0x0
80105bef:	6a 01                	push   $0x1
80105bf1:	50                   	push   %eax
80105bf2:	e8 56 fc ff ff       	call   8010584d <create>
80105bf7:	83 c4 10             	add    $0x10,%esp
80105bfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c01:	75 0c                	jne    80105c0f <sys_mkdir+0x4b>
    end_op();
80105c03:	e8 57 d6 ff ff       	call   8010325f <end_op>
    return -1;
80105c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0d:	eb 18                	jmp    80105c27 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105c0f:	83 ec 0c             	sub    $0xc,%esp
80105c12:	ff 75 f4             	push   -0xc(%ebp)
80105c15:	e8 fd c0 ff ff       	call   80101d17 <iunlockput>
80105c1a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c1d:	e8 3d d6 ff ff       	call   8010325f <end_op>
  return 0;
80105c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c27:	c9                   	leave
80105c28:	c3                   	ret

80105c29 <sys_mknod>:

int
sys_mknod(void)
{
80105c29:	f3 0f 1e fb          	endbr32
80105c2d:	55                   	push   %ebp
80105c2e:	89 e5                	mov    %esp,%ebp
80105c30:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c33:	e8 97 d5 ff ff       	call   801031cf <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c38:	83 ec 08             	sub    $0x8,%esp
80105c3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c3e:	50                   	push   %eax
80105c3f:	6a 00                	push   $0x0
80105c41:	e8 a7 f4 ff ff       	call   801050ed <argstr>
80105c46:	83 c4 10             	add    $0x10,%esp
80105c49:	85 c0                	test   %eax,%eax
80105c4b:	78 4f                	js     80105c9c <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105c4d:	83 ec 08             	sub    $0x8,%esp
80105c50:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c53:	50                   	push   %eax
80105c54:	6a 01                	push   $0x1
80105c56:	e8 04 f4 ff ff       	call   8010505f <argint>
80105c5b:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c5e:	85 c0                	test   %eax,%eax
80105c60:	78 3a                	js     80105c9c <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c62:	83 ec 08             	sub    $0x8,%esp
80105c65:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c68:	50                   	push   %eax
80105c69:	6a 02                	push   $0x2
80105c6b:	e8 ef f3 ff ff       	call   8010505f <argint>
80105c70:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c73:	85 c0                	test   %eax,%eax
80105c75:	78 25                	js     80105c9c <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c7a:	0f bf c8             	movswl %ax,%ecx
80105c7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c80:	0f bf d0             	movswl %ax,%edx
80105c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c86:	51                   	push   %ecx
80105c87:	52                   	push   %edx
80105c88:	6a 03                	push   $0x3
80105c8a:	50                   	push   %eax
80105c8b:	e8 bd fb ff ff       	call   8010584d <create>
80105c90:	83 c4 10             	add    $0x10,%esp
80105c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105c96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c9a:	75 0c                	jne    80105ca8 <sys_mknod+0x7f>
    end_op();
80105c9c:	e8 be d5 ff ff       	call   8010325f <end_op>
    return -1;
80105ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca6:	eb 18                	jmp    80105cc0 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105ca8:	83 ec 0c             	sub    $0xc,%esp
80105cab:	ff 75 f4             	push   -0xc(%ebp)
80105cae:	e8 64 c0 ff ff       	call   80101d17 <iunlockput>
80105cb3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cb6:	e8 a4 d5 ff ff       	call   8010325f <end_op>
  return 0;
80105cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc0:	c9                   	leave
80105cc1:	c3                   	ret

80105cc2 <sys_chdir>:

int
sys_chdir(void)
{
80105cc2:	f3 0f 1e fb          	endbr32
80105cc6:	55                   	push   %ebp
80105cc7:	89 e5                	mov    %esp,%ebp
80105cc9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ccc:	e8 36 df ff ff       	call   80103c07 <myproc>
80105cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cd4:	e8 f6 d4 ff ff       	call   801031cf <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105cd9:	83 ec 08             	sub    $0x8,%esp
80105cdc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cdf:	50                   	push   %eax
80105ce0:	6a 00                	push   $0x0
80105ce2:	e8 06 f4 ff ff       	call   801050ed <argstr>
80105ce7:	83 c4 10             	add    $0x10,%esp
80105cea:	85 c0                	test   %eax,%eax
80105cec:	78 18                	js     80105d06 <sys_chdir+0x44>
80105cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cf1:	83 ec 0c             	sub    $0xc,%esp
80105cf4:	50                   	push   %eax
80105cf5:	e8 4b c9 ff ff       	call   80102645 <namei>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d04:	75 0c                	jne    80105d12 <sys_chdir+0x50>
    end_op();
80105d06:	e8 54 d5 ff ff       	call   8010325f <end_op>
    return -1;
80105d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d10:	eb 68                	jmp    80105d7a <sys_chdir+0xb8>
  }
  ilock(ip);
80105d12:	83 ec 0c             	sub    $0xc,%esp
80105d15:	ff 75 f0             	push   -0x10(%ebp)
80105d18:	e8 bd bd ff ff       	call   80101ada <ilock>
80105d1d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d23:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d27:	66 83 f8 01          	cmp    $0x1,%ax
80105d2b:	74 1a                	je     80105d47 <sys_chdir+0x85>
    iunlockput(ip);
80105d2d:	83 ec 0c             	sub    $0xc,%esp
80105d30:	ff 75 f0             	push   -0x10(%ebp)
80105d33:	e8 df bf ff ff       	call   80101d17 <iunlockput>
80105d38:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d3b:	e8 1f d5 ff ff       	call   8010325f <end_op>
    return -1;
80105d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d45:	eb 33                	jmp    80105d7a <sys_chdir+0xb8>
  }
  iunlock(ip);
80105d47:	83 ec 0c             	sub    $0xc,%esp
80105d4a:	ff 75 f0             	push   -0x10(%ebp)
80105d4d:	e8 9f be ff ff       	call   80101bf1 <iunlock>
80105d52:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d58:	8b 40 68             	mov    0x68(%eax),%eax
80105d5b:	83 ec 0c             	sub    $0xc,%esp
80105d5e:	50                   	push   %eax
80105d5f:	e8 df be ff ff       	call   80101c43 <iput>
80105d64:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d67:	e8 f3 d4 ff ff       	call   8010325f <end_op>
  curproc->cwd = ip;
80105d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d72:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d7a:	c9                   	leave
80105d7b:	c3                   	ret

80105d7c <sys_exec>:

int
sys_exec(void)
{
80105d7c:	f3 0f 1e fb          	endbr32
80105d80:	55                   	push   %ebp
80105d81:	89 e5                	mov    %esp,%ebp
80105d83:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d89:	83 ec 08             	sub    $0x8,%esp
80105d8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d8f:	50                   	push   %eax
80105d90:	6a 00                	push   $0x0
80105d92:	e8 56 f3 ff ff       	call   801050ed <argstr>
80105d97:	83 c4 10             	add    $0x10,%esp
80105d9a:	85 c0                	test   %eax,%eax
80105d9c:	78 18                	js     80105db6 <sys_exec+0x3a>
80105d9e:	83 ec 08             	sub    $0x8,%esp
80105da1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105da7:	50                   	push   %eax
80105da8:	6a 01                	push   $0x1
80105daa:	e8 b0 f2 ff ff       	call   8010505f <argint>
80105daf:	83 c4 10             	add    $0x10,%esp
80105db2:	85 c0                	test   %eax,%eax
80105db4:	79 0a                	jns    80105dc0 <sys_exec+0x44>
    return -1;
80105db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbb:	e9 c6 00 00 00       	jmp    80105e86 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105dc0:	83 ec 04             	sub    $0x4,%esp
80105dc3:	68 80 00 00 00       	push   $0x80
80105dc8:	6a 00                	push   $0x0
80105dca:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105dd0:	50                   	push   %eax
80105dd1:	e8 54 ef ff ff       	call   80104d2a <memset>
80105dd6:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105dd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de3:	83 f8 1f             	cmp    $0x1f,%eax
80105de6:	76 0a                	jbe    80105df2 <sys_exec+0x76>
      return -1;
80105de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ded:	e9 94 00 00 00       	jmp    80105e86 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	c1 e0 02             	shl    $0x2,%eax
80105df8:	89 c2                	mov    %eax,%edx
80105dfa:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e00:	01 c2                	add    %eax,%edx
80105e02:	83 ec 08             	sub    $0x8,%esp
80105e05:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e0b:	50                   	push   %eax
80105e0c:	52                   	push   %edx
80105e0d:	e8 c1 f1 ff ff       	call   80104fd3 <fetchint>
80105e12:	83 c4 10             	add    $0x10,%esp
80105e15:	85 c0                	test   %eax,%eax
80105e17:	79 07                	jns    80105e20 <sys_exec+0xa4>
      return -1;
80105e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1e:	eb 66                	jmp    80105e86 <sys_exec+0x10a>
    if(uarg == 0){
80105e20:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e26:	85 c0                	test   %eax,%eax
80105e28:	75 27                	jne    80105e51 <sys_exec+0xd5>
      argv[i] = 0;
80105e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e34:	00 00 00 00 
      break;
80105e38:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3c:	83 ec 08             	sub    $0x8,%esp
80105e3f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e45:	52                   	push   %edx
80105e46:	50                   	push   %eax
80105e47:	e8 8b ad ff ff       	call   80100bd7 <exec>
80105e4c:	83 c4 10             	add    $0x10,%esp
80105e4f:	eb 35                	jmp    80105e86 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e51:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e5a:	c1 e2 02             	shl    $0x2,%edx
80105e5d:	01 c2                	add    %eax,%edx
80105e5f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e65:	83 ec 08             	sub    $0x8,%esp
80105e68:	52                   	push   %edx
80105e69:	50                   	push   %eax
80105e6a:	e8 94 f1 ff ff       	call   80105003 <fetchstr>
80105e6f:	83 c4 10             	add    $0x10,%esp
80105e72:	85 c0                	test   %eax,%eax
80105e74:	79 07                	jns    80105e7d <sys_exec+0x101>
      return -1;
80105e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7b:	eb 09                	jmp    80105e86 <sys_exec+0x10a>
  for(i=0;; i++){
80105e7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e81:	e9 5a ff ff ff       	jmp    80105de0 <sys_exec+0x64>
}
80105e86:	c9                   	leave
80105e87:	c3                   	ret

80105e88 <sys_pipe>:

int
sys_pipe(void)
{
80105e88:	f3 0f 1e fb          	endbr32
80105e8c:	55                   	push   %ebp
80105e8d:	89 e5                	mov    %esp,%ebp
80105e8f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e92:	83 ec 04             	sub    $0x4,%esp
80105e95:	6a 08                	push   $0x8
80105e97:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e9a:	50                   	push   %eax
80105e9b:	6a 00                	push   $0x0
80105e9d:	e8 ee f1 ff ff       	call   80105090 <argptr>
80105ea2:	83 c4 10             	add    $0x10,%esp
80105ea5:	85 c0                	test   %eax,%eax
80105ea7:	79 0a                	jns    80105eb3 <sys_pipe+0x2b>
    return -1;
80105ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eae:	e9 ae 00 00 00       	jmp    80105f61 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105eb3:	83 ec 08             	sub    $0x8,%esp
80105eb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105eb9:	50                   	push   %eax
80105eba:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ebd:	50                   	push   %eax
80105ebe:	e8 65 d8 ff ff       	call   80103728 <pipealloc>
80105ec3:	83 c4 10             	add    $0x10,%esp
80105ec6:	85 c0                	test   %eax,%eax
80105ec8:	79 0a                	jns    80105ed4 <sys_pipe+0x4c>
    return -1;
80105eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecf:	e9 8d 00 00 00       	jmp    80105f61 <sys_pipe+0xd9>
  fd0 = -1;
80105ed4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105edb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ede:	83 ec 0c             	sub    $0xc,%esp
80105ee1:	50                   	push   %eax
80105ee2:	e8 3b f3 ff ff       	call   80105222 <fdalloc>
80105ee7:	83 c4 10             	add    $0x10,%esp
80105eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ef1:	78 18                	js     80105f0b <sys_pipe+0x83>
80105ef3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ef6:	83 ec 0c             	sub    $0xc,%esp
80105ef9:	50                   	push   %eax
80105efa:	e8 23 f3 ff ff       	call   80105222 <fdalloc>
80105eff:	83 c4 10             	add    $0x10,%esp
80105f02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f09:	79 3e                	jns    80105f49 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105f0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f0f:	78 13                	js     80105f24 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105f11:	e8 f1 dc ff ff       	call   80103c07 <myproc>
80105f16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f19:	83 c2 08             	add    $0x8,%edx
80105f1c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f23:	00 
    fileclose(rf);
80105f24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f27:	83 ec 0c             	sub    $0xc,%esp
80105f2a:	50                   	push   %eax
80105f2b:	e8 17 b2 ff ff       	call   80101147 <fileclose>
80105f30:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f36:	83 ec 0c             	sub    $0xc,%esp
80105f39:	50                   	push   %eax
80105f3a:	e8 08 b2 ff ff       	call   80101147 <fileclose>
80105f3f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f47:	eb 18                	jmp    80105f61 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f4f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f54:	8d 50 04             	lea    0x4(%eax),%edx
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	89 02                	mov    %eax,(%edx)
  return 0;
80105f5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f61:	c9                   	leave
80105f62:	c3                   	ret

80105f63 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f63:	f3 0f 1e fb          	endbr32
80105f67:	55                   	push   %ebp
80105f68:	89 e5                	mov    %esp,%ebp
80105f6a:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f6d:	83 ec 08             	sub    $0x8,%esp
80105f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f73:	50                   	push   %eax
80105f74:	6a 00                	push   $0x0
80105f76:	e8 e4 f0 ff ff       	call   8010505f <argint>
80105f7b:	83 c4 10             	add    $0x10,%esp
80105f7e:	85 c0                	test   %eax,%eax
80105f80:	79 07                	jns    80105f89 <sys_printpt+0x26>
        return -1;
80105f82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f87:	eb 0f                	jmp    80105f98 <sys_printpt+0x35>
  return printpt(pid);
80105f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8c:	83 ec 0c             	sub    $0xc,%esp
80105f8f:	50                   	push   %eax
80105f90:	e8 3d e8 ff ff       	call   801047d2 <printpt>
80105f95:	83 c4 10             	add    $0x10,%esp
}
80105f98:	c9                   	leave
80105f99:	c3                   	ret

80105f9a <sys_fork>:

int
sys_fork(void)
{
80105f9a:	f3 0f 1e fb          	endbr32
80105f9e:	55                   	push   %ebp
80105f9f:	89 e5                	mov    %esp,%ebp
80105fa1:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fa4:	e8 81 df ff ff       	call   80103f2a <fork>
}
80105fa9:	c9                   	leave
80105faa:	c3                   	ret

80105fab <sys_exit>:

int
sys_exit(void)
{
80105fab:	f3 0f 1e fb          	endbr32
80105faf:	55                   	push   %ebp
80105fb0:	89 e5                	mov    %esp,%ebp
80105fb2:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fb5:	e8 ed e0 ff ff       	call   801040a7 <exit>
  return 0;  // not reached
80105fba:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fbf:	c9                   	leave
80105fc0:	c3                   	ret

80105fc1 <sys_wait>:

int
sys_wait(void)
{
80105fc1:	f3 0f 1e fb          	endbr32
80105fc5:	55                   	push   %ebp
80105fc6:	89 e5                	mov    %esp,%ebp
80105fc8:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fcb:	e8 fb e1 ff ff       	call   801041cb <wait>
}
80105fd0:	c9                   	leave
80105fd1:	c3                   	ret

80105fd2 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105fd2:	f3 0f 1e fb          	endbr32
80105fd6:	55                   	push   %ebp
80105fd7:	89 e5                	mov    %esp,%ebp
80105fd9:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105fdc:	83 ec 08             	sub    $0x8,%esp
80105fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fe2:	50                   	push   %eax
80105fe3:	6a 00                	push   $0x0
80105fe5:	e8 75 f0 ff ff       	call   8010505f <argint>
80105fea:	83 c4 10             	add    $0x10,%esp
80105fed:	85 c0                	test   %eax,%eax
80105fef:	79 07                	jns    80105ff8 <sys_uthread_init+0x26>
        return -1;
80105ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff6:	eb 0f                	jmp    80106007 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80105ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffb:	83 ec 0c             	sub    $0xc,%esp
80105ffe:	50                   	push   %eax
80105fff:	e8 a7 e3 ff ff       	call   801043ab <uthread_init>
80106004:	83 c4 10             	add    $0x10,%esp
}
80106007:	c9                   	leave
80106008:	c3                   	ret

80106009 <sys_kill>:

int
sys_kill(void)
{
80106009:	f3 0f 1e fb          	endbr32
8010600d:	55                   	push   %ebp
8010600e:	89 e5                	mov    %esp,%ebp
80106010:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106013:	83 ec 08             	sub    $0x8,%esp
80106016:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106019:	50                   	push   %eax
8010601a:	6a 00                	push   $0x0
8010601c:	e8 3e f0 ff ff       	call   8010505f <argint>
80106021:	83 c4 10             	add    $0x10,%esp
80106024:	85 c0                	test   %eax,%eax
80106026:	79 07                	jns    8010602f <sys_kill+0x26>
    return -1;
80106028:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602d:	eb 0f                	jmp    8010603e <sys_kill+0x35>
  return kill(pid);
8010602f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106032:	83 ec 0c             	sub    $0xc,%esp
80106035:	50                   	push   %eax
80106036:	e8 01 e6 ff ff       	call   8010463c <kill>
8010603b:	83 c4 10             	add    $0x10,%esp
}
8010603e:	c9                   	leave
8010603f:	c3                   	ret

80106040 <sys_getpid>:

int
sys_getpid(void)
{
80106040:	f3 0f 1e fb          	endbr32
80106044:	55                   	push   %ebp
80106045:	89 e5                	mov    %esp,%ebp
80106047:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010604a:	e8 b8 db ff ff       	call   80103c07 <myproc>
8010604f:	8b 40 10             	mov    0x10(%eax),%eax
}
80106052:	c9                   	leave
80106053:	c3                   	ret

80106054 <sys_sbrk>:

int
sys_sbrk(void)
{
80106054:	f3 0f 1e fb          	endbr32
80106058:	55                   	push   %ebp
80106059:	89 e5                	mov    %esp,%ebp
8010605b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc* p = myproc();
8010605e:	e8 a4 db ff ff       	call   80103c07 <myproc>
80106063:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(argint(0, &n) < 0)
80106066:	83 ec 08             	sub    $0x8,%esp
80106069:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010606c:	50                   	push   %eax
8010606d:	6a 00                	push   $0x0
8010606f:	e8 eb ef ff ff       	call   8010505f <argint>
80106074:	83 c4 10             	add    $0x10,%esp
80106077:	85 c0                	test   %eax,%eax
80106079:	79 0a                	jns    80106085 <sys_sbrk+0x31>
    return -1;
8010607b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106080:	e9 4f 01 00 00       	jmp    801061d4 <sys_sbrk+0x180>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80106085:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106088:	8b 00                	mov    (%eax),%eax
8010608a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (n > 0)
8010608d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106090:	85 c0                	test   %eax,%eax
80106092:	0f 8e b5 00 00 00    	jle    8010614d <sys_sbrk+0xf9>
  { 
    if (PGROUNDUP(p->sz + n) >= p->tf->esp){
80106098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609b:	8b 00                	mov    (%eax),%eax
8010609d:	8b 55 e0             	mov    -0x20(%ebp),%edx
801060a0:	01 d0                	add    %edx,%eax
801060a2:	05 ff 0f 00 00       	add    $0xfff,%eax
801060a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060ac:	89 c2                	mov    %eax,%edx
801060ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b1:	8b 40 18             	mov    0x18(%eax),%eax
801060b4:	8b 40 44             	mov    0x44(%eax),%eax
801060b7:	39 c2                	cmp    %eax,%edx
801060b9:	72 1c                	jb     801060d7 <sys_sbrk+0x83>
      kill(p->pid);
801060bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060be:	8b 40 10             	mov    0x10(%eax),%eax
801060c1:	83 ec 0c             	sub    $0xc,%esp
801060c4:	50                   	push   %eax
801060c5:	e8 72 e5 ff ff       	call   8010463c <kill>
801060ca:	83 c4 10             	add    $0x10,%esp
      return -1;
801060cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d2:	e9 fd 00 00 00       	jmp    801061d4 <sys_sbrk+0x180>
    }
    else{
      uint oldsz = PGROUNDUP(p->sz);
801060d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060da:	8b 00                	mov    (%eax),%eax
801060dc:	05 ff 0f 00 00       	add    $0xfff,%eax
801060e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint newsz = p->sz + n;
801060e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ec:	8b 00                	mov    (%eax),%eax
801060ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
801060f1:	01 d0                	add    %edx,%eax
801060f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      p->sz = newsz;
801060f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801060fc:	89 10                	mov    %edx,(%eax)
      for(; oldsz < newsz; oldsz += PGSIZE){
801060fe:	eb 32                	jmp    80106132 <sys_sbrk+0xde>
      pte_t *pte = walkpgdir(p->pgdir, (void*)oldsz, 1);
80106100:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106106:	8b 40 04             	mov    0x4(%eax),%eax
80106109:	83 ec 04             	sub    $0x4,%esp
8010610c:	6a 01                	push   $0x1
8010610e:	52                   	push   %edx
8010610f:	50                   	push   %eax
80106110:	e8 f8 16 00 00       	call   8010780d <walkpgdir>
80106115:	83 c4 10             	add    $0x10,%esp
80106118:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (pte == 0)
8010611b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010611f:	75 0a                	jne    8010612b <sys_sbrk+0xd7>
        return -1;
80106121:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106126:	e9 a9 00 00 00       	jmp    801061d4 <sys_sbrk+0x180>
      for(; oldsz < newsz; oldsz += PGSIZE){
8010612b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80106132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106135:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106138:	72 c6                	jb     80106100 <sys_sbrk+0xac>
      // cprintf("pgtab %x\n",*pte);
      }
      switchuvm(p);
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	ff 75 f0             	push   -0x10(%ebp)
80106140:	e8 20 19 00 00       	call   80107a65 <switchuvm>
80106145:	83 c4 10             	add    $0x10,%esp
80106148:	e9 84 00 00 00       	jmp    801061d1 <sys_sbrk+0x17d>
    }
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
8010614d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106150:	85 c0                	test   %eax,%eax
80106152:	79 7d                	jns    801061d1 <sys_sbrk+0x17d>
  {
    cprintf("[sbrk] sz %x \n",p->sz);
80106154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106157:	8b 00                	mov    (%eax),%eax
80106159:	83 ec 08             	sub    $0x8,%esp
8010615c:	50                   	push   %eax
8010615d:	68 99 ac 10 80       	push   $0x8010ac99
80106162:	e8 a5 a2 ff ff       	call   8010040c <cprintf>
80106167:	83 c4 10             	add    $0x10,%esp
    if(growproc(n) < 0)
8010616a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010616d:	83 ec 0c             	sub    $0xc,%esp
80106170:	50                   	push   %eax
80106171:	e8 15 dd ff ff       	call   80103e8b <growproc>
80106176:	83 c4 10             	add    $0x10,%esp
80106179:	85 c0                	test   %eax,%eax
8010617b:	79 07                	jns    80106184 <sys_sbrk+0x130>
      return -1;
8010617d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106182:	eb 50                	jmp    801061d4 <sys_sbrk+0x180>
    cprintf("[sbrk] sz %x \n",p->sz);
80106184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106187:	8b 00                	mov    (%eax),%eax
80106189:	83 ec 08             	sub    $0x8,%esp
8010618c:	50                   	push   %eax
8010618d:	68 99 ac 10 80       	push   $0x8010ac99
80106192:	e8 75 a2 ff ff       	call   8010040c <cprintf>
80106197:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] addr %x \n", addr);
8010619a:	83 ec 08             	sub    $0x8,%esp
8010619d:	ff 75 ec             	push   -0x14(%ebp)
801061a0:	68 a8 ac 10 80       	push   $0x8010aca8
801061a5:	e8 62 a2 ff ff       	call   8010040c <cprintf>
801061aa:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] esp %x eip %x \n",p->tf->esp, p->tf->eip);
801061ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b0:	8b 40 18             	mov    0x18(%eax),%eax
801061b3:	8b 50 38             	mov    0x38(%eax),%edx
801061b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b9:	8b 40 18             	mov    0x18(%eax),%eax
801061bc:	8b 40 44             	mov    0x44(%eax),%eax
801061bf:	83 ec 04             	sub    $0x4,%esp
801061c2:	52                   	push   %edx
801061c3:	50                   	push   %eax
801061c4:	68 b9 ac 10 80       	push   $0x8010acb9
801061c9:	e8 3e a2 ff ff       	call   8010040c <cprintf>
801061ce:	83 c4 10             	add    $0x10,%esp
  }
  return addr;
801061d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061d4:	c9                   	leave
801061d5:	c3                   	ret

801061d6 <sys_sleep>:

int
sys_sleep(void)
{
801061d6:	f3 0f 1e fb          	endbr32
801061da:	55                   	push   %ebp
801061db:	89 e5                	mov    %esp,%ebp
801061dd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801061e0:	83 ec 08             	sub    $0x8,%esp
801061e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061e6:	50                   	push   %eax
801061e7:	6a 00                	push   $0x0
801061e9:	e8 71 ee ff ff       	call   8010505f <argint>
801061ee:	83 c4 10             	add    $0x10,%esp
801061f1:	85 c0                	test   %eax,%eax
801061f3:	79 07                	jns    801061fc <sys_sleep+0x26>
    return -1;
801061f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fa:	eb 76                	jmp    80106272 <sys_sleep+0x9c>
  acquire(&tickslock);
801061fc:	83 ec 0c             	sub    $0xc,%esp
801061ff:	68 40 75 19 80       	push   $0x80197540
80106204:	e8 92 e8 ff ff       	call   80104a9b <acquire>
80106209:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010620c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106211:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106214:	eb 38                	jmp    8010624e <sys_sleep+0x78>
    if(myproc()->killed){
80106216:	e8 ec d9 ff ff       	call   80103c07 <myproc>
8010621b:	8b 40 24             	mov    0x24(%eax),%eax
8010621e:	85 c0                	test   %eax,%eax
80106220:	74 17                	je     80106239 <sys_sleep+0x63>
      release(&tickslock);
80106222:	83 ec 0c             	sub    $0xc,%esp
80106225:	68 40 75 19 80       	push   $0x80197540
8010622a:	e8 de e8 ff ff       	call   80104b0d <release>
8010622f:	83 c4 10             	add    $0x10,%esp
      return -1;
80106232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106237:	eb 39                	jmp    80106272 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106239:	83 ec 08             	sub    $0x8,%esp
8010623c:	68 40 75 19 80       	push   $0x80197540
80106241:	68 80 7d 19 80       	push   $0x80197d80
80106246:	e8 c7 e2 ff ff       	call   80104512 <sleep>
8010624b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010624e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106253:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106256:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106259:	39 d0                	cmp    %edx,%eax
8010625b:	72 b9                	jb     80106216 <sys_sleep+0x40>
  }
  release(&tickslock);
8010625d:	83 ec 0c             	sub    $0xc,%esp
80106260:	68 40 75 19 80       	push   $0x80197540
80106265:	e8 a3 e8 ff ff       	call   80104b0d <release>
8010626a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010626d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106272:	c9                   	leave
80106273:	c3                   	ret

80106274 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106274:	f3 0f 1e fb          	endbr32
80106278:	55                   	push   %ebp
80106279:	89 e5                	mov    %esp,%ebp
8010627b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010627e:	83 ec 0c             	sub    $0xc,%esp
80106281:	68 40 75 19 80       	push   $0x80197540
80106286:	e8 10 e8 ff ff       	call   80104a9b <acquire>
8010628b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010628e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106296:	83 ec 0c             	sub    $0xc,%esp
80106299:	68 40 75 19 80       	push   $0x80197540
8010629e:	e8 6a e8 ff ff       	call   80104b0d <release>
801062a3:	83 c4 10             	add    $0x10,%esp
  return xticks;
801062a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062a9:	c9                   	leave
801062aa:	c3                   	ret

801062ab <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062ab:	1e                   	push   %ds
  pushl %es
801062ac:	06                   	push   %es
  pushl %fs
801062ad:	0f a0                	push   %fs
  pushl %gs
801062af:	0f a8                	push   %gs
  pushal
801062b1:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062b2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062b6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062b8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801062ba:	54                   	push   %esp
  call trap
801062bb:	e8 df 01 00 00       	call   8010649f <trap>
  addl $4, %esp
801062c0:	83 c4 04             	add    $0x4,%esp

801062c3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801062c3:	61                   	popa
  popl %gs
801062c4:	0f a9                	pop    %gs
  popl %fs
801062c6:	0f a1                	pop    %fs
  popl %es
801062c8:	07                   	pop    %es
  popl %ds
801062c9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801062ca:	83 c4 08             	add    $0x8,%esp
  iret
801062cd:	cf                   	iret

801062ce <lidt>:
{
801062ce:	55                   	push   %ebp
801062cf:	89 e5                	mov    %esp,%ebp
801062d1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801062d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d7:	83 e8 01             	sub    $0x1,%eax
801062da:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062de:	8b 45 08             	mov    0x8(%ebp),%eax
801062e1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062e5:	8b 45 08             	mov    0x8(%ebp),%eax
801062e8:	c1 e8 10             	shr    $0x10,%eax
801062eb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062ef:	8d 45 fa             	lea    -0x6(%ebp),%eax
801062f2:	0f 01 18             	lidtl  (%eax)
}
801062f5:	90                   	nop
801062f6:	c9                   	leave
801062f7:	c3                   	ret

801062f8 <rcr2>:

static inline uint
rcr2(void)
{
801062f8:	55                   	push   %ebp
801062f9:	89 e5                	mov    %esp,%ebp
801062fb:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062fe:	0f 20 d0             	mov    %cr2,%eax
80106301:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106307:	c9                   	leave
80106308:	c3                   	ret

80106309 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106309:	f3 0f 1e fb          	endbr32
8010630d:	55                   	push   %ebp
8010630e:	89 e5                	mov    %esp,%ebp
80106310:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106313:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010631a:	e9 c3 00 00 00       	jmp    801063e2 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106329:	89 c2                	mov    %eax,%edx
8010632b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632e:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106335:	80 
80106336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106339:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
80106340:	80 08 00 
80106343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106346:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010634d:	80 
8010634e:	83 e2 e0             	and    $0xffffffe0,%edx
80106351:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635b:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106362:	80 
80106363:	83 e2 1f             	and    $0x1f,%edx
80106366:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106377:	80 
80106378:	83 e2 f0             	and    $0xfffffff0,%edx
8010637b:	83 ca 0e             	or     $0xe,%edx
8010637e:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106388:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010638f:	80 
80106390:	83 e2 ef             	and    $0xffffffef,%edx
80106393:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010639a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639d:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063a4:	80 
801063a5:	83 e2 9f             	and    $0xffffff9f,%edx
801063a8:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b2:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063b9:	80 
801063ba:	83 ca 80             	or     $0xffffff80,%edx
801063bd:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c7:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801063ce:	c1 e8 10             	shr    $0x10,%eax
801063d1:	89 c2                	mov    %eax,%edx
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801063dd:	80 
  for(i = 0; i < 256; i++)
801063de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063e2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063e9:	0f 8e 30 ff ff ff    	jle    8010631f <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063ef:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801063f4:	66 a3 80 77 19 80    	mov    %ax,0x80197780
801063fa:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
80106401:	08 00 
80106403:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
8010640a:	83 e0 e0             	and    $0xffffffe0,%eax
8010640d:	a2 84 77 19 80       	mov    %al,0x80197784
80106412:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106419:	83 e0 1f             	and    $0x1f,%eax
8010641c:	a2 84 77 19 80       	mov    %al,0x80197784
80106421:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106428:	83 c8 0f             	or     $0xf,%eax
8010642b:	a2 85 77 19 80       	mov    %al,0x80197785
80106430:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106437:	83 e0 ef             	and    $0xffffffef,%eax
8010643a:	a2 85 77 19 80       	mov    %al,0x80197785
8010643f:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106446:	83 c8 60             	or     $0x60,%eax
80106449:	a2 85 77 19 80       	mov    %al,0x80197785
8010644e:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106455:	83 c8 80             	or     $0xffffff80,%eax
80106458:	a2 85 77 19 80       	mov    %al,0x80197785
8010645d:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106462:	c1 e8 10             	shr    $0x10,%eax
80106465:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
8010646b:	83 ec 08             	sub    $0x8,%esp
8010646e:	68 d0 ac 10 80       	push   $0x8010acd0
80106473:	68 40 75 19 80       	push   $0x80197540
80106478:	e8 f8 e5 ff ff       	call   80104a75 <initlock>
8010647d:	83 c4 10             	add    $0x10,%esp
}
80106480:	90                   	nop
80106481:	c9                   	leave
80106482:	c3                   	ret

80106483 <idtinit>:

void
idtinit(void)
{
80106483:	f3 0f 1e fb          	endbr32
80106487:	55                   	push   %ebp
80106488:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010648a:	68 00 08 00 00       	push   $0x800
8010648f:	68 80 75 19 80       	push   $0x80197580
80106494:	e8 35 fe ff ff       	call   801062ce <lidt>
80106499:	83 c4 08             	add    $0x8,%esp
}
8010649c:	90                   	nop
8010649d:	c9                   	leave
8010649e:	c3                   	ret

8010649f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010649f:	f3 0f 1e fb          	endbr32
801064a3:	55                   	push   %ebp
801064a4:	89 e5                	mov    %esp,%ebp
801064a6:	57                   	push   %edi
801064a7:	56                   	push   %esi
801064a8:	53                   	push   %ebx
801064a9:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801064ac:	8b 45 08             	mov    0x8(%ebp),%eax
801064af:	8b 40 30             	mov    0x30(%eax),%eax
801064b2:	83 f8 40             	cmp    $0x40,%eax
801064b5:	75 3b                	jne    801064f2 <trap+0x53>
    if(myproc()->killed)
801064b7:	e8 4b d7 ff ff       	call   80103c07 <myproc>
801064bc:	8b 40 24             	mov    0x24(%eax),%eax
801064bf:	85 c0                	test   %eax,%eax
801064c1:	74 05                	je     801064c8 <trap+0x29>
      exit();
801064c3:	e8 df db ff ff       	call   801040a7 <exit>
    myproc()->tf = tf;
801064c8:	e8 3a d7 ff ff       	call   80103c07 <myproc>
801064cd:	8b 55 08             	mov    0x8(%ebp),%edx
801064d0:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801064d3:	e8 50 ec ff ff       	call   80105128 <syscall>
    if(myproc()->killed)
801064d8:	e8 2a d7 ff ff       	call   80103c07 <myproc>
801064dd:	8b 40 24             	mov    0x24(%eax),%eax
801064e0:	85 c0                	test   %eax,%eax
801064e2:	0f 84 0d 03 00 00    	je     801067f5 <trap+0x356>
      exit();
801064e8:	e8 ba db ff ff       	call   801040a7 <exit>
    return;
801064ed:	e9 03 03 00 00       	jmp    801067f5 <trap+0x356>
  }

  switch(tf->trapno){
801064f2:	8b 45 08             	mov    0x8(%ebp),%eax
801064f5:	8b 40 30             	mov    0x30(%eax),%eax
801064f8:	83 e8 0e             	sub    $0xe,%eax
801064fb:	83 f8 31             	cmp    $0x31,%eax
801064fe:	0f 87 bc 01 00 00    	ja     801066c0 <trap+0x221>
80106504:	8b 04 85 a4 ad 10 80 	mov    -0x7fef525c(,%eax,4),%eax
8010650b:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010650e:	e8 59 d6 ff ff       	call   80103b6c <cpuid>
80106513:	85 c0                	test   %eax,%eax
80106515:	75 3d                	jne    80106554 <trap+0xb5>
      acquire(&tickslock);
80106517:	83 ec 0c             	sub    $0xc,%esp
8010651a:	68 40 75 19 80       	push   $0x80197540
8010651f:	e8 77 e5 ff ff       	call   80104a9b <acquire>
80106524:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106527:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010652c:	83 c0 01             	add    $0x1,%eax
8010652f:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106534:	83 ec 0c             	sub    $0xc,%esp
80106537:	68 80 7d 19 80       	push   $0x80197d80
8010653c:	e8 c0 e0 ff ff       	call   80104601 <wakeup>
80106541:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106544:	83 ec 0c             	sub    $0xc,%esp
80106547:	68 40 75 19 80       	push   $0x80197540
8010654c:	e8 bc e5 ff ff       	call   80104b0d <release>
80106551:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106554:	e8 2a c7 ff ff       	call   80102c83 <lapiceoi>


    break;
80106559:	e9 17 02 00 00       	jmp    80106775 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010655e:	e8 fd 40 00 00       	call   8010a660 <ideintr>
    lapiceoi();
80106563:	e8 1b c7 ff ff       	call   80102c83 <lapiceoi>
    break;
80106568:	e9 08 02 00 00       	jmp    80106775 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010656d:	e8 47 c5 ff ff       	call   80102ab9 <kbdintr>
    lapiceoi();
80106572:	e8 0c c7 ff ff       	call   80102c83 <lapiceoi>
    break;
80106577:	e9 f9 01 00 00       	jmp    80106775 <trap+0x2d6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010657c:	e8 56 04 00 00       	call   801069d7 <uartintr>
    lapiceoi();
80106581:	e8 fd c6 ff ff       	call   80102c83 <lapiceoi>
    break;
80106586:	e9 ea 01 00 00       	jmp    80106775 <trap+0x2d6>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010658b:	e8 0f 2d 00 00       	call   8010929f <i8254_intr>
    lapiceoi();
80106590:	e8 ee c6 ff ff       	call   80102c83 <lapiceoi>
    break;
80106595:	e9 db 01 00 00       	jmp    80106775 <trap+0x2d6>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010659a:	8b 45 08             	mov    0x8(%ebp),%eax
8010659d:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065a0:	8b 45 08             	mov    0x8(%ebp),%eax
801065a3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065a7:	0f b7 d8             	movzwl %ax,%ebx
801065aa:	e8 bd d5 ff ff       	call   80103b6c <cpuid>
801065af:	56                   	push   %esi
801065b0:	53                   	push   %ebx
801065b1:	50                   	push   %eax
801065b2:	68 d8 ac 10 80       	push   $0x8010acd8
801065b7:	e8 50 9e ff ff       	call   8010040c <cprintf>
801065bc:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065bf:	e8 bf c6 ff ff       	call   80102c83 <lapiceoi>
    break;
801065c4:	e9 ac 01 00 00       	jmp    80106775 <trap+0x2d6>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
801065c9:	e8 39 d6 ff ff       	call   80103c07 <myproc>
801065ce:	8b 40 24             	mov    0x24(%eax),%eax
801065d1:	85 c0                	test   %eax,%eax
801065d3:	74 05                	je     801065da <trap+0x13b>
      exit();
801065d5:	e8 cd da ff ff       	call   801040a7 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    uint sp;
    p = myproc();
801065da:	e8 28 d6 ff ff       	call   80103c07 <myproc>
801065df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801065e2:	e8 11 fd ff ff       	call   801062f8 <rcr2>
801065e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
801065ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065f2:	8b 40 04             	mov    0x4(%eax),%eax
801065f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    sp = p->tf->esp;
801065f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065fb:	8b 40 18             	mov    0x18(%eax),%eax
801065fe:	8b 40 44             	mov    0x44(%eax),%eax
80106601:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // sz+PGSIZE보다 크면 비정상적인 힙 영역 접근
    // sp-PGSIZE보다 작으면 비정상적인 스택 접근
    if (va > p->sz + PGSIZE && va < sp - PGSIZE){
80106604:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106607:	8b 00                	mov    (%eax),%eax
80106609:	05 00 10 00 00       	add    $0x1000,%eax
8010660e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106611:	76 48                	jbe    8010665b <trap+0x1bc>
80106613:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106616:	2d 00 10 00 00       	sub    $0x1000,%eax
8010661b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010661e:	73 3b                	jae    8010665b <trap+0x1bc>
      cprintf("invaild access va %x sz %x sp %x eip %x\n",rcr2(),p->sz,sp, p->tf->eip);
80106620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106623:	8b 40 18             	mov    0x18(%eax),%eax
80106626:	8b 70 38             	mov    0x38(%eax),%esi
80106629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010662c:	8b 18                	mov    (%eax),%ebx
8010662e:	e8 c5 fc ff ff       	call   801062f8 <rcr2>
80106633:	83 ec 0c             	sub    $0xc,%esp
80106636:	56                   	push   %esi
80106637:	ff 75 d8             	push   -0x28(%ebp)
8010663a:	53                   	push   %ebx
8010663b:	50                   	push   %eax
8010663c:	68 fc ac 10 80       	push   $0x8010acfc
80106641:	e8 c6 9d ff ff       	call   8010040c <cprintf>
80106646:	83 c4 20             	add    $0x20,%esp
      kill(p->pid);
80106649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010664c:	8b 40 10             	mov    0x10(%eax),%eax
8010664f:	83 ec 0c             	sub    $0xc,%esp
80106652:	50                   	push   %eax
80106653:	e8 e4 df ff ff       	call   8010463c <kill>
80106658:	83 c4 10             	add    $0x10,%esp
    }

    if (va <= p->sz + PGSIZE){
8010665b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010665e:	8b 00                	mov    (%eax),%eax
80106660:	05 00 10 00 00       	add    $0x1000,%eax
80106665:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106668:	77 1c                	ja     80106686 <trap+0x1e7>
      allocuvm(pgdir, va, va + PGSIZE);
8010666a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010666d:	05 00 10 00 00       	add    $0x1000,%eax
80106672:	83 ec 04             	sub    $0x4,%esp
80106675:	50                   	push   %eax
80106676:	ff 75 e0             	push   -0x20(%ebp)
80106679:	ff 75 dc             	push   -0x24(%ebp)
8010667c:	e8 cc 16 00 00       	call   80107d4d <allocuvm>
80106681:	83 c4 10             	add    $0x10,%esp
80106684:	eb 27                	jmp    801066ad <trap+0x20e>
    }
    else if (va >= sp - PGSIZE)
80106686:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106689:	2d 00 10 00 00       	sub    $0x1000,%eax
8010668e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106691:	72 1a                	jb     801066ad <trap+0x20e>
    {
      allocuvm(pgdir, va, va + PGSIZE);
80106693:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106696:	05 00 10 00 00       	add    $0x1000,%eax
8010669b:	83 ec 04             	sub    $0x4,%esp
8010669e:	50                   	push   %eax
8010669f:	ff 75 e0             	push   -0x20(%ebp)
801066a2:	ff 75 dc             	push   -0x24(%ebp)
801066a5:	e8 a3 16 00 00       	call   80107d4d <allocuvm>
801066aa:	83 c4 10             	add    $0x10,%esp
    }

    // flush
    switchuvm(p);
801066ad:	83 ec 0c             	sub    $0xc,%esp
801066b0:	ff 75 e4             	push   -0x1c(%ebp)
801066b3:	e8 ad 13 00 00       	call   80107a65 <switchuvm>
801066b8:	83 c4 10             	add    $0x10,%esp
    break;
801066bb:	e9 b5 00 00 00       	jmp    80106775 <trap+0x2d6>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801066c0:	e8 42 d5 ff ff       	call   80103c07 <myproc>
801066c5:	85 c0                	test   %eax,%eax
801066c7:	74 11                	je     801066da <trap+0x23b>
801066c9:	8b 45 08             	mov    0x8(%ebp),%eax
801066cc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066d0:	0f b7 c0             	movzwl %ax,%eax
801066d3:	83 e0 03             	and    $0x3,%eax
801066d6:	85 c0                	test   %eax,%eax
801066d8:	75 39                	jne    80106713 <trap+0x274>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801066da:	e8 19 fc ff ff       	call   801062f8 <rcr2>
801066df:	89 c3                	mov    %eax,%ebx
801066e1:	8b 45 08             	mov    0x8(%ebp),%eax
801066e4:	8b 70 38             	mov    0x38(%eax),%esi
801066e7:	e8 80 d4 ff ff       	call   80103b6c <cpuid>
801066ec:	8b 55 08             	mov    0x8(%ebp),%edx
801066ef:	8b 52 30             	mov    0x30(%edx),%edx
801066f2:	83 ec 0c             	sub    $0xc,%esp
801066f5:	53                   	push   %ebx
801066f6:	56                   	push   %esi
801066f7:	50                   	push   %eax
801066f8:	52                   	push   %edx
801066f9:	68 28 ad 10 80       	push   $0x8010ad28
801066fe:	e8 09 9d ff ff       	call   8010040c <cprintf>
80106703:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106706:	83 ec 0c             	sub    $0xc,%esp
80106709:	68 5a ad 10 80       	push   $0x8010ad5a
8010670e:	e8 cb 9e ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106713:	e8 e0 fb ff ff       	call   801062f8 <rcr2>
80106718:	89 c6                	mov    %eax,%esi
8010671a:	8b 45 08             	mov    0x8(%ebp),%eax
8010671d:	8b 40 38             	mov    0x38(%eax),%eax
80106720:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106723:	e8 44 d4 ff ff       	call   80103b6c <cpuid>
80106728:	89 c3                	mov    %eax,%ebx
8010672a:	8b 45 08             	mov    0x8(%ebp),%eax
8010672d:	8b 48 34             	mov    0x34(%eax),%ecx
80106730:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106733:	8b 45 08             	mov    0x8(%ebp),%eax
80106736:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106739:	e8 c9 d4 ff ff       	call   80103c07 <myproc>
8010673e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106741:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106744:	e8 be d4 ff ff       	call   80103c07 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106749:	8b 40 10             	mov    0x10(%eax),%eax
8010674c:	56                   	push   %esi
8010674d:	ff 75 d4             	push   -0x2c(%ebp)
80106750:	53                   	push   %ebx
80106751:	ff 75 d0             	push   -0x30(%ebp)
80106754:	57                   	push   %edi
80106755:	ff 75 cc             	push   -0x34(%ebp)
80106758:	50                   	push   %eax
80106759:	68 60 ad 10 80       	push   $0x8010ad60
8010675e:	e8 a9 9c ff ff       	call   8010040c <cprintf>
80106763:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106766:	e8 9c d4 ff ff       	call   80103c07 <myproc>
8010676b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106772:	eb 01                	jmp    80106775 <trap+0x2d6>
    break;
80106774:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106775:	e8 8d d4 ff ff       	call   80103c07 <myproc>
8010677a:	85 c0                	test   %eax,%eax
8010677c:	74 23                	je     801067a1 <trap+0x302>
8010677e:	e8 84 d4 ff ff       	call   80103c07 <myproc>
80106783:	8b 40 24             	mov    0x24(%eax),%eax
80106786:	85 c0                	test   %eax,%eax
80106788:	74 17                	je     801067a1 <trap+0x302>
8010678a:	8b 45 08             	mov    0x8(%ebp),%eax
8010678d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106791:	0f b7 c0             	movzwl %ax,%eax
80106794:	83 e0 03             	and    $0x3,%eax
80106797:	83 f8 03             	cmp    $0x3,%eax
8010679a:	75 05                	jne    801067a1 <trap+0x302>
    exit();
8010679c:	e8 06 d9 ff ff       	call   801040a7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801067a1:	e8 61 d4 ff ff       	call   80103c07 <myproc>
801067a6:	85 c0                	test   %eax,%eax
801067a8:	74 1d                	je     801067c7 <trap+0x328>
801067aa:	e8 58 d4 ff ff       	call   80103c07 <myproc>
801067af:	8b 40 0c             	mov    0xc(%eax),%eax
801067b2:	83 f8 04             	cmp    $0x4,%eax
801067b5:	75 10                	jne    801067c7 <trap+0x328>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801067b7:	8b 45 08             	mov    0x8(%ebp),%eax
801067ba:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801067bd:	83 f8 20             	cmp    $0x20,%eax
801067c0:	75 05                	jne    801067c7 <trap+0x328>
    yield();
801067c2:	e8 c3 dc ff ff       	call   8010448a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067c7:	e8 3b d4 ff ff       	call   80103c07 <myproc>
801067cc:	85 c0                	test   %eax,%eax
801067ce:	74 26                	je     801067f6 <trap+0x357>
801067d0:	e8 32 d4 ff ff       	call   80103c07 <myproc>
801067d5:	8b 40 24             	mov    0x24(%eax),%eax
801067d8:	85 c0                	test   %eax,%eax
801067da:	74 1a                	je     801067f6 <trap+0x357>
801067dc:	8b 45 08             	mov    0x8(%ebp),%eax
801067df:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067e3:	0f b7 c0             	movzwl %ax,%eax
801067e6:	83 e0 03             	and    $0x3,%eax
801067e9:	83 f8 03             	cmp    $0x3,%eax
801067ec:	75 08                	jne    801067f6 <trap+0x357>
    exit();
801067ee:	e8 b4 d8 ff ff       	call   801040a7 <exit>
801067f3:	eb 01                	jmp    801067f6 <trap+0x357>
    return;
801067f5:	90                   	nop
}
801067f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067f9:	5b                   	pop    %ebx
801067fa:	5e                   	pop    %esi
801067fb:	5f                   	pop    %edi
801067fc:	5d                   	pop    %ebp
801067fd:	c3                   	ret

801067fe <inb>:
{
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 14             	sub    $0x14,%esp
80106804:	8b 45 08             	mov    0x8(%ebp),%eax
80106807:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010680b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010680f:	89 c2                	mov    %eax,%edx
80106811:	ec                   	in     (%dx),%al
80106812:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106815:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106819:	c9                   	leave
8010681a:	c3                   	ret

8010681b <outb>:
{
8010681b:	55                   	push   %ebp
8010681c:	89 e5                	mov    %esp,%ebp
8010681e:	83 ec 08             	sub    $0x8,%esp
80106821:	8b 45 08             	mov    0x8(%ebp),%eax
80106824:	8b 55 0c             	mov    0xc(%ebp),%edx
80106827:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010682b:	89 d0                	mov    %edx,%eax
8010682d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106830:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106834:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106838:	ee                   	out    %al,(%dx)
}
80106839:	90                   	nop
8010683a:	c9                   	leave
8010683b:	c3                   	ret

8010683c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010683c:	f3 0f 1e fb          	endbr32
80106840:	55                   	push   %ebp
80106841:	89 e5                	mov    %esp,%ebp
80106843:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106846:	6a 00                	push   $0x0
80106848:	68 fa 03 00 00       	push   $0x3fa
8010684d:	e8 c9 ff ff ff       	call   8010681b <outb>
80106852:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106855:	68 80 00 00 00       	push   $0x80
8010685a:	68 fb 03 00 00       	push   $0x3fb
8010685f:	e8 b7 ff ff ff       	call   8010681b <outb>
80106864:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106867:	6a 0c                	push   $0xc
80106869:	68 f8 03 00 00       	push   $0x3f8
8010686e:	e8 a8 ff ff ff       	call   8010681b <outb>
80106873:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106876:	6a 00                	push   $0x0
80106878:	68 f9 03 00 00       	push   $0x3f9
8010687d:	e8 99 ff ff ff       	call   8010681b <outb>
80106882:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106885:	6a 03                	push   $0x3
80106887:	68 fb 03 00 00       	push   $0x3fb
8010688c:	e8 8a ff ff ff       	call   8010681b <outb>
80106891:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106894:	6a 00                	push   $0x0
80106896:	68 fc 03 00 00       	push   $0x3fc
8010689b:	e8 7b ff ff ff       	call   8010681b <outb>
801068a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801068a3:	6a 01                	push   $0x1
801068a5:	68 f9 03 00 00       	push   $0x3f9
801068aa:	e8 6c ff ff ff       	call   8010681b <outb>
801068af:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801068b2:	68 fd 03 00 00       	push   $0x3fd
801068b7:	e8 42 ff ff ff       	call   801067fe <inb>
801068bc:	83 c4 04             	add    $0x4,%esp
801068bf:	3c ff                	cmp    $0xff,%al
801068c1:	74 61                	je     80106924 <uartinit+0xe8>
    return;
  uart = 1;
801068c3:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801068ca:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801068cd:	68 fa 03 00 00       	push   $0x3fa
801068d2:	e8 27 ff ff ff       	call   801067fe <inb>
801068d7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801068da:	68 f8 03 00 00       	push   $0x3f8
801068df:	e8 1a ff ff ff       	call   801067fe <inb>
801068e4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801068e7:	83 ec 08             	sub    $0x8,%esp
801068ea:	6a 00                	push   $0x0
801068ec:	6a 04                	push   $0x4
801068ee:	e8 77 be ff ff       	call   8010276a <ioapicenable>
801068f3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801068f6:	c7 45 f4 6c ae 10 80 	movl   $0x8010ae6c,-0xc(%ebp)
801068fd:	eb 19                	jmp    80106918 <uartinit+0xdc>
    uartputc(*p);
801068ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106902:	0f b6 00             	movzbl (%eax),%eax
80106905:	0f be c0             	movsbl %al,%eax
80106908:	83 ec 0c             	sub    $0xc,%esp
8010690b:	50                   	push   %eax
8010690c:	e8 16 00 00 00       	call   80106927 <uartputc>
80106911:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106914:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691b:	0f b6 00             	movzbl (%eax),%eax
8010691e:	84 c0                	test   %al,%al
80106920:	75 dd                	jne    801068ff <uartinit+0xc3>
80106922:	eb 01                	jmp    80106925 <uartinit+0xe9>
    return;
80106924:	90                   	nop
}
80106925:	c9                   	leave
80106926:	c3                   	ret

80106927 <uartputc>:

void
uartputc(int c)
{
80106927:	f3 0f 1e fb          	endbr32
8010692b:	55                   	push   %ebp
8010692c:	89 e5                	mov    %esp,%ebp
8010692e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106931:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106936:	85 c0                	test   %eax,%eax
80106938:	74 53                	je     8010698d <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010693a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106941:	eb 11                	jmp    80106954 <uartputc+0x2d>
    microdelay(10);
80106943:	83 ec 0c             	sub    $0xc,%esp
80106946:	6a 0a                	push   $0xa
80106948:	e8 55 c3 ff ff       	call   80102ca2 <microdelay>
8010694d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106950:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106954:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106958:	7f 1a                	jg     80106974 <uartputc+0x4d>
8010695a:	83 ec 0c             	sub    $0xc,%esp
8010695d:	68 fd 03 00 00       	push   $0x3fd
80106962:	e8 97 fe ff ff       	call   801067fe <inb>
80106967:	83 c4 10             	add    $0x10,%esp
8010696a:	0f b6 c0             	movzbl %al,%eax
8010696d:	83 e0 20             	and    $0x20,%eax
80106970:	85 c0                	test   %eax,%eax
80106972:	74 cf                	je     80106943 <uartputc+0x1c>
  outb(COM1+0, c);
80106974:	8b 45 08             	mov    0x8(%ebp),%eax
80106977:	0f b6 c0             	movzbl %al,%eax
8010697a:	83 ec 08             	sub    $0x8,%esp
8010697d:	50                   	push   %eax
8010697e:	68 f8 03 00 00       	push   $0x3f8
80106983:	e8 93 fe ff ff       	call   8010681b <outb>
80106988:	83 c4 10             	add    $0x10,%esp
8010698b:	eb 01                	jmp    8010698e <uartputc+0x67>
    return;
8010698d:	90                   	nop
}
8010698e:	c9                   	leave
8010698f:	c3                   	ret

80106990 <uartgetc>:

static int
uartgetc(void)
{
80106990:	f3 0f 1e fb          	endbr32
80106994:	55                   	push   %ebp
80106995:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106997:	a1 60 d0 18 80       	mov    0x8018d060,%eax
8010699c:	85 c0                	test   %eax,%eax
8010699e:	75 07                	jne    801069a7 <uartgetc+0x17>
    return -1;
801069a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a5:	eb 2e                	jmp    801069d5 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801069a7:	68 fd 03 00 00       	push   $0x3fd
801069ac:	e8 4d fe ff ff       	call   801067fe <inb>
801069b1:	83 c4 04             	add    $0x4,%esp
801069b4:	0f b6 c0             	movzbl %al,%eax
801069b7:	83 e0 01             	and    $0x1,%eax
801069ba:	85 c0                	test   %eax,%eax
801069bc:	75 07                	jne    801069c5 <uartgetc+0x35>
    return -1;
801069be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c3:	eb 10                	jmp    801069d5 <uartgetc+0x45>
  return inb(COM1+0);
801069c5:	68 f8 03 00 00       	push   $0x3f8
801069ca:	e8 2f fe ff ff       	call   801067fe <inb>
801069cf:	83 c4 04             	add    $0x4,%esp
801069d2:	0f b6 c0             	movzbl %al,%eax
}
801069d5:	c9                   	leave
801069d6:	c3                   	ret

801069d7 <uartintr>:

void
uartintr(void)
{
801069d7:	f3 0f 1e fb          	endbr32
801069db:	55                   	push   %ebp
801069dc:	89 e5                	mov    %esp,%ebp
801069de:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801069e1:	83 ec 0c             	sub    $0xc,%esp
801069e4:	68 90 69 10 80       	push   $0x80106990
801069e9:	e8 2b 9e ff ff       	call   80100819 <consoleintr>
801069ee:	83 c4 10             	add    $0x10,%esp
}
801069f1:	90                   	nop
801069f2:	c9                   	leave
801069f3:	c3                   	ret

801069f4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $0
801069f6:	6a 00                	push   $0x0
  jmp alltraps
801069f8:	e9 ae f8 ff ff       	jmp    801062ab <alltraps>

801069fd <vector1>:
.globl vector1
vector1:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $1
801069ff:	6a 01                	push   $0x1
  jmp alltraps
80106a01:	e9 a5 f8 ff ff       	jmp    801062ab <alltraps>

80106a06 <vector2>:
.globl vector2
vector2:
  pushl $0
80106a06:	6a 00                	push   $0x0
  pushl $2
80106a08:	6a 02                	push   $0x2
  jmp alltraps
80106a0a:	e9 9c f8 ff ff       	jmp    801062ab <alltraps>

80106a0f <vector3>:
.globl vector3
vector3:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $3
80106a11:	6a 03                	push   $0x3
  jmp alltraps
80106a13:	e9 93 f8 ff ff       	jmp    801062ab <alltraps>

80106a18 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $4
80106a1a:	6a 04                	push   $0x4
  jmp alltraps
80106a1c:	e9 8a f8 ff ff       	jmp    801062ab <alltraps>

80106a21 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $5
80106a23:	6a 05                	push   $0x5
  jmp alltraps
80106a25:	e9 81 f8 ff ff       	jmp    801062ab <alltraps>

80106a2a <vector6>:
.globl vector6
vector6:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $6
80106a2c:	6a 06                	push   $0x6
  jmp alltraps
80106a2e:	e9 78 f8 ff ff       	jmp    801062ab <alltraps>

80106a33 <vector7>:
.globl vector7
vector7:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $7
80106a35:	6a 07                	push   $0x7
  jmp alltraps
80106a37:	e9 6f f8 ff ff       	jmp    801062ab <alltraps>

80106a3c <vector8>:
.globl vector8
vector8:
  pushl $8
80106a3c:	6a 08                	push   $0x8
  jmp alltraps
80106a3e:	e9 68 f8 ff ff       	jmp    801062ab <alltraps>

80106a43 <vector9>:
.globl vector9
vector9:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $9
80106a45:	6a 09                	push   $0x9
  jmp alltraps
80106a47:	e9 5f f8 ff ff       	jmp    801062ab <alltraps>

80106a4c <vector10>:
.globl vector10
vector10:
  pushl $10
80106a4c:	6a 0a                	push   $0xa
  jmp alltraps
80106a4e:	e9 58 f8 ff ff       	jmp    801062ab <alltraps>

80106a53 <vector11>:
.globl vector11
vector11:
  pushl $11
80106a53:	6a 0b                	push   $0xb
  jmp alltraps
80106a55:	e9 51 f8 ff ff       	jmp    801062ab <alltraps>

80106a5a <vector12>:
.globl vector12
vector12:
  pushl $12
80106a5a:	6a 0c                	push   $0xc
  jmp alltraps
80106a5c:	e9 4a f8 ff ff       	jmp    801062ab <alltraps>

80106a61 <vector13>:
.globl vector13
vector13:
  pushl $13
80106a61:	6a 0d                	push   $0xd
  jmp alltraps
80106a63:	e9 43 f8 ff ff       	jmp    801062ab <alltraps>

80106a68 <vector14>:
.globl vector14
vector14:
  pushl $14
80106a68:	6a 0e                	push   $0xe
  jmp alltraps
80106a6a:	e9 3c f8 ff ff       	jmp    801062ab <alltraps>

80106a6f <vector15>:
.globl vector15
vector15:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $15
80106a71:	6a 0f                	push   $0xf
  jmp alltraps
80106a73:	e9 33 f8 ff ff       	jmp    801062ab <alltraps>

80106a78 <vector16>:
.globl vector16
vector16:
  pushl $0
80106a78:	6a 00                	push   $0x0
  pushl $16
80106a7a:	6a 10                	push   $0x10
  jmp alltraps
80106a7c:	e9 2a f8 ff ff       	jmp    801062ab <alltraps>

80106a81 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a81:	6a 11                	push   $0x11
  jmp alltraps
80106a83:	e9 23 f8 ff ff       	jmp    801062ab <alltraps>

80106a88 <vector18>:
.globl vector18
vector18:
  pushl $0
80106a88:	6a 00                	push   $0x0
  pushl $18
80106a8a:	6a 12                	push   $0x12
  jmp alltraps
80106a8c:	e9 1a f8 ff ff       	jmp    801062ab <alltraps>

80106a91 <vector19>:
.globl vector19
vector19:
  pushl $0
80106a91:	6a 00                	push   $0x0
  pushl $19
80106a93:	6a 13                	push   $0x13
  jmp alltraps
80106a95:	e9 11 f8 ff ff       	jmp    801062ab <alltraps>

80106a9a <vector20>:
.globl vector20
vector20:
  pushl $0
80106a9a:	6a 00                	push   $0x0
  pushl $20
80106a9c:	6a 14                	push   $0x14
  jmp alltraps
80106a9e:	e9 08 f8 ff ff       	jmp    801062ab <alltraps>

80106aa3 <vector21>:
.globl vector21
vector21:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $21
80106aa5:	6a 15                	push   $0x15
  jmp alltraps
80106aa7:	e9 ff f7 ff ff       	jmp    801062ab <alltraps>

80106aac <vector22>:
.globl vector22
vector22:
  pushl $0
80106aac:	6a 00                	push   $0x0
  pushl $22
80106aae:	6a 16                	push   $0x16
  jmp alltraps
80106ab0:	e9 f6 f7 ff ff       	jmp    801062ab <alltraps>

80106ab5 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ab5:	6a 00                	push   $0x0
  pushl $23
80106ab7:	6a 17                	push   $0x17
  jmp alltraps
80106ab9:	e9 ed f7 ff ff       	jmp    801062ab <alltraps>

80106abe <vector24>:
.globl vector24
vector24:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $24
80106ac0:	6a 18                	push   $0x18
  jmp alltraps
80106ac2:	e9 e4 f7 ff ff       	jmp    801062ab <alltraps>

80106ac7 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $25
80106ac9:	6a 19                	push   $0x19
  jmp alltraps
80106acb:	e9 db f7 ff ff       	jmp    801062ab <alltraps>

80106ad0 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ad0:	6a 00                	push   $0x0
  pushl $26
80106ad2:	6a 1a                	push   $0x1a
  jmp alltraps
80106ad4:	e9 d2 f7 ff ff       	jmp    801062ab <alltraps>

80106ad9 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ad9:	6a 00                	push   $0x0
  pushl $27
80106adb:	6a 1b                	push   $0x1b
  jmp alltraps
80106add:	e9 c9 f7 ff ff       	jmp    801062ab <alltraps>

80106ae2 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $28
80106ae4:	6a 1c                	push   $0x1c
  jmp alltraps
80106ae6:	e9 c0 f7 ff ff       	jmp    801062ab <alltraps>

80106aeb <vector29>:
.globl vector29
vector29:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $29
80106aed:	6a 1d                	push   $0x1d
  jmp alltraps
80106aef:	e9 b7 f7 ff ff       	jmp    801062ab <alltraps>

80106af4 <vector30>:
.globl vector30
vector30:
  pushl $0
80106af4:	6a 00                	push   $0x0
  pushl $30
80106af6:	6a 1e                	push   $0x1e
  jmp alltraps
80106af8:	e9 ae f7 ff ff       	jmp    801062ab <alltraps>

80106afd <vector31>:
.globl vector31
vector31:
  pushl $0
80106afd:	6a 00                	push   $0x0
  pushl $31
80106aff:	6a 1f                	push   $0x1f
  jmp alltraps
80106b01:	e9 a5 f7 ff ff       	jmp    801062ab <alltraps>

80106b06 <vector32>:
.globl vector32
vector32:
  pushl $0
80106b06:	6a 00                	push   $0x0
  pushl $32
80106b08:	6a 20                	push   $0x20
  jmp alltraps
80106b0a:	e9 9c f7 ff ff       	jmp    801062ab <alltraps>

80106b0f <vector33>:
.globl vector33
vector33:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $33
80106b11:	6a 21                	push   $0x21
  jmp alltraps
80106b13:	e9 93 f7 ff ff       	jmp    801062ab <alltraps>

80106b18 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b18:	6a 00                	push   $0x0
  pushl $34
80106b1a:	6a 22                	push   $0x22
  jmp alltraps
80106b1c:	e9 8a f7 ff ff       	jmp    801062ab <alltraps>

80106b21 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b21:	6a 00                	push   $0x0
  pushl $35
80106b23:	6a 23                	push   $0x23
  jmp alltraps
80106b25:	e9 81 f7 ff ff       	jmp    801062ab <alltraps>

80106b2a <vector36>:
.globl vector36
vector36:
  pushl $0
80106b2a:	6a 00                	push   $0x0
  pushl $36
80106b2c:	6a 24                	push   $0x24
  jmp alltraps
80106b2e:	e9 78 f7 ff ff       	jmp    801062ab <alltraps>

80106b33 <vector37>:
.globl vector37
vector37:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $37
80106b35:	6a 25                	push   $0x25
  jmp alltraps
80106b37:	e9 6f f7 ff ff       	jmp    801062ab <alltraps>

80106b3c <vector38>:
.globl vector38
vector38:
  pushl $0
80106b3c:	6a 00                	push   $0x0
  pushl $38
80106b3e:	6a 26                	push   $0x26
  jmp alltraps
80106b40:	e9 66 f7 ff ff       	jmp    801062ab <alltraps>

80106b45 <vector39>:
.globl vector39
vector39:
  pushl $0
80106b45:	6a 00                	push   $0x0
  pushl $39
80106b47:	6a 27                	push   $0x27
  jmp alltraps
80106b49:	e9 5d f7 ff ff       	jmp    801062ab <alltraps>

80106b4e <vector40>:
.globl vector40
vector40:
  pushl $0
80106b4e:	6a 00                	push   $0x0
  pushl $40
80106b50:	6a 28                	push   $0x28
  jmp alltraps
80106b52:	e9 54 f7 ff ff       	jmp    801062ab <alltraps>

80106b57 <vector41>:
.globl vector41
vector41:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $41
80106b59:	6a 29                	push   $0x29
  jmp alltraps
80106b5b:	e9 4b f7 ff ff       	jmp    801062ab <alltraps>

80106b60 <vector42>:
.globl vector42
vector42:
  pushl $0
80106b60:	6a 00                	push   $0x0
  pushl $42
80106b62:	6a 2a                	push   $0x2a
  jmp alltraps
80106b64:	e9 42 f7 ff ff       	jmp    801062ab <alltraps>

80106b69 <vector43>:
.globl vector43
vector43:
  pushl $0
80106b69:	6a 00                	push   $0x0
  pushl $43
80106b6b:	6a 2b                	push   $0x2b
  jmp alltraps
80106b6d:	e9 39 f7 ff ff       	jmp    801062ab <alltraps>

80106b72 <vector44>:
.globl vector44
vector44:
  pushl $0
80106b72:	6a 00                	push   $0x0
  pushl $44
80106b74:	6a 2c                	push   $0x2c
  jmp alltraps
80106b76:	e9 30 f7 ff ff       	jmp    801062ab <alltraps>

80106b7b <vector45>:
.globl vector45
vector45:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $45
80106b7d:	6a 2d                	push   $0x2d
  jmp alltraps
80106b7f:	e9 27 f7 ff ff       	jmp    801062ab <alltraps>

80106b84 <vector46>:
.globl vector46
vector46:
  pushl $0
80106b84:	6a 00                	push   $0x0
  pushl $46
80106b86:	6a 2e                	push   $0x2e
  jmp alltraps
80106b88:	e9 1e f7 ff ff       	jmp    801062ab <alltraps>

80106b8d <vector47>:
.globl vector47
vector47:
  pushl $0
80106b8d:	6a 00                	push   $0x0
  pushl $47
80106b8f:	6a 2f                	push   $0x2f
  jmp alltraps
80106b91:	e9 15 f7 ff ff       	jmp    801062ab <alltraps>

80106b96 <vector48>:
.globl vector48
vector48:
  pushl $0
80106b96:	6a 00                	push   $0x0
  pushl $48
80106b98:	6a 30                	push   $0x30
  jmp alltraps
80106b9a:	e9 0c f7 ff ff       	jmp    801062ab <alltraps>

80106b9f <vector49>:
.globl vector49
vector49:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $49
80106ba1:	6a 31                	push   $0x31
  jmp alltraps
80106ba3:	e9 03 f7 ff ff       	jmp    801062ab <alltraps>

80106ba8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ba8:	6a 00                	push   $0x0
  pushl $50
80106baa:	6a 32                	push   $0x32
  jmp alltraps
80106bac:	e9 fa f6 ff ff       	jmp    801062ab <alltraps>

80106bb1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106bb1:	6a 00                	push   $0x0
  pushl $51
80106bb3:	6a 33                	push   $0x33
  jmp alltraps
80106bb5:	e9 f1 f6 ff ff       	jmp    801062ab <alltraps>

80106bba <vector52>:
.globl vector52
vector52:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $52
80106bbc:	6a 34                	push   $0x34
  jmp alltraps
80106bbe:	e9 e8 f6 ff ff       	jmp    801062ab <alltraps>

80106bc3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $53
80106bc5:	6a 35                	push   $0x35
  jmp alltraps
80106bc7:	e9 df f6 ff ff       	jmp    801062ab <alltraps>

80106bcc <vector54>:
.globl vector54
vector54:
  pushl $0
80106bcc:	6a 00                	push   $0x0
  pushl $54
80106bce:	6a 36                	push   $0x36
  jmp alltraps
80106bd0:	e9 d6 f6 ff ff       	jmp    801062ab <alltraps>

80106bd5 <vector55>:
.globl vector55
vector55:
  pushl $0
80106bd5:	6a 00                	push   $0x0
  pushl $55
80106bd7:	6a 37                	push   $0x37
  jmp alltraps
80106bd9:	e9 cd f6 ff ff       	jmp    801062ab <alltraps>

80106bde <vector56>:
.globl vector56
vector56:
  pushl $0
80106bde:	6a 00                	push   $0x0
  pushl $56
80106be0:	6a 38                	push   $0x38
  jmp alltraps
80106be2:	e9 c4 f6 ff ff       	jmp    801062ab <alltraps>

80106be7 <vector57>:
.globl vector57
vector57:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $57
80106be9:	6a 39                	push   $0x39
  jmp alltraps
80106beb:	e9 bb f6 ff ff       	jmp    801062ab <alltraps>

80106bf0 <vector58>:
.globl vector58
vector58:
  pushl $0
80106bf0:	6a 00                	push   $0x0
  pushl $58
80106bf2:	6a 3a                	push   $0x3a
  jmp alltraps
80106bf4:	e9 b2 f6 ff ff       	jmp    801062ab <alltraps>

80106bf9 <vector59>:
.globl vector59
vector59:
  pushl $0
80106bf9:	6a 00                	push   $0x0
  pushl $59
80106bfb:	6a 3b                	push   $0x3b
  jmp alltraps
80106bfd:	e9 a9 f6 ff ff       	jmp    801062ab <alltraps>

80106c02 <vector60>:
.globl vector60
vector60:
  pushl $0
80106c02:	6a 00                	push   $0x0
  pushl $60
80106c04:	6a 3c                	push   $0x3c
  jmp alltraps
80106c06:	e9 a0 f6 ff ff       	jmp    801062ab <alltraps>

80106c0b <vector61>:
.globl vector61
vector61:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $61
80106c0d:	6a 3d                	push   $0x3d
  jmp alltraps
80106c0f:	e9 97 f6 ff ff       	jmp    801062ab <alltraps>

80106c14 <vector62>:
.globl vector62
vector62:
  pushl $0
80106c14:	6a 00                	push   $0x0
  pushl $62
80106c16:	6a 3e                	push   $0x3e
  jmp alltraps
80106c18:	e9 8e f6 ff ff       	jmp    801062ab <alltraps>

80106c1d <vector63>:
.globl vector63
vector63:
  pushl $0
80106c1d:	6a 00                	push   $0x0
  pushl $63
80106c1f:	6a 3f                	push   $0x3f
  jmp alltraps
80106c21:	e9 85 f6 ff ff       	jmp    801062ab <alltraps>

80106c26 <vector64>:
.globl vector64
vector64:
  pushl $0
80106c26:	6a 00                	push   $0x0
  pushl $64
80106c28:	6a 40                	push   $0x40
  jmp alltraps
80106c2a:	e9 7c f6 ff ff       	jmp    801062ab <alltraps>

80106c2f <vector65>:
.globl vector65
vector65:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $65
80106c31:	6a 41                	push   $0x41
  jmp alltraps
80106c33:	e9 73 f6 ff ff       	jmp    801062ab <alltraps>

80106c38 <vector66>:
.globl vector66
vector66:
  pushl $0
80106c38:	6a 00                	push   $0x0
  pushl $66
80106c3a:	6a 42                	push   $0x42
  jmp alltraps
80106c3c:	e9 6a f6 ff ff       	jmp    801062ab <alltraps>

80106c41 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c41:	6a 00                	push   $0x0
  pushl $67
80106c43:	6a 43                	push   $0x43
  jmp alltraps
80106c45:	e9 61 f6 ff ff       	jmp    801062ab <alltraps>

80106c4a <vector68>:
.globl vector68
vector68:
  pushl $0
80106c4a:	6a 00                	push   $0x0
  pushl $68
80106c4c:	6a 44                	push   $0x44
  jmp alltraps
80106c4e:	e9 58 f6 ff ff       	jmp    801062ab <alltraps>

80106c53 <vector69>:
.globl vector69
vector69:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $69
80106c55:	6a 45                	push   $0x45
  jmp alltraps
80106c57:	e9 4f f6 ff ff       	jmp    801062ab <alltraps>

80106c5c <vector70>:
.globl vector70
vector70:
  pushl $0
80106c5c:	6a 00                	push   $0x0
  pushl $70
80106c5e:	6a 46                	push   $0x46
  jmp alltraps
80106c60:	e9 46 f6 ff ff       	jmp    801062ab <alltraps>

80106c65 <vector71>:
.globl vector71
vector71:
  pushl $0
80106c65:	6a 00                	push   $0x0
  pushl $71
80106c67:	6a 47                	push   $0x47
  jmp alltraps
80106c69:	e9 3d f6 ff ff       	jmp    801062ab <alltraps>

80106c6e <vector72>:
.globl vector72
vector72:
  pushl $0
80106c6e:	6a 00                	push   $0x0
  pushl $72
80106c70:	6a 48                	push   $0x48
  jmp alltraps
80106c72:	e9 34 f6 ff ff       	jmp    801062ab <alltraps>

80106c77 <vector73>:
.globl vector73
vector73:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $73
80106c79:	6a 49                	push   $0x49
  jmp alltraps
80106c7b:	e9 2b f6 ff ff       	jmp    801062ab <alltraps>

80106c80 <vector74>:
.globl vector74
vector74:
  pushl $0
80106c80:	6a 00                	push   $0x0
  pushl $74
80106c82:	6a 4a                	push   $0x4a
  jmp alltraps
80106c84:	e9 22 f6 ff ff       	jmp    801062ab <alltraps>

80106c89 <vector75>:
.globl vector75
vector75:
  pushl $0
80106c89:	6a 00                	push   $0x0
  pushl $75
80106c8b:	6a 4b                	push   $0x4b
  jmp alltraps
80106c8d:	e9 19 f6 ff ff       	jmp    801062ab <alltraps>

80106c92 <vector76>:
.globl vector76
vector76:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $76
80106c94:	6a 4c                	push   $0x4c
  jmp alltraps
80106c96:	e9 10 f6 ff ff       	jmp    801062ab <alltraps>

80106c9b <vector77>:
.globl vector77
vector77:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $77
80106c9d:	6a 4d                	push   $0x4d
  jmp alltraps
80106c9f:	e9 07 f6 ff ff       	jmp    801062ab <alltraps>

80106ca4 <vector78>:
.globl vector78
vector78:
  pushl $0
80106ca4:	6a 00                	push   $0x0
  pushl $78
80106ca6:	6a 4e                	push   $0x4e
  jmp alltraps
80106ca8:	e9 fe f5 ff ff       	jmp    801062ab <alltraps>

80106cad <vector79>:
.globl vector79
vector79:
  pushl $0
80106cad:	6a 00                	push   $0x0
  pushl $79
80106caf:	6a 4f                	push   $0x4f
  jmp alltraps
80106cb1:	e9 f5 f5 ff ff       	jmp    801062ab <alltraps>

80106cb6 <vector80>:
.globl vector80
vector80:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $80
80106cb8:	6a 50                	push   $0x50
  jmp alltraps
80106cba:	e9 ec f5 ff ff       	jmp    801062ab <alltraps>

80106cbf <vector81>:
.globl vector81
vector81:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $81
80106cc1:	6a 51                	push   $0x51
  jmp alltraps
80106cc3:	e9 e3 f5 ff ff       	jmp    801062ab <alltraps>

80106cc8 <vector82>:
.globl vector82
vector82:
  pushl $0
80106cc8:	6a 00                	push   $0x0
  pushl $82
80106cca:	6a 52                	push   $0x52
  jmp alltraps
80106ccc:	e9 da f5 ff ff       	jmp    801062ab <alltraps>

80106cd1 <vector83>:
.globl vector83
vector83:
  pushl $0
80106cd1:	6a 00                	push   $0x0
  pushl $83
80106cd3:	6a 53                	push   $0x53
  jmp alltraps
80106cd5:	e9 d1 f5 ff ff       	jmp    801062ab <alltraps>

80106cda <vector84>:
.globl vector84
vector84:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $84
80106cdc:	6a 54                	push   $0x54
  jmp alltraps
80106cde:	e9 c8 f5 ff ff       	jmp    801062ab <alltraps>

80106ce3 <vector85>:
.globl vector85
vector85:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $85
80106ce5:	6a 55                	push   $0x55
  jmp alltraps
80106ce7:	e9 bf f5 ff ff       	jmp    801062ab <alltraps>

80106cec <vector86>:
.globl vector86
vector86:
  pushl $0
80106cec:	6a 00                	push   $0x0
  pushl $86
80106cee:	6a 56                	push   $0x56
  jmp alltraps
80106cf0:	e9 b6 f5 ff ff       	jmp    801062ab <alltraps>

80106cf5 <vector87>:
.globl vector87
vector87:
  pushl $0
80106cf5:	6a 00                	push   $0x0
  pushl $87
80106cf7:	6a 57                	push   $0x57
  jmp alltraps
80106cf9:	e9 ad f5 ff ff       	jmp    801062ab <alltraps>

80106cfe <vector88>:
.globl vector88
vector88:
  pushl $0
80106cfe:	6a 00                	push   $0x0
  pushl $88
80106d00:	6a 58                	push   $0x58
  jmp alltraps
80106d02:	e9 a4 f5 ff ff       	jmp    801062ab <alltraps>

80106d07 <vector89>:
.globl vector89
vector89:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $89
80106d09:	6a 59                	push   $0x59
  jmp alltraps
80106d0b:	e9 9b f5 ff ff       	jmp    801062ab <alltraps>

80106d10 <vector90>:
.globl vector90
vector90:
  pushl $0
80106d10:	6a 00                	push   $0x0
  pushl $90
80106d12:	6a 5a                	push   $0x5a
  jmp alltraps
80106d14:	e9 92 f5 ff ff       	jmp    801062ab <alltraps>

80106d19 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $91
80106d1b:	6a 5b                	push   $0x5b
  jmp alltraps
80106d1d:	e9 89 f5 ff ff       	jmp    801062ab <alltraps>

80106d22 <vector92>:
.globl vector92
vector92:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $92
80106d24:	6a 5c                	push   $0x5c
  jmp alltraps
80106d26:	e9 80 f5 ff ff       	jmp    801062ab <alltraps>

80106d2b <vector93>:
.globl vector93
vector93:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $93
80106d2d:	6a 5d                	push   $0x5d
  jmp alltraps
80106d2f:	e9 77 f5 ff ff       	jmp    801062ab <alltraps>

80106d34 <vector94>:
.globl vector94
vector94:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $94
80106d36:	6a 5e                	push   $0x5e
  jmp alltraps
80106d38:	e9 6e f5 ff ff       	jmp    801062ab <alltraps>

80106d3d <vector95>:
.globl vector95
vector95:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $95
80106d3f:	6a 5f                	push   $0x5f
  jmp alltraps
80106d41:	e9 65 f5 ff ff       	jmp    801062ab <alltraps>

80106d46 <vector96>:
.globl vector96
vector96:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $96
80106d48:	6a 60                	push   $0x60
  jmp alltraps
80106d4a:	e9 5c f5 ff ff       	jmp    801062ab <alltraps>

80106d4f <vector97>:
.globl vector97
vector97:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $97
80106d51:	6a 61                	push   $0x61
  jmp alltraps
80106d53:	e9 53 f5 ff ff       	jmp    801062ab <alltraps>

80106d58 <vector98>:
.globl vector98
vector98:
  pushl $0
80106d58:	6a 00                	push   $0x0
  pushl $98
80106d5a:	6a 62                	push   $0x62
  jmp alltraps
80106d5c:	e9 4a f5 ff ff       	jmp    801062ab <alltraps>

80106d61 <vector99>:
.globl vector99
vector99:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $99
80106d63:	6a 63                	push   $0x63
  jmp alltraps
80106d65:	e9 41 f5 ff ff       	jmp    801062ab <alltraps>

80106d6a <vector100>:
.globl vector100
vector100:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $100
80106d6c:	6a 64                	push   $0x64
  jmp alltraps
80106d6e:	e9 38 f5 ff ff       	jmp    801062ab <alltraps>

80106d73 <vector101>:
.globl vector101
vector101:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $101
80106d75:	6a 65                	push   $0x65
  jmp alltraps
80106d77:	e9 2f f5 ff ff       	jmp    801062ab <alltraps>

80106d7c <vector102>:
.globl vector102
vector102:
  pushl $0
80106d7c:	6a 00                	push   $0x0
  pushl $102
80106d7e:	6a 66                	push   $0x66
  jmp alltraps
80106d80:	e9 26 f5 ff ff       	jmp    801062ab <alltraps>

80106d85 <vector103>:
.globl vector103
vector103:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $103
80106d87:	6a 67                	push   $0x67
  jmp alltraps
80106d89:	e9 1d f5 ff ff       	jmp    801062ab <alltraps>

80106d8e <vector104>:
.globl vector104
vector104:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $104
80106d90:	6a 68                	push   $0x68
  jmp alltraps
80106d92:	e9 14 f5 ff ff       	jmp    801062ab <alltraps>

80106d97 <vector105>:
.globl vector105
vector105:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $105
80106d99:	6a 69                	push   $0x69
  jmp alltraps
80106d9b:	e9 0b f5 ff ff       	jmp    801062ab <alltraps>

80106da0 <vector106>:
.globl vector106
vector106:
  pushl $0
80106da0:	6a 00                	push   $0x0
  pushl $106
80106da2:	6a 6a                	push   $0x6a
  jmp alltraps
80106da4:	e9 02 f5 ff ff       	jmp    801062ab <alltraps>

80106da9 <vector107>:
.globl vector107
vector107:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $107
80106dab:	6a 6b                	push   $0x6b
  jmp alltraps
80106dad:	e9 f9 f4 ff ff       	jmp    801062ab <alltraps>

80106db2 <vector108>:
.globl vector108
vector108:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $108
80106db4:	6a 6c                	push   $0x6c
  jmp alltraps
80106db6:	e9 f0 f4 ff ff       	jmp    801062ab <alltraps>

80106dbb <vector109>:
.globl vector109
vector109:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $109
80106dbd:	6a 6d                	push   $0x6d
  jmp alltraps
80106dbf:	e9 e7 f4 ff ff       	jmp    801062ab <alltraps>

80106dc4 <vector110>:
.globl vector110
vector110:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $110
80106dc6:	6a 6e                	push   $0x6e
  jmp alltraps
80106dc8:	e9 de f4 ff ff       	jmp    801062ab <alltraps>

80106dcd <vector111>:
.globl vector111
vector111:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $111
80106dcf:	6a 6f                	push   $0x6f
  jmp alltraps
80106dd1:	e9 d5 f4 ff ff       	jmp    801062ab <alltraps>

80106dd6 <vector112>:
.globl vector112
vector112:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $112
80106dd8:	6a 70                	push   $0x70
  jmp alltraps
80106dda:	e9 cc f4 ff ff       	jmp    801062ab <alltraps>

80106ddf <vector113>:
.globl vector113
vector113:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $113
80106de1:	6a 71                	push   $0x71
  jmp alltraps
80106de3:	e9 c3 f4 ff ff       	jmp    801062ab <alltraps>

80106de8 <vector114>:
.globl vector114
vector114:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $114
80106dea:	6a 72                	push   $0x72
  jmp alltraps
80106dec:	e9 ba f4 ff ff       	jmp    801062ab <alltraps>

80106df1 <vector115>:
.globl vector115
vector115:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $115
80106df3:	6a 73                	push   $0x73
  jmp alltraps
80106df5:	e9 b1 f4 ff ff       	jmp    801062ab <alltraps>

80106dfa <vector116>:
.globl vector116
vector116:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $116
80106dfc:	6a 74                	push   $0x74
  jmp alltraps
80106dfe:	e9 a8 f4 ff ff       	jmp    801062ab <alltraps>

80106e03 <vector117>:
.globl vector117
vector117:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $117
80106e05:	6a 75                	push   $0x75
  jmp alltraps
80106e07:	e9 9f f4 ff ff       	jmp    801062ab <alltraps>

80106e0c <vector118>:
.globl vector118
vector118:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $118
80106e0e:	6a 76                	push   $0x76
  jmp alltraps
80106e10:	e9 96 f4 ff ff       	jmp    801062ab <alltraps>

80106e15 <vector119>:
.globl vector119
vector119:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $119
80106e17:	6a 77                	push   $0x77
  jmp alltraps
80106e19:	e9 8d f4 ff ff       	jmp    801062ab <alltraps>

80106e1e <vector120>:
.globl vector120
vector120:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $120
80106e20:	6a 78                	push   $0x78
  jmp alltraps
80106e22:	e9 84 f4 ff ff       	jmp    801062ab <alltraps>

80106e27 <vector121>:
.globl vector121
vector121:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $121
80106e29:	6a 79                	push   $0x79
  jmp alltraps
80106e2b:	e9 7b f4 ff ff       	jmp    801062ab <alltraps>

80106e30 <vector122>:
.globl vector122
vector122:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $122
80106e32:	6a 7a                	push   $0x7a
  jmp alltraps
80106e34:	e9 72 f4 ff ff       	jmp    801062ab <alltraps>

80106e39 <vector123>:
.globl vector123
vector123:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $123
80106e3b:	6a 7b                	push   $0x7b
  jmp alltraps
80106e3d:	e9 69 f4 ff ff       	jmp    801062ab <alltraps>

80106e42 <vector124>:
.globl vector124
vector124:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $124
80106e44:	6a 7c                	push   $0x7c
  jmp alltraps
80106e46:	e9 60 f4 ff ff       	jmp    801062ab <alltraps>

80106e4b <vector125>:
.globl vector125
vector125:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $125
80106e4d:	6a 7d                	push   $0x7d
  jmp alltraps
80106e4f:	e9 57 f4 ff ff       	jmp    801062ab <alltraps>

80106e54 <vector126>:
.globl vector126
vector126:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $126
80106e56:	6a 7e                	push   $0x7e
  jmp alltraps
80106e58:	e9 4e f4 ff ff       	jmp    801062ab <alltraps>

80106e5d <vector127>:
.globl vector127
vector127:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $127
80106e5f:	6a 7f                	push   $0x7f
  jmp alltraps
80106e61:	e9 45 f4 ff ff       	jmp    801062ab <alltraps>

80106e66 <vector128>:
.globl vector128
vector128:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $128
80106e68:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106e6d:	e9 39 f4 ff ff       	jmp    801062ab <alltraps>

80106e72 <vector129>:
.globl vector129
vector129:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $129
80106e74:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e79:	e9 2d f4 ff ff       	jmp    801062ab <alltraps>

80106e7e <vector130>:
.globl vector130
vector130:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $130
80106e80:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e85:	e9 21 f4 ff ff       	jmp    801062ab <alltraps>

80106e8a <vector131>:
.globl vector131
vector131:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $131
80106e8c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106e91:	e9 15 f4 ff ff       	jmp    801062ab <alltraps>

80106e96 <vector132>:
.globl vector132
vector132:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $132
80106e98:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106e9d:	e9 09 f4 ff ff       	jmp    801062ab <alltraps>

80106ea2 <vector133>:
.globl vector133
vector133:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $133
80106ea4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106ea9:	e9 fd f3 ff ff       	jmp    801062ab <alltraps>

80106eae <vector134>:
.globl vector134
vector134:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $134
80106eb0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106eb5:	e9 f1 f3 ff ff       	jmp    801062ab <alltraps>

80106eba <vector135>:
.globl vector135
vector135:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $135
80106ebc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ec1:	e9 e5 f3 ff ff       	jmp    801062ab <alltraps>

80106ec6 <vector136>:
.globl vector136
vector136:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $136
80106ec8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106ecd:	e9 d9 f3 ff ff       	jmp    801062ab <alltraps>

80106ed2 <vector137>:
.globl vector137
vector137:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $137
80106ed4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106ed9:	e9 cd f3 ff ff       	jmp    801062ab <alltraps>

80106ede <vector138>:
.globl vector138
vector138:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $138
80106ee0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ee5:	e9 c1 f3 ff ff       	jmp    801062ab <alltraps>

80106eea <vector139>:
.globl vector139
vector139:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $139
80106eec:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ef1:	e9 b5 f3 ff ff       	jmp    801062ab <alltraps>

80106ef6 <vector140>:
.globl vector140
vector140:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $140
80106ef8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106efd:	e9 a9 f3 ff ff       	jmp    801062ab <alltraps>

80106f02 <vector141>:
.globl vector141
vector141:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $141
80106f04:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f09:	e9 9d f3 ff ff       	jmp    801062ab <alltraps>

80106f0e <vector142>:
.globl vector142
vector142:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $142
80106f10:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f15:	e9 91 f3 ff ff       	jmp    801062ab <alltraps>

80106f1a <vector143>:
.globl vector143
vector143:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $143
80106f1c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f21:	e9 85 f3 ff ff       	jmp    801062ab <alltraps>

80106f26 <vector144>:
.globl vector144
vector144:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $144
80106f28:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f2d:	e9 79 f3 ff ff       	jmp    801062ab <alltraps>

80106f32 <vector145>:
.globl vector145
vector145:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $145
80106f34:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f39:	e9 6d f3 ff ff       	jmp    801062ab <alltraps>

80106f3e <vector146>:
.globl vector146
vector146:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $146
80106f40:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f45:	e9 61 f3 ff ff       	jmp    801062ab <alltraps>

80106f4a <vector147>:
.globl vector147
vector147:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $147
80106f4c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106f51:	e9 55 f3 ff ff       	jmp    801062ab <alltraps>

80106f56 <vector148>:
.globl vector148
vector148:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $148
80106f58:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106f5d:	e9 49 f3 ff ff       	jmp    801062ab <alltraps>

80106f62 <vector149>:
.globl vector149
vector149:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $149
80106f64:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106f69:	e9 3d f3 ff ff       	jmp    801062ab <alltraps>

80106f6e <vector150>:
.globl vector150
vector150:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $150
80106f70:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106f75:	e9 31 f3 ff ff       	jmp    801062ab <alltraps>

80106f7a <vector151>:
.globl vector151
vector151:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $151
80106f7c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f81:	e9 25 f3 ff ff       	jmp    801062ab <alltraps>

80106f86 <vector152>:
.globl vector152
vector152:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $152
80106f88:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f8d:	e9 19 f3 ff ff       	jmp    801062ab <alltraps>

80106f92 <vector153>:
.globl vector153
vector153:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $153
80106f94:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106f99:	e9 0d f3 ff ff       	jmp    801062ab <alltraps>

80106f9e <vector154>:
.globl vector154
vector154:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $154
80106fa0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106fa5:	e9 01 f3 ff ff       	jmp    801062ab <alltraps>

80106faa <vector155>:
.globl vector155
vector155:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $155
80106fac:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106fb1:	e9 f5 f2 ff ff       	jmp    801062ab <alltraps>

80106fb6 <vector156>:
.globl vector156
vector156:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $156
80106fb8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106fbd:	e9 e9 f2 ff ff       	jmp    801062ab <alltraps>

80106fc2 <vector157>:
.globl vector157
vector157:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $157
80106fc4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106fc9:	e9 dd f2 ff ff       	jmp    801062ab <alltraps>

80106fce <vector158>:
.globl vector158
vector158:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $158
80106fd0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106fd5:	e9 d1 f2 ff ff       	jmp    801062ab <alltraps>

80106fda <vector159>:
.globl vector159
vector159:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $159
80106fdc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106fe1:	e9 c5 f2 ff ff       	jmp    801062ab <alltraps>

80106fe6 <vector160>:
.globl vector160
vector160:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $160
80106fe8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106fed:	e9 b9 f2 ff ff       	jmp    801062ab <alltraps>

80106ff2 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $161
80106ff4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ff9:	e9 ad f2 ff ff       	jmp    801062ab <alltraps>

80106ffe <vector162>:
.globl vector162
vector162:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $162
80107000:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107005:	e9 a1 f2 ff ff       	jmp    801062ab <alltraps>

8010700a <vector163>:
.globl vector163
vector163:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $163
8010700c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107011:	e9 95 f2 ff ff       	jmp    801062ab <alltraps>

80107016 <vector164>:
.globl vector164
vector164:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $164
80107018:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010701d:	e9 89 f2 ff ff       	jmp    801062ab <alltraps>

80107022 <vector165>:
.globl vector165
vector165:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $165
80107024:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107029:	e9 7d f2 ff ff       	jmp    801062ab <alltraps>

8010702e <vector166>:
.globl vector166
vector166:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $166
80107030:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107035:	e9 71 f2 ff ff       	jmp    801062ab <alltraps>

8010703a <vector167>:
.globl vector167
vector167:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $167
8010703c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107041:	e9 65 f2 ff ff       	jmp    801062ab <alltraps>

80107046 <vector168>:
.globl vector168
vector168:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $168
80107048:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010704d:	e9 59 f2 ff ff       	jmp    801062ab <alltraps>

80107052 <vector169>:
.globl vector169
vector169:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $169
80107054:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107059:	e9 4d f2 ff ff       	jmp    801062ab <alltraps>

8010705e <vector170>:
.globl vector170
vector170:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $170
80107060:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107065:	e9 41 f2 ff ff       	jmp    801062ab <alltraps>

8010706a <vector171>:
.globl vector171
vector171:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $171
8010706c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107071:	e9 35 f2 ff ff       	jmp    801062ab <alltraps>

80107076 <vector172>:
.globl vector172
vector172:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $172
80107078:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010707d:	e9 29 f2 ff ff       	jmp    801062ab <alltraps>

80107082 <vector173>:
.globl vector173
vector173:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $173
80107084:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107089:	e9 1d f2 ff ff       	jmp    801062ab <alltraps>

8010708e <vector174>:
.globl vector174
vector174:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $174
80107090:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107095:	e9 11 f2 ff ff       	jmp    801062ab <alltraps>

8010709a <vector175>:
.globl vector175
vector175:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $175
8010709c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801070a1:	e9 05 f2 ff ff       	jmp    801062ab <alltraps>

801070a6 <vector176>:
.globl vector176
vector176:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $176
801070a8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801070ad:	e9 f9 f1 ff ff       	jmp    801062ab <alltraps>

801070b2 <vector177>:
.globl vector177
vector177:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $177
801070b4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801070b9:	e9 ed f1 ff ff       	jmp    801062ab <alltraps>

801070be <vector178>:
.globl vector178
vector178:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $178
801070c0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801070c5:	e9 e1 f1 ff ff       	jmp    801062ab <alltraps>

801070ca <vector179>:
.globl vector179
vector179:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $179
801070cc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801070d1:	e9 d5 f1 ff ff       	jmp    801062ab <alltraps>

801070d6 <vector180>:
.globl vector180
vector180:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $180
801070d8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801070dd:	e9 c9 f1 ff ff       	jmp    801062ab <alltraps>

801070e2 <vector181>:
.globl vector181
vector181:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $181
801070e4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801070e9:	e9 bd f1 ff ff       	jmp    801062ab <alltraps>

801070ee <vector182>:
.globl vector182
vector182:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $182
801070f0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801070f5:	e9 b1 f1 ff ff       	jmp    801062ab <alltraps>

801070fa <vector183>:
.globl vector183
vector183:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $183
801070fc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107101:	e9 a5 f1 ff ff       	jmp    801062ab <alltraps>

80107106 <vector184>:
.globl vector184
vector184:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $184
80107108:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010710d:	e9 99 f1 ff ff       	jmp    801062ab <alltraps>

80107112 <vector185>:
.globl vector185
vector185:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $185
80107114:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107119:	e9 8d f1 ff ff       	jmp    801062ab <alltraps>

8010711e <vector186>:
.globl vector186
vector186:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $186
80107120:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107125:	e9 81 f1 ff ff       	jmp    801062ab <alltraps>

8010712a <vector187>:
.globl vector187
vector187:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $187
8010712c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107131:	e9 75 f1 ff ff       	jmp    801062ab <alltraps>

80107136 <vector188>:
.globl vector188
vector188:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $188
80107138:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010713d:	e9 69 f1 ff ff       	jmp    801062ab <alltraps>

80107142 <vector189>:
.globl vector189
vector189:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $189
80107144:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107149:	e9 5d f1 ff ff       	jmp    801062ab <alltraps>

8010714e <vector190>:
.globl vector190
vector190:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $190
80107150:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107155:	e9 51 f1 ff ff       	jmp    801062ab <alltraps>

8010715a <vector191>:
.globl vector191
vector191:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $191
8010715c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107161:	e9 45 f1 ff ff       	jmp    801062ab <alltraps>

80107166 <vector192>:
.globl vector192
vector192:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $192
80107168:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010716d:	e9 39 f1 ff ff       	jmp    801062ab <alltraps>

80107172 <vector193>:
.globl vector193
vector193:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $193
80107174:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107179:	e9 2d f1 ff ff       	jmp    801062ab <alltraps>

8010717e <vector194>:
.globl vector194
vector194:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $194
80107180:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107185:	e9 21 f1 ff ff       	jmp    801062ab <alltraps>

8010718a <vector195>:
.globl vector195
vector195:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $195
8010718c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107191:	e9 15 f1 ff ff       	jmp    801062ab <alltraps>

80107196 <vector196>:
.globl vector196
vector196:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $196
80107198:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010719d:	e9 09 f1 ff ff       	jmp    801062ab <alltraps>

801071a2 <vector197>:
.globl vector197
vector197:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $197
801071a4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801071a9:	e9 fd f0 ff ff       	jmp    801062ab <alltraps>

801071ae <vector198>:
.globl vector198
vector198:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $198
801071b0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801071b5:	e9 f1 f0 ff ff       	jmp    801062ab <alltraps>

801071ba <vector199>:
.globl vector199
vector199:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $199
801071bc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801071c1:	e9 e5 f0 ff ff       	jmp    801062ab <alltraps>

801071c6 <vector200>:
.globl vector200
vector200:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $200
801071c8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801071cd:	e9 d9 f0 ff ff       	jmp    801062ab <alltraps>

801071d2 <vector201>:
.globl vector201
vector201:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $201
801071d4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801071d9:	e9 cd f0 ff ff       	jmp    801062ab <alltraps>

801071de <vector202>:
.globl vector202
vector202:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $202
801071e0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801071e5:	e9 c1 f0 ff ff       	jmp    801062ab <alltraps>

801071ea <vector203>:
.globl vector203
vector203:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $203
801071ec:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801071f1:	e9 b5 f0 ff ff       	jmp    801062ab <alltraps>

801071f6 <vector204>:
.globl vector204
vector204:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $204
801071f8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801071fd:	e9 a9 f0 ff ff       	jmp    801062ab <alltraps>

80107202 <vector205>:
.globl vector205
vector205:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $205
80107204:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107209:	e9 9d f0 ff ff       	jmp    801062ab <alltraps>

8010720e <vector206>:
.globl vector206
vector206:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $206
80107210:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107215:	e9 91 f0 ff ff       	jmp    801062ab <alltraps>

8010721a <vector207>:
.globl vector207
vector207:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $207
8010721c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107221:	e9 85 f0 ff ff       	jmp    801062ab <alltraps>

80107226 <vector208>:
.globl vector208
vector208:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $208
80107228:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010722d:	e9 79 f0 ff ff       	jmp    801062ab <alltraps>

80107232 <vector209>:
.globl vector209
vector209:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $209
80107234:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107239:	e9 6d f0 ff ff       	jmp    801062ab <alltraps>

8010723e <vector210>:
.globl vector210
vector210:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $210
80107240:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107245:	e9 61 f0 ff ff       	jmp    801062ab <alltraps>

8010724a <vector211>:
.globl vector211
vector211:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $211
8010724c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107251:	e9 55 f0 ff ff       	jmp    801062ab <alltraps>

80107256 <vector212>:
.globl vector212
vector212:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $212
80107258:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010725d:	e9 49 f0 ff ff       	jmp    801062ab <alltraps>

80107262 <vector213>:
.globl vector213
vector213:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $213
80107264:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107269:	e9 3d f0 ff ff       	jmp    801062ab <alltraps>

8010726e <vector214>:
.globl vector214
vector214:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $214
80107270:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107275:	e9 31 f0 ff ff       	jmp    801062ab <alltraps>

8010727a <vector215>:
.globl vector215
vector215:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $215
8010727c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107281:	e9 25 f0 ff ff       	jmp    801062ab <alltraps>

80107286 <vector216>:
.globl vector216
vector216:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $216
80107288:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010728d:	e9 19 f0 ff ff       	jmp    801062ab <alltraps>

80107292 <vector217>:
.globl vector217
vector217:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $217
80107294:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107299:	e9 0d f0 ff ff       	jmp    801062ab <alltraps>

8010729e <vector218>:
.globl vector218
vector218:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $218
801072a0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801072a5:	e9 01 f0 ff ff       	jmp    801062ab <alltraps>

801072aa <vector219>:
.globl vector219
vector219:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $219
801072ac:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801072b1:	e9 f5 ef ff ff       	jmp    801062ab <alltraps>

801072b6 <vector220>:
.globl vector220
vector220:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $220
801072b8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801072bd:	e9 e9 ef ff ff       	jmp    801062ab <alltraps>

801072c2 <vector221>:
.globl vector221
vector221:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $221
801072c4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801072c9:	e9 dd ef ff ff       	jmp    801062ab <alltraps>

801072ce <vector222>:
.globl vector222
vector222:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $222
801072d0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801072d5:	e9 d1 ef ff ff       	jmp    801062ab <alltraps>

801072da <vector223>:
.globl vector223
vector223:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $223
801072dc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801072e1:	e9 c5 ef ff ff       	jmp    801062ab <alltraps>

801072e6 <vector224>:
.globl vector224
vector224:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $224
801072e8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801072ed:	e9 b9 ef ff ff       	jmp    801062ab <alltraps>

801072f2 <vector225>:
.globl vector225
vector225:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $225
801072f4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801072f9:	e9 ad ef ff ff       	jmp    801062ab <alltraps>

801072fe <vector226>:
.globl vector226
vector226:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $226
80107300:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107305:	e9 a1 ef ff ff       	jmp    801062ab <alltraps>

8010730a <vector227>:
.globl vector227
vector227:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $227
8010730c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107311:	e9 95 ef ff ff       	jmp    801062ab <alltraps>

80107316 <vector228>:
.globl vector228
vector228:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $228
80107318:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010731d:	e9 89 ef ff ff       	jmp    801062ab <alltraps>

80107322 <vector229>:
.globl vector229
vector229:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $229
80107324:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107329:	e9 7d ef ff ff       	jmp    801062ab <alltraps>

8010732e <vector230>:
.globl vector230
vector230:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $230
80107330:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107335:	e9 71 ef ff ff       	jmp    801062ab <alltraps>

8010733a <vector231>:
.globl vector231
vector231:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $231
8010733c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107341:	e9 65 ef ff ff       	jmp    801062ab <alltraps>

80107346 <vector232>:
.globl vector232
vector232:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $232
80107348:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010734d:	e9 59 ef ff ff       	jmp    801062ab <alltraps>

80107352 <vector233>:
.globl vector233
vector233:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $233
80107354:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107359:	e9 4d ef ff ff       	jmp    801062ab <alltraps>

8010735e <vector234>:
.globl vector234
vector234:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $234
80107360:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107365:	e9 41 ef ff ff       	jmp    801062ab <alltraps>

8010736a <vector235>:
.globl vector235
vector235:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $235
8010736c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107371:	e9 35 ef ff ff       	jmp    801062ab <alltraps>

80107376 <vector236>:
.globl vector236
vector236:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $236
80107378:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010737d:	e9 29 ef ff ff       	jmp    801062ab <alltraps>

80107382 <vector237>:
.globl vector237
vector237:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $237
80107384:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107389:	e9 1d ef ff ff       	jmp    801062ab <alltraps>

8010738e <vector238>:
.globl vector238
vector238:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $238
80107390:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107395:	e9 11 ef ff ff       	jmp    801062ab <alltraps>

8010739a <vector239>:
.globl vector239
vector239:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $239
8010739c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801073a1:	e9 05 ef ff ff       	jmp    801062ab <alltraps>

801073a6 <vector240>:
.globl vector240
vector240:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $240
801073a8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801073ad:	e9 f9 ee ff ff       	jmp    801062ab <alltraps>

801073b2 <vector241>:
.globl vector241
vector241:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $241
801073b4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801073b9:	e9 ed ee ff ff       	jmp    801062ab <alltraps>

801073be <vector242>:
.globl vector242
vector242:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $242
801073c0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801073c5:	e9 e1 ee ff ff       	jmp    801062ab <alltraps>

801073ca <vector243>:
.globl vector243
vector243:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $243
801073cc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801073d1:	e9 d5 ee ff ff       	jmp    801062ab <alltraps>

801073d6 <vector244>:
.globl vector244
vector244:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $244
801073d8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801073dd:	e9 c9 ee ff ff       	jmp    801062ab <alltraps>

801073e2 <vector245>:
.globl vector245
vector245:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $245
801073e4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801073e9:	e9 bd ee ff ff       	jmp    801062ab <alltraps>

801073ee <vector246>:
.globl vector246
vector246:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $246
801073f0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801073f5:	e9 b1 ee ff ff       	jmp    801062ab <alltraps>

801073fa <vector247>:
.globl vector247
vector247:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $247
801073fc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107401:	e9 a5 ee ff ff       	jmp    801062ab <alltraps>

80107406 <vector248>:
.globl vector248
vector248:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $248
80107408:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010740d:	e9 99 ee ff ff       	jmp    801062ab <alltraps>

80107412 <vector249>:
.globl vector249
vector249:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $249
80107414:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107419:	e9 8d ee ff ff       	jmp    801062ab <alltraps>

8010741e <vector250>:
.globl vector250
vector250:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $250
80107420:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107425:	e9 81 ee ff ff       	jmp    801062ab <alltraps>

8010742a <vector251>:
.globl vector251
vector251:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $251
8010742c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107431:	e9 75 ee ff ff       	jmp    801062ab <alltraps>

80107436 <vector252>:
.globl vector252
vector252:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $252
80107438:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010743d:	e9 69 ee ff ff       	jmp    801062ab <alltraps>

80107442 <vector253>:
.globl vector253
vector253:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $253
80107444:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107449:	e9 5d ee ff ff       	jmp    801062ab <alltraps>

8010744e <vector254>:
.globl vector254
vector254:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $254
80107450:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107455:	e9 51 ee ff ff       	jmp    801062ab <alltraps>

8010745a <vector255>:
.globl vector255
vector255:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $255
8010745c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107461:	e9 45 ee ff ff       	jmp    801062ab <alltraps>

80107466 <lgdt>:
{
80107466:	55                   	push   %ebp
80107467:	89 e5                	mov    %esp,%ebp
80107469:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010746c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010746f:	83 e8 01             	sub    $0x1,%eax
80107472:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107476:	8b 45 08             	mov    0x8(%ebp),%eax
80107479:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010747d:	8b 45 08             	mov    0x8(%ebp),%eax
80107480:	c1 e8 10             	shr    $0x10,%eax
80107483:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107487:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010748a:	0f 01 10             	lgdtl  (%eax)
}
8010748d:	90                   	nop
8010748e:	c9                   	leave
8010748f:	c3                   	ret

80107490 <ltr>:
{
80107490:	55                   	push   %ebp
80107491:	89 e5                	mov    %esp,%ebp
80107493:	83 ec 04             	sub    $0x4,%esp
80107496:	8b 45 08             	mov    0x8(%ebp),%eax
80107499:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010749d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801074a1:	0f 00 d8             	ltr    %eax
}
801074a4:	90                   	nop
801074a5:	c9                   	leave
801074a6:	c3                   	ret

801074a7 <lcr3>:

static inline void
lcr3(uint val)
{
801074a7:	55                   	push   %ebp
801074a8:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074aa:	8b 45 08             	mov    0x8(%ebp),%eax
801074ad:	0f 22 d8             	mov    %eax,%cr3
}
801074b0:	90                   	nop
801074b1:	5d                   	pop    %ebp
801074b2:	c3                   	ret

801074b3 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801074b3:	f3 0f 1e fb          	endbr32
801074b7:	55                   	push   %ebp
801074b8:	89 e5                	mov    %esp,%ebp
801074ba:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801074bd:	e8 aa c6 ff ff       	call   80103b6c <cpuid>
801074c2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801074c8:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801074cd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801074d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dc:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801074e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074f0:	83 e2 f0             	and    $0xfffffff0,%edx
801074f3:	83 ca 0a             	or     $0xa,%edx
801074f6:	88 50 7d             	mov    %dl,0x7d(%eax)
801074f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107500:	83 ca 10             	or     $0x10,%edx
80107503:	88 50 7d             	mov    %dl,0x7d(%eax)
80107506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107509:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010750d:	83 e2 9f             	and    $0xffffff9f,%edx
80107510:	88 50 7d             	mov    %dl,0x7d(%eax)
80107513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107516:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010751a:	83 ca 80             	or     $0xffffff80,%edx
8010751d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107523:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107527:	83 ca 0f             	or     $0xf,%edx
8010752a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010752d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107530:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107534:	83 e2 ef             	and    $0xffffffef,%edx
80107537:	88 50 7e             	mov    %dl,0x7e(%eax)
8010753a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107541:	83 e2 df             	and    $0xffffffdf,%edx
80107544:	88 50 7e             	mov    %dl,0x7e(%eax)
80107547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010754e:	83 ca 40             	or     $0x40,%edx
80107551:	88 50 7e             	mov    %dl,0x7e(%eax)
80107554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107557:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010755b:	83 ca 80             	or     $0xffffff80,%edx
8010755e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107564:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107572:	ff ff 
80107574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107577:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010757e:	00 00 
80107580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107583:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010758a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107594:	83 e2 f0             	and    $0xfffffff0,%edx
80107597:	83 ca 02             	or     $0x2,%edx
8010759a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075aa:	83 ca 10             	or     $0x10,%edx
801075ad:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075bd:	83 e2 9f             	and    $0xffffff9f,%edx
801075c0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075d0:	83 ca 80             	or     $0xffffff80,%edx
801075d3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075e3:	83 ca 0f             	or     $0xf,%edx
801075e6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ef:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075f6:	83 e2 ef             	and    $0xffffffef,%edx
801075f9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107609:	83 e2 df             	and    $0xffffffdf,%edx
8010760c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107615:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010761c:	83 ca 40             	or     $0x40,%edx
8010761f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107628:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010762f:	83 ca 80             	or     $0xffffff80,%edx
80107632:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107645:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010764c:	ff ff 
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107658:	00 00 
8010765a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107667:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010766e:	83 e2 f0             	and    $0xfffffff0,%edx
80107671:	83 ca 0a             	or     $0xa,%edx
80107674:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010767a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107684:	83 ca 10             	or     $0x10,%edx
80107687:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010768d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107690:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107697:	83 ca 60             	or     $0x60,%edx
8010769a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076aa:	83 ca 80             	or     $0xffffff80,%edx
801076ad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076bd:	83 ca 0f             	or     $0xf,%edx
801076c0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076d0:	83 e2 ef             	and    $0xffffffef,%edx
801076d3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076dc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076e3:	83 e2 df             	and    $0xffffffdf,%edx
801076e6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ef:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076f6:	83 ca 40             	or     $0x40,%edx
801076f9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107702:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107709:	83 ca 80             	or     $0xffffff80,%edx
8010770c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107715:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107726:	ff ff 
80107728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107732:	00 00 
80107734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107737:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010773e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107741:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107748:	83 e2 f0             	and    $0xfffffff0,%edx
8010774b:	83 ca 02             	or     $0x2,%edx
8010774e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107757:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010775e:	83 ca 10             	or     $0x10,%edx
80107761:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107771:	83 ca 60             	or     $0x60,%edx
80107774:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010777a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107784:	83 ca 80             	or     $0xffffff80,%edx
80107787:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010778d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107790:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107797:	83 ca 0f             	or     $0xf,%edx
8010779a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077aa:	83 e2 ef             	and    $0xffffffef,%edx
801077ad:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077bd:	83 e2 df             	and    $0xffffffdf,%edx
801077c0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077d0:	83 ca 40             	or     $0x40,%edx
801077d3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077e3:	83 ca 80             	or     $0xffffff80,%edx
801077e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	83 c0 70             	add    $0x70,%eax
801077fc:	83 ec 08             	sub    $0x8,%esp
801077ff:	6a 30                	push   $0x30
80107801:	50                   	push   %eax
80107802:	e8 5f fc ff ff       	call   80107466 <lgdt>
80107807:	83 c4 10             	add    $0x10,%esp
}
8010780a:	90                   	nop
8010780b:	c9                   	leave
8010780c:	c3                   	ret

8010780d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010780d:	f3 0f 1e fb          	endbr32
80107811:	55                   	push   %ebp
80107812:	89 e5                	mov    %esp,%ebp
80107814:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010781a:	c1 e8 16             	shr    $0x16,%eax
8010781d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107824:	8b 45 08             	mov    0x8(%ebp),%eax
80107827:	01 d0                	add    %edx,%eax
80107829:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010782c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010782f:	8b 00                	mov    (%eax),%eax
80107831:	83 e0 01             	and    $0x1,%eax
80107834:	85 c0                	test   %eax,%eax
80107836:	74 14                	je     8010784c <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010783b:	8b 00                	mov    (%eax),%eax
8010783d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107842:	05 00 00 00 80       	add    $0x80000000,%eax
80107847:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010784a:	eb 42                	jmp    8010788e <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010784c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107850:	74 0e                	je     80107860 <walkpgdir+0x53>
80107852:	e8 99 b0 ff ff       	call   801028f0 <kalloc>
80107857:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010785a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010785e:	75 07                	jne    80107867 <walkpgdir+0x5a>
      return 0;
80107860:	b8 00 00 00 00       	mov    $0x0,%eax
80107865:	eb 3e                	jmp    801078a5 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107867:	83 ec 04             	sub    $0x4,%esp
8010786a:	68 00 10 00 00       	push   $0x1000
8010786f:	6a 00                	push   $0x0
80107871:	ff 75 f4             	push   -0xc(%ebp)
80107874:	e8 b1 d4 ff ff       	call   80104d2a <memset>
80107879:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	05 00 00 00 80       	add    $0x80000000,%eax
80107884:	83 c8 07             	or     $0x7,%eax
80107887:	89 c2                	mov    %eax,%edx
80107889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010788c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010788e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107891:	c1 e8 0c             	shr    $0xc,%eax
80107894:	25 ff 03 00 00       	and    $0x3ff,%eax
80107899:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	01 d0                	add    %edx,%eax
}
801078a5:	c9                   	leave
801078a6:	c3                   	ret

801078a7 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078a7:	f3 0f 1e fb          	endbr32
801078ab:	55                   	push   %ebp
801078ac:	89 e5                	mov    %esp,%ebp
801078ae:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801078b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801078b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801078bf:	8b 45 10             	mov    0x10(%ebp),%eax
801078c2:	01 d0                	add    %edx,%eax
801078c4:	83 e8 01             	sub    $0x1,%eax
801078c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078cf:	83 ec 04             	sub    $0x4,%esp
801078d2:	6a 01                	push   $0x1
801078d4:	ff 75 f4             	push   -0xc(%ebp)
801078d7:	ff 75 08             	push   0x8(%ebp)
801078da:	e8 2e ff ff ff       	call   8010780d <walkpgdir>
801078df:	83 c4 10             	add    $0x10,%esp
801078e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078e9:	75 07                	jne    801078f2 <mappages+0x4b>
      return -1;
801078eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078f0:	eb 47                	jmp    80107939 <mappages+0x92>
    if(*pte & PTE_P)
801078f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078f5:	8b 00                	mov    (%eax),%eax
801078f7:	83 e0 01             	and    $0x1,%eax
801078fa:	85 c0                	test   %eax,%eax
801078fc:	74 0d                	je     8010790b <mappages+0x64>
      panic("remap");
801078fe:	83 ec 0c             	sub    $0xc,%esp
80107901:	68 74 ae 10 80       	push   $0x8010ae74
80107906:	e8 d3 8c ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
8010790b:	8b 45 18             	mov    0x18(%ebp),%eax
8010790e:	0b 45 14             	or     0x14(%ebp),%eax
80107911:	83 c8 01             	or     $0x1,%eax
80107914:	89 c2                	mov    %eax,%edx
80107916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107919:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010791b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107921:	74 10                	je     80107933 <mappages+0x8c>
      break;
    a += PGSIZE;
80107923:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010792a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107931:	eb 9c                	jmp    801078cf <mappages+0x28>
      break;
80107933:	90                   	nop
  }
  return 0;
80107934:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107939:	c9                   	leave
8010793a:	c3                   	ret

8010793b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010793b:	f3 0f 1e fb          	endbr32
8010793f:	55                   	push   %ebp
80107940:	89 e5                	mov    %esp,%ebp
80107942:	53                   	push   %ebx
80107943:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107946:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010794d:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107952:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107957:	29 c2                	sub    %eax,%edx
80107959:	89 d0                	mov    %edx,%eax
8010795b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010795e:	a1 84 80 19 80       	mov    0x80198084,%eax
80107963:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107966:	8b 15 84 80 19 80    	mov    0x80198084,%edx
8010796c:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107971:	01 d0                	add    %edx,%eax
80107973:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107976:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010797d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107980:	83 c0 30             	add    $0x30,%eax
80107983:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107986:	89 10                	mov    %edx,(%eax)
80107988:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010798b:	89 50 04             	mov    %edx,0x4(%eax)
8010798e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107991:	89 50 08             	mov    %edx,0x8(%eax)
80107994:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107997:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010799a:	e8 51 af ff ff       	call   801028f0 <kalloc>
8010799f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079a6:	75 07                	jne    801079af <setupkvm+0x74>
    return 0;
801079a8:	b8 00 00 00 00       	mov    $0x0,%eax
801079ad:	eb 78                	jmp    80107a27 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801079af:	83 ec 04             	sub    $0x4,%esp
801079b2:	68 00 10 00 00       	push   $0x1000
801079b7:	6a 00                	push   $0x0
801079b9:	ff 75 f0             	push   -0x10(%ebp)
801079bc:	e8 69 d3 ff ff       	call   80104d2a <memset>
801079c1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079c4:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801079cb:	eb 4e                	jmp    80107a1b <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d6:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dc:	8b 58 08             	mov    0x8(%eax),%ebx
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	8b 40 04             	mov    0x4(%eax),%eax
801079e5:	29 c3                	sub    %eax,%ebx
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	8b 00                	mov    (%eax),%eax
801079ec:	83 ec 0c             	sub    $0xc,%esp
801079ef:	51                   	push   %ecx
801079f0:	52                   	push   %edx
801079f1:	53                   	push   %ebx
801079f2:	50                   	push   %eax
801079f3:	ff 75 f0             	push   -0x10(%ebp)
801079f6:	e8 ac fe ff ff       	call   801078a7 <mappages>
801079fb:	83 c4 20             	add    $0x20,%esp
801079fe:	85 c0                	test   %eax,%eax
80107a00:	79 15                	jns    80107a17 <setupkvm+0xdc>
      freevm(pgdir);
80107a02:	83 ec 0c             	sub    $0xc,%esp
80107a05:	ff 75 f0             	push   -0x10(%ebp)
80107a08:	e8 11 05 00 00       	call   80107f1e <freevm>
80107a0d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a10:	b8 00 00 00 00       	mov    $0x0,%eax
80107a15:	eb 10                	jmp    80107a27 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a17:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a1b:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107a22:	72 a9                	jb     801079cd <setupkvm+0x92>
    }
  return pgdir;
80107a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a2a:	c9                   	leave
80107a2b:	c3                   	ret

80107a2c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a2c:	f3 0f 1e fb          	endbr32
80107a30:	55                   	push   %ebp
80107a31:	89 e5                	mov    %esp,%ebp
80107a33:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a36:	e8 00 ff ff ff       	call   8010793b <setupkvm>
80107a3b:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
80107a40:	e8 03 00 00 00       	call   80107a48 <switchkvm>
}
80107a45:	90                   	nop
80107a46:	c9                   	leave
80107a47:	c3                   	ret

80107a48 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a48:	f3 0f 1e fb          	endbr32
80107a4c:	55                   	push   %ebp
80107a4d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a4f:	a1 84 7d 19 80       	mov    0x80197d84,%eax
80107a54:	05 00 00 00 80       	add    $0x80000000,%eax
80107a59:	50                   	push   %eax
80107a5a:	e8 48 fa ff ff       	call   801074a7 <lcr3>
80107a5f:	83 c4 04             	add    $0x4,%esp
}
80107a62:	90                   	nop
80107a63:	c9                   	leave
80107a64:	c3                   	ret

80107a65 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a65:	f3 0f 1e fb          	endbr32
80107a69:	55                   	push   %ebp
80107a6a:	89 e5                	mov    %esp,%ebp
80107a6c:	56                   	push   %esi
80107a6d:	53                   	push   %ebx
80107a6e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107a71:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a75:	75 0d                	jne    80107a84 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107a77:	83 ec 0c             	sub    $0xc,%esp
80107a7a:	68 7a ae 10 80       	push   $0x8010ae7a
80107a7f:	e8 5a 8b ff ff       	call   801005de <panic>
  if(p->kstack == 0)
80107a84:	8b 45 08             	mov    0x8(%ebp),%eax
80107a87:	8b 40 08             	mov    0x8(%eax),%eax
80107a8a:	85 c0                	test   %eax,%eax
80107a8c:	75 0d                	jne    80107a9b <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107a8e:	83 ec 0c             	sub    $0xc,%esp
80107a91:	68 90 ae 10 80       	push   $0x8010ae90
80107a96:	e8 43 8b ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
80107a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9e:	8b 40 04             	mov    0x4(%eax),%eax
80107aa1:	85 c0                	test   %eax,%eax
80107aa3:	75 0d                	jne    80107ab2 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107aa5:	83 ec 0c             	sub    $0xc,%esp
80107aa8:	68 a5 ae 10 80       	push   $0x8010aea5
80107aad:	e8 2c 8b ff ff       	call   801005de <panic>

  pushcli();
80107ab2:	e8 60 d1 ff ff       	call   80104c17 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ab7:	e8 cf c0 ff ff       	call   80103b8b <mycpu>
80107abc:	89 c3                	mov    %eax,%ebx
80107abe:	e8 c8 c0 ff ff       	call   80103b8b <mycpu>
80107ac3:	83 c0 08             	add    $0x8,%eax
80107ac6:	89 c6                	mov    %eax,%esi
80107ac8:	e8 be c0 ff ff       	call   80103b8b <mycpu>
80107acd:	83 c0 08             	add    $0x8,%eax
80107ad0:	c1 e8 10             	shr    $0x10,%eax
80107ad3:	88 45 f7             	mov    %al,-0x9(%ebp)
80107ad6:	e8 b0 c0 ff ff       	call   80103b8b <mycpu>
80107adb:	83 c0 08             	add    $0x8,%eax
80107ade:	c1 e8 18             	shr    $0x18,%eax
80107ae1:	89 c2                	mov    %eax,%edx
80107ae3:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107aea:	67 00 
80107aec:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107af3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107af7:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107afd:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b04:	83 e0 f0             	and    $0xfffffff0,%eax
80107b07:	83 c8 09             	or     $0x9,%eax
80107b0a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b10:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b17:	83 c8 10             	or     $0x10,%eax
80107b1a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b20:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b27:	83 e0 9f             	and    $0xffffff9f,%eax
80107b2a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b30:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b37:	83 c8 80             	or     $0xffffff80,%eax
80107b3a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b40:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b47:	83 e0 f0             	and    $0xfffffff0,%eax
80107b4a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b50:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b57:	83 e0 ef             	and    $0xffffffef,%eax
80107b5a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b60:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b67:	83 e0 df             	and    $0xffffffdf,%eax
80107b6a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b70:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b77:	83 c8 40             	or     $0x40,%eax
80107b7a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b80:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b87:	83 e0 7f             	and    $0x7f,%eax
80107b8a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b90:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107b96:	e8 f0 bf ff ff       	call   80103b8b <mycpu>
80107b9b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ba2:	83 e2 ef             	and    $0xffffffef,%edx
80107ba5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107bab:	e8 db bf ff ff       	call   80103b8b <mycpu>
80107bb0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb9:	8b 40 08             	mov    0x8(%eax),%eax
80107bbc:	89 c3                	mov    %eax,%ebx
80107bbe:	e8 c8 bf ff ff       	call   80103b8b <mycpu>
80107bc3:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107bc9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107bcc:	e8 ba bf ff ff       	call   80103b8b <mycpu>
80107bd1:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107bd7:	83 ec 0c             	sub    $0xc,%esp
80107bda:	6a 28                	push   $0x28
80107bdc:	e8 af f8 ff ff       	call   80107490 <ltr>
80107be1:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107be4:	8b 45 08             	mov    0x8(%ebp),%eax
80107be7:	8b 40 04             	mov    0x4(%eax),%eax
80107bea:	05 00 00 00 80       	add    $0x80000000,%eax
80107bef:	83 ec 0c             	sub    $0xc,%esp
80107bf2:	50                   	push   %eax
80107bf3:	e8 af f8 ff ff       	call   801074a7 <lcr3>
80107bf8:	83 c4 10             	add    $0x10,%esp
  popcli();
80107bfb:	e8 68 d0 ff ff       	call   80104c68 <popcli>
}
80107c00:	90                   	nop
80107c01:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c04:	5b                   	pop    %ebx
80107c05:	5e                   	pop    %esi
80107c06:	5d                   	pop    %ebp
80107c07:	c3                   	ret

80107c08 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c08:	f3 0f 1e fb          	endbr32
80107c0c:	55                   	push   %ebp
80107c0d:	89 e5                	mov    %esp,%ebp
80107c0f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c12:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c19:	76 0d                	jbe    80107c28 <inituvm+0x20>
    panic("inituvm: more than a page");
80107c1b:	83 ec 0c             	sub    $0xc,%esp
80107c1e:	68 b9 ae 10 80       	push   $0x8010aeb9
80107c23:	e8 b6 89 ff ff       	call   801005de <panic>
  mem = kalloc();
80107c28:	e8 c3 ac ff ff       	call   801028f0 <kalloc>
80107c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c30:	83 ec 04             	sub    $0x4,%esp
80107c33:	68 00 10 00 00       	push   $0x1000
80107c38:	6a 00                	push   $0x0
80107c3a:	ff 75 f4             	push   -0xc(%ebp)
80107c3d:	e8 e8 d0 ff ff       	call   80104d2a <memset>
80107c42:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	05 00 00 00 80       	add    $0x80000000,%eax
80107c4d:	83 ec 0c             	sub    $0xc,%esp
80107c50:	6a 06                	push   $0x6
80107c52:	50                   	push   %eax
80107c53:	68 00 10 00 00       	push   $0x1000
80107c58:	6a 00                	push   $0x0
80107c5a:	ff 75 08             	push   0x8(%ebp)
80107c5d:	e8 45 fc ff ff       	call   801078a7 <mappages>
80107c62:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c65:	83 ec 04             	sub    $0x4,%esp
80107c68:	ff 75 10             	push   0x10(%ebp)
80107c6b:	ff 75 0c             	push   0xc(%ebp)
80107c6e:	ff 75 f4             	push   -0xc(%ebp)
80107c71:	e8 7b d1 ff ff       	call   80104df1 <memmove>
80107c76:	83 c4 10             	add    $0x10,%esp
}
80107c79:	90                   	nop
80107c7a:	c9                   	leave
80107c7b:	c3                   	ret

80107c7c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c7c:	f3 0f 1e fb          	endbr32
80107c80:	55                   	push   %ebp
80107c81:	89 e5                	mov    %esp,%ebp
80107c83:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c86:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c89:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c8e:	85 c0                	test   %eax,%eax
80107c90:	74 0d                	je     80107c9f <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107c92:	83 ec 0c             	sub    $0xc,%esp
80107c95:	68 d4 ae 10 80       	push   $0x8010aed4
80107c9a:	e8 3f 89 ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ca6:	e9 8f 00 00 00       	jmp    80107d3a <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cab:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb1:	01 d0                	add    %edx,%eax
80107cb3:	83 ec 04             	sub    $0x4,%esp
80107cb6:	6a 00                	push   $0x0
80107cb8:	50                   	push   %eax
80107cb9:	ff 75 08             	push   0x8(%ebp)
80107cbc:	e8 4c fb ff ff       	call   8010780d <walkpgdir>
80107cc1:	83 c4 10             	add    $0x10,%esp
80107cc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cc7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ccb:	75 0d                	jne    80107cda <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107ccd:	83 ec 0c             	sub    $0xc,%esp
80107cd0:	68 f7 ae 10 80       	push   $0x8010aef7
80107cd5:	e8 04 89 ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107cda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cdd:	8b 00                	mov    (%eax),%eax
80107cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ce7:	8b 45 18             	mov    0x18(%ebp),%eax
80107cea:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ced:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107cf2:	77 0b                	ja     80107cff <loaduvm+0x83>
      n = sz - i;
80107cf4:	8b 45 18             	mov    0x18(%ebp),%eax
80107cf7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cfd:	eb 07                	jmp    80107d06 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107cff:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d06:	8b 55 14             	mov    0x14(%ebp),%edx
80107d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0c:	01 d0                	add    %edx,%eax
80107d0e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d11:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107d17:	ff 75 f0             	push   -0x10(%ebp)
80107d1a:	50                   	push   %eax
80107d1b:	52                   	push   %edx
80107d1c:	ff 75 10             	push   0x10(%ebp)
80107d1f:	e8 be a2 ff ff       	call   80101fe2 <readi>
80107d24:	83 c4 10             	add    $0x10,%esp
80107d27:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107d2a:	74 07                	je     80107d33 <loaduvm+0xb7>
      return -1;
80107d2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d31:	eb 18                	jmp    80107d4b <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107d33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d40:	0f 82 65 ff ff ff    	jb     80107cab <loaduvm+0x2f>
  }
  return 0;
80107d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d4b:	c9                   	leave
80107d4c:	c3                   	ret

80107d4d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d4d:	f3 0f 1e fb          	endbr32
80107d51:	55                   	push   %ebp
80107d52:	89 e5                	mov    %esp,%ebp
80107d54:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d57:	8b 45 10             	mov    0x10(%ebp),%eax
80107d5a:	85 c0                	test   %eax,%eax
80107d5c:	79 0a                	jns    80107d68 <allocuvm+0x1b>
    return 0;
80107d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d63:	e9 ec 00 00 00       	jmp    80107e54 <allocuvm+0x107>
  if(newsz < oldsz)
80107d68:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d6e:	73 08                	jae    80107d78 <allocuvm+0x2b>
    return oldsz;
80107d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d73:	e9 dc 00 00 00       	jmp    80107e54 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d7b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d88:	e9 b8 00 00 00       	jmp    80107e45 <allocuvm+0xf8>
    mem = kalloc();
80107d8d:	e8 5e ab ff ff       	call   801028f0 <kalloc>
80107d92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d99:	75 2e                	jne    80107dc9 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107d9b:	83 ec 0c             	sub    $0xc,%esp
80107d9e:	68 15 af 10 80       	push   $0x8010af15
80107da3:	e8 64 86 ff ff       	call   8010040c <cprintf>
80107da8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dab:	83 ec 04             	sub    $0x4,%esp
80107dae:	ff 75 0c             	push   0xc(%ebp)
80107db1:	ff 75 10             	push   0x10(%ebp)
80107db4:	ff 75 08             	push   0x8(%ebp)
80107db7:	e8 9a 00 00 00       	call   80107e56 <deallocuvm>
80107dbc:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dbf:	b8 00 00 00 00       	mov    $0x0,%eax
80107dc4:	e9 8b 00 00 00       	jmp    80107e54 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107dc9:	83 ec 04             	sub    $0x4,%esp
80107dcc:	68 00 10 00 00       	push   $0x1000
80107dd1:	6a 00                	push   $0x0
80107dd3:	ff 75 f0             	push   -0x10(%ebp)
80107dd6:	e8 4f cf ff ff       	call   80104d2a <memset>
80107ddb:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dea:	83 ec 0c             	sub    $0xc,%esp
80107ded:	6a 06                	push   $0x6
80107def:	52                   	push   %edx
80107df0:	68 00 10 00 00       	push   $0x1000
80107df5:	50                   	push   %eax
80107df6:	ff 75 08             	push   0x8(%ebp)
80107df9:	e8 a9 fa ff ff       	call   801078a7 <mappages>
80107dfe:	83 c4 20             	add    $0x20,%esp
80107e01:	85 c0                	test   %eax,%eax
80107e03:	79 39                	jns    80107e3e <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107e05:	83 ec 0c             	sub    $0xc,%esp
80107e08:	68 2d af 10 80       	push   $0x8010af2d
80107e0d:	e8 fa 85 ff ff       	call   8010040c <cprintf>
80107e12:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e15:	83 ec 04             	sub    $0x4,%esp
80107e18:	ff 75 0c             	push   0xc(%ebp)
80107e1b:	ff 75 10             	push   0x10(%ebp)
80107e1e:	ff 75 08             	push   0x8(%ebp)
80107e21:	e8 30 00 00 00       	call   80107e56 <deallocuvm>
80107e26:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107e29:	83 ec 0c             	sub    $0xc,%esp
80107e2c:	ff 75 f0             	push   -0x10(%ebp)
80107e2f:	e8 1e aa ff ff       	call   80102852 <kfree>
80107e34:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e37:	b8 00 00 00 00       	mov    $0x0,%eax
80107e3c:	eb 16                	jmp    80107e54 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107e3e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e48:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e4b:	0f 82 3c ff ff ff    	jb     80107d8d <allocuvm+0x40>
    }
  }
  return newsz;
80107e51:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e54:	c9                   	leave
80107e55:	c3                   	ret

80107e56 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e56:	f3 0f 1e fb          	endbr32
80107e5a:	55                   	push   %ebp
80107e5b:	89 e5                	mov    %esp,%ebp
80107e5d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e60:	8b 45 10             	mov    0x10(%ebp),%eax
80107e63:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e66:	72 08                	jb     80107e70 <deallocuvm+0x1a>
    return oldsz;
80107e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6b:	e9 ac 00 00 00       	jmp    80107f1c <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107e70:	8b 45 10             	mov    0x10(%ebp),%eax
80107e73:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e80:	e9 88 00 00 00       	jmp    80107f0d <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	83 ec 04             	sub    $0x4,%esp
80107e8b:	6a 00                	push   $0x0
80107e8d:	50                   	push   %eax
80107e8e:	ff 75 08             	push   0x8(%ebp)
80107e91:	e8 77 f9 ff ff       	call   8010780d <walkpgdir>
80107e96:	83 c4 10             	add    $0x10,%esp
80107e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ea0:	75 16                	jne    80107eb8 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	c1 e8 16             	shr    $0x16,%eax
80107ea8:	83 c0 01             	add    $0x1,%eax
80107eab:	c1 e0 16             	shl    $0x16,%eax
80107eae:	2d 00 10 00 00       	sub    $0x1000,%eax
80107eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107eb6:	eb 4e                	jmp    80107f06 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebb:	8b 00                	mov    (%eax),%eax
80107ebd:	83 e0 01             	and    $0x1,%eax
80107ec0:	85 c0                	test   %eax,%eax
80107ec2:	74 42                	je     80107f06 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec7:	8b 00                	mov    (%eax),%eax
80107ec9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ece:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ed1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ed5:	75 0d                	jne    80107ee4 <deallocuvm+0x8e>
        panic("kfree");
80107ed7:	83 ec 0c             	sub    $0xc,%esp
80107eda:	68 49 af 10 80       	push   $0x8010af49
80107edf:	e8 fa 86 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee7:	05 00 00 00 80       	add    $0x80000000,%eax
80107eec:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107eef:	83 ec 0c             	sub    $0xc,%esp
80107ef2:	ff 75 e8             	push   -0x18(%ebp)
80107ef5:	e8 58 a9 ff ff       	call   80102852 <kfree>
80107efa:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f06:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f13:	0f 82 6c ff ff ff    	jb     80107e85 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107f19:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f1c:	c9                   	leave
80107f1d:	c3                   	ret

80107f1e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f1e:	f3 0f 1e fb          	endbr32
80107f22:	55                   	push   %ebp
80107f23:	89 e5                	mov    %esp,%ebp
80107f25:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107f28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f2c:	75 0d                	jne    80107f3b <freevm+0x1d>
    panic("freevm: no pgdir");
80107f2e:	83 ec 0c             	sub    $0xc,%esp
80107f31:	68 4f af 10 80       	push   $0x8010af4f
80107f36:	e8 a3 86 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f3b:	83 ec 04             	sub    $0x4,%esp
80107f3e:	6a 00                	push   $0x0
80107f40:	68 00 00 00 80       	push   $0x80000000
80107f45:	ff 75 08             	push   0x8(%ebp)
80107f48:	e8 09 ff ff ff       	call   80107e56 <deallocuvm>
80107f4d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f57:	eb 48                	jmp    80107fa1 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f63:	8b 45 08             	mov    0x8(%ebp),%eax
80107f66:	01 d0                	add    %edx,%eax
80107f68:	8b 00                	mov    (%eax),%eax
80107f6a:	83 e0 01             	and    $0x1,%eax
80107f6d:	85 c0                	test   %eax,%eax
80107f6f:	74 2c                	je     80107f9d <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f7e:	01 d0                	add    %edx,%eax
80107f80:	8b 00                	mov    (%eax),%eax
80107f82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f87:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f8f:	83 ec 0c             	sub    $0xc,%esp
80107f92:	ff 75 f0             	push   -0x10(%ebp)
80107f95:	e8 b8 a8 ff ff       	call   80102852 <kfree>
80107f9a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fa1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107fa8:	76 af                	jbe    80107f59 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107faa:	83 ec 0c             	sub    $0xc,%esp
80107fad:	ff 75 08             	push   0x8(%ebp)
80107fb0:	e8 9d a8 ff ff       	call   80102852 <kfree>
80107fb5:	83 c4 10             	add    $0x10,%esp
}
80107fb8:	90                   	nop
80107fb9:	c9                   	leave
80107fba:	c3                   	ret

80107fbb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fbb:	f3 0f 1e fb          	endbr32
80107fbf:	55                   	push   %ebp
80107fc0:	89 e5                	mov    %esp,%ebp
80107fc2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fc5:	83 ec 04             	sub    $0x4,%esp
80107fc8:	6a 00                	push   $0x0
80107fca:	ff 75 0c             	push   0xc(%ebp)
80107fcd:	ff 75 08             	push   0x8(%ebp)
80107fd0:	e8 38 f8 ff ff       	call   8010780d <walkpgdir>
80107fd5:	83 c4 10             	add    $0x10,%esp
80107fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107fdb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fdf:	75 0d                	jne    80107fee <clearpteu+0x33>
    panic("clearpteu");
80107fe1:	83 ec 0c             	sub    $0xc,%esp
80107fe4:	68 60 af 10 80       	push   $0x8010af60
80107fe9:	e8 f0 85 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff1:	8b 00                	mov    (%eax),%eax
80107ff3:	83 e0 fb             	and    $0xfffffffb,%eax
80107ff6:	89 c2                	mov    %eax,%edx
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	89 10                	mov    %edx,(%eax)
}
80107ffd:	90                   	nop
80107ffe:	c9                   	leave
80107fff:	c3                   	ret

80108000 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108000:	f3 0f 1e fb          	endbr32
80108004:	55                   	push   %ebp
80108005:	89 e5                	mov    %esp,%ebp
80108007:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
8010800a:	e8 2c f9 ff ff       	call   8010793b <setupkvm>
8010800f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108012:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108016:	75 0a                	jne    80108022 <copyuvm+0x22>
    return 0;
80108018:	b8 00 00 00 00       	mov    $0x0,%eax
8010801d:	e9 d6 00 00 00       	jmp    801080f8 <copyuvm+0xf8>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80108022:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108029:	e9 a3 00 00 00       	jmp    801080d1 <copyuvm+0xd1>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010802e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108031:	83 ec 04             	sub    $0x4,%esp
80108034:	6a 00                	push   $0x0
80108036:	50                   	push   %eax
80108037:	ff 75 08             	push   0x8(%ebp)
8010803a:	e8 ce f7 ff ff       	call   8010780d <walkpgdir>
8010803f:	83 c4 10             	add    $0x10,%esp
80108042:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108045:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108049:	74 7b                	je     801080c6 <copyuvm+0xc6>
      continue;
    if(!(*pte & PTE_P)){
8010804b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804e:	8b 00                	mov    (%eax),%eax
80108050:	83 e0 01             	and    $0x1,%eax
80108053:	85 c0                	test   %eax,%eax
80108055:	74 72                	je     801080c9 <copyuvm+0xc9>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80108057:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805a:	8b 00                	mov    (%eax),%eax
8010805c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108061:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108064:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108067:	8b 00                	mov    (%eax),%eax
80108069:	25 ff 0f 00 00       	and    $0xfff,%eax
8010806e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80108071:	e8 7a a8 ff ff       	call   801028f0 <kalloc>
80108076:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108079:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010807d:	74 62                	je     801080e1 <copyuvm+0xe1>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010807f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108082:	05 00 00 00 80       	add    $0x80000000,%eax
80108087:	83 ec 04             	sub    $0x4,%esp
8010808a:	68 00 10 00 00       	push   $0x1000
8010808f:	50                   	push   %eax
80108090:	ff 75 e0             	push   -0x20(%ebp)
80108093:	e8 59 cd ff ff       	call   80104df1 <memmove>
80108098:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010809b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010809e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080a1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080aa:	83 ec 0c             	sub    $0xc,%esp
801080ad:	52                   	push   %edx
801080ae:	51                   	push   %ecx
801080af:	68 00 10 00 00       	push   $0x1000
801080b4:	50                   	push   %eax
801080b5:	ff 75 f0             	push   -0x10(%ebp)
801080b8:	e8 ea f7 ff ff       	call   801078a7 <mappages>
801080bd:	83 c4 20             	add    $0x20,%esp
801080c0:	85 c0                	test   %eax,%eax
801080c2:	78 20                	js     801080e4 <copyuvm+0xe4>
801080c4:	eb 04                	jmp    801080ca <copyuvm+0xca>
      continue;
801080c6:	90                   	nop
801080c7:	eb 01                	jmp    801080ca <copyuvm+0xca>
      continue;
801080c9:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
801080ca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d4:	85 c0                	test   %eax,%eax
801080d6:	0f 89 52 ff ff ff    	jns    8010802e <copyuvm+0x2e>
      goto bad;
  }  
  return d;
801080dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080df:	eb 17                	jmp    801080f8 <copyuvm+0xf8>
      goto bad;
801080e1:	90                   	nop
801080e2:	eb 01                	jmp    801080e5 <copyuvm+0xe5>
      goto bad;
801080e4:	90                   	nop

bad:
  freevm(d);
801080e5:	83 ec 0c             	sub    $0xc,%esp
801080e8:	ff 75 f0             	push   -0x10(%ebp)
801080eb:	e8 2e fe ff ff       	call   80107f1e <freevm>
801080f0:	83 c4 10             	add    $0x10,%esp
  return 0;
801080f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080f8:	c9                   	leave
801080f9:	c3                   	ret

801080fa <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801080fa:	f3 0f 1e fb          	endbr32
801080fe:	55                   	push   %ebp
801080ff:	89 e5                	mov    %esp,%ebp
80108101:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108104:	83 ec 04             	sub    $0x4,%esp
80108107:	6a 00                	push   $0x0
80108109:	ff 75 0c             	push   0xc(%ebp)
8010810c:	ff 75 08             	push   0x8(%ebp)
8010810f:	e8 f9 f6 ff ff       	call   8010780d <walkpgdir>
80108114:	83 c4 10             	add    $0x10,%esp
80108117:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010811a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811d:	8b 00                	mov    (%eax),%eax
8010811f:	83 e0 01             	and    $0x1,%eax
80108122:	85 c0                	test   %eax,%eax
80108124:	75 07                	jne    8010812d <uva2ka+0x33>
    return 0;
80108126:	b8 00 00 00 00       	mov    $0x0,%eax
8010812b:	eb 22                	jmp    8010814f <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	8b 00                	mov    (%eax),%eax
80108132:	83 e0 04             	and    $0x4,%eax
80108135:	85 c0                	test   %eax,%eax
80108137:	75 07                	jne    80108140 <uva2ka+0x46>
    return 0;
80108139:	b8 00 00 00 00       	mov    $0x0,%eax
8010813e:	eb 0f                	jmp    8010814f <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108143:	8b 00                	mov    (%eax),%eax
80108145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010814a:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010814f:	c9                   	leave
80108150:	c3                   	ret

80108151 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108151:	f3 0f 1e fb          	endbr32
80108155:	55                   	push   %ebp
80108156:	89 e5                	mov    %esp,%ebp
80108158:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010815b:	8b 45 10             	mov    0x10(%ebp),%eax
8010815e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108161:	eb 7f                	jmp    801081e2 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108163:	8b 45 0c             	mov    0xc(%ebp),%eax
80108166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010816b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010816e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108171:	83 ec 08             	sub    $0x8,%esp
80108174:	50                   	push   %eax
80108175:	ff 75 08             	push   0x8(%ebp)
80108178:	e8 7d ff ff ff       	call   801080fa <uva2ka>
8010817d:	83 c4 10             	add    $0x10,%esp
80108180:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108183:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108187:	75 07                	jne    80108190 <copyout+0x3f>
      return -1;
80108189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010818e:	eb 61                	jmp    801081f1 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108190:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108193:	2b 45 0c             	sub    0xc(%ebp),%eax
80108196:	05 00 10 00 00       	add    $0x1000,%eax
8010819b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a1:	3b 45 14             	cmp    0x14(%ebp),%eax
801081a4:	76 06                	jbe    801081ac <copyout+0x5b>
      n = len;
801081a6:	8b 45 14             	mov    0x14(%ebp),%eax
801081a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801081af:	2b 45 ec             	sub    -0x14(%ebp),%eax
801081b2:	89 c2                	mov    %eax,%edx
801081b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081b7:	01 d0                	add    %edx,%eax
801081b9:	83 ec 04             	sub    $0x4,%esp
801081bc:	ff 75 f0             	push   -0x10(%ebp)
801081bf:	ff 75 f4             	push   -0xc(%ebp)
801081c2:	50                   	push   %eax
801081c3:	e8 29 cc ff ff       	call   80104df1 <memmove>
801081c8:	83 c4 10             	add    $0x10,%esp
    len -= n;
801081cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ce:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081da:	05 00 10 00 00       	add    $0x1000,%eax
801081df:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801081e2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081e6:	0f 85 77 ff ff ff    	jne    80108163 <copyout+0x12>
  }
  return 0;
801081ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081f1:	c9                   	leave
801081f2:	c3                   	ret

801081f3 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801081f3:	f3 0f 1e fb          	endbr32
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801081fd:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108204:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108207:	8b 40 08             	mov    0x8(%eax),%eax
8010820a:	05 00 00 00 80       	add    $0x80000000,%eax
8010820f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108212:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	8b 40 24             	mov    0x24(%eax),%eax
8010821f:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108224:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
8010822b:	00 00 00 

  while(i<madt->len){
8010822e:	90                   	nop
8010822f:	e9 be 00 00 00       	jmp    801082f2 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108237:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010823a:	01 d0                	add    %edx,%eax
8010823c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010823f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108242:	0f b6 00             	movzbl (%eax),%eax
80108245:	0f b6 c0             	movzbl %al,%eax
80108248:	83 f8 05             	cmp    $0x5,%eax
8010824b:	0f 87 a1 00 00 00    	ja     801082f2 <mpinit_uefi+0xff>
80108251:	8b 04 85 6c af 10 80 	mov    -0x7fef5094(,%eax,4),%eax
80108258:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010825b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108261:	a1 80 80 19 80       	mov    0x80198080,%eax
80108266:	83 f8 03             	cmp    $0x3,%eax
80108269:	7f 28                	jg     80108293 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010826b:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108271:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108274:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108278:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010827e:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108284:	88 02                	mov    %al,(%edx)
          ncpu++;
80108286:	a1 80 80 19 80       	mov    0x80198080,%eax
8010828b:	83 c0 01             	add    $0x1,%eax
8010828e:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80108293:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108296:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010829a:	0f b6 c0             	movzbl %al,%eax
8010829d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082a0:	eb 50                	jmp    801082f2 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801082a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801082a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082ab:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801082af:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
801082b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082b7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082bb:	0f b6 c0             	movzbl %al,%eax
801082be:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082c1:	eb 2f                	jmp    801082f2 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801082c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801082c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082cc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082d0:	0f b6 c0             	movzbl %al,%eax
801082d3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082d6:	eb 1a                	jmp    801082f2 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801082d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082db:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801082de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082e5:	0f b6 c0             	movzbl %al,%eax
801082e8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082eb:	eb 05                	jmp    801082f2 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801082ed:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801082f1:	90                   	nop
  while(i<madt->len){
801082f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f5:	8b 40 04             	mov    0x4(%eax),%eax
801082f8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801082fb:	0f 82 33 ff ff ff    	jb     80108234 <mpinit_uefi+0x41>
    }
  }

}
80108301:	90                   	nop
80108302:	90                   	nop
80108303:	c9                   	leave
80108304:	c3                   	ret

80108305 <inb>:
{
80108305:	55                   	push   %ebp
80108306:	89 e5                	mov    %esp,%ebp
80108308:	83 ec 14             	sub    $0x14,%esp
8010830b:	8b 45 08             	mov    0x8(%ebp),%eax
8010830e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108312:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108316:	89 c2                	mov    %eax,%edx
80108318:	ec                   	in     (%dx),%al
80108319:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010831c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108320:	c9                   	leave
80108321:	c3                   	ret

80108322 <outb>:
{
80108322:	55                   	push   %ebp
80108323:	89 e5                	mov    %esp,%ebp
80108325:	83 ec 08             	sub    $0x8,%esp
80108328:	8b 45 08             	mov    0x8(%ebp),%eax
8010832b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010832e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108332:	89 d0                	mov    %edx,%eax
80108334:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108337:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010833b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010833f:	ee                   	out    %al,(%dx)
}
80108340:	90                   	nop
80108341:	c9                   	leave
80108342:	c3                   	ret

80108343 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108343:	f3 0f 1e fb          	endbr32
80108347:	55                   	push   %ebp
80108348:	89 e5                	mov    %esp,%ebp
8010834a:	83 ec 28             	sub    $0x28,%esp
8010834d:	8b 45 08             	mov    0x8(%ebp),%eax
80108350:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108353:	6a 00                	push   $0x0
80108355:	68 fa 03 00 00       	push   $0x3fa
8010835a:	e8 c3 ff ff ff       	call   80108322 <outb>
8010835f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108362:	68 80 00 00 00       	push   $0x80
80108367:	68 fb 03 00 00       	push   $0x3fb
8010836c:	e8 b1 ff ff ff       	call   80108322 <outb>
80108371:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108374:	6a 0c                	push   $0xc
80108376:	68 f8 03 00 00       	push   $0x3f8
8010837b:	e8 a2 ff ff ff       	call   80108322 <outb>
80108380:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108383:	6a 00                	push   $0x0
80108385:	68 f9 03 00 00       	push   $0x3f9
8010838a:	e8 93 ff ff ff       	call   80108322 <outb>
8010838f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108392:	6a 03                	push   $0x3
80108394:	68 fb 03 00 00       	push   $0x3fb
80108399:	e8 84 ff ff ff       	call   80108322 <outb>
8010839e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801083a1:	6a 00                	push   $0x0
801083a3:	68 fc 03 00 00       	push   $0x3fc
801083a8:	e8 75 ff ff ff       	call   80108322 <outb>
801083ad:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801083b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083b7:	eb 11                	jmp    801083ca <uart_debug+0x87>
801083b9:	83 ec 0c             	sub    $0xc,%esp
801083bc:	6a 0a                	push   $0xa
801083be:	e8 df a8 ff ff       	call   80102ca2 <microdelay>
801083c3:	83 c4 10             	add    $0x10,%esp
801083c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083ca:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801083ce:	7f 1a                	jg     801083ea <uart_debug+0xa7>
801083d0:	83 ec 0c             	sub    $0xc,%esp
801083d3:	68 fd 03 00 00       	push   $0x3fd
801083d8:	e8 28 ff ff ff       	call   80108305 <inb>
801083dd:	83 c4 10             	add    $0x10,%esp
801083e0:	0f b6 c0             	movzbl %al,%eax
801083e3:	83 e0 20             	and    $0x20,%eax
801083e6:	85 c0                	test   %eax,%eax
801083e8:	74 cf                	je     801083b9 <uart_debug+0x76>
  outb(COM1+0, p);
801083ea:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801083ee:	0f b6 c0             	movzbl %al,%eax
801083f1:	83 ec 08             	sub    $0x8,%esp
801083f4:	50                   	push   %eax
801083f5:	68 f8 03 00 00       	push   $0x3f8
801083fa:	e8 23 ff ff ff       	call   80108322 <outb>
801083ff:	83 c4 10             	add    $0x10,%esp
}
80108402:	90                   	nop
80108403:	c9                   	leave
80108404:	c3                   	ret

80108405 <uart_debugs>:

void uart_debugs(char *p){
80108405:	f3 0f 1e fb          	endbr32
80108409:	55                   	push   %ebp
8010840a:	89 e5                	mov    %esp,%ebp
8010840c:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010840f:	eb 1b                	jmp    8010842c <uart_debugs+0x27>
    uart_debug(*p++);
80108411:	8b 45 08             	mov    0x8(%ebp),%eax
80108414:	8d 50 01             	lea    0x1(%eax),%edx
80108417:	89 55 08             	mov    %edx,0x8(%ebp)
8010841a:	0f b6 00             	movzbl (%eax),%eax
8010841d:	0f be c0             	movsbl %al,%eax
80108420:	83 ec 0c             	sub    $0xc,%esp
80108423:	50                   	push   %eax
80108424:	e8 1a ff ff ff       	call   80108343 <uart_debug>
80108429:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010842c:	8b 45 08             	mov    0x8(%ebp),%eax
8010842f:	0f b6 00             	movzbl (%eax),%eax
80108432:	84 c0                	test   %al,%al
80108434:	75 db                	jne    80108411 <uart_debugs+0xc>
  }
}
80108436:	90                   	nop
80108437:	90                   	nop
80108438:	c9                   	leave
80108439:	c3                   	ret

8010843a <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010843a:	f3 0f 1e fb          	endbr32
8010843e:	55                   	push   %ebp
8010843f:	89 e5                	mov    %esp,%ebp
80108441:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108444:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010844b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010844e:	8b 50 14             	mov    0x14(%eax),%edx
80108451:	8b 40 10             	mov    0x10(%eax),%eax
80108454:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108459:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010845c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010845f:	8b 40 18             	mov    0x18(%eax),%eax
80108462:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108467:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010846c:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108471:	29 c2                	sub    %eax,%edx
80108473:	89 d0                	mov    %edx,%eax
80108475:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010847a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010847d:	8b 50 24             	mov    0x24(%eax),%edx
80108480:	8b 40 20             	mov    0x20(%eax),%eax
80108483:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108488:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010848b:	8b 50 2c             	mov    0x2c(%eax),%edx
8010848e:	8b 40 28             	mov    0x28(%eax),%eax
80108491:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108496:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108499:	8b 50 34             	mov    0x34(%eax),%edx
8010849c:	8b 40 30             	mov    0x30(%eax),%eax
8010849f:	a3 98 80 19 80       	mov    %eax,0x80198098
}
801084a4:	90                   	nop
801084a5:	c9                   	leave
801084a6:	c3                   	ret

801084a7 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801084a7:	f3 0f 1e fb          	endbr32
801084ab:	55                   	push   %ebp
801084ac:	89 e5                	mov    %esp,%ebp
801084ae:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801084b1:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801084b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ba:	0f af d0             	imul   %eax,%edx
801084bd:	8b 45 08             	mov    0x8(%ebp),%eax
801084c0:	01 d0                	add    %edx,%eax
801084c2:	c1 e0 02             	shl    $0x2,%eax
801084c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801084c8:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801084ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084d1:	01 d0                	add    %edx,%eax
801084d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801084d6:	8b 45 10             	mov    0x10(%ebp),%eax
801084d9:	0f b6 10             	movzbl (%eax),%edx
801084dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084df:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801084e1:	8b 45 10             	mov    0x10(%ebp),%eax
801084e4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801084e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084eb:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801084ee:	8b 45 10             	mov    0x10(%ebp),%eax
801084f1:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801084f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084f8:	88 50 02             	mov    %dl,0x2(%eax)
}
801084fb:	90                   	nop
801084fc:	c9                   	leave
801084fd:	c3                   	ret

801084fe <graphic_scroll_up>:

void graphic_scroll_up(int height){
801084fe:	f3 0f 1e fb          	endbr32
80108502:	55                   	push   %ebp
80108503:	89 e5                	mov    %esp,%ebp
80108505:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108508:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010850e:	8b 45 08             	mov    0x8(%ebp),%eax
80108511:	0f af c2             	imul   %edx,%eax
80108514:	c1 e0 02             	shl    $0x2,%eax
80108517:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010851a:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108523:	29 c2                	sub    %eax,%edx
80108525:	89 d0                	mov    %edx,%eax
80108527:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010852d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108530:	01 ca                	add    %ecx,%edx
80108532:	89 d1                	mov    %edx,%ecx
80108534:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010853a:	83 ec 04             	sub    $0x4,%esp
8010853d:	50                   	push   %eax
8010853e:	51                   	push   %ecx
8010853f:	52                   	push   %edx
80108540:	e8 ac c8 ff ff       	call   80104df1 <memmove>
80108545:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108551:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108557:	01 d1                	add    %edx,%ecx
80108559:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010855c:	29 d1                	sub    %edx,%ecx
8010855e:	89 ca                	mov    %ecx,%edx
80108560:	83 ec 04             	sub    $0x4,%esp
80108563:	50                   	push   %eax
80108564:	6a 00                	push   $0x0
80108566:	52                   	push   %edx
80108567:	e8 be c7 ff ff       	call   80104d2a <memset>
8010856c:	83 c4 10             	add    $0x10,%esp
}
8010856f:	90                   	nop
80108570:	c9                   	leave
80108571:	c3                   	ret

80108572 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108572:	f3 0f 1e fb          	endbr32
80108576:	55                   	push   %ebp
80108577:	89 e5                	mov    %esp,%ebp
80108579:	53                   	push   %ebx
8010857a:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010857d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108584:	e9 b1 00 00 00       	jmp    8010863a <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108589:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108590:	e9 97 00 00 00       	jmp    8010862c <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108595:	8b 45 10             	mov    0x10(%ebp),%eax
80108598:	83 e8 20             	sub    $0x20,%eax
8010859b:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010859e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a1:	01 d0                	add    %edx,%eax
801085a3:	0f b7 84 00 a0 af 10 	movzwl -0x7fef5060(%eax,%eax,1),%eax
801085aa:	80 
801085ab:	0f b7 d0             	movzwl %ax,%edx
801085ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b1:	bb 01 00 00 00       	mov    $0x1,%ebx
801085b6:	89 c1                	mov    %eax,%ecx
801085b8:	d3 e3                	shl    %cl,%ebx
801085ba:	89 d8                	mov    %ebx,%eax
801085bc:	21 d0                	and    %edx,%eax
801085be:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801085c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c4:	ba 01 00 00 00       	mov    $0x1,%edx
801085c9:	89 c1                	mov    %eax,%ecx
801085cb:	d3 e2                	shl    %cl,%edx
801085cd:	89 d0                	mov    %edx,%eax
801085cf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801085d2:	75 2b                	jne    801085ff <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801085d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801085d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085da:	01 c2                	add    %eax,%edx
801085dc:	b8 0e 00 00 00       	mov    $0xe,%eax
801085e1:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085e4:	89 c1                	mov    %eax,%ecx
801085e6:	8b 45 08             	mov    0x8(%ebp),%eax
801085e9:	01 c8                	add    %ecx,%eax
801085eb:	83 ec 04             	sub    $0x4,%esp
801085ee:	68 e0 f4 10 80       	push   $0x8010f4e0
801085f3:	52                   	push   %edx
801085f4:	50                   	push   %eax
801085f5:	e8 ad fe ff ff       	call   801084a7 <graphic_draw_pixel>
801085fa:	83 c4 10             	add    $0x10,%esp
801085fd:	eb 29                	jmp    80108628 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801085ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80108602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108605:	01 c2                	add    %eax,%edx
80108607:	b8 0e 00 00 00       	mov    $0xe,%eax
8010860c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010860f:	89 c1                	mov    %eax,%ecx
80108611:	8b 45 08             	mov    0x8(%ebp),%eax
80108614:	01 c8                	add    %ecx,%eax
80108616:	83 ec 04             	sub    $0x4,%esp
80108619:	68 64 d0 18 80       	push   $0x8018d064
8010861e:	52                   	push   %edx
8010861f:	50                   	push   %eax
80108620:	e8 82 fe ff ff       	call   801084a7 <graphic_draw_pixel>
80108625:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108628:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010862c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108630:	0f 89 5f ff ff ff    	jns    80108595 <font_render+0x23>
  for(int i=0;i<30;i++){
80108636:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010863a:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010863e:	0f 8e 45 ff ff ff    	jle    80108589 <font_render+0x17>
      }
    }
  }
}
80108644:	90                   	nop
80108645:	90                   	nop
80108646:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108649:	c9                   	leave
8010864a:	c3                   	ret

8010864b <font_render_string>:

void font_render_string(char *string,int row){
8010864b:	f3 0f 1e fb          	endbr32
8010864f:	55                   	push   %ebp
80108650:	89 e5                	mov    %esp,%ebp
80108652:	53                   	push   %ebx
80108653:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108656:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010865d:	eb 33                	jmp    80108692 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010865f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108662:	8b 45 08             	mov    0x8(%ebp),%eax
80108665:	01 d0                	add    %edx,%eax
80108667:	0f b6 00             	movzbl (%eax),%eax
8010866a:	0f be d8             	movsbl %al,%ebx
8010866d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108670:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108676:	89 d0                	mov    %edx,%eax
80108678:	c1 e0 04             	shl    $0x4,%eax
8010867b:	29 d0                	sub    %edx,%eax
8010867d:	83 c0 02             	add    $0x2,%eax
80108680:	83 ec 04             	sub    $0x4,%esp
80108683:	53                   	push   %ebx
80108684:	51                   	push   %ecx
80108685:	50                   	push   %eax
80108686:	e8 e7 fe ff ff       	call   80108572 <font_render>
8010868b:	83 c4 10             	add    $0x10,%esp
    i++;
8010868e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108692:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108695:	8b 45 08             	mov    0x8(%ebp),%eax
80108698:	01 d0                	add    %edx,%eax
8010869a:	0f b6 00             	movzbl (%eax),%eax
8010869d:	84 c0                	test   %al,%al
8010869f:	74 06                	je     801086a7 <font_render_string+0x5c>
801086a1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801086a5:	7e b8                	jle    8010865f <font_render_string+0x14>
  }
}
801086a7:	90                   	nop
801086a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086ab:	c9                   	leave
801086ac:	c3                   	ret

801086ad <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801086ad:	f3 0f 1e fb          	endbr32
801086b1:	55                   	push   %ebp
801086b2:	89 e5                	mov    %esp,%ebp
801086b4:	53                   	push   %ebx
801086b5:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801086b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086bf:	eb 6b                	jmp    8010872c <pci_init+0x7f>
    for(int j=0;j<32;j++){
801086c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801086c8:	eb 58                	jmp    80108722 <pci_init+0x75>
      for(int k=0;k<8;k++){
801086ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801086d1:	eb 45                	jmp    80108718 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801086d3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dc:	83 ec 0c             	sub    $0xc,%esp
801086df:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801086e2:	53                   	push   %ebx
801086e3:	6a 00                	push   $0x0
801086e5:	51                   	push   %ecx
801086e6:	52                   	push   %edx
801086e7:	50                   	push   %eax
801086e8:	e8 c0 00 00 00       	call   801087ad <pci_access_config>
801086ed:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801086f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086f3:	0f b7 c0             	movzwl %ax,%eax
801086f6:	3d ff ff 00 00       	cmp    $0xffff,%eax
801086fb:	74 17                	je     80108714 <pci_init+0x67>
        pci_init_device(i,j,k);
801086fd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108700:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108706:	83 ec 04             	sub    $0x4,%esp
80108709:	51                   	push   %ecx
8010870a:	52                   	push   %edx
8010870b:	50                   	push   %eax
8010870c:	e8 4f 01 00 00       	call   80108860 <pci_init_device>
80108711:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108714:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108718:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010871c:	7e b5                	jle    801086d3 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010871e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108722:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108726:	7e a2                	jle    801086ca <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108728:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010872c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108733:	7e 8c                	jle    801086c1 <pci_init+0x14>
      }
      }
    }
  }
}
80108735:	90                   	nop
80108736:	90                   	nop
80108737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010873a:	c9                   	leave
8010873b:	c3                   	ret

8010873c <pci_write_config>:

void pci_write_config(uint config){
8010873c:	f3 0f 1e fb          	endbr32
80108740:	55                   	push   %ebp
80108741:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108743:	8b 45 08             	mov    0x8(%ebp),%eax
80108746:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010874b:	89 c0                	mov    %eax,%eax
8010874d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010874e:	90                   	nop
8010874f:	5d                   	pop    %ebp
80108750:	c3                   	ret

80108751 <pci_write_data>:

void pci_write_data(uint config){
80108751:	f3 0f 1e fb          	endbr32
80108755:	55                   	push   %ebp
80108756:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108758:	8b 45 08             	mov    0x8(%ebp),%eax
8010875b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108760:	89 c0                	mov    %eax,%eax
80108762:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108763:	90                   	nop
80108764:	5d                   	pop    %ebp
80108765:	c3                   	ret

80108766 <pci_read_config>:
uint pci_read_config(){
80108766:	f3 0f 1e fb          	endbr32
8010876a:	55                   	push   %ebp
8010876b:	89 e5                	mov    %esp,%ebp
8010876d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108770:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108775:	ed                   	in     (%dx),%eax
80108776:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108779:	83 ec 0c             	sub    $0xc,%esp
8010877c:	68 c8 00 00 00       	push   $0xc8
80108781:	e8 1c a5 ff ff       	call   80102ca2 <microdelay>
80108786:	83 c4 10             	add    $0x10,%esp
  return data;
80108789:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010878c:	c9                   	leave
8010878d:	c3                   	ret

8010878e <pci_test>:


void pci_test(){
8010878e:	f3 0f 1e fb          	endbr32
80108792:	55                   	push   %ebp
80108793:	89 e5                	mov    %esp,%ebp
80108795:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108798:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010879f:	ff 75 fc             	push   -0x4(%ebp)
801087a2:	e8 95 ff ff ff       	call   8010873c <pci_write_config>
801087a7:	83 c4 04             	add    $0x4,%esp
}
801087aa:	90                   	nop
801087ab:	c9                   	leave
801087ac:	c3                   	ret

801087ad <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801087ad:	f3 0f 1e fb          	endbr32
801087b1:	55                   	push   %ebp
801087b2:	89 e5                	mov    %esp,%ebp
801087b4:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087b7:	8b 45 08             	mov    0x8(%ebp),%eax
801087ba:	c1 e0 10             	shl    $0x10,%eax
801087bd:	25 00 00 ff 00       	and    $0xff0000,%eax
801087c2:	89 c2                	mov    %eax,%edx
801087c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c7:	c1 e0 0b             	shl    $0xb,%eax
801087ca:	0f b7 c0             	movzwl %ax,%eax
801087cd:	09 c2                	or     %eax,%edx
801087cf:	8b 45 10             	mov    0x10(%ebp),%eax
801087d2:	c1 e0 08             	shl    $0x8,%eax
801087d5:	25 00 07 00 00       	and    $0x700,%eax
801087da:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087dc:	8b 45 14             	mov    0x14(%ebp),%eax
801087df:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087e4:	09 d0                	or     %edx,%eax
801087e6:	0d 00 00 00 80       	or     $0x80000000,%eax
801087eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801087ee:	ff 75 f4             	push   -0xc(%ebp)
801087f1:	e8 46 ff ff ff       	call   8010873c <pci_write_config>
801087f6:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801087f9:	e8 68 ff ff ff       	call   80108766 <pci_read_config>
801087fe:	8b 55 18             	mov    0x18(%ebp),%edx
80108801:	89 02                	mov    %eax,(%edx)
}
80108803:	90                   	nop
80108804:	c9                   	leave
80108805:	c3                   	ret

80108806 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108806:	f3 0f 1e fb          	endbr32
8010880a:	55                   	push   %ebp
8010880b:	89 e5                	mov    %esp,%ebp
8010880d:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108810:	8b 45 08             	mov    0x8(%ebp),%eax
80108813:	c1 e0 10             	shl    $0x10,%eax
80108816:	25 00 00 ff 00       	and    $0xff0000,%eax
8010881b:	89 c2                	mov    %eax,%edx
8010881d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108820:	c1 e0 0b             	shl    $0xb,%eax
80108823:	0f b7 c0             	movzwl %ax,%eax
80108826:	09 c2                	or     %eax,%edx
80108828:	8b 45 10             	mov    0x10(%ebp),%eax
8010882b:	c1 e0 08             	shl    $0x8,%eax
8010882e:	25 00 07 00 00       	and    $0x700,%eax
80108833:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108835:	8b 45 14             	mov    0x14(%ebp),%eax
80108838:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010883d:	09 d0                	or     %edx,%eax
8010883f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108847:	ff 75 fc             	push   -0x4(%ebp)
8010884a:	e8 ed fe ff ff       	call   8010873c <pci_write_config>
8010884f:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108852:	ff 75 18             	push   0x18(%ebp)
80108855:	e8 f7 fe ff ff       	call   80108751 <pci_write_data>
8010885a:	83 c4 04             	add    $0x4,%esp
}
8010885d:	90                   	nop
8010885e:	c9                   	leave
8010885f:	c3                   	ret

80108860 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108860:	f3 0f 1e fb          	endbr32
80108864:	55                   	push   %ebp
80108865:	89 e5                	mov    %esp,%ebp
80108867:	53                   	push   %ebx
80108868:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010886b:	8b 45 08             	mov    0x8(%ebp),%eax
8010886e:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108873:	8b 45 0c             	mov    0xc(%ebp),%eax
80108876:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
8010887b:	8b 45 10             	mov    0x10(%ebp),%eax
8010887e:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108883:	ff 75 10             	push   0x10(%ebp)
80108886:	ff 75 0c             	push   0xc(%ebp)
80108889:	ff 75 08             	push   0x8(%ebp)
8010888c:	68 e4 c5 10 80       	push   $0x8010c5e4
80108891:	e8 76 7b ff ff       	call   8010040c <cprintf>
80108896:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108899:	83 ec 0c             	sub    $0xc,%esp
8010889c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010889f:	50                   	push   %eax
801088a0:	6a 00                	push   $0x0
801088a2:	ff 75 10             	push   0x10(%ebp)
801088a5:	ff 75 0c             	push   0xc(%ebp)
801088a8:	ff 75 08             	push   0x8(%ebp)
801088ab:	e8 fd fe ff ff       	call   801087ad <pci_access_config>
801088b0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801088b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b6:	c1 e8 10             	shr    $0x10,%eax
801088b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801088bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088bf:	25 ff ff 00 00       	and    $0xffff,%eax
801088c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801088cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d2:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801088d7:	83 ec 04             	sub    $0x4,%esp
801088da:	ff 75 f0             	push   -0x10(%ebp)
801088dd:	ff 75 f4             	push   -0xc(%ebp)
801088e0:	68 18 c6 10 80       	push   $0x8010c618
801088e5:	e8 22 7b ff ff       	call   8010040c <cprintf>
801088ea:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801088ed:	83 ec 0c             	sub    $0xc,%esp
801088f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088f3:	50                   	push   %eax
801088f4:	6a 08                	push   $0x8
801088f6:	ff 75 10             	push   0x10(%ebp)
801088f9:	ff 75 0c             	push   0xc(%ebp)
801088fc:	ff 75 08             	push   0x8(%ebp)
801088ff:	e8 a9 fe ff ff       	call   801087ad <pci_access_config>
80108904:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108907:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010890a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010890d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108910:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108913:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108919:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010891c:	0f b6 c0             	movzbl %al,%eax
8010891f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108922:	c1 eb 18             	shr    $0x18,%ebx
80108925:	83 ec 0c             	sub    $0xc,%esp
80108928:	51                   	push   %ecx
80108929:	52                   	push   %edx
8010892a:	50                   	push   %eax
8010892b:	53                   	push   %ebx
8010892c:	68 3c c6 10 80       	push   $0x8010c63c
80108931:	e8 d6 7a ff ff       	call   8010040c <cprintf>
80108936:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108939:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010893c:	c1 e8 18             	shr    $0x18,%eax
8010893f:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
80108944:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108947:	c1 e8 10             	shr    $0x10,%eax
8010894a:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
8010894f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108952:	c1 e8 08             	shr    $0x8,%eax
80108955:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
8010895a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010895d:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108962:	83 ec 0c             	sub    $0xc,%esp
80108965:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108968:	50                   	push   %eax
80108969:	6a 10                	push   $0x10
8010896b:	ff 75 10             	push   0x10(%ebp)
8010896e:	ff 75 0c             	push   0xc(%ebp)
80108971:	ff 75 08             	push   0x8(%ebp)
80108974:	e8 34 fe ff ff       	call   801087ad <pci_access_config>
80108979:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010897c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010897f:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108984:	83 ec 0c             	sub    $0xc,%esp
80108987:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010898a:	50                   	push   %eax
8010898b:	6a 14                	push   $0x14
8010898d:	ff 75 10             	push   0x10(%ebp)
80108990:	ff 75 0c             	push   0xc(%ebp)
80108993:	ff 75 08             	push   0x8(%ebp)
80108996:	e8 12 fe ff ff       	call   801087ad <pci_access_config>
8010899b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010899e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a1:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089a6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801089ad:	75 5a                	jne    80108a09 <pci_init_device+0x1a9>
801089af:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801089b6:	75 51                	jne    80108a09 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801089b8:	83 ec 0c             	sub    $0xc,%esp
801089bb:	68 81 c6 10 80       	push   $0x8010c681
801089c0:	e8 47 7a ff ff       	call   8010040c <cprintf>
801089c5:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801089c8:	83 ec 0c             	sub    $0xc,%esp
801089cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089ce:	50                   	push   %eax
801089cf:	68 f0 00 00 00       	push   $0xf0
801089d4:	ff 75 10             	push   0x10(%ebp)
801089d7:	ff 75 0c             	push   0xc(%ebp)
801089da:	ff 75 08             	push   0x8(%ebp)
801089dd:	e8 cb fd ff ff       	call   801087ad <pci_access_config>
801089e2:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801089e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e8:	83 ec 08             	sub    $0x8,%esp
801089eb:	50                   	push   %eax
801089ec:	68 9b c6 10 80       	push   $0x8010c69b
801089f1:	e8 16 7a ff ff       	call   8010040c <cprintf>
801089f6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801089f9:	83 ec 0c             	sub    $0xc,%esp
801089fc:	68 9c 80 19 80       	push   $0x8019809c
80108a01:	e8 09 00 00 00       	call   80108a0f <i8254_init>
80108a06:	83 c4 10             	add    $0x10,%esp
  }
}
80108a09:	90                   	nop
80108a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a0d:	c9                   	leave
80108a0e:	c3                   	ret

80108a0f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a0f:	f3 0f 1e fb          	endbr32
80108a13:	55                   	push   %ebp
80108a14:	89 e5                	mov    %esp,%ebp
80108a16:	53                   	push   %ebx
80108a17:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a1d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a21:	0f b6 c8             	movzbl %al,%ecx
80108a24:	8b 45 08             	mov    0x8(%ebp),%eax
80108a27:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a2b:	0f b6 d0             	movzbl %al,%edx
80108a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a31:	0f b6 00             	movzbl (%eax),%eax
80108a34:	0f b6 c0             	movzbl %al,%eax
80108a37:	83 ec 0c             	sub    $0xc,%esp
80108a3a:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a3d:	53                   	push   %ebx
80108a3e:	6a 04                	push   $0x4
80108a40:	51                   	push   %ecx
80108a41:	52                   	push   %edx
80108a42:	50                   	push   %eax
80108a43:	e8 65 fd ff ff       	call   801087ad <pci_access_config>
80108a48:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4e:	83 c8 04             	or     $0x4,%eax
80108a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a54:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a57:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a5e:	0f b6 c8             	movzbl %al,%ecx
80108a61:	8b 45 08             	mov    0x8(%ebp),%eax
80108a64:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a68:	0f b6 d0             	movzbl %al,%edx
80108a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6e:	0f b6 00             	movzbl (%eax),%eax
80108a71:	0f b6 c0             	movzbl %al,%eax
80108a74:	83 ec 0c             	sub    $0xc,%esp
80108a77:	53                   	push   %ebx
80108a78:	6a 04                	push   $0x4
80108a7a:	51                   	push   %ecx
80108a7b:	52                   	push   %edx
80108a7c:	50                   	push   %eax
80108a7d:	e8 84 fd ff ff       	call   80108806 <pci_write_config_register>
80108a82:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a85:	8b 45 08             	mov    0x8(%ebp),%eax
80108a88:	8b 40 10             	mov    0x10(%eax),%eax
80108a8b:	05 00 00 00 40       	add    $0x40000000,%eax
80108a90:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108a95:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108a9d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aa2:	05 d8 00 00 00       	add    $0xd8,%eax
80108aa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aad:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab6:	8b 00                	mov    (%eax),%eax
80108ab8:	0d 00 00 00 04       	or     $0x4000000,%eax
80108abd:	89 c2                	mov    %eax,%edx
80108abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac2:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac7:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad0:	8b 00                	mov    (%eax),%eax
80108ad2:	83 c8 40             	or     $0x40,%eax
80108ad5:	89 c2                	mov    %eax,%edx
80108ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ada:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108adf:	8b 10                	mov    (%eax),%edx
80108ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae4:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108ae6:	83 ec 0c             	sub    $0xc,%esp
80108ae9:	68 b0 c6 10 80       	push   $0x8010c6b0
80108aee:	e8 19 79 ff ff       	call   8010040c <cprintf>
80108af3:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108af6:	e8 f5 9d ff ff       	call   801028f0 <kalloc>
80108afb:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
80108b00:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b0b:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b10:	83 ec 08             	sub    $0x8,%esp
80108b13:	50                   	push   %eax
80108b14:	68 d2 c6 10 80       	push   $0x8010c6d2
80108b19:	e8 ee 78 ff ff       	call   8010040c <cprintf>
80108b1e:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b21:	e8 50 00 00 00       	call   80108b76 <i8254_init_recv>
  i8254_init_send();
80108b26:	e8 6d 03 00 00       	call   80108e98 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b2b:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b32:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b35:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b3c:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b3f:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b46:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b49:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b50:	0f b6 c0             	movzbl %al,%eax
80108b53:	83 ec 0c             	sub    $0xc,%esp
80108b56:	53                   	push   %ebx
80108b57:	51                   	push   %ecx
80108b58:	52                   	push   %edx
80108b59:	50                   	push   %eax
80108b5a:	68 e0 c6 10 80       	push   $0x8010c6e0
80108b5f:	e8 a8 78 ff ff       	call   8010040c <cprintf>
80108b64:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b70:	90                   	nop
80108b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b74:	c9                   	leave
80108b75:	c3                   	ret

80108b76 <i8254_init_recv>:

void i8254_init_recv(){
80108b76:	f3 0f 1e fb          	endbr32
80108b7a:	55                   	push   %ebp
80108b7b:	89 e5                	mov    %esp,%ebp
80108b7d:	57                   	push   %edi
80108b7e:	56                   	push   %esi
80108b7f:	53                   	push   %ebx
80108b80:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b83:	83 ec 0c             	sub    $0xc,%esp
80108b86:	6a 00                	push   $0x0
80108b88:	e8 ec 04 00 00       	call   80109079 <i8254_read_eeprom>
80108b8d:	83 c4 10             	add    $0x10,%esp
80108b90:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108b93:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b96:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108b9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b9e:	c1 e8 08             	shr    $0x8,%eax
80108ba1:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108ba6:	83 ec 0c             	sub    $0xc,%esp
80108ba9:	6a 01                	push   $0x1
80108bab:	e8 c9 04 00 00       	call   80109079 <i8254_read_eeprom>
80108bb0:	83 c4 10             	add    $0x10,%esp
80108bb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108bb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bb9:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108bbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bc1:	c1 e8 08             	shr    $0x8,%eax
80108bc4:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108bc9:	83 ec 0c             	sub    $0xc,%esp
80108bcc:	6a 02                	push   $0x2
80108bce:	e8 a6 04 00 00       	call   80109079 <i8254_read_eeprom>
80108bd3:	83 c4 10             	add    $0x10,%esp
80108bd6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108bd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bdc:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108be1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108be4:	c1 e8 08             	shr    $0x8,%eax
80108be7:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108bec:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bf3:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108bf6:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bfd:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108c00:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c07:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c0a:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c11:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c14:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c1b:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c1e:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c25:	0f b6 c0             	movzbl %al,%eax
80108c28:	83 ec 04             	sub    $0x4,%esp
80108c2b:	57                   	push   %edi
80108c2c:	56                   	push   %esi
80108c2d:	53                   	push   %ebx
80108c2e:	51                   	push   %ecx
80108c2f:	52                   	push   %edx
80108c30:	50                   	push   %eax
80108c31:	68 f8 c6 10 80       	push   $0x8010c6f8
80108c36:	e8 d1 77 ff ff       	call   8010040c <cprintf>
80108c3b:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c3e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c43:	05 00 54 00 00       	add    $0x5400,%eax
80108c48:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c4b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c50:	05 04 54 00 00       	add    $0x5404,%eax
80108c55:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c5b:	c1 e0 10             	shl    $0x10,%eax
80108c5e:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c61:	89 c2                	mov    %eax,%edx
80108c63:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c66:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c68:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c6b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c70:	89 c2                	mov    %eax,%edx
80108c72:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c75:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c77:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c7c:	05 00 52 00 00       	add    $0x5200,%eax
80108c81:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c8b:	eb 19                	jmp    80108ca6 <i8254_init_recv+0x130>
    mta[i] = 0;
80108c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c97:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c9a:	01 d0                	add    %edx,%eax
80108c9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ca2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ca6:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108caa:	7e e1                	jle    80108c8d <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108cac:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cb1:	05 d0 00 00 00       	add    $0xd0,%eax
80108cb6:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cb9:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108cbc:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108cc2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cc7:	05 c8 00 00 00       	add    $0xc8,%eax
80108ccc:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ccf:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108cd2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108cd8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cdd:	05 28 28 00 00       	add    $0x2828,%eax
80108ce2:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ce5:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108ce8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108cee:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cf3:	05 00 01 00 00       	add    $0x100,%eax
80108cf8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108cfb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cfe:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d04:	e8 e7 9b ff ff       	call   801028f0 <kalloc>
80108d09:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d0c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d11:	05 00 28 00 00       	add    $0x2800,%eax
80108d16:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d19:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d1e:	05 04 28 00 00       	add    $0x2804,%eax
80108d23:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d26:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d2b:	05 08 28 00 00       	add    $0x2808,%eax
80108d30:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d33:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d38:	05 10 28 00 00       	add    $0x2810,%eax
80108d3d:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d40:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d45:	05 18 28 00 00       	add    $0x2818,%eax
80108d4a:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d4d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d50:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d56:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d59:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d5b:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d64:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d67:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d6d:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d76:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d79:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d7f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d82:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d85:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d8c:	eb 73                	jmp    80108e01 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d91:	c1 e0 04             	shl    $0x4,%eax
80108d94:	89 c2                	mov    %eax,%edx
80108d96:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d99:	01 d0                	add    %edx,%eax
80108d9b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da5:	c1 e0 04             	shl    $0x4,%eax
80108da8:	89 c2                	mov    %eax,%edx
80108daa:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dad:	01 d0                	add    %edx,%eax
80108daf:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db8:	c1 e0 04             	shl    $0x4,%eax
80108dbb:	89 c2                	mov    %eax,%edx
80108dbd:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dc0:	01 d0                	add    %edx,%eax
80108dc2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108dc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dcb:	c1 e0 04             	shl    $0x4,%eax
80108dce:	89 c2                	mov    %eax,%edx
80108dd0:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dd3:	01 d0                	add    %edx,%eax
80108dd5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ddc:	c1 e0 04             	shl    $0x4,%eax
80108ddf:	89 c2                	mov    %eax,%edx
80108de1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de4:	01 d0                	add    %edx,%eax
80108de6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108dea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ded:	c1 e0 04             	shl    $0x4,%eax
80108df0:	89 c2                	mov    %eax,%edx
80108df2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df5:	01 d0                	add    %edx,%eax
80108df7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108dfd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108e01:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e08:	7e 84                	jle    80108d8e <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e0a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e11:	eb 57                	jmp    80108e6a <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108e13:	e8 d8 9a ff ff       	call   801028f0 <kalloc>
80108e18:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e1b:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e1f:	75 12                	jne    80108e33 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108e21:	83 ec 0c             	sub    $0xc,%esp
80108e24:	68 18 c7 10 80       	push   $0x8010c718
80108e29:	e8 de 75 ff ff       	call   8010040c <cprintf>
80108e2e:	83 c4 10             	add    $0x10,%esp
      break;
80108e31:	eb 3d                	jmp    80108e70 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e36:	c1 e0 04             	shl    $0x4,%eax
80108e39:	89 c2                	mov    %eax,%edx
80108e3b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e3e:	01 d0                	add    %edx,%eax
80108e40:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e43:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e49:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e4e:	83 c0 01             	add    $0x1,%eax
80108e51:	c1 e0 04             	shl    $0x4,%eax
80108e54:	89 c2                	mov    %eax,%edx
80108e56:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e59:	01 d0                	add    %edx,%eax
80108e5b:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e5e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e64:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e66:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e6a:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e6e:	7e a3                	jle    80108e13 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108e70:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e73:	8b 00                	mov    (%eax),%eax
80108e75:	83 c8 02             	or     $0x2,%eax
80108e78:	89 c2                	mov    %eax,%edx
80108e7a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e7d:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e7f:	83 ec 0c             	sub    $0xc,%esp
80108e82:	68 38 c7 10 80       	push   $0x8010c738
80108e87:	e8 80 75 ff ff       	call   8010040c <cprintf>
80108e8c:	83 c4 10             	add    $0x10,%esp
}
80108e8f:	90                   	nop
80108e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108e93:	5b                   	pop    %ebx
80108e94:	5e                   	pop    %esi
80108e95:	5f                   	pop    %edi
80108e96:	5d                   	pop    %ebp
80108e97:	c3                   	ret

80108e98 <i8254_init_send>:

void i8254_init_send(){
80108e98:	f3 0f 1e fb          	endbr32
80108e9c:	55                   	push   %ebp
80108e9d:	89 e5                	mov    %esp,%ebp
80108e9f:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108ea2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ea7:	05 28 38 00 00       	add    $0x3828,%eax
80108eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb2:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108eb8:	e8 33 9a ff ff       	call   801028f0 <kalloc>
80108ebd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ec0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ec5:	05 00 38 00 00       	add    $0x3800,%eax
80108eca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108ecd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ed2:	05 04 38 00 00       	add    $0x3804,%eax
80108ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108eda:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108edf:	05 08 38 00 00       	add    $0x3808,%eax
80108ee4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ee7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eea:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ef3:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ef8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108efe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f01:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f07:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f0c:	05 10 38 00 00       	add    $0x3810,%eax
80108f11:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f14:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f19:	05 18 38 00 00       	add    $0x3818,%eax
80108f1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f21:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f36:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f40:	e9 82 00 00 00       	jmp    80108fc7 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f48:	c1 e0 04             	shl    $0x4,%eax
80108f4b:	89 c2                	mov    %eax,%edx
80108f4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f50:	01 d0                	add    %edx,%eax
80108f52:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5c:	c1 e0 04             	shl    $0x4,%eax
80108f5f:	89 c2                	mov    %eax,%edx
80108f61:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f64:	01 d0                	add    %edx,%eax
80108f66:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6f:	c1 e0 04             	shl    $0x4,%eax
80108f72:	89 c2                	mov    %eax,%edx
80108f74:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f77:	01 d0                	add    %edx,%eax
80108f79:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f80:	c1 e0 04             	shl    $0x4,%eax
80108f83:	89 c2                	mov    %eax,%edx
80108f85:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f88:	01 d0                	add    %edx,%eax
80108f8a:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f91:	c1 e0 04             	shl    $0x4,%eax
80108f94:	89 c2                	mov    %eax,%edx
80108f96:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f99:	01 d0                	add    %edx,%eax
80108f9b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa2:	c1 e0 04             	shl    $0x4,%eax
80108fa5:	89 c2                	mov    %eax,%edx
80108fa7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108faa:	01 d0                	add    %edx,%eax
80108fac:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb3:	c1 e0 04             	shl    $0x4,%eax
80108fb6:	89 c2                	mov    %eax,%edx
80108fb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fbb:	01 d0                	add    %edx,%eax
80108fbd:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fc7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108fce:	0f 8e 71 ff ff ff    	jle    80108f45 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fd4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fdb:	eb 57                	jmp    80109034 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108fdd:	e8 0e 99 ff ff       	call   801028f0 <kalloc>
80108fe2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108fe5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108fe9:	75 12                	jne    80108ffd <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108feb:	83 ec 0c             	sub    $0xc,%esp
80108fee:	68 18 c7 10 80       	push   $0x8010c718
80108ff3:	e8 14 74 ff ff       	call   8010040c <cprintf>
80108ff8:	83 c4 10             	add    $0x10,%esp
      break;
80108ffb:	eb 3d                	jmp    8010903a <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109000:	c1 e0 04             	shl    $0x4,%eax
80109003:	89 c2                	mov    %eax,%edx
80109005:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109008:	01 d0                	add    %edx,%eax
8010900a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010900d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109013:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109018:	83 c0 01             	add    $0x1,%eax
8010901b:	c1 e0 04             	shl    $0x4,%eax
8010901e:	89 c2                	mov    %eax,%edx
80109020:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109023:	01 d0                	add    %edx,%eax
80109025:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109028:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010902e:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109030:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109034:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109038:	7e a3                	jle    80108fdd <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010903a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010903f:	05 00 04 00 00       	add    $0x400,%eax
80109044:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109047:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010904a:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109050:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109055:	05 10 04 00 00       	add    $0x410,%eax
8010905a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010905d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109060:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109066:	83 ec 0c             	sub    $0xc,%esp
80109069:	68 58 c7 10 80       	push   $0x8010c758
8010906e:	e8 99 73 ff ff       	call   8010040c <cprintf>
80109073:	83 c4 10             	add    $0x10,%esp

}
80109076:	90                   	nop
80109077:	c9                   	leave
80109078:	c3                   	ret

80109079 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109079:	f3 0f 1e fb          	endbr32
8010907d:	55                   	push   %ebp
8010907e:	89 e5                	mov    %esp,%ebp
80109080:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109083:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109088:	83 c0 14             	add    $0x14,%eax
8010908b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010908e:	8b 45 08             	mov    0x8(%ebp),%eax
80109091:	c1 e0 08             	shl    $0x8,%eax
80109094:	0f b7 c0             	movzwl %ax,%eax
80109097:	83 c8 01             	or     $0x1,%eax
8010909a:	89 c2                	mov    %eax,%edx
8010909c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801090a1:	83 ec 0c             	sub    $0xc,%esp
801090a4:	68 78 c7 10 80       	push   $0x8010c778
801090a9:	e8 5e 73 ff ff       	call   8010040c <cprintf>
801090ae:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b4:	8b 00                	mov    (%eax),%eax
801090b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090bc:	83 e0 10             	and    $0x10,%eax
801090bf:	85 c0                	test   %eax,%eax
801090c1:	75 02                	jne    801090c5 <i8254_read_eeprom+0x4c>
  while(1){
801090c3:	eb dc                	jmp    801090a1 <i8254_read_eeprom+0x28>
      break;
801090c5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801090c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c9:	8b 00                	mov    (%eax),%eax
801090cb:	c1 e8 10             	shr    $0x10,%eax
}
801090ce:	c9                   	leave
801090cf:	c3                   	ret

801090d0 <i8254_recv>:
void i8254_recv(){
801090d0:	f3 0f 1e fb          	endbr32
801090d4:	55                   	push   %ebp
801090d5:	89 e5                	mov    %esp,%ebp
801090d7:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801090da:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090df:	05 10 28 00 00       	add    $0x2810,%eax
801090e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801090e7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090ec:	05 18 28 00 00       	add    $0x2818,%eax
801090f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801090f4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090f9:	05 00 28 00 00       	add    $0x2800,%eax
801090fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109101:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109104:	8b 00                	mov    (%eax),%eax
80109106:	05 00 00 00 80       	add    $0x80000000,%eax
8010910b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010910e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109111:	8b 10                	mov    (%eax),%edx
80109113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109116:	8b 00                	mov    (%eax),%eax
80109118:	29 c2                	sub    %eax,%edx
8010911a:	89 d0                	mov    %edx,%eax
8010911c:	25 ff 00 00 00       	and    $0xff,%eax
80109121:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109124:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109128:	7e 37                	jle    80109161 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010912a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912d:	8b 00                	mov    (%eax),%eax
8010912f:	c1 e0 04             	shl    $0x4,%eax
80109132:	89 c2                	mov    %eax,%edx
80109134:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109137:	01 d0                	add    %edx,%eax
80109139:	8b 00                	mov    (%eax),%eax
8010913b:	05 00 00 00 80       	add    $0x80000000,%eax
80109140:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109146:	8b 00                	mov    (%eax),%eax
80109148:	83 c0 01             	add    $0x1,%eax
8010914b:	0f b6 d0             	movzbl %al,%edx
8010914e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109151:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109153:	83 ec 0c             	sub    $0xc,%esp
80109156:	ff 75 e0             	push   -0x20(%ebp)
80109159:	e8 47 09 00 00       	call   80109aa5 <eth_proc>
8010915e:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109164:	8b 10                	mov    (%eax),%edx
80109166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109169:	8b 00                	mov    (%eax),%eax
8010916b:	39 c2                	cmp    %eax,%edx
8010916d:	75 9f                	jne    8010910e <i8254_recv+0x3e>
      (*rdt)--;
8010916f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109172:	8b 00                	mov    (%eax),%eax
80109174:	8d 50 ff             	lea    -0x1(%eax),%edx
80109177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010917a:	89 10                	mov    %edx,(%eax)
  while(1){
8010917c:	eb 90                	jmp    8010910e <i8254_recv+0x3e>

8010917e <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010917e:	f3 0f 1e fb          	endbr32
80109182:	55                   	push   %ebp
80109183:	89 e5                	mov    %esp,%ebp
80109185:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109188:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010918d:	05 10 38 00 00       	add    $0x3810,%eax
80109192:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109195:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010919a:	05 18 38 00 00       	add    $0x3818,%eax
8010919f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091a2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801091a7:	05 00 38 00 00       	add    $0x3800,%eax
801091ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801091af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091b2:	8b 00                	mov    (%eax),%eax
801091b4:	05 00 00 00 80       	add    $0x80000000,%eax
801091b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091bf:	8b 10                	mov    (%eax),%edx
801091c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c4:	8b 00                	mov    (%eax),%eax
801091c6:	29 c2                	sub    %eax,%edx
801091c8:	89 d0                	mov    %edx,%eax
801091ca:	0f b6 c0             	movzbl %al,%eax
801091cd:	ba 00 01 00 00       	mov    $0x100,%edx
801091d2:	29 c2                	sub    %eax,%edx
801091d4:	89 d0                	mov    %edx,%eax
801091d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801091d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091dc:	8b 00                	mov    (%eax),%eax
801091de:	25 ff 00 00 00       	and    $0xff,%eax
801091e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801091e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091ea:	0f 8e a8 00 00 00    	jle    80109298 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801091f0:	8b 45 08             	mov    0x8(%ebp),%eax
801091f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801091f6:	89 d1                	mov    %edx,%ecx
801091f8:	c1 e1 04             	shl    $0x4,%ecx
801091fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801091fe:	01 ca                	add    %ecx,%edx
80109200:	8b 12                	mov    (%edx),%edx
80109202:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109208:	83 ec 04             	sub    $0x4,%esp
8010920b:	ff 75 0c             	push   0xc(%ebp)
8010920e:	50                   	push   %eax
8010920f:	52                   	push   %edx
80109210:	e8 dc bb ff ff       	call   80104df1 <memmove>
80109215:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109218:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010921b:	c1 e0 04             	shl    $0x4,%eax
8010921e:	89 c2                	mov    %eax,%edx
80109220:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109223:	01 d0                	add    %edx,%eax
80109225:	8b 55 0c             	mov    0xc(%ebp),%edx
80109228:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010922c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010922f:	c1 e0 04             	shl    $0x4,%eax
80109232:	89 c2                	mov    %eax,%edx
80109234:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109237:	01 d0                	add    %edx,%eax
80109239:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010923d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109240:	c1 e0 04             	shl    $0x4,%eax
80109243:	89 c2                	mov    %eax,%edx
80109245:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109248:	01 d0                	add    %edx,%eax
8010924a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010924e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109251:	c1 e0 04             	shl    $0x4,%eax
80109254:	89 c2                	mov    %eax,%edx
80109256:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109259:	01 d0                	add    %edx,%eax
8010925b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010925f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109262:	c1 e0 04             	shl    $0x4,%eax
80109265:	89 c2                	mov    %eax,%edx
80109267:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010926a:	01 d0                	add    %edx,%eax
8010926c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109272:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109275:	c1 e0 04             	shl    $0x4,%eax
80109278:	89 c2                	mov    %eax,%edx
8010927a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927d:	01 d0                	add    %edx,%eax
8010927f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109283:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109286:	8b 00                	mov    (%eax),%eax
80109288:	83 c0 01             	add    $0x1,%eax
8010928b:	0f b6 d0             	movzbl %al,%edx
8010928e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109291:	89 10                	mov    %edx,(%eax)
    return len;
80109293:	8b 45 0c             	mov    0xc(%ebp),%eax
80109296:	eb 05                	jmp    8010929d <i8254_send+0x11f>
  }else{
    return -1;
80109298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010929d:	c9                   	leave
8010929e:	c3                   	ret

8010929f <i8254_intr>:

void i8254_intr(){
8010929f:	f3 0f 1e fb          	endbr32
801092a3:	55                   	push   %ebp
801092a4:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801092a6:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801092ab:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801092b1:	90                   	nop
801092b2:	5d                   	pop    %ebp
801092b3:	c3                   	ret

801092b4 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801092b4:	f3 0f 1e fb          	endbr32
801092b8:	55                   	push   %ebp
801092b9:	89 e5                	mov    %esp,%ebp
801092bb:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092be:	8b 45 08             	mov    0x8(%ebp),%eax
801092c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c7:	0f b7 00             	movzwl (%eax),%eax
801092ca:	66 3d 00 01          	cmp    $0x100,%ax
801092ce:	74 0a                	je     801092da <arp_proc+0x26>
801092d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092d5:	e9 4f 01 00 00       	jmp    80109429 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801092da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092dd:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801092e1:	66 83 f8 08          	cmp    $0x8,%ax
801092e5:	74 0a                	je     801092f1 <arp_proc+0x3d>
801092e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092ec:	e9 38 01 00 00       	jmp    80109429 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801092f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801092f8:	3c 06                	cmp    $0x6,%al
801092fa:	74 0a                	je     80109306 <arp_proc+0x52>
801092fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109301:	e9 23 01 00 00       	jmp    80109429 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109309:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010930d:	3c 04                	cmp    $0x4,%al
8010930f:	74 0a                	je     8010931b <arp_proc+0x67>
80109311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109316:	e9 0e 01 00 00       	jmp    80109429 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010931b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931e:	83 c0 18             	add    $0x18,%eax
80109321:	83 ec 04             	sub    $0x4,%esp
80109324:	6a 04                	push   $0x4
80109326:	50                   	push   %eax
80109327:	68 e4 f4 10 80       	push   $0x8010f4e4
8010932c:	e8 64 ba ff ff       	call   80104d95 <memcmp>
80109331:	83 c4 10             	add    $0x10,%esp
80109334:	85 c0                	test   %eax,%eax
80109336:	74 27                	je     8010935f <arp_proc+0xab>
80109338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933b:	83 c0 0e             	add    $0xe,%eax
8010933e:	83 ec 04             	sub    $0x4,%esp
80109341:	6a 04                	push   $0x4
80109343:	50                   	push   %eax
80109344:	68 e4 f4 10 80       	push   $0x8010f4e4
80109349:	e8 47 ba ff ff       	call   80104d95 <memcmp>
8010934e:	83 c4 10             	add    $0x10,%esp
80109351:	85 c0                	test   %eax,%eax
80109353:	74 0a                	je     8010935f <arp_proc+0xab>
80109355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010935a:	e9 ca 00 00 00       	jmp    80109429 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010935f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109362:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109366:	66 3d 00 01          	cmp    $0x100,%ax
8010936a:	75 69                	jne    801093d5 <arp_proc+0x121>
8010936c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936f:	83 c0 18             	add    $0x18,%eax
80109372:	83 ec 04             	sub    $0x4,%esp
80109375:	6a 04                	push   $0x4
80109377:	50                   	push   %eax
80109378:	68 e4 f4 10 80       	push   $0x8010f4e4
8010937d:	e8 13 ba ff ff       	call   80104d95 <memcmp>
80109382:	83 c4 10             	add    $0x10,%esp
80109385:	85 c0                	test   %eax,%eax
80109387:	75 4c                	jne    801093d5 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109389:	e8 62 95 ff ff       	call   801028f0 <kalloc>
8010938e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109391:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109398:	83 ec 04             	sub    $0x4,%esp
8010939b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010939e:	50                   	push   %eax
8010939f:	ff 75 f0             	push   -0x10(%ebp)
801093a2:	ff 75 f4             	push   -0xc(%ebp)
801093a5:	e8 33 04 00 00       	call   801097dd <arp_reply_pkt_create>
801093aa:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801093ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093b0:	83 ec 08             	sub    $0x8,%esp
801093b3:	50                   	push   %eax
801093b4:	ff 75 f0             	push   -0x10(%ebp)
801093b7:	e8 c2 fd ff ff       	call   8010917e <i8254_send>
801093bc:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c2:	83 ec 0c             	sub    $0xc,%esp
801093c5:	50                   	push   %eax
801093c6:	e8 87 94 ff ff       	call   80102852 <kfree>
801093cb:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093ce:	b8 02 00 00 00       	mov    $0x2,%eax
801093d3:	eb 54                	jmp    80109429 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093dc:	66 3d 00 02          	cmp    $0x200,%ax
801093e0:	75 42                	jne    80109424 <arp_proc+0x170>
801093e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e5:	83 c0 18             	add    $0x18,%eax
801093e8:	83 ec 04             	sub    $0x4,%esp
801093eb:	6a 04                	push   $0x4
801093ed:	50                   	push   %eax
801093ee:	68 e4 f4 10 80       	push   $0x8010f4e4
801093f3:	e8 9d b9 ff ff       	call   80104d95 <memcmp>
801093f8:	83 c4 10             	add    $0x10,%esp
801093fb:	85 c0                	test   %eax,%eax
801093fd:	75 25                	jne    80109424 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801093ff:	83 ec 0c             	sub    $0xc,%esp
80109402:	68 7c c7 10 80       	push   $0x8010c77c
80109407:	e8 00 70 ff ff       	call   8010040c <cprintf>
8010940c:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010940f:	83 ec 0c             	sub    $0xc,%esp
80109412:	ff 75 f4             	push   -0xc(%ebp)
80109415:	e8 b7 01 00 00       	call   801095d1 <arp_table_update>
8010941a:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010941d:	b8 01 00 00 00       	mov    $0x1,%eax
80109422:	eb 05                	jmp    80109429 <arp_proc+0x175>
  }else{
    return -1;
80109424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109429:	c9                   	leave
8010942a:	c3                   	ret

8010942b <arp_scan>:

void arp_scan(){
8010942b:	f3 0f 1e fb          	endbr32
8010942f:	55                   	push   %ebp
80109430:	89 e5                	mov    %esp,%ebp
80109432:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109435:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010943c:	eb 6f                	jmp    801094ad <arp_scan+0x82>
    uint send = (uint)kalloc();
8010943e:	e8 ad 94 ff ff       	call   801028f0 <kalloc>
80109443:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109446:	83 ec 04             	sub    $0x4,%esp
80109449:	ff 75 f4             	push   -0xc(%ebp)
8010944c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010944f:	50                   	push   %eax
80109450:	ff 75 ec             	push   -0x14(%ebp)
80109453:	e8 62 00 00 00       	call   801094ba <arp_broadcast>
80109458:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010945b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010945e:	83 ec 08             	sub    $0x8,%esp
80109461:	50                   	push   %eax
80109462:	ff 75 ec             	push   -0x14(%ebp)
80109465:	e8 14 fd ff ff       	call   8010917e <i8254_send>
8010946a:	83 c4 10             	add    $0x10,%esp
8010946d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109470:	eb 22                	jmp    80109494 <arp_scan+0x69>
      microdelay(1);
80109472:	83 ec 0c             	sub    $0xc,%esp
80109475:	6a 01                	push   $0x1
80109477:	e8 26 98 ff ff       	call   80102ca2 <microdelay>
8010947c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010947f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109482:	83 ec 08             	sub    $0x8,%esp
80109485:	50                   	push   %eax
80109486:	ff 75 ec             	push   -0x14(%ebp)
80109489:	e8 f0 fc ff ff       	call   8010917e <i8254_send>
8010948e:	83 c4 10             	add    $0x10,%esp
80109491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109494:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109498:	74 d8                	je     80109472 <arp_scan+0x47>
    }
    kfree((char *)send);
8010949a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010949d:	83 ec 0c             	sub    $0xc,%esp
801094a0:	50                   	push   %eax
801094a1:	e8 ac 93 ff ff       	call   80102852 <kfree>
801094a6:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801094a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094ad:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094b4:	7e 88                	jle    8010943e <arp_scan+0x13>
  }
}
801094b6:	90                   	nop
801094b7:	90                   	nop
801094b8:	c9                   	leave
801094b9:	c3                   	ret

801094ba <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801094ba:	f3 0f 1e fb          	endbr32
801094be:	55                   	push   %ebp
801094bf:	89 e5                	mov    %esp,%ebp
801094c1:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094c4:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094c8:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094cc:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094d0:	8b 45 10             	mov    0x10(%ebp),%eax
801094d3:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094d6:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801094dd:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801094e3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094ea:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801094f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801094f3:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801094f9:	8b 45 08             	mov    0x8(%ebp),%eax
801094fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801094ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109502:	83 c0 0e             	add    $0xe,%eax
80109505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010950f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109512:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109519:	83 ec 04             	sub    $0x4,%esp
8010951c:	6a 06                	push   $0x6
8010951e:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109521:	52                   	push   %edx
80109522:	50                   	push   %eax
80109523:	e8 c9 b8 ff ff       	call   80104df1 <memmove>
80109528:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010952b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952e:	83 c0 06             	add    $0x6,%eax
80109531:	83 ec 04             	sub    $0x4,%esp
80109534:	6a 06                	push   $0x6
80109536:	68 68 d0 18 80       	push   $0x8018d068
8010953b:	50                   	push   %eax
8010953c:	e8 b0 b8 ff ff       	call   80104df1 <memmove>
80109541:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109547:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010954c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010954f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109558:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010955c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010955f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109566:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010956c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956f:	8d 50 12             	lea    0x12(%eax),%edx
80109572:	83 ec 04             	sub    $0x4,%esp
80109575:	6a 06                	push   $0x6
80109577:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010957a:	50                   	push   %eax
8010957b:	52                   	push   %edx
8010957c:	e8 70 b8 ff ff       	call   80104df1 <memmove>
80109581:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109587:	8d 50 18             	lea    0x18(%eax),%edx
8010958a:	83 ec 04             	sub    $0x4,%esp
8010958d:	6a 04                	push   $0x4
8010958f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109592:	50                   	push   %eax
80109593:	52                   	push   %edx
80109594:	e8 58 b8 ff ff       	call   80104df1 <memmove>
80109599:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010959c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010959f:	83 c0 08             	add    $0x8,%eax
801095a2:	83 ec 04             	sub    $0x4,%esp
801095a5:	6a 06                	push   $0x6
801095a7:	68 68 d0 18 80       	push   $0x8018d068
801095ac:	50                   	push   %eax
801095ad:	e8 3f b8 ff ff       	call   80104df1 <memmove>
801095b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095b8:	83 c0 0e             	add    $0xe,%eax
801095bb:	83 ec 04             	sub    $0x4,%esp
801095be:	6a 04                	push   $0x4
801095c0:	68 e4 f4 10 80       	push   $0x8010f4e4
801095c5:	50                   	push   %eax
801095c6:	e8 26 b8 ff ff       	call   80104df1 <memmove>
801095cb:	83 c4 10             	add    $0x10,%esp
}
801095ce:	90                   	nop
801095cf:	c9                   	leave
801095d0:	c3                   	ret

801095d1 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095d1:	f3 0f 1e fb          	endbr32
801095d5:	55                   	push   %ebp
801095d6:	89 e5                	mov    %esp,%ebp
801095d8:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095db:	8b 45 08             	mov    0x8(%ebp),%eax
801095de:	83 c0 0e             	add    $0xe,%eax
801095e1:	83 ec 0c             	sub    $0xc,%esp
801095e4:	50                   	push   %eax
801095e5:	e8 bc 00 00 00       	call   801096a6 <arp_table_search>
801095ea:	83 c4 10             	add    $0x10,%esp
801095ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801095f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801095f4:	78 2d                	js     80109623 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801095f6:	8b 45 08             	mov    0x8(%ebp),%eax
801095f9:	8d 48 08             	lea    0x8(%eax),%ecx
801095fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095ff:	89 d0                	mov    %edx,%eax
80109601:	c1 e0 02             	shl    $0x2,%eax
80109604:	01 d0                	add    %edx,%eax
80109606:	01 c0                	add    %eax,%eax
80109608:	01 d0                	add    %edx,%eax
8010960a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010960f:	83 c0 04             	add    $0x4,%eax
80109612:	83 ec 04             	sub    $0x4,%esp
80109615:	6a 06                	push   $0x6
80109617:	51                   	push   %ecx
80109618:	50                   	push   %eax
80109619:	e8 d3 b7 ff ff       	call   80104df1 <memmove>
8010961e:	83 c4 10             	add    $0x10,%esp
80109621:	eb 70                	jmp    80109693 <arp_table_update+0xc2>
  }else{
    index += 1;
80109623:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109627:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010962a:	8b 45 08             	mov    0x8(%ebp),%eax
8010962d:	8d 48 08             	lea    0x8(%eax),%ecx
80109630:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109633:	89 d0                	mov    %edx,%eax
80109635:	c1 e0 02             	shl    $0x2,%eax
80109638:	01 d0                	add    %edx,%eax
8010963a:	01 c0                	add    %eax,%eax
8010963c:	01 d0                	add    %edx,%eax
8010963e:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109643:	83 c0 04             	add    $0x4,%eax
80109646:	83 ec 04             	sub    $0x4,%esp
80109649:	6a 06                	push   $0x6
8010964b:	51                   	push   %ecx
8010964c:	50                   	push   %eax
8010964d:	e8 9f b7 ff ff       	call   80104df1 <memmove>
80109652:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109655:	8b 45 08             	mov    0x8(%ebp),%eax
80109658:	8d 48 0e             	lea    0xe(%eax),%ecx
8010965b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010965e:	89 d0                	mov    %edx,%eax
80109660:	c1 e0 02             	shl    $0x2,%eax
80109663:	01 d0                	add    %edx,%eax
80109665:	01 c0                	add    %eax,%eax
80109667:	01 d0                	add    %edx,%eax
80109669:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010966e:	83 ec 04             	sub    $0x4,%esp
80109671:	6a 04                	push   $0x4
80109673:	51                   	push   %ecx
80109674:	50                   	push   %eax
80109675:	e8 77 b7 ff ff       	call   80104df1 <memmove>
8010967a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010967d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109680:	89 d0                	mov    %edx,%eax
80109682:	c1 e0 02             	shl    $0x2,%eax
80109685:	01 d0                	add    %edx,%eax
80109687:	01 c0                	add    %eax,%eax
80109689:	01 d0                	add    %edx,%eax
8010968b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109690:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109693:	83 ec 0c             	sub    $0xc,%esp
80109696:	68 80 d0 18 80       	push   $0x8018d080
8010969b:	e8 87 00 00 00       	call   80109727 <print_arp_table>
801096a0:	83 c4 10             	add    $0x10,%esp
}
801096a3:	90                   	nop
801096a4:	c9                   	leave
801096a5:	c3                   	ret

801096a6 <arp_table_search>:

int arp_table_search(uchar *ip){
801096a6:	f3 0f 1e fb          	endbr32
801096aa:	55                   	push   %ebp
801096ab:	89 e5                	mov    %esp,%ebp
801096ad:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801096b0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096be:	eb 59                	jmp    80109719 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801096c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096c3:	89 d0                	mov    %edx,%eax
801096c5:	c1 e0 02             	shl    $0x2,%eax
801096c8:	01 d0                	add    %edx,%eax
801096ca:	01 c0                	add    %eax,%eax
801096cc:	01 d0                	add    %edx,%eax
801096ce:	05 80 d0 18 80       	add    $0x8018d080,%eax
801096d3:	83 ec 04             	sub    $0x4,%esp
801096d6:	6a 04                	push   $0x4
801096d8:	ff 75 08             	push   0x8(%ebp)
801096db:	50                   	push   %eax
801096dc:	e8 b4 b6 ff ff       	call   80104d95 <memcmp>
801096e1:	83 c4 10             	add    $0x10,%esp
801096e4:	85 c0                	test   %eax,%eax
801096e6:	75 05                	jne    801096ed <arp_table_search+0x47>
      return i;
801096e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096eb:	eb 38                	jmp    80109725 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801096ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096f0:	89 d0                	mov    %edx,%eax
801096f2:	c1 e0 02             	shl    $0x2,%eax
801096f5:	01 d0                	add    %edx,%eax
801096f7:	01 c0                	add    %eax,%eax
801096f9:	01 d0                	add    %edx,%eax
801096fb:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109700:	0f b6 00             	movzbl (%eax),%eax
80109703:	84 c0                	test   %al,%al
80109705:	75 0e                	jne    80109715 <arp_table_search+0x6f>
80109707:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010970b:	75 08                	jne    80109715 <arp_table_search+0x6f>
      empty = -i;
8010970d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109710:	f7 d8                	neg    %eax
80109712:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109715:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109719:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010971d:	7e a1                	jle    801096c0 <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010971f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109722:	83 e8 01             	sub    $0x1,%eax
}
80109725:	c9                   	leave
80109726:	c3                   	ret

80109727 <print_arp_table>:

void print_arp_table(){
80109727:	f3 0f 1e fb          	endbr32
8010972b:	55                   	push   %ebp
8010972c:	89 e5                	mov    %esp,%ebp
8010972e:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109738:	e9 92 00 00 00       	jmp    801097cf <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010973d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109740:	89 d0                	mov    %edx,%eax
80109742:	c1 e0 02             	shl    $0x2,%eax
80109745:	01 d0                	add    %edx,%eax
80109747:	01 c0                	add    %eax,%eax
80109749:	01 d0                	add    %edx,%eax
8010974b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109750:	0f b6 00             	movzbl (%eax),%eax
80109753:	84 c0                	test   %al,%al
80109755:	74 74                	je     801097cb <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109757:	83 ec 08             	sub    $0x8,%esp
8010975a:	ff 75 f4             	push   -0xc(%ebp)
8010975d:	68 8f c7 10 80       	push   $0x8010c78f
80109762:	e8 a5 6c ff ff       	call   8010040c <cprintf>
80109767:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010976a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010976d:	89 d0                	mov    %edx,%eax
8010976f:	c1 e0 02             	shl    $0x2,%eax
80109772:	01 d0                	add    %edx,%eax
80109774:	01 c0                	add    %eax,%eax
80109776:	01 d0                	add    %edx,%eax
80109778:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010977d:	83 ec 0c             	sub    $0xc,%esp
80109780:	50                   	push   %eax
80109781:	e8 5c 02 00 00       	call   801099e2 <print_ipv4>
80109786:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109789:	83 ec 0c             	sub    $0xc,%esp
8010978c:	68 9e c7 10 80       	push   $0x8010c79e
80109791:	e8 76 6c ff ff       	call   8010040c <cprintf>
80109796:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109799:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010979c:	89 d0                	mov    %edx,%eax
8010979e:	c1 e0 02             	shl    $0x2,%eax
801097a1:	01 d0                	add    %edx,%eax
801097a3:	01 c0                	add    %eax,%eax
801097a5:	01 d0                	add    %edx,%eax
801097a7:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097ac:	83 c0 04             	add    $0x4,%eax
801097af:	83 ec 0c             	sub    $0xc,%esp
801097b2:	50                   	push   %eax
801097b3:	e8 7c 02 00 00       	call   80109a34 <print_mac>
801097b8:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801097bb:	83 ec 0c             	sub    $0xc,%esp
801097be:	68 a0 c7 10 80       	push   $0x8010c7a0
801097c3:	e8 44 6c ff ff       	call   8010040c <cprintf>
801097c8:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097cf:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097d3:	0f 8e 64 ff ff ff    	jle    8010973d <print_arp_table+0x16>
    }
  }
}
801097d9:	90                   	nop
801097da:	90                   	nop
801097db:	c9                   	leave
801097dc:	c3                   	ret

801097dd <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097dd:	f3 0f 1e fb          	endbr32
801097e1:	55                   	push   %ebp
801097e2:	89 e5                	mov    %esp,%ebp
801097e4:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097e7:	8b 45 10             	mov    0x10(%ebp),%eax
801097ea:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801097f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801097f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801097f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801097f9:	83 c0 0e             	add    $0xe,%eax
801097fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801097ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109802:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109809:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010980d:	8b 45 08             	mov    0x8(%ebp),%eax
80109810:	8d 50 08             	lea    0x8(%eax),%edx
80109813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109816:	83 ec 04             	sub    $0x4,%esp
80109819:	6a 06                	push   $0x6
8010981b:	52                   	push   %edx
8010981c:	50                   	push   %eax
8010981d:	e8 cf b5 ff ff       	call   80104df1 <memmove>
80109822:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109828:	83 c0 06             	add    $0x6,%eax
8010982b:	83 ec 04             	sub    $0x4,%esp
8010982e:	6a 06                	push   $0x6
80109830:	68 68 d0 18 80       	push   $0x8018d068
80109835:	50                   	push   %eax
80109836:	e8 b6 b5 ff ff       	call   80104df1 <memmove>
8010983b:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010983e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109841:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109849:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010984f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109852:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109859:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010985d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109860:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109866:	8b 45 08             	mov    0x8(%ebp),%eax
80109869:	8d 50 08             	lea    0x8(%eax),%edx
8010986c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010986f:	83 c0 12             	add    $0x12,%eax
80109872:	83 ec 04             	sub    $0x4,%esp
80109875:	6a 06                	push   $0x6
80109877:	52                   	push   %edx
80109878:	50                   	push   %eax
80109879:	e8 73 b5 ff ff       	call   80104df1 <memmove>
8010987e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109881:	8b 45 08             	mov    0x8(%ebp),%eax
80109884:	8d 50 0e             	lea    0xe(%eax),%edx
80109887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010988a:	83 c0 18             	add    $0x18,%eax
8010988d:	83 ec 04             	sub    $0x4,%esp
80109890:	6a 04                	push   $0x4
80109892:	52                   	push   %edx
80109893:	50                   	push   %eax
80109894:	e8 58 b5 ff ff       	call   80104df1 <memmove>
80109899:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010989c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989f:	83 c0 08             	add    $0x8,%eax
801098a2:	83 ec 04             	sub    $0x4,%esp
801098a5:	6a 06                	push   $0x6
801098a7:	68 68 d0 18 80       	push   $0x8018d068
801098ac:	50                   	push   %eax
801098ad:	e8 3f b5 ff ff       	call   80104df1 <memmove>
801098b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b8:	83 c0 0e             	add    $0xe,%eax
801098bb:	83 ec 04             	sub    $0x4,%esp
801098be:	6a 04                	push   $0x4
801098c0:	68 e4 f4 10 80       	push   $0x8010f4e4
801098c5:	50                   	push   %eax
801098c6:	e8 26 b5 ff ff       	call   80104df1 <memmove>
801098cb:	83 c4 10             	add    $0x10,%esp
}
801098ce:	90                   	nop
801098cf:	c9                   	leave
801098d0:	c3                   	ret

801098d1 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801098d1:	f3 0f 1e fb          	endbr32
801098d5:	55                   	push   %ebp
801098d6:	89 e5                	mov    %esp,%ebp
801098d8:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098db:	83 ec 0c             	sub    $0xc,%esp
801098de:	68 a2 c7 10 80       	push   $0x8010c7a2
801098e3:	e8 24 6b ff ff       	call   8010040c <cprintf>
801098e8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098eb:	8b 45 08             	mov    0x8(%ebp),%eax
801098ee:	83 c0 0e             	add    $0xe,%eax
801098f1:	83 ec 0c             	sub    $0xc,%esp
801098f4:	50                   	push   %eax
801098f5:	e8 e8 00 00 00       	call   801099e2 <print_ipv4>
801098fa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098fd:	83 ec 0c             	sub    $0xc,%esp
80109900:	68 a0 c7 10 80       	push   $0x8010c7a0
80109905:	e8 02 6b ff ff       	call   8010040c <cprintf>
8010990a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010990d:	8b 45 08             	mov    0x8(%ebp),%eax
80109910:	83 c0 08             	add    $0x8,%eax
80109913:	83 ec 0c             	sub    $0xc,%esp
80109916:	50                   	push   %eax
80109917:	e8 18 01 00 00       	call   80109a34 <print_mac>
8010991c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010991f:	83 ec 0c             	sub    $0xc,%esp
80109922:	68 a0 c7 10 80       	push   $0x8010c7a0
80109927:	e8 e0 6a ff ff       	call   8010040c <cprintf>
8010992c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010992f:	83 ec 0c             	sub    $0xc,%esp
80109932:	68 b9 c7 10 80       	push   $0x8010c7b9
80109937:	e8 d0 6a ff ff       	call   8010040c <cprintf>
8010993c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010993f:	8b 45 08             	mov    0x8(%ebp),%eax
80109942:	83 c0 18             	add    $0x18,%eax
80109945:	83 ec 0c             	sub    $0xc,%esp
80109948:	50                   	push   %eax
80109949:	e8 94 00 00 00       	call   801099e2 <print_ipv4>
8010994e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109951:	83 ec 0c             	sub    $0xc,%esp
80109954:	68 a0 c7 10 80       	push   $0x8010c7a0
80109959:	e8 ae 6a ff ff       	call   8010040c <cprintf>
8010995e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109961:	8b 45 08             	mov    0x8(%ebp),%eax
80109964:	83 c0 12             	add    $0x12,%eax
80109967:	83 ec 0c             	sub    $0xc,%esp
8010996a:	50                   	push   %eax
8010996b:	e8 c4 00 00 00       	call   80109a34 <print_mac>
80109970:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109973:	83 ec 0c             	sub    $0xc,%esp
80109976:	68 a0 c7 10 80       	push   $0x8010c7a0
8010997b:	e8 8c 6a ff ff       	call   8010040c <cprintf>
80109980:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109983:	83 ec 0c             	sub    $0xc,%esp
80109986:	68 d0 c7 10 80       	push   $0x8010c7d0
8010998b:	e8 7c 6a ff ff       	call   8010040c <cprintf>
80109990:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109993:	8b 45 08             	mov    0x8(%ebp),%eax
80109996:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010999a:	66 3d 00 01          	cmp    $0x100,%ax
8010999e:	75 12                	jne    801099b2 <print_arp_info+0xe1>
801099a0:	83 ec 0c             	sub    $0xc,%esp
801099a3:	68 dc c7 10 80       	push   $0x8010c7dc
801099a8:	e8 5f 6a ff ff       	call   8010040c <cprintf>
801099ad:	83 c4 10             	add    $0x10,%esp
801099b0:	eb 1d                	jmp    801099cf <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801099b2:	8b 45 08             	mov    0x8(%ebp),%eax
801099b5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099b9:	66 3d 00 02          	cmp    $0x200,%ax
801099bd:	75 10                	jne    801099cf <print_arp_info+0xfe>
    cprintf("Reply\n");
801099bf:	83 ec 0c             	sub    $0xc,%esp
801099c2:	68 e5 c7 10 80       	push   $0x8010c7e5
801099c7:	e8 40 6a ff ff       	call   8010040c <cprintf>
801099cc:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801099cf:	83 ec 0c             	sub    $0xc,%esp
801099d2:	68 a0 c7 10 80       	push   $0x8010c7a0
801099d7:	e8 30 6a ff ff       	call   8010040c <cprintf>
801099dc:	83 c4 10             	add    $0x10,%esp
}
801099df:	90                   	nop
801099e0:	c9                   	leave
801099e1:	c3                   	ret

801099e2 <print_ipv4>:

void print_ipv4(uchar *ip){
801099e2:	f3 0f 1e fb          	endbr32
801099e6:	55                   	push   %ebp
801099e7:	89 e5                	mov    %esp,%ebp
801099e9:	53                   	push   %ebx
801099ea:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099ed:	8b 45 08             	mov    0x8(%ebp),%eax
801099f0:	83 c0 03             	add    $0x3,%eax
801099f3:	0f b6 00             	movzbl (%eax),%eax
801099f6:	0f b6 d8             	movzbl %al,%ebx
801099f9:	8b 45 08             	mov    0x8(%ebp),%eax
801099fc:	83 c0 02             	add    $0x2,%eax
801099ff:	0f b6 00             	movzbl (%eax),%eax
80109a02:	0f b6 c8             	movzbl %al,%ecx
80109a05:	8b 45 08             	mov    0x8(%ebp),%eax
80109a08:	83 c0 01             	add    $0x1,%eax
80109a0b:	0f b6 00             	movzbl (%eax),%eax
80109a0e:	0f b6 d0             	movzbl %al,%edx
80109a11:	8b 45 08             	mov    0x8(%ebp),%eax
80109a14:	0f b6 00             	movzbl (%eax),%eax
80109a17:	0f b6 c0             	movzbl %al,%eax
80109a1a:	83 ec 0c             	sub    $0xc,%esp
80109a1d:	53                   	push   %ebx
80109a1e:	51                   	push   %ecx
80109a1f:	52                   	push   %edx
80109a20:	50                   	push   %eax
80109a21:	68 ec c7 10 80       	push   $0x8010c7ec
80109a26:	e8 e1 69 ff ff       	call   8010040c <cprintf>
80109a2b:	83 c4 20             	add    $0x20,%esp
}
80109a2e:	90                   	nop
80109a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a32:	c9                   	leave
80109a33:	c3                   	ret

80109a34 <print_mac>:

void print_mac(uchar *mac){
80109a34:	f3 0f 1e fb          	endbr32
80109a38:	55                   	push   %ebp
80109a39:	89 e5                	mov    %esp,%ebp
80109a3b:	57                   	push   %edi
80109a3c:	56                   	push   %esi
80109a3d:	53                   	push   %ebx
80109a3e:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a41:	8b 45 08             	mov    0x8(%ebp),%eax
80109a44:	83 c0 05             	add    $0x5,%eax
80109a47:	0f b6 00             	movzbl (%eax),%eax
80109a4a:	0f b6 f8             	movzbl %al,%edi
80109a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a50:	83 c0 04             	add    $0x4,%eax
80109a53:	0f b6 00             	movzbl (%eax),%eax
80109a56:	0f b6 f0             	movzbl %al,%esi
80109a59:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5c:	83 c0 03             	add    $0x3,%eax
80109a5f:	0f b6 00             	movzbl (%eax),%eax
80109a62:	0f b6 d8             	movzbl %al,%ebx
80109a65:	8b 45 08             	mov    0x8(%ebp),%eax
80109a68:	83 c0 02             	add    $0x2,%eax
80109a6b:	0f b6 00             	movzbl (%eax),%eax
80109a6e:	0f b6 c8             	movzbl %al,%ecx
80109a71:	8b 45 08             	mov    0x8(%ebp),%eax
80109a74:	83 c0 01             	add    $0x1,%eax
80109a77:	0f b6 00             	movzbl (%eax),%eax
80109a7a:	0f b6 d0             	movzbl %al,%edx
80109a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a80:	0f b6 00             	movzbl (%eax),%eax
80109a83:	0f b6 c0             	movzbl %al,%eax
80109a86:	83 ec 04             	sub    $0x4,%esp
80109a89:	57                   	push   %edi
80109a8a:	56                   	push   %esi
80109a8b:	53                   	push   %ebx
80109a8c:	51                   	push   %ecx
80109a8d:	52                   	push   %edx
80109a8e:	50                   	push   %eax
80109a8f:	68 04 c8 10 80       	push   $0x8010c804
80109a94:	e8 73 69 ff ff       	call   8010040c <cprintf>
80109a99:	83 c4 20             	add    $0x20,%esp
}
80109a9c:	90                   	nop
80109a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109aa0:	5b                   	pop    %ebx
80109aa1:	5e                   	pop    %esi
80109aa2:	5f                   	pop    %edi
80109aa3:	5d                   	pop    %ebp
80109aa4:	c3                   	ret

80109aa5 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109aa5:	f3 0f 1e fb          	endbr32
80109aa9:	55                   	push   %ebp
80109aaa:	89 e5                	mov    %esp,%ebp
80109aac:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab8:	83 c0 0e             	add    $0xe,%eax
80109abb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ac5:	3c 08                	cmp    $0x8,%al
80109ac7:	75 1b                	jne    80109ae4 <eth_proc+0x3f>
80109ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ad0:	3c 06                	cmp    $0x6,%al
80109ad2:	75 10                	jne    80109ae4 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109ad4:	83 ec 0c             	sub    $0xc,%esp
80109ad7:	ff 75 f0             	push   -0x10(%ebp)
80109ada:	e8 d5 f7 ff ff       	call   801092b4 <arp_proc>
80109adf:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109ae2:	eb 24                	jmp    80109b08 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109aeb:	3c 08                	cmp    $0x8,%al
80109aed:	75 19                	jne    80109b08 <eth_proc+0x63>
80109aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109af6:	84 c0                	test   %al,%al
80109af8:	75 0e                	jne    80109b08 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109afa:	83 ec 0c             	sub    $0xc,%esp
80109afd:	ff 75 08             	push   0x8(%ebp)
80109b00:	e8 b3 00 00 00       	call   80109bb8 <ipv4_proc>
80109b05:	83 c4 10             	add    $0x10,%esp
}
80109b08:	90                   	nop
80109b09:	c9                   	leave
80109b0a:	c3                   	ret

80109b0b <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b0b:	f3 0f 1e fb          	endbr32
80109b0f:	55                   	push   %ebp
80109b10:	89 e5                	mov    %esp,%ebp
80109b12:	83 ec 04             	sub    $0x4,%esp
80109b15:	8b 45 08             	mov    0x8(%ebp),%eax
80109b18:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b1c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b20:	c1 e0 08             	shl    $0x8,%eax
80109b23:	89 c2                	mov    %eax,%edx
80109b25:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b29:	66 c1 e8 08          	shr    $0x8,%ax
80109b2d:	01 d0                	add    %edx,%eax
}
80109b2f:	c9                   	leave
80109b30:	c3                   	ret

80109b31 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b31:	f3 0f 1e fb          	endbr32
80109b35:	55                   	push   %ebp
80109b36:	89 e5                	mov    %esp,%ebp
80109b38:	83 ec 04             	sub    $0x4,%esp
80109b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b3e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b42:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b46:	c1 e0 08             	shl    $0x8,%eax
80109b49:	89 c2                	mov    %eax,%edx
80109b4b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b4f:	66 c1 e8 08          	shr    $0x8,%ax
80109b53:	01 d0                	add    %edx,%eax
}
80109b55:	c9                   	leave
80109b56:	c3                   	ret

80109b57 <H2N_uint>:

uint H2N_uint(uint value){
80109b57:	f3 0f 1e fb          	endbr32
80109b5b:	55                   	push   %ebp
80109b5c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b61:	c1 e0 18             	shl    $0x18,%eax
80109b64:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b69:	89 c2                	mov    %eax,%edx
80109b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6e:	c1 e0 08             	shl    $0x8,%eax
80109b71:	25 00 f0 00 00       	and    $0xf000,%eax
80109b76:	09 c2                	or     %eax,%edx
80109b78:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7b:	c1 e8 08             	shr    $0x8,%eax
80109b7e:	83 e0 0f             	and    $0xf,%eax
80109b81:	01 d0                	add    %edx,%eax
}
80109b83:	5d                   	pop    %ebp
80109b84:	c3                   	ret

80109b85 <N2H_uint>:

uint N2H_uint(uint value){
80109b85:	f3 0f 1e fb          	endbr32
80109b89:	55                   	push   %ebp
80109b8a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b8f:	c1 e0 18             	shl    $0x18,%eax
80109b92:	89 c2                	mov    %eax,%edx
80109b94:	8b 45 08             	mov    0x8(%ebp),%eax
80109b97:	c1 e0 08             	shl    $0x8,%eax
80109b9a:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b9f:	01 c2                	add    %eax,%edx
80109ba1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba4:	c1 e8 08             	shr    $0x8,%eax
80109ba7:	25 00 ff 00 00       	and    $0xff00,%eax
80109bac:	01 c2                	add    %eax,%edx
80109bae:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb1:	c1 e8 18             	shr    $0x18,%eax
80109bb4:	01 d0                	add    %edx,%eax
}
80109bb6:	5d                   	pop    %ebp
80109bb7:	c3                   	ret

80109bb8 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109bb8:	f3 0f 1e fb          	endbr32
80109bbc:	55                   	push   %ebp
80109bbd:	89 e5                	mov    %esp,%ebp
80109bbf:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc5:	83 c0 0e             	add    $0xe,%eax
80109bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bce:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bd2:	0f b7 d0             	movzwl %ax,%edx
80109bd5:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109bda:	39 c2                	cmp    %eax,%edx
80109bdc:	74 60                	je     80109c3e <ipv4_proc+0x86>
80109bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be1:	83 c0 0c             	add    $0xc,%eax
80109be4:	83 ec 04             	sub    $0x4,%esp
80109be7:	6a 04                	push   $0x4
80109be9:	50                   	push   %eax
80109bea:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bef:	e8 a1 b1 ff ff       	call   80104d95 <memcmp>
80109bf4:	83 c4 10             	add    $0x10,%esp
80109bf7:	85 c0                	test   %eax,%eax
80109bf9:	74 43                	je     80109c3e <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bfe:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c02:	0f b7 c0             	movzwl %ax,%eax
80109c05:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c11:	3c 01                	cmp    $0x1,%al
80109c13:	75 10                	jne    80109c25 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109c15:	83 ec 0c             	sub    $0xc,%esp
80109c18:	ff 75 08             	push   0x8(%ebp)
80109c1b:	e8 a7 00 00 00       	call   80109cc7 <icmp_proc>
80109c20:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c23:	eb 19                	jmp    80109c3e <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c28:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c2c:	3c 06                	cmp    $0x6,%al
80109c2e:	75 0e                	jne    80109c3e <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109c30:	83 ec 0c             	sub    $0xc,%esp
80109c33:	ff 75 08             	push   0x8(%ebp)
80109c36:	e8 c7 03 00 00       	call   8010a002 <tcp_proc>
80109c3b:	83 c4 10             	add    $0x10,%esp
}
80109c3e:	90                   	nop
80109c3f:	c9                   	leave
80109c40:	c3                   	ret

80109c41 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c41:	f3 0f 1e fb          	endbr32
80109c45:	55                   	push   %ebp
80109c46:	89 e5                	mov    %esp,%ebp
80109c48:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c54:	0f b6 00             	movzbl (%eax),%eax
80109c57:	83 e0 0f             	and    $0xf,%eax
80109c5a:	01 c0                	add    %eax,%eax
80109c5c:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c5f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c66:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c6d:	eb 48                	jmp    80109cb7 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c72:	01 c0                	add    %eax,%eax
80109c74:	89 c2                	mov    %eax,%edx
80109c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c79:	01 d0                	add    %edx,%eax
80109c7b:	0f b6 00             	movzbl (%eax),%eax
80109c7e:	0f b6 c0             	movzbl %al,%eax
80109c81:	c1 e0 08             	shl    $0x8,%eax
80109c84:	89 c2                	mov    %eax,%edx
80109c86:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c89:	01 c0                	add    %eax,%eax
80109c8b:	8d 48 01             	lea    0x1(%eax),%ecx
80109c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c91:	01 c8                	add    %ecx,%eax
80109c93:	0f b6 00             	movzbl (%eax),%eax
80109c96:	0f b6 c0             	movzbl %al,%eax
80109c99:	01 d0                	add    %edx,%eax
80109c9b:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c9e:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ca5:	76 0c                	jbe    80109cb3 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109caa:	0f b7 c0             	movzwl %ax,%eax
80109cad:	83 c0 01             	add    $0x1,%eax
80109cb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cb3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109cb7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109cbb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109cbe:	7c af                	jl     80109c6f <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109cc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cc3:	f7 d0                	not    %eax
}
80109cc5:	c9                   	leave
80109cc6:	c3                   	ret

80109cc7 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109cc7:	f3 0f 1e fb          	endbr32
80109ccb:	55                   	push   %ebp
80109ccc:	89 e5                	mov    %esp,%ebp
80109cce:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd4:	83 c0 0e             	add    $0xe,%eax
80109cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cdd:	0f b6 00             	movzbl (%eax),%eax
80109ce0:	0f b6 c0             	movzbl %al,%eax
80109ce3:	83 e0 0f             	and    $0xf,%eax
80109ce6:	c1 e0 02             	shl    $0x2,%eax
80109ce9:	89 c2                	mov    %eax,%edx
80109ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cee:	01 d0                	add    %edx,%eax
80109cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109cfa:	84 c0                	test   %al,%al
80109cfc:	75 4f                	jne    80109d4d <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d01:	0f b6 00             	movzbl (%eax),%eax
80109d04:	3c 08                	cmp    $0x8,%al
80109d06:	75 45                	jne    80109d4d <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109d08:	e8 e3 8b ff ff       	call   801028f0 <kalloc>
80109d0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d10:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d17:	83 ec 04             	sub    $0x4,%esp
80109d1a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d1d:	50                   	push   %eax
80109d1e:	ff 75 ec             	push   -0x14(%ebp)
80109d21:	ff 75 08             	push   0x8(%ebp)
80109d24:	e8 7c 00 00 00       	call   80109da5 <icmp_reply_pkt_create>
80109d29:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d2f:	83 ec 08             	sub    $0x8,%esp
80109d32:	50                   	push   %eax
80109d33:	ff 75 ec             	push   -0x14(%ebp)
80109d36:	e8 43 f4 ff ff       	call   8010917e <i8254_send>
80109d3b:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d41:	83 ec 0c             	sub    $0xc,%esp
80109d44:	50                   	push   %eax
80109d45:	e8 08 8b ff ff       	call   80102852 <kfree>
80109d4a:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d4d:	90                   	nop
80109d4e:	c9                   	leave
80109d4f:	c3                   	ret

80109d50 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d50:	f3 0f 1e fb          	endbr32
80109d54:	55                   	push   %ebp
80109d55:	89 e5                	mov    %esp,%ebp
80109d57:	53                   	push   %ebx
80109d58:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d62:	0f b7 c0             	movzwl %ax,%eax
80109d65:	83 ec 0c             	sub    $0xc,%esp
80109d68:	50                   	push   %eax
80109d69:	e8 9d fd ff ff       	call   80109b0b <N2H_ushort>
80109d6e:	83 c4 10             	add    $0x10,%esp
80109d71:	0f b7 d8             	movzwl %ax,%ebx
80109d74:	8b 45 08             	mov    0x8(%ebp),%eax
80109d77:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d7b:	0f b7 c0             	movzwl %ax,%eax
80109d7e:	83 ec 0c             	sub    $0xc,%esp
80109d81:	50                   	push   %eax
80109d82:	e8 84 fd ff ff       	call   80109b0b <N2H_ushort>
80109d87:	83 c4 10             	add    $0x10,%esp
80109d8a:	0f b7 c0             	movzwl %ax,%eax
80109d8d:	83 ec 04             	sub    $0x4,%esp
80109d90:	53                   	push   %ebx
80109d91:	50                   	push   %eax
80109d92:	68 23 c8 10 80       	push   $0x8010c823
80109d97:	e8 70 66 ff ff       	call   8010040c <cprintf>
80109d9c:	83 c4 10             	add    $0x10,%esp
}
80109d9f:	90                   	nop
80109da0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109da3:	c9                   	leave
80109da4:	c3                   	ret

80109da5 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109da5:	f3 0f 1e fb          	endbr32
80109da9:	55                   	push   %ebp
80109daa:	89 e5                	mov    %esp,%ebp
80109dac:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109daf:	8b 45 08             	mov    0x8(%ebp),%eax
80109db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109db5:	8b 45 08             	mov    0x8(%ebp),%eax
80109db8:	83 c0 0e             	add    $0xe,%eax
80109dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc1:	0f b6 00             	movzbl (%eax),%eax
80109dc4:	0f b6 c0             	movzbl %al,%eax
80109dc7:	83 e0 0f             	and    $0xf,%eax
80109dca:	c1 e0 02             	shl    $0x2,%eax
80109dcd:	89 c2                	mov    %eax,%edx
80109dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd2:	01 d0                	add    %edx,%eax
80109dd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dda:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109de0:	83 c0 0e             	add    $0xe,%eax
80109de3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109de9:	83 c0 14             	add    $0x14,%eax
80109dec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109def:	8b 45 10             	mov    0x10(%ebp),%eax
80109df2:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dfb:	8d 50 06             	lea    0x6(%eax),%edx
80109dfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e01:	83 ec 04             	sub    $0x4,%esp
80109e04:	6a 06                	push   $0x6
80109e06:	52                   	push   %edx
80109e07:	50                   	push   %eax
80109e08:	e8 e4 af ff ff       	call   80104df1 <memmove>
80109e0d:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e13:	83 c0 06             	add    $0x6,%eax
80109e16:	83 ec 04             	sub    $0x4,%esp
80109e19:	6a 06                	push   $0x6
80109e1b:	68 68 d0 18 80       	push   $0x8018d068
80109e20:	50                   	push   %eax
80109e21:	e8 cb af ff ff       	call   80104df1 <memmove>
80109e26:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e2c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e33:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e3a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e40:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e44:	83 ec 0c             	sub    $0xc,%esp
80109e47:	6a 54                	push   $0x54
80109e49:	e8 e3 fc ff ff       	call   80109b31 <H2N_ushort>
80109e4e:	83 c4 10             	add    $0x10,%esp
80109e51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e54:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e58:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e62:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e66:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109e6d:	83 c0 01             	add    $0x1,%eax
80109e70:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e76:	83 ec 0c             	sub    $0xc,%esp
80109e79:	68 00 40 00 00       	push   $0x4000
80109e7e:	e8 ae fc ff ff       	call   80109b31 <H2N_ushort>
80109e83:	83 c4 10             	add    $0x10,%esp
80109e86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e89:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e90:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e97:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e9e:	83 c0 0c             	add    $0xc,%eax
80109ea1:	83 ec 04             	sub    $0x4,%esp
80109ea4:	6a 04                	push   $0x4
80109ea6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109eab:	50                   	push   %eax
80109eac:	e8 40 af ff ff       	call   80104df1 <memmove>
80109eb1:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eb7:	8d 50 0c             	lea    0xc(%eax),%edx
80109eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ebd:	83 c0 10             	add    $0x10,%eax
80109ec0:	83 ec 04             	sub    $0x4,%esp
80109ec3:	6a 04                	push   $0x4
80109ec5:	52                   	push   %edx
80109ec6:	50                   	push   %eax
80109ec7:	e8 25 af ff ff       	call   80104df1 <memmove>
80109ecc:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109edb:	83 ec 0c             	sub    $0xc,%esp
80109ede:	50                   	push   %eax
80109edf:	e8 5d fd ff ff       	call   80109c41 <ipv4_chksum>
80109ee4:	83 c4 10             	add    $0x10,%esp
80109ee7:	0f b7 c0             	movzwl %ax,%eax
80109eea:	83 ec 0c             	sub    $0xc,%esp
80109eed:	50                   	push   %eax
80109eee:	e8 3e fc ff ff       	call   80109b31 <H2N_ushort>
80109ef3:	83 c4 10             	add    $0x10,%esp
80109ef6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ef9:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f00:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f06:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f0d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f14:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f1b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f22:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f29:	8d 50 08             	lea    0x8(%eax),%edx
80109f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f2f:	83 c0 08             	add    $0x8,%eax
80109f32:	83 ec 04             	sub    $0x4,%esp
80109f35:	6a 08                	push   $0x8
80109f37:	52                   	push   %edx
80109f38:	50                   	push   %eax
80109f39:	e8 b3 ae ff ff       	call   80104df1 <memmove>
80109f3e:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f44:	8d 50 10             	lea    0x10(%eax),%edx
80109f47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f4a:	83 c0 10             	add    $0x10,%eax
80109f4d:	83 ec 04             	sub    $0x4,%esp
80109f50:	6a 30                	push   $0x30
80109f52:	52                   	push   %edx
80109f53:	50                   	push   %eax
80109f54:	e8 98 ae ff ff       	call   80104df1 <memmove>
80109f59:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f5f:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f68:	83 ec 0c             	sub    $0xc,%esp
80109f6b:	50                   	push   %eax
80109f6c:	e8 1c 00 00 00       	call   80109f8d <icmp_chksum>
80109f71:	83 c4 10             	add    $0x10,%esp
80109f74:	0f b7 c0             	movzwl %ax,%eax
80109f77:	83 ec 0c             	sub    $0xc,%esp
80109f7a:	50                   	push   %eax
80109f7b:	e8 b1 fb ff ff       	call   80109b31 <H2N_ushort>
80109f80:	83 c4 10             	add    $0x10,%esp
80109f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f86:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f8a:	90                   	nop
80109f8b:	c9                   	leave
80109f8c:	c3                   	ret

80109f8d <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f8d:	f3 0f 1e fb          	endbr32
80109f91:	55                   	push   %ebp
80109f92:	89 e5                	mov    %esp,%ebp
80109f94:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109f97:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109f9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fa4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fab:	eb 48                	jmp    80109ff5 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fad:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fb0:	01 c0                	add    %eax,%eax
80109fb2:	89 c2                	mov    %eax,%edx
80109fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb7:	01 d0                	add    %edx,%eax
80109fb9:	0f b6 00             	movzbl (%eax),%eax
80109fbc:	0f b6 c0             	movzbl %al,%eax
80109fbf:	c1 e0 08             	shl    $0x8,%eax
80109fc2:	89 c2                	mov    %eax,%edx
80109fc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fc7:	01 c0                	add    %eax,%eax
80109fc9:	8d 48 01             	lea    0x1(%eax),%ecx
80109fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fcf:	01 c8                	add    %ecx,%eax
80109fd1:	0f b6 00             	movzbl (%eax),%eax
80109fd4:	0f b6 c0             	movzbl %al,%eax
80109fd7:	01 d0                	add    %edx,%eax
80109fd9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109fdc:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109fe3:	76 0c                	jbe    80109ff1 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fe8:	0f b7 c0             	movzwl %ax,%eax
80109feb:	83 c0 01             	add    $0x1,%eax
80109fee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ff1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ff5:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ff9:	7e b2                	jle    80109fad <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ffe:	f7 d0                	not    %eax
}
8010a000:	c9                   	leave
8010a001:	c3                   	ret

8010a002 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a002:	f3 0f 1e fb          	endbr32
8010a006:	55                   	push   %ebp
8010a007:	89 e5                	mov    %esp,%ebp
8010a009:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a00c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00f:	83 c0 0e             	add    $0xe,%eax
8010a012:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a015:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a018:	0f b6 00             	movzbl (%eax),%eax
8010a01b:	0f b6 c0             	movzbl %al,%eax
8010a01e:	83 e0 0f             	and    $0xf,%eax
8010a021:	c1 e0 02             	shl    $0x2,%eax
8010a024:	89 c2                	mov    %eax,%edx
8010a026:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a029:	01 d0                	add    %edx,%eax
8010a02b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a02e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a031:	83 c0 14             	add    $0x14,%eax
8010a034:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a037:	e8 b4 88 ff ff       	call   801028f0 <kalloc>
8010a03c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a03f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a046:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a049:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a04d:	0f b6 c0             	movzbl %al,%eax
8010a050:	83 e0 02             	and    $0x2,%eax
8010a053:	85 c0                	test   %eax,%eax
8010a055:	74 3d                	je     8010a094 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a057:	83 ec 0c             	sub    $0xc,%esp
8010a05a:	6a 00                	push   $0x0
8010a05c:	6a 12                	push   $0x12
8010a05e:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a061:	50                   	push   %eax
8010a062:	ff 75 e8             	push   -0x18(%ebp)
8010a065:	ff 75 08             	push   0x8(%ebp)
8010a068:	e8 a2 01 00 00       	call   8010a20f <tcp_pkt_create>
8010a06d:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a070:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a073:	83 ec 08             	sub    $0x8,%esp
8010a076:	50                   	push   %eax
8010a077:	ff 75 e8             	push   -0x18(%ebp)
8010a07a:	e8 ff f0 ff ff       	call   8010917e <i8254_send>
8010a07f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a082:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a087:	83 c0 01             	add    $0x1,%eax
8010a08a:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a08f:	e9 69 01 00 00       	jmp    8010a1fd <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a094:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a097:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a09b:	3c 18                	cmp    $0x18,%al
8010a09d:	0f 85 10 01 00 00    	jne    8010a1b3 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a0a3:	83 ec 04             	sub    $0x4,%esp
8010a0a6:	6a 03                	push   $0x3
8010a0a8:	68 3e c8 10 80       	push   $0x8010c83e
8010a0ad:	ff 75 ec             	push   -0x14(%ebp)
8010a0b0:	e8 e0 ac ff ff       	call   80104d95 <memcmp>
8010a0b5:	83 c4 10             	add    $0x10,%esp
8010a0b8:	85 c0                	test   %eax,%eax
8010a0ba:	74 74                	je     8010a130 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a0bc:	83 ec 0c             	sub    $0xc,%esp
8010a0bf:	68 42 c8 10 80       	push   $0x8010c842
8010a0c4:	e8 43 63 ff ff       	call   8010040c <cprintf>
8010a0c9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0cc:	83 ec 0c             	sub    $0xc,%esp
8010a0cf:	6a 00                	push   $0x0
8010a0d1:	6a 10                	push   $0x10
8010a0d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0d6:	50                   	push   %eax
8010a0d7:	ff 75 e8             	push   -0x18(%ebp)
8010a0da:	ff 75 08             	push   0x8(%ebp)
8010a0dd:	e8 2d 01 00 00       	call   8010a20f <tcp_pkt_create>
8010a0e2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0e8:	83 ec 08             	sub    $0x8,%esp
8010a0eb:	50                   	push   %eax
8010a0ec:	ff 75 e8             	push   -0x18(%ebp)
8010a0ef:	e8 8a f0 ff ff       	call   8010917e <i8254_send>
8010a0f4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0fa:	83 c0 36             	add    $0x36,%eax
8010a0fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a100:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a103:	50                   	push   %eax
8010a104:	ff 75 e0             	push   -0x20(%ebp)
8010a107:	6a 00                	push   $0x0
8010a109:	6a 00                	push   $0x0
8010a10b:	e8 66 04 00 00       	call   8010a576 <http_proc>
8010a110:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a113:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a116:	83 ec 0c             	sub    $0xc,%esp
8010a119:	50                   	push   %eax
8010a11a:	6a 18                	push   $0x18
8010a11c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a11f:	50                   	push   %eax
8010a120:	ff 75 e8             	push   -0x18(%ebp)
8010a123:	ff 75 08             	push   0x8(%ebp)
8010a126:	e8 e4 00 00 00       	call   8010a20f <tcp_pkt_create>
8010a12b:	83 c4 20             	add    $0x20,%esp
8010a12e:	eb 62                	jmp    8010a192 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a130:	83 ec 0c             	sub    $0xc,%esp
8010a133:	6a 00                	push   $0x0
8010a135:	6a 10                	push   $0x10
8010a137:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a13a:	50                   	push   %eax
8010a13b:	ff 75 e8             	push   -0x18(%ebp)
8010a13e:	ff 75 08             	push   0x8(%ebp)
8010a141:	e8 c9 00 00 00       	call   8010a20f <tcp_pkt_create>
8010a146:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a149:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a14c:	83 ec 08             	sub    $0x8,%esp
8010a14f:	50                   	push   %eax
8010a150:	ff 75 e8             	push   -0x18(%ebp)
8010a153:	e8 26 f0 ff ff       	call   8010917e <i8254_send>
8010a158:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a15b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a15e:	83 c0 36             	add    $0x36,%eax
8010a161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a164:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a167:	50                   	push   %eax
8010a168:	ff 75 e4             	push   -0x1c(%ebp)
8010a16b:	6a 00                	push   $0x0
8010a16d:	6a 00                	push   $0x0
8010a16f:	e8 02 04 00 00       	call   8010a576 <http_proc>
8010a174:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a177:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a17a:	83 ec 0c             	sub    $0xc,%esp
8010a17d:	50                   	push   %eax
8010a17e:	6a 18                	push   $0x18
8010a180:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a183:	50                   	push   %eax
8010a184:	ff 75 e8             	push   -0x18(%ebp)
8010a187:	ff 75 08             	push   0x8(%ebp)
8010a18a:	e8 80 00 00 00       	call   8010a20f <tcp_pkt_create>
8010a18f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a192:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a195:	83 ec 08             	sub    $0x8,%esp
8010a198:	50                   	push   %eax
8010a199:	ff 75 e8             	push   -0x18(%ebp)
8010a19c:	e8 dd ef ff ff       	call   8010917e <i8254_send>
8010a1a1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1a4:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a1a9:	83 c0 01             	add    $0x1,%eax
8010a1ac:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a1b1:	eb 4a                	jmp    8010a1fd <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a1b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1ba:	3c 10                	cmp    $0x10,%al
8010a1bc:	75 3f                	jne    8010a1fd <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a1be:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a1c3:	83 f8 01             	cmp    $0x1,%eax
8010a1c6:	75 35                	jne    8010a1fd <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a1c8:	83 ec 0c             	sub    $0xc,%esp
8010a1cb:	6a 00                	push   $0x0
8010a1cd:	6a 01                	push   $0x1
8010a1cf:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1d2:	50                   	push   %eax
8010a1d3:	ff 75 e8             	push   -0x18(%ebp)
8010a1d6:	ff 75 08             	push   0x8(%ebp)
8010a1d9:	e8 31 00 00 00       	call   8010a20f <tcp_pkt_create>
8010a1de:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1e4:	83 ec 08             	sub    $0x8,%esp
8010a1e7:	50                   	push   %eax
8010a1e8:	ff 75 e8             	push   -0x18(%ebp)
8010a1eb:	e8 8e ef ff ff       	call   8010917e <i8254_send>
8010a1f0:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a1f3:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a1fa:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a1fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a200:	83 ec 0c             	sub    $0xc,%esp
8010a203:	50                   	push   %eax
8010a204:	e8 49 86 ff ff       	call   80102852 <kfree>
8010a209:	83 c4 10             	add    $0x10,%esp
}
8010a20c:	90                   	nop
8010a20d:	c9                   	leave
8010a20e:	c3                   	ret

8010a20f <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a20f:	f3 0f 1e fb          	endbr32
8010a213:	55                   	push   %ebp
8010a214:	89 e5                	mov    %esp,%ebp
8010a216:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a219:	8b 45 08             	mov    0x8(%ebp),%eax
8010a21c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a21f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a222:	83 c0 0e             	add    $0xe,%eax
8010a225:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a22b:	0f b6 00             	movzbl (%eax),%eax
8010a22e:	0f b6 c0             	movzbl %al,%eax
8010a231:	83 e0 0f             	and    $0xf,%eax
8010a234:	c1 e0 02             	shl    $0x2,%eax
8010a237:	89 c2                	mov    %eax,%edx
8010a239:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23c:	01 d0                	add    %edx,%eax
8010a23e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a241:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a244:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a24a:	83 c0 0e             	add    $0xe,%eax
8010a24d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a253:	83 c0 14             	add    $0x14,%eax
8010a256:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a259:	8b 45 18             	mov    0x18(%ebp),%eax
8010a25c:	8d 50 36             	lea    0x36(%eax),%edx
8010a25f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a262:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a264:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a267:	8d 50 06             	lea    0x6(%eax),%edx
8010a26a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a26d:	83 ec 04             	sub    $0x4,%esp
8010a270:	6a 06                	push   $0x6
8010a272:	52                   	push   %edx
8010a273:	50                   	push   %eax
8010a274:	e8 78 ab ff ff       	call   80104df1 <memmove>
8010a279:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a27c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a27f:	83 c0 06             	add    $0x6,%eax
8010a282:	83 ec 04             	sub    $0x4,%esp
8010a285:	6a 06                	push   $0x6
8010a287:	68 68 d0 18 80       	push   $0x8018d068
8010a28c:	50                   	push   %eax
8010a28d:	e8 5f ab ff ff       	call   80104df1 <memmove>
8010a292:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a295:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a298:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a29c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a29f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2a6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ac:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a2b0:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2b3:	83 c0 28             	add    $0x28,%eax
8010a2b6:	0f b7 c0             	movzwl %ax,%eax
8010a2b9:	83 ec 0c             	sub    $0xc,%esp
8010a2bc:	50                   	push   %eax
8010a2bd:	e8 6f f8 ff ff       	call   80109b31 <H2N_ushort>
8010a2c2:	83 c4 10             	add    $0x10,%esp
8010a2c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2c8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2cc:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a2d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2da:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a2e1:	83 c0 01             	add    $0x1,%eax
8010a2e4:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a2ea:	83 ec 0c             	sub    $0xc,%esp
8010a2ed:	6a 00                	push   $0x0
8010a2ef:	e8 3d f8 ff ff       	call   80109b31 <H2N_ushort>
8010a2f4:	83 c4 10             	add    $0x10,%esp
8010a2f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2fa:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a2fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a301:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a305:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a308:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a30c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30f:	83 c0 0c             	add    $0xc,%eax
8010a312:	83 ec 04             	sub    $0x4,%esp
8010a315:	6a 04                	push   $0x4
8010a317:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a31c:	50                   	push   %eax
8010a31d:	e8 cf aa ff ff       	call   80104df1 <memmove>
8010a322:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a325:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a328:	8d 50 0c             	lea    0xc(%eax),%edx
8010a32b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a32e:	83 c0 10             	add    $0x10,%eax
8010a331:	83 ec 04             	sub    $0x4,%esp
8010a334:	6a 04                	push   $0x4
8010a336:	52                   	push   %edx
8010a337:	50                   	push   %eax
8010a338:	e8 b4 aa ff ff       	call   80104df1 <memmove>
8010a33d:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a343:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a34c:	83 ec 0c             	sub    $0xc,%esp
8010a34f:	50                   	push   %eax
8010a350:	e8 ec f8 ff ff       	call   80109c41 <ipv4_chksum>
8010a355:	83 c4 10             	add    $0x10,%esp
8010a358:	0f b7 c0             	movzwl %ax,%eax
8010a35b:	83 ec 0c             	sub    $0xc,%esp
8010a35e:	50                   	push   %eax
8010a35f:	e8 cd f7 ff ff       	call   80109b31 <H2N_ushort>
8010a364:	83 c4 10             	add    $0x10,%esp
8010a367:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a36a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a36e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a371:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a375:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a378:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a37b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a37e:	0f b7 10             	movzwl (%eax),%edx
8010a381:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a384:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a388:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a38d:	83 ec 0c             	sub    $0xc,%esp
8010a390:	50                   	push   %eax
8010a391:	e8 c1 f7 ff ff       	call   80109b57 <H2N_uint>
8010a396:	83 c4 10             	add    $0x10,%esp
8010a399:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a39c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a39f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a2:	8b 40 04             	mov    0x4(%eax),%eax
8010a3a5:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a3ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ae:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a3b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a3b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a3bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c2:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a3c6:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3c9:	89 c2                	mov    %eax,%edx
8010a3cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ce:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a3d1:	83 ec 0c             	sub    $0xc,%esp
8010a3d4:	68 90 38 00 00       	push   $0x3890
8010a3d9:	e8 53 f7 ff ff       	call   80109b31 <H2N_ushort>
8010a3de:	83 c4 10             	add    $0x10,%esp
8010a3e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3e4:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a3e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3eb:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a3f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3f4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a3fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3fd:	83 ec 0c             	sub    $0xc,%esp
8010a400:	50                   	push   %eax
8010a401:	e8 1f 00 00 00       	call   8010a425 <tcp_chksum>
8010a406:	83 c4 10             	add    $0x10,%esp
8010a409:	83 c0 08             	add    $0x8,%eax
8010a40c:	0f b7 c0             	movzwl %ax,%eax
8010a40f:	83 ec 0c             	sub    $0xc,%esp
8010a412:	50                   	push   %eax
8010a413:	e8 19 f7 ff ff       	call   80109b31 <H2N_ushort>
8010a418:	83 c4 10             	add    $0x10,%esp
8010a41b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a41e:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a422:	90                   	nop
8010a423:	c9                   	leave
8010a424:	c3                   	ret

8010a425 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a425:	f3 0f 1e fb          	endbr32
8010a429:	55                   	push   %ebp
8010a42a:	89 e5                	mov    %esp,%ebp
8010a42c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a42f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a432:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a435:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a438:	83 c0 14             	add    $0x14,%eax
8010a43b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a43e:	83 ec 04             	sub    $0x4,%esp
8010a441:	6a 04                	push   $0x4
8010a443:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a448:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a44b:	50                   	push   %eax
8010a44c:	e8 a0 a9 ff ff       	call   80104df1 <memmove>
8010a451:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a454:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a457:	83 c0 0c             	add    $0xc,%eax
8010a45a:	83 ec 04             	sub    $0x4,%esp
8010a45d:	6a 04                	push   $0x4
8010a45f:	50                   	push   %eax
8010a460:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a463:	83 c0 04             	add    $0x4,%eax
8010a466:	50                   	push   %eax
8010a467:	e8 85 a9 ff ff       	call   80104df1 <memmove>
8010a46c:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a46f:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a473:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a477:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a47a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a47e:	0f b7 c0             	movzwl %ax,%eax
8010a481:	83 ec 0c             	sub    $0xc,%esp
8010a484:	50                   	push   %eax
8010a485:	e8 81 f6 ff ff       	call   80109b0b <N2H_ushort>
8010a48a:	83 c4 10             	add    $0x10,%esp
8010a48d:	83 e8 14             	sub    $0x14,%eax
8010a490:	0f b7 c0             	movzwl %ax,%eax
8010a493:	83 ec 0c             	sub    $0xc,%esp
8010a496:	50                   	push   %eax
8010a497:	e8 95 f6 ff ff       	call   80109b31 <H2N_ushort>
8010a49c:	83 c4 10             	add    $0x10,%esp
8010a49f:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4aa:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a4b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a4b7:	eb 33                	jmp    8010a4ec <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4bc:	01 c0                	add    %eax,%eax
8010a4be:	89 c2                	mov    %eax,%edx
8010a4c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4c3:	01 d0                	add    %edx,%eax
8010a4c5:	0f b6 00             	movzbl (%eax),%eax
8010a4c8:	0f b6 c0             	movzbl %al,%eax
8010a4cb:	c1 e0 08             	shl    $0x8,%eax
8010a4ce:	89 c2                	mov    %eax,%edx
8010a4d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4d3:	01 c0                	add    %eax,%eax
8010a4d5:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4db:	01 c8                	add    %ecx,%eax
8010a4dd:	0f b6 00             	movzbl (%eax),%eax
8010a4e0:	0f b6 c0             	movzbl %al,%eax
8010a4e3:	01 d0                	add    %edx,%eax
8010a4e5:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a4e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a4ec:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a4f0:	7e c7                	jle    8010a4b9 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a4f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a4ff:	eb 33                	jmp    8010a534 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a501:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a504:	01 c0                	add    %eax,%eax
8010a506:	89 c2                	mov    %eax,%edx
8010a508:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a50b:	01 d0                	add    %edx,%eax
8010a50d:	0f b6 00             	movzbl (%eax),%eax
8010a510:	0f b6 c0             	movzbl %al,%eax
8010a513:	c1 e0 08             	shl    $0x8,%eax
8010a516:	89 c2                	mov    %eax,%edx
8010a518:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a51b:	01 c0                	add    %eax,%eax
8010a51d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a520:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a523:	01 c8                	add    %ecx,%eax
8010a525:	0f b6 00             	movzbl (%eax),%eax
8010a528:	0f b6 c0             	movzbl %al,%eax
8010a52b:	01 d0                	add    %edx,%eax
8010a52d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a530:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a534:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a538:	0f b7 c0             	movzwl %ax,%eax
8010a53b:	83 ec 0c             	sub    $0xc,%esp
8010a53e:	50                   	push   %eax
8010a53f:	e8 c7 f5 ff ff       	call   80109b0b <N2H_ushort>
8010a544:	83 c4 10             	add    $0x10,%esp
8010a547:	66 d1 e8             	shr    $1,%ax
8010a54a:	0f b7 c0             	movzwl %ax,%eax
8010a54d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a550:	7c af                	jl     8010a501 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a552:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a555:	c1 e8 10             	shr    $0x10,%eax
8010a558:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a55b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a55e:	f7 d0                	not    %eax
}
8010a560:	c9                   	leave
8010a561:	c3                   	ret

8010a562 <tcp_fin>:

void tcp_fin(){
8010a562:	f3 0f 1e fb          	endbr32
8010a566:	55                   	push   %ebp
8010a567:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a569:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a570:	00 00 00 
}
8010a573:	90                   	nop
8010a574:	5d                   	pop    %ebp
8010a575:	c3                   	ret

8010a576 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a576:	f3 0f 1e fb          	endbr32
8010a57a:	55                   	push   %ebp
8010a57b:	89 e5                	mov    %esp,%ebp
8010a57d:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a580:	8b 45 10             	mov    0x10(%ebp),%eax
8010a583:	83 ec 04             	sub    $0x4,%esp
8010a586:	6a 00                	push   $0x0
8010a588:	68 4b c8 10 80       	push   $0x8010c84b
8010a58d:	50                   	push   %eax
8010a58e:	e8 65 00 00 00       	call   8010a5f8 <http_strcpy>
8010a593:	83 c4 10             	add    $0x10,%esp
8010a596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a599:	8b 45 10             	mov    0x10(%ebp),%eax
8010a59c:	83 ec 04             	sub    $0x4,%esp
8010a59f:	ff 75 f4             	push   -0xc(%ebp)
8010a5a2:	68 5e c8 10 80       	push   $0x8010c85e
8010a5a7:	50                   	push   %eax
8010a5a8:	e8 4b 00 00 00       	call   8010a5f8 <http_strcpy>
8010a5ad:	83 c4 10             	add    $0x10,%esp
8010a5b0:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5b3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5b6:	83 ec 04             	sub    $0x4,%esp
8010a5b9:	ff 75 f4             	push   -0xc(%ebp)
8010a5bc:	68 79 c8 10 80       	push   $0x8010c879
8010a5c1:	50                   	push   %eax
8010a5c2:	e8 31 00 00 00       	call   8010a5f8 <http_strcpy>
8010a5c7:	83 c4 10             	add    $0x10,%esp
8010a5ca:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a5cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5d0:	83 e0 01             	and    $0x1,%eax
8010a5d3:	85 c0                	test   %eax,%eax
8010a5d5:	74 11                	je     8010a5e8 <http_proc+0x72>
    char *payload = (char *)send;
8010a5d7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a5dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5e3:	01 d0                	add    %edx,%eax
8010a5e5:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a5e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5eb:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5ee:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a5f0:	e8 6d ff ff ff       	call   8010a562 <tcp_fin>
}
8010a5f5:	90                   	nop
8010a5f6:	c9                   	leave
8010a5f7:	c3                   	ret

8010a5f8 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a5f8:	f3 0f 1e fb          	endbr32
8010a5fc:	55                   	push   %ebp
8010a5fd:	89 e5                	mov    %esp,%ebp
8010a5ff:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a602:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a609:	eb 20                	jmp    8010a62b <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a60b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a60e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a611:	01 d0                	add    %edx,%eax
8010a613:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a616:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a619:	01 ca                	add    %ecx,%edx
8010a61b:	89 d1                	mov    %edx,%ecx
8010a61d:	8b 55 08             	mov    0x8(%ebp),%edx
8010a620:	01 ca                	add    %ecx,%edx
8010a622:	0f b6 00             	movzbl (%eax),%eax
8010a625:	88 02                	mov    %al,(%edx)
    i++;
8010a627:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a62b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a62e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a631:	01 d0                	add    %edx,%eax
8010a633:	0f b6 00             	movzbl (%eax),%eax
8010a636:	84 c0                	test   %al,%al
8010a638:	75 d1                	jne    8010a60b <http_strcpy+0x13>
  }
  return i;
8010a63a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a63d:	c9                   	leave
8010a63e:	c3                   	ret

8010a63f <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a63f:	f3 0f 1e fb          	endbr32
8010a643:	55                   	push   %ebp
8010a644:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a646:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a64d:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a650:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a655:	c1 e8 09             	shr    $0x9,%eax
8010a658:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a65d:	90                   	nop
8010a65e:	5d                   	pop    %ebp
8010a65f:	c3                   	ret

8010a660 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a660:	f3 0f 1e fb          	endbr32
8010a664:	55                   	push   %ebp
8010a665:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a667:	90                   	nop
8010a668:	5d                   	pop    %ebp
8010a669:	c3                   	ret

8010a66a <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a66a:	f3 0f 1e fb          	endbr32
8010a66e:	55                   	push   %ebp
8010a66f:	89 e5                	mov    %esp,%ebp
8010a671:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a674:	8b 45 08             	mov    0x8(%ebp),%eax
8010a677:	83 c0 0c             	add    $0xc,%eax
8010a67a:	83 ec 0c             	sub    $0xc,%esp
8010a67d:	50                   	push   %eax
8010a67e:	e8 7f a3 ff ff       	call   80104a02 <holdingsleep>
8010a683:	83 c4 10             	add    $0x10,%esp
8010a686:	85 c0                	test   %eax,%eax
8010a688:	75 0d                	jne    8010a697 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a68a:	83 ec 0c             	sub    $0xc,%esp
8010a68d:	68 8a c8 10 80       	push   $0x8010c88a
8010a692:	e8 47 5f ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a697:	8b 45 08             	mov    0x8(%ebp),%eax
8010a69a:	8b 00                	mov    (%eax),%eax
8010a69c:	83 e0 06             	and    $0x6,%eax
8010a69f:	83 f8 02             	cmp    $0x2,%eax
8010a6a2:	75 0d                	jne    8010a6b1 <iderw+0x47>
    panic("iderw: nothing to do");
8010a6a4:	83 ec 0c             	sub    $0xc,%esp
8010a6a7:	68 a0 c8 10 80       	push   $0x8010c8a0
8010a6ac:	e8 2d 5f ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a6b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b4:	8b 40 04             	mov    0x4(%eax),%eax
8010a6b7:	83 f8 01             	cmp    $0x1,%eax
8010a6ba:	74 0d                	je     8010a6c9 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a6bc:	83 ec 0c             	sub    $0xc,%esp
8010a6bf:	68 b5 c8 10 80       	push   $0x8010c8b5
8010a6c4:	e8 15 5f ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a6c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6cc:	8b 40 08             	mov    0x8(%eax),%eax
8010a6cf:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a6d5:	39 d0                	cmp    %edx,%eax
8010a6d7:	72 0d                	jb     8010a6e6 <iderw+0x7c>
    panic("iderw: block out of range");
8010a6d9:	83 ec 0c             	sub    $0xc,%esp
8010a6dc:	68 d3 c8 10 80       	push   $0x8010c8d3
8010a6e1:	e8 f8 5e ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a6e6:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a6ec:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6ef:	8b 40 08             	mov    0x8(%eax),%eax
8010a6f2:	c1 e0 09             	shl    $0x9,%eax
8010a6f5:	01 d0                	add    %edx,%eax
8010a6f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a6fa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6fd:	8b 00                	mov    (%eax),%eax
8010a6ff:	83 e0 04             	and    $0x4,%eax
8010a702:	85 c0                	test   %eax,%eax
8010a704:	74 2b                	je     8010a731 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a706:	8b 45 08             	mov    0x8(%ebp),%eax
8010a709:	8b 00                	mov    (%eax),%eax
8010a70b:	83 e0 fb             	and    $0xfffffffb,%eax
8010a70e:	89 c2                	mov    %eax,%edx
8010a710:	8b 45 08             	mov    0x8(%ebp),%eax
8010a713:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a715:	8b 45 08             	mov    0x8(%ebp),%eax
8010a718:	83 c0 5c             	add    $0x5c,%eax
8010a71b:	83 ec 04             	sub    $0x4,%esp
8010a71e:	68 00 02 00 00       	push   $0x200
8010a723:	50                   	push   %eax
8010a724:	ff 75 f4             	push   -0xc(%ebp)
8010a727:	e8 c5 a6 ff ff       	call   80104df1 <memmove>
8010a72c:	83 c4 10             	add    $0x10,%esp
8010a72f:	eb 1a                	jmp    8010a74b <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a731:	8b 45 08             	mov    0x8(%ebp),%eax
8010a734:	83 c0 5c             	add    $0x5c,%eax
8010a737:	83 ec 04             	sub    $0x4,%esp
8010a73a:	68 00 02 00 00       	push   $0x200
8010a73f:	ff 75 f4             	push   -0xc(%ebp)
8010a742:	50                   	push   %eax
8010a743:	e8 a9 a6 ff ff       	call   80104df1 <memmove>
8010a748:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a74b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a74e:	8b 00                	mov    (%eax),%eax
8010a750:	83 c8 02             	or     $0x2,%eax
8010a753:	89 c2                	mov    %eax,%edx
8010a755:	8b 45 08             	mov    0x8(%ebp),%eax
8010a758:	89 10                	mov    %edx,(%eax)
}
8010a75a:	90                   	nop
8010a75b:	c9                   	leave
8010a75c:	c3                   	ret
