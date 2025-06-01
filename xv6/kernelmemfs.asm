
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
8010005f:	ba 1b 35 10 80       	mov    $0x8010351b,%edx
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
8010007d:	e8 02 4a 00 00       	call   80104a84 <initlock>
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
801000c7:	e8 4b 48 00 00       	call   80104917 <initsleeplock>
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
80100109:	e8 9c 49 00 00       	call   80104aaa <acquire>
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
80100148:	e8 cf 49 00 00       	call   80104b1c <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 f8 47 00 00       	call   80104957 <acquiresleep>
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
801001c9:	e8 4e 49 00 00       	call   80104b1c <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 77 47 00 00       	call   80104957 <acquiresleep>
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
80100239:	e8 3b a4 00 00       	call   8010a679 <iderw>
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
8010025a:	e8 b2 47 00 00       	call   80104a11 <holdingsleep>
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
80100288:	e8 ec a3 00 00       	call   8010a679 <iderw>
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
801002a7:	e8 65 47 00 00       	call   80104a11 <holdingsleep>
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
801002ca:	e8 f0 46 00 00       	call   801049bf <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 cb 47 00 00       	call   80104aaa <acquire>
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
8010034a:	e8 cd 47 00 00       	call   80104b1c <release>
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
8010042c:	e8 79 46 00 00       	call   80104aaa <acquire>
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
801005d3:	e8 44 45 00 00       	call   80104b1c <release>
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
801005f7:	e8 70 26 00 00       	call   80102c6c <lapicid>
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
80100637:	e8 36 45 00 00       	call   80104b72 <getcallerpcs>
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
801006dd:	e8 2b 7e 00 00       	call   8010850d <graphic_scroll_up>
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
80100730:	e8 d8 7d 00 00       	call   8010850d <graphic_scroll_up>
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
80100796:	e8 e6 7d 00 00       	call   80108581 <font_render>
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
801007d6:	e8 5b 61 00 00       	call   80106936 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 4e 61 00 00       	call   80106936 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 41 61 00 00       	call   80106936 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 31 61 00 00       	call   80106936 <uartputc>
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
80100832:	e8 73 42 00 00       	call   80104aaa <acquire>
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
80100988:	e8 83 3c 00 00       	call   80104610 <wakeup>
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
801009ab:	e8 6c 41 00 00       	call   80104b1c <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 25 3d 00 00       	call   801046e3 <procdump>
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
801009d1:	e8 2a 12 00 00       	call   80101c00 <iunlock>
801009d6:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d9:	8b 45 10             	mov    0x10(%ebp),%eax
801009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 20 d0 18 80       	push   $0x8018d020
801009e7:	e8 be 40 00 00       	call   80104aaa <acquire>
801009ec:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ef:	e9 ab 00 00 00       	jmp    80100a9f <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009f4:	e8 1d 32 00 00       	call   80103c16 <myproc>
801009f9:	8b 40 24             	mov    0x24(%eax),%eax
801009fc:	85 c0                	test   %eax,%eax
801009fe:	74 28                	je     80100a28 <consoleread+0x67>
        release(&cons.lock);
80100a00:	83 ec 0c             	sub    $0xc,%esp
80100a03:	68 20 d0 18 80       	push   $0x8018d020
80100a08:	e8 0f 41 00 00       	call   80104b1c <release>
80100a0d:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a10:	83 ec 0c             	sub    $0xc,%esp
80100a13:	ff 75 08             	push   0x8(%ebp)
80100a16:	e8 ce 10 00 00       	call   80101ae9 <ilock>
80100a1b:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a23:	e9 ab 00 00 00       	jmp    80100ad3 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a28:	83 ec 08             	sub    $0x8,%esp
80100a2b:	68 20 d0 18 80       	push   $0x8018d020
80100a30:	68 40 2d 19 80       	push   $0x80192d40
80100a35:	e8 e7 3a 00 00       	call   80104521 <sleep>
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
80100ab3:	e8 64 40 00 00       	call   80104b1c <release>
80100ab8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100abb:	83 ec 0c             	sub    $0xc,%esp
80100abe:	ff 75 08             	push   0x8(%ebp)
80100ac1:	e8 23 10 00 00       	call   80101ae9 <ilock>
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
80100ae5:	e8 16 11 00 00       	call   80101c00 <iunlock>
80100aea:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aed:	83 ec 0c             	sub    $0xc,%esp
80100af0:	68 20 d0 18 80       	push   $0x8018d020
80100af5:	e8 b0 3f 00 00       	call   80104aaa <acquire>
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
80100b37:	e8 e0 3f 00 00       	call   80104b1c <release>
80100b3c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b3f:	83 ec 0c             	sub    $0xc,%esp
80100b42:	ff 75 08             	push   0x8(%ebp)
80100b45:	e8 9f 0f 00 00       	call   80101ae9 <ilock>
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
80100b73:	e8 0c 3f 00 00       	call   80104a84 <initlock>
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
80100bcc:	e8 a8 1b 00 00       	call   80102779 <ioapicenable>
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
80100bde:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100be4:	e8 2d 30 00 00       	call   80103c16 <myproc>
80100be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bec:	e8 ed 25 00 00       	call   801031de <begin_op>

  if((ip = namei(path)) == 0){
80100bf1:	83 ec 0c             	sub    $0xc,%esp
80100bf4:	ff 75 08             	push   0x8(%ebp)
80100bf7:	e8 58 1a 00 00       	call   80102654 <namei>
80100bfc:	83 c4 10             	add    $0x10,%esp
80100bff:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c06:	75 1f                	jne    80100c27 <exec+0x50>
    end_op();
80100c08:	e8 61 26 00 00       	call   8010326e <end_op>
    cprintf("exec: fail\n");
80100c0d:	83 ec 0c             	sub    $0xc,%esp
80100c10:	68 50 a8 10 80       	push   $0x8010a850
80100c15:	e8 f2 f7 ff ff       	call   8010040c <cprintf>
80100c1a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 45 04 00 00       	jmp    8010106c <exec+0x495>
  }
  ilock(ip);
80100c27:	83 ec 0c             	sub    $0xc,%esp
80100c2a:	ff 75 d8             	push   -0x28(%ebp)
80100c2d:	e8 b7 0e 00 00       	call   80101ae9 <ilock>
80100c32:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c35:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c3c:	6a 34                	push   $0x34
80100c3e:	6a 00                	push   $0x0
80100c40:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c46:	50                   	push   %eax
80100c47:	ff 75 d8             	push   -0x28(%ebp)
80100c4a:	e8 a2 13 00 00       	call   80101ff1 <readi>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	83 f8 34             	cmp    $0x34,%eax
80100c55:	0f 85 aa 03 00 00    	jne    80101005 <exec+0x42e>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c5b:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100c61:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c66:	0f 85 9c 03 00 00    	jne    80101008 <exec+0x431>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c6c:	e8 d9 6c 00 00       	call   8010794a <setupkvm>
80100c71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c78:	0f 84 8d 03 00 00    	je     8010100b <exec+0x434>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c7e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c8c:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100c92:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c95:	e9 de 00 00 00       	jmp    80100d78 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c9d:	6a 20                	push   $0x20
80100c9f:	50                   	push   %eax
80100ca0:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100ca6:	50                   	push   %eax
80100ca7:	ff 75 d8             	push   -0x28(%ebp)
80100caa:	e8 42 13 00 00       	call   80101ff1 <readi>
80100caf:	83 c4 10             	add    $0x10,%esp
80100cb2:	83 f8 20             	cmp    $0x20,%eax
80100cb5:	0f 85 53 03 00 00    	jne    8010100e <exec+0x437>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cbb:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100cc1:	83 f8 01             	cmp    $0x1,%eax
80100cc4:	0f 85 a0 00 00 00    	jne    80100d6a <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cca:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cd0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100cd6:	39 c2                	cmp    %eax,%edx
80100cd8:	0f 82 33 03 00 00    	jb     80101011 <exec+0x43a>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cde:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ce4:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cea:	01 c2                	add    %eax,%edx
80100cec:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 1a 03 00 00    	jb     80101014 <exec+0x43d>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d00:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	push   -0x20(%ebp)
80100d0f:	ff 75 d4             	push   -0x2c(%ebp)
80100d12:	e8 45 70 00 00       	call   80107d5c <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 f0 02 00 00    	je     80101017 <exec+0x440>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d32:	85 c0                	test   %eax,%eax
80100d34:	0f 85 e0 02 00 00    	jne    8010101a <exec+0x443>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d3a:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d40:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d46:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100d4c:	83 ec 0c             	sub    $0xc,%esp
80100d4f:	52                   	push   %edx
80100d50:	50                   	push   %eax
80100d51:	ff 75 d8             	push   -0x28(%ebp)
80100d54:	51                   	push   %ecx
80100d55:	ff 75 d4             	push   -0x2c(%ebp)
80100d58:	e8 2e 6f 00 00       	call   80107c8b <loaduvm>
80100d5d:	83 c4 20             	add    $0x20,%esp
80100d60:	85 c0                	test   %eax,%eax
80100d62:	0f 88 b5 02 00 00    	js     8010101d <exec+0x446>
80100d68:	eb 01                	jmp    80100d6b <exec+0x194>
      continue;
80100d6a:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d6b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d72:	83 c0 20             	add    $0x20,%eax
80100d75:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d78:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100d7f:	0f b7 c0             	movzwl %ax,%eax
80100d82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d85:	0f 8c 0f ff ff ff    	jl     80100c9a <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d8b:	83 ec 0c             	sub    $0xc,%esp
80100d8e:	ff 75 d8             	push   -0x28(%ebp)
80100d91:	e8 90 0f 00 00       	call   80101d26 <iunlockput>
80100d96:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d99:	e8 d0 24 00 00       	call   8010326e <end_op>
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
80100db2:	68 5c a8 10 80       	push   $0x8010a85c
80100db7:	e8 50 f6 ff ff       	call   8010040c <cprintf>
80100dbc:	83 c4 10             	add    $0x10,%esp
  uint sz0 = sz;
80100dbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  sz = PGROUNDDOWN(KERNBASE - 2*PGSIZE);
80100dc5:	c7 45 e0 00 e0 ff 7f 	movl   $0x7fffe000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dcf:	05 00 10 00 00       	add    $0x1000,%eax
80100dd4:	83 ec 04             	sub    $0x4,%esp
80100dd7:	50                   	push   %eax
80100dd8:	ff 75 e0             	push   -0x20(%ebp)
80100ddb:	ff 75 d4             	push   -0x2c(%ebp)
80100dde:	e8 79 6f 00 00       	call   80107d5c <allocuvm>
80100de3:	83 c4 10             	add    $0x10,%esp
80100de6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100de9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ded:	0f 84 2d 02 00 00    	je     80101020 <exec+0x449>
    goto bad;
  // 스택 포인터를 sz로
  sp = sz;
80100df3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100df6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // 0xb98은 text, data영역의 윗 부분
  // sz는 사용 중인 유저 공간을 나타내주는데 스택을 kernbase로 옮겨서
  // 스택 외의 코드까지만 sz로 변경
  sz = PGROUNDUP(sz0);
80100df9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100dfc:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100e09:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e0c:	8b 40 10             	mov    0x10(%eax),%eax
80100e0f:	83 ec 04             	sub    $0x4,%esp
80100e12:	50                   	push   %eax
80100e13:	ff 75 e0             	push   -0x20(%ebp)
80100e16:	68 5c a8 10 80       	push   $0x8010a85c
80100e1b:	e8 ec f5 ff ff       	call   8010040c <cprintf>
80100e20:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e23:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e2a:	e9 96 00 00 00       	jmp    80100ec5 <exec+0x2ee>
    if(argc >= MAXARG)
80100e2f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e33:	0f 87 ea 01 00 00    	ja     80101023 <exec+0x44c>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e46:	01 d0                	add    %edx,%eax
80100e48:	8b 00                	mov    (%eax),%eax
80100e4a:	83 ec 0c             	sub    $0xc,%esp
80100e4d:	50                   	push   %eax
80100e4e:	e8 4f 41 00 00       	call   80104fa2 <strlen>
80100e53:	83 c4 10             	add    $0x10,%esp
80100e56:	89 c2                	mov    %eax,%edx
80100e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e5b:	29 d0                	sub    %edx,%eax
80100e5d:	83 e8 01             	sub    $0x1,%eax
80100e60:	83 e0 fc             	and    $0xfffffffc,%eax
80100e63:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e73:	01 d0                	add    %edx,%eax
80100e75:	8b 00                	mov    (%eax),%eax
80100e77:	83 ec 0c             	sub    $0xc,%esp
80100e7a:	50                   	push   %eax
80100e7b:	e8 22 41 00 00       	call   80104fa2 <strlen>
80100e80:	83 c4 10             	add    $0x10,%esp
80100e83:	83 c0 01             	add    $0x1,%eax
80100e86:	89 c1                	mov    %eax,%ecx
80100e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e95:	01 d0                	add    %edx,%eax
80100e97:	8b 00                	mov    (%eax),%eax
80100e99:	51                   	push   %ecx
80100e9a:	50                   	push   %eax
80100e9b:	ff 75 dc             	push   -0x24(%ebp)
80100e9e:	ff 75 d4             	push   -0x2c(%ebp)
80100ea1:	e8 ba 72 00 00       	call   80108160 <copyout>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	85 c0                	test   %eax,%eax
80100eab:	0f 88 75 01 00 00    	js     80101026 <exec+0x44f>
      goto bad;
    ustack[3+argc] = sp;
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	8d 50 03             	lea    0x3(%eax),%edx
80100eb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eba:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ec1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed2:	01 d0                	add    %edx,%eax
80100ed4:	8b 00                	mov    (%eax),%eax
80100ed6:	85 c0                	test   %eax,%eax
80100ed8:	0f 85 51 ff ff ff    	jne    80100e2f <exec+0x258>
  }
  ustack[3+argc] = 0;
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	83 c0 03             	add    $0x3,%eax
80100ee4:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100eeb:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eef:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100ef6:	ff ff ff 
  ustack[1] = argc;
80100ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efc:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f05:	83 c0 01             	add    $0x1,%eax
80100f08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f12:	29 d0                	sub    %edx,%eax
80100f14:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1d:	83 c0 04             	add    $0x4,%eax
80100f20:	c1 e0 02             	shl    $0x2,%eax
80100f23:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f29:	83 c0 04             	add    $0x4,%eax
80100f2c:	c1 e0 02             	shl    $0x2,%eax
80100f2f:	50                   	push   %eax
80100f30:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100f36:	50                   	push   %eax
80100f37:	ff 75 dc             	push   -0x24(%ebp)
80100f3a:	ff 75 d4             	push   -0x2c(%ebp)
80100f3d:	e8 1e 72 00 00       	call   80108160 <copyout>
80100f42:	83 c4 10             	add    $0x10,%esp
80100f45:	85 c0                	test   %eax,%eax
80100f47:	0f 88 dc 00 00 00    	js     80101029 <exec+0x452>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80100f50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f59:	eb 17                	jmp    80100f72 <exec+0x39b>
    if(*s == '/')
80100f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5e:	0f b6 00             	movzbl (%eax),%eax
80100f61:	3c 2f                	cmp    $0x2f,%al
80100f63:	75 09                	jne    80100f6e <exec+0x397>
      last = s+1;
80100f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f68:	83 c0 01             	add    $0x1,%eax
80100f6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f75:	0f b6 00             	movzbl (%eax),%eax
80100f78:	84 c0                	test   %al,%al
80100f7a:	75 df                	jne    80100f5b <exec+0x384>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f7c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7f:	83 c0 6c             	add    $0x6c,%eax
80100f82:	83 ec 04             	sub    $0x4,%esp
80100f85:	6a 10                	push   $0x10
80100f87:	ff 75 f0             	push   -0x10(%ebp)
80100f8a:	50                   	push   %eax
80100f8b:	e8 c4 3f 00 00       	call   80104f54 <safestrcpy>
80100f90:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f93:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f96:	8b 40 04             	mov    0x4(%eax),%eax
80100f99:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fa2:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa8:	8b 40 18             	mov    0x18(%eax),%eax
80100fab:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100fb1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->sz = sz;
80100fb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fba:	89 10                	mov    %edx,(%eax)
  curproc->tf->esp = sp;
80100fbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fbf:	8b 40 18             	mov    0x18(%eax),%eax
80100fc2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fc5:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("[exec] eip %x\n",curproc->tf->eip);
80100fc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fcb:	8b 40 18             	mov    0x18(%eax),%eax
80100fce:	8b 40 38             	mov    0x38(%eax),%eax
80100fd1:	83 ec 08             	sub    $0x8,%esp
80100fd4:	50                   	push   %eax
80100fd5:	68 79 a8 10 80       	push   $0x8010a879
80100fda:	e8 2d f4 ff ff       	call   8010040c <cprintf>
80100fdf:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80100fe2:	83 ec 0c             	sub    $0xc,%esp
80100fe5:	ff 75 d0             	push   -0x30(%ebp)
80100fe8:	e8 87 6a 00 00       	call   80107a74 <switchuvm>
80100fed:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ff0:	83 ec 0c             	sub    $0xc,%esp
80100ff3:	ff 75 c8             	push   -0x38(%ebp)
80100ff6:	e8 32 6f 00 00       	call   80107f2d <freevm>
80100ffb:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ffe:	b8 00 00 00 00       	mov    $0x0,%eax
80101003:	eb 67                	jmp    8010106c <exec+0x495>
    goto bad;
80101005:	90                   	nop
80101006:	eb 22                	jmp    8010102a <exec+0x453>
    goto bad;
80101008:	90                   	nop
80101009:	eb 1f                	jmp    8010102a <exec+0x453>
    goto bad;
8010100b:	90                   	nop
8010100c:	eb 1c                	jmp    8010102a <exec+0x453>
      goto bad;
8010100e:	90                   	nop
8010100f:	eb 19                	jmp    8010102a <exec+0x453>
      goto bad;
80101011:	90                   	nop
80101012:	eb 16                	jmp    8010102a <exec+0x453>
      goto bad;
80101014:	90                   	nop
80101015:	eb 13                	jmp    8010102a <exec+0x453>
      goto bad;
80101017:	90                   	nop
80101018:	eb 10                	jmp    8010102a <exec+0x453>
      goto bad;
8010101a:	90                   	nop
8010101b:	eb 0d                	jmp    8010102a <exec+0x453>
      goto bad;
8010101d:	90                   	nop
8010101e:	eb 0a                	jmp    8010102a <exec+0x453>
    goto bad;
80101020:	90                   	nop
80101021:	eb 07                	jmp    8010102a <exec+0x453>
      goto bad;
80101023:	90                   	nop
80101024:	eb 04                	jmp    8010102a <exec+0x453>
      goto bad;
80101026:	90                   	nop
80101027:	eb 01                	jmp    8010102a <exec+0x453>
    goto bad;
80101029:	90                   	nop

 bad:
  cprintf("bad \n");
8010102a:	83 ec 0c             	sub    $0xc,%esp
8010102d:	68 88 a8 10 80       	push   $0x8010a888
80101032:	e8 d5 f3 ff ff       	call   8010040c <cprintf>
80101037:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
8010103a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010103e:	74 0e                	je     8010104e <exec+0x477>
    freevm(pgdir);
80101040:	83 ec 0c             	sub    $0xc,%esp
80101043:	ff 75 d4             	push   -0x2c(%ebp)
80101046:	e8 e2 6e 00 00       	call   80107f2d <freevm>
8010104b:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010104e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101052:	74 13                	je     80101067 <exec+0x490>
    iunlockput(ip);
80101054:	83 ec 0c             	sub    $0xc,%esp
80101057:	ff 75 d8             	push   -0x28(%ebp)
8010105a:	e8 c7 0c 00 00       	call   80101d26 <iunlockput>
8010105f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101062:	e8 07 22 00 00       	call   8010326e <end_op>
  }
  return -1;
80101067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010106c:	c9                   	leave
8010106d:	c3                   	ret

8010106e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010106e:	f3 0f 1e fb          	endbr32
80101072:	55                   	push   %ebp
80101073:	89 e5                	mov    %esp,%ebp
80101075:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101078:	83 ec 08             	sub    $0x8,%esp
8010107b:	68 8e a8 10 80       	push   $0x8010a88e
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 fa 39 00 00       	call   80104a84 <initlock>
8010108a:	83 c4 10             	add    $0x10,%esp
}
8010108d:	90                   	nop
8010108e:	c9                   	leave
8010108f:	c3                   	ret

80101090 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101090:	f3 0f 1e fb          	endbr32
80101094:	55                   	push   %ebp
80101095:	89 e5                	mov    %esp,%ebp
80101097:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010109a:	83 ec 0c             	sub    $0xc,%esp
8010109d:	68 60 2d 19 80       	push   $0x80192d60
801010a2:	e8 03 3a 00 00       	call   80104aaa <acquire>
801010a7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010aa:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
801010b1:	eb 2d                	jmp    801010e0 <filealloc+0x50>
    if(f->ref == 0){
801010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010b6:	8b 40 04             	mov    0x4(%eax),%eax
801010b9:	85 c0                	test   %eax,%eax
801010bb:	75 1f                	jne    801010dc <filealloc+0x4c>
      f->ref = 1;
801010bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010c0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010c7:	83 ec 0c             	sub    $0xc,%esp
801010ca:	68 60 2d 19 80       	push   $0x80192d60
801010cf:	e8 48 3a 00 00       	call   80104b1c <release>
801010d4:	83 c4 10             	add    $0x10,%esp
      return f;
801010d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010da:	eb 23                	jmp    801010ff <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010dc:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010e0:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
801010e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010e8:	72 c9                	jb     801010b3 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010ea:	83 ec 0c             	sub    $0xc,%esp
801010ed:	68 60 2d 19 80       	push   $0x80192d60
801010f2:	e8 25 3a 00 00       	call   80104b1c <release>
801010f7:	83 c4 10             	add    $0x10,%esp
  return 0;
801010fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010ff:	c9                   	leave
80101100:	c3                   	ret

80101101 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101101:	f3 0f 1e fb          	endbr32
80101105:	55                   	push   %ebp
80101106:	89 e5                	mov    %esp,%ebp
80101108:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	68 60 2d 19 80       	push   $0x80192d60
80101113:	e8 92 39 00 00       	call   80104aaa <acquire>
80101118:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010111b:	8b 45 08             	mov    0x8(%ebp),%eax
8010111e:	8b 40 04             	mov    0x4(%eax),%eax
80101121:	85 c0                	test   %eax,%eax
80101123:	7f 0d                	jg     80101132 <filedup+0x31>
    panic("filedup");
80101125:	83 ec 0c             	sub    $0xc,%esp
80101128:	68 95 a8 10 80       	push   $0x8010a895
8010112d:	e8 ac f4 ff ff       	call   801005de <panic>
  f->ref++;
80101132:	8b 45 08             	mov    0x8(%ebp),%eax
80101135:	8b 40 04             	mov    0x4(%eax),%eax
80101138:	8d 50 01             	lea    0x1(%eax),%edx
8010113b:	8b 45 08             	mov    0x8(%ebp),%eax
8010113e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101141:	83 ec 0c             	sub    $0xc,%esp
80101144:	68 60 2d 19 80       	push   $0x80192d60
80101149:	e8 ce 39 00 00       	call   80104b1c <release>
8010114e:	83 c4 10             	add    $0x10,%esp
  return f;
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101154:	c9                   	leave
80101155:	c3                   	ret

80101156 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101156:	f3 0f 1e fb          	endbr32
8010115a:	55                   	push   %ebp
8010115b:	89 e5                	mov    %esp,%ebp
8010115d:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101160:	83 ec 0c             	sub    $0xc,%esp
80101163:	68 60 2d 19 80       	push   $0x80192d60
80101168:	e8 3d 39 00 00       	call   80104aaa <acquire>
8010116d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 04             	mov    0x4(%eax),%eax
80101176:	85 c0                	test   %eax,%eax
80101178:	7f 0d                	jg     80101187 <fileclose+0x31>
    panic("fileclose");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 9d a8 10 80       	push   $0x8010a89d
80101182:	e8 57 f4 ff ff       	call   801005de <panic>
  if(--f->ref > 0){
80101187:	8b 45 08             	mov    0x8(%ebp),%eax
8010118a:	8b 40 04             	mov    0x4(%eax),%eax
8010118d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	89 50 04             	mov    %edx,0x4(%eax)
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	8b 40 04             	mov    0x4(%eax),%eax
8010119c:	85 c0                	test   %eax,%eax
8010119e:	7e 15                	jle    801011b5 <fileclose+0x5f>
    release(&ftable.lock);
801011a0:	83 ec 0c             	sub    $0xc,%esp
801011a3:	68 60 2d 19 80       	push   $0x80192d60
801011a8:	e8 6f 39 00 00       	call   80104b1c <release>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	e9 8b 00 00 00       	jmp    80101240 <fileclose+0xea>
    return;
  }
  ff = *f;
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 10                	mov    (%eax),%edx
801011ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011bd:	8b 50 04             	mov    0x4(%eax),%edx
801011c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011c3:	8b 50 08             	mov    0x8(%eax),%edx
801011c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011c9:	8b 50 0c             	mov    0xc(%eax),%edx
801011cc:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011cf:	8b 50 10             	mov    0x10(%eax),%edx
801011d2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011d5:	8b 40 14             	mov    0x14(%eax),%eax
801011d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011e5:	8b 45 08             	mov    0x8(%ebp),%eax
801011e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011ee:	83 ec 0c             	sub    $0xc,%esp
801011f1:	68 60 2d 19 80       	push   $0x80192d60
801011f6:	e8 21 39 00 00       	call   80104b1c <release>
801011fb:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101201:	83 f8 01             	cmp    $0x1,%eax
80101204:	75 19                	jne    8010121f <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101206:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010120a:	0f be d0             	movsbl %al,%edx
8010120d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101210:	83 ec 08             	sub    $0x8,%esp
80101213:	52                   	push   %edx
80101214:	50                   	push   %eax
80101215:	e8 73 26 00 00       	call   8010388d <pipeclose>
8010121a:	83 c4 10             	add    $0x10,%esp
8010121d:	eb 21                	jmp    80101240 <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010121f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101222:	83 f8 02             	cmp    $0x2,%eax
80101225:	75 19                	jne    80101240 <fileclose+0xea>
    begin_op();
80101227:	e8 b2 1f 00 00       	call   801031de <begin_op>
    iput(ff.ip);
8010122c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010122f:	83 ec 0c             	sub    $0xc,%esp
80101232:	50                   	push   %eax
80101233:	e8 1a 0a 00 00       	call   80101c52 <iput>
80101238:	83 c4 10             	add    $0x10,%esp
    end_op();
8010123b:	e8 2e 20 00 00       	call   8010326e <end_op>
  }
}
80101240:	c9                   	leave
80101241:	c3                   	ret

80101242 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101242:	f3 0f 1e fb          	endbr32
80101246:	55                   	push   %ebp
80101247:	89 e5                	mov    %esp,%ebp
80101249:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 00                	mov    (%eax),%eax
80101251:	83 f8 02             	cmp    $0x2,%eax
80101254:	75 40                	jne    80101296 <filestat+0x54>
    ilock(f->ip);
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	83 ec 0c             	sub    $0xc,%esp
8010125f:	50                   	push   %eax
80101260:	e8 84 08 00 00       	call   80101ae9 <ilock>
80101265:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101268:	8b 45 08             	mov    0x8(%ebp),%eax
8010126b:	8b 40 10             	mov    0x10(%eax),%eax
8010126e:	83 ec 08             	sub    $0x8,%esp
80101271:	ff 75 0c             	push   0xc(%ebp)
80101274:	50                   	push   %eax
80101275:	e8 2d 0d 00 00       	call   80101fa7 <stati>
8010127a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 74 09 00 00       	call   80101c00 <iunlock>
8010128c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010128f:	b8 00 00 00 00       	mov    $0x0,%eax
80101294:	eb 05                	jmp    8010129b <filestat+0x59>
  }
  return -1;
80101296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010129b:	c9                   	leave
8010129c:	c3                   	ret

8010129d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010129d:	f3 0f 1e fb          	endbr32
801012a1:	55                   	push   %ebp
801012a2:	89 e5                	mov    %esp,%ebp
801012a4:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012ae:	84 c0                	test   %al,%al
801012b0:	75 0a                	jne    801012bc <fileread+0x1f>
    return -1;
801012b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b7:	e9 9b 00 00 00       	jmp    80101357 <fileread+0xba>
  if(f->type == FD_PIPE)
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 00                	mov    (%eax),%eax
801012c1:	83 f8 01             	cmp    $0x1,%eax
801012c4:	75 1a                	jne    801012e0 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 0c             	mov    0xc(%eax),%eax
801012cc:	83 ec 04             	sub    $0x4,%esp
801012cf:	ff 75 10             	push   0x10(%ebp)
801012d2:	ff 75 0c             	push   0xc(%ebp)
801012d5:	50                   	push   %eax
801012d6:	e8 67 27 00 00       	call   80103a42 <piperead>
801012db:	83 c4 10             	add    $0x10,%esp
801012de:	eb 77                	jmp    80101357 <fileread+0xba>
  if(f->type == FD_INODE){
801012e0:	8b 45 08             	mov    0x8(%ebp),%eax
801012e3:	8b 00                	mov    (%eax),%eax
801012e5:	83 f8 02             	cmp    $0x2,%eax
801012e8:	75 60                	jne    8010134a <fileread+0xad>
    ilock(f->ip);
801012ea:	8b 45 08             	mov    0x8(%ebp),%eax
801012ed:	8b 40 10             	mov    0x10(%eax),%eax
801012f0:	83 ec 0c             	sub    $0xc,%esp
801012f3:	50                   	push   %eax
801012f4:	e8 f0 07 00 00       	call   80101ae9 <ilock>
801012f9:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101302:	8b 50 14             	mov    0x14(%eax),%edx
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 40 10             	mov    0x10(%eax),%eax
8010130b:	51                   	push   %ecx
8010130c:	52                   	push   %edx
8010130d:	ff 75 0c             	push   0xc(%ebp)
80101310:	50                   	push   %eax
80101311:	e8 db 0c 00 00       	call   80101ff1 <readi>
80101316:	83 c4 10             	add    $0x10,%esp
80101319:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010131c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101320:	7e 11                	jle    80101333 <fileread+0x96>
      f->off += r;
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 50 14             	mov    0x14(%eax),%edx
80101328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132b:	01 c2                	add    %eax,%edx
8010132d:	8b 45 08             	mov    0x8(%ebp),%eax
80101330:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 40 10             	mov    0x10(%eax),%eax
80101339:	83 ec 0c             	sub    $0xc,%esp
8010133c:	50                   	push   %eax
8010133d:	e8 be 08 00 00       	call   80101c00 <iunlock>
80101342:	83 c4 10             	add    $0x10,%esp
    return r;
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	eb 0d                	jmp    80101357 <fileread+0xba>
  }
  panic("fileread");
8010134a:	83 ec 0c             	sub    $0xc,%esp
8010134d:	68 a7 a8 10 80       	push   $0x8010a8a7
80101352:	e8 87 f2 ff ff       	call   801005de <panic>
}
80101357:	c9                   	leave
80101358:	c3                   	ret

80101359 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101359:	f3 0f 1e fb          	endbr32
8010135d:	55                   	push   %ebp
8010135e:	89 e5                	mov    %esp,%ebp
80101360:	53                   	push   %ebx
80101361:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101364:	8b 45 08             	mov    0x8(%ebp),%eax
80101367:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010136b:	84 c0                	test   %al,%al
8010136d:	75 0a                	jne    80101379 <filewrite+0x20>
    return -1;
8010136f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101374:	e9 1b 01 00 00       	jmp    80101494 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101379:	8b 45 08             	mov    0x8(%ebp),%eax
8010137c:	8b 00                	mov    (%eax),%eax
8010137e:	83 f8 01             	cmp    $0x1,%eax
80101381:	75 1d                	jne    801013a0 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101383:	8b 45 08             	mov    0x8(%ebp),%eax
80101386:	8b 40 0c             	mov    0xc(%eax),%eax
80101389:	83 ec 04             	sub    $0x4,%esp
8010138c:	ff 75 10             	push   0x10(%ebp)
8010138f:	ff 75 0c             	push   0xc(%ebp)
80101392:	50                   	push   %eax
80101393:	e8 a4 25 00 00       	call   8010393c <pipewrite>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	e9 f4 00 00 00       	jmp    80101494 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	8b 00                	mov    (%eax),%eax
801013a5:	83 f8 02             	cmp    $0x2,%eax
801013a8:	0f 85 d9 00 00 00    	jne    80101487 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013ae:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013bc:	e9 a3 00 00 00       	jmp    80101464 <filewrite+0x10b>
      int n1 = n - i;
801013c1:	8b 45 10             	mov    0x10(%ebp),%eax
801013c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013d0:	7e 06                	jle    801013d8 <filewrite+0x7f>
        n1 = max;
801013d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013d5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013d8:	e8 01 1e 00 00       	call   801031de <begin_op>
      ilock(f->ip);
801013dd:	8b 45 08             	mov    0x8(%ebp),%eax
801013e0:	8b 40 10             	mov    0x10(%eax),%eax
801013e3:	83 ec 0c             	sub    $0xc,%esp
801013e6:	50                   	push   %eax
801013e7:	e8 fd 06 00 00       	call   80101ae9 <ilock>
801013ec:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013ef:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013f2:	8b 45 08             	mov    0x8(%ebp),%eax
801013f5:	8b 50 14             	mov    0x14(%eax),%edx
801013f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801013fe:	01 c3                	add    %eax,%ebx
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	8b 40 10             	mov    0x10(%eax),%eax
80101406:	51                   	push   %ecx
80101407:	52                   	push   %edx
80101408:	53                   	push   %ebx
80101409:	50                   	push   %eax
8010140a:	e8 3b 0d 00 00       	call   8010214a <writei>
8010140f:	83 c4 10             	add    $0x10,%esp
80101412:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101415:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101419:	7e 11                	jle    8010142c <filewrite+0xd3>
        f->off += r;
8010141b:	8b 45 08             	mov    0x8(%ebp),%eax
8010141e:	8b 50 14             	mov    0x14(%eax),%edx
80101421:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101424:	01 c2                	add    %eax,%edx
80101426:	8b 45 08             	mov    0x8(%ebp),%eax
80101429:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	8b 40 10             	mov    0x10(%eax),%eax
80101432:	83 ec 0c             	sub    $0xc,%esp
80101435:	50                   	push   %eax
80101436:	e8 c5 07 00 00       	call   80101c00 <iunlock>
8010143b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010143e:	e8 2b 1e 00 00       	call   8010326e <end_op>

      if(r < 0)
80101443:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101447:	78 29                	js     80101472 <filewrite+0x119>
        break;
      if(r != n1)
80101449:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010144c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010144f:	74 0d                	je     8010145e <filewrite+0x105>
        panic("short filewrite");
80101451:	83 ec 0c             	sub    $0xc,%esp
80101454:	68 b0 a8 10 80       	push   $0x8010a8b0
80101459:	e8 80 f1 ff ff       	call   801005de <panic>
      i += r;
8010145e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101461:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	3b 45 10             	cmp    0x10(%ebp),%eax
8010146a:	0f 8c 51 ff ff ff    	jl     801013c1 <filewrite+0x68>
80101470:	eb 01                	jmp    80101473 <filewrite+0x11a>
        break;
80101472:	90                   	nop
    }
    return i == n ? n : -1;
80101473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101476:	3b 45 10             	cmp    0x10(%ebp),%eax
80101479:	75 05                	jne    80101480 <filewrite+0x127>
8010147b:	8b 45 10             	mov    0x10(%ebp),%eax
8010147e:	eb 14                	jmp    80101494 <filewrite+0x13b>
80101480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101485:	eb 0d                	jmp    80101494 <filewrite+0x13b>
  }
  panic("filewrite");
80101487:	83 ec 0c             	sub    $0xc,%esp
8010148a:	68 c0 a8 10 80       	push   $0x8010a8c0
8010148f:	e8 4a f1 ff ff       	call   801005de <panic>
}
80101494:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101497:	c9                   	leave
80101498:	c3                   	ret

80101499 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101499:	f3 0f 1e fb          	endbr32
8010149d:	55                   	push   %ebp
8010149e:	89 e5                	mov    %esp,%ebp
801014a0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014a3:	8b 45 08             	mov    0x8(%ebp),%eax
801014a6:	83 ec 08             	sub    $0x8,%esp
801014a9:	6a 01                	push   $0x1
801014ab:	50                   	push   %eax
801014ac:	e8 58 ed ff ff       	call   80100209 <bread>
801014b1:	83 c4 10             	add    $0x10,%esp
801014b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ba:	83 c0 5c             	add    $0x5c,%eax
801014bd:	83 ec 04             	sub    $0x4,%esp
801014c0:	6a 1c                	push   $0x1c
801014c2:	50                   	push   %eax
801014c3:	ff 75 0c             	push   0xc(%ebp)
801014c6:	e8 35 39 00 00       	call   80104e00 <memmove>
801014cb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014ce:	83 ec 0c             	sub    $0xc,%esp
801014d1:	ff 75 f4             	push   -0xc(%ebp)
801014d4:	e8 ba ed ff ff       	call   80100293 <brelse>
801014d9:	83 c4 10             	add    $0x10,%esp
}
801014dc:	90                   	nop
801014dd:	c9                   	leave
801014de:	c3                   	ret

801014df <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014df:	f3 0f 1e fb          	endbr32
801014e3:	55                   	push   %ebp
801014e4:	89 e5                	mov    %esp,%ebp
801014e6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801014ec:	8b 45 08             	mov    0x8(%ebp),%eax
801014ef:	83 ec 08             	sub    $0x8,%esp
801014f2:	52                   	push   %edx
801014f3:	50                   	push   %eax
801014f4:	e8 10 ed ff ff       	call   80100209 <bread>
801014f9:	83 c4 10             	add    $0x10,%esp
801014fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101502:	83 c0 5c             	add    $0x5c,%eax
80101505:	83 ec 04             	sub    $0x4,%esp
80101508:	68 00 02 00 00       	push   $0x200
8010150d:	6a 00                	push   $0x0
8010150f:	50                   	push   %eax
80101510:	e8 24 38 00 00       	call   80104d39 <memset>
80101515:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 f4             	push   -0xc(%ebp)
8010151e:	e8 04 1f 00 00       	call   80103427 <log_write>
80101523:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101526:	83 ec 0c             	sub    $0xc,%esp
80101529:	ff 75 f4             	push   -0xc(%ebp)
8010152c:	e8 62 ed ff ff       	call   80100293 <brelse>
80101531:	83 c4 10             	add    $0x10,%esp
}
80101534:	90                   	nop
80101535:	c9                   	leave
80101536:	c3                   	ret

80101537 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101537:	f3 0f 1e fb          	endbr32
8010153b:	55                   	push   %ebp
8010153c:	89 e5                	mov    %esp,%ebp
8010153e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101541:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101548:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010154f:	e9 13 01 00 00       	jmp    80101667 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101557:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010155d:	85 c0                	test   %eax,%eax
8010155f:	0f 48 c2             	cmovs  %edx,%eax
80101562:	c1 f8 0c             	sar    $0xc,%eax
80101565:	89 c2                	mov    %eax,%edx
80101567:	a1 78 37 19 80       	mov    0x80193778,%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	83 ec 08             	sub    $0x8,%esp
80101571:	50                   	push   %eax
80101572:	ff 75 08             	push   0x8(%ebp)
80101575:	e8 8f ec ff ff       	call   80100209 <bread>
8010157a:	83 c4 10             	add    $0x10,%esp
8010157d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101580:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101587:	e9 a6 00 00 00       	jmp    80101632 <balloc+0xfb>
      m = 1 << (bi % 8);
8010158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158f:	99                   	cltd
80101590:	c1 ea 1d             	shr    $0x1d,%edx
80101593:	01 d0                	add    %edx,%eax
80101595:	83 e0 07             	and    $0x7,%eax
80101598:	29 d0                	sub    %edx,%eax
8010159a:	ba 01 00 00 00       	mov    $0x1,%edx
8010159f:	89 c1                	mov    %eax,%ecx
801015a1:	d3 e2                	shl    %cl,%edx
801015a3:	89 d0                	mov    %edx,%eax
801015a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ab:	8d 50 07             	lea    0x7(%eax),%edx
801015ae:	85 c0                	test   %eax,%eax
801015b0:	0f 48 c2             	cmovs  %edx,%eax
801015b3:	c1 f8 03             	sar    $0x3,%eax
801015b6:	89 c2                	mov    %eax,%edx
801015b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015bb:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015c0:	0f b6 c0             	movzbl %al,%eax
801015c3:	23 45 e8             	and    -0x18(%ebp),%eax
801015c6:	85 c0                	test   %eax,%eax
801015c8:	75 64                	jne    8010162e <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	8d 50 07             	lea    0x7(%eax),%edx
801015d0:	85 c0                	test   %eax,%eax
801015d2:	0f 48 c2             	cmovs  %edx,%eax
801015d5:	c1 f8 03             	sar    $0x3,%eax
801015d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015db:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015e0:	89 d1                	mov    %edx,%ecx
801015e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015e5:	09 ca                	or     %ecx,%edx
801015e7:	89 d1                	mov    %edx,%ecx
801015e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ec:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015f0:	83 ec 0c             	sub    $0xc,%esp
801015f3:	ff 75 ec             	push   -0x14(%ebp)
801015f6:	e8 2c 1e 00 00       	call   80103427 <log_write>
801015fb:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015fe:	83 ec 0c             	sub    $0xc,%esp
80101601:	ff 75 ec             	push   -0x14(%ebp)
80101604:	e8 8a ec ff ff       	call   80100293 <brelse>
80101609:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101612:	01 c2                	add    %eax,%edx
80101614:	8b 45 08             	mov    0x8(%ebp),%eax
80101617:	83 ec 08             	sub    $0x8,%esp
8010161a:	52                   	push   %edx
8010161b:	50                   	push   %eax
8010161c:	e8 be fe ff ff       	call   801014df <bzero>
80101621:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101624:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162a:	01 d0                	add    %edx,%eax
8010162c:	eb 57                	jmp    80101685 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010162e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101632:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101639:	7f 17                	jg     80101652 <balloc+0x11b>
8010163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101641:	01 d0                	add    %edx,%eax
80101643:	89 c2                	mov    %eax,%edx
80101645:	a1 60 37 19 80       	mov    0x80193760,%eax
8010164a:	39 c2                	cmp    %eax,%edx
8010164c:	0f 82 3a ff ff ff    	jb     8010158c <balloc+0x55>
      }
    }
    brelse(bp);
80101652:	83 ec 0c             	sub    $0xc,%esp
80101655:	ff 75 ec             	push   -0x14(%ebp)
80101658:	e8 36 ec ff ff       	call   80100293 <brelse>
8010165d:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101660:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101667:	8b 15 60 37 19 80    	mov    0x80193760,%edx
8010166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101670:	39 c2                	cmp    %eax,%edx
80101672:	0f 87 dc fe ff ff    	ja     80101554 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101678:	83 ec 0c             	sub    $0xc,%esp
8010167b:	68 cc a8 10 80       	push   $0x8010a8cc
80101680:	e8 59 ef ff ff       	call   801005de <panic>
}
80101685:	c9                   	leave
80101686:	c3                   	ret

80101687 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101687:	f3 0f 1e fb          	endbr32
8010168b:	55                   	push   %ebp
8010168c:	89 e5                	mov    %esp,%ebp
8010168e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 60 37 19 80       	push   $0x80193760
80101699:	ff 75 08             	push   0x8(%ebp)
8010169c:	e8 f8 fd ff ff       	call   80101499 <readsb>
801016a1:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801016a7:	c1 e8 0c             	shr    $0xc,%eax
801016aa:	89 c2                	mov    %eax,%edx
801016ac:	a1 78 37 19 80       	mov    0x80193778,%eax
801016b1:	01 c2                	add    %eax,%edx
801016b3:	8b 45 08             	mov    0x8(%ebp),%eax
801016b6:	83 ec 08             	sub    $0x8,%esp
801016b9:	52                   	push   %edx
801016ba:	50                   	push   %eax
801016bb:	e8 49 eb ff ff       	call   80100209 <bread>
801016c0:	83 c4 10             	add    $0x10,%esp
801016c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c9:	25 ff 0f 00 00       	and    $0xfff,%eax
801016ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d4:	99                   	cltd
801016d5:	c1 ea 1d             	shr    $0x1d,%edx
801016d8:	01 d0                	add    %edx,%eax
801016da:	83 e0 07             	and    $0x7,%eax
801016dd:	29 d0                	sub    %edx,%eax
801016df:	ba 01 00 00 00       	mov    $0x1,%edx
801016e4:	89 c1                	mov    %eax,%ecx
801016e6:	d3 e2                	shl    %cl,%edx
801016e8:	89 d0                	mov    %edx,%eax
801016ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f0:	8d 50 07             	lea    0x7(%eax),%edx
801016f3:	85 c0                	test   %eax,%eax
801016f5:	0f 48 c2             	cmovs  %edx,%eax
801016f8:	c1 f8 03             	sar    $0x3,%eax
801016fb:	89 c2                	mov    %eax,%edx
801016fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101700:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101705:	0f b6 c0             	movzbl %al,%eax
80101708:	23 45 ec             	and    -0x14(%ebp),%eax
8010170b:	85 c0                	test   %eax,%eax
8010170d:	75 0d                	jne    8010171c <bfree+0x95>
    panic("freeing free block");
8010170f:	83 ec 0c             	sub    $0xc,%esp
80101712:	68 e2 a8 10 80       	push   $0x8010a8e2
80101717:	e8 c2 ee ff ff       	call   801005de <panic>
  bp->data[bi/8] &= ~m;
8010171c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171f:	8d 50 07             	lea    0x7(%eax),%edx
80101722:	85 c0                	test   %eax,%eax
80101724:	0f 48 c2             	cmovs  %edx,%eax
80101727:	c1 f8 03             	sar    $0x3,%eax
8010172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101732:	89 d1                	mov    %edx,%ecx
80101734:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101737:	f7 d2                	not    %edx
80101739:	21 ca                	and    %ecx,%edx
8010173b:	89 d1                	mov    %edx,%ecx
8010173d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101740:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101744:	83 ec 0c             	sub    $0xc,%esp
80101747:	ff 75 f4             	push   -0xc(%ebp)
8010174a:	e8 d8 1c 00 00       	call   80103427 <log_write>
8010174f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101752:	83 ec 0c             	sub    $0xc,%esp
80101755:	ff 75 f4             	push   -0xc(%ebp)
80101758:	e8 36 eb ff ff       	call   80100293 <brelse>
8010175d:	83 c4 10             	add    $0x10,%esp
}
80101760:	90                   	nop
80101761:	c9                   	leave
80101762:	c3                   	ret

80101763 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101763:	f3 0f 1e fb          	endbr32
80101767:	55                   	push   %ebp
80101768:	89 e5                	mov    %esp,%ebp
8010176a:	57                   	push   %edi
8010176b:	56                   	push   %esi
8010176c:	53                   	push   %ebx
8010176d:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101770:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101777:	83 ec 08             	sub    $0x8,%esp
8010177a:	68 f5 a8 10 80       	push   $0x8010a8f5
8010177f:	68 80 37 19 80       	push   $0x80193780
80101784:	e8 fb 32 00 00       	call   80104a84 <initlock>
80101789:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010178c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101793:	eb 2d                	jmp    801017c2 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101795:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101798:	89 d0                	mov    %edx,%eax
8010179a:	c1 e0 03             	shl    $0x3,%eax
8010179d:	01 d0                	add    %edx,%eax
8010179f:	c1 e0 04             	shl    $0x4,%eax
801017a2:	83 c0 30             	add    $0x30,%eax
801017a5:	05 80 37 19 80       	add    $0x80193780,%eax
801017aa:	83 c0 10             	add    $0x10,%eax
801017ad:	83 ec 08             	sub    $0x8,%esp
801017b0:	68 fc a8 10 80       	push   $0x8010a8fc
801017b5:	50                   	push   %eax
801017b6:	e8 5c 31 00 00       	call   80104917 <initsleeplock>
801017bb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017be:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017c2:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017c6:	7e cd                	jle    80101795 <iinit+0x32>
  }

  readsb(dev, &sb);
801017c8:	83 ec 08             	sub    $0x8,%esp
801017cb:	68 60 37 19 80       	push   $0x80193760
801017d0:	ff 75 08             	push   0x8(%ebp)
801017d3:	e8 c1 fc ff ff       	call   80101499 <readsb>
801017d8:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017db:	a1 78 37 19 80       	mov    0x80193778,%eax
801017e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017e3:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
801017e9:	8b 35 70 37 19 80    	mov    0x80193770,%esi
801017ef:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
801017f5:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
801017fb:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101801:	a1 60 37 19 80       	mov    0x80193760,%eax
80101806:	ff 75 d4             	push   -0x2c(%ebp)
80101809:	57                   	push   %edi
8010180a:	56                   	push   %esi
8010180b:	53                   	push   %ebx
8010180c:	51                   	push   %ecx
8010180d:	52                   	push   %edx
8010180e:	50                   	push   %eax
8010180f:	68 04 a9 10 80       	push   $0x8010a904
80101814:	e8 f3 eb ff ff       	call   8010040c <cprintf>
80101819:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010181c:	90                   	nop
8010181d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101820:	5b                   	pop    %ebx
80101821:	5e                   	pop    %esi
80101822:	5f                   	pop    %edi
80101823:	5d                   	pop    %ebp
80101824:	c3                   	ret

80101825 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101825:	f3 0f 1e fb          	endbr32
80101829:	55                   	push   %ebp
8010182a:	89 e5                	mov    %esp,%ebp
8010182c:	83 ec 28             	sub    $0x28,%esp
8010182f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101832:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101836:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010183d:	e9 9e 00 00 00       	jmp    801018e0 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	c1 e8 03             	shr    $0x3,%eax
80101848:	89 c2                	mov    %eax,%edx
8010184a:	a1 74 37 19 80       	mov    0x80193774,%eax
8010184f:	01 d0                	add    %edx,%eax
80101851:	83 ec 08             	sub    $0x8,%esp
80101854:	50                   	push   %eax
80101855:	ff 75 08             	push   0x8(%ebp)
80101858:	e8 ac e9 ff ff       	call   80100209 <bread>
8010185d:	83 c4 10             	add    $0x10,%esp
80101860:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101866:	8d 50 5c             	lea    0x5c(%eax),%edx
80101869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186c:	83 e0 07             	and    $0x7,%eax
8010186f:	c1 e0 06             	shl    $0x6,%eax
80101872:	01 d0                	add    %edx,%eax
80101874:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101877:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010187a:	0f b7 00             	movzwl (%eax),%eax
8010187d:	66 85 c0             	test   %ax,%ax
80101880:	75 4c                	jne    801018ce <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101882:	83 ec 04             	sub    $0x4,%esp
80101885:	6a 40                	push   $0x40
80101887:	6a 00                	push   $0x0
80101889:	ff 75 ec             	push   -0x14(%ebp)
8010188c:	e8 a8 34 00 00       	call   80104d39 <memset>
80101891:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101894:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101897:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010189b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010189e:	83 ec 0c             	sub    $0xc,%esp
801018a1:	ff 75 f0             	push   -0x10(%ebp)
801018a4:	e8 7e 1b 00 00       	call   80103427 <log_write>
801018a9:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018ac:	83 ec 0c             	sub    $0xc,%esp
801018af:	ff 75 f0             	push   -0x10(%ebp)
801018b2:	e8 dc e9 ff ff       	call   80100293 <brelse>
801018b7:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bd:	83 ec 08             	sub    $0x8,%esp
801018c0:	50                   	push   %eax
801018c1:	ff 75 08             	push   0x8(%ebp)
801018c4:	e8 fc 00 00 00       	call   801019c5 <iget>
801018c9:	83 c4 10             	add    $0x10,%esp
801018cc:	eb 30                	jmp    801018fe <ialloc+0xd9>
    }
    brelse(bp);
801018ce:	83 ec 0c             	sub    $0xc,%esp
801018d1:	ff 75 f0             	push   -0x10(%ebp)
801018d4:	e8 ba e9 ff ff       	call   80100293 <brelse>
801018d9:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018e0:	8b 15 68 37 19 80    	mov    0x80193768,%edx
801018e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e9:	39 c2                	cmp    %eax,%edx
801018eb:	0f 87 51 ff ff ff    	ja     80101842 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018f1:	83 ec 0c             	sub    $0xc,%esp
801018f4:	68 57 a9 10 80       	push   $0x8010a957
801018f9:	e8 e0 ec ff ff       	call   801005de <panic>
}
801018fe:	c9                   	leave
801018ff:	c3                   	ret

80101900 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101900:	f3 0f 1e fb          	endbr32
80101904:	55                   	push   %ebp
80101905:	89 e5                	mov    %esp,%ebp
80101907:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010190a:	8b 45 08             	mov    0x8(%ebp),%eax
8010190d:	8b 40 04             	mov    0x4(%eax),%eax
80101910:	c1 e8 03             	shr    $0x3,%eax
80101913:	89 c2                	mov    %eax,%edx
80101915:	a1 74 37 19 80       	mov    0x80193774,%eax
8010191a:	01 c2                	add    %eax,%edx
8010191c:	8b 45 08             	mov    0x8(%ebp),%eax
8010191f:	8b 00                	mov    (%eax),%eax
80101921:	83 ec 08             	sub    $0x8,%esp
80101924:	52                   	push   %edx
80101925:	50                   	push   %eax
80101926:	e8 de e8 ff ff       	call   80100209 <bread>
8010192b:	83 c4 10             	add    $0x10,%esp
8010192e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101934:	8d 50 5c             	lea    0x5c(%eax),%edx
80101937:	8b 45 08             	mov    0x8(%ebp),%eax
8010193a:	8b 40 04             	mov    0x4(%eax),%eax
8010193d:	83 e0 07             	and    $0x7,%eax
80101940:	c1 e0 06             	shl    $0x6,%eax
80101943:	01 d0                	add    %edx,%eax
80101945:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101948:	8b 45 08             	mov    0x8(%ebp),%eax
8010194b:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101952:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010197f:	8b 45 08             	mov    0x8(%ebp),%eax
80101982:	8b 50 58             	mov    0x58(%eax),%edx
80101985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101988:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101994:	83 c0 0c             	add    $0xc,%eax
80101997:	83 ec 04             	sub    $0x4,%esp
8010199a:	6a 34                	push   $0x34
8010199c:	52                   	push   %edx
8010199d:	50                   	push   %eax
8010199e:	e8 5d 34 00 00       	call   80104e00 <memmove>
801019a3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019a6:	83 ec 0c             	sub    $0xc,%esp
801019a9:	ff 75 f4             	push   -0xc(%ebp)
801019ac:	e8 76 1a 00 00       	call   80103427 <log_write>
801019b1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019b4:	83 ec 0c             	sub    $0xc,%esp
801019b7:	ff 75 f4             	push   -0xc(%ebp)
801019ba:	e8 d4 e8 ff ff       	call   80100293 <brelse>
801019bf:	83 c4 10             	add    $0x10,%esp
}
801019c2:	90                   	nop
801019c3:	c9                   	leave
801019c4:	c3                   	ret

801019c5 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019c5:	f3 0f 1e fb          	endbr32
801019c9:	55                   	push   %ebp
801019ca:	89 e5                	mov    %esp,%ebp
801019cc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019cf:	83 ec 0c             	sub    $0xc,%esp
801019d2:	68 80 37 19 80       	push   $0x80193780
801019d7:	e8 ce 30 00 00       	call   80104aaa <acquire>
801019dc:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019e6:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
801019ed:	eb 60                	jmp    80101a4f <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f2:	8b 40 08             	mov    0x8(%eax),%eax
801019f5:	85 c0                	test   %eax,%eax
801019f7:	7e 39                	jle    80101a32 <iget+0x6d>
801019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fc:	8b 00                	mov    (%eax),%eax
801019fe:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a01:	75 2f                	jne    80101a32 <iget+0x6d>
80101a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a06:	8b 40 04             	mov    0x4(%eax),%eax
80101a09:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a0c:	75 24                	jne    80101a32 <iget+0x6d>
      ip->ref++;
80101a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a11:	8b 40 08             	mov    0x8(%eax),%eax
80101a14:	8d 50 01             	lea    0x1(%eax),%edx
80101a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1a:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a1d:	83 ec 0c             	sub    $0xc,%esp
80101a20:	68 80 37 19 80       	push   $0x80193780
80101a25:	e8 f2 30 00 00       	call   80104b1c <release>
80101a2a:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a30:	eb 77                	jmp    80101aa9 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a36:	75 10                	jne    80101a48 <iget+0x83>
80101a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3b:	8b 40 08             	mov    0x8(%eax),%eax
80101a3e:	85 c0                	test   %eax,%eax
80101a40:	75 06                	jne    80101a48 <iget+0x83>
      empty = ip;
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a48:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a4f:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
80101a56:	72 97                	jb     801019ef <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a5c:	75 0d                	jne    80101a6b <iget+0xa6>
    panic("iget: no inodes");
80101a5e:	83 ec 0c             	sub    $0xc,%esp
80101a61:	68 69 a9 10 80       	push   $0x8010a969
80101a66:	e8 73 eb ff ff       	call   801005de <panic>

  ip = empty;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a74:	8b 55 08             	mov    0x8(%ebp),%edx
80101a77:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a7f:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 80 37 19 80       	push   $0x80193780
80101a9e:	e8 79 30 00 00       	call   80104b1c <release>
80101aa3:	83 c4 10             	add    $0x10,%esp

  return ip;
80101aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101aa9:	c9                   	leave
80101aaa:	c3                   	ret

80101aab <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101aab:	f3 0f 1e fb          	endbr32
80101aaf:	55                   	push   %ebp
80101ab0:	89 e5                	mov    %esp,%ebp
80101ab2:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ab5:	83 ec 0c             	sub    $0xc,%esp
80101ab8:	68 80 37 19 80       	push   $0x80193780
80101abd:	e8 e8 2f 00 00       	call   80104aaa <acquire>
80101ac2:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	8b 40 08             	mov    0x8(%eax),%eax
80101acb:	8d 50 01             	lea    0x1(%eax),%edx
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	68 80 37 19 80       	push   $0x80193780
80101adc:	e8 3b 30 00 00       	call   80104b1c <release>
80101ae1:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ae7:	c9                   	leave
80101ae8:	c3                   	ret

80101ae9 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ae9:	f3 0f 1e fb          	endbr32
80101aed:	55                   	push   %ebp
80101aee:	89 e5                	mov    %esp,%ebp
80101af0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101af3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af7:	74 0a                	je     80101b03 <ilock+0x1a>
80101af9:	8b 45 08             	mov    0x8(%ebp),%eax
80101afc:	8b 40 08             	mov    0x8(%eax),%eax
80101aff:	85 c0                	test   %eax,%eax
80101b01:	7f 0d                	jg     80101b10 <ilock+0x27>
    panic("ilock");
80101b03:	83 ec 0c             	sub    $0xc,%esp
80101b06:	68 79 a9 10 80       	push   $0x8010a979
80101b0b:	e8 ce ea ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	83 c0 0c             	add    $0xc,%eax
80101b16:	83 ec 0c             	sub    $0xc,%esp
80101b19:	50                   	push   %eax
80101b1a:	e8 38 2e 00 00       	call   80104957 <acquiresleep>
80101b1f:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b28:	85 c0                	test   %eax,%eax
80101b2a:	0f 85 cd 00 00 00    	jne    80101bfd <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 40 04             	mov    0x4(%eax),%eax
80101b36:	c1 e8 03             	shr    $0x3,%eax
80101b39:	89 c2                	mov    %eax,%edx
80101b3b:	a1 74 37 19 80       	mov    0x80193774,%eax
80101b40:	01 c2                	add    %eax,%edx
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 00                	mov    (%eax),%eax
80101b47:	83 ec 08             	sub    $0x8,%esp
80101b4a:	52                   	push   %edx
80101b4b:	50                   	push   %eax
80101b4c:	e8 b8 e6 ff ff       	call   80100209 <bread>
80101b51:	83 c4 10             	add    $0x10,%esp
80101b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b60:	8b 40 04             	mov    0x4(%eax),%eax
80101b63:	83 e0 07             	and    $0x7,%eax
80101b66:	c1 e0 06             	shl    $0x6,%eax
80101b69:	01 d0                	add    %edx,%eax
80101b6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b71:	0f b7 10             	movzwl (%eax),%edx
80101b74:	8b 45 08             	mov    0x8(%ebp),%eax
80101b77:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b7e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b8c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba8:	8b 50 08             	mov    0x8(%eax),%edx
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb4:	8d 50 0c             	lea    0xc(%eax),%edx
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	83 c0 5c             	add    $0x5c,%eax
80101bbd:	83 ec 04             	sub    $0x4,%esp
80101bc0:	6a 34                	push   $0x34
80101bc2:	52                   	push   %edx
80101bc3:	50                   	push   %eax
80101bc4:	e8 37 32 00 00       	call   80104e00 <memmove>
80101bc9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bcc:	83 ec 0c             	sub    $0xc,%esp
80101bcf:	ff 75 f4             	push   -0xc(%ebp)
80101bd2:	e8 bc e6 ff ff       	call   80100293 <brelse>
80101bd7:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bda:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdd:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101beb:	66 85 c0             	test   %ax,%ax
80101bee:	75 0d                	jne    80101bfd <ilock+0x114>
      panic("ilock: no type");
80101bf0:	83 ec 0c             	sub    $0xc,%esp
80101bf3:	68 7f a9 10 80       	push   $0x8010a97f
80101bf8:	e8 e1 e9 ff ff       	call   801005de <panic>
  }
}
80101bfd:	90                   	nop
80101bfe:	c9                   	leave
80101bff:	c3                   	ret

80101c00 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c00:	f3 0f 1e fb          	endbr32
80101c04:	55                   	push   %ebp
80101c05:	89 e5                	mov    %esp,%ebp
80101c07:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c0a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c0e:	74 20                	je     80101c30 <iunlock+0x30>
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	83 c0 0c             	add    $0xc,%eax
80101c16:	83 ec 0c             	sub    $0xc,%esp
80101c19:	50                   	push   %eax
80101c1a:	e8 f2 2d 00 00       	call   80104a11 <holdingsleep>
80101c1f:	83 c4 10             	add    $0x10,%esp
80101c22:	85 c0                	test   %eax,%eax
80101c24:	74 0a                	je     80101c30 <iunlock+0x30>
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 40 08             	mov    0x8(%eax),%eax
80101c2c:	85 c0                	test   %eax,%eax
80101c2e:	7f 0d                	jg     80101c3d <iunlock+0x3d>
    panic("iunlock");
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 8e a9 10 80       	push   $0x8010a98e
80101c38:	e8 a1 e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	83 c0 0c             	add    $0xc,%eax
80101c43:	83 ec 0c             	sub    $0xc,%esp
80101c46:	50                   	push   %eax
80101c47:	e8 73 2d 00 00       	call   801049bf <releasesleep>
80101c4c:	83 c4 10             	add    $0x10,%esp
}
80101c4f:	90                   	nop
80101c50:	c9                   	leave
80101c51:	c3                   	ret

80101c52 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c52:	f3 0f 1e fb          	endbr32
80101c56:	55                   	push   %ebp
80101c57:	89 e5                	mov    %esp,%ebp
80101c59:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	83 c0 0c             	add    $0xc,%eax
80101c62:	83 ec 0c             	sub    $0xc,%esp
80101c65:	50                   	push   %eax
80101c66:	e8 ec 2c 00 00       	call   80104957 <acquiresleep>
80101c6b:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c71:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c74:	85 c0                	test   %eax,%eax
80101c76:	74 6a                	je     80101ce2 <iput+0x90>
80101c78:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c7f:	66 85 c0             	test   %ax,%ax
80101c82:	75 5e                	jne    80101ce2 <iput+0x90>
    acquire(&icache.lock);
80101c84:	83 ec 0c             	sub    $0xc,%esp
80101c87:	68 80 37 19 80       	push   $0x80193780
80101c8c:	e8 19 2e 00 00       	call   80104aaa <acquire>
80101c91:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c94:	8b 45 08             	mov    0x8(%ebp),%eax
80101c97:	8b 40 08             	mov    0x8(%eax),%eax
80101c9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c9d:	83 ec 0c             	sub    $0xc,%esp
80101ca0:	68 80 37 19 80       	push   $0x80193780
80101ca5:	e8 72 2e 00 00       	call   80104b1c <release>
80101caa:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101cad:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cb1:	75 2f                	jne    80101ce2 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	ff 75 08             	push   0x8(%ebp)
80101cb9:	e8 b5 01 00 00       	call   80101e73 <itrunc>
80101cbe:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	ff 75 08             	push   0x8(%ebp)
80101cd0:	e8 2b fc ff ff       	call   80101900 <iupdate>
80101cd5:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	83 c0 0c             	add    $0xc,%eax
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	50                   	push   %eax
80101cec:	e8 ce 2c 00 00       	call   801049bf <releasesleep>
80101cf1:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101cf4:	83 ec 0c             	sub    $0xc,%esp
80101cf7:	68 80 37 19 80       	push   $0x80193780
80101cfc:	e8 a9 2d 00 00       	call   80104aaa <acquire>
80101d01:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	8b 40 08             	mov    0x8(%eax),%eax
80101d0a:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d10:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d13:	83 ec 0c             	sub    $0xc,%esp
80101d16:	68 80 37 19 80       	push   $0x80193780
80101d1b:	e8 fc 2d 00 00       	call   80104b1c <release>
80101d20:	83 c4 10             	add    $0x10,%esp
}
80101d23:	90                   	nop
80101d24:	c9                   	leave
80101d25:	c3                   	ret

80101d26 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d26:	f3 0f 1e fb          	endbr32
80101d2a:	55                   	push   %ebp
80101d2b:	89 e5                	mov    %esp,%ebp
80101d2d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 08             	push   0x8(%ebp)
80101d36:	e8 c5 fe ff ff       	call   80101c00 <iunlock>
80101d3b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 08             	push   0x8(%ebp)
80101d44:	e8 09 ff ff ff       	call   80101c52 <iput>
80101d49:	83 c4 10             	add    $0x10,%esp
}
80101d4c:	90                   	nop
80101d4d:	c9                   	leave
80101d4e:	c3                   	ret

80101d4f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d4f:	f3 0f 1e fb          	endbr32
80101d53:	55                   	push   %ebp
80101d54:	89 e5                	mov    %esp,%ebp
80101d56:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d59:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d5d:	77 42                	ja     80101da1 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d62:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d65:	83 c2 14             	add    $0x14,%edx
80101d68:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d73:	75 24                	jne    80101d99 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d75:	8b 45 08             	mov    0x8(%ebp),%eax
80101d78:	8b 00                	mov    (%eax),%eax
80101d7a:	83 ec 0c             	sub    $0xc,%esp
80101d7d:	50                   	push   %eax
80101d7e:	e8 b4 f7 ff ff       	call   80101537 <balloc>
80101d83:	83 c4 10             	add    $0x10,%esp
80101d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d89:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d8f:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d95:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9c:	e9 d0 00 00 00       	jmp    80101e71 <bmap+0x122>
  }
  bn -= NDIRECT;
80101da1:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101da5:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101da9:	0f 87 b5 00 00 00    	ja     80101e64 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dbf:	75 20                	jne    80101de1 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 00                	mov    (%eax),%eax
80101dc6:	83 ec 0c             	sub    $0xc,%esp
80101dc9:	50                   	push   %eax
80101dca:	e8 68 f7 ff ff       	call   80101537 <balloc>
80101dcf:	83 c4 10             	add    $0x10,%esp
80101dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ddb:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101de1:	8b 45 08             	mov    0x8(%ebp),%eax
80101de4:	8b 00                	mov    (%eax),%eax
80101de6:	83 ec 08             	sub    $0x8,%esp
80101de9:	ff 75 f4             	push   -0xc(%ebp)
80101dec:	50                   	push   %eax
80101ded:	e8 17 e4 ff ff       	call   80100209 <bread>
80101df2:	83 c4 10             	add    $0x10,%esp
80101df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfb:	83 c0 5c             	add    $0x5c,%eax
80101dfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0e:	01 d0                	add    %edx,%eax
80101e10:	8b 00                	mov    (%eax),%eax
80101e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e19:	75 36                	jne    80101e51 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1e:	8b 00                	mov    (%eax),%eax
80101e20:	83 ec 0c             	sub    $0xc,%esp
80101e23:	50                   	push   %eax
80101e24:	e8 0e f7 ff ff       	call   80101537 <balloc>
80101e29:	83 c4 10             	add    $0x10,%esp
80101e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e32:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e3c:	01 c2                	add    %eax,%edx
80101e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e41:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e43:	83 ec 0c             	sub    $0xc,%esp
80101e46:	ff 75 f0             	push   -0x10(%ebp)
80101e49:	e8 d9 15 00 00       	call   80103427 <log_write>
80101e4e:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e51:	83 ec 0c             	sub    $0xc,%esp
80101e54:	ff 75 f0             	push   -0x10(%ebp)
80101e57:	e8 37 e4 ff ff       	call   80100293 <brelse>
80101e5c:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e62:	eb 0d                	jmp    80101e71 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e64:	83 ec 0c             	sub    $0xc,%esp
80101e67:	68 96 a9 10 80       	push   $0x8010a996
80101e6c:	e8 6d e7 ff ff       	call   801005de <panic>
}
80101e71:	c9                   	leave
80101e72:	c3                   	ret

80101e73 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e73:	f3 0f 1e fb          	endbr32
80101e77:	55                   	push   %ebp
80101e78:	89 e5                	mov    %esp,%ebp
80101e7a:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e84:	eb 45                	jmp    80101ecb <itrunc+0x58>
    if(ip->addrs[i]){
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e8c:	83 c2 14             	add    $0x14,%edx
80101e8f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e93:	85 c0                	test   %eax,%eax
80101e95:	74 30                	je     80101ec7 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e97:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9d:	83 c2 14             	add    $0x14,%edx
80101ea0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ea4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ea7:	8b 12                	mov    (%edx),%edx
80101ea9:	83 ec 08             	sub    $0x8,%esp
80101eac:	50                   	push   %eax
80101ead:	52                   	push   %edx
80101eae:	e8 d4 f7 ff ff       	call   80101687 <bfree>
80101eb3:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ebc:	83 c2 14             	add    $0x14,%edx
80101ebf:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ec6:	00 
  for(i = 0; i < NDIRECT; i++){
80101ec7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ecb:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ecf:	7e b5                	jle    80101e86 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eda:	85 c0                	test   %eax,%eax
80101edc:	0f 84 aa 00 00 00    	je     80101f8c <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	8b 00                	mov    (%eax),%eax
80101ef0:	83 ec 08             	sub    $0x8,%esp
80101ef3:	52                   	push   %edx
80101ef4:	50                   	push   %eax
80101ef5:	e8 0f e3 ff ff       	call   80100209 <bread>
80101efa:	83 c4 10             	add    $0x10,%esp
80101efd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f03:	83 c0 5c             	add    $0x5c,%eax
80101f06:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f09:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f10:	eb 3c                	jmp    80101f4e <itrunc+0xdb>
      if(a[j])
80101f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f1f:	01 d0                	add    %edx,%eax
80101f21:	8b 00                	mov    (%eax),%eax
80101f23:	85 c0                	test   %eax,%eax
80101f25:	74 23                	je     80101f4a <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f34:	01 d0                	add    %edx,%eax
80101f36:	8b 00                	mov    (%eax),%eax
80101f38:	8b 55 08             	mov    0x8(%ebp),%edx
80101f3b:	8b 12                	mov    (%edx),%edx
80101f3d:	83 ec 08             	sub    $0x8,%esp
80101f40:	50                   	push   %eax
80101f41:	52                   	push   %edx
80101f42:	e8 40 f7 ff ff       	call   80101687 <bfree>
80101f47:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f4a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f51:	83 f8 7f             	cmp    $0x7f,%eax
80101f54:	76 bc                	jbe    80101f12 <itrunc+0x9f>
    }
    brelse(bp);
80101f56:	83 ec 0c             	sub    $0xc,%esp
80101f59:	ff 75 ec             	push   -0x14(%ebp)
80101f5c:	e8 32 e3 ff ff       	call   80100293 <brelse>
80101f61:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f64:	8b 45 08             	mov    0x8(%ebp),%eax
80101f67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f6d:	8b 55 08             	mov    0x8(%ebp),%edx
80101f70:	8b 12                	mov    (%edx),%edx
80101f72:	83 ec 08             	sub    $0x8,%esp
80101f75:	50                   	push   %eax
80101f76:	52                   	push   %edx
80101f77:	e8 0b f7 ff ff       	call   80101687 <bfree>
80101f7c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f82:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f89:	00 00 00 
  }

  ip->size = 0;
80101f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f96:	83 ec 0c             	sub    $0xc,%esp
80101f99:	ff 75 08             	push   0x8(%ebp)
80101f9c:	e8 5f f9 ff ff       	call   80101900 <iupdate>
80101fa1:	83 c4 10             	add    $0x10,%esp
}
80101fa4:	90                   	nop
80101fa5:	c9                   	leave
80101fa6:	c3                   	ret

80101fa7 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101fa7:	f3 0f 1e fb          	endbr32
80101fab:	55                   	push   %ebp
80101fac:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101fae:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb1:	8b 00                	mov    (%eax),%eax
80101fb3:	89 c2                	mov    %eax,%edx
80101fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb8:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbe:	8b 50 04             	mov    0x4(%eax),%edx
80101fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc4:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fca:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd1:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fde:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe5:	8b 50 58             	mov    0x58(%eax),%edx
80101fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101feb:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fee:	90                   	nop
80101fef:	5d                   	pop    %ebp
80101ff0:	c3                   	ret

80101ff1 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ff1:	f3 0f 1e fb          	endbr32
80101ff5:	55                   	push   %ebp
80101ff6:	89 e5                	mov    %esp,%ebp
80101ff8:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffe:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102002:	66 83 f8 03          	cmp    $0x3,%ax
80102006:	75 5c                	jne    80102064 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102008:	8b 45 08             	mov    0x8(%ebp),%eax
8010200b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010200f:	66 85 c0             	test   %ax,%ax
80102012:	78 20                	js     80102034 <readi+0x43>
80102014:	8b 45 08             	mov    0x8(%ebp),%eax
80102017:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010201b:	66 83 f8 09          	cmp    $0x9,%ax
8010201f:	7f 13                	jg     80102034 <readi+0x43>
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102028:	98                   	cwtl
80102029:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102030:	85 c0                	test   %eax,%eax
80102032:	75 0a                	jne    8010203e <readi+0x4d>
      return -1;
80102034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102039:	e9 0a 01 00 00       	jmp    80102148 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	98                   	cwtl
80102046:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
8010204d:	8b 55 14             	mov    0x14(%ebp),%edx
80102050:	83 ec 04             	sub    $0x4,%esp
80102053:	52                   	push   %edx
80102054:	ff 75 0c             	push   0xc(%ebp)
80102057:	ff 75 08             	push   0x8(%ebp)
8010205a:	ff d0                	call   *%eax
8010205c:	83 c4 10             	add    $0x10,%esp
8010205f:	e9 e4 00 00 00       	jmp    80102148 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	8b 40 58             	mov    0x58(%eax),%eax
8010206a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010206d:	77 0d                	ja     8010207c <readi+0x8b>
8010206f:	8b 55 10             	mov    0x10(%ebp),%edx
80102072:	8b 45 14             	mov    0x14(%ebp),%eax
80102075:	01 d0                	add    %edx,%eax
80102077:	39 45 10             	cmp    %eax,0x10(%ebp)
8010207a:	76 0a                	jbe    80102086 <readi+0x95>
    return -1;
8010207c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102081:	e9 c2 00 00 00       	jmp    80102148 <readi+0x157>
  if(off + n > ip->size)
80102086:	8b 55 10             	mov    0x10(%ebp),%edx
80102089:	8b 45 14             	mov    0x14(%ebp),%eax
8010208c:	01 c2                	add    %eax,%edx
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	8b 40 58             	mov    0x58(%eax),%eax
80102094:	39 c2                	cmp    %eax,%edx
80102096:	76 0c                	jbe    801020a4 <readi+0xb3>
    n = ip->size - off;
80102098:	8b 45 08             	mov    0x8(%ebp),%eax
8010209b:	8b 40 58             	mov    0x58(%eax),%eax
8010209e:	2b 45 10             	sub    0x10(%ebp),%eax
801020a1:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ab:	e9 89 00 00 00       	jmp    80102139 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020b0:	8b 45 10             	mov    0x10(%ebp),%eax
801020b3:	c1 e8 09             	shr    $0x9,%eax
801020b6:	83 ec 08             	sub    $0x8,%esp
801020b9:	50                   	push   %eax
801020ba:	ff 75 08             	push   0x8(%ebp)
801020bd:	e8 8d fc ff ff       	call   80101d4f <bmap>
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	8b 55 08             	mov    0x8(%ebp),%edx
801020c8:	8b 12                	mov    (%edx),%edx
801020ca:	83 ec 08             	sub    $0x8,%esp
801020cd:	50                   	push   %eax
801020ce:	52                   	push   %edx
801020cf:	e8 35 e1 ff ff       	call   80100209 <bread>
801020d4:	83 c4 10             	add    $0x10,%esp
801020d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020da:	8b 45 10             	mov    0x10(%ebp),%eax
801020dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801020e2:	ba 00 02 00 00       	mov    $0x200,%edx
801020e7:	29 c2                	sub    %eax,%edx
801020e9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020ef:	39 c2                	cmp    %eax,%edx
801020f1:	0f 46 c2             	cmovbe %edx,%eax
801020f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020fa:	8d 50 5c             	lea    0x5c(%eax),%edx
801020fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102100:	25 ff 01 00 00       	and    $0x1ff,%eax
80102105:	01 d0                	add    %edx,%eax
80102107:	83 ec 04             	sub    $0x4,%esp
8010210a:	ff 75 ec             	push   -0x14(%ebp)
8010210d:	50                   	push   %eax
8010210e:	ff 75 0c             	push   0xc(%ebp)
80102111:	e8 ea 2c 00 00       	call   80104e00 <memmove>
80102116:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102119:	83 ec 0c             	sub    $0xc,%esp
8010211c:	ff 75 f0             	push   -0x10(%ebp)
8010211f:	e8 6f e1 ff ff       	call   80100293 <brelse>
80102124:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102127:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010212a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010212d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102130:	01 45 10             	add    %eax,0x10(%ebp)
80102133:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102136:	01 45 0c             	add    %eax,0xc(%ebp)
80102139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010213f:	0f 82 6b ff ff ff    	jb     801020b0 <readi+0xbf>
  }
  return n;
80102145:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102148:	c9                   	leave
80102149:	c3                   	ret

8010214a <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010214a:	f3 0f 1e fb          	endbr32
8010214e:	55                   	push   %ebp
8010214f:	89 e5                	mov    %esp,%ebp
80102151:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102154:	8b 45 08             	mov    0x8(%ebp),%eax
80102157:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010215b:	66 83 f8 03          	cmp    $0x3,%ax
8010215f:	75 5c                	jne    801021bd <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102161:	8b 45 08             	mov    0x8(%ebp),%eax
80102164:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102168:	66 85 c0             	test   %ax,%ax
8010216b:	78 20                	js     8010218d <writei+0x43>
8010216d:	8b 45 08             	mov    0x8(%ebp),%eax
80102170:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102174:	66 83 f8 09          	cmp    $0x9,%ax
80102178:	7f 13                	jg     8010218d <writei+0x43>
8010217a:	8b 45 08             	mov    0x8(%ebp),%eax
8010217d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102181:	98                   	cwtl
80102182:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102189:	85 c0                	test   %eax,%eax
8010218b:	75 0a                	jne    80102197 <writei+0x4d>
      return -1;
8010218d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102192:	e9 3b 01 00 00       	jmp    801022d2 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102197:	8b 45 08             	mov    0x8(%ebp),%eax
8010219a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010219e:	98                   	cwtl
8010219f:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
801021a6:	8b 55 14             	mov    0x14(%ebp),%edx
801021a9:	83 ec 04             	sub    $0x4,%esp
801021ac:	52                   	push   %edx
801021ad:	ff 75 0c             	push   0xc(%ebp)
801021b0:	ff 75 08             	push   0x8(%ebp)
801021b3:	ff d0                	call   *%eax
801021b5:	83 c4 10             	add    $0x10,%esp
801021b8:	e9 15 01 00 00       	jmp    801022d2 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021bd:	8b 45 08             	mov    0x8(%ebp),%eax
801021c0:	8b 40 58             	mov    0x58(%eax),%eax
801021c3:	39 45 10             	cmp    %eax,0x10(%ebp)
801021c6:	77 0d                	ja     801021d5 <writei+0x8b>
801021c8:	8b 55 10             	mov    0x10(%ebp),%edx
801021cb:	8b 45 14             	mov    0x14(%ebp),%eax
801021ce:	01 d0                	add    %edx,%eax
801021d0:	39 45 10             	cmp    %eax,0x10(%ebp)
801021d3:	76 0a                	jbe    801021df <writei+0x95>
    return -1;
801021d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021da:	e9 f3 00 00 00       	jmp    801022d2 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021df:	8b 55 10             	mov    0x10(%ebp),%edx
801021e2:	8b 45 14             	mov    0x14(%ebp),%eax
801021e5:	01 d0                	add    %edx,%eax
801021e7:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021ec:	76 0a                	jbe    801021f8 <writei+0xae>
    return -1;
801021ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021f3:	e9 da 00 00 00       	jmp    801022d2 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ff:	e9 97 00 00 00       	jmp    8010229b <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102204:	8b 45 10             	mov    0x10(%ebp),%eax
80102207:	c1 e8 09             	shr    $0x9,%eax
8010220a:	83 ec 08             	sub    $0x8,%esp
8010220d:	50                   	push   %eax
8010220e:	ff 75 08             	push   0x8(%ebp)
80102211:	e8 39 fb ff ff       	call   80101d4f <bmap>
80102216:	83 c4 10             	add    $0x10,%esp
80102219:	8b 55 08             	mov    0x8(%ebp),%edx
8010221c:	8b 12                	mov    (%edx),%edx
8010221e:	83 ec 08             	sub    $0x8,%esp
80102221:	50                   	push   %eax
80102222:	52                   	push   %edx
80102223:	e8 e1 df ff ff       	call   80100209 <bread>
80102228:	83 c4 10             	add    $0x10,%esp
8010222b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010222e:	8b 45 10             	mov    0x10(%ebp),%eax
80102231:	25 ff 01 00 00       	and    $0x1ff,%eax
80102236:	ba 00 02 00 00       	mov    $0x200,%edx
8010223b:	29 c2                	sub    %eax,%edx
8010223d:	8b 45 14             	mov    0x14(%ebp),%eax
80102240:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102243:	39 c2                	cmp    %eax,%edx
80102245:	0f 46 c2             	cmovbe %edx,%eax
80102248:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010224b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010224e:	8d 50 5c             	lea    0x5c(%eax),%edx
80102251:	8b 45 10             	mov    0x10(%ebp),%eax
80102254:	25 ff 01 00 00       	and    $0x1ff,%eax
80102259:	01 d0                	add    %edx,%eax
8010225b:	83 ec 04             	sub    $0x4,%esp
8010225e:	ff 75 ec             	push   -0x14(%ebp)
80102261:	ff 75 0c             	push   0xc(%ebp)
80102264:	50                   	push   %eax
80102265:	e8 96 2b 00 00       	call   80104e00 <memmove>
8010226a:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010226d:	83 ec 0c             	sub    $0xc,%esp
80102270:	ff 75 f0             	push   -0x10(%ebp)
80102273:	e8 af 11 00 00       	call   80103427 <log_write>
80102278:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010227b:	83 ec 0c             	sub    $0xc,%esp
8010227e:	ff 75 f0             	push   -0x10(%ebp)
80102281:	e8 0d e0 ff ff       	call   80100293 <brelse>
80102286:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102289:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010228c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010228f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102292:	01 45 10             	add    %eax,0x10(%ebp)
80102295:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102298:	01 45 0c             	add    %eax,0xc(%ebp)
8010229b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229e:	3b 45 14             	cmp    0x14(%ebp),%eax
801022a1:	0f 82 5d ff ff ff    	jb     80102204 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
801022a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022ab:	74 22                	je     801022cf <writei+0x185>
801022ad:	8b 45 08             	mov    0x8(%ebp),%eax
801022b0:	8b 40 58             	mov    0x58(%eax),%eax
801022b3:	39 45 10             	cmp    %eax,0x10(%ebp)
801022b6:	76 17                	jbe    801022cf <writei+0x185>
    ip->size = off;
801022b8:	8b 45 08             	mov    0x8(%ebp),%eax
801022bb:	8b 55 10             	mov    0x10(%ebp),%edx
801022be:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022c1:	83 ec 0c             	sub    $0xc,%esp
801022c4:	ff 75 08             	push   0x8(%ebp)
801022c7:	e8 34 f6 ff ff       	call   80101900 <iupdate>
801022cc:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022cf:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022d2:	c9                   	leave
801022d3:	c3                   	ret

801022d4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022d4:	f3 0f 1e fb          	endbr32
801022d8:	55                   	push   %ebp
801022d9:	89 e5                	mov    %esp,%ebp
801022db:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022de:	83 ec 04             	sub    $0x4,%esp
801022e1:	6a 0e                	push   $0xe
801022e3:	ff 75 0c             	push   0xc(%ebp)
801022e6:	ff 75 08             	push   0x8(%ebp)
801022e9:	e8 b0 2b 00 00       	call   80104e9e <strncmp>
801022ee:	83 c4 10             	add    $0x10,%esp
}
801022f1:	c9                   	leave
801022f2:	c3                   	ret

801022f3 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022f3:	f3 0f 1e fb          	endbr32
801022f7:	55                   	push   %ebp
801022f8:	89 e5                	mov    %esp,%ebp
801022fa:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102300:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102304:	66 83 f8 01          	cmp    $0x1,%ax
80102308:	74 0d                	je     80102317 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010230a:	83 ec 0c             	sub    $0xc,%esp
8010230d:	68 a9 a9 10 80       	push   $0x8010a9a9
80102312:	e8 c7 e2 ff ff       	call   801005de <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010231e:	eb 7b                	jmp    8010239b <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102320:	6a 10                	push   $0x10
80102322:	ff 75 f4             	push   -0xc(%ebp)
80102325:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102328:	50                   	push   %eax
80102329:	ff 75 08             	push   0x8(%ebp)
8010232c:	e8 c0 fc ff ff       	call   80101ff1 <readi>
80102331:	83 c4 10             	add    $0x10,%esp
80102334:	83 f8 10             	cmp    $0x10,%eax
80102337:	74 0d                	je     80102346 <dirlookup+0x53>
      panic("dirlookup read");
80102339:	83 ec 0c             	sub    $0xc,%esp
8010233c:	68 bb a9 10 80       	push   $0x8010a9bb
80102341:	e8 98 e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102346:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010234a:	66 85 c0             	test   %ax,%ax
8010234d:	74 47                	je     80102396 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
8010234f:	83 ec 08             	sub    $0x8,%esp
80102352:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102355:	83 c0 02             	add    $0x2,%eax
80102358:	50                   	push   %eax
80102359:	ff 75 0c             	push   0xc(%ebp)
8010235c:	e8 73 ff ff ff       	call   801022d4 <namecmp>
80102361:	83 c4 10             	add    $0x10,%esp
80102364:	85 c0                	test   %eax,%eax
80102366:	75 2f                	jne    80102397 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102368:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010236c:	74 08                	je     80102376 <dirlookup+0x83>
        *poff = off;
8010236e:	8b 45 10             	mov    0x10(%ebp),%eax
80102371:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102374:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102376:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010237a:	0f b7 c0             	movzwl %ax,%eax
8010237d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102380:	8b 45 08             	mov    0x8(%ebp),%eax
80102383:	8b 00                	mov    (%eax),%eax
80102385:	83 ec 08             	sub    $0x8,%esp
80102388:	ff 75 f0             	push   -0x10(%ebp)
8010238b:	50                   	push   %eax
8010238c:	e8 34 f6 ff ff       	call   801019c5 <iget>
80102391:	83 c4 10             	add    $0x10,%esp
80102394:	eb 19                	jmp    801023af <dirlookup+0xbc>
      continue;
80102396:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102397:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	8b 40 58             	mov    0x58(%eax),%eax
801023a1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801023a4:	0f 82 76 ff ff ff    	jb     80102320 <dirlookup+0x2d>
    }
  }

  return 0;
801023aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023af:	c9                   	leave
801023b0:	c3                   	ret

801023b1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801023b1:	f3 0f 1e fb          	endbr32
801023b5:	55                   	push   %ebp
801023b6:	89 e5                	mov    %esp,%ebp
801023b8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023bb:	83 ec 04             	sub    $0x4,%esp
801023be:	6a 00                	push   $0x0
801023c0:	ff 75 0c             	push   0xc(%ebp)
801023c3:	ff 75 08             	push   0x8(%ebp)
801023c6:	e8 28 ff ff ff       	call   801022f3 <dirlookup>
801023cb:	83 c4 10             	add    $0x10,%esp
801023ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023d5:	74 18                	je     801023ef <dirlink+0x3e>
    iput(ip);
801023d7:	83 ec 0c             	sub    $0xc,%esp
801023da:	ff 75 f0             	push   -0x10(%ebp)
801023dd:	e8 70 f8 ff ff       	call   80101c52 <iput>
801023e2:	83 c4 10             	add    $0x10,%esp
    return -1;
801023e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ea:	e9 9c 00 00 00       	jmp    8010248b <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023f6:	eb 39                	jmp    80102431 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fb:	6a 10                	push   $0x10
801023fd:	50                   	push   %eax
801023fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102401:	50                   	push   %eax
80102402:	ff 75 08             	push   0x8(%ebp)
80102405:	e8 e7 fb ff ff       	call   80101ff1 <readi>
8010240a:	83 c4 10             	add    $0x10,%esp
8010240d:	83 f8 10             	cmp    $0x10,%eax
80102410:	74 0d                	je     8010241f <dirlink+0x6e>
      panic("dirlink read");
80102412:	83 ec 0c             	sub    $0xc,%esp
80102415:	68 ca a9 10 80       	push   $0x8010a9ca
8010241a:	e8 bf e1 ff ff       	call   801005de <panic>
    if(de.inum == 0)
8010241f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102423:	66 85 c0             	test   %ax,%ax
80102426:	74 18                	je     80102440 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242b:	83 c0 10             	add    $0x10,%eax
8010242e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102431:	8b 45 08             	mov    0x8(%ebp),%eax
80102434:	8b 50 58             	mov    0x58(%eax),%edx
80102437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243a:	39 c2                	cmp    %eax,%edx
8010243c:	77 ba                	ja     801023f8 <dirlink+0x47>
8010243e:	eb 01                	jmp    80102441 <dirlink+0x90>
      break;
80102440:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102441:	83 ec 04             	sub    $0x4,%esp
80102444:	6a 0e                	push   $0xe
80102446:	ff 75 0c             	push   0xc(%ebp)
80102449:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010244c:	83 c0 02             	add    $0x2,%eax
8010244f:	50                   	push   %eax
80102450:	e8 a3 2a 00 00       	call   80104ef8 <strncpy>
80102455:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102458:	8b 45 10             	mov    0x10(%ebp),%eax
8010245b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010245f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102462:	6a 10                	push   $0x10
80102464:	50                   	push   %eax
80102465:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102468:	50                   	push   %eax
80102469:	ff 75 08             	push   0x8(%ebp)
8010246c:	e8 d9 fc ff ff       	call   8010214a <writei>
80102471:	83 c4 10             	add    $0x10,%esp
80102474:	83 f8 10             	cmp    $0x10,%eax
80102477:	74 0d                	je     80102486 <dirlink+0xd5>
    panic("dirlink");
80102479:	83 ec 0c             	sub    $0xc,%esp
8010247c:	68 d7 a9 10 80       	push   $0x8010a9d7
80102481:	e8 58 e1 ff ff       	call   801005de <panic>

  return 0;
80102486:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010248b:	c9                   	leave
8010248c:	c3                   	ret

8010248d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010248d:	f3 0f 1e fb          	endbr32
80102491:	55                   	push   %ebp
80102492:	89 e5                	mov    %esp,%ebp
80102494:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102497:	eb 04                	jmp    8010249d <skipelem+0x10>
    path++;
80102499:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010249d:	8b 45 08             	mov    0x8(%ebp),%eax
801024a0:	0f b6 00             	movzbl (%eax),%eax
801024a3:	3c 2f                	cmp    $0x2f,%al
801024a5:	74 f2                	je     80102499 <skipelem+0xc>
  if(*path == 0)
801024a7:	8b 45 08             	mov    0x8(%ebp),%eax
801024aa:	0f b6 00             	movzbl (%eax),%eax
801024ad:	84 c0                	test   %al,%al
801024af:	75 07                	jne    801024b8 <skipelem+0x2b>
    return 0;
801024b1:	b8 00 00 00 00       	mov    $0x0,%eax
801024b6:	eb 77                	jmp    8010252f <skipelem+0xa2>
  s = path;
801024b8:	8b 45 08             	mov    0x8(%ebp),%eax
801024bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024be:	eb 04                	jmp    801024c4 <skipelem+0x37>
    path++;
801024c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024c4:	8b 45 08             	mov    0x8(%ebp),%eax
801024c7:	0f b6 00             	movzbl (%eax),%eax
801024ca:	3c 2f                	cmp    $0x2f,%al
801024cc:	74 0a                	je     801024d8 <skipelem+0x4b>
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	84 c0                	test   %al,%al
801024d6:	75 e8                	jne    801024c0 <skipelem+0x33>
  len = path - s;
801024d8:	8b 45 08             	mov    0x8(%ebp),%eax
801024db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024e1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024e5:	7e 15                	jle    801024fc <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024e7:	83 ec 04             	sub    $0x4,%esp
801024ea:	6a 0e                	push   $0xe
801024ec:	ff 75 f4             	push   -0xc(%ebp)
801024ef:	ff 75 0c             	push   0xc(%ebp)
801024f2:	e8 09 29 00 00       	call   80104e00 <memmove>
801024f7:	83 c4 10             	add    $0x10,%esp
801024fa:	eb 26                	jmp    80102522 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ff:	83 ec 04             	sub    $0x4,%esp
80102502:	50                   	push   %eax
80102503:	ff 75 f4             	push   -0xc(%ebp)
80102506:	ff 75 0c             	push   0xc(%ebp)
80102509:	e8 f2 28 00 00       	call   80104e00 <memmove>
8010250e:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102511:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	01 d0                	add    %edx,%eax
80102519:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010251c:	eb 04                	jmp    80102522 <skipelem+0x95>
    path++;
8010251e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102522:	8b 45 08             	mov    0x8(%ebp),%eax
80102525:	0f b6 00             	movzbl (%eax),%eax
80102528:	3c 2f                	cmp    $0x2f,%al
8010252a:	74 f2                	je     8010251e <skipelem+0x91>
  return path;
8010252c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010252f:	c9                   	leave
80102530:	c3                   	ret

80102531 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102531:	f3 0f 1e fb          	endbr32
80102535:	55                   	push   %ebp
80102536:	89 e5                	mov    %esp,%ebp
80102538:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010253b:	8b 45 08             	mov    0x8(%ebp),%eax
8010253e:	0f b6 00             	movzbl (%eax),%eax
80102541:	3c 2f                	cmp    $0x2f,%al
80102543:	75 17                	jne    8010255c <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102545:	83 ec 08             	sub    $0x8,%esp
80102548:	6a 01                	push   $0x1
8010254a:	6a 01                	push   $0x1
8010254c:	e8 74 f4 ff ff       	call   801019c5 <iget>
80102551:	83 c4 10             	add    $0x10,%esp
80102554:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102557:	e9 ba 00 00 00       	jmp    80102616 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010255c:	e8 b5 16 00 00       	call   80103c16 <myproc>
80102561:	8b 40 68             	mov    0x68(%eax),%eax
80102564:	83 ec 0c             	sub    $0xc,%esp
80102567:	50                   	push   %eax
80102568:	e8 3e f5 ff ff       	call   80101aab <idup>
8010256d:	83 c4 10             	add    $0x10,%esp
80102570:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102573:	e9 9e 00 00 00       	jmp    80102616 <namex+0xe5>
    ilock(ip);
80102578:	83 ec 0c             	sub    $0xc,%esp
8010257b:	ff 75 f4             	push   -0xc(%ebp)
8010257e:	e8 66 f5 ff ff       	call   80101ae9 <ilock>
80102583:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102589:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010258d:	66 83 f8 01          	cmp    $0x1,%ax
80102591:	74 18                	je     801025ab <namex+0x7a>
      iunlockput(ip);
80102593:	83 ec 0c             	sub    $0xc,%esp
80102596:	ff 75 f4             	push   -0xc(%ebp)
80102599:	e8 88 f7 ff ff       	call   80101d26 <iunlockput>
8010259e:	83 c4 10             	add    $0x10,%esp
      return 0;
801025a1:	b8 00 00 00 00       	mov    $0x0,%eax
801025a6:	e9 a7 00 00 00       	jmp    80102652 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
801025ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025af:	74 20                	je     801025d1 <namex+0xa0>
801025b1:	8b 45 08             	mov    0x8(%ebp),%eax
801025b4:	0f b6 00             	movzbl (%eax),%eax
801025b7:	84 c0                	test   %al,%al
801025b9:	75 16                	jne    801025d1 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025bb:	83 ec 0c             	sub    $0xc,%esp
801025be:	ff 75 f4             	push   -0xc(%ebp)
801025c1:	e8 3a f6 ff ff       	call   80101c00 <iunlock>
801025c6:	83 c4 10             	add    $0x10,%esp
      return ip;
801025c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cc:	e9 81 00 00 00       	jmp    80102652 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025d1:	83 ec 04             	sub    $0x4,%esp
801025d4:	6a 00                	push   $0x0
801025d6:	ff 75 10             	push   0x10(%ebp)
801025d9:	ff 75 f4             	push   -0xc(%ebp)
801025dc:	e8 12 fd ff ff       	call   801022f3 <dirlookup>
801025e1:	83 c4 10             	add    $0x10,%esp
801025e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025eb:	75 15                	jne    80102602 <namex+0xd1>
      iunlockput(ip);
801025ed:	83 ec 0c             	sub    $0xc,%esp
801025f0:	ff 75 f4             	push   -0xc(%ebp)
801025f3:	e8 2e f7 ff ff       	call   80101d26 <iunlockput>
801025f8:	83 c4 10             	add    $0x10,%esp
      return 0;
801025fb:	b8 00 00 00 00       	mov    $0x0,%eax
80102600:	eb 50                	jmp    80102652 <namex+0x121>
    }
    iunlockput(ip);
80102602:	83 ec 0c             	sub    $0xc,%esp
80102605:	ff 75 f4             	push   -0xc(%ebp)
80102608:	e8 19 f7 ff ff       	call   80101d26 <iunlockput>
8010260d:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102616:	83 ec 08             	sub    $0x8,%esp
80102619:	ff 75 10             	push   0x10(%ebp)
8010261c:	ff 75 08             	push   0x8(%ebp)
8010261f:	e8 69 fe ff ff       	call   8010248d <skipelem>
80102624:	83 c4 10             	add    $0x10,%esp
80102627:	89 45 08             	mov    %eax,0x8(%ebp)
8010262a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010262e:	0f 85 44 ff ff ff    	jne    80102578 <namex+0x47>
  }
  if(nameiparent){
80102634:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102638:	74 15                	je     8010264f <namex+0x11e>
    iput(ip);
8010263a:	83 ec 0c             	sub    $0xc,%esp
8010263d:	ff 75 f4             	push   -0xc(%ebp)
80102640:	e8 0d f6 ff ff       	call   80101c52 <iput>
80102645:	83 c4 10             	add    $0x10,%esp
    return 0;
80102648:	b8 00 00 00 00       	mov    $0x0,%eax
8010264d:	eb 03                	jmp    80102652 <namex+0x121>
  }
  return ip;
8010264f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102652:	c9                   	leave
80102653:	c3                   	ret

80102654 <namei>:

struct inode*
namei(char *path)
{
80102654:	f3 0f 1e fb          	endbr32
80102658:	55                   	push   %ebp
80102659:	89 e5                	mov    %esp,%ebp
8010265b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010265e:	83 ec 04             	sub    $0x4,%esp
80102661:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102664:	50                   	push   %eax
80102665:	6a 00                	push   $0x0
80102667:	ff 75 08             	push   0x8(%ebp)
8010266a:	e8 c2 fe ff ff       	call   80102531 <namex>
8010266f:	83 c4 10             	add    $0x10,%esp
}
80102672:	c9                   	leave
80102673:	c3                   	ret

80102674 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102674:	f3 0f 1e fb          	endbr32
80102678:	55                   	push   %ebp
80102679:	89 e5                	mov    %esp,%ebp
8010267b:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010267e:	83 ec 04             	sub    $0x4,%esp
80102681:	ff 75 0c             	push   0xc(%ebp)
80102684:	6a 01                	push   $0x1
80102686:	ff 75 08             	push   0x8(%ebp)
80102689:	e8 a3 fe ff ff       	call   80102531 <namex>
8010268e:	83 c4 10             	add    $0x10,%esp
}
80102691:	c9                   	leave
80102692:	c3                   	ret

80102693 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102693:	f3 0f 1e fb          	endbr32
80102697:	55                   	push   %ebp
80102698:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010269a:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010269f:	8b 55 08             	mov    0x8(%ebp),%edx
801026a2:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801026a4:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026a9:	8b 40 10             	mov    0x10(%eax),%eax
}
801026ac:	5d                   	pop    %ebp
801026ad:	c3                   	ret

801026ae <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801026ae:	f3 0f 1e fb          	endbr32
801026b2:	55                   	push   %ebp
801026b3:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801026b5:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026ba:	8b 55 08             	mov    0x8(%ebp),%edx
801026bd:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801026bf:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801026c7:	89 50 10             	mov    %edx,0x10(%eax)
}
801026ca:	90                   	nop
801026cb:	5d                   	pop    %ebp
801026cc:	c3                   	ret

801026cd <ioapicinit>:

void
ioapicinit(void)
{
801026cd:	f3 0f 1e fb          	endbr32
801026d1:	55                   	push   %ebp
801026d2:	89 e5                	mov    %esp,%ebp
801026d4:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801026d7:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
801026de:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801026e1:	6a 01                	push   $0x1
801026e3:	e8 ab ff ff ff       	call   80102693 <ioapicread>
801026e8:	83 c4 04             	add    $0x4,%esp
801026eb:	c1 e8 10             	shr    $0x10,%eax
801026ee:	25 ff 00 00 00       	and    $0xff,%eax
801026f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801026f6:	6a 00                	push   $0x0
801026f8:	e8 96 ff ff ff       	call   80102693 <ioapicread>
801026fd:	83 c4 04             	add    $0x4,%esp
80102700:	c1 e8 18             	shr    $0x18,%eax
80102703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102706:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
8010270d:	0f b6 c0             	movzbl %al,%eax
80102710:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102713:	74 10                	je     80102725 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102715:	83 ec 0c             	sub    $0xc,%esp
80102718:	68 e0 a9 10 80       	push   $0x8010a9e0
8010271d:	e8 ea dc ff ff       	call   8010040c <cprintf>
80102722:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010272c:	eb 3f                	jmp    8010276d <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	83 c0 20             	add    $0x20,%eax
80102734:	0d 00 00 01 00       	or     $0x10000,%eax
80102739:	89 c2                	mov    %eax,%edx
8010273b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273e:	83 c0 08             	add    $0x8,%eax
80102741:	01 c0                	add    %eax,%eax
80102743:	83 ec 08             	sub    $0x8,%esp
80102746:	52                   	push   %edx
80102747:	50                   	push   %eax
80102748:	e8 61 ff ff ff       	call   801026ae <ioapicwrite>
8010274d:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102753:	83 c0 08             	add    $0x8,%eax
80102756:	01 c0                	add    %eax,%eax
80102758:	83 c0 01             	add    $0x1,%eax
8010275b:	83 ec 08             	sub    $0x8,%esp
8010275e:	6a 00                	push   $0x0
80102760:	50                   	push   %eax
80102761:	e8 48 ff ff ff       	call   801026ae <ioapicwrite>
80102766:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102769:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102773:	7e b9                	jle    8010272e <ioapicinit+0x61>
  }
}
80102775:	90                   	nop
80102776:	90                   	nop
80102777:	c9                   	leave
80102778:	c3                   	ret

80102779 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102779:	f3 0f 1e fb          	endbr32
8010277d:	55                   	push   %ebp
8010277e:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102780:	8b 45 08             	mov    0x8(%ebp),%eax
80102783:	83 c0 20             	add    $0x20,%eax
80102786:	89 c2                	mov    %eax,%edx
80102788:	8b 45 08             	mov    0x8(%ebp),%eax
8010278b:	83 c0 08             	add    $0x8,%eax
8010278e:	01 c0                	add    %eax,%eax
80102790:	52                   	push   %edx
80102791:	50                   	push   %eax
80102792:	e8 17 ff ff ff       	call   801026ae <ioapicwrite>
80102797:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010279a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010279d:	c1 e0 18             	shl    $0x18,%eax
801027a0:	89 c2                	mov    %eax,%edx
801027a2:	8b 45 08             	mov    0x8(%ebp),%eax
801027a5:	83 c0 08             	add    $0x8,%eax
801027a8:	01 c0                	add    %eax,%eax
801027aa:	83 c0 01             	add    $0x1,%eax
801027ad:	52                   	push   %edx
801027ae:	50                   	push   %eax
801027af:	e8 fa fe ff ff       	call   801026ae <ioapicwrite>
801027b4:	83 c4 08             	add    $0x8,%esp
}
801027b7:	90                   	nop
801027b8:	c9                   	leave
801027b9:	c3                   	ret

801027ba <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801027ba:	f3 0f 1e fb          	endbr32
801027be:	55                   	push   %ebp
801027bf:	89 e5                	mov    %esp,%ebp
801027c1:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801027c4:	83 ec 08             	sub    $0x8,%esp
801027c7:	68 12 aa 10 80       	push   $0x8010aa12
801027cc:	68 e0 53 19 80       	push   $0x801953e0
801027d1:	e8 ae 22 00 00       	call   80104a84 <initlock>
801027d6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801027d9:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
801027e0:	00 00 00 
  freerange(vstart, vend);
801027e3:	83 ec 08             	sub    $0x8,%esp
801027e6:	ff 75 0c             	push   0xc(%ebp)
801027e9:	ff 75 08             	push   0x8(%ebp)
801027ec:	e8 2e 00 00 00       	call   8010281f <freerange>
801027f1:	83 c4 10             	add    $0x10,%esp
}
801027f4:	90                   	nop
801027f5:	c9                   	leave
801027f6:	c3                   	ret

801027f7 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801027f7:	f3 0f 1e fb          	endbr32
801027fb:	55                   	push   %ebp
801027fc:	89 e5                	mov    %esp,%ebp
801027fe:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102801:	83 ec 08             	sub    $0x8,%esp
80102804:	ff 75 0c             	push   0xc(%ebp)
80102807:	ff 75 08             	push   0x8(%ebp)
8010280a:	e8 10 00 00 00       	call   8010281f <freerange>
8010280f:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102812:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
80102819:	00 00 00 
}
8010281c:	90                   	nop
8010281d:	c9                   	leave
8010281e:	c3                   	ret

8010281f <freerange>:

void
freerange(void *vstart, void *vend)
{
8010281f:	f3 0f 1e fb          	endbr32
80102823:	55                   	push   %ebp
80102824:	89 e5                	mov    %esp,%ebp
80102826:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102829:	8b 45 08             	mov    0x8(%ebp),%eax
8010282c:	05 ff 0f 00 00       	add    $0xfff,%eax
80102831:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102836:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102839:	eb 15                	jmp    80102850 <freerange+0x31>
    kfree(p);
8010283b:	83 ec 0c             	sub    $0xc,%esp
8010283e:	ff 75 f4             	push   -0xc(%ebp)
80102841:	e8 1b 00 00 00       	call   80102861 <kfree>
80102846:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102849:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102853:	05 00 10 00 00       	add    $0x1000,%eax
80102858:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010285b:	73 de                	jae    8010283b <freerange+0x1c>
}
8010285d:	90                   	nop
8010285e:	90                   	nop
8010285f:	c9                   	leave
80102860:	c3                   	ret

80102861 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102861:	f3 0f 1e fb          	endbr32
80102865:	55                   	push   %ebp
80102866:	89 e5                	mov    %esp,%ebp
80102868:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010286b:	8b 45 08             	mov    0x8(%ebp),%eax
8010286e:	25 ff 0f 00 00       	and    $0xfff,%eax
80102873:	85 c0                	test   %eax,%eax
80102875:	75 18                	jne    8010288f <kfree+0x2e>
80102877:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010287e:	72 0f                	jb     8010288f <kfree+0x2e>
80102880:	8b 45 08             	mov    0x8(%ebp),%eax
80102883:	05 00 00 00 80       	add    $0x80000000,%eax
80102888:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010288d:	76 0d                	jbe    8010289c <kfree+0x3b>
    panic("kfree");
8010288f:	83 ec 0c             	sub    $0xc,%esp
80102892:	68 17 aa 10 80       	push   $0x8010aa17
80102897:	e8 42 dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010289c:	83 ec 04             	sub    $0x4,%esp
8010289f:	68 00 10 00 00       	push   $0x1000
801028a4:	6a 01                	push   $0x1
801028a6:	ff 75 08             	push   0x8(%ebp)
801028a9:	e8 8b 24 00 00       	call   80104d39 <memset>
801028ae:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801028b1:	a1 14 54 19 80       	mov    0x80195414,%eax
801028b6:	85 c0                	test   %eax,%eax
801028b8:	74 10                	je     801028ca <kfree+0x69>
    acquire(&kmem.lock);
801028ba:	83 ec 0c             	sub    $0xc,%esp
801028bd:	68 e0 53 19 80       	push   $0x801953e0
801028c2:	e8 e3 21 00 00       	call   80104aaa <acquire>
801028c7:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801028ca:	8b 45 08             	mov    0x8(%ebp),%eax
801028cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801028d0:	8b 15 18 54 19 80    	mov    0x80195418,%edx
801028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d9:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801028db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028de:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028e3:	a1 14 54 19 80       	mov    0x80195414,%eax
801028e8:	85 c0                	test   %eax,%eax
801028ea:	74 10                	je     801028fc <kfree+0x9b>
    release(&kmem.lock);
801028ec:	83 ec 0c             	sub    $0xc,%esp
801028ef:	68 e0 53 19 80       	push   $0x801953e0
801028f4:	e8 23 22 00 00       	call   80104b1c <release>
801028f9:	83 c4 10             	add    $0x10,%esp
}
801028fc:	90                   	nop
801028fd:	c9                   	leave
801028fe:	c3                   	ret

801028ff <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028ff:	f3 0f 1e fb          	endbr32
80102903:	55                   	push   %ebp
80102904:	89 e5                	mov    %esp,%ebp
80102906:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102909:	a1 14 54 19 80       	mov    0x80195414,%eax
8010290e:	85 c0                	test   %eax,%eax
80102910:	74 10                	je     80102922 <kalloc+0x23>
    acquire(&kmem.lock);
80102912:	83 ec 0c             	sub    $0xc,%esp
80102915:	68 e0 53 19 80       	push   $0x801953e0
8010291a:	e8 8b 21 00 00       	call   80104aaa <acquire>
8010291f:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102922:	a1 18 54 19 80       	mov    0x80195418,%eax
80102927:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010292a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010292e:	74 0a                	je     8010293a <kalloc+0x3b>
    kmem.freelist = r->next;
80102930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102933:	8b 00                	mov    (%eax),%eax
80102935:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
8010293a:	a1 14 54 19 80       	mov    0x80195414,%eax
8010293f:	85 c0                	test   %eax,%eax
80102941:	74 10                	je     80102953 <kalloc+0x54>
    release(&kmem.lock);
80102943:	83 ec 0c             	sub    $0xc,%esp
80102946:	68 e0 53 19 80       	push   $0x801953e0
8010294b:	e8 cc 21 00 00       	call   80104b1c <release>
80102950:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102956:	c9                   	leave
80102957:	c3                   	ret

80102958 <inb>:
{
80102958:	55                   	push   %ebp
80102959:	89 e5                	mov    %esp,%ebp
8010295b:	83 ec 14             	sub    $0x14,%esp
8010295e:	8b 45 08             	mov    0x8(%ebp),%eax
80102961:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102965:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102969:	89 c2                	mov    %eax,%edx
8010296b:	ec                   	in     (%dx),%al
8010296c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010296f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102973:	c9                   	leave
80102974:	c3                   	ret

80102975 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102975:	f3 0f 1e fb          	endbr32
80102979:	55                   	push   %ebp
8010297a:	89 e5                	mov    %esp,%ebp
8010297c:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010297f:	6a 64                	push   $0x64
80102981:	e8 d2 ff ff ff       	call   80102958 <inb>
80102986:	83 c4 04             	add    $0x4,%esp
80102989:	0f b6 c0             	movzbl %al,%eax
8010298c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010298f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102992:	83 e0 01             	and    $0x1,%eax
80102995:	85 c0                	test   %eax,%eax
80102997:	75 0a                	jne    801029a3 <kbdgetc+0x2e>
    return -1;
80102999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010299e:	e9 23 01 00 00       	jmp    80102ac6 <kbdgetc+0x151>
  data = inb(KBDATAP);
801029a3:	6a 60                	push   $0x60
801029a5:	e8 ae ff ff ff       	call   80102958 <inb>
801029aa:	83 c4 04             	add    $0x4,%esp
801029ad:	0f b6 c0             	movzbl %al,%eax
801029b0:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801029b3:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801029ba:	75 17                	jne    801029d3 <kbdgetc+0x5e>
    shift |= E0ESC;
801029bc:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029c1:	83 c8 40             	or     $0x40,%eax
801029c4:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029c9:	b8 00 00 00 00       	mov    $0x0,%eax
801029ce:	e9 f3 00 00 00       	jmp    80102ac6 <kbdgetc+0x151>
  } else if(data & 0x80){
801029d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029d6:	25 80 00 00 00       	and    $0x80,%eax
801029db:	85 c0                	test   %eax,%eax
801029dd:	74 45                	je     80102a24 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029df:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029e4:	83 e0 40             	and    $0x40,%eax
801029e7:	85 c0                	test   %eax,%eax
801029e9:	75 08                	jne    801029f3 <kbdgetc+0x7e>
801029eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029ee:	83 e0 7f             	and    $0x7f,%eax
801029f1:	eb 03                	jmp    801029f6 <kbdgetc+0x81>
801029f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801029f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029fc:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a01:	0f b6 00             	movzbl (%eax),%eax
80102a04:	83 c8 40             	or     $0x40,%eax
80102a07:	0f b6 c0             	movzbl %al,%eax
80102a0a:	f7 d0                	not    %eax
80102a0c:	89 c2                	mov    %eax,%edx
80102a0e:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a13:	21 d0                	and    %edx,%eax
80102a15:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
80102a1a:	b8 00 00 00 00       	mov    $0x0,%eax
80102a1f:	e9 a2 00 00 00       	jmp    80102ac6 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102a24:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a29:	83 e0 40             	and    $0x40,%eax
80102a2c:	85 c0                	test   %eax,%eax
80102a2e:	74 14                	je     80102a44 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a30:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102a37:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a3c:	83 e0 bf             	and    $0xffffffbf,%eax
80102a3f:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
80102a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a47:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a4c:	0f b6 00             	movzbl (%eax),%eax
80102a4f:	0f b6 d0             	movzbl %al,%edx
80102a52:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a57:	09 d0                	or     %edx,%eax
80102a59:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a61:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a66:	0f b6 00             	movzbl (%eax),%eax
80102a69:	0f b6 d0             	movzbl %al,%edx
80102a6c:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a71:	31 d0                	xor    %edx,%eax
80102a73:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a78:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a7d:	83 e0 03             	and    $0x3,%eax
80102a80:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a8a:	01 d0                	add    %edx,%eax
80102a8c:	0f b6 00             	movzbl (%eax),%eax
80102a8f:	0f b6 c0             	movzbl %al,%eax
80102a92:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a95:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a9a:	83 e0 08             	and    $0x8,%eax
80102a9d:	85 c0                	test   %eax,%eax
80102a9f:	74 22                	je     80102ac3 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102aa1:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102aa5:	76 0c                	jbe    80102ab3 <kbdgetc+0x13e>
80102aa7:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102aab:	77 06                	ja     80102ab3 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102aad:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ab1:	eb 10                	jmp    80102ac3 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ab3:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ab7:	76 0a                	jbe    80102ac3 <kbdgetc+0x14e>
80102ab9:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102abd:	77 04                	ja     80102ac3 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102abf:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ac6:	c9                   	leave
80102ac7:	c3                   	ret

80102ac8 <kbdintr>:

void
kbdintr(void)
{
80102ac8:	f3 0f 1e fb          	endbr32
80102acc:	55                   	push   %ebp
80102acd:	89 e5                	mov    %esp,%ebp
80102acf:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ad2:	83 ec 0c             	sub    $0xc,%esp
80102ad5:	68 75 29 10 80       	push   $0x80102975
80102ada:	e8 3a dd ff ff       	call   80100819 <consoleintr>
80102adf:	83 c4 10             	add    $0x10,%esp
}
80102ae2:	90                   	nop
80102ae3:	c9                   	leave
80102ae4:	c3                   	ret

80102ae5 <inb>:
{
80102ae5:	55                   	push   %ebp
80102ae6:	89 e5                	mov    %esp,%ebp
80102ae8:	83 ec 14             	sub    $0x14,%esp
80102aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80102aee:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102af2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102af6:	89 c2                	mov    %eax,%edx
80102af8:	ec                   	in     (%dx),%al
80102af9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102afc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b00:	c9                   	leave
80102b01:	c3                   	ret

80102b02 <outb>:
{
80102b02:	55                   	push   %ebp
80102b03:	89 e5                	mov    %esp,%ebp
80102b05:	83 ec 08             	sub    $0x8,%esp
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102b12:	89 d0                	mov    %edx,%eax
80102b14:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b17:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102b1b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102b1f:	ee                   	out    %al,(%dx)
}
80102b20:	90                   	nop
80102b21:	c9                   	leave
80102b22:	c3                   	ret

80102b23 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102b23:	f3 0f 1e fb          	endbr32
80102b27:	55                   	push   %ebp
80102b28:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102b2a:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b2f:	8b 55 08             	mov    0x8(%ebp),%edx
80102b32:	c1 e2 02             	shl    $0x2,%edx
80102b35:	01 c2                	add    %eax,%edx
80102b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b3a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102b3c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b41:	83 c0 20             	add    $0x20,%eax
80102b44:	8b 00                	mov    (%eax),%eax
}
80102b46:	90                   	nop
80102b47:	5d                   	pop    %ebp
80102b48:	c3                   	ret

80102b49 <lapicinit>:

void
lapicinit(void)
{
80102b49:	f3 0f 1e fb          	endbr32
80102b4d:	55                   	push   %ebp
80102b4e:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b50:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b55:	85 c0                	test   %eax,%eax
80102b57:	0f 84 0c 01 00 00    	je     80102c69 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b5d:	68 3f 01 00 00       	push   $0x13f
80102b62:	6a 3c                	push   $0x3c
80102b64:	e8 ba ff ff ff       	call   80102b23 <lapicw>
80102b69:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b6c:	6a 0b                	push   $0xb
80102b6e:	68 f8 00 00 00       	push   $0xf8
80102b73:	e8 ab ff ff ff       	call   80102b23 <lapicw>
80102b78:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b7b:	68 20 00 02 00       	push   $0x20020
80102b80:	68 c8 00 00 00       	push   $0xc8
80102b85:	e8 99 ff ff ff       	call   80102b23 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b8d:	68 80 96 98 00       	push   $0x989680
80102b92:	68 e0 00 00 00       	push   $0xe0
80102b97:	e8 87 ff ff ff       	call   80102b23 <lapicw>
80102b9c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b9f:	68 00 00 01 00       	push   $0x10000
80102ba4:	68 d4 00 00 00       	push   $0xd4
80102ba9:	e8 75 ff ff ff       	call   80102b23 <lapicw>
80102bae:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102bb1:	68 00 00 01 00       	push   $0x10000
80102bb6:	68 d8 00 00 00       	push   $0xd8
80102bbb:	e8 63 ff ff ff       	call   80102b23 <lapicw>
80102bc0:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102bc3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bc8:	83 c0 30             	add    $0x30,%eax
80102bcb:	8b 00                	mov    (%eax),%eax
80102bcd:	c1 e8 10             	shr    $0x10,%eax
80102bd0:	25 fc 00 00 00       	and    $0xfc,%eax
80102bd5:	85 c0                	test   %eax,%eax
80102bd7:	74 12                	je     80102beb <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102bd9:	68 00 00 01 00       	push   $0x10000
80102bde:	68 d0 00 00 00       	push   $0xd0
80102be3:	e8 3b ff ff ff       	call   80102b23 <lapicw>
80102be8:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102beb:	6a 33                	push   $0x33
80102bed:	68 dc 00 00 00       	push   $0xdc
80102bf2:	e8 2c ff ff ff       	call   80102b23 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102bfa:	6a 00                	push   $0x0
80102bfc:	68 a0 00 00 00       	push   $0xa0
80102c01:	e8 1d ff ff ff       	call   80102b23 <lapicw>
80102c06:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102c09:	6a 00                	push   $0x0
80102c0b:	68 a0 00 00 00       	push   $0xa0
80102c10:	e8 0e ff ff ff       	call   80102b23 <lapicw>
80102c15:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102c18:	6a 00                	push   $0x0
80102c1a:	6a 2c                	push   $0x2c
80102c1c:	e8 02 ff ff ff       	call   80102b23 <lapicw>
80102c21:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102c24:	6a 00                	push   $0x0
80102c26:	68 c4 00 00 00       	push   $0xc4
80102c2b:	e8 f3 fe ff ff       	call   80102b23 <lapicw>
80102c30:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102c33:	68 00 85 08 00       	push   $0x88500
80102c38:	68 c0 00 00 00       	push   $0xc0
80102c3d:	e8 e1 fe ff ff       	call   80102b23 <lapicw>
80102c42:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102c45:	90                   	nop
80102c46:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c4b:	05 00 03 00 00       	add    $0x300,%eax
80102c50:	8b 00                	mov    (%eax),%eax
80102c52:	25 00 10 00 00       	and    $0x1000,%eax
80102c57:	85 c0                	test   %eax,%eax
80102c59:	75 eb                	jne    80102c46 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102c5b:	6a 00                	push   $0x0
80102c5d:	6a 20                	push   $0x20
80102c5f:	e8 bf fe ff ff       	call   80102b23 <lapicw>
80102c64:	83 c4 08             	add    $0x8,%esp
80102c67:	eb 01                	jmp    80102c6a <lapicinit+0x121>
    return;
80102c69:	90                   	nop
}
80102c6a:	c9                   	leave
80102c6b:	c3                   	ret

80102c6c <lapicid>:

int
lapicid(void)
{
80102c6c:	f3 0f 1e fb          	endbr32
80102c70:	55                   	push   %ebp
80102c71:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c73:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c78:	85 c0                	test   %eax,%eax
80102c7a:	75 07                	jne    80102c83 <lapicid+0x17>
    return 0;
80102c7c:	b8 00 00 00 00       	mov    $0x0,%eax
80102c81:	eb 0d                	jmp    80102c90 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c83:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c88:	83 c0 20             	add    $0x20,%eax
80102c8b:	8b 00                	mov    (%eax),%eax
80102c8d:	c1 e8 18             	shr    $0x18,%eax
}
80102c90:	5d                   	pop    %ebp
80102c91:	c3                   	ret

80102c92 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c92:	f3 0f 1e fb          	endbr32
80102c96:	55                   	push   %ebp
80102c97:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c99:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c9e:	85 c0                	test   %eax,%eax
80102ca0:	74 0c                	je     80102cae <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102ca2:	6a 00                	push   $0x0
80102ca4:	6a 2c                	push   $0x2c
80102ca6:	e8 78 fe ff ff       	call   80102b23 <lapicw>
80102cab:	83 c4 08             	add    $0x8,%esp
}
80102cae:	90                   	nop
80102caf:	c9                   	leave
80102cb0:	c3                   	ret

80102cb1 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102cb1:	f3 0f 1e fb          	endbr32
80102cb5:	55                   	push   %ebp
80102cb6:	89 e5                	mov    %esp,%ebp
}
80102cb8:	90                   	nop
80102cb9:	5d                   	pop    %ebp
80102cba:	c3                   	ret

80102cbb <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102cbb:	f3 0f 1e fb          	endbr32
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 14             	sub    $0x14,%esp
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102ccb:	6a 0f                	push   $0xf
80102ccd:	6a 70                	push   $0x70
80102ccf:	e8 2e fe ff ff       	call   80102b02 <outb>
80102cd4:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102cd7:	6a 0a                	push   $0xa
80102cd9:	6a 71                	push   $0x71
80102cdb:	e8 22 fe ff ff       	call   80102b02 <outb>
80102ce0:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102ce3:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ced:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf5:	c1 e8 04             	shr    $0x4,%eax
80102cf8:	89 c2                	mov    %eax,%edx
80102cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cfd:	83 c0 02             	add    $0x2,%eax
80102d00:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102d03:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d07:	c1 e0 18             	shl    $0x18,%eax
80102d0a:	50                   	push   %eax
80102d0b:	68 c4 00 00 00       	push   $0xc4
80102d10:	e8 0e fe ff ff       	call   80102b23 <lapicw>
80102d15:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102d18:	68 00 c5 00 00       	push   $0xc500
80102d1d:	68 c0 00 00 00       	push   $0xc0
80102d22:	e8 fc fd ff ff       	call   80102b23 <lapicw>
80102d27:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d2a:	68 c8 00 00 00       	push   $0xc8
80102d2f:	e8 7d ff ff ff       	call   80102cb1 <microdelay>
80102d34:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102d37:	68 00 85 00 00       	push   $0x8500
80102d3c:	68 c0 00 00 00       	push   $0xc0
80102d41:	e8 dd fd ff ff       	call   80102b23 <lapicw>
80102d46:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102d49:	6a 64                	push   $0x64
80102d4b:	e8 61 ff ff ff       	call   80102cb1 <microdelay>
80102d50:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102d53:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102d5a:	eb 3d                	jmp    80102d99 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102d5c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d60:	c1 e0 18             	shl    $0x18,%eax
80102d63:	50                   	push   %eax
80102d64:	68 c4 00 00 00       	push   $0xc4
80102d69:	e8 b5 fd ff ff       	call   80102b23 <lapicw>
80102d6e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d74:	c1 e8 0c             	shr    $0xc,%eax
80102d77:	80 cc 06             	or     $0x6,%ah
80102d7a:	50                   	push   %eax
80102d7b:	68 c0 00 00 00       	push   $0xc0
80102d80:	e8 9e fd ff ff       	call   80102b23 <lapicw>
80102d85:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d88:	68 c8 00 00 00       	push   $0xc8
80102d8d:	e8 1f ff ff ff       	call   80102cb1 <microdelay>
80102d92:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d95:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d99:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d9d:	7e bd                	jle    80102d5c <lapicstartap+0xa1>
  }
}
80102d9f:	90                   	nop
80102da0:	90                   	nop
80102da1:	c9                   	leave
80102da2:	c3                   	ret

80102da3 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102da3:	f3 0f 1e fb          	endbr32
80102da7:	55                   	push   %ebp
80102da8:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102daa:	8b 45 08             	mov    0x8(%ebp),%eax
80102dad:	0f b6 c0             	movzbl %al,%eax
80102db0:	50                   	push   %eax
80102db1:	6a 70                	push   $0x70
80102db3:	e8 4a fd ff ff       	call   80102b02 <outb>
80102db8:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102dbb:	68 c8 00 00 00       	push   $0xc8
80102dc0:	e8 ec fe ff ff       	call   80102cb1 <microdelay>
80102dc5:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102dc8:	6a 71                	push   $0x71
80102dca:	e8 16 fd ff ff       	call   80102ae5 <inb>
80102dcf:	83 c4 04             	add    $0x4,%esp
80102dd2:	0f b6 c0             	movzbl %al,%eax
}
80102dd5:	c9                   	leave
80102dd6:	c3                   	ret

80102dd7 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102dd7:	f3 0f 1e fb          	endbr32
80102ddb:	55                   	push   %ebp
80102ddc:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102dde:	6a 00                	push   $0x0
80102de0:	e8 be ff ff ff       	call   80102da3 <cmos_read>
80102de5:	83 c4 04             	add    $0x4,%esp
80102de8:	8b 55 08             	mov    0x8(%ebp),%edx
80102deb:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102ded:	6a 02                	push   $0x2
80102def:	e8 af ff ff ff       	call   80102da3 <cmos_read>
80102df4:	83 c4 04             	add    $0x4,%esp
80102df7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfa:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102dfd:	6a 04                	push   $0x4
80102dff:	e8 9f ff ff ff       	call   80102da3 <cmos_read>
80102e04:	83 c4 04             	add    $0x4,%esp
80102e07:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0a:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102e0d:	6a 07                	push   $0x7
80102e0f:	e8 8f ff ff ff       	call   80102da3 <cmos_read>
80102e14:	83 c4 04             	add    $0x4,%esp
80102e17:	8b 55 08             	mov    0x8(%ebp),%edx
80102e1a:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102e1d:	6a 08                	push   $0x8
80102e1f:	e8 7f ff ff ff       	call   80102da3 <cmos_read>
80102e24:	83 c4 04             	add    $0x4,%esp
80102e27:	8b 55 08             	mov    0x8(%ebp),%edx
80102e2a:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102e2d:	6a 09                	push   $0x9
80102e2f:	e8 6f ff ff ff       	call   80102da3 <cmos_read>
80102e34:	83 c4 04             	add    $0x4,%esp
80102e37:	8b 55 08             	mov    0x8(%ebp),%edx
80102e3a:	89 42 14             	mov    %eax,0x14(%edx)
}
80102e3d:	90                   	nop
80102e3e:	c9                   	leave
80102e3f:	c3                   	ret

80102e40 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102e40:	f3 0f 1e fb          	endbr32
80102e44:	55                   	push   %ebp
80102e45:	89 e5                	mov    %esp,%ebp
80102e47:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102e4a:	6a 0b                	push   $0xb
80102e4c:	e8 52 ff ff ff       	call   80102da3 <cmos_read>
80102e51:	83 c4 04             	add    $0x4,%esp
80102e54:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e5a:	83 e0 04             	and    $0x4,%eax
80102e5d:	85 c0                	test   %eax,%eax
80102e5f:	0f 94 c0             	sete   %al
80102e62:	0f b6 c0             	movzbl %al,%eax
80102e65:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e68:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e6b:	50                   	push   %eax
80102e6c:	e8 66 ff ff ff       	call   80102dd7 <fill_rtcdate>
80102e71:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e74:	6a 0a                	push   $0xa
80102e76:	e8 28 ff ff ff       	call   80102da3 <cmos_read>
80102e7b:	83 c4 04             	add    $0x4,%esp
80102e7e:	25 80 00 00 00       	and    $0x80,%eax
80102e83:	85 c0                	test   %eax,%eax
80102e85:	75 27                	jne    80102eae <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e87:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e8a:	50                   	push   %eax
80102e8b:	e8 47 ff ff ff       	call   80102dd7 <fill_rtcdate>
80102e90:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e93:	83 ec 04             	sub    $0x4,%esp
80102e96:	6a 18                	push   $0x18
80102e98:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e9b:	50                   	push   %eax
80102e9c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e9f:	50                   	push   %eax
80102ea0:	e8 ff 1e 00 00       	call   80104da4 <memcmp>
80102ea5:	83 c4 10             	add    $0x10,%esp
80102ea8:	85 c0                	test   %eax,%eax
80102eaa:	74 05                	je     80102eb1 <cmostime+0x71>
80102eac:	eb ba                	jmp    80102e68 <cmostime+0x28>
        continue;
80102eae:	90                   	nop
    fill_rtcdate(&t1);
80102eaf:	eb b7                	jmp    80102e68 <cmostime+0x28>
      break;
80102eb1:	90                   	nop
  }

  // convert
  if(bcd) {
80102eb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102eb6:	0f 84 b4 00 00 00    	je     80102f70 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ebc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ebf:	c1 e8 04             	shr    $0x4,%eax
80102ec2:	89 c2                	mov    %eax,%edx
80102ec4:	89 d0                	mov    %edx,%eax
80102ec6:	c1 e0 02             	shl    $0x2,%eax
80102ec9:	01 d0                	add    %edx,%eax
80102ecb:	01 c0                	add    %eax,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ed2:	83 e0 0f             	and    $0xf,%eax
80102ed5:	01 d0                	add    %edx,%eax
80102ed7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102eda:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102edd:	c1 e8 04             	shr    $0x4,%eax
80102ee0:	89 c2                	mov    %eax,%edx
80102ee2:	89 d0                	mov    %edx,%eax
80102ee4:	c1 e0 02             	shl    $0x2,%eax
80102ee7:	01 d0                	add    %edx,%eax
80102ee9:	01 c0                	add    %eax,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ef0:	83 e0 0f             	and    $0xf,%eax
80102ef3:	01 d0                	add    %edx,%eax
80102ef5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102efb:	c1 e8 04             	shr    $0x4,%eax
80102efe:	89 c2                	mov    %eax,%edx
80102f00:	89 d0                	mov    %edx,%eax
80102f02:	c1 e0 02             	shl    $0x2,%eax
80102f05:	01 d0                	add    %edx,%eax
80102f07:	01 c0                	add    %eax,%eax
80102f09:	89 c2                	mov    %eax,%edx
80102f0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102f0e:	83 e0 0f             	and    $0xf,%eax
80102f11:	01 d0                	add    %edx,%eax
80102f13:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f19:	c1 e8 04             	shr    $0x4,%eax
80102f1c:	89 c2                	mov    %eax,%edx
80102f1e:	89 d0                	mov    %edx,%eax
80102f20:	c1 e0 02             	shl    $0x2,%eax
80102f23:	01 d0                	add    %edx,%eax
80102f25:	01 c0                	add    %eax,%eax
80102f27:	89 c2                	mov    %eax,%edx
80102f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f2c:	83 e0 0f             	and    $0xf,%eax
80102f2f:	01 d0                	add    %edx,%eax
80102f31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f37:	c1 e8 04             	shr    $0x4,%eax
80102f3a:	89 c2                	mov    %eax,%edx
80102f3c:	89 d0                	mov    %edx,%eax
80102f3e:	c1 e0 02             	shl    $0x2,%eax
80102f41:	01 d0                	add    %edx,%eax
80102f43:	01 c0                	add    %eax,%eax
80102f45:	89 c2                	mov    %eax,%edx
80102f47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f4a:	83 e0 0f             	and    $0xf,%eax
80102f4d:	01 d0                	add    %edx,%eax
80102f4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f55:	c1 e8 04             	shr    $0x4,%eax
80102f58:	89 c2                	mov    %eax,%edx
80102f5a:	89 d0                	mov    %edx,%eax
80102f5c:	c1 e0 02             	shl    $0x2,%eax
80102f5f:	01 d0                	add    %edx,%eax
80102f61:	01 c0                	add    %eax,%eax
80102f63:	89 c2                	mov    %eax,%edx
80102f65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f68:	83 e0 0f             	and    $0xf,%eax
80102f6b:	01 d0                	add    %edx,%eax
80102f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f70:	8b 45 08             	mov    0x8(%ebp),%eax
80102f73:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f76:	89 10                	mov    %edx,(%eax)
80102f78:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f7b:	89 50 04             	mov    %edx,0x4(%eax)
80102f7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f81:	89 50 08             	mov    %edx,0x8(%eax)
80102f84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f87:	89 50 0c             	mov    %edx,0xc(%eax)
80102f8a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f8d:	89 50 10             	mov    %edx,0x10(%eax)
80102f90:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f93:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f96:	8b 45 08             	mov    0x8(%ebp),%eax
80102f99:	8b 40 14             	mov    0x14(%eax),%eax
80102f9c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa5:	89 50 14             	mov    %edx,0x14(%eax)
}
80102fa8:	90                   	nop
80102fa9:	c9                   	leave
80102faa:	c3                   	ret

80102fab <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102fab:	f3 0f 1e fb          	endbr32
80102faf:	55                   	push   %ebp
80102fb0:	89 e5                	mov    %esp,%ebp
80102fb2:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102fb5:	83 ec 08             	sub    $0x8,%esp
80102fb8:	68 1d aa 10 80       	push   $0x8010aa1d
80102fbd:	68 20 54 19 80       	push   $0x80195420
80102fc2:	e8 bd 1a 00 00       	call   80104a84 <initlock>
80102fc7:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102fca:	83 ec 08             	sub    $0x8,%esp
80102fcd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102fd0:	50                   	push   %eax
80102fd1:	ff 75 08             	push   0x8(%ebp)
80102fd4:	e8 c0 e4 ff ff       	call   80101499 <readsb>
80102fd9:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fdf:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102fe7:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102fec:	8b 45 08             	mov    0x8(%ebp),%eax
80102fef:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102ff4:	e8 bf 01 00 00       	call   801031b8 <recover_from_log>
}
80102ff9:	90                   	nop
80102ffa:	c9                   	leave
80102ffb:	c3                   	ret

80102ffc <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102ffc:	f3 0f 1e fb          	endbr32
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
80103003:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010300d:	e9 95 00 00 00       	jmp    801030a7 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103012:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010301b:	01 d0                	add    %edx,%eax
8010301d:	83 c0 01             	add    $0x1,%eax
80103020:	89 c2                	mov    %eax,%edx
80103022:	a1 64 54 19 80       	mov    0x80195464,%eax
80103027:	83 ec 08             	sub    $0x8,%esp
8010302a:	52                   	push   %edx
8010302b:	50                   	push   %eax
8010302c:	e8 d8 d1 ff ff       	call   80100209 <bread>
80103031:	83 c4 10             	add    $0x10,%esp
80103034:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303a:	83 c0 10             	add    $0x10,%eax
8010303d:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103044:	89 c2                	mov    %eax,%edx
80103046:	a1 64 54 19 80       	mov    0x80195464,%eax
8010304b:	83 ec 08             	sub    $0x8,%esp
8010304e:	52                   	push   %edx
8010304f:	50                   	push   %eax
80103050:	e8 b4 d1 ff ff       	call   80100209 <bread>
80103055:	83 c4 10             	add    $0x10,%esp
80103058:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010305b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010305e:	8d 50 5c             	lea    0x5c(%eax),%edx
80103061:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103064:	83 c0 5c             	add    $0x5c,%eax
80103067:	83 ec 04             	sub    $0x4,%esp
8010306a:	68 00 02 00 00       	push   $0x200
8010306f:	52                   	push   %edx
80103070:	50                   	push   %eax
80103071:	e8 8a 1d 00 00       	call   80104e00 <memmove>
80103076:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103079:	83 ec 0c             	sub    $0xc,%esp
8010307c:	ff 75 ec             	push   -0x14(%ebp)
8010307f:	e8 c2 d1 ff ff       	call   80100246 <bwrite>
80103084:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103087:	83 ec 0c             	sub    $0xc,%esp
8010308a:	ff 75 f0             	push   -0x10(%ebp)
8010308d:	e8 01 d2 ff ff       	call   80100293 <brelse>
80103092:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103095:	83 ec 0c             	sub    $0xc,%esp
80103098:	ff 75 ec             	push   -0x14(%ebp)
8010309b:	e8 f3 d1 ff ff       	call   80100293 <brelse>
801030a0:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801030a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a7:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030af:	0f 8c 5d ff ff ff    	jl     80103012 <install_trans+0x16>
  }
}
801030b5:	90                   	nop
801030b6:	90                   	nop
801030b7:	c9                   	leave
801030b8:	c3                   	ret

801030b9 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030b9:	f3 0f 1e fb          	endbr32
801030bd:	55                   	push   %ebp
801030be:	89 e5                	mov    %esp,%ebp
801030c0:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030c3:	a1 54 54 19 80       	mov    0x80195454,%eax
801030c8:	89 c2                	mov    %eax,%edx
801030ca:	a1 64 54 19 80       	mov    0x80195464,%eax
801030cf:	83 ec 08             	sub    $0x8,%esp
801030d2:	52                   	push   %edx
801030d3:	50                   	push   %eax
801030d4:	e8 30 d1 ff ff       	call   80100209 <bread>
801030d9:	83 c4 10             	add    $0x10,%esp
801030dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030e2:	83 c0 5c             	add    $0x5c,%eax
801030e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030eb:	8b 00                	mov    (%eax),%eax
801030ed:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
801030f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030f9:	eb 1b                	jmp    80103116 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801030fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103101:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103105:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103108:	83 c2 10             	add    $0x10,%edx
8010310b:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103112:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103116:	a1 68 54 19 80       	mov    0x80195468,%eax
8010311b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010311e:	7c db                	jl     801030fb <read_head+0x42>
  }
  brelse(buf);
80103120:	83 ec 0c             	sub    $0xc,%esp
80103123:	ff 75 f0             	push   -0x10(%ebp)
80103126:	e8 68 d1 ff ff       	call   80100293 <brelse>
8010312b:	83 c4 10             	add    $0x10,%esp
}
8010312e:	90                   	nop
8010312f:	c9                   	leave
80103130:	c3                   	ret

80103131 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103131:	f3 0f 1e fb          	endbr32
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
80103138:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010313b:	a1 54 54 19 80       	mov    0x80195454,%eax
80103140:	89 c2                	mov    %eax,%edx
80103142:	a1 64 54 19 80       	mov    0x80195464,%eax
80103147:	83 ec 08             	sub    $0x8,%esp
8010314a:	52                   	push   %edx
8010314b:	50                   	push   %eax
8010314c:	e8 b8 d0 ff ff       	call   80100209 <bread>
80103151:	83 c4 10             	add    $0x10,%esp
80103154:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010315a:	83 c0 5c             	add    $0x5c,%eax
8010315d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103160:	8b 15 68 54 19 80    	mov    0x80195468,%edx
80103166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103169:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010316b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103172:	eb 1b                	jmp    8010318f <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103177:	83 c0 10             	add    $0x10,%eax
8010317a:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103181:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103184:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103187:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010318b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010318f:	a1 68 54 19 80       	mov    0x80195468,%eax
80103194:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103197:	7c db                	jl     80103174 <write_head+0x43>
  }
  bwrite(buf);
80103199:	83 ec 0c             	sub    $0xc,%esp
8010319c:	ff 75 f0             	push   -0x10(%ebp)
8010319f:	e8 a2 d0 ff ff       	call   80100246 <bwrite>
801031a4:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801031a7:	83 ec 0c             	sub    $0xc,%esp
801031aa:	ff 75 f0             	push   -0x10(%ebp)
801031ad:	e8 e1 d0 ff ff       	call   80100293 <brelse>
801031b2:	83 c4 10             	add    $0x10,%esp
}
801031b5:	90                   	nop
801031b6:	c9                   	leave
801031b7:	c3                   	ret

801031b8 <recover_from_log>:

static void
recover_from_log(void)
{
801031b8:	f3 0f 1e fb          	endbr32
801031bc:	55                   	push   %ebp
801031bd:	89 e5                	mov    %esp,%ebp
801031bf:	83 ec 08             	sub    $0x8,%esp
  read_head();
801031c2:	e8 f2 fe ff ff       	call   801030b9 <read_head>
  install_trans(); // if committed, copy from log to disk
801031c7:	e8 30 fe ff ff       	call   80102ffc <install_trans>
  log.lh.n = 0;
801031cc:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801031d3:	00 00 00 
  write_head(); // clear the log
801031d6:	e8 56 ff ff ff       	call   80103131 <write_head>
}
801031db:	90                   	nop
801031dc:	c9                   	leave
801031dd:	c3                   	ret

801031de <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801031de:	f3 0f 1e fb          	endbr32
801031e2:	55                   	push   %ebp
801031e3:	89 e5                	mov    %esp,%ebp
801031e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801031e8:	83 ec 0c             	sub    $0xc,%esp
801031eb:	68 20 54 19 80       	push   $0x80195420
801031f0:	e8 b5 18 00 00       	call   80104aaa <acquire>
801031f5:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801031f8:	a1 60 54 19 80       	mov    0x80195460,%eax
801031fd:	85 c0                	test   %eax,%eax
801031ff:	74 17                	je     80103218 <begin_op+0x3a>
      sleep(&log, &log.lock);
80103201:	83 ec 08             	sub    $0x8,%esp
80103204:	68 20 54 19 80       	push   $0x80195420
80103209:	68 20 54 19 80       	push   $0x80195420
8010320e:	e8 0e 13 00 00       	call   80104521 <sleep>
80103213:	83 c4 10             	add    $0x10,%esp
80103216:	eb e0                	jmp    801031f8 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103218:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
8010321e:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103223:	8d 50 01             	lea    0x1(%eax),%edx
80103226:	89 d0                	mov    %edx,%eax
80103228:	c1 e0 02             	shl    $0x2,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	01 c0                	add    %eax,%eax
8010322f:	01 c8                	add    %ecx,%eax
80103231:	83 f8 1e             	cmp    $0x1e,%eax
80103234:	7e 17                	jle    8010324d <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103236:	83 ec 08             	sub    $0x8,%esp
80103239:	68 20 54 19 80       	push   $0x80195420
8010323e:	68 20 54 19 80       	push   $0x80195420
80103243:	e8 d9 12 00 00       	call   80104521 <sleep>
80103248:	83 c4 10             	add    $0x10,%esp
8010324b:	eb ab                	jmp    801031f8 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
8010324d:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103252:	83 c0 01             	add    $0x1,%eax
80103255:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
8010325a:	83 ec 0c             	sub    $0xc,%esp
8010325d:	68 20 54 19 80       	push   $0x80195420
80103262:	e8 b5 18 00 00       	call   80104b1c <release>
80103267:	83 c4 10             	add    $0x10,%esp
      break;
8010326a:	90                   	nop
    }
  }
}
8010326b:	90                   	nop
8010326c:	c9                   	leave
8010326d:	c3                   	ret

8010326e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010326e:	f3 0f 1e fb          	endbr32
80103272:	55                   	push   %ebp
80103273:	89 e5                	mov    %esp,%ebp
80103275:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103278:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010327f:	83 ec 0c             	sub    $0xc,%esp
80103282:	68 20 54 19 80       	push   $0x80195420
80103287:	e8 1e 18 00 00       	call   80104aaa <acquire>
8010328c:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010328f:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103294:	83 e8 01             	sub    $0x1,%eax
80103297:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010329c:	a1 60 54 19 80       	mov    0x80195460,%eax
801032a1:	85 c0                	test   %eax,%eax
801032a3:	74 0d                	je     801032b2 <end_op+0x44>
    panic("log.committing");
801032a5:	83 ec 0c             	sub    $0xc,%esp
801032a8:	68 21 aa 10 80       	push   $0x8010aa21
801032ad:	e8 2c d3 ff ff       	call   801005de <panic>
  if(log.outstanding == 0){
801032b2:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801032b7:	85 c0                	test   %eax,%eax
801032b9:	75 13                	jne    801032ce <end_op+0x60>
    do_commit = 1;
801032bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801032c2:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
801032c9:	00 00 00 
801032cc:	eb 10                	jmp    801032de <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801032ce:	83 ec 0c             	sub    $0xc,%esp
801032d1:	68 20 54 19 80       	push   $0x80195420
801032d6:	e8 35 13 00 00       	call   80104610 <wakeup>
801032db:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801032de:	83 ec 0c             	sub    $0xc,%esp
801032e1:	68 20 54 19 80       	push   $0x80195420
801032e6:	e8 31 18 00 00       	call   80104b1c <release>
801032eb:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801032ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801032f2:	74 3f                	je     80103333 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801032f4:	e8 fa 00 00 00       	call   801033f3 <commit>
    acquire(&log.lock);
801032f9:	83 ec 0c             	sub    $0xc,%esp
801032fc:	68 20 54 19 80       	push   $0x80195420
80103301:	e8 a4 17 00 00       	call   80104aaa <acquire>
80103306:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103309:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
80103310:	00 00 00 
    wakeup(&log);
80103313:	83 ec 0c             	sub    $0xc,%esp
80103316:	68 20 54 19 80       	push   $0x80195420
8010331b:	e8 f0 12 00 00       	call   80104610 <wakeup>
80103320:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103323:	83 ec 0c             	sub    $0xc,%esp
80103326:	68 20 54 19 80       	push   $0x80195420
8010332b:	e8 ec 17 00 00       	call   80104b1c <release>
80103330:	83 c4 10             	add    $0x10,%esp
  }
}
80103333:	90                   	nop
80103334:	c9                   	leave
80103335:	c3                   	ret

80103336 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103336:	f3 0f 1e fb          	endbr32
8010333a:	55                   	push   %ebp
8010333b:	89 e5                	mov    %esp,%ebp
8010333d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103340:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103347:	e9 95 00 00 00       	jmp    801033e1 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010334c:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103355:	01 d0                	add    %edx,%eax
80103357:	83 c0 01             	add    $0x1,%eax
8010335a:	89 c2                	mov    %eax,%edx
8010335c:	a1 64 54 19 80       	mov    0x80195464,%eax
80103361:	83 ec 08             	sub    $0x8,%esp
80103364:	52                   	push   %edx
80103365:	50                   	push   %eax
80103366:	e8 9e ce ff ff       	call   80100209 <bread>
8010336b:	83 c4 10             	add    $0x10,%esp
8010336e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103374:	83 c0 10             	add    $0x10,%eax
80103377:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010337e:	89 c2                	mov    %eax,%edx
80103380:	a1 64 54 19 80       	mov    0x80195464,%eax
80103385:	83 ec 08             	sub    $0x8,%esp
80103388:	52                   	push   %edx
80103389:	50                   	push   %eax
8010338a:	e8 7a ce ff ff       	call   80100209 <bread>
8010338f:	83 c4 10             	add    $0x10,%esp
80103392:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103395:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103398:	8d 50 5c             	lea    0x5c(%eax),%edx
8010339b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010339e:	83 c0 5c             	add    $0x5c,%eax
801033a1:	83 ec 04             	sub    $0x4,%esp
801033a4:	68 00 02 00 00       	push   $0x200
801033a9:	52                   	push   %edx
801033aa:	50                   	push   %eax
801033ab:	e8 50 1a 00 00       	call   80104e00 <memmove>
801033b0:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801033b3:	83 ec 0c             	sub    $0xc,%esp
801033b6:	ff 75 f0             	push   -0x10(%ebp)
801033b9:	e8 88 ce ff ff       	call   80100246 <bwrite>
801033be:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801033c1:	83 ec 0c             	sub    $0xc,%esp
801033c4:	ff 75 ec             	push   -0x14(%ebp)
801033c7:	e8 c7 ce ff ff       	call   80100293 <brelse>
801033cc:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801033cf:	83 ec 0c             	sub    $0xc,%esp
801033d2:	ff 75 f0             	push   -0x10(%ebp)
801033d5:	e8 b9 ce ff ff       	call   80100293 <brelse>
801033da:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033e1:	a1 68 54 19 80       	mov    0x80195468,%eax
801033e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033e9:	0f 8c 5d ff ff ff    	jl     8010334c <write_log+0x16>
  }
}
801033ef:	90                   	nop
801033f0:	90                   	nop
801033f1:	c9                   	leave
801033f2:	c3                   	ret

801033f3 <commit>:

static void
commit()
{
801033f3:	f3 0f 1e fb          	endbr32
801033f7:	55                   	push   %ebp
801033f8:	89 e5                	mov    %esp,%ebp
801033fa:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033fd:	a1 68 54 19 80       	mov    0x80195468,%eax
80103402:	85 c0                	test   %eax,%eax
80103404:	7e 1e                	jle    80103424 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103406:	e8 2b ff ff ff       	call   80103336 <write_log>
    write_head();    // Write header to disk -- the real commit
8010340b:	e8 21 fd ff ff       	call   80103131 <write_head>
    install_trans(); // Now install writes to home locations
80103410:	e8 e7 fb ff ff       	call   80102ffc <install_trans>
    log.lh.n = 0;
80103415:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
8010341c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010341f:	e8 0d fd ff ff       	call   80103131 <write_head>
  }
}
80103424:	90                   	nop
80103425:	c9                   	leave
80103426:	c3                   	ret

80103427 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103427:	f3 0f 1e fb          	endbr32
8010342b:	55                   	push   %ebp
8010342c:	89 e5                	mov    %esp,%ebp
8010342e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103431:	a1 68 54 19 80       	mov    0x80195468,%eax
80103436:	83 f8 1d             	cmp    $0x1d,%eax
80103439:	7f 12                	jg     8010344d <log_write+0x26>
8010343b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103440:	8b 15 58 54 19 80    	mov    0x80195458,%edx
80103446:	83 ea 01             	sub    $0x1,%edx
80103449:	39 d0                	cmp    %edx,%eax
8010344b:	7c 0d                	jl     8010345a <log_write+0x33>
    panic("too big a transaction");
8010344d:	83 ec 0c             	sub    $0xc,%esp
80103450:	68 30 aa 10 80       	push   $0x8010aa30
80103455:	e8 84 d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
8010345a:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010345f:	85 c0                	test   %eax,%eax
80103461:	7f 0d                	jg     80103470 <log_write+0x49>
    panic("log_write outside of trans");
80103463:	83 ec 0c             	sub    $0xc,%esp
80103466:	68 46 aa 10 80       	push   $0x8010aa46
8010346b:	e8 6e d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103470:	83 ec 0c             	sub    $0xc,%esp
80103473:	68 20 54 19 80       	push   $0x80195420
80103478:	e8 2d 16 00 00       	call   80104aaa <acquire>
8010347d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103487:	eb 1d                	jmp    801034a6 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010348c:	83 c0 10             	add    $0x10,%eax
8010348f:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103496:	89 c2                	mov    %eax,%edx
80103498:	8b 45 08             	mov    0x8(%ebp),%eax
8010349b:	8b 40 08             	mov    0x8(%eax),%eax
8010349e:	39 c2                	cmp    %eax,%edx
801034a0:	74 10                	je     801034b2 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801034a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034a6:	a1 68 54 19 80       	mov    0x80195468,%eax
801034ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034ae:	7c d9                	jl     80103489 <log_write+0x62>
801034b0:	eb 01                	jmp    801034b3 <log_write+0x8c>
      break;
801034b2:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801034b3:	8b 45 08             	mov    0x8(%ebp),%eax
801034b6:	8b 40 08             	mov    0x8(%eax),%eax
801034b9:	89 c2                	mov    %eax,%edx
801034bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034be:	83 c0 10             	add    $0x10,%eax
801034c1:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
801034c8:	a1 68 54 19 80       	mov    0x80195468,%eax
801034cd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034d0:	75 0d                	jne    801034df <log_write+0xb8>
    log.lh.n++;
801034d2:	a1 68 54 19 80       	mov    0x80195468,%eax
801034d7:	83 c0 01             	add    $0x1,%eax
801034da:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
801034df:	8b 45 08             	mov    0x8(%ebp),%eax
801034e2:	8b 00                	mov    (%eax),%eax
801034e4:	83 c8 04             	or     $0x4,%eax
801034e7:	89 c2                	mov    %eax,%edx
801034e9:	8b 45 08             	mov    0x8(%ebp),%eax
801034ec:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801034ee:	83 ec 0c             	sub    $0xc,%esp
801034f1:	68 20 54 19 80       	push   $0x80195420
801034f6:	e8 21 16 00 00       	call   80104b1c <release>
801034fb:	83 c4 10             	add    $0x10,%esp
}
801034fe:	90                   	nop
801034ff:	c9                   	leave
80103500:	c3                   	ret

80103501 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103501:	55                   	push   %ebp
80103502:	89 e5                	mov    %esp,%ebp
80103504:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103507:	8b 55 08             	mov    0x8(%ebp),%edx
8010350a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010350d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103510:	f0 87 02             	lock xchg %eax,(%edx)
80103513:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103516:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103519:	c9                   	leave
8010351a:	c3                   	ret

8010351b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010351b:	f3 0f 1e fb          	endbr32
8010351f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103523:	83 e4 f0             	and    $0xfffffff0,%esp
80103526:	ff 71 fc             	push   -0x4(%ecx)
80103529:	55                   	push   %ebp
8010352a:	89 e5                	mov    %esp,%ebp
8010352c:	51                   	push   %ecx
8010352d:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103530:	e8 14 4f 00 00       	call   80108449 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103535:	83 ec 08             	sub    $0x8,%esp
80103538:	68 00 00 40 80       	push   $0x80400000
8010353d:	68 00 90 19 80       	push   $0x80199000
80103542:	e8 73 f2 ff ff       	call   801027ba <kinit1>
80103547:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010354a:	e8 ec 44 00 00       	call   80107a3b <kvmalloc>
  mpinit_uefi();
8010354f:	e8 ae 4c 00 00       	call   80108202 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103554:	e8 f0 f5 ff ff       	call   80102b49 <lapicinit>
  seginit();       // segment descriptors
80103559:	e8 64 3f 00 00       	call   801074c2 <seginit>
  picinit();    // disable pic
8010355e:	e8 a9 01 00 00       	call   8010370c <picinit>
  ioapicinit();    // another interrupt controller
80103563:	e8 65 f1 ff ff       	call   801026cd <ioapicinit>
  consoleinit();   // console hardware
80103568:	e8 e5 d5 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
8010356d:	e8 d9 32 00 00       	call   8010684b <uartinit>
  pinit();         // process table
80103572:	e8 e2 05 00 00       	call   80103b59 <pinit>
  tvinit();        // trap vectors
80103577:	e8 9c 2d 00 00       	call   80106318 <tvinit>
  binit();         // buffer cache
8010357c:	e8 e5 ca ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103581:	e8 e8 da ff ff       	call   8010106e <fileinit>
  ideinit();       // disk 
80103586:	e8 c3 70 00 00       	call   8010a64e <ideinit>
  startothers();   // start other processors
8010358b:	e8 92 00 00 00       	call   80103622 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103590:	83 ec 08             	sub    $0x8,%esp
80103593:	68 00 00 00 a0       	push   $0xa0000000
80103598:	68 00 00 40 80       	push   $0x80400000
8010359d:	e8 55 f2 ff ff       	call   801027f7 <kinit2>
801035a2:	83 c4 10             	add    $0x10,%esp
  pci_init();
801035a5:	e8 12 51 00 00       	call   801086bc <pci_init>
  arp_scan();
801035aa:	e8 8b 5e 00 00       	call   8010943a <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801035af:	e8 9b 07 00 00       	call   80103d4f <userinit>
  mpmain();        // finish this processor's setup
801035b4:	e8 1e 00 00 00       	call   801035d7 <mpmain>

801035b9 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801035b9:	f3 0f 1e fb          	endbr32
801035bd:	55                   	push   %ebp
801035be:	89 e5                	mov    %esp,%ebp
801035c0:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801035c3:	e8 8f 44 00 00       	call   80107a57 <switchkvm>
  seginit();
801035c8:	e8 f5 3e 00 00       	call   801074c2 <seginit>
  lapicinit();
801035cd:	e8 77 f5 ff ff       	call   80102b49 <lapicinit>
  mpmain();
801035d2:	e8 00 00 00 00       	call   801035d7 <mpmain>

801035d7 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035d7:	f3 0f 1e fb          	endbr32
801035db:	55                   	push   %ebp
801035dc:	89 e5                	mov    %esp,%ebp
801035de:	53                   	push   %ebx
801035df:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801035e2:	e8 94 05 00 00       	call   80103b7b <cpuid>
801035e7:	89 c3                	mov    %eax,%ebx
801035e9:	e8 8d 05 00 00       	call   80103b7b <cpuid>
801035ee:	83 ec 04             	sub    $0x4,%esp
801035f1:	53                   	push   %ebx
801035f2:	50                   	push   %eax
801035f3:	68 61 aa 10 80       	push   $0x8010aa61
801035f8:	e8 0f ce ff ff       	call   8010040c <cprintf>
801035fd:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103600:	e8 8d 2e 00 00       	call   80106492 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103605:	e8 90 05 00 00       	call   80103b9a <mycpu>
8010360a:	05 a0 00 00 00       	add    $0xa0,%eax
8010360f:	83 ec 08             	sub    $0x8,%esp
80103612:	6a 01                	push   $0x1
80103614:	50                   	push   %eax
80103615:	e8 e7 fe ff ff       	call   80103501 <xchg>
8010361a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010361d:	e8 dc 0c 00 00       	call   801042fe <scheduler>

80103622 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103622:	f3 0f 1e fb          	endbr32
80103626:	55                   	push   %ebp
80103627:	89 e5                	mov    %esp,%ebp
80103629:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010362c:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103633:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103638:	83 ec 04             	sub    $0x4,%esp
8010363b:	50                   	push   %eax
8010363c:	68 18 f5 10 80       	push   $0x8010f518
80103641:	ff 75 f0             	push   -0x10(%ebp)
80103644:	e8 b7 17 00 00       	call   80104e00 <memmove>
80103649:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010364c:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
80103653:	eb 79                	jmp    801036ce <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103655:	e8 40 05 00 00       	call   80103b9a <mycpu>
8010365a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010365d:	74 67                	je     801036c6 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010365f:	e8 9b f2 ff ff       	call   801028ff <kalloc>
80103664:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366a:	83 e8 04             	sub    $0x4,%eax
8010366d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103670:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103676:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103678:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367b:	83 e8 08             	sub    $0x8,%eax
8010367e:	c7 00 b9 35 10 80    	movl   $0x801035b9,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103684:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103689:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010368f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103692:	83 e8 0c             	sub    $0xc,%eax
80103695:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801036a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a3:	0f b6 00             	movzbl (%eax),%eax
801036a6:	0f b6 c0             	movzbl %al,%eax
801036a9:	83 ec 08             	sub    $0x8,%esp
801036ac:	52                   	push   %edx
801036ad:	50                   	push   %eax
801036ae:	e8 08 f6 ff ff       	call   80102cbb <lapicstartap>
801036b3:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801036b6:	90                   	nop
801036b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ba:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801036c0:	85 c0                	test   %eax,%eax
801036c2:	74 f3                	je     801036b7 <startothers+0x95>
801036c4:	eb 01                	jmp    801036c7 <startothers+0xa5>
      continue;
801036c6:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801036c7:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801036ce:	a1 80 80 19 80       	mov    0x80198080,%eax
801036d3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801036d9:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801036de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036e1:	0f 82 6e ff ff ff    	jb     80103655 <startothers+0x33>
      ;
  }
}
801036e7:	90                   	nop
801036e8:	90                   	nop
801036e9:	c9                   	leave
801036ea:	c3                   	ret

801036eb <outb>:
{
801036eb:	55                   	push   %ebp
801036ec:	89 e5                	mov    %esp,%ebp
801036ee:	83 ec 08             	sub    $0x8,%esp
801036f1:	8b 45 08             	mov    0x8(%ebp),%eax
801036f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801036f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801036fb:	89 d0                	mov    %edx,%eax
801036fd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103700:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103704:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103708:	ee                   	out    %al,(%dx)
}
80103709:	90                   	nop
8010370a:	c9                   	leave
8010370b:	c3                   	ret

8010370c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010370c:	f3 0f 1e fb          	endbr32
80103710:	55                   	push   %ebp
80103711:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103713:	68 ff 00 00 00       	push   $0xff
80103718:	6a 21                	push   $0x21
8010371a:	e8 cc ff ff ff       	call   801036eb <outb>
8010371f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103722:	68 ff 00 00 00       	push   $0xff
80103727:	68 a1 00 00 00       	push   $0xa1
8010372c:	e8 ba ff ff ff       	call   801036eb <outb>
80103731:	83 c4 08             	add    $0x8,%esp
}
80103734:	90                   	nop
80103735:	c9                   	leave
80103736:	c3                   	ret

80103737 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103737:	f3 0f 1e fb          	endbr32
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103748:	8b 45 0c             	mov    0xc(%ebp),%eax
8010374b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103751:	8b 45 0c             	mov    0xc(%ebp),%eax
80103754:	8b 10                	mov    (%eax),%edx
80103756:	8b 45 08             	mov    0x8(%ebp),%eax
80103759:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010375b:	e8 30 d9 ff ff       	call   80101090 <filealloc>
80103760:	8b 55 08             	mov    0x8(%ebp),%edx
80103763:	89 02                	mov    %eax,(%edx)
80103765:	8b 45 08             	mov    0x8(%ebp),%eax
80103768:	8b 00                	mov    (%eax),%eax
8010376a:	85 c0                	test   %eax,%eax
8010376c:	0f 84 c8 00 00 00    	je     8010383a <pipealloc+0x103>
80103772:	e8 19 d9 ff ff       	call   80101090 <filealloc>
80103777:	8b 55 0c             	mov    0xc(%ebp),%edx
8010377a:	89 02                	mov    %eax,(%edx)
8010377c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010377f:	8b 00                	mov    (%eax),%eax
80103781:	85 c0                	test   %eax,%eax
80103783:	0f 84 b1 00 00 00    	je     8010383a <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103789:	e8 71 f1 ff ff       	call   801028ff <kalloc>
8010378e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103791:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103795:	0f 84 a2 00 00 00    	je     8010383d <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010379b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379e:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801037a5:	00 00 00 
  p->writeopen = 1;
801037a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ab:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801037b2:	00 00 00 
  p->nwrite = 0;
801037b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801037bf:	00 00 00 
  p->nread = 0;
801037c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801037cc:	00 00 00 
  initlock(&p->lock, "pipe");
801037cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d2:	83 ec 08             	sub    $0x8,%esp
801037d5:	68 75 aa 10 80       	push   $0x8010aa75
801037da:	50                   	push   %eax
801037db:	e8 a4 12 00 00       	call   80104a84 <initlock>
801037e0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037e3:	8b 45 08             	mov    0x8(%ebp),%eax
801037e6:	8b 00                	mov    (%eax),%eax
801037e8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037f7:	8b 45 08             	mov    0x8(%ebp),%eax
801037fa:	8b 00                	mov    (%eax),%eax
801037fc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103800:	8b 45 08             	mov    0x8(%ebp),%eax
80103803:	8b 00                	mov    (%eax),%eax
80103805:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103808:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010380b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380e:	8b 00                	mov    (%eax),%eax
80103810:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103816:	8b 45 0c             	mov    0xc(%ebp),%eax
80103819:	8b 00                	mov    (%eax),%eax
8010381b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010381f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103822:	8b 00                	mov    (%eax),%eax
80103824:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103828:	8b 45 0c             	mov    0xc(%ebp),%eax
8010382b:	8b 00                	mov    (%eax),%eax
8010382d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103830:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103833:	b8 00 00 00 00       	mov    $0x0,%eax
80103838:	eb 51                	jmp    8010388b <pipealloc+0x154>
    goto bad;
8010383a:	90                   	nop
8010383b:	eb 01                	jmp    8010383e <pipealloc+0x107>
    goto bad;
8010383d:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010383e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103842:	74 0e                	je     80103852 <pipealloc+0x11b>
    kfree((char*)p);
80103844:	83 ec 0c             	sub    $0xc,%esp
80103847:	ff 75 f4             	push   -0xc(%ebp)
8010384a:	e8 12 f0 ff ff       	call   80102861 <kfree>
8010384f:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103852:	8b 45 08             	mov    0x8(%ebp),%eax
80103855:	8b 00                	mov    (%eax),%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	74 11                	je     8010386c <pipealloc+0x135>
    fileclose(*f0);
8010385b:	8b 45 08             	mov    0x8(%ebp),%eax
8010385e:	8b 00                	mov    (%eax),%eax
80103860:	83 ec 0c             	sub    $0xc,%esp
80103863:	50                   	push   %eax
80103864:	e8 ed d8 ff ff       	call   80101156 <fileclose>
80103869:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010386c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010386f:	8b 00                	mov    (%eax),%eax
80103871:	85 c0                	test   %eax,%eax
80103873:	74 11                	je     80103886 <pipealloc+0x14f>
    fileclose(*f1);
80103875:	8b 45 0c             	mov    0xc(%ebp),%eax
80103878:	8b 00                	mov    (%eax),%eax
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	50                   	push   %eax
8010387e:	e8 d3 d8 ff ff       	call   80101156 <fileclose>
80103883:	83 c4 10             	add    $0x10,%esp
  return -1;
80103886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010388b:	c9                   	leave
8010388c:	c3                   	ret

8010388d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010388d:	f3 0f 1e fb          	endbr32
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103897:	8b 45 08             	mov    0x8(%ebp),%eax
8010389a:	83 ec 0c             	sub    $0xc,%esp
8010389d:	50                   	push   %eax
8010389e:	e8 07 12 00 00       	call   80104aaa <acquire>
801038a3:	83 c4 10             	add    $0x10,%esp
  if(writable){
801038a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801038aa:	74 23                	je     801038cf <pipeclose+0x42>
    p->writeopen = 0;
801038ac:	8b 45 08             	mov    0x8(%ebp),%eax
801038af:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801038b6:	00 00 00 
    wakeup(&p->nread);
801038b9:	8b 45 08             	mov    0x8(%ebp),%eax
801038bc:	05 34 02 00 00       	add    $0x234,%eax
801038c1:	83 ec 0c             	sub    $0xc,%esp
801038c4:	50                   	push   %eax
801038c5:	e8 46 0d 00 00       	call   80104610 <wakeup>
801038ca:	83 c4 10             	add    $0x10,%esp
801038cd:	eb 21                	jmp    801038f0 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801038cf:	8b 45 08             	mov    0x8(%ebp),%eax
801038d2:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801038d9:	00 00 00 
    wakeup(&p->nwrite);
801038dc:	8b 45 08             	mov    0x8(%ebp),%eax
801038df:	05 38 02 00 00       	add    $0x238,%eax
801038e4:	83 ec 0c             	sub    $0xc,%esp
801038e7:	50                   	push   %eax
801038e8:	e8 23 0d 00 00       	call   80104610 <wakeup>
801038ed:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801038f0:	8b 45 08             	mov    0x8(%ebp),%eax
801038f3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038f9:	85 c0                	test   %eax,%eax
801038fb:	75 2c                	jne    80103929 <pipeclose+0x9c>
801038fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103900:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103906:	85 c0                	test   %eax,%eax
80103908:	75 1f                	jne    80103929 <pipeclose+0x9c>
    release(&p->lock);
8010390a:	8b 45 08             	mov    0x8(%ebp),%eax
8010390d:	83 ec 0c             	sub    $0xc,%esp
80103910:	50                   	push   %eax
80103911:	e8 06 12 00 00       	call   80104b1c <release>
80103916:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103919:	83 ec 0c             	sub    $0xc,%esp
8010391c:	ff 75 08             	push   0x8(%ebp)
8010391f:	e8 3d ef ff ff       	call   80102861 <kfree>
80103924:	83 c4 10             	add    $0x10,%esp
80103927:	eb 10                	jmp    80103939 <pipeclose+0xac>
  } else
    release(&p->lock);
80103929:	8b 45 08             	mov    0x8(%ebp),%eax
8010392c:	83 ec 0c             	sub    $0xc,%esp
8010392f:	50                   	push   %eax
80103930:	e8 e7 11 00 00       	call   80104b1c <release>
80103935:	83 c4 10             	add    $0x10,%esp
}
80103938:	90                   	nop
80103939:	90                   	nop
8010393a:	c9                   	leave
8010393b:	c3                   	ret

8010393c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010393c:	f3 0f 1e fb          	endbr32
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	53                   	push   %ebx
80103944:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103947:	8b 45 08             	mov    0x8(%ebp),%eax
8010394a:	83 ec 0c             	sub    $0xc,%esp
8010394d:	50                   	push   %eax
8010394e:	e8 57 11 00 00       	call   80104aaa <acquire>
80103953:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010395d:	e9 ad 00 00 00       	jmp    80103a0f <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103962:	8b 45 08             	mov    0x8(%ebp),%eax
80103965:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010396b:	85 c0                	test   %eax,%eax
8010396d:	74 0c                	je     8010397b <pipewrite+0x3f>
8010396f:	e8 a2 02 00 00       	call   80103c16 <myproc>
80103974:	8b 40 24             	mov    0x24(%eax),%eax
80103977:	85 c0                	test   %eax,%eax
80103979:	74 19                	je     80103994 <pipewrite+0x58>
        release(&p->lock);
8010397b:	8b 45 08             	mov    0x8(%ebp),%eax
8010397e:	83 ec 0c             	sub    $0xc,%esp
80103981:	50                   	push   %eax
80103982:	e8 95 11 00 00       	call   80104b1c <release>
80103987:	83 c4 10             	add    $0x10,%esp
        return -1;
8010398a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010398f:	e9 a9 00 00 00       	jmp    80103a3d <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103994:	8b 45 08             	mov    0x8(%ebp),%eax
80103997:	05 34 02 00 00       	add    $0x234,%eax
8010399c:	83 ec 0c             	sub    $0xc,%esp
8010399f:	50                   	push   %eax
801039a0:	e8 6b 0c 00 00       	call   80104610 <wakeup>
801039a5:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801039a8:	8b 45 08             	mov    0x8(%ebp),%eax
801039ab:	8b 55 08             	mov    0x8(%ebp),%edx
801039ae:	81 c2 38 02 00 00    	add    $0x238,%edx
801039b4:	83 ec 08             	sub    $0x8,%esp
801039b7:	50                   	push   %eax
801039b8:	52                   	push   %edx
801039b9:	e8 63 0b 00 00       	call   80104521 <sleep>
801039be:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801039c1:	8b 45 08             	mov    0x8(%ebp),%eax
801039c4:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801039ca:	8b 45 08             	mov    0x8(%ebp),%eax
801039cd:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801039d3:	05 00 02 00 00       	add    $0x200,%eax
801039d8:	39 c2                	cmp    %eax,%edx
801039da:	74 86                	je     80103962 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039df:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801039e5:	8b 45 08             	mov    0x8(%ebp),%eax
801039e8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801039ee:	8d 48 01             	lea    0x1(%eax),%ecx
801039f1:	8b 55 08             	mov    0x8(%ebp),%edx
801039f4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801039fa:	25 ff 01 00 00       	and    $0x1ff,%eax
801039ff:	89 c1                	mov    %eax,%ecx
80103a01:	0f b6 13             	movzbl (%ebx),%edx
80103a04:	8b 45 08             	mov    0x8(%ebp),%eax
80103a07:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103a0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a12:	3b 45 10             	cmp    0x10(%ebp),%eax
80103a15:	7c aa                	jl     801039c1 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103a17:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1a:	05 34 02 00 00       	add    $0x234,%eax
80103a1f:	83 ec 0c             	sub    $0xc,%esp
80103a22:	50                   	push   %eax
80103a23:	e8 e8 0b 00 00       	call   80104610 <wakeup>
80103a28:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2e:	83 ec 0c             	sub    $0xc,%esp
80103a31:	50                   	push   %eax
80103a32:	e8 e5 10 00 00       	call   80104b1c <release>
80103a37:	83 c4 10             	add    $0x10,%esp
  return n;
80103a3a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103a3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a40:	c9                   	leave
80103a41:	c3                   	ret

80103a42 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103a42:	f3 0f 1e fb          	endbr32
80103a46:	55                   	push   %ebp
80103a47:	89 e5                	mov    %esp,%ebp
80103a49:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	50                   	push   %eax
80103a53:	e8 52 10 00 00       	call   80104aaa <acquire>
80103a58:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a5b:	eb 3e                	jmp    80103a9b <piperead+0x59>
    if(myproc()->killed){
80103a5d:	e8 b4 01 00 00       	call   80103c16 <myproc>
80103a62:	8b 40 24             	mov    0x24(%eax),%eax
80103a65:	85 c0                	test   %eax,%eax
80103a67:	74 19                	je     80103a82 <piperead+0x40>
      release(&p->lock);
80103a69:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6c:	83 ec 0c             	sub    $0xc,%esp
80103a6f:	50                   	push   %eax
80103a70:	e8 a7 10 00 00       	call   80104b1c <release>
80103a75:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a7d:	e9 be 00 00 00       	jmp    80103b40 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a82:	8b 45 08             	mov    0x8(%ebp),%eax
80103a85:	8b 55 08             	mov    0x8(%ebp),%edx
80103a88:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a8e:	83 ec 08             	sub    $0x8,%esp
80103a91:	50                   	push   %eax
80103a92:	52                   	push   %edx
80103a93:	e8 89 0a 00 00       	call   80104521 <sleep>
80103a98:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103aad:	39 c2                	cmp    %eax,%edx
80103aaf:	75 0d                	jne    80103abe <piperead+0x7c>
80103ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103aba:	85 c0                	test   %eax,%eax
80103abc:	75 9f                	jne    80103a5d <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ac5:	eb 48                	jmp    80103b0f <piperead+0xcd>
    if(p->nread == p->nwrite)
80103ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80103aca:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ad9:	39 c2                	cmp    %eax,%edx
80103adb:	74 3c                	je     80103b19 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103add:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ae6:	8d 48 01             	lea    0x1(%eax),%ecx
80103ae9:	8b 55 08             	mov    0x8(%ebp),%edx
80103aec:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103af2:	25 ff 01 00 00       	and    $0x1ff,%eax
80103af7:	89 c1                	mov    %eax,%ecx
80103af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103afc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aff:	01 c2                	add    %eax,%edx
80103b01:	8b 45 08             	mov    0x8(%ebp),%eax
80103b04:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103b09:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103b0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b12:	3b 45 10             	cmp    0x10(%ebp),%eax
80103b15:	7c b0                	jl     80103ac7 <piperead+0x85>
80103b17:	eb 01                	jmp    80103b1a <piperead+0xd8>
      break;
80103b19:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1d:	05 38 02 00 00       	add    $0x238,%eax
80103b22:	83 ec 0c             	sub    $0xc,%esp
80103b25:	50                   	push   %eax
80103b26:	e8 e5 0a 00 00       	call   80104610 <wakeup>
80103b2b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b31:	83 ec 0c             	sub    $0xc,%esp
80103b34:	50                   	push   %eax
80103b35:	e8 e2 0f 00 00       	call   80104b1c <release>
80103b3a:	83 c4 10             	add    $0x10,%esp
  return i;
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b40:	c9                   	leave
80103b41:	c3                   	ret

80103b42 <readeflags>:
{
80103b42:	55                   	push   %ebp
80103b43:	89 e5                	mov    %esp,%ebp
80103b45:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b48:	9c                   	pushf
80103b49:	58                   	pop    %eax
80103b4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b50:	c9                   	leave
80103b51:	c3                   	ret

80103b52 <sti>:
{
80103b52:	55                   	push   %ebp
80103b53:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103b55:	fb                   	sti
}
80103b56:	90                   	nop
80103b57:	5d                   	pop    %ebp
80103b58:	c3                   	ret

80103b59 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103b59:	f3 0f 1e fb          	endbr32
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b63:	83 ec 08             	sub    $0x8,%esp
80103b66:	68 7c aa 10 80       	push   $0x8010aa7c
80103b6b:	68 00 55 19 80       	push   $0x80195500
80103b70:	e8 0f 0f 00 00       	call   80104a84 <initlock>
80103b75:	83 c4 10             	add    $0x10,%esp
}
80103b78:	90                   	nop
80103b79:	c9                   	leave
80103b7a:	c3                   	ret

80103b7b <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b7b:	f3 0f 1e fb          	endbr32
80103b7f:	55                   	push   %ebp
80103b80:	89 e5                	mov    %esp,%ebp
80103b82:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b85:	e8 10 00 00 00       	call   80103b9a <mycpu>
80103b8a:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b8f:	c1 f8 04             	sar    $0x4,%eax
80103b92:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b98:	c9                   	leave
80103b99:	c3                   	ret

80103b9a <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b9a:	f3 0f 1e fb          	endbr32
80103b9e:	55                   	push   %ebp
80103b9f:	89 e5                	mov    %esp,%ebp
80103ba1:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ba4:	e8 99 ff ff ff       	call   80103b42 <readeflags>
80103ba9:	25 00 02 00 00       	and    $0x200,%eax
80103bae:	85 c0                	test   %eax,%eax
80103bb0:	74 0d                	je     80103bbf <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103bb2:	83 ec 0c             	sub    $0xc,%esp
80103bb5:	68 84 aa 10 80       	push   $0x8010aa84
80103bba:	e8 1f ca ff ff       	call   801005de <panic>
  }

  apicid = lapicid();
80103bbf:	e8 a8 f0 ff ff       	call   80102c6c <lapicid>
80103bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103bc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bce:	eb 2d                	jmp    80103bfd <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bd9:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bde:	0f b6 00             	movzbl (%eax),%eax
80103be1:	0f b6 c0             	movzbl %al,%eax
80103be4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103be7:	75 10                	jne    80103bf9 <mycpu+0x5f>
      return &cpus[i];
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bf2:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bf7:	eb 1b                	jmp    80103c14 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103bf9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bfd:	a1 80 80 19 80       	mov    0x80198080,%eax
80103c02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c05:	7c c9                	jl     80103bd0 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103c07:	83 ec 0c             	sub    $0xc,%esp
80103c0a:	68 aa aa 10 80       	push   $0x8010aaaa
80103c0f:	e8 ca c9 ff ff       	call   801005de <panic>
}
80103c14:	c9                   	leave
80103c15:	c3                   	ret

80103c16 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103c16:	f3 0f 1e fb          	endbr32
80103c1a:	55                   	push   %ebp
80103c1b:	89 e5                	mov    %esp,%ebp
80103c1d:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103c20:	e8 01 10 00 00       	call   80104c26 <pushcli>
  c = mycpu();
80103c25:	e8 70 ff ff ff       	call   80103b9a <mycpu>
80103c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c30:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103c36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103c39:	e8 39 10 00 00       	call   80104c77 <popcli>
  return p;
80103c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c41:	c9                   	leave
80103c42:	c3                   	ret

80103c43 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103c43:	f3 0f 1e fb          	endbr32
80103c47:	55                   	push   %ebp
80103c48:	89 e5                	mov    %esp,%ebp
80103c4a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103c4d:	83 ec 0c             	sub    $0xc,%esp
80103c50:	68 00 55 19 80       	push   $0x80195500
80103c55:	e8 50 0e 00 00       	call   80104aaa <acquire>
80103c5a:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c5d:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c64:	eb 0e                	jmp    80103c74 <allocproc+0x31>
    if(p->state == UNUSED){
80103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c69:	8b 40 0c             	mov    0xc(%eax),%eax
80103c6c:	85 c0                	test   %eax,%eax
80103c6e:	74 27                	je     80103c97 <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c70:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c74:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c7b:	72 e9                	jb     80103c66 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c7d:	83 ec 0c             	sub    $0xc,%esp
80103c80:	68 00 55 19 80       	push   $0x80195500
80103c85:	e8 92 0e 00 00       	call   80104b1c <release>
80103c8a:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c8d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c92:	e9 b6 00 00 00       	jmp    80103d4d <allocproc+0x10a>
      goto found;
80103c97:	90                   	nop
80103c98:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ca6:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103cab:	8d 50 01             	lea    0x1(%eax),%edx
80103cae:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb7:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103cba:	83 ec 0c             	sub    $0xc,%esp
80103cbd:	68 00 55 19 80       	push   $0x80195500
80103cc2:	e8 55 0e 00 00       	call   80104b1c <release>
80103cc7:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103cca:	e8 30 ec ff ff       	call   801028ff <kalloc>
80103ccf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd2:	89 42 08             	mov    %eax,0x8(%edx)
80103cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd8:	8b 40 08             	mov    0x8(%eax),%eax
80103cdb:	85 c0                	test   %eax,%eax
80103cdd:	75 11                	jne    80103cf0 <allocproc+0xad>
    p->state = UNUSED;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103ce9:	b8 00 00 00 00       	mov    $0x0,%eax
80103cee:	eb 5d                	jmp    80103d4d <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf3:	8b 40 08             	mov    0x8(%eax),%eax
80103cf6:	05 00 10 00 00       	add    $0x1000,%eax
80103cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103cfe:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d08:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103d0b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103d0f:	ba d2 62 10 80       	mov    $0x801062d2,%edx
80103d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d17:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d19:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d23:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d29:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d2c:	83 ec 04             	sub    $0x4,%esp
80103d2f:	6a 14                	push   $0x14
80103d31:	6a 00                	push   $0x0
80103d33:	50                   	push   %eax
80103d34:	e8 00 10 00 00       	call   80104d39 <memset>
80103d39:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3f:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d42:	ba d7 44 10 80       	mov    $0x801044d7,%edx
80103d47:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d4d:	c9                   	leave
80103d4e:	c3                   	ret

80103d4f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d4f:	f3 0f 1e fb          	endbr32
80103d53:	55                   	push   %ebp
80103d54:	89 e5                	mov    %esp,%ebp
80103d56:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	68 ba aa 10 80       	push   $0x8010aaba
80103d61:	e8 a6 c6 ff ff       	call   8010040c <cprintf>
80103d66:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d69:	e8 d5 fe ff ff       	call   80103c43 <allocproc>
80103d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d74:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d79:	e8 cc 3b 00 00       	call   8010794a <setupkvm>
80103d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d81:	89 42 04             	mov    %eax,0x4(%edx)
80103d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d87:	8b 40 04             	mov    0x4(%eax),%eax
80103d8a:	85 c0                	test   %eax,%eax
80103d8c:	75 0d                	jne    80103d9b <userinit+0x4c>
    panic("userinit: out of memory?");
80103d8e:	83 ec 0c             	sub    $0xc,%esp
80103d91:	68 ca aa 10 80       	push   $0x8010aaca
80103d96:	e8 43 c8 ff ff       	call   801005de <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d9b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da3:	8b 40 04             	mov    0x4(%eax),%eax
80103da6:	83 ec 04             	sub    $0x4,%esp
80103da9:	52                   	push   %edx
80103daa:	68 ec f4 10 80       	push   $0x8010f4ec
80103daf:	50                   	push   %eax
80103db0:	e8 62 3e 00 00       	call   80107c17 <inituvm>
80103db5:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	8b 40 18             	mov    0x18(%eax),%eax
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	6a 4c                	push   $0x4c
80103dcc:	6a 00                	push   $0x0
80103dce:	50                   	push   %eax
80103dcf:	e8 65 0f 00 00       	call   80104d39 <memset>
80103dd4:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dda:	8b 40 18             	mov    0x18(%eax),%eax
80103ddd:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de6:	8b 40 18             	mov    0x18(%eax),%eax
80103de9:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	8b 50 18             	mov    0x18(%eax),%edx
80103df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df8:	8b 40 18             	mov    0x18(%eax),%eax
80103dfb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103dff:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e06:	8b 50 18             	mov    0x18(%eax),%edx
80103e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0c:	8b 40 18             	mov    0x18(%eax),%eax
80103e0f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e13:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1a:	8b 40 18             	mov    0x18(%eax),%eax
80103e1d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e27:	8b 40 18             	mov    0x18(%eax),%eax
80103e2a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	8b 40 18             	mov    0x18(%eax),%eax
80103e37:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e41:	83 c0 6c             	add    $0x6c,%eax
80103e44:	83 ec 04             	sub    $0x4,%esp
80103e47:	6a 10                	push   $0x10
80103e49:	68 e3 aa 10 80       	push   $0x8010aae3
80103e4e:	50                   	push   %eax
80103e4f:	e8 00 11 00 00       	call   80104f54 <safestrcpy>
80103e54:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e57:	83 ec 0c             	sub    $0xc,%esp
80103e5a:	68 ec aa 10 80       	push   $0x8010aaec
80103e5f:	e8 f0 e7 ff ff       	call   80102654 <namei>
80103e64:	83 c4 10             	add    $0x10,%esp
80103e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e6a:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e6d:	83 ec 0c             	sub    $0xc,%esp
80103e70:	68 00 55 19 80       	push   $0x80195500
80103e75:	e8 30 0c 00 00       	call   80104aaa <acquire>
80103e7a:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e80:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e87:	83 ec 0c             	sub    $0xc,%esp
80103e8a:	68 00 55 19 80       	push   $0x80195500
80103e8f:	e8 88 0c 00 00       	call   80104b1c <release>
80103e94:	83 c4 10             	add    $0x10,%esp
}
80103e97:	90                   	nop
80103e98:	c9                   	leave
80103e99:	c3                   	ret

80103e9a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e9a:	f3 0f 1e fb          	endbr32
80103e9e:	55                   	push   %ebp
80103e9f:	89 e5                	mov    %esp,%ebp
80103ea1:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ea4:	e8 6d fd ff ff       	call   80103c16 <myproc>
80103ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eaf:	8b 00                	mov    (%eax),%eax
80103eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103eb4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103eb8:	7e 2e                	jle    80103ee8 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eba:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec0:	01 c2                	add    %eax,%edx
80103ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec5:	8b 40 04             	mov    0x4(%eax),%eax
80103ec8:	83 ec 04             	sub    $0x4,%esp
80103ecb:	52                   	push   %edx
80103ecc:	ff 75 f4             	push   -0xc(%ebp)
80103ecf:	50                   	push   %eax
80103ed0:	e8 87 3e 00 00       	call   80107d5c <allocuvm>
80103ed5:	83 c4 10             	add    $0x10,%esp
80103ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103edb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103edf:	75 3b                	jne    80103f1c <growproc+0x82>
      return -1;
80103ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee6:	eb 4f                	jmp    80103f37 <growproc+0x9d>
  } else if(n < 0){
80103ee8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103eec:	79 2e                	jns    80103f1c <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eee:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef4:	01 c2                	add    %eax,%edx
80103ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ef9:	8b 40 04             	mov    0x4(%eax),%eax
80103efc:	83 ec 04             	sub    $0x4,%esp
80103eff:	52                   	push   %edx
80103f00:	ff 75 f4             	push   -0xc(%ebp)
80103f03:	50                   	push   %eax
80103f04:	e8 5c 3f 00 00       	call   80107e65 <deallocuvm>
80103f09:	83 c4 10             	add    $0x10,%esp
80103f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f13:	75 07                	jne    80103f1c <growproc+0x82>
      return -1;
80103f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f1a:	eb 1b                	jmp    80103f37 <growproc+0x9d>
  }
  curproc->sz = sz;
80103f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f22:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f24:	83 ec 0c             	sub    $0xc,%esp
80103f27:	ff 75 f0             	push   -0x10(%ebp)
80103f2a:	e8 45 3b 00 00       	call   80107a74 <switchuvm>
80103f2f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f37:	c9                   	leave
80103f38:	c3                   	ret

80103f39 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f39:	f3 0f 1e fb          	endbr32
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	57                   	push   %edi
80103f41:	56                   	push   %esi
80103f42:	53                   	push   %ebx
80103f43:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f46:	e8 cb fc ff ff       	call   80103c16 <myproc>
80103f4b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f4e:	e8 f0 fc ff ff       	call   80103c43 <allocproc>
80103f53:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f56:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f5a:	75 0a                	jne    80103f66 <fork+0x2d>
    return -1;
80103f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f61:	e9 48 01 00 00       	jmp    801040ae <fork+0x175>
  } 
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f69:	8b 10                	mov    (%eax),%edx
80103f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f6e:	8b 40 04             	mov    0x4(%eax),%eax
80103f71:	83 ec 08             	sub    $0x8,%esp
80103f74:	52                   	push   %edx
80103f75:	50                   	push   %eax
80103f76:	e8 94 40 00 00       	call   8010800f <copyuvm>
80103f7b:	83 c4 10             	add    $0x10,%esp
80103f7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f81:	89 42 04             	mov    %eax,0x4(%edx)
80103f84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f87:	8b 40 04             	mov    0x4(%eax),%eax
80103f8a:	85 c0                	test   %eax,%eax
80103f8c:	75 30                	jne    80103fbe <fork+0x85>
    kfree(np->kstack);
80103f8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f91:	8b 40 08             	mov    0x8(%eax),%eax
80103f94:	83 ec 0c             	sub    $0xc,%esp
80103f97:	50                   	push   %eax
80103f98:	e8 c4 e8 ff ff       	call   80102861 <kfree>
80103f9d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fa0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103faa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fb9:	e9 f0 00 00 00       	jmp    801040ae <fork+0x175>
  }
  np->sz = curproc->sz;
80103fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fc1:	8b 10                	mov    (%eax),%edx
80103fc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc6:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fcb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103fce:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fd4:	8b 48 18             	mov    0x18(%eax),%ecx
80103fd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fda:	8b 40 18             	mov    0x18(%eax),%eax
80103fdd:	89 c2                	mov    %eax,%edx
80103fdf:	89 cb                	mov    %ecx,%ebx
80103fe1:	b8 13 00 00 00       	mov    $0x13,%eax
80103fe6:	89 d7                	mov    %edx,%edi
80103fe8:	89 de                	mov    %ebx,%esi
80103fea:	89 c1                	mov    %eax,%ecx
80103fec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103fee:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff1:	8b 40 18             	mov    0x18(%eax),%eax
80103ff4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103ffb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104002:	eb 3b                	jmp    8010403f <fork+0x106>
    if(curproc->ofile[i])
80104004:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104007:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010400a:	83 c2 08             	add    $0x8,%edx
8010400d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104011:	85 c0                	test   %eax,%eax
80104013:	74 26                	je     8010403b <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104015:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104018:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010401b:	83 c2 08             	add    $0x8,%edx
8010401e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104022:	83 ec 0c             	sub    $0xc,%esp
80104025:	50                   	push   %eax
80104026:	e8 d6 d0 ff ff       	call   80101101 <filedup>
8010402b:	83 c4 10             	add    $0x10,%esp
8010402e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104031:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104034:	83 c1 08             	add    $0x8,%ecx
80104037:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010403b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010403f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104043:	7e bf                	jle    80104004 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104045:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104048:	8b 40 68             	mov    0x68(%eax),%eax
8010404b:	83 ec 0c             	sub    $0xc,%esp
8010404e:	50                   	push   %eax
8010404f:	e8 57 da ff ff       	call   80101aab <idup>
80104054:	83 c4 10             	add    $0x10,%esp
80104057:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010405a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010405d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104060:	8d 50 6c             	lea    0x6c(%eax),%edx
80104063:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104066:	83 c0 6c             	add    $0x6c,%eax
80104069:	83 ec 04             	sub    $0x4,%esp
8010406c:	6a 10                	push   $0x10
8010406e:	52                   	push   %edx
8010406f:	50                   	push   %eax
80104070:	e8 df 0e 00 00       	call   80104f54 <safestrcpy>
80104075:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104078:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010407b:	8b 40 10             	mov    0x10(%eax),%eax
8010407e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104081:	83 ec 0c             	sub    $0xc,%esp
80104084:	68 00 55 19 80       	push   $0x80195500
80104089:	e8 1c 0a 00 00       	call   80104aaa <acquire>
8010408e:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104091:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104094:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010409b:	83 ec 0c             	sub    $0xc,%esp
8010409e:	68 00 55 19 80       	push   $0x80195500
801040a3:	e8 74 0a 00 00       	call   80104b1c <release>
801040a8:	83 c4 10             	add    $0x10,%esp
  return pid;
801040ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801040ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040b1:	5b                   	pop    %ebx
801040b2:	5e                   	pop    %esi
801040b3:	5f                   	pop    %edi
801040b4:	5d                   	pop    %ebp
801040b5:	c3                   	ret

801040b6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801040b6:	f3 0f 1e fb          	endbr32
801040ba:	55                   	push   %ebp
801040bb:	89 e5                	mov    %esp,%ebp
801040bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801040c0:	e8 51 fb ff ff       	call   80103c16 <myproc>
801040c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801040c8:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801040cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040d0:	75 0d                	jne    801040df <exit+0x29>
    panic("init exiting");
801040d2:	83 ec 0c             	sub    $0xc,%esp
801040d5:	68 ee aa 10 80       	push   $0x8010aaee
801040da:	e8 ff c4 ff ff       	call   801005de <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801040df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801040e6:	eb 3f                	jmp    80104127 <exit+0x71>
    if(curproc->ofile[fd]){
801040e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040ee:	83 c2 08             	add    $0x8,%edx
801040f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040f5:	85 c0                	test   %eax,%eax
801040f7:	74 2a                	je     80104123 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801040f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040ff:	83 c2 08             	add    $0x8,%edx
80104102:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104106:	83 ec 0c             	sub    $0xc,%esp
80104109:	50                   	push   %eax
8010410a:	e8 47 d0 ff ff       	call   80101156 <fileclose>
8010410f:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104112:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104115:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104118:	83 c2 08             	add    $0x8,%edx
8010411b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104122:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104123:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104127:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010412b:	7e bb                	jle    801040e8 <exit+0x32>
    }
  }

  begin_op();
8010412d:	e8 ac f0 ff ff       	call   801031de <begin_op>
  iput(curproc->cwd);
80104132:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104135:	8b 40 68             	mov    0x68(%eax),%eax
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	50                   	push   %eax
8010413c:	e8 11 db ff ff       	call   80101c52 <iput>
80104141:	83 c4 10             	add    $0x10,%esp
  end_op();
80104144:	e8 25 f1 ff ff       	call   8010326e <end_op>
  curproc->cwd = 0;
80104149:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010414c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104153:	83 ec 0c             	sub    $0xc,%esp
80104156:	68 00 55 19 80       	push   $0x80195500
8010415b:	e8 4a 09 00 00       	call   80104aaa <acquire>
80104160:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104163:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104166:	8b 40 14             	mov    0x14(%eax),%eax
80104169:	83 ec 0c             	sub    $0xc,%esp
8010416c:	50                   	push   %eax
8010416d:	e8 5a 04 00 00       	call   801045cc <wakeup1>
80104172:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104175:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010417c:	eb 37                	jmp    801041b5 <exit+0xff>
    if(p->parent == curproc){
8010417e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104181:	8b 40 14             	mov    0x14(%eax),%eax
80104184:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104187:	75 28                	jne    801041b1 <exit+0xfb>
      p->parent = initproc;
80104189:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
8010418f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104192:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104198:	8b 40 0c             	mov    0xc(%eax),%eax
8010419b:	83 f8 05             	cmp    $0x5,%eax
8010419e:	75 11                	jne    801041b1 <exit+0xfb>
        wakeup1(initproc);
801041a0:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801041a5:	83 ec 0c             	sub    $0xc,%esp
801041a8:	50                   	push   %eax
801041a9:	e8 1e 04 00 00       	call   801045cc <wakeup1>
801041ae:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041b1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041b5:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801041bc:	72 c0                	jb     8010417e <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801041be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c1:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801041c8:	e8 0f 02 00 00       	call   801043dc <sched>
  panic("zombie exit");
801041cd:	83 ec 0c             	sub    $0xc,%esp
801041d0:	68 fb aa 10 80       	push   $0x8010aafb
801041d5:	e8 04 c4 ff ff       	call   801005de <panic>

801041da <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801041da:	f3 0f 1e fb          	endbr32
801041de:	55                   	push   %ebp
801041df:	89 e5                	mov    %esp,%ebp
801041e1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801041e4:	e8 2d fa ff ff       	call   80103c16 <myproc>
801041e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801041ec:	83 ec 0c             	sub    $0xc,%esp
801041ef:	68 00 55 19 80       	push   $0x80195500
801041f4:	e8 b1 08 00 00       	call   80104aaa <acquire>
801041f9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801041fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104203:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010420a:	e9 a1 00 00 00       	jmp    801042b0 <wait+0xd6>
      if(p->parent != curproc)
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	8b 40 14             	mov    0x14(%eax),%eax
80104215:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104218:	0f 85 8d 00 00 00    	jne    801042ab <wait+0xd1>
        continue;
      havekids = 1;
8010421e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	8b 40 0c             	mov    0xc(%eax),%eax
8010422b:	83 f8 05             	cmp    $0x5,%eax
8010422e:	75 7c                	jne    801042ac <wait+0xd2>
        // Found one.
        pid = p->pid;
80104230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104233:	8b 40 10             	mov    0x10(%eax),%eax
80104236:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423c:	8b 40 08             	mov    0x8(%eax),%eax
8010423f:	83 ec 0c             	sub    $0xc,%esp
80104242:	50                   	push   %eax
80104243:	e8 19 e6 ff ff       	call   80102861 <kfree>
80104248:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010424b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104258:	8b 40 04             	mov    0x4(%eax),%eax
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	50                   	push   %eax
8010425f:	e8 c9 3c 00 00       	call   80107f2d <freevm>
80104264:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104274:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010427b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104285:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010428c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104296:	83 ec 0c             	sub    $0xc,%esp
80104299:	68 00 55 19 80       	push   $0x80195500
8010429e:	e8 79 08 00 00       	call   80104b1c <release>
801042a3:	83 c4 10             	add    $0x10,%esp
        return pid;
801042a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042a9:	eb 51                	jmp    801042fc <wait+0x122>
        continue;
801042ab:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042ac:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042b0:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801042b7:	0f 82 52 ff ff ff    	jb     8010420f <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801042bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042c1:	74 0a                	je     801042cd <wait+0xf3>
801042c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042c6:	8b 40 24             	mov    0x24(%eax),%eax
801042c9:	85 c0                	test   %eax,%eax
801042cb:	74 17                	je     801042e4 <wait+0x10a>
      release(&ptable.lock);
801042cd:	83 ec 0c             	sub    $0xc,%esp
801042d0:	68 00 55 19 80       	push   $0x80195500
801042d5:	e8 42 08 00 00       	call   80104b1c <release>
801042da:	83 c4 10             	add    $0x10,%esp
      return -1;
801042dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e2:	eb 18                	jmp    801042fc <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801042e4:	83 ec 08             	sub    $0x8,%esp
801042e7:	68 00 55 19 80       	push   $0x80195500
801042ec:	ff 75 ec             	push   -0x14(%ebp)
801042ef:	e8 2d 02 00 00       	call   80104521 <sleep>
801042f4:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801042f7:	e9 00 ff ff ff       	jmp    801041fc <wait+0x22>
  }
}
801042fc:	c9                   	leave
801042fd:	c3                   	ret

801042fe <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801042fe:	f3 0f 1e fb          	endbr32
80104302:	55                   	push   %ebp
80104303:	89 e5                	mov    %esp,%ebp
80104305:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104308:	e8 8d f8 ff ff       	call   80103b9a <mycpu>
8010430d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104313:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010431a:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010431d:	e8 30 f8 ff ff       	call   80103b52 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104322:	83 ec 0c             	sub    $0xc,%esp
80104325:	68 00 55 19 80       	push   $0x80195500
8010432a:	e8 7b 07 00 00       	call   80104aaa <acquire>
8010432f:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104332:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104339:	eb 61                	jmp    8010439c <scheduler+0x9e>
      if(p->state != RUNNABLE)
8010433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433e:	8b 40 0c             	mov    0xc(%eax),%eax
80104341:	83 f8 03             	cmp    $0x3,%eax
80104344:	75 51                	jne    80104397 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104349:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010434c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104352:	83 ec 0c             	sub    $0xc,%esp
80104355:	ff 75 f4             	push   -0xc(%ebp)
80104358:	e8 17 37 00 00       	call   80107a74 <switchuvm>
8010435d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104363:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104370:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104373:	83 c2 04             	add    $0x4,%edx
80104376:	83 ec 08             	sub    $0x8,%esp
80104379:	50                   	push   %eax
8010437a:	52                   	push   %edx
8010437b:	e8 4d 0c 00 00       	call   80104fcd <swtch>
80104380:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104383:	e8 cf 36 00 00       	call   80107a57 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104392:	00 00 00 
80104395:	eb 01                	jmp    80104398 <scheduler+0x9a>
        continue;
80104397:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104398:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010439c:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801043a3:	72 96                	jb     8010433b <scheduler+0x3d>
    }
    release(&ptable.lock);
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	68 00 55 19 80       	push   $0x80195500
801043ad:	e8 6a 07 00 00       	call   80104b1c <release>
801043b2:	83 c4 10             	add    $0x10,%esp
    sti();
801043b5:	e9 63 ff ff ff       	jmp    8010431d <scheduler+0x1f>

801043ba <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
801043ba:	f3 0f 1e fb          	endbr32
801043be:	55                   	push   %ebp
801043bf:	89 e5                	mov    %esp,%ebp
801043c1:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043c4:	e8 4d f8 ff ff       	call   80103c16 <myproc>
801043c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
801043cc:	8b 55 08             	mov    0x8(%ebp),%edx
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
801043d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043da:	c9                   	leave
801043db:	c3                   	ret

801043dc <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801043dc:	f3 0f 1e fb          	endbr32
801043e0:	55                   	push   %ebp
801043e1:	89 e5                	mov    %esp,%ebp
801043e3:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801043e6:	e8 2b f8 ff ff       	call   80103c16 <myproc>
801043eb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801043ee:	83 ec 0c             	sub    $0xc,%esp
801043f1:	68 00 55 19 80       	push   $0x80195500
801043f6:	e8 f6 07 00 00       	call   80104bf1 <holding>
801043fb:	83 c4 10             	add    $0x10,%esp
801043fe:	85 c0                	test   %eax,%eax
80104400:	75 0d                	jne    8010440f <sched+0x33>
    panic("sched ptable.lock");
80104402:	83 ec 0c             	sub    $0xc,%esp
80104405:	68 07 ab 10 80       	push   $0x8010ab07
8010440a:	e8 cf c1 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
8010440f:	e8 86 f7 ff ff       	call   80103b9a <mycpu>
80104414:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010441a:	83 f8 01             	cmp    $0x1,%eax
8010441d:	74 0d                	je     8010442c <sched+0x50>
    panic("sched locks");
8010441f:	83 ec 0c             	sub    $0xc,%esp
80104422:	68 19 ab 10 80       	push   $0x8010ab19
80104427:	e8 b2 c1 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	8b 40 0c             	mov    0xc(%eax),%eax
80104432:	83 f8 04             	cmp    $0x4,%eax
80104435:	75 0d                	jne    80104444 <sched+0x68>
    panic("sched running");
80104437:	83 ec 0c             	sub    $0xc,%esp
8010443a:	68 25 ab 10 80       	push   $0x8010ab25
8010443f:	e8 9a c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
80104444:	e8 f9 f6 ff ff       	call   80103b42 <readeflags>
80104449:	25 00 02 00 00       	and    $0x200,%eax
8010444e:	85 c0                	test   %eax,%eax
80104450:	74 0d                	je     8010445f <sched+0x83>
    panic("sched interruptible");
80104452:	83 ec 0c             	sub    $0xc,%esp
80104455:	68 33 ab 10 80       	push   $0x8010ab33
8010445a:	e8 7f c1 ff ff       	call   801005de <panic>
  intena = mycpu()->intena;
8010445f:	e8 36 f7 ff ff       	call   80103b9a <mycpu>
80104464:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010446a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010446d:	e8 28 f7 ff ff       	call   80103b9a <mycpu>
80104472:	8b 40 04             	mov    0x4(%eax),%eax
80104475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104478:	83 c2 1c             	add    $0x1c,%edx
8010447b:	83 ec 08             	sub    $0x8,%esp
8010447e:	50                   	push   %eax
8010447f:	52                   	push   %edx
80104480:	e8 48 0b 00 00       	call   80104fcd <swtch>
80104485:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104488:	e8 0d f7 ff ff       	call   80103b9a <mycpu>
8010448d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104490:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104496:	90                   	nop
80104497:	c9                   	leave
80104498:	c3                   	ret

80104499 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104499:	f3 0f 1e fb          	endbr32
8010449d:	55                   	push   %ebp
8010449e:	89 e5                	mov    %esp,%ebp
801044a0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044a3:	83 ec 0c             	sub    $0xc,%esp
801044a6:	68 00 55 19 80       	push   $0x80195500
801044ab:	e8 fa 05 00 00       	call   80104aaa <acquire>
801044b0:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044b3:	e8 5e f7 ff ff       	call   80103c16 <myproc>
801044b8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044bf:	e8 18 ff ff ff       	call   801043dc <sched>
  release(&ptable.lock);
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	68 00 55 19 80       	push   $0x80195500
801044cc:	e8 4b 06 00 00       	call   80104b1c <release>
801044d1:	83 c4 10             	add    $0x10,%esp
}
801044d4:	90                   	nop
801044d5:	c9                   	leave
801044d6:	c3                   	ret

801044d7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801044d7:	f3 0f 1e fb          	endbr32
801044db:	55                   	push   %ebp
801044dc:	89 e5                	mov    %esp,%ebp
801044de:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044e1:	83 ec 0c             	sub    $0xc,%esp
801044e4:	68 00 55 19 80       	push   $0x80195500
801044e9:	e8 2e 06 00 00       	call   80104b1c <release>
801044ee:	83 c4 10             	add    $0x10,%esp

  if (first) {
801044f1:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801044f6:	85 c0                	test   %eax,%eax
801044f8:	74 24                	je     8010451e <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801044fa:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104501:	00 00 00 
    iinit(ROOTDEV);
80104504:	83 ec 0c             	sub    $0xc,%esp
80104507:	6a 01                	push   $0x1
80104509:	e8 55 d2 ff ff       	call   80101763 <iinit>
8010450e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104511:	83 ec 0c             	sub    $0xc,%esp
80104514:	6a 01                	push   $0x1
80104516:	e8 90 ea ff ff       	call   80102fab <initlog>
8010451b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010451e:	90                   	nop
8010451f:	c9                   	leave
80104520:	c3                   	ret

80104521 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104521:	f3 0f 1e fb          	endbr32
80104525:	55                   	push   %ebp
80104526:	89 e5                	mov    %esp,%ebp
80104528:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010452b:	e8 e6 f6 ff ff       	call   80103c16 <myproc>
80104530:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104533:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104537:	75 0d                	jne    80104546 <sleep+0x25>
    panic("sleep");
80104539:	83 ec 0c             	sub    $0xc,%esp
8010453c:	68 47 ab 10 80       	push   $0x8010ab47
80104541:	e8 98 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
80104546:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010454a:	75 0d                	jne    80104559 <sleep+0x38>
    panic("sleep without lk");
8010454c:	83 ec 0c             	sub    $0xc,%esp
8010454f:	68 4d ab 10 80       	push   $0x8010ab4d
80104554:	e8 85 c0 ff ff       	call   801005de <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104559:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104560:	74 1e                	je     80104580 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	68 00 55 19 80       	push   $0x80195500
8010456a:	e8 3b 05 00 00       	call   80104aaa <acquire>
8010456f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	ff 75 0c             	push   0xc(%ebp)
80104578:	e8 9f 05 00 00       	call   80104b1c <release>
8010457d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	8b 55 08             	mov    0x8(%ebp),%edx
80104586:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104593:	e8 44 fe ff ff       	call   801043dc <sched>

  // Tidy up.
  p->chan = 0;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045a2:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801045a9:	74 1e                	je     801045c9 <sleep+0xa8>
    release(&ptable.lock);
801045ab:	83 ec 0c             	sub    $0xc,%esp
801045ae:	68 00 55 19 80       	push   $0x80195500
801045b3:	e8 64 05 00 00       	call   80104b1c <release>
801045b8:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045bb:	83 ec 0c             	sub    $0xc,%esp
801045be:	ff 75 0c             	push   0xc(%ebp)
801045c1:	e8 e4 04 00 00       	call   80104aaa <acquire>
801045c6:	83 c4 10             	add    $0x10,%esp
  }
}
801045c9:	90                   	nop
801045ca:	c9                   	leave
801045cb:	c3                   	ret

801045cc <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045cc:	f3 0f 1e fb          	endbr32
801045d0:	55                   	push   %ebp
801045d1:	89 e5                	mov    %esp,%ebp
801045d3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045d6:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801045dd:	eb 24                	jmp    80104603 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
801045df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045e2:	8b 40 0c             	mov    0xc(%eax),%eax
801045e5:	83 f8 02             	cmp    $0x2,%eax
801045e8:	75 15                	jne    801045ff <wakeup1+0x33>
801045ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045ed:	8b 40 20             	mov    0x20(%eax),%eax
801045f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801045f3:	75 0a                	jne    801045ff <wakeup1+0x33>
      p->state = RUNNABLE;
801045f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045f8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045ff:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104603:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
8010460a:	72 d3                	jb     801045df <wakeup1+0x13>
}
8010460c:	90                   	nop
8010460d:	90                   	nop
8010460e:	c9                   	leave
8010460f:	c3                   	ret

80104610 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104610:	f3 0f 1e fb          	endbr32
80104614:	55                   	push   %ebp
80104615:	89 e5                	mov    %esp,%ebp
80104617:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010461a:	83 ec 0c             	sub    $0xc,%esp
8010461d:	68 00 55 19 80       	push   $0x80195500
80104622:	e8 83 04 00 00       	call   80104aaa <acquire>
80104627:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010462a:	83 ec 0c             	sub    $0xc,%esp
8010462d:	ff 75 08             	push   0x8(%ebp)
80104630:	e8 97 ff ff ff       	call   801045cc <wakeup1>
80104635:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104638:	83 ec 0c             	sub    $0xc,%esp
8010463b:	68 00 55 19 80       	push   $0x80195500
80104640:	e8 d7 04 00 00       	call   80104b1c <release>
80104645:	83 c4 10             	add    $0x10,%esp
}
80104648:	90                   	nop
80104649:	c9                   	leave
8010464a:	c3                   	ret

8010464b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010464b:	f3 0f 1e fb          	endbr32
8010464f:	55                   	push   %ebp
80104650:	89 e5                	mov    %esp,%ebp
80104652:	83 ec 18             	sub    $0x18,%esp
  cprintf("kill\n");
80104655:	83 ec 0c             	sub    $0xc,%esp
80104658:	68 5e ab 10 80       	push   $0x8010ab5e
8010465d:	e8 aa bd ff ff       	call   8010040c <cprintf>
80104662:	83 c4 10             	add    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104665:	83 ec 0c             	sub    $0xc,%esp
80104668:	68 00 55 19 80       	push   $0x80195500
8010466d:	e8 38 04 00 00       	call   80104aaa <acquire>
80104672:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104675:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010467c:	eb 45                	jmp    801046c3 <kill+0x78>
    if(p->pid == pid){
8010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104681:	8b 40 10             	mov    0x10(%eax),%eax
80104684:	39 45 08             	cmp    %eax,0x8(%ebp)
80104687:	75 36                	jne    801046bf <kill+0x74>
      p->killed = 1;
80104689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	8b 40 0c             	mov    0xc(%eax),%eax
80104699:	83 f8 02             	cmp    $0x2,%eax
8010469c:	75 0a                	jne    801046a8 <kill+0x5d>
        p->state = RUNNABLE;
8010469e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	68 00 55 19 80       	push   $0x80195500
801046b0:	e8 67 04 00 00       	call   80104b1c <release>
801046b5:	83 c4 10             	add    $0x10,%esp
      return 0;
801046b8:	b8 00 00 00 00       	mov    $0x0,%eax
801046bd:	eb 22                	jmp    801046e1 <kill+0x96>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046bf:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046c3:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801046ca:	72 b2                	jb     8010467e <kill+0x33>
    }
  }
  release(&ptable.lock);
801046cc:	83 ec 0c             	sub    $0xc,%esp
801046cf:	68 00 55 19 80       	push   $0x80195500
801046d4:	e8 43 04 00 00       	call   80104b1c <release>
801046d9:	83 c4 10             	add    $0x10,%esp
  return -1;
801046dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046e1:	c9                   	leave
801046e2:	c3                   	ret

801046e3 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046e3:	f3 0f 1e fb          	endbr32
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
801046ea:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046ed:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801046f4:	e9 d7 00 00 00       	jmp    801047d0 <procdump+0xed>
    if(p->state == UNUSED)
801046f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fc:	8b 40 0c             	mov    0xc(%eax),%eax
801046ff:	85 c0                	test   %eax,%eax
80104701:	0f 84 c4 00 00 00    	je     801047cb <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470a:	8b 40 0c             	mov    0xc(%eax),%eax
8010470d:	83 f8 05             	cmp    $0x5,%eax
80104710:	77 23                	ja     80104735 <procdump+0x52>
80104712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104715:	8b 40 0c             	mov    0xc(%eax),%eax
80104718:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010471f:	85 c0                	test   %eax,%eax
80104721:	74 12                	je     80104735 <procdump+0x52>
      state = states[p->state];
80104723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104726:	8b 40 0c             	mov    0xc(%eax),%eax
80104729:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104730:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104733:	eb 07                	jmp    8010473c <procdump+0x59>
    else
      state = "???";
80104735:	c7 45 ec 64 ab 10 80 	movl   $0x8010ab64,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010473c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104745:	8b 40 10             	mov    0x10(%eax),%eax
80104748:	52                   	push   %edx
80104749:	ff 75 ec             	push   -0x14(%ebp)
8010474c:	50                   	push   %eax
8010474d:	68 68 ab 10 80       	push   $0x8010ab68
80104752:	e8 b5 bc ff ff       	call   8010040c <cprintf>
80104757:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010475a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010475d:	8b 40 0c             	mov    0xc(%eax),%eax
80104760:	83 f8 02             	cmp    $0x2,%eax
80104763:	75 54                	jne    801047b9 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104768:	8b 40 1c             	mov    0x1c(%eax),%eax
8010476b:	8b 40 0c             	mov    0xc(%eax),%eax
8010476e:	83 c0 08             	add    $0x8,%eax
80104771:	89 c2                	mov    %eax,%edx
80104773:	83 ec 08             	sub    $0x8,%esp
80104776:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104779:	50                   	push   %eax
8010477a:	52                   	push   %edx
8010477b:	e8 f2 03 00 00       	call   80104b72 <getcallerpcs>
80104780:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010478a:	eb 1c                	jmp    801047a8 <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010478c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104793:	83 ec 08             	sub    $0x8,%esp
80104796:	50                   	push   %eax
80104797:	68 71 ab 10 80       	push   $0x8010ab71
8010479c:	e8 6b bc ff ff       	call   8010040c <cprintf>
801047a1:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047a8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047ac:	7f 0b                	jg     801047b9 <procdump+0xd6>
801047ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047b5:	85 c0                	test   %eax,%eax
801047b7:	75 d3                	jne    8010478c <procdump+0xa9>
    }
    cprintf("\n");
801047b9:	83 ec 0c             	sub    $0xc,%esp
801047bc:	68 75 ab 10 80       	push   $0x8010ab75
801047c1:	e8 46 bc ff ff       	call   8010040c <cprintf>
801047c6:	83 c4 10             	add    $0x10,%esp
801047c9:	eb 01                	jmp    801047cc <procdump+0xe9>
      continue;
801047cb:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047cc:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801047d0:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
801047d7:	0f 82 1c ff ff ff    	jb     801046f9 <procdump+0x16>
  }
}
801047dd:	90                   	nop
801047de:	90                   	nop
801047df:	c9                   	leave
801047e0:	c3                   	ret

801047e1 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
801047e1:	f3 0f 1e fb          	endbr32
801047e5:	55                   	push   %ebp
801047e6:	89 e5                	mov    %esp,%ebp
801047e8:	53                   	push   %ebx
801047e9:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ec:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801047f3:	eb 0f                	jmp    80104804 <printpt+0x23>
    if (p->pid == pid)
801047f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f8:	8b 40 10             	mov    0x10(%eax),%eax
801047fb:	39 45 08             	cmp    %eax,0x8(%ebp)
801047fe:	74 0f                	je     8010480f <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104800:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104804:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010480b:	72 e8                	jb     801047f5 <printpt+0x14>
8010480d:	eb 01                	jmp    80104810 <printpt+0x2f>
      break;
8010480f:	90                   	nop
  }
  if (p == 0){
80104810:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104814:	75 1a                	jne    80104830 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
80104816:	83 ec 0c             	sub    $0xc,%esp
80104819:	68 77 ab 10 80       	push   $0x8010ab77
8010481e:	e8 e9 bb ff ff       	call   8010040c <cprintf>
80104823:	83 c4 10             	add    $0x10,%esp
    return -1;
80104826:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482b:	e9 e2 00 00 00       	jmp    80104912 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	8b 40 04             	mov    0x4(%eax),%eax
80104836:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
80104839:	83 ec 08             	sub    $0x8,%esp
8010483c:	ff 75 08             	push   0x8(%ebp)
8010483f:	68 93 ab 10 80       	push   $0x8010ab93
80104844:	e8 c3 bb ff ff       	call   8010040c <cprintf>
80104849:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010484c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104853:	e9 9a 00 00 00       	jmp    801048f2 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
80104858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485b:	83 ec 04             	sub    $0x4,%esp
8010485e:	6a 00                	push   $0x0
80104860:	50                   	push   %eax
80104861:	ff 75 ec             	push   -0x14(%ebp)
80104864:	e8 b3 2f 00 00       	call   8010781c <walkpgdir>
80104869:	83 c4 10             	add    $0x10,%esp
8010486c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
8010486f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104872:	8b 00                	mov    (%eax),%eax
80104874:	83 e0 01             	and    $0x1,%eax
80104877:	85 c0                	test   %eax,%eax
80104879:	74 6f                	je     801048ea <printpt+0x109>
8010487b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010487f:	74 69                	je     801048ea <printpt+0x109>
    cprintf("pte: %x\n",pte);
80104881:	83 ec 08             	sub    $0x8,%esp
80104884:	ff 75 e8             	push   -0x18(%ebp)
80104887:	68 af ab 10 80       	push   $0x8010abaf
8010488c:	e8 7b bb ff ff       	call   8010040c <cprintf>
80104891:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104894:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104897:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
80104899:	c1 e8 0c             	shr    $0xc,%eax
8010489c:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
8010489e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a1:	8b 00                	mov    (%eax),%eax
801048a3:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048a6:	85 c0                	test   %eax,%eax
801048a8:	74 07                	je     801048b1 <printpt+0xd0>
801048aa:	bb 57 00 00 00       	mov    $0x57,%ebx
801048af:	eb 05                	jmp    801048b6 <printpt+0xd5>
801048b1:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801048b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048b9:	8b 00                	mov    (%eax),%eax
801048bb:	83 e0 04             	and    $0x4,%eax
801048be:	85 c0                	test   %eax,%eax
801048c0:	74 07                	je     801048c9 <printpt+0xe8>
801048c2:	b9 55 00 00 00       	mov    $0x55,%ecx
801048c7:	eb 05                	jmp    801048ce <printpt+0xed>
801048c9:	b9 4b 00 00 00       	mov    $0x4b,%ecx
801048ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d1:	c1 e8 0c             	shr    $0xc,%eax
801048d4:	83 ec 0c             	sub    $0xc,%esp
801048d7:	52                   	push   %edx
801048d8:	53                   	push   %ebx
801048d9:	51                   	push   %ecx
801048da:	50                   	push   %eax
801048db:	68 b8 ab 10 80       	push   $0x8010abb8
801048e0:	e8 27 bb ff ff       	call   8010040c <cprintf>
801048e5:	83 c4 20             	add    $0x20,%esp
801048e8:	eb 01                	jmp    801048eb <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
801048ea:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
801048eb:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801048f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f5:	85 c0                	test   %eax,%eax
801048f7:	0f 89 5b ff ff ff    	jns    80104858 <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	68 c7 ab 10 80       	push   $0x8010abc7
80104905:	e8 02 bb ff ff       	call   8010040c <cprintf>
8010490a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010490d:	b8 00 00 00 00       	mov    $0x0,%eax
80104912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104915:	c9                   	leave
80104916:	c3                   	ret

80104917 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104917:	f3 0f 1e fb          	endbr32
8010491b:	55                   	push   %ebp
8010491c:	89 e5                	mov    %esp,%ebp
8010491e:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104921:	8b 45 08             	mov    0x8(%ebp),%eax
80104924:	83 c0 04             	add    $0x4,%eax
80104927:	83 ec 08             	sub    $0x8,%esp
8010492a:	68 01 ac 10 80       	push   $0x8010ac01
8010492f:	50                   	push   %eax
80104930:	e8 4f 01 00 00       	call   80104a84 <initlock>
80104935:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104938:	8b 45 08             	mov    0x8(%ebp),%eax
8010493b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010493e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104941:	8b 45 08             	mov    0x8(%ebp),%eax
80104944:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010494a:	8b 45 08             	mov    0x8(%ebp),%eax
8010494d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104954:	90                   	nop
80104955:	c9                   	leave
80104956:	c3                   	ret

80104957 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104957:	f3 0f 1e fb          	endbr32
8010495b:	55                   	push   %ebp
8010495c:	89 e5                	mov    %esp,%ebp
8010495e:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104961:	8b 45 08             	mov    0x8(%ebp),%eax
80104964:	83 c0 04             	add    $0x4,%eax
80104967:	83 ec 0c             	sub    $0xc,%esp
8010496a:	50                   	push   %eax
8010496b:	e8 3a 01 00 00       	call   80104aaa <acquire>
80104970:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104973:	eb 15                	jmp    8010498a <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104975:	8b 45 08             	mov    0x8(%ebp),%eax
80104978:	83 c0 04             	add    $0x4,%eax
8010497b:	83 ec 08             	sub    $0x8,%esp
8010497e:	50                   	push   %eax
8010497f:	ff 75 08             	push   0x8(%ebp)
80104982:	e8 9a fb ff ff       	call   80104521 <sleep>
80104987:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010498a:	8b 45 08             	mov    0x8(%ebp),%eax
8010498d:	8b 00                	mov    (%eax),%eax
8010498f:	85 c0                	test   %eax,%eax
80104991:	75 e2                	jne    80104975 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104993:	8b 45 08             	mov    0x8(%ebp),%eax
80104996:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010499c:	e8 75 f2 ff ff       	call   80103c16 <myproc>
801049a1:	8b 50 10             	mov    0x10(%eax),%edx
801049a4:	8b 45 08             	mov    0x8(%ebp),%eax
801049a7:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801049aa:	8b 45 08             	mov    0x8(%ebp),%eax
801049ad:	83 c0 04             	add    $0x4,%eax
801049b0:	83 ec 0c             	sub    $0xc,%esp
801049b3:	50                   	push   %eax
801049b4:	e8 63 01 00 00       	call   80104b1c <release>
801049b9:	83 c4 10             	add    $0x10,%esp
}
801049bc:	90                   	nop
801049bd:	c9                   	leave
801049be:	c3                   	ret

801049bf <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801049bf:	f3 0f 1e fb          	endbr32
801049c3:	55                   	push   %ebp
801049c4:	89 e5                	mov    %esp,%ebp
801049c6:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049c9:	8b 45 08             	mov    0x8(%ebp),%eax
801049cc:	83 c0 04             	add    $0x4,%eax
801049cf:	83 ec 0c             	sub    $0xc,%esp
801049d2:	50                   	push   %eax
801049d3:	e8 d2 00 00 00       	call   80104aaa <acquire>
801049d8:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801049db:	8b 45 08             	mov    0x8(%ebp),%eax
801049de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049e4:	8b 45 08             	mov    0x8(%ebp),%eax
801049e7:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	ff 75 08             	push   0x8(%ebp)
801049f4:	e8 17 fc ff ff       	call   80104610 <wakeup>
801049f9:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801049fc:	8b 45 08             	mov    0x8(%ebp),%eax
801049ff:	83 c0 04             	add    $0x4,%eax
80104a02:	83 ec 0c             	sub    $0xc,%esp
80104a05:	50                   	push   %eax
80104a06:	e8 11 01 00 00       	call   80104b1c <release>
80104a0b:	83 c4 10             	add    $0x10,%esp
}
80104a0e:	90                   	nop
80104a0f:	c9                   	leave
80104a10:	c3                   	ret

80104a11 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a11:	f3 0f 1e fb          	endbr32
80104a15:	55                   	push   %ebp
80104a16:	89 e5                	mov    %esp,%ebp
80104a18:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1e:	83 c0 04             	add    $0x4,%eax
80104a21:	83 ec 0c             	sub    $0xc,%esp
80104a24:	50                   	push   %eax
80104a25:	e8 80 00 00 00       	call   80104aaa <acquire>
80104a2a:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a30:	8b 00                	mov    (%eax),%eax
80104a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a35:	8b 45 08             	mov    0x8(%ebp),%eax
80104a38:	83 c0 04             	add    $0x4,%eax
80104a3b:	83 ec 0c             	sub    $0xc,%esp
80104a3e:	50                   	push   %eax
80104a3f:	e8 d8 00 00 00       	call   80104b1c <release>
80104a44:	83 c4 10             	add    $0x10,%esp
  return r;
80104a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a4a:	c9                   	leave
80104a4b:	c3                   	ret

80104a4c <readeflags>:
{
80104a4c:	55                   	push   %ebp
80104a4d:	89 e5                	mov    %esp,%ebp
80104a4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a52:	9c                   	pushf
80104a53:	58                   	pop    %eax
80104a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a5a:	c9                   	leave
80104a5b:	c3                   	ret

80104a5c <cli>:
{
80104a5c:	55                   	push   %ebp
80104a5d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a5f:	fa                   	cli
}
80104a60:	90                   	nop
80104a61:	5d                   	pop    %ebp
80104a62:	c3                   	ret

80104a63 <sti>:
{
80104a63:	55                   	push   %ebp
80104a64:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a66:	fb                   	sti
}
80104a67:	90                   	nop
80104a68:	5d                   	pop    %ebp
80104a69:	c3                   	ret

80104a6a <xchg>:
{
80104a6a:	55                   	push   %ebp
80104a6b:	89 e5                	mov    %esp,%ebp
80104a6d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a70:	8b 55 08             	mov    0x8(%ebp),%edx
80104a73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a79:	f0 87 02             	lock xchg %eax,(%edx)
80104a7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a82:	c9                   	leave
80104a83:	c3                   	ret

80104a84 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a84:	f3 0f 1e fb          	endbr32
80104a88:	55                   	push   %ebp
80104a89:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a91:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a94:	8b 45 08             	mov    0x8(%ebp),%eax
80104a97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104aa7:	90                   	nop
80104aa8:	5d                   	pop    %ebp
80104aa9:	c3                   	ret

80104aaa <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104aaa:	f3 0f 1e fb          	endbr32
80104aae:	55                   	push   %ebp
80104aaf:	89 e5                	mov    %esp,%ebp
80104ab1:	53                   	push   %ebx
80104ab2:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ab5:	e8 6c 01 00 00       	call   80104c26 <pushcli>
  if(holding(lk)){
80104aba:	8b 45 08             	mov    0x8(%ebp),%eax
80104abd:	83 ec 0c             	sub    $0xc,%esp
80104ac0:	50                   	push   %eax
80104ac1:	e8 2b 01 00 00       	call   80104bf1 <holding>
80104ac6:	83 c4 10             	add    $0x10,%esp
80104ac9:	85 c0                	test   %eax,%eax
80104acb:	74 0d                	je     80104ada <acquire+0x30>
    panic("acquire");
80104acd:	83 ec 0c             	sub    $0xc,%esp
80104ad0:	68 0c ac 10 80       	push   $0x8010ac0c
80104ad5:	e8 04 bb ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104ada:	90                   	nop
80104adb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ade:	83 ec 08             	sub    $0x8,%esp
80104ae1:	6a 01                	push   $0x1
80104ae3:	50                   	push   %eax
80104ae4:	e8 81 ff ff ff       	call   80104a6a <xchg>
80104ae9:	83 c4 10             	add    $0x10,%esp
80104aec:	85 c0                	test   %eax,%eax
80104aee:	75 eb                	jne    80104adb <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104af0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104af8:	e8 9d f0 ff ff       	call   80103b9a <mycpu>
80104afd:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b00:	8b 45 08             	mov    0x8(%ebp),%eax
80104b03:	83 c0 0c             	add    $0xc,%eax
80104b06:	83 ec 08             	sub    $0x8,%esp
80104b09:	50                   	push   %eax
80104b0a:	8d 45 08             	lea    0x8(%ebp),%eax
80104b0d:	50                   	push   %eax
80104b0e:	e8 5f 00 00 00       	call   80104b72 <getcallerpcs>
80104b13:	83 c4 10             	add    $0x10,%esp
}
80104b16:	90                   	nop
80104b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b1a:	c9                   	leave
80104b1b:	c3                   	ret

80104b1c <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b1c:	f3 0f 1e fb          	endbr32
80104b20:	55                   	push   %ebp
80104b21:	89 e5                	mov    %esp,%ebp
80104b23:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b26:	83 ec 0c             	sub    $0xc,%esp
80104b29:	ff 75 08             	push   0x8(%ebp)
80104b2c:	e8 c0 00 00 00       	call   80104bf1 <holding>
80104b31:	83 c4 10             	add    $0x10,%esp
80104b34:	85 c0                	test   %eax,%eax
80104b36:	75 0d                	jne    80104b45 <release+0x29>
    panic("release");
80104b38:	83 ec 0c             	sub    $0xc,%esp
80104b3b:	68 14 ac 10 80       	push   $0x8010ac14
80104b40:	e8 99 ba ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104b45:	8b 45 08             	mov    0x8(%ebp),%eax
80104b48:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b59:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b61:	8b 55 08             	mov    0x8(%ebp),%edx
80104b64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b6a:	e8 08 01 00 00       	call   80104c77 <popcli>
}
80104b6f:	90                   	nop
80104b70:	c9                   	leave
80104b71:	c3                   	ret

80104b72 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b72:	f3 0f 1e fb          	endbr32
80104b76:	55                   	push   %ebp
80104b77:	89 e5                	mov    %esp,%ebp
80104b79:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	83 e8 08             	sub    $0x8,%eax
80104b82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b85:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b8c:	eb 38                	jmp    80104bc6 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b8e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b92:	74 53                	je     80104be7 <getcallerpcs+0x75>
80104b94:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b9b:	76 4a                	jbe    80104be7 <getcallerpcs+0x75>
80104b9d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104ba1:	74 44                	je     80104be7 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104ba3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ba6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bad:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb0:	01 c2                	add    %eax,%edx
80104bb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb5:	8b 40 04             	mov    0x4(%eax),%eax
80104bb8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bbd:	8b 00                	mov    (%eax),%eax
80104bbf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bc2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bc6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bca:	7e c2                	jle    80104b8e <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104bcc:	eb 19                	jmp    80104be7 <getcallerpcs+0x75>
    pcs[i] = 0;
80104bce:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdb:	01 d0                	add    %edx,%eax
80104bdd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104be3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104be7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104beb:	7e e1                	jle    80104bce <getcallerpcs+0x5c>
}
80104bed:	90                   	nop
80104bee:	90                   	nop
80104bef:	c9                   	leave
80104bf0:	c3                   	ret

80104bf1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104bf1:	f3 0f 1e fb          	endbr32
80104bf5:	55                   	push   %ebp
80104bf6:	89 e5                	mov    %esp,%ebp
80104bf8:	53                   	push   %ebx
80104bf9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bff:	8b 00                	mov    (%eax),%eax
80104c01:	85 c0                	test   %eax,%eax
80104c03:	74 16                	je     80104c1b <holding+0x2a>
80104c05:	8b 45 08             	mov    0x8(%ebp),%eax
80104c08:	8b 58 08             	mov    0x8(%eax),%ebx
80104c0b:	e8 8a ef ff ff       	call   80103b9a <mycpu>
80104c10:	39 c3                	cmp    %eax,%ebx
80104c12:	75 07                	jne    80104c1b <holding+0x2a>
80104c14:	b8 01 00 00 00       	mov    $0x1,%eax
80104c19:	eb 05                	jmp    80104c20 <holding+0x2f>
80104c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c20:	83 c4 04             	add    $0x4,%esp
80104c23:	5b                   	pop    %ebx
80104c24:	5d                   	pop    %ebp
80104c25:	c3                   	ret

80104c26 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c26:	f3 0f 1e fb          	endbr32
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c30:	e8 17 fe ff ff       	call   80104a4c <readeflags>
80104c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c38:	e8 1f fe ff ff       	call   80104a5c <cli>
  if(mycpu()->ncli == 0)
80104c3d:	e8 58 ef ff ff       	call   80103b9a <mycpu>
80104c42:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c48:	85 c0                	test   %eax,%eax
80104c4a:	75 14                	jne    80104c60 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104c4c:	e8 49 ef ff ff       	call   80103b9a <mycpu>
80104c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c54:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c5a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c60:	e8 35 ef ff ff       	call   80103b9a <mycpu>
80104c65:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c6b:	83 c2 01             	add    $0x1,%edx
80104c6e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c74:	90                   	nop
80104c75:	c9                   	leave
80104c76:	c3                   	ret

80104c77 <popcli>:

void
popcli(void)
{
80104c77:	f3 0f 1e fb          	endbr32
80104c7b:	55                   	push   %ebp
80104c7c:	89 e5                	mov    %esp,%ebp
80104c7e:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c81:	e8 c6 fd ff ff       	call   80104a4c <readeflags>
80104c86:	25 00 02 00 00       	and    $0x200,%eax
80104c8b:	85 c0                	test   %eax,%eax
80104c8d:	74 0d                	je     80104c9c <popcli+0x25>
    panic("popcli - interruptible");
80104c8f:	83 ec 0c             	sub    $0xc,%esp
80104c92:	68 1c ac 10 80       	push   $0x8010ac1c
80104c97:	e8 42 b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104c9c:	e8 f9 ee ff ff       	call   80103b9a <mycpu>
80104ca1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ca7:	83 ea 01             	sub    $0x1,%edx
80104caa:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104cb0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cb6:	85 c0                	test   %eax,%eax
80104cb8:	79 0d                	jns    80104cc7 <popcli+0x50>
    panic("popcli");
80104cba:	83 ec 0c             	sub    $0xc,%esp
80104cbd:	68 33 ac 10 80       	push   $0x8010ac33
80104cc2:	e8 17 b9 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104cc7:	e8 ce ee ff ff       	call   80103b9a <mycpu>
80104ccc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cd2:	85 c0                	test   %eax,%eax
80104cd4:	75 14                	jne    80104cea <popcli+0x73>
80104cd6:	e8 bf ee ff ff       	call   80103b9a <mycpu>
80104cdb:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104ce1:	85 c0                	test   %eax,%eax
80104ce3:	74 05                	je     80104cea <popcli+0x73>
    sti();
80104ce5:	e8 79 fd ff ff       	call   80104a63 <sti>
}
80104cea:	90                   	nop
80104ceb:	c9                   	leave
80104cec:	c3                   	ret

80104ced <stosb>:
{
80104ced:	55                   	push   %ebp
80104cee:	89 e5                	mov    %esp,%ebp
80104cf0:	57                   	push   %edi
80104cf1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cf5:	8b 55 10             	mov    0x10(%ebp),%edx
80104cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cfb:	89 cb                	mov    %ecx,%ebx
80104cfd:	89 df                	mov    %ebx,%edi
80104cff:	89 d1                	mov    %edx,%ecx
80104d01:	fc                   	cld
80104d02:	f3 aa                	rep stos %al,%es:(%edi)
80104d04:	89 ca                	mov    %ecx,%edx
80104d06:	89 fb                	mov    %edi,%ebx
80104d08:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d0b:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d0e:	90                   	nop
80104d0f:	5b                   	pop    %ebx
80104d10:	5f                   	pop    %edi
80104d11:	5d                   	pop    %ebp
80104d12:	c3                   	ret

80104d13 <stosl>:
{
80104d13:	55                   	push   %ebp
80104d14:	89 e5                	mov    %esp,%ebp
80104d16:	57                   	push   %edi
80104d17:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d1b:	8b 55 10             	mov    0x10(%ebp),%edx
80104d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d21:	89 cb                	mov    %ecx,%ebx
80104d23:	89 df                	mov    %ebx,%edi
80104d25:	89 d1                	mov    %edx,%ecx
80104d27:	fc                   	cld
80104d28:	f3 ab                	rep stos %eax,%es:(%edi)
80104d2a:	89 ca                	mov    %ecx,%edx
80104d2c:	89 fb                	mov    %edi,%ebx
80104d2e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d31:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d34:	90                   	nop
80104d35:	5b                   	pop    %ebx
80104d36:	5f                   	pop    %edi
80104d37:	5d                   	pop    %ebp
80104d38:	c3                   	ret

80104d39 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d39:	f3 0f 1e fb          	endbr32
80104d3d:	55                   	push   %ebp
80104d3e:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d40:	8b 45 08             	mov    0x8(%ebp),%eax
80104d43:	83 e0 03             	and    $0x3,%eax
80104d46:	85 c0                	test   %eax,%eax
80104d48:	75 43                	jne    80104d8d <memset+0x54>
80104d4a:	8b 45 10             	mov    0x10(%ebp),%eax
80104d4d:	83 e0 03             	and    $0x3,%eax
80104d50:	85 c0                	test   %eax,%eax
80104d52:	75 39                	jne    80104d8d <memset+0x54>
    c &= 0xFF;
80104d54:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104d5e:	c1 e8 02             	shr    $0x2,%eax
80104d61:	89 c1                	mov    %eax,%ecx
80104d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d66:	c1 e0 18             	shl    $0x18,%eax
80104d69:	89 c2                	mov    %eax,%edx
80104d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6e:	c1 e0 10             	shl    $0x10,%eax
80104d71:	09 c2                	or     %eax,%edx
80104d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d76:	c1 e0 08             	shl    $0x8,%eax
80104d79:	09 d0                	or     %edx,%eax
80104d7b:	0b 45 0c             	or     0xc(%ebp),%eax
80104d7e:	51                   	push   %ecx
80104d7f:	50                   	push   %eax
80104d80:	ff 75 08             	push   0x8(%ebp)
80104d83:	e8 8b ff ff ff       	call   80104d13 <stosl>
80104d88:	83 c4 0c             	add    $0xc,%esp
80104d8b:	eb 12                	jmp    80104d9f <memset+0x66>
  } else
    stosb(dst, c, n);
80104d8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104d90:	50                   	push   %eax
80104d91:	ff 75 0c             	push   0xc(%ebp)
80104d94:	ff 75 08             	push   0x8(%ebp)
80104d97:	e8 51 ff ff ff       	call   80104ced <stosb>
80104d9c:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104da2:	c9                   	leave
80104da3:	c3                   	ret

80104da4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104da4:	f3 0f 1e fb          	endbr32
80104da8:	55                   	push   %ebp
80104da9:	89 e5                	mov    %esp,%ebp
80104dab:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104dae:	8b 45 08             	mov    0x8(%ebp),%eax
80104db1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dba:	eb 30                	jmp    80104dec <memcmp+0x48>
    if(*s1 != *s2)
80104dbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbf:	0f b6 10             	movzbl (%eax),%edx
80104dc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dc5:	0f b6 00             	movzbl (%eax),%eax
80104dc8:	38 c2                	cmp    %al,%dl
80104dca:	74 18                	je     80104de4 <memcmp+0x40>
      return *s1 - *s2;
80104dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dcf:	0f b6 00             	movzbl (%eax),%eax
80104dd2:	0f b6 d0             	movzbl %al,%edx
80104dd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dd8:	0f b6 00             	movzbl (%eax),%eax
80104ddb:	0f b6 c0             	movzbl %al,%eax
80104dde:	29 c2                	sub    %eax,%edx
80104de0:	89 d0                	mov    %edx,%eax
80104de2:	eb 1a                	jmp    80104dfe <memcmp+0x5a>
    s1++, s2++;
80104de4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104de8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104dec:	8b 45 10             	mov    0x10(%ebp),%eax
80104def:	8d 50 ff             	lea    -0x1(%eax),%edx
80104df2:	89 55 10             	mov    %edx,0x10(%ebp)
80104df5:	85 c0                	test   %eax,%eax
80104df7:	75 c3                	jne    80104dbc <memcmp+0x18>
  }

  return 0;
80104df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dfe:	c9                   	leave
80104dff:	c3                   	ret

80104e00 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e00:	f3 0f 1e fb          	endbr32
80104e04:	55                   	push   %ebp
80104e05:	89 e5                	mov    %esp,%ebp
80104e07:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e10:	8b 45 08             	mov    0x8(%ebp),%eax
80104e13:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e19:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e1c:	73 54                	jae    80104e72 <memmove+0x72>
80104e1e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e21:	8b 45 10             	mov    0x10(%ebp),%eax
80104e24:	01 d0                	add    %edx,%eax
80104e26:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e29:	73 47                	jae    80104e72 <memmove+0x72>
    s += n;
80104e2b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e2e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e31:	8b 45 10             	mov    0x10(%ebp),%eax
80104e34:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e37:	eb 13                	jmp    80104e4c <memmove+0x4c>
      *--d = *--s;
80104e39:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e3d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e44:	0f b6 10             	movzbl (%eax),%edx
80104e47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e4c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e4f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e52:	89 55 10             	mov    %edx,0x10(%ebp)
80104e55:	85 c0                	test   %eax,%eax
80104e57:	75 e0                	jne    80104e39 <memmove+0x39>
  if(s < d && s + n > d){
80104e59:	eb 24                	jmp    80104e7f <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e5e:	8d 42 01             	lea    0x1(%edx),%eax
80104e61:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e64:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e67:	8d 48 01             	lea    0x1(%eax),%ecx
80104e6a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e6d:	0f b6 12             	movzbl (%edx),%edx
80104e70:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e72:	8b 45 10             	mov    0x10(%ebp),%eax
80104e75:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e78:	89 55 10             	mov    %edx,0x10(%ebp)
80104e7b:	85 c0                	test   %eax,%eax
80104e7d:	75 dc                	jne    80104e5b <memmove+0x5b>

  return dst;
80104e7f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e82:	c9                   	leave
80104e83:	c3                   	ret

80104e84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e84:	f3 0f 1e fb          	endbr32
80104e88:	55                   	push   %ebp
80104e89:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e8b:	ff 75 10             	push   0x10(%ebp)
80104e8e:	ff 75 0c             	push   0xc(%ebp)
80104e91:	ff 75 08             	push   0x8(%ebp)
80104e94:	e8 67 ff ff ff       	call   80104e00 <memmove>
80104e99:	83 c4 0c             	add    $0xc,%esp
}
80104e9c:	c9                   	leave
80104e9d:	c3                   	ret

80104e9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e9e:	f3 0f 1e fb          	endbr32
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ea5:	eb 0c                	jmp    80104eb3 <strncmp+0x15>
    n--, p++, q++;
80104ea7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104eab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104eaf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104eb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104eb7:	74 1a                	je     80104ed3 <strncmp+0x35>
80104eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebc:	0f b6 00             	movzbl (%eax),%eax
80104ebf:	84 c0                	test   %al,%al
80104ec1:	74 10                	je     80104ed3 <strncmp+0x35>
80104ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec6:	0f b6 10             	movzbl (%eax),%edx
80104ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ecc:	0f b6 00             	movzbl (%eax),%eax
80104ecf:	38 c2                	cmp    %al,%dl
80104ed1:	74 d4                	je     80104ea7 <strncmp+0x9>
  if(n == 0)
80104ed3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ed7:	75 07                	jne    80104ee0 <strncmp+0x42>
    return 0;
80104ed9:	b8 00 00 00 00       	mov    $0x0,%eax
80104ede:	eb 16                	jmp    80104ef6 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee3:	0f b6 00             	movzbl (%eax),%eax
80104ee6:	0f b6 d0             	movzbl %al,%edx
80104ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eec:	0f b6 00             	movzbl (%eax),%eax
80104eef:	0f b6 c0             	movzbl %al,%eax
80104ef2:	29 c2                	sub    %eax,%edx
80104ef4:	89 d0                	mov    %edx,%eax
}
80104ef6:	5d                   	pop    %ebp
80104ef7:	c3                   	ret

80104ef8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104ef8:	f3 0f 1e fb          	endbr32
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f02:	8b 45 08             	mov    0x8(%ebp),%eax
80104f05:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f08:	90                   	nop
80104f09:	8b 45 10             	mov    0x10(%ebp),%eax
80104f0c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f0f:	89 55 10             	mov    %edx,0x10(%ebp)
80104f12:	85 c0                	test   %eax,%eax
80104f14:	7e 2c                	jle    80104f42 <strncpy+0x4a>
80104f16:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f19:	8d 42 01             	lea    0x1(%edx),%eax
80104f1c:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f22:	8d 48 01             	lea    0x1(%eax),%ecx
80104f25:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f28:	0f b6 12             	movzbl (%edx),%edx
80104f2b:	88 10                	mov    %dl,(%eax)
80104f2d:	0f b6 00             	movzbl (%eax),%eax
80104f30:	84 c0                	test   %al,%al
80104f32:	75 d5                	jne    80104f09 <strncpy+0x11>
    ;
  while(n-- > 0)
80104f34:	eb 0c                	jmp    80104f42 <strncpy+0x4a>
    *s++ = 0;
80104f36:	8b 45 08             	mov    0x8(%ebp),%eax
80104f39:	8d 50 01             	lea    0x1(%eax),%edx
80104f3c:	89 55 08             	mov    %edx,0x8(%ebp)
80104f3f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f42:	8b 45 10             	mov    0x10(%ebp),%eax
80104f45:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f48:	89 55 10             	mov    %edx,0x10(%ebp)
80104f4b:	85 c0                	test   %eax,%eax
80104f4d:	7f e7                	jg     80104f36 <strncpy+0x3e>
  return os;
80104f4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f52:	c9                   	leave
80104f53:	c3                   	ret

80104f54 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f54:	f3 0f 1e fb          	endbr32
80104f58:	55                   	push   %ebp
80104f59:	89 e5                	mov    %esp,%ebp
80104f5b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f68:	7f 05                	jg     80104f6f <safestrcpy+0x1b>
    return os;
80104f6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f6d:	eb 31                	jmp    80104fa0 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f6f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f77:	7e 1e                	jle    80104f97 <safestrcpy+0x43>
80104f79:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f7c:	8d 42 01             	lea    0x1(%edx),%eax
80104f7f:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f82:	8b 45 08             	mov    0x8(%ebp),%eax
80104f85:	8d 48 01             	lea    0x1(%eax),%ecx
80104f88:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f8b:	0f b6 12             	movzbl (%edx),%edx
80104f8e:	88 10                	mov    %dl,(%eax)
80104f90:	0f b6 00             	movzbl (%eax),%eax
80104f93:	84 c0                	test   %al,%al
80104f95:	75 d8                	jne    80104f6f <safestrcpy+0x1b>
    ;
  *s = 0;
80104f97:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fa0:	c9                   	leave
80104fa1:	c3                   	ret

80104fa2 <strlen>:

int
strlen(const char *s)
{
80104fa2:	f3 0f 1e fb          	endbr32
80104fa6:	55                   	push   %ebp
80104fa7:	89 e5                	mov    %esp,%ebp
80104fa9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fb3:	eb 04                	jmp    80104fb9 <strlen+0x17>
80104fb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104fb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbf:	01 d0                	add    %edx,%eax
80104fc1:	0f b6 00             	movzbl (%eax),%eax
80104fc4:	84 c0                	test   %al,%al
80104fc6:	75 ed                	jne    80104fb5 <strlen+0x13>
    ;
  return n;
80104fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fcb:	c9                   	leave
80104fcc:	c3                   	ret

80104fcd <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fcd:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104fd1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104fd5:	55                   	push   %ebp
  pushl %ebx
80104fd6:	53                   	push   %ebx
  pushl %esi
80104fd7:	56                   	push   %esi
  pushl %edi
80104fd8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104fd9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104fdb:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104fdd:	5f                   	pop    %edi
  popl %esi
80104fde:	5e                   	pop    %esi
  popl %ebx
80104fdf:	5b                   	pop    %ebx
  popl %ebp
80104fe0:	5d                   	pop    %ebp
  ret
80104fe1:	c3                   	ret

80104fe2 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104fe2:	f3 0f 1e fb          	endbr32
80104fe6:	55                   	push   %ebp
80104fe7:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fec:	85 c0                	test   %eax,%eax
80104fee:	78 0a                	js     80104ffa <fetchint+0x18>
80104ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff3:	83 c0 04             	add    $0x4,%eax
80104ff6:	85 c0                	test   %eax,%eax
80104ff8:	79 07                	jns    80105001 <fetchint+0x1f>
    return -1;
80104ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fff:	eb 0f                	jmp    80105010 <fetchint+0x2e>
  *ip = *(int*)(addr);
80105001:	8b 45 08             	mov    0x8(%ebp),%eax
80105004:	8b 10                	mov    (%eax),%edx
80105006:	8b 45 0c             	mov    0xc(%ebp),%eax
80105009:	89 10                	mov    %edx,(%eax)
  return 0;
8010500b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105010:	5d                   	pop    %ebp
80105011:	c3                   	ret

80105012 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105012:	f3 0f 1e fb          	endbr32
80105016:	55                   	push   %ebp
80105017:	89 e5                	mov    %esp,%ebp
80105019:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
8010501c:	8b 45 08             	mov    0x8(%ebp),%eax
8010501f:	85 c0                	test   %eax,%eax
80105021:	79 07                	jns    8010502a <fetchstr+0x18>
    return -1;
80105023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105028:	eb 42                	jmp    8010506c <fetchstr+0x5a>
  *pp = (char*)addr;
8010502a:	8b 55 08             	mov    0x8(%ebp),%edx
8010502d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105030:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80105032:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503c:	8b 00                	mov    (%eax),%eax
8010503e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105041:	eb 1c                	jmp    8010505f <fetchstr+0x4d>
    if(*s == 0)
80105043:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105046:	0f b6 00             	movzbl (%eax),%eax
80105049:	84 c0                	test   %al,%al
8010504b:	75 0e                	jne    8010505b <fetchstr+0x49>
      return s - *pp;
8010504d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105050:	8b 00                	mov    (%eax),%eax
80105052:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105055:	29 c2                	sub    %eax,%edx
80105057:	89 d0                	mov    %edx,%eax
80105059:	eb 11                	jmp    8010506c <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
8010505b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010505f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105062:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105065:	72 dc                	jb     80105043 <fetchstr+0x31>
  }
  return -1;
80105067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010506c:	c9                   	leave
8010506d:	c3                   	ret

8010506e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010506e:	f3 0f 1e fb          	endbr32
80105072:	55                   	push   %ebp
80105073:	89 e5                	mov    %esp,%ebp
80105075:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105078:	e8 99 eb ff ff       	call   80103c16 <myproc>
8010507d:	8b 40 18             	mov    0x18(%eax),%eax
80105080:	8b 40 44             	mov    0x44(%eax),%eax
80105083:	8b 55 08             	mov    0x8(%ebp),%edx
80105086:	c1 e2 02             	shl    $0x2,%edx
80105089:	01 d0                	add    %edx,%eax
8010508b:	83 c0 04             	add    $0x4,%eax
8010508e:	83 ec 08             	sub    $0x8,%esp
80105091:	ff 75 0c             	push   0xc(%ebp)
80105094:	50                   	push   %eax
80105095:	e8 48 ff ff ff       	call   80104fe2 <fetchint>
8010509a:	83 c4 10             	add    $0x10,%esp
}
8010509d:	c9                   	leave
8010509e:	c3                   	ret

8010509f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010509f:	f3 0f 1e fb          	endbr32
801050a3:	55                   	push   %ebp
801050a4:	89 e5                	mov    %esp,%ebp
801050a6:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801050a9:	83 ec 08             	sub    $0x8,%esp
801050ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050af:	50                   	push   %eax
801050b0:	ff 75 08             	push   0x8(%ebp)
801050b3:	e8 b6 ff ff ff       	call   8010506e <argint>
801050b8:	83 c4 10             	add    $0x10,%esp
801050bb:	85 c0                	test   %eax,%eax
801050bd:	79 07                	jns    801050c6 <argptr+0x27>
    return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	eb 34                	jmp    801050fa <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801050c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050ca:	78 18                	js     801050e4 <argptr+0x45>
801050cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cf:	85 c0                	test   %eax,%eax
801050d1:	78 11                	js     801050e4 <argptr+0x45>
801050d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d6:	89 c2                	mov    %eax,%edx
801050d8:	8b 45 10             	mov    0x10(%ebp),%eax
801050db:	01 d0                	add    %edx,%eax
801050dd:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801050e2:	76 07                	jbe    801050eb <argptr+0x4c>
    return -1;
801050e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e9:	eb 0f                	jmp    801050fa <argptr+0x5b>
  *pp = (char*)i;
801050eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ee:	89 c2                	mov    %eax,%edx
801050f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f3:	89 10                	mov    %edx,(%eax)
  return 0;
801050f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050fa:	c9                   	leave
801050fb:	c3                   	ret

801050fc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801050fc:	f3 0f 1e fb          	endbr32
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105106:	83 ec 08             	sub    $0x8,%esp
80105109:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010510c:	50                   	push   %eax
8010510d:	ff 75 08             	push   0x8(%ebp)
80105110:	e8 59 ff ff ff       	call   8010506e <argint>
80105115:	83 c4 10             	add    $0x10,%esp
80105118:	85 c0                	test   %eax,%eax
8010511a:	79 07                	jns    80105123 <argstr+0x27>
    return -1;
8010511c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105121:	eb 12                	jmp    80105135 <argstr+0x39>
  return fetchstr(addr, pp);
80105123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105126:	83 ec 08             	sub    $0x8,%esp
80105129:	ff 75 0c             	push   0xc(%ebp)
8010512c:	50                   	push   %eax
8010512d:	e8 e0 fe ff ff       	call   80105012 <fetchstr>
80105132:	83 c4 10             	add    $0x10,%esp
}
80105135:	c9                   	leave
80105136:	c3                   	ret

80105137 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105137:	f3 0f 1e fb          	endbr32
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105141:	e8 d0 ea ff ff       	call   80103c16 <myproc>
80105146:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514c:	8b 40 18             	mov    0x18(%eax),%eax
8010514f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105152:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105155:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105159:	7e 2f                	jle    8010518a <syscall+0x53>
8010515b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515e:	83 f8 17             	cmp    $0x17,%eax
80105161:	77 27                	ja     8010518a <syscall+0x53>
80105163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105166:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010516d:	85 c0                	test   %eax,%eax
8010516f:	74 19                	je     8010518a <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105174:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010517b:	ff d0                	call   *%eax
8010517d:	89 c2                	mov    %eax,%edx
8010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105182:	8b 40 18             	mov    0x18(%eax),%eax
80105185:	89 50 1c             	mov    %edx,0x1c(%eax)
80105188:	eb 2c                	jmp    801051b6 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105193:	8b 40 10             	mov    0x10(%eax),%eax
80105196:	ff 75 f0             	push   -0x10(%ebp)
80105199:	52                   	push   %edx
8010519a:	50                   	push   %eax
8010519b:	68 3a ac 10 80       	push   $0x8010ac3a
801051a0:	e8 67 b2 ff ff       	call   8010040c <cprintf>
801051a5:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ab:	8b 40 18             	mov    0x18(%eax),%eax
801051ae:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051b5:	90                   	nop
801051b6:	90                   	nop
801051b7:	c9                   	leave
801051b8:	c3                   	ret

801051b9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051b9:	f3 0f 1e fb          	endbr32
801051bd:	55                   	push   %ebp
801051be:	89 e5                	mov    %esp,%ebp
801051c0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051c3:	83 ec 08             	sub    $0x8,%esp
801051c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051c9:	50                   	push   %eax
801051ca:	ff 75 08             	push   0x8(%ebp)
801051cd:	e8 9c fe ff ff       	call   8010506e <argint>
801051d2:	83 c4 10             	add    $0x10,%esp
801051d5:	85 c0                	test   %eax,%eax
801051d7:	79 07                	jns    801051e0 <argfd+0x27>
    return -1;
801051d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051de:	eb 4f                	jmp    8010522f <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e3:	85 c0                	test   %eax,%eax
801051e5:	78 20                	js     80105207 <argfd+0x4e>
801051e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ea:	83 f8 0f             	cmp    $0xf,%eax
801051ed:	7f 18                	jg     80105207 <argfd+0x4e>
801051ef:	e8 22 ea ff ff       	call   80103c16 <myproc>
801051f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051f7:	83 c2 08             	add    $0x8,%edx
801051fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105201:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105205:	75 07                	jne    8010520e <argfd+0x55>
    return -1;
80105207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520c:	eb 21                	jmp    8010522f <argfd+0x76>
  if(pfd)
8010520e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105212:	74 08                	je     8010521c <argfd+0x63>
    *pfd = fd;
80105214:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105217:	8b 45 0c             	mov    0xc(%ebp),%eax
8010521a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010521c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105220:	74 08                	je     8010522a <argfd+0x71>
    *pf = f;
80105222:	8b 45 10             	mov    0x10(%ebp),%eax
80105225:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105228:	89 10                	mov    %edx,(%eax)
  return 0;
8010522a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010522f:	c9                   	leave
80105230:	c3                   	ret

80105231 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105231:	f3 0f 1e fb          	endbr32
80105235:	55                   	push   %ebp
80105236:	89 e5                	mov    %esp,%ebp
80105238:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010523b:	e8 d6 e9 ff ff       	call   80103c16 <myproc>
80105240:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105243:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010524a:	eb 2a                	jmp    80105276 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010524c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105252:	83 c2 08             	add    $0x8,%edx
80105255:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105259:	85 c0                	test   %eax,%eax
8010525b:	75 15                	jne    80105272 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010525d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105260:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105263:	8d 4a 08             	lea    0x8(%edx),%ecx
80105266:	8b 55 08             	mov    0x8(%ebp),%edx
80105269:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010526d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105270:	eb 0f                	jmp    80105281 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105272:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105276:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010527a:	7e d0                	jle    8010524c <fdalloc+0x1b>
    }
  }
  return -1;
8010527c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105281:	c9                   	leave
80105282:	c3                   	ret

80105283 <sys_dup>:

int
sys_dup(void)
{
80105283:	f3 0f 1e fb          	endbr32
80105287:	55                   	push   %ebp
80105288:	89 e5                	mov    %esp,%ebp
8010528a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010528d:	83 ec 04             	sub    $0x4,%esp
80105290:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105293:	50                   	push   %eax
80105294:	6a 00                	push   $0x0
80105296:	6a 00                	push   $0x0
80105298:	e8 1c ff ff ff       	call   801051b9 <argfd>
8010529d:	83 c4 10             	add    $0x10,%esp
801052a0:	85 c0                	test   %eax,%eax
801052a2:	79 07                	jns    801052ab <sys_dup+0x28>
    return -1;
801052a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a9:	eb 31                	jmp    801052dc <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801052ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ae:	83 ec 0c             	sub    $0xc,%esp
801052b1:	50                   	push   %eax
801052b2:	e8 7a ff ff ff       	call   80105231 <fdalloc>
801052b7:	83 c4 10             	add    $0x10,%esp
801052ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052c1:	79 07                	jns    801052ca <sys_dup+0x47>
    return -1;
801052c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c8:	eb 12                	jmp    801052dc <sys_dup+0x59>
  filedup(f);
801052ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052cd:	83 ec 0c             	sub    $0xc,%esp
801052d0:	50                   	push   %eax
801052d1:	e8 2b be ff ff       	call   80101101 <filedup>
801052d6:	83 c4 10             	add    $0x10,%esp
  return fd;
801052d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052dc:	c9                   	leave
801052dd:	c3                   	ret

801052de <sys_read>:

int
sys_read(void)
{
801052de:	f3 0f 1e fb          	endbr32
801052e2:	55                   	push   %ebp
801052e3:	89 e5                	mov    %esp,%ebp
801052e5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052e8:	83 ec 04             	sub    $0x4,%esp
801052eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052ee:	50                   	push   %eax
801052ef:	6a 00                	push   $0x0
801052f1:	6a 00                	push   $0x0
801052f3:	e8 c1 fe ff ff       	call   801051b9 <argfd>
801052f8:	83 c4 10             	add    $0x10,%esp
801052fb:	85 c0                	test   %eax,%eax
801052fd:	78 2e                	js     8010532d <sys_read+0x4f>
801052ff:	83 ec 08             	sub    $0x8,%esp
80105302:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105305:	50                   	push   %eax
80105306:	6a 02                	push   $0x2
80105308:	e8 61 fd ff ff       	call   8010506e <argint>
8010530d:	83 c4 10             	add    $0x10,%esp
80105310:	85 c0                	test   %eax,%eax
80105312:	78 19                	js     8010532d <sys_read+0x4f>
80105314:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105317:	83 ec 04             	sub    $0x4,%esp
8010531a:	50                   	push   %eax
8010531b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010531e:	50                   	push   %eax
8010531f:	6a 01                	push   $0x1
80105321:	e8 79 fd ff ff       	call   8010509f <argptr>
80105326:	83 c4 10             	add    $0x10,%esp
80105329:	85 c0                	test   %eax,%eax
8010532b:	79 07                	jns    80105334 <sys_read+0x56>
    return -1;
8010532d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105332:	eb 17                	jmp    8010534b <sys_read+0x6d>
  return fileread(f, p, n);
80105334:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105337:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010533a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533d:	83 ec 04             	sub    $0x4,%esp
80105340:	51                   	push   %ecx
80105341:	52                   	push   %edx
80105342:	50                   	push   %eax
80105343:	e8 55 bf ff ff       	call   8010129d <fileread>
80105348:	83 c4 10             	add    $0x10,%esp
}
8010534b:	c9                   	leave
8010534c:	c3                   	ret

8010534d <sys_write>:

int
sys_write(void)
{
8010534d:	f3 0f 1e fb          	endbr32
80105351:	55                   	push   %ebp
80105352:	89 e5                	mov    %esp,%ebp
80105354:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105357:	83 ec 04             	sub    $0x4,%esp
8010535a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010535d:	50                   	push   %eax
8010535e:	6a 00                	push   $0x0
80105360:	6a 00                	push   $0x0
80105362:	e8 52 fe ff ff       	call   801051b9 <argfd>
80105367:	83 c4 10             	add    $0x10,%esp
8010536a:	85 c0                	test   %eax,%eax
8010536c:	78 2e                	js     8010539c <sys_write+0x4f>
8010536e:	83 ec 08             	sub    $0x8,%esp
80105371:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105374:	50                   	push   %eax
80105375:	6a 02                	push   $0x2
80105377:	e8 f2 fc ff ff       	call   8010506e <argint>
8010537c:	83 c4 10             	add    $0x10,%esp
8010537f:	85 c0                	test   %eax,%eax
80105381:	78 19                	js     8010539c <sys_write+0x4f>
80105383:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105386:	83 ec 04             	sub    $0x4,%esp
80105389:	50                   	push   %eax
8010538a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010538d:	50                   	push   %eax
8010538e:	6a 01                	push   $0x1
80105390:	e8 0a fd ff ff       	call   8010509f <argptr>
80105395:	83 c4 10             	add    $0x10,%esp
80105398:	85 c0                	test   %eax,%eax
8010539a:	79 07                	jns    801053a3 <sys_write+0x56>
    return -1;
8010539c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a1:	eb 17                	jmp    801053ba <sys_write+0x6d>
  return filewrite(f, p, n);
801053a3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ac:	83 ec 04             	sub    $0x4,%esp
801053af:	51                   	push   %ecx
801053b0:	52                   	push   %edx
801053b1:	50                   	push   %eax
801053b2:	e8 a2 bf ff ff       	call   80101359 <filewrite>
801053b7:	83 c4 10             	add    $0x10,%esp
}
801053ba:	c9                   	leave
801053bb:	c3                   	ret

801053bc <sys_close>:

int
sys_close(void)
{
801053bc:	f3 0f 1e fb          	endbr32
801053c0:	55                   	push   %ebp
801053c1:	89 e5                	mov    %esp,%ebp
801053c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053c6:	83 ec 04             	sub    $0x4,%esp
801053c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053cc:	50                   	push   %eax
801053cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d0:	50                   	push   %eax
801053d1:	6a 00                	push   $0x0
801053d3:	e8 e1 fd ff ff       	call   801051b9 <argfd>
801053d8:	83 c4 10             	add    $0x10,%esp
801053db:	85 c0                	test   %eax,%eax
801053dd:	79 07                	jns    801053e6 <sys_close+0x2a>
    return -1;
801053df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e4:	eb 27                	jmp    8010540d <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801053e6:	e8 2b e8 ff ff       	call   80103c16 <myproc>
801053eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053ee:	83 c2 08             	add    $0x8,%edx
801053f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801053f8:	00 
  fileclose(f);
801053f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fc:	83 ec 0c             	sub    $0xc,%esp
801053ff:	50                   	push   %eax
80105400:	e8 51 bd ff ff       	call   80101156 <fileclose>
80105405:	83 c4 10             	add    $0x10,%esp
  return 0;
80105408:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010540d:	c9                   	leave
8010540e:	c3                   	ret

8010540f <sys_fstat>:

int
sys_fstat(void)
{
8010540f:	f3 0f 1e fb          	endbr32
80105413:	55                   	push   %ebp
80105414:	89 e5                	mov    %esp,%ebp
80105416:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105419:	83 ec 04             	sub    $0x4,%esp
8010541c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010541f:	50                   	push   %eax
80105420:	6a 00                	push   $0x0
80105422:	6a 00                	push   $0x0
80105424:	e8 90 fd ff ff       	call   801051b9 <argfd>
80105429:	83 c4 10             	add    $0x10,%esp
8010542c:	85 c0                	test   %eax,%eax
8010542e:	78 17                	js     80105447 <sys_fstat+0x38>
80105430:	83 ec 04             	sub    $0x4,%esp
80105433:	6a 14                	push   $0x14
80105435:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105438:	50                   	push   %eax
80105439:	6a 01                	push   $0x1
8010543b:	e8 5f fc ff ff       	call   8010509f <argptr>
80105440:	83 c4 10             	add    $0x10,%esp
80105443:	85 c0                	test   %eax,%eax
80105445:	79 07                	jns    8010544e <sys_fstat+0x3f>
    return -1;
80105447:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010544c:	eb 13                	jmp    80105461 <sys_fstat+0x52>
  return filestat(f, st);
8010544e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105454:	83 ec 08             	sub    $0x8,%esp
80105457:	52                   	push   %edx
80105458:	50                   	push   %eax
80105459:	e8 e4 bd ff ff       	call   80101242 <filestat>
8010545e:	83 c4 10             	add    $0x10,%esp
}
80105461:	c9                   	leave
80105462:	c3                   	ret

80105463 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105463:	f3 0f 1e fb          	endbr32
80105467:	55                   	push   %ebp
80105468:	89 e5                	mov    %esp,%ebp
8010546a:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010546d:	83 ec 08             	sub    $0x8,%esp
80105470:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105473:	50                   	push   %eax
80105474:	6a 00                	push   $0x0
80105476:	e8 81 fc ff ff       	call   801050fc <argstr>
8010547b:	83 c4 10             	add    $0x10,%esp
8010547e:	85 c0                	test   %eax,%eax
80105480:	78 15                	js     80105497 <sys_link+0x34>
80105482:	83 ec 08             	sub    $0x8,%esp
80105485:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105488:	50                   	push   %eax
80105489:	6a 01                	push   $0x1
8010548b:	e8 6c fc ff ff       	call   801050fc <argstr>
80105490:	83 c4 10             	add    $0x10,%esp
80105493:	85 c0                	test   %eax,%eax
80105495:	79 0a                	jns    801054a1 <sys_link+0x3e>
    return -1;
80105497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549c:	e9 68 01 00 00       	jmp    80105609 <sys_link+0x1a6>

  begin_op();
801054a1:	e8 38 dd ff ff       	call   801031de <begin_op>
  if((ip = namei(old)) == 0){
801054a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054a9:	83 ec 0c             	sub    $0xc,%esp
801054ac:	50                   	push   %eax
801054ad:	e8 a2 d1 ff ff       	call   80102654 <namei>
801054b2:	83 c4 10             	add    $0x10,%esp
801054b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054bc:	75 0f                	jne    801054cd <sys_link+0x6a>
    end_op();
801054be:	e8 ab dd ff ff       	call   8010326e <end_op>
    return -1;
801054c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c8:	e9 3c 01 00 00       	jmp    80105609 <sys_link+0x1a6>
  }

  ilock(ip);
801054cd:	83 ec 0c             	sub    $0xc,%esp
801054d0:	ff 75 f4             	push   -0xc(%ebp)
801054d3:	e8 11 c6 ff ff       	call   80101ae9 <ilock>
801054d8:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801054db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054de:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054e2:	66 83 f8 01          	cmp    $0x1,%ax
801054e6:	75 1d                	jne    80105505 <sys_link+0xa2>
    iunlockput(ip);
801054e8:	83 ec 0c             	sub    $0xc,%esp
801054eb:	ff 75 f4             	push   -0xc(%ebp)
801054ee:	e8 33 c8 ff ff       	call   80101d26 <iunlockput>
801054f3:	83 c4 10             	add    $0x10,%esp
    end_op();
801054f6:	e8 73 dd ff ff       	call   8010326e <end_op>
    return -1;
801054fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105500:	e9 04 01 00 00       	jmp    80105609 <sys_link+0x1a6>
  }

  ip->nlink++;
80105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105508:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010550c:	83 c0 01             	add    $0x1,%eax
8010550f:	89 c2                	mov    %eax,%edx
80105511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105514:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105518:	83 ec 0c             	sub    $0xc,%esp
8010551b:	ff 75 f4             	push   -0xc(%ebp)
8010551e:	e8 dd c3 ff ff       	call   80101900 <iupdate>
80105523:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105526:	83 ec 0c             	sub    $0xc,%esp
80105529:	ff 75 f4             	push   -0xc(%ebp)
8010552c:	e8 cf c6 ff ff       	call   80101c00 <iunlock>
80105531:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105534:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105537:	83 ec 08             	sub    $0x8,%esp
8010553a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010553d:	52                   	push   %edx
8010553e:	50                   	push   %eax
8010553f:	e8 30 d1 ff ff       	call   80102674 <nameiparent>
80105544:	83 c4 10             	add    $0x10,%esp
80105547:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010554a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010554e:	74 71                	je     801055c1 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105550:	83 ec 0c             	sub    $0xc,%esp
80105553:	ff 75 f0             	push   -0x10(%ebp)
80105556:	e8 8e c5 ff ff       	call   80101ae9 <ilock>
8010555b:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010555e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105561:	8b 10                	mov    (%eax),%edx
80105563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105566:	8b 00                	mov    (%eax),%eax
80105568:	39 c2                	cmp    %eax,%edx
8010556a:	75 1d                	jne    80105589 <sys_link+0x126>
8010556c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010556f:	8b 40 04             	mov    0x4(%eax),%eax
80105572:	83 ec 04             	sub    $0x4,%esp
80105575:	50                   	push   %eax
80105576:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105579:	50                   	push   %eax
8010557a:	ff 75 f0             	push   -0x10(%ebp)
8010557d:	e8 2f ce ff ff       	call   801023b1 <dirlink>
80105582:	83 c4 10             	add    $0x10,%esp
80105585:	85 c0                	test   %eax,%eax
80105587:	79 10                	jns    80105599 <sys_link+0x136>
    iunlockput(dp);
80105589:	83 ec 0c             	sub    $0xc,%esp
8010558c:	ff 75 f0             	push   -0x10(%ebp)
8010558f:	e8 92 c7 ff ff       	call   80101d26 <iunlockput>
80105594:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105597:	eb 29                	jmp    801055c2 <sys_link+0x15f>
  }
  iunlockput(dp);
80105599:	83 ec 0c             	sub    $0xc,%esp
8010559c:	ff 75 f0             	push   -0x10(%ebp)
8010559f:	e8 82 c7 ff ff       	call   80101d26 <iunlockput>
801055a4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	ff 75 f4             	push   -0xc(%ebp)
801055ad:	e8 a0 c6 ff ff       	call   80101c52 <iput>
801055b2:	83 c4 10             	add    $0x10,%esp

  end_op();
801055b5:	e8 b4 dc ff ff       	call   8010326e <end_op>

  return 0;
801055ba:	b8 00 00 00 00       	mov    $0x0,%eax
801055bf:	eb 48                	jmp    80105609 <sys_link+0x1a6>
    goto bad;
801055c1:	90                   	nop

bad:
  ilock(ip);
801055c2:	83 ec 0c             	sub    $0xc,%esp
801055c5:	ff 75 f4             	push   -0xc(%ebp)
801055c8:	e8 1c c5 ff ff       	call   80101ae9 <ilock>
801055cd:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801055d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055d7:	83 e8 01             	sub    $0x1,%eax
801055da:	89 c2                	mov    %eax,%edx
801055dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055df:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055e3:	83 ec 0c             	sub    $0xc,%esp
801055e6:	ff 75 f4             	push   -0xc(%ebp)
801055e9:	e8 12 c3 ff ff       	call   80101900 <iupdate>
801055ee:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801055f1:	83 ec 0c             	sub    $0xc,%esp
801055f4:	ff 75 f4             	push   -0xc(%ebp)
801055f7:	e8 2a c7 ff ff       	call   80101d26 <iunlockput>
801055fc:	83 c4 10             	add    $0x10,%esp
  end_op();
801055ff:	e8 6a dc ff ff       	call   8010326e <end_op>
  return -1;
80105604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105609:	c9                   	leave
8010560a:	c3                   	ret

8010560b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010560b:	f3 0f 1e fb          	endbr32
8010560f:	55                   	push   %ebp
80105610:	89 e5                	mov    %esp,%ebp
80105612:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105615:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010561c:	eb 40                	jmp    8010565e <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105621:	6a 10                	push   $0x10
80105623:	50                   	push   %eax
80105624:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105627:	50                   	push   %eax
80105628:	ff 75 08             	push   0x8(%ebp)
8010562b:	e8 c1 c9 ff ff       	call   80101ff1 <readi>
80105630:	83 c4 10             	add    $0x10,%esp
80105633:	83 f8 10             	cmp    $0x10,%eax
80105636:	74 0d                	je     80105645 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105638:	83 ec 0c             	sub    $0xc,%esp
8010563b:	68 56 ac 10 80       	push   $0x8010ac56
80105640:	e8 99 af ff ff       	call   801005de <panic>
    if(de.inum != 0)
80105645:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105649:	66 85 c0             	test   %ax,%ax
8010564c:	74 07                	je     80105655 <isdirempty+0x4a>
      return 0;
8010564e:	b8 00 00 00 00       	mov    $0x0,%eax
80105653:	eb 1b                	jmp    80105670 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105658:	83 c0 10             	add    $0x10,%eax
8010565b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010565e:	8b 45 08             	mov    0x8(%ebp),%eax
80105661:	8b 50 58             	mov    0x58(%eax),%edx
80105664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105667:	39 c2                	cmp    %eax,%edx
80105669:	77 b3                	ja     8010561e <isdirempty+0x13>
  }
  return 1;
8010566b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105670:	c9                   	leave
80105671:	c3                   	ret

80105672 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105672:	f3 0f 1e fb          	endbr32
80105676:	55                   	push   %ebp
80105677:	89 e5                	mov    %esp,%ebp
80105679:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010567c:	83 ec 08             	sub    $0x8,%esp
8010567f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105682:	50                   	push   %eax
80105683:	6a 00                	push   $0x0
80105685:	e8 72 fa ff ff       	call   801050fc <argstr>
8010568a:	83 c4 10             	add    $0x10,%esp
8010568d:	85 c0                	test   %eax,%eax
8010568f:	79 0a                	jns    8010569b <sys_unlink+0x29>
    return -1;
80105691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105696:	e9 bf 01 00 00       	jmp    8010585a <sys_unlink+0x1e8>

  begin_op();
8010569b:	e8 3e db ff ff       	call   801031de <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056a3:	83 ec 08             	sub    $0x8,%esp
801056a6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056a9:	52                   	push   %edx
801056aa:	50                   	push   %eax
801056ab:	e8 c4 cf ff ff       	call   80102674 <nameiparent>
801056b0:	83 c4 10             	add    $0x10,%esp
801056b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ba:	75 0f                	jne    801056cb <sys_unlink+0x59>
    end_op();
801056bc:	e8 ad db ff ff       	call   8010326e <end_op>
    return -1;
801056c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c6:	e9 8f 01 00 00       	jmp    8010585a <sys_unlink+0x1e8>
  }

  ilock(dp);
801056cb:	83 ec 0c             	sub    $0xc,%esp
801056ce:	ff 75 f4             	push   -0xc(%ebp)
801056d1:	e8 13 c4 ff ff       	call   80101ae9 <ilock>
801056d6:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056d9:	83 ec 08             	sub    $0x8,%esp
801056dc:	68 68 ac 10 80       	push   $0x8010ac68
801056e1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056e4:	50                   	push   %eax
801056e5:	e8 ea cb ff ff       	call   801022d4 <namecmp>
801056ea:	83 c4 10             	add    $0x10,%esp
801056ed:	85 c0                	test   %eax,%eax
801056ef:	0f 84 49 01 00 00    	je     8010583e <sys_unlink+0x1cc>
801056f5:	83 ec 08             	sub    $0x8,%esp
801056f8:	68 6a ac 10 80       	push   $0x8010ac6a
801056fd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105700:	50                   	push   %eax
80105701:	e8 ce cb ff ff       	call   801022d4 <namecmp>
80105706:	83 c4 10             	add    $0x10,%esp
80105709:	85 c0                	test   %eax,%eax
8010570b:	0f 84 2d 01 00 00    	je     8010583e <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105711:	83 ec 04             	sub    $0x4,%esp
80105714:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105717:	50                   	push   %eax
80105718:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010571b:	50                   	push   %eax
8010571c:	ff 75 f4             	push   -0xc(%ebp)
8010571f:	e8 cf cb ff ff       	call   801022f3 <dirlookup>
80105724:	83 c4 10             	add    $0x10,%esp
80105727:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010572a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010572e:	0f 84 0d 01 00 00    	je     80105841 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	ff 75 f0             	push   -0x10(%ebp)
8010573a:	e8 aa c3 ff ff       	call   80101ae9 <ilock>
8010573f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105745:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105749:	66 85 c0             	test   %ax,%ax
8010574c:	7f 0d                	jg     8010575b <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010574e:	83 ec 0c             	sub    $0xc,%esp
80105751:	68 6d ac 10 80       	push   $0x8010ac6d
80105756:	e8 83 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010575b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105762:	66 83 f8 01          	cmp    $0x1,%ax
80105766:	75 25                	jne    8010578d <sys_unlink+0x11b>
80105768:	83 ec 0c             	sub    $0xc,%esp
8010576b:	ff 75 f0             	push   -0x10(%ebp)
8010576e:	e8 98 fe ff ff       	call   8010560b <isdirempty>
80105773:	83 c4 10             	add    $0x10,%esp
80105776:	85 c0                	test   %eax,%eax
80105778:	75 13                	jne    8010578d <sys_unlink+0x11b>
    iunlockput(ip);
8010577a:	83 ec 0c             	sub    $0xc,%esp
8010577d:	ff 75 f0             	push   -0x10(%ebp)
80105780:	e8 a1 c5 ff ff       	call   80101d26 <iunlockput>
80105785:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105788:	e9 b5 00 00 00       	jmp    80105842 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010578d:	83 ec 04             	sub    $0x4,%esp
80105790:	6a 10                	push   $0x10
80105792:	6a 00                	push   $0x0
80105794:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105797:	50                   	push   %eax
80105798:	e8 9c f5 ff ff       	call   80104d39 <memset>
8010579d:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057a3:	6a 10                	push   $0x10
801057a5:	50                   	push   %eax
801057a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057a9:	50                   	push   %eax
801057aa:	ff 75 f4             	push   -0xc(%ebp)
801057ad:	e8 98 c9 ff ff       	call   8010214a <writei>
801057b2:	83 c4 10             	add    $0x10,%esp
801057b5:	83 f8 10             	cmp    $0x10,%eax
801057b8:	74 0d                	je     801057c7 <sys_unlink+0x155>
    panic("unlink: writei");
801057ba:	83 ec 0c             	sub    $0xc,%esp
801057bd:	68 7f ac 10 80       	push   $0x8010ac7f
801057c2:	e8 17 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
801057c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ca:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057ce:	66 83 f8 01          	cmp    $0x1,%ax
801057d2:	75 21                	jne    801057f5 <sys_unlink+0x183>
    dp->nlink--;
801057d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057db:	83 e8 01             	sub    $0x1,%eax
801057de:	89 c2                	mov    %eax,%edx
801057e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057e7:	83 ec 0c             	sub    $0xc,%esp
801057ea:	ff 75 f4             	push   -0xc(%ebp)
801057ed:	e8 0e c1 ff ff       	call   80101900 <iupdate>
801057f2:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801057f5:	83 ec 0c             	sub    $0xc,%esp
801057f8:	ff 75 f4             	push   -0xc(%ebp)
801057fb:	e8 26 c5 ff ff       	call   80101d26 <iunlockput>
80105800:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105806:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010580a:	83 e8 01             	sub    $0x1,%eax
8010580d:	89 c2                	mov    %eax,%edx
8010580f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105812:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	ff 75 f0             	push   -0x10(%ebp)
8010581c:	e8 df c0 ff ff       	call   80101900 <iupdate>
80105821:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105824:	83 ec 0c             	sub    $0xc,%esp
80105827:	ff 75 f0             	push   -0x10(%ebp)
8010582a:	e8 f7 c4 ff ff       	call   80101d26 <iunlockput>
8010582f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105832:	e8 37 da ff ff       	call   8010326e <end_op>

  return 0;
80105837:	b8 00 00 00 00       	mov    $0x0,%eax
8010583c:	eb 1c                	jmp    8010585a <sys_unlink+0x1e8>
    goto bad;
8010583e:	90                   	nop
8010583f:	eb 01                	jmp    80105842 <sys_unlink+0x1d0>
    goto bad;
80105841:	90                   	nop

bad:
  iunlockput(dp);
80105842:	83 ec 0c             	sub    $0xc,%esp
80105845:	ff 75 f4             	push   -0xc(%ebp)
80105848:	e8 d9 c4 ff ff       	call   80101d26 <iunlockput>
8010584d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105850:	e8 19 da ff ff       	call   8010326e <end_op>
  return -1;
80105855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010585a:	c9                   	leave
8010585b:	c3                   	ret

8010585c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010585c:	f3 0f 1e fb          	endbr32
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	83 ec 38             	sub    $0x38,%esp
80105866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105869:	8b 55 10             	mov    0x10(%ebp),%edx
8010586c:	8b 45 14             	mov    0x14(%ebp),%eax
8010586f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105873:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105877:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010587b:	83 ec 08             	sub    $0x8,%esp
8010587e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105881:	50                   	push   %eax
80105882:	ff 75 08             	push   0x8(%ebp)
80105885:	e8 ea cd ff ff       	call   80102674 <nameiparent>
8010588a:	83 c4 10             	add    $0x10,%esp
8010588d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105890:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105894:	75 0a                	jne    801058a0 <create+0x44>
    return 0;
80105896:	b8 00 00 00 00       	mov    $0x0,%eax
8010589b:	e9 90 01 00 00       	jmp    80105a30 <create+0x1d4>
  ilock(dp);
801058a0:	83 ec 0c             	sub    $0xc,%esp
801058a3:	ff 75 f4             	push   -0xc(%ebp)
801058a6:	e8 3e c2 ff ff       	call   80101ae9 <ilock>
801058ab:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058ae:	83 ec 04             	sub    $0x4,%esp
801058b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058b4:	50                   	push   %eax
801058b5:	8d 45 de             	lea    -0x22(%ebp),%eax
801058b8:	50                   	push   %eax
801058b9:	ff 75 f4             	push   -0xc(%ebp)
801058bc:	e8 32 ca ff ff       	call   801022f3 <dirlookup>
801058c1:	83 c4 10             	add    $0x10,%esp
801058c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058cb:	74 50                	je     8010591d <create+0xc1>
    iunlockput(dp);
801058cd:	83 ec 0c             	sub    $0xc,%esp
801058d0:	ff 75 f4             	push   -0xc(%ebp)
801058d3:	e8 4e c4 ff ff       	call   80101d26 <iunlockput>
801058d8:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	ff 75 f0             	push   -0x10(%ebp)
801058e1:	e8 03 c2 ff ff       	call   80101ae9 <ilock>
801058e6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801058e9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801058ee:	75 15                	jne    80105905 <create+0xa9>
801058f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058f7:	66 83 f8 02          	cmp    $0x2,%ax
801058fb:	75 08                	jne    80105905 <create+0xa9>
      return ip;
801058fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105900:	e9 2b 01 00 00       	jmp    80105a30 <create+0x1d4>
    iunlockput(ip);
80105905:	83 ec 0c             	sub    $0xc,%esp
80105908:	ff 75 f0             	push   -0x10(%ebp)
8010590b:	e8 16 c4 ff ff       	call   80101d26 <iunlockput>
80105910:	83 c4 10             	add    $0x10,%esp
    return 0;
80105913:	b8 00 00 00 00       	mov    $0x0,%eax
80105918:	e9 13 01 00 00       	jmp    80105a30 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010591d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	8b 00                	mov    (%eax),%eax
80105926:	83 ec 08             	sub    $0x8,%esp
80105929:	52                   	push   %edx
8010592a:	50                   	push   %eax
8010592b:	e8 f5 be ff ff       	call   80101825 <ialloc>
80105930:	83 c4 10             	add    $0x10,%esp
80105933:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105936:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010593a:	75 0d                	jne    80105949 <create+0xed>
    panic("create: ialloc");
8010593c:	83 ec 0c             	sub    $0xc,%esp
8010593f:	68 8e ac 10 80       	push   $0x8010ac8e
80105944:	e8 95 ac ff ff       	call   801005de <panic>

  ilock(ip);
80105949:	83 ec 0c             	sub    $0xc,%esp
8010594c:	ff 75 f0             	push   -0x10(%ebp)
8010594f:	e8 95 c1 ff ff       	call   80101ae9 <ilock>
80105954:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010595e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105965:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105969:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010596d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105970:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	ff 75 f0             	push   -0x10(%ebp)
8010597c:	e8 7f bf ff ff       	call   80101900 <iupdate>
80105981:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105984:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105989:	75 6a                	jne    801059f5 <create+0x199>
    dp->nlink++;  // for ".."
8010598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105992:	83 c0 01             	add    $0x1,%eax
80105995:	89 c2                	mov    %eax,%edx
80105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010599e:	83 ec 0c             	sub    $0xc,%esp
801059a1:	ff 75 f4             	push   -0xc(%ebp)
801059a4:	e8 57 bf ff ff       	call   80101900 <iupdate>
801059a9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	8b 40 04             	mov    0x4(%eax),%eax
801059b2:	83 ec 04             	sub    $0x4,%esp
801059b5:	50                   	push   %eax
801059b6:	68 68 ac 10 80       	push   $0x8010ac68
801059bb:	ff 75 f0             	push   -0x10(%ebp)
801059be:	e8 ee c9 ff ff       	call   801023b1 <dirlink>
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	85 c0                	test   %eax,%eax
801059c8:	78 1e                	js     801059e8 <create+0x18c>
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	8b 40 04             	mov    0x4(%eax),%eax
801059d0:	83 ec 04             	sub    $0x4,%esp
801059d3:	50                   	push   %eax
801059d4:	68 6a ac 10 80       	push   $0x8010ac6a
801059d9:	ff 75 f0             	push   -0x10(%ebp)
801059dc:	e8 d0 c9 ff ff       	call   801023b1 <dirlink>
801059e1:	83 c4 10             	add    $0x10,%esp
801059e4:	85 c0                	test   %eax,%eax
801059e6:	79 0d                	jns    801059f5 <create+0x199>
      panic("create dots");
801059e8:	83 ec 0c             	sub    $0xc,%esp
801059eb:	68 9d ac 10 80       	push   $0x8010ac9d
801059f0:	e8 e9 ab ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801059f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f8:	8b 40 04             	mov    0x4(%eax),%eax
801059fb:	83 ec 04             	sub    $0x4,%esp
801059fe:	50                   	push   %eax
801059ff:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a02:	50                   	push   %eax
80105a03:	ff 75 f4             	push   -0xc(%ebp)
80105a06:	e8 a6 c9 ff ff       	call   801023b1 <dirlink>
80105a0b:	83 c4 10             	add    $0x10,%esp
80105a0e:	85 c0                	test   %eax,%eax
80105a10:	79 0d                	jns    80105a1f <create+0x1c3>
    panic("create: dirlink");
80105a12:	83 ec 0c             	sub    $0xc,%esp
80105a15:	68 a9 ac 10 80       	push   $0x8010aca9
80105a1a:	e8 bf ab ff ff       	call   801005de <panic>

  iunlockput(dp);
80105a1f:	83 ec 0c             	sub    $0xc,%esp
80105a22:	ff 75 f4             	push   -0xc(%ebp)
80105a25:	e8 fc c2 ff ff       	call   80101d26 <iunlockput>
80105a2a:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a30:	c9                   	leave
80105a31:	c3                   	ret

80105a32 <sys_open>:

int
sys_open(void)
{
80105a32:	f3 0f 1e fb          	endbr32
80105a36:	55                   	push   %ebp
80105a37:	89 e5                	mov    %esp,%ebp
80105a39:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a3c:	83 ec 08             	sub    $0x8,%esp
80105a3f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a42:	50                   	push   %eax
80105a43:	6a 00                	push   $0x0
80105a45:	e8 b2 f6 ff ff       	call   801050fc <argstr>
80105a4a:	83 c4 10             	add    $0x10,%esp
80105a4d:	85 c0                	test   %eax,%eax
80105a4f:	78 15                	js     80105a66 <sys_open+0x34>
80105a51:	83 ec 08             	sub    $0x8,%esp
80105a54:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a57:	50                   	push   %eax
80105a58:	6a 01                	push   $0x1
80105a5a:	e8 0f f6 ff ff       	call   8010506e <argint>
80105a5f:	83 c4 10             	add    $0x10,%esp
80105a62:	85 c0                	test   %eax,%eax
80105a64:	79 0a                	jns    80105a70 <sys_open+0x3e>
    return -1;
80105a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6b:	e9 61 01 00 00       	jmp    80105bd1 <sys_open+0x19f>

  begin_op();
80105a70:	e8 69 d7 ff ff       	call   801031de <begin_op>

  if(omode & O_CREATE){
80105a75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a78:	25 00 02 00 00       	and    $0x200,%eax
80105a7d:	85 c0                	test   %eax,%eax
80105a7f:	74 2a                	je     80105aab <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a84:	6a 00                	push   $0x0
80105a86:	6a 00                	push   $0x0
80105a88:	6a 02                	push   $0x2
80105a8a:	50                   	push   %eax
80105a8b:	e8 cc fd ff ff       	call   8010585c <create>
80105a90:	83 c4 10             	add    $0x10,%esp
80105a93:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a9a:	75 75                	jne    80105b11 <sys_open+0xdf>
      end_op();
80105a9c:	e8 cd d7 ff ff       	call   8010326e <end_op>
      return -1;
80105aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa6:	e9 26 01 00 00       	jmp    80105bd1 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aae:	83 ec 0c             	sub    $0xc,%esp
80105ab1:	50                   	push   %eax
80105ab2:	e8 9d cb ff ff       	call   80102654 <namei>
80105ab7:	83 c4 10             	add    $0x10,%esp
80105aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105abd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac1:	75 0f                	jne    80105ad2 <sys_open+0xa0>
      end_op();
80105ac3:	e8 a6 d7 ff ff       	call   8010326e <end_op>
      return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	e9 ff 00 00 00       	jmp    80105bd1 <sys_open+0x19f>
    }
    ilock(ip);
80105ad2:	83 ec 0c             	sub    $0xc,%esp
80105ad5:	ff 75 f4             	push   -0xc(%ebp)
80105ad8:	e8 0c c0 ff ff       	call   80101ae9 <ilock>
80105add:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ae7:	66 83 f8 01          	cmp    $0x1,%ax
80105aeb:	75 24                	jne    80105b11 <sys_open+0xdf>
80105aed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105af0:	85 c0                	test   %eax,%eax
80105af2:	74 1d                	je     80105b11 <sys_open+0xdf>
      iunlockput(ip);
80105af4:	83 ec 0c             	sub    $0xc,%esp
80105af7:	ff 75 f4             	push   -0xc(%ebp)
80105afa:	e8 27 c2 ff ff       	call   80101d26 <iunlockput>
80105aff:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b02:	e8 67 d7 ff ff       	call   8010326e <end_op>
      return -1;
80105b07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0c:	e9 c0 00 00 00       	jmp    80105bd1 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b11:	e8 7a b5 ff ff       	call   80101090 <filealloc>
80105b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b1d:	74 17                	je     80105b36 <sys_open+0x104>
80105b1f:	83 ec 0c             	sub    $0xc,%esp
80105b22:	ff 75 f0             	push   -0x10(%ebp)
80105b25:	e8 07 f7 ff ff       	call   80105231 <fdalloc>
80105b2a:	83 c4 10             	add    $0x10,%esp
80105b2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b34:	79 2e                	jns    80105b64 <sys_open+0x132>
    if(f)
80105b36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3a:	74 0e                	je     80105b4a <sys_open+0x118>
      fileclose(f);
80105b3c:	83 ec 0c             	sub    $0xc,%esp
80105b3f:	ff 75 f0             	push   -0x10(%ebp)
80105b42:	e8 0f b6 ff ff       	call   80101156 <fileclose>
80105b47:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b4a:	83 ec 0c             	sub    $0xc,%esp
80105b4d:	ff 75 f4             	push   -0xc(%ebp)
80105b50:	e8 d1 c1 ff ff       	call   80101d26 <iunlockput>
80105b55:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b58:	e8 11 d7 ff ff       	call   8010326e <end_op>
    return -1;
80105b5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b62:	eb 6d                	jmp    80105bd1 <sys_open+0x19f>
  }
  iunlock(ip);
80105b64:	83 ec 0c             	sub    $0xc,%esp
80105b67:	ff 75 f4             	push   -0xc(%ebp)
80105b6a:	e8 91 c0 ff ff       	call   80101c00 <iunlock>
80105b6f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b72:	e8 f7 d6 ff ff       	call   8010326e <end_op>

  f->type = FD_INODE;
80105b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b86:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b96:	83 e0 01             	and    $0x1,%eax
80105b99:	85 c0                	test   %eax,%eax
80105b9b:	0f 94 c0             	sete   %al
80105b9e:	89 c2                	mov    %eax,%edx
80105ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ba9:	83 e0 01             	and    $0x1,%eax
80105bac:	85 c0                	test   %eax,%eax
80105bae:	75 0a                	jne    80105bba <sys_open+0x188>
80105bb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bb3:	83 e0 02             	and    $0x2,%eax
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	74 07                	je     80105bc1 <sys_open+0x18f>
80105bba:	b8 01 00 00 00       	mov    $0x1,%eax
80105bbf:	eb 05                	jmp    80105bc6 <sys_open+0x194>
80105bc1:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc6:	89 c2                	mov    %eax,%edx
80105bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bce:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bd1:	c9                   	leave
80105bd2:	c3                   	ret

80105bd3 <sys_mkdir>:

int
sys_mkdir(void)
{
80105bd3:	f3 0f 1e fb          	endbr32
80105bd7:	55                   	push   %ebp
80105bd8:	89 e5                	mov    %esp,%ebp
80105bda:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bdd:	e8 fc d5 ff ff       	call   801031de <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105be2:	83 ec 08             	sub    $0x8,%esp
80105be5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be8:	50                   	push   %eax
80105be9:	6a 00                	push   $0x0
80105beb:	e8 0c f5 ff ff       	call   801050fc <argstr>
80105bf0:	83 c4 10             	add    $0x10,%esp
80105bf3:	85 c0                	test   %eax,%eax
80105bf5:	78 1b                	js     80105c12 <sys_mkdir+0x3f>
80105bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfa:	6a 00                	push   $0x0
80105bfc:	6a 00                	push   $0x0
80105bfe:	6a 01                	push   $0x1
80105c00:	50                   	push   %eax
80105c01:	e8 56 fc ff ff       	call   8010585c <create>
80105c06:	83 c4 10             	add    $0x10,%esp
80105c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c10:	75 0c                	jne    80105c1e <sys_mkdir+0x4b>
    end_op();
80105c12:	e8 57 d6 ff ff       	call   8010326e <end_op>
    return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	eb 18                	jmp    80105c36 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105c1e:	83 ec 0c             	sub    $0xc,%esp
80105c21:	ff 75 f4             	push   -0xc(%ebp)
80105c24:	e8 fd c0 ff ff       	call   80101d26 <iunlockput>
80105c29:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c2c:	e8 3d d6 ff ff       	call   8010326e <end_op>
  return 0;
80105c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c36:	c9                   	leave
80105c37:	c3                   	ret

80105c38 <sys_mknod>:

int
sys_mknod(void)
{
80105c38:	f3 0f 1e fb          	endbr32
80105c3c:	55                   	push   %ebp
80105c3d:	89 e5                	mov    %esp,%ebp
80105c3f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c42:	e8 97 d5 ff ff       	call   801031de <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c47:	83 ec 08             	sub    $0x8,%esp
80105c4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c4d:	50                   	push   %eax
80105c4e:	6a 00                	push   $0x0
80105c50:	e8 a7 f4 ff ff       	call   801050fc <argstr>
80105c55:	83 c4 10             	add    $0x10,%esp
80105c58:	85 c0                	test   %eax,%eax
80105c5a:	78 4f                	js     80105cab <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105c5c:	83 ec 08             	sub    $0x8,%esp
80105c5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	6a 01                	push   $0x1
80105c65:	e8 04 f4 ff ff       	call   8010506e <argint>
80105c6a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c6d:	85 c0                	test   %eax,%eax
80105c6f:	78 3a                	js     80105cab <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c71:	83 ec 08             	sub    $0x8,%esp
80105c74:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c77:	50                   	push   %eax
80105c78:	6a 02                	push   $0x2
80105c7a:	e8 ef f3 ff ff       	call   8010506e <argint>
80105c7f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c82:	85 c0                	test   %eax,%eax
80105c84:	78 25                	js     80105cab <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c89:	0f bf c8             	movswl %ax,%ecx
80105c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c8f:	0f bf d0             	movswl %ax,%edx
80105c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c95:	51                   	push   %ecx
80105c96:	52                   	push   %edx
80105c97:	6a 03                	push   $0x3
80105c99:	50                   	push   %eax
80105c9a:	e8 bd fb ff ff       	call   8010585c <create>
80105c9f:	83 c4 10             	add    $0x10,%esp
80105ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105ca5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca9:	75 0c                	jne    80105cb7 <sys_mknod+0x7f>
    end_op();
80105cab:	e8 be d5 ff ff       	call   8010326e <end_op>
    return -1;
80105cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb5:	eb 18                	jmp    80105ccf <sys_mknod+0x97>
  }
  iunlockput(ip);
80105cb7:	83 ec 0c             	sub    $0xc,%esp
80105cba:	ff 75 f4             	push   -0xc(%ebp)
80105cbd:	e8 64 c0 ff ff       	call   80101d26 <iunlockput>
80105cc2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cc5:	e8 a4 d5 ff ff       	call   8010326e <end_op>
  return 0;
80105cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ccf:	c9                   	leave
80105cd0:	c3                   	ret

80105cd1 <sys_chdir>:

int
sys_chdir(void)
{
80105cd1:	f3 0f 1e fb          	endbr32
80105cd5:	55                   	push   %ebp
80105cd6:	89 e5                	mov    %esp,%ebp
80105cd8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cdb:	e8 36 df ff ff       	call   80103c16 <myproc>
80105ce0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105ce3:	e8 f6 d4 ff ff       	call   801031de <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105ce8:	83 ec 08             	sub    $0x8,%esp
80105ceb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cee:	50                   	push   %eax
80105cef:	6a 00                	push   $0x0
80105cf1:	e8 06 f4 ff ff       	call   801050fc <argstr>
80105cf6:	83 c4 10             	add    $0x10,%esp
80105cf9:	85 c0                	test   %eax,%eax
80105cfb:	78 18                	js     80105d15 <sys_chdir+0x44>
80105cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d00:	83 ec 0c             	sub    $0xc,%esp
80105d03:	50                   	push   %eax
80105d04:	e8 4b c9 ff ff       	call   80102654 <namei>
80105d09:	83 c4 10             	add    $0x10,%esp
80105d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d13:	75 0c                	jne    80105d21 <sys_chdir+0x50>
    end_op();
80105d15:	e8 54 d5 ff ff       	call   8010326e <end_op>
    return -1;
80105d1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1f:	eb 68                	jmp    80105d89 <sys_chdir+0xb8>
  }
  ilock(ip);
80105d21:	83 ec 0c             	sub    $0xc,%esp
80105d24:	ff 75 f0             	push   -0x10(%ebp)
80105d27:	e8 bd bd ff ff       	call   80101ae9 <ilock>
80105d2c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d32:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d36:	66 83 f8 01          	cmp    $0x1,%ax
80105d3a:	74 1a                	je     80105d56 <sys_chdir+0x85>
    iunlockput(ip);
80105d3c:	83 ec 0c             	sub    $0xc,%esp
80105d3f:	ff 75 f0             	push   -0x10(%ebp)
80105d42:	e8 df bf ff ff       	call   80101d26 <iunlockput>
80105d47:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d4a:	e8 1f d5 ff ff       	call   8010326e <end_op>
    return -1;
80105d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d54:	eb 33                	jmp    80105d89 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105d56:	83 ec 0c             	sub    $0xc,%esp
80105d59:	ff 75 f0             	push   -0x10(%ebp)
80105d5c:	e8 9f be ff ff       	call   80101c00 <iunlock>
80105d61:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d67:	8b 40 68             	mov    0x68(%eax),%eax
80105d6a:	83 ec 0c             	sub    $0xc,%esp
80105d6d:	50                   	push   %eax
80105d6e:	e8 df be ff ff       	call   80101c52 <iput>
80105d73:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d76:	e8 f3 d4 ff ff       	call   8010326e <end_op>
  curproc->cwd = ip;
80105d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d81:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d89:	c9                   	leave
80105d8a:	c3                   	ret

80105d8b <sys_exec>:

int
sys_exec(void)
{
80105d8b:	f3 0f 1e fb          	endbr32
80105d8f:	55                   	push   %ebp
80105d90:	89 e5                	mov    %esp,%ebp
80105d92:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d98:	83 ec 08             	sub    $0x8,%esp
80105d9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d9e:	50                   	push   %eax
80105d9f:	6a 00                	push   $0x0
80105da1:	e8 56 f3 ff ff       	call   801050fc <argstr>
80105da6:	83 c4 10             	add    $0x10,%esp
80105da9:	85 c0                	test   %eax,%eax
80105dab:	78 18                	js     80105dc5 <sys_exec+0x3a>
80105dad:	83 ec 08             	sub    $0x8,%esp
80105db0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105db6:	50                   	push   %eax
80105db7:	6a 01                	push   $0x1
80105db9:	e8 b0 f2 ff ff       	call   8010506e <argint>
80105dbe:	83 c4 10             	add    $0x10,%esp
80105dc1:	85 c0                	test   %eax,%eax
80105dc3:	79 0a                	jns    80105dcf <sys_exec+0x44>
    return -1;
80105dc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dca:	e9 c6 00 00 00       	jmp    80105e95 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105dcf:	83 ec 04             	sub    $0x4,%esp
80105dd2:	68 80 00 00 00       	push   $0x80
80105dd7:	6a 00                	push   $0x0
80105dd9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ddf:	50                   	push   %eax
80105de0:	e8 54 ef ff ff       	call   80104d39 <memset>
80105de5:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105de8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df2:	83 f8 1f             	cmp    $0x1f,%eax
80105df5:	76 0a                	jbe    80105e01 <sys_exec+0x76>
      return -1;
80105df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfc:	e9 94 00 00 00       	jmp    80105e95 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e04:	c1 e0 02             	shl    $0x2,%eax
80105e07:	89 c2                	mov    %eax,%edx
80105e09:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e0f:	01 c2                	add    %eax,%edx
80105e11:	83 ec 08             	sub    $0x8,%esp
80105e14:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e1a:	50                   	push   %eax
80105e1b:	52                   	push   %edx
80105e1c:	e8 c1 f1 ff ff       	call   80104fe2 <fetchint>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	79 07                	jns    80105e2f <sys_exec+0xa4>
      return -1;
80105e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2d:	eb 66                	jmp    80105e95 <sys_exec+0x10a>
    if(uarg == 0){
80105e2f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e35:	85 c0                	test   %eax,%eax
80105e37:	75 27                	jne    80105e60 <sys_exec+0xd5>
      argv[i] = 0;
80105e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e43:	00 00 00 00 
      break;
80105e47:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4b:	83 ec 08             	sub    $0x8,%esp
80105e4e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e54:	52                   	push   %edx
80105e55:	50                   	push   %eax
80105e56:	e8 7c ad ff ff       	call   80100bd7 <exec>
80105e5b:	83 c4 10             	add    $0x10,%esp
80105e5e:	eb 35                	jmp    80105e95 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e60:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e69:	c1 e2 02             	shl    $0x2,%edx
80105e6c:	01 c2                	add    %eax,%edx
80105e6e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e74:	83 ec 08             	sub    $0x8,%esp
80105e77:	52                   	push   %edx
80105e78:	50                   	push   %eax
80105e79:	e8 94 f1 ff ff       	call   80105012 <fetchstr>
80105e7e:	83 c4 10             	add    $0x10,%esp
80105e81:	85 c0                	test   %eax,%eax
80105e83:	79 07                	jns    80105e8c <sys_exec+0x101>
      return -1;
80105e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8a:	eb 09                	jmp    80105e95 <sys_exec+0x10a>
  for(i=0;; i++){
80105e8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e90:	e9 5a ff ff ff       	jmp    80105def <sys_exec+0x64>
}
80105e95:	c9                   	leave
80105e96:	c3                   	ret

80105e97 <sys_pipe>:

int
sys_pipe(void)
{
80105e97:	f3 0f 1e fb          	endbr32
80105e9b:	55                   	push   %ebp
80105e9c:	89 e5                	mov    %esp,%ebp
80105e9e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ea1:	83 ec 04             	sub    $0x4,%esp
80105ea4:	6a 08                	push   $0x8
80105ea6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ea9:	50                   	push   %eax
80105eaa:	6a 00                	push   $0x0
80105eac:	e8 ee f1 ff ff       	call   8010509f <argptr>
80105eb1:	83 c4 10             	add    $0x10,%esp
80105eb4:	85 c0                	test   %eax,%eax
80105eb6:	79 0a                	jns    80105ec2 <sys_pipe+0x2b>
    return -1;
80105eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebd:	e9 ae 00 00 00       	jmp    80105f70 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105ec2:	83 ec 08             	sub    $0x8,%esp
80105ec5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ec8:	50                   	push   %eax
80105ec9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ecc:	50                   	push   %eax
80105ecd:	e8 65 d8 ff ff       	call   80103737 <pipealloc>
80105ed2:	83 c4 10             	add    $0x10,%esp
80105ed5:	85 c0                	test   %eax,%eax
80105ed7:	79 0a                	jns    80105ee3 <sys_pipe+0x4c>
    return -1;
80105ed9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ede:	e9 8d 00 00 00       	jmp    80105f70 <sys_pipe+0xd9>
  fd0 = -1;
80105ee3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105eea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105eed:	83 ec 0c             	sub    $0xc,%esp
80105ef0:	50                   	push   %eax
80105ef1:	e8 3b f3 ff ff       	call   80105231 <fdalloc>
80105ef6:	83 c4 10             	add    $0x10,%esp
80105ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f00:	78 18                	js     80105f1a <sys_pipe+0x83>
80105f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f05:	83 ec 0c             	sub    $0xc,%esp
80105f08:	50                   	push   %eax
80105f09:	e8 23 f3 ff ff       	call   80105231 <fdalloc>
80105f0e:	83 c4 10             	add    $0x10,%esp
80105f11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f18:	79 3e                	jns    80105f58 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105f1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f1e:	78 13                	js     80105f33 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105f20:	e8 f1 dc ff ff       	call   80103c16 <myproc>
80105f25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f28:	83 c2 08             	add    $0x8,%edx
80105f2b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f32:	00 
    fileclose(rf);
80105f33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f36:	83 ec 0c             	sub    $0xc,%esp
80105f39:	50                   	push   %eax
80105f3a:	e8 17 b2 ff ff       	call   80101156 <fileclose>
80105f3f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f45:	83 ec 0c             	sub    $0xc,%esp
80105f48:	50                   	push   %eax
80105f49:	e8 08 b2 ff ff       	call   80101156 <fileclose>
80105f4e:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f56:	eb 18                	jmp    80105f70 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105f58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f5e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f63:	8d 50 04             	lea    0x4(%eax),%edx
80105f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f69:	89 02                	mov    %eax,(%edx)
  return 0;
80105f6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f70:	c9                   	leave
80105f71:	c3                   	ret

80105f72 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f72:	f3 0f 1e fb          	endbr32
80105f76:	55                   	push   %ebp
80105f77:	89 e5                	mov    %esp,%ebp
80105f79:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f7c:	83 ec 08             	sub    $0x8,%esp
80105f7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f82:	50                   	push   %eax
80105f83:	6a 00                	push   $0x0
80105f85:	e8 e4 f0 ff ff       	call   8010506e <argint>
80105f8a:	83 c4 10             	add    $0x10,%esp
80105f8d:	85 c0                	test   %eax,%eax
80105f8f:	79 07                	jns    80105f98 <sys_printpt+0x26>
        return -1;
80105f91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f96:	eb 0f                	jmp    80105fa7 <sys_printpt+0x35>
  return printpt(pid);
80105f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9b:	83 ec 0c             	sub    $0xc,%esp
80105f9e:	50                   	push   %eax
80105f9f:	e8 3d e8 ff ff       	call   801047e1 <printpt>
80105fa4:	83 c4 10             	add    $0x10,%esp
}
80105fa7:	c9                   	leave
80105fa8:	c3                   	ret

80105fa9 <sys_fork>:

int
sys_fork(void)
{
80105fa9:	f3 0f 1e fb          	endbr32
80105fad:	55                   	push   %ebp
80105fae:	89 e5                	mov    %esp,%ebp
80105fb0:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fb3:	e8 81 df ff ff       	call   80103f39 <fork>
}
80105fb8:	c9                   	leave
80105fb9:	c3                   	ret

80105fba <sys_exit>:

int
sys_exit(void)
{
80105fba:	f3 0f 1e fb          	endbr32
80105fbe:	55                   	push   %ebp
80105fbf:	89 e5                	mov    %esp,%ebp
80105fc1:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fc4:	e8 ed e0 ff ff       	call   801040b6 <exit>
  return 0;  // not reached
80105fc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fce:	c9                   	leave
80105fcf:	c3                   	ret

80105fd0 <sys_wait>:

int
sys_wait(void)
{
80105fd0:	f3 0f 1e fb          	endbr32
80105fd4:	55                   	push   %ebp
80105fd5:	89 e5                	mov    %esp,%ebp
80105fd7:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fda:	e8 fb e1 ff ff       	call   801041da <wait>
}
80105fdf:	c9                   	leave
80105fe0:	c3                   	ret

80105fe1 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105fe1:	f3 0f 1e fb          	endbr32
80105fe5:	55                   	push   %ebp
80105fe6:	89 e5                	mov    %esp,%ebp
80105fe8:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105feb:	83 ec 08             	sub    $0x8,%esp
80105fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ff1:	50                   	push   %eax
80105ff2:	6a 00                	push   $0x0
80105ff4:	e8 75 f0 ff ff       	call   8010506e <argint>
80105ff9:	83 c4 10             	add    $0x10,%esp
80105ffc:	85 c0                	test   %eax,%eax
80105ffe:	79 07                	jns    80106007 <sys_uthread_init+0x26>
        return -1;
80106000:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106005:	eb 0f                	jmp    80106016 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80106007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600a:	83 ec 0c             	sub    $0xc,%esp
8010600d:	50                   	push   %eax
8010600e:	e8 a7 e3 ff ff       	call   801043ba <uthread_init>
80106013:	83 c4 10             	add    $0x10,%esp
}
80106016:	c9                   	leave
80106017:	c3                   	ret

80106018 <sys_kill>:

int
sys_kill(void)
{
80106018:	f3 0f 1e fb          	endbr32
8010601c:	55                   	push   %ebp
8010601d:	89 e5                	mov    %esp,%ebp
8010601f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106022:	83 ec 08             	sub    $0x8,%esp
80106025:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106028:	50                   	push   %eax
80106029:	6a 00                	push   $0x0
8010602b:	e8 3e f0 ff ff       	call   8010506e <argint>
80106030:	83 c4 10             	add    $0x10,%esp
80106033:	85 c0                	test   %eax,%eax
80106035:	79 07                	jns    8010603e <sys_kill+0x26>
    return -1;
80106037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603c:	eb 0f                	jmp    8010604d <sys_kill+0x35>
  return kill(pid);
8010603e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106041:	83 ec 0c             	sub    $0xc,%esp
80106044:	50                   	push   %eax
80106045:	e8 01 e6 ff ff       	call   8010464b <kill>
8010604a:	83 c4 10             	add    $0x10,%esp
}
8010604d:	c9                   	leave
8010604e:	c3                   	ret

8010604f <sys_getpid>:

int
sys_getpid(void)
{
8010604f:	f3 0f 1e fb          	endbr32
80106053:	55                   	push   %ebp
80106054:	89 e5                	mov    %esp,%ebp
80106056:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106059:	e8 b8 db ff ff       	call   80103c16 <myproc>
8010605e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106061:	c9                   	leave
80106062:	c3                   	ret

80106063 <sys_sbrk>:

int
sys_sbrk(void)
{
80106063:	f3 0f 1e fb          	endbr32
80106067:	55                   	push   %ebp
80106068:	89 e5                	mov    %esp,%ebp
8010606a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc* p = myproc();
8010606d:	e8 a4 db ff ff       	call   80103c16 <myproc>
80106072:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(argint(0, &n) < 0)
80106075:	83 ec 08             	sub    $0x8,%esp
80106078:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010607b:	50                   	push   %eax
8010607c:	6a 00                	push   $0x0
8010607e:	e8 eb ef ff ff       	call   8010506e <argint>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	85 c0                	test   %eax,%eax
80106088:	79 0a                	jns    80106094 <sys_sbrk+0x31>
    return -1;
8010608a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608f:	e9 4f 01 00 00       	jmp    801061e3 <sys_sbrk+0x180>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80106094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106097:	8b 00                	mov    (%eax),%eax
80106099:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (n > 0)
8010609c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010609f:	85 c0                	test   %eax,%eax
801060a1:	0f 8e b5 00 00 00    	jle    8010615c <sys_sbrk+0xf9>
  { 
    if (PGROUNDUP(p->sz + n) >= p->tf->esp){
801060a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060aa:	8b 00                	mov    (%eax),%eax
801060ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
801060af:	01 d0                	add    %edx,%eax
801060b1:	05 ff 0f 00 00       	add    $0xfff,%eax
801060b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060bb:	89 c2                	mov    %eax,%edx
801060bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c0:	8b 40 18             	mov    0x18(%eax),%eax
801060c3:	8b 40 44             	mov    0x44(%eax),%eax
801060c6:	39 c2                	cmp    %eax,%edx
801060c8:	72 1c                	jb     801060e6 <sys_sbrk+0x83>
      kill(p->pid);
801060ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cd:	8b 40 10             	mov    0x10(%eax),%eax
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	50                   	push   %eax
801060d4:	e8 72 e5 ff ff       	call   8010464b <kill>
801060d9:	83 c4 10             	add    $0x10,%esp
      return -1;
801060dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e1:	e9 fd 00 00 00       	jmp    801061e3 <sys_sbrk+0x180>
    }
    else{
      uint oldsz = PGROUNDUP(p->sz);
801060e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e9:	8b 00                	mov    (%eax),%eax
801060eb:	05 ff 0f 00 00       	add    $0xfff,%eax
801060f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint newsz = p->sz + n;
801060f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fb:	8b 00                	mov    (%eax),%eax
801060fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106100:	01 d0                	add    %edx,%eax
80106102:	89 45 e8             	mov    %eax,-0x18(%ebp)
      p->sz = newsz;
80106105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106108:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010610b:	89 10                	mov    %edx,(%eax)
      for(; oldsz < newsz; oldsz += PGSIZE){
8010610d:	eb 32                	jmp    80106141 <sys_sbrk+0xde>
      pte_t *pte = walkpgdir(p->pgdir, (void*)oldsz, 1);
8010610f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	8b 40 04             	mov    0x4(%eax),%eax
80106118:	83 ec 04             	sub    $0x4,%esp
8010611b:	6a 01                	push   $0x1
8010611d:	52                   	push   %edx
8010611e:	50                   	push   %eax
8010611f:	e8 f8 16 00 00       	call   8010781c <walkpgdir>
80106124:	83 c4 10             	add    $0x10,%esp
80106127:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (pte == 0)
8010612a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010612e:	75 0a                	jne    8010613a <sys_sbrk+0xd7>
        return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106135:	e9 a9 00 00 00       	jmp    801061e3 <sys_sbrk+0x180>
      for(; oldsz < newsz; oldsz += PGSIZE){
8010613a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80106141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106144:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80106147:	72 c6                	jb     8010610f <sys_sbrk+0xac>
      // cprintf("pgtab %x\n",*pte);
      }
      switchuvm(p);
80106149:	83 ec 0c             	sub    $0xc,%esp
8010614c:	ff 75 f0             	push   -0x10(%ebp)
8010614f:	e8 20 19 00 00       	call   80107a74 <switchuvm>
80106154:	83 c4 10             	add    $0x10,%esp
80106157:	e9 84 00 00 00       	jmp    801061e0 <sys_sbrk+0x17d>
    }
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
8010615c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010615f:	85 c0                	test   %eax,%eax
80106161:	79 7d                	jns    801061e0 <sys_sbrk+0x17d>
  {
    cprintf("[sbrk] sz %x \n",p->sz);
80106163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106166:	8b 00                	mov    (%eax),%eax
80106168:	83 ec 08             	sub    $0x8,%esp
8010616b:	50                   	push   %eax
8010616c:	68 b9 ac 10 80       	push   $0x8010acb9
80106171:	e8 96 a2 ff ff       	call   8010040c <cprintf>
80106176:	83 c4 10             	add    $0x10,%esp
    if(growproc(n) < 0)
80106179:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010617c:	83 ec 0c             	sub    $0xc,%esp
8010617f:	50                   	push   %eax
80106180:	e8 15 dd ff ff       	call   80103e9a <growproc>
80106185:	83 c4 10             	add    $0x10,%esp
80106188:	85 c0                	test   %eax,%eax
8010618a:	79 07                	jns    80106193 <sys_sbrk+0x130>
      return -1;
8010618c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106191:	eb 50                	jmp    801061e3 <sys_sbrk+0x180>
    cprintf("[sbrk] sz %x \n",p->sz);
80106193:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106196:	8b 00                	mov    (%eax),%eax
80106198:	83 ec 08             	sub    $0x8,%esp
8010619b:	50                   	push   %eax
8010619c:	68 b9 ac 10 80       	push   $0x8010acb9
801061a1:	e8 66 a2 ff ff       	call   8010040c <cprintf>
801061a6:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] addr %x \n", addr);
801061a9:	83 ec 08             	sub    $0x8,%esp
801061ac:	ff 75 ec             	push   -0x14(%ebp)
801061af:	68 c8 ac 10 80       	push   $0x8010acc8
801061b4:	e8 53 a2 ff ff       	call   8010040c <cprintf>
801061b9:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] esp %x eip %x \n",p->tf->esp, p->tf->eip);
801061bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bf:	8b 40 18             	mov    0x18(%eax),%eax
801061c2:	8b 50 38             	mov    0x38(%eax),%edx
801061c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c8:	8b 40 18             	mov    0x18(%eax),%eax
801061cb:	8b 40 44             	mov    0x44(%eax),%eax
801061ce:	83 ec 04             	sub    $0x4,%esp
801061d1:	52                   	push   %edx
801061d2:	50                   	push   %eax
801061d3:	68 d9 ac 10 80       	push   $0x8010acd9
801061d8:	e8 2f a2 ff ff       	call   8010040c <cprintf>
801061dd:	83 c4 10             	add    $0x10,%esp
  }
  return addr;
801061e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061e3:	c9                   	leave
801061e4:	c3                   	ret

801061e5 <sys_sleep>:

int
sys_sleep(void)
{
801061e5:	f3 0f 1e fb          	endbr32
801061e9:	55                   	push   %ebp
801061ea:	89 e5                	mov    %esp,%ebp
801061ec:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801061ef:	83 ec 08             	sub    $0x8,%esp
801061f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061f5:	50                   	push   %eax
801061f6:	6a 00                	push   $0x0
801061f8:	e8 71 ee ff ff       	call   8010506e <argint>
801061fd:	83 c4 10             	add    $0x10,%esp
80106200:	85 c0                	test   %eax,%eax
80106202:	79 07                	jns    8010620b <sys_sleep+0x26>
    return -1;
80106204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106209:	eb 76                	jmp    80106281 <sys_sleep+0x9c>
  acquire(&tickslock);
8010620b:	83 ec 0c             	sub    $0xc,%esp
8010620e:	68 40 75 19 80       	push   $0x80197540
80106213:	e8 92 e8 ff ff       	call   80104aaa <acquire>
80106218:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010621b:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106223:	eb 38                	jmp    8010625d <sys_sleep+0x78>
    if(myproc()->killed){
80106225:	e8 ec d9 ff ff       	call   80103c16 <myproc>
8010622a:	8b 40 24             	mov    0x24(%eax),%eax
8010622d:	85 c0                	test   %eax,%eax
8010622f:	74 17                	je     80106248 <sys_sleep+0x63>
      release(&tickslock);
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	68 40 75 19 80       	push   $0x80197540
80106239:	e8 de e8 ff ff       	call   80104b1c <release>
8010623e:	83 c4 10             	add    $0x10,%esp
      return -1;
80106241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106246:	eb 39                	jmp    80106281 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106248:	83 ec 08             	sub    $0x8,%esp
8010624b:	68 40 75 19 80       	push   $0x80197540
80106250:	68 80 7d 19 80       	push   $0x80197d80
80106255:	e8 c7 e2 ff ff       	call   80104521 <sleep>
8010625a:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010625d:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106262:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106265:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106268:	39 d0                	cmp    %edx,%eax
8010626a:	72 b9                	jb     80106225 <sys_sleep+0x40>
  }
  release(&tickslock);
8010626c:	83 ec 0c             	sub    $0xc,%esp
8010626f:	68 40 75 19 80       	push   $0x80197540
80106274:	e8 a3 e8 ff ff       	call   80104b1c <release>
80106279:	83 c4 10             	add    $0x10,%esp
  return 0;
8010627c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106281:	c9                   	leave
80106282:	c3                   	ret

80106283 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106283:	f3 0f 1e fb          	endbr32
80106287:	55                   	push   %ebp
80106288:	89 e5                	mov    %esp,%ebp
8010628a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010628d:	83 ec 0c             	sub    $0xc,%esp
80106290:	68 40 75 19 80       	push   $0x80197540
80106295:	e8 10 e8 ff ff       	call   80104aaa <acquire>
8010629a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010629d:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801062a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801062a5:	83 ec 0c             	sub    $0xc,%esp
801062a8:	68 40 75 19 80       	push   $0x80197540
801062ad:	e8 6a e8 ff ff       	call   80104b1c <release>
801062b2:	83 c4 10             	add    $0x10,%esp
  return xticks;
801062b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062b8:	c9                   	leave
801062b9:	c3                   	ret

801062ba <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062ba:	1e                   	push   %ds
  pushl %es
801062bb:	06                   	push   %es
  pushl %fs
801062bc:	0f a0                	push   %fs
  pushl %gs
801062be:	0f a8                	push   %gs
  pushal
801062c0:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062c1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062c5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062c7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801062c9:	54                   	push   %esp
  call trap
801062ca:	e8 df 01 00 00       	call   801064ae <trap>
  addl $4, %esp
801062cf:	83 c4 04             	add    $0x4,%esp

801062d2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801062d2:	61                   	popa
  popl %gs
801062d3:	0f a9                	pop    %gs
  popl %fs
801062d5:	0f a1                	pop    %fs
  popl %es
801062d7:	07                   	pop    %es
  popl %ds
801062d8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801062d9:	83 c4 08             	add    $0x8,%esp
  iret
801062dc:	cf                   	iret

801062dd <lidt>:
{
801062dd:	55                   	push   %ebp
801062de:	89 e5                	mov    %esp,%ebp
801062e0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801062e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e6:	83 e8 01             	sub    $0x1,%eax
801062e9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062ed:	8b 45 08             	mov    0x8(%ebp),%eax
801062f0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062f4:	8b 45 08             	mov    0x8(%ebp),%eax
801062f7:	c1 e8 10             	shr    $0x10,%eax
801062fa:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062fe:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106301:	0f 01 18             	lidtl  (%eax)
}
80106304:	90                   	nop
80106305:	c9                   	leave
80106306:	c3                   	ret

80106307 <rcr2>:

static inline uint
rcr2(void)
{
80106307:	55                   	push   %ebp
80106308:	89 e5                	mov    %esp,%ebp
8010630a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010630d:	0f 20 d0             	mov    %cr2,%eax
80106310:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106313:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106316:	c9                   	leave
80106317:	c3                   	ret

80106318 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106318:	f3 0f 1e fb          	endbr32
8010631c:	55                   	push   %ebp
8010631d:	89 e5                	mov    %esp,%ebp
8010631f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106322:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106329:	e9 c3 00 00 00       	jmp    801063f1 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010632e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106331:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106338:	89 c2                	mov    %eax,%edx
8010633a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633d:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106344:	80 
80106345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106348:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
8010634f:	80 08 00 
80106352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106355:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010635c:	80 
8010635d:	83 e2 e0             	and    $0xffffffe0,%edx
80106360:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636a:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106371:	80 
80106372:	83 e2 1f             	and    $0x1f,%edx
80106375:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010637c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637f:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106386:	80 
80106387:	83 e2 f0             	and    $0xfffffff0,%edx
8010638a:	83 ca 0e             	or     $0xe,%edx
8010638d:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106397:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010639e:	80 
8010639f:	83 e2 ef             	and    $0xffffffef,%edx
801063a2:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ac:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063b3:	80 
801063b4:	83 e2 9f             	and    $0xffffff9f,%edx
801063b7:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c1:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801063c8:	80 
801063c9:	83 ca 80             	or     $0xffffff80,%edx
801063cc:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801063dd:	c1 e8 10             	shr    $0x10,%eax
801063e0:	89 c2                	mov    %eax,%edx
801063e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e5:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801063ec:	80 
  for(i = 0; i < 256; i++)
801063ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063f1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063f8:	0f 8e 30 ff ff ff    	jle    8010632e <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063fe:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106403:	66 a3 80 77 19 80    	mov    %ax,0x80197780
80106409:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
80106410:	08 00 
80106412:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106419:	83 e0 e0             	and    $0xffffffe0,%eax
8010641c:	a2 84 77 19 80       	mov    %al,0x80197784
80106421:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106428:	83 e0 1f             	and    $0x1f,%eax
8010642b:	a2 84 77 19 80       	mov    %al,0x80197784
80106430:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106437:	83 c8 0f             	or     $0xf,%eax
8010643a:	a2 85 77 19 80       	mov    %al,0x80197785
8010643f:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106446:	83 e0 ef             	and    $0xffffffef,%eax
80106449:	a2 85 77 19 80       	mov    %al,0x80197785
8010644e:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106455:	83 c8 60             	or     $0x60,%eax
80106458:	a2 85 77 19 80       	mov    %al,0x80197785
8010645d:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106464:	83 c8 80             	or     $0xffffff80,%eax
80106467:	a2 85 77 19 80       	mov    %al,0x80197785
8010646c:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106471:	c1 e8 10             	shr    $0x10,%eax
80106474:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
8010647a:	83 ec 08             	sub    $0x8,%esp
8010647d:	68 f0 ac 10 80       	push   $0x8010acf0
80106482:	68 40 75 19 80       	push   $0x80197540
80106487:	e8 f8 e5 ff ff       	call   80104a84 <initlock>
8010648c:	83 c4 10             	add    $0x10,%esp
}
8010648f:	90                   	nop
80106490:	c9                   	leave
80106491:	c3                   	ret

80106492 <idtinit>:

void
idtinit(void)
{
80106492:	f3 0f 1e fb          	endbr32
80106496:	55                   	push   %ebp
80106497:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106499:	68 00 08 00 00       	push   $0x800
8010649e:	68 80 75 19 80       	push   $0x80197580
801064a3:	e8 35 fe ff ff       	call   801062dd <lidt>
801064a8:	83 c4 08             	add    $0x8,%esp
}
801064ab:	90                   	nop
801064ac:	c9                   	leave
801064ad:	c3                   	ret

801064ae <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801064ae:	f3 0f 1e fb          	endbr32
801064b2:	55                   	push   %ebp
801064b3:	89 e5                	mov    %esp,%ebp
801064b5:	57                   	push   %edi
801064b6:	56                   	push   %esi
801064b7:	53                   	push   %ebx
801064b8:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801064bb:	8b 45 08             	mov    0x8(%ebp),%eax
801064be:	8b 40 30             	mov    0x30(%eax),%eax
801064c1:	83 f8 40             	cmp    $0x40,%eax
801064c4:	75 3b                	jne    80106501 <trap+0x53>
    if(myproc()->killed)
801064c6:	e8 4b d7 ff ff       	call   80103c16 <myproc>
801064cb:	8b 40 24             	mov    0x24(%eax),%eax
801064ce:	85 c0                	test   %eax,%eax
801064d0:	74 05                	je     801064d7 <trap+0x29>
      exit();
801064d2:	e8 df db ff ff       	call   801040b6 <exit>
    myproc()->tf = tf;
801064d7:	e8 3a d7 ff ff       	call   80103c16 <myproc>
801064dc:	8b 55 08             	mov    0x8(%ebp),%edx
801064df:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801064e2:	e8 50 ec ff ff       	call   80105137 <syscall>
    if(myproc()->killed)
801064e7:	e8 2a d7 ff ff       	call   80103c16 <myproc>
801064ec:	8b 40 24             	mov    0x24(%eax),%eax
801064ef:	85 c0                	test   %eax,%eax
801064f1:	0f 84 0d 03 00 00    	je     80106804 <trap+0x356>
      exit();
801064f7:	e8 ba db ff ff       	call   801040b6 <exit>
    return;
801064fc:	e9 03 03 00 00       	jmp    80106804 <trap+0x356>
  }

  switch(tf->trapno){
80106501:	8b 45 08             	mov    0x8(%ebp),%eax
80106504:	8b 40 30             	mov    0x30(%eax),%eax
80106507:	83 e8 0e             	sub    $0xe,%eax
8010650a:	83 f8 31             	cmp    $0x31,%eax
8010650d:	0f 87 bc 01 00 00    	ja     801066cf <trap+0x221>
80106513:	8b 04 85 c4 ad 10 80 	mov    -0x7fef523c(,%eax,4),%eax
8010651a:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010651d:	e8 59 d6 ff ff       	call   80103b7b <cpuid>
80106522:	85 c0                	test   %eax,%eax
80106524:	75 3d                	jne    80106563 <trap+0xb5>
      acquire(&tickslock);
80106526:	83 ec 0c             	sub    $0xc,%esp
80106529:	68 40 75 19 80       	push   $0x80197540
8010652e:	e8 77 e5 ff ff       	call   80104aaa <acquire>
80106533:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106536:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010653b:	83 c0 01             	add    $0x1,%eax
8010653e:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106543:	83 ec 0c             	sub    $0xc,%esp
80106546:	68 80 7d 19 80       	push   $0x80197d80
8010654b:	e8 c0 e0 ff ff       	call   80104610 <wakeup>
80106550:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106553:	83 ec 0c             	sub    $0xc,%esp
80106556:	68 40 75 19 80       	push   $0x80197540
8010655b:	e8 bc e5 ff ff       	call   80104b1c <release>
80106560:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106563:	e8 2a c7 ff ff       	call   80102c92 <lapiceoi>


    break;
80106568:	e9 17 02 00 00       	jmp    80106784 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010656d:	e8 fd 40 00 00       	call   8010a66f <ideintr>
    lapiceoi();
80106572:	e8 1b c7 ff ff       	call   80102c92 <lapiceoi>
    break;
80106577:	e9 08 02 00 00       	jmp    80106784 <trap+0x2d6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010657c:	e8 47 c5 ff ff       	call   80102ac8 <kbdintr>
    lapiceoi();
80106581:	e8 0c c7 ff ff       	call   80102c92 <lapiceoi>
    break;
80106586:	e9 f9 01 00 00       	jmp    80106784 <trap+0x2d6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010658b:	e8 56 04 00 00       	call   801069e6 <uartintr>
    lapiceoi();
80106590:	e8 fd c6 ff ff       	call   80102c92 <lapiceoi>
    break;
80106595:	e9 ea 01 00 00       	jmp    80106784 <trap+0x2d6>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010659a:	e8 0f 2d 00 00       	call   801092ae <i8254_intr>
    lapiceoi();
8010659f:	e8 ee c6 ff ff       	call   80102c92 <lapiceoi>
    break;
801065a4:	e9 db 01 00 00       	jmp    80106784 <trap+0x2d6>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065a9:	8b 45 08             	mov    0x8(%ebp),%eax
801065ac:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065af:	8b 45 08             	mov    0x8(%ebp),%eax
801065b2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065b6:	0f b7 d8             	movzwl %ax,%ebx
801065b9:	e8 bd d5 ff ff       	call   80103b7b <cpuid>
801065be:	56                   	push   %esi
801065bf:	53                   	push   %ebx
801065c0:	50                   	push   %eax
801065c1:	68 f8 ac 10 80       	push   $0x8010acf8
801065c6:	e8 41 9e ff ff       	call   8010040c <cprintf>
801065cb:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065ce:	e8 bf c6 ff ff       	call   80102c92 <lapiceoi>
    break;
801065d3:	e9 ac 01 00 00       	jmp    80106784 <trap+0x2d6>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
801065d8:	e8 39 d6 ff ff       	call   80103c16 <myproc>
801065dd:	8b 40 24             	mov    0x24(%eax),%eax
801065e0:	85 c0                	test   %eax,%eax
801065e2:	74 05                	je     801065e9 <trap+0x13b>
      exit();
801065e4:	e8 cd da ff ff       	call   801040b6 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    uint sp;
    p = myproc();
801065e9:	e8 28 d6 ff ff       	call   80103c16 <myproc>
801065ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801065f1:	e8 11 fd ff ff       	call   80106307 <rcr2>
801065f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
801065fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106601:	8b 40 04             	mov    0x4(%eax),%eax
80106604:	89 45 dc             	mov    %eax,-0x24(%ebp)
    sp = p->tf->esp;
80106607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010660a:	8b 40 18             	mov    0x18(%eax),%eax
8010660d:	8b 40 44             	mov    0x44(%eax),%eax
80106610:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // sz+PGSIZE보다 크면 비정상적인 힙 영역 접근
    // sp-PGSIZE보다 작으면 비정상적인 스택 접근
    if (va > p->sz + PGSIZE && va < sp - PGSIZE){
80106613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106616:	8b 00                	mov    (%eax),%eax
80106618:	05 00 10 00 00       	add    $0x1000,%eax
8010661d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106620:	76 48                	jbe    8010666a <trap+0x1bc>
80106622:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106625:	2d 00 10 00 00       	sub    $0x1000,%eax
8010662a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010662d:	73 3b                	jae    8010666a <trap+0x1bc>
      cprintf("invaild access va %x sz %x sp %x eip %x\n",rcr2(),p->sz,sp, p->tf->eip);
8010662f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106632:	8b 40 18             	mov    0x18(%eax),%eax
80106635:	8b 70 38             	mov    0x38(%eax),%esi
80106638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010663b:	8b 18                	mov    (%eax),%ebx
8010663d:	e8 c5 fc ff ff       	call   80106307 <rcr2>
80106642:	83 ec 0c             	sub    $0xc,%esp
80106645:	56                   	push   %esi
80106646:	ff 75 d8             	push   -0x28(%ebp)
80106649:	53                   	push   %ebx
8010664a:	50                   	push   %eax
8010664b:	68 1c ad 10 80       	push   $0x8010ad1c
80106650:	e8 b7 9d ff ff       	call   8010040c <cprintf>
80106655:	83 c4 20             	add    $0x20,%esp
      kill(p->pid);
80106658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010665b:	8b 40 10             	mov    0x10(%eax),%eax
8010665e:	83 ec 0c             	sub    $0xc,%esp
80106661:	50                   	push   %eax
80106662:	e8 e4 df ff ff       	call   8010464b <kill>
80106667:	83 c4 10             	add    $0x10,%esp
    }

    if (va <= p->sz + PGSIZE){
8010666a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010666d:	8b 00                	mov    (%eax),%eax
8010666f:	05 00 10 00 00       	add    $0x1000,%eax
80106674:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106677:	77 1c                	ja     80106695 <trap+0x1e7>
      allocuvm(pgdir, va, va + PGSIZE);
80106679:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010667c:	05 00 10 00 00       	add    $0x1000,%eax
80106681:	83 ec 04             	sub    $0x4,%esp
80106684:	50                   	push   %eax
80106685:	ff 75 e0             	push   -0x20(%ebp)
80106688:	ff 75 dc             	push   -0x24(%ebp)
8010668b:	e8 cc 16 00 00       	call   80107d5c <allocuvm>
80106690:	83 c4 10             	add    $0x10,%esp
80106693:	eb 27                	jmp    801066bc <trap+0x20e>
    }
    else if (va >= sp - PGSIZE)
80106695:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106698:	2d 00 10 00 00       	sub    $0x1000,%eax
8010669d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
801066a0:	72 1a                	jb     801066bc <trap+0x20e>
    {
      allocuvm(pgdir, va, va + PGSIZE);
801066a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066a5:	05 00 10 00 00       	add    $0x1000,%eax
801066aa:	83 ec 04             	sub    $0x4,%esp
801066ad:	50                   	push   %eax
801066ae:	ff 75 e0             	push   -0x20(%ebp)
801066b1:	ff 75 dc             	push   -0x24(%ebp)
801066b4:	e8 a3 16 00 00       	call   80107d5c <allocuvm>
801066b9:	83 c4 10             	add    $0x10,%esp
    }

    // flush
    switchuvm(p);
801066bc:	83 ec 0c             	sub    $0xc,%esp
801066bf:	ff 75 e4             	push   -0x1c(%ebp)
801066c2:	e8 ad 13 00 00       	call   80107a74 <switchuvm>
801066c7:	83 c4 10             	add    $0x10,%esp
    break;
801066ca:	e9 b5 00 00 00       	jmp    80106784 <trap+0x2d6>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801066cf:	e8 42 d5 ff ff       	call   80103c16 <myproc>
801066d4:	85 c0                	test   %eax,%eax
801066d6:	74 11                	je     801066e9 <trap+0x23b>
801066d8:	8b 45 08             	mov    0x8(%ebp),%eax
801066db:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066df:	0f b7 c0             	movzwl %ax,%eax
801066e2:	83 e0 03             	and    $0x3,%eax
801066e5:	85 c0                	test   %eax,%eax
801066e7:	75 39                	jne    80106722 <trap+0x274>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801066e9:	e8 19 fc ff ff       	call   80106307 <rcr2>
801066ee:	89 c3                	mov    %eax,%ebx
801066f0:	8b 45 08             	mov    0x8(%ebp),%eax
801066f3:	8b 70 38             	mov    0x38(%eax),%esi
801066f6:	e8 80 d4 ff ff       	call   80103b7b <cpuid>
801066fb:	8b 55 08             	mov    0x8(%ebp),%edx
801066fe:	8b 52 30             	mov    0x30(%edx),%edx
80106701:	83 ec 0c             	sub    $0xc,%esp
80106704:	53                   	push   %ebx
80106705:	56                   	push   %esi
80106706:	50                   	push   %eax
80106707:	52                   	push   %edx
80106708:	68 48 ad 10 80       	push   $0x8010ad48
8010670d:	e8 fa 9c ff ff       	call   8010040c <cprintf>
80106712:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106715:	83 ec 0c             	sub    $0xc,%esp
80106718:	68 7a ad 10 80       	push   $0x8010ad7a
8010671d:	e8 bc 9e ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106722:	e8 e0 fb ff ff       	call   80106307 <rcr2>
80106727:	89 c6                	mov    %eax,%esi
80106729:	8b 45 08             	mov    0x8(%ebp),%eax
8010672c:	8b 40 38             	mov    0x38(%eax),%eax
8010672f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106732:	e8 44 d4 ff ff       	call   80103b7b <cpuid>
80106737:	89 c3                	mov    %eax,%ebx
80106739:	8b 45 08             	mov    0x8(%ebp),%eax
8010673c:	8b 48 34             	mov    0x34(%eax),%ecx
8010673f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106742:	8b 45 08             	mov    0x8(%ebp),%eax
80106745:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106748:	e8 c9 d4 ff ff       	call   80103c16 <myproc>
8010674d:	8d 50 6c             	lea    0x6c(%eax),%edx
80106750:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106753:	e8 be d4 ff ff       	call   80103c16 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106758:	8b 40 10             	mov    0x10(%eax),%eax
8010675b:	56                   	push   %esi
8010675c:	ff 75 d4             	push   -0x2c(%ebp)
8010675f:	53                   	push   %ebx
80106760:	ff 75 d0             	push   -0x30(%ebp)
80106763:	57                   	push   %edi
80106764:	ff 75 cc             	push   -0x34(%ebp)
80106767:	50                   	push   %eax
80106768:	68 80 ad 10 80       	push   $0x8010ad80
8010676d:	e8 9a 9c ff ff       	call   8010040c <cprintf>
80106772:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106775:	e8 9c d4 ff ff       	call   80103c16 <myproc>
8010677a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106781:	eb 01                	jmp    80106784 <trap+0x2d6>
    break;
80106783:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106784:	e8 8d d4 ff ff       	call   80103c16 <myproc>
80106789:	85 c0                	test   %eax,%eax
8010678b:	74 23                	je     801067b0 <trap+0x302>
8010678d:	e8 84 d4 ff ff       	call   80103c16 <myproc>
80106792:	8b 40 24             	mov    0x24(%eax),%eax
80106795:	85 c0                	test   %eax,%eax
80106797:	74 17                	je     801067b0 <trap+0x302>
80106799:	8b 45 08             	mov    0x8(%ebp),%eax
8010679c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067a0:	0f b7 c0             	movzwl %ax,%eax
801067a3:	83 e0 03             	and    $0x3,%eax
801067a6:	83 f8 03             	cmp    $0x3,%eax
801067a9:	75 05                	jne    801067b0 <trap+0x302>
    exit();
801067ab:	e8 06 d9 ff ff       	call   801040b6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801067b0:	e8 61 d4 ff ff       	call   80103c16 <myproc>
801067b5:	85 c0                	test   %eax,%eax
801067b7:	74 1d                	je     801067d6 <trap+0x328>
801067b9:	e8 58 d4 ff ff       	call   80103c16 <myproc>
801067be:	8b 40 0c             	mov    0xc(%eax),%eax
801067c1:	83 f8 04             	cmp    $0x4,%eax
801067c4:	75 10                	jne    801067d6 <trap+0x328>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801067c6:	8b 45 08             	mov    0x8(%ebp),%eax
801067c9:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801067cc:	83 f8 20             	cmp    $0x20,%eax
801067cf:	75 05                	jne    801067d6 <trap+0x328>
    yield();
801067d1:	e8 c3 dc ff ff       	call   80104499 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067d6:	e8 3b d4 ff ff       	call   80103c16 <myproc>
801067db:	85 c0                	test   %eax,%eax
801067dd:	74 26                	je     80106805 <trap+0x357>
801067df:	e8 32 d4 ff ff       	call   80103c16 <myproc>
801067e4:	8b 40 24             	mov    0x24(%eax),%eax
801067e7:	85 c0                	test   %eax,%eax
801067e9:	74 1a                	je     80106805 <trap+0x357>
801067eb:	8b 45 08             	mov    0x8(%ebp),%eax
801067ee:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067f2:	0f b7 c0             	movzwl %ax,%eax
801067f5:	83 e0 03             	and    $0x3,%eax
801067f8:	83 f8 03             	cmp    $0x3,%eax
801067fb:	75 08                	jne    80106805 <trap+0x357>
    exit();
801067fd:	e8 b4 d8 ff ff       	call   801040b6 <exit>
80106802:	eb 01                	jmp    80106805 <trap+0x357>
    return;
80106804:	90                   	nop
}
80106805:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106808:	5b                   	pop    %ebx
80106809:	5e                   	pop    %esi
8010680a:	5f                   	pop    %edi
8010680b:	5d                   	pop    %ebp
8010680c:	c3                   	ret

8010680d <inb>:
{
8010680d:	55                   	push   %ebp
8010680e:	89 e5                	mov    %esp,%ebp
80106810:	83 ec 14             	sub    $0x14,%esp
80106813:	8b 45 08             	mov    0x8(%ebp),%eax
80106816:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010681a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010681e:	89 c2                	mov    %eax,%edx
80106820:	ec                   	in     (%dx),%al
80106821:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106824:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106828:	c9                   	leave
80106829:	c3                   	ret

8010682a <outb>:
{
8010682a:	55                   	push   %ebp
8010682b:	89 e5                	mov    %esp,%ebp
8010682d:	83 ec 08             	sub    $0x8,%esp
80106830:	8b 45 08             	mov    0x8(%ebp),%eax
80106833:	8b 55 0c             	mov    0xc(%ebp),%edx
80106836:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010683a:	89 d0                	mov    %edx,%eax
8010683c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010683f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106843:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106847:	ee                   	out    %al,(%dx)
}
80106848:	90                   	nop
80106849:	c9                   	leave
8010684a:	c3                   	ret

8010684b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010684b:	f3 0f 1e fb          	endbr32
8010684f:	55                   	push   %ebp
80106850:	89 e5                	mov    %esp,%ebp
80106852:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106855:	6a 00                	push   $0x0
80106857:	68 fa 03 00 00       	push   $0x3fa
8010685c:	e8 c9 ff ff ff       	call   8010682a <outb>
80106861:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106864:	68 80 00 00 00       	push   $0x80
80106869:	68 fb 03 00 00       	push   $0x3fb
8010686e:	e8 b7 ff ff ff       	call   8010682a <outb>
80106873:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106876:	6a 0c                	push   $0xc
80106878:	68 f8 03 00 00       	push   $0x3f8
8010687d:	e8 a8 ff ff ff       	call   8010682a <outb>
80106882:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106885:	6a 00                	push   $0x0
80106887:	68 f9 03 00 00       	push   $0x3f9
8010688c:	e8 99 ff ff ff       	call   8010682a <outb>
80106891:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106894:	6a 03                	push   $0x3
80106896:	68 fb 03 00 00       	push   $0x3fb
8010689b:	e8 8a ff ff ff       	call   8010682a <outb>
801068a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801068a3:	6a 00                	push   $0x0
801068a5:	68 fc 03 00 00       	push   $0x3fc
801068aa:	e8 7b ff ff ff       	call   8010682a <outb>
801068af:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801068b2:	6a 01                	push   $0x1
801068b4:	68 f9 03 00 00       	push   $0x3f9
801068b9:	e8 6c ff ff ff       	call   8010682a <outb>
801068be:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801068c1:	68 fd 03 00 00       	push   $0x3fd
801068c6:	e8 42 ff ff ff       	call   8010680d <inb>
801068cb:	83 c4 04             	add    $0x4,%esp
801068ce:	3c ff                	cmp    $0xff,%al
801068d0:	74 61                	je     80106933 <uartinit+0xe8>
    return;
  uart = 1;
801068d2:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801068d9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801068dc:	68 fa 03 00 00       	push   $0x3fa
801068e1:	e8 27 ff ff ff       	call   8010680d <inb>
801068e6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801068e9:	68 f8 03 00 00       	push   $0x3f8
801068ee:	e8 1a ff ff ff       	call   8010680d <inb>
801068f3:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801068f6:	83 ec 08             	sub    $0x8,%esp
801068f9:	6a 00                	push   $0x0
801068fb:	6a 04                	push   $0x4
801068fd:	e8 77 be ff ff       	call   80102779 <ioapicenable>
80106902:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106905:	c7 45 f4 8c ae 10 80 	movl   $0x8010ae8c,-0xc(%ebp)
8010690c:	eb 19                	jmp    80106927 <uartinit+0xdc>
    uartputc(*p);
8010690e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106911:	0f b6 00             	movzbl (%eax),%eax
80106914:	0f be c0             	movsbl %al,%eax
80106917:	83 ec 0c             	sub    $0xc,%esp
8010691a:	50                   	push   %eax
8010691b:	e8 16 00 00 00       	call   80106936 <uartputc>
80106920:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106923:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010692a:	0f b6 00             	movzbl (%eax),%eax
8010692d:	84 c0                	test   %al,%al
8010692f:	75 dd                	jne    8010690e <uartinit+0xc3>
80106931:	eb 01                	jmp    80106934 <uartinit+0xe9>
    return;
80106933:	90                   	nop
}
80106934:	c9                   	leave
80106935:	c3                   	ret

80106936 <uartputc>:

void
uartputc(int c)
{
80106936:	f3 0f 1e fb          	endbr32
8010693a:	55                   	push   %ebp
8010693b:	89 e5                	mov    %esp,%ebp
8010693d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106940:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106945:	85 c0                	test   %eax,%eax
80106947:	74 53                	je     8010699c <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106949:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106950:	eb 11                	jmp    80106963 <uartputc+0x2d>
    microdelay(10);
80106952:	83 ec 0c             	sub    $0xc,%esp
80106955:	6a 0a                	push   $0xa
80106957:	e8 55 c3 ff ff       	call   80102cb1 <microdelay>
8010695c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010695f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106963:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106967:	7f 1a                	jg     80106983 <uartputc+0x4d>
80106969:	83 ec 0c             	sub    $0xc,%esp
8010696c:	68 fd 03 00 00       	push   $0x3fd
80106971:	e8 97 fe ff ff       	call   8010680d <inb>
80106976:	83 c4 10             	add    $0x10,%esp
80106979:	0f b6 c0             	movzbl %al,%eax
8010697c:	83 e0 20             	and    $0x20,%eax
8010697f:	85 c0                	test   %eax,%eax
80106981:	74 cf                	je     80106952 <uartputc+0x1c>
  outb(COM1+0, c);
80106983:	8b 45 08             	mov    0x8(%ebp),%eax
80106986:	0f b6 c0             	movzbl %al,%eax
80106989:	83 ec 08             	sub    $0x8,%esp
8010698c:	50                   	push   %eax
8010698d:	68 f8 03 00 00       	push   $0x3f8
80106992:	e8 93 fe ff ff       	call   8010682a <outb>
80106997:	83 c4 10             	add    $0x10,%esp
8010699a:	eb 01                	jmp    8010699d <uartputc+0x67>
    return;
8010699c:	90                   	nop
}
8010699d:	c9                   	leave
8010699e:	c3                   	ret

8010699f <uartgetc>:

static int
uartgetc(void)
{
8010699f:	f3 0f 1e fb          	endbr32
801069a3:	55                   	push   %ebp
801069a4:	89 e5                	mov    %esp,%ebp
  if(!uart)
801069a6:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801069ab:	85 c0                	test   %eax,%eax
801069ad:	75 07                	jne    801069b6 <uartgetc+0x17>
    return -1;
801069af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b4:	eb 2e                	jmp    801069e4 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801069b6:	68 fd 03 00 00       	push   $0x3fd
801069bb:	e8 4d fe ff ff       	call   8010680d <inb>
801069c0:	83 c4 04             	add    $0x4,%esp
801069c3:	0f b6 c0             	movzbl %al,%eax
801069c6:	83 e0 01             	and    $0x1,%eax
801069c9:	85 c0                	test   %eax,%eax
801069cb:	75 07                	jne    801069d4 <uartgetc+0x35>
    return -1;
801069cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d2:	eb 10                	jmp    801069e4 <uartgetc+0x45>
  return inb(COM1+0);
801069d4:	68 f8 03 00 00       	push   $0x3f8
801069d9:	e8 2f fe ff ff       	call   8010680d <inb>
801069de:	83 c4 04             	add    $0x4,%esp
801069e1:	0f b6 c0             	movzbl %al,%eax
}
801069e4:	c9                   	leave
801069e5:	c3                   	ret

801069e6 <uartintr>:

void
uartintr(void)
{
801069e6:	f3 0f 1e fb          	endbr32
801069ea:	55                   	push   %ebp
801069eb:	89 e5                	mov    %esp,%ebp
801069ed:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801069f0:	83 ec 0c             	sub    $0xc,%esp
801069f3:	68 9f 69 10 80       	push   $0x8010699f
801069f8:	e8 1c 9e ff ff       	call   80100819 <consoleintr>
801069fd:	83 c4 10             	add    $0x10,%esp
}
80106a00:	90                   	nop
80106a01:	c9                   	leave
80106a02:	c3                   	ret

80106a03 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a03:	6a 00                	push   $0x0
  pushl $0
80106a05:	6a 00                	push   $0x0
  jmp alltraps
80106a07:	e9 ae f8 ff ff       	jmp    801062ba <alltraps>

80106a0c <vector1>:
.globl vector1
vector1:
  pushl $0
80106a0c:	6a 00                	push   $0x0
  pushl $1
80106a0e:	6a 01                	push   $0x1
  jmp alltraps
80106a10:	e9 a5 f8 ff ff       	jmp    801062ba <alltraps>

80106a15 <vector2>:
.globl vector2
vector2:
  pushl $0
80106a15:	6a 00                	push   $0x0
  pushl $2
80106a17:	6a 02                	push   $0x2
  jmp alltraps
80106a19:	e9 9c f8 ff ff       	jmp    801062ba <alltraps>

80106a1e <vector3>:
.globl vector3
vector3:
  pushl $0
80106a1e:	6a 00                	push   $0x0
  pushl $3
80106a20:	6a 03                	push   $0x3
  jmp alltraps
80106a22:	e9 93 f8 ff ff       	jmp    801062ba <alltraps>

80106a27 <vector4>:
.globl vector4
vector4:
  pushl $0
80106a27:	6a 00                	push   $0x0
  pushl $4
80106a29:	6a 04                	push   $0x4
  jmp alltraps
80106a2b:	e9 8a f8 ff ff       	jmp    801062ba <alltraps>

80106a30 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a30:	6a 00                	push   $0x0
  pushl $5
80106a32:	6a 05                	push   $0x5
  jmp alltraps
80106a34:	e9 81 f8 ff ff       	jmp    801062ba <alltraps>

80106a39 <vector6>:
.globl vector6
vector6:
  pushl $0
80106a39:	6a 00                	push   $0x0
  pushl $6
80106a3b:	6a 06                	push   $0x6
  jmp alltraps
80106a3d:	e9 78 f8 ff ff       	jmp    801062ba <alltraps>

80106a42 <vector7>:
.globl vector7
vector7:
  pushl $0
80106a42:	6a 00                	push   $0x0
  pushl $7
80106a44:	6a 07                	push   $0x7
  jmp alltraps
80106a46:	e9 6f f8 ff ff       	jmp    801062ba <alltraps>

80106a4b <vector8>:
.globl vector8
vector8:
  pushl $8
80106a4b:	6a 08                	push   $0x8
  jmp alltraps
80106a4d:	e9 68 f8 ff ff       	jmp    801062ba <alltraps>

80106a52 <vector9>:
.globl vector9
vector9:
  pushl $0
80106a52:	6a 00                	push   $0x0
  pushl $9
80106a54:	6a 09                	push   $0x9
  jmp alltraps
80106a56:	e9 5f f8 ff ff       	jmp    801062ba <alltraps>

80106a5b <vector10>:
.globl vector10
vector10:
  pushl $10
80106a5b:	6a 0a                	push   $0xa
  jmp alltraps
80106a5d:	e9 58 f8 ff ff       	jmp    801062ba <alltraps>

80106a62 <vector11>:
.globl vector11
vector11:
  pushl $11
80106a62:	6a 0b                	push   $0xb
  jmp alltraps
80106a64:	e9 51 f8 ff ff       	jmp    801062ba <alltraps>

80106a69 <vector12>:
.globl vector12
vector12:
  pushl $12
80106a69:	6a 0c                	push   $0xc
  jmp alltraps
80106a6b:	e9 4a f8 ff ff       	jmp    801062ba <alltraps>

80106a70 <vector13>:
.globl vector13
vector13:
  pushl $13
80106a70:	6a 0d                	push   $0xd
  jmp alltraps
80106a72:	e9 43 f8 ff ff       	jmp    801062ba <alltraps>

80106a77 <vector14>:
.globl vector14
vector14:
  pushl $14
80106a77:	6a 0e                	push   $0xe
  jmp alltraps
80106a79:	e9 3c f8 ff ff       	jmp    801062ba <alltraps>

80106a7e <vector15>:
.globl vector15
vector15:
  pushl $0
80106a7e:	6a 00                	push   $0x0
  pushl $15
80106a80:	6a 0f                	push   $0xf
  jmp alltraps
80106a82:	e9 33 f8 ff ff       	jmp    801062ba <alltraps>

80106a87 <vector16>:
.globl vector16
vector16:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $16
80106a89:	6a 10                	push   $0x10
  jmp alltraps
80106a8b:	e9 2a f8 ff ff       	jmp    801062ba <alltraps>

80106a90 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a90:	6a 11                	push   $0x11
  jmp alltraps
80106a92:	e9 23 f8 ff ff       	jmp    801062ba <alltraps>

80106a97 <vector18>:
.globl vector18
vector18:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $18
80106a99:	6a 12                	push   $0x12
  jmp alltraps
80106a9b:	e9 1a f8 ff ff       	jmp    801062ba <alltraps>

80106aa0 <vector19>:
.globl vector19
vector19:
  pushl $0
80106aa0:	6a 00                	push   $0x0
  pushl $19
80106aa2:	6a 13                	push   $0x13
  jmp alltraps
80106aa4:	e9 11 f8 ff ff       	jmp    801062ba <alltraps>

80106aa9 <vector20>:
.globl vector20
vector20:
  pushl $0
80106aa9:	6a 00                	push   $0x0
  pushl $20
80106aab:	6a 14                	push   $0x14
  jmp alltraps
80106aad:	e9 08 f8 ff ff       	jmp    801062ba <alltraps>

80106ab2 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ab2:	6a 00                	push   $0x0
  pushl $21
80106ab4:	6a 15                	push   $0x15
  jmp alltraps
80106ab6:	e9 ff f7 ff ff       	jmp    801062ba <alltraps>

80106abb <vector22>:
.globl vector22
vector22:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $22
80106abd:	6a 16                	push   $0x16
  jmp alltraps
80106abf:	e9 f6 f7 ff ff       	jmp    801062ba <alltraps>

80106ac4 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ac4:	6a 00                	push   $0x0
  pushl $23
80106ac6:	6a 17                	push   $0x17
  jmp alltraps
80106ac8:	e9 ed f7 ff ff       	jmp    801062ba <alltraps>

80106acd <vector24>:
.globl vector24
vector24:
  pushl $0
80106acd:	6a 00                	push   $0x0
  pushl $24
80106acf:	6a 18                	push   $0x18
  jmp alltraps
80106ad1:	e9 e4 f7 ff ff       	jmp    801062ba <alltraps>

80106ad6 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ad6:	6a 00                	push   $0x0
  pushl $25
80106ad8:	6a 19                	push   $0x19
  jmp alltraps
80106ada:	e9 db f7 ff ff       	jmp    801062ba <alltraps>

80106adf <vector26>:
.globl vector26
vector26:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $26
80106ae1:	6a 1a                	push   $0x1a
  jmp alltraps
80106ae3:	e9 d2 f7 ff ff       	jmp    801062ba <alltraps>

80106ae8 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ae8:	6a 00                	push   $0x0
  pushl $27
80106aea:	6a 1b                	push   $0x1b
  jmp alltraps
80106aec:	e9 c9 f7 ff ff       	jmp    801062ba <alltraps>

80106af1 <vector28>:
.globl vector28
vector28:
  pushl $0
80106af1:	6a 00                	push   $0x0
  pushl $28
80106af3:	6a 1c                	push   $0x1c
  jmp alltraps
80106af5:	e9 c0 f7 ff ff       	jmp    801062ba <alltraps>

80106afa <vector29>:
.globl vector29
vector29:
  pushl $0
80106afa:	6a 00                	push   $0x0
  pushl $29
80106afc:	6a 1d                	push   $0x1d
  jmp alltraps
80106afe:	e9 b7 f7 ff ff       	jmp    801062ba <alltraps>

80106b03 <vector30>:
.globl vector30
vector30:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $30
80106b05:	6a 1e                	push   $0x1e
  jmp alltraps
80106b07:	e9 ae f7 ff ff       	jmp    801062ba <alltraps>

80106b0c <vector31>:
.globl vector31
vector31:
  pushl $0
80106b0c:	6a 00                	push   $0x0
  pushl $31
80106b0e:	6a 1f                	push   $0x1f
  jmp alltraps
80106b10:	e9 a5 f7 ff ff       	jmp    801062ba <alltraps>

80106b15 <vector32>:
.globl vector32
vector32:
  pushl $0
80106b15:	6a 00                	push   $0x0
  pushl $32
80106b17:	6a 20                	push   $0x20
  jmp alltraps
80106b19:	e9 9c f7 ff ff       	jmp    801062ba <alltraps>

80106b1e <vector33>:
.globl vector33
vector33:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $33
80106b20:	6a 21                	push   $0x21
  jmp alltraps
80106b22:	e9 93 f7 ff ff       	jmp    801062ba <alltraps>

80106b27 <vector34>:
.globl vector34
vector34:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $34
80106b29:	6a 22                	push   $0x22
  jmp alltraps
80106b2b:	e9 8a f7 ff ff       	jmp    801062ba <alltraps>

80106b30 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b30:	6a 00                	push   $0x0
  pushl $35
80106b32:	6a 23                	push   $0x23
  jmp alltraps
80106b34:	e9 81 f7 ff ff       	jmp    801062ba <alltraps>

80106b39 <vector36>:
.globl vector36
vector36:
  pushl $0
80106b39:	6a 00                	push   $0x0
  pushl $36
80106b3b:	6a 24                	push   $0x24
  jmp alltraps
80106b3d:	e9 78 f7 ff ff       	jmp    801062ba <alltraps>

80106b42 <vector37>:
.globl vector37
vector37:
  pushl $0
80106b42:	6a 00                	push   $0x0
  pushl $37
80106b44:	6a 25                	push   $0x25
  jmp alltraps
80106b46:	e9 6f f7 ff ff       	jmp    801062ba <alltraps>

80106b4b <vector38>:
.globl vector38
vector38:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $38
80106b4d:	6a 26                	push   $0x26
  jmp alltraps
80106b4f:	e9 66 f7 ff ff       	jmp    801062ba <alltraps>

80106b54 <vector39>:
.globl vector39
vector39:
  pushl $0
80106b54:	6a 00                	push   $0x0
  pushl $39
80106b56:	6a 27                	push   $0x27
  jmp alltraps
80106b58:	e9 5d f7 ff ff       	jmp    801062ba <alltraps>

80106b5d <vector40>:
.globl vector40
vector40:
  pushl $0
80106b5d:	6a 00                	push   $0x0
  pushl $40
80106b5f:	6a 28                	push   $0x28
  jmp alltraps
80106b61:	e9 54 f7 ff ff       	jmp    801062ba <alltraps>

80106b66 <vector41>:
.globl vector41
vector41:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $41
80106b68:	6a 29                	push   $0x29
  jmp alltraps
80106b6a:	e9 4b f7 ff ff       	jmp    801062ba <alltraps>

80106b6f <vector42>:
.globl vector42
vector42:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $42
80106b71:	6a 2a                	push   $0x2a
  jmp alltraps
80106b73:	e9 42 f7 ff ff       	jmp    801062ba <alltraps>

80106b78 <vector43>:
.globl vector43
vector43:
  pushl $0
80106b78:	6a 00                	push   $0x0
  pushl $43
80106b7a:	6a 2b                	push   $0x2b
  jmp alltraps
80106b7c:	e9 39 f7 ff ff       	jmp    801062ba <alltraps>

80106b81 <vector44>:
.globl vector44
vector44:
  pushl $0
80106b81:	6a 00                	push   $0x0
  pushl $44
80106b83:	6a 2c                	push   $0x2c
  jmp alltraps
80106b85:	e9 30 f7 ff ff       	jmp    801062ba <alltraps>

80106b8a <vector45>:
.globl vector45
vector45:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $45
80106b8c:	6a 2d                	push   $0x2d
  jmp alltraps
80106b8e:	e9 27 f7 ff ff       	jmp    801062ba <alltraps>

80106b93 <vector46>:
.globl vector46
vector46:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $46
80106b95:	6a 2e                	push   $0x2e
  jmp alltraps
80106b97:	e9 1e f7 ff ff       	jmp    801062ba <alltraps>

80106b9c <vector47>:
.globl vector47
vector47:
  pushl $0
80106b9c:	6a 00                	push   $0x0
  pushl $47
80106b9e:	6a 2f                	push   $0x2f
  jmp alltraps
80106ba0:	e9 15 f7 ff ff       	jmp    801062ba <alltraps>

80106ba5 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ba5:	6a 00                	push   $0x0
  pushl $48
80106ba7:	6a 30                	push   $0x30
  jmp alltraps
80106ba9:	e9 0c f7 ff ff       	jmp    801062ba <alltraps>

80106bae <vector49>:
.globl vector49
vector49:
  pushl $0
80106bae:	6a 00                	push   $0x0
  pushl $49
80106bb0:	6a 31                	push   $0x31
  jmp alltraps
80106bb2:	e9 03 f7 ff ff       	jmp    801062ba <alltraps>

80106bb7 <vector50>:
.globl vector50
vector50:
  pushl $0
80106bb7:	6a 00                	push   $0x0
  pushl $50
80106bb9:	6a 32                	push   $0x32
  jmp alltraps
80106bbb:	e9 fa f6 ff ff       	jmp    801062ba <alltraps>

80106bc0 <vector51>:
.globl vector51
vector51:
  pushl $0
80106bc0:	6a 00                	push   $0x0
  pushl $51
80106bc2:	6a 33                	push   $0x33
  jmp alltraps
80106bc4:	e9 f1 f6 ff ff       	jmp    801062ba <alltraps>

80106bc9 <vector52>:
.globl vector52
vector52:
  pushl $0
80106bc9:	6a 00                	push   $0x0
  pushl $52
80106bcb:	6a 34                	push   $0x34
  jmp alltraps
80106bcd:	e9 e8 f6 ff ff       	jmp    801062ba <alltraps>

80106bd2 <vector53>:
.globl vector53
vector53:
  pushl $0
80106bd2:	6a 00                	push   $0x0
  pushl $53
80106bd4:	6a 35                	push   $0x35
  jmp alltraps
80106bd6:	e9 df f6 ff ff       	jmp    801062ba <alltraps>

80106bdb <vector54>:
.globl vector54
vector54:
  pushl $0
80106bdb:	6a 00                	push   $0x0
  pushl $54
80106bdd:	6a 36                	push   $0x36
  jmp alltraps
80106bdf:	e9 d6 f6 ff ff       	jmp    801062ba <alltraps>

80106be4 <vector55>:
.globl vector55
vector55:
  pushl $0
80106be4:	6a 00                	push   $0x0
  pushl $55
80106be6:	6a 37                	push   $0x37
  jmp alltraps
80106be8:	e9 cd f6 ff ff       	jmp    801062ba <alltraps>

80106bed <vector56>:
.globl vector56
vector56:
  pushl $0
80106bed:	6a 00                	push   $0x0
  pushl $56
80106bef:	6a 38                	push   $0x38
  jmp alltraps
80106bf1:	e9 c4 f6 ff ff       	jmp    801062ba <alltraps>

80106bf6 <vector57>:
.globl vector57
vector57:
  pushl $0
80106bf6:	6a 00                	push   $0x0
  pushl $57
80106bf8:	6a 39                	push   $0x39
  jmp alltraps
80106bfa:	e9 bb f6 ff ff       	jmp    801062ba <alltraps>

80106bff <vector58>:
.globl vector58
vector58:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $58
80106c01:	6a 3a                	push   $0x3a
  jmp alltraps
80106c03:	e9 b2 f6 ff ff       	jmp    801062ba <alltraps>

80106c08 <vector59>:
.globl vector59
vector59:
  pushl $0
80106c08:	6a 00                	push   $0x0
  pushl $59
80106c0a:	6a 3b                	push   $0x3b
  jmp alltraps
80106c0c:	e9 a9 f6 ff ff       	jmp    801062ba <alltraps>

80106c11 <vector60>:
.globl vector60
vector60:
  pushl $0
80106c11:	6a 00                	push   $0x0
  pushl $60
80106c13:	6a 3c                	push   $0x3c
  jmp alltraps
80106c15:	e9 a0 f6 ff ff       	jmp    801062ba <alltraps>

80106c1a <vector61>:
.globl vector61
vector61:
  pushl $0
80106c1a:	6a 00                	push   $0x0
  pushl $61
80106c1c:	6a 3d                	push   $0x3d
  jmp alltraps
80106c1e:	e9 97 f6 ff ff       	jmp    801062ba <alltraps>

80106c23 <vector62>:
.globl vector62
vector62:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $62
80106c25:	6a 3e                	push   $0x3e
  jmp alltraps
80106c27:	e9 8e f6 ff ff       	jmp    801062ba <alltraps>

80106c2c <vector63>:
.globl vector63
vector63:
  pushl $0
80106c2c:	6a 00                	push   $0x0
  pushl $63
80106c2e:	6a 3f                	push   $0x3f
  jmp alltraps
80106c30:	e9 85 f6 ff ff       	jmp    801062ba <alltraps>

80106c35 <vector64>:
.globl vector64
vector64:
  pushl $0
80106c35:	6a 00                	push   $0x0
  pushl $64
80106c37:	6a 40                	push   $0x40
  jmp alltraps
80106c39:	e9 7c f6 ff ff       	jmp    801062ba <alltraps>

80106c3e <vector65>:
.globl vector65
vector65:
  pushl $0
80106c3e:	6a 00                	push   $0x0
  pushl $65
80106c40:	6a 41                	push   $0x41
  jmp alltraps
80106c42:	e9 73 f6 ff ff       	jmp    801062ba <alltraps>

80106c47 <vector66>:
.globl vector66
vector66:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $66
80106c49:	6a 42                	push   $0x42
  jmp alltraps
80106c4b:	e9 6a f6 ff ff       	jmp    801062ba <alltraps>

80106c50 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c50:	6a 00                	push   $0x0
  pushl $67
80106c52:	6a 43                	push   $0x43
  jmp alltraps
80106c54:	e9 61 f6 ff ff       	jmp    801062ba <alltraps>

80106c59 <vector68>:
.globl vector68
vector68:
  pushl $0
80106c59:	6a 00                	push   $0x0
  pushl $68
80106c5b:	6a 44                	push   $0x44
  jmp alltraps
80106c5d:	e9 58 f6 ff ff       	jmp    801062ba <alltraps>

80106c62 <vector69>:
.globl vector69
vector69:
  pushl $0
80106c62:	6a 00                	push   $0x0
  pushl $69
80106c64:	6a 45                	push   $0x45
  jmp alltraps
80106c66:	e9 4f f6 ff ff       	jmp    801062ba <alltraps>

80106c6b <vector70>:
.globl vector70
vector70:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $70
80106c6d:	6a 46                	push   $0x46
  jmp alltraps
80106c6f:	e9 46 f6 ff ff       	jmp    801062ba <alltraps>

80106c74 <vector71>:
.globl vector71
vector71:
  pushl $0
80106c74:	6a 00                	push   $0x0
  pushl $71
80106c76:	6a 47                	push   $0x47
  jmp alltraps
80106c78:	e9 3d f6 ff ff       	jmp    801062ba <alltraps>

80106c7d <vector72>:
.globl vector72
vector72:
  pushl $0
80106c7d:	6a 00                	push   $0x0
  pushl $72
80106c7f:	6a 48                	push   $0x48
  jmp alltraps
80106c81:	e9 34 f6 ff ff       	jmp    801062ba <alltraps>

80106c86 <vector73>:
.globl vector73
vector73:
  pushl $0
80106c86:	6a 00                	push   $0x0
  pushl $73
80106c88:	6a 49                	push   $0x49
  jmp alltraps
80106c8a:	e9 2b f6 ff ff       	jmp    801062ba <alltraps>

80106c8f <vector74>:
.globl vector74
vector74:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $74
80106c91:	6a 4a                	push   $0x4a
  jmp alltraps
80106c93:	e9 22 f6 ff ff       	jmp    801062ba <alltraps>

80106c98 <vector75>:
.globl vector75
vector75:
  pushl $0
80106c98:	6a 00                	push   $0x0
  pushl $75
80106c9a:	6a 4b                	push   $0x4b
  jmp alltraps
80106c9c:	e9 19 f6 ff ff       	jmp    801062ba <alltraps>

80106ca1 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ca1:	6a 00                	push   $0x0
  pushl $76
80106ca3:	6a 4c                	push   $0x4c
  jmp alltraps
80106ca5:	e9 10 f6 ff ff       	jmp    801062ba <alltraps>

80106caa <vector77>:
.globl vector77
vector77:
  pushl $0
80106caa:	6a 00                	push   $0x0
  pushl $77
80106cac:	6a 4d                	push   $0x4d
  jmp alltraps
80106cae:	e9 07 f6 ff ff       	jmp    801062ba <alltraps>

80106cb3 <vector78>:
.globl vector78
vector78:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $78
80106cb5:	6a 4e                	push   $0x4e
  jmp alltraps
80106cb7:	e9 fe f5 ff ff       	jmp    801062ba <alltraps>

80106cbc <vector79>:
.globl vector79
vector79:
  pushl $0
80106cbc:	6a 00                	push   $0x0
  pushl $79
80106cbe:	6a 4f                	push   $0x4f
  jmp alltraps
80106cc0:	e9 f5 f5 ff ff       	jmp    801062ba <alltraps>

80106cc5 <vector80>:
.globl vector80
vector80:
  pushl $0
80106cc5:	6a 00                	push   $0x0
  pushl $80
80106cc7:	6a 50                	push   $0x50
  jmp alltraps
80106cc9:	e9 ec f5 ff ff       	jmp    801062ba <alltraps>

80106cce <vector81>:
.globl vector81
vector81:
  pushl $0
80106cce:	6a 00                	push   $0x0
  pushl $81
80106cd0:	6a 51                	push   $0x51
  jmp alltraps
80106cd2:	e9 e3 f5 ff ff       	jmp    801062ba <alltraps>

80106cd7 <vector82>:
.globl vector82
vector82:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $82
80106cd9:	6a 52                	push   $0x52
  jmp alltraps
80106cdb:	e9 da f5 ff ff       	jmp    801062ba <alltraps>

80106ce0 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ce0:	6a 00                	push   $0x0
  pushl $83
80106ce2:	6a 53                	push   $0x53
  jmp alltraps
80106ce4:	e9 d1 f5 ff ff       	jmp    801062ba <alltraps>

80106ce9 <vector84>:
.globl vector84
vector84:
  pushl $0
80106ce9:	6a 00                	push   $0x0
  pushl $84
80106ceb:	6a 54                	push   $0x54
  jmp alltraps
80106ced:	e9 c8 f5 ff ff       	jmp    801062ba <alltraps>

80106cf2 <vector85>:
.globl vector85
vector85:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $85
80106cf4:	6a 55                	push   $0x55
  jmp alltraps
80106cf6:	e9 bf f5 ff ff       	jmp    801062ba <alltraps>

80106cfb <vector86>:
.globl vector86
vector86:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $86
80106cfd:	6a 56                	push   $0x56
  jmp alltraps
80106cff:	e9 b6 f5 ff ff       	jmp    801062ba <alltraps>

80106d04 <vector87>:
.globl vector87
vector87:
  pushl $0
80106d04:	6a 00                	push   $0x0
  pushl $87
80106d06:	6a 57                	push   $0x57
  jmp alltraps
80106d08:	e9 ad f5 ff ff       	jmp    801062ba <alltraps>

80106d0d <vector88>:
.globl vector88
vector88:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $88
80106d0f:	6a 58                	push   $0x58
  jmp alltraps
80106d11:	e9 a4 f5 ff ff       	jmp    801062ba <alltraps>

80106d16 <vector89>:
.globl vector89
vector89:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $89
80106d18:	6a 59                	push   $0x59
  jmp alltraps
80106d1a:	e9 9b f5 ff ff       	jmp    801062ba <alltraps>

80106d1f <vector90>:
.globl vector90
vector90:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $90
80106d21:	6a 5a                	push   $0x5a
  jmp alltraps
80106d23:	e9 92 f5 ff ff       	jmp    801062ba <alltraps>

80106d28 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d28:	6a 00                	push   $0x0
  pushl $91
80106d2a:	6a 5b                	push   $0x5b
  jmp alltraps
80106d2c:	e9 89 f5 ff ff       	jmp    801062ba <alltraps>

80106d31 <vector92>:
.globl vector92
vector92:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $92
80106d33:	6a 5c                	push   $0x5c
  jmp alltraps
80106d35:	e9 80 f5 ff ff       	jmp    801062ba <alltraps>

80106d3a <vector93>:
.globl vector93
vector93:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $93
80106d3c:	6a 5d                	push   $0x5d
  jmp alltraps
80106d3e:	e9 77 f5 ff ff       	jmp    801062ba <alltraps>

80106d43 <vector94>:
.globl vector94
vector94:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $94
80106d45:	6a 5e                	push   $0x5e
  jmp alltraps
80106d47:	e9 6e f5 ff ff       	jmp    801062ba <alltraps>

80106d4c <vector95>:
.globl vector95
vector95:
  pushl $0
80106d4c:	6a 00                	push   $0x0
  pushl $95
80106d4e:	6a 5f                	push   $0x5f
  jmp alltraps
80106d50:	e9 65 f5 ff ff       	jmp    801062ba <alltraps>

80106d55 <vector96>:
.globl vector96
vector96:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $96
80106d57:	6a 60                	push   $0x60
  jmp alltraps
80106d59:	e9 5c f5 ff ff       	jmp    801062ba <alltraps>

80106d5e <vector97>:
.globl vector97
vector97:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $97
80106d60:	6a 61                	push   $0x61
  jmp alltraps
80106d62:	e9 53 f5 ff ff       	jmp    801062ba <alltraps>

80106d67 <vector98>:
.globl vector98
vector98:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $98
80106d69:	6a 62                	push   $0x62
  jmp alltraps
80106d6b:	e9 4a f5 ff ff       	jmp    801062ba <alltraps>

80106d70 <vector99>:
.globl vector99
vector99:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $99
80106d72:	6a 63                	push   $0x63
  jmp alltraps
80106d74:	e9 41 f5 ff ff       	jmp    801062ba <alltraps>

80106d79 <vector100>:
.globl vector100
vector100:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $100
80106d7b:	6a 64                	push   $0x64
  jmp alltraps
80106d7d:	e9 38 f5 ff ff       	jmp    801062ba <alltraps>

80106d82 <vector101>:
.globl vector101
vector101:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $101
80106d84:	6a 65                	push   $0x65
  jmp alltraps
80106d86:	e9 2f f5 ff ff       	jmp    801062ba <alltraps>

80106d8b <vector102>:
.globl vector102
vector102:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $102
80106d8d:	6a 66                	push   $0x66
  jmp alltraps
80106d8f:	e9 26 f5 ff ff       	jmp    801062ba <alltraps>

80106d94 <vector103>:
.globl vector103
vector103:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $103
80106d96:	6a 67                	push   $0x67
  jmp alltraps
80106d98:	e9 1d f5 ff ff       	jmp    801062ba <alltraps>

80106d9d <vector104>:
.globl vector104
vector104:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $104
80106d9f:	6a 68                	push   $0x68
  jmp alltraps
80106da1:	e9 14 f5 ff ff       	jmp    801062ba <alltraps>

80106da6 <vector105>:
.globl vector105
vector105:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $105
80106da8:	6a 69                	push   $0x69
  jmp alltraps
80106daa:	e9 0b f5 ff ff       	jmp    801062ba <alltraps>

80106daf <vector106>:
.globl vector106
vector106:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $106
80106db1:	6a 6a                	push   $0x6a
  jmp alltraps
80106db3:	e9 02 f5 ff ff       	jmp    801062ba <alltraps>

80106db8 <vector107>:
.globl vector107
vector107:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $107
80106dba:	6a 6b                	push   $0x6b
  jmp alltraps
80106dbc:	e9 f9 f4 ff ff       	jmp    801062ba <alltraps>

80106dc1 <vector108>:
.globl vector108
vector108:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $108
80106dc3:	6a 6c                	push   $0x6c
  jmp alltraps
80106dc5:	e9 f0 f4 ff ff       	jmp    801062ba <alltraps>

80106dca <vector109>:
.globl vector109
vector109:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $109
80106dcc:	6a 6d                	push   $0x6d
  jmp alltraps
80106dce:	e9 e7 f4 ff ff       	jmp    801062ba <alltraps>

80106dd3 <vector110>:
.globl vector110
vector110:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $110
80106dd5:	6a 6e                	push   $0x6e
  jmp alltraps
80106dd7:	e9 de f4 ff ff       	jmp    801062ba <alltraps>

80106ddc <vector111>:
.globl vector111
vector111:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $111
80106dde:	6a 6f                	push   $0x6f
  jmp alltraps
80106de0:	e9 d5 f4 ff ff       	jmp    801062ba <alltraps>

80106de5 <vector112>:
.globl vector112
vector112:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $112
80106de7:	6a 70                	push   $0x70
  jmp alltraps
80106de9:	e9 cc f4 ff ff       	jmp    801062ba <alltraps>

80106dee <vector113>:
.globl vector113
vector113:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $113
80106df0:	6a 71                	push   $0x71
  jmp alltraps
80106df2:	e9 c3 f4 ff ff       	jmp    801062ba <alltraps>

80106df7 <vector114>:
.globl vector114
vector114:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $114
80106df9:	6a 72                	push   $0x72
  jmp alltraps
80106dfb:	e9 ba f4 ff ff       	jmp    801062ba <alltraps>

80106e00 <vector115>:
.globl vector115
vector115:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $115
80106e02:	6a 73                	push   $0x73
  jmp alltraps
80106e04:	e9 b1 f4 ff ff       	jmp    801062ba <alltraps>

80106e09 <vector116>:
.globl vector116
vector116:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $116
80106e0b:	6a 74                	push   $0x74
  jmp alltraps
80106e0d:	e9 a8 f4 ff ff       	jmp    801062ba <alltraps>

80106e12 <vector117>:
.globl vector117
vector117:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $117
80106e14:	6a 75                	push   $0x75
  jmp alltraps
80106e16:	e9 9f f4 ff ff       	jmp    801062ba <alltraps>

80106e1b <vector118>:
.globl vector118
vector118:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $118
80106e1d:	6a 76                	push   $0x76
  jmp alltraps
80106e1f:	e9 96 f4 ff ff       	jmp    801062ba <alltraps>

80106e24 <vector119>:
.globl vector119
vector119:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $119
80106e26:	6a 77                	push   $0x77
  jmp alltraps
80106e28:	e9 8d f4 ff ff       	jmp    801062ba <alltraps>

80106e2d <vector120>:
.globl vector120
vector120:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $120
80106e2f:	6a 78                	push   $0x78
  jmp alltraps
80106e31:	e9 84 f4 ff ff       	jmp    801062ba <alltraps>

80106e36 <vector121>:
.globl vector121
vector121:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $121
80106e38:	6a 79                	push   $0x79
  jmp alltraps
80106e3a:	e9 7b f4 ff ff       	jmp    801062ba <alltraps>

80106e3f <vector122>:
.globl vector122
vector122:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $122
80106e41:	6a 7a                	push   $0x7a
  jmp alltraps
80106e43:	e9 72 f4 ff ff       	jmp    801062ba <alltraps>

80106e48 <vector123>:
.globl vector123
vector123:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $123
80106e4a:	6a 7b                	push   $0x7b
  jmp alltraps
80106e4c:	e9 69 f4 ff ff       	jmp    801062ba <alltraps>

80106e51 <vector124>:
.globl vector124
vector124:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $124
80106e53:	6a 7c                	push   $0x7c
  jmp alltraps
80106e55:	e9 60 f4 ff ff       	jmp    801062ba <alltraps>

80106e5a <vector125>:
.globl vector125
vector125:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $125
80106e5c:	6a 7d                	push   $0x7d
  jmp alltraps
80106e5e:	e9 57 f4 ff ff       	jmp    801062ba <alltraps>

80106e63 <vector126>:
.globl vector126
vector126:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $126
80106e65:	6a 7e                	push   $0x7e
  jmp alltraps
80106e67:	e9 4e f4 ff ff       	jmp    801062ba <alltraps>

80106e6c <vector127>:
.globl vector127
vector127:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $127
80106e6e:	6a 7f                	push   $0x7f
  jmp alltraps
80106e70:	e9 45 f4 ff ff       	jmp    801062ba <alltraps>

80106e75 <vector128>:
.globl vector128
vector128:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $128
80106e77:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106e7c:	e9 39 f4 ff ff       	jmp    801062ba <alltraps>

80106e81 <vector129>:
.globl vector129
vector129:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $129
80106e83:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e88:	e9 2d f4 ff ff       	jmp    801062ba <alltraps>

80106e8d <vector130>:
.globl vector130
vector130:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $130
80106e8f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e94:	e9 21 f4 ff ff       	jmp    801062ba <alltraps>

80106e99 <vector131>:
.globl vector131
vector131:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $131
80106e9b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ea0:	e9 15 f4 ff ff       	jmp    801062ba <alltraps>

80106ea5 <vector132>:
.globl vector132
vector132:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $132
80106ea7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106eac:	e9 09 f4 ff ff       	jmp    801062ba <alltraps>

80106eb1 <vector133>:
.globl vector133
vector133:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $133
80106eb3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106eb8:	e9 fd f3 ff ff       	jmp    801062ba <alltraps>

80106ebd <vector134>:
.globl vector134
vector134:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $134
80106ebf:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106ec4:	e9 f1 f3 ff ff       	jmp    801062ba <alltraps>

80106ec9 <vector135>:
.globl vector135
vector135:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $135
80106ecb:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ed0:	e9 e5 f3 ff ff       	jmp    801062ba <alltraps>

80106ed5 <vector136>:
.globl vector136
vector136:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $136
80106ed7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106edc:	e9 d9 f3 ff ff       	jmp    801062ba <alltraps>

80106ee1 <vector137>:
.globl vector137
vector137:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $137
80106ee3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106ee8:	e9 cd f3 ff ff       	jmp    801062ba <alltraps>

80106eed <vector138>:
.globl vector138
vector138:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $138
80106eef:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ef4:	e9 c1 f3 ff ff       	jmp    801062ba <alltraps>

80106ef9 <vector139>:
.globl vector139
vector139:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $139
80106efb:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f00:	e9 b5 f3 ff ff       	jmp    801062ba <alltraps>

80106f05 <vector140>:
.globl vector140
vector140:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $140
80106f07:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f0c:	e9 a9 f3 ff ff       	jmp    801062ba <alltraps>

80106f11 <vector141>:
.globl vector141
vector141:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $141
80106f13:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f18:	e9 9d f3 ff ff       	jmp    801062ba <alltraps>

80106f1d <vector142>:
.globl vector142
vector142:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $142
80106f1f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f24:	e9 91 f3 ff ff       	jmp    801062ba <alltraps>

80106f29 <vector143>:
.globl vector143
vector143:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $143
80106f2b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f30:	e9 85 f3 ff ff       	jmp    801062ba <alltraps>

80106f35 <vector144>:
.globl vector144
vector144:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $144
80106f37:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f3c:	e9 79 f3 ff ff       	jmp    801062ba <alltraps>

80106f41 <vector145>:
.globl vector145
vector145:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $145
80106f43:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f48:	e9 6d f3 ff ff       	jmp    801062ba <alltraps>

80106f4d <vector146>:
.globl vector146
vector146:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $146
80106f4f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f54:	e9 61 f3 ff ff       	jmp    801062ba <alltraps>

80106f59 <vector147>:
.globl vector147
vector147:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $147
80106f5b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106f60:	e9 55 f3 ff ff       	jmp    801062ba <alltraps>

80106f65 <vector148>:
.globl vector148
vector148:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $148
80106f67:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106f6c:	e9 49 f3 ff ff       	jmp    801062ba <alltraps>

80106f71 <vector149>:
.globl vector149
vector149:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $149
80106f73:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106f78:	e9 3d f3 ff ff       	jmp    801062ba <alltraps>

80106f7d <vector150>:
.globl vector150
vector150:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $150
80106f7f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106f84:	e9 31 f3 ff ff       	jmp    801062ba <alltraps>

80106f89 <vector151>:
.globl vector151
vector151:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $151
80106f8b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f90:	e9 25 f3 ff ff       	jmp    801062ba <alltraps>

80106f95 <vector152>:
.globl vector152
vector152:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $152
80106f97:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f9c:	e9 19 f3 ff ff       	jmp    801062ba <alltraps>

80106fa1 <vector153>:
.globl vector153
vector153:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $153
80106fa3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106fa8:	e9 0d f3 ff ff       	jmp    801062ba <alltraps>

80106fad <vector154>:
.globl vector154
vector154:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $154
80106faf:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106fb4:	e9 01 f3 ff ff       	jmp    801062ba <alltraps>

80106fb9 <vector155>:
.globl vector155
vector155:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $155
80106fbb:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106fc0:	e9 f5 f2 ff ff       	jmp    801062ba <alltraps>

80106fc5 <vector156>:
.globl vector156
vector156:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $156
80106fc7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106fcc:	e9 e9 f2 ff ff       	jmp    801062ba <alltraps>

80106fd1 <vector157>:
.globl vector157
vector157:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $157
80106fd3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106fd8:	e9 dd f2 ff ff       	jmp    801062ba <alltraps>

80106fdd <vector158>:
.globl vector158
vector158:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $158
80106fdf:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106fe4:	e9 d1 f2 ff ff       	jmp    801062ba <alltraps>

80106fe9 <vector159>:
.globl vector159
vector159:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $159
80106feb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ff0:	e9 c5 f2 ff ff       	jmp    801062ba <alltraps>

80106ff5 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $160
80106ff7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ffc:	e9 b9 f2 ff ff       	jmp    801062ba <alltraps>

80107001 <vector161>:
.globl vector161
vector161:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $161
80107003:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107008:	e9 ad f2 ff ff       	jmp    801062ba <alltraps>

8010700d <vector162>:
.globl vector162
vector162:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $162
8010700f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107014:	e9 a1 f2 ff ff       	jmp    801062ba <alltraps>

80107019 <vector163>:
.globl vector163
vector163:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $163
8010701b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107020:	e9 95 f2 ff ff       	jmp    801062ba <alltraps>

80107025 <vector164>:
.globl vector164
vector164:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $164
80107027:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010702c:	e9 89 f2 ff ff       	jmp    801062ba <alltraps>

80107031 <vector165>:
.globl vector165
vector165:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $165
80107033:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107038:	e9 7d f2 ff ff       	jmp    801062ba <alltraps>

8010703d <vector166>:
.globl vector166
vector166:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $166
8010703f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107044:	e9 71 f2 ff ff       	jmp    801062ba <alltraps>

80107049 <vector167>:
.globl vector167
vector167:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $167
8010704b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107050:	e9 65 f2 ff ff       	jmp    801062ba <alltraps>

80107055 <vector168>:
.globl vector168
vector168:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $168
80107057:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010705c:	e9 59 f2 ff ff       	jmp    801062ba <alltraps>

80107061 <vector169>:
.globl vector169
vector169:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $169
80107063:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107068:	e9 4d f2 ff ff       	jmp    801062ba <alltraps>

8010706d <vector170>:
.globl vector170
vector170:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $170
8010706f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107074:	e9 41 f2 ff ff       	jmp    801062ba <alltraps>

80107079 <vector171>:
.globl vector171
vector171:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $171
8010707b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107080:	e9 35 f2 ff ff       	jmp    801062ba <alltraps>

80107085 <vector172>:
.globl vector172
vector172:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $172
80107087:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010708c:	e9 29 f2 ff ff       	jmp    801062ba <alltraps>

80107091 <vector173>:
.globl vector173
vector173:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $173
80107093:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107098:	e9 1d f2 ff ff       	jmp    801062ba <alltraps>

8010709d <vector174>:
.globl vector174
vector174:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $174
8010709f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801070a4:	e9 11 f2 ff ff       	jmp    801062ba <alltraps>

801070a9 <vector175>:
.globl vector175
vector175:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $175
801070ab:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801070b0:	e9 05 f2 ff ff       	jmp    801062ba <alltraps>

801070b5 <vector176>:
.globl vector176
vector176:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $176
801070b7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801070bc:	e9 f9 f1 ff ff       	jmp    801062ba <alltraps>

801070c1 <vector177>:
.globl vector177
vector177:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $177
801070c3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801070c8:	e9 ed f1 ff ff       	jmp    801062ba <alltraps>

801070cd <vector178>:
.globl vector178
vector178:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $178
801070cf:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801070d4:	e9 e1 f1 ff ff       	jmp    801062ba <alltraps>

801070d9 <vector179>:
.globl vector179
vector179:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $179
801070db:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801070e0:	e9 d5 f1 ff ff       	jmp    801062ba <alltraps>

801070e5 <vector180>:
.globl vector180
vector180:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $180
801070e7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801070ec:	e9 c9 f1 ff ff       	jmp    801062ba <alltraps>

801070f1 <vector181>:
.globl vector181
vector181:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $181
801070f3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801070f8:	e9 bd f1 ff ff       	jmp    801062ba <alltraps>

801070fd <vector182>:
.globl vector182
vector182:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $182
801070ff:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107104:	e9 b1 f1 ff ff       	jmp    801062ba <alltraps>

80107109 <vector183>:
.globl vector183
vector183:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $183
8010710b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107110:	e9 a5 f1 ff ff       	jmp    801062ba <alltraps>

80107115 <vector184>:
.globl vector184
vector184:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $184
80107117:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010711c:	e9 99 f1 ff ff       	jmp    801062ba <alltraps>

80107121 <vector185>:
.globl vector185
vector185:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $185
80107123:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107128:	e9 8d f1 ff ff       	jmp    801062ba <alltraps>

8010712d <vector186>:
.globl vector186
vector186:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $186
8010712f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107134:	e9 81 f1 ff ff       	jmp    801062ba <alltraps>

80107139 <vector187>:
.globl vector187
vector187:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $187
8010713b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107140:	e9 75 f1 ff ff       	jmp    801062ba <alltraps>

80107145 <vector188>:
.globl vector188
vector188:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $188
80107147:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010714c:	e9 69 f1 ff ff       	jmp    801062ba <alltraps>

80107151 <vector189>:
.globl vector189
vector189:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $189
80107153:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107158:	e9 5d f1 ff ff       	jmp    801062ba <alltraps>

8010715d <vector190>:
.globl vector190
vector190:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $190
8010715f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107164:	e9 51 f1 ff ff       	jmp    801062ba <alltraps>

80107169 <vector191>:
.globl vector191
vector191:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $191
8010716b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107170:	e9 45 f1 ff ff       	jmp    801062ba <alltraps>

80107175 <vector192>:
.globl vector192
vector192:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $192
80107177:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010717c:	e9 39 f1 ff ff       	jmp    801062ba <alltraps>

80107181 <vector193>:
.globl vector193
vector193:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $193
80107183:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107188:	e9 2d f1 ff ff       	jmp    801062ba <alltraps>

8010718d <vector194>:
.globl vector194
vector194:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $194
8010718f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107194:	e9 21 f1 ff ff       	jmp    801062ba <alltraps>

80107199 <vector195>:
.globl vector195
vector195:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $195
8010719b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801071a0:	e9 15 f1 ff ff       	jmp    801062ba <alltraps>

801071a5 <vector196>:
.globl vector196
vector196:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $196
801071a7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801071ac:	e9 09 f1 ff ff       	jmp    801062ba <alltraps>

801071b1 <vector197>:
.globl vector197
vector197:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $197
801071b3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801071b8:	e9 fd f0 ff ff       	jmp    801062ba <alltraps>

801071bd <vector198>:
.globl vector198
vector198:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $198
801071bf:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801071c4:	e9 f1 f0 ff ff       	jmp    801062ba <alltraps>

801071c9 <vector199>:
.globl vector199
vector199:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $199
801071cb:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801071d0:	e9 e5 f0 ff ff       	jmp    801062ba <alltraps>

801071d5 <vector200>:
.globl vector200
vector200:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $200
801071d7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801071dc:	e9 d9 f0 ff ff       	jmp    801062ba <alltraps>

801071e1 <vector201>:
.globl vector201
vector201:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $201
801071e3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801071e8:	e9 cd f0 ff ff       	jmp    801062ba <alltraps>

801071ed <vector202>:
.globl vector202
vector202:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $202
801071ef:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801071f4:	e9 c1 f0 ff ff       	jmp    801062ba <alltraps>

801071f9 <vector203>:
.globl vector203
vector203:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $203
801071fb:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107200:	e9 b5 f0 ff ff       	jmp    801062ba <alltraps>

80107205 <vector204>:
.globl vector204
vector204:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $204
80107207:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010720c:	e9 a9 f0 ff ff       	jmp    801062ba <alltraps>

80107211 <vector205>:
.globl vector205
vector205:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $205
80107213:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107218:	e9 9d f0 ff ff       	jmp    801062ba <alltraps>

8010721d <vector206>:
.globl vector206
vector206:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $206
8010721f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107224:	e9 91 f0 ff ff       	jmp    801062ba <alltraps>

80107229 <vector207>:
.globl vector207
vector207:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $207
8010722b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107230:	e9 85 f0 ff ff       	jmp    801062ba <alltraps>

80107235 <vector208>:
.globl vector208
vector208:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $208
80107237:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010723c:	e9 79 f0 ff ff       	jmp    801062ba <alltraps>

80107241 <vector209>:
.globl vector209
vector209:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $209
80107243:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107248:	e9 6d f0 ff ff       	jmp    801062ba <alltraps>

8010724d <vector210>:
.globl vector210
vector210:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $210
8010724f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107254:	e9 61 f0 ff ff       	jmp    801062ba <alltraps>

80107259 <vector211>:
.globl vector211
vector211:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $211
8010725b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107260:	e9 55 f0 ff ff       	jmp    801062ba <alltraps>

80107265 <vector212>:
.globl vector212
vector212:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $212
80107267:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010726c:	e9 49 f0 ff ff       	jmp    801062ba <alltraps>

80107271 <vector213>:
.globl vector213
vector213:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $213
80107273:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107278:	e9 3d f0 ff ff       	jmp    801062ba <alltraps>

8010727d <vector214>:
.globl vector214
vector214:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $214
8010727f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107284:	e9 31 f0 ff ff       	jmp    801062ba <alltraps>

80107289 <vector215>:
.globl vector215
vector215:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $215
8010728b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107290:	e9 25 f0 ff ff       	jmp    801062ba <alltraps>

80107295 <vector216>:
.globl vector216
vector216:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $216
80107297:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010729c:	e9 19 f0 ff ff       	jmp    801062ba <alltraps>

801072a1 <vector217>:
.globl vector217
vector217:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $217
801072a3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801072a8:	e9 0d f0 ff ff       	jmp    801062ba <alltraps>

801072ad <vector218>:
.globl vector218
vector218:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $218
801072af:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801072b4:	e9 01 f0 ff ff       	jmp    801062ba <alltraps>

801072b9 <vector219>:
.globl vector219
vector219:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $219
801072bb:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801072c0:	e9 f5 ef ff ff       	jmp    801062ba <alltraps>

801072c5 <vector220>:
.globl vector220
vector220:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $220
801072c7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801072cc:	e9 e9 ef ff ff       	jmp    801062ba <alltraps>

801072d1 <vector221>:
.globl vector221
vector221:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $221
801072d3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801072d8:	e9 dd ef ff ff       	jmp    801062ba <alltraps>

801072dd <vector222>:
.globl vector222
vector222:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $222
801072df:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801072e4:	e9 d1 ef ff ff       	jmp    801062ba <alltraps>

801072e9 <vector223>:
.globl vector223
vector223:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $223
801072eb:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801072f0:	e9 c5 ef ff ff       	jmp    801062ba <alltraps>

801072f5 <vector224>:
.globl vector224
vector224:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $224
801072f7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801072fc:	e9 b9 ef ff ff       	jmp    801062ba <alltraps>

80107301 <vector225>:
.globl vector225
vector225:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $225
80107303:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107308:	e9 ad ef ff ff       	jmp    801062ba <alltraps>

8010730d <vector226>:
.globl vector226
vector226:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $226
8010730f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107314:	e9 a1 ef ff ff       	jmp    801062ba <alltraps>

80107319 <vector227>:
.globl vector227
vector227:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $227
8010731b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107320:	e9 95 ef ff ff       	jmp    801062ba <alltraps>

80107325 <vector228>:
.globl vector228
vector228:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $228
80107327:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010732c:	e9 89 ef ff ff       	jmp    801062ba <alltraps>

80107331 <vector229>:
.globl vector229
vector229:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $229
80107333:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107338:	e9 7d ef ff ff       	jmp    801062ba <alltraps>

8010733d <vector230>:
.globl vector230
vector230:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $230
8010733f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107344:	e9 71 ef ff ff       	jmp    801062ba <alltraps>

80107349 <vector231>:
.globl vector231
vector231:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $231
8010734b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107350:	e9 65 ef ff ff       	jmp    801062ba <alltraps>

80107355 <vector232>:
.globl vector232
vector232:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $232
80107357:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010735c:	e9 59 ef ff ff       	jmp    801062ba <alltraps>

80107361 <vector233>:
.globl vector233
vector233:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $233
80107363:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107368:	e9 4d ef ff ff       	jmp    801062ba <alltraps>

8010736d <vector234>:
.globl vector234
vector234:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $234
8010736f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107374:	e9 41 ef ff ff       	jmp    801062ba <alltraps>

80107379 <vector235>:
.globl vector235
vector235:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $235
8010737b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107380:	e9 35 ef ff ff       	jmp    801062ba <alltraps>

80107385 <vector236>:
.globl vector236
vector236:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $236
80107387:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010738c:	e9 29 ef ff ff       	jmp    801062ba <alltraps>

80107391 <vector237>:
.globl vector237
vector237:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $237
80107393:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107398:	e9 1d ef ff ff       	jmp    801062ba <alltraps>

8010739d <vector238>:
.globl vector238
vector238:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $238
8010739f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801073a4:	e9 11 ef ff ff       	jmp    801062ba <alltraps>

801073a9 <vector239>:
.globl vector239
vector239:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $239
801073ab:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801073b0:	e9 05 ef ff ff       	jmp    801062ba <alltraps>

801073b5 <vector240>:
.globl vector240
vector240:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $240
801073b7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801073bc:	e9 f9 ee ff ff       	jmp    801062ba <alltraps>

801073c1 <vector241>:
.globl vector241
vector241:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $241
801073c3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801073c8:	e9 ed ee ff ff       	jmp    801062ba <alltraps>

801073cd <vector242>:
.globl vector242
vector242:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $242
801073cf:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801073d4:	e9 e1 ee ff ff       	jmp    801062ba <alltraps>

801073d9 <vector243>:
.globl vector243
vector243:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $243
801073db:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801073e0:	e9 d5 ee ff ff       	jmp    801062ba <alltraps>

801073e5 <vector244>:
.globl vector244
vector244:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $244
801073e7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801073ec:	e9 c9 ee ff ff       	jmp    801062ba <alltraps>

801073f1 <vector245>:
.globl vector245
vector245:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $245
801073f3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801073f8:	e9 bd ee ff ff       	jmp    801062ba <alltraps>

801073fd <vector246>:
.globl vector246
vector246:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $246
801073ff:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107404:	e9 b1 ee ff ff       	jmp    801062ba <alltraps>

80107409 <vector247>:
.globl vector247
vector247:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $247
8010740b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107410:	e9 a5 ee ff ff       	jmp    801062ba <alltraps>

80107415 <vector248>:
.globl vector248
vector248:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $248
80107417:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010741c:	e9 99 ee ff ff       	jmp    801062ba <alltraps>

80107421 <vector249>:
.globl vector249
vector249:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $249
80107423:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107428:	e9 8d ee ff ff       	jmp    801062ba <alltraps>

8010742d <vector250>:
.globl vector250
vector250:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $250
8010742f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107434:	e9 81 ee ff ff       	jmp    801062ba <alltraps>

80107439 <vector251>:
.globl vector251
vector251:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $251
8010743b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107440:	e9 75 ee ff ff       	jmp    801062ba <alltraps>

80107445 <vector252>:
.globl vector252
vector252:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $252
80107447:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010744c:	e9 69 ee ff ff       	jmp    801062ba <alltraps>

80107451 <vector253>:
.globl vector253
vector253:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $253
80107453:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107458:	e9 5d ee ff ff       	jmp    801062ba <alltraps>

8010745d <vector254>:
.globl vector254
vector254:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $254
8010745f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107464:	e9 51 ee ff ff       	jmp    801062ba <alltraps>

80107469 <vector255>:
.globl vector255
vector255:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $255
8010746b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107470:	e9 45 ee ff ff       	jmp    801062ba <alltraps>

80107475 <lgdt>:
{
80107475:	55                   	push   %ebp
80107476:	89 e5                	mov    %esp,%ebp
80107478:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010747b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010747e:	83 e8 01             	sub    $0x1,%eax
80107481:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107485:	8b 45 08             	mov    0x8(%ebp),%eax
80107488:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010748c:	8b 45 08             	mov    0x8(%ebp),%eax
8010748f:	c1 e8 10             	shr    $0x10,%eax
80107492:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107496:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107499:	0f 01 10             	lgdtl  (%eax)
}
8010749c:	90                   	nop
8010749d:	c9                   	leave
8010749e:	c3                   	ret

8010749f <ltr>:
{
8010749f:	55                   	push   %ebp
801074a0:	89 e5                	mov    %esp,%ebp
801074a2:	83 ec 04             	sub    $0x4,%esp
801074a5:	8b 45 08             	mov    0x8(%ebp),%eax
801074a8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801074ac:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801074b0:	0f 00 d8             	ltr    %eax
}
801074b3:	90                   	nop
801074b4:	c9                   	leave
801074b5:	c3                   	ret

801074b6 <lcr3>:

static inline void
lcr3(uint val)
{
801074b6:	55                   	push   %ebp
801074b7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074b9:	8b 45 08             	mov    0x8(%ebp),%eax
801074bc:	0f 22 d8             	mov    %eax,%cr3
}
801074bf:	90                   	nop
801074c0:	5d                   	pop    %ebp
801074c1:	c3                   	ret

801074c2 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801074c2:	f3 0f 1e fb          	endbr32
801074c6:	55                   	push   %ebp
801074c7:	89 e5                	mov    %esp,%ebp
801074c9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801074cc:	e8 aa c6 ff ff       	call   80103b7b <cpuid>
801074d1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801074d7:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801074dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801074df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801074e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074eb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801074f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801074f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074ff:	83 e2 f0             	and    $0xfffffff0,%edx
80107502:	83 ca 0a             	or     $0xa,%edx
80107505:	88 50 7d             	mov    %dl,0x7d(%eax)
80107508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010750f:	83 ca 10             	or     $0x10,%edx
80107512:	88 50 7d             	mov    %dl,0x7d(%eax)
80107515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107518:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010751c:	83 e2 9f             	and    $0xffffff9f,%edx
8010751f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107525:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107529:	83 ca 80             	or     $0xffffff80,%edx
8010752c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010752f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107532:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107536:	83 ca 0f             	or     $0xf,%edx
80107539:	88 50 7e             	mov    %dl,0x7e(%eax)
8010753c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107543:	83 e2 ef             	and    $0xffffffef,%edx
80107546:	88 50 7e             	mov    %dl,0x7e(%eax)
80107549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107550:	83 e2 df             	and    $0xffffffdf,%edx
80107553:	88 50 7e             	mov    %dl,0x7e(%eax)
80107556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107559:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010755d:	83 ca 40             	or     $0x40,%edx
80107560:	88 50 7e             	mov    %dl,0x7e(%eax)
80107563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107566:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010756a:	83 ca 80             	or     $0xffffff80,%edx
8010756d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107573:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107581:	ff ff 
80107583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107586:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010758d:	00 00 
8010758f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107592:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075a3:	83 e2 f0             	and    $0xfffffff0,%edx
801075a6:	83 ca 02             	or     $0x2,%edx
801075a9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075b9:	83 ca 10             	or     $0x10,%edx
801075bc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075cc:	83 e2 9f             	and    $0xffffff9f,%edx
801075cf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075df:	83 ca 80             	or     $0xffffff80,%edx
801075e2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075eb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075f2:	83 ca 0f             	or     $0xf,%edx
801075f5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fe:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107605:	83 e2 ef             	and    $0xffffffef,%edx
80107608:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010760e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107611:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107618:	83 e2 df             	and    $0xffffffdf,%edx
8010761b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107624:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010762b:	83 ca 40             	or     $0x40,%edx
8010762e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107637:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010763e:	83 ca 80             	or     $0xffffff80,%edx
80107641:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107654:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010765b:	ff ff 
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107667:	00 00 
80107669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107676:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010767d:	83 e2 f0             	and    $0xfffffff0,%edx
80107680:	83 ca 0a             	or     $0xa,%edx
80107683:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107693:	83 ca 10             	or     $0x10,%edx
80107696:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010769c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076a6:	83 ca 60             	or     $0x60,%edx
801076a9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076b9:	83 ca 80             	or     $0xffffff80,%edx
801076bc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076cc:	83 ca 0f             	or     $0xf,%edx
801076cf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076df:	83 e2 ef             	and    $0xffffffef,%edx
801076e2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076f2:	83 e2 df             	and    $0xffffffdf,%edx
801076f5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107705:	83 ca 40             	or     $0x40,%edx
80107708:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010770e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107711:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107718:	83 ca 80             	or     $0xffffff80,%edx
8010771b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107724:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010772b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107735:	ff ff 
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107741:	00 00 
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010774d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107750:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107757:	83 e2 f0             	and    $0xfffffff0,%edx
8010775a:	83 ca 02             	or     $0x2,%edx
8010775d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010776d:	83 ca 10             	or     $0x10,%edx
80107770:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107779:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107780:	83 ca 60             	or     $0x60,%edx
80107783:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107793:	83 ca 80             	or     $0xffffff80,%edx
80107796:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010779c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077a6:	83 ca 0f             	or     $0xf,%edx
801077a9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077b9:	83 e2 ef             	and    $0xffffffef,%edx
801077bc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077cc:	83 e2 df             	and    $0xffffffdf,%edx
801077cf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077df:	83 ca 40             	or     $0x40,%edx
801077e2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077f2:	83 ca 80             	or     $0xffffff80,%edx
801077f5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fe:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	83 c0 70             	add    $0x70,%eax
8010780b:	83 ec 08             	sub    $0x8,%esp
8010780e:	6a 30                	push   $0x30
80107810:	50                   	push   %eax
80107811:	e8 5f fc ff ff       	call   80107475 <lgdt>
80107816:	83 c4 10             	add    $0x10,%esp
}
80107819:	90                   	nop
8010781a:	c9                   	leave
8010781b:	c3                   	ret

8010781c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010781c:	f3 0f 1e fb          	endbr32
80107820:	55                   	push   %ebp
80107821:	89 e5                	mov    %esp,%ebp
80107823:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107826:	8b 45 0c             	mov    0xc(%ebp),%eax
80107829:	c1 e8 16             	shr    $0x16,%eax
8010782c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107833:	8b 45 08             	mov    0x8(%ebp),%eax
80107836:	01 d0                	add    %edx,%eax
80107838:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010783b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010783e:	8b 00                	mov    (%eax),%eax
80107840:	83 e0 01             	and    $0x1,%eax
80107843:	85 c0                	test   %eax,%eax
80107845:	74 14                	je     8010785b <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010784a:	8b 00                	mov    (%eax),%eax
8010784c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107851:	05 00 00 00 80       	add    $0x80000000,%eax
80107856:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107859:	eb 42                	jmp    8010789d <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010785b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010785f:	74 0e                	je     8010786f <walkpgdir+0x53>
80107861:	e8 99 b0 ff ff       	call   801028ff <kalloc>
80107866:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107869:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010786d:	75 07                	jne    80107876 <walkpgdir+0x5a>
      return 0;
8010786f:	b8 00 00 00 00       	mov    $0x0,%eax
80107874:	eb 3e                	jmp    801078b4 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107876:	83 ec 04             	sub    $0x4,%esp
80107879:	68 00 10 00 00       	push   $0x1000
8010787e:	6a 00                	push   $0x0
80107880:	ff 75 f4             	push   -0xc(%ebp)
80107883:	e8 b1 d4 ff ff       	call   80104d39 <memset>
80107888:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	05 00 00 00 80       	add    $0x80000000,%eax
80107893:	83 c8 07             	or     $0x7,%eax
80107896:	89 c2                	mov    %eax,%edx
80107898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010789b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010789d:	8b 45 0c             	mov    0xc(%ebp),%eax
801078a0:	c1 e8 0c             	shr    $0xc,%eax
801078a3:	25 ff 03 00 00       	and    $0x3ff,%eax
801078a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b2:	01 d0                	add    %edx,%eax
}
801078b4:	c9                   	leave
801078b5:	c3                   	ret

801078b6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078b6:	f3 0f 1e fb          	endbr32
801078ba:	55                   	push   %ebp
801078bb:	89 e5                	mov    %esp,%ebp
801078bd:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801078c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801078ce:	8b 45 10             	mov    0x10(%ebp),%eax
801078d1:	01 d0                	add    %edx,%eax
801078d3:	83 e8 01             	sub    $0x1,%eax
801078d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078de:	83 ec 04             	sub    $0x4,%esp
801078e1:	6a 01                	push   $0x1
801078e3:	ff 75 f4             	push   -0xc(%ebp)
801078e6:	ff 75 08             	push   0x8(%ebp)
801078e9:	e8 2e ff ff ff       	call   8010781c <walkpgdir>
801078ee:	83 c4 10             	add    $0x10,%esp
801078f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078f8:	75 07                	jne    80107901 <mappages+0x4b>
      return -1;
801078fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078ff:	eb 47                	jmp    80107948 <mappages+0x92>
    if(*pte & PTE_P)
80107901:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107904:	8b 00                	mov    (%eax),%eax
80107906:	83 e0 01             	and    $0x1,%eax
80107909:	85 c0                	test   %eax,%eax
8010790b:	74 0d                	je     8010791a <mappages+0x64>
      panic("remap");
8010790d:	83 ec 0c             	sub    $0xc,%esp
80107910:	68 94 ae 10 80       	push   $0x8010ae94
80107915:	e8 c4 8c ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
8010791a:	8b 45 18             	mov    0x18(%ebp),%eax
8010791d:	0b 45 14             	or     0x14(%ebp),%eax
80107920:	83 c8 01             	or     $0x1,%eax
80107923:	89 c2                	mov    %eax,%edx
80107925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107928:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107930:	74 10                	je     80107942 <mappages+0x8c>
      break;
    a += PGSIZE;
80107932:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107939:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107940:	eb 9c                	jmp    801078de <mappages+0x28>
      break;
80107942:	90                   	nop
  }
  return 0;
80107943:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107948:	c9                   	leave
80107949:	c3                   	ret

8010794a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010794a:	f3 0f 1e fb          	endbr32
8010794e:	55                   	push   %ebp
8010794f:	89 e5                	mov    %esp,%ebp
80107951:	53                   	push   %ebx
80107952:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107955:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010795c:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107961:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107966:	29 c2                	sub    %eax,%edx
80107968:	89 d0                	mov    %edx,%eax
8010796a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010796d:	a1 84 80 19 80       	mov    0x80198084,%eax
80107972:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107975:	8b 15 84 80 19 80    	mov    0x80198084,%edx
8010797b:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107980:	01 d0                	add    %edx,%eax
80107982:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107985:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010798c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798f:	83 c0 30             	add    $0x30,%eax
80107992:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107995:	89 10                	mov    %edx,(%eax)
80107997:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010799a:	89 50 04             	mov    %edx,0x4(%eax)
8010799d:	8b 55 e8             	mov    -0x18(%ebp),%edx
801079a0:	89 50 08             	mov    %edx,0x8(%eax)
801079a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801079a6:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801079a9:	e8 51 af ff ff       	call   801028ff <kalloc>
801079ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079b5:	75 07                	jne    801079be <setupkvm+0x74>
    return 0;
801079b7:	b8 00 00 00 00       	mov    $0x0,%eax
801079bc:	eb 78                	jmp    80107a36 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801079be:	83 ec 04             	sub    $0x4,%esp
801079c1:	68 00 10 00 00       	push   $0x1000
801079c6:	6a 00                	push   $0x0
801079c8:	ff 75 f0             	push   -0x10(%ebp)
801079cb:	e8 69 d3 ff ff       	call   80104d39 <memset>
801079d0:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079d3:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801079da:	eb 4e                	jmp    80107a2a <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079df:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801079e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e5:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079eb:	8b 58 08             	mov    0x8(%eax),%ebx
801079ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f1:	8b 40 04             	mov    0x4(%eax),%eax
801079f4:	29 c3                	sub    %eax,%ebx
801079f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f9:	8b 00                	mov    (%eax),%eax
801079fb:	83 ec 0c             	sub    $0xc,%esp
801079fe:	51                   	push   %ecx
801079ff:	52                   	push   %edx
80107a00:	53                   	push   %ebx
80107a01:	50                   	push   %eax
80107a02:	ff 75 f0             	push   -0x10(%ebp)
80107a05:	e8 ac fe ff ff       	call   801078b6 <mappages>
80107a0a:	83 c4 20             	add    $0x20,%esp
80107a0d:	85 c0                	test   %eax,%eax
80107a0f:	79 15                	jns    80107a26 <setupkvm+0xdc>
      freevm(pgdir);
80107a11:	83 ec 0c             	sub    $0xc,%esp
80107a14:	ff 75 f0             	push   -0x10(%ebp)
80107a17:	e8 11 05 00 00       	call   80107f2d <freevm>
80107a1c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a1f:	b8 00 00 00 00       	mov    $0x0,%eax
80107a24:	eb 10                	jmp    80107a36 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a26:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a2a:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107a31:	72 a9                	jb     801079dc <setupkvm+0x92>
    }
  return pgdir;
80107a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a39:	c9                   	leave
80107a3a:	c3                   	ret

80107a3b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a3b:	f3 0f 1e fb          	endbr32
80107a3f:	55                   	push   %ebp
80107a40:	89 e5                	mov    %esp,%ebp
80107a42:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a45:	e8 00 ff ff ff       	call   8010794a <setupkvm>
80107a4a:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
80107a4f:	e8 03 00 00 00       	call   80107a57 <switchkvm>
}
80107a54:	90                   	nop
80107a55:	c9                   	leave
80107a56:	c3                   	ret

80107a57 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a57:	f3 0f 1e fb          	endbr32
80107a5b:	55                   	push   %ebp
80107a5c:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a5e:	a1 84 7d 19 80       	mov    0x80197d84,%eax
80107a63:	05 00 00 00 80       	add    $0x80000000,%eax
80107a68:	50                   	push   %eax
80107a69:	e8 48 fa ff ff       	call   801074b6 <lcr3>
80107a6e:	83 c4 04             	add    $0x4,%esp
}
80107a71:	90                   	nop
80107a72:	c9                   	leave
80107a73:	c3                   	ret

80107a74 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a74:	f3 0f 1e fb          	endbr32
80107a78:	55                   	push   %ebp
80107a79:	89 e5                	mov    %esp,%ebp
80107a7b:	56                   	push   %esi
80107a7c:	53                   	push   %ebx
80107a7d:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107a80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a84:	75 0d                	jne    80107a93 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107a86:	83 ec 0c             	sub    $0xc,%esp
80107a89:	68 9a ae 10 80       	push   $0x8010ae9a
80107a8e:	e8 4b 8b ff ff       	call   801005de <panic>
  if(p->kstack == 0)
80107a93:	8b 45 08             	mov    0x8(%ebp),%eax
80107a96:	8b 40 08             	mov    0x8(%eax),%eax
80107a99:	85 c0                	test   %eax,%eax
80107a9b:	75 0d                	jne    80107aaa <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107a9d:	83 ec 0c             	sub    $0xc,%esp
80107aa0:	68 b0 ae 10 80       	push   $0x8010aeb0
80107aa5:	e8 34 8b ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
80107aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80107aad:	8b 40 04             	mov    0x4(%eax),%eax
80107ab0:	85 c0                	test   %eax,%eax
80107ab2:	75 0d                	jne    80107ac1 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107ab4:	83 ec 0c             	sub    $0xc,%esp
80107ab7:	68 c5 ae 10 80       	push   $0x8010aec5
80107abc:	e8 1d 8b ff ff       	call   801005de <panic>

  pushcli();
80107ac1:	e8 60 d1 ff ff       	call   80104c26 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ac6:	e8 cf c0 ff ff       	call   80103b9a <mycpu>
80107acb:	89 c3                	mov    %eax,%ebx
80107acd:	e8 c8 c0 ff ff       	call   80103b9a <mycpu>
80107ad2:	83 c0 08             	add    $0x8,%eax
80107ad5:	89 c6                	mov    %eax,%esi
80107ad7:	e8 be c0 ff ff       	call   80103b9a <mycpu>
80107adc:	83 c0 08             	add    $0x8,%eax
80107adf:	c1 e8 10             	shr    $0x10,%eax
80107ae2:	88 45 f7             	mov    %al,-0x9(%ebp)
80107ae5:	e8 b0 c0 ff ff       	call   80103b9a <mycpu>
80107aea:	83 c0 08             	add    $0x8,%eax
80107aed:	c1 e8 18             	shr    $0x18,%eax
80107af0:	89 c2                	mov    %eax,%edx
80107af2:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107af9:	67 00 
80107afb:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b02:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107b06:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107b0c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b13:	83 e0 f0             	and    $0xfffffff0,%eax
80107b16:	83 c8 09             	or     $0x9,%eax
80107b19:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b1f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b26:	83 c8 10             	or     $0x10,%eax
80107b29:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b2f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b36:	83 e0 9f             	and    $0xffffff9f,%eax
80107b39:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b3f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b46:	83 c8 80             	or     $0xffffff80,%eax
80107b49:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b4f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b56:	83 e0 f0             	and    $0xfffffff0,%eax
80107b59:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b5f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b66:	83 e0 ef             	and    $0xffffffef,%eax
80107b69:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b6f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b76:	83 e0 df             	and    $0xffffffdf,%eax
80107b79:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b7f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b86:	83 c8 40             	or     $0x40,%eax
80107b89:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b8f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b96:	83 e0 7f             	and    $0x7f,%eax
80107b99:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b9f:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ba5:	e8 f0 bf ff ff       	call   80103b9a <mycpu>
80107baa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bb1:	83 e2 ef             	and    $0xffffffef,%edx
80107bb4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107bba:	e8 db bf ff ff       	call   80103b9a <mycpu>
80107bbf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc8:	8b 40 08             	mov    0x8(%eax),%eax
80107bcb:	89 c3                	mov    %eax,%ebx
80107bcd:	e8 c8 bf ff ff       	call   80103b9a <mycpu>
80107bd2:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107bd8:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107bdb:	e8 ba bf ff ff       	call   80103b9a <mycpu>
80107be0:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107be6:	83 ec 0c             	sub    $0xc,%esp
80107be9:	6a 28                	push   $0x28
80107beb:	e8 af f8 ff ff       	call   8010749f <ltr>
80107bf0:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf6:	8b 40 04             	mov    0x4(%eax),%eax
80107bf9:	05 00 00 00 80       	add    $0x80000000,%eax
80107bfe:	83 ec 0c             	sub    $0xc,%esp
80107c01:	50                   	push   %eax
80107c02:	e8 af f8 ff ff       	call   801074b6 <lcr3>
80107c07:	83 c4 10             	add    $0x10,%esp
  popcli();
80107c0a:	e8 68 d0 ff ff       	call   80104c77 <popcli>
}
80107c0f:	90                   	nop
80107c10:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c13:	5b                   	pop    %ebx
80107c14:	5e                   	pop    %esi
80107c15:	5d                   	pop    %ebp
80107c16:	c3                   	ret

80107c17 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c17:	f3 0f 1e fb          	endbr32
80107c1b:	55                   	push   %ebp
80107c1c:	89 e5                	mov    %esp,%ebp
80107c1e:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c21:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c28:	76 0d                	jbe    80107c37 <inituvm+0x20>
    panic("inituvm: more than a page");
80107c2a:	83 ec 0c             	sub    $0xc,%esp
80107c2d:	68 d9 ae 10 80       	push   $0x8010aed9
80107c32:	e8 a7 89 ff ff       	call   801005de <panic>
  mem = kalloc();
80107c37:	e8 c3 ac ff ff       	call   801028ff <kalloc>
80107c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c3f:	83 ec 04             	sub    $0x4,%esp
80107c42:	68 00 10 00 00       	push   $0x1000
80107c47:	6a 00                	push   $0x0
80107c49:	ff 75 f4             	push   -0xc(%ebp)
80107c4c:	e8 e8 d0 ff ff       	call   80104d39 <memset>
80107c51:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	05 00 00 00 80       	add    $0x80000000,%eax
80107c5c:	83 ec 0c             	sub    $0xc,%esp
80107c5f:	6a 06                	push   $0x6
80107c61:	50                   	push   %eax
80107c62:	68 00 10 00 00       	push   $0x1000
80107c67:	6a 00                	push   $0x0
80107c69:	ff 75 08             	push   0x8(%ebp)
80107c6c:	e8 45 fc ff ff       	call   801078b6 <mappages>
80107c71:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c74:	83 ec 04             	sub    $0x4,%esp
80107c77:	ff 75 10             	push   0x10(%ebp)
80107c7a:	ff 75 0c             	push   0xc(%ebp)
80107c7d:	ff 75 f4             	push   -0xc(%ebp)
80107c80:	e8 7b d1 ff ff       	call   80104e00 <memmove>
80107c85:	83 c4 10             	add    $0x10,%esp
}
80107c88:	90                   	nop
80107c89:	c9                   	leave
80107c8a:	c3                   	ret

80107c8b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c8b:	f3 0f 1e fb          	endbr32
80107c8f:	55                   	push   %ebp
80107c90:	89 e5                	mov    %esp,%ebp
80107c92:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c95:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c98:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c9d:	85 c0                	test   %eax,%eax
80107c9f:	74 0d                	je     80107cae <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107ca1:	83 ec 0c             	sub    $0xc,%esp
80107ca4:	68 f4 ae 10 80       	push   $0x8010aef4
80107ca9:	e8 30 89 ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cb5:	e9 8f 00 00 00       	jmp    80107d49 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cba:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	01 d0                	add    %edx,%eax
80107cc2:	83 ec 04             	sub    $0x4,%esp
80107cc5:	6a 00                	push   $0x0
80107cc7:	50                   	push   %eax
80107cc8:	ff 75 08             	push   0x8(%ebp)
80107ccb:	e8 4c fb ff ff       	call   8010781c <walkpgdir>
80107cd0:	83 c4 10             	add    $0x10,%esp
80107cd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cd6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cda:	75 0d                	jne    80107ce9 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107cdc:	83 ec 0c             	sub    $0xc,%esp
80107cdf:	68 17 af 10 80       	push   $0x8010af17
80107ce4:	e8 f5 88 ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107ce9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cec:	8b 00                	mov    (%eax),%eax
80107cee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cf3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107cf6:	8b 45 18             	mov    0x18(%ebp),%eax
80107cf9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107cfc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d01:	77 0b                	ja     80107d0e <loaduvm+0x83>
      n = sz - i;
80107d03:	8b 45 18             	mov    0x18(%ebp),%eax
80107d06:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d0c:	eb 07                	jmp    80107d15 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107d0e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d15:	8b 55 14             	mov    0x14(%ebp),%edx
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	01 d0                	add    %edx,%eax
80107d1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d20:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107d26:	ff 75 f0             	push   -0x10(%ebp)
80107d29:	50                   	push   %eax
80107d2a:	52                   	push   %edx
80107d2b:	ff 75 10             	push   0x10(%ebp)
80107d2e:	e8 be a2 ff ff       	call   80101ff1 <readi>
80107d33:	83 c4 10             	add    $0x10,%esp
80107d36:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107d39:	74 07                	je     80107d42 <loaduvm+0xb7>
      return -1;
80107d3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d40:	eb 18                	jmp    80107d5a <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107d42:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d4f:	0f 82 65 ff ff ff    	jb     80107cba <loaduvm+0x2f>
  }
  return 0;
80107d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d5a:	c9                   	leave
80107d5b:	c3                   	ret

80107d5c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d5c:	f3 0f 1e fb          	endbr32
80107d60:	55                   	push   %ebp
80107d61:	89 e5                	mov    %esp,%ebp
80107d63:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d66:	8b 45 10             	mov    0x10(%ebp),%eax
80107d69:	85 c0                	test   %eax,%eax
80107d6b:	79 0a                	jns    80107d77 <allocuvm+0x1b>
    return 0;
80107d6d:	b8 00 00 00 00       	mov    $0x0,%eax
80107d72:	e9 ec 00 00 00       	jmp    80107e63 <allocuvm+0x107>
  if(newsz < oldsz)
80107d77:	8b 45 10             	mov    0x10(%ebp),%eax
80107d7a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d7d:	73 08                	jae    80107d87 <allocuvm+0x2b>
    return oldsz;
80107d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d82:	e9 dc 00 00 00       	jmp    80107e63 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107d87:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d8a:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d97:	e9 b8 00 00 00       	jmp    80107e54 <allocuvm+0xf8>
    mem = kalloc();
80107d9c:	e8 5e ab ff ff       	call   801028ff <kalloc>
80107da1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107da4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107da8:	75 2e                	jne    80107dd8 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107daa:	83 ec 0c             	sub    $0xc,%esp
80107dad:	68 35 af 10 80       	push   $0x8010af35
80107db2:	e8 55 86 ff ff       	call   8010040c <cprintf>
80107db7:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dba:	83 ec 04             	sub    $0x4,%esp
80107dbd:	ff 75 0c             	push   0xc(%ebp)
80107dc0:	ff 75 10             	push   0x10(%ebp)
80107dc3:	ff 75 08             	push   0x8(%ebp)
80107dc6:	e8 9a 00 00 00       	call   80107e65 <deallocuvm>
80107dcb:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dce:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd3:	e9 8b 00 00 00       	jmp    80107e63 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107dd8:	83 ec 04             	sub    $0x4,%esp
80107ddb:	68 00 10 00 00       	push   $0x1000
80107de0:	6a 00                	push   $0x0
80107de2:	ff 75 f0             	push   -0x10(%ebp)
80107de5:	e8 4f cf ff ff       	call   80104d39 <memset>
80107dea:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df9:	83 ec 0c             	sub    $0xc,%esp
80107dfc:	6a 06                	push   $0x6
80107dfe:	52                   	push   %edx
80107dff:	68 00 10 00 00       	push   $0x1000
80107e04:	50                   	push   %eax
80107e05:	ff 75 08             	push   0x8(%ebp)
80107e08:	e8 a9 fa ff ff       	call   801078b6 <mappages>
80107e0d:	83 c4 20             	add    $0x20,%esp
80107e10:	85 c0                	test   %eax,%eax
80107e12:	79 39                	jns    80107e4d <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107e14:	83 ec 0c             	sub    $0xc,%esp
80107e17:	68 4d af 10 80       	push   $0x8010af4d
80107e1c:	e8 eb 85 ff ff       	call   8010040c <cprintf>
80107e21:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e24:	83 ec 04             	sub    $0x4,%esp
80107e27:	ff 75 0c             	push   0xc(%ebp)
80107e2a:	ff 75 10             	push   0x10(%ebp)
80107e2d:	ff 75 08             	push   0x8(%ebp)
80107e30:	e8 30 00 00 00       	call   80107e65 <deallocuvm>
80107e35:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107e38:	83 ec 0c             	sub    $0xc,%esp
80107e3b:	ff 75 f0             	push   -0x10(%ebp)
80107e3e:	e8 1e aa ff ff       	call   80102861 <kfree>
80107e43:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e46:	b8 00 00 00 00       	mov    $0x0,%eax
80107e4b:	eb 16                	jmp    80107e63 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107e4d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e57:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e5a:	0f 82 3c ff ff ff    	jb     80107d9c <allocuvm+0x40>
    }
  }
  return newsz;
80107e60:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e63:	c9                   	leave
80107e64:	c3                   	ret

80107e65 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e65:	f3 0f 1e fb          	endbr32
80107e69:	55                   	push   %ebp
80107e6a:	89 e5                	mov    %esp,%ebp
80107e6c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e72:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e75:	72 08                	jb     80107e7f <deallocuvm+0x1a>
    return oldsz;
80107e77:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e7a:	e9 ac 00 00 00       	jmp    80107f2b <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107e7f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e82:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e8f:	e9 88 00 00 00       	jmp    80107f1c <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	83 ec 04             	sub    $0x4,%esp
80107e9a:	6a 00                	push   $0x0
80107e9c:	50                   	push   %eax
80107e9d:	ff 75 08             	push   0x8(%ebp)
80107ea0:	e8 77 f9 ff ff       	call   8010781c <walkpgdir>
80107ea5:	83 c4 10             	add    $0x10,%esp
80107ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107eab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eaf:	75 16                	jne    80107ec7 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb4:	c1 e8 16             	shr    $0x16,%eax
80107eb7:	83 c0 01             	add    $0x1,%eax
80107eba:	c1 e0 16             	shl    $0x16,%eax
80107ebd:	2d 00 10 00 00       	sub    $0x1000,%eax
80107ec2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ec5:	eb 4e                	jmp    80107f15 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eca:	8b 00                	mov    (%eax),%eax
80107ecc:	83 e0 01             	and    $0x1,%eax
80107ecf:	85 c0                	test   %eax,%eax
80107ed1:	74 42                	je     80107f15 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed6:	8b 00                	mov    (%eax),%eax
80107ed8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107edd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ee0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ee4:	75 0d                	jne    80107ef3 <deallocuvm+0x8e>
        panic("kfree");
80107ee6:	83 ec 0c             	sub    $0xc,%esp
80107ee9:	68 69 af 10 80       	push   $0x8010af69
80107eee:	e8 eb 86 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef6:	05 00 00 00 80       	add    $0x80000000,%eax
80107efb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107efe:	83 ec 0c             	sub    $0xc,%esp
80107f01:	ff 75 e8             	push   -0x18(%ebp)
80107f04:	e8 58 a9 ff ff       	call   80102861 <kfree>
80107f09:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f15:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f22:	0f 82 6c ff ff ff    	jb     80107e94 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107f28:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f2b:	c9                   	leave
80107f2c:	c3                   	ret

80107f2d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f2d:	f3 0f 1e fb          	endbr32
80107f31:	55                   	push   %ebp
80107f32:	89 e5                	mov    %esp,%ebp
80107f34:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107f37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f3b:	75 0d                	jne    80107f4a <freevm+0x1d>
    panic("freevm: no pgdir");
80107f3d:	83 ec 0c             	sub    $0xc,%esp
80107f40:	68 6f af 10 80       	push   $0x8010af6f
80107f45:	e8 94 86 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f4a:	83 ec 04             	sub    $0x4,%esp
80107f4d:	6a 00                	push   $0x0
80107f4f:	68 00 00 00 80       	push   $0x80000000
80107f54:	ff 75 08             	push   0x8(%ebp)
80107f57:	e8 09 ff ff ff       	call   80107e65 <deallocuvm>
80107f5c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f66:	eb 48                	jmp    80107fb0 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f72:	8b 45 08             	mov    0x8(%ebp),%eax
80107f75:	01 d0                	add    %edx,%eax
80107f77:	8b 00                	mov    (%eax),%eax
80107f79:	83 e0 01             	and    $0x1,%eax
80107f7c:	85 c0                	test   %eax,%eax
80107f7e:	74 2c                	je     80107fac <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8d:	01 d0                	add    %edx,%eax
80107f8f:	8b 00                	mov    (%eax),%eax
80107f91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f96:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f9e:	83 ec 0c             	sub    $0xc,%esp
80107fa1:	ff 75 f0             	push   -0x10(%ebp)
80107fa4:	e8 b8 a8 ff ff       	call   80102861 <kfree>
80107fa9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fb0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107fb7:	76 af                	jbe    80107f68 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107fb9:	83 ec 0c             	sub    $0xc,%esp
80107fbc:	ff 75 08             	push   0x8(%ebp)
80107fbf:	e8 9d a8 ff ff       	call   80102861 <kfree>
80107fc4:	83 c4 10             	add    $0x10,%esp
}
80107fc7:	90                   	nop
80107fc8:	c9                   	leave
80107fc9:	c3                   	ret

80107fca <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fca:	f3 0f 1e fb          	endbr32
80107fce:	55                   	push   %ebp
80107fcf:	89 e5                	mov    %esp,%ebp
80107fd1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fd4:	83 ec 04             	sub    $0x4,%esp
80107fd7:	6a 00                	push   $0x0
80107fd9:	ff 75 0c             	push   0xc(%ebp)
80107fdc:	ff 75 08             	push   0x8(%ebp)
80107fdf:	e8 38 f8 ff ff       	call   8010781c <walkpgdir>
80107fe4:	83 c4 10             	add    $0x10,%esp
80107fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107fea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fee:	75 0d                	jne    80107ffd <clearpteu+0x33>
    panic("clearpteu");
80107ff0:	83 ec 0c             	sub    $0xc,%esp
80107ff3:	68 80 af 10 80       	push   $0x8010af80
80107ff8:	e8 e1 85 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108000:	8b 00                	mov    (%eax),%eax
80108002:	83 e0 fb             	and    $0xfffffffb,%eax
80108005:	89 c2                	mov    %eax,%edx
80108007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800a:	89 10                	mov    %edx,(%eax)
}
8010800c:	90                   	nop
8010800d:	c9                   	leave
8010800e:	c3                   	ret

8010800f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010800f:	f3 0f 1e fb          	endbr32
80108013:	55                   	push   %ebp
80108014:	89 e5                	mov    %esp,%ebp
80108016:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80108019:	e8 2c f9 ff ff       	call   8010794a <setupkvm>
8010801e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108021:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108025:	75 0a                	jne    80108031 <copyuvm+0x22>
    return 0;
80108027:	b8 00 00 00 00       	mov    $0x0,%eax
8010802c:	e9 d6 00 00 00       	jmp    80108107 <copyuvm+0xf8>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80108031:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108038:	e9 a3 00 00 00       	jmp    801080e0 <copyuvm+0xd1>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010803d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108040:	83 ec 04             	sub    $0x4,%esp
80108043:	6a 00                	push   $0x0
80108045:	50                   	push   %eax
80108046:	ff 75 08             	push   0x8(%ebp)
80108049:	e8 ce f7 ff ff       	call   8010781c <walkpgdir>
8010804e:	83 c4 10             	add    $0x10,%esp
80108051:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108054:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108058:	74 7b                	je     801080d5 <copyuvm+0xc6>
      continue;
    if(!(*pte & PTE_P)){
8010805a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805d:	8b 00                	mov    (%eax),%eax
8010805f:	83 e0 01             	and    $0x1,%eax
80108062:	85 c0                	test   %eax,%eax
80108064:	74 72                	je     801080d8 <copyuvm+0xc9>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80108066:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108069:	8b 00                	mov    (%eax),%eax
8010806b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108070:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108073:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108076:	8b 00                	mov    (%eax),%eax
80108078:	25 ff 0f 00 00       	and    $0xfff,%eax
8010807d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80108080:	e8 7a a8 ff ff       	call   801028ff <kalloc>
80108085:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108088:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010808c:	74 62                	je     801080f0 <copyuvm+0xe1>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010808e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108091:	05 00 00 00 80       	add    $0x80000000,%eax
80108096:	83 ec 04             	sub    $0x4,%esp
80108099:	68 00 10 00 00       	push   $0x1000
8010809e:	50                   	push   %eax
8010809f:	ff 75 e0             	push   -0x20(%ebp)
801080a2:	e8 59 cd ff ff       	call   80104e00 <memmove>
801080a7:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801080aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801080ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080b0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801080b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b9:	83 ec 0c             	sub    $0xc,%esp
801080bc:	52                   	push   %edx
801080bd:	51                   	push   %ecx
801080be:	68 00 10 00 00       	push   $0x1000
801080c3:	50                   	push   %eax
801080c4:	ff 75 f0             	push   -0x10(%ebp)
801080c7:	e8 ea f7 ff ff       	call   801078b6 <mappages>
801080cc:	83 c4 20             	add    $0x20,%esp
801080cf:	85 c0                	test   %eax,%eax
801080d1:	78 20                	js     801080f3 <copyuvm+0xe4>
801080d3:	eb 04                	jmp    801080d9 <copyuvm+0xca>
      continue;
801080d5:	90                   	nop
801080d6:	eb 01                	jmp    801080d9 <copyuvm+0xca>
      continue;
801080d8:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
801080d9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e3:	85 c0                	test   %eax,%eax
801080e5:	0f 89 52 ff ff ff    	jns    8010803d <copyuvm+0x2e>
      goto bad;
  }  
  return d;
801080eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ee:	eb 17                	jmp    80108107 <copyuvm+0xf8>
      goto bad;
801080f0:	90                   	nop
801080f1:	eb 01                	jmp    801080f4 <copyuvm+0xe5>
      goto bad;
801080f3:	90                   	nop

bad:
  freevm(d);
801080f4:	83 ec 0c             	sub    $0xc,%esp
801080f7:	ff 75 f0             	push   -0x10(%ebp)
801080fa:	e8 2e fe ff ff       	call   80107f2d <freevm>
801080ff:	83 c4 10             	add    $0x10,%esp
  return 0;
80108102:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108107:	c9                   	leave
80108108:	c3                   	ret

80108109 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108109:	f3 0f 1e fb          	endbr32
8010810d:	55                   	push   %ebp
8010810e:	89 e5                	mov    %esp,%ebp
80108110:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108113:	83 ec 04             	sub    $0x4,%esp
80108116:	6a 00                	push   $0x0
80108118:	ff 75 0c             	push   0xc(%ebp)
8010811b:	ff 75 08             	push   0x8(%ebp)
8010811e:	e8 f9 f6 ff ff       	call   8010781c <walkpgdir>
80108123:	83 c4 10             	add    $0x10,%esp
80108126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812c:	8b 00                	mov    (%eax),%eax
8010812e:	83 e0 01             	and    $0x1,%eax
80108131:	85 c0                	test   %eax,%eax
80108133:	75 07                	jne    8010813c <uva2ka+0x33>
    return 0;
80108135:	b8 00 00 00 00       	mov    $0x0,%eax
8010813a:	eb 22                	jmp    8010815e <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
8010813c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813f:	8b 00                	mov    (%eax),%eax
80108141:	83 e0 04             	and    $0x4,%eax
80108144:	85 c0                	test   %eax,%eax
80108146:	75 07                	jne    8010814f <uva2ka+0x46>
    return 0;
80108148:	b8 00 00 00 00       	mov    $0x0,%eax
8010814d:	eb 0f                	jmp    8010815e <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	8b 00                	mov    (%eax),%eax
80108154:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108159:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010815e:	c9                   	leave
8010815f:	c3                   	ret

80108160 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108160:	f3 0f 1e fb          	endbr32
80108164:	55                   	push   %ebp
80108165:	89 e5                	mov    %esp,%ebp
80108167:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010816a:	8b 45 10             	mov    0x10(%ebp),%eax
8010816d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108170:	eb 7f                	jmp    801081f1 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108172:	8b 45 0c             	mov    0xc(%ebp),%eax
80108175:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010817d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108180:	83 ec 08             	sub    $0x8,%esp
80108183:	50                   	push   %eax
80108184:	ff 75 08             	push   0x8(%ebp)
80108187:	e8 7d ff ff ff       	call   80108109 <uva2ka>
8010818c:	83 c4 10             	add    $0x10,%esp
8010818f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108192:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108196:	75 07                	jne    8010819f <copyout+0x3f>
      return -1;
80108198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010819d:	eb 61                	jmp    80108200 <copyout+0xa0>
    n = PGSIZE - (va - va0);
8010819f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081a2:	2b 45 0c             	sub    0xc(%ebp),%eax
801081a5:	05 00 10 00 00       	add    $0x1000,%eax
801081aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801081ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b0:	3b 45 14             	cmp    0x14(%ebp),%eax
801081b3:	76 06                	jbe    801081bb <copyout+0x5b>
      n = len;
801081b5:	8b 45 14             	mov    0x14(%ebp),%eax
801081b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081be:	2b 45 ec             	sub    -0x14(%ebp),%eax
801081c1:	89 c2                	mov    %eax,%edx
801081c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c6:	01 d0                	add    %edx,%eax
801081c8:	83 ec 04             	sub    $0x4,%esp
801081cb:	ff 75 f0             	push   -0x10(%ebp)
801081ce:	ff 75 f4             	push   -0xc(%ebp)
801081d1:	50                   	push   %eax
801081d2:	e8 29 cc ff ff       	call   80104e00 <memmove>
801081d7:	83 c4 10             	add    $0x10,%esp
    len -= n;
801081da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081dd:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e3:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e9:	05 00 10 00 00       	add    $0x1000,%eax
801081ee:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801081f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081f5:	0f 85 77 ff ff ff    	jne    80108172 <copyout+0x12>
  }
  return 0;
801081fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108200:	c9                   	leave
80108201:	c3                   	ret

80108202 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108202:	f3 0f 1e fb          	endbr32
80108206:	55                   	push   %ebp
80108207:	89 e5                	mov    %esp,%ebp
80108209:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010820c:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108213:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108216:	8b 40 08             	mov    0x8(%eax),%eax
80108219:	05 00 00 00 80       	add    $0x80000000,%eax
8010821e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108221:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	8b 40 24             	mov    0x24(%eax),%eax
8010822e:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108233:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
8010823a:	00 00 00 

  while(i<madt->len){
8010823d:	90                   	nop
8010823e:	e9 be 00 00 00       	jmp    80108301 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108243:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108246:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108249:	01 d0                	add    %edx,%eax
8010824b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010824e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108251:	0f b6 00             	movzbl (%eax),%eax
80108254:	0f b6 c0             	movzbl %al,%eax
80108257:	83 f8 05             	cmp    $0x5,%eax
8010825a:	0f 87 a1 00 00 00    	ja     80108301 <mpinit_uefi+0xff>
80108260:	8b 04 85 8c af 10 80 	mov    -0x7fef5074(,%eax,4),%eax
80108267:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010826a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108270:	a1 80 80 19 80       	mov    0x80198080,%eax
80108275:	83 f8 03             	cmp    $0x3,%eax
80108278:	7f 28                	jg     801082a2 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010827a:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108280:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108283:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108287:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010828d:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108293:	88 02                	mov    %al,(%edx)
          ncpu++;
80108295:	a1 80 80 19 80       	mov    0x80198080,%eax
8010829a:	83 c0 01             	add    $0x1,%eax
8010829d:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
801082a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082a5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082a9:	0f b6 c0             	movzbl %al,%eax
801082ac:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082af:	eb 50                	jmp    80108301 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801082b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801082b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082ba:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801082be:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
801082c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082c6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082ca:	0f b6 c0             	movzbl %al,%eax
801082cd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082d0:	eb 2f                	jmp    80108301 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801082d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801082d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082db:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082df:	0f b6 c0             	movzbl %al,%eax
801082e2:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082e5:	eb 1a                	jmp    80108301 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801082e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801082ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082f4:	0f b6 c0             	movzbl %al,%eax
801082f7:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082fa:	eb 05                	jmp    80108301 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801082fc:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108300:	90                   	nop
  while(i<madt->len){
80108301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108304:	8b 40 04             	mov    0x4(%eax),%eax
80108307:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010830a:	0f 82 33 ff ff ff    	jb     80108243 <mpinit_uefi+0x41>
    }
  }

}
80108310:	90                   	nop
80108311:	90                   	nop
80108312:	c9                   	leave
80108313:	c3                   	ret

80108314 <inb>:
{
80108314:	55                   	push   %ebp
80108315:	89 e5                	mov    %esp,%ebp
80108317:	83 ec 14             	sub    $0x14,%esp
8010831a:	8b 45 08             	mov    0x8(%ebp),%eax
8010831d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108321:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108325:	89 c2                	mov    %eax,%edx
80108327:	ec                   	in     (%dx),%al
80108328:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010832b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010832f:	c9                   	leave
80108330:	c3                   	ret

80108331 <outb>:
{
80108331:	55                   	push   %ebp
80108332:	89 e5                	mov    %esp,%ebp
80108334:	83 ec 08             	sub    $0x8,%esp
80108337:	8b 45 08             	mov    0x8(%ebp),%eax
8010833a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108341:	89 d0                	mov    %edx,%eax
80108343:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108346:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010834a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010834e:	ee                   	out    %al,(%dx)
}
8010834f:	90                   	nop
80108350:	c9                   	leave
80108351:	c3                   	ret

80108352 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108352:	f3 0f 1e fb          	endbr32
80108356:	55                   	push   %ebp
80108357:	89 e5                	mov    %esp,%ebp
80108359:	83 ec 28             	sub    $0x28,%esp
8010835c:	8b 45 08             	mov    0x8(%ebp),%eax
8010835f:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108362:	6a 00                	push   $0x0
80108364:	68 fa 03 00 00       	push   $0x3fa
80108369:	e8 c3 ff ff ff       	call   80108331 <outb>
8010836e:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108371:	68 80 00 00 00       	push   $0x80
80108376:	68 fb 03 00 00       	push   $0x3fb
8010837b:	e8 b1 ff ff ff       	call   80108331 <outb>
80108380:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108383:	6a 0c                	push   $0xc
80108385:	68 f8 03 00 00       	push   $0x3f8
8010838a:	e8 a2 ff ff ff       	call   80108331 <outb>
8010838f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108392:	6a 00                	push   $0x0
80108394:	68 f9 03 00 00       	push   $0x3f9
80108399:	e8 93 ff ff ff       	call   80108331 <outb>
8010839e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801083a1:	6a 03                	push   $0x3
801083a3:	68 fb 03 00 00       	push   $0x3fb
801083a8:	e8 84 ff ff ff       	call   80108331 <outb>
801083ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801083b0:	6a 00                	push   $0x0
801083b2:	68 fc 03 00 00       	push   $0x3fc
801083b7:	e8 75 ff ff ff       	call   80108331 <outb>
801083bc:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801083bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c6:	eb 11                	jmp    801083d9 <uart_debug+0x87>
801083c8:	83 ec 0c             	sub    $0xc,%esp
801083cb:	6a 0a                	push   $0xa
801083cd:	e8 df a8 ff ff       	call   80102cb1 <microdelay>
801083d2:	83 c4 10             	add    $0x10,%esp
801083d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083d9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801083dd:	7f 1a                	jg     801083f9 <uart_debug+0xa7>
801083df:	83 ec 0c             	sub    $0xc,%esp
801083e2:	68 fd 03 00 00       	push   $0x3fd
801083e7:	e8 28 ff ff ff       	call   80108314 <inb>
801083ec:	83 c4 10             	add    $0x10,%esp
801083ef:	0f b6 c0             	movzbl %al,%eax
801083f2:	83 e0 20             	and    $0x20,%eax
801083f5:	85 c0                	test   %eax,%eax
801083f7:	74 cf                	je     801083c8 <uart_debug+0x76>
  outb(COM1+0, p);
801083f9:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801083fd:	0f b6 c0             	movzbl %al,%eax
80108400:	83 ec 08             	sub    $0x8,%esp
80108403:	50                   	push   %eax
80108404:	68 f8 03 00 00       	push   $0x3f8
80108409:	e8 23 ff ff ff       	call   80108331 <outb>
8010840e:	83 c4 10             	add    $0x10,%esp
}
80108411:	90                   	nop
80108412:	c9                   	leave
80108413:	c3                   	ret

80108414 <uart_debugs>:

void uart_debugs(char *p){
80108414:	f3 0f 1e fb          	endbr32
80108418:	55                   	push   %ebp
80108419:	89 e5                	mov    %esp,%ebp
8010841b:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010841e:	eb 1b                	jmp    8010843b <uart_debugs+0x27>
    uart_debug(*p++);
80108420:	8b 45 08             	mov    0x8(%ebp),%eax
80108423:	8d 50 01             	lea    0x1(%eax),%edx
80108426:	89 55 08             	mov    %edx,0x8(%ebp)
80108429:	0f b6 00             	movzbl (%eax),%eax
8010842c:	0f be c0             	movsbl %al,%eax
8010842f:	83 ec 0c             	sub    $0xc,%esp
80108432:	50                   	push   %eax
80108433:	e8 1a ff ff ff       	call   80108352 <uart_debug>
80108438:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010843b:	8b 45 08             	mov    0x8(%ebp),%eax
8010843e:	0f b6 00             	movzbl (%eax),%eax
80108441:	84 c0                	test   %al,%al
80108443:	75 db                	jne    80108420 <uart_debugs+0xc>
  }
}
80108445:	90                   	nop
80108446:	90                   	nop
80108447:	c9                   	leave
80108448:	c3                   	ret

80108449 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108449:	f3 0f 1e fb          	endbr32
8010844d:	55                   	push   %ebp
8010844e:	89 e5                	mov    %esp,%ebp
80108450:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108453:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010845a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010845d:	8b 50 14             	mov    0x14(%eax),%edx
80108460:	8b 40 10             	mov    0x10(%eax),%eax
80108463:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108468:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010846b:	8b 50 1c             	mov    0x1c(%eax),%edx
8010846e:	8b 40 18             	mov    0x18(%eax),%eax
80108471:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108476:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010847b:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108480:	29 c2                	sub    %eax,%edx
80108482:	89 d0                	mov    %edx,%eax
80108484:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108489:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010848c:	8b 50 24             	mov    0x24(%eax),%edx
8010848f:	8b 40 20             	mov    0x20(%eax),%eax
80108492:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108497:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010849a:	8b 50 2c             	mov    0x2c(%eax),%edx
8010849d:	8b 40 28             	mov    0x28(%eax),%eax
801084a0:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801084a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084a8:	8b 50 34             	mov    0x34(%eax),%edx
801084ab:	8b 40 30             	mov    0x30(%eax),%eax
801084ae:	a3 98 80 19 80       	mov    %eax,0x80198098
}
801084b3:	90                   	nop
801084b4:	c9                   	leave
801084b5:	c3                   	ret

801084b6 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801084b6:	f3 0f 1e fb          	endbr32
801084ba:	55                   	push   %ebp
801084bb:	89 e5                	mov    %esp,%ebp
801084bd:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801084c0:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801084c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c9:	0f af d0             	imul   %eax,%edx
801084cc:	8b 45 08             	mov    0x8(%ebp),%eax
801084cf:	01 d0                	add    %edx,%eax
801084d1:	c1 e0 02             	shl    $0x2,%eax
801084d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801084d7:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801084dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084e0:	01 d0                	add    %edx,%eax
801084e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801084e5:	8b 45 10             	mov    0x10(%ebp),%eax
801084e8:	0f b6 10             	movzbl (%eax),%edx
801084eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084ee:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801084f0:	8b 45 10             	mov    0x10(%ebp),%eax
801084f3:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801084f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084fa:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801084fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108500:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108504:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108507:	88 50 02             	mov    %dl,0x2(%eax)
}
8010850a:	90                   	nop
8010850b:	c9                   	leave
8010850c:	c3                   	ret

8010850d <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010850d:	f3 0f 1e fb          	endbr32
80108511:	55                   	push   %ebp
80108512:	89 e5                	mov    %esp,%ebp
80108514:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108517:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010851d:	8b 45 08             	mov    0x8(%ebp),%eax
80108520:	0f af c2             	imul   %edx,%eax
80108523:	c1 e0 02             	shl    $0x2,%eax
80108526:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108529:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
8010852f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108532:	29 c2                	sub    %eax,%edx
80108534:	89 d0                	mov    %edx,%eax
80108536:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010853c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010853f:	01 ca                	add    %ecx,%edx
80108541:	89 d1                	mov    %edx,%ecx
80108543:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108549:	83 ec 04             	sub    $0x4,%esp
8010854c:	50                   	push   %eax
8010854d:	51                   	push   %ecx
8010854e:	52                   	push   %edx
8010854f:	e8 ac c8 ff ff       	call   80104e00 <memmove>
80108554:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108560:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108566:	01 d1                	add    %edx,%ecx
80108568:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010856b:	29 d1                	sub    %edx,%ecx
8010856d:	89 ca                	mov    %ecx,%edx
8010856f:	83 ec 04             	sub    $0x4,%esp
80108572:	50                   	push   %eax
80108573:	6a 00                	push   $0x0
80108575:	52                   	push   %edx
80108576:	e8 be c7 ff ff       	call   80104d39 <memset>
8010857b:	83 c4 10             	add    $0x10,%esp
}
8010857e:	90                   	nop
8010857f:	c9                   	leave
80108580:	c3                   	ret

80108581 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108581:	f3 0f 1e fb          	endbr32
80108585:	55                   	push   %ebp
80108586:	89 e5                	mov    %esp,%ebp
80108588:	53                   	push   %ebx
80108589:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010858c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108593:	e9 b1 00 00 00       	jmp    80108649 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108598:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010859f:	e9 97 00 00 00       	jmp    8010863b <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801085a4:	8b 45 10             	mov    0x10(%ebp),%eax
801085a7:	83 e8 20             	sub    $0x20,%eax
801085aa:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b0:	01 d0                	add    %edx,%eax
801085b2:	0f b7 84 00 c0 af 10 	movzwl -0x7fef5040(%eax,%eax,1),%eax
801085b9:	80 
801085ba:	0f b7 d0             	movzwl %ax,%edx
801085bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c0:	bb 01 00 00 00       	mov    $0x1,%ebx
801085c5:	89 c1                	mov    %eax,%ecx
801085c7:	d3 e3                	shl    %cl,%ebx
801085c9:	89 d8                	mov    %ebx,%eax
801085cb:	21 d0                	and    %edx,%eax
801085cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801085d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d3:	ba 01 00 00 00       	mov    $0x1,%edx
801085d8:	89 c1                	mov    %eax,%ecx
801085da:	d3 e2                	shl    %cl,%edx
801085dc:	89 d0                	mov    %edx,%eax
801085de:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801085e1:	75 2b                	jne    8010860e <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801085e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801085e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e9:	01 c2                	add    %eax,%edx
801085eb:	b8 0e 00 00 00       	mov    $0xe,%eax
801085f0:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085f3:	89 c1                	mov    %eax,%ecx
801085f5:	8b 45 08             	mov    0x8(%ebp),%eax
801085f8:	01 c8                	add    %ecx,%eax
801085fa:	83 ec 04             	sub    $0x4,%esp
801085fd:	68 e0 f4 10 80       	push   $0x8010f4e0
80108602:	52                   	push   %edx
80108603:	50                   	push   %eax
80108604:	e8 ad fe ff ff       	call   801084b6 <graphic_draw_pixel>
80108609:	83 c4 10             	add    $0x10,%esp
8010860c:	eb 29                	jmp    80108637 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010860e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108614:	01 c2                	add    %eax,%edx
80108616:	b8 0e 00 00 00       	mov    $0xe,%eax
8010861b:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010861e:	89 c1                	mov    %eax,%ecx
80108620:	8b 45 08             	mov    0x8(%ebp),%eax
80108623:	01 c8                	add    %ecx,%eax
80108625:	83 ec 04             	sub    $0x4,%esp
80108628:	68 64 d0 18 80       	push   $0x8018d064
8010862d:	52                   	push   %edx
8010862e:	50                   	push   %eax
8010862f:	e8 82 fe ff ff       	call   801084b6 <graphic_draw_pixel>
80108634:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108637:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010863b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010863f:	0f 89 5f ff ff ff    	jns    801085a4 <font_render+0x23>
  for(int i=0;i<30;i++){
80108645:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108649:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010864d:	0f 8e 45 ff ff ff    	jle    80108598 <font_render+0x17>
      }
    }
  }
}
80108653:	90                   	nop
80108654:	90                   	nop
80108655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108658:	c9                   	leave
80108659:	c3                   	ret

8010865a <font_render_string>:

void font_render_string(char *string,int row){
8010865a:	f3 0f 1e fb          	endbr32
8010865e:	55                   	push   %ebp
8010865f:	89 e5                	mov    %esp,%ebp
80108661:	53                   	push   %ebx
80108662:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010866c:	eb 33                	jmp    801086a1 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010866e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108671:	8b 45 08             	mov    0x8(%ebp),%eax
80108674:	01 d0                	add    %edx,%eax
80108676:	0f b6 00             	movzbl (%eax),%eax
80108679:	0f be d8             	movsbl %al,%ebx
8010867c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867f:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108685:	89 d0                	mov    %edx,%eax
80108687:	c1 e0 04             	shl    $0x4,%eax
8010868a:	29 d0                	sub    %edx,%eax
8010868c:	83 c0 02             	add    $0x2,%eax
8010868f:	83 ec 04             	sub    $0x4,%esp
80108692:	53                   	push   %ebx
80108693:	51                   	push   %ecx
80108694:	50                   	push   %eax
80108695:	e8 e7 fe ff ff       	call   80108581 <font_render>
8010869a:	83 c4 10             	add    $0x10,%esp
    i++;
8010869d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801086a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086a4:	8b 45 08             	mov    0x8(%ebp),%eax
801086a7:	01 d0                	add    %edx,%eax
801086a9:	0f b6 00             	movzbl (%eax),%eax
801086ac:	84 c0                	test   %al,%al
801086ae:	74 06                	je     801086b6 <font_render_string+0x5c>
801086b0:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801086b4:	7e b8                	jle    8010866e <font_render_string+0x14>
  }
}
801086b6:	90                   	nop
801086b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086ba:	c9                   	leave
801086bb:	c3                   	ret

801086bc <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801086bc:	f3 0f 1e fb          	endbr32
801086c0:	55                   	push   %ebp
801086c1:	89 e5                	mov    %esp,%ebp
801086c3:	53                   	push   %ebx
801086c4:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801086c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086ce:	eb 6b                	jmp    8010873b <pci_init+0x7f>
    for(int j=0;j<32;j++){
801086d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801086d7:	eb 58                	jmp    80108731 <pci_init+0x75>
      for(int k=0;k<8;k++){
801086d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801086e0:	eb 45                	jmp    80108727 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801086e2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086eb:	83 ec 0c             	sub    $0xc,%esp
801086ee:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801086f1:	53                   	push   %ebx
801086f2:	6a 00                	push   $0x0
801086f4:	51                   	push   %ecx
801086f5:	52                   	push   %edx
801086f6:	50                   	push   %eax
801086f7:	e8 c0 00 00 00       	call   801087bc <pci_access_config>
801086fc:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801086ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108702:	0f b7 c0             	movzwl %ax,%eax
80108705:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010870a:	74 17                	je     80108723 <pci_init+0x67>
        pci_init_device(i,j,k);
8010870c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010870f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108715:	83 ec 04             	sub    $0x4,%esp
80108718:	51                   	push   %ecx
80108719:	52                   	push   %edx
8010871a:	50                   	push   %eax
8010871b:	e8 4f 01 00 00       	call   8010886f <pci_init_device>
80108720:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108723:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108727:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010872b:	7e b5                	jle    801086e2 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010872d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108731:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108735:	7e a2                	jle    801086d9 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108737:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010873b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108742:	7e 8c                	jle    801086d0 <pci_init+0x14>
      }
      }
    }
  }
}
80108744:	90                   	nop
80108745:	90                   	nop
80108746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108749:	c9                   	leave
8010874a:	c3                   	ret

8010874b <pci_write_config>:

void pci_write_config(uint config){
8010874b:	f3 0f 1e fb          	endbr32
8010874f:	55                   	push   %ebp
80108750:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108752:	8b 45 08             	mov    0x8(%ebp),%eax
80108755:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010875a:	89 c0                	mov    %eax,%eax
8010875c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010875d:	90                   	nop
8010875e:	5d                   	pop    %ebp
8010875f:	c3                   	ret

80108760 <pci_write_data>:

void pci_write_data(uint config){
80108760:	f3 0f 1e fb          	endbr32
80108764:	55                   	push   %ebp
80108765:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108767:	8b 45 08             	mov    0x8(%ebp),%eax
8010876a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010876f:	89 c0                	mov    %eax,%eax
80108771:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108772:	90                   	nop
80108773:	5d                   	pop    %ebp
80108774:	c3                   	ret

80108775 <pci_read_config>:
uint pci_read_config(){
80108775:	f3 0f 1e fb          	endbr32
80108779:	55                   	push   %ebp
8010877a:	89 e5                	mov    %esp,%ebp
8010877c:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010877f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108784:	ed                   	in     (%dx),%eax
80108785:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108788:	83 ec 0c             	sub    $0xc,%esp
8010878b:	68 c8 00 00 00       	push   $0xc8
80108790:	e8 1c a5 ff ff       	call   80102cb1 <microdelay>
80108795:	83 c4 10             	add    $0x10,%esp
  return data;
80108798:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010879b:	c9                   	leave
8010879c:	c3                   	ret

8010879d <pci_test>:


void pci_test(){
8010879d:	f3 0f 1e fb          	endbr32
801087a1:	55                   	push   %ebp
801087a2:	89 e5                	mov    %esp,%ebp
801087a4:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801087a7:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801087ae:	ff 75 fc             	push   -0x4(%ebp)
801087b1:	e8 95 ff ff ff       	call   8010874b <pci_write_config>
801087b6:	83 c4 04             	add    $0x4,%esp
}
801087b9:	90                   	nop
801087ba:	c9                   	leave
801087bb:	c3                   	ret

801087bc <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801087bc:	f3 0f 1e fb          	endbr32
801087c0:	55                   	push   %ebp
801087c1:	89 e5                	mov    %esp,%ebp
801087c3:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087c6:	8b 45 08             	mov    0x8(%ebp),%eax
801087c9:	c1 e0 10             	shl    $0x10,%eax
801087cc:	25 00 00 ff 00       	and    $0xff0000,%eax
801087d1:	89 c2                	mov    %eax,%edx
801087d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d6:	c1 e0 0b             	shl    $0xb,%eax
801087d9:	0f b7 c0             	movzwl %ax,%eax
801087dc:	09 c2                	or     %eax,%edx
801087de:	8b 45 10             	mov    0x10(%ebp),%eax
801087e1:	c1 e0 08             	shl    $0x8,%eax
801087e4:	25 00 07 00 00       	and    $0x700,%eax
801087e9:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087eb:	8b 45 14             	mov    0x14(%ebp),%eax
801087ee:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087f3:	09 d0                	or     %edx,%eax
801087f5:	0d 00 00 00 80       	or     $0x80000000,%eax
801087fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801087fd:	ff 75 f4             	push   -0xc(%ebp)
80108800:	e8 46 ff ff ff       	call   8010874b <pci_write_config>
80108805:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108808:	e8 68 ff ff ff       	call   80108775 <pci_read_config>
8010880d:	8b 55 18             	mov    0x18(%ebp),%edx
80108810:	89 02                	mov    %eax,(%edx)
}
80108812:	90                   	nop
80108813:	c9                   	leave
80108814:	c3                   	ret

80108815 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108815:	f3 0f 1e fb          	endbr32
80108819:	55                   	push   %ebp
8010881a:	89 e5                	mov    %esp,%ebp
8010881c:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010881f:	8b 45 08             	mov    0x8(%ebp),%eax
80108822:	c1 e0 10             	shl    $0x10,%eax
80108825:	25 00 00 ff 00       	and    $0xff0000,%eax
8010882a:	89 c2                	mov    %eax,%edx
8010882c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010882f:	c1 e0 0b             	shl    $0xb,%eax
80108832:	0f b7 c0             	movzwl %ax,%eax
80108835:	09 c2                	or     %eax,%edx
80108837:	8b 45 10             	mov    0x10(%ebp),%eax
8010883a:	c1 e0 08             	shl    $0x8,%eax
8010883d:	25 00 07 00 00       	and    $0x700,%eax
80108842:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108844:	8b 45 14             	mov    0x14(%ebp),%eax
80108847:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010884c:	09 d0                	or     %edx,%eax
8010884e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108853:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108856:	ff 75 fc             	push   -0x4(%ebp)
80108859:	e8 ed fe ff ff       	call   8010874b <pci_write_config>
8010885e:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108861:	ff 75 18             	push   0x18(%ebp)
80108864:	e8 f7 fe ff ff       	call   80108760 <pci_write_data>
80108869:	83 c4 04             	add    $0x4,%esp
}
8010886c:	90                   	nop
8010886d:	c9                   	leave
8010886e:	c3                   	ret

8010886f <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010886f:	f3 0f 1e fb          	endbr32
80108873:	55                   	push   %ebp
80108874:	89 e5                	mov    %esp,%ebp
80108876:	53                   	push   %ebx
80108877:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010887a:	8b 45 08             	mov    0x8(%ebp),%eax
8010887d:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108882:	8b 45 0c             	mov    0xc(%ebp),%eax
80108885:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
8010888a:	8b 45 10             	mov    0x10(%ebp),%eax
8010888d:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108892:	ff 75 10             	push   0x10(%ebp)
80108895:	ff 75 0c             	push   0xc(%ebp)
80108898:	ff 75 08             	push   0x8(%ebp)
8010889b:	68 04 c6 10 80       	push   $0x8010c604
801088a0:	e8 67 7b ff ff       	call   8010040c <cprintf>
801088a5:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801088a8:	83 ec 0c             	sub    $0xc,%esp
801088ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088ae:	50                   	push   %eax
801088af:	6a 00                	push   $0x0
801088b1:	ff 75 10             	push   0x10(%ebp)
801088b4:	ff 75 0c             	push   0xc(%ebp)
801088b7:	ff 75 08             	push   0x8(%ebp)
801088ba:	e8 fd fe ff ff       	call   801087bc <pci_access_config>
801088bf:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801088c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c5:	c1 e8 10             	shr    $0x10,%eax
801088c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801088cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ce:	25 ff ff 00 00       	and    $0xffff,%eax
801088d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801088d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d9:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801088de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e1:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801088e6:	83 ec 04             	sub    $0x4,%esp
801088e9:	ff 75 f0             	push   -0x10(%ebp)
801088ec:	ff 75 f4             	push   -0xc(%ebp)
801088ef:	68 38 c6 10 80       	push   $0x8010c638
801088f4:	e8 13 7b ff ff       	call   8010040c <cprintf>
801088f9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801088fc:	83 ec 0c             	sub    $0xc,%esp
801088ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108902:	50                   	push   %eax
80108903:	6a 08                	push   $0x8
80108905:	ff 75 10             	push   0x10(%ebp)
80108908:	ff 75 0c             	push   0xc(%ebp)
8010890b:	ff 75 08             	push   0x8(%ebp)
8010890e:	e8 a9 fe ff ff       	call   801087bc <pci_access_config>
80108913:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108919:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010891c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010891f:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108922:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108928:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010892b:	0f b6 c0             	movzbl %al,%eax
8010892e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108931:	c1 eb 18             	shr    $0x18,%ebx
80108934:	83 ec 0c             	sub    $0xc,%esp
80108937:	51                   	push   %ecx
80108938:	52                   	push   %edx
80108939:	50                   	push   %eax
8010893a:	53                   	push   %ebx
8010893b:	68 5c c6 10 80       	push   $0x8010c65c
80108940:	e8 c7 7a ff ff       	call   8010040c <cprintf>
80108945:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108948:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894b:	c1 e8 18             	shr    $0x18,%eax
8010894e:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
80108953:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108956:	c1 e8 10             	shr    $0x10,%eax
80108959:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
8010895e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108961:	c1 e8 08             	shr    $0x8,%eax
80108964:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
80108969:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896c:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108971:	83 ec 0c             	sub    $0xc,%esp
80108974:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108977:	50                   	push   %eax
80108978:	6a 10                	push   $0x10
8010897a:	ff 75 10             	push   0x10(%ebp)
8010897d:	ff 75 0c             	push   0xc(%ebp)
80108980:	ff 75 08             	push   0x8(%ebp)
80108983:	e8 34 fe ff ff       	call   801087bc <pci_access_config>
80108988:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010898b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898e:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108993:	83 ec 0c             	sub    $0xc,%esp
80108996:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108999:	50                   	push   %eax
8010899a:	6a 14                	push   $0x14
8010899c:	ff 75 10             	push   0x10(%ebp)
8010899f:	ff 75 0c             	push   0xc(%ebp)
801089a2:	ff 75 08             	push   0x8(%ebp)
801089a5:	e8 12 fe ff ff       	call   801087bc <pci_access_config>
801089aa:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801089ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b0:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089b5:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801089bc:	75 5a                	jne    80108a18 <pci_init_device+0x1a9>
801089be:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801089c5:	75 51                	jne    80108a18 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801089c7:	83 ec 0c             	sub    $0xc,%esp
801089ca:	68 a1 c6 10 80       	push   $0x8010c6a1
801089cf:	e8 38 7a ff ff       	call   8010040c <cprintf>
801089d4:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801089d7:	83 ec 0c             	sub    $0xc,%esp
801089da:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089dd:	50                   	push   %eax
801089de:	68 f0 00 00 00       	push   $0xf0
801089e3:	ff 75 10             	push   0x10(%ebp)
801089e6:	ff 75 0c             	push   0xc(%ebp)
801089e9:	ff 75 08             	push   0x8(%ebp)
801089ec:	e8 cb fd ff ff       	call   801087bc <pci_access_config>
801089f1:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801089f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f7:	83 ec 08             	sub    $0x8,%esp
801089fa:	50                   	push   %eax
801089fb:	68 bb c6 10 80       	push   $0x8010c6bb
80108a00:	e8 07 7a ff ff       	call   8010040c <cprintf>
80108a05:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108a08:	83 ec 0c             	sub    $0xc,%esp
80108a0b:	68 9c 80 19 80       	push   $0x8019809c
80108a10:	e8 09 00 00 00       	call   80108a1e <i8254_init>
80108a15:	83 c4 10             	add    $0x10,%esp
  }
}
80108a18:	90                   	nop
80108a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a1c:	c9                   	leave
80108a1d:	c3                   	ret

80108a1e <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a1e:	f3 0f 1e fb          	endbr32
80108a22:	55                   	push   %ebp
80108a23:	89 e5                	mov    %esp,%ebp
80108a25:	53                   	push   %ebx
80108a26:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a29:	8b 45 08             	mov    0x8(%ebp),%eax
80108a2c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a30:	0f b6 c8             	movzbl %al,%ecx
80108a33:	8b 45 08             	mov    0x8(%ebp),%eax
80108a36:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a3a:	0f b6 d0             	movzbl %al,%edx
80108a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a40:	0f b6 00             	movzbl (%eax),%eax
80108a43:	0f b6 c0             	movzbl %al,%eax
80108a46:	83 ec 0c             	sub    $0xc,%esp
80108a49:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a4c:	53                   	push   %ebx
80108a4d:	6a 04                	push   $0x4
80108a4f:	51                   	push   %ecx
80108a50:	52                   	push   %edx
80108a51:	50                   	push   %eax
80108a52:	e8 65 fd ff ff       	call   801087bc <pci_access_config>
80108a57:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a5d:	83 c8 04             	or     $0x4,%eax
80108a60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a63:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a66:	8b 45 08             	mov    0x8(%ebp),%eax
80108a69:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a6d:	0f b6 c8             	movzbl %al,%ecx
80108a70:	8b 45 08             	mov    0x8(%ebp),%eax
80108a73:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a77:	0f b6 d0             	movzbl %al,%edx
80108a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7d:	0f b6 00             	movzbl (%eax),%eax
80108a80:	0f b6 c0             	movzbl %al,%eax
80108a83:	83 ec 0c             	sub    $0xc,%esp
80108a86:	53                   	push   %ebx
80108a87:	6a 04                	push   $0x4
80108a89:	51                   	push   %ecx
80108a8a:	52                   	push   %edx
80108a8b:	50                   	push   %eax
80108a8c:	e8 84 fd ff ff       	call   80108815 <pci_write_config_register>
80108a91:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a94:	8b 45 08             	mov    0x8(%ebp),%eax
80108a97:	8b 40 10             	mov    0x10(%eax),%eax
80108a9a:	05 00 00 00 40       	add    $0x40000000,%eax
80108a9f:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108aa4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108aac:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ab1:	05 d8 00 00 00       	add    $0xd8,%eax
80108ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108abc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac5:	8b 00                	mov    (%eax),%eax
80108ac7:	0d 00 00 00 04       	or     $0x4000000,%eax
80108acc:	89 c2                	mov    %eax,%edx
80108ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad1:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad6:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108adf:	8b 00                	mov    (%eax),%eax
80108ae1:	83 c8 40             	or     $0x40,%eax
80108ae4:	89 c2                	mov    %eax,%edx
80108ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae9:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aee:	8b 10                	mov    (%eax),%edx
80108af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af3:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108af5:	83 ec 0c             	sub    $0xc,%esp
80108af8:	68 d0 c6 10 80       	push   $0x8010c6d0
80108afd:	e8 0a 79 ff ff       	call   8010040c <cprintf>
80108b02:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108b05:	e8 f5 9d ff ff       	call   801028ff <kalloc>
80108b0a:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
80108b0f:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b1a:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108b1f:	83 ec 08             	sub    $0x8,%esp
80108b22:	50                   	push   %eax
80108b23:	68 f2 c6 10 80       	push   $0x8010c6f2
80108b28:	e8 df 78 ff ff       	call   8010040c <cprintf>
80108b2d:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b30:	e8 50 00 00 00       	call   80108b85 <i8254_init_recv>
  i8254_init_send();
80108b35:	e8 6d 03 00 00       	call   80108ea7 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b3a:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b41:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b44:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b4b:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b4e:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b55:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b58:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b5f:	0f b6 c0             	movzbl %al,%eax
80108b62:	83 ec 0c             	sub    $0xc,%esp
80108b65:	53                   	push   %ebx
80108b66:	51                   	push   %ecx
80108b67:	52                   	push   %edx
80108b68:	50                   	push   %eax
80108b69:	68 00 c7 10 80       	push   $0x8010c700
80108b6e:	e8 99 78 ff ff       	call   8010040c <cprintf>
80108b73:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b7f:	90                   	nop
80108b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b83:	c9                   	leave
80108b84:	c3                   	ret

80108b85 <i8254_init_recv>:

void i8254_init_recv(){
80108b85:	f3 0f 1e fb          	endbr32
80108b89:	55                   	push   %ebp
80108b8a:	89 e5                	mov    %esp,%ebp
80108b8c:	57                   	push   %edi
80108b8d:	56                   	push   %esi
80108b8e:	53                   	push   %ebx
80108b8f:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b92:	83 ec 0c             	sub    $0xc,%esp
80108b95:	6a 00                	push   $0x0
80108b97:	e8 ec 04 00 00       	call   80109088 <i8254_read_eeprom>
80108b9c:	83 c4 10             	add    $0x10,%esp
80108b9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108ba2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ba5:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108baa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bad:	c1 e8 08             	shr    $0x8,%eax
80108bb0:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108bb5:	83 ec 0c             	sub    $0xc,%esp
80108bb8:	6a 01                	push   $0x1
80108bba:	e8 c9 04 00 00       	call   80109088 <i8254_read_eeprom>
80108bbf:	83 c4 10             	add    $0x10,%esp
80108bc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108bc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bc8:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108bcd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bd0:	c1 e8 08             	shr    $0x8,%eax
80108bd3:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108bd8:	83 ec 0c             	sub    $0xc,%esp
80108bdb:	6a 02                	push   $0x2
80108bdd:	e8 a6 04 00 00       	call   80109088 <i8254_read_eeprom>
80108be2:	83 c4 10             	add    $0x10,%esp
80108be5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108be8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108beb:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108bf0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bf3:	c1 e8 08             	shr    $0x8,%eax
80108bf6:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108bfb:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c02:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c05:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c0c:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108c0f:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c16:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c19:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c20:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c23:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c2a:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c2d:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c34:	0f b6 c0             	movzbl %al,%eax
80108c37:	83 ec 04             	sub    $0x4,%esp
80108c3a:	57                   	push   %edi
80108c3b:	56                   	push   %esi
80108c3c:	53                   	push   %ebx
80108c3d:	51                   	push   %ecx
80108c3e:	52                   	push   %edx
80108c3f:	50                   	push   %eax
80108c40:	68 18 c7 10 80       	push   $0x8010c718
80108c45:	e8 c2 77 ff ff       	call   8010040c <cprintf>
80108c4a:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c4d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c52:	05 00 54 00 00       	add    $0x5400,%eax
80108c57:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c5a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c5f:	05 04 54 00 00       	add    $0x5404,%eax
80108c64:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c6a:	c1 e0 10             	shl    $0x10,%eax
80108c6d:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c70:	89 c2                	mov    %eax,%edx
80108c72:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c75:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c77:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c7a:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c7f:	89 c2                	mov    %eax,%edx
80108c81:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c84:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c86:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c8b:	05 00 52 00 00       	add    $0x5200,%eax
80108c90:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c9a:	eb 19                	jmp    80108cb5 <i8254_init_recv+0x130>
    mta[i] = 0;
80108c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ca6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ca9:	01 d0                	add    %edx,%eax
80108cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108cb1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108cb5:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108cb9:	7e e1                	jle    80108c9c <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108cbb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cc0:	05 d0 00 00 00       	add    $0xd0,%eax
80108cc5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cc8:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ccb:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108cd1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cd6:	05 c8 00 00 00       	add    $0xc8,%eax
80108cdb:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108cde:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ce1:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ce7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108cec:	05 28 28 00 00       	add    $0x2828,%eax
80108cf1:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108cf4:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108cf7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108cfd:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d02:	05 00 01 00 00       	add    $0x100,%eax
80108d07:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108d0a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d0d:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d13:	e8 e7 9b ff ff       	call   801028ff <kalloc>
80108d18:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d1b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d20:	05 00 28 00 00       	add    $0x2800,%eax
80108d25:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d28:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d2d:	05 04 28 00 00       	add    $0x2804,%eax
80108d32:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d35:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d3a:	05 08 28 00 00       	add    $0x2808,%eax
80108d3f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d42:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d47:	05 10 28 00 00       	add    $0x2810,%eax
80108d4c:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d4f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d54:	05 18 28 00 00       	add    $0x2818,%eax
80108d59:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d5c:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d5f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d65:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d68:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d6a:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d6d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d73:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d76:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d7c:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d85:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d88:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d8e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d91:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d94:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d9b:	eb 73                	jmp    80108e10 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da0:	c1 e0 04             	shl    $0x4,%eax
80108da3:	89 c2                	mov    %eax,%edx
80108da5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108da8:	01 d0                	add    %edx,%eax
80108daa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108db1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db4:	c1 e0 04             	shl    $0x4,%eax
80108db7:	89 c2                	mov    %eax,%edx
80108db9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dbc:	01 d0                	add    %edx,%eax
80108dbe:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc7:	c1 e0 04             	shl    $0x4,%eax
80108dca:	89 c2                	mov    %eax,%edx
80108dcc:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dcf:	01 d0                	add    %edx,%eax
80108dd1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dda:	c1 e0 04             	shl    $0x4,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de2:	01 d0                	add    %edx,%eax
80108de4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108deb:	c1 e0 04             	shl    $0x4,%eax
80108dee:	89 c2                	mov    %eax,%edx
80108df0:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dfc:	c1 e0 04             	shl    $0x4,%eax
80108dff:	89 c2                	mov    %eax,%edx
80108e01:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e04:	01 d0                	add    %edx,%eax
80108e06:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e0c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108e10:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e17:	7e 84                	jle    80108d9d <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e19:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e20:	eb 57                	jmp    80108e79 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108e22:	e8 d8 9a ff ff       	call   801028ff <kalloc>
80108e27:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e2a:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e2e:	75 12                	jne    80108e42 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108e30:	83 ec 0c             	sub    $0xc,%esp
80108e33:	68 38 c7 10 80       	push   $0x8010c738
80108e38:	e8 cf 75 ff ff       	call   8010040c <cprintf>
80108e3d:	83 c4 10             	add    $0x10,%esp
      break;
80108e40:	eb 3d                	jmp    80108e7f <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e42:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e45:	c1 e0 04             	shl    $0x4,%eax
80108e48:	89 c2                	mov    %eax,%edx
80108e4a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e4d:	01 d0                	add    %edx,%eax
80108e4f:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e52:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e58:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e5d:	83 c0 01             	add    $0x1,%eax
80108e60:	c1 e0 04             	shl    $0x4,%eax
80108e63:	89 c2                	mov    %eax,%edx
80108e65:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e68:	01 d0                	add    %edx,%eax
80108e6a:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e6d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e73:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e75:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e79:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e7d:	7e a3                	jle    80108e22 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108e7f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e82:	8b 00                	mov    (%eax),%eax
80108e84:	83 c8 02             	or     $0x2,%eax
80108e87:	89 c2                	mov    %eax,%edx
80108e89:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e8c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e8e:	83 ec 0c             	sub    $0xc,%esp
80108e91:	68 58 c7 10 80       	push   $0x8010c758
80108e96:	e8 71 75 ff ff       	call   8010040c <cprintf>
80108e9b:	83 c4 10             	add    $0x10,%esp
}
80108e9e:	90                   	nop
80108e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108ea2:	5b                   	pop    %ebx
80108ea3:	5e                   	pop    %esi
80108ea4:	5f                   	pop    %edi
80108ea5:	5d                   	pop    %ebp
80108ea6:	c3                   	ret

80108ea7 <i8254_init_send>:

void i8254_init_send(){
80108ea7:	f3 0f 1e fb          	endbr32
80108eab:	55                   	push   %ebp
80108eac:	89 e5                	mov    %esp,%ebp
80108eae:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108eb1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eb6:	05 28 38 00 00       	add    $0x3828,%eax
80108ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ec1:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108ec7:	e8 33 9a ff ff       	call   801028ff <kalloc>
80108ecc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ecf:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ed4:	05 00 38 00 00       	add    $0x3800,%eax
80108ed9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108edc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ee1:	05 04 38 00 00       	add    $0x3804,%eax
80108ee6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108ee9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eee:	05 08 38 00 00       	add    $0x3808,%eax
80108ef3:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ef6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f02:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108f0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f10:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f16:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f1b:	05 10 38 00 00       	add    $0x3810,%eax
80108f20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f23:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f28:	05 18 38 00 00       	add    $0x3818,%eax
80108f2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f39:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f45:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f4f:	e9 82 00 00 00       	jmp    80108fd6 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f57:	c1 e0 04             	shl    $0x4,%eax
80108f5a:	89 c2                	mov    %eax,%edx
80108f5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f5f:	01 d0                	add    %edx,%eax
80108f61:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6b:	c1 e0 04             	shl    $0x4,%eax
80108f6e:	89 c2                	mov    %eax,%edx
80108f70:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f73:	01 d0                	add    %edx,%eax
80108f75:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7e:	c1 e0 04             	shl    $0x4,%eax
80108f81:	89 c2                	mov    %eax,%edx
80108f83:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f86:	01 d0                	add    %edx,%eax
80108f88:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8f:	c1 e0 04             	shl    $0x4,%eax
80108f92:	89 c2                	mov    %eax,%edx
80108f94:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f97:	01 d0                	add    %edx,%eax
80108f99:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa0:	c1 e0 04             	shl    $0x4,%eax
80108fa3:	89 c2                	mov    %eax,%edx
80108fa5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fa8:	01 d0                	add    %edx,%eax
80108faa:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb1:	c1 e0 04             	shl    $0x4,%eax
80108fb4:	89 c2                	mov    %eax,%edx
80108fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fb9:	01 d0                	add    %edx,%eax
80108fbb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc2:	c1 e0 04             	shl    $0x4,%eax
80108fc5:	89 c2                	mov    %eax,%edx
80108fc7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fca:	01 d0                	add    %edx,%eax
80108fcc:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108fd6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108fdd:	0f 8e 71 ff ff ff    	jle    80108f54 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fe3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fea:	eb 57                	jmp    80109043 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108fec:	e8 0e 99 ff ff       	call   801028ff <kalloc>
80108ff1:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ff4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ff8:	75 12                	jne    8010900c <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108ffa:	83 ec 0c             	sub    $0xc,%esp
80108ffd:	68 38 c7 10 80       	push   $0x8010c738
80109002:	e8 05 74 ff ff       	call   8010040c <cprintf>
80109007:	83 c4 10             	add    $0x10,%esp
      break;
8010900a:	eb 3d                	jmp    80109049 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010900c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900f:	c1 e0 04             	shl    $0x4,%eax
80109012:	89 c2                	mov    %eax,%edx
80109014:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109017:	01 d0                	add    %edx,%eax
80109019:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010901c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109022:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109027:	83 c0 01             	add    $0x1,%eax
8010902a:	c1 e0 04             	shl    $0x4,%eax
8010902d:	89 c2                	mov    %eax,%edx
8010902f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109032:	01 d0                	add    %edx,%eax
80109034:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109037:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010903d:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010903f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109043:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109047:	7e a3                	jle    80108fec <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109049:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010904e:	05 00 04 00 00       	add    $0x400,%eax
80109053:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109056:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109059:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010905f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109064:	05 10 04 00 00       	add    $0x410,%eax
80109069:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010906c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010906f:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109075:	83 ec 0c             	sub    $0xc,%esp
80109078:	68 78 c7 10 80       	push   $0x8010c778
8010907d:	e8 8a 73 ff ff       	call   8010040c <cprintf>
80109082:	83 c4 10             	add    $0x10,%esp

}
80109085:	90                   	nop
80109086:	c9                   	leave
80109087:	c3                   	ret

80109088 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109088:	f3 0f 1e fb          	endbr32
8010908c:	55                   	push   %ebp
8010908d:	89 e5                	mov    %esp,%ebp
8010908f:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109092:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109097:	83 c0 14             	add    $0x14,%eax
8010909a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010909d:	8b 45 08             	mov    0x8(%ebp),%eax
801090a0:	c1 e0 08             	shl    $0x8,%eax
801090a3:	0f b7 c0             	movzwl %ax,%eax
801090a6:	83 c8 01             	or     $0x1,%eax
801090a9:	89 c2                	mov    %eax,%edx
801090ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ae:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801090b0:	83 ec 0c             	sub    $0xc,%esp
801090b3:	68 98 c7 10 80       	push   $0x8010c798
801090b8:	e8 4f 73 ff ff       	call   8010040c <cprintf>
801090bd:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c3:	8b 00                	mov    (%eax),%eax
801090c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090cb:	83 e0 10             	and    $0x10,%eax
801090ce:	85 c0                	test   %eax,%eax
801090d0:	75 02                	jne    801090d4 <i8254_read_eeprom+0x4c>
  while(1){
801090d2:	eb dc                	jmp    801090b0 <i8254_read_eeprom+0x28>
      break;
801090d4:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801090d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d8:	8b 00                	mov    (%eax),%eax
801090da:	c1 e8 10             	shr    $0x10,%eax
}
801090dd:	c9                   	leave
801090de:	c3                   	ret

801090df <i8254_recv>:
void i8254_recv(){
801090df:	f3 0f 1e fb          	endbr32
801090e3:	55                   	push   %ebp
801090e4:	89 e5                	mov    %esp,%ebp
801090e6:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801090e9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090ee:	05 10 28 00 00       	add    $0x2810,%eax
801090f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801090f6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090fb:	05 18 28 00 00       	add    $0x2818,%eax
80109100:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109103:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109108:	05 00 28 00 00       	add    $0x2800,%eax
8010910d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109113:	8b 00                	mov    (%eax),%eax
80109115:	05 00 00 00 80       	add    $0x80000000,%eax
8010911a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010911d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109120:	8b 10                	mov    (%eax),%edx
80109122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109125:	8b 00                	mov    (%eax),%eax
80109127:	29 c2                	sub    %eax,%edx
80109129:	89 d0                	mov    %edx,%eax
8010912b:	25 ff 00 00 00       	and    $0xff,%eax
80109130:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109133:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109137:	7e 37                	jle    80109170 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913c:	8b 00                	mov    (%eax),%eax
8010913e:	c1 e0 04             	shl    $0x4,%eax
80109141:	89 c2                	mov    %eax,%edx
80109143:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109146:	01 d0                	add    %edx,%eax
80109148:	8b 00                	mov    (%eax),%eax
8010914a:	05 00 00 00 80       	add    $0x80000000,%eax
8010914f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109155:	8b 00                	mov    (%eax),%eax
80109157:	83 c0 01             	add    $0x1,%eax
8010915a:	0f b6 d0             	movzbl %al,%edx
8010915d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109160:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109162:	83 ec 0c             	sub    $0xc,%esp
80109165:	ff 75 e0             	push   -0x20(%ebp)
80109168:	e8 47 09 00 00       	call   80109ab4 <eth_proc>
8010916d:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109173:	8b 10                	mov    (%eax),%edx
80109175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109178:	8b 00                	mov    (%eax),%eax
8010917a:	39 c2                	cmp    %eax,%edx
8010917c:	75 9f                	jne    8010911d <i8254_recv+0x3e>
      (*rdt)--;
8010917e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109181:	8b 00                	mov    (%eax),%eax
80109183:	8d 50 ff             	lea    -0x1(%eax),%edx
80109186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109189:	89 10                	mov    %edx,(%eax)
  while(1){
8010918b:	eb 90                	jmp    8010911d <i8254_recv+0x3e>

8010918d <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010918d:	f3 0f 1e fb          	endbr32
80109191:	55                   	push   %ebp
80109192:	89 e5                	mov    %esp,%ebp
80109194:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109197:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010919c:	05 10 38 00 00       	add    $0x3810,%eax
801091a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801091a4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801091a9:	05 18 38 00 00       	add    $0x3818,%eax
801091ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091b1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801091b6:	05 00 38 00 00       	add    $0x3800,%eax
801091bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801091be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091c1:	8b 00                	mov    (%eax),%eax
801091c3:	05 00 00 00 80       	add    $0x80000000,%eax
801091c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ce:	8b 10                	mov    (%eax),%edx
801091d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d3:	8b 00                	mov    (%eax),%eax
801091d5:	29 c2                	sub    %eax,%edx
801091d7:	89 d0                	mov    %edx,%eax
801091d9:	0f b6 c0             	movzbl %al,%eax
801091dc:	ba 00 01 00 00       	mov    $0x100,%edx
801091e1:	29 c2                	sub    %eax,%edx
801091e3:	89 d0                	mov    %edx,%eax
801091e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801091e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091eb:	8b 00                	mov    (%eax),%eax
801091ed:	25 ff 00 00 00       	and    $0xff,%eax
801091f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801091f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091f9:	0f 8e a8 00 00 00    	jle    801092a7 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801091ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109202:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109205:	89 d1                	mov    %edx,%ecx
80109207:	c1 e1 04             	shl    $0x4,%ecx
8010920a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010920d:	01 ca                	add    %ecx,%edx
8010920f:	8b 12                	mov    (%edx),%edx
80109211:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109217:	83 ec 04             	sub    $0x4,%esp
8010921a:	ff 75 0c             	push   0xc(%ebp)
8010921d:	50                   	push   %eax
8010921e:	52                   	push   %edx
8010921f:	e8 dc bb ff ff       	call   80104e00 <memmove>
80109224:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109227:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010922a:	c1 e0 04             	shl    $0x4,%eax
8010922d:	89 c2                	mov    %eax,%edx
8010922f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109232:	01 d0                	add    %edx,%eax
80109234:	8b 55 0c             	mov    0xc(%ebp),%edx
80109237:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010923b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010923e:	c1 e0 04             	shl    $0x4,%eax
80109241:	89 c2                	mov    %eax,%edx
80109243:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109246:	01 d0                	add    %edx,%eax
80109248:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010924c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010924f:	c1 e0 04             	shl    $0x4,%eax
80109252:	89 c2                	mov    %eax,%edx
80109254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109257:	01 d0                	add    %edx,%eax
80109259:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010925d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109260:	c1 e0 04             	shl    $0x4,%eax
80109263:	89 c2                	mov    %eax,%edx
80109265:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109268:	01 d0                	add    %edx,%eax
8010926a:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010926e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109271:	c1 e0 04             	shl    $0x4,%eax
80109274:	89 c2                	mov    %eax,%edx
80109276:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109279:	01 d0                	add    %edx,%eax
8010927b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109281:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109284:	c1 e0 04             	shl    $0x4,%eax
80109287:	89 c2                	mov    %eax,%edx
80109289:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010928c:	01 d0                	add    %edx,%eax
8010928e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109295:	8b 00                	mov    (%eax),%eax
80109297:	83 c0 01             	add    $0x1,%eax
8010929a:	0f b6 d0             	movzbl %al,%edx
8010929d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a0:	89 10                	mov    %edx,(%eax)
    return len;
801092a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801092a5:	eb 05                	jmp    801092ac <i8254_send+0x11f>
  }else{
    return -1;
801092a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801092ac:	c9                   	leave
801092ad:	c3                   	ret

801092ae <i8254_intr>:

void i8254_intr(){
801092ae:	f3 0f 1e fb          	endbr32
801092b2:	55                   	push   %ebp
801092b3:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801092b5:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801092ba:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801092c0:	90                   	nop
801092c1:	5d                   	pop    %ebp
801092c2:	c3                   	ret

801092c3 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801092c3:	f3 0f 1e fb          	endbr32
801092c7:	55                   	push   %ebp
801092c8:	89 e5                	mov    %esp,%ebp
801092ca:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092cd:	8b 45 08             	mov    0x8(%ebp),%eax
801092d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d6:	0f b7 00             	movzwl (%eax),%eax
801092d9:	66 3d 00 01          	cmp    $0x100,%ax
801092dd:	74 0a                	je     801092e9 <arp_proc+0x26>
801092df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092e4:	e9 4f 01 00 00       	jmp    80109438 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801092e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ec:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801092f0:	66 83 f8 08          	cmp    $0x8,%ax
801092f4:	74 0a                	je     80109300 <arp_proc+0x3d>
801092f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092fb:	e9 38 01 00 00       	jmp    80109438 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109303:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109307:	3c 06                	cmp    $0x6,%al
80109309:	74 0a                	je     80109315 <arp_proc+0x52>
8010930b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109310:	e9 23 01 00 00       	jmp    80109438 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109318:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010931c:	3c 04                	cmp    $0x4,%al
8010931e:	74 0a                	je     8010932a <arp_proc+0x67>
80109320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109325:	e9 0e 01 00 00       	jmp    80109438 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010932a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932d:	83 c0 18             	add    $0x18,%eax
80109330:	83 ec 04             	sub    $0x4,%esp
80109333:	6a 04                	push   $0x4
80109335:	50                   	push   %eax
80109336:	68 e4 f4 10 80       	push   $0x8010f4e4
8010933b:	e8 64 ba ff ff       	call   80104da4 <memcmp>
80109340:	83 c4 10             	add    $0x10,%esp
80109343:	85 c0                	test   %eax,%eax
80109345:	74 27                	je     8010936e <arp_proc+0xab>
80109347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934a:	83 c0 0e             	add    $0xe,%eax
8010934d:	83 ec 04             	sub    $0x4,%esp
80109350:	6a 04                	push   $0x4
80109352:	50                   	push   %eax
80109353:	68 e4 f4 10 80       	push   $0x8010f4e4
80109358:	e8 47 ba ff ff       	call   80104da4 <memcmp>
8010935d:	83 c4 10             	add    $0x10,%esp
80109360:	85 c0                	test   %eax,%eax
80109362:	74 0a                	je     8010936e <arp_proc+0xab>
80109364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109369:	e9 ca 00 00 00       	jmp    80109438 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010936e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109371:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109375:	66 3d 00 01          	cmp    $0x100,%ax
80109379:	75 69                	jne    801093e4 <arp_proc+0x121>
8010937b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937e:	83 c0 18             	add    $0x18,%eax
80109381:	83 ec 04             	sub    $0x4,%esp
80109384:	6a 04                	push   $0x4
80109386:	50                   	push   %eax
80109387:	68 e4 f4 10 80       	push   $0x8010f4e4
8010938c:	e8 13 ba ff ff       	call   80104da4 <memcmp>
80109391:	83 c4 10             	add    $0x10,%esp
80109394:	85 c0                	test   %eax,%eax
80109396:	75 4c                	jne    801093e4 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109398:	e8 62 95 ff ff       	call   801028ff <kalloc>
8010939d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801093a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801093a7:	83 ec 04             	sub    $0x4,%esp
801093aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093ad:	50                   	push   %eax
801093ae:	ff 75 f0             	push   -0x10(%ebp)
801093b1:	ff 75 f4             	push   -0xc(%ebp)
801093b4:	e8 33 04 00 00       	call   801097ec <arp_reply_pkt_create>
801093b9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801093bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093bf:	83 ec 08             	sub    $0x8,%esp
801093c2:	50                   	push   %eax
801093c3:	ff 75 f0             	push   -0x10(%ebp)
801093c6:	e8 c2 fd ff ff       	call   8010918d <i8254_send>
801093cb:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d1:	83 ec 0c             	sub    $0xc,%esp
801093d4:	50                   	push   %eax
801093d5:	e8 87 94 ff ff       	call   80102861 <kfree>
801093da:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093dd:	b8 02 00 00 00       	mov    $0x2,%eax
801093e2:	eb 54                	jmp    80109438 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093eb:	66 3d 00 02          	cmp    $0x200,%ax
801093ef:	75 42                	jne    80109433 <arp_proc+0x170>
801093f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f4:	83 c0 18             	add    $0x18,%eax
801093f7:	83 ec 04             	sub    $0x4,%esp
801093fa:	6a 04                	push   $0x4
801093fc:	50                   	push   %eax
801093fd:	68 e4 f4 10 80       	push   $0x8010f4e4
80109402:	e8 9d b9 ff ff       	call   80104da4 <memcmp>
80109407:	83 c4 10             	add    $0x10,%esp
8010940a:	85 c0                	test   %eax,%eax
8010940c:	75 25                	jne    80109433 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010940e:	83 ec 0c             	sub    $0xc,%esp
80109411:	68 9c c7 10 80       	push   $0x8010c79c
80109416:	e8 f1 6f ff ff       	call   8010040c <cprintf>
8010941b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010941e:	83 ec 0c             	sub    $0xc,%esp
80109421:	ff 75 f4             	push   -0xc(%ebp)
80109424:	e8 b7 01 00 00       	call   801095e0 <arp_table_update>
80109429:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010942c:	b8 01 00 00 00       	mov    $0x1,%eax
80109431:	eb 05                	jmp    80109438 <arp_proc+0x175>
  }else{
    return -1;
80109433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109438:	c9                   	leave
80109439:	c3                   	ret

8010943a <arp_scan>:

void arp_scan(){
8010943a:	f3 0f 1e fb          	endbr32
8010943e:	55                   	push   %ebp
8010943f:	89 e5                	mov    %esp,%ebp
80109441:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109444:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010944b:	eb 6f                	jmp    801094bc <arp_scan+0x82>
    uint send = (uint)kalloc();
8010944d:	e8 ad 94 ff ff       	call   801028ff <kalloc>
80109452:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109455:	83 ec 04             	sub    $0x4,%esp
80109458:	ff 75 f4             	push   -0xc(%ebp)
8010945b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010945e:	50                   	push   %eax
8010945f:	ff 75 ec             	push   -0x14(%ebp)
80109462:	e8 62 00 00 00       	call   801094c9 <arp_broadcast>
80109467:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010946a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010946d:	83 ec 08             	sub    $0x8,%esp
80109470:	50                   	push   %eax
80109471:	ff 75 ec             	push   -0x14(%ebp)
80109474:	e8 14 fd ff ff       	call   8010918d <i8254_send>
80109479:	83 c4 10             	add    $0x10,%esp
8010947c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010947f:	eb 22                	jmp    801094a3 <arp_scan+0x69>
      microdelay(1);
80109481:	83 ec 0c             	sub    $0xc,%esp
80109484:	6a 01                	push   $0x1
80109486:	e8 26 98 ff ff       	call   80102cb1 <microdelay>
8010948b:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010948e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109491:	83 ec 08             	sub    $0x8,%esp
80109494:	50                   	push   %eax
80109495:	ff 75 ec             	push   -0x14(%ebp)
80109498:	e8 f0 fc ff ff       	call   8010918d <i8254_send>
8010949d:	83 c4 10             	add    $0x10,%esp
801094a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094a3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801094a7:	74 d8                	je     80109481 <arp_scan+0x47>
    }
    kfree((char *)send);
801094a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094ac:	83 ec 0c             	sub    $0xc,%esp
801094af:	50                   	push   %eax
801094b0:	e8 ac 93 ff ff       	call   80102861 <kfree>
801094b5:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801094b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094bc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094c3:	7e 88                	jle    8010944d <arp_scan+0x13>
  }
}
801094c5:	90                   	nop
801094c6:	90                   	nop
801094c7:	c9                   	leave
801094c8:	c3                   	ret

801094c9 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801094c9:	f3 0f 1e fb          	endbr32
801094cd:	55                   	push   %ebp
801094ce:	89 e5                	mov    %esp,%ebp
801094d0:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094d3:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094d7:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094db:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094df:	8b 45 10             	mov    0x10(%ebp),%eax
801094e2:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094e5:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801094ec:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801094f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094f9:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801094ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80109502:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109508:	8b 45 08             	mov    0x8(%ebp),%eax
8010950b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010950e:	8b 45 08             	mov    0x8(%ebp),%eax
80109511:	83 c0 0e             	add    $0xe,%eax
80109514:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010951e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109521:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109528:	83 ec 04             	sub    $0x4,%esp
8010952b:	6a 06                	push   $0x6
8010952d:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109530:	52                   	push   %edx
80109531:	50                   	push   %eax
80109532:	e8 c9 b8 ff ff       	call   80104e00 <memmove>
80109537:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010953a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953d:	83 c0 06             	add    $0x6,%eax
80109540:	83 ec 04             	sub    $0x4,%esp
80109543:	6a 06                	push   $0x6
80109545:	68 68 d0 18 80       	push   $0x8018d068
8010954a:	50                   	push   %eax
8010954b:	e8 b0 b8 ff ff       	call   80104e00 <memmove>
80109550:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109556:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010955b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010955e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109567:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010956b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109575:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010957b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010957e:	8d 50 12             	lea    0x12(%eax),%edx
80109581:	83 ec 04             	sub    $0x4,%esp
80109584:	6a 06                	push   $0x6
80109586:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109589:	50                   	push   %eax
8010958a:	52                   	push   %edx
8010958b:	e8 70 b8 ff ff       	call   80104e00 <memmove>
80109590:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109596:	8d 50 18             	lea    0x18(%eax),%edx
80109599:	83 ec 04             	sub    $0x4,%esp
8010959c:	6a 04                	push   $0x4
8010959e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095a1:	50                   	push   %eax
801095a2:	52                   	push   %edx
801095a3:	e8 58 b8 ff ff       	call   80104e00 <memmove>
801095a8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ae:	83 c0 08             	add    $0x8,%eax
801095b1:	83 ec 04             	sub    $0x4,%esp
801095b4:	6a 06                	push   $0x6
801095b6:	68 68 d0 18 80       	push   $0x8018d068
801095bb:	50                   	push   %eax
801095bc:	e8 3f b8 ff ff       	call   80104e00 <memmove>
801095c1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c7:	83 c0 0e             	add    $0xe,%eax
801095ca:	83 ec 04             	sub    $0x4,%esp
801095cd:	6a 04                	push   $0x4
801095cf:	68 e4 f4 10 80       	push   $0x8010f4e4
801095d4:	50                   	push   %eax
801095d5:	e8 26 b8 ff ff       	call   80104e00 <memmove>
801095da:	83 c4 10             	add    $0x10,%esp
}
801095dd:	90                   	nop
801095de:	c9                   	leave
801095df:	c3                   	ret

801095e0 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095e0:	f3 0f 1e fb          	endbr32
801095e4:	55                   	push   %ebp
801095e5:	89 e5                	mov    %esp,%ebp
801095e7:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095ea:	8b 45 08             	mov    0x8(%ebp),%eax
801095ed:	83 c0 0e             	add    $0xe,%eax
801095f0:	83 ec 0c             	sub    $0xc,%esp
801095f3:	50                   	push   %eax
801095f4:	e8 bc 00 00 00       	call   801096b5 <arp_table_search>
801095f9:	83 c4 10             	add    $0x10,%esp
801095fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801095ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109603:	78 2d                	js     80109632 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109605:	8b 45 08             	mov    0x8(%ebp),%eax
80109608:	8d 48 08             	lea    0x8(%eax),%ecx
8010960b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010960e:	89 d0                	mov    %edx,%eax
80109610:	c1 e0 02             	shl    $0x2,%eax
80109613:	01 d0                	add    %edx,%eax
80109615:	01 c0                	add    %eax,%eax
80109617:	01 d0                	add    %edx,%eax
80109619:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010961e:	83 c0 04             	add    $0x4,%eax
80109621:	83 ec 04             	sub    $0x4,%esp
80109624:	6a 06                	push   $0x6
80109626:	51                   	push   %ecx
80109627:	50                   	push   %eax
80109628:	e8 d3 b7 ff ff       	call   80104e00 <memmove>
8010962d:	83 c4 10             	add    $0x10,%esp
80109630:	eb 70                	jmp    801096a2 <arp_table_update+0xc2>
  }else{
    index += 1;
80109632:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109636:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109639:	8b 45 08             	mov    0x8(%ebp),%eax
8010963c:	8d 48 08             	lea    0x8(%eax),%ecx
8010963f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109642:	89 d0                	mov    %edx,%eax
80109644:	c1 e0 02             	shl    $0x2,%eax
80109647:	01 d0                	add    %edx,%eax
80109649:	01 c0                	add    %eax,%eax
8010964b:	01 d0                	add    %edx,%eax
8010964d:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109652:	83 c0 04             	add    $0x4,%eax
80109655:	83 ec 04             	sub    $0x4,%esp
80109658:	6a 06                	push   $0x6
8010965a:	51                   	push   %ecx
8010965b:	50                   	push   %eax
8010965c:	e8 9f b7 ff ff       	call   80104e00 <memmove>
80109661:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109664:	8b 45 08             	mov    0x8(%ebp),%eax
80109667:	8d 48 0e             	lea    0xe(%eax),%ecx
8010966a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010966d:	89 d0                	mov    %edx,%eax
8010966f:	c1 e0 02             	shl    $0x2,%eax
80109672:	01 d0                	add    %edx,%eax
80109674:	01 c0                	add    %eax,%eax
80109676:	01 d0                	add    %edx,%eax
80109678:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010967d:	83 ec 04             	sub    $0x4,%esp
80109680:	6a 04                	push   $0x4
80109682:	51                   	push   %ecx
80109683:	50                   	push   %eax
80109684:	e8 77 b7 ff ff       	call   80104e00 <memmove>
80109689:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010968c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010968f:	89 d0                	mov    %edx,%eax
80109691:	c1 e0 02             	shl    $0x2,%eax
80109694:	01 d0                	add    %edx,%eax
80109696:	01 c0                	add    %eax,%eax
80109698:	01 d0                	add    %edx,%eax
8010969a:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010969f:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801096a2:	83 ec 0c             	sub    $0xc,%esp
801096a5:	68 80 d0 18 80       	push   $0x8018d080
801096aa:	e8 87 00 00 00       	call   80109736 <print_arp_table>
801096af:	83 c4 10             	add    $0x10,%esp
}
801096b2:	90                   	nop
801096b3:	c9                   	leave
801096b4:	c3                   	ret

801096b5 <arp_table_search>:

int arp_table_search(uchar *ip){
801096b5:	f3 0f 1e fb          	endbr32
801096b9:	55                   	push   %ebp
801096ba:	89 e5                	mov    %esp,%ebp
801096bc:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801096bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096cd:	eb 59                	jmp    80109728 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801096cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096d2:	89 d0                	mov    %edx,%eax
801096d4:	c1 e0 02             	shl    $0x2,%eax
801096d7:	01 d0                	add    %edx,%eax
801096d9:	01 c0                	add    %eax,%eax
801096db:	01 d0                	add    %edx,%eax
801096dd:	05 80 d0 18 80       	add    $0x8018d080,%eax
801096e2:	83 ec 04             	sub    $0x4,%esp
801096e5:	6a 04                	push   $0x4
801096e7:	ff 75 08             	push   0x8(%ebp)
801096ea:	50                   	push   %eax
801096eb:	e8 b4 b6 ff ff       	call   80104da4 <memcmp>
801096f0:	83 c4 10             	add    $0x10,%esp
801096f3:	85 c0                	test   %eax,%eax
801096f5:	75 05                	jne    801096fc <arp_table_search+0x47>
      return i;
801096f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096fa:	eb 38                	jmp    80109734 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801096fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096ff:	89 d0                	mov    %edx,%eax
80109701:	c1 e0 02             	shl    $0x2,%eax
80109704:	01 d0                	add    %edx,%eax
80109706:	01 c0                	add    %eax,%eax
80109708:	01 d0                	add    %edx,%eax
8010970a:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010970f:	0f b6 00             	movzbl (%eax),%eax
80109712:	84 c0                	test   %al,%al
80109714:	75 0e                	jne    80109724 <arp_table_search+0x6f>
80109716:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010971a:	75 08                	jne    80109724 <arp_table_search+0x6f>
      empty = -i;
8010971c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010971f:	f7 d8                	neg    %eax
80109721:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109724:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109728:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010972c:	7e a1                	jle    801096cf <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010972e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109731:	83 e8 01             	sub    $0x1,%eax
}
80109734:	c9                   	leave
80109735:	c3                   	ret

80109736 <print_arp_table>:

void print_arp_table(){
80109736:	f3 0f 1e fb          	endbr32
8010973a:	55                   	push   %ebp
8010973b:	89 e5                	mov    %esp,%ebp
8010973d:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109747:	e9 92 00 00 00       	jmp    801097de <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010974c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010974f:	89 d0                	mov    %edx,%eax
80109751:	c1 e0 02             	shl    $0x2,%eax
80109754:	01 d0                	add    %edx,%eax
80109756:	01 c0                	add    %eax,%eax
80109758:	01 d0                	add    %edx,%eax
8010975a:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010975f:	0f b6 00             	movzbl (%eax),%eax
80109762:	84 c0                	test   %al,%al
80109764:	74 74                	je     801097da <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109766:	83 ec 08             	sub    $0x8,%esp
80109769:	ff 75 f4             	push   -0xc(%ebp)
8010976c:	68 af c7 10 80       	push   $0x8010c7af
80109771:	e8 96 6c ff ff       	call   8010040c <cprintf>
80109776:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109779:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010977c:	89 d0                	mov    %edx,%eax
8010977e:	c1 e0 02             	shl    $0x2,%eax
80109781:	01 d0                	add    %edx,%eax
80109783:	01 c0                	add    %eax,%eax
80109785:	01 d0                	add    %edx,%eax
80109787:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010978c:	83 ec 0c             	sub    $0xc,%esp
8010978f:	50                   	push   %eax
80109790:	e8 5c 02 00 00       	call   801099f1 <print_ipv4>
80109795:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109798:	83 ec 0c             	sub    $0xc,%esp
8010979b:	68 be c7 10 80       	push   $0x8010c7be
801097a0:	e8 67 6c ff ff       	call   8010040c <cprintf>
801097a5:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801097a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097ab:	89 d0                	mov    %edx,%eax
801097ad:	c1 e0 02             	shl    $0x2,%eax
801097b0:	01 d0                	add    %edx,%eax
801097b2:	01 c0                	add    %eax,%eax
801097b4:	01 d0                	add    %edx,%eax
801097b6:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097bb:	83 c0 04             	add    $0x4,%eax
801097be:	83 ec 0c             	sub    $0xc,%esp
801097c1:	50                   	push   %eax
801097c2:	e8 7c 02 00 00       	call   80109a43 <print_mac>
801097c7:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801097ca:	83 ec 0c             	sub    $0xc,%esp
801097cd:	68 c0 c7 10 80       	push   $0x8010c7c0
801097d2:	e8 35 6c ff ff       	call   8010040c <cprintf>
801097d7:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097de:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097e2:	0f 8e 64 ff ff ff    	jle    8010974c <print_arp_table+0x16>
    }
  }
}
801097e8:	90                   	nop
801097e9:	90                   	nop
801097ea:	c9                   	leave
801097eb:	c3                   	ret

801097ec <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097ec:	f3 0f 1e fb          	endbr32
801097f0:	55                   	push   %ebp
801097f1:	89 e5                	mov    %esp,%ebp
801097f3:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097f6:	8b 45 10             	mov    0x10(%ebp),%eax
801097f9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801097ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80109802:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109805:	8b 45 0c             	mov    0xc(%ebp),%eax
80109808:	83 c0 0e             	add    $0xe,%eax
8010980b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010980e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109811:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109818:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010981c:	8b 45 08             	mov    0x8(%ebp),%eax
8010981f:	8d 50 08             	lea    0x8(%eax),%edx
80109822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109825:	83 ec 04             	sub    $0x4,%esp
80109828:	6a 06                	push   $0x6
8010982a:	52                   	push   %edx
8010982b:	50                   	push   %eax
8010982c:	e8 cf b5 ff ff       	call   80104e00 <memmove>
80109831:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109837:	83 c0 06             	add    $0x6,%eax
8010983a:	83 ec 04             	sub    $0x4,%esp
8010983d:	6a 06                	push   $0x6
8010983f:	68 68 d0 18 80       	push   $0x8018d068
80109844:	50                   	push   %eax
80109845:	e8 b6 b5 ff ff       	call   80104e00 <memmove>
8010984a:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010984d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109850:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109858:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010985e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109861:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109868:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010986c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010986f:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109875:	8b 45 08             	mov    0x8(%ebp),%eax
80109878:	8d 50 08             	lea    0x8(%eax),%edx
8010987b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987e:	83 c0 12             	add    $0x12,%eax
80109881:	83 ec 04             	sub    $0x4,%esp
80109884:	6a 06                	push   $0x6
80109886:	52                   	push   %edx
80109887:	50                   	push   %eax
80109888:	e8 73 b5 ff ff       	call   80104e00 <memmove>
8010988d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109890:	8b 45 08             	mov    0x8(%ebp),%eax
80109893:	8d 50 0e             	lea    0xe(%eax),%edx
80109896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109899:	83 c0 18             	add    $0x18,%eax
8010989c:	83 ec 04             	sub    $0x4,%esp
8010989f:	6a 04                	push   $0x4
801098a1:	52                   	push   %edx
801098a2:	50                   	push   %eax
801098a3:	e8 58 b5 ff ff       	call   80104e00 <memmove>
801098a8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801098ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ae:	83 c0 08             	add    $0x8,%eax
801098b1:	83 ec 04             	sub    $0x4,%esp
801098b4:	6a 06                	push   $0x6
801098b6:	68 68 d0 18 80       	push   $0x8018d068
801098bb:	50                   	push   %eax
801098bc:	e8 3f b5 ff ff       	call   80104e00 <memmove>
801098c1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c7:	83 c0 0e             	add    $0xe,%eax
801098ca:	83 ec 04             	sub    $0x4,%esp
801098cd:	6a 04                	push   $0x4
801098cf:	68 e4 f4 10 80       	push   $0x8010f4e4
801098d4:	50                   	push   %eax
801098d5:	e8 26 b5 ff ff       	call   80104e00 <memmove>
801098da:	83 c4 10             	add    $0x10,%esp
}
801098dd:	90                   	nop
801098de:	c9                   	leave
801098df:	c3                   	ret

801098e0 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801098e0:	f3 0f 1e fb          	endbr32
801098e4:	55                   	push   %ebp
801098e5:	89 e5                	mov    %esp,%ebp
801098e7:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098ea:	83 ec 0c             	sub    $0xc,%esp
801098ed:	68 c2 c7 10 80       	push   $0x8010c7c2
801098f2:	e8 15 6b ff ff       	call   8010040c <cprintf>
801098f7:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098fa:	8b 45 08             	mov    0x8(%ebp),%eax
801098fd:	83 c0 0e             	add    $0xe,%eax
80109900:	83 ec 0c             	sub    $0xc,%esp
80109903:	50                   	push   %eax
80109904:	e8 e8 00 00 00       	call   801099f1 <print_ipv4>
80109909:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010990c:	83 ec 0c             	sub    $0xc,%esp
8010990f:	68 c0 c7 10 80       	push   $0x8010c7c0
80109914:	e8 f3 6a ff ff       	call   8010040c <cprintf>
80109919:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010991c:	8b 45 08             	mov    0x8(%ebp),%eax
8010991f:	83 c0 08             	add    $0x8,%eax
80109922:	83 ec 0c             	sub    $0xc,%esp
80109925:	50                   	push   %eax
80109926:	e8 18 01 00 00       	call   80109a43 <print_mac>
8010992b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010992e:	83 ec 0c             	sub    $0xc,%esp
80109931:	68 c0 c7 10 80       	push   $0x8010c7c0
80109936:	e8 d1 6a ff ff       	call   8010040c <cprintf>
8010993b:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010993e:	83 ec 0c             	sub    $0xc,%esp
80109941:	68 d9 c7 10 80       	push   $0x8010c7d9
80109946:	e8 c1 6a ff ff       	call   8010040c <cprintf>
8010994b:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010994e:	8b 45 08             	mov    0x8(%ebp),%eax
80109951:	83 c0 18             	add    $0x18,%eax
80109954:	83 ec 0c             	sub    $0xc,%esp
80109957:	50                   	push   %eax
80109958:	e8 94 00 00 00       	call   801099f1 <print_ipv4>
8010995d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109960:	83 ec 0c             	sub    $0xc,%esp
80109963:	68 c0 c7 10 80       	push   $0x8010c7c0
80109968:	e8 9f 6a ff ff       	call   8010040c <cprintf>
8010996d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109970:	8b 45 08             	mov    0x8(%ebp),%eax
80109973:	83 c0 12             	add    $0x12,%eax
80109976:	83 ec 0c             	sub    $0xc,%esp
80109979:	50                   	push   %eax
8010997a:	e8 c4 00 00 00       	call   80109a43 <print_mac>
8010997f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109982:	83 ec 0c             	sub    $0xc,%esp
80109985:	68 c0 c7 10 80       	push   $0x8010c7c0
8010998a:	e8 7d 6a ff ff       	call   8010040c <cprintf>
8010998f:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109992:	83 ec 0c             	sub    $0xc,%esp
80109995:	68 f0 c7 10 80       	push   $0x8010c7f0
8010999a:	e8 6d 6a ff ff       	call   8010040c <cprintf>
8010999f:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801099a2:	8b 45 08             	mov    0x8(%ebp),%eax
801099a5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099a9:	66 3d 00 01          	cmp    $0x100,%ax
801099ad:	75 12                	jne    801099c1 <print_arp_info+0xe1>
801099af:	83 ec 0c             	sub    $0xc,%esp
801099b2:	68 fc c7 10 80       	push   $0x8010c7fc
801099b7:	e8 50 6a ff ff       	call   8010040c <cprintf>
801099bc:	83 c4 10             	add    $0x10,%esp
801099bf:	eb 1d                	jmp    801099de <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801099c1:	8b 45 08             	mov    0x8(%ebp),%eax
801099c4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099c8:	66 3d 00 02          	cmp    $0x200,%ax
801099cc:	75 10                	jne    801099de <print_arp_info+0xfe>
    cprintf("Reply\n");
801099ce:	83 ec 0c             	sub    $0xc,%esp
801099d1:	68 05 c8 10 80       	push   $0x8010c805
801099d6:	e8 31 6a ff ff       	call   8010040c <cprintf>
801099db:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801099de:	83 ec 0c             	sub    $0xc,%esp
801099e1:	68 c0 c7 10 80       	push   $0x8010c7c0
801099e6:	e8 21 6a ff ff       	call   8010040c <cprintf>
801099eb:	83 c4 10             	add    $0x10,%esp
}
801099ee:	90                   	nop
801099ef:	c9                   	leave
801099f0:	c3                   	ret

801099f1 <print_ipv4>:

void print_ipv4(uchar *ip){
801099f1:	f3 0f 1e fb          	endbr32
801099f5:	55                   	push   %ebp
801099f6:	89 e5                	mov    %esp,%ebp
801099f8:	53                   	push   %ebx
801099f9:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099fc:	8b 45 08             	mov    0x8(%ebp),%eax
801099ff:	83 c0 03             	add    $0x3,%eax
80109a02:	0f b6 00             	movzbl (%eax),%eax
80109a05:	0f b6 d8             	movzbl %al,%ebx
80109a08:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0b:	83 c0 02             	add    $0x2,%eax
80109a0e:	0f b6 00             	movzbl (%eax),%eax
80109a11:	0f b6 c8             	movzbl %al,%ecx
80109a14:	8b 45 08             	mov    0x8(%ebp),%eax
80109a17:	83 c0 01             	add    $0x1,%eax
80109a1a:	0f b6 00             	movzbl (%eax),%eax
80109a1d:	0f b6 d0             	movzbl %al,%edx
80109a20:	8b 45 08             	mov    0x8(%ebp),%eax
80109a23:	0f b6 00             	movzbl (%eax),%eax
80109a26:	0f b6 c0             	movzbl %al,%eax
80109a29:	83 ec 0c             	sub    $0xc,%esp
80109a2c:	53                   	push   %ebx
80109a2d:	51                   	push   %ecx
80109a2e:	52                   	push   %edx
80109a2f:	50                   	push   %eax
80109a30:	68 0c c8 10 80       	push   $0x8010c80c
80109a35:	e8 d2 69 ff ff       	call   8010040c <cprintf>
80109a3a:	83 c4 20             	add    $0x20,%esp
}
80109a3d:	90                   	nop
80109a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a41:	c9                   	leave
80109a42:	c3                   	ret

80109a43 <print_mac>:

void print_mac(uchar *mac){
80109a43:	f3 0f 1e fb          	endbr32
80109a47:	55                   	push   %ebp
80109a48:	89 e5                	mov    %esp,%ebp
80109a4a:	57                   	push   %edi
80109a4b:	56                   	push   %esi
80109a4c:	53                   	push   %ebx
80109a4d:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a50:	8b 45 08             	mov    0x8(%ebp),%eax
80109a53:	83 c0 05             	add    $0x5,%eax
80109a56:	0f b6 00             	movzbl (%eax),%eax
80109a59:	0f b6 f8             	movzbl %al,%edi
80109a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5f:	83 c0 04             	add    $0x4,%eax
80109a62:	0f b6 00             	movzbl (%eax),%eax
80109a65:	0f b6 f0             	movzbl %al,%esi
80109a68:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6b:	83 c0 03             	add    $0x3,%eax
80109a6e:	0f b6 00             	movzbl (%eax),%eax
80109a71:	0f b6 d8             	movzbl %al,%ebx
80109a74:	8b 45 08             	mov    0x8(%ebp),%eax
80109a77:	83 c0 02             	add    $0x2,%eax
80109a7a:	0f b6 00             	movzbl (%eax),%eax
80109a7d:	0f b6 c8             	movzbl %al,%ecx
80109a80:	8b 45 08             	mov    0x8(%ebp),%eax
80109a83:	83 c0 01             	add    $0x1,%eax
80109a86:	0f b6 00             	movzbl (%eax),%eax
80109a89:	0f b6 d0             	movzbl %al,%edx
80109a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8f:	0f b6 00             	movzbl (%eax),%eax
80109a92:	0f b6 c0             	movzbl %al,%eax
80109a95:	83 ec 04             	sub    $0x4,%esp
80109a98:	57                   	push   %edi
80109a99:	56                   	push   %esi
80109a9a:	53                   	push   %ebx
80109a9b:	51                   	push   %ecx
80109a9c:	52                   	push   %edx
80109a9d:	50                   	push   %eax
80109a9e:	68 24 c8 10 80       	push   $0x8010c824
80109aa3:	e8 64 69 ff ff       	call   8010040c <cprintf>
80109aa8:	83 c4 20             	add    $0x20,%esp
}
80109aab:	90                   	nop
80109aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109aaf:	5b                   	pop    %ebx
80109ab0:	5e                   	pop    %esi
80109ab1:	5f                   	pop    %edi
80109ab2:	5d                   	pop    %ebp
80109ab3:	c3                   	ret

80109ab4 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109ab4:	f3 0f 1e fb          	endbr32
80109ab8:	55                   	push   %ebp
80109ab9:	89 e5                	mov    %esp,%ebp
80109abb:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109abe:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac7:	83 c0 0e             	add    $0xe,%eax
80109aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad0:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ad4:	3c 08                	cmp    $0x8,%al
80109ad6:	75 1b                	jne    80109af3 <eth_proc+0x3f>
80109ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adb:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109adf:	3c 06                	cmp    $0x6,%al
80109ae1:	75 10                	jne    80109af3 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109ae3:	83 ec 0c             	sub    $0xc,%esp
80109ae6:	ff 75 f0             	push   -0x10(%ebp)
80109ae9:	e8 d5 f7 ff ff       	call   801092c3 <arp_proc>
80109aee:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109af1:	eb 24                	jmp    80109b17 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109afa:	3c 08                	cmp    $0x8,%al
80109afc:	75 19                	jne    80109b17 <eth_proc+0x63>
80109afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b01:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b05:	84 c0                	test   %al,%al
80109b07:	75 0e                	jne    80109b17 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109b09:	83 ec 0c             	sub    $0xc,%esp
80109b0c:	ff 75 08             	push   0x8(%ebp)
80109b0f:	e8 b3 00 00 00       	call   80109bc7 <ipv4_proc>
80109b14:	83 c4 10             	add    $0x10,%esp
}
80109b17:	90                   	nop
80109b18:	c9                   	leave
80109b19:	c3                   	ret

80109b1a <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b1a:	f3 0f 1e fb          	endbr32
80109b1e:	55                   	push   %ebp
80109b1f:	89 e5                	mov    %esp,%ebp
80109b21:	83 ec 04             	sub    $0x4,%esp
80109b24:	8b 45 08             	mov    0x8(%ebp),%eax
80109b27:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b2b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b2f:	c1 e0 08             	shl    $0x8,%eax
80109b32:	89 c2                	mov    %eax,%edx
80109b34:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b38:	66 c1 e8 08          	shr    $0x8,%ax
80109b3c:	01 d0                	add    %edx,%eax
}
80109b3e:	c9                   	leave
80109b3f:	c3                   	ret

80109b40 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b40:	f3 0f 1e fb          	endbr32
80109b44:	55                   	push   %ebp
80109b45:	89 e5                	mov    %esp,%ebp
80109b47:	83 ec 04             	sub    $0x4,%esp
80109b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b51:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b55:	c1 e0 08             	shl    $0x8,%eax
80109b58:	89 c2                	mov    %eax,%edx
80109b5a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b5e:	66 c1 e8 08          	shr    $0x8,%ax
80109b62:	01 d0                	add    %edx,%eax
}
80109b64:	c9                   	leave
80109b65:	c3                   	ret

80109b66 <H2N_uint>:

uint H2N_uint(uint value){
80109b66:	f3 0f 1e fb          	endbr32
80109b6a:	55                   	push   %ebp
80109b6b:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b70:	c1 e0 18             	shl    $0x18,%eax
80109b73:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b78:	89 c2                	mov    %eax,%edx
80109b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7d:	c1 e0 08             	shl    $0x8,%eax
80109b80:	25 00 f0 00 00       	and    $0xf000,%eax
80109b85:	09 c2                	or     %eax,%edx
80109b87:	8b 45 08             	mov    0x8(%ebp),%eax
80109b8a:	c1 e8 08             	shr    $0x8,%eax
80109b8d:	83 e0 0f             	and    $0xf,%eax
80109b90:	01 d0                	add    %edx,%eax
}
80109b92:	5d                   	pop    %ebp
80109b93:	c3                   	ret

80109b94 <N2H_uint>:

uint N2H_uint(uint value){
80109b94:	f3 0f 1e fb          	endbr32
80109b98:	55                   	push   %ebp
80109b99:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9e:	c1 e0 18             	shl    $0x18,%eax
80109ba1:	89 c2                	mov    %eax,%edx
80109ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba6:	c1 e0 08             	shl    $0x8,%eax
80109ba9:	25 00 00 ff 00       	and    $0xff0000,%eax
80109bae:	01 c2                	add    %eax,%edx
80109bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb3:	c1 e8 08             	shr    $0x8,%eax
80109bb6:	25 00 ff 00 00       	and    $0xff00,%eax
80109bbb:	01 c2                	add    %eax,%edx
80109bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc0:	c1 e8 18             	shr    $0x18,%eax
80109bc3:	01 d0                	add    %edx,%eax
}
80109bc5:	5d                   	pop    %ebp
80109bc6:	c3                   	ret

80109bc7 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109bc7:	f3 0f 1e fb          	endbr32
80109bcb:	55                   	push   %ebp
80109bcc:	89 e5                	mov    %esp,%ebp
80109bce:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd4:	83 c0 0e             	add    $0xe,%eax
80109bd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bdd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109be1:	0f b7 d0             	movzwl %ax,%edx
80109be4:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109be9:	39 c2                	cmp    %eax,%edx
80109beb:	74 60                	je     80109c4d <ipv4_proc+0x86>
80109bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf0:	83 c0 0c             	add    $0xc,%eax
80109bf3:	83 ec 04             	sub    $0x4,%esp
80109bf6:	6a 04                	push   $0x4
80109bf8:	50                   	push   %eax
80109bf9:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bfe:	e8 a1 b1 ff ff       	call   80104da4 <memcmp>
80109c03:	83 c4 10             	add    $0x10,%esp
80109c06:	85 c0                	test   %eax,%eax
80109c08:	74 43                	je     80109c4d <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c11:	0f b7 c0             	movzwl %ax,%eax
80109c14:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c1c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c20:	3c 01                	cmp    $0x1,%al
80109c22:	75 10                	jne    80109c34 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109c24:	83 ec 0c             	sub    $0xc,%esp
80109c27:	ff 75 08             	push   0x8(%ebp)
80109c2a:	e8 a7 00 00 00       	call   80109cd6 <icmp_proc>
80109c2f:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c32:	eb 19                	jmp    80109c4d <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c37:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c3b:	3c 06                	cmp    $0x6,%al
80109c3d:	75 0e                	jne    80109c4d <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109c3f:	83 ec 0c             	sub    $0xc,%esp
80109c42:	ff 75 08             	push   0x8(%ebp)
80109c45:	e8 c7 03 00 00       	call   8010a011 <tcp_proc>
80109c4a:	83 c4 10             	add    $0x10,%esp
}
80109c4d:	90                   	nop
80109c4e:	c9                   	leave
80109c4f:	c3                   	ret

80109c50 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c50:	f3 0f 1e fb          	endbr32
80109c54:	55                   	push   %ebp
80109c55:	89 e5                	mov    %esp,%ebp
80109c57:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c63:	0f b6 00             	movzbl (%eax),%eax
80109c66:	83 e0 0f             	and    $0xf,%eax
80109c69:	01 c0                	add    %eax,%eax
80109c6b:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c6e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c75:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c7c:	eb 48                	jmp    80109cc6 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c81:	01 c0                	add    %eax,%eax
80109c83:	89 c2                	mov    %eax,%edx
80109c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c88:	01 d0                	add    %edx,%eax
80109c8a:	0f b6 00             	movzbl (%eax),%eax
80109c8d:	0f b6 c0             	movzbl %al,%eax
80109c90:	c1 e0 08             	shl    $0x8,%eax
80109c93:	89 c2                	mov    %eax,%edx
80109c95:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c98:	01 c0                	add    %eax,%eax
80109c9a:	8d 48 01             	lea    0x1(%eax),%ecx
80109c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca0:	01 c8                	add    %ecx,%eax
80109ca2:	0f b6 00             	movzbl (%eax),%eax
80109ca5:	0f b6 c0             	movzbl %al,%eax
80109ca8:	01 d0                	add    %edx,%eax
80109caa:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109cad:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109cb4:	76 0c                	jbe    80109cc2 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109cb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cb9:	0f b7 c0             	movzwl %ax,%eax
80109cbc:	83 c0 01             	add    $0x1,%eax
80109cbf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cc2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109cc6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109cca:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ccd:	7c af                	jl     80109c7e <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109ccf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cd2:	f7 d0                	not    %eax
}
80109cd4:	c9                   	leave
80109cd5:	c3                   	ret

80109cd6 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109cd6:	f3 0f 1e fb          	endbr32
80109cda:	55                   	push   %ebp
80109cdb:	89 e5                	mov    %esp,%ebp
80109cdd:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ce3:	83 c0 0e             	add    $0xe,%eax
80109ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cec:	0f b6 00             	movzbl (%eax),%eax
80109cef:	0f b6 c0             	movzbl %al,%eax
80109cf2:	83 e0 0f             	and    $0xf,%eax
80109cf5:	c1 e0 02             	shl    $0x2,%eax
80109cf8:	89 c2                	mov    %eax,%edx
80109cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfd:	01 d0                	add    %edx,%eax
80109cff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d05:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109d09:	84 c0                	test   %al,%al
80109d0b:	75 4f                	jne    80109d5c <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d10:	0f b6 00             	movzbl (%eax),%eax
80109d13:	3c 08                	cmp    $0x8,%al
80109d15:	75 45                	jne    80109d5c <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109d17:	e8 e3 8b ff ff       	call   801028ff <kalloc>
80109d1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d26:	83 ec 04             	sub    $0x4,%esp
80109d29:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d2c:	50                   	push   %eax
80109d2d:	ff 75 ec             	push   -0x14(%ebp)
80109d30:	ff 75 08             	push   0x8(%ebp)
80109d33:	e8 7c 00 00 00       	call   80109db4 <icmp_reply_pkt_create>
80109d38:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d3e:	83 ec 08             	sub    $0x8,%esp
80109d41:	50                   	push   %eax
80109d42:	ff 75 ec             	push   -0x14(%ebp)
80109d45:	e8 43 f4 ff ff       	call   8010918d <i8254_send>
80109d4a:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d50:	83 ec 0c             	sub    $0xc,%esp
80109d53:	50                   	push   %eax
80109d54:	e8 08 8b ff ff       	call   80102861 <kfree>
80109d59:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d5c:	90                   	nop
80109d5d:	c9                   	leave
80109d5e:	c3                   	ret

80109d5f <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d5f:	f3 0f 1e fb          	endbr32
80109d63:	55                   	push   %ebp
80109d64:	89 e5                	mov    %esp,%ebp
80109d66:	53                   	push   %ebx
80109d67:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d71:	0f b7 c0             	movzwl %ax,%eax
80109d74:	83 ec 0c             	sub    $0xc,%esp
80109d77:	50                   	push   %eax
80109d78:	e8 9d fd ff ff       	call   80109b1a <N2H_ushort>
80109d7d:	83 c4 10             	add    $0x10,%esp
80109d80:	0f b7 d8             	movzwl %ax,%ebx
80109d83:	8b 45 08             	mov    0x8(%ebp),%eax
80109d86:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d8a:	0f b7 c0             	movzwl %ax,%eax
80109d8d:	83 ec 0c             	sub    $0xc,%esp
80109d90:	50                   	push   %eax
80109d91:	e8 84 fd ff ff       	call   80109b1a <N2H_ushort>
80109d96:	83 c4 10             	add    $0x10,%esp
80109d99:	0f b7 c0             	movzwl %ax,%eax
80109d9c:	83 ec 04             	sub    $0x4,%esp
80109d9f:	53                   	push   %ebx
80109da0:	50                   	push   %eax
80109da1:	68 43 c8 10 80       	push   $0x8010c843
80109da6:	e8 61 66 ff ff       	call   8010040c <cprintf>
80109dab:	83 c4 10             	add    $0x10,%esp
}
80109dae:	90                   	nop
80109daf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109db2:	c9                   	leave
80109db3:	c3                   	ret

80109db4 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109db4:	f3 0f 1e fb          	endbr32
80109db8:	55                   	push   %ebp
80109db9:	89 e5                	mov    %esp,%ebp
80109dbb:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc7:	83 c0 0e             	add    $0xe,%eax
80109dca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd0:	0f b6 00             	movzbl (%eax),%eax
80109dd3:	0f b6 c0             	movzbl %al,%eax
80109dd6:	83 e0 0f             	and    $0xf,%eax
80109dd9:	c1 e0 02             	shl    $0x2,%eax
80109ddc:	89 c2                	mov    %eax,%edx
80109dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de1:	01 d0                	add    %edx,%eax
80109de3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80109de9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80109def:	83 c0 0e             	add    $0xe,%eax
80109df2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df8:	83 c0 14             	add    $0x14,%eax
80109dfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109dfe:	8b 45 10             	mov    0x10(%ebp),%eax
80109e01:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0a:	8d 50 06             	lea    0x6(%eax),%edx
80109e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e10:	83 ec 04             	sub    $0x4,%esp
80109e13:	6a 06                	push   $0x6
80109e15:	52                   	push   %edx
80109e16:	50                   	push   %eax
80109e17:	e8 e4 af ff ff       	call   80104e00 <memmove>
80109e1c:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e22:	83 c0 06             	add    $0x6,%eax
80109e25:	83 ec 04             	sub    $0x4,%esp
80109e28:	6a 06                	push   $0x6
80109e2a:	68 68 d0 18 80       	push   $0x8018d068
80109e2f:	50                   	push   %eax
80109e30:	e8 cb af ff ff       	call   80104e00 <memmove>
80109e35:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e3b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e42:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e49:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e4f:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e53:	83 ec 0c             	sub    $0xc,%esp
80109e56:	6a 54                	push   $0x54
80109e58:	e8 e3 fc ff ff       	call   80109b40 <H2N_ushort>
80109e5d:	83 c4 10             	add    $0x10,%esp
80109e60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e63:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e67:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e71:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e75:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109e7c:	83 c0 01             	add    $0x1,%eax
80109e7f:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e85:	83 ec 0c             	sub    $0xc,%esp
80109e88:	68 00 40 00 00       	push   $0x4000
80109e8d:	e8 ae fc ff ff       	call   80109b40 <H2N_ushort>
80109e92:	83 c4 10             	add    $0x10,%esp
80109e95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e98:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e9f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea6:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ead:	83 c0 0c             	add    $0xc,%eax
80109eb0:	83 ec 04             	sub    $0x4,%esp
80109eb3:	6a 04                	push   $0x4
80109eb5:	68 e4 f4 10 80       	push   $0x8010f4e4
80109eba:	50                   	push   %eax
80109ebb:	e8 40 af ff ff       	call   80104e00 <memmove>
80109ec0:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ec6:	8d 50 0c             	lea    0xc(%eax),%edx
80109ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ecc:	83 c0 10             	add    $0x10,%eax
80109ecf:	83 ec 04             	sub    $0x4,%esp
80109ed2:	6a 04                	push   $0x4
80109ed4:	52                   	push   %edx
80109ed5:	50                   	push   %eax
80109ed6:	e8 25 af ff ff       	call   80104e00 <memmove>
80109edb:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ee1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eea:	83 ec 0c             	sub    $0xc,%esp
80109eed:	50                   	push   %eax
80109eee:	e8 5d fd ff ff       	call   80109c50 <ipv4_chksum>
80109ef3:	83 c4 10             	add    $0x10,%esp
80109ef6:	0f b7 c0             	movzwl %ax,%eax
80109ef9:	83 ec 0c             	sub    $0xc,%esp
80109efc:	50                   	push   %eax
80109efd:	e8 3e fc ff ff       	call   80109b40 <H2N_ushort>
80109f02:	83 c4 10             	add    $0x10,%esp
80109f05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f08:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f0f:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f15:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f1c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f23:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f2a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f31:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f38:	8d 50 08             	lea    0x8(%eax),%edx
80109f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f3e:	83 c0 08             	add    $0x8,%eax
80109f41:	83 ec 04             	sub    $0x4,%esp
80109f44:	6a 08                	push   $0x8
80109f46:	52                   	push   %edx
80109f47:	50                   	push   %eax
80109f48:	e8 b3 ae ff ff       	call   80104e00 <memmove>
80109f4d:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f53:	8d 50 10             	lea    0x10(%eax),%edx
80109f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f59:	83 c0 10             	add    $0x10,%eax
80109f5c:	83 ec 04             	sub    $0x4,%esp
80109f5f:	6a 30                	push   $0x30
80109f61:	52                   	push   %edx
80109f62:	50                   	push   %eax
80109f63:	e8 98 ae ff ff       	call   80104e00 <memmove>
80109f68:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f6e:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f77:	83 ec 0c             	sub    $0xc,%esp
80109f7a:	50                   	push   %eax
80109f7b:	e8 1c 00 00 00       	call   80109f9c <icmp_chksum>
80109f80:	83 c4 10             	add    $0x10,%esp
80109f83:	0f b7 c0             	movzwl %ax,%eax
80109f86:	83 ec 0c             	sub    $0xc,%esp
80109f89:	50                   	push   %eax
80109f8a:	e8 b1 fb ff ff       	call   80109b40 <H2N_ushort>
80109f8f:	83 c4 10             	add    $0x10,%esp
80109f92:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f95:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f99:	90                   	nop
80109f9a:	c9                   	leave
80109f9b:	c3                   	ret

80109f9c <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f9c:	f3 0f 1e fb          	endbr32
80109fa0:	55                   	push   %ebp
80109fa1:	89 e5                	mov    %esp,%ebp
80109fa3:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109fac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fb3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fba:	eb 48                	jmp    8010a004 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fbf:	01 c0                	add    %eax,%eax
80109fc1:	89 c2                	mov    %eax,%edx
80109fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc6:	01 d0                	add    %edx,%eax
80109fc8:	0f b6 00             	movzbl (%eax),%eax
80109fcb:	0f b6 c0             	movzbl %al,%eax
80109fce:	c1 e0 08             	shl    $0x8,%eax
80109fd1:	89 c2                	mov    %eax,%edx
80109fd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fd6:	01 c0                	add    %eax,%eax
80109fd8:	8d 48 01             	lea    0x1(%eax),%ecx
80109fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fde:	01 c8                	add    %ecx,%eax
80109fe0:	0f b6 00             	movzbl (%eax),%eax
80109fe3:	0f b6 c0             	movzbl %al,%eax
80109fe6:	01 d0                	add    %edx,%eax
80109fe8:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109feb:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ff2:	76 0c                	jbe    8010a000 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ff4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ff7:	0f b7 c0             	movzwl %ax,%eax
80109ffa:	83 c0 01             	add    $0x1,%eax
80109ffd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a000:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a004:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a008:	7e b2                	jle    80109fbc <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a00a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a00d:	f7 d0                	not    %eax
}
8010a00f:	c9                   	leave
8010a010:	c3                   	ret

8010a011 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a011:	f3 0f 1e fb          	endbr32
8010a015:	55                   	push   %ebp
8010a016:	89 e5                	mov    %esp,%ebp
8010a018:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a01b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01e:	83 c0 0e             	add    $0xe,%eax
8010a021:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a024:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a027:	0f b6 00             	movzbl (%eax),%eax
8010a02a:	0f b6 c0             	movzbl %al,%eax
8010a02d:	83 e0 0f             	and    $0xf,%eax
8010a030:	c1 e0 02             	shl    $0x2,%eax
8010a033:	89 c2                	mov    %eax,%edx
8010a035:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a038:	01 d0                	add    %edx,%eax
8010a03a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a03d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a040:	83 c0 14             	add    $0x14,%eax
8010a043:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a046:	e8 b4 88 ff ff       	call   801028ff <kalloc>
8010a04b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a04e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a055:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a058:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a05c:	0f b6 c0             	movzbl %al,%eax
8010a05f:	83 e0 02             	and    $0x2,%eax
8010a062:	85 c0                	test   %eax,%eax
8010a064:	74 3d                	je     8010a0a3 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a066:	83 ec 0c             	sub    $0xc,%esp
8010a069:	6a 00                	push   $0x0
8010a06b:	6a 12                	push   $0x12
8010a06d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a070:	50                   	push   %eax
8010a071:	ff 75 e8             	push   -0x18(%ebp)
8010a074:	ff 75 08             	push   0x8(%ebp)
8010a077:	e8 a2 01 00 00       	call   8010a21e <tcp_pkt_create>
8010a07c:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a07f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a082:	83 ec 08             	sub    $0x8,%esp
8010a085:	50                   	push   %eax
8010a086:	ff 75 e8             	push   -0x18(%ebp)
8010a089:	e8 ff f0 ff ff       	call   8010918d <i8254_send>
8010a08e:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a091:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a096:	83 c0 01             	add    $0x1,%eax
8010a099:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a09e:	e9 69 01 00 00       	jmp    8010a20c <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a0a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0aa:	3c 18                	cmp    $0x18,%al
8010a0ac:	0f 85 10 01 00 00    	jne    8010a1c2 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a0b2:	83 ec 04             	sub    $0x4,%esp
8010a0b5:	6a 03                	push   $0x3
8010a0b7:	68 5e c8 10 80       	push   $0x8010c85e
8010a0bc:	ff 75 ec             	push   -0x14(%ebp)
8010a0bf:	e8 e0 ac ff ff       	call   80104da4 <memcmp>
8010a0c4:	83 c4 10             	add    $0x10,%esp
8010a0c7:	85 c0                	test   %eax,%eax
8010a0c9:	74 74                	je     8010a13f <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a0cb:	83 ec 0c             	sub    $0xc,%esp
8010a0ce:	68 62 c8 10 80       	push   $0x8010c862
8010a0d3:	e8 34 63 ff ff       	call   8010040c <cprintf>
8010a0d8:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0db:	83 ec 0c             	sub    $0xc,%esp
8010a0de:	6a 00                	push   $0x0
8010a0e0:	6a 10                	push   $0x10
8010a0e2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0e5:	50                   	push   %eax
8010a0e6:	ff 75 e8             	push   -0x18(%ebp)
8010a0e9:	ff 75 08             	push   0x8(%ebp)
8010a0ec:	e8 2d 01 00 00       	call   8010a21e <tcp_pkt_create>
8010a0f1:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0f7:	83 ec 08             	sub    $0x8,%esp
8010a0fa:	50                   	push   %eax
8010a0fb:	ff 75 e8             	push   -0x18(%ebp)
8010a0fe:	e8 8a f0 ff ff       	call   8010918d <i8254_send>
8010a103:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a106:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a109:	83 c0 36             	add    $0x36,%eax
8010a10c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a10f:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a112:	50                   	push   %eax
8010a113:	ff 75 e0             	push   -0x20(%ebp)
8010a116:	6a 00                	push   $0x0
8010a118:	6a 00                	push   $0x0
8010a11a:	e8 66 04 00 00       	call   8010a585 <http_proc>
8010a11f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a122:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a125:	83 ec 0c             	sub    $0xc,%esp
8010a128:	50                   	push   %eax
8010a129:	6a 18                	push   $0x18
8010a12b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a12e:	50                   	push   %eax
8010a12f:	ff 75 e8             	push   -0x18(%ebp)
8010a132:	ff 75 08             	push   0x8(%ebp)
8010a135:	e8 e4 00 00 00       	call   8010a21e <tcp_pkt_create>
8010a13a:	83 c4 20             	add    $0x20,%esp
8010a13d:	eb 62                	jmp    8010a1a1 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a13f:	83 ec 0c             	sub    $0xc,%esp
8010a142:	6a 00                	push   $0x0
8010a144:	6a 10                	push   $0x10
8010a146:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a149:	50                   	push   %eax
8010a14a:	ff 75 e8             	push   -0x18(%ebp)
8010a14d:	ff 75 08             	push   0x8(%ebp)
8010a150:	e8 c9 00 00 00       	call   8010a21e <tcp_pkt_create>
8010a155:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a158:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a15b:	83 ec 08             	sub    $0x8,%esp
8010a15e:	50                   	push   %eax
8010a15f:	ff 75 e8             	push   -0x18(%ebp)
8010a162:	e8 26 f0 ff ff       	call   8010918d <i8254_send>
8010a167:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a16a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a16d:	83 c0 36             	add    $0x36,%eax
8010a170:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a173:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a176:	50                   	push   %eax
8010a177:	ff 75 e4             	push   -0x1c(%ebp)
8010a17a:	6a 00                	push   $0x0
8010a17c:	6a 00                	push   $0x0
8010a17e:	e8 02 04 00 00       	call   8010a585 <http_proc>
8010a183:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a186:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a189:	83 ec 0c             	sub    $0xc,%esp
8010a18c:	50                   	push   %eax
8010a18d:	6a 18                	push   $0x18
8010a18f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a192:	50                   	push   %eax
8010a193:	ff 75 e8             	push   -0x18(%ebp)
8010a196:	ff 75 08             	push   0x8(%ebp)
8010a199:	e8 80 00 00 00       	call   8010a21e <tcp_pkt_create>
8010a19e:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a1a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1a4:	83 ec 08             	sub    $0x8,%esp
8010a1a7:	50                   	push   %eax
8010a1a8:	ff 75 e8             	push   -0x18(%ebp)
8010a1ab:	e8 dd ef ff ff       	call   8010918d <i8254_send>
8010a1b0:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1b3:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a1b8:	83 c0 01             	add    $0x1,%eax
8010a1bb:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a1c0:	eb 4a                	jmp    8010a20c <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a1c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1c5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1c9:	3c 10                	cmp    $0x10,%al
8010a1cb:	75 3f                	jne    8010a20c <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a1cd:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a1d2:	83 f8 01             	cmp    $0x1,%eax
8010a1d5:	75 35                	jne    8010a20c <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a1d7:	83 ec 0c             	sub    $0xc,%esp
8010a1da:	6a 00                	push   $0x0
8010a1dc:	6a 01                	push   $0x1
8010a1de:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1e1:	50                   	push   %eax
8010a1e2:	ff 75 e8             	push   -0x18(%ebp)
8010a1e5:	ff 75 08             	push   0x8(%ebp)
8010a1e8:	e8 31 00 00 00       	call   8010a21e <tcp_pkt_create>
8010a1ed:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1f3:	83 ec 08             	sub    $0x8,%esp
8010a1f6:	50                   	push   %eax
8010a1f7:	ff 75 e8             	push   -0x18(%ebp)
8010a1fa:	e8 8e ef ff ff       	call   8010918d <i8254_send>
8010a1ff:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a202:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a209:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a20c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a20f:	83 ec 0c             	sub    $0xc,%esp
8010a212:	50                   	push   %eax
8010a213:	e8 49 86 ff ff       	call   80102861 <kfree>
8010a218:	83 c4 10             	add    $0x10,%esp
}
8010a21b:	90                   	nop
8010a21c:	c9                   	leave
8010a21d:	c3                   	ret

8010a21e <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a21e:	f3 0f 1e fb          	endbr32
8010a222:	55                   	push   %ebp
8010a223:	89 e5                	mov    %esp,%ebp
8010a225:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a228:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a22e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a231:	83 c0 0e             	add    $0xe,%eax
8010a234:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23a:	0f b6 00             	movzbl (%eax),%eax
8010a23d:	0f b6 c0             	movzbl %al,%eax
8010a240:	83 e0 0f             	and    $0xf,%eax
8010a243:	c1 e0 02             	shl    $0x2,%eax
8010a246:	89 c2                	mov    %eax,%edx
8010a248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a24b:	01 d0                	add    %edx,%eax
8010a24d:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a250:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a253:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a256:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a259:	83 c0 0e             	add    $0xe,%eax
8010a25c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a25f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a262:	83 c0 14             	add    $0x14,%eax
8010a265:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a268:	8b 45 18             	mov    0x18(%ebp),%eax
8010a26b:	8d 50 36             	lea    0x36(%eax),%edx
8010a26e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a271:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a273:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a276:	8d 50 06             	lea    0x6(%eax),%edx
8010a279:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a27c:	83 ec 04             	sub    $0x4,%esp
8010a27f:	6a 06                	push   $0x6
8010a281:	52                   	push   %edx
8010a282:	50                   	push   %eax
8010a283:	e8 78 ab ff ff       	call   80104e00 <memmove>
8010a288:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a28b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a28e:	83 c0 06             	add    $0x6,%eax
8010a291:	83 ec 04             	sub    $0x4,%esp
8010a294:	6a 06                	push   $0x6
8010a296:	68 68 d0 18 80       	push   $0x8018d068
8010a29b:	50                   	push   %eax
8010a29c:	e8 5f ab ff ff       	call   80104e00 <memmove>
8010a2a1:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2a7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ae:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2b5:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2bb:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a2bf:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2c2:	83 c0 28             	add    $0x28,%eax
8010a2c5:	0f b7 c0             	movzwl %ax,%eax
8010a2c8:	83 ec 0c             	sub    $0xc,%esp
8010a2cb:	50                   	push   %eax
8010a2cc:	e8 6f f8 ff ff       	call   80109b40 <H2N_ushort>
8010a2d1:	83 c4 10             	add    $0x10,%esp
8010a2d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2d7:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2db:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a2e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e5:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2e9:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a2f0:	83 c0 01             	add    $0x1,%eax
8010a2f3:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a2f9:	83 ec 0c             	sub    $0xc,%esp
8010a2fc:	6a 00                	push   $0x0
8010a2fe:	e8 3d f8 ff ff       	call   80109b40 <H2N_ushort>
8010a303:	83 c4 10             	add    $0x10,%esp
8010a306:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a309:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a30d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a310:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a317:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a31b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a31e:	83 c0 0c             	add    $0xc,%eax
8010a321:	83 ec 04             	sub    $0x4,%esp
8010a324:	6a 04                	push   $0x4
8010a326:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a32b:	50                   	push   %eax
8010a32c:	e8 cf aa ff ff       	call   80104e00 <memmove>
8010a331:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a334:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a337:	8d 50 0c             	lea    0xc(%eax),%edx
8010a33a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a33d:	83 c0 10             	add    $0x10,%eax
8010a340:	83 ec 04             	sub    $0x4,%esp
8010a343:	6a 04                	push   $0x4
8010a345:	52                   	push   %edx
8010a346:	50                   	push   %eax
8010a347:	e8 b4 aa ff ff       	call   80104e00 <memmove>
8010a34c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a34f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a352:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a35b:	83 ec 0c             	sub    $0xc,%esp
8010a35e:	50                   	push   %eax
8010a35f:	e8 ec f8 ff ff       	call   80109c50 <ipv4_chksum>
8010a364:	83 c4 10             	add    $0x10,%esp
8010a367:	0f b7 c0             	movzwl %ax,%eax
8010a36a:	83 ec 0c             	sub    $0xc,%esp
8010a36d:	50                   	push   %eax
8010a36e:	e8 cd f7 ff ff       	call   80109b40 <H2N_ushort>
8010a373:	83 c4 10             	add    $0x10,%esp
8010a376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a379:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a37d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a380:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a384:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a387:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a38a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a38d:	0f b7 10             	movzwl (%eax),%edx
8010a390:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a393:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a397:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a39c:	83 ec 0c             	sub    $0xc,%esp
8010a39f:	50                   	push   %eax
8010a3a0:	e8 c1 f7 ff ff       	call   80109b66 <H2N_uint>
8010a3a5:	83 c4 10             	add    $0x10,%esp
8010a3a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3ab:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a3ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3b1:	8b 40 04             	mov    0x4(%eax),%eax
8010a3b4:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a3ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bd:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a3c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a3c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ca:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a3ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d1:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a3d5:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3d8:	89 c2                	mov    %eax,%edx
8010a3da:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3dd:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a3e0:	83 ec 0c             	sub    $0xc,%esp
8010a3e3:	68 90 38 00 00       	push   $0x3890
8010a3e8:	e8 53 f7 ff ff       	call   80109b40 <H2N_ushort>
8010a3ed:	83 c4 10             	add    $0x10,%esp
8010a3f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3f3:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a3f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fa:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a400:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a403:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a409:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a40c:	83 ec 0c             	sub    $0xc,%esp
8010a40f:	50                   	push   %eax
8010a410:	e8 1f 00 00 00       	call   8010a434 <tcp_chksum>
8010a415:	83 c4 10             	add    $0x10,%esp
8010a418:	83 c0 08             	add    $0x8,%eax
8010a41b:	0f b7 c0             	movzwl %ax,%eax
8010a41e:	83 ec 0c             	sub    $0xc,%esp
8010a421:	50                   	push   %eax
8010a422:	e8 19 f7 ff ff       	call   80109b40 <H2N_ushort>
8010a427:	83 c4 10             	add    $0x10,%esp
8010a42a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a42d:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a431:	90                   	nop
8010a432:	c9                   	leave
8010a433:	c3                   	ret

8010a434 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a434:	f3 0f 1e fb          	endbr32
8010a438:	55                   	push   %ebp
8010a439:	89 e5                	mov    %esp,%ebp
8010a43b:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a43e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a441:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a444:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a447:	83 c0 14             	add    $0x14,%eax
8010a44a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a44d:	83 ec 04             	sub    $0x4,%esp
8010a450:	6a 04                	push   $0x4
8010a452:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a457:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a45a:	50                   	push   %eax
8010a45b:	e8 a0 a9 ff ff       	call   80104e00 <memmove>
8010a460:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a463:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a466:	83 c0 0c             	add    $0xc,%eax
8010a469:	83 ec 04             	sub    $0x4,%esp
8010a46c:	6a 04                	push   $0x4
8010a46e:	50                   	push   %eax
8010a46f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a472:	83 c0 04             	add    $0x4,%eax
8010a475:	50                   	push   %eax
8010a476:	e8 85 a9 ff ff       	call   80104e00 <memmove>
8010a47b:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a47e:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a482:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a486:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a489:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a48d:	0f b7 c0             	movzwl %ax,%eax
8010a490:	83 ec 0c             	sub    $0xc,%esp
8010a493:	50                   	push   %eax
8010a494:	e8 81 f6 ff ff       	call   80109b1a <N2H_ushort>
8010a499:	83 c4 10             	add    $0x10,%esp
8010a49c:	83 e8 14             	sub    $0x14,%eax
8010a49f:	0f b7 c0             	movzwl %ax,%eax
8010a4a2:	83 ec 0c             	sub    $0xc,%esp
8010a4a5:	50                   	push   %eax
8010a4a6:	e8 95 f6 ff ff       	call   80109b40 <H2N_ushort>
8010a4ab:	83 c4 10             	add    $0x10,%esp
8010a4ae:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4b9:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a4bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a4c6:	eb 33                	jmp    8010a4fb <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4cb:	01 c0                	add    %eax,%eax
8010a4cd:	89 c2                	mov    %eax,%edx
8010a4cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4d2:	01 d0                	add    %edx,%eax
8010a4d4:	0f b6 00             	movzbl (%eax),%eax
8010a4d7:	0f b6 c0             	movzbl %al,%eax
8010a4da:	c1 e0 08             	shl    $0x8,%eax
8010a4dd:	89 c2                	mov    %eax,%edx
8010a4df:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4e2:	01 c0                	add    %eax,%eax
8010a4e4:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4ea:	01 c8                	add    %ecx,%eax
8010a4ec:	0f b6 00             	movzbl (%eax),%eax
8010a4ef:	0f b6 c0             	movzbl %al,%eax
8010a4f2:	01 d0                	add    %edx,%eax
8010a4f4:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a4f7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a4fb:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a4ff:	7e c7                	jle    8010a4c8 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a501:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a507:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a50e:	eb 33                	jmp    8010a543 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a510:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a513:	01 c0                	add    %eax,%eax
8010a515:	89 c2                	mov    %eax,%edx
8010a517:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a51a:	01 d0                	add    %edx,%eax
8010a51c:	0f b6 00             	movzbl (%eax),%eax
8010a51f:	0f b6 c0             	movzbl %al,%eax
8010a522:	c1 e0 08             	shl    $0x8,%eax
8010a525:	89 c2                	mov    %eax,%edx
8010a527:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a52a:	01 c0                	add    %eax,%eax
8010a52c:	8d 48 01             	lea    0x1(%eax),%ecx
8010a52f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a532:	01 c8                	add    %ecx,%eax
8010a534:	0f b6 00             	movzbl (%eax),%eax
8010a537:	0f b6 c0             	movzbl %al,%eax
8010a53a:	01 d0                	add    %edx,%eax
8010a53c:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a53f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a543:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a547:	0f b7 c0             	movzwl %ax,%eax
8010a54a:	83 ec 0c             	sub    $0xc,%esp
8010a54d:	50                   	push   %eax
8010a54e:	e8 c7 f5 ff ff       	call   80109b1a <N2H_ushort>
8010a553:	83 c4 10             	add    $0x10,%esp
8010a556:	66 d1 e8             	shr    $1,%ax
8010a559:	0f b7 c0             	movzwl %ax,%eax
8010a55c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a55f:	7c af                	jl     8010a510 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a561:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a564:	c1 e8 10             	shr    $0x10,%eax
8010a567:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a56a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a56d:	f7 d0                	not    %eax
}
8010a56f:	c9                   	leave
8010a570:	c3                   	ret

8010a571 <tcp_fin>:

void tcp_fin(){
8010a571:	f3 0f 1e fb          	endbr32
8010a575:	55                   	push   %ebp
8010a576:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a578:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a57f:	00 00 00 
}
8010a582:	90                   	nop
8010a583:	5d                   	pop    %ebp
8010a584:	c3                   	ret

8010a585 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a585:	f3 0f 1e fb          	endbr32
8010a589:	55                   	push   %ebp
8010a58a:	89 e5                	mov    %esp,%ebp
8010a58c:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a58f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a592:	83 ec 04             	sub    $0x4,%esp
8010a595:	6a 00                	push   $0x0
8010a597:	68 6b c8 10 80       	push   $0x8010c86b
8010a59c:	50                   	push   %eax
8010a59d:	e8 65 00 00 00       	call   8010a607 <http_strcpy>
8010a5a2:	83 c4 10             	add    $0x10,%esp
8010a5a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a5a8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5ab:	83 ec 04             	sub    $0x4,%esp
8010a5ae:	ff 75 f4             	push   -0xc(%ebp)
8010a5b1:	68 7e c8 10 80       	push   $0x8010c87e
8010a5b6:	50                   	push   %eax
8010a5b7:	e8 4b 00 00 00       	call   8010a607 <http_strcpy>
8010a5bc:	83 c4 10             	add    $0x10,%esp
8010a5bf:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5c2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5c5:	83 ec 04             	sub    $0x4,%esp
8010a5c8:	ff 75 f4             	push   -0xc(%ebp)
8010a5cb:	68 99 c8 10 80       	push   $0x8010c899
8010a5d0:	50                   	push   %eax
8010a5d1:	e8 31 00 00 00       	call   8010a607 <http_strcpy>
8010a5d6:	83 c4 10             	add    $0x10,%esp
8010a5d9:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a5dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5df:	83 e0 01             	and    $0x1,%eax
8010a5e2:	85 c0                	test   %eax,%eax
8010a5e4:	74 11                	je     8010a5f7 <http_proc+0x72>
    char *payload = (char *)send;
8010a5e6:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a5ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5f2:	01 d0                	add    %edx,%eax
8010a5f4:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a5f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5fa:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5fd:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a5ff:	e8 6d ff ff ff       	call   8010a571 <tcp_fin>
}
8010a604:	90                   	nop
8010a605:	c9                   	leave
8010a606:	c3                   	ret

8010a607 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a607:	f3 0f 1e fb          	endbr32
8010a60b:	55                   	push   %ebp
8010a60c:	89 e5                	mov    %esp,%ebp
8010a60e:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a611:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a618:	eb 20                	jmp    8010a63a <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a61a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a61d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a620:	01 d0                	add    %edx,%eax
8010a622:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a625:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a628:	01 ca                	add    %ecx,%edx
8010a62a:	89 d1                	mov    %edx,%ecx
8010a62c:	8b 55 08             	mov    0x8(%ebp),%edx
8010a62f:	01 ca                	add    %ecx,%edx
8010a631:	0f b6 00             	movzbl (%eax),%eax
8010a634:	88 02                	mov    %al,(%edx)
    i++;
8010a636:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a63a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a63d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a640:	01 d0                	add    %edx,%eax
8010a642:	0f b6 00             	movzbl (%eax),%eax
8010a645:	84 c0                	test   %al,%al
8010a647:	75 d1                	jne    8010a61a <http_strcpy+0x13>
  }
  return i;
8010a649:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a64c:	c9                   	leave
8010a64d:	c3                   	ret

8010a64e <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a64e:	f3 0f 1e fb          	endbr32
8010a652:	55                   	push   %ebp
8010a653:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a655:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a65c:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a65f:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a664:	c1 e8 09             	shr    $0x9,%eax
8010a667:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a66c:	90                   	nop
8010a66d:	5d                   	pop    %ebp
8010a66e:	c3                   	ret

8010a66f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a66f:	f3 0f 1e fb          	endbr32
8010a673:	55                   	push   %ebp
8010a674:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a676:	90                   	nop
8010a677:	5d                   	pop    %ebp
8010a678:	c3                   	ret

8010a679 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a679:	f3 0f 1e fb          	endbr32
8010a67d:	55                   	push   %ebp
8010a67e:	89 e5                	mov    %esp,%ebp
8010a680:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a683:	8b 45 08             	mov    0x8(%ebp),%eax
8010a686:	83 c0 0c             	add    $0xc,%eax
8010a689:	83 ec 0c             	sub    $0xc,%esp
8010a68c:	50                   	push   %eax
8010a68d:	e8 7f a3 ff ff       	call   80104a11 <holdingsleep>
8010a692:	83 c4 10             	add    $0x10,%esp
8010a695:	85 c0                	test   %eax,%eax
8010a697:	75 0d                	jne    8010a6a6 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a699:	83 ec 0c             	sub    $0xc,%esp
8010a69c:	68 aa c8 10 80       	push   $0x8010c8aa
8010a6a1:	e8 38 5f ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a6a6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6a9:	8b 00                	mov    (%eax),%eax
8010a6ab:	83 e0 06             	and    $0x6,%eax
8010a6ae:	83 f8 02             	cmp    $0x2,%eax
8010a6b1:	75 0d                	jne    8010a6c0 <iderw+0x47>
    panic("iderw: nothing to do");
8010a6b3:	83 ec 0c             	sub    $0xc,%esp
8010a6b6:	68 c0 c8 10 80       	push   $0x8010c8c0
8010a6bb:	e8 1e 5f ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a6c0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c3:	8b 40 04             	mov    0x4(%eax),%eax
8010a6c6:	83 f8 01             	cmp    $0x1,%eax
8010a6c9:	74 0d                	je     8010a6d8 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a6cb:	83 ec 0c             	sub    $0xc,%esp
8010a6ce:	68 d5 c8 10 80       	push   $0x8010c8d5
8010a6d3:	e8 06 5f ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a6d8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6db:	8b 40 08             	mov    0x8(%eax),%eax
8010a6de:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a6e4:	39 d0                	cmp    %edx,%eax
8010a6e6:	72 0d                	jb     8010a6f5 <iderw+0x7c>
    panic("iderw: block out of range");
8010a6e8:	83 ec 0c             	sub    $0xc,%esp
8010a6eb:	68 f3 c8 10 80       	push   $0x8010c8f3
8010a6f0:	e8 e9 5e ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a6f5:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a6fb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6fe:	8b 40 08             	mov    0x8(%eax),%eax
8010a701:	c1 e0 09             	shl    $0x9,%eax
8010a704:	01 d0                	add    %edx,%eax
8010a706:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a709:	8b 45 08             	mov    0x8(%ebp),%eax
8010a70c:	8b 00                	mov    (%eax),%eax
8010a70e:	83 e0 04             	and    $0x4,%eax
8010a711:	85 c0                	test   %eax,%eax
8010a713:	74 2b                	je     8010a740 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a715:	8b 45 08             	mov    0x8(%ebp),%eax
8010a718:	8b 00                	mov    (%eax),%eax
8010a71a:	83 e0 fb             	and    $0xfffffffb,%eax
8010a71d:	89 c2                	mov    %eax,%edx
8010a71f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a722:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a724:	8b 45 08             	mov    0x8(%ebp),%eax
8010a727:	83 c0 5c             	add    $0x5c,%eax
8010a72a:	83 ec 04             	sub    $0x4,%esp
8010a72d:	68 00 02 00 00       	push   $0x200
8010a732:	50                   	push   %eax
8010a733:	ff 75 f4             	push   -0xc(%ebp)
8010a736:	e8 c5 a6 ff ff       	call   80104e00 <memmove>
8010a73b:	83 c4 10             	add    $0x10,%esp
8010a73e:	eb 1a                	jmp    8010a75a <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a740:	8b 45 08             	mov    0x8(%ebp),%eax
8010a743:	83 c0 5c             	add    $0x5c,%eax
8010a746:	83 ec 04             	sub    $0x4,%esp
8010a749:	68 00 02 00 00       	push   $0x200
8010a74e:	ff 75 f4             	push   -0xc(%ebp)
8010a751:	50                   	push   %eax
8010a752:	e8 a9 a6 ff ff       	call   80104e00 <memmove>
8010a757:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a75a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a75d:	8b 00                	mov    (%eax),%eax
8010a75f:	83 c8 02             	or     $0x2,%eax
8010a762:	89 c2                	mov    %eax,%edx
8010a764:	8b 45 08             	mov    0x8(%ebp),%eax
8010a767:	89 10                	mov    %edx,(%eax)
}
8010a769:	90                   	nop
8010a76a:	c9                   	leave
8010a76b:	c3                   	ret
