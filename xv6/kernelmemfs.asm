
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
8010005f:	ba 1c 35 10 80       	mov    $0x8010351c,%edx
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
80100073:	68 80 a7 10 80       	push   $0x8010a780
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 03 4a 00 00       	call   80104a85 <initlock>
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
801000c1:	68 87 a7 10 80       	push   $0x8010a787
801000c6:	50                   	push   %eax
801000c7:	e8 4c 48 00 00       	call   80104918 <initsleeplock>
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
80100109:	e8 9d 49 00 00       	call   80104aab <acquire>
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
80100148:	e8 d0 49 00 00       	call   80104b1d <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 f9 47 00 00       	call   80104958 <acquiresleep>
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
801001c9:	e8 4f 49 00 00       	call   80104b1d <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 78 47 00 00       	call   80104958 <acquiresleep>
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
801001fd:	68 8e a7 10 80       	push   $0x8010a78e
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
80100239:	e8 3c a4 00 00       	call   8010a67a <iderw>
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
8010025a:	e8 b3 47 00 00       	call   80104a12 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 9f a7 10 80       	push   $0x8010a79f
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
80100288:	e8 ed a3 00 00       	call   8010a67a <iderw>
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
801002a7:	e8 66 47 00 00       	call   80104a12 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 a6 a7 10 80       	push   $0x8010a7a6
801002bb:	e8 1e 03 00 00       	call   801005de <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 f1 46 00 00       	call   801049c0 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 cc 47 00 00       	call   80104aab <acquire>
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
8010034a:	e8 ce 47 00 00       	call   80104b1d <release>
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
8010042c:	e8 7a 46 00 00       	call   80104aab <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 b0 a7 10 80       	push   $0x8010a7b0
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
801004ce:	8b 04 85 c0 a7 10 80 	mov    -0x7fef5840(,%eax,4),%eax
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
8010052c:	c7 45 ec b9 a7 10 80 	movl   $0x8010a7b9,-0x14(%ebp)
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
801005d3:	e8 45 45 00 00       	call   80104b1d <release>
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
801005f7:	e8 71 26 00 00       	call   80102c6d <lapicid>
801005fc:	83 ec 08             	sub    $0x8,%esp
801005ff:	50                   	push   %eax
80100600:	68 18 a8 10 80       	push   $0x8010a818
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
8010061f:	68 2c a8 10 80       	push   $0x8010a82c
80100624:	e8 e3 fd ff ff       	call   8010040c <cprintf>
80100629:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010062c:	83 ec 08             	sub    $0x8,%esp
8010062f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100632:	50                   	push   %eax
80100633:	8d 45 08             	lea    0x8(%ebp),%eax
80100636:	50                   	push   %eax
80100637:	e8 37 45 00 00       	call   80104b73 <getcallerpcs>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100646:	eb 1c                	jmp    80100664 <panic+0x86>
    cprintf(" %p", pcs[i]);
80100648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010064b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010064f:	83 ec 08             	sub    $0x8,%esp
80100652:	50                   	push   %eax
80100653:	68 2e a8 10 80       	push   $0x8010a82e
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
801006dd:	e8 2c 7e 00 00       	call   8010850e <graphic_scroll_up>
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
80100730:	e8 d9 7d 00 00       	call   8010850e <graphic_scroll_up>
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
80100796:	e8 e7 7d 00 00       	call   80108582 <font_render>
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
801007d6:	e8 5c 61 00 00       	call   80106937 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 4f 61 00 00       	call   80106937 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 42 61 00 00       	call   80106937 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 32 61 00 00       	call   80106937 <uartputc>
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
80100832:	e8 74 42 00 00       	call   80104aab <acquire>
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
80100988:	e8 84 3c 00 00       	call   80104611 <wakeup>
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
801009ab:	e8 6d 41 00 00       	call   80104b1d <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 26 3d 00 00       	call   801046e4 <procdump>
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
801009d1:	e8 2b 12 00 00       	call   80101c01 <iunlock>
801009d6:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d9:	8b 45 10             	mov    0x10(%ebp),%eax
801009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 20 d0 18 80       	push   $0x8018d020
801009e7:	e8 bf 40 00 00       	call   80104aab <acquire>
801009ec:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ef:	e9 ab 00 00 00       	jmp    80100a9f <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009f4:	e8 1e 32 00 00       	call   80103c17 <myproc>
801009f9:	8b 40 24             	mov    0x24(%eax),%eax
801009fc:	85 c0                	test   %eax,%eax
801009fe:	74 28                	je     80100a28 <consoleread+0x67>
        release(&cons.lock);
80100a00:	83 ec 0c             	sub    $0xc,%esp
80100a03:	68 20 d0 18 80       	push   $0x8018d020
80100a08:	e8 10 41 00 00       	call   80104b1d <release>
80100a0d:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a10:	83 ec 0c             	sub    $0xc,%esp
80100a13:	ff 75 08             	push   0x8(%ebp)
80100a16:	e8 cf 10 00 00       	call   80101aea <ilock>
80100a1b:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a23:	e9 ab 00 00 00       	jmp    80100ad3 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a28:	83 ec 08             	sub    $0x8,%esp
80100a2b:	68 20 d0 18 80       	push   $0x8018d020
80100a30:	68 40 2d 19 80       	push   $0x80192d40
80100a35:	e8 e8 3a 00 00       	call   80104522 <sleep>
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
80100ab3:	e8 65 40 00 00       	call   80104b1d <release>
80100ab8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100abb:	83 ec 0c             	sub    $0xc,%esp
80100abe:	ff 75 08             	push   0x8(%ebp)
80100ac1:	e8 24 10 00 00       	call   80101aea <ilock>
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
80100ae5:	e8 17 11 00 00       	call   80101c01 <iunlock>
80100aea:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aed:	83 ec 0c             	sub    $0xc,%esp
80100af0:	68 20 d0 18 80       	push   $0x8018d020
80100af5:	e8 b1 3f 00 00       	call   80104aab <acquire>
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
80100b37:	e8 e1 3f 00 00       	call   80104b1d <release>
80100b3c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b3f:	83 ec 0c             	sub    $0xc,%esp
80100b42:	ff 75 08             	push   0x8(%ebp)
80100b45:	e8 a0 0f 00 00       	call   80101aea <ilock>
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
80100b69:	68 32 a8 10 80       	push   $0x8010a832
80100b6e:	68 20 d0 18 80       	push   $0x8018d020
80100b73:	e8 0d 3f 00 00       	call   80104a85 <initlock>
80100b78:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b7b:	c7 05 0c 37 19 80 d5 	movl   $0x80100ad5,0x8019370c
80100b82:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b85:	c7 05 08 37 19 80 c1 	movl   $0x801009c1,0x80193708
80100b8c:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b8f:	c7 45 f4 3a a8 10 80 	movl   $0x8010a83a,-0xc(%ebp)
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
80100bcc:	e8 a9 1b 00 00       	call   8010277a <ioapicenable>
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
80100be4:	e8 2e 30 00 00       	call   80103c17 <myproc>
80100be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bec:	e8 ee 25 00 00       	call   801031df <begin_op>

  if((ip = namei(path)) == 0){
80100bf1:	83 ec 0c             	sub    $0xc,%esp
80100bf4:	ff 75 08             	push   0x8(%ebp)
80100bf7:	e8 59 1a 00 00       	call   80102655 <namei>
80100bfc:	83 c4 10             	add    $0x10,%esp
80100bff:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c06:	75 1f                	jne    80100c27 <exec+0x50>
    end_op();
80100c08:	e8 62 26 00 00       	call   8010326f <end_op>
    cprintf("exec: fail\n");
80100c0d:	83 ec 0c             	sub    $0xc,%esp
80100c10:	68 50 a8 10 80       	push   $0x8010a850
80100c15:	e8 f2 f7 ff ff       	call   8010040c <cprintf>
80100c1a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 46 04 00 00       	jmp    8010106d <exec+0x496>
  }
  ilock(ip);
80100c27:	83 ec 0c             	sub    $0xc,%esp
80100c2a:	ff 75 d8             	push   -0x28(%ebp)
80100c2d:	e8 b8 0e 00 00       	call   80101aea <ilock>
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
80100c4a:	e8 a3 13 00 00       	call   80101ff2 <readi>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	83 f8 34             	cmp    $0x34,%eax
80100c55:	0f 85 a8 03 00 00    	jne    80101003 <exec+0x42c>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c5b:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c61:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c66:	0f 85 9a 03 00 00    	jne    80101006 <exec+0x42f>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c6c:	e8 da 6c 00 00       	call   8010794b <setupkvm>
80100c71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c78:	0f 84 8b 03 00 00    	je     80101009 <exec+0x432>
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
80100caa:	e8 43 13 00 00       	call   80101ff2 <readi>
80100caf:	83 c4 10             	add    $0x10,%esp
80100cb2:	83 f8 20             	cmp    $0x20,%eax
80100cb5:	0f 85 51 03 00 00    	jne    8010100c <exec+0x435>
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
80100cd8:	0f 82 31 03 00 00    	jb     8010100f <exec+0x438>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cde:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cea:	01 c2                	add    %eax,%edx
80100cec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 18 03 00 00    	jb     80101012 <exec+0x43b>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d00:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	push   -0x20(%ebp)
80100d0f:	ff 75 d4             	push   -0x2c(%ebp)
80100d12:	e8 46 70 00 00       	call   80107d5d <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 ee 02 00 00    	je     80101015 <exec+0x43e>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d32:	85 c0                	test   %eax,%eax
80100d34:	0f 85 de 02 00 00    	jne    80101018 <exec+0x441>
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
80100d58:	e8 2f 6f 00 00       	call   80107c8c <loaduvm>
80100d5d:	83 c4 20             	add    $0x20,%esp
80100d60:	85 c0                	test   %eax,%eax
80100d62:	0f 88 b3 02 00 00    	js     8010101b <exec+0x444>
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
80100d91:	e8 91 0f 00 00       	call   80101d27 <iunlockput>
80100d96:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d99:	e8 d1 24 00 00       	call   8010326f <end_op>
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
80100dbe:	e8 9a 6f 00 00       	call   80107d5d <allocuvm>
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dcd:	0f 84 4b 02 00 00    	je     8010101e <exec+0x447>
    goto bad;
  // 스택 포인터를 sz로
  sp = sz;
80100dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dd6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // 0xb98은 text, data영역의 윗 부분
  // sz는 사용 중인 유저 공간을 나타내주는데 스택을 kernbase로 옮겨서
  // 스택 외의 코드까지만 sz로 변경
  sz = PGROUNDUP(0xb98);
80100dd9:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100de3:	05 00 20 00 00       	add    $0x2000,%eax
80100de8:	83 ec 04             	sub    $0x4,%esp
80100deb:	50                   	push   %eax
80100dec:	ff 75 e0             	push   -0x20(%ebp)
80100def:	ff 75 d4             	push   -0x2c(%ebp)
80100df2:	e8 66 6f 00 00       	call   80107d5d <allocuvm>
80100df7:	83 c4 10             	add    $0x10,%esp
80100dfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dfd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e01:	0f 84 1a 02 00 00    	je     80101021 <exec+0x44a>
    goto bad;
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100e07:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e0a:	8b 40 10             	mov    0x10(%eax),%eax
80100e0d:	83 ec 04             	sub    $0x4,%esp
80100e10:	50                   	push   %eax
80100e11:	ff 75 e0             	push   -0x20(%ebp)
80100e14:	68 5c a8 10 80       	push   $0x8010a85c
80100e19:	e8 ee f5 ff ff       	call   8010040c <cprintf>
80100e1e:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e21:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e28:	e9 96 00 00 00       	jmp    80100ec3 <exec+0x2ec>
    if(argc >= MAXARG)
80100e2d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e31:	0f 87 ed 01 00 00    	ja     80101024 <exec+0x44d>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e44:	01 d0                	add    %edx,%eax
80100e46:	8b 00                	mov    (%eax),%eax
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	50                   	push   %eax
80100e4c:	e8 52 41 00 00       	call   80104fa3 <strlen>
80100e51:	83 c4 10             	add    $0x10,%esp
80100e54:	89 c2                	mov    %eax,%edx
80100e56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e59:	29 d0                	sub    %edx,%eax
80100e5b:	83 e8 01             	sub    $0x1,%eax
80100e5e:	83 e0 fc             	and    $0xfffffffc,%eax
80100e61:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e67:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e71:	01 d0                	add    %edx,%eax
80100e73:	8b 00                	mov    (%eax),%eax
80100e75:	83 ec 0c             	sub    $0xc,%esp
80100e78:	50                   	push   %eax
80100e79:	e8 25 41 00 00       	call   80104fa3 <strlen>
80100e7e:	83 c4 10             	add    $0x10,%esp
80100e81:	83 c0 01             	add    $0x1,%eax
80100e84:	89 c1                	mov    %eax,%ecx
80100e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e93:	01 d0                	add    %edx,%eax
80100e95:	8b 00                	mov    (%eax),%eax
80100e97:	51                   	push   %ecx
80100e98:	50                   	push   %eax
80100e99:	ff 75 dc             	push   -0x24(%ebp)
80100e9c:	ff 75 d4             	push   -0x2c(%ebp)
80100e9f:	e8 bd 72 00 00       	call   80108161 <copyout>
80100ea4:	83 c4 10             	add    $0x10,%esp
80100ea7:	85 c0                	test   %eax,%eax
80100ea9:	0f 88 78 01 00 00    	js     80101027 <exec+0x450>
      goto bad;
    ustack[3+argc] = sp;
80100eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb2:	8d 50 03             	lea    0x3(%eax),%edx
80100eb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eb8:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ebf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ec3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed0:	01 d0                	add    %edx,%eax
80100ed2:	8b 00                	mov    (%eax),%eax
80100ed4:	85 c0                	test   %eax,%eax
80100ed6:	0f 85 51 ff ff ff    	jne    80100e2d <exec+0x256>
  }
  ustack[3+argc] = 0;
80100edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edf:	83 c0 03             	add    $0x3,%eax
80100ee2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ee9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eed:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ef4:	ff ff ff 
  ustack[1] = argc;
80100ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efa:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f03:	83 c0 01             	add    $0x1,%eax
80100f06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f10:	29 d0                	sub    %edx,%eax
80100f12:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1b:	83 c0 04             	add    $0x4,%eax
80100f1e:	c1 e0 02             	shl    $0x2,%eax
80100f21:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f27:	83 c0 04             	add    $0x4,%eax
80100f2a:	c1 e0 02             	shl    $0x2,%eax
80100f2d:	50                   	push   %eax
80100f2e:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f34:	50                   	push   %eax
80100f35:	ff 75 dc             	push   -0x24(%ebp)
80100f38:	ff 75 d4             	push   -0x2c(%ebp)
80100f3b:	e8 21 72 00 00       	call   80108161 <copyout>
80100f40:	83 c4 10             	add    $0x10,%esp
80100f43:	85 c0                	test   %eax,%eax
80100f45:	0f 88 df 00 00 00    	js     8010102a <exec+0x453>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f57:	eb 17                	jmp    80100f70 <exec+0x399>
    if(*s == '/')
80100f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5c:	0f b6 00             	movzbl (%eax),%eax
80100f5f:	3c 2f                	cmp    $0x2f,%al
80100f61:	75 09                	jne    80100f6c <exec+0x395>
      last = s+1;
80100f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f66:	83 c0 01             	add    $0x1,%eax
80100f69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f73:	0f b6 00             	movzbl (%eax),%eax
80100f76:	84 c0                	test   %al,%al
80100f78:	75 df                	jne    80100f59 <exec+0x382>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7d:	83 c0 6c             	add    $0x6c,%eax
80100f80:	83 ec 04             	sub    $0x4,%esp
80100f83:	6a 10                	push   $0x10
80100f85:	ff 75 f0             	push   -0x10(%ebp)
80100f88:	50                   	push   %eax
80100f89:	e8 c7 3f 00 00       	call   80104f55 <safestrcpy>
80100f8e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f91:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f94:	8b 40 04             	mov    0x4(%eax),%eax
80100f97:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fa0:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa6:	8b 40 18             	mov    0x18(%eax),%eax
80100fa9:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100faf:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->sz = sz;
80100fb2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fb8:	89 10                	mov    %edx,(%eax)
  curproc->tf->esp = sp;
80100fba:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fbd:	8b 40 18             	mov    0x18(%eax),%eax
80100fc0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fc3:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("[exec] eip %x\n",curproc->tf->eip);
80100fc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc9:	8b 40 18             	mov    0x18(%eax),%eax
80100fcc:	8b 40 38             	mov    0x38(%eax),%eax
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	50                   	push   %eax
80100fd3:	68 79 a8 10 80       	push   $0x8010a879
80100fd8:	e8 2f f4 ff ff       	call   8010040c <cprintf>
80100fdd:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80100fe0:	83 ec 0c             	sub    $0xc,%esp
80100fe3:	ff 75 d0             	push   -0x30(%ebp)
80100fe6:	e8 8a 6a 00 00       	call   80107a75 <switchuvm>
80100feb:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fee:	83 ec 0c             	sub    $0xc,%esp
80100ff1:	ff 75 cc             	push   -0x34(%ebp)
80100ff4:	e8 35 6f 00 00       	call   80107f2e <freevm>
80100ff9:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ffc:	b8 00 00 00 00       	mov    $0x0,%eax
80101001:	eb 6a                	jmp    8010106d <exec+0x496>
    goto bad;
80101003:	90                   	nop
80101004:	eb 25                	jmp    8010102b <exec+0x454>
    goto bad;
80101006:	90                   	nop
80101007:	eb 22                	jmp    8010102b <exec+0x454>
    goto bad;
80101009:	90                   	nop
8010100a:	eb 1f                	jmp    8010102b <exec+0x454>
      goto bad;
8010100c:	90                   	nop
8010100d:	eb 1c                	jmp    8010102b <exec+0x454>
      goto bad;
8010100f:	90                   	nop
80101010:	eb 19                	jmp    8010102b <exec+0x454>
      goto bad;
80101012:	90                   	nop
80101013:	eb 16                	jmp    8010102b <exec+0x454>
      goto bad;
80101015:	90                   	nop
80101016:	eb 13                	jmp    8010102b <exec+0x454>
      goto bad;
80101018:	90                   	nop
80101019:	eb 10                	jmp    8010102b <exec+0x454>
      goto bad;
8010101b:	90                   	nop
8010101c:	eb 0d                	jmp    8010102b <exec+0x454>
    goto bad;
8010101e:	90                   	nop
8010101f:	eb 0a                	jmp    8010102b <exec+0x454>
    goto bad;
80101021:	90                   	nop
80101022:	eb 07                	jmp    8010102b <exec+0x454>
      goto bad;
80101024:	90                   	nop
80101025:	eb 04                	jmp    8010102b <exec+0x454>
      goto bad;
80101027:	90                   	nop
80101028:	eb 01                	jmp    8010102b <exec+0x454>
    goto bad;
8010102a:	90                   	nop

 bad:
  cprintf("bad \n");
8010102b:	83 ec 0c             	sub    $0xc,%esp
8010102e:	68 88 a8 10 80       	push   $0x8010a888
80101033:	e8 d4 f3 ff ff       	call   8010040c <cprintf>
80101038:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
8010103b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010103f:	74 0e                	je     8010104f <exec+0x478>
    freevm(pgdir);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	ff 75 d4             	push   -0x2c(%ebp)
80101047:	e8 e2 6e 00 00       	call   80107f2e <freevm>
8010104c:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010104f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101053:	74 13                	je     80101068 <exec+0x491>
    iunlockput(ip);
80101055:	83 ec 0c             	sub    $0xc,%esp
80101058:	ff 75 d8             	push   -0x28(%ebp)
8010105b:	e8 c7 0c 00 00       	call   80101d27 <iunlockput>
80101060:	83 c4 10             	add    $0x10,%esp
    end_op();
80101063:	e8 07 22 00 00       	call   8010326f <end_op>
  }
  return -1;
80101068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010106d:	c9                   	leave
8010106e:	c3                   	ret

8010106f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010106f:	f3 0f 1e fb          	endbr32
80101073:	55                   	push   %ebp
80101074:	89 e5                	mov    %esp,%ebp
80101076:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101079:	83 ec 08             	sub    $0x8,%esp
8010107c:	68 8e a8 10 80       	push   $0x8010a88e
80101081:	68 60 2d 19 80       	push   $0x80192d60
80101086:	e8 fa 39 00 00       	call   80104a85 <initlock>
8010108b:	83 c4 10             	add    $0x10,%esp
}
8010108e:	90                   	nop
8010108f:	c9                   	leave
80101090:	c3                   	ret

80101091 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101091:	f3 0f 1e fb          	endbr32
80101095:	55                   	push   %ebp
80101096:	89 e5                	mov    %esp,%ebp
80101098:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010109b:	83 ec 0c             	sub    $0xc,%esp
8010109e:	68 60 2d 19 80       	push   $0x80192d60
801010a3:	e8 03 3a 00 00       	call   80104aab <acquire>
801010a8:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010ab:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
801010b2:	eb 2d                	jmp    801010e1 <filealloc+0x50>
    if(f->ref == 0){
801010b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	75 1f                	jne    801010dd <filealloc+0x4c>
      f->ref = 1;
801010be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010c1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 60 2d 19 80       	push   $0x80192d60
801010d0:	e8 48 3a 00 00       	call   80104b1d <release>
801010d5:	83 c4 10             	add    $0x10,%esp
      return f;
801010d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010db:	eb 23                	jmp    80101100 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010dd:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010e1:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
801010e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010e9:	72 c9                	jb     801010b4 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 60 2d 19 80       	push   $0x80192d60
801010f3:	e8 25 3a 00 00       	call   80104b1d <release>
801010f8:	83 c4 10             	add    $0x10,%esp
  return 0;
801010fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101100:	c9                   	leave
80101101:	c3                   	ret

80101102 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101102:	f3 0f 1e fb          	endbr32
80101106:	55                   	push   %ebp
80101107:	89 e5                	mov    %esp,%ebp
80101109:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010110c:	83 ec 0c             	sub    $0xc,%esp
8010110f:	68 60 2d 19 80       	push   $0x80192d60
80101114:	e8 92 39 00 00       	call   80104aab <acquire>
80101119:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	8b 40 04             	mov    0x4(%eax),%eax
80101122:	85 c0                	test   %eax,%eax
80101124:	7f 0d                	jg     80101133 <filedup+0x31>
    panic("filedup");
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	68 95 a8 10 80       	push   $0x8010a895
8010112e:	e8 ab f4 ff ff       	call   801005de <panic>
  f->ref++;
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 04             	mov    0x4(%eax),%eax
80101139:	8d 50 01             	lea    0x1(%eax),%edx
8010113c:	8b 45 08             	mov    0x8(%ebp),%eax
8010113f:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101142:	83 ec 0c             	sub    $0xc,%esp
80101145:	68 60 2d 19 80       	push   $0x80192d60
8010114a:	e8 ce 39 00 00       	call   80104b1d <release>
8010114f:	83 c4 10             	add    $0x10,%esp
  return f;
80101152:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101155:	c9                   	leave
80101156:	c3                   	ret

80101157 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101157:	f3 0f 1e fb          	endbr32
8010115b:	55                   	push   %ebp
8010115c:	89 e5                	mov    %esp,%ebp
8010115e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101161:	83 ec 0c             	sub    $0xc,%esp
80101164:	68 60 2d 19 80       	push   $0x80192d60
80101169:	e8 3d 39 00 00       	call   80104aab <acquire>
8010116e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 04             	mov    0x4(%eax),%eax
80101177:	85 c0                	test   %eax,%eax
80101179:	7f 0d                	jg     80101188 <fileclose+0x31>
    panic("fileclose");
8010117b:	83 ec 0c             	sub    $0xc,%esp
8010117e:	68 9d a8 10 80       	push   $0x8010a89d
80101183:	e8 56 f4 ff ff       	call   801005de <panic>
  if(--f->ref > 0){
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	8b 40 04             	mov    0x4(%eax),%eax
8010118e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101191:	8b 45 08             	mov    0x8(%ebp),%eax
80101194:	89 50 04             	mov    %edx,0x4(%eax)
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	8b 40 04             	mov    0x4(%eax),%eax
8010119d:	85 c0                	test   %eax,%eax
8010119f:	7e 15                	jle    801011b6 <fileclose+0x5f>
    release(&ftable.lock);
801011a1:	83 ec 0c             	sub    $0xc,%esp
801011a4:	68 60 2d 19 80       	push   $0x80192d60
801011a9:	e8 6f 39 00 00       	call   80104b1d <release>
801011ae:	83 c4 10             	add    $0x10,%esp
801011b1:	e9 8b 00 00 00       	jmp    80101241 <fileclose+0xea>
    return;
  }
  ff = *f;
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 10                	mov    (%eax),%edx
801011bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011be:	8b 50 04             	mov    0x4(%eax),%edx
801011c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011c4:	8b 50 08             	mov    0x8(%eax),%edx
801011c7:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011ca:	8b 50 0c             	mov    0xc(%eax),%edx
801011cd:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011d0:	8b 50 10             	mov    0x10(%eax),%edx
801011d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011d6:	8b 40 14             	mov    0x14(%eax),%eax
801011d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	68 60 2d 19 80       	push   $0x80192d60
801011f7:	e8 21 39 00 00       	call   80104b1d <release>
801011fc:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101202:	83 f8 01             	cmp    $0x1,%eax
80101205:	75 19                	jne    80101220 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101207:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010120b:	0f be d0             	movsbl %al,%edx
8010120e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101211:	83 ec 08             	sub    $0x8,%esp
80101214:	52                   	push   %edx
80101215:	50                   	push   %eax
80101216:	e8 73 26 00 00       	call   8010388e <pipeclose>
8010121b:	83 c4 10             	add    $0x10,%esp
8010121e:	eb 21                	jmp    80101241 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101220:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101223:	83 f8 02             	cmp    $0x2,%eax
80101226:	75 19                	jne    80101241 <fileclose+0xea>
    begin_op();
80101228:	e8 b2 1f 00 00       	call   801031df <begin_op>
    iput(ff.ip);
8010122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101230:	83 ec 0c             	sub    $0xc,%esp
80101233:	50                   	push   %eax
80101234:	e8 1a 0a 00 00       	call   80101c53 <iput>
80101239:	83 c4 10             	add    $0x10,%esp
    end_op();
8010123c:	e8 2e 20 00 00       	call   8010326f <end_op>
  }
}
80101241:	c9                   	leave
80101242:	c3                   	ret

80101243 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101243:	f3 0f 1e fb          	endbr32
80101247:	55                   	push   %ebp
80101248:	89 e5                	mov    %esp,%ebp
8010124a:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	8b 00                	mov    (%eax),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 40                	jne    80101297 <filestat+0x54>
    ilock(f->ip);
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	8b 40 10             	mov    0x10(%eax),%eax
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	50                   	push   %eax
80101261:	e8 84 08 00 00       	call   80101aea <ilock>
80101266:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	8b 40 10             	mov    0x10(%eax),%eax
8010126f:	83 ec 08             	sub    $0x8,%esp
80101272:	ff 75 0c             	push   0xc(%ebp)
80101275:	50                   	push   %eax
80101276:	e8 2d 0d 00 00       	call   80101fa8 <stati>
8010127b:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010127e:	8b 45 08             	mov    0x8(%ebp),%eax
80101281:	8b 40 10             	mov    0x10(%eax),%eax
80101284:	83 ec 0c             	sub    $0xc,%esp
80101287:	50                   	push   %eax
80101288:	e8 74 09 00 00       	call   80101c01 <iunlock>
8010128d:	83 c4 10             	add    $0x10,%esp
    return 0;
80101290:	b8 00 00 00 00       	mov    $0x0,%eax
80101295:	eb 05                	jmp    8010129c <filestat+0x59>
  }
  return -1;
80101297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010129c:	c9                   	leave
8010129d:	c3                   	ret

8010129e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010129e:	f3 0f 1e fb          	endbr32
801012a2:	55                   	push   %ebp
801012a3:	89 e5                	mov    %esp,%ebp
801012a5:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012af:	84 c0                	test   %al,%al
801012b1:	75 0a                	jne    801012bd <fileread+0x1f>
    return -1;
801012b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b8:	e9 9b 00 00 00       	jmp    80101358 <fileread+0xba>
  if(f->type == FD_PIPE)
801012bd:	8b 45 08             	mov    0x8(%ebp),%eax
801012c0:	8b 00                	mov    (%eax),%eax
801012c2:	83 f8 01             	cmp    $0x1,%eax
801012c5:	75 1a                	jne    801012e1 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012c7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ca:	8b 40 0c             	mov    0xc(%eax),%eax
801012cd:	83 ec 04             	sub    $0x4,%esp
801012d0:	ff 75 10             	push   0x10(%ebp)
801012d3:	ff 75 0c             	push   0xc(%ebp)
801012d6:	50                   	push   %eax
801012d7:	e8 67 27 00 00       	call   80103a43 <piperead>
801012dc:	83 c4 10             	add    $0x10,%esp
801012df:	eb 77                	jmp    80101358 <fileread+0xba>
  if(f->type == FD_INODE){
801012e1:	8b 45 08             	mov    0x8(%ebp),%eax
801012e4:	8b 00                	mov    (%eax),%eax
801012e6:	83 f8 02             	cmp    $0x2,%eax
801012e9:	75 60                	jne    8010134b <fileread+0xad>
    ilock(f->ip);
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	83 ec 0c             	sub    $0xc,%esp
801012f4:	50                   	push   %eax
801012f5:	e8 f0 07 00 00       	call   80101aea <ilock>
801012fa:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 50 14             	mov    0x14(%eax),%edx
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 40 10             	mov    0x10(%eax),%eax
8010130c:	51                   	push   %ecx
8010130d:	52                   	push   %edx
8010130e:	ff 75 0c             	push   0xc(%ebp)
80101311:	50                   	push   %eax
80101312:	e8 db 0c 00 00       	call   80101ff2 <readi>
80101317:	83 c4 10             	add    $0x10,%esp
8010131a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010131d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101321:	7e 11                	jle    80101334 <fileread+0x96>
      f->off += r;
80101323:	8b 45 08             	mov    0x8(%ebp),%eax
80101326:	8b 50 14             	mov    0x14(%eax),%edx
80101329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132c:	01 c2                	add    %eax,%edx
8010132e:	8b 45 08             	mov    0x8(%ebp),%eax
80101331:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101334:	8b 45 08             	mov    0x8(%ebp),%eax
80101337:	8b 40 10             	mov    0x10(%eax),%eax
8010133a:	83 ec 0c             	sub    $0xc,%esp
8010133d:	50                   	push   %eax
8010133e:	e8 be 08 00 00       	call   80101c01 <iunlock>
80101343:	83 c4 10             	add    $0x10,%esp
    return r;
80101346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101349:	eb 0d                	jmp    80101358 <fileread+0xba>
  }
  panic("fileread");
8010134b:	83 ec 0c             	sub    $0xc,%esp
8010134e:	68 a7 a8 10 80       	push   $0x8010a8a7
80101353:	e8 86 f2 ff ff       	call   801005de <panic>
}
80101358:	c9                   	leave
80101359:	c3                   	ret

8010135a <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010135a:	f3 0f 1e fb          	endbr32
8010135e:	55                   	push   %ebp
8010135f:	89 e5                	mov    %esp,%ebp
80101361:	53                   	push   %ebx
80101362:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010136c:	84 c0                	test   %al,%al
8010136e:	75 0a                	jne    8010137a <filewrite+0x20>
    return -1;
80101370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101375:	e9 1b 01 00 00       	jmp    80101495 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010137a:	8b 45 08             	mov    0x8(%ebp),%eax
8010137d:	8b 00                	mov    (%eax),%eax
8010137f:	83 f8 01             	cmp    $0x1,%eax
80101382:	75 1d                	jne    801013a1 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101384:	8b 45 08             	mov    0x8(%ebp),%eax
80101387:	8b 40 0c             	mov    0xc(%eax),%eax
8010138a:	83 ec 04             	sub    $0x4,%esp
8010138d:	ff 75 10             	push   0x10(%ebp)
80101390:	ff 75 0c             	push   0xc(%ebp)
80101393:	50                   	push   %eax
80101394:	e8 a4 25 00 00       	call   8010393d <pipewrite>
80101399:	83 c4 10             	add    $0x10,%esp
8010139c:	e9 f4 00 00 00       	jmp    80101495 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013a1:	8b 45 08             	mov    0x8(%ebp),%eax
801013a4:	8b 00                	mov    (%eax),%eax
801013a6:	83 f8 02             	cmp    $0x2,%eax
801013a9:	0f 85 d9 00 00 00    	jne    80101488 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013af:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013bd:	e9 a3 00 00 00       	jmp    80101465 <filewrite+0x10b>
      int n1 = n - i;
801013c2:	8b 45 10             	mov    0x10(%ebp),%eax
801013c5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ce:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013d1:	7e 06                	jle    801013d9 <filewrite+0x7f>
        n1 = max;
801013d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013d6:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013d9:	e8 01 1e 00 00       	call   801031df <begin_op>
      ilock(f->ip);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	8b 40 10             	mov    0x10(%eax),%eax
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	50                   	push   %eax
801013e8:	e8 fd 06 00 00       	call   80101aea <ilock>
801013ed:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013f0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	8b 50 14             	mov    0x14(%eax),%edx
801013f9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ff:	01 c3                	add    %eax,%ebx
80101401:	8b 45 08             	mov    0x8(%ebp),%eax
80101404:	8b 40 10             	mov    0x10(%eax),%eax
80101407:	51                   	push   %ecx
80101408:	52                   	push   %edx
80101409:	53                   	push   %ebx
8010140a:	50                   	push   %eax
8010140b:	e8 3b 0d 00 00       	call   8010214b <writei>
80101410:	83 c4 10             	add    $0x10,%esp
80101413:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101416:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010141a:	7e 11                	jle    8010142d <filewrite+0xd3>
        f->off += r;
8010141c:	8b 45 08             	mov    0x8(%ebp),%eax
8010141f:	8b 50 14             	mov    0x14(%eax),%edx
80101422:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101425:	01 c2                	add    %eax,%edx
80101427:	8b 45 08             	mov    0x8(%ebp),%eax
8010142a:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010142d:	8b 45 08             	mov    0x8(%ebp),%eax
80101430:	8b 40 10             	mov    0x10(%eax),%eax
80101433:	83 ec 0c             	sub    $0xc,%esp
80101436:	50                   	push   %eax
80101437:	e8 c5 07 00 00       	call   80101c01 <iunlock>
8010143c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010143f:	e8 2b 1e 00 00       	call   8010326f <end_op>

      if(r < 0)
80101444:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101448:	78 29                	js     80101473 <filewrite+0x119>
        break;
      if(r != n1)
8010144a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010144d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101450:	74 0d                	je     8010145f <filewrite+0x105>
        panic("short filewrite");
80101452:	83 ec 0c             	sub    $0xc,%esp
80101455:	68 b0 a8 10 80       	push   $0x8010a8b0
8010145a:	e8 7f f1 ff ff       	call   801005de <panic>
      i += r;
8010145f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101462:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101468:	3b 45 10             	cmp    0x10(%ebp),%eax
8010146b:	0f 8c 51 ff ff ff    	jl     801013c2 <filewrite+0x68>
80101471:	eb 01                	jmp    80101474 <filewrite+0x11a>
        break;
80101473:	90                   	nop
    }
    return i == n ? n : -1;
80101474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101477:	3b 45 10             	cmp    0x10(%ebp),%eax
8010147a:	75 05                	jne    80101481 <filewrite+0x127>
8010147c:	8b 45 10             	mov    0x10(%ebp),%eax
8010147f:	eb 14                	jmp    80101495 <filewrite+0x13b>
80101481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101486:	eb 0d                	jmp    80101495 <filewrite+0x13b>
  }
  panic("filewrite");
80101488:	83 ec 0c             	sub    $0xc,%esp
8010148b:	68 c0 a8 10 80       	push   $0x8010a8c0
80101490:	e8 49 f1 ff ff       	call   801005de <panic>
}
80101495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101498:	c9                   	leave
80101499:	c3                   	ret

8010149a <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010149a:	f3 0f 1e fb          	endbr32
8010149e:	55                   	push   %ebp
8010149f:	89 e5                	mov    %esp,%ebp
801014a1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014a4:	8b 45 08             	mov    0x8(%ebp),%eax
801014a7:	83 ec 08             	sub    $0x8,%esp
801014aa:	6a 01                	push   $0x1
801014ac:	50                   	push   %eax
801014ad:	e8 57 ed ff ff       	call   80100209 <bread>
801014b2:	83 c4 10             	add    $0x10,%esp
801014b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014bb:	83 c0 5c             	add    $0x5c,%eax
801014be:	83 ec 04             	sub    $0x4,%esp
801014c1:	6a 1c                	push   $0x1c
801014c3:	50                   	push   %eax
801014c4:	ff 75 0c             	push   0xc(%ebp)
801014c7:	e8 35 39 00 00       	call   80104e01 <memmove>
801014cc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014cf:	83 ec 0c             	sub    $0xc,%esp
801014d2:	ff 75 f4             	push   -0xc(%ebp)
801014d5:	e8 b9 ed ff ff       	call   80100293 <brelse>
801014da:	83 c4 10             	add    $0x10,%esp
}
801014dd:	90                   	nop
801014de:	c9                   	leave
801014df:	c3                   	ret

801014e0 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014e0:	f3 0f 1e fb          	endbr32
801014e4:	55                   	push   %ebp
801014e5:	89 e5                	mov    %esp,%ebp
801014e7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801014ed:	8b 45 08             	mov    0x8(%ebp),%eax
801014f0:	83 ec 08             	sub    $0x8,%esp
801014f3:	52                   	push   %edx
801014f4:	50                   	push   %eax
801014f5:	e8 0f ed ff ff       	call   80100209 <bread>
801014fa:	83 c4 10             	add    $0x10,%esp
801014fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101503:	83 c0 5c             	add    $0x5c,%eax
80101506:	83 ec 04             	sub    $0x4,%esp
80101509:	68 00 02 00 00       	push   $0x200
8010150e:	6a 00                	push   $0x0
80101510:	50                   	push   %eax
80101511:	e8 24 38 00 00       	call   80104d3a <memset>
80101516:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101519:	83 ec 0c             	sub    $0xc,%esp
8010151c:	ff 75 f4             	push   -0xc(%ebp)
8010151f:	e8 04 1f 00 00       	call   80103428 <log_write>
80101524:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101527:	83 ec 0c             	sub    $0xc,%esp
8010152a:	ff 75 f4             	push   -0xc(%ebp)
8010152d:	e8 61 ed ff ff       	call   80100293 <brelse>
80101532:	83 c4 10             	add    $0x10,%esp
}
80101535:	90                   	nop
80101536:	c9                   	leave
80101537:	c3                   	ret

80101538 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101538:	f3 0f 1e fb          	endbr32
8010153c:	55                   	push   %ebp
8010153d:	89 e5                	mov    %esp,%ebp
8010153f:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101542:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101549:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101550:	e9 13 01 00 00       	jmp    80101668 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101558:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010155e:	85 c0                	test   %eax,%eax
80101560:	0f 48 c2             	cmovs  %edx,%eax
80101563:	c1 f8 0c             	sar    $0xc,%eax
80101566:	89 c2                	mov    %eax,%edx
80101568:	a1 78 37 19 80       	mov    0x80193778,%eax
8010156d:	01 d0                	add    %edx,%eax
8010156f:	83 ec 08             	sub    $0x8,%esp
80101572:	50                   	push   %eax
80101573:	ff 75 08             	push   0x8(%ebp)
80101576:	e8 8e ec ff ff       	call   80100209 <bread>
8010157b:	83 c4 10             	add    $0x10,%esp
8010157e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101581:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101588:	e9 a6 00 00 00       	jmp    80101633 <balloc+0xfb>
      m = 1 << (bi % 8);
8010158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101590:	99                   	cltd
80101591:	c1 ea 1d             	shr    $0x1d,%edx
80101594:	01 d0                	add    %edx,%eax
80101596:	83 e0 07             	and    $0x7,%eax
80101599:	29 d0                	sub    %edx,%eax
8010159b:	ba 01 00 00 00       	mov    $0x1,%edx
801015a0:	89 c1                	mov    %eax,%ecx
801015a2:	d3 e2                	shl    %cl,%edx
801015a4:	89 d0                	mov    %edx,%eax
801015a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ac:	8d 50 07             	lea    0x7(%eax),%edx
801015af:	85 c0                	test   %eax,%eax
801015b1:	0f 48 c2             	cmovs  %edx,%eax
801015b4:	c1 f8 03             	sar    $0x3,%eax
801015b7:	89 c2                	mov    %eax,%edx
801015b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015bc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015c1:	0f b6 c0             	movzbl %al,%eax
801015c4:	23 45 e8             	and    -0x18(%ebp),%eax
801015c7:	85 c0                	test   %eax,%eax
801015c9:	75 64                	jne    8010162f <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ce:	8d 50 07             	lea    0x7(%eax),%edx
801015d1:	85 c0                	test   %eax,%eax
801015d3:	0f 48 c2             	cmovs  %edx,%eax
801015d6:	c1 f8 03             	sar    $0x3,%eax
801015d9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015dc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015e1:	89 d1                	mov    %edx,%ecx
801015e3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015e6:	09 ca                	or     %ecx,%edx
801015e8:	89 d1                	mov    %edx,%ecx
801015ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ed:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015f1:	83 ec 0c             	sub    $0xc,%esp
801015f4:	ff 75 ec             	push   -0x14(%ebp)
801015f7:	e8 2c 1e 00 00       	call   80103428 <log_write>
801015fc:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015ff:	83 ec 0c             	sub    $0xc,%esp
80101602:	ff 75 ec             	push   -0x14(%ebp)
80101605:	e8 89 ec ff ff       	call   80100293 <brelse>
8010160a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	01 c2                	add    %eax,%edx
80101615:	8b 45 08             	mov    0x8(%ebp),%eax
80101618:	83 ec 08             	sub    $0x8,%esp
8010161b:	52                   	push   %edx
8010161c:	50                   	push   %eax
8010161d:	e8 be fe ff ff       	call   801014e0 <bzero>
80101622:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101628:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162b:	01 d0                	add    %edx,%eax
8010162d:	eb 57                	jmp    80101686 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010162f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101633:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010163a:	7f 17                	jg     80101653 <balloc+0x11b>
8010163c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	01 d0                	add    %edx,%eax
80101644:	89 c2                	mov    %eax,%edx
80101646:	a1 60 37 19 80       	mov    0x80193760,%eax
8010164b:	39 c2                	cmp    %eax,%edx
8010164d:	0f 82 3a ff ff ff    	jb     8010158d <balloc+0x55>
      }
    }
    brelse(bp);
80101653:	83 ec 0c             	sub    $0xc,%esp
80101656:	ff 75 ec             	push   -0x14(%ebp)
80101659:	e8 35 ec ff ff       	call   80100293 <brelse>
8010165e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101661:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101668:	8b 15 60 37 19 80    	mov    0x80193760,%edx
8010166e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101671:	39 c2                	cmp    %eax,%edx
80101673:	0f 87 dc fe ff ff    	ja     80101555 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101679:	83 ec 0c             	sub    $0xc,%esp
8010167c:	68 cc a8 10 80       	push   $0x8010a8cc
80101681:	e8 58 ef ff ff       	call   801005de <panic>
}
80101686:	c9                   	leave
80101687:	c3                   	ret

80101688 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101688:	f3 0f 1e fb          	endbr32
8010168c:	55                   	push   %ebp
8010168d:	89 e5                	mov    %esp,%ebp
8010168f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101692:	83 ec 08             	sub    $0x8,%esp
80101695:	68 60 37 19 80       	push   $0x80193760
8010169a:	ff 75 08             	push   0x8(%ebp)
8010169d:	e8 f8 fd ff ff       	call   8010149a <readsb>
801016a2:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801016a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801016a8:	c1 e8 0c             	shr    $0xc,%eax
801016ab:	89 c2                	mov    %eax,%edx
801016ad:	a1 78 37 19 80       	mov    0x80193778,%eax
801016b2:	01 c2                	add    %eax,%edx
801016b4:	8b 45 08             	mov    0x8(%ebp),%eax
801016b7:	83 ec 08             	sub    $0x8,%esp
801016ba:	52                   	push   %edx
801016bb:	50                   	push   %eax
801016bc:	e8 48 eb ff ff       	call   80100209 <bread>
801016c1:	83 c4 10             	add    $0x10,%esp
801016c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ca:	25 ff 0f 00 00       	and    $0xfff,%eax
801016cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d5:	99                   	cltd
801016d6:	c1 ea 1d             	shr    $0x1d,%edx
801016d9:	01 d0                	add    %edx,%eax
801016db:	83 e0 07             	and    $0x7,%eax
801016de:	29 d0                	sub    %edx,%eax
801016e0:	ba 01 00 00 00       	mov    $0x1,%edx
801016e5:	89 c1                	mov    %eax,%ecx
801016e7:	d3 e2                	shl    %cl,%edx
801016e9:	89 d0                	mov    %edx,%eax
801016eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f1:	8d 50 07             	lea    0x7(%eax),%edx
801016f4:	85 c0                	test   %eax,%eax
801016f6:	0f 48 c2             	cmovs  %edx,%eax
801016f9:	c1 f8 03             	sar    $0x3,%eax
801016fc:	89 c2                	mov    %eax,%edx
801016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101701:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101706:	0f b6 c0             	movzbl %al,%eax
80101709:	23 45 ec             	and    -0x14(%ebp),%eax
8010170c:	85 c0                	test   %eax,%eax
8010170e:	75 0d                	jne    8010171d <bfree+0x95>
    panic("freeing free block");
80101710:	83 ec 0c             	sub    $0xc,%esp
80101713:	68 e2 a8 10 80       	push   $0x8010a8e2
80101718:	e8 c1 ee ff ff       	call   801005de <panic>
  bp->data[bi/8] &= ~m;
8010171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101720:	8d 50 07             	lea    0x7(%eax),%edx
80101723:	85 c0                	test   %eax,%eax
80101725:	0f 48 c2             	cmovs  %edx,%eax
80101728:	c1 f8 03             	sar    $0x3,%eax
8010172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101733:	89 d1                	mov    %edx,%ecx
80101735:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101738:	f7 d2                	not    %edx
8010173a:	21 ca                	and    %ecx,%edx
8010173c:	89 d1                	mov    %edx,%ecx
8010173e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101741:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101745:	83 ec 0c             	sub    $0xc,%esp
80101748:	ff 75 f4             	push   -0xc(%ebp)
8010174b:	e8 d8 1c 00 00       	call   80103428 <log_write>
80101750:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101753:	83 ec 0c             	sub    $0xc,%esp
80101756:	ff 75 f4             	push   -0xc(%ebp)
80101759:	e8 35 eb ff ff       	call   80100293 <brelse>
8010175e:	83 c4 10             	add    $0x10,%esp
}
80101761:	90                   	nop
80101762:	c9                   	leave
80101763:	c3                   	ret

80101764 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101764:	f3 0f 1e fb          	endbr32
80101768:	55                   	push   %ebp
80101769:	89 e5                	mov    %esp,%ebp
8010176b:	57                   	push   %edi
8010176c:	56                   	push   %esi
8010176d:	53                   	push   %ebx
8010176e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101771:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101778:	83 ec 08             	sub    $0x8,%esp
8010177b:	68 f5 a8 10 80       	push   $0x8010a8f5
80101780:	68 80 37 19 80       	push   $0x80193780
80101785:	e8 fb 32 00 00       	call   80104a85 <initlock>
8010178a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010178d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101794:	eb 2d                	jmp    801017c3 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101796:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101799:	89 d0                	mov    %edx,%eax
8010179b:	c1 e0 03             	shl    $0x3,%eax
8010179e:	01 d0                	add    %edx,%eax
801017a0:	c1 e0 04             	shl    $0x4,%eax
801017a3:	83 c0 30             	add    $0x30,%eax
801017a6:	05 80 37 19 80       	add    $0x80193780,%eax
801017ab:	83 c0 10             	add    $0x10,%eax
801017ae:	83 ec 08             	sub    $0x8,%esp
801017b1:	68 fc a8 10 80       	push   $0x8010a8fc
801017b6:	50                   	push   %eax
801017b7:	e8 5c 31 00 00       	call   80104918 <initsleeplock>
801017bc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017bf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017c3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017c7:	7e cd                	jle    80101796 <iinit+0x32>
  }

  readsb(dev, &sb);
801017c9:	83 ec 08             	sub    $0x8,%esp
801017cc:	68 60 37 19 80       	push   $0x80193760
801017d1:	ff 75 08             	push   0x8(%ebp)
801017d4:	e8 c1 fc ff ff       	call   8010149a <readsb>
801017d9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017dc:	a1 78 37 19 80       	mov    0x80193778,%eax
801017e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017e4:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
801017ea:	8b 35 70 37 19 80    	mov    0x80193770,%esi
801017f0:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
801017f6:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
801017fc:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101802:	a1 60 37 19 80       	mov    0x80193760,%eax
80101807:	ff 75 d4             	push   -0x2c(%ebp)
8010180a:	57                   	push   %edi
8010180b:	56                   	push   %esi
8010180c:	53                   	push   %ebx
8010180d:	51                   	push   %ecx
8010180e:	52                   	push   %edx
8010180f:	50                   	push   %eax
80101810:	68 04 a9 10 80       	push   $0x8010a904
80101815:	e8 f2 eb ff ff       	call   8010040c <cprintf>
8010181a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010181d:	90                   	nop
8010181e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101821:	5b                   	pop    %ebx
80101822:	5e                   	pop    %esi
80101823:	5f                   	pop    %edi
80101824:	5d                   	pop    %ebp
80101825:	c3                   	ret

80101826 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101826:	f3 0f 1e fb          	endbr32
8010182a:	55                   	push   %ebp
8010182b:	89 e5                	mov    %esp,%ebp
8010182d:	83 ec 28             	sub    $0x28,%esp
80101830:	8b 45 0c             	mov    0xc(%ebp),%eax
80101833:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101837:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010183e:	e9 9e 00 00 00       	jmp    801018e1 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101846:	c1 e8 03             	shr    $0x3,%eax
80101849:	89 c2                	mov    %eax,%edx
8010184b:	a1 74 37 19 80       	mov    0x80193774,%eax
80101850:	01 d0                	add    %edx,%eax
80101852:	83 ec 08             	sub    $0x8,%esp
80101855:	50                   	push   %eax
80101856:	ff 75 08             	push   0x8(%ebp)
80101859:	e8 ab e9 ff ff       	call   80100209 <bread>
8010185e:	83 c4 10             	add    $0x10,%esp
80101861:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101864:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101867:	8d 50 5c             	lea    0x5c(%eax),%edx
8010186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186d:	83 e0 07             	and    $0x7,%eax
80101870:	c1 e0 06             	shl    $0x6,%eax
80101873:	01 d0                	add    %edx,%eax
80101875:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101878:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010187b:	0f b7 00             	movzwl (%eax),%eax
8010187e:	66 85 c0             	test   %ax,%ax
80101881:	75 4c                	jne    801018cf <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101883:	83 ec 04             	sub    $0x4,%esp
80101886:	6a 40                	push   $0x40
80101888:	6a 00                	push   $0x0
8010188a:	ff 75 ec             	push   -0x14(%ebp)
8010188d:	e8 a8 34 00 00       	call   80104d3a <memset>
80101892:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101898:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010189c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010189f:	83 ec 0c             	sub    $0xc,%esp
801018a2:	ff 75 f0             	push   -0x10(%ebp)
801018a5:	e8 7e 1b 00 00       	call   80103428 <log_write>
801018aa:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018ad:	83 ec 0c             	sub    $0xc,%esp
801018b0:	ff 75 f0             	push   -0x10(%ebp)
801018b3:	e8 db e9 ff ff       	call   80100293 <brelse>
801018b8:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018be:	83 ec 08             	sub    $0x8,%esp
801018c1:	50                   	push   %eax
801018c2:	ff 75 08             	push   0x8(%ebp)
801018c5:	e8 fc 00 00 00       	call   801019c6 <iget>
801018ca:	83 c4 10             	add    $0x10,%esp
801018cd:	eb 30                	jmp    801018ff <ialloc+0xd9>
    }
    brelse(bp);
801018cf:	83 ec 0c             	sub    $0xc,%esp
801018d2:	ff 75 f0             	push   -0x10(%ebp)
801018d5:	e8 b9 e9 ff ff       	call   80100293 <brelse>
801018da:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018e1:	8b 15 68 37 19 80    	mov    0x80193768,%edx
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ea:	39 c2                	cmp    %eax,%edx
801018ec:	0f 87 51 ff ff ff    	ja     80101843 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018f2:	83 ec 0c             	sub    $0xc,%esp
801018f5:	68 57 a9 10 80       	push   $0x8010a957
801018fa:	e8 df ec ff ff       	call   801005de <panic>
}
801018ff:	c9                   	leave
80101900:	c3                   	ret

80101901 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101901:	f3 0f 1e fb          	endbr32
80101905:	55                   	push   %ebp
80101906:	89 e5                	mov    %esp,%ebp
80101908:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010190b:	8b 45 08             	mov    0x8(%ebp),%eax
8010190e:	8b 40 04             	mov    0x4(%eax),%eax
80101911:	c1 e8 03             	shr    $0x3,%eax
80101914:	89 c2                	mov    %eax,%edx
80101916:	a1 74 37 19 80       	mov    0x80193774,%eax
8010191b:	01 c2                	add    %eax,%edx
8010191d:	8b 45 08             	mov    0x8(%ebp),%eax
80101920:	8b 00                	mov    (%eax),%eax
80101922:	83 ec 08             	sub    $0x8,%esp
80101925:	52                   	push   %edx
80101926:	50                   	push   %eax
80101927:	e8 dd e8 ff ff       	call   80100209 <bread>
8010192c:	83 c4 10             	add    $0x10,%esp
8010192f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	8d 50 5c             	lea    0x5c(%eax),%edx
80101938:	8b 45 08             	mov    0x8(%ebp),%eax
8010193b:	8b 40 04             	mov    0x4(%eax),%eax
8010193e:	83 e0 07             	and    $0x7,%eax
80101941:	c1 e0 06             	shl    $0x6,%eax
80101944:	01 d0                	add    %edx,%eax
80101946:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101949:	8b 45 08             	mov    0x8(%ebp),%eax
8010194c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101953:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101956:	8b 45 08             	mov    0x8(%ebp),%eax
80101959:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010195d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101960:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010196b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101980:	8b 45 08             	mov    0x8(%ebp),%eax
80101983:	8b 50 58             	mov    0x58(%eax),%edx
80101986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101989:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010198c:	8b 45 08             	mov    0x8(%ebp),%eax
8010198f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101995:	83 c0 0c             	add    $0xc,%eax
80101998:	83 ec 04             	sub    $0x4,%esp
8010199b:	6a 34                	push   $0x34
8010199d:	52                   	push   %edx
8010199e:	50                   	push   %eax
8010199f:	e8 5d 34 00 00       	call   80104e01 <memmove>
801019a4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019a7:	83 ec 0c             	sub    $0xc,%esp
801019aa:	ff 75 f4             	push   -0xc(%ebp)
801019ad:	e8 76 1a 00 00       	call   80103428 <log_write>
801019b2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019b5:	83 ec 0c             	sub    $0xc,%esp
801019b8:	ff 75 f4             	push   -0xc(%ebp)
801019bb:	e8 d3 e8 ff ff       	call   80100293 <brelse>
801019c0:	83 c4 10             	add    $0x10,%esp
}
801019c3:	90                   	nop
801019c4:	c9                   	leave
801019c5:	c3                   	ret

801019c6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019c6:	f3 0f 1e fb          	endbr32
801019ca:	55                   	push   %ebp
801019cb:	89 e5                	mov    %esp,%ebp
801019cd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 80 37 19 80       	push   $0x80193780
801019d8:	e8 ce 30 00 00       	call   80104aab <acquire>
801019dd:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019e7:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
801019ee:	eb 60                	jmp    80101a50 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f3:	8b 40 08             	mov    0x8(%eax),%eax
801019f6:	85 c0                	test   %eax,%eax
801019f8:	7e 39                	jle    80101a33 <iget+0x6d>
801019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fd:	8b 00                	mov    (%eax),%eax
801019ff:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a02:	75 2f                	jne    80101a33 <iget+0x6d>
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 40 04             	mov    0x4(%eax),%eax
80101a0a:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a0d:	75 24                	jne    80101a33 <iget+0x6d>
      ip->ref++;
80101a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a12:	8b 40 08             	mov    0x8(%eax),%eax
80101a15:	8d 50 01             	lea    0x1(%eax),%edx
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a1e:	83 ec 0c             	sub    $0xc,%esp
80101a21:	68 80 37 19 80       	push   $0x80193780
80101a26:	e8 f2 30 00 00       	call   80104b1d <release>
80101a2b:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a31:	eb 77                	jmp    80101aaa <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a37:	75 10                	jne    80101a49 <iget+0x83>
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3c:	8b 40 08             	mov    0x8(%eax),%eax
80101a3f:	85 c0                	test   %eax,%eax
80101a41:	75 06                	jne    80101a49 <iget+0x83>
      empty = ip;
80101a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a49:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a50:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
80101a57:	72 97                	jb     801019f0 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a5d:	75 0d                	jne    80101a6c <iget+0xa6>
    panic("iget: no inodes");
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	68 69 a9 10 80       	push   $0x8010a969
80101a67:	e8 72 eb ff ff       	call   801005de <panic>

  ip = empty;
80101a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a75:	8b 55 08             	mov    0x8(%ebp),%edx
80101a78:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a80:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a86:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a90:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	68 80 37 19 80       	push   $0x80193780
80101a9f:	e8 79 30 00 00       	call   80104b1d <release>
80101aa4:	83 c4 10             	add    $0x10,%esp

  return ip;
80101aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101aaa:	c9                   	leave
80101aab:	c3                   	ret

80101aac <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101aac:	f3 0f 1e fb          	endbr32
80101ab0:	55                   	push   %ebp
80101ab1:	89 e5                	mov    %esp,%ebp
80101ab3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	68 80 37 19 80       	push   $0x80193780
80101abe:	e8 e8 2f 00 00       	call   80104aab <acquire>
80101ac3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	8b 40 08             	mov    0x8(%eax),%eax
80101acc:	8d 50 01             	lea    0x1(%eax),%edx
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad5:	83 ec 0c             	sub    $0xc,%esp
80101ad8:	68 80 37 19 80       	push   $0x80193780
80101add:	e8 3b 30 00 00       	call   80104b1d <release>
80101ae2:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ae8:	c9                   	leave
80101ae9:	c3                   	ret

80101aea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101aea:	f3 0f 1e fb          	endbr32
80101aee:	55                   	push   %ebp
80101aef:	89 e5                	mov    %esp,%ebp
80101af1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101af4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af8:	74 0a                	je     80101b04 <ilock+0x1a>
80101afa:	8b 45 08             	mov    0x8(%ebp),%eax
80101afd:	8b 40 08             	mov    0x8(%eax),%eax
80101b00:	85 c0                	test   %eax,%eax
80101b02:	7f 0d                	jg     80101b11 <ilock+0x27>
    panic("ilock");
80101b04:	83 ec 0c             	sub    $0xc,%esp
80101b07:	68 79 a9 10 80       	push   $0x8010a979
80101b0c:	e8 cd ea ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 38 2e 00 00       	call   80104958 <acquiresleep>
80101b20:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b29:	85 c0                	test   %eax,%eax
80101b2b:	0f 85 cd 00 00 00    	jne    80101bfe <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	8b 40 04             	mov    0x4(%eax),%eax
80101b37:	c1 e8 03             	shr    $0x3,%eax
80101b3a:	89 c2                	mov    %eax,%edx
80101b3c:	a1 74 37 19 80       	mov    0x80193774,%eax
80101b41:	01 c2                	add    %eax,%edx
80101b43:	8b 45 08             	mov    0x8(%ebp),%eax
80101b46:	8b 00                	mov    (%eax),%eax
80101b48:	83 ec 08             	sub    $0x8,%esp
80101b4b:	52                   	push   %edx
80101b4c:	50                   	push   %eax
80101b4d:	e8 b7 e6 ff ff       	call   80100209 <bread>
80101b52:	83 c4 10             	add    $0x10,%esp
80101b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5b:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b61:	8b 40 04             	mov    0x4(%eax),%eax
80101b64:	83 e0 07             	and    $0x7,%eax
80101b67:	c1 e0 06             	shl    $0x6,%eax
80101b6a:	01 d0                	add    %edx,%eax
80101b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b72:	0f b7 10             	movzwl (%eax),%edx
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba9:	8b 50 08             	mov    0x8(%eax),%edx
80101bac:	8b 45 08             	mov    0x8(%ebp),%eax
80101baf:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb5:	8d 50 0c             	lea    0xc(%eax),%edx
80101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbb:	83 c0 5c             	add    $0x5c,%eax
80101bbe:	83 ec 04             	sub    $0x4,%esp
80101bc1:	6a 34                	push   $0x34
80101bc3:	52                   	push   %edx
80101bc4:	50                   	push   %eax
80101bc5:	e8 37 32 00 00       	call   80104e01 <memmove>
80101bca:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bcd:	83 ec 0c             	sub    $0xc,%esp
80101bd0:	ff 75 f4             	push   -0xc(%ebp)
80101bd3:	e8 bb e6 ff ff       	call   80100293 <brelse>
80101bd8:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101be5:	8b 45 08             	mov    0x8(%ebp),%eax
80101be8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101bec:	66 85 c0             	test   %ax,%ax
80101bef:	75 0d                	jne    80101bfe <ilock+0x114>
      panic("ilock: no type");
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 7f a9 10 80       	push   $0x8010a97f
80101bf9:	e8 e0 e9 ff ff       	call   801005de <panic>
  }
}
80101bfe:	90                   	nop
80101bff:	c9                   	leave
80101c00:	c3                   	ret

80101c01 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c01:	f3 0f 1e fb          	endbr32
80101c05:	55                   	push   %ebp
80101c06:	89 e5                	mov    %esp,%ebp
80101c08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c0f:	74 20                	je     80101c31 <iunlock+0x30>
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	83 c0 0c             	add    $0xc,%eax
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	50                   	push   %eax
80101c1b:	e8 f2 2d 00 00       	call   80104a12 <holdingsleep>
80101c20:	83 c4 10             	add    $0x10,%esp
80101c23:	85 c0                	test   %eax,%eax
80101c25:	74 0a                	je     80101c31 <iunlock+0x30>
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	85 c0                	test   %eax,%eax
80101c2f:	7f 0d                	jg     80101c3e <iunlock+0x3d>
    panic("iunlock");
80101c31:	83 ec 0c             	sub    $0xc,%esp
80101c34:	68 8e a9 10 80       	push   $0x8010a98e
80101c39:	e8 a0 e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	83 c0 0c             	add    $0xc,%eax
80101c44:	83 ec 0c             	sub    $0xc,%esp
80101c47:	50                   	push   %eax
80101c48:	e8 73 2d 00 00       	call   801049c0 <releasesleep>
80101c4d:	83 c4 10             	add    $0x10,%esp
}
80101c50:	90                   	nop
80101c51:	c9                   	leave
80101c52:	c3                   	ret

80101c53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c53:	f3 0f 1e fb          	endbr32
80101c57:	55                   	push   %ebp
80101c58:	89 e5                	mov    %esp,%ebp
80101c5a:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	83 c0 0c             	add    $0xc,%eax
80101c63:	83 ec 0c             	sub    $0xc,%esp
80101c66:	50                   	push   %eax
80101c67:	e8 ec 2c 00 00       	call   80104958 <acquiresleep>
80101c6c:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c75:	85 c0                	test   %eax,%eax
80101c77:	74 6a                	je     80101ce3 <iput+0x90>
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c80:	66 85 c0             	test   %ax,%ax
80101c83:	75 5e                	jne    80101ce3 <iput+0x90>
    acquire(&icache.lock);
80101c85:	83 ec 0c             	sub    $0xc,%esp
80101c88:	68 80 37 19 80       	push   $0x80193780
80101c8d:	e8 19 2e 00 00       	call   80104aab <acquire>
80101c92:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c95:	8b 45 08             	mov    0x8(%ebp),%eax
80101c98:	8b 40 08             	mov    0x8(%eax),%eax
80101c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c9e:	83 ec 0c             	sub    $0xc,%esp
80101ca1:	68 80 37 19 80       	push   $0x80193780
80101ca6:	e8 72 2e 00 00       	call   80104b1d <release>
80101cab:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101cae:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cb2:	75 2f                	jne    80101ce3 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cb4:	83 ec 0c             	sub    $0xc,%esp
80101cb7:	ff 75 08             	push   0x8(%ebp)
80101cba:	e8 b5 01 00 00       	call   80101e74 <itrunc>
80101cbf:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101ccb:	83 ec 0c             	sub    $0xc,%esp
80101cce:	ff 75 08             	push   0x8(%ebp)
80101cd1:	e8 2b fc ff ff       	call   80101901 <iupdate>
80101cd6:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce6:	83 c0 0c             	add    $0xc,%eax
80101ce9:	83 ec 0c             	sub    $0xc,%esp
80101cec:	50                   	push   %eax
80101ced:	e8 ce 2c 00 00       	call   801049c0 <releasesleep>
80101cf2:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101cf5:	83 ec 0c             	sub    $0xc,%esp
80101cf8:	68 80 37 19 80       	push   $0x80193780
80101cfd:	e8 a9 2d 00 00       	call   80104aab <acquire>
80101d02:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	8b 40 08             	mov    0x8(%eax),%eax
80101d0b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d14:	83 ec 0c             	sub    $0xc,%esp
80101d17:	68 80 37 19 80       	push   $0x80193780
80101d1c:	e8 fc 2d 00 00       	call   80104b1d <release>
80101d21:	83 c4 10             	add    $0x10,%esp
}
80101d24:	90                   	nop
80101d25:	c9                   	leave
80101d26:	c3                   	ret

80101d27 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d27:	f3 0f 1e fb          	endbr32
80101d2b:	55                   	push   %ebp
80101d2c:	89 e5                	mov    %esp,%ebp
80101d2e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	ff 75 08             	push   0x8(%ebp)
80101d37:	e8 c5 fe ff ff       	call   80101c01 <iunlock>
80101d3c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d3f:	83 ec 0c             	sub    $0xc,%esp
80101d42:	ff 75 08             	push   0x8(%ebp)
80101d45:	e8 09 ff ff ff       	call   80101c53 <iput>
80101d4a:	83 c4 10             	add    $0x10,%esp
}
80101d4d:	90                   	nop
80101d4e:	c9                   	leave
80101d4f:	c3                   	ret

80101d50 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d50:	f3 0f 1e fb          	endbr32
80101d54:	55                   	push   %ebp
80101d55:	89 e5                	mov    %esp,%ebp
80101d57:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d5a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d5e:	77 42                	ja     80101da2 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d66:	83 c2 14             	add    $0x14,%edx
80101d69:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d74:	75 24                	jne    80101d9a <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 00                	mov    (%eax),%eax
80101d7b:	83 ec 0c             	sub    $0xc,%esp
80101d7e:	50                   	push   %eax
80101d7f:	e8 b4 f7 ff ff       	call   80101538 <balloc>
80101d84:	83 c4 10             	add    $0x10,%esp
80101d87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d90:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d96:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9d:	e9 d0 00 00 00       	jmp    80101e72 <bmap+0x122>
  }
  bn -= NDIRECT;
80101da2:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101da6:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101daa:	0f 87 b5 00 00 00    	ja     80101e65 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dc0:	75 20                	jne    80101de2 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 00                	mov    (%eax),%eax
80101dc7:	83 ec 0c             	sub    $0xc,%esp
80101dca:	50                   	push   %eax
80101dcb:	e8 68 f7 ff ff       	call   80101538 <balloc>
80101dd0:	83 c4 10             	add    $0x10,%esp
80101dd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ddc:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 00                	mov    (%eax),%eax
80101de7:	83 ec 08             	sub    $0x8,%esp
80101dea:	ff 75 f4             	push   -0xc(%ebp)
80101ded:	50                   	push   %eax
80101dee:	e8 16 e4 ff ff       	call   80100209 <bread>
80101df3:	83 c4 10             	add    $0x10,%esp
80101df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfc:	83 c0 5c             	add    $0x5c,%eax
80101dff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0f:	01 d0                	add    %edx,%eax
80101e11:	8b 00                	mov    (%eax),%eax
80101e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e1a:	75 36                	jne    80101e52 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	83 ec 0c             	sub    $0xc,%esp
80101e24:	50                   	push   %eax
80101e25:	e8 0e f7 ff ff       	call   80101538 <balloc>
80101e2a:	83 c4 10             	add    $0x10,%esp
80101e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e30:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e3d:	01 c2                	add    %eax,%edx
80101e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e42:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e44:	83 ec 0c             	sub    $0xc,%esp
80101e47:	ff 75 f0             	push   -0x10(%ebp)
80101e4a:	e8 d9 15 00 00       	call   80103428 <log_write>
80101e4f:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e52:	83 ec 0c             	sub    $0xc,%esp
80101e55:	ff 75 f0             	push   -0x10(%ebp)
80101e58:	e8 36 e4 ff ff       	call   80100293 <brelse>
80101e5d:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e63:	eb 0d                	jmp    80101e72 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 96 a9 10 80       	push   $0x8010a996
80101e6d:	e8 6c e7 ff ff       	call   801005de <panic>
}
80101e72:	c9                   	leave
80101e73:	c3                   	ret

80101e74 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e74:	f3 0f 1e fb          	endbr32
80101e78:	55                   	push   %ebp
80101e79:	89 e5                	mov    %esp,%ebp
80101e7b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e85:	eb 45                	jmp    80101ecc <itrunc+0x58>
    if(ip->addrs[i]){
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e8d:	83 c2 14             	add    $0x14,%edx
80101e90:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e94:	85 c0                	test   %eax,%eax
80101e96:	74 30                	je     80101ec8 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e98:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9e:	83 c2 14             	add    $0x14,%edx
80101ea1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ea5:	8b 55 08             	mov    0x8(%ebp),%edx
80101ea8:	8b 12                	mov    (%edx),%edx
80101eaa:	83 ec 08             	sub    $0x8,%esp
80101ead:	50                   	push   %eax
80101eae:	52                   	push   %edx
80101eaf:	e8 d4 f7 ff ff       	call   80101688 <bfree>
80101eb4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebd:	83 c2 14             	add    $0x14,%edx
80101ec0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ec7:	00 
  for(i = 0; i < NDIRECT; i++){
80101ec8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ecc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ed0:	7e b5                	jle    80101e87 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101edb:	85 c0                	test   %eax,%eax
80101edd:	0f 84 aa 00 00 00    	je     80101f8d <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101eec:	8b 45 08             	mov    0x8(%ebp),%eax
80101eef:	8b 00                	mov    (%eax),%eax
80101ef1:	83 ec 08             	sub    $0x8,%esp
80101ef4:	52                   	push   %edx
80101ef5:	50                   	push   %eax
80101ef6:	e8 0e e3 ff ff       	call   80100209 <bread>
80101efb:	83 c4 10             	add    $0x10,%esp
80101efe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f04:	83 c0 5c             	add    $0x5c,%eax
80101f07:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f11:	eb 3c                	jmp    80101f4f <itrunc+0xdb>
      if(a[j])
80101f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f20:	01 d0                	add    %edx,%eax
80101f22:	8b 00                	mov    (%eax),%eax
80101f24:	85 c0                	test   %eax,%eax
80101f26:	74 23                	je     80101f4b <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f35:	01 d0                	add    %edx,%eax
80101f37:	8b 00                	mov    (%eax),%eax
80101f39:	8b 55 08             	mov    0x8(%ebp),%edx
80101f3c:	8b 12                	mov    (%edx),%edx
80101f3e:	83 ec 08             	sub    $0x8,%esp
80101f41:	50                   	push   %eax
80101f42:	52                   	push   %edx
80101f43:	e8 40 f7 ff ff       	call   80101688 <bfree>
80101f48:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f52:	83 f8 7f             	cmp    $0x7f,%eax
80101f55:	76 bc                	jbe    80101f13 <itrunc+0x9f>
    }
    brelse(bp);
80101f57:	83 ec 0c             	sub    $0xc,%esp
80101f5a:	ff 75 ec             	push   -0x14(%ebp)
80101f5d:	e8 31 e3 ff ff       	call   80100293 <brelse>
80101f62:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f6e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f71:	8b 12                	mov    (%edx),%edx
80101f73:	83 ec 08             	sub    $0x8,%esp
80101f76:	50                   	push   %eax
80101f77:	52                   	push   %edx
80101f78:	e8 0b f7 ff ff       	call   80101688 <bfree>
80101f7d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f8a:	00 00 00 
  }

  ip->size = 0;
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f97:	83 ec 0c             	sub    $0xc,%esp
80101f9a:	ff 75 08             	push   0x8(%ebp)
80101f9d:	e8 5f f9 ff ff       	call   80101901 <iupdate>
80101fa2:	83 c4 10             	add    $0x10,%esp
}
80101fa5:	90                   	nop
80101fa6:	c9                   	leave
80101fa7:	c3                   	ret

80101fa8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fa8:	f3 0f 1e fb          	endbr32
80101fac:	55                   	push   %ebp
80101fad:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	8b 00                	mov    (%eax),%eax
80101fb4:	89 c2                	mov    %eax,%edx
80101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbf:	8b 50 04             	mov    0x4(%eax),%edx
80101fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcb:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fdf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	8b 50 58             	mov    0x58(%eax),%edx
80101fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fec:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fef:	90                   	nop
80101ff0:	5d                   	pop    %ebp
80101ff1:	c3                   	ret

80101ff2 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ff2:	f3 0f 1e fb          	endbr32
80101ff6:	55                   	push   %ebp
80101ff7:	89 e5                	mov    %esp,%ebp
80101ff9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fff:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102003:	66 83 f8 03          	cmp    $0x3,%ax
80102007:	75 5c                	jne    80102065 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102009:	8b 45 08             	mov    0x8(%ebp),%eax
8010200c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102010:	66 85 c0             	test   %ax,%ax
80102013:	78 20                	js     80102035 <readi+0x43>
80102015:	8b 45 08             	mov    0x8(%ebp),%eax
80102018:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010201c:	66 83 f8 09          	cmp    $0x9,%ax
80102020:	7f 13                	jg     80102035 <readi+0x43>
80102022:	8b 45 08             	mov    0x8(%ebp),%eax
80102025:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102029:	98                   	cwtl
8010202a:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102031:	85 c0                	test   %eax,%eax
80102033:	75 0a                	jne    8010203f <readi+0x4d>
      return -1;
80102035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010203a:	e9 0a 01 00 00       	jmp    80102149 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	98                   	cwtl
80102047:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
8010204e:	8b 55 14             	mov    0x14(%ebp),%edx
80102051:	83 ec 04             	sub    $0x4,%esp
80102054:	52                   	push   %edx
80102055:	ff 75 0c             	push   0xc(%ebp)
80102058:	ff 75 08             	push   0x8(%ebp)
8010205b:	ff d0                	call   *%eax
8010205d:	83 c4 10             	add    $0x10,%esp
80102060:	e9 e4 00 00 00       	jmp    80102149 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102065:	8b 45 08             	mov    0x8(%ebp),%eax
80102068:	8b 40 58             	mov    0x58(%eax),%eax
8010206b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010206e:	77 0d                	ja     8010207d <readi+0x8b>
80102070:	8b 55 10             	mov    0x10(%ebp),%edx
80102073:	8b 45 14             	mov    0x14(%ebp),%eax
80102076:	01 d0                	add    %edx,%eax
80102078:	39 45 10             	cmp    %eax,0x10(%ebp)
8010207b:	76 0a                	jbe    80102087 <readi+0x95>
    return -1;
8010207d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102082:	e9 c2 00 00 00       	jmp    80102149 <readi+0x157>
  if(off + n > ip->size)
80102087:	8b 55 10             	mov    0x10(%ebp),%edx
8010208a:	8b 45 14             	mov    0x14(%ebp),%eax
8010208d:	01 c2                	add    %eax,%edx
8010208f:	8b 45 08             	mov    0x8(%ebp),%eax
80102092:	8b 40 58             	mov    0x58(%eax),%eax
80102095:	39 c2                	cmp    %eax,%edx
80102097:	76 0c                	jbe    801020a5 <readi+0xb3>
    n = ip->size - off;
80102099:	8b 45 08             	mov    0x8(%ebp),%eax
8010209c:	8b 40 58             	mov    0x58(%eax),%eax
8010209f:	2b 45 10             	sub    0x10(%ebp),%eax
801020a2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ac:	e9 89 00 00 00       	jmp    8010213a <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020b1:	8b 45 10             	mov    0x10(%ebp),%eax
801020b4:	c1 e8 09             	shr    $0x9,%eax
801020b7:	83 ec 08             	sub    $0x8,%esp
801020ba:	50                   	push   %eax
801020bb:	ff 75 08             	push   0x8(%ebp)
801020be:	e8 8d fc ff ff       	call   80101d50 <bmap>
801020c3:	83 c4 10             	add    $0x10,%esp
801020c6:	8b 55 08             	mov    0x8(%ebp),%edx
801020c9:	8b 12                	mov    (%edx),%edx
801020cb:	83 ec 08             	sub    $0x8,%esp
801020ce:	50                   	push   %eax
801020cf:	52                   	push   %edx
801020d0:	e8 34 e1 ff ff       	call   80100209 <bread>
801020d5:	83 c4 10             	add    $0x10,%esp
801020d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020db:	8b 45 10             	mov    0x10(%ebp),%eax
801020de:	25 ff 01 00 00       	and    $0x1ff,%eax
801020e3:	ba 00 02 00 00       	mov    $0x200,%edx
801020e8:	29 c2                	sub    %eax,%edx
801020ea:	8b 45 14             	mov    0x14(%ebp),%eax
801020ed:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020f0:	39 c2                	cmp    %eax,%edx
801020f2:	0f 46 c2             	cmovbe %edx,%eax
801020f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020fb:	8d 50 5c             	lea    0x5c(%eax),%edx
801020fe:	8b 45 10             	mov    0x10(%ebp),%eax
80102101:	25 ff 01 00 00       	and    $0x1ff,%eax
80102106:	01 d0                	add    %edx,%eax
80102108:	83 ec 04             	sub    $0x4,%esp
8010210b:	ff 75 ec             	push   -0x14(%ebp)
8010210e:	50                   	push   %eax
8010210f:	ff 75 0c             	push   0xc(%ebp)
80102112:	e8 ea 2c 00 00       	call   80104e01 <memmove>
80102117:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010211a:	83 ec 0c             	sub    $0xc,%esp
8010211d:	ff 75 f0             	push   -0x10(%ebp)
80102120:	e8 6e e1 ff ff       	call   80100293 <brelse>
80102125:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102128:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010212b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010212e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102131:	01 45 10             	add    %eax,0x10(%ebp)
80102134:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102137:	01 45 0c             	add    %eax,0xc(%ebp)
8010213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102140:	0f 82 6b ff ff ff    	jb     801020b1 <readi+0xbf>
  }
  return n;
80102146:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102149:	c9                   	leave
8010214a:	c3                   	ret

8010214b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010214b:	f3 0f 1e fb          	endbr32
8010214f:	55                   	push   %ebp
80102150:	89 e5                	mov    %esp,%ebp
80102152:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102155:	8b 45 08             	mov    0x8(%ebp),%eax
80102158:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010215c:	66 83 f8 03          	cmp    $0x3,%ax
80102160:	75 5c                	jne    801021be <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102169:	66 85 c0             	test   %ax,%ax
8010216c:	78 20                	js     8010218e <writei+0x43>
8010216e:	8b 45 08             	mov    0x8(%ebp),%eax
80102171:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102175:	66 83 f8 09          	cmp    $0x9,%ax
80102179:	7f 13                	jg     8010218e <writei+0x43>
8010217b:	8b 45 08             	mov    0x8(%ebp),%eax
8010217e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102182:	98                   	cwtl
80102183:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010218a:	85 c0                	test   %eax,%eax
8010218c:	75 0a                	jne    80102198 <writei+0x4d>
      return -1;
8010218e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102193:	e9 3b 01 00 00       	jmp    801022d3 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
8010219b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010219f:	98                   	cwtl
801021a0:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
801021a7:	8b 55 14             	mov    0x14(%ebp),%edx
801021aa:	83 ec 04             	sub    $0x4,%esp
801021ad:	52                   	push   %edx
801021ae:	ff 75 0c             	push   0xc(%ebp)
801021b1:	ff 75 08             	push   0x8(%ebp)
801021b4:	ff d0                	call   *%eax
801021b6:	83 c4 10             	add    $0x10,%esp
801021b9:	e9 15 01 00 00       	jmp    801022d3 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021be:	8b 45 08             	mov    0x8(%ebp),%eax
801021c1:	8b 40 58             	mov    0x58(%eax),%eax
801021c4:	39 45 10             	cmp    %eax,0x10(%ebp)
801021c7:	77 0d                	ja     801021d6 <writei+0x8b>
801021c9:	8b 55 10             	mov    0x10(%ebp),%edx
801021cc:	8b 45 14             	mov    0x14(%ebp),%eax
801021cf:	01 d0                	add    %edx,%eax
801021d1:	39 45 10             	cmp    %eax,0x10(%ebp)
801021d4:	76 0a                	jbe    801021e0 <writei+0x95>
    return -1;
801021d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021db:	e9 f3 00 00 00       	jmp    801022d3 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021e0:	8b 55 10             	mov    0x10(%ebp),%edx
801021e3:	8b 45 14             	mov    0x14(%ebp),%eax
801021e6:	01 d0                	add    %edx,%eax
801021e8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021ed:	76 0a                	jbe    801021f9 <writei+0xae>
    return -1;
801021ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021f4:	e9 da 00 00 00       	jmp    801022d3 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102200:	e9 97 00 00 00       	jmp    8010229c <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102205:	8b 45 10             	mov    0x10(%ebp),%eax
80102208:	c1 e8 09             	shr    $0x9,%eax
8010220b:	83 ec 08             	sub    $0x8,%esp
8010220e:	50                   	push   %eax
8010220f:	ff 75 08             	push   0x8(%ebp)
80102212:	e8 39 fb ff ff       	call   80101d50 <bmap>
80102217:	83 c4 10             	add    $0x10,%esp
8010221a:	8b 55 08             	mov    0x8(%ebp),%edx
8010221d:	8b 12                	mov    (%edx),%edx
8010221f:	83 ec 08             	sub    $0x8,%esp
80102222:	50                   	push   %eax
80102223:	52                   	push   %edx
80102224:	e8 e0 df ff ff       	call   80100209 <bread>
80102229:	83 c4 10             	add    $0x10,%esp
8010222c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010222f:	8b 45 10             	mov    0x10(%ebp),%eax
80102232:	25 ff 01 00 00       	and    $0x1ff,%eax
80102237:	ba 00 02 00 00       	mov    $0x200,%edx
8010223c:	29 c2                	sub    %eax,%edx
8010223e:	8b 45 14             	mov    0x14(%ebp),%eax
80102241:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102244:	39 c2                	cmp    %eax,%edx
80102246:	0f 46 c2             	cmovbe %edx,%eax
80102249:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010224c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010224f:	8d 50 5c             	lea    0x5c(%eax),%edx
80102252:	8b 45 10             	mov    0x10(%ebp),%eax
80102255:	25 ff 01 00 00       	and    $0x1ff,%eax
8010225a:	01 d0                	add    %edx,%eax
8010225c:	83 ec 04             	sub    $0x4,%esp
8010225f:	ff 75 ec             	push   -0x14(%ebp)
80102262:	ff 75 0c             	push   0xc(%ebp)
80102265:	50                   	push   %eax
80102266:	e8 96 2b 00 00       	call   80104e01 <memmove>
8010226b:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010226e:	83 ec 0c             	sub    $0xc,%esp
80102271:	ff 75 f0             	push   -0x10(%ebp)
80102274:	e8 af 11 00 00       	call   80103428 <log_write>
80102279:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010227c:	83 ec 0c             	sub    $0xc,%esp
8010227f:	ff 75 f0             	push   -0x10(%ebp)
80102282:	e8 0c e0 ff ff       	call   80100293 <brelse>
80102287:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010228a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010228d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102290:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102293:	01 45 10             	add    %eax,0x10(%ebp)
80102296:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102299:	01 45 0c             	add    %eax,0xc(%ebp)
8010229c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229f:	3b 45 14             	cmp    0x14(%ebp),%eax
801022a2:	0f 82 5d ff ff ff    	jb     80102205 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022a8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022ac:	74 22                	je     801022d0 <writei+0x185>
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	8b 40 58             	mov    0x58(%eax),%eax
801022b4:	39 45 10             	cmp    %eax,0x10(%ebp)
801022b7:	76 17                	jbe    801022d0 <writei+0x185>
    ip->size = off;
801022b9:	8b 45 08             	mov    0x8(%ebp),%eax
801022bc:	8b 55 10             	mov    0x10(%ebp),%edx
801022bf:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022c2:	83 ec 0c             	sub    $0xc,%esp
801022c5:	ff 75 08             	push   0x8(%ebp)
801022c8:	e8 34 f6 ff ff       	call   80101901 <iupdate>
801022cd:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022d0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022d3:	c9                   	leave
801022d4:	c3                   	ret

801022d5 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022d5:	f3 0f 1e fb          	endbr32
801022d9:	55                   	push   %ebp
801022da:	89 e5                	mov    %esp,%ebp
801022dc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022df:	83 ec 04             	sub    $0x4,%esp
801022e2:	6a 0e                	push   $0xe
801022e4:	ff 75 0c             	push   0xc(%ebp)
801022e7:	ff 75 08             	push   0x8(%ebp)
801022ea:	e8 b0 2b 00 00       	call   80104e9f <strncmp>
801022ef:	83 c4 10             	add    $0x10,%esp
}
801022f2:	c9                   	leave
801022f3:	c3                   	ret

801022f4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022f4:	f3 0f 1e fb          	endbr32
801022f8:	55                   	push   %ebp
801022f9:	89 e5                	mov    %esp,%ebp
801022fb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102301:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102305:	66 83 f8 01          	cmp    $0x1,%ax
80102309:	74 0d                	je     80102318 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010230b:	83 ec 0c             	sub    $0xc,%esp
8010230e:	68 a9 a9 10 80       	push   $0x8010a9a9
80102313:	e8 c6 e2 ff ff       	call   801005de <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102318:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010231f:	eb 7b                	jmp    8010239c <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102321:	6a 10                	push   $0x10
80102323:	ff 75 f4             	push   -0xc(%ebp)
80102326:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102329:	50                   	push   %eax
8010232a:	ff 75 08             	push   0x8(%ebp)
8010232d:	e8 c0 fc ff ff       	call   80101ff2 <readi>
80102332:	83 c4 10             	add    $0x10,%esp
80102335:	83 f8 10             	cmp    $0x10,%eax
80102338:	74 0d                	je     80102347 <dirlookup+0x53>
      panic("dirlookup read");
8010233a:	83 ec 0c             	sub    $0xc,%esp
8010233d:	68 bb a9 10 80       	push   $0x8010a9bb
80102342:	e8 97 e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102347:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010234b:	66 85 c0             	test   %ax,%ax
8010234e:	74 47                	je     80102397 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102350:	83 ec 08             	sub    $0x8,%esp
80102353:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102356:	83 c0 02             	add    $0x2,%eax
80102359:	50                   	push   %eax
8010235a:	ff 75 0c             	push   0xc(%ebp)
8010235d:	e8 73 ff ff ff       	call   801022d5 <namecmp>
80102362:	83 c4 10             	add    $0x10,%esp
80102365:	85 c0                	test   %eax,%eax
80102367:	75 2f                	jne    80102398 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102369:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010236d:	74 08                	je     80102377 <dirlookup+0x83>
        *poff = off;
8010236f:	8b 45 10             	mov    0x10(%ebp),%eax
80102372:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102375:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102377:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010237b:	0f b7 c0             	movzwl %ax,%eax
8010237e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102381:	8b 45 08             	mov    0x8(%ebp),%eax
80102384:	8b 00                	mov    (%eax),%eax
80102386:	83 ec 08             	sub    $0x8,%esp
80102389:	ff 75 f0             	push   -0x10(%ebp)
8010238c:	50                   	push   %eax
8010238d:	e8 34 f6 ff ff       	call   801019c6 <iget>
80102392:	83 c4 10             	add    $0x10,%esp
80102395:	eb 19                	jmp    801023b0 <dirlookup+0xbc>
      continue;
80102397:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102398:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	8b 40 58             	mov    0x58(%eax),%eax
801023a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023a5:	0f 82 76 ff ff ff    	jb     80102321 <dirlookup+0x2d>
    }
  }

  return 0;
801023ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023b0:	c9                   	leave
801023b1:	c3                   	ret

801023b2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023b2:	f3 0f 1e fb          	endbr32
801023b6:	55                   	push   %ebp
801023b7:	89 e5                	mov    %esp,%ebp
801023b9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 00                	push   $0x0
801023c1:	ff 75 0c             	push   0xc(%ebp)
801023c4:	ff 75 08             	push   0x8(%ebp)
801023c7:	e8 28 ff ff ff       	call   801022f4 <dirlookup>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023d6:	74 18                	je     801023f0 <dirlink+0x3e>
    iput(ip);
801023d8:	83 ec 0c             	sub    $0xc,%esp
801023db:	ff 75 f0             	push   -0x10(%ebp)
801023de:	e8 70 f8 ff ff       	call   80101c53 <iput>
801023e3:	83 c4 10             	add    $0x10,%esp
    return -1;
801023e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023eb:	e9 9c 00 00 00       	jmp    8010248c <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023f7:	eb 39                	jmp    80102432 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fc:	6a 10                	push   $0x10
801023fe:	50                   	push   %eax
801023ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102402:	50                   	push   %eax
80102403:	ff 75 08             	push   0x8(%ebp)
80102406:	e8 e7 fb ff ff       	call   80101ff2 <readi>
8010240b:	83 c4 10             	add    $0x10,%esp
8010240e:	83 f8 10             	cmp    $0x10,%eax
80102411:	74 0d                	je     80102420 <dirlink+0x6e>
      panic("dirlink read");
80102413:	83 ec 0c             	sub    $0xc,%esp
80102416:	68 ca a9 10 80       	push   $0x8010a9ca
8010241b:	e8 be e1 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102420:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102424:	66 85 c0             	test   %ax,%ax
80102427:	74 18                	je     80102441 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242c:	83 c0 10             	add    $0x10,%eax
8010242f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102432:	8b 45 08             	mov    0x8(%ebp),%eax
80102435:	8b 50 58             	mov    0x58(%eax),%edx
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	39 c2                	cmp    %eax,%edx
8010243d:	77 ba                	ja     801023f9 <dirlink+0x47>
8010243f:	eb 01                	jmp    80102442 <dirlink+0x90>
      break;
80102441:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102442:	83 ec 04             	sub    $0x4,%esp
80102445:	6a 0e                	push   $0xe
80102447:	ff 75 0c             	push   0xc(%ebp)
8010244a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010244d:	83 c0 02             	add    $0x2,%eax
80102450:	50                   	push   %eax
80102451:	e8 a3 2a 00 00       	call   80104ef9 <strncpy>
80102456:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102459:	8b 45 10             	mov    0x10(%ebp),%eax
8010245c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102463:	6a 10                	push   $0x10
80102465:	50                   	push   %eax
80102466:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102469:	50                   	push   %eax
8010246a:	ff 75 08             	push   0x8(%ebp)
8010246d:	e8 d9 fc ff ff       	call   8010214b <writei>
80102472:	83 c4 10             	add    $0x10,%esp
80102475:	83 f8 10             	cmp    $0x10,%eax
80102478:	74 0d                	je     80102487 <dirlink+0xd5>
    panic("dirlink");
8010247a:	83 ec 0c             	sub    $0xc,%esp
8010247d:	68 d7 a9 10 80       	push   $0x8010a9d7
80102482:	e8 57 e1 ff ff       	call   801005de <panic>

  return 0;
80102487:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010248c:	c9                   	leave
8010248d:	c3                   	ret

8010248e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010248e:	f3 0f 1e fb          	endbr32
80102492:	55                   	push   %ebp
80102493:	89 e5                	mov    %esp,%ebp
80102495:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102498:	eb 04                	jmp    8010249e <skipelem+0x10>
    path++;
8010249a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010249e:	8b 45 08             	mov    0x8(%ebp),%eax
801024a1:	0f b6 00             	movzbl (%eax),%eax
801024a4:	3c 2f                	cmp    $0x2f,%al
801024a6:	74 f2                	je     8010249a <skipelem+0xc>
  if(*path == 0)
801024a8:	8b 45 08             	mov    0x8(%ebp),%eax
801024ab:	0f b6 00             	movzbl (%eax),%eax
801024ae:	84 c0                	test   %al,%al
801024b0:	75 07                	jne    801024b9 <skipelem+0x2b>
    return 0;
801024b2:	b8 00 00 00 00       	mov    $0x0,%eax
801024b7:	eb 77                	jmp    80102530 <skipelem+0xa2>
  s = path;
801024b9:	8b 45 08             	mov    0x8(%ebp),%eax
801024bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024bf:	eb 04                	jmp    801024c5 <skipelem+0x37>
    path++;
801024c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024c5:	8b 45 08             	mov    0x8(%ebp),%eax
801024c8:	0f b6 00             	movzbl (%eax),%eax
801024cb:	3c 2f                	cmp    $0x2f,%al
801024cd:	74 0a                	je     801024d9 <skipelem+0x4b>
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	0f b6 00             	movzbl (%eax),%eax
801024d5:	84 c0                	test   %al,%al
801024d7:	75 e8                	jne    801024c1 <skipelem+0x33>
  len = path - s;
801024d9:	8b 45 08             	mov    0x8(%ebp),%eax
801024dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024e2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024e6:	7e 15                	jle    801024fd <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024e8:	83 ec 04             	sub    $0x4,%esp
801024eb:	6a 0e                	push   $0xe
801024ed:	ff 75 f4             	push   -0xc(%ebp)
801024f0:	ff 75 0c             	push   0xc(%ebp)
801024f3:	e8 09 29 00 00       	call   80104e01 <memmove>
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	eb 26                	jmp    80102523 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102500:	83 ec 04             	sub    $0x4,%esp
80102503:	50                   	push   %eax
80102504:	ff 75 f4             	push   -0xc(%ebp)
80102507:	ff 75 0c             	push   0xc(%ebp)
8010250a:	e8 f2 28 00 00       	call   80104e01 <memmove>
8010250f:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102512:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102515:	8b 45 0c             	mov    0xc(%ebp),%eax
80102518:	01 d0                	add    %edx,%eax
8010251a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010251d:	eb 04                	jmp    80102523 <skipelem+0x95>
    path++;
8010251f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102523:	8b 45 08             	mov    0x8(%ebp),%eax
80102526:	0f b6 00             	movzbl (%eax),%eax
80102529:	3c 2f                	cmp    $0x2f,%al
8010252b:	74 f2                	je     8010251f <skipelem+0x91>
  return path;
8010252d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102530:	c9                   	leave
80102531:	c3                   	ret

80102532 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102532:	f3 0f 1e fb          	endbr32
80102536:	55                   	push   %ebp
80102537:	89 e5                	mov    %esp,%ebp
80102539:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010253c:	8b 45 08             	mov    0x8(%ebp),%eax
8010253f:	0f b6 00             	movzbl (%eax),%eax
80102542:	3c 2f                	cmp    $0x2f,%al
80102544:	75 17                	jne    8010255d <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102546:	83 ec 08             	sub    $0x8,%esp
80102549:	6a 01                	push   $0x1
8010254b:	6a 01                	push   $0x1
8010254d:	e8 74 f4 ff ff       	call   801019c6 <iget>
80102552:	83 c4 10             	add    $0x10,%esp
80102555:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102558:	e9 ba 00 00 00       	jmp    80102617 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010255d:	e8 b5 16 00 00       	call   80103c17 <myproc>
80102562:	8b 40 68             	mov    0x68(%eax),%eax
80102565:	83 ec 0c             	sub    $0xc,%esp
80102568:	50                   	push   %eax
80102569:	e8 3e f5 ff ff       	call   80101aac <idup>
8010256e:	83 c4 10             	add    $0x10,%esp
80102571:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102574:	e9 9e 00 00 00       	jmp    80102617 <namex+0xe5>
    ilock(ip);
80102579:	83 ec 0c             	sub    $0xc,%esp
8010257c:	ff 75 f4             	push   -0xc(%ebp)
8010257f:	e8 66 f5 ff ff       	call   80101aea <ilock>
80102584:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010258a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010258e:	66 83 f8 01          	cmp    $0x1,%ax
80102592:	74 18                	je     801025ac <namex+0x7a>
      iunlockput(ip);
80102594:	83 ec 0c             	sub    $0xc,%esp
80102597:	ff 75 f4             	push   -0xc(%ebp)
8010259a:	e8 88 f7 ff ff       	call   80101d27 <iunlockput>
8010259f:	83 c4 10             	add    $0x10,%esp
      return 0;
801025a2:	b8 00 00 00 00       	mov    $0x0,%eax
801025a7:	e9 a7 00 00 00       	jmp    80102653 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025b0:	74 20                	je     801025d2 <namex+0xa0>
801025b2:	8b 45 08             	mov    0x8(%ebp),%eax
801025b5:	0f b6 00             	movzbl (%eax),%eax
801025b8:	84 c0                	test   %al,%al
801025ba:	75 16                	jne    801025d2 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025bc:	83 ec 0c             	sub    $0xc,%esp
801025bf:	ff 75 f4             	push   -0xc(%ebp)
801025c2:	e8 3a f6 ff ff       	call   80101c01 <iunlock>
801025c7:	83 c4 10             	add    $0x10,%esp
      return ip;
801025ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cd:	e9 81 00 00 00       	jmp    80102653 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025d2:	83 ec 04             	sub    $0x4,%esp
801025d5:	6a 00                	push   $0x0
801025d7:	ff 75 10             	push   0x10(%ebp)
801025da:	ff 75 f4             	push   -0xc(%ebp)
801025dd:	e8 12 fd ff ff       	call   801022f4 <dirlookup>
801025e2:	83 c4 10             	add    $0x10,%esp
801025e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025ec:	75 15                	jne    80102603 <namex+0xd1>
      iunlockput(ip);
801025ee:	83 ec 0c             	sub    $0xc,%esp
801025f1:	ff 75 f4             	push   -0xc(%ebp)
801025f4:	e8 2e f7 ff ff       	call   80101d27 <iunlockput>
801025f9:	83 c4 10             	add    $0x10,%esp
      return 0;
801025fc:	b8 00 00 00 00       	mov    $0x0,%eax
80102601:	eb 50                	jmp    80102653 <namex+0x121>
    }
    iunlockput(ip);
80102603:	83 ec 0c             	sub    $0xc,%esp
80102606:	ff 75 f4             	push   -0xc(%ebp)
80102609:	e8 19 f7 ff ff       	call   80101d27 <iunlockput>
8010260e:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102614:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102617:	83 ec 08             	sub    $0x8,%esp
8010261a:	ff 75 10             	push   0x10(%ebp)
8010261d:	ff 75 08             	push   0x8(%ebp)
80102620:	e8 69 fe ff ff       	call   8010248e <skipelem>
80102625:	83 c4 10             	add    $0x10,%esp
80102628:	89 45 08             	mov    %eax,0x8(%ebp)
8010262b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010262f:	0f 85 44 ff ff ff    	jne    80102579 <namex+0x47>
  }
  if(nameiparent){
80102635:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102639:	74 15                	je     80102650 <namex+0x11e>
    iput(ip);
8010263b:	83 ec 0c             	sub    $0xc,%esp
8010263e:	ff 75 f4             	push   -0xc(%ebp)
80102641:	e8 0d f6 ff ff       	call   80101c53 <iput>
80102646:	83 c4 10             	add    $0x10,%esp
    return 0;
80102649:	b8 00 00 00 00       	mov    $0x0,%eax
8010264e:	eb 03                	jmp    80102653 <namex+0x121>
  }
  return ip;
80102650:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102653:	c9                   	leave
80102654:	c3                   	ret

80102655 <namei>:

struct inode*
namei(char *path)
{
80102655:	f3 0f 1e fb          	endbr32
80102659:	55                   	push   %ebp
8010265a:	89 e5                	mov    %esp,%ebp
8010265c:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010265f:	83 ec 04             	sub    $0x4,%esp
80102662:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102665:	50                   	push   %eax
80102666:	6a 00                	push   $0x0
80102668:	ff 75 08             	push   0x8(%ebp)
8010266b:	e8 c2 fe ff ff       	call   80102532 <namex>
80102670:	83 c4 10             	add    $0x10,%esp
}
80102673:	c9                   	leave
80102674:	c3                   	ret

80102675 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102675:	f3 0f 1e fb          	endbr32
80102679:	55                   	push   %ebp
8010267a:	89 e5                	mov    %esp,%ebp
8010267c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010267f:	83 ec 04             	sub    $0x4,%esp
80102682:	ff 75 0c             	push   0xc(%ebp)
80102685:	6a 01                	push   $0x1
80102687:	ff 75 08             	push   0x8(%ebp)
8010268a:	e8 a3 fe ff ff       	call   80102532 <namex>
8010268f:	83 c4 10             	add    $0x10,%esp
}
80102692:	c9                   	leave
80102693:	c3                   	ret

80102694 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102694:	f3 0f 1e fb          	endbr32
80102698:	55                   	push   %ebp
80102699:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010269b:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026a0:	8b 55 08             	mov    0x8(%ebp),%edx
801026a3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801026a5:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026aa:	8b 40 10             	mov    0x10(%eax),%eax
}
801026ad:	5d                   	pop    %ebp
801026ae:	c3                   	ret

801026af <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801026af:	f3 0f 1e fb          	endbr32
801026b3:	55                   	push   %ebp
801026b4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801026b6:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026bb:	8b 55 08             	mov    0x8(%ebp),%edx
801026be:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801026c0:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801026c8:	89 50 10             	mov    %edx,0x10(%eax)
}
801026cb:	90                   	nop
801026cc:	5d                   	pop    %ebp
801026cd:	c3                   	ret

801026ce <ioapicinit>:

void
ioapicinit(void)
{
801026ce:	f3 0f 1e fb          	endbr32
801026d2:	55                   	push   %ebp
801026d3:	89 e5                	mov    %esp,%ebp
801026d5:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801026d8:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
801026df:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801026e2:	6a 01                	push   $0x1
801026e4:	e8 ab ff ff ff       	call   80102694 <ioapicread>
801026e9:	83 c4 04             	add    $0x4,%esp
801026ec:	c1 e8 10             	shr    $0x10,%eax
801026ef:	25 ff 00 00 00       	and    $0xff,%eax
801026f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801026f7:	6a 00                	push   $0x0
801026f9:	e8 96 ff ff ff       	call   80102694 <ioapicread>
801026fe:	83 c4 04             	add    $0x4,%esp
80102701:	c1 e8 18             	shr    $0x18,%eax
80102704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102707:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
8010270e:	0f b6 c0             	movzbl %al,%eax
80102711:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102714:	74 10                	je     80102726 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102716:	83 ec 0c             	sub    $0xc,%esp
80102719:	68 e0 a9 10 80       	push   $0x8010a9e0
8010271e:	e8 e9 dc ff ff       	call   8010040c <cprintf>
80102723:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010272d:	eb 3f                	jmp    8010276e <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010272f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102732:	83 c0 20             	add    $0x20,%eax
80102735:	0d 00 00 01 00       	or     $0x10000,%eax
8010273a:	89 c2                	mov    %eax,%edx
8010273c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273f:	83 c0 08             	add    $0x8,%eax
80102742:	01 c0                	add    %eax,%eax
80102744:	83 ec 08             	sub    $0x8,%esp
80102747:	52                   	push   %edx
80102748:	50                   	push   %eax
80102749:	e8 61 ff ff ff       	call   801026af <ioapicwrite>
8010274e:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102754:	83 c0 08             	add    $0x8,%eax
80102757:	01 c0                	add    %eax,%eax
80102759:	83 c0 01             	add    $0x1,%eax
8010275c:	83 ec 08             	sub    $0x8,%esp
8010275f:	6a 00                	push   $0x0
80102761:	50                   	push   %eax
80102762:	e8 48 ff ff ff       	call   801026af <ioapicwrite>
80102767:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010276a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102771:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102774:	7e b9                	jle    8010272f <ioapicinit+0x61>
  }
}
80102776:	90                   	nop
80102777:	90                   	nop
80102778:	c9                   	leave
80102779:	c3                   	ret

8010277a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010277a:	f3 0f 1e fb          	endbr32
8010277e:	55                   	push   %ebp
8010277f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102781:	8b 45 08             	mov    0x8(%ebp),%eax
80102784:	83 c0 20             	add    $0x20,%eax
80102787:	89 c2                	mov    %eax,%edx
80102789:	8b 45 08             	mov    0x8(%ebp),%eax
8010278c:	83 c0 08             	add    $0x8,%eax
8010278f:	01 c0                	add    %eax,%eax
80102791:	52                   	push   %edx
80102792:	50                   	push   %eax
80102793:	e8 17 ff ff ff       	call   801026af <ioapicwrite>
80102798:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010279b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010279e:	c1 e0 18             	shl    $0x18,%eax
801027a1:	89 c2                	mov    %eax,%edx
801027a3:	8b 45 08             	mov    0x8(%ebp),%eax
801027a6:	83 c0 08             	add    $0x8,%eax
801027a9:	01 c0                	add    %eax,%eax
801027ab:	83 c0 01             	add    $0x1,%eax
801027ae:	52                   	push   %edx
801027af:	50                   	push   %eax
801027b0:	e8 fa fe ff ff       	call   801026af <ioapicwrite>
801027b5:	83 c4 08             	add    $0x8,%esp
}
801027b8:	90                   	nop
801027b9:	c9                   	leave
801027ba:	c3                   	ret

801027bb <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801027bb:	f3 0f 1e fb          	endbr32
801027bf:	55                   	push   %ebp
801027c0:	89 e5                	mov    %esp,%ebp
801027c2:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 12 aa 10 80       	push   $0x8010aa12
801027cd:	68 e0 53 19 80       	push   $0x801953e0
801027d2:	e8 ae 22 00 00       	call   80104a85 <initlock>
801027d7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801027da:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
801027e1:	00 00 00 
  freerange(vstart, vend);
801027e4:	83 ec 08             	sub    $0x8,%esp
801027e7:	ff 75 0c             	push   0xc(%ebp)
801027ea:	ff 75 08             	push   0x8(%ebp)
801027ed:	e8 2e 00 00 00       	call   80102820 <freerange>
801027f2:	83 c4 10             	add    $0x10,%esp
}
801027f5:	90                   	nop
801027f6:	c9                   	leave
801027f7:	c3                   	ret

801027f8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801027f8:	f3 0f 1e fb          	endbr32
801027fc:	55                   	push   %ebp
801027fd:	89 e5                	mov    %esp,%ebp
801027ff:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102802:	83 ec 08             	sub    $0x8,%esp
80102805:	ff 75 0c             	push   0xc(%ebp)
80102808:	ff 75 08             	push   0x8(%ebp)
8010280b:	e8 10 00 00 00       	call   80102820 <freerange>
80102810:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102813:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
8010281a:	00 00 00 
}
8010281d:	90                   	nop
8010281e:	c9                   	leave
8010281f:	c3                   	ret

80102820 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102820:	f3 0f 1e fb          	endbr32
80102824:	55                   	push   %ebp
80102825:	89 e5                	mov    %esp,%ebp
80102827:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010282a:	8b 45 08             	mov    0x8(%ebp),%eax
8010282d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102832:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010283a:	eb 15                	jmp    80102851 <freerange+0x31>
    kfree(p);
8010283c:	83 ec 0c             	sub    $0xc,%esp
8010283f:	ff 75 f4             	push   -0xc(%ebp)
80102842:	e8 1b 00 00 00       	call   80102862 <kfree>
80102847:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010284a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102854:	05 00 10 00 00       	add    $0x1000,%eax
80102859:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010285c:	73 de                	jae    8010283c <freerange+0x1c>
}
8010285e:	90                   	nop
8010285f:	90                   	nop
80102860:	c9                   	leave
80102861:	c3                   	ret

80102862 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102862:	f3 0f 1e fb          	endbr32
80102866:	55                   	push   %ebp
80102867:	89 e5                	mov    %esp,%ebp
80102869:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010286c:	8b 45 08             	mov    0x8(%ebp),%eax
8010286f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	75 18                	jne    80102890 <kfree+0x2e>
80102878:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010287f:	72 0f                	jb     80102890 <kfree+0x2e>
80102881:	8b 45 08             	mov    0x8(%ebp),%eax
80102884:	05 00 00 00 80       	add    $0x80000000,%eax
80102889:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010288e:	76 0d                	jbe    8010289d <kfree+0x3b>
    panic("kfree");
80102890:	83 ec 0c             	sub    $0xc,%esp
80102893:	68 17 aa 10 80       	push   $0x8010aa17
80102898:	e8 41 dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010289d:	83 ec 04             	sub    $0x4,%esp
801028a0:	68 00 10 00 00       	push   $0x1000
801028a5:	6a 01                	push   $0x1
801028a7:	ff 75 08             	push   0x8(%ebp)
801028aa:	e8 8b 24 00 00       	call   80104d3a <memset>
801028af:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801028b2:	a1 14 54 19 80       	mov    0x80195414,%eax
801028b7:	85 c0                	test   %eax,%eax
801028b9:	74 10                	je     801028cb <kfree+0x69>
    acquire(&kmem.lock);
801028bb:	83 ec 0c             	sub    $0xc,%esp
801028be:	68 e0 53 19 80       	push   $0x801953e0
801028c3:	e8 e3 21 00 00       	call   80104aab <acquire>
801028c8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801028cb:	8b 45 08             	mov    0x8(%ebp),%eax
801028ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801028d1:	8b 15 18 54 19 80    	mov    0x80195418,%edx
801028d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028da:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801028dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028df:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028e4:	a1 14 54 19 80       	mov    0x80195414,%eax
801028e9:	85 c0                	test   %eax,%eax
801028eb:	74 10                	je     801028fd <kfree+0x9b>
    release(&kmem.lock);
801028ed:	83 ec 0c             	sub    $0xc,%esp
801028f0:	68 e0 53 19 80       	push   $0x801953e0
801028f5:	e8 23 22 00 00       	call   80104b1d <release>
801028fa:	83 c4 10             	add    $0x10,%esp
}
801028fd:	90                   	nop
801028fe:	c9                   	leave
801028ff:	c3                   	ret

80102900 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102900:	f3 0f 1e fb          	endbr32
80102904:	55                   	push   %ebp
80102905:	89 e5                	mov    %esp,%ebp
80102907:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010290a:	a1 14 54 19 80       	mov    0x80195414,%eax
8010290f:	85 c0                	test   %eax,%eax
80102911:	74 10                	je     80102923 <kalloc+0x23>
    acquire(&kmem.lock);
80102913:	83 ec 0c             	sub    $0xc,%esp
80102916:	68 e0 53 19 80       	push   $0x801953e0
8010291b:	e8 8b 21 00 00       	call   80104aab <acquire>
80102920:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102923:	a1 18 54 19 80       	mov    0x80195418,%eax
80102928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010292b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010292f:	74 0a                	je     8010293b <kalloc+0x3b>
    kmem.freelist = r->next;
80102931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102934:	8b 00                	mov    (%eax),%eax
80102936:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
8010293b:	a1 14 54 19 80       	mov    0x80195414,%eax
80102940:	85 c0                	test   %eax,%eax
80102942:	74 10                	je     80102954 <kalloc+0x54>
    release(&kmem.lock);
80102944:	83 ec 0c             	sub    $0xc,%esp
80102947:	68 e0 53 19 80       	push   $0x801953e0
8010294c:	e8 cc 21 00 00       	call   80104b1d <release>
80102951:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102954:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102957:	c9                   	leave
80102958:	c3                   	ret

80102959 <inb>:
{
80102959:	55                   	push   %ebp
8010295a:	89 e5                	mov    %esp,%ebp
8010295c:	83 ec 14             	sub    $0x14,%esp
8010295f:	8b 45 08             	mov    0x8(%ebp),%eax
80102962:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102966:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010296a:	89 c2                	mov    %eax,%edx
8010296c:	ec                   	in     (%dx),%al
8010296d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102970:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102974:	c9                   	leave
80102975:	c3                   	ret

80102976 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102976:	f3 0f 1e fb          	endbr32
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102980:	6a 64                	push   $0x64
80102982:	e8 d2 ff ff ff       	call   80102959 <inb>
80102987:	83 c4 04             	add    $0x4,%esp
8010298a:	0f b6 c0             	movzbl %al,%eax
8010298d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102993:	83 e0 01             	and    $0x1,%eax
80102996:	85 c0                	test   %eax,%eax
80102998:	75 0a                	jne    801029a4 <kbdgetc+0x2e>
    return -1;
8010299a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010299f:	e9 23 01 00 00       	jmp    80102ac7 <kbdgetc+0x151>
  data = inb(KBDATAP);
801029a4:	6a 60                	push   $0x60
801029a6:	e8 ae ff ff ff       	call   80102959 <inb>
801029ab:	83 c4 04             	add    $0x4,%esp
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801029b4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801029bb:	75 17                	jne    801029d4 <kbdgetc+0x5e>
    shift |= E0ESC;
801029bd:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029c2:	83 c8 40             	or     $0x40,%eax
801029c5:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ca:	b8 00 00 00 00       	mov    $0x0,%eax
801029cf:	e9 f3 00 00 00       	jmp    80102ac7 <kbdgetc+0x151>
  } else if(data & 0x80){
801029d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029d7:	25 80 00 00 00       	and    $0x80,%eax
801029dc:	85 c0                	test   %eax,%eax
801029de:	74 45                	je     80102a25 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029e0:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029e5:	83 e0 40             	and    $0x40,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	75 08                	jne    801029f4 <kbdgetc+0x7e>
801029ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029ef:	83 e0 7f             	and    $0x7f,%eax
801029f2:	eb 03                	jmp    801029f7 <kbdgetc+0x81>
801029f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801029fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029fd:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a02:	0f b6 00             	movzbl (%eax),%eax
80102a05:	83 c8 40             	or     $0x40,%eax
80102a08:	0f b6 c0             	movzbl %al,%eax
80102a0b:	f7 d0                	not    %eax
80102a0d:	89 c2                	mov    %eax,%edx
80102a0f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a14:	21 d0                	and    %edx,%eax
80102a16:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
80102a1b:	b8 00 00 00 00       	mov    $0x0,%eax
80102a20:	e9 a2 00 00 00       	jmp    80102ac7 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102a25:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2a:	83 e0 40             	and    $0x40,%eax
80102a2d:	85 c0                	test   %eax,%eax
80102a2f:	74 14                	je     80102a45 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a31:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102a38:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a3d:	83 e0 bf             	and    $0xffffffbf,%eax
80102a40:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
80102a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a48:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a4d:	0f b6 00             	movzbl (%eax),%eax
80102a50:	0f b6 d0             	movzbl %al,%edx
80102a53:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a58:	09 d0                	or     %edx,%eax
80102a5a:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a62:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a67:	0f b6 00             	movzbl (%eax),%eax
80102a6a:	0f b6 d0             	movzbl %al,%edx
80102a6d:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a72:	31 d0                	xor    %edx,%eax
80102a74:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a79:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a7e:	83 e0 03             	and    $0x3,%eax
80102a81:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a8b:	01 d0                	add    %edx,%eax
80102a8d:	0f b6 00             	movzbl (%eax),%eax
80102a90:	0f b6 c0             	movzbl %al,%eax
80102a93:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a96:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a9b:	83 e0 08             	and    $0x8,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	74 22                	je     80102ac4 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102aa2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102aa6:	76 0c                	jbe    80102ab4 <kbdgetc+0x13e>
80102aa8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102aac:	77 06                	ja     80102ab4 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102aae:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ab2:	eb 10                	jmp    80102ac4 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ab4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ab8:	76 0a                	jbe    80102ac4 <kbdgetc+0x14e>
80102aba:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102abe:	77 04                	ja     80102ac4 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102ac0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ac4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ac7:	c9                   	leave
80102ac8:	c3                   	ret

80102ac9 <kbdintr>:

void
kbdintr(void)
{
80102ac9:	f3 0f 1e fb          	endbr32
80102acd:	55                   	push   %ebp
80102ace:	89 e5                	mov    %esp,%ebp
80102ad0:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	68 76 29 10 80       	push   $0x80102976
80102adb:	e8 39 dd ff ff       	call   80100819 <consoleintr>
80102ae0:	83 c4 10             	add    $0x10,%esp
}
80102ae3:	90                   	nop
80102ae4:	c9                   	leave
80102ae5:	c3                   	ret

80102ae6 <inb>:
{
80102ae6:	55                   	push   %ebp
80102ae7:	89 e5                	mov    %esp,%ebp
80102ae9:	83 ec 14             	sub    $0x14,%esp
80102aec:	8b 45 08             	mov    0x8(%ebp),%eax
80102aef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102af3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102af7:	89 c2                	mov    %eax,%edx
80102af9:	ec                   	in     (%dx),%al
80102afa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102afd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b01:	c9                   	leave
80102b02:	c3                   	ret

80102b03 <outb>:
{
80102b03:	55                   	push   %ebp
80102b04:	89 e5                	mov    %esp,%ebp
80102b06:	83 ec 08             	sub    $0x8,%esp
80102b09:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b0f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102b13:	89 d0                	mov    %edx,%eax
80102b15:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b18:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102b1c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102b20:	ee                   	out    %al,(%dx)
}
80102b21:	90                   	nop
80102b22:	c9                   	leave
80102b23:	c3                   	ret

80102b24 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102b24:	f3 0f 1e fb          	endbr32
80102b28:	55                   	push   %ebp
80102b29:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102b2b:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b30:	8b 55 08             	mov    0x8(%ebp),%edx
80102b33:	c1 e2 02             	shl    $0x2,%edx
80102b36:	01 c2                	add    %eax,%edx
80102b38:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b3b:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102b3d:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b42:	83 c0 20             	add    $0x20,%eax
80102b45:	8b 00                	mov    (%eax),%eax
}
80102b47:	90                   	nop
80102b48:	5d                   	pop    %ebp
80102b49:	c3                   	ret

80102b4a <lapicinit>:

void
lapicinit(void)
{
80102b4a:	f3 0f 1e fb          	endbr32
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b51:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b56:	85 c0                	test   %eax,%eax
80102b58:	0f 84 0c 01 00 00    	je     80102c6a <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b5e:	68 3f 01 00 00       	push   $0x13f
80102b63:	6a 3c                	push   $0x3c
80102b65:	e8 ba ff ff ff       	call   80102b24 <lapicw>
80102b6a:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b6d:	6a 0b                	push   $0xb
80102b6f:	68 f8 00 00 00       	push   $0xf8
80102b74:	e8 ab ff ff ff       	call   80102b24 <lapicw>
80102b79:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b7c:	68 20 00 02 00       	push   $0x20020
80102b81:	68 c8 00 00 00       	push   $0xc8
80102b86:	e8 99 ff ff ff       	call   80102b24 <lapicw>
80102b8b:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b8e:	68 80 96 98 00       	push   $0x989680
80102b93:	68 e0 00 00 00       	push   $0xe0
80102b98:	e8 87 ff ff ff       	call   80102b24 <lapicw>
80102b9d:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ba0:	68 00 00 01 00       	push   $0x10000
80102ba5:	68 d4 00 00 00       	push   $0xd4
80102baa:	e8 75 ff ff ff       	call   80102b24 <lapicw>
80102baf:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102bb2:	68 00 00 01 00       	push   $0x10000
80102bb7:	68 d8 00 00 00       	push   $0xd8
80102bbc:	e8 63 ff ff ff       	call   80102b24 <lapicw>
80102bc1:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102bc4:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bc9:	83 c0 30             	add    $0x30,%eax
80102bcc:	8b 00                	mov    (%eax),%eax
80102bce:	c1 e8 10             	shr    $0x10,%eax
80102bd1:	25 fc 00 00 00       	and    $0xfc,%eax
80102bd6:	85 c0                	test   %eax,%eax
80102bd8:	74 12                	je     80102bec <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102bda:	68 00 00 01 00       	push   $0x10000
80102bdf:	68 d0 00 00 00       	push   $0xd0
80102be4:	e8 3b ff ff ff       	call   80102b24 <lapicw>
80102be9:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102bec:	6a 33                	push   $0x33
80102bee:	68 dc 00 00 00       	push   $0xdc
80102bf3:	e8 2c ff ff ff       	call   80102b24 <lapicw>
80102bf8:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102bfb:	6a 00                	push   $0x0
80102bfd:	68 a0 00 00 00       	push   $0xa0
80102c02:	e8 1d ff ff ff       	call   80102b24 <lapicw>
80102c07:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102c0a:	6a 00                	push   $0x0
80102c0c:	68 a0 00 00 00       	push   $0xa0
80102c11:	e8 0e ff ff ff       	call   80102b24 <lapicw>
80102c16:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102c19:	6a 00                	push   $0x0
80102c1b:	6a 2c                	push   $0x2c
80102c1d:	e8 02 ff ff ff       	call   80102b24 <lapicw>
80102c22:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102c25:	6a 00                	push   $0x0
80102c27:	68 c4 00 00 00       	push   $0xc4
80102c2c:	e8 f3 fe ff ff       	call   80102b24 <lapicw>
80102c31:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102c34:	68 00 85 08 00       	push   $0x88500
80102c39:	68 c0 00 00 00       	push   $0xc0
80102c3e:	e8 e1 fe ff ff       	call   80102b24 <lapicw>
80102c43:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102c46:	90                   	nop
80102c47:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c4c:	05 00 03 00 00       	add    $0x300,%eax
80102c51:	8b 00                	mov    (%eax),%eax
80102c53:	25 00 10 00 00       	and    $0x1000,%eax
80102c58:	85 c0                	test   %eax,%eax
80102c5a:	75 eb                	jne    80102c47 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102c5c:	6a 00                	push   $0x0
80102c5e:	6a 20                	push   $0x20
80102c60:	e8 bf fe ff ff       	call   80102b24 <lapicw>
80102c65:	83 c4 08             	add    $0x8,%esp
80102c68:	eb 01                	jmp    80102c6b <lapicinit+0x121>
    return;
80102c6a:	90                   	nop
}
80102c6b:	c9                   	leave
80102c6c:	c3                   	ret

80102c6d <lapicid>:

int
lapicid(void)
{
80102c6d:	f3 0f 1e fb          	endbr32
80102c71:	55                   	push   %ebp
80102c72:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c74:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c79:	85 c0                	test   %eax,%eax
80102c7b:	75 07                	jne    80102c84 <lapicid+0x17>
    return 0;
80102c7d:	b8 00 00 00 00       	mov    $0x0,%eax
80102c82:	eb 0d                	jmp    80102c91 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c84:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c89:	83 c0 20             	add    $0x20,%eax
80102c8c:	8b 00                	mov    (%eax),%eax
80102c8e:	c1 e8 18             	shr    $0x18,%eax
}
80102c91:	5d                   	pop    %ebp
80102c92:	c3                   	ret

80102c93 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c93:	f3 0f 1e fb          	endbr32
80102c97:	55                   	push   %ebp
80102c98:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c9a:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c9f:	85 c0                	test   %eax,%eax
80102ca1:	74 0c                	je     80102caf <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102ca3:	6a 00                	push   $0x0
80102ca5:	6a 2c                	push   $0x2c
80102ca7:	e8 78 fe ff ff       	call   80102b24 <lapicw>
80102cac:	83 c4 08             	add    $0x8,%esp
}
80102caf:	90                   	nop
80102cb0:	c9                   	leave
80102cb1:	c3                   	ret

80102cb2 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102cb2:	f3 0f 1e fb          	endbr32
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
}
80102cb9:	90                   	nop
80102cba:	5d                   	pop    %ebp
80102cbb:	c3                   	ret

80102cbc <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102cbc:	f3 0f 1e fb          	endbr32
80102cc0:	55                   	push   %ebp
80102cc1:	89 e5                	mov    %esp,%ebp
80102cc3:	83 ec 14             	sub    $0x14,%esp
80102cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102ccc:	6a 0f                	push   $0xf
80102cce:	6a 70                	push   $0x70
80102cd0:	e8 2e fe ff ff       	call   80102b03 <outb>
80102cd5:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102cd8:	6a 0a                	push   $0xa
80102cda:	6a 71                	push   $0x71
80102cdc:	e8 22 fe ff ff       	call   80102b03 <outb>
80102ce1:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102ce4:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ceb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cee:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf6:	c1 e8 04             	shr    $0x4,%eax
80102cf9:	89 c2                	mov    %eax,%edx
80102cfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cfe:	83 c0 02             	add    $0x2,%eax
80102d01:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102d04:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d08:	c1 e0 18             	shl    $0x18,%eax
80102d0b:	50                   	push   %eax
80102d0c:	68 c4 00 00 00       	push   $0xc4
80102d11:	e8 0e fe ff ff       	call   80102b24 <lapicw>
80102d16:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102d19:	68 00 c5 00 00       	push   $0xc500
80102d1e:	68 c0 00 00 00       	push   $0xc0
80102d23:	e8 fc fd ff ff       	call   80102b24 <lapicw>
80102d28:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d2b:	68 c8 00 00 00       	push   $0xc8
80102d30:	e8 7d ff ff ff       	call   80102cb2 <microdelay>
80102d35:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102d38:	68 00 85 00 00       	push   $0x8500
80102d3d:	68 c0 00 00 00       	push   $0xc0
80102d42:	e8 dd fd ff ff       	call   80102b24 <lapicw>
80102d47:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102d4a:	6a 64                	push   $0x64
80102d4c:	e8 61 ff ff ff       	call   80102cb2 <microdelay>
80102d51:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102d54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102d5b:	eb 3d                	jmp    80102d9a <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102d5d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d61:	c1 e0 18             	shl    $0x18,%eax
80102d64:	50                   	push   %eax
80102d65:	68 c4 00 00 00       	push   $0xc4
80102d6a:	e8 b5 fd ff ff       	call   80102b24 <lapicw>
80102d6f:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d75:	c1 e8 0c             	shr    $0xc,%eax
80102d78:	80 cc 06             	or     $0x6,%ah
80102d7b:	50                   	push   %eax
80102d7c:	68 c0 00 00 00       	push   $0xc0
80102d81:	e8 9e fd ff ff       	call   80102b24 <lapicw>
80102d86:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d89:	68 c8 00 00 00       	push   $0xc8
80102d8e:	e8 1f ff ff ff       	call   80102cb2 <microdelay>
80102d93:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d96:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d9a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d9e:	7e bd                	jle    80102d5d <lapicstartap+0xa1>
  }
}
80102da0:	90                   	nop
80102da1:	90                   	nop
80102da2:	c9                   	leave
80102da3:	c3                   	ret

80102da4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102da4:	f3 0f 1e fb          	endbr32
80102da8:	55                   	push   %ebp
80102da9:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102dab:	8b 45 08             	mov    0x8(%ebp),%eax
80102dae:	0f b6 c0             	movzbl %al,%eax
80102db1:	50                   	push   %eax
80102db2:	6a 70                	push   $0x70
80102db4:	e8 4a fd ff ff       	call   80102b03 <outb>
80102db9:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102dbc:	68 c8 00 00 00       	push   $0xc8
80102dc1:	e8 ec fe ff ff       	call   80102cb2 <microdelay>
80102dc6:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102dc9:	6a 71                	push   $0x71
80102dcb:	e8 16 fd ff ff       	call   80102ae6 <inb>
80102dd0:	83 c4 04             	add    $0x4,%esp
80102dd3:	0f b6 c0             	movzbl %al,%eax
}
80102dd6:	c9                   	leave
80102dd7:	c3                   	ret

80102dd8 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102dd8:	f3 0f 1e fb          	endbr32
80102ddc:	55                   	push   %ebp
80102ddd:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102ddf:	6a 00                	push   $0x0
80102de1:	e8 be ff ff ff       	call   80102da4 <cmos_read>
80102de6:	83 c4 04             	add    $0x4,%esp
80102de9:	8b 55 08             	mov    0x8(%ebp),%edx
80102dec:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102dee:	6a 02                	push   $0x2
80102df0:	e8 af ff ff ff       	call   80102da4 <cmos_read>
80102df5:	83 c4 04             	add    $0x4,%esp
80102df8:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfb:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102dfe:	6a 04                	push   $0x4
80102e00:	e8 9f ff ff ff       	call   80102da4 <cmos_read>
80102e05:	83 c4 04             	add    $0x4,%esp
80102e08:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102e0e:	6a 07                	push   $0x7
80102e10:	e8 8f ff ff ff       	call   80102da4 <cmos_read>
80102e15:	83 c4 04             	add    $0x4,%esp
80102e18:	8b 55 08             	mov    0x8(%ebp),%edx
80102e1b:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102e1e:	6a 08                	push   $0x8
80102e20:	e8 7f ff ff ff       	call   80102da4 <cmos_read>
80102e25:	83 c4 04             	add    $0x4,%esp
80102e28:	8b 55 08             	mov    0x8(%ebp),%edx
80102e2b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102e2e:	6a 09                	push   $0x9
80102e30:	e8 6f ff ff ff       	call   80102da4 <cmos_read>
80102e35:	83 c4 04             	add    $0x4,%esp
80102e38:	8b 55 08             	mov    0x8(%ebp),%edx
80102e3b:	89 42 14             	mov    %eax,0x14(%edx)
}
80102e3e:	90                   	nop
80102e3f:	c9                   	leave
80102e40:	c3                   	ret

80102e41 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102e41:	f3 0f 1e fb          	endbr32
80102e45:	55                   	push   %ebp
80102e46:	89 e5                	mov    %esp,%ebp
80102e48:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102e4b:	6a 0b                	push   $0xb
80102e4d:	e8 52 ff ff ff       	call   80102da4 <cmos_read>
80102e52:	83 c4 04             	add    $0x4,%esp
80102e55:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e5b:	83 e0 04             	and    $0x4,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	0f 94 c0             	sete   %al
80102e63:	0f b6 c0             	movzbl %al,%eax
80102e66:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e69:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e6c:	50                   	push   %eax
80102e6d:	e8 66 ff ff ff       	call   80102dd8 <fill_rtcdate>
80102e72:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e75:	6a 0a                	push   $0xa
80102e77:	e8 28 ff ff ff       	call   80102da4 <cmos_read>
80102e7c:	83 c4 04             	add    $0x4,%esp
80102e7f:	25 80 00 00 00       	and    $0x80,%eax
80102e84:	85 c0                	test   %eax,%eax
80102e86:	75 27                	jne    80102eaf <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e88:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e8b:	50                   	push   %eax
80102e8c:	e8 47 ff ff ff       	call   80102dd8 <fill_rtcdate>
80102e91:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e94:	83 ec 04             	sub    $0x4,%esp
80102e97:	6a 18                	push   $0x18
80102e99:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e9c:	50                   	push   %eax
80102e9d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102ea0:	50                   	push   %eax
80102ea1:	e8 ff 1e 00 00       	call   80104da5 <memcmp>
80102ea6:	83 c4 10             	add    $0x10,%esp
80102ea9:	85 c0                	test   %eax,%eax
80102eab:	74 05                	je     80102eb2 <cmostime+0x71>
80102ead:	eb ba                	jmp    80102e69 <cmostime+0x28>
        continue;
80102eaf:	90                   	nop
    fill_rtcdate(&t1);
80102eb0:	eb b7                	jmp    80102e69 <cmostime+0x28>
      break;
80102eb2:	90                   	nop
  }

  // convert
  if(bcd) {
80102eb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102eb7:	0f 84 b4 00 00 00    	je     80102f71 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ebd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ec0:	c1 e8 04             	shr    $0x4,%eax
80102ec3:	89 c2                	mov    %eax,%edx
80102ec5:	89 d0                	mov    %edx,%eax
80102ec7:	c1 e0 02             	shl    $0x2,%eax
80102eca:	01 d0                	add    %edx,%eax
80102ecc:	01 c0                	add    %eax,%eax
80102ece:	89 c2                	mov    %eax,%edx
80102ed0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ed3:	83 e0 0f             	and    $0xf,%eax
80102ed6:	01 d0                	add    %edx,%eax
80102ed8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102edb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ede:	c1 e8 04             	shr    $0x4,%eax
80102ee1:	89 c2                	mov    %eax,%edx
80102ee3:	89 d0                	mov    %edx,%eax
80102ee5:	c1 e0 02             	shl    $0x2,%eax
80102ee8:	01 d0                	add    %edx,%eax
80102eea:	01 c0                	add    %eax,%eax
80102eec:	89 c2                	mov    %eax,%edx
80102eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ef1:	83 e0 0f             	and    $0xf,%eax
80102ef4:	01 d0                	add    %edx,%eax
80102ef6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102efc:	c1 e8 04             	shr    $0x4,%eax
80102eff:	89 c2                	mov    %eax,%edx
80102f01:	89 d0                	mov    %edx,%eax
80102f03:	c1 e0 02             	shl    $0x2,%eax
80102f06:	01 d0                	add    %edx,%eax
80102f08:	01 c0                	add    %eax,%eax
80102f0a:	89 c2                	mov    %eax,%edx
80102f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102f0f:	83 e0 0f             	and    $0xf,%eax
80102f12:	01 d0                	add    %edx,%eax
80102f14:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102f17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f1a:	c1 e8 04             	shr    $0x4,%eax
80102f1d:	89 c2                	mov    %eax,%edx
80102f1f:	89 d0                	mov    %edx,%eax
80102f21:	c1 e0 02             	shl    $0x2,%eax
80102f24:	01 d0                	add    %edx,%eax
80102f26:	01 c0                	add    %eax,%eax
80102f28:	89 c2                	mov    %eax,%edx
80102f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f2d:	83 e0 0f             	and    $0xf,%eax
80102f30:	01 d0                	add    %edx,%eax
80102f32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f38:	c1 e8 04             	shr    $0x4,%eax
80102f3b:	89 c2                	mov    %eax,%edx
80102f3d:	89 d0                	mov    %edx,%eax
80102f3f:	c1 e0 02             	shl    $0x2,%eax
80102f42:	01 d0                	add    %edx,%eax
80102f44:	01 c0                	add    %eax,%eax
80102f46:	89 c2                	mov    %eax,%edx
80102f48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f4b:	83 e0 0f             	and    $0xf,%eax
80102f4e:	01 d0                	add    %edx,%eax
80102f50:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f56:	c1 e8 04             	shr    $0x4,%eax
80102f59:	89 c2                	mov    %eax,%edx
80102f5b:	89 d0                	mov    %edx,%eax
80102f5d:	c1 e0 02             	shl    $0x2,%eax
80102f60:	01 d0                	add    %edx,%eax
80102f62:	01 c0                	add    %eax,%eax
80102f64:	89 c2                	mov    %eax,%edx
80102f66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f69:	83 e0 0f             	and    $0xf,%eax
80102f6c:	01 d0                	add    %edx,%eax
80102f6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f71:	8b 45 08             	mov    0x8(%ebp),%eax
80102f74:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f77:	89 10                	mov    %edx,(%eax)
80102f79:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f7c:	89 50 04             	mov    %edx,0x4(%eax)
80102f7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f82:	89 50 08             	mov    %edx,0x8(%eax)
80102f85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f88:	89 50 0c             	mov    %edx,0xc(%eax)
80102f8b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f8e:	89 50 10             	mov    %edx,0x10(%eax)
80102f91:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f94:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f97:	8b 45 08             	mov    0x8(%ebp),%eax
80102f9a:	8b 40 14             	mov    0x14(%eax),%eax
80102f9d:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa6:	89 50 14             	mov    %edx,0x14(%eax)
}
80102fa9:	90                   	nop
80102faa:	c9                   	leave
80102fab:	c3                   	ret

80102fac <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102fac:	f3 0f 1e fb          	endbr32
80102fb0:	55                   	push   %ebp
80102fb1:	89 e5                	mov    %esp,%ebp
80102fb3:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102fb6:	83 ec 08             	sub    $0x8,%esp
80102fb9:	68 1d aa 10 80       	push   $0x8010aa1d
80102fbe:	68 20 54 19 80       	push   $0x80195420
80102fc3:	e8 bd 1a 00 00       	call   80104a85 <initlock>
80102fc8:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102fcb:	83 ec 08             	sub    $0x8,%esp
80102fce:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102fd1:	50                   	push   %eax
80102fd2:	ff 75 08             	push   0x8(%ebp)
80102fd5:	e8 c0 e4 ff ff       	call   8010149a <readsb>
80102fda:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102fdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe0:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102fe5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102fe8:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102fed:	8b 45 08             	mov    0x8(%ebp),%eax
80102ff0:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102ff5:	e8 bf 01 00 00       	call   801031b9 <recover_from_log>
}
80102ffa:	90                   	nop
80102ffb:	c9                   	leave
80102ffc:	c3                   	ret

80102ffd <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102ffd:	f3 0f 1e fb          	endbr32
80103001:	55                   	push   %ebp
80103002:	89 e5                	mov    %esp,%ebp
80103004:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103007:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010300e:	e9 95 00 00 00       	jmp    801030a8 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103013:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010301c:	01 d0                	add    %edx,%eax
8010301e:	83 c0 01             	add    $0x1,%eax
80103021:	89 c2                	mov    %eax,%edx
80103023:	a1 64 54 19 80       	mov    0x80195464,%eax
80103028:	83 ec 08             	sub    $0x8,%esp
8010302b:	52                   	push   %edx
8010302c:	50                   	push   %eax
8010302d:	e8 d7 d1 ff ff       	call   80100209 <bread>
80103032:	83 c4 10             	add    $0x10,%esp
80103035:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303b:	83 c0 10             	add    $0x10,%eax
8010303e:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103045:	89 c2                	mov    %eax,%edx
80103047:	a1 64 54 19 80       	mov    0x80195464,%eax
8010304c:	83 ec 08             	sub    $0x8,%esp
8010304f:	52                   	push   %edx
80103050:	50                   	push   %eax
80103051:	e8 b3 d1 ff ff       	call   80100209 <bread>
80103056:	83 c4 10             	add    $0x10,%esp
80103059:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010305c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010305f:	8d 50 5c             	lea    0x5c(%eax),%edx
80103062:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103065:	83 c0 5c             	add    $0x5c,%eax
80103068:	83 ec 04             	sub    $0x4,%esp
8010306b:	68 00 02 00 00       	push   $0x200
80103070:	52                   	push   %edx
80103071:	50                   	push   %eax
80103072:	e8 8a 1d 00 00       	call   80104e01 <memmove>
80103077:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010307a:	83 ec 0c             	sub    $0xc,%esp
8010307d:	ff 75 ec             	push   -0x14(%ebp)
80103080:	e8 c1 d1 ff ff       	call   80100246 <bwrite>
80103085:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103088:	83 ec 0c             	sub    $0xc,%esp
8010308b:	ff 75 f0             	push   -0x10(%ebp)
8010308e:	e8 00 d2 ff ff       	call   80100293 <brelse>
80103093:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103096:	83 ec 0c             	sub    $0xc,%esp
80103099:	ff 75 ec             	push   -0x14(%ebp)
8010309c:	e8 f2 d1 ff ff       	call   80100293 <brelse>
801030a1:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801030a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a8:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ad:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b0:	0f 8c 5d ff ff ff    	jl     80103013 <install_trans+0x16>
  }
}
801030b6:	90                   	nop
801030b7:	90                   	nop
801030b8:	c9                   	leave
801030b9:	c3                   	ret

801030ba <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030ba:	f3 0f 1e fb          	endbr32
801030be:	55                   	push   %ebp
801030bf:	89 e5                	mov    %esp,%ebp
801030c1:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030c4:	a1 54 54 19 80       	mov    0x80195454,%eax
801030c9:	89 c2                	mov    %eax,%edx
801030cb:	a1 64 54 19 80       	mov    0x80195464,%eax
801030d0:	83 ec 08             	sub    $0x8,%esp
801030d3:	52                   	push   %edx
801030d4:	50                   	push   %eax
801030d5:	e8 2f d1 ff ff       	call   80100209 <bread>
801030da:	83 c4 10             	add    $0x10,%esp
801030dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030e3:	83 c0 5c             	add    $0x5c,%eax
801030e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ec:	8b 00                	mov    (%eax),%eax
801030ee:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
801030f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030fa:	eb 1b                	jmp    80103117 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801030fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103102:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103106:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103109:	83 c2 10             	add    $0x10,%edx
8010310c:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103113:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103117:	a1 68 54 19 80       	mov    0x80195468,%eax
8010311c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010311f:	7c db                	jl     801030fc <read_head+0x42>
  }
  brelse(buf);
80103121:	83 ec 0c             	sub    $0xc,%esp
80103124:	ff 75 f0             	push   -0x10(%ebp)
80103127:	e8 67 d1 ff ff       	call   80100293 <brelse>
8010312c:	83 c4 10             	add    $0x10,%esp
}
8010312f:	90                   	nop
80103130:	c9                   	leave
80103131:	c3                   	ret

80103132 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103132:	f3 0f 1e fb          	endbr32
80103136:	55                   	push   %ebp
80103137:	89 e5                	mov    %esp,%ebp
80103139:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010313c:	a1 54 54 19 80       	mov    0x80195454,%eax
80103141:	89 c2                	mov    %eax,%edx
80103143:	a1 64 54 19 80       	mov    0x80195464,%eax
80103148:	83 ec 08             	sub    $0x8,%esp
8010314b:	52                   	push   %edx
8010314c:	50                   	push   %eax
8010314d:	e8 b7 d0 ff ff       	call   80100209 <bread>
80103152:	83 c4 10             	add    $0x10,%esp
80103155:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010315b:	83 c0 5c             	add    $0x5c,%eax
8010315e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103161:	8b 15 68 54 19 80    	mov    0x80195468,%edx
80103167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010316a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010316c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103173:	eb 1b                	jmp    80103190 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103178:	83 c0 10             	add    $0x10,%eax
8010317b:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103185:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103188:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010318c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103190:	a1 68 54 19 80       	mov    0x80195468,%eax
80103195:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103198:	7c db                	jl     80103175 <write_head+0x43>
  }
  bwrite(buf);
8010319a:	83 ec 0c             	sub    $0xc,%esp
8010319d:	ff 75 f0             	push   -0x10(%ebp)
801031a0:	e8 a1 d0 ff ff       	call   80100246 <bwrite>
801031a5:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801031a8:	83 ec 0c             	sub    $0xc,%esp
801031ab:	ff 75 f0             	push   -0x10(%ebp)
801031ae:	e8 e0 d0 ff ff       	call   80100293 <brelse>
801031b3:	83 c4 10             	add    $0x10,%esp
}
801031b6:	90                   	nop
801031b7:	c9                   	leave
801031b8:	c3                   	ret

801031b9 <recover_from_log>:

static void
recover_from_log(void)
{
801031b9:	f3 0f 1e fb          	endbr32
801031bd:	55                   	push   %ebp
801031be:	89 e5                	mov    %esp,%ebp
801031c0:	83 ec 08             	sub    $0x8,%esp
  read_head();
801031c3:	e8 f2 fe ff ff       	call   801030ba <read_head>
  install_trans(); // if committed, copy from log to disk
801031c8:	e8 30 fe ff ff       	call   80102ffd <install_trans>
  log.lh.n = 0;
801031cd:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801031d4:	00 00 00 
  write_head(); // clear the log
801031d7:	e8 56 ff ff ff       	call   80103132 <write_head>
}
801031dc:	90                   	nop
801031dd:	c9                   	leave
801031de:	c3                   	ret

801031df <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801031df:	f3 0f 1e fb          	endbr32
801031e3:	55                   	push   %ebp
801031e4:	89 e5                	mov    %esp,%ebp
801031e6:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801031e9:	83 ec 0c             	sub    $0xc,%esp
801031ec:	68 20 54 19 80       	push   $0x80195420
801031f1:	e8 b5 18 00 00       	call   80104aab <acquire>
801031f6:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801031f9:	a1 60 54 19 80       	mov    0x80195460,%eax
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 17                	je     80103219 <begin_op+0x3a>
      sleep(&log, &log.lock);
80103202:	83 ec 08             	sub    $0x8,%esp
80103205:	68 20 54 19 80       	push   $0x80195420
8010320a:	68 20 54 19 80       	push   $0x80195420
8010320f:	e8 0e 13 00 00       	call   80104522 <sleep>
80103214:	83 c4 10             	add    $0x10,%esp
80103217:	eb e0                	jmp    801031f9 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103219:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
8010321f:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103224:	8d 50 01             	lea    0x1(%eax),%edx
80103227:	89 d0                	mov    %edx,%eax
80103229:	c1 e0 02             	shl    $0x2,%eax
8010322c:	01 d0                	add    %edx,%eax
8010322e:	01 c0                	add    %eax,%eax
80103230:	01 c8                	add    %ecx,%eax
80103232:	83 f8 1e             	cmp    $0x1e,%eax
80103235:	7e 17                	jle    8010324e <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103237:	83 ec 08             	sub    $0x8,%esp
8010323a:	68 20 54 19 80       	push   $0x80195420
8010323f:	68 20 54 19 80       	push   $0x80195420
80103244:	e8 d9 12 00 00       	call   80104522 <sleep>
80103249:	83 c4 10             	add    $0x10,%esp
8010324c:	eb ab                	jmp    801031f9 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
8010324e:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103253:	83 c0 01             	add    $0x1,%eax
80103256:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
8010325b:	83 ec 0c             	sub    $0xc,%esp
8010325e:	68 20 54 19 80       	push   $0x80195420
80103263:	e8 b5 18 00 00       	call   80104b1d <release>
80103268:	83 c4 10             	add    $0x10,%esp
      break;
8010326b:	90                   	nop
    }
  }
}
8010326c:	90                   	nop
8010326d:	c9                   	leave
8010326e:	c3                   	ret

8010326f <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010326f:	f3 0f 1e fb          	endbr32
80103273:	55                   	push   %ebp
80103274:	89 e5                	mov    %esp,%ebp
80103276:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103279:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103280:	83 ec 0c             	sub    $0xc,%esp
80103283:	68 20 54 19 80       	push   $0x80195420
80103288:	e8 1e 18 00 00       	call   80104aab <acquire>
8010328d:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103290:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103295:	83 e8 01             	sub    $0x1,%eax
80103298:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010329d:	a1 60 54 19 80       	mov    0x80195460,%eax
801032a2:	85 c0                	test   %eax,%eax
801032a4:	74 0d                	je     801032b3 <end_op+0x44>
    panic("log.committing");
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 21 aa 10 80       	push   $0x8010aa21
801032ae:	e8 2b d3 ff ff       	call   801005de <panic>
  if(log.outstanding == 0){
801032b3:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801032b8:	85 c0                	test   %eax,%eax
801032ba:	75 13                	jne    801032cf <end_op+0x60>
    do_commit = 1;
801032bc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801032c3:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
801032ca:	00 00 00 
801032cd:	eb 10                	jmp    801032df <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801032cf:	83 ec 0c             	sub    $0xc,%esp
801032d2:	68 20 54 19 80       	push   $0x80195420
801032d7:	e8 35 13 00 00       	call   80104611 <wakeup>
801032dc:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801032df:	83 ec 0c             	sub    $0xc,%esp
801032e2:	68 20 54 19 80       	push   $0x80195420
801032e7:	e8 31 18 00 00       	call   80104b1d <release>
801032ec:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801032ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801032f3:	74 3f                	je     80103334 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801032f5:	e8 fa 00 00 00       	call   801033f4 <commit>
    acquire(&log.lock);
801032fa:	83 ec 0c             	sub    $0xc,%esp
801032fd:	68 20 54 19 80       	push   $0x80195420
80103302:	e8 a4 17 00 00       	call   80104aab <acquire>
80103307:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010330a:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
80103311:	00 00 00 
    wakeup(&log);
80103314:	83 ec 0c             	sub    $0xc,%esp
80103317:	68 20 54 19 80       	push   $0x80195420
8010331c:	e8 f0 12 00 00       	call   80104611 <wakeup>
80103321:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103324:	83 ec 0c             	sub    $0xc,%esp
80103327:	68 20 54 19 80       	push   $0x80195420
8010332c:	e8 ec 17 00 00       	call   80104b1d <release>
80103331:	83 c4 10             	add    $0x10,%esp
  }
}
80103334:	90                   	nop
80103335:	c9                   	leave
80103336:	c3                   	ret

80103337 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103337:	f3 0f 1e fb          	endbr32
8010333b:	55                   	push   %ebp
8010333c:	89 e5                	mov    %esp,%ebp
8010333e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103341:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103348:	e9 95 00 00 00       	jmp    801033e2 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010334d:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103356:	01 d0                	add    %edx,%eax
80103358:	83 c0 01             	add    $0x1,%eax
8010335b:	89 c2                	mov    %eax,%edx
8010335d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103362:	83 ec 08             	sub    $0x8,%esp
80103365:	52                   	push   %edx
80103366:	50                   	push   %eax
80103367:	e8 9d ce ff ff       	call   80100209 <bread>
8010336c:	83 c4 10             	add    $0x10,%esp
8010336f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103375:	83 c0 10             	add    $0x10,%eax
80103378:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 64 54 19 80       	mov    0x80195464,%eax
80103386:	83 ec 08             	sub    $0x8,%esp
80103389:	52                   	push   %edx
8010338a:	50                   	push   %eax
8010338b:	e8 79 ce ff ff       	call   80100209 <bread>
80103390:	83 c4 10             	add    $0x10,%esp
80103393:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103396:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103399:	8d 50 5c             	lea    0x5c(%eax),%edx
8010339c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010339f:	83 c0 5c             	add    $0x5c,%eax
801033a2:	83 ec 04             	sub    $0x4,%esp
801033a5:	68 00 02 00 00       	push   $0x200
801033aa:	52                   	push   %edx
801033ab:	50                   	push   %eax
801033ac:	e8 50 1a 00 00       	call   80104e01 <memmove>
801033b1:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801033b4:	83 ec 0c             	sub    $0xc,%esp
801033b7:	ff 75 f0             	push   -0x10(%ebp)
801033ba:	e8 87 ce ff ff       	call   80100246 <bwrite>
801033bf:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801033c2:	83 ec 0c             	sub    $0xc,%esp
801033c5:	ff 75 ec             	push   -0x14(%ebp)
801033c8:	e8 c6 ce ff ff       	call   80100293 <brelse>
801033cd:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801033d0:	83 ec 0c             	sub    $0xc,%esp
801033d3:	ff 75 f0             	push   -0x10(%ebp)
801033d6:	e8 b8 ce ff ff       	call   80100293 <brelse>
801033db:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033e2:	a1 68 54 19 80       	mov    0x80195468,%eax
801033e7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033ea:	0f 8c 5d ff ff ff    	jl     8010334d <write_log+0x16>
  }
}
801033f0:	90                   	nop
801033f1:	90                   	nop
801033f2:	c9                   	leave
801033f3:	c3                   	ret

801033f4 <commit>:

static void
commit()
{
801033f4:	f3 0f 1e fb          	endbr32
801033f8:	55                   	push   %ebp
801033f9:	89 e5                	mov    %esp,%ebp
801033fb:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033fe:	a1 68 54 19 80       	mov    0x80195468,%eax
80103403:	85 c0                	test   %eax,%eax
80103405:	7e 1e                	jle    80103425 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103407:	e8 2b ff ff ff       	call   80103337 <write_log>
    write_head();    // Write header to disk -- the real commit
8010340c:	e8 21 fd ff ff       	call   80103132 <write_head>
    install_trans(); // Now install writes to home locations
80103411:	e8 e7 fb ff ff       	call   80102ffd <install_trans>
    log.lh.n = 0;
80103416:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
8010341d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103420:	e8 0d fd ff ff       	call   80103132 <write_head>
  }
}
80103425:	90                   	nop
80103426:	c9                   	leave
80103427:	c3                   	ret

80103428 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103428:	f3 0f 1e fb          	endbr32
8010342c:	55                   	push   %ebp
8010342d:	89 e5                	mov    %esp,%ebp
8010342f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103432:	a1 68 54 19 80       	mov    0x80195468,%eax
80103437:	83 f8 1d             	cmp    $0x1d,%eax
8010343a:	7f 12                	jg     8010344e <log_write+0x26>
8010343c:	a1 68 54 19 80       	mov    0x80195468,%eax
80103441:	8b 15 58 54 19 80    	mov    0x80195458,%edx
80103447:	83 ea 01             	sub    $0x1,%edx
8010344a:	39 d0                	cmp    %edx,%eax
8010344c:	7c 0d                	jl     8010345b <log_write+0x33>
    panic("too big a transaction");
8010344e:	83 ec 0c             	sub    $0xc,%esp
80103451:	68 30 aa 10 80       	push   $0x8010aa30
80103456:	e8 83 d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
8010345b:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103460:	85 c0                	test   %eax,%eax
80103462:	7f 0d                	jg     80103471 <log_write+0x49>
    panic("log_write outside of trans");
80103464:	83 ec 0c             	sub    $0xc,%esp
80103467:	68 46 aa 10 80       	push   $0x8010aa46
8010346c:	e8 6d d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103471:	83 ec 0c             	sub    $0xc,%esp
80103474:	68 20 54 19 80       	push   $0x80195420
80103479:	e8 2d 16 00 00       	call   80104aab <acquire>
8010347e:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103481:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103488:	eb 1d                	jmp    801034a7 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010348a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010348d:	83 c0 10             	add    $0x10,%eax
80103490:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103497:	89 c2                	mov    %eax,%edx
80103499:	8b 45 08             	mov    0x8(%ebp),%eax
8010349c:	8b 40 08             	mov    0x8(%eax),%eax
8010349f:	39 c2                	cmp    %eax,%edx
801034a1:	74 10                	je     801034b3 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801034a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034a7:	a1 68 54 19 80       	mov    0x80195468,%eax
801034ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034af:	7c d9                	jl     8010348a <log_write+0x62>
801034b1:	eb 01                	jmp    801034b4 <log_write+0x8c>
      break;
801034b3:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801034b4:	8b 45 08             	mov    0x8(%ebp),%eax
801034b7:	8b 40 08             	mov    0x8(%eax),%eax
801034ba:	89 c2                	mov    %eax,%edx
801034bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bf:	83 c0 10             	add    $0x10,%eax
801034c2:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
801034c9:	a1 68 54 19 80       	mov    0x80195468,%eax
801034ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034d1:	75 0d                	jne    801034e0 <log_write+0xb8>
    log.lh.n++;
801034d3:	a1 68 54 19 80       	mov    0x80195468,%eax
801034d8:	83 c0 01             	add    $0x1,%eax
801034db:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
801034e0:	8b 45 08             	mov    0x8(%ebp),%eax
801034e3:	8b 00                	mov    (%eax),%eax
801034e5:	83 c8 04             	or     $0x4,%eax
801034e8:	89 c2                	mov    %eax,%edx
801034ea:	8b 45 08             	mov    0x8(%ebp),%eax
801034ed:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801034ef:	83 ec 0c             	sub    $0xc,%esp
801034f2:	68 20 54 19 80       	push   $0x80195420
801034f7:	e8 21 16 00 00       	call   80104b1d <release>
801034fc:	83 c4 10             	add    $0x10,%esp
}
801034ff:	90                   	nop
80103500:	c9                   	leave
80103501:	c3                   	ret

80103502 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103502:	55                   	push   %ebp
80103503:	89 e5                	mov    %esp,%ebp
80103505:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103508:	8b 55 08             	mov    0x8(%ebp),%edx
8010350b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010350e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103511:	f0 87 02             	lock xchg %eax,(%edx)
80103514:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103517:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010351a:	c9                   	leave
8010351b:	c3                   	ret

8010351c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010351c:	f3 0f 1e fb          	endbr32
80103520:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103524:	83 e4 f0             	and    $0xfffffff0,%esp
80103527:	ff 71 fc             	push   -0x4(%ecx)
8010352a:	55                   	push   %ebp
8010352b:	89 e5                	mov    %esp,%ebp
8010352d:	51                   	push   %ecx
8010352e:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103531:	e8 14 4f 00 00       	call   8010844a <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103536:	83 ec 08             	sub    $0x8,%esp
80103539:	68 00 00 40 80       	push   $0x80400000
8010353e:	68 00 90 19 80       	push   $0x80199000
80103543:	e8 73 f2 ff ff       	call   801027bb <kinit1>
80103548:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010354b:	e8 ec 44 00 00       	call   80107a3c <kvmalloc>
  mpinit_uefi();
80103550:	e8 ae 4c 00 00       	call   80108203 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103555:	e8 f0 f5 ff ff       	call   80102b4a <lapicinit>
  seginit();       // segment descriptors
8010355a:	e8 64 3f 00 00       	call   801074c3 <seginit>
  picinit();    // disable pic
8010355f:	e8 a9 01 00 00       	call   8010370d <picinit>
  ioapicinit();    // another interrupt controller
80103564:	e8 65 f1 ff ff       	call   801026ce <ioapicinit>
  consoleinit();   // console hardware
80103569:	e8 e4 d5 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
8010356e:	e8 d9 32 00 00       	call   8010684c <uartinit>
  pinit();         // process table
80103573:	e8 e2 05 00 00       	call   80103b5a <pinit>
  tvinit();        // trap vectors
80103578:	e8 9c 2d 00 00       	call   80106319 <tvinit>
  binit();         // buffer cache
8010357d:	e8 e4 ca ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103582:	e8 e8 da ff ff       	call   8010106f <fileinit>
  ideinit();       // disk 
80103587:	e8 c3 70 00 00       	call   8010a64f <ideinit>
  startothers();   // start other processors
8010358c:	e8 92 00 00 00       	call   80103623 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103591:	83 ec 08             	sub    $0x8,%esp
80103594:	68 00 00 00 a0       	push   $0xa0000000
80103599:	68 00 00 40 80       	push   $0x80400000
8010359e:	e8 55 f2 ff ff       	call   801027f8 <kinit2>
801035a3:	83 c4 10             	add    $0x10,%esp
  pci_init();
801035a6:	e8 12 51 00 00       	call   801086bd <pci_init>
  arp_scan();
801035ab:	e8 8b 5e 00 00       	call   8010943b <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801035b0:	e8 9b 07 00 00       	call   80103d50 <userinit>
  mpmain();        // finish this processor's setup
801035b5:	e8 1e 00 00 00       	call   801035d8 <mpmain>

801035ba <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801035ba:	f3 0f 1e fb          	endbr32
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801035c4:	e8 8f 44 00 00       	call   80107a58 <switchkvm>
  seginit();
801035c9:	e8 f5 3e 00 00       	call   801074c3 <seginit>
  lapicinit();
801035ce:	e8 77 f5 ff ff       	call   80102b4a <lapicinit>
  mpmain();
801035d3:	e8 00 00 00 00       	call   801035d8 <mpmain>

801035d8 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035d8:	f3 0f 1e fb          	endbr32
801035dc:	55                   	push   %ebp
801035dd:	89 e5                	mov    %esp,%ebp
801035df:	53                   	push   %ebx
801035e0:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801035e3:	e8 94 05 00 00       	call   80103b7c <cpuid>
801035e8:	89 c3                	mov    %eax,%ebx
801035ea:	e8 8d 05 00 00       	call   80103b7c <cpuid>
801035ef:	83 ec 04             	sub    $0x4,%esp
801035f2:	53                   	push   %ebx
801035f3:	50                   	push   %eax
801035f4:	68 61 aa 10 80       	push   $0x8010aa61
801035f9:	e8 0e ce ff ff       	call   8010040c <cprintf>
801035fe:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103601:	e8 8d 2e 00 00       	call   80106493 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103606:	e8 90 05 00 00       	call   80103b9b <mycpu>
8010360b:	05 a0 00 00 00       	add    $0xa0,%eax
80103610:	83 ec 08             	sub    $0x8,%esp
80103613:	6a 01                	push   $0x1
80103615:	50                   	push   %eax
80103616:	e8 e7 fe ff ff       	call   80103502 <xchg>
8010361b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010361e:	e8 dc 0c 00 00       	call   801042ff <scheduler>

80103623 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103623:	f3 0f 1e fb          	endbr32
80103627:	55                   	push   %ebp
80103628:	89 e5                	mov    %esp,%ebp
8010362a:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010362d:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103634:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103639:	83 ec 04             	sub    $0x4,%esp
8010363c:	50                   	push   %eax
8010363d:	68 18 f5 10 80       	push   $0x8010f518
80103642:	ff 75 f0             	push   -0x10(%ebp)
80103645:	e8 b7 17 00 00       	call   80104e01 <memmove>
8010364a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010364d:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
80103654:	eb 79                	jmp    801036cf <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103656:	e8 40 05 00 00       	call   80103b9b <mycpu>
8010365b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010365e:	74 67                	je     801036c7 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103660:	e8 9b f2 ff ff       	call   80102900 <kalloc>
80103665:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366b:	83 e8 04             	sub    $0x4,%eax
8010366e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103671:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103677:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367c:	83 e8 08             	sub    $0x8,%eax
8010367f:	c7 00 ba 35 10 80    	movl   $0x801035ba,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103685:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010368a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103690:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103693:	83 e8 0c             	sub    $0xc,%eax
80103696:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801036a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a4:	0f b6 00             	movzbl (%eax),%eax
801036a7:	0f b6 c0             	movzbl %al,%eax
801036aa:	83 ec 08             	sub    $0x8,%esp
801036ad:	52                   	push   %edx
801036ae:	50                   	push   %eax
801036af:	e8 08 f6 ff ff       	call   80102cbc <lapicstartap>
801036b4:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801036b7:	90                   	nop
801036b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801036c1:	85 c0                	test   %eax,%eax
801036c3:	74 f3                	je     801036b8 <startothers+0x95>
801036c5:	eb 01                	jmp    801036c8 <startothers+0xa5>
      continue;
801036c7:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801036c8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801036cf:	a1 80 80 19 80       	mov    0x80198080,%eax
801036d4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801036da:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801036df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036e2:	0f 82 6e ff ff ff    	jb     80103656 <startothers+0x33>
      ;
  }
}
801036e8:	90                   	nop
801036e9:	90                   	nop
801036ea:	c9                   	leave
801036eb:	c3                   	ret

801036ec <outb>:
{
801036ec:	55                   	push   %ebp
801036ed:	89 e5                	mov    %esp,%ebp
801036ef:	83 ec 08             	sub    $0x8,%esp
801036f2:	8b 45 08             	mov    0x8(%ebp),%eax
801036f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801036f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801036fc:	89 d0                	mov    %edx,%eax
801036fe:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103701:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103705:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103709:	ee                   	out    %al,(%dx)
}
8010370a:	90                   	nop
8010370b:	c9                   	leave
8010370c:	c3                   	ret

8010370d <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010370d:	f3 0f 1e fb          	endbr32
80103711:	55                   	push   %ebp
80103712:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103714:	68 ff 00 00 00       	push   $0xff
80103719:	6a 21                	push   $0x21
8010371b:	e8 cc ff ff ff       	call   801036ec <outb>
80103720:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103723:	68 ff 00 00 00       	push   $0xff
80103728:	68 a1 00 00 00       	push   $0xa1
8010372d:	e8 ba ff ff ff       	call   801036ec <outb>
80103732:	83 c4 08             	add    $0x8,%esp
}
80103735:	90                   	nop
80103736:	c9                   	leave
80103737:	c3                   	ret

80103738 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103738:	f3 0f 1e fb          	endbr32
8010373c:	55                   	push   %ebp
8010373d:	89 e5                	mov    %esp,%ebp
8010373f:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103749:	8b 45 0c             	mov    0xc(%ebp),%eax
8010374c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103752:	8b 45 0c             	mov    0xc(%ebp),%eax
80103755:	8b 10                	mov    (%eax),%edx
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010375c:	e8 30 d9 ff ff       	call   80101091 <filealloc>
80103761:	8b 55 08             	mov    0x8(%ebp),%edx
80103764:	89 02                	mov    %eax,(%edx)
80103766:	8b 45 08             	mov    0x8(%ebp),%eax
80103769:	8b 00                	mov    (%eax),%eax
8010376b:	85 c0                	test   %eax,%eax
8010376d:	0f 84 c8 00 00 00    	je     8010383b <pipealloc+0x103>
80103773:	e8 19 d9 ff ff       	call   80101091 <filealloc>
80103778:	8b 55 0c             	mov    0xc(%ebp),%edx
8010377b:	89 02                	mov    %eax,(%edx)
8010377d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103780:	8b 00                	mov    (%eax),%eax
80103782:	85 c0                	test   %eax,%eax
80103784:	0f 84 b1 00 00 00    	je     8010383b <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010378a:	e8 71 f1 ff ff       	call   80102900 <kalloc>
8010378f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103792:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103796:	0f 84 a2 00 00 00    	je     8010383e <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010379c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801037a6:	00 00 00 
  p->writeopen = 1;
801037a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ac:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801037b3:	00 00 00 
  p->nwrite = 0;
801037b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801037c0:	00 00 00 
  p->nread = 0;
801037c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801037cd:	00 00 00 
  initlock(&p->lock, "pipe");
801037d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d3:	83 ec 08             	sub    $0x8,%esp
801037d6:	68 75 aa 10 80       	push   $0x8010aa75
801037db:	50                   	push   %eax
801037dc:	e8 a4 12 00 00       	call   80104a85 <initlock>
801037e1:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037e4:	8b 45 08             	mov    0x8(%ebp),%eax
801037e7:	8b 00                	mov    (%eax),%eax
801037e9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037ef:	8b 45 08             	mov    0x8(%ebp),%eax
801037f2:	8b 00                	mov    (%eax),%eax
801037f4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037f8:	8b 45 08             	mov    0x8(%ebp),%eax
801037fb:	8b 00                	mov    (%eax),%eax
801037fd:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103801:	8b 45 08             	mov    0x8(%ebp),%eax
80103804:	8b 00                	mov    (%eax),%eax
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010380c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380f:	8b 00                	mov    (%eax),%eax
80103811:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010381a:	8b 00                	mov    (%eax),%eax
8010381c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103820:	8b 45 0c             	mov    0xc(%ebp),%eax
80103823:	8b 00                	mov    (%eax),%eax
80103825:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103829:	8b 45 0c             	mov    0xc(%ebp),%eax
8010382c:	8b 00                	mov    (%eax),%eax
8010382e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103831:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103834:	b8 00 00 00 00       	mov    $0x0,%eax
80103839:	eb 51                	jmp    8010388c <pipealloc+0x154>
    goto bad;
8010383b:	90                   	nop
8010383c:	eb 01                	jmp    8010383f <pipealloc+0x107>
    goto bad;
8010383e:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010383f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103843:	74 0e                	je     80103853 <pipealloc+0x11b>
    kfree((char*)p);
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	ff 75 f4             	push   -0xc(%ebp)
8010384b:	e8 12 f0 ff ff       	call   80102862 <kfree>
80103850:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103853:	8b 45 08             	mov    0x8(%ebp),%eax
80103856:	8b 00                	mov    (%eax),%eax
80103858:	85 c0                	test   %eax,%eax
8010385a:	74 11                	je     8010386d <pipealloc+0x135>
    fileclose(*f0);
8010385c:	8b 45 08             	mov    0x8(%ebp),%eax
8010385f:	8b 00                	mov    (%eax),%eax
80103861:	83 ec 0c             	sub    $0xc,%esp
80103864:	50                   	push   %eax
80103865:	e8 ed d8 ff ff       	call   80101157 <fileclose>
8010386a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010386d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103870:	8b 00                	mov    (%eax),%eax
80103872:	85 c0                	test   %eax,%eax
80103874:	74 11                	je     80103887 <pipealloc+0x14f>
    fileclose(*f1);
80103876:	8b 45 0c             	mov    0xc(%ebp),%eax
80103879:	8b 00                	mov    (%eax),%eax
8010387b:	83 ec 0c             	sub    $0xc,%esp
8010387e:	50                   	push   %eax
8010387f:	e8 d3 d8 ff ff       	call   80101157 <fileclose>
80103884:	83 c4 10             	add    $0x10,%esp
  return -1;
80103887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010388c:	c9                   	leave
8010388d:	c3                   	ret

8010388e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010388e:	f3 0f 1e fb          	endbr32
80103892:	55                   	push   %ebp
80103893:	89 e5                	mov    %esp,%ebp
80103895:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103898:	8b 45 08             	mov    0x8(%ebp),%eax
8010389b:	83 ec 0c             	sub    $0xc,%esp
8010389e:	50                   	push   %eax
8010389f:	e8 07 12 00 00       	call   80104aab <acquire>
801038a4:	83 c4 10             	add    $0x10,%esp
  if(writable){
801038a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801038ab:	74 23                	je     801038d0 <pipeclose+0x42>
    p->writeopen = 0;
801038ad:	8b 45 08             	mov    0x8(%ebp),%eax
801038b0:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801038b7:	00 00 00 
    wakeup(&p->nread);
801038ba:	8b 45 08             	mov    0x8(%ebp),%eax
801038bd:	05 34 02 00 00       	add    $0x234,%eax
801038c2:	83 ec 0c             	sub    $0xc,%esp
801038c5:	50                   	push   %eax
801038c6:	e8 46 0d 00 00       	call   80104611 <wakeup>
801038cb:	83 c4 10             	add    $0x10,%esp
801038ce:	eb 21                	jmp    801038f1 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801038d0:	8b 45 08             	mov    0x8(%ebp),%eax
801038d3:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801038da:	00 00 00 
    wakeup(&p->nwrite);
801038dd:	8b 45 08             	mov    0x8(%ebp),%eax
801038e0:	05 38 02 00 00       	add    $0x238,%eax
801038e5:	83 ec 0c             	sub    $0xc,%esp
801038e8:	50                   	push   %eax
801038e9:	e8 23 0d 00 00       	call   80104611 <wakeup>
801038ee:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801038f1:	8b 45 08             	mov    0x8(%ebp),%eax
801038f4:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fa:	85 c0                	test   %eax,%eax
801038fc:	75 2c                	jne    8010392a <pipeclose+0x9c>
801038fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103901:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103907:	85 c0                	test   %eax,%eax
80103909:	75 1f                	jne    8010392a <pipeclose+0x9c>
    release(&p->lock);
8010390b:	8b 45 08             	mov    0x8(%ebp),%eax
8010390e:	83 ec 0c             	sub    $0xc,%esp
80103911:	50                   	push   %eax
80103912:	e8 06 12 00 00       	call   80104b1d <release>
80103917:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010391a:	83 ec 0c             	sub    $0xc,%esp
8010391d:	ff 75 08             	push   0x8(%ebp)
80103920:	e8 3d ef ff ff       	call   80102862 <kfree>
80103925:	83 c4 10             	add    $0x10,%esp
80103928:	eb 10                	jmp    8010393a <pipeclose+0xac>
  } else
    release(&p->lock);
8010392a:	8b 45 08             	mov    0x8(%ebp),%eax
8010392d:	83 ec 0c             	sub    $0xc,%esp
80103930:	50                   	push   %eax
80103931:	e8 e7 11 00 00       	call   80104b1d <release>
80103936:	83 c4 10             	add    $0x10,%esp
}
80103939:	90                   	nop
8010393a:	90                   	nop
8010393b:	c9                   	leave
8010393c:	c3                   	ret

8010393d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010393d:	f3 0f 1e fb          	endbr32
80103941:	55                   	push   %ebp
80103942:	89 e5                	mov    %esp,%ebp
80103944:	53                   	push   %ebx
80103945:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103948:	8b 45 08             	mov    0x8(%ebp),%eax
8010394b:	83 ec 0c             	sub    $0xc,%esp
8010394e:	50                   	push   %eax
8010394f:	e8 57 11 00 00       	call   80104aab <acquire>
80103954:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103957:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010395e:	e9 ad 00 00 00       	jmp    80103a10 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103963:	8b 45 08             	mov    0x8(%ebp),%eax
80103966:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010396c:	85 c0                	test   %eax,%eax
8010396e:	74 0c                	je     8010397c <pipewrite+0x3f>
80103970:	e8 a2 02 00 00       	call   80103c17 <myproc>
80103975:	8b 40 24             	mov    0x24(%eax),%eax
80103978:	85 c0                	test   %eax,%eax
8010397a:	74 19                	je     80103995 <pipewrite+0x58>
        release(&p->lock);
8010397c:	8b 45 08             	mov    0x8(%ebp),%eax
8010397f:	83 ec 0c             	sub    $0xc,%esp
80103982:	50                   	push   %eax
80103983:	e8 95 11 00 00       	call   80104b1d <release>
80103988:	83 c4 10             	add    $0x10,%esp
        return -1;
8010398b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103990:	e9 a9 00 00 00       	jmp    80103a3e <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103995:	8b 45 08             	mov    0x8(%ebp),%eax
80103998:	05 34 02 00 00       	add    $0x234,%eax
8010399d:	83 ec 0c             	sub    $0xc,%esp
801039a0:	50                   	push   %eax
801039a1:	e8 6b 0c 00 00       	call   80104611 <wakeup>
801039a6:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801039a9:	8b 45 08             	mov    0x8(%ebp),%eax
801039ac:	8b 55 08             	mov    0x8(%ebp),%edx
801039af:	81 c2 38 02 00 00    	add    $0x238,%edx
801039b5:	83 ec 08             	sub    $0x8,%esp
801039b8:	50                   	push   %eax
801039b9:	52                   	push   %edx
801039ba:	e8 63 0b 00 00       	call   80104522 <sleep>
801039bf:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801039c2:	8b 45 08             	mov    0x8(%ebp),%eax
801039c5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801039cb:	8b 45 08             	mov    0x8(%ebp),%eax
801039ce:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801039d4:	05 00 02 00 00       	add    $0x200,%eax
801039d9:	39 c2                	cmp    %eax,%edx
801039db:	74 86                	je     80103963 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801039e6:	8b 45 08             	mov    0x8(%ebp),%eax
801039e9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801039ef:	8d 48 01             	lea    0x1(%eax),%ecx
801039f2:	8b 55 08             	mov    0x8(%ebp),%edx
801039f5:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801039fb:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a00:	89 c1                	mov    %eax,%ecx
80103a02:	0f b6 13             	movzbl (%ebx),%edx
80103a05:	8b 45 08             	mov    0x8(%ebp),%eax
80103a08:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103a0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a13:	3b 45 10             	cmp    0x10(%ebp),%eax
80103a16:	7c aa                	jl     801039c2 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103a18:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1b:	05 34 02 00 00       	add    $0x234,%eax
80103a20:	83 ec 0c             	sub    $0xc,%esp
80103a23:	50                   	push   %eax
80103a24:	e8 e8 0b 00 00       	call   80104611 <wakeup>
80103a29:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2f:	83 ec 0c             	sub    $0xc,%esp
80103a32:	50                   	push   %eax
80103a33:	e8 e5 10 00 00       	call   80104b1d <release>
80103a38:	83 c4 10             	add    $0x10,%esp
  return n;
80103a3b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a41:	c9                   	leave
80103a42:	c3                   	ret

80103a43 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103a43:	f3 0f 1e fb          	endbr32
80103a47:	55                   	push   %ebp
80103a48:	89 e5                	mov    %esp,%ebp
80103a4a:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a50:	83 ec 0c             	sub    $0xc,%esp
80103a53:	50                   	push   %eax
80103a54:	e8 52 10 00 00       	call   80104aab <acquire>
80103a59:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a5c:	eb 3e                	jmp    80103a9c <piperead+0x59>
    if(myproc()->killed){
80103a5e:	e8 b4 01 00 00       	call   80103c17 <myproc>
80103a63:	8b 40 24             	mov    0x24(%eax),%eax
80103a66:	85 c0                	test   %eax,%eax
80103a68:	74 19                	je     80103a83 <piperead+0x40>
      release(&p->lock);
80103a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6d:	83 ec 0c             	sub    $0xc,%esp
80103a70:	50                   	push   %eax
80103a71:	e8 a7 10 00 00       	call   80104b1d <release>
80103a76:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a7e:	e9 be 00 00 00       	jmp    80103b41 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a83:	8b 45 08             	mov    0x8(%ebp),%eax
80103a86:	8b 55 08             	mov    0x8(%ebp),%edx
80103a89:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a8f:	83 ec 08             	sub    $0x8,%esp
80103a92:	50                   	push   %eax
80103a93:	52                   	push   %edx
80103a94:	e8 89 0a 00 00       	call   80104522 <sleep>
80103a99:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103aae:	39 c2                	cmp    %eax,%edx
80103ab0:	75 0d                	jne    80103abf <piperead+0x7c>
80103ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103abb:	85 c0                	test   %eax,%eax
80103abd:	75 9f                	jne    80103a5e <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ac6:	eb 48                	jmp    80103b10 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80103acb:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ada:	39 c2                	cmp    %eax,%edx
80103adc:	74 3c                	je     80103b1a <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103ade:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ae7:	8d 48 01             	lea    0x1(%eax),%ecx
80103aea:	8b 55 08             	mov    0x8(%ebp),%edx
80103aed:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103af3:	25 ff 01 00 00       	and    $0x1ff,%eax
80103af8:	89 c1                	mov    %eax,%ecx
80103afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b00:	01 c2                	add    %eax,%edx
80103b02:	8b 45 08             	mov    0x8(%ebp),%eax
80103b05:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103b0a:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103b0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	3b 45 10             	cmp    0x10(%ebp),%eax
80103b16:	7c b0                	jl     80103ac8 <piperead+0x85>
80103b18:	eb 01                	jmp    80103b1b <piperead+0xd8>
      break;
80103b1a:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1e:	05 38 02 00 00       	add    $0x238,%eax
80103b23:	83 ec 0c             	sub    $0xc,%esp
80103b26:	50                   	push   %eax
80103b27:	e8 e5 0a 00 00       	call   80104611 <wakeup>
80103b2c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b32:	83 ec 0c             	sub    $0xc,%esp
80103b35:	50                   	push   %eax
80103b36:	e8 e2 0f 00 00       	call   80104b1d <release>
80103b3b:	83 c4 10             	add    $0x10,%esp
  return i;
80103b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b41:	c9                   	leave
80103b42:	c3                   	ret

80103b43 <readeflags>:
{
80103b43:	55                   	push   %ebp
80103b44:	89 e5                	mov    %esp,%ebp
80103b46:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b49:	9c                   	pushf
80103b4a:	58                   	pop    %eax
80103b4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b51:	c9                   	leave
80103b52:	c3                   	ret

80103b53 <sti>:
{
80103b53:	55                   	push   %ebp
80103b54:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103b56:	fb                   	sti
}
80103b57:	90                   	nop
80103b58:	5d                   	pop    %ebp
80103b59:	c3                   	ret

80103b5a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103b5a:	f3 0f 1e fb          	endbr32
80103b5e:	55                   	push   %ebp
80103b5f:	89 e5                	mov    %esp,%ebp
80103b61:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b64:	83 ec 08             	sub    $0x8,%esp
80103b67:	68 7c aa 10 80       	push   $0x8010aa7c
80103b6c:	68 00 55 19 80       	push   $0x80195500
80103b71:	e8 0f 0f 00 00       	call   80104a85 <initlock>
80103b76:	83 c4 10             	add    $0x10,%esp
}
80103b79:	90                   	nop
80103b7a:	c9                   	leave
80103b7b:	c3                   	ret

80103b7c <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b7c:	f3 0f 1e fb          	endbr32
80103b80:	55                   	push   %ebp
80103b81:	89 e5                	mov    %esp,%ebp
80103b83:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b86:	e8 10 00 00 00       	call   80103b9b <mycpu>
80103b8b:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b90:	c1 f8 04             	sar    $0x4,%eax
80103b93:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b99:	c9                   	leave
80103b9a:	c3                   	ret

80103b9b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b9b:	f3 0f 1e fb          	endbr32
80103b9f:	55                   	push   %ebp
80103ba0:	89 e5                	mov    %esp,%ebp
80103ba2:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ba5:	e8 99 ff ff ff       	call   80103b43 <readeflags>
80103baa:	25 00 02 00 00       	and    $0x200,%eax
80103baf:	85 c0                	test   %eax,%eax
80103bb1:	74 0d                	je     80103bc0 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103bb3:	83 ec 0c             	sub    $0xc,%esp
80103bb6:	68 84 aa 10 80       	push   $0x8010aa84
80103bbb:	e8 1e ca ff ff       	call   801005de <panic>
  }

  apicid = lapicid();
80103bc0:	e8 a8 f0 ff ff       	call   80102c6d <lapicid>
80103bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103bc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bcf:	eb 2d                	jmp    80103bfe <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bda:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bdf:	0f b6 00             	movzbl (%eax),%eax
80103be2:	0f b6 c0             	movzbl %al,%eax
80103be5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103be8:	75 10                	jne    80103bfa <mycpu+0x5f>
      return &cpus[i];
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bf3:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bf8:	eb 1b                	jmp    80103c15 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103bfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bfe:	a1 80 80 19 80       	mov    0x80198080,%eax
80103c03:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c06:	7c c9                	jl     80103bd1 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103c08:	83 ec 0c             	sub    $0xc,%esp
80103c0b:	68 aa aa 10 80       	push   $0x8010aaaa
80103c10:	e8 c9 c9 ff ff       	call   801005de <panic>
}
80103c15:	c9                   	leave
80103c16:	c3                   	ret

80103c17 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103c17:	f3 0f 1e fb          	endbr32
80103c1b:	55                   	push   %ebp
80103c1c:	89 e5                	mov    %esp,%ebp
80103c1e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103c21:	e8 01 10 00 00       	call   80104c27 <pushcli>
  c = mycpu();
80103c26:	e8 70 ff ff ff       	call   80103b9b <mycpu>
80103c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103c3a:	e8 39 10 00 00       	call   80104c78 <popcli>
  return p;
80103c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c42:	c9                   	leave
80103c43:	c3                   	ret

80103c44 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103c44:	f3 0f 1e fb          	endbr32
80103c48:	55                   	push   %ebp
80103c49:	89 e5                	mov    %esp,%ebp
80103c4b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	68 00 55 19 80       	push   $0x80195500
80103c56:	e8 50 0e 00 00       	call   80104aab <acquire>
80103c5b:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c5e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c65:	eb 0e                	jmp    80103c75 <allocproc+0x31>
    if(p->state == UNUSED){
80103c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6a:	8b 40 0c             	mov    0xc(%eax),%eax
80103c6d:	85 c0                	test   %eax,%eax
80103c6f:	74 27                	je     80103c98 <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c71:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c75:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c7c:	72 e9                	jb     80103c67 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c7e:	83 ec 0c             	sub    $0xc,%esp
80103c81:	68 00 55 19 80       	push   $0x80195500
80103c86:	e8 92 0e 00 00       	call   80104b1d <release>
80103c8b:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c8e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c93:	e9 b6 00 00 00       	jmp    80103d4e <allocproc+0x10a>
      goto found;
80103c98:	90                   	nop
80103c99:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ca7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103cac:	8d 50 01             	lea    0x1(%eax),%edx
80103caf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103cb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103cbb:	83 ec 0c             	sub    $0xc,%esp
80103cbe:	68 00 55 19 80       	push   $0x80195500
80103cc3:	e8 55 0e 00 00       	call   80104b1d <release>
80103cc8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ccb:	e8 30 ec ff ff       	call   80102900 <kalloc>
80103cd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd3:	89 42 08             	mov    %eax,0x8(%edx)
80103cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd9:	8b 40 08             	mov    0x8(%eax),%eax
80103cdc:	85 c0                	test   %eax,%eax
80103cde:	75 11                	jne    80103cf1 <allocproc+0xad>
    p->state = UNUSED;
80103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103cea:	b8 00 00 00 00       	mov    $0x0,%eax
80103cef:	eb 5d                	jmp    80103d4e <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf4:	8b 40 08             	mov    0x8(%eax),%eax
80103cf7:	05 00 10 00 00       	add    $0x1000,%eax
80103cfc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103cff:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d09:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103d0c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103d10:	ba d3 62 10 80       	mov    $0x801062d3,%edx
80103d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d18:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d1a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d24:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d2d:	83 ec 04             	sub    $0x4,%esp
80103d30:	6a 14                	push   $0x14
80103d32:	6a 00                	push   $0x0
80103d34:	50                   	push   %eax
80103d35:	e8 00 10 00 00       	call   80104d3a <memset>
80103d3a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d40:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d43:	ba d8 44 10 80       	mov    $0x801044d8,%edx
80103d48:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d4e:	c9                   	leave
80103d4f:	c3                   	ret

80103d50 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d50:	f3 0f 1e fb          	endbr32
80103d54:	55                   	push   %ebp
80103d55:	89 e5                	mov    %esp,%ebp
80103d57:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103d5a:	83 ec 0c             	sub    $0xc,%esp
80103d5d:	68 ba aa 10 80       	push   $0x8010aaba
80103d62:	e8 a5 c6 ff ff       	call   8010040c <cprintf>
80103d67:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d6a:	e8 d5 fe ff ff       	call   80103c44 <allocproc>
80103d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d75:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d7a:	e8 cc 3b 00 00       	call   8010794b <setupkvm>
80103d7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d82:	89 42 04             	mov    %eax,0x4(%edx)
80103d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d88:	8b 40 04             	mov    0x4(%eax),%eax
80103d8b:	85 c0                	test   %eax,%eax
80103d8d:	75 0d                	jne    80103d9c <userinit+0x4c>
    panic("userinit: out of memory?");
80103d8f:	83 ec 0c             	sub    $0xc,%esp
80103d92:	68 ca aa 10 80       	push   $0x8010aaca
80103d97:	e8 42 c8 ff ff       	call   801005de <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d9c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da4:	8b 40 04             	mov    0x4(%eax),%eax
80103da7:	83 ec 04             	sub    $0x4,%esp
80103daa:	52                   	push   %edx
80103dab:	68 ec f4 10 80       	push   $0x8010f4ec
80103db0:	50                   	push   %eax
80103db1:	e8 62 3e 00 00       	call   80107c18 <inituvm>
80103db6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbc:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc5:	8b 40 18             	mov    0x18(%eax),%eax
80103dc8:	83 ec 04             	sub    $0x4,%esp
80103dcb:	6a 4c                	push   $0x4c
80103dcd:	6a 00                	push   $0x0
80103dcf:	50                   	push   %eax
80103dd0:	e8 65 0f 00 00       	call   80104d3a <memset>
80103dd5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddb:	8b 40 18             	mov    0x18(%eax),%eax
80103dde:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de7:	8b 40 18             	mov    0x18(%eax),%eax
80103dea:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df3:	8b 50 18             	mov    0x18(%eax),%edx
80103df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df9:	8b 40 18             	mov    0x18(%eax),%eax
80103dfc:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e00:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e07:	8b 50 18             	mov    0x18(%eax),%edx
80103e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0d:	8b 40 18             	mov    0x18(%eax),%eax
80103e10:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e14:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1b:	8b 40 18             	mov    0x18(%eax),%eax
80103e1e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e28:	8b 40 18             	mov    0x18(%eax),%eax
80103e2b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e35:	8b 40 18             	mov    0x18(%eax),%eax
80103e38:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e42:	83 c0 6c             	add    $0x6c,%eax
80103e45:	83 ec 04             	sub    $0x4,%esp
80103e48:	6a 10                	push   $0x10
80103e4a:	68 e3 aa 10 80       	push   $0x8010aae3
80103e4f:	50                   	push   %eax
80103e50:	e8 00 11 00 00       	call   80104f55 <safestrcpy>
80103e55:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e58:	83 ec 0c             	sub    $0xc,%esp
80103e5b:	68 ec aa 10 80       	push   $0x8010aaec
80103e60:	e8 f0 e7 ff ff       	call   80102655 <namei>
80103e65:	83 c4 10             	add    $0x10,%esp
80103e68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e6b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e6e:	83 ec 0c             	sub    $0xc,%esp
80103e71:	68 00 55 19 80       	push   $0x80195500
80103e76:	e8 30 0c 00 00       	call   80104aab <acquire>
80103e7b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e81:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e88:	83 ec 0c             	sub    $0xc,%esp
80103e8b:	68 00 55 19 80       	push   $0x80195500
80103e90:	e8 88 0c 00 00       	call   80104b1d <release>
80103e95:	83 c4 10             	add    $0x10,%esp
}
80103e98:	90                   	nop
80103e99:	c9                   	leave
80103e9a:	c3                   	ret

80103e9b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e9b:	f3 0f 1e fb          	endbr32
80103e9f:	55                   	push   %ebp
80103ea0:	89 e5                	mov    %esp,%ebp
80103ea2:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ea5:	e8 6d fd ff ff       	call   80103c17 <myproc>
80103eaa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb0:	8b 00                	mov    (%eax),%eax
80103eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103eb5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103eb9:	7e 2e                	jle    80103ee9 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ebb:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec1:	01 c2                	add    %eax,%edx
80103ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec6:	8b 40 04             	mov    0x4(%eax),%eax
80103ec9:	83 ec 04             	sub    $0x4,%esp
80103ecc:	52                   	push   %edx
80103ecd:	ff 75 f4             	push   -0xc(%ebp)
80103ed0:	50                   	push   %eax
80103ed1:	e8 87 3e 00 00       	call   80107d5d <allocuvm>
80103ed6:	83 c4 10             	add    $0x10,%esp
80103ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103edc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ee0:	75 3b                	jne    80103f1d <growproc+0x82>
      return -1;
80103ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee7:	eb 4f                	jmp    80103f38 <growproc+0x9d>
  } else if(n < 0){
80103ee9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103eed:	79 2e                	jns    80103f1d <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eef:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef5:	01 c2                	add    %eax,%edx
80103ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103efa:	8b 40 04             	mov    0x4(%eax),%eax
80103efd:	83 ec 04             	sub    $0x4,%esp
80103f00:	52                   	push   %edx
80103f01:	ff 75 f4             	push   -0xc(%ebp)
80103f04:	50                   	push   %eax
80103f05:	e8 5c 3f 00 00       	call   80107e66 <deallocuvm>
80103f0a:	83 c4 10             	add    $0x10,%esp
80103f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f14:	75 07                	jne    80103f1d <growproc+0x82>
      return -1;
80103f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f1b:	eb 1b                	jmp    80103f38 <growproc+0x9d>
  }
  curproc->sz = sz;
80103f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f23:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f25:	83 ec 0c             	sub    $0xc,%esp
80103f28:	ff 75 f0             	push   -0x10(%ebp)
80103f2b:	e8 45 3b 00 00       	call   80107a75 <switchuvm>
80103f30:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f38:	c9                   	leave
80103f39:	c3                   	ret

80103f3a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f3a:	f3 0f 1e fb          	endbr32
80103f3e:	55                   	push   %ebp
80103f3f:	89 e5                	mov    %esp,%ebp
80103f41:	57                   	push   %edi
80103f42:	56                   	push   %esi
80103f43:	53                   	push   %ebx
80103f44:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f47:	e8 cb fc ff ff       	call   80103c17 <myproc>
80103f4c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f4f:	e8 f0 fc ff ff       	call   80103c44 <allocproc>
80103f54:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f57:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f5b:	75 0a                	jne    80103f67 <fork+0x2d>
    return -1;
80103f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f62:	e9 48 01 00 00       	jmp    801040af <fork+0x175>
  } 
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f6a:	8b 10                	mov    (%eax),%edx
80103f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f6f:	8b 40 04             	mov    0x4(%eax),%eax
80103f72:	83 ec 08             	sub    $0x8,%esp
80103f75:	52                   	push   %edx
80103f76:	50                   	push   %eax
80103f77:	e8 94 40 00 00       	call   80108010 <copyuvm>
80103f7c:	83 c4 10             	add    $0x10,%esp
80103f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f82:	89 42 04             	mov    %eax,0x4(%edx)
80103f85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f88:	8b 40 04             	mov    0x4(%eax),%eax
80103f8b:	85 c0                	test   %eax,%eax
80103f8d:	75 30                	jne    80103fbf <fork+0x85>
    kfree(np->kstack);
80103f8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f92:	8b 40 08             	mov    0x8(%eax),%eax
80103f95:	83 ec 0c             	sub    $0xc,%esp
80103f98:	50                   	push   %eax
80103f99:	e8 c4 e8 ff ff       	call   80102862 <kfree>
80103f9e:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fba:	e9 f0 00 00 00       	jmp    801040af <fork+0x175>
  }
  np->sz = curproc->sz;
80103fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fc2:	8b 10                	mov    (%eax),%edx
80103fc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc7:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103fcf:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103fd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fd5:	8b 48 18             	mov    0x18(%eax),%ecx
80103fd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fdb:	8b 40 18             	mov    0x18(%eax),%eax
80103fde:	89 c2                	mov    %eax,%edx
80103fe0:	89 cb                	mov    %ecx,%ebx
80103fe2:	b8 13 00 00 00       	mov    $0x13,%eax
80103fe7:	89 d7                	mov    %edx,%edi
80103fe9:	89 de                	mov    %ebx,%esi
80103feb:	89 c1                	mov    %eax,%ecx
80103fed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103fef:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff2:	8b 40 18             	mov    0x18(%eax),%eax
80103ff5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103ffc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104003:	eb 3b                	jmp    80104040 <fork+0x106>
    if(curproc->ofile[i])
80104005:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010400b:	83 c2 08             	add    $0x8,%edx
8010400e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104012:	85 c0                	test   %eax,%eax
80104014:	74 26                	je     8010403c <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104016:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104019:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010401c:	83 c2 08             	add    $0x8,%edx
8010401f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104023:	83 ec 0c             	sub    $0xc,%esp
80104026:	50                   	push   %eax
80104027:	e8 d6 d0 ff ff       	call   80101102 <filedup>
8010402c:	83 c4 10             	add    $0x10,%esp
8010402f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104032:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104035:	83 c1 08             	add    $0x8,%ecx
80104038:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010403c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104040:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104044:	7e bf                	jle    80104005 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104046:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104049:	8b 40 68             	mov    0x68(%eax),%eax
8010404c:	83 ec 0c             	sub    $0xc,%esp
8010404f:	50                   	push   %eax
80104050:	e8 57 da ff ff       	call   80101aac <idup>
80104055:	83 c4 10             	add    $0x10,%esp
80104058:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010405b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010405e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104061:	8d 50 6c             	lea    0x6c(%eax),%edx
80104064:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104067:	83 c0 6c             	add    $0x6c,%eax
8010406a:	83 ec 04             	sub    $0x4,%esp
8010406d:	6a 10                	push   $0x10
8010406f:	52                   	push   %edx
80104070:	50                   	push   %eax
80104071:	e8 df 0e 00 00       	call   80104f55 <safestrcpy>
80104076:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104079:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010407c:	8b 40 10             	mov    0x10(%eax),%eax
8010407f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104082:	83 ec 0c             	sub    $0xc,%esp
80104085:	68 00 55 19 80       	push   $0x80195500
8010408a:	e8 1c 0a 00 00       	call   80104aab <acquire>
8010408f:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104092:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104095:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010409c:	83 ec 0c             	sub    $0xc,%esp
8010409f:	68 00 55 19 80       	push   $0x80195500
801040a4:	e8 74 0a 00 00       	call   80104b1d <release>
801040a9:	83 c4 10             	add    $0x10,%esp
  return pid;
801040ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801040af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040b2:	5b                   	pop    %ebx
801040b3:	5e                   	pop    %esi
801040b4:	5f                   	pop    %edi
801040b5:	5d                   	pop    %ebp
801040b6:	c3                   	ret

801040b7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801040b7:	f3 0f 1e fb          	endbr32
801040bb:	55                   	push   %ebp
801040bc:	89 e5                	mov    %esp,%ebp
801040be:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801040c1:	e8 51 fb ff ff       	call   80103c17 <myproc>
801040c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801040c9:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801040ce:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040d1:	75 0d                	jne    801040e0 <exit+0x29>
    panic("init exiting");
801040d3:	83 ec 0c             	sub    $0xc,%esp
801040d6:	68 ee aa 10 80       	push   $0x8010aaee
801040db:	e8 fe c4 ff ff       	call   801005de <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801040e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801040e7:	eb 3f                	jmp    80104128 <exit+0x71>
    if(curproc->ofile[fd]){
801040e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040ef:	83 c2 08             	add    $0x8,%edx
801040f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040f6:	85 c0                	test   %eax,%eax
801040f8:	74 2a                	je     80104124 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801040fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104100:	83 c2 08             	add    $0x8,%edx
80104103:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104107:	83 ec 0c             	sub    $0xc,%esp
8010410a:	50                   	push   %eax
8010410b:	e8 47 d0 ff ff       	call   80101157 <fileclose>
80104110:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104113:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104116:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104119:	83 c2 08             	add    $0x8,%edx
8010411c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104123:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104124:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104128:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010412c:	7e bb                	jle    801040e9 <exit+0x32>
    }
  }

  begin_op();
8010412e:	e8 ac f0 ff ff       	call   801031df <begin_op>
  iput(curproc->cwd);
80104133:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104136:	8b 40 68             	mov    0x68(%eax),%eax
80104139:	83 ec 0c             	sub    $0xc,%esp
8010413c:	50                   	push   %eax
8010413d:	e8 11 db ff ff       	call   80101c53 <iput>
80104142:	83 c4 10             	add    $0x10,%esp
  end_op();
80104145:	e8 25 f1 ff ff       	call   8010326f <end_op>
  curproc->cwd = 0;
8010414a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010414d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104154:	83 ec 0c             	sub    $0xc,%esp
80104157:	68 00 55 19 80       	push   $0x80195500
8010415c:	e8 4a 09 00 00       	call   80104aab <acquire>
80104161:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104164:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104167:	8b 40 14             	mov    0x14(%eax),%eax
8010416a:	83 ec 0c             	sub    $0xc,%esp
8010416d:	50                   	push   %eax
8010416e:	e8 5a 04 00 00       	call   801045cd <wakeup1>
80104173:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104176:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010417d:	eb 37                	jmp    801041b6 <exit+0xff>
    if(p->parent == curproc){
8010417f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104182:	8b 40 14             	mov    0x14(%eax),%eax
80104185:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104188:	75 28                	jne    801041b2 <exit+0xfb>
      p->parent = initproc;
8010418a:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104193:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	8b 40 0c             	mov    0xc(%eax),%eax
8010419c:	83 f8 05             	cmp    $0x5,%eax
8010419f:	75 11                	jne    801041b2 <exit+0xfb>
        wakeup1(initproc);
801041a1:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801041a6:	83 ec 0c             	sub    $0xc,%esp
801041a9:	50                   	push   %eax
801041aa:	e8 1e 04 00 00       	call   801045cd <wakeup1>
801041af:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041b2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041b6:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801041bd:	72 c0                	jb     8010417f <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801041bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c2:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801041c9:	e8 0f 02 00 00       	call   801043dd <sched>
  panic("zombie exit");
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	68 fb aa 10 80       	push   $0x8010aafb
801041d6:	e8 03 c4 ff ff       	call   801005de <panic>

801041db <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801041db:	f3 0f 1e fb          	endbr32
801041df:	55                   	push   %ebp
801041e0:	89 e5                	mov    %esp,%ebp
801041e2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801041e5:	e8 2d fa ff ff       	call   80103c17 <myproc>
801041ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	68 00 55 19 80       	push   $0x80195500
801041f5:	e8 b1 08 00 00       	call   80104aab <acquire>
801041fa:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801041fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104204:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010420b:	e9 a1 00 00 00       	jmp    801042b1 <wait+0xd6>
      if(p->parent != curproc)
80104210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104213:	8b 40 14             	mov    0x14(%eax),%eax
80104216:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104219:	0f 85 8d 00 00 00    	jne    801042ac <wait+0xd1>
        continue;
      havekids = 1;
8010421f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104229:	8b 40 0c             	mov    0xc(%eax),%eax
8010422c:	83 f8 05             	cmp    $0x5,%eax
8010422f:	75 7c                	jne    801042ad <wait+0xd2>
        // Found one.
        pid = p->pid;
80104231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104234:	8b 40 10             	mov    0x10(%eax),%eax
80104237:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010423a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423d:	8b 40 08             	mov    0x8(%eax),%eax
80104240:	83 ec 0c             	sub    $0xc,%esp
80104243:	50                   	push   %eax
80104244:	e8 19 e6 ff ff       	call   80102862 <kfree>
80104249:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010424c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104259:	8b 40 04             	mov    0x4(%eax),%eax
8010425c:	83 ec 0c             	sub    $0xc,%esp
8010425f:	50                   	push   %eax
80104260:	e8 c9 3c 00 00       	call   80107f2e <freevm>
80104265:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104275:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010427c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104286:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010428d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104290:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104297:	83 ec 0c             	sub    $0xc,%esp
8010429a:	68 00 55 19 80       	push   $0x80195500
8010429f:	e8 79 08 00 00       	call   80104b1d <release>
801042a4:	83 c4 10             	add    $0x10,%esp
        return pid;
801042a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042aa:	eb 51                	jmp    801042fd <wait+0x122>
        continue;
801042ac:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042ad:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042b1:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801042b8:	0f 82 52 ff ff ff    	jb     80104210 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801042be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042c2:	74 0a                	je     801042ce <wait+0xf3>
801042c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042c7:	8b 40 24             	mov    0x24(%eax),%eax
801042ca:	85 c0                	test   %eax,%eax
801042cc:	74 17                	je     801042e5 <wait+0x10a>
      release(&ptable.lock);
801042ce:	83 ec 0c             	sub    $0xc,%esp
801042d1:	68 00 55 19 80       	push   $0x80195500
801042d6:	e8 42 08 00 00       	call   80104b1d <release>
801042db:	83 c4 10             	add    $0x10,%esp
      return -1;
801042de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e3:	eb 18                	jmp    801042fd <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801042e5:	83 ec 08             	sub    $0x8,%esp
801042e8:	68 00 55 19 80       	push   $0x80195500
801042ed:	ff 75 ec             	push   -0x14(%ebp)
801042f0:	e8 2d 02 00 00       	call   80104522 <sleep>
801042f5:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801042f8:	e9 00 ff ff ff       	jmp    801041fd <wait+0x22>
  }
}
801042fd:	c9                   	leave
801042fe:	c3                   	ret

801042ff <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801042ff:	f3 0f 1e fb          	endbr32
80104303:	55                   	push   %ebp
80104304:	89 e5                	mov    %esp,%ebp
80104306:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104309:	e8 8d f8 ff ff       	call   80103b9b <mycpu>
8010430e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104311:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104314:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010431b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010431e:	e8 30 f8 ff ff       	call   80103b53 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104323:	83 ec 0c             	sub    $0xc,%esp
80104326:	68 00 55 19 80       	push   $0x80195500
8010432b:	e8 7b 07 00 00       	call   80104aab <acquire>
80104330:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104333:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010433a:	eb 61                	jmp    8010439d <scheduler+0x9e>
      if(p->state != RUNNABLE)
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	8b 40 0c             	mov    0xc(%eax),%eax
80104342:	83 f8 03             	cmp    $0x3,%eax
80104345:	75 51                	jne    80104398 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010434a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010434d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104353:	83 ec 0c             	sub    $0xc,%esp
80104356:	ff 75 f4             	push   -0xc(%ebp)
80104359:	e8 17 37 00 00       	call   80107a75 <switchuvm>
8010435e:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104364:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
8010436b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104371:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104374:	83 c2 04             	add    $0x4,%edx
80104377:	83 ec 08             	sub    $0x8,%esp
8010437a:	50                   	push   %eax
8010437b:	52                   	push   %edx
8010437c:	e8 4d 0c 00 00       	call   80104fce <swtch>
80104381:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104384:	e8 cf 36 00 00       	call   80107a58 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104393:	00 00 00 
80104396:	eb 01                	jmp    80104399 <scheduler+0x9a>
        continue;
80104398:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104399:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010439d:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801043a4:	72 96                	jb     8010433c <scheduler+0x3d>
    }
    release(&ptable.lock);
801043a6:	83 ec 0c             	sub    $0xc,%esp
801043a9:	68 00 55 19 80       	push   $0x80195500
801043ae:	e8 6a 07 00 00       	call   80104b1d <release>
801043b3:	83 c4 10             	add    $0x10,%esp
    sti();
801043b6:	e9 63 ff ff ff       	jmp    8010431e <scheduler+0x1f>

801043bb <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
801043bb:	f3 0f 1e fb          	endbr32
801043bf:	55                   	push   %ebp
801043c0:	89 e5                	mov    %esp,%ebp
801043c2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043c5:	e8 4d f8 ff ff       	call   80103c17 <myproc>
801043ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
801043cd:	8b 55 08             	mov    0x8(%ebp),%edx
801043d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d3:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
801043d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043db:	c9                   	leave
801043dc:	c3                   	ret

801043dd <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801043dd:	f3 0f 1e fb          	endbr32
801043e1:	55                   	push   %ebp
801043e2:	89 e5                	mov    %esp,%ebp
801043e4:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801043e7:	e8 2b f8 ff ff       	call   80103c17 <myproc>
801043ec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	68 00 55 19 80       	push   $0x80195500
801043f7:	e8 f6 07 00 00       	call   80104bf2 <holding>
801043fc:	83 c4 10             	add    $0x10,%esp
801043ff:	85 c0                	test   %eax,%eax
80104401:	75 0d                	jne    80104410 <sched+0x33>
    panic("sched ptable.lock");
80104403:	83 ec 0c             	sub    $0xc,%esp
80104406:	68 07 ab 10 80       	push   $0x8010ab07
8010440b:	e8 ce c1 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
80104410:	e8 86 f7 ff ff       	call   80103b9b <mycpu>
80104415:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010441b:	83 f8 01             	cmp    $0x1,%eax
8010441e:	74 0d                	je     8010442d <sched+0x50>
    panic("sched locks");
80104420:	83 ec 0c             	sub    $0xc,%esp
80104423:	68 19 ab 10 80       	push   $0x8010ab19
80104428:	e8 b1 c1 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	8b 40 0c             	mov    0xc(%eax),%eax
80104433:	83 f8 04             	cmp    $0x4,%eax
80104436:	75 0d                	jne    80104445 <sched+0x68>
    panic("sched running");
80104438:	83 ec 0c             	sub    $0xc,%esp
8010443b:	68 25 ab 10 80       	push   $0x8010ab25
80104440:	e8 99 c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
80104445:	e8 f9 f6 ff ff       	call   80103b43 <readeflags>
8010444a:	25 00 02 00 00       	and    $0x200,%eax
8010444f:	85 c0                	test   %eax,%eax
80104451:	74 0d                	je     80104460 <sched+0x83>
    panic("sched interruptible");
80104453:	83 ec 0c             	sub    $0xc,%esp
80104456:	68 33 ab 10 80       	push   $0x8010ab33
8010445b:	e8 7e c1 ff ff       	call   801005de <panic>
  intena = mycpu()->intena;
80104460:	e8 36 f7 ff ff       	call   80103b9b <mycpu>
80104465:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010446b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010446e:	e8 28 f7 ff ff       	call   80103b9b <mycpu>
80104473:	8b 40 04             	mov    0x4(%eax),%eax
80104476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104479:	83 c2 1c             	add    $0x1c,%edx
8010447c:	83 ec 08             	sub    $0x8,%esp
8010447f:	50                   	push   %eax
80104480:	52                   	push   %edx
80104481:	e8 48 0b 00 00       	call   80104fce <swtch>
80104486:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104489:	e8 0d f7 ff ff       	call   80103b9b <mycpu>
8010448e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104491:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104497:	90                   	nop
80104498:	c9                   	leave
80104499:	c3                   	ret

8010449a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010449a:	f3 0f 1e fb          	endbr32
8010449e:	55                   	push   %ebp
8010449f:	89 e5                	mov    %esp,%ebp
801044a1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044a4:	83 ec 0c             	sub    $0xc,%esp
801044a7:	68 00 55 19 80       	push   $0x80195500
801044ac:	e8 fa 05 00 00       	call   80104aab <acquire>
801044b1:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044b4:	e8 5e f7 ff ff       	call   80103c17 <myproc>
801044b9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044c0:	e8 18 ff ff ff       	call   801043dd <sched>
  release(&ptable.lock);
801044c5:	83 ec 0c             	sub    $0xc,%esp
801044c8:	68 00 55 19 80       	push   $0x80195500
801044cd:	e8 4b 06 00 00       	call   80104b1d <release>
801044d2:	83 c4 10             	add    $0x10,%esp
}
801044d5:	90                   	nop
801044d6:	c9                   	leave
801044d7:	c3                   	ret

801044d8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801044d8:	f3 0f 1e fb          	endbr32
801044dc:	55                   	push   %ebp
801044dd:	89 e5                	mov    %esp,%ebp
801044df:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044e2:	83 ec 0c             	sub    $0xc,%esp
801044e5:	68 00 55 19 80       	push   $0x80195500
801044ea:	e8 2e 06 00 00       	call   80104b1d <release>
801044ef:	83 c4 10             	add    $0x10,%esp

  if (first) {
801044f2:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801044f7:	85 c0                	test   %eax,%eax
801044f9:	74 24                	je     8010451f <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801044fb:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104502:	00 00 00 
    iinit(ROOTDEV);
80104505:	83 ec 0c             	sub    $0xc,%esp
80104508:	6a 01                	push   $0x1
8010450a:	e8 55 d2 ff ff       	call   80101764 <iinit>
8010450f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104512:	83 ec 0c             	sub    $0xc,%esp
80104515:	6a 01                	push   $0x1
80104517:	e8 90 ea ff ff       	call   80102fac <initlog>
8010451c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010451f:	90                   	nop
80104520:	c9                   	leave
80104521:	c3                   	ret

80104522 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104522:	f3 0f 1e fb          	endbr32
80104526:	55                   	push   %ebp
80104527:	89 e5                	mov    %esp,%ebp
80104529:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010452c:	e8 e6 f6 ff ff       	call   80103c17 <myproc>
80104531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104534:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104538:	75 0d                	jne    80104547 <sleep+0x25>
    panic("sleep");
8010453a:	83 ec 0c             	sub    $0xc,%esp
8010453d:	68 47 ab 10 80       	push   $0x8010ab47
80104542:	e8 97 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
80104547:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010454b:	75 0d                	jne    8010455a <sleep+0x38>
    panic("sleep without lk");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 4d ab 10 80       	push   $0x8010ab4d
80104555:	e8 84 c0 ff ff       	call   801005de <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010455a:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104561:	74 1e                	je     80104581 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	68 00 55 19 80       	push   $0x80195500
8010456b:	e8 3b 05 00 00       	call   80104aab <acquire>
80104570:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104573:	83 ec 0c             	sub    $0xc,%esp
80104576:	ff 75 0c             	push   0xc(%ebp)
80104579:	e8 9f 05 00 00       	call   80104b1d <release>
8010457e:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	8b 55 08             	mov    0x8(%ebp),%edx
80104587:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104594:	e8 44 fe ff ff       	call   801043dd <sched>

  // Tidy up.
  p->chan = 0;
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045a3:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801045aa:	74 1e                	je     801045ca <sleep+0xa8>
    release(&ptable.lock);
801045ac:	83 ec 0c             	sub    $0xc,%esp
801045af:	68 00 55 19 80       	push   $0x80195500
801045b4:	e8 64 05 00 00       	call   80104b1d <release>
801045b9:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045bc:	83 ec 0c             	sub    $0xc,%esp
801045bf:	ff 75 0c             	push   0xc(%ebp)
801045c2:	e8 e4 04 00 00       	call   80104aab <acquire>
801045c7:	83 c4 10             	add    $0x10,%esp
  }
}
801045ca:	90                   	nop
801045cb:	c9                   	leave
801045cc:	c3                   	ret

801045cd <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045cd:	f3 0f 1e fb          	endbr32
801045d1:	55                   	push   %ebp
801045d2:	89 e5                	mov    %esp,%ebp
801045d4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045d7:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801045de:	eb 24                	jmp    80104604 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
801045e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045e3:	8b 40 0c             	mov    0xc(%eax),%eax
801045e6:	83 f8 02             	cmp    $0x2,%eax
801045e9:	75 15                	jne    80104600 <wakeup1+0x33>
801045eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045ee:	8b 40 20             	mov    0x20(%eax),%eax
801045f1:	39 45 08             	cmp    %eax,0x8(%ebp)
801045f4:	75 0a                	jne    80104600 <wakeup1+0x33>
      p->state = RUNNABLE;
801045f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045f9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104600:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104604:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
8010460b:	72 d3                	jb     801045e0 <wakeup1+0x13>
}
8010460d:	90                   	nop
8010460e:	90                   	nop
8010460f:	c9                   	leave
80104610:	c3                   	ret

80104611 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104611:	f3 0f 1e fb          	endbr32
80104615:	55                   	push   %ebp
80104616:	89 e5                	mov    %esp,%ebp
80104618:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	68 00 55 19 80       	push   $0x80195500
80104623:	e8 83 04 00 00       	call   80104aab <acquire>
80104628:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010462b:	83 ec 0c             	sub    $0xc,%esp
8010462e:	ff 75 08             	push   0x8(%ebp)
80104631:	e8 97 ff ff ff       	call   801045cd <wakeup1>
80104636:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104639:	83 ec 0c             	sub    $0xc,%esp
8010463c:	68 00 55 19 80       	push   $0x80195500
80104641:	e8 d7 04 00 00       	call   80104b1d <release>
80104646:	83 c4 10             	add    $0x10,%esp
}
80104649:	90                   	nop
8010464a:	c9                   	leave
8010464b:	c3                   	ret

8010464c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010464c:	f3 0f 1e fb          	endbr32
80104650:	55                   	push   %ebp
80104651:	89 e5                	mov    %esp,%ebp
80104653:	83 ec 18             	sub    $0x18,%esp
  cprintf("kill\n");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 5e ab 10 80       	push   $0x8010ab5e
8010465e:	e8 a9 bd ff ff       	call   8010040c <cprintf>
80104663:	83 c4 10             	add    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104666:	83 ec 0c             	sub    $0xc,%esp
80104669:	68 00 55 19 80       	push   $0x80195500
8010466e:	e8 38 04 00 00       	call   80104aab <acquire>
80104673:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104676:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010467d:	eb 45                	jmp    801046c4 <kill+0x78>
    if(p->pid == pid){
8010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104682:	8b 40 10             	mov    0x10(%eax),%eax
80104685:	39 45 08             	cmp    %eax,0x8(%ebp)
80104688:	75 36                	jne    801046c0 <kill+0x74>
      p->killed = 1;
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104697:	8b 40 0c             	mov    0xc(%eax),%eax
8010469a:	83 f8 02             	cmp    $0x2,%eax
8010469d:	75 0a                	jne    801046a9 <kill+0x5d>
        p->state = RUNNABLE;
8010469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046a9:	83 ec 0c             	sub    $0xc,%esp
801046ac:	68 00 55 19 80       	push   $0x80195500
801046b1:	e8 67 04 00 00       	call   80104b1d <release>
801046b6:	83 c4 10             	add    $0x10,%esp
      return 0;
801046b9:	b8 00 00 00 00       	mov    $0x0,%eax
801046be:	eb 22                	jmp    801046e2 <kill+0x96>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046c0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046c4:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801046cb:	72 b2                	jb     8010467f <kill+0x33>
    }
  }
  release(&ptable.lock);
801046cd:	83 ec 0c             	sub    $0xc,%esp
801046d0:	68 00 55 19 80       	push   $0x80195500
801046d5:	e8 43 04 00 00       	call   80104b1d <release>
801046da:	83 c4 10             	add    $0x10,%esp
  return -1;
801046dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046e2:	c9                   	leave
801046e3:	c3                   	ret

801046e4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046e4:	f3 0f 1e fb          	endbr32
801046e8:	55                   	push   %ebp
801046e9:	89 e5                	mov    %esp,%ebp
801046eb:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ee:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801046f5:	e9 d7 00 00 00       	jmp    801047d1 <procdump+0xed>
    if(p->state == UNUSED)
801046fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fd:	8b 40 0c             	mov    0xc(%eax),%eax
80104700:	85 c0                	test   %eax,%eax
80104702:	0f 84 c4 00 00 00    	je     801047cc <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470b:	8b 40 0c             	mov    0xc(%eax),%eax
8010470e:	83 f8 05             	cmp    $0x5,%eax
80104711:	77 23                	ja     80104736 <procdump+0x52>
80104713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104716:	8b 40 0c             	mov    0xc(%eax),%eax
80104719:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104720:	85 c0                	test   %eax,%eax
80104722:	74 12                	je     80104736 <procdump+0x52>
      state = states[p->state];
80104724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104727:	8b 40 0c             	mov    0xc(%eax),%eax
8010472a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104731:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104734:	eb 07                	jmp    8010473d <procdump+0x59>
    else
      state = "???";
80104736:	c7 45 ec 64 ab 10 80 	movl   $0x8010ab64,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010473d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104740:	8d 50 6c             	lea    0x6c(%eax),%edx
80104743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104746:	8b 40 10             	mov    0x10(%eax),%eax
80104749:	52                   	push   %edx
8010474a:	ff 75 ec             	push   -0x14(%ebp)
8010474d:	50                   	push   %eax
8010474e:	68 68 ab 10 80       	push   $0x8010ab68
80104753:	e8 b4 bc ff ff       	call   8010040c <cprintf>
80104758:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010475b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010475e:	8b 40 0c             	mov    0xc(%eax),%eax
80104761:	83 f8 02             	cmp    $0x2,%eax
80104764:	75 54                	jne    801047ba <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104769:	8b 40 1c             	mov    0x1c(%eax),%eax
8010476c:	8b 40 0c             	mov    0xc(%eax),%eax
8010476f:	83 c0 08             	add    $0x8,%eax
80104772:	89 c2                	mov    %eax,%edx
80104774:	83 ec 08             	sub    $0x8,%esp
80104777:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010477a:	50                   	push   %eax
8010477b:	52                   	push   %edx
8010477c:	e8 f2 03 00 00       	call   80104b73 <getcallerpcs>
80104781:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010478b:	eb 1c                	jmp    801047a9 <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010478d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104790:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104794:	83 ec 08             	sub    $0x8,%esp
80104797:	50                   	push   %eax
80104798:	68 71 ab 10 80       	push   $0x8010ab71
8010479d:	e8 6a bc ff ff       	call   8010040c <cprintf>
801047a2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047a9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047ad:	7f 0b                	jg     801047ba <procdump+0xd6>
801047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047b6:	85 c0                	test   %eax,%eax
801047b8:	75 d3                	jne    8010478d <procdump+0xa9>
    }
    cprintf("\n");
801047ba:	83 ec 0c             	sub    $0xc,%esp
801047bd:	68 75 ab 10 80       	push   $0x8010ab75
801047c2:	e8 45 bc ff ff       	call   8010040c <cprintf>
801047c7:	83 c4 10             	add    $0x10,%esp
801047ca:	eb 01                	jmp    801047cd <procdump+0xe9>
      continue;
801047cc:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047cd:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801047d1:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
801047d8:	0f 82 1c ff ff ff    	jb     801046fa <procdump+0x16>
  }
}
801047de:	90                   	nop
801047df:	90                   	nop
801047e0:	c9                   	leave
801047e1:	c3                   	ret

801047e2 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
801047e2:	f3 0f 1e fb          	endbr32
801047e6:	55                   	push   %ebp
801047e7:	89 e5                	mov    %esp,%ebp
801047e9:	53                   	push   %ebx
801047ea:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ed:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801047f4:	eb 0f                	jmp    80104805 <printpt+0x23>
    if (p->pid == pid)
801047f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f9:	8b 40 10             	mov    0x10(%eax),%eax
801047fc:	39 45 08             	cmp    %eax,0x8(%ebp)
801047ff:	74 0f                	je     80104810 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104801:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104805:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010480c:	72 e8                	jb     801047f6 <printpt+0x14>
8010480e:	eb 01                	jmp    80104811 <printpt+0x2f>
      break;
80104810:	90                   	nop
  }
  if (p == 0){
80104811:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104815:	75 1a                	jne    80104831 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
80104817:	83 ec 0c             	sub    $0xc,%esp
8010481a:	68 77 ab 10 80       	push   $0x8010ab77
8010481f:	e8 e8 bb ff ff       	call   8010040c <cprintf>
80104824:	83 c4 10             	add    $0x10,%esp
    return -1;
80104827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482c:	e9 e2 00 00 00       	jmp    80104913 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
80104831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104834:	8b 40 04             	mov    0x4(%eax),%eax
80104837:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
8010483a:	83 ec 08             	sub    $0x8,%esp
8010483d:	ff 75 08             	push   0x8(%ebp)
80104840:	68 93 ab 10 80       	push   $0x8010ab93
80104845:	e8 c2 bb ff ff       	call   8010040c <cprintf>
8010484a:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010484d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104854:	e9 9a 00 00 00       	jmp    801048f3 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
80104859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485c:	83 ec 04             	sub    $0x4,%esp
8010485f:	6a 00                	push   $0x0
80104861:	50                   	push   %eax
80104862:	ff 75 ec             	push   -0x14(%ebp)
80104865:	e8 b3 2f 00 00       	call   8010781d <walkpgdir>
8010486a:	83 c4 10             	add    $0x10,%esp
8010486d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
80104870:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104873:	8b 00                	mov    (%eax),%eax
80104875:	83 e0 01             	and    $0x1,%eax
80104878:	85 c0                	test   %eax,%eax
8010487a:	74 6f                	je     801048eb <printpt+0x109>
8010487c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104880:	74 69                	je     801048eb <printpt+0x109>
    cprintf("pte: %x\n",pte);
80104882:	83 ec 08             	sub    $0x8,%esp
80104885:	ff 75 e8             	push   -0x18(%ebp)
80104888:	68 af ab 10 80       	push   $0x8010abaf
8010488d:	e8 7a bb ff ff       	call   8010040c <cprintf>
80104892:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104895:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104898:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
8010489a:	c1 e8 0c             	shr    $0xc,%eax
8010489d:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
8010489f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a2:	8b 00                	mov    (%eax),%eax
801048a4:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048a7:	85 c0                	test   %eax,%eax
801048a9:	74 07                	je     801048b2 <printpt+0xd0>
801048ab:	bb 57 00 00 00       	mov    $0x57,%ebx
801048b0:	eb 05                	jmp    801048b7 <printpt+0xd5>
801048b2:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801048b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048ba:	8b 00                	mov    (%eax),%eax
801048bc:	83 e0 04             	and    $0x4,%eax
801048bf:	85 c0                	test   %eax,%eax
801048c1:	74 07                	je     801048ca <printpt+0xe8>
801048c3:	b9 55 00 00 00       	mov    $0x55,%ecx
801048c8:	eb 05                	jmp    801048cf <printpt+0xed>
801048ca:	b9 4b 00 00 00       	mov    $0x4b,%ecx
801048cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d2:	c1 e8 0c             	shr    $0xc,%eax
801048d5:	83 ec 0c             	sub    $0xc,%esp
801048d8:	52                   	push   %edx
801048d9:	53                   	push   %ebx
801048da:	51                   	push   %ecx
801048db:	50                   	push   %eax
801048dc:	68 b8 ab 10 80       	push   $0x8010abb8
801048e1:	e8 26 bb ff ff       	call   8010040c <cprintf>
801048e6:	83 c4 20             	add    $0x20,%esp
801048e9:	eb 01                	jmp    801048ec <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
801048eb:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
801048ec:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801048f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f6:	85 c0                	test   %eax,%eax
801048f8:	0f 89 5b ff ff ff    	jns    80104859 <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
801048fe:	83 ec 0c             	sub    $0xc,%esp
80104901:	68 c7 ab 10 80       	push   $0x8010abc7
80104906:	e8 01 bb ff ff       	call   8010040c <cprintf>
8010490b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010490e:	b8 00 00 00 00       	mov    $0x0,%eax
80104913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104916:	c9                   	leave
80104917:	c3                   	ret

80104918 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104918:	f3 0f 1e fb          	endbr32
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104922:	8b 45 08             	mov    0x8(%ebp),%eax
80104925:	83 c0 04             	add    $0x4,%eax
80104928:	83 ec 08             	sub    $0x8,%esp
8010492b:	68 01 ac 10 80       	push   $0x8010ac01
80104930:	50                   	push   %eax
80104931:	e8 4f 01 00 00       	call   80104a85 <initlock>
80104936:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104939:	8b 45 08             	mov    0x8(%ebp),%eax
8010493c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010493f:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104942:	8b 45 08             	mov    0x8(%ebp),%eax
80104945:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010494b:	8b 45 08             	mov    0x8(%ebp),%eax
8010494e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104955:	90                   	nop
80104956:	c9                   	leave
80104957:	c3                   	ret

80104958 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104958:	f3 0f 1e fb          	endbr32
8010495c:	55                   	push   %ebp
8010495d:	89 e5                	mov    %esp,%ebp
8010495f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104962:	8b 45 08             	mov    0x8(%ebp),%eax
80104965:	83 c0 04             	add    $0x4,%eax
80104968:	83 ec 0c             	sub    $0xc,%esp
8010496b:	50                   	push   %eax
8010496c:	e8 3a 01 00 00       	call   80104aab <acquire>
80104971:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104974:	eb 15                	jmp    8010498b <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104976:	8b 45 08             	mov    0x8(%ebp),%eax
80104979:	83 c0 04             	add    $0x4,%eax
8010497c:	83 ec 08             	sub    $0x8,%esp
8010497f:	50                   	push   %eax
80104980:	ff 75 08             	push   0x8(%ebp)
80104983:	e8 9a fb ff ff       	call   80104522 <sleep>
80104988:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010498b:	8b 45 08             	mov    0x8(%ebp),%eax
8010498e:	8b 00                	mov    (%eax),%eax
80104990:	85 c0                	test   %eax,%eax
80104992:	75 e2                	jne    80104976 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104994:	8b 45 08             	mov    0x8(%ebp),%eax
80104997:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010499d:	e8 75 f2 ff ff       	call   80103c17 <myproc>
801049a2:	8b 50 10             	mov    0x10(%eax),%edx
801049a5:	8b 45 08             	mov    0x8(%ebp),%eax
801049a8:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801049ab:	8b 45 08             	mov    0x8(%ebp),%eax
801049ae:	83 c0 04             	add    $0x4,%eax
801049b1:	83 ec 0c             	sub    $0xc,%esp
801049b4:	50                   	push   %eax
801049b5:	e8 63 01 00 00       	call   80104b1d <release>
801049ba:	83 c4 10             	add    $0x10,%esp
}
801049bd:	90                   	nop
801049be:	c9                   	leave
801049bf:	c3                   	ret

801049c0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801049c0:	f3 0f 1e fb          	endbr32
801049c4:	55                   	push   %ebp
801049c5:	89 e5                	mov    %esp,%ebp
801049c7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049ca:	8b 45 08             	mov    0x8(%ebp),%eax
801049cd:	83 c0 04             	add    $0x4,%eax
801049d0:	83 ec 0c             	sub    $0xc,%esp
801049d3:	50                   	push   %eax
801049d4:	e8 d2 00 00 00       	call   80104aab <acquire>
801049d9:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801049dc:	8b 45 08             	mov    0x8(%ebp),%eax
801049df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049e5:	8b 45 08             	mov    0x8(%ebp),%eax
801049e8:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801049ef:	83 ec 0c             	sub    $0xc,%esp
801049f2:	ff 75 08             	push   0x8(%ebp)
801049f5:	e8 17 fc ff ff       	call   80104611 <wakeup>
801049fa:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801049fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104a00:	83 c0 04             	add    $0x4,%eax
80104a03:	83 ec 0c             	sub    $0xc,%esp
80104a06:	50                   	push   %eax
80104a07:	e8 11 01 00 00       	call   80104b1d <release>
80104a0c:	83 c4 10             	add    $0x10,%esp
}
80104a0f:	90                   	nop
80104a10:	c9                   	leave
80104a11:	c3                   	ret

80104a12 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a12:	f3 0f 1e fb          	endbr32
80104a16:	55                   	push   %ebp
80104a17:	89 e5                	mov    %esp,%ebp
80104a19:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1f:	83 c0 04             	add    $0x4,%eax
80104a22:	83 ec 0c             	sub    $0xc,%esp
80104a25:	50                   	push   %eax
80104a26:	e8 80 00 00 00       	call   80104aab <acquire>
80104a2b:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a31:	8b 00                	mov    (%eax),%eax
80104a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a36:	8b 45 08             	mov    0x8(%ebp),%eax
80104a39:	83 c0 04             	add    $0x4,%eax
80104a3c:	83 ec 0c             	sub    $0xc,%esp
80104a3f:	50                   	push   %eax
80104a40:	e8 d8 00 00 00       	call   80104b1d <release>
80104a45:	83 c4 10             	add    $0x10,%esp
  return r;
80104a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a4b:	c9                   	leave
80104a4c:	c3                   	ret

80104a4d <readeflags>:
{
80104a4d:	55                   	push   %ebp
80104a4e:	89 e5                	mov    %esp,%ebp
80104a50:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a53:	9c                   	pushf
80104a54:	58                   	pop    %eax
80104a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a5b:	c9                   	leave
80104a5c:	c3                   	ret

80104a5d <cli>:
{
80104a5d:	55                   	push   %ebp
80104a5e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a60:	fa                   	cli
}
80104a61:	90                   	nop
80104a62:	5d                   	pop    %ebp
80104a63:	c3                   	ret

80104a64 <sti>:
{
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a67:	fb                   	sti
}
80104a68:	90                   	nop
80104a69:	5d                   	pop    %ebp
80104a6a:	c3                   	ret

80104a6b <xchg>:
{
80104a6b:	55                   	push   %ebp
80104a6c:	89 e5                	mov    %esp,%ebp
80104a6e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a71:	8b 55 08             	mov    0x8(%ebp),%edx
80104a74:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a7a:	f0 87 02             	lock xchg %eax,(%edx)
80104a7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a83:	c9                   	leave
80104a84:	c3                   	ret

80104a85 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a85:	f3 0f 1e fb          	endbr32
80104a89:	55                   	push   %ebp
80104a8a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a92:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a95:	8b 45 08             	mov    0x8(%ebp),%eax
80104a98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104aa8:	90                   	nop
80104aa9:	5d                   	pop    %ebp
80104aaa:	c3                   	ret

80104aab <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104aab:	f3 0f 1e fb          	endbr32
80104aaf:	55                   	push   %ebp
80104ab0:	89 e5                	mov    %esp,%ebp
80104ab2:	53                   	push   %ebx
80104ab3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ab6:	e8 6c 01 00 00       	call   80104c27 <pushcli>
  if(holding(lk)){
80104abb:	8b 45 08             	mov    0x8(%ebp),%eax
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	50                   	push   %eax
80104ac2:	e8 2b 01 00 00       	call   80104bf2 <holding>
80104ac7:	83 c4 10             	add    $0x10,%esp
80104aca:	85 c0                	test   %eax,%eax
80104acc:	74 0d                	je     80104adb <acquire+0x30>
    panic("acquire");
80104ace:	83 ec 0c             	sub    $0xc,%esp
80104ad1:	68 0c ac 10 80       	push   $0x8010ac0c
80104ad6:	e8 03 bb ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104adb:	90                   	nop
80104adc:	8b 45 08             	mov    0x8(%ebp),%eax
80104adf:	83 ec 08             	sub    $0x8,%esp
80104ae2:	6a 01                	push   $0x1
80104ae4:	50                   	push   %eax
80104ae5:	e8 81 ff ff ff       	call   80104a6b <xchg>
80104aea:	83 c4 10             	add    $0x10,%esp
80104aed:	85 c0                	test   %eax,%eax
80104aef:	75 eb                	jne    80104adc <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104af1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104af6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104af9:	e8 9d f0 ff ff       	call   80103b9b <mycpu>
80104afe:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b01:	8b 45 08             	mov    0x8(%ebp),%eax
80104b04:	83 c0 0c             	add    $0xc,%eax
80104b07:	83 ec 08             	sub    $0x8,%esp
80104b0a:	50                   	push   %eax
80104b0b:	8d 45 08             	lea    0x8(%ebp),%eax
80104b0e:	50                   	push   %eax
80104b0f:	e8 5f 00 00 00       	call   80104b73 <getcallerpcs>
80104b14:	83 c4 10             	add    $0x10,%esp
}
80104b17:	90                   	nop
80104b18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b1b:	c9                   	leave
80104b1c:	c3                   	ret

80104b1d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b1d:	f3 0f 1e fb          	endbr32
80104b21:	55                   	push   %ebp
80104b22:	89 e5                	mov    %esp,%ebp
80104b24:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b27:	83 ec 0c             	sub    $0xc,%esp
80104b2a:	ff 75 08             	push   0x8(%ebp)
80104b2d:	e8 c0 00 00 00       	call   80104bf2 <holding>
80104b32:	83 c4 10             	add    $0x10,%esp
80104b35:	85 c0                	test   %eax,%eax
80104b37:	75 0d                	jne    80104b46 <release+0x29>
    panic("release");
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	68 14 ac 10 80       	push   $0x8010ac14
80104b41:	e8 98 ba ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104b46:	8b 45 08             	mov    0x8(%ebp),%eax
80104b49:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b50:	8b 45 08             	mov    0x8(%ebp),%eax
80104b53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b5a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b62:	8b 55 08             	mov    0x8(%ebp),%edx
80104b65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b6b:	e8 08 01 00 00       	call   80104c78 <popcli>
}
80104b70:	90                   	nop
80104b71:	c9                   	leave
80104b72:	c3                   	ret

80104b73 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b73:	f3 0f 1e fb          	endbr32
80104b77:	55                   	push   %ebp
80104b78:	89 e5                	mov    %esp,%ebp
80104b7a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b80:	83 e8 08             	sub    $0x8,%eax
80104b83:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b86:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b8d:	eb 38                	jmp    80104bc7 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b8f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b93:	74 53                	je     80104be8 <getcallerpcs+0x75>
80104b95:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b9c:	76 4a                	jbe    80104be8 <getcallerpcs+0x75>
80104b9e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104ba2:	74 44                	je     80104be8 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104ba4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ba7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb1:	01 c2                	add    %eax,%edx
80104bb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb6:	8b 40 04             	mov    0x4(%eax),%eax
80104bb9:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bbe:	8b 00                	mov    (%eax),%eax
80104bc0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bc3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bc7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bcb:	7e c2                	jle    80104b8f <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104bcd:	eb 19                	jmp    80104be8 <getcallerpcs+0x75>
    pcs[i] = 0;
80104bcf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdc:	01 d0                	add    %edx,%eax
80104bde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104be4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104be8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bec:	7e e1                	jle    80104bcf <getcallerpcs+0x5c>
}
80104bee:	90                   	nop
80104bef:	90                   	nop
80104bf0:	c9                   	leave
80104bf1:	c3                   	ret

80104bf2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104bf2:	f3 0f 1e fb          	endbr32
80104bf6:	55                   	push   %ebp
80104bf7:	89 e5                	mov    %esp,%ebp
80104bf9:	53                   	push   %ebx
80104bfa:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104c00:	8b 00                	mov    (%eax),%eax
80104c02:	85 c0                	test   %eax,%eax
80104c04:	74 16                	je     80104c1c <holding+0x2a>
80104c06:	8b 45 08             	mov    0x8(%ebp),%eax
80104c09:	8b 58 08             	mov    0x8(%eax),%ebx
80104c0c:	e8 8a ef ff ff       	call   80103b9b <mycpu>
80104c11:	39 c3                	cmp    %eax,%ebx
80104c13:	75 07                	jne    80104c1c <holding+0x2a>
80104c15:	b8 01 00 00 00       	mov    $0x1,%eax
80104c1a:	eb 05                	jmp    80104c21 <holding+0x2f>
80104c1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c21:	83 c4 04             	add    $0x4,%esp
80104c24:	5b                   	pop    %ebx
80104c25:	5d                   	pop    %ebp
80104c26:	c3                   	ret

80104c27 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c27:	f3 0f 1e fb          	endbr32
80104c2b:	55                   	push   %ebp
80104c2c:	89 e5                	mov    %esp,%ebp
80104c2e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c31:	e8 17 fe ff ff       	call   80104a4d <readeflags>
80104c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c39:	e8 1f fe ff ff       	call   80104a5d <cli>
  if(mycpu()->ncli == 0)
80104c3e:	e8 58 ef ff ff       	call   80103b9b <mycpu>
80104c43:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c49:	85 c0                	test   %eax,%eax
80104c4b:	75 14                	jne    80104c61 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104c4d:	e8 49 ef ff ff       	call   80103b9b <mycpu>
80104c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c55:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c5b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c61:	e8 35 ef ff ff       	call   80103b9b <mycpu>
80104c66:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c6c:	83 c2 01             	add    $0x1,%edx
80104c6f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c75:	90                   	nop
80104c76:	c9                   	leave
80104c77:	c3                   	ret

80104c78 <popcli>:

void
popcli(void)
{
80104c78:	f3 0f 1e fb          	endbr32
80104c7c:	55                   	push   %ebp
80104c7d:	89 e5                	mov    %esp,%ebp
80104c7f:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c82:	e8 c6 fd ff ff       	call   80104a4d <readeflags>
80104c87:	25 00 02 00 00       	and    $0x200,%eax
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	74 0d                	je     80104c9d <popcli+0x25>
    panic("popcli - interruptible");
80104c90:	83 ec 0c             	sub    $0xc,%esp
80104c93:	68 1c ac 10 80       	push   $0x8010ac1c
80104c98:	e8 41 b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104c9d:	e8 f9 ee ff ff       	call   80103b9b <mycpu>
80104ca2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ca8:	83 ea 01             	sub    $0x1,%edx
80104cab:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104cb1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	79 0d                	jns    80104cc8 <popcli+0x50>
    panic("popcli");
80104cbb:	83 ec 0c             	sub    $0xc,%esp
80104cbe:	68 33 ac 10 80       	push   $0x8010ac33
80104cc3:	e8 16 b9 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104cc8:	e8 ce ee ff ff       	call   80103b9b <mycpu>
80104ccd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	75 14                	jne    80104ceb <popcli+0x73>
80104cd7:	e8 bf ee ff ff       	call   80103b9b <mycpu>
80104cdc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104ce2:	85 c0                	test   %eax,%eax
80104ce4:	74 05                	je     80104ceb <popcli+0x73>
    sti();
80104ce6:	e8 79 fd ff ff       	call   80104a64 <sti>
}
80104ceb:	90                   	nop
80104cec:	c9                   	leave
80104ced:	c3                   	ret

80104cee <stosb>:
{
80104cee:	55                   	push   %ebp
80104cef:	89 e5                	mov    %esp,%ebp
80104cf1:	57                   	push   %edi
80104cf2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104cf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cf6:	8b 55 10             	mov    0x10(%ebp),%edx
80104cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cfc:	89 cb                	mov    %ecx,%ebx
80104cfe:	89 df                	mov    %ebx,%edi
80104d00:	89 d1                	mov    %edx,%ecx
80104d02:	fc                   	cld
80104d03:	f3 aa                	rep stos %al,%es:(%edi)
80104d05:	89 ca                	mov    %ecx,%edx
80104d07:	89 fb                	mov    %edi,%ebx
80104d09:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d0c:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d0f:	90                   	nop
80104d10:	5b                   	pop    %ebx
80104d11:	5f                   	pop    %edi
80104d12:	5d                   	pop    %ebp
80104d13:	c3                   	ret

80104d14 <stosl>:
{
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	57                   	push   %edi
80104d18:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d1c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d22:	89 cb                	mov    %ecx,%ebx
80104d24:	89 df                	mov    %ebx,%edi
80104d26:	89 d1                	mov    %edx,%ecx
80104d28:	fc                   	cld
80104d29:	f3 ab                	rep stos %eax,%es:(%edi)
80104d2b:	89 ca                	mov    %ecx,%edx
80104d2d:	89 fb                	mov    %edi,%ebx
80104d2f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d32:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d35:	90                   	nop
80104d36:	5b                   	pop    %ebx
80104d37:	5f                   	pop    %edi
80104d38:	5d                   	pop    %ebp
80104d39:	c3                   	ret

80104d3a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d3a:	f3 0f 1e fb          	endbr32
80104d3e:	55                   	push   %ebp
80104d3f:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d41:	8b 45 08             	mov    0x8(%ebp),%eax
80104d44:	83 e0 03             	and    $0x3,%eax
80104d47:	85 c0                	test   %eax,%eax
80104d49:	75 43                	jne    80104d8e <memset+0x54>
80104d4b:	8b 45 10             	mov    0x10(%ebp),%eax
80104d4e:	83 e0 03             	and    $0x3,%eax
80104d51:	85 c0                	test   %eax,%eax
80104d53:	75 39                	jne    80104d8e <memset+0x54>
    c &= 0xFF;
80104d55:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d5c:	8b 45 10             	mov    0x10(%ebp),%eax
80104d5f:	c1 e8 02             	shr    $0x2,%eax
80104d62:	89 c1                	mov    %eax,%ecx
80104d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d67:	c1 e0 18             	shl    $0x18,%eax
80104d6a:	89 c2                	mov    %eax,%edx
80104d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6f:	c1 e0 10             	shl    $0x10,%eax
80104d72:	09 c2                	or     %eax,%edx
80104d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d77:	c1 e0 08             	shl    $0x8,%eax
80104d7a:	09 d0                	or     %edx,%eax
80104d7c:	0b 45 0c             	or     0xc(%ebp),%eax
80104d7f:	51                   	push   %ecx
80104d80:	50                   	push   %eax
80104d81:	ff 75 08             	push   0x8(%ebp)
80104d84:	e8 8b ff ff ff       	call   80104d14 <stosl>
80104d89:	83 c4 0c             	add    $0xc,%esp
80104d8c:	eb 12                	jmp    80104da0 <memset+0x66>
  } else
    stosb(dst, c, n);
80104d8e:	8b 45 10             	mov    0x10(%ebp),%eax
80104d91:	50                   	push   %eax
80104d92:	ff 75 0c             	push   0xc(%ebp)
80104d95:	ff 75 08             	push   0x8(%ebp)
80104d98:	e8 51 ff ff ff       	call   80104cee <stosb>
80104d9d:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104da0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104da3:	c9                   	leave
80104da4:	c3                   	ret

80104da5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104da5:	f3 0f 1e fb          	endbr32
80104da9:	55                   	push   %ebp
80104daa:	89 e5                	mov    %esp,%ebp
80104dac:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104daf:	8b 45 08             	mov    0x8(%ebp),%eax
80104db2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dbb:	eb 30                	jmp    80104ded <memcmp+0x48>
    if(*s1 != *s2)
80104dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dc0:	0f b6 10             	movzbl (%eax),%edx
80104dc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dc6:	0f b6 00             	movzbl (%eax),%eax
80104dc9:	38 c2                	cmp    %al,%dl
80104dcb:	74 18                	je     80104de5 <memcmp+0x40>
      return *s1 - *s2;
80104dcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd0:	0f b6 00             	movzbl (%eax),%eax
80104dd3:	0f b6 d0             	movzbl %al,%edx
80104dd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dd9:	0f b6 00             	movzbl (%eax),%eax
80104ddc:	0f b6 c0             	movzbl %al,%eax
80104ddf:	29 c2                	sub    %eax,%edx
80104de1:	89 d0                	mov    %edx,%eax
80104de3:	eb 1a                	jmp    80104dff <memcmp+0x5a>
    s1++, s2++;
80104de5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104de9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ded:	8b 45 10             	mov    0x10(%ebp),%eax
80104df0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104df3:	89 55 10             	mov    %edx,0x10(%ebp)
80104df6:	85 c0                	test   %eax,%eax
80104df8:	75 c3                	jne    80104dbd <memcmp+0x18>
  }

  return 0;
80104dfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dff:	c9                   	leave
80104e00:	c3                   	ret

80104e01 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e01:	f3 0f 1e fb          	endbr32
80104e05:	55                   	push   %ebp
80104e06:	89 e5                	mov    %esp,%ebp
80104e08:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e11:	8b 45 08             	mov    0x8(%ebp),%eax
80104e14:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e1d:	73 54                	jae    80104e73 <memmove+0x72>
80104e1f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e22:	8b 45 10             	mov    0x10(%ebp),%eax
80104e25:	01 d0                	add    %edx,%eax
80104e27:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e2a:	73 47                	jae    80104e73 <memmove+0x72>
    s += n;
80104e2c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e2f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e32:	8b 45 10             	mov    0x10(%ebp),%eax
80104e35:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e38:	eb 13                	jmp    80104e4d <memmove+0x4c>
      *--d = *--s;
80104e3a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e3e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e45:	0f b6 10             	movzbl (%eax),%edx
80104e48:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e4d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e50:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e53:	89 55 10             	mov    %edx,0x10(%ebp)
80104e56:	85 c0                	test   %eax,%eax
80104e58:	75 e0                	jne    80104e3a <memmove+0x39>
  if(s < d && s + n > d){
80104e5a:	eb 24                	jmp    80104e80 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e5c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e5f:	8d 42 01             	lea    0x1(%edx),%eax
80104e62:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e68:	8d 48 01             	lea    0x1(%eax),%ecx
80104e6b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e6e:	0f b6 12             	movzbl (%edx),%edx
80104e71:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e73:	8b 45 10             	mov    0x10(%ebp),%eax
80104e76:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e79:	89 55 10             	mov    %edx,0x10(%ebp)
80104e7c:	85 c0                	test   %eax,%eax
80104e7e:	75 dc                	jne    80104e5c <memmove+0x5b>

  return dst;
80104e80:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e83:	c9                   	leave
80104e84:	c3                   	ret

80104e85 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e85:	f3 0f 1e fb          	endbr32
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e8c:	ff 75 10             	push   0x10(%ebp)
80104e8f:	ff 75 0c             	push   0xc(%ebp)
80104e92:	ff 75 08             	push   0x8(%ebp)
80104e95:	e8 67 ff ff ff       	call   80104e01 <memmove>
80104e9a:	83 c4 0c             	add    $0xc,%esp
}
80104e9d:	c9                   	leave
80104e9e:	c3                   	ret

80104e9f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e9f:	f3 0f 1e fb          	endbr32
80104ea3:	55                   	push   %ebp
80104ea4:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ea6:	eb 0c                	jmp    80104eb4 <strncmp+0x15>
    n--, p++, q++;
80104ea8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104eac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104eb0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104eb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104eb8:	74 1a                	je     80104ed4 <strncmp+0x35>
80104eba:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebd:	0f b6 00             	movzbl (%eax),%eax
80104ec0:	84 c0                	test   %al,%al
80104ec2:	74 10                	je     80104ed4 <strncmp+0x35>
80104ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec7:	0f b6 10             	movzbl (%eax),%edx
80104eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ecd:	0f b6 00             	movzbl (%eax),%eax
80104ed0:	38 c2                	cmp    %al,%dl
80104ed2:	74 d4                	je     80104ea8 <strncmp+0x9>
  if(n == 0)
80104ed4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ed8:	75 07                	jne    80104ee1 <strncmp+0x42>
    return 0;
80104eda:	b8 00 00 00 00       	mov    $0x0,%eax
80104edf:	eb 16                	jmp    80104ef7 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	0f b6 00             	movzbl (%eax),%eax
80104ee7:	0f b6 d0             	movzbl %al,%edx
80104eea:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eed:	0f b6 00             	movzbl (%eax),%eax
80104ef0:	0f b6 c0             	movzbl %al,%eax
80104ef3:	29 c2                	sub    %eax,%edx
80104ef5:	89 d0                	mov    %edx,%eax
}
80104ef7:	5d                   	pop    %ebp
80104ef8:	c3                   	ret

80104ef9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104ef9:	f3 0f 1e fb          	endbr32
80104efd:	55                   	push   %ebp
80104efe:	89 e5                	mov    %esp,%ebp
80104f00:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f03:	8b 45 08             	mov    0x8(%ebp),%eax
80104f06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f09:	90                   	nop
80104f0a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f0d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f10:	89 55 10             	mov    %edx,0x10(%ebp)
80104f13:	85 c0                	test   %eax,%eax
80104f15:	7e 2c                	jle    80104f43 <strncpy+0x4a>
80104f17:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f1a:	8d 42 01             	lea    0x1(%edx),%eax
80104f1d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f20:	8b 45 08             	mov    0x8(%ebp),%eax
80104f23:	8d 48 01             	lea    0x1(%eax),%ecx
80104f26:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f29:	0f b6 12             	movzbl (%edx),%edx
80104f2c:	88 10                	mov    %dl,(%eax)
80104f2e:	0f b6 00             	movzbl (%eax),%eax
80104f31:	84 c0                	test   %al,%al
80104f33:	75 d5                	jne    80104f0a <strncpy+0x11>
    ;
  while(n-- > 0)
80104f35:	eb 0c                	jmp    80104f43 <strncpy+0x4a>
    *s++ = 0;
80104f37:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3a:	8d 50 01             	lea    0x1(%eax),%edx
80104f3d:	89 55 08             	mov    %edx,0x8(%ebp)
80104f40:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f43:	8b 45 10             	mov    0x10(%ebp),%eax
80104f46:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f49:	89 55 10             	mov    %edx,0x10(%ebp)
80104f4c:	85 c0                	test   %eax,%eax
80104f4e:	7f e7                	jg     80104f37 <strncpy+0x3e>
  return os;
80104f50:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f53:	c9                   	leave
80104f54:	c3                   	ret

80104f55 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f55:	f3 0f 1e fb          	endbr32
80104f59:	55                   	push   %ebp
80104f5a:	89 e5                	mov    %esp,%ebp
80104f5c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f69:	7f 05                	jg     80104f70 <safestrcpy+0x1b>
    return os;
80104f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f6e:	eb 31                	jmp    80104fa1 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f78:	7e 1e                	jle    80104f98 <safestrcpy+0x43>
80104f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f7d:	8d 42 01             	lea    0x1(%edx),%eax
80104f80:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f83:	8b 45 08             	mov    0x8(%ebp),%eax
80104f86:	8d 48 01             	lea    0x1(%eax),%ecx
80104f89:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f8c:	0f b6 12             	movzbl (%edx),%edx
80104f8f:	88 10                	mov    %dl,(%eax)
80104f91:	0f b6 00             	movzbl (%eax),%eax
80104f94:	84 c0                	test   %al,%al
80104f96:	75 d8                	jne    80104f70 <safestrcpy+0x1b>
    ;
  *s = 0;
80104f98:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fa1:	c9                   	leave
80104fa2:	c3                   	ret

80104fa3 <strlen>:

int
strlen(const char *s)
{
80104fa3:	f3 0f 1e fb          	endbr32
80104fa7:	55                   	push   %ebp
80104fa8:	89 e5                	mov    %esp,%ebp
80104faa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fb4:	eb 04                	jmp    80104fba <strlen+0x17>
80104fb6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104fba:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc0:	01 d0                	add    %edx,%eax
80104fc2:	0f b6 00             	movzbl (%eax),%eax
80104fc5:	84 c0                	test   %al,%al
80104fc7:	75 ed                	jne    80104fb6 <strlen+0x13>
    ;
  return n;
80104fc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fcc:	c9                   	leave
80104fcd:	c3                   	ret

80104fce <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fce:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104fd2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104fd6:	55                   	push   %ebp
  pushl %ebx
80104fd7:	53                   	push   %ebx
  pushl %esi
80104fd8:	56                   	push   %esi
  pushl %edi
80104fd9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104fda:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104fdc:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104fde:	5f                   	pop    %edi
  popl %esi
80104fdf:	5e                   	pop    %esi
  popl %ebx
80104fe0:	5b                   	pop    %ebx
  popl %ebp
80104fe1:	5d                   	pop    %ebp
  ret
80104fe2:	c3                   	ret

80104fe3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104fe3:	f3 0f 1e fb          	endbr32
80104fe7:	55                   	push   %ebp
80104fe8:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104fea:	8b 45 08             	mov    0x8(%ebp),%eax
80104fed:	85 c0                	test   %eax,%eax
80104fef:	78 0a                	js     80104ffb <fetchint+0x18>
80104ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff4:	83 c0 04             	add    $0x4,%eax
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	79 07                	jns    80105002 <fetchint+0x1f>
    return -1;
80104ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105000:	eb 0f                	jmp    80105011 <fetchint+0x2e>
  *ip = *(int*)(addr);
80105002:	8b 45 08             	mov    0x8(%ebp),%eax
80105005:	8b 10                	mov    (%eax),%edx
80105007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500a:	89 10                	mov    %edx,(%eax)
  return 0;
8010500c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105011:	5d                   	pop    %ebp
80105012:	c3                   	ret

80105013 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105013:	f3 0f 1e fb          	endbr32
80105017:	55                   	push   %ebp
80105018:	89 e5                	mov    %esp,%ebp
8010501a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
8010501d:	8b 45 08             	mov    0x8(%ebp),%eax
80105020:	85 c0                	test   %eax,%eax
80105022:	79 07                	jns    8010502b <fetchstr+0x18>
    return -1;
80105024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105029:	eb 42                	jmp    8010506d <fetchstr+0x5a>
  *pp = (char*)addr;
8010502b:	8b 55 08             	mov    0x8(%ebp),%edx
8010502e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105031:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80105033:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
8010503a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503d:	8b 00                	mov    (%eax),%eax
8010503f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105042:	eb 1c                	jmp    80105060 <fetchstr+0x4d>
    if(*s == 0)
80105044:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105047:	0f b6 00             	movzbl (%eax),%eax
8010504a:	84 c0                	test   %al,%al
8010504c:	75 0e                	jne    8010505c <fetchstr+0x49>
      return s - *pp;
8010504e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105051:	8b 00                	mov    (%eax),%eax
80105053:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105056:	29 c2                	sub    %eax,%edx
80105058:	89 d0                	mov    %edx,%eax
8010505a:	eb 11                	jmp    8010506d <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
8010505c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105060:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105063:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105066:	72 dc                	jb     80105044 <fetchstr+0x31>
  }
  return -1;
80105068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010506d:	c9                   	leave
8010506e:	c3                   	ret

8010506f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010506f:	f3 0f 1e fb          	endbr32
80105073:	55                   	push   %ebp
80105074:	89 e5                	mov    %esp,%ebp
80105076:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105079:	e8 99 eb ff ff       	call   80103c17 <myproc>
8010507e:	8b 40 18             	mov    0x18(%eax),%eax
80105081:	8b 40 44             	mov    0x44(%eax),%eax
80105084:	8b 55 08             	mov    0x8(%ebp),%edx
80105087:	c1 e2 02             	shl    $0x2,%edx
8010508a:	01 d0                	add    %edx,%eax
8010508c:	83 c0 04             	add    $0x4,%eax
8010508f:	83 ec 08             	sub    $0x8,%esp
80105092:	ff 75 0c             	push   0xc(%ebp)
80105095:	50                   	push   %eax
80105096:	e8 48 ff ff ff       	call   80104fe3 <fetchint>
8010509b:	83 c4 10             	add    $0x10,%esp
}
8010509e:	c9                   	leave
8010509f:	c3                   	ret

801050a0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050a0:	f3 0f 1e fb          	endbr32
801050a4:	55                   	push   %ebp
801050a5:	89 e5                	mov    %esp,%ebp
801050a7:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801050aa:	83 ec 08             	sub    $0x8,%esp
801050ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050b0:	50                   	push   %eax
801050b1:	ff 75 08             	push   0x8(%ebp)
801050b4:	e8 b6 ff ff ff       	call   8010506f <argint>
801050b9:	83 c4 10             	add    $0x10,%esp
801050bc:	85 c0                	test   %eax,%eax
801050be:	79 07                	jns    801050c7 <argptr+0x27>
    return -1;
801050c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c5:	eb 34                	jmp    801050fb <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801050c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050cb:	78 18                	js     801050e5 <argptr+0x45>
801050cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d0:	85 c0                	test   %eax,%eax
801050d2:	78 11                	js     801050e5 <argptr+0x45>
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	89 c2                	mov    %eax,%edx
801050d9:	8b 45 10             	mov    0x10(%ebp),%eax
801050dc:	01 d0                	add    %edx,%eax
801050de:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801050e3:	76 07                	jbe    801050ec <argptr+0x4c>
    return -1;
801050e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ea:	eb 0f                	jmp    801050fb <argptr+0x5b>
  *pp = (char*)i;
801050ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ef:	89 c2                	mov    %eax,%edx
801050f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f4:	89 10                	mov    %edx,(%eax)
  return 0;
801050f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050fb:	c9                   	leave
801050fc:	c3                   	ret

801050fd <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801050fd:	f3 0f 1e fb          	endbr32
80105101:	55                   	push   %ebp
80105102:	89 e5                	mov    %esp,%ebp
80105104:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105107:	83 ec 08             	sub    $0x8,%esp
8010510a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010510d:	50                   	push   %eax
8010510e:	ff 75 08             	push   0x8(%ebp)
80105111:	e8 59 ff ff ff       	call   8010506f <argint>
80105116:	83 c4 10             	add    $0x10,%esp
80105119:	85 c0                	test   %eax,%eax
8010511b:	79 07                	jns    80105124 <argstr+0x27>
    return -1;
8010511d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105122:	eb 12                	jmp    80105136 <argstr+0x39>
  return fetchstr(addr, pp);
80105124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105127:	83 ec 08             	sub    $0x8,%esp
8010512a:	ff 75 0c             	push   0xc(%ebp)
8010512d:	50                   	push   %eax
8010512e:	e8 e0 fe ff ff       	call   80105013 <fetchstr>
80105133:	83 c4 10             	add    $0x10,%esp
}
80105136:	c9                   	leave
80105137:	c3                   	ret

80105138 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105138:	f3 0f 1e fb          	endbr32
8010513c:	55                   	push   %ebp
8010513d:	89 e5                	mov    %esp,%ebp
8010513f:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105142:	e8 d0 ea ff ff       	call   80103c17 <myproc>
80105147:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010514a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514d:	8b 40 18             	mov    0x18(%eax),%eax
80105150:	8b 40 1c             	mov    0x1c(%eax),%eax
80105153:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105156:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010515a:	7e 2f                	jle    8010518b <syscall+0x53>
8010515c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515f:	83 f8 17             	cmp    $0x17,%eax
80105162:	77 27                	ja     8010518b <syscall+0x53>
80105164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105167:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010516e:	85 c0                	test   %eax,%eax
80105170:	74 19                	je     8010518b <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105175:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010517c:	ff d0                	call   *%eax
8010517e:	89 c2                	mov    %eax,%edx
80105180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105183:	8b 40 18             	mov    0x18(%eax),%eax
80105186:	89 50 1c             	mov    %edx,0x1c(%eax)
80105189:	eb 2c                	jmp    801051b7 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010518b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105194:	8b 40 10             	mov    0x10(%eax),%eax
80105197:	ff 75 f0             	push   -0x10(%ebp)
8010519a:	52                   	push   %edx
8010519b:	50                   	push   %eax
8010519c:	68 3a ac 10 80       	push   $0x8010ac3a
801051a1:	e8 66 b2 ff ff       	call   8010040c <cprintf>
801051a6:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ac:	8b 40 18             	mov    0x18(%eax),%eax
801051af:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051b6:	90                   	nop
801051b7:	90                   	nop
801051b8:	c9                   	leave
801051b9:	c3                   	ret

801051ba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051ba:	f3 0f 1e fb          	endbr32
801051be:	55                   	push   %ebp
801051bf:	89 e5                	mov    %esp,%ebp
801051c1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051c4:	83 ec 08             	sub    $0x8,%esp
801051c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ca:	50                   	push   %eax
801051cb:	ff 75 08             	push   0x8(%ebp)
801051ce:	e8 9c fe ff ff       	call   8010506f <argint>
801051d3:	83 c4 10             	add    $0x10,%esp
801051d6:	85 c0                	test   %eax,%eax
801051d8:	79 07                	jns    801051e1 <argfd+0x27>
    return -1;
801051da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051df:	eb 4f                	jmp    80105230 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e4:	85 c0                	test   %eax,%eax
801051e6:	78 20                	js     80105208 <argfd+0x4e>
801051e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051eb:	83 f8 0f             	cmp    $0xf,%eax
801051ee:	7f 18                	jg     80105208 <argfd+0x4e>
801051f0:	e8 22 ea ff ff       	call   80103c17 <myproc>
801051f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051f8:	83 c2 08             	add    $0x8,%edx
801051fb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105202:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105206:	75 07                	jne    8010520f <argfd+0x55>
    return -1;
80105208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520d:	eb 21                	jmp    80105230 <argfd+0x76>
  if(pfd)
8010520f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105213:	74 08                	je     8010521d <argfd+0x63>
    *pfd = fd;
80105215:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105218:	8b 45 0c             	mov    0xc(%ebp),%eax
8010521b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010521d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105221:	74 08                	je     8010522b <argfd+0x71>
    *pf = f;
80105223:	8b 45 10             	mov    0x10(%ebp),%eax
80105226:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105229:	89 10                	mov    %edx,(%eax)
  return 0;
8010522b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105230:	c9                   	leave
80105231:	c3                   	ret

80105232 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105232:	f3 0f 1e fb          	endbr32
80105236:	55                   	push   %ebp
80105237:	89 e5                	mov    %esp,%ebp
80105239:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010523c:	e8 d6 e9 ff ff       	call   80103c17 <myproc>
80105241:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105244:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010524b:	eb 2a                	jmp    80105277 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010524d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105250:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105253:	83 c2 08             	add    $0x8,%edx
80105256:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 15                	jne    80105273 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010525e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105261:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105264:	8d 4a 08             	lea    0x8(%edx),%ecx
80105267:	8b 55 08             	mov    0x8(%ebp),%edx
8010526a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010526e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105271:	eb 0f                	jmp    80105282 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105273:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105277:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010527b:	7e d0                	jle    8010524d <fdalloc+0x1b>
    }
  }
  return -1;
8010527d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105282:	c9                   	leave
80105283:	c3                   	ret

80105284 <sys_dup>:

int
sys_dup(void)
{
80105284:	f3 0f 1e fb          	endbr32
80105288:	55                   	push   %ebp
80105289:	89 e5                	mov    %esp,%ebp
8010528b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010528e:	83 ec 04             	sub    $0x4,%esp
80105291:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105294:	50                   	push   %eax
80105295:	6a 00                	push   $0x0
80105297:	6a 00                	push   $0x0
80105299:	e8 1c ff ff ff       	call   801051ba <argfd>
8010529e:	83 c4 10             	add    $0x10,%esp
801052a1:	85 c0                	test   %eax,%eax
801052a3:	79 07                	jns    801052ac <sys_dup+0x28>
    return -1;
801052a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052aa:	eb 31                	jmp    801052dd <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801052ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052af:	83 ec 0c             	sub    $0xc,%esp
801052b2:	50                   	push   %eax
801052b3:	e8 7a ff ff ff       	call   80105232 <fdalloc>
801052b8:	83 c4 10             	add    $0x10,%esp
801052bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052c2:	79 07                	jns    801052cb <sys_dup+0x47>
    return -1;
801052c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c9:	eb 12                	jmp    801052dd <sys_dup+0x59>
  filedup(f);
801052cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ce:	83 ec 0c             	sub    $0xc,%esp
801052d1:	50                   	push   %eax
801052d2:	e8 2b be ff ff       	call   80101102 <filedup>
801052d7:	83 c4 10             	add    $0x10,%esp
  return fd;
801052da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052dd:	c9                   	leave
801052de:	c3                   	ret

801052df <sys_read>:

int
sys_read(void)
{
801052df:	f3 0f 1e fb          	endbr32
801052e3:	55                   	push   %ebp
801052e4:	89 e5                	mov    %esp,%ebp
801052e6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052e9:	83 ec 04             	sub    $0x4,%esp
801052ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052ef:	50                   	push   %eax
801052f0:	6a 00                	push   $0x0
801052f2:	6a 00                	push   $0x0
801052f4:	e8 c1 fe ff ff       	call   801051ba <argfd>
801052f9:	83 c4 10             	add    $0x10,%esp
801052fc:	85 c0                	test   %eax,%eax
801052fe:	78 2e                	js     8010532e <sys_read+0x4f>
80105300:	83 ec 08             	sub    $0x8,%esp
80105303:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105306:	50                   	push   %eax
80105307:	6a 02                	push   $0x2
80105309:	e8 61 fd ff ff       	call   8010506f <argint>
8010530e:	83 c4 10             	add    $0x10,%esp
80105311:	85 c0                	test   %eax,%eax
80105313:	78 19                	js     8010532e <sys_read+0x4f>
80105315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105318:	83 ec 04             	sub    $0x4,%esp
8010531b:	50                   	push   %eax
8010531c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010531f:	50                   	push   %eax
80105320:	6a 01                	push   $0x1
80105322:	e8 79 fd ff ff       	call   801050a0 <argptr>
80105327:	83 c4 10             	add    $0x10,%esp
8010532a:	85 c0                	test   %eax,%eax
8010532c:	79 07                	jns    80105335 <sys_read+0x56>
    return -1;
8010532e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105333:	eb 17                	jmp    8010534c <sys_read+0x6d>
  return fileread(f, p, n);
80105335:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105338:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010533b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533e:	83 ec 04             	sub    $0x4,%esp
80105341:	51                   	push   %ecx
80105342:	52                   	push   %edx
80105343:	50                   	push   %eax
80105344:	e8 55 bf ff ff       	call   8010129e <fileread>
80105349:	83 c4 10             	add    $0x10,%esp
}
8010534c:	c9                   	leave
8010534d:	c3                   	ret

8010534e <sys_write>:

int
sys_write(void)
{
8010534e:	f3 0f 1e fb          	endbr32
80105352:	55                   	push   %ebp
80105353:	89 e5                	mov    %esp,%ebp
80105355:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105358:	83 ec 04             	sub    $0x4,%esp
8010535b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010535e:	50                   	push   %eax
8010535f:	6a 00                	push   $0x0
80105361:	6a 00                	push   $0x0
80105363:	e8 52 fe ff ff       	call   801051ba <argfd>
80105368:	83 c4 10             	add    $0x10,%esp
8010536b:	85 c0                	test   %eax,%eax
8010536d:	78 2e                	js     8010539d <sys_write+0x4f>
8010536f:	83 ec 08             	sub    $0x8,%esp
80105372:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105375:	50                   	push   %eax
80105376:	6a 02                	push   $0x2
80105378:	e8 f2 fc ff ff       	call   8010506f <argint>
8010537d:	83 c4 10             	add    $0x10,%esp
80105380:	85 c0                	test   %eax,%eax
80105382:	78 19                	js     8010539d <sys_write+0x4f>
80105384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105387:	83 ec 04             	sub    $0x4,%esp
8010538a:	50                   	push   %eax
8010538b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010538e:	50                   	push   %eax
8010538f:	6a 01                	push   $0x1
80105391:	e8 0a fd ff ff       	call   801050a0 <argptr>
80105396:	83 c4 10             	add    $0x10,%esp
80105399:	85 c0                	test   %eax,%eax
8010539b:	79 07                	jns    801053a4 <sys_write+0x56>
    return -1;
8010539d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a2:	eb 17                	jmp    801053bb <sys_write+0x6d>
  return filewrite(f, p, n);
801053a4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ad:	83 ec 04             	sub    $0x4,%esp
801053b0:	51                   	push   %ecx
801053b1:	52                   	push   %edx
801053b2:	50                   	push   %eax
801053b3:	e8 a2 bf ff ff       	call   8010135a <filewrite>
801053b8:	83 c4 10             	add    $0x10,%esp
}
801053bb:	c9                   	leave
801053bc:	c3                   	ret

801053bd <sys_close>:

int
sys_close(void)
{
801053bd:	f3 0f 1e fb          	endbr32
801053c1:	55                   	push   %ebp
801053c2:	89 e5                	mov    %esp,%ebp
801053c4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053c7:	83 ec 04             	sub    $0x4,%esp
801053ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053cd:	50                   	push   %eax
801053ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d1:	50                   	push   %eax
801053d2:	6a 00                	push   $0x0
801053d4:	e8 e1 fd ff ff       	call   801051ba <argfd>
801053d9:	83 c4 10             	add    $0x10,%esp
801053dc:	85 c0                	test   %eax,%eax
801053de:	79 07                	jns    801053e7 <sys_close+0x2a>
    return -1;
801053e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e5:	eb 27                	jmp    8010540e <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801053e7:	e8 2b e8 ff ff       	call   80103c17 <myproc>
801053ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053ef:	83 c2 08             	add    $0x8,%edx
801053f2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801053f9:	00 
  fileclose(f);
801053fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fd:	83 ec 0c             	sub    $0xc,%esp
80105400:	50                   	push   %eax
80105401:	e8 51 bd ff ff       	call   80101157 <fileclose>
80105406:	83 c4 10             	add    $0x10,%esp
  return 0;
80105409:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010540e:	c9                   	leave
8010540f:	c3                   	ret

80105410 <sys_fstat>:

int
sys_fstat(void)
{
80105410:	f3 0f 1e fb          	endbr32
80105414:	55                   	push   %ebp
80105415:	89 e5                	mov    %esp,%ebp
80105417:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010541a:	83 ec 04             	sub    $0x4,%esp
8010541d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105420:	50                   	push   %eax
80105421:	6a 00                	push   $0x0
80105423:	6a 00                	push   $0x0
80105425:	e8 90 fd ff ff       	call   801051ba <argfd>
8010542a:	83 c4 10             	add    $0x10,%esp
8010542d:	85 c0                	test   %eax,%eax
8010542f:	78 17                	js     80105448 <sys_fstat+0x38>
80105431:	83 ec 04             	sub    $0x4,%esp
80105434:	6a 14                	push   $0x14
80105436:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105439:	50                   	push   %eax
8010543a:	6a 01                	push   $0x1
8010543c:	e8 5f fc ff ff       	call   801050a0 <argptr>
80105441:	83 c4 10             	add    $0x10,%esp
80105444:	85 c0                	test   %eax,%eax
80105446:	79 07                	jns    8010544f <sys_fstat+0x3f>
    return -1;
80105448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010544d:	eb 13                	jmp    80105462 <sys_fstat+0x52>
  return filestat(f, st);
8010544f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105455:	83 ec 08             	sub    $0x8,%esp
80105458:	52                   	push   %edx
80105459:	50                   	push   %eax
8010545a:	e8 e4 bd ff ff       	call   80101243 <filestat>
8010545f:	83 c4 10             	add    $0x10,%esp
}
80105462:	c9                   	leave
80105463:	c3                   	ret

80105464 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105464:	f3 0f 1e fb          	endbr32
80105468:	55                   	push   %ebp
80105469:	89 e5                	mov    %esp,%ebp
8010546b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010546e:	83 ec 08             	sub    $0x8,%esp
80105471:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105474:	50                   	push   %eax
80105475:	6a 00                	push   $0x0
80105477:	e8 81 fc ff ff       	call   801050fd <argstr>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	85 c0                	test   %eax,%eax
80105481:	78 15                	js     80105498 <sys_link+0x34>
80105483:	83 ec 08             	sub    $0x8,%esp
80105486:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105489:	50                   	push   %eax
8010548a:	6a 01                	push   $0x1
8010548c:	e8 6c fc ff ff       	call   801050fd <argstr>
80105491:	83 c4 10             	add    $0x10,%esp
80105494:	85 c0                	test   %eax,%eax
80105496:	79 0a                	jns    801054a2 <sys_link+0x3e>
    return -1;
80105498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549d:	e9 68 01 00 00       	jmp    8010560a <sys_link+0x1a6>

  begin_op();
801054a2:	e8 38 dd ff ff       	call   801031df <begin_op>
  if((ip = namei(old)) == 0){
801054a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054aa:	83 ec 0c             	sub    $0xc,%esp
801054ad:	50                   	push   %eax
801054ae:	e8 a2 d1 ff ff       	call   80102655 <namei>
801054b3:	83 c4 10             	add    $0x10,%esp
801054b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054bd:	75 0f                	jne    801054ce <sys_link+0x6a>
    end_op();
801054bf:	e8 ab dd ff ff       	call   8010326f <end_op>
    return -1;
801054c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c9:	e9 3c 01 00 00       	jmp    8010560a <sys_link+0x1a6>
  }

  ilock(ip);
801054ce:	83 ec 0c             	sub    $0xc,%esp
801054d1:	ff 75 f4             	push   -0xc(%ebp)
801054d4:	e8 11 c6 ff ff       	call   80101aea <ilock>
801054d9:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801054dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054df:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054e3:	66 83 f8 01          	cmp    $0x1,%ax
801054e7:	75 1d                	jne    80105506 <sys_link+0xa2>
    iunlockput(ip);
801054e9:	83 ec 0c             	sub    $0xc,%esp
801054ec:	ff 75 f4             	push   -0xc(%ebp)
801054ef:	e8 33 c8 ff ff       	call   80101d27 <iunlockput>
801054f4:	83 c4 10             	add    $0x10,%esp
    end_op();
801054f7:	e8 73 dd ff ff       	call   8010326f <end_op>
    return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105501:	e9 04 01 00 00       	jmp    8010560a <sys_link+0x1a6>
  }

  ip->nlink++;
80105506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105509:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010550d:	83 c0 01             	add    $0x1,%eax
80105510:	89 c2                	mov    %eax,%edx
80105512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105515:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105519:	83 ec 0c             	sub    $0xc,%esp
8010551c:	ff 75 f4             	push   -0xc(%ebp)
8010551f:	e8 dd c3 ff ff       	call   80101901 <iupdate>
80105524:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105527:	83 ec 0c             	sub    $0xc,%esp
8010552a:	ff 75 f4             	push   -0xc(%ebp)
8010552d:	e8 cf c6 ff ff       	call   80101c01 <iunlock>
80105532:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105535:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105538:	83 ec 08             	sub    $0x8,%esp
8010553b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010553e:	52                   	push   %edx
8010553f:	50                   	push   %eax
80105540:	e8 30 d1 ff ff       	call   80102675 <nameiparent>
80105545:	83 c4 10             	add    $0x10,%esp
80105548:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010554b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010554f:	74 71                	je     801055c2 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	ff 75 f0             	push   -0x10(%ebp)
80105557:	e8 8e c5 ff ff       	call   80101aea <ilock>
8010555c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010555f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105562:	8b 10                	mov    (%eax),%edx
80105564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105567:	8b 00                	mov    (%eax),%eax
80105569:	39 c2                	cmp    %eax,%edx
8010556b:	75 1d                	jne    8010558a <sys_link+0x126>
8010556d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105570:	8b 40 04             	mov    0x4(%eax),%eax
80105573:	83 ec 04             	sub    $0x4,%esp
80105576:	50                   	push   %eax
80105577:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010557a:	50                   	push   %eax
8010557b:	ff 75 f0             	push   -0x10(%ebp)
8010557e:	e8 2f ce ff ff       	call   801023b2 <dirlink>
80105583:	83 c4 10             	add    $0x10,%esp
80105586:	85 c0                	test   %eax,%eax
80105588:	79 10                	jns    8010559a <sys_link+0x136>
    iunlockput(dp);
8010558a:	83 ec 0c             	sub    $0xc,%esp
8010558d:	ff 75 f0             	push   -0x10(%ebp)
80105590:	e8 92 c7 ff ff       	call   80101d27 <iunlockput>
80105595:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105598:	eb 29                	jmp    801055c3 <sys_link+0x15f>
  }
  iunlockput(dp);
8010559a:	83 ec 0c             	sub    $0xc,%esp
8010559d:	ff 75 f0             	push   -0x10(%ebp)
801055a0:	e8 82 c7 ff ff       	call   80101d27 <iunlockput>
801055a5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055a8:	83 ec 0c             	sub    $0xc,%esp
801055ab:	ff 75 f4             	push   -0xc(%ebp)
801055ae:	e8 a0 c6 ff ff       	call   80101c53 <iput>
801055b3:	83 c4 10             	add    $0x10,%esp

  end_op();
801055b6:	e8 b4 dc ff ff       	call   8010326f <end_op>

  return 0;
801055bb:	b8 00 00 00 00       	mov    $0x0,%eax
801055c0:	eb 48                	jmp    8010560a <sys_link+0x1a6>
    goto bad;
801055c2:	90                   	nop

bad:
  ilock(ip);
801055c3:	83 ec 0c             	sub    $0xc,%esp
801055c6:	ff 75 f4             	push   -0xc(%ebp)
801055c9:	e8 1c c5 ff ff       	call   80101aea <ilock>
801055ce:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055d8:	83 e8 01             	sub    $0x1,%eax
801055db:	89 c2                	mov    %eax,%edx
801055dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055e4:	83 ec 0c             	sub    $0xc,%esp
801055e7:	ff 75 f4             	push   -0xc(%ebp)
801055ea:	e8 12 c3 ff ff       	call   80101901 <iupdate>
801055ef:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801055f2:	83 ec 0c             	sub    $0xc,%esp
801055f5:	ff 75 f4             	push   -0xc(%ebp)
801055f8:	e8 2a c7 ff ff       	call   80101d27 <iunlockput>
801055fd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105600:	e8 6a dc ff ff       	call   8010326f <end_op>
  return -1;
80105605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010560a:	c9                   	leave
8010560b:	c3                   	ret

8010560c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010560c:	f3 0f 1e fb          	endbr32
80105610:	55                   	push   %ebp
80105611:	89 e5                	mov    %esp,%ebp
80105613:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105616:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010561d:	eb 40                	jmp    8010565f <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105622:	6a 10                	push   $0x10
80105624:	50                   	push   %eax
80105625:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105628:	50                   	push   %eax
80105629:	ff 75 08             	push   0x8(%ebp)
8010562c:	e8 c1 c9 ff ff       	call   80101ff2 <readi>
80105631:	83 c4 10             	add    $0x10,%esp
80105634:	83 f8 10             	cmp    $0x10,%eax
80105637:	74 0d                	je     80105646 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105639:	83 ec 0c             	sub    $0xc,%esp
8010563c:	68 56 ac 10 80       	push   $0x8010ac56
80105641:	e8 98 af ff ff       	call   801005de <panic>
    if(de.inum != 0)
80105646:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010564a:	66 85 c0             	test   %ax,%ax
8010564d:	74 07                	je     80105656 <isdirempty+0x4a>
      return 0;
8010564f:	b8 00 00 00 00       	mov    $0x0,%eax
80105654:	eb 1b                	jmp    80105671 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105659:	83 c0 10             	add    $0x10,%eax
8010565c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010565f:	8b 45 08             	mov    0x8(%ebp),%eax
80105662:	8b 50 58             	mov    0x58(%eax),%edx
80105665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105668:	39 c2                	cmp    %eax,%edx
8010566a:	77 b3                	ja     8010561f <isdirempty+0x13>
  }
  return 1;
8010566c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105671:	c9                   	leave
80105672:	c3                   	ret

80105673 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105673:	f3 0f 1e fb          	endbr32
80105677:	55                   	push   %ebp
80105678:	89 e5                	mov    %esp,%ebp
8010567a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010567d:	83 ec 08             	sub    $0x8,%esp
80105680:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105683:	50                   	push   %eax
80105684:	6a 00                	push   $0x0
80105686:	e8 72 fa ff ff       	call   801050fd <argstr>
8010568b:	83 c4 10             	add    $0x10,%esp
8010568e:	85 c0                	test   %eax,%eax
80105690:	79 0a                	jns    8010569c <sys_unlink+0x29>
    return -1;
80105692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105697:	e9 bf 01 00 00       	jmp    8010585b <sys_unlink+0x1e8>

  begin_op();
8010569c:	e8 3e db ff ff       	call   801031df <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056a4:	83 ec 08             	sub    $0x8,%esp
801056a7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056aa:	52                   	push   %edx
801056ab:	50                   	push   %eax
801056ac:	e8 c4 cf ff ff       	call   80102675 <nameiparent>
801056b1:	83 c4 10             	add    $0x10,%esp
801056b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056bb:	75 0f                	jne    801056cc <sys_unlink+0x59>
    end_op();
801056bd:	e8 ad db ff ff       	call   8010326f <end_op>
    return -1;
801056c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c7:	e9 8f 01 00 00       	jmp    8010585b <sys_unlink+0x1e8>
  }

  ilock(dp);
801056cc:	83 ec 0c             	sub    $0xc,%esp
801056cf:	ff 75 f4             	push   -0xc(%ebp)
801056d2:	e8 13 c4 ff ff       	call   80101aea <ilock>
801056d7:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056da:	83 ec 08             	sub    $0x8,%esp
801056dd:	68 68 ac 10 80       	push   $0x8010ac68
801056e2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056e5:	50                   	push   %eax
801056e6:	e8 ea cb ff ff       	call   801022d5 <namecmp>
801056eb:	83 c4 10             	add    $0x10,%esp
801056ee:	85 c0                	test   %eax,%eax
801056f0:	0f 84 49 01 00 00    	je     8010583f <sys_unlink+0x1cc>
801056f6:	83 ec 08             	sub    $0x8,%esp
801056f9:	68 6a ac 10 80       	push   $0x8010ac6a
801056fe:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105701:	50                   	push   %eax
80105702:	e8 ce cb ff ff       	call   801022d5 <namecmp>
80105707:	83 c4 10             	add    $0x10,%esp
8010570a:	85 c0                	test   %eax,%eax
8010570c:	0f 84 2d 01 00 00    	je     8010583f <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105712:	83 ec 04             	sub    $0x4,%esp
80105715:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105718:	50                   	push   %eax
80105719:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010571c:	50                   	push   %eax
8010571d:	ff 75 f4             	push   -0xc(%ebp)
80105720:	e8 cf cb ff ff       	call   801022f4 <dirlookup>
80105725:	83 c4 10             	add    $0x10,%esp
80105728:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010572b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010572f:	0f 84 0d 01 00 00    	je     80105842 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105735:	83 ec 0c             	sub    $0xc,%esp
80105738:	ff 75 f0             	push   -0x10(%ebp)
8010573b:	e8 aa c3 ff ff       	call   80101aea <ilock>
80105740:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105746:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010574a:	66 85 c0             	test   %ax,%ax
8010574d:	7f 0d                	jg     8010575c <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010574f:	83 ec 0c             	sub    $0xc,%esp
80105752:	68 6d ac 10 80       	push   $0x8010ac6d
80105757:	e8 82 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010575c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105763:	66 83 f8 01          	cmp    $0x1,%ax
80105767:	75 25                	jne    8010578e <sys_unlink+0x11b>
80105769:	83 ec 0c             	sub    $0xc,%esp
8010576c:	ff 75 f0             	push   -0x10(%ebp)
8010576f:	e8 98 fe ff ff       	call   8010560c <isdirempty>
80105774:	83 c4 10             	add    $0x10,%esp
80105777:	85 c0                	test   %eax,%eax
80105779:	75 13                	jne    8010578e <sys_unlink+0x11b>
    iunlockput(ip);
8010577b:	83 ec 0c             	sub    $0xc,%esp
8010577e:	ff 75 f0             	push   -0x10(%ebp)
80105781:	e8 a1 c5 ff ff       	call   80101d27 <iunlockput>
80105786:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105789:	e9 b5 00 00 00       	jmp    80105843 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010578e:	83 ec 04             	sub    $0x4,%esp
80105791:	6a 10                	push   $0x10
80105793:	6a 00                	push   $0x0
80105795:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105798:	50                   	push   %eax
80105799:	e8 9c f5 ff ff       	call   80104d3a <memset>
8010579e:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057a4:	6a 10                	push   $0x10
801057a6:	50                   	push   %eax
801057a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057aa:	50                   	push   %eax
801057ab:	ff 75 f4             	push   -0xc(%ebp)
801057ae:	e8 98 c9 ff ff       	call   8010214b <writei>
801057b3:	83 c4 10             	add    $0x10,%esp
801057b6:	83 f8 10             	cmp    $0x10,%eax
801057b9:	74 0d                	je     801057c8 <sys_unlink+0x155>
    panic("unlink: writei");
801057bb:	83 ec 0c             	sub    $0xc,%esp
801057be:	68 7f ac 10 80       	push   $0x8010ac7f
801057c3:	e8 16 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
801057c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057cb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057cf:	66 83 f8 01          	cmp    $0x1,%ax
801057d3:	75 21                	jne    801057f6 <sys_unlink+0x183>
    dp->nlink--;
801057d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057dc:	83 e8 01             	sub    $0x1,%eax
801057df:	89 c2                	mov    %eax,%edx
801057e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057e8:	83 ec 0c             	sub    $0xc,%esp
801057eb:	ff 75 f4             	push   -0xc(%ebp)
801057ee:	e8 0e c1 ff ff       	call   80101901 <iupdate>
801057f3:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801057f6:	83 ec 0c             	sub    $0xc,%esp
801057f9:	ff 75 f4             	push   -0xc(%ebp)
801057fc:	e8 26 c5 ff ff       	call   80101d27 <iunlockput>
80105801:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105807:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010580b:	83 e8 01             	sub    $0x1,%eax
8010580e:	89 c2                	mov    %eax,%edx
80105810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105813:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	ff 75 f0             	push   -0x10(%ebp)
8010581d:	e8 df c0 ff ff       	call   80101901 <iupdate>
80105822:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105825:	83 ec 0c             	sub    $0xc,%esp
80105828:	ff 75 f0             	push   -0x10(%ebp)
8010582b:	e8 f7 c4 ff ff       	call   80101d27 <iunlockput>
80105830:	83 c4 10             	add    $0x10,%esp

  end_op();
80105833:	e8 37 da ff ff       	call   8010326f <end_op>

  return 0;
80105838:	b8 00 00 00 00       	mov    $0x0,%eax
8010583d:	eb 1c                	jmp    8010585b <sys_unlink+0x1e8>
    goto bad;
8010583f:	90                   	nop
80105840:	eb 01                	jmp    80105843 <sys_unlink+0x1d0>
    goto bad;
80105842:	90                   	nop

bad:
  iunlockput(dp);
80105843:	83 ec 0c             	sub    $0xc,%esp
80105846:	ff 75 f4             	push   -0xc(%ebp)
80105849:	e8 d9 c4 ff ff       	call   80101d27 <iunlockput>
8010584e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105851:	e8 19 da ff ff       	call   8010326f <end_op>
  return -1;
80105856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010585b:	c9                   	leave
8010585c:	c3                   	ret

8010585d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010585d:	f3 0f 1e fb          	endbr32
80105861:	55                   	push   %ebp
80105862:	89 e5                	mov    %esp,%ebp
80105864:	83 ec 38             	sub    $0x38,%esp
80105867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010586a:	8b 55 10             	mov    0x10(%ebp),%edx
8010586d:	8b 45 14             	mov    0x14(%ebp),%eax
80105870:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105874:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105878:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010587c:	83 ec 08             	sub    $0x8,%esp
8010587f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105882:	50                   	push   %eax
80105883:	ff 75 08             	push   0x8(%ebp)
80105886:	e8 ea cd ff ff       	call   80102675 <nameiparent>
8010588b:	83 c4 10             	add    $0x10,%esp
8010588e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105891:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105895:	75 0a                	jne    801058a1 <create+0x44>
    return 0;
80105897:	b8 00 00 00 00       	mov    $0x0,%eax
8010589c:	e9 90 01 00 00       	jmp    80105a31 <create+0x1d4>
  ilock(dp);
801058a1:	83 ec 0c             	sub    $0xc,%esp
801058a4:	ff 75 f4             	push   -0xc(%ebp)
801058a7:	e8 3e c2 ff ff       	call   80101aea <ilock>
801058ac:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058af:	83 ec 04             	sub    $0x4,%esp
801058b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058b5:	50                   	push   %eax
801058b6:	8d 45 de             	lea    -0x22(%ebp),%eax
801058b9:	50                   	push   %eax
801058ba:	ff 75 f4             	push   -0xc(%ebp)
801058bd:	e8 32 ca ff ff       	call   801022f4 <dirlookup>
801058c2:	83 c4 10             	add    $0x10,%esp
801058c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058cc:	74 50                	je     8010591e <create+0xc1>
    iunlockput(dp);
801058ce:	83 ec 0c             	sub    $0xc,%esp
801058d1:	ff 75 f4             	push   -0xc(%ebp)
801058d4:	e8 4e c4 ff ff       	call   80101d27 <iunlockput>
801058d9:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	ff 75 f0             	push   -0x10(%ebp)
801058e2:	e8 03 c2 ff ff       	call   80101aea <ilock>
801058e7:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801058ea:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801058ef:	75 15                	jne    80105906 <create+0xa9>
801058f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058f8:	66 83 f8 02          	cmp    $0x2,%ax
801058fc:	75 08                	jne    80105906 <create+0xa9>
      return ip;
801058fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105901:	e9 2b 01 00 00       	jmp    80105a31 <create+0x1d4>
    iunlockput(ip);
80105906:	83 ec 0c             	sub    $0xc,%esp
80105909:	ff 75 f0             	push   -0x10(%ebp)
8010590c:	e8 16 c4 ff ff       	call   80101d27 <iunlockput>
80105911:	83 c4 10             	add    $0x10,%esp
    return 0;
80105914:	b8 00 00 00 00       	mov    $0x0,%eax
80105919:	e9 13 01 00 00       	jmp    80105a31 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010591e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105925:	8b 00                	mov    (%eax),%eax
80105927:	83 ec 08             	sub    $0x8,%esp
8010592a:	52                   	push   %edx
8010592b:	50                   	push   %eax
8010592c:	e8 f5 be ff ff       	call   80101826 <ialloc>
80105931:	83 c4 10             	add    $0x10,%esp
80105934:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010593b:	75 0d                	jne    8010594a <create+0xed>
    panic("create: ialloc");
8010593d:	83 ec 0c             	sub    $0xc,%esp
80105940:	68 8e ac 10 80       	push   $0x8010ac8e
80105945:	e8 94 ac ff ff       	call   801005de <panic>

  ilock(ip);
8010594a:	83 ec 0c             	sub    $0xc,%esp
8010594d:	ff 75 f0             	push   -0x10(%ebp)
80105950:	e8 95 c1 ff ff       	call   80101aea <ilock>
80105955:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010595f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105966:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010596a:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010596e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105971:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105977:	83 ec 0c             	sub    $0xc,%esp
8010597a:	ff 75 f0             	push   -0x10(%ebp)
8010597d:	e8 7f bf ff ff       	call   80101901 <iupdate>
80105982:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105985:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010598a:	75 6a                	jne    801059f6 <create+0x199>
    dp->nlink++;  // for ".."
8010598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105993:	83 c0 01             	add    $0x1,%eax
80105996:	89 c2                	mov    %eax,%edx
80105998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010599f:	83 ec 0c             	sub    $0xc,%esp
801059a2:	ff 75 f4             	push   -0xc(%ebp)
801059a5:	e8 57 bf ff ff       	call   80101901 <iupdate>
801059aa:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b0:	8b 40 04             	mov    0x4(%eax),%eax
801059b3:	83 ec 04             	sub    $0x4,%esp
801059b6:	50                   	push   %eax
801059b7:	68 68 ac 10 80       	push   $0x8010ac68
801059bc:	ff 75 f0             	push   -0x10(%ebp)
801059bf:	e8 ee c9 ff ff       	call   801023b2 <dirlink>
801059c4:	83 c4 10             	add    $0x10,%esp
801059c7:	85 c0                	test   %eax,%eax
801059c9:	78 1e                	js     801059e9 <create+0x18c>
801059cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ce:	8b 40 04             	mov    0x4(%eax),%eax
801059d1:	83 ec 04             	sub    $0x4,%esp
801059d4:	50                   	push   %eax
801059d5:	68 6a ac 10 80       	push   $0x8010ac6a
801059da:	ff 75 f0             	push   -0x10(%ebp)
801059dd:	e8 d0 c9 ff ff       	call   801023b2 <dirlink>
801059e2:	83 c4 10             	add    $0x10,%esp
801059e5:	85 c0                	test   %eax,%eax
801059e7:	79 0d                	jns    801059f6 <create+0x199>
      panic("create dots");
801059e9:	83 ec 0c             	sub    $0xc,%esp
801059ec:	68 9d ac 10 80       	push   $0x8010ac9d
801059f1:	e8 e8 ab ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801059f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f9:	8b 40 04             	mov    0x4(%eax),%eax
801059fc:	83 ec 04             	sub    $0x4,%esp
801059ff:	50                   	push   %eax
80105a00:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a03:	50                   	push   %eax
80105a04:	ff 75 f4             	push   -0xc(%ebp)
80105a07:	e8 a6 c9 ff ff       	call   801023b2 <dirlink>
80105a0c:	83 c4 10             	add    $0x10,%esp
80105a0f:	85 c0                	test   %eax,%eax
80105a11:	79 0d                	jns    80105a20 <create+0x1c3>
    panic("create: dirlink");
80105a13:	83 ec 0c             	sub    $0xc,%esp
80105a16:	68 a9 ac 10 80       	push   $0x8010aca9
80105a1b:	e8 be ab ff ff       	call   801005de <panic>

  iunlockput(dp);
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	ff 75 f4             	push   -0xc(%ebp)
80105a26:	e8 fc c2 ff ff       	call   80101d27 <iunlockput>
80105a2b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a31:	c9                   	leave
80105a32:	c3                   	ret

80105a33 <sys_open>:

int
sys_open(void)
{
80105a33:	f3 0f 1e fb          	endbr32
80105a37:	55                   	push   %ebp
80105a38:	89 e5                	mov    %esp,%ebp
80105a3a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a3d:	83 ec 08             	sub    $0x8,%esp
80105a40:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a43:	50                   	push   %eax
80105a44:	6a 00                	push   $0x0
80105a46:	e8 b2 f6 ff ff       	call   801050fd <argstr>
80105a4b:	83 c4 10             	add    $0x10,%esp
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	78 15                	js     80105a67 <sys_open+0x34>
80105a52:	83 ec 08             	sub    $0x8,%esp
80105a55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a58:	50                   	push   %eax
80105a59:	6a 01                	push   $0x1
80105a5b:	e8 0f f6 ff ff       	call   8010506f <argint>
80105a60:	83 c4 10             	add    $0x10,%esp
80105a63:	85 c0                	test   %eax,%eax
80105a65:	79 0a                	jns    80105a71 <sys_open+0x3e>
    return -1;
80105a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6c:	e9 61 01 00 00       	jmp    80105bd2 <sys_open+0x19f>

  begin_op();
80105a71:	e8 69 d7 ff ff       	call   801031df <begin_op>

  if(omode & O_CREATE){
80105a76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a79:	25 00 02 00 00       	and    $0x200,%eax
80105a7e:	85 c0                	test   %eax,%eax
80105a80:	74 2a                	je     80105aac <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a85:	6a 00                	push   $0x0
80105a87:	6a 00                	push   $0x0
80105a89:	6a 02                	push   $0x2
80105a8b:	50                   	push   %eax
80105a8c:	e8 cc fd ff ff       	call   8010585d <create>
80105a91:	83 c4 10             	add    $0x10,%esp
80105a94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a9b:	75 75                	jne    80105b12 <sys_open+0xdf>
      end_op();
80105a9d:	e8 cd d7 ff ff       	call   8010326f <end_op>
      return -1;
80105aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa7:	e9 26 01 00 00       	jmp    80105bd2 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aaf:	83 ec 0c             	sub    $0xc,%esp
80105ab2:	50                   	push   %eax
80105ab3:	e8 9d cb ff ff       	call   80102655 <namei>
80105ab8:	83 c4 10             	add    $0x10,%esp
80105abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105abe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac2:	75 0f                	jne    80105ad3 <sys_open+0xa0>
      end_op();
80105ac4:	e8 a6 d7 ff ff       	call   8010326f <end_op>
      return -1;
80105ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ace:	e9 ff 00 00 00       	jmp    80105bd2 <sys_open+0x19f>
    }
    ilock(ip);
80105ad3:	83 ec 0c             	sub    $0xc,%esp
80105ad6:	ff 75 f4             	push   -0xc(%ebp)
80105ad9:	e8 0c c0 ff ff       	call   80101aea <ilock>
80105ade:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ae8:	66 83 f8 01          	cmp    $0x1,%ax
80105aec:	75 24                	jne    80105b12 <sys_open+0xdf>
80105aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105af1:	85 c0                	test   %eax,%eax
80105af3:	74 1d                	je     80105b12 <sys_open+0xdf>
      iunlockput(ip);
80105af5:	83 ec 0c             	sub    $0xc,%esp
80105af8:	ff 75 f4             	push   -0xc(%ebp)
80105afb:	e8 27 c2 ff ff       	call   80101d27 <iunlockput>
80105b00:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b03:	e8 67 d7 ff ff       	call   8010326f <end_op>
      return -1;
80105b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0d:	e9 c0 00 00 00       	jmp    80105bd2 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b12:	e8 7a b5 ff ff       	call   80101091 <filealloc>
80105b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b1e:	74 17                	je     80105b37 <sys_open+0x104>
80105b20:	83 ec 0c             	sub    $0xc,%esp
80105b23:	ff 75 f0             	push   -0x10(%ebp)
80105b26:	e8 07 f7 ff ff       	call   80105232 <fdalloc>
80105b2b:	83 c4 10             	add    $0x10,%esp
80105b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b31:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b35:	79 2e                	jns    80105b65 <sys_open+0x132>
    if(f)
80105b37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3b:	74 0e                	je     80105b4b <sys_open+0x118>
      fileclose(f);
80105b3d:	83 ec 0c             	sub    $0xc,%esp
80105b40:	ff 75 f0             	push   -0x10(%ebp)
80105b43:	e8 0f b6 ff ff       	call   80101157 <fileclose>
80105b48:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b4b:	83 ec 0c             	sub    $0xc,%esp
80105b4e:	ff 75 f4             	push   -0xc(%ebp)
80105b51:	e8 d1 c1 ff ff       	call   80101d27 <iunlockput>
80105b56:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b59:	e8 11 d7 ff ff       	call   8010326f <end_op>
    return -1;
80105b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b63:	eb 6d                	jmp    80105bd2 <sys_open+0x19f>
  }
  iunlock(ip);
80105b65:	83 ec 0c             	sub    $0xc,%esp
80105b68:	ff 75 f4             	push   -0xc(%ebp)
80105b6b:	e8 91 c0 ff ff       	call   80101c01 <iunlock>
80105b70:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b73:	e8 f7 d6 ff ff       	call   8010326f <end_op>

  f->type = FD_INODE;
80105b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b87:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b97:	83 e0 01             	and    $0x1,%eax
80105b9a:	85 c0                	test   %eax,%eax
80105b9c:	0f 94 c0             	sete   %al
80105b9f:	89 c2                	mov    %eax,%edx
80105ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ba7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105baa:	83 e0 01             	and    $0x1,%eax
80105bad:	85 c0                	test   %eax,%eax
80105baf:	75 0a                	jne    80105bbb <sys_open+0x188>
80105bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bb4:	83 e0 02             	and    $0x2,%eax
80105bb7:	85 c0                	test   %eax,%eax
80105bb9:	74 07                	je     80105bc2 <sys_open+0x18f>
80105bbb:	b8 01 00 00 00       	mov    $0x1,%eax
80105bc0:	eb 05                	jmp    80105bc7 <sys_open+0x194>
80105bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc7:	89 c2                	mov    %eax,%edx
80105bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcc:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bd2:	c9                   	leave
80105bd3:	c3                   	ret

80105bd4 <sys_mkdir>:

int
sys_mkdir(void)
{
80105bd4:	f3 0f 1e fb          	endbr32
80105bd8:	55                   	push   %ebp
80105bd9:	89 e5                	mov    %esp,%ebp
80105bdb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bde:	e8 fc d5 ff ff       	call   801031df <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105be3:	83 ec 08             	sub    $0x8,%esp
80105be6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be9:	50                   	push   %eax
80105bea:	6a 00                	push   $0x0
80105bec:	e8 0c f5 ff ff       	call   801050fd <argstr>
80105bf1:	83 c4 10             	add    $0x10,%esp
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	78 1b                	js     80105c13 <sys_mkdir+0x3f>
80105bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfb:	6a 00                	push   $0x0
80105bfd:	6a 00                	push   $0x0
80105bff:	6a 01                	push   $0x1
80105c01:	50                   	push   %eax
80105c02:	e8 56 fc ff ff       	call   8010585d <create>
80105c07:	83 c4 10             	add    $0x10,%esp
80105c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c11:	75 0c                	jne    80105c1f <sys_mkdir+0x4b>
    end_op();
80105c13:	e8 57 d6 ff ff       	call   8010326f <end_op>
    return -1;
80105c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1d:	eb 18                	jmp    80105c37 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105c1f:	83 ec 0c             	sub    $0xc,%esp
80105c22:	ff 75 f4             	push   -0xc(%ebp)
80105c25:	e8 fd c0 ff ff       	call   80101d27 <iunlockput>
80105c2a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c2d:	e8 3d d6 ff ff       	call   8010326f <end_op>
  return 0;
80105c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c37:	c9                   	leave
80105c38:	c3                   	ret

80105c39 <sys_mknod>:

int
sys_mknod(void)
{
80105c39:	f3 0f 1e fb          	endbr32
80105c3d:	55                   	push   %ebp
80105c3e:	89 e5                	mov    %esp,%ebp
80105c40:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c43:	e8 97 d5 ff ff       	call   801031df <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c48:	83 ec 08             	sub    $0x8,%esp
80105c4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c4e:	50                   	push   %eax
80105c4f:	6a 00                	push   $0x0
80105c51:	e8 a7 f4 ff ff       	call   801050fd <argstr>
80105c56:	83 c4 10             	add    $0x10,%esp
80105c59:	85 c0                	test   %eax,%eax
80105c5b:	78 4f                	js     80105cac <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105c5d:	83 ec 08             	sub    $0x8,%esp
80105c60:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c63:	50                   	push   %eax
80105c64:	6a 01                	push   $0x1
80105c66:	e8 04 f4 ff ff       	call   8010506f <argint>
80105c6b:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c6e:	85 c0                	test   %eax,%eax
80105c70:	78 3a                	js     80105cac <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c72:	83 ec 08             	sub    $0x8,%esp
80105c75:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c78:	50                   	push   %eax
80105c79:	6a 02                	push   $0x2
80105c7b:	e8 ef f3 ff ff       	call   8010506f <argint>
80105c80:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c83:	85 c0                	test   %eax,%eax
80105c85:	78 25                	js     80105cac <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c8a:	0f bf c8             	movswl %ax,%ecx
80105c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c90:	0f bf d0             	movswl %ax,%edx
80105c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c96:	51                   	push   %ecx
80105c97:	52                   	push   %edx
80105c98:	6a 03                	push   $0x3
80105c9a:	50                   	push   %eax
80105c9b:	e8 bd fb ff ff       	call   8010585d <create>
80105ca0:	83 c4 10             	add    $0x10,%esp
80105ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105ca6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105caa:	75 0c                	jne    80105cb8 <sys_mknod+0x7f>
    end_op();
80105cac:	e8 be d5 ff ff       	call   8010326f <end_op>
    return -1;
80105cb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb6:	eb 18                	jmp    80105cd0 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105cb8:	83 ec 0c             	sub    $0xc,%esp
80105cbb:	ff 75 f4             	push   -0xc(%ebp)
80105cbe:	e8 64 c0 ff ff       	call   80101d27 <iunlockput>
80105cc3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cc6:	e8 a4 d5 ff ff       	call   8010326f <end_op>
  return 0;
80105ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cd0:	c9                   	leave
80105cd1:	c3                   	ret

80105cd2 <sys_chdir>:

int
sys_chdir(void)
{
80105cd2:	f3 0f 1e fb          	endbr32
80105cd6:	55                   	push   %ebp
80105cd7:	89 e5                	mov    %esp,%ebp
80105cd9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cdc:	e8 36 df ff ff       	call   80103c17 <myproc>
80105ce1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105ce4:	e8 f6 d4 ff ff       	call   801031df <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105ce9:	83 ec 08             	sub    $0x8,%esp
80105cec:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cef:	50                   	push   %eax
80105cf0:	6a 00                	push   $0x0
80105cf2:	e8 06 f4 ff ff       	call   801050fd <argstr>
80105cf7:	83 c4 10             	add    $0x10,%esp
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	78 18                	js     80105d16 <sys_chdir+0x44>
80105cfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d01:	83 ec 0c             	sub    $0xc,%esp
80105d04:	50                   	push   %eax
80105d05:	e8 4b c9 ff ff       	call   80102655 <namei>
80105d0a:	83 c4 10             	add    $0x10,%esp
80105d0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d14:	75 0c                	jne    80105d22 <sys_chdir+0x50>
    end_op();
80105d16:	e8 54 d5 ff ff       	call   8010326f <end_op>
    return -1;
80105d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d20:	eb 68                	jmp    80105d8a <sys_chdir+0xb8>
  }
  ilock(ip);
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	ff 75 f0             	push   -0x10(%ebp)
80105d28:	e8 bd bd ff ff       	call   80101aea <ilock>
80105d2d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d33:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d37:	66 83 f8 01          	cmp    $0x1,%ax
80105d3b:	74 1a                	je     80105d57 <sys_chdir+0x85>
    iunlockput(ip);
80105d3d:	83 ec 0c             	sub    $0xc,%esp
80105d40:	ff 75 f0             	push   -0x10(%ebp)
80105d43:	e8 df bf ff ff       	call   80101d27 <iunlockput>
80105d48:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d4b:	e8 1f d5 ff ff       	call   8010326f <end_op>
    return -1;
80105d50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d55:	eb 33                	jmp    80105d8a <sys_chdir+0xb8>
  }
  iunlock(ip);
80105d57:	83 ec 0c             	sub    $0xc,%esp
80105d5a:	ff 75 f0             	push   -0x10(%ebp)
80105d5d:	e8 9f be ff ff       	call   80101c01 <iunlock>
80105d62:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d68:	8b 40 68             	mov    0x68(%eax),%eax
80105d6b:	83 ec 0c             	sub    $0xc,%esp
80105d6e:	50                   	push   %eax
80105d6f:	e8 df be ff ff       	call   80101c53 <iput>
80105d74:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d77:	e8 f3 d4 ff ff       	call   8010326f <end_op>
  curproc->cwd = ip;
80105d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d82:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d8a:	c9                   	leave
80105d8b:	c3                   	ret

80105d8c <sys_exec>:

int
sys_exec(void)
{
80105d8c:	f3 0f 1e fb          	endbr32
80105d90:	55                   	push   %ebp
80105d91:	89 e5                	mov    %esp,%ebp
80105d93:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d99:	83 ec 08             	sub    $0x8,%esp
80105d9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d9f:	50                   	push   %eax
80105da0:	6a 00                	push   $0x0
80105da2:	e8 56 f3 ff ff       	call   801050fd <argstr>
80105da7:	83 c4 10             	add    $0x10,%esp
80105daa:	85 c0                	test   %eax,%eax
80105dac:	78 18                	js     80105dc6 <sys_exec+0x3a>
80105dae:	83 ec 08             	sub    $0x8,%esp
80105db1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105db7:	50                   	push   %eax
80105db8:	6a 01                	push   $0x1
80105dba:	e8 b0 f2 ff ff       	call   8010506f <argint>
80105dbf:	83 c4 10             	add    $0x10,%esp
80105dc2:	85 c0                	test   %eax,%eax
80105dc4:	79 0a                	jns    80105dd0 <sys_exec+0x44>
    return -1;
80105dc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dcb:	e9 c6 00 00 00       	jmp    80105e96 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105dd0:	83 ec 04             	sub    $0x4,%esp
80105dd3:	68 80 00 00 00       	push   $0x80
80105dd8:	6a 00                	push   $0x0
80105dda:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105de0:	50                   	push   %eax
80105de1:	e8 54 ef ff ff       	call   80104d3a <memset>
80105de6:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105de9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df3:	83 f8 1f             	cmp    $0x1f,%eax
80105df6:	76 0a                	jbe    80105e02 <sys_exec+0x76>
      return -1;
80105df8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfd:	e9 94 00 00 00       	jmp    80105e96 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	c1 e0 02             	shl    $0x2,%eax
80105e08:	89 c2                	mov    %eax,%edx
80105e0a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e10:	01 c2                	add    %eax,%edx
80105e12:	83 ec 08             	sub    $0x8,%esp
80105e15:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e1b:	50                   	push   %eax
80105e1c:	52                   	push   %edx
80105e1d:	e8 c1 f1 ff ff       	call   80104fe3 <fetchint>
80105e22:	83 c4 10             	add    $0x10,%esp
80105e25:	85 c0                	test   %eax,%eax
80105e27:	79 07                	jns    80105e30 <sys_exec+0xa4>
      return -1;
80105e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2e:	eb 66                	jmp    80105e96 <sys_exec+0x10a>
    if(uarg == 0){
80105e30:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e36:	85 c0                	test   %eax,%eax
80105e38:	75 27                	jne    80105e61 <sys_exec+0xd5>
      argv[i] = 0;
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e44:	00 00 00 00 
      break;
80105e48:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4c:	83 ec 08             	sub    $0x8,%esp
80105e4f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e55:	52                   	push   %edx
80105e56:	50                   	push   %eax
80105e57:	e8 7b ad ff ff       	call   80100bd7 <exec>
80105e5c:	83 c4 10             	add    $0x10,%esp
80105e5f:	eb 35                	jmp    80105e96 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e61:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e6a:	c1 e2 02             	shl    $0x2,%edx
80105e6d:	01 c2                	add    %eax,%edx
80105e6f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e75:	83 ec 08             	sub    $0x8,%esp
80105e78:	52                   	push   %edx
80105e79:	50                   	push   %eax
80105e7a:	e8 94 f1 ff ff       	call   80105013 <fetchstr>
80105e7f:	83 c4 10             	add    $0x10,%esp
80105e82:	85 c0                	test   %eax,%eax
80105e84:	79 07                	jns    80105e8d <sys_exec+0x101>
      return -1;
80105e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8b:	eb 09                	jmp    80105e96 <sys_exec+0x10a>
  for(i=0;; i++){
80105e8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e91:	e9 5a ff ff ff       	jmp    80105df0 <sys_exec+0x64>
}
80105e96:	c9                   	leave
80105e97:	c3                   	ret

80105e98 <sys_pipe>:

int
sys_pipe(void)
{
80105e98:	f3 0f 1e fb          	endbr32
80105e9c:	55                   	push   %ebp
80105e9d:	89 e5                	mov    %esp,%ebp
80105e9f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ea2:	83 ec 04             	sub    $0x4,%esp
80105ea5:	6a 08                	push   $0x8
80105ea7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eaa:	50                   	push   %eax
80105eab:	6a 00                	push   $0x0
80105ead:	e8 ee f1 ff ff       	call   801050a0 <argptr>
80105eb2:	83 c4 10             	add    $0x10,%esp
80105eb5:	85 c0                	test   %eax,%eax
80105eb7:	79 0a                	jns    80105ec3 <sys_pipe+0x2b>
    return -1;
80105eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebe:	e9 ae 00 00 00       	jmp    80105f71 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105ec3:	83 ec 08             	sub    $0x8,%esp
80105ec6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ec9:	50                   	push   %eax
80105eca:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ecd:	50                   	push   %eax
80105ece:	e8 65 d8 ff ff       	call   80103738 <pipealloc>
80105ed3:	83 c4 10             	add    $0x10,%esp
80105ed6:	85 c0                	test   %eax,%eax
80105ed8:	79 0a                	jns    80105ee4 <sys_pipe+0x4c>
    return -1;
80105eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edf:	e9 8d 00 00 00       	jmp    80105f71 <sys_pipe+0xd9>
  fd0 = -1;
80105ee4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105eee:	83 ec 0c             	sub    $0xc,%esp
80105ef1:	50                   	push   %eax
80105ef2:	e8 3b f3 ff ff       	call   80105232 <fdalloc>
80105ef7:	83 c4 10             	add    $0x10,%esp
80105efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105efd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f01:	78 18                	js     80105f1b <sys_pipe+0x83>
80105f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f06:	83 ec 0c             	sub    $0xc,%esp
80105f09:	50                   	push   %eax
80105f0a:	e8 23 f3 ff ff       	call   80105232 <fdalloc>
80105f0f:	83 c4 10             	add    $0x10,%esp
80105f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f19:	79 3e                	jns    80105f59 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105f1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f1f:	78 13                	js     80105f34 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105f21:	e8 f1 dc ff ff       	call   80103c17 <myproc>
80105f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f29:	83 c2 08             	add    $0x8,%edx
80105f2c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f33:	00 
    fileclose(rf);
80105f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f37:	83 ec 0c             	sub    $0xc,%esp
80105f3a:	50                   	push   %eax
80105f3b:	e8 17 b2 ff ff       	call   80101157 <fileclose>
80105f40:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f46:	83 ec 0c             	sub    $0xc,%esp
80105f49:	50                   	push   %eax
80105f4a:	e8 08 b2 ff ff       	call   80101157 <fileclose>
80105f4f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f57:	eb 18                	jmp    80105f71 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f5f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f64:	8d 50 04             	lea    0x4(%eax),%edx
80105f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6a:	89 02                	mov    %eax,(%edx)
  return 0;
80105f6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f71:	c9                   	leave
80105f72:	c3                   	ret

80105f73 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f73:	f3 0f 1e fb          	endbr32
80105f77:	55                   	push   %ebp
80105f78:	89 e5                	mov    %esp,%ebp
80105f7a:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f7d:	83 ec 08             	sub    $0x8,%esp
80105f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f83:	50                   	push   %eax
80105f84:	6a 00                	push   $0x0
80105f86:	e8 e4 f0 ff ff       	call   8010506f <argint>
80105f8b:	83 c4 10             	add    $0x10,%esp
80105f8e:	85 c0                	test   %eax,%eax
80105f90:	79 07                	jns    80105f99 <sys_printpt+0x26>
        return -1;
80105f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f97:	eb 0f                	jmp    80105fa8 <sys_printpt+0x35>
  return printpt(pid);
80105f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	50                   	push   %eax
80105fa0:	e8 3d e8 ff ff       	call   801047e2 <printpt>
80105fa5:	83 c4 10             	add    $0x10,%esp
}
80105fa8:	c9                   	leave
80105fa9:	c3                   	ret

80105faa <sys_fork>:

int
sys_fork(void)
{
80105faa:	f3 0f 1e fb          	endbr32
80105fae:	55                   	push   %ebp
80105faf:	89 e5                	mov    %esp,%ebp
80105fb1:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fb4:	e8 81 df ff ff       	call   80103f3a <fork>
}
80105fb9:	c9                   	leave
80105fba:	c3                   	ret

80105fbb <sys_exit>:

int
sys_exit(void)
{
80105fbb:	f3 0f 1e fb          	endbr32
80105fbf:	55                   	push   %ebp
80105fc0:	89 e5                	mov    %esp,%ebp
80105fc2:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fc5:	e8 ed e0 ff ff       	call   801040b7 <exit>
  return 0;  // not reached
80105fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fcf:	c9                   	leave
80105fd0:	c3                   	ret

80105fd1 <sys_wait>:

int
sys_wait(void)
{
80105fd1:	f3 0f 1e fb          	endbr32
80105fd5:	55                   	push   %ebp
80105fd6:	89 e5                	mov    %esp,%ebp
80105fd8:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fdb:	e8 fb e1 ff ff       	call   801041db <wait>
}
80105fe0:	c9                   	leave
80105fe1:	c3                   	ret

80105fe2 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105fe2:	f3 0f 1e fb          	endbr32
80105fe6:	55                   	push   %ebp
80105fe7:	89 e5                	mov    %esp,%ebp
80105fe9:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105fec:	83 ec 08             	sub    $0x8,%esp
80105fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ff2:	50                   	push   %eax
80105ff3:	6a 00                	push   $0x0
80105ff5:	e8 75 f0 ff ff       	call   8010506f <argint>
80105ffa:	83 c4 10             	add    $0x10,%esp
80105ffd:	85 c0                	test   %eax,%eax
80105fff:	79 07                	jns    80106008 <sys_uthread_init+0x26>
        return -1;
80106001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106006:	eb 0f                	jmp    80106017 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80106008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600b:	83 ec 0c             	sub    $0xc,%esp
8010600e:	50                   	push   %eax
8010600f:	e8 a7 e3 ff ff       	call   801043bb <uthread_init>
80106014:	83 c4 10             	add    $0x10,%esp
}
80106017:	c9                   	leave
80106018:	c3                   	ret

80106019 <sys_kill>:

int
sys_kill(void)
{
80106019:	f3 0f 1e fb          	endbr32
8010601d:	55                   	push   %ebp
8010601e:	89 e5                	mov    %esp,%ebp
80106020:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106023:	83 ec 08             	sub    $0x8,%esp
80106026:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106029:	50                   	push   %eax
8010602a:	6a 00                	push   $0x0
8010602c:	e8 3e f0 ff ff       	call   8010506f <argint>
80106031:	83 c4 10             	add    $0x10,%esp
80106034:	85 c0                	test   %eax,%eax
80106036:	79 07                	jns    8010603f <sys_kill+0x26>
    return -1;
80106038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603d:	eb 0f                	jmp    8010604e <sys_kill+0x35>
  return kill(pid);
8010603f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106042:	83 ec 0c             	sub    $0xc,%esp
80106045:	50                   	push   %eax
80106046:	e8 01 e6 ff ff       	call   8010464c <kill>
8010604b:	83 c4 10             	add    $0x10,%esp
}
8010604e:	c9                   	leave
8010604f:	c3                   	ret

80106050 <sys_getpid>:

int
sys_getpid(void)
{
80106050:	f3 0f 1e fb          	endbr32
80106054:	55                   	push   %ebp
80106055:	89 e5                	mov    %esp,%ebp
80106057:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010605a:	e8 b8 db ff ff       	call   80103c17 <myproc>
8010605f:	8b 40 10             	mov    0x10(%eax),%eax
}
80106062:	c9                   	leave
80106063:	c3                   	ret

80106064 <sys_sbrk>:

int
sys_sbrk(void)
{
80106064:	f3 0f 1e fb          	endbr32
80106068:	55                   	push   %ebp
80106069:	89 e5                	mov    %esp,%ebp
8010606b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc* p = myproc();
8010606e:	e8 a4 db ff ff       	call   80103c17 <myproc>
80106073:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(argint(0, &n) < 0)
80106076:	83 ec 08             	sub    $0x8,%esp
80106079:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010607c:	50                   	push   %eax
8010607d:	6a 00                	push   $0x0
8010607f:	e8 eb ef ff ff       	call   8010506f <argint>
80106084:	83 c4 10             	add    $0x10,%esp
80106087:	85 c0                	test   %eax,%eax
80106089:	79 0a                	jns    80106095 <sys_sbrk+0x31>
    return -1;
8010608b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106090:	e9 4f 01 00 00       	jmp    801061e4 <sys_sbrk+0x180>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80106095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106098:	8b 00                	mov    (%eax),%eax
8010609a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (n > 0)
8010609d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060a0:	85 c0                	test   %eax,%eax
801060a2:	0f 8e b5 00 00 00    	jle    8010615d <sys_sbrk+0xf9>
  { 
    if (PGROUNDUP(p->sz + n) >= p->tf->esp){
801060a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ab:	8b 00                	mov    (%eax),%eax
801060ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
801060b0:	01 d0                	add    %edx,%eax
801060b2:	05 ff 0f 00 00       	add    $0xfff,%eax
801060b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060bc:	89 c2                	mov    %eax,%edx
801060be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c1:	8b 40 18             	mov    0x18(%eax),%eax
801060c4:	8b 40 44             	mov    0x44(%eax),%eax
801060c7:	39 c2                	cmp    %eax,%edx
801060c9:	72 1c                	jb     801060e7 <sys_sbrk+0x83>
      kill(p->pid);
801060cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ce:	8b 40 10             	mov    0x10(%eax),%eax
801060d1:	83 ec 0c             	sub    $0xc,%esp
801060d4:	50                   	push   %eax
801060d5:	e8 72 e5 ff ff       	call   8010464c <kill>
801060da:	83 c4 10             	add    $0x10,%esp
      return -1;
801060dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e2:	e9 fd 00 00 00       	jmp    801061e4 <sys_sbrk+0x180>
    }
    else{
      uint oldsz = PGROUNDUP(p->sz);
801060e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ea:	8b 00                	mov    (%eax),%eax
801060ec:	05 ff 0f 00 00       	add    $0xfff,%eax
801060f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint newsz = p->sz + n;
801060f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fc:	8b 00                	mov    (%eax),%eax
801060fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106101:	01 d0                	add    %edx,%eax
80106103:	89 45 e8             	mov    %eax,-0x18(%ebp)
      p->sz = newsz;
80106106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106109:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010610c:	89 10                	mov    %edx,(%eax)
      for(; oldsz < newsz; oldsz += PGSIZE){
8010610e:	eb 32                	jmp    80106142 <sys_sbrk+0xde>
      pte_t *pte = walkpgdir(p->pgdir, (void*)oldsz, 1);
80106110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106116:	8b 40 04             	mov    0x4(%eax),%eax
80106119:	83 ec 04             	sub    $0x4,%esp
8010611c:	6a 01                	push   $0x1
8010611e:	52                   	push   %edx
8010611f:	50                   	push   %eax
80106120:	e8 f8 16 00 00       	call   8010781d <walkpgdir>
80106125:	83 c4 10             	add    $0x10,%esp
80106128:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (pte == 0)
8010612b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010612f:	75 0a                	jne    8010613b <sys_sbrk+0xd7>
        return -1;
80106131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106136:	e9 a9 00 00 00       	jmp    801061e4 <sys_sbrk+0x180>
      for(; oldsz < newsz; oldsz += PGSIZE){
8010613b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80106142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106145:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106148:	72 c6                	jb     80106110 <sys_sbrk+0xac>
      // cprintf("pgtab %x\n",*pte);
      }
      switchuvm(p);
8010614a:	83 ec 0c             	sub    $0xc,%esp
8010614d:	ff 75 f0             	push   -0x10(%ebp)
80106150:	e8 20 19 00 00       	call   80107a75 <switchuvm>
80106155:	83 c4 10             	add    $0x10,%esp
80106158:	e9 84 00 00 00       	jmp    801061e1 <sys_sbrk+0x17d>
    }
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
8010615d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106160:	85 c0                	test   %eax,%eax
80106162:	79 7d                	jns    801061e1 <sys_sbrk+0x17d>
  {
    cprintf("[sbrk] sz %x \n",p->sz);
80106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106167:	8b 00                	mov    (%eax),%eax
80106169:	83 ec 08             	sub    $0x8,%esp
8010616c:	50                   	push   %eax
8010616d:	68 b9 ac 10 80       	push   $0x8010acb9
80106172:	e8 95 a2 ff ff       	call   8010040c <cprintf>
80106177:	83 c4 10             	add    $0x10,%esp
    if(growproc(n) < 0)
8010617a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010617d:	83 ec 0c             	sub    $0xc,%esp
80106180:	50                   	push   %eax
80106181:	e8 15 dd ff ff       	call   80103e9b <growproc>
80106186:	83 c4 10             	add    $0x10,%esp
80106189:	85 c0                	test   %eax,%eax
8010618b:	79 07                	jns    80106194 <sys_sbrk+0x130>
      return -1;
8010618d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106192:	eb 50                	jmp    801061e4 <sys_sbrk+0x180>
    cprintf("[sbrk] sz %x \n",p->sz);
80106194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106197:	8b 00                	mov    (%eax),%eax
80106199:	83 ec 08             	sub    $0x8,%esp
8010619c:	50                   	push   %eax
8010619d:	68 b9 ac 10 80       	push   $0x8010acb9
801061a2:	e8 65 a2 ff ff       	call   8010040c <cprintf>
801061a7:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] addr %x \n", addr);
801061aa:	83 ec 08             	sub    $0x8,%esp
801061ad:	ff 75 ec             	push   -0x14(%ebp)
801061b0:	68 c8 ac 10 80       	push   $0x8010acc8
801061b5:	e8 52 a2 ff ff       	call   8010040c <cprintf>
801061ba:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] esp %x eip %x \n",p->tf->esp, p->tf->eip);
801061bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c0:	8b 40 18             	mov    0x18(%eax),%eax
801061c3:	8b 50 38             	mov    0x38(%eax),%edx
801061c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c9:	8b 40 18             	mov    0x18(%eax),%eax
801061cc:	8b 40 44             	mov    0x44(%eax),%eax
801061cf:	83 ec 04             	sub    $0x4,%esp
801061d2:	52                   	push   %edx
801061d3:	50                   	push   %eax
801061d4:	68 d9 ac 10 80       	push   $0x8010acd9
801061d9:	e8 2e a2 ff ff       	call   8010040c <cprintf>
801061de:	83 c4 10             	add    $0x10,%esp
  }
  return addr;
801061e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061e4:	c9                   	leave
801061e5:	c3                   	ret

801061e6 <sys_sleep>:

int
sys_sleep(void)
{
801061e6:	f3 0f 1e fb          	endbr32
801061ea:	55                   	push   %ebp
801061eb:	89 e5                	mov    %esp,%ebp
801061ed:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801061f0:	83 ec 08             	sub    $0x8,%esp
801061f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061f6:	50                   	push   %eax
801061f7:	6a 00                	push   $0x0
801061f9:	e8 71 ee ff ff       	call   8010506f <argint>
801061fe:	83 c4 10             	add    $0x10,%esp
80106201:	85 c0                	test   %eax,%eax
80106203:	79 07                	jns    8010620c <sys_sleep+0x26>
    return -1;
80106205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620a:	eb 76                	jmp    80106282 <sys_sleep+0x9c>
  acquire(&tickslock);
8010620c:	83 ec 0c             	sub    $0xc,%esp
8010620f:	68 40 75 19 80       	push   $0x80197540
80106214:	e8 92 e8 ff ff       	call   80104aab <acquire>
80106219:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010621c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106221:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106224:	eb 38                	jmp    8010625e <sys_sleep+0x78>
    if(myproc()->killed){
80106226:	e8 ec d9 ff ff       	call   80103c17 <myproc>
8010622b:	8b 40 24             	mov    0x24(%eax),%eax
8010622e:	85 c0                	test   %eax,%eax
80106230:	74 17                	je     80106249 <sys_sleep+0x63>
      release(&tickslock);
80106232:	83 ec 0c             	sub    $0xc,%esp
80106235:	68 40 75 19 80       	push   $0x80197540
8010623a:	e8 de e8 ff ff       	call   80104b1d <release>
8010623f:	83 c4 10             	add    $0x10,%esp
      return -1;
80106242:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106247:	eb 39                	jmp    80106282 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106249:	83 ec 08             	sub    $0x8,%esp
8010624c:	68 40 75 19 80       	push   $0x80197540
80106251:	68 80 7d 19 80       	push   $0x80197d80
80106256:	e8 c7 e2 ff ff       	call   80104522 <sleep>
8010625b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010625e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106263:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106266:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106269:	39 d0                	cmp    %edx,%eax
8010626b:	72 b9                	jb     80106226 <sys_sleep+0x40>
  }
  release(&tickslock);
8010626d:	83 ec 0c             	sub    $0xc,%esp
80106270:	68 40 75 19 80       	push   $0x80197540
80106275:	e8 a3 e8 ff ff       	call   80104b1d <release>
8010627a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010627d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106282:	c9                   	leave
80106283:	c3                   	ret

80106284 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106284:	f3 0f 1e fb          	endbr32
80106288:	55                   	push   %ebp
80106289:	89 e5                	mov    %esp,%ebp
8010628b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010628e:	83 ec 0c             	sub    $0xc,%esp
80106291:	68 40 75 19 80       	push   $0x80197540
80106296:	e8 10 e8 ff ff       	call   80104aab <acquire>
8010629b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010629e:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801062a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801062a6:	83 ec 0c             	sub    $0xc,%esp
801062a9:	68 40 75 19 80       	push   $0x80197540
801062ae:	e8 6a e8 ff ff       	call   80104b1d <release>
801062b3:	83 c4 10             	add    $0x10,%esp
  return xticks;
801062b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062b9:	c9                   	leave
801062ba:	c3                   	ret

801062bb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062bb:	1e                   	push   %ds
  pushl %es
801062bc:	06                   	push   %es
  pushl %fs
801062bd:	0f a0                	push   %fs
  pushl %gs
801062bf:	0f a8                	push   %gs
  pushal
801062c1:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062c2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062c6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062c8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801062ca:	54                   	push   %esp
  call trap
801062cb:	e8 df 01 00 00       	call   801064af <trap>
  addl $4, %esp
801062d0:	83 c4 04             	add    $0x4,%esp

801062d3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801062d3:	61                   	popa
  popl %gs
801062d4:	0f a9                	pop    %gs
  popl %fs
801062d6:	0f a1                	pop    %fs
  popl %es
801062d8:	07                   	pop    %es
  popl %ds
801062d9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801062da:	83 c4 08             	add    $0x8,%esp
  iret
801062dd:	cf                   	iret

801062de <lidt>:
{
801062de:	55                   	push   %ebp
801062df:	89 e5                	mov    %esp,%ebp
801062e1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801062e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e7:	83 e8 01             	sub    $0x1,%eax
801062ea:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062ee:	8b 45 08             	mov    0x8(%ebp),%eax
801062f1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062f5:	8b 45 08             	mov    0x8(%ebp),%eax
801062f8:	c1 e8 10             	shr    $0x10,%eax
801062fb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062ff:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106302:	0f 01 18             	lidtl  (%eax)
}
80106305:	90                   	nop
80106306:	c9                   	leave
80106307:	c3                   	ret

80106308 <rcr2>:

static inline uint
rcr2(void)
{
80106308:	55                   	push   %ebp
80106309:	89 e5                	mov    %esp,%ebp
8010630b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010630e:	0f 20 d0             	mov    %cr2,%eax
80106311:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106314:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106317:	c9                   	leave
80106318:	c3                   	ret

80106319 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106319:	f3 0f 1e fb          	endbr32
8010631d:	55                   	push   %ebp
8010631e:	89 e5                	mov    %esp,%ebp
80106320:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106323:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010632a:	e9 c3 00 00 00       	jmp    801063f2 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010632f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106332:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106339:	89 c2                	mov    %eax,%edx
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106345:	80 
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
80106350:	80 08 00 
80106353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106356:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010635d:	80 
8010635e:	83 e2 e0             	and    $0xffffffe0,%edx
80106361:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636b:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106372:	80 
80106373:	83 e2 1f             	and    $0x1f,%edx
80106376:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106380:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106387:	80 
80106388:	83 e2 f0             	and    $0xfffffff0,%edx
8010638b:	83 ca 0e             	or     $0xe,%edx
8010638e:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106398:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010639f:	80 
801063a0:	83 e2 ef             	and    $0xffffffef,%edx
801063a3:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ad:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063b4:	80 
801063b5:	83 e2 9f             	and    $0xffffff9f,%edx
801063b8:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c2:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063c9:	80 
801063ca:	83 ca 80             	or     $0xffffff80,%edx
801063cd:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d7:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801063de:	c1 e8 10             	shr    $0x10,%eax
801063e1:	89 c2                	mov    %eax,%edx
801063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e6:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801063ed:	80 
  for(i = 0; i < 256; i++)
801063ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063f2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063f9:	0f 8e 30 ff ff ff    	jle    8010632f <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063ff:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106404:	66 a3 80 77 19 80    	mov    %ax,0x80197780
8010640a:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
80106411:	08 00 
80106413:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
8010641a:	83 e0 e0             	and    $0xffffffe0,%eax
8010641d:	a2 84 77 19 80       	mov    %al,0x80197784
80106422:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106429:	83 e0 1f             	and    $0x1f,%eax
8010642c:	a2 84 77 19 80       	mov    %al,0x80197784
80106431:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106438:	83 c8 0f             	or     $0xf,%eax
8010643b:	a2 85 77 19 80       	mov    %al,0x80197785
80106440:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106447:	83 e0 ef             	and    $0xffffffef,%eax
8010644a:	a2 85 77 19 80       	mov    %al,0x80197785
8010644f:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106456:	83 c8 60             	or     $0x60,%eax
80106459:	a2 85 77 19 80       	mov    %al,0x80197785
8010645e:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106465:	83 c8 80             	or     $0xffffff80,%eax
80106468:	a2 85 77 19 80       	mov    %al,0x80197785
8010646d:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106472:	c1 e8 10             	shr    $0x10,%eax
80106475:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
8010647b:	83 ec 08             	sub    $0x8,%esp
8010647e:	68 f0 ac 10 80       	push   $0x8010acf0
80106483:	68 40 75 19 80       	push   $0x80197540
80106488:	e8 f8 e5 ff ff       	call   80104a85 <initlock>
8010648d:	83 c4 10             	add    $0x10,%esp
}
80106490:	90                   	nop
80106491:	c9                   	leave
80106492:	c3                   	ret

80106493 <idtinit>:

void
idtinit(void)
{
80106493:	f3 0f 1e fb          	endbr32
80106497:	55                   	push   %ebp
80106498:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010649a:	68 00 08 00 00       	push   $0x800
8010649f:	68 80 75 19 80       	push   $0x80197580
801064a4:	e8 35 fe ff ff       	call   801062de <lidt>
801064a9:	83 c4 08             	add    $0x8,%esp
}
801064ac:	90                   	nop
801064ad:	c9                   	leave
801064ae:	c3                   	ret

801064af <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801064af:	f3 0f 1e fb          	endbr32
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	57                   	push   %edi
801064b7:	56                   	push   %esi
801064b8:	53                   	push   %ebx
801064b9:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801064bc:	8b 45 08             	mov    0x8(%ebp),%eax
801064bf:	8b 40 30             	mov    0x30(%eax),%eax
801064c2:	83 f8 40             	cmp    $0x40,%eax
801064c5:	75 3b                	jne    80106502 <trap+0x53>
    if(myproc()->killed)
801064c7:	e8 4b d7 ff ff       	call   80103c17 <myproc>
801064cc:	8b 40 24             	mov    0x24(%eax),%eax
801064cf:	85 c0                	test   %eax,%eax
801064d1:	74 05                	je     801064d8 <trap+0x29>
      exit();
801064d3:	e8 df db ff ff       	call   801040b7 <exit>
    myproc()->tf = tf;
801064d8:	e8 3a d7 ff ff       	call   80103c17 <myproc>
801064dd:	8b 55 08             	mov    0x8(%ebp),%edx
801064e0:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801064e3:	e8 50 ec ff ff       	call   80105138 <syscall>
    if(myproc()->killed)
801064e8:	e8 2a d7 ff ff       	call   80103c17 <myproc>
801064ed:	8b 40 24             	mov    0x24(%eax),%eax
801064f0:	85 c0                	test   %eax,%eax
801064f2:	0f 84 0d 03 00 00    	je     80106805 <trap+0x356>
      exit();
801064f8:	e8 ba db ff ff       	call   801040b7 <exit>
    return;
801064fd:	e9 03 03 00 00       	jmp    80106805 <trap+0x356>
  }

  switch(tf->trapno){
80106502:	8b 45 08             	mov    0x8(%ebp),%eax
80106505:	8b 40 30             	mov    0x30(%eax),%eax
80106508:	83 e8 0e             	sub    $0xe,%eax
8010650b:	83 f8 31             	cmp    $0x31,%eax
8010650e:	0f 87 bc 01 00 00    	ja     801066d0 <trap+0x221>
80106514:	8b 04 85 c4 ad 10 80 	mov    -0x7fef523c(,%eax,4),%eax
8010651b:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010651e:	e8 59 d6 ff ff       	call   80103b7c <cpuid>
80106523:	85 c0                	test   %eax,%eax
80106525:	75 3d                	jne    80106564 <trap+0xb5>
      acquire(&tickslock);
80106527:	83 ec 0c             	sub    $0xc,%esp
8010652a:	68 40 75 19 80       	push   $0x80197540
8010652f:	e8 77 e5 ff ff       	call   80104aab <acquire>
80106534:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106537:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010653c:	83 c0 01             	add    $0x1,%eax
8010653f:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106544:	83 ec 0c             	sub    $0xc,%esp
80106547:	68 80 7d 19 80       	push   $0x80197d80
8010654c:	e8 c0 e0 ff ff       	call   80104611 <wakeup>
80106551:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106554:	83 ec 0c             	sub    $0xc,%esp
80106557:	68 40 75 19 80       	push   $0x80197540
8010655c:	e8 bc e5 ff ff       	call   80104b1d <release>
80106561:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106564:	e8 2a c7 ff ff       	call   80102c93 <lapiceoi>


    break;
80106569:	e9 17 02 00 00       	jmp    80106785 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010656e:	e8 fd 40 00 00       	call   8010a670 <ideintr>
    lapiceoi();
80106573:	e8 1b c7 ff ff       	call   80102c93 <lapiceoi>
    break;
80106578:	e9 08 02 00 00       	jmp    80106785 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010657d:	e8 47 c5 ff ff       	call   80102ac9 <kbdintr>
    lapiceoi();
80106582:	e8 0c c7 ff ff       	call   80102c93 <lapiceoi>
    break;
80106587:	e9 f9 01 00 00       	jmp    80106785 <trap+0x2d6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010658c:	e8 56 04 00 00       	call   801069e7 <uartintr>
    lapiceoi();
80106591:	e8 fd c6 ff ff       	call   80102c93 <lapiceoi>
    break;
80106596:	e9 ea 01 00 00       	jmp    80106785 <trap+0x2d6>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010659b:	e8 0f 2d 00 00       	call   801092af <i8254_intr>
    lapiceoi();
801065a0:	e8 ee c6 ff ff       	call   80102c93 <lapiceoi>
    break;
801065a5:	e9 db 01 00 00       	jmp    80106785 <trap+0x2d6>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065aa:	8b 45 08             	mov    0x8(%ebp),%eax
801065ad:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065b0:	8b 45 08             	mov    0x8(%ebp),%eax
801065b3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065b7:	0f b7 d8             	movzwl %ax,%ebx
801065ba:	e8 bd d5 ff ff       	call   80103b7c <cpuid>
801065bf:	56                   	push   %esi
801065c0:	53                   	push   %ebx
801065c1:	50                   	push   %eax
801065c2:	68 f8 ac 10 80       	push   $0x8010acf8
801065c7:	e8 40 9e ff ff       	call   8010040c <cprintf>
801065cc:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065cf:	e8 bf c6 ff ff       	call   80102c93 <lapiceoi>
    break;
801065d4:	e9 ac 01 00 00       	jmp    80106785 <trap+0x2d6>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
801065d9:	e8 39 d6 ff ff       	call   80103c17 <myproc>
801065de:	8b 40 24             	mov    0x24(%eax),%eax
801065e1:	85 c0                	test   %eax,%eax
801065e3:	74 05                	je     801065ea <trap+0x13b>
      exit();
801065e5:	e8 cd da ff ff       	call   801040b7 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    uint sp;
    p = myproc();
801065ea:	e8 28 d6 ff ff       	call   80103c17 <myproc>
801065ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801065f2:	e8 11 fd ff ff       	call   80106308 <rcr2>
801065f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
801065ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106602:	8b 40 04             	mov    0x4(%eax),%eax
80106605:	89 45 dc             	mov    %eax,-0x24(%ebp)
    sp = p->tf->esp;
80106608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010660b:	8b 40 18             	mov    0x18(%eax),%eax
8010660e:	8b 40 44             	mov    0x44(%eax),%eax
80106611:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // sz+PGSIZE보다 크면 비정상적인 힙 영역 접근
    // sp-PGSIZE보다 작으면 비정상적인 스택 접근
    if (va > p->sz + PGSIZE && va < sp - PGSIZE){
80106614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106617:	8b 00                	mov    (%eax),%eax
80106619:	05 00 10 00 00       	add    $0x1000,%eax
8010661e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106621:	76 48                	jbe    8010666b <trap+0x1bc>
80106623:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106626:	2d 00 10 00 00       	sub    $0x1000,%eax
8010662b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010662e:	73 3b                	jae    8010666b <trap+0x1bc>
      cprintf("invaild access va %x sz %x sp %x eip %x\n",rcr2(),p->sz,sp, p->tf->eip);
80106630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106633:	8b 40 18             	mov    0x18(%eax),%eax
80106636:	8b 70 38             	mov    0x38(%eax),%esi
80106639:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010663c:	8b 18                	mov    (%eax),%ebx
8010663e:	e8 c5 fc ff ff       	call   80106308 <rcr2>
80106643:	83 ec 0c             	sub    $0xc,%esp
80106646:	56                   	push   %esi
80106647:	ff 75 d8             	push   -0x28(%ebp)
8010664a:	53                   	push   %ebx
8010664b:	50                   	push   %eax
8010664c:	68 1c ad 10 80       	push   $0x8010ad1c
80106651:	e8 b6 9d ff ff       	call   8010040c <cprintf>
80106656:	83 c4 20             	add    $0x20,%esp
      kill(p->pid);
80106659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010665c:	8b 40 10             	mov    0x10(%eax),%eax
8010665f:	83 ec 0c             	sub    $0xc,%esp
80106662:	50                   	push   %eax
80106663:	e8 e4 df ff ff       	call   8010464c <kill>
80106668:	83 c4 10             	add    $0x10,%esp
    }

    if (va <= p->sz + PGSIZE){
8010666b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010666e:	8b 00                	mov    (%eax),%eax
80106670:	05 00 10 00 00       	add    $0x1000,%eax
80106675:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106678:	77 1c                	ja     80106696 <trap+0x1e7>
      allocuvm(pgdir, va, va + PGSIZE);
8010667a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010667d:	05 00 10 00 00       	add    $0x1000,%eax
80106682:	83 ec 04             	sub    $0x4,%esp
80106685:	50                   	push   %eax
80106686:	ff 75 e0             	push   -0x20(%ebp)
80106689:	ff 75 dc             	push   -0x24(%ebp)
8010668c:	e8 cc 16 00 00       	call   80107d5d <allocuvm>
80106691:	83 c4 10             	add    $0x10,%esp
80106694:	eb 27                	jmp    801066bd <trap+0x20e>
    }
    else if (va >= sp - PGSIZE)
80106696:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106699:	2d 00 10 00 00       	sub    $0x1000,%eax
8010669e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
801066a1:	72 1a                	jb     801066bd <trap+0x20e>
    {
      allocuvm(pgdir, va, va + PGSIZE);
801066a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066a6:	05 00 10 00 00       	add    $0x1000,%eax
801066ab:	83 ec 04             	sub    $0x4,%esp
801066ae:	50                   	push   %eax
801066af:	ff 75 e0             	push   -0x20(%ebp)
801066b2:	ff 75 dc             	push   -0x24(%ebp)
801066b5:	e8 a3 16 00 00       	call   80107d5d <allocuvm>
801066ba:	83 c4 10             	add    $0x10,%esp
    }

    // flush
    switchuvm(p);
801066bd:	83 ec 0c             	sub    $0xc,%esp
801066c0:	ff 75 e4             	push   -0x1c(%ebp)
801066c3:	e8 ad 13 00 00       	call   80107a75 <switchuvm>
801066c8:	83 c4 10             	add    $0x10,%esp
    break;
801066cb:	e9 b5 00 00 00       	jmp    80106785 <trap+0x2d6>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801066d0:	e8 42 d5 ff ff       	call   80103c17 <myproc>
801066d5:	85 c0                	test   %eax,%eax
801066d7:	74 11                	je     801066ea <trap+0x23b>
801066d9:	8b 45 08             	mov    0x8(%ebp),%eax
801066dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066e0:	0f b7 c0             	movzwl %ax,%eax
801066e3:	83 e0 03             	and    $0x3,%eax
801066e6:	85 c0                	test   %eax,%eax
801066e8:	75 39                	jne    80106723 <trap+0x274>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801066ea:	e8 19 fc ff ff       	call   80106308 <rcr2>
801066ef:	89 c3                	mov    %eax,%ebx
801066f1:	8b 45 08             	mov    0x8(%ebp),%eax
801066f4:	8b 70 38             	mov    0x38(%eax),%esi
801066f7:	e8 80 d4 ff ff       	call   80103b7c <cpuid>
801066fc:	8b 55 08             	mov    0x8(%ebp),%edx
801066ff:	8b 52 30             	mov    0x30(%edx),%edx
80106702:	83 ec 0c             	sub    $0xc,%esp
80106705:	53                   	push   %ebx
80106706:	56                   	push   %esi
80106707:	50                   	push   %eax
80106708:	52                   	push   %edx
80106709:	68 48 ad 10 80       	push   $0x8010ad48
8010670e:	e8 f9 9c ff ff       	call   8010040c <cprintf>
80106713:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106716:	83 ec 0c             	sub    $0xc,%esp
80106719:	68 7a ad 10 80       	push   $0x8010ad7a
8010671e:	e8 bb 9e ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106723:	e8 e0 fb ff ff       	call   80106308 <rcr2>
80106728:	89 c6                	mov    %eax,%esi
8010672a:	8b 45 08             	mov    0x8(%ebp),%eax
8010672d:	8b 40 38             	mov    0x38(%eax),%eax
80106730:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106733:	e8 44 d4 ff ff       	call   80103b7c <cpuid>
80106738:	89 c3                	mov    %eax,%ebx
8010673a:	8b 45 08             	mov    0x8(%ebp),%eax
8010673d:	8b 48 34             	mov    0x34(%eax),%ecx
80106740:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106743:	8b 45 08             	mov    0x8(%ebp),%eax
80106746:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106749:	e8 c9 d4 ff ff       	call   80103c17 <myproc>
8010674e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106751:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106754:	e8 be d4 ff ff       	call   80103c17 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106759:	8b 40 10             	mov    0x10(%eax),%eax
8010675c:	56                   	push   %esi
8010675d:	ff 75 d4             	push   -0x2c(%ebp)
80106760:	53                   	push   %ebx
80106761:	ff 75 d0             	push   -0x30(%ebp)
80106764:	57                   	push   %edi
80106765:	ff 75 cc             	push   -0x34(%ebp)
80106768:	50                   	push   %eax
80106769:	68 80 ad 10 80       	push   $0x8010ad80
8010676e:	e8 99 9c ff ff       	call   8010040c <cprintf>
80106773:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106776:	e8 9c d4 ff ff       	call   80103c17 <myproc>
8010677b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106782:	eb 01                	jmp    80106785 <trap+0x2d6>
    break;
80106784:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106785:	e8 8d d4 ff ff       	call   80103c17 <myproc>
8010678a:	85 c0                	test   %eax,%eax
8010678c:	74 23                	je     801067b1 <trap+0x302>
8010678e:	e8 84 d4 ff ff       	call   80103c17 <myproc>
80106793:	8b 40 24             	mov    0x24(%eax),%eax
80106796:	85 c0                	test   %eax,%eax
80106798:	74 17                	je     801067b1 <trap+0x302>
8010679a:	8b 45 08             	mov    0x8(%ebp),%eax
8010679d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067a1:	0f b7 c0             	movzwl %ax,%eax
801067a4:	83 e0 03             	and    $0x3,%eax
801067a7:	83 f8 03             	cmp    $0x3,%eax
801067aa:	75 05                	jne    801067b1 <trap+0x302>
    exit();
801067ac:	e8 06 d9 ff ff       	call   801040b7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801067b1:	e8 61 d4 ff ff       	call   80103c17 <myproc>
801067b6:	85 c0                	test   %eax,%eax
801067b8:	74 1d                	je     801067d7 <trap+0x328>
801067ba:	e8 58 d4 ff ff       	call   80103c17 <myproc>
801067bf:	8b 40 0c             	mov    0xc(%eax),%eax
801067c2:	83 f8 04             	cmp    $0x4,%eax
801067c5:	75 10                	jne    801067d7 <trap+0x328>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801067c7:	8b 45 08             	mov    0x8(%ebp),%eax
801067ca:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801067cd:	83 f8 20             	cmp    $0x20,%eax
801067d0:	75 05                	jne    801067d7 <trap+0x328>
    yield();
801067d2:	e8 c3 dc ff ff       	call   8010449a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067d7:	e8 3b d4 ff ff       	call   80103c17 <myproc>
801067dc:	85 c0                	test   %eax,%eax
801067de:	74 26                	je     80106806 <trap+0x357>
801067e0:	e8 32 d4 ff ff       	call   80103c17 <myproc>
801067e5:	8b 40 24             	mov    0x24(%eax),%eax
801067e8:	85 c0                	test   %eax,%eax
801067ea:	74 1a                	je     80106806 <trap+0x357>
801067ec:	8b 45 08             	mov    0x8(%ebp),%eax
801067ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067f3:	0f b7 c0             	movzwl %ax,%eax
801067f6:	83 e0 03             	and    $0x3,%eax
801067f9:	83 f8 03             	cmp    $0x3,%eax
801067fc:	75 08                	jne    80106806 <trap+0x357>
    exit();
801067fe:	e8 b4 d8 ff ff       	call   801040b7 <exit>
80106803:	eb 01                	jmp    80106806 <trap+0x357>
    return;
80106805:	90                   	nop
}
80106806:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106809:	5b                   	pop    %ebx
8010680a:	5e                   	pop    %esi
8010680b:	5f                   	pop    %edi
8010680c:	5d                   	pop    %ebp
8010680d:	c3                   	ret

8010680e <inb>:
{
8010680e:	55                   	push   %ebp
8010680f:	89 e5                	mov    %esp,%ebp
80106811:	83 ec 14             	sub    $0x14,%esp
80106814:	8b 45 08             	mov    0x8(%ebp),%eax
80106817:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010681b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010681f:	89 c2                	mov    %eax,%edx
80106821:	ec                   	in     (%dx),%al
80106822:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106825:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106829:	c9                   	leave
8010682a:	c3                   	ret

8010682b <outb>:
{
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
8010682e:	83 ec 08             	sub    $0x8,%esp
80106831:	8b 45 08             	mov    0x8(%ebp),%eax
80106834:	8b 55 0c             	mov    0xc(%ebp),%edx
80106837:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010683b:	89 d0                	mov    %edx,%eax
8010683d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106840:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106844:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106848:	ee                   	out    %al,(%dx)
}
80106849:	90                   	nop
8010684a:	c9                   	leave
8010684b:	c3                   	ret

8010684c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010684c:	f3 0f 1e fb          	endbr32
80106850:	55                   	push   %ebp
80106851:	89 e5                	mov    %esp,%ebp
80106853:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106856:	6a 00                	push   $0x0
80106858:	68 fa 03 00 00       	push   $0x3fa
8010685d:	e8 c9 ff ff ff       	call   8010682b <outb>
80106862:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106865:	68 80 00 00 00       	push   $0x80
8010686a:	68 fb 03 00 00       	push   $0x3fb
8010686f:	e8 b7 ff ff ff       	call   8010682b <outb>
80106874:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106877:	6a 0c                	push   $0xc
80106879:	68 f8 03 00 00       	push   $0x3f8
8010687e:	e8 a8 ff ff ff       	call   8010682b <outb>
80106883:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106886:	6a 00                	push   $0x0
80106888:	68 f9 03 00 00       	push   $0x3f9
8010688d:	e8 99 ff ff ff       	call   8010682b <outb>
80106892:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106895:	6a 03                	push   $0x3
80106897:	68 fb 03 00 00       	push   $0x3fb
8010689c:	e8 8a ff ff ff       	call   8010682b <outb>
801068a1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801068a4:	6a 00                	push   $0x0
801068a6:	68 fc 03 00 00       	push   $0x3fc
801068ab:	e8 7b ff ff ff       	call   8010682b <outb>
801068b0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801068b3:	6a 01                	push   $0x1
801068b5:	68 f9 03 00 00       	push   $0x3f9
801068ba:	e8 6c ff ff ff       	call   8010682b <outb>
801068bf:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801068c2:	68 fd 03 00 00       	push   $0x3fd
801068c7:	e8 42 ff ff ff       	call   8010680e <inb>
801068cc:	83 c4 04             	add    $0x4,%esp
801068cf:	3c ff                	cmp    $0xff,%al
801068d1:	74 61                	je     80106934 <uartinit+0xe8>
    return;
  uart = 1;
801068d3:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801068da:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801068dd:	68 fa 03 00 00       	push   $0x3fa
801068e2:	e8 27 ff ff ff       	call   8010680e <inb>
801068e7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801068ea:	68 f8 03 00 00       	push   $0x3f8
801068ef:	e8 1a ff ff ff       	call   8010680e <inb>
801068f4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801068f7:	83 ec 08             	sub    $0x8,%esp
801068fa:	6a 00                	push   $0x0
801068fc:	6a 04                	push   $0x4
801068fe:	e8 77 be ff ff       	call   8010277a <ioapicenable>
80106903:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106906:	c7 45 f4 8c ae 10 80 	movl   $0x8010ae8c,-0xc(%ebp)
8010690d:	eb 19                	jmp    80106928 <uartinit+0xdc>
    uartputc(*p);
8010690f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106912:	0f b6 00             	movzbl (%eax),%eax
80106915:	0f be c0             	movsbl %al,%eax
80106918:	83 ec 0c             	sub    $0xc,%esp
8010691b:	50                   	push   %eax
8010691c:	e8 16 00 00 00       	call   80106937 <uartputc>
80106921:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106924:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010692b:	0f b6 00             	movzbl (%eax),%eax
8010692e:	84 c0                	test   %al,%al
80106930:	75 dd                	jne    8010690f <uartinit+0xc3>
80106932:	eb 01                	jmp    80106935 <uartinit+0xe9>
    return;
80106934:	90                   	nop
}
80106935:	c9                   	leave
80106936:	c3                   	ret

80106937 <uartputc>:

void
uartputc(int c)
{
80106937:	f3 0f 1e fb          	endbr32
8010693b:	55                   	push   %ebp
8010693c:	89 e5                	mov    %esp,%ebp
8010693e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106941:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106946:	85 c0                	test   %eax,%eax
80106948:	74 53                	je     8010699d <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010694a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106951:	eb 11                	jmp    80106964 <uartputc+0x2d>
    microdelay(10);
80106953:	83 ec 0c             	sub    $0xc,%esp
80106956:	6a 0a                	push   $0xa
80106958:	e8 55 c3 ff ff       	call   80102cb2 <microdelay>
8010695d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106960:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106964:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106968:	7f 1a                	jg     80106984 <uartputc+0x4d>
8010696a:	83 ec 0c             	sub    $0xc,%esp
8010696d:	68 fd 03 00 00       	push   $0x3fd
80106972:	e8 97 fe ff ff       	call   8010680e <inb>
80106977:	83 c4 10             	add    $0x10,%esp
8010697a:	0f b6 c0             	movzbl %al,%eax
8010697d:	83 e0 20             	and    $0x20,%eax
80106980:	85 c0                	test   %eax,%eax
80106982:	74 cf                	je     80106953 <uartputc+0x1c>
  outb(COM1+0, c);
80106984:	8b 45 08             	mov    0x8(%ebp),%eax
80106987:	0f b6 c0             	movzbl %al,%eax
8010698a:	83 ec 08             	sub    $0x8,%esp
8010698d:	50                   	push   %eax
8010698e:	68 f8 03 00 00       	push   $0x3f8
80106993:	e8 93 fe ff ff       	call   8010682b <outb>
80106998:	83 c4 10             	add    $0x10,%esp
8010699b:	eb 01                	jmp    8010699e <uartputc+0x67>
    return;
8010699d:	90                   	nop
}
8010699e:	c9                   	leave
8010699f:	c3                   	ret

801069a0 <uartgetc>:

static int
uartgetc(void)
{
801069a0:	f3 0f 1e fb          	endbr32
801069a4:	55                   	push   %ebp
801069a5:	89 e5                	mov    %esp,%ebp
  if(!uart)
801069a7:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801069ac:	85 c0                	test   %eax,%eax
801069ae:	75 07                	jne    801069b7 <uartgetc+0x17>
    return -1;
801069b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b5:	eb 2e                	jmp    801069e5 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801069b7:	68 fd 03 00 00       	push   $0x3fd
801069bc:	e8 4d fe ff ff       	call   8010680e <inb>
801069c1:	83 c4 04             	add    $0x4,%esp
801069c4:	0f b6 c0             	movzbl %al,%eax
801069c7:	83 e0 01             	and    $0x1,%eax
801069ca:	85 c0                	test   %eax,%eax
801069cc:	75 07                	jne    801069d5 <uartgetc+0x35>
    return -1;
801069ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d3:	eb 10                	jmp    801069e5 <uartgetc+0x45>
  return inb(COM1+0);
801069d5:	68 f8 03 00 00       	push   $0x3f8
801069da:	e8 2f fe ff ff       	call   8010680e <inb>
801069df:	83 c4 04             	add    $0x4,%esp
801069e2:	0f b6 c0             	movzbl %al,%eax
}
801069e5:	c9                   	leave
801069e6:	c3                   	ret

801069e7 <uartintr>:

void
uartintr(void)
{
801069e7:	f3 0f 1e fb          	endbr32
801069eb:	55                   	push   %ebp
801069ec:	89 e5                	mov    %esp,%ebp
801069ee:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801069f1:	83 ec 0c             	sub    $0xc,%esp
801069f4:	68 a0 69 10 80       	push   $0x801069a0
801069f9:	e8 1b 9e ff ff       	call   80100819 <consoleintr>
801069fe:	83 c4 10             	add    $0x10,%esp
}
80106a01:	90                   	nop
80106a02:	c9                   	leave
80106a03:	c3                   	ret

80106a04 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $0
80106a06:	6a 00                	push   $0x0
  jmp alltraps
80106a08:	e9 ae f8 ff ff       	jmp    801062bb <alltraps>

80106a0d <vector1>:
.globl vector1
vector1:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $1
80106a0f:	6a 01                	push   $0x1
  jmp alltraps
80106a11:	e9 a5 f8 ff ff       	jmp    801062bb <alltraps>

80106a16 <vector2>:
.globl vector2
vector2:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $2
80106a18:	6a 02                	push   $0x2
  jmp alltraps
80106a1a:	e9 9c f8 ff ff       	jmp    801062bb <alltraps>

80106a1f <vector3>:
.globl vector3
vector3:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $3
80106a21:	6a 03                	push   $0x3
  jmp alltraps
80106a23:	e9 93 f8 ff ff       	jmp    801062bb <alltraps>

80106a28 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $4
80106a2a:	6a 04                	push   $0x4
  jmp alltraps
80106a2c:	e9 8a f8 ff ff       	jmp    801062bb <alltraps>

80106a31 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $5
80106a33:	6a 05                	push   $0x5
  jmp alltraps
80106a35:	e9 81 f8 ff ff       	jmp    801062bb <alltraps>

80106a3a <vector6>:
.globl vector6
vector6:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $6
80106a3c:	6a 06                	push   $0x6
  jmp alltraps
80106a3e:	e9 78 f8 ff ff       	jmp    801062bb <alltraps>

80106a43 <vector7>:
.globl vector7
vector7:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $7
80106a45:	6a 07                	push   $0x7
  jmp alltraps
80106a47:	e9 6f f8 ff ff       	jmp    801062bb <alltraps>

80106a4c <vector8>:
.globl vector8
vector8:
  pushl $8
80106a4c:	6a 08                	push   $0x8
  jmp alltraps
80106a4e:	e9 68 f8 ff ff       	jmp    801062bb <alltraps>

80106a53 <vector9>:
.globl vector9
vector9:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $9
80106a55:	6a 09                	push   $0x9
  jmp alltraps
80106a57:	e9 5f f8 ff ff       	jmp    801062bb <alltraps>

80106a5c <vector10>:
.globl vector10
vector10:
  pushl $10
80106a5c:	6a 0a                	push   $0xa
  jmp alltraps
80106a5e:	e9 58 f8 ff ff       	jmp    801062bb <alltraps>

80106a63 <vector11>:
.globl vector11
vector11:
  pushl $11
80106a63:	6a 0b                	push   $0xb
  jmp alltraps
80106a65:	e9 51 f8 ff ff       	jmp    801062bb <alltraps>

80106a6a <vector12>:
.globl vector12
vector12:
  pushl $12
80106a6a:	6a 0c                	push   $0xc
  jmp alltraps
80106a6c:	e9 4a f8 ff ff       	jmp    801062bb <alltraps>

80106a71 <vector13>:
.globl vector13
vector13:
  pushl $13
80106a71:	6a 0d                	push   $0xd
  jmp alltraps
80106a73:	e9 43 f8 ff ff       	jmp    801062bb <alltraps>

80106a78 <vector14>:
.globl vector14
vector14:
  pushl $14
80106a78:	6a 0e                	push   $0xe
  jmp alltraps
80106a7a:	e9 3c f8 ff ff       	jmp    801062bb <alltraps>

80106a7f <vector15>:
.globl vector15
vector15:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $15
80106a81:	6a 0f                	push   $0xf
  jmp alltraps
80106a83:	e9 33 f8 ff ff       	jmp    801062bb <alltraps>

80106a88 <vector16>:
.globl vector16
vector16:
  pushl $0
80106a88:	6a 00                	push   $0x0
  pushl $16
80106a8a:	6a 10                	push   $0x10
  jmp alltraps
80106a8c:	e9 2a f8 ff ff       	jmp    801062bb <alltraps>

80106a91 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a91:	6a 11                	push   $0x11
  jmp alltraps
80106a93:	e9 23 f8 ff ff       	jmp    801062bb <alltraps>

80106a98 <vector18>:
.globl vector18
vector18:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $18
80106a9a:	6a 12                	push   $0x12
  jmp alltraps
80106a9c:	e9 1a f8 ff ff       	jmp    801062bb <alltraps>

80106aa1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $19
80106aa3:	6a 13                	push   $0x13
  jmp alltraps
80106aa5:	e9 11 f8 ff ff       	jmp    801062bb <alltraps>

80106aaa <vector20>:
.globl vector20
vector20:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $20
80106aac:	6a 14                	push   $0x14
  jmp alltraps
80106aae:	e9 08 f8 ff ff       	jmp    801062bb <alltraps>

80106ab3 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $21
80106ab5:	6a 15                	push   $0x15
  jmp alltraps
80106ab7:	e9 ff f7 ff ff       	jmp    801062bb <alltraps>

80106abc <vector22>:
.globl vector22
vector22:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $22
80106abe:	6a 16                	push   $0x16
  jmp alltraps
80106ac0:	e9 f6 f7 ff ff       	jmp    801062bb <alltraps>

80106ac5 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $23
80106ac7:	6a 17                	push   $0x17
  jmp alltraps
80106ac9:	e9 ed f7 ff ff       	jmp    801062bb <alltraps>

80106ace <vector24>:
.globl vector24
vector24:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $24
80106ad0:	6a 18                	push   $0x18
  jmp alltraps
80106ad2:	e9 e4 f7 ff ff       	jmp    801062bb <alltraps>

80106ad7 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $25
80106ad9:	6a 19                	push   $0x19
  jmp alltraps
80106adb:	e9 db f7 ff ff       	jmp    801062bb <alltraps>

80106ae0 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $26
80106ae2:	6a 1a                	push   $0x1a
  jmp alltraps
80106ae4:	e9 d2 f7 ff ff       	jmp    801062bb <alltraps>

80106ae9 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $27
80106aeb:	6a 1b                	push   $0x1b
  jmp alltraps
80106aed:	e9 c9 f7 ff ff       	jmp    801062bb <alltraps>

80106af2 <vector28>:
.globl vector28
vector28:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $28
80106af4:	6a 1c                	push   $0x1c
  jmp alltraps
80106af6:	e9 c0 f7 ff ff       	jmp    801062bb <alltraps>

80106afb <vector29>:
.globl vector29
vector29:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $29
80106afd:	6a 1d                	push   $0x1d
  jmp alltraps
80106aff:	e9 b7 f7 ff ff       	jmp    801062bb <alltraps>

80106b04 <vector30>:
.globl vector30
vector30:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $30
80106b06:	6a 1e                	push   $0x1e
  jmp alltraps
80106b08:	e9 ae f7 ff ff       	jmp    801062bb <alltraps>

80106b0d <vector31>:
.globl vector31
vector31:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $31
80106b0f:	6a 1f                	push   $0x1f
  jmp alltraps
80106b11:	e9 a5 f7 ff ff       	jmp    801062bb <alltraps>

80106b16 <vector32>:
.globl vector32
vector32:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $32
80106b18:	6a 20                	push   $0x20
  jmp alltraps
80106b1a:	e9 9c f7 ff ff       	jmp    801062bb <alltraps>

80106b1f <vector33>:
.globl vector33
vector33:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $33
80106b21:	6a 21                	push   $0x21
  jmp alltraps
80106b23:	e9 93 f7 ff ff       	jmp    801062bb <alltraps>

80106b28 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $34
80106b2a:	6a 22                	push   $0x22
  jmp alltraps
80106b2c:	e9 8a f7 ff ff       	jmp    801062bb <alltraps>

80106b31 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $35
80106b33:	6a 23                	push   $0x23
  jmp alltraps
80106b35:	e9 81 f7 ff ff       	jmp    801062bb <alltraps>

80106b3a <vector36>:
.globl vector36
vector36:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $36
80106b3c:	6a 24                	push   $0x24
  jmp alltraps
80106b3e:	e9 78 f7 ff ff       	jmp    801062bb <alltraps>

80106b43 <vector37>:
.globl vector37
vector37:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $37
80106b45:	6a 25                	push   $0x25
  jmp alltraps
80106b47:	e9 6f f7 ff ff       	jmp    801062bb <alltraps>

80106b4c <vector38>:
.globl vector38
vector38:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $38
80106b4e:	6a 26                	push   $0x26
  jmp alltraps
80106b50:	e9 66 f7 ff ff       	jmp    801062bb <alltraps>

80106b55 <vector39>:
.globl vector39
vector39:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $39
80106b57:	6a 27                	push   $0x27
  jmp alltraps
80106b59:	e9 5d f7 ff ff       	jmp    801062bb <alltraps>

80106b5e <vector40>:
.globl vector40
vector40:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $40
80106b60:	6a 28                	push   $0x28
  jmp alltraps
80106b62:	e9 54 f7 ff ff       	jmp    801062bb <alltraps>

80106b67 <vector41>:
.globl vector41
vector41:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $41
80106b69:	6a 29                	push   $0x29
  jmp alltraps
80106b6b:	e9 4b f7 ff ff       	jmp    801062bb <alltraps>

80106b70 <vector42>:
.globl vector42
vector42:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $42
80106b72:	6a 2a                	push   $0x2a
  jmp alltraps
80106b74:	e9 42 f7 ff ff       	jmp    801062bb <alltraps>

80106b79 <vector43>:
.globl vector43
vector43:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $43
80106b7b:	6a 2b                	push   $0x2b
  jmp alltraps
80106b7d:	e9 39 f7 ff ff       	jmp    801062bb <alltraps>

80106b82 <vector44>:
.globl vector44
vector44:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $44
80106b84:	6a 2c                	push   $0x2c
  jmp alltraps
80106b86:	e9 30 f7 ff ff       	jmp    801062bb <alltraps>

80106b8b <vector45>:
.globl vector45
vector45:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $45
80106b8d:	6a 2d                	push   $0x2d
  jmp alltraps
80106b8f:	e9 27 f7 ff ff       	jmp    801062bb <alltraps>

80106b94 <vector46>:
.globl vector46
vector46:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $46
80106b96:	6a 2e                	push   $0x2e
  jmp alltraps
80106b98:	e9 1e f7 ff ff       	jmp    801062bb <alltraps>

80106b9d <vector47>:
.globl vector47
vector47:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $47
80106b9f:	6a 2f                	push   $0x2f
  jmp alltraps
80106ba1:	e9 15 f7 ff ff       	jmp    801062bb <alltraps>

80106ba6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $48
80106ba8:	6a 30                	push   $0x30
  jmp alltraps
80106baa:	e9 0c f7 ff ff       	jmp    801062bb <alltraps>

80106baf <vector49>:
.globl vector49
vector49:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $49
80106bb1:	6a 31                	push   $0x31
  jmp alltraps
80106bb3:	e9 03 f7 ff ff       	jmp    801062bb <alltraps>

80106bb8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $50
80106bba:	6a 32                	push   $0x32
  jmp alltraps
80106bbc:	e9 fa f6 ff ff       	jmp    801062bb <alltraps>

80106bc1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $51
80106bc3:	6a 33                	push   $0x33
  jmp alltraps
80106bc5:	e9 f1 f6 ff ff       	jmp    801062bb <alltraps>

80106bca <vector52>:
.globl vector52
vector52:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $52
80106bcc:	6a 34                	push   $0x34
  jmp alltraps
80106bce:	e9 e8 f6 ff ff       	jmp    801062bb <alltraps>

80106bd3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $53
80106bd5:	6a 35                	push   $0x35
  jmp alltraps
80106bd7:	e9 df f6 ff ff       	jmp    801062bb <alltraps>

80106bdc <vector54>:
.globl vector54
vector54:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $54
80106bde:	6a 36                	push   $0x36
  jmp alltraps
80106be0:	e9 d6 f6 ff ff       	jmp    801062bb <alltraps>

80106be5 <vector55>:
.globl vector55
vector55:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $55
80106be7:	6a 37                	push   $0x37
  jmp alltraps
80106be9:	e9 cd f6 ff ff       	jmp    801062bb <alltraps>

80106bee <vector56>:
.globl vector56
vector56:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $56
80106bf0:	6a 38                	push   $0x38
  jmp alltraps
80106bf2:	e9 c4 f6 ff ff       	jmp    801062bb <alltraps>

80106bf7 <vector57>:
.globl vector57
vector57:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $57
80106bf9:	6a 39                	push   $0x39
  jmp alltraps
80106bfb:	e9 bb f6 ff ff       	jmp    801062bb <alltraps>

80106c00 <vector58>:
.globl vector58
vector58:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $58
80106c02:	6a 3a                	push   $0x3a
  jmp alltraps
80106c04:	e9 b2 f6 ff ff       	jmp    801062bb <alltraps>

80106c09 <vector59>:
.globl vector59
vector59:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $59
80106c0b:	6a 3b                	push   $0x3b
  jmp alltraps
80106c0d:	e9 a9 f6 ff ff       	jmp    801062bb <alltraps>

80106c12 <vector60>:
.globl vector60
vector60:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $60
80106c14:	6a 3c                	push   $0x3c
  jmp alltraps
80106c16:	e9 a0 f6 ff ff       	jmp    801062bb <alltraps>

80106c1b <vector61>:
.globl vector61
vector61:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $61
80106c1d:	6a 3d                	push   $0x3d
  jmp alltraps
80106c1f:	e9 97 f6 ff ff       	jmp    801062bb <alltraps>

80106c24 <vector62>:
.globl vector62
vector62:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $62
80106c26:	6a 3e                	push   $0x3e
  jmp alltraps
80106c28:	e9 8e f6 ff ff       	jmp    801062bb <alltraps>

80106c2d <vector63>:
.globl vector63
vector63:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $63
80106c2f:	6a 3f                	push   $0x3f
  jmp alltraps
80106c31:	e9 85 f6 ff ff       	jmp    801062bb <alltraps>

80106c36 <vector64>:
.globl vector64
vector64:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $64
80106c38:	6a 40                	push   $0x40
  jmp alltraps
80106c3a:	e9 7c f6 ff ff       	jmp    801062bb <alltraps>

80106c3f <vector65>:
.globl vector65
vector65:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $65
80106c41:	6a 41                	push   $0x41
  jmp alltraps
80106c43:	e9 73 f6 ff ff       	jmp    801062bb <alltraps>

80106c48 <vector66>:
.globl vector66
vector66:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $66
80106c4a:	6a 42                	push   $0x42
  jmp alltraps
80106c4c:	e9 6a f6 ff ff       	jmp    801062bb <alltraps>

80106c51 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $67
80106c53:	6a 43                	push   $0x43
  jmp alltraps
80106c55:	e9 61 f6 ff ff       	jmp    801062bb <alltraps>

80106c5a <vector68>:
.globl vector68
vector68:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $68
80106c5c:	6a 44                	push   $0x44
  jmp alltraps
80106c5e:	e9 58 f6 ff ff       	jmp    801062bb <alltraps>

80106c63 <vector69>:
.globl vector69
vector69:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $69
80106c65:	6a 45                	push   $0x45
  jmp alltraps
80106c67:	e9 4f f6 ff ff       	jmp    801062bb <alltraps>

80106c6c <vector70>:
.globl vector70
vector70:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $70
80106c6e:	6a 46                	push   $0x46
  jmp alltraps
80106c70:	e9 46 f6 ff ff       	jmp    801062bb <alltraps>

80106c75 <vector71>:
.globl vector71
vector71:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $71
80106c77:	6a 47                	push   $0x47
  jmp alltraps
80106c79:	e9 3d f6 ff ff       	jmp    801062bb <alltraps>

80106c7e <vector72>:
.globl vector72
vector72:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $72
80106c80:	6a 48                	push   $0x48
  jmp alltraps
80106c82:	e9 34 f6 ff ff       	jmp    801062bb <alltraps>

80106c87 <vector73>:
.globl vector73
vector73:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $73
80106c89:	6a 49                	push   $0x49
  jmp alltraps
80106c8b:	e9 2b f6 ff ff       	jmp    801062bb <alltraps>

80106c90 <vector74>:
.globl vector74
vector74:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $74
80106c92:	6a 4a                	push   $0x4a
  jmp alltraps
80106c94:	e9 22 f6 ff ff       	jmp    801062bb <alltraps>

80106c99 <vector75>:
.globl vector75
vector75:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $75
80106c9b:	6a 4b                	push   $0x4b
  jmp alltraps
80106c9d:	e9 19 f6 ff ff       	jmp    801062bb <alltraps>

80106ca2 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $76
80106ca4:	6a 4c                	push   $0x4c
  jmp alltraps
80106ca6:	e9 10 f6 ff ff       	jmp    801062bb <alltraps>

80106cab <vector77>:
.globl vector77
vector77:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $77
80106cad:	6a 4d                	push   $0x4d
  jmp alltraps
80106caf:	e9 07 f6 ff ff       	jmp    801062bb <alltraps>

80106cb4 <vector78>:
.globl vector78
vector78:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $78
80106cb6:	6a 4e                	push   $0x4e
  jmp alltraps
80106cb8:	e9 fe f5 ff ff       	jmp    801062bb <alltraps>

80106cbd <vector79>:
.globl vector79
vector79:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $79
80106cbf:	6a 4f                	push   $0x4f
  jmp alltraps
80106cc1:	e9 f5 f5 ff ff       	jmp    801062bb <alltraps>

80106cc6 <vector80>:
.globl vector80
vector80:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $80
80106cc8:	6a 50                	push   $0x50
  jmp alltraps
80106cca:	e9 ec f5 ff ff       	jmp    801062bb <alltraps>

80106ccf <vector81>:
.globl vector81
vector81:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $81
80106cd1:	6a 51                	push   $0x51
  jmp alltraps
80106cd3:	e9 e3 f5 ff ff       	jmp    801062bb <alltraps>

80106cd8 <vector82>:
.globl vector82
vector82:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $82
80106cda:	6a 52                	push   $0x52
  jmp alltraps
80106cdc:	e9 da f5 ff ff       	jmp    801062bb <alltraps>

80106ce1 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $83
80106ce3:	6a 53                	push   $0x53
  jmp alltraps
80106ce5:	e9 d1 f5 ff ff       	jmp    801062bb <alltraps>

80106cea <vector84>:
.globl vector84
vector84:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $84
80106cec:	6a 54                	push   $0x54
  jmp alltraps
80106cee:	e9 c8 f5 ff ff       	jmp    801062bb <alltraps>

80106cf3 <vector85>:
.globl vector85
vector85:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $85
80106cf5:	6a 55                	push   $0x55
  jmp alltraps
80106cf7:	e9 bf f5 ff ff       	jmp    801062bb <alltraps>

80106cfc <vector86>:
.globl vector86
vector86:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $86
80106cfe:	6a 56                	push   $0x56
  jmp alltraps
80106d00:	e9 b6 f5 ff ff       	jmp    801062bb <alltraps>

80106d05 <vector87>:
.globl vector87
vector87:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $87
80106d07:	6a 57                	push   $0x57
  jmp alltraps
80106d09:	e9 ad f5 ff ff       	jmp    801062bb <alltraps>

80106d0e <vector88>:
.globl vector88
vector88:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $88
80106d10:	6a 58                	push   $0x58
  jmp alltraps
80106d12:	e9 a4 f5 ff ff       	jmp    801062bb <alltraps>

80106d17 <vector89>:
.globl vector89
vector89:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $89
80106d19:	6a 59                	push   $0x59
  jmp alltraps
80106d1b:	e9 9b f5 ff ff       	jmp    801062bb <alltraps>

80106d20 <vector90>:
.globl vector90
vector90:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $90
80106d22:	6a 5a                	push   $0x5a
  jmp alltraps
80106d24:	e9 92 f5 ff ff       	jmp    801062bb <alltraps>

80106d29 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $91
80106d2b:	6a 5b                	push   $0x5b
  jmp alltraps
80106d2d:	e9 89 f5 ff ff       	jmp    801062bb <alltraps>

80106d32 <vector92>:
.globl vector92
vector92:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $92
80106d34:	6a 5c                	push   $0x5c
  jmp alltraps
80106d36:	e9 80 f5 ff ff       	jmp    801062bb <alltraps>

80106d3b <vector93>:
.globl vector93
vector93:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $93
80106d3d:	6a 5d                	push   $0x5d
  jmp alltraps
80106d3f:	e9 77 f5 ff ff       	jmp    801062bb <alltraps>

80106d44 <vector94>:
.globl vector94
vector94:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $94
80106d46:	6a 5e                	push   $0x5e
  jmp alltraps
80106d48:	e9 6e f5 ff ff       	jmp    801062bb <alltraps>

80106d4d <vector95>:
.globl vector95
vector95:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $95
80106d4f:	6a 5f                	push   $0x5f
  jmp alltraps
80106d51:	e9 65 f5 ff ff       	jmp    801062bb <alltraps>

80106d56 <vector96>:
.globl vector96
vector96:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $96
80106d58:	6a 60                	push   $0x60
  jmp alltraps
80106d5a:	e9 5c f5 ff ff       	jmp    801062bb <alltraps>

80106d5f <vector97>:
.globl vector97
vector97:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $97
80106d61:	6a 61                	push   $0x61
  jmp alltraps
80106d63:	e9 53 f5 ff ff       	jmp    801062bb <alltraps>

80106d68 <vector98>:
.globl vector98
vector98:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $98
80106d6a:	6a 62                	push   $0x62
  jmp alltraps
80106d6c:	e9 4a f5 ff ff       	jmp    801062bb <alltraps>

80106d71 <vector99>:
.globl vector99
vector99:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $99
80106d73:	6a 63                	push   $0x63
  jmp alltraps
80106d75:	e9 41 f5 ff ff       	jmp    801062bb <alltraps>

80106d7a <vector100>:
.globl vector100
vector100:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $100
80106d7c:	6a 64                	push   $0x64
  jmp alltraps
80106d7e:	e9 38 f5 ff ff       	jmp    801062bb <alltraps>

80106d83 <vector101>:
.globl vector101
vector101:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $101
80106d85:	6a 65                	push   $0x65
  jmp alltraps
80106d87:	e9 2f f5 ff ff       	jmp    801062bb <alltraps>

80106d8c <vector102>:
.globl vector102
vector102:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $102
80106d8e:	6a 66                	push   $0x66
  jmp alltraps
80106d90:	e9 26 f5 ff ff       	jmp    801062bb <alltraps>

80106d95 <vector103>:
.globl vector103
vector103:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $103
80106d97:	6a 67                	push   $0x67
  jmp alltraps
80106d99:	e9 1d f5 ff ff       	jmp    801062bb <alltraps>

80106d9e <vector104>:
.globl vector104
vector104:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $104
80106da0:	6a 68                	push   $0x68
  jmp alltraps
80106da2:	e9 14 f5 ff ff       	jmp    801062bb <alltraps>

80106da7 <vector105>:
.globl vector105
vector105:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $105
80106da9:	6a 69                	push   $0x69
  jmp alltraps
80106dab:	e9 0b f5 ff ff       	jmp    801062bb <alltraps>

80106db0 <vector106>:
.globl vector106
vector106:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $106
80106db2:	6a 6a                	push   $0x6a
  jmp alltraps
80106db4:	e9 02 f5 ff ff       	jmp    801062bb <alltraps>

80106db9 <vector107>:
.globl vector107
vector107:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $107
80106dbb:	6a 6b                	push   $0x6b
  jmp alltraps
80106dbd:	e9 f9 f4 ff ff       	jmp    801062bb <alltraps>

80106dc2 <vector108>:
.globl vector108
vector108:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $108
80106dc4:	6a 6c                	push   $0x6c
  jmp alltraps
80106dc6:	e9 f0 f4 ff ff       	jmp    801062bb <alltraps>

80106dcb <vector109>:
.globl vector109
vector109:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $109
80106dcd:	6a 6d                	push   $0x6d
  jmp alltraps
80106dcf:	e9 e7 f4 ff ff       	jmp    801062bb <alltraps>

80106dd4 <vector110>:
.globl vector110
vector110:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $110
80106dd6:	6a 6e                	push   $0x6e
  jmp alltraps
80106dd8:	e9 de f4 ff ff       	jmp    801062bb <alltraps>

80106ddd <vector111>:
.globl vector111
vector111:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $111
80106ddf:	6a 6f                	push   $0x6f
  jmp alltraps
80106de1:	e9 d5 f4 ff ff       	jmp    801062bb <alltraps>

80106de6 <vector112>:
.globl vector112
vector112:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $112
80106de8:	6a 70                	push   $0x70
  jmp alltraps
80106dea:	e9 cc f4 ff ff       	jmp    801062bb <alltraps>

80106def <vector113>:
.globl vector113
vector113:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $113
80106df1:	6a 71                	push   $0x71
  jmp alltraps
80106df3:	e9 c3 f4 ff ff       	jmp    801062bb <alltraps>

80106df8 <vector114>:
.globl vector114
vector114:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $114
80106dfa:	6a 72                	push   $0x72
  jmp alltraps
80106dfc:	e9 ba f4 ff ff       	jmp    801062bb <alltraps>

80106e01 <vector115>:
.globl vector115
vector115:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $115
80106e03:	6a 73                	push   $0x73
  jmp alltraps
80106e05:	e9 b1 f4 ff ff       	jmp    801062bb <alltraps>

80106e0a <vector116>:
.globl vector116
vector116:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $116
80106e0c:	6a 74                	push   $0x74
  jmp alltraps
80106e0e:	e9 a8 f4 ff ff       	jmp    801062bb <alltraps>

80106e13 <vector117>:
.globl vector117
vector117:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $117
80106e15:	6a 75                	push   $0x75
  jmp alltraps
80106e17:	e9 9f f4 ff ff       	jmp    801062bb <alltraps>

80106e1c <vector118>:
.globl vector118
vector118:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $118
80106e1e:	6a 76                	push   $0x76
  jmp alltraps
80106e20:	e9 96 f4 ff ff       	jmp    801062bb <alltraps>

80106e25 <vector119>:
.globl vector119
vector119:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $119
80106e27:	6a 77                	push   $0x77
  jmp alltraps
80106e29:	e9 8d f4 ff ff       	jmp    801062bb <alltraps>

80106e2e <vector120>:
.globl vector120
vector120:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $120
80106e30:	6a 78                	push   $0x78
  jmp alltraps
80106e32:	e9 84 f4 ff ff       	jmp    801062bb <alltraps>

80106e37 <vector121>:
.globl vector121
vector121:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $121
80106e39:	6a 79                	push   $0x79
  jmp alltraps
80106e3b:	e9 7b f4 ff ff       	jmp    801062bb <alltraps>

80106e40 <vector122>:
.globl vector122
vector122:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $122
80106e42:	6a 7a                	push   $0x7a
  jmp alltraps
80106e44:	e9 72 f4 ff ff       	jmp    801062bb <alltraps>

80106e49 <vector123>:
.globl vector123
vector123:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $123
80106e4b:	6a 7b                	push   $0x7b
  jmp alltraps
80106e4d:	e9 69 f4 ff ff       	jmp    801062bb <alltraps>

80106e52 <vector124>:
.globl vector124
vector124:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $124
80106e54:	6a 7c                	push   $0x7c
  jmp alltraps
80106e56:	e9 60 f4 ff ff       	jmp    801062bb <alltraps>

80106e5b <vector125>:
.globl vector125
vector125:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $125
80106e5d:	6a 7d                	push   $0x7d
  jmp alltraps
80106e5f:	e9 57 f4 ff ff       	jmp    801062bb <alltraps>

80106e64 <vector126>:
.globl vector126
vector126:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $126
80106e66:	6a 7e                	push   $0x7e
  jmp alltraps
80106e68:	e9 4e f4 ff ff       	jmp    801062bb <alltraps>

80106e6d <vector127>:
.globl vector127
vector127:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $127
80106e6f:	6a 7f                	push   $0x7f
  jmp alltraps
80106e71:	e9 45 f4 ff ff       	jmp    801062bb <alltraps>

80106e76 <vector128>:
.globl vector128
vector128:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $128
80106e78:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106e7d:	e9 39 f4 ff ff       	jmp    801062bb <alltraps>

80106e82 <vector129>:
.globl vector129
vector129:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $129
80106e84:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e89:	e9 2d f4 ff ff       	jmp    801062bb <alltraps>

80106e8e <vector130>:
.globl vector130
vector130:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $130
80106e90:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e95:	e9 21 f4 ff ff       	jmp    801062bb <alltraps>

80106e9a <vector131>:
.globl vector131
vector131:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $131
80106e9c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ea1:	e9 15 f4 ff ff       	jmp    801062bb <alltraps>

80106ea6 <vector132>:
.globl vector132
vector132:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $132
80106ea8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106ead:	e9 09 f4 ff ff       	jmp    801062bb <alltraps>

80106eb2 <vector133>:
.globl vector133
vector133:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $133
80106eb4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106eb9:	e9 fd f3 ff ff       	jmp    801062bb <alltraps>

80106ebe <vector134>:
.globl vector134
vector134:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $134
80106ec0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106ec5:	e9 f1 f3 ff ff       	jmp    801062bb <alltraps>

80106eca <vector135>:
.globl vector135
vector135:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $135
80106ecc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ed1:	e9 e5 f3 ff ff       	jmp    801062bb <alltraps>

80106ed6 <vector136>:
.globl vector136
vector136:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $136
80106ed8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106edd:	e9 d9 f3 ff ff       	jmp    801062bb <alltraps>

80106ee2 <vector137>:
.globl vector137
vector137:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $137
80106ee4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106ee9:	e9 cd f3 ff ff       	jmp    801062bb <alltraps>

80106eee <vector138>:
.globl vector138
vector138:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $138
80106ef0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ef5:	e9 c1 f3 ff ff       	jmp    801062bb <alltraps>

80106efa <vector139>:
.globl vector139
vector139:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $139
80106efc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f01:	e9 b5 f3 ff ff       	jmp    801062bb <alltraps>

80106f06 <vector140>:
.globl vector140
vector140:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $140
80106f08:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f0d:	e9 a9 f3 ff ff       	jmp    801062bb <alltraps>

80106f12 <vector141>:
.globl vector141
vector141:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $141
80106f14:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f19:	e9 9d f3 ff ff       	jmp    801062bb <alltraps>

80106f1e <vector142>:
.globl vector142
vector142:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $142
80106f20:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f25:	e9 91 f3 ff ff       	jmp    801062bb <alltraps>

80106f2a <vector143>:
.globl vector143
vector143:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $143
80106f2c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f31:	e9 85 f3 ff ff       	jmp    801062bb <alltraps>

80106f36 <vector144>:
.globl vector144
vector144:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $144
80106f38:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f3d:	e9 79 f3 ff ff       	jmp    801062bb <alltraps>

80106f42 <vector145>:
.globl vector145
vector145:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $145
80106f44:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f49:	e9 6d f3 ff ff       	jmp    801062bb <alltraps>

80106f4e <vector146>:
.globl vector146
vector146:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $146
80106f50:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f55:	e9 61 f3 ff ff       	jmp    801062bb <alltraps>

80106f5a <vector147>:
.globl vector147
vector147:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $147
80106f5c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106f61:	e9 55 f3 ff ff       	jmp    801062bb <alltraps>

80106f66 <vector148>:
.globl vector148
vector148:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $148
80106f68:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106f6d:	e9 49 f3 ff ff       	jmp    801062bb <alltraps>

80106f72 <vector149>:
.globl vector149
vector149:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $149
80106f74:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106f79:	e9 3d f3 ff ff       	jmp    801062bb <alltraps>

80106f7e <vector150>:
.globl vector150
vector150:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $150
80106f80:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106f85:	e9 31 f3 ff ff       	jmp    801062bb <alltraps>

80106f8a <vector151>:
.globl vector151
vector151:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $151
80106f8c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f91:	e9 25 f3 ff ff       	jmp    801062bb <alltraps>

80106f96 <vector152>:
.globl vector152
vector152:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $152
80106f98:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f9d:	e9 19 f3 ff ff       	jmp    801062bb <alltraps>

80106fa2 <vector153>:
.globl vector153
vector153:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $153
80106fa4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106fa9:	e9 0d f3 ff ff       	jmp    801062bb <alltraps>

80106fae <vector154>:
.globl vector154
vector154:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $154
80106fb0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106fb5:	e9 01 f3 ff ff       	jmp    801062bb <alltraps>

80106fba <vector155>:
.globl vector155
vector155:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $155
80106fbc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106fc1:	e9 f5 f2 ff ff       	jmp    801062bb <alltraps>

80106fc6 <vector156>:
.globl vector156
vector156:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $156
80106fc8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106fcd:	e9 e9 f2 ff ff       	jmp    801062bb <alltraps>

80106fd2 <vector157>:
.globl vector157
vector157:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $157
80106fd4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106fd9:	e9 dd f2 ff ff       	jmp    801062bb <alltraps>

80106fde <vector158>:
.globl vector158
vector158:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $158
80106fe0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106fe5:	e9 d1 f2 ff ff       	jmp    801062bb <alltraps>

80106fea <vector159>:
.globl vector159
vector159:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $159
80106fec:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ff1:	e9 c5 f2 ff ff       	jmp    801062bb <alltraps>

80106ff6 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $160
80106ff8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ffd:	e9 b9 f2 ff ff       	jmp    801062bb <alltraps>

80107002 <vector161>:
.globl vector161
vector161:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $161
80107004:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107009:	e9 ad f2 ff ff       	jmp    801062bb <alltraps>

8010700e <vector162>:
.globl vector162
vector162:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $162
80107010:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107015:	e9 a1 f2 ff ff       	jmp    801062bb <alltraps>

8010701a <vector163>:
.globl vector163
vector163:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $163
8010701c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107021:	e9 95 f2 ff ff       	jmp    801062bb <alltraps>

80107026 <vector164>:
.globl vector164
vector164:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $164
80107028:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010702d:	e9 89 f2 ff ff       	jmp    801062bb <alltraps>

80107032 <vector165>:
.globl vector165
vector165:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $165
80107034:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107039:	e9 7d f2 ff ff       	jmp    801062bb <alltraps>

8010703e <vector166>:
.globl vector166
vector166:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $166
80107040:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107045:	e9 71 f2 ff ff       	jmp    801062bb <alltraps>

8010704a <vector167>:
.globl vector167
vector167:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $167
8010704c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107051:	e9 65 f2 ff ff       	jmp    801062bb <alltraps>

80107056 <vector168>:
.globl vector168
vector168:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $168
80107058:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010705d:	e9 59 f2 ff ff       	jmp    801062bb <alltraps>

80107062 <vector169>:
.globl vector169
vector169:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $169
80107064:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107069:	e9 4d f2 ff ff       	jmp    801062bb <alltraps>

8010706e <vector170>:
.globl vector170
vector170:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $170
80107070:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107075:	e9 41 f2 ff ff       	jmp    801062bb <alltraps>

8010707a <vector171>:
.globl vector171
vector171:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $171
8010707c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107081:	e9 35 f2 ff ff       	jmp    801062bb <alltraps>

80107086 <vector172>:
.globl vector172
vector172:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $172
80107088:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010708d:	e9 29 f2 ff ff       	jmp    801062bb <alltraps>

80107092 <vector173>:
.globl vector173
vector173:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $173
80107094:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107099:	e9 1d f2 ff ff       	jmp    801062bb <alltraps>

8010709e <vector174>:
.globl vector174
vector174:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $174
801070a0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801070a5:	e9 11 f2 ff ff       	jmp    801062bb <alltraps>

801070aa <vector175>:
.globl vector175
vector175:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $175
801070ac:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801070b1:	e9 05 f2 ff ff       	jmp    801062bb <alltraps>

801070b6 <vector176>:
.globl vector176
vector176:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $176
801070b8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801070bd:	e9 f9 f1 ff ff       	jmp    801062bb <alltraps>

801070c2 <vector177>:
.globl vector177
vector177:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $177
801070c4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801070c9:	e9 ed f1 ff ff       	jmp    801062bb <alltraps>

801070ce <vector178>:
.globl vector178
vector178:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $178
801070d0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801070d5:	e9 e1 f1 ff ff       	jmp    801062bb <alltraps>

801070da <vector179>:
.globl vector179
vector179:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $179
801070dc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801070e1:	e9 d5 f1 ff ff       	jmp    801062bb <alltraps>

801070e6 <vector180>:
.globl vector180
vector180:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $180
801070e8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801070ed:	e9 c9 f1 ff ff       	jmp    801062bb <alltraps>

801070f2 <vector181>:
.globl vector181
vector181:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $181
801070f4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801070f9:	e9 bd f1 ff ff       	jmp    801062bb <alltraps>

801070fe <vector182>:
.globl vector182
vector182:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $182
80107100:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107105:	e9 b1 f1 ff ff       	jmp    801062bb <alltraps>

8010710a <vector183>:
.globl vector183
vector183:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $183
8010710c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107111:	e9 a5 f1 ff ff       	jmp    801062bb <alltraps>

80107116 <vector184>:
.globl vector184
vector184:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $184
80107118:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010711d:	e9 99 f1 ff ff       	jmp    801062bb <alltraps>

80107122 <vector185>:
.globl vector185
vector185:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $185
80107124:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107129:	e9 8d f1 ff ff       	jmp    801062bb <alltraps>

8010712e <vector186>:
.globl vector186
vector186:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $186
80107130:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107135:	e9 81 f1 ff ff       	jmp    801062bb <alltraps>

8010713a <vector187>:
.globl vector187
vector187:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $187
8010713c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107141:	e9 75 f1 ff ff       	jmp    801062bb <alltraps>

80107146 <vector188>:
.globl vector188
vector188:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $188
80107148:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010714d:	e9 69 f1 ff ff       	jmp    801062bb <alltraps>

80107152 <vector189>:
.globl vector189
vector189:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $189
80107154:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107159:	e9 5d f1 ff ff       	jmp    801062bb <alltraps>

8010715e <vector190>:
.globl vector190
vector190:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $190
80107160:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107165:	e9 51 f1 ff ff       	jmp    801062bb <alltraps>

8010716a <vector191>:
.globl vector191
vector191:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $191
8010716c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107171:	e9 45 f1 ff ff       	jmp    801062bb <alltraps>

80107176 <vector192>:
.globl vector192
vector192:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $192
80107178:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010717d:	e9 39 f1 ff ff       	jmp    801062bb <alltraps>

80107182 <vector193>:
.globl vector193
vector193:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $193
80107184:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107189:	e9 2d f1 ff ff       	jmp    801062bb <alltraps>

8010718e <vector194>:
.globl vector194
vector194:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $194
80107190:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107195:	e9 21 f1 ff ff       	jmp    801062bb <alltraps>

8010719a <vector195>:
.globl vector195
vector195:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $195
8010719c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801071a1:	e9 15 f1 ff ff       	jmp    801062bb <alltraps>

801071a6 <vector196>:
.globl vector196
vector196:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $196
801071a8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801071ad:	e9 09 f1 ff ff       	jmp    801062bb <alltraps>

801071b2 <vector197>:
.globl vector197
vector197:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $197
801071b4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801071b9:	e9 fd f0 ff ff       	jmp    801062bb <alltraps>

801071be <vector198>:
.globl vector198
vector198:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $198
801071c0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801071c5:	e9 f1 f0 ff ff       	jmp    801062bb <alltraps>

801071ca <vector199>:
.globl vector199
vector199:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $199
801071cc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801071d1:	e9 e5 f0 ff ff       	jmp    801062bb <alltraps>

801071d6 <vector200>:
.globl vector200
vector200:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $200
801071d8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801071dd:	e9 d9 f0 ff ff       	jmp    801062bb <alltraps>

801071e2 <vector201>:
.globl vector201
vector201:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $201
801071e4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801071e9:	e9 cd f0 ff ff       	jmp    801062bb <alltraps>

801071ee <vector202>:
.globl vector202
vector202:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $202
801071f0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801071f5:	e9 c1 f0 ff ff       	jmp    801062bb <alltraps>

801071fa <vector203>:
.globl vector203
vector203:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $203
801071fc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107201:	e9 b5 f0 ff ff       	jmp    801062bb <alltraps>

80107206 <vector204>:
.globl vector204
vector204:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $204
80107208:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010720d:	e9 a9 f0 ff ff       	jmp    801062bb <alltraps>

80107212 <vector205>:
.globl vector205
vector205:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $205
80107214:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107219:	e9 9d f0 ff ff       	jmp    801062bb <alltraps>

8010721e <vector206>:
.globl vector206
vector206:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $206
80107220:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107225:	e9 91 f0 ff ff       	jmp    801062bb <alltraps>

8010722a <vector207>:
.globl vector207
vector207:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $207
8010722c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107231:	e9 85 f0 ff ff       	jmp    801062bb <alltraps>

80107236 <vector208>:
.globl vector208
vector208:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $208
80107238:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010723d:	e9 79 f0 ff ff       	jmp    801062bb <alltraps>

80107242 <vector209>:
.globl vector209
vector209:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $209
80107244:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107249:	e9 6d f0 ff ff       	jmp    801062bb <alltraps>

8010724e <vector210>:
.globl vector210
vector210:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $210
80107250:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107255:	e9 61 f0 ff ff       	jmp    801062bb <alltraps>

8010725a <vector211>:
.globl vector211
vector211:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $211
8010725c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107261:	e9 55 f0 ff ff       	jmp    801062bb <alltraps>

80107266 <vector212>:
.globl vector212
vector212:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $212
80107268:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010726d:	e9 49 f0 ff ff       	jmp    801062bb <alltraps>

80107272 <vector213>:
.globl vector213
vector213:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $213
80107274:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107279:	e9 3d f0 ff ff       	jmp    801062bb <alltraps>

8010727e <vector214>:
.globl vector214
vector214:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $214
80107280:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107285:	e9 31 f0 ff ff       	jmp    801062bb <alltraps>

8010728a <vector215>:
.globl vector215
vector215:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $215
8010728c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107291:	e9 25 f0 ff ff       	jmp    801062bb <alltraps>

80107296 <vector216>:
.globl vector216
vector216:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $216
80107298:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010729d:	e9 19 f0 ff ff       	jmp    801062bb <alltraps>

801072a2 <vector217>:
.globl vector217
vector217:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $217
801072a4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801072a9:	e9 0d f0 ff ff       	jmp    801062bb <alltraps>

801072ae <vector218>:
.globl vector218
vector218:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $218
801072b0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801072b5:	e9 01 f0 ff ff       	jmp    801062bb <alltraps>

801072ba <vector219>:
.globl vector219
vector219:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $219
801072bc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801072c1:	e9 f5 ef ff ff       	jmp    801062bb <alltraps>

801072c6 <vector220>:
.globl vector220
vector220:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $220
801072c8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801072cd:	e9 e9 ef ff ff       	jmp    801062bb <alltraps>

801072d2 <vector221>:
.globl vector221
vector221:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $221
801072d4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801072d9:	e9 dd ef ff ff       	jmp    801062bb <alltraps>

801072de <vector222>:
.globl vector222
vector222:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $222
801072e0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801072e5:	e9 d1 ef ff ff       	jmp    801062bb <alltraps>

801072ea <vector223>:
.globl vector223
vector223:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $223
801072ec:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801072f1:	e9 c5 ef ff ff       	jmp    801062bb <alltraps>

801072f6 <vector224>:
.globl vector224
vector224:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $224
801072f8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801072fd:	e9 b9 ef ff ff       	jmp    801062bb <alltraps>

80107302 <vector225>:
.globl vector225
vector225:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $225
80107304:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107309:	e9 ad ef ff ff       	jmp    801062bb <alltraps>

8010730e <vector226>:
.globl vector226
vector226:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $226
80107310:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107315:	e9 a1 ef ff ff       	jmp    801062bb <alltraps>

8010731a <vector227>:
.globl vector227
vector227:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $227
8010731c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107321:	e9 95 ef ff ff       	jmp    801062bb <alltraps>

80107326 <vector228>:
.globl vector228
vector228:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $228
80107328:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010732d:	e9 89 ef ff ff       	jmp    801062bb <alltraps>

80107332 <vector229>:
.globl vector229
vector229:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $229
80107334:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107339:	e9 7d ef ff ff       	jmp    801062bb <alltraps>

8010733e <vector230>:
.globl vector230
vector230:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $230
80107340:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107345:	e9 71 ef ff ff       	jmp    801062bb <alltraps>

8010734a <vector231>:
.globl vector231
vector231:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $231
8010734c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107351:	e9 65 ef ff ff       	jmp    801062bb <alltraps>

80107356 <vector232>:
.globl vector232
vector232:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $232
80107358:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010735d:	e9 59 ef ff ff       	jmp    801062bb <alltraps>

80107362 <vector233>:
.globl vector233
vector233:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $233
80107364:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107369:	e9 4d ef ff ff       	jmp    801062bb <alltraps>

8010736e <vector234>:
.globl vector234
vector234:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $234
80107370:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107375:	e9 41 ef ff ff       	jmp    801062bb <alltraps>

8010737a <vector235>:
.globl vector235
vector235:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $235
8010737c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107381:	e9 35 ef ff ff       	jmp    801062bb <alltraps>

80107386 <vector236>:
.globl vector236
vector236:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $236
80107388:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010738d:	e9 29 ef ff ff       	jmp    801062bb <alltraps>

80107392 <vector237>:
.globl vector237
vector237:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $237
80107394:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107399:	e9 1d ef ff ff       	jmp    801062bb <alltraps>

8010739e <vector238>:
.globl vector238
vector238:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $238
801073a0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801073a5:	e9 11 ef ff ff       	jmp    801062bb <alltraps>

801073aa <vector239>:
.globl vector239
vector239:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $239
801073ac:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801073b1:	e9 05 ef ff ff       	jmp    801062bb <alltraps>

801073b6 <vector240>:
.globl vector240
vector240:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $240
801073b8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801073bd:	e9 f9 ee ff ff       	jmp    801062bb <alltraps>

801073c2 <vector241>:
.globl vector241
vector241:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $241
801073c4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801073c9:	e9 ed ee ff ff       	jmp    801062bb <alltraps>

801073ce <vector242>:
.globl vector242
vector242:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $242
801073d0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801073d5:	e9 e1 ee ff ff       	jmp    801062bb <alltraps>

801073da <vector243>:
.globl vector243
vector243:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $243
801073dc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801073e1:	e9 d5 ee ff ff       	jmp    801062bb <alltraps>

801073e6 <vector244>:
.globl vector244
vector244:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $244
801073e8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801073ed:	e9 c9 ee ff ff       	jmp    801062bb <alltraps>

801073f2 <vector245>:
.globl vector245
vector245:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $245
801073f4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801073f9:	e9 bd ee ff ff       	jmp    801062bb <alltraps>

801073fe <vector246>:
.globl vector246
vector246:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $246
80107400:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107405:	e9 b1 ee ff ff       	jmp    801062bb <alltraps>

8010740a <vector247>:
.globl vector247
vector247:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $247
8010740c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107411:	e9 a5 ee ff ff       	jmp    801062bb <alltraps>

80107416 <vector248>:
.globl vector248
vector248:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $248
80107418:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010741d:	e9 99 ee ff ff       	jmp    801062bb <alltraps>

80107422 <vector249>:
.globl vector249
vector249:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $249
80107424:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107429:	e9 8d ee ff ff       	jmp    801062bb <alltraps>

8010742e <vector250>:
.globl vector250
vector250:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $250
80107430:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107435:	e9 81 ee ff ff       	jmp    801062bb <alltraps>

8010743a <vector251>:
.globl vector251
vector251:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $251
8010743c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107441:	e9 75 ee ff ff       	jmp    801062bb <alltraps>

80107446 <vector252>:
.globl vector252
vector252:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $252
80107448:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010744d:	e9 69 ee ff ff       	jmp    801062bb <alltraps>

80107452 <vector253>:
.globl vector253
vector253:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $253
80107454:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107459:	e9 5d ee ff ff       	jmp    801062bb <alltraps>

8010745e <vector254>:
.globl vector254
vector254:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $254
80107460:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107465:	e9 51 ee ff ff       	jmp    801062bb <alltraps>

8010746a <vector255>:
.globl vector255
vector255:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $255
8010746c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107471:	e9 45 ee ff ff       	jmp    801062bb <alltraps>

80107476 <lgdt>:
{
80107476:	55                   	push   %ebp
80107477:	89 e5                	mov    %esp,%ebp
80107479:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010747c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010747f:	83 e8 01             	sub    $0x1,%eax
80107482:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107486:	8b 45 08             	mov    0x8(%ebp),%eax
80107489:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010748d:	8b 45 08             	mov    0x8(%ebp),%eax
80107490:	c1 e8 10             	shr    $0x10,%eax
80107493:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107497:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010749a:	0f 01 10             	lgdtl  (%eax)
}
8010749d:	90                   	nop
8010749e:	c9                   	leave
8010749f:	c3                   	ret

801074a0 <ltr>:
{
801074a0:	55                   	push   %ebp
801074a1:	89 e5                	mov    %esp,%ebp
801074a3:	83 ec 04             	sub    $0x4,%esp
801074a6:	8b 45 08             	mov    0x8(%ebp),%eax
801074a9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801074ad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801074b1:	0f 00 d8             	ltr    %eax
}
801074b4:	90                   	nop
801074b5:	c9                   	leave
801074b6:	c3                   	ret

801074b7 <lcr3>:

static inline void
lcr3(uint val)
{
801074b7:	55                   	push   %ebp
801074b8:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074ba:	8b 45 08             	mov    0x8(%ebp),%eax
801074bd:	0f 22 d8             	mov    %eax,%cr3
}
801074c0:	90                   	nop
801074c1:	5d                   	pop    %ebp
801074c2:	c3                   	ret

801074c3 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801074c3:	f3 0f 1e fb          	endbr32
801074c7:	55                   	push   %ebp
801074c8:	89 e5                	mov    %esp,%ebp
801074ca:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801074cd:	e8 aa c6 ff ff       	call   80103b7c <cpuid>
801074d2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801074d8:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801074dd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801074e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801074f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107500:	83 e2 f0             	and    $0xfffffff0,%edx
80107503:	83 ca 0a             	or     $0xa,%edx
80107506:	88 50 7d             	mov    %dl,0x7d(%eax)
80107509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107510:	83 ca 10             	or     $0x10,%edx
80107513:	88 50 7d             	mov    %dl,0x7d(%eax)
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010751d:	83 e2 9f             	and    $0xffffff9f,%edx
80107520:	88 50 7d             	mov    %dl,0x7d(%eax)
80107523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107526:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010752a:	83 ca 80             	or     $0xffffff80,%edx
8010752d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107533:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107537:	83 ca 0f             	or     $0xf,%edx
8010753a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107540:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107544:	83 e2 ef             	and    $0xffffffef,%edx
80107547:	88 50 7e             	mov    %dl,0x7e(%eax)
8010754a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107551:	83 e2 df             	and    $0xffffffdf,%edx
80107554:	88 50 7e             	mov    %dl,0x7e(%eax)
80107557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010755e:	83 ca 40             	or     $0x40,%edx
80107561:	88 50 7e             	mov    %dl,0x7e(%eax)
80107564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107567:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010756b:	83 ca 80             	or     $0xffffff80,%edx
8010756e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107574:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107582:	ff ff 
80107584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107587:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010758e:	00 00 
80107590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107593:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010759a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075a4:	83 e2 f0             	and    $0xfffffff0,%edx
801075a7:	83 ca 02             	or     $0x2,%edx
801075aa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075ba:	83 ca 10             	or     $0x10,%edx
801075bd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075cd:	83 e2 9f             	and    $0xffffff9f,%edx
801075d0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075e0:	83 ca 80             	or     $0xffffff80,%edx
801075e3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ec:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075f3:	83 ca 0f             	or     $0xf,%edx
801075f6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107606:	83 e2 ef             	and    $0xffffffef,%edx
80107609:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010760f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107612:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107619:	83 e2 df             	and    $0xffffffdf,%edx
8010761c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107625:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010762c:	83 ca 40             	or     $0x40,%edx
8010762f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107638:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010763f:	83 ca 80             	or     $0xffffff80,%edx
80107642:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107655:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010765c:	ff ff 
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107668:	00 00 
8010766a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107677:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010767e:	83 e2 f0             	and    $0xfffffff0,%edx
80107681:	83 ca 0a             	or     $0xa,%edx
80107684:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010768a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107694:	83 ca 10             	or     $0x10,%edx
80107697:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076a7:	83 ca 60             	or     $0x60,%edx
801076aa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076ba:	83 ca 80             	or     $0xffffff80,%edx
801076bd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076cd:	83 ca 0f             	or     $0xf,%edx
801076d0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076e0:	83 e2 ef             	and    $0xffffffef,%edx
801076e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076f3:	83 e2 df             	and    $0xffffffdf,%edx
801076f6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107706:	83 ca 40             	or     $0x40,%edx
80107709:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107712:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107719:	83 ca 80             	or     $0xffffff80,%edx
8010771c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107725:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010772c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107736:	ff ff 
80107738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107742:	00 00 
80107744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107747:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010774e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107751:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107758:	83 e2 f0             	and    $0xfffffff0,%edx
8010775b:	83 ca 02             	or     $0x2,%edx
8010775e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107767:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010776e:	83 ca 10             	or     $0x10,%edx
80107771:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107781:	83 ca 60             	or     $0x60,%edx
80107784:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107794:	83 ca 80             	or     $0xffffff80,%edx
80107797:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077a7:	83 ca 0f             	or     $0xf,%edx
801077aa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077ba:	83 e2 ef             	and    $0xffffffef,%edx
801077bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077cd:	83 e2 df             	and    $0xffffffdf,%edx
801077d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077e0:	83 ca 40             	or     $0x40,%edx
801077e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077f3:	83 ca 80             	or     $0xffffff80,%edx
801077f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ff:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107809:	83 c0 70             	add    $0x70,%eax
8010780c:	83 ec 08             	sub    $0x8,%esp
8010780f:	6a 30                	push   $0x30
80107811:	50                   	push   %eax
80107812:	e8 5f fc ff ff       	call   80107476 <lgdt>
80107817:	83 c4 10             	add    $0x10,%esp
}
8010781a:	90                   	nop
8010781b:	c9                   	leave
8010781c:	c3                   	ret

8010781d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010781d:	f3 0f 1e fb          	endbr32
80107821:	55                   	push   %ebp
80107822:	89 e5                	mov    %esp,%ebp
80107824:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010782a:	c1 e8 16             	shr    $0x16,%eax
8010782d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107834:	8b 45 08             	mov    0x8(%ebp),%eax
80107837:	01 d0                	add    %edx,%eax
80107839:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010783c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010783f:	8b 00                	mov    (%eax),%eax
80107841:	83 e0 01             	and    $0x1,%eax
80107844:	85 c0                	test   %eax,%eax
80107846:	74 14                	je     8010785c <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010784b:	8b 00                	mov    (%eax),%eax
8010784d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107852:	05 00 00 00 80       	add    $0x80000000,%eax
80107857:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010785a:	eb 42                	jmp    8010789e <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010785c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107860:	74 0e                	je     80107870 <walkpgdir+0x53>
80107862:	e8 99 b0 ff ff       	call   80102900 <kalloc>
80107867:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010786a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010786e:	75 07                	jne    80107877 <walkpgdir+0x5a>
      return 0;
80107870:	b8 00 00 00 00       	mov    $0x0,%eax
80107875:	eb 3e                	jmp    801078b5 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107877:	83 ec 04             	sub    $0x4,%esp
8010787a:	68 00 10 00 00       	push   $0x1000
8010787f:	6a 00                	push   $0x0
80107881:	ff 75 f4             	push   -0xc(%ebp)
80107884:	e8 b1 d4 ff ff       	call   80104d3a <memset>
80107889:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	05 00 00 00 80       	add    $0x80000000,%eax
80107894:	83 c8 07             	or     $0x7,%eax
80107897:	89 c2                	mov    %eax,%edx
80107899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010789c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010789e:	8b 45 0c             	mov    0xc(%ebp),%eax
801078a1:	c1 e8 0c             	shr    $0xc,%eax
801078a4:	25 ff 03 00 00       	and    $0x3ff,%eax
801078a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	01 d0                	add    %edx,%eax
}
801078b5:	c9                   	leave
801078b6:	c3                   	ret

801078b7 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078b7:	f3 0f 1e fb          	endbr32
801078bb:	55                   	push   %ebp
801078bc:	89 e5                	mov    %esp,%ebp
801078be:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801078c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801078cf:	8b 45 10             	mov    0x10(%ebp),%eax
801078d2:	01 d0                	add    %edx,%eax
801078d4:	83 e8 01             	sub    $0x1,%eax
801078d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078df:	83 ec 04             	sub    $0x4,%esp
801078e2:	6a 01                	push   $0x1
801078e4:	ff 75 f4             	push   -0xc(%ebp)
801078e7:	ff 75 08             	push   0x8(%ebp)
801078ea:	e8 2e ff ff ff       	call   8010781d <walkpgdir>
801078ef:	83 c4 10             	add    $0x10,%esp
801078f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078f9:	75 07                	jne    80107902 <mappages+0x4b>
      return -1;
801078fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107900:	eb 47                	jmp    80107949 <mappages+0x92>
    if(*pte & PTE_P)
80107902:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107905:	8b 00                	mov    (%eax),%eax
80107907:	83 e0 01             	and    $0x1,%eax
8010790a:	85 c0                	test   %eax,%eax
8010790c:	74 0d                	je     8010791b <mappages+0x64>
      panic("remap");
8010790e:	83 ec 0c             	sub    $0xc,%esp
80107911:	68 94 ae 10 80       	push   $0x8010ae94
80107916:	e8 c3 8c ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
8010791b:	8b 45 18             	mov    0x18(%ebp),%eax
8010791e:	0b 45 14             	or     0x14(%ebp),%eax
80107921:	83 c8 01             	or     $0x1,%eax
80107924:	89 c2                	mov    %eax,%edx
80107926:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107929:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010792b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107931:	74 10                	je     80107943 <mappages+0x8c>
      break;
    a += PGSIZE;
80107933:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010793a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107941:	eb 9c                	jmp    801078df <mappages+0x28>
      break;
80107943:	90                   	nop
  }
  return 0;
80107944:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107949:	c9                   	leave
8010794a:	c3                   	ret

8010794b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010794b:	f3 0f 1e fb          	endbr32
8010794f:	55                   	push   %ebp
80107950:	89 e5                	mov    %esp,%ebp
80107952:	53                   	push   %ebx
80107953:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107956:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010795d:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107962:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107967:	29 c2                	sub    %eax,%edx
80107969:	89 d0                	mov    %edx,%eax
8010796b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010796e:	a1 84 80 19 80       	mov    0x80198084,%eax
80107973:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107976:	8b 15 84 80 19 80    	mov    0x80198084,%edx
8010797c:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107981:	01 d0                	add    %edx,%eax
80107983:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107986:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010798d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107990:	83 c0 30             	add    $0x30,%eax
80107993:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107996:	89 10                	mov    %edx,(%eax)
80107998:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010799b:	89 50 04             	mov    %edx,0x4(%eax)
8010799e:	8b 55 e8             	mov    -0x18(%ebp),%edx
801079a1:	89 50 08             	mov    %edx,0x8(%eax)
801079a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801079a7:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801079aa:	e8 51 af ff ff       	call   80102900 <kalloc>
801079af:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079b6:	75 07                	jne    801079bf <setupkvm+0x74>
    return 0;
801079b8:	b8 00 00 00 00       	mov    $0x0,%eax
801079bd:	eb 78                	jmp    80107a37 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801079bf:	83 ec 04             	sub    $0x4,%esp
801079c2:	68 00 10 00 00       	push   $0x1000
801079c7:	6a 00                	push   $0x0
801079c9:	ff 75 f0             	push   -0x10(%ebp)
801079cc:	e8 69 d3 ff ff       	call   80104d3a <memset>
801079d1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079d4:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801079db:	eb 4e                	jmp    80107a2b <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e6:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ec:	8b 58 08             	mov    0x8(%eax),%ebx
801079ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f2:	8b 40 04             	mov    0x4(%eax),%eax
801079f5:	29 c3                	sub    %eax,%ebx
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	8b 00                	mov    (%eax),%eax
801079fc:	83 ec 0c             	sub    $0xc,%esp
801079ff:	51                   	push   %ecx
80107a00:	52                   	push   %edx
80107a01:	53                   	push   %ebx
80107a02:	50                   	push   %eax
80107a03:	ff 75 f0             	push   -0x10(%ebp)
80107a06:	e8 ac fe ff ff       	call   801078b7 <mappages>
80107a0b:	83 c4 20             	add    $0x20,%esp
80107a0e:	85 c0                	test   %eax,%eax
80107a10:	79 15                	jns    80107a27 <setupkvm+0xdc>
      freevm(pgdir);
80107a12:	83 ec 0c             	sub    $0xc,%esp
80107a15:	ff 75 f0             	push   -0x10(%ebp)
80107a18:	e8 11 05 00 00       	call   80107f2e <freevm>
80107a1d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a20:	b8 00 00 00 00       	mov    $0x0,%eax
80107a25:	eb 10                	jmp    80107a37 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a27:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a2b:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107a32:	72 a9                	jb     801079dd <setupkvm+0x92>
    }
  return pgdir;
80107a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a3a:	c9                   	leave
80107a3b:	c3                   	ret

80107a3c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a3c:	f3 0f 1e fb          	endbr32
80107a40:	55                   	push   %ebp
80107a41:	89 e5                	mov    %esp,%ebp
80107a43:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a46:	e8 00 ff ff ff       	call   8010794b <setupkvm>
80107a4b:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
80107a50:	e8 03 00 00 00       	call   80107a58 <switchkvm>
}
80107a55:	90                   	nop
80107a56:	c9                   	leave
80107a57:	c3                   	ret

80107a58 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a58:	f3 0f 1e fb          	endbr32
80107a5c:	55                   	push   %ebp
80107a5d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a5f:	a1 84 7d 19 80       	mov    0x80197d84,%eax
80107a64:	05 00 00 00 80       	add    $0x80000000,%eax
80107a69:	50                   	push   %eax
80107a6a:	e8 48 fa ff ff       	call   801074b7 <lcr3>
80107a6f:	83 c4 04             	add    $0x4,%esp
}
80107a72:	90                   	nop
80107a73:	c9                   	leave
80107a74:	c3                   	ret

80107a75 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a75:	f3 0f 1e fb          	endbr32
80107a79:	55                   	push   %ebp
80107a7a:	89 e5                	mov    %esp,%ebp
80107a7c:	56                   	push   %esi
80107a7d:	53                   	push   %ebx
80107a7e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107a81:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a85:	75 0d                	jne    80107a94 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107a87:	83 ec 0c             	sub    $0xc,%esp
80107a8a:	68 9a ae 10 80       	push   $0x8010ae9a
80107a8f:	e8 4a 8b ff ff       	call   801005de <panic>
  if(p->kstack == 0)
80107a94:	8b 45 08             	mov    0x8(%ebp),%eax
80107a97:	8b 40 08             	mov    0x8(%eax),%eax
80107a9a:	85 c0                	test   %eax,%eax
80107a9c:	75 0d                	jne    80107aab <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107a9e:	83 ec 0c             	sub    $0xc,%esp
80107aa1:	68 b0 ae 10 80       	push   $0x8010aeb0
80107aa6:	e8 33 8b ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
80107aab:	8b 45 08             	mov    0x8(%ebp),%eax
80107aae:	8b 40 04             	mov    0x4(%eax),%eax
80107ab1:	85 c0                	test   %eax,%eax
80107ab3:	75 0d                	jne    80107ac2 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107ab5:	83 ec 0c             	sub    $0xc,%esp
80107ab8:	68 c5 ae 10 80       	push   $0x8010aec5
80107abd:	e8 1c 8b ff ff       	call   801005de <panic>

  pushcli();
80107ac2:	e8 60 d1 ff ff       	call   80104c27 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ac7:	e8 cf c0 ff ff       	call   80103b9b <mycpu>
80107acc:	89 c3                	mov    %eax,%ebx
80107ace:	e8 c8 c0 ff ff       	call   80103b9b <mycpu>
80107ad3:	83 c0 08             	add    $0x8,%eax
80107ad6:	89 c6                	mov    %eax,%esi
80107ad8:	e8 be c0 ff ff       	call   80103b9b <mycpu>
80107add:	83 c0 08             	add    $0x8,%eax
80107ae0:	c1 e8 10             	shr    $0x10,%eax
80107ae3:	88 45 f7             	mov    %al,-0x9(%ebp)
80107ae6:	e8 b0 c0 ff ff       	call   80103b9b <mycpu>
80107aeb:	83 c0 08             	add    $0x8,%eax
80107aee:	c1 e8 18             	shr    $0x18,%eax
80107af1:	89 c2                	mov    %eax,%edx
80107af3:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107afa:	67 00 
80107afc:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b03:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107b07:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107b0d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b14:	83 e0 f0             	and    $0xfffffff0,%eax
80107b17:	83 c8 09             	or     $0x9,%eax
80107b1a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b20:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b27:	83 c8 10             	or     $0x10,%eax
80107b2a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b30:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b37:	83 e0 9f             	and    $0xffffff9f,%eax
80107b3a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b40:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b47:	83 c8 80             	or     $0xffffff80,%eax
80107b4a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b50:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b57:	83 e0 f0             	and    $0xfffffff0,%eax
80107b5a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b60:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b67:	83 e0 ef             	and    $0xffffffef,%eax
80107b6a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b70:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b77:	83 e0 df             	and    $0xffffffdf,%eax
80107b7a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b80:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b87:	83 c8 40             	or     $0x40,%eax
80107b8a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b90:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b97:	83 e0 7f             	and    $0x7f,%eax
80107b9a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ba0:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ba6:	e8 f0 bf ff ff       	call   80103b9b <mycpu>
80107bab:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bb2:	83 e2 ef             	and    $0xffffffef,%edx
80107bb5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107bbb:	e8 db bf ff ff       	call   80103b9b <mycpu>
80107bc0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc9:	8b 40 08             	mov    0x8(%eax),%eax
80107bcc:	89 c3                	mov    %eax,%ebx
80107bce:	e8 c8 bf ff ff       	call   80103b9b <mycpu>
80107bd3:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107bd9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107bdc:	e8 ba bf ff ff       	call   80103b9b <mycpu>
80107be1:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107be7:	83 ec 0c             	sub    $0xc,%esp
80107bea:	6a 28                	push   $0x28
80107bec:	e8 af f8 ff ff       	call   801074a0 <ltr>
80107bf1:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf7:	8b 40 04             	mov    0x4(%eax),%eax
80107bfa:	05 00 00 00 80       	add    $0x80000000,%eax
80107bff:	83 ec 0c             	sub    $0xc,%esp
80107c02:	50                   	push   %eax
80107c03:	e8 af f8 ff ff       	call   801074b7 <lcr3>
80107c08:	83 c4 10             	add    $0x10,%esp
  popcli();
80107c0b:	e8 68 d0 ff ff       	call   80104c78 <popcli>
}
80107c10:	90                   	nop
80107c11:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c14:	5b                   	pop    %ebx
80107c15:	5e                   	pop    %esi
80107c16:	5d                   	pop    %ebp
80107c17:	c3                   	ret

80107c18 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c18:	f3 0f 1e fb          	endbr32
80107c1c:	55                   	push   %ebp
80107c1d:	89 e5                	mov    %esp,%ebp
80107c1f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c22:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c29:	76 0d                	jbe    80107c38 <inituvm+0x20>
    panic("inituvm: more than a page");
80107c2b:	83 ec 0c             	sub    $0xc,%esp
80107c2e:	68 d9 ae 10 80       	push   $0x8010aed9
80107c33:	e8 a6 89 ff ff       	call   801005de <panic>
  mem = kalloc();
80107c38:	e8 c3 ac ff ff       	call   80102900 <kalloc>
80107c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c40:	83 ec 04             	sub    $0x4,%esp
80107c43:	68 00 10 00 00       	push   $0x1000
80107c48:	6a 00                	push   $0x0
80107c4a:	ff 75 f4             	push   -0xc(%ebp)
80107c4d:	e8 e8 d0 ff ff       	call   80104d3a <memset>
80107c52:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	05 00 00 00 80       	add    $0x80000000,%eax
80107c5d:	83 ec 0c             	sub    $0xc,%esp
80107c60:	6a 06                	push   $0x6
80107c62:	50                   	push   %eax
80107c63:	68 00 10 00 00       	push   $0x1000
80107c68:	6a 00                	push   $0x0
80107c6a:	ff 75 08             	push   0x8(%ebp)
80107c6d:	e8 45 fc ff ff       	call   801078b7 <mappages>
80107c72:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c75:	83 ec 04             	sub    $0x4,%esp
80107c78:	ff 75 10             	push   0x10(%ebp)
80107c7b:	ff 75 0c             	push   0xc(%ebp)
80107c7e:	ff 75 f4             	push   -0xc(%ebp)
80107c81:	e8 7b d1 ff ff       	call   80104e01 <memmove>
80107c86:	83 c4 10             	add    $0x10,%esp
}
80107c89:	90                   	nop
80107c8a:	c9                   	leave
80107c8b:	c3                   	ret

80107c8c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c8c:	f3 0f 1e fb          	endbr32
80107c90:	55                   	push   %ebp
80107c91:	89 e5                	mov    %esp,%ebp
80107c93:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c99:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c9e:	85 c0                	test   %eax,%eax
80107ca0:	74 0d                	je     80107caf <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107ca2:	83 ec 0c             	sub    $0xc,%esp
80107ca5:	68 f4 ae 10 80       	push   $0x8010aef4
80107caa:	e8 2f 89 ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107caf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cb6:	e9 8f 00 00 00       	jmp    80107d4a <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	01 d0                	add    %edx,%eax
80107cc3:	83 ec 04             	sub    $0x4,%esp
80107cc6:	6a 00                	push   $0x0
80107cc8:	50                   	push   %eax
80107cc9:	ff 75 08             	push   0x8(%ebp)
80107ccc:	e8 4c fb ff ff       	call   8010781d <walkpgdir>
80107cd1:	83 c4 10             	add    $0x10,%esp
80107cd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cd7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cdb:	75 0d                	jne    80107cea <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107cdd:	83 ec 0c             	sub    $0xc,%esp
80107ce0:	68 17 af 10 80       	push   $0x8010af17
80107ce5:	e8 f4 88 ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107cea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ced:	8b 00                	mov    (%eax),%eax
80107cef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107cf7:	8b 45 18             	mov    0x18(%ebp),%eax
80107cfa:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107cfd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d02:	77 0b                	ja     80107d0f <loaduvm+0x83>
      n = sz - i;
80107d04:	8b 45 18             	mov    0x18(%ebp),%eax
80107d07:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d0d:	eb 07                	jmp    80107d16 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107d0f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d16:	8b 55 14             	mov    0x14(%ebp),%edx
80107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1c:	01 d0                	add    %edx,%eax
80107d1e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d21:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107d27:	ff 75 f0             	push   -0x10(%ebp)
80107d2a:	50                   	push   %eax
80107d2b:	52                   	push   %edx
80107d2c:	ff 75 10             	push   0x10(%ebp)
80107d2f:	e8 be a2 ff ff       	call   80101ff2 <readi>
80107d34:	83 c4 10             	add    $0x10,%esp
80107d37:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107d3a:	74 07                	je     80107d43 <loaduvm+0xb7>
      return -1;
80107d3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d41:	eb 18                	jmp    80107d5b <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107d43:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4d:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d50:	0f 82 65 ff ff ff    	jb     80107cbb <loaduvm+0x2f>
  }
  return 0;
80107d56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d5b:	c9                   	leave
80107d5c:	c3                   	ret

80107d5d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d5d:	f3 0f 1e fb          	endbr32
80107d61:	55                   	push   %ebp
80107d62:	89 e5                	mov    %esp,%ebp
80107d64:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d67:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6a:	85 c0                	test   %eax,%eax
80107d6c:	79 0a                	jns    80107d78 <allocuvm+0x1b>
    return 0;
80107d6e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d73:	e9 ec 00 00 00       	jmp    80107e64 <allocuvm+0x107>
  if(newsz < oldsz)
80107d78:	8b 45 10             	mov    0x10(%ebp),%eax
80107d7b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d7e:	73 08                	jae    80107d88 <allocuvm+0x2b>
    return oldsz;
80107d80:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d83:	e9 dc 00 00 00       	jmp    80107e64 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107d88:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d8b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d98:	e9 b8 00 00 00       	jmp    80107e55 <allocuvm+0xf8>
    mem = kalloc();
80107d9d:	e8 5e ab ff ff       	call   80102900 <kalloc>
80107da2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107da5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107da9:	75 2e                	jne    80107dd9 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107dab:	83 ec 0c             	sub    $0xc,%esp
80107dae:	68 35 af 10 80       	push   $0x8010af35
80107db3:	e8 54 86 ff ff       	call   8010040c <cprintf>
80107db8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dbb:	83 ec 04             	sub    $0x4,%esp
80107dbe:	ff 75 0c             	push   0xc(%ebp)
80107dc1:	ff 75 10             	push   0x10(%ebp)
80107dc4:	ff 75 08             	push   0x8(%ebp)
80107dc7:	e8 9a 00 00 00       	call   80107e66 <deallocuvm>
80107dcc:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dcf:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd4:	e9 8b 00 00 00       	jmp    80107e64 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107dd9:	83 ec 04             	sub    $0x4,%esp
80107ddc:	68 00 10 00 00       	push   $0x1000
80107de1:	6a 00                	push   $0x0
80107de3:	ff 75 f0             	push   -0x10(%ebp)
80107de6:	e8 4f cf ff ff       	call   80104d3a <memset>
80107deb:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	83 ec 0c             	sub    $0xc,%esp
80107dfd:	6a 06                	push   $0x6
80107dff:	52                   	push   %edx
80107e00:	68 00 10 00 00       	push   $0x1000
80107e05:	50                   	push   %eax
80107e06:	ff 75 08             	push   0x8(%ebp)
80107e09:	e8 a9 fa ff ff       	call   801078b7 <mappages>
80107e0e:	83 c4 20             	add    $0x20,%esp
80107e11:	85 c0                	test   %eax,%eax
80107e13:	79 39                	jns    80107e4e <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107e15:	83 ec 0c             	sub    $0xc,%esp
80107e18:	68 4d af 10 80       	push   $0x8010af4d
80107e1d:	e8 ea 85 ff ff       	call   8010040c <cprintf>
80107e22:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e25:	83 ec 04             	sub    $0x4,%esp
80107e28:	ff 75 0c             	push   0xc(%ebp)
80107e2b:	ff 75 10             	push   0x10(%ebp)
80107e2e:	ff 75 08             	push   0x8(%ebp)
80107e31:	e8 30 00 00 00       	call   80107e66 <deallocuvm>
80107e36:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107e39:	83 ec 0c             	sub    $0xc,%esp
80107e3c:	ff 75 f0             	push   -0x10(%ebp)
80107e3f:	e8 1e aa ff ff       	call   80102862 <kfree>
80107e44:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e47:	b8 00 00 00 00       	mov    $0x0,%eax
80107e4c:	eb 16                	jmp    80107e64 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107e4e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e5b:	0f 82 3c ff ff ff    	jb     80107d9d <allocuvm+0x40>
    }
  }
  return newsz;
80107e61:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e64:	c9                   	leave
80107e65:	c3                   	ret

80107e66 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e66:	f3 0f 1e fb          	endbr32
80107e6a:	55                   	push   %ebp
80107e6b:	89 e5                	mov    %esp,%ebp
80107e6d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e70:	8b 45 10             	mov    0x10(%ebp),%eax
80107e73:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e76:	72 08                	jb     80107e80 <deallocuvm+0x1a>
    return oldsz;
80107e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e7b:	e9 ac 00 00 00       	jmp    80107f2c <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107e80:	8b 45 10             	mov    0x10(%ebp),%eax
80107e83:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e90:	e9 88 00 00 00       	jmp    80107f1d <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e98:	83 ec 04             	sub    $0x4,%esp
80107e9b:	6a 00                	push   $0x0
80107e9d:	50                   	push   %eax
80107e9e:	ff 75 08             	push   0x8(%ebp)
80107ea1:	e8 77 f9 ff ff       	call   8010781d <walkpgdir>
80107ea6:	83 c4 10             	add    $0x10,%esp
80107ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107eac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eb0:	75 16                	jne    80107ec8 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb5:	c1 e8 16             	shr    $0x16,%eax
80107eb8:	83 c0 01             	add    $0x1,%eax
80107ebb:	c1 e0 16             	shl    $0x16,%eax
80107ebe:	2d 00 10 00 00       	sub    $0x1000,%eax
80107ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ec6:	eb 4e                	jmp    80107f16 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ecb:	8b 00                	mov    (%eax),%eax
80107ecd:	83 e0 01             	and    $0x1,%eax
80107ed0:	85 c0                	test   %eax,%eax
80107ed2:	74 42                	je     80107f16 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed7:	8b 00                	mov    (%eax),%eax
80107ed9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ede:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ee1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ee5:	75 0d                	jne    80107ef4 <deallocuvm+0x8e>
        panic("kfree");
80107ee7:	83 ec 0c             	sub    $0xc,%esp
80107eea:	68 69 af 10 80       	push   $0x8010af69
80107eef:	e8 ea 86 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef7:	05 00 00 00 80       	add    $0x80000000,%eax
80107efc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107eff:	83 ec 0c             	sub    $0xc,%esp
80107f02:	ff 75 e8             	push   -0x18(%ebp)
80107f05:	e8 58 a9 ff ff       	call   80102862 <kfree>
80107f0a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f16:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f23:	0f 82 6c ff ff ff    	jb     80107e95 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107f29:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f2c:	c9                   	leave
80107f2d:	c3                   	ret

80107f2e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f2e:	f3 0f 1e fb          	endbr32
80107f32:	55                   	push   %ebp
80107f33:	89 e5                	mov    %esp,%ebp
80107f35:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107f38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f3c:	75 0d                	jne    80107f4b <freevm+0x1d>
    panic("freevm: no pgdir");
80107f3e:	83 ec 0c             	sub    $0xc,%esp
80107f41:	68 6f af 10 80       	push   $0x8010af6f
80107f46:	e8 93 86 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f4b:	83 ec 04             	sub    $0x4,%esp
80107f4e:	6a 00                	push   $0x0
80107f50:	68 00 00 00 80       	push   $0x80000000
80107f55:	ff 75 08             	push   0x8(%ebp)
80107f58:	e8 09 ff ff ff       	call   80107e66 <deallocuvm>
80107f5d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f67:	eb 48                	jmp    80107fb1 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f73:	8b 45 08             	mov    0x8(%ebp),%eax
80107f76:	01 d0                	add    %edx,%eax
80107f78:	8b 00                	mov    (%eax),%eax
80107f7a:	83 e0 01             	and    $0x1,%eax
80107f7d:	85 c0                	test   %eax,%eax
80107f7f:	74 2c                	je     80107fad <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8e:	01 d0                	add    %edx,%eax
80107f90:	8b 00                	mov    (%eax),%eax
80107f92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f97:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f9f:	83 ec 0c             	sub    $0xc,%esp
80107fa2:	ff 75 f0             	push   -0x10(%ebp)
80107fa5:	e8 b8 a8 ff ff       	call   80102862 <kfree>
80107faa:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fb1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107fb8:	76 af                	jbe    80107f69 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107fba:	83 ec 0c             	sub    $0xc,%esp
80107fbd:	ff 75 08             	push   0x8(%ebp)
80107fc0:	e8 9d a8 ff ff       	call   80102862 <kfree>
80107fc5:	83 c4 10             	add    $0x10,%esp
}
80107fc8:	90                   	nop
80107fc9:	c9                   	leave
80107fca:	c3                   	ret

80107fcb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fcb:	f3 0f 1e fb          	endbr32
80107fcf:	55                   	push   %ebp
80107fd0:	89 e5                	mov    %esp,%ebp
80107fd2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fd5:	83 ec 04             	sub    $0x4,%esp
80107fd8:	6a 00                	push   $0x0
80107fda:	ff 75 0c             	push   0xc(%ebp)
80107fdd:	ff 75 08             	push   0x8(%ebp)
80107fe0:	e8 38 f8 ff ff       	call   8010781d <walkpgdir>
80107fe5:	83 c4 10             	add    $0x10,%esp
80107fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107feb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fef:	75 0d                	jne    80107ffe <clearpteu+0x33>
    panic("clearpteu");
80107ff1:	83 ec 0c             	sub    $0xc,%esp
80107ff4:	68 80 af 10 80       	push   $0x8010af80
80107ff9:	e8 e0 85 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108001:	8b 00                	mov    (%eax),%eax
80108003:	83 e0 fb             	and    $0xfffffffb,%eax
80108006:	89 c2                	mov    %eax,%edx
80108008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800b:	89 10                	mov    %edx,(%eax)
}
8010800d:	90                   	nop
8010800e:	c9                   	leave
8010800f:	c3                   	ret

80108010 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108010:	f3 0f 1e fb          	endbr32
80108014:	55                   	push   %ebp
80108015:	89 e5                	mov    %esp,%ebp
80108017:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
8010801a:	e8 2c f9 ff ff       	call   8010794b <setupkvm>
8010801f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108022:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108026:	75 0a                	jne    80108032 <copyuvm+0x22>
    return 0;
80108028:	b8 00 00 00 00       	mov    $0x0,%eax
8010802d:	e9 d6 00 00 00       	jmp    80108108 <copyuvm+0xf8>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80108032:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108039:	e9 a3 00 00 00       	jmp    801080e1 <copyuvm+0xd1>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010803e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108041:	83 ec 04             	sub    $0x4,%esp
80108044:	6a 00                	push   $0x0
80108046:	50                   	push   %eax
80108047:	ff 75 08             	push   0x8(%ebp)
8010804a:	e8 ce f7 ff ff       	call   8010781d <walkpgdir>
8010804f:	83 c4 10             	add    $0x10,%esp
80108052:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108055:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108059:	74 7b                	je     801080d6 <copyuvm+0xc6>
      continue;
    if(!(*pte & PTE_P)){
8010805b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805e:	8b 00                	mov    (%eax),%eax
80108060:	83 e0 01             	and    $0x1,%eax
80108063:	85 c0                	test   %eax,%eax
80108065:	74 72                	je     801080d9 <copyuvm+0xc9>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80108067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806a:	8b 00                	mov    (%eax),%eax
8010806c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108071:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108077:	8b 00                	mov    (%eax),%eax
80108079:	25 ff 0f 00 00       	and    $0xfff,%eax
8010807e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80108081:	e8 7a a8 ff ff       	call   80102900 <kalloc>
80108086:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108089:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010808d:	74 62                	je     801080f1 <copyuvm+0xe1>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010808f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108092:	05 00 00 00 80       	add    $0x80000000,%eax
80108097:	83 ec 04             	sub    $0x4,%esp
8010809a:	68 00 10 00 00       	push   $0x1000
8010809f:	50                   	push   %eax
801080a0:	ff 75 e0             	push   -0x20(%ebp)
801080a3:	e8 59 cd ff ff       	call   80104e01 <memmove>
801080a8:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801080ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801080ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080b1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801080b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ba:	83 ec 0c             	sub    $0xc,%esp
801080bd:	52                   	push   %edx
801080be:	51                   	push   %ecx
801080bf:	68 00 10 00 00       	push   $0x1000
801080c4:	50                   	push   %eax
801080c5:	ff 75 f0             	push   -0x10(%ebp)
801080c8:	e8 ea f7 ff ff       	call   801078b7 <mappages>
801080cd:	83 c4 20             	add    $0x20,%esp
801080d0:	85 c0                	test   %eax,%eax
801080d2:	78 20                	js     801080f4 <copyuvm+0xe4>
801080d4:	eb 04                	jmp    801080da <copyuvm+0xca>
      continue;
801080d6:	90                   	nop
801080d7:	eb 01                	jmp    801080da <copyuvm+0xca>
      continue;
801080d9:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
801080da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e4:	85 c0                	test   %eax,%eax
801080e6:	0f 89 52 ff ff ff    	jns    8010803e <copyuvm+0x2e>
      goto bad;
  }  
  return d;
801080ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ef:	eb 17                	jmp    80108108 <copyuvm+0xf8>
      goto bad;
801080f1:	90                   	nop
801080f2:	eb 01                	jmp    801080f5 <copyuvm+0xe5>
      goto bad;
801080f4:	90                   	nop

bad:
  freevm(d);
801080f5:	83 ec 0c             	sub    $0xc,%esp
801080f8:	ff 75 f0             	push   -0x10(%ebp)
801080fb:	e8 2e fe ff ff       	call   80107f2e <freevm>
80108100:	83 c4 10             	add    $0x10,%esp
  return 0;
80108103:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108108:	c9                   	leave
80108109:	c3                   	ret

8010810a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010810a:	f3 0f 1e fb          	endbr32
8010810e:	55                   	push   %ebp
8010810f:	89 e5                	mov    %esp,%ebp
80108111:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108114:	83 ec 04             	sub    $0x4,%esp
80108117:	6a 00                	push   $0x0
80108119:	ff 75 0c             	push   0xc(%ebp)
8010811c:	ff 75 08             	push   0x8(%ebp)
8010811f:	e8 f9 f6 ff ff       	call   8010781d <walkpgdir>
80108124:	83 c4 10             	add    $0x10,%esp
80108127:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	8b 00                	mov    (%eax),%eax
8010812f:	83 e0 01             	and    $0x1,%eax
80108132:	85 c0                	test   %eax,%eax
80108134:	75 07                	jne    8010813d <uva2ka+0x33>
    return 0;
80108136:	b8 00 00 00 00       	mov    $0x0,%eax
8010813b:	eb 22                	jmp    8010815f <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
8010813d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108140:	8b 00                	mov    (%eax),%eax
80108142:	83 e0 04             	and    $0x4,%eax
80108145:	85 c0                	test   %eax,%eax
80108147:	75 07                	jne    80108150 <uva2ka+0x46>
    return 0;
80108149:	b8 00 00 00 00       	mov    $0x0,%eax
8010814e:	eb 0f                	jmp    8010815f <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108153:	8b 00                	mov    (%eax),%eax
80108155:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010815a:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010815f:	c9                   	leave
80108160:	c3                   	ret

80108161 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108161:	f3 0f 1e fb          	endbr32
80108165:	55                   	push   %ebp
80108166:	89 e5                	mov    %esp,%ebp
80108168:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010816b:	8b 45 10             	mov    0x10(%ebp),%eax
8010816e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108171:	eb 7f                	jmp    801081f2 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108173:	8b 45 0c             	mov    0xc(%ebp),%eax
80108176:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010817e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108181:	83 ec 08             	sub    $0x8,%esp
80108184:	50                   	push   %eax
80108185:	ff 75 08             	push   0x8(%ebp)
80108188:	e8 7d ff ff ff       	call   8010810a <uva2ka>
8010818d:	83 c4 10             	add    $0x10,%esp
80108190:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108193:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108197:	75 07                	jne    801081a0 <copyout+0x3f>
      return -1;
80108199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010819e:	eb 61                	jmp    80108201 <copyout+0xa0>
    n = PGSIZE - (va - va0);
801081a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081a3:	2b 45 0c             	sub    0xc(%ebp),%eax
801081a6:	05 00 10 00 00       	add    $0x1000,%eax
801081ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801081ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b1:	3b 45 14             	cmp    0x14(%ebp),%eax
801081b4:	76 06                	jbe    801081bc <copyout+0x5b>
      n = len;
801081b6:	8b 45 14             	mov    0x14(%ebp),%eax
801081b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081bf:	2b 45 ec             	sub    -0x14(%ebp),%eax
801081c2:	89 c2                	mov    %eax,%edx
801081c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c7:	01 d0                	add    %edx,%eax
801081c9:	83 ec 04             	sub    $0x4,%esp
801081cc:	ff 75 f0             	push   -0x10(%ebp)
801081cf:	ff 75 f4             	push   -0xc(%ebp)
801081d2:	50                   	push   %eax
801081d3:	e8 29 cc ff ff       	call   80104e01 <memmove>
801081d8:	83 c4 10             	add    $0x10,%esp
    len -= n;
801081db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081de:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ea:	05 00 10 00 00       	add    $0x1000,%eax
801081ef:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801081f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081f6:	0f 85 77 ff ff ff    	jne    80108173 <copyout+0x12>
  }
  return 0;
801081fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108201:	c9                   	leave
80108202:	c3                   	ret

80108203 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108203:	f3 0f 1e fb          	endbr32
80108207:	55                   	push   %ebp
80108208:	89 e5                	mov    %esp,%ebp
8010820a:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010820d:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108214:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108217:	8b 40 08             	mov    0x8(%eax),%eax
8010821a:	05 00 00 00 80       	add    $0x80000000,%eax
8010821f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108222:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822c:	8b 40 24             	mov    0x24(%eax),%eax
8010822f:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108234:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
8010823b:	00 00 00 

  while(i<madt->len){
8010823e:	90                   	nop
8010823f:	e9 be 00 00 00       	jmp    80108302 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108244:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108247:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010824a:	01 d0                	add    %edx,%eax
8010824c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010824f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108252:	0f b6 00             	movzbl (%eax),%eax
80108255:	0f b6 c0             	movzbl %al,%eax
80108258:	83 f8 05             	cmp    $0x5,%eax
8010825b:	0f 87 a1 00 00 00    	ja     80108302 <mpinit_uefi+0xff>
80108261:	8b 04 85 8c af 10 80 	mov    -0x7fef5074(,%eax,4),%eax
80108268:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010826b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108271:	a1 80 80 19 80       	mov    0x80198080,%eax
80108276:	83 f8 03             	cmp    $0x3,%eax
80108279:	7f 28                	jg     801082a3 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010827b:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108281:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108284:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108288:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010828e:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108294:	88 02                	mov    %al,(%edx)
          ncpu++;
80108296:	a1 80 80 19 80       	mov    0x80198080,%eax
8010829b:	83 c0 01             	add    $0x1,%eax
8010829e:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
801082a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082a6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082aa:	0f b6 c0             	movzbl %al,%eax
801082ad:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082b0:	eb 50                	jmp    80108302 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801082b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801082b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082bb:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801082bf:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
801082c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082c7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082cb:	0f b6 c0             	movzbl %al,%eax
801082ce:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082d1:	eb 2f                	jmp    80108302 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801082d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801082d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082dc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082e0:	0f b6 c0             	movzbl %al,%eax
801082e3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082e6:	eb 1a                	jmp    80108302 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801082e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801082ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082f5:	0f b6 c0             	movzbl %al,%eax
801082f8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082fb:	eb 05                	jmp    80108302 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801082fd:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108301:	90                   	nop
  while(i<madt->len){
80108302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108305:	8b 40 04             	mov    0x4(%eax),%eax
80108308:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010830b:	0f 82 33 ff ff ff    	jb     80108244 <mpinit_uefi+0x41>
    }
  }

}
80108311:	90                   	nop
80108312:	90                   	nop
80108313:	c9                   	leave
80108314:	c3                   	ret

80108315 <inb>:
{
80108315:	55                   	push   %ebp
80108316:	89 e5                	mov    %esp,%ebp
80108318:	83 ec 14             	sub    $0x14,%esp
8010831b:	8b 45 08             	mov    0x8(%ebp),%eax
8010831e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108322:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108326:	89 c2                	mov    %eax,%edx
80108328:	ec                   	in     (%dx),%al
80108329:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010832c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108330:	c9                   	leave
80108331:	c3                   	ret

80108332 <outb>:
{
80108332:	55                   	push   %ebp
80108333:	89 e5                	mov    %esp,%ebp
80108335:	83 ec 08             	sub    $0x8,%esp
80108338:	8b 45 08             	mov    0x8(%ebp),%eax
8010833b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108342:	89 d0                	mov    %edx,%eax
80108344:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108347:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010834b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010834f:	ee                   	out    %al,(%dx)
}
80108350:	90                   	nop
80108351:	c9                   	leave
80108352:	c3                   	ret

80108353 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108353:	f3 0f 1e fb          	endbr32
80108357:	55                   	push   %ebp
80108358:	89 e5                	mov    %esp,%ebp
8010835a:	83 ec 28             	sub    $0x28,%esp
8010835d:	8b 45 08             	mov    0x8(%ebp),%eax
80108360:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108363:	6a 00                	push   $0x0
80108365:	68 fa 03 00 00       	push   $0x3fa
8010836a:	e8 c3 ff ff ff       	call   80108332 <outb>
8010836f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108372:	68 80 00 00 00       	push   $0x80
80108377:	68 fb 03 00 00       	push   $0x3fb
8010837c:	e8 b1 ff ff ff       	call   80108332 <outb>
80108381:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108384:	6a 0c                	push   $0xc
80108386:	68 f8 03 00 00       	push   $0x3f8
8010838b:	e8 a2 ff ff ff       	call   80108332 <outb>
80108390:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108393:	6a 00                	push   $0x0
80108395:	68 f9 03 00 00       	push   $0x3f9
8010839a:	e8 93 ff ff ff       	call   80108332 <outb>
8010839f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801083a2:	6a 03                	push   $0x3
801083a4:	68 fb 03 00 00       	push   $0x3fb
801083a9:	e8 84 ff ff ff       	call   80108332 <outb>
801083ae:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801083b1:	6a 00                	push   $0x0
801083b3:	68 fc 03 00 00       	push   $0x3fc
801083b8:	e8 75 ff ff ff       	call   80108332 <outb>
801083bd:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801083c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c7:	eb 11                	jmp    801083da <uart_debug+0x87>
801083c9:	83 ec 0c             	sub    $0xc,%esp
801083cc:	6a 0a                	push   $0xa
801083ce:	e8 df a8 ff ff       	call   80102cb2 <microdelay>
801083d3:	83 c4 10             	add    $0x10,%esp
801083d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083da:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801083de:	7f 1a                	jg     801083fa <uart_debug+0xa7>
801083e0:	83 ec 0c             	sub    $0xc,%esp
801083e3:	68 fd 03 00 00       	push   $0x3fd
801083e8:	e8 28 ff ff ff       	call   80108315 <inb>
801083ed:	83 c4 10             	add    $0x10,%esp
801083f0:	0f b6 c0             	movzbl %al,%eax
801083f3:	83 e0 20             	and    $0x20,%eax
801083f6:	85 c0                	test   %eax,%eax
801083f8:	74 cf                	je     801083c9 <uart_debug+0x76>
  outb(COM1+0, p);
801083fa:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801083fe:	0f b6 c0             	movzbl %al,%eax
80108401:	83 ec 08             	sub    $0x8,%esp
80108404:	50                   	push   %eax
80108405:	68 f8 03 00 00       	push   $0x3f8
8010840a:	e8 23 ff ff ff       	call   80108332 <outb>
8010840f:	83 c4 10             	add    $0x10,%esp
}
80108412:	90                   	nop
80108413:	c9                   	leave
80108414:	c3                   	ret

80108415 <uart_debugs>:

void uart_debugs(char *p){
80108415:	f3 0f 1e fb          	endbr32
80108419:	55                   	push   %ebp
8010841a:	89 e5                	mov    %esp,%ebp
8010841c:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010841f:	eb 1b                	jmp    8010843c <uart_debugs+0x27>
    uart_debug(*p++);
80108421:	8b 45 08             	mov    0x8(%ebp),%eax
80108424:	8d 50 01             	lea    0x1(%eax),%edx
80108427:	89 55 08             	mov    %edx,0x8(%ebp)
8010842a:	0f b6 00             	movzbl (%eax),%eax
8010842d:	0f be c0             	movsbl %al,%eax
80108430:	83 ec 0c             	sub    $0xc,%esp
80108433:	50                   	push   %eax
80108434:	e8 1a ff ff ff       	call   80108353 <uart_debug>
80108439:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010843c:	8b 45 08             	mov    0x8(%ebp),%eax
8010843f:	0f b6 00             	movzbl (%eax),%eax
80108442:	84 c0                	test   %al,%al
80108444:	75 db                	jne    80108421 <uart_debugs+0xc>
  }
}
80108446:	90                   	nop
80108447:	90                   	nop
80108448:	c9                   	leave
80108449:	c3                   	ret

8010844a <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010844a:	f3 0f 1e fb          	endbr32
8010844e:	55                   	push   %ebp
8010844f:	89 e5                	mov    %esp,%ebp
80108451:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108454:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010845b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010845e:	8b 50 14             	mov    0x14(%eax),%edx
80108461:	8b 40 10             	mov    0x10(%eax),%eax
80108464:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108469:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010846c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010846f:	8b 40 18             	mov    0x18(%eax),%eax
80108472:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108477:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010847c:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108481:	29 c2                	sub    %eax,%edx
80108483:	89 d0                	mov    %edx,%eax
80108485:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010848a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010848d:	8b 50 24             	mov    0x24(%eax),%edx
80108490:	8b 40 20             	mov    0x20(%eax),%eax
80108493:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108498:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010849b:	8b 50 2c             	mov    0x2c(%eax),%edx
8010849e:	8b 40 28             	mov    0x28(%eax),%eax
801084a1:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801084a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084a9:	8b 50 34             	mov    0x34(%eax),%edx
801084ac:	8b 40 30             	mov    0x30(%eax),%eax
801084af:	a3 98 80 19 80       	mov    %eax,0x80198098
}
801084b4:	90                   	nop
801084b5:	c9                   	leave
801084b6:	c3                   	ret

801084b7 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801084b7:	f3 0f 1e fb          	endbr32
801084bb:	55                   	push   %ebp
801084bc:	89 e5                	mov    %esp,%ebp
801084be:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801084c1:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801084c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ca:	0f af d0             	imul   %eax,%edx
801084cd:	8b 45 08             	mov    0x8(%ebp),%eax
801084d0:	01 d0                	add    %edx,%eax
801084d2:	c1 e0 02             	shl    $0x2,%eax
801084d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801084d8:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801084de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084e1:	01 d0                	add    %edx,%eax
801084e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801084e6:	8b 45 10             	mov    0x10(%ebp),%eax
801084e9:	0f b6 10             	movzbl (%eax),%edx
801084ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084ef:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801084f1:	8b 45 10             	mov    0x10(%ebp),%eax
801084f4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801084f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084fb:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801084fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108501:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108505:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108508:	88 50 02             	mov    %dl,0x2(%eax)
}
8010850b:	90                   	nop
8010850c:	c9                   	leave
8010850d:	c3                   	ret

8010850e <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010850e:	f3 0f 1e fb          	endbr32
80108512:	55                   	push   %ebp
80108513:	89 e5                	mov    %esp,%ebp
80108515:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108518:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010851e:	8b 45 08             	mov    0x8(%ebp),%eax
80108521:	0f af c2             	imul   %edx,%eax
80108524:	c1 e0 02             	shl    $0x2,%eax
80108527:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010852a:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108533:	29 c2                	sub    %eax,%edx
80108535:	89 d0                	mov    %edx,%eax
80108537:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010853d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108540:	01 ca                	add    %ecx,%edx
80108542:	89 d1                	mov    %edx,%ecx
80108544:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010854a:	83 ec 04             	sub    $0x4,%esp
8010854d:	50                   	push   %eax
8010854e:	51                   	push   %ecx
8010854f:	52                   	push   %edx
80108550:	e8 ac c8 ff ff       	call   80104e01 <memmove>
80108555:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855b:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108561:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108567:	01 d1                	add    %edx,%ecx
80108569:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010856c:	29 d1                	sub    %edx,%ecx
8010856e:	89 ca                	mov    %ecx,%edx
80108570:	83 ec 04             	sub    $0x4,%esp
80108573:	50                   	push   %eax
80108574:	6a 00                	push   $0x0
80108576:	52                   	push   %edx
80108577:	e8 be c7 ff ff       	call   80104d3a <memset>
8010857c:	83 c4 10             	add    $0x10,%esp
}
8010857f:	90                   	nop
80108580:	c9                   	leave
80108581:	c3                   	ret

80108582 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108582:	f3 0f 1e fb          	endbr32
80108586:	55                   	push   %ebp
80108587:	89 e5                	mov    %esp,%ebp
80108589:	53                   	push   %ebx
8010858a:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010858d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108594:	e9 b1 00 00 00       	jmp    8010864a <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108599:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801085a0:	e9 97 00 00 00       	jmp    8010863c <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801085a5:	8b 45 10             	mov    0x10(%ebp),%eax
801085a8:	83 e8 20             	sub    $0x20,%eax
801085ab:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b1:	01 d0                	add    %edx,%eax
801085b3:	0f b7 84 00 c0 af 10 	movzwl -0x7fef5040(%eax,%eax,1),%eax
801085ba:	80 
801085bb:	0f b7 d0             	movzwl %ax,%edx
801085be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c1:	bb 01 00 00 00       	mov    $0x1,%ebx
801085c6:	89 c1                	mov    %eax,%ecx
801085c8:	d3 e3                	shl    %cl,%ebx
801085ca:	89 d8                	mov    %ebx,%eax
801085cc:	21 d0                	and    %edx,%eax
801085ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801085d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d4:	ba 01 00 00 00       	mov    $0x1,%edx
801085d9:	89 c1                	mov    %eax,%ecx
801085db:	d3 e2                	shl    %cl,%edx
801085dd:	89 d0                	mov    %edx,%eax
801085df:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801085e2:	75 2b                	jne    8010860f <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801085e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801085e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ea:	01 c2                	add    %eax,%edx
801085ec:	b8 0e 00 00 00       	mov    $0xe,%eax
801085f1:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085f4:	89 c1                	mov    %eax,%ecx
801085f6:	8b 45 08             	mov    0x8(%ebp),%eax
801085f9:	01 c8                	add    %ecx,%eax
801085fb:	83 ec 04             	sub    $0x4,%esp
801085fe:	68 e0 f4 10 80       	push   $0x8010f4e0
80108603:	52                   	push   %edx
80108604:	50                   	push   %eax
80108605:	e8 ad fe ff ff       	call   801084b7 <graphic_draw_pixel>
8010860a:	83 c4 10             	add    $0x10,%esp
8010860d:	eb 29                	jmp    80108638 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010860f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108615:	01 c2                	add    %eax,%edx
80108617:	b8 0e 00 00 00       	mov    $0xe,%eax
8010861c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010861f:	89 c1                	mov    %eax,%ecx
80108621:	8b 45 08             	mov    0x8(%ebp),%eax
80108624:	01 c8                	add    %ecx,%eax
80108626:	83 ec 04             	sub    $0x4,%esp
80108629:	68 64 d0 18 80       	push   $0x8018d064
8010862e:	52                   	push   %edx
8010862f:	50                   	push   %eax
80108630:	e8 82 fe ff ff       	call   801084b7 <graphic_draw_pixel>
80108635:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108638:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010863c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108640:	0f 89 5f ff ff ff    	jns    801085a5 <font_render+0x23>
  for(int i=0;i<30;i++){
80108646:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010864a:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010864e:	0f 8e 45 ff ff ff    	jle    80108599 <font_render+0x17>
      }
    }
  }
}
80108654:	90                   	nop
80108655:	90                   	nop
80108656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108659:	c9                   	leave
8010865a:	c3                   	ret

8010865b <font_render_string>:

void font_render_string(char *string,int row){
8010865b:	f3 0f 1e fb          	endbr32
8010865f:	55                   	push   %ebp
80108660:	89 e5                	mov    %esp,%ebp
80108662:	53                   	push   %ebx
80108663:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108666:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010866d:	eb 33                	jmp    801086a2 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010866f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108672:	8b 45 08             	mov    0x8(%ebp),%eax
80108675:	01 d0                	add    %edx,%eax
80108677:	0f b6 00             	movzbl (%eax),%eax
8010867a:	0f be d8             	movsbl %al,%ebx
8010867d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108680:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108686:	89 d0                	mov    %edx,%eax
80108688:	c1 e0 04             	shl    $0x4,%eax
8010868b:	29 d0                	sub    %edx,%eax
8010868d:	83 c0 02             	add    $0x2,%eax
80108690:	83 ec 04             	sub    $0x4,%esp
80108693:	53                   	push   %ebx
80108694:	51                   	push   %ecx
80108695:	50                   	push   %eax
80108696:	e8 e7 fe ff ff       	call   80108582 <font_render>
8010869b:	83 c4 10             	add    $0x10,%esp
    i++;
8010869e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801086a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086a5:	8b 45 08             	mov    0x8(%ebp),%eax
801086a8:	01 d0                	add    %edx,%eax
801086aa:	0f b6 00             	movzbl (%eax),%eax
801086ad:	84 c0                	test   %al,%al
801086af:	74 06                	je     801086b7 <font_render_string+0x5c>
801086b1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801086b5:	7e b8                	jle    8010866f <font_render_string+0x14>
  }
}
801086b7:	90                   	nop
801086b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086bb:	c9                   	leave
801086bc:	c3                   	ret

801086bd <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801086bd:	f3 0f 1e fb          	endbr32
801086c1:	55                   	push   %ebp
801086c2:	89 e5                	mov    %esp,%ebp
801086c4:	53                   	push   %ebx
801086c5:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801086c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086cf:	eb 6b                	jmp    8010873c <pci_init+0x7f>
    for(int j=0;j<32;j++){
801086d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801086d8:	eb 58                	jmp    80108732 <pci_init+0x75>
      for(int k=0;k<8;k++){
801086da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801086e1:	eb 45                	jmp    80108728 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801086e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ec:	83 ec 0c             	sub    $0xc,%esp
801086ef:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801086f2:	53                   	push   %ebx
801086f3:	6a 00                	push   $0x0
801086f5:	51                   	push   %ecx
801086f6:	52                   	push   %edx
801086f7:	50                   	push   %eax
801086f8:	e8 c0 00 00 00       	call   801087bd <pci_access_config>
801086fd:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108700:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108703:	0f b7 c0             	movzwl %ax,%eax
80108706:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010870b:	74 17                	je     80108724 <pci_init+0x67>
        pci_init_device(i,j,k);
8010870d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108710:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	83 ec 04             	sub    $0x4,%esp
80108719:	51                   	push   %ecx
8010871a:	52                   	push   %edx
8010871b:	50                   	push   %eax
8010871c:	e8 4f 01 00 00       	call   80108870 <pci_init_device>
80108721:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108724:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108728:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010872c:	7e b5                	jle    801086e3 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010872e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108732:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108736:	7e a2                	jle    801086da <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108738:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010873c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108743:	7e 8c                	jle    801086d1 <pci_init+0x14>
      }
      }
    }
  }
}
80108745:	90                   	nop
80108746:	90                   	nop
80108747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010874a:	c9                   	leave
8010874b:	c3                   	ret

8010874c <pci_write_config>:

void pci_write_config(uint config){
8010874c:	f3 0f 1e fb          	endbr32
80108750:	55                   	push   %ebp
80108751:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108753:	8b 45 08             	mov    0x8(%ebp),%eax
80108756:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010875b:	89 c0                	mov    %eax,%eax
8010875d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010875e:	90                   	nop
8010875f:	5d                   	pop    %ebp
80108760:	c3                   	ret

80108761 <pci_write_data>:

void pci_write_data(uint config){
80108761:	f3 0f 1e fb          	endbr32
80108765:	55                   	push   %ebp
80108766:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108768:	8b 45 08             	mov    0x8(%ebp),%eax
8010876b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108770:	89 c0                	mov    %eax,%eax
80108772:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108773:	90                   	nop
80108774:	5d                   	pop    %ebp
80108775:	c3                   	ret

80108776 <pci_read_config>:
uint pci_read_config(){
80108776:	f3 0f 1e fb          	endbr32
8010877a:	55                   	push   %ebp
8010877b:	89 e5                	mov    %esp,%ebp
8010877d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108780:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108785:	ed                   	in     (%dx),%eax
80108786:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108789:	83 ec 0c             	sub    $0xc,%esp
8010878c:	68 c8 00 00 00       	push   $0xc8
80108791:	e8 1c a5 ff ff       	call   80102cb2 <microdelay>
80108796:	83 c4 10             	add    $0x10,%esp
  return data;
80108799:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010879c:	c9                   	leave
8010879d:	c3                   	ret

8010879e <pci_test>:


void pci_test(){
8010879e:	f3 0f 1e fb          	endbr32
801087a2:	55                   	push   %ebp
801087a3:	89 e5                	mov    %esp,%ebp
801087a5:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801087a8:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801087af:	ff 75 fc             	push   -0x4(%ebp)
801087b2:	e8 95 ff ff ff       	call   8010874c <pci_write_config>
801087b7:	83 c4 04             	add    $0x4,%esp
}
801087ba:	90                   	nop
801087bb:	c9                   	leave
801087bc:	c3                   	ret

801087bd <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801087bd:	f3 0f 1e fb          	endbr32
801087c1:	55                   	push   %ebp
801087c2:	89 e5                	mov    %esp,%ebp
801087c4:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087c7:	8b 45 08             	mov    0x8(%ebp),%eax
801087ca:	c1 e0 10             	shl    $0x10,%eax
801087cd:	25 00 00 ff 00       	and    $0xff0000,%eax
801087d2:	89 c2                	mov    %eax,%edx
801087d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d7:	c1 e0 0b             	shl    $0xb,%eax
801087da:	0f b7 c0             	movzwl %ax,%eax
801087dd:	09 c2                	or     %eax,%edx
801087df:	8b 45 10             	mov    0x10(%ebp),%eax
801087e2:	c1 e0 08             	shl    $0x8,%eax
801087e5:	25 00 07 00 00       	and    $0x700,%eax
801087ea:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087ec:	8b 45 14             	mov    0x14(%ebp),%eax
801087ef:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087f4:	09 d0                	or     %edx,%eax
801087f6:	0d 00 00 00 80       	or     $0x80000000,%eax
801087fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801087fe:	ff 75 f4             	push   -0xc(%ebp)
80108801:	e8 46 ff ff ff       	call   8010874c <pci_write_config>
80108806:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108809:	e8 68 ff ff ff       	call   80108776 <pci_read_config>
8010880e:	8b 55 18             	mov    0x18(%ebp),%edx
80108811:	89 02                	mov    %eax,(%edx)
}
80108813:	90                   	nop
80108814:	c9                   	leave
80108815:	c3                   	ret

80108816 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108816:	f3 0f 1e fb          	endbr32
8010881a:	55                   	push   %ebp
8010881b:	89 e5                	mov    %esp,%ebp
8010881d:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108820:	8b 45 08             	mov    0x8(%ebp),%eax
80108823:	c1 e0 10             	shl    $0x10,%eax
80108826:	25 00 00 ff 00       	and    $0xff0000,%eax
8010882b:	89 c2                	mov    %eax,%edx
8010882d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108830:	c1 e0 0b             	shl    $0xb,%eax
80108833:	0f b7 c0             	movzwl %ax,%eax
80108836:	09 c2                	or     %eax,%edx
80108838:	8b 45 10             	mov    0x10(%ebp),%eax
8010883b:	c1 e0 08             	shl    $0x8,%eax
8010883e:	25 00 07 00 00       	and    $0x700,%eax
80108843:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108845:	8b 45 14             	mov    0x14(%ebp),%eax
80108848:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010884d:	09 d0                	or     %edx,%eax
8010884f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108854:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108857:	ff 75 fc             	push   -0x4(%ebp)
8010885a:	e8 ed fe ff ff       	call   8010874c <pci_write_config>
8010885f:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108862:	ff 75 18             	push   0x18(%ebp)
80108865:	e8 f7 fe ff ff       	call   80108761 <pci_write_data>
8010886a:	83 c4 04             	add    $0x4,%esp
}
8010886d:	90                   	nop
8010886e:	c9                   	leave
8010886f:	c3                   	ret

80108870 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108870:	f3 0f 1e fb          	endbr32
80108874:	55                   	push   %ebp
80108875:	89 e5                	mov    %esp,%ebp
80108877:	53                   	push   %ebx
80108878:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010887b:	8b 45 08             	mov    0x8(%ebp),%eax
8010887e:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108883:	8b 45 0c             	mov    0xc(%ebp),%eax
80108886:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
8010888b:	8b 45 10             	mov    0x10(%ebp),%eax
8010888e:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108893:	ff 75 10             	push   0x10(%ebp)
80108896:	ff 75 0c             	push   0xc(%ebp)
80108899:	ff 75 08             	push   0x8(%ebp)
8010889c:	68 04 c6 10 80       	push   $0x8010c604
801088a1:	e8 66 7b ff ff       	call   8010040c <cprintf>
801088a6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801088a9:	83 ec 0c             	sub    $0xc,%esp
801088ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088af:	50                   	push   %eax
801088b0:	6a 00                	push   $0x0
801088b2:	ff 75 10             	push   0x10(%ebp)
801088b5:	ff 75 0c             	push   0xc(%ebp)
801088b8:	ff 75 08             	push   0x8(%ebp)
801088bb:	e8 fd fe ff ff       	call   801087bd <pci_access_config>
801088c0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801088c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c6:	c1 e8 10             	shr    $0x10,%eax
801088c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801088cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088cf:	25 ff ff 00 00       	and    $0xffff,%eax
801088d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801088d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088da:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801088df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e2:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801088e7:	83 ec 04             	sub    $0x4,%esp
801088ea:	ff 75 f0             	push   -0x10(%ebp)
801088ed:	ff 75 f4             	push   -0xc(%ebp)
801088f0:	68 38 c6 10 80       	push   $0x8010c638
801088f5:	e8 12 7b ff ff       	call   8010040c <cprintf>
801088fa:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801088fd:	83 ec 0c             	sub    $0xc,%esp
80108900:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108903:	50                   	push   %eax
80108904:	6a 08                	push   $0x8
80108906:	ff 75 10             	push   0x10(%ebp)
80108909:	ff 75 0c             	push   0xc(%ebp)
8010890c:	ff 75 08             	push   0x8(%ebp)
8010890f:	e8 a9 fe ff ff       	call   801087bd <pci_access_config>
80108914:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108917:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010891a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010891d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108920:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108923:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108926:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108929:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010892c:	0f b6 c0             	movzbl %al,%eax
8010892f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108932:	c1 eb 18             	shr    $0x18,%ebx
80108935:	83 ec 0c             	sub    $0xc,%esp
80108938:	51                   	push   %ecx
80108939:	52                   	push   %edx
8010893a:	50                   	push   %eax
8010893b:	53                   	push   %ebx
8010893c:	68 5c c6 10 80       	push   $0x8010c65c
80108941:	e8 c6 7a ff ff       	call   8010040c <cprintf>
80108946:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108949:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894c:	c1 e8 18             	shr    $0x18,%eax
8010894f:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
80108954:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108957:	c1 e8 10             	shr    $0x10,%eax
8010895a:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
8010895f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108962:	c1 e8 08             	shr    $0x8,%eax
80108965:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
8010896a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896d:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108972:	83 ec 0c             	sub    $0xc,%esp
80108975:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108978:	50                   	push   %eax
80108979:	6a 10                	push   $0x10
8010897b:	ff 75 10             	push   0x10(%ebp)
8010897e:	ff 75 0c             	push   0xc(%ebp)
80108981:	ff 75 08             	push   0x8(%ebp)
80108984:	e8 34 fe ff ff       	call   801087bd <pci_access_config>
80108989:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010898c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898f:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108994:	83 ec 0c             	sub    $0xc,%esp
80108997:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010899a:	50                   	push   %eax
8010899b:	6a 14                	push   $0x14
8010899d:	ff 75 10             	push   0x10(%ebp)
801089a0:	ff 75 0c             	push   0xc(%ebp)
801089a3:	ff 75 08             	push   0x8(%ebp)
801089a6:	e8 12 fe ff ff       	call   801087bd <pci_access_config>
801089ab:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801089ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b1:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089b6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801089bd:	75 5a                	jne    80108a19 <pci_init_device+0x1a9>
801089bf:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801089c6:	75 51                	jne    80108a19 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801089c8:	83 ec 0c             	sub    $0xc,%esp
801089cb:	68 a1 c6 10 80       	push   $0x8010c6a1
801089d0:	e8 37 7a ff ff       	call   8010040c <cprintf>
801089d5:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801089d8:	83 ec 0c             	sub    $0xc,%esp
801089db:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089de:	50                   	push   %eax
801089df:	68 f0 00 00 00       	push   $0xf0
801089e4:	ff 75 10             	push   0x10(%ebp)
801089e7:	ff 75 0c             	push   0xc(%ebp)
801089ea:	ff 75 08             	push   0x8(%ebp)
801089ed:	e8 cb fd ff ff       	call   801087bd <pci_access_config>
801089f2:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801089f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f8:	83 ec 08             	sub    $0x8,%esp
801089fb:	50                   	push   %eax
801089fc:	68 bb c6 10 80       	push   $0x8010c6bb
80108a01:	e8 06 7a ff ff       	call   8010040c <cprintf>
80108a06:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108a09:	83 ec 0c             	sub    $0xc,%esp
80108a0c:	68 9c 80 19 80       	push   $0x8019809c
80108a11:	e8 09 00 00 00       	call   80108a1f <i8254_init>
80108a16:	83 c4 10             	add    $0x10,%esp
  }
}
80108a19:	90                   	nop
80108a1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a1d:	c9                   	leave
80108a1e:	c3                   	ret

80108a1f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a1f:	f3 0f 1e fb          	endbr32
80108a23:	55                   	push   %ebp
80108a24:	89 e5                	mov    %esp,%ebp
80108a26:	53                   	push   %ebx
80108a27:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a2d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a31:	0f b6 c8             	movzbl %al,%ecx
80108a34:	8b 45 08             	mov    0x8(%ebp),%eax
80108a37:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a3b:	0f b6 d0             	movzbl %al,%edx
80108a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a41:	0f b6 00             	movzbl (%eax),%eax
80108a44:	0f b6 c0             	movzbl %al,%eax
80108a47:	83 ec 0c             	sub    $0xc,%esp
80108a4a:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a4d:	53                   	push   %ebx
80108a4e:	6a 04                	push   $0x4
80108a50:	51                   	push   %ecx
80108a51:	52                   	push   %edx
80108a52:	50                   	push   %eax
80108a53:	e8 65 fd ff ff       	call   801087bd <pci_access_config>
80108a58:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a5e:	83 c8 04             	or     $0x4,%eax
80108a61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a64:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a67:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a6e:	0f b6 c8             	movzbl %al,%ecx
80108a71:	8b 45 08             	mov    0x8(%ebp),%eax
80108a74:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a78:	0f b6 d0             	movzbl %al,%edx
80108a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7e:	0f b6 00             	movzbl (%eax),%eax
80108a81:	0f b6 c0             	movzbl %al,%eax
80108a84:	83 ec 0c             	sub    $0xc,%esp
80108a87:	53                   	push   %ebx
80108a88:	6a 04                	push   $0x4
80108a8a:	51                   	push   %ecx
80108a8b:	52                   	push   %edx
80108a8c:	50                   	push   %eax
80108a8d:	e8 84 fd ff ff       	call   80108816 <pci_write_config_register>
80108a92:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a95:	8b 45 08             	mov    0x8(%ebp),%eax
80108a98:	8b 40 10             	mov    0x10(%eax),%eax
80108a9b:	05 00 00 00 40       	add    $0x40000000,%eax
80108aa0:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108aa5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108aad:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ab2:	05 d8 00 00 00       	add    $0xd8,%eax
80108ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108abd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac6:	8b 00                	mov    (%eax),%eax
80108ac8:	0d 00 00 00 04       	or     $0x4000000,%eax
80108acd:	89 c2                	mov    %eax,%edx
80108acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad2:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad7:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae0:	8b 00                	mov    (%eax),%eax
80108ae2:	83 c8 40             	or     $0x40,%eax
80108ae5:	89 c2                	mov    %eax,%edx
80108ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aea:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aef:	8b 10                	mov    (%eax),%edx
80108af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af4:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108af6:	83 ec 0c             	sub    $0xc,%esp
80108af9:	68 d0 c6 10 80       	push   $0x8010c6d0
80108afe:	e8 09 79 ff ff       	call   8010040c <cprintf>
80108b03:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108b06:	e8 f5 9d ff ff       	call   80102900 <kalloc>
80108b0b:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
80108b10:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b1b:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b20:	83 ec 08             	sub    $0x8,%esp
80108b23:	50                   	push   %eax
80108b24:	68 f2 c6 10 80       	push   $0x8010c6f2
80108b29:	e8 de 78 ff ff       	call   8010040c <cprintf>
80108b2e:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b31:	e8 50 00 00 00       	call   80108b86 <i8254_init_recv>
  i8254_init_send();
80108b36:	e8 6d 03 00 00       	call   80108ea8 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b3b:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b42:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b45:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b4c:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b4f:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b56:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b59:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b60:	0f b6 c0             	movzbl %al,%eax
80108b63:	83 ec 0c             	sub    $0xc,%esp
80108b66:	53                   	push   %ebx
80108b67:	51                   	push   %ecx
80108b68:	52                   	push   %edx
80108b69:	50                   	push   %eax
80108b6a:	68 00 c7 10 80       	push   $0x8010c700
80108b6f:	e8 98 78 ff ff       	call   8010040c <cprintf>
80108b74:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b80:	90                   	nop
80108b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b84:	c9                   	leave
80108b85:	c3                   	ret

80108b86 <i8254_init_recv>:

void i8254_init_recv(){
80108b86:	f3 0f 1e fb          	endbr32
80108b8a:	55                   	push   %ebp
80108b8b:	89 e5                	mov    %esp,%ebp
80108b8d:	57                   	push   %edi
80108b8e:	56                   	push   %esi
80108b8f:	53                   	push   %ebx
80108b90:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b93:	83 ec 0c             	sub    $0xc,%esp
80108b96:	6a 00                	push   $0x0
80108b98:	e8 ec 04 00 00       	call   80109089 <i8254_read_eeprom>
80108b9d:	83 c4 10             	add    $0x10,%esp
80108ba0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108ba3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ba6:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bae:	c1 e8 08             	shr    $0x8,%eax
80108bb1:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108bb6:	83 ec 0c             	sub    $0xc,%esp
80108bb9:	6a 01                	push   $0x1
80108bbb:	e8 c9 04 00 00       	call   80109089 <i8254_read_eeprom>
80108bc0:	83 c4 10             	add    $0x10,%esp
80108bc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108bc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bc9:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108bce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bd1:	c1 e8 08             	shr    $0x8,%eax
80108bd4:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108bd9:	83 ec 0c             	sub    $0xc,%esp
80108bdc:	6a 02                	push   $0x2
80108bde:	e8 a6 04 00 00       	call   80109089 <i8254_read_eeprom>
80108be3:	83 c4 10             	add    $0x10,%esp
80108be6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108be9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bec:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108bf1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bf4:	c1 e8 08             	shr    $0x8,%eax
80108bf7:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108bfc:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c03:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c06:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c0d:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108c10:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c17:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c1a:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c21:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c24:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c2b:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c2e:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c35:	0f b6 c0             	movzbl %al,%eax
80108c38:	83 ec 04             	sub    $0x4,%esp
80108c3b:	57                   	push   %edi
80108c3c:	56                   	push   %esi
80108c3d:	53                   	push   %ebx
80108c3e:	51                   	push   %ecx
80108c3f:	52                   	push   %edx
80108c40:	50                   	push   %eax
80108c41:	68 18 c7 10 80       	push   $0x8010c718
80108c46:	e8 c1 77 ff ff       	call   8010040c <cprintf>
80108c4b:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c4e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c53:	05 00 54 00 00       	add    $0x5400,%eax
80108c58:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c5b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c60:	05 04 54 00 00       	add    $0x5404,%eax
80108c65:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c6b:	c1 e0 10             	shl    $0x10,%eax
80108c6e:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c71:	89 c2                	mov    %eax,%edx
80108c73:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c76:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c78:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c7b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c80:	89 c2                	mov    %eax,%edx
80108c82:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c85:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c87:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c8c:	05 00 52 00 00       	add    $0x5200,%eax
80108c91:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c94:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c9b:	eb 19                	jmp    80108cb6 <i8254_init_recv+0x130>
    mta[i] = 0;
80108c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ca7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108caa:	01 d0                	add    %edx,%eax
80108cac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108cb2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108cb6:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108cba:	7e e1                	jle    80108c9d <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108cbc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cc1:	05 d0 00 00 00       	add    $0xd0,%eax
80108cc6:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cc9:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ccc:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108cd2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cd7:	05 c8 00 00 00       	add    $0xc8,%eax
80108cdc:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cdf:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ce2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ce8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ced:	05 28 28 00 00       	add    $0x2828,%eax
80108cf2:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108cf5:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108cf8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108cfe:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d03:	05 00 01 00 00       	add    $0x100,%eax
80108d08:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108d0b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d0e:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d14:	e8 e7 9b ff ff       	call   80102900 <kalloc>
80108d19:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d1c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d21:	05 00 28 00 00       	add    $0x2800,%eax
80108d26:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d29:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d2e:	05 04 28 00 00       	add    $0x2804,%eax
80108d33:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d36:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d3b:	05 08 28 00 00       	add    $0x2808,%eax
80108d40:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d43:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d48:	05 10 28 00 00       	add    $0x2810,%eax
80108d4d:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d50:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d55:	05 18 28 00 00       	add    $0x2818,%eax
80108d5a:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d5d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d60:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d66:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d69:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d6b:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d74:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d77:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d7d:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d86:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d89:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d8f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d92:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d95:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d9c:	eb 73                	jmp    80108e11 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da1:	c1 e0 04             	shl    $0x4,%eax
80108da4:	89 c2                	mov    %eax,%edx
80108da6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108da9:	01 d0                	add    %edx,%eax
80108dab:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db5:	c1 e0 04             	shl    $0x4,%eax
80108db8:	89 c2                	mov    %eax,%edx
80108dba:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dbd:	01 d0                	add    %edx,%eax
80108dbf:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc8:	c1 e0 04             	shl    $0x4,%eax
80108dcb:	89 c2                	mov    %eax,%edx
80108dcd:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dd0:	01 d0                	add    %edx,%eax
80108dd2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108dd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ddb:	c1 e0 04             	shl    $0x4,%eax
80108dde:	89 c2                	mov    %eax,%edx
80108de0:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de3:	01 d0                	add    %edx,%eax
80108de5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dec:	c1 e0 04             	shl    $0x4,%eax
80108def:	89 c2                	mov    %eax,%edx
80108df1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df4:	01 d0                	add    %edx,%eax
80108df6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dfd:	c1 e0 04             	shl    $0x4,%eax
80108e00:	89 c2                	mov    %eax,%edx
80108e02:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e05:	01 d0                	add    %edx,%eax
80108e07:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e0d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108e11:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e18:	7e 84                	jle    80108d9e <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e1a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e21:	eb 57                	jmp    80108e7a <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108e23:	e8 d8 9a ff ff       	call   80102900 <kalloc>
80108e28:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e2b:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e2f:	75 12                	jne    80108e43 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108e31:	83 ec 0c             	sub    $0xc,%esp
80108e34:	68 38 c7 10 80       	push   $0x8010c738
80108e39:	e8 ce 75 ff ff       	call   8010040c <cprintf>
80108e3e:	83 c4 10             	add    $0x10,%esp
      break;
80108e41:	eb 3d                	jmp    80108e80 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e46:	c1 e0 04             	shl    $0x4,%eax
80108e49:	89 c2                	mov    %eax,%edx
80108e4b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e4e:	01 d0                	add    %edx,%eax
80108e50:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e53:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e59:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e5e:	83 c0 01             	add    $0x1,%eax
80108e61:	c1 e0 04             	shl    $0x4,%eax
80108e64:	89 c2                	mov    %eax,%edx
80108e66:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e69:	01 d0                	add    %edx,%eax
80108e6b:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e6e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e74:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e76:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e7a:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e7e:	7e a3                	jle    80108e23 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108e80:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e83:	8b 00                	mov    (%eax),%eax
80108e85:	83 c8 02             	or     $0x2,%eax
80108e88:	89 c2                	mov    %eax,%edx
80108e8a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e8d:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e8f:	83 ec 0c             	sub    $0xc,%esp
80108e92:	68 58 c7 10 80       	push   $0x8010c758
80108e97:	e8 70 75 ff ff       	call   8010040c <cprintf>
80108e9c:	83 c4 10             	add    $0x10,%esp
}
80108e9f:	90                   	nop
80108ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ea3:	5b                   	pop    %ebx
80108ea4:	5e                   	pop    %esi
80108ea5:	5f                   	pop    %edi
80108ea6:	5d                   	pop    %ebp
80108ea7:	c3                   	ret

80108ea8 <i8254_init_send>:

void i8254_init_send(){
80108ea8:	f3 0f 1e fb          	endbr32
80108eac:	55                   	push   %ebp
80108ead:	89 e5                	mov    %esp,%ebp
80108eaf:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108eb2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eb7:	05 28 38 00 00       	add    $0x3828,%eax
80108ebc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ec2:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108ec8:	e8 33 9a ff ff       	call   80102900 <kalloc>
80108ecd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ed0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ed5:	05 00 38 00 00       	add    $0x3800,%eax
80108eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108edd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ee2:	05 04 38 00 00       	add    $0x3804,%eax
80108ee7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108eea:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eef:	05 08 38 00 00       	add    $0x3808,%eax
80108ef4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ef7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108efa:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f03:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108f0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f11:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f17:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f1c:	05 10 38 00 00       	add    $0x3810,%eax
80108f21:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f24:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f29:	05 18 38 00 00       	add    $0x3818,%eax
80108f2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f31:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f3a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f46:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f50:	e9 82 00 00 00       	jmp    80108fd7 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f58:	c1 e0 04             	shl    $0x4,%eax
80108f5b:	89 c2                	mov    %eax,%edx
80108f5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f60:	01 d0                	add    %edx,%eax
80108f62:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6c:	c1 e0 04             	shl    $0x4,%eax
80108f6f:	89 c2                	mov    %eax,%edx
80108f71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f74:	01 d0                	add    %edx,%eax
80108f76:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7f:	c1 e0 04             	shl    $0x4,%eax
80108f82:	89 c2                	mov    %eax,%edx
80108f84:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f87:	01 d0                	add    %edx,%eax
80108f89:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f90:	c1 e0 04             	shl    $0x4,%eax
80108f93:	89 c2                	mov    %eax,%edx
80108f95:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f98:	01 d0                	add    %edx,%eax
80108f9a:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa1:	c1 e0 04             	shl    $0x4,%eax
80108fa4:	89 c2                	mov    %eax,%edx
80108fa6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fa9:	01 d0                	add    %edx,%eax
80108fab:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb2:	c1 e0 04             	shl    $0x4,%eax
80108fb5:	89 c2                	mov    %eax,%edx
80108fb7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fba:	01 d0                	add    %edx,%eax
80108fbc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc3:	c1 e0 04             	shl    $0x4,%eax
80108fc6:	89 c2                	mov    %eax,%edx
80108fc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fcb:	01 d0                	add    %edx,%eax
80108fcd:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fd3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fd7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108fde:	0f 8e 71 ff ff ff    	jle    80108f55 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fe4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108feb:	eb 57                	jmp    80109044 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108fed:	e8 0e 99 ff ff       	call   80102900 <kalloc>
80108ff2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ff5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ff9:	75 12                	jne    8010900d <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108ffb:	83 ec 0c             	sub    $0xc,%esp
80108ffe:	68 38 c7 10 80       	push   $0x8010c738
80109003:	e8 04 74 ff ff       	call   8010040c <cprintf>
80109008:	83 c4 10             	add    $0x10,%esp
      break;
8010900b:	eb 3d                	jmp    8010904a <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010900d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109010:	c1 e0 04             	shl    $0x4,%eax
80109013:	89 c2                	mov    %eax,%edx
80109015:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109018:	01 d0                	add    %edx,%eax
8010901a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010901d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109023:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109028:	83 c0 01             	add    $0x1,%eax
8010902b:	c1 e0 04             	shl    $0x4,%eax
8010902e:	89 c2                	mov    %eax,%edx
80109030:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109033:	01 d0                	add    %edx,%eax
80109035:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109038:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010903e:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109040:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109044:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109048:	7e a3                	jle    80108fed <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010904a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010904f:	05 00 04 00 00       	add    $0x400,%eax
80109054:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109057:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010905a:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109060:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109065:	05 10 04 00 00       	add    $0x410,%eax
8010906a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010906d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109070:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109076:	83 ec 0c             	sub    $0xc,%esp
80109079:	68 78 c7 10 80       	push   $0x8010c778
8010907e:	e8 89 73 ff ff       	call   8010040c <cprintf>
80109083:	83 c4 10             	add    $0x10,%esp

}
80109086:	90                   	nop
80109087:	c9                   	leave
80109088:	c3                   	ret

80109089 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109089:	f3 0f 1e fb          	endbr32
8010908d:	55                   	push   %ebp
8010908e:	89 e5                	mov    %esp,%ebp
80109090:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109093:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109098:	83 c0 14             	add    $0x14,%eax
8010909b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010909e:	8b 45 08             	mov    0x8(%ebp),%eax
801090a1:	c1 e0 08             	shl    $0x8,%eax
801090a4:	0f b7 c0             	movzwl %ax,%eax
801090a7:	83 c8 01             	or     $0x1,%eax
801090aa:	89 c2                	mov    %eax,%edx
801090ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090af:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801090b1:	83 ec 0c             	sub    $0xc,%esp
801090b4:	68 98 c7 10 80       	push   $0x8010c798
801090b9:	e8 4e 73 ff ff       	call   8010040c <cprintf>
801090be:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c4:	8b 00                	mov    (%eax),%eax
801090c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090cc:	83 e0 10             	and    $0x10,%eax
801090cf:	85 c0                	test   %eax,%eax
801090d1:	75 02                	jne    801090d5 <i8254_read_eeprom+0x4c>
  while(1){
801090d3:	eb dc                	jmp    801090b1 <i8254_read_eeprom+0x28>
      break;
801090d5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801090d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d9:	8b 00                	mov    (%eax),%eax
801090db:	c1 e8 10             	shr    $0x10,%eax
}
801090de:	c9                   	leave
801090df:	c3                   	ret

801090e0 <i8254_recv>:
void i8254_recv(){
801090e0:	f3 0f 1e fb          	endbr32
801090e4:	55                   	push   %ebp
801090e5:	89 e5                	mov    %esp,%ebp
801090e7:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801090ea:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090ef:	05 10 28 00 00       	add    $0x2810,%eax
801090f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801090f7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090fc:	05 18 28 00 00       	add    $0x2818,%eax
80109101:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109104:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109109:	05 00 28 00 00       	add    $0x2800,%eax
8010910e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109111:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109114:	8b 00                	mov    (%eax),%eax
80109116:	05 00 00 00 80       	add    $0x80000000,%eax
8010911b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010911e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109121:	8b 10                	mov    (%eax),%edx
80109123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109126:	8b 00                	mov    (%eax),%eax
80109128:	29 c2                	sub    %eax,%edx
8010912a:	89 d0                	mov    %edx,%eax
8010912c:	25 ff 00 00 00       	and    $0xff,%eax
80109131:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109134:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109138:	7e 37                	jle    80109171 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010913a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913d:	8b 00                	mov    (%eax),%eax
8010913f:	c1 e0 04             	shl    $0x4,%eax
80109142:	89 c2                	mov    %eax,%edx
80109144:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109147:	01 d0                	add    %edx,%eax
80109149:	8b 00                	mov    (%eax),%eax
8010914b:	05 00 00 00 80       	add    $0x80000000,%eax
80109150:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109156:	8b 00                	mov    (%eax),%eax
80109158:	83 c0 01             	add    $0x1,%eax
8010915b:	0f b6 d0             	movzbl %al,%edx
8010915e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109161:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109163:	83 ec 0c             	sub    $0xc,%esp
80109166:	ff 75 e0             	push   -0x20(%ebp)
80109169:	e8 47 09 00 00       	call   80109ab5 <eth_proc>
8010916e:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109174:	8b 10                	mov    (%eax),%edx
80109176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109179:	8b 00                	mov    (%eax),%eax
8010917b:	39 c2                	cmp    %eax,%edx
8010917d:	75 9f                	jne    8010911e <i8254_recv+0x3e>
      (*rdt)--;
8010917f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109182:	8b 00                	mov    (%eax),%eax
80109184:	8d 50 ff             	lea    -0x1(%eax),%edx
80109187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918a:	89 10                	mov    %edx,(%eax)
  while(1){
8010918c:	eb 90                	jmp    8010911e <i8254_recv+0x3e>

8010918e <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010918e:	f3 0f 1e fb          	endbr32
80109192:	55                   	push   %ebp
80109193:	89 e5                	mov    %esp,%ebp
80109195:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109198:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010919d:	05 10 38 00 00       	add    $0x3810,%eax
801091a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801091a5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801091aa:	05 18 38 00 00       	add    $0x3818,%eax
801091af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091b2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801091b7:	05 00 38 00 00       	add    $0x3800,%eax
801091bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801091bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c2:	8b 00                	mov    (%eax),%eax
801091c4:	05 00 00 00 80       	add    $0x80000000,%eax
801091c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091cf:	8b 10                	mov    (%eax),%edx
801091d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d4:	8b 00                	mov    (%eax),%eax
801091d6:	29 c2                	sub    %eax,%edx
801091d8:	89 d0                	mov    %edx,%eax
801091da:	0f b6 c0             	movzbl %al,%eax
801091dd:	ba 00 01 00 00       	mov    $0x100,%edx
801091e2:	29 c2                	sub    %eax,%edx
801091e4:	89 d0                	mov    %edx,%eax
801091e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801091e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ec:	8b 00                	mov    (%eax),%eax
801091ee:	25 ff 00 00 00       	and    $0xff,%eax
801091f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801091f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091fa:	0f 8e a8 00 00 00    	jle    801092a8 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109200:	8b 45 08             	mov    0x8(%ebp),%eax
80109203:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109206:	89 d1                	mov    %edx,%ecx
80109208:	c1 e1 04             	shl    $0x4,%ecx
8010920b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010920e:	01 ca                	add    %ecx,%edx
80109210:	8b 12                	mov    (%edx),%edx
80109212:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109218:	83 ec 04             	sub    $0x4,%esp
8010921b:	ff 75 0c             	push   0xc(%ebp)
8010921e:	50                   	push   %eax
8010921f:	52                   	push   %edx
80109220:	e8 dc bb ff ff       	call   80104e01 <memmove>
80109225:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109228:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010922b:	c1 e0 04             	shl    $0x4,%eax
8010922e:	89 c2                	mov    %eax,%edx
80109230:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109233:	01 d0                	add    %edx,%eax
80109235:	8b 55 0c             	mov    0xc(%ebp),%edx
80109238:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010923c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010923f:	c1 e0 04             	shl    $0x4,%eax
80109242:	89 c2                	mov    %eax,%edx
80109244:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109247:	01 d0                	add    %edx,%eax
80109249:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010924d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109250:	c1 e0 04             	shl    $0x4,%eax
80109253:	89 c2                	mov    %eax,%edx
80109255:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109258:	01 d0                	add    %edx,%eax
8010925a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010925e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109261:	c1 e0 04             	shl    $0x4,%eax
80109264:	89 c2                	mov    %eax,%edx
80109266:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109269:	01 d0                	add    %edx,%eax
8010926b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010926f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109272:	c1 e0 04             	shl    $0x4,%eax
80109275:	89 c2                	mov    %eax,%edx
80109277:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927a:	01 d0                	add    %edx,%eax
8010927c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109282:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109285:	c1 e0 04             	shl    $0x4,%eax
80109288:	89 c2                	mov    %eax,%edx
8010928a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010928d:	01 d0                	add    %edx,%eax
8010928f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109293:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109296:	8b 00                	mov    (%eax),%eax
80109298:	83 c0 01             	add    $0x1,%eax
8010929b:	0f b6 d0             	movzbl %al,%edx
8010929e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a1:	89 10                	mov    %edx,(%eax)
    return len;
801092a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801092a6:	eb 05                	jmp    801092ad <i8254_send+0x11f>
  }else{
    return -1;
801092a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801092ad:	c9                   	leave
801092ae:	c3                   	ret

801092af <i8254_intr>:

void i8254_intr(){
801092af:	f3 0f 1e fb          	endbr32
801092b3:	55                   	push   %ebp
801092b4:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801092b6:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801092bb:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801092c1:	90                   	nop
801092c2:	5d                   	pop    %ebp
801092c3:	c3                   	ret

801092c4 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801092c4:	f3 0f 1e fb          	endbr32
801092c8:	55                   	push   %ebp
801092c9:	89 e5                	mov    %esp,%ebp
801092cb:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092ce:	8b 45 08             	mov    0x8(%ebp),%eax
801092d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d7:	0f b7 00             	movzwl (%eax),%eax
801092da:	66 3d 00 01          	cmp    $0x100,%ax
801092de:	74 0a                	je     801092ea <arp_proc+0x26>
801092e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092e5:	e9 4f 01 00 00       	jmp    80109439 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801092ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ed:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801092f1:	66 83 f8 08          	cmp    $0x8,%ax
801092f5:	74 0a                	je     80109301 <arp_proc+0x3d>
801092f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092fc:	e9 38 01 00 00       	jmp    80109439 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109304:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109308:	3c 06                	cmp    $0x6,%al
8010930a:	74 0a                	je     80109316 <arp_proc+0x52>
8010930c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109311:	e9 23 01 00 00       	jmp    80109439 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109319:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010931d:	3c 04                	cmp    $0x4,%al
8010931f:	74 0a                	je     8010932b <arp_proc+0x67>
80109321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109326:	e9 0e 01 00 00       	jmp    80109439 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010932b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932e:	83 c0 18             	add    $0x18,%eax
80109331:	83 ec 04             	sub    $0x4,%esp
80109334:	6a 04                	push   $0x4
80109336:	50                   	push   %eax
80109337:	68 e4 f4 10 80       	push   $0x8010f4e4
8010933c:	e8 64 ba ff ff       	call   80104da5 <memcmp>
80109341:	83 c4 10             	add    $0x10,%esp
80109344:	85 c0                	test   %eax,%eax
80109346:	74 27                	je     8010936f <arp_proc+0xab>
80109348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934b:	83 c0 0e             	add    $0xe,%eax
8010934e:	83 ec 04             	sub    $0x4,%esp
80109351:	6a 04                	push   $0x4
80109353:	50                   	push   %eax
80109354:	68 e4 f4 10 80       	push   $0x8010f4e4
80109359:	e8 47 ba ff ff       	call   80104da5 <memcmp>
8010935e:	83 c4 10             	add    $0x10,%esp
80109361:	85 c0                	test   %eax,%eax
80109363:	74 0a                	je     8010936f <arp_proc+0xab>
80109365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010936a:	e9 ca 00 00 00       	jmp    80109439 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010936f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109372:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109376:	66 3d 00 01          	cmp    $0x100,%ax
8010937a:	75 69                	jne    801093e5 <arp_proc+0x121>
8010937c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937f:	83 c0 18             	add    $0x18,%eax
80109382:	83 ec 04             	sub    $0x4,%esp
80109385:	6a 04                	push   $0x4
80109387:	50                   	push   %eax
80109388:	68 e4 f4 10 80       	push   $0x8010f4e4
8010938d:	e8 13 ba ff ff       	call   80104da5 <memcmp>
80109392:	83 c4 10             	add    $0x10,%esp
80109395:	85 c0                	test   %eax,%eax
80109397:	75 4c                	jne    801093e5 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109399:	e8 62 95 ff ff       	call   80102900 <kalloc>
8010939e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801093a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801093a8:	83 ec 04             	sub    $0x4,%esp
801093ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093ae:	50                   	push   %eax
801093af:	ff 75 f0             	push   -0x10(%ebp)
801093b2:	ff 75 f4             	push   -0xc(%ebp)
801093b5:	e8 33 04 00 00       	call   801097ed <arp_reply_pkt_create>
801093ba:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801093bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093c0:	83 ec 08             	sub    $0x8,%esp
801093c3:	50                   	push   %eax
801093c4:	ff 75 f0             	push   -0x10(%ebp)
801093c7:	e8 c2 fd ff ff       	call   8010918e <i8254_send>
801093cc:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d2:	83 ec 0c             	sub    $0xc,%esp
801093d5:	50                   	push   %eax
801093d6:	e8 87 94 ff ff       	call   80102862 <kfree>
801093db:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093de:	b8 02 00 00 00       	mov    $0x2,%eax
801093e3:	eb 54                	jmp    80109439 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093ec:	66 3d 00 02          	cmp    $0x200,%ax
801093f0:	75 42                	jne    80109434 <arp_proc+0x170>
801093f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f5:	83 c0 18             	add    $0x18,%eax
801093f8:	83 ec 04             	sub    $0x4,%esp
801093fb:	6a 04                	push   $0x4
801093fd:	50                   	push   %eax
801093fe:	68 e4 f4 10 80       	push   $0x8010f4e4
80109403:	e8 9d b9 ff ff       	call   80104da5 <memcmp>
80109408:	83 c4 10             	add    $0x10,%esp
8010940b:	85 c0                	test   %eax,%eax
8010940d:	75 25                	jne    80109434 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010940f:	83 ec 0c             	sub    $0xc,%esp
80109412:	68 9c c7 10 80       	push   $0x8010c79c
80109417:	e8 f0 6f ff ff       	call   8010040c <cprintf>
8010941c:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010941f:	83 ec 0c             	sub    $0xc,%esp
80109422:	ff 75 f4             	push   -0xc(%ebp)
80109425:	e8 b7 01 00 00       	call   801095e1 <arp_table_update>
8010942a:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010942d:	b8 01 00 00 00       	mov    $0x1,%eax
80109432:	eb 05                	jmp    80109439 <arp_proc+0x175>
  }else{
    return -1;
80109434:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109439:	c9                   	leave
8010943a:	c3                   	ret

8010943b <arp_scan>:

void arp_scan(){
8010943b:	f3 0f 1e fb          	endbr32
8010943f:	55                   	push   %ebp
80109440:	89 e5                	mov    %esp,%ebp
80109442:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010944c:	eb 6f                	jmp    801094bd <arp_scan+0x82>
    uint send = (uint)kalloc();
8010944e:	e8 ad 94 ff ff       	call   80102900 <kalloc>
80109453:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109456:	83 ec 04             	sub    $0x4,%esp
80109459:	ff 75 f4             	push   -0xc(%ebp)
8010945c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010945f:	50                   	push   %eax
80109460:	ff 75 ec             	push   -0x14(%ebp)
80109463:	e8 62 00 00 00       	call   801094ca <arp_broadcast>
80109468:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010946b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010946e:	83 ec 08             	sub    $0x8,%esp
80109471:	50                   	push   %eax
80109472:	ff 75 ec             	push   -0x14(%ebp)
80109475:	e8 14 fd ff ff       	call   8010918e <i8254_send>
8010947a:	83 c4 10             	add    $0x10,%esp
8010947d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109480:	eb 22                	jmp    801094a4 <arp_scan+0x69>
      microdelay(1);
80109482:	83 ec 0c             	sub    $0xc,%esp
80109485:	6a 01                	push   $0x1
80109487:	e8 26 98 ff ff       	call   80102cb2 <microdelay>
8010948c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010948f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109492:	83 ec 08             	sub    $0x8,%esp
80109495:	50                   	push   %eax
80109496:	ff 75 ec             	push   -0x14(%ebp)
80109499:	e8 f0 fc ff ff       	call   8010918e <i8254_send>
8010949e:	83 c4 10             	add    $0x10,%esp
801094a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094a4:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801094a8:	74 d8                	je     80109482 <arp_scan+0x47>
    }
    kfree((char *)send);
801094aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094ad:	83 ec 0c             	sub    $0xc,%esp
801094b0:	50                   	push   %eax
801094b1:	e8 ac 93 ff ff       	call   80102862 <kfree>
801094b6:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801094b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094bd:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094c4:	7e 88                	jle    8010944e <arp_scan+0x13>
  }
}
801094c6:	90                   	nop
801094c7:	90                   	nop
801094c8:	c9                   	leave
801094c9:	c3                   	ret

801094ca <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801094ca:	f3 0f 1e fb          	endbr32
801094ce:	55                   	push   %ebp
801094cf:	89 e5                	mov    %esp,%ebp
801094d1:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094d4:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094d8:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094dc:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094e0:	8b 45 10             	mov    0x10(%ebp),%eax
801094e3:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094e6:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801094ed:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801094f3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094fa:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109500:	8b 45 0c             	mov    0xc(%ebp),%eax
80109503:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109509:	8b 45 08             	mov    0x8(%ebp),%eax
8010950c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010950f:	8b 45 08             	mov    0x8(%ebp),%eax
80109512:	83 c0 0e             	add    $0xe,%eax
80109515:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010951f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109522:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109529:	83 ec 04             	sub    $0x4,%esp
8010952c:	6a 06                	push   $0x6
8010952e:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109531:	52                   	push   %edx
80109532:	50                   	push   %eax
80109533:	e8 c9 b8 ff ff       	call   80104e01 <memmove>
80109538:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010953b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953e:	83 c0 06             	add    $0x6,%eax
80109541:	83 ec 04             	sub    $0x4,%esp
80109544:	6a 06                	push   $0x6
80109546:	68 68 d0 18 80       	push   $0x8018d068
8010954b:	50                   	push   %eax
8010954c:	e8 b0 b8 ff ff       	call   80104e01 <memmove>
80109551:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109557:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010955c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010955f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109568:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010956c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109576:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010957c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010957f:	8d 50 12             	lea    0x12(%eax),%edx
80109582:	83 ec 04             	sub    $0x4,%esp
80109585:	6a 06                	push   $0x6
80109587:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010958a:	50                   	push   %eax
8010958b:	52                   	push   %edx
8010958c:	e8 70 b8 ff ff       	call   80104e01 <memmove>
80109591:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109597:	8d 50 18             	lea    0x18(%eax),%edx
8010959a:	83 ec 04             	sub    $0x4,%esp
8010959d:	6a 04                	push   $0x4
8010959f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095a2:	50                   	push   %eax
801095a3:	52                   	push   %edx
801095a4:	e8 58 b8 ff ff       	call   80104e01 <memmove>
801095a9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095af:	83 c0 08             	add    $0x8,%eax
801095b2:	83 ec 04             	sub    $0x4,%esp
801095b5:	6a 06                	push   $0x6
801095b7:	68 68 d0 18 80       	push   $0x8018d068
801095bc:	50                   	push   %eax
801095bd:	e8 3f b8 ff ff       	call   80104e01 <memmove>
801095c2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c8:	83 c0 0e             	add    $0xe,%eax
801095cb:	83 ec 04             	sub    $0x4,%esp
801095ce:	6a 04                	push   $0x4
801095d0:	68 e4 f4 10 80       	push   $0x8010f4e4
801095d5:	50                   	push   %eax
801095d6:	e8 26 b8 ff ff       	call   80104e01 <memmove>
801095db:	83 c4 10             	add    $0x10,%esp
}
801095de:	90                   	nop
801095df:	c9                   	leave
801095e0:	c3                   	ret

801095e1 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095e1:	f3 0f 1e fb          	endbr32
801095e5:	55                   	push   %ebp
801095e6:	89 e5                	mov    %esp,%ebp
801095e8:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095eb:	8b 45 08             	mov    0x8(%ebp),%eax
801095ee:	83 c0 0e             	add    $0xe,%eax
801095f1:	83 ec 0c             	sub    $0xc,%esp
801095f4:	50                   	push   %eax
801095f5:	e8 bc 00 00 00       	call   801096b6 <arp_table_search>
801095fa:	83 c4 10             	add    $0x10,%esp
801095fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109604:	78 2d                	js     80109633 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109606:	8b 45 08             	mov    0x8(%ebp),%eax
80109609:	8d 48 08             	lea    0x8(%eax),%ecx
8010960c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010960f:	89 d0                	mov    %edx,%eax
80109611:	c1 e0 02             	shl    $0x2,%eax
80109614:	01 d0                	add    %edx,%eax
80109616:	01 c0                	add    %eax,%eax
80109618:	01 d0                	add    %edx,%eax
8010961a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010961f:	83 c0 04             	add    $0x4,%eax
80109622:	83 ec 04             	sub    $0x4,%esp
80109625:	6a 06                	push   $0x6
80109627:	51                   	push   %ecx
80109628:	50                   	push   %eax
80109629:	e8 d3 b7 ff ff       	call   80104e01 <memmove>
8010962e:	83 c4 10             	add    $0x10,%esp
80109631:	eb 70                	jmp    801096a3 <arp_table_update+0xc2>
  }else{
    index += 1;
80109633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109637:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010963a:	8b 45 08             	mov    0x8(%ebp),%eax
8010963d:	8d 48 08             	lea    0x8(%eax),%ecx
80109640:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109643:	89 d0                	mov    %edx,%eax
80109645:	c1 e0 02             	shl    $0x2,%eax
80109648:	01 d0                	add    %edx,%eax
8010964a:	01 c0                	add    %eax,%eax
8010964c:	01 d0                	add    %edx,%eax
8010964e:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109653:	83 c0 04             	add    $0x4,%eax
80109656:	83 ec 04             	sub    $0x4,%esp
80109659:	6a 06                	push   $0x6
8010965b:	51                   	push   %ecx
8010965c:	50                   	push   %eax
8010965d:	e8 9f b7 ff ff       	call   80104e01 <memmove>
80109662:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109665:	8b 45 08             	mov    0x8(%ebp),%eax
80109668:	8d 48 0e             	lea    0xe(%eax),%ecx
8010966b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010966e:	89 d0                	mov    %edx,%eax
80109670:	c1 e0 02             	shl    $0x2,%eax
80109673:	01 d0                	add    %edx,%eax
80109675:	01 c0                	add    %eax,%eax
80109677:	01 d0                	add    %edx,%eax
80109679:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010967e:	83 ec 04             	sub    $0x4,%esp
80109681:	6a 04                	push   $0x4
80109683:	51                   	push   %ecx
80109684:	50                   	push   %eax
80109685:	e8 77 b7 ff ff       	call   80104e01 <memmove>
8010968a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010968d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109690:	89 d0                	mov    %edx,%eax
80109692:	c1 e0 02             	shl    $0x2,%eax
80109695:	01 d0                	add    %edx,%eax
80109697:	01 c0                	add    %eax,%eax
80109699:	01 d0                	add    %edx,%eax
8010969b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801096a0:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801096a3:	83 ec 0c             	sub    $0xc,%esp
801096a6:	68 80 d0 18 80       	push   $0x8018d080
801096ab:	e8 87 00 00 00       	call   80109737 <print_arp_table>
801096b0:	83 c4 10             	add    $0x10,%esp
}
801096b3:	90                   	nop
801096b4:	c9                   	leave
801096b5:	c3                   	ret

801096b6 <arp_table_search>:

int arp_table_search(uchar *ip){
801096b6:	f3 0f 1e fb          	endbr32
801096ba:	55                   	push   %ebp
801096bb:	89 e5                	mov    %esp,%ebp
801096bd:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801096c0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096ce:	eb 59                	jmp    80109729 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801096d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096d3:	89 d0                	mov    %edx,%eax
801096d5:	c1 e0 02             	shl    $0x2,%eax
801096d8:	01 d0                	add    %edx,%eax
801096da:	01 c0                	add    %eax,%eax
801096dc:	01 d0                	add    %edx,%eax
801096de:	05 80 d0 18 80       	add    $0x8018d080,%eax
801096e3:	83 ec 04             	sub    $0x4,%esp
801096e6:	6a 04                	push   $0x4
801096e8:	ff 75 08             	push   0x8(%ebp)
801096eb:	50                   	push   %eax
801096ec:	e8 b4 b6 ff ff       	call   80104da5 <memcmp>
801096f1:	83 c4 10             	add    $0x10,%esp
801096f4:	85 c0                	test   %eax,%eax
801096f6:	75 05                	jne    801096fd <arp_table_search+0x47>
      return i;
801096f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096fb:	eb 38                	jmp    80109735 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801096fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109700:	89 d0                	mov    %edx,%eax
80109702:	c1 e0 02             	shl    $0x2,%eax
80109705:	01 d0                	add    %edx,%eax
80109707:	01 c0                	add    %eax,%eax
80109709:	01 d0                	add    %edx,%eax
8010970b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109710:	0f b6 00             	movzbl (%eax),%eax
80109713:	84 c0                	test   %al,%al
80109715:	75 0e                	jne    80109725 <arp_table_search+0x6f>
80109717:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010971b:	75 08                	jne    80109725 <arp_table_search+0x6f>
      empty = -i;
8010971d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109720:	f7 d8                	neg    %eax
80109722:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109725:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109729:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010972d:	7e a1                	jle    801096d0 <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010972f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109732:	83 e8 01             	sub    $0x1,%eax
}
80109735:	c9                   	leave
80109736:	c3                   	ret

80109737 <print_arp_table>:

void print_arp_table(){
80109737:	f3 0f 1e fb          	endbr32
8010973b:	55                   	push   %ebp
8010973c:	89 e5                	mov    %esp,%ebp
8010973e:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109748:	e9 92 00 00 00       	jmp    801097df <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010974d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109750:	89 d0                	mov    %edx,%eax
80109752:	c1 e0 02             	shl    $0x2,%eax
80109755:	01 d0                	add    %edx,%eax
80109757:	01 c0                	add    %eax,%eax
80109759:	01 d0                	add    %edx,%eax
8010975b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109760:	0f b6 00             	movzbl (%eax),%eax
80109763:	84 c0                	test   %al,%al
80109765:	74 74                	je     801097db <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109767:	83 ec 08             	sub    $0x8,%esp
8010976a:	ff 75 f4             	push   -0xc(%ebp)
8010976d:	68 af c7 10 80       	push   $0x8010c7af
80109772:	e8 95 6c ff ff       	call   8010040c <cprintf>
80109777:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010977a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010977d:	89 d0                	mov    %edx,%eax
8010977f:	c1 e0 02             	shl    $0x2,%eax
80109782:	01 d0                	add    %edx,%eax
80109784:	01 c0                	add    %eax,%eax
80109786:	01 d0                	add    %edx,%eax
80109788:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010978d:	83 ec 0c             	sub    $0xc,%esp
80109790:	50                   	push   %eax
80109791:	e8 5c 02 00 00       	call   801099f2 <print_ipv4>
80109796:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109799:	83 ec 0c             	sub    $0xc,%esp
8010979c:	68 be c7 10 80       	push   $0x8010c7be
801097a1:	e8 66 6c ff ff       	call   8010040c <cprintf>
801097a6:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801097a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097ac:	89 d0                	mov    %edx,%eax
801097ae:	c1 e0 02             	shl    $0x2,%eax
801097b1:	01 d0                	add    %edx,%eax
801097b3:	01 c0                	add    %eax,%eax
801097b5:	01 d0                	add    %edx,%eax
801097b7:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097bc:	83 c0 04             	add    $0x4,%eax
801097bf:	83 ec 0c             	sub    $0xc,%esp
801097c2:	50                   	push   %eax
801097c3:	e8 7c 02 00 00       	call   80109a44 <print_mac>
801097c8:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801097cb:	83 ec 0c             	sub    $0xc,%esp
801097ce:	68 c0 c7 10 80       	push   $0x8010c7c0
801097d3:	e8 34 6c ff ff       	call   8010040c <cprintf>
801097d8:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097df:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097e3:	0f 8e 64 ff ff ff    	jle    8010974d <print_arp_table+0x16>
    }
  }
}
801097e9:	90                   	nop
801097ea:	90                   	nop
801097eb:	c9                   	leave
801097ec:	c3                   	ret

801097ed <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097ed:	f3 0f 1e fb          	endbr32
801097f1:	55                   	push   %ebp
801097f2:	89 e5                	mov    %esp,%ebp
801097f4:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097f7:	8b 45 10             	mov    0x10(%ebp),%eax
801097fa:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109800:	8b 45 0c             	mov    0xc(%ebp),%eax
80109803:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109806:	8b 45 0c             	mov    0xc(%ebp),%eax
80109809:	83 c0 0e             	add    $0xe,%eax
8010980c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010980f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109812:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109819:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010981d:	8b 45 08             	mov    0x8(%ebp),%eax
80109820:	8d 50 08             	lea    0x8(%eax),%edx
80109823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109826:	83 ec 04             	sub    $0x4,%esp
80109829:	6a 06                	push   $0x6
8010982b:	52                   	push   %edx
8010982c:	50                   	push   %eax
8010982d:	e8 cf b5 ff ff       	call   80104e01 <memmove>
80109832:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109838:	83 c0 06             	add    $0x6,%eax
8010983b:	83 ec 04             	sub    $0x4,%esp
8010983e:	6a 06                	push   $0x6
80109840:	68 68 d0 18 80       	push   $0x8018d068
80109845:	50                   	push   %eax
80109846:	e8 b6 b5 ff ff       	call   80104e01 <memmove>
8010984b:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010984e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109851:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109859:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010985f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109862:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109869:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010986d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109870:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109876:	8b 45 08             	mov    0x8(%ebp),%eax
80109879:	8d 50 08             	lea    0x8(%eax),%edx
8010987c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987f:	83 c0 12             	add    $0x12,%eax
80109882:	83 ec 04             	sub    $0x4,%esp
80109885:	6a 06                	push   $0x6
80109887:	52                   	push   %edx
80109888:	50                   	push   %eax
80109889:	e8 73 b5 ff ff       	call   80104e01 <memmove>
8010988e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109891:	8b 45 08             	mov    0x8(%ebp),%eax
80109894:	8d 50 0e             	lea    0xe(%eax),%edx
80109897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989a:	83 c0 18             	add    $0x18,%eax
8010989d:	83 ec 04             	sub    $0x4,%esp
801098a0:	6a 04                	push   $0x4
801098a2:	52                   	push   %edx
801098a3:	50                   	push   %eax
801098a4:	e8 58 b5 ff ff       	call   80104e01 <memmove>
801098a9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801098ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098af:	83 c0 08             	add    $0x8,%eax
801098b2:	83 ec 04             	sub    $0x4,%esp
801098b5:	6a 06                	push   $0x6
801098b7:	68 68 d0 18 80       	push   $0x8018d068
801098bc:	50                   	push   %eax
801098bd:	e8 3f b5 ff ff       	call   80104e01 <memmove>
801098c2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c8:	83 c0 0e             	add    $0xe,%eax
801098cb:	83 ec 04             	sub    $0x4,%esp
801098ce:	6a 04                	push   $0x4
801098d0:	68 e4 f4 10 80       	push   $0x8010f4e4
801098d5:	50                   	push   %eax
801098d6:	e8 26 b5 ff ff       	call   80104e01 <memmove>
801098db:	83 c4 10             	add    $0x10,%esp
}
801098de:	90                   	nop
801098df:	c9                   	leave
801098e0:	c3                   	ret

801098e1 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801098e1:	f3 0f 1e fb          	endbr32
801098e5:	55                   	push   %ebp
801098e6:	89 e5                	mov    %esp,%ebp
801098e8:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098eb:	83 ec 0c             	sub    $0xc,%esp
801098ee:	68 c2 c7 10 80       	push   $0x8010c7c2
801098f3:	e8 14 6b ff ff       	call   8010040c <cprintf>
801098f8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098fb:	8b 45 08             	mov    0x8(%ebp),%eax
801098fe:	83 c0 0e             	add    $0xe,%eax
80109901:	83 ec 0c             	sub    $0xc,%esp
80109904:	50                   	push   %eax
80109905:	e8 e8 00 00 00       	call   801099f2 <print_ipv4>
8010990a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010990d:	83 ec 0c             	sub    $0xc,%esp
80109910:	68 c0 c7 10 80       	push   $0x8010c7c0
80109915:	e8 f2 6a ff ff       	call   8010040c <cprintf>
8010991a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010991d:	8b 45 08             	mov    0x8(%ebp),%eax
80109920:	83 c0 08             	add    $0x8,%eax
80109923:	83 ec 0c             	sub    $0xc,%esp
80109926:	50                   	push   %eax
80109927:	e8 18 01 00 00       	call   80109a44 <print_mac>
8010992c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010992f:	83 ec 0c             	sub    $0xc,%esp
80109932:	68 c0 c7 10 80       	push   $0x8010c7c0
80109937:	e8 d0 6a ff ff       	call   8010040c <cprintf>
8010993c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010993f:	83 ec 0c             	sub    $0xc,%esp
80109942:	68 d9 c7 10 80       	push   $0x8010c7d9
80109947:	e8 c0 6a ff ff       	call   8010040c <cprintf>
8010994c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010994f:	8b 45 08             	mov    0x8(%ebp),%eax
80109952:	83 c0 18             	add    $0x18,%eax
80109955:	83 ec 0c             	sub    $0xc,%esp
80109958:	50                   	push   %eax
80109959:	e8 94 00 00 00       	call   801099f2 <print_ipv4>
8010995e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109961:	83 ec 0c             	sub    $0xc,%esp
80109964:	68 c0 c7 10 80       	push   $0x8010c7c0
80109969:	e8 9e 6a ff ff       	call   8010040c <cprintf>
8010996e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109971:	8b 45 08             	mov    0x8(%ebp),%eax
80109974:	83 c0 12             	add    $0x12,%eax
80109977:	83 ec 0c             	sub    $0xc,%esp
8010997a:	50                   	push   %eax
8010997b:	e8 c4 00 00 00       	call   80109a44 <print_mac>
80109980:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109983:	83 ec 0c             	sub    $0xc,%esp
80109986:	68 c0 c7 10 80       	push   $0x8010c7c0
8010998b:	e8 7c 6a ff ff       	call   8010040c <cprintf>
80109990:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109993:	83 ec 0c             	sub    $0xc,%esp
80109996:	68 f0 c7 10 80       	push   $0x8010c7f0
8010999b:	e8 6c 6a ff ff       	call   8010040c <cprintf>
801099a0:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801099a3:	8b 45 08             	mov    0x8(%ebp),%eax
801099a6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099aa:	66 3d 00 01          	cmp    $0x100,%ax
801099ae:	75 12                	jne    801099c2 <print_arp_info+0xe1>
801099b0:	83 ec 0c             	sub    $0xc,%esp
801099b3:	68 fc c7 10 80       	push   $0x8010c7fc
801099b8:	e8 4f 6a ff ff       	call   8010040c <cprintf>
801099bd:	83 c4 10             	add    $0x10,%esp
801099c0:	eb 1d                	jmp    801099df <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801099c2:	8b 45 08             	mov    0x8(%ebp),%eax
801099c5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099c9:	66 3d 00 02          	cmp    $0x200,%ax
801099cd:	75 10                	jne    801099df <print_arp_info+0xfe>
    cprintf("Reply\n");
801099cf:	83 ec 0c             	sub    $0xc,%esp
801099d2:	68 05 c8 10 80       	push   $0x8010c805
801099d7:	e8 30 6a ff ff       	call   8010040c <cprintf>
801099dc:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801099df:	83 ec 0c             	sub    $0xc,%esp
801099e2:	68 c0 c7 10 80       	push   $0x8010c7c0
801099e7:	e8 20 6a ff ff       	call   8010040c <cprintf>
801099ec:	83 c4 10             	add    $0x10,%esp
}
801099ef:	90                   	nop
801099f0:	c9                   	leave
801099f1:	c3                   	ret

801099f2 <print_ipv4>:

void print_ipv4(uchar *ip){
801099f2:	f3 0f 1e fb          	endbr32
801099f6:	55                   	push   %ebp
801099f7:	89 e5                	mov    %esp,%ebp
801099f9:	53                   	push   %ebx
801099fa:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109a00:	83 c0 03             	add    $0x3,%eax
80109a03:	0f b6 00             	movzbl (%eax),%eax
80109a06:	0f b6 d8             	movzbl %al,%ebx
80109a09:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0c:	83 c0 02             	add    $0x2,%eax
80109a0f:	0f b6 00             	movzbl (%eax),%eax
80109a12:	0f b6 c8             	movzbl %al,%ecx
80109a15:	8b 45 08             	mov    0x8(%ebp),%eax
80109a18:	83 c0 01             	add    $0x1,%eax
80109a1b:	0f b6 00             	movzbl (%eax),%eax
80109a1e:	0f b6 d0             	movzbl %al,%edx
80109a21:	8b 45 08             	mov    0x8(%ebp),%eax
80109a24:	0f b6 00             	movzbl (%eax),%eax
80109a27:	0f b6 c0             	movzbl %al,%eax
80109a2a:	83 ec 0c             	sub    $0xc,%esp
80109a2d:	53                   	push   %ebx
80109a2e:	51                   	push   %ecx
80109a2f:	52                   	push   %edx
80109a30:	50                   	push   %eax
80109a31:	68 0c c8 10 80       	push   $0x8010c80c
80109a36:	e8 d1 69 ff ff       	call   8010040c <cprintf>
80109a3b:	83 c4 20             	add    $0x20,%esp
}
80109a3e:	90                   	nop
80109a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a42:	c9                   	leave
80109a43:	c3                   	ret

80109a44 <print_mac>:

void print_mac(uchar *mac){
80109a44:	f3 0f 1e fb          	endbr32
80109a48:	55                   	push   %ebp
80109a49:	89 e5                	mov    %esp,%ebp
80109a4b:	57                   	push   %edi
80109a4c:	56                   	push   %esi
80109a4d:	53                   	push   %ebx
80109a4e:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a51:	8b 45 08             	mov    0x8(%ebp),%eax
80109a54:	83 c0 05             	add    $0x5,%eax
80109a57:	0f b6 00             	movzbl (%eax),%eax
80109a5a:	0f b6 f8             	movzbl %al,%edi
80109a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a60:	83 c0 04             	add    $0x4,%eax
80109a63:	0f b6 00             	movzbl (%eax),%eax
80109a66:	0f b6 f0             	movzbl %al,%esi
80109a69:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6c:	83 c0 03             	add    $0x3,%eax
80109a6f:	0f b6 00             	movzbl (%eax),%eax
80109a72:	0f b6 d8             	movzbl %al,%ebx
80109a75:	8b 45 08             	mov    0x8(%ebp),%eax
80109a78:	83 c0 02             	add    $0x2,%eax
80109a7b:	0f b6 00             	movzbl (%eax),%eax
80109a7e:	0f b6 c8             	movzbl %al,%ecx
80109a81:	8b 45 08             	mov    0x8(%ebp),%eax
80109a84:	83 c0 01             	add    $0x1,%eax
80109a87:	0f b6 00             	movzbl (%eax),%eax
80109a8a:	0f b6 d0             	movzbl %al,%edx
80109a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a90:	0f b6 00             	movzbl (%eax),%eax
80109a93:	0f b6 c0             	movzbl %al,%eax
80109a96:	83 ec 04             	sub    $0x4,%esp
80109a99:	57                   	push   %edi
80109a9a:	56                   	push   %esi
80109a9b:	53                   	push   %ebx
80109a9c:	51                   	push   %ecx
80109a9d:	52                   	push   %edx
80109a9e:	50                   	push   %eax
80109a9f:	68 24 c8 10 80       	push   $0x8010c824
80109aa4:	e8 63 69 ff ff       	call   8010040c <cprintf>
80109aa9:	83 c4 20             	add    $0x20,%esp
}
80109aac:	90                   	nop
80109aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109ab0:	5b                   	pop    %ebx
80109ab1:	5e                   	pop    %esi
80109ab2:	5f                   	pop    %edi
80109ab3:	5d                   	pop    %ebp
80109ab4:	c3                   	ret

80109ab5 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109ab5:	f3 0f 1e fb          	endbr32
80109ab9:	55                   	push   %ebp
80109aba:	89 e5                	mov    %esp,%ebp
80109abc:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109abf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac8:	83 c0 0e             	add    $0xe,%eax
80109acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ad5:	3c 08                	cmp    $0x8,%al
80109ad7:	75 1b                	jne    80109af4 <eth_proc+0x3f>
80109ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ae0:	3c 06                	cmp    $0x6,%al
80109ae2:	75 10                	jne    80109af4 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109ae4:	83 ec 0c             	sub    $0xc,%esp
80109ae7:	ff 75 f0             	push   -0x10(%ebp)
80109aea:	e8 d5 f7 ff ff       	call   801092c4 <arp_proc>
80109aef:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109af2:	eb 24                	jmp    80109b18 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109afb:	3c 08                	cmp    $0x8,%al
80109afd:	75 19                	jne    80109b18 <eth_proc+0x63>
80109aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b02:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b06:	84 c0                	test   %al,%al
80109b08:	75 0e                	jne    80109b18 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109b0a:	83 ec 0c             	sub    $0xc,%esp
80109b0d:	ff 75 08             	push   0x8(%ebp)
80109b10:	e8 b3 00 00 00       	call   80109bc8 <ipv4_proc>
80109b15:	83 c4 10             	add    $0x10,%esp
}
80109b18:	90                   	nop
80109b19:	c9                   	leave
80109b1a:	c3                   	ret

80109b1b <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b1b:	f3 0f 1e fb          	endbr32
80109b1f:	55                   	push   %ebp
80109b20:	89 e5                	mov    %esp,%ebp
80109b22:	83 ec 04             	sub    $0x4,%esp
80109b25:	8b 45 08             	mov    0x8(%ebp),%eax
80109b28:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b2c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b30:	c1 e0 08             	shl    $0x8,%eax
80109b33:	89 c2                	mov    %eax,%edx
80109b35:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b39:	66 c1 e8 08          	shr    $0x8,%ax
80109b3d:	01 d0                	add    %edx,%eax
}
80109b3f:	c9                   	leave
80109b40:	c3                   	ret

80109b41 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b41:	f3 0f 1e fb          	endbr32
80109b45:	55                   	push   %ebp
80109b46:	89 e5                	mov    %esp,%ebp
80109b48:	83 ec 04             	sub    $0x4,%esp
80109b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b52:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b56:	c1 e0 08             	shl    $0x8,%eax
80109b59:	89 c2                	mov    %eax,%edx
80109b5b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b5f:	66 c1 e8 08          	shr    $0x8,%ax
80109b63:	01 d0                	add    %edx,%eax
}
80109b65:	c9                   	leave
80109b66:	c3                   	ret

80109b67 <H2N_uint>:

uint H2N_uint(uint value){
80109b67:	f3 0f 1e fb          	endbr32
80109b6b:	55                   	push   %ebp
80109b6c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b71:	c1 e0 18             	shl    $0x18,%eax
80109b74:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b79:	89 c2                	mov    %eax,%edx
80109b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7e:	c1 e0 08             	shl    $0x8,%eax
80109b81:	25 00 f0 00 00       	and    $0xf000,%eax
80109b86:	09 c2                	or     %eax,%edx
80109b88:	8b 45 08             	mov    0x8(%ebp),%eax
80109b8b:	c1 e8 08             	shr    $0x8,%eax
80109b8e:	83 e0 0f             	and    $0xf,%eax
80109b91:	01 d0                	add    %edx,%eax
}
80109b93:	5d                   	pop    %ebp
80109b94:	c3                   	ret

80109b95 <N2H_uint>:

uint N2H_uint(uint value){
80109b95:	f3 0f 1e fb          	endbr32
80109b99:	55                   	push   %ebp
80109b9a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9f:	c1 e0 18             	shl    $0x18,%eax
80109ba2:	89 c2                	mov    %eax,%edx
80109ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba7:	c1 e0 08             	shl    $0x8,%eax
80109baa:	25 00 00 ff 00       	and    $0xff0000,%eax
80109baf:	01 c2                	add    %eax,%edx
80109bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb4:	c1 e8 08             	shr    $0x8,%eax
80109bb7:	25 00 ff 00 00       	and    $0xff00,%eax
80109bbc:	01 c2                	add    %eax,%edx
80109bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc1:	c1 e8 18             	shr    $0x18,%eax
80109bc4:	01 d0                	add    %edx,%eax
}
80109bc6:	5d                   	pop    %ebp
80109bc7:	c3                   	ret

80109bc8 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109bc8:	f3 0f 1e fb          	endbr32
80109bcc:	55                   	push   %ebp
80109bcd:	89 e5                	mov    %esp,%ebp
80109bcf:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd5:	83 c0 0e             	add    $0xe,%eax
80109bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bde:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109be2:	0f b7 d0             	movzwl %ax,%edx
80109be5:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109bea:	39 c2                	cmp    %eax,%edx
80109bec:	74 60                	je     80109c4e <ipv4_proc+0x86>
80109bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf1:	83 c0 0c             	add    $0xc,%eax
80109bf4:	83 ec 04             	sub    $0x4,%esp
80109bf7:	6a 04                	push   $0x4
80109bf9:	50                   	push   %eax
80109bfa:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bff:	e8 a1 b1 ff ff       	call   80104da5 <memcmp>
80109c04:	83 c4 10             	add    $0x10,%esp
80109c07:	85 c0                	test   %eax,%eax
80109c09:	74 43                	je     80109c4e <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c12:	0f b7 c0             	movzwl %ax,%eax
80109c15:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c1d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c21:	3c 01                	cmp    $0x1,%al
80109c23:	75 10                	jne    80109c35 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109c25:	83 ec 0c             	sub    $0xc,%esp
80109c28:	ff 75 08             	push   0x8(%ebp)
80109c2b:	e8 a7 00 00 00       	call   80109cd7 <icmp_proc>
80109c30:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c33:	eb 19                	jmp    80109c4e <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c38:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c3c:	3c 06                	cmp    $0x6,%al
80109c3e:	75 0e                	jne    80109c4e <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109c40:	83 ec 0c             	sub    $0xc,%esp
80109c43:	ff 75 08             	push   0x8(%ebp)
80109c46:	e8 c7 03 00 00       	call   8010a012 <tcp_proc>
80109c4b:	83 c4 10             	add    $0x10,%esp
}
80109c4e:	90                   	nop
80109c4f:	c9                   	leave
80109c50:	c3                   	ret

80109c51 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c51:	f3 0f 1e fb          	endbr32
80109c55:	55                   	push   %ebp
80109c56:	89 e5                	mov    %esp,%ebp
80109c58:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c64:	0f b6 00             	movzbl (%eax),%eax
80109c67:	83 e0 0f             	and    $0xf,%eax
80109c6a:	01 c0                	add    %eax,%eax
80109c6c:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c6f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c76:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c7d:	eb 48                	jmp    80109cc7 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c82:	01 c0                	add    %eax,%eax
80109c84:	89 c2                	mov    %eax,%edx
80109c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c89:	01 d0                	add    %edx,%eax
80109c8b:	0f b6 00             	movzbl (%eax),%eax
80109c8e:	0f b6 c0             	movzbl %al,%eax
80109c91:	c1 e0 08             	shl    $0x8,%eax
80109c94:	89 c2                	mov    %eax,%edx
80109c96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c99:	01 c0                	add    %eax,%eax
80109c9b:	8d 48 01             	lea    0x1(%eax),%ecx
80109c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca1:	01 c8                	add    %ecx,%eax
80109ca3:	0f b6 00             	movzbl (%eax),%eax
80109ca6:	0f b6 c0             	movzbl %al,%eax
80109ca9:	01 d0                	add    %edx,%eax
80109cab:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109cae:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109cb5:	76 0c                	jbe    80109cc3 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109cb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cba:	0f b7 c0             	movzwl %ax,%eax
80109cbd:	83 c0 01             	add    $0x1,%eax
80109cc0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cc3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109cc7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ccb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109cce:	7c af                	jl     80109c7f <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109cd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cd3:	f7 d0                	not    %eax
}
80109cd5:	c9                   	leave
80109cd6:	c3                   	ret

80109cd7 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109cd7:	f3 0f 1e fb          	endbr32
80109cdb:	55                   	push   %ebp
80109cdc:	89 e5                	mov    %esp,%ebp
80109cde:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ce4:	83 c0 0e             	add    $0xe,%eax
80109ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ced:	0f b6 00             	movzbl (%eax),%eax
80109cf0:	0f b6 c0             	movzbl %al,%eax
80109cf3:	83 e0 0f             	and    $0xf,%eax
80109cf6:	c1 e0 02             	shl    $0x2,%eax
80109cf9:	89 c2                	mov    %eax,%edx
80109cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfe:	01 d0                	add    %edx,%eax
80109d00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109d0a:	84 c0                	test   %al,%al
80109d0c:	75 4f                	jne    80109d5d <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d11:	0f b6 00             	movzbl (%eax),%eax
80109d14:	3c 08                	cmp    $0x8,%al
80109d16:	75 45                	jne    80109d5d <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109d18:	e8 e3 8b ff ff       	call   80102900 <kalloc>
80109d1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d20:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d27:	83 ec 04             	sub    $0x4,%esp
80109d2a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d2d:	50                   	push   %eax
80109d2e:	ff 75 ec             	push   -0x14(%ebp)
80109d31:	ff 75 08             	push   0x8(%ebp)
80109d34:	e8 7c 00 00 00       	call   80109db5 <icmp_reply_pkt_create>
80109d39:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d3f:	83 ec 08             	sub    $0x8,%esp
80109d42:	50                   	push   %eax
80109d43:	ff 75 ec             	push   -0x14(%ebp)
80109d46:	e8 43 f4 ff ff       	call   8010918e <i8254_send>
80109d4b:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d51:	83 ec 0c             	sub    $0xc,%esp
80109d54:	50                   	push   %eax
80109d55:	e8 08 8b ff ff       	call   80102862 <kfree>
80109d5a:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d5d:	90                   	nop
80109d5e:	c9                   	leave
80109d5f:	c3                   	ret

80109d60 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d60:	f3 0f 1e fb          	endbr32
80109d64:	55                   	push   %ebp
80109d65:	89 e5                	mov    %esp,%ebp
80109d67:	53                   	push   %ebx
80109d68:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d72:	0f b7 c0             	movzwl %ax,%eax
80109d75:	83 ec 0c             	sub    $0xc,%esp
80109d78:	50                   	push   %eax
80109d79:	e8 9d fd ff ff       	call   80109b1b <N2H_ushort>
80109d7e:	83 c4 10             	add    $0x10,%esp
80109d81:	0f b7 d8             	movzwl %ax,%ebx
80109d84:	8b 45 08             	mov    0x8(%ebp),%eax
80109d87:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d8b:	0f b7 c0             	movzwl %ax,%eax
80109d8e:	83 ec 0c             	sub    $0xc,%esp
80109d91:	50                   	push   %eax
80109d92:	e8 84 fd ff ff       	call   80109b1b <N2H_ushort>
80109d97:	83 c4 10             	add    $0x10,%esp
80109d9a:	0f b7 c0             	movzwl %ax,%eax
80109d9d:	83 ec 04             	sub    $0x4,%esp
80109da0:	53                   	push   %ebx
80109da1:	50                   	push   %eax
80109da2:	68 43 c8 10 80       	push   $0x8010c843
80109da7:	e8 60 66 ff ff       	call   8010040c <cprintf>
80109dac:	83 c4 10             	add    $0x10,%esp
}
80109daf:	90                   	nop
80109db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109db3:	c9                   	leave
80109db4:	c3                   	ret

80109db5 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109db5:	f3 0f 1e fb          	endbr32
80109db9:	55                   	push   %ebp
80109dba:	89 e5                	mov    %esp,%ebp
80109dbc:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc8:	83 c0 0e             	add    $0xe,%eax
80109dcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd1:	0f b6 00             	movzbl (%eax),%eax
80109dd4:	0f b6 c0             	movzbl %al,%eax
80109dd7:	83 e0 0f             	and    $0xf,%eax
80109dda:	c1 e0 02             	shl    $0x2,%eax
80109ddd:	89 c2                	mov    %eax,%edx
80109ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de2:	01 d0                	add    %edx,%eax
80109de4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109de7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80109df0:	83 c0 0e             	add    $0xe,%eax
80109df3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df9:	83 c0 14             	add    $0x14,%eax
80109dfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109dff:	8b 45 10             	mov    0x10(%ebp),%eax
80109e02:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0b:	8d 50 06             	lea    0x6(%eax),%edx
80109e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e11:	83 ec 04             	sub    $0x4,%esp
80109e14:	6a 06                	push   $0x6
80109e16:	52                   	push   %edx
80109e17:	50                   	push   %eax
80109e18:	e8 e4 af ff ff       	call   80104e01 <memmove>
80109e1d:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e23:	83 c0 06             	add    $0x6,%eax
80109e26:	83 ec 04             	sub    $0x4,%esp
80109e29:	6a 06                	push   $0x6
80109e2b:	68 68 d0 18 80       	push   $0x8018d068
80109e30:	50                   	push   %eax
80109e31:	e8 cb af ff ff       	call   80104e01 <memmove>
80109e36:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e3c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e43:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e4a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e50:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e54:	83 ec 0c             	sub    $0xc,%esp
80109e57:	6a 54                	push   $0x54
80109e59:	e8 e3 fc ff ff       	call   80109b41 <H2N_ushort>
80109e5e:	83 c4 10             	add    $0x10,%esp
80109e61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e64:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e68:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e72:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e76:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109e7d:	83 c0 01             	add    $0x1,%eax
80109e80:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e86:	83 ec 0c             	sub    $0xc,%esp
80109e89:	68 00 40 00 00       	push   $0x4000
80109e8e:	e8 ae fc ff ff       	call   80109b41 <H2N_ushort>
80109e93:	83 c4 10             	add    $0x10,%esp
80109e96:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e99:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea0:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ea4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eae:	83 c0 0c             	add    $0xc,%eax
80109eb1:	83 ec 04             	sub    $0x4,%esp
80109eb4:	6a 04                	push   $0x4
80109eb6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ebb:	50                   	push   %eax
80109ebc:	e8 40 af ff ff       	call   80104e01 <memmove>
80109ec1:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ec7:	8d 50 0c             	lea    0xc(%eax),%edx
80109eca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ecd:	83 c0 10             	add    $0x10,%eax
80109ed0:	83 ec 04             	sub    $0x4,%esp
80109ed3:	6a 04                	push   $0x4
80109ed5:	52                   	push   %edx
80109ed6:	50                   	push   %eax
80109ed7:	e8 25 af ff ff       	call   80104e01 <memmove>
80109edc:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ee2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eeb:	83 ec 0c             	sub    $0xc,%esp
80109eee:	50                   	push   %eax
80109eef:	e8 5d fd ff ff       	call   80109c51 <ipv4_chksum>
80109ef4:	83 c4 10             	add    $0x10,%esp
80109ef7:	0f b7 c0             	movzwl %ax,%eax
80109efa:	83 ec 0c             	sub    $0xc,%esp
80109efd:	50                   	push   %eax
80109efe:	e8 3e fc ff ff       	call   80109b41 <H2N_ushort>
80109f03:	83 c4 10             	add    $0x10,%esp
80109f06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f09:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109f0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f10:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f16:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f1d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f24:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f2b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f32:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f39:	8d 50 08             	lea    0x8(%eax),%edx
80109f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f3f:	83 c0 08             	add    $0x8,%eax
80109f42:	83 ec 04             	sub    $0x4,%esp
80109f45:	6a 08                	push   $0x8
80109f47:	52                   	push   %edx
80109f48:	50                   	push   %eax
80109f49:	e8 b3 ae ff ff       	call   80104e01 <memmove>
80109f4e:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f54:	8d 50 10             	lea    0x10(%eax),%edx
80109f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f5a:	83 c0 10             	add    $0x10,%eax
80109f5d:	83 ec 04             	sub    $0x4,%esp
80109f60:	6a 30                	push   $0x30
80109f62:	52                   	push   %edx
80109f63:	50                   	push   %eax
80109f64:	e8 98 ae ff ff       	call   80104e01 <memmove>
80109f69:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f6f:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f78:	83 ec 0c             	sub    $0xc,%esp
80109f7b:	50                   	push   %eax
80109f7c:	e8 1c 00 00 00       	call   80109f9d <icmp_chksum>
80109f81:	83 c4 10             	add    $0x10,%esp
80109f84:	0f b7 c0             	movzwl %ax,%eax
80109f87:	83 ec 0c             	sub    $0xc,%esp
80109f8a:	50                   	push   %eax
80109f8b:	e8 b1 fb ff ff       	call   80109b41 <H2N_ushort>
80109f90:	83 c4 10             	add    $0x10,%esp
80109f93:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f96:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f9a:	90                   	nop
80109f9b:	c9                   	leave
80109f9c:	c3                   	ret

80109f9d <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f9d:	f3 0f 1e fb          	endbr32
80109fa1:	55                   	push   %ebp
80109fa2:	89 e5                	mov    %esp,%ebp
80109fa4:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80109faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109fad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fb4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fbb:	eb 48                	jmp    8010a005 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fc0:	01 c0                	add    %eax,%eax
80109fc2:	89 c2                	mov    %eax,%edx
80109fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc7:	01 d0                	add    %edx,%eax
80109fc9:	0f b6 00             	movzbl (%eax),%eax
80109fcc:	0f b6 c0             	movzbl %al,%eax
80109fcf:	c1 e0 08             	shl    $0x8,%eax
80109fd2:	89 c2                	mov    %eax,%edx
80109fd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fd7:	01 c0                	add    %eax,%eax
80109fd9:	8d 48 01             	lea    0x1(%eax),%ecx
80109fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fdf:	01 c8                	add    %ecx,%eax
80109fe1:	0f b6 00             	movzbl (%eax),%eax
80109fe4:	0f b6 c0             	movzbl %al,%eax
80109fe7:	01 d0                	add    %edx,%eax
80109fe9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109fec:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ff3:	76 0c                	jbe    8010a001 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ff8:	0f b7 c0             	movzwl %ax,%eax
80109ffb:	83 c0 01             	add    $0x1,%eax
80109ffe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a001:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a005:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a009:	7e b2                	jle    80109fbd <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a00b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a00e:	f7 d0                	not    %eax
}
8010a010:	c9                   	leave
8010a011:	c3                   	ret

8010a012 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a012:	f3 0f 1e fb          	endbr32
8010a016:	55                   	push   %ebp
8010a017:	89 e5                	mov    %esp,%ebp
8010a019:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a01c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01f:	83 c0 0e             	add    $0xe,%eax
8010a022:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a025:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a028:	0f b6 00             	movzbl (%eax),%eax
8010a02b:	0f b6 c0             	movzbl %al,%eax
8010a02e:	83 e0 0f             	and    $0xf,%eax
8010a031:	c1 e0 02             	shl    $0x2,%eax
8010a034:	89 c2                	mov    %eax,%edx
8010a036:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a039:	01 d0                	add    %edx,%eax
8010a03b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a03e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a041:	83 c0 14             	add    $0x14,%eax
8010a044:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a047:	e8 b4 88 ff ff       	call   80102900 <kalloc>
8010a04c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a04f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a056:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a059:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a05d:	0f b6 c0             	movzbl %al,%eax
8010a060:	83 e0 02             	and    $0x2,%eax
8010a063:	85 c0                	test   %eax,%eax
8010a065:	74 3d                	je     8010a0a4 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a067:	83 ec 0c             	sub    $0xc,%esp
8010a06a:	6a 00                	push   $0x0
8010a06c:	6a 12                	push   $0x12
8010a06e:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a071:	50                   	push   %eax
8010a072:	ff 75 e8             	push   -0x18(%ebp)
8010a075:	ff 75 08             	push   0x8(%ebp)
8010a078:	e8 a2 01 00 00       	call   8010a21f <tcp_pkt_create>
8010a07d:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a080:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a083:	83 ec 08             	sub    $0x8,%esp
8010a086:	50                   	push   %eax
8010a087:	ff 75 e8             	push   -0x18(%ebp)
8010a08a:	e8 ff f0 ff ff       	call   8010918e <i8254_send>
8010a08f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a092:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a097:	83 c0 01             	add    $0x1,%eax
8010a09a:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a09f:	e9 69 01 00 00       	jmp    8010a20d <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a0a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0ab:	3c 18                	cmp    $0x18,%al
8010a0ad:	0f 85 10 01 00 00    	jne    8010a1c3 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a0b3:	83 ec 04             	sub    $0x4,%esp
8010a0b6:	6a 03                	push   $0x3
8010a0b8:	68 5e c8 10 80       	push   $0x8010c85e
8010a0bd:	ff 75 ec             	push   -0x14(%ebp)
8010a0c0:	e8 e0 ac ff ff       	call   80104da5 <memcmp>
8010a0c5:	83 c4 10             	add    $0x10,%esp
8010a0c8:	85 c0                	test   %eax,%eax
8010a0ca:	74 74                	je     8010a140 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a0cc:	83 ec 0c             	sub    $0xc,%esp
8010a0cf:	68 62 c8 10 80       	push   $0x8010c862
8010a0d4:	e8 33 63 ff ff       	call   8010040c <cprintf>
8010a0d9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0dc:	83 ec 0c             	sub    $0xc,%esp
8010a0df:	6a 00                	push   $0x0
8010a0e1:	6a 10                	push   $0x10
8010a0e3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0e6:	50                   	push   %eax
8010a0e7:	ff 75 e8             	push   -0x18(%ebp)
8010a0ea:	ff 75 08             	push   0x8(%ebp)
8010a0ed:	e8 2d 01 00 00       	call   8010a21f <tcp_pkt_create>
8010a0f2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0f8:	83 ec 08             	sub    $0x8,%esp
8010a0fb:	50                   	push   %eax
8010a0fc:	ff 75 e8             	push   -0x18(%ebp)
8010a0ff:	e8 8a f0 ff ff       	call   8010918e <i8254_send>
8010a104:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a107:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a10a:	83 c0 36             	add    $0x36,%eax
8010a10d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a110:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a113:	50                   	push   %eax
8010a114:	ff 75 e0             	push   -0x20(%ebp)
8010a117:	6a 00                	push   $0x0
8010a119:	6a 00                	push   $0x0
8010a11b:	e8 66 04 00 00       	call   8010a586 <http_proc>
8010a120:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a123:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a126:	83 ec 0c             	sub    $0xc,%esp
8010a129:	50                   	push   %eax
8010a12a:	6a 18                	push   $0x18
8010a12c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a12f:	50                   	push   %eax
8010a130:	ff 75 e8             	push   -0x18(%ebp)
8010a133:	ff 75 08             	push   0x8(%ebp)
8010a136:	e8 e4 00 00 00       	call   8010a21f <tcp_pkt_create>
8010a13b:	83 c4 20             	add    $0x20,%esp
8010a13e:	eb 62                	jmp    8010a1a2 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a140:	83 ec 0c             	sub    $0xc,%esp
8010a143:	6a 00                	push   $0x0
8010a145:	6a 10                	push   $0x10
8010a147:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a14a:	50                   	push   %eax
8010a14b:	ff 75 e8             	push   -0x18(%ebp)
8010a14e:	ff 75 08             	push   0x8(%ebp)
8010a151:	e8 c9 00 00 00       	call   8010a21f <tcp_pkt_create>
8010a156:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a159:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a15c:	83 ec 08             	sub    $0x8,%esp
8010a15f:	50                   	push   %eax
8010a160:	ff 75 e8             	push   -0x18(%ebp)
8010a163:	e8 26 f0 ff ff       	call   8010918e <i8254_send>
8010a168:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a16b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a16e:	83 c0 36             	add    $0x36,%eax
8010a171:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a174:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a177:	50                   	push   %eax
8010a178:	ff 75 e4             	push   -0x1c(%ebp)
8010a17b:	6a 00                	push   $0x0
8010a17d:	6a 00                	push   $0x0
8010a17f:	e8 02 04 00 00       	call   8010a586 <http_proc>
8010a184:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a187:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a18a:	83 ec 0c             	sub    $0xc,%esp
8010a18d:	50                   	push   %eax
8010a18e:	6a 18                	push   $0x18
8010a190:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a193:	50                   	push   %eax
8010a194:	ff 75 e8             	push   -0x18(%ebp)
8010a197:	ff 75 08             	push   0x8(%ebp)
8010a19a:	e8 80 00 00 00       	call   8010a21f <tcp_pkt_create>
8010a19f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a1a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1a5:	83 ec 08             	sub    $0x8,%esp
8010a1a8:	50                   	push   %eax
8010a1a9:	ff 75 e8             	push   -0x18(%ebp)
8010a1ac:	e8 dd ef ff ff       	call   8010918e <i8254_send>
8010a1b1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1b4:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a1b9:	83 c0 01             	add    $0x1,%eax
8010a1bc:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a1c1:	eb 4a                	jmp    8010a20d <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a1c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1c6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1ca:	3c 10                	cmp    $0x10,%al
8010a1cc:	75 3f                	jne    8010a20d <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a1ce:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a1d3:	83 f8 01             	cmp    $0x1,%eax
8010a1d6:	75 35                	jne    8010a20d <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a1d8:	83 ec 0c             	sub    $0xc,%esp
8010a1db:	6a 00                	push   $0x0
8010a1dd:	6a 01                	push   $0x1
8010a1df:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1e2:	50                   	push   %eax
8010a1e3:	ff 75 e8             	push   -0x18(%ebp)
8010a1e6:	ff 75 08             	push   0x8(%ebp)
8010a1e9:	e8 31 00 00 00       	call   8010a21f <tcp_pkt_create>
8010a1ee:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1f4:	83 ec 08             	sub    $0x8,%esp
8010a1f7:	50                   	push   %eax
8010a1f8:	ff 75 e8             	push   -0x18(%ebp)
8010a1fb:	e8 8e ef ff ff       	call   8010918e <i8254_send>
8010a200:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a203:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a20a:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a20d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a210:	83 ec 0c             	sub    $0xc,%esp
8010a213:	50                   	push   %eax
8010a214:	e8 49 86 ff ff       	call   80102862 <kfree>
8010a219:	83 c4 10             	add    $0x10,%esp
}
8010a21c:	90                   	nop
8010a21d:	c9                   	leave
8010a21e:	c3                   	ret

8010a21f <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a21f:	f3 0f 1e fb          	endbr32
8010a223:	55                   	push   %ebp
8010a224:	89 e5                	mov    %esp,%ebp
8010a226:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a229:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a22f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a232:	83 c0 0e             	add    $0xe,%eax
8010a235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23b:	0f b6 00             	movzbl (%eax),%eax
8010a23e:	0f b6 c0             	movzbl %al,%eax
8010a241:	83 e0 0f             	and    $0xf,%eax
8010a244:	c1 e0 02             	shl    $0x2,%eax
8010a247:	89 c2                	mov    %eax,%edx
8010a249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a24c:	01 d0                	add    %edx,%eax
8010a24e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a251:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a254:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a25a:	83 c0 0e             	add    $0xe,%eax
8010a25d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a260:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a263:	83 c0 14             	add    $0x14,%eax
8010a266:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a269:	8b 45 18             	mov    0x18(%ebp),%eax
8010a26c:	8d 50 36             	lea    0x36(%eax),%edx
8010a26f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a272:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a274:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a277:	8d 50 06             	lea    0x6(%eax),%edx
8010a27a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a27d:	83 ec 04             	sub    $0x4,%esp
8010a280:	6a 06                	push   $0x6
8010a282:	52                   	push   %edx
8010a283:	50                   	push   %eax
8010a284:	e8 78 ab ff ff       	call   80104e01 <memmove>
8010a289:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a28c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a28f:	83 c0 06             	add    $0x6,%eax
8010a292:	83 ec 04             	sub    $0x4,%esp
8010a295:	6a 06                	push   $0x6
8010a297:	68 68 d0 18 80       	push   $0x8018d068
8010a29c:	50                   	push   %eax
8010a29d:	e8 5f ab ff ff       	call   80104e01 <memmove>
8010a2a2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2a8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2af:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2b6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2bc:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a2c0:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2c3:	83 c0 28             	add    $0x28,%eax
8010a2c6:	0f b7 c0             	movzwl %ax,%eax
8010a2c9:	83 ec 0c             	sub    $0xc,%esp
8010a2cc:	50                   	push   %eax
8010a2cd:	e8 6f f8 ff ff       	call   80109b41 <H2N_ushort>
8010a2d2:	83 c4 10             	add    $0x10,%esp
8010a2d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2d8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2dc:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a2e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2ea:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a2f1:	83 c0 01             	add    $0x1,%eax
8010a2f4:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a2fa:	83 ec 0c             	sub    $0xc,%esp
8010a2fd:	6a 00                	push   $0x0
8010a2ff:	e8 3d f8 ff ff       	call   80109b41 <H2N_ushort>
8010a304:	83 c4 10             	add    $0x10,%esp
8010a307:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a30a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a30e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a311:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a318:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a31c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a31f:	83 c0 0c             	add    $0xc,%eax
8010a322:	83 ec 04             	sub    $0x4,%esp
8010a325:	6a 04                	push   $0x4
8010a327:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a32c:	50                   	push   %eax
8010a32d:	e8 cf aa ff ff       	call   80104e01 <memmove>
8010a332:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a335:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a338:	8d 50 0c             	lea    0xc(%eax),%edx
8010a33b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a33e:	83 c0 10             	add    $0x10,%eax
8010a341:	83 ec 04             	sub    $0x4,%esp
8010a344:	6a 04                	push   $0x4
8010a346:	52                   	push   %edx
8010a347:	50                   	push   %eax
8010a348:	e8 b4 aa ff ff       	call   80104e01 <memmove>
8010a34d:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a353:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a35c:	83 ec 0c             	sub    $0xc,%esp
8010a35f:	50                   	push   %eax
8010a360:	e8 ec f8 ff ff       	call   80109c51 <ipv4_chksum>
8010a365:	83 c4 10             	add    $0x10,%esp
8010a368:	0f b7 c0             	movzwl %ax,%eax
8010a36b:	83 ec 0c             	sub    $0xc,%esp
8010a36e:	50                   	push   %eax
8010a36f:	e8 cd f7 ff ff       	call   80109b41 <H2N_ushort>
8010a374:	83 c4 10             	add    $0x10,%esp
8010a377:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a37a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a37e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a381:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a385:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a388:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a38b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a38e:	0f b7 10             	movzwl (%eax),%edx
8010a391:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a394:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a398:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a39d:	83 ec 0c             	sub    $0xc,%esp
8010a3a0:	50                   	push   %eax
8010a3a1:	e8 c1 f7 ff ff       	call   80109b67 <H2N_uint>
8010a3a6:	83 c4 10             	add    $0x10,%esp
8010a3a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3ac:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a3af:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3b2:	8b 40 04             	mov    0x4(%eax),%eax
8010a3b5:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a3bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3be:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a3c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a3c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3cb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a3cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d2:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a3d6:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3d9:	89 c2                	mov    %eax,%edx
8010a3db:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3de:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a3e1:	83 ec 0c             	sub    $0xc,%esp
8010a3e4:	68 90 38 00 00       	push   $0x3890
8010a3e9:	e8 53 f7 ff ff       	call   80109b41 <H2N_ushort>
8010a3ee:	83 c4 10             	add    $0x10,%esp
8010a3f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3f4:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a3f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fb:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a401:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a404:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a40a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a40d:	83 ec 0c             	sub    $0xc,%esp
8010a410:	50                   	push   %eax
8010a411:	e8 1f 00 00 00       	call   8010a435 <tcp_chksum>
8010a416:	83 c4 10             	add    $0x10,%esp
8010a419:	83 c0 08             	add    $0x8,%eax
8010a41c:	0f b7 c0             	movzwl %ax,%eax
8010a41f:	83 ec 0c             	sub    $0xc,%esp
8010a422:	50                   	push   %eax
8010a423:	e8 19 f7 ff ff       	call   80109b41 <H2N_ushort>
8010a428:	83 c4 10             	add    $0x10,%esp
8010a42b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a42e:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a432:	90                   	nop
8010a433:	c9                   	leave
8010a434:	c3                   	ret

8010a435 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a435:	f3 0f 1e fb          	endbr32
8010a439:	55                   	push   %ebp
8010a43a:	89 e5                	mov    %esp,%ebp
8010a43c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a43f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a442:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a445:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a448:	83 c0 14             	add    $0x14,%eax
8010a44b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a44e:	83 ec 04             	sub    $0x4,%esp
8010a451:	6a 04                	push   $0x4
8010a453:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a458:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a45b:	50                   	push   %eax
8010a45c:	e8 a0 a9 ff ff       	call   80104e01 <memmove>
8010a461:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a464:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a467:	83 c0 0c             	add    $0xc,%eax
8010a46a:	83 ec 04             	sub    $0x4,%esp
8010a46d:	6a 04                	push   $0x4
8010a46f:	50                   	push   %eax
8010a470:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a473:	83 c0 04             	add    $0x4,%eax
8010a476:	50                   	push   %eax
8010a477:	e8 85 a9 ff ff       	call   80104e01 <memmove>
8010a47c:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a47f:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a483:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a48a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a48e:	0f b7 c0             	movzwl %ax,%eax
8010a491:	83 ec 0c             	sub    $0xc,%esp
8010a494:	50                   	push   %eax
8010a495:	e8 81 f6 ff ff       	call   80109b1b <N2H_ushort>
8010a49a:	83 c4 10             	add    $0x10,%esp
8010a49d:	83 e8 14             	sub    $0x14,%eax
8010a4a0:	0f b7 c0             	movzwl %ax,%eax
8010a4a3:	83 ec 0c             	sub    $0xc,%esp
8010a4a6:	50                   	push   %eax
8010a4a7:	e8 95 f6 ff ff       	call   80109b41 <H2N_ushort>
8010a4ac:	83 c4 10             	add    $0x10,%esp
8010a4af:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4ba:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a4c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a4c7:	eb 33                	jmp    8010a4fc <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4cc:	01 c0                	add    %eax,%eax
8010a4ce:	89 c2                	mov    %eax,%edx
8010a4d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4d3:	01 d0                	add    %edx,%eax
8010a4d5:	0f b6 00             	movzbl (%eax),%eax
8010a4d8:	0f b6 c0             	movzbl %al,%eax
8010a4db:	c1 e0 08             	shl    $0x8,%eax
8010a4de:	89 c2                	mov    %eax,%edx
8010a4e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4e3:	01 c0                	add    %eax,%eax
8010a4e5:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4eb:	01 c8                	add    %ecx,%eax
8010a4ed:	0f b6 00             	movzbl (%eax),%eax
8010a4f0:	0f b6 c0             	movzbl %al,%eax
8010a4f3:	01 d0                	add    %edx,%eax
8010a4f5:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a4f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a4fc:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a500:	7e c7                	jle    8010a4c9 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a502:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a508:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a50f:	eb 33                	jmp    8010a544 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a511:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a514:	01 c0                	add    %eax,%eax
8010a516:	89 c2                	mov    %eax,%edx
8010a518:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a51b:	01 d0                	add    %edx,%eax
8010a51d:	0f b6 00             	movzbl (%eax),%eax
8010a520:	0f b6 c0             	movzbl %al,%eax
8010a523:	c1 e0 08             	shl    $0x8,%eax
8010a526:	89 c2                	mov    %eax,%edx
8010a528:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a52b:	01 c0                	add    %eax,%eax
8010a52d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a530:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a533:	01 c8                	add    %ecx,%eax
8010a535:	0f b6 00             	movzbl (%eax),%eax
8010a538:	0f b6 c0             	movzbl %al,%eax
8010a53b:	01 d0                	add    %edx,%eax
8010a53d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a540:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a544:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a548:	0f b7 c0             	movzwl %ax,%eax
8010a54b:	83 ec 0c             	sub    $0xc,%esp
8010a54e:	50                   	push   %eax
8010a54f:	e8 c7 f5 ff ff       	call   80109b1b <N2H_ushort>
8010a554:	83 c4 10             	add    $0x10,%esp
8010a557:	66 d1 e8             	shr    $1,%ax
8010a55a:	0f b7 c0             	movzwl %ax,%eax
8010a55d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a560:	7c af                	jl     8010a511 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a562:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a565:	c1 e8 10             	shr    $0x10,%eax
8010a568:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a56b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a56e:	f7 d0                	not    %eax
}
8010a570:	c9                   	leave
8010a571:	c3                   	ret

8010a572 <tcp_fin>:

void tcp_fin(){
8010a572:	f3 0f 1e fb          	endbr32
8010a576:	55                   	push   %ebp
8010a577:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a579:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a580:	00 00 00 
}
8010a583:	90                   	nop
8010a584:	5d                   	pop    %ebp
8010a585:	c3                   	ret

8010a586 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a586:	f3 0f 1e fb          	endbr32
8010a58a:	55                   	push   %ebp
8010a58b:	89 e5                	mov    %esp,%ebp
8010a58d:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a590:	8b 45 10             	mov    0x10(%ebp),%eax
8010a593:	83 ec 04             	sub    $0x4,%esp
8010a596:	6a 00                	push   $0x0
8010a598:	68 6b c8 10 80       	push   $0x8010c86b
8010a59d:	50                   	push   %eax
8010a59e:	e8 65 00 00 00       	call   8010a608 <http_strcpy>
8010a5a3:	83 c4 10             	add    $0x10,%esp
8010a5a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a5a9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5ac:	83 ec 04             	sub    $0x4,%esp
8010a5af:	ff 75 f4             	push   -0xc(%ebp)
8010a5b2:	68 7e c8 10 80       	push   $0x8010c87e
8010a5b7:	50                   	push   %eax
8010a5b8:	e8 4b 00 00 00       	call   8010a608 <http_strcpy>
8010a5bd:	83 c4 10             	add    $0x10,%esp
8010a5c0:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5c3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5c6:	83 ec 04             	sub    $0x4,%esp
8010a5c9:	ff 75 f4             	push   -0xc(%ebp)
8010a5cc:	68 99 c8 10 80       	push   $0x8010c899
8010a5d1:	50                   	push   %eax
8010a5d2:	e8 31 00 00 00       	call   8010a608 <http_strcpy>
8010a5d7:	83 c4 10             	add    $0x10,%esp
8010a5da:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a5dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5e0:	83 e0 01             	and    $0x1,%eax
8010a5e3:	85 c0                	test   %eax,%eax
8010a5e5:	74 11                	je     8010a5f8 <http_proc+0x72>
    char *payload = (char *)send;
8010a5e7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a5ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5f3:	01 d0                	add    %edx,%eax
8010a5f5:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a5f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5fb:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5fe:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a600:	e8 6d ff ff ff       	call   8010a572 <tcp_fin>
}
8010a605:	90                   	nop
8010a606:	c9                   	leave
8010a607:	c3                   	ret

8010a608 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a608:	f3 0f 1e fb          	endbr32
8010a60c:	55                   	push   %ebp
8010a60d:	89 e5                	mov    %esp,%ebp
8010a60f:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a612:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a619:	eb 20                	jmp    8010a63b <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a61b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a61e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a621:	01 d0                	add    %edx,%eax
8010a623:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a626:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a629:	01 ca                	add    %ecx,%edx
8010a62b:	89 d1                	mov    %edx,%ecx
8010a62d:	8b 55 08             	mov    0x8(%ebp),%edx
8010a630:	01 ca                	add    %ecx,%edx
8010a632:	0f b6 00             	movzbl (%eax),%eax
8010a635:	88 02                	mov    %al,(%edx)
    i++;
8010a637:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a63b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a63e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a641:	01 d0                	add    %edx,%eax
8010a643:	0f b6 00             	movzbl (%eax),%eax
8010a646:	84 c0                	test   %al,%al
8010a648:	75 d1                	jne    8010a61b <http_strcpy+0x13>
  }
  return i;
8010a64a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a64d:	c9                   	leave
8010a64e:	c3                   	ret

8010a64f <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a64f:	f3 0f 1e fb          	endbr32
8010a653:	55                   	push   %ebp
8010a654:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a656:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a65d:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a660:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a665:	c1 e8 09             	shr    $0x9,%eax
8010a668:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a66d:	90                   	nop
8010a66e:	5d                   	pop    %ebp
8010a66f:	c3                   	ret

8010a670 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a670:	f3 0f 1e fb          	endbr32
8010a674:	55                   	push   %ebp
8010a675:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a677:	90                   	nop
8010a678:	5d                   	pop    %ebp
8010a679:	c3                   	ret

8010a67a <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a67a:	f3 0f 1e fb          	endbr32
8010a67e:	55                   	push   %ebp
8010a67f:	89 e5                	mov    %esp,%ebp
8010a681:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a684:	8b 45 08             	mov    0x8(%ebp),%eax
8010a687:	83 c0 0c             	add    $0xc,%eax
8010a68a:	83 ec 0c             	sub    $0xc,%esp
8010a68d:	50                   	push   %eax
8010a68e:	e8 7f a3 ff ff       	call   80104a12 <holdingsleep>
8010a693:	83 c4 10             	add    $0x10,%esp
8010a696:	85 c0                	test   %eax,%eax
8010a698:	75 0d                	jne    8010a6a7 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a69a:	83 ec 0c             	sub    $0xc,%esp
8010a69d:	68 aa c8 10 80       	push   $0x8010c8aa
8010a6a2:	e8 37 5f ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a6a7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6aa:	8b 00                	mov    (%eax),%eax
8010a6ac:	83 e0 06             	and    $0x6,%eax
8010a6af:	83 f8 02             	cmp    $0x2,%eax
8010a6b2:	75 0d                	jne    8010a6c1 <iderw+0x47>
    panic("iderw: nothing to do");
8010a6b4:	83 ec 0c             	sub    $0xc,%esp
8010a6b7:	68 c0 c8 10 80       	push   $0x8010c8c0
8010a6bc:	e8 1d 5f ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a6c1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c4:	8b 40 04             	mov    0x4(%eax),%eax
8010a6c7:	83 f8 01             	cmp    $0x1,%eax
8010a6ca:	74 0d                	je     8010a6d9 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a6cc:	83 ec 0c             	sub    $0xc,%esp
8010a6cf:	68 d5 c8 10 80       	push   $0x8010c8d5
8010a6d4:	e8 05 5f ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a6d9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6dc:	8b 40 08             	mov    0x8(%eax),%eax
8010a6df:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a6e5:	39 d0                	cmp    %edx,%eax
8010a6e7:	72 0d                	jb     8010a6f6 <iderw+0x7c>
    panic("iderw: block out of range");
8010a6e9:	83 ec 0c             	sub    $0xc,%esp
8010a6ec:	68 f3 c8 10 80       	push   $0x8010c8f3
8010a6f1:	e8 e8 5e ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a6f6:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a6fc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6ff:	8b 40 08             	mov    0x8(%eax),%eax
8010a702:	c1 e0 09             	shl    $0x9,%eax
8010a705:	01 d0                	add    %edx,%eax
8010a707:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a70a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a70d:	8b 00                	mov    (%eax),%eax
8010a70f:	83 e0 04             	and    $0x4,%eax
8010a712:	85 c0                	test   %eax,%eax
8010a714:	74 2b                	je     8010a741 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a716:	8b 45 08             	mov    0x8(%ebp),%eax
8010a719:	8b 00                	mov    (%eax),%eax
8010a71b:	83 e0 fb             	and    $0xfffffffb,%eax
8010a71e:	89 c2                	mov    %eax,%edx
8010a720:	8b 45 08             	mov    0x8(%ebp),%eax
8010a723:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a725:	8b 45 08             	mov    0x8(%ebp),%eax
8010a728:	83 c0 5c             	add    $0x5c,%eax
8010a72b:	83 ec 04             	sub    $0x4,%esp
8010a72e:	68 00 02 00 00       	push   $0x200
8010a733:	50                   	push   %eax
8010a734:	ff 75 f4             	push   -0xc(%ebp)
8010a737:	e8 c5 a6 ff ff       	call   80104e01 <memmove>
8010a73c:	83 c4 10             	add    $0x10,%esp
8010a73f:	eb 1a                	jmp    8010a75b <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a741:	8b 45 08             	mov    0x8(%ebp),%eax
8010a744:	83 c0 5c             	add    $0x5c,%eax
8010a747:	83 ec 04             	sub    $0x4,%esp
8010a74a:	68 00 02 00 00       	push   $0x200
8010a74f:	ff 75 f4             	push   -0xc(%ebp)
8010a752:	50                   	push   %eax
8010a753:	e8 a9 a6 ff ff       	call   80104e01 <memmove>
8010a758:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a75b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a75e:	8b 00                	mov    (%eax),%eax
8010a760:	83 c8 02             	or     $0x2,%eax
8010a763:	89 c2                	mov    %eax,%edx
8010a765:	8b 45 08             	mov    0x8(%ebp),%eax
8010a768:	89 10                	mov    %edx,(%eax)
}
8010a76a:	90                   	nop
8010a76b:	c9                   	leave
8010a76c:	c3                   	ret
