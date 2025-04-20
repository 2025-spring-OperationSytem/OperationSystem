
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
80100073:	68 a0 a4 10 80       	push   $0x8010a4a0
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 88 48 00 00       	call   8010490a <initlock>
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
801000c1:	68 a7 a4 10 80       	push   $0x8010a4a7
801000c6:	50                   	push   %eax
801000c7:	e8 d1 46 00 00       	call   8010479d <initsleeplock>
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
80100109:	e8 22 48 00 00       	call   80104930 <acquire>
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
80100148:	e8 55 48 00 00       	call   801049a2 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 7e 46 00 00       	call   801047dd <acquiresleep>
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
801001c9:	e8 d4 47 00 00       	call   801049a2 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 fd 45 00 00       	call   801047dd <acquiresleep>
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
801001fd:	68 ae a4 10 80       	push   $0x8010a4ae
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
80100239:	e8 5a a1 00 00       	call   8010a398 <iderw>
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
8010025a:	e8 38 46 00 00       	call   80104897 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 bf a4 10 80       	push   $0x8010a4bf
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
80100288:	e8 0b a1 00 00       	call   8010a398 <iderw>
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
801002a7:	e8 eb 45 00 00       	call   80104897 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 c6 a4 10 80       	push   $0x8010a4c6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 76 45 00 00       	call   80104845 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 51 46 00 00       	call   80104930 <acquire>
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
8010034a:	e8 53 46 00 00       	call   801049a2 <release>
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
8010042c:	e8 ff 44 00 00       	call   80104930 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 cd a4 10 80       	push   $0x8010a4cd
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
8010052c:	c7 45 ec d6 a4 10 80 	movl   $0x8010a4d6,-0x14(%ebp)
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
801005ba:	e8 e3 43 00 00       	call   801049a2 <release>
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
801005e7:	68 dd a4 10 80       	push   $0x8010a4dd
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
80100606:	68 f1 a4 10 80       	push   $0x8010a4f1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 d5 43 00 00       	call   801049f8 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 f3 a4 10 80       	push   $0x8010a4f3
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
801006c4:	e8 63 7b 00 00       	call   8010822c <graphic_scroll_up>
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
80100717:	e8 10 7b 00 00       	call   8010822c <graphic_scroll_up>
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
8010077d:	e8 1e 7b 00 00       	call   801082a0 <font_render>
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
801007bd:	e8 7e 5e 00 00       	call   80106640 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 71 5e 00 00       	call   80106640 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 64 5e 00 00       	call   80106640 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 54 5e 00 00       	call   80106640 <uartputc>
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
80100819:	e8 12 41 00 00       	call   80104930 <acquire>
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
8010096f:	e8 62 3c 00 00       	call   801045d6 <wakeup>
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
80100992:	e8 0b 40 00 00       	call   801049a2 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 f7 3c 00 00       	call   8010469c <procdump>
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
801009ce:	e8 5d 3f 00 00       	call   80104930 <acquire>
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
801009ef:	e8 ae 3f 00 00       	call   801049a2 <release>
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
80100a1c:	e8 c3 3a 00 00       	call   801044e4 <sleep>
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
80100a9a:	e8 03 3f 00 00       	call   801049a2 <release>
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
80100adc:	e8 4f 3e 00 00       	call   80104930 <acquire>
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
80100b1e:	e8 7f 3e 00 00       	call   801049a2 <release>
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
80100b50:	68 f7 a4 10 80       	push   $0x8010a4f7
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 ab 3d 00 00       	call   8010490a <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 ff a4 10 80 	movl   $0x8010a4ff,-0xc(%ebp)
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
80100bf7:	68 15 a5 10 80       	push   $0x8010a515
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
80100c53:	e8 fc 69 00 00       	call   80107654 <setupkvm>
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
80100cf9:	e8 68 6d 00 00       	call   80107a66 <allocuvm>
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
80100d3f:	e8 51 6c 00 00       	call   80107995 <loaduvm>
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
80100dae:	e8 b3 6c 00 00       	call   80107a66 <allocuvm>
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
80100dd2:	e8 fd 6e 00 00       	call   80107cd4 <clearpteu>
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
80100e0b:	e8 18 40 00 00       	call   80104e28 <strlen>
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
80100e38:	e8 eb 3f 00 00       	call   80104e28 <strlen>
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
80100e5e:	e8 1c 70 00 00       	call   80107e7f <copyout>
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
80100efa:	e8 80 6f 00 00       	call   80107e7f <copyout>
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
80100f48:	e8 8d 3e 00 00       	call   80104dda <safestrcpy>
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
80100f8b:	e8 ee 67 00 00       	call   8010777e <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 99 6c 00 00       	call   80107c37 <freevm>
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
80100fd9:	e8 59 6c 00 00       	call   80107c37 <freevm>
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
8010100e:	68 21 a5 10 80       	push   $0x8010a521
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 ed 38 00 00       	call   8010490a <initlock>
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
80101035:	e8 f6 38 00 00       	call   80104930 <acquire>
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
80101062:	e8 3b 39 00 00       	call   801049a2 <release>
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
80101085:	e8 18 39 00 00       	call   801049a2 <release>
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
801010a6:	e8 85 38 00 00       	call   80104930 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 28 a5 10 80       	push   $0x8010a528
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
801010dc:	e8 c1 38 00 00       	call   801049a2 <release>
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
801010fb:	e8 30 38 00 00       	call   80104930 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 30 a5 10 80       	push   $0x8010a530
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
8010113b:	e8 62 38 00 00       	call   801049a2 <release>
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
80101189:	e8 14 38 00 00       	call   801049a2 <release>
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
801012e0:	68 3a a5 10 80       	push   $0x8010a53a
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
801013e7:	68 43 a5 10 80       	push   $0x8010a543
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
8010141d:	68 53 a5 10 80       	push   $0x8010a553
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
80101459:	e8 28 38 00 00       	call   80104c86 <memmove>
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
801014a3:	e8 17 37 00 00       	call   80104bbf <memset>
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
8010160e:	68 60 a5 10 80       	push   $0x8010a560
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
801016a5:	68 76 a5 10 80       	push   $0x8010a576
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
8010170d:	68 89 a5 10 80       	push   $0x8010a589
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 ee 31 00 00       	call   8010490a <initlock>
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
80101743:	68 90 a5 10 80       	push   $0x8010a590
80101748:	50                   	push   %eax
80101749:	e8 4f 30 00 00       	call   8010479d <initsleeplock>
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
801017a2:	68 98 a5 10 80       	push   $0x8010a598
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
8010181f:	e8 9b 33 00 00       	call   80104bbf <memset>
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
80101887:	68 eb a5 10 80       	push   $0x8010a5eb
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
80101931:	e8 50 33 00 00       	call   80104c86 <memmove>
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
8010196a:	e8 c1 2f 00 00       	call   80104930 <acquire>
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
801019b8:	e8 e5 2f 00 00       	call   801049a2 <release>
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
801019f4:	68 fd a5 10 80       	push   $0x8010a5fd
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
80101a31:	e8 6c 2f 00 00       	call   801049a2 <release>
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
80101a50:	e8 db 2e 00 00       	call   80104930 <acquire>
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
80101a6f:	e8 2e 2f 00 00       	call   801049a2 <release>
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
80101a99:	68 0d a6 10 80       	push   $0x8010a60d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 2b 2d 00 00       	call   801047dd <acquiresleep>
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
80101b57:	e8 2a 31 00 00       	call   80104c86 <memmove>
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
80101b86:	68 13 a6 10 80       	push   $0x8010a613
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
80101bad:	e8 e5 2c 00 00       	call   80104897 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 22 a6 10 80       	push   $0x8010a622
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 66 2c 00 00       	call   80104845 <releasesleep>
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
80101bf9:	e8 df 2b 00 00       	call   801047dd <acquiresleep>
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
80101c1f:	e8 0c 2d 00 00       	call   80104930 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 65 2d 00 00       	call   801049a2 <release>
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
80101c7f:	e8 c1 2b 00 00       	call   80104845 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 9c 2c 00 00       	call   80104930 <acquire>
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
80101cae:	e8 ef 2c 00 00       	call   801049a2 <release>
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
80101dfa:	68 2a a6 10 80       	push   $0x8010a62a
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
801020a4:	e8 dd 2b 00 00       	call   80104c86 <memmove>
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
801021f8:	e8 89 2a 00 00       	call   80104c86 <memmove>
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
8010227c:	e8 a3 2a 00 00       	call   80104d24 <strncmp>
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
801022a0:	68 3d a6 10 80       	push   $0x8010a63d
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
801022cf:	68 4f a6 10 80       	push   $0x8010a64f
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
801023a8:	68 5e a6 10 80       	push   $0x8010a65e
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
801023e3:	e8 96 29 00 00       	call   80104d7e <strncpy>
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
8010240f:	68 6b a6 10 80       	push   $0x8010a66b
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
80102485:	e8 fc 27 00 00       	call   80104c86 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 e5 27 00 00       	call   80104c86 <memmove>
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
80102699:	0f b6 05 a0 7e 19 80 	movzbl 0x80197ea0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 74 a6 10 80       	push   $0x8010a674
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
8010275a:	68 a6 a6 10 80       	push   $0x8010a6a6
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 a1 21 00 00       	call   8010490a <initlock>
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
80102825:	68 ab a6 10 80       	push   $0x8010a6ab
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 7e 23 00 00       	call   80104bbf <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 d6 20 00 00       	call   80104930 <acquire>
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
80102887:	e8 16 21 00 00       	call   801049a2 <release>
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
801028ad:	e8 7e 20 00 00       	call   80104930 <acquire>
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
801028de:	e8 bf 20 00 00       	call   801049a2 <release>
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
80102e33:	e8 f2 1d 00 00       	call   80104c2a <memcmp>
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
80102f4b:	68 b1 a6 10 80       	push   $0x8010a6b1
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 b0 19 00 00       	call   8010490a <initlock>
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
80103004:	e8 7d 1c 00 00       	call   80104c86 <memmove>
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
80103183:	e8 a8 17 00 00       	call   80104930 <acquire>
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
801031a1:	e8 3e 13 00 00       	call   801044e4 <sleep>
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
801031d6:	e8 09 13 00 00       	call   801044e4 <sleep>
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
801031f5:	e8 a8 17 00 00       	call   801049a2 <release>
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
8010321a:	e8 11 17 00 00       	call   80104930 <acquire>
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
8010323b:	68 b5 a6 10 80       	push   $0x8010a6b5
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
80103269:	e8 68 13 00 00       	call   801045d6 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 24 17 00 00       	call   801049a2 <release>
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
80103294:	e8 97 16 00 00       	call   80104930 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 23 13 00 00       	call   801045d6 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 df 16 00 00       	call   801049a2 <release>
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
8010333e:	e8 43 19 00 00       	call   80104c86 <memmove>
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
801033e3:	68 c4 a6 10 80       	push   $0x8010a6c4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 da a6 10 80       	push   $0x8010a6da
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 20 15 00 00       	call   80104930 <acquire>
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
80103489:	e8 14 15 00 00       	call   801049a2 <release>
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
801034c3:	e8 a0 4c 00 00       	call   80108168 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 63 42 00 00       	call   80107745 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 3a 4a 00 00       	call   80107f21 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 db 3c 00 00       	call   801071cc <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 50 30 00 00       	call   80106555 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 8a 2b 00 00       	call   80106099 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 4f 6e 00 00       	call   8010a36d <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 9e 4e 00 00       	call   801083db <pci_init>
  arp_scan();
8010353d:	e8 17 5c 00 00       	call   80109159 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 9e 07 00 00       	call   80103ce5 <userinit>

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
80103556:	e8 06 42 00 00       	call   80107761 <switchkvm>
  seginit();
8010355b:	e8 6c 3c 00 00       	call   801071cc <seginit>
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
80103586:	68 f5 a6 10 80       	push   $0x8010a6f5
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 7b 2c 00 00       	call   80106213 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 d5 0c 00 00       	call   8010428a <scheduler>

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
801035d7:	e8 aa 16 00 00       	call   80104c86 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7e 19 80 	movl   $0x80197ec0,-0xc(%ebp)
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
80103661:	a1 80 81 19 80       	mov    0x80198180,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
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
80103768:	68 09 a7 10 80       	push   $0x8010a709
8010376d:	50                   	push   %eax
8010376e:	e8 97 11 00 00       	call   8010490a <initlock>
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
80103831:	e8 fa 10 00 00       	call   80104930 <acquire>
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
80103858:	e8 79 0d 00 00       	call   801045d6 <wakeup>
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
8010387b:	e8 56 0d 00 00       	call   801045d6 <wakeup>
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
801038a4:	e8 f9 10 00 00       	call   801049a2 <release>
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
801038c3:	e8 da 10 00 00       	call   801049a2 <release>
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
801038e1:	e8 4a 10 00 00       	call   80104930 <acquire>
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
80103915:	e8 88 10 00 00       	call   801049a2 <release>
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
80103933:	e8 9e 0c 00 00       	call   801045d6 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 93 0b 00 00       	call   801044e4 <sleep>
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
801039b6:	e8 1b 0c 00 00       	call   801045d6 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 d8 0f 00 00       	call   801049a2 <release>
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
801039e6:	e8 45 0f 00 00       	call   80104930 <acquire>
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
80103a03:	e8 9a 0f 00 00       	call   801049a2 <release>
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
80103a26:	e8 b9 0a 00 00       	call   801044e4 <sleep>
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
80103ab9:	e8 18 0b 00 00       	call   801045d6 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 d5 0e 00 00       	call   801049a2 <release>
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
80103af9:	68 10 a7 10 80       	push   $0x8010a710
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 02 0e 00 00       	call   8010490a <initlock>
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
80103b1d:	2d c0 7e 19 80       	sub    $0x80197ec0,%eax
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
80103b48:	68 18 a7 10 80       	push   $0x8010a718
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
80103b6c:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 81 19 80       	mov    0x80198180,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 3e a7 10 80       	push   $0x8010a73e
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
80103bb3:	e8 f4 0e 00 00       	call   80104aac <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 2c 0f 00 00       	call   80104afd <popcli>
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
80103be8:	e8 43 0d 00 00       	call   80104930 <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 11                	jmp    80103c0a <allocproc+0x34>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 2a                	je     80103c2d <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103c0a:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80103c11:	72 e6                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c13:	83 ec 0c             	sub    $0xc,%esp
80103c16:	68 00 55 19 80       	push   $0x80195500
80103c1b:	e8 82 0d 00 00       	call   801049a2 <release>
80103c20:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c23:	b8 00 00 00 00       	mov    $0x0,%eax
80103c28:	e9 b6 00 00 00       	jmp    80103ce3 <allocproc+0x10d>
      goto found;
80103c2d:	90                   	nop
80103c2e:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c35:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c3c:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c41:	8d 50 01             	lea    0x1(%eax),%edx
80103c44:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4d:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103c50:	83 ec 0c             	sub    $0xc,%esp
80103c53:	68 00 55 19 80       	push   $0x80195500
80103c58:	e8 45 0d 00 00       	call   801049a2 <release>
80103c5d:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c60:	e8 2d ec ff ff       	call   80102892 <kalloc>
80103c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c68:	89 42 08             	mov    %eax,0x8(%edx)
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 40 08             	mov    0x8(%eax),%eax
80103c71:	85 c0                	test   %eax,%eax
80103c73:	75 11                	jne    80103c86 <allocproc+0xb0>
    p->state = UNUSED;
80103c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c78:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c7f:	b8 00 00 00 00       	mov    $0x0,%eax
80103c84:	eb 5d                	jmp    80103ce3 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
80103c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c89:	8b 40 08             	mov    0x8(%eax),%eax
80103c8c:	05 00 10 00 00       	add    $0x1000,%eax
80103c91:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103c94:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c9e:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ca1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103ca5:	ba 53 60 10 80       	mov    $0x80106053,%edx
80103caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cad:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103caf:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cb9:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbf:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cc2:	83 ec 04             	sub    $0x4,%esp
80103cc5:	6a 14                	push   $0x14
80103cc7:	6a 00                	push   $0x0
80103cc9:	50                   	push   %eax
80103cca:	e8 f0 0e 00 00       	call   80104bbf <memset>
80103ccf:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd5:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd8:	ba 9a 44 10 80       	mov    $0x8010449a,%edx
80103cdd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ce3:	c9                   	leave
80103ce4:	c3                   	ret

80103ce5 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103ce5:	f3 0f 1e fb          	endbr32
80103ce9:	55                   	push   %ebp
80103cea:	89 e5                	mov    %esp,%ebp
80103cec:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cef:	e8 e2 fe ff ff       	call   80103bd6 <allocproc>
80103cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103cff:	e8 50 39 00 00       	call   80107654 <setupkvm>
80103d04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d07:	89 42 04             	mov    %eax,0x4(%edx)
80103d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0d:	8b 40 04             	mov    0x4(%eax),%eax
80103d10:	85 c0                	test   %eax,%eax
80103d12:	75 0d                	jne    80103d21 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d14:	83 ec 0c             	sub    $0xc,%esp
80103d17:	68 4e a7 10 80       	push   $0x8010a74e
80103d1c:	e8 a4 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d21:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d29:	8b 40 04             	mov    0x4(%eax),%eax
80103d2c:	83 ec 04             	sub    $0x4,%esp
80103d2f:	52                   	push   %edx
80103d30:	68 ec f4 10 80       	push   $0x8010f4ec
80103d35:	50                   	push   %eax
80103d36:	e8 e6 3b 00 00       	call   80107921 <inituvm>
80103d3b:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d41:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4a:	8b 40 18             	mov    0x18(%eax),%eax
80103d4d:	83 ec 04             	sub    $0x4,%esp
80103d50:	6a 4c                	push   $0x4c
80103d52:	6a 00                	push   $0x0
80103d54:	50                   	push   %eax
80103d55:	e8 65 0e 00 00       	call   80104bbf <memset>
80103d5a:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d60:	8b 40 18             	mov    0x18(%eax),%eax
80103d63:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6c:	8b 40 18             	mov    0x18(%eax),%eax
80103d6f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d78:	8b 50 18             	mov    0x18(%eax),%edx
80103d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7e:	8b 40 18             	mov    0x18(%eax),%eax
80103d81:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d85:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8c:	8b 50 18             	mov    0x18(%eax),%edx
80103d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d92:	8b 40 18             	mov    0x18(%eax),%eax
80103d95:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d99:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da0:	8b 40 18             	mov    0x18(%eax),%eax
80103da3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dad:	8b 40 18             	mov    0x18(%eax),%eax
80103db0:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dba:	8b 40 18             	mov    0x18(%eax),%eax
80103dbd:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc7:	83 c0 6c             	add    $0x6c,%eax
80103dca:	83 ec 04             	sub    $0x4,%esp
80103dcd:	6a 10                	push   $0x10
80103dcf:	68 67 a7 10 80       	push   $0x8010a767
80103dd4:	50                   	push   %eax
80103dd5:	e8 00 10 00 00       	call   80104dda <safestrcpy>
80103dda:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103ddd:	83 ec 0c             	sub    $0xc,%esp
80103de0:	68 70 a7 10 80       	push   $0x8010a770
80103de5:	e8 fd e7 ff ff       	call   801025e7 <namei>
80103dea:	83 c4 10             	add    $0x10,%esp
80103ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103df0:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103df3:	83 ec 0c             	sub    $0xc,%esp
80103df6:	68 00 55 19 80       	push   $0x80195500
80103dfb:	e8 30 0b 00 00       	call   80104930 <acquire>
80103e00:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e06:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0d:	83 ec 0c             	sub    $0xc,%esp
80103e10:	68 00 55 19 80       	push   $0x80195500
80103e15:	e8 88 0b 00 00       	call   801049a2 <release>
80103e1a:	83 c4 10             	add    $0x10,%esp
}
80103e1d:	90                   	nop
80103e1e:	c9                   	leave
80103e1f:	c3                   	ret

80103e20 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e20:	f3 0f 1e fb          	endbr32
80103e24:	55                   	push   %ebp
80103e25:	89 e5                	mov    %esp,%ebp
80103e27:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e2a:	e8 7a fd ff ff       	call   80103ba9 <myproc>
80103e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e35:	8b 00                	mov    (%eax),%eax
80103e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e3a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e3e:	7e 2e                	jle    80103e6e <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e40:	8b 55 08             	mov    0x8(%ebp),%edx
80103e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e46:	01 c2                	add    %eax,%edx
80103e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4b:	8b 40 04             	mov    0x4(%eax),%eax
80103e4e:	83 ec 04             	sub    $0x4,%esp
80103e51:	52                   	push   %edx
80103e52:	ff 75 f4             	push   -0xc(%ebp)
80103e55:	50                   	push   %eax
80103e56:	e8 0b 3c 00 00       	call   80107a66 <allocuvm>
80103e5b:	83 c4 10             	add    $0x10,%esp
80103e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e65:	75 3b                	jne    80103ea2 <growproc+0x82>
      return -1;
80103e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e6c:	eb 4f                	jmp    80103ebd <growproc+0x9d>
  } else if(n < 0){
80103e6e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e72:	79 2e                	jns    80103ea2 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e74:	8b 55 08             	mov    0x8(%ebp),%edx
80103e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7a:	01 c2                	add    %eax,%edx
80103e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7f:	8b 40 04             	mov    0x4(%eax),%eax
80103e82:	83 ec 04             	sub    $0x4,%esp
80103e85:	52                   	push   %edx
80103e86:	ff 75 f4             	push   -0xc(%ebp)
80103e89:	50                   	push   %eax
80103e8a:	e8 e0 3c 00 00       	call   80107b6f <deallocuvm>
80103e8f:	83 c4 10             	add    $0x10,%esp
80103e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e99:	75 07                	jne    80103ea2 <growproc+0x82>
      return -1;
80103e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ea0:	eb 1b                	jmp    80103ebd <growproc+0x9d>
  }
  curproc->sz = sz;
80103ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea8:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103eaa:	83 ec 0c             	sub    $0xc,%esp
80103ead:	ff 75 f0             	push   -0x10(%ebp)
80103eb0:	e8 c9 38 00 00       	call   8010777e <switchuvm>
80103eb5:	83 c4 10             	add    $0x10,%esp
  return 0;
80103eb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ebd:	c9                   	leave
80103ebe:	c3                   	ret

80103ebf <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ebf:	f3 0f 1e fb          	endbr32
80103ec3:	55                   	push   %ebp
80103ec4:	89 e5                	mov    %esp,%ebp
80103ec6:	57                   	push   %edi
80103ec7:	56                   	push   %esi
80103ec8:	53                   	push   %ebx
80103ec9:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ecc:	e8 d8 fc ff ff       	call   80103ba9 <myproc>
80103ed1:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ed4:	e8 fd fc ff ff       	call   80103bd6 <allocproc>
80103ed9:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103edc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103ee0:	75 0a                	jne    80103eec <fork+0x2d>
    return -1;
80103ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee7:	e9 48 01 00 00       	jmp    80104034 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eef:	8b 10                	mov    (%eax),%edx
80103ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef4:	8b 40 04             	mov    0x4(%eax),%eax
80103ef7:	83 ec 08             	sub    $0x8,%esp
80103efa:	52                   	push   %edx
80103efb:	50                   	push   %eax
80103efc:	e8 18 3e 00 00       	call   80107d19 <copyuvm>
80103f01:	83 c4 10             	add    $0x10,%esp
80103f04:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f07:	89 42 04             	mov    %eax,0x4(%edx)
80103f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0d:	8b 40 04             	mov    0x4(%eax),%eax
80103f10:	85 c0                	test   %eax,%eax
80103f12:	75 30                	jne    80103f44 <fork+0x85>
    kfree(np->kstack);
80103f14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f17:	8b 40 08             	mov    0x8(%eax),%eax
80103f1a:	83 ec 0c             	sub    $0xc,%esp
80103f1d:	50                   	push   %eax
80103f1e:	e8 d1 e8 ff ff       	call   801027f4 <kfree>
80103f23:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f26:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3f:	e9 f0 00 00 00       	jmp    80104034 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f47:	8b 10                	mov    (%eax),%edx
80103f49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f51:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f54:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f5a:	8b 48 18             	mov    0x18(%eax),%ecx
80103f5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f60:	8b 40 18             	mov    0x18(%eax),%eax
80103f63:	89 c2                	mov    %eax,%edx
80103f65:	89 cb                	mov    %ecx,%ebx
80103f67:	b8 13 00 00 00       	mov    $0x13,%eax
80103f6c:	89 d7                	mov    %edx,%edi
80103f6e:	89 de                	mov    %ebx,%esi
80103f70:	89 c1                	mov    %eax,%ecx
80103f72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f77:	8b 40 18             	mov    0x18(%eax),%eax
80103f7a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f88:	eb 3b                	jmp    80103fc5 <fork+0x106>
    if(curproc->ofile[i])
80103f8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f90:	83 c2 08             	add    $0x8,%edx
80103f93:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f97:	85 c0                	test   %eax,%eax
80103f99:	74 26                	je     80103fc1 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fa1:	83 c2 08             	add    $0x8,%edx
80103fa4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa8:	83 ec 0c             	sub    $0xc,%esp
80103fab:	50                   	push   %eax
80103fac:	e8 e3 d0 ff ff       	call   80101094 <filedup>
80103fb1:	83 c4 10             	add    $0x10,%esp
80103fb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fb7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fba:	83 c1 08             	add    $0x8,%ecx
80103fbd:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fc1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fc5:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fc9:	7e bf                	jle    80103f8a <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fce:	8b 40 68             	mov    0x68(%eax),%eax
80103fd1:	83 ec 0c             	sub    $0xc,%esp
80103fd4:	50                   	push   %eax
80103fd5:	e8 64 da ff ff       	call   80101a3e <idup>
80103fda:	83 c4 10             	add    $0x10,%esp
80103fdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fe0:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103fe3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe6:	8d 50 6c             	lea    0x6c(%eax),%edx
80103fe9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fec:	83 c0 6c             	add    $0x6c,%eax
80103fef:	83 ec 04             	sub    $0x4,%esp
80103ff2:	6a 10                	push   $0x10
80103ff4:	52                   	push   %edx
80103ff5:	50                   	push   %eax
80103ff6:	e8 df 0d 00 00       	call   80104dda <safestrcpy>
80103ffb:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ffe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104001:	8b 40 10             	mov    0x10(%eax),%eax
80104004:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104007:	83 ec 0c             	sub    $0xc,%esp
8010400a:	68 00 55 19 80       	push   $0x80195500
8010400f:	e8 1c 09 00 00       	call   80104930 <acquire>
80104014:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104017:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010401a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104021:	83 ec 0c             	sub    $0xc,%esp
80104024:	68 00 55 19 80       	push   $0x80195500
80104029:	e8 74 09 00 00       	call   801049a2 <release>
8010402e:	83 c4 10             	add    $0x10,%esp

  return pid;
80104031:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104034:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104037:	5b                   	pop    %ebx
80104038:	5e                   	pop    %esi
80104039:	5f                   	pop    %edi
8010403a:	5d                   	pop    %ebp
8010403b:	c3                   	ret

8010403c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010403c:	f3 0f 1e fb          	endbr32
80104040:	55                   	push   %ebp
80104041:	89 e5                	mov    %esp,%ebp
80104043:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104046:	e8 5e fb ff ff       	call   80103ba9 <myproc>
8010404b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010404e:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104053:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104056:	75 0d                	jne    80104065 <exit+0x29>
    panic("init exiting");
80104058:	83 ec 0c             	sub    $0xc,%esp
8010405b:	68 72 a7 10 80       	push   $0x8010a772
80104060:	e8 60 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104065:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010406c:	eb 3f                	jmp    801040ad <exit+0x71>
    if(curproc->ofile[fd]){
8010406e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104071:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104074:	83 c2 08             	add    $0x8,%edx
80104077:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010407b:	85 c0                	test   %eax,%eax
8010407d:	74 2a                	je     801040a9 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010407f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104082:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104085:	83 c2 08             	add    $0x8,%edx
80104088:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010408c:	83 ec 0c             	sub    $0xc,%esp
8010408f:	50                   	push   %eax
80104090:	e8 54 d0 ff ff       	call   801010e9 <fileclose>
80104095:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104098:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010409b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010409e:	83 c2 08             	add    $0x8,%edx
801040a1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040a8:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040a9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040ad:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040b1:	7e bb                	jle    8010406e <exit+0x32>
    }
  }

  begin_op();
801040b3:	e8 b9 f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040bb:	8b 40 68             	mov    0x68(%eax),%eax
801040be:	83 ec 0c             	sub    $0xc,%esp
801040c1:	50                   	push   %eax
801040c2:	e8 1e db ff ff       	call   80101be5 <iput>
801040c7:	83 c4 10             	add    $0x10,%esp
  end_op();
801040ca:	e8 32 f1 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801040cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040d2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040d9:	83 ec 0c             	sub    $0xc,%esp
801040dc:	68 00 55 19 80       	push   $0x80195500
801040e1:	e8 4a 08 00 00       	call   80104930 <acquire>
801040e6:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ec:	8b 40 14             	mov    0x14(%eax),%eax
801040ef:	83 ec 0c             	sub    $0xc,%esp
801040f2:	50                   	push   %eax
801040f3:	e8 97 04 00 00       	call   8010458f <wakeup1>
801040f8:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040fb:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104102:	eb 3a                	jmp    8010413e <exit+0x102>
    if(p->parent == curproc){
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	8b 40 14             	mov    0x14(%eax),%eax
8010410a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010410d:	75 28                	jne    80104137 <exit+0xfb>
      p->parent = initproc;
8010410f:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104118:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010411b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411e:	8b 40 0c             	mov    0xc(%eax),%eax
80104121:	83 f8 05             	cmp    $0x5,%eax
80104124:	75 11                	jne    80104137 <exit+0xfb>
        wakeup1(initproc);
80104126:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010412b:	83 ec 0c             	sub    $0xc,%esp
8010412e:	50                   	push   %eax
8010412f:	e8 5b 04 00 00       	call   8010458f <wakeup1>
80104134:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104137:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010413e:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104145:	72 bd                	jb     80104104 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010414a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104151:	e8 49 02 00 00       	call   8010439f <sched>
  panic("zombie exit");
80104156:	83 ec 0c             	sub    $0xc,%esp
80104159:	68 7f a7 10 80       	push   $0x8010a77f
8010415e:	e8 62 c4 ff ff       	call   801005c5 <panic>

80104163 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104163:	f3 0f 1e fb          	endbr32
80104167:	55                   	push   %ebp
80104168:	89 e5                	mov    %esp,%ebp
8010416a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010416d:	e8 37 fa ff ff       	call   80103ba9 <myproc>
80104172:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104175:	83 ec 0c             	sub    $0xc,%esp
80104178:	68 00 55 19 80       	push   $0x80195500
8010417d:	e8 ae 07 00 00       	call   80104930 <acquire>
80104182:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104185:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010418c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104193:	e9 a4 00 00 00       	jmp    8010423c <wait+0xd9>
      if(p->parent != curproc)
80104198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419b:	8b 40 14             	mov    0x14(%eax),%eax
8010419e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041a1:	0f 85 8d 00 00 00    	jne    80104234 <wait+0xd1>
        continue;
      havekids = 1;
801041a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	8b 40 0c             	mov    0xc(%eax),%eax
801041b4:	83 f8 05             	cmp    $0x5,%eax
801041b7:	75 7c                	jne    80104235 <wait+0xd2>
        // Found one.
        pid = p->pid;
801041b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bc:	8b 40 10             	mov    0x10(%eax),%eax
801041bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	8b 40 08             	mov    0x8(%eax),%eax
801041c8:	83 ec 0c             	sub    $0xc,%esp
801041cb:	50                   	push   %eax
801041cc:	e8 23 e6 ff ff       	call   801027f4 <kfree>
801041d1:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e1:	8b 40 04             	mov    0x4(%eax),%eax
801041e4:	83 ec 0c             	sub    $0xc,%esp
801041e7:	50                   	push   %eax
801041e8:	e8 4a 3a 00 00       	call   80107c37 <freevm>
801041ed:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104207:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104218:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010421f:	83 ec 0c             	sub    $0xc,%esp
80104222:	68 00 55 19 80       	push   $0x80195500
80104227:	e8 76 07 00 00       	call   801049a2 <release>
8010422c:	83 c4 10             	add    $0x10,%esp
        return pid;
8010422f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104232:	eb 54                	jmp    80104288 <wait+0x125>
        continue;
80104234:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104235:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010423c:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104243:	0f 82 4f ff ff ff    	jb     80104198 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010424d:	74 0a                	je     80104259 <wait+0xf6>
8010424f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104252:	8b 40 24             	mov    0x24(%eax),%eax
80104255:	85 c0                	test   %eax,%eax
80104257:	74 17                	je     80104270 <wait+0x10d>
      release(&ptable.lock);
80104259:	83 ec 0c             	sub    $0xc,%esp
8010425c:	68 00 55 19 80       	push   $0x80195500
80104261:	e8 3c 07 00 00       	call   801049a2 <release>
80104266:	83 c4 10             	add    $0x10,%esp
      return -1;
80104269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426e:	eb 18                	jmp    80104288 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104270:	83 ec 08             	sub    $0x8,%esp
80104273:	68 00 55 19 80       	push   $0x80195500
80104278:	ff 75 ec             	push   -0x14(%ebp)
8010427b:	e8 64 02 00 00       	call   801044e4 <sleep>
80104280:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104283:	e9 fd fe ff ff       	jmp    80104185 <wait+0x22>
  }
}
80104288:	c9                   	leave
80104289:	c3                   	ret

8010428a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010428a:	f3 0f 1e fb          	endbr32
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104294:	e8 94 f8 ff ff       	call   80103b2d <mycpu>
80104299:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010429c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010429f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042a6:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801042a9:	e8 37 f8 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801042ae:	83 ec 0c             	sub    $0xc,%esp
801042b1:	68 00 55 19 80       	push   $0x80195500
801042b6:	e8 75 06 00 00       	call   80104930 <acquire>
801042bb:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042be:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042c5:	eb 64                	jmp    8010432b <scheduler+0xa1>
      if(p->state != RUNNABLE)
801042c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ca:	8b 40 0c             	mov    0xc(%eax),%eax
801042cd:	83 f8 03             	cmp    $0x3,%eax
801042d0:	75 51                	jne    80104323 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801042d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d8:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801042de:	83 ec 0c             	sub    $0xc,%esp
801042e1:	ff 75 f4             	push   -0xc(%ebp)
801042e4:	e8 95 34 00 00       	call   8010777e <switchuvm>
801042e9:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801042ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ef:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801042f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f9:	8b 40 1c             	mov    0x1c(%eax),%eax
801042fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042ff:	83 c2 04             	add    $0x4,%edx
80104302:	83 ec 08             	sub    $0x8,%esp
80104305:	50                   	push   %eax
80104306:	52                   	push   %edx
80104307:	e8 47 0b 00 00       	call   80104e53 <swtch>
8010430c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010430f:	e8 4d 34 00 00       	call   80107761 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104314:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104317:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010431e:	00 00 00 
80104321:	eb 01                	jmp    80104324 <scheduler+0x9a>
        continue;
80104323:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104324:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010432b:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104332:	72 93                	jb     801042c7 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104334:	83 ec 0c             	sub    $0xc,%esp
80104337:	68 00 55 19 80       	push   $0x80195500
8010433c:	e8 61 06 00 00       	call   801049a2 <release>
80104341:	83 c4 10             	add    $0x10,%esp
    sti();
80104344:	e9 60 ff ff ff       	jmp    801042a9 <scheduler+0x1f>

80104349 <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
80104349:	f3 0f 1e fb          	endbr32
8010434d:	55                   	push   %ebp
8010434e:	89 e5                	mov    %esp,%ebp
80104350:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104353:	e8 51 f8 ff ff       	call   80103ba9 <myproc>
80104358:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
8010435b:	8b 55 08             	mov    0x8(%ebp),%edx
8010435e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104361:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
80104364:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104369:	c9                   	leave
8010436a:	c3                   	ret

8010436b <thread_count>:

int thread_count(int count)
{
8010436b:	f3 0f 1e fb          	endbr32
8010436f:	55                   	push   %ebp
80104370:	89 e5                	mov    %esp,%ebp
80104372:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104375:	e8 2f f8 ff ff       	call   80103ba9 <myproc>
8010437a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  curproc->thread_count += count;
8010437d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104380:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104386:	8b 45 08             	mov    0x8(%ebp),%eax
80104389:	01 c2                	add    %eax,%edx
8010438b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438e:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  return curproc->thread_count;
80104394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104397:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
8010439d:	c9                   	leave
8010439e:	c3                   	ret

8010439f <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010439f:	f3 0f 1e fb          	endbr32
801043a3:	55                   	push   %ebp
801043a4:	89 e5                	mov    %esp,%ebp
801043a6:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801043a9:	e8 fb f7 ff ff       	call   80103ba9 <myproc>
801043ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	68 00 55 19 80       	push   $0x80195500
801043b9:	e8 b9 06 00 00       	call   80104a77 <holding>
801043be:	83 c4 10             	add    $0x10,%esp
801043c1:	85 c0                	test   %eax,%eax
801043c3:	75 0d                	jne    801043d2 <sched+0x33>
    panic("sched ptable.lock");
801043c5:	83 ec 0c             	sub    $0xc,%esp
801043c8:	68 8b a7 10 80       	push   $0x8010a78b
801043cd:	e8 f3 c1 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
801043d2:	e8 56 f7 ff ff       	call   80103b2d <mycpu>
801043d7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801043dd:	83 f8 01             	cmp    $0x1,%eax
801043e0:	74 0d                	je     801043ef <sched+0x50>
    panic("sched locks");
801043e2:	83 ec 0c             	sub    $0xc,%esp
801043e5:	68 9d a7 10 80       	push   $0x8010a79d
801043ea:	e8 d6 c1 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
801043ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f2:	8b 40 0c             	mov    0xc(%eax),%eax
801043f5:	83 f8 04             	cmp    $0x4,%eax
801043f8:	75 0d                	jne    80104407 <sched+0x68>
    panic("sched running");
801043fa:	83 ec 0c             	sub    $0xc,%esp
801043fd:	68 a9 a7 10 80       	push   $0x8010a7a9
80104402:	e8 be c1 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104407:	e8 c9 f6 ff ff       	call   80103ad5 <readeflags>
8010440c:	25 00 02 00 00       	and    $0x200,%eax
80104411:	85 c0                	test   %eax,%eax
80104413:	74 0d                	je     80104422 <sched+0x83>
    panic("sched interruptible");
80104415:	83 ec 0c             	sub    $0xc,%esp
80104418:	68 b7 a7 10 80       	push   $0x8010a7b7
8010441d:	e8 a3 c1 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104422:	e8 06 f7 ff ff       	call   80103b2d <mycpu>
80104427:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010442d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104430:	e8 f8 f6 ff ff       	call   80103b2d <mycpu>
80104435:	8b 40 04             	mov    0x4(%eax),%eax
80104438:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010443b:	83 c2 1c             	add    $0x1c,%edx
8010443e:	83 ec 08             	sub    $0x8,%esp
80104441:	50                   	push   %eax
80104442:	52                   	push   %edx
80104443:	e8 0b 0a 00 00       	call   80104e53 <swtch>
80104448:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010444b:	e8 dd f6 ff ff       	call   80103b2d <mycpu>
80104450:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104453:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104459:	90                   	nop
8010445a:	c9                   	leave
8010445b:	c3                   	ret

8010445c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010445c:	f3 0f 1e fb          	endbr32
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104466:	83 ec 0c             	sub    $0xc,%esp
80104469:	68 00 55 19 80       	push   $0x80195500
8010446e:	e8 bd 04 00 00       	call   80104930 <acquire>
80104473:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104476:	e8 2e f7 ff ff       	call   80103ba9 <myproc>
8010447b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104482:	e8 18 ff ff ff       	call   8010439f <sched>
  release(&ptable.lock);
80104487:	83 ec 0c             	sub    $0xc,%esp
8010448a:	68 00 55 19 80       	push   $0x80195500
8010448f:	e8 0e 05 00 00       	call   801049a2 <release>
80104494:	83 c4 10             	add    $0x10,%esp
}
80104497:	90                   	nop
80104498:	c9                   	leave
80104499:	c3                   	ret

8010449a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010449a:	f3 0f 1e fb          	endbr32
8010449e:	55                   	push   %ebp
8010449f:	89 e5                	mov    %esp,%ebp
801044a1:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044a4:	83 ec 0c             	sub    $0xc,%esp
801044a7:	68 00 55 19 80       	push   $0x80195500
801044ac:	e8 f1 04 00 00       	call   801049a2 <release>
801044b1:	83 c4 10             	add    $0x10,%esp

  if (first) {
801044b4:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801044b9:	85 c0                	test   %eax,%eax
801044bb:	74 24                	je     801044e1 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801044bd:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801044c4:	00 00 00 
    iinit(ROOTDEV);
801044c7:	83 ec 0c             	sub    $0xc,%esp
801044ca:	6a 01                	push   $0x1
801044cc:	e8 25 d2 ff ff       	call   801016f6 <iinit>
801044d1:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	6a 01                	push   $0x1
801044d9:	e8 60 ea ff ff       	call   80102f3e <initlog>
801044de:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801044e1:	90                   	nop
801044e2:	c9                   	leave
801044e3:	c3                   	ret

801044e4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801044e4:	f3 0f 1e fb          	endbr32
801044e8:	55                   	push   %ebp
801044e9:	89 e5                	mov    %esp,%ebp
801044eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801044ee:	e8 b6 f6 ff ff       	call   80103ba9 <myproc>
801044f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801044f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044fa:	75 0d                	jne    80104509 <sleep+0x25>
    panic("sleep");
801044fc:	83 ec 0c             	sub    $0xc,%esp
801044ff:	68 cb a7 10 80       	push   $0x8010a7cb
80104504:	e8 bc c0 ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104509:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010450d:	75 0d                	jne    8010451c <sleep+0x38>
    panic("sleep without lk");
8010450f:	83 ec 0c             	sub    $0xc,%esp
80104512:	68 d1 a7 10 80       	push   $0x8010a7d1
80104517:	e8 a9 c0 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010451c:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104523:	74 1e                	je     80104543 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104525:	83 ec 0c             	sub    $0xc,%esp
80104528:	68 00 55 19 80       	push   $0x80195500
8010452d:	e8 fe 03 00 00       	call   80104930 <acquire>
80104532:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104535:	83 ec 0c             	sub    $0xc,%esp
80104538:	ff 75 0c             	push   0xc(%ebp)
8010453b:	e8 62 04 00 00       	call   801049a2 <release>
80104540:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	8b 55 08             	mov    0x8(%ebp),%edx
80104549:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  
  sched();
80104556:	e8 44 fe ff ff       	call   8010439f <sched>
  // Tidy up.
  p->chan = 0;
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104565:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010456c:	74 1e                	je     8010458c <sleep+0xa8>
    release(&ptable.lock);
8010456e:	83 ec 0c             	sub    $0xc,%esp
80104571:	68 00 55 19 80       	push   $0x80195500
80104576:	e8 27 04 00 00       	call   801049a2 <release>
8010457b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010457e:	83 ec 0c             	sub    $0xc,%esp
80104581:	ff 75 0c             	push   0xc(%ebp)
80104584:	e8 a7 03 00 00       	call   80104930 <acquire>
80104589:	83 c4 10             	add    $0x10,%esp
  }
}
8010458c:	90                   	nop
8010458d:	c9                   	leave
8010458e:	c3                   	ret

8010458f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010458f:	f3 0f 1e fb          	endbr32
80104593:	55                   	push   %ebp
80104594:	89 e5                	mov    %esp,%ebp
80104596:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104599:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801045a0:	eb 27                	jmp    801045c9 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801045a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045a5:	8b 40 0c             	mov    0xc(%eax),%eax
801045a8:	83 f8 02             	cmp    $0x2,%eax
801045ab:	75 15                	jne    801045c2 <wakeup1+0x33>
801045ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045b0:	8b 40 20             	mov    0x20(%eax),%eax
801045b3:	39 45 08             	cmp    %eax,0x8(%ebp)
801045b6:	75 0a                	jne    801045c2 <wakeup1+0x33>
      p->state = RUNNABLE;
801045b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045bb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045c2:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801045c9:	81 7d fc 34 76 19 80 	cmpl   $0x80197634,-0x4(%ebp)
801045d0:	72 d0                	jb     801045a2 <wakeup1+0x13>
}
801045d2:	90                   	nop
801045d3:	90                   	nop
801045d4:	c9                   	leave
801045d5:	c3                   	ret

801045d6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801045d6:	f3 0f 1e fb          	endbr32
801045da:	55                   	push   %ebp
801045db:	89 e5                	mov    %esp,%ebp
801045dd:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801045e0:	83 ec 0c             	sub    $0xc,%esp
801045e3:	68 00 55 19 80       	push   $0x80195500
801045e8:	e8 43 03 00 00       	call   80104930 <acquire>
801045ed:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801045f0:	83 ec 0c             	sub    $0xc,%esp
801045f3:	ff 75 08             	push   0x8(%ebp)
801045f6:	e8 94 ff ff ff       	call   8010458f <wakeup1>
801045fb:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045fe:	83 ec 0c             	sub    $0xc,%esp
80104601:	68 00 55 19 80       	push   $0x80195500
80104606:	e8 97 03 00 00       	call   801049a2 <release>
8010460b:	83 c4 10             	add    $0x10,%esp
}
8010460e:	90                   	nop
8010460f:	c9                   	leave
80104610:	c3                   	ret

80104611 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104611:	f3 0f 1e fb          	endbr32
80104615:	55                   	push   %ebp
80104616:	89 e5                	mov    %esp,%ebp
80104618:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	68 00 55 19 80       	push   $0x80195500
80104623:	e8 08 03 00 00       	call   80104930 <acquire>
80104628:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462b:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104632:	eb 48                	jmp    8010467c <kill+0x6b>
    if(p->pid == pid){
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	8b 40 10             	mov    0x10(%eax),%eax
8010463a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010463d:	75 36                	jne    80104675 <kill+0x64>
      p->killed = 1;
8010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104642:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464c:	8b 40 0c             	mov    0xc(%eax),%eax
8010464f:	83 f8 02             	cmp    $0x2,%eax
80104652:	75 0a                	jne    8010465e <kill+0x4d>
        p->state = RUNNABLE;
80104654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104657:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010465e:	83 ec 0c             	sub    $0xc,%esp
80104661:	68 00 55 19 80       	push   $0x80195500
80104666:	e8 37 03 00 00       	call   801049a2 <release>
8010466b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010466e:	b8 00 00 00 00       	mov    $0x0,%eax
80104673:	eb 25                	jmp    8010469a <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104675:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010467c:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104683:	72 af                	jb     80104634 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104685:	83 ec 0c             	sub    $0xc,%esp
80104688:	68 00 55 19 80       	push   $0x80195500
8010468d:	e8 10 03 00 00       	call   801049a2 <release>
80104692:	83 c4 10             	add    $0x10,%esp
  return -1;
80104695:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010469a:	c9                   	leave
8010469b:	c3                   	ret

8010469c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010469c:	f3 0f 1e fb          	endbr32
801046a0:	55                   	push   %ebp
801046a1:	89 e5                	mov    %esp,%ebp
801046a3:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a6:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801046ad:	e9 da 00 00 00       	jmp    8010478c <procdump+0xf0>
    if(p->state == UNUSED)
801046b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b5:	8b 40 0c             	mov    0xc(%eax),%eax
801046b8:	85 c0                	test   %eax,%eax
801046ba:	0f 84 c4 00 00 00    	je     80104784 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046c3:	8b 40 0c             	mov    0xc(%eax),%eax
801046c6:	83 f8 05             	cmp    $0x5,%eax
801046c9:	77 23                	ja     801046ee <procdump+0x52>
801046cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ce:	8b 40 0c             	mov    0xc(%eax),%eax
801046d1:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046d8:	85 c0                	test   %eax,%eax
801046da:	74 12                	je     801046ee <procdump+0x52>
      state = states[p->state];
801046dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046df:	8b 40 0c             	mov    0xc(%eax),%eax
801046e2:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046ec:	eb 07                	jmp    801046f5 <procdump+0x59>
    else
      state = "???";
801046ee:	c7 45 ec e2 a7 10 80 	movl   $0x8010a7e2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801046f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046f8:	8d 50 6c             	lea    0x6c(%eax),%edx
801046fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fe:	8b 40 10             	mov    0x10(%eax),%eax
80104701:	52                   	push   %edx
80104702:	ff 75 ec             	push   -0x14(%ebp)
80104705:	50                   	push   %eax
80104706:	68 e6 a7 10 80       	push   $0x8010a7e6
8010470b:	e8 fc bc ff ff       	call   8010040c <cprintf>
80104710:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104716:	8b 40 0c             	mov    0xc(%eax),%eax
80104719:	83 f8 02             	cmp    $0x2,%eax
8010471c:	75 54                	jne    80104772 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010471e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104721:	8b 40 1c             	mov    0x1c(%eax),%eax
80104724:	8b 40 0c             	mov    0xc(%eax),%eax
80104727:	83 c0 08             	add    $0x8,%eax
8010472a:	89 c2                	mov    %eax,%edx
8010472c:	83 ec 08             	sub    $0x8,%esp
8010472f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104732:	50                   	push   %eax
80104733:	52                   	push   %edx
80104734:	e8 bf 02 00 00       	call   801049f8 <getcallerpcs>
80104739:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010473c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104743:	eb 1c                	jmp    80104761 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104748:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010474c:	83 ec 08             	sub    $0x8,%esp
8010474f:	50                   	push   %eax
80104750:	68 ef a7 10 80       	push   $0x8010a7ef
80104755:	e8 b2 bc ff ff       	call   8010040c <cprintf>
8010475a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010475d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104761:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104765:	7f 0b                	jg     80104772 <procdump+0xd6>
80104767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010476e:	85 c0                	test   %eax,%eax
80104770:	75 d3                	jne    80104745 <procdump+0xa9>
    }
    cprintf("\n");
80104772:	83 ec 0c             	sub    $0xc,%esp
80104775:	68 f3 a7 10 80       	push   $0x8010a7f3
8010477a:	e8 8d bc ff ff       	call   8010040c <cprintf>
8010477f:	83 c4 10             	add    $0x10,%esp
80104782:	eb 01                	jmp    80104785 <procdump+0xe9>
      continue;
80104784:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104785:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
8010478c:	81 7d f0 34 76 19 80 	cmpl   $0x80197634,-0x10(%ebp)
80104793:	0f 82 19 ff ff ff    	jb     801046b2 <procdump+0x16>
  }
}
80104799:	90                   	nop
8010479a:	90                   	nop
8010479b:	c9                   	leave
8010479c:	c3                   	ret

8010479d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010479d:	f3 0f 1e fb          	endbr32
801047a1:	55                   	push   %ebp
801047a2:	89 e5                	mov    %esp,%ebp
801047a4:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801047a7:	8b 45 08             	mov    0x8(%ebp),%eax
801047aa:	83 c0 04             	add    $0x4,%eax
801047ad:	83 ec 08             	sub    $0x8,%esp
801047b0:	68 1f a8 10 80       	push   $0x8010a81f
801047b5:	50                   	push   %eax
801047b6:	e8 4f 01 00 00       	call   8010490a <initlock>
801047bb:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801047be:	8b 45 08             	mov    0x8(%ebp),%eax
801047c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801047c4:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047d0:	8b 45 08             	mov    0x8(%ebp),%eax
801047d3:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801047da:	90                   	nop
801047db:	c9                   	leave
801047dc:	c3                   	ret

801047dd <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801047dd:	f3 0f 1e fb          	endbr32
801047e1:	55                   	push   %ebp
801047e2:	89 e5                	mov    %esp,%ebp
801047e4:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047e7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ea:	83 c0 04             	add    $0x4,%eax
801047ed:	83 ec 0c             	sub    $0xc,%esp
801047f0:	50                   	push   %eax
801047f1:	e8 3a 01 00 00       	call   80104930 <acquire>
801047f6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047f9:	eb 15                	jmp    80104810 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801047fb:	8b 45 08             	mov    0x8(%ebp),%eax
801047fe:	83 c0 04             	add    $0x4,%eax
80104801:	83 ec 08             	sub    $0x8,%esp
80104804:	50                   	push   %eax
80104805:	ff 75 08             	push   0x8(%ebp)
80104808:	e8 d7 fc ff ff       	call   801044e4 <sleep>
8010480d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104810:	8b 45 08             	mov    0x8(%ebp),%eax
80104813:	8b 00                	mov    (%eax),%eax
80104815:	85 c0                	test   %eax,%eax
80104817:	75 e2                	jne    801047fb <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104819:	8b 45 08             	mov    0x8(%ebp),%eax
8010481c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104822:	e8 82 f3 ff ff       	call   80103ba9 <myproc>
80104827:	8b 50 10             	mov    0x10(%eax),%edx
8010482a:	8b 45 08             	mov    0x8(%ebp),%eax
8010482d:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104830:	8b 45 08             	mov    0x8(%ebp),%eax
80104833:	83 c0 04             	add    $0x4,%eax
80104836:	83 ec 0c             	sub    $0xc,%esp
80104839:	50                   	push   %eax
8010483a:	e8 63 01 00 00       	call   801049a2 <release>
8010483f:	83 c4 10             	add    $0x10,%esp
}
80104842:	90                   	nop
80104843:	c9                   	leave
80104844:	c3                   	ret

80104845 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104845:	f3 0f 1e fb          	endbr32
80104849:	55                   	push   %ebp
8010484a:	89 e5                	mov    %esp,%ebp
8010484c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010484f:	8b 45 08             	mov    0x8(%ebp),%eax
80104852:	83 c0 04             	add    $0x4,%eax
80104855:	83 ec 0c             	sub    $0xc,%esp
80104858:	50                   	push   %eax
80104859:	e8 d2 00 00 00       	call   80104930 <acquire>
8010485e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104861:	8b 45 08             	mov    0x8(%ebp),%eax
80104864:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010486a:	8b 45 08             	mov    0x8(%ebp),%eax
8010486d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104874:	83 ec 0c             	sub    $0xc,%esp
80104877:	ff 75 08             	push   0x8(%ebp)
8010487a:	e8 57 fd ff ff       	call   801045d6 <wakeup>
8010487f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104882:	8b 45 08             	mov    0x8(%ebp),%eax
80104885:	83 c0 04             	add    $0x4,%eax
80104888:	83 ec 0c             	sub    $0xc,%esp
8010488b:	50                   	push   %eax
8010488c:	e8 11 01 00 00       	call   801049a2 <release>
80104891:	83 c4 10             	add    $0x10,%esp
}
80104894:	90                   	nop
80104895:	c9                   	leave
80104896:	c3                   	ret

80104897 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104897:	f3 0f 1e fb          	endbr32
8010489b:	55                   	push   %ebp
8010489c:	89 e5                	mov    %esp,%ebp
8010489e:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801048a1:	8b 45 08             	mov    0x8(%ebp),%eax
801048a4:	83 c0 04             	add    $0x4,%eax
801048a7:	83 ec 0c             	sub    $0xc,%esp
801048aa:	50                   	push   %eax
801048ab:	e8 80 00 00 00       	call   80104930 <acquire>
801048b0:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801048b3:	8b 45 08             	mov    0x8(%ebp),%eax
801048b6:	8b 00                	mov    (%eax),%eax
801048b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801048bb:	8b 45 08             	mov    0x8(%ebp),%eax
801048be:	83 c0 04             	add    $0x4,%eax
801048c1:	83 ec 0c             	sub    $0xc,%esp
801048c4:	50                   	push   %eax
801048c5:	e8 d8 00 00 00       	call   801049a2 <release>
801048ca:	83 c4 10             	add    $0x10,%esp
  return r;
801048cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801048d0:	c9                   	leave
801048d1:	c3                   	ret

801048d2 <readeflags>:
{
801048d2:	55                   	push   %ebp
801048d3:	89 e5                	mov    %esp,%ebp
801048d5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801048d8:	9c                   	pushf
801048d9:	58                   	pop    %eax
801048da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801048dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801048e0:	c9                   	leave
801048e1:	c3                   	ret

801048e2 <cli>:
{
801048e2:	55                   	push   %ebp
801048e3:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801048e5:	fa                   	cli
}
801048e6:	90                   	nop
801048e7:	5d                   	pop    %ebp
801048e8:	c3                   	ret

801048e9 <sti>:
{
801048e9:	55                   	push   %ebp
801048ea:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801048ec:	fb                   	sti
}
801048ed:	90                   	nop
801048ee:	5d                   	pop    %ebp
801048ef:	c3                   	ret

801048f0 <xchg>:
{
801048f0:	55                   	push   %ebp
801048f1:	89 e5                	mov    %esp,%ebp
801048f3:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801048f6:	8b 55 08             	mov    0x8(%ebp),%edx
801048f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801048fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
801048ff:	f0 87 02             	lock xchg %eax,(%edx)
80104902:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104905:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104908:	c9                   	leave
80104909:	c3                   	ret

8010490a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010490a:	f3 0f 1e fb          	endbr32
8010490e:	55                   	push   %ebp
8010490f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104911:	8b 45 08             	mov    0x8(%ebp),%eax
80104914:	8b 55 0c             	mov    0xc(%ebp),%edx
80104917:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010491a:	8b 45 08             	mov    0x8(%ebp),%eax
8010491d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104923:	8b 45 08             	mov    0x8(%ebp),%eax
80104926:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010492d:	90                   	nop
8010492e:	5d                   	pop    %ebp
8010492f:	c3                   	ret

80104930 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104930:	f3 0f 1e fb          	endbr32
80104934:	55                   	push   %ebp
80104935:	89 e5                	mov    %esp,%ebp
80104937:	53                   	push   %ebx
80104938:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010493b:	e8 6c 01 00 00       	call   80104aac <pushcli>
  if(holding(lk)){
80104940:	8b 45 08             	mov    0x8(%ebp),%eax
80104943:	83 ec 0c             	sub    $0xc,%esp
80104946:	50                   	push   %eax
80104947:	e8 2b 01 00 00       	call   80104a77 <holding>
8010494c:	83 c4 10             	add    $0x10,%esp
8010494f:	85 c0                	test   %eax,%eax
80104951:	74 0d                	je     80104960 <acquire+0x30>
    panic("acquire");
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	68 2a a8 10 80       	push   $0x8010a82a
8010495b:	e8 65 bc ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104960:	90                   	nop
80104961:	8b 45 08             	mov    0x8(%ebp),%eax
80104964:	83 ec 08             	sub    $0x8,%esp
80104967:	6a 01                	push   $0x1
80104969:	50                   	push   %eax
8010496a:	e8 81 ff ff ff       	call   801048f0 <xchg>
8010496f:	83 c4 10             	add    $0x10,%esp
80104972:	85 c0                	test   %eax,%eax
80104974:	75 eb                	jne    80104961 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104976:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010497b:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010497e:	e8 aa f1 ff ff       	call   80103b2d <mycpu>
80104983:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104986:	8b 45 08             	mov    0x8(%ebp),%eax
80104989:	83 c0 0c             	add    $0xc,%eax
8010498c:	83 ec 08             	sub    $0x8,%esp
8010498f:	50                   	push   %eax
80104990:	8d 45 08             	lea    0x8(%ebp),%eax
80104993:	50                   	push   %eax
80104994:	e8 5f 00 00 00       	call   801049f8 <getcallerpcs>
80104999:	83 c4 10             	add    $0x10,%esp
}
8010499c:	90                   	nop
8010499d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049a0:	c9                   	leave
801049a1:	c3                   	ret

801049a2 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801049a2:	f3 0f 1e fb          	endbr32
801049a6:	55                   	push   %ebp
801049a7:	89 e5                	mov    %esp,%ebp
801049a9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801049ac:	83 ec 0c             	sub    $0xc,%esp
801049af:	ff 75 08             	push   0x8(%ebp)
801049b2:	e8 c0 00 00 00       	call   80104a77 <holding>
801049b7:	83 c4 10             	add    $0x10,%esp
801049ba:	85 c0                	test   %eax,%eax
801049bc:	75 0d                	jne    801049cb <release+0x29>
    panic("release");
801049be:	83 ec 0c             	sub    $0xc,%esp
801049c1:	68 32 a8 10 80       	push   $0x8010a832
801049c6:	e8 fa bb ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
801049cb:	8b 45 08             	mov    0x8(%ebp),%eax
801049ce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801049df:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801049e4:	8b 45 08             	mov    0x8(%ebp),%eax
801049e7:	8b 55 08             	mov    0x8(%ebp),%edx
801049ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801049f0:	e8 08 01 00 00       	call   80104afd <popcli>
}
801049f5:	90                   	nop
801049f6:	c9                   	leave
801049f7:	c3                   	ret

801049f8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801049f8:	f3 0f 1e fb          	endbr32
801049fc:	55                   	push   %ebp
801049fd:	89 e5                	mov    %esp,%ebp
801049ff:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104a02:	8b 45 08             	mov    0x8(%ebp),%eax
80104a05:	83 e8 08             	sub    $0x8,%eax
80104a08:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a0b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104a12:	eb 38                	jmp    80104a4c <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a14:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104a18:	74 53                	je     80104a6d <getcallerpcs+0x75>
80104a1a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104a21:	76 4a                	jbe    80104a6d <getcallerpcs+0x75>
80104a23:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104a27:	74 44                	je     80104a6d <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104a29:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a36:	01 c2                	add    %eax,%edx
80104a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a3b:	8b 40 04             	mov    0x4(%eax),%eax
80104a3e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104a40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a43:	8b 00                	mov    (%eax),%eax
80104a45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a48:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a4c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a50:	7e c2                	jle    80104a14 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104a52:	eb 19                	jmp    80104a6d <getcallerpcs+0x75>
    pcs[i] = 0;
80104a54:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a57:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a61:	01 d0                	add    %edx,%eax
80104a63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a69:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a6d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a71:	7e e1                	jle    80104a54 <getcallerpcs+0x5c>
}
80104a73:	90                   	nop
80104a74:	90                   	nop
80104a75:	c9                   	leave
80104a76:	c3                   	ret

80104a77 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a77:	f3 0f 1e fb          	endbr32
80104a7b:	55                   	push   %ebp
80104a7c:	89 e5                	mov    %esp,%ebp
80104a7e:	53                   	push   %ebx
80104a7f:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a82:	8b 45 08             	mov    0x8(%ebp),%eax
80104a85:	8b 00                	mov    (%eax),%eax
80104a87:	85 c0                	test   %eax,%eax
80104a89:	74 16                	je     80104aa1 <holding+0x2a>
80104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8e:	8b 58 08             	mov    0x8(%eax),%ebx
80104a91:	e8 97 f0 ff ff       	call   80103b2d <mycpu>
80104a96:	39 c3                	cmp    %eax,%ebx
80104a98:	75 07                	jne    80104aa1 <holding+0x2a>
80104a9a:	b8 01 00 00 00       	mov    $0x1,%eax
80104a9f:	eb 05                	jmp    80104aa6 <holding+0x2f>
80104aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104aa6:	83 c4 04             	add    $0x4,%esp
80104aa9:	5b                   	pop    %ebx
80104aaa:	5d                   	pop    %ebp
80104aab:	c3                   	ret

80104aac <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104aac:	f3 0f 1e fb          	endbr32
80104ab0:	55                   	push   %ebp
80104ab1:	89 e5                	mov    %esp,%ebp
80104ab3:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ab6:	e8 17 fe ff ff       	call   801048d2 <readeflags>
80104abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104abe:	e8 1f fe ff ff       	call   801048e2 <cli>
  if(mycpu()->ncli == 0)
80104ac3:	e8 65 f0 ff ff       	call   80103b2d <mycpu>
80104ac8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ace:	85 c0                	test   %eax,%eax
80104ad0:	75 14                	jne    80104ae6 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104ad2:	e8 56 f0 ff ff       	call   80103b2d <mycpu>
80104ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ada:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ae0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ae6:	e8 42 f0 ff ff       	call   80103b2d <mycpu>
80104aeb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104af1:	83 c2 01             	add    $0x1,%edx
80104af4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104afa:	90                   	nop
80104afb:	c9                   	leave
80104afc:	c3                   	ret

80104afd <popcli>:

void
popcli(void)
{
80104afd:	f3 0f 1e fb          	endbr32
80104b01:	55                   	push   %ebp
80104b02:	89 e5                	mov    %esp,%ebp
80104b04:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104b07:	e8 c6 fd ff ff       	call   801048d2 <readeflags>
80104b0c:	25 00 02 00 00       	and    $0x200,%eax
80104b11:	85 c0                	test   %eax,%eax
80104b13:	74 0d                	je     80104b22 <popcli+0x25>
    panic("popcli - interruptible");
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 3a a8 10 80       	push   $0x8010a83a
80104b1d:	e8 a3 ba ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104b22:	e8 06 f0 ff ff       	call   80103b2d <mycpu>
80104b27:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104b2d:	83 ea 01             	sub    $0x1,%edx
80104b30:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104b36:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b3c:	85 c0                	test   %eax,%eax
80104b3e:	79 0d                	jns    80104b4d <popcli+0x50>
    panic("popcli");
80104b40:	83 ec 0c             	sub    $0xc,%esp
80104b43:	68 51 a8 10 80       	push   $0x8010a851
80104b48:	e8 78 ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104b4d:	e8 db ef ff ff       	call   80103b2d <mycpu>
80104b52:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b58:	85 c0                	test   %eax,%eax
80104b5a:	75 14                	jne    80104b70 <popcli+0x73>
80104b5c:	e8 cc ef ff ff       	call   80103b2d <mycpu>
80104b61:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b67:	85 c0                	test   %eax,%eax
80104b69:	74 05                	je     80104b70 <popcli+0x73>
    sti();
80104b6b:	e8 79 fd ff ff       	call   801048e9 <sti>
}
80104b70:	90                   	nop
80104b71:	c9                   	leave
80104b72:	c3                   	ret

80104b73 <stosb>:
{
80104b73:	55                   	push   %ebp
80104b74:	89 e5                	mov    %esp,%ebp
80104b76:	57                   	push   %edi
80104b77:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b7b:	8b 55 10             	mov    0x10(%ebp),%edx
80104b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b81:	89 cb                	mov    %ecx,%ebx
80104b83:	89 df                	mov    %ebx,%edi
80104b85:	89 d1                	mov    %edx,%ecx
80104b87:	fc                   	cld
80104b88:	f3 aa                	rep stos %al,%es:(%edi)
80104b8a:	89 ca                	mov    %ecx,%edx
80104b8c:	89 fb                	mov    %edi,%ebx
80104b8e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b91:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b94:	90                   	nop
80104b95:	5b                   	pop    %ebx
80104b96:	5f                   	pop    %edi
80104b97:	5d                   	pop    %ebp
80104b98:	c3                   	ret

80104b99 <stosl>:
{
80104b99:	55                   	push   %ebp
80104b9a:	89 e5                	mov    %esp,%ebp
80104b9c:	57                   	push   %edi
80104b9d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ba1:	8b 55 10             	mov    0x10(%ebp),%edx
80104ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba7:	89 cb                	mov    %ecx,%ebx
80104ba9:	89 df                	mov    %ebx,%edi
80104bab:	89 d1                	mov    %edx,%ecx
80104bad:	fc                   	cld
80104bae:	f3 ab                	rep stos %eax,%es:(%edi)
80104bb0:	89 ca                	mov    %ecx,%edx
80104bb2:	89 fb                	mov    %edi,%ebx
80104bb4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104bb7:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104bba:	90                   	nop
80104bbb:	5b                   	pop    %ebx
80104bbc:	5f                   	pop    %edi
80104bbd:	5d                   	pop    %ebp
80104bbe:	c3                   	ret

80104bbf <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104bbf:	f3 0f 1e fb          	endbr32
80104bc3:	55                   	push   %ebp
80104bc4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc9:	83 e0 03             	and    $0x3,%eax
80104bcc:	85 c0                	test   %eax,%eax
80104bce:	75 43                	jne    80104c13 <memset+0x54>
80104bd0:	8b 45 10             	mov    0x10(%ebp),%eax
80104bd3:	83 e0 03             	and    $0x3,%eax
80104bd6:	85 c0                	test   %eax,%eax
80104bd8:	75 39                	jne    80104c13 <memset+0x54>
    c &= 0xFF;
80104bda:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104be1:	8b 45 10             	mov    0x10(%ebp),%eax
80104be4:	c1 e8 02             	shr    $0x2,%eax
80104be7:	89 c1                	mov    %eax,%ecx
80104be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bec:	c1 e0 18             	shl    $0x18,%eax
80104bef:	89 c2                	mov    %eax,%edx
80104bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf4:	c1 e0 10             	shl    $0x10,%eax
80104bf7:	09 c2                	or     %eax,%edx
80104bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bfc:	c1 e0 08             	shl    $0x8,%eax
80104bff:	09 d0                	or     %edx,%eax
80104c01:	0b 45 0c             	or     0xc(%ebp),%eax
80104c04:	51                   	push   %ecx
80104c05:	50                   	push   %eax
80104c06:	ff 75 08             	push   0x8(%ebp)
80104c09:	e8 8b ff ff ff       	call   80104b99 <stosl>
80104c0e:	83 c4 0c             	add    $0xc,%esp
80104c11:	eb 12                	jmp    80104c25 <memset+0x66>
  } else
    stosb(dst, c, n);
80104c13:	8b 45 10             	mov    0x10(%ebp),%eax
80104c16:	50                   	push   %eax
80104c17:	ff 75 0c             	push   0xc(%ebp)
80104c1a:	ff 75 08             	push   0x8(%ebp)
80104c1d:	e8 51 ff ff ff       	call   80104b73 <stosb>
80104c22:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104c25:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c28:	c9                   	leave
80104c29:	c3                   	ret

80104c2a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104c2a:	f3 0f 1e fb          	endbr32
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104c40:	eb 30                	jmp    80104c72 <memcmp+0x48>
    if(*s1 != *s2)
80104c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c45:	0f b6 10             	movzbl (%eax),%edx
80104c48:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c4b:	0f b6 00             	movzbl (%eax),%eax
80104c4e:	38 c2                	cmp    %al,%dl
80104c50:	74 18                	je     80104c6a <memcmp+0x40>
      return *s1 - *s2;
80104c52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c55:	0f b6 00             	movzbl (%eax),%eax
80104c58:	0f b6 d0             	movzbl %al,%edx
80104c5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c5e:	0f b6 00             	movzbl (%eax),%eax
80104c61:	0f b6 c0             	movzbl %al,%eax
80104c64:	29 c2                	sub    %eax,%edx
80104c66:	89 d0                	mov    %edx,%eax
80104c68:	eb 1a                	jmp    80104c84 <memcmp+0x5a>
    s1++, s2++;
80104c6a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c6e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c72:	8b 45 10             	mov    0x10(%ebp),%eax
80104c75:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c78:	89 55 10             	mov    %edx,0x10(%ebp)
80104c7b:	85 c0                	test   %eax,%eax
80104c7d:	75 c3                	jne    80104c42 <memcmp+0x18>
  }

  return 0;
80104c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c84:	c9                   	leave
80104c85:	c3                   	ret

80104c86 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c86:	f3 0f 1e fb          	endbr32
80104c8a:	55                   	push   %ebp
80104c8b:	89 e5                	mov    %esp,%ebp
80104c8d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c90:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c96:	8b 45 08             	mov    0x8(%ebp),%eax
80104c99:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ca2:	73 54                	jae    80104cf8 <memmove+0x72>
80104ca4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ca7:	8b 45 10             	mov    0x10(%ebp),%eax
80104caa:	01 d0                	add    %edx,%eax
80104cac:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104caf:	73 47                	jae    80104cf8 <memmove+0x72>
    s += n;
80104cb1:	8b 45 10             	mov    0x10(%ebp),%eax
80104cb4:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104cb7:	8b 45 10             	mov    0x10(%ebp),%eax
80104cba:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104cbd:	eb 13                	jmp    80104cd2 <memmove+0x4c>
      *--d = *--s;
80104cbf:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104cc3:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cca:	0f b6 10             	movzbl (%eax),%edx
80104ccd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cd0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104cd2:	8b 45 10             	mov    0x10(%ebp),%eax
80104cd5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cd8:	89 55 10             	mov    %edx,0x10(%ebp)
80104cdb:	85 c0                	test   %eax,%eax
80104cdd:	75 e0                	jne    80104cbf <memmove+0x39>
  if(s < d && s + n > d){
80104cdf:	eb 24                	jmp    80104d05 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104ce1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ce4:	8d 42 01             	lea    0x1(%edx),%eax
80104ce7:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ced:	8d 48 01             	lea    0x1(%eax),%ecx
80104cf0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104cf3:	0f b6 12             	movzbl (%edx),%edx
80104cf6:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104cf8:	8b 45 10             	mov    0x10(%ebp),%eax
80104cfb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cfe:	89 55 10             	mov    %edx,0x10(%ebp)
80104d01:	85 c0                	test   %eax,%eax
80104d03:	75 dc                	jne    80104ce1 <memmove+0x5b>

  return dst;
80104d05:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d08:	c9                   	leave
80104d09:	c3                   	ret

80104d0a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104d0a:	f3 0f 1e fb          	endbr32
80104d0e:	55                   	push   %ebp
80104d0f:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104d11:	ff 75 10             	push   0x10(%ebp)
80104d14:	ff 75 0c             	push   0xc(%ebp)
80104d17:	ff 75 08             	push   0x8(%ebp)
80104d1a:	e8 67 ff ff ff       	call   80104c86 <memmove>
80104d1f:	83 c4 0c             	add    $0xc,%esp
}
80104d22:	c9                   	leave
80104d23:	c3                   	ret

80104d24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104d24:	f3 0f 1e fb          	endbr32
80104d28:	55                   	push   %ebp
80104d29:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104d2b:	eb 0c                	jmp    80104d39 <strncmp+0x15>
    n--, p++, q++;
80104d2d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104d35:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104d39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d3d:	74 1a                	je     80104d59 <strncmp+0x35>
80104d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d42:	0f b6 00             	movzbl (%eax),%eax
80104d45:	84 c0                	test   %al,%al
80104d47:	74 10                	je     80104d59 <strncmp+0x35>
80104d49:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4c:	0f b6 10             	movzbl (%eax),%edx
80104d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d52:	0f b6 00             	movzbl (%eax),%eax
80104d55:	38 c2                	cmp    %al,%dl
80104d57:	74 d4                	je     80104d2d <strncmp+0x9>
  if(n == 0)
80104d59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d5d:	75 07                	jne    80104d66 <strncmp+0x42>
    return 0;
80104d5f:	b8 00 00 00 00       	mov    $0x0,%eax
80104d64:	eb 16                	jmp    80104d7c <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104d66:	8b 45 08             	mov    0x8(%ebp),%eax
80104d69:	0f b6 00             	movzbl (%eax),%eax
80104d6c:	0f b6 d0             	movzbl %al,%edx
80104d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d72:	0f b6 00             	movzbl (%eax),%eax
80104d75:	0f b6 c0             	movzbl %al,%eax
80104d78:	29 c2                	sub    %eax,%edx
80104d7a:	89 d0                	mov    %edx,%eax
}
80104d7c:	5d                   	pop    %ebp
80104d7d:	c3                   	ret

80104d7e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d7e:	f3 0f 1e fb          	endbr32
80104d82:	55                   	push   %ebp
80104d83:	89 e5                	mov    %esp,%ebp
80104d85:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d88:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d8e:	90                   	nop
80104d8f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d92:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d95:	89 55 10             	mov    %edx,0x10(%ebp)
80104d98:	85 c0                	test   %eax,%eax
80104d9a:	7e 2c                	jle    80104dc8 <strncpy+0x4a>
80104d9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d9f:	8d 42 01             	lea    0x1(%edx),%eax
80104da2:	89 45 0c             	mov    %eax,0xc(%ebp)
80104da5:	8b 45 08             	mov    0x8(%ebp),%eax
80104da8:	8d 48 01             	lea    0x1(%eax),%ecx
80104dab:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104dae:	0f b6 12             	movzbl (%edx),%edx
80104db1:	88 10                	mov    %dl,(%eax)
80104db3:	0f b6 00             	movzbl (%eax),%eax
80104db6:	84 c0                	test   %al,%al
80104db8:	75 d5                	jne    80104d8f <strncpy+0x11>
    ;
  while(n-- > 0)
80104dba:	eb 0c                	jmp    80104dc8 <strncpy+0x4a>
    *s++ = 0;
80104dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbf:	8d 50 01             	lea    0x1(%eax),%edx
80104dc2:	89 55 08             	mov    %edx,0x8(%ebp)
80104dc5:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104dc8:	8b 45 10             	mov    0x10(%ebp),%eax
80104dcb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104dce:	89 55 10             	mov    %edx,0x10(%ebp)
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	7f e7                	jg     80104dbc <strncpy+0x3e>
  return os;
80104dd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dd8:	c9                   	leave
80104dd9:	c3                   	ret

80104dda <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104dda:	f3 0f 1e fb          	endbr32
80104dde:	55                   	push   %ebp
80104ddf:	89 e5                	mov    %esp,%ebp
80104de1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104de4:	8b 45 08             	mov    0x8(%ebp),%eax
80104de7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104dea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104dee:	7f 05                	jg     80104df5 <safestrcpy+0x1b>
    return os;
80104df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df3:	eb 31                	jmp    80104e26 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104df5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104df9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104dfd:	7e 1e                	jle    80104e1d <safestrcpy+0x43>
80104dff:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e02:	8d 42 01             	lea    0x1(%edx),%eax
80104e05:	89 45 0c             	mov    %eax,0xc(%ebp)
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	8d 48 01             	lea    0x1(%eax),%ecx
80104e0e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104e11:	0f b6 12             	movzbl (%edx),%edx
80104e14:	88 10                	mov    %dl,(%eax)
80104e16:	0f b6 00             	movzbl (%eax),%eax
80104e19:	84 c0                	test   %al,%al
80104e1b:	75 d8                	jne    80104df5 <safestrcpy+0x1b>
    ;
  *s = 0;
80104e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e20:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104e23:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e26:	c9                   	leave
80104e27:	c3                   	ret

80104e28 <strlen>:

int
strlen(const char *s)
{
80104e28:	f3 0f 1e fb          	endbr32
80104e2c:	55                   	push   %ebp
80104e2d:	89 e5                	mov    %esp,%ebp
80104e2f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104e32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104e39:	eb 04                	jmp    80104e3f <strlen+0x17>
80104e3b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e3f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e42:	8b 45 08             	mov    0x8(%ebp),%eax
80104e45:	01 d0                	add    %edx,%eax
80104e47:	0f b6 00             	movzbl (%eax),%eax
80104e4a:	84 c0                	test   %al,%al
80104e4c:	75 ed                	jne    80104e3b <strlen+0x13>
    ;
  return n;
80104e4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e51:	c9                   	leave
80104e52:	c3                   	ret

80104e53 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e53:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e57:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104e5b:	55                   	push   %ebp
  pushl %ebx
80104e5c:	53                   	push   %ebx
  pushl %esi
80104e5d:	56                   	push   %esi
  pushl %edi
80104e5e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e5f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e61:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e63:	5f                   	pop    %edi
  popl %esi
80104e64:	5e                   	pop    %esi
  popl %ebx
80104e65:	5b                   	pop    %ebx
  popl %ebp
80104e66:	5d                   	pop    %ebp
  ret
80104e67:	c3                   	ret

80104e68 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e68:	f3 0f 1e fb          	endbr32
80104e6c:	55                   	push   %ebp
80104e6d:	89 e5                	mov    %esp,%ebp
80104e6f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e72:	e8 32 ed ff ff       	call   80103ba9 <myproc>
80104e77:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7d:	8b 00                	mov    (%eax),%eax
80104e7f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e82:	73 0f                	jae    80104e93 <fetchint+0x2b>
80104e84:	8b 45 08             	mov    0x8(%ebp),%eax
80104e87:	8d 50 04             	lea    0x4(%eax),%edx
80104e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8d:	8b 00                	mov    (%eax),%eax
80104e8f:	39 c2                	cmp    %eax,%edx
80104e91:	76 07                	jbe    80104e9a <fetchint+0x32>
    return -1;
80104e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e98:	eb 0f                	jmp    80104ea9 <fetchint+0x41>
  *ip = *(int*)(addr);
80104e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e9d:	8b 10                	mov    (%eax),%edx
80104e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ea2:	89 10                	mov    %edx,(%eax)
  return 0;
80104ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ea9:	c9                   	leave
80104eaa:	c3                   	ret

80104eab <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104eab:	f3 0f 1e fb          	endbr32
80104eaf:	55                   	push   %ebp
80104eb0:	89 e5                	mov    %esp,%ebp
80104eb2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104eb5:	e8 ef ec ff ff       	call   80103ba9 <myproc>
80104eba:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec0:	8b 00                	mov    (%eax),%eax
80104ec2:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ec5:	72 07                	jb     80104ece <fetchstr+0x23>
    return -1;
80104ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecc:	eb 43                	jmp    80104f11 <fetchstr+0x66>
  *pp = (char*)addr;
80104ece:	8b 55 08             	mov    0x8(%ebp),%edx
80104ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed4:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed9:	8b 00                	mov    (%eax),%eax
80104edb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104ede:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee1:	8b 00                	mov    (%eax),%eax
80104ee3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ee6:	eb 1c                	jmp    80104f04 <fetchstr+0x59>
    if(*s == 0)
80104ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eeb:	0f b6 00             	movzbl (%eax),%eax
80104eee:	84 c0                	test   %al,%al
80104ef0:	75 0e                	jne    80104f00 <fetchstr+0x55>
      return s - *pp;
80104ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef5:	8b 00                	mov    (%eax),%eax
80104ef7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104efa:	29 c2                	sub    %eax,%edx
80104efc:	89 d0                	mov    %edx,%eax
80104efe:	eb 11                	jmp    80104f11 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80104f00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f07:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104f0a:	72 dc                	jb     80104ee8 <fetchstr+0x3d>
  }
  return -1;
80104f0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f11:	c9                   	leave
80104f12:	c3                   	ret

80104f13 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104f13:	f3 0f 1e fb          	endbr32
80104f17:	55                   	push   %ebp
80104f18:	89 e5                	mov    %esp,%ebp
80104f1a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f1d:	e8 87 ec ff ff       	call   80103ba9 <myproc>
80104f22:	8b 40 18             	mov    0x18(%eax),%eax
80104f25:	8b 40 44             	mov    0x44(%eax),%eax
80104f28:	8b 55 08             	mov    0x8(%ebp),%edx
80104f2b:	c1 e2 02             	shl    $0x2,%edx
80104f2e:	01 d0                	add    %edx,%eax
80104f30:	83 c0 04             	add    $0x4,%eax
80104f33:	83 ec 08             	sub    $0x8,%esp
80104f36:	ff 75 0c             	push   0xc(%ebp)
80104f39:	50                   	push   %eax
80104f3a:	e8 29 ff ff ff       	call   80104e68 <fetchint>
80104f3f:	83 c4 10             	add    $0x10,%esp
}
80104f42:	c9                   	leave
80104f43:	c3                   	ret

80104f44 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f44:	f3 0f 1e fb          	endbr32
80104f48:	55                   	push   %ebp
80104f49:	89 e5                	mov    %esp,%ebp
80104f4b:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104f4e:	e8 56 ec ff ff       	call   80103ba9 <myproc>
80104f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104f56:	83 ec 08             	sub    $0x8,%esp
80104f59:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f5c:	50                   	push   %eax
80104f5d:	ff 75 08             	push   0x8(%ebp)
80104f60:	e8 ae ff ff ff       	call   80104f13 <argint>
80104f65:	83 c4 10             	add    $0x10,%esp
80104f68:	85 c0                	test   %eax,%eax
80104f6a:	79 07                	jns    80104f73 <argptr+0x2f>
    return -1;
80104f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f71:	eb 3b                	jmp    80104fae <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f77:	78 1f                	js     80104f98 <argptr+0x54>
80104f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7c:	8b 00                	mov    (%eax),%eax
80104f7e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f81:	39 d0                	cmp    %edx,%eax
80104f83:	76 13                	jbe    80104f98 <argptr+0x54>
80104f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f88:	89 c2                	mov    %eax,%edx
80104f8a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f8d:	01 c2                	add    %eax,%edx
80104f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f92:	8b 00                	mov    (%eax),%eax
80104f94:	39 c2                	cmp    %eax,%edx
80104f96:	76 07                	jbe    80104f9f <argptr+0x5b>
    return -1;
80104f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f9d:	eb 0f                	jmp    80104fae <argptr+0x6a>
  *pp = (char*)i;
80104f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa2:	89 c2                	mov    %eax,%edx
80104fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa7:	89 10                	mov    %edx,(%eax)
  return 0;
80104fa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fae:	c9                   	leave
80104faf:	c3                   	ret

80104fb0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104fb0:	f3 0f 1e fb          	endbr32
80104fb4:	55                   	push   %ebp
80104fb5:	89 e5                	mov    %esp,%ebp
80104fb7:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104fba:	83 ec 08             	sub    $0x8,%esp
80104fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fc0:	50                   	push   %eax
80104fc1:	ff 75 08             	push   0x8(%ebp)
80104fc4:	e8 4a ff ff ff       	call   80104f13 <argint>
80104fc9:	83 c4 10             	add    $0x10,%esp
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	79 07                	jns    80104fd7 <argstr+0x27>
    return -1;
80104fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd5:	eb 12                	jmp    80104fe9 <argstr+0x39>
  return fetchstr(addr, pp);
80104fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fda:	83 ec 08             	sub    $0x8,%esp
80104fdd:	ff 75 0c             	push   0xc(%ebp)
80104fe0:	50                   	push   %eax
80104fe1:	e8 c5 fe ff ff       	call   80104eab <fetchstr>
80104fe6:	83 c4 10             	add    $0x10,%esp
}
80104fe9:	c9                   	leave
80104fea:	c3                   	ret

80104feb <syscall>:
[SYS_thread_count] sys_thread_count,
};

void
syscall(void)
{
80104feb:	f3 0f 1e fb          	endbr32
80104fef:	55                   	push   %ebp
80104ff0:	89 e5                	mov    %esp,%ebp
80104ff2:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104ff5:	e8 af eb ff ff       	call   80103ba9 <myproc>
80104ffa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105000:	8b 40 18             	mov    0x18(%eax),%eax
80105003:	8b 40 1c             	mov    0x1c(%eax),%eax
80105006:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105009:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010500d:	7e 2f                	jle    8010503e <syscall+0x53>
8010500f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105012:	83 f8 17             	cmp    $0x17,%eax
80105015:	77 27                	ja     8010503e <syscall+0x53>
80105017:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105021:	85 c0                	test   %eax,%eax
80105023:	74 19                	je     8010503e <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105028:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010502f:	ff d0                	call   *%eax
80105031:	89 c2                	mov    %eax,%edx
80105033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105036:	8b 40 18             	mov    0x18(%eax),%eax
80105039:	89 50 1c             	mov    %edx,0x1c(%eax)
8010503c:	eb 2c                	jmp    8010506a <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010503e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105041:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	8b 40 10             	mov    0x10(%eax),%eax
8010504a:	ff 75 f0             	push   -0x10(%ebp)
8010504d:	52                   	push   %edx
8010504e:	50                   	push   %eax
8010504f:	68 58 a8 10 80       	push   $0x8010a858
80105054:	e8 b3 b3 ff ff       	call   8010040c <cprintf>
80105059:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010505c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505f:	8b 40 18             	mov    0x18(%eax),%eax
80105062:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105069:	90                   	nop
8010506a:	90                   	nop
8010506b:	c9                   	leave
8010506c:	c3                   	ret

8010506d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010506d:	f3 0f 1e fb          	endbr32
80105071:	55                   	push   %ebp
80105072:	89 e5                	mov    %esp,%ebp
80105074:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105077:	83 ec 08             	sub    $0x8,%esp
8010507a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010507d:	50                   	push   %eax
8010507e:	ff 75 08             	push   0x8(%ebp)
80105081:	e8 8d fe ff ff       	call   80104f13 <argint>
80105086:	83 c4 10             	add    $0x10,%esp
80105089:	85 c0                	test   %eax,%eax
8010508b:	79 07                	jns    80105094 <argfd+0x27>
    return -1;
8010508d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105092:	eb 4f                	jmp    801050e3 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105097:	85 c0                	test   %eax,%eax
80105099:	78 20                	js     801050bb <argfd+0x4e>
8010509b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509e:	83 f8 0f             	cmp    $0xf,%eax
801050a1:	7f 18                	jg     801050bb <argfd+0x4e>
801050a3:	e8 01 eb ff ff       	call   80103ba9 <myproc>
801050a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050ab:	83 c2 08             	add    $0x8,%edx
801050ae:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050b9:	75 07                	jne    801050c2 <argfd+0x55>
    return -1;
801050bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c0:	eb 21                	jmp    801050e3 <argfd+0x76>
  if(pfd)
801050c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050c6:	74 08                	je     801050d0 <argfd+0x63>
    *pfd = fd;
801050c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ce:	89 10                	mov    %edx,(%eax)
  if(pf)
801050d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050d4:	74 08                	je     801050de <argfd+0x71>
    *pf = f;
801050d6:	8b 45 10             	mov    0x10(%ebp),%eax
801050d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050dc:	89 10                	mov    %edx,(%eax)
  return 0;
801050de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050e3:	c9                   	leave
801050e4:	c3                   	ret

801050e5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801050e5:	f3 0f 1e fb          	endbr32
801050e9:	55                   	push   %ebp
801050ea:	89 e5                	mov    %esp,%ebp
801050ec:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801050ef:	e8 b5 ea ff ff       	call   80103ba9 <myproc>
801050f4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801050f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050fe:	eb 2a                	jmp    8010512a <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105103:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105106:	83 c2 08             	add    $0x8,%edx
80105109:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010510d:	85 c0                	test   %eax,%eax
8010510f:	75 15                	jne    80105126 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105114:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105117:	8d 4a 08             	lea    0x8(%edx),%ecx
8010511a:	8b 55 08             	mov    0x8(%ebp),%edx
8010511d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105124:	eb 0f                	jmp    80105135 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105126:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010512a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010512e:	7e d0                	jle    80105100 <fdalloc+0x1b>
    }
  }
  return -1;
80105130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105135:	c9                   	leave
80105136:	c3                   	ret

80105137 <sys_dup>:

int
sys_dup(void)
{
80105137:	f3 0f 1e fb          	endbr32
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105141:	83 ec 04             	sub    $0x4,%esp
80105144:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105147:	50                   	push   %eax
80105148:	6a 00                	push   $0x0
8010514a:	6a 00                	push   $0x0
8010514c:	e8 1c ff ff ff       	call   8010506d <argfd>
80105151:	83 c4 10             	add    $0x10,%esp
80105154:	85 c0                	test   %eax,%eax
80105156:	79 07                	jns    8010515f <sys_dup+0x28>
    return -1;
80105158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515d:	eb 31                	jmp    80105190 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010515f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105162:	83 ec 0c             	sub    $0xc,%esp
80105165:	50                   	push   %eax
80105166:	e8 7a ff ff ff       	call   801050e5 <fdalloc>
8010516b:	83 c4 10             	add    $0x10,%esp
8010516e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105171:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105175:	79 07                	jns    8010517e <sys_dup+0x47>
    return -1;
80105177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517c:	eb 12                	jmp    80105190 <sys_dup+0x59>
  filedup(f);
8010517e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105181:	83 ec 0c             	sub    $0xc,%esp
80105184:	50                   	push   %eax
80105185:	e8 0a bf ff ff       	call   80101094 <filedup>
8010518a:	83 c4 10             	add    $0x10,%esp
  return fd;
8010518d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105190:	c9                   	leave
80105191:	c3                   	ret

80105192 <sys_read>:

int
sys_read(void)
{
80105192:	f3 0f 1e fb          	endbr32
80105196:	55                   	push   %ebp
80105197:	89 e5                	mov    %esp,%ebp
80105199:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010519c:	83 ec 04             	sub    $0x4,%esp
8010519f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051a2:	50                   	push   %eax
801051a3:	6a 00                	push   $0x0
801051a5:	6a 00                	push   $0x0
801051a7:	e8 c1 fe ff ff       	call   8010506d <argfd>
801051ac:	83 c4 10             	add    $0x10,%esp
801051af:	85 c0                	test   %eax,%eax
801051b1:	78 2e                	js     801051e1 <sys_read+0x4f>
801051b3:	83 ec 08             	sub    $0x8,%esp
801051b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051b9:	50                   	push   %eax
801051ba:	6a 02                	push   $0x2
801051bc:	e8 52 fd ff ff       	call   80104f13 <argint>
801051c1:	83 c4 10             	add    $0x10,%esp
801051c4:	85 c0                	test   %eax,%eax
801051c6:	78 19                	js     801051e1 <sys_read+0x4f>
801051c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051cb:	83 ec 04             	sub    $0x4,%esp
801051ce:	50                   	push   %eax
801051cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051d2:	50                   	push   %eax
801051d3:	6a 01                	push   $0x1
801051d5:	e8 6a fd ff ff       	call   80104f44 <argptr>
801051da:	83 c4 10             	add    $0x10,%esp
801051dd:	85 c0                	test   %eax,%eax
801051df:	79 07                	jns    801051e8 <sys_read+0x56>
    return -1;
801051e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e6:	eb 17                	jmp    801051ff <sys_read+0x6d>
  return fileread(f, p, n);
801051e8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	83 ec 04             	sub    $0x4,%esp
801051f4:	51                   	push   %ecx
801051f5:	52                   	push   %edx
801051f6:	50                   	push   %eax
801051f7:	e8 34 c0 ff ff       	call   80101230 <fileread>
801051fc:	83 c4 10             	add    $0x10,%esp
}
801051ff:	c9                   	leave
80105200:	c3                   	ret

80105201 <sys_write>:

int
sys_write(void)
{
80105201:	f3 0f 1e fb          	endbr32
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
80105208:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010520b:	83 ec 04             	sub    $0x4,%esp
8010520e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105211:	50                   	push   %eax
80105212:	6a 00                	push   $0x0
80105214:	6a 00                	push   $0x0
80105216:	e8 52 fe ff ff       	call   8010506d <argfd>
8010521b:	83 c4 10             	add    $0x10,%esp
8010521e:	85 c0                	test   %eax,%eax
80105220:	78 2e                	js     80105250 <sys_write+0x4f>
80105222:	83 ec 08             	sub    $0x8,%esp
80105225:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105228:	50                   	push   %eax
80105229:	6a 02                	push   $0x2
8010522b:	e8 e3 fc ff ff       	call   80104f13 <argint>
80105230:	83 c4 10             	add    $0x10,%esp
80105233:	85 c0                	test   %eax,%eax
80105235:	78 19                	js     80105250 <sys_write+0x4f>
80105237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010523a:	83 ec 04             	sub    $0x4,%esp
8010523d:	50                   	push   %eax
8010523e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105241:	50                   	push   %eax
80105242:	6a 01                	push   $0x1
80105244:	e8 fb fc ff ff       	call   80104f44 <argptr>
80105249:	83 c4 10             	add    $0x10,%esp
8010524c:	85 c0                	test   %eax,%eax
8010524e:	79 07                	jns    80105257 <sys_write+0x56>
    return -1;
80105250:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105255:	eb 17                	jmp    8010526e <sys_write+0x6d>
  return filewrite(f, p, n);
80105257:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010525a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010525d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105260:	83 ec 04             	sub    $0x4,%esp
80105263:	51                   	push   %ecx
80105264:	52                   	push   %edx
80105265:	50                   	push   %eax
80105266:	e8 81 c0 ff ff       	call   801012ec <filewrite>
8010526b:	83 c4 10             	add    $0x10,%esp
}
8010526e:	c9                   	leave
8010526f:	c3                   	ret

80105270 <sys_close>:

int
sys_close(void)
{
80105270:	f3 0f 1e fb          	endbr32
80105274:	55                   	push   %ebp
80105275:	89 e5                	mov    %esp,%ebp
80105277:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010527a:	83 ec 04             	sub    $0x4,%esp
8010527d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105280:	50                   	push   %eax
80105281:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105284:	50                   	push   %eax
80105285:	6a 00                	push   $0x0
80105287:	e8 e1 fd ff ff       	call   8010506d <argfd>
8010528c:	83 c4 10             	add    $0x10,%esp
8010528f:	85 c0                	test   %eax,%eax
80105291:	79 07                	jns    8010529a <sys_close+0x2a>
    return -1;
80105293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105298:	eb 27                	jmp    801052c1 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
8010529a:	e8 0a e9 ff ff       	call   80103ba9 <myproc>
8010529f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a2:	83 c2 08             	add    $0x8,%edx
801052a5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801052ac:	00 
  fileclose(f);
801052ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b0:	83 ec 0c             	sub    $0xc,%esp
801052b3:	50                   	push   %eax
801052b4:	e8 30 be ff ff       	call   801010e9 <fileclose>
801052b9:	83 c4 10             	add    $0x10,%esp
  return 0;
801052bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052c1:	c9                   	leave
801052c2:	c3                   	ret

801052c3 <sys_fstat>:

int
sys_fstat(void)
{
801052c3:	f3 0f 1e fb          	endbr32
801052c7:	55                   	push   %ebp
801052c8:	89 e5                	mov    %esp,%ebp
801052ca:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801052cd:	83 ec 04             	sub    $0x4,%esp
801052d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052d3:	50                   	push   %eax
801052d4:	6a 00                	push   $0x0
801052d6:	6a 00                	push   $0x0
801052d8:	e8 90 fd ff ff       	call   8010506d <argfd>
801052dd:	83 c4 10             	add    $0x10,%esp
801052e0:	85 c0                	test   %eax,%eax
801052e2:	78 17                	js     801052fb <sys_fstat+0x38>
801052e4:	83 ec 04             	sub    $0x4,%esp
801052e7:	6a 14                	push   $0x14
801052e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052ec:	50                   	push   %eax
801052ed:	6a 01                	push   $0x1
801052ef:	e8 50 fc ff ff       	call   80104f44 <argptr>
801052f4:	83 c4 10             	add    $0x10,%esp
801052f7:	85 c0                	test   %eax,%eax
801052f9:	79 07                	jns    80105302 <sys_fstat+0x3f>
    return -1;
801052fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105300:	eb 13                	jmp    80105315 <sys_fstat+0x52>
  return filestat(f, st);
80105302:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105308:	83 ec 08             	sub    $0x8,%esp
8010530b:	52                   	push   %edx
8010530c:	50                   	push   %eax
8010530d:	e8 c3 be ff ff       	call   801011d5 <filestat>
80105312:	83 c4 10             	add    $0x10,%esp
}
80105315:	c9                   	leave
80105316:	c3                   	ret

80105317 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105317:	f3 0f 1e fb          	endbr32
8010531b:	55                   	push   %ebp
8010531c:	89 e5                	mov    %esp,%ebp
8010531e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105321:	83 ec 08             	sub    $0x8,%esp
80105324:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105327:	50                   	push   %eax
80105328:	6a 00                	push   $0x0
8010532a:	e8 81 fc ff ff       	call   80104fb0 <argstr>
8010532f:	83 c4 10             	add    $0x10,%esp
80105332:	85 c0                	test   %eax,%eax
80105334:	78 15                	js     8010534b <sys_link+0x34>
80105336:	83 ec 08             	sub    $0x8,%esp
80105339:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010533c:	50                   	push   %eax
8010533d:	6a 01                	push   $0x1
8010533f:	e8 6c fc ff ff       	call   80104fb0 <argstr>
80105344:	83 c4 10             	add    $0x10,%esp
80105347:	85 c0                	test   %eax,%eax
80105349:	79 0a                	jns    80105355 <sys_link+0x3e>
    return -1;
8010534b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105350:	e9 68 01 00 00       	jmp    801054bd <sys_link+0x1a6>

  begin_op();
80105355:	e8 17 de ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
8010535a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	50                   	push   %eax
80105361:	e8 81 d2 ff ff       	call   801025e7 <namei>
80105366:	83 c4 10             	add    $0x10,%esp
80105369:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010536c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105370:	75 0f                	jne    80105381 <sys_link+0x6a>
    end_op();
80105372:	e8 8a de ff ff       	call   80103201 <end_op>
    return -1;
80105377:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537c:	e9 3c 01 00 00       	jmp    801054bd <sys_link+0x1a6>
  }

  ilock(ip);
80105381:	83 ec 0c             	sub    $0xc,%esp
80105384:	ff 75 f4             	push   -0xc(%ebp)
80105387:	e8 f0 c6 ff ff       	call   80101a7c <ilock>
8010538c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010538f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105392:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105396:	66 83 f8 01          	cmp    $0x1,%ax
8010539a:	75 1d                	jne    801053b9 <sys_link+0xa2>
    iunlockput(ip);
8010539c:	83 ec 0c             	sub    $0xc,%esp
8010539f:	ff 75 f4             	push   -0xc(%ebp)
801053a2:	e8 12 c9 ff ff       	call   80101cb9 <iunlockput>
801053a7:	83 c4 10             	add    $0x10,%esp
    end_op();
801053aa:	e8 52 de ff ff       	call   80103201 <end_op>
    return -1;
801053af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b4:	e9 04 01 00 00       	jmp    801054bd <sys_link+0x1a6>
  }

  ip->nlink++;
801053b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053bc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053c0:	83 c0 01             	add    $0x1,%eax
801053c3:	89 c2                	mov    %eax,%edx
801053c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801053cc:	83 ec 0c             	sub    $0xc,%esp
801053cf:	ff 75 f4             	push   -0xc(%ebp)
801053d2:	e8 bc c4 ff ff       	call   80101893 <iupdate>
801053d7:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801053da:	83 ec 0c             	sub    $0xc,%esp
801053dd:	ff 75 f4             	push   -0xc(%ebp)
801053e0:	e8 ae c7 ff ff       	call   80101b93 <iunlock>
801053e5:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801053e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801053eb:	83 ec 08             	sub    $0x8,%esp
801053ee:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801053f1:	52                   	push   %edx
801053f2:	50                   	push   %eax
801053f3:	e8 0f d2 ff ff       	call   80102607 <nameiparent>
801053f8:	83 c4 10             	add    $0x10,%esp
801053fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105402:	74 71                	je     80105475 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105404:	83 ec 0c             	sub    $0xc,%esp
80105407:	ff 75 f0             	push   -0x10(%ebp)
8010540a:	e8 6d c6 ff ff       	call   80101a7c <ilock>
8010540f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105415:	8b 10                	mov    (%eax),%edx
80105417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541a:	8b 00                	mov    (%eax),%eax
8010541c:	39 c2                	cmp    %eax,%edx
8010541e:	75 1d                	jne    8010543d <sys_link+0x126>
80105420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105423:	8b 40 04             	mov    0x4(%eax),%eax
80105426:	83 ec 04             	sub    $0x4,%esp
80105429:	50                   	push   %eax
8010542a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010542d:	50                   	push   %eax
8010542e:	ff 75 f0             	push   -0x10(%ebp)
80105431:	e8 0e cf ff ff       	call   80102344 <dirlink>
80105436:	83 c4 10             	add    $0x10,%esp
80105439:	85 c0                	test   %eax,%eax
8010543b:	79 10                	jns    8010544d <sys_link+0x136>
    iunlockput(dp);
8010543d:	83 ec 0c             	sub    $0xc,%esp
80105440:	ff 75 f0             	push   -0x10(%ebp)
80105443:	e8 71 c8 ff ff       	call   80101cb9 <iunlockput>
80105448:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010544b:	eb 29                	jmp    80105476 <sys_link+0x15f>
  }
  iunlockput(dp);
8010544d:	83 ec 0c             	sub    $0xc,%esp
80105450:	ff 75 f0             	push   -0x10(%ebp)
80105453:	e8 61 c8 ff ff       	call   80101cb9 <iunlockput>
80105458:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010545b:	83 ec 0c             	sub    $0xc,%esp
8010545e:	ff 75 f4             	push   -0xc(%ebp)
80105461:	e8 7f c7 ff ff       	call   80101be5 <iput>
80105466:	83 c4 10             	add    $0x10,%esp

  end_op();
80105469:	e8 93 dd ff ff       	call   80103201 <end_op>

  return 0;
8010546e:	b8 00 00 00 00       	mov    $0x0,%eax
80105473:	eb 48                	jmp    801054bd <sys_link+0x1a6>
    goto bad;
80105475:	90                   	nop

bad:
  ilock(ip);
80105476:	83 ec 0c             	sub    $0xc,%esp
80105479:	ff 75 f4             	push   -0xc(%ebp)
8010547c:	e8 fb c5 ff ff       	call   80101a7c <ilock>
80105481:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105487:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010548b:	83 e8 01             	sub    $0x1,%eax
8010548e:	89 c2                	mov    %eax,%edx
80105490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105493:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105497:	83 ec 0c             	sub    $0xc,%esp
8010549a:	ff 75 f4             	push   -0xc(%ebp)
8010549d:	e8 f1 c3 ff ff       	call   80101893 <iupdate>
801054a2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801054a5:	83 ec 0c             	sub    $0xc,%esp
801054a8:	ff 75 f4             	push   -0xc(%ebp)
801054ab:	e8 09 c8 ff ff       	call   80101cb9 <iunlockput>
801054b0:	83 c4 10             	add    $0x10,%esp
  end_op();
801054b3:	e8 49 dd ff ff       	call   80103201 <end_op>
  return -1;
801054b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054bd:	c9                   	leave
801054be:	c3                   	ret

801054bf <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801054bf:	f3 0f 1e fb          	endbr32
801054c3:	55                   	push   %ebp
801054c4:	89 e5                	mov    %esp,%ebp
801054c6:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054c9:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801054d0:	eb 40                	jmp    80105512 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d5:	6a 10                	push   $0x10
801054d7:	50                   	push   %eax
801054d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801054db:	50                   	push   %eax
801054dc:	ff 75 08             	push   0x8(%ebp)
801054df:	e8 a0 ca ff ff       	call   80101f84 <readi>
801054e4:	83 c4 10             	add    $0x10,%esp
801054e7:	83 f8 10             	cmp    $0x10,%eax
801054ea:	74 0d                	je     801054f9 <isdirempty+0x3a>
      panic("isdirempty: readi");
801054ec:	83 ec 0c             	sub    $0xc,%esp
801054ef:	68 74 a8 10 80       	push   $0x8010a874
801054f4:	e8 cc b0 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
801054f9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801054fd:	66 85 c0             	test   %ax,%ax
80105500:	74 07                	je     80105509 <isdirempty+0x4a>
      return 0;
80105502:	b8 00 00 00 00       	mov    $0x0,%eax
80105507:	eb 1b                	jmp    80105524 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550c:	83 c0 10             	add    $0x10,%eax
8010550f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105512:	8b 45 08             	mov    0x8(%ebp),%eax
80105515:	8b 50 58             	mov    0x58(%eax),%edx
80105518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551b:	39 c2                	cmp    %eax,%edx
8010551d:	77 b3                	ja     801054d2 <isdirempty+0x13>
  }
  return 1;
8010551f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105524:	c9                   	leave
80105525:	c3                   	ret

80105526 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105526:	f3 0f 1e fb          	endbr32
8010552a:	55                   	push   %ebp
8010552b:	89 e5                	mov    %esp,%ebp
8010552d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105530:	83 ec 08             	sub    $0x8,%esp
80105533:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105536:	50                   	push   %eax
80105537:	6a 00                	push   $0x0
80105539:	e8 72 fa ff ff       	call   80104fb0 <argstr>
8010553e:	83 c4 10             	add    $0x10,%esp
80105541:	85 c0                	test   %eax,%eax
80105543:	79 0a                	jns    8010554f <sys_unlink+0x29>
    return -1;
80105545:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554a:	e9 bf 01 00 00       	jmp    8010570e <sys_unlink+0x1e8>

  begin_op();
8010554f:	e8 1d dc ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105554:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105557:	83 ec 08             	sub    $0x8,%esp
8010555a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010555d:	52                   	push   %edx
8010555e:	50                   	push   %eax
8010555f:	e8 a3 d0 ff ff       	call   80102607 <nameiparent>
80105564:	83 c4 10             	add    $0x10,%esp
80105567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010556a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010556e:	75 0f                	jne    8010557f <sys_unlink+0x59>
    end_op();
80105570:	e8 8c dc ff ff       	call   80103201 <end_op>
    return -1;
80105575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010557a:	e9 8f 01 00 00       	jmp    8010570e <sys_unlink+0x1e8>
  }

  ilock(dp);
8010557f:	83 ec 0c             	sub    $0xc,%esp
80105582:	ff 75 f4             	push   -0xc(%ebp)
80105585:	e8 f2 c4 ff ff       	call   80101a7c <ilock>
8010558a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010558d:	83 ec 08             	sub    $0x8,%esp
80105590:	68 86 a8 10 80       	push   $0x8010a886
80105595:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105598:	50                   	push   %eax
80105599:	e8 c9 cc ff ff       	call   80102267 <namecmp>
8010559e:	83 c4 10             	add    $0x10,%esp
801055a1:	85 c0                	test   %eax,%eax
801055a3:	0f 84 49 01 00 00    	je     801056f2 <sys_unlink+0x1cc>
801055a9:	83 ec 08             	sub    $0x8,%esp
801055ac:	68 88 a8 10 80       	push   $0x8010a888
801055b1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801055b4:	50                   	push   %eax
801055b5:	e8 ad cc ff ff       	call   80102267 <namecmp>
801055ba:	83 c4 10             	add    $0x10,%esp
801055bd:	85 c0                	test   %eax,%eax
801055bf:	0f 84 2d 01 00 00    	je     801056f2 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801055c5:	83 ec 04             	sub    $0x4,%esp
801055c8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801055cb:	50                   	push   %eax
801055cc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801055cf:	50                   	push   %eax
801055d0:	ff 75 f4             	push   -0xc(%ebp)
801055d3:	e8 ae cc ff ff       	call   80102286 <dirlookup>
801055d8:	83 c4 10             	add    $0x10,%esp
801055db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055e2:	0f 84 0d 01 00 00    	je     801056f5 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
801055e8:	83 ec 0c             	sub    $0xc,%esp
801055eb:	ff 75 f0             	push   -0x10(%ebp)
801055ee:	e8 89 c4 ff ff       	call   80101a7c <ilock>
801055f3:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801055f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055fd:	66 85 c0             	test   %ax,%ax
80105600:	7f 0d                	jg     8010560f <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105602:	83 ec 0c             	sub    $0xc,%esp
80105605:	68 8b a8 10 80       	push   $0x8010a88b
8010560a:	e8 b6 af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010560f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105612:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105616:	66 83 f8 01          	cmp    $0x1,%ax
8010561a:	75 25                	jne    80105641 <sys_unlink+0x11b>
8010561c:	83 ec 0c             	sub    $0xc,%esp
8010561f:	ff 75 f0             	push   -0x10(%ebp)
80105622:	e8 98 fe ff ff       	call   801054bf <isdirempty>
80105627:	83 c4 10             	add    $0x10,%esp
8010562a:	85 c0                	test   %eax,%eax
8010562c:	75 13                	jne    80105641 <sys_unlink+0x11b>
    iunlockput(ip);
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	ff 75 f0             	push   -0x10(%ebp)
80105634:	e8 80 c6 ff ff       	call   80101cb9 <iunlockput>
80105639:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010563c:	e9 b5 00 00 00       	jmp    801056f6 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105641:	83 ec 04             	sub    $0x4,%esp
80105644:	6a 10                	push   $0x10
80105646:	6a 00                	push   $0x0
80105648:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010564b:	50                   	push   %eax
8010564c:	e8 6e f5 ff ff       	call   80104bbf <memset>
80105651:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105654:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105657:	6a 10                	push   $0x10
80105659:	50                   	push   %eax
8010565a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010565d:	50                   	push   %eax
8010565e:	ff 75 f4             	push   -0xc(%ebp)
80105661:	e8 77 ca ff ff       	call   801020dd <writei>
80105666:	83 c4 10             	add    $0x10,%esp
80105669:	83 f8 10             	cmp    $0x10,%eax
8010566c:	74 0d                	je     8010567b <sys_unlink+0x155>
    panic("unlink: writei");
8010566e:	83 ec 0c             	sub    $0xc,%esp
80105671:	68 9d a8 10 80       	push   $0x8010a89d
80105676:	e8 4a af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
8010567b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105682:	66 83 f8 01          	cmp    $0x1,%ax
80105686:	75 21                	jne    801056a9 <sys_unlink+0x183>
    dp->nlink--;
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010568f:	83 e8 01             	sub    $0x1,%eax
80105692:	89 c2                	mov    %eax,%edx
80105694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105697:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010569b:	83 ec 0c             	sub    $0xc,%esp
8010569e:	ff 75 f4             	push   -0xc(%ebp)
801056a1:	e8 ed c1 ff ff       	call   80101893 <iupdate>
801056a6:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801056a9:	83 ec 0c             	sub    $0xc,%esp
801056ac:	ff 75 f4             	push   -0xc(%ebp)
801056af:	e8 05 c6 ff ff       	call   80101cb9 <iunlockput>
801056b4:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801056b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ba:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056be:	83 e8 01             	sub    $0x1,%eax
801056c1:	89 c2                	mov    %eax,%edx
801056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056ca:	83 ec 0c             	sub    $0xc,%esp
801056cd:	ff 75 f0             	push   -0x10(%ebp)
801056d0:	e8 be c1 ff ff       	call   80101893 <iupdate>
801056d5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056d8:	83 ec 0c             	sub    $0xc,%esp
801056db:	ff 75 f0             	push   -0x10(%ebp)
801056de:	e8 d6 c5 ff ff       	call   80101cb9 <iunlockput>
801056e3:	83 c4 10             	add    $0x10,%esp

  end_op();
801056e6:	e8 16 db ff ff       	call   80103201 <end_op>

  return 0;
801056eb:	b8 00 00 00 00       	mov    $0x0,%eax
801056f0:	eb 1c                	jmp    8010570e <sys_unlink+0x1e8>
    goto bad;
801056f2:	90                   	nop
801056f3:	eb 01                	jmp    801056f6 <sys_unlink+0x1d0>
    goto bad;
801056f5:	90                   	nop

bad:
  iunlockput(dp);
801056f6:	83 ec 0c             	sub    $0xc,%esp
801056f9:	ff 75 f4             	push   -0xc(%ebp)
801056fc:	e8 b8 c5 ff ff       	call   80101cb9 <iunlockput>
80105701:	83 c4 10             	add    $0x10,%esp
  end_op();
80105704:	e8 f8 da ff ff       	call   80103201 <end_op>
  return -1;
80105709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010570e:	c9                   	leave
8010570f:	c3                   	ret

80105710 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105710:	f3 0f 1e fb          	endbr32
80105714:	55                   	push   %ebp
80105715:	89 e5                	mov    %esp,%ebp
80105717:	83 ec 38             	sub    $0x38,%esp
8010571a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010571d:	8b 55 10             	mov    0x10(%ebp),%edx
80105720:	8b 45 14             	mov    0x14(%ebp),%eax
80105723:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105727:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010572b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010572f:	83 ec 08             	sub    $0x8,%esp
80105732:	8d 45 de             	lea    -0x22(%ebp),%eax
80105735:	50                   	push   %eax
80105736:	ff 75 08             	push   0x8(%ebp)
80105739:	e8 c9 ce ff ff       	call   80102607 <nameiparent>
8010573e:	83 c4 10             	add    $0x10,%esp
80105741:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105748:	75 0a                	jne    80105754 <create+0x44>
    return 0;
8010574a:	b8 00 00 00 00       	mov    $0x0,%eax
8010574f:	e9 90 01 00 00       	jmp    801058e4 <create+0x1d4>
  ilock(dp);
80105754:	83 ec 0c             	sub    $0xc,%esp
80105757:	ff 75 f4             	push   -0xc(%ebp)
8010575a:	e8 1d c3 ff ff       	call   80101a7c <ilock>
8010575f:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105762:	83 ec 04             	sub    $0x4,%esp
80105765:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105768:	50                   	push   %eax
80105769:	8d 45 de             	lea    -0x22(%ebp),%eax
8010576c:	50                   	push   %eax
8010576d:	ff 75 f4             	push   -0xc(%ebp)
80105770:	e8 11 cb ff ff       	call   80102286 <dirlookup>
80105775:	83 c4 10             	add    $0x10,%esp
80105778:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010577b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010577f:	74 50                	je     801057d1 <create+0xc1>
    iunlockput(dp);
80105781:	83 ec 0c             	sub    $0xc,%esp
80105784:	ff 75 f4             	push   -0xc(%ebp)
80105787:	e8 2d c5 ff ff       	call   80101cb9 <iunlockput>
8010578c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010578f:	83 ec 0c             	sub    $0xc,%esp
80105792:	ff 75 f0             	push   -0x10(%ebp)
80105795:	e8 e2 c2 ff ff       	call   80101a7c <ilock>
8010579a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010579d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801057a2:	75 15                	jne    801057b9 <create+0xa9>
801057a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057ab:	66 83 f8 02          	cmp    $0x2,%ax
801057af:	75 08                	jne    801057b9 <create+0xa9>
      return ip;
801057b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b4:	e9 2b 01 00 00       	jmp    801058e4 <create+0x1d4>
    iunlockput(ip);
801057b9:	83 ec 0c             	sub    $0xc,%esp
801057bc:	ff 75 f0             	push   -0x10(%ebp)
801057bf:	e8 f5 c4 ff ff       	call   80101cb9 <iunlockput>
801057c4:	83 c4 10             	add    $0x10,%esp
    return 0;
801057c7:	b8 00 00 00 00       	mov    $0x0,%eax
801057cc:	e9 13 01 00 00       	jmp    801058e4 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801057d1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801057d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d8:	8b 00                	mov    (%eax),%eax
801057da:	83 ec 08             	sub    $0x8,%esp
801057dd:	52                   	push   %edx
801057de:	50                   	push   %eax
801057df:	e8 d4 bf ff ff       	call   801017b8 <ialloc>
801057e4:	83 c4 10             	add    $0x10,%esp
801057e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057ee:	75 0d                	jne    801057fd <create+0xed>
    panic("create: ialloc");
801057f0:	83 ec 0c             	sub    $0xc,%esp
801057f3:	68 ac a8 10 80       	push   $0x8010a8ac
801057f8:	e8 c8 ad ff ff       	call   801005c5 <panic>

  ilock(ip);
801057fd:	83 ec 0c             	sub    $0xc,%esp
80105800:	ff 75 f0             	push   -0x10(%ebp)
80105803:	e8 74 c2 ff ff       	call   80101a7c <ilock>
80105808:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105812:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105816:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105819:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010581d:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105824:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010582a:	83 ec 0c             	sub    $0xc,%esp
8010582d:	ff 75 f0             	push   -0x10(%ebp)
80105830:	e8 5e c0 ff ff       	call   80101893 <iupdate>
80105835:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105838:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010583d:	75 6a                	jne    801058a9 <create+0x199>
    dp->nlink++;  // for ".."
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105842:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105846:	83 c0 01             	add    $0x1,%eax
80105849:	89 c2                	mov    %eax,%edx
8010584b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105852:	83 ec 0c             	sub    $0xc,%esp
80105855:	ff 75 f4             	push   -0xc(%ebp)
80105858:	e8 36 c0 ff ff       	call   80101893 <iupdate>
8010585d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	8b 40 04             	mov    0x4(%eax),%eax
80105866:	83 ec 04             	sub    $0x4,%esp
80105869:	50                   	push   %eax
8010586a:	68 86 a8 10 80       	push   $0x8010a886
8010586f:	ff 75 f0             	push   -0x10(%ebp)
80105872:	e8 cd ca ff ff       	call   80102344 <dirlink>
80105877:	83 c4 10             	add    $0x10,%esp
8010587a:	85 c0                	test   %eax,%eax
8010587c:	78 1e                	js     8010589c <create+0x18c>
8010587e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105881:	8b 40 04             	mov    0x4(%eax),%eax
80105884:	83 ec 04             	sub    $0x4,%esp
80105887:	50                   	push   %eax
80105888:	68 88 a8 10 80       	push   $0x8010a888
8010588d:	ff 75 f0             	push   -0x10(%ebp)
80105890:	e8 af ca ff ff       	call   80102344 <dirlink>
80105895:	83 c4 10             	add    $0x10,%esp
80105898:	85 c0                	test   %eax,%eax
8010589a:	79 0d                	jns    801058a9 <create+0x199>
      panic("create dots");
8010589c:	83 ec 0c             	sub    $0xc,%esp
8010589f:	68 bb a8 10 80       	push   $0x8010a8bb
801058a4:	e8 1c ad ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801058a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ac:	8b 40 04             	mov    0x4(%eax),%eax
801058af:	83 ec 04             	sub    $0x4,%esp
801058b2:	50                   	push   %eax
801058b3:	8d 45 de             	lea    -0x22(%ebp),%eax
801058b6:	50                   	push   %eax
801058b7:	ff 75 f4             	push   -0xc(%ebp)
801058ba:	e8 85 ca ff ff       	call   80102344 <dirlink>
801058bf:	83 c4 10             	add    $0x10,%esp
801058c2:	85 c0                	test   %eax,%eax
801058c4:	79 0d                	jns    801058d3 <create+0x1c3>
    panic("create: dirlink");
801058c6:	83 ec 0c             	sub    $0xc,%esp
801058c9:	68 c7 a8 10 80       	push   $0x8010a8c7
801058ce:	e8 f2 ac ff ff       	call   801005c5 <panic>

  iunlockput(dp);
801058d3:	83 ec 0c             	sub    $0xc,%esp
801058d6:	ff 75 f4             	push   -0xc(%ebp)
801058d9:	e8 db c3 ff ff       	call   80101cb9 <iunlockput>
801058de:	83 c4 10             	add    $0x10,%esp

  return ip;
801058e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801058e4:	c9                   	leave
801058e5:	c3                   	ret

801058e6 <sys_open>:

int
sys_open(void)
{
801058e6:	f3 0f 1e fb          	endbr32
801058ea:	55                   	push   %ebp
801058eb:	89 e5                	mov    %esp,%ebp
801058ed:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801058f0:	83 ec 08             	sub    $0x8,%esp
801058f3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801058f6:	50                   	push   %eax
801058f7:	6a 00                	push   $0x0
801058f9:	e8 b2 f6 ff ff       	call   80104fb0 <argstr>
801058fe:	83 c4 10             	add    $0x10,%esp
80105901:	85 c0                	test   %eax,%eax
80105903:	78 15                	js     8010591a <sys_open+0x34>
80105905:	83 ec 08             	sub    $0x8,%esp
80105908:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010590b:	50                   	push   %eax
8010590c:	6a 01                	push   $0x1
8010590e:	e8 00 f6 ff ff       	call   80104f13 <argint>
80105913:	83 c4 10             	add    $0x10,%esp
80105916:	85 c0                	test   %eax,%eax
80105918:	79 0a                	jns    80105924 <sys_open+0x3e>
    return -1;
8010591a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591f:	e9 61 01 00 00       	jmp    80105a85 <sys_open+0x19f>

  begin_op();
80105924:	e8 48 d8 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80105929:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010592c:	25 00 02 00 00       	and    $0x200,%eax
80105931:	85 c0                	test   %eax,%eax
80105933:	74 2a                	je     8010595f <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105935:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105938:	6a 00                	push   $0x0
8010593a:	6a 00                	push   $0x0
8010593c:	6a 02                	push   $0x2
8010593e:	50                   	push   %eax
8010593f:	e8 cc fd ff ff       	call   80105710 <create>
80105944:	83 c4 10             	add    $0x10,%esp
80105947:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010594a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010594e:	75 75                	jne    801059c5 <sys_open+0xdf>
      end_op();
80105950:	e8 ac d8 ff ff       	call   80103201 <end_op>
      return -1;
80105955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595a:	e9 26 01 00 00       	jmp    80105a85 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
8010595f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105962:	83 ec 0c             	sub    $0xc,%esp
80105965:	50                   	push   %eax
80105966:	e8 7c cc ff ff       	call   801025e7 <namei>
8010596b:	83 c4 10             	add    $0x10,%esp
8010596e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105971:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105975:	75 0f                	jne    80105986 <sys_open+0xa0>
      end_op();
80105977:	e8 85 d8 ff ff       	call   80103201 <end_op>
      return -1;
8010597c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105981:	e9 ff 00 00 00       	jmp    80105a85 <sys_open+0x19f>
    }
    ilock(ip);
80105986:	83 ec 0c             	sub    $0xc,%esp
80105989:	ff 75 f4             	push   -0xc(%ebp)
8010598c:	e8 eb c0 ff ff       	call   80101a7c <ilock>
80105991:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105997:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010599b:	66 83 f8 01          	cmp    $0x1,%ax
8010599f:	75 24                	jne    801059c5 <sys_open+0xdf>
801059a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059a4:	85 c0                	test   %eax,%eax
801059a6:	74 1d                	je     801059c5 <sys_open+0xdf>
      iunlockput(ip);
801059a8:	83 ec 0c             	sub    $0xc,%esp
801059ab:	ff 75 f4             	push   -0xc(%ebp)
801059ae:	e8 06 c3 ff ff       	call   80101cb9 <iunlockput>
801059b3:	83 c4 10             	add    $0x10,%esp
      end_op();
801059b6:	e8 46 d8 ff ff       	call   80103201 <end_op>
      return -1;
801059bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c0:	e9 c0 00 00 00       	jmp    80105a85 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801059c5:	e8 59 b6 ff ff       	call   80101023 <filealloc>
801059ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d1:	74 17                	je     801059ea <sys_open+0x104>
801059d3:	83 ec 0c             	sub    $0xc,%esp
801059d6:	ff 75 f0             	push   -0x10(%ebp)
801059d9:	e8 07 f7 ff ff       	call   801050e5 <fdalloc>
801059de:	83 c4 10             	add    $0x10,%esp
801059e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801059e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801059e8:	79 2e                	jns    80105a18 <sys_open+0x132>
    if(f)
801059ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059ee:	74 0e                	je     801059fe <sys_open+0x118>
      fileclose(f);
801059f0:	83 ec 0c             	sub    $0xc,%esp
801059f3:	ff 75 f0             	push   -0x10(%ebp)
801059f6:	e8 ee b6 ff ff       	call   801010e9 <fileclose>
801059fb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801059fe:	83 ec 0c             	sub    $0xc,%esp
80105a01:	ff 75 f4             	push   -0xc(%ebp)
80105a04:	e8 b0 c2 ff ff       	call   80101cb9 <iunlockput>
80105a09:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a0c:	e8 f0 d7 ff ff       	call   80103201 <end_op>
    return -1;
80105a11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a16:	eb 6d                	jmp    80105a85 <sys_open+0x19f>
  }
  iunlock(ip);
80105a18:	83 ec 0c             	sub    $0xc,%esp
80105a1b:	ff 75 f4             	push   -0xc(%ebp)
80105a1e:	e8 70 c1 ff ff       	call   80101b93 <iunlock>
80105a23:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a26:	e8 d6 d7 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80105a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a3a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a40:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105a47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a4a:	83 e0 01             	and    $0x1,%eax
80105a4d:	85 c0                	test   %eax,%eax
80105a4f:	0f 94 c0             	sete   %al
80105a52:	89 c2                	mov    %eax,%edx
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a5d:	83 e0 01             	and    $0x1,%eax
80105a60:	85 c0                	test   %eax,%eax
80105a62:	75 0a                	jne    80105a6e <sys_open+0x188>
80105a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a67:	83 e0 02             	and    $0x2,%eax
80105a6a:	85 c0                	test   %eax,%eax
80105a6c:	74 07                	je     80105a75 <sys_open+0x18f>
80105a6e:	b8 01 00 00 00       	mov    $0x1,%eax
80105a73:	eb 05                	jmp    80105a7a <sys_open+0x194>
80105a75:	b8 00 00 00 00       	mov    $0x0,%eax
80105a7a:	89 c2                	mov    %eax,%edx
80105a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a82:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a85:	c9                   	leave
80105a86:	c3                   	ret

80105a87 <sys_mkdir>:

int
sys_mkdir(void)
{
80105a87:	f3 0f 1e fb          	endbr32
80105a8b:	55                   	push   %ebp
80105a8c:	89 e5                	mov    %esp,%ebp
80105a8e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a91:	e8 db d6 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a96:	83 ec 08             	sub    $0x8,%esp
80105a99:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a9c:	50                   	push   %eax
80105a9d:	6a 00                	push   $0x0
80105a9f:	e8 0c f5 ff ff       	call   80104fb0 <argstr>
80105aa4:	83 c4 10             	add    $0x10,%esp
80105aa7:	85 c0                	test   %eax,%eax
80105aa9:	78 1b                	js     80105ac6 <sys_mkdir+0x3f>
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	6a 00                	push   $0x0
80105ab0:	6a 00                	push   $0x0
80105ab2:	6a 01                	push   $0x1
80105ab4:	50                   	push   %eax
80105ab5:	e8 56 fc ff ff       	call   80105710 <create>
80105aba:	83 c4 10             	add    $0x10,%esp
80105abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ac0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac4:	75 0c                	jne    80105ad2 <sys_mkdir+0x4b>
    end_op();
80105ac6:	e8 36 d7 ff ff       	call   80103201 <end_op>
    return -1;
80105acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad0:	eb 18                	jmp    80105aea <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105ad2:	83 ec 0c             	sub    $0xc,%esp
80105ad5:	ff 75 f4             	push   -0xc(%ebp)
80105ad8:	e8 dc c1 ff ff       	call   80101cb9 <iunlockput>
80105add:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ae0:	e8 1c d7 ff ff       	call   80103201 <end_op>
  return 0;
80105ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aea:	c9                   	leave
80105aeb:	c3                   	ret

80105aec <sys_mknod>:

int
sys_mknod(void)
{
80105aec:	f3 0f 1e fb          	endbr32
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105af6:	e8 76 d6 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105afb:	83 ec 08             	sub    $0x8,%esp
80105afe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b01:	50                   	push   %eax
80105b02:	6a 00                	push   $0x0
80105b04:	e8 a7 f4 ff ff       	call   80104fb0 <argstr>
80105b09:	83 c4 10             	add    $0x10,%esp
80105b0c:	85 c0                	test   %eax,%eax
80105b0e:	78 4f                	js     80105b5f <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105b10:	83 ec 08             	sub    $0x8,%esp
80105b13:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b16:	50                   	push   %eax
80105b17:	6a 01                	push   $0x1
80105b19:	e8 f5 f3 ff ff       	call   80104f13 <argint>
80105b1e:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105b21:	85 c0                	test   %eax,%eax
80105b23:	78 3a                	js     80105b5f <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105b25:	83 ec 08             	sub    $0x8,%esp
80105b28:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b2b:	50                   	push   %eax
80105b2c:	6a 02                	push   $0x2
80105b2e:	e8 e0 f3 ff ff       	call   80104f13 <argint>
80105b33:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105b36:	85 c0                	test   %eax,%eax
80105b38:	78 25                	js     80105b5f <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105b3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b3d:	0f bf c8             	movswl %ax,%ecx
80105b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b43:	0f bf d0             	movswl %ax,%edx
80105b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b49:	51                   	push   %ecx
80105b4a:	52                   	push   %edx
80105b4b:	6a 03                	push   $0x3
80105b4d:	50                   	push   %eax
80105b4e:	e8 bd fb ff ff       	call   80105710 <create>
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105b59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b5d:	75 0c                	jne    80105b6b <sys_mknod+0x7f>
    end_op();
80105b5f:	e8 9d d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 18                	jmp    80105b83 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105b6b:	83 ec 0c             	sub    $0xc,%esp
80105b6e:	ff 75 f4             	push   -0xc(%ebp)
80105b71:	e8 43 c1 ff ff       	call   80101cb9 <iunlockput>
80105b76:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b79:	e8 83 d6 ff ff       	call   80103201 <end_op>
  return 0;
80105b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b83:	c9                   	leave
80105b84:	c3                   	ret

80105b85 <sys_chdir>:

int
sys_chdir(void)
{
80105b85:	f3 0f 1e fb          	endbr32
80105b89:	55                   	push   %ebp
80105b8a:	89 e5                	mov    %esp,%ebp
80105b8c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b8f:	e8 15 e0 ff ff       	call   80103ba9 <myproc>
80105b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b97:	e8 d5 d5 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b9c:	83 ec 08             	sub    $0x8,%esp
80105b9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ba2:	50                   	push   %eax
80105ba3:	6a 00                	push   $0x0
80105ba5:	e8 06 f4 ff ff       	call   80104fb0 <argstr>
80105baa:	83 c4 10             	add    $0x10,%esp
80105bad:	85 c0                	test   %eax,%eax
80105baf:	78 18                	js     80105bc9 <sys_chdir+0x44>
80105bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105bb4:	83 ec 0c             	sub    $0xc,%esp
80105bb7:	50                   	push   %eax
80105bb8:	e8 2a ca ff ff       	call   801025e7 <namei>
80105bbd:	83 c4 10             	add    $0x10,%esp
80105bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bc7:	75 0c                	jne    80105bd5 <sys_chdir+0x50>
    end_op();
80105bc9:	e8 33 d6 ff ff       	call   80103201 <end_op>
    return -1;
80105bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd3:	eb 68                	jmp    80105c3d <sys_chdir+0xb8>
  }
  ilock(ip);
80105bd5:	83 ec 0c             	sub    $0xc,%esp
80105bd8:	ff 75 f0             	push   -0x10(%ebp)
80105bdb:	e8 9c be ff ff       	call   80101a7c <ilock>
80105be0:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bea:	66 83 f8 01          	cmp    $0x1,%ax
80105bee:	74 1a                	je     80105c0a <sys_chdir+0x85>
    iunlockput(ip);
80105bf0:	83 ec 0c             	sub    $0xc,%esp
80105bf3:	ff 75 f0             	push   -0x10(%ebp)
80105bf6:	e8 be c0 ff ff       	call   80101cb9 <iunlockput>
80105bfb:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bfe:	e8 fe d5 ff ff       	call   80103201 <end_op>
    return -1;
80105c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c08:	eb 33                	jmp    80105c3d <sys_chdir+0xb8>
  }
  iunlock(ip);
80105c0a:	83 ec 0c             	sub    $0xc,%esp
80105c0d:	ff 75 f0             	push   -0x10(%ebp)
80105c10:	e8 7e bf ff ff       	call   80101b93 <iunlock>
80105c15:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1b:	8b 40 68             	mov    0x68(%eax),%eax
80105c1e:	83 ec 0c             	sub    $0xc,%esp
80105c21:	50                   	push   %eax
80105c22:	e8 be bf ff ff       	call   80101be5 <iput>
80105c27:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c2a:	e8 d2 d5 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c35:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c3d:	c9                   	leave
80105c3e:	c3                   	ret

80105c3f <sys_exec>:

int
sys_exec(void)
{
80105c3f:	f3 0f 1e fb          	endbr32
80105c43:	55                   	push   %ebp
80105c44:	89 e5                	mov    %esp,%ebp
80105c46:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105c4c:	83 ec 08             	sub    $0x8,%esp
80105c4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c52:	50                   	push   %eax
80105c53:	6a 00                	push   $0x0
80105c55:	e8 56 f3 ff ff       	call   80104fb0 <argstr>
80105c5a:	83 c4 10             	add    $0x10,%esp
80105c5d:	85 c0                	test   %eax,%eax
80105c5f:	78 18                	js     80105c79 <sys_exec+0x3a>
80105c61:	83 ec 08             	sub    $0x8,%esp
80105c64:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105c6a:	50                   	push   %eax
80105c6b:	6a 01                	push   $0x1
80105c6d:	e8 a1 f2 ff ff       	call   80104f13 <argint>
80105c72:	83 c4 10             	add    $0x10,%esp
80105c75:	85 c0                	test   %eax,%eax
80105c77:	79 0a                	jns    80105c83 <sys_exec+0x44>
    return -1;
80105c79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7e:	e9 c6 00 00 00       	jmp    80105d49 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105c83:	83 ec 04             	sub    $0x4,%esp
80105c86:	68 80 00 00 00       	push   $0x80
80105c8b:	6a 00                	push   $0x0
80105c8d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c93:	50                   	push   %eax
80105c94:	e8 26 ef ff ff       	call   80104bbf <memset>
80105c99:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	83 f8 1f             	cmp    $0x1f,%eax
80105ca9:	76 0a                	jbe    80105cb5 <sys_exec+0x76>
      return -1;
80105cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb0:	e9 94 00 00 00       	jmp    80105d49 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb8:	c1 e0 02             	shl    $0x2,%eax
80105cbb:	89 c2                	mov    %eax,%edx
80105cbd:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105cc3:	01 c2                	add    %eax,%edx
80105cc5:	83 ec 08             	sub    $0x8,%esp
80105cc8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105cce:	50                   	push   %eax
80105ccf:	52                   	push   %edx
80105cd0:	e8 93 f1 ff ff       	call   80104e68 <fetchint>
80105cd5:	83 c4 10             	add    $0x10,%esp
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	79 07                	jns    80105ce3 <sys_exec+0xa4>
      return -1;
80105cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce1:	eb 66                	jmp    80105d49 <sys_exec+0x10a>
    if(uarg == 0){
80105ce3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ce9:	85 c0                	test   %eax,%eax
80105ceb:	75 27                	jne    80105d14 <sys_exec+0xd5>
      argv[i] = 0;
80105ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105cf7:	00 00 00 00 
      break;
80105cfb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cff:	83 ec 08             	sub    $0x8,%esp
80105d02:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105d08:	52                   	push   %edx
80105d09:	50                   	push   %eax
80105d0a:	e8 af ae ff ff       	call   80100bbe <exec>
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	eb 35                	jmp    80105d49 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105d14:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d1d:	c1 e2 02             	shl    $0x2,%edx
80105d20:	01 c2                	add    %eax,%edx
80105d22:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105d28:	83 ec 08             	sub    $0x8,%esp
80105d2b:	52                   	push   %edx
80105d2c:	50                   	push   %eax
80105d2d:	e8 79 f1 ff ff       	call   80104eab <fetchstr>
80105d32:	83 c4 10             	add    $0x10,%esp
80105d35:	85 c0                	test   %eax,%eax
80105d37:	79 07                	jns    80105d40 <sys_exec+0x101>
      return -1;
80105d39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3e:	eb 09                	jmp    80105d49 <sys_exec+0x10a>
  for(i=0;; i++){
80105d40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d44:	e9 5a ff ff ff       	jmp    80105ca3 <sys_exec+0x64>
}
80105d49:	c9                   	leave
80105d4a:	c3                   	ret

80105d4b <sys_pipe>:

int
sys_pipe(void)
{
80105d4b:	f3 0f 1e fb          	endbr32
80105d4f:	55                   	push   %ebp
80105d50:	89 e5                	mov    %esp,%ebp
80105d52:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d55:	83 ec 04             	sub    $0x4,%esp
80105d58:	6a 08                	push   $0x8
80105d5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d5d:	50                   	push   %eax
80105d5e:	6a 00                	push   $0x0
80105d60:	e8 df f1 ff ff       	call   80104f44 <argptr>
80105d65:	83 c4 10             	add    $0x10,%esp
80105d68:	85 c0                	test   %eax,%eax
80105d6a:	79 0a                	jns    80105d76 <sys_pipe+0x2b>
    return -1;
80105d6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d71:	e9 ae 00 00 00       	jmp    80105e24 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105d76:	83 ec 08             	sub    $0x8,%esp
80105d79:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d7c:	50                   	push   %eax
80105d7d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d80:	50                   	push   %eax
80105d81:	e8 44 d9 ff ff       	call   801036ca <pipealloc>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	85 c0                	test   %eax,%eax
80105d8b:	79 0a                	jns    80105d97 <sys_pipe+0x4c>
    return -1;
80105d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d92:	e9 8d 00 00 00       	jmp    80105e24 <sys_pipe+0xd9>
  fd0 = -1;
80105d97:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105da1:	83 ec 0c             	sub    $0xc,%esp
80105da4:	50                   	push   %eax
80105da5:	e8 3b f3 ff ff       	call   801050e5 <fdalloc>
80105daa:	83 c4 10             	add    $0x10,%esp
80105dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db4:	78 18                	js     80105dce <sys_pipe+0x83>
80105db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db9:	83 ec 0c             	sub    $0xc,%esp
80105dbc:	50                   	push   %eax
80105dbd:	e8 23 f3 ff ff       	call   801050e5 <fdalloc>
80105dc2:	83 c4 10             	add    $0x10,%esp
80105dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dcc:	79 3e                	jns    80105e0c <sys_pipe+0xc1>
    if(fd0 >= 0)
80105dce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd2:	78 13                	js     80105de7 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105dd4:	e8 d0 dd ff ff       	call   80103ba9 <myproc>
80105dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ddc:	83 c2 08             	add    $0x8,%edx
80105ddf:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105de6:	00 
    fileclose(rf);
80105de7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dea:	83 ec 0c             	sub    $0xc,%esp
80105ded:	50                   	push   %eax
80105dee:	e8 f6 b2 ff ff       	call   801010e9 <fileclose>
80105df3:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105df9:	83 ec 0c             	sub    $0xc,%esp
80105dfc:	50                   	push   %eax
80105dfd:	e8 e7 b2 ff ff       	call   801010e9 <fileclose>
80105e02:	83 c4 10             	add    $0x10,%esp
    return -1;
80105e05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0a:	eb 18                	jmp    80105e24 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105e0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e12:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105e14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e17:	8d 50 04             	lea    0x4(%eax),%edx
80105e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1d:	89 02                	mov    %eax,(%edx)
  return 0;
80105e1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e24:	c9                   	leave
80105e25:	c3                   	ret

80105e26 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105e26:	f3 0f 1e fb          	endbr32
80105e2a:	55                   	push   %ebp
80105e2b:	89 e5                	mov    %esp,%ebp
80105e2d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105e30:	e8 8a e0 ff ff       	call   80103ebf <fork>
}
80105e35:	c9                   	leave
80105e36:	c3                   	ret

80105e37 <sys_exit>:

int
sys_exit(void)
{
80105e37:	f3 0f 1e fb          	endbr32
80105e3b:	55                   	push   %ebp
80105e3c:	89 e5                	mov    %esp,%ebp
80105e3e:	83 ec 08             	sub    $0x8,%esp
  exit();
80105e41:	e8 f6 e1 ff ff       	call   8010403c <exit>
  return 0;  // not reached
80105e46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e4b:	c9                   	leave
80105e4c:	c3                   	ret

80105e4d <sys_wait>:

int
sys_wait(void)
{
80105e4d:	f3 0f 1e fb          	endbr32
80105e51:	55                   	push   %ebp
80105e52:	89 e5                	mov    %esp,%ebp
80105e54:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105e57:	e8 07 e3 ff ff       	call   80104163 <wait>
}
80105e5c:	c9                   	leave
80105e5d:	c3                   	ret

80105e5e <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105e5e:	f3 0f 1e fb          	endbr32
80105e62:	55                   	push   %ebp
80105e63:	89 e5                	mov    %esp,%ebp
80105e65:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105e68:	83 ec 08             	sub    $0x8,%esp
80105e6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e6e:	50                   	push   %eax
80105e6f:	6a 00                	push   $0x0
80105e71:	e8 9d f0 ff ff       	call   80104f13 <argint>
80105e76:	83 c4 10             	add    $0x10,%esp
80105e79:	85 c0                	test   %eax,%eax
80105e7b:	79 07                	jns    80105e84 <sys_uthread_init+0x26>
        return -1;
80105e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e82:	eb 0f                	jmp    80105e93 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80105e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e87:	83 ec 0c             	sub    $0xc,%esp
80105e8a:	50                   	push   %eax
80105e8b:	e8 b9 e4 ff ff       	call   80104349 <uthread_init>
80105e90:	83 c4 10             	add    $0x10,%esp
}
80105e93:	c9                   	leave
80105e94:	c3                   	ret

80105e95 <sys_thread_count>:

int
sys_thread_count(void)
{
80105e95:	f3 0f 1e fb          	endbr32
80105e99:	55                   	push   %ebp
80105e9a:	89 e5                	mov    %esp,%ebp
80105e9c:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int count;
    if (argint(0, &count) < 0)
80105e9f:	83 ec 08             	sub    $0x8,%esp
80105ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ea5:	50                   	push   %eax
80105ea6:	6a 00                	push   $0x0
80105ea8:	e8 66 f0 ff ff       	call   80104f13 <argint>
80105ead:	83 c4 10             	add    $0x10,%esp
80105eb0:	85 c0                	test   %eax,%eax
80105eb2:	79 07                	jns    80105ebb <sys_thread_count+0x26>
        return -1;
80105eb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb9:	eb 0f                	jmp    80105eca <sys_thread_count+0x35>
    // proc.c의 thread_count() 함수 호출
    return thread_count(count);
80105ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebe:	83 ec 0c             	sub    $0xc,%esp
80105ec1:	50                   	push   %eax
80105ec2:	e8 a4 e4 ff ff       	call   8010436b <thread_count>
80105ec7:	83 c4 10             	add    $0x10,%esp
}
80105eca:	c9                   	leave
80105ecb:	c3                   	ret

80105ecc <sys_kill>:
int
sys_kill(void)
{
80105ecc:	f3 0f 1e fb          	endbr32
80105ed0:	55                   	push   %ebp
80105ed1:	89 e5                	mov    %esp,%ebp
80105ed3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105ed6:	83 ec 08             	sub    $0x8,%esp
80105ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105edc:	50                   	push   %eax
80105edd:	6a 00                	push   $0x0
80105edf:	e8 2f f0 ff ff       	call   80104f13 <argint>
80105ee4:	83 c4 10             	add    $0x10,%esp
80105ee7:	85 c0                	test   %eax,%eax
80105ee9:	79 07                	jns    80105ef2 <sys_kill+0x26>
    return -1;
80105eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef0:	eb 0f                	jmp    80105f01 <sys_kill+0x35>
  return kill(pid);
80105ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef5:	83 ec 0c             	sub    $0xc,%esp
80105ef8:	50                   	push   %eax
80105ef9:	e8 13 e7 ff ff       	call   80104611 <kill>
80105efe:	83 c4 10             	add    $0x10,%esp
}
80105f01:	c9                   	leave
80105f02:	c3                   	ret

80105f03 <sys_getpid>:

int
sys_getpid(void)
{
80105f03:	f3 0f 1e fb          	endbr32
80105f07:	55                   	push   %ebp
80105f08:	89 e5                	mov    %esp,%ebp
80105f0a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105f0d:	e8 97 dc ff ff       	call   80103ba9 <myproc>
80105f12:	8b 40 10             	mov    0x10(%eax),%eax
}
80105f15:	c9                   	leave
80105f16:	c3                   	ret

80105f17 <sys_sbrk>:

int
sys_sbrk(void)
{
80105f17:	f3 0f 1e fb          	endbr32
80105f1b:	55                   	push   %ebp
80105f1c:	89 e5                	mov    %esp,%ebp
80105f1e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105f21:	83 ec 08             	sub    $0x8,%esp
80105f24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f27:	50                   	push   %eax
80105f28:	6a 00                	push   $0x0
80105f2a:	e8 e4 ef ff ff       	call   80104f13 <argint>
80105f2f:	83 c4 10             	add    $0x10,%esp
80105f32:	85 c0                	test   %eax,%eax
80105f34:	79 07                	jns    80105f3d <sys_sbrk+0x26>
    return -1;
80105f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3b:	eb 27                	jmp    80105f64 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80105f3d:	e8 67 dc ff ff       	call   80103ba9 <myproc>
80105f42:	8b 00                	mov    (%eax),%eax
80105f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4a:	83 ec 0c             	sub    $0xc,%esp
80105f4d:	50                   	push   %eax
80105f4e:	e8 cd de ff ff       	call   80103e20 <growproc>
80105f53:	83 c4 10             	add    $0x10,%esp
80105f56:	85 c0                	test   %eax,%eax
80105f58:	79 07                	jns    80105f61 <sys_sbrk+0x4a>
    return -1;
80105f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5f:	eb 03                	jmp    80105f64 <sys_sbrk+0x4d>
  return addr;
80105f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f64:	c9                   	leave
80105f65:	c3                   	ret

80105f66 <sys_sleep>:

int
sys_sleep(void)
{
80105f66:	f3 0f 1e fb          	endbr32
80105f6a:	55                   	push   %ebp
80105f6b:	89 e5                	mov    %esp,%ebp
80105f6d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105f70:	83 ec 08             	sub    $0x8,%esp
80105f73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f76:	50                   	push   %eax
80105f77:	6a 00                	push   $0x0
80105f79:	e8 95 ef ff ff       	call   80104f13 <argint>
80105f7e:	83 c4 10             	add    $0x10,%esp
80105f81:	85 c0                	test   %eax,%eax
80105f83:	79 07                	jns    80105f8c <sys_sleep+0x26>
    return -1;
80105f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8a:	eb 76                	jmp    80106002 <sys_sleep+0x9c>
  acquire(&tickslock);
80105f8c:	83 ec 0c             	sub    $0xc,%esp
80105f8f:	68 40 76 19 80       	push   $0x80197640
80105f94:	e8 97 e9 ff ff       	call   80104930 <acquire>
80105f99:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105f9c:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80105fa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105fa4:	eb 38                	jmp    80105fde <sys_sleep+0x78>
    if(myproc()->killed){
80105fa6:	e8 fe db ff ff       	call   80103ba9 <myproc>
80105fab:	8b 40 24             	mov    0x24(%eax),%eax
80105fae:	85 c0                	test   %eax,%eax
80105fb0:	74 17                	je     80105fc9 <sys_sleep+0x63>
      release(&tickslock);
80105fb2:	83 ec 0c             	sub    $0xc,%esp
80105fb5:	68 40 76 19 80       	push   $0x80197640
80105fba:	e8 e3 e9 ff ff       	call   801049a2 <release>
80105fbf:	83 c4 10             	add    $0x10,%esp
      return -1;
80105fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc7:	eb 39                	jmp    80106002 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80105fc9:	83 ec 08             	sub    $0x8,%esp
80105fcc:	68 40 76 19 80       	push   $0x80197640
80105fd1:	68 80 7e 19 80       	push   $0x80197e80
80105fd6:	e8 09 e5 ff ff       	call   801044e4 <sleep>
80105fdb:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105fde:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80105fe3:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105fe6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fe9:	39 d0                	cmp    %edx,%eax
80105feb:	72 b9                	jb     80105fa6 <sys_sleep+0x40>
  }
  release(&tickslock);
80105fed:	83 ec 0c             	sub    $0xc,%esp
80105ff0:	68 40 76 19 80       	push   $0x80197640
80105ff5:	e8 a8 e9 ff ff       	call   801049a2 <release>
80105ffa:	83 c4 10             	add    $0x10,%esp
  return 0;
80105ffd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106002:	c9                   	leave
80106003:	c3                   	ret

80106004 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106004:	f3 0f 1e fb          	endbr32
80106008:	55                   	push   %ebp
80106009:	89 e5                	mov    %esp,%ebp
8010600b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010600e:	83 ec 0c             	sub    $0xc,%esp
80106011:	68 40 76 19 80       	push   $0x80197640
80106016:	e8 15 e9 ff ff       	call   80104930 <acquire>
8010601b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010601e:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106023:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106026:	83 ec 0c             	sub    $0xc,%esp
80106029:	68 40 76 19 80       	push   $0x80197640
8010602e:	e8 6f e9 ff ff       	call   801049a2 <release>
80106033:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106036:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106039:	c9                   	leave
8010603a:	c3                   	ret

8010603b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010603b:	1e                   	push   %ds
  pushl %es
8010603c:	06                   	push   %es
  pushl %fs
8010603d:	0f a0                	push   %fs
  pushl %gs
8010603f:	0f a8                	push   %gs
  pushal
80106041:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106042:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106046:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106048:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010604a:	54                   	push   %esp
  call trap
8010604b:	e8 df 01 00 00       	call   8010622f <trap>
  addl $4, %esp
80106050:	83 c4 04             	add    $0x4,%esp

80106053 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106053:	61                   	popa
  popl %gs
80106054:	0f a9                	pop    %gs
  popl %fs
80106056:	0f a1                	pop    %fs
  popl %es
80106058:	07                   	pop    %es
  popl %ds
80106059:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010605a:	83 c4 08             	add    $0x8,%esp
  iret
8010605d:	cf                   	iret

8010605e <lidt>:
{
8010605e:	55                   	push   %ebp
8010605f:	89 e5                	mov    %esp,%ebp
80106061:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106064:	8b 45 0c             	mov    0xc(%ebp),%eax
80106067:	83 e8 01             	sub    $0x1,%eax
8010606a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010606e:	8b 45 08             	mov    0x8(%ebp),%eax
80106071:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106075:	8b 45 08             	mov    0x8(%ebp),%eax
80106078:	c1 e8 10             	shr    $0x10,%eax
8010607b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010607f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106082:	0f 01 18             	lidtl  (%eax)
}
80106085:	90                   	nop
80106086:	c9                   	leave
80106087:	c3                   	ret

80106088 <rcr2>:

static inline uint
rcr2(void)
{
80106088:	55                   	push   %ebp
80106089:	89 e5                	mov    %esp,%ebp
8010608b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010608e:	0f 20 d0             	mov    %cr2,%eax
80106091:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106094:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106097:	c9                   	leave
80106098:	c3                   	ret

80106099 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106099:	f3 0f 1e fb          	endbr32
8010609d:	55                   	push   %ebp
8010609e:	89 e5                	mov    %esp,%ebp
801060a0:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801060a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801060aa:	e9 c3 00 00 00       	jmp    80106172 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801060af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b2:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801060b9:	89 c2                	mov    %eax,%edx
801060bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060be:	66 89 14 c5 80 76 19 	mov    %dx,-0x7fe68980(,%eax,8)
801060c5:	80 
801060c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c9:	66 c7 04 c5 82 76 19 	movw   $0x8,-0x7fe6897e(,%eax,8)
801060d0:	80 08 00 
801060d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d6:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
801060dd:	80 
801060de:	83 e2 e0             	and    $0xffffffe0,%edx
801060e1:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
801060e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060eb:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
801060f2:	80 
801060f3:	83 e2 1f             	and    $0x1f,%edx
801060f6:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
801060fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106100:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
80106107:	80 
80106108:	83 e2 f0             	and    $0xfffffff0,%edx
8010610b:	83 ca 0e             	or     $0xe,%edx
8010610e:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
80106115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106118:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
8010611f:	80 
80106120:	83 e2 ef             	and    $0xffffffef,%edx
80106123:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
8010612a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612d:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
80106134:	80 
80106135:	83 e2 9f             	and    $0xffffff9f,%edx
80106138:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
8010613f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106142:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
80106149:	80 
8010614a:	83 ca 80             	or     $0xffffff80,%edx
8010614d:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
80106154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106157:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010615e:	c1 e8 10             	shr    $0x10,%eax
80106161:	89 c2                	mov    %eax,%edx
80106163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106166:	66 89 14 c5 86 76 19 	mov    %dx,-0x7fe6897a(,%eax,8)
8010616d:	80 
  for(i = 0; i < 256; i++)
8010616e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106172:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106179:	0f 8e 30 ff ff ff    	jle    801060af <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010617f:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106184:	66 a3 80 78 19 80    	mov    %ax,0x80197880
8010618a:	66 c7 05 82 78 19 80 	movw   $0x8,0x80197882
80106191:	08 00 
80106193:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
8010619a:	83 e0 e0             	and    $0xffffffe0,%eax
8010619d:	a2 84 78 19 80       	mov    %al,0x80197884
801061a2:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
801061a9:	83 e0 1f             	and    $0x1f,%eax
801061ac:	a2 84 78 19 80       	mov    %al,0x80197884
801061b1:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
801061b8:	83 c8 0f             	or     $0xf,%eax
801061bb:	a2 85 78 19 80       	mov    %al,0x80197885
801061c0:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
801061c7:	83 e0 ef             	and    $0xffffffef,%eax
801061ca:	a2 85 78 19 80       	mov    %al,0x80197885
801061cf:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
801061d6:	83 c8 60             	or     $0x60,%eax
801061d9:	a2 85 78 19 80       	mov    %al,0x80197885
801061de:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
801061e5:	83 c8 80             	or     $0xffffff80,%eax
801061e8:	a2 85 78 19 80       	mov    %al,0x80197885
801061ed:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801061f2:	c1 e8 10             	shr    $0x10,%eax
801061f5:	66 a3 86 78 19 80    	mov    %ax,0x80197886

  initlock(&tickslock, "time");
801061fb:	83 ec 08             	sub    $0x8,%esp
801061fe:	68 d8 a8 10 80       	push   $0x8010a8d8
80106203:	68 40 76 19 80       	push   $0x80197640
80106208:	e8 fd e6 ff ff       	call   8010490a <initlock>
8010620d:	83 c4 10             	add    $0x10,%esp
}
80106210:	90                   	nop
80106211:	c9                   	leave
80106212:	c3                   	ret

80106213 <idtinit>:

void
idtinit(void)
{
80106213:	f3 0f 1e fb          	endbr32
80106217:	55                   	push   %ebp
80106218:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010621a:	68 00 08 00 00       	push   $0x800
8010621f:	68 80 76 19 80       	push   $0x80197680
80106224:	e8 35 fe ff ff       	call   8010605e <lidt>
80106229:	83 c4 08             	add    $0x8,%esp
}
8010622c:	90                   	nop
8010622d:	c9                   	leave
8010622e:	c3                   	ret

8010622f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010622f:	f3 0f 1e fb          	endbr32
80106233:	55                   	push   %ebp
80106234:	89 e5                	mov    %esp,%ebp
80106236:	57                   	push   %edi
80106237:	56                   	push   %esi
80106238:	53                   	push   %ebx
80106239:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010623c:	8b 45 08             	mov    0x8(%ebp),%eax
8010623f:	8b 40 30             	mov    0x30(%eax),%eax
80106242:	83 f8 40             	cmp    $0x40,%eax
80106245:	75 3b                	jne    80106282 <trap+0x53>
    if(myproc()->killed)
80106247:	e8 5d d9 ff ff       	call   80103ba9 <myproc>
8010624c:	8b 40 24             	mov    0x24(%eax),%eax
8010624f:	85 c0                	test   %eax,%eax
80106251:	74 05                	je     80106258 <trap+0x29>
      exit();
80106253:	e8 e4 dd ff ff       	call   8010403c <exit>
    myproc()->tf = tf;
80106258:	e8 4c d9 ff ff       	call   80103ba9 <myproc>
8010625d:	8b 55 08             	mov    0x8(%ebp),%edx
80106260:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106263:	e8 83 ed ff ff       	call   80104feb <syscall>
    if(myproc()->killed)
80106268:	e8 3c d9 ff ff       	call   80103ba9 <myproc>
8010626d:	8b 40 24             	mov    0x24(%eax),%eax
80106270:	85 c0                	test   %eax,%eax
80106272:	0f 84 96 02 00 00    	je     8010650e <trap+0x2df>
      exit();
80106278:	e8 bf dd ff ff       	call   8010403c <exit>
    return;
8010627d:	e9 8c 02 00 00       	jmp    8010650e <trap+0x2df>
  }

  switch(tf->trapno){
80106282:	8b 45 08             	mov    0x8(%ebp),%eax
80106285:	8b 40 30             	mov    0x30(%eax),%eax
80106288:	83 e8 20             	sub    $0x20,%eax
8010628b:	83 f8 1f             	cmp    $0x1f,%eax
8010628e:	0f 87 42 01 00 00    	ja     801063d6 <trap+0x1a7>
80106294:	8b 04 85 80 a9 10 80 	mov    -0x7fef5680(,%eax,4),%eax
8010629b:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010629e:	e8 6b d8 ff ff       	call   80103b0e <cpuid>
801062a3:	85 c0                	test   %eax,%eax
801062a5:	75 3d                	jne    801062e4 <trap+0xb5>
      acquire(&tickslock);
801062a7:	83 ec 0c             	sub    $0xc,%esp
801062aa:	68 40 76 19 80       	push   $0x80197640
801062af:	e8 7c e6 ff ff       	call   80104930 <acquire>
801062b4:	83 c4 10             	add    $0x10,%esp
      ticks++;
801062b7:	a1 80 7e 19 80       	mov    0x80197e80,%eax
801062bc:	83 c0 01             	add    $0x1,%eax
801062bf:	a3 80 7e 19 80       	mov    %eax,0x80197e80
      wakeup(&ticks);
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	68 80 7e 19 80       	push   $0x80197e80
801062cc:	e8 05 e3 ff ff       	call   801045d6 <wakeup>
801062d1:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801062d4:	83 ec 0c             	sub    $0xc,%esp
801062d7:	68 40 76 19 80       	push   $0x80197640
801062dc:	e8 c1 e6 ff ff       	call   801049a2 <release>
801062e1:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801062e4:	e8 3c c9 ff ff       	call   80102c25 <lapiceoi>

    // 여기서부터 코드 시작
    // 현재 실행하고 있는 프로세스 호출
    struct proc* p = myproc();
801062e9:	e8 bb d8 ff ff       	call   80103ba9 <myproc>
801062ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // 커널 모드에서 동작 && 프로세스 존재 && 스케줄러가 존재(uthread_init()에서 설정)
    if ((tf->cs&3) == 0 && p != 0 && p->scheduler != 0 && p->thread_count > 1 && ticks % 5 == 0) {
801062f1:	8b 45 08             	mov    0x8(%ebp),%eax
801062f4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062f8:	0f b7 c0             	movzwl %ax,%eax
801062fb:	83 e0 03             	and    $0x3,%eax
801062fe:	85 c0                	test   %eax,%eax
80106300:	0f 85 87 01 00 00    	jne    8010648d <trap+0x25e>
80106306:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010630a:	0f 84 7d 01 00 00    	je     8010648d <trap+0x25e>
80106310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106313:	8b 40 7c             	mov    0x7c(%eax),%eax
80106316:	85 c0                	test   %eax,%eax
80106318:	0f 84 6f 01 00 00    	je     8010648d <trap+0x25e>
8010631e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106321:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106327:	83 f8 01             	cmp    $0x1,%eax
8010632a:	0f 8e 5d 01 00 00    	jle    8010648d <trap+0x25e>
80106330:	8b 0d 80 7e 19 80    	mov    0x80197e80,%ecx
80106336:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010633b:	89 c8                	mov    %ecx,%eax
8010633d:	f7 e2                	mul    %edx
8010633f:	89 d0                	mov    %edx,%eax
80106341:	c1 e8 02             	shr    $0x2,%eax
80106344:	89 c2                	mov    %eax,%edx
80106346:	c1 e2 02             	shl    $0x2,%edx
80106349:	01 c2                	add    %eax,%edx
8010634b:	89 c8                	mov    %ecx,%eax
8010634d:	29 d0                	sub    %edx,%eax
8010634f:	85 c0                	test   %eax,%eax
80106351:	0f 85 36 01 00 00    	jne    8010648d <trap+0x25e>
      // eip를 uthread의 scheduler의 주소로 설정
      p->tf->eip = (uint)p->scheduler;
80106357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010635a:	8b 40 18             	mov    0x18(%eax),%eax
8010635d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106360:	8b 52 7c             	mov    0x7c(%edx),%edx
80106363:	89 50 38             	mov    %edx,0x38(%eax)
    }

    break;
80106366:	e9 22 01 00 00       	jmp    8010648d <trap+0x25e>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010636b:	e8 1e 40 00 00       	call   8010a38e <ideintr>
    lapiceoi();
80106370:	e8 b0 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
80106375:	e9 14 01 00 00       	jmp    8010648e <trap+0x25f>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010637a:	e8 dc c6 ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
8010637f:	e8 a1 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
80106384:	e9 05 01 00 00       	jmp    8010648e <trap+0x25f>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106389:	e8 62 03 00 00       	call   801066f0 <uartintr>
    lapiceoi();
8010638e:	e8 92 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
80106393:	e9 f6 00 00 00       	jmp    8010648e <trap+0x25f>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106398:	e8 30 2c 00 00       	call   80108fcd <i8254_intr>
    lapiceoi();
8010639d:	e8 83 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
801063a2:	e9 e7 00 00 00       	jmp    8010648e <trap+0x25f>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063a7:	8b 45 08             	mov    0x8(%ebp),%eax
801063aa:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801063ad:	8b 45 08             	mov    0x8(%ebp),%eax
801063b0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063b4:	0f b7 d8             	movzwl %ax,%ebx
801063b7:	e8 52 d7 ff ff       	call   80103b0e <cpuid>
801063bc:	56                   	push   %esi
801063bd:	53                   	push   %ebx
801063be:	50                   	push   %eax
801063bf:	68 e0 a8 10 80       	push   $0x8010a8e0
801063c4:	e8 43 a0 ff ff       	call   8010040c <cprintf>
801063c9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801063cc:	e8 54 c8 ff ff       	call   80102c25 <lapiceoi>
    break;
801063d1:	e9 b8 00 00 00       	jmp    8010648e <trap+0x25f>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801063d6:	e8 ce d7 ff ff       	call   80103ba9 <myproc>
801063db:	85 c0                	test   %eax,%eax
801063dd:	74 11                	je     801063f0 <trap+0x1c1>
801063df:	8b 45 08             	mov    0x8(%ebp),%eax
801063e2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063e6:	0f b7 c0             	movzwl %ax,%eax
801063e9:	83 e0 03             	and    $0x3,%eax
801063ec:	85 c0                	test   %eax,%eax
801063ee:	75 39                	jne    80106429 <trap+0x1fa>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801063f0:	e8 93 fc ff ff       	call   80106088 <rcr2>
801063f5:	89 c3                	mov    %eax,%ebx
801063f7:	8b 45 08             	mov    0x8(%ebp),%eax
801063fa:	8b 70 38             	mov    0x38(%eax),%esi
801063fd:	e8 0c d7 ff ff       	call   80103b0e <cpuid>
80106402:	8b 55 08             	mov    0x8(%ebp),%edx
80106405:	8b 52 30             	mov    0x30(%edx),%edx
80106408:	83 ec 0c             	sub    $0xc,%esp
8010640b:	53                   	push   %ebx
8010640c:	56                   	push   %esi
8010640d:	50                   	push   %eax
8010640e:	52                   	push   %edx
8010640f:	68 04 a9 10 80       	push   $0x8010a904
80106414:	e8 f3 9f ff ff       	call   8010040c <cprintf>
80106419:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010641c:	83 ec 0c             	sub    $0xc,%esp
8010641f:	68 36 a9 10 80       	push   $0x8010a936
80106424:	e8 9c a1 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106429:	e8 5a fc ff ff       	call   80106088 <rcr2>
8010642e:	89 c6                	mov    %eax,%esi
80106430:	8b 45 08             	mov    0x8(%ebp),%eax
80106433:	8b 40 38             	mov    0x38(%eax),%eax
80106436:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106439:	e8 d0 d6 ff ff       	call   80103b0e <cpuid>
8010643e:	89 c3                	mov    %eax,%ebx
80106440:	8b 45 08             	mov    0x8(%ebp),%eax
80106443:	8b 78 34             	mov    0x34(%eax),%edi
80106446:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106449:	8b 45 08             	mov    0x8(%ebp),%eax
8010644c:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010644f:	e8 55 d7 ff ff       	call   80103ba9 <myproc>
80106454:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106457:	89 4d cc             	mov    %ecx,-0x34(%ebp)
8010645a:	e8 4a d7 ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010645f:	8b 40 10             	mov    0x10(%eax),%eax
80106462:	56                   	push   %esi
80106463:	ff 75 d4             	push   -0x2c(%ebp)
80106466:	53                   	push   %ebx
80106467:	ff 75 d0             	push   -0x30(%ebp)
8010646a:	57                   	push   %edi
8010646b:	ff 75 cc             	push   -0x34(%ebp)
8010646e:	50                   	push   %eax
8010646f:	68 3c a9 10 80       	push   $0x8010a93c
80106474:	e8 93 9f ff ff       	call   8010040c <cprintf>
80106479:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010647c:	e8 28 d7 ff ff       	call   80103ba9 <myproc>
80106481:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106488:	eb 04                	jmp    8010648e <trap+0x25f>
    break;
8010648a:	90                   	nop
8010648b:	eb 01                	jmp    8010648e <trap+0x25f>
    break;
8010648d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010648e:	e8 16 d7 ff ff       	call   80103ba9 <myproc>
80106493:	85 c0                	test   %eax,%eax
80106495:	74 23                	je     801064ba <trap+0x28b>
80106497:	e8 0d d7 ff ff       	call   80103ba9 <myproc>
8010649c:	8b 40 24             	mov    0x24(%eax),%eax
8010649f:	85 c0                	test   %eax,%eax
801064a1:	74 17                	je     801064ba <trap+0x28b>
801064a3:	8b 45 08             	mov    0x8(%ebp),%eax
801064a6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064aa:	0f b7 c0             	movzwl %ax,%eax
801064ad:	83 e0 03             	and    $0x3,%eax
801064b0:	83 f8 03             	cmp    $0x3,%eax
801064b3:	75 05                	jne    801064ba <trap+0x28b>
    exit();
801064b5:	e8 82 db ff ff       	call   8010403c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801064ba:	e8 ea d6 ff ff       	call   80103ba9 <myproc>
801064bf:	85 c0                	test   %eax,%eax
801064c1:	74 1d                	je     801064e0 <trap+0x2b1>
801064c3:	e8 e1 d6 ff ff       	call   80103ba9 <myproc>
801064c8:	8b 40 0c             	mov    0xc(%eax),%eax
801064cb:	83 f8 04             	cmp    $0x4,%eax
801064ce:	75 10                	jne    801064e0 <trap+0x2b1>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801064d0:	8b 45 08             	mov    0x8(%ebp),%eax
801064d3:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801064d6:	83 f8 20             	cmp    $0x20,%eax
801064d9:	75 05                	jne    801064e0 <trap+0x2b1>
    yield();
801064db:	e8 7c df ff ff       	call   8010445c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801064e0:	e8 c4 d6 ff ff       	call   80103ba9 <myproc>
801064e5:	85 c0                	test   %eax,%eax
801064e7:	74 26                	je     8010650f <trap+0x2e0>
801064e9:	e8 bb d6 ff ff       	call   80103ba9 <myproc>
801064ee:	8b 40 24             	mov    0x24(%eax),%eax
801064f1:	85 c0                	test   %eax,%eax
801064f3:	74 1a                	je     8010650f <trap+0x2e0>
801064f5:	8b 45 08             	mov    0x8(%ebp),%eax
801064f8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064fc:	0f b7 c0             	movzwl %ax,%eax
801064ff:	83 e0 03             	and    $0x3,%eax
80106502:	83 f8 03             	cmp    $0x3,%eax
80106505:	75 08                	jne    8010650f <trap+0x2e0>
    exit();
80106507:	e8 30 db ff ff       	call   8010403c <exit>
8010650c:	eb 01                	jmp    8010650f <trap+0x2e0>
    return;
8010650e:	90                   	nop
}
8010650f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106512:	5b                   	pop    %ebx
80106513:	5e                   	pop    %esi
80106514:	5f                   	pop    %edi
80106515:	5d                   	pop    %ebp
80106516:	c3                   	ret

80106517 <inb>:
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 14             	sub    $0x14,%esp
8010651d:	8b 45 08             	mov    0x8(%ebp),%eax
80106520:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106524:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106528:	89 c2                	mov    %eax,%edx
8010652a:	ec                   	in     (%dx),%al
8010652b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010652e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106532:	c9                   	leave
80106533:	c3                   	ret

80106534 <outb>:
{
80106534:	55                   	push   %ebp
80106535:	89 e5                	mov    %esp,%ebp
80106537:	83 ec 08             	sub    $0x8,%esp
8010653a:	8b 45 08             	mov    0x8(%ebp),%eax
8010653d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106540:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106544:	89 d0                	mov    %edx,%eax
80106546:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106549:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010654d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106551:	ee                   	out    %al,(%dx)
}
80106552:	90                   	nop
80106553:	c9                   	leave
80106554:	c3                   	ret

80106555 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106555:	f3 0f 1e fb          	endbr32
80106559:	55                   	push   %ebp
8010655a:	89 e5                	mov    %esp,%ebp
8010655c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010655f:	6a 00                	push   $0x0
80106561:	68 fa 03 00 00       	push   $0x3fa
80106566:	e8 c9 ff ff ff       	call   80106534 <outb>
8010656b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010656e:	68 80 00 00 00       	push   $0x80
80106573:	68 fb 03 00 00       	push   $0x3fb
80106578:	e8 b7 ff ff ff       	call   80106534 <outb>
8010657d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106580:	6a 0c                	push   $0xc
80106582:	68 f8 03 00 00       	push   $0x3f8
80106587:	e8 a8 ff ff ff       	call   80106534 <outb>
8010658c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010658f:	6a 00                	push   $0x0
80106591:	68 f9 03 00 00       	push   $0x3f9
80106596:	e8 99 ff ff ff       	call   80106534 <outb>
8010659b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010659e:	6a 03                	push   $0x3
801065a0:	68 fb 03 00 00       	push   $0x3fb
801065a5:	e8 8a ff ff ff       	call   80106534 <outb>
801065aa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801065ad:	6a 00                	push   $0x0
801065af:	68 fc 03 00 00       	push   $0x3fc
801065b4:	e8 7b ff ff ff       	call   80106534 <outb>
801065b9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801065bc:	6a 01                	push   $0x1
801065be:	68 f9 03 00 00       	push   $0x3f9
801065c3:	e8 6c ff ff ff       	call   80106534 <outb>
801065c8:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801065cb:	68 fd 03 00 00       	push   $0x3fd
801065d0:	e8 42 ff ff ff       	call   80106517 <inb>
801065d5:	83 c4 04             	add    $0x4,%esp
801065d8:	3c ff                	cmp    $0xff,%al
801065da:	74 61                	je     8010663d <uartinit+0xe8>
    return;
  uart = 1;
801065dc:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801065e3:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801065e6:	68 fa 03 00 00       	push   $0x3fa
801065eb:	e8 27 ff ff ff       	call   80106517 <inb>
801065f0:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801065f3:	68 f8 03 00 00       	push   $0x3f8
801065f8:	e8 1a ff ff ff       	call   80106517 <inb>
801065fd:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106600:	83 ec 08             	sub    $0x8,%esp
80106603:	6a 00                	push   $0x0
80106605:	6a 04                	push   $0x4
80106607:	e8 00 c1 ff ff       	call   8010270c <ioapicenable>
8010660c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010660f:	c7 45 f4 00 aa 10 80 	movl   $0x8010aa00,-0xc(%ebp)
80106616:	eb 19                	jmp    80106631 <uartinit+0xdc>
    uartputc(*p);
80106618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661b:	0f b6 00             	movzbl (%eax),%eax
8010661e:	0f be c0             	movsbl %al,%eax
80106621:	83 ec 0c             	sub    $0xc,%esp
80106624:	50                   	push   %eax
80106625:	e8 16 00 00 00       	call   80106640 <uartputc>
8010662a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010662d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106634:	0f b6 00             	movzbl (%eax),%eax
80106637:	84 c0                	test   %al,%al
80106639:	75 dd                	jne    80106618 <uartinit+0xc3>
8010663b:	eb 01                	jmp    8010663e <uartinit+0xe9>
    return;
8010663d:	90                   	nop
}
8010663e:	c9                   	leave
8010663f:	c3                   	ret

80106640 <uartputc>:

void
uartputc(int c)
{
80106640:	f3 0f 1e fb          	endbr32
80106644:	55                   	push   %ebp
80106645:	89 e5                	mov    %esp,%ebp
80106647:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010664a:	a1 60 d0 18 80       	mov    0x8018d060,%eax
8010664f:	85 c0                	test   %eax,%eax
80106651:	74 53                	je     801066a6 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106653:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010665a:	eb 11                	jmp    8010666d <uartputc+0x2d>
    microdelay(10);
8010665c:	83 ec 0c             	sub    $0xc,%esp
8010665f:	6a 0a                	push   $0xa
80106661:	e8 de c5 ff ff       	call   80102c44 <microdelay>
80106666:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106669:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010666d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106671:	7f 1a                	jg     8010668d <uartputc+0x4d>
80106673:	83 ec 0c             	sub    $0xc,%esp
80106676:	68 fd 03 00 00       	push   $0x3fd
8010667b:	e8 97 fe ff ff       	call   80106517 <inb>
80106680:	83 c4 10             	add    $0x10,%esp
80106683:	0f b6 c0             	movzbl %al,%eax
80106686:	83 e0 20             	and    $0x20,%eax
80106689:	85 c0                	test   %eax,%eax
8010668b:	74 cf                	je     8010665c <uartputc+0x1c>
  outb(COM1+0, c);
8010668d:	8b 45 08             	mov    0x8(%ebp),%eax
80106690:	0f b6 c0             	movzbl %al,%eax
80106693:	83 ec 08             	sub    $0x8,%esp
80106696:	50                   	push   %eax
80106697:	68 f8 03 00 00       	push   $0x3f8
8010669c:	e8 93 fe ff ff       	call   80106534 <outb>
801066a1:	83 c4 10             	add    $0x10,%esp
801066a4:	eb 01                	jmp    801066a7 <uartputc+0x67>
    return;
801066a6:	90                   	nop
}
801066a7:	c9                   	leave
801066a8:	c3                   	ret

801066a9 <uartgetc>:

static int
uartgetc(void)
{
801066a9:	f3 0f 1e fb          	endbr32
801066ad:	55                   	push   %ebp
801066ae:	89 e5                	mov    %esp,%ebp
  if(!uart)
801066b0:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801066b5:	85 c0                	test   %eax,%eax
801066b7:	75 07                	jne    801066c0 <uartgetc+0x17>
    return -1;
801066b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066be:	eb 2e                	jmp    801066ee <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801066c0:	68 fd 03 00 00       	push   $0x3fd
801066c5:	e8 4d fe ff ff       	call   80106517 <inb>
801066ca:	83 c4 04             	add    $0x4,%esp
801066cd:	0f b6 c0             	movzbl %al,%eax
801066d0:	83 e0 01             	and    $0x1,%eax
801066d3:	85 c0                	test   %eax,%eax
801066d5:	75 07                	jne    801066de <uartgetc+0x35>
    return -1;
801066d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066dc:	eb 10                	jmp    801066ee <uartgetc+0x45>
  return inb(COM1+0);
801066de:	68 f8 03 00 00       	push   $0x3f8
801066e3:	e8 2f fe ff ff       	call   80106517 <inb>
801066e8:	83 c4 04             	add    $0x4,%esp
801066eb:	0f b6 c0             	movzbl %al,%eax
}
801066ee:	c9                   	leave
801066ef:	c3                   	ret

801066f0 <uartintr>:

void
uartintr(void)
{
801066f0:	f3 0f 1e fb          	endbr32
801066f4:	55                   	push   %ebp
801066f5:	89 e5                	mov    %esp,%ebp
801066f7:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801066fa:	83 ec 0c             	sub    $0xc,%esp
801066fd:	68 a9 66 10 80       	push   $0x801066a9
80106702:	e8 f9 a0 ff ff       	call   80100800 <consoleintr>
80106707:	83 c4 10             	add    $0x10,%esp
}
8010670a:	90                   	nop
8010670b:	c9                   	leave
8010670c:	c3                   	ret

8010670d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010670d:	6a 00                	push   $0x0
  pushl $0
8010670f:	6a 00                	push   $0x0
  jmp alltraps
80106711:	e9 25 f9 ff ff       	jmp    8010603b <alltraps>

80106716 <vector1>:
.globl vector1
vector1:
  pushl $0
80106716:	6a 00                	push   $0x0
  pushl $1
80106718:	6a 01                	push   $0x1
  jmp alltraps
8010671a:	e9 1c f9 ff ff       	jmp    8010603b <alltraps>

8010671f <vector2>:
.globl vector2
vector2:
  pushl $0
8010671f:	6a 00                	push   $0x0
  pushl $2
80106721:	6a 02                	push   $0x2
  jmp alltraps
80106723:	e9 13 f9 ff ff       	jmp    8010603b <alltraps>

80106728 <vector3>:
.globl vector3
vector3:
  pushl $0
80106728:	6a 00                	push   $0x0
  pushl $3
8010672a:	6a 03                	push   $0x3
  jmp alltraps
8010672c:	e9 0a f9 ff ff       	jmp    8010603b <alltraps>

80106731 <vector4>:
.globl vector4
vector4:
  pushl $0
80106731:	6a 00                	push   $0x0
  pushl $4
80106733:	6a 04                	push   $0x4
  jmp alltraps
80106735:	e9 01 f9 ff ff       	jmp    8010603b <alltraps>

8010673a <vector5>:
.globl vector5
vector5:
  pushl $0
8010673a:	6a 00                	push   $0x0
  pushl $5
8010673c:	6a 05                	push   $0x5
  jmp alltraps
8010673e:	e9 f8 f8 ff ff       	jmp    8010603b <alltraps>

80106743 <vector6>:
.globl vector6
vector6:
  pushl $0
80106743:	6a 00                	push   $0x0
  pushl $6
80106745:	6a 06                	push   $0x6
  jmp alltraps
80106747:	e9 ef f8 ff ff       	jmp    8010603b <alltraps>

8010674c <vector7>:
.globl vector7
vector7:
  pushl $0
8010674c:	6a 00                	push   $0x0
  pushl $7
8010674e:	6a 07                	push   $0x7
  jmp alltraps
80106750:	e9 e6 f8 ff ff       	jmp    8010603b <alltraps>

80106755 <vector8>:
.globl vector8
vector8:
  pushl $8
80106755:	6a 08                	push   $0x8
  jmp alltraps
80106757:	e9 df f8 ff ff       	jmp    8010603b <alltraps>

8010675c <vector9>:
.globl vector9
vector9:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $9
8010675e:	6a 09                	push   $0x9
  jmp alltraps
80106760:	e9 d6 f8 ff ff       	jmp    8010603b <alltraps>

80106765 <vector10>:
.globl vector10
vector10:
  pushl $10
80106765:	6a 0a                	push   $0xa
  jmp alltraps
80106767:	e9 cf f8 ff ff       	jmp    8010603b <alltraps>

8010676c <vector11>:
.globl vector11
vector11:
  pushl $11
8010676c:	6a 0b                	push   $0xb
  jmp alltraps
8010676e:	e9 c8 f8 ff ff       	jmp    8010603b <alltraps>

80106773 <vector12>:
.globl vector12
vector12:
  pushl $12
80106773:	6a 0c                	push   $0xc
  jmp alltraps
80106775:	e9 c1 f8 ff ff       	jmp    8010603b <alltraps>

8010677a <vector13>:
.globl vector13
vector13:
  pushl $13
8010677a:	6a 0d                	push   $0xd
  jmp alltraps
8010677c:	e9 ba f8 ff ff       	jmp    8010603b <alltraps>

80106781 <vector14>:
.globl vector14
vector14:
  pushl $14
80106781:	6a 0e                	push   $0xe
  jmp alltraps
80106783:	e9 b3 f8 ff ff       	jmp    8010603b <alltraps>

80106788 <vector15>:
.globl vector15
vector15:
  pushl $0
80106788:	6a 00                	push   $0x0
  pushl $15
8010678a:	6a 0f                	push   $0xf
  jmp alltraps
8010678c:	e9 aa f8 ff ff       	jmp    8010603b <alltraps>

80106791 <vector16>:
.globl vector16
vector16:
  pushl $0
80106791:	6a 00                	push   $0x0
  pushl $16
80106793:	6a 10                	push   $0x10
  jmp alltraps
80106795:	e9 a1 f8 ff ff       	jmp    8010603b <alltraps>

8010679a <vector17>:
.globl vector17
vector17:
  pushl $17
8010679a:	6a 11                	push   $0x11
  jmp alltraps
8010679c:	e9 9a f8 ff ff       	jmp    8010603b <alltraps>

801067a1 <vector18>:
.globl vector18
vector18:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $18
801067a3:	6a 12                	push   $0x12
  jmp alltraps
801067a5:	e9 91 f8 ff ff       	jmp    8010603b <alltraps>

801067aa <vector19>:
.globl vector19
vector19:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $19
801067ac:	6a 13                	push   $0x13
  jmp alltraps
801067ae:	e9 88 f8 ff ff       	jmp    8010603b <alltraps>

801067b3 <vector20>:
.globl vector20
vector20:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $20
801067b5:	6a 14                	push   $0x14
  jmp alltraps
801067b7:	e9 7f f8 ff ff       	jmp    8010603b <alltraps>

801067bc <vector21>:
.globl vector21
vector21:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $21
801067be:	6a 15                	push   $0x15
  jmp alltraps
801067c0:	e9 76 f8 ff ff       	jmp    8010603b <alltraps>

801067c5 <vector22>:
.globl vector22
vector22:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $22
801067c7:	6a 16                	push   $0x16
  jmp alltraps
801067c9:	e9 6d f8 ff ff       	jmp    8010603b <alltraps>

801067ce <vector23>:
.globl vector23
vector23:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $23
801067d0:	6a 17                	push   $0x17
  jmp alltraps
801067d2:	e9 64 f8 ff ff       	jmp    8010603b <alltraps>

801067d7 <vector24>:
.globl vector24
vector24:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $24
801067d9:	6a 18                	push   $0x18
  jmp alltraps
801067db:	e9 5b f8 ff ff       	jmp    8010603b <alltraps>

801067e0 <vector25>:
.globl vector25
vector25:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $25
801067e2:	6a 19                	push   $0x19
  jmp alltraps
801067e4:	e9 52 f8 ff ff       	jmp    8010603b <alltraps>

801067e9 <vector26>:
.globl vector26
vector26:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $26
801067eb:	6a 1a                	push   $0x1a
  jmp alltraps
801067ed:	e9 49 f8 ff ff       	jmp    8010603b <alltraps>

801067f2 <vector27>:
.globl vector27
vector27:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $27
801067f4:	6a 1b                	push   $0x1b
  jmp alltraps
801067f6:	e9 40 f8 ff ff       	jmp    8010603b <alltraps>

801067fb <vector28>:
.globl vector28
vector28:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $28
801067fd:	6a 1c                	push   $0x1c
  jmp alltraps
801067ff:	e9 37 f8 ff ff       	jmp    8010603b <alltraps>

80106804 <vector29>:
.globl vector29
vector29:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $29
80106806:	6a 1d                	push   $0x1d
  jmp alltraps
80106808:	e9 2e f8 ff ff       	jmp    8010603b <alltraps>

8010680d <vector30>:
.globl vector30
vector30:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $30
8010680f:	6a 1e                	push   $0x1e
  jmp alltraps
80106811:	e9 25 f8 ff ff       	jmp    8010603b <alltraps>

80106816 <vector31>:
.globl vector31
vector31:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $31
80106818:	6a 1f                	push   $0x1f
  jmp alltraps
8010681a:	e9 1c f8 ff ff       	jmp    8010603b <alltraps>

8010681f <vector32>:
.globl vector32
vector32:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $32
80106821:	6a 20                	push   $0x20
  jmp alltraps
80106823:	e9 13 f8 ff ff       	jmp    8010603b <alltraps>

80106828 <vector33>:
.globl vector33
vector33:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $33
8010682a:	6a 21                	push   $0x21
  jmp alltraps
8010682c:	e9 0a f8 ff ff       	jmp    8010603b <alltraps>

80106831 <vector34>:
.globl vector34
vector34:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $34
80106833:	6a 22                	push   $0x22
  jmp alltraps
80106835:	e9 01 f8 ff ff       	jmp    8010603b <alltraps>

8010683a <vector35>:
.globl vector35
vector35:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $35
8010683c:	6a 23                	push   $0x23
  jmp alltraps
8010683e:	e9 f8 f7 ff ff       	jmp    8010603b <alltraps>

80106843 <vector36>:
.globl vector36
vector36:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $36
80106845:	6a 24                	push   $0x24
  jmp alltraps
80106847:	e9 ef f7 ff ff       	jmp    8010603b <alltraps>

8010684c <vector37>:
.globl vector37
vector37:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $37
8010684e:	6a 25                	push   $0x25
  jmp alltraps
80106850:	e9 e6 f7 ff ff       	jmp    8010603b <alltraps>

80106855 <vector38>:
.globl vector38
vector38:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $38
80106857:	6a 26                	push   $0x26
  jmp alltraps
80106859:	e9 dd f7 ff ff       	jmp    8010603b <alltraps>

8010685e <vector39>:
.globl vector39
vector39:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $39
80106860:	6a 27                	push   $0x27
  jmp alltraps
80106862:	e9 d4 f7 ff ff       	jmp    8010603b <alltraps>

80106867 <vector40>:
.globl vector40
vector40:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $40
80106869:	6a 28                	push   $0x28
  jmp alltraps
8010686b:	e9 cb f7 ff ff       	jmp    8010603b <alltraps>

80106870 <vector41>:
.globl vector41
vector41:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $41
80106872:	6a 29                	push   $0x29
  jmp alltraps
80106874:	e9 c2 f7 ff ff       	jmp    8010603b <alltraps>

80106879 <vector42>:
.globl vector42
vector42:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $42
8010687b:	6a 2a                	push   $0x2a
  jmp alltraps
8010687d:	e9 b9 f7 ff ff       	jmp    8010603b <alltraps>

80106882 <vector43>:
.globl vector43
vector43:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $43
80106884:	6a 2b                	push   $0x2b
  jmp alltraps
80106886:	e9 b0 f7 ff ff       	jmp    8010603b <alltraps>

8010688b <vector44>:
.globl vector44
vector44:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $44
8010688d:	6a 2c                	push   $0x2c
  jmp alltraps
8010688f:	e9 a7 f7 ff ff       	jmp    8010603b <alltraps>

80106894 <vector45>:
.globl vector45
vector45:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $45
80106896:	6a 2d                	push   $0x2d
  jmp alltraps
80106898:	e9 9e f7 ff ff       	jmp    8010603b <alltraps>

8010689d <vector46>:
.globl vector46
vector46:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $46
8010689f:	6a 2e                	push   $0x2e
  jmp alltraps
801068a1:	e9 95 f7 ff ff       	jmp    8010603b <alltraps>

801068a6 <vector47>:
.globl vector47
vector47:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $47
801068a8:	6a 2f                	push   $0x2f
  jmp alltraps
801068aa:	e9 8c f7 ff ff       	jmp    8010603b <alltraps>

801068af <vector48>:
.globl vector48
vector48:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $48
801068b1:	6a 30                	push   $0x30
  jmp alltraps
801068b3:	e9 83 f7 ff ff       	jmp    8010603b <alltraps>

801068b8 <vector49>:
.globl vector49
vector49:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $49
801068ba:	6a 31                	push   $0x31
  jmp alltraps
801068bc:	e9 7a f7 ff ff       	jmp    8010603b <alltraps>

801068c1 <vector50>:
.globl vector50
vector50:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $50
801068c3:	6a 32                	push   $0x32
  jmp alltraps
801068c5:	e9 71 f7 ff ff       	jmp    8010603b <alltraps>

801068ca <vector51>:
.globl vector51
vector51:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $51
801068cc:	6a 33                	push   $0x33
  jmp alltraps
801068ce:	e9 68 f7 ff ff       	jmp    8010603b <alltraps>

801068d3 <vector52>:
.globl vector52
vector52:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $52
801068d5:	6a 34                	push   $0x34
  jmp alltraps
801068d7:	e9 5f f7 ff ff       	jmp    8010603b <alltraps>

801068dc <vector53>:
.globl vector53
vector53:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $53
801068de:	6a 35                	push   $0x35
  jmp alltraps
801068e0:	e9 56 f7 ff ff       	jmp    8010603b <alltraps>

801068e5 <vector54>:
.globl vector54
vector54:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $54
801068e7:	6a 36                	push   $0x36
  jmp alltraps
801068e9:	e9 4d f7 ff ff       	jmp    8010603b <alltraps>

801068ee <vector55>:
.globl vector55
vector55:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $55
801068f0:	6a 37                	push   $0x37
  jmp alltraps
801068f2:	e9 44 f7 ff ff       	jmp    8010603b <alltraps>

801068f7 <vector56>:
.globl vector56
vector56:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $56
801068f9:	6a 38                	push   $0x38
  jmp alltraps
801068fb:	e9 3b f7 ff ff       	jmp    8010603b <alltraps>

80106900 <vector57>:
.globl vector57
vector57:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $57
80106902:	6a 39                	push   $0x39
  jmp alltraps
80106904:	e9 32 f7 ff ff       	jmp    8010603b <alltraps>

80106909 <vector58>:
.globl vector58
vector58:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $58
8010690b:	6a 3a                	push   $0x3a
  jmp alltraps
8010690d:	e9 29 f7 ff ff       	jmp    8010603b <alltraps>

80106912 <vector59>:
.globl vector59
vector59:
  pushl $0
80106912:	6a 00                	push   $0x0
  pushl $59
80106914:	6a 3b                	push   $0x3b
  jmp alltraps
80106916:	e9 20 f7 ff ff       	jmp    8010603b <alltraps>

8010691b <vector60>:
.globl vector60
vector60:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $60
8010691d:	6a 3c                	push   $0x3c
  jmp alltraps
8010691f:	e9 17 f7 ff ff       	jmp    8010603b <alltraps>

80106924 <vector61>:
.globl vector61
vector61:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $61
80106926:	6a 3d                	push   $0x3d
  jmp alltraps
80106928:	e9 0e f7 ff ff       	jmp    8010603b <alltraps>

8010692d <vector62>:
.globl vector62
vector62:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $62
8010692f:	6a 3e                	push   $0x3e
  jmp alltraps
80106931:	e9 05 f7 ff ff       	jmp    8010603b <alltraps>

80106936 <vector63>:
.globl vector63
vector63:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $63
80106938:	6a 3f                	push   $0x3f
  jmp alltraps
8010693a:	e9 fc f6 ff ff       	jmp    8010603b <alltraps>

8010693f <vector64>:
.globl vector64
vector64:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $64
80106941:	6a 40                	push   $0x40
  jmp alltraps
80106943:	e9 f3 f6 ff ff       	jmp    8010603b <alltraps>

80106948 <vector65>:
.globl vector65
vector65:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $65
8010694a:	6a 41                	push   $0x41
  jmp alltraps
8010694c:	e9 ea f6 ff ff       	jmp    8010603b <alltraps>

80106951 <vector66>:
.globl vector66
vector66:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $66
80106953:	6a 42                	push   $0x42
  jmp alltraps
80106955:	e9 e1 f6 ff ff       	jmp    8010603b <alltraps>

8010695a <vector67>:
.globl vector67
vector67:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $67
8010695c:	6a 43                	push   $0x43
  jmp alltraps
8010695e:	e9 d8 f6 ff ff       	jmp    8010603b <alltraps>

80106963 <vector68>:
.globl vector68
vector68:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $68
80106965:	6a 44                	push   $0x44
  jmp alltraps
80106967:	e9 cf f6 ff ff       	jmp    8010603b <alltraps>

8010696c <vector69>:
.globl vector69
vector69:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $69
8010696e:	6a 45                	push   $0x45
  jmp alltraps
80106970:	e9 c6 f6 ff ff       	jmp    8010603b <alltraps>

80106975 <vector70>:
.globl vector70
vector70:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $70
80106977:	6a 46                	push   $0x46
  jmp alltraps
80106979:	e9 bd f6 ff ff       	jmp    8010603b <alltraps>

8010697e <vector71>:
.globl vector71
vector71:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $71
80106980:	6a 47                	push   $0x47
  jmp alltraps
80106982:	e9 b4 f6 ff ff       	jmp    8010603b <alltraps>

80106987 <vector72>:
.globl vector72
vector72:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $72
80106989:	6a 48                	push   $0x48
  jmp alltraps
8010698b:	e9 ab f6 ff ff       	jmp    8010603b <alltraps>

80106990 <vector73>:
.globl vector73
vector73:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $73
80106992:	6a 49                	push   $0x49
  jmp alltraps
80106994:	e9 a2 f6 ff ff       	jmp    8010603b <alltraps>

80106999 <vector74>:
.globl vector74
vector74:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $74
8010699b:	6a 4a                	push   $0x4a
  jmp alltraps
8010699d:	e9 99 f6 ff ff       	jmp    8010603b <alltraps>

801069a2 <vector75>:
.globl vector75
vector75:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $75
801069a4:	6a 4b                	push   $0x4b
  jmp alltraps
801069a6:	e9 90 f6 ff ff       	jmp    8010603b <alltraps>

801069ab <vector76>:
.globl vector76
vector76:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $76
801069ad:	6a 4c                	push   $0x4c
  jmp alltraps
801069af:	e9 87 f6 ff ff       	jmp    8010603b <alltraps>

801069b4 <vector77>:
.globl vector77
vector77:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $77
801069b6:	6a 4d                	push   $0x4d
  jmp alltraps
801069b8:	e9 7e f6 ff ff       	jmp    8010603b <alltraps>

801069bd <vector78>:
.globl vector78
vector78:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $78
801069bf:	6a 4e                	push   $0x4e
  jmp alltraps
801069c1:	e9 75 f6 ff ff       	jmp    8010603b <alltraps>

801069c6 <vector79>:
.globl vector79
vector79:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $79
801069c8:	6a 4f                	push   $0x4f
  jmp alltraps
801069ca:	e9 6c f6 ff ff       	jmp    8010603b <alltraps>

801069cf <vector80>:
.globl vector80
vector80:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $80
801069d1:	6a 50                	push   $0x50
  jmp alltraps
801069d3:	e9 63 f6 ff ff       	jmp    8010603b <alltraps>

801069d8 <vector81>:
.globl vector81
vector81:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $81
801069da:	6a 51                	push   $0x51
  jmp alltraps
801069dc:	e9 5a f6 ff ff       	jmp    8010603b <alltraps>

801069e1 <vector82>:
.globl vector82
vector82:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $82
801069e3:	6a 52                	push   $0x52
  jmp alltraps
801069e5:	e9 51 f6 ff ff       	jmp    8010603b <alltraps>

801069ea <vector83>:
.globl vector83
vector83:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $83
801069ec:	6a 53                	push   $0x53
  jmp alltraps
801069ee:	e9 48 f6 ff ff       	jmp    8010603b <alltraps>

801069f3 <vector84>:
.globl vector84
vector84:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $84
801069f5:	6a 54                	push   $0x54
  jmp alltraps
801069f7:	e9 3f f6 ff ff       	jmp    8010603b <alltraps>

801069fc <vector85>:
.globl vector85
vector85:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $85
801069fe:	6a 55                	push   $0x55
  jmp alltraps
80106a00:	e9 36 f6 ff ff       	jmp    8010603b <alltraps>

80106a05 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $86
80106a07:	6a 56                	push   $0x56
  jmp alltraps
80106a09:	e9 2d f6 ff ff       	jmp    8010603b <alltraps>

80106a0e <vector87>:
.globl vector87
vector87:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $87
80106a10:	6a 57                	push   $0x57
  jmp alltraps
80106a12:	e9 24 f6 ff ff       	jmp    8010603b <alltraps>

80106a17 <vector88>:
.globl vector88
vector88:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $88
80106a19:	6a 58                	push   $0x58
  jmp alltraps
80106a1b:	e9 1b f6 ff ff       	jmp    8010603b <alltraps>

80106a20 <vector89>:
.globl vector89
vector89:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $89
80106a22:	6a 59                	push   $0x59
  jmp alltraps
80106a24:	e9 12 f6 ff ff       	jmp    8010603b <alltraps>

80106a29 <vector90>:
.globl vector90
vector90:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $90
80106a2b:	6a 5a                	push   $0x5a
  jmp alltraps
80106a2d:	e9 09 f6 ff ff       	jmp    8010603b <alltraps>

80106a32 <vector91>:
.globl vector91
vector91:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $91
80106a34:	6a 5b                	push   $0x5b
  jmp alltraps
80106a36:	e9 00 f6 ff ff       	jmp    8010603b <alltraps>

80106a3b <vector92>:
.globl vector92
vector92:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $92
80106a3d:	6a 5c                	push   $0x5c
  jmp alltraps
80106a3f:	e9 f7 f5 ff ff       	jmp    8010603b <alltraps>

80106a44 <vector93>:
.globl vector93
vector93:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $93
80106a46:	6a 5d                	push   $0x5d
  jmp alltraps
80106a48:	e9 ee f5 ff ff       	jmp    8010603b <alltraps>

80106a4d <vector94>:
.globl vector94
vector94:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $94
80106a4f:	6a 5e                	push   $0x5e
  jmp alltraps
80106a51:	e9 e5 f5 ff ff       	jmp    8010603b <alltraps>

80106a56 <vector95>:
.globl vector95
vector95:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $95
80106a58:	6a 5f                	push   $0x5f
  jmp alltraps
80106a5a:	e9 dc f5 ff ff       	jmp    8010603b <alltraps>

80106a5f <vector96>:
.globl vector96
vector96:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $96
80106a61:	6a 60                	push   $0x60
  jmp alltraps
80106a63:	e9 d3 f5 ff ff       	jmp    8010603b <alltraps>

80106a68 <vector97>:
.globl vector97
vector97:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $97
80106a6a:	6a 61                	push   $0x61
  jmp alltraps
80106a6c:	e9 ca f5 ff ff       	jmp    8010603b <alltraps>

80106a71 <vector98>:
.globl vector98
vector98:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $98
80106a73:	6a 62                	push   $0x62
  jmp alltraps
80106a75:	e9 c1 f5 ff ff       	jmp    8010603b <alltraps>

80106a7a <vector99>:
.globl vector99
vector99:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $99
80106a7c:	6a 63                	push   $0x63
  jmp alltraps
80106a7e:	e9 b8 f5 ff ff       	jmp    8010603b <alltraps>

80106a83 <vector100>:
.globl vector100
vector100:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $100
80106a85:	6a 64                	push   $0x64
  jmp alltraps
80106a87:	e9 af f5 ff ff       	jmp    8010603b <alltraps>

80106a8c <vector101>:
.globl vector101
vector101:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $101
80106a8e:	6a 65                	push   $0x65
  jmp alltraps
80106a90:	e9 a6 f5 ff ff       	jmp    8010603b <alltraps>

80106a95 <vector102>:
.globl vector102
vector102:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $102
80106a97:	6a 66                	push   $0x66
  jmp alltraps
80106a99:	e9 9d f5 ff ff       	jmp    8010603b <alltraps>

80106a9e <vector103>:
.globl vector103
vector103:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $103
80106aa0:	6a 67                	push   $0x67
  jmp alltraps
80106aa2:	e9 94 f5 ff ff       	jmp    8010603b <alltraps>

80106aa7 <vector104>:
.globl vector104
vector104:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $104
80106aa9:	6a 68                	push   $0x68
  jmp alltraps
80106aab:	e9 8b f5 ff ff       	jmp    8010603b <alltraps>

80106ab0 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $105
80106ab2:	6a 69                	push   $0x69
  jmp alltraps
80106ab4:	e9 82 f5 ff ff       	jmp    8010603b <alltraps>

80106ab9 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $106
80106abb:	6a 6a                	push   $0x6a
  jmp alltraps
80106abd:	e9 79 f5 ff ff       	jmp    8010603b <alltraps>

80106ac2 <vector107>:
.globl vector107
vector107:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $107
80106ac4:	6a 6b                	push   $0x6b
  jmp alltraps
80106ac6:	e9 70 f5 ff ff       	jmp    8010603b <alltraps>

80106acb <vector108>:
.globl vector108
vector108:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $108
80106acd:	6a 6c                	push   $0x6c
  jmp alltraps
80106acf:	e9 67 f5 ff ff       	jmp    8010603b <alltraps>

80106ad4 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $109
80106ad6:	6a 6d                	push   $0x6d
  jmp alltraps
80106ad8:	e9 5e f5 ff ff       	jmp    8010603b <alltraps>

80106add <vector110>:
.globl vector110
vector110:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $110
80106adf:	6a 6e                	push   $0x6e
  jmp alltraps
80106ae1:	e9 55 f5 ff ff       	jmp    8010603b <alltraps>

80106ae6 <vector111>:
.globl vector111
vector111:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $111
80106ae8:	6a 6f                	push   $0x6f
  jmp alltraps
80106aea:	e9 4c f5 ff ff       	jmp    8010603b <alltraps>

80106aef <vector112>:
.globl vector112
vector112:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $112
80106af1:	6a 70                	push   $0x70
  jmp alltraps
80106af3:	e9 43 f5 ff ff       	jmp    8010603b <alltraps>

80106af8 <vector113>:
.globl vector113
vector113:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $113
80106afa:	6a 71                	push   $0x71
  jmp alltraps
80106afc:	e9 3a f5 ff ff       	jmp    8010603b <alltraps>

80106b01 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $114
80106b03:	6a 72                	push   $0x72
  jmp alltraps
80106b05:	e9 31 f5 ff ff       	jmp    8010603b <alltraps>

80106b0a <vector115>:
.globl vector115
vector115:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $115
80106b0c:	6a 73                	push   $0x73
  jmp alltraps
80106b0e:	e9 28 f5 ff ff       	jmp    8010603b <alltraps>

80106b13 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $116
80106b15:	6a 74                	push   $0x74
  jmp alltraps
80106b17:	e9 1f f5 ff ff       	jmp    8010603b <alltraps>

80106b1c <vector117>:
.globl vector117
vector117:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $117
80106b1e:	6a 75                	push   $0x75
  jmp alltraps
80106b20:	e9 16 f5 ff ff       	jmp    8010603b <alltraps>

80106b25 <vector118>:
.globl vector118
vector118:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $118
80106b27:	6a 76                	push   $0x76
  jmp alltraps
80106b29:	e9 0d f5 ff ff       	jmp    8010603b <alltraps>

80106b2e <vector119>:
.globl vector119
vector119:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $119
80106b30:	6a 77                	push   $0x77
  jmp alltraps
80106b32:	e9 04 f5 ff ff       	jmp    8010603b <alltraps>

80106b37 <vector120>:
.globl vector120
vector120:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $120
80106b39:	6a 78                	push   $0x78
  jmp alltraps
80106b3b:	e9 fb f4 ff ff       	jmp    8010603b <alltraps>

80106b40 <vector121>:
.globl vector121
vector121:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $121
80106b42:	6a 79                	push   $0x79
  jmp alltraps
80106b44:	e9 f2 f4 ff ff       	jmp    8010603b <alltraps>

80106b49 <vector122>:
.globl vector122
vector122:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $122
80106b4b:	6a 7a                	push   $0x7a
  jmp alltraps
80106b4d:	e9 e9 f4 ff ff       	jmp    8010603b <alltraps>

80106b52 <vector123>:
.globl vector123
vector123:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $123
80106b54:	6a 7b                	push   $0x7b
  jmp alltraps
80106b56:	e9 e0 f4 ff ff       	jmp    8010603b <alltraps>

80106b5b <vector124>:
.globl vector124
vector124:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $124
80106b5d:	6a 7c                	push   $0x7c
  jmp alltraps
80106b5f:	e9 d7 f4 ff ff       	jmp    8010603b <alltraps>

80106b64 <vector125>:
.globl vector125
vector125:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $125
80106b66:	6a 7d                	push   $0x7d
  jmp alltraps
80106b68:	e9 ce f4 ff ff       	jmp    8010603b <alltraps>

80106b6d <vector126>:
.globl vector126
vector126:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $126
80106b6f:	6a 7e                	push   $0x7e
  jmp alltraps
80106b71:	e9 c5 f4 ff ff       	jmp    8010603b <alltraps>

80106b76 <vector127>:
.globl vector127
vector127:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $127
80106b78:	6a 7f                	push   $0x7f
  jmp alltraps
80106b7a:	e9 bc f4 ff ff       	jmp    8010603b <alltraps>

80106b7f <vector128>:
.globl vector128
vector128:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $128
80106b81:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106b86:	e9 b0 f4 ff ff       	jmp    8010603b <alltraps>

80106b8b <vector129>:
.globl vector129
vector129:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $129
80106b8d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b92:	e9 a4 f4 ff ff       	jmp    8010603b <alltraps>

80106b97 <vector130>:
.globl vector130
vector130:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $130
80106b99:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b9e:	e9 98 f4 ff ff       	jmp    8010603b <alltraps>

80106ba3 <vector131>:
.globl vector131
vector131:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $131
80106ba5:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106baa:	e9 8c f4 ff ff       	jmp    8010603b <alltraps>

80106baf <vector132>:
.globl vector132
vector132:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $132
80106bb1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106bb6:	e9 80 f4 ff ff       	jmp    8010603b <alltraps>

80106bbb <vector133>:
.globl vector133
vector133:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $133
80106bbd:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106bc2:	e9 74 f4 ff ff       	jmp    8010603b <alltraps>

80106bc7 <vector134>:
.globl vector134
vector134:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $134
80106bc9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106bce:	e9 68 f4 ff ff       	jmp    8010603b <alltraps>

80106bd3 <vector135>:
.globl vector135
vector135:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $135
80106bd5:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106bda:	e9 5c f4 ff ff       	jmp    8010603b <alltraps>

80106bdf <vector136>:
.globl vector136
vector136:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $136
80106be1:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106be6:	e9 50 f4 ff ff       	jmp    8010603b <alltraps>

80106beb <vector137>:
.globl vector137
vector137:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $137
80106bed:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106bf2:	e9 44 f4 ff ff       	jmp    8010603b <alltraps>

80106bf7 <vector138>:
.globl vector138
vector138:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $138
80106bf9:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106bfe:	e9 38 f4 ff ff       	jmp    8010603b <alltraps>

80106c03 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $139
80106c05:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c0a:	e9 2c f4 ff ff       	jmp    8010603b <alltraps>

80106c0f <vector140>:
.globl vector140
vector140:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $140
80106c11:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c16:	e9 20 f4 ff ff       	jmp    8010603b <alltraps>

80106c1b <vector141>:
.globl vector141
vector141:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $141
80106c1d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106c22:	e9 14 f4 ff ff       	jmp    8010603b <alltraps>

80106c27 <vector142>:
.globl vector142
vector142:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $142
80106c29:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106c2e:	e9 08 f4 ff ff       	jmp    8010603b <alltraps>

80106c33 <vector143>:
.globl vector143
vector143:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $143
80106c35:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106c3a:	e9 fc f3 ff ff       	jmp    8010603b <alltraps>

80106c3f <vector144>:
.globl vector144
vector144:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $144
80106c41:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106c46:	e9 f0 f3 ff ff       	jmp    8010603b <alltraps>

80106c4b <vector145>:
.globl vector145
vector145:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $145
80106c4d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106c52:	e9 e4 f3 ff ff       	jmp    8010603b <alltraps>

80106c57 <vector146>:
.globl vector146
vector146:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $146
80106c59:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106c5e:	e9 d8 f3 ff ff       	jmp    8010603b <alltraps>

80106c63 <vector147>:
.globl vector147
vector147:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $147
80106c65:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106c6a:	e9 cc f3 ff ff       	jmp    8010603b <alltraps>

80106c6f <vector148>:
.globl vector148
vector148:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $148
80106c71:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106c76:	e9 c0 f3 ff ff       	jmp    8010603b <alltraps>

80106c7b <vector149>:
.globl vector149
vector149:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $149
80106c7d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106c82:	e9 b4 f3 ff ff       	jmp    8010603b <alltraps>

80106c87 <vector150>:
.globl vector150
vector150:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $150
80106c89:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c8e:	e9 a8 f3 ff ff       	jmp    8010603b <alltraps>

80106c93 <vector151>:
.globl vector151
vector151:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $151
80106c95:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c9a:	e9 9c f3 ff ff       	jmp    8010603b <alltraps>

80106c9f <vector152>:
.globl vector152
vector152:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $152
80106ca1:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106ca6:	e9 90 f3 ff ff       	jmp    8010603b <alltraps>

80106cab <vector153>:
.globl vector153
vector153:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $153
80106cad:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106cb2:	e9 84 f3 ff ff       	jmp    8010603b <alltraps>

80106cb7 <vector154>:
.globl vector154
vector154:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $154
80106cb9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106cbe:	e9 78 f3 ff ff       	jmp    8010603b <alltraps>

80106cc3 <vector155>:
.globl vector155
vector155:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $155
80106cc5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106cca:	e9 6c f3 ff ff       	jmp    8010603b <alltraps>

80106ccf <vector156>:
.globl vector156
vector156:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $156
80106cd1:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106cd6:	e9 60 f3 ff ff       	jmp    8010603b <alltraps>

80106cdb <vector157>:
.globl vector157
vector157:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $157
80106cdd:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106ce2:	e9 54 f3 ff ff       	jmp    8010603b <alltraps>

80106ce7 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $158
80106ce9:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106cee:	e9 48 f3 ff ff       	jmp    8010603b <alltraps>

80106cf3 <vector159>:
.globl vector159
vector159:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $159
80106cf5:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106cfa:	e9 3c f3 ff ff       	jmp    8010603b <alltraps>

80106cff <vector160>:
.globl vector160
vector160:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $160
80106d01:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d06:	e9 30 f3 ff ff       	jmp    8010603b <alltraps>

80106d0b <vector161>:
.globl vector161
vector161:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $161
80106d0d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d12:	e9 24 f3 ff ff       	jmp    8010603b <alltraps>

80106d17 <vector162>:
.globl vector162
vector162:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $162
80106d19:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d1e:	e9 18 f3 ff ff       	jmp    8010603b <alltraps>

80106d23 <vector163>:
.globl vector163
vector163:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $163
80106d25:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106d2a:	e9 0c f3 ff ff       	jmp    8010603b <alltraps>

80106d2f <vector164>:
.globl vector164
vector164:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $164
80106d31:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106d36:	e9 00 f3 ff ff       	jmp    8010603b <alltraps>

80106d3b <vector165>:
.globl vector165
vector165:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $165
80106d3d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106d42:	e9 f4 f2 ff ff       	jmp    8010603b <alltraps>

80106d47 <vector166>:
.globl vector166
vector166:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $166
80106d49:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106d4e:	e9 e8 f2 ff ff       	jmp    8010603b <alltraps>

80106d53 <vector167>:
.globl vector167
vector167:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $167
80106d55:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106d5a:	e9 dc f2 ff ff       	jmp    8010603b <alltraps>

80106d5f <vector168>:
.globl vector168
vector168:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $168
80106d61:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106d66:	e9 d0 f2 ff ff       	jmp    8010603b <alltraps>

80106d6b <vector169>:
.globl vector169
vector169:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $169
80106d6d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106d72:	e9 c4 f2 ff ff       	jmp    8010603b <alltraps>

80106d77 <vector170>:
.globl vector170
vector170:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $170
80106d79:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106d7e:	e9 b8 f2 ff ff       	jmp    8010603b <alltraps>

80106d83 <vector171>:
.globl vector171
vector171:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $171
80106d85:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d8a:	e9 ac f2 ff ff       	jmp    8010603b <alltraps>

80106d8f <vector172>:
.globl vector172
vector172:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $172
80106d91:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d96:	e9 a0 f2 ff ff       	jmp    8010603b <alltraps>

80106d9b <vector173>:
.globl vector173
vector173:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $173
80106d9d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106da2:	e9 94 f2 ff ff       	jmp    8010603b <alltraps>

80106da7 <vector174>:
.globl vector174
vector174:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $174
80106da9:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106dae:	e9 88 f2 ff ff       	jmp    8010603b <alltraps>

80106db3 <vector175>:
.globl vector175
vector175:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $175
80106db5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106dba:	e9 7c f2 ff ff       	jmp    8010603b <alltraps>

80106dbf <vector176>:
.globl vector176
vector176:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $176
80106dc1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106dc6:	e9 70 f2 ff ff       	jmp    8010603b <alltraps>

80106dcb <vector177>:
.globl vector177
vector177:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $177
80106dcd:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106dd2:	e9 64 f2 ff ff       	jmp    8010603b <alltraps>

80106dd7 <vector178>:
.globl vector178
vector178:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $178
80106dd9:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106dde:	e9 58 f2 ff ff       	jmp    8010603b <alltraps>

80106de3 <vector179>:
.globl vector179
vector179:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $179
80106de5:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106dea:	e9 4c f2 ff ff       	jmp    8010603b <alltraps>

80106def <vector180>:
.globl vector180
vector180:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $180
80106df1:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106df6:	e9 40 f2 ff ff       	jmp    8010603b <alltraps>

80106dfb <vector181>:
.globl vector181
vector181:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $181
80106dfd:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e02:	e9 34 f2 ff ff       	jmp    8010603b <alltraps>

80106e07 <vector182>:
.globl vector182
vector182:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $182
80106e09:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e0e:	e9 28 f2 ff ff       	jmp    8010603b <alltraps>

80106e13 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $183
80106e15:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e1a:	e9 1c f2 ff ff       	jmp    8010603b <alltraps>

80106e1f <vector184>:
.globl vector184
vector184:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $184
80106e21:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106e26:	e9 10 f2 ff ff       	jmp    8010603b <alltraps>

80106e2b <vector185>:
.globl vector185
vector185:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $185
80106e2d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106e32:	e9 04 f2 ff ff       	jmp    8010603b <alltraps>

80106e37 <vector186>:
.globl vector186
vector186:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $186
80106e39:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106e3e:	e9 f8 f1 ff ff       	jmp    8010603b <alltraps>

80106e43 <vector187>:
.globl vector187
vector187:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $187
80106e45:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106e4a:	e9 ec f1 ff ff       	jmp    8010603b <alltraps>

80106e4f <vector188>:
.globl vector188
vector188:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $188
80106e51:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106e56:	e9 e0 f1 ff ff       	jmp    8010603b <alltraps>

80106e5b <vector189>:
.globl vector189
vector189:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $189
80106e5d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106e62:	e9 d4 f1 ff ff       	jmp    8010603b <alltraps>

80106e67 <vector190>:
.globl vector190
vector190:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $190
80106e69:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106e6e:	e9 c8 f1 ff ff       	jmp    8010603b <alltraps>

80106e73 <vector191>:
.globl vector191
vector191:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $191
80106e75:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106e7a:	e9 bc f1 ff ff       	jmp    8010603b <alltraps>

80106e7f <vector192>:
.globl vector192
vector192:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $192
80106e81:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106e86:	e9 b0 f1 ff ff       	jmp    8010603b <alltraps>

80106e8b <vector193>:
.globl vector193
vector193:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $193
80106e8d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e92:	e9 a4 f1 ff ff       	jmp    8010603b <alltraps>

80106e97 <vector194>:
.globl vector194
vector194:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $194
80106e99:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e9e:	e9 98 f1 ff ff       	jmp    8010603b <alltraps>

80106ea3 <vector195>:
.globl vector195
vector195:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $195
80106ea5:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106eaa:	e9 8c f1 ff ff       	jmp    8010603b <alltraps>

80106eaf <vector196>:
.globl vector196
vector196:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $196
80106eb1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106eb6:	e9 80 f1 ff ff       	jmp    8010603b <alltraps>

80106ebb <vector197>:
.globl vector197
vector197:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $197
80106ebd:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106ec2:	e9 74 f1 ff ff       	jmp    8010603b <alltraps>

80106ec7 <vector198>:
.globl vector198
vector198:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $198
80106ec9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106ece:	e9 68 f1 ff ff       	jmp    8010603b <alltraps>

80106ed3 <vector199>:
.globl vector199
vector199:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $199
80106ed5:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106eda:	e9 5c f1 ff ff       	jmp    8010603b <alltraps>

80106edf <vector200>:
.globl vector200
vector200:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $200
80106ee1:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106ee6:	e9 50 f1 ff ff       	jmp    8010603b <alltraps>

80106eeb <vector201>:
.globl vector201
vector201:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $201
80106eed:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106ef2:	e9 44 f1 ff ff       	jmp    8010603b <alltraps>

80106ef7 <vector202>:
.globl vector202
vector202:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $202
80106ef9:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106efe:	e9 38 f1 ff ff       	jmp    8010603b <alltraps>

80106f03 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $203
80106f05:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f0a:	e9 2c f1 ff ff       	jmp    8010603b <alltraps>

80106f0f <vector204>:
.globl vector204
vector204:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $204
80106f11:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f16:	e9 20 f1 ff ff       	jmp    8010603b <alltraps>

80106f1b <vector205>:
.globl vector205
vector205:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $205
80106f1d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106f22:	e9 14 f1 ff ff       	jmp    8010603b <alltraps>

80106f27 <vector206>:
.globl vector206
vector206:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $206
80106f29:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106f2e:	e9 08 f1 ff ff       	jmp    8010603b <alltraps>

80106f33 <vector207>:
.globl vector207
vector207:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $207
80106f35:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106f3a:	e9 fc f0 ff ff       	jmp    8010603b <alltraps>

80106f3f <vector208>:
.globl vector208
vector208:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $208
80106f41:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106f46:	e9 f0 f0 ff ff       	jmp    8010603b <alltraps>

80106f4b <vector209>:
.globl vector209
vector209:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $209
80106f4d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106f52:	e9 e4 f0 ff ff       	jmp    8010603b <alltraps>

80106f57 <vector210>:
.globl vector210
vector210:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $210
80106f59:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106f5e:	e9 d8 f0 ff ff       	jmp    8010603b <alltraps>

80106f63 <vector211>:
.globl vector211
vector211:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $211
80106f65:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106f6a:	e9 cc f0 ff ff       	jmp    8010603b <alltraps>

80106f6f <vector212>:
.globl vector212
vector212:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $212
80106f71:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106f76:	e9 c0 f0 ff ff       	jmp    8010603b <alltraps>

80106f7b <vector213>:
.globl vector213
vector213:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $213
80106f7d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106f82:	e9 b4 f0 ff ff       	jmp    8010603b <alltraps>

80106f87 <vector214>:
.globl vector214
vector214:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $214
80106f89:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f8e:	e9 a8 f0 ff ff       	jmp    8010603b <alltraps>

80106f93 <vector215>:
.globl vector215
vector215:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $215
80106f95:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f9a:	e9 9c f0 ff ff       	jmp    8010603b <alltraps>

80106f9f <vector216>:
.globl vector216
vector216:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $216
80106fa1:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106fa6:	e9 90 f0 ff ff       	jmp    8010603b <alltraps>

80106fab <vector217>:
.globl vector217
vector217:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $217
80106fad:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106fb2:	e9 84 f0 ff ff       	jmp    8010603b <alltraps>

80106fb7 <vector218>:
.globl vector218
vector218:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $218
80106fb9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106fbe:	e9 78 f0 ff ff       	jmp    8010603b <alltraps>

80106fc3 <vector219>:
.globl vector219
vector219:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $219
80106fc5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106fca:	e9 6c f0 ff ff       	jmp    8010603b <alltraps>

80106fcf <vector220>:
.globl vector220
vector220:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $220
80106fd1:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106fd6:	e9 60 f0 ff ff       	jmp    8010603b <alltraps>

80106fdb <vector221>:
.globl vector221
vector221:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $221
80106fdd:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106fe2:	e9 54 f0 ff ff       	jmp    8010603b <alltraps>

80106fe7 <vector222>:
.globl vector222
vector222:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $222
80106fe9:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106fee:	e9 48 f0 ff ff       	jmp    8010603b <alltraps>

80106ff3 <vector223>:
.globl vector223
vector223:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $223
80106ff5:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106ffa:	e9 3c f0 ff ff       	jmp    8010603b <alltraps>

80106fff <vector224>:
.globl vector224
vector224:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $224
80107001:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107006:	e9 30 f0 ff ff       	jmp    8010603b <alltraps>

8010700b <vector225>:
.globl vector225
vector225:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $225
8010700d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107012:	e9 24 f0 ff ff       	jmp    8010603b <alltraps>

80107017 <vector226>:
.globl vector226
vector226:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $226
80107019:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010701e:	e9 18 f0 ff ff       	jmp    8010603b <alltraps>

80107023 <vector227>:
.globl vector227
vector227:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $227
80107025:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010702a:	e9 0c f0 ff ff       	jmp    8010603b <alltraps>

8010702f <vector228>:
.globl vector228
vector228:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $228
80107031:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107036:	e9 00 f0 ff ff       	jmp    8010603b <alltraps>

8010703b <vector229>:
.globl vector229
vector229:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $229
8010703d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107042:	e9 f4 ef ff ff       	jmp    8010603b <alltraps>

80107047 <vector230>:
.globl vector230
vector230:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $230
80107049:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010704e:	e9 e8 ef ff ff       	jmp    8010603b <alltraps>

80107053 <vector231>:
.globl vector231
vector231:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $231
80107055:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010705a:	e9 dc ef ff ff       	jmp    8010603b <alltraps>

8010705f <vector232>:
.globl vector232
vector232:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $232
80107061:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107066:	e9 d0 ef ff ff       	jmp    8010603b <alltraps>

8010706b <vector233>:
.globl vector233
vector233:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $233
8010706d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107072:	e9 c4 ef ff ff       	jmp    8010603b <alltraps>

80107077 <vector234>:
.globl vector234
vector234:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $234
80107079:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010707e:	e9 b8 ef ff ff       	jmp    8010603b <alltraps>

80107083 <vector235>:
.globl vector235
vector235:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $235
80107085:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010708a:	e9 ac ef ff ff       	jmp    8010603b <alltraps>

8010708f <vector236>:
.globl vector236
vector236:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $236
80107091:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107096:	e9 a0 ef ff ff       	jmp    8010603b <alltraps>

8010709b <vector237>:
.globl vector237
vector237:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $237
8010709d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801070a2:	e9 94 ef ff ff       	jmp    8010603b <alltraps>

801070a7 <vector238>:
.globl vector238
vector238:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $238
801070a9:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801070ae:	e9 88 ef ff ff       	jmp    8010603b <alltraps>

801070b3 <vector239>:
.globl vector239
vector239:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $239
801070b5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801070ba:	e9 7c ef ff ff       	jmp    8010603b <alltraps>

801070bf <vector240>:
.globl vector240
vector240:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $240
801070c1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801070c6:	e9 70 ef ff ff       	jmp    8010603b <alltraps>

801070cb <vector241>:
.globl vector241
vector241:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $241
801070cd:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801070d2:	e9 64 ef ff ff       	jmp    8010603b <alltraps>

801070d7 <vector242>:
.globl vector242
vector242:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $242
801070d9:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801070de:	e9 58 ef ff ff       	jmp    8010603b <alltraps>

801070e3 <vector243>:
.globl vector243
vector243:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $243
801070e5:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801070ea:	e9 4c ef ff ff       	jmp    8010603b <alltraps>

801070ef <vector244>:
.globl vector244
vector244:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $244
801070f1:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801070f6:	e9 40 ef ff ff       	jmp    8010603b <alltraps>

801070fb <vector245>:
.globl vector245
vector245:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $245
801070fd:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107102:	e9 34 ef ff ff       	jmp    8010603b <alltraps>

80107107 <vector246>:
.globl vector246
vector246:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $246
80107109:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010710e:	e9 28 ef ff ff       	jmp    8010603b <alltraps>

80107113 <vector247>:
.globl vector247
vector247:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $247
80107115:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010711a:	e9 1c ef ff ff       	jmp    8010603b <alltraps>

8010711f <vector248>:
.globl vector248
vector248:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $248
80107121:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107126:	e9 10 ef ff ff       	jmp    8010603b <alltraps>

8010712b <vector249>:
.globl vector249
vector249:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $249
8010712d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107132:	e9 04 ef ff ff       	jmp    8010603b <alltraps>

80107137 <vector250>:
.globl vector250
vector250:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $250
80107139:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010713e:	e9 f8 ee ff ff       	jmp    8010603b <alltraps>

80107143 <vector251>:
.globl vector251
vector251:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $251
80107145:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010714a:	e9 ec ee ff ff       	jmp    8010603b <alltraps>

8010714f <vector252>:
.globl vector252
vector252:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $252
80107151:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107156:	e9 e0 ee ff ff       	jmp    8010603b <alltraps>

8010715b <vector253>:
.globl vector253
vector253:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $253
8010715d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107162:	e9 d4 ee ff ff       	jmp    8010603b <alltraps>

80107167 <vector254>:
.globl vector254
vector254:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $254
80107169:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010716e:	e9 c8 ee ff ff       	jmp    8010603b <alltraps>

80107173 <vector255>:
.globl vector255
vector255:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $255
80107175:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010717a:	e9 bc ee ff ff       	jmp    8010603b <alltraps>

8010717f <lgdt>:
{
8010717f:	55                   	push   %ebp
80107180:	89 e5                	mov    %esp,%ebp
80107182:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107185:	8b 45 0c             	mov    0xc(%ebp),%eax
80107188:	83 e8 01             	sub    $0x1,%eax
8010718b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010718f:	8b 45 08             	mov    0x8(%ebp),%eax
80107192:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107196:	8b 45 08             	mov    0x8(%ebp),%eax
80107199:	c1 e8 10             	shr    $0x10,%eax
8010719c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801071a0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071a3:	0f 01 10             	lgdtl  (%eax)
}
801071a6:	90                   	nop
801071a7:	c9                   	leave
801071a8:	c3                   	ret

801071a9 <ltr>:
{
801071a9:	55                   	push   %ebp
801071aa:	89 e5                	mov    %esp,%ebp
801071ac:	83 ec 04             	sub    $0x4,%esp
801071af:	8b 45 08             	mov    0x8(%ebp),%eax
801071b2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801071b6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801071ba:	0f 00 d8             	ltr    %eax
}
801071bd:	90                   	nop
801071be:	c9                   	leave
801071bf:	c3                   	ret

801071c0 <lcr3>:

static inline void
lcr3(uint val)
{
801071c0:	55                   	push   %ebp
801071c1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071c3:	8b 45 08             	mov    0x8(%ebp),%eax
801071c6:	0f 22 d8             	mov    %eax,%cr3
}
801071c9:	90                   	nop
801071ca:	5d                   	pop    %ebp
801071cb:	c3                   	ret

801071cc <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801071cc:	f3 0f 1e fb          	endbr32
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801071d6:	e8 33 c9 ff ff       	call   80103b0e <cpuid>
801071db:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801071e1:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
801071e6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801071e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ec:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801071f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f5:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801071fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fe:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107205:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107209:	83 e2 f0             	and    $0xfffffff0,%edx
8010720c:	83 ca 0a             	or     $0xa,%edx
8010720f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107215:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107219:	83 ca 10             	or     $0x10,%edx
8010721c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010721f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107222:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107226:	83 e2 9f             	and    $0xffffff9f,%edx
80107229:	88 50 7d             	mov    %dl,0x7d(%eax)
8010722c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107233:	83 ca 80             	or     $0xffffff80,%edx
80107236:	88 50 7d             	mov    %dl,0x7d(%eax)
80107239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107240:	83 ca 0f             	or     $0xf,%edx
80107243:	88 50 7e             	mov    %dl,0x7e(%eax)
80107246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107249:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010724d:	83 e2 ef             	and    $0xffffffef,%edx
80107250:	88 50 7e             	mov    %dl,0x7e(%eax)
80107253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107256:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010725a:	83 e2 df             	and    $0xffffffdf,%edx
8010725d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107263:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107267:	83 ca 40             	or     $0x40,%edx
8010726a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010726d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107270:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107274:	83 ca 80             	or     $0xffffff80,%edx
80107277:	88 50 7e             	mov    %dl,0x7e(%eax)
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107284:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010728b:	ff ff 
8010728d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107290:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107297:	00 00 
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801072a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072ad:	83 e2 f0             	and    $0xfffffff0,%edx
801072b0:	83 ca 02             	or     $0x2,%edx
801072b3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072c3:	83 ca 10             	or     $0x10,%edx
801072c6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072d6:	83 e2 9f             	and    $0xffffff9f,%edx
801072d9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072e9:	83 ca 80             	or     $0xffffff80,%edx
801072ec:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801072fc:	83 ca 0f             	or     $0xf,%edx
801072ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107308:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010730f:	83 e2 ef             	and    $0xffffffef,%edx
80107312:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107322:	83 e2 df             	and    $0xffffffdf,%edx
80107325:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010732b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107335:	83 ca 40             	or     $0x40,%edx
80107338:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010733e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107341:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107348:	83 ca 80             	or     $0xffffff80,%edx
8010734b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107354:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010735b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107365:	ff ff 
80107367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736a:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107371:	00 00 
80107373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107376:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010737d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107380:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107387:	83 e2 f0             	and    $0xfffffff0,%edx
8010738a:	83 ca 0a             	or     $0xa,%edx
8010738d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010739d:	83 ca 10             	or     $0x10,%edx
801073a0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073b0:	83 ca 60             	or     $0x60,%edx
801073b3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073c3:	83 ca 80             	or     $0xffffff80,%edx
801073c6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073d6:	83 ca 0f             	or     $0xf,%edx
801073d9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801073df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073e9:	83 e2 ef             	and    $0xffffffef,%edx
801073ec:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801073fc:	83 e2 df             	and    $0xffffffdf,%edx
801073ff:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107408:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010740f:	83 ca 40             	or     $0x40,%edx
80107412:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107422:	83 ca 80             	or     $0xffffff80,%edx
80107425:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107438:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010743f:	ff ff 
80107441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107444:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010744b:	00 00 
8010744d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107450:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107461:	83 e2 f0             	and    $0xfffffff0,%edx
80107464:	83 ca 02             	or     $0x2,%edx
80107467:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010746d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107470:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107477:	83 ca 10             	or     $0x10,%edx
8010747a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107483:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010748a:	83 ca 60             	or     $0x60,%edx
8010748d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107496:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010749d:	83 ca 80             	or     $0xffffff80,%edx
801074a0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074b0:	83 ca 0f             	or     $0xf,%edx
801074b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074c3:	83 e2 ef             	and    $0xffffffef,%edx
801074c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074cf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074d6:	83 e2 df             	and    $0xffffffdf,%edx
801074d9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074e9:	83 ca 40             	or     $0x40,%edx
801074ec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074fc:	83 ca 80             	or     $0xffffff80,%edx
801074ff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107508:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010750f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107512:	83 c0 70             	add    $0x70,%eax
80107515:	83 ec 08             	sub    $0x8,%esp
80107518:	6a 30                	push   $0x30
8010751a:	50                   	push   %eax
8010751b:	e8 5f fc ff ff       	call   8010717f <lgdt>
80107520:	83 c4 10             	add    $0x10,%esp
}
80107523:	90                   	nop
80107524:	c9                   	leave
80107525:	c3                   	ret

80107526 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107526:	f3 0f 1e fb          	endbr32
8010752a:	55                   	push   %ebp
8010752b:	89 e5                	mov    %esp,%ebp
8010752d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107530:	8b 45 0c             	mov    0xc(%ebp),%eax
80107533:	c1 e8 16             	shr    $0x16,%eax
80107536:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010753d:	8b 45 08             	mov    0x8(%ebp),%eax
80107540:	01 d0                	add    %edx,%eax
80107542:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107548:	8b 00                	mov    (%eax),%eax
8010754a:	83 e0 01             	and    $0x1,%eax
8010754d:	85 c0                	test   %eax,%eax
8010754f:	74 14                	je     80107565 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107554:	8b 00                	mov    (%eax),%eax
80107556:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010755b:	05 00 00 00 80       	add    $0x80000000,%eax
80107560:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107563:	eb 42                	jmp    801075a7 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107565:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107569:	74 0e                	je     80107579 <walkpgdir+0x53>
8010756b:	e8 22 b3 ff ff       	call   80102892 <kalloc>
80107570:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107573:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107577:	75 07                	jne    80107580 <walkpgdir+0x5a>
      return 0;
80107579:	b8 00 00 00 00       	mov    $0x0,%eax
8010757e:	eb 3e                	jmp    801075be <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107580:	83 ec 04             	sub    $0x4,%esp
80107583:	68 00 10 00 00       	push   $0x1000
80107588:	6a 00                	push   $0x0
8010758a:	ff 75 f4             	push   -0xc(%ebp)
8010758d:	e8 2d d6 ff ff       	call   80104bbf <memset>
80107592:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107598:	05 00 00 00 80       	add    $0x80000000,%eax
8010759d:	83 c8 07             	or     $0x7,%eax
801075a0:	89 c2                	mov    %eax,%edx
801075a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075a5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801075a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801075aa:	c1 e8 0c             	shr    $0xc,%eax
801075ad:	25 ff 03 00 00       	and    $0x3ff,%eax
801075b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801075b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bc:	01 d0                	add    %edx,%eax
}
801075be:	c9                   	leave
801075bf:	c3                   	ret

801075c0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801075c0:	f3 0f 1e fb          	endbr32
801075c4:	55                   	push   %ebp
801075c5:	89 e5                	mov    %esp,%ebp
801075c7:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801075ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801075cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801075d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801075d8:	8b 45 10             	mov    0x10(%ebp),%eax
801075db:	01 d0                	add    %edx,%eax
801075dd:	83 e8 01             	sub    $0x1,%eax
801075e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801075e8:	83 ec 04             	sub    $0x4,%esp
801075eb:	6a 01                	push   $0x1
801075ed:	ff 75 f4             	push   -0xc(%ebp)
801075f0:	ff 75 08             	push   0x8(%ebp)
801075f3:	e8 2e ff ff ff       	call   80107526 <walkpgdir>
801075f8:	83 c4 10             	add    $0x10,%esp
801075fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801075fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107602:	75 07                	jne    8010760b <mappages+0x4b>
      return -1;
80107604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107609:	eb 47                	jmp    80107652 <mappages+0x92>
    if(*pte & PTE_P)
8010760b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010760e:	8b 00                	mov    (%eax),%eax
80107610:	83 e0 01             	and    $0x1,%eax
80107613:	85 c0                	test   %eax,%eax
80107615:	74 0d                	je     80107624 <mappages+0x64>
      panic("remap");
80107617:	83 ec 0c             	sub    $0xc,%esp
8010761a:	68 08 aa 10 80       	push   $0x8010aa08
8010761f:	e8 a1 8f ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107624:	8b 45 18             	mov    0x18(%ebp),%eax
80107627:	0b 45 14             	or     0x14(%ebp),%eax
8010762a:	83 c8 01             	or     $0x1,%eax
8010762d:	89 c2                	mov    %eax,%edx
8010762f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107632:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107637:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010763a:	74 10                	je     8010764c <mappages+0x8c>
      break;
    a += PGSIZE;
8010763c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107643:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010764a:	eb 9c                	jmp    801075e8 <mappages+0x28>
      break;
8010764c:	90                   	nop
  }
  return 0;
8010764d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107652:	c9                   	leave
80107653:	c3                   	ret

80107654 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107654:	f3 0f 1e fb          	endbr32
80107658:	55                   	push   %ebp
80107659:	89 e5                	mov    %esp,%ebp
8010765b:	53                   	push   %ebx
8010765c:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010765f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107666:	a1 8c 81 19 80       	mov    0x8019818c,%eax
8010766b:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107670:	29 c2                	sub    %eax,%edx
80107672:	89 d0                	mov    %edx,%eax
80107674:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107677:	a1 84 81 19 80       	mov    0x80198184,%eax
8010767c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010767f:	8b 15 84 81 19 80    	mov    0x80198184,%edx
80107685:	a1 8c 81 19 80       	mov    0x8019818c,%eax
8010768a:	01 d0                	add    %edx,%eax
8010768c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010768f:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107699:	83 c0 30             	add    $0x30,%eax
8010769c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010769f:	89 10                	mov    %edx,(%eax)
801076a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076a4:	89 50 04             	mov    %edx,0x4(%eax)
801076a7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076aa:	89 50 08             	mov    %edx,0x8(%eax)
801076ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801076b0:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801076b3:	e8 da b1 ff ff       	call   80102892 <kalloc>
801076b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076bf:	75 07                	jne    801076c8 <setupkvm+0x74>
    return 0;
801076c1:	b8 00 00 00 00       	mov    $0x0,%eax
801076c6:	eb 78                	jmp    80107740 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801076c8:	83 ec 04             	sub    $0x4,%esp
801076cb:	68 00 10 00 00       	push   $0x1000
801076d0:	6a 00                	push   $0x0
801076d2:	ff 75 f0             	push   -0x10(%ebp)
801076d5:	e8 e5 d4 ff ff       	call   80104bbf <memset>
801076da:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801076dd:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801076e4:	eb 4e                	jmp    80107734 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801076e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e9:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801076ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ef:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801076f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f5:	8b 58 08             	mov    0x8(%eax),%ebx
801076f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fb:	8b 40 04             	mov    0x4(%eax),%eax
801076fe:	29 c3                	sub    %eax,%ebx
80107700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107703:	8b 00                	mov    (%eax),%eax
80107705:	83 ec 0c             	sub    $0xc,%esp
80107708:	51                   	push   %ecx
80107709:	52                   	push   %edx
8010770a:	53                   	push   %ebx
8010770b:	50                   	push   %eax
8010770c:	ff 75 f0             	push   -0x10(%ebp)
8010770f:	e8 ac fe ff ff       	call   801075c0 <mappages>
80107714:	83 c4 20             	add    $0x20,%esp
80107717:	85 c0                	test   %eax,%eax
80107719:	79 15                	jns    80107730 <setupkvm+0xdc>
      freevm(pgdir);
8010771b:	83 ec 0c             	sub    $0xc,%esp
8010771e:	ff 75 f0             	push   -0x10(%ebp)
80107721:	e8 11 05 00 00       	call   80107c37 <freevm>
80107726:	83 c4 10             	add    $0x10,%esp
      return 0;
80107729:	b8 00 00 00 00       	mov    $0x0,%eax
8010772e:	eb 10                	jmp    80107740 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107730:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107734:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010773b:	72 a9                	jb     801076e6 <setupkvm+0x92>
    }
  return pgdir;
8010773d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107743:	c9                   	leave
80107744:	c3                   	ret

80107745 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107745:	f3 0f 1e fb          	endbr32
80107749:	55                   	push   %ebp
8010774a:	89 e5                	mov    %esp,%ebp
8010774c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010774f:	e8 00 ff ff ff       	call   80107654 <setupkvm>
80107754:	a3 84 7e 19 80       	mov    %eax,0x80197e84
  switchkvm();
80107759:	e8 03 00 00 00       	call   80107761 <switchkvm>
}
8010775e:	90                   	nop
8010775f:	c9                   	leave
80107760:	c3                   	ret

80107761 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107761:	f3 0f 1e fb          	endbr32
80107765:	55                   	push   %ebp
80107766:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107768:	a1 84 7e 19 80       	mov    0x80197e84,%eax
8010776d:	05 00 00 00 80       	add    $0x80000000,%eax
80107772:	50                   	push   %eax
80107773:	e8 48 fa ff ff       	call   801071c0 <lcr3>
80107778:	83 c4 04             	add    $0x4,%esp
}
8010777b:	90                   	nop
8010777c:	c9                   	leave
8010777d:	c3                   	ret

8010777e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010777e:	f3 0f 1e fb          	endbr32
80107782:	55                   	push   %ebp
80107783:	89 e5                	mov    %esp,%ebp
80107785:	56                   	push   %esi
80107786:	53                   	push   %ebx
80107787:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010778a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010778e:	75 0d                	jne    8010779d <switchuvm+0x1f>
    panic("switchuvm: no process");
80107790:	83 ec 0c             	sub    $0xc,%esp
80107793:	68 0e aa 10 80       	push   $0x8010aa0e
80107798:	e8 28 8e ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
8010779d:	8b 45 08             	mov    0x8(%ebp),%eax
801077a0:	8b 40 08             	mov    0x8(%eax),%eax
801077a3:	85 c0                	test   %eax,%eax
801077a5:	75 0d                	jne    801077b4 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801077a7:	83 ec 0c             	sub    $0xc,%esp
801077aa:	68 24 aa 10 80       	push   $0x8010aa24
801077af:	e8 11 8e ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801077b4:	8b 45 08             	mov    0x8(%ebp),%eax
801077b7:	8b 40 04             	mov    0x4(%eax),%eax
801077ba:	85 c0                	test   %eax,%eax
801077bc:	75 0d                	jne    801077cb <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801077be:	83 ec 0c             	sub    $0xc,%esp
801077c1:	68 39 aa 10 80       	push   $0x8010aa39
801077c6:	e8 fa 8d ff ff       	call   801005c5 <panic>

  pushcli();
801077cb:	e8 dc d2 ff ff       	call   80104aac <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801077d0:	e8 58 c3 ff ff       	call   80103b2d <mycpu>
801077d5:	89 c3                	mov    %eax,%ebx
801077d7:	e8 51 c3 ff ff       	call   80103b2d <mycpu>
801077dc:	83 c0 08             	add    $0x8,%eax
801077df:	89 c6                	mov    %eax,%esi
801077e1:	e8 47 c3 ff ff       	call   80103b2d <mycpu>
801077e6:	83 c0 08             	add    $0x8,%eax
801077e9:	c1 e8 10             	shr    $0x10,%eax
801077ec:	88 45 f7             	mov    %al,-0x9(%ebp)
801077ef:	e8 39 c3 ff ff       	call   80103b2d <mycpu>
801077f4:	83 c0 08             	add    $0x8,%eax
801077f7:	c1 e8 18             	shr    $0x18,%eax
801077fa:	89 c2                	mov    %eax,%edx
801077fc:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107803:	67 00 
80107805:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010780c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107810:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107816:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010781d:	83 e0 f0             	and    $0xfffffff0,%eax
80107820:	83 c8 09             	or     $0x9,%eax
80107823:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107829:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107830:	83 c8 10             	or     $0x10,%eax
80107833:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107839:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107840:	83 e0 9f             	and    $0xffffff9f,%eax
80107843:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107849:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107850:	83 c8 80             	or     $0xffffff80,%eax
80107853:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107859:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107860:	83 e0 f0             	and    $0xfffffff0,%eax
80107863:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107869:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107870:	83 e0 ef             	and    $0xffffffef,%eax
80107873:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107879:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107880:	83 e0 df             	and    $0xffffffdf,%eax
80107883:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107889:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107890:	83 c8 40             	or     $0x40,%eax
80107893:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107899:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078a0:	83 e0 7f             	and    $0x7f,%eax
801078a3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078a9:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801078af:	e8 79 c2 ff ff       	call   80103b2d <mycpu>
801078b4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801078bb:	83 e2 ef             	and    $0xffffffef,%edx
801078be:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801078c4:	e8 64 c2 ff ff       	call   80103b2d <mycpu>
801078c9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801078cf:	8b 45 08             	mov    0x8(%ebp),%eax
801078d2:	8b 40 08             	mov    0x8(%eax),%eax
801078d5:	89 c3                	mov    %eax,%ebx
801078d7:	e8 51 c2 ff ff       	call   80103b2d <mycpu>
801078dc:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801078e2:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801078e5:	e8 43 c2 ff ff       	call   80103b2d <mycpu>
801078ea:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801078f0:	83 ec 0c             	sub    $0xc,%esp
801078f3:	6a 28                	push   $0x28
801078f5:	e8 af f8 ff ff       	call   801071a9 <ltr>
801078fa:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801078fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107900:	8b 40 04             	mov    0x4(%eax),%eax
80107903:	05 00 00 00 80       	add    $0x80000000,%eax
80107908:	83 ec 0c             	sub    $0xc,%esp
8010790b:	50                   	push   %eax
8010790c:	e8 af f8 ff ff       	call   801071c0 <lcr3>
80107911:	83 c4 10             	add    $0x10,%esp
  popcli();
80107914:	e8 e4 d1 ff ff       	call   80104afd <popcli>
}
80107919:	90                   	nop
8010791a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010791d:	5b                   	pop    %ebx
8010791e:	5e                   	pop    %esi
8010791f:	5d                   	pop    %ebp
80107920:	c3                   	ret

80107921 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107921:	f3 0f 1e fb          	endbr32
80107925:	55                   	push   %ebp
80107926:	89 e5                	mov    %esp,%ebp
80107928:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010792b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107932:	76 0d                	jbe    80107941 <inituvm+0x20>
    panic("inituvm: more than a page");
80107934:	83 ec 0c             	sub    $0xc,%esp
80107937:	68 4d aa 10 80       	push   $0x8010aa4d
8010793c:	e8 84 8c ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107941:	e8 4c af ff ff       	call   80102892 <kalloc>
80107946:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107949:	83 ec 04             	sub    $0x4,%esp
8010794c:	68 00 10 00 00       	push   $0x1000
80107951:	6a 00                	push   $0x0
80107953:	ff 75 f4             	push   -0xc(%ebp)
80107956:	e8 64 d2 ff ff       	call   80104bbf <memset>
8010795b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010795e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107961:	05 00 00 00 80       	add    $0x80000000,%eax
80107966:	83 ec 0c             	sub    $0xc,%esp
80107969:	6a 06                	push   $0x6
8010796b:	50                   	push   %eax
8010796c:	68 00 10 00 00       	push   $0x1000
80107971:	6a 00                	push   $0x0
80107973:	ff 75 08             	push   0x8(%ebp)
80107976:	e8 45 fc ff ff       	call   801075c0 <mappages>
8010797b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010797e:	83 ec 04             	sub    $0x4,%esp
80107981:	ff 75 10             	push   0x10(%ebp)
80107984:	ff 75 0c             	push   0xc(%ebp)
80107987:	ff 75 f4             	push   -0xc(%ebp)
8010798a:	e8 f7 d2 ff ff       	call   80104c86 <memmove>
8010798f:	83 c4 10             	add    $0x10,%esp
}
80107992:	90                   	nop
80107993:	c9                   	leave
80107994:	c3                   	ret

80107995 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107995:	f3 0f 1e fb          	endbr32
80107999:	55                   	push   %ebp
8010799a:	89 e5                	mov    %esp,%ebp
8010799c:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010799f:	8b 45 0c             	mov    0xc(%ebp),%eax
801079a2:	25 ff 0f 00 00       	and    $0xfff,%eax
801079a7:	85 c0                	test   %eax,%eax
801079a9:	74 0d                	je     801079b8 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801079ab:	83 ec 0c             	sub    $0xc,%esp
801079ae:	68 68 aa 10 80       	push   $0x8010aa68
801079b3:	e8 0d 8c ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801079b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079bf:	e9 8f 00 00 00       	jmp    80107a53 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801079c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801079c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ca:	01 d0                	add    %edx,%eax
801079cc:	83 ec 04             	sub    $0x4,%esp
801079cf:	6a 00                	push   $0x0
801079d1:	50                   	push   %eax
801079d2:	ff 75 08             	push   0x8(%ebp)
801079d5:	e8 4c fb ff ff       	call   80107526 <walkpgdir>
801079da:	83 c4 10             	add    $0x10,%esp
801079dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079e4:	75 0d                	jne    801079f3 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801079e6:	83 ec 0c             	sub    $0xc,%esp
801079e9:	68 8b aa 10 80       	push   $0x8010aa8b
801079ee:	e8 d2 8b ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801079f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079f6:	8b 00                	mov    (%eax),%eax
801079f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107a00:	8b 45 18             	mov    0x18(%ebp),%eax
80107a03:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a06:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107a0b:	77 0b                	ja     80107a18 <loaduvm+0x83>
      n = sz - i;
80107a0d:	8b 45 18             	mov    0x18(%ebp),%eax
80107a10:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a16:	eb 07                	jmp    80107a1f <loaduvm+0x8a>
    else
      n = PGSIZE;
80107a18:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107a1f:	8b 55 14             	mov    0x14(%ebp),%edx
80107a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a25:	01 d0                	add    %edx,%eax
80107a27:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a2a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107a30:	ff 75 f0             	push   -0x10(%ebp)
80107a33:	50                   	push   %eax
80107a34:	52                   	push   %edx
80107a35:	ff 75 10             	push   0x10(%ebp)
80107a38:	e8 47 a5 ff ff       	call   80101f84 <readi>
80107a3d:	83 c4 10             	add    $0x10,%esp
80107a40:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107a43:	74 07                	je     80107a4c <loaduvm+0xb7>
      return -1;
80107a45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a4a:	eb 18                	jmp    80107a64 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107a4c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a56:	3b 45 18             	cmp    0x18(%ebp),%eax
80107a59:	0f 82 65 ff ff ff    	jb     801079c4 <loaduvm+0x2f>
  }
  return 0;
80107a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a64:	c9                   	leave
80107a65:	c3                   	ret

80107a66 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a66:	f3 0f 1e fb          	endbr32
80107a6a:	55                   	push   %ebp
80107a6b:	89 e5                	mov    %esp,%ebp
80107a6d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107a70:	8b 45 10             	mov    0x10(%ebp),%eax
80107a73:	85 c0                	test   %eax,%eax
80107a75:	79 0a                	jns    80107a81 <allocuvm+0x1b>
    return 0;
80107a77:	b8 00 00 00 00       	mov    $0x0,%eax
80107a7c:	e9 ec 00 00 00       	jmp    80107b6d <allocuvm+0x107>
  if(newsz < oldsz)
80107a81:	8b 45 10             	mov    0x10(%ebp),%eax
80107a84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a87:	73 08                	jae    80107a91 <allocuvm+0x2b>
    return oldsz;
80107a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a8c:	e9 dc 00 00 00       	jmp    80107b6d <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a94:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107aa1:	e9 b8 00 00 00       	jmp    80107b5e <allocuvm+0xf8>
    mem = kalloc();
80107aa6:	e8 e7 ad ff ff       	call   80102892 <kalloc>
80107aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107aae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ab2:	75 2e                	jne    80107ae2 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107ab4:	83 ec 0c             	sub    $0xc,%esp
80107ab7:	68 a9 aa 10 80       	push   $0x8010aaa9
80107abc:	e8 4b 89 ff ff       	call   8010040c <cprintf>
80107ac1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ac4:	83 ec 04             	sub    $0x4,%esp
80107ac7:	ff 75 0c             	push   0xc(%ebp)
80107aca:	ff 75 10             	push   0x10(%ebp)
80107acd:	ff 75 08             	push   0x8(%ebp)
80107ad0:	e8 9a 00 00 00       	call   80107b6f <deallocuvm>
80107ad5:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ad8:	b8 00 00 00 00       	mov    $0x0,%eax
80107add:	e9 8b 00 00 00       	jmp    80107b6d <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107ae2:	83 ec 04             	sub    $0x4,%esp
80107ae5:	68 00 10 00 00       	push   $0x1000
80107aea:	6a 00                	push   $0x0
80107aec:	ff 75 f0             	push   -0x10(%ebp)
80107aef:	e8 cb d0 ff ff       	call   80104bbf <memset>
80107af4:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107afa:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b03:	83 ec 0c             	sub    $0xc,%esp
80107b06:	6a 06                	push   $0x6
80107b08:	52                   	push   %edx
80107b09:	68 00 10 00 00       	push   $0x1000
80107b0e:	50                   	push   %eax
80107b0f:	ff 75 08             	push   0x8(%ebp)
80107b12:	e8 a9 fa ff ff       	call   801075c0 <mappages>
80107b17:	83 c4 20             	add    $0x20,%esp
80107b1a:	85 c0                	test   %eax,%eax
80107b1c:	79 39                	jns    80107b57 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107b1e:	83 ec 0c             	sub    $0xc,%esp
80107b21:	68 c1 aa 10 80       	push   $0x8010aac1
80107b26:	e8 e1 88 ff ff       	call   8010040c <cprintf>
80107b2b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107b2e:	83 ec 04             	sub    $0x4,%esp
80107b31:	ff 75 0c             	push   0xc(%ebp)
80107b34:	ff 75 10             	push   0x10(%ebp)
80107b37:	ff 75 08             	push   0x8(%ebp)
80107b3a:	e8 30 00 00 00       	call   80107b6f <deallocuvm>
80107b3f:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107b42:	83 ec 0c             	sub    $0xc,%esp
80107b45:	ff 75 f0             	push   -0x10(%ebp)
80107b48:	e8 a7 ac ff ff       	call   801027f4 <kfree>
80107b4d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b50:	b8 00 00 00 00       	mov    $0x0,%eax
80107b55:	eb 16                	jmp    80107b6d <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107b57:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	3b 45 10             	cmp    0x10(%ebp),%eax
80107b64:	0f 82 3c ff ff ff    	jb     80107aa6 <allocuvm+0x40>
    }
  }
  return newsz;
80107b6a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b6d:	c9                   	leave
80107b6e:	c3                   	ret

80107b6f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107b6f:	f3 0f 1e fb          	endbr32
80107b73:	55                   	push   %ebp
80107b74:	89 e5                	mov    %esp,%ebp
80107b76:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107b79:	8b 45 10             	mov    0x10(%ebp),%eax
80107b7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b7f:	72 08                	jb     80107b89 <deallocuvm+0x1a>
    return oldsz;
80107b81:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b84:	e9 ac 00 00 00       	jmp    80107c35 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107b89:	8b 45 10             	mov    0x10(%ebp),%eax
80107b8c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107b91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107b99:	e9 88 00 00 00       	jmp    80107c26 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	83 ec 04             	sub    $0x4,%esp
80107ba4:	6a 00                	push   $0x0
80107ba6:	50                   	push   %eax
80107ba7:	ff 75 08             	push   0x8(%ebp)
80107baa:	e8 77 f9 ff ff       	call   80107526 <walkpgdir>
80107baf:	83 c4 10             	add    $0x10,%esp
80107bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107bb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bb9:	75 16                	jne    80107bd1 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbe:	c1 e8 16             	shr    $0x16,%eax
80107bc1:	83 c0 01             	add    $0x1,%eax
80107bc4:	c1 e0 16             	shl    $0x16,%eax
80107bc7:	2d 00 10 00 00       	sub    $0x1000,%eax
80107bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bcf:	eb 4e                	jmp    80107c1f <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd4:	8b 00                	mov    (%eax),%eax
80107bd6:	83 e0 01             	and    $0x1,%eax
80107bd9:	85 c0                	test   %eax,%eax
80107bdb:	74 42                	je     80107c1f <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be0:	8b 00                	mov    (%eax),%eax
80107be2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107bea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bee:	75 0d                	jne    80107bfd <deallocuvm+0x8e>
        panic("kfree");
80107bf0:	83 ec 0c             	sub    $0xc,%esp
80107bf3:	68 dd aa 10 80       	push   $0x8010aadd
80107bf8:	e8 c8 89 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c00:	05 00 00 00 80       	add    $0x80000000,%eax
80107c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107c08:	83 ec 0c             	sub    $0xc,%esp
80107c0b:	ff 75 e8             	push   -0x18(%ebp)
80107c0e:	e8 e1 ab ff ff       	call   801027f4 <kfree>
80107c13:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107c1f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c29:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c2c:	0f 82 6c ff ff ff    	jb     80107b9e <deallocuvm+0x2f>
    }
  }
  return newsz;
80107c32:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c35:	c9                   	leave
80107c36:	c3                   	ret

80107c37 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107c37:	f3 0f 1e fb          	endbr32
80107c3b:	55                   	push   %ebp
80107c3c:	89 e5                	mov    %esp,%ebp
80107c3e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107c41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c45:	75 0d                	jne    80107c54 <freevm+0x1d>
    panic("freevm: no pgdir");
80107c47:	83 ec 0c             	sub    $0xc,%esp
80107c4a:	68 e3 aa 10 80       	push   $0x8010aae3
80107c4f:	e8 71 89 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107c54:	83 ec 04             	sub    $0x4,%esp
80107c57:	6a 00                	push   $0x0
80107c59:	68 00 00 00 80       	push   $0x80000000
80107c5e:	ff 75 08             	push   0x8(%ebp)
80107c61:	e8 09 ff ff ff       	call   80107b6f <deallocuvm>
80107c66:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c70:	eb 48                	jmp    80107cba <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7f:	01 d0                	add    %edx,%eax
80107c81:	8b 00                	mov    (%eax),%eax
80107c83:	83 e0 01             	and    $0x1,%eax
80107c86:	85 c0                	test   %eax,%eax
80107c88:	74 2c                	je     80107cb6 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c94:	8b 45 08             	mov    0x8(%ebp),%eax
80107c97:	01 d0                	add    %edx,%eax
80107c99:	8b 00                	mov    (%eax),%eax
80107c9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ca0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ca5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107ca8:	83 ec 0c             	sub    $0xc,%esp
80107cab:	ff 75 f0             	push   -0x10(%ebp)
80107cae:	e8 41 ab ff ff       	call   801027f4 <kfree>
80107cb3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107cb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cba:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107cc1:	76 af                	jbe    80107c72 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107cc3:	83 ec 0c             	sub    $0xc,%esp
80107cc6:	ff 75 08             	push   0x8(%ebp)
80107cc9:	e8 26 ab ff ff       	call   801027f4 <kfree>
80107cce:	83 c4 10             	add    $0x10,%esp
}
80107cd1:	90                   	nop
80107cd2:	c9                   	leave
80107cd3:	c3                   	ret

80107cd4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107cd4:	f3 0f 1e fb          	endbr32
80107cd8:	55                   	push   %ebp
80107cd9:	89 e5                	mov    %esp,%ebp
80107cdb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107cde:	83 ec 04             	sub    $0x4,%esp
80107ce1:	6a 00                	push   $0x0
80107ce3:	ff 75 0c             	push   0xc(%ebp)
80107ce6:	ff 75 08             	push   0x8(%ebp)
80107ce9:	e8 38 f8 ff ff       	call   80107526 <walkpgdir>
80107cee:	83 c4 10             	add    $0x10,%esp
80107cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107cf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cf8:	75 0d                	jne    80107d07 <clearpteu+0x33>
    panic("clearpteu");
80107cfa:	83 ec 0c             	sub    $0xc,%esp
80107cfd:	68 f4 aa 10 80       	push   $0x8010aaf4
80107d02:	e8 be 88 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	8b 00                	mov    (%eax),%eax
80107d0c:	83 e0 fb             	and    $0xfffffffb,%eax
80107d0f:	89 c2                	mov    %eax,%edx
80107d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d14:	89 10                	mov    %edx,(%eax)
}
80107d16:	90                   	nop
80107d17:	c9                   	leave
80107d18:	c3                   	ret

80107d19 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107d19:	f3 0f 1e fb          	endbr32
80107d1d:	55                   	push   %ebp
80107d1e:	89 e5                	mov    %esp,%ebp
80107d20:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107d23:	e8 2c f9 ff ff       	call   80107654 <setupkvm>
80107d28:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d2f:	75 0a                	jne    80107d3b <copyuvm+0x22>
    return 0;
80107d31:	b8 00 00 00 00       	mov    $0x0,%eax
80107d36:	e9 eb 00 00 00       	jmp    80107e26 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107d3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d42:	e9 b7 00 00 00       	jmp    80107dfe <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	83 ec 04             	sub    $0x4,%esp
80107d4d:	6a 00                	push   $0x0
80107d4f:	50                   	push   %eax
80107d50:	ff 75 08             	push   0x8(%ebp)
80107d53:	e8 ce f7 ff ff       	call   80107526 <walkpgdir>
80107d58:	83 c4 10             	add    $0x10,%esp
80107d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d5e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d62:	75 0d                	jne    80107d71 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107d64:	83 ec 0c             	sub    $0xc,%esp
80107d67:	68 fe aa 10 80       	push   $0x8010aafe
80107d6c:	e8 54 88 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107d71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d74:	8b 00                	mov    (%eax),%eax
80107d76:	83 e0 01             	and    $0x1,%eax
80107d79:	85 c0                	test   %eax,%eax
80107d7b:	75 0d                	jne    80107d8a <copyuvm+0x71>
      panic("copyuvm: page not present");
80107d7d:	83 ec 0c             	sub    $0xc,%esp
80107d80:	68 18 ab 10 80       	push   $0x8010ab18
80107d85:	e8 3b 88 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107d8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d8d:	8b 00                	mov    (%eax),%eax
80107d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d94:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9a:	8b 00                	mov    (%eax),%eax
80107d9c:	25 ff 0f 00 00       	and    $0xfff,%eax
80107da1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107da4:	e8 e9 aa ff ff       	call   80102892 <kalloc>
80107da9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107dac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107db0:	74 5d                	je     80107e0f <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107db5:	05 00 00 00 80       	add    $0x80000000,%eax
80107dba:	83 ec 04             	sub    $0x4,%esp
80107dbd:	68 00 10 00 00       	push   $0x1000
80107dc2:	50                   	push   %eax
80107dc3:	ff 75 e0             	push   -0x20(%ebp)
80107dc6:	e8 bb ce ff ff       	call   80104c86 <memmove>
80107dcb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107dce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107dd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107dd4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	83 ec 0c             	sub    $0xc,%esp
80107de0:	52                   	push   %edx
80107de1:	51                   	push   %ecx
80107de2:	68 00 10 00 00       	push   $0x1000
80107de7:	50                   	push   %eax
80107de8:	ff 75 f0             	push   -0x10(%ebp)
80107deb:	e8 d0 f7 ff ff       	call   801075c0 <mappages>
80107df0:	83 c4 20             	add    $0x20,%esp
80107df3:	85 c0                	test   %eax,%eax
80107df5:	78 1b                	js     80107e12 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107df7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e01:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e04:	0f 82 3d ff ff ff    	jb     80107d47 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0d:	eb 17                	jmp    80107e26 <copyuvm+0x10d>
      goto bad;
80107e0f:	90                   	nop
80107e10:	eb 01                	jmp    80107e13 <copyuvm+0xfa>
      goto bad;
80107e12:	90                   	nop

bad:
  freevm(d);
80107e13:	83 ec 0c             	sub    $0xc,%esp
80107e16:	ff 75 f0             	push   -0x10(%ebp)
80107e19:	e8 19 fe ff ff       	call   80107c37 <freevm>
80107e1e:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e26:	c9                   	leave
80107e27:	c3                   	ret

80107e28 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107e28:	f3 0f 1e fb          	endbr32
80107e2c:	55                   	push   %ebp
80107e2d:	89 e5                	mov    %esp,%ebp
80107e2f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e32:	83 ec 04             	sub    $0x4,%esp
80107e35:	6a 00                	push   $0x0
80107e37:	ff 75 0c             	push   0xc(%ebp)
80107e3a:	ff 75 08             	push   0x8(%ebp)
80107e3d:	e8 e4 f6 ff ff       	call   80107526 <walkpgdir>
80107e42:	83 c4 10             	add    $0x10,%esp
80107e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	8b 00                	mov    (%eax),%eax
80107e4d:	83 e0 01             	and    $0x1,%eax
80107e50:	85 c0                	test   %eax,%eax
80107e52:	75 07                	jne    80107e5b <uva2ka+0x33>
    return 0;
80107e54:	b8 00 00 00 00       	mov    $0x0,%eax
80107e59:	eb 22                	jmp    80107e7d <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	8b 00                	mov    (%eax),%eax
80107e60:	83 e0 04             	and    $0x4,%eax
80107e63:	85 c0                	test   %eax,%eax
80107e65:	75 07                	jne    80107e6e <uva2ka+0x46>
    return 0;
80107e67:	b8 00 00 00 00       	mov    $0x0,%eax
80107e6c:	eb 0f                	jmp    80107e7d <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	8b 00                	mov    (%eax),%eax
80107e73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e78:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107e7d:	c9                   	leave
80107e7e:	c3                   	ret

80107e7f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107e7f:	f3 0f 1e fb          	endbr32
80107e83:	55                   	push   %ebp
80107e84:	89 e5                	mov    %esp,%ebp
80107e86:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107e89:	8b 45 10             	mov    0x10(%ebp),%eax
80107e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107e8f:	eb 7f                	jmp    80107f10 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e99:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9f:	83 ec 08             	sub    $0x8,%esp
80107ea2:	50                   	push   %eax
80107ea3:	ff 75 08             	push   0x8(%ebp)
80107ea6:	e8 7d ff ff ff       	call   80107e28 <uva2ka>
80107eab:	83 c4 10             	add    $0x10,%esp
80107eae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107eb1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107eb5:	75 07                	jne    80107ebe <copyout+0x3f>
      return -1;
80107eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ebc:	eb 61                	jmp    80107f1f <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec1:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ec4:	05 00 10 00 00       	add    $0x1000,%eax
80107ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ecf:	3b 45 14             	cmp    0x14(%ebp),%eax
80107ed2:	76 06                	jbe    80107eda <copyout+0x5b>
      n = len;
80107ed4:	8b 45 14             	mov    0x14(%ebp),%eax
80107ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80107edd:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107ee0:	89 c2                	mov    %eax,%edx
80107ee2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ee5:	01 d0                	add    %edx,%eax
80107ee7:	83 ec 04             	sub    $0x4,%esp
80107eea:	ff 75 f0             	push   -0x10(%ebp)
80107eed:	ff 75 f4             	push   -0xc(%ebp)
80107ef0:	50                   	push   %eax
80107ef1:	e8 90 cd ff ff       	call   80104c86 <memmove>
80107ef6:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107efc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f02:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f08:	05 00 10 00 00       	add    $0x1000,%eax
80107f0d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107f10:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107f14:	0f 85 77 ff ff ff    	jne    80107e91 <copyout+0x12>
  }
  return 0;
80107f1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f1f:	c9                   	leave
80107f20:	c3                   	ret

80107f21 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107f21:	f3 0f 1e fb          	endbr32
80107f25:	55                   	push   %ebp
80107f26:	89 e5                	mov    %esp,%ebp
80107f28:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f2b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107f32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f35:	8b 40 08             	mov    0x8(%eax),%eax
80107f38:	05 00 00 00 80       	add    $0x80000000,%eax
80107f3d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107f40:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4a:	8b 40 24             	mov    0x24(%eax),%eax
80107f4d:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80107f52:	c7 05 80 81 19 80 00 	movl   $0x0,0x80198180
80107f59:	00 00 00 

  while(i<madt->len){
80107f5c:	90                   	nop
80107f5d:	e9 be 00 00 00       	jmp    80108020 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80107f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f68:	01 d0                	add    %edx,%eax
80107f6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f70:	0f b6 00             	movzbl (%eax),%eax
80107f73:	0f b6 c0             	movzbl %al,%eax
80107f76:	83 f8 05             	cmp    $0x5,%eax
80107f79:	0f 87 a1 00 00 00    	ja     80108020 <mpinit_uefi+0xff>
80107f7f:	8b 04 85 34 ab 10 80 	mov    -0x7fef54cc(,%eax,4),%eax
80107f86:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107f8f:	a1 80 81 19 80       	mov    0x80198180,%eax
80107f94:	83 f8 03             	cmp    $0x3,%eax
80107f97:	7f 28                	jg     80107fc1 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107f99:	8b 15 80 81 19 80    	mov    0x80198180,%edx
80107f9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fa2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107fa6:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107fac:	81 c2 c0 7e 19 80    	add    $0x80197ec0,%edx
80107fb2:	88 02                	mov    %al,(%edx)
          ncpu++;
80107fb4:	a1 80 81 19 80       	mov    0x80198180,%eax
80107fb9:	83 c0 01             	add    $0x1,%eax
80107fbc:	a3 80 81 19 80       	mov    %eax,0x80198180
        }
        i += lapic_entry->record_len;
80107fc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fc4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fc8:	0f b6 c0             	movzbl %al,%eax
80107fcb:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fce:	eb 50                	jmp    80108020 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fd9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107fdd:	a2 a0 7e 19 80       	mov    %al,0x80197ea0
        i += ioapic->record_len;
80107fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fe5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fe9:	0f b6 c0             	movzbl %al,%eax
80107fec:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fef:	eb 2f                	jmp    80108020 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107ff7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ffa:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ffe:	0f b6 c0             	movzbl %al,%eax
80108001:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108004:	eb 1a                	jmp    80108020 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108009:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010800c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010800f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108013:	0f b6 c0             	movzbl %al,%eax
80108016:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108019:	eb 05                	jmp    80108020 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
8010801b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010801f:	90                   	nop
  while(i<madt->len){
80108020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108023:	8b 40 04             	mov    0x4(%eax),%eax
80108026:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108029:	0f 82 33 ff ff ff    	jb     80107f62 <mpinit_uefi+0x41>
    }
  }

}
8010802f:	90                   	nop
80108030:	90                   	nop
80108031:	c9                   	leave
80108032:	c3                   	ret

80108033 <inb>:
{
80108033:	55                   	push   %ebp
80108034:	89 e5                	mov    %esp,%ebp
80108036:	83 ec 14             	sub    $0x14,%esp
80108039:	8b 45 08             	mov    0x8(%ebp),%eax
8010803c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108040:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108044:	89 c2                	mov    %eax,%edx
80108046:	ec                   	in     (%dx),%al
80108047:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010804a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010804e:	c9                   	leave
8010804f:	c3                   	ret

80108050 <outb>:
{
80108050:	55                   	push   %ebp
80108051:	89 e5                	mov    %esp,%ebp
80108053:	83 ec 08             	sub    $0x8,%esp
80108056:	8b 45 08             	mov    0x8(%ebp),%eax
80108059:	8b 55 0c             	mov    0xc(%ebp),%edx
8010805c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108060:	89 d0                	mov    %edx,%eax
80108062:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108065:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108069:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010806d:	ee                   	out    %al,(%dx)
}
8010806e:	90                   	nop
8010806f:	c9                   	leave
80108070:	c3                   	ret

80108071 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108071:	f3 0f 1e fb          	endbr32
80108075:	55                   	push   %ebp
80108076:	89 e5                	mov    %esp,%ebp
80108078:	83 ec 28             	sub    $0x28,%esp
8010807b:	8b 45 08             	mov    0x8(%ebp),%eax
8010807e:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108081:	6a 00                	push   $0x0
80108083:	68 fa 03 00 00       	push   $0x3fa
80108088:	e8 c3 ff ff ff       	call   80108050 <outb>
8010808d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108090:	68 80 00 00 00       	push   $0x80
80108095:	68 fb 03 00 00       	push   $0x3fb
8010809a:	e8 b1 ff ff ff       	call   80108050 <outb>
8010809f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801080a2:	6a 0c                	push   $0xc
801080a4:	68 f8 03 00 00       	push   $0x3f8
801080a9:	e8 a2 ff ff ff       	call   80108050 <outb>
801080ae:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801080b1:	6a 00                	push   $0x0
801080b3:	68 f9 03 00 00       	push   $0x3f9
801080b8:	e8 93 ff ff ff       	call   80108050 <outb>
801080bd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801080c0:	6a 03                	push   $0x3
801080c2:	68 fb 03 00 00       	push   $0x3fb
801080c7:	e8 84 ff ff ff       	call   80108050 <outb>
801080cc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801080cf:	6a 00                	push   $0x0
801080d1:	68 fc 03 00 00       	push   $0x3fc
801080d6:	e8 75 ff ff ff       	call   80108050 <outb>
801080db:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801080de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080e5:	eb 11                	jmp    801080f8 <uart_debug+0x87>
801080e7:	83 ec 0c             	sub    $0xc,%esp
801080ea:	6a 0a                	push   $0xa
801080ec:	e8 53 ab ff ff       	call   80102c44 <microdelay>
801080f1:	83 c4 10             	add    $0x10,%esp
801080f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080f8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801080fc:	7f 1a                	jg     80108118 <uart_debug+0xa7>
801080fe:	83 ec 0c             	sub    $0xc,%esp
80108101:	68 fd 03 00 00       	push   $0x3fd
80108106:	e8 28 ff ff ff       	call   80108033 <inb>
8010810b:	83 c4 10             	add    $0x10,%esp
8010810e:	0f b6 c0             	movzbl %al,%eax
80108111:	83 e0 20             	and    $0x20,%eax
80108114:	85 c0                	test   %eax,%eax
80108116:	74 cf                	je     801080e7 <uart_debug+0x76>
  outb(COM1+0, p);
80108118:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010811c:	0f b6 c0             	movzbl %al,%eax
8010811f:	83 ec 08             	sub    $0x8,%esp
80108122:	50                   	push   %eax
80108123:	68 f8 03 00 00       	push   $0x3f8
80108128:	e8 23 ff ff ff       	call   80108050 <outb>
8010812d:	83 c4 10             	add    $0x10,%esp
}
80108130:	90                   	nop
80108131:	c9                   	leave
80108132:	c3                   	ret

80108133 <uart_debugs>:

void uart_debugs(char *p){
80108133:	f3 0f 1e fb          	endbr32
80108137:	55                   	push   %ebp
80108138:	89 e5                	mov    %esp,%ebp
8010813a:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010813d:	eb 1b                	jmp    8010815a <uart_debugs+0x27>
    uart_debug(*p++);
8010813f:	8b 45 08             	mov    0x8(%ebp),%eax
80108142:	8d 50 01             	lea    0x1(%eax),%edx
80108145:	89 55 08             	mov    %edx,0x8(%ebp)
80108148:	0f b6 00             	movzbl (%eax),%eax
8010814b:	0f be c0             	movsbl %al,%eax
8010814e:	83 ec 0c             	sub    $0xc,%esp
80108151:	50                   	push   %eax
80108152:	e8 1a ff ff ff       	call   80108071 <uart_debug>
80108157:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010815a:	8b 45 08             	mov    0x8(%ebp),%eax
8010815d:	0f b6 00             	movzbl (%eax),%eax
80108160:	84 c0                	test   %al,%al
80108162:	75 db                	jne    8010813f <uart_debugs+0xc>
  }
}
80108164:	90                   	nop
80108165:	90                   	nop
80108166:	c9                   	leave
80108167:	c3                   	ret

80108168 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108168:	f3 0f 1e fb          	endbr32
8010816c:	55                   	push   %ebp
8010816d:	89 e5                	mov    %esp,%ebp
8010816f:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108172:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108179:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010817c:	8b 50 14             	mov    0x14(%eax),%edx
8010817f:	8b 40 10             	mov    0x10(%eax),%eax
80108182:	a3 84 81 19 80       	mov    %eax,0x80198184
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108187:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010818a:	8b 50 1c             	mov    0x1c(%eax),%edx
8010818d:	8b 40 18             	mov    0x18(%eax),%eax
80108190:	a3 8c 81 19 80       	mov    %eax,0x8019818c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108195:	a1 8c 81 19 80       	mov    0x8019818c,%eax
8010819a:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010819f:	29 c2                	sub    %eax,%edx
801081a1:	89 d0                	mov    %edx,%eax
801081a3:	a3 88 81 19 80       	mov    %eax,0x80198188
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801081a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081ab:	8b 50 24             	mov    0x24(%eax),%edx
801081ae:	8b 40 20             	mov    0x20(%eax),%eax
801081b1:	a3 90 81 19 80       	mov    %eax,0x80198190
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801081b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081b9:	8b 50 2c             	mov    0x2c(%eax),%edx
801081bc:	8b 40 28             	mov    0x28(%eax),%eax
801081bf:	a3 94 81 19 80       	mov    %eax,0x80198194
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801081c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081c7:	8b 50 34             	mov    0x34(%eax),%edx
801081ca:	8b 40 30             	mov    0x30(%eax),%eax
801081cd:	a3 98 81 19 80       	mov    %eax,0x80198198
}
801081d2:	90                   	nop
801081d3:	c9                   	leave
801081d4:	c3                   	ret

801081d5 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801081d5:	f3 0f 1e fb          	endbr32
801081d9:	55                   	push   %ebp
801081da:	89 e5                	mov    %esp,%ebp
801081dc:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801081df:	8b 15 98 81 19 80    	mov    0x80198198,%edx
801081e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801081e8:	0f af d0             	imul   %eax,%edx
801081eb:	8b 45 08             	mov    0x8(%ebp),%eax
801081ee:	01 d0                	add    %edx,%eax
801081f0:	c1 e0 02             	shl    $0x2,%eax
801081f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801081f6:	8b 15 88 81 19 80    	mov    0x80198188,%edx
801081fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081ff:	01 d0                	add    %edx,%eax
80108201:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108204:	8b 45 10             	mov    0x10(%ebp),%eax
80108207:	0f b6 10             	movzbl (%eax),%edx
8010820a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010820d:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010820f:	8b 45 10             	mov    0x10(%ebp),%eax
80108212:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108216:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108219:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010821c:	8b 45 10             	mov    0x10(%ebp),%eax
8010821f:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108223:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108226:	88 50 02             	mov    %dl,0x2(%eax)
}
80108229:	90                   	nop
8010822a:	c9                   	leave
8010822b:	c3                   	ret

8010822c <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010822c:	f3 0f 1e fb          	endbr32
80108230:	55                   	push   %ebp
80108231:	89 e5                	mov    %esp,%ebp
80108233:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108236:	8b 15 98 81 19 80    	mov    0x80198198,%edx
8010823c:	8b 45 08             	mov    0x8(%ebp),%eax
8010823f:	0f af c2             	imul   %edx,%eax
80108242:	c1 e0 02             	shl    $0x2,%eax
80108245:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108248:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
8010824e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108251:	29 c2                	sub    %eax,%edx
80108253:	89 d0                	mov    %edx,%eax
80108255:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
8010825b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010825e:	01 ca                	add    %ecx,%edx
80108260:	89 d1                	mov    %edx,%ecx
80108262:	8b 15 88 81 19 80    	mov    0x80198188,%edx
80108268:	83 ec 04             	sub    $0x4,%esp
8010826b:	50                   	push   %eax
8010826c:	51                   	push   %ecx
8010826d:	52                   	push   %edx
8010826e:	e8 13 ca ff ff       	call   80104c86 <memmove>
80108273:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108279:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
8010827f:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
80108285:	01 d1                	add    %edx,%ecx
80108287:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010828a:	29 d1                	sub    %edx,%ecx
8010828c:	89 ca                	mov    %ecx,%edx
8010828e:	83 ec 04             	sub    $0x4,%esp
80108291:	50                   	push   %eax
80108292:	6a 00                	push   $0x0
80108294:	52                   	push   %edx
80108295:	e8 25 c9 ff ff       	call   80104bbf <memset>
8010829a:	83 c4 10             	add    $0x10,%esp
}
8010829d:	90                   	nop
8010829e:	c9                   	leave
8010829f:	c3                   	ret

801082a0 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801082a0:	f3 0f 1e fb          	endbr32
801082a4:	55                   	push   %ebp
801082a5:	89 e5                	mov    %esp,%ebp
801082a7:	53                   	push   %ebx
801082a8:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801082ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082b2:	e9 b1 00 00 00       	jmp    80108368 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801082b7:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801082be:	e9 97 00 00 00       	jmp    8010835a <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801082c3:	8b 45 10             	mov    0x10(%ebp),%eax
801082c6:	83 e8 20             	sub    $0x20,%eax
801082c9:	6b d0 1e             	imul   $0x1e,%eax,%edx
801082cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cf:	01 d0                	add    %edx,%eax
801082d1:	0f b7 84 00 60 ab 10 	movzwl -0x7fef54a0(%eax,%eax,1),%eax
801082d8:	80 
801082d9:	0f b7 d0             	movzwl %ax,%edx
801082dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082df:	bb 01 00 00 00       	mov    $0x1,%ebx
801082e4:	89 c1                	mov    %eax,%ecx
801082e6:	d3 e3                	shl    %cl,%ebx
801082e8:	89 d8                	mov    %ebx,%eax
801082ea:	21 d0                	and    %edx,%eax
801082ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801082ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f2:	ba 01 00 00 00       	mov    $0x1,%edx
801082f7:	89 c1                	mov    %eax,%ecx
801082f9:	d3 e2                	shl    %cl,%edx
801082fb:	89 d0                	mov    %edx,%eax
801082fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108300:	75 2b                	jne    8010832d <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108302:	8b 55 0c             	mov    0xc(%ebp),%edx
80108305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108308:	01 c2                	add    %eax,%edx
8010830a:	b8 0e 00 00 00       	mov    $0xe,%eax
8010830f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108312:	89 c1                	mov    %eax,%ecx
80108314:	8b 45 08             	mov    0x8(%ebp),%eax
80108317:	01 c8                	add    %ecx,%eax
80108319:	83 ec 04             	sub    $0x4,%esp
8010831c:	68 e0 f4 10 80       	push   $0x8010f4e0
80108321:	52                   	push   %edx
80108322:	50                   	push   %eax
80108323:	e8 ad fe ff ff       	call   801081d5 <graphic_draw_pixel>
80108328:	83 c4 10             	add    $0x10,%esp
8010832b:	eb 29                	jmp    80108356 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010832d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108333:	01 c2                	add    %eax,%edx
80108335:	b8 0e 00 00 00       	mov    $0xe,%eax
8010833a:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010833d:	89 c1                	mov    %eax,%ecx
8010833f:	8b 45 08             	mov    0x8(%ebp),%eax
80108342:	01 c8                	add    %ecx,%eax
80108344:	83 ec 04             	sub    $0x4,%esp
80108347:	68 64 d0 18 80       	push   $0x8018d064
8010834c:	52                   	push   %edx
8010834d:	50                   	push   %eax
8010834e:	e8 82 fe ff ff       	call   801081d5 <graphic_draw_pixel>
80108353:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108356:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010835a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010835e:	0f 89 5f ff ff ff    	jns    801082c3 <font_render+0x23>
  for(int i=0;i<30;i++){
80108364:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108368:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010836c:	0f 8e 45 ff ff ff    	jle    801082b7 <font_render+0x17>
      }
    }
  }
}
80108372:	90                   	nop
80108373:	90                   	nop
80108374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108377:	c9                   	leave
80108378:	c3                   	ret

80108379 <font_render_string>:

void font_render_string(char *string,int row){
80108379:	f3 0f 1e fb          	endbr32
8010837d:	55                   	push   %ebp
8010837e:	89 e5                	mov    %esp,%ebp
80108380:	53                   	push   %ebx
80108381:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010838b:	eb 33                	jmp    801083c0 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010838d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108390:	8b 45 08             	mov    0x8(%ebp),%eax
80108393:	01 d0                	add    %edx,%eax
80108395:	0f b6 00             	movzbl (%eax),%eax
80108398:	0f be d8             	movsbl %al,%ebx
8010839b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839e:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801083a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083a4:	89 d0                	mov    %edx,%eax
801083a6:	c1 e0 04             	shl    $0x4,%eax
801083a9:	29 d0                	sub    %edx,%eax
801083ab:	83 c0 02             	add    $0x2,%eax
801083ae:	83 ec 04             	sub    $0x4,%esp
801083b1:	53                   	push   %ebx
801083b2:	51                   	push   %ecx
801083b3:	50                   	push   %eax
801083b4:	e8 e7 fe ff ff       	call   801082a0 <font_render>
801083b9:	83 c4 10             	add    $0x10,%esp
    i++;
801083bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801083c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083c3:	8b 45 08             	mov    0x8(%ebp),%eax
801083c6:	01 d0                	add    %edx,%eax
801083c8:	0f b6 00             	movzbl (%eax),%eax
801083cb:	84 c0                	test   %al,%al
801083cd:	74 06                	je     801083d5 <font_render_string+0x5c>
801083cf:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801083d3:	7e b8                	jle    8010838d <font_render_string+0x14>
  }
}
801083d5:	90                   	nop
801083d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083d9:	c9                   	leave
801083da:	c3                   	ret

801083db <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801083db:	f3 0f 1e fb          	endbr32
801083df:	55                   	push   %ebp
801083e0:	89 e5                	mov    %esp,%ebp
801083e2:	53                   	push   %ebx
801083e3:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801083e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ed:	eb 6b                	jmp    8010845a <pci_init+0x7f>
    for(int j=0;j<32;j++){
801083ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801083f6:	eb 58                	jmp    80108450 <pci_init+0x75>
      for(int k=0;k<8;k++){
801083f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801083ff:	eb 45                	jmp    80108446 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108401:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108404:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108410:	53                   	push   %ebx
80108411:	6a 00                	push   $0x0
80108413:	51                   	push   %ecx
80108414:	52                   	push   %edx
80108415:	50                   	push   %eax
80108416:	e8 c0 00 00 00       	call   801084db <pci_access_config>
8010841b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010841e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108421:	0f b7 c0             	movzwl %ax,%eax
80108424:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108429:	74 17                	je     80108442 <pci_init+0x67>
        pci_init_device(i,j,k);
8010842b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010842e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	83 ec 04             	sub    $0x4,%esp
80108437:	51                   	push   %ecx
80108438:	52                   	push   %edx
80108439:	50                   	push   %eax
8010843a:	e8 4f 01 00 00       	call   8010858e <pci_init_device>
8010843f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108442:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108446:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010844a:	7e b5                	jle    80108401 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010844c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108450:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108454:	7e a2                	jle    801083f8 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010845a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108461:	7e 8c                	jle    801083ef <pci_init+0x14>
      }
      }
    }
  }
}
80108463:	90                   	nop
80108464:	90                   	nop
80108465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108468:	c9                   	leave
80108469:	c3                   	ret

8010846a <pci_write_config>:

void pci_write_config(uint config){
8010846a:	f3 0f 1e fb          	endbr32
8010846e:	55                   	push   %ebp
8010846f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108471:	8b 45 08             	mov    0x8(%ebp),%eax
80108474:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108479:	89 c0                	mov    %eax,%eax
8010847b:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010847c:	90                   	nop
8010847d:	5d                   	pop    %ebp
8010847e:	c3                   	ret

8010847f <pci_write_data>:

void pci_write_data(uint config){
8010847f:	f3 0f 1e fb          	endbr32
80108483:	55                   	push   %ebp
80108484:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108486:	8b 45 08             	mov    0x8(%ebp),%eax
80108489:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010848e:	89 c0                	mov    %eax,%eax
80108490:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108491:	90                   	nop
80108492:	5d                   	pop    %ebp
80108493:	c3                   	ret

80108494 <pci_read_config>:
uint pci_read_config(){
80108494:	f3 0f 1e fb          	endbr32
80108498:	55                   	push   %ebp
80108499:	89 e5                	mov    %esp,%ebp
8010849b:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010849e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801084a3:	ed                   	in     (%dx),%eax
801084a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801084a7:	83 ec 0c             	sub    $0xc,%esp
801084aa:	68 c8 00 00 00       	push   $0xc8
801084af:	e8 90 a7 ff ff       	call   80102c44 <microdelay>
801084b4:	83 c4 10             	add    $0x10,%esp
  return data;
801084b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801084ba:	c9                   	leave
801084bb:	c3                   	ret

801084bc <pci_test>:


void pci_test(){
801084bc:	f3 0f 1e fb          	endbr32
801084c0:	55                   	push   %ebp
801084c1:	89 e5                	mov    %esp,%ebp
801084c3:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801084c6:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801084cd:	ff 75 fc             	push   -0x4(%ebp)
801084d0:	e8 95 ff ff ff       	call   8010846a <pci_write_config>
801084d5:	83 c4 04             	add    $0x4,%esp
}
801084d8:	90                   	nop
801084d9:	c9                   	leave
801084da:	c3                   	ret

801084db <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801084db:	f3 0f 1e fb          	endbr32
801084df:	55                   	push   %ebp
801084e0:	89 e5                	mov    %esp,%ebp
801084e2:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084e5:	8b 45 08             	mov    0x8(%ebp),%eax
801084e8:	c1 e0 10             	shl    $0x10,%eax
801084eb:	25 00 00 ff 00       	and    $0xff0000,%eax
801084f0:	89 c2                	mov    %eax,%edx
801084f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f5:	c1 e0 0b             	shl    $0xb,%eax
801084f8:	0f b7 c0             	movzwl %ax,%eax
801084fb:	09 c2                	or     %eax,%edx
801084fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108500:	c1 e0 08             	shl    $0x8,%eax
80108503:	25 00 07 00 00       	and    $0x700,%eax
80108508:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010850a:	8b 45 14             	mov    0x14(%ebp),%eax
8010850d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108512:	09 d0                	or     %edx,%eax
80108514:	0d 00 00 00 80       	or     $0x80000000,%eax
80108519:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010851c:	ff 75 f4             	push   -0xc(%ebp)
8010851f:	e8 46 ff ff ff       	call   8010846a <pci_write_config>
80108524:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108527:	e8 68 ff ff ff       	call   80108494 <pci_read_config>
8010852c:	8b 55 18             	mov    0x18(%ebp),%edx
8010852f:	89 02                	mov    %eax,(%edx)
}
80108531:	90                   	nop
80108532:	c9                   	leave
80108533:	c3                   	ret

80108534 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108534:	f3 0f 1e fb          	endbr32
80108538:	55                   	push   %ebp
80108539:	89 e5                	mov    %esp,%ebp
8010853b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010853e:	8b 45 08             	mov    0x8(%ebp),%eax
80108541:	c1 e0 10             	shl    $0x10,%eax
80108544:	25 00 00 ff 00       	and    $0xff0000,%eax
80108549:	89 c2                	mov    %eax,%edx
8010854b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010854e:	c1 e0 0b             	shl    $0xb,%eax
80108551:	0f b7 c0             	movzwl %ax,%eax
80108554:	09 c2                	or     %eax,%edx
80108556:	8b 45 10             	mov    0x10(%ebp),%eax
80108559:	c1 e0 08             	shl    $0x8,%eax
8010855c:	25 00 07 00 00       	and    $0x700,%eax
80108561:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108563:	8b 45 14             	mov    0x14(%ebp),%eax
80108566:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010856b:	09 d0                	or     %edx,%eax
8010856d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108572:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108575:	ff 75 fc             	push   -0x4(%ebp)
80108578:	e8 ed fe ff ff       	call   8010846a <pci_write_config>
8010857d:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108580:	ff 75 18             	push   0x18(%ebp)
80108583:	e8 f7 fe ff ff       	call   8010847f <pci_write_data>
80108588:	83 c4 04             	add    $0x4,%esp
}
8010858b:	90                   	nop
8010858c:	c9                   	leave
8010858d:	c3                   	ret

8010858e <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010858e:	f3 0f 1e fb          	endbr32
80108592:	55                   	push   %ebp
80108593:	89 e5                	mov    %esp,%ebp
80108595:	53                   	push   %ebx
80108596:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108599:	8b 45 08             	mov    0x8(%ebp),%eax
8010859c:	a2 9c 81 19 80       	mov    %al,0x8019819c
  dev.device_num = device_num;
801085a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a4:	a2 9d 81 19 80       	mov    %al,0x8019819d
  dev.function_num = function_num;
801085a9:	8b 45 10             	mov    0x10(%ebp),%eax
801085ac:	a2 9e 81 19 80       	mov    %al,0x8019819e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801085b1:	ff 75 10             	push   0x10(%ebp)
801085b4:	ff 75 0c             	push   0xc(%ebp)
801085b7:	ff 75 08             	push   0x8(%ebp)
801085ba:	68 a4 c1 10 80       	push   $0x8010c1a4
801085bf:	e8 48 7e ff ff       	call   8010040c <cprintf>
801085c4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801085c7:	83 ec 0c             	sub    $0xc,%esp
801085ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085cd:	50                   	push   %eax
801085ce:	6a 00                	push   $0x0
801085d0:	ff 75 10             	push   0x10(%ebp)
801085d3:	ff 75 0c             	push   0xc(%ebp)
801085d6:	ff 75 08             	push   0x8(%ebp)
801085d9:	e8 fd fe ff ff       	call   801084db <pci_access_config>
801085de:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801085e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e4:	c1 e8 10             	shr    $0x10,%eax
801085e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801085ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ed:	25 ff ff 00 00       	and    $0xffff,%eax
801085f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801085f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f8:	a3 a0 81 19 80       	mov    %eax,0x801981a0
  dev.vendor_id = vendor_id;
801085fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108600:	a3 a4 81 19 80       	mov    %eax,0x801981a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108605:	83 ec 04             	sub    $0x4,%esp
80108608:	ff 75 f0             	push   -0x10(%ebp)
8010860b:	ff 75 f4             	push   -0xc(%ebp)
8010860e:	68 d8 c1 10 80       	push   $0x8010c1d8
80108613:	e8 f4 7d ff ff       	call   8010040c <cprintf>
80108618:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010861b:	83 ec 0c             	sub    $0xc,%esp
8010861e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108621:	50                   	push   %eax
80108622:	6a 08                	push   $0x8
80108624:	ff 75 10             	push   0x10(%ebp)
80108627:	ff 75 0c             	push   0xc(%ebp)
8010862a:	ff 75 08             	push   0x8(%ebp)
8010862d:	e8 a9 fe ff ff       	call   801084db <pci_access_config>
80108632:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108638:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010863b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010863e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108641:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108647:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010864a:	0f b6 c0             	movzbl %al,%eax
8010864d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108650:	c1 eb 18             	shr    $0x18,%ebx
80108653:	83 ec 0c             	sub    $0xc,%esp
80108656:	51                   	push   %ecx
80108657:	52                   	push   %edx
80108658:	50                   	push   %eax
80108659:	53                   	push   %ebx
8010865a:	68 fc c1 10 80       	push   $0x8010c1fc
8010865f:	e8 a8 7d ff ff       	call   8010040c <cprintf>
80108664:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108667:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010866a:	c1 e8 18             	shr    $0x18,%eax
8010866d:	a2 a8 81 19 80       	mov    %al,0x801981a8
  dev.sub_class = (data>>16)&0xFF;
80108672:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108675:	c1 e8 10             	shr    $0x10,%eax
80108678:	a2 a9 81 19 80       	mov    %al,0x801981a9
  dev.interface = (data>>8)&0xFF;
8010867d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108680:	c1 e8 08             	shr    $0x8,%eax
80108683:	a2 aa 81 19 80       	mov    %al,0x801981aa
  dev.revision_id = data&0xFF;
80108688:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010868b:	a2 ab 81 19 80       	mov    %al,0x801981ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108690:	83 ec 0c             	sub    $0xc,%esp
80108693:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108696:	50                   	push   %eax
80108697:	6a 10                	push   $0x10
80108699:	ff 75 10             	push   0x10(%ebp)
8010869c:	ff 75 0c             	push   0xc(%ebp)
8010869f:	ff 75 08             	push   0x8(%ebp)
801086a2:	e8 34 fe ff ff       	call   801084db <pci_access_config>
801086a7:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801086aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ad:	a3 ac 81 19 80       	mov    %eax,0x801981ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801086b2:	83 ec 0c             	sub    $0xc,%esp
801086b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086b8:	50                   	push   %eax
801086b9:	6a 14                	push   $0x14
801086bb:	ff 75 10             	push   0x10(%ebp)
801086be:	ff 75 0c             	push   0xc(%ebp)
801086c1:	ff 75 08             	push   0x8(%ebp)
801086c4:	e8 12 fe ff ff       	call   801084db <pci_access_config>
801086c9:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801086cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086cf:	a3 b0 81 19 80       	mov    %eax,0x801981b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801086d4:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801086db:	75 5a                	jne    80108737 <pci_init_device+0x1a9>
801086dd:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801086e4:	75 51                	jne    80108737 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801086e6:	83 ec 0c             	sub    $0xc,%esp
801086e9:	68 41 c2 10 80       	push   $0x8010c241
801086ee:	e8 19 7d ff ff       	call   8010040c <cprintf>
801086f3:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801086f6:	83 ec 0c             	sub    $0xc,%esp
801086f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086fc:	50                   	push   %eax
801086fd:	68 f0 00 00 00       	push   $0xf0
80108702:	ff 75 10             	push   0x10(%ebp)
80108705:	ff 75 0c             	push   0xc(%ebp)
80108708:	ff 75 08             	push   0x8(%ebp)
8010870b:	e8 cb fd ff ff       	call   801084db <pci_access_config>
80108710:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108713:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108716:	83 ec 08             	sub    $0x8,%esp
80108719:	50                   	push   %eax
8010871a:	68 5b c2 10 80       	push   $0x8010c25b
8010871f:	e8 e8 7c ff ff       	call   8010040c <cprintf>
80108724:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108727:	83 ec 0c             	sub    $0xc,%esp
8010872a:	68 9c 81 19 80       	push   $0x8019819c
8010872f:	e8 09 00 00 00       	call   8010873d <i8254_init>
80108734:	83 c4 10             	add    $0x10,%esp
  }
}
80108737:	90                   	nop
80108738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010873b:	c9                   	leave
8010873c:	c3                   	ret

8010873d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010873d:	f3 0f 1e fb          	endbr32
80108741:	55                   	push   %ebp
80108742:	89 e5                	mov    %esp,%ebp
80108744:	53                   	push   %ebx
80108745:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108748:	8b 45 08             	mov    0x8(%ebp),%eax
8010874b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010874f:	0f b6 c8             	movzbl %al,%ecx
80108752:	8b 45 08             	mov    0x8(%ebp),%eax
80108755:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108759:	0f b6 d0             	movzbl %al,%edx
8010875c:	8b 45 08             	mov    0x8(%ebp),%eax
8010875f:	0f b6 00             	movzbl (%eax),%eax
80108762:	0f b6 c0             	movzbl %al,%eax
80108765:	83 ec 0c             	sub    $0xc,%esp
80108768:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010876b:	53                   	push   %ebx
8010876c:	6a 04                	push   $0x4
8010876e:	51                   	push   %ecx
8010876f:	52                   	push   %edx
80108770:	50                   	push   %eax
80108771:	e8 65 fd ff ff       	call   801084db <pci_access_config>
80108776:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108779:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877c:	83 c8 04             	or     $0x4,%eax
8010877f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108782:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108785:	8b 45 08             	mov    0x8(%ebp),%eax
80108788:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010878c:	0f b6 c8             	movzbl %al,%ecx
8010878f:	8b 45 08             	mov    0x8(%ebp),%eax
80108792:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108796:	0f b6 d0             	movzbl %al,%edx
80108799:	8b 45 08             	mov    0x8(%ebp),%eax
8010879c:	0f b6 00             	movzbl (%eax),%eax
8010879f:	0f b6 c0             	movzbl %al,%eax
801087a2:	83 ec 0c             	sub    $0xc,%esp
801087a5:	53                   	push   %ebx
801087a6:	6a 04                	push   $0x4
801087a8:	51                   	push   %ecx
801087a9:	52                   	push   %edx
801087aa:	50                   	push   %eax
801087ab:	e8 84 fd ff ff       	call   80108534 <pci_write_config_register>
801087b0:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801087b3:	8b 45 08             	mov    0x8(%ebp),%eax
801087b6:	8b 40 10             	mov    0x10(%eax),%eax
801087b9:	05 00 00 00 40       	add    $0x40000000,%eax
801087be:	a3 b4 81 19 80       	mov    %eax,0x801981b4
  uint *ctrl = (uint *)base_addr;
801087c3:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801087c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801087cb:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801087d0:	05 d8 00 00 00       	add    $0xd8,%eax
801087d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801087d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087db:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801087e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e4:	8b 00                	mov    (%eax),%eax
801087e6:	0d 00 00 00 04       	or     $0x4000000,%eax
801087eb:	89 c2                	mov    %eax,%edx
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801087f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801087fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fe:	8b 00                	mov    (%eax),%eax
80108800:	83 c8 40             	or     $0x40,%eax
80108803:	89 c2                	mov    %eax,%edx
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010880a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880d:	8b 10                	mov    (%eax),%edx
8010880f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108812:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108814:	83 ec 0c             	sub    $0xc,%esp
80108817:	68 70 c2 10 80       	push   $0x8010c270
8010881c:	e8 eb 7b ff ff       	call   8010040c <cprintf>
80108821:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108824:	e8 69 a0 ff ff       	call   80102892 <kalloc>
80108829:	a3 b8 81 19 80       	mov    %eax,0x801981b8
  *intr_addr = 0;
8010882e:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108833:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108839:	a1 b8 81 19 80       	mov    0x801981b8,%eax
8010883e:	83 ec 08             	sub    $0x8,%esp
80108841:	50                   	push   %eax
80108842:	68 92 c2 10 80       	push   $0x8010c292
80108847:	e8 c0 7b ff ff       	call   8010040c <cprintf>
8010884c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010884f:	e8 50 00 00 00       	call   801088a4 <i8254_init_recv>
  i8254_init_send();
80108854:	e8 6d 03 00 00       	call   80108bc6 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108859:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108860:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108863:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010886a:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010886d:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108874:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108877:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010887e:	0f b6 c0             	movzbl %al,%eax
80108881:	83 ec 0c             	sub    $0xc,%esp
80108884:	53                   	push   %ebx
80108885:	51                   	push   %ecx
80108886:	52                   	push   %edx
80108887:	50                   	push   %eax
80108888:	68 a0 c2 10 80       	push   $0x8010c2a0
8010888d:	e8 7a 7b ff ff       	call   8010040c <cprintf>
80108892:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108898:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010889e:	90                   	nop
8010889f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088a2:	c9                   	leave
801088a3:	c3                   	ret

801088a4 <i8254_init_recv>:

void i8254_init_recv(){
801088a4:	f3 0f 1e fb          	endbr32
801088a8:	55                   	push   %ebp
801088a9:	89 e5                	mov    %esp,%ebp
801088ab:	57                   	push   %edi
801088ac:	56                   	push   %esi
801088ad:	53                   	push   %ebx
801088ae:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801088b1:	83 ec 0c             	sub    $0xc,%esp
801088b4:	6a 00                	push   $0x0
801088b6:	e8 ec 04 00 00       	call   80108da7 <i8254_read_eeprom>
801088bb:	83 c4 10             	add    $0x10,%esp
801088be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801088c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088c4:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
801088c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088cc:	c1 e8 08             	shr    $0x8,%eax
801088cf:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
801088d4:	83 ec 0c             	sub    $0xc,%esp
801088d7:	6a 01                	push   $0x1
801088d9:	e8 c9 04 00 00       	call   80108da7 <i8254_read_eeprom>
801088de:	83 c4 10             	add    $0x10,%esp
801088e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801088e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088e7:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
801088ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088ef:	c1 e8 08             	shr    $0x8,%eax
801088f2:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
801088f7:	83 ec 0c             	sub    $0xc,%esp
801088fa:	6a 02                	push   $0x2
801088fc:	e8 a6 04 00 00       	call   80108da7 <i8254_read_eeprom>
80108901:	83 c4 10             	add    $0x10,%esp
80108904:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108907:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010890a:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
8010890f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108912:	c1 e8 08             	shr    $0x8,%eax
80108915:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010891a:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108921:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108924:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010892b:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010892e:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108935:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108938:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010893f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108942:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108949:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010894c:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108953:	0f b6 c0             	movzbl %al,%eax
80108956:	83 ec 04             	sub    $0x4,%esp
80108959:	57                   	push   %edi
8010895a:	56                   	push   %esi
8010895b:	53                   	push   %ebx
8010895c:	51                   	push   %ecx
8010895d:	52                   	push   %edx
8010895e:	50                   	push   %eax
8010895f:	68 b8 c2 10 80       	push   $0x8010c2b8
80108964:	e8 a3 7a ff ff       	call   8010040c <cprintf>
80108969:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010896c:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108971:	05 00 54 00 00       	add    $0x5400,%eax
80108976:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108979:	a1 b4 81 19 80       	mov    0x801981b4,%eax
8010897e:	05 04 54 00 00       	add    $0x5404,%eax
80108983:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108986:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108989:	c1 e0 10             	shl    $0x10,%eax
8010898c:	0b 45 d8             	or     -0x28(%ebp),%eax
8010898f:	89 c2                	mov    %eax,%edx
80108991:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108994:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108996:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108999:	0d 00 00 00 80       	or     $0x80000000,%eax
8010899e:	89 c2                	mov    %eax,%edx
801089a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801089a3:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801089a5:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801089aa:	05 00 52 00 00       	add    $0x5200,%eax
801089af:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801089b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801089b9:	eb 19                	jmp    801089d4 <i8254_init_recv+0x130>
    mta[i] = 0;
801089bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089c8:	01 d0                	add    %edx,%eax
801089ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801089d0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801089d4:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801089d8:	7e e1                	jle    801089bb <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801089da:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801089df:	05 d0 00 00 00       	add    $0xd0,%eax
801089e4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801089e7:	8b 45 c0             	mov    -0x40(%ebp),%eax
801089ea:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801089f0:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801089f5:	05 c8 00 00 00       	add    $0xc8,%eax
801089fa:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801089fd:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108a00:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108a06:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a0b:	05 28 28 00 00       	add    $0x2828,%eax
80108a10:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108a13:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108a16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108a1c:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a21:	05 00 01 00 00       	add    $0x100,%eax
80108a26:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108a29:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a2c:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108a32:	e8 5b 9e ff ff       	call   80102892 <kalloc>
80108a37:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a3a:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a3f:	05 00 28 00 00       	add    $0x2800,%eax
80108a44:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108a47:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a4c:	05 04 28 00 00       	add    $0x2804,%eax
80108a51:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108a54:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a59:	05 08 28 00 00       	add    $0x2808,%eax
80108a5e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a61:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a66:	05 10 28 00 00       	add    $0x2810,%eax
80108a6b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a6e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a73:	05 18 28 00 00       	add    $0x2818,%eax
80108a78:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108a7b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a7e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a84:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108a87:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108a89:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108a8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108a92:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108a95:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108a9b:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108a9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108aa4:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108aa7:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108aad:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ab0:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ab3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108aba:	eb 73                	jmp    80108b2f <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108abf:	c1 e0 04             	shl    $0x4,%eax
80108ac2:	89 c2                	mov    %eax,%edx
80108ac4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ac7:	01 d0                	add    %edx,%eax
80108ac9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108ad0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ad3:	c1 e0 04             	shl    $0x4,%eax
80108ad6:	89 c2                	mov    %eax,%edx
80108ad8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108adb:	01 d0                	add    %edx,%eax
80108add:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108ae3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ae6:	c1 e0 04             	shl    $0x4,%eax
80108ae9:	89 c2                	mov    %eax,%edx
80108aeb:	8b 45 98             	mov    -0x68(%ebp),%eax
80108aee:	01 d0                	add    %edx,%eax
80108af0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108af6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af9:	c1 e0 04             	shl    $0x4,%eax
80108afc:	89 c2                	mov    %eax,%edx
80108afe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b01:	01 d0                	add    %edx,%eax
80108b03:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b0a:	c1 e0 04             	shl    $0x4,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b12:	01 d0                	add    %edx,%eax
80108b14:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b1b:	c1 e0 04             	shl    $0x4,%eax
80108b1e:	89 c2                	mov    %eax,%edx
80108b20:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b23:	01 d0                	add    %edx,%eax
80108b25:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b2b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108b2f:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108b36:	7e 84                	jle    80108abc <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b38:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108b3f:	eb 57                	jmp    80108b98 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108b41:	e8 4c 9d ff ff       	call   80102892 <kalloc>
80108b46:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108b49:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108b4d:	75 12                	jne    80108b61 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108b4f:	83 ec 0c             	sub    $0xc,%esp
80108b52:	68 d8 c2 10 80       	push   $0x8010c2d8
80108b57:	e8 b0 78 ff ff       	call   8010040c <cprintf>
80108b5c:	83 c4 10             	add    $0x10,%esp
      break;
80108b5f:	eb 3d                	jmp    80108b9e <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108b61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b64:	c1 e0 04             	shl    $0x4,%eax
80108b67:	89 c2                	mov    %eax,%edx
80108b69:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b6c:	01 d0                	add    %edx,%eax
80108b6e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b71:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b77:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108b79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b7c:	83 c0 01             	add    $0x1,%eax
80108b7f:	c1 e0 04             	shl    $0x4,%eax
80108b82:	89 c2                	mov    %eax,%edx
80108b84:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b87:	01 d0                	add    %edx,%eax
80108b89:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b8c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b92:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b94:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108b98:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108b9c:	7e a3                	jle    80108b41 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108b9e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ba1:	8b 00                	mov    (%eax),%eax
80108ba3:	83 c8 02             	or     $0x2,%eax
80108ba6:	89 c2                	mov    %eax,%edx
80108ba8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bab:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108bad:	83 ec 0c             	sub    $0xc,%esp
80108bb0:	68 f8 c2 10 80       	push   $0x8010c2f8
80108bb5:	e8 52 78 ff ff       	call   8010040c <cprintf>
80108bba:	83 c4 10             	add    $0x10,%esp
}
80108bbd:	90                   	nop
80108bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108bc1:	5b                   	pop    %ebx
80108bc2:	5e                   	pop    %esi
80108bc3:	5f                   	pop    %edi
80108bc4:	5d                   	pop    %ebp
80108bc5:	c3                   	ret

80108bc6 <i8254_init_send>:

void i8254_init_send(){
80108bc6:	f3 0f 1e fb          	endbr32
80108bca:	55                   	push   %ebp
80108bcb:	89 e5                	mov    %esp,%ebp
80108bcd:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108bd0:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108bd5:	05 28 38 00 00       	add    $0x3828,%eax
80108bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be0:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108be6:	e8 a7 9c ff ff       	call   80102892 <kalloc>
80108beb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bee:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108bf3:	05 00 38 00 00       	add    $0x3800,%eax
80108bf8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108bfb:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c00:	05 04 38 00 00       	add    $0x3804,%eax
80108c05:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108c08:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c0d:	05 08 38 00 00       	add    $0x3808,%eax
80108c12:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108c15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c18:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c21:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108c2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c2f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108c35:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c3a:	05 10 38 00 00       	add    $0x3810,%eax
80108c3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108c42:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c47:	05 18 38 00 00       	add    $0x3818,%eax
80108c4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108c4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108c58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c6e:	e9 82 00 00 00       	jmp    80108cf5 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c76:	c1 e0 04             	shl    $0x4,%eax
80108c79:	89 c2                	mov    %eax,%edx
80108c7b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c7e:	01 d0                	add    %edx,%eax
80108c80:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8a:	c1 e0 04             	shl    $0x4,%eax
80108c8d:	89 c2                	mov    %eax,%edx
80108c8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c92:	01 d0                	add    %edx,%eax
80108c94:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9d:	c1 e0 04             	shl    $0x4,%eax
80108ca0:	89 c2                	mov    %eax,%edx
80108ca2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ca5:	01 d0                	add    %edx,%eax
80108ca7:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cae:	c1 e0 04             	shl    $0x4,%eax
80108cb1:	89 c2                	mov    %eax,%edx
80108cb3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb6:	01 d0                	add    %edx,%eax
80108cb8:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbf:	c1 e0 04             	shl    $0x4,%eax
80108cc2:	89 c2                	mov    %eax,%edx
80108cc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cc7:	01 d0                	add    %edx,%eax
80108cc9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd0:	c1 e0 04             	shl    $0x4,%eax
80108cd3:	89 c2                	mov    %eax,%edx
80108cd5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cd8:	01 d0                	add    %edx,%eax
80108cda:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce1:	c1 e0 04             	shl    $0x4,%eax
80108ce4:	89 c2                	mov    %eax,%edx
80108ce6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ce9:	01 d0                	add    %edx,%eax
80108ceb:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108cf1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cf5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108cfc:	0f 8e 71 ff ff ff    	jle    80108c73 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d02:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d09:	eb 57                	jmp    80108d62 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108d0b:	e8 82 9b ff ff       	call   80102892 <kalloc>
80108d10:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108d13:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108d17:	75 12                	jne    80108d2b <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108d19:	83 ec 0c             	sub    $0xc,%esp
80108d1c:	68 d8 c2 10 80       	push   $0x8010c2d8
80108d21:	e8 e6 76 ff ff       	call   8010040c <cprintf>
80108d26:	83 c4 10             	add    $0x10,%esp
      break;
80108d29:	eb 3d                	jmp    80108d68 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d2e:	c1 e0 04             	shl    $0x4,%eax
80108d31:	89 c2                	mov    %eax,%edx
80108d33:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d36:	01 d0                	add    %edx,%eax
80108d38:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d3b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d41:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d46:	83 c0 01             	add    $0x1,%eax
80108d49:	c1 e0 04             	shl    $0x4,%eax
80108d4c:	89 c2                	mov    %eax,%edx
80108d4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d51:	01 d0                	add    %edx,%eax
80108d53:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108d56:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d5c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108d5e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d62:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108d66:	7e a3                	jle    80108d0b <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108d68:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108d6d:	05 00 04 00 00       	add    $0x400,%eax
80108d72:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108d75:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d78:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108d7e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108d83:	05 10 04 00 00       	add    $0x410,%eax
80108d88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108d8b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d8e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108d94:	83 ec 0c             	sub    $0xc,%esp
80108d97:	68 18 c3 10 80       	push   $0x8010c318
80108d9c:	e8 6b 76 ff ff       	call   8010040c <cprintf>
80108da1:	83 c4 10             	add    $0x10,%esp

}
80108da4:	90                   	nop
80108da5:	c9                   	leave
80108da6:	c3                   	ret

80108da7 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108da7:	f3 0f 1e fb          	endbr32
80108dab:	55                   	push   %ebp
80108dac:	89 e5                	mov    %esp,%ebp
80108dae:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108db1:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108db6:	83 c0 14             	add    $0x14,%eax
80108db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80108dbf:	c1 e0 08             	shl    $0x8,%eax
80108dc2:	0f b7 c0             	movzwl %ax,%eax
80108dc5:	83 c8 01             	or     $0x1,%eax
80108dc8:	89 c2                	mov    %eax,%edx
80108dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcd:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108dcf:	83 ec 0c             	sub    $0xc,%esp
80108dd2:	68 38 c3 10 80       	push   $0x8010c338
80108dd7:	e8 30 76 ff ff       	call   8010040c <cprintf>
80108ddc:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de2:	8b 00                	mov    (%eax),%eax
80108de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dea:	83 e0 10             	and    $0x10,%eax
80108ded:	85 c0                	test   %eax,%eax
80108def:	75 02                	jne    80108df3 <i8254_read_eeprom+0x4c>
  while(1){
80108df1:	eb dc                	jmp    80108dcf <i8254_read_eeprom+0x28>
      break;
80108df3:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df7:	8b 00                	mov    (%eax),%eax
80108df9:	c1 e8 10             	shr    $0x10,%eax
}
80108dfc:	c9                   	leave
80108dfd:	c3                   	ret

80108dfe <i8254_recv>:
void i8254_recv(){
80108dfe:	f3 0f 1e fb          	endbr32
80108e02:	55                   	push   %ebp
80108e03:	89 e5                	mov    %esp,%ebp
80108e05:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e08:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e0d:	05 10 28 00 00       	add    $0x2810,%eax
80108e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e15:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e1a:	05 18 28 00 00       	add    $0x2818,%eax
80108e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108e22:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e27:	05 00 28 00 00       	add    $0x2800,%eax
80108e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108e2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e32:	8b 00                	mov    (%eax),%eax
80108e34:	05 00 00 00 80       	add    $0x80000000,%eax
80108e39:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3f:	8b 10                	mov    (%eax),%edx
80108e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e44:	8b 00                	mov    (%eax),%eax
80108e46:	29 c2                	sub    %eax,%edx
80108e48:	89 d0                	mov    %edx,%eax
80108e4a:	25 ff 00 00 00       	and    $0xff,%eax
80108e4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108e52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e56:	7e 37                	jle    80108e8f <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5b:	8b 00                	mov    (%eax),%eax
80108e5d:	c1 e0 04             	shl    $0x4,%eax
80108e60:	89 c2                	mov    %eax,%edx
80108e62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e65:	01 d0                	add    %edx,%eax
80108e67:	8b 00                	mov    (%eax),%eax
80108e69:	05 00 00 00 80       	add    $0x80000000,%eax
80108e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e74:	8b 00                	mov    (%eax),%eax
80108e76:	83 c0 01             	add    $0x1,%eax
80108e79:	0f b6 d0             	movzbl %al,%edx
80108e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7f:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108e81:	83 ec 0c             	sub    $0xc,%esp
80108e84:	ff 75 e0             	push   -0x20(%ebp)
80108e87:	e8 47 09 00 00       	call   801097d3 <eth_proc>
80108e8c:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e92:	8b 10                	mov    (%eax),%edx
80108e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e97:	8b 00                	mov    (%eax),%eax
80108e99:	39 c2                	cmp    %eax,%edx
80108e9b:	75 9f                	jne    80108e3c <i8254_recv+0x3e>
      (*rdt)--;
80108e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea0:	8b 00                	mov    (%eax),%eax
80108ea2:	8d 50 ff             	lea    -0x1(%eax),%edx
80108ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea8:	89 10                	mov    %edx,(%eax)
  while(1){
80108eaa:	eb 90                	jmp    80108e3c <i8254_recv+0x3e>

80108eac <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108eac:	f3 0f 1e fb          	endbr32
80108eb0:	55                   	push   %ebp
80108eb1:	89 e5                	mov    %esp,%ebp
80108eb3:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108eb6:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ebb:	05 10 38 00 00       	add    $0x3810,%eax
80108ec0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ec3:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ec8:	05 18 38 00 00       	add    $0x3818,%eax
80108ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ed0:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ed5:	05 00 38 00 00       	add    $0x3800,%eax
80108eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee0:	8b 00                	mov    (%eax),%eax
80108ee2:	05 00 00 00 80       	add    $0x80000000,%eax
80108ee7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eed:	8b 10                	mov    (%eax),%edx
80108eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef2:	8b 00                	mov    (%eax),%eax
80108ef4:	29 c2                	sub    %eax,%edx
80108ef6:	89 d0                	mov    %edx,%eax
80108ef8:	0f b6 c0             	movzbl %al,%eax
80108efb:	ba 00 01 00 00       	mov    $0x100,%edx
80108f00:	29 c2                	sub    %eax,%edx
80108f02:	89 d0                	mov    %edx,%eax
80108f04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f0a:	8b 00                	mov    (%eax),%eax
80108f0c:	25 ff 00 00 00       	and    $0xff,%eax
80108f11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108f14:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f18:	0f 8e a8 00 00 00    	jle    80108fc6 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80108f21:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108f24:	89 d1                	mov    %edx,%ecx
80108f26:	c1 e1 04             	shl    $0x4,%ecx
80108f29:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108f2c:	01 ca                	add    %ecx,%edx
80108f2e:	8b 12                	mov    (%edx),%edx
80108f30:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f36:	83 ec 04             	sub    $0x4,%esp
80108f39:	ff 75 0c             	push   0xc(%ebp)
80108f3c:	50                   	push   %eax
80108f3d:	52                   	push   %edx
80108f3e:	e8 43 bd ff ff       	call   80104c86 <memmove>
80108f43:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f49:	c1 e0 04             	shl    $0x4,%eax
80108f4c:	89 c2                	mov    %eax,%edx
80108f4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f51:	01 d0                	add    %edx,%eax
80108f53:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f56:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f5d:	c1 e0 04             	shl    $0x4,%eax
80108f60:	89 c2                	mov    %eax,%edx
80108f62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f65:	01 d0                	add    %edx,%eax
80108f67:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f6e:	c1 e0 04             	shl    $0x4,%eax
80108f71:	89 c2                	mov    %eax,%edx
80108f73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f76:	01 d0                	add    %edx,%eax
80108f78:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f7f:	c1 e0 04             	shl    $0x4,%eax
80108f82:	89 c2                	mov    %eax,%edx
80108f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f87:	01 d0                	add    %edx,%eax
80108f89:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f90:	c1 e0 04             	shl    $0x4,%eax
80108f93:	89 c2                	mov    %eax,%edx
80108f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f98:	01 d0                	add    %edx,%eax
80108f9a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fa3:	c1 e0 04             	shl    $0x4,%eax
80108fa6:	89 c2                	mov    %eax,%edx
80108fa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fab:	01 d0                	add    %edx,%eax
80108fad:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb4:	8b 00                	mov    (%eax),%eax
80108fb6:	83 c0 01             	add    $0x1,%eax
80108fb9:	0f b6 d0             	movzbl %al,%edx
80108fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fbf:	89 10                	mov    %edx,(%eax)
    return len;
80108fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fc4:	eb 05                	jmp    80108fcb <i8254_send+0x11f>
  }else{
    return -1;
80108fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108fcb:	c9                   	leave
80108fcc:	c3                   	ret

80108fcd <i8254_intr>:

void i8254_intr(){
80108fcd:	f3 0f 1e fb          	endbr32
80108fd1:	55                   	push   %ebp
80108fd2:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108fd4:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108fd9:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108fdf:	90                   	nop
80108fe0:	5d                   	pop    %ebp
80108fe1:	c3                   	ret

80108fe2 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108fe2:	f3 0f 1e fb          	endbr32
80108fe6:	55                   	push   %ebp
80108fe7:	89 e5                	mov    %esp,%ebp
80108fe9:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108fec:	8b 45 08             	mov    0x8(%ebp),%eax
80108fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff5:	0f b7 00             	movzwl (%eax),%eax
80108ff8:	66 3d 00 01          	cmp    $0x100,%ax
80108ffc:	74 0a                	je     80109008 <arp_proc+0x26>
80108ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109003:	e9 4f 01 00 00       	jmp    80109157 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010900f:	66 83 f8 08          	cmp    $0x8,%ax
80109013:	74 0a                	je     8010901f <arp_proc+0x3d>
80109015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010901a:	e9 38 01 00 00       	jmp    80109157 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010901f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109022:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109026:	3c 06                	cmp    $0x6,%al
80109028:	74 0a                	je     80109034 <arp_proc+0x52>
8010902a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010902f:	e9 23 01 00 00       	jmp    80109157 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109037:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010903b:	3c 04                	cmp    $0x4,%al
8010903d:	74 0a                	je     80109049 <arp_proc+0x67>
8010903f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109044:	e9 0e 01 00 00       	jmp    80109157 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010904c:	83 c0 18             	add    $0x18,%eax
8010904f:	83 ec 04             	sub    $0x4,%esp
80109052:	6a 04                	push   $0x4
80109054:	50                   	push   %eax
80109055:	68 e4 f4 10 80       	push   $0x8010f4e4
8010905a:	e8 cb bb ff ff       	call   80104c2a <memcmp>
8010905f:	83 c4 10             	add    $0x10,%esp
80109062:	85 c0                	test   %eax,%eax
80109064:	74 27                	je     8010908d <arp_proc+0xab>
80109066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109069:	83 c0 0e             	add    $0xe,%eax
8010906c:	83 ec 04             	sub    $0x4,%esp
8010906f:	6a 04                	push   $0x4
80109071:	50                   	push   %eax
80109072:	68 e4 f4 10 80       	push   $0x8010f4e4
80109077:	e8 ae bb ff ff       	call   80104c2a <memcmp>
8010907c:	83 c4 10             	add    $0x10,%esp
8010907f:	85 c0                	test   %eax,%eax
80109081:	74 0a                	je     8010908d <arp_proc+0xab>
80109083:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109088:	e9 ca 00 00 00       	jmp    80109157 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010908d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109090:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109094:	66 3d 00 01          	cmp    $0x100,%ax
80109098:	75 69                	jne    80109103 <arp_proc+0x121>
8010909a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909d:	83 c0 18             	add    $0x18,%eax
801090a0:	83 ec 04             	sub    $0x4,%esp
801090a3:	6a 04                	push   $0x4
801090a5:	50                   	push   %eax
801090a6:	68 e4 f4 10 80       	push   $0x8010f4e4
801090ab:	e8 7a bb ff ff       	call   80104c2a <memcmp>
801090b0:	83 c4 10             	add    $0x10,%esp
801090b3:	85 c0                	test   %eax,%eax
801090b5:	75 4c                	jne    80109103 <arp_proc+0x121>
    uint send = (uint)kalloc();
801090b7:	e8 d6 97 ff ff       	call   80102892 <kalloc>
801090bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801090bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801090c6:	83 ec 04             	sub    $0x4,%esp
801090c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090cc:	50                   	push   %eax
801090cd:	ff 75 f0             	push   -0x10(%ebp)
801090d0:	ff 75 f4             	push   -0xc(%ebp)
801090d3:	e8 33 04 00 00       	call   8010950b <arp_reply_pkt_create>
801090d8:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801090db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090de:	83 ec 08             	sub    $0x8,%esp
801090e1:	50                   	push   %eax
801090e2:	ff 75 f0             	push   -0x10(%ebp)
801090e5:	e8 c2 fd ff ff       	call   80108eac <i8254_send>
801090ea:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801090ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f0:	83 ec 0c             	sub    $0xc,%esp
801090f3:	50                   	push   %eax
801090f4:	e8 fb 96 ff ff       	call   801027f4 <kfree>
801090f9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801090fc:	b8 02 00 00 00       	mov    $0x2,%eax
80109101:	eb 54                	jmp    80109157 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109106:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010910a:	66 3d 00 02          	cmp    $0x200,%ax
8010910e:	75 42                	jne    80109152 <arp_proc+0x170>
80109110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109113:	83 c0 18             	add    $0x18,%eax
80109116:	83 ec 04             	sub    $0x4,%esp
80109119:	6a 04                	push   $0x4
8010911b:	50                   	push   %eax
8010911c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109121:	e8 04 bb ff ff       	call   80104c2a <memcmp>
80109126:	83 c4 10             	add    $0x10,%esp
80109129:	85 c0                	test   %eax,%eax
8010912b:	75 25                	jne    80109152 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010912d:	83 ec 0c             	sub    $0xc,%esp
80109130:	68 3c c3 10 80       	push   $0x8010c33c
80109135:	e8 d2 72 ff ff       	call   8010040c <cprintf>
8010913a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010913d:	83 ec 0c             	sub    $0xc,%esp
80109140:	ff 75 f4             	push   -0xc(%ebp)
80109143:	e8 b7 01 00 00       	call   801092ff <arp_table_update>
80109148:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010914b:	b8 01 00 00 00       	mov    $0x1,%eax
80109150:	eb 05                	jmp    80109157 <arp_proc+0x175>
  }else{
    return -1;
80109152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109157:	c9                   	leave
80109158:	c3                   	ret

80109159 <arp_scan>:

void arp_scan(){
80109159:	f3 0f 1e fb          	endbr32
8010915d:	55                   	push   %ebp
8010915e:	89 e5                	mov    %esp,%ebp
80109160:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109163:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010916a:	eb 6f                	jmp    801091db <arp_scan+0x82>
    uint send = (uint)kalloc();
8010916c:	e8 21 97 ff ff       	call   80102892 <kalloc>
80109171:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109174:	83 ec 04             	sub    $0x4,%esp
80109177:	ff 75 f4             	push   -0xc(%ebp)
8010917a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010917d:	50                   	push   %eax
8010917e:	ff 75 ec             	push   -0x14(%ebp)
80109181:	e8 62 00 00 00       	call   801091e8 <arp_broadcast>
80109186:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109189:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010918c:	83 ec 08             	sub    $0x8,%esp
8010918f:	50                   	push   %eax
80109190:	ff 75 ec             	push   -0x14(%ebp)
80109193:	e8 14 fd ff ff       	call   80108eac <i8254_send>
80109198:	83 c4 10             	add    $0x10,%esp
8010919b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010919e:	eb 22                	jmp    801091c2 <arp_scan+0x69>
      microdelay(1);
801091a0:	83 ec 0c             	sub    $0xc,%esp
801091a3:	6a 01                	push   $0x1
801091a5:	e8 9a 9a ff ff       	call   80102c44 <microdelay>
801091aa:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801091ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091b0:	83 ec 08             	sub    $0x8,%esp
801091b3:	50                   	push   %eax
801091b4:	ff 75 ec             	push   -0x14(%ebp)
801091b7:	e8 f0 fc ff ff       	call   80108eac <i8254_send>
801091bc:	83 c4 10             	add    $0x10,%esp
801091bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801091c2:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801091c6:	74 d8                	je     801091a0 <arp_scan+0x47>
    }
    kfree((char *)send);
801091c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091cb:	83 ec 0c             	sub    $0xc,%esp
801091ce:	50                   	push   %eax
801091cf:	e8 20 96 ff ff       	call   801027f4 <kfree>
801091d4:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801091d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091db:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801091e2:	7e 88                	jle    8010916c <arp_scan+0x13>
  }
}
801091e4:	90                   	nop
801091e5:	90                   	nop
801091e6:	c9                   	leave
801091e7:	c3                   	ret

801091e8 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801091e8:	f3 0f 1e fb          	endbr32
801091ec:	55                   	push   %ebp
801091ed:	89 e5                	mov    %esp,%ebp
801091ef:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801091f2:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801091f6:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801091fa:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801091fe:	8b 45 10             	mov    0x10(%ebp),%eax
80109201:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109204:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010920b:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109211:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109218:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010921e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109221:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109227:	8b 45 08             	mov    0x8(%ebp),%eax
8010922a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010922d:	8b 45 08             	mov    0x8(%ebp),%eax
80109230:	83 c0 0e             	add    $0xe,%eax
80109233:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109239:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010923d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109240:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109247:	83 ec 04             	sub    $0x4,%esp
8010924a:	6a 06                	push   $0x6
8010924c:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010924f:	52                   	push   %edx
80109250:	50                   	push   %eax
80109251:	e8 30 ba ff ff       	call   80104c86 <memmove>
80109256:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925c:	83 c0 06             	add    $0x6,%eax
8010925f:	83 ec 04             	sub    $0x4,%esp
80109262:	6a 06                	push   $0x6
80109264:	68 68 d0 18 80       	push   $0x8018d068
80109269:	50                   	push   %eax
8010926a:	e8 17 ba ff ff       	call   80104c86 <memmove>
8010926f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109275:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010927a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927d:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109283:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109286:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010928a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109291:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109294:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010929a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929d:	8d 50 12             	lea    0x12(%eax),%edx
801092a0:	83 ec 04             	sub    $0x4,%esp
801092a3:	6a 06                	push   $0x6
801092a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801092a8:	50                   	push   %eax
801092a9:	52                   	push   %edx
801092aa:	e8 d7 b9 ff ff       	call   80104c86 <memmove>
801092af:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801092b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b5:	8d 50 18             	lea    0x18(%eax),%edx
801092b8:	83 ec 04             	sub    $0x4,%esp
801092bb:	6a 04                	push   $0x4
801092bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801092c0:	50                   	push   %eax
801092c1:	52                   	push   %edx
801092c2:	e8 bf b9 ff ff       	call   80104c86 <memmove>
801092c7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092cd:	83 c0 08             	add    $0x8,%eax
801092d0:	83 ec 04             	sub    $0x4,%esp
801092d3:	6a 06                	push   $0x6
801092d5:	68 68 d0 18 80       	push   $0x8018d068
801092da:	50                   	push   %eax
801092db:	e8 a6 b9 ff ff       	call   80104c86 <memmove>
801092e0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e6:	83 c0 0e             	add    $0xe,%eax
801092e9:	83 ec 04             	sub    $0x4,%esp
801092ec:	6a 04                	push   $0x4
801092ee:	68 e4 f4 10 80       	push   $0x8010f4e4
801092f3:	50                   	push   %eax
801092f4:	e8 8d b9 ff ff       	call   80104c86 <memmove>
801092f9:	83 c4 10             	add    $0x10,%esp
}
801092fc:	90                   	nop
801092fd:	c9                   	leave
801092fe:	c3                   	ret

801092ff <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801092ff:	f3 0f 1e fb          	endbr32
80109303:	55                   	push   %ebp
80109304:	89 e5                	mov    %esp,%ebp
80109306:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109309:	8b 45 08             	mov    0x8(%ebp),%eax
8010930c:	83 c0 0e             	add    $0xe,%eax
8010930f:	83 ec 0c             	sub    $0xc,%esp
80109312:	50                   	push   %eax
80109313:	e8 bc 00 00 00       	call   801093d4 <arp_table_search>
80109318:	83 c4 10             	add    $0x10,%esp
8010931b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010931e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109322:	78 2d                	js     80109351 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109324:	8b 45 08             	mov    0x8(%ebp),%eax
80109327:	8d 48 08             	lea    0x8(%eax),%ecx
8010932a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010932d:	89 d0                	mov    %edx,%eax
8010932f:	c1 e0 02             	shl    $0x2,%eax
80109332:	01 d0                	add    %edx,%eax
80109334:	01 c0                	add    %eax,%eax
80109336:	01 d0                	add    %edx,%eax
80109338:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010933d:	83 c0 04             	add    $0x4,%eax
80109340:	83 ec 04             	sub    $0x4,%esp
80109343:	6a 06                	push   $0x6
80109345:	51                   	push   %ecx
80109346:	50                   	push   %eax
80109347:	e8 3a b9 ff ff       	call   80104c86 <memmove>
8010934c:	83 c4 10             	add    $0x10,%esp
8010934f:	eb 70                	jmp    801093c1 <arp_table_update+0xc2>
  }else{
    index += 1;
80109351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109355:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109358:	8b 45 08             	mov    0x8(%ebp),%eax
8010935b:	8d 48 08             	lea    0x8(%eax),%ecx
8010935e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109361:	89 d0                	mov    %edx,%eax
80109363:	c1 e0 02             	shl    $0x2,%eax
80109366:	01 d0                	add    %edx,%eax
80109368:	01 c0                	add    %eax,%eax
8010936a:	01 d0                	add    %edx,%eax
8010936c:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109371:	83 c0 04             	add    $0x4,%eax
80109374:	83 ec 04             	sub    $0x4,%esp
80109377:	6a 06                	push   $0x6
80109379:	51                   	push   %ecx
8010937a:	50                   	push   %eax
8010937b:	e8 06 b9 ff ff       	call   80104c86 <memmove>
80109380:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109383:	8b 45 08             	mov    0x8(%ebp),%eax
80109386:	8d 48 0e             	lea    0xe(%eax),%ecx
80109389:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010938c:	89 d0                	mov    %edx,%eax
8010938e:	c1 e0 02             	shl    $0x2,%eax
80109391:	01 d0                	add    %edx,%eax
80109393:	01 c0                	add    %eax,%eax
80109395:	01 d0                	add    %edx,%eax
80109397:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010939c:	83 ec 04             	sub    $0x4,%esp
8010939f:	6a 04                	push   $0x4
801093a1:	51                   	push   %ecx
801093a2:	50                   	push   %eax
801093a3:	e8 de b8 ff ff       	call   80104c86 <memmove>
801093a8:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801093ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093ae:	89 d0                	mov    %edx,%eax
801093b0:	c1 e0 02             	shl    $0x2,%eax
801093b3:	01 d0                	add    %edx,%eax
801093b5:	01 c0                	add    %eax,%eax
801093b7:	01 d0                	add    %edx,%eax
801093b9:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801093be:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801093c1:	83 ec 0c             	sub    $0xc,%esp
801093c4:	68 80 d0 18 80       	push   $0x8018d080
801093c9:	e8 87 00 00 00       	call   80109455 <print_arp_table>
801093ce:	83 c4 10             	add    $0x10,%esp
}
801093d1:	90                   	nop
801093d2:	c9                   	leave
801093d3:	c3                   	ret

801093d4 <arp_table_search>:

int arp_table_search(uchar *ip){
801093d4:	f3 0f 1e fb          	endbr32
801093d8:	55                   	push   %ebp
801093d9:	89 e5                	mov    %esp,%ebp
801093db:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801093de:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801093e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801093ec:	eb 59                	jmp    80109447 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801093ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801093f1:	89 d0                	mov    %edx,%eax
801093f3:	c1 e0 02             	shl    $0x2,%eax
801093f6:	01 d0                	add    %edx,%eax
801093f8:	01 c0                	add    %eax,%eax
801093fa:	01 d0                	add    %edx,%eax
801093fc:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109401:	83 ec 04             	sub    $0x4,%esp
80109404:	6a 04                	push   $0x4
80109406:	ff 75 08             	push   0x8(%ebp)
80109409:	50                   	push   %eax
8010940a:	e8 1b b8 ff ff       	call   80104c2a <memcmp>
8010940f:	83 c4 10             	add    $0x10,%esp
80109412:	85 c0                	test   %eax,%eax
80109414:	75 05                	jne    8010941b <arp_table_search+0x47>
      return i;
80109416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109419:	eb 38                	jmp    80109453 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010941b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010941e:	89 d0                	mov    %edx,%eax
80109420:	c1 e0 02             	shl    $0x2,%eax
80109423:	01 d0                	add    %edx,%eax
80109425:	01 c0                	add    %eax,%eax
80109427:	01 d0                	add    %edx,%eax
80109429:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010942e:	0f b6 00             	movzbl (%eax),%eax
80109431:	84 c0                	test   %al,%al
80109433:	75 0e                	jne    80109443 <arp_table_search+0x6f>
80109435:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109439:	75 08                	jne    80109443 <arp_table_search+0x6f>
      empty = -i;
8010943b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943e:	f7 d8                	neg    %eax
80109440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109443:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109447:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010944b:	7e a1                	jle    801093ee <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010944d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109450:	83 e8 01             	sub    $0x1,%eax
}
80109453:	c9                   	leave
80109454:	c3                   	ret

80109455 <print_arp_table>:

void print_arp_table(){
80109455:	f3 0f 1e fb          	endbr32
80109459:	55                   	push   %ebp
8010945a:	89 e5                	mov    %esp,%ebp
8010945c:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010945f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109466:	e9 92 00 00 00       	jmp    801094fd <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010946b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010946e:	89 d0                	mov    %edx,%eax
80109470:	c1 e0 02             	shl    $0x2,%eax
80109473:	01 d0                	add    %edx,%eax
80109475:	01 c0                	add    %eax,%eax
80109477:	01 d0                	add    %edx,%eax
80109479:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010947e:	0f b6 00             	movzbl (%eax),%eax
80109481:	84 c0                	test   %al,%al
80109483:	74 74                	je     801094f9 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109485:	83 ec 08             	sub    $0x8,%esp
80109488:	ff 75 f4             	push   -0xc(%ebp)
8010948b:	68 4f c3 10 80       	push   $0x8010c34f
80109490:	e8 77 6f ff ff       	call   8010040c <cprintf>
80109495:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109498:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010949b:	89 d0                	mov    %edx,%eax
8010949d:	c1 e0 02             	shl    $0x2,%eax
801094a0:	01 d0                	add    %edx,%eax
801094a2:	01 c0                	add    %eax,%eax
801094a4:	01 d0                	add    %edx,%eax
801094a6:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094ab:	83 ec 0c             	sub    $0xc,%esp
801094ae:	50                   	push   %eax
801094af:	e8 5c 02 00 00       	call   80109710 <print_ipv4>
801094b4:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801094b7:	83 ec 0c             	sub    $0xc,%esp
801094ba:	68 5e c3 10 80       	push   $0x8010c35e
801094bf:	e8 48 6f ff ff       	call   8010040c <cprintf>
801094c4:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801094c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094ca:	89 d0                	mov    %edx,%eax
801094cc:	c1 e0 02             	shl    $0x2,%eax
801094cf:	01 d0                	add    %edx,%eax
801094d1:	01 c0                	add    %eax,%eax
801094d3:	01 d0                	add    %edx,%eax
801094d5:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094da:	83 c0 04             	add    $0x4,%eax
801094dd:	83 ec 0c             	sub    $0xc,%esp
801094e0:	50                   	push   %eax
801094e1:	e8 7c 02 00 00       	call   80109762 <print_mac>
801094e6:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801094e9:	83 ec 0c             	sub    $0xc,%esp
801094ec:	68 60 c3 10 80       	push   $0x8010c360
801094f1:	e8 16 6f ff ff       	call   8010040c <cprintf>
801094f6:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801094f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094fd:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109501:	0f 8e 64 ff ff ff    	jle    8010946b <print_arp_table+0x16>
    }
  }
}
80109507:	90                   	nop
80109508:	90                   	nop
80109509:	c9                   	leave
8010950a:	c3                   	ret

8010950b <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010950b:	f3 0f 1e fb          	endbr32
8010950f:	55                   	push   %ebp
80109510:	89 e5                	mov    %esp,%ebp
80109512:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109515:	8b 45 10             	mov    0x10(%ebp),%eax
80109518:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010951e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109524:	8b 45 0c             	mov    0xc(%ebp),%eax
80109527:	83 c0 0e             	add    $0xe,%eax
8010952a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010952d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109530:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109537:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010953b:	8b 45 08             	mov    0x8(%ebp),%eax
8010953e:	8d 50 08             	lea    0x8(%eax),%edx
80109541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109544:	83 ec 04             	sub    $0x4,%esp
80109547:	6a 06                	push   $0x6
80109549:	52                   	push   %edx
8010954a:	50                   	push   %eax
8010954b:	e8 36 b7 ff ff       	call   80104c86 <memmove>
80109550:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109556:	83 c0 06             	add    $0x6,%eax
80109559:	83 ec 04             	sub    $0x4,%esp
8010955c:	6a 06                	push   $0x6
8010955e:	68 68 d0 18 80       	push   $0x8018d068
80109563:	50                   	push   %eax
80109564:	e8 1d b7 ff ff       	call   80104c86 <memmove>
80109569:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010956c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109577:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010957d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109580:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109587:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010958b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010958e:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109594:	8b 45 08             	mov    0x8(%ebp),%eax
80109597:	8d 50 08             	lea    0x8(%eax),%edx
8010959a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010959d:	83 c0 12             	add    $0x12,%eax
801095a0:	83 ec 04             	sub    $0x4,%esp
801095a3:	6a 06                	push   $0x6
801095a5:	52                   	push   %edx
801095a6:	50                   	push   %eax
801095a7:	e8 da b6 ff ff       	call   80104c86 <memmove>
801095ac:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801095af:	8b 45 08             	mov    0x8(%ebp),%eax
801095b2:	8d 50 0e             	lea    0xe(%eax),%edx
801095b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095b8:	83 c0 18             	add    $0x18,%eax
801095bb:	83 ec 04             	sub    $0x4,%esp
801095be:	6a 04                	push   $0x4
801095c0:	52                   	push   %edx
801095c1:	50                   	push   %eax
801095c2:	e8 bf b6 ff ff       	call   80104c86 <memmove>
801095c7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095cd:	83 c0 08             	add    $0x8,%eax
801095d0:	83 ec 04             	sub    $0x4,%esp
801095d3:	6a 06                	push   $0x6
801095d5:	68 68 d0 18 80       	push   $0x8018d068
801095da:	50                   	push   %eax
801095db:	e8 a6 b6 ff ff       	call   80104c86 <memmove>
801095e0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e6:	83 c0 0e             	add    $0xe,%eax
801095e9:	83 ec 04             	sub    $0x4,%esp
801095ec:	6a 04                	push   $0x4
801095ee:	68 e4 f4 10 80       	push   $0x8010f4e4
801095f3:	50                   	push   %eax
801095f4:	e8 8d b6 ff ff       	call   80104c86 <memmove>
801095f9:	83 c4 10             	add    $0x10,%esp
}
801095fc:	90                   	nop
801095fd:	c9                   	leave
801095fe:	c3                   	ret

801095ff <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801095ff:	f3 0f 1e fb          	endbr32
80109603:	55                   	push   %ebp
80109604:	89 e5                	mov    %esp,%ebp
80109606:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109609:	83 ec 0c             	sub    $0xc,%esp
8010960c:	68 62 c3 10 80       	push   $0x8010c362
80109611:	e8 f6 6d ff ff       	call   8010040c <cprintf>
80109616:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109619:	8b 45 08             	mov    0x8(%ebp),%eax
8010961c:	83 c0 0e             	add    $0xe,%eax
8010961f:	83 ec 0c             	sub    $0xc,%esp
80109622:	50                   	push   %eax
80109623:	e8 e8 00 00 00       	call   80109710 <print_ipv4>
80109628:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010962b:	83 ec 0c             	sub    $0xc,%esp
8010962e:	68 60 c3 10 80       	push   $0x8010c360
80109633:	e8 d4 6d ff ff       	call   8010040c <cprintf>
80109638:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010963b:	8b 45 08             	mov    0x8(%ebp),%eax
8010963e:	83 c0 08             	add    $0x8,%eax
80109641:	83 ec 0c             	sub    $0xc,%esp
80109644:	50                   	push   %eax
80109645:	e8 18 01 00 00       	call   80109762 <print_mac>
8010964a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010964d:	83 ec 0c             	sub    $0xc,%esp
80109650:	68 60 c3 10 80       	push   $0x8010c360
80109655:	e8 b2 6d ff ff       	call   8010040c <cprintf>
8010965a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010965d:	83 ec 0c             	sub    $0xc,%esp
80109660:	68 79 c3 10 80       	push   $0x8010c379
80109665:	e8 a2 6d ff ff       	call   8010040c <cprintf>
8010966a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010966d:	8b 45 08             	mov    0x8(%ebp),%eax
80109670:	83 c0 18             	add    $0x18,%eax
80109673:	83 ec 0c             	sub    $0xc,%esp
80109676:	50                   	push   %eax
80109677:	e8 94 00 00 00       	call   80109710 <print_ipv4>
8010967c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010967f:	83 ec 0c             	sub    $0xc,%esp
80109682:	68 60 c3 10 80       	push   $0x8010c360
80109687:	e8 80 6d ff ff       	call   8010040c <cprintf>
8010968c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010968f:	8b 45 08             	mov    0x8(%ebp),%eax
80109692:	83 c0 12             	add    $0x12,%eax
80109695:	83 ec 0c             	sub    $0xc,%esp
80109698:	50                   	push   %eax
80109699:	e8 c4 00 00 00       	call   80109762 <print_mac>
8010969e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096a1:	83 ec 0c             	sub    $0xc,%esp
801096a4:	68 60 c3 10 80       	push   $0x8010c360
801096a9:	e8 5e 6d ff ff       	call   8010040c <cprintf>
801096ae:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801096b1:	83 ec 0c             	sub    $0xc,%esp
801096b4:	68 90 c3 10 80       	push   $0x8010c390
801096b9:	e8 4e 6d ff ff       	call   8010040c <cprintf>
801096be:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801096c1:	8b 45 08             	mov    0x8(%ebp),%eax
801096c4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096c8:	66 3d 00 01          	cmp    $0x100,%ax
801096cc:	75 12                	jne    801096e0 <print_arp_info+0xe1>
801096ce:	83 ec 0c             	sub    $0xc,%esp
801096d1:	68 9c c3 10 80       	push   $0x8010c39c
801096d6:	e8 31 6d ff ff       	call   8010040c <cprintf>
801096db:	83 c4 10             	add    $0x10,%esp
801096de:	eb 1d                	jmp    801096fd <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801096e0:	8b 45 08             	mov    0x8(%ebp),%eax
801096e3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096e7:	66 3d 00 02          	cmp    $0x200,%ax
801096eb:	75 10                	jne    801096fd <print_arp_info+0xfe>
    cprintf("Reply\n");
801096ed:	83 ec 0c             	sub    $0xc,%esp
801096f0:	68 a5 c3 10 80       	push   $0x8010c3a5
801096f5:	e8 12 6d ff ff       	call   8010040c <cprintf>
801096fa:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801096fd:	83 ec 0c             	sub    $0xc,%esp
80109700:	68 60 c3 10 80       	push   $0x8010c360
80109705:	e8 02 6d ff ff       	call   8010040c <cprintf>
8010970a:	83 c4 10             	add    $0x10,%esp
}
8010970d:	90                   	nop
8010970e:	c9                   	leave
8010970f:	c3                   	ret

80109710 <print_ipv4>:

void print_ipv4(uchar *ip){
80109710:	f3 0f 1e fb          	endbr32
80109714:	55                   	push   %ebp
80109715:	89 e5                	mov    %esp,%ebp
80109717:	53                   	push   %ebx
80109718:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010971b:	8b 45 08             	mov    0x8(%ebp),%eax
8010971e:	83 c0 03             	add    $0x3,%eax
80109721:	0f b6 00             	movzbl (%eax),%eax
80109724:	0f b6 d8             	movzbl %al,%ebx
80109727:	8b 45 08             	mov    0x8(%ebp),%eax
8010972a:	83 c0 02             	add    $0x2,%eax
8010972d:	0f b6 00             	movzbl (%eax),%eax
80109730:	0f b6 c8             	movzbl %al,%ecx
80109733:	8b 45 08             	mov    0x8(%ebp),%eax
80109736:	83 c0 01             	add    $0x1,%eax
80109739:	0f b6 00             	movzbl (%eax),%eax
8010973c:	0f b6 d0             	movzbl %al,%edx
8010973f:	8b 45 08             	mov    0x8(%ebp),%eax
80109742:	0f b6 00             	movzbl (%eax),%eax
80109745:	0f b6 c0             	movzbl %al,%eax
80109748:	83 ec 0c             	sub    $0xc,%esp
8010974b:	53                   	push   %ebx
8010974c:	51                   	push   %ecx
8010974d:	52                   	push   %edx
8010974e:	50                   	push   %eax
8010974f:	68 ac c3 10 80       	push   $0x8010c3ac
80109754:	e8 b3 6c ff ff       	call   8010040c <cprintf>
80109759:	83 c4 20             	add    $0x20,%esp
}
8010975c:	90                   	nop
8010975d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109760:	c9                   	leave
80109761:	c3                   	ret

80109762 <print_mac>:

void print_mac(uchar *mac){
80109762:	f3 0f 1e fb          	endbr32
80109766:	55                   	push   %ebp
80109767:	89 e5                	mov    %esp,%ebp
80109769:	57                   	push   %edi
8010976a:	56                   	push   %esi
8010976b:	53                   	push   %ebx
8010976c:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010976f:	8b 45 08             	mov    0x8(%ebp),%eax
80109772:	83 c0 05             	add    $0x5,%eax
80109775:	0f b6 00             	movzbl (%eax),%eax
80109778:	0f b6 f8             	movzbl %al,%edi
8010977b:	8b 45 08             	mov    0x8(%ebp),%eax
8010977e:	83 c0 04             	add    $0x4,%eax
80109781:	0f b6 00             	movzbl (%eax),%eax
80109784:	0f b6 f0             	movzbl %al,%esi
80109787:	8b 45 08             	mov    0x8(%ebp),%eax
8010978a:	83 c0 03             	add    $0x3,%eax
8010978d:	0f b6 00             	movzbl (%eax),%eax
80109790:	0f b6 d8             	movzbl %al,%ebx
80109793:	8b 45 08             	mov    0x8(%ebp),%eax
80109796:	83 c0 02             	add    $0x2,%eax
80109799:	0f b6 00             	movzbl (%eax),%eax
8010979c:	0f b6 c8             	movzbl %al,%ecx
8010979f:	8b 45 08             	mov    0x8(%ebp),%eax
801097a2:	83 c0 01             	add    $0x1,%eax
801097a5:	0f b6 00             	movzbl (%eax),%eax
801097a8:	0f b6 d0             	movzbl %al,%edx
801097ab:	8b 45 08             	mov    0x8(%ebp),%eax
801097ae:	0f b6 00             	movzbl (%eax),%eax
801097b1:	0f b6 c0             	movzbl %al,%eax
801097b4:	83 ec 04             	sub    $0x4,%esp
801097b7:	57                   	push   %edi
801097b8:	56                   	push   %esi
801097b9:	53                   	push   %ebx
801097ba:	51                   	push   %ecx
801097bb:	52                   	push   %edx
801097bc:	50                   	push   %eax
801097bd:	68 c4 c3 10 80       	push   $0x8010c3c4
801097c2:	e8 45 6c ff ff       	call   8010040c <cprintf>
801097c7:	83 c4 20             	add    $0x20,%esp
}
801097ca:	90                   	nop
801097cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801097ce:	5b                   	pop    %ebx
801097cf:	5e                   	pop    %esi
801097d0:	5f                   	pop    %edi
801097d1:	5d                   	pop    %ebp
801097d2:	c3                   	ret

801097d3 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801097d3:	f3 0f 1e fb          	endbr32
801097d7:	55                   	push   %ebp
801097d8:	89 e5                	mov    %esp,%ebp
801097da:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801097dd:	8b 45 08             	mov    0x8(%ebp),%eax
801097e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801097e3:	8b 45 08             	mov    0x8(%ebp),%eax
801097e6:	83 c0 0e             	add    $0xe,%eax
801097e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801097ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ef:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801097f3:	3c 08                	cmp    $0x8,%al
801097f5:	75 1b                	jne    80109812 <eth_proc+0x3f>
801097f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fa:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801097fe:	3c 06                	cmp    $0x6,%al
80109800:	75 10                	jne    80109812 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109802:	83 ec 0c             	sub    $0xc,%esp
80109805:	ff 75 f0             	push   -0x10(%ebp)
80109808:	e8 d5 f7 ff ff       	call   80108fe2 <arp_proc>
8010980d:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109810:	eb 24                	jmp    80109836 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109815:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109819:	3c 08                	cmp    $0x8,%al
8010981b:	75 19                	jne    80109836 <eth_proc+0x63>
8010981d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109820:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109824:	84 c0                	test   %al,%al
80109826:	75 0e                	jne    80109836 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109828:	83 ec 0c             	sub    $0xc,%esp
8010982b:	ff 75 08             	push   0x8(%ebp)
8010982e:	e8 b3 00 00 00       	call   801098e6 <ipv4_proc>
80109833:	83 c4 10             	add    $0x10,%esp
}
80109836:	90                   	nop
80109837:	c9                   	leave
80109838:	c3                   	ret

80109839 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109839:	f3 0f 1e fb          	endbr32
8010983d:	55                   	push   %ebp
8010983e:	89 e5                	mov    %esp,%ebp
80109840:	83 ec 04             	sub    $0x4,%esp
80109843:	8b 45 08             	mov    0x8(%ebp),%eax
80109846:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010984a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010984e:	c1 e0 08             	shl    $0x8,%eax
80109851:	89 c2                	mov    %eax,%edx
80109853:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109857:	66 c1 e8 08          	shr    $0x8,%ax
8010985b:	01 d0                	add    %edx,%eax
}
8010985d:	c9                   	leave
8010985e:	c3                   	ret

8010985f <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010985f:	f3 0f 1e fb          	endbr32
80109863:	55                   	push   %ebp
80109864:	89 e5                	mov    %esp,%ebp
80109866:	83 ec 04             	sub    $0x4,%esp
80109869:	8b 45 08             	mov    0x8(%ebp),%eax
8010986c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109870:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109874:	c1 e0 08             	shl    $0x8,%eax
80109877:	89 c2                	mov    %eax,%edx
80109879:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010987d:	66 c1 e8 08          	shr    $0x8,%ax
80109881:	01 d0                	add    %edx,%eax
}
80109883:	c9                   	leave
80109884:	c3                   	ret

80109885 <H2N_uint>:

uint H2N_uint(uint value){
80109885:	f3 0f 1e fb          	endbr32
80109889:	55                   	push   %ebp
8010988a:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010988c:	8b 45 08             	mov    0x8(%ebp),%eax
8010988f:	c1 e0 18             	shl    $0x18,%eax
80109892:	25 00 00 00 0f       	and    $0xf000000,%eax
80109897:	89 c2                	mov    %eax,%edx
80109899:	8b 45 08             	mov    0x8(%ebp),%eax
8010989c:	c1 e0 08             	shl    $0x8,%eax
8010989f:	25 00 f0 00 00       	and    $0xf000,%eax
801098a4:	09 c2                	or     %eax,%edx
801098a6:	8b 45 08             	mov    0x8(%ebp),%eax
801098a9:	c1 e8 08             	shr    $0x8,%eax
801098ac:	83 e0 0f             	and    $0xf,%eax
801098af:	01 d0                	add    %edx,%eax
}
801098b1:	5d                   	pop    %ebp
801098b2:	c3                   	ret

801098b3 <N2H_uint>:

uint N2H_uint(uint value){
801098b3:	f3 0f 1e fb          	endbr32
801098b7:	55                   	push   %ebp
801098b8:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801098ba:	8b 45 08             	mov    0x8(%ebp),%eax
801098bd:	c1 e0 18             	shl    $0x18,%eax
801098c0:	89 c2                	mov    %eax,%edx
801098c2:	8b 45 08             	mov    0x8(%ebp),%eax
801098c5:	c1 e0 08             	shl    $0x8,%eax
801098c8:	25 00 00 ff 00       	and    $0xff0000,%eax
801098cd:	01 c2                	add    %eax,%edx
801098cf:	8b 45 08             	mov    0x8(%ebp),%eax
801098d2:	c1 e8 08             	shr    $0x8,%eax
801098d5:	25 00 ff 00 00       	and    $0xff00,%eax
801098da:	01 c2                	add    %eax,%edx
801098dc:	8b 45 08             	mov    0x8(%ebp),%eax
801098df:	c1 e8 18             	shr    $0x18,%eax
801098e2:	01 d0                	add    %edx,%eax
}
801098e4:	5d                   	pop    %ebp
801098e5:	c3                   	ret

801098e6 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801098e6:	f3 0f 1e fb          	endbr32
801098ea:	55                   	push   %ebp
801098eb:	89 e5                	mov    %esp,%ebp
801098ed:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801098f0:	8b 45 08             	mov    0x8(%ebp),%eax
801098f3:	83 c0 0e             	add    $0xe,%eax
801098f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801098f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109900:	0f b7 d0             	movzwl %ax,%edx
80109903:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109908:	39 c2                	cmp    %eax,%edx
8010990a:	74 60                	je     8010996c <ipv4_proc+0x86>
8010990c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010990f:	83 c0 0c             	add    $0xc,%eax
80109912:	83 ec 04             	sub    $0x4,%esp
80109915:	6a 04                	push   $0x4
80109917:	50                   	push   %eax
80109918:	68 e4 f4 10 80       	push   $0x8010f4e4
8010991d:	e8 08 b3 ff ff       	call   80104c2a <memcmp>
80109922:	83 c4 10             	add    $0x10,%esp
80109925:	85 c0                	test   %eax,%eax
80109927:	74 43                	je     8010996c <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109930:	0f b7 c0             	movzwl %ax,%eax
80109933:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010993b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010993f:	3c 01                	cmp    $0x1,%al
80109941:	75 10                	jne    80109953 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109943:	83 ec 0c             	sub    $0xc,%esp
80109946:	ff 75 08             	push   0x8(%ebp)
80109949:	e8 a7 00 00 00       	call   801099f5 <icmp_proc>
8010994e:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109951:	eb 19                	jmp    8010996c <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109956:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010995a:	3c 06                	cmp    $0x6,%al
8010995c:	75 0e                	jne    8010996c <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010995e:	83 ec 0c             	sub    $0xc,%esp
80109961:	ff 75 08             	push   0x8(%ebp)
80109964:	e8 c7 03 00 00       	call   80109d30 <tcp_proc>
80109969:	83 c4 10             	add    $0x10,%esp
}
8010996c:	90                   	nop
8010996d:	c9                   	leave
8010996e:	c3                   	ret

8010996f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010996f:	f3 0f 1e fb          	endbr32
80109973:	55                   	push   %ebp
80109974:	89 e5                	mov    %esp,%ebp
80109976:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109979:	8b 45 08             	mov    0x8(%ebp),%eax
8010997c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010997f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109982:	0f b6 00             	movzbl (%eax),%eax
80109985:	83 e0 0f             	and    $0xf,%eax
80109988:	01 c0                	add    %eax,%eax
8010998a:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010998d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109994:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010999b:	eb 48                	jmp    801099e5 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010999d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099a0:	01 c0                	add    %eax,%eax
801099a2:	89 c2                	mov    %eax,%edx
801099a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a7:	01 d0                	add    %edx,%eax
801099a9:	0f b6 00             	movzbl (%eax),%eax
801099ac:	0f b6 c0             	movzbl %al,%eax
801099af:	c1 e0 08             	shl    $0x8,%eax
801099b2:	89 c2                	mov    %eax,%edx
801099b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099b7:	01 c0                	add    %eax,%eax
801099b9:	8d 48 01             	lea    0x1(%eax),%ecx
801099bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099bf:	01 c8                	add    %ecx,%eax
801099c1:	0f b6 00             	movzbl (%eax),%eax
801099c4:	0f b6 c0             	movzbl %al,%eax
801099c7:	01 d0                	add    %edx,%eax
801099c9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099cc:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099d3:	76 0c                	jbe    801099e1 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
801099d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099d8:	0f b7 c0             	movzwl %ax,%eax
801099db:	83 c0 01             	add    $0x1,%eax
801099de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801099e1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099e5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801099e9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801099ec:	7c af                	jl     8010999d <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
801099ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099f1:	f7 d0                	not    %eax
}
801099f3:	c9                   	leave
801099f4:	c3                   	ret

801099f5 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801099f5:	f3 0f 1e fb          	endbr32
801099f9:	55                   	push   %ebp
801099fa:	89 e5                	mov    %esp,%ebp
801099fc:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801099ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109a02:	83 c0 0e             	add    $0xe,%eax
80109a05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0b:	0f b6 00             	movzbl (%eax),%eax
80109a0e:	0f b6 c0             	movzbl %al,%eax
80109a11:	83 e0 0f             	and    $0xf,%eax
80109a14:	c1 e0 02             	shl    $0x2,%eax
80109a17:	89 c2                	mov    %eax,%edx
80109a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1c:	01 d0                	add    %edx,%eax
80109a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a24:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a28:	84 c0                	test   %al,%al
80109a2a:	75 4f                	jne    80109a7b <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2f:	0f b6 00             	movzbl (%eax),%eax
80109a32:	3c 08                	cmp    $0x8,%al
80109a34:	75 45                	jne    80109a7b <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109a36:	e8 57 8e ff ff       	call   80102892 <kalloc>
80109a3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109a3e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109a45:	83 ec 04             	sub    $0x4,%esp
80109a48:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109a4b:	50                   	push   %eax
80109a4c:	ff 75 ec             	push   -0x14(%ebp)
80109a4f:	ff 75 08             	push   0x8(%ebp)
80109a52:	e8 7c 00 00 00       	call   80109ad3 <icmp_reply_pkt_create>
80109a57:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109a5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a5d:	83 ec 08             	sub    $0x8,%esp
80109a60:	50                   	push   %eax
80109a61:	ff 75 ec             	push   -0x14(%ebp)
80109a64:	e8 43 f4 ff ff       	call   80108eac <i8254_send>
80109a69:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a6f:	83 ec 0c             	sub    $0xc,%esp
80109a72:	50                   	push   %eax
80109a73:	e8 7c 8d ff ff       	call   801027f4 <kfree>
80109a78:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109a7b:	90                   	nop
80109a7c:	c9                   	leave
80109a7d:	c3                   	ret

80109a7e <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109a7e:	f3 0f 1e fb          	endbr32
80109a82:	55                   	push   %ebp
80109a83:	89 e5                	mov    %esp,%ebp
80109a85:	53                   	push   %ebx
80109a86:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109a89:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a90:	0f b7 c0             	movzwl %ax,%eax
80109a93:	83 ec 0c             	sub    $0xc,%esp
80109a96:	50                   	push   %eax
80109a97:	e8 9d fd ff ff       	call   80109839 <N2H_ushort>
80109a9c:	83 c4 10             	add    $0x10,%esp
80109a9f:	0f b7 d8             	movzwl %ax,%ebx
80109aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109aa9:	0f b7 c0             	movzwl %ax,%eax
80109aac:	83 ec 0c             	sub    $0xc,%esp
80109aaf:	50                   	push   %eax
80109ab0:	e8 84 fd ff ff       	call   80109839 <N2H_ushort>
80109ab5:	83 c4 10             	add    $0x10,%esp
80109ab8:	0f b7 c0             	movzwl %ax,%eax
80109abb:	83 ec 04             	sub    $0x4,%esp
80109abe:	53                   	push   %ebx
80109abf:	50                   	push   %eax
80109ac0:	68 e3 c3 10 80       	push   $0x8010c3e3
80109ac5:	e8 42 69 ff ff       	call   8010040c <cprintf>
80109aca:	83 c4 10             	add    $0x10,%esp
}
80109acd:	90                   	nop
80109ace:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ad1:	c9                   	leave
80109ad2:	c3                   	ret

80109ad3 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109ad3:	f3 0f 1e fb          	endbr32
80109ad7:	55                   	push   %ebp
80109ad8:	89 e5                	mov    %esp,%ebp
80109ada:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109add:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae6:	83 c0 0e             	add    $0xe,%eax
80109ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aef:	0f b6 00             	movzbl (%eax),%eax
80109af2:	0f b6 c0             	movzbl %al,%eax
80109af5:	83 e0 0f             	and    $0xf,%eax
80109af8:	c1 e0 02             	shl    $0x2,%eax
80109afb:	89 c2                	mov    %eax,%edx
80109afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b00:	01 d0                	add    %edx,%eax
80109b02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b05:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b08:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b0e:	83 c0 0e             	add    $0xe,%eax
80109b11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b17:	83 c0 14             	add    $0x14,%eax
80109b1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b1d:	8b 45 10             	mov    0x10(%ebp),%eax
80109b20:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b29:	8d 50 06             	lea    0x6(%eax),%edx
80109b2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b2f:	83 ec 04             	sub    $0x4,%esp
80109b32:	6a 06                	push   $0x6
80109b34:	52                   	push   %edx
80109b35:	50                   	push   %eax
80109b36:	e8 4b b1 ff ff       	call   80104c86 <memmove>
80109b3b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b41:	83 c0 06             	add    $0x6,%eax
80109b44:	83 ec 04             	sub    $0x4,%esp
80109b47:	6a 06                	push   $0x6
80109b49:	68 68 d0 18 80       	push   $0x8018d068
80109b4e:	50                   	push   %eax
80109b4f:	e8 32 b1 ff ff       	call   80104c86 <memmove>
80109b54:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b5a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b61:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b68:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109b72:	83 ec 0c             	sub    $0xc,%esp
80109b75:	6a 54                	push   $0x54
80109b77:	e8 e3 fc ff ff       	call   8010985f <H2N_ushort>
80109b7c:	83 c4 10             	add    $0x10,%esp
80109b7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b82:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b86:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b90:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b94:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109b9b:	83 c0 01             	add    $0x1,%eax
80109b9e:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109ba4:	83 ec 0c             	sub    $0xc,%esp
80109ba7:	68 00 40 00 00       	push   $0x4000
80109bac:	e8 ae fc ff ff       	call   8010985f <H2N_ushort>
80109bb1:	83 c4 10             	add    $0x10,%esp
80109bb4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bb7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bbe:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bcc:	83 c0 0c             	add    $0xc,%eax
80109bcf:	83 ec 04             	sub    $0x4,%esp
80109bd2:	6a 04                	push   $0x4
80109bd4:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bd9:	50                   	push   %eax
80109bda:	e8 a7 b0 ff ff       	call   80104c86 <memmove>
80109bdf:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be5:	8d 50 0c             	lea    0xc(%eax),%edx
80109be8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109beb:	83 c0 10             	add    $0x10,%eax
80109bee:	83 ec 04             	sub    $0x4,%esp
80109bf1:	6a 04                	push   $0x4
80109bf3:	52                   	push   %edx
80109bf4:	50                   	push   %eax
80109bf5:	e8 8c b0 ff ff       	call   80104c86 <memmove>
80109bfa:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c00:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c09:	83 ec 0c             	sub    $0xc,%esp
80109c0c:	50                   	push   %eax
80109c0d:	e8 5d fd ff ff       	call   8010996f <ipv4_chksum>
80109c12:	83 c4 10             	add    $0x10,%esp
80109c15:	0f b7 c0             	movzwl %ax,%eax
80109c18:	83 ec 0c             	sub    $0xc,%esp
80109c1b:	50                   	push   %eax
80109c1c:	e8 3e fc ff ff       	call   8010985f <H2N_ushort>
80109c21:	83 c4 10             	add    $0x10,%esp
80109c24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c27:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c2e:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c34:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c3b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109c3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c42:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c49:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109c4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c50:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c57:	8d 50 08             	lea    0x8(%eax),%edx
80109c5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5d:	83 c0 08             	add    $0x8,%eax
80109c60:	83 ec 04             	sub    $0x4,%esp
80109c63:	6a 08                	push   $0x8
80109c65:	52                   	push   %edx
80109c66:	50                   	push   %eax
80109c67:	e8 1a b0 ff ff       	call   80104c86 <memmove>
80109c6c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109c6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c72:	8d 50 10             	lea    0x10(%eax),%edx
80109c75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c78:	83 c0 10             	add    $0x10,%eax
80109c7b:	83 ec 04             	sub    $0x4,%esp
80109c7e:	6a 30                	push   $0x30
80109c80:	52                   	push   %edx
80109c81:	50                   	push   %eax
80109c82:	e8 ff af ff ff       	call   80104c86 <memmove>
80109c87:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c8d:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c96:	83 ec 0c             	sub    $0xc,%esp
80109c99:	50                   	push   %eax
80109c9a:	e8 1c 00 00 00       	call   80109cbb <icmp_chksum>
80109c9f:	83 c4 10             	add    $0x10,%esp
80109ca2:	0f b7 c0             	movzwl %ax,%eax
80109ca5:	83 ec 0c             	sub    $0xc,%esp
80109ca8:	50                   	push   %eax
80109ca9:	e8 b1 fb ff ff       	call   8010985f <H2N_ushort>
80109cae:	83 c4 10             	add    $0x10,%esp
80109cb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109cb4:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109cb8:	90                   	nop
80109cb9:	c9                   	leave
80109cba:	c3                   	ret

80109cbb <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109cbb:	f3 0f 1e fb          	endbr32
80109cbf:	55                   	push   %ebp
80109cc0:	89 e5                	mov    %esp,%ebp
80109cc2:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80109cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109ccb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109cd2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109cd9:	eb 48                	jmp    80109d23 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109cdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cde:	01 c0                	add    %eax,%eax
80109ce0:	89 c2                	mov    %eax,%edx
80109ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce5:	01 d0                	add    %edx,%eax
80109ce7:	0f b6 00             	movzbl (%eax),%eax
80109cea:	0f b6 c0             	movzbl %al,%eax
80109ced:	c1 e0 08             	shl    $0x8,%eax
80109cf0:	89 c2                	mov    %eax,%edx
80109cf2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cf5:	01 c0                	add    %eax,%eax
80109cf7:	8d 48 01             	lea    0x1(%eax),%ecx
80109cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfd:	01 c8                	add    %ecx,%eax
80109cff:	0f b6 00             	movzbl (%eax),%eax
80109d02:	0f b6 c0             	movzbl %al,%eax
80109d05:	01 d0                	add    %edx,%eax
80109d07:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d0a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d11:	76 0c                	jbe    80109d1f <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d13:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d16:	0f b7 c0             	movzwl %ax,%eax
80109d19:	83 c0 01             	add    $0x1,%eax
80109d1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d1f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d23:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d27:	7e b2                	jle    80109cdb <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109d29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d2c:	f7 d0                	not    %eax
}
80109d2e:	c9                   	leave
80109d2f:	c3                   	ret

80109d30 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d30:	f3 0f 1e fb          	endbr32
80109d34:	55                   	push   %ebp
80109d35:	89 e5                	mov    %esp,%ebp
80109d37:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d3d:	83 c0 0e             	add    $0xe,%eax
80109d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d46:	0f b6 00             	movzbl (%eax),%eax
80109d49:	0f b6 c0             	movzbl %al,%eax
80109d4c:	83 e0 0f             	and    $0xf,%eax
80109d4f:	c1 e0 02             	shl    $0x2,%eax
80109d52:	89 c2                	mov    %eax,%edx
80109d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d57:	01 d0                	add    %edx,%eax
80109d59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d5f:	83 c0 14             	add    $0x14,%eax
80109d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109d65:	e8 28 8b ff ff       	call   80102892 <kalloc>
80109d6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109d6d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d77:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d7b:	0f b6 c0             	movzbl %al,%eax
80109d7e:	83 e0 02             	and    $0x2,%eax
80109d81:	85 c0                	test   %eax,%eax
80109d83:	74 3d                	je     80109dc2 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109d85:	83 ec 0c             	sub    $0xc,%esp
80109d88:	6a 00                	push   $0x0
80109d8a:	6a 12                	push   $0x12
80109d8c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d8f:	50                   	push   %eax
80109d90:	ff 75 e8             	push   -0x18(%ebp)
80109d93:	ff 75 08             	push   0x8(%ebp)
80109d96:	e8 a2 01 00 00       	call   80109f3d <tcp_pkt_create>
80109d9b:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109d9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109da1:	83 ec 08             	sub    $0x8,%esp
80109da4:	50                   	push   %eax
80109da5:	ff 75 e8             	push   -0x18(%ebp)
80109da8:	e8 ff f0 ff ff       	call   80108eac <i8254_send>
80109dad:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109db0:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109db5:	83 c0 01             	add    $0x1,%eax
80109db8:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109dbd:	e9 69 01 00 00       	jmp    80109f2b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109dc9:	3c 18                	cmp    $0x18,%al
80109dcb:	0f 85 10 01 00 00    	jne    80109ee1 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109dd1:	83 ec 04             	sub    $0x4,%esp
80109dd4:	6a 03                	push   $0x3
80109dd6:	68 fe c3 10 80       	push   $0x8010c3fe
80109ddb:	ff 75 ec             	push   -0x14(%ebp)
80109dde:	e8 47 ae ff ff       	call   80104c2a <memcmp>
80109de3:	83 c4 10             	add    $0x10,%esp
80109de6:	85 c0                	test   %eax,%eax
80109de8:	74 74                	je     80109e5e <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109dea:	83 ec 0c             	sub    $0xc,%esp
80109ded:	68 02 c4 10 80       	push   $0x8010c402
80109df2:	e8 15 66 ff ff       	call   8010040c <cprintf>
80109df7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109dfa:	83 ec 0c             	sub    $0xc,%esp
80109dfd:	6a 00                	push   $0x0
80109dff:	6a 10                	push   $0x10
80109e01:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e04:	50                   	push   %eax
80109e05:	ff 75 e8             	push   -0x18(%ebp)
80109e08:	ff 75 08             	push   0x8(%ebp)
80109e0b:	e8 2d 01 00 00       	call   80109f3d <tcp_pkt_create>
80109e10:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e13:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e16:	83 ec 08             	sub    $0x8,%esp
80109e19:	50                   	push   %eax
80109e1a:	ff 75 e8             	push   -0x18(%ebp)
80109e1d:	e8 8a f0 ff ff       	call   80108eac <i8254_send>
80109e22:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e28:	83 c0 36             	add    $0x36,%eax
80109e2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e2e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e31:	50                   	push   %eax
80109e32:	ff 75 e0             	push   -0x20(%ebp)
80109e35:	6a 00                	push   $0x0
80109e37:	6a 00                	push   $0x0
80109e39:	e8 66 04 00 00       	call   8010a2a4 <http_proc>
80109e3e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109e41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109e44:	83 ec 0c             	sub    $0xc,%esp
80109e47:	50                   	push   %eax
80109e48:	6a 18                	push   $0x18
80109e4a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e4d:	50                   	push   %eax
80109e4e:	ff 75 e8             	push   -0x18(%ebp)
80109e51:	ff 75 08             	push   0x8(%ebp)
80109e54:	e8 e4 00 00 00       	call   80109f3d <tcp_pkt_create>
80109e59:	83 c4 20             	add    $0x20,%esp
80109e5c:	eb 62                	jmp    80109ec0 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e5e:	83 ec 0c             	sub    $0xc,%esp
80109e61:	6a 00                	push   $0x0
80109e63:	6a 10                	push   $0x10
80109e65:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e68:	50                   	push   %eax
80109e69:	ff 75 e8             	push   -0x18(%ebp)
80109e6c:	ff 75 08             	push   0x8(%ebp)
80109e6f:	e8 c9 00 00 00       	call   80109f3d <tcp_pkt_create>
80109e74:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e7a:	83 ec 08             	sub    $0x8,%esp
80109e7d:	50                   	push   %eax
80109e7e:	ff 75 e8             	push   -0x18(%ebp)
80109e81:	e8 26 f0 ff ff       	call   80108eac <i8254_send>
80109e86:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e8c:	83 c0 36             	add    $0x36,%eax
80109e8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e92:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e95:	50                   	push   %eax
80109e96:	ff 75 e4             	push   -0x1c(%ebp)
80109e99:	6a 00                	push   $0x0
80109e9b:	6a 00                	push   $0x0
80109e9d:	e8 02 04 00 00       	call   8010a2a4 <http_proc>
80109ea2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ea5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109ea8:	83 ec 0c             	sub    $0xc,%esp
80109eab:	50                   	push   %eax
80109eac:	6a 18                	push   $0x18
80109eae:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eb1:	50                   	push   %eax
80109eb2:	ff 75 e8             	push   -0x18(%ebp)
80109eb5:	ff 75 08             	push   0x8(%ebp)
80109eb8:	e8 80 00 00 00       	call   80109f3d <tcp_pkt_create>
80109ebd:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ec3:	83 ec 08             	sub    $0x8,%esp
80109ec6:	50                   	push   %eax
80109ec7:	ff 75 e8             	push   -0x18(%ebp)
80109eca:	e8 dd ef ff ff       	call   80108eac <i8254_send>
80109ecf:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ed2:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109ed7:	83 c0 01             	add    $0x1,%eax
80109eda:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109edf:	eb 4a                	jmp    80109f2b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ee4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ee8:	3c 10                	cmp    $0x10,%al
80109eea:	75 3f                	jne    80109f2b <tcp_proc+0x1fb>
    if(fin_flag == 1){
80109eec:	a1 48 d3 18 80       	mov    0x8018d348,%eax
80109ef1:	83 f8 01             	cmp    $0x1,%eax
80109ef4:	75 35                	jne    80109f2b <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109ef6:	83 ec 0c             	sub    $0xc,%esp
80109ef9:	6a 00                	push   $0x0
80109efb:	6a 01                	push   $0x1
80109efd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f00:	50                   	push   %eax
80109f01:	ff 75 e8             	push   -0x18(%ebp)
80109f04:	ff 75 08             	push   0x8(%ebp)
80109f07:	e8 31 00 00 00       	call   80109f3d <tcp_pkt_create>
80109f0c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f12:	83 ec 08             	sub    $0x8,%esp
80109f15:	50                   	push   %eax
80109f16:	ff 75 e8             	push   -0x18(%ebp)
80109f19:	e8 8e ef ff ff       	call   80108eac <i8254_send>
80109f1e:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f21:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
80109f28:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f2e:	83 ec 0c             	sub    $0xc,%esp
80109f31:	50                   	push   %eax
80109f32:	e8 bd 88 ff ff       	call   801027f4 <kfree>
80109f37:	83 c4 10             	add    $0x10,%esp
}
80109f3a:	90                   	nop
80109f3b:	c9                   	leave
80109f3c:	c3                   	ret

80109f3d <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109f3d:	f3 0f 1e fb          	endbr32
80109f41:	55                   	push   %ebp
80109f42:	89 e5                	mov    %esp,%ebp
80109f44:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f47:	8b 45 08             	mov    0x8(%ebp),%eax
80109f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f50:	83 c0 0e             	add    $0xe,%eax
80109f53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f59:	0f b6 00             	movzbl (%eax),%eax
80109f5c:	0f b6 c0             	movzbl %al,%eax
80109f5f:	83 e0 0f             	and    $0xf,%eax
80109f62:	c1 e0 02             	shl    $0x2,%eax
80109f65:	89 c2                	mov    %eax,%edx
80109f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f6a:	01 d0                	add    %edx,%eax
80109f6c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f78:	83 c0 0e             	add    $0xe,%eax
80109f7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109f7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f81:	83 c0 14             	add    $0x14,%eax
80109f84:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109f87:	8b 45 18             	mov    0x18(%ebp),%eax
80109f8a:	8d 50 36             	lea    0x36(%eax),%edx
80109f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80109f90:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f95:	8d 50 06             	lea    0x6(%eax),%edx
80109f98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f9b:	83 ec 04             	sub    $0x4,%esp
80109f9e:	6a 06                	push   $0x6
80109fa0:	52                   	push   %edx
80109fa1:	50                   	push   %eax
80109fa2:	e8 df ac ff ff       	call   80104c86 <memmove>
80109fa7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fad:	83 c0 06             	add    $0x6,%eax
80109fb0:	83 ec 04             	sub    $0x4,%esp
80109fb3:	6a 06                	push   $0x6
80109fb5:	68 68 d0 18 80       	push   $0x8018d068
80109fba:	50                   	push   %eax
80109fbb:	e8 c6 ac ff ff       	call   80104c86 <memmove>
80109fc0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109fc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fc6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fcd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109fd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fd4:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fda:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109fde:	8b 45 18             	mov    0x18(%ebp),%eax
80109fe1:	83 c0 28             	add    $0x28,%eax
80109fe4:	0f b7 c0             	movzwl %ax,%eax
80109fe7:	83 ec 0c             	sub    $0xc,%esp
80109fea:	50                   	push   %eax
80109feb:	e8 6f f8 ff ff       	call   8010985f <H2N_ushort>
80109ff0:	83 c4 10             	add    $0x10,%esp
80109ff3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ff6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109ffa:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a001:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a004:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a008:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a00f:	83 c0 01             	add    $0x1,%eax
8010a012:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a018:	83 ec 0c             	sub    $0xc,%esp
8010a01b:	6a 00                	push   $0x0
8010a01d:	e8 3d f8 ff ff       	call   8010985f <H2N_ushort>
8010a022:	83 c4 10             	add    $0x10,%esp
8010a025:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a028:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a02c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a02f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a036:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a03a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03d:	83 c0 0c             	add    $0xc,%eax
8010a040:	83 ec 04             	sub    $0x4,%esp
8010a043:	6a 04                	push   $0x4
8010a045:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a04a:	50                   	push   %eax
8010a04b:	e8 36 ac ff ff       	call   80104c86 <memmove>
8010a050:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a053:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a056:	8d 50 0c             	lea    0xc(%eax),%edx
8010a059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a05c:	83 c0 10             	add    $0x10,%eax
8010a05f:	83 ec 04             	sub    $0x4,%esp
8010a062:	6a 04                	push   $0x4
8010a064:	52                   	push   %edx
8010a065:	50                   	push   %eax
8010a066:	e8 1b ac ff ff       	call   80104c86 <memmove>
8010a06b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a06e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a071:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a07a:	83 ec 0c             	sub    $0xc,%esp
8010a07d:	50                   	push   %eax
8010a07e:	e8 ec f8 ff ff       	call   8010996f <ipv4_chksum>
8010a083:	83 c4 10             	add    $0x10,%esp
8010a086:	0f b7 c0             	movzwl %ax,%eax
8010a089:	83 ec 0c             	sub    $0xc,%esp
8010a08c:	50                   	push   %eax
8010a08d:	e8 cd f7 ff ff       	call   8010985f <H2N_ushort>
8010a092:	83 c4 10             	add    $0x10,%esp
8010a095:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a098:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a09c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a09f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a0a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0a6:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a0a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0ac:	0f b7 10             	movzwl (%eax),%edx
8010a0af:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0b2:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a0b6:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a0bb:	83 ec 0c             	sub    $0xc,%esp
8010a0be:	50                   	push   %eax
8010a0bf:	e8 c1 f7 ff ff       	call   80109885 <H2N_uint>
8010a0c4:	83 c4 10             	add    $0x10,%esp
8010a0c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0ca:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a0cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0d0:	8b 40 04             	mov    0x4(%eax),%eax
8010a0d3:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a0d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0dc:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a0df:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a0e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a0ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0f0:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a0f4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a0f7:	89 c2                	mov    %eax,%edx
8010a0f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fc:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a0ff:	83 ec 0c             	sub    $0xc,%esp
8010a102:	68 90 38 00 00       	push   $0x3890
8010a107:	e8 53 f7 ff ff       	call   8010985f <H2N_ushort>
8010a10c:	83 c4 10             	add    $0x10,%esp
8010a10f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a112:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a116:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a119:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a11f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a122:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a12b:	83 ec 0c             	sub    $0xc,%esp
8010a12e:	50                   	push   %eax
8010a12f:	e8 1f 00 00 00       	call   8010a153 <tcp_chksum>
8010a134:	83 c4 10             	add    $0x10,%esp
8010a137:	83 c0 08             	add    $0x8,%eax
8010a13a:	0f b7 c0             	movzwl %ax,%eax
8010a13d:	83 ec 0c             	sub    $0xc,%esp
8010a140:	50                   	push   %eax
8010a141:	e8 19 f7 ff ff       	call   8010985f <H2N_ushort>
8010a146:	83 c4 10             	add    $0x10,%esp
8010a149:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a14c:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a150:	90                   	nop
8010a151:	c9                   	leave
8010a152:	c3                   	ret

8010a153 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a153:	f3 0f 1e fb          	endbr32
8010a157:	55                   	push   %ebp
8010a158:	89 e5                	mov    %esp,%ebp
8010a15a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a15d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a160:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a163:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a166:	83 c0 14             	add    $0x14,%eax
8010a169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a16c:	83 ec 04             	sub    $0x4,%esp
8010a16f:	6a 04                	push   $0x4
8010a171:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a176:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a179:	50                   	push   %eax
8010a17a:	e8 07 ab ff ff       	call   80104c86 <memmove>
8010a17f:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a182:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a185:	83 c0 0c             	add    $0xc,%eax
8010a188:	83 ec 04             	sub    $0x4,%esp
8010a18b:	6a 04                	push   $0x4
8010a18d:	50                   	push   %eax
8010a18e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a191:	83 c0 04             	add    $0x4,%eax
8010a194:	50                   	push   %eax
8010a195:	e8 ec aa ff ff       	call   80104c86 <memmove>
8010a19a:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a19d:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1a1:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a1a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1a8:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a1ac:	0f b7 c0             	movzwl %ax,%eax
8010a1af:	83 ec 0c             	sub    $0xc,%esp
8010a1b2:	50                   	push   %eax
8010a1b3:	e8 81 f6 ff ff       	call   80109839 <N2H_ushort>
8010a1b8:	83 c4 10             	add    $0x10,%esp
8010a1bb:	83 e8 14             	sub    $0x14,%eax
8010a1be:	0f b7 c0             	movzwl %ax,%eax
8010a1c1:	83 ec 0c             	sub    $0xc,%esp
8010a1c4:	50                   	push   %eax
8010a1c5:	e8 95 f6 ff ff       	call   8010985f <H2N_ushort>
8010a1ca:	83 c4 10             	add    $0x10,%esp
8010a1cd:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a1d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a1d8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a1de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a1e5:	eb 33                	jmp    8010a21a <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ea:	01 c0                	add    %eax,%eax
8010a1ec:	89 c2                	mov    %eax,%edx
8010a1ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1f1:	01 d0                	add    %edx,%eax
8010a1f3:	0f b6 00             	movzbl (%eax),%eax
8010a1f6:	0f b6 c0             	movzbl %al,%eax
8010a1f9:	c1 e0 08             	shl    $0x8,%eax
8010a1fc:	89 c2                	mov    %eax,%edx
8010a1fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a201:	01 c0                	add    %eax,%eax
8010a203:	8d 48 01             	lea    0x1(%eax),%ecx
8010a206:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a209:	01 c8                	add    %ecx,%eax
8010a20b:	0f b6 00             	movzbl (%eax),%eax
8010a20e:	0f b6 c0             	movzbl %al,%eax
8010a211:	01 d0                	add    %edx,%eax
8010a213:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a216:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a21a:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a21e:	7e c7                	jle    8010a1e7 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a223:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a226:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a22d:	eb 33                	jmp    8010a262 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a22f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a232:	01 c0                	add    %eax,%eax
8010a234:	89 c2                	mov    %eax,%edx
8010a236:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a239:	01 d0                	add    %edx,%eax
8010a23b:	0f b6 00             	movzbl (%eax),%eax
8010a23e:	0f b6 c0             	movzbl %al,%eax
8010a241:	c1 e0 08             	shl    $0x8,%eax
8010a244:	89 c2                	mov    %eax,%edx
8010a246:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a249:	01 c0                	add    %eax,%eax
8010a24b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a24e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a251:	01 c8                	add    %ecx,%eax
8010a253:	0f b6 00             	movzbl (%eax),%eax
8010a256:	0f b6 c0             	movzbl %al,%eax
8010a259:	01 d0                	add    %edx,%eax
8010a25b:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a25e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a262:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a266:	0f b7 c0             	movzwl %ax,%eax
8010a269:	83 ec 0c             	sub    $0xc,%esp
8010a26c:	50                   	push   %eax
8010a26d:	e8 c7 f5 ff ff       	call   80109839 <N2H_ushort>
8010a272:	83 c4 10             	add    $0x10,%esp
8010a275:	66 d1 e8             	shr    $1,%ax
8010a278:	0f b7 c0             	movzwl %ax,%eax
8010a27b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a27e:	7c af                	jl     8010a22f <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a280:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a283:	c1 e8 10             	shr    $0x10,%eax
8010a286:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a28c:	f7 d0                	not    %eax
}
8010a28e:	c9                   	leave
8010a28f:	c3                   	ret

8010a290 <tcp_fin>:

void tcp_fin(){
8010a290:	f3 0f 1e fb          	endbr32
8010a294:	55                   	push   %ebp
8010a295:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a297:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a29e:	00 00 00 
}
8010a2a1:	90                   	nop
8010a2a2:	5d                   	pop    %ebp
8010a2a3:	c3                   	ret

8010a2a4 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2a4:	f3 0f 1e fb          	endbr32
8010a2a8:	55                   	push   %ebp
8010a2a9:	89 e5                	mov    %esp,%ebp
8010a2ab:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a2ae:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2b1:	83 ec 04             	sub    $0x4,%esp
8010a2b4:	6a 00                	push   $0x0
8010a2b6:	68 0b c4 10 80       	push   $0x8010c40b
8010a2bb:	50                   	push   %eax
8010a2bc:	e8 65 00 00 00       	call   8010a326 <http_strcpy>
8010a2c1:	83 c4 10             	add    $0x10,%esp
8010a2c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a2c7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2ca:	83 ec 04             	sub    $0x4,%esp
8010a2cd:	ff 75 f4             	push   -0xc(%ebp)
8010a2d0:	68 1e c4 10 80       	push   $0x8010c41e
8010a2d5:	50                   	push   %eax
8010a2d6:	e8 4b 00 00 00       	call   8010a326 <http_strcpy>
8010a2db:	83 c4 10             	add    $0x10,%esp
8010a2de:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a2e1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2e4:	83 ec 04             	sub    $0x4,%esp
8010a2e7:	ff 75 f4             	push   -0xc(%ebp)
8010a2ea:	68 39 c4 10 80       	push   $0x8010c439
8010a2ef:	50                   	push   %eax
8010a2f0:	e8 31 00 00 00       	call   8010a326 <http_strcpy>
8010a2f5:	83 c4 10             	add    $0x10,%esp
8010a2f8:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a2fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2fe:	83 e0 01             	and    $0x1,%eax
8010a301:	85 c0                	test   %eax,%eax
8010a303:	74 11                	je     8010a316 <http_proc+0x72>
    char *payload = (char *)send;
8010a305:	8b 45 10             	mov    0x10(%ebp),%eax
8010a308:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a30b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a30e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a311:	01 d0                	add    %edx,%eax
8010a313:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a316:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a319:	8b 45 14             	mov    0x14(%ebp),%eax
8010a31c:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a31e:	e8 6d ff ff ff       	call   8010a290 <tcp_fin>
}
8010a323:	90                   	nop
8010a324:	c9                   	leave
8010a325:	c3                   	ret

8010a326 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a326:	f3 0f 1e fb          	endbr32
8010a32a:	55                   	push   %ebp
8010a32b:	89 e5                	mov    %esp,%ebp
8010a32d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a330:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a337:	eb 20                	jmp    8010a359 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a339:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a33c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a33f:	01 d0                	add    %edx,%eax
8010a341:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a344:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a347:	01 ca                	add    %ecx,%edx
8010a349:	89 d1                	mov    %edx,%ecx
8010a34b:	8b 55 08             	mov    0x8(%ebp),%edx
8010a34e:	01 ca                	add    %ecx,%edx
8010a350:	0f b6 00             	movzbl (%eax),%eax
8010a353:	88 02                	mov    %al,(%edx)
    i++;
8010a355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a359:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a35c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a35f:	01 d0                	add    %edx,%eax
8010a361:	0f b6 00             	movzbl (%eax),%eax
8010a364:	84 c0                	test   %al,%al
8010a366:	75 d1                	jne    8010a339 <http_strcpy+0x13>
  }
  return i;
8010a368:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a36b:	c9                   	leave
8010a36c:	c3                   	ret

8010a36d <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a36d:	f3 0f 1e fb          	endbr32
8010a371:	55                   	push   %ebp
8010a372:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a374:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a37b:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a37e:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a383:	c1 e8 09             	shr    $0x9,%eax
8010a386:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a38b:	90                   	nop
8010a38c:	5d                   	pop    %ebp
8010a38d:	c3                   	ret

8010a38e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a38e:	f3 0f 1e fb          	endbr32
8010a392:	55                   	push   %ebp
8010a393:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a395:	90                   	nop
8010a396:	5d                   	pop    %ebp
8010a397:	c3                   	ret

8010a398 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a398:	f3 0f 1e fb          	endbr32
8010a39c:	55                   	push   %ebp
8010a39d:	89 e5                	mov    %esp,%ebp
8010a39f:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a3a2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3a5:	83 c0 0c             	add    $0xc,%eax
8010a3a8:	83 ec 0c             	sub    $0xc,%esp
8010a3ab:	50                   	push   %eax
8010a3ac:	e8 e6 a4 ff ff       	call   80104897 <holdingsleep>
8010a3b1:	83 c4 10             	add    $0x10,%esp
8010a3b4:	85 c0                	test   %eax,%eax
8010a3b6:	75 0d                	jne    8010a3c5 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a3b8:	83 ec 0c             	sub    $0xc,%esp
8010a3bb:	68 4a c4 10 80       	push   $0x8010c44a
8010a3c0:	e8 00 62 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a3c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c8:	8b 00                	mov    (%eax),%eax
8010a3ca:	83 e0 06             	and    $0x6,%eax
8010a3cd:	83 f8 02             	cmp    $0x2,%eax
8010a3d0:	75 0d                	jne    8010a3df <iderw+0x47>
    panic("iderw: nothing to do");
8010a3d2:	83 ec 0c             	sub    $0xc,%esp
8010a3d5:	68 60 c4 10 80       	push   $0x8010c460
8010a3da:	e8 e6 61 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a3df:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3e2:	8b 40 04             	mov    0x4(%eax),%eax
8010a3e5:	83 f8 01             	cmp    $0x1,%eax
8010a3e8:	74 0d                	je     8010a3f7 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a3ea:	83 ec 0c             	sub    $0xc,%esp
8010a3ed:	68 75 c4 10 80       	push   $0x8010c475
8010a3f2:	e8 ce 61 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a3f7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3fa:	8b 40 08             	mov    0x8(%eax),%eax
8010a3fd:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a403:	39 d0                	cmp    %edx,%eax
8010a405:	72 0d                	jb     8010a414 <iderw+0x7c>
    panic("iderw: block out of range");
8010a407:	83 ec 0c             	sub    $0xc,%esp
8010a40a:	68 93 c4 10 80       	push   $0x8010c493
8010a40f:	e8 b1 61 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a414:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a41a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a41d:	8b 40 08             	mov    0x8(%eax),%eax
8010a420:	c1 e0 09             	shl    $0x9,%eax
8010a423:	01 d0                	add    %edx,%eax
8010a425:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a428:	8b 45 08             	mov    0x8(%ebp),%eax
8010a42b:	8b 00                	mov    (%eax),%eax
8010a42d:	83 e0 04             	and    $0x4,%eax
8010a430:	85 c0                	test   %eax,%eax
8010a432:	74 2b                	je     8010a45f <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a434:	8b 45 08             	mov    0x8(%ebp),%eax
8010a437:	8b 00                	mov    (%eax),%eax
8010a439:	83 e0 fb             	and    $0xfffffffb,%eax
8010a43c:	89 c2                	mov    %eax,%edx
8010a43e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a441:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a443:	8b 45 08             	mov    0x8(%ebp),%eax
8010a446:	83 c0 5c             	add    $0x5c,%eax
8010a449:	83 ec 04             	sub    $0x4,%esp
8010a44c:	68 00 02 00 00       	push   $0x200
8010a451:	50                   	push   %eax
8010a452:	ff 75 f4             	push   -0xc(%ebp)
8010a455:	e8 2c a8 ff ff       	call   80104c86 <memmove>
8010a45a:	83 c4 10             	add    $0x10,%esp
8010a45d:	eb 1a                	jmp    8010a479 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a45f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a462:	83 c0 5c             	add    $0x5c,%eax
8010a465:	83 ec 04             	sub    $0x4,%esp
8010a468:	68 00 02 00 00       	push   $0x200
8010a46d:	ff 75 f4             	push   -0xc(%ebp)
8010a470:	50                   	push   %eax
8010a471:	e8 10 a8 ff ff       	call   80104c86 <memmove>
8010a476:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a479:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47c:	8b 00                	mov    (%eax),%eax
8010a47e:	83 c8 02             	or     $0x2,%eax
8010a481:	89 c2                	mov    %eax,%edx
8010a483:	8b 45 08             	mov    0x8(%ebp),%eax
8010a486:	89 10                	mov    %edx,(%eax)
}
8010a488:	90                   	nop
8010a489:	c9                   	leave
8010a48a:	c3                   	ret
