
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
8010005f:	ba ae 34 10 80       	mov    $0x801034ae,%edx
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
80100073:	68 20 a4 10 80       	push   $0x8010a420
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 3f 48 00 00       	call   801048c1 <initlock>
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
801000c1:	68 27 a4 10 80       	push   $0x8010a427
801000c6:	50                   	push   %eax
801000c7:	e8 88 46 00 00       	call   80104754 <initsleeplock>
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
80100109:	e8 d9 47 00 00       	call   801048e7 <acquire>
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
80100148:	e8 0c 48 00 00       	call   80104959 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 35 46 00 00       	call   80104794 <acquiresleep>
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
801001c9:	e8 8b 47 00 00       	call   80104959 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 b4 45 00 00       	call   80104794 <acquiresleep>
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
801001fd:	68 2e a4 10 80       	push   $0x8010a42e
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
80100239:	e8 d9 a0 00 00       	call   8010a317 <iderw>
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
8010025a:	e8 ef 45 00 00       	call   8010484e <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 3f a4 10 80       	push   $0x8010a43f
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
80100288:	e8 8a a0 00 00       	call   8010a317 <iderw>
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
801002a7:	e8 a2 45 00 00       	call   8010484e <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 46 a4 10 80       	push   $0x8010a446
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 2d 45 00 00       	call   801047fc <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 08 46 00 00       	call   801048e7 <acquire>
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
8010034a:	e8 0a 46 00 00       	call   80104959 <release>
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
8010042c:	e8 b6 44 00 00       	call   801048e7 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 4d a4 10 80       	push   $0x8010a44d
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
8010052c:	c7 45 ec 56 a4 10 80 	movl   $0x8010a456,-0x14(%ebp)
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
801005ba:	e8 9a 43 00 00       	call   80104959 <release>
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
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 5d a4 10 80       	push   $0x8010a45d
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
80100606:	68 71 a4 10 80       	push   $0x8010a471
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 8c 43 00 00       	call   801049af <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 73 a4 10 80       	push   $0x8010a473
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
801006c4:	e8 e2 7a 00 00       	call   801081ab <graphic_scroll_up>
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
80100717:	e8 8f 7a 00 00       	call   801081ab <graphic_scroll_up>
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
8010077d:	e8 9d 7a 00 00       	call   8010821f <font_render>
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
801007bd:	e8 fd 5d 00 00       	call   801065bf <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 f0 5d 00 00       	call   801065bf <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 e3 5d 00 00       	call   801065bf <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 d3 5d 00 00       	call   801065bf <uartputc>
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
80100819:	e8 c9 40 00 00       	call   801048e7 <acquire>
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
8010096f:	e8 1f 3c 00 00       	call   80104593 <wakeup>
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
80100992:	e8 c2 3f 00 00       	call   80104959 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 b1 3c 00 00       	call   80104656 <procdump>
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
801009b8:	e8 d6 11 00 00       	call   80101b93 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 14 3f 00 00       	call   801048e7 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c9 31 00 00       	call   80103ba9 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 65 3f 00 00       	call   80104959 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 7a 10 00 00       	call   80101a7c <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 83 3a 00 00       	call   801044a4 <sleep>
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
80100a9a:	e8 ba 3e 00 00       	call   80104959 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	push   0x8(%ebp)
80100aa8:	e8 cf 0f 00 00       	call   80101a7c <ilock>
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
80100acc:	e8 c2 10 00 00       	call   80101b93 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 06 3e 00 00       	call   801048e7 <acquire>
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
80100b1e:	e8 36 3e 00 00       	call   80104959 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	push   0x8(%ebp)
80100b2c:	e8 4b 0f 00 00       	call   80101a7c <ilock>
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
80100b50:	68 77 a4 10 80       	push   $0x8010a477
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 62 3d 00 00       	call   801048c1 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 7f a4 10 80 	movl   $0x8010a47f,-0xc(%ebp)
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
80100bb3:	e8 54 1b 00 00       	call   8010270c <ioapicenable>
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
80100bcb:	e8 d9 2f 00 00       	call   80103ba9 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 99 25 00 00       	call   80103171 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	push   0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 0d 26 00 00       	call   80103201 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 95 a4 10 80       	push   $0x8010a495
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 f1 03 00 00       	jmp    80100fff <exec+0x441>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	push   -0x28(%ebp)
80100c14:	e8 63 0e 00 00       	call   80101a7c <ilock>
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
80100c31:	e8 4e 13 00 00       	call   80101f84 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 66 03 00 00    	jne    80100fa8 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 58 03 00 00    	jne    80100fab <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 7b 69 00 00       	call   801075d3 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 49 03 00 00    	je     80100fae <exec+0x3f0>
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
80100c91:	e8 ee 12 00 00       	call   80101f84 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 0f 03 00 00    	jne    80100fb1 <exec+0x3f3>
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
80100cbf:	0f 82 ef 02 00 00    	jb     80100fb4 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 d6 02 00 00    	jb     80100fb7 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	push   -0x20(%ebp)
80100cf6:	ff 75 d4             	push   -0x2c(%ebp)
80100cf9:	e8 e7 6c 00 00       	call   801079e5 <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 ac 02 00 00    	je     80100fba <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 9c 02 00 00    	jne    80100fbd <exec+0x3ff>
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
80100d3f:	e8 d0 6b 00 00       	call   80107914 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 71 02 00 00    	js     80100fc0 <exec+0x402>
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
80100d78:	e8 3c 0f 00 00       	call   80101cb9 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 7c 24 00 00       	call   80103201 <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9f:	05 00 20 00 00       	add    $0x2000,%eax
80100da4:	83 ec 04             	sub    $0x4,%esp
80100da7:	50                   	push   %eax
80100da8:	ff 75 e0             	push   -0x20(%ebp)
80100dab:	ff 75 d4             	push   -0x2c(%ebp)
80100dae:	e8 32 6c 00 00       	call   801079e5 <allocuvm>
80100db3:	83 c4 10             	add    $0x10,%esp
80100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbd:	0f 84 00 02 00 00    	je     80100fc3 <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcb:	83 ec 08             	sub    $0x8,%esp
80100dce:	50                   	push   %eax
80100dcf:	ff 75 d4             	push   -0x2c(%ebp)
80100dd2:	e8 7c 6e 00 00       	call   80107c53 <clearpteu>
80100dd7:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2c4>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 cf 3f 00 00       	call   80104ddf <strlen>
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
80100e38:	e8 a2 3f 00 00       	call   80104ddf <strlen>
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
80100e5e:	e8 9b 6f 00 00       	call   80107dfe <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x40b>
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
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x22e>
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
80100efa:	e8 ff 6e 00 00       	call   80107dfe <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x371>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x36d>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	push   -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 44 3e 00 00       	call   80104d91 <safestrcpy>
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
80100f8b:	e8 6d 67 00 00       	call   801076fd <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 18 6c 00 00       	call   80107bb6 <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 57                	jmp    80100fff <exec+0x441>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fcc:	90                   	nop

 bad:
  if(pgdir)
80100fcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd1:	74 0e                	je     80100fe1 <exec+0x423>
    freevm(pgdir);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d4             	push   -0x2c(%ebp)
80100fd9:	e8 d8 6b 00 00       	call   80107bb6 <freevm>
80100fde:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe5:	74 13                	je     80100ffa <exec+0x43c>
    iunlockput(ip);
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	ff 75 d8             	push   -0x28(%ebp)
80100fed:	e8 c7 0c 00 00       	call   80101cb9 <iunlockput>
80100ff2:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff5:	e8 07 22 00 00       	call   80103201 <end_op>
  }
  return -1;
80100ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fff:	c9                   	leave
80101000:	c3                   	ret

80101001 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101001:	f3 0f 1e fb          	endbr32
80101005:	55                   	push   %ebp
80101006:	89 e5                	mov    %esp,%ebp
80101008:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100b:	83 ec 08             	sub    $0x8,%esp
8010100e:	68 a1 a4 10 80       	push   $0x8010a4a1
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 a4 38 00 00       	call   801048c1 <initlock>
8010101d:	83 c4 10             	add    $0x10,%esp
}
80101020:	90                   	nop
80101021:	c9                   	leave
80101022:	c3                   	ret

80101023 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101023:	f3 0f 1e fb          	endbr32
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 60 2d 19 80       	push   $0x80192d60
80101035:	e8 ad 38 00 00       	call   801048e7 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x50>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x4c>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 60 2d 19 80       	push   $0x80192d60
80101062:	e8 f2 38 00 00       	call   80104959 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 cf 38 00 00       	call   80104959 <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave
80101093:	c3                   	ret

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	f3 0f 1e fb          	endbr32
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 60 2d 19 80       	push   $0x80192d60
801010a6:	e8 3c 38 00 00       	call   801048e7 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 a8 a4 10 80       	push   $0x8010a4a8
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 60 2d 19 80       	push   $0x80192d60
801010dc:	e8 78 38 00 00       	call   80104959 <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return f;
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e7:	c9                   	leave
801010e8:	c3                   	ret

801010e9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e9:	f3 0f 1e fb          	endbr32
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 60 2d 19 80       	push   $0x80192d60
801010fb:	e8 e7 37 00 00       	call   801048e7 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 b0 a4 10 80       	push   $0x8010a4b0
80101115:	e8 ab f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	8d 50 ff             	lea    -0x1(%eax),%edx
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	89 50 04             	mov    %edx,0x4(%eax)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 40 04             	mov    0x4(%eax),%eax
8010112f:	85 c0                	test   %eax,%eax
80101131:	7e 15                	jle    80101148 <fileclose+0x5f>
    release(&ftable.lock);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	68 60 2d 19 80       	push   $0x80192d60
8010113b:	e8 19 38 00 00       	call   80104959 <release>
80101140:	83 c4 10             	add    $0x10,%esp
80101143:	e9 8b 00 00 00       	jmp    801011d3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 10                	mov    (%eax),%edx
8010114d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101150:	8b 50 04             	mov    0x4(%eax),%edx
80101153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101156:	8b 50 08             	mov    0x8(%eax),%edx
80101159:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115c:	8b 50 0c             	mov    0xc(%eax),%edx
8010115f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101162:	8b 50 10             	mov    0x10(%eax),%edx
80101165:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101168:	8b 40 14             	mov    0x14(%eax),%eax
8010116b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 2d 19 80       	push   $0x80192d60
80101189:	e8 cb 37 00 00       	call   80104959 <release>
8010118e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101191:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101194:	83 f8 01             	cmp    $0x1,%eax
80101197:	75 19                	jne    801011b2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101199:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a3:	83 ec 08             	sub    $0x8,%esp
801011a6:	52                   	push   %edx
801011a7:	50                   	push   %eax
801011a8:	e8 73 26 00 00       	call   80103820 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 b2 1f 00 00       	call   80103171 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 2e 20 00 00       	call   80103201 <end_op>
  }
}
801011d3:	c9                   	leave
801011d4:	c3                   	ret

801011d5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d5:	f3 0f 1e fb          	endbr32
801011d9:	55                   	push   %ebp
801011da:	89 e5                	mov    %esp,%ebp
801011dc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 00                	mov    (%eax),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 40                	jne    80101229 <filestat+0x54>
    ilock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 84 08 00 00       	call   80101a7c <ilock>
801011f8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	ff 75 0c             	push   0xc(%ebp)
80101207:	50                   	push   %eax
80101208:	e8 2d 0d 00 00       	call   80101f3a <stati>
8010120d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 74 09 00 00       	call   80101b93 <iunlock>
8010121f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101222:	b8 00 00 00 00       	mov    $0x0,%eax
80101227:	eb 05                	jmp    8010122e <filestat+0x59>
  }
  return -1;
80101229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122e:	c9                   	leave
8010122f:	c3                   	ret

80101230 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101230:	f3 0f 1e fb          	endbr32
80101234:	55                   	push   %ebp
80101235:	89 e5                	mov    %esp,%ebp
80101237:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101241:	84 c0                	test   %al,%al
80101243:	75 0a                	jne    8010124f <fileread+0x1f>
    return -1;
80101245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124a:	e9 9b 00 00 00       	jmp    801012ea <fileread+0xba>
  if(f->type == FD_PIPE)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 01             	cmp    $0x1,%eax
80101257:	75 1a                	jne    80101273 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0c             	mov    0xc(%eax),%eax
8010125f:	83 ec 04             	sub    $0x4,%esp
80101262:	ff 75 10             	push   0x10(%ebp)
80101265:	ff 75 0c             	push   0xc(%ebp)
80101268:	50                   	push   %eax
80101269:	e8 67 27 00 00       	call   801039d5 <piperead>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	eb 77                	jmp    801012ea <fileread+0xba>
  if(f->type == FD_INODE){
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 00                	mov    (%eax),%eax
80101278:	83 f8 02             	cmp    $0x2,%eax
8010127b:	75 60                	jne    801012dd <fileread+0xad>
    ilock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 f0 07 00 00       	call   80101a7c <ilock>
8010128c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 50 14             	mov    0x14(%eax),%edx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	51                   	push   %ecx
8010129f:	52                   	push   %edx
801012a0:	ff 75 0c             	push   0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 db 0c 00 00       	call   80101f84 <readi>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b3:	7e 11                	jle    801012c6 <fileread+0x96>
      f->off += r;
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 50 14             	mov    0x14(%eax),%edx
801012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012be:	01 c2                	add    %eax,%edx
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 10             	mov    0x10(%eax),%eax
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	50                   	push   %eax
801012d0:	e8 be 08 00 00       	call   80101b93 <iunlock>
801012d5:	83 c4 10             	add    $0x10,%esp
    return r;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	eb 0d                	jmp    801012ea <fileread+0xba>
  }
  panic("fileread");
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	68 ba a4 10 80       	push   $0x8010a4ba
801012e5:	e8 db f2 ff ff       	call   801005c5 <panic>
}
801012ea:	c9                   	leave
801012eb:	c3                   	ret

801012ec <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ec:	f3 0f 1e fb          	endbr32
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012fe:	84 c0                	test   %al,%al
80101300:	75 0a                	jne    8010130c <filewrite+0x20>
    return -1;
80101302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101307:	e9 1b 01 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 00                	mov    (%eax),%eax
80101311:	83 f8 01             	cmp    $0x1,%eax
80101314:	75 1d                	jne    80101333 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 40 0c             	mov    0xc(%eax),%eax
8010131c:	83 ec 04             	sub    $0x4,%esp
8010131f:	ff 75 10             	push   0x10(%ebp)
80101322:	ff 75 0c             	push   0xc(%ebp)
80101325:	50                   	push   %eax
80101326:	e8 a4 25 00 00       	call   801038cf <pipewrite>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	e9 f4 00 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 00                	mov    (%eax),%eax
80101338:	83 f8 02             	cmp    $0x2,%eax
8010133b:	0f 85 d9 00 00 00    	jne    8010141a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101341:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010134f:	e9 a3 00 00 00       	jmp    801013f7 <filewrite+0x10b>
      int n1 = n - i;
80101354:	8b 45 10             	mov    0x10(%ebp),%eax
80101357:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101360:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101363:	7e 06                	jle    8010136b <filewrite+0x7f>
        n1 = max;
80101365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101368:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136b:	e8 01 1e 00 00       	call   80103171 <begin_op>
      ilock(f->ip);
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 40 10             	mov    0x10(%eax),%eax
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	50                   	push   %eax
8010137a:	e8 fd 06 00 00       	call   80101a7c <ilock>
8010137f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101382:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 50 14             	mov    0x14(%eax),%edx
8010138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101391:	01 c3                	add    %eax,%ebx
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	51                   	push   %ecx
8010139a:	52                   	push   %edx
8010139b:	53                   	push   %ebx
8010139c:	50                   	push   %eax
8010139d:	e8 3b 0d 00 00       	call   801020dd <writei>
801013a2:	83 c4 10             	add    $0x10,%esp
801013a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ac:	7e 11                	jle    801013bf <filewrite+0xd3>
        f->off += r;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 50 14             	mov    0x14(%eax),%edx
801013b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b7:	01 c2                	add    %eax,%edx
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 10             	mov    0x10(%eax),%eax
801013c5:	83 ec 0c             	sub    $0xc,%esp
801013c8:	50                   	push   %eax
801013c9:	e8 c5 07 00 00       	call   80101b93 <iunlock>
801013ce:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d1:	e8 2b 1e 00 00       	call   80103201 <end_op>

      if(r < 0)
801013d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013da:	78 29                	js     80101405 <filewrite+0x119>
        break;
      if(r != n1)
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e2:	74 0d                	je     801013f1 <filewrite+0x105>
        panic("short filewrite");
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	68 c3 a4 10 80       	push   $0x8010a4c3
801013ec:	e8 d4 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fd:	0f 8c 51 ff ff ff    	jl     80101354 <filewrite+0x68>
80101403:	eb 01                	jmp    80101406 <filewrite+0x11a>
        break;
80101405:	90                   	nop
    }
    return i == n ? n : -1;
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140c:	75 05                	jne    80101413 <filewrite+0x127>
8010140e:	8b 45 10             	mov    0x10(%ebp),%eax
80101411:	eb 14                	jmp    80101427 <filewrite+0x13b>
80101413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101418:	eb 0d                	jmp    80101427 <filewrite+0x13b>
  }
  panic("filewrite");
8010141a:	83 ec 0c             	sub    $0xc,%esp
8010141d:	68 d3 a4 10 80       	push   $0x8010a4d3
80101422:	e8 9e f1 ff ff       	call   801005c5 <panic>
}
80101427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142a:	c9                   	leave
8010142b:	c3                   	ret

8010142c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142c:	f3 0f 1e fb          	endbr32
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	83 ec 08             	sub    $0x8,%esp
8010143c:	6a 01                	push   $0x1
8010143e:	50                   	push   %eax
8010143f:	e8 c5 ed ff ff       	call   80100209 <bread>
80101444:	83 c4 10             	add    $0x10,%esp
80101447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144d:	83 c0 5c             	add    $0x5c,%eax
80101450:	83 ec 04             	sub    $0x4,%esp
80101453:	6a 1c                	push   $0x1c
80101455:	50                   	push   %eax
80101456:	ff 75 0c             	push   0xc(%ebp)
80101459:	e8 df 37 00 00       	call   80104c3d <memmove>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	push   -0xc(%ebp)
80101467:	e8 27 ee ff ff       	call   80100293 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave
80101471:	c3                   	ret

80101472 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101472:	f3 0f 1e fb          	endbr32
80101476:	55                   	push   %ebp
80101477:	89 e5                	mov    %esp,%ebp
80101479:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010147f:	8b 45 08             	mov    0x8(%ebp),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	52                   	push   %edx
80101486:	50                   	push   %eax
80101487:	e8 7d ed ff ff       	call   80100209 <bread>
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101495:	83 c0 5c             	add    $0x5c,%eax
80101498:	83 ec 04             	sub    $0x4,%esp
8010149b:	68 00 02 00 00       	push   $0x200
801014a0:	6a 00                	push   $0x0
801014a2:	50                   	push   %eax
801014a3:	e8 ce 36 00 00       	call   80104b76 <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	push   -0xc(%ebp)
801014b1:	e8 04 1f 00 00       	call   801033ba <log_write>
801014b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	ff 75 f4             	push   -0xc(%ebp)
801014bf:	e8 cf ed ff ff       	call   80100293 <brelse>
801014c4:	83 c4 10             	add    $0x10,%esp
}
801014c7:	90                   	nop
801014c8:	c9                   	leave
801014c9:	c3                   	ret

801014ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ca:	f3 0f 1e fb          	endbr32
801014ce:	55                   	push   %ebp
801014cf:	89 e5                	mov    %esp,%ebp
801014d1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e2:	e9 13 01 00 00       	jmp    801015fa <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014f0:	85 c0                	test   %eax,%eax
801014f2:	0f 48 c2             	cmovs  %edx,%eax
801014f5:	c1 f8 0c             	sar    $0xc,%eax
801014f8:	89 c2                	mov    %eax,%edx
801014fa:	a1 78 37 19 80       	mov    0x80193778,%eax
801014ff:	01 d0                	add    %edx,%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	50                   	push   %eax
80101505:	ff 75 08             	push   0x8(%ebp)
80101508:	e8 fc ec ff ff       	call   80100209 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010151a:	e9 a6 00 00 00       	jmp    801015c5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101522:	99                   	cltd
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 c1                	mov    %eax,%ecx
80101534:	d3 e2                	shl    %cl,%edx
80101536:	89 d0                	mov    %edx,%eax
80101538:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	8d 50 07             	lea    0x7(%eax),%edx
80101541:	85 c0                	test   %eax,%eax
80101543:	0f 48 c2             	cmovs  %edx,%eax
80101546:	c1 f8 03             	sar    $0x3,%eax
80101549:	89 c2                	mov    %eax,%edx
8010154b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 e8             	and    -0x18(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 64                	jne    801015c1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	8d 50 07             	lea    0x7(%eax),%edx
80101563:	85 c0                	test   %eax,%eax
80101565:	0f 48 c2             	cmovs  %edx,%eax
80101568:	c1 f8 03             	sar    $0x3,%eax
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101573:	89 d1                	mov    %edx,%ecx
80101575:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101578:	09 ca                	or     %ecx,%edx
8010157a:	89 d1                	mov    %edx,%ecx
8010157c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	push   -0x14(%ebp)
80101589:	e8 2c 1e 00 00       	call   801033ba <log_write>
8010158e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101591:	83 ec 0c             	sub    $0xc,%esp
80101594:	ff 75 ec             	push   -0x14(%ebp)
80101597:	e8 f7 ec ff ff       	call   80100293 <brelse>
8010159c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 c2                	add    %eax,%edx
801015a7:	8b 45 08             	mov    0x8(%ebp),%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	52                   	push   %edx
801015ae:	50                   	push   %eax
801015af:	e8 be fe ff ff       	call   80101472 <bzero>
801015b4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bd:	01 d0                	add    %edx,%eax
801015bf:	eb 57                	jmp    80101618 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x11b>
801015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 3a ff ff ff    	jb     8010151f <balloc+0x55>
      }
    }
    brelse(bp);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	ff 75 ec             	push   -0x14(%ebp)
801015eb:	e8 a3 ec ff ff       	call   80100293 <brelse>
801015f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015fa:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 e0 a4 10 80       	push   $0x8010a4e0
80101613:	e8 ad ef ff ff       	call   801005c5 <panic>
}
80101618:	c9                   	leave
80101619:	c3                   	ret

8010161a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010161a:	f3 0f 1e fb          	endbr32
8010161e:	55                   	push   %ebp
8010161f:	89 e5                	mov    %esp,%ebp
80101621:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	68 60 37 19 80       	push   $0x80193760
8010162c:	ff 75 08             	push   0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 b6 eb ff ff       	call   80100209 <bread>
80101653:	83 c4 10             	add    $0x10,%esp
80101656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	99                   	cltd
80101668:	c1 ea 1d             	shr    $0x1d,%edx
8010166b:	01 d0                	add    %edx,%eax
8010166d:	83 e0 07             	and    $0x7,%eax
80101670:	29 d0                	sub    %edx,%eax
80101672:	ba 01 00 00 00       	mov    $0x1,%edx
80101677:	89 c1                	mov    %eax,%ecx
80101679:	d3 e2                	shl    %cl,%edx
8010167b:	89 d0                	mov    %edx,%eax
8010167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101683:	8d 50 07             	lea    0x7(%eax),%edx
80101686:	85 c0                	test   %eax,%eax
80101688:	0f 48 c2             	cmovs  %edx,%eax
8010168b:	c1 f8 03             	sar    $0x3,%eax
8010168e:	89 c2                	mov    %eax,%edx
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101698:	0f b6 c0             	movzbl %al,%eax
8010169b:	23 45 ec             	and    -0x14(%ebp),%eax
8010169e:	85 c0                	test   %eax,%eax
801016a0:	75 0d                	jne    801016af <bfree+0x95>
    panic("freeing free block");
801016a2:	83 ec 0c             	sub    $0xc,%esp
801016a5:	68 f6 a4 10 80       	push   $0x8010a4f6
801016aa:	e8 16 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b2:	8d 50 07             	lea    0x7(%eax),%edx
801016b5:	85 c0                	test   %eax,%eax
801016b7:	0f 48 c2             	cmovs  %edx,%eax
801016ba:	c1 f8 03             	sar    $0x3,%eax
801016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016c5:	89 d1                	mov    %edx,%ecx
801016c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ca:	f7 d2                	not    %edx
801016cc:	21 ca                	and    %ecx,%edx
801016ce:	89 d1                	mov    %edx,%ecx
801016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	push   -0xc(%ebp)
801016dd:	e8 d8 1c 00 00       	call   801033ba <log_write>
801016e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f4             	push   -0xc(%ebp)
801016eb:	e8 a3 eb ff ff       	call   80100293 <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
}
801016f3:	90                   	nop
801016f4:	c9                   	leave
801016f5:	c3                   	ret

801016f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f6:	f3 0f 1e fb          	endbr32
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010170a:	83 ec 08             	sub    $0x8,%esp
8010170d:	68 09 a5 10 80       	push   $0x8010a509
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 a5 31 00 00       	call   801048c1 <initlock>
8010171c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010171f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101726:	eb 2d                	jmp    80101755 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	89 d0                	mov    %edx,%eax
8010172d:	c1 e0 03             	shl    $0x3,%eax
80101730:	01 d0                	add    %edx,%eax
80101732:	c1 e0 04             	shl    $0x4,%eax
80101735:	83 c0 30             	add    $0x30,%eax
80101738:	05 80 37 19 80       	add    $0x80193780,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 10 a5 10 80       	push   $0x8010a510
80101748:	50                   	push   %eax
80101749:	e8 06 30 00 00       	call   80104754 <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 60 37 19 80       	push   $0x80193760
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010177c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101782:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101788:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010178e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101794:	a1 60 37 19 80       	mov    0x80193760,%eax
80101799:	ff 75 d4             	push   -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 18 a5 10 80       	push   $0x8010a518
801017a7:	e8 60 ec ff ff       	call   8010040c <cprintf>
801017ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017af:	90                   	nop
801017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017b3:	5b                   	pop    %ebx
801017b4:	5e                   	pop    %esi
801017b5:	5f                   	pop    %edi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret

801017b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b8:	f3 0f 1e fb          	endbr32
801017bc:	55                   	push   %ebp
801017bd:	89 e5                	mov    %esp,%ebp
801017bf:	83 ec 28             	sub    $0x28,%esp
801017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d0:	e9 9e 00 00 00       	jmp    80101873 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c1 e8 03             	shr    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	a1 74 37 19 80       	mov    0x80193774,%eax
801017e2:	01 d0                	add    %edx,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	push   0x8(%ebp)
801017eb:	e8 19 ea ff ff       	call   80100209 <bread>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	01 d0                	add    %edx,%eax
80101807:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180d:	0f b7 00             	movzwl (%eax),%eax
80101810:	66 85 c0             	test   %ax,%ax
80101813:	75 4c                	jne    80101861 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101815:	83 ec 04             	sub    $0x4,%esp
80101818:	6a 40                	push   $0x40
8010181a:	6a 00                	push   $0x0
8010181c:	ff 75 ec             	push   -0x14(%ebp)
8010181f:	e8 52 33 00 00       	call   80104b76 <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	push   -0x10(%ebp)
80101837:	e8 7e 1b 00 00       	call   801033ba <log_write>
8010183c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f0             	push   -0x10(%ebp)
80101845:	e8 49 ea ff ff       	call   80100293 <brelse>
8010184a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	83 ec 08             	sub    $0x8,%esp
80101853:	50                   	push   %eax
80101854:	ff 75 08             	push   0x8(%ebp)
80101857:	e8 fc 00 00 00       	call   80101958 <iget>
8010185c:	83 c4 10             	add    $0x10,%esp
8010185f:	eb 30                	jmp    80101891 <ialloc+0xd9>
    }
    brelse(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 f0             	push   -0x10(%ebp)
80101867:	e8 27 ea ff ff       	call   80100293 <brelse>
8010186c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101873:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 6b a5 10 80       	push   $0x8010a56b
8010188c:	e8 34 ed ff ff       	call   801005c5 <panic>
}
80101891:	c9                   	leave
80101892:	c3                   	ret

80101893 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101893:	f3 0f 1e fb          	endbr32
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 4b e9 ff ff       	call   80100209 <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 07 33 00 00       	call   80104c3d <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	push   -0xc(%ebp)
8010193f:	e8 76 1a 00 00       	call   801033ba <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	push   -0xc(%ebp)
8010194d:	e8 41 e9 ff ff       	call   80100293 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave
80101957:	c3                   	ret

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	f3 0f 1e fb          	endbr32
8010195c:	55                   	push   %ebp
8010195d:	89 e5                	mov    %esp,%ebp
8010195f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101962:	83 ec 0c             	sub    $0xc,%esp
80101965:	68 80 37 19 80       	push   $0x80193780
8010196a:	e8 78 2f 00 00       	call   801048e7 <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101980:	eb 60                	jmp    801019e2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	8b 40 08             	mov    0x8(%eax),%eax
80101988:	85 c0                	test   %eax,%eax
8010198a:	7e 39                	jle    801019c5 <iget+0x6d>
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	39 45 08             	cmp    %eax,0x8(%ebp)
80101994:	75 2f                	jne    801019c5 <iget+0x6d>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010199f:	75 24                	jne    801019c5 <iget+0x6d>
      ip->ref++;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 40 08             	mov    0x8(%eax),%eax
801019a7:	8d 50 01             	lea    0x1(%eax),%edx
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 80 37 19 80       	push   $0x80193780
801019b8:	e8 9c 2f 00 00       	call   80104959 <release>
801019bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c3:	eb 77                	jmp    80101a3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c9:	75 10                	jne    801019db <iget+0x83>
801019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ce:	8b 40 08             	mov    0x8(%eax),%eax
801019d1:	85 c0                	test   %eax,%eax
801019d3:	75 06                	jne    801019db <iget+0x83>
      empty = ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019db:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019e2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 7d a5 10 80       	push   $0x8010a57d
801019f9:	e8 c7 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 55 08             	mov    0x8(%ebp),%edx
80101a0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a29:	83 ec 0c             	sub    $0xc,%esp
80101a2c:	68 80 37 19 80       	push   $0x80193780
80101a31:	e8 23 2f 00 00       	call   80104959 <release>
80101a36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a3c:	c9                   	leave
80101a3d:	c3                   	ret

80101a3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3e:	f3 0f 1e fb          	endbr32
80101a42:	55                   	push   %ebp
80101a43:	89 e5                	mov    %esp,%ebp
80101a45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	68 80 37 19 80       	push   $0x80193780
80101a50:	e8 92 2e 00 00       	call   801048e7 <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 80 37 19 80       	push   $0x80193780
80101a6f:	e8 e5 2e 00 00       	call   80104959 <release>
80101a74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a7a:	c9                   	leave
80101a7b:	c3                   	ret

80101a7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a7c:	f3 0f 1e fb          	endbr32
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8a:	74 0a                	je     80101a96 <ilock+0x1a>
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	8b 40 08             	mov    0x8(%eax),%eax
80101a92:	85 c0                	test   %eax,%eax
80101a94:	7f 0d                	jg     80101aa3 <ilock+0x27>
    panic("ilock");
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 8d a5 10 80       	push   $0x8010a58d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 e2 2c 00 00       	call   80104794 <acquiresleep>
80101ab2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 85 cd 00 00 00    	jne    80101b90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 04             	mov    0x4(%eax),%eax
80101ac9:	c1 e8 03             	shr    $0x3,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ad3:	01 c2                	add    %eax,%edx
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 00                	mov    (%eax),%eax
80101ada:	83 ec 08             	sub    $0x8,%esp
80101add:	52                   	push   %edx
80101ade:	50                   	push   %eax
80101adf:	e8 25 e7 ff ff       	call   80100209 <bread>
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 40 04             	mov    0x4(%eax),%eax
80101af6:	83 e0 07             	and    $0x7,%eax
80101af9:	c1 e0 06             	shl    $0x6,%eax
80101afc:	01 d0                	add    %edx,%eax
80101afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b04:	0f b7 10             	movzwl (%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8b 50 08             	mov    0x8(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	8d 50 0c             	lea    0xc(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	83 c0 5c             	add    $0x5c,%eax
80101b50:	83 ec 04             	sub    $0x4,%esp
80101b53:	6a 34                	push   $0x34
80101b55:	52                   	push   %edx
80101b56:	50                   	push   %eax
80101b57:	e8 e1 30 00 00       	call   80104c3d <memmove>
80101b5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	ff 75 f4             	push   -0xc(%ebp)
80101b65:	e8 29 e7 ff ff       	call   80100293 <brelse>
80101b6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b7e:	66 85 c0             	test   %ax,%ax
80101b81:	75 0d                	jne    80101b90 <ilock+0x114>
      panic("ilock: no type");
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 93 a5 10 80       	push   $0x8010a593
80101b8b:	e8 35 ea ff ff       	call   801005c5 <panic>
  }
}
80101b90:	90                   	nop
80101b91:	c9                   	leave
80101b92:	c3                   	ret

80101b93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b93:	f3 0f 1e fb          	endbr32
80101b97:	55                   	push   %ebp
80101b98:	89 e5                	mov    %esp,%ebp
80101b9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ba1:	74 20                	je     80101bc3 <iunlock+0x30>
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 9c 2c 00 00       	call   8010484e <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 a2 a5 10 80       	push   $0x8010a5a2
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 1d 2c 00 00       	call   801047fc <releasesleep>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave
80101be4:	c3                   	ret

80101be5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be5:	f3 0f 1e fb          	endbr32
80101be9:	55                   	push   %ebp
80101bea:	89 e5                	mov    %esp,%ebp
80101bec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 96 2b 00 00       	call   80104794 <acquiresleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c07:	85 c0                	test   %eax,%eax
80101c09:	74 6a                	je     80101c75 <iput+0x90>
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c12:	66 85 c0             	test   %ax,%ax
80101c15:	75 5e                	jne    80101c75 <iput+0x90>
    acquire(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 80 37 19 80       	push   $0x80193780
80101c1f:	e8 c3 2c 00 00       	call   801048e7 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 1c 2d 00 00       	call   80104959 <release>
80101c3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c44:	75 2f                	jne    80101c75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c46:	83 ec 0c             	sub    $0xc,%esp
80101c49:	ff 75 08             	push   0x8(%ebp)
80101c4c:	e8 b5 01 00 00       	call   80101e06 <itrunc>
80101c51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	push   0x8(%ebp)
80101c63:	e8 2b fc ff ff       	call   80101893 <iupdate>
80101c68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	83 c0 0c             	add    $0xc,%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 78 2b 00 00       	call   801047fc <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 53 2c 00 00       	call   801048e7 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 80 37 19 80       	push   $0x80193780
80101cae:	e8 a6 2c 00 00       	call   80104959 <release>
80101cb3:	83 c4 10             	add    $0x10,%esp
}
80101cb6:	90                   	nop
80101cb7:	c9                   	leave
80101cb8:	c3                   	ret

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	f3 0f 1e fb          	endbr32
80101cbd:	55                   	push   %ebp
80101cbe:	89 e5                	mov    %esp,%ebp
80101cc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	push   0x8(%ebp)
80101cc9:	e8 c5 fe ff ff       	call   80101b93 <iunlock>
80101cce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	push   0x8(%ebp)
80101cd7:	e8 09 ff ff ff       	call   80101be5 <iput>
80101cdc:	83 c4 10             	add    $0x10,%esp
}
80101cdf:	90                   	nop
80101ce0:	c9                   	leave
80101ce1:	c3                   	ret

80101ce2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce2:	f3 0f 1e fb          	endbr32
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf0:	77 42                	ja     80101d34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf8:	83 c2 14             	add    $0x14,%edx
80101cfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 24                	jne    80101d2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 b4 f7 ff ff       	call   801014ca <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	e9 d0 00 00 00       	jmp    80101e04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3c:	0f 87 b5 00 00 00    	ja     80101df7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d52:	75 20                	jne    80101d74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	50                   	push   %eax
80101d5d:	e8 68 f7 ff ff       	call   801014ca <balloc>
80101d62:	83 c4 10             	add    $0x10,%esp
80101d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	83 ec 08             	sub    $0x8,%esp
80101d7c:	ff 75 f4             	push   -0xc(%ebp)
80101d7f:	50                   	push   %eax
80101d80:	e8 84 e4 ff ff       	call   80100209 <bread>
80101d85:	83 c4 10             	add    $0x10,%esp
80101d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	83 c0 5c             	add    $0x5c,%eax
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da1:	01 d0                	add    %edx,%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 36                	jne    80101de4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 0e f7 ff ff       	call   801014ca <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	01 c2                	add    %eax,%edx
80101dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	push   -0x10(%ebp)
80101ddc:	e8 d9 15 00 00       	call   801033ba <log_write>
80101de1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 f0             	push   -0x10(%ebp)
80101dea:	e8 a4 e4 ff ff       	call   80100293 <brelse>
80101def:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df5:	eb 0d                	jmp    80101e04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 aa a5 10 80       	push   $0x8010a5aa
80101dff:	e8 c1 e7 ff ff       	call   801005c5 <panic>
}
80101e04:	c9                   	leave
80101e05:	c3                   	ret

80101e06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e06:	f3 0f 1e fb          	endbr32
80101e0a:	55                   	push   %ebp
80101e0b:	89 e5                	mov    %esp,%ebp
80101e0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e17:	eb 45                	jmp    80101e5e <itrunc+0x58>
    if(ip->addrs[i]){
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1f:	83 c2 14             	add    $0x14,%edx
80101e22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	74 30                	je     80101e5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e30:	83 c2 14             	add    $0x14,%edx
80101e33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e37:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3a:	8b 12                	mov    (%edx),%edx
80101e3c:	83 ec 08             	sub    $0x8,%esp
80101e3f:	50                   	push   %eax
80101e40:	52                   	push   %edx
80101e41:	e8 d4 f7 ff ff       	call   8010161a <bfree>
80101e46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4f:	83 c2 14             	add    $0x14,%edx
80101e52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e59:	00 
  for(i = 0; i < NDIRECT; i++){
80101e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e62:	7e b5                	jle    80101e19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6d:	85 c0                	test   %eax,%eax
80101e6f:	0f 84 aa 00 00 00    	je     80101f1f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 7c e3 ff ff       	call   80100209 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 5c             	add    $0x5c,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xdb>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 40 f7 ff ff       	call   8010161a <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x9f>
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	push   -0x14(%ebp)
80101eef:	e8 9f e3 ff ff       	call   80100293 <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 0b f7 ff ff       	call   8010161a <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f1c:	00 00 00 
  }

  ip->size = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f29:	83 ec 0c             	sub    $0xc,%esp
80101f2c:	ff 75 08             	push   0x8(%ebp)
80101f2f:	e8 5f f9 ff ff       	call   80101893 <iupdate>
80101f34:	83 c4 10             	add    $0x10,%esp
}
80101f37:	90                   	nop
80101f38:	c9                   	leave
80101f39:	c3                   	ret

80101f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f3a:	f3 0f 1e fb          	endbr32
80101f3e:	55                   	push   %ebp
80101f3f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 00                	mov    (%eax),%eax
80101f46:	89 c2                	mov    %eax,%edx
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 50 04             	mov    0x4(%eax),%edx
80101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f57:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f64:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f71:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 50 58             	mov    0x58(%eax),%edx
80101f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f81:	90                   	nop
80101f82:	5d                   	pop    %ebp
80101f83:	c3                   	ret

80101f84 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f84:	f3 0f 1e fb          	endbr32
80101f88:	55                   	push   %ebp
80101f89:	89 e5                	mov    %esp,%ebp
80101f8b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f95:	66 83 f8 03          	cmp    $0x3,%ax
80101f99:	75 5c                	jne    80101ff7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa2:	66 85 c0             	test   %ax,%ax
80101fa5:	78 20                	js     80101fc7 <readi+0x43>
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 83 f8 09          	cmp    $0x9,%ax
80101fb2:	7f 13                	jg     80101fc7 <readi+0x43>
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbb:	98                   	cwtl
80101fbc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl
80101fd9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fe0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	52                   	push   %edx
80101fe7:	ff 75 0c             	push   0xc(%ebp)
80101fea:	ff 75 08             	push   0x8(%ebp)
80101fed:	ff d0                	call   *%eax
80101fef:	83 c4 10             	add    $0x10,%esp
80101ff2:	e9 e4 00 00 00       	jmp    801020db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 40 58             	mov    0x58(%eax),%eax
80101ffd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102000:	77 0d                	ja     8010200f <readi+0x8b>
80102002:	8b 55 10             	mov    0x10(%ebp),%edx
80102005:	8b 45 14             	mov    0x14(%ebp),%eax
80102008:	01 d0                	add    %edx,%eax
8010200a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010200d:	76 0a                	jbe    80102019 <readi+0x95>
    return -1;
8010200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102014:	e9 c2 00 00 00       	jmp    801020db <readi+0x157>
  if(off + n > ip->size)
80102019:	8b 55 10             	mov    0x10(%ebp),%edx
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	01 c2                	add    %eax,%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 40 58             	mov    0x58(%eax),%eax
80102027:	39 c2                	cmp    %eax,%edx
80102029:	76 0c                	jbe    80102037 <readi+0xb3>
    n = ip->size - off;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	2b 45 10             	sub    0x10(%ebp),%eax
80102034:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010203e:	e9 89 00 00 00       	jmp    801020cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	c1 e8 09             	shr    $0x9,%eax
80102049:	83 ec 08             	sub    $0x8,%esp
8010204c:	50                   	push   %eax
8010204d:	ff 75 08             	push   0x8(%ebp)
80102050:	e8 8d fc ff ff       	call   80101ce2 <bmap>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	8b 55 08             	mov    0x8(%ebp),%edx
8010205b:	8b 12                	mov    (%edx),%edx
8010205d:	83 ec 08             	sub    $0x8,%esp
80102060:	50                   	push   %eax
80102061:	52                   	push   %edx
80102062:	e8 a2 e1 ff ff       	call   80100209 <bread>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010206d:	8b 45 10             	mov    0x10(%ebp),%eax
80102070:	25 ff 01 00 00       	and    $0x1ff,%eax
80102075:	ba 00 02 00 00       	mov    $0x200,%edx
8010207a:	29 c2                	sub    %eax,%edx
8010207c:	8b 45 14             	mov    0x14(%ebp),%eax
8010207f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102082:	39 c2                	cmp    %eax,%edx
80102084:	0f 46 c2             	cmovbe %edx,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102090:	8b 45 10             	mov    0x10(%ebp),%eax
80102093:	25 ff 01 00 00       	and    $0x1ff,%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	83 ec 04             	sub    $0x4,%esp
8010209d:	ff 75 ec             	push   -0x14(%ebp)
801020a0:	50                   	push   %eax
801020a1:	ff 75 0c             	push   0xc(%ebp)
801020a4:	e8 94 2b 00 00       	call   80104c3d <memmove>
801020a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	ff 75 f0             	push   -0x10(%ebp)
801020b2:	e8 dc e1 ff ff       	call   80100293 <brelse>
801020b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 10             	add    %eax,0x10(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 0c             	add    %eax,0xc(%ebp)
801020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d2:	0f 82 6b ff ff ff    	jb     80102043 <readi+0xbf>
  }
  return n;
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020db:	c9                   	leave
801020dc:	c3                   	ret

801020dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020dd:	f3 0f 1e fb          	endbr32
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x43>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x43>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102114:	98                   	cwtl
80102115:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl
80102132:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	push   0xc(%ebp)
80102143:	ff 75 08             	push   0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 15 01 00 00       	jmp    80102265 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 58             	mov    0x58(%eax),%eax
80102156:	39 45 10             	cmp    %eax,0x10(%ebp)
80102159:	77 0d                	ja     80102168 <writei+0x8b>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	39 45 10             	cmp    %eax,0x10(%ebp)
80102166:	76 0a                	jbe    80102172 <writei+0x95>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f3 00 00 00       	jmp    80102265 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xae>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 da 00 00 00       	jmp    80102265 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 97 00 00 00       	jmp    8010222e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 39 fb ff ff       	call   80101ce2 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	8b 55 08             	mov    0x8(%ebp),%edx
801021af:	8b 12                	mov    (%edx),%edx
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	50                   	push   %eax
801021b5:	52                   	push   %edx
801021b6:	e8 4e e0 ff ff       	call   80100209 <bread>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	ba 00 02 00 00       	mov    $0x200,%edx
801021ce:	29 c2                	sub    %eax,%edx
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
801021d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d6:	39 c2                	cmp    %eax,%edx
801021d8:	0f 46 c2             	cmovbe %edx,%eax
801021db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	01 d0                	add    %edx,%eax
801021ee:	83 ec 04             	sub    $0x4,%esp
801021f1:	ff 75 ec             	push   -0x14(%ebp)
801021f4:	ff 75 0c             	push   0xc(%ebp)
801021f7:	50                   	push   %eax
801021f8:	e8 40 2a 00 00       	call   80104c3d <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	push   -0x10(%ebp)
80102206:	e8 af 11 00 00       	call   801033ba <log_write>
8010220b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	ff 75 f0             	push   -0x10(%ebp)
80102214:	e8 7a e0 ff ff       	call   80100293 <brelse>
80102219:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 10             	add    %eax,0x10(%ebp)
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 0c             	add    %eax,0xc(%ebp)
8010222e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102231:	3b 45 14             	cmp    0x14(%ebp),%eax
80102234:	0f 82 5d ff ff ff    	jb     80102197 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010223a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010223e:	74 22                	je     80102262 <writei+0x185>
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 40 58             	mov    0x58(%eax),%eax
80102246:	39 45 10             	cmp    %eax,0x10(%ebp)
80102249:	76 17                	jbe    80102262 <writei+0x185>
    ip->size = off;
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 55 10             	mov    0x10(%ebp),%edx
80102251:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102254:	83 ec 0c             	sub    $0xc,%esp
80102257:	ff 75 08             	push   0x8(%ebp)
8010225a:	e8 34 f6 ff ff       	call   80101893 <iupdate>
8010225f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102262:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102265:	c9                   	leave
80102266:	c3                   	ret

80102267 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102267:	f3 0f 1e fb          	endbr32
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	push   0xc(%ebp)
80102279:	ff 75 08             	push   0x8(%ebp)
8010227c:	e8 5a 2a 00 00       	call   80104cdb <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave
80102285:	c3                   	ret

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	f3 0f 1e fb          	endbr32
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102297:	66 83 f8 01          	cmp    $0x1,%ax
8010229b:	74 0d                	je     801022aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010229d:	83 ec 0c             	sub    $0xc,%esp
801022a0:	68 bd a5 10 80       	push   $0x8010a5bd
801022a5:	e8 1b e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b1:	eb 7b                	jmp    8010232e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b3:	6a 10                	push   $0x10
801022b5:	ff 75 f4             	push   -0xc(%ebp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	50                   	push   %eax
801022bc:	ff 75 08             	push   0x8(%ebp)
801022bf:	e8 c0 fc ff ff       	call   80101f84 <readi>
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	83 f8 10             	cmp    $0x10,%eax
801022ca:	74 0d                	je     801022d9 <dirlookup+0x53>
      panic("dirlookup read");
801022cc:	83 ec 0c             	sub    $0xc,%esp
801022cf:	68 cf a5 10 80       	push   $0x8010a5cf
801022d4:	e8 ec e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dd:	66 85 c0             	test   %ax,%ax
801022e0:	74 47                	je     80102329 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	83 c0 02             	add    $0x2,%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 0c             	push   0xc(%ebp)
801022ef:	e8 73 ff ff ff       	call   80102267 <namecmp>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	85 c0                	test   %eax,%eax
801022f9:	75 2f                	jne    8010232a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ff:	74 08                	je     80102309 <dirlookup+0x83>
        *poff = off;
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102307:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	0f b7 c0             	movzwl %ax,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 00                	mov    (%eax),%eax
80102318:	83 ec 08             	sub    $0x8,%esp
8010231b:	ff 75 f0             	push   -0x10(%ebp)
8010231e:	50                   	push   %eax
8010231f:	e8 34 f6 ff ff       	call   80101958 <iget>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	eb 19                	jmp    80102342 <dirlookup+0xbc>
      continue;
80102329:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 58             	mov    0x58(%eax),%eax
80102334:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102337:	0f 82 76 ff ff ff    	jb     801022b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010233d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102342:	c9                   	leave
80102343:	c3                   	ret

80102344 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102344:	f3 0f 1e fb          	endbr32
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	push   0xc(%ebp)
80102356:	ff 75 08             	push   0x8(%ebp)
80102359:	e8 28 ff ff ff       	call   80102286 <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3e>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	push   -0x10(%ebp)
80102370:	e8 70 f8 ff ff       	call   80101be5 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	push   0x8(%ebp)
80102398:	e8 e7 fb ff ff       	call   80101f84 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6e>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 de a5 10 80       	push   $0x8010a5de
801023ad:	e8 13 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x47>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x90>
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	push   0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 4d 29 00 00       	call   80104d35 <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	push   0x8(%ebp)
801023ff:	e8 d9 fc ff ff       	call   801020dd <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd5>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 eb a5 10 80       	push   $0x8010a5eb
80102414:	e8 ac e1 ff ff       	call   801005c5 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave
8010241f:	c3                   	ret

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	f3 0f 1e fb          	endbr32
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010242a:	eb 04                	jmp    80102430 <skipelem+0x10>
    path++;
8010242c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	0f b6 00             	movzbl (%eax),%eax
80102436:	3c 2f                	cmp    $0x2f,%al
80102438:	74 f2                	je     8010242c <skipelem+0xc>
  if(*path == 0)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	0f b6 00             	movzbl (%eax),%eax
80102440:	84 c0                	test   %al,%al
80102442:	75 07                	jne    8010244b <skipelem+0x2b>
    return 0;
80102444:	b8 00 00 00 00       	mov    $0x0,%eax
80102449:	eb 77                	jmp    801024c2 <skipelem+0xa2>
  s = path;
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102451:	eb 04                	jmp    80102457 <skipelem+0x37>
    path++;
80102453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	3c 2f                	cmp    $0x2f,%al
8010245f:	74 0a                	je     8010246b <skipelem+0x4b>
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b6 00             	movzbl (%eax),%eax
80102467:	84 c0                	test   %al,%al
80102469:	75 e8                	jne    80102453 <skipelem+0x33>
  len = path - s;
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	push   -0xc(%ebp)
80102482:	ff 75 0c             	push   0xc(%ebp)
80102485:	e8 b3 27 00 00       	call   80104c3d <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 9c 27 00 00       	call   80104c3d <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave
801024c3:	c3                   	ret

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	3c 2f                	cmp    $0x2f,%al
801024d6:	75 17                	jne    801024ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024d8:	83 ec 08             	sub    $0x8,%esp
801024db:	6a 01                	push   $0x1
801024dd:	6a 01                	push   $0x1
801024df:	e8 74 f4 ff ff       	call   80101958 <iget>
801024e4:	83 c4 10             	add    $0x10,%esp
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ea:	e9 ba 00 00 00       	jmp    801025a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ef:	e8 b5 16 00 00       	call   80103ba9 <myproc>
801024f4:	8b 40 68             	mov    0x68(%eax),%eax
801024f7:	83 ec 0c             	sub    $0xc,%esp
801024fa:	50                   	push   %eax
801024fb:	e8 3e f5 ff ff       	call   80101a3e <idup>
80102500:	83 c4 10             	add    $0x10,%esp
80102503:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102506:	e9 9e 00 00 00       	jmp    801025a9 <namex+0xe5>
    ilock(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 66 f5 ff ff       	call   80101a7c <ilock>
80102516:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 18                	je     8010253e <namex+0x7a>
      iunlockput(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	push   -0xc(%ebp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
80102531:	83 c4 10             	add    $0x10,%esp
      return 0;
80102534:	b8 00 00 00 00       	mov    $0x0,%eax
80102539:	e9 a7 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010253e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102542:	74 20                	je     80102564 <namex+0xa0>
80102544:	8b 45 08             	mov    0x8(%ebp),%eax
80102547:	0f b6 00             	movzbl (%eax),%eax
8010254a:	84 c0                	test   %al,%al
8010254c:	75 16                	jne    80102564 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	push   -0xc(%ebp)
80102554:	e8 3a f6 ff ff       	call   80101b93 <iunlock>
80102559:	83 c4 10             	add    $0x10,%esp
      return ip;
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	e9 81 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 00                	push   $0x0
80102569:	ff 75 10             	push   0x10(%ebp)
8010256c:	ff 75 f4             	push   -0xc(%ebp)
8010256f:	e8 12 fd ff ff       	call   80102286 <dirlookup>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257e:	75 15                	jne    80102595 <namex+0xd1>
      iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	push   -0xc(%ebp)
80102586:	e8 2e f7 ff ff       	call   80101cb9 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
80102593:	eb 50                	jmp    801025e5 <namex+0x121>
    }
    iunlockput(ip);
80102595:	83 ec 0c             	sub    $0xc,%esp
80102598:	ff 75 f4             	push   -0xc(%ebp)
8010259b:	e8 19 f7 ff ff       	call   80101cb9 <iunlockput>
801025a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	ff 75 10             	push   0x10(%ebp)
801025af:	ff 75 08             	push   0x8(%ebp)
801025b2:	e8 69 fe ff ff       	call   80102420 <skipelem>
801025b7:	83 c4 10             	add    $0x10,%esp
801025ba:	89 45 08             	mov    %eax,0x8(%ebp)
801025bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c1:	0f 85 44 ff ff ff    	jne    8010250b <namex+0x47>
  }
  if(nameiparent){
801025c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cb:	74 15                	je     801025e2 <namex+0x11e>
    iput(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	push   -0xc(%ebp)
801025d3:	e8 0d f6 ff ff       	call   80101be5 <iput>
801025d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x121>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave
801025e6:	c3                   	ret

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	f3 0f 1e fb          	endbr32
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f7:	50                   	push   %eax
801025f8:	6a 00                	push   $0x0
801025fa:	ff 75 08             	push   0x8(%ebp)
801025fd:	e8 c2 fe ff ff       	call   801024c4 <namex>
80102602:	83 c4 10             	add    $0x10,%esp
}
80102605:	c9                   	leave
80102606:	c3                   	ret

80102607 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102607:	f3 0f 1e fb          	endbr32
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	ff 75 0c             	push   0xc(%ebp)
80102617:	6a 01                	push   $0x1
80102619:	ff 75 08             	push   0x8(%ebp)
8010261c:	e8 a3 fe ff ff       	call   801024c4 <namex>
80102621:	83 c4 10             	add    $0x10,%esp
}
80102624:	c9                   	leave
80102625:	c3                   	ret

80102626 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102626:	f3 0f 1e fb          	endbr32
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010262d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010263f:	5d                   	pop    %ebp
80102640:	c3                   	ret

80102641 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102641:	f3 0f 1e fb          	endbr32
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102648:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102657:	8b 55 0c             	mov    0xc(%ebp),%edx
8010265a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010265d:	90                   	nop
8010265e:	5d                   	pop    %ebp
8010265f:	c3                   	ret

80102660 <ioapicinit>:

void
ioapicinit(void)
{
80102660:	f3 0f 1e fb          	endbr32
80102664:	55                   	push   %ebp
80102665:	89 e5                	mov    %esp,%ebp
80102667:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010266a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102671:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102674:	6a 01                	push   $0x1
80102676:	e8 ab ff ff ff       	call   80102626 <ioapicread>
8010267b:	83 c4 04             	add    $0x4,%esp
8010267e:	c1 e8 10             	shr    $0x10,%eax
80102681:	25 ff 00 00 00       	and    $0xff,%eax
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102689:	6a 00                	push   $0x0
8010268b:	e8 96 ff ff ff       	call   80102626 <ioapicread>
80102690:	83 c4 04             	add    $0x4,%esp
80102693:	c1 e8 18             	shr    $0x18,%eax
80102696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102699:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 f4 a5 10 80       	push   $0x8010a5f4
801026b0:	e8 57 dd ff ff       	call   8010040c <cprintf>
801026b5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bf:	eb 3f                	jmp    80102700 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c4:	83 c0 20             	add    $0x20,%eax
801026c7:	0d 00 00 01 00       	or     $0x10000,%eax
801026cc:	89 c2                	mov    %eax,%edx
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	83 c0 08             	add    $0x8,%eax
801026d4:	01 c0                	add    %eax,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	52                   	push   %edx
801026da:	50                   	push   %eax
801026db:	e8 61 ff ff ff       	call   80102641 <ioapicwrite>
801026e0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e6:	83 c0 08             	add    $0x8,%eax
801026e9:	01 c0                	add    %eax,%eax
801026eb:	83 c0 01             	add    $0x1,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	6a 00                	push   $0x0
801026f3:	50                   	push   %eax
801026f4:	e8 48 ff ff ff       	call   80102641 <ioapicwrite>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102706:	7e b9                	jle    801026c1 <ioapicinit+0x61>
  }
}
80102708:	90                   	nop
80102709:	90                   	nop
8010270a:	c9                   	leave
8010270b:	c3                   	ret

8010270c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010270c:	f3 0f 1e fb          	endbr32
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	83 c0 20             	add    $0x20,%eax
80102719:	89 c2                	mov    %eax,%edx
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	83 c0 08             	add    $0x8,%eax
80102721:	01 c0                	add    %eax,%eax
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 17 ff ff ff       	call   80102641 <ioapicwrite>
8010272a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010272d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102730:	c1 e0 18             	shl    $0x18,%eax
80102733:	89 c2                	mov    %eax,%edx
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	83 c0 08             	add    $0x8,%eax
8010273b:	01 c0                	add    %eax,%eax
8010273d:	83 c0 01             	add    $0x1,%eax
80102740:	52                   	push   %edx
80102741:	50                   	push   %eax
80102742:	e8 fa fe ff ff       	call   80102641 <ioapicwrite>
80102747:	83 c4 08             	add    $0x8,%esp
}
8010274a:	90                   	nop
8010274b:	c9                   	leave
8010274c:	c3                   	ret

8010274d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010274d:	f3 0f 1e fb          	endbr32
80102751:	55                   	push   %ebp
80102752:	89 e5                	mov    %esp,%ebp
80102754:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	68 26 a6 10 80       	push   $0x8010a626
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 58 21 00 00       	call   801048c1 <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102773:	00 00 00 
  freerange(vstart, vend);
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	ff 75 0c             	push   0xc(%ebp)
8010277c:	ff 75 08             	push   0x8(%ebp)
8010277f:	e8 2e 00 00 00       	call   801027b2 <freerange>
80102784:	83 c4 10             	add    $0x10,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave
80102789:	c3                   	ret

8010278a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	ff 75 0c             	push   0xc(%ebp)
8010279a:	ff 75 08             	push   0x8(%ebp)
8010279d:	e8 10 00 00 00       	call   801027b2 <freerange>
801027a2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027a5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027ac:	00 00 00 
}
801027af:	90                   	nop
801027b0:	c9                   	leave
801027b1:	c3                   	ret

801027b2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027b2:	f3 0f 1e fb          	endbr32
801027b6:	55                   	push   %ebp
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027cc:	eb 15                	jmp    801027e3 <freerange+0x31>
    kfree(p);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	ff 75 f4             	push   -0xc(%ebp)
801027d4:	e8 1b 00 00 00       	call   801027f4 <kfree>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	05 00 10 00 00       	add    $0x1000,%eax
801027eb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027ee:	73 de                	jae    801027ce <freerange+0x1c>
}
801027f0:	90                   	nop
801027f1:	90                   	nop
801027f2:	c9                   	leave
801027f3:	c3                   	ret

801027f4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f4:	f3 0f 1e fb          	endbr32
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	25 ff 0f 00 00       	and    $0xfff,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 18                	jne    80102822 <kfree+0x2e>
8010280a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 2b a6 10 80       	push   $0x8010a62b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 35 23 00 00       	call   80104b76 <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 8d 20 00 00       	call   801048e7 <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102876:	a1 14 54 19 80       	mov    0x80195414,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 e0 53 19 80       	push   $0x801953e0
80102887:	e8 cd 20 00 00       	call   80104959 <release>
8010288c:	83 c4 10             	add    $0x10,%esp
}
8010288f:	90                   	nop
80102890:	c9                   	leave
80102891:	c3                   	ret

80102892 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102892:	f3 0f 1e fb          	endbr32
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010289c:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 e0 53 19 80       	push   $0x801953e0
801028ad:	e8 35 20 00 00       	call   801048e7 <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 e0 53 19 80       	push   $0x801953e0
801028de:	e8 76 20 00 00       	call   80104959 <release>
801028e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028e9:	c9                   	leave
801028ea:	c3                   	ret

801028eb <inb>:
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 14             	sub    $0x14,%esp
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028fc:	89 c2                	mov    %eax,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102902:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102906:	c9                   	leave
80102907:	c3                   	ret

80102908 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102908:	f3 0f 1e fb          	endbr32
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
8010290f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102912:	6a 64                	push   $0x64
80102914:	e8 d2 ff ff ff       	call   801028eb <inb>
80102919:	83 c4 04             	add    $0x4,%esp
8010291c:	0f b6 c0             	movzbl %al,%eax
8010291f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 e0 01             	and    $0x1,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	75 0a                	jne    80102936 <kbdgetc+0x2e>
    return -1;
8010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102931:	e9 23 01 00 00       	jmp    80102a59 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102936:	6a 60                	push   $0x60
80102938:	e8 ae ff ff ff       	call   801028eb <inb>
8010293d:	83 c4 04             	add    $0x4,%esp
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102946:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010294d:	75 17                	jne    80102966 <kbdgetc+0x5e>
    shift |= E0ESC;
8010294f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010295c:	b8 00 00 00 00       	mov    $0x0,%eax
80102961:	e9 f3 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(data & 0x80){
80102966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102969:	25 80 00 00 00       	and    $0x80,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 45                	je     801029b7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102972:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102977:	83 e0 40             	and    $0x40,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	75 08                	jne    80102986 <kbdgetc+0x7e>
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	83 e0 7f             	and    $0x7f,%eax
80102984:	eb 03                	jmp    80102989 <kbdgetc+0x81>
80102986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102989:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010298c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 08             	and    $0x8,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 22                	je     80102a56 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a34:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a38:	76 0c                	jbe    80102a46 <kbdgetc+0x13e>
80102a3a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a3e:	77 06                	ja     80102a46 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a40:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a44:	eb 10                	jmp    80102a56 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a46:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a4a:	76 0a                	jbe    80102a56 <kbdgetc+0x14e>
80102a4c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a50:	77 04                	ja     80102a56 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a52:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a59:	c9                   	leave
80102a5a:	c3                   	ret

80102a5b <kbdintr>:

void
kbdintr(void)
{
80102a5b:	f3 0f 1e fb          	endbr32
80102a5f:	55                   	push   %ebp
80102a60:	89 e5                	mov    %esp,%ebp
80102a62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 08 29 10 80       	push   $0x80102908
80102a6d:	e8 8e dd ff ff       	call   80100800 <consoleintr>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	90                   	nop
80102a76:	c9                   	leave
80102a77:	c3                   	ret

80102a78 <inb>:
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 14             	sub    $0x14,%esp
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a89:	89 c2                	mov    %eax,%edx
80102a8b:	ec                   	in     (%dx),%al
80102a8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a93:	c9                   	leave
80102a94:	c3                   	ret

80102a95 <outb>:
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 08             	sub    $0x8,%esp
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102aa5:	89 d0                	mov    %edx,%eax
80102aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ab2:	ee                   	out    %al,(%dx)
}
80102ab3:	90                   	nop
80102ab4:	c9                   	leave
80102ab5:	c3                   	ret

80102ab6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ab6:	f3 0f 1e fb          	endbr32
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102abd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	8b 00                	mov    (%eax),%eax
}
80102ad9:	90                   	nop
80102ada:	5d                   	pop    %ebp
80102adb:	c3                   	ret

80102adc <lapicinit>:

void
lapicinit(void)
{
80102adc:	f3 0f 1e fb          	endbr32
80102ae0:	55                   	push   %ebp
80102ae1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ae3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	0f 84 0c 01 00 00    	je     80102bfc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102af0:	68 3f 01 00 00       	push   $0x13f
80102af5:	6a 3c                	push   $0x3c
80102af7:	e8 ba ff ff ff       	call   80102ab6 <lapicw>
80102afc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102aff:	6a 0b                	push   $0xb
80102b01:	68 f8 00 00 00       	push   $0xf8
80102b06:	e8 ab ff ff ff       	call   80102ab6 <lapicw>
80102b0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b0e:	68 20 00 02 00       	push   $0x20020
80102b13:	68 c8 00 00 00       	push   $0xc8
80102b18:	e8 99 ff ff ff       	call   80102ab6 <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b20:	68 80 96 98 00       	push   $0x989680
80102b25:	68 e0 00 00 00       	push   $0xe0
80102b2a:	e8 87 ff ff ff       	call   80102ab6 <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b32:	68 00 00 01 00       	push   $0x10000
80102b37:	68 d4 00 00 00       	push   $0xd4
80102b3c:	e8 75 ff ff ff       	call   80102ab6 <lapicw>
80102b41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b44:	68 00 00 01 00       	push   $0x10000
80102b49:	68 d8 00 00 00       	push   $0xd8
80102b4e:	e8 63 ff ff ff       	call   80102ab6 <lapicw>
80102b53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b56:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b5b:	83 c0 30             	add    $0x30,%eax
80102b5e:	8b 00                	mov    (%eax),%eax
80102b60:	c1 e8 10             	shr    $0x10,%eax
80102b63:	25 fc 00 00 00       	and    $0xfc,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 12                	je     80102b7e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b6c:	68 00 00 01 00       	push   $0x10000
80102b71:	68 d0 00 00 00       	push   $0xd0
80102b76:	e8 3b ff ff ff       	call   80102ab6 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b7e:	6a 33                	push   $0x33
80102b80:	68 dc 00 00 00       	push   $0xdc
80102b85:	e8 2c ff ff ff       	call   80102ab6 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b8d:	6a 00                	push   $0x0
80102b8f:	68 a0 00 00 00       	push   $0xa0
80102b94:	e8 1d ff ff ff       	call   80102ab6 <lapicw>
80102b99:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b9c:	6a 00                	push   $0x0
80102b9e:	68 a0 00 00 00       	push   $0xa0
80102ba3:	e8 0e ff ff ff       	call   80102ab6 <lapicw>
80102ba8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bab:	6a 00                	push   $0x0
80102bad:	6a 2c                	push   $0x2c
80102baf:	e8 02 ff ff ff       	call   80102ab6 <lapicw>
80102bb4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bb7:	6a 00                	push   $0x0
80102bb9:	68 c4 00 00 00       	push   $0xc4
80102bbe:	e8 f3 fe ff ff       	call   80102ab6 <lapicw>
80102bc3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bc6:	68 00 85 08 00       	push   $0x88500
80102bcb:	68 c0 00 00 00       	push   $0xc0
80102bd0:	e8 e1 fe ff ff       	call   80102ab6 <lapicw>
80102bd5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bd8:	90                   	nop
80102bd9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bde:	05 00 03 00 00       	add    $0x300,%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	25 00 10 00 00       	and    $0x1000,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 eb                	jne    80102bd9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bee:	6a 00                	push   $0x0
80102bf0:	6a 20                	push   $0x20
80102bf2:	e8 bf fe ff ff       	call   80102ab6 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
80102bfa:	eb 01                	jmp    80102bfd <lapicinit+0x121>
    return;
80102bfc:	90                   	nop
}
80102bfd:	c9                   	leave
80102bfe:	c3                   	ret

80102bff <lapicid>:

int
lapicid(void)
{
80102bff:	f3 0f 1e fb          	endbr32
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c06:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	83 c0 20             	add    $0x20,%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	c1 e8 18             	shr    $0x18,%eax
}
80102c23:	5d                   	pop    %ebp
80102c24:	c3                   	ret

80102c25 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c25:	f3 0f 1e fb          	endbr32
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c2c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 0c                	je     80102c41 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c35:	6a 00                	push   $0x0
80102c37:	6a 2c                	push   $0x2c
80102c39:	e8 78 fe ff ff       	call   80102ab6 <lapicw>
80102c3e:	83 c4 08             	add    $0x8,%esp
}
80102c41:	90                   	nop
80102c42:	c9                   	leave
80102c43:	c3                   	ret

80102c44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c44:	f3 0f 1e fb          	endbr32
80102c48:	55                   	push   %ebp
80102c49:	89 e5                	mov    %esp,%ebp
}
80102c4b:	90                   	nop
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret

80102c4e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c4e:	f3 0f 1e fb          	endbr32
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 14             	sub    $0x14,%esp
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c5e:	6a 0f                	push   $0xf
80102c60:	6a 70                	push   $0x70
80102c62:	e8 2e fe ff ff       	call   80102a95 <outb>
80102c67:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c6a:	6a 0a                	push   $0xa
80102c6c:	6a 71                	push   $0x71
80102c6e:	e8 22 fe ff ff       	call   80102a95 <outb>
80102c73:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c76:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c80:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c88:	c1 e8 04             	shr    $0x4,%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	83 c0 02             	add    $0x2,%eax
80102c93:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c96:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c9a:	c1 e0 18             	shl    $0x18,%eax
80102c9d:	50                   	push   %eax
80102c9e:	68 c4 00 00 00       	push   $0xc4
80102ca3:	e8 0e fe ff ff       	call   80102ab6 <lapicw>
80102ca8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cab:	68 00 c5 00 00       	push   $0xc500
80102cb0:	68 c0 00 00 00       	push   $0xc0
80102cb5:	e8 fc fd ff ff       	call   80102ab6 <lapicw>
80102cba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cbd:	68 c8 00 00 00       	push   $0xc8
80102cc2:	e8 7d ff ff ff       	call   80102c44 <microdelay>
80102cc7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cca:	68 00 85 00 00       	push   $0x8500
80102ccf:	68 c0 00 00 00       	push   $0xc0
80102cd4:	e8 dd fd ff ff       	call   80102ab6 <lapicw>
80102cd9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cdc:	6a 64                	push   $0x64
80102cde:	e8 61 ff ff ff       	call   80102c44 <microdelay>
80102ce3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ce6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ced:	eb 3d                	jmp    80102d2c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf3:	c1 e0 18             	shl    $0x18,%eax
80102cf6:	50                   	push   %eax
80102cf7:	68 c4 00 00 00       	push   $0xc4
80102cfc:	e8 b5 fd ff ff       	call   80102ab6 <lapicw>
80102d01:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d07:	c1 e8 0c             	shr    $0xc,%eax
80102d0a:	80 cc 06             	or     $0x6,%ah
80102d0d:	50                   	push   %eax
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 9e fd ff ff       	call   80102ab6 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 1f ff ff ff       	call   80102c44 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d2c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d30:	7e bd                	jle    80102cef <lapicstartap+0xa1>
  }
}
80102d32:	90                   	nop
80102d33:	90                   	nop
80102d34:	c9                   	leave
80102d35:	c3                   	ret

80102d36 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d36:	f3 0f 1e fb          	endbr32
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d40:	0f b6 c0             	movzbl %al,%eax
80102d43:	50                   	push   %eax
80102d44:	6a 70                	push   $0x70
80102d46:	e8 4a fd ff ff       	call   80102a95 <outb>
80102d4b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d4e:	68 c8 00 00 00       	push   $0xc8
80102d53:	e8 ec fe ff ff       	call   80102c44 <microdelay>
80102d58:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d5b:	6a 71                	push   $0x71
80102d5d:	e8 16 fd ff ff       	call   80102a78 <inb>
80102d62:	83 c4 04             	add    $0x4,%esp
80102d65:	0f b6 c0             	movzbl %al,%eax
}
80102d68:	c9                   	leave
80102d69:	c3                   	ret

80102d6a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d6a:	f3 0f 1e fb          	endbr32
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d71:	6a 00                	push   $0x0
80102d73:	e8 be ff ff ff       	call   80102d36 <cmos_read>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d80:	6a 02                	push   $0x2
80102d82:	e8 af ff ff ff       	call   80102d36 <cmos_read>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d90:	6a 04                	push   $0x4
80102d92:	e8 9f ff ff ff       	call   80102d36 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102da0:	6a 07                	push   $0x7
80102da2:	e8 8f ff ff ff       	call   80102d36 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102db0:	6a 08                	push   $0x8
80102db2:	e8 7f ff ff ff       	call   80102d36 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dc0:	6a 09                	push   $0x9
80102dc2:	e8 6f ff ff ff       	call   80102d36 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dd0:	90                   	nop
80102dd1:	c9                   	leave
80102dd2:	c3                   	ret

80102dd3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dd3:	f3 0f 1e fb          	endbr32
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ddd:	6a 0b                	push   $0xb
80102ddf:	e8 52 ff ff ff       	call   80102d36 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ded:	83 e0 04             	and    $0x4,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	0f 94 c0             	sete   %al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102dfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102dfe:	50                   	push   %eax
80102dff:	e8 66 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e04:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e07:	6a 0a                	push   $0xa
80102e09:	e8 28 ff ff ff       	call   80102d36 <cmos_read>
80102e0e:	83 c4 04             	add    $0x4,%esp
80102e11:	25 80 00 00 00       	and    $0x80,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	75 27                	jne    80102e41 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e1a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e1d:	50                   	push   %eax
80102e1e:	e8 47 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e23:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e26:	83 ec 04             	sub    $0x4,%esp
80102e29:	6a 18                	push   $0x18
80102e2b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2e:	50                   	push   %eax
80102e2f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e32:	50                   	push   %eax
80102e33:	e8 a9 1d 00 00       	call   80104be1 <memcmp>
80102e38:	83 c4 10             	add    $0x10,%esp
80102e3b:	85 c0                	test   %eax,%eax
80102e3d:	74 05                	je     80102e44 <cmostime+0x71>
80102e3f:	eb ba                	jmp    80102dfb <cmostime+0x28>
        continue;
80102e41:	90                   	nop
    fill_rtcdate(&t1);
80102e42:	eb b7                	jmp    80102dfb <cmostime+0x28>
      break;
80102e44:	90                   	nop
  }

  // convert
  if(bcd) {
80102e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e49:	0f 84 b4 00 00 00    	je     80102f03 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e52:	c1 e8 04             	shr    $0x4,%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	89 d0                	mov    %edx,%eax
80102e59:	c1 e0 02             	shl    $0x2,%eax
80102e5c:	01 d0                	add    %edx,%eax
80102e5e:	01 c0                	add    %eax,%eax
80102e60:	89 c2                	mov    %eax,%edx
80102e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e65:	83 e0 0f             	and    $0xf,%eax
80102e68:	01 d0                	add    %edx,%eax
80102e6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e70:	c1 e8 04             	shr    $0x4,%eax
80102e73:	89 c2                	mov    %eax,%edx
80102e75:	89 d0                	mov    %edx,%eax
80102e77:	c1 e0 02             	shl    $0x2,%eax
80102e7a:	01 d0                	add    %edx,%eax
80102e7c:	01 c0                	add    %eax,%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e83:	83 e0 0f             	and    $0xf,%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e8e:	c1 e8 04             	shr    $0x4,%eax
80102e91:	89 c2                	mov    %eax,%edx
80102e93:	89 d0                	mov    %edx,%eax
80102e95:	c1 e0 02             	shl    $0x2,%eax
80102e98:	01 d0                	add    %edx,%eax
80102e9a:	01 c0                	add    %eax,%eax
80102e9c:	89 c2                	mov    %eax,%edx
80102e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ea1:	83 e0 0f             	and    $0xf,%eax
80102ea4:	01 d0                	add    %edx,%eax
80102ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eac:	c1 e8 04             	shr    $0x4,%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	89 d0                	mov    %edx,%eax
80102eb3:	c1 e0 02             	shl    $0x2,%eax
80102eb6:	01 d0                	add    %edx,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	89 c2                	mov    %eax,%edx
80102ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	01 d0                	add    %edx,%eax
80102ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eca:	c1 e8 04             	shr    $0x4,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	89 d0                	mov    %edx,%eax
80102ed1:	c1 e0 02             	shl    $0x2,%eax
80102ed4:	01 d0                	add    %edx,%eax
80102ed6:	01 c0                	add    %eax,%eax
80102ed8:	89 c2                	mov    %eax,%edx
80102eda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102edd:	83 e0 0f             	and    $0xf,%eax
80102ee0:	01 d0                	add    %edx,%eax
80102ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ee8:	c1 e8 04             	shr    $0x4,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	89 d0                	mov    %edx,%eax
80102eef:	c1 e0 02             	shl    $0x2,%eax
80102ef2:	01 d0                	add    %edx,%eax
80102ef4:	01 c0                	add    %eax,%eax
80102ef6:	89 c2                	mov    %eax,%edx
80102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102efb:	83 e0 0f             	and    $0xf,%eax
80102efe:	01 d0                	add    %edx,%eax
80102f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f09:	89 10                	mov    %edx,(%eax)
80102f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f0e:	89 50 04             	mov    %edx,0x4(%eax)
80102f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f14:	89 50 08             	mov    %edx,0x8(%eax)
80102f17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f1a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f20:	89 50 10             	mov    %edx,0x10(%eax)
80102f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f26:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 40 14             	mov    0x14(%eax),%eax
80102f2f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave
80102f3d:	c3                   	ret

80102f3e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f3e:	f3 0f 1e fb          	endbr32
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
80102f45:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	68 31 a6 10 80       	push   $0x8010a631
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 67 19 00 00       	call   801048c1 <initlock>
80102f5a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f5d:	83 ec 08             	sub    $0x8,%esp
80102f60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f63:	50                   	push   %eax
80102f64:	ff 75 08             	push   0x8(%ebp)
80102f67:	e8 c0 e4 ff ff       	call   8010142c <readsb>
80102f6c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f87:	e8 bf 01 00 00       	call   8010314b <recover_from_log>
}
80102f8c:	90                   	nop
80102f8d:	c9                   	leave
80102f8e:	c3                   	ret

80102f8f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f8f:	f3 0f 1e fb          	endbr32
80102f93:	55                   	push   %ebp
80102f94:	89 e5                	mov    %esp,%ebp
80102f96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fa0:	e9 95 00 00 00       	jmp    8010303a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fa5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fde:	83 ec 08             	sub    $0x8,%esp
80102fe1:	52                   	push   %edx
80102fe2:	50                   	push   %eax
80102fe3:	e8 21 d2 ff ff       	call   80100209 <bread>
80102fe8:	83 c4 10             	add    $0x10,%esp
80102feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ff1:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff7:	83 c0 5c             	add    $0x5c,%eax
80102ffa:	83 ec 04             	sub    $0x4,%esp
80102ffd:	68 00 02 00 00       	push   $0x200
80103002:	52                   	push   %edx
80103003:	50                   	push   %eax
80103004:	e8 34 1c 00 00       	call   80104c3d <memmove>
80103009:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 ec             	push   -0x14(%ebp)
80103012:	e8 2f d2 ff ff       	call   80100246 <bwrite>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 f0             	push   -0x10(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103028:	83 ec 0c             	sub    $0xc,%esp
8010302b:	ff 75 ec             	push   -0x14(%ebp)
8010302e:	e8 60 d2 ff ff       	call   80100293 <brelse>
80103033:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010303a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010303f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103042:	0f 8c 5d ff ff ff    	jl     80102fa5 <install_trans+0x16>
  }
}
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	c9                   	leave
8010304b:	c3                   	ret

8010304c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010304c:	f3 0f 1e fb          	endbr32
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103056:	a1 54 54 19 80       	mov    0x80195454,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103062:	83 ec 08             	sub    $0x8,%esp
80103065:	52                   	push   %edx
80103066:	50                   	push   %eax
80103067:	e8 9d d1 ff ff       	call   80100209 <bread>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103075:	83 c0 5c             	add    $0x5c,%eax
80103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010307b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307e:	8b 00                	mov    (%eax),%eax
80103080:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b1:	7c db                	jl     8010308e <read_head+0x42>
  }
  brelse(buf);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	ff 75 f0             	push   -0x10(%ebp)
801030b9:	e8 d5 d1 ff ff       	call   80100293 <brelse>
801030be:	83 c4 10             	add    $0x10,%esp
}
801030c1:	90                   	nop
801030c2:	c9                   	leave
801030c3:	c3                   	ret

801030c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030c4:	f3 0f 1e fb          	endbr32
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ce:	a1 54 54 19 80       	mov    0x80195454,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	52                   	push   %edx
801030de:	50                   	push   %eax
801030df:	e8 25 d1 ff ff       	call   80100209 <bread>
801030e4:	83 c4 10             	add    $0x10,%esp
801030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ed:	83 c0 5c             	add    $0x5c,%eax
801030f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030f3:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 68 54 19 80       	mov    0x80195468,%eax
80103127:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010312a:	7c db                	jl     80103107 <write_head+0x43>
  }
  bwrite(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	push   -0x10(%ebp)
80103132:	e8 0f d1 ff ff       	call   80100246 <bwrite>
80103137:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	ff 75 f0             	push   -0x10(%ebp)
80103140:	e8 4e d1 ff ff       	call   80100293 <brelse>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	90                   	nop
80103149:	c9                   	leave
8010314a:	c3                   	ret

8010314b <recover_from_log>:

static void
recover_from_log(void)
{
8010314b:	f3 0f 1e fb          	endbr32
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
80103152:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103155:	e8 f2 fe ff ff       	call   8010304c <read_head>
  install_trans(); // if committed, copy from log to disk
8010315a:	e8 30 fe ff ff       	call   80102f8f <install_trans>
  log.lh.n = 0;
8010315f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103166:	00 00 00 
  write_head(); // clear the log
80103169:	e8 56 ff ff ff       	call   801030c4 <write_head>
}
8010316e:	90                   	nop
8010316f:	c9                   	leave
80103170:	c3                   	ret

80103171 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103171:	f3 0f 1e fb          	endbr32
80103175:	55                   	push   %ebp
80103176:	89 e5                	mov    %esp,%ebp
80103178:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 54 19 80       	push   $0x80195420
80103183:	e8 5f 17 00 00       	call   801048e7 <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 60 54 19 80       	mov    0x80195460,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 20 54 19 80       	push   $0x80195420
8010319c:	68 20 54 19 80       	push   $0x80195420
801031a1:	e8 fe 12 00 00       	call   801044a4 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031b1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031b6:	8d 50 01             	lea    0x1(%eax),%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	01 c8                	add    %ecx,%eax
801031c4:	83 f8 1e             	cmp    $0x1e,%eax
801031c7:	7e 17                	jle    801031e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031c9:	83 ec 08             	sub    $0x8,%esp
801031cc:	68 20 54 19 80       	push   $0x80195420
801031d1:	68 20 54 19 80       	push   $0x80195420
801031d6:	e8 c9 12 00 00       	call   801044a4 <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 20 54 19 80       	push   $0x80195420
801031f5:	e8 5f 17 00 00       	call   80104959 <release>
801031fa:	83 c4 10             	add    $0x10,%esp
      break;
801031fd:	90                   	nop
    }
  }
}
801031fe:	90                   	nop
801031ff:	c9                   	leave
80103200:	c3                   	ret

80103201 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103201:	f3 0f 1e fb          	endbr32
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010320b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	68 20 54 19 80       	push   $0x80195420
8010321a:	e8 c8 16 00 00       	call   801048e7 <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010322f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 35 a6 10 80       	push   $0x8010a635
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 20 54 19 80       	push   $0x80195420
80103269:	e8 25 13 00 00       	call   80104593 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 db 16 00 00       	call   80104959 <release>
8010327e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103285:	74 3f                	je     801032c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103287:	e8 fa 00 00 00       	call   80103386 <commit>
    acquire(&log.lock);
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 20 54 19 80       	push   $0x80195420
80103294:	e8 4e 16 00 00       	call   801048e7 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 e0 12 00 00       	call   80104593 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 96 16 00 00       	call   80104959 <release>
801032c3:	83 c4 10             	add    $0x10,%esp
  }
}
801032c6:	90                   	nop
801032c7:	c9                   	leave
801032c8:	c3                   	ret

801032c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032c9:	f3 0f 1e fb          	endbr32
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032da:	e9 95 00 00 00       	jmp    80103374 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032df:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 64 54 19 80       	mov    0x80195464,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 64 54 19 80       	mov    0x80195464,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 e7 ce ff ff       	call   80100209 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103331:	83 c0 5c             	add    $0x5c,%eax
80103334:	83 ec 04             	sub    $0x4,%esp
80103337:	68 00 02 00 00       	push   $0x200
8010333c:	52                   	push   %edx
8010333d:	50                   	push   %eax
8010333e:	e8 fa 18 00 00       	call   80104c3d <memmove>
80103343:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 f0             	push   -0x10(%ebp)
8010334c:	e8 f5 ce ff ff       	call   80100246 <bwrite>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 ec             	push   -0x14(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103362:	83 ec 0c             	sub    $0xc,%esp
80103365:	ff 75 f0             	push   -0x10(%ebp)
80103368:	e8 26 cf ff ff       	call   80100293 <brelse>
8010336d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103374:	a1 68 54 19 80       	mov    0x80195468,%eax
80103379:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010337c:	0f 8c 5d ff ff ff    	jl     801032df <write_log+0x16>
  }
}
80103382:	90                   	nop
80103383:	90                   	nop
80103384:	c9                   	leave
80103385:	c3                   	ret

80103386 <commit>:

static void
commit()
{
80103386:	f3 0f 1e fb          	endbr32
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103390:	a1 68 54 19 80       	mov    0x80195468,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033af:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b2:	e8 0d fd ff ff       	call   801030c4 <write_head>
  }
}
801033b7:	90                   	nop
801033b8:	c9                   	leave
801033b9:	c3                   	ret

801033ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ba:	f3 0f 1e fb          	endbr32
801033be:	55                   	push   %ebp
801033bf:	89 e5                	mov    %esp,%ebp
801033c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033c4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 44 a6 10 80       	push   $0x8010a644
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 5a a6 10 80       	push   $0x8010a65a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 d7 14 00 00       	call   801048e7 <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 68 54 19 80       	mov    0x80195468,%eax
8010343e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103441:	7c d9                	jl     8010341c <log_write+0x62>
80103443:	eb 01                	jmp    80103446 <log_write+0x8c>
      break;
80103445:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	8b 40 08             	mov    0x8(%eax),%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 68 54 19 80       	mov    0x80195468,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 20 54 19 80       	push   $0x80195420
80103489:	e8 cb 14 00 00       	call   80104959 <release>
8010348e:	83 c4 10             	add    $0x10,%esp
}
80103491:	90                   	nop
80103492:	c9                   	leave
80103493:	c3                   	ret

80103494 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010349a:	8b 55 08             	mov    0x8(%ebp),%edx
8010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034a3:	f0 87 02             	lock xchg %eax,(%edx)
801034a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034ac:	c9                   	leave
801034ad:	c3                   	ret

801034ae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034ae:	f3 0f 1e fb          	endbr32
801034b2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034b6:	83 e4 f0             	and    $0xfffffff0,%esp
801034b9:	ff 71 fc             	push   -0x4(%ecx)
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	51                   	push   %ecx
801034c0:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034c3:	e8 1f 4c 00 00       	call   801080e7 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 e2 41 00 00       	call   801076c4 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 b9 49 00 00       	call   80107ea0 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 5a 3c 00 00       	call   8010714b <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 cf 2f 00 00       	call   801064d4 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 0a 2b 00 00       	call   80106019 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 ce 6d 00 00       	call   8010a2ec <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 1d 4e 00 00       	call   8010835a <pci_init>
  arp_scan();
8010353d:	e8 96 5b 00 00       	call   801090d8 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 9b 07 00 00       	call   80103ce2 <userinit>

  mpmain();        // finish this processor's setup
80103547:	e8 1e 00 00 00       	call   8010356a <mpmain>

8010354c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010354c:	f3 0f 1e fb          	endbr32
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103556:	e8 85 41 00 00       	call   801076e0 <switchkvm>
  seginit();
8010355b:	e8 eb 3b 00 00       	call   8010714b <seginit>
  lapicinit();
80103560:	e8 77 f5 ff ff       	call   80102adc <lapicinit>
  mpmain();
80103565:	e8 00 00 00 00       	call   8010356a <mpmain>

8010356a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010356a:	f3 0f 1e fb          	endbr32
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103575:	e8 94 05 00 00       	call   80103b0e <cpuid>
8010357a:	89 c3                	mov    %eax,%ebx
8010357c:	e8 8d 05 00 00       	call   80103b0e <cpuid>
80103581:	83 ec 04             	sub    $0x4,%esp
80103584:	53                   	push   %ebx
80103585:	50                   	push   %eax
80103586:	68 75 a6 10 80       	push   $0x8010a675
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 fb 2b 00 00       	call   80106193 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 cc 0c 00 00       	call   80104281 <scheduler>

801035b5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035b5:	f3 0f 1e fb          	endbr32
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035bf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035cb:	83 ec 04             	sub    $0x4,%esp
801035ce:	50                   	push   %eax
801035cf:	68 18 f5 10 80       	push   $0x8010f518
801035d4:	ff 75 f0             	push   -0x10(%ebp)
801035d7:	e8 61 16 00 00       	call   80104c3d <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
801035e6:	eb 79                	jmp    80103661 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035e8:	e8 40 05 00 00       	call   80103b2d <mycpu>
801035ed:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035f0:	74 67                	je     80103659 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035f2:	e8 9b f2 ff ff       	call   80102892 <kalloc>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	83 e8 04             	sub    $0x4,%eax
80103600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103603:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103609:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 e8 08             	sub    $0x8,%eax
80103611:	c7 00 4c 35 10 80    	movl   $0x8010354c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103617:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010361c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103625:	83 e8 0c             	sub    $0xc,%eax
80103628:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103636:	0f b6 00             	movzbl (%eax),%eax
80103639:	0f b6 c0             	movzbl %al,%eax
8010363c:	83 ec 08             	sub    $0x8,%esp
8010363f:	52                   	push   %edx
80103640:	50                   	push   %eax
80103641:	e8 08 f6 ff ff       	call   80102c4e <lapicstartap>
80103646:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103649:	90                   	nop
8010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103653:	85 c0                	test   %eax,%eax
80103655:	74 f3                	je     8010364a <startothers+0x95>
80103657:	eb 01                	jmp    8010365a <startothers+0xa5>
      continue;
80103659:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010365a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103661:	a1 80 80 19 80       	mov    0x80198080,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103671:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103674:	0f 82 6e ff ff ff    	jb     801035e8 <startothers+0x33>
      ;
  }
}
8010367a:	90                   	nop
8010367b:	90                   	nop
8010367c:	c9                   	leave
8010367d:	c3                   	ret

8010367e <outb>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 08             	sub    $0x8,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010368a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010368e:	89 d0                	mov    %edx,%eax
80103690:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103693:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103697:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369b:	ee                   	out    %al,(%dx)
}
8010369c:	90                   	nop
8010369d:	c9                   	leave
8010369e:	c3                   	ret

8010369f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010369f:	f3 0f 1e fb          	endbr32
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036a6:	68 ff 00 00 00       	push   $0xff
801036ab:	6a 21                	push   $0x21
801036ad:	e8 cc ff ff ff       	call   8010367e <outb>
801036b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036b5:	68 ff 00 00 00       	push   $0xff
801036ba:	68 a1 00 00 00       	push   $0xa1
801036bf:	e8 ba ff ff ff       	call   8010367e <outb>
801036c4:	83 c4 08             	add    $0x8,%esp
}
801036c7:	90                   	nop
801036c8:	c9                   	leave
801036c9:	c3                   	ret

801036ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036ca:	f3 0f 1e fb          	endbr32
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036db:	8b 45 0c             	mov    0xc(%ebp),%eax
801036de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036e7:	8b 10                	mov    (%eax),%edx
801036e9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ec:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036ee:	e8 30 d9 ff ff       	call   80101023 <filealloc>
801036f3:	8b 55 08             	mov    0x8(%ebp),%edx
801036f6:	89 02                	mov    %eax,(%edx)
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	8b 00                	mov    (%eax),%eax
801036fd:	85 c0                	test   %eax,%eax
801036ff:	0f 84 c8 00 00 00    	je     801037cd <pipealloc+0x103>
80103705:	e8 19 d9 ff ff       	call   80101023 <filealloc>
8010370a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370d:	89 02                	mov    %eax,(%edx)
8010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103712:	8b 00                	mov    (%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	0f 84 b1 00 00 00    	je     801037cd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010371c:	e8 71 f1 ff ff       	call   80102892 <kalloc>
80103721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103728:	0f 84 a2 00 00 00    	je     801037d0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103731:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103738:	00 00 00 
  p->writeopen = 1;
8010373b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103745:	00 00 00 
  p->nwrite = 0;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103752:	00 00 00 
  p->nread = 0;
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010375f:	00 00 00 
  initlock(&p->lock, "pipe");
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	83 ec 08             	sub    $0x8,%esp
80103768:	68 89 a6 10 80       	push   $0x8010a689
8010376d:	50                   	push   %eax
8010376e:	e8 4e 11 00 00       	call   801048c1 <initlock>
80103773:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	8b 00                	mov    (%eax),%eax
8010377b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103781:	8b 45 08             	mov    0x8(%ebp),%eax
80103784:	8b 00                	mov    (%eax),%eax
80103786:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	8b 00                	mov    (%eax),%eax
8010378f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	8b 00                	mov    (%eax),%eax
80103798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010379b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010379e:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a1:	8b 00                	mov    (%eax),%eax
801037a3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ac:	8b 00                	mov    (%eax),%eax
801037ae:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037be:	8b 00                	mov    (%eax),%eax
801037c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037c6:	b8 00 00 00 00       	mov    $0x0,%eax
801037cb:	eb 51                	jmp    8010381e <pipealloc+0x154>
    goto bad;
801037cd:	90                   	nop
801037ce:	eb 01                	jmp    801037d1 <pipealloc+0x107>
    goto bad;
801037d0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037d5:	74 0e                	je     801037e5 <pipealloc+0x11b>
    kfree((char*)p);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	ff 75 f4             	push   -0xc(%ebp)
801037dd:	e8 12 f0 ff ff       	call   801027f4 <kfree>
801037e2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 00                	mov    (%eax),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 11                	je     801037ff <pipealloc+0x135>
    fileclose(*f0);
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	50                   	push   %eax
801037f7:	e8 ed d8 ff ff       	call   801010e9 <fileclose>
801037fc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 11                	je     80103819 <pipealloc+0x14f>
    fileclose(*f1);
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	50                   	push   %eax
80103811:	e8 d3 d8 ff ff       	call   801010e9 <fileclose>
80103816:	83 c4 10             	add    $0x10,%esp
  return -1;
80103819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010381e:	c9                   	leave
8010381f:	c3                   	ret

80103820 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103820:	f3 0f 1e fb          	endbr32
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010382a:	8b 45 08             	mov    0x8(%ebp),%eax
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	50                   	push   %eax
80103831:	e8 b1 10 00 00       	call   801048e7 <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010383d:	74 23                	je     80103862 <pipeclose+0x42>
    p->writeopen = 0;
8010383f:	8b 45 08             	mov    0x8(%ebp),%eax
80103842:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103849:	00 00 00 
    wakeup(&p->nread);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	05 34 02 00 00       	add    $0x234,%eax
80103854:	83 ec 0c             	sub    $0xc,%esp
80103857:	50                   	push   %eax
80103858:	e8 36 0d 00 00       	call   80104593 <wakeup>
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	eb 21                	jmp    80103883 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010386c:	00 00 00 
    wakeup(&p->nwrite);
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 38 02 00 00       	add    $0x238,%eax
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	50                   	push   %eax
8010387b:	e8 13 0d 00 00       	call   80104593 <wakeup>
80103880:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 2c                	jne    801038bc <pipeclose+0x9c>
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	75 1f                	jne    801038bc <pipeclose+0x9c>
    release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 b0 10 00 00       	call   80104959 <release>
801038a9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 08             	push   0x8(%ebp)
801038b2:	e8 3d ef ff ff       	call   801027f4 <kfree>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	eb 10                	jmp    801038cc <pipeclose+0xac>
  } else
    release(&p->lock);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	83 ec 0c             	sub    $0xc,%esp
801038c2:	50                   	push   %eax
801038c3:	e8 91 10 00 00       	call   80104959 <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	90                   	nop
801038cd:	c9                   	leave
801038ce:	c3                   	ret

801038cf <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038cf:	f3 0f 1e fb          	endbr32
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	53                   	push   %ebx
801038d7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 01 10 00 00       	call   801048e7 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	e9 ad 00 00 00       	jmp    801039a2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 0c                	je     8010390e <pipewrite+0x3f>
80103902:	e8 a2 02 00 00       	call   80103ba9 <myproc>
80103907:	8b 40 24             	mov    0x24(%eax),%eax
8010390a:	85 c0                	test   %eax,%eax
8010390c:	74 19                	je     80103927 <pipewrite+0x58>
        release(&p->lock);
8010390e:	8b 45 08             	mov    0x8(%ebp),%eax
80103911:	83 ec 0c             	sub    $0xc,%esp
80103914:	50                   	push   %eax
80103915:	e8 3f 10 00 00       	call   80104959 <release>
8010391a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010391d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103922:	e9 a9 00 00 00       	jmp    801039d0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	05 34 02 00 00       	add    $0x234,%eax
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	50                   	push   %eax
80103933:	e8 5b 0c 00 00       	call   80104593 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 53 0b 00 00       	call   801044a4 <sleep>
80103951:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103966:	05 00 02 00 00       	add    $0x200,%eax
8010396b:	39 c2                	cmp    %eax,%edx
8010396d:	74 86                	je     801038f5 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010396f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103972:	8b 45 0c             	mov    0xc(%ebp),%eax
80103975:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103981:	8d 48 01             	lea    0x1(%eax),%ecx
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010398d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103992:	89 c1                	mov    %eax,%ecx
80103994:	0f b6 13             	movzbl (%ebx),%edx
80103997:	8b 45 08             	mov    0x8(%ebp),%eax
8010399a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010399e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039a8:	7c aa                	jl     80103954 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	05 34 02 00 00       	add    $0x234,%eax
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	50                   	push   %eax
801039b6:	e8 d8 0b 00 00       	call   80104593 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 8f 0f 00 00       	call   80104959 <release>
801039ca:	83 c4 10             	add    $0x10,%esp
  return n;
801039cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d3:	c9                   	leave
801039d4:	c3                   	ret

801039d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039d5:	f3 0f 1e fb          	endbr32
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039df:	8b 45 08             	mov    0x8(%ebp),%eax
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	50                   	push   %eax
801039e6:	e8 fc 0e 00 00       	call   801048e7 <acquire>
801039eb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ee:	eb 3e                	jmp    80103a2e <piperead+0x59>
    if(myproc()->killed){
801039f0:	e8 b4 01 00 00       	call   80103ba9 <myproc>
801039f5:	8b 40 24             	mov    0x24(%eax),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	74 19                	je     80103a15 <piperead+0x40>
      release(&p->lock);
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	50                   	push   %eax
80103a03:	e8 51 0f 00 00       	call   80104959 <release>
80103a08:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a10:	e9 be 00 00 00       	jmp    80103ad3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	50                   	push   %eax
80103a25:	52                   	push   %edx
80103a26:	e8 79 0a 00 00       	call   801044a4 <sleep>
80103a2b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a31:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a40:	39 c2                	cmp    %eax,%edx
80103a42:	75 0d                	jne    80103a51 <piperead+0x7c>
80103a44:	8b 45 08             	mov    0x8(%ebp),%eax
80103a47:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a4d:	85 c0                	test   %eax,%eax
80103a4f:	75 9f                	jne    801039f0 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a58:	eb 48                	jmp    80103aa2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a6c:	39 c2                	cmp    %eax,%edx
80103a6e:	74 3c                	je     80103aac <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a70:	8b 45 08             	mov    0x8(%ebp),%eax
80103a73:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a79:	8d 48 01             	lea    0x1(%eax),%ecx
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a8a:	89 c1                	mov    %eax,%ecx
80103a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a92:	01 c2                	add    %eax,%edx
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a9c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103aa8:	7c b0                	jl     80103a5a <piperead+0x85>
80103aaa:	eb 01                	jmp    80103aad <piperead+0xd8>
      break;
80103aac:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	05 38 02 00 00       	add    $0x238,%eax
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	50                   	push   %eax
80103ab9:	e8 d5 0a 00 00       	call   80104593 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 8c 0e 00 00       	call   80104959 <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return i;
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ad3:	c9                   	leave
80103ad4:	c3                   	ret

80103ad5 <readeflags>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103adb:	9c                   	pushf
80103adc:	58                   	pop    %eax
80103add:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ae3:	c9                   	leave
80103ae4:	c3                   	ret

80103ae5 <sti>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ae8:	fb                   	sti
}
80103ae9:	90                   	nop
80103aea:	5d                   	pop    %ebp
80103aeb:	c3                   	ret

80103aec <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 90 a6 10 80       	push   $0x8010a690
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 b9 0d 00 00       	call   801048c1 <initlock>
80103b08:	83 c4 10             	add    $0x10,%esp
}
80103b0b:	90                   	nop
80103b0c:	c9                   	leave
80103b0d:	c3                   	ret

80103b0e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b0e:	f3 0f 1e fb          	endbr32
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b18:	e8 10 00 00 00       	call   80103b2d <mycpu>
80103b1d:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b22:	c1 f8 04             	sar    $0x4,%eax
80103b25:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b2b:	c9                   	leave
80103b2c:	c3                   	ret

80103b2d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b2d:	f3 0f 1e fb          	endbr32
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b37:	e8 99 ff ff ff       	call   80103ad5 <readeflags>
80103b3c:	25 00 02 00 00       	and    $0x200,%eax
80103b41:	85 c0                	test   %eax,%eax
80103b43:	74 0d                	je     80103b52 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	68 98 a6 10 80       	push   $0x8010a698
80103b4d:	e8 73 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b52:	e8 a8 f0 ff ff       	call   80102bff <lapicid>
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b61:	eb 2d                	jmp    80103b90 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b6c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 80 19 80       	mov    0x80198080,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 be a6 10 80       	push   $0x8010a6be
80103ba2:	e8 1e ca ff ff       	call   801005c5 <panic>
}
80103ba7:	c9                   	leave
80103ba8:	c3                   	ret

80103ba9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103ba9:	f3 0f 1e fb          	endbr32
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bb3:	e8 ab 0e 00 00       	call   80104a63 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 e3 0e 00 00       	call   80104ab4 <popcli>
  return p;
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bd4:	c9                   	leave
80103bd5:	c3                   	ret

80103bd6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bd6:	f3 0f 1e fb          	endbr32
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 00 55 19 80       	push   $0x80195500
80103be8:	e8 fa 0c 00 00       	call   801048e7 <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 0e                	jmp    80103c07 <allocproc+0x31>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 27                	je     80103c2a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c07:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 00 55 19 80       	push   $0x80195500
80103c18:	e8 3c 0d 00 00       	call   80104959 <release>
80103c1d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c20:	b8 00 00 00 00       	mov    $0x0,%eax
80103c25:	e9 b6 00 00 00       	jmp    80103ce0 <allocproc+0x10a>
      goto found;
80103c2a:	90                   	nop
80103c2b:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c39:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c3e:	8d 50 01             	lea    0x1(%eax),%edx
80103c41:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4a:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103c4d:	83 ec 0c             	sub    $0xc,%esp
80103c50:	68 00 55 19 80       	push   $0x80195500
80103c55:	e8 ff 0c 00 00       	call   80104959 <release>
80103c5a:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c5d:	e8 30 ec ff ff       	call   80102892 <kalloc>
80103c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c65:	89 42 08             	mov    %eax,0x8(%edx)
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	8b 40 08             	mov    0x8(%eax),%eax
80103c6e:	85 c0                	test   %eax,%eax
80103c70:	75 11                	jne    80103c83 <allocproc+0xad>
    p->state = UNUSED;
80103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c75:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c7c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c81:	eb 5d                	jmp    80103ce0 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c86:	8b 40 08             	mov    0x8(%eax),%eax
80103c89:	05 00 10 00 00       	add    $0x1000,%eax
80103c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103c91:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c9b:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103c9e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103ca2:	ba d3 5f 10 80       	mov    $0x80105fd3,%edx
80103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103caa:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cac:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cb6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbc:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	6a 14                	push   $0x14
80103cc4:	6a 00                	push   $0x0
80103cc6:	50                   	push   %eax
80103cc7:	e8 aa 0e 00 00       	call   80104b76 <memset>
80103ccc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd2:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd5:	ba 5a 44 10 80       	mov    $0x8010445a,%edx
80103cda:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ce0:	c9                   	leave
80103ce1:	c3                   	ret

80103ce2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103ce2:	f3 0f 1e fb          	endbr32
80103ce6:	55                   	push   %ebp
80103ce7:	89 e5                	mov    %esp,%ebp
80103ce9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cec:	e8 e5 fe ff ff       	call   80103bd6 <allocproc>
80103cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103cfc:	e8 d2 38 00 00       	call   801075d3 <setupkvm>
80103d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d04:	89 42 04             	mov    %eax,0x4(%edx)
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	8b 40 04             	mov    0x4(%eax),%eax
80103d0d:	85 c0                	test   %eax,%eax
80103d0f:	75 0d                	jne    80103d1e <userinit+0x3c>
    panic("userinit: out of memory?");
80103d11:	83 ec 0c             	sub    $0xc,%esp
80103d14:	68 ce a6 10 80       	push   $0x8010a6ce
80103d19:	e8 a7 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d1e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d26:	8b 40 04             	mov    0x4(%eax),%eax
80103d29:	83 ec 04             	sub    $0x4,%esp
80103d2c:	52                   	push   %edx
80103d2d:	68 ec f4 10 80       	push   $0x8010f4ec
80103d32:	50                   	push   %eax
80103d33:	e8 68 3b 00 00       	call   801078a0 <inituvm>
80103d38:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	8b 40 18             	mov    0x18(%eax),%eax
80103d4a:	83 ec 04             	sub    $0x4,%esp
80103d4d:	6a 4c                	push   $0x4c
80103d4f:	6a 00                	push   $0x0
80103d51:	50                   	push   %eax
80103d52:	e8 1f 0e 00 00       	call   80104b76 <memset>
80103d57:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5d:	8b 40 18             	mov    0x18(%eax),%eax
80103d60:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d69:	8b 40 18             	mov    0x18(%eax),%eax
80103d6c:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d75:	8b 50 18             	mov    0x18(%eax),%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	8b 40 18             	mov    0x18(%eax),%eax
80103d7e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d82:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d89:	8b 50 18             	mov    0x18(%eax),%edx
80103d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8f:	8b 40 18             	mov    0x18(%eax),%eax
80103d92:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d96:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9d:	8b 40 18             	mov    0x18(%eax),%eax
80103da0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103daa:	8b 40 18             	mov    0x18(%eax),%eax
80103dad:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db7:	8b 40 18             	mov    0x18(%eax),%eax
80103dba:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	83 c0 6c             	add    $0x6c,%eax
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	6a 10                	push   $0x10
80103dcc:	68 e7 a6 10 80       	push   $0x8010a6e7
80103dd1:	50                   	push   %eax
80103dd2:	e8 ba 0f 00 00       	call   80104d91 <safestrcpy>
80103dd7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dda:	83 ec 0c             	sub    $0xc,%esp
80103ddd:	68 f0 a6 10 80       	push   $0x8010a6f0
80103de2:	e8 00 e8 ff ff       	call   801025e7 <namei>
80103de7:	83 c4 10             	add    $0x10,%esp
80103dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ded:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103df0:	83 ec 0c             	sub    $0xc,%esp
80103df3:	68 00 55 19 80       	push   $0x80195500
80103df8:	e8 ea 0a 00 00       	call   801048e7 <acquire>
80103dfd:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e03:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	68 00 55 19 80       	push   $0x80195500
80103e12:	e8 42 0b 00 00       	call   80104959 <release>
80103e17:	83 c4 10             	add    $0x10,%esp
}
80103e1a:	90                   	nop
80103e1b:	c9                   	leave
80103e1c:	c3                   	ret

80103e1d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e1d:	f3 0f 1e fb          	endbr32
80103e21:	55                   	push   %ebp
80103e22:	89 e5                	mov    %esp,%ebp
80103e24:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e27:	e8 7d fd ff ff       	call   80103ba9 <myproc>
80103e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e32:	8b 00                	mov    (%eax),%eax
80103e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e3b:	7e 2e                	jle    80103e6b <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e3d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e43:	01 c2                	add    %eax,%edx
80103e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e48:	8b 40 04             	mov    0x4(%eax),%eax
80103e4b:	83 ec 04             	sub    $0x4,%esp
80103e4e:	52                   	push   %edx
80103e4f:	ff 75 f4             	push   -0xc(%ebp)
80103e52:	50                   	push   %eax
80103e53:	e8 8d 3b 00 00       	call   801079e5 <allocuvm>
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e62:	75 3b                	jne    80103e9f <growproc+0x82>
      return -1;
80103e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e69:	eb 4f                	jmp    80103eba <growproc+0x9d>
  } else if(n < 0){
80103e6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e6f:	79 2e                	jns    80103e9f <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e71:	8b 55 08             	mov    0x8(%ebp),%edx
80103e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e77:	01 c2                	add    %eax,%edx
80103e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7c:	8b 40 04             	mov    0x4(%eax),%eax
80103e7f:	83 ec 04             	sub    $0x4,%esp
80103e82:	52                   	push   %edx
80103e83:	ff 75 f4             	push   -0xc(%ebp)
80103e86:	50                   	push   %eax
80103e87:	e8 62 3c 00 00       	call   80107aee <deallocuvm>
80103e8c:	83 c4 10             	add    $0x10,%esp
80103e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e96:	75 07                	jne    80103e9f <growproc+0x82>
      return -1;
80103e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e9d:	eb 1b                	jmp    80103eba <growproc+0x9d>
  }
  curproc->sz = sz;
80103e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103ea7:	83 ec 0c             	sub    $0xc,%esp
80103eaa:	ff 75 f0             	push   -0x10(%ebp)
80103ead:	e8 4b 38 00 00       	call   801076fd <switchuvm>
80103eb2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103eba:	c9                   	leave
80103ebb:	c3                   	ret

80103ebc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ebc:	f3 0f 1e fb          	endbr32
80103ec0:	55                   	push   %ebp
80103ec1:	89 e5                	mov    %esp,%ebp
80103ec3:	57                   	push   %edi
80103ec4:	56                   	push   %esi
80103ec5:	53                   	push   %ebx
80103ec6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ec9:	e8 db fc ff ff       	call   80103ba9 <myproc>
80103ece:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ed1:	e8 00 fd ff ff       	call   80103bd6 <allocproc>
80103ed6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ed9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103edd:	75 0a                	jne    80103ee9 <fork+0x2d>
    return -1;
80103edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee4:	e9 48 01 00 00       	jmp    80104031 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eec:	8b 10                	mov    (%eax),%edx
80103eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef1:	8b 40 04             	mov    0x4(%eax),%eax
80103ef4:	83 ec 08             	sub    $0x8,%esp
80103ef7:	52                   	push   %edx
80103ef8:	50                   	push   %eax
80103ef9:	e8 9a 3d 00 00       	call   80107c98 <copyuvm>
80103efe:	83 c4 10             	add    $0x10,%esp
80103f01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f04:	89 42 04             	mov    %eax,0x4(%edx)
80103f07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0a:	8b 40 04             	mov    0x4(%eax),%eax
80103f0d:	85 c0                	test   %eax,%eax
80103f0f:	75 30                	jne    80103f41 <fork+0x85>
    kfree(np->kstack);
80103f11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f14:	8b 40 08             	mov    0x8(%eax),%eax
80103f17:	83 ec 0c             	sub    $0xc,%esp
80103f1a:	50                   	push   %eax
80103f1b:	e8 d4 e8 ff ff       	call   801027f4 <kfree>
80103f20:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3c:	e9 f0 00 00 00       	jmp    80104031 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f44:	8b 10                	mov    (%eax),%edx
80103f46:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f49:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f51:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f57:	8b 48 18             	mov    0x18(%eax),%ecx
80103f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5d:	8b 40 18             	mov    0x18(%eax),%eax
80103f60:	89 c2                	mov    %eax,%edx
80103f62:	89 cb                	mov    %ecx,%ebx
80103f64:	b8 13 00 00 00       	mov    $0x13,%eax
80103f69:	89 d7                	mov    %edx,%edi
80103f6b:	89 de                	mov    %ebx,%esi
80103f6d:	89 c1                	mov    %eax,%ecx
80103f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f74:	8b 40 18             	mov    0x18(%eax),%eax
80103f77:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f7e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f85:	eb 3b                	jmp    80103fc2 <fork+0x106>
    if(curproc->ofile[i])
80103f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f8d:	83 c2 08             	add    $0x8,%edx
80103f90:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f94:	85 c0                	test   %eax,%eax
80103f96:	74 26                	je     80103fbe <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f9e:	83 c2 08             	add    $0x8,%edx
80103fa1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa5:	83 ec 0c             	sub    $0xc,%esp
80103fa8:	50                   	push   %eax
80103fa9:	e8 e6 d0 ff ff       	call   80101094 <filedup>
80103fae:	83 c4 10             	add    $0x10,%esp
80103fb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fb4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fb7:	83 c1 08             	add    $0x8,%ecx
80103fba:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fbe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fc2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fc6:	7e bf                	jle    80103f87 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fcb:	8b 40 68             	mov    0x68(%eax),%eax
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	50                   	push   %eax
80103fd2:	e8 67 da ff ff       	call   80101a3e <idup>
80103fd7:	83 c4 10             	add    $0x10,%esp
80103fda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fdd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103fe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80103fe6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe9:	83 c0 6c             	add    $0x6c,%eax
80103fec:	83 ec 04             	sub    $0x4,%esp
80103fef:	6a 10                	push   $0x10
80103ff1:	52                   	push   %edx
80103ff2:	50                   	push   %eax
80103ff3:	e8 99 0d 00 00       	call   80104d91 <safestrcpy>
80103ff8:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffe:	8b 40 10             	mov    0x10(%eax),%eax
80104001:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 00 55 19 80       	push   $0x80195500
8010400c:	e8 d6 08 00 00       	call   801048e7 <acquire>
80104011:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104014:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104017:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010401e:	83 ec 0c             	sub    $0xc,%esp
80104021:	68 00 55 19 80       	push   $0x80195500
80104026:	e8 2e 09 00 00       	call   80104959 <release>
8010402b:	83 c4 10             	add    $0x10,%esp

  return pid;
8010402e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104031:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104034:	5b                   	pop    %ebx
80104035:	5e                   	pop    %esi
80104036:	5f                   	pop    %edi
80104037:	5d                   	pop    %ebp
80104038:	c3                   	ret

80104039 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104039:	f3 0f 1e fb          	endbr32
8010403d:	55                   	push   %ebp
8010403e:	89 e5                	mov    %esp,%ebp
80104040:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104043:	e8 61 fb ff ff       	call   80103ba9 <myproc>
80104048:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010404b:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104050:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104053:	75 0d                	jne    80104062 <exit+0x29>
    panic("init exiting");
80104055:	83 ec 0c             	sub    $0xc,%esp
80104058:	68 f2 a6 10 80       	push   $0x8010a6f2
8010405d:	e8 63 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104062:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104069:	eb 3f                	jmp    801040aa <exit+0x71>
    if(curproc->ofile[fd]){
8010406b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010406e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104071:	83 c2 08             	add    $0x8,%edx
80104074:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104078:	85 c0                	test   %eax,%eax
8010407a:	74 2a                	je     801040a6 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010407c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010407f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104082:	83 c2 08             	add    $0x8,%edx
80104085:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104089:	83 ec 0c             	sub    $0xc,%esp
8010408c:	50                   	push   %eax
8010408d:	e8 57 d0 ff ff       	call   801010e9 <fileclose>
80104092:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104098:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010409b:	83 c2 08             	add    $0x8,%edx
8010409e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040a5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040aa:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040ae:	7e bb                	jle    8010406b <exit+0x32>
    }
  }

  begin_op();
801040b0:	e8 bc f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b8:	8b 40 68             	mov    0x68(%eax),%eax
801040bb:	83 ec 0c             	sub    $0xc,%esp
801040be:	50                   	push   %eax
801040bf:	e8 21 db ff ff       	call   80101be5 <iput>
801040c4:	83 c4 10             	add    $0x10,%esp
  end_op();
801040c7:	e8 35 f1 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801040cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040cf:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040d6:	83 ec 0c             	sub    $0xc,%esp
801040d9:	68 00 55 19 80       	push   $0x80195500
801040de:	e8 04 08 00 00       	call   801048e7 <acquire>
801040e3:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040e9:	8b 40 14             	mov    0x14(%eax),%eax
801040ec:	83 ec 0c             	sub    $0xc,%esp
801040ef:	50                   	push   %eax
801040f0:	e8 5a 04 00 00       	call   8010454f <wakeup1>
801040f5:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040f8:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801040ff:	eb 37                	jmp    80104138 <exit+0xff>
    if(p->parent == curproc){
80104101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104104:	8b 40 14             	mov    0x14(%eax),%eax
80104107:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010410a:	75 28                	jne    80104134 <exit+0xfb>
      p->parent = initproc;
8010410c:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411b:	8b 40 0c             	mov    0xc(%eax),%eax
8010411e:	83 f8 05             	cmp    $0x5,%eax
80104121:	75 11                	jne    80104134 <exit+0xfb>
        wakeup1(initproc);
80104123:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104128:	83 ec 0c             	sub    $0xc,%esp
8010412b:	50                   	push   %eax
8010412c:	e8 1e 04 00 00       	call   8010454f <wakeup1>
80104131:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104134:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104138:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010413f:	72 c0                	jb     80104101 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104144:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010414b:	e8 0f 02 00 00       	call   8010435f <sched>
  panic("zombie exit");
80104150:	83 ec 0c             	sub    $0xc,%esp
80104153:	68 ff a6 10 80       	push   $0x8010a6ff
80104158:	e8 68 c4 ff ff       	call   801005c5 <panic>

8010415d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010415d:	f3 0f 1e fb          	endbr32
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104167:	e8 3d fa ff ff       	call   80103ba9 <myproc>
8010416c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010416f:	83 ec 0c             	sub    $0xc,%esp
80104172:	68 00 55 19 80       	push   $0x80195500
80104177:	e8 6b 07 00 00       	call   801048e7 <acquire>
8010417c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010417f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104186:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010418d:	e9 a1 00 00 00       	jmp    80104233 <wait+0xd6>
      if(p->parent != curproc)
80104192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104195:	8b 40 14             	mov    0x14(%eax),%eax
80104198:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010419b:	0f 85 8d 00 00 00    	jne    8010422e <wait+0xd1>
        continue;
      havekids = 1;
801041a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ab:	8b 40 0c             	mov    0xc(%eax),%eax
801041ae:	83 f8 05             	cmp    $0x5,%eax
801041b1:	75 7c                	jne    8010422f <wait+0xd2>
        // Found one.
        pid = p->pid;
801041b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b6:	8b 40 10             	mov    0x10(%eax),%eax
801041b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bf:	8b 40 08             	mov    0x8(%eax),%eax
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	50                   	push   %eax
801041c6:	e8 29 e6 ff ff       	call   801027f4 <kfree>
801041cb:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041db:	8b 40 04             	mov    0x4(%eax),%eax
801041de:	83 ec 0c             	sub    $0xc,%esp
801041e1:	50                   	push   %eax
801041e2:	e8 cf 39 00 00       	call   80107bb6 <freevm>
801041e7:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ed:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104208:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	68 00 55 19 80       	push   $0x80195500
80104221:	e8 33 07 00 00       	call   80104959 <release>
80104226:	83 c4 10             	add    $0x10,%esp
        return pid;
80104229:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010422c:	eb 51                	jmp    8010427f <wait+0x122>
        continue;
8010422e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010422f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104233:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010423a:	0f 82 52 ff ff ff    	jb     80104192 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104240:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104244:	74 0a                	je     80104250 <wait+0xf3>
80104246:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104249:	8b 40 24             	mov    0x24(%eax),%eax
8010424c:	85 c0                	test   %eax,%eax
8010424e:	74 17                	je     80104267 <wait+0x10a>
      release(&ptable.lock);
80104250:	83 ec 0c             	sub    $0xc,%esp
80104253:	68 00 55 19 80       	push   $0x80195500
80104258:	e8 fc 06 00 00       	call   80104959 <release>
8010425d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104265:	eb 18                	jmp    8010427f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104267:	83 ec 08             	sub    $0x8,%esp
8010426a:	68 00 55 19 80       	push   $0x80195500
8010426f:	ff 75 ec             	push   -0x14(%ebp)
80104272:	e8 2d 02 00 00       	call   801044a4 <sleep>
80104277:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010427a:	e9 00 ff ff ff       	jmp    8010417f <wait+0x22>
  }
}
8010427f:	c9                   	leave
80104280:	c3                   	ret

80104281 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104281:	f3 0f 1e fb          	endbr32
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010428b:	e8 9d f8 ff ff       	call   80103b2d <mycpu>
80104290:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104293:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104296:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010429d:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801042a0:	e8 40 f8 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 00 55 19 80       	push   $0x80195500
801042ad:	e8 35 06 00 00       	call   801048e7 <acquire>
801042b2:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042b5:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042bc:	eb 61                	jmp    8010431f <scheduler+0x9e>
      if(p->state != RUNNABLE)
801042be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c1:	8b 40 0c             	mov    0xc(%eax),%eax
801042c4:	83 f8 03             	cmp    $0x3,%eax
801042c7:	75 51                	jne    8010431a <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801042c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042cf:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	ff 75 f4             	push   -0xc(%ebp)
801042db:	e8 1d 34 00 00       	call   801076fd <switchuvm>
801042e0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801042ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f0:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042f6:	83 c2 04             	add    $0x4,%edx
801042f9:	83 ec 08             	sub    $0x8,%esp
801042fc:	50                   	push   %eax
801042fd:	52                   	push   %edx
801042fe:	e8 07 0b 00 00       	call   80104e0a <swtch>
80104303:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104306:	e8 d5 33 00 00       	call   801076e0 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010430b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010430e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104315:	00 00 00 
80104318:	eb 01                	jmp    8010431b <scheduler+0x9a>
        continue;
8010431a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010431b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010431f:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104326:	72 96                	jb     801042be <scheduler+0x3d>
    }
    release(&ptable.lock);
80104328:	83 ec 0c             	sub    $0xc,%esp
8010432b:	68 00 55 19 80       	push   $0x80195500
80104330:	e8 24 06 00 00       	call   80104959 <release>
80104335:	83 c4 10             	add    $0x10,%esp
    sti();
80104338:	e9 63 ff ff ff       	jmp    801042a0 <scheduler+0x1f>

8010433d <uthread_init>:
  }
}

int 
uthread_init(int address)
{
8010433d:	f3 0f 1e fb          	endbr32
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104347:	e8 5d f8 ff ff       	call   80103ba9 <myproc>
8010434c:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
8010434f:	8b 55 08             	mov    0x8(%ebp),%edx
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
80104358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010435d:	c9                   	leave
8010435e:	c3                   	ret

8010435f <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010435f:	f3 0f 1e fb          	endbr32
80104363:	55                   	push   %ebp
80104364:	89 e5                	mov    %esp,%ebp
80104366:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104369:	e8 3b f8 ff ff       	call   80103ba9 <myproc>
8010436e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104371:	83 ec 0c             	sub    $0xc,%esp
80104374:	68 00 55 19 80       	push   $0x80195500
80104379:	e8 b0 06 00 00       	call   80104a2e <holding>
8010437e:	83 c4 10             	add    $0x10,%esp
80104381:	85 c0                	test   %eax,%eax
80104383:	75 0d                	jne    80104392 <sched+0x33>
    panic("sched ptable.lock");
80104385:	83 ec 0c             	sub    $0xc,%esp
80104388:	68 0b a7 10 80       	push   $0x8010a70b
8010438d:	e8 33 c2 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104392:	e8 96 f7 ff ff       	call   80103b2d <mycpu>
80104397:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010439d:	83 f8 01             	cmp    $0x1,%eax
801043a0:	74 0d                	je     801043af <sched+0x50>
    panic("sched locks");
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	68 1d a7 10 80       	push   $0x8010a71d
801043aa:	e8 16 c2 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
801043af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b2:	8b 40 0c             	mov    0xc(%eax),%eax
801043b5:	83 f8 04             	cmp    $0x4,%eax
801043b8:	75 0d                	jne    801043c7 <sched+0x68>
    panic("sched running");
801043ba:	83 ec 0c             	sub    $0xc,%esp
801043bd:	68 29 a7 10 80       	push   $0x8010a729
801043c2:	e8 fe c1 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801043c7:	e8 09 f7 ff ff       	call   80103ad5 <readeflags>
801043cc:	25 00 02 00 00       	and    $0x200,%eax
801043d1:	85 c0                	test   %eax,%eax
801043d3:	74 0d                	je     801043e2 <sched+0x83>
    panic("sched interruptible");
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	68 37 a7 10 80       	push   $0x8010a737
801043dd:	e8 e3 c1 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801043e2:	e8 46 f7 ff ff       	call   80103b2d <mycpu>
801043e7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801043f0:	e8 38 f7 ff ff       	call   80103b2d <mycpu>
801043f5:	8b 40 04             	mov    0x4(%eax),%eax
801043f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043fb:	83 c2 1c             	add    $0x1c,%edx
801043fe:	83 ec 08             	sub    $0x8,%esp
80104401:	50                   	push   %eax
80104402:	52                   	push   %edx
80104403:	e8 02 0a 00 00       	call   80104e0a <swtch>
80104408:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010440b:	e8 1d f7 ff ff       	call   80103b2d <mycpu>
80104410:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104413:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104419:	90                   	nop
8010441a:	c9                   	leave
8010441b:	c3                   	ret

8010441c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010441c:	f3 0f 1e fb          	endbr32
80104420:	55                   	push   %ebp
80104421:	89 e5                	mov    %esp,%ebp
80104423:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104426:	83 ec 0c             	sub    $0xc,%esp
80104429:	68 00 55 19 80       	push   $0x80195500
8010442e:	e8 b4 04 00 00       	call   801048e7 <acquire>
80104433:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104436:	e8 6e f7 ff ff       	call   80103ba9 <myproc>
8010443b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104442:	e8 18 ff ff ff       	call   8010435f <sched>
  release(&ptable.lock);
80104447:	83 ec 0c             	sub    $0xc,%esp
8010444a:	68 00 55 19 80       	push   $0x80195500
8010444f:	e8 05 05 00 00       	call   80104959 <release>
80104454:	83 c4 10             	add    $0x10,%esp
}
80104457:	90                   	nop
80104458:	c9                   	leave
80104459:	c3                   	ret

8010445a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010445a:	f3 0f 1e fb          	endbr32
8010445e:	55                   	push   %ebp
8010445f:	89 e5                	mov    %esp,%ebp
80104461:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 00 55 19 80       	push   $0x80195500
8010446c:	e8 e8 04 00 00       	call   80104959 <release>
80104471:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104474:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104479:	85 c0                	test   %eax,%eax
8010447b:	74 24                	je     801044a1 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010447d:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104484:	00 00 00 
    iinit(ROOTDEV);
80104487:	83 ec 0c             	sub    $0xc,%esp
8010448a:	6a 01                	push   $0x1
8010448c:	e8 65 d2 ff ff       	call   801016f6 <iinit>
80104491:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104494:	83 ec 0c             	sub    $0xc,%esp
80104497:	6a 01                	push   $0x1
80104499:	e8 a0 ea ff ff       	call   80102f3e <initlog>
8010449e:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801044a1:	90                   	nop
801044a2:	c9                   	leave
801044a3:	c3                   	ret

801044a4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801044a4:	f3 0f 1e fb          	endbr32
801044a8:	55                   	push   %ebp
801044a9:	89 e5                	mov    %esp,%ebp
801044ab:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801044ae:	e8 f6 f6 ff ff       	call   80103ba9 <myproc>
801044b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801044b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044ba:	75 0d                	jne    801044c9 <sleep+0x25>
    panic("sleep");
801044bc:	83 ec 0c             	sub    $0xc,%esp
801044bf:	68 4b a7 10 80       	push   $0x8010a74b
801044c4:	e8 fc c0 ff ff       	call   801005c5 <panic>

  if(lk == 0)
801044c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044cd:	75 0d                	jne    801044dc <sleep+0x38>
    panic("sleep without lk");
801044cf:	83 ec 0c             	sub    $0xc,%esp
801044d2:	68 51 a7 10 80       	push   $0x8010a751
801044d7:	e8 e9 c0 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044dc:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801044e3:	74 1e                	je     80104503 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044e5:	83 ec 0c             	sub    $0xc,%esp
801044e8:	68 00 55 19 80       	push   $0x80195500
801044ed:	e8 f5 03 00 00       	call   801048e7 <acquire>
801044f2:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044f5:	83 ec 0c             	sub    $0xc,%esp
801044f8:	ff 75 0c             	push   0xc(%ebp)
801044fb:	e8 59 04 00 00       	call   80104959 <release>
80104500:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	8b 55 08             	mov    0x8(%ebp),%edx
80104509:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010450c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104516:	e8 44 fe ff ff       	call   8010435f <sched>

  // Tidy up.
  p->chan = 0;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104525:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010452c:	74 1e                	je     8010454c <sleep+0xa8>
    release(&ptable.lock);
8010452e:	83 ec 0c             	sub    $0xc,%esp
80104531:	68 00 55 19 80       	push   $0x80195500
80104536:	e8 1e 04 00 00       	call   80104959 <release>
8010453b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010453e:	83 ec 0c             	sub    $0xc,%esp
80104541:	ff 75 0c             	push   0xc(%ebp)
80104544:	e8 9e 03 00 00       	call   801048e7 <acquire>
80104549:	83 c4 10             	add    $0x10,%esp
  }
}
8010454c:	90                   	nop
8010454d:	c9                   	leave
8010454e:	c3                   	ret

8010454f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010454f:	f3 0f 1e fb          	endbr32
80104553:	55                   	push   %ebp
80104554:	89 e5                	mov    %esp,%ebp
80104556:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104559:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
80104560:	eb 24                	jmp    80104586 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104562:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104565:	8b 40 0c             	mov    0xc(%eax),%eax
80104568:	83 f8 02             	cmp    $0x2,%eax
8010456b:	75 15                	jne    80104582 <wakeup1+0x33>
8010456d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104570:	8b 40 20             	mov    0x20(%eax),%eax
80104573:	39 45 08             	cmp    %eax,0x8(%ebp)
80104576:	75 0a                	jne    80104582 <wakeup1+0x33>
      p->state = RUNNABLE;
80104578:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010457b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104582:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104586:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
8010458d:	72 d3                	jb     80104562 <wakeup1+0x13>
}
8010458f:	90                   	nop
80104590:	90                   	nop
80104591:	c9                   	leave
80104592:	c3                   	ret

80104593 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104593:	f3 0f 1e fb          	endbr32
80104597:	55                   	push   %ebp
80104598:	89 e5                	mov    %esp,%ebp
8010459a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010459d:	83 ec 0c             	sub    $0xc,%esp
801045a0:	68 00 55 19 80       	push   $0x80195500
801045a5:	e8 3d 03 00 00       	call   801048e7 <acquire>
801045aa:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801045ad:	83 ec 0c             	sub    $0xc,%esp
801045b0:	ff 75 08             	push   0x8(%ebp)
801045b3:	e8 97 ff ff ff       	call   8010454f <wakeup1>
801045b8:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045bb:	83 ec 0c             	sub    $0xc,%esp
801045be:	68 00 55 19 80       	push   $0x80195500
801045c3:	e8 91 03 00 00       	call   80104959 <release>
801045c8:	83 c4 10             	add    $0x10,%esp
}
801045cb:	90                   	nop
801045cc:	c9                   	leave
801045cd:	c3                   	ret

801045ce <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045ce:	f3 0f 1e fb          	endbr32
801045d2:	55                   	push   %ebp
801045d3:	89 e5                	mov    %esp,%ebp
801045d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045d8:	83 ec 0c             	sub    $0xc,%esp
801045db:	68 00 55 19 80       	push   $0x80195500
801045e0:	e8 02 03 00 00       	call   801048e7 <acquire>
801045e5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045e8:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801045ef:	eb 45                	jmp    80104636 <kill+0x68>
    if(p->pid == pid){
801045f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f4:	8b 40 10             	mov    0x10(%eax),%eax
801045f7:	39 45 08             	cmp    %eax,0x8(%ebp)
801045fa:	75 36                	jne    80104632 <kill+0x64>
      p->killed = 1;
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104609:	8b 40 0c             	mov    0xc(%eax),%eax
8010460c:	83 f8 02             	cmp    $0x2,%eax
8010460f:	75 0a                	jne    8010461b <kill+0x4d>
        p->state = RUNNABLE;
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104614:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	68 00 55 19 80       	push   $0x80195500
80104623:	e8 31 03 00 00       	call   80104959 <release>
80104628:	83 c4 10             	add    $0x10,%esp
      return 0;
8010462b:	b8 00 00 00 00       	mov    $0x0,%eax
80104630:	eb 22                	jmp    80104654 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104632:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104636:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010463d:	72 b2                	jb     801045f1 <kill+0x23>
    }
  }
  release(&ptable.lock);
8010463f:	83 ec 0c             	sub    $0xc,%esp
80104642:	68 00 55 19 80       	push   $0x80195500
80104647:	e8 0d 03 00 00       	call   80104959 <release>
8010464c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010464f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104654:	c9                   	leave
80104655:	c3                   	ret

80104656 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104656:	f3 0f 1e fb          	endbr32
8010465a:	55                   	push   %ebp
8010465b:	89 e5                	mov    %esp,%ebp
8010465d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104660:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104667:	e9 d7 00 00 00       	jmp    80104743 <procdump+0xed>
    if(p->state == UNUSED)
8010466c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466f:	8b 40 0c             	mov    0xc(%eax),%eax
80104672:	85 c0                	test   %eax,%eax
80104674:	0f 84 c4 00 00 00    	je     8010473e <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010467a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467d:	8b 40 0c             	mov    0xc(%eax),%eax
80104680:	83 f8 05             	cmp    $0x5,%eax
80104683:	77 23                	ja     801046a8 <procdump+0x52>
80104685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104688:	8b 40 0c             	mov    0xc(%eax),%eax
8010468b:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104692:	85 c0                	test   %eax,%eax
80104694:	74 12                	je     801046a8 <procdump+0x52>
      state = states[p->state];
80104696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104699:	8b 40 0c             	mov    0xc(%eax),%eax
8010469c:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046a6:	eb 07                	jmp    801046af <procdump+0x59>
    else
      state = "???";
801046a8:	c7 45 ec 62 a7 10 80 	movl   $0x8010a762,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801046af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b2:	8d 50 6c             	lea    0x6c(%eax),%edx
801046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b8:	8b 40 10             	mov    0x10(%eax),%eax
801046bb:	52                   	push   %edx
801046bc:	ff 75 ec             	push   -0x14(%ebp)
801046bf:	50                   	push   %eax
801046c0:	68 66 a7 10 80       	push   $0x8010a766
801046c5:	e8 42 bd ff ff       	call   8010040c <cprintf>
801046ca:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046d0:	8b 40 0c             	mov    0xc(%eax),%eax
801046d3:	83 f8 02             	cmp    $0x2,%eax
801046d6:	75 54                	jne    8010472c <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046db:	8b 40 1c             	mov    0x1c(%eax),%eax
801046de:	8b 40 0c             	mov    0xc(%eax),%eax
801046e1:	83 c0 08             	add    $0x8,%eax
801046e4:	89 c2                	mov    %eax,%edx
801046e6:	83 ec 08             	sub    $0x8,%esp
801046e9:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046ec:	50                   	push   %eax
801046ed:	52                   	push   %edx
801046ee:	e8 bc 02 00 00       	call   801049af <getcallerpcs>
801046f3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046fd:	eb 1c                	jmp    8010471b <procdump+0xc5>
        cprintf(" %p", pc[i]);
801046ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104702:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104706:	83 ec 08             	sub    $0x8,%esp
80104709:	50                   	push   %eax
8010470a:	68 6f a7 10 80       	push   $0x8010a76f
8010470f:	e8 f8 bc ff ff       	call   8010040c <cprintf>
80104714:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104717:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010471b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010471f:	7f 0b                	jg     8010472c <procdump+0xd6>
80104721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104724:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104728:	85 c0                	test   %eax,%eax
8010472a:	75 d3                	jne    801046ff <procdump+0xa9>
    }
    cprintf("\n");
8010472c:	83 ec 0c             	sub    $0xc,%esp
8010472f:	68 73 a7 10 80       	push   $0x8010a773
80104734:	e8 d3 bc ff ff       	call   8010040c <cprintf>
80104739:	83 c4 10             	add    $0x10,%esp
8010473c:	eb 01                	jmp    8010473f <procdump+0xe9>
      continue;
8010473e:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010473f:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104743:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
8010474a:	0f 82 1c ff ff ff    	jb     8010466c <procdump+0x16>
  }
}
80104750:	90                   	nop
80104751:	90                   	nop
80104752:	c9                   	leave
80104753:	c3                   	ret

80104754 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104754:	f3 0f 1e fb          	endbr32
80104758:	55                   	push   %ebp
80104759:	89 e5                	mov    %esp,%ebp
8010475b:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010475e:	8b 45 08             	mov    0x8(%ebp),%eax
80104761:	83 c0 04             	add    $0x4,%eax
80104764:	83 ec 08             	sub    $0x8,%esp
80104767:	68 9f a7 10 80       	push   $0x8010a79f
8010476c:	50                   	push   %eax
8010476d:	e8 4f 01 00 00       	call   801048c1 <initlock>
80104772:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104775:	8b 45 08             	mov    0x8(%ebp),%eax
80104778:	8b 55 0c             	mov    0xc(%ebp),%edx
8010477b:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010477e:	8b 45 08             	mov    0x8(%ebp),%eax
80104781:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104787:	8b 45 08             	mov    0x8(%ebp),%eax
8010478a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104791:	90                   	nop
80104792:	c9                   	leave
80104793:	c3                   	ret

80104794 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104794:	f3 0f 1e fb          	endbr32
80104798:	55                   	push   %ebp
80104799:	89 e5                	mov    %esp,%ebp
8010479b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010479e:	8b 45 08             	mov    0x8(%ebp),%eax
801047a1:	83 c0 04             	add    $0x4,%eax
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	50                   	push   %eax
801047a8:	e8 3a 01 00 00       	call   801048e7 <acquire>
801047ad:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047b0:	eb 15                	jmp    801047c7 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801047b2:	8b 45 08             	mov    0x8(%ebp),%eax
801047b5:	83 c0 04             	add    $0x4,%eax
801047b8:	83 ec 08             	sub    $0x8,%esp
801047bb:	50                   	push   %eax
801047bc:	ff 75 08             	push   0x8(%ebp)
801047bf:	e8 e0 fc ff ff       	call   801044a4 <sleep>
801047c4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	8b 00                	mov    (%eax),%eax
801047cc:	85 c0                	test   %eax,%eax
801047ce:	75 e2                	jne    801047b2 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801047d0:	8b 45 08             	mov    0x8(%ebp),%eax
801047d3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801047d9:	e8 cb f3 ff ff       	call   80103ba9 <myproc>
801047de:	8b 50 10             	mov    0x10(%eax),%edx
801047e1:	8b 45 08             	mov    0x8(%ebp),%eax
801047e4:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801047e7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ea:	83 c0 04             	add    $0x4,%eax
801047ed:	83 ec 0c             	sub    $0xc,%esp
801047f0:	50                   	push   %eax
801047f1:	e8 63 01 00 00       	call   80104959 <release>
801047f6:	83 c4 10             	add    $0x10,%esp
}
801047f9:	90                   	nop
801047fa:	c9                   	leave
801047fb:	c3                   	ret

801047fc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801047fc:	f3 0f 1e fb          	endbr32
80104800:	55                   	push   %ebp
80104801:	89 e5                	mov    %esp,%ebp
80104803:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104806:	8b 45 08             	mov    0x8(%ebp),%eax
80104809:	83 c0 04             	add    $0x4,%eax
8010480c:	83 ec 0c             	sub    $0xc,%esp
8010480f:	50                   	push   %eax
80104810:	e8 d2 00 00 00       	call   801048e7 <acquire>
80104815:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104818:	8b 45 08             	mov    0x8(%ebp),%eax
8010481b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104821:	8b 45 08             	mov    0x8(%ebp),%eax
80104824:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010482b:	83 ec 0c             	sub    $0xc,%esp
8010482e:	ff 75 08             	push   0x8(%ebp)
80104831:	e8 5d fd ff ff       	call   80104593 <wakeup>
80104836:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104839:	8b 45 08             	mov    0x8(%ebp),%eax
8010483c:	83 c0 04             	add    $0x4,%eax
8010483f:	83 ec 0c             	sub    $0xc,%esp
80104842:	50                   	push   %eax
80104843:	e8 11 01 00 00       	call   80104959 <release>
80104848:	83 c4 10             	add    $0x10,%esp
}
8010484b:	90                   	nop
8010484c:	c9                   	leave
8010484d:	c3                   	ret

8010484e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010484e:	f3 0f 1e fb          	endbr32
80104852:	55                   	push   %ebp
80104853:	89 e5                	mov    %esp,%ebp
80104855:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104858:	8b 45 08             	mov    0x8(%ebp),%eax
8010485b:	83 c0 04             	add    $0x4,%eax
8010485e:	83 ec 0c             	sub    $0xc,%esp
80104861:	50                   	push   %eax
80104862:	e8 80 00 00 00       	call   801048e7 <acquire>
80104867:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010486a:	8b 45 08             	mov    0x8(%ebp),%eax
8010486d:	8b 00                	mov    (%eax),%eax
8010486f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104872:	8b 45 08             	mov    0x8(%ebp),%eax
80104875:	83 c0 04             	add    $0x4,%eax
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	50                   	push   %eax
8010487c:	e8 d8 00 00 00       	call   80104959 <release>
80104881:	83 c4 10             	add    $0x10,%esp
  return r;
80104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104887:	c9                   	leave
80104888:	c3                   	ret

80104889 <readeflags>:
{
80104889:	55                   	push   %ebp
8010488a:	89 e5                	mov    %esp,%ebp
8010488c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010488f:	9c                   	pushf
80104890:	58                   	pop    %eax
80104891:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104894:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104897:	c9                   	leave
80104898:	c3                   	ret

80104899 <cli>:
{
80104899:	55                   	push   %ebp
8010489a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010489c:	fa                   	cli
}
8010489d:	90                   	nop
8010489e:	5d                   	pop    %ebp
8010489f:	c3                   	ret

801048a0 <sti>:
{
801048a0:	55                   	push   %ebp
801048a1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801048a3:	fb                   	sti
}
801048a4:	90                   	nop
801048a5:	5d                   	pop    %ebp
801048a6:	c3                   	ret

801048a7 <xchg>:
{
801048a7:	55                   	push   %ebp
801048a8:	89 e5                	mov    %esp,%ebp
801048aa:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801048ad:	8b 55 08             	mov    0x8(%ebp),%edx
801048b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801048b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801048b6:	f0 87 02             	lock xchg %eax,(%edx)
801048b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801048bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801048bf:	c9                   	leave
801048c0:	c3                   	ret

801048c1 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801048c1:	f3 0f 1e fb          	endbr32
801048c5:	55                   	push   %ebp
801048c6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801048c8:	8b 45 08             	mov    0x8(%ebp),%eax
801048cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801048ce:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801048d1:	8b 45 08             	mov    0x8(%ebp),%eax
801048d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801048da:	8b 45 08             	mov    0x8(%ebp),%eax
801048dd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801048e4:	90                   	nop
801048e5:	5d                   	pop    %ebp
801048e6:	c3                   	ret

801048e7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801048e7:	f3 0f 1e fb          	endbr32
801048eb:	55                   	push   %ebp
801048ec:	89 e5                	mov    %esp,%ebp
801048ee:	53                   	push   %ebx
801048ef:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801048f2:	e8 6c 01 00 00       	call   80104a63 <pushcli>
  if(holding(lk)){
801048f7:	8b 45 08             	mov    0x8(%ebp),%eax
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	50                   	push   %eax
801048fe:	e8 2b 01 00 00       	call   80104a2e <holding>
80104903:	83 c4 10             	add    $0x10,%esp
80104906:	85 c0                	test   %eax,%eax
80104908:	74 0d                	je     80104917 <acquire+0x30>
    panic("acquire");
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	68 aa a7 10 80       	push   $0x8010a7aa
80104912:	e8 ae bc ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104917:	90                   	nop
80104918:	8b 45 08             	mov    0x8(%ebp),%eax
8010491b:	83 ec 08             	sub    $0x8,%esp
8010491e:	6a 01                	push   $0x1
80104920:	50                   	push   %eax
80104921:	e8 81 ff ff ff       	call   801048a7 <xchg>
80104926:	83 c4 10             	add    $0x10,%esp
80104929:	85 c0                	test   %eax,%eax
8010492b:	75 eb                	jne    80104918 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010492d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104932:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104935:	e8 f3 f1 ff ff       	call   80103b2d <mycpu>
8010493a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010493d:	8b 45 08             	mov    0x8(%ebp),%eax
80104940:	83 c0 0c             	add    $0xc,%eax
80104943:	83 ec 08             	sub    $0x8,%esp
80104946:	50                   	push   %eax
80104947:	8d 45 08             	lea    0x8(%ebp),%eax
8010494a:	50                   	push   %eax
8010494b:	e8 5f 00 00 00       	call   801049af <getcallerpcs>
80104950:	83 c4 10             	add    $0x10,%esp
}
80104953:	90                   	nop
80104954:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104957:	c9                   	leave
80104958:	c3                   	ret

80104959 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104959:	f3 0f 1e fb          	endbr32
8010495d:	55                   	push   %ebp
8010495e:	89 e5                	mov    %esp,%ebp
80104960:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104963:	83 ec 0c             	sub    $0xc,%esp
80104966:	ff 75 08             	push   0x8(%ebp)
80104969:	e8 c0 00 00 00       	call   80104a2e <holding>
8010496e:	83 c4 10             	add    $0x10,%esp
80104971:	85 c0                	test   %eax,%eax
80104973:	75 0d                	jne    80104982 <release+0x29>
    panic("release");
80104975:	83 ec 0c             	sub    $0xc,%esp
80104978:	68 b2 a7 10 80       	push   $0x8010a7b2
8010497d:	e8 43 bc ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104982:	8b 45 08             	mov    0x8(%ebp),%eax
80104985:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010498c:	8b 45 08             	mov    0x8(%ebp),%eax
8010498f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104996:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	8b 55 08             	mov    0x8(%ebp),%edx
801049a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801049a7:	e8 08 01 00 00       	call   80104ab4 <popcli>
}
801049ac:	90                   	nop
801049ad:	c9                   	leave
801049ae:	c3                   	ret

801049af <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801049af:	f3 0f 1e fb          	endbr32
801049b3:	55                   	push   %ebp
801049b4:	89 e5                	mov    %esp,%ebp
801049b6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801049b9:	8b 45 08             	mov    0x8(%ebp),%eax
801049bc:	83 e8 08             	sub    $0x8,%eax
801049bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049c2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801049c9:	eb 38                	jmp    80104a03 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049cb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801049cf:	74 53                	je     80104a24 <getcallerpcs+0x75>
801049d1:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801049d8:	76 4a                	jbe    80104a24 <getcallerpcs+0x75>
801049da:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801049de:	74 44                	je     80104a24 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ed:	01 c2                	add    %eax,%edx
801049ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049f2:	8b 40 04             	mov    0x4(%eax),%eax
801049f5:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801049f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049fa:	8b 00                	mov    (%eax),%eax
801049fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049ff:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a03:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a07:	7e c2                	jle    801049cb <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104a09:	eb 19                	jmp    80104a24 <getcallerpcs+0x75>
    pcs[i] = 0;
80104a0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a18:	01 d0                	add    %edx,%eax
80104a1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a20:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a24:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a28:	7e e1                	jle    80104a0b <getcallerpcs+0x5c>
}
80104a2a:	90                   	nop
80104a2b:	90                   	nop
80104a2c:	c9                   	leave
80104a2d:	c3                   	ret

80104a2e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a2e:	f3 0f 1e fb          	endbr32
80104a32:	55                   	push   %ebp
80104a33:	89 e5                	mov    %esp,%ebp
80104a35:	53                   	push   %ebx
80104a36:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a39:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3c:	8b 00                	mov    (%eax),%eax
80104a3e:	85 c0                	test   %eax,%eax
80104a40:	74 16                	je     80104a58 <holding+0x2a>
80104a42:	8b 45 08             	mov    0x8(%ebp),%eax
80104a45:	8b 58 08             	mov    0x8(%eax),%ebx
80104a48:	e8 e0 f0 ff ff       	call   80103b2d <mycpu>
80104a4d:	39 c3                	cmp    %eax,%ebx
80104a4f:	75 07                	jne    80104a58 <holding+0x2a>
80104a51:	b8 01 00 00 00       	mov    $0x1,%eax
80104a56:	eb 05                	jmp    80104a5d <holding+0x2f>
80104a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a5d:	83 c4 04             	add    $0x4,%esp
80104a60:	5b                   	pop    %ebx
80104a61:	5d                   	pop    %ebp
80104a62:	c3                   	ret

80104a63 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a63:	f3 0f 1e fb          	endbr32
80104a67:	55                   	push   %ebp
80104a68:	89 e5                	mov    %esp,%ebp
80104a6a:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a6d:	e8 17 fe ff ff       	call   80104889 <readeflags>
80104a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a75:	e8 1f fe ff ff       	call   80104899 <cli>
  if(mycpu()->ncli == 0)
80104a7a:	e8 ae f0 ff ff       	call   80103b2d <mycpu>
80104a7f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a85:	85 c0                	test   %eax,%eax
80104a87:	75 14                	jne    80104a9d <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104a89:	e8 9f f0 ff ff       	call   80103b2d <mycpu>
80104a8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a91:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a97:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a9d:	e8 8b f0 ff ff       	call   80103b2d <mycpu>
80104aa2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104aa8:	83 c2 01             	add    $0x1,%edx
80104aab:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ab1:	90                   	nop
80104ab2:	c9                   	leave
80104ab3:	c3                   	ret

80104ab4 <popcli>:

void
popcli(void)
{
80104ab4:	f3 0f 1e fb          	endbr32
80104ab8:	55                   	push   %ebp
80104ab9:	89 e5                	mov    %esp,%ebp
80104abb:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104abe:	e8 c6 fd ff ff       	call   80104889 <readeflags>
80104ac3:	25 00 02 00 00       	and    $0x200,%eax
80104ac8:	85 c0                	test   %eax,%eax
80104aca:	74 0d                	je     80104ad9 <popcli+0x25>
    panic("popcli - interruptible");
80104acc:	83 ec 0c             	sub    $0xc,%esp
80104acf:	68 ba a7 10 80       	push   $0x8010a7ba
80104ad4:	e8 ec ba ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104ad9:	e8 4f f0 ff ff       	call   80103b2d <mycpu>
80104ade:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ae4:	83 ea 01             	sub    $0x1,%edx
80104ae7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104aed:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104af3:	85 c0                	test   %eax,%eax
80104af5:	79 0d                	jns    80104b04 <popcli+0x50>
    panic("popcli");
80104af7:	83 ec 0c             	sub    $0xc,%esp
80104afa:	68 d1 a7 10 80       	push   $0x8010a7d1
80104aff:	e8 c1 ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104b04:	e8 24 f0 ff ff       	call   80103b2d <mycpu>
80104b09:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b0f:	85 c0                	test   %eax,%eax
80104b11:	75 14                	jne    80104b27 <popcli+0x73>
80104b13:	e8 15 f0 ff ff       	call   80103b2d <mycpu>
80104b18:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	74 05                	je     80104b27 <popcli+0x73>
    sti();
80104b22:	e8 79 fd ff ff       	call   801048a0 <sti>
}
80104b27:	90                   	nop
80104b28:	c9                   	leave
80104b29:	c3                   	ret

80104b2a <stosb>:
{
80104b2a:	55                   	push   %ebp
80104b2b:	89 e5                	mov    %esp,%ebp
80104b2d:	57                   	push   %edi
80104b2e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b32:	8b 55 10             	mov    0x10(%ebp),%edx
80104b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b38:	89 cb                	mov    %ecx,%ebx
80104b3a:	89 df                	mov    %ebx,%edi
80104b3c:	89 d1                	mov    %edx,%ecx
80104b3e:	fc                   	cld
80104b3f:	f3 aa                	rep stos %al,%es:(%edi)
80104b41:	89 ca                	mov    %ecx,%edx
80104b43:	89 fb                	mov    %edi,%ebx
80104b45:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b48:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b4b:	90                   	nop
80104b4c:	5b                   	pop    %ebx
80104b4d:	5f                   	pop    %edi
80104b4e:	5d                   	pop    %ebp
80104b4f:	c3                   	ret

80104b50 <stosl>:
{
80104b50:	55                   	push   %ebp
80104b51:	89 e5                	mov    %esp,%ebp
80104b53:	57                   	push   %edi
80104b54:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b58:	8b 55 10             	mov    0x10(%ebp),%edx
80104b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b5e:	89 cb                	mov    %ecx,%ebx
80104b60:	89 df                	mov    %ebx,%edi
80104b62:	89 d1                	mov    %edx,%ecx
80104b64:	fc                   	cld
80104b65:	f3 ab                	rep stos %eax,%es:(%edi)
80104b67:	89 ca                	mov    %ecx,%edx
80104b69:	89 fb                	mov    %edi,%ebx
80104b6b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b6e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b71:	90                   	nop
80104b72:	5b                   	pop    %ebx
80104b73:	5f                   	pop    %edi
80104b74:	5d                   	pop    %ebp
80104b75:	c3                   	ret

80104b76 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b76:	f3 0f 1e fb          	endbr32
80104b7a:	55                   	push   %ebp
80104b7b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b80:	83 e0 03             	and    $0x3,%eax
80104b83:	85 c0                	test   %eax,%eax
80104b85:	75 43                	jne    80104bca <memset+0x54>
80104b87:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8a:	83 e0 03             	and    $0x3,%eax
80104b8d:	85 c0                	test   %eax,%eax
80104b8f:	75 39                	jne    80104bca <memset+0x54>
    c &= 0xFF;
80104b91:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b98:	8b 45 10             	mov    0x10(%ebp),%eax
80104b9b:	c1 e8 02             	shr    $0x2,%eax
80104b9e:	89 c1                	mov    %eax,%ecx
80104ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba3:	c1 e0 18             	shl    $0x18,%eax
80104ba6:	89 c2                	mov    %eax,%edx
80104ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bab:	c1 e0 10             	shl    $0x10,%eax
80104bae:	09 c2                	or     %eax,%edx
80104bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb3:	c1 e0 08             	shl    $0x8,%eax
80104bb6:	09 d0                	or     %edx,%eax
80104bb8:	0b 45 0c             	or     0xc(%ebp),%eax
80104bbb:	51                   	push   %ecx
80104bbc:	50                   	push   %eax
80104bbd:	ff 75 08             	push   0x8(%ebp)
80104bc0:	e8 8b ff ff ff       	call   80104b50 <stosl>
80104bc5:	83 c4 0c             	add    $0xc,%esp
80104bc8:	eb 12                	jmp    80104bdc <memset+0x66>
  } else
    stosb(dst, c, n);
80104bca:	8b 45 10             	mov    0x10(%ebp),%eax
80104bcd:	50                   	push   %eax
80104bce:	ff 75 0c             	push   0xc(%ebp)
80104bd1:	ff 75 08             	push   0x8(%ebp)
80104bd4:	e8 51 ff ff ff       	call   80104b2a <stosb>
80104bd9:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104bdc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bdf:	c9                   	leave
80104be0:	c3                   	ret

80104be1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104be1:	f3 0f 1e fb          	endbr32
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
80104be8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104beb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104bf7:	eb 30                	jmp    80104c29 <memcmp+0x48>
    if(*s1 != *s2)
80104bf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bfc:	0f b6 10             	movzbl (%eax),%edx
80104bff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c02:	0f b6 00             	movzbl (%eax),%eax
80104c05:	38 c2                	cmp    %al,%dl
80104c07:	74 18                	je     80104c21 <memcmp+0x40>
      return *s1 - *s2;
80104c09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0c:	0f b6 00             	movzbl (%eax),%eax
80104c0f:	0f b6 d0             	movzbl %al,%edx
80104c12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c15:	0f b6 00             	movzbl (%eax),%eax
80104c18:	0f b6 c0             	movzbl %al,%eax
80104c1b:	29 c2                	sub    %eax,%edx
80104c1d:	89 d0                	mov    %edx,%eax
80104c1f:	eb 1a                	jmp    80104c3b <memcmp+0x5a>
    s1++, s2++;
80104c21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c25:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c29:	8b 45 10             	mov    0x10(%ebp),%eax
80104c2c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c2f:	89 55 10             	mov    %edx,0x10(%ebp)
80104c32:	85 c0                	test   %eax,%eax
80104c34:	75 c3                	jne    80104bf9 <memcmp+0x18>
  }

  return 0;
80104c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c3b:	c9                   	leave
80104c3c:	c3                   	ret

80104c3d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c3d:	f3 0f 1e fb          	endbr32
80104c41:	55                   	push   %ebp
80104c42:	89 e5                	mov    %esp,%ebp
80104c44:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c56:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c59:	73 54                	jae    80104caf <memmove+0x72>
80104c5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c5e:	8b 45 10             	mov    0x10(%ebp),%eax
80104c61:	01 d0                	add    %edx,%eax
80104c63:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104c66:	73 47                	jae    80104caf <memmove+0x72>
    s += n;
80104c68:	8b 45 10             	mov    0x10(%ebp),%eax
80104c6b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104c6e:	8b 45 10             	mov    0x10(%ebp),%eax
80104c71:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c74:	eb 13                	jmp    80104c89 <memmove+0x4c>
      *--d = *--s;
80104c76:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c7a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c81:	0f b6 10             	movzbl (%eax),%edx
80104c84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c87:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c89:	8b 45 10             	mov    0x10(%ebp),%eax
80104c8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c8f:	89 55 10             	mov    %edx,0x10(%ebp)
80104c92:	85 c0                	test   %eax,%eax
80104c94:	75 e0                	jne    80104c76 <memmove+0x39>
  if(s < d && s + n > d){
80104c96:	eb 24                	jmp    80104cbc <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c9b:	8d 42 01             	lea    0x1(%edx),%eax
80104c9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104ca1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ca4:	8d 48 01             	lea    0x1(%eax),%ecx
80104ca7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104caa:	0f b6 12             	movzbl (%edx),%edx
80104cad:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104caf:	8b 45 10             	mov    0x10(%ebp),%eax
80104cb2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cb5:	89 55 10             	mov    %edx,0x10(%ebp)
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	75 dc                	jne    80104c98 <memmove+0x5b>

  return dst;
80104cbc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104cbf:	c9                   	leave
80104cc0:	c3                   	ret

80104cc1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104cc1:	f3 0f 1e fb          	endbr32
80104cc5:	55                   	push   %ebp
80104cc6:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104cc8:	ff 75 10             	push   0x10(%ebp)
80104ccb:	ff 75 0c             	push   0xc(%ebp)
80104cce:	ff 75 08             	push   0x8(%ebp)
80104cd1:	e8 67 ff ff ff       	call   80104c3d <memmove>
80104cd6:	83 c4 0c             	add    $0xc,%esp
}
80104cd9:	c9                   	leave
80104cda:	c3                   	ret

80104cdb <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104cdb:	f3 0f 1e fb          	endbr32
80104cdf:	55                   	push   %ebp
80104ce0:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ce2:	eb 0c                	jmp    80104cf0 <strncmp+0x15>
    n--, p++, q++;
80104ce4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ce8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104cec:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104cf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cf4:	74 1a                	je     80104d10 <strncmp+0x35>
80104cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf9:	0f b6 00             	movzbl (%eax),%eax
80104cfc:	84 c0                	test   %al,%al
80104cfe:	74 10                	je     80104d10 <strncmp+0x35>
80104d00:	8b 45 08             	mov    0x8(%ebp),%eax
80104d03:	0f b6 10             	movzbl (%eax),%edx
80104d06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d09:	0f b6 00             	movzbl (%eax),%eax
80104d0c:	38 c2                	cmp    %al,%dl
80104d0e:	74 d4                	je     80104ce4 <strncmp+0x9>
  if(n == 0)
80104d10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d14:	75 07                	jne    80104d1d <strncmp+0x42>
    return 0;
80104d16:	b8 00 00 00 00       	mov    $0x0,%eax
80104d1b:	eb 16                	jmp    80104d33 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104d1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d20:	0f b6 00             	movzbl (%eax),%eax
80104d23:	0f b6 d0             	movzbl %al,%edx
80104d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d29:	0f b6 00             	movzbl (%eax),%eax
80104d2c:	0f b6 c0             	movzbl %al,%eax
80104d2f:	29 c2                	sub    %eax,%edx
80104d31:	89 d0                	mov    %edx,%eax
}
80104d33:	5d                   	pop    %ebp
80104d34:	c3                   	ret

80104d35 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d35:	f3 0f 1e fb          	endbr32
80104d39:	55                   	push   %ebp
80104d3a:	89 e5                	mov    %esp,%ebp
80104d3c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d45:	90                   	nop
80104d46:	8b 45 10             	mov    0x10(%ebp),%eax
80104d49:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d4c:	89 55 10             	mov    %edx,0x10(%ebp)
80104d4f:	85 c0                	test   %eax,%eax
80104d51:	7e 2c                	jle    80104d7f <strncpy+0x4a>
80104d53:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d56:	8d 42 01             	lea    0x1(%edx),%eax
80104d59:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5f:	8d 48 01             	lea    0x1(%eax),%ecx
80104d62:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d65:	0f b6 12             	movzbl (%edx),%edx
80104d68:	88 10                	mov    %dl,(%eax)
80104d6a:	0f b6 00             	movzbl (%eax),%eax
80104d6d:	84 c0                	test   %al,%al
80104d6f:	75 d5                	jne    80104d46 <strncpy+0x11>
    ;
  while(n-- > 0)
80104d71:	eb 0c                	jmp    80104d7f <strncpy+0x4a>
    *s++ = 0;
80104d73:	8b 45 08             	mov    0x8(%ebp),%eax
80104d76:	8d 50 01             	lea    0x1(%eax),%edx
80104d79:	89 55 08             	mov    %edx,0x8(%ebp)
80104d7c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d7f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d82:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d85:	89 55 10             	mov    %edx,0x10(%ebp)
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	7f e7                	jg     80104d73 <strncpy+0x3e>
  return os;
80104d8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d8f:	c9                   	leave
80104d90:	c3                   	ret

80104d91 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d91:	f3 0f 1e fb          	endbr32
80104d95:	55                   	push   %ebp
80104d96:	89 e5                	mov    %esp,%ebp
80104d98:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104da5:	7f 05                	jg     80104dac <safestrcpy+0x1b>
    return os;
80104da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104daa:	eb 31                	jmp    80104ddd <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104dac:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104db4:	7e 1e                	jle    80104dd4 <safestrcpy+0x43>
80104db6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104db9:	8d 42 01             	lea    0x1(%edx),%eax
80104dbc:	89 45 0c             	mov    %eax,0xc(%ebp)
80104dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc2:	8d 48 01             	lea    0x1(%eax),%ecx
80104dc5:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104dc8:	0f b6 12             	movzbl (%edx),%edx
80104dcb:	88 10                	mov    %dl,(%eax)
80104dcd:	0f b6 00             	movzbl (%eax),%eax
80104dd0:	84 c0                	test   %al,%al
80104dd2:	75 d8                	jne    80104dac <safestrcpy+0x1b>
    ;
  *s = 0;
80104dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ddd:	c9                   	leave
80104dde:	c3                   	ret

80104ddf <strlen>:

int
strlen(const char *s)
{
80104ddf:	f3 0f 1e fb          	endbr32
80104de3:	55                   	push   %ebp
80104de4:	89 e5                	mov    %esp,%ebp
80104de6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104de9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104df0:	eb 04                	jmp    80104df6 <strlen+0x17>
80104df2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104df6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104df9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfc:	01 d0                	add    %edx,%eax
80104dfe:	0f b6 00             	movzbl (%eax),%eax
80104e01:	84 c0                	test   %al,%al
80104e03:	75 ed                	jne    80104df2 <strlen+0x13>
    ;
  return n;
80104e05:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e08:	c9                   	leave
80104e09:	c3                   	ret

80104e0a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e0a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e0e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104e12:	55                   	push   %ebp
  pushl %ebx
80104e13:	53                   	push   %ebx
  pushl %esi
80104e14:	56                   	push   %esi
  pushl %edi
80104e15:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e16:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e18:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e1a:	5f                   	pop    %edi
  popl %esi
80104e1b:	5e                   	pop    %esi
  popl %ebx
80104e1c:	5b                   	pop    %ebx
  popl %ebp
80104e1d:	5d                   	pop    %ebp
  ret
80104e1e:	c3                   	ret

80104e1f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e1f:	f3 0f 1e fb          	endbr32
80104e23:	55                   	push   %ebp
80104e24:	89 e5                	mov    %esp,%ebp
80104e26:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e29:	e8 7b ed ff ff       	call   80103ba9 <myproc>
80104e2e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e34:	8b 00                	mov    (%eax),%eax
80104e36:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e39:	73 0f                	jae    80104e4a <fetchint+0x2b>
80104e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3e:	8d 50 04             	lea    0x4(%eax),%edx
80104e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e44:	8b 00                	mov    (%eax),%eax
80104e46:	39 c2                	cmp    %eax,%edx
80104e48:	76 07                	jbe    80104e51 <fetchint+0x32>
    return -1;
80104e4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4f:	eb 0f                	jmp    80104e60 <fetchint+0x41>
  *ip = *(int*)(addr);
80104e51:	8b 45 08             	mov    0x8(%ebp),%eax
80104e54:	8b 10                	mov    (%eax),%edx
80104e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e59:	89 10                	mov    %edx,(%eax)
  return 0;
80104e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e60:	c9                   	leave
80104e61:	c3                   	ret

80104e62 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e62:	f3 0f 1e fb          	endbr32
80104e66:	55                   	push   %ebp
80104e67:	89 e5                	mov    %esp,%ebp
80104e69:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104e6c:	e8 38 ed ff ff       	call   80103ba9 <myproc>
80104e71:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e77:	8b 00                	mov    (%eax),%eax
80104e79:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e7c:	72 07                	jb     80104e85 <fetchstr+0x23>
    return -1;
80104e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e83:	eb 43                	jmp    80104ec8 <fetchstr+0x66>
  *pp = (char*)addr;
80104e85:	8b 55 08             	mov    0x8(%ebp),%edx
80104e88:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8b:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e90:	8b 00                	mov    (%eax),%eax
80104e92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e98:	8b 00                	mov    (%eax),%eax
80104e9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e9d:	eb 1c                	jmp    80104ebb <fetchstr+0x59>
    if(*s == 0)
80104e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea2:	0f b6 00             	movzbl (%eax),%eax
80104ea5:	84 c0                	test   %al,%al
80104ea7:	75 0e                	jne    80104eb7 <fetchstr+0x55>
      return s - *pp;
80104ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eac:	8b 00                	mov    (%eax),%eax
80104eae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb1:	29 c2                	sub    %eax,%edx
80104eb3:	89 d0                	mov    %edx,%eax
80104eb5:	eb 11                	jmp    80104ec8 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80104eb7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ec1:	72 dc                	jb     80104e9f <fetchstr+0x3d>
  }
  return -1;
80104ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec8:	c9                   	leave
80104ec9:	c3                   	ret

80104eca <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104eca:	f3 0f 1e fb          	endbr32
80104ece:	55                   	push   %ebp
80104ecf:	89 e5                	mov    %esp,%ebp
80104ed1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ed4:	e8 d0 ec ff ff       	call   80103ba9 <myproc>
80104ed9:	8b 40 18             	mov    0x18(%eax),%eax
80104edc:	8b 40 44             	mov    0x44(%eax),%eax
80104edf:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee2:	c1 e2 02             	shl    $0x2,%edx
80104ee5:	01 d0                	add    %edx,%eax
80104ee7:	83 c0 04             	add    $0x4,%eax
80104eea:	83 ec 08             	sub    $0x8,%esp
80104eed:	ff 75 0c             	push   0xc(%ebp)
80104ef0:	50                   	push   %eax
80104ef1:	e8 29 ff ff ff       	call   80104e1f <fetchint>
80104ef6:	83 c4 10             	add    $0x10,%esp
}
80104ef9:	c9                   	leave
80104efa:	c3                   	ret

80104efb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104efb:	f3 0f 1e fb          	endbr32
80104eff:	55                   	push   %ebp
80104f00:	89 e5                	mov    %esp,%ebp
80104f02:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104f05:	e8 9f ec ff ff       	call   80103ba9 <myproc>
80104f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104f0d:	83 ec 08             	sub    $0x8,%esp
80104f10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f13:	50                   	push   %eax
80104f14:	ff 75 08             	push   0x8(%ebp)
80104f17:	e8 ae ff ff ff       	call   80104eca <argint>
80104f1c:	83 c4 10             	add    $0x10,%esp
80104f1f:	85 c0                	test   %eax,%eax
80104f21:	79 07                	jns    80104f2a <argptr+0x2f>
    return -1;
80104f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f28:	eb 3b                	jmp    80104f65 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f2e:	78 1f                	js     80104f4f <argptr+0x54>
80104f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f33:	8b 00                	mov    (%eax),%eax
80104f35:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f38:	39 d0                	cmp    %edx,%eax
80104f3a:	76 13                	jbe    80104f4f <argptr+0x54>
80104f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3f:	89 c2                	mov    %eax,%edx
80104f41:	8b 45 10             	mov    0x10(%ebp),%eax
80104f44:	01 c2                	add    %eax,%edx
80104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f49:	8b 00                	mov    (%eax),%eax
80104f4b:	39 c2                	cmp    %eax,%edx
80104f4d:	76 07                	jbe    80104f56 <argptr+0x5b>
    return -1;
80104f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f54:	eb 0f                	jmp    80104f65 <argptr+0x6a>
  *pp = (char*)i;
80104f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f59:	89 c2                	mov    %eax,%edx
80104f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5e:	89 10                	mov    %edx,(%eax)
  return 0;
80104f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f65:	c9                   	leave
80104f66:	c3                   	ret

80104f67 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f67:	f3 0f 1e fb          	endbr32
80104f6b:	55                   	push   %ebp
80104f6c:	89 e5                	mov    %esp,%ebp
80104f6e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104f71:	83 ec 08             	sub    $0x8,%esp
80104f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f77:	50                   	push   %eax
80104f78:	ff 75 08             	push   0x8(%ebp)
80104f7b:	e8 4a ff ff ff       	call   80104eca <argint>
80104f80:	83 c4 10             	add    $0x10,%esp
80104f83:	85 c0                	test   %eax,%eax
80104f85:	79 07                	jns    80104f8e <argstr+0x27>
    return -1;
80104f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f8c:	eb 12                	jmp    80104fa0 <argstr+0x39>
  return fetchstr(addr, pp);
80104f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f91:	83 ec 08             	sub    $0x8,%esp
80104f94:	ff 75 0c             	push   0xc(%ebp)
80104f97:	50                   	push   %eax
80104f98:	e8 c5 fe ff ff       	call   80104e62 <fetchstr>
80104f9d:	83 c4 10             	add    $0x10,%esp
}
80104fa0:	c9                   	leave
80104fa1:	c3                   	ret

80104fa2 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104fa2:	f3 0f 1e fb          	endbr32
80104fa6:	55                   	push   %ebp
80104fa7:	89 e5                	mov    %esp,%ebp
80104fa9:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104fac:	e8 f8 eb ff ff       	call   80103ba9 <myproc>
80104fb1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb7:	8b 40 18             	mov    0x18(%eax),%eax
80104fba:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104fc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fc4:	7e 2f                	jle    80104ff5 <syscall+0x53>
80104fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc9:	83 f8 16             	cmp    $0x16,%eax
80104fcc:	77 27                	ja     80104ff5 <syscall+0x53>
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fd8:	85 c0                	test   %eax,%eax
80104fda:	74 19                	je     80104ff5 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80104fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdf:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fe6:	ff d0                	call   *%eax
80104fe8:	89 c2                	mov    %eax,%edx
80104fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fed:	8b 40 18             	mov    0x18(%eax),%eax
80104ff0:	89 50 1c             	mov    %edx,0x1c(%eax)
80104ff3:	eb 2c                	jmp    80105021 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff8:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ffe:	8b 40 10             	mov    0x10(%eax),%eax
80105001:	ff 75 f0             	push   -0x10(%ebp)
80105004:	52                   	push   %edx
80105005:	50                   	push   %eax
80105006:	68 d8 a7 10 80       	push   $0x8010a7d8
8010500b:	e8 fc b3 ff ff       	call   8010040c <cprintf>
80105010:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105016:	8b 40 18             	mov    0x18(%eax),%eax
80105019:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105020:	90                   	nop
80105021:	90                   	nop
80105022:	c9                   	leave
80105023:	c3                   	ret

80105024 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105024:	f3 0f 1e fb          	endbr32
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010502e:	83 ec 08             	sub    $0x8,%esp
80105031:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105034:	50                   	push   %eax
80105035:	ff 75 08             	push   0x8(%ebp)
80105038:	e8 8d fe ff ff       	call   80104eca <argint>
8010503d:	83 c4 10             	add    $0x10,%esp
80105040:	85 c0                	test   %eax,%eax
80105042:	79 07                	jns    8010504b <argfd+0x27>
    return -1;
80105044:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105049:	eb 4f                	jmp    8010509a <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010504b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504e:	85 c0                	test   %eax,%eax
80105050:	78 20                	js     80105072 <argfd+0x4e>
80105052:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105055:	83 f8 0f             	cmp    $0xf,%eax
80105058:	7f 18                	jg     80105072 <argfd+0x4e>
8010505a:	e8 4a eb ff ff       	call   80103ba9 <myproc>
8010505f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105062:	83 c2 08             	add    $0x8,%edx
80105065:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105069:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010506c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105070:	75 07                	jne    80105079 <argfd+0x55>
    return -1;
80105072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105077:	eb 21                	jmp    8010509a <argfd+0x76>
  if(pfd)
80105079:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010507d:	74 08                	je     80105087 <argfd+0x63>
    *pfd = fd;
8010507f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105082:	8b 45 0c             	mov    0xc(%ebp),%eax
80105085:	89 10                	mov    %edx,(%eax)
  if(pf)
80105087:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010508b:	74 08                	je     80105095 <argfd+0x71>
    *pf = f;
8010508d:	8b 45 10             	mov    0x10(%ebp),%eax
80105090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105093:	89 10                	mov    %edx,(%eax)
  return 0;
80105095:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010509a:	c9                   	leave
8010509b:	c3                   	ret

8010509c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010509c:	f3 0f 1e fb          	endbr32
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801050a6:	e8 fe ea ff ff       	call   80103ba9 <myproc>
801050ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801050ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050b5:	eb 2a                	jmp    801050e1 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801050b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050bd:	83 c2 08             	add    $0x8,%edx
801050c0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050c4:	85 c0                	test   %eax,%eax
801050c6:	75 15                	jne    801050dd <fdalloc+0x41>
      curproc->ofile[fd] = f;
801050c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050ce:	8d 4a 08             	lea    0x8(%edx),%ecx
801050d1:	8b 55 08             	mov    0x8(%ebp),%edx
801050d4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801050d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050db:	eb 0f                	jmp    801050ec <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801050dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050e1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050e5:	7e d0                	jle    801050b7 <fdalloc+0x1b>
    }
  }
  return -1;
801050e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050ec:	c9                   	leave
801050ed:	c3                   	ret

801050ee <sys_dup>:

int
sys_dup(void)
{
801050ee:	f3 0f 1e fb          	endbr32
801050f2:	55                   	push   %ebp
801050f3:	89 e5                	mov    %esp,%ebp
801050f5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801050f8:	83 ec 04             	sub    $0x4,%esp
801050fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050fe:	50                   	push   %eax
801050ff:	6a 00                	push   $0x0
80105101:	6a 00                	push   $0x0
80105103:	e8 1c ff ff ff       	call   80105024 <argfd>
80105108:	83 c4 10             	add    $0x10,%esp
8010510b:	85 c0                	test   %eax,%eax
8010510d:	79 07                	jns    80105116 <sys_dup+0x28>
    return -1;
8010510f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105114:	eb 31                	jmp    80105147 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105119:	83 ec 0c             	sub    $0xc,%esp
8010511c:	50                   	push   %eax
8010511d:	e8 7a ff ff ff       	call   8010509c <fdalloc>
80105122:	83 c4 10             	add    $0x10,%esp
80105125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105128:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010512c:	79 07                	jns    80105135 <sys_dup+0x47>
    return -1;
8010512e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105133:	eb 12                	jmp    80105147 <sys_dup+0x59>
  filedup(f);
80105135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105138:	83 ec 0c             	sub    $0xc,%esp
8010513b:	50                   	push   %eax
8010513c:	e8 53 bf ff ff       	call   80101094 <filedup>
80105141:	83 c4 10             	add    $0x10,%esp
  return fd;
80105144:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105147:	c9                   	leave
80105148:	c3                   	ret

80105149 <sys_read>:

int
sys_read(void)
{
80105149:	f3 0f 1e fb          	endbr32
8010514d:	55                   	push   %ebp
8010514e:	89 e5                	mov    %esp,%ebp
80105150:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105153:	83 ec 04             	sub    $0x4,%esp
80105156:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105159:	50                   	push   %eax
8010515a:	6a 00                	push   $0x0
8010515c:	6a 00                	push   $0x0
8010515e:	e8 c1 fe ff ff       	call   80105024 <argfd>
80105163:	83 c4 10             	add    $0x10,%esp
80105166:	85 c0                	test   %eax,%eax
80105168:	78 2e                	js     80105198 <sys_read+0x4f>
8010516a:	83 ec 08             	sub    $0x8,%esp
8010516d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105170:	50                   	push   %eax
80105171:	6a 02                	push   $0x2
80105173:	e8 52 fd ff ff       	call   80104eca <argint>
80105178:	83 c4 10             	add    $0x10,%esp
8010517b:	85 c0                	test   %eax,%eax
8010517d:	78 19                	js     80105198 <sys_read+0x4f>
8010517f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105182:	83 ec 04             	sub    $0x4,%esp
80105185:	50                   	push   %eax
80105186:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105189:	50                   	push   %eax
8010518a:	6a 01                	push   $0x1
8010518c:	e8 6a fd ff ff       	call   80104efb <argptr>
80105191:	83 c4 10             	add    $0x10,%esp
80105194:	85 c0                	test   %eax,%eax
80105196:	79 07                	jns    8010519f <sys_read+0x56>
    return -1;
80105198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010519d:	eb 17                	jmp    801051b6 <sys_read+0x6d>
  return fileread(f, p, n);
8010519f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a8:	83 ec 04             	sub    $0x4,%esp
801051ab:	51                   	push   %ecx
801051ac:	52                   	push   %edx
801051ad:	50                   	push   %eax
801051ae:	e8 7d c0 ff ff       	call   80101230 <fileread>
801051b3:	83 c4 10             	add    $0x10,%esp
}
801051b6:	c9                   	leave
801051b7:	c3                   	ret

801051b8 <sys_write>:

int
sys_write(void)
{
801051b8:	f3 0f 1e fb          	endbr32
801051bc:	55                   	push   %ebp
801051bd:	89 e5                	mov    %esp,%ebp
801051bf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051c2:	83 ec 04             	sub    $0x4,%esp
801051c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051c8:	50                   	push   %eax
801051c9:	6a 00                	push   $0x0
801051cb:	6a 00                	push   $0x0
801051cd:	e8 52 fe ff ff       	call   80105024 <argfd>
801051d2:	83 c4 10             	add    $0x10,%esp
801051d5:	85 c0                	test   %eax,%eax
801051d7:	78 2e                	js     80105207 <sys_write+0x4f>
801051d9:	83 ec 08             	sub    $0x8,%esp
801051dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051df:	50                   	push   %eax
801051e0:	6a 02                	push   $0x2
801051e2:	e8 e3 fc ff ff       	call   80104eca <argint>
801051e7:	83 c4 10             	add    $0x10,%esp
801051ea:	85 c0                	test   %eax,%eax
801051ec:	78 19                	js     80105207 <sys_write+0x4f>
801051ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f1:	83 ec 04             	sub    $0x4,%esp
801051f4:	50                   	push   %eax
801051f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051f8:	50                   	push   %eax
801051f9:	6a 01                	push   $0x1
801051fb:	e8 fb fc ff ff       	call   80104efb <argptr>
80105200:	83 c4 10             	add    $0x10,%esp
80105203:	85 c0                	test   %eax,%eax
80105205:	79 07                	jns    8010520e <sys_write+0x56>
    return -1;
80105207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520c:	eb 17                	jmp    80105225 <sys_write+0x6d>
  return filewrite(f, p, n);
8010520e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105211:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105217:	83 ec 04             	sub    $0x4,%esp
8010521a:	51                   	push   %ecx
8010521b:	52                   	push   %edx
8010521c:	50                   	push   %eax
8010521d:	e8 ca c0 ff ff       	call   801012ec <filewrite>
80105222:	83 c4 10             	add    $0x10,%esp
}
80105225:	c9                   	leave
80105226:	c3                   	ret

80105227 <sys_close>:

int
sys_close(void)
{
80105227:	f3 0f 1e fb          	endbr32
8010522b:	55                   	push   %ebp
8010522c:	89 e5                	mov    %esp,%ebp
8010522e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105231:	83 ec 04             	sub    $0x4,%esp
80105234:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105237:	50                   	push   %eax
80105238:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010523b:	50                   	push   %eax
8010523c:	6a 00                	push   $0x0
8010523e:	e8 e1 fd ff ff       	call   80105024 <argfd>
80105243:	83 c4 10             	add    $0x10,%esp
80105246:	85 c0                	test   %eax,%eax
80105248:	79 07                	jns    80105251 <sys_close+0x2a>
    return -1;
8010524a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524f:	eb 27                	jmp    80105278 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105251:	e8 53 e9 ff ff       	call   80103ba9 <myproc>
80105256:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105259:	83 c2 08             	add    $0x8,%edx
8010525c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105263:	00 
  fileclose(f);
80105264:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105267:	83 ec 0c             	sub    $0xc,%esp
8010526a:	50                   	push   %eax
8010526b:	e8 79 be ff ff       	call   801010e9 <fileclose>
80105270:	83 c4 10             	add    $0x10,%esp
  return 0;
80105273:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105278:	c9                   	leave
80105279:	c3                   	ret

8010527a <sys_fstat>:

int
sys_fstat(void)
{
8010527a:	f3 0f 1e fb          	endbr32
8010527e:	55                   	push   %ebp
8010527f:	89 e5                	mov    %esp,%ebp
80105281:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105284:	83 ec 04             	sub    $0x4,%esp
80105287:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010528a:	50                   	push   %eax
8010528b:	6a 00                	push   $0x0
8010528d:	6a 00                	push   $0x0
8010528f:	e8 90 fd ff ff       	call   80105024 <argfd>
80105294:	83 c4 10             	add    $0x10,%esp
80105297:	85 c0                	test   %eax,%eax
80105299:	78 17                	js     801052b2 <sys_fstat+0x38>
8010529b:	83 ec 04             	sub    $0x4,%esp
8010529e:	6a 14                	push   $0x14
801052a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a3:	50                   	push   %eax
801052a4:	6a 01                	push   $0x1
801052a6:	e8 50 fc ff ff       	call   80104efb <argptr>
801052ab:	83 c4 10             	add    $0x10,%esp
801052ae:	85 c0                	test   %eax,%eax
801052b0:	79 07                	jns    801052b9 <sys_fstat+0x3f>
    return -1;
801052b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b7:	eb 13                	jmp    801052cc <sys_fstat+0x52>
  return filestat(f, st);
801052b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bf:	83 ec 08             	sub    $0x8,%esp
801052c2:	52                   	push   %edx
801052c3:	50                   	push   %eax
801052c4:	e8 0c bf ff ff       	call   801011d5 <filestat>
801052c9:	83 c4 10             	add    $0x10,%esp
}
801052cc:	c9                   	leave
801052cd:	c3                   	ret

801052ce <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801052ce:	f3 0f 1e fb          	endbr32
801052d2:	55                   	push   %ebp
801052d3:	89 e5                	mov    %esp,%ebp
801052d5:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801052d8:	83 ec 08             	sub    $0x8,%esp
801052db:	8d 45 d8             	lea    -0x28(%ebp),%eax
801052de:	50                   	push   %eax
801052df:	6a 00                	push   $0x0
801052e1:	e8 81 fc ff ff       	call   80104f67 <argstr>
801052e6:	83 c4 10             	add    $0x10,%esp
801052e9:	85 c0                	test   %eax,%eax
801052eb:	78 15                	js     80105302 <sys_link+0x34>
801052ed:	83 ec 08             	sub    $0x8,%esp
801052f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801052f3:	50                   	push   %eax
801052f4:	6a 01                	push   $0x1
801052f6:	e8 6c fc ff ff       	call   80104f67 <argstr>
801052fb:	83 c4 10             	add    $0x10,%esp
801052fe:	85 c0                	test   %eax,%eax
80105300:	79 0a                	jns    8010530c <sys_link+0x3e>
    return -1;
80105302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105307:	e9 68 01 00 00       	jmp    80105474 <sys_link+0x1a6>

  begin_op();
8010530c:	e8 60 de ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105311:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105314:	83 ec 0c             	sub    $0xc,%esp
80105317:	50                   	push   %eax
80105318:	e8 ca d2 ff ff       	call   801025e7 <namei>
8010531d:	83 c4 10             	add    $0x10,%esp
80105320:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105327:	75 0f                	jne    80105338 <sys_link+0x6a>
    end_op();
80105329:	e8 d3 de ff ff       	call   80103201 <end_op>
    return -1;
8010532e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105333:	e9 3c 01 00 00       	jmp    80105474 <sys_link+0x1a6>
  }

  ilock(ip);
80105338:	83 ec 0c             	sub    $0xc,%esp
8010533b:	ff 75 f4             	push   -0xc(%ebp)
8010533e:	e8 39 c7 ff ff       	call   80101a7c <ilock>
80105343:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105349:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010534d:	66 83 f8 01          	cmp    $0x1,%ax
80105351:	75 1d                	jne    80105370 <sys_link+0xa2>
    iunlockput(ip);
80105353:	83 ec 0c             	sub    $0xc,%esp
80105356:	ff 75 f4             	push   -0xc(%ebp)
80105359:	e8 5b c9 ff ff       	call   80101cb9 <iunlockput>
8010535e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105361:	e8 9b de ff ff       	call   80103201 <end_op>
    return -1;
80105366:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010536b:	e9 04 01 00 00       	jmp    80105474 <sys_link+0x1a6>
  }

  ip->nlink++;
80105370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105373:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105377:	83 c0 01             	add    $0x1,%eax
8010537a:	89 c2                	mov    %eax,%edx
8010537c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105383:	83 ec 0c             	sub    $0xc,%esp
80105386:	ff 75 f4             	push   -0xc(%ebp)
80105389:	e8 05 c5 ff ff       	call   80101893 <iupdate>
8010538e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105391:	83 ec 0c             	sub    $0xc,%esp
80105394:	ff 75 f4             	push   -0xc(%ebp)
80105397:	e8 f7 c7 ff ff       	call   80101b93 <iunlock>
8010539c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010539f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801053a2:	83 ec 08             	sub    $0x8,%esp
801053a5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801053a8:	52                   	push   %edx
801053a9:	50                   	push   %eax
801053aa:	e8 58 d2 ff ff       	call   80102607 <nameiparent>
801053af:	83 c4 10             	add    $0x10,%esp
801053b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053b9:	74 71                	je     8010542c <sys_link+0x15e>
    goto bad;
  ilock(dp);
801053bb:	83 ec 0c             	sub    $0xc,%esp
801053be:	ff 75 f0             	push   -0x10(%ebp)
801053c1:	e8 b6 c6 ff ff       	call   80101a7c <ilock>
801053c6:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801053c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053cc:	8b 10                	mov    (%eax),%edx
801053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d1:	8b 00                	mov    (%eax),%eax
801053d3:	39 c2                	cmp    %eax,%edx
801053d5:	75 1d                	jne    801053f4 <sys_link+0x126>
801053d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053da:	8b 40 04             	mov    0x4(%eax),%eax
801053dd:	83 ec 04             	sub    $0x4,%esp
801053e0:	50                   	push   %eax
801053e1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801053e4:	50                   	push   %eax
801053e5:	ff 75 f0             	push   -0x10(%ebp)
801053e8:	e8 57 cf ff ff       	call   80102344 <dirlink>
801053ed:	83 c4 10             	add    $0x10,%esp
801053f0:	85 c0                	test   %eax,%eax
801053f2:	79 10                	jns    80105404 <sys_link+0x136>
    iunlockput(dp);
801053f4:	83 ec 0c             	sub    $0xc,%esp
801053f7:	ff 75 f0             	push   -0x10(%ebp)
801053fa:	e8 ba c8 ff ff       	call   80101cb9 <iunlockput>
801053ff:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105402:	eb 29                	jmp    8010542d <sys_link+0x15f>
  }
  iunlockput(dp);
80105404:	83 ec 0c             	sub    $0xc,%esp
80105407:	ff 75 f0             	push   -0x10(%ebp)
8010540a:	e8 aa c8 ff ff       	call   80101cb9 <iunlockput>
8010540f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105412:	83 ec 0c             	sub    $0xc,%esp
80105415:	ff 75 f4             	push   -0xc(%ebp)
80105418:	e8 c8 c7 ff ff       	call   80101be5 <iput>
8010541d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105420:	e8 dc dd ff ff       	call   80103201 <end_op>

  return 0;
80105425:	b8 00 00 00 00       	mov    $0x0,%eax
8010542a:	eb 48                	jmp    80105474 <sys_link+0x1a6>
    goto bad;
8010542c:	90                   	nop

bad:
  ilock(ip);
8010542d:	83 ec 0c             	sub    $0xc,%esp
80105430:	ff 75 f4             	push   -0xc(%ebp)
80105433:	e8 44 c6 ff ff       	call   80101a7c <ilock>
80105438:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010543b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010543e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105442:	83 e8 01             	sub    $0x1,%eax
80105445:	89 c2                	mov    %eax,%edx
80105447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010544e:	83 ec 0c             	sub    $0xc,%esp
80105451:	ff 75 f4             	push   -0xc(%ebp)
80105454:	e8 3a c4 ff ff       	call   80101893 <iupdate>
80105459:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010545c:	83 ec 0c             	sub    $0xc,%esp
8010545f:	ff 75 f4             	push   -0xc(%ebp)
80105462:	e8 52 c8 ff ff       	call   80101cb9 <iunlockput>
80105467:	83 c4 10             	add    $0x10,%esp
  end_op();
8010546a:	e8 92 dd ff ff       	call   80103201 <end_op>
  return -1;
8010546f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105474:	c9                   	leave
80105475:	c3                   	ret

80105476 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105476:	f3 0f 1e fb          	endbr32
8010547a:	55                   	push   %ebp
8010547b:	89 e5                	mov    %esp,%ebp
8010547d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105480:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105487:	eb 40                	jmp    801054c9 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010548c:	6a 10                	push   $0x10
8010548e:	50                   	push   %eax
8010548f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105492:	50                   	push   %eax
80105493:	ff 75 08             	push   0x8(%ebp)
80105496:	e8 e9 ca ff ff       	call   80101f84 <readi>
8010549b:	83 c4 10             	add    $0x10,%esp
8010549e:	83 f8 10             	cmp    $0x10,%eax
801054a1:	74 0d                	je     801054b0 <isdirempty+0x3a>
      panic("isdirempty: readi");
801054a3:	83 ec 0c             	sub    $0xc,%esp
801054a6:	68 f4 a7 10 80       	push   $0x8010a7f4
801054ab:	e8 15 b1 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
801054b0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801054b4:	66 85 c0             	test   %ax,%ax
801054b7:	74 07                	je     801054c0 <isdirempty+0x4a>
      return 0;
801054b9:	b8 00 00 00 00       	mov    $0x0,%eax
801054be:	eb 1b                	jmp    801054db <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c3:	83 c0 10             	add    $0x10,%eax
801054c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054c9:	8b 45 08             	mov    0x8(%ebp),%eax
801054cc:	8b 50 58             	mov    0x58(%eax),%edx
801054cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d2:	39 c2                	cmp    %eax,%edx
801054d4:	77 b3                	ja     80105489 <isdirempty+0x13>
  }
  return 1;
801054d6:	b8 01 00 00 00       	mov    $0x1,%eax
}
801054db:	c9                   	leave
801054dc:	c3                   	ret

801054dd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801054dd:	f3 0f 1e fb          	endbr32
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
801054e4:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801054e7:	83 ec 08             	sub    $0x8,%esp
801054ea:	8d 45 cc             	lea    -0x34(%ebp),%eax
801054ed:	50                   	push   %eax
801054ee:	6a 00                	push   $0x0
801054f0:	e8 72 fa ff ff       	call   80104f67 <argstr>
801054f5:	83 c4 10             	add    $0x10,%esp
801054f8:	85 c0                	test   %eax,%eax
801054fa:	79 0a                	jns    80105506 <sys_unlink+0x29>
    return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105501:	e9 bf 01 00 00       	jmp    801056c5 <sys_unlink+0x1e8>

  begin_op();
80105506:	e8 66 dc ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010550b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010550e:	83 ec 08             	sub    $0x8,%esp
80105511:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105514:	52                   	push   %edx
80105515:	50                   	push   %eax
80105516:	e8 ec d0 ff ff       	call   80102607 <nameiparent>
8010551b:	83 c4 10             	add    $0x10,%esp
8010551e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105521:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105525:	75 0f                	jne    80105536 <sys_unlink+0x59>
    end_op();
80105527:	e8 d5 dc ff ff       	call   80103201 <end_op>
    return -1;
8010552c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105531:	e9 8f 01 00 00       	jmp    801056c5 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105536:	83 ec 0c             	sub    $0xc,%esp
80105539:	ff 75 f4             	push   -0xc(%ebp)
8010553c:	e8 3b c5 ff ff       	call   80101a7c <ilock>
80105541:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105544:	83 ec 08             	sub    $0x8,%esp
80105547:	68 06 a8 10 80       	push   $0x8010a806
8010554c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010554f:	50                   	push   %eax
80105550:	e8 12 cd ff ff       	call   80102267 <namecmp>
80105555:	83 c4 10             	add    $0x10,%esp
80105558:	85 c0                	test   %eax,%eax
8010555a:	0f 84 49 01 00 00    	je     801056a9 <sys_unlink+0x1cc>
80105560:	83 ec 08             	sub    $0x8,%esp
80105563:	68 08 a8 10 80       	push   $0x8010a808
80105568:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010556b:	50                   	push   %eax
8010556c:	e8 f6 cc ff ff       	call   80102267 <namecmp>
80105571:	83 c4 10             	add    $0x10,%esp
80105574:	85 c0                	test   %eax,%eax
80105576:	0f 84 2d 01 00 00    	je     801056a9 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010557c:	83 ec 04             	sub    $0x4,%esp
8010557f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105582:	50                   	push   %eax
80105583:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105586:	50                   	push   %eax
80105587:	ff 75 f4             	push   -0xc(%ebp)
8010558a:	e8 f7 cc ff ff       	call   80102286 <dirlookup>
8010558f:	83 c4 10             	add    $0x10,%esp
80105592:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105599:	0f 84 0d 01 00 00    	je     801056ac <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010559f:	83 ec 0c             	sub    $0xc,%esp
801055a2:	ff 75 f0             	push   -0x10(%ebp)
801055a5:	e8 d2 c4 ff ff       	call   80101a7c <ilock>
801055aa:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801055ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055b4:	66 85 c0             	test   %ax,%ax
801055b7:	7f 0d                	jg     801055c6 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801055b9:	83 ec 0c             	sub    $0xc,%esp
801055bc:	68 0b a8 10 80       	push   $0x8010a80b
801055c1:	e8 ff af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801055c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055cd:	66 83 f8 01          	cmp    $0x1,%ax
801055d1:	75 25                	jne    801055f8 <sys_unlink+0x11b>
801055d3:	83 ec 0c             	sub    $0xc,%esp
801055d6:	ff 75 f0             	push   -0x10(%ebp)
801055d9:	e8 98 fe ff ff       	call   80105476 <isdirempty>
801055de:	83 c4 10             	add    $0x10,%esp
801055e1:	85 c0                	test   %eax,%eax
801055e3:	75 13                	jne    801055f8 <sys_unlink+0x11b>
    iunlockput(ip);
801055e5:	83 ec 0c             	sub    $0xc,%esp
801055e8:	ff 75 f0             	push   -0x10(%ebp)
801055eb:	e8 c9 c6 ff ff       	call   80101cb9 <iunlockput>
801055f0:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055f3:	e9 b5 00 00 00       	jmp    801056ad <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801055f8:	83 ec 04             	sub    $0x4,%esp
801055fb:	6a 10                	push   $0x10
801055fd:	6a 00                	push   $0x0
801055ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105602:	50                   	push   %eax
80105603:	e8 6e f5 ff ff       	call   80104b76 <memset>
80105608:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010560b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010560e:	6a 10                	push   $0x10
80105610:	50                   	push   %eax
80105611:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105614:	50                   	push   %eax
80105615:	ff 75 f4             	push   -0xc(%ebp)
80105618:	e8 c0 ca ff ff       	call   801020dd <writei>
8010561d:	83 c4 10             	add    $0x10,%esp
80105620:	83 f8 10             	cmp    $0x10,%eax
80105623:	74 0d                	je     80105632 <sys_unlink+0x155>
    panic("unlink: writei");
80105625:	83 ec 0c             	sub    $0xc,%esp
80105628:	68 1d a8 10 80       	push   $0x8010a81d
8010562d:	e8 93 af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105635:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105639:	66 83 f8 01          	cmp    $0x1,%ax
8010563d:	75 21                	jne    80105660 <sys_unlink+0x183>
    dp->nlink--;
8010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105642:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105646:	83 e8 01             	sub    $0x1,%eax
80105649:	89 c2                	mov    %eax,%edx
8010564b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105652:	83 ec 0c             	sub    $0xc,%esp
80105655:	ff 75 f4             	push   -0xc(%ebp)
80105658:	e8 36 c2 ff ff       	call   80101893 <iupdate>
8010565d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105660:	83 ec 0c             	sub    $0xc,%esp
80105663:	ff 75 f4             	push   -0xc(%ebp)
80105666:	e8 4e c6 ff ff       	call   80101cb9 <iunlockput>
8010566b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010566e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105671:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105675:	83 e8 01             	sub    $0x1,%eax
80105678:	89 c2                	mov    %eax,%edx
8010567a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105681:	83 ec 0c             	sub    $0xc,%esp
80105684:	ff 75 f0             	push   -0x10(%ebp)
80105687:	e8 07 c2 ff ff       	call   80101893 <iupdate>
8010568c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010568f:	83 ec 0c             	sub    $0xc,%esp
80105692:	ff 75 f0             	push   -0x10(%ebp)
80105695:	e8 1f c6 ff ff       	call   80101cb9 <iunlockput>
8010569a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010569d:	e8 5f db ff ff       	call   80103201 <end_op>

  return 0;
801056a2:	b8 00 00 00 00       	mov    $0x0,%eax
801056a7:	eb 1c                	jmp    801056c5 <sys_unlink+0x1e8>
    goto bad;
801056a9:	90                   	nop
801056aa:	eb 01                	jmp    801056ad <sys_unlink+0x1d0>
    goto bad;
801056ac:	90                   	nop

bad:
  iunlockput(dp);
801056ad:	83 ec 0c             	sub    $0xc,%esp
801056b0:	ff 75 f4             	push   -0xc(%ebp)
801056b3:	e8 01 c6 ff ff       	call   80101cb9 <iunlockput>
801056b8:	83 c4 10             	add    $0x10,%esp
  end_op();
801056bb:	e8 41 db ff ff       	call   80103201 <end_op>
  return -1;
801056c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056c5:	c9                   	leave
801056c6:	c3                   	ret

801056c7 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801056c7:	f3 0f 1e fb          	endbr32
801056cb:	55                   	push   %ebp
801056cc:	89 e5                	mov    %esp,%ebp
801056ce:	83 ec 38             	sub    $0x38,%esp
801056d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801056d4:	8b 55 10             	mov    0x10(%ebp),%edx
801056d7:	8b 45 14             	mov    0x14(%ebp),%eax
801056da:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801056de:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801056e2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801056e6:	83 ec 08             	sub    $0x8,%esp
801056e9:	8d 45 de             	lea    -0x22(%ebp),%eax
801056ec:	50                   	push   %eax
801056ed:	ff 75 08             	push   0x8(%ebp)
801056f0:	e8 12 cf ff ff       	call   80102607 <nameiparent>
801056f5:	83 c4 10             	add    $0x10,%esp
801056f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ff:	75 0a                	jne    8010570b <create+0x44>
    return 0;
80105701:	b8 00 00 00 00       	mov    $0x0,%eax
80105706:	e9 90 01 00 00       	jmp    8010589b <create+0x1d4>
  ilock(dp);
8010570b:	83 ec 0c             	sub    $0xc,%esp
8010570e:	ff 75 f4             	push   -0xc(%ebp)
80105711:	e8 66 c3 ff ff       	call   80101a7c <ilock>
80105716:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105719:	83 ec 04             	sub    $0x4,%esp
8010571c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010571f:	50                   	push   %eax
80105720:	8d 45 de             	lea    -0x22(%ebp),%eax
80105723:	50                   	push   %eax
80105724:	ff 75 f4             	push   -0xc(%ebp)
80105727:	e8 5a cb ff ff       	call   80102286 <dirlookup>
8010572c:	83 c4 10             	add    $0x10,%esp
8010572f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105732:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105736:	74 50                	je     80105788 <create+0xc1>
    iunlockput(dp);
80105738:	83 ec 0c             	sub    $0xc,%esp
8010573b:	ff 75 f4             	push   -0xc(%ebp)
8010573e:	e8 76 c5 ff ff       	call   80101cb9 <iunlockput>
80105743:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105746:	83 ec 0c             	sub    $0xc,%esp
80105749:	ff 75 f0             	push   -0x10(%ebp)
8010574c:	e8 2b c3 ff ff       	call   80101a7c <ilock>
80105751:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105754:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105759:	75 15                	jne    80105770 <create+0xa9>
8010575b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105762:	66 83 f8 02          	cmp    $0x2,%ax
80105766:	75 08                	jne    80105770 <create+0xa9>
      return ip;
80105768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576b:	e9 2b 01 00 00       	jmp    8010589b <create+0x1d4>
    iunlockput(ip);
80105770:	83 ec 0c             	sub    $0xc,%esp
80105773:	ff 75 f0             	push   -0x10(%ebp)
80105776:	e8 3e c5 ff ff       	call   80101cb9 <iunlockput>
8010577b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010577e:	b8 00 00 00 00       	mov    $0x0,%eax
80105783:	e9 13 01 00 00       	jmp    8010589b <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105788:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010578c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578f:	8b 00                	mov    (%eax),%eax
80105791:	83 ec 08             	sub    $0x8,%esp
80105794:	52                   	push   %edx
80105795:	50                   	push   %eax
80105796:	e8 1d c0 ff ff       	call   801017b8 <ialloc>
8010579b:	83 c4 10             	add    $0x10,%esp
8010579e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057a5:	75 0d                	jne    801057b4 <create+0xed>
    panic("create: ialloc");
801057a7:	83 ec 0c             	sub    $0xc,%esp
801057aa:	68 2c a8 10 80       	push   $0x8010a82c
801057af:	e8 11 ae ff ff       	call   801005c5 <panic>

  ilock(ip);
801057b4:	83 ec 0c             	sub    $0xc,%esp
801057b7:	ff 75 f0             	push   -0x10(%ebp)
801057ba:	e8 bd c2 ff ff       	call   80101a7c <ilock>
801057bf:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801057c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c5:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801057c9:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801057cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d0:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801057d4:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801057d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057db:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801057e1:	83 ec 0c             	sub    $0xc,%esp
801057e4:	ff 75 f0             	push   -0x10(%ebp)
801057e7:	e8 a7 c0 ff ff       	call   80101893 <iupdate>
801057ec:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801057ef:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801057f4:	75 6a                	jne    80105860 <create+0x199>
    dp->nlink++;  // for ".."
801057f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057fd:	83 c0 01             	add    $0x1,%eax
80105800:	89 c2                	mov    %eax,%edx
80105802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105805:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105809:	83 ec 0c             	sub    $0xc,%esp
8010580c:	ff 75 f4             	push   -0xc(%ebp)
8010580f:	e8 7f c0 ff ff       	call   80101893 <iupdate>
80105814:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581a:	8b 40 04             	mov    0x4(%eax),%eax
8010581d:	83 ec 04             	sub    $0x4,%esp
80105820:	50                   	push   %eax
80105821:	68 06 a8 10 80       	push   $0x8010a806
80105826:	ff 75 f0             	push   -0x10(%ebp)
80105829:	e8 16 cb ff ff       	call   80102344 <dirlink>
8010582e:	83 c4 10             	add    $0x10,%esp
80105831:	85 c0                	test   %eax,%eax
80105833:	78 1e                	js     80105853 <create+0x18c>
80105835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105838:	8b 40 04             	mov    0x4(%eax),%eax
8010583b:	83 ec 04             	sub    $0x4,%esp
8010583e:	50                   	push   %eax
8010583f:	68 08 a8 10 80       	push   $0x8010a808
80105844:	ff 75 f0             	push   -0x10(%ebp)
80105847:	e8 f8 ca ff ff       	call   80102344 <dirlink>
8010584c:	83 c4 10             	add    $0x10,%esp
8010584f:	85 c0                	test   %eax,%eax
80105851:	79 0d                	jns    80105860 <create+0x199>
      panic("create dots");
80105853:	83 ec 0c             	sub    $0xc,%esp
80105856:	68 3b a8 10 80       	push   $0x8010a83b
8010585b:	e8 65 ad ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	8b 40 04             	mov    0x4(%eax),%eax
80105866:	83 ec 04             	sub    $0x4,%esp
80105869:	50                   	push   %eax
8010586a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010586d:	50                   	push   %eax
8010586e:	ff 75 f4             	push   -0xc(%ebp)
80105871:	e8 ce ca ff ff       	call   80102344 <dirlink>
80105876:	83 c4 10             	add    $0x10,%esp
80105879:	85 c0                	test   %eax,%eax
8010587b:	79 0d                	jns    8010588a <create+0x1c3>
    panic("create: dirlink");
8010587d:	83 ec 0c             	sub    $0xc,%esp
80105880:	68 47 a8 10 80       	push   $0x8010a847
80105885:	e8 3b ad ff ff       	call   801005c5 <panic>

  iunlockput(dp);
8010588a:	83 ec 0c             	sub    $0xc,%esp
8010588d:	ff 75 f4             	push   -0xc(%ebp)
80105890:	e8 24 c4 ff ff       	call   80101cb9 <iunlockput>
80105895:	83 c4 10             	add    $0x10,%esp

  return ip;
80105898:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010589b:	c9                   	leave
8010589c:	c3                   	ret

8010589d <sys_open>:

int
sys_open(void)
{
8010589d:	f3 0f 1e fb          	endbr32
801058a1:	55                   	push   %ebp
801058a2:	89 e5                	mov    %esp,%ebp
801058a4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801058a7:	83 ec 08             	sub    $0x8,%esp
801058aa:	8d 45 e8             	lea    -0x18(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	6a 00                	push   $0x0
801058b0:	e8 b2 f6 ff ff       	call   80104f67 <argstr>
801058b5:	83 c4 10             	add    $0x10,%esp
801058b8:	85 c0                	test   %eax,%eax
801058ba:	78 15                	js     801058d1 <sys_open+0x34>
801058bc:	83 ec 08             	sub    $0x8,%esp
801058bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058c2:	50                   	push   %eax
801058c3:	6a 01                	push   $0x1
801058c5:	e8 00 f6 ff ff       	call   80104eca <argint>
801058ca:	83 c4 10             	add    $0x10,%esp
801058cd:	85 c0                	test   %eax,%eax
801058cf:	79 0a                	jns    801058db <sys_open+0x3e>
    return -1;
801058d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d6:	e9 61 01 00 00       	jmp    80105a3c <sys_open+0x19f>

  begin_op();
801058db:	e8 91 d8 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
801058e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058e3:	25 00 02 00 00       	and    $0x200,%eax
801058e8:	85 c0                	test   %eax,%eax
801058ea:	74 2a                	je     80105916 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801058ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058ef:	6a 00                	push   $0x0
801058f1:	6a 00                	push   $0x0
801058f3:	6a 02                	push   $0x2
801058f5:	50                   	push   %eax
801058f6:	e8 cc fd ff ff       	call   801056c7 <create>
801058fb:	83 c4 10             	add    $0x10,%esp
801058fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105901:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105905:	75 75                	jne    8010597c <sys_open+0xdf>
      end_op();
80105907:	e8 f5 d8 ff ff       	call   80103201 <end_op>
      return -1;
8010590c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105911:	e9 26 01 00 00       	jmp    80105a3c <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105916:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105919:	83 ec 0c             	sub    $0xc,%esp
8010591c:	50                   	push   %eax
8010591d:	e8 c5 cc ff ff       	call   801025e7 <namei>
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105928:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010592c:	75 0f                	jne    8010593d <sys_open+0xa0>
      end_op();
8010592e:	e8 ce d8 ff ff       	call   80103201 <end_op>
      return -1;
80105933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105938:	e9 ff 00 00 00       	jmp    80105a3c <sys_open+0x19f>
    }
    ilock(ip);
8010593d:	83 ec 0c             	sub    $0xc,%esp
80105940:	ff 75 f4             	push   -0xc(%ebp)
80105943:	e8 34 c1 ff ff       	call   80101a7c <ilock>
80105948:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010594b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105952:	66 83 f8 01          	cmp    $0x1,%ax
80105956:	75 24                	jne    8010597c <sys_open+0xdf>
80105958:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010595b:	85 c0                	test   %eax,%eax
8010595d:	74 1d                	je     8010597c <sys_open+0xdf>
      iunlockput(ip);
8010595f:	83 ec 0c             	sub    $0xc,%esp
80105962:	ff 75 f4             	push   -0xc(%ebp)
80105965:	e8 4f c3 ff ff       	call   80101cb9 <iunlockput>
8010596a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010596d:	e8 8f d8 ff ff       	call   80103201 <end_op>
      return -1;
80105972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105977:	e9 c0 00 00 00       	jmp    80105a3c <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010597c:	e8 a2 b6 ff ff       	call   80101023 <filealloc>
80105981:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105984:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105988:	74 17                	je     801059a1 <sys_open+0x104>
8010598a:	83 ec 0c             	sub    $0xc,%esp
8010598d:	ff 75 f0             	push   -0x10(%ebp)
80105990:	e8 07 f7 ff ff       	call   8010509c <fdalloc>
80105995:	83 c4 10             	add    $0x10,%esp
80105998:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010599b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010599f:	79 2e                	jns    801059cf <sys_open+0x132>
    if(f)
801059a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a5:	74 0e                	je     801059b5 <sys_open+0x118>
      fileclose(f);
801059a7:	83 ec 0c             	sub    $0xc,%esp
801059aa:	ff 75 f0             	push   -0x10(%ebp)
801059ad:	e8 37 b7 ff ff       	call   801010e9 <fileclose>
801059b2:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801059b5:	83 ec 0c             	sub    $0xc,%esp
801059b8:	ff 75 f4             	push   -0xc(%ebp)
801059bb:	e8 f9 c2 ff ff       	call   80101cb9 <iunlockput>
801059c0:	83 c4 10             	add    $0x10,%esp
    end_op();
801059c3:	e8 39 d8 ff ff       	call   80103201 <end_op>
    return -1;
801059c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cd:	eb 6d                	jmp    80105a3c <sys_open+0x19f>
  }
  iunlock(ip);
801059cf:	83 ec 0c             	sub    $0xc,%esp
801059d2:	ff 75 f4             	push   -0xc(%ebp)
801059d5:	e8 b9 c1 ff ff       	call   80101b93 <iunlock>
801059da:	83 c4 10             	add    $0x10,%esp
  end_op();
801059dd:	e8 1f d8 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
801059e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059f1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801059f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801059fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a01:	83 e0 01             	and    $0x1,%eax
80105a04:	85 c0                	test   %eax,%eax
80105a06:	0f 94 c0             	sete   %al
80105a09:	89 c2                	mov    %eax,%edx
80105a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a14:	83 e0 01             	and    $0x1,%eax
80105a17:	85 c0                	test   %eax,%eax
80105a19:	75 0a                	jne    80105a25 <sys_open+0x188>
80105a1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a1e:	83 e0 02             	and    $0x2,%eax
80105a21:	85 c0                	test   %eax,%eax
80105a23:	74 07                	je     80105a2c <sys_open+0x18f>
80105a25:	b8 01 00 00 00       	mov    $0x1,%eax
80105a2a:	eb 05                	jmp    80105a31 <sys_open+0x194>
80105a2c:	b8 00 00 00 00       	mov    $0x0,%eax
80105a31:	89 c2                	mov    %eax,%edx
80105a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a36:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a39:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a3c:	c9                   	leave
80105a3d:	c3                   	ret

80105a3e <sys_mkdir>:

int
sys_mkdir(void)
{
80105a3e:	f3 0f 1e fb          	endbr32
80105a42:	55                   	push   %ebp
80105a43:	89 e5                	mov    %esp,%ebp
80105a45:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a48:	e8 24 d7 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a4d:	83 ec 08             	sub    $0x8,%esp
80105a50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a53:	50                   	push   %eax
80105a54:	6a 00                	push   $0x0
80105a56:	e8 0c f5 ff ff       	call   80104f67 <argstr>
80105a5b:	83 c4 10             	add    $0x10,%esp
80105a5e:	85 c0                	test   %eax,%eax
80105a60:	78 1b                	js     80105a7d <sys_mkdir+0x3f>
80105a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a65:	6a 00                	push   $0x0
80105a67:	6a 00                	push   $0x0
80105a69:	6a 01                	push   $0x1
80105a6b:	50                   	push   %eax
80105a6c:	e8 56 fc ff ff       	call   801056c7 <create>
80105a71:	83 c4 10             	add    $0x10,%esp
80105a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a7b:	75 0c                	jne    80105a89 <sys_mkdir+0x4b>
    end_op();
80105a7d:	e8 7f d7 ff ff       	call   80103201 <end_op>
    return -1;
80105a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a87:	eb 18                	jmp    80105aa1 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105a89:	83 ec 0c             	sub    $0xc,%esp
80105a8c:	ff 75 f4             	push   -0xc(%ebp)
80105a8f:	e8 25 c2 ff ff       	call   80101cb9 <iunlockput>
80105a94:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a97:	e8 65 d7 ff ff       	call   80103201 <end_op>
  return 0;
80105a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa1:	c9                   	leave
80105aa2:	c3                   	ret

80105aa3 <sys_mknod>:

int
sys_mknod(void)
{
80105aa3:	f3 0f 1e fb          	endbr32
80105aa7:	55                   	push   %ebp
80105aa8:	89 e5                	mov    %esp,%ebp
80105aaa:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105aad:	e8 bf d6 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ab2:	83 ec 08             	sub    $0x8,%esp
80105ab5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab8:	50                   	push   %eax
80105ab9:	6a 00                	push   $0x0
80105abb:	e8 a7 f4 ff ff       	call   80104f67 <argstr>
80105ac0:	83 c4 10             	add    $0x10,%esp
80105ac3:	85 c0                	test   %eax,%eax
80105ac5:	78 4f                	js     80105b16 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105ac7:	83 ec 08             	sub    $0x8,%esp
80105aca:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105acd:	50                   	push   %eax
80105ace:	6a 01                	push   $0x1
80105ad0:	e8 f5 f3 ff ff       	call   80104eca <argint>
80105ad5:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105ad8:	85 c0                	test   %eax,%eax
80105ada:	78 3a                	js     80105b16 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105adc:	83 ec 08             	sub    $0x8,%esp
80105adf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ae2:	50                   	push   %eax
80105ae3:	6a 02                	push   $0x2
80105ae5:	e8 e0 f3 ff ff       	call   80104eca <argint>
80105aea:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105aed:	85 c0                	test   %eax,%eax
80105aef:	78 25                	js     80105b16 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105af4:	0f bf c8             	movswl %ax,%ecx
80105af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105afa:	0f bf d0             	movswl %ax,%edx
80105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b00:	51                   	push   %ecx
80105b01:	52                   	push   %edx
80105b02:	6a 03                	push   $0x3
80105b04:	50                   	push   %eax
80105b05:	e8 bd fb ff ff       	call   801056c7 <create>
80105b0a:	83 c4 10             	add    $0x10,%esp
80105b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105b10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b14:	75 0c                	jne    80105b22 <sys_mknod+0x7f>
    end_op();
80105b16:	e8 e6 d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b20:	eb 18                	jmp    80105b3a <sys_mknod+0x97>
  }
  iunlockput(ip);
80105b22:	83 ec 0c             	sub    $0xc,%esp
80105b25:	ff 75 f4             	push   -0xc(%ebp)
80105b28:	e8 8c c1 ff ff       	call   80101cb9 <iunlockput>
80105b2d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b30:	e8 cc d6 ff ff       	call   80103201 <end_op>
  return 0;
80105b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3a:	c9                   	leave
80105b3b:	c3                   	ret

80105b3c <sys_chdir>:

int
sys_chdir(void)
{
80105b3c:	f3 0f 1e fb          	endbr32
80105b40:	55                   	push   %ebp
80105b41:	89 e5                	mov    %esp,%ebp
80105b43:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b46:	e8 5e e0 ff ff       	call   80103ba9 <myproc>
80105b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b4e:	e8 1e d6 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b53:	83 ec 08             	sub    $0x8,%esp
80105b56:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b59:	50                   	push   %eax
80105b5a:	6a 00                	push   $0x0
80105b5c:	e8 06 f4 ff ff       	call   80104f67 <argstr>
80105b61:	83 c4 10             	add    $0x10,%esp
80105b64:	85 c0                	test   %eax,%eax
80105b66:	78 18                	js     80105b80 <sys_chdir+0x44>
80105b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b6b:	83 ec 0c             	sub    $0xc,%esp
80105b6e:	50                   	push   %eax
80105b6f:	e8 73 ca ff ff       	call   801025e7 <namei>
80105b74:	83 c4 10             	add    $0x10,%esp
80105b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b7e:	75 0c                	jne    80105b8c <sys_chdir+0x50>
    end_op();
80105b80:	e8 7c d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8a:	eb 68                	jmp    80105bf4 <sys_chdir+0xb8>
  }
  ilock(ip);
80105b8c:	83 ec 0c             	sub    $0xc,%esp
80105b8f:	ff 75 f0             	push   -0x10(%ebp)
80105b92:	e8 e5 be ff ff       	call   80101a7c <ilock>
80105b97:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ba1:	66 83 f8 01          	cmp    $0x1,%ax
80105ba5:	74 1a                	je     80105bc1 <sys_chdir+0x85>
    iunlockput(ip);
80105ba7:	83 ec 0c             	sub    $0xc,%esp
80105baa:	ff 75 f0             	push   -0x10(%ebp)
80105bad:	e8 07 c1 ff ff       	call   80101cb9 <iunlockput>
80105bb2:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bb5:	e8 47 d6 ff ff       	call   80103201 <end_op>
    return -1;
80105bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbf:	eb 33                	jmp    80105bf4 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105bc1:	83 ec 0c             	sub    $0xc,%esp
80105bc4:	ff 75 f0             	push   -0x10(%ebp)
80105bc7:	e8 c7 bf ff ff       	call   80101b93 <iunlock>
80105bcc:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd2:	8b 40 68             	mov    0x68(%eax),%eax
80105bd5:	83 ec 0c             	sub    $0xc,%esp
80105bd8:	50                   	push   %eax
80105bd9:	e8 07 c0 ff ff       	call   80101be5 <iput>
80105bde:	83 c4 10             	add    $0x10,%esp
  end_op();
80105be1:	e8 1b d6 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bec:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bf4:	c9                   	leave
80105bf5:	c3                   	ret

80105bf6 <sys_exec>:

int
sys_exec(void)
{
80105bf6:	f3 0f 1e fb          	endbr32
80105bfa:	55                   	push   %ebp
80105bfb:	89 e5                	mov    %esp,%ebp
80105bfd:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105c03:	83 ec 08             	sub    $0x8,%esp
80105c06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c09:	50                   	push   %eax
80105c0a:	6a 00                	push   $0x0
80105c0c:	e8 56 f3 ff ff       	call   80104f67 <argstr>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	85 c0                	test   %eax,%eax
80105c16:	78 18                	js     80105c30 <sys_exec+0x3a>
80105c18:	83 ec 08             	sub    $0x8,%esp
80105c1b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105c21:	50                   	push   %eax
80105c22:	6a 01                	push   $0x1
80105c24:	e8 a1 f2 ff ff       	call   80104eca <argint>
80105c29:	83 c4 10             	add    $0x10,%esp
80105c2c:	85 c0                	test   %eax,%eax
80105c2e:	79 0a                	jns    80105c3a <sys_exec+0x44>
    return -1;
80105c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c35:	e9 c6 00 00 00       	jmp    80105d00 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105c3a:	83 ec 04             	sub    $0x4,%esp
80105c3d:	68 80 00 00 00       	push   $0x80
80105c42:	6a 00                	push   $0x0
80105c44:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c4a:	50                   	push   %eax
80105c4b:	e8 26 ef ff ff       	call   80104b76 <memset>
80105c50:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5d:	83 f8 1f             	cmp    $0x1f,%eax
80105c60:	76 0a                	jbe    80105c6c <sys_exec+0x76>
      return -1;
80105c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c67:	e9 94 00 00 00       	jmp    80105d00 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	c1 e0 02             	shl    $0x2,%eax
80105c72:	89 c2                	mov    %eax,%edx
80105c74:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c7a:	01 c2                	add    %eax,%edx
80105c7c:	83 ec 08             	sub    $0x8,%esp
80105c7f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c85:	50                   	push   %eax
80105c86:	52                   	push   %edx
80105c87:	e8 93 f1 ff ff       	call   80104e1f <fetchint>
80105c8c:	83 c4 10             	add    $0x10,%esp
80105c8f:	85 c0                	test   %eax,%eax
80105c91:	79 07                	jns    80105c9a <sys_exec+0xa4>
      return -1;
80105c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c98:	eb 66                	jmp    80105d00 <sys_exec+0x10a>
    if(uarg == 0){
80105c9a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ca0:	85 c0                	test   %eax,%eax
80105ca2:	75 27                	jne    80105ccb <sys_exec+0xd5>
      argv[i] = 0;
80105ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105cae:	00 00 00 00 
      break;
80105cb2:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb6:	83 ec 08             	sub    $0x8,%esp
80105cb9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105cbf:	52                   	push   %edx
80105cc0:	50                   	push   %eax
80105cc1:	e8 f8 ae ff ff       	call   80100bbe <exec>
80105cc6:	83 c4 10             	add    $0x10,%esp
80105cc9:	eb 35                	jmp    80105d00 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105ccb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cd4:	c1 e2 02             	shl    $0x2,%edx
80105cd7:	01 c2                	add    %eax,%edx
80105cd9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105cdf:	83 ec 08             	sub    $0x8,%esp
80105ce2:	52                   	push   %edx
80105ce3:	50                   	push   %eax
80105ce4:	e8 79 f1 ff ff       	call   80104e62 <fetchstr>
80105ce9:	83 c4 10             	add    $0x10,%esp
80105cec:	85 c0                	test   %eax,%eax
80105cee:	79 07                	jns    80105cf7 <sys_exec+0x101>
      return -1;
80105cf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf5:	eb 09                	jmp    80105d00 <sys_exec+0x10a>
  for(i=0;; i++){
80105cf7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105cfb:	e9 5a ff ff ff       	jmp    80105c5a <sys_exec+0x64>
}
80105d00:	c9                   	leave
80105d01:	c3                   	ret

80105d02 <sys_pipe>:

int
sys_pipe(void)
{
80105d02:	f3 0f 1e fb          	endbr32
80105d06:	55                   	push   %ebp
80105d07:	89 e5                	mov    %esp,%ebp
80105d09:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d0c:	83 ec 04             	sub    $0x4,%esp
80105d0f:	6a 08                	push   $0x8
80105d11:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d14:	50                   	push   %eax
80105d15:	6a 00                	push   $0x0
80105d17:	e8 df f1 ff ff       	call   80104efb <argptr>
80105d1c:	83 c4 10             	add    $0x10,%esp
80105d1f:	85 c0                	test   %eax,%eax
80105d21:	79 0a                	jns    80105d2d <sys_pipe+0x2b>
    return -1;
80105d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d28:	e9 ae 00 00 00       	jmp    80105ddb <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105d2d:	83 ec 08             	sub    $0x8,%esp
80105d30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d33:	50                   	push   %eax
80105d34:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d37:	50                   	push   %eax
80105d38:	e8 8d d9 ff ff       	call   801036ca <pipealloc>
80105d3d:	83 c4 10             	add    $0x10,%esp
80105d40:	85 c0                	test   %eax,%eax
80105d42:	79 0a                	jns    80105d4e <sys_pipe+0x4c>
    return -1;
80105d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d49:	e9 8d 00 00 00       	jmp    80105ddb <sys_pipe+0xd9>
  fd0 = -1;
80105d4e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d58:	83 ec 0c             	sub    $0xc,%esp
80105d5b:	50                   	push   %eax
80105d5c:	e8 3b f3 ff ff       	call   8010509c <fdalloc>
80105d61:	83 c4 10             	add    $0x10,%esp
80105d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d6b:	78 18                	js     80105d85 <sys_pipe+0x83>
80105d6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d70:	83 ec 0c             	sub    $0xc,%esp
80105d73:	50                   	push   %eax
80105d74:	e8 23 f3 ff ff       	call   8010509c <fdalloc>
80105d79:	83 c4 10             	add    $0x10,%esp
80105d7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d83:	79 3e                	jns    80105dc3 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105d85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d89:	78 13                	js     80105d9e <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105d8b:	e8 19 de ff ff       	call   80103ba9 <myproc>
80105d90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d93:	83 c2 08             	add    $0x8,%edx
80105d96:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d9d:	00 
    fileclose(rf);
80105d9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105da1:	83 ec 0c             	sub    $0xc,%esp
80105da4:	50                   	push   %eax
80105da5:	e8 3f b3 ff ff       	call   801010e9 <fileclose>
80105daa:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db0:	83 ec 0c             	sub    $0xc,%esp
80105db3:	50                   	push   %eax
80105db4:	e8 30 b3 ff ff       	call   801010e9 <fileclose>
80105db9:	83 c4 10             	add    $0x10,%esp
    return -1;
80105dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc1:	eb 18                	jmp    80105ddb <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dc9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dce:	8d 50 04             	lea    0x4(%eax),%edx
80105dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd4:	89 02                	mov    %eax,(%edx)
  return 0;
80105dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ddb:	c9                   	leave
80105ddc:	c3                   	ret

80105ddd <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105ddd:	f3 0f 1e fb          	endbr32
80105de1:	55                   	push   %ebp
80105de2:	89 e5                	mov    %esp,%ebp
80105de4:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105de7:	e8 d0 e0 ff ff       	call   80103ebc <fork>
}
80105dec:	c9                   	leave
80105ded:	c3                   	ret

80105dee <sys_exit>:

int
sys_exit(void)
{
80105dee:	f3 0f 1e fb          	endbr32
80105df2:	55                   	push   %ebp
80105df3:	89 e5                	mov    %esp,%ebp
80105df5:	83 ec 08             	sub    $0x8,%esp
  exit();
80105df8:	e8 3c e2 ff ff       	call   80104039 <exit>
  return 0;  // not reached
80105dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e02:	c9                   	leave
80105e03:	c3                   	ret

80105e04 <sys_wait>:

int
sys_wait(void)
{
80105e04:	f3 0f 1e fb          	endbr32
80105e08:	55                   	push   %ebp
80105e09:	89 e5                	mov    %esp,%ebp
80105e0b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105e0e:	e8 4a e3 ff ff       	call   8010415d <wait>
}
80105e13:	c9                   	leave
80105e14:	c3                   	ret

80105e15 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105e15:	f3 0f 1e fb          	endbr32
80105e19:	55                   	push   %ebp
80105e1a:	89 e5                	mov    %esp,%ebp
80105e1c:	83 ec 18             	sub    $0x18,%esp
    int address;
    if (argint(0, &address) < 0)
80105e1f:	83 ec 08             	sub    $0x8,%esp
80105e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e25:	50                   	push   %eax
80105e26:	6a 00                	push   $0x0
80105e28:	e8 9d f0 ff ff       	call   80104eca <argint>
80105e2d:	83 c4 10             	add    $0x10,%esp
80105e30:	85 c0                	test   %eax,%eax
80105e32:	79 07                	jns    80105e3b <sys_uthread_init+0x26>
        return -1;
80105e34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e39:	eb 0f                	jmp    80105e4a <sys_uthread_init+0x35>
    return uthread_init(address);
80105e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3e:	83 ec 0c             	sub    $0xc,%esp
80105e41:	50                   	push   %eax
80105e42:	e8 f6 e4 ff ff       	call   8010433d <uthread_init>
80105e47:	83 c4 10             	add    $0x10,%esp
}
80105e4a:	c9                   	leave
80105e4b:	c3                   	ret

80105e4c <sys_kill>:

int
sys_kill(void)
{
80105e4c:	f3 0f 1e fb          	endbr32
80105e50:	55                   	push   %ebp
80105e51:	89 e5                	mov    %esp,%ebp
80105e53:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105e56:	83 ec 08             	sub    $0x8,%esp
80105e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e5c:	50                   	push   %eax
80105e5d:	6a 00                	push   $0x0
80105e5f:	e8 66 f0 ff ff       	call   80104eca <argint>
80105e64:	83 c4 10             	add    $0x10,%esp
80105e67:	85 c0                	test   %eax,%eax
80105e69:	79 07                	jns    80105e72 <sys_kill+0x26>
    return -1;
80105e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e70:	eb 0f                	jmp    80105e81 <sys_kill+0x35>
  return kill(pid);
80105e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e75:	83 ec 0c             	sub    $0xc,%esp
80105e78:	50                   	push   %eax
80105e79:	e8 50 e7 ff ff       	call   801045ce <kill>
80105e7e:	83 c4 10             	add    $0x10,%esp
}
80105e81:	c9                   	leave
80105e82:	c3                   	ret

80105e83 <sys_getpid>:

int
sys_getpid(void)
{
80105e83:	f3 0f 1e fb          	endbr32
80105e87:	55                   	push   %ebp
80105e88:	89 e5                	mov    %esp,%ebp
80105e8a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105e8d:	e8 17 dd ff ff       	call   80103ba9 <myproc>
80105e92:	8b 40 10             	mov    0x10(%eax),%eax
}
80105e95:	c9                   	leave
80105e96:	c3                   	ret

80105e97 <sys_sbrk>:

int
sys_sbrk(void)
{
80105e97:	f3 0f 1e fb          	endbr32
80105e9b:	55                   	push   %ebp
80105e9c:	89 e5                	mov    %esp,%ebp
80105e9e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ea1:	83 ec 08             	sub    $0x8,%esp
80105ea4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ea7:	50                   	push   %eax
80105ea8:	6a 00                	push   $0x0
80105eaa:	e8 1b f0 ff ff       	call   80104eca <argint>
80105eaf:	83 c4 10             	add    $0x10,%esp
80105eb2:	85 c0                	test   %eax,%eax
80105eb4:	79 07                	jns    80105ebd <sys_sbrk+0x26>
    return -1;
80105eb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebb:	eb 27                	jmp    80105ee4 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80105ebd:	e8 e7 dc ff ff       	call   80103ba9 <myproc>
80105ec2:	8b 00                	mov    (%eax),%eax
80105ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eca:	83 ec 0c             	sub    $0xc,%esp
80105ecd:	50                   	push   %eax
80105ece:	e8 4a df ff ff       	call   80103e1d <growproc>
80105ed3:	83 c4 10             	add    $0x10,%esp
80105ed6:	85 c0                	test   %eax,%eax
80105ed8:	79 07                	jns    80105ee1 <sys_sbrk+0x4a>
    return -1;
80105eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edf:	eb 03                	jmp    80105ee4 <sys_sbrk+0x4d>
  return addr;
80105ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ee4:	c9                   	leave
80105ee5:	c3                   	ret

80105ee6 <sys_sleep>:

int
sys_sleep(void)
{
80105ee6:	f3 0f 1e fb          	endbr32
80105eea:	55                   	push   %ebp
80105eeb:	89 e5                	mov    %esp,%ebp
80105eed:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105ef0:	83 ec 08             	sub    $0x8,%esp
80105ef3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ef6:	50                   	push   %eax
80105ef7:	6a 00                	push   $0x0
80105ef9:	e8 cc ef ff ff       	call   80104eca <argint>
80105efe:	83 c4 10             	add    $0x10,%esp
80105f01:	85 c0                	test   %eax,%eax
80105f03:	79 07                	jns    80105f0c <sys_sleep+0x26>
    return -1;
80105f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0a:	eb 76                	jmp    80105f82 <sys_sleep+0x9c>
  acquire(&tickslock);
80105f0c:	83 ec 0c             	sub    $0xc,%esp
80105f0f:	68 40 75 19 80       	push   $0x80197540
80105f14:	e8 ce e9 ff ff       	call   801048e7 <acquire>
80105f19:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105f1c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105f24:	eb 38                	jmp    80105f5e <sys_sleep+0x78>
    if(myproc()->killed){
80105f26:	e8 7e dc ff ff       	call   80103ba9 <myproc>
80105f2b:	8b 40 24             	mov    0x24(%eax),%eax
80105f2e:	85 c0                	test   %eax,%eax
80105f30:	74 17                	je     80105f49 <sys_sleep+0x63>
      release(&tickslock);
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	68 40 75 19 80       	push   $0x80197540
80105f3a:	e8 1a ea ff ff       	call   80104959 <release>
80105f3f:	83 c4 10             	add    $0x10,%esp
      return -1;
80105f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f47:	eb 39                	jmp    80105f82 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80105f49:	83 ec 08             	sub    $0x8,%esp
80105f4c:	68 40 75 19 80       	push   $0x80197540
80105f51:	68 80 7d 19 80       	push   $0x80197d80
80105f56:	e8 49 e5 ff ff       	call   801044a4 <sleep>
80105f5b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105f5e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105f63:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105f66:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f69:	39 d0                	cmp    %edx,%eax
80105f6b:	72 b9                	jb     80105f26 <sys_sleep+0x40>
  }
  release(&tickslock);
80105f6d:	83 ec 0c             	sub    $0xc,%esp
80105f70:	68 40 75 19 80       	push   $0x80197540
80105f75:	e8 df e9 ff ff       	call   80104959 <release>
80105f7a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f82:	c9                   	leave
80105f83:	c3                   	ret

80105f84 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105f84:	f3 0f 1e fb          	endbr32
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105f8e:	83 ec 0c             	sub    $0xc,%esp
80105f91:	68 40 75 19 80       	push   $0x80197540
80105f96:	e8 4c e9 ff ff       	call   801048e7 <acquire>
80105f9b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105f9e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80105fa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105fa6:	83 ec 0c             	sub    $0xc,%esp
80105fa9:	68 40 75 19 80       	push   $0x80197540
80105fae:	e8 a6 e9 ff ff       	call   80104959 <release>
80105fb3:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fb9:	c9                   	leave
80105fba:	c3                   	ret

80105fbb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105fbb:	1e                   	push   %ds
  pushl %es
80105fbc:	06                   	push   %es
  pushl %fs
80105fbd:	0f a0                	push   %fs
  pushl %gs
80105fbf:	0f a8                	push   %gs
  pushal
80105fc1:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105fc2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105fc6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105fc8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105fca:	54                   	push   %esp
  call trap
80105fcb:	e8 df 01 00 00       	call   801061af <trap>
  addl $4, %esp
80105fd0:	83 c4 04             	add    $0x4,%esp

80105fd3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105fd3:	61                   	popa
  popl %gs
80105fd4:	0f a9                	pop    %gs
  popl %fs
80105fd6:	0f a1                	pop    %fs
  popl %es
80105fd8:	07                   	pop    %es
  popl %ds
80105fd9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105fda:	83 c4 08             	add    $0x8,%esp
  iret
80105fdd:	cf                   	iret

80105fde <lidt>:
{
80105fde:	55                   	push   %ebp
80105fdf:	89 e5                	mov    %esp,%ebp
80105fe1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fe7:	83 e8 01             	sub    $0x1,%eax
80105fea:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105fee:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff8:	c1 e8 10             	shr    $0x10,%eax
80105ffb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105fff:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106002:	0f 01 18             	lidtl  (%eax)
}
80106005:	90                   	nop
80106006:	c9                   	leave
80106007:	c3                   	ret

80106008 <rcr2>:

static inline uint
rcr2(void)
{
80106008:	55                   	push   %ebp
80106009:	89 e5                	mov    %esp,%ebp
8010600b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010600e:	0f 20 d0             	mov    %cr2,%eax
80106011:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106014:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106017:	c9                   	leave
80106018:	c3                   	ret

80106019 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106019:	f3 0f 1e fb          	endbr32
8010601d:	55                   	push   %ebp
8010601e:	89 e5                	mov    %esp,%ebp
80106020:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106023:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010602a:	e9 c3 00 00 00       	jmp    801060f2 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010602f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106032:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106039:	89 c2                	mov    %eax,%edx
8010603b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603e:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106045:	80 
80106046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106049:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
80106050:	80 08 00 
80106053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106056:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010605d:	80 
8010605e:	83 e2 e0             	and    $0xffffffe0,%edx
80106061:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606b:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106072:	80 
80106073:	83 e2 1f             	and    $0x1f,%edx
80106076:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010607d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106080:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106087:	80 
80106088:	83 e2 f0             	and    $0xfffffff0,%edx
8010608b:	83 ca 0e             	or     $0xe,%edx
8010608e:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106098:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010609f:	80 
801060a0:	83 e2 ef             	and    $0xffffffef,%edx
801060a3:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ad:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801060b4:	80 
801060b5:	83 e2 9f             	and    $0xffffff9f,%edx
801060b8:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c2:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801060c9:	80 
801060ca:	83 ca 80             	or     $0xffffff80,%edx
801060cd:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801060d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d7:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
801060de:	c1 e8 10             	shr    $0x10,%eax
801060e1:	89 c2                	mov    %eax,%edx
801060e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e6:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801060ed:	80 
  for(i = 0; i < 256; i++)
801060ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801060f2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801060f9:	0f 8e 30 ff ff ff    	jle    8010602f <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060ff:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106104:	66 a3 80 77 19 80    	mov    %ax,0x80197780
8010610a:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
80106111:	08 00 
80106113:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
8010611a:	83 e0 e0             	and    $0xffffffe0,%eax
8010611d:	a2 84 77 19 80       	mov    %al,0x80197784
80106122:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106129:	83 e0 1f             	and    $0x1f,%eax
8010612c:	a2 84 77 19 80       	mov    %al,0x80197784
80106131:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106138:	83 c8 0f             	or     $0xf,%eax
8010613b:	a2 85 77 19 80       	mov    %al,0x80197785
80106140:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106147:	83 e0 ef             	and    $0xffffffef,%eax
8010614a:	a2 85 77 19 80       	mov    %al,0x80197785
8010614f:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106156:	83 c8 60             	or     $0x60,%eax
80106159:	a2 85 77 19 80       	mov    %al,0x80197785
8010615e:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106165:	83 c8 80             	or     $0xffffff80,%eax
80106168:	a2 85 77 19 80       	mov    %al,0x80197785
8010616d:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106172:	c1 e8 10             	shr    $0x10,%eax
80106175:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
8010617b:	83 ec 08             	sub    $0x8,%esp
8010617e:	68 58 a8 10 80       	push   $0x8010a858
80106183:	68 40 75 19 80       	push   $0x80197540
80106188:	e8 34 e7 ff ff       	call   801048c1 <initlock>
8010618d:	83 c4 10             	add    $0x10,%esp
}
80106190:	90                   	nop
80106191:	c9                   	leave
80106192:	c3                   	ret

80106193 <idtinit>:

void
idtinit(void)
{
80106193:	f3 0f 1e fb          	endbr32
80106197:	55                   	push   %ebp
80106198:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010619a:	68 00 08 00 00       	push   $0x800
8010619f:	68 80 75 19 80       	push   $0x80197580
801061a4:	e8 35 fe ff ff       	call   80105fde <lidt>
801061a9:	83 c4 08             	add    $0x8,%esp
}
801061ac:	90                   	nop
801061ad:	c9                   	leave
801061ae:	c3                   	ret

801061af <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801061af:	f3 0f 1e fb          	endbr32
801061b3:	55                   	push   %ebp
801061b4:	89 e5                	mov    %esp,%ebp
801061b6:	57                   	push   %edi
801061b7:	56                   	push   %esi
801061b8:	53                   	push   %ebx
801061b9:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801061bc:	8b 45 08             	mov    0x8(%ebp),%eax
801061bf:	8b 40 30             	mov    0x30(%eax),%eax
801061c2:	83 f8 40             	cmp    $0x40,%eax
801061c5:	75 3b                	jne    80106202 <trap+0x53>
    if(myproc()->killed)
801061c7:	e8 dd d9 ff ff       	call   80103ba9 <myproc>
801061cc:	8b 40 24             	mov    0x24(%eax),%eax
801061cf:	85 c0                	test   %eax,%eax
801061d1:	74 05                	je     801061d8 <trap+0x29>
      exit();
801061d3:	e8 61 de ff ff       	call   80104039 <exit>
    myproc()->tf = tf;
801061d8:	e8 cc d9 ff ff       	call   80103ba9 <myproc>
801061dd:	8b 55 08             	mov    0x8(%ebp),%edx
801061e0:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801061e3:	e8 ba ed ff ff       	call   80104fa2 <syscall>
    if(myproc()->killed)
801061e8:	e8 bc d9 ff ff       	call   80103ba9 <myproc>
801061ed:	8b 40 24             	mov    0x24(%eax),%eax
801061f0:	85 c0                	test   %eax,%eax
801061f2:	0f 84 95 02 00 00    	je     8010648d <trap+0x2de>
      exit();
801061f8:	e8 3c de ff ff       	call   80104039 <exit>
    return;
801061fd:	e9 8b 02 00 00       	jmp    8010648d <trap+0x2de>
  }

  switch(tf->trapno){
80106202:	8b 45 08             	mov    0x8(%ebp),%eax
80106205:	8b 40 30             	mov    0x30(%eax),%eax
80106208:	83 e8 20             	sub    $0x20,%eax
8010620b:	83 f8 1f             	cmp    $0x1f,%eax
8010620e:	0f 87 41 01 00 00    	ja     80106355 <trap+0x1a6>
80106214:	8b 04 85 08 a9 10 80 	mov    -0x7fef56f8(,%eax,4),%eax
8010621b:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010621e:	e8 eb d8 ff ff       	call   80103b0e <cpuid>
80106223:	85 c0                	test   %eax,%eax
80106225:	75 3d                	jne    80106264 <trap+0xb5>
      acquire(&tickslock);
80106227:	83 ec 0c             	sub    $0xc,%esp
8010622a:	68 40 75 19 80       	push   $0x80197540
8010622f:	e8 b3 e6 ff ff       	call   801048e7 <acquire>
80106234:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106237:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010623c:	83 c0 01             	add    $0x1,%eax
8010623f:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106244:	83 ec 0c             	sub    $0xc,%esp
80106247:	68 80 7d 19 80       	push   $0x80197d80
8010624c:	e8 42 e3 ff ff       	call   80104593 <wakeup>
80106251:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106254:	83 ec 0c             	sub    $0xc,%esp
80106257:	68 40 75 19 80       	push   $0x80197540
8010625c:	e8 f8 e6 ff ff       	call   80104959 <release>
80106261:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106264:	e8 bc c9 ff ff       	call   80102c25 <lapiceoi>

    // 여기서부터 코드 시작

    struct proc* p = myproc();
80106269:	e8 3b d9 ff ff       	call   80103ba9 <myproc>
8010626e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//    if(p != 0){cprintf("p: %d",p);}
    
    if ((tf->cs&3) == 0 && p != 0 && p->scheduler != 0 && ticks % 20 == 0) {
80106271:	8b 45 08             	mov    0x8(%ebp),%eax
80106274:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106278:	0f b7 c0             	movzwl %ax,%eax
8010627b:	83 e0 03             	and    $0x3,%eax
8010627e:	85 c0                	test   %eax,%eax
80106280:	0f 85 86 01 00 00    	jne    8010640c <trap+0x25d>
80106286:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010628a:	0f 84 7c 01 00 00    	je     8010640c <trap+0x25d>
80106290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106293:	8b 40 7c             	mov    0x7c(%eax),%eax
80106296:	85 c0                	test   %eax,%eax
80106298:	0f 84 6e 01 00 00    	je     8010640c <trap+0x25d>
8010629e:	8b 0d 80 7d 19 80    	mov    0x80197d80,%ecx
801062a4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801062a9:	89 c8                	mov    %ecx,%eax
801062ab:	f7 e2                	mul    %edx
801062ad:	c1 ea 04             	shr    $0x4,%edx
801062b0:	89 d0                	mov    %edx,%eax
801062b2:	c1 e0 02             	shl    $0x2,%eax
801062b5:	01 d0                	add    %edx,%eax
801062b7:	c1 e0 02             	shl    $0x2,%eax
801062ba:	29 c1                	sub    %eax,%ecx
801062bc:	89 ca                	mov    %ecx,%edx
801062be:	85 d2                	test   %edx,%edx
801062c0:	0f 85 46 01 00 00    	jne    8010640c <trap+0x25d>
      cprintf("trap in");
801062c6:	83 ec 0c             	sub    $0xc,%esp
801062c9:	68 5d a8 10 80       	push   $0x8010a85d
801062ce:	e8 39 a1 ff ff       	call   8010040c <cprintf>
801062d3:	83 c4 10             	add    $0x10,%esp
      p->tf->eip = (uint)p->scheduler;
801062d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d9:	8b 40 18             	mov    0x18(%eax),%eax
801062dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801062df:	8b 52 7c             	mov    0x7c(%edx),%edx
801062e2:	89 50 38             	mov    %edx,0x38(%eax)
    }

    break;
801062e5:	e9 22 01 00 00       	jmp    8010640c <trap+0x25d>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801062ea:	e8 1e 40 00 00       	call   8010a30d <ideintr>
    lapiceoi();
801062ef:	e8 31 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
801062f4:	e9 14 01 00 00       	jmp    8010640d <trap+0x25e>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801062f9:	e8 5d c7 ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
801062fe:	e8 22 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
80106303:	e9 05 01 00 00       	jmp    8010640d <trap+0x25e>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106308:	e8 62 03 00 00       	call   8010666f <uartintr>
    lapiceoi();
8010630d:	e8 13 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
80106312:	e9 f6 00 00 00       	jmp    8010640d <trap+0x25e>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106317:	e8 30 2c 00 00       	call   80108f4c <i8254_intr>
    lapiceoi();
8010631c:	e8 04 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
80106321:	e9 e7 00 00 00       	jmp    8010640d <trap+0x25e>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106326:	8b 45 08             	mov    0x8(%ebp),%eax
80106329:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010632c:	8b 45 08             	mov    0x8(%ebp),%eax
8010632f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106333:	0f b7 d8             	movzwl %ax,%ebx
80106336:	e8 d3 d7 ff ff       	call   80103b0e <cpuid>
8010633b:	56                   	push   %esi
8010633c:	53                   	push   %ebx
8010633d:	50                   	push   %eax
8010633e:	68 68 a8 10 80       	push   $0x8010a868
80106343:	e8 c4 a0 ff ff       	call   8010040c <cprintf>
80106348:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010634b:	e8 d5 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
80106350:	e9 b8 00 00 00       	jmp    8010640d <trap+0x25e>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106355:	e8 4f d8 ff ff       	call   80103ba9 <myproc>
8010635a:	85 c0                	test   %eax,%eax
8010635c:	74 11                	je     8010636f <trap+0x1c0>
8010635e:	8b 45 08             	mov    0x8(%ebp),%eax
80106361:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106365:	0f b7 c0             	movzwl %ax,%eax
80106368:	83 e0 03             	and    $0x3,%eax
8010636b:	85 c0                	test   %eax,%eax
8010636d:	75 39                	jne    801063a8 <trap+0x1f9>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010636f:	e8 94 fc ff ff       	call   80106008 <rcr2>
80106374:	89 c3                	mov    %eax,%ebx
80106376:	8b 45 08             	mov    0x8(%ebp),%eax
80106379:	8b 70 38             	mov    0x38(%eax),%esi
8010637c:	e8 8d d7 ff ff       	call   80103b0e <cpuid>
80106381:	8b 55 08             	mov    0x8(%ebp),%edx
80106384:	8b 52 30             	mov    0x30(%edx),%edx
80106387:	83 ec 0c             	sub    $0xc,%esp
8010638a:	53                   	push   %ebx
8010638b:	56                   	push   %esi
8010638c:	50                   	push   %eax
8010638d:	52                   	push   %edx
8010638e:	68 8c a8 10 80       	push   $0x8010a88c
80106393:	e8 74 a0 ff ff       	call   8010040c <cprintf>
80106398:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010639b:	83 ec 0c             	sub    $0xc,%esp
8010639e:	68 be a8 10 80       	push   $0x8010a8be
801063a3:	e8 1d a2 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801063a8:	e8 5b fc ff ff       	call   80106008 <rcr2>
801063ad:	89 c6                	mov    %eax,%esi
801063af:	8b 45 08             	mov    0x8(%ebp),%eax
801063b2:	8b 40 38             	mov    0x38(%eax),%eax
801063b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801063b8:	e8 51 d7 ff ff       	call   80103b0e <cpuid>
801063bd:	89 c3                	mov    %eax,%ebx
801063bf:	8b 45 08             	mov    0x8(%ebp),%eax
801063c2:	8b 78 34             	mov    0x34(%eax),%edi
801063c5:	89 7d d0             	mov    %edi,-0x30(%ebp)
801063c8:	8b 45 08             	mov    0x8(%ebp),%eax
801063cb:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801063ce:	e8 d6 d7 ff ff       	call   80103ba9 <myproc>
801063d3:	8d 48 6c             	lea    0x6c(%eax),%ecx
801063d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801063d9:	e8 cb d7 ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801063de:	8b 40 10             	mov    0x10(%eax),%eax
801063e1:	56                   	push   %esi
801063e2:	ff 75 d4             	push   -0x2c(%ebp)
801063e5:	53                   	push   %ebx
801063e6:	ff 75 d0             	push   -0x30(%ebp)
801063e9:	57                   	push   %edi
801063ea:	ff 75 cc             	push   -0x34(%ebp)
801063ed:	50                   	push   %eax
801063ee:	68 c4 a8 10 80       	push   $0x8010a8c4
801063f3:	e8 14 a0 ff ff       	call   8010040c <cprintf>
801063f8:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801063fb:	e8 a9 d7 ff ff       	call   80103ba9 <myproc>
80106400:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106407:	eb 04                	jmp    8010640d <trap+0x25e>
    break;
80106409:	90                   	nop
8010640a:	eb 01                	jmp    8010640d <trap+0x25e>
    break;
8010640c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010640d:	e8 97 d7 ff ff       	call   80103ba9 <myproc>
80106412:	85 c0                	test   %eax,%eax
80106414:	74 23                	je     80106439 <trap+0x28a>
80106416:	e8 8e d7 ff ff       	call   80103ba9 <myproc>
8010641b:	8b 40 24             	mov    0x24(%eax),%eax
8010641e:	85 c0                	test   %eax,%eax
80106420:	74 17                	je     80106439 <trap+0x28a>
80106422:	8b 45 08             	mov    0x8(%ebp),%eax
80106425:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106429:	0f b7 c0             	movzwl %ax,%eax
8010642c:	83 e0 03             	and    $0x3,%eax
8010642f:	83 f8 03             	cmp    $0x3,%eax
80106432:	75 05                	jne    80106439 <trap+0x28a>
    exit();
80106434:	e8 00 dc ff ff       	call   80104039 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106439:	e8 6b d7 ff ff       	call   80103ba9 <myproc>
8010643e:	85 c0                	test   %eax,%eax
80106440:	74 1d                	je     8010645f <trap+0x2b0>
80106442:	e8 62 d7 ff ff       	call   80103ba9 <myproc>
80106447:	8b 40 0c             	mov    0xc(%eax),%eax
8010644a:	83 f8 04             	cmp    $0x4,%eax
8010644d:	75 10                	jne    8010645f <trap+0x2b0>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010644f:	8b 45 08             	mov    0x8(%ebp),%eax
80106452:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106455:	83 f8 20             	cmp    $0x20,%eax
80106458:	75 05                	jne    8010645f <trap+0x2b0>
    yield();
8010645a:	e8 bd df ff ff       	call   8010441c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010645f:	e8 45 d7 ff ff       	call   80103ba9 <myproc>
80106464:	85 c0                	test   %eax,%eax
80106466:	74 26                	je     8010648e <trap+0x2df>
80106468:	e8 3c d7 ff ff       	call   80103ba9 <myproc>
8010646d:	8b 40 24             	mov    0x24(%eax),%eax
80106470:	85 c0                	test   %eax,%eax
80106472:	74 1a                	je     8010648e <trap+0x2df>
80106474:	8b 45 08             	mov    0x8(%ebp),%eax
80106477:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010647b:	0f b7 c0             	movzwl %ax,%eax
8010647e:	83 e0 03             	and    $0x3,%eax
80106481:	83 f8 03             	cmp    $0x3,%eax
80106484:	75 08                	jne    8010648e <trap+0x2df>
    exit();
80106486:	e8 ae db ff ff       	call   80104039 <exit>
8010648b:	eb 01                	jmp    8010648e <trap+0x2df>
    return;
8010648d:	90                   	nop
}
8010648e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106491:	5b                   	pop    %ebx
80106492:	5e                   	pop    %esi
80106493:	5f                   	pop    %edi
80106494:	5d                   	pop    %ebp
80106495:	c3                   	ret

80106496 <inb>:
{
80106496:	55                   	push   %ebp
80106497:	89 e5                	mov    %esp,%ebp
80106499:	83 ec 14             	sub    $0x14,%esp
8010649c:	8b 45 08             	mov    0x8(%ebp),%eax
8010649f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801064a3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801064a7:	89 c2                	mov    %eax,%edx
801064a9:	ec                   	in     (%dx),%al
801064aa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801064ad:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801064b1:	c9                   	leave
801064b2:	c3                   	ret

801064b3 <outb>:
{
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	83 ec 08             	sub    $0x8,%esp
801064b9:	8b 45 08             	mov    0x8(%ebp),%eax
801064bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801064bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801064c3:	89 d0                	mov    %edx,%eax
801064c5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064c8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064cc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064d0:	ee                   	out    %al,(%dx)
}
801064d1:	90                   	nop
801064d2:	c9                   	leave
801064d3:	c3                   	ret

801064d4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801064d4:	f3 0f 1e fb          	endbr32
801064d8:	55                   	push   %ebp
801064d9:	89 e5                	mov    %esp,%ebp
801064db:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801064de:	6a 00                	push   $0x0
801064e0:	68 fa 03 00 00       	push   $0x3fa
801064e5:	e8 c9 ff ff ff       	call   801064b3 <outb>
801064ea:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801064ed:	68 80 00 00 00       	push   $0x80
801064f2:	68 fb 03 00 00       	push   $0x3fb
801064f7:	e8 b7 ff ff ff       	call   801064b3 <outb>
801064fc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801064ff:	6a 0c                	push   $0xc
80106501:	68 f8 03 00 00       	push   $0x3f8
80106506:	e8 a8 ff ff ff       	call   801064b3 <outb>
8010650b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010650e:	6a 00                	push   $0x0
80106510:	68 f9 03 00 00       	push   $0x3f9
80106515:	e8 99 ff ff ff       	call   801064b3 <outb>
8010651a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010651d:	6a 03                	push   $0x3
8010651f:	68 fb 03 00 00       	push   $0x3fb
80106524:	e8 8a ff ff ff       	call   801064b3 <outb>
80106529:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010652c:	6a 00                	push   $0x0
8010652e:	68 fc 03 00 00       	push   $0x3fc
80106533:	e8 7b ff ff ff       	call   801064b3 <outb>
80106538:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010653b:	6a 01                	push   $0x1
8010653d:	68 f9 03 00 00       	push   $0x3f9
80106542:	e8 6c ff ff ff       	call   801064b3 <outb>
80106547:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010654a:	68 fd 03 00 00       	push   $0x3fd
8010654f:	e8 42 ff ff ff       	call   80106496 <inb>
80106554:	83 c4 04             	add    $0x4,%esp
80106557:	3c ff                	cmp    $0xff,%al
80106559:	74 61                	je     801065bc <uartinit+0xe8>
    return;
  uart = 1;
8010655b:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106562:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106565:	68 fa 03 00 00       	push   $0x3fa
8010656a:	e8 27 ff ff ff       	call   80106496 <inb>
8010656f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106572:	68 f8 03 00 00       	push   $0x3f8
80106577:	e8 1a ff ff ff       	call   80106496 <inb>
8010657c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010657f:	83 ec 08             	sub    $0x8,%esp
80106582:	6a 00                	push   $0x0
80106584:	6a 04                	push   $0x4
80106586:	e8 81 c1 ff ff       	call   8010270c <ioapicenable>
8010658b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010658e:	c7 45 f4 88 a9 10 80 	movl   $0x8010a988,-0xc(%ebp)
80106595:	eb 19                	jmp    801065b0 <uartinit+0xdc>
    uartputc(*p);
80106597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010659a:	0f b6 00             	movzbl (%eax),%eax
8010659d:	0f be c0             	movsbl %al,%eax
801065a0:	83 ec 0c             	sub    $0xc,%esp
801065a3:	50                   	push   %eax
801065a4:	e8 16 00 00 00       	call   801065bf <uartputc>
801065a9:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801065ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b3:	0f b6 00             	movzbl (%eax),%eax
801065b6:	84 c0                	test   %al,%al
801065b8:	75 dd                	jne    80106597 <uartinit+0xc3>
801065ba:	eb 01                	jmp    801065bd <uartinit+0xe9>
    return;
801065bc:	90                   	nop
}
801065bd:	c9                   	leave
801065be:	c3                   	ret

801065bf <uartputc>:

void
uartputc(int c)
{
801065bf:	f3 0f 1e fb          	endbr32
801065c3:	55                   	push   %ebp
801065c4:	89 e5                	mov    %esp,%ebp
801065c6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801065c9:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801065ce:	85 c0                	test   %eax,%eax
801065d0:	74 53                	je     80106625 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801065d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801065d9:	eb 11                	jmp    801065ec <uartputc+0x2d>
    microdelay(10);
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	6a 0a                	push   $0xa
801065e0:	e8 5f c6 ff ff       	call   80102c44 <microdelay>
801065e5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801065e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065ec:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801065f0:	7f 1a                	jg     8010660c <uartputc+0x4d>
801065f2:	83 ec 0c             	sub    $0xc,%esp
801065f5:	68 fd 03 00 00       	push   $0x3fd
801065fa:	e8 97 fe ff ff       	call   80106496 <inb>
801065ff:	83 c4 10             	add    $0x10,%esp
80106602:	0f b6 c0             	movzbl %al,%eax
80106605:	83 e0 20             	and    $0x20,%eax
80106608:	85 c0                	test   %eax,%eax
8010660a:	74 cf                	je     801065db <uartputc+0x1c>
  outb(COM1+0, c);
8010660c:	8b 45 08             	mov    0x8(%ebp),%eax
8010660f:	0f b6 c0             	movzbl %al,%eax
80106612:	83 ec 08             	sub    $0x8,%esp
80106615:	50                   	push   %eax
80106616:	68 f8 03 00 00       	push   $0x3f8
8010661b:	e8 93 fe ff ff       	call   801064b3 <outb>
80106620:	83 c4 10             	add    $0x10,%esp
80106623:	eb 01                	jmp    80106626 <uartputc+0x67>
    return;
80106625:	90                   	nop
}
80106626:	c9                   	leave
80106627:	c3                   	ret

80106628 <uartgetc>:

static int
uartgetc(void)
{
80106628:	f3 0f 1e fb          	endbr32
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010662f:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106634:	85 c0                	test   %eax,%eax
80106636:	75 07                	jne    8010663f <uartgetc+0x17>
    return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	eb 2e                	jmp    8010666d <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
8010663f:	68 fd 03 00 00       	push   $0x3fd
80106644:	e8 4d fe ff ff       	call   80106496 <inb>
80106649:	83 c4 04             	add    $0x4,%esp
8010664c:	0f b6 c0             	movzbl %al,%eax
8010664f:	83 e0 01             	and    $0x1,%eax
80106652:	85 c0                	test   %eax,%eax
80106654:	75 07                	jne    8010665d <uartgetc+0x35>
    return -1;
80106656:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665b:	eb 10                	jmp    8010666d <uartgetc+0x45>
  return inb(COM1+0);
8010665d:	68 f8 03 00 00       	push   $0x3f8
80106662:	e8 2f fe ff ff       	call   80106496 <inb>
80106667:	83 c4 04             	add    $0x4,%esp
8010666a:	0f b6 c0             	movzbl %al,%eax
}
8010666d:	c9                   	leave
8010666e:	c3                   	ret

8010666f <uartintr>:

void
uartintr(void)
{
8010666f:	f3 0f 1e fb          	endbr32
80106673:	55                   	push   %ebp
80106674:	89 e5                	mov    %esp,%ebp
80106676:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106679:	83 ec 0c             	sub    $0xc,%esp
8010667c:	68 28 66 10 80       	push   $0x80106628
80106681:	e8 7a a1 ff ff       	call   80100800 <consoleintr>
80106686:	83 c4 10             	add    $0x10,%esp
}
80106689:	90                   	nop
8010668a:	c9                   	leave
8010668b:	c3                   	ret

8010668c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010668c:	6a 00                	push   $0x0
  pushl $0
8010668e:	6a 00                	push   $0x0
  jmp alltraps
80106690:	e9 26 f9 ff ff       	jmp    80105fbb <alltraps>

80106695 <vector1>:
.globl vector1
vector1:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $1
80106697:	6a 01                	push   $0x1
  jmp alltraps
80106699:	e9 1d f9 ff ff       	jmp    80105fbb <alltraps>

8010669e <vector2>:
.globl vector2
vector2:
  pushl $0
8010669e:	6a 00                	push   $0x0
  pushl $2
801066a0:	6a 02                	push   $0x2
  jmp alltraps
801066a2:	e9 14 f9 ff ff       	jmp    80105fbb <alltraps>

801066a7 <vector3>:
.globl vector3
vector3:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $3
801066a9:	6a 03                	push   $0x3
  jmp alltraps
801066ab:	e9 0b f9 ff ff       	jmp    80105fbb <alltraps>

801066b0 <vector4>:
.globl vector4
vector4:
  pushl $0
801066b0:	6a 00                	push   $0x0
  pushl $4
801066b2:	6a 04                	push   $0x4
  jmp alltraps
801066b4:	e9 02 f9 ff ff       	jmp    80105fbb <alltraps>

801066b9 <vector5>:
.globl vector5
vector5:
  pushl $0
801066b9:	6a 00                	push   $0x0
  pushl $5
801066bb:	6a 05                	push   $0x5
  jmp alltraps
801066bd:	e9 f9 f8 ff ff       	jmp    80105fbb <alltraps>

801066c2 <vector6>:
.globl vector6
vector6:
  pushl $0
801066c2:	6a 00                	push   $0x0
  pushl $6
801066c4:	6a 06                	push   $0x6
  jmp alltraps
801066c6:	e9 f0 f8 ff ff       	jmp    80105fbb <alltraps>

801066cb <vector7>:
.globl vector7
vector7:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $7
801066cd:	6a 07                	push   $0x7
  jmp alltraps
801066cf:	e9 e7 f8 ff ff       	jmp    80105fbb <alltraps>

801066d4 <vector8>:
.globl vector8
vector8:
  pushl $8
801066d4:	6a 08                	push   $0x8
  jmp alltraps
801066d6:	e9 e0 f8 ff ff       	jmp    80105fbb <alltraps>

801066db <vector9>:
.globl vector9
vector9:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $9
801066dd:	6a 09                	push   $0x9
  jmp alltraps
801066df:	e9 d7 f8 ff ff       	jmp    80105fbb <alltraps>

801066e4 <vector10>:
.globl vector10
vector10:
  pushl $10
801066e4:	6a 0a                	push   $0xa
  jmp alltraps
801066e6:	e9 d0 f8 ff ff       	jmp    80105fbb <alltraps>

801066eb <vector11>:
.globl vector11
vector11:
  pushl $11
801066eb:	6a 0b                	push   $0xb
  jmp alltraps
801066ed:	e9 c9 f8 ff ff       	jmp    80105fbb <alltraps>

801066f2 <vector12>:
.globl vector12
vector12:
  pushl $12
801066f2:	6a 0c                	push   $0xc
  jmp alltraps
801066f4:	e9 c2 f8 ff ff       	jmp    80105fbb <alltraps>

801066f9 <vector13>:
.globl vector13
vector13:
  pushl $13
801066f9:	6a 0d                	push   $0xd
  jmp alltraps
801066fb:	e9 bb f8 ff ff       	jmp    80105fbb <alltraps>

80106700 <vector14>:
.globl vector14
vector14:
  pushl $14
80106700:	6a 0e                	push   $0xe
  jmp alltraps
80106702:	e9 b4 f8 ff ff       	jmp    80105fbb <alltraps>

80106707 <vector15>:
.globl vector15
vector15:
  pushl $0
80106707:	6a 00                	push   $0x0
  pushl $15
80106709:	6a 0f                	push   $0xf
  jmp alltraps
8010670b:	e9 ab f8 ff ff       	jmp    80105fbb <alltraps>

80106710 <vector16>:
.globl vector16
vector16:
  pushl $0
80106710:	6a 00                	push   $0x0
  pushl $16
80106712:	6a 10                	push   $0x10
  jmp alltraps
80106714:	e9 a2 f8 ff ff       	jmp    80105fbb <alltraps>

80106719 <vector17>:
.globl vector17
vector17:
  pushl $17
80106719:	6a 11                	push   $0x11
  jmp alltraps
8010671b:	e9 9b f8 ff ff       	jmp    80105fbb <alltraps>

80106720 <vector18>:
.globl vector18
vector18:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $18
80106722:	6a 12                	push   $0x12
  jmp alltraps
80106724:	e9 92 f8 ff ff       	jmp    80105fbb <alltraps>

80106729 <vector19>:
.globl vector19
vector19:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $19
8010672b:	6a 13                	push   $0x13
  jmp alltraps
8010672d:	e9 89 f8 ff ff       	jmp    80105fbb <alltraps>

80106732 <vector20>:
.globl vector20
vector20:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $20
80106734:	6a 14                	push   $0x14
  jmp alltraps
80106736:	e9 80 f8 ff ff       	jmp    80105fbb <alltraps>

8010673b <vector21>:
.globl vector21
vector21:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $21
8010673d:	6a 15                	push   $0x15
  jmp alltraps
8010673f:	e9 77 f8 ff ff       	jmp    80105fbb <alltraps>

80106744 <vector22>:
.globl vector22
vector22:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $22
80106746:	6a 16                	push   $0x16
  jmp alltraps
80106748:	e9 6e f8 ff ff       	jmp    80105fbb <alltraps>

8010674d <vector23>:
.globl vector23
vector23:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $23
8010674f:	6a 17                	push   $0x17
  jmp alltraps
80106751:	e9 65 f8 ff ff       	jmp    80105fbb <alltraps>

80106756 <vector24>:
.globl vector24
vector24:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $24
80106758:	6a 18                	push   $0x18
  jmp alltraps
8010675a:	e9 5c f8 ff ff       	jmp    80105fbb <alltraps>

8010675f <vector25>:
.globl vector25
vector25:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $25
80106761:	6a 19                	push   $0x19
  jmp alltraps
80106763:	e9 53 f8 ff ff       	jmp    80105fbb <alltraps>

80106768 <vector26>:
.globl vector26
vector26:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $26
8010676a:	6a 1a                	push   $0x1a
  jmp alltraps
8010676c:	e9 4a f8 ff ff       	jmp    80105fbb <alltraps>

80106771 <vector27>:
.globl vector27
vector27:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $27
80106773:	6a 1b                	push   $0x1b
  jmp alltraps
80106775:	e9 41 f8 ff ff       	jmp    80105fbb <alltraps>

8010677a <vector28>:
.globl vector28
vector28:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $28
8010677c:	6a 1c                	push   $0x1c
  jmp alltraps
8010677e:	e9 38 f8 ff ff       	jmp    80105fbb <alltraps>

80106783 <vector29>:
.globl vector29
vector29:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $29
80106785:	6a 1d                	push   $0x1d
  jmp alltraps
80106787:	e9 2f f8 ff ff       	jmp    80105fbb <alltraps>

8010678c <vector30>:
.globl vector30
vector30:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $30
8010678e:	6a 1e                	push   $0x1e
  jmp alltraps
80106790:	e9 26 f8 ff ff       	jmp    80105fbb <alltraps>

80106795 <vector31>:
.globl vector31
vector31:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $31
80106797:	6a 1f                	push   $0x1f
  jmp alltraps
80106799:	e9 1d f8 ff ff       	jmp    80105fbb <alltraps>

8010679e <vector32>:
.globl vector32
vector32:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $32
801067a0:	6a 20                	push   $0x20
  jmp alltraps
801067a2:	e9 14 f8 ff ff       	jmp    80105fbb <alltraps>

801067a7 <vector33>:
.globl vector33
vector33:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $33
801067a9:	6a 21                	push   $0x21
  jmp alltraps
801067ab:	e9 0b f8 ff ff       	jmp    80105fbb <alltraps>

801067b0 <vector34>:
.globl vector34
vector34:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $34
801067b2:	6a 22                	push   $0x22
  jmp alltraps
801067b4:	e9 02 f8 ff ff       	jmp    80105fbb <alltraps>

801067b9 <vector35>:
.globl vector35
vector35:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $35
801067bb:	6a 23                	push   $0x23
  jmp alltraps
801067bd:	e9 f9 f7 ff ff       	jmp    80105fbb <alltraps>

801067c2 <vector36>:
.globl vector36
vector36:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $36
801067c4:	6a 24                	push   $0x24
  jmp alltraps
801067c6:	e9 f0 f7 ff ff       	jmp    80105fbb <alltraps>

801067cb <vector37>:
.globl vector37
vector37:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $37
801067cd:	6a 25                	push   $0x25
  jmp alltraps
801067cf:	e9 e7 f7 ff ff       	jmp    80105fbb <alltraps>

801067d4 <vector38>:
.globl vector38
vector38:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $38
801067d6:	6a 26                	push   $0x26
  jmp alltraps
801067d8:	e9 de f7 ff ff       	jmp    80105fbb <alltraps>

801067dd <vector39>:
.globl vector39
vector39:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $39
801067df:	6a 27                	push   $0x27
  jmp alltraps
801067e1:	e9 d5 f7 ff ff       	jmp    80105fbb <alltraps>

801067e6 <vector40>:
.globl vector40
vector40:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $40
801067e8:	6a 28                	push   $0x28
  jmp alltraps
801067ea:	e9 cc f7 ff ff       	jmp    80105fbb <alltraps>

801067ef <vector41>:
.globl vector41
vector41:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $41
801067f1:	6a 29                	push   $0x29
  jmp alltraps
801067f3:	e9 c3 f7 ff ff       	jmp    80105fbb <alltraps>

801067f8 <vector42>:
.globl vector42
vector42:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $42
801067fa:	6a 2a                	push   $0x2a
  jmp alltraps
801067fc:	e9 ba f7 ff ff       	jmp    80105fbb <alltraps>

80106801 <vector43>:
.globl vector43
vector43:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $43
80106803:	6a 2b                	push   $0x2b
  jmp alltraps
80106805:	e9 b1 f7 ff ff       	jmp    80105fbb <alltraps>

8010680a <vector44>:
.globl vector44
vector44:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $44
8010680c:	6a 2c                	push   $0x2c
  jmp alltraps
8010680e:	e9 a8 f7 ff ff       	jmp    80105fbb <alltraps>

80106813 <vector45>:
.globl vector45
vector45:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $45
80106815:	6a 2d                	push   $0x2d
  jmp alltraps
80106817:	e9 9f f7 ff ff       	jmp    80105fbb <alltraps>

8010681c <vector46>:
.globl vector46
vector46:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $46
8010681e:	6a 2e                	push   $0x2e
  jmp alltraps
80106820:	e9 96 f7 ff ff       	jmp    80105fbb <alltraps>

80106825 <vector47>:
.globl vector47
vector47:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $47
80106827:	6a 2f                	push   $0x2f
  jmp alltraps
80106829:	e9 8d f7 ff ff       	jmp    80105fbb <alltraps>

8010682e <vector48>:
.globl vector48
vector48:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $48
80106830:	6a 30                	push   $0x30
  jmp alltraps
80106832:	e9 84 f7 ff ff       	jmp    80105fbb <alltraps>

80106837 <vector49>:
.globl vector49
vector49:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $49
80106839:	6a 31                	push   $0x31
  jmp alltraps
8010683b:	e9 7b f7 ff ff       	jmp    80105fbb <alltraps>

80106840 <vector50>:
.globl vector50
vector50:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $50
80106842:	6a 32                	push   $0x32
  jmp alltraps
80106844:	e9 72 f7 ff ff       	jmp    80105fbb <alltraps>

80106849 <vector51>:
.globl vector51
vector51:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $51
8010684b:	6a 33                	push   $0x33
  jmp alltraps
8010684d:	e9 69 f7 ff ff       	jmp    80105fbb <alltraps>

80106852 <vector52>:
.globl vector52
vector52:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $52
80106854:	6a 34                	push   $0x34
  jmp alltraps
80106856:	e9 60 f7 ff ff       	jmp    80105fbb <alltraps>

8010685b <vector53>:
.globl vector53
vector53:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $53
8010685d:	6a 35                	push   $0x35
  jmp alltraps
8010685f:	e9 57 f7 ff ff       	jmp    80105fbb <alltraps>

80106864 <vector54>:
.globl vector54
vector54:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $54
80106866:	6a 36                	push   $0x36
  jmp alltraps
80106868:	e9 4e f7 ff ff       	jmp    80105fbb <alltraps>

8010686d <vector55>:
.globl vector55
vector55:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $55
8010686f:	6a 37                	push   $0x37
  jmp alltraps
80106871:	e9 45 f7 ff ff       	jmp    80105fbb <alltraps>

80106876 <vector56>:
.globl vector56
vector56:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $56
80106878:	6a 38                	push   $0x38
  jmp alltraps
8010687a:	e9 3c f7 ff ff       	jmp    80105fbb <alltraps>

8010687f <vector57>:
.globl vector57
vector57:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $57
80106881:	6a 39                	push   $0x39
  jmp alltraps
80106883:	e9 33 f7 ff ff       	jmp    80105fbb <alltraps>

80106888 <vector58>:
.globl vector58
vector58:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $58
8010688a:	6a 3a                	push   $0x3a
  jmp alltraps
8010688c:	e9 2a f7 ff ff       	jmp    80105fbb <alltraps>

80106891 <vector59>:
.globl vector59
vector59:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $59
80106893:	6a 3b                	push   $0x3b
  jmp alltraps
80106895:	e9 21 f7 ff ff       	jmp    80105fbb <alltraps>

8010689a <vector60>:
.globl vector60
vector60:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $60
8010689c:	6a 3c                	push   $0x3c
  jmp alltraps
8010689e:	e9 18 f7 ff ff       	jmp    80105fbb <alltraps>

801068a3 <vector61>:
.globl vector61
vector61:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $61
801068a5:	6a 3d                	push   $0x3d
  jmp alltraps
801068a7:	e9 0f f7 ff ff       	jmp    80105fbb <alltraps>

801068ac <vector62>:
.globl vector62
vector62:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $62
801068ae:	6a 3e                	push   $0x3e
  jmp alltraps
801068b0:	e9 06 f7 ff ff       	jmp    80105fbb <alltraps>

801068b5 <vector63>:
.globl vector63
vector63:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $63
801068b7:	6a 3f                	push   $0x3f
  jmp alltraps
801068b9:	e9 fd f6 ff ff       	jmp    80105fbb <alltraps>

801068be <vector64>:
.globl vector64
vector64:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $64
801068c0:	6a 40                	push   $0x40
  jmp alltraps
801068c2:	e9 f4 f6 ff ff       	jmp    80105fbb <alltraps>

801068c7 <vector65>:
.globl vector65
vector65:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $65
801068c9:	6a 41                	push   $0x41
  jmp alltraps
801068cb:	e9 eb f6 ff ff       	jmp    80105fbb <alltraps>

801068d0 <vector66>:
.globl vector66
vector66:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $66
801068d2:	6a 42                	push   $0x42
  jmp alltraps
801068d4:	e9 e2 f6 ff ff       	jmp    80105fbb <alltraps>

801068d9 <vector67>:
.globl vector67
vector67:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $67
801068db:	6a 43                	push   $0x43
  jmp alltraps
801068dd:	e9 d9 f6 ff ff       	jmp    80105fbb <alltraps>

801068e2 <vector68>:
.globl vector68
vector68:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $68
801068e4:	6a 44                	push   $0x44
  jmp alltraps
801068e6:	e9 d0 f6 ff ff       	jmp    80105fbb <alltraps>

801068eb <vector69>:
.globl vector69
vector69:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $69
801068ed:	6a 45                	push   $0x45
  jmp alltraps
801068ef:	e9 c7 f6 ff ff       	jmp    80105fbb <alltraps>

801068f4 <vector70>:
.globl vector70
vector70:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $70
801068f6:	6a 46                	push   $0x46
  jmp alltraps
801068f8:	e9 be f6 ff ff       	jmp    80105fbb <alltraps>

801068fd <vector71>:
.globl vector71
vector71:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $71
801068ff:	6a 47                	push   $0x47
  jmp alltraps
80106901:	e9 b5 f6 ff ff       	jmp    80105fbb <alltraps>

80106906 <vector72>:
.globl vector72
vector72:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $72
80106908:	6a 48                	push   $0x48
  jmp alltraps
8010690a:	e9 ac f6 ff ff       	jmp    80105fbb <alltraps>

8010690f <vector73>:
.globl vector73
vector73:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $73
80106911:	6a 49                	push   $0x49
  jmp alltraps
80106913:	e9 a3 f6 ff ff       	jmp    80105fbb <alltraps>

80106918 <vector74>:
.globl vector74
vector74:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $74
8010691a:	6a 4a                	push   $0x4a
  jmp alltraps
8010691c:	e9 9a f6 ff ff       	jmp    80105fbb <alltraps>

80106921 <vector75>:
.globl vector75
vector75:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $75
80106923:	6a 4b                	push   $0x4b
  jmp alltraps
80106925:	e9 91 f6 ff ff       	jmp    80105fbb <alltraps>

8010692a <vector76>:
.globl vector76
vector76:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $76
8010692c:	6a 4c                	push   $0x4c
  jmp alltraps
8010692e:	e9 88 f6 ff ff       	jmp    80105fbb <alltraps>

80106933 <vector77>:
.globl vector77
vector77:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $77
80106935:	6a 4d                	push   $0x4d
  jmp alltraps
80106937:	e9 7f f6 ff ff       	jmp    80105fbb <alltraps>

8010693c <vector78>:
.globl vector78
vector78:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $78
8010693e:	6a 4e                	push   $0x4e
  jmp alltraps
80106940:	e9 76 f6 ff ff       	jmp    80105fbb <alltraps>

80106945 <vector79>:
.globl vector79
vector79:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $79
80106947:	6a 4f                	push   $0x4f
  jmp alltraps
80106949:	e9 6d f6 ff ff       	jmp    80105fbb <alltraps>

8010694e <vector80>:
.globl vector80
vector80:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $80
80106950:	6a 50                	push   $0x50
  jmp alltraps
80106952:	e9 64 f6 ff ff       	jmp    80105fbb <alltraps>

80106957 <vector81>:
.globl vector81
vector81:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $81
80106959:	6a 51                	push   $0x51
  jmp alltraps
8010695b:	e9 5b f6 ff ff       	jmp    80105fbb <alltraps>

80106960 <vector82>:
.globl vector82
vector82:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $82
80106962:	6a 52                	push   $0x52
  jmp alltraps
80106964:	e9 52 f6 ff ff       	jmp    80105fbb <alltraps>

80106969 <vector83>:
.globl vector83
vector83:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $83
8010696b:	6a 53                	push   $0x53
  jmp alltraps
8010696d:	e9 49 f6 ff ff       	jmp    80105fbb <alltraps>

80106972 <vector84>:
.globl vector84
vector84:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $84
80106974:	6a 54                	push   $0x54
  jmp alltraps
80106976:	e9 40 f6 ff ff       	jmp    80105fbb <alltraps>

8010697b <vector85>:
.globl vector85
vector85:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $85
8010697d:	6a 55                	push   $0x55
  jmp alltraps
8010697f:	e9 37 f6 ff ff       	jmp    80105fbb <alltraps>

80106984 <vector86>:
.globl vector86
vector86:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $86
80106986:	6a 56                	push   $0x56
  jmp alltraps
80106988:	e9 2e f6 ff ff       	jmp    80105fbb <alltraps>

8010698d <vector87>:
.globl vector87
vector87:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $87
8010698f:	6a 57                	push   $0x57
  jmp alltraps
80106991:	e9 25 f6 ff ff       	jmp    80105fbb <alltraps>

80106996 <vector88>:
.globl vector88
vector88:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $88
80106998:	6a 58                	push   $0x58
  jmp alltraps
8010699a:	e9 1c f6 ff ff       	jmp    80105fbb <alltraps>

8010699f <vector89>:
.globl vector89
vector89:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $89
801069a1:	6a 59                	push   $0x59
  jmp alltraps
801069a3:	e9 13 f6 ff ff       	jmp    80105fbb <alltraps>

801069a8 <vector90>:
.globl vector90
vector90:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $90
801069aa:	6a 5a                	push   $0x5a
  jmp alltraps
801069ac:	e9 0a f6 ff ff       	jmp    80105fbb <alltraps>

801069b1 <vector91>:
.globl vector91
vector91:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $91
801069b3:	6a 5b                	push   $0x5b
  jmp alltraps
801069b5:	e9 01 f6 ff ff       	jmp    80105fbb <alltraps>

801069ba <vector92>:
.globl vector92
vector92:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $92
801069bc:	6a 5c                	push   $0x5c
  jmp alltraps
801069be:	e9 f8 f5 ff ff       	jmp    80105fbb <alltraps>

801069c3 <vector93>:
.globl vector93
vector93:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $93
801069c5:	6a 5d                	push   $0x5d
  jmp alltraps
801069c7:	e9 ef f5 ff ff       	jmp    80105fbb <alltraps>

801069cc <vector94>:
.globl vector94
vector94:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $94
801069ce:	6a 5e                	push   $0x5e
  jmp alltraps
801069d0:	e9 e6 f5 ff ff       	jmp    80105fbb <alltraps>

801069d5 <vector95>:
.globl vector95
vector95:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $95
801069d7:	6a 5f                	push   $0x5f
  jmp alltraps
801069d9:	e9 dd f5 ff ff       	jmp    80105fbb <alltraps>

801069de <vector96>:
.globl vector96
vector96:
  pushl $0
801069de:	6a 00                	push   $0x0
  pushl $96
801069e0:	6a 60                	push   $0x60
  jmp alltraps
801069e2:	e9 d4 f5 ff ff       	jmp    80105fbb <alltraps>

801069e7 <vector97>:
.globl vector97
vector97:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $97
801069e9:	6a 61                	push   $0x61
  jmp alltraps
801069eb:	e9 cb f5 ff ff       	jmp    80105fbb <alltraps>

801069f0 <vector98>:
.globl vector98
vector98:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $98
801069f2:	6a 62                	push   $0x62
  jmp alltraps
801069f4:	e9 c2 f5 ff ff       	jmp    80105fbb <alltraps>

801069f9 <vector99>:
.globl vector99
vector99:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $99
801069fb:	6a 63                	push   $0x63
  jmp alltraps
801069fd:	e9 b9 f5 ff ff       	jmp    80105fbb <alltraps>

80106a02 <vector100>:
.globl vector100
vector100:
  pushl $0
80106a02:	6a 00                	push   $0x0
  pushl $100
80106a04:	6a 64                	push   $0x64
  jmp alltraps
80106a06:	e9 b0 f5 ff ff       	jmp    80105fbb <alltraps>

80106a0b <vector101>:
.globl vector101
vector101:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $101
80106a0d:	6a 65                	push   $0x65
  jmp alltraps
80106a0f:	e9 a7 f5 ff ff       	jmp    80105fbb <alltraps>

80106a14 <vector102>:
.globl vector102
vector102:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $102
80106a16:	6a 66                	push   $0x66
  jmp alltraps
80106a18:	e9 9e f5 ff ff       	jmp    80105fbb <alltraps>

80106a1d <vector103>:
.globl vector103
vector103:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $103
80106a1f:	6a 67                	push   $0x67
  jmp alltraps
80106a21:	e9 95 f5 ff ff       	jmp    80105fbb <alltraps>

80106a26 <vector104>:
.globl vector104
vector104:
  pushl $0
80106a26:	6a 00                	push   $0x0
  pushl $104
80106a28:	6a 68                	push   $0x68
  jmp alltraps
80106a2a:	e9 8c f5 ff ff       	jmp    80105fbb <alltraps>

80106a2f <vector105>:
.globl vector105
vector105:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $105
80106a31:	6a 69                	push   $0x69
  jmp alltraps
80106a33:	e9 83 f5 ff ff       	jmp    80105fbb <alltraps>

80106a38 <vector106>:
.globl vector106
vector106:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $106
80106a3a:	6a 6a                	push   $0x6a
  jmp alltraps
80106a3c:	e9 7a f5 ff ff       	jmp    80105fbb <alltraps>

80106a41 <vector107>:
.globl vector107
vector107:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $107
80106a43:	6a 6b                	push   $0x6b
  jmp alltraps
80106a45:	e9 71 f5 ff ff       	jmp    80105fbb <alltraps>

80106a4a <vector108>:
.globl vector108
vector108:
  pushl $0
80106a4a:	6a 00                	push   $0x0
  pushl $108
80106a4c:	6a 6c                	push   $0x6c
  jmp alltraps
80106a4e:	e9 68 f5 ff ff       	jmp    80105fbb <alltraps>

80106a53 <vector109>:
.globl vector109
vector109:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $109
80106a55:	6a 6d                	push   $0x6d
  jmp alltraps
80106a57:	e9 5f f5 ff ff       	jmp    80105fbb <alltraps>

80106a5c <vector110>:
.globl vector110
vector110:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $110
80106a5e:	6a 6e                	push   $0x6e
  jmp alltraps
80106a60:	e9 56 f5 ff ff       	jmp    80105fbb <alltraps>

80106a65 <vector111>:
.globl vector111
vector111:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $111
80106a67:	6a 6f                	push   $0x6f
  jmp alltraps
80106a69:	e9 4d f5 ff ff       	jmp    80105fbb <alltraps>

80106a6e <vector112>:
.globl vector112
vector112:
  pushl $0
80106a6e:	6a 00                	push   $0x0
  pushl $112
80106a70:	6a 70                	push   $0x70
  jmp alltraps
80106a72:	e9 44 f5 ff ff       	jmp    80105fbb <alltraps>

80106a77 <vector113>:
.globl vector113
vector113:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $113
80106a79:	6a 71                	push   $0x71
  jmp alltraps
80106a7b:	e9 3b f5 ff ff       	jmp    80105fbb <alltraps>

80106a80 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $114
80106a82:	6a 72                	push   $0x72
  jmp alltraps
80106a84:	e9 32 f5 ff ff       	jmp    80105fbb <alltraps>

80106a89 <vector115>:
.globl vector115
vector115:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $115
80106a8b:	6a 73                	push   $0x73
  jmp alltraps
80106a8d:	e9 29 f5 ff ff       	jmp    80105fbb <alltraps>

80106a92 <vector116>:
.globl vector116
vector116:
  pushl $0
80106a92:	6a 00                	push   $0x0
  pushl $116
80106a94:	6a 74                	push   $0x74
  jmp alltraps
80106a96:	e9 20 f5 ff ff       	jmp    80105fbb <alltraps>

80106a9b <vector117>:
.globl vector117
vector117:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $117
80106a9d:	6a 75                	push   $0x75
  jmp alltraps
80106a9f:	e9 17 f5 ff ff       	jmp    80105fbb <alltraps>

80106aa4 <vector118>:
.globl vector118
vector118:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $118
80106aa6:	6a 76                	push   $0x76
  jmp alltraps
80106aa8:	e9 0e f5 ff ff       	jmp    80105fbb <alltraps>

80106aad <vector119>:
.globl vector119
vector119:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $119
80106aaf:	6a 77                	push   $0x77
  jmp alltraps
80106ab1:	e9 05 f5 ff ff       	jmp    80105fbb <alltraps>

80106ab6 <vector120>:
.globl vector120
vector120:
  pushl $0
80106ab6:	6a 00                	push   $0x0
  pushl $120
80106ab8:	6a 78                	push   $0x78
  jmp alltraps
80106aba:	e9 fc f4 ff ff       	jmp    80105fbb <alltraps>

80106abf <vector121>:
.globl vector121
vector121:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $121
80106ac1:	6a 79                	push   $0x79
  jmp alltraps
80106ac3:	e9 f3 f4 ff ff       	jmp    80105fbb <alltraps>

80106ac8 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $122
80106aca:	6a 7a                	push   $0x7a
  jmp alltraps
80106acc:	e9 ea f4 ff ff       	jmp    80105fbb <alltraps>

80106ad1 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $123
80106ad3:	6a 7b                	push   $0x7b
  jmp alltraps
80106ad5:	e9 e1 f4 ff ff       	jmp    80105fbb <alltraps>

80106ada <vector124>:
.globl vector124
vector124:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $124
80106adc:	6a 7c                	push   $0x7c
  jmp alltraps
80106ade:	e9 d8 f4 ff ff       	jmp    80105fbb <alltraps>

80106ae3 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $125
80106ae5:	6a 7d                	push   $0x7d
  jmp alltraps
80106ae7:	e9 cf f4 ff ff       	jmp    80105fbb <alltraps>

80106aec <vector126>:
.globl vector126
vector126:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $126
80106aee:	6a 7e                	push   $0x7e
  jmp alltraps
80106af0:	e9 c6 f4 ff ff       	jmp    80105fbb <alltraps>

80106af5 <vector127>:
.globl vector127
vector127:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $127
80106af7:	6a 7f                	push   $0x7f
  jmp alltraps
80106af9:	e9 bd f4 ff ff       	jmp    80105fbb <alltraps>

80106afe <vector128>:
.globl vector128
vector128:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $128
80106b00:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106b05:	e9 b1 f4 ff ff       	jmp    80105fbb <alltraps>

80106b0a <vector129>:
.globl vector129
vector129:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $129
80106b0c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b11:	e9 a5 f4 ff ff       	jmp    80105fbb <alltraps>

80106b16 <vector130>:
.globl vector130
vector130:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $130
80106b18:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b1d:	e9 99 f4 ff ff       	jmp    80105fbb <alltraps>

80106b22 <vector131>:
.globl vector131
vector131:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $131
80106b24:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106b29:	e9 8d f4 ff ff       	jmp    80105fbb <alltraps>

80106b2e <vector132>:
.globl vector132
vector132:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $132
80106b30:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106b35:	e9 81 f4 ff ff       	jmp    80105fbb <alltraps>

80106b3a <vector133>:
.globl vector133
vector133:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $133
80106b3c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106b41:	e9 75 f4 ff ff       	jmp    80105fbb <alltraps>

80106b46 <vector134>:
.globl vector134
vector134:
  pushl $0
80106b46:	6a 00                	push   $0x0
  pushl $134
80106b48:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106b4d:	e9 69 f4 ff ff       	jmp    80105fbb <alltraps>

80106b52 <vector135>:
.globl vector135
vector135:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $135
80106b54:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106b59:	e9 5d f4 ff ff       	jmp    80105fbb <alltraps>

80106b5e <vector136>:
.globl vector136
vector136:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $136
80106b60:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106b65:	e9 51 f4 ff ff       	jmp    80105fbb <alltraps>

80106b6a <vector137>:
.globl vector137
vector137:
  pushl $0
80106b6a:	6a 00                	push   $0x0
  pushl $137
80106b6c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106b71:	e9 45 f4 ff ff       	jmp    80105fbb <alltraps>

80106b76 <vector138>:
.globl vector138
vector138:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $138
80106b78:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b7d:	e9 39 f4 ff ff       	jmp    80105fbb <alltraps>

80106b82 <vector139>:
.globl vector139
vector139:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $139
80106b84:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106b89:	e9 2d f4 ff ff       	jmp    80105fbb <alltraps>

80106b8e <vector140>:
.globl vector140
vector140:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $140
80106b90:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106b95:	e9 21 f4 ff ff       	jmp    80105fbb <alltraps>

80106b9a <vector141>:
.globl vector141
vector141:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $141
80106b9c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ba1:	e9 15 f4 ff ff       	jmp    80105fbb <alltraps>

80106ba6 <vector142>:
.globl vector142
vector142:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $142
80106ba8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106bad:	e9 09 f4 ff ff       	jmp    80105fbb <alltraps>

80106bb2 <vector143>:
.globl vector143
vector143:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $143
80106bb4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106bb9:	e9 fd f3 ff ff       	jmp    80105fbb <alltraps>

80106bbe <vector144>:
.globl vector144
vector144:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $144
80106bc0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106bc5:	e9 f1 f3 ff ff       	jmp    80105fbb <alltraps>

80106bca <vector145>:
.globl vector145
vector145:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $145
80106bcc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106bd1:	e9 e5 f3 ff ff       	jmp    80105fbb <alltraps>

80106bd6 <vector146>:
.globl vector146
vector146:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $146
80106bd8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106bdd:	e9 d9 f3 ff ff       	jmp    80105fbb <alltraps>

80106be2 <vector147>:
.globl vector147
vector147:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $147
80106be4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106be9:	e9 cd f3 ff ff       	jmp    80105fbb <alltraps>

80106bee <vector148>:
.globl vector148
vector148:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $148
80106bf0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106bf5:	e9 c1 f3 ff ff       	jmp    80105fbb <alltraps>

80106bfa <vector149>:
.globl vector149
vector149:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $149
80106bfc:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106c01:	e9 b5 f3 ff ff       	jmp    80105fbb <alltraps>

80106c06 <vector150>:
.globl vector150
vector150:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $150
80106c08:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c0d:	e9 a9 f3 ff ff       	jmp    80105fbb <alltraps>

80106c12 <vector151>:
.globl vector151
vector151:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $151
80106c14:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c19:	e9 9d f3 ff ff       	jmp    80105fbb <alltraps>

80106c1e <vector152>:
.globl vector152
vector152:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $152
80106c20:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106c25:	e9 91 f3 ff ff       	jmp    80105fbb <alltraps>

80106c2a <vector153>:
.globl vector153
vector153:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $153
80106c2c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106c31:	e9 85 f3 ff ff       	jmp    80105fbb <alltraps>

80106c36 <vector154>:
.globl vector154
vector154:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $154
80106c38:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106c3d:	e9 79 f3 ff ff       	jmp    80105fbb <alltraps>

80106c42 <vector155>:
.globl vector155
vector155:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $155
80106c44:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106c49:	e9 6d f3 ff ff       	jmp    80105fbb <alltraps>

80106c4e <vector156>:
.globl vector156
vector156:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $156
80106c50:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106c55:	e9 61 f3 ff ff       	jmp    80105fbb <alltraps>

80106c5a <vector157>:
.globl vector157
vector157:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $157
80106c5c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106c61:	e9 55 f3 ff ff       	jmp    80105fbb <alltraps>

80106c66 <vector158>:
.globl vector158
vector158:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $158
80106c68:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106c6d:	e9 49 f3 ff ff       	jmp    80105fbb <alltraps>

80106c72 <vector159>:
.globl vector159
vector159:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $159
80106c74:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106c79:	e9 3d f3 ff ff       	jmp    80105fbb <alltraps>

80106c7e <vector160>:
.globl vector160
vector160:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $160
80106c80:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c85:	e9 31 f3 ff ff       	jmp    80105fbb <alltraps>

80106c8a <vector161>:
.globl vector161
vector161:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $161
80106c8c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106c91:	e9 25 f3 ff ff       	jmp    80105fbb <alltraps>

80106c96 <vector162>:
.globl vector162
vector162:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $162
80106c98:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106c9d:	e9 19 f3 ff ff       	jmp    80105fbb <alltraps>

80106ca2 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $163
80106ca4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ca9:	e9 0d f3 ff ff       	jmp    80105fbb <alltraps>

80106cae <vector164>:
.globl vector164
vector164:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $164
80106cb0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106cb5:	e9 01 f3 ff ff       	jmp    80105fbb <alltraps>

80106cba <vector165>:
.globl vector165
vector165:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $165
80106cbc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106cc1:	e9 f5 f2 ff ff       	jmp    80105fbb <alltraps>

80106cc6 <vector166>:
.globl vector166
vector166:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $166
80106cc8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ccd:	e9 e9 f2 ff ff       	jmp    80105fbb <alltraps>

80106cd2 <vector167>:
.globl vector167
vector167:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $167
80106cd4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106cd9:	e9 dd f2 ff ff       	jmp    80105fbb <alltraps>

80106cde <vector168>:
.globl vector168
vector168:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $168
80106ce0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ce5:	e9 d1 f2 ff ff       	jmp    80105fbb <alltraps>

80106cea <vector169>:
.globl vector169
vector169:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $169
80106cec:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106cf1:	e9 c5 f2 ff ff       	jmp    80105fbb <alltraps>

80106cf6 <vector170>:
.globl vector170
vector170:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $170
80106cf8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106cfd:	e9 b9 f2 ff ff       	jmp    80105fbb <alltraps>

80106d02 <vector171>:
.globl vector171
vector171:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $171
80106d04:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d09:	e9 ad f2 ff ff       	jmp    80105fbb <alltraps>

80106d0e <vector172>:
.globl vector172
vector172:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $172
80106d10:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d15:	e9 a1 f2 ff ff       	jmp    80105fbb <alltraps>

80106d1a <vector173>:
.globl vector173
vector173:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $173
80106d1c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106d21:	e9 95 f2 ff ff       	jmp    80105fbb <alltraps>

80106d26 <vector174>:
.globl vector174
vector174:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $174
80106d28:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106d2d:	e9 89 f2 ff ff       	jmp    80105fbb <alltraps>

80106d32 <vector175>:
.globl vector175
vector175:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $175
80106d34:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106d39:	e9 7d f2 ff ff       	jmp    80105fbb <alltraps>

80106d3e <vector176>:
.globl vector176
vector176:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $176
80106d40:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106d45:	e9 71 f2 ff ff       	jmp    80105fbb <alltraps>

80106d4a <vector177>:
.globl vector177
vector177:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $177
80106d4c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106d51:	e9 65 f2 ff ff       	jmp    80105fbb <alltraps>

80106d56 <vector178>:
.globl vector178
vector178:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $178
80106d58:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106d5d:	e9 59 f2 ff ff       	jmp    80105fbb <alltraps>

80106d62 <vector179>:
.globl vector179
vector179:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $179
80106d64:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106d69:	e9 4d f2 ff ff       	jmp    80105fbb <alltraps>

80106d6e <vector180>:
.globl vector180
vector180:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $180
80106d70:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106d75:	e9 41 f2 ff ff       	jmp    80105fbb <alltraps>

80106d7a <vector181>:
.globl vector181
vector181:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $181
80106d7c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d81:	e9 35 f2 ff ff       	jmp    80105fbb <alltraps>

80106d86 <vector182>:
.globl vector182
vector182:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $182
80106d88:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106d8d:	e9 29 f2 ff ff       	jmp    80105fbb <alltraps>

80106d92 <vector183>:
.globl vector183
vector183:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $183
80106d94:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106d99:	e9 1d f2 ff ff       	jmp    80105fbb <alltraps>

80106d9e <vector184>:
.globl vector184
vector184:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $184
80106da0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106da5:	e9 11 f2 ff ff       	jmp    80105fbb <alltraps>

80106daa <vector185>:
.globl vector185
vector185:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $185
80106dac:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106db1:	e9 05 f2 ff ff       	jmp    80105fbb <alltraps>

80106db6 <vector186>:
.globl vector186
vector186:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $186
80106db8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106dbd:	e9 f9 f1 ff ff       	jmp    80105fbb <alltraps>

80106dc2 <vector187>:
.globl vector187
vector187:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $187
80106dc4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106dc9:	e9 ed f1 ff ff       	jmp    80105fbb <alltraps>

80106dce <vector188>:
.globl vector188
vector188:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $188
80106dd0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106dd5:	e9 e1 f1 ff ff       	jmp    80105fbb <alltraps>

80106dda <vector189>:
.globl vector189
vector189:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $189
80106ddc:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106de1:	e9 d5 f1 ff ff       	jmp    80105fbb <alltraps>

80106de6 <vector190>:
.globl vector190
vector190:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $190
80106de8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ded:	e9 c9 f1 ff ff       	jmp    80105fbb <alltraps>

80106df2 <vector191>:
.globl vector191
vector191:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $191
80106df4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106df9:	e9 bd f1 ff ff       	jmp    80105fbb <alltraps>

80106dfe <vector192>:
.globl vector192
vector192:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $192
80106e00:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106e05:	e9 b1 f1 ff ff       	jmp    80105fbb <alltraps>

80106e0a <vector193>:
.globl vector193
vector193:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $193
80106e0c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e11:	e9 a5 f1 ff ff       	jmp    80105fbb <alltraps>

80106e16 <vector194>:
.globl vector194
vector194:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $194
80106e18:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e1d:	e9 99 f1 ff ff       	jmp    80105fbb <alltraps>

80106e22 <vector195>:
.globl vector195
vector195:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $195
80106e24:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106e29:	e9 8d f1 ff ff       	jmp    80105fbb <alltraps>

80106e2e <vector196>:
.globl vector196
vector196:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $196
80106e30:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106e35:	e9 81 f1 ff ff       	jmp    80105fbb <alltraps>

80106e3a <vector197>:
.globl vector197
vector197:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $197
80106e3c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106e41:	e9 75 f1 ff ff       	jmp    80105fbb <alltraps>

80106e46 <vector198>:
.globl vector198
vector198:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $198
80106e48:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106e4d:	e9 69 f1 ff ff       	jmp    80105fbb <alltraps>

80106e52 <vector199>:
.globl vector199
vector199:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $199
80106e54:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106e59:	e9 5d f1 ff ff       	jmp    80105fbb <alltraps>

80106e5e <vector200>:
.globl vector200
vector200:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $200
80106e60:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106e65:	e9 51 f1 ff ff       	jmp    80105fbb <alltraps>

80106e6a <vector201>:
.globl vector201
vector201:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $201
80106e6c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106e71:	e9 45 f1 ff ff       	jmp    80105fbb <alltraps>

80106e76 <vector202>:
.globl vector202
vector202:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $202
80106e78:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e7d:	e9 39 f1 ff ff       	jmp    80105fbb <alltraps>

80106e82 <vector203>:
.globl vector203
vector203:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $203
80106e84:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106e89:	e9 2d f1 ff ff       	jmp    80105fbb <alltraps>

80106e8e <vector204>:
.globl vector204
vector204:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $204
80106e90:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106e95:	e9 21 f1 ff ff       	jmp    80105fbb <alltraps>

80106e9a <vector205>:
.globl vector205
vector205:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $205
80106e9c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106ea1:	e9 15 f1 ff ff       	jmp    80105fbb <alltraps>

80106ea6 <vector206>:
.globl vector206
vector206:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $206
80106ea8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106ead:	e9 09 f1 ff ff       	jmp    80105fbb <alltraps>

80106eb2 <vector207>:
.globl vector207
vector207:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $207
80106eb4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106eb9:	e9 fd f0 ff ff       	jmp    80105fbb <alltraps>

80106ebe <vector208>:
.globl vector208
vector208:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $208
80106ec0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ec5:	e9 f1 f0 ff ff       	jmp    80105fbb <alltraps>

80106eca <vector209>:
.globl vector209
vector209:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $209
80106ecc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106ed1:	e9 e5 f0 ff ff       	jmp    80105fbb <alltraps>

80106ed6 <vector210>:
.globl vector210
vector210:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $210
80106ed8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106edd:	e9 d9 f0 ff ff       	jmp    80105fbb <alltraps>

80106ee2 <vector211>:
.globl vector211
vector211:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $211
80106ee4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106ee9:	e9 cd f0 ff ff       	jmp    80105fbb <alltraps>

80106eee <vector212>:
.globl vector212
vector212:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $212
80106ef0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106ef5:	e9 c1 f0 ff ff       	jmp    80105fbb <alltraps>

80106efa <vector213>:
.globl vector213
vector213:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $213
80106efc:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106f01:	e9 b5 f0 ff ff       	jmp    80105fbb <alltraps>

80106f06 <vector214>:
.globl vector214
vector214:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $214
80106f08:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f0d:	e9 a9 f0 ff ff       	jmp    80105fbb <alltraps>

80106f12 <vector215>:
.globl vector215
vector215:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $215
80106f14:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f19:	e9 9d f0 ff ff       	jmp    80105fbb <alltraps>

80106f1e <vector216>:
.globl vector216
vector216:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $216
80106f20:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106f25:	e9 91 f0 ff ff       	jmp    80105fbb <alltraps>

80106f2a <vector217>:
.globl vector217
vector217:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $217
80106f2c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106f31:	e9 85 f0 ff ff       	jmp    80105fbb <alltraps>

80106f36 <vector218>:
.globl vector218
vector218:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $218
80106f38:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106f3d:	e9 79 f0 ff ff       	jmp    80105fbb <alltraps>

80106f42 <vector219>:
.globl vector219
vector219:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $219
80106f44:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106f49:	e9 6d f0 ff ff       	jmp    80105fbb <alltraps>

80106f4e <vector220>:
.globl vector220
vector220:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $220
80106f50:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106f55:	e9 61 f0 ff ff       	jmp    80105fbb <alltraps>

80106f5a <vector221>:
.globl vector221
vector221:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $221
80106f5c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106f61:	e9 55 f0 ff ff       	jmp    80105fbb <alltraps>

80106f66 <vector222>:
.globl vector222
vector222:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $222
80106f68:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106f6d:	e9 49 f0 ff ff       	jmp    80105fbb <alltraps>

80106f72 <vector223>:
.globl vector223
vector223:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $223
80106f74:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106f79:	e9 3d f0 ff ff       	jmp    80105fbb <alltraps>

80106f7e <vector224>:
.globl vector224
vector224:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $224
80106f80:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f85:	e9 31 f0 ff ff       	jmp    80105fbb <alltraps>

80106f8a <vector225>:
.globl vector225
vector225:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $225
80106f8c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106f91:	e9 25 f0 ff ff       	jmp    80105fbb <alltraps>

80106f96 <vector226>:
.globl vector226
vector226:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $226
80106f98:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106f9d:	e9 19 f0 ff ff       	jmp    80105fbb <alltraps>

80106fa2 <vector227>:
.globl vector227
vector227:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $227
80106fa4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106fa9:	e9 0d f0 ff ff       	jmp    80105fbb <alltraps>

80106fae <vector228>:
.globl vector228
vector228:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $228
80106fb0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106fb5:	e9 01 f0 ff ff       	jmp    80105fbb <alltraps>

80106fba <vector229>:
.globl vector229
vector229:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $229
80106fbc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106fc1:	e9 f5 ef ff ff       	jmp    80105fbb <alltraps>

80106fc6 <vector230>:
.globl vector230
vector230:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $230
80106fc8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106fcd:	e9 e9 ef ff ff       	jmp    80105fbb <alltraps>

80106fd2 <vector231>:
.globl vector231
vector231:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $231
80106fd4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106fd9:	e9 dd ef ff ff       	jmp    80105fbb <alltraps>

80106fde <vector232>:
.globl vector232
vector232:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $232
80106fe0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106fe5:	e9 d1 ef ff ff       	jmp    80105fbb <alltraps>

80106fea <vector233>:
.globl vector233
vector233:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $233
80106fec:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106ff1:	e9 c5 ef ff ff       	jmp    80105fbb <alltraps>

80106ff6 <vector234>:
.globl vector234
vector234:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $234
80106ff8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106ffd:	e9 b9 ef ff ff       	jmp    80105fbb <alltraps>

80107002 <vector235>:
.globl vector235
vector235:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $235
80107004:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107009:	e9 ad ef ff ff       	jmp    80105fbb <alltraps>

8010700e <vector236>:
.globl vector236
vector236:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $236
80107010:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107015:	e9 a1 ef ff ff       	jmp    80105fbb <alltraps>

8010701a <vector237>:
.globl vector237
vector237:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $237
8010701c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107021:	e9 95 ef ff ff       	jmp    80105fbb <alltraps>

80107026 <vector238>:
.globl vector238
vector238:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $238
80107028:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010702d:	e9 89 ef ff ff       	jmp    80105fbb <alltraps>

80107032 <vector239>:
.globl vector239
vector239:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $239
80107034:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107039:	e9 7d ef ff ff       	jmp    80105fbb <alltraps>

8010703e <vector240>:
.globl vector240
vector240:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $240
80107040:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107045:	e9 71 ef ff ff       	jmp    80105fbb <alltraps>

8010704a <vector241>:
.globl vector241
vector241:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $241
8010704c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107051:	e9 65 ef ff ff       	jmp    80105fbb <alltraps>

80107056 <vector242>:
.globl vector242
vector242:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $242
80107058:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010705d:	e9 59 ef ff ff       	jmp    80105fbb <alltraps>

80107062 <vector243>:
.globl vector243
vector243:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $243
80107064:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107069:	e9 4d ef ff ff       	jmp    80105fbb <alltraps>

8010706e <vector244>:
.globl vector244
vector244:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $244
80107070:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107075:	e9 41 ef ff ff       	jmp    80105fbb <alltraps>

8010707a <vector245>:
.globl vector245
vector245:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $245
8010707c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107081:	e9 35 ef ff ff       	jmp    80105fbb <alltraps>

80107086 <vector246>:
.globl vector246
vector246:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $246
80107088:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010708d:	e9 29 ef ff ff       	jmp    80105fbb <alltraps>

80107092 <vector247>:
.globl vector247
vector247:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $247
80107094:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107099:	e9 1d ef ff ff       	jmp    80105fbb <alltraps>

8010709e <vector248>:
.globl vector248
vector248:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $248
801070a0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801070a5:	e9 11 ef ff ff       	jmp    80105fbb <alltraps>

801070aa <vector249>:
.globl vector249
vector249:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $249
801070ac:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801070b1:	e9 05 ef ff ff       	jmp    80105fbb <alltraps>

801070b6 <vector250>:
.globl vector250
vector250:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $250
801070b8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801070bd:	e9 f9 ee ff ff       	jmp    80105fbb <alltraps>

801070c2 <vector251>:
.globl vector251
vector251:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $251
801070c4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801070c9:	e9 ed ee ff ff       	jmp    80105fbb <alltraps>

801070ce <vector252>:
.globl vector252
vector252:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $252
801070d0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801070d5:	e9 e1 ee ff ff       	jmp    80105fbb <alltraps>

801070da <vector253>:
.globl vector253
vector253:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $253
801070dc:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801070e1:	e9 d5 ee ff ff       	jmp    80105fbb <alltraps>

801070e6 <vector254>:
.globl vector254
vector254:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $254
801070e8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801070ed:	e9 c9 ee ff ff       	jmp    80105fbb <alltraps>

801070f2 <vector255>:
.globl vector255
vector255:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $255
801070f4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801070f9:	e9 bd ee ff ff       	jmp    80105fbb <alltraps>

801070fe <lgdt>:
{
801070fe:	55                   	push   %ebp
801070ff:	89 e5                	mov    %esp,%ebp
80107101:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107104:	8b 45 0c             	mov    0xc(%ebp),%eax
80107107:	83 e8 01             	sub    $0x1,%eax
8010710a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010710e:	8b 45 08             	mov    0x8(%ebp),%eax
80107111:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107115:	8b 45 08             	mov    0x8(%ebp),%eax
80107118:	c1 e8 10             	shr    $0x10,%eax
8010711b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010711f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107122:	0f 01 10             	lgdtl  (%eax)
}
80107125:	90                   	nop
80107126:	c9                   	leave
80107127:	c3                   	ret

80107128 <ltr>:
{
80107128:	55                   	push   %ebp
80107129:	89 e5                	mov    %esp,%ebp
8010712b:	83 ec 04             	sub    $0x4,%esp
8010712e:	8b 45 08             	mov    0x8(%ebp),%eax
80107131:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107135:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107139:	0f 00 d8             	ltr    %eax
}
8010713c:	90                   	nop
8010713d:	c9                   	leave
8010713e:	c3                   	ret

8010713f <lcr3>:

static inline void
lcr3(uint val)
{
8010713f:	55                   	push   %ebp
80107140:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107142:	8b 45 08             	mov    0x8(%ebp),%eax
80107145:	0f 22 d8             	mov    %eax,%cr3
}
80107148:	90                   	nop
80107149:	5d                   	pop    %ebp
8010714a:	c3                   	ret

8010714b <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010714b:	f3 0f 1e fb          	endbr32
8010714f:	55                   	push   %ebp
80107150:	89 e5                	mov    %esp,%ebp
80107152:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107155:	e8 b4 c9 ff ff       	call   80103b0e <cpuid>
8010715a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107160:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80107165:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107174:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010717a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107184:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107188:	83 e2 f0             	and    $0xfffffff0,%edx
8010718b:	83 ca 0a             	or     $0xa,%edx
8010718e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107194:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107198:	83 ca 10             	or     $0x10,%edx
8010719b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010719e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801071a5:	83 e2 9f             	and    $0xffffff9f,%edx
801071a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801071ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ae:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801071b2:	83 ca 80             	or     $0xffffff80,%edx
801071b5:	88 50 7d             	mov    %dl,0x7d(%eax)
801071b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071bf:	83 ca 0f             	or     $0xf,%edx
801071c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801071c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071cc:	83 e2 ef             	and    $0xffffffef,%edx
801071cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801071d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071d9:	83 e2 df             	and    $0xffffffdf,%edx
801071dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801071df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071e6:	83 ca 40             	or     $0x40,%edx
801071e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801071ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801071f3:	83 ca 80             	or     $0xffffff80,%edx
801071f6:	88 50 7e             	mov    %dl,0x7e(%eax)
801071f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107203:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010720a:	ff ff 
8010720c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107216:	00 00 
80107218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010722c:	83 e2 f0             	and    $0xfffffff0,%edx
8010722f:	83 ca 02             	or     $0x2,%edx
80107232:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107242:	83 ca 10             	or     $0x10,%edx
80107245:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010724b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107255:	83 e2 9f             	and    $0xffffff9f,%edx
80107258:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010725e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107261:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107268:	83 ca 80             	or     $0xffffff80,%edx
8010726b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010727b:	83 ca 0f             	or     $0xf,%edx
8010727e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107287:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010728e:	83 e2 ef             	and    $0xffffffef,%edx
80107291:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072a1:	83 e2 df             	and    $0xffffffdf,%edx
801072a4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801072aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072b4:	83 ca 40             	or     $0x40,%edx
801072b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801072bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072c7:	83 ca 80             	or     $0xffffff80,%edx
801072ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801072d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801072da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072dd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801072e4:	ff ff 
801072e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801072f0:	00 00 
801072f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801072fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ff:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107306:	83 e2 f0             	and    $0xfffffff0,%edx
80107309:	83 ca 0a             	or     $0xa,%edx
8010730c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107315:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010731c:	83 ca 10             	or     $0x10,%edx
8010731f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107328:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010732f:	83 ca 60             	or     $0x60,%edx
80107332:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107342:	83 ca 80             	or     $0xffffff80,%edx
80107345:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107355:	83 ca 0f             	or     $0xf,%edx
80107358:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107368:	83 e2 ef             	and    $0xffffffef,%edx
8010736b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010737b:	83 e2 df             	and    $0xffffffdf,%edx
8010737e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107387:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010738e:	83 ca 40             	or     $0x40,%edx
80107391:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073a1:	83 ca 80             	or     $0xffffff80,%edx
801073a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801073aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ad:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801073b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801073be:	ff ff 
801073c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801073ca:	00 00 
801073cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cf:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801073d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073e0:	83 e2 f0             	and    $0xfffffff0,%edx
801073e3:	83 ca 02             	or     $0x2,%edx
801073e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073f6:	83 ca 10             	or     $0x10,%edx
801073f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107409:	83 ca 60             	or     $0x60,%edx
8010740c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107415:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010741c:	83 ca 80             	or     $0xffffff80,%edx
8010741f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010742f:	83 ca 0f             	or     $0xf,%edx
80107432:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107442:	83 e2 ef             	and    $0xffffffef,%edx
80107445:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010744b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107455:	83 e2 df             	and    $0xffffffdf,%edx
80107458:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010745e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107461:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107468:	83 ca 40             	or     $0x40,%edx
8010746b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107474:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010747b:	83 ca 80             	or     $0xffffff80,%edx
8010747e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107487:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	83 c0 70             	add    $0x70,%eax
80107494:	83 ec 08             	sub    $0x8,%esp
80107497:	6a 30                	push   $0x30
80107499:	50                   	push   %eax
8010749a:	e8 5f fc ff ff       	call   801070fe <lgdt>
8010749f:	83 c4 10             	add    $0x10,%esp
}
801074a2:	90                   	nop
801074a3:	c9                   	leave
801074a4:	c3                   	ret

801074a5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801074a5:	f3 0f 1e fb          	endbr32
801074a9:	55                   	push   %ebp
801074aa:	89 e5                	mov    %esp,%ebp
801074ac:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801074af:	8b 45 0c             	mov    0xc(%ebp),%eax
801074b2:	c1 e8 16             	shr    $0x16,%eax
801074b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801074bc:	8b 45 08             	mov    0x8(%ebp),%eax
801074bf:	01 d0                	add    %edx,%eax
801074c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801074c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074c7:	8b 00                	mov    (%eax),%eax
801074c9:	83 e0 01             	and    $0x1,%eax
801074cc:	85 c0                	test   %eax,%eax
801074ce:	74 14                	je     801074e4 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801074d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074d3:	8b 00                	mov    (%eax),%eax
801074d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074da:	05 00 00 00 80       	add    $0x80000000,%eax
801074df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801074e2:	eb 42                	jmp    80107526 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801074e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801074e8:	74 0e                	je     801074f8 <walkpgdir+0x53>
801074ea:	e8 a3 b3 ff ff       	call   80102892 <kalloc>
801074ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801074f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801074f6:	75 07                	jne    801074ff <walkpgdir+0x5a>
      return 0;
801074f8:	b8 00 00 00 00       	mov    $0x0,%eax
801074fd:	eb 3e                	jmp    8010753d <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801074ff:	83 ec 04             	sub    $0x4,%esp
80107502:	68 00 10 00 00       	push   $0x1000
80107507:	6a 00                	push   $0x0
80107509:	ff 75 f4             	push   -0xc(%ebp)
8010750c:	e8 65 d6 ff ff       	call   80104b76 <memset>
80107511:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107517:	05 00 00 00 80       	add    $0x80000000,%eax
8010751c:	83 c8 07             	or     $0x7,%eax
8010751f:	89 c2                	mov    %eax,%edx
80107521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107524:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107526:	8b 45 0c             	mov    0xc(%ebp),%eax
80107529:	c1 e8 0c             	shr    $0xc,%eax
8010752c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107531:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753b:	01 d0                	add    %edx,%eax
}
8010753d:	c9                   	leave
8010753e:	c3                   	ret

8010753f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010753f:	f3 0f 1e fb          	endbr32
80107543:	55                   	push   %ebp
80107544:	89 e5                	mov    %esp,%ebp
80107546:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010754c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107554:	8b 55 0c             	mov    0xc(%ebp),%edx
80107557:	8b 45 10             	mov    0x10(%ebp),%eax
8010755a:	01 d0                	add    %edx,%eax
8010755c:	83 e8 01             	sub    $0x1,%eax
8010755f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107564:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107567:	83 ec 04             	sub    $0x4,%esp
8010756a:	6a 01                	push   $0x1
8010756c:	ff 75 f4             	push   -0xc(%ebp)
8010756f:	ff 75 08             	push   0x8(%ebp)
80107572:	e8 2e ff ff ff       	call   801074a5 <walkpgdir>
80107577:	83 c4 10             	add    $0x10,%esp
8010757a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010757d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107581:	75 07                	jne    8010758a <mappages+0x4b>
      return -1;
80107583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107588:	eb 47                	jmp    801075d1 <mappages+0x92>
    if(*pte & PTE_P)
8010758a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010758d:	8b 00                	mov    (%eax),%eax
8010758f:	83 e0 01             	and    $0x1,%eax
80107592:	85 c0                	test   %eax,%eax
80107594:	74 0d                	je     801075a3 <mappages+0x64>
      panic("remap");
80107596:	83 ec 0c             	sub    $0xc,%esp
80107599:	68 90 a9 10 80       	push   $0x8010a990
8010759e:	e8 22 90 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
801075a3:	8b 45 18             	mov    0x18(%ebp),%eax
801075a6:	0b 45 14             	or     0x14(%ebp),%eax
801075a9:	83 c8 01             	or     $0x1,%eax
801075ac:	89 c2                	mov    %eax,%edx
801075ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801075b1:	89 10                	mov    %edx,(%eax)
    if(a == last)
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801075b9:	74 10                	je     801075cb <mappages+0x8c>
      break;
    a += PGSIZE;
801075bb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801075c2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801075c9:	eb 9c                	jmp    80107567 <mappages+0x28>
      break;
801075cb:	90                   	nop
  }
  return 0;
801075cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801075d1:	c9                   	leave
801075d2:	c3                   	ret

801075d3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801075d3:	f3 0f 1e fb          	endbr32
801075d7:	55                   	push   %ebp
801075d8:	89 e5                	mov    %esp,%ebp
801075da:	53                   	push   %ebx
801075db:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801075de:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801075e5:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801075ea:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801075ef:	29 c2                	sub    %eax,%edx
801075f1:	89 d0                	mov    %edx,%eax
801075f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801075f6:	a1 84 80 19 80       	mov    0x80198084,%eax
801075fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801075fe:	8b 15 84 80 19 80    	mov    0x80198084,%edx
80107604:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107609:	01 d0                	add    %edx,%eax
8010760b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010760e:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107618:	83 c0 30             	add    $0x30,%eax
8010761b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010761e:	89 10                	mov    %edx,(%eax)
80107620:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107623:	89 50 04             	mov    %edx,0x4(%eax)
80107626:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107629:	89 50 08             	mov    %edx,0x8(%eax)
8010762c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010762f:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107632:	e8 5b b2 ff ff       	call   80102892 <kalloc>
80107637:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010763a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010763e:	75 07                	jne    80107647 <setupkvm+0x74>
    return 0;
80107640:	b8 00 00 00 00       	mov    $0x0,%eax
80107645:	eb 78                	jmp    801076bf <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107647:	83 ec 04             	sub    $0x4,%esp
8010764a:	68 00 10 00 00       	push   $0x1000
8010764f:	6a 00                	push   $0x0
80107651:	ff 75 f0             	push   -0x10(%ebp)
80107654:	e8 1d d5 ff ff       	call   80104b76 <memset>
80107659:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010765c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107663:	eb 4e                	jmp    801076b3 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107668:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	8b 58 08             	mov    0x8(%eax),%ebx
80107677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767a:	8b 40 04             	mov    0x4(%eax),%eax
8010767d:	29 c3                	sub    %eax,%ebx
8010767f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107682:	8b 00                	mov    (%eax),%eax
80107684:	83 ec 0c             	sub    $0xc,%esp
80107687:	51                   	push   %ecx
80107688:	52                   	push   %edx
80107689:	53                   	push   %ebx
8010768a:	50                   	push   %eax
8010768b:	ff 75 f0             	push   -0x10(%ebp)
8010768e:	e8 ac fe ff ff       	call   8010753f <mappages>
80107693:	83 c4 20             	add    $0x20,%esp
80107696:	85 c0                	test   %eax,%eax
80107698:	79 15                	jns    801076af <setupkvm+0xdc>
      freevm(pgdir);
8010769a:	83 ec 0c             	sub    $0xc,%esp
8010769d:	ff 75 f0             	push   -0x10(%ebp)
801076a0:	e8 11 05 00 00       	call   80107bb6 <freevm>
801076a5:	83 c4 10             	add    $0x10,%esp
      return 0;
801076a8:	b8 00 00 00 00       	mov    $0x0,%eax
801076ad:	eb 10                	jmp    801076bf <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801076af:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801076b3:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801076ba:	72 a9                	jb     80107665 <setupkvm+0x92>
    }
  return pgdir;
801076bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801076bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801076c2:	c9                   	leave
801076c3:	c3                   	ret

801076c4 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801076c4:	f3 0f 1e fb          	endbr32
801076c8:	55                   	push   %ebp
801076c9:	89 e5                	mov    %esp,%ebp
801076cb:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801076ce:	e8 00 ff ff ff       	call   801075d3 <setupkvm>
801076d3:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
801076d8:	e8 03 00 00 00       	call   801076e0 <switchkvm>
}
801076dd:	90                   	nop
801076de:	c9                   	leave
801076df:	c3                   	ret

801076e0 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801076e0:	f3 0f 1e fb          	endbr32
801076e4:	55                   	push   %ebp
801076e5:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801076e7:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801076ec:	05 00 00 00 80       	add    $0x80000000,%eax
801076f1:	50                   	push   %eax
801076f2:	e8 48 fa ff ff       	call   8010713f <lcr3>
801076f7:	83 c4 04             	add    $0x4,%esp
}
801076fa:	90                   	nop
801076fb:	c9                   	leave
801076fc:	c3                   	ret

801076fd <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801076fd:	f3 0f 1e fb          	endbr32
80107701:	55                   	push   %ebp
80107702:	89 e5                	mov    %esp,%ebp
80107704:	56                   	push   %esi
80107705:	53                   	push   %ebx
80107706:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107709:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010770d:	75 0d                	jne    8010771c <switchuvm+0x1f>
    panic("switchuvm: no process");
8010770f:	83 ec 0c             	sub    $0xc,%esp
80107712:	68 96 a9 10 80       	push   $0x8010a996
80107717:	e8 a9 8e ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
8010771c:	8b 45 08             	mov    0x8(%ebp),%eax
8010771f:	8b 40 08             	mov    0x8(%eax),%eax
80107722:	85 c0                	test   %eax,%eax
80107724:	75 0d                	jne    80107733 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107726:	83 ec 0c             	sub    $0xc,%esp
80107729:	68 ac a9 10 80       	push   $0x8010a9ac
8010772e:	e8 92 8e ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107733:	8b 45 08             	mov    0x8(%ebp),%eax
80107736:	8b 40 04             	mov    0x4(%eax),%eax
80107739:	85 c0                	test   %eax,%eax
8010773b:	75 0d                	jne    8010774a <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010773d:	83 ec 0c             	sub    $0xc,%esp
80107740:	68 c1 a9 10 80       	push   $0x8010a9c1
80107745:	e8 7b 8e ff ff       	call   801005c5 <panic>

  pushcli();
8010774a:	e8 14 d3 ff ff       	call   80104a63 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010774f:	e8 d9 c3 ff ff       	call   80103b2d <mycpu>
80107754:	89 c3                	mov    %eax,%ebx
80107756:	e8 d2 c3 ff ff       	call   80103b2d <mycpu>
8010775b:	83 c0 08             	add    $0x8,%eax
8010775e:	89 c6                	mov    %eax,%esi
80107760:	e8 c8 c3 ff ff       	call   80103b2d <mycpu>
80107765:	83 c0 08             	add    $0x8,%eax
80107768:	c1 e8 10             	shr    $0x10,%eax
8010776b:	88 45 f7             	mov    %al,-0x9(%ebp)
8010776e:	e8 ba c3 ff ff       	call   80103b2d <mycpu>
80107773:	83 c0 08             	add    $0x8,%eax
80107776:	c1 e8 18             	shr    $0x18,%eax
80107779:	89 c2                	mov    %eax,%edx
8010777b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107782:	67 00 
80107784:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010778b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010778f:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107795:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010779c:	83 e0 f0             	and    $0xfffffff0,%eax
8010779f:	83 c8 09             	or     $0x9,%eax
801077a2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801077a8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801077af:	83 c8 10             	or     $0x10,%eax
801077b2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801077b8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801077bf:	83 e0 9f             	and    $0xffffff9f,%eax
801077c2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801077c8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801077cf:	83 c8 80             	or     $0xffffff80,%eax
801077d2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801077d8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077df:	83 e0 f0             	and    $0xfffffff0,%eax
801077e2:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077e8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077ef:	83 e0 ef             	and    $0xffffffef,%eax
801077f2:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801077f8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801077ff:	83 e0 df             	and    $0xffffffdf,%eax
80107802:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107808:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010780f:	83 c8 40             	or     $0x40,%eax
80107812:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107818:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010781f:	83 e0 7f             	and    $0x7f,%eax
80107822:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107828:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010782e:	e8 fa c2 ff ff       	call   80103b2d <mycpu>
80107833:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010783a:	83 e2 ef             	and    $0xffffffef,%edx
8010783d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107843:	e8 e5 c2 ff ff       	call   80103b2d <mycpu>
80107848:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010784e:	8b 45 08             	mov    0x8(%ebp),%eax
80107851:	8b 40 08             	mov    0x8(%eax),%eax
80107854:	89 c3                	mov    %eax,%ebx
80107856:	e8 d2 c2 ff ff       	call   80103b2d <mycpu>
8010785b:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107861:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107864:	e8 c4 c2 ff ff       	call   80103b2d <mycpu>
80107869:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010786f:	83 ec 0c             	sub    $0xc,%esp
80107872:	6a 28                	push   $0x28
80107874:	e8 af f8 ff ff       	call   80107128 <ltr>
80107879:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010787c:	8b 45 08             	mov    0x8(%ebp),%eax
8010787f:	8b 40 04             	mov    0x4(%eax),%eax
80107882:	05 00 00 00 80       	add    $0x80000000,%eax
80107887:	83 ec 0c             	sub    $0xc,%esp
8010788a:	50                   	push   %eax
8010788b:	e8 af f8 ff ff       	call   8010713f <lcr3>
80107890:	83 c4 10             	add    $0x10,%esp
  popcli();
80107893:	e8 1c d2 ff ff       	call   80104ab4 <popcli>
}
80107898:	90                   	nop
80107899:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010789c:	5b                   	pop    %ebx
8010789d:	5e                   	pop    %esi
8010789e:	5d                   	pop    %ebp
8010789f:	c3                   	ret

801078a0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801078a0:	f3 0f 1e fb          	endbr32
801078a4:	55                   	push   %ebp
801078a5:	89 e5                	mov    %esp,%ebp
801078a7:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801078aa:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801078b1:	76 0d                	jbe    801078c0 <inituvm+0x20>
    panic("inituvm: more than a page");
801078b3:	83 ec 0c             	sub    $0xc,%esp
801078b6:	68 d5 a9 10 80       	push   $0x8010a9d5
801078bb:	e8 05 8d ff ff       	call   801005c5 <panic>
  mem = kalloc();
801078c0:	e8 cd af ff ff       	call   80102892 <kalloc>
801078c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801078c8:	83 ec 04             	sub    $0x4,%esp
801078cb:	68 00 10 00 00       	push   $0x1000
801078d0:	6a 00                	push   $0x0
801078d2:	ff 75 f4             	push   -0xc(%ebp)
801078d5:	e8 9c d2 ff ff       	call   80104b76 <memset>
801078da:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	05 00 00 00 80       	add    $0x80000000,%eax
801078e5:	83 ec 0c             	sub    $0xc,%esp
801078e8:	6a 06                	push   $0x6
801078ea:	50                   	push   %eax
801078eb:	68 00 10 00 00       	push   $0x1000
801078f0:	6a 00                	push   $0x0
801078f2:	ff 75 08             	push   0x8(%ebp)
801078f5:	e8 45 fc ff ff       	call   8010753f <mappages>
801078fa:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801078fd:	83 ec 04             	sub    $0x4,%esp
80107900:	ff 75 10             	push   0x10(%ebp)
80107903:	ff 75 0c             	push   0xc(%ebp)
80107906:	ff 75 f4             	push   -0xc(%ebp)
80107909:	e8 2f d3 ff ff       	call   80104c3d <memmove>
8010790e:	83 c4 10             	add    $0x10,%esp
}
80107911:	90                   	nop
80107912:	c9                   	leave
80107913:	c3                   	ret

80107914 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107914:	f3 0f 1e fb          	endbr32
80107918:	55                   	push   %ebp
80107919:	89 e5                	mov    %esp,%ebp
8010791b:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010791e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107921:	25 ff 0f 00 00       	and    $0xfff,%eax
80107926:	85 c0                	test   %eax,%eax
80107928:	74 0d                	je     80107937 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
8010792a:	83 ec 0c             	sub    $0xc,%esp
8010792d:	68 f0 a9 10 80       	push   $0x8010a9f0
80107932:	e8 8e 8c ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107937:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010793e:	e9 8f 00 00 00       	jmp    801079d2 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107943:	8b 55 0c             	mov    0xc(%ebp),%edx
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	01 d0                	add    %edx,%eax
8010794b:	83 ec 04             	sub    $0x4,%esp
8010794e:	6a 00                	push   $0x0
80107950:	50                   	push   %eax
80107951:	ff 75 08             	push   0x8(%ebp)
80107954:	e8 4c fb ff ff       	call   801074a5 <walkpgdir>
80107959:	83 c4 10             	add    $0x10,%esp
8010795c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010795f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107963:	75 0d                	jne    80107972 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107965:	83 ec 0c             	sub    $0xc,%esp
80107968:	68 13 aa 10 80       	push   $0x8010aa13
8010796d:	e8 53 8c ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107972:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107975:	8b 00                	mov    (%eax),%eax
80107977:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010797c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010797f:	8b 45 18             	mov    0x18(%ebp),%eax
80107982:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107985:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010798a:	77 0b                	ja     80107997 <loaduvm+0x83>
      n = sz - i;
8010798c:	8b 45 18             	mov    0x18(%ebp),%eax
8010798f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107992:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107995:	eb 07                	jmp    8010799e <loaduvm+0x8a>
    else
      n = PGSIZE;
80107997:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010799e:	8b 55 14             	mov    0x14(%ebp),%edx
801079a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a4:	01 d0                	add    %edx,%eax
801079a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801079a9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801079af:	ff 75 f0             	push   -0x10(%ebp)
801079b2:	50                   	push   %eax
801079b3:	52                   	push   %edx
801079b4:	ff 75 10             	push   0x10(%ebp)
801079b7:	e8 c8 a5 ff ff       	call   80101f84 <readi>
801079bc:	83 c4 10             	add    $0x10,%esp
801079bf:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801079c2:	74 07                	je     801079cb <loaduvm+0xb7>
      return -1;
801079c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079c9:	eb 18                	jmp    801079e3 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801079cb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d5:	3b 45 18             	cmp    0x18(%ebp),%eax
801079d8:	0f 82 65 ff ff ff    	jb     80107943 <loaduvm+0x2f>
  }
  return 0;
801079de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079e3:	c9                   	leave
801079e4:	c3                   	ret

801079e5 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801079e5:	f3 0f 1e fb          	endbr32
801079e9:	55                   	push   %ebp
801079ea:	89 e5                	mov    %esp,%ebp
801079ec:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801079ef:	8b 45 10             	mov    0x10(%ebp),%eax
801079f2:	85 c0                	test   %eax,%eax
801079f4:	79 0a                	jns    80107a00 <allocuvm+0x1b>
    return 0;
801079f6:	b8 00 00 00 00       	mov    $0x0,%eax
801079fb:	e9 ec 00 00 00       	jmp    80107aec <allocuvm+0x107>
  if(newsz < oldsz)
80107a00:	8b 45 10             	mov    0x10(%ebp),%eax
80107a03:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a06:	73 08                	jae    80107a10 <allocuvm+0x2b>
    return oldsz;
80107a08:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a0b:	e9 dc 00 00 00       	jmp    80107aec <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107a10:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a13:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107a20:	e9 b8 00 00 00       	jmp    80107add <allocuvm+0xf8>
    mem = kalloc();
80107a25:	e8 68 ae ff ff       	call   80102892 <kalloc>
80107a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107a2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a31:	75 2e                	jne    80107a61 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107a33:	83 ec 0c             	sub    $0xc,%esp
80107a36:	68 31 aa 10 80       	push   $0x8010aa31
80107a3b:	e8 cc 89 ff ff       	call   8010040c <cprintf>
80107a40:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107a43:	83 ec 04             	sub    $0x4,%esp
80107a46:	ff 75 0c             	push   0xc(%ebp)
80107a49:	ff 75 10             	push   0x10(%ebp)
80107a4c:	ff 75 08             	push   0x8(%ebp)
80107a4f:	e8 9a 00 00 00       	call   80107aee <deallocuvm>
80107a54:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a57:	b8 00 00 00 00       	mov    $0x0,%eax
80107a5c:	e9 8b 00 00 00       	jmp    80107aec <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107a61:	83 ec 04             	sub    $0x4,%esp
80107a64:	68 00 10 00 00       	push   $0x1000
80107a69:	6a 00                	push   $0x0
80107a6b:	ff 75 f0             	push   -0x10(%ebp)
80107a6e:	e8 03 d1 ff ff       	call   80104b76 <memset>
80107a73:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a79:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a82:	83 ec 0c             	sub    $0xc,%esp
80107a85:	6a 06                	push   $0x6
80107a87:	52                   	push   %edx
80107a88:	68 00 10 00 00       	push   $0x1000
80107a8d:	50                   	push   %eax
80107a8e:	ff 75 08             	push   0x8(%ebp)
80107a91:	e8 a9 fa ff ff       	call   8010753f <mappages>
80107a96:	83 c4 20             	add    $0x20,%esp
80107a99:	85 c0                	test   %eax,%eax
80107a9b:	79 39                	jns    80107ad6 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107a9d:	83 ec 0c             	sub    $0xc,%esp
80107aa0:	68 49 aa 10 80       	push   $0x8010aa49
80107aa5:	e8 62 89 ff ff       	call   8010040c <cprintf>
80107aaa:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107aad:	83 ec 04             	sub    $0x4,%esp
80107ab0:	ff 75 0c             	push   0xc(%ebp)
80107ab3:	ff 75 10             	push   0x10(%ebp)
80107ab6:	ff 75 08             	push   0x8(%ebp)
80107ab9:	e8 30 00 00 00       	call   80107aee <deallocuvm>
80107abe:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ac1:	83 ec 0c             	sub    $0xc,%esp
80107ac4:	ff 75 f0             	push   -0x10(%ebp)
80107ac7:	e8 28 ad ff ff       	call   801027f4 <kfree>
80107acc:	83 c4 10             	add    $0x10,%esp
      return 0;
80107acf:	b8 00 00 00 00       	mov    $0x0,%eax
80107ad4:	eb 16                	jmp    80107aec <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107ad6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ae3:	0f 82 3c ff ff ff    	jb     80107a25 <allocuvm+0x40>
    }
  }
  return newsz;
80107ae9:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107aec:	c9                   	leave
80107aed:	c3                   	ret

80107aee <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107aee:	f3 0f 1e fb          	endbr32
80107af2:	55                   	push   %ebp
80107af3:	89 e5                	mov    %esp,%ebp
80107af5:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107af8:	8b 45 10             	mov    0x10(%ebp),%eax
80107afb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107afe:	72 08                	jb     80107b08 <deallocuvm+0x1a>
    return oldsz;
80107b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b03:	e9 ac 00 00 00       	jmp    80107bb4 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107b08:	8b 45 10             	mov    0x10(%ebp),%eax
80107b0b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107b18:	e9 88 00 00 00       	jmp    80107ba5 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b20:	83 ec 04             	sub    $0x4,%esp
80107b23:	6a 00                	push   $0x0
80107b25:	50                   	push   %eax
80107b26:	ff 75 08             	push   0x8(%ebp)
80107b29:	e8 77 f9 ff ff       	call   801074a5 <walkpgdir>
80107b2e:	83 c4 10             	add    $0x10,%esp
80107b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107b34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b38:	75 16                	jne    80107b50 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	c1 e8 16             	shr    $0x16,%eax
80107b40:	83 c0 01             	add    $0x1,%eax
80107b43:	c1 e0 16             	shl    $0x16,%eax
80107b46:	2d 00 10 00 00       	sub    $0x1000,%eax
80107b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b4e:	eb 4e                	jmp    80107b9e <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b53:	8b 00                	mov    (%eax),%eax
80107b55:	83 e0 01             	and    $0x1,%eax
80107b58:	85 c0                	test   %eax,%eax
80107b5a:	74 42                	je     80107b9e <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b5f:	8b 00                	mov    (%eax),%eax
80107b61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b66:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107b69:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b6d:	75 0d                	jne    80107b7c <deallocuvm+0x8e>
        panic("kfree");
80107b6f:	83 ec 0c             	sub    $0xc,%esp
80107b72:	68 65 aa 10 80       	push   $0x8010aa65
80107b77:	e8 49 8a ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b7f:	05 00 00 00 80       	add    $0x80000000,%eax
80107b84:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107b87:	83 ec 0c             	sub    $0xc,%esp
80107b8a:	ff 75 e8             	push   -0x18(%ebp)
80107b8d:	e8 62 ac ff ff       	call   801027f4 <kfree>
80107b92:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107b9e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bab:	0f 82 6c ff ff ff    	jb     80107b1d <deallocuvm+0x2f>
    }
  }
  return newsz;
80107bb1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107bb4:	c9                   	leave
80107bb5:	c3                   	ret

80107bb6 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107bb6:	f3 0f 1e fb          	endbr32
80107bba:	55                   	push   %ebp
80107bbb:	89 e5                	mov    %esp,%ebp
80107bbd:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107bc0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107bc4:	75 0d                	jne    80107bd3 <freevm+0x1d>
    panic("freevm: no pgdir");
80107bc6:	83 ec 0c             	sub    $0xc,%esp
80107bc9:	68 6b aa 10 80       	push   $0x8010aa6b
80107bce:	e8 f2 89 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107bd3:	83 ec 04             	sub    $0x4,%esp
80107bd6:	6a 00                	push   $0x0
80107bd8:	68 00 00 00 80       	push   $0x80000000
80107bdd:	ff 75 08             	push   0x8(%ebp)
80107be0:	e8 09 ff ff ff       	call   80107aee <deallocuvm>
80107be5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107be8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107bef:	eb 48                	jmp    80107c39 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bfe:	01 d0                	add    %edx,%eax
80107c00:	8b 00                	mov    (%eax),%eax
80107c02:	83 e0 01             	and    $0x1,%eax
80107c05:	85 c0                	test   %eax,%eax
80107c07:	74 2c                	je     80107c35 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c13:	8b 45 08             	mov    0x8(%ebp),%eax
80107c16:	01 d0                	add    %edx,%eax
80107c18:	8b 00                	mov    (%eax),%eax
80107c1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c1f:	05 00 00 00 80       	add    $0x80000000,%eax
80107c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107c27:	83 ec 0c             	sub    $0xc,%esp
80107c2a:	ff 75 f0             	push   -0x10(%ebp)
80107c2d:	e8 c2 ab ff ff       	call   801027f4 <kfree>
80107c32:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c39:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107c40:	76 af                	jbe    80107bf1 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107c42:	83 ec 0c             	sub    $0xc,%esp
80107c45:	ff 75 08             	push   0x8(%ebp)
80107c48:	e8 a7 ab ff ff       	call   801027f4 <kfree>
80107c4d:	83 c4 10             	add    $0x10,%esp
}
80107c50:	90                   	nop
80107c51:	c9                   	leave
80107c52:	c3                   	ret

80107c53 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107c53:	f3 0f 1e fb          	endbr32
80107c57:	55                   	push   %ebp
80107c58:	89 e5                	mov    %esp,%ebp
80107c5a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107c5d:	83 ec 04             	sub    $0x4,%esp
80107c60:	6a 00                	push   $0x0
80107c62:	ff 75 0c             	push   0xc(%ebp)
80107c65:	ff 75 08             	push   0x8(%ebp)
80107c68:	e8 38 f8 ff ff       	call   801074a5 <walkpgdir>
80107c6d:	83 c4 10             	add    $0x10,%esp
80107c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107c73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c77:	75 0d                	jne    80107c86 <clearpteu+0x33>
    panic("clearpteu");
80107c79:	83 ec 0c             	sub    $0xc,%esp
80107c7c:	68 7c aa 10 80       	push   $0x8010aa7c
80107c81:	e8 3f 89 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	8b 00                	mov    (%eax),%eax
80107c8b:	83 e0 fb             	and    $0xfffffffb,%eax
80107c8e:	89 c2                	mov    %eax,%edx
80107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c93:	89 10                	mov    %edx,(%eax)
}
80107c95:	90                   	nop
80107c96:	c9                   	leave
80107c97:	c3                   	ret

80107c98 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107c98:	f3 0f 1e fb          	endbr32
80107c9c:	55                   	push   %ebp
80107c9d:	89 e5                	mov    %esp,%ebp
80107c9f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ca2:	e8 2c f9 ff ff       	call   801075d3 <setupkvm>
80107ca7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107caa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cae:	75 0a                	jne    80107cba <copyuvm+0x22>
    return 0;
80107cb0:	b8 00 00 00 00       	mov    $0x0,%eax
80107cb5:	e9 eb 00 00 00       	jmp    80107da5 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cc1:	e9 b7 00 00 00       	jmp    80107d7d <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	83 ec 04             	sub    $0x4,%esp
80107ccc:	6a 00                	push   $0x0
80107cce:	50                   	push   %eax
80107ccf:	ff 75 08             	push   0x8(%ebp)
80107cd2:	e8 ce f7 ff ff       	call   801074a5 <walkpgdir>
80107cd7:	83 c4 10             	add    $0x10,%esp
80107cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cdd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ce1:	75 0d                	jne    80107cf0 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107ce3:	83 ec 0c             	sub    $0xc,%esp
80107ce6:	68 86 aa 10 80       	push   $0x8010aa86
80107ceb:	e8 d5 88 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cf3:	8b 00                	mov    (%eax),%eax
80107cf5:	83 e0 01             	and    $0x1,%eax
80107cf8:	85 c0                	test   %eax,%eax
80107cfa:	75 0d                	jne    80107d09 <copyuvm+0x71>
      panic("copyuvm: page not present");
80107cfc:	83 ec 0c             	sub    $0xc,%esp
80107cff:	68 a0 aa 10 80       	push   $0x8010aaa0
80107d04:	e8 bc 88 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d0c:	8b 00                	mov    (%eax),%eax
80107d0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d13:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107d16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d19:	8b 00                	mov    (%eax),%eax
80107d1b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107d23:	e8 6a ab ff ff       	call   80102892 <kalloc>
80107d28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107d2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107d2f:	74 5d                	je     80107d8e <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d34:	05 00 00 00 80       	add    $0x80000000,%eax
80107d39:	83 ec 04             	sub    $0x4,%esp
80107d3c:	68 00 10 00 00       	push   $0x1000
80107d41:	50                   	push   %eax
80107d42:	ff 75 e0             	push   -0x20(%ebp)
80107d45:	e8 f3 ce ff ff       	call   80104c3d <memmove>
80107d4a:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107d4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107d50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d53:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	83 ec 0c             	sub    $0xc,%esp
80107d5f:	52                   	push   %edx
80107d60:	51                   	push   %ecx
80107d61:	68 00 10 00 00       	push   $0x1000
80107d66:	50                   	push   %eax
80107d67:	ff 75 f0             	push   -0x10(%ebp)
80107d6a:	e8 d0 f7 ff ff       	call   8010753f <mappages>
80107d6f:	83 c4 20             	add    $0x20,%esp
80107d72:	85 c0                	test   %eax,%eax
80107d74:	78 1b                	js     80107d91 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107d76:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d83:	0f 82 3d ff ff ff    	jb     80107cc6 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8c:	eb 17                	jmp    80107da5 <copyuvm+0x10d>
      goto bad;
80107d8e:	90                   	nop
80107d8f:	eb 01                	jmp    80107d92 <copyuvm+0xfa>
      goto bad;
80107d91:	90                   	nop

bad:
  freevm(d);
80107d92:	83 ec 0c             	sub    $0xc,%esp
80107d95:	ff 75 f0             	push   -0x10(%ebp)
80107d98:	e8 19 fe ff ff       	call   80107bb6 <freevm>
80107d9d:	83 c4 10             	add    $0x10,%esp
  return 0;
80107da0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107da5:	c9                   	leave
80107da6:	c3                   	ret

80107da7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107da7:	f3 0f 1e fb          	endbr32
80107dab:	55                   	push   %ebp
80107dac:	89 e5                	mov    %esp,%ebp
80107dae:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107db1:	83 ec 04             	sub    $0x4,%esp
80107db4:	6a 00                	push   $0x0
80107db6:	ff 75 0c             	push   0xc(%ebp)
80107db9:	ff 75 08             	push   0x8(%ebp)
80107dbc:	e8 e4 f6 ff ff       	call   801074a5 <walkpgdir>
80107dc1:	83 c4 10             	add    $0x10,%esp
80107dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dca:	8b 00                	mov    (%eax),%eax
80107dcc:	83 e0 01             	and    $0x1,%eax
80107dcf:	85 c0                	test   %eax,%eax
80107dd1:	75 07                	jne    80107dda <uva2ka+0x33>
    return 0;
80107dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd8:	eb 22                	jmp    80107dfc <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	8b 00                	mov    (%eax),%eax
80107ddf:	83 e0 04             	and    $0x4,%eax
80107de2:	85 c0                	test   %eax,%eax
80107de4:	75 07                	jne    80107ded <uva2ka+0x46>
    return 0;
80107de6:	b8 00 00 00 00       	mov    $0x0,%eax
80107deb:	eb 0f                	jmp    80107dfc <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df0:	8b 00                	mov    (%eax),%eax
80107df2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df7:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107dfc:	c9                   	leave
80107dfd:	c3                   	ret

80107dfe <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107dfe:	f3 0f 1e fb          	endbr32
80107e02:	55                   	push   %ebp
80107e03:	89 e5                	mov    %esp,%ebp
80107e05:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107e08:	8b 45 10             	mov    0x10(%ebp),%eax
80107e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107e0e:	eb 7f                	jmp    80107e8f <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e18:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e1e:	83 ec 08             	sub    $0x8,%esp
80107e21:	50                   	push   %eax
80107e22:	ff 75 08             	push   0x8(%ebp)
80107e25:	e8 7d ff ff ff       	call   80107da7 <uva2ka>
80107e2a:	83 c4 10             	add    $0x10,%esp
80107e2d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107e30:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107e34:	75 07                	jne    80107e3d <copyout+0x3f>
      return -1;
80107e36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e3b:	eb 61                	jmp    80107e9e <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107e3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e40:	2b 45 0c             	sub    0xc(%ebp),%eax
80107e43:	05 00 10 00 00       	add    $0x1000,%eax
80107e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4e:	3b 45 14             	cmp    0x14(%ebp),%eax
80107e51:	76 06                	jbe    80107e59 <copyout+0x5b>
      n = len;
80107e53:	8b 45 14             	mov    0x14(%ebp),%eax
80107e56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e5c:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107e5f:	89 c2                	mov    %eax,%edx
80107e61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e64:	01 d0                	add    %edx,%eax
80107e66:	83 ec 04             	sub    $0x4,%esp
80107e69:	ff 75 f0             	push   -0x10(%ebp)
80107e6c:	ff 75 f4             	push   -0xc(%ebp)
80107e6f:	50                   	push   %eax
80107e70:	e8 c8 cd ff ff       	call   80104c3d <memmove>
80107e75:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e7b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e81:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107e84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e87:	05 00 10 00 00       	add    $0x1000,%eax
80107e8c:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107e8f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107e93:	0f 85 77 ff ff ff    	jne    80107e10 <copyout+0x12>
  }
  return 0;
80107e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e9e:	c9                   	leave
80107e9f:	c3                   	ret

80107ea0 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107ea0:	f3 0f 1e fb          	endbr32
80107ea4:	55                   	push   %ebp
80107ea5:	89 e5                	mov    %esp,%ebp
80107ea7:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107eaa:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107eb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107eb4:	8b 40 08             	mov    0x8(%eax),%eax
80107eb7:	05 00 00 00 80       	add    $0x80000000,%eax
80107ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107ebf:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec9:	8b 40 24             	mov    0x24(%eax),%eax
80107ecc:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80107ed1:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80107ed8:	00 00 00 

  while(i<madt->len){
80107edb:	90                   	nop
80107edc:	e9 be 00 00 00       	jmp    80107f9f <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80107ee1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ee7:	01 d0                	add    %edx,%eax
80107ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eef:	0f b6 00             	movzbl (%eax),%eax
80107ef2:	0f b6 c0             	movzbl %al,%eax
80107ef5:	83 f8 05             	cmp    $0x5,%eax
80107ef8:	0f 87 a1 00 00 00    	ja     80107f9f <mpinit_uefi+0xff>
80107efe:	8b 04 85 bc aa 10 80 	mov    -0x7fef5544(,%eax,4),%eax
80107f05:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107f0e:	a1 80 80 19 80       	mov    0x80198080,%eax
80107f13:	83 f8 03             	cmp    $0x3,%eax
80107f16:	7f 28                	jg     80107f40 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107f18:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80107f1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f21:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107f25:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107f2b:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80107f31:	88 02                	mov    %al,(%edx)
          ncpu++;
80107f33:	a1 80 80 19 80       	mov    0x80198080,%eax
80107f38:	83 c0 01             	add    $0x1,%eax
80107f3b:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80107f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f43:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f47:	0f b6 c0             	movzbl %al,%eax
80107f4a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f4d:	eb 50                	jmp    80107f9f <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f58:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107f5c:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80107f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f64:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f68:	0f b6 c0             	movzbl %al,%eax
80107f6b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f6e:	eb 2f                	jmp    80107f9f <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f73:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107f76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f79:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f7d:	0f b6 c0             	movzbl %al,%eax
80107f80:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f83:	eb 1a                	jmp    80107f9f <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f88:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107f8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f8e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f92:	0f b6 c0             	movzbl %al,%eax
80107f95:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107f98:	eb 05                	jmp    80107f9f <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80107f9a:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107f9e:	90                   	nop
  while(i<madt->len){
80107f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa2:	8b 40 04             	mov    0x4(%eax),%eax
80107fa5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107fa8:	0f 82 33 ff ff ff    	jb     80107ee1 <mpinit_uefi+0x41>
    }
  }

}
80107fae:	90                   	nop
80107faf:	90                   	nop
80107fb0:	c9                   	leave
80107fb1:	c3                   	ret

80107fb2 <inb>:
{
80107fb2:	55                   	push   %ebp
80107fb3:	89 e5                	mov    %esp,%ebp
80107fb5:	83 ec 14             	sub    $0x14,%esp
80107fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80107fbb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107fbf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107fc3:	89 c2                	mov    %eax,%edx
80107fc5:	ec                   	in     (%dx),%al
80107fc6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107fc9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107fcd:	c9                   	leave
80107fce:	c3                   	ret

80107fcf <outb>:
{
80107fcf:	55                   	push   %ebp
80107fd0:	89 e5                	mov    %esp,%ebp
80107fd2:	83 ec 08             	sub    $0x8,%esp
80107fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fdb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107fdf:	89 d0                	mov    %edx,%eax
80107fe1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107fe4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107fe8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107fec:	ee                   	out    %al,(%dx)
}
80107fed:	90                   	nop
80107fee:	c9                   	leave
80107fef:	c3                   	ret

80107ff0 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107ff0:	f3 0f 1e fb          	endbr32
80107ff4:	55                   	push   %ebp
80107ff5:	89 e5                	mov    %esp,%ebp
80107ff7:	83 ec 28             	sub    $0x28,%esp
80107ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffd:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108000:	6a 00                	push   $0x0
80108002:	68 fa 03 00 00       	push   $0x3fa
80108007:	e8 c3 ff ff ff       	call   80107fcf <outb>
8010800c:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010800f:	68 80 00 00 00       	push   $0x80
80108014:	68 fb 03 00 00       	push   $0x3fb
80108019:	e8 b1 ff ff ff       	call   80107fcf <outb>
8010801e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108021:	6a 0c                	push   $0xc
80108023:	68 f8 03 00 00       	push   $0x3f8
80108028:	e8 a2 ff ff ff       	call   80107fcf <outb>
8010802d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108030:	6a 00                	push   $0x0
80108032:	68 f9 03 00 00       	push   $0x3f9
80108037:	e8 93 ff ff ff       	call   80107fcf <outb>
8010803c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010803f:	6a 03                	push   $0x3
80108041:	68 fb 03 00 00       	push   $0x3fb
80108046:	e8 84 ff ff ff       	call   80107fcf <outb>
8010804b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010804e:	6a 00                	push   $0x0
80108050:	68 fc 03 00 00       	push   $0x3fc
80108055:	e8 75 ff ff ff       	call   80107fcf <outb>
8010805a:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010805d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108064:	eb 11                	jmp    80108077 <uart_debug+0x87>
80108066:	83 ec 0c             	sub    $0xc,%esp
80108069:	6a 0a                	push   $0xa
8010806b:	e8 d4 ab ff ff       	call   80102c44 <microdelay>
80108070:	83 c4 10             	add    $0x10,%esp
80108073:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108077:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010807b:	7f 1a                	jg     80108097 <uart_debug+0xa7>
8010807d:	83 ec 0c             	sub    $0xc,%esp
80108080:	68 fd 03 00 00       	push   $0x3fd
80108085:	e8 28 ff ff ff       	call   80107fb2 <inb>
8010808a:	83 c4 10             	add    $0x10,%esp
8010808d:	0f b6 c0             	movzbl %al,%eax
80108090:	83 e0 20             	and    $0x20,%eax
80108093:	85 c0                	test   %eax,%eax
80108095:	74 cf                	je     80108066 <uart_debug+0x76>
  outb(COM1+0, p);
80108097:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010809b:	0f b6 c0             	movzbl %al,%eax
8010809e:	83 ec 08             	sub    $0x8,%esp
801080a1:	50                   	push   %eax
801080a2:	68 f8 03 00 00       	push   $0x3f8
801080a7:	e8 23 ff ff ff       	call   80107fcf <outb>
801080ac:	83 c4 10             	add    $0x10,%esp
}
801080af:	90                   	nop
801080b0:	c9                   	leave
801080b1:	c3                   	ret

801080b2 <uart_debugs>:

void uart_debugs(char *p){
801080b2:	f3 0f 1e fb          	endbr32
801080b6:	55                   	push   %ebp
801080b7:	89 e5                	mov    %esp,%ebp
801080b9:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801080bc:	eb 1b                	jmp    801080d9 <uart_debugs+0x27>
    uart_debug(*p++);
801080be:	8b 45 08             	mov    0x8(%ebp),%eax
801080c1:	8d 50 01             	lea    0x1(%eax),%edx
801080c4:	89 55 08             	mov    %edx,0x8(%ebp)
801080c7:	0f b6 00             	movzbl (%eax),%eax
801080ca:	0f be c0             	movsbl %al,%eax
801080cd:	83 ec 0c             	sub    $0xc,%esp
801080d0:	50                   	push   %eax
801080d1:	e8 1a ff ff ff       	call   80107ff0 <uart_debug>
801080d6:	83 c4 10             	add    $0x10,%esp
  while(*p){
801080d9:	8b 45 08             	mov    0x8(%ebp),%eax
801080dc:	0f b6 00             	movzbl (%eax),%eax
801080df:	84 c0                	test   %al,%al
801080e1:	75 db                	jne    801080be <uart_debugs+0xc>
  }
}
801080e3:	90                   	nop
801080e4:	90                   	nop
801080e5:	c9                   	leave
801080e6:	c3                   	ret

801080e7 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801080e7:	f3 0f 1e fb          	endbr32
801080eb:	55                   	push   %ebp
801080ec:	89 e5                	mov    %esp,%ebp
801080ee:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080f1:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801080f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080fb:	8b 50 14             	mov    0x14(%eax),%edx
801080fe:	8b 40 10             	mov    0x10(%eax),%eax
80108101:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108106:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108109:	8b 50 1c             	mov    0x1c(%eax),%edx
8010810c:	8b 40 18             	mov    0x18(%eax),%eax
8010810f:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108114:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80108119:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010811e:	29 c2                	sub    %eax,%edx
80108120:	89 d0                	mov    %edx,%eax
80108122:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108127:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010812a:	8b 50 24             	mov    0x24(%eax),%edx
8010812d:	8b 40 20             	mov    0x20(%eax),%eax
80108130:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108135:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108138:	8b 50 2c             	mov    0x2c(%eax),%edx
8010813b:	8b 40 28             	mov    0x28(%eax),%eax
8010813e:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108143:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108146:	8b 50 34             	mov    0x34(%eax),%edx
80108149:	8b 40 30             	mov    0x30(%eax),%eax
8010814c:	a3 98 80 19 80       	mov    %eax,0x80198098
}
80108151:	90                   	nop
80108152:	c9                   	leave
80108153:	c3                   	ret

80108154 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108154:	f3 0f 1e fb          	endbr32
80108158:	55                   	push   %ebp
80108159:	89 e5                	mov    %esp,%ebp
8010815b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010815e:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108164:	8b 45 0c             	mov    0xc(%ebp),%eax
80108167:	0f af d0             	imul   %eax,%edx
8010816a:	8b 45 08             	mov    0x8(%ebp),%eax
8010816d:	01 d0                	add    %edx,%eax
8010816f:	c1 e0 02             	shl    $0x2,%eax
80108172:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108175:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010817b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010817e:	01 d0                	add    %edx,%eax
80108180:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108183:	8b 45 10             	mov    0x10(%ebp),%eax
80108186:	0f b6 10             	movzbl (%eax),%edx
80108189:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010818c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010818e:	8b 45 10             	mov    0x10(%ebp),%eax
80108191:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108195:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108198:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010819b:	8b 45 10             	mov    0x10(%ebp),%eax
8010819e:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801081a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081a5:	88 50 02             	mov    %dl,0x2(%eax)
}
801081a8:	90                   	nop
801081a9:	c9                   	leave
801081aa:	c3                   	ret

801081ab <graphic_scroll_up>:

void graphic_scroll_up(int height){
801081ab:	f3 0f 1e fb          	endbr32
801081af:	55                   	push   %ebp
801081b0:	89 e5                	mov    %esp,%ebp
801081b2:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801081b5:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801081bb:	8b 45 08             	mov    0x8(%ebp),%eax
801081be:	0f af c2             	imul   %edx,%eax
801081c1:	c1 e0 02             	shl    $0x2,%eax
801081c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801081c7:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
801081cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d0:	29 c2                	sub    %eax,%edx
801081d2:	89 d0                	mov    %edx,%eax
801081d4:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
801081da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081dd:	01 ca                	add    %ecx,%edx
801081df:	89 d1                	mov    %edx,%ecx
801081e1:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801081e7:	83 ec 04             	sub    $0x4,%esp
801081ea:	50                   	push   %eax
801081eb:	51                   	push   %ecx
801081ec:	52                   	push   %edx
801081ed:	e8 4b ca ff ff       	call   80104c3d <memmove>
801081f2:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801081f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f8:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
801081fe:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108204:	01 d1                	add    %edx,%ecx
80108206:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108209:	29 d1                	sub    %edx,%ecx
8010820b:	89 ca                	mov    %ecx,%edx
8010820d:	83 ec 04             	sub    $0x4,%esp
80108210:	50                   	push   %eax
80108211:	6a 00                	push   $0x0
80108213:	52                   	push   %edx
80108214:	e8 5d c9 ff ff       	call   80104b76 <memset>
80108219:	83 c4 10             	add    $0x10,%esp
}
8010821c:	90                   	nop
8010821d:	c9                   	leave
8010821e:	c3                   	ret

8010821f <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010821f:	f3 0f 1e fb          	endbr32
80108223:	55                   	push   %ebp
80108224:	89 e5                	mov    %esp,%ebp
80108226:	53                   	push   %ebx
80108227:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010822a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108231:	e9 b1 00 00 00       	jmp    801082e7 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108236:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010823d:	e9 97 00 00 00       	jmp    801082d9 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108242:	8b 45 10             	mov    0x10(%ebp),%eax
80108245:	83 e8 20             	sub    $0x20,%eax
80108248:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010824b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824e:	01 d0                	add    %edx,%eax
80108250:	0f b7 84 00 e0 aa 10 	movzwl -0x7fef5520(%eax,%eax,1),%eax
80108257:	80 
80108258:	0f b7 d0             	movzwl %ax,%edx
8010825b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825e:	bb 01 00 00 00       	mov    $0x1,%ebx
80108263:	89 c1                	mov    %eax,%ecx
80108265:	d3 e3                	shl    %cl,%ebx
80108267:	89 d8                	mov    %ebx,%eax
80108269:	21 d0                	and    %edx,%eax
8010826b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010826e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108271:	ba 01 00 00 00       	mov    $0x1,%edx
80108276:	89 c1                	mov    %eax,%ecx
80108278:	d3 e2                	shl    %cl,%edx
8010827a:	89 d0                	mov    %edx,%eax
8010827c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010827f:	75 2b                	jne    801082ac <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108281:	8b 55 0c             	mov    0xc(%ebp),%edx
80108284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108287:	01 c2                	add    %eax,%edx
80108289:	b8 0e 00 00 00       	mov    $0xe,%eax
8010828e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108291:	89 c1                	mov    %eax,%ecx
80108293:	8b 45 08             	mov    0x8(%ebp),%eax
80108296:	01 c8                	add    %ecx,%eax
80108298:	83 ec 04             	sub    $0x4,%esp
8010829b:	68 e0 f4 10 80       	push   $0x8010f4e0
801082a0:	52                   	push   %edx
801082a1:	50                   	push   %eax
801082a2:	e8 ad fe ff ff       	call   80108154 <graphic_draw_pixel>
801082a7:	83 c4 10             	add    $0x10,%esp
801082aa:	eb 29                	jmp    801082d5 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801082ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801082af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b2:	01 c2                	add    %eax,%edx
801082b4:	b8 0e 00 00 00       	mov    $0xe,%eax
801082b9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801082bc:	89 c1                	mov    %eax,%ecx
801082be:	8b 45 08             	mov    0x8(%ebp),%eax
801082c1:	01 c8                	add    %ecx,%eax
801082c3:	83 ec 04             	sub    $0x4,%esp
801082c6:	68 64 d0 18 80       	push   $0x8018d064
801082cb:	52                   	push   %edx
801082cc:	50                   	push   %eax
801082cd:	e8 82 fe ff ff       	call   80108154 <graphic_draw_pixel>
801082d2:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801082d5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801082d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082dd:	0f 89 5f ff ff ff    	jns    80108242 <font_render+0x23>
  for(int i=0;i<30;i++){
801082e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082e7:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801082eb:	0f 8e 45 ff ff ff    	jle    80108236 <font_render+0x17>
      }
    }
  }
}
801082f1:	90                   	nop
801082f2:	90                   	nop
801082f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082f6:	c9                   	leave
801082f7:	c3                   	ret

801082f8 <font_render_string>:

void font_render_string(char *string,int row){
801082f8:	f3 0f 1e fb          	endbr32
801082fc:	55                   	push   %ebp
801082fd:	89 e5                	mov    %esp,%ebp
801082ff:	53                   	push   %ebx
80108300:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108303:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010830a:	eb 33                	jmp    8010833f <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010830c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010830f:	8b 45 08             	mov    0x8(%ebp),%eax
80108312:	01 d0                	add    %edx,%eax
80108314:	0f b6 00             	movzbl (%eax),%eax
80108317:	0f be d8             	movsbl %al,%ebx
8010831a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831d:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108320:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108323:	89 d0                	mov    %edx,%eax
80108325:	c1 e0 04             	shl    $0x4,%eax
80108328:	29 d0                	sub    %edx,%eax
8010832a:	83 c0 02             	add    $0x2,%eax
8010832d:	83 ec 04             	sub    $0x4,%esp
80108330:	53                   	push   %ebx
80108331:	51                   	push   %ecx
80108332:	50                   	push   %eax
80108333:	e8 e7 fe ff ff       	call   8010821f <font_render>
80108338:	83 c4 10             	add    $0x10,%esp
    i++;
8010833b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010833f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108342:	8b 45 08             	mov    0x8(%ebp),%eax
80108345:	01 d0                	add    %edx,%eax
80108347:	0f b6 00             	movzbl (%eax),%eax
8010834a:	84 c0                	test   %al,%al
8010834c:	74 06                	je     80108354 <font_render_string+0x5c>
8010834e:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108352:	7e b8                	jle    8010830c <font_render_string+0x14>
  }
}
80108354:	90                   	nop
80108355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108358:	c9                   	leave
80108359:	c3                   	ret

8010835a <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010835a:	f3 0f 1e fb          	endbr32
8010835e:	55                   	push   %ebp
8010835f:	89 e5                	mov    %esp,%ebp
80108361:	53                   	push   %ebx
80108362:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108365:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010836c:	eb 6b                	jmp    801083d9 <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010836e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108375:	eb 58                	jmp    801083cf <pci_init+0x75>
      for(int k=0;k<8;k++){
80108377:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010837e:	eb 45                	jmp    801083c5 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108380:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108383:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	83 ec 0c             	sub    $0xc,%esp
8010838c:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010838f:	53                   	push   %ebx
80108390:	6a 00                	push   $0x0
80108392:	51                   	push   %ecx
80108393:	52                   	push   %edx
80108394:	50                   	push   %eax
80108395:	e8 c0 00 00 00       	call   8010845a <pci_access_config>
8010839a:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010839d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083a0:	0f b7 c0             	movzwl %ax,%eax
801083a3:	3d ff ff 00 00       	cmp    $0xffff,%eax
801083a8:	74 17                	je     801083c1 <pci_init+0x67>
        pci_init_device(i,j,k);
801083aa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801083ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	83 ec 04             	sub    $0x4,%esp
801083b6:	51                   	push   %ecx
801083b7:	52                   	push   %edx
801083b8:	50                   	push   %eax
801083b9:	e8 4f 01 00 00       	call   8010850d <pci_init_device>
801083be:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801083c1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801083c5:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801083c9:	7e b5                	jle    80108380 <pci_init+0x26>
    for(int j=0;j<32;j++){
801083cb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801083cf:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801083d3:	7e a2                	jle    80108377 <pci_init+0x1d>
  for(int i=0;i<256;i++){
801083d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083d9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801083e0:	7e 8c                	jle    8010836e <pci_init+0x14>
      }
      }
    }
  }
}
801083e2:	90                   	nop
801083e3:	90                   	nop
801083e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083e7:	c9                   	leave
801083e8:	c3                   	ret

801083e9 <pci_write_config>:

void pci_write_config(uint config){
801083e9:	f3 0f 1e fb          	endbr32
801083ed:	55                   	push   %ebp
801083ee:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801083f0:	8b 45 08             	mov    0x8(%ebp),%eax
801083f3:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801083f8:	89 c0                	mov    %eax,%eax
801083fa:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801083fb:	90                   	nop
801083fc:	5d                   	pop    %ebp
801083fd:	c3                   	ret

801083fe <pci_write_data>:

void pci_write_data(uint config){
801083fe:	f3 0f 1e fb          	endbr32
80108402:	55                   	push   %ebp
80108403:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108405:	8b 45 08             	mov    0x8(%ebp),%eax
80108408:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010840d:	89 c0                	mov    %eax,%eax
8010840f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108410:	90                   	nop
80108411:	5d                   	pop    %ebp
80108412:	c3                   	ret

80108413 <pci_read_config>:
uint pci_read_config(){
80108413:	f3 0f 1e fb          	endbr32
80108417:	55                   	push   %ebp
80108418:	89 e5                	mov    %esp,%ebp
8010841a:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010841d:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108422:	ed                   	in     (%dx),%eax
80108423:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108426:	83 ec 0c             	sub    $0xc,%esp
80108429:	68 c8 00 00 00       	push   $0xc8
8010842e:	e8 11 a8 ff ff       	call   80102c44 <microdelay>
80108433:	83 c4 10             	add    $0x10,%esp
  return data;
80108436:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108439:	c9                   	leave
8010843a:	c3                   	ret

8010843b <pci_test>:


void pci_test(){
8010843b:	f3 0f 1e fb          	endbr32
8010843f:	55                   	push   %ebp
80108440:	89 e5                	mov    %esp,%ebp
80108442:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108445:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010844c:	ff 75 fc             	push   -0x4(%ebp)
8010844f:	e8 95 ff ff ff       	call   801083e9 <pci_write_config>
80108454:	83 c4 04             	add    $0x4,%esp
}
80108457:	90                   	nop
80108458:	c9                   	leave
80108459:	c3                   	ret

8010845a <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010845a:	f3 0f 1e fb          	endbr32
8010845e:	55                   	push   %ebp
8010845f:	89 e5                	mov    %esp,%ebp
80108461:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108464:	8b 45 08             	mov    0x8(%ebp),%eax
80108467:	c1 e0 10             	shl    $0x10,%eax
8010846a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010846f:	89 c2                	mov    %eax,%edx
80108471:	8b 45 0c             	mov    0xc(%ebp),%eax
80108474:	c1 e0 0b             	shl    $0xb,%eax
80108477:	0f b7 c0             	movzwl %ax,%eax
8010847a:	09 c2                	or     %eax,%edx
8010847c:	8b 45 10             	mov    0x10(%ebp),%eax
8010847f:	c1 e0 08             	shl    $0x8,%eax
80108482:	25 00 07 00 00       	and    $0x700,%eax
80108487:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108489:	8b 45 14             	mov    0x14(%ebp),%eax
8010848c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108491:	09 d0                	or     %edx,%eax
80108493:	0d 00 00 00 80       	or     $0x80000000,%eax
80108498:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010849b:	ff 75 f4             	push   -0xc(%ebp)
8010849e:	e8 46 ff ff ff       	call   801083e9 <pci_write_config>
801084a3:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801084a6:	e8 68 ff ff ff       	call   80108413 <pci_read_config>
801084ab:	8b 55 18             	mov    0x18(%ebp),%edx
801084ae:	89 02                	mov    %eax,(%edx)
}
801084b0:	90                   	nop
801084b1:	c9                   	leave
801084b2:	c3                   	ret

801084b3 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801084b3:	f3 0f 1e fb          	endbr32
801084b7:	55                   	push   %ebp
801084b8:	89 e5                	mov    %esp,%ebp
801084ba:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084bd:	8b 45 08             	mov    0x8(%ebp),%eax
801084c0:	c1 e0 10             	shl    $0x10,%eax
801084c3:	25 00 00 ff 00       	and    $0xff0000,%eax
801084c8:	89 c2                	mov    %eax,%edx
801084ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801084cd:	c1 e0 0b             	shl    $0xb,%eax
801084d0:	0f b7 c0             	movzwl %ax,%eax
801084d3:	09 c2                	or     %eax,%edx
801084d5:	8b 45 10             	mov    0x10(%ebp),%eax
801084d8:	c1 e0 08             	shl    $0x8,%eax
801084db:	25 00 07 00 00       	and    $0x700,%eax
801084e0:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801084e2:	8b 45 14             	mov    0x14(%ebp),%eax
801084e5:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084ea:	09 d0                	or     %edx,%eax
801084ec:	0d 00 00 00 80       	or     $0x80000000,%eax
801084f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801084f4:	ff 75 fc             	push   -0x4(%ebp)
801084f7:	e8 ed fe ff ff       	call   801083e9 <pci_write_config>
801084fc:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801084ff:	ff 75 18             	push   0x18(%ebp)
80108502:	e8 f7 fe ff ff       	call   801083fe <pci_write_data>
80108507:	83 c4 04             	add    $0x4,%esp
}
8010850a:	90                   	nop
8010850b:	c9                   	leave
8010850c:	c3                   	ret

8010850d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010850d:	f3 0f 1e fb          	endbr32
80108511:	55                   	push   %ebp
80108512:	89 e5                	mov    %esp,%ebp
80108514:	53                   	push   %ebx
80108515:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108518:	8b 45 08             	mov    0x8(%ebp),%eax
8010851b:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108520:	8b 45 0c             	mov    0xc(%ebp),%eax
80108523:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
80108528:	8b 45 10             	mov    0x10(%ebp),%eax
8010852b:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108530:	ff 75 10             	push   0x10(%ebp)
80108533:	ff 75 0c             	push   0xc(%ebp)
80108536:	ff 75 08             	push   0x8(%ebp)
80108539:	68 24 c1 10 80       	push   $0x8010c124
8010853e:	e8 c9 7e ff ff       	call   8010040c <cprintf>
80108543:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108546:	83 ec 0c             	sub    $0xc,%esp
80108549:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010854c:	50                   	push   %eax
8010854d:	6a 00                	push   $0x0
8010854f:	ff 75 10             	push   0x10(%ebp)
80108552:	ff 75 0c             	push   0xc(%ebp)
80108555:	ff 75 08             	push   0x8(%ebp)
80108558:	e8 fd fe ff ff       	call   8010845a <pci_access_config>
8010855d:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108563:	c1 e8 10             	shr    $0x10,%eax
80108566:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108569:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010856c:	25 ff ff 00 00       	and    $0xffff,%eax
80108571:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
8010857c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857f:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108584:	83 ec 04             	sub    $0x4,%esp
80108587:	ff 75 f0             	push   -0x10(%ebp)
8010858a:	ff 75 f4             	push   -0xc(%ebp)
8010858d:	68 58 c1 10 80       	push   $0x8010c158
80108592:	e8 75 7e ff ff       	call   8010040c <cprintf>
80108597:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010859a:	83 ec 0c             	sub    $0xc,%esp
8010859d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085a0:	50                   	push   %eax
801085a1:	6a 08                	push   $0x8
801085a3:	ff 75 10             	push   0x10(%ebp)
801085a6:	ff 75 0c             	push   0xc(%ebp)
801085a9:	ff 75 08             	push   0x8(%ebp)
801085ac:	e8 a9 fe ff ff       	call   8010845a <pci_access_config>
801085b1:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b7:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801085ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bd:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085c0:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801085c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c6:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085c9:	0f b6 c0             	movzbl %al,%eax
801085cc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801085cf:	c1 eb 18             	shr    $0x18,%ebx
801085d2:	83 ec 0c             	sub    $0xc,%esp
801085d5:	51                   	push   %ecx
801085d6:	52                   	push   %edx
801085d7:	50                   	push   %eax
801085d8:	53                   	push   %ebx
801085d9:	68 7c c1 10 80       	push   $0x8010c17c
801085de:	e8 29 7e ff ff       	call   8010040c <cprintf>
801085e3:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801085e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e9:	c1 e8 18             	shr    $0x18,%eax
801085ec:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
801085f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f4:	c1 e8 10             	shr    $0x10,%eax
801085f7:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
801085fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ff:	c1 e8 08             	shr    $0x8,%eax
80108602:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
80108607:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860a:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010860f:	83 ec 0c             	sub    $0xc,%esp
80108612:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108615:	50                   	push   %eax
80108616:	6a 10                	push   $0x10
80108618:	ff 75 10             	push   0x10(%ebp)
8010861b:	ff 75 0c             	push   0xc(%ebp)
8010861e:	ff 75 08             	push   0x8(%ebp)
80108621:	e8 34 fe ff ff       	call   8010845a <pci_access_config>
80108626:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108629:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010862c:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108631:	83 ec 0c             	sub    $0xc,%esp
80108634:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108637:	50                   	push   %eax
80108638:	6a 14                	push   $0x14
8010863a:	ff 75 10             	push   0x10(%ebp)
8010863d:	ff 75 0c             	push   0xc(%ebp)
80108640:	ff 75 08             	push   0x8(%ebp)
80108643:	e8 12 fe ff ff       	call   8010845a <pci_access_config>
80108648:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010864b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864e:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108653:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010865a:	75 5a                	jne    801086b6 <pci_init_device+0x1a9>
8010865c:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108663:	75 51                	jne    801086b6 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108665:	83 ec 0c             	sub    $0xc,%esp
80108668:	68 c1 c1 10 80       	push   $0x8010c1c1
8010866d:	e8 9a 7d ff ff       	call   8010040c <cprintf>
80108672:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108675:	83 ec 0c             	sub    $0xc,%esp
80108678:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010867b:	50                   	push   %eax
8010867c:	68 f0 00 00 00       	push   $0xf0
80108681:	ff 75 10             	push   0x10(%ebp)
80108684:	ff 75 0c             	push   0xc(%ebp)
80108687:	ff 75 08             	push   0x8(%ebp)
8010868a:	e8 cb fd ff ff       	call   8010845a <pci_access_config>
8010868f:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108692:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108695:	83 ec 08             	sub    $0x8,%esp
80108698:	50                   	push   %eax
80108699:	68 db c1 10 80       	push   $0x8010c1db
8010869e:	e8 69 7d ff ff       	call   8010040c <cprintf>
801086a3:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801086a6:	83 ec 0c             	sub    $0xc,%esp
801086a9:	68 9c 80 19 80       	push   $0x8019809c
801086ae:	e8 09 00 00 00       	call   801086bc <i8254_init>
801086b3:	83 c4 10             	add    $0x10,%esp
  }
}
801086b6:	90                   	nop
801086b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086ba:	c9                   	leave
801086bb:	c3                   	ret

801086bc <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801086bc:	f3 0f 1e fb          	endbr32
801086c0:	55                   	push   %ebp
801086c1:	89 e5                	mov    %esp,%ebp
801086c3:	53                   	push   %ebx
801086c4:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801086c7:	8b 45 08             	mov    0x8(%ebp),%eax
801086ca:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801086ce:	0f b6 c8             	movzbl %al,%ecx
801086d1:	8b 45 08             	mov    0x8(%ebp),%eax
801086d4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801086d8:	0f b6 d0             	movzbl %al,%edx
801086db:	8b 45 08             	mov    0x8(%ebp),%eax
801086de:	0f b6 00             	movzbl (%eax),%eax
801086e1:	0f b6 c0             	movzbl %al,%eax
801086e4:	83 ec 0c             	sub    $0xc,%esp
801086e7:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801086ea:	53                   	push   %ebx
801086eb:	6a 04                	push   $0x4
801086ed:	51                   	push   %ecx
801086ee:	52                   	push   %edx
801086ef:	50                   	push   %eax
801086f0:	e8 65 fd ff ff       	call   8010845a <pci_access_config>
801086f5:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801086f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086fb:	83 c8 04             	or     $0x4,%eax
801086fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108701:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108704:	8b 45 08             	mov    0x8(%ebp),%eax
80108707:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010870b:	0f b6 c8             	movzbl %al,%ecx
8010870e:	8b 45 08             	mov    0x8(%ebp),%eax
80108711:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108715:	0f b6 d0             	movzbl %al,%edx
80108718:	8b 45 08             	mov    0x8(%ebp),%eax
8010871b:	0f b6 00             	movzbl (%eax),%eax
8010871e:	0f b6 c0             	movzbl %al,%eax
80108721:	83 ec 0c             	sub    $0xc,%esp
80108724:	53                   	push   %ebx
80108725:	6a 04                	push   $0x4
80108727:	51                   	push   %ecx
80108728:	52                   	push   %edx
80108729:	50                   	push   %eax
8010872a:	e8 84 fd ff ff       	call   801084b3 <pci_write_config_register>
8010872f:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108732:	8b 45 08             	mov    0x8(%ebp),%eax
80108735:	8b 40 10             	mov    0x10(%eax),%eax
80108738:	05 00 00 00 40       	add    $0x40000000,%eax
8010873d:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108742:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108747:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010874a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010874f:	05 d8 00 00 00       	add    $0xd8,%eax
80108754:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108763:	8b 00                	mov    (%eax),%eax
80108765:	0d 00 00 00 04       	or     $0x4000000,%eax
8010876a:	89 c2                	mov    %eax,%edx
8010876c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876f:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108774:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010877a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877d:	8b 00                	mov    (%eax),%eax
8010877f:	83 c8 40             	or     $0x40,%eax
80108782:	89 c2                	mov    %eax,%edx
80108784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108787:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878c:	8b 10                	mov    (%eax),%edx
8010878e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108791:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108793:	83 ec 0c             	sub    $0xc,%esp
80108796:	68 f0 c1 10 80       	push   $0x8010c1f0
8010879b:	e8 6c 7c ff ff       	call   8010040c <cprintf>
801087a0:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801087a3:	e8 ea a0 ff ff       	call   80102892 <kalloc>
801087a8:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
801087ad:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801087b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801087b8:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801087bd:	83 ec 08             	sub    $0x8,%esp
801087c0:	50                   	push   %eax
801087c1:	68 12 c2 10 80       	push   $0x8010c212
801087c6:	e8 41 7c ff ff       	call   8010040c <cprintf>
801087cb:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801087ce:	e8 50 00 00 00       	call   80108823 <i8254_init_recv>
  i8254_init_send();
801087d3:	e8 6d 03 00 00       	call   80108b45 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801087d8:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087df:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801087e2:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087e9:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801087ec:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087f3:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801087f6:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087fd:	0f b6 c0             	movzbl %al,%eax
80108800:	83 ec 0c             	sub    $0xc,%esp
80108803:	53                   	push   %ebx
80108804:	51                   	push   %ecx
80108805:	52                   	push   %edx
80108806:	50                   	push   %eax
80108807:	68 20 c2 10 80       	push   $0x8010c220
8010880c:	e8 fb 7b ff ff       	call   8010040c <cprintf>
80108811:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108817:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010881d:	90                   	nop
8010881e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108821:	c9                   	leave
80108822:	c3                   	ret

80108823 <i8254_init_recv>:

void i8254_init_recv(){
80108823:	f3 0f 1e fb          	endbr32
80108827:	55                   	push   %ebp
80108828:	89 e5                	mov    %esp,%ebp
8010882a:	57                   	push   %edi
8010882b:	56                   	push   %esi
8010882c:	53                   	push   %ebx
8010882d:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108830:	83 ec 0c             	sub    $0xc,%esp
80108833:	6a 00                	push   $0x0
80108835:	e8 ec 04 00 00       	call   80108d26 <i8254_read_eeprom>
8010883a:	83 c4 10             	add    $0x10,%esp
8010883d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108840:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108843:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108848:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010884b:	c1 e8 08             	shr    $0x8,%eax
8010884e:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108853:	83 ec 0c             	sub    $0xc,%esp
80108856:	6a 01                	push   $0x1
80108858:	e8 c9 04 00 00       	call   80108d26 <i8254_read_eeprom>
8010885d:	83 c4 10             	add    $0x10,%esp
80108860:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108866:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
8010886b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010886e:	c1 e8 08             	shr    $0x8,%eax
80108871:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108876:	83 ec 0c             	sub    $0xc,%esp
80108879:	6a 02                	push   $0x2
8010887b:	e8 a6 04 00 00       	call   80108d26 <i8254_read_eeprom>
80108880:	83 c4 10             	add    $0x10,%esp
80108883:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108886:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108889:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
8010888e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108891:	c1 e8 08             	shr    $0x8,%eax
80108894:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108899:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088a0:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801088a3:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088aa:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801088ad:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088b4:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801088b7:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088be:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801088c1:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088c8:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801088cb:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088d2:	0f b6 c0             	movzbl %al,%eax
801088d5:	83 ec 04             	sub    $0x4,%esp
801088d8:	57                   	push   %edi
801088d9:	56                   	push   %esi
801088da:	53                   	push   %ebx
801088db:	51                   	push   %ecx
801088dc:	52                   	push   %edx
801088dd:	50                   	push   %eax
801088de:	68 38 c2 10 80       	push   $0x8010c238
801088e3:	e8 24 7b ff ff       	call   8010040c <cprintf>
801088e8:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801088eb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801088f0:	05 00 54 00 00       	add    $0x5400,%eax
801088f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801088f8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801088fd:	05 04 54 00 00       	add    $0x5404,%eax
80108902:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108905:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108908:	c1 e0 10             	shl    $0x10,%eax
8010890b:	0b 45 d8             	or     -0x28(%ebp),%eax
8010890e:	89 c2                	mov    %eax,%edx
80108910:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108913:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108915:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108918:	0d 00 00 00 80       	or     $0x80000000,%eax
8010891d:	89 c2                	mov    %eax,%edx
8010891f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108922:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108924:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108929:	05 00 52 00 00       	add    $0x5200,%eax
8010892e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108931:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108938:	eb 19                	jmp    80108953 <i8254_init_recv+0x130>
    mta[i] = 0;
8010893a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010893d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108944:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108947:	01 d0                	add    %edx,%eax
80108949:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010894f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108953:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108957:	7e e1                	jle    8010893a <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108959:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010895e:	05 d0 00 00 00       	add    $0xd0,%eax
80108963:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108966:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108969:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010896f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108974:	05 c8 00 00 00       	add    $0xc8,%eax
80108979:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010897c:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010897f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108985:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010898a:	05 28 28 00 00       	add    $0x2828,%eax
8010898f:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108992:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108995:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010899b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089a0:	05 00 01 00 00       	add    $0x100,%eax
801089a5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801089a8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801089ab:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801089b1:	e8 dc 9e ff ff       	call   80102892 <kalloc>
801089b6:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801089b9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089be:	05 00 28 00 00       	add    $0x2800,%eax
801089c3:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801089c6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089cb:	05 04 28 00 00       	add    $0x2804,%eax
801089d0:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801089d3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089d8:	05 08 28 00 00       	add    $0x2808,%eax
801089dd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801089e0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089e5:	05 10 28 00 00       	add    $0x2810,%eax
801089ea:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801089ed:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801089f2:	05 18 28 00 00       	add    $0x2818,%eax
801089f7:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801089fa:	8b 45 b0             	mov    -0x50(%ebp),%eax
801089fd:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a03:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108a06:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108a08:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108a0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108a11:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108a14:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108a1a:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108a1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108a23:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108a26:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108a2c:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a2f:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108a32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108a39:	eb 73                	jmp    80108aae <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108a3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a3e:	c1 e0 04             	shl    $0x4,%eax
80108a41:	89 c2                	mov    %eax,%edx
80108a43:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a46:	01 d0                	add    %edx,%eax
80108a48:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108a4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a52:	c1 e0 04             	shl    $0x4,%eax
80108a55:	89 c2                	mov    %eax,%edx
80108a57:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a5a:	01 d0                	add    %edx,%eax
80108a5c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108a62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a65:	c1 e0 04             	shl    $0x4,%eax
80108a68:	89 c2                	mov    %eax,%edx
80108a6a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a6d:	01 d0                	add    %edx,%eax
80108a6f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108a75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a78:	c1 e0 04             	shl    $0x4,%eax
80108a7b:	89 c2                	mov    %eax,%edx
80108a7d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a80:	01 d0                	add    %edx,%eax
80108a82:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a89:	c1 e0 04             	shl    $0x4,%eax
80108a8c:	89 c2                	mov    %eax,%edx
80108a8e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a91:	01 d0                	add    %edx,%eax
80108a93:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a9a:	c1 e0 04             	shl    $0x4,%eax
80108a9d:	89 c2                	mov    %eax,%edx
80108a9f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108aa2:	01 d0                	add    %edx,%eax
80108aa4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108aaa:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108aae:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ab5:	7e 84                	jle    80108a3b <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ab7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108abe:	eb 57                	jmp    80108b17 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108ac0:	e8 cd 9d ff ff       	call   80102892 <kalloc>
80108ac5:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ac8:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108acc:	75 12                	jne    80108ae0 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108ace:	83 ec 0c             	sub    $0xc,%esp
80108ad1:	68 58 c2 10 80       	push   $0x8010c258
80108ad6:	e8 31 79 ff ff       	call   8010040c <cprintf>
80108adb:	83 c4 10             	add    $0x10,%esp
      break;
80108ade:	eb 3d                	jmp    80108b1d <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108ae0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ae3:	c1 e0 04             	shl    $0x4,%eax
80108ae6:	89 c2                	mov    %eax,%edx
80108ae8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108aeb:	01 d0                	add    %edx,%eax
80108aed:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108af0:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108af6:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108af8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108afb:	83 c0 01             	add    $0x1,%eax
80108afe:	c1 e0 04             	shl    $0x4,%eax
80108b01:	89 c2                	mov    %eax,%edx
80108b03:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b06:	01 d0                	add    %edx,%eax
80108b08:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b0b:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b11:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b13:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108b17:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108b1b:	7e a3                	jle    80108ac0 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108b1d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b20:	8b 00                	mov    (%eax),%eax
80108b22:	83 c8 02             	or     $0x2,%eax
80108b25:	89 c2                	mov    %eax,%edx
80108b27:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b2a:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108b2c:	83 ec 0c             	sub    $0xc,%esp
80108b2f:	68 78 c2 10 80       	push   $0x8010c278
80108b34:	e8 d3 78 ff ff       	call   8010040c <cprintf>
80108b39:	83 c4 10             	add    $0x10,%esp
}
80108b3c:	90                   	nop
80108b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108b40:	5b                   	pop    %ebx
80108b41:	5e                   	pop    %esi
80108b42:	5f                   	pop    %edi
80108b43:	5d                   	pop    %ebp
80108b44:	c3                   	ret

80108b45 <i8254_init_send>:

void i8254_init_send(){
80108b45:	f3 0f 1e fb          	endbr32
80108b49:	55                   	push   %ebp
80108b4a:	89 e5                	mov    %esp,%ebp
80108b4c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108b4f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b54:	05 28 38 00 00       	add    $0x3828,%eax
80108b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b5f:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108b65:	e8 28 9d ff ff       	call   80102892 <kalloc>
80108b6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108b6d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b72:	05 00 38 00 00       	add    $0x3800,%eax
80108b77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108b7a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b7f:	05 04 38 00 00       	add    $0x3804,%eax
80108b84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108b87:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b8c:	05 08 38 00 00       	add    $0x3808,%eax
80108b91:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108b94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b97:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ba0:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108bab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108bae:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108bb4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bb9:	05 10 38 00 00       	add    $0x3810,%eax
80108bbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bc1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bc6:	05 18 38 00 00       	add    $0x3818,%eax
80108bcb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108bce:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108bd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108be0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108be3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108be6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bed:	e9 82 00 00 00       	jmp    80108c74 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf5:	c1 e0 04             	shl    $0x4,%eax
80108bf8:	89 c2                	mov    %eax,%edx
80108bfa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bfd:	01 d0                	add    %edx,%eax
80108bff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c09:	c1 e0 04             	shl    $0x4,%eax
80108c0c:	89 c2                	mov    %eax,%edx
80108c0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c11:	01 d0                	add    %edx,%eax
80108c13:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1c:	c1 e0 04             	shl    $0x4,%eax
80108c1f:	89 c2                	mov    %eax,%edx
80108c21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c24:	01 d0                	add    %edx,%eax
80108c26:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2d:	c1 e0 04             	shl    $0x4,%eax
80108c30:	89 c2                	mov    %eax,%edx
80108c32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c35:	01 d0                	add    %edx,%eax
80108c37:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3e:	c1 e0 04             	shl    $0x4,%eax
80108c41:	89 c2                	mov    %eax,%edx
80108c43:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c46:	01 d0                	add    %edx,%eax
80108c48:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4f:	c1 e0 04             	shl    $0x4,%eax
80108c52:	89 c2                	mov    %eax,%edx
80108c54:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c57:	01 d0                	add    %edx,%eax
80108c59:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c60:	c1 e0 04             	shl    $0x4,%eax
80108c63:	89 c2                	mov    %eax,%edx
80108c65:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c68:	01 d0                	add    %edx,%eax
80108c6a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c74:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c7b:	0f 8e 71 ff ff ff    	jle    80108bf2 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c88:	eb 57                	jmp    80108ce1 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108c8a:	e8 03 9c ff ff       	call   80102892 <kalloc>
80108c8f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108c92:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108c96:	75 12                	jne    80108caa <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108c98:	83 ec 0c             	sub    $0xc,%esp
80108c9b:	68 58 c2 10 80       	push   $0x8010c258
80108ca0:	e8 67 77 ff ff       	call   8010040c <cprintf>
80108ca5:	83 c4 10             	add    $0x10,%esp
      break;
80108ca8:	eb 3d                	jmp    80108ce7 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cad:	c1 e0 04             	shl    $0x4,%eax
80108cb0:	89 c2                	mov    %eax,%edx
80108cb2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb5:	01 d0                	add    %edx,%eax
80108cb7:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108cba:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cc0:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc5:	83 c0 01             	add    $0x1,%eax
80108cc8:	c1 e0 04             	shl    $0x4,%eax
80108ccb:	89 c2                	mov    %eax,%edx
80108ccd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cd0:	01 d0                	add    %edx,%eax
80108cd2:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108cd5:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108cdb:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108cdd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ce1:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108ce5:	7e a3                	jle    80108c8a <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108ce7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cec:	05 00 04 00 00       	add    $0x400,%eax
80108cf1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108cf4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108cf7:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108cfd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d02:	05 10 04 00 00       	add    $0x410,%eax
80108d07:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108d0a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d0d:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108d13:	83 ec 0c             	sub    $0xc,%esp
80108d16:	68 98 c2 10 80       	push   $0x8010c298
80108d1b:	e8 ec 76 ff ff       	call   8010040c <cprintf>
80108d20:	83 c4 10             	add    $0x10,%esp

}
80108d23:	90                   	nop
80108d24:	c9                   	leave
80108d25:	c3                   	ret

80108d26 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108d26:	f3 0f 1e fb          	endbr32
80108d2a:	55                   	push   %ebp
80108d2b:	89 e5                	mov    %esp,%ebp
80108d2d:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108d30:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d35:	83 c0 14             	add    $0x14,%eax
80108d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d3e:	c1 e0 08             	shl    $0x8,%eax
80108d41:	0f b7 c0             	movzwl %ax,%eax
80108d44:	83 c8 01             	or     $0x1,%eax
80108d47:	89 c2                	mov    %eax,%edx
80108d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4c:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108d4e:	83 ec 0c             	sub    $0xc,%esp
80108d51:	68 b8 c2 10 80       	push   $0x8010c2b8
80108d56:	e8 b1 76 ff ff       	call   8010040c <cprintf>
80108d5b:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d61:	8b 00                	mov    (%eax),%eax
80108d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d69:	83 e0 10             	and    $0x10,%eax
80108d6c:	85 c0                	test   %eax,%eax
80108d6e:	75 02                	jne    80108d72 <i8254_read_eeprom+0x4c>
  while(1){
80108d70:	eb dc                	jmp    80108d4e <i8254_read_eeprom+0x28>
      break;
80108d72:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d76:	8b 00                	mov    (%eax),%eax
80108d78:	c1 e8 10             	shr    $0x10,%eax
}
80108d7b:	c9                   	leave
80108d7c:	c3                   	ret

80108d7d <i8254_recv>:
void i8254_recv(){
80108d7d:	f3 0f 1e fb          	endbr32
80108d81:	55                   	push   %ebp
80108d82:	89 e5                	mov    %esp,%ebp
80108d84:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d87:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d8c:	05 10 28 00 00       	add    $0x2810,%eax
80108d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d94:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d99:	05 18 28 00 00       	add    $0x2818,%eax
80108d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108da1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108da6:	05 00 28 00 00       	add    $0x2800,%eax
80108dab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db1:	8b 00                	mov    (%eax),%eax
80108db3:	05 00 00 00 80       	add    $0x80000000,%eax
80108db8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbe:	8b 10                	mov    (%eax),%edx
80108dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc3:	8b 00                	mov    (%eax),%eax
80108dc5:	29 c2                	sub    %eax,%edx
80108dc7:	89 d0                	mov    %edx,%eax
80108dc9:	25 ff 00 00 00       	and    $0xff,%eax
80108dce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108dd1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108dd5:	7e 37                	jle    80108e0e <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dda:	8b 00                	mov    (%eax),%eax
80108ddc:	c1 e0 04             	shl    $0x4,%eax
80108ddf:	89 c2                	mov    %eax,%edx
80108de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de4:	01 d0                	add    %edx,%eax
80108de6:	8b 00                	mov    (%eax),%eax
80108de8:	05 00 00 00 80       	add    $0x80000000,%eax
80108ded:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df3:	8b 00                	mov    (%eax),%eax
80108df5:	83 c0 01             	add    $0x1,%eax
80108df8:	0f b6 d0             	movzbl %al,%edx
80108dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dfe:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108e00:	83 ec 0c             	sub    $0xc,%esp
80108e03:	ff 75 e0             	push   -0x20(%ebp)
80108e06:	e8 47 09 00 00       	call   80109752 <eth_proc>
80108e0b:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e11:	8b 10                	mov    (%eax),%edx
80108e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e16:	8b 00                	mov    (%eax),%eax
80108e18:	39 c2                	cmp    %eax,%edx
80108e1a:	75 9f                	jne    80108dbb <i8254_recv+0x3e>
      (*rdt)--;
80108e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1f:	8b 00                	mov    (%eax),%eax
80108e21:	8d 50 ff             	lea    -0x1(%eax),%edx
80108e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e27:	89 10                	mov    %edx,(%eax)
  while(1){
80108e29:	eb 90                	jmp    80108dbb <i8254_recv+0x3e>

80108e2b <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108e2b:	f3 0f 1e fb          	endbr32
80108e2f:	55                   	push   %ebp
80108e30:	89 e5                	mov    %esp,%ebp
80108e32:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e35:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e3a:	05 10 38 00 00       	add    $0x3810,%eax
80108e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e42:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e47:	05 18 38 00 00       	add    $0x3818,%eax
80108e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e4f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e54:	05 00 38 00 00       	add    $0x3800,%eax
80108e59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108e5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e5f:	8b 00                	mov    (%eax),%eax
80108e61:	05 00 00 00 80       	add    $0x80000000,%eax
80108e66:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6c:	8b 10                	mov    (%eax),%edx
80108e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e71:	8b 00                	mov    (%eax),%eax
80108e73:	29 c2                	sub    %eax,%edx
80108e75:	89 d0                	mov    %edx,%eax
80108e77:	0f b6 c0             	movzbl %al,%eax
80108e7a:	ba 00 01 00 00       	mov    $0x100,%edx
80108e7f:	29 c2                	sub    %eax,%edx
80108e81:	89 d0                	mov    %edx,%eax
80108e83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e89:	8b 00                	mov    (%eax),%eax
80108e8b:	25 ff 00 00 00       	and    $0xff,%eax
80108e90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108e93:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e97:	0f 8e a8 00 00 00    	jle    80108f45 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108ea3:	89 d1                	mov    %edx,%ecx
80108ea5:	c1 e1 04             	shl    $0x4,%ecx
80108ea8:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108eab:	01 ca                	add    %ecx,%edx
80108ead:	8b 12                	mov    (%edx),%edx
80108eaf:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eb5:	83 ec 04             	sub    $0x4,%esp
80108eb8:	ff 75 0c             	push   0xc(%ebp)
80108ebb:	50                   	push   %eax
80108ebc:	52                   	push   %edx
80108ebd:	e8 7b bd ff ff       	call   80104c3d <memmove>
80108ec2:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ec8:	c1 e0 04             	shl    $0x4,%eax
80108ecb:	89 c2                	mov    %eax,%edx
80108ecd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ed0:	01 d0                	add    %edx,%eax
80108ed2:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ed5:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108ed9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108edc:	c1 e0 04             	shl    $0x4,%eax
80108edf:	89 c2                	mov    %eax,%edx
80108ee1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ee4:	01 d0                	add    %edx,%eax
80108ee6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108eed:	c1 e0 04             	shl    $0x4,%eax
80108ef0:	89 c2                	mov    %eax,%edx
80108ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef5:	01 d0                	add    %edx,%eax
80108ef7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108efb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108efe:	c1 e0 04             	shl    $0x4,%eax
80108f01:	89 c2                	mov    %eax,%edx
80108f03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f06:	01 d0                	add    %edx,%eax
80108f08:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f0f:	c1 e0 04             	shl    $0x4,%eax
80108f12:	89 c2                	mov    %eax,%edx
80108f14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f17:	01 d0                	add    %edx,%eax
80108f19:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f22:	c1 e0 04             	shl    $0x4,%eax
80108f25:	89 c2                	mov    %eax,%edx
80108f27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f2a:	01 d0                	add    %edx,%eax
80108f2c:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f33:	8b 00                	mov    (%eax),%eax
80108f35:	83 c0 01             	add    $0x1,%eax
80108f38:	0f b6 d0             	movzbl %al,%edx
80108f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3e:	89 10                	mov    %edx,(%eax)
    return len;
80108f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f43:	eb 05                	jmp    80108f4a <i8254_send+0x11f>
  }else{
    return -1;
80108f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108f4a:	c9                   	leave
80108f4b:	c3                   	ret

80108f4c <i8254_intr>:

void i8254_intr(){
80108f4c:	f3 0f 1e fb          	endbr32
80108f50:	55                   	push   %ebp
80108f51:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108f53:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108f58:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108f5e:	90                   	nop
80108f5f:	5d                   	pop    %ebp
80108f60:	c3                   	ret

80108f61 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108f61:	f3 0f 1e fb          	endbr32
80108f65:	55                   	push   %ebp
80108f66:	89 e5                	mov    %esp,%ebp
80108f68:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f74:	0f b7 00             	movzwl (%eax),%eax
80108f77:	66 3d 00 01          	cmp    $0x100,%ax
80108f7b:	74 0a                	je     80108f87 <arp_proc+0x26>
80108f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f82:	e9 4f 01 00 00       	jmp    801090d6 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108f8e:	66 83 f8 08          	cmp    $0x8,%ax
80108f92:	74 0a                	je     80108f9e <arp_proc+0x3d>
80108f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f99:	e9 38 01 00 00       	jmp    801090d6 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80108f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108fa5:	3c 06                	cmp    $0x6,%al
80108fa7:	74 0a                	je     80108fb3 <arp_proc+0x52>
80108fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fae:	e9 23 01 00 00       	jmp    801090d6 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80108fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb6:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108fba:	3c 04                	cmp    $0x4,%al
80108fbc:	74 0a                	je     80108fc8 <arp_proc+0x67>
80108fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fc3:	e9 0e 01 00 00       	jmp    801090d6 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fcb:	83 c0 18             	add    $0x18,%eax
80108fce:	83 ec 04             	sub    $0x4,%esp
80108fd1:	6a 04                	push   $0x4
80108fd3:	50                   	push   %eax
80108fd4:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fd9:	e8 03 bc ff ff       	call   80104be1 <memcmp>
80108fde:	83 c4 10             	add    $0x10,%esp
80108fe1:	85 c0                	test   %eax,%eax
80108fe3:	74 27                	je     8010900c <arp_proc+0xab>
80108fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe8:	83 c0 0e             	add    $0xe,%eax
80108feb:	83 ec 04             	sub    $0x4,%esp
80108fee:	6a 04                	push   $0x4
80108ff0:	50                   	push   %eax
80108ff1:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ff6:	e8 e6 bb ff ff       	call   80104be1 <memcmp>
80108ffb:	83 c4 10             	add    $0x10,%esp
80108ffe:	85 c0                	test   %eax,%eax
80109000:	74 0a                	je     8010900c <arp_proc+0xab>
80109002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109007:	e9 ca 00 00 00       	jmp    801090d6 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010900c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109013:	66 3d 00 01          	cmp    $0x100,%ax
80109017:	75 69                	jne    80109082 <arp_proc+0x121>
80109019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901c:	83 c0 18             	add    $0x18,%eax
8010901f:	83 ec 04             	sub    $0x4,%esp
80109022:	6a 04                	push   $0x4
80109024:	50                   	push   %eax
80109025:	68 e4 f4 10 80       	push   $0x8010f4e4
8010902a:	e8 b2 bb ff ff       	call   80104be1 <memcmp>
8010902f:	83 c4 10             	add    $0x10,%esp
80109032:	85 c0                	test   %eax,%eax
80109034:	75 4c                	jne    80109082 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109036:	e8 57 98 ff ff       	call   80102892 <kalloc>
8010903b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010903e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109045:	83 ec 04             	sub    $0x4,%esp
80109048:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010904b:	50                   	push   %eax
8010904c:	ff 75 f0             	push   -0x10(%ebp)
8010904f:	ff 75 f4             	push   -0xc(%ebp)
80109052:	e8 33 04 00 00       	call   8010948a <arp_reply_pkt_create>
80109057:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010905a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010905d:	83 ec 08             	sub    $0x8,%esp
80109060:	50                   	push   %eax
80109061:	ff 75 f0             	push   -0x10(%ebp)
80109064:	e8 c2 fd ff ff       	call   80108e2b <i8254_send>
80109069:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010906c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906f:	83 ec 0c             	sub    $0xc,%esp
80109072:	50                   	push   %eax
80109073:	e8 7c 97 ff ff       	call   801027f4 <kfree>
80109078:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010907b:	b8 02 00 00 00       	mov    $0x2,%eax
80109080:	eb 54                	jmp    801090d6 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109085:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109089:	66 3d 00 02          	cmp    $0x200,%ax
8010908d:	75 42                	jne    801090d1 <arp_proc+0x170>
8010908f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109092:	83 c0 18             	add    $0x18,%eax
80109095:	83 ec 04             	sub    $0x4,%esp
80109098:	6a 04                	push   $0x4
8010909a:	50                   	push   %eax
8010909b:	68 e4 f4 10 80       	push   $0x8010f4e4
801090a0:	e8 3c bb ff ff       	call   80104be1 <memcmp>
801090a5:	83 c4 10             	add    $0x10,%esp
801090a8:	85 c0                	test   %eax,%eax
801090aa:	75 25                	jne    801090d1 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801090ac:	83 ec 0c             	sub    $0xc,%esp
801090af:	68 bc c2 10 80       	push   $0x8010c2bc
801090b4:	e8 53 73 ff ff       	call   8010040c <cprintf>
801090b9:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801090bc:	83 ec 0c             	sub    $0xc,%esp
801090bf:	ff 75 f4             	push   -0xc(%ebp)
801090c2:	e8 b7 01 00 00       	call   8010927e <arp_table_update>
801090c7:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801090ca:	b8 01 00 00 00       	mov    $0x1,%eax
801090cf:	eb 05                	jmp    801090d6 <arp_proc+0x175>
  }else{
    return -1;
801090d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801090d6:	c9                   	leave
801090d7:	c3                   	ret

801090d8 <arp_scan>:

void arp_scan(){
801090d8:	f3 0f 1e fb          	endbr32
801090dc:	55                   	push   %ebp
801090dd:	89 e5                	mov    %esp,%ebp
801090df:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801090e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090e9:	eb 6f                	jmp    8010915a <arp_scan+0x82>
    uint send = (uint)kalloc();
801090eb:	e8 a2 97 ff ff       	call   80102892 <kalloc>
801090f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801090f3:	83 ec 04             	sub    $0x4,%esp
801090f6:	ff 75 f4             	push   -0xc(%ebp)
801090f9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801090fc:	50                   	push   %eax
801090fd:	ff 75 ec             	push   -0x14(%ebp)
80109100:	e8 62 00 00 00       	call   80109167 <arp_broadcast>
80109105:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109108:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010910b:	83 ec 08             	sub    $0x8,%esp
8010910e:	50                   	push   %eax
8010910f:	ff 75 ec             	push   -0x14(%ebp)
80109112:	e8 14 fd ff ff       	call   80108e2b <i8254_send>
80109117:	83 c4 10             	add    $0x10,%esp
8010911a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010911d:	eb 22                	jmp    80109141 <arp_scan+0x69>
      microdelay(1);
8010911f:	83 ec 0c             	sub    $0xc,%esp
80109122:	6a 01                	push   $0x1
80109124:	e8 1b 9b ff ff       	call   80102c44 <microdelay>
80109129:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010912c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010912f:	83 ec 08             	sub    $0x8,%esp
80109132:	50                   	push   %eax
80109133:	ff 75 ec             	push   -0x14(%ebp)
80109136:	e8 f0 fc ff ff       	call   80108e2b <i8254_send>
8010913b:	83 c4 10             	add    $0x10,%esp
8010913e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109141:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109145:	74 d8                	je     8010911f <arp_scan+0x47>
    }
    kfree((char *)send);
80109147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010914a:	83 ec 0c             	sub    $0xc,%esp
8010914d:	50                   	push   %eax
8010914e:	e8 a1 96 ff ff       	call   801027f4 <kfree>
80109153:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109156:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010915a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109161:	7e 88                	jle    801090eb <arp_scan+0x13>
  }
}
80109163:	90                   	nop
80109164:	90                   	nop
80109165:	c9                   	leave
80109166:	c3                   	ret

80109167 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109167:	f3 0f 1e fb          	endbr32
8010916b:	55                   	push   %ebp
8010916c:	89 e5                	mov    %esp,%ebp
8010916e:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109171:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109175:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109179:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010917d:	8b 45 10             	mov    0x10(%ebp),%eax
80109180:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109183:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010918a:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109190:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109197:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010919d:	8b 45 0c             	mov    0xc(%ebp),%eax
801091a0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801091a6:	8b 45 08             	mov    0x8(%ebp),%eax
801091a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801091ac:	8b 45 08             	mov    0x8(%ebp),%eax
801091af:	83 c0 0e             	add    $0xe,%eax
801091b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801091b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801091bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091bf:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801091c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c6:	83 ec 04             	sub    $0x4,%esp
801091c9:	6a 06                	push   $0x6
801091cb:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801091ce:	52                   	push   %edx
801091cf:	50                   	push   %eax
801091d0:	e8 68 ba ff ff       	call   80104c3d <memmove>
801091d5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801091d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091db:	83 c0 06             	add    $0x6,%eax
801091de:	83 ec 04             	sub    $0x4,%esp
801091e1:	6a 06                	push   $0x6
801091e3:	68 68 d0 18 80       	push   $0x8018d068
801091e8:	50                   	push   %eax
801091e9:	e8 4f ba ff ff       	call   80104c3d <memmove>
801091ee:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801091f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f4:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801091f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fc:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109202:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109205:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109213:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109219:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921c:	8d 50 12             	lea    0x12(%eax),%edx
8010921f:	83 ec 04             	sub    $0x4,%esp
80109222:	6a 06                	push   $0x6
80109224:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109227:	50                   	push   %eax
80109228:	52                   	push   %edx
80109229:	e8 0f ba ff ff       	call   80104c3d <memmove>
8010922e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109234:	8d 50 18             	lea    0x18(%eax),%edx
80109237:	83 ec 04             	sub    $0x4,%esp
8010923a:	6a 04                	push   $0x4
8010923c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010923f:	50                   	push   %eax
80109240:	52                   	push   %edx
80109241:	e8 f7 b9 ff ff       	call   80104c3d <memmove>
80109246:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924c:	83 c0 08             	add    $0x8,%eax
8010924f:	83 ec 04             	sub    $0x4,%esp
80109252:	6a 06                	push   $0x6
80109254:	68 68 d0 18 80       	push   $0x8018d068
80109259:	50                   	push   %eax
8010925a:	e8 de b9 ff ff       	call   80104c3d <memmove>
8010925f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109265:	83 c0 0e             	add    $0xe,%eax
80109268:	83 ec 04             	sub    $0x4,%esp
8010926b:	6a 04                	push   $0x4
8010926d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109272:	50                   	push   %eax
80109273:	e8 c5 b9 ff ff       	call   80104c3d <memmove>
80109278:	83 c4 10             	add    $0x10,%esp
}
8010927b:	90                   	nop
8010927c:	c9                   	leave
8010927d:	c3                   	ret

8010927e <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010927e:	f3 0f 1e fb          	endbr32
80109282:	55                   	push   %ebp
80109283:	89 e5                	mov    %esp,%ebp
80109285:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109288:	8b 45 08             	mov    0x8(%ebp),%eax
8010928b:	83 c0 0e             	add    $0xe,%eax
8010928e:	83 ec 0c             	sub    $0xc,%esp
80109291:	50                   	push   %eax
80109292:	e8 bc 00 00 00       	call   80109353 <arp_table_search>
80109297:	83 c4 10             	add    $0x10,%esp
8010929a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010929d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801092a1:	78 2d                	js     801092d0 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801092a3:	8b 45 08             	mov    0x8(%ebp),%eax
801092a6:	8d 48 08             	lea    0x8(%eax),%ecx
801092a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092ac:	89 d0                	mov    %edx,%eax
801092ae:	c1 e0 02             	shl    $0x2,%eax
801092b1:	01 d0                	add    %edx,%eax
801092b3:	01 c0                	add    %eax,%eax
801092b5:	01 d0                	add    %edx,%eax
801092b7:	05 80 d0 18 80       	add    $0x8018d080,%eax
801092bc:	83 c0 04             	add    $0x4,%eax
801092bf:	83 ec 04             	sub    $0x4,%esp
801092c2:	6a 06                	push   $0x6
801092c4:	51                   	push   %ecx
801092c5:	50                   	push   %eax
801092c6:	e8 72 b9 ff ff       	call   80104c3d <memmove>
801092cb:	83 c4 10             	add    $0x10,%esp
801092ce:	eb 70                	jmp    80109340 <arp_table_update+0xc2>
  }else{
    index += 1;
801092d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801092d4:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801092d7:	8b 45 08             	mov    0x8(%ebp),%eax
801092da:	8d 48 08             	lea    0x8(%eax),%ecx
801092dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092e0:	89 d0                	mov    %edx,%eax
801092e2:	c1 e0 02             	shl    $0x2,%eax
801092e5:	01 d0                	add    %edx,%eax
801092e7:	01 c0                	add    %eax,%eax
801092e9:	01 d0                	add    %edx,%eax
801092eb:	05 80 d0 18 80       	add    $0x8018d080,%eax
801092f0:	83 c0 04             	add    $0x4,%eax
801092f3:	83 ec 04             	sub    $0x4,%esp
801092f6:	6a 06                	push   $0x6
801092f8:	51                   	push   %ecx
801092f9:	50                   	push   %eax
801092fa:	e8 3e b9 ff ff       	call   80104c3d <memmove>
801092ff:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109302:	8b 45 08             	mov    0x8(%ebp),%eax
80109305:	8d 48 0e             	lea    0xe(%eax),%ecx
80109308:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010930b:	89 d0                	mov    %edx,%eax
8010930d:	c1 e0 02             	shl    $0x2,%eax
80109310:	01 d0                	add    %edx,%eax
80109312:	01 c0                	add    %eax,%eax
80109314:	01 d0                	add    %edx,%eax
80109316:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010931b:	83 ec 04             	sub    $0x4,%esp
8010931e:	6a 04                	push   $0x4
80109320:	51                   	push   %ecx
80109321:	50                   	push   %eax
80109322:	e8 16 b9 ff ff       	call   80104c3d <memmove>
80109327:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010932a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010932d:	89 d0                	mov    %edx,%eax
8010932f:	c1 e0 02             	shl    $0x2,%eax
80109332:	01 d0                	add    %edx,%eax
80109334:	01 c0                	add    %eax,%eax
80109336:	01 d0                	add    %edx,%eax
80109338:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010933d:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109340:	83 ec 0c             	sub    $0xc,%esp
80109343:	68 80 d0 18 80       	push   $0x8018d080
80109348:	e8 87 00 00 00       	call   801093d4 <print_arp_table>
8010934d:	83 c4 10             	add    $0x10,%esp
}
80109350:	90                   	nop
80109351:	c9                   	leave
80109352:	c3                   	ret

80109353 <arp_table_search>:

int arp_table_search(uchar *ip){
80109353:	f3 0f 1e fb          	endbr32
80109357:	55                   	push   %ebp
80109358:	89 e5                	mov    %esp,%ebp
8010935a:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010935d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109364:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010936b:	eb 59                	jmp    801093c6 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010936d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109370:	89 d0                	mov    %edx,%eax
80109372:	c1 e0 02             	shl    $0x2,%eax
80109375:	01 d0                	add    %edx,%eax
80109377:	01 c0                	add    %eax,%eax
80109379:	01 d0                	add    %edx,%eax
8010937b:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109380:	83 ec 04             	sub    $0x4,%esp
80109383:	6a 04                	push   $0x4
80109385:	ff 75 08             	push   0x8(%ebp)
80109388:	50                   	push   %eax
80109389:	e8 53 b8 ff ff       	call   80104be1 <memcmp>
8010938e:	83 c4 10             	add    $0x10,%esp
80109391:	85 c0                	test   %eax,%eax
80109393:	75 05                	jne    8010939a <arp_table_search+0x47>
      return i;
80109395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109398:	eb 38                	jmp    801093d2 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010939a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010939d:	89 d0                	mov    %edx,%eax
8010939f:	c1 e0 02             	shl    $0x2,%eax
801093a2:	01 d0                	add    %edx,%eax
801093a4:	01 c0                	add    %eax,%eax
801093a6:	01 d0                	add    %edx,%eax
801093a8:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801093ad:	0f b6 00             	movzbl (%eax),%eax
801093b0:	84 c0                	test   %al,%al
801093b2:	75 0e                	jne    801093c2 <arp_table_search+0x6f>
801093b4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801093b8:	75 08                	jne    801093c2 <arp_table_search+0x6f>
      empty = -i;
801093ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bd:	f7 d8                	neg    %eax
801093bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801093c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801093c6:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801093ca:	7e a1                	jle    8010936d <arp_table_search+0x1a>
    }
  }
  return empty-1;
801093cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093cf:	83 e8 01             	sub    $0x1,%eax
}
801093d2:	c9                   	leave
801093d3:	c3                   	ret

801093d4 <print_arp_table>:

void print_arp_table(){
801093d4:	f3 0f 1e fb          	endbr32
801093d8:	55                   	push   %ebp
801093d9:	89 e5                	mov    %esp,%ebp
801093db:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801093de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093e5:	e9 92 00 00 00       	jmp    8010947c <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
801093ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093ed:	89 d0                	mov    %edx,%eax
801093ef:	c1 e0 02             	shl    $0x2,%eax
801093f2:	01 d0                	add    %edx,%eax
801093f4:	01 c0                	add    %eax,%eax
801093f6:	01 d0                	add    %edx,%eax
801093f8:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801093fd:	0f b6 00             	movzbl (%eax),%eax
80109400:	84 c0                	test   %al,%al
80109402:	74 74                	je     80109478 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109404:	83 ec 08             	sub    $0x8,%esp
80109407:	ff 75 f4             	push   -0xc(%ebp)
8010940a:	68 cf c2 10 80       	push   $0x8010c2cf
8010940f:	e8 f8 6f ff ff       	call   8010040c <cprintf>
80109414:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109417:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010941a:	89 d0                	mov    %edx,%eax
8010941c:	c1 e0 02             	shl    $0x2,%eax
8010941f:	01 d0                	add    %edx,%eax
80109421:	01 c0                	add    %eax,%eax
80109423:	01 d0                	add    %edx,%eax
80109425:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010942a:	83 ec 0c             	sub    $0xc,%esp
8010942d:	50                   	push   %eax
8010942e:	e8 5c 02 00 00       	call   8010968f <print_ipv4>
80109433:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109436:	83 ec 0c             	sub    $0xc,%esp
80109439:	68 de c2 10 80       	push   $0x8010c2de
8010943e:	e8 c9 6f ff ff       	call   8010040c <cprintf>
80109443:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109449:	89 d0                	mov    %edx,%eax
8010944b:	c1 e0 02             	shl    $0x2,%eax
8010944e:	01 d0                	add    %edx,%eax
80109450:	01 c0                	add    %eax,%eax
80109452:	01 d0                	add    %edx,%eax
80109454:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109459:	83 c0 04             	add    $0x4,%eax
8010945c:	83 ec 0c             	sub    $0xc,%esp
8010945f:	50                   	push   %eax
80109460:	e8 7c 02 00 00       	call   801096e1 <print_mac>
80109465:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109468:	83 ec 0c             	sub    $0xc,%esp
8010946b:	68 e0 c2 10 80       	push   $0x8010c2e0
80109470:	e8 97 6f ff ff       	call   8010040c <cprintf>
80109475:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109478:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010947c:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109480:	0f 8e 64 ff ff ff    	jle    801093ea <print_arp_table+0x16>
    }
  }
}
80109486:	90                   	nop
80109487:	90                   	nop
80109488:	c9                   	leave
80109489:	c3                   	ret

8010948a <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010948a:	f3 0f 1e fb          	endbr32
8010948e:	55                   	push   %ebp
8010948f:	89 e5                	mov    %esp,%ebp
80109491:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109494:	8b 45 10             	mov    0x10(%ebp),%eax
80109497:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010949d:	8b 45 0c             	mov    0xc(%ebp),%eax
801094a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801094a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801094a6:	83 c0 0e             	add    $0xe,%eax
801094a9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801094ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094af:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801094b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801094ba:	8b 45 08             	mov    0x8(%ebp),%eax
801094bd:	8d 50 08             	lea    0x8(%eax),%edx
801094c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c3:	83 ec 04             	sub    $0x4,%esp
801094c6:	6a 06                	push   $0x6
801094c8:	52                   	push   %edx
801094c9:	50                   	push   %eax
801094ca:	e8 6e b7 ff ff       	call   80104c3d <memmove>
801094cf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801094d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d5:	83 c0 06             	add    $0x6,%eax
801094d8:	83 ec 04             	sub    $0x4,%esp
801094db:	6a 06                	push   $0x6
801094dd:	68 68 d0 18 80       	push   $0x8018d068
801094e2:	50                   	push   %eax
801094e3:	e8 55 b7 ff ff       	call   80104c3d <memmove>
801094e8:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801094eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ee:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801094f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f6:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801094fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ff:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109506:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010950a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010950d:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109513:	8b 45 08             	mov    0x8(%ebp),%eax
80109516:	8d 50 08             	lea    0x8(%eax),%edx
80109519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010951c:	83 c0 12             	add    $0x12,%eax
8010951f:	83 ec 04             	sub    $0x4,%esp
80109522:	6a 06                	push   $0x6
80109524:	52                   	push   %edx
80109525:	50                   	push   %eax
80109526:	e8 12 b7 ff ff       	call   80104c3d <memmove>
8010952b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010952e:	8b 45 08             	mov    0x8(%ebp),%eax
80109531:	8d 50 0e             	lea    0xe(%eax),%edx
80109534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109537:	83 c0 18             	add    $0x18,%eax
8010953a:	83 ec 04             	sub    $0x4,%esp
8010953d:	6a 04                	push   $0x4
8010953f:	52                   	push   %edx
80109540:	50                   	push   %eax
80109541:	e8 f7 b6 ff ff       	call   80104c3d <memmove>
80109546:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010954c:	83 c0 08             	add    $0x8,%eax
8010954f:	83 ec 04             	sub    $0x4,%esp
80109552:	6a 06                	push   $0x6
80109554:	68 68 d0 18 80       	push   $0x8018d068
80109559:	50                   	push   %eax
8010955a:	e8 de b6 ff ff       	call   80104c3d <memmove>
8010955f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109565:	83 c0 0e             	add    $0xe,%eax
80109568:	83 ec 04             	sub    $0x4,%esp
8010956b:	6a 04                	push   $0x4
8010956d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109572:	50                   	push   %eax
80109573:	e8 c5 b6 ff ff       	call   80104c3d <memmove>
80109578:	83 c4 10             	add    $0x10,%esp
}
8010957b:	90                   	nop
8010957c:	c9                   	leave
8010957d:	c3                   	ret

8010957e <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010957e:	f3 0f 1e fb          	endbr32
80109582:	55                   	push   %ebp
80109583:	89 e5                	mov    %esp,%ebp
80109585:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109588:	83 ec 0c             	sub    $0xc,%esp
8010958b:	68 e2 c2 10 80       	push   $0x8010c2e2
80109590:	e8 77 6e ff ff       	call   8010040c <cprintf>
80109595:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109598:	8b 45 08             	mov    0x8(%ebp),%eax
8010959b:	83 c0 0e             	add    $0xe,%eax
8010959e:	83 ec 0c             	sub    $0xc,%esp
801095a1:	50                   	push   %eax
801095a2:	e8 e8 00 00 00       	call   8010968f <print_ipv4>
801095a7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095aa:	83 ec 0c             	sub    $0xc,%esp
801095ad:	68 e0 c2 10 80       	push   $0x8010c2e0
801095b2:	e8 55 6e ff ff       	call   8010040c <cprintf>
801095b7:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801095ba:	8b 45 08             	mov    0x8(%ebp),%eax
801095bd:	83 c0 08             	add    $0x8,%eax
801095c0:	83 ec 0c             	sub    $0xc,%esp
801095c3:	50                   	push   %eax
801095c4:	e8 18 01 00 00       	call   801096e1 <print_mac>
801095c9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095cc:	83 ec 0c             	sub    $0xc,%esp
801095cf:	68 e0 c2 10 80       	push   $0x8010c2e0
801095d4:	e8 33 6e ff ff       	call   8010040c <cprintf>
801095d9:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801095dc:	83 ec 0c             	sub    $0xc,%esp
801095df:	68 f9 c2 10 80       	push   $0x8010c2f9
801095e4:	e8 23 6e ff ff       	call   8010040c <cprintf>
801095e9:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801095ec:	8b 45 08             	mov    0x8(%ebp),%eax
801095ef:	83 c0 18             	add    $0x18,%eax
801095f2:	83 ec 0c             	sub    $0xc,%esp
801095f5:	50                   	push   %eax
801095f6:	e8 94 00 00 00       	call   8010968f <print_ipv4>
801095fb:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095fe:	83 ec 0c             	sub    $0xc,%esp
80109601:	68 e0 c2 10 80       	push   $0x8010c2e0
80109606:	e8 01 6e ff ff       	call   8010040c <cprintf>
8010960b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010960e:	8b 45 08             	mov    0x8(%ebp),%eax
80109611:	83 c0 12             	add    $0x12,%eax
80109614:	83 ec 0c             	sub    $0xc,%esp
80109617:	50                   	push   %eax
80109618:	e8 c4 00 00 00       	call   801096e1 <print_mac>
8010961d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109620:	83 ec 0c             	sub    $0xc,%esp
80109623:	68 e0 c2 10 80       	push   $0x8010c2e0
80109628:	e8 df 6d ff ff       	call   8010040c <cprintf>
8010962d:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109630:	83 ec 0c             	sub    $0xc,%esp
80109633:	68 10 c3 10 80       	push   $0x8010c310
80109638:	e8 cf 6d ff ff       	call   8010040c <cprintf>
8010963d:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109640:	8b 45 08             	mov    0x8(%ebp),%eax
80109643:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109647:	66 3d 00 01          	cmp    $0x100,%ax
8010964b:	75 12                	jne    8010965f <print_arp_info+0xe1>
8010964d:	83 ec 0c             	sub    $0xc,%esp
80109650:	68 1c c3 10 80       	push   $0x8010c31c
80109655:	e8 b2 6d ff ff       	call   8010040c <cprintf>
8010965a:	83 c4 10             	add    $0x10,%esp
8010965d:	eb 1d                	jmp    8010967c <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010965f:	8b 45 08             	mov    0x8(%ebp),%eax
80109662:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109666:	66 3d 00 02          	cmp    $0x200,%ax
8010966a:	75 10                	jne    8010967c <print_arp_info+0xfe>
    cprintf("Reply\n");
8010966c:	83 ec 0c             	sub    $0xc,%esp
8010966f:	68 25 c3 10 80       	push   $0x8010c325
80109674:	e8 93 6d ff ff       	call   8010040c <cprintf>
80109679:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010967c:	83 ec 0c             	sub    $0xc,%esp
8010967f:	68 e0 c2 10 80       	push   $0x8010c2e0
80109684:	e8 83 6d ff ff       	call   8010040c <cprintf>
80109689:	83 c4 10             	add    $0x10,%esp
}
8010968c:	90                   	nop
8010968d:	c9                   	leave
8010968e:	c3                   	ret

8010968f <print_ipv4>:

void print_ipv4(uchar *ip){
8010968f:	f3 0f 1e fb          	endbr32
80109693:	55                   	push   %ebp
80109694:	89 e5                	mov    %esp,%ebp
80109696:	53                   	push   %ebx
80109697:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010969a:	8b 45 08             	mov    0x8(%ebp),%eax
8010969d:	83 c0 03             	add    $0x3,%eax
801096a0:	0f b6 00             	movzbl (%eax),%eax
801096a3:	0f b6 d8             	movzbl %al,%ebx
801096a6:	8b 45 08             	mov    0x8(%ebp),%eax
801096a9:	83 c0 02             	add    $0x2,%eax
801096ac:	0f b6 00             	movzbl (%eax),%eax
801096af:	0f b6 c8             	movzbl %al,%ecx
801096b2:	8b 45 08             	mov    0x8(%ebp),%eax
801096b5:	83 c0 01             	add    $0x1,%eax
801096b8:	0f b6 00             	movzbl (%eax),%eax
801096bb:	0f b6 d0             	movzbl %al,%edx
801096be:	8b 45 08             	mov    0x8(%ebp),%eax
801096c1:	0f b6 00             	movzbl (%eax),%eax
801096c4:	0f b6 c0             	movzbl %al,%eax
801096c7:	83 ec 0c             	sub    $0xc,%esp
801096ca:	53                   	push   %ebx
801096cb:	51                   	push   %ecx
801096cc:	52                   	push   %edx
801096cd:	50                   	push   %eax
801096ce:	68 2c c3 10 80       	push   $0x8010c32c
801096d3:	e8 34 6d ff ff       	call   8010040c <cprintf>
801096d8:	83 c4 20             	add    $0x20,%esp
}
801096db:	90                   	nop
801096dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801096df:	c9                   	leave
801096e0:	c3                   	ret

801096e1 <print_mac>:

void print_mac(uchar *mac){
801096e1:	f3 0f 1e fb          	endbr32
801096e5:	55                   	push   %ebp
801096e6:	89 e5                	mov    %esp,%ebp
801096e8:	57                   	push   %edi
801096e9:	56                   	push   %esi
801096ea:	53                   	push   %ebx
801096eb:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801096ee:	8b 45 08             	mov    0x8(%ebp),%eax
801096f1:	83 c0 05             	add    $0x5,%eax
801096f4:	0f b6 00             	movzbl (%eax),%eax
801096f7:	0f b6 f8             	movzbl %al,%edi
801096fa:	8b 45 08             	mov    0x8(%ebp),%eax
801096fd:	83 c0 04             	add    $0x4,%eax
80109700:	0f b6 00             	movzbl (%eax),%eax
80109703:	0f b6 f0             	movzbl %al,%esi
80109706:	8b 45 08             	mov    0x8(%ebp),%eax
80109709:	83 c0 03             	add    $0x3,%eax
8010970c:	0f b6 00             	movzbl (%eax),%eax
8010970f:	0f b6 d8             	movzbl %al,%ebx
80109712:	8b 45 08             	mov    0x8(%ebp),%eax
80109715:	83 c0 02             	add    $0x2,%eax
80109718:	0f b6 00             	movzbl (%eax),%eax
8010971b:	0f b6 c8             	movzbl %al,%ecx
8010971e:	8b 45 08             	mov    0x8(%ebp),%eax
80109721:	83 c0 01             	add    $0x1,%eax
80109724:	0f b6 00             	movzbl (%eax),%eax
80109727:	0f b6 d0             	movzbl %al,%edx
8010972a:	8b 45 08             	mov    0x8(%ebp),%eax
8010972d:	0f b6 00             	movzbl (%eax),%eax
80109730:	0f b6 c0             	movzbl %al,%eax
80109733:	83 ec 04             	sub    $0x4,%esp
80109736:	57                   	push   %edi
80109737:	56                   	push   %esi
80109738:	53                   	push   %ebx
80109739:	51                   	push   %ecx
8010973a:	52                   	push   %edx
8010973b:	50                   	push   %eax
8010973c:	68 44 c3 10 80       	push   $0x8010c344
80109741:	e8 c6 6c ff ff       	call   8010040c <cprintf>
80109746:	83 c4 20             	add    $0x20,%esp
}
80109749:	90                   	nop
8010974a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010974d:	5b                   	pop    %ebx
8010974e:	5e                   	pop    %esi
8010974f:	5f                   	pop    %edi
80109750:	5d                   	pop    %ebp
80109751:	c3                   	ret

80109752 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109752:	f3 0f 1e fb          	endbr32
80109756:	55                   	push   %ebp
80109757:	89 e5                	mov    %esp,%ebp
80109759:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010975c:	8b 45 08             	mov    0x8(%ebp),%eax
8010975f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	83 c0 0e             	add    $0xe,%eax
80109768:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109772:	3c 08                	cmp    $0x8,%al
80109774:	75 1b                	jne    80109791 <eth_proc+0x3f>
80109776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109779:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010977d:	3c 06                	cmp    $0x6,%al
8010977f:	75 10                	jne    80109791 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109781:	83 ec 0c             	sub    $0xc,%esp
80109784:	ff 75 f0             	push   -0x10(%ebp)
80109787:	e8 d5 f7 ff ff       	call   80108f61 <arp_proc>
8010978c:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010978f:	eb 24                	jmp    801097b5 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109794:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109798:	3c 08                	cmp    $0x8,%al
8010979a:	75 19                	jne    801097b5 <eth_proc+0x63>
8010979c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801097a3:	84 c0                	test   %al,%al
801097a5:	75 0e                	jne    801097b5 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801097a7:	83 ec 0c             	sub    $0xc,%esp
801097aa:	ff 75 08             	push   0x8(%ebp)
801097ad:	e8 b3 00 00 00       	call   80109865 <ipv4_proc>
801097b2:	83 c4 10             	add    $0x10,%esp
}
801097b5:	90                   	nop
801097b6:	c9                   	leave
801097b7:	c3                   	ret

801097b8 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801097b8:	f3 0f 1e fb          	endbr32
801097bc:	55                   	push   %ebp
801097bd:	89 e5                	mov    %esp,%ebp
801097bf:	83 ec 04             	sub    $0x4,%esp
801097c2:	8b 45 08             	mov    0x8(%ebp),%eax
801097c5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801097c9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097cd:	c1 e0 08             	shl    $0x8,%eax
801097d0:	89 c2                	mov    %eax,%edx
801097d2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097d6:	66 c1 e8 08          	shr    $0x8,%ax
801097da:	01 d0                	add    %edx,%eax
}
801097dc:	c9                   	leave
801097dd:	c3                   	ret

801097de <H2N_ushort>:

ushort H2N_ushort(ushort value){
801097de:	f3 0f 1e fb          	endbr32
801097e2:	55                   	push   %ebp
801097e3:	89 e5                	mov    %esp,%ebp
801097e5:	83 ec 04             	sub    $0x4,%esp
801097e8:	8b 45 08             	mov    0x8(%ebp),%eax
801097eb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801097ef:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097f3:	c1 e0 08             	shl    $0x8,%eax
801097f6:	89 c2                	mov    %eax,%edx
801097f8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097fc:	66 c1 e8 08          	shr    $0x8,%ax
80109800:	01 d0                	add    %edx,%eax
}
80109802:	c9                   	leave
80109803:	c3                   	ret

80109804 <H2N_uint>:

uint H2N_uint(uint value){
80109804:	f3 0f 1e fb          	endbr32
80109808:	55                   	push   %ebp
80109809:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010980b:	8b 45 08             	mov    0x8(%ebp),%eax
8010980e:	c1 e0 18             	shl    $0x18,%eax
80109811:	25 00 00 00 0f       	and    $0xf000000,%eax
80109816:	89 c2                	mov    %eax,%edx
80109818:	8b 45 08             	mov    0x8(%ebp),%eax
8010981b:	c1 e0 08             	shl    $0x8,%eax
8010981e:	25 00 f0 00 00       	and    $0xf000,%eax
80109823:	09 c2                	or     %eax,%edx
80109825:	8b 45 08             	mov    0x8(%ebp),%eax
80109828:	c1 e8 08             	shr    $0x8,%eax
8010982b:	83 e0 0f             	and    $0xf,%eax
8010982e:	01 d0                	add    %edx,%eax
}
80109830:	5d                   	pop    %ebp
80109831:	c3                   	ret

80109832 <N2H_uint>:

uint N2H_uint(uint value){
80109832:	f3 0f 1e fb          	endbr32
80109836:	55                   	push   %ebp
80109837:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109839:	8b 45 08             	mov    0x8(%ebp),%eax
8010983c:	c1 e0 18             	shl    $0x18,%eax
8010983f:	89 c2                	mov    %eax,%edx
80109841:	8b 45 08             	mov    0x8(%ebp),%eax
80109844:	c1 e0 08             	shl    $0x8,%eax
80109847:	25 00 00 ff 00       	and    $0xff0000,%eax
8010984c:	01 c2                	add    %eax,%edx
8010984e:	8b 45 08             	mov    0x8(%ebp),%eax
80109851:	c1 e8 08             	shr    $0x8,%eax
80109854:	25 00 ff 00 00       	and    $0xff00,%eax
80109859:	01 c2                	add    %eax,%edx
8010985b:	8b 45 08             	mov    0x8(%ebp),%eax
8010985e:	c1 e8 18             	shr    $0x18,%eax
80109861:	01 d0                	add    %edx,%eax
}
80109863:	5d                   	pop    %ebp
80109864:	c3                   	ret

80109865 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109865:	f3 0f 1e fb          	endbr32
80109869:	55                   	push   %ebp
8010986a:	89 e5                	mov    %esp,%ebp
8010986c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010986f:	8b 45 08             	mov    0x8(%ebp),%eax
80109872:	83 c0 0e             	add    $0xe,%eax
80109875:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010987f:	0f b7 d0             	movzwl %ax,%edx
80109882:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109887:	39 c2                	cmp    %eax,%edx
80109889:	74 60                	je     801098eb <ipv4_proc+0x86>
8010988b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988e:	83 c0 0c             	add    $0xc,%eax
80109891:	83 ec 04             	sub    $0x4,%esp
80109894:	6a 04                	push   $0x4
80109896:	50                   	push   %eax
80109897:	68 e4 f4 10 80       	push   $0x8010f4e4
8010989c:	e8 40 b3 ff ff       	call   80104be1 <memcmp>
801098a1:	83 c4 10             	add    $0x10,%esp
801098a4:	85 c0                	test   %eax,%eax
801098a6:	74 43                	je     801098eb <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
801098a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ab:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801098af:	0f b7 c0             	movzwl %ax,%eax
801098b2:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801098b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ba:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801098be:	3c 01                	cmp    $0x1,%al
801098c0:	75 10                	jne    801098d2 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
801098c2:	83 ec 0c             	sub    $0xc,%esp
801098c5:	ff 75 08             	push   0x8(%ebp)
801098c8:	e8 a7 00 00 00       	call   80109974 <icmp_proc>
801098cd:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801098d0:	eb 19                	jmp    801098eb <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801098d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801098d9:	3c 06                	cmp    $0x6,%al
801098db:	75 0e                	jne    801098eb <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
801098dd:	83 ec 0c             	sub    $0xc,%esp
801098e0:	ff 75 08             	push   0x8(%ebp)
801098e3:	e8 c7 03 00 00       	call   80109caf <tcp_proc>
801098e8:	83 c4 10             	add    $0x10,%esp
}
801098eb:	90                   	nop
801098ec:	c9                   	leave
801098ed:	c3                   	ret

801098ee <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801098ee:	f3 0f 1e fb          	endbr32
801098f2:	55                   	push   %ebp
801098f3:	89 e5                	mov    %esp,%ebp
801098f5:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801098f8:	8b 45 08             	mov    0x8(%ebp),%eax
801098fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801098fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109901:	0f b6 00             	movzbl (%eax),%eax
80109904:	83 e0 0f             	and    $0xf,%eax
80109907:	01 c0                	add    %eax,%eax
80109909:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010990c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109913:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010991a:	eb 48                	jmp    80109964 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010991c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010991f:	01 c0                	add    %eax,%eax
80109921:	89 c2                	mov    %eax,%edx
80109923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109926:	01 d0                	add    %edx,%eax
80109928:	0f b6 00             	movzbl (%eax),%eax
8010992b:	0f b6 c0             	movzbl %al,%eax
8010992e:	c1 e0 08             	shl    $0x8,%eax
80109931:	89 c2                	mov    %eax,%edx
80109933:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109936:	01 c0                	add    %eax,%eax
80109938:	8d 48 01             	lea    0x1(%eax),%ecx
8010993b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010993e:	01 c8                	add    %ecx,%eax
80109940:	0f b6 00             	movzbl (%eax),%eax
80109943:	0f b6 c0             	movzbl %al,%eax
80109946:	01 d0                	add    %edx,%eax
80109948:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010994b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109952:	76 0c                	jbe    80109960 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109954:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109957:	0f b7 c0             	movzwl %ax,%eax
8010995a:	83 c0 01             	add    $0x1,%eax
8010995d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109960:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109964:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109968:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010996b:	7c af                	jl     8010991c <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010996d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109970:	f7 d0                	not    %eax
}
80109972:	c9                   	leave
80109973:	c3                   	ret

80109974 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109974:	f3 0f 1e fb          	endbr32
80109978:	55                   	push   %ebp
80109979:	89 e5                	mov    %esp,%ebp
8010997b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010997e:	8b 45 08             	mov    0x8(%ebp),%eax
80109981:	83 c0 0e             	add    $0xe,%eax
80109984:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998a:	0f b6 00             	movzbl (%eax),%eax
8010998d:	0f b6 c0             	movzbl %al,%eax
80109990:	83 e0 0f             	and    $0xf,%eax
80109993:	c1 e0 02             	shl    $0x2,%eax
80109996:	89 c2                	mov    %eax,%edx
80109998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999b:	01 d0                	add    %edx,%eax
8010999d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801099a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801099a7:	84 c0                	test   %al,%al
801099a9:	75 4f                	jne    801099fa <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801099ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ae:	0f b6 00             	movzbl (%eax),%eax
801099b1:	3c 08                	cmp    $0x8,%al
801099b3:	75 45                	jne    801099fa <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
801099b5:	e8 d8 8e ff ff       	call   80102892 <kalloc>
801099ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801099bd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801099c4:	83 ec 04             	sub    $0x4,%esp
801099c7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801099ca:	50                   	push   %eax
801099cb:	ff 75 ec             	push   -0x14(%ebp)
801099ce:	ff 75 08             	push   0x8(%ebp)
801099d1:	e8 7c 00 00 00       	call   80109a52 <icmp_reply_pkt_create>
801099d6:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801099d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099dc:	83 ec 08             	sub    $0x8,%esp
801099df:	50                   	push   %eax
801099e0:	ff 75 ec             	push   -0x14(%ebp)
801099e3:	e8 43 f4 ff ff       	call   80108e2b <i8254_send>
801099e8:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801099eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099ee:	83 ec 0c             	sub    $0xc,%esp
801099f1:	50                   	push   %eax
801099f2:	e8 fd 8d ff ff       	call   801027f4 <kfree>
801099f7:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801099fa:	90                   	nop
801099fb:	c9                   	leave
801099fc:	c3                   	ret

801099fd <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801099fd:	f3 0f 1e fb          	endbr32
80109a01:	55                   	push   %ebp
80109a02:	89 e5                	mov    %esp,%ebp
80109a04:	53                   	push   %ebx
80109a05:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109a08:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a0f:	0f b7 c0             	movzwl %ax,%eax
80109a12:	83 ec 0c             	sub    $0xc,%esp
80109a15:	50                   	push   %eax
80109a16:	e8 9d fd ff ff       	call   801097b8 <N2H_ushort>
80109a1b:	83 c4 10             	add    $0x10,%esp
80109a1e:	0f b7 d8             	movzwl %ax,%ebx
80109a21:	8b 45 08             	mov    0x8(%ebp),%eax
80109a24:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a28:	0f b7 c0             	movzwl %ax,%eax
80109a2b:	83 ec 0c             	sub    $0xc,%esp
80109a2e:	50                   	push   %eax
80109a2f:	e8 84 fd ff ff       	call   801097b8 <N2H_ushort>
80109a34:	83 c4 10             	add    $0x10,%esp
80109a37:	0f b7 c0             	movzwl %ax,%eax
80109a3a:	83 ec 04             	sub    $0x4,%esp
80109a3d:	53                   	push   %ebx
80109a3e:	50                   	push   %eax
80109a3f:	68 63 c3 10 80       	push   $0x8010c363
80109a44:	e8 c3 69 ff ff       	call   8010040c <cprintf>
80109a49:	83 c4 10             	add    $0x10,%esp
}
80109a4c:	90                   	nop
80109a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a50:	c9                   	leave
80109a51:	c3                   	ret

80109a52 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109a52:	f3 0f 1e fb          	endbr32
80109a56:	55                   	push   %ebp
80109a57:	89 e5                	mov    %esp,%ebp
80109a59:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109a62:	8b 45 08             	mov    0x8(%ebp),%eax
80109a65:	83 c0 0e             	add    $0xe,%eax
80109a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6e:	0f b6 00             	movzbl (%eax),%eax
80109a71:	0f b6 c0             	movzbl %al,%eax
80109a74:	83 e0 0f             	and    $0xf,%eax
80109a77:	c1 e0 02             	shl    $0x2,%eax
80109a7a:	89 c2                	mov    %eax,%edx
80109a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7f:	01 d0                	add    %edx,%eax
80109a81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109a84:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a87:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a8d:	83 c0 0e             	add    $0xe,%eax
80109a90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a96:	83 c0 14             	add    $0x14,%eax
80109a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80109a9f:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa8:	8d 50 06             	lea    0x6(%eax),%edx
80109aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aae:	83 ec 04             	sub    $0x4,%esp
80109ab1:	6a 06                	push   $0x6
80109ab3:	52                   	push   %edx
80109ab4:	50                   	push   %eax
80109ab5:	e8 83 b1 ff ff       	call   80104c3d <memmove>
80109aba:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109abd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ac0:	83 c0 06             	add    $0x6,%eax
80109ac3:	83 ec 04             	sub    $0x4,%esp
80109ac6:	6a 06                	push   $0x6
80109ac8:	68 68 d0 18 80       	push   $0x8018d068
80109acd:	50                   	push   %eax
80109ace:	e8 6a b1 ff ff       	call   80104c3d <memmove>
80109ad3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109ad6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ad9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109add:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ae0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ae4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ae7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109aed:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109af1:	83 ec 0c             	sub    $0xc,%esp
80109af4:	6a 54                	push   $0x54
80109af6:	e8 e3 fc ff ff       	call   801097de <H2N_ushort>
80109afb:	83 c4 10             	add    $0x10,%esp
80109afe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b01:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b05:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109b0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b0f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b13:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109b1a:	83 c0 01             	add    $0x1,%eax
80109b1d:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109b23:	83 ec 0c             	sub    $0xc,%esp
80109b26:	68 00 40 00 00       	push   $0x4000
80109b2b:	e8 ae fc ff ff       	call   801097de <H2N_ushort>
80109b30:	83 c4 10             	add    $0x10,%esp
80109b33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b36:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109b3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b3d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b44:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109b48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b4b:	83 c0 0c             	add    $0xc,%eax
80109b4e:	83 ec 04             	sub    $0x4,%esp
80109b51:	6a 04                	push   $0x4
80109b53:	68 e4 f4 10 80       	push   $0x8010f4e4
80109b58:	50                   	push   %eax
80109b59:	e8 df b0 ff ff       	call   80104c3d <memmove>
80109b5e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b64:	8d 50 0c             	lea    0xc(%eax),%edx
80109b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6a:	83 c0 10             	add    $0x10,%eax
80109b6d:	83 ec 04             	sub    $0x4,%esp
80109b70:	6a 04                	push   $0x4
80109b72:	52                   	push   %edx
80109b73:	50                   	push   %eax
80109b74:	e8 c4 b0 ff ff       	call   80104c3d <memmove>
80109b79:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b7f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b88:	83 ec 0c             	sub    $0xc,%esp
80109b8b:	50                   	push   %eax
80109b8c:	e8 5d fd ff ff       	call   801098ee <ipv4_chksum>
80109b91:	83 c4 10             	add    $0x10,%esp
80109b94:	0f b7 c0             	movzwl %ax,%eax
80109b97:	83 ec 0c             	sub    $0xc,%esp
80109b9a:	50                   	push   %eax
80109b9b:	e8 3e fc ff ff       	call   801097de <H2N_ushort>
80109ba0:	83 c4 10             	add    $0x10,%esp
80109ba3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ba6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109baa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bad:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109bb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bb3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bba:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109bbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bc1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bc8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109bcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bcf:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109bd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bd6:	8d 50 08             	lea    0x8(%eax),%edx
80109bd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bdc:	83 c0 08             	add    $0x8,%eax
80109bdf:	83 ec 04             	sub    $0x4,%esp
80109be2:	6a 08                	push   $0x8
80109be4:	52                   	push   %edx
80109be5:	50                   	push   %eax
80109be6:	e8 52 b0 ff ff       	call   80104c3d <memmove>
80109beb:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bf1:	8d 50 10             	lea    0x10(%eax),%edx
80109bf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bf7:	83 c0 10             	add    $0x10,%eax
80109bfa:	83 ec 04             	sub    $0x4,%esp
80109bfd:	6a 30                	push   $0x30
80109bff:	52                   	push   %edx
80109c00:	50                   	push   %eax
80109c01:	e8 37 b0 ff ff       	call   80104c3d <memmove>
80109c06:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109c09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c0c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109c12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c15:	83 ec 0c             	sub    $0xc,%esp
80109c18:	50                   	push   %eax
80109c19:	e8 1c 00 00 00       	call   80109c3a <icmp_chksum>
80109c1e:	83 c4 10             	add    $0x10,%esp
80109c21:	0f b7 c0             	movzwl %ax,%eax
80109c24:	83 ec 0c             	sub    $0xc,%esp
80109c27:	50                   	push   %eax
80109c28:	e8 b1 fb ff ff       	call   801097de <H2N_ushort>
80109c2d:	83 c4 10             	add    $0x10,%esp
80109c30:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c33:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109c37:	90                   	nop
80109c38:	c9                   	leave
80109c39:	c3                   	ret

80109c3a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109c3a:	f3 0f 1e fb          	endbr32
80109c3e:	55                   	push   %ebp
80109c3f:	89 e5                	mov    %esp,%ebp
80109c41:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109c44:	8b 45 08             	mov    0x8(%ebp),%eax
80109c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109c4a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109c51:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c58:	eb 48                	jmp    80109ca2 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c5d:	01 c0                	add    %eax,%eax
80109c5f:	89 c2                	mov    %eax,%edx
80109c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c64:	01 d0                	add    %edx,%eax
80109c66:	0f b6 00             	movzbl (%eax),%eax
80109c69:	0f b6 c0             	movzbl %al,%eax
80109c6c:	c1 e0 08             	shl    $0x8,%eax
80109c6f:	89 c2                	mov    %eax,%edx
80109c71:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c74:	01 c0                	add    %eax,%eax
80109c76:	8d 48 01             	lea    0x1(%eax),%ecx
80109c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c7c:	01 c8                	add    %ecx,%eax
80109c7e:	0f b6 00             	movzbl (%eax),%eax
80109c81:	0f b6 c0             	movzbl %al,%eax
80109c84:	01 d0                	add    %edx,%eax
80109c86:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c89:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c90:	76 0c                	jbe    80109c9e <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c95:	0f b7 c0             	movzwl %ax,%eax
80109c98:	83 c0 01             	add    $0x1,%eax
80109c9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109c9e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ca2:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ca6:	7e b2                	jle    80109c5a <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cab:	f7 d0                	not    %eax
}
80109cad:	c9                   	leave
80109cae:	c3                   	ret

80109caf <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109caf:	f3 0f 1e fb          	endbr32
80109cb3:	55                   	push   %ebp
80109cb4:	89 e5                	mov    %esp,%ebp
80109cb6:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbc:	83 c0 0e             	add    $0xe,%eax
80109cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc5:	0f b6 00             	movzbl (%eax),%eax
80109cc8:	0f b6 c0             	movzbl %al,%eax
80109ccb:	83 e0 0f             	and    $0xf,%eax
80109cce:	c1 e0 02             	shl    $0x2,%eax
80109cd1:	89 c2                	mov    %eax,%edx
80109cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd6:	01 d0                	add    %edx,%eax
80109cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cde:	83 c0 14             	add    $0x14,%eax
80109ce1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109ce4:	e8 a9 8b ff ff       	call   80102892 <kalloc>
80109ce9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109cec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cfa:	0f b6 c0             	movzbl %al,%eax
80109cfd:	83 e0 02             	and    $0x2,%eax
80109d00:	85 c0                	test   %eax,%eax
80109d02:	74 3d                	je     80109d41 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109d04:	83 ec 0c             	sub    $0xc,%esp
80109d07:	6a 00                	push   $0x0
80109d09:	6a 12                	push   $0x12
80109d0b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d0e:	50                   	push   %eax
80109d0f:	ff 75 e8             	push   -0x18(%ebp)
80109d12:	ff 75 08             	push   0x8(%ebp)
80109d15:	e8 a2 01 00 00       	call   80109ebc <tcp_pkt_create>
80109d1a:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109d1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d20:	83 ec 08             	sub    $0x8,%esp
80109d23:	50                   	push   %eax
80109d24:	ff 75 e8             	push   -0x18(%ebp)
80109d27:	e8 ff f0 ff ff       	call   80108e2b <i8254_send>
80109d2c:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109d2f:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109d34:	83 c0 01             	add    $0x1,%eax
80109d37:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109d3c:	e9 69 01 00 00       	jmp    80109eaa <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d44:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d48:	3c 18                	cmp    $0x18,%al
80109d4a:	0f 85 10 01 00 00    	jne    80109e60 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109d50:	83 ec 04             	sub    $0x4,%esp
80109d53:	6a 03                	push   $0x3
80109d55:	68 7e c3 10 80       	push   $0x8010c37e
80109d5a:	ff 75 ec             	push   -0x14(%ebp)
80109d5d:	e8 7f ae ff ff       	call   80104be1 <memcmp>
80109d62:	83 c4 10             	add    $0x10,%esp
80109d65:	85 c0                	test   %eax,%eax
80109d67:	74 74                	je     80109ddd <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109d69:	83 ec 0c             	sub    $0xc,%esp
80109d6c:	68 82 c3 10 80       	push   $0x8010c382
80109d71:	e8 96 66 ff ff       	call   8010040c <cprintf>
80109d76:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109d79:	83 ec 0c             	sub    $0xc,%esp
80109d7c:	6a 00                	push   $0x0
80109d7e:	6a 10                	push   $0x10
80109d80:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d83:	50                   	push   %eax
80109d84:	ff 75 e8             	push   -0x18(%ebp)
80109d87:	ff 75 08             	push   0x8(%ebp)
80109d8a:	e8 2d 01 00 00       	call   80109ebc <tcp_pkt_create>
80109d8f:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d95:	83 ec 08             	sub    $0x8,%esp
80109d98:	50                   	push   %eax
80109d99:	ff 75 e8             	push   -0x18(%ebp)
80109d9c:	e8 8a f0 ff ff       	call   80108e2b <i8254_send>
80109da1:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109da4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109da7:	83 c0 36             	add    $0x36,%eax
80109daa:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109dad:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109db0:	50                   	push   %eax
80109db1:	ff 75 e0             	push   -0x20(%ebp)
80109db4:	6a 00                	push   $0x0
80109db6:	6a 00                	push   $0x0
80109db8:	e8 66 04 00 00       	call   8010a223 <http_proc>
80109dbd:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109dc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109dc3:	83 ec 0c             	sub    $0xc,%esp
80109dc6:	50                   	push   %eax
80109dc7:	6a 18                	push   $0x18
80109dc9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109dcc:	50                   	push   %eax
80109dcd:	ff 75 e8             	push   -0x18(%ebp)
80109dd0:	ff 75 08             	push   0x8(%ebp)
80109dd3:	e8 e4 00 00 00       	call   80109ebc <tcp_pkt_create>
80109dd8:	83 c4 20             	add    $0x20,%esp
80109ddb:	eb 62                	jmp    80109e3f <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ddd:	83 ec 0c             	sub    $0xc,%esp
80109de0:	6a 00                	push   $0x0
80109de2:	6a 10                	push   $0x10
80109de4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109de7:	50                   	push   %eax
80109de8:	ff 75 e8             	push   -0x18(%ebp)
80109deb:	ff 75 08             	push   0x8(%ebp)
80109dee:	e8 c9 00 00 00       	call   80109ebc <tcp_pkt_create>
80109df3:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109df6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109df9:	83 ec 08             	sub    $0x8,%esp
80109dfc:	50                   	push   %eax
80109dfd:	ff 75 e8             	push   -0x18(%ebp)
80109e00:	e8 26 f0 ff ff       	call   80108e2b <i8254_send>
80109e05:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e0b:	83 c0 36             	add    $0x36,%eax
80109e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e11:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e14:	50                   	push   %eax
80109e15:	ff 75 e4             	push   -0x1c(%ebp)
80109e18:	6a 00                	push   $0x0
80109e1a:	6a 00                	push   $0x0
80109e1c:	e8 02 04 00 00       	call   8010a223 <http_proc>
80109e21:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109e27:	83 ec 0c             	sub    $0xc,%esp
80109e2a:	50                   	push   %eax
80109e2b:	6a 18                	push   $0x18
80109e2d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e30:	50                   	push   %eax
80109e31:	ff 75 e8             	push   -0x18(%ebp)
80109e34:	ff 75 08             	push   0x8(%ebp)
80109e37:	e8 80 00 00 00       	call   80109ebc <tcp_pkt_create>
80109e3c:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109e3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e42:	83 ec 08             	sub    $0x8,%esp
80109e45:	50                   	push   %eax
80109e46:	ff 75 e8             	push   -0x18(%ebp)
80109e49:	e8 dd ef ff ff       	call   80108e2b <i8254_send>
80109e4e:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e51:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109e56:	83 c0 01             	add    $0x1,%eax
80109e59:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109e5e:	eb 4a                	jmp    80109eaa <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e63:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e67:	3c 10                	cmp    $0x10,%al
80109e69:	75 3f                	jne    80109eaa <tcp_proc+0x1fb>
    if(fin_flag == 1){
80109e6b:	a1 48 d3 18 80       	mov    0x8018d348,%eax
80109e70:	83 f8 01             	cmp    $0x1,%eax
80109e73:	75 35                	jne    80109eaa <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109e75:	83 ec 0c             	sub    $0xc,%esp
80109e78:	6a 00                	push   $0x0
80109e7a:	6a 01                	push   $0x1
80109e7c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e7f:	50                   	push   %eax
80109e80:	ff 75 e8             	push   -0x18(%ebp)
80109e83:	ff 75 08             	push   0x8(%ebp)
80109e86:	e8 31 00 00 00       	call   80109ebc <tcp_pkt_create>
80109e8b:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e91:	83 ec 08             	sub    $0x8,%esp
80109e94:	50                   	push   %eax
80109e95:	ff 75 e8             	push   -0x18(%ebp)
80109e98:	e8 8e ef ff ff       	call   80108e2b <i8254_send>
80109e9d:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109ea0:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
80109ea7:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109eaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ead:	83 ec 0c             	sub    $0xc,%esp
80109eb0:	50                   	push   %eax
80109eb1:	e8 3e 89 ff ff       	call   801027f4 <kfree>
80109eb6:	83 c4 10             	add    $0x10,%esp
}
80109eb9:	90                   	nop
80109eba:	c9                   	leave
80109ebb:	c3                   	ret

80109ebc <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ebc:	f3 0f 1e fb          	endbr32
80109ec0:	55                   	push   %ebp
80109ec1:	89 e5                	mov    %esp,%ebp
80109ec3:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80109ecf:	83 c0 0e             	add    $0xe,%eax
80109ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed8:	0f b6 00             	movzbl (%eax),%eax
80109edb:	0f b6 c0             	movzbl %al,%eax
80109ede:	83 e0 0f             	and    $0xf,%eax
80109ee1:	c1 e0 02             	shl    $0x2,%eax
80109ee4:	89 c2                	mov    %eax,%edx
80109ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ee9:	01 d0                	add    %edx,%eax
80109eeb:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109eee:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ef1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ef7:	83 c0 0e             	add    $0xe,%eax
80109efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f00:	83 c0 14             	add    $0x14,%eax
80109f03:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109f06:	8b 45 18             	mov    0x18(%ebp),%eax
80109f09:	8d 50 36             	lea    0x36(%eax),%edx
80109f0c:	8b 45 10             	mov    0x10(%ebp),%eax
80109f0f:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f14:	8d 50 06             	lea    0x6(%eax),%edx
80109f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f1a:	83 ec 04             	sub    $0x4,%esp
80109f1d:	6a 06                	push   $0x6
80109f1f:	52                   	push   %edx
80109f20:	50                   	push   %eax
80109f21:	e8 17 ad ff ff       	call   80104c3d <memmove>
80109f26:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109f29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f2c:	83 c0 06             	add    $0x6,%eax
80109f2f:	83 ec 04             	sub    $0x4,%esp
80109f32:	6a 06                	push   $0x6
80109f34:	68 68 d0 18 80       	push   $0x8018d068
80109f39:	50                   	push   %eax
80109f3a:	e8 fe ac ff ff       	call   80104c3d <memmove>
80109f3f:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109f42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f45:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109f49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f4c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f53:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f59:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109f5d:	8b 45 18             	mov    0x18(%ebp),%eax
80109f60:	83 c0 28             	add    $0x28,%eax
80109f63:	0f b7 c0             	movzwl %ax,%eax
80109f66:	83 ec 0c             	sub    $0xc,%esp
80109f69:	50                   	push   %eax
80109f6a:	e8 6f f8 ff ff       	call   801097de <H2N_ushort>
80109f6f:	83 c4 10             	add    $0x10,%esp
80109f72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f75:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109f79:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f83:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109f87:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109f8e:	83 c0 01             	add    $0x1,%eax
80109f91:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
80109f97:	83 ec 0c             	sub    $0xc,%esp
80109f9a:	6a 00                	push   $0x0
80109f9c:	e8 3d f8 ff ff       	call   801097de <H2N_ushort>
80109fa1:	83 c4 10             	add    $0x10,%esp
80109fa4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109fa7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109fab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fae:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fb5:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fbc:	83 c0 0c             	add    $0xc,%eax
80109fbf:	83 ec 04             	sub    $0x4,%esp
80109fc2:	6a 04                	push   $0x4
80109fc4:	68 e4 f4 10 80       	push   $0x8010f4e4
80109fc9:	50                   	push   %eax
80109fca:	e8 6e ac ff ff       	call   80104c3d <memmove>
80109fcf:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd5:	8d 50 0c             	lea    0xc(%eax),%edx
80109fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fdb:	83 c0 10             	add    $0x10,%eax
80109fde:	83 ec 04             	sub    $0x4,%esp
80109fe1:	6a 04                	push   $0x4
80109fe3:	52                   	push   %edx
80109fe4:	50                   	push   %eax
80109fe5:	e8 53 ac ff ff       	call   80104c3d <memmove>
80109fea:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ff0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ff9:	83 ec 0c             	sub    $0xc,%esp
80109ffc:	50                   	push   %eax
80109ffd:	e8 ec f8 ff ff       	call   801098ee <ipv4_chksum>
8010a002:	83 c4 10             	add    $0x10,%esp
8010a005:	0f b7 c0             	movzwl %ax,%eax
8010a008:	83 ec 0c             	sub    $0xc,%esp
8010a00b:	50                   	push   %eax
8010a00c:	e8 cd f7 ff ff       	call   801097de <H2N_ushort>
8010a011:	83 c4 10             	add    $0x10,%esp
8010a014:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a017:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a01b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a01e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a022:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a025:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a02b:	0f b7 10             	movzwl (%eax),%edx
8010a02e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a031:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a035:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a03a:	83 ec 0c             	sub    $0xc,%esp
8010a03d:	50                   	push   %eax
8010a03e:	e8 c1 f7 ff ff       	call   80109804 <H2N_uint>
8010a043:	83 c4 10             	add    $0x10,%esp
8010a046:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a049:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a04c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a04f:	8b 40 04             	mov    0x4(%eax),%eax
8010a052:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a058:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a05b:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a05e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a061:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a065:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a068:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a06c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a06f:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a073:	8b 45 14             	mov    0x14(%ebp),%eax
8010a076:	89 c2                	mov    %eax,%edx
8010a078:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a07b:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a07e:	83 ec 0c             	sub    $0xc,%esp
8010a081:	68 90 38 00 00       	push   $0x3890
8010a086:	e8 53 f7 ff ff       	call   801097de <H2N_ushort>
8010a08b:	83 c4 10             	add    $0x10,%esp
8010a08e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a091:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a095:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a098:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a09e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0a1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a0a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0aa:	83 ec 0c             	sub    $0xc,%esp
8010a0ad:	50                   	push   %eax
8010a0ae:	e8 1f 00 00 00       	call   8010a0d2 <tcp_chksum>
8010a0b3:	83 c4 10             	add    $0x10,%esp
8010a0b6:	83 c0 08             	add    $0x8,%eax
8010a0b9:	0f b7 c0             	movzwl %ax,%eax
8010a0bc:	83 ec 0c             	sub    $0xc,%esp
8010a0bf:	50                   	push   %eax
8010a0c0:	e8 19 f7 ff ff       	call   801097de <H2N_ushort>
8010a0c5:	83 c4 10             	add    $0x10,%esp
8010a0c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0cb:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a0cf:	90                   	nop
8010a0d0:	c9                   	leave
8010a0d1:	c3                   	ret

8010a0d2 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a0d2:	f3 0f 1e fb          	endbr32
8010a0d6:	55                   	push   %ebp
8010a0d7:	89 e5                	mov    %esp,%ebp
8010a0d9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a0dc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a0e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e5:	83 c0 14             	add    $0x14,%eax
8010a0e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a0eb:	83 ec 04             	sub    $0x4,%esp
8010a0ee:	6a 04                	push   $0x4
8010a0f0:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a0f5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0f8:	50                   	push   %eax
8010a0f9:	e8 3f ab ff ff       	call   80104c3d <memmove>
8010a0fe:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a101:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a104:	83 c0 0c             	add    $0xc,%eax
8010a107:	83 ec 04             	sub    $0x4,%esp
8010a10a:	6a 04                	push   $0x4
8010a10c:	50                   	push   %eax
8010a10d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a110:	83 c0 04             	add    $0x4,%eax
8010a113:	50                   	push   %eax
8010a114:	e8 24 ab ff ff       	call   80104c3d <memmove>
8010a119:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a11c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a120:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a124:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a127:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a12b:	0f b7 c0             	movzwl %ax,%eax
8010a12e:	83 ec 0c             	sub    $0xc,%esp
8010a131:	50                   	push   %eax
8010a132:	e8 81 f6 ff ff       	call   801097b8 <N2H_ushort>
8010a137:	83 c4 10             	add    $0x10,%esp
8010a13a:	83 e8 14             	sub    $0x14,%eax
8010a13d:	0f b7 c0             	movzwl %ax,%eax
8010a140:	83 ec 0c             	sub    $0xc,%esp
8010a143:	50                   	push   %eax
8010a144:	e8 95 f6 ff ff       	call   801097de <H2N_ushort>
8010a149:	83 c4 10             	add    $0x10,%esp
8010a14c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a150:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a157:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a15a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a15d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a164:	eb 33                	jmp    8010a199 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a166:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a169:	01 c0                	add    %eax,%eax
8010a16b:	89 c2                	mov    %eax,%edx
8010a16d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a170:	01 d0                	add    %edx,%eax
8010a172:	0f b6 00             	movzbl (%eax),%eax
8010a175:	0f b6 c0             	movzbl %al,%eax
8010a178:	c1 e0 08             	shl    $0x8,%eax
8010a17b:	89 c2                	mov    %eax,%edx
8010a17d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a180:	01 c0                	add    %eax,%eax
8010a182:	8d 48 01             	lea    0x1(%eax),%ecx
8010a185:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a188:	01 c8                	add    %ecx,%eax
8010a18a:	0f b6 00             	movzbl (%eax),%eax
8010a18d:	0f b6 c0             	movzbl %al,%eax
8010a190:	01 d0                	add    %edx,%eax
8010a192:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a195:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a199:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a19d:	7e c7                	jle    8010a166 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a19f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a1a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a1ac:	eb 33                	jmp    8010a1e1 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1b1:	01 c0                	add    %eax,%eax
8010a1b3:	89 c2                	mov    %eax,%edx
8010a1b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1b8:	01 d0                	add    %edx,%eax
8010a1ba:	0f b6 00             	movzbl (%eax),%eax
8010a1bd:	0f b6 c0             	movzbl %al,%eax
8010a1c0:	c1 e0 08             	shl    $0x8,%eax
8010a1c3:	89 c2                	mov    %eax,%edx
8010a1c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1c8:	01 c0                	add    %eax,%eax
8010a1ca:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1d0:	01 c8                	add    %ecx,%eax
8010a1d2:	0f b6 00             	movzbl (%eax),%eax
8010a1d5:	0f b6 c0             	movzbl %al,%eax
8010a1d8:	01 d0                	add    %edx,%eax
8010a1da:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a1dd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a1e1:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a1e5:	0f b7 c0             	movzwl %ax,%eax
8010a1e8:	83 ec 0c             	sub    $0xc,%esp
8010a1eb:	50                   	push   %eax
8010a1ec:	e8 c7 f5 ff ff       	call   801097b8 <N2H_ushort>
8010a1f1:	83 c4 10             	add    $0x10,%esp
8010a1f4:	66 d1 e8             	shr    $1,%ax
8010a1f7:	0f b7 c0             	movzwl %ax,%eax
8010a1fa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a1fd:	7c af                	jl     8010a1ae <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a1ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a202:	c1 e8 10             	shr    $0x10,%eax
8010a205:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a20b:	f7 d0                	not    %eax
}
8010a20d:	c9                   	leave
8010a20e:	c3                   	ret

8010a20f <tcp_fin>:

void tcp_fin(){
8010a20f:	f3 0f 1e fb          	endbr32
8010a213:	55                   	push   %ebp
8010a214:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a216:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a21d:	00 00 00 
}
8010a220:	90                   	nop
8010a221:	5d                   	pop    %ebp
8010a222:	c3                   	ret

8010a223 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a223:	f3 0f 1e fb          	endbr32
8010a227:	55                   	push   %ebp
8010a228:	89 e5                	mov    %esp,%ebp
8010a22a:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a22d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a230:	83 ec 04             	sub    $0x4,%esp
8010a233:	6a 00                	push   $0x0
8010a235:	68 8b c3 10 80       	push   $0x8010c38b
8010a23a:	50                   	push   %eax
8010a23b:	e8 65 00 00 00       	call   8010a2a5 <http_strcpy>
8010a240:	83 c4 10             	add    $0x10,%esp
8010a243:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a246:	8b 45 10             	mov    0x10(%ebp),%eax
8010a249:	83 ec 04             	sub    $0x4,%esp
8010a24c:	ff 75 f4             	push   -0xc(%ebp)
8010a24f:	68 9e c3 10 80       	push   $0x8010c39e
8010a254:	50                   	push   %eax
8010a255:	e8 4b 00 00 00       	call   8010a2a5 <http_strcpy>
8010a25a:	83 c4 10             	add    $0x10,%esp
8010a25d:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a260:	8b 45 10             	mov    0x10(%ebp),%eax
8010a263:	83 ec 04             	sub    $0x4,%esp
8010a266:	ff 75 f4             	push   -0xc(%ebp)
8010a269:	68 b9 c3 10 80       	push   $0x8010c3b9
8010a26e:	50                   	push   %eax
8010a26f:	e8 31 00 00 00       	call   8010a2a5 <http_strcpy>
8010a274:	83 c4 10             	add    $0x10,%esp
8010a277:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a27a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a27d:	83 e0 01             	and    $0x1,%eax
8010a280:	85 c0                	test   %eax,%eax
8010a282:	74 11                	je     8010a295 <http_proc+0x72>
    char *payload = (char *)send;
8010a284:	8b 45 10             	mov    0x10(%ebp),%eax
8010a287:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a28a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a28d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a290:	01 d0                	add    %edx,%eax
8010a292:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a295:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a298:	8b 45 14             	mov    0x14(%ebp),%eax
8010a29b:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a29d:	e8 6d ff ff ff       	call   8010a20f <tcp_fin>
}
8010a2a2:	90                   	nop
8010a2a3:	c9                   	leave
8010a2a4:	c3                   	ret

8010a2a5 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a2a5:	f3 0f 1e fb          	endbr32
8010a2a9:	55                   	push   %ebp
8010a2aa:	89 e5                	mov    %esp,%ebp
8010a2ac:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a2af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a2b6:	eb 20                	jmp    8010a2d8 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a2b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a2bb:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a2be:	01 d0                	add    %edx,%eax
8010a2c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a2c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a2c6:	01 ca                	add    %ecx,%edx
8010a2c8:	89 d1                	mov    %edx,%ecx
8010a2ca:	8b 55 08             	mov    0x8(%ebp),%edx
8010a2cd:	01 ca                	add    %ecx,%edx
8010a2cf:	0f b6 00             	movzbl (%eax),%eax
8010a2d2:	88 02                	mov    %al,(%edx)
    i++;
8010a2d4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a2d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a2db:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a2de:	01 d0                	add    %edx,%eax
8010a2e0:	0f b6 00             	movzbl (%eax),%eax
8010a2e3:	84 c0                	test   %al,%al
8010a2e5:	75 d1                	jne    8010a2b8 <http_strcpy+0x13>
  }
  return i;
8010a2e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a2ea:	c9                   	leave
8010a2eb:	c3                   	ret

8010a2ec <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a2ec:	f3 0f 1e fb          	endbr32
8010a2f0:	55                   	push   %ebp
8010a2f1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a2f3:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a2fa:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a2fd:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a302:	c1 e8 09             	shr    $0x9,%eax
8010a305:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a30a:	90                   	nop
8010a30b:	5d                   	pop    %ebp
8010a30c:	c3                   	ret

8010a30d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a30d:	f3 0f 1e fb          	endbr32
8010a311:	55                   	push   %ebp
8010a312:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a314:	90                   	nop
8010a315:	5d                   	pop    %ebp
8010a316:	c3                   	ret

8010a317 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a317:	f3 0f 1e fb          	endbr32
8010a31b:	55                   	push   %ebp
8010a31c:	89 e5                	mov    %esp,%ebp
8010a31e:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a321:	8b 45 08             	mov    0x8(%ebp),%eax
8010a324:	83 c0 0c             	add    $0xc,%eax
8010a327:	83 ec 0c             	sub    $0xc,%esp
8010a32a:	50                   	push   %eax
8010a32b:	e8 1e a5 ff ff       	call   8010484e <holdingsleep>
8010a330:	83 c4 10             	add    $0x10,%esp
8010a333:	85 c0                	test   %eax,%eax
8010a335:	75 0d                	jne    8010a344 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a337:	83 ec 0c             	sub    $0xc,%esp
8010a33a:	68 ca c3 10 80       	push   $0x8010c3ca
8010a33f:	e8 81 62 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a344:	8b 45 08             	mov    0x8(%ebp),%eax
8010a347:	8b 00                	mov    (%eax),%eax
8010a349:	83 e0 06             	and    $0x6,%eax
8010a34c:	83 f8 02             	cmp    $0x2,%eax
8010a34f:	75 0d                	jne    8010a35e <iderw+0x47>
    panic("iderw: nothing to do");
8010a351:	83 ec 0c             	sub    $0xc,%esp
8010a354:	68 e0 c3 10 80       	push   $0x8010c3e0
8010a359:	e8 67 62 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a35e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a361:	8b 40 04             	mov    0x4(%eax),%eax
8010a364:	83 f8 01             	cmp    $0x1,%eax
8010a367:	74 0d                	je     8010a376 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a369:	83 ec 0c             	sub    $0xc,%esp
8010a36c:	68 f5 c3 10 80       	push   $0x8010c3f5
8010a371:	e8 4f 62 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a376:	8b 45 08             	mov    0x8(%ebp),%eax
8010a379:	8b 40 08             	mov    0x8(%eax),%eax
8010a37c:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a382:	39 d0                	cmp    %edx,%eax
8010a384:	72 0d                	jb     8010a393 <iderw+0x7c>
    panic("iderw: block out of range");
8010a386:	83 ec 0c             	sub    $0xc,%esp
8010a389:	68 13 c4 10 80       	push   $0x8010c413
8010a38e:	e8 32 62 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a393:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a399:	8b 45 08             	mov    0x8(%ebp),%eax
8010a39c:	8b 40 08             	mov    0x8(%eax),%eax
8010a39f:	c1 e0 09             	shl    $0x9,%eax
8010a3a2:	01 d0                	add    %edx,%eax
8010a3a4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a3a7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3aa:	8b 00                	mov    (%eax),%eax
8010a3ac:	83 e0 04             	and    $0x4,%eax
8010a3af:	85 c0                	test   %eax,%eax
8010a3b1:	74 2b                	je     8010a3de <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a3b3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b6:	8b 00                	mov    (%eax),%eax
8010a3b8:	83 e0 fb             	and    $0xfffffffb,%eax
8010a3bb:	89 c2                	mov    %eax,%edx
8010a3bd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c0:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a3c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c5:	83 c0 5c             	add    $0x5c,%eax
8010a3c8:	83 ec 04             	sub    $0x4,%esp
8010a3cb:	68 00 02 00 00       	push   $0x200
8010a3d0:	50                   	push   %eax
8010a3d1:	ff 75 f4             	push   -0xc(%ebp)
8010a3d4:	e8 64 a8 ff ff       	call   80104c3d <memmove>
8010a3d9:	83 c4 10             	add    $0x10,%esp
8010a3dc:	eb 1a                	jmp    8010a3f8 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a3de:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3e1:	83 c0 5c             	add    $0x5c,%eax
8010a3e4:	83 ec 04             	sub    $0x4,%esp
8010a3e7:	68 00 02 00 00       	push   $0x200
8010a3ec:	ff 75 f4             	push   -0xc(%ebp)
8010a3ef:	50                   	push   %eax
8010a3f0:	e8 48 a8 ff ff       	call   80104c3d <memmove>
8010a3f5:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a3f8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3fb:	8b 00                	mov    (%eax),%eax
8010a3fd:	83 c8 02             	or     $0x2,%eax
8010a400:	89 c2                	mov    %eax,%edx
8010a402:	8b 45 08             	mov    0x8(%ebp),%eax
8010a405:	89 10                	mov    %edx,(%eax)
}
8010a407:	90                   	nop
8010a408:	c9                   	leave
8010a409:	c3                   	ret
