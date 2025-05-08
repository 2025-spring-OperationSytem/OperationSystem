
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
8010002d:	b8 00 f0 10 00       	mov    $0x10f000,%eax
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
8010005a:	bc 80 f3 18 80       	mov    $0x8018f380,%esp
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
80100073:	68 80 af 10 80       	push   $0x8010af80
80100078:	68 80 f3 18 80       	push   $0x8018f380
8010007d:	e8 87 52 00 00       	call   80105309 <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 cc 3a 19 80 7c 	movl   $0x80193a7c,0x80193acc
8010008c:	3a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 d0 3a 19 80 7c 	movl   $0x80193a7c,0x80193ad0
80100096:	3a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 b4 f3 18 80 	movl   $0x8018f3b4,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 d0 3a 19 80    	mov    0x80193ad0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 7c 3a 19 80 	movl   $0x80193a7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 87 af 10 80       	push   $0x8010af87
801000c6:	50                   	push   %eax
801000c7:	e8 d0 50 00 00       	call   8010519c <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 d0 3a 19 80       	mov    0x80193ad0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 d0 3a 19 80       	mov    %eax,0x80193ad0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 7c 3a 19 80       	mov    $0x80193a7c,%eax
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
80100104:	68 80 f3 18 80       	push   $0x8018f380
80100109:	e8 21 52 00 00       	call   8010532f <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 d0 3a 19 80       	mov    0x80193ad0,%eax
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
80100143:	68 80 f3 18 80       	push   $0x8018f380
80100148:	e8 54 52 00 00       	call   801053a1 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 7d 50 00 00       	call   801051dc <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 7c 3a 19 80 	cmpl   $0x80193a7c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 cc 3a 19 80       	mov    0x80193acc,%eax
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
801001c4:	68 80 f3 18 80       	push   $0x8018f380
801001c9:	e8 d3 51 00 00       	call   801053a1 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 fc 4f 00 00       	call   801051dc <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 7c 3a 19 80 	cmpl   $0x80193a7c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 8e af 10 80       	push   $0x8010af8e
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
80100239:	e8 41 ac 00 00       	call   8010ae7f <iderw>
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
8010025a:	e8 37 50 00 00       	call   80105296 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 9f af 10 80       	push   $0x8010af9f
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
80100288:	e8 f2 ab 00 00       	call   8010ae7f <iderw>
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
801002a7:	e8 ea 4f 00 00       	call   80105296 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 a6 af 10 80       	push   $0x8010afa6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 75 4f 00 00       	call   80105244 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 80 f3 18 80       	push   $0x8018f380
801002da:	e8 50 50 00 00       	call   8010532f <acquire>
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
80100319:	8b 15 d0 3a 19 80    	mov    0x80193ad0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 7c 3a 19 80 	movl   $0x80193a7c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 d0 3a 19 80       	mov    0x80193ad0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 d0 3a 19 80       	mov    %eax,0x80193ad0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 80 f3 18 80       	push   $0x8018f380
8010034a:	e8 52 50 00 00       	call   801053a1 <release>
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
801003ad:	0f b6 91 04 e0 10 80 	movzbl -0x7fef1ffc(%ecx),%edx
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
80100416:	a1 54 e0 18 80       	mov    0x8018e054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 e0 18 80       	push   $0x8018e020
8010042c:	e8 fe 4e 00 00       	call   8010532f <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ad af 10 80       	push   $0x8010afad
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
8010052c:	c7 45 ec b6 af 10 80 	movl   $0x8010afb6,-0x14(%ebp)
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
801005b5:	68 20 e0 18 80       	push   $0x8018e020
801005ba:	e8 e2 4d 00 00       	call   801053a1 <release>
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
801005d4:	c7 05 54 e0 18 80 00 	movl   $0x0,0x8018e054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 bd af 10 80       	push   $0x8010afbd
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
80100606:	68 d1 af 10 80       	push   $0x8010afd1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 d4 4d 00 00       	call   801053f7 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 d3 af 10 80       	push   $0x8010afd3
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 e0 18 80 01 	movl   $0x1,0x8018e000
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
8010066d:	8b 0d 00 e0 10 80    	mov    0x8010e000,%ecx
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
80100696:	a1 00 e0 10 80       	mov    0x8010e000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 e0 10 80       	mov    %eax,0x8010e000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 e0 10 80       	mov    0x8010e000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 e0 10 80       	mov    0x8010e000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 e0 10 80       	mov    %eax,0x8010e000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 4a 86 00 00       	call   80108d13 <graphic_scroll_up>
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
801006da:	a1 00 e0 10 80       	mov    0x8010e000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 e0 10 80       	mov    0x8010e000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 e0 10 80       	mov    %eax,0x8010e000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 e0 10 80       	mov    0x8010e000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 e0 10 80       	mov    0x8010e000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 e0 10 80       	mov    %eax,0x8010e000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 f7 85 00 00       	call   80108d13 <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 e0 10 80    	mov    0x8010e000,%ecx
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
80100750:	8b 0d 00 e0 10 80    	mov    0x8010e000,%ecx
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
8010077d:	e8 05 86 00 00       	call   80108d87 <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 e0 10 80       	mov    0x8010e000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 e0 10 80       	mov    %eax,0x8010e000
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
8010079f:	a1 00 e0 18 80       	mov    0x8018e000,%eax
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
801007bd:	e8 66 69 00 00       	call   80107128 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 59 69 00 00       	call   80107128 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 4c 69 00 00       	call   80107128 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 3c 69 00 00       	call   80107128 <uartputc>
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
80100814:	68 20 e0 18 80       	push   $0x8018e020
80100819:	e8 11 4b 00 00       	call   8010532f <acquire>
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
80100866:	a1 68 3d 19 80       	mov    0x80193d68,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 68 3d 19 80       	mov    %eax,0x80193d68
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 68 3d 19 80    	mov    0x80193d68,%edx
80100889:	a1 64 3d 19 80       	mov    0x80193d64,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 68 3d 19 80       	mov    0x80193d68,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 e0 3c 19 80 	movzbl -0x7fe6c320(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 68 3d 19 80    	mov    0x80193d68,%edx
801008b7:	a1 64 3d 19 80       	mov    0x80193d64,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 68 3d 19 80       	mov    0x80193d68,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 68 3d 19 80       	mov    %eax,0x80193d68
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
801008f0:	8b 15 68 3d 19 80    	mov    0x80193d68,%edx
801008f6:	a1 60 3d 19 80       	mov    0x80193d60,%eax
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
80100917:	a1 68 3d 19 80       	mov    0x80193d68,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 68 3d 19 80    	mov    %edx,0x80193d68
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 e0 3c 19 80    	mov    %dl,-0x7fe6c320(%eax)
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
8010094b:	a1 68 3d 19 80       	mov    0x80193d68,%eax
80100950:	8b 15 60 3d 19 80    	mov    0x80193d60,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 68 3d 19 80       	mov    0x80193d68,%eax
80100962:	a3 64 3d 19 80       	mov    %eax,0x80193d64
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 60 3d 19 80       	push   $0x80193d60
8010096f:	e8 e4 3d 00 00       	call   80104758 <wakeup>
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
8010098d:	68 20 e0 18 80       	push   $0x8018e020
80100992:	e8 0a 4a 00 00       	call   801053a1 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 76 3e 00 00       	call   8010481b <procdump>
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
801009c9:	68 20 e0 18 80       	push   $0x8018e020
801009ce:	e8 5c 49 00 00       	call   8010532f <acquire>
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
801009ea:	68 20 e0 18 80       	push   $0x8018e020
801009ef:	e8 ad 49 00 00       	call   801053a1 <release>
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
80100a12:	68 20 e0 18 80       	push   $0x8018e020
80100a17:	68 60 3d 19 80       	push   $0x80193d60
80100a1c:	e8 48 3c 00 00       	call   80104669 <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 60 3d 19 80    	mov    0x80193d60,%edx
80100a2a:	a1 64 3d 19 80       	mov    0x80193d64,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 60 3d 19 80       	mov    0x80193d60,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 60 3d 19 80    	mov    %edx,0x80193d60
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 e0 3c 19 80 	movzbl -0x7fe6c320(%eax),%eax
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
80100a5f:	a1 60 3d 19 80       	mov    0x80193d60,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 60 3d 19 80       	mov    %eax,0x80193d60
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
80100a95:	68 20 e0 18 80       	push   $0x8018e020
80100a9a:	e8 02 49 00 00       	call   801053a1 <release>
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
80100ad7:	68 20 e0 18 80       	push   $0x8018e020
80100adc:	e8 4e 48 00 00       	call   8010532f <acquire>
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
80100b19:	68 20 e0 18 80       	push   $0x8018e020
80100b1e:	e8 7e 48 00 00       	call   801053a1 <release>
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
80100b43:	c7 05 00 e0 18 80 00 	movl   $0x0,0x8018e000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 d7 af 10 80       	push   $0x8010afd7
80100b55:	68 20 e0 18 80       	push   $0x8018e020
80100b5a:	e8 aa 47 00 00       	call   80105309 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 2c 47 19 80 bc 	movl   $0x80100abc,0x8019472c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 28 47 19 80 a8 	movl   $0x801009a8,0x80194728
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 df af 10 80 	movl   $0x8010afdf,-0xc(%ebp)
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
80100ba2:	c7 05 54 e0 18 80 01 	movl   $0x1,0x8018e054
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
80100bf7:	68 f5 af 10 80       	push   $0x8010aff5
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
80100c53:	e8 e4 74 00 00       	call   8010813c <setupkvm>
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
80100cf9:	e8 50 78 00 00       	call   8010854e <allocuvm>
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
80100d3f:	e8 39 77 00 00       	call   8010847d <loaduvm>
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
80100dae:	e8 9b 77 00 00       	call   8010854e <allocuvm>
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
80100dd2:	e8 e5 79 00 00       	call   801087bc <clearpteu>
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
80100e0b:	e8 17 4a 00 00       	call   80105827 <strlen>
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
80100e38:	e8 ea 49 00 00       	call   80105827 <strlen>
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
80100e5e:	e8 04 7b 00 00       	call   80108967 <copyout>
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
80100efa:	e8 68 7a 00 00       	call   80108967 <copyout>
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
80100f48:	e8 8c 48 00 00       	call   801057d9 <safestrcpy>
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
80100f8b:	e8 d6 72 00 00       	call   80108266 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 81 77 00 00       	call   8010871f <freevm>
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
80100fd9:	e8 41 77 00 00       	call   8010871f <freevm>
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
8010100e:	68 01 b0 10 80       	push   $0x8010b001
80101013:	68 80 3d 19 80       	push   $0x80193d80
80101018:	e8 ec 42 00 00       	call   80105309 <initlock>
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
80101030:	68 80 3d 19 80       	push   $0x80193d80
80101035:	e8 f5 42 00 00       	call   8010532f <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 b4 3d 19 80 	movl   $0x80193db4,-0xc(%ebp)
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
8010105d:	68 80 3d 19 80       	push   $0x80193d80
80101062:	e8 3a 43 00 00       	call   801053a1 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 14 47 19 80       	mov    $0x80194714,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 80 3d 19 80       	push   $0x80193d80
80101085:	e8 17 43 00 00       	call   801053a1 <release>
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
801010a1:	68 80 3d 19 80       	push   $0x80193d80
801010a6:	e8 84 42 00 00       	call   8010532f <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 08 b0 10 80       	push   $0x8010b008
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 80 3d 19 80       	push   $0x80193d80
801010dc:	e8 c0 42 00 00       	call   801053a1 <release>
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
801010f6:	68 80 3d 19 80       	push   $0x80193d80
801010fb:	e8 2f 42 00 00       	call   8010532f <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 10 b0 10 80       	push   $0x8010b010
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
80101136:	68 80 3d 19 80       	push   $0x80193d80
8010113b:	e8 61 42 00 00       	call   801053a1 <release>
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
80101184:	68 80 3d 19 80       	push   $0x80193d80
80101189:	e8 13 42 00 00       	call   801053a1 <release>
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
801012e0:	68 1a b0 10 80       	push   $0x8010b01a
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
801013e7:	68 23 b0 10 80       	push   $0x8010b023
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
8010141d:	68 33 b0 10 80       	push   $0x8010b033
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
80101459:	e8 27 42 00 00       	call   80105685 <memmove>
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
801014a3:	e8 16 41 00 00       	call   801055be <memset>
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
801014fa:	a1 98 47 19 80       	mov    0x80194798,%eax
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
801015d8:	a1 80 47 19 80       	mov    0x80194780,%eax
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
801015fa:	8b 15 80 47 19 80    	mov    0x80194780,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 40 b0 10 80       	push   $0x8010b040
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
80101627:	68 80 47 19 80       	push   $0x80194780
8010162c:	ff 75 08             	push   0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 98 47 19 80       	mov    0x80194798,%eax
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
801016a5:	68 56 b0 10 80       	push   $0x8010b056
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
8010170d:	68 69 b0 10 80       	push   $0x8010b069
80101712:	68 a0 47 19 80       	push   $0x801947a0
80101717:	e8 ed 3b 00 00       	call   80105309 <initlock>
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
80101738:	05 a0 47 19 80       	add    $0x801947a0,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 70 b0 10 80       	push   $0x8010b070
80101748:	50                   	push   %eax
80101749:	e8 4e 3a 00 00       	call   8010519c <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 80 47 19 80       	push   $0x80194780
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 98 47 19 80       	mov    0x80194798,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 94 47 19 80    	mov    0x80194794,%edi
8010177c:	8b 35 90 47 19 80    	mov    0x80194790,%esi
80101782:	8b 1d 8c 47 19 80    	mov    0x8019478c,%ebx
80101788:	8b 0d 88 47 19 80    	mov    0x80194788,%ecx
8010178e:	8b 15 84 47 19 80    	mov    0x80194784,%edx
80101794:	a1 80 47 19 80       	mov    0x80194780,%eax
80101799:	ff 75 d4             	push   -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 78 b0 10 80       	push   $0x8010b078
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
801017dd:	a1 94 47 19 80       	mov    0x80194794,%eax
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
8010181f:	e8 9a 3d 00 00       	call   801055be <memset>
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
80101873:	8b 15 88 47 19 80    	mov    0x80194788,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 cb b0 10 80       	push   $0x8010b0cb
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
801018a8:	a1 94 47 19 80       	mov    0x80194794,%eax
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
80101931:	e8 4f 3d 00 00       	call   80105685 <memmove>
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
80101965:	68 a0 47 19 80       	push   $0x801947a0
8010196a:	e8 c0 39 00 00       	call   8010532f <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 d4 47 19 80 	movl   $0x801947d4,-0xc(%ebp)
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
801019b3:	68 a0 47 19 80       	push   $0x801947a0
801019b8:	e8 e4 39 00 00       	call   801053a1 <release>
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
801019e2:	81 7d f4 f4 63 19 80 	cmpl   $0x801963f4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 dd b0 10 80       	push   $0x8010b0dd
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
80101a2c:	68 a0 47 19 80       	push   $0x801947a0
80101a31:	e8 6b 39 00 00       	call   801053a1 <release>
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
80101a4b:	68 a0 47 19 80       	push   $0x801947a0
80101a50:	e8 da 38 00 00       	call   8010532f <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 a0 47 19 80       	push   $0x801947a0
80101a6f:	e8 2d 39 00 00       	call   801053a1 <release>
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
80101a99:	68 ed b0 10 80       	push   $0x8010b0ed
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 2a 37 00 00       	call   801051dc <acquiresleep>
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
80101ace:	a1 94 47 19 80       	mov    0x80194794,%eax
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
80101b57:	e8 29 3b 00 00       	call   80105685 <memmove>
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
80101b86:	68 f3 b0 10 80       	push   $0x8010b0f3
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
80101bad:	e8 e4 36 00 00       	call   80105296 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 02 b1 10 80       	push   $0x8010b102
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 65 36 00 00       	call   80105244 <releasesleep>
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
80101bf9:	e8 de 35 00 00       	call   801051dc <acquiresleep>
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
80101c1a:	68 a0 47 19 80       	push   $0x801947a0
80101c1f:	e8 0b 37 00 00       	call   8010532f <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 a0 47 19 80       	push   $0x801947a0
80101c38:	e8 64 37 00 00       	call   801053a1 <release>
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
80101c7f:	e8 c0 35 00 00       	call   80105244 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 a0 47 19 80       	push   $0x801947a0
80101c8f:	e8 9b 36 00 00       	call   8010532f <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 a0 47 19 80       	push   $0x801947a0
80101cae:	e8 ee 36 00 00       	call   801053a1 <release>
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
80101dfa:	68 0a b1 10 80       	push   $0x8010b10a
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
80101fbc:	8b 04 c5 20 47 19 80 	mov    -0x7fe6b8e0(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl
80101fd9:	8b 04 c5 20 47 19 80 	mov    -0x7fe6b8e0(,%eax,8),%eax
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
801020a4:	e8 dc 35 00 00       	call   80105685 <memmove>
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
80102115:	8b 04 c5 24 47 19 80 	mov    -0x7fe6b8dc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl
80102132:	8b 04 c5 24 47 19 80 	mov    -0x7fe6b8dc(,%eax,8),%eax
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
801021f8:	e8 88 34 00 00       	call   80105685 <memmove>
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
8010227c:	e8 a2 34 00 00       	call   80105723 <strncmp>
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
801022a0:	68 1d b1 10 80       	push   $0x8010b11d
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
801022cf:	68 2f b1 10 80       	push   $0x8010b12f
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
801023a8:	68 3e b1 10 80       	push   $0x8010b13e
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
801023e3:	e8 95 33 00 00       	call   8010577d <strncpy>
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
8010240f:	68 4b b1 10 80       	push   $0x8010b14b
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
80102485:	e8 fb 31 00 00       	call   80105685 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 e4 31 00 00       	call   80105685 <memmove>
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
8010262d:	a1 f4 63 19 80       	mov    0x801963f4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 f4 63 19 80       	mov    0x801963f4,%eax
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
80102648:	a1 f4 63 19 80       	mov    0x801963f4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 f4 63 19 80       	mov    0x801963f4,%eax
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
8010266a:	c7 05 f4 63 19 80 00 	movl   $0xfec00000,0x801963f4
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
80102699:	0f b6 05 c0 9c 19 80 	movzbl 0x80199cc0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 54 b1 10 80       	push   $0x8010b154
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
8010275a:	68 86 b1 10 80       	push   $0x8010b186
8010275f:	68 00 64 19 80       	push   $0x80196400
80102764:	e8 a0 2b 00 00       	call   80105309 <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 34 64 19 80 00 	movl   $0x0,0x80196434
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
801027a5:	c7 05 34 64 19 80 01 	movl   $0x1,0x80196434
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
8010280a:	81 7d 08 00 a0 19 80 	cmpl   $0x8019a000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 8b b1 10 80       	push   $0x8010b18b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 7d 2d 00 00       	call   801055be <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 34 64 19 80       	mov    0x80196434,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 00 64 19 80       	push   $0x80196400
80102855:	e8 d5 2a 00 00       	call   8010532f <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 38 64 19 80    	mov    0x80196438,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 38 64 19 80       	mov    %eax,0x80196438
  if(kmem.use_lock)
80102876:	a1 34 64 19 80       	mov    0x80196434,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 00 64 19 80       	push   $0x80196400
80102887:	e8 15 2b 00 00       	call   801053a1 <release>
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
8010289c:	a1 34 64 19 80       	mov    0x80196434,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 00 64 19 80       	push   $0x80196400
801028ad:	e8 7d 2a 00 00       	call   8010532f <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 38 64 19 80       	mov    0x80196438,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 38 64 19 80       	mov    %eax,0x80196438
  if(kmem.use_lock)
801028cd:	a1 34 64 19 80       	mov    0x80196434,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 00 64 19 80       	push   $0x80196400
801028de:	e8 be 2a 00 00       	call   801053a1 <release>
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
8010294f:	a1 58 e0 18 80       	mov    0x8018e058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 e0 18 80       	mov    %eax,0x8018e058
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
80102972:	a1 58 e0 18 80       	mov    0x8018e058,%eax
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
8010298f:	05 20 e0 10 80       	add    $0x8010e020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 e0 18 80       	mov    0x8018e058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 e0 18 80       	mov    %eax,0x8018e058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 e0 18 80       	mov    0x8018e058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 e0 18 80       	mov    0x8018e058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 e0 18 80       	mov    %eax,0x8018e058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 e0 10 80       	add    $0x8010e020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 e0 18 80       	mov    0x8018e058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 e0 18 80       	mov    %eax,0x8018e058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 e1 10 80       	add    $0x8010e120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 e0 18 80       	mov    0x8018e058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 e0 18 80       	mov    %eax,0x8018e058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 e0 18 80       	mov    0x8018e058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 e5 10 80 	mov    -0x7fef1ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 e0 18 80       	mov    0x8018e058,%eax
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
80102abd:	a1 3c 64 19 80       	mov    0x8019643c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102ae3:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102b56:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102bd9:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102c06:	a1 3c 64 19 80       	mov    0x8019643c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102c2c:	a1 3c 64 19 80       	mov    0x8019643c,%eax
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
80102e33:	e8 f1 27 00 00       	call   80105629 <memcmp>
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
80102f4b:	68 91 b1 10 80       	push   $0x8010b191
80102f50:	68 40 64 19 80       	push   $0x80196440
80102f55:	e8 af 23 00 00       	call   80105309 <initlock>
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
80102f72:	a3 74 64 19 80       	mov    %eax,0x80196474
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 78 64 19 80       	mov    %eax,0x80196478
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 84 64 19 80       	mov    %eax,0x80196484
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
80102fa5:	8b 15 74 64 19 80    	mov    0x80196474,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 84 64 19 80       	mov    0x80196484,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 4c 64 19 80 	mov    -0x7fe69bb4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 84 64 19 80       	mov    0x80196484,%eax
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
80103004:	e8 7c 26 00 00       	call   80105685 <memmove>
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
8010303a:	a1 88 64 19 80       	mov    0x80196488,%eax
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
80103056:	a1 74 64 19 80       	mov    0x80196474,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 84 64 19 80       	mov    0x80196484,%eax
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
80103080:	a3 88 64 19 80       	mov    %eax,0x80196488
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 4c 64 19 80 	mov    %eax,-0x7fe69bb4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 88 64 19 80       	mov    0x80196488,%eax
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
801030ce:	a1 74 64 19 80       	mov    0x80196474,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 84 64 19 80       	mov    0x80196484,%eax
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
801030f3:	8b 15 88 64 19 80    	mov    0x80196488,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 4c 64 19 80 	mov    -0x7fe69bb4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 88 64 19 80       	mov    0x80196488,%eax
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
8010315f:	c7 05 88 64 19 80 00 	movl   $0x0,0x80196488
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
8010317e:	68 40 64 19 80       	push   $0x80196440
80103183:	e8 a7 21 00 00       	call   8010532f <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 80 64 19 80       	mov    0x80196480,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 40 64 19 80       	push   $0x80196440
8010319c:	68 40 64 19 80       	push   $0x80196440
801031a1:	e8 c3 14 00 00       	call   80104669 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 88 64 19 80    	mov    0x80196488,%ecx
801031b1:	a1 7c 64 19 80       	mov    0x8019647c,%eax
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
801031cc:	68 40 64 19 80       	push   $0x80196440
801031d1:	68 40 64 19 80       	push   $0x80196440
801031d6:	e8 8e 14 00 00       	call   80104669 <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 7c 64 19 80       	mov    0x8019647c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 7c 64 19 80       	mov    %eax,0x8019647c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 40 64 19 80       	push   $0x80196440
801031f5:	e8 a7 21 00 00       	call   801053a1 <release>
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
80103215:	68 40 64 19 80       	push   $0x80196440
8010321a:	e8 10 21 00 00       	call   8010532f <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 7c 64 19 80       	mov    0x8019647c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 7c 64 19 80       	mov    %eax,0x8019647c
  if(log.committing)
8010322f:	a1 80 64 19 80       	mov    0x80196480,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 95 b1 10 80       	push   $0x8010b195
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 7c 64 19 80       	mov    0x8019647c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 80 64 19 80 01 	movl   $0x1,0x80196480
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 40 64 19 80       	push   $0x80196440
80103269:	e8 ea 14 00 00       	call   80104758 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 40 64 19 80       	push   $0x80196440
80103279:	e8 23 21 00 00       	call   801053a1 <release>
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
8010328f:	68 40 64 19 80       	push   $0x80196440
80103294:	e8 96 20 00 00       	call   8010532f <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 80 64 19 80 00 	movl   $0x0,0x80196480
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 40 64 19 80       	push   $0x80196440
801032ae:	e8 a5 14 00 00       	call   80104758 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 40 64 19 80       	push   $0x80196440
801032be:	e8 de 20 00 00       	call   801053a1 <release>
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
801032df:	8b 15 74 64 19 80    	mov    0x80196474,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 84 64 19 80       	mov    0x80196484,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 4c 64 19 80 	mov    -0x7fe69bb4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 84 64 19 80       	mov    0x80196484,%eax
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
8010333e:	e8 42 23 00 00       	call   80105685 <memmove>
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
80103374:	a1 88 64 19 80       	mov    0x80196488,%eax
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
80103390:	a1 88 64 19 80       	mov    0x80196488,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 88 64 19 80 00 	movl   $0x0,0x80196488
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
801033c4:	a1 88 64 19 80       	mov    0x80196488,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 88 64 19 80       	mov    0x80196488,%eax
801033d3:	8b 15 78 64 19 80    	mov    0x80196478,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 a4 b1 10 80       	push   $0x8010b1a4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 7c 64 19 80       	mov    0x8019647c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 ba b1 10 80       	push   $0x8010b1ba
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 40 64 19 80       	push   $0x80196440
8010340b:	e8 1f 1f 00 00       	call   8010532f <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 4c 64 19 80 	mov    -0x7fe69bb4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 88 64 19 80       	mov    0x80196488,%eax
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
80103454:	89 14 85 4c 64 19 80 	mov    %edx,-0x7fe69bb4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 88 64 19 80       	mov    0x80196488,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 88 64 19 80       	mov    0x80196488,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 88 64 19 80       	mov    %eax,0x80196488
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 40 64 19 80       	push   $0x80196440
80103489:	e8 13 1f 00 00       	call   801053a1 <release>
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
801034c3:	e8 87 57 00 00       	call   80108c4f <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 a0 19 80       	push   $0x8019a000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 4b 4d 00 00       	call   8010822d <kvmalloc>
  mpinit_uefi();
801034e2:	e8 22 55 00 00       	call   80108a09 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 c3 47 00 00       	call   80107cb4 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 38 3b 00 00       	call   8010703d <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 c9 35 00 00       	call   80106ad8 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 36 79 00 00       	call   8010ae54 <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 85 59 00 00       	call   80108ec2 <pci_init>
  arp_scan();
8010353d:	e8 fe 66 00 00       	call   80109c40 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 1d 08 00 00       	call   80103d64 <userinit>

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
80103556:	e8 ee 4c 00 00       	call   80108249 <switchkvm>
  seginit();
8010355b:	e8 54 47 00 00       	call   80107cb4 <seginit>
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
80103586:	68 d5 b1 10 80       	push   $0x8010b1d5
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 ba 36 00 00       	call   80106c52 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 1d 0e 00 00       	call   801043d2 <scheduler>

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
801035cf:	68 38 05 11 80       	push   $0x80110538
801035d4:	ff 75 f0             	push   -0x10(%ebp)
801035d7:	e8 a9 20 00 00       	call   80105685 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 e0 9c 19 80 	movl   $0x80199ce0,-0xc(%ebp)
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
80103617:	b8 00 f0 10 80       	mov    $0x8010f000,%eax
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
8010365a:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103661:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80103666:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010366c:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
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
80103768:	68 e9 b1 10 80       	push   $0x8010b1e9
8010376d:	50                   	push   %eax
8010376e:	e8 96 1b 00 00       	call   80105309 <initlock>
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
80103831:	e8 f9 1a 00 00       	call   8010532f <acquire>
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
80103858:	e8 fb 0e 00 00       	call   80104758 <wakeup>
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
8010387b:	e8 d8 0e 00 00       	call   80104758 <wakeup>
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
801038a4:	e8 f8 1a 00 00       	call   801053a1 <release>
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
801038c3:	e8 d9 1a 00 00       	call   801053a1 <release>
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
801038e1:	e8 49 1a 00 00       	call   8010532f <acquire>
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
80103915:	e8 87 1a 00 00       	call   801053a1 <release>
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
80103933:	e8 20 0e 00 00       	call   80104758 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 18 0d 00 00       	call   80104669 <sleep>
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
801039b6:	e8 9d 0d 00 00       	call   80104758 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 d7 19 00 00       	call   801053a1 <release>
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
801039e6:	e8 44 19 00 00       	call   8010532f <acquire>
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
80103a03:	e8 99 19 00 00       	call   801053a1 <release>
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
80103a26:	e8 3e 0c 00 00       	call   80104669 <sleep>
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
80103ab9:	e8 9a 0c 00 00       	call   80104758 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 d4 18 00 00       	call   801053a1 <release>
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
void enqueue(struct proc *p, int level);  
struct proc* dequeue(int level);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 f0 b1 10 80       	push   $0x8010b1f0
80103afe:	68 20 75 19 80       	push   $0x80197520
80103b03:	e8 01 18 00 00       	call   80105309 <initlock>
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
80103b1d:	2d e0 9c 19 80       	sub    $0x80199ce0,%eax
80103b22:	c1 f8 02             	sar    $0x2,%eax
80103b25:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
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
80103b48:	68 f8 b1 10 80       	push   $0x8010b1f8
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
80103b66:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103b6c:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103b85:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 1e b2 10 80       	push   $0x8010b21e
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
80103bb3:	e8 f3 18 00 00       	call   801054ab <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 2b 19 00 00       	call   801054fc <popcli>
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
80103be3:	68 20 75 19 80       	push   $0x80197520
80103be8:	e8 42 17 00 00       	call   8010532f <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
80103bf7:	eb 0e                	jmp    80103c07 <allocproc+0x31>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 27                	je     80103c2a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103c07:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 20 75 19 80       	push   $0x80197520
80103c18:	e8 84 17 00 00       	call   801053a1 <release>
80103c1d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c20:	b8 00 00 00 00       	mov    $0x0,%eax
80103c25:	e9 38 01 00 00       	jmp    80103d62 <allocproc+0x18c>
      goto found;
80103c2a:	90                   	nop
80103c2b:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c39:	a1 00 00 11 80       	mov    0x80110000,%eax
80103c3e:	8d 50 01             	lea    0x1(%eax),%edx
80103c41:	89 15 00 00 11 80    	mov    %edx,0x80110000
80103c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4a:	89 42 10             	mov    %eax,0x10(%edx)

    
  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
80103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c50:	2d 54 75 19 80       	sub    $0x80197554,%eax
80103c55:	c1 f8 02             	sar    $0x2,%eax
80103c58:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  kernel_pstat.inuse[i] = 1;
80103c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c64:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
80103c6b:	01 00 00 00 
  kernel_pstat.pid[i] = p->pid;
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	8b 40 10             	mov    0x10(%eax),%eax
80103c75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c78:	83 c2 40             	add    $0x40,%edx
80103c7b:	89 04 95 20 69 19 80 	mov    %eax,-0x7fe696e0(,%edx,4)
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
80103c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c85:	83 e8 80             	sub    $0xffffff80,%eax
80103c88:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80103c8f:	03 00 00 00 
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
80103c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c96:	83 c0 40             	add    $0x40,%eax
80103c99:	c1 e0 04             	shl    $0x4,%eax
80103c9c:	05 20 69 19 80       	add    $0x80196920,%eax
80103ca1:	83 ec 04             	sub    $0x4,%esp
80103ca4:	6a 10                	push   $0x10
80103ca6:	6a 00                	push   $0x0
80103ca8:	50                   	push   %eax
80103ca9:	e8 10 19 00 00       	call   801055be <memset>
80103cae:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));
80103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb4:	83 e8 80             	sub    $0xffffff80,%eax
80103cb7:	c1 e0 04             	shl    $0x4,%eax
80103cba:	05 20 69 19 80       	add    $0x80196920,%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	6a 10                	push   $0x10
80103cc4:	6a 00                	push   $0x0
80103cc6:	50                   	push   %eax
80103cc7:	e8 f2 18 00 00       	call   801055be <memset>
80103ccc:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103ccf:	83 ec 0c             	sub    $0xc,%esp
80103cd2:	68 20 75 19 80       	push   $0x80197520
80103cd7:	e8 c5 16 00 00       	call   801053a1 <release>
80103cdc:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103cdf:	e8 ae eb ff ff       	call   80102892 <kalloc>
80103ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce7:	89 42 08             	mov    %eax,0x8(%edx)
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	8b 40 08             	mov    0x8(%eax),%eax
80103cf0:	85 c0                	test   %eax,%eax
80103cf2:	75 11                	jne    80103d05 <allocproc+0x12f>
    p->state = UNUSED;
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103cfe:	b8 00 00 00 00       	mov    $0x0,%eax
80103d03:	eb 5d                	jmp    80103d62 <allocproc+0x18c>
  }
  sp = p->kstack + KSTACKSIZE;
80103d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d08:	8b 40 08             	mov    0x8(%eax),%eax
80103d0b:	05 00 10 00 00       	add    $0x1000,%eax
80103d10:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103d13:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d1d:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103d20:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103d24:	ba 92 6a 10 80       	mov    $0x80106a92,%edx
80103d29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d2c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d2e:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d35:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d38:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3e:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d41:	83 ec 04             	sub    $0x4,%esp
80103d44:	6a 14                	push   $0x14
80103d46:	6a 00                	push   $0x0
80103d48:	50                   	push   %eax
80103d49:	e8 70 18 00 00       	call   801055be <memset>
80103d4e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d54:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d57:	ba 1f 46 10 80       	mov    $0x8010461f,%edx
80103d5c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d62:	c9                   	leave
80103d63:	c3                   	ret

80103d64 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d64:	f3 0f 1e fb          	endbr32
80103d68:	55                   	push   %ebp
80103d69:	89 e5                	mov    %esp,%ebp
80103d6b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d6e:	e8 63 fe ff ff       	call   80103bd6 <allocproc>
80103d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d79:	a3 7c e0 18 80       	mov    %eax,0x8018e07c
  if((p->pgdir = setupkvm()) == 0){
80103d7e:	e8 b9 43 00 00       	call   8010813c <setupkvm>
80103d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d86:	89 42 04             	mov    %eax,0x4(%edx)
80103d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8c:	8b 40 04             	mov    0x4(%eax),%eax
80103d8f:	85 c0                	test   %eax,%eax
80103d91:	75 0d                	jne    80103da0 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d93:	83 ec 0c             	sub    $0xc,%esp
80103d96:	68 2e b2 10 80       	push   $0x8010b22e
80103d9b:	e8 25 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103da0:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da8:	8b 40 04             	mov    0x4(%eax),%eax
80103dab:	83 ec 04             	sub    $0x4,%esp
80103dae:	52                   	push   %edx
80103daf:	68 0c 05 11 80       	push   $0x8011050c
80103db4:	50                   	push   %eax
80103db5:	e8 4f 46 00 00       	call   80108409 <inituvm>
80103dba:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc9:	8b 40 18             	mov    0x18(%eax),%eax
80103dcc:	83 ec 04             	sub    $0x4,%esp
80103dcf:	6a 4c                	push   $0x4c
80103dd1:	6a 00                	push   $0x0
80103dd3:	50                   	push   %eax
80103dd4:	e8 e5 17 00 00       	call   801055be <memset>
80103dd9:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddf:	8b 40 18             	mov    0x18(%eax),%eax
80103de2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103deb:	8b 40 18             	mov    0x18(%eax),%eax
80103dee:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df7:	8b 50 18             	mov    0x18(%eax),%edx
80103dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfd:	8b 40 18             	mov    0x18(%eax),%eax
80103e00:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e04:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0b:	8b 50 18             	mov    0x18(%eax),%edx
80103e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e11:	8b 40 18             	mov    0x18(%eax),%eax
80103e14:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e18:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1f:	8b 40 18             	mov    0x18(%eax),%eax
80103e22:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2c:	8b 40 18             	mov    0x18(%eax),%eax
80103e2f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	8b 40 18             	mov    0x18(%eax),%eax
80103e3c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e46:	83 c0 6c             	add    $0x6c,%eax
80103e49:	83 ec 04             	sub    $0x4,%esp
80103e4c:	6a 10                	push   $0x10
80103e4e:	68 47 b2 10 80       	push   $0x8010b247
80103e53:	50                   	push   %eax
80103e54:	e8 80 19 00 00       	call   801057d9 <safestrcpy>
80103e59:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e5c:	83 ec 0c             	sub    $0xc,%esp
80103e5f:	68 50 b2 10 80       	push   $0x8010b250
80103e64:	e8 7e e7 ff ff       	call   801025e7 <namei>
80103e69:	83 c4 10             	add    $0x10,%esp
80103e6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e6f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e72:	83 ec 0c             	sub    $0xc,%esp
80103e75:	68 20 75 19 80       	push   $0x80197520
80103e7a:	e8 b0 14 00 00       	call   8010532f <acquire>
80103e7f:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e85:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  if (mycpu()->sched_policy > 0)
80103e8c:	e8 9c fc ff ff       	call   80103b2d <mycpu>
80103e91:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103e97:	85 c0                	test   %eax,%eax
80103e99:	7e 10                	jle    80103eab <userinit+0x147>
  enqueue(p, 3);
80103e9b:	83 ec 08             	sub    $0x8,%esp
80103e9e:	6a 03                	push   $0x3
80103ea0:	ff 75 f4             	push   -0xc(%ebp)
80103ea3:	e8 bb 0c 00 00       	call   80104b63 <enqueue>
80103ea8:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103eab:	83 ec 0c             	sub    $0xc,%esp
80103eae:	68 20 75 19 80       	push   $0x80197520
80103eb3:	e8 e9 14 00 00       	call   801053a1 <release>
80103eb8:	83 c4 10             	add    $0x10,%esp
}
80103ebb:	90                   	nop
80103ebc:	c9                   	leave
80103ebd:	c3                   	ret

80103ebe <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ebe:	f3 0f 1e fb          	endbr32
80103ec2:	55                   	push   %ebp
80103ec3:	89 e5                	mov    %esp,%ebp
80103ec5:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ec8:	e8 dc fc ff ff       	call   80103ba9 <myproc>
80103ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ed3:	8b 00                	mov    (%eax),%eax
80103ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ed8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103edc:	7e 2e                	jle    80103f0c <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ede:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee4:	01 c2                	add    %eax,%edx
80103ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee9:	8b 40 04             	mov    0x4(%eax),%eax
80103eec:	83 ec 04             	sub    $0x4,%esp
80103eef:	52                   	push   %edx
80103ef0:	ff 75 f4             	push   -0xc(%ebp)
80103ef3:	50                   	push   %eax
80103ef4:	e8 55 46 00 00       	call   8010854e <allocuvm>
80103ef9:	83 c4 10             	add    $0x10,%esp
80103efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f03:	75 3b                	jne    80103f40 <growproc+0x82>
      return -1;
80103f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f0a:	eb 4f                	jmp    80103f5b <growproc+0x9d>
  } else if(n < 0){
80103f0c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103f10:	79 2e                	jns    80103f40 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103f12:	8b 55 08             	mov    0x8(%ebp),%edx
80103f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f18:	01 c2                	add    %eax,%edx
80103f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f1d:	8b 40 04             	mov    0x4(%eax),%eax
80103f20:	83 ec 04             	sub    $0x4,%esp
80103f23:	52                   	push   %edx
80103f24:	ff 75 f4             	push   -0xc(%ebp)
80103f27:	50                   	push   %eax
80103f28:	e8 2a 47 00 00       	call   80108657 <deallocuvm>
80103f2d:	83 c4 10             	add    $0x10,%esp
80103f30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f37:	75 07                	jne    80103f40 <growproc+0x82>
      return -1;
80103f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3e:	eb 1b                	jmp    80103f5b <growproc+0x9d>
  }
  curproc->sz = sz;
80103f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f46:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f48:	83 ec 0c             	sub    $0xc,%esp
80103f4b:	ff 75 f0             	push   -0x10(%ebp)
80103f4e:	e8 13 43 00 00       	call   80108266 <switchuvm>
80103f53:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f5b:	c9                   	leave
80103f5c:	c3                   	ret

80103f5d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f5d:	f3 0f 1e fb          	endbr32
80103f61:	55                   	push   %ebp
80103f62:	89 e5                	mov    %esp,%ebp
80103f64:	57                   	push   %edi
80103f65:	56                   	push   %esi
80103f66:	53                   	push   %ebx
80103f67:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f6a:	e8 3a fc ff ff       	call   80103ba9 <myproc>
80103f6f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f72:	e8 5f fc ff ff       	call   80103bd6 <allocproc>
80103f77:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f7e:	75 0a                	jne    80103f8a <fork+0x2d>
    return -1;
80103f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f85:	e9 a3 01 00 00       	jmp    8010412d <fork+0x1d0>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8d:	8b 10                	mov    (%eax),%edx
80103f8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f92:	8b 40 04             	mov    0x4(%eax),%eax
80103f95:	83 ec 08             	sub    $0x8,%esp
80103f98:	52                   	push   %edx
80103f99:	50                   	push   %eax
80103f9a:	e8 62 48 00 00       	call   80108801 <copyuvm>
80103f9f:	83 c4 10             	add    $0x10,%esp
80103fa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fa5:	89 42 04             	mov    %eax,0x4(%edx)
80103fa8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fab:	8b 40 04             	mov    0x4(%eax),%eax
80103fae:	85 c0                	test   %eax,%eax
80103fb0:	75 30                	jne    80103fe2 <fork+0x85>
    kfree(np->kstack);
80103fb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fb5:	8b 40 08             	mov    0x8(%eax),%eax
80103fb8:	83 ec 0c             	sub    $0xc,%esp
80103fbb:	50                   	push   %eax
80103fbc:	e8 33 e8 ff ff       	call   801027f4 <kfree>
80103fc1:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fce:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fd1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fdd:	e9 4b 01 00 00       	jmp    8010412d <fork+0x1d0>
  }
  np->sz = curproc->sz;
80103fe2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe5:	8b 10                	mov    (%eax),%edx
80103fe7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fea:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fec:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fef:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103ff2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff8:	8b 48 18             	mov    0x18(%eax),%ecx
80103ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffe:	8b 40 18             	mov    0x18(%eax),%eax
80104001:	89 c2                	mov    %eax,%edx
80104003:	89 cb                	mov    %ecx,%ebx
80104005:	b8 13 00 00 00       	mov    $0x13,%eax
8010400a:	89 d7                	mov    %edx,%edi
8010400c:	89 de                	mov    %ebx,%esi
8010400e:	89 c1                	mov    %eax,%ecx
80104010:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104012:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104015:	8b 40 18             	mov    0x18(%eax),%eax
80104018:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010401f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104026:	eb 3b                	jmp    80104063 <fork+0x106>
    if(curproc->ofile[i])
80104028:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010402b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010402e:	83 c2 08             	add    $0x8,%edx
80104031:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104035:	85 c0                	test   %eax,%eax
80104037:	74 26                	je     8010405f <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104039:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010403c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010403f:	83 c2 08             	add    $0x8,%edx
80104042:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104046:	83 ec 0c             	sub    $0xc,%esp
80104049:	50                   	push   %eax
8010404a:	e8 45 d0 ff ff       	call   80101094 <filedup>
8010404f:	83 c4 10             	add    $0x10,%esp
80104052:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104055:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104058:	83 c1 08             	add    $0x8,%ecx
8010405b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010405f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104063:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104067:	7e bf                	jle    80104028 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104069:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010406c:	8b 40 68             	mov    0x68(%eax),%eax
8010406f:	83 ec 0c             	sub    $0xc,%esp
80104072:	50                   	push   %eax
80104073:	e8 c6 d9 ff ff       	call   80101a3e <idup>
80104078:	83 c4 10             	add    $0x10,%esp
8010407b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010407e:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104081:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104084:	8d 50 6c             	lea    0x6c(%eax),%edx
80104087:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010408a:	83 c0 6c             	add    $0x6c,%eax
8010408d:	83 ec 04             	sub    $0x4,%esp
80104090:	6a 10                	push   $0x10
80104092:	52                   	push   %edx
80104093:	50                   	push   %eax
80104094:	e8 40 17 00 00       	call   801057d9 <safestrcpy>
80104099:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010409c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010409f:	8b 40 10             	mov    0x10(%eax),%eax
801040a2:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801040a5:	83 ec 0c             	sub    $0xc,%esp
801040a8:	68 20 75 19 80       	push   $0x80197520
801040ad:	e8 7d 12 00 00       	call   8010532f <acquire>
801040b2:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801040b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040b8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  cprintf("[FORK] pid %d created, sched_policy = %d\n", np->pid, mycpu()->sched_policy);
801040bf:	e8 69 fa ff ff       	call   80103b2d <mycpu>
801040c4:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
801040ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040cd:	8b 40 10             	mov    0x10(%eax),%eax
801040d0:	83 ec 04             	sub    $0x4,%esp
801040d3:	52                   	push   %edx
801040d4:	50                   	push   %eax
801040d5:	68 54 b2 10 80       	push   $0x8010b254
801040da:	e8 2d c3 ff ff       	call   8010040c <cprintf>
801040df:	83 c4 10             	add    $0x10,%esp
  if (cpus[0].sched_policy > 0){
801040e2:	a1 90 9d 19 80       	mov    0x80199d90,%eax
801040e7:	85 c0                	test   %eax,%eax
801040e9:	7e 2f                	jle    8010411a <fork+0x1bd>
    kernel_pstat.priority[np - ptable.proc] = 3;
801040eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040ee:	2d 54 75 19 80       	sub    $0x80197554,%eax
801040f3:	c1 f8 02             	sar    $0x2,%eax
801040f6:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801040fc:	83 e8 80             	sub    $0xffffff80,%eax
801040ff:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80104106:	03 00 00 00 
    enqueue(np, 3);
8010410a:	83 ec 08             	sub    $0x8,%esp
8010410d:	6a 03                	push   $0x3
8010410f:	ff 75 dc             	push   -0x24(%ebp)
80104112:	e8 4c 0a 00 00       	call   80104b63 <enqueue>
80104117:	83 c4 10             	add    $0x10,%esp
  }
   

  release(&ptable.lock);
8010411a:	83 ec 0c             	sub    $0xc,%esp
8010411d:	68 20 75 19 80       	push   $0x80197520
80104122:	e8 7a 12 00 00       	call   801053a1 <release>
80104127:	83 c4 10             	add    $0x10,%esp

  return pid;
8010412a:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010412d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104130:	5b                   	pop    %ebx
80104131:	5e                   	pop    %esi
80104132:	5f                   	pop    %edi
80104133:	5d                   	pop    %ebp
80104134:	c3                   	ret

80104135 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104135:	f3 0f 1e fb          	endbr32
80104139:	55                   	push   %ebp
8010413a:	89 e5                	mov    %esp,%ebp
8010413c:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
8010413f:	e8 65 fa ff ff       	call   80103ba9 <myproc>
80104144:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;
  
  if(curproc == initproc)
80104147:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
8010414c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010414f:	75 0d                	jne    8010415e <exit+0x29>
    panic("init exiting");
80104151:	83 ec 0c             	sub    $0xc,%esp
80104154:	68 7e b2 10 80       	push   $0x8010b27e
80104159:	e8 67 c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010415e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104165:	eb 3f                	jmp    801041a6 <exit+0x71>
    if(curproc->ofile[fd]){
80104167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010416a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010416d:	83 c2 08             	add    $0x8,%edx
80104170:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	74 2a                	je     801041a2 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010417b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010417e:	83 c2 08             	add    $0x8,%edx
80104181:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104185:	83 ec 0c             	sub    $0xc,%esp
80104188:	50                   	push   %eax
80104189:	e8 5b cf ff ff       	call   801010e9 <fileclose>
8010418e:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104194:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104197:	83 c2 08             	add    $0x8,%edx
8010419a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041a1:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041a6:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041aa:	7e bb                	jle    80104167 <exit+0x32>
    }
  }

  begin_op();
801041ac:	e8 c0 ef ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801041b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b4:	8b 40 68             	mov    0x68(%eax),%eax
801041b7:	83 ec 0c             	sub    $0xc,%esp
801041ba:	50                   	push   %eax
801041bb:	e8 25 da ff ff       	call   80101be5 <iput>
801041c0:	83 c4 10             	add    $0x10,%esp
  end_op();
801041c3:	e8 39 f0 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801041c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041cb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801041d2:	83 ec 0c             	sub    $0xc,%esp
801041d5:	68 20 75 19 80       	push   $0x80197520
801041da:	e8 50 11 00 00       	call   8010532f <acquire>
801041df:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801041e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041e5:	8b 40 14             	mov    0x14(%eax),%eax
801041e8:	83 ec 0c             	sub    $0xc,%esp
801041eb:	50                   	push   %eax
801041ec:	e8 23 05 00 00       	call   80104714 <wakeup1>
801041f1:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041f4:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
801041fb:	eb 37                	jmp    80104234 <exit+0xff>
    if(p->parent == curproc){
801041fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104200:	8b 40 14             	mov    0x14(%eax),%eax
80104203:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104206:	75 28                	jne    80104230 <exit+0xfb>
      p->parent = initproc;
80104208:	8b 15 7c e0 18 80    	mov    0x8018e07c,%edx
8010420e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104211:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104217:	8b 40 0c             	mov    0xc(%eax),%eax
8010421a:	83 f8 05             	cmp    $0x5,%eax
8010421d:	75 11                	jne    80104230 <exit+0xfb>
        wakeup1(initproc);
8010421f:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	50                   	push   %eax
80104228:	e8 e7 04 00 00       	call   80104714 <wakeup1>
8010422d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104230:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104234:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
8010423b:	72 c0                	jb     801041fd <exit+0xc8>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
8010423d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104240:	2d 54 75 19 80       	sub    $0x80197554,%eax
80104245:	c1 f8 02             	sar    $0x2,%eax
80104248:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
8010424e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
80104251:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104254:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
8010425b:	00 00 00 00 
  int q;
  q = kernel_pstat.priority[i];
8010425f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104262:	83 e8 80             	sub    $0xffffff80,%eax
80104265:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
8010426c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (p == dequeue(q))
8010426f:	83 ec 0c             	sub    $0xc,%esp
80104272:	ff 75 e4             	push   -0x1c(%ebp)
80104275:	e8 68 09 00 00       	call   80104be2 <dequeue>
8010427a:	83 c4 10             	add    $0x10,%esp
8010427d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104280:	75 10                	jne    80104292 <exit+0x15d>
  {
    cprintf("[PROCESS EXIT] suc\n");
80104282:	83 ec 0c             	sub    $0xc,%esp
80104285:	68 8b b2 10 80       	push   $0x8010b28b
8010428a:	e8 7d c1 ff ff       	call   8010040c <cprintf>
8010428f:	83 c4 10             	add    $0x10,%esp
  }
   
  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104292:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104295:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010429c:	e8 83 02 00 00       	call   80104524 <sched>
  panic("zombie exit");
801042a1:	83 ec 0c             	sub    $0xc,%esp
801042a4:	68 9f b2 10 80       	push   $0x8010b29f
801042a9:	e8 17 c3 ff ff       	call   801005c5 <panic>

801042ae <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801042ae:	f3 0f 1e fb          	endbr32
801042b2:	55                   	push   %ebp
801042b3:	89 e5                	mov    %esp,%ebp
801042b5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801042b8:	e8 ec f8 ff ff       	call   80103ba9 <myproc>
801042bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801042c0:	83 ec 0c             	sub    $0xc,%esp
801042c3:	68 20 75 19 80       	push   $0x80197520
801042c8:	e8 62 10 00 00       	call   8010532f <acquire>
801042cd:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801042d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042d7:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
801042de:	e9 a1 00 00 00       	jmp    80104384 <wait+0xd6>
      if(p->parent != curproc)
801042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e6:	8b 40 14             	mov    0x14(%eax),%eax
801042e9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042ec:	0f 85 8d 00 00 00    	jne    8010437f <wait+0xd1>
        continue;
      havekids = 1;
801042f2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	8b 40 0c             	mov    0xc(%eax),%eax
801042ff:	83 f8 05             	cmp    $0x5,%eax
80104302:	75 7c                	jne    80104380 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104307:	8b 40 10             	mov    0x10(%eax),%eax
8010430a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104310:	8b 40 08             	mov    0x8(%eax),%eax
80104313:	83 ec 0c             	sub    $0xc,%esp
80104316:	50                   	push   %eax
80104317:	e8 d8 e4 ff ff       	call   801027f4 <kfree>
8010431c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432c:	8b 40 04             	mov    0x4(%eax),%eax
8010432f:	83 ec 0c             	sub    $0xc,%esp
80104332:	50                   	push   %eax
80104333:	e8 e7 43 00 00       	call   8010871f <freevm>
80104338:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104348:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104359:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104363:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	68 20 75 19 80       	push   $0x80197520
80104372:	e8 2a 10 00 00       	call   801053a1 <release>
80104377:	83 c4 10             	add    $0x10,%esp
        return pid;
8010437a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010437d:	eb 51                	jmp    801043d0 <wait+0x122>
        continue;
8010437f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104380:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104384:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
8010438b:	0f 82 52 ff ff ff    	jb     801042e3 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104391:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104395:	74 0a                	je     801043a1 <wait+0xf3>
80104397:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010439a:	8b 40 24             	mov    0x24(%eax),%eax
8010439d:	85 c0                	test   %eax,%eax
8010439f:	74 17                	je     801043b8 <wait+0x10a>
      release(&ptable.lock);
801043a1:	83 ec 0c             	sub    $0xc,%esp
801043a4:	68 20 75 19 80       	push   $0x80197520
801043a9:	e8 f3 0f 00 00       	call   801053a1 <release>
801043ae:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b6:	eb 18                	jmp    801043d0 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801043b8:	83 ec 08             	sub    $0x8,%esp
801043bb:	68 20 75 19 80       	push   $0x80197520
801043c0:	ff 75 ec             	push   -0x14(%ebp)
801043c3:	e8 a1 02 00 00       	call   80104669 <sleep>
801043c8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801043cb:	e9 00 ff ff ff       	jmp    801042d0 <wait+0x22>
  }
}
801043d0:	c9                   	leave
801043d1:	c3                   	ret

801043d2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801043d2:	f3 0f 1e fb          	endbr32
801043d6:	55                   	push   %ebp
801043d7:	89 e5                	mov    %esp,%ebp
801043d9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801043dc:	e8 4c f7 ff ff       	call   80103b2d <mycpu>
801043e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801043e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043e7:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043ee:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801043f1:	e8 ef f6 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801043f6:	83 ec 0c             	sub    $0xc,%esp
801043f9:	68 20 75 19 80       	push   $0x80197520
801043fe:	e8 2c 0f 00 00       	call   8010532f <acquire>
80104403:	83 c4 10             	add    $0x10,%esp
    

    if (mycpu()->sched_policy == 0) {
80104406:	e8 22 f7 ff ff       	call   80103b2d <mycpu>
8010440b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104411:	85 c0                	test   %eax,%eax
80104413:	0f 85 f1 00 00 00    	jne    8010450a <scheduler+0x138>
      // Round Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104419:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
80104420:	eb 61                	jmp    80104483 <scheduler+0xb1>
        if(p->state != RUNNABLE)
80104422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104425:	8b 40 0c             	mov    0xc(%eax),%eax
80104428:	83 f8 03             	cmp    $0x3,%eax
8010442b:	75 51                	jne    8010447e <scheduler+0xac>
          continue;
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        c->proc = p;
8010442d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104430:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104433:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104439:	83 ec 0c             	sub    $0xc,%esp
8010443c:	ff 75 f4             	push   -0xc(%ebp)
8010443f:	e8 22 3e 00 00       	call   80108266 <switchuvm>
80104444:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	8b 40 1c             	mov    0x1c(%eax),%eax
80104457:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445a:	83 c2 04             	add    $0x4,%edx
8010445d:	83 ec 08             	sub    $0x8,%esp
80104460:	50                   	push   %eax
80104461:	52                   	push   %edx
80104462:	e8 eb 13 00 00       	call   80105852 <swtch>
80104467:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010446a:	e8 da 3d 00 00       	call   80108249 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
8010446f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104472:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104479:	00 00 00 
8010447c:	eb 01                	jmp    8010447f <scheduler+0xad>
          continue;
8010447e:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010447f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104483:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
8010448a:	72 96                	jb     80104422 <scheduler+0x50>
      }
      // wait_ticks 누적
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010448c:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
80104493:	eb 6a                	jmp    801044ff <scheduler+0x12d>
        if(p->state == RUNNABLE && p != c->proc){
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	8b 40 0c             	mov    0xc(%eax),%eax
8010449b:	83 f8 03             	cmp    $0x3,%eax
8010449e:	75 5b                	jne    801044fb <scheduler+0x129>
801044a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044a9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044ac:	74 4d                	je     801044fb <scheduler+0x129>
          int i = p - ptable.proc;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	2d 54 75 19 80       	sub    $0x80197554,%eax
801044b6:	c1 f8 02             	sar    $0x2,%eax
801044b9:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801044bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
          kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
801044c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044c5:	83 e8 80             	sub    $0xffffff80,%eax
801044c8:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
801044cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801044d2:	c1 e2 02             	shl    $0x2,%edx
801044d5:	01 c2                	add    %eax,%edx
801044d7:	81 c2 00 02 00 00    	add    $0x200,%edx
801044dd:	8b 14 95 20 69 19 80 	mov    -0x7fe696e0(,%edx,4),%edx
801044e4:	83 c2 01             	add    $0x1,%edx
801044e7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801044ea:	c1 e1 02             	shl    $0x2,%ecx
801044ed:	01 c8                	add    %ecx,%eax
801044ef:	05 00 02 00 00       	add    $0x200,%eax
801044f4:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044fb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044ff:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
80104506:	72 8d                	jb     80104495 <scheduler+0xc3>
80104508:	eb 05                	jmp    8010450f <scheduler+0x13d>
        }
      }
    } else {
      // TODO: MLFQ로 넘기기
      run_mlfq();
8010450a:	e8 47 0b 00 00       	call   80105056 <run_mlfq>
    }  

    release(&ptable.lock);
8010450f:	83 ec 0c             	sub    $0xc,%esp
80104512:	68 20 75 19 80       	push   $0x80197520
80104517:	e8 85 0e 00 00       	call   801053a1 <release>
8010451c:	83 c4 10             	add    $0x10,%esp
    sti();
8010451f:	e9 cd fe ff ff       	jmp    801043f1 <scheduler+0x1f>

80104524 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104524:	f3 0f 1e fb          	endbr32
80104528:	55                   	push   %ebp
80104529:	89 e5                	mov    %esp,%ebp
8010452b:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010452e:	e8 76 f6 ff ff       	call   80103ba9 <myproc>
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104536:	83 ec 0c             	sub    $0xc,%esp
80104539:	68 20 75 19 80       	push   $0x80197520
8010453e:	e8 33 0f 00 00       	call   80105476 <holding>
80104543:	83 c4 10             	add    $0x10,%esp
80104546:	85 c0                	test   %eax,%eax
80104548:	75 0d                	jne    80104557 <sched+0x33>
    panic("sched ptable.lock");
8010454a:	83 ec 0c             	sub    $0xc,%esp
8010454d:	68 ab b2 10 80       	push   $0x8010b2ab
80104552:	e8 6e c0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104557:	e8 d1 f5 ff ff       	call   80103b2d <mycpu>
8010455c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104562:	83 f8 01             	cmp    $0x1,%eax
80104565:	74 0d                	je     80104574 <sched+0x50>
    panic("sched locks");
80104567:	83 ec 0c             	sub    $0xc,%esp
8010456a:	68 bd b2 10 80       	push   $0x8010b2bd
8010456f:	e8 51 c0 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104577:	8b 40 0c             	mov    0xc(%eax),%eax
8010457a:	83 f8 04             	cmp    $0x4,%eax
8010457d:	75 0d                	jne    8010458c <sched+0x68>
    panic("sched running");
8010457f:	83 ec 0c             	sub    $0xc,%esp
80104582:	68 c9 b2 10 80       	push   $0x8010b2c9
80104587:	e8 39 c0 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
8010458c:	e8 44 f5 ff ff       	call   80103ad5 <readeflags>
80104591:	25 00 02 00 00       	and    $0x200,%eax
80104596:	85 c0                	test   %eax,%eax
80104598:	74 0d                	je     801045a7 <sched+0x83>
    panic("sched interruptible");
8010459a:	83 ec 0c             	sub    $0xc,%esp
8010459d:	68 d7 b2 10 80       	push   $0x8010b2d7
801045a2:	e8 1e c0 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801045a7:	e8 81 f5 ff ff       	call   80103b2d <mycpu>
801045ac:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045b5:	e8 73 f5 ff ff       	call   80103b2d <mycpu>
801045ba:	8b 40 04             	mov    0x4(%eax),%eax
801045bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c0:	83 c2 1c             	add    $0x1c,%edx
801045c3:	83 ec 08             	sub    $0x8,%esp
801045c6:	50                   	push   %eax
801045c7:	52                   	push   %edx
801045c8:	e8 85 12 00 00       	call   80105852 <swtch>
801045cd:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801045d0:	e8 58 f5 ff ff       	call   80103b2d <mycpu>
801045d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045d8:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801045de:	90                   	nop
801045df:	c9                   	leave
801045e0:	c3                   	ret

801045e1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801045e1:	f3 0f 1e fb          	endbr32
801045e5:	55                   	push   %ebp
801045e6:	89 e5                	mov    %esp,%ebp
801045e8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801045eb:	83 ec 0c             	sub    $0xc,%esp
801045ee:	68 20 75 19 80       	push   $0x80197520
801045f3:	e8 37 0d 00 00       	call   8010532f <acquire>
801045f8:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801045fb:	e8 a9 f5 ff ff       	call   80103ba9 <myproc>
80104600:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104607:	e8 18 ff ff ff       	call   80104524 <sched>
  release(&ptable.lock);
8010460c:	83 ec 0c             	sub    $0xc,%esp
8010460f:	68 20 75 19 80       	push   $0x80197520
80104614:	e8 88 0d 00 00       	call   801053a1 <release>
80104619:	83 c4 10             	add    $0x10,%esp
}
8010461c:	90                   	nop
8010461d:	c9                   	leave
8010461e:	c3                   	ret

8010461f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010461f:	f3 0f 1e fb          	endbr32
80104623:	55                   	push   %ebp
80104624:	89 e5                	mov    %esp,%ebp
80104626:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104629:	83 ec 0c             	sub    $0xc,%esp
8010462c:	68 20 75 19 80       	push   $0x80197520
80104631:	e8 6b 0d 00 00       	call   801053a1 <release>
80104636:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104639:	a1 04 00 11 80       	mov    0x80110004,%eax
8010463e:	85 c0                	test   %eax,%eax
80104640:	74 24                	je     80104666 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104642:	c7 05 04 00 11 80 00 	movl   $0x0,0x80110004
80104649:	00 00 00 
    iinit(ROOTDEV);
8010464c:	83 ec 0c             	sub    $0xc,%esp
8010464f:	6a 01                	push   $0x1
80104651:	e8 a0 d0 ff ff       	call   801016f6 <iinit>
80104656:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104659:	83 ec 0c             	sub    $0xc,%esp
8010465c:	6a 01                	push   $0x1
8010465e:	e8 db e8 ff ff       	call   80102f3e <initlog>
80104663:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104666:	90                   	nop
80104667:	c9                   	leave
80104668:	c3                   	ret

80104669 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104669:	f3 0f 1e fb          	endbr32
8010466d:	55                   	push   %ebp
8010466e:	89 e5                	mov    %esp,%ebp
80104670:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104673:	e8 31 f5 ff ff       	call   80103ba9 <myproc>
80104678:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010467b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010467f:	75 0d                	jne    8010468e <sleep+0x25>
    panic("sleep");
80104681:	83 ec 0c             	sub    $0xc,%esp
80104684:	68 eb b2 10 80       	push   $0x8010b2eb
80104689:	e8 37 bf ff ff       	call   801005c5 <panic>

  if(lk == 0)
8010468e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104692:	75 0d                	jne    801046a1 <sleep+0x38>
    panic("sleep without lk");
80104694:	83 ec 0c             	sub    $0xc,%esp
80104697:	68 f1 b2 10 80       	push   $0x8010b2f1
8010469c:	e8 24 bf ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801046a1:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
801046a8:	74 1e                	je     801046c8 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801046aa:	83 ec 0c             	sub    $0xc,%esp
801046ad:	68 20 75 19 80       	push   $0x80197520
801046b2:	e8 78 0c 00 00       	call   8010532f <acquire>
801046b7:	83 c4 10             	add    $0x10,%esp
    release(lk);
801046ba:	83 ec 0c             	sub    $0xc,%esp
801046bd:	ff 75 0c             	push   0xc(%ebp)
801046c0:	e8 dc 0c 00 00       	call   801053a1 <release>
801046c5:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	8b 55 08             	mov    0x8(%ebp),%edx
801046ce:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801046db:	e8 44 fe ff ff       	call   80104524 <sched>

  // Tidy up.
  p->chan = 0;
801046e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801046ea:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
801046f1:	74 1e                	je     80104711 <sleep+0xa8>
    release(&ptable.lock);
801046f3:	83 ec 0c             	sub    $0xc,%esp
801046f6:	68 20 75 19 80       	push   $0x80197520
801046fb:	e8 a1 0c 00 00       	call   801053a1 <release>
80104700:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104703:	83 ec 0c             	sub    $0xc,%esp
80104706:	ff 75 0c             	push   0xc(%ebp)
80104709:	e8 21 0c 00 00       	call   8010532f <acquire>
8010470e:	83 c4 10             	add    $0x10,%esp
  }
}
80104711:	90                   	nop
80104712:	c9                   	leave
80104713:	c3                   	ret

80104714 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104714:	f3 0f 1e fb          	endbr32
80104718:	55                   	push   %ebp
80104719:	89 e5                	mov    %esp,%ebp
8010471b:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010471e:	c7 45 fc 54 75 19 80 	movl   $0x80197554,-0x4(%ebp)
80104725:	eb 24                	jmp    8010474b <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104727:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010472a:	8b 40 0c             	mov    0xc(%eax),%eax
8010472d:	83 f8 02             	cmp    $0x2,%eax
80104730:	75 15                	jne    80104747 <wakeup1+0x33>
80104732:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104735:	8b 40 20             	mov    0x20(%eax),%eax
80104738:	39 45 08             	cmp    %eax,0x8(%ebp)
8010473b:	75 0a                	jne    80104747 <wakeup1+0x33>
      p->state = RUNNABLE;
8010473d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104740:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104747:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010474b:	81 7d fc 54 94 19 80 	cmpl   $0x80199454,-0x4(%ebp)
80104752:	72 d3                	jb     80104727 <wakeup1+0x13>
}
80104754:	90                   	nop
80104755:	90                   	nop
80104756:	c9                   	leave
80104757:	c3                   	ret

80104758 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104758:	f3 0f 1e fb          	endbr32
8010475c:	55                   	push   %ebp
8010475d:	89 e5                	mov    %esp,%ebp
8010475f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	68 20 75 19 80       	push   $0x80197520
8010476a:	e8 c0 0b 00 00       	call   8010532f <acquire>
8010476f:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104772:	83 ec 0c             	sub    $0xc,%esp
80104775:	ff 75 08             	push   0x8(%ebp)
80104778:	e8 97 ff ff ff       	call   80104714 <wakeup1>
8010477d:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104780:	83 ec 0c             	sub    $0xc,%esp
80104783:	68 20 75 19 80       	push   $0x80197520
80104788:	e8 14 0c 00 00       	call   801053a1 <release>
8010478d:	83 c4 10             	add    $0x10,%esp
}
80104790:	90                   	nop
80104791:	c9                   	leave
80104792:	c3                   	ret

80104793 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104793:	f3 0f 1e fb          	endbr32
80104797:	55                   	push   %ebp
80104798:	89 e5                	mov    %esp,%ebp
8010479a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	68 20 75 19 80       	push   $0x80197520
801047a5:	e8 85 0b 00 00       	call   8010532f <acquire>
801047aa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ad:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
801047b4:	eb 45                	jmp    801047fb <kill+0x68>
    if(p->pid == pid){
801047b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b9:	8b 40 10             	mov    0x10(%eax),%eax
801047bc:	39 45 08             	cmp    %eax,0x8(%ebp)
801047bf:	75 36                	jne    801047f7 <kill+0x64>
      p->killed = 1;
801047c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	8b 40 0c             	mov    0xc(%eax),%eax
801047d1:	83 f8 02             	cmp    $0x2,%eax
801047d4:	75 0a                	jne    801047e0 <kill+0x4d>
        p->state = RUNNABLE;
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801047e0:	83 ec 0c             	sub    $0xc,%esp
801047e3:	68 20 75 19 80       	push   $0x80197520
801047e8:	e8 b4 0b 00 00       	call   801053a1 <release>
801047ed:	83 c4 10             	add    $0x10,%esp
      return 0;
801047f0:	b8 00 00 00 00       	mov    $0x0,%eax
801047f5:	eb 22                	jmp    80104819 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047f7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801047fb:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
80104802:	72 b2                	jb     801047b6 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104804:	83 ec 0c             	sub    $0xc,%esp
80104807:	68 20 75 19 80       	push   $0x80197520
8010480c:	e8 90 0b 00 00       	call   801053a1 <release>
80104811:	83 c4 10             	add    $0x10,%esp
  return -1;
80104814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104819:	c9                   	leave
8010481a:	c3                   	ret

8010481b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010481b:	f3 0f 1e fb          	endbr32
8010481f:	55                   	push   %ebp
80104820:	89 e5                	mov    %esp,%ebp
80104822:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104825:	c7 45 f0 54 75 19 80 	movl   $0x80197554,-0x10(%ebp)
8010482c:	e9 d7 00 00 00       	jmp    80104908 <procdump+0xed>
    if(p->state == UNUSED)
80104831:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104834:	8b 40 0c             	mov    0xc(%eax),%eax
80104837:	85 c0                	test   %eax,%eax
80104839:	0f 84 c4 00 00 00    	je     80104903 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010483f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104842:	8b 40 0c             	mov    0xc(%eax),%eax
80104845:	83 f8 05             	cmp    $0x5,%eax
80104848:	77 23                	ja     8010486d <procdump+0x52>
8010484a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010484d:	8b 40 0c             	mov    0xc(%eax),%eax
80104850:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
80104857:	85 c0                	test   %eax,%eax
80104859:	74 12                	je     8010486d <procdump+0x52>
      state = states[p->state];
8010485b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485e:	8b 40 0c             	mov    0xc(%eax),%eax
80104861:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
80104868:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010486b:	eb 07                	jmp    80104874 <procdump+0x59>
    else
      state = "???";
8010486d:	c7 45 ec 02 b3 10 80 	movl   $0x8010b302,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104877:	8d 50 6c             	lea    0x6c(%eax),%edx
8010487a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010487d:	8b 40 10             	mov    0x10(%eax),%eax
80104880:	52                   	push   %edx
80104881:	ff 75 ec             	push   -0x14(%ebp)
80104884:	50                   	push   %eax
80104885:	68 06 b3 10 80       	push   $0x8010b306
8010488a:	e8 7d bb ff ff       	call   8010040c <cprintf>
8010488f:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104895:	8b 40 0c             	mov    0xc(%eax),%eax
80104898:	83 f8 02             	cmp    $0x2,%eax
8010489b:	75 54                	jne    801048f1 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010489d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a0:	8b 40 1c             	mov    0x1c(%eax),%eax
801048a3:	8b 40 0c             	mov    0xc(%eax),%eax
801048a6:	83 c0 08             	add    $0x8,%eax
801048a9:	89 c2                	mov    %eax,%edx
801048ab:	83 ec 08             	sub    $0x8,%esp
801048ae:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801048b1:	50                   	push   %eax
801048b2:	52                   	push   %edx
801048b3:	e8 3f 0b 00 00       	call   801053f7 <getcallerpcs>
801048b8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048c2:	eb 1c                	jmp    801048e0 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801048c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048cb:	83 ec 08             	sub    $0x8,%esp
801048ce:	50                   	push   %eax
801048cf:	68 0f b3 10 80       	push   $0x8010b30f
801048d4:	e8 33 bb ff ff       	call   8010040c <cprintf>
801048d9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801048e0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801048e4:	7f 0b                	jg     801048f1 <procdump+0xd6>
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048ed:	85 c0                	test   %eax,%eax
801048ef:	75 d3                	jne    801048c4 <procdump+0xa9>
    }
    cprintf("\n");
801048f1:	83 ec 0c             	sub    $0xc,%esp
801048f4:	68 13 b3 10 80       	push   $0x8010b313
801048f9:	e8 0e bb ff ff       	call   8010040c <cprintf>
801048fe:	83 c4 10             	add    $0x10,%esp
80104901:	eb 01                	jmp    80104904 <procdump+0xe9>
      continue;
80104903:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104904:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104908:	81 7d f0 54 94 19 80 	cmpl   $0x80199454,-0x10(%ebp)
8010490f:	0f 82 1c ff ff ff    	jb     80104831 <procdump+0x16>
  }
}
80104915:	90                   	nop
80104916:	90                   	nop
80104917:	c9                   	leave
80104918:	c3                   	ret

80104919 <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
80104919:	f3 0f 1e fb          	endbr32
8010491d:	55                   	push   %ebp
8010491e:	89 e5                	mov    %esp,%ebp
80104920:	53                   	push   %ebx
80104921:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104924:	83 ec 0c             	sub    $0xc,%esp
80104927:	68 20 75 19 80       	push   $0x80197520
8010492c:	e8 fe 09 00 00       	call   8010532f <acquire>
80104931:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104934:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010493b:	e9 e6 00 00 00       	jmp    80104a26 <getpinfo+0x10d>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 0c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ecx
8010494a:	8b 45 08             	mov    0x8(%ebp),%eax
8010494d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104950:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104956:	83 c0 40             	add    $0x40,%eax
80104959:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104960:	8b 45 08             	mov    0x8(%ebp),%eax
80104963:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104966:	83 c1 40             	add    $0x40,%ecx
80104969:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
8010496c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496f:	83 e8 80             	sub    $0xffffff80,%eax
80104972:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104979:	8b 45 08             	mov    0x8(%ebp),%eax
8010497c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010497f:	83 e9 80             	sub    $0xffffff80,%ecx
80104982:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
80104985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104988:	6b c0 7c             	imul   $0x7c,%eax,%eax
8010498b:	05 60 75 19 80       	add    $0x80197560,%eax
80104990:	8b 00                	mov    (%eax),%eax
80104992:	89 c1                	mov    %eax,%ecx
80104994:	8b 45 08             	mov    0x8(%ebp),%eax
80104997:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010499a:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801049a0:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801049a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049aa:	eb 70                	jmp    80104a1c <getpinfo+0x103>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b9:	01 d0                	add    %edx,%eax
801049bb:	05 00 01 00 00       	add    $0x100,%eax
801049c0:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
801049c7:	8b 45 08             	mov    0x8(%ebp),%eax
801049ca:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049cd:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801049d4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801049d7:	01 d9                	add    %ebx,%ecx
801049d9:	81 c1 00 01 00 00    	add    $0x100,%ecx
801049df:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
801049e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ef:	01 d0                	add    %edx,%eax
801049f1:	05 00 02 00 00       	add    $0x200,%eax
801049f6:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
801049fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104a00:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a03:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a0a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a0d:	01 d9                	add    %ebx,%ecx
80104a0f:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a15:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104a18:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a1c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a20:	7e 8a                	jle    801049ac <getpinfo+0x93>
  for (int i = 0; i < NPROC; i++) {
80104a22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a26:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a2a:	0f 8e 10 ff ff ff    	jle    80104940 <getpinfo+0x27>
    }
  }
  release(&ptable.lock);
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	68 20 75 19 80       	push   $0x80197520
80104a38:	e8 64 09 00 00       	call   801053a1 <release>
80104a3d:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a48:	c9                   	leave
80104a49:	c3                   	ret

80104a4a <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
80104a4a:	f3 0f 1e fb          	endbr32
80104a4e:	55                   	push   %ebp
80104a4f:	89 e5                	mov    %esp,%ebp
80104a51:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a54:	83 ec 0c             	sub    $0xc,%esp
80104a57:	68 20 75 19 80       	push   $0x80197520
80104a5c:	e8 ce 08 00 00       	call   8010532f <acquire>
80104a61:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104a64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a6b:	eb 6f                	jmp    80104adc <mlfq_enqueue_all_runnable+0x92>
    if (!kernel_pstat.inuse[i]) continue;
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104a77:	85 c0                	test   %eax,%eax
80104a79:	74 5c                	je     80104ad7 <mlfq_enqueue_all_runnable+0x8d>
    struct proc *p = &ptable.proc[i];
80104a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104a81:	83 c0 30             	add    $0x30,%eax
80104a84:	05 20 75 19 80       	add    $0x80197520,%eax
80104a89:	83 c0 04             	add    $0x4,%eax
80104a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE) {
80104a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a92:	8b 40 0c             	mov    0xc(%eax),%eax
80104a95:	83 f8 03             	cmp    $0x3,%eax
80104a98:	75 3e                	jne    80104ad8 <mlfq_enqueue_all_runnable+0x8e>
      int q = kernel_pstat.priority[i];
80104a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9d:	83 e8 80             	sub    $0xffffff80,%eax
80104aa0:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
80104aaa:	83 ec 08             	sub    $0x8,%esp
80104aad:	ff 75 ec             	push   -0x14(%ebp)
80104ab0:	ff 75 f0             	push   -0x10(%ebp)
80104ab3:	e8 ab 00 00 00       	call   80104b63 <enqueue>
80104ab8:	83 c4 10             	add    $0x10,%esp
      cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
80104abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104abe:	8b 40 10             	mov    0x10(%eax),%eax
80104ac1:	83 ec 04             	sub    $0x4,%esp
80104ac4:	ff 75 ec             	push   -0x14(%ebp)
80104ac7:	50                   	push   %eax
80104ac8:	68 15 b3 10 80       	push   $0x8010b315
80104acd:	e8 3a b9 ff ff       	call   8010040c <cprintf>
80104ad2:	83 c4 10             	add    $0x10,%esp
80104ad5:	eb 01                	jmp    80104ad8 <mlfq_enqueue_all_runnable+0x8e>
    if (!kernel_pstat.inuse[i]) continue;
80104ad7:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104ad8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104adc:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104ae0:	7e 8b                	jle    80104a6d <mlfq_enqueue_all_runnable+0x23>
    }
  }
  release(&ptable.lock);
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	68 20 75 19 80       	push   $0x80197520
80104aea:	e8 b2 08 00 00       	call   801053a1 <release>
80104aef:	83 c4 10             	add    $0x10,%esp
}
80104af2:	90                   	nop
80104af3:	c9                   	leave
80104af4:	c3                   	ret

80104af5 <set_sched_policy>:

int
set_sched_policy(int policy)
{
80104af5:	f3 0f 1e fb          	endbr32
80104af9:	55                   	push   %ebp
80104afa:	89 e5                	mov    %esp,%ebp
80104afc:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104aff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b03:	78 06                	js     80104b0b <set_sched_policy+0x16>
80104b05:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104b09:	7e 07                	jle    80104b12 <set_sched_policy+0x1d>
    return -1;
80104b0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b10:	eb 28                	jmp    80104b3a <set_sched_policy+0x45>

  pushcli(); 
80104b12:	e8 94 09 00 00       	call   801054ab <pushcli>
  mycpu()->sched_policy = policy;
80104b17:	e8 11 f0 ff ff       	call   80103b2d <mycpu>
80104b1c:	8b 55 08             	mov    0x8(%ebp),%edx
80104b1f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104b25:	e8 d2 09 00 00       	call   801054fc <popcli>

  if (policy > 0)
80104b2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b2e:	7e 05                	jle    80104b35 <set_sched_policy+0x40>
  mlfq_enqueue_all_runnable();
80104b30:	e8 15 ff ff ff       	call   80104a4a <mlfq_enqueue_all_runnable>

  return 0;
80104b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b3a:	c9                   	leave
80104b3b:	c3                   	ret

80104b3c <get_sched_policy>:
int
get_sched_policy(void)
{
80104b3c:	f3 0f 1e fb          	endbr32
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
80104b46:	e8 60 09 00 00       	call   801054ab <pushcli>
  int policy = mycpu()->sched_policy;
80104b4b:	e8 dd ef ff ff       	call   80103b2d <mycpu>
80104b50:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104b59:	e8 9e 09 00 00       	call   801054fc <popcli>
  return policy;
80104b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b61:	c9                   	leave
80104b62:	c3                   	ret

80104b63 <enqueue>:
struct proc* mlfq_queues[4][NPROC];
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void enqueue(struct proc *p, int level) {
80104b63:	f3 0f 1e fb          	endbr32
80104b67:	55                   	push   %ebp
80104b68:	89 e5                	mov    %esp,%ebp
80104b6a:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104b6d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104b74:	eb 1d                	jmp    80104b93 <enqueue+0x30>
    if (mlfq_queues[level][i] == p) {
80104b76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b79:	c1 e0 06             	shl    $0x6,%eax
80104b7c:	89 c2                	mov    %eax,%edx
80104b7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b81:	01 d0                	add    %edx,%eax
80104b83:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104b8a:	39 45 08             	cmp    %eax,0x8(%ebp)
80104b8d:	74 50                	je     80104bdf <enqueue+0x7c>
  for (int i = 0; i < NPROC; i++) {
80104b8f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b93:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104b97:	7e dd                	jle    80104b76 <enqueue+0x13>
      //cprintf("[ENQUEUE] DUP PID %d already in Q%d\n", p->pid, level);
      return;
    }
  }
  for (int i = 0; i < NPROC; i++) {
80104b99:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ba0:	eb 35                	jmp    80104bd7 <enqueue+0x74>
    if (mlfq_queues[level][i] == 0) {
80104ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba5:	c1 e0 06             	shl    $0x6,%eax
80104ba8:	89 c2                	mov    %eax,%edx
80104baa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bad:	01 d0                	add    %edx,%eax
80104baf:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104bb6:	85 c0                	test   %eax,%eax
80104bb8:	75 19                	jne    80104bd3 <enqueue+0x70>
      mlfq_queues[level][i] = p;
80104bba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bbd:	c1 e0 06             	shl    $0x6,%eax
80104bc0:	89 c2                	mov    %eax,%edx
80104bc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bc5:	01 c2                	add    %eax,%edx
80104bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bca:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      //cprintf("[ENQUEUE] PID %d → Q%d (inserted)\n", p->pid, level);
      return;
80104bd1:	eb 0d                	jmp    80104be0 <enqueue+0x7d>
  for (int i = 0; i < NPROC; i++) {
80104bd3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bd7:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104bdb:	7e c5                	jle    80104ba2 <enqueue+0x3f>
80104bdd:	eb 01                	jmp    80104be0 <enqueue+0x7d>
      return;
80104bdf:	90                   	nop
    }
  }
  //cprintf("[ENQUEUE] Failed: Q%d full\n", level);
}
80104be0:	c9                   	leave
80104be1:	c3                   	ret

80104be2 <dequeue>:

struct proc* dequeue(int level) {
80104be2:	f3 0f 1e fb          	endbr32
80104be6:	55                   	push   %ebp
80104be7:	89 e5                	mov    %esp,%ebp
80104be9:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
80104bec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  for (int i = 0; i < NPROC; i++) {
80104bf3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bfa:	e9 81 00 00 00       	jmp    80104c80 <dequeue+0x9e>
    if (mlfq_queues[level][i] != 0) {
80104bff:	8b 45 08             	mov    0x8(%ebp),%eax
80104c02:	c1 e0 06             	shl    $0x6,%eax
80104c05:	89 c2                	mov    %eax,%edx
80104c07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c0a:	01 d0                	add    %edx,%eax
80104c0c:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c13:	85 c0                	test   %eax,%eax
80104c15:	74 65                	je     80104c7c <dequeue+0x9a>
      p = mlfq_queues[level][i];
80104c17:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1a:	c1 e0 06             	shl    $0x6,%eax
80104c1d:	89 c2                	mov    %eax,%edx
80104c1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c22:	01 d0                	add    %edx,%eax
80104c24:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104c2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c34:	eb 2d                	jmp    80104c63 <dequeue+0x81>
        mlfq_queues[level][j] = mlfq_queues[level][j + 1];
80104c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c39:	8d 50 01             	lea    0x1(%eax),%edx
80104c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3f:	c1 e0 06             	shl    $0x6,%eax
80104c42:	01 d0                	add    %edx,%eax
80104c44:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c4b:	8b 55 08             	mov    0x8(%ebp),%edx
80104c4e:	89 d1                	mov    %edx,%ecx
80104c50:	c1 e1 06             	shl    $0x6,%ecx
80104c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c56:	01 ca                	add    %ecx,%edx
80104c58:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104c5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c63:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104c67:	7e cd                	jle    80104c36 <dequeue+0x54>
      mlfq_queues[level][NPROC - 1] = 0;
80104c69:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6c:	c1 e0 08             	shl    $0x8,%eax
80104c6f:	05 1c 66 19 80       	add    $0x8019661c,%eax
80104c74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      //cprintf("[DEQUEUE] PID %d from Q%d\n", p->pid, level);
      break;
80104c7a:	eb 0e                	jmp    80104c8a <dequeue+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104c7c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c80:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104c84:	0f 8e 75 ff ff ff    	jle    80104bff <dequeue+0x1d>
    }
  }
  return p;
80104c8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c8d:	c9                   	leave
80104c8e:	c3                   	ret

80104c8f <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104c8f:	f3 0f 1e fb          	endbr32
80104c93:	55                   	push   %ebp
80104c94:	89 e5                	mov    %esp,%ebp
80104c96:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104c99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ca0:	e9 da 01 00 00       	jmp    80104e7f <apply_priority_boosting+0x1f0>
    if (!kernel_pstat.inuse[i]) continue;
80104ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca8:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104caf:	85 c0                	test   %eax,%eax
80104cb1:	0f 84 c3 01 00 00    	je     80104e7a <apply_priority_boosting+0x1eb>
    int q = kernel_pstat.priority[i];
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	83 e8 80             	sub    $0xffffff80,%eax
80104cbd:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd4:	01 d0                	add    %edx,%eax
80104cd6:	05 00 02 00 00       	add    $0x200,%eax
80104cdb:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (q == 2 && waited >= 160) {
80104ce5:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104ce9:	75 70                	jne    80104d5b <apply_priority_boosting+0xcc>
80104ceb:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104cf2:	7e 67                	jle    80104d5b <apply_priority_boosting+0xcc>
      kernel_pstat.priority[i] = 3;
80104cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf7:	83 e8 80             	sub    $0xffffff80,%eax
80104cfa:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80104d01:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d08:	c1 e0 04             	shl    $0x4,%eax
80104d0b:	05 28 71 19 80       	add    $0x80197128,%eax
80104d10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d19:	83 c0 40             	add    $0x40,%eax
80104d1c:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d23:	83 ec 04             	sub    $0x4,%esp
80104d26:	ff 75 ec             	push   -0x14(%ebp)
80104d29:	50                   	push   %eax
80104d2a:	68 34 b3 10 80       	push   $0x8010b334
80104d2f:	e8 d8 b6 ff ff       	call   8010040c <cprintf>
80104d34:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104d3d:	83 c0 30             	add    $0x30,%eax
80104d40:	05 20 75 19 80       	add    $0x80197520,%eax
80104d45:	83 c0 04             	add    $0x4,%eax
80104d48:	83 ec 08             	sub    $0x8,%esp
80104d4b:	6a 03                	push   $0x3
80104d4d:	50                   	push   %eax
80104d4e:	e8 10 fe ff ff       	call   80104b63 <enqueue>
80104d53:	83 c4 10             	add    $0x10,%esp
80104d56:	e9 20 01 00 00       	jmp    80104e7b <apply_priority_boosting+0x1ec>
    } else if (q == 1 && waited >= 320) {
80104d5b:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104d5f:	75 70                	jne    80104dd1 <apply_priority_boosting+0x142>
80104d61:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104d68:	7e 67                	jle    80104dd1 <apply_priority_boosting+0x142>
      kernel_pstat.priority[i] = 2;
80104d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6d:	83 e8 80             	sub    $0xffffff80,%eax
80104d70:	c7 04 85 20 69 19 80 	movl   $0x2,-0x7fe696e0(,%eax,4)
80104d77:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7e:	c1 e0 04             	shl    $0x4,%eax
80104d81:	05 24 71 19 80       	add    $0x80197124,%eax
80104d86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8f:	83 c0 40             	add    $0x40,%eax
80104d92:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d99:	83 ec 04             	sub    $0x4,%esp
80104d9c:	ff 75 ec             	push   -0x14(%ebp)
80104d9f:	50                   	push   %eax
80104da0:	68 58 b3 10 80       	push   $0x8010b358
80104da5:	e8 62 b6 ff ff       	call   8010040c <cprintf>
80104daa:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db0:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104db3:	83 c0 30             	add    $0x30,%eax
80104db6:	05 20 75 19 80       	add    $0x80197520,%eax
80104dbb:	83 c0 04             	add    $0x4,%eax
80104dbe:	83 ec 08             	sub    $0x8,%esp
80104dc1:	6a 02                	push   $0x2
80104dc3:	50                   	push   %eax
80104dc4:	e8 9a fd ff ff       	call   80104b63 <enqueue>
80104dc9:	83 c4 10             	add    $0x10,%esp
80104dcc:	e9 aa 00 00 00       	jmp    80104e7b <apply_priority_boosting+0x1ec>
    } else if (q == 0 && waited >= 500) {
80104dd1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104dd5:	0f 85 a0 00 00 00    	jne    80104e7b <apply_priority_boosting+0x1ec>
80104ddb:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104de2:	0f 8e 93 00 00 00    	jle    80104e7b <apply_priority_boosting+0x1ec>
      int pid = kernel_pstat.pid[i];
80104de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104deb:	83 c0 40             	add    $0x40,%eax
80104dee:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104df5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfb:	83 c0 40             	add    $0x40,%eax
80104dfe:	c1 e0 04             	shl    $0x4,%eax
80104e01:	05 20 69 19 80       	add    $0x80196920,%eax
80104e06:	8b 00                	mov    (%eax),%eax
80104e08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0e:	83 e8 80             	sub    $0xffffff80,%eax
80104e11:	c1 e0 04             	shl    $0x4,%eax
80104e14:	05 20 69 19 80       	add    $0x80196920,%eax
80104e19:	8b 00                	mov    (%eax),%eax
80104e1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e21:	83 e8 80             	sub    $0xffffff80,%eax
80104e24:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
80104e2b:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e32:	83 e8 80             	sub    $0xffffff80,%eax
80104e35:	c1 e0 04             	shl    $0x4,%eax
80104e38:	05 20 69 19 80       	add    $0x80196920,%eax
80104e3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104e43:	ff 75 e4             	push   -0x1c(%ebp)
80104e46:	ff 75 e0             	push   -0x20(%ebp)
80104e49:	ff 75 e8             	push   -0x18(%ebp)
80104e4c:	68 7c b3 10 80       	push   $0x8010b37c
80104e51:	e8 b6 b5 ff ff       	call   8010040c <cprintf>
80104e56:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5c:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104e5f:	83 c0 30             	add    $0x30,%eax
80104e62:	05 20 75 19 80       	add    $0x80197520,%eax
80104e67:	83 c0 04             	add    $0x4,%eax
80104e6a:	83 ec 08             	sub    $0x8,%esp
80104e6d:	6a 01                	push   $0x1
80104e6f:	50                   	push   %eax
80104e70:	e8 ee fc ff ff       	call   80104b63 <enqueue>
80104e75:	83 c4 10             	add    $0x10,%esp
80104e78:	eb 01                	jmp    80104e7b <apply_priority_boosting+0x1ec>
    if (!kernel_pstat.inuse[i]) continue;
80104e7a:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104e7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e7f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104e83:	0f 8e 1c fe ff ff    	jle    80104ca5 <apply_priority_boosting+0x16>
    }
  }
}
80104e89:	90                   	nop
80104e8a:	90                   	nop
80104e8b:	c9                   	leave
80104e8c:	c3                   	ret

80104e8d <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104e8d:	f3 0f 1e fb          	endbr32
80104e91:	55                   	push   %ebp
80104e92:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104e94:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104e98:	75 07                	jne    80104ea1 <get_time_slice+0x14>
80104e9a:	b8 08 00 00 00       	mov    $0x8,%eax
80104e9f:	eb 1f                	jmp    80104ec0 <get_time_slice+0x33>
  if (level == 2) return 16;
80104ea1:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104ea5:	75 07                	jne    80104eae <get_time_slice+0x21>
80104ea7:	b8 10 00 00 00       	mov    $0x10,%eax
80104eac:	eb 12                	jmp    80104ec0 <get_time_slice+0x33>
  if (level == 1) return 32;
80104eae:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104eb2:	75 07                	jne    80104ebb <get_time_slice+0x2e>
80104eb4:	b8 20 00 00 00       	mov    $0x20,%eax
80104eb9:	eb 05                	jmp    80104ec0 <get_time_slice+0x33>
  return -1; // FIFO (Q0)
80104ebb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec0:	5d                   	pop    %ebp
80104ec1:	c3                   	ret

80104ec2 <run_process>:

void run_process(struct proc* p, int q, int slice) {
80104ec2:	f3 0f 1e fb          	endbr32
80104ec6:	55                   	push   %ebp
80104ec7:	89 e5                	mov    %esp,%ebp
80104ec9:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104ecc:	e8 5c ec ff ff       	call   80103b2d <mycpu>
80104ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	8b 55 08             	mov    0x8(%ebp),%edx
80104eda:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104ee0:	83 ec 0c             	sub    $0xc,%esp
80104ee3:	ff 75 08             	push   0x8(%ebp)
80104ee6:	e8 7b 33 00 00       	call   80108266 <switchuvm>
80104eeb:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104eee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

  int i = p - ptable.proc;
80104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80104efb:	2d 54 75 19 80       	sub    $0x80197554,%eax
80104f00:	c1 f8 02             	sar    $0x2,%eax
80104f03:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104f09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  cprintf("[RUN_PROCESS] PID %d starts at Q%d ticks %d wait_ticks %d\n", p->pid, q,kernel_pstat.ticks[i][q], kernel_pstat.wait_ticks[i][q]);
80104f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f16:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f19:	01 d0                	add    %edx,%eax
80104f1b:	05 00 02 00 00       	add    $0x200,%eax
80104f20:	8b 0c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ecx
80104f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f31:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f34:	01 d0                	add    %edx,%eax
80104f36:	05 00 01 00 00       	add    $0x100,%eax
80104f3b:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104f42:	8b 45 08             	mov    0x8(%ebp),%eax
80104f45:	8b 40 10             	mov    0x10(%eax),%eax
80104f48:	83 ec 0c             	sub    $0xc,%esp
80104f4b:	51                   	push   %ecx
80104f4c:	52                   	push   %edx
80104f4d:	ff 75 0c             	push   0xc(%ebp)
80104f50:	50                   	push   %eax
80104f51:	68 ac b3 10 80       	push   $0x8010b3ac
80104f56:	e8 b1 b4 ff ff       	call   8010040c <cprintf>
80104f5b:	83 c4 20             	add    $0x20,%esp

  // 실제 프로세스를 실행 (문맥 전환)
  swtch(&(c->scheduler), p->context);
80104f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f61:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f67:	83 c2 04             	add    $0x4,%edx
80104f6a:	83 ec 08             	sub    $0x8,%esp
80104f6d:	50                   	push   %eax
80104f6e:	52                   	push   %edx
80104f6f:	e8 de 08 00 00       	call   80105852 <swtch>
80104f74:	83 c4 10             	add    $0x10,%esp
  // 유저 공간에서 실행이 끝나고 다시 돌아옴
  switchkvm();
80104f77:	e8 cd 32 00 00       	call   80108249 <switchkvm>
  c->proc = 0;
80104f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104f86:	00 00 00 

  int executed = kernel_pstat.ticks[i][q];
80104f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f93:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f96:	01 d0                	add    %edx,%eax
80104f98:	05 00 01 00 00       	add    $0x100,%eax
80104f9d:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104fa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  //cprintf("[CHECK] PID %d total ticks at Q%d = %d (slice = %d)\n", p->pid, q, executed, slice);

  if (slice != -1 && executed >= slice && q > 0) {
80104fa7:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104fab:	74 75                	je     80105022 <run_process+0x160>
80104fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fb0:	3b 45 10             	cmp    0x10(%ebp),%eax
80104fb3:	7c 6d                	jl     80105022 <run_process+0x160>
80104fb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fb9:	7e 67                	jle    80105022 <run_process+0x160>
    kernel_pstat.priority[i] = q - 1;
80104fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fbe:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc4:	83 e8 80             	sub    $0xffffff80,%eax
80104fc7:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;  // 현재 큐에서의 실행 시간 초기화
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdb:	01 d0                	add    %edx,%eax
80104fdd:	05 00 01 00 00       	add    $0x100,%eax
80104fe2:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80104fe9:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80104fed:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff6:	8b 40 10             	mov    0x10(%eax),%eax
80104ff9:	52                   	push   %edx
80104ffa:	ff 75 0c             	push   0xc(%ebp)
80104ffd:	50                   	push   %eax
80104ffe:	68 e7 b3 10 80       	push   $0x8010b3e7
80105003:	e8 04 b4 ff ff       	call   8010040c <cprintf>
80105008:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
8010500b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500e:	83 e8 01             	sub    $0x1,%eax
80105011:	83 ec 08             	sub    $0x8,%esp
80105014:	50                   	push   %eax
80105015:	ff 75 08             	push   0x8(%ebp)
80105018:	e8 46 fb ff ff       	call   80104b63 <enqueue>
8010501d:	83 c4 10             	add    $0x10,%esp
  } else {
    // 타임슬라이스 소진 안 했거나 Q0가 아닌 경우는 재삽입
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
80105020:	eb 31                	jmp    80105053 <run_process+0x191>
  } else if (q == 0) {
80105022:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105026:	74 2b                	je     80105053 <run_process+0x191>
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
80105028:	8b 45 08             	mov    0x8(%ebp),%eax
8010502b:	8b 40 10             	mov    0x10(%eax),%eax
8010502e:	83 ec 04             	sub    $0x4,%esp
80105031:	ff 75 0c             	push   0xc(%ebp)
80105034:	50                   	push   %eax
80105035:	68 04 b4 10 80       	push   $0x8010b404
8010503a:	e8 cd b3 ff ff       	call   8010040c <cprintf>
8010503f:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
80105042:	83 ec 08             	sub    $0x8,%esp
80105045:	ff 75 0c             	push   0xc(%ebp)
80105048:	ff 75 08             	push   0x8(%ebp)
8010504b:	e8 13 fb ff ff       	call   80104b63 <enqueue>
80105050:	83 c4 10             	add    $0x10,%esp
}
80105053:	90                   	nop
80105054:	c9                   	leave
80105055:	c3                   	ret

80105056 <run_mlfq>:


// MLFQ 스케줄러 진입점
void run_mlfq(void) {
80105056:	f3 0f 1e fb          	endbr32
8010505a:	55                   	push   %ebp
8010505b:	89 e5                	mov    %esp,%ebp
8010505d:	83 ec 28             	sub    $0x28,%esp
  
  apply_priority_boosting();
80105060:	e8 2a fc ff ff       	call   80104c8f <apply_priority_boosting>
  
  for (int q = 3; q >= 0; q--) {
80105065:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
8010506c:	eb 7c                	jmp    801050ea <run_mlfq+0x94>
    for (int i = 0; i < NPROC; i++) {
8010506e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105075:	eb 69                	jmp    801050e0 <run_mlfq+0x8a>
      struct proc *p = mlfq_queues[q][i];
80105077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507a:	c1 e0 06             	shl    $0x6,%eax
8010507d:	89 c2                	mov    %eax,%edx
8010507f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105082:	01 d0                	add    %edx,%eax
80105084:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
8010508b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      //cprintf("[MLFQ_LOOP] Q%d index %d: pid %d, state %d\n", q, i,
      //  p ? p->pid : -1, p ? p->state : -1);
      if (p == 0 || p->state != RUNNABLE)
8010508e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80105092:	74 0b                	je     8010509f <run_mlfq+0x49>
80105094:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105097:	8b 40 0c             	mov    0xc(%eax),%eax
8010509a:	83 f8 03             	cmp    $0x3,%eax
8010509d:	74 06                	je     801050a5 <run_mlfq+0x4f>
    for (int i = 0; i < NPROC; i++) {
8010509f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050a3:	eb 3b                	jmp    801050e0 <run_mlfq+0x8a>
        continue;
      
      // 실행할 프로세스는 dequeue
      if (q != 0)
801050a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050a9:	74 0e                	je     801050b9 <run_mlfq+0x63>
      {
        dequeue(q);
801050ab:	83 ec 0c             	sub    $0xc,%esp
801050ae:	ff 75 f4             	push   -0xc(%ebp)
801050b1:	e8 2c fb ff ff       	call   80104be2 <dequeue>
801050b6:	83 c4 10             	add    $0x10,%esp
      }
      int slice = get_time_slice(q);
801050b9:	83 ec 0c             	sub    $0xc,%esp
801050bc:	ff 75 f4             	push   -0xc(%ebp)
801050bf:	e8 c9 fd ff ff       	call   80104e8d <get_time_slice>
801050c4:	83 c4 10             	add    $0x10,%esp
801050c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice);
801050ca:	83 ec 04             	sub    $0x4,%esp
801050cd:	ff 75 e4             	push   -0x1c(%ebp)
801050d0:	ff 75 f4             	push   -0xc(%ebp)
801050d3:	ff 75 e8             	push   -0x18(%ebp)
801050d6:	e8 e7 fd ff ff       	call   80104ec2 <run_process>
801050db:	83 c4 10             	add    $0x10,%esp
      goto tick_update; // 한 번만 실행
801050de:	eb 15                	jmp    801050f5 <run_mlfq+0x9f>
    for (int i = 0; i < NPROC; i++) {
801050e0:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801050e4:	7e 91                	jle    80105077 <run_mlfq+0x21>
  for (int q = 3; q >= 0; q--) {
801050e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801050ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050ee:	0f 89 7a ff ff ff    	jns    8010506e <run_mlfq+0x18>
    }
  }

tick_update:
801050f4:	90                   	nop
  // wait tick 증가 (실행 안 된 RUNNABLE 프로세스만)
  for (int i = 0; i < NPROC; i++) {
801050f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801050fc:	e9 8d 00 00 00       	jmp    8010518e <run_mlfq+0x138>
    struct proc* p = &ptable.proc[i];
80105101:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105104:	6b c0 7c             	imul   $0x7c,%eax,%eax
80105107:	83 c0 30             	add    $0x30,%eax
8010510a:	05 20 75 19 80       	add    $0x80197520,%eax
8010510f:	83 c0 04             	add    $0x4,%eax
80105112:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80105115:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105118:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
8010511f:	85 c0                	test   %eax,%eax
80105121:	74 66                	je     80105189 <run_mlfq+0x133>
    int q = kernel_pstat.priority[i];    
80105123:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105126:	83 e8 80             	sub    $0xffffff80,%eax
80105129:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105130:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (p->state == RUNNABLE && p != mycpu()->proc) {
80105133:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105136:	8b 40 0c             	mov    0xc(%eax),%eax
80105139:	83 f8 03             	cmp    $0x3,%eax
8010513c:	75 4c                	jne    8010518a <run_mlfq+0x134>
8010513e:	e8 ea e9 ff ff       	call   80103b2d <mycpu>
80105143:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105149:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010514c:	74 3c                	je     8010518a <run_mlfq+0x134>
      kernel_pstat.wait_ticks[i][q]++;
8010514e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105151:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105158:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010515b:	01 d0                	add    %edx,%eax
8010515d:	05 00 02 00 00       	add    $0x200,%eax
80105162:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105169:	8d 50 01             	lea    0x1(%eax),%edx
8010516c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010516f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80105176:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105179:	01 c8                	add    %ecx,%eax
8010517b:	05 00 02 00 00       	add    $0x200,%eax
80105180:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
80105187:	eb 01                	jmp    8010518a <run_mlfq+0x134>
    if (!kernel_pstat.inuse[i]) continue;
80105189:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
8010518a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010518e:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80105192:	0f 8e 69 ff ff ff    	jle    80105101 <run_mlfq+0xab>
    }
  }
}
80105198:	90                   	nop
80105199:	90                   	nop
8010519a:	c9                   	leave
8010519b:	c3                   	ret

8010519c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010519c:	f3 0f 1e fb          	endbr32
801051a0:	55                   	push   %ebp
801051a1:	89 e5                	mov    %esp,%ebp
801051a3:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801051a6:	8b 45 08             	mov    0x8(%ebp),%eax
801051a9:	83 c0 04             	add    $0x4,%eax
801051ac:	83 ec 08             	sub    $0x8,%esp
801051af:	68 50 b4 10 80       	push   $0x8010b450
801051b4:	50                   	push   %eax
801051b5:	e8 4f 01 00 00       	call   80105309 <initlock>
801051ba:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801051bd:	8b 45 08             	mov    0x8(%ebp),%eax
801051c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801051c3:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801051c6:	8b 45 08             	mov    0x8(%ebp),%eax
801051c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051cf:	8b 45 08             	mov    0x8(%ebp),%eax
801051d2:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801051d9:	90                   	nop
801051da:	c9                   	leave
801051db:	c3                   	ret

801051dc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801051dc:	f3 0f 1e fb          	endbr32
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051e6:	8b 45 08             	mov    0x8(%ebp),%eax
801051e9:	83 c0 04             	add    $0x4,%eax
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	50                   	push   %eax
801051f0:	e8 3a 01 00 00       	call   8010532f <acquire>
801051f5:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051f8:	eb 15                	jmp    8010520f <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801051fa:	8b 45 08             	mov    0x8(%ebp),%eax
801051fd:	83 c0 04             	add    $0x4,%eax
80105200:	83 ec 08             	sub    $0x8,%esp
80105203:	50                   	push   %eax
80105204:	ff 75 08             	push   0x8(%ebp)
80105207:	e8 5d f4 ff ff       	call   80104669 <sleep>
8010520c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	8b 00                	mov    (%eax),%eax
80105214:	85 c0                	test   %eax,%eax
80105216:	75 e2                	jne    801051fa <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105218:	8b 45 08             	mov    0x8(%ebp),%eax
8010521b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105221:	e8 83 e9 ff ff       	call   80103ba9 <myproc>
80105226:	8b 50 10             	mov    0x10(%eax),%edx
80105229:	8b 45 08             	mov    0x8(%ebp),%eax
8010522c:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010522f:	8b 45 08             	mov    0x8(%ebp),%eax
80105232:	83 c0 04             	add    $0x4,%eax
80105235:	83 ec 0c             	sub    $0xc,%esp
80105238:	50                   	push   %eax
80105239:	e8 63 01 00 00       	call   801053a1 <release>
8010523e:	83 c4 10             	add    $0x10,%esp
}
80105241:	90                   	nop
80105242:	c9                   	leave
80105243:	c3                   	ret

80105244 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105244:	f3 0f 1e fb          	endbr32
80105248:	55                   	push   %ebp
80105249:	89 e5                	mov    %esp,%ebp
8010524b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010524e:	8b 45 08             	mov    0x8(%ebp),%eax
80105251:	83 c0 04             	add    $0x4,%eax
80105254:	83 ec 0c             	sub    $0xc,%esp
80105257:	50                   	push   %eax
80105258:	e8 d2 00 00 00       	call   8010532f <acquire>
8010525d:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105260:	8b 45 08             	mov    0x8(%ebp),%eax
80105263:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105269:	8b 45 08             	mov    0x8(%ebp),%eax
8010526c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105273:	83 ec 0c             	sub    $0xc,%esp
80105276:	ff 75 08             	push   0x8(%ebp)
80105279:	e8 da f4 ff ff       	call   80104758 <wakeup>
8010527e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105281:	8b 45 08             	mov    0x8(%ebp),%eax
80105284:	83 c0 04             	add    $0x4,%eax
80105287:	83 ec 0c             	sub    $0xc,%esp
8010528a:	50                   	push   %eax
8010528b:	e8 11 01 00 00       	call   801053a1 <release>
80105290:	83 c4 10             	add    $0x10,%esp
}
80105293:	90                   	nop
80105294:	c9                   	leave
80105295:	c3                   	ret

80105296 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105296:	f3 0f 1e fb          	endbr32
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801052a0:	8b 45 08             	mov    0x8(%ebp),%eax
801052a3:	83 c0 04             	add    $0x4,%eax
801052a6:	83 ec 0c             	sub    $0xc,%esp
801052a9:	50                   	push   %eax
801052aa:	e8 80 00 00 00       	call   8010532f <acquire>
801052af:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801052b2:	8b 45 08             	mov    0x8(%ebp),%eax
801052b5:	8b 00                	mov    (%eax),%eax
801052b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801052ba:	8b 45 08             	mov    0x8(%ebp),%eax
801052bd:	83 c0 04             	add    $0x4,%eax
801052c0:	83 ec 0c             	sub    $0xc,%esp
801052c3:	50                   	push   %eax
801052c4:	e8 d8 00 00 00       	call   801053a1 <release>
801052c9:	83 c4 10             	add    $0x10,%esp
  return r;
801052cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052cf:	c9                   	leave
801052d0:	c3                   	ret

801052d1 <readeflags>:
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052d7:	9c                   	pushf
801052d8:	58                   	pop    %eax
801052d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052df:	c9                   	leave
801052e0:	c3                   	ret

801052e1 <cli>:
{
801052e1:	55                   	push   %ebp
801052e2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052e4:	fa                   	cli
}
801052e5:	90                   	nop
801052e6:	5d                   	pop    %ebp
801052e7:	c3                   	ret

801052e8 <sti>:
{
801052e8:	55                   	push   %ebp
801052e9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052eb:	fb                   	sti
}
801052ec:	90                   	nop
801052ed:	5d                   	pop    %ebp
801052ee:	c3                   	ret

801052ef <xchg>:
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052f5:	8b 55 08             	mov    0x8(%ebp),%edx
801052f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052fe:	f0 87 02             	lock xchg %eax,(%edx)
80105301:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105307:	c9                   	leave
80105308:	c3                   	ret

80105309 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105309:	f3 0f 1e fb          	endbr32
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105310:	8b 45 08             	mov    0x8(%ebp),%eax
80105313:	8b 55 0c             	mov    0xc(%ebp),%edx
80105316:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105322:	8b 45 08             	mov    0x8(%ebp),%eax
80105325:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010532c:	90                   	nop
8010532d:	5d                   	pop    %ebp
8010532e:	c3                   	ret

8010532f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010532f:	f3 0f 1e fb          	endbr32
80105333:	55                   	push   %ebp
80105334:	89 e5                	mov    %esp,%ebp
80105336:	53                   	push   %ebx
80105337:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010533a:	e8 6c 01 00 00       	call   801054ab <pushcli>
  if(holding(lk)){
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	83 ec 0c             	sub    $0xc,%esp
80105345:	50                   	push   %eax
80105346:	e8 2b 01 00 00       	call   80105476 <holding>
8010534b:	83 c4 10             	add    $0x10,%esp
8010534e:	85 c0                	test   %eax,%eax
80105350:	74 0d                	je     8010535f <acquire+0x30>
    panic("acquire");
80105352:	83 ec 0c             	sub    $0xc,%esp
80105355:	68 5b b4 10 80       	push   $0x8010b45b
8010535a:	e8 66 b2 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010535f:	90                   	nop
80105360:	8b 45 08             	mov    0x8(%ebp),%eax
80105363:	83 ec 08             	sub    $0x8,%esp
80105366:	6a 01                	push   $0x1
80105368:	50                   	push   %eax
80105369:	e8 81 ff ff ff       	call   801052ef <xchg>
8010536e:	83 c4 10             	add    $0x10,%esp
80105371:	85 c0                	test   %eax,%eax
80105373:	75 eb                	jne    80105360 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105375:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010537a:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010537d:	e8 ab e7 ff ff       	call   80103b2d <mycpu>
80105382:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105385:	8b 45 08             	mov    0x8(%ebp),%eax
80105388:	83 c0 0c             	add    $0xc,%eax
8010538b:	83 ec 08             	sub    $0x8,%esp
8010538e:	50                   	push   %eax
8010538f:	8d 45 08             	lea    0x8(%ebp),%eax
80105392:	50                   	push   %eax
80105393:	e8 5f 00 00 00       	call   801053f7 <getcallerpcs>
80105398:	83 c4 10             	add    $0x10,%esp
}
8010539b:	90                   	nop
8010539c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010539f:	c9                   	leave
801053a0:	c3                   	ret

801053a1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053a1:	f3 0f 1e fb          	endbr32
801053a5:	55                   	push   %ebp
801053a6:	89 e5                	mov    %esp,%ebp
801053a8:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801053ab:	83 ec 0c             	sub    $0xc,%esp
801053ae:	ff 75 08             	push   0x8(%ebp)
801053b1:	e8 c0 00 00 00       	call   80105476 <holding>
801053b6:	83 c4 10             	add    $0x10,%esp
801053b9:	85 c0                	test   %eax,%eax
801053bb:	75 0d                	jne    801053ca <release+0x29>
    panic("release");
801053bd:	83 ec 0c             	sub    $0xc,%esp
801053c0:	68 63 b4 10 80       	push   $0x8010b463
801053c5:	e8 fb b1 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
801053ca:	8b 45 08             	mov    0x8(%ebp),%eax
801053cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053d4:	8b 45 08             	mov    0x8(%ebp),%eax
801053d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053de:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801053e3:	8b 45 08             	mov    0x8(%ebp),%eax
801053e6:	8b 55 08             	mov    0x8(%ebp),%edx
801053e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053ef:	e8 08 01 00 00       	call   801054fc <popcli>
}
801053f4:	90                   	nop
801053f5:	c9                   	leave
801053f6:	c3                   	ret

801053f7 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053f7:	f3 0f 1e fb          	endbr32
801053fb:	55                   	push   %ebp
801053fc:	89 e5                	mov    %esp,%ebp
801053fe:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
80105404:	83 e8 08             	sub    $0x8,%eax
80105407:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010540a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105411:	eb 38                	jmp    8010544b <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105413:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105417:	74 53                	je     8010546c <getcallerpcs+0x75>
80105419:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105420:	76 4a                	jbe    8010546c <getcallerpcs+0x75>
80105422:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105426:	74 44                	je     8010546c <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105428:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010542b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105432:	8b 45 0c             	mov    0xc(%ebp),%eax
80105435:	01 c2                	add    %eax,%edx
80105437:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543a:	8b 40 04             	mov    0x4(%eax),%eax
8010543d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010543f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105442:	8b 00                	mov    (%eax),%eax
80105444:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105447:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010544b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010544f:	7e c2                	jle    80105413 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105451:	eb 19                	jmp    8010546c <getcallerpcs+0x75>
    pcs[i] = 0;
80105453:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105456:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010545d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105460:	01 d0                	add    %edx,%eax
80105462:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105468:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010546c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105470:	7e e1                	jle    80105453 <getcallerpcs+0x5c>
}
80105472:	90                   	nop
80105473:	90                   	nop
80105474:	c9                   	leave
80105475:	c3                   	ret

80105476 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105476:	f3 0f 1e fb          	endbr32
8010547a:	55                   	push   %ebp
8010547b:	89 e5                	mov    %esp,%ebp
8010547d:	53                   	push   %ebx
8010547e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105481:	8b 45 08             	mov    0x8(%ebp),%eax
80105484:	8b 00                	mov    (%eax),%eax
80105486:	85 c0                	test   %eax,%eax
80105488:	74 16                	je     801054a0 <holding+0x2a>
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	8b 58 08             	mov    0x8(%eax),%ebx
80105490:	e8 98 e6 ff ff       	call   80103b2d <mycpu>
80105495:	39 c3                	cmp    %eax,%ebx
80105497:	75 07                	jne    801054a0 <holding+0x2a>
80105499:	b8 01 00 00 00       	mov    $0x1,%eax
8010549e:	eb 05                	jmp    801054a5 <holding+0x2f>
801054a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054a5:	83 c4 04             	add    $0x4,%esp
801054a8:	5b                   	pop    %ebx
801054a9:	5d                   	pop    %ebp
801054aa:	c3                   	ret

801054ab <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054ab:	f3 0f 1e fb          	endbr32
801054af:	55                   	push   %ebp
801054b0:	89 e5                	mov    %esp,%ebp
801054b2:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054b5:	e8 17 fe ff ff       	call   801052d1 <readeflags>
801054ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801054bd:	e8 1f fe ff ff       	call   801052e1 <cli>
  if(mycpu()->ncli == 0)
801054c2:	e8 66 e6 ff ff       	call   80103b2d <mycpu>
801054c7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054cd:	85 c0                	test   %eax,%eax
801054cf:	75 14                	jne    801054e5 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801054d1:	e8 57 e6 ff ff       	call   80103b2d <mycpu>
801054d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054d9:	81 e2 00 02 00 00    	and    $0x200,%edx
801054df:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054e5:	e8 43 e6 ff ff       	call   80103b2d <mycpu>
801054ea:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054f0:	83 c2 01             	add    $0x1,%edx
801054f3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054f9:	90                   	nop
801054fa:	c9                   	leave
801054fb:	c3                   	ret

801054fc <popcli>:

void
popcli(void)
{
801054fc:	f3 0f 1e fb          	endbr32
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
80105503:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105506:	e8 c6 fd ff ff       	call   801052d1 <readeflags>
8010550b:	25 00 02 00 00       	and    $0x200,%eax
80105510:	85 c0                	test   %eax,%eax
80105512:	74 0d                	je     80105521 <popcli+0x25>
    panic("popcli - interruptible");
80105514:	83 ec 0c             	sub    $0xc,%esp
80105517:	68 6b b4 10 80       	push   $0x8010b46b
8010551c:	e8 a4 b0 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80105521:	e8 07 e6 ff ff       	call   80103b2d <mycpu>
80105526:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010552c:	83 ea 01             	sub    $0x1,%edx
8010552f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105535:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010553b:	85 c0                	test   %eax,%eax
8010553d:	79 0d                	jns    8010554c <popcli+0x50>
    panic("popcli");
8010553f:	83 ec 0c             	sub    $0xc,%esp
80105542:	68 82 b4 10 80       	push   $0x8010b482
80105547:	e8 79 b0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010554c:	e8 dc e5 ff ff       	call   80103b2d <mycpu>
80105551:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105557:	85 c0                	test   %eax,%eax
80105559:	75 14                	jne    8010556f <popcli+0x73>
8010555b:	e8 cd e5 ff ff       	call   80103b2d <mycpu>
80105560:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105566:	85 c0                	test   %eax,%eax
80105568:	74 05                	je     8010556f <popcli+0x73>
    sti();
8010556a:	e8 79 fd ff ff       	call   801052e8 <sti>
}
8010556f:	90                   	nop
80105570:	c9                   	leave
80105571:	c3                   	ret

80105572 <stosb>:
{
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
80105575:	57                   	push   %edi
80105576:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105577:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010557a:	8b 55 10             	mov    0x10(%ebp),%edx
8010557d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105580:	89 cb                	mov    %ecx,%ebx
80105582:	89 df                	mov    %ebx,%edi
80105584:	89 d1                	mov    %edx,%ecx
80105586:	fc                   	cld
80105587:	f3 aa                	rep stos %al,%es:(%edi)
80105589:	89 ca                	mov    %ecx,%edx
8010558b:	89 fb                	mov    %edi,%ebx
8010558d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105590:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105593:	90                   	nop
80105594:	5b                   	pop    %ebx
80105595:	5f                   	pop    %edi
80105596:	5d                   	pop    %ebp
80105597:	c3                   	ret

80105598 <stosl>:
{
80105598:	55                   	push   %ebp
80105599:	89 e5                	mov    %esp,%ebp
8010559b:	57                   	push   %edi
8010559c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010559d:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055a0:	8b 55 10             	mov    0x10(%ebp),%edx
801055a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a6:	89 cb                	mov    %ecx,%ebx
801055a8:	89 df                	mov    %ebx,%edi
801055aa:	89 d1                	mov    %edx,%ecx
801055ac:	fc                   	cld
801055ad:	f3 ab                	rep stos %eax,%es:(%edi)
801055af:	89 ca                	mov    %ecx,%edx
801055b1:	89 fb                	mov    %edi,%ebx
801055b3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055b6:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055b9:	90                   	nop
801055ba:	5b                   	pop    %ebx
801055bb:	5f                   	pop    %edi
801055bc:	5d                   	pop    %ebp
801055bd:	c3                   	ret

801055be <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055be:	f3 0f 1e fb          	endbr32
801055c2:	55                   	push   %ebp
801055c3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801055c5:	8b 45 08             	mov    0x8(%ebp),%eax
801055c8:	83 e0 03             	and    $0x3,%eax
801055cb:	85 c0                	test   %eax,%eax
801055cd:	75 43                	jne    80105612 <memset+0x54>
801055cf:	8b 45 10             	mov    0x10(%ebp),%eax
801055d2:	83 e0 03             	and    $0x3,%eax
801055d5:	85 c0                	test   %eax,%eax
801055d7:	75 39                	jne    80105612 <memset+0x54>
    c &= 0xFF;
801055d9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055e0:	8b 45 10             	mov    0x10(%ebp),%eax
801055e3:	c1 e8 02             	shr    $0x2,%eax
801055e6:	89 c1                	mov    %eax,%ecx
801055e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055eb:	c1 e0 18             	shl    $0x18,%eax
801055ee:	89 c2                	mov    %eax,%edx
801055f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f3:	c1 e0 10             	shl    $0x10,%eax
801055f6:	09 c2                	or     %eax,%edx
801055f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055fb:	c1 e0 08             	shl    $0x8,%eax
801055fe:	09 d0                	or     %edx,%eax
80105600:	0b 45 0c             	or     0xc(%ebp),%eax
80105603:	51                   	push   %ecx
80105604:	50                   	push   %eax
80105605:	ff 75 08             	push   0x8(%ebp)
80105608:	e8 8b ff ff ff       	call   80105598 <stosl>
8010560d:	83 c4 0c             	add    $0xc,%esp
80105610:	eb 12                	jmp    80105624 <memset+0x66>
  } else
    stosb(dst, c, n);
80105612:	8b 45 10             	mov    0x10(%ebp),%eax
80105615:	50                   	push   %eax
80105616:	ff 75 0c             	push   0xc(%ebp)
80105619:	ff 75 08             	push   0x8(%ebp)
8010561c:	e8 51 ff ff ff       	call   80105572 <stosb>
80105621:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105624:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105627:	c9                   	leave
80105628:	c3                   	ret

80105629 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105629:	f3 0f 1e fb          	endbr32
8010562d:	55                   	push   %ebp
8010562e:	89 e5                	mov    %esp,%ebp
80105630:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105633:	8b 45 08             	mov    0x8(%ebp),%eax
80105636:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010563f:	eb 30                	jmp    80105671 <memcmp+0x48>
    if(*s1 != *s2)
80105641:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105644:	0f b6 10             	movzbl (%eax),%edx
80105647:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010564a:	0f b6 00             	movzbl (%eax),%eax
8010564d:	38 c2                	cmp    %al,%dl
8010564f:	74 18                	je     80105669 <memcmp+0x40>
      return *s1 - *s2;
80105651:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105654:	0f b6 00             	movzbl (%eax),%eax
80105657:	0f b6 d0             	movzbl %al,%edx
8010565a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565d:	0f b6 00             	movzbl (%eax),%eax
80105660:	0f b6 c0             	movzbl %al,%eax
80105663:	29 c2                	sub    %eax,%edx
80105665:	89 d0                	mov    %edx,%eax
80105667:	eb 1a                	jmp    80105683 <memcmp+0x5a>
    s1++, s2++;
80105669:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010566d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105671:	8b 45 10             	mov    0x10(%ebp),%eax
80105674:	8d 50 ff             	lea    -0x1(%eax),%edx
80105677:	89 55 10             	mov    %edx,0x10(%ebp)
8010567a:	85 c0                	test   %eax,%eax
8010567c:	75 c3                	jne    80105641 <memcmp+0x18>
  }

  return 0;
8010567e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105683:	c9                   	leave
80105684:	c3                   	ret

80105685 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105685:	f3 0f 1e fb          	endbr32
80105689:	55                   	push   %ebp
8010568a:	89 e5                	mov    %esp,%ebp
8010568c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010568f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105692:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105695:	8b 45 08             	mov    0x8(%ebp),%eax
80105698:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010569b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056a1:	73 54                	jae    801056f7 <memmove+0x72>
801056a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056a6:	8b 45 10             	mov    0x10(%ebp),%eax
801056a9:	01 d0                	add    %edx,%eax
801056ab:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801056ae:	73 47                	jae    801056f7 <memmove+0x72>
    s += n;
801056b0:	8b 45 10             	mov    0x10(%ebp),%eax
801056b3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056b6:	8b 45 10             	mov    0x10(%ebp),%eax
801056b9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056bc:	eb 13                	jmp    801056d1 <memmove+0x4c>
      *--d = *--s;
801056be:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056c2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c9:	0f b6 10             	movzbl (%eax),%edx
801056cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056cf:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056d1:	8b 45 10             	mov    0x10(%ebp),%eax
801056d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801056d7:	89 55 10             	mov    %edx,0x10(%ebp)
801056da:	85 c0                	test   %eax,%eax
801056dc:	75 e0                	jne    801056be <memmove+0x39>
  if(s < d && s + n > d){
801056de:	eb 24                	jmp    80105704 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056e3:	8d 42 01             	lea    0x1(%edx),%eax
801056e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056ec:	8d 48 01             	lea    0x1(%eax),%ecx
801056ef:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056f2:	0f b6 12             	movzbl (%edx),%edx
801056f5:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056f7:	8b 45 10             	mov    0x10(%ebp),%eax
801056fa:	8d 50 ff             	lea    -0x1(%eax),%edx
801056fd:	89 55 10             	mov    %edx,0x10(%ebp)
80105700:	85 c0                	test   %eax,%eax
80105702:	75 dc                	jne    801056e0 <memmove+0x5b>

  return dst;
80105704:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105707:	c9                   	leave
80105708:	c3                   	ret

80105709 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105709:	f3 0f 1e fb          	endbr32
8010570d:	55                   	push   %ebp
8010570e:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105710:	ff 75 10             	push   0x10(%ebp)
80105713:	ff 75 0c             	push   0xc(%ebp)
80105716:	ff 75 08             	push   0x8(%ebp)
80105719:	e8 67 ff ff ff       	call   80105685 <memmove>
8010571e:	83 c4 0c             	add    $0xc,%esp
}
80105721:	c9                   	leave
80105722:	c3                   	ret

80105723 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105723:	f3 0f 1e fb          	endbr32
80105727:	55                   	push   %ebp
80105728:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010572a:	eb 0c                	jmp    80105738 <strncmp+0x15>
    n--, p++, q++;
8010572c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105730:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105734:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105738:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010573c:	74 1a                	je     80105758 <strncmp+0x35>
8010573e:	8b 45 08             	mov    0x8(%ebp),%eax
80105741:	0f b6 00             	movzbl (%eax),%eax
80105744:	84 c0                	test   %al,%al
80105746:	74 10                	je     80105758 <strncmp+0x35>
80105748:	8b 45 08             	mov    0x8(%ebp),%eax
8010574b:	0f b6 10             	movzbl (%eax),%edx
8010574e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105751:	0f b6 00             	movzbl (%eax),%eax
80105754:	38 c2                	cmp    %al,%dl
80105756:	74 d4                	je     8010572c <strncmp+0x9>
  if(n == 0)
80105758:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010575c:	75 07                	jne    80105765 <strncmp+0x42>
    return 0;
8010575e:	b8 00 00 00 00       	mov    $0x0,%eax
80105763:	eb 16                	jmp    8010577b <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105765:	8b 45 08             	mov    0x8(%ebp),%eax
80105768:	0f b6 00             	movzbl (%eax),%eax
8010576b:	0f b6 d0             	movzbl %al,%edx
8010576e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105771:	0f b6 00             	movzbl (%eax),%eax
80105774:	0f b6 c0             	movzbl %al,%eax
80105777:	29 c2                	sub    %eax,%edx
80105779:	89 d0                	mov    %edx,%eax
}
8010577b:	5d                   	pop    %ebp
8010577c:	c3                   	ret

8010577d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010577d:	f3 0f 1e fb          	endbr32
80105781:	55                   	push   %ebp
80105782:	89 e5                	mov    %esp,%ebp
80105784:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105787:	8b 45 08             	mov    0x8(%ebp),%eax
8010578a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010578d:	90                   	nop
8010578e:	8b 45 10             	mov    0x10(%ebp),%eax
80105791:	8d 50 ff             	lea    -0x1(%eax),%edx
80105794:	89 55 10             	mov    %edx,0x10(%ebp)
80105797:	85 c0                	test   %eax,%eax
80105799:	7e 2c                	jle    801057c7 <strncpy+0x4a>
8010579b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010579e:	8d 42 01             	lea    0x1(%edx),%eax
801057a1:	89 45 0c             	mov    %eax,0xc(%ebp)
801057a4:	8b 45 08             	mov    0x8(%ebp),%eax
801057a7:	8d 48 01             	lea    0x1(%eax),%ecx
801057aa:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057ad:	0f b6 12             	movzbl (%edx),%edx
801057b0:	88 10                	mov    %dl,(%eax)
801057b2:	0f b6 00             	movzbl (%eax),%eax
801057b5:	84 c0                	test   %al,%al
801057b7:	75 d5                	jne    8010578e <strncpy+0x11>
    ;
  while(n-- > 0)
801057b9:	eb 0c                	jmp    801057c7 <strncpy+0x4a>
    *s++ = 0;
801057bb:	8b 45 08             	mov    0x8(%ebp),%eax
801057be:	8d 50 01             	lea    0x1(%eax),%edx
801057c1:	89 55 08             	mov    %edx,0x8(%ebp)
801057c4:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801057c7:	8b 45 10             	mov    0x10(%ebp),%eax
801057ca:	8d 50 ff             	lea    -0x1(%eax),%edx
801057cd:	89 55 10             	mov    %edx,0x10(%ebp)
801057d0:	85 c0                	test   %eax,%eax
801057d2:	7f e7                	jg     801057bb <strncpy+0x3e>
  return os;
801057d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057d7:	c9                   	leave
801057d8:	c3                   	ret

801057d9 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057d9:	f3 0f 1e fb          	endbr32
801057dd:	55                   	push   %ebp
801057de:	89 e5                	mov    %esp,%ebp
801057e0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057e3:	8b 45 08             	mov    0x8(%ebp),%eax
801057e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057ed:	7f 05                	jg     801057f4 <safestrcpy+0x1b>
    return os;
801057ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f2:	eb 31                	jmp    80105825 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057fc:	7e 1e                	jle    8010581c <safestrcpy+0x43>
801057fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80105801:	8d 42 01             	lea    0x1(%edx),%eax
80105804:	89 45 0c             	mov    %eax,0xc(%ebp)
80105807:	8b 45 08             	mov    0x8(%ebp),%eax
8010580a:	8d 48 01             	lea    0x1(%eax),%ecx
8010580d:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105810:	0f b6 12             	movzbl (%edx),%edx
80105813:	88 10                	mov    %dl,(%eax)
80105815:	0f b6 00             	movzbl (%eax),%eax
80105818:	84 c0                	test   %al,%al
8010581a:	75 d8                	jne    801057f4 <safestrcpy+0x1b>
    ;
  *s = 0;
8010581c:	8b 45 08             	mov    0x8(%ebp),%eax
8010581f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105822:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105825:	c9                   	leave
80105826:	c3                   	ret

80105827 <strlen>:

int
strlen(const char *s)
{
80105827:	f3 0f 1e fb          	endbr32
8010582b:	55                   	push   %ebp
8010582c:	89 e5                	mov    %esp,%ebp
8010582e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105831:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105838:	eb 04                	jmp    8010583e <strlen+0x17>
8010583a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010583e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105841:	8b 45 08             	mov    0x8(%ebp),%eax
80105844:	01 d0                	add    %edx,%eax
80105846:	0f b6 00             	movzbl (%eax),%eax
80105849:	84 c0                	test   %al,%al
8010584b:	75 ed                	jne    8010583a <strlen+0x13>
    ;
  return n;
8010584d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105850:	c9                   	leave
80105851:	c3                   	ret

80105852 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105852:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105856:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010585a:	55                   	push   %ebp
  pushl %ebx
8010585b:	53                   	push   %ebx
  pushl %esi
8010585c:	56                   	push   %esi
  pushl %edi
8010585d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010585e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105860:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105862:	5f                   	pop    %edi
  popl %esi
80105863:	5e                   	pop    %esi
  popl %ebx
80105864:	5b                   	pop    %ebx
  popl %ebp
80105865:	5d                   	pop    %ebp
  ret
80105866:	c3                   	ret

80105867 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105867:	f3 0f 1e fb          	endbr32
8010586b:	55                   	push   %ebp
8010586c:	89 e5                	mov    %esp,%ebp
8010586e:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105871:	e8 33 e3 ff ff       	call   80103ba9 <myproc>
80105876:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587c:	8b 00                	mov    (%eax),%eax
8010587e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105881:	73 0f                	jae    80105892 <fetchint+0x2b>
80105883:	8b 45 08             	mov    0x8(%ebp),%eax
80105886:	8d 50 04             	lea    0x4(%eax),%edx
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	8b 00                	mov    (%eax),%eax
8010588e:	39 c2                	cmp    %eax,%edx
80105890:	76 07                	jbe    80105899 <fetchint+0x32>
    return -1;
80105892:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105897:	eb 0f                	jmp    801058a8 <fetchint+0x41>
  *ip = *(int*)(addr);
80105899:	8b 45 08             	mov    0x8(%ebp),%eax
8010589c:	8b 10                	mov    (%eax),%edx
8010589e:	8b 45 0c             	mov    0xc(%ebp),%eax
801058a1:	89 10                	mov    %edx,(%eax)
  return 0;
801058a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058a8:	c9                   	leave
801058a9:	c3                   	ret

801058aa <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058aa:	f3 0f 1e fb          	endbr32
801058ae:	55                   	push   %ebp
801058af:	89 e5                	mov    %esp,%ebp
801058b1:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801058b4:	e8 f0 e2 ff ff       	call   80103ba9 <myproc>
801058b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801058bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bf:	8b 00                	mov    (%eax),%eax
801058c1:	39 45 08             	cmp    %eax,0x8(%ebp)
801058c4:	72 07                	jb     801058cd <fetchstr+0x23>
    return -1;
801058c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058cb:	eb 43                	jmp    80105910 <fetchstr+0x66>
  *pp = (char*)addr;
801058cd:	8b 55 08             	mov    0x8(%ebp),%edx
801058d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d3:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d8:	8b 00                	mov    (%eax),%eax
801058da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e0:	8b 00                	mov    (%eax),%eax
801058e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e5:	eb 1c                	jmp    80105903 <fetchstr+0x59>
    if(*s == 0)
801058e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ea:	0f b6 00             	movzbl (%eax),%eax
801058ed:	84 c0                	test   %al,%al
801058ef:	75 0e                	jne    801058ff <fetchstr+0x55>
      return s - *pp;
801058f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f4:	8b 00                	mov    (%eax),%eax
801058f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058f9:	29 c2                	sub    %eax,%edx
801058fb:	89 d0                	mov    %edx,%eax
801058fd:	eb 11                	jmp    80105910 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105906:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105909:	72 dc                	jb     801058e7 <fetchstr+0x3d>
  }
  return -1;
8010590b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105910:	c9                   	leave
80105911:	c3                   	ret

80105912 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105912:	f3 0f 1e fb          	endbr32
80105916:	55                   	push   %ebp
80105917:	89 e5                	mov    %esp,%ebp
80105919:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010591c:	e8 88 e2 ff ff       	call   80103ba9 <myproc>
80105921:	8b 40 18             	mov    0x18(%eax),%eax
80105924:	8b 40 44             	mov    0x44(%eax),%eax
80105927:	8b 55 08             	mov    0x8(%ebp),%edx
8010592a:	c1 e2 02             	shl    $0x2,%edx
8010592d:	01 d0                	add    %edx,%eax
8010592f:	83 c0 04             	add    $0x4,%eax
80105932:	83 ec 08             	sub    $0x8,%esp
80105935:	ff 75 0c             	push   0xc(%ebp)
80105938:	50                   	push   %eax
80105939:	e8 29 ff ff ff       	call   80105867 <fetchint>
8010593e:	83 c4 10             	add    $0x10,%esp
}
80105941:	c9                   	leave
80105942:	c3                   	ret

80105943 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105943:	f3 0f 1e fb          	endbr32
80105947:	55                   	push   %ebp
80105948:	89 e5                	mov    %esp,%ebp
8010594a:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010594d:	e8 57 e2 ff ff       	call   80103ba9 <myproc>
80105952:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105955:	83 ec 08             	sub    $0x8,%esp
80105958:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595b:	50                   	push   %eax
8010595c:	ff 75 08             	push   0x8(%ebp)
8010595f:	e8 ae ff ff ff       	call   80105912 <argint>
80105964:	83 c4 10             	add    $0x10,%esp
80105967:	85 c0                	test   %eax,%eax
80105969:	79 07                	jns    80105972 <argptr+0x2f>
    return -1;
8010596b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105970:	eb 3b                	jmp    801059ad <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105972:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105976:	78 1f                	js     80105997 <argptr+0x54>
80105978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597b:	8b 00                	mov    (%eax),%eax
8010597d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105980:	39 d0                	cmp    %edx,%eax
80105982:	76 13                	jbe    80105997 <argptr+0x54>
80105984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105987:	89 c2                	mov    %eax,%edx
80105989:	8b 45 10             	mov    0x10(%ebp),%eax
8010598c:	01 c2                	add    %eax,%edx
8010598e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105991:	8b 00                	mov    (%eax),%eax
80105993:	39 c2                	cmp    %eax,%edx
80105995:	76 07                	jbe    8010599e <argptr+0x5b>
    return -1;
80105997:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599c:	eb 0f                	jmp    801059ad <argptr+0x6a>
  *pp = (char*)i;
8010599e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a1:	89 c2                	mov    %eax,%edx
801059a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801059a6:	89 10                	mov    %edx,(%eax)
  return 0;
801059a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059ad:	c9                   	leave
801059ae:	c3                   	ret

801059af <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059af:	f3 0f 1e fb          	endbr32
801059b3:	55                   	push   %ebp
801059b4:	89 e5                	mov    %esp,%ebp
801059b6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059b9:	83 ec 08             	sub    $0x8,%esp
801059bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	ff 75 08             	push   0x8(%ebp)
801059c3:	e8 4a ff ff ff       	call   80105912 <argint>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	85 c0                	test   %eax,%eax
801059cd:	79 07                	jns    801059d6 <argstr+0x27>
    return -1;
801059cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d4:	eb 12                	jmp    801059e8 <argstr+0x39>
  return fetchstr(addr, pp);
801059d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d9:	83 ec 08             	sub    $0x8,%esp
801059dc:	ff 75 0c             	push   0xc(%ebp)
801059df:	50                   	push   %eax
801059e0:	e8 c5 fe ff ff       	call   801058aa <fetchstr>
801059e5:	83 c4 10             	add    $0x10,%esp
}
801059e8:	c9                   	leave
801059e9:	c3                   	ret

801059ea <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
801059ea:	f3 0f 1e fb          	endbr32
801059ee:	55                   	push   %ebp
801059ef:	89 e5                	mov    %esp,%ebp
801059f1:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059f4:	e8 b0 e1 ff ff       	call   80103ba9 <myproc>
801059f9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ff:	8b 40 18             	mov    0x18(%eax),%eax
80105a02:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a0c:	7e 2f                	jle    80105a3d <syscall+0x53>
80105a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a11:	83 f8 19             	cmp    $0x19,%eax
80105a14:	77 27                	ja     80105a3d <syscall+0x53>
80105a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a19:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a20:	85 c0                	test   %eax,%eax
80105a22:	74 19                	je     80105a3d <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a27:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a2e:	ff d0                	call   *%eax
80105a30:	89 c2                	mov    %eax,%edx
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a35:	8b 40 18             	mov    0x18(%eax),%eax
80105a38:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a3b:	eb 2c                	jmp    80105a69 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a46:	8b 40 10             	mov    0x10(%eax),%eax
80105a49:	ff 75 f0             	push   -0x10(%ebp)
80105a4c:	52                   	push   %edx
80105a4d:	50                   	push   %eax
80105a4e:	68 89 b4 10 80       	push   $0x8010b489
80105a53:	e8 b4 a9 ff ff       	call   8010040c <cprintf>
80105a58:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5e:	8b 40 18             	mov    0x18(%eax),%eax
80105a61:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a68:	90                   	nop
80105a69:	90                   	nop
80105a6a:	c9                   	leave
80105a6b:	c3                   	ret

80105a6c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a6c:	f3 0f 1e fb          	endbr32
80105a70:	55                   	push   %ebp
80105a71:	89 e5                	mov    %esp,%ebp
80105a73:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a76:	83 ec 08             	sub    $0x8,%esp
80105a79:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a7c:	50                   	push   %eax
80105a7d:	ff 75 08             	push   0x8(%ebp)
80105a80:	e8 8d fe ff ff       	call   80105912 <argint>
80105a85:	83 c4 10             	add    $0x10,%esp
80105a88:	85 c0                	test   %eax,%eax
80105a8a:	79 07                	jns    80105a93 <argfd+0x27>
    return -1;
80105a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a91:	eb 4f                	jmp    80105ae2 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a96:	85 c0                	test   %eax,%eax
80105a98:	78 20                	js     80105aba <argfd+0x4e>
80105a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9d:	83 f8 0f             	cmp    $0xf,%eax
80105aa0:	7f 18                	jg     80105aba <argfd+0x4e>
80105aa2:	e8 02 e1 ff ff       	call   80103ba9 <myproc>
80105aa7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aaa:	83 c2 08             	add    $0x8,%edx
80105aad:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ab4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab8:	75 07                	jne    80105ac1 <argfd+0x55>
    return -1;
80105aba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abf:	eb 21                	jmp    80105ae2 <argfd+0x76>
  if(pfd)
80105ac1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ac5:	74 08                	je     80105acf <argfd+0x63>
    *pfd = fd;
80105ac7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80105acd:	89 10                	mov    %edx,(%eax)
  if(pf)
80105acf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ad3:	74 08                	je     80105add <argfd+0x71>
    *pf = f;
80105ad5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105adb:	89 10                	mov    %edx,(%eax)
  return 0;
80105add:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ae2:	c9                   	leave
80105ae3:	c3                   	ret

80105ae4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ae4:	f3 0f 1e fb          	endbr32
80105ae8:	55                   	push   %ebp
80105ae9:	89 e5                	mov    %esp,%ebp
80105aeb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105aee:	e8 b6 e0 ff ff       	call   80103ba9 <myproc>
80105af3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105afd:	eb 2a                	jmp    80105b29 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b05:	83 c2 08             	add    $0x8,%edx
80105b08:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b0c:	85 c0                	test   %eax,%eax
80105b0e:	75 15                	jne    80105b25 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b16:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b19:	8b 55 08             	mov    0x8(%ebp),%edx
80105b1c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b23:	eb 0f                	jmp    80105b34 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b29:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b2d:	7e d0                	jle    80105aff <fdalloc+0x1b>
    }
  }
  return -1;
80105b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b34:	c9                   	leave
80105b35:	c3                   	ret

80105b36 <sys_dup>:

int
sys_dup(void)
{
80105b36:	f3 0f 1e fb          	endbr32
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
80105b3d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b40:	83 ec 04             	sub    $0x4,%esp
80105b43:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b46:	50                   	push   %eax
80105b47:	6a 00                	push   $0x0
80105b49:	6a 00                	push   $0x0
80105b4b:	e8 1c ff ff ff       	call   80105a6c <argfd>
80105b50:	83 c4 10             	add    $0x10,%esp
80105b53:	85 c0                	test   %eax,%eax
80105b55:	79 07                	jns    80105b5e <sys_dup+0x28>
    return -1;
80105b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5c:	eb 31                	jmp    80105b8f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b61:	83 ec 0c             	sub    $0xc,%esp
80105b64:	50                   	push   %eax
80105b65:	e8 7a ff ff ff       	call   80105ae4 <fdalloc>
80105b6a:	83 c4 10             	add    $0x10,%esp
80105b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b74:	79 07                	jns    80105b7d <sys_dup+0x47>
    return -1;
80105b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7b:	eb 12                	jmp    80105b8f <sys_dup+0x59>
  filedup(f);
80105b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b80:	83 ec 0c             	sub    $0xc,%esp
80105b83:	50                   	push   %eax
80105b84:	e8 0b b5 ff ff       	call   80101094 <filedup>
80105b89:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b8f:	c9                   	leave
80105b90:	c3                   	ret

80105b91 <sys_read>:

int
sys_read(void)
{
80105b91:	f3 0f 1e fb          	endbr32
80105b95:	55                   	push   %ebp
80105b96:	89 e5                	mov    %esp,%ebp
80105b98:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b9b:	83 ec 04             	sub    $0x4,%esp
80105b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba1:	50                   	push   %eax
80105ba2:	6a 00                	push   $0x0
80105ba4:	6a 00                	push   $0x0
80105ba6:	e8 c1 fe ff ff       	call   80105a6c <argfd>
80105bab:	83 c4 10             	add    $0x10,%esp
80105bae:	85 c0                	test   %eax,%eax
80105bb0:	78 2e                	js     80105be0 <sys_read+0x4f>
80105bb2:	83 ec 08             	sub    $0x8,%esp
80105bb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb8:	50                   	push   %eax
80105bb9:	6a 02                	push   $0x2
80105bbb:	e8 52 fd ff ff       	call   80105912 <argint>
80105bc0:	83 c4 10             	add    $0x10,%esp
80105bc3:	85 c0                	test   %eax,%eax
80105bc5:	78 19                	js     80105be0 <sys_read+0x4f>
80105bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bca:	83 ec 04             	sub    $0x4,%esp
80105bcd:	50                   	push   %eax
80105bce:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bd1:	50                   	push   %eax
80105bd2:	6a 01                	push   $0x1
80105bd4:	e8 6a fd ff ff       	call   80105943 <argptr>
80105bd9:	83 c4 10             	add    $0x10,%esp
80105bdc:	85 c0                	test   %eax,%eax
80105bde:	79 07                	jns    80105be7 <sys_read+0x56>
    return -1;
80105be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be5:	eb 17                	jmp    80105bfe <sys_read+0x6d>
  return fileread(f, p, n);
80105be7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bea:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	83 ec 04             	sub    $0x4,%esp
80105bf3:	51                   	push   %ecx
80105bf4:	52                   	push   %edx
80105bf5:	50                   	push   %eax
80105bf6:	e8 35 b6 ff ff       	call   80101230 <fileread>
80105bfb:	83 c4 10             	add    $0x10,%esp
}
80105bfe:	c9                   	leave
80105bff:	c3                   	ret

80105c00 <sys_write>:

int
sys_write(void)
{
80105c00:	f3 0f 1e fb          	endbr32
80105c04:	55                   	push   %ebp
80105c05:	89 e5                	mov    %esp,%ebp
80105c07:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c0a:	83 ec 04             	sub    $0x4,%esp
80105c0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c10:	50                   	push   %eax
80105c11:	6a 00                	push   $0x0
80105c13:	6a 00                	push   $0x0
80105c15:	e8 52 fe ff ff       	call   80105a6c <argfd>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	78 2e                	js     80105c4f <sys_write+0x4f>
80105c21:	83 ec 08             	sub    $0x8,%esp
80105c24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c27:	50                   	push   %eax
80105c28:	6a 02                	push   $0x2
80105c2a:	e8 e3 fc ff ff       	call   80105912 <argint>
80105c2f:	83 c4 10             	add    $0x10,%esp
80105c32:	85 c0                	test   %eax,%eax
80105c34:	78 19                	js     80105c4f <sys_write+0x4f>
80105c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c39:	83 ec 04             	sub    $0x4,%esp
80105c3c:	50                   	push   %eax
80105c3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c40:	50                   	push   %eax
80105c41:	6a 01                	push   $0x1
80105c43:	e8 fb fc ff ff       	call   80105943 <argptr>
80105c48:	83 c4 10             	add    $0x10,%esp
80105c4b:	85 c0                	test   %eax,%eax
80105c4d:	79 07                	jns    80105c56 <sys_write+0x56>
    return -1;
80105c4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c54:	eb 17                	jmp    80105c6d <sys_write+0x6d>
  return filewrite(f, p, n);
80105c56:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c59:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5f:	83 ec 04             	sub    $0x4,%esp
80105c62:	51                   	push   %ecx
80105c63:	52                   	push   %edx
80105c64:	50                   	push   %eax
80105c65:	e8 82 b6 ff ff       	call   801012ec <filewrite>
80105c6a:	83 c4 10             	add    $0x10,%esp
}
80105c6d:	c9                   	leave
80105c6e:	c3                   	ret

80105c6f <sys_close>:

int
sys_close(void)
{
80105c6f:	f3 0f 1e fb          	endbr32
80105c73:	55                   	push   %ebp
80105c74:	89 e5                	mov    %esp,%ebp
80105c76:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c79:	83 ec 04             	sub    $0x4,%esp
80105c7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c7f:	50                   	push   %eax
80105c80:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c83:	50                   	push   %eax
80105c84:	6a 00                	push   $0x0
80105c86:	e8 e1 fd ff ff       	call   80105a6c <argfd>
80105c8b:	83 c4 10             	add    $0x10,%esp
80105c8e:	85 c0                	test   %eax,%eax
80105c90:	79 07                	jns    80105c99 <sys_close+0x2a>
    return -1;
80105c92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c97:	eb 27                	jmp    80105cc0 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c99:	e8 0b df ff ff       	call   80103ba9 <myproc>
80105c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ca1:	83 c2 08             	add    $0x8,%edx
80105ca4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cab:	00 
  fileclose(f);
80105cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caf:	83 ec 0c             	sub    $0xc,%esp
80105cb2:	50                   	push   %eax
80105cb3:	e8 31 b4 ff ff       	call   801010e9 <fileclose>
80105cb8:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc0:	c9                   	leave
80105cc1:	c3                   	ret

80105cc2 <sys_fstat>:

int
sys_fstat(void)
{
80105cc2:	f3 0f 1e fb          	endbr32
80105cc6:	55                   	push   %ebp
80105cc7:	89 e5                	mov    %esp,%ebp
80105cc9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105ccc:	83 ec 04             	sub    $0x4,%esp
80105ccf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cd2:	50                   	push   %eax
80105cd3:	6a 00                	push   $0x0
80105cd5:	6a 00                	push   $0x0
80105cd7:	e8 90 fd ff ff       	call   80105a6c <argfd>
80105cdc:	83 c4 10             	add    $0x10,%esp
80105cdf:	85 c0                	test   %eax,%eax
80105ce1:	78 17                	js     80105cfa <sys_fstat+0x38>
80105ce3:	83 ec 04             	sub    $0x4,%esp
80105ce6:	6a 14                	push   $0x14
80105ce8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ceb:	50                   	push   %eax
80105cec:	6a 01                	push   $0x1
80105cee:	e8 50 fc ff ff       	call   80105943 <argptr>
80105cf3:	83 c4 10             	add    $0x10,%esp
80105cf6:	85 c0                	test   %eax,%eax
80105cf8:	79 07                	jns    80105d01 <sys_fstat+0x3f>
    return -1;
80105cfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cff:	eb 13                	jmp    80105d14 <sys_fstat+0x52>
  return filestat(f, st);
80105d01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d07:	83 ec 08             	sub    $0x8,%esp
80105d0a:	52                   	push   %edx
80105d0b:	50                   	push   %eax
80105d0c:	e8 c4 b4 ff ff       	call   801011d5 <filestat>
80105d11:	83 c4 10             	add    $0x10,%esp
}
80105d14:	c9                   	leave
80105d15:	c3                   	ret

80105d16 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d16:	f3 0f 1e fb          	endbr32
80105d1a:	55                   	push   %ebp
80105d1b:	89 e5                	mov    %esp,%ebp
80105d1d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d20:	83 ec 08             	sub    $0x8,%esp
80105d23:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d26:	50                   	push   %eax
80105d27:	6a 00                	push   $0x0
80105d29:	e8 81 fc ff ff       	call   801059af <argstr>
80105d2e:	83 c4 10             	add    $0x10,%esp
80105d31:	85 c0                	test   %eax,%eax
80105d33:	78 15                	js     80105d4a <sys_link+0x34>
80105d35:	83 ec 08             	sub    $0x8,%esp
80105d38:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d3b:	50                   	push   %eax
80105d3c:	6a 01                	push   $0x1
80105d3e:	e8 6c fc ff ff       	call   801059af <argstr>
80105d43:	83 c4 10             	add    $0x10,%esp
80105d46:	85 c0                	test   %eax,%eax
80105d48:	79 0a                	jns    80105d54 <sys_link+0x3e>
    return -1;
80105d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4f:	e9 68 01 00 00       	jmp    80105ebc <sys_link+0x1a6>

  begin_op();
80105d54:	e8 18 d4 ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105d59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d5c:	83 ec 0c             	sub    $0xc,%esp
80105d5f:	50                   	push   %eax
80105d60:	e8 82 c8 ff ff       	call   801025e7 <namei>
80105d65:	83 c4 10             	add    $0x10,%esp
80105d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d6f:	75 0f                	jne    80105d80 <sys_link+0x6a>
    end_op();
80105d71:	e8 8b d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7b:	e9 3c 01 00 00       	jmp    80105ebc <sys_link+0x1a6>
  }

  ilock(ip);
80105d80:	83 ec 0c             	sub    $0xc,%esp
80105d83:	ff 75 f4             	push   -0xc(%ebp)
80105d86:	e8 f1 bc ff ff       	call   80101a7c <ilock>
80105d8b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d95:	66 83 f8 01          	cmp    $0x1,%ax
80105d99:	75 1d                	jne    80105db8 <sys_link+0xa2>
    iunlockput(ip);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	ff 75 f4             	push   -0xc(%ebp)
80105da1:	e8 13 bf ff ff       	call   80101cb9 <iunlockput>
80105da6:	83 c4 10             	add    $0x10,%esp
    end_op();
80105da9:	e8 53 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db3:	e9 04 01 00 00       	jmp    80105ebc <sys_link+0x1a6>
  }

  ip->nlink++;
80105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dbf:	83 c0 01             	add    $0x1,%eax
80105dc2:	89 c2                	mov    %eax,%edx
80105dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105dcb:	83 ec 0c             	sub    $0xc,%esp
80105dce:	ff 75 f4             	push   -0xc(%ebp)
80105dd1:	e8 bd ba ff ff       	call   80101893 <iupdate>
80105dd6:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105dd9:	83 ec 0c             	sub    $0xc,%esp
80105ddc:	ff 75 f4             	push   -0xc(%ebp)
80105ddf:	e8 af bd ff ff       	call   80101b93 <iunlock>
80105de4:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105de7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105dea:	83 ec 08             	sub    $0x8,%esp
80105ded:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105df0:	52                   	push   %edx
80105df1:	50                   	push   %eax
80105df2:	e8 10 c8 ff ff       	call   80102607 <nameiparent>
80105df7:	83 c4 10             	add    $0x10,%esp
80105dfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dfd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e01:	74 71                	je     80105e74 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105e03:	83 ec 0c             	sub    $0xc,%esp
80105e06:	ff 75 f0             	push   -0x10(%ebp)
80105e09:	e8 6e bc ff ff       	call   80101a7c <ilock>
80105e0e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e14:	8b 10                	mov    (%eax),%edx
80105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e19:	8b 00                	mov    (%eax),%eax
80105e1b:	39 c2                	cmp    %eax,%edx
80105e1d:	75 1d                	jne    80105e3c <sys_link+0x126>
80105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e22:	8b 40 04             	mov    0x4(%eax),%eax
80105e25:	83 ec 04             	sub    $0x4,%esp
80105e28:	50                   	push   %eax
80105e29:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e2c:	50                   	push   %eax
80105e2d:	ff 75 f0             	push   -0x10(%ebp)
80105e30:	e8 0f c5 ff ff       	call   80102344 <dirlink>
80105e35:	83 c4 10             	add    $0x10,%esp
80105e38:	85 c0                	test   %eax,%eax
80105e3a:	79 10                	jns    80105e4c <sys_link+0x136>
    iunlockput(dp);
80105e3c:	83 ec 0c             	sub    $0xc,%esp
80105e3f:	ff 75 f0             	push   -0x10(%ebp)
80105e42:	e8 72 be ff ff       	call   80101cb9 <iunlockput>
80105e47:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e4a:	eb 29                	jmp    80105e75 <sys_link+0x15f>
  }
  iunlockput(dp);
80105e4c:	83 ec 0c             	sub    $0xc,%esp
80105e4f:	ff 75 f0             	push   -0x10(%ebp)
80105e52:	e8 62 be ff ff       	call   80101cb9 <iunlockput>
80105e57:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e5a:	83 ec 0c             	sub    $0xc,%esp
80105e5d:	ff 75 f4             	push   -0xc(%ebp)
80105e60:	e8 80 bd ff ff       	call   80101be5 <iput>
80105e65:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e68:	e8 94 d3 ff ff       	call   80103201 <end_op>

  return 0;
80105e6d:	b8 00 00 00 00       	mov    $0x0,%eax
80105e72:	eb 48                	jmp    80105ebc <sys_link+0x1a6>
    goto bad;
80105e74:	90                   	nop

bad:
  ilock(ip);
80105e75:	83 ec 0c             	sub    $0xc,%esp
80105e78:	ff 75 f4             	push   -0xc(%ebp)
80105e7b:	e8 fc bb ff ff       	call   80101a7c <ilock>
80105e80:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e86:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e8a:	83 e8 01             	sub    $0x1,%eax
80105e8d:	89 c2                	mov    %eax,%edx
80105e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e92:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e96:	83 ec 0c             	sub    $0xc,%esp
80105e99:	ff 75 f4             	push   -0xc(%ebp)
80105e9c:	e8 f2 b9 ff ff       	call   80101893 <iupdate>
80105ea1:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ea4:	83 ec 0c             	sub    $0xc,%esp
80105ea7:	ff 75 f4             	push   -0xc(%ebp)
80105eaa:	e8 0a be ff ff       	call   80101cb9 <iunlockput>
80105eaf:	83 c4 10             	add    $0x10,%esp
  end_op();
80105eb2:	e8 4a d3 ff ff       	call   80103201 <end_op>
  return -1;
80105eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ebc:	c9                   	leave
80105ebd:	c3                   	ret

80105ebe <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ebe:	f3 0f 1e fb          	endbr32
80105ec2:	55                   	push   %ebp
80105ec3:	89 e5                	mov    %esp,%ebp
80105ec5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ec8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ecf:	eb 40                	jmp    80105f11 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	6a 10                	push   $0x10
80105ed6:	50                   	push   %eax
80105ed7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105eda:	50                   	push   %eax
80105edb:	ff 75 08             	push   0x8(%ebp)
80105ede:	e8 a1 c0 ff ff       	call   80101f84 <readi>
80105ee3:	83 c4 10             	add    $0x10,%esp
80105ee6:	83 f8 10             	cmp    $0x10,%eax
80105ee9:	74 0d                	je     80105ef8 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105eeb:	83 ec 0c             	sub    $0xc,%esp
80105eee:	68 a5 b4 10 80       	push   $0x8010b4a5
80105ef3:	e8 cd a6 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105ef8:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105efc:	66 85 c0             	test   %ax,%ax
80105eff:	74 07                	je     80105f08 <isdirempty+0x4a>
      return 0;
80105f01:	b8 00 00 00 00       	mov    $0x0,%eax
80105f06:	eb 1b                	jmp    80105f23 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0b:	83 c0 10             	add    $0x10,%eax
80105f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f11:	8b 45 08             	mov    0x8(%ebp),%eax
80105f14:	8b 50 58             	mov    0x58(%eax),%edx
80105f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1a:	39 c2                	cmp    %eax,%edx
80105f1c:	77 b3                	ja     80105ed1 <isdirempty+0x13>
  }
  return 1;
80105f1e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f23:	c9                   	leave
80105f24:	c3                   	ret

80105f25 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f25:	f3 0f 1e fb          	endbr32
80105f29:	55                   	push   %ebp
80105f2a:	89 e5                	mov    %esp,%ebp
80105f2c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f2f:	83 ec 08             	sub    $0x8,%esp
80105f32:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f35:	50                   	push   %eax
80105f36:	6a 00                	push   $0x0
80105f38:	e8 72 fa ff ff       	call   801059af <argstr>
80105f3d:	83 c4 10             	add    $0x10,%esp
80105f40:	85 c0                	test   %eax,%eax
80105f42:	79 0a                	jns    80105f4e <sys_unlink+0x29>
    return -1;
80105f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f49:	e9 bf 01 00 00       	jmp    8010610d <sys_unlink+0x1e8>

  begin_op();
80105f4e:	e8 1e d2 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f53:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f56:	83 ec 08             	sub    $0x8,%esp
80105f59:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f5c:	52                   	push   %edx
80105f5d:	50                   	push   %eax
80105f5e:	e8 a4 c6 ff ff       	call   80102607 <nameiparent>
80105f63:	83 c4 10             	add    $0x10,%esp
80105f66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f6d:	75 0f                	jne    80105f7e <sys_unlink+0x59>
    end_op();
80105f6f:	e8 8d d2 ff ff       	call   80103201 <end_op>
    return -1;
80105f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f79:	e9 8f 01 00 00       	jmp    8010610d <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f7e:	83 ec 0c             	sub    $0xc,%esp
80105f81:	ff 75 f4             	push   -0xc(%ebp)
80105f84:	e8 f3 ba ff ff       	call   80101a7c <ilock>
80105f89:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f8c:	83 ec 08             	sub    $0x8,%esp
80105f8f:	68 b7 b4 10 80       	push   $0x8010b4b7
80105f94:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f97:	50                   	push   %eax
80105f98:	e8 ca c2 ff ff       	call   80102267 <namecmp>
80105f9d:	83 c4 10             	add    $0x10,%esp
80105fa0:	85 c0                	test   %eax,%eax
80105fa2:	0f 84 49 01 00 00    	je     801060f1 <sys_unlink+0x1cc>
80105fa8:	83 ec 08             	sub    $0x8,%esp
80105fab:	68 b9 b4 10 80       	push   $0x8010b4b9
80105fb0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fb3:	50                   	push   %eax
80105fb4:	e8 ae c2 ff ff       	call   80102267 <namecmp>
80105fb9:	83 c4 10             	add    $0x10,%esp
80105fbc:	85 c0                	test   %eax,%eax
80105fbe:	0f 84 2d 01 00 00    	je     801060f1 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fc4:	83 ec 04             	sub    $0x4,%esp
80105fc7:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105fca:	50                   	push   %eax
80105fcb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fce:	50                   	push   %eax
80105fcf:	ff 75 f4             	push   -0xc(%ebp)
80105fd2:	e8 af c2 ff ff       	call   80102286 <dirlookup>
80105fd7:	83 c4 10             	add    $0x10,%esp
80105fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe1:	0f 84 0d 01 00 00    	je     801060f4 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fe7:	83 ec 0c             	sub    $0xc,%esp
80105fea:	ff 75 f0             	push   -0x10(%ebp)
80105fed:	e8 8a ba ff ff       	call   80101a7c <ilock>
80105ff2:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ffc:	66 85 c0             	test   %ax,%ax
80105fff:	7f 0d                	jg     8010600e <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80106001:	83 ec 0c             	sub    $0xc,%esp
80106004:	68 bc b4 10 80       	push   $0x8010b4bc
80106009:	e8 b7 a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010600e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106011:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106015:	66 83 f8 01          	cmp    $0x1,%ax
80106019:	75 25                	jne    80106040 <sys_unlink+0x11b>
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	ff 75 f0             	push   -0x10(%ebp)
80106021:	e8 98 fe ff ff       	call   80105ebe <isdirempty>
80106026:	83 c4 10             	add    $0x10,%esp
80106029:	85 c0                	test   %eax,%eax
8010602b:	75 13                	jne    80106040 <sys_unlink+0x11b>
    iunlockput(ip);
8010602d:	83 ec 0c             	sub    $0xc,%esp
80106030:	ff 75 f0             	push   -0x10(%ebp)
80106033:	e8 81 bc ff ff       	call   80101cb9 <iunlockput>
80106038:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010603b:	e9 b5 00 00 00       	jmp    801060f5 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106040:	83 ec 04             	sub    $0x4,%esp
80106043:	6a 10                	push   $0x10
80106045:	6a 00                	push   $0x0
80106047:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010604a:	50                   	push   %eax
8010604b:	e8 6e f5 ff ff       	call   801055be <memset>
80106050:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106053:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106056:	6a 10                	push   $0x10
80106058:	50                   	push   %eax
80106059:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010605c:	50                   	push   %eax
8010605d:	ff 75 f4             	push   -0xc(%ebp)
80106060:	e8 78 c0 ff ff       	call   801020dd <writei>
80106065:	83 c4 10             	add    $0x10,%esp
80106068:	83 f8 10             	cmp    $0x10,%eax
8010606b:	74 0d                	je     8010607a <sys_unlink+0x155>
    panic("unlink: writei");
8010606d:	83 ec 0c             	sub    $0xc,%esp
80106070:	68 ce b4 10 80       	push   $0x8010b4ce
80106075:	e8 4b a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
8010607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106081:	66 83 f8 01          	cmp    $0x1,%ax
80106085:	75 21                	jne    801060a8 <sys_unlink+0x183>
    dp->nlink--;
80106087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010608e:	83 e8 01             	sub    $0x1,%eax
80106091:	89 c2                	mov    %eax,%edx
80106093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106096:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010609a:	83 ec 0c             	sub    $0xc,%esp
8010609d:	ff 75 f4             	push   -0xc(%ebp)
801060a0:	e8 ee b7 ff ff       	call   80101893 <iupdate>
801060a5:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801060a8:	83 ec 0c             	sub    $0xc,%esp
801060ab:	ff 75 f4             	push   -0xc(%ebp)
801060ae:	e8 06 bc ff ff       	call   80101cb9 <iunlockput>
801060b3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801060b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060bd:	83 e8 01             	sub    $0x1,%eax
801060c0:	89 c2                	mov    %eax,%edx
801060c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801060c9:	83 ec 0c             	sub    $0xc,%esp
801060cc:	ff 75 f0             	push   -0x10(%ebp)
801060cf:	e8 bf b7 ff ff       	call   80101893 <iupdate>
801060d4:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060d7:	83 ec 0c             	sub    $0xc,%esp
801060da:	ff 75 f0             	push   -0x10(%ebp)
801060dd:	e8 d7 bb ff ff       	call   80101cb9 <iunlockput>
801060e2:	83 c4 10             	add    $0x10,%esp

  end_op();
801060e5:	e8 17 d1 ff ff       	call   80103201 <end_op>

  return 0;
801060ea:	b8 00 00 00 00       	mov    $0x0,%eax
801060ef:	eb 1c                	jmp    8010610d <sys_unlink+0x1e8>
    goto bad;
801060f1:	90                   	nop
801060f2:	eb 01                	jmp    801060f5 <sys_unlink+0x1d0>
    goto bad;
801060f4:	90                   	nop

bad:
  iunlockput(dp);
801060f5:	83 ec 0c             	sub    $0xc,%esp
801060f8:	ff 75 f4             	push   -0xc(%ebp)
801060fb:	e8 b9 bb ff ff       	call   80101cb9 <iunlockput>
80106100:	83 c4 10             	add    $0x10,%esp
  end_op();
80106103:	e8 f9 d0 ff ff       	call   80103201 <end_op>
  return -1;
80106108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010610d:	c9                   	leave
8010610e:	c3                   	ret

8010610f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010610f:	f3 0f 1e fb          	endbr32
80106113:	55                   	push   %ebp
80106114:	89 e5                	mov    %esp,%ebp
80106116:	83 ec 38             	sub    $0x38,%esp
80106119:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010611c:	8b 55 10             	mov    0x10(%ebp),%edx
8010611f:	8b 45 14             	mov    0x14(%ebp),%eax
80106122:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106126:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010612a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010612e:	83 ec 08             	sub    $0x8,%esp
80106131:	8d 45 de             	lea    -0x22(%ebp),%eax
80106134:	50                   	push   %eax
80106135:	ff 75 08             	push   0x8(%ebp)
80106138:	e8 ca c4 ff ff       	call   80102607 <nameiparent>
8010613d:	83 c4 10             	add    $0x10,%esp
80106140:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106143:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106147:	75 0a                	jne    80106153 <create+0x44>
    return 0;
80106149:	b8 00 00 00 00       	mov    $0x0,%eax
8010614e:	e9 90 01 00 00       	jmp    801062e3 <create+0x1d4>
  ilock(dp);
80106153:	83 ec 0c             	sub    $0xc,%esp
80106156:	ff 75 f4             	push   -0xc(%ebp)
80106159:	e8 1e b9 ff ff       	call   80101a7c <ilock>
8010615e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106161:	83 ec 04             	sub    $0x4,%esp
80106164:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106167:	50                   	push   %eax
80106168:	8d 45 de             	lea    -0x22(%ebp),%eax
8010616b:	50                   	push   %eax
8010616c:	ff 75 f4             	push   -0xc(%ebp)
8010616f:	e8 12 c1 ff ff       	call   80102286 <dirlookup>
80106174:	83 c4 10             	add    $0x10,%esp
80106177:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010617a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010617e:	74 50                	je     801061d0 <create+0xc1>
    iunlockput(dp);
80106180:	83 ec 0c             	sub    $0xc,%esp
80106183:	ff 75 f4             	push   -0xc(%ebp)
80106186:	e8 2e bb ff ff       	call   80101cb9 <iunlockput>
8010618b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010618e:	83 ec 0c             	sub    $0xc,%esp
80106191:	ff 75 f0             	push   -0x10(%ebp)
80106194:	e8 e3 b8 ff ff       	call   80101a7c <ilock>
80106199:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010619c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061a1:	75 15                	jne    801061b8 <create+0xa9>
801061a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061aa:	66 83 f8 02          	cmp    $0x2,%ax
801061ae:	75 08                	jne    801061b8 <create+0xa9>
      return ip;
801061b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b3:	e9 2b 01 00 00       	jmp    801062e3 <create+0x1d4>
    iunlockput(ip);
801061b8:	83 ec 0c             	sub    $0xc,%esp
801061bb:	ff 75 f0             	push   -0x10(%ebp)
801061be:	e8 f6 ba ff ff       	call   80101cb9 <iunlockput>
801061c3:	83 c4 10             	add    $0x10,%esp
    return 0;
801061c6:	b8 00 00 00 00       	mov    $0x0,%eax
801061cb:	e9 13 01 00 00       	jmp    801062e3 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061d0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d7:	8b 00                	mov    (%eax),%eax
801061d9:	83 ec 08             	sub    $0x8,%esp
801061dc:	52                   	push   %edx
801061dd:	50                   	push   %eax
801061de:	e8 d5 b5 ff ff       	call   801017b8 <ialloc>
801061e3:	83 c4 10             	add    $0x10,%esp
801061e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061ed:	75 0d                	jne    801061fc <create+0xed>
    panic("create: ialloc");
801061ef:	83 ec 0c             	sub    $0xc,%esp
801061f2:	68 dd b4 10 80       	push   $0x8010b4dd
801061f7:	e8 c9 a3 ff ff       	call   801005c5 <panic>

  ilock(ip);
801061fc:	83 ec 0c             	sub    $0xc,%esp
801061ff:	ff 75 f0             	push   -0x10(%ebp)
80106202:	e8 75 b8 ff ff       	call   80101a7c <ilock>
80106207:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106211:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106218:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010621c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106220:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106223:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106229:	83 ec 0c             	sub    $0xc,%esp
8010622c:	ff 75 f0             	push   -0x10(%ebp)
8010622f:	e8 5f b6 ff ff       	call   80101893 <iupdate>
80106234:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106237:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010623c:	75 6a                	jne    801062a8 <create+0x199>
    dp->nlink++;  // for ".."
8010623e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106241:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106245:	83 c0 01             	add    $0x1,%eax
80106248:	89 c2                	mov    %eax,%edx
8010624a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106251:	83 ec 0c             	sub    $0xc,%esp
80106254:	ff 75 f4             	push   -0xc(%ebp)
80106257:	e8 37 b6 ff ff       	call   80101893 <iupdate>
8010625c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106262:	8b 40 04             	mov    0x4(%eax),%eax
80106265:	83 ec 04             	sub    $0x4,%esp
80106268:	50                   	push   %eax
80106269:	68 b7 b4 10 80       	push   $0x8010b4b7
8010626e:	ff 75 f0             	push   -0x10(%ebp)
80106271:	e8 ce c0 ff ff       	call   80102344 <dirlink>
80106276:	83 c4 10             	add    $0x10,%esp
80106279:	85 c0                	test   %eax,%eax
8010627b:	78 1e                	js     8010629b <create+0x18c>
8010627d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106280:	8b 40 04             	mov    0x4(%eax),%eax
80106283:	83 ec 04             	sub    $0x4,%esp
80106286:	50                   	push   %eax
80106287:	68 b9 b4 10 80       	push   $0x8010b4b9
8010628c:	ff 75 f0             	push   -0x10(%ebp)
8010628f:	e8 b0 c0 ff ff       	call   80102344 <dirlink>
80106294:	83 c4 10             	add    $0x10,%esp
80106297:	85 c0                	test   %eax,%eax
80106299:	79 0d                	jns    801062a8 <create+0x199>
      panic("create dots");
8010629b:	83 ec 0c             	sub    $0xc,%esp
8010629e:	68 ec b4 10 80       	push   $0x8010b4ec
801062a3:	e8 1d a3 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ab:	8b 40 04             	mov    0x4(%eax),%eax
801062ae:	83 ec 04             	sub    $0x4,%esp
801062b1:	50                   	push   %eax
801062b2:	8d 45 de             	lea    -0x22(%ebp),%eax
801062b5:	50                   	push   %eax
801062b6:	ff 75 f4             	push   -0xc(%ebp)
801062b9:	e8 86 c0 ff ff       	call   80102344 <dirlink>
801062be:	83 c4 10             	add    $0x10,%esp
801062c1:	85 c0                	test   %eax,%eax
801062c3:	79 0d                	jns    801062d2 <create+0x1c3>
    panic("create: dirlink");
801062c5:	83 ec 0c             	sub    $0xc,%esp
801062c8:	68 f8 b4 10 80       	push   $0x8010b4f8
801062cd:	e8 f3 a2 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
801062d2:	83 ec 0c             	sub    $0xc,%esp
801062d5:	ff 75 f4             	push   -0xc(%ebp)
801062d8:	e8 dc b9 ff ff       	call   80101cb9 <iunlockput>
801062dd:	83 c4 10             	add    $0x10,%esp

  return ip;
801062e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062e3:	c9                   	leave
801062e4:	c3                   	ret

801062e5 <sys_open>:

int
sys_open(void)
{
801062e5:	f3 0f 1e fb          	endbr32
801062e9:	55                   	push   %ebp
801062ea:	89 e5                	mov    %esp,%ebp
801062ec:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062ef:	83 ec 08             	sub    $0x8,%esp
801062f2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062f5:	50                   	push   %eax
801062f6:	6a 00                	push   $0x0
801062f8:	e8 b2 f6 ff ff       	call   801059af <argstr>
801062fd:	83 c4 10             	add    $0x10,%esp
80106300:	85 c0                	test   %eax,%eax
80106302:	78 15                	js     80106319 <sys_open+0x34>
80106304:	83 ec 08             	sub    $0x8,%esp
80106307:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010630a:	50                   	push   %eax
8010630b:	6a 01                	push   $0x1
8010630d:	e8 00 f6 ff ff       	call   80105912 <argint>
80106312:	83 c4 10             	add    $0x10,%esp
80106315:	85 c0                	test   %eax,%eax
80106317:	79 0a                	jns    80106323 <sys_open+0x3e>
    return -1;
80106319:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631e:	e9 61 01 00 00       	jmp    80106484 <sys_open+0x19f>

  begin_op();
80106323:	e8 49 ce ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80106328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010632b:	25 00 02 00 00       	and    $0x200,%eax
80106330:	85 c0                	test   %eax,%eax
80106332:	74 2a                	je     8010635e <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106337:	6a 00                	push   $0x0
80106339:	6a 00                	push   $0x0
8010633b:	6a 02                	push   $0x2
8010633d:	50                   	push   %eax
8010633e:	e8 cc fd ff ff       	call   8010610f <create>
80106343:	83 c4 10             	add    $0x10,%esp
80106346:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106349:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010634d:	75 75                	jne    801063c4 <sys_open+0xdf>
      end_op();
8010634f:	e8 ad ce ff ff       	call   80103201 <end_op>
      return -1;
80106354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106359:	e9 26 01 00 00       	jmp    80106484 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
8010635e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106361:	83 ec 0c             	sub    $0xc,%esp
80106364:	50                   	push   %eax
80106365:	e8 7d c2 ff ff       	call   801025e7 <namei>
8010636a:	83 c4 10             	add    $0x10,%esp
8010636d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106370:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106374:	75 0f                	jne    80106385 <sys_open+0xa0>
      end_op();
80106376:	e8 86 ce ff ff       	call   80103201 <end_op>
      return -1;
8010637b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106380:	e9 ff 00 00 00       	jmp    80106484 <sys_open+0x19f>
    }
    ilock(ip);
80106385:	83 ec 0c             	sub    $0xc,%esp
80106388:	ff 75 f4             	push   -0xc(%ebp)
8010638b:	e8 ec b6 ff ff       	call   80101a7c <ilock>
80106390:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106396:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010639a:	66 83 f8 01          	cmp    $0x1,%ax
8010639e:	75 24                	jne    801063c4 <sys_open+0xdf>
801063a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063a3:	85 c0                	test   %eax,%eax
801063a5:	74 1d                	je     801063c4 <sys_open+0xdf>
      iunlockput(ip);
801063a7:	83 ec 0c             	sub    $0xc,%esp
801063aa:	ff 75 f4             	push   -0xc(%ebp)
801063ad:	e8 07 b9 ff ff       	call   80101cb9 <iunlockput>
801063b2:	83 c4 10             	add    $0x10,%esp
      end_op();
801063b5:	e8 47 ce ff ff       	call   80103201 <end_op>
      return -1;
801063ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bf:	e9 c0 00 00 00       	jmp    80106484 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063c4:	e8 5a ac ff ff       	call   80101023 <filealloc>
801063c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063d0:	74 17                	je     801063e9 <sys_open+0x104>
801063d2:	83 ec 0c             	sub    $0xc,%esp
801063d5:	ff 75 f0             	push   -0x10(%ebp)
801063d8:	e8 07 f7 ff ff       	call   80105ae4 <fdalloc>
801063dd:	83 c4 10             	add    $0x10,%esp
801063e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063e7:	79 2e                	jns    80106417 <sys_open+0x132>
    if(f)
801063e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ed:	74 0e                	je     801063fd <sys_open+0x118>
      fileclose(f);
801063ef:	83 ec 0c             	sub    $0xc,%esp
801063f2:	ff 75 f0             	push   -0x10(%ebp)
801063f5:	e8 ef ac ff ff       	call   801010e9 <fileclose>
801063fa:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063fd:	83 ec 0c             	sub    $0xc,%esp
80106400:	ff 75 f4             	push   -0xc(%ebp)
80106403:	e8 b1 b8 ff ff       	call   80101cb9 <iunlockput>
80106408:	83 c4 10             	add    $0x10,%esp
    end_op();
8010640b:	e8 f1 cd ff ff       	call   80103201 <end_op>
    return -1;
80106410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106415:	eb 6d                	jmp    80106484 <sys_open+0x19f>
  }
  iunlock(ip);
80106417:	83 ec 0c             	sub    $0xc,%esp
8010641a:	ff 75 f4             	push   -0xc(%ebp)
8010641d:	e8 71 b7 ff ff       	call   80101b93 <iunlock>
80106422:	83 c4 10             	add    $0x10,%esp
  end_op();
80106425:	e8 d7 cd ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
8010642a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106433:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106436:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106439:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010643c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106449:	83 e0 01             	and    $0x1,%eax
8010644c:	85 c0                	test   %eax,%eax
8010644e:	0f 94 c0             	sete   %al
80106451:	89 c2                	mov    %eax,%edx
80106453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106456:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010645c:	83 e0 01             	and    $0x1,%eax
8010645f:	85 c0                	test   %eax,%eax
80106461:	75 0a                	jne    8010646d <sys_open+0x188>
80106463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106466:	83 e0 02             	and    $0x2,%eax
80106469:	85 c0                	test   %eax,%eax
8010646b:	74 07                	je     80106474 <sys_open+0x18f>
8010646d:	b8 01 00 00 00       	mov    $0x1,%eax
80106472:	eb 05                	jmp    80106479 <sys_open+0x194>
80106474:	b8 00 00 00 00       	mov    $0x0,%eax
80106479:	89 c2                	mov    %eax,%edx
8010647b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106481:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106484:	c9                   	leave
80106485:	c3                   	ret

80106486 <sys_mkdir>:

int
sys_mkdir(void)
{
80106486:	f3 0f 1e fb          	endbr32
8010648a:	55                   	push   %ebp
8010648b:	89 e5                	mov    %esp,%ebp
8010648d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106490:	e8 dc cc ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106495:	83 ec 08             	sub    $0x8,%esp
80106498:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010649b:	50                   	push   %eax
8010649c:	6a 00                	push   $0x0
8010649e:	e8 0c f5 ff ff       	call   801059af <argstr>
801064a3:	83 c4 10             	add    $0x10,%esp
801064a6:	85 c0                	test   %eax,%eax
801064a8:	78 1b                	js     801064c5 <sys_mkdir+0x3f>
801064aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ad:	6a 00                	push   $0x0
801064af:	6a 00                	push   $0x0
801064b1:	6a 01                	push   $0x1
801064b3:	50                   	push   %eax
801064b4:	e8 56 fc ff ff       	call   8010610f <create>
801064b9:	83 c4 10             	add    $0x10,%esp
801064bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c3:	75 0c                	jne    801064d1 <sys_mkdir+0x4b>
    end_op();
801064c5:	e8 37 cd ff ff       	call   80103201 <end_op>
    return -1;
801064ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cf:	eb 18                	jmp    801064e9 <sys_mkdir+0x63>
  }
  iunlockput(ip);
801064d1:	83 ec 0c             	sub    $0xc,%esp
801064d4:	ff 75 f4             	push   -0xc(%ebp)
801064d7:	e8 dd b7 ff ff       	call   80101cb9 <iunlockput>
801064dc:	83 c4 10             	add    $0x10,%esp
  end_op();
801064df:	e8 1d cd ff ff       	call   80103201 <end_op>
  return 0;
801064e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e9:	c9                   	leave
801064ea:	c3                   	ret

801064eb <sys_mknod>:

int
sys_mknod(void)
{
801064eb:	f3 0f 1e fb          	endbr32
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064f5:	e8 77 cc ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064fa:	83 ec 08             	sub    $0x8,%esp
801064fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106500:	50                   	push   %eax
80106501:	6a 00                	push   $0x0
80106503:	e8 a7 f4 ff ff       	call   801059af <argstr>
80106508:	83 c4 10             	add    $0x10,%esp
8010650b:	85 c0                	test   %eax,%eax
8010650d:	78 4f                	js     8010655e <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010650f:	83 ec 08             	sub    $0x8,%esp
80106512:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106515:	50                   	push   %eax
80106516:	6a 01                	push   $0x1
80106518:	e8 f5 f3 ff ff       	call   80105912 <argint>
8010651d:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106520:	85 c0                	test   %eax,%eax
80106522:	78 3a                	js     8010655e <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106524:	83 ec 08             	sub    $0x8,%esp
80106527:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010652a:	50                   	push   %eax
8010652b:	6a 02                	push   $0x2
8010652d:	e8 e0 f3 ff ff       	call   80105912 <argint>
80106532:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106535:	85 c0                	test   %eax,%eax
80106537:	78 25                	js     8010655e <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106539:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010653c:	0f bf c8             	movswl %ax,%ecx
8010653f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106542:	0f bf d0             	movswl %ax,%edx
80106545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106548:	51                   	push   %ecx
80106549:	52                   	push   %edx
8010654a:	6a 03                	push   $0x3
8010654c:	50                   	push   %eax
8010654d:	e8 bd fb ff ff       	call   8010610f <create>
80106552:	83 c4 10             	add    $0x10,%esp
80106555:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106558:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010655c:	75 0c                	jne    8010656a <sys_mknod+0x7f>
    end_op();
8010655e:	e8 9e cc ff ff       	call   80103201 <end_op>
    return -1;
80106563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106568:	eb 18                	jmp    80106582 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010656a:	83 ec 0c             	sub    $0xc,%esp
8010656d:	ff 75 f4             	push   -0xc(%ebp)
80106570:	e8 44 b7 ff ff       	call   80101cb9 <iunlockput>
80106575:	83 c4 10             	add    $0x10,%esp
  end_op();
80106578:	e8 84 cc ff ff       	call   80103201 <end_op>
  return 0;
8010657d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106582:	c9                   	leave
80106583:	c3                   	ret

80106584 <sys_chdir>:

int
sys_chdir(void)
{
80106584:	f3 0f 1e fb          	endbr32
80106588:	55                   	push   %ebp
80106589:	89 e5                	mov    %esp,%ebp
8010658b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010658e:	e8 16 d6 ff ff       	call   80103ba9 <myproc>
80106593:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106596:	e8 d6 cb ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010659b:	83 ec 08             	sub    $0x8,%esp
8010659e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065a1:	50                   	push   %eax
801065a2:	6a 00                	push   $0x0
801065a4:	e8 06 f4 ff ff       	call   801059af <argstr>
801065a9:	83 c4 10             	add    $0x10,%esp
801065ac:	85 c0                	test   %eax,%eax
801065ae:	78 18                	js     801065c8 <sys_chdir+0x44>
801065b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065b3:	83 ec 0c             	sub    $0xc,%esp
801065b6:	50                   	push   %eax
801065b7:	e8 2b c0 ff ff       	call   801025e7 <namei>
801065bc:	83 c4 10             	add    $0x10,%esp
801065bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c6:	75 0c                	jne    801065d4 <sys_chdir+0x50>
    end_op();
801065c8:	e8 34 cc ff ff       	call   80103201 <end_op>
    return -1;
801065cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d2:	eb 68                	jmp    8010663c <sys_chdir+0xb8>
  }
  ilock(ip);
801065d4:	83 ec 0c             	sub    $0xc,%esp
801065d7:	ff 75 f0             	push   -0x10(%ebp)
801065da:	e8 9d b4 ff ff       	call   80101a7c <ilock>
801065df:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065e9:	66 83 f8 01          	cmp    $0x1,%ax
801065ed:	74 1a                	je     80106609 <sys_chdir+0x85>
    iunlockput(ip);
801065ef:	83 ec 0c             	sub    $0xc,%esp
801065f2:	ff 75 f0             	push   -0x10(%ebp)
801065f5:	e8 bf b6 ff ff       	call   80101cb9 <iunlockput>
801065fa:	83 c4 10             	add    $0x10,%esp
    end_op();
801065fd:	e8 ff cb ff ff       	call   80103201 <end_op>
    return -1;
80106602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106607:	eb 33                	jmp    8010663c <sys_chdir+0xb8>
  }
  iunlock(ip);
80106609:	83 ec 0c             	sub    $0xc,%esp
8010660c:	ff 75 f0             	push   -0x10(%ebp)
8010660f:	e8 7f b5 ff ff       	call   80101b93 <iunlock>
80106614:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661a:	8b 40 68             	mov    0x68(%eax),%eax
8010661d:	83 ec 0c             	sub    $0xc,%esp
80106620:	50                   	push   %eax
80106621:	e8 bf b5 ff ff       	call   80101be5 <iput>
80106626:	83 c4 10             	add    $0x10,%esp
  end_op();
80106629:	e8 d3 cb ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
8010662e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106631:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106634:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106637:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010663c:	c9                   	leave
8010663d:	c3                   	ret

8010663e <sys_exec>:

int
sys_exec(void)
{
8010663e:	f3 0f 1e fb          	endbr32
80106642:	55                   	push   %ebp
80106643:	89 e5                	mov    %esp,%ebp
80106645:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010664b:	83 ec 08             	sub    $0x8,%esp
8010664e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106651:	50                   	push   %eax
80106652:	6a 00                	push   $0x0
80106654:	e8 56 f3 ff ff       	call   801059af <argstr>
80106659:	83 c4 10             	add    $0x10,%esp
8010665c:	85 c0                	test   %eax,%eax
8010665e:	78 18                	js     80106678 <sys_exec+0x3a>
80106660:	83 ec 08             	sub    $0x8,%esp
80106663:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106669:	50                   	push   %eax
8010666a:	6a 01                	push   $0x1
8010666c:	e8 a1 f2 ff ff       	call   80105912 <argint>
80106671:	83 c4 10             	add    $0x10,%esp
80106674:	85 c0                	test   %eax,%eax
80106676:	79 0a                	jns    80106682 <sys_exec+0x44>
    return -1;
80106678:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010667d:	e9 c6 00 00 00       	jmp    80106748 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106682:	83 ec 04             	sub    $0x4,%esp
80106685:	68 80 00 00 00       	push   $0x80
8010668a:	6a 00                	push   $0x0
8010668c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106692:	50                   	push   %eax
80106693:	e8 26 ef ff ff       	call   801055be <memset>
80106698:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010669b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a5:	83 f8 1f             	cmp    $0x1f,%eax
801066a8:	76 0a                	jbe    801066b4 <sys_exec+0x76>
      return -1;
801066aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066af:	e9 94 00 00 00       	jmp    80106748 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b7:	c1 e0 02             	shl    $0x2,%eax
801066ba:	89 c2                	mov    %eax,%edx
801066bc:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066c2:	01 c2                	add    %eax,%edx
801066c4:	83 ec 08             	sub    $0x8,%esp
801066c7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066cd:	50                   	push   %eax
801066ce:	52                   	push   %edx
801066cf:	e8 93 f1 ff ff       	call   80105867 <fetchint>
801066d4:	83 c4 10             	add    $0x10,%esp
801066d7:	85 c0                	test   %eax,%eax
801066d9:	79 07                	jns    801066e2 <sys_exec+0xa4>
      return -1;
801066db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e0:	eb 66                	jmp    80106748 <sys_exec+0x10a>
    if(uarg == 0){
801066e2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066e8:	85 c0                	test   %eax,%eax
801066ea:	75 27                	jne    80106713 <sys_exec+0xd5>
      argv[i] = 0;
801066ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ef:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066f6:	00 00 00 00 
      break;
801066fa:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066fe:	83 ec 08             	sub    $0x8,%esp
80106701:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106707:	52                   	push   %edx
80106708:	50                   	push   %eax
80106709:	e8 b0 a4 ff ff       	call   80100bbe <exec>
8010670e:	83 c4 10             	add    $0x10,%esp
80106711:	eb 35                	jmp    80106748 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106713:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010671c:	c1 e2 02             	shl    $0x2,%edx
8010671f:	01 c2                	add    %eax,%edx
80106721:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106727:	83 ec 08             	sub    $0x8,%esp
8010672a:	52                   	push   %edx
8010672b:	50                   	push   %eax
8010672c:	e8 79 f1 ff ff       	call   801058aa <fetchstr>
80106731:	83 c4 10             	add    $0x10,%esp
80106734:	85 c0                	test   %eax,%eax
80106736:	79 07                	jns    8010673f <sys_exec+0x101>
      return -1;
80106738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673d:	eb 09                	jmp    80106748 <sys_exec+0x10a>
  for(i=0;; i++){
8010673f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106743:	e9 5a ff ff ff       	jmp    801066a2 <sys_exec+0x64>
}
80106748:	c9                   	leave
80106749:	c3                   	ret

8010674a <sys_pipe>:

int
sys_pipe(void)
{
8010674a:	f3 0f 1e fb          	endbr32
8010674e:	55                   	push   %ebp
8010674f:	89 e5                	mov    %esp,%ebp
80106751:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106754:	83 ec 04             	sub    $0x4,%esp
80106757:	6a 08                	push   $0x8
80106759:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010675c:	50                   	push   %eax
8010675d:	6a 00                	push   $0x0
8010675f:	e8 df f1 ff ff       	call   80105943 <argptr>
80106764:	83 c4 10             	add    $0x10,%esp
80106767:	85 c0                	test   %eax,%eax
80106769:	79 0a                	jns    80106775 <sys_pipe+0x2b>
    return -1;
8010676b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106770:	e9 ae 00 00 00       	jmp    80106823 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106775:	83 ec 08             	sub    $0x8,%esp
80106778:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010677b:	50                   	push   %eax
8010677c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010677f:	50                   	push   %eax
80106780:	e8 45 cf ff ff       	call   801036ca <pipealloc>
80106785:	83 c4 10             	add    $0x10,%esp
80106788:	85 c0                	test   %eax,%eax
8010678a:	79 0a                	jns    80106796 <sys_pipe+0x4c>
    return -1;
8010678c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106791:	e9 8d 00 00 00       	jmp    80106823 <sys_pipe+0xd9>
  fd0 = -1;
80106796:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010679d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067a0:	83 ec 0c             	sub    $0xc,%esp
801067a3:	50                   	push   %eax
801067a4:	e8 3b f3 ff ff       	call   80105ae4 <fdalloc>
801067a9:	83 c4 10             	add    $0x10,%esp
801067ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067b3:	78 18                	js     801067cd <sys_pipe+0x83>
801067b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067b8:	83 ec 0c             	sub    $0xc,%esp
801067bb:	50                   	push   %eax
801067bc:	e8 23 f3 ff ff       	call   80105ae4 <fdalloc>
801067c1:	83 c4 10             	add    $0x10,%esp
801067c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067cb:	79 3e                	jns    8010680b <sys_pipe+0xc1>
    if(fd0 >= 0)
801067cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d1:	78 13                	js     801067e6 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801067d3:	e8 d1 d3 ff ff       	call   80103ba9 <myproc>
801067d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067db:	83 c2 08             	add    $0x8,%edx
801067de:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067e5:	00 
    fileclose(rf);
801067e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067e9:	83 ec 0c             	sub    $0xc,%esp
801067ec:	50                   	push   %eax
801067ed:	e8 f7 a8 ff ff       	call   801010e9 <fileclose>
801067f2:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067f8:	83 ec 0c             	sub    $0xc,%esp
801067fb:	50                   	push   %eax
801067fc:	e8 e8 a8 ff ff       	call   801010e9 <fileclose>
80106801:	83 c4 10             	add    $0x10,%esp
    return -1;
80106804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106809:	eb 18                	jmp    80106823 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
8010680b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010680e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106811:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106813:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106816:	8d 50 04             	lea    0x4(%eax),%edx
80106819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010681c:	89 02                	mov    %eax,(%edx)
  return 0;
8010681e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106823:	c9                   	leave
80106824:	c3                   	ret

80106825 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
80106825:	f3 0f 1e fb          	endbr32
80106829:	55                   	push   %ebp
8010682a:	89 e5                	mov    %esp,%ebp
8010682c:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
8010682f:	83 ec 04             	sub    $0x4,%esp
80106832:	68 00 0c 00 00       	push   $0xc00
80106837:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010683a:	50                   	push   %eax
8010683b:	6a 00                	push   $0x0
8010683d:	e8 01 f1 ff ff       	call   80105943 <argptr>
80106842:	83 c4 10             	add    $0x10,%esp
80106845:	85 c0                	test   %eax,%eax
80106847:	79 07                	jns    80106850 <sys_getpinfo+0x2b>
    return -1;
80106849:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010684e:	eb 0f                	jmp    8010685f <sys_getpinfo+0x3a>
  return getpinfo(ps);
80106850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106853:	83 ec 0c             	sub    $0xc,%esp
80106856:	50                   	push   %eax
80106857:	e8 bd e0 ff ff       	call   80104919 <getpinfo>
8010685c:	83 c4 10             	add    $0x10,%esp
}
8010685f:	c9                   	leave
80106860:	c3                   	ret

80106861 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
80106861:	f3 0f 1e fb          	endbr32
80106865:	55                   	push   %ebp
80106866:	89 e5                	mov    %esp,%ebp
80106868:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
8010686b:	83 ec 08             	sub    $0x8,%esp
8010686e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106871:	50                   	push   %eax
80106872:	6a 00                	push   $0x0
80106874:	e8 99 f0 ff ff       	call   80105912 <argint>
80106879:	83 c4 10             	add    $0x10,%esp
8010687c:	85 c0                	test   %eax,%eax
8010687e:	79 07                	jns    80106887 <sys_setSchedPolicy+0x26>
    return -1;
80106880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106885:	eb 23                	jmp    801068aa <sys_setSchedPolicy+0x49>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688a:	83 ec 08             	sub    $0x8,%esp
8010688d:	50                   	push   %eax
8010688e:	68 08 b5 10 80       	push   $0x8010b508
80106893:	e8 74 9b ff ff       	call   8010040c <cprintf>
80106898:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
8010689b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689e:	83 ec 0c             	sub    $0xc,%esp
801068a1:	50                   	push   %eax
801068a2:	e8 4e e2 ff ff       	call   80104af5 <set_sched_policy>
801068a7:	83 c4 10             	add    $0x10,%esp
}
801068aa:	c9                   	leave
801068ab:	c3                   	ret

801068ac <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
801068ac:	f3 0f 1e fb          	endbr32
801068b0:	55                   	push   %ebp
801068b1:	89 e5                	mov    %esp,%ebp
801068b3:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
801068b6:	e8 81 e2 ff ff       	call   80104b3c <get_sched_policy>
}
801068bb:	c9                   	leave
801068bc:	c3                   	ret

801068bd <sys_yield>:
int
sys_yield(void)
{
801068bd:	f3 0f 1e fb          	endbr32
801068c1:	55                   	push   %ebp
801068c2:	89 e5                	mov    %esp,%ebp
801068c4:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
801068c7:	e8 15 dd ff ff       	call   801045e1 <yield>
  return 0;
801068cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068d1:	c9                   	leave
801068d2:	c3                   	ret

801068d3 <sys_fork>:

int
sys_fork(void)
{
801068d3:	f3 0f 1e fb          	endbr32
801068d7:	55                   	push   %ebp
801068d8:	89 e5                	mov    %esp,%ebp
801068da:	83 ec 08             	sub    $0x8,%esp
  return fork();
801068dd:	e8 7b d6 ff ff       	call   80103f5d <fork>
}
801068e2:	c9                   	leave
801068e3:	c3                   	ret

801068e4 <sys_exit>:

int
sys_exit(void)
{
801068e4:	f3 0f 1e fb          	endbr32
801068e8:	55                   	push   %ebp
801068e9:	89 e5                	mov    %esp,%ebp
801068eb:	83 ec 08             	sub    $0x8,%esp
  exit();
801068ee:	e8 42 d8 ff ff       	call   80104135 <exit>
  return 0;  // not reached
801068f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068f8:	c9                   	leave
801068f9:	c3                   	ret

801068fa <sys_wait>:

int
sys_wait(void)
{
801068fa:	f3 0f 1e fb          	endbr32
801068fe:	55                   	push   %ebp
801068ff:	89 e5                	mov    %esp,%ebp
80106901:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106904:	e8 a5 d9 ff ff       	call   801042ae <wait>
}
80106909:	c9                   	leave
8010690a:	c3                   	ret

8010690b <sys_kill>:

int
sys_kill(void)
{
8010690b:	f3 0f 1e fb          	endbr32
8010690f:	55                   	push   %ebp
80106910:	89 e5                	mov    %esp,%ebp
80106912:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106915:	83 ec 08             	sub    $0x8,%esp
80106918:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010691b:	50                   	push   %eax
8010691c:	6a 00                	push   $0x0
8010691e:	e8 ef ef ff ff       	call   80105912 <argint>
80106923:	83 c4 10             	add    $0x10,%esp
80106926:	85 c0                	test   %eax,%eax
80106928:	79 07                	jns    80106931 <sys_kill+0x26>
    return -1;
8010692a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010692f:	eb 0f                	jmp    80106940 <sys_kill+0x35>
  return kill(pid);
80106931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106934:	83 ec 0c             	sub    $0xc,%esp
80106937:	50                   	push   %eax
80106938:	e8 56 de ff ff       	call   80104793 <kill>
8010693d:	83 c4 10             	add    $0x10,%esp
}
80106940:	c9                   	leave
80106941:	c3                   	ret

80106942 <sys_getpid>:

int
sys_getpid(void)
{
80106942:	f3 0f 1e fb          	endbr32
80106946:	55                   	push   %ebp
80106947:	89 e5                	mov    %esp,%ebp
80106949:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010694c:	e8 58 d2 ff ff       	call   80103ba9 <myproc>
80106951:	8b 40 10             	mov    0x10(%eax),%eax
}
80106954:	c9                   	leave
80106955:	c3                   	ret

80106956 <sys_sbrk>:

int
sys_sbrk(void)
{
80106956:	f3 0f 1e fb          	endbr32
8010695a:	55                   	push   %ebp
8010695b:	89 e5                	mov    %esp,%ebp
8010695d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106960:	83 ec 08             	sub    $0x8,%esp
80106963:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106966:	50                   	push   %eax
80106967:	6a 00                	push   $0x0
80106969:	e8 a4 ef ff ff       	call   80105912 <argint>
8010696e:	83 c4 10             	add    $0x10,%esp
80106971:	85 c0                	test   %eax,%eax
80106973:	79 07                	jns    8010697c <sys_sbrk+0x26>
    return -1;
80106975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697a:	eb 27                	jmp    801069a3 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010697c:	e8 28 d2 ff ff       	call   80103ba9 <myproc>
80106981:	8b 00                	mov    (%eax),%eax
80106983:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106989:	83 ec 0c             	sub    $0xc,%esp
8010698c:	50                   	push   %eax
8010698d:	e8 2c d5 ff ff       	call   80103ebe <growproc>
80106992:	83 c4 10             	add    $0x10,%esp
80106995:	85 c0                	test   %eax,%eax
80106997:	79 07                	jns    801069a0 <sys_sbrk+0x4a>
    return -1;
80106999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699e:	eb 03                	jmp    801069a3 <sys_sbrk+0x4d>
  return addr;
801069a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069a3:	c9                   	leave
801069a4:	c3                   	ret

801069a5 <sys_sleep>:

int
sys_sleep(void)
{
801069a5:	f3 0f 1e fb          	endbr32
801069a9:	55                   	push   %ebp
801069aa:	89 e5                	mov    %esp,%ebp
801069ac:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801069af:	83 ec 08             	sub    $0x8,%esp
801069b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069b5:	50                   	push   %eax
801069b6:	6a 00                	push   $0x0
801069b8:	e8 55 ef ff ff       	call   80105912 <argint>
801069bd:	83 c4 10             	add    $0x10,%esp
801069c0:	85 c0                	test   %eax,%eax
801069c2:	79 07                	jns    801069cb <sys_sleep+0x26>
    return -1;
801069c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c9:	eb 76                	jmp    80106a41 <sys_sleep+0x9c>
  acquire(&tickslock);
801069cb:	83 ec 0c             	sub    $0xc,%esp
801069ce:	68 60 94 19 80       	push   $0x80199460
801069d3:	e8 57 e9 ff ff       	call   8010532f <acquire>
801069d8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801069db:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
801069e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801069e3:	eb 38                	jmp    80106a1d <sys_sleep+0x78>
    if(myproc()->killed){
801069e5:	e8 bf d1 ff ff       	call   80103ba9 <myproc>
801069ea:	8b 40 24             	mov    0x24(%eax),%eax
801069ed:	85 c0                	test   %eax,%eax
801069ef:	74 17                	je     80106a08 <sys_sleep+0x63>
      release(&tickslock);
801069f1:	83 ec 0c             	sub    $0xc,%esp
801069f4:	68 60 94 19 80       	push   $0x80199460
801069f9:	e8 a3 e9 ff ff       	call   801053a1 <release>
801069fe:	83 c4 10             	add    $0x10,%esp
      return -1;
80106a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a06:	eb 39                	jmp    80106a41 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106a08:	83 ec 08             	sub    $0x8,%esp
80106a0b:	68 60 94 19 80       	push   $0x80199460
80106a10:	68 a0 9c 19 80       	push   $0x80199ca0
80106a15:	e8 4f dc ff ff       	call   80104669 <sleep>
80106a1a:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106a1d:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a22:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a28:	39 d0                	cmp    %edx,%eax
80106a2a:	72 b9                	jb     801069e5 <sys_sleep+0x40>
  }
  release(&tickslock);
80106a2c:	83 ec 0c             	sub    $0xc,%esp
80106a2f:	68 60 94 19 80       	push   $0x80199460
80106a34:	e8 68 e9 ff ff       	call   801053a1 <release>
80106a39:	83 c4 10             	add    $0x10,%esp
  return 0;
80106a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a41:	c9                   	leave
80106a42:	c3                   	ret

80106a43 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106a43:	f3 0f 1e fb          	endbr32
80106a47:	55                   	push   %ebp
80106a48:	89 e5                	mov    %esp,%ebp
80106a4a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106a4d:	83 ec 0c             	sub    $0xc,%esp
80106a50:	68 60 94 19 80       	push   $0x80199460
80106a55:	e8 d5 e8 ff ff       	call   8010532f <acquire>
80106a5a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106a5d:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a65:	83 ec 0c             	sub    $0xc,%esp
80106a68:	68 60 94 19 80       	push   $0x80199460
80106a6d:	e8 2f e9 ff ff       	call   801053a1 <release>
80106a72:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a78:	c9                   	leave
80106a79:	c3                   	ret

80106a7a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a7a:	1e                   	push   %ds
  pushl %es
80106a7b:	06                   	push   %es
  pushl %fs
80106a7c:	0f a0                	push   %fs
  pushl %gs
80106a7e:	0f a8                	push   %gs
  pushal
80106a80:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106a81:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a85:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a87:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a89:	54                   	push   %esp
  call trap
80106a8a:	e8 df 01 00 00       	call   80106c6e <trap>
  addl $4, %esp
80106a8f:	83 c4 04             	add    $0x4,%esp

80106a92 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a92:	61                   	popa
  popl %gs
80106a93:	0f a9                	pop    %gs
  popl %fs
80106a95:	0f a1                	pop    %fs
  popl %es
80106a97:	07                   	pop    %es
  popl %ds
80106a98:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a99:	83 c4 08             	add    $0x8,%esp
  iret
80106a9c:	cf                   	iret

80106a9d <lidt>:
{
80106a9d:	55                   	push   %ebp
80106a9e:	89 e5                	mov    %esp,%ebp
80106aa0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aa6:	83 e8 01             	sub    $0x1,%eax
80106aa9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106aad:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab7:	c1 e8 10             	shr    $0x10,%eax
80106aba:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106abe:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ac1:	0f 01 18             	lidtl  (%eax)
}
80106ac4:	90                   	nop
80106ac5:	c9                   	leave
80106ac6:	c3                   	ret

80106ac7 <rcr2>:

static inline uint
rcr2(void)
{
80106ac7:	55                   	push   %ebp
80106ac8:	89 e5                	mov    %esp,%ebp
80106aca:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106acd:	0f 20 d0             	mov    %cr2,%eax
80106ad0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106ad3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106ad6:	c9                   	leave
80106ad7:	c3                   	ret

80106ad8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106ad8:	f3 0f 1e fb          	endbr32
80106adc:	55                   	push   %ebp
80106add:	89 e5                	mov    %esp,%ebp
80106adf:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ae9:	e9 c3 00 00 00       	jmp    80106bb1 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af1:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106af8:	89 c2                	mov    %eax,%edx
80106afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afd:	66 89 14 c5 a0 94 19 	mov    %dx,-0x7fe66b60(,%eax,8)
80106b04:	80 
80106b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b08:	66 c7 04 c5 a2 94 19 	movw   $0x8,-0x7fe66b5e(,%eax,8)
80106b0f:	80 08 00 
80106b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b15:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b1c:	80 
80106b1d:	83 e2 e0             	and    $0xffffffe0,%edx
80106b20:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2a:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b31:	80 
80106b32:	83 e2 1f             	and    $0x1f,%edx
80106b35:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3f:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b46:	80 
80106b47:	83 e2 f0             	and    $0xfffffff0,%edx
80106b4a:	83 ca 0e             	or     $0xe,%edx
80106b4d:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b57:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b5e:	80 
80106b5f:	83 e2 ef             	and    $0xffffffef,%edx
80106b62:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6c:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b73:	80 
80106b74:	83 e2 9f             	and    $0xffffff9f,%edx
80106b77:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b81:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b88:	80 
80106b89:	83 ca 80             	or     $0xffffff80,%edx
80106b8c:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b96:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106b9d:	c1 e8 10             	shr    $0x10,%eax
80106ba0:	89 c2                	mov    %eax,%edx
80106ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba5:	66 89 14 c5 a6 94 19 	mov    %dx,-0x7fe66b5a(,%eax,8)
80106bac:	80 
  for(i = 0; i < 256; i++)
80106bad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bb1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bb8:	0f 8e 30 ff ff ff    	jle    80106aee <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bbe:	a1 88 01 11 80       	mov    0x80110188,%eax
80106bc3:	66 a3 a0 96 19 80    	mov    %ax,0x801996a0
80106bc9:	66 c7 05 a2 96 19 80 	movw   $0x8,0x801996a2
80106bd0:	08 00 
80106bd2:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106bd9:	83 e0 e0             	and    $0xffffffe0,%eax
80106bdc:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106be1:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106be8:	83 e0 1f             	and    $0x1f,%eax
80106beb:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106bf0:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106bf7:	83 c8 0f             	or     $0xf,%eax
80106bfa:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106bff:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c06:	83 e0 ef             	and    $0xffffffef,%eax
80106c09:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c0e:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c15:	83 c8 60             	or     $0x60,%eax
80106c18:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c1d:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c24:	83 c8 80             	or     $0xffffff80,%eax
80106c27:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c2c:	a1 88 01 11 80       	mov    0x80110188,%eax
80106c31:	c1 e8 10             	shr    $0x10,%eax
80106c34:	66 a3 a6 96 19 80    	mov    %ax,0x801996a6

  initlock(&tickslock, "time");
80106c3a:	83 ec 08             	sub    $0x8,%esp
80106c3d:	68 34 b5 10 80       	push   $0x8010b534
80106c42:	68 60 94 19 80       	push   $0x80199460
80106c47:	e8 bd e6 ff ff       	call   80105309 <initlock>
80106c4c:	83 c4 10             	add    $0x10,%esp
}
80106c4f:	90                   	nop
80106c50:	c9                   	leave
80106c51:	c3                   	ret

80106c52 <idtinit>:

void
idtinit(void)
{
80106c52:	f3 0f 1e fb          	endbr32
80106c56:	55                   	push   %ebp
80106c57:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c59:	68 00 08 00 00       	push   $0x800
80106c5e:	68 a0 94 19 80       	push   $0x801994a0
80106c63:	e8 35 fe ff ff       	call   80106a9d <lidt>
80106c68:	83 c4 08             	add    $0x8,%esp
}
80106c6b:	90                   	nop
80106c6c:	c9                   	leave
80106c6d:	c3                   	ret

80106c6e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c6e:	f3 0f 1e fb          	endbr32
80106c72:	55                   	push   %ebp
80106c73:	89 e5                	mov    %esp,%ebp
80106c75:	57                   	push   %edi
80106c76:	56                   	push   %esi
80106c77:	53                   	push   %ebx
80106c78:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7e:	8b 40 30             	mov    0x30(%eax),%eax
80106c81:	83 f8 40             	cmp    $0x40,%eax
80106c84:	75 3b                	jne    80106cc1 <trap+0x53>
    if(myproc()->killed)
80106c86:	e8 1e cf ff ff       	call   80103ba9 <myproc>
80106c8b:	8b 40 24             	mov    0x24(%eax),%eax
80106c8e:	85 c0                	test   %eax,%eax
80106c90:	74 05                	je     80106c97 <trap+0x29>
      exit();
80106c92:	e8 9e d4 ff ff       	call   80104135 <exit>
    myproc()->tf = tf;
80106c97:	e8 0d cf ff ff       	call   80103ba9 <myproc>
80106c9c:	8b 55 08             	mov    0x8(%ebp),%edx
80106c9f:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ca2:	e8 43 ed ff ff       	call   801059ea <syscall>
    if(myproc()->killed)
80106ca7:	e8 fd ce ff ff       	call   80103ba9 <myproc>
80106cac:	8b 40 24             	mov    0x24(%eax),%eax
80106caf:	85 c0                	test   %eax,%eax
80106cb1:	0f 84 3f 03 00 00    	je     80106ff6 <trap+0x388>
      exit();
80106cb7:	e8 79 d4 ff ff       	call   80104135 <exit>
    return;
80106cbc:	e9 35 03 00 00       	jmp    80106ff6 <trap+0x388>
  }

  switch(tf->trapno){
80106cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc4:	8b 40 30             	mov    0x30(%eax),%eax
80106cc7:	83 e8 20             	sub    $0x20,%eax
80106cca:	83 f8 1f             	cmp    $0x1f,%eax
80106ccd:	0f 87 ee 01 00 00    	ja     80106ec1 <trap+0x253>
80106cd3:	8b 04 85 08 b6 10 80 	mov    -0x7fef49f8(,%eax,4),%eax
80106cda:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106cdd:	e8 2c ce ff ff       	call   80103b0e <cpuid>
80106ce2:	85 c0                	test   %eax,%eax
80106ce4:	75 3d                	jne    80106d23 <trap+0xb5>
      acquire(&tickslock);
80106ce6:	83 ec 0c             	sub    $0xc,%esp
80106ce9:	68 60 94 19 80       	push   $0x80199460
80106cee:	e8 3c e6 ff ff       	call   8010532f <acquire>
80106cf3:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106cf6:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106cfb:	83 c0 01             	add    $0x1,%eax
80106cfe:	a3 a0 9c 19 80       	mov    %eax,0x80199ca0
      wakeup(&ticks);
80106d03:	83 ec 0c             	sub    $0xc,%esp
80106d06:	68 a0 9c 19 80       	push   $0x80199ca0
80106d0b:	e8 48 da ff ff       	call   80104758 <wakeup>
80106d10:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d13:	83 ec 0c             	sub    $0xc,%esp
80106d16:	68 60 94 19 80       	push   $0x80199460
80106d1b:	e8 81 e6 ff ff       	call   801053a1 <release>
80106d20:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106d23:	e8 81 ce ff ff       	call   80103ba9 <myproc>
80106d28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106d2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106d2f:	0f 84 17 01 00 00    	je     80106e4c <trap+0x1de>
80106d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d38:	8b 40 0c             	mov    0xc(%eax),%eax
80106d3b:	83 f8 04             	cmp    $0x4,%eax
80106d3e:	0f 85 08 01 00 00    	jne    80106e4c <trap+0x1de>
80106d44:	e8 e4 cd ff ff       	call   80103b2d <mycpu>
80106d49:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106d4f:	85 c0                	test   %eax,%eax
80106d51:	0f 84 f5 00 00 00    	je     80106e4c <trap+0x1de>
      int idx = myproc() - ptable.proc;
80106d57:	e8 4d ce ff ff       	call   80103ba9 <myproc>
80106d5c:	2d 54 75 19 80       	sub    $0x80197554,%eax
80106d61:	c1 f8 02             	sar    $0x2,%eax
80106d64:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106d6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d70:	83 e8 80             	sub    $0xffffff80,%eax
80106d73:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106d7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106d87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d8a:	01 d0                	add    %edx,%eax
80106d8c:	05 00 01 00 00       	add    $0x100,%eax
80106d91:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106d98:	8d 50 01             	lea    0x1(%eax),%edx
80106d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d9e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106da8:	01 c8                	add    %ecx,%eax
80106daa:	05 00 01 00 00       	add    $0x100,%eax
80106daf:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
      kernel_pstat.wait_ticks[idx][q] = 0; // wait time 초기화
80106db6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106db9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106dc3:	01 d0                	add    %edx,%eax
80106dc5:	05 00 02 00 00       	add    $0x200,%eax
80106dca:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80106dd1:	00 00 00 00 
      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106dd8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106ddf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106de2:	01 d0                	add    %edx,%eax
80106de4:	05 00 01 00 00       	add    $0x100,%eax
80106de9:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106df0:	83 f8 01             	cmp    $0x1,%eax
80106df3:	74 22                	je     80106e17 <trap+0x1a9>
80106df5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106df8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e02:	01 d0                	add    %edx,%eax
80106e04:	05 00 01 00 00       	add    $0x100,%eax
80106e09:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106e10:	83 e0 07             	and    $0x7,%eax
80106e13:	85 c0                	test   %eax,%eax
80106e15:	75 35                	jne    80106e4c <trap+0x1de>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e24:	01 d0                	add    %edx,%eax
80106e26:	05 00 01 00 00       	add    $0x100,%eax
80106e2b:	8b 1c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106e32:	e8 72 cd ff ff       	call   80103ba9 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e37:	8b 40 10             	mov    0x10(%eax),%eax
80106e3a:	53                   	push   %ebx
80106e3b:	ff 75 dc             	push   -0x24(%ebp)
80106e3e:	50                   	push   %eax
80106e3f:	68 3c b5 10 80       	push   $0x8010b53c
80106e44:	e8 c3 95 ff ff       	call   8010040c <cprintf>
80106e49:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106e4c:	e8 d4 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e51:	e9 20 01 00 00       	jmp    80106f76 <trap+0x308>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e56:	e8 1a 40 00 00       	call   8010ae75 <ideintr>
    lapiceoi();
80106e5b:	e8 c5 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e60:	e9 11 01 00 00       	jmp    80106f76 <trap+0x308>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106e65:	e8 f1 bb ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106e6a:	e8 b6 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e6f:	e9 02 01 00 00       	jmp    80106f76 <trap+0x308>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106e74:	e8 5f 03 00 00       	call   801071d8 <uartintr>
    lapiceoi();
80106e79:	e8 a7 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e7e:	e9 f3 00 00 00       	jmp    80106f76 <trap+0x308>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106e83:	e8 2c 2c 00 00       	call   80109ab4 <i8254_intr>
    lapiceoi();
80106e88:	e8 98 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e8d:	e9 e4 00 00 00       	jmp    80106f76 <trap+0x308>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e92:	8b 45 08             	mov    0x8(%ebp),%eax
80106e95:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106e98:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e9f:	0f b7 d8             	movzwl %ax,%ebx
80106ea2:	e8 67 cc ff ff       	call   80103b0e <cpuid>
80106ea7:	56                   	push   %esi
80106ea8:	53                   	push   %ebx
80106ea9:	50                   	push   %eax
80106eaa:	68 68 b5 10 80       	push   $0x8010b568
80106eaf:	e8 58 95 ff ff       	call   8010040c <cprintf>
80106eb4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106eb7:	e8 69 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106ebc:	e9 b5 00 00 00       	jmp    80106f76 <trap+0x308>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ec1:	e8 e3 cc ff ff       	call   80103ba9 <myproc>
80106ec6:	85 c0                	test   %eax,%eax
80106ec8:	74 11                	je     80106edb <trap+0x26d>
80106eca:	8b 45 08             	mov    0x8(%ebp),%eax
80106ecd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ed1:	0f b7 c0             	movzwl %ax,%eax
80106ed4:	83 e0 03             	and    $0x3,%eax
80106ed7:	85 c0                	test   %eax,%eax
80106ed9:	75 39                	jne    80106f14 <trap+0x2a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106edb:	e8 e7 fb ff ff       	call   80106ac7 <rcr2>
80106ee0:	89 c3                	mov    %eax,%ebx
80106ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee5:	8b 70 38             	mov    0x38(%eax),%esi
80106ee8:	e8 21 cc ff ff       	call   80103b0e <cpuid>
80106eed:	8b 55 08             	mov    0x8(%ebp),%edx
80106ef0:	8b 52 30             	mov    0x30(%edx),%edx
80106ef3:	83 ec 0c             	sub    $0xc,%esp
80106ef6:	53                   	push   %ebx
80106ef7:	56                   	push   %esi
80106ef8:	50                   	push   %eax
80106ef9:	52                   	push   %edx
80106efa:	68 8c b5 10 80       	push   $0x8010b58c
80106eff:	e8 08 95 ff ff       	call   8010040c <cprintf>
80106f04:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106f07:	83 ec 0c             	sub    $0xc,%esp
80106f0a:	68 be b5 10 80       	push   $0x8010b5be
80106f0f:	e8 b1 96 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f14:	e8 ae fb ff ff       	call   80106ac7 <rcr2>
80106f19:	89 c6                	mov    %eax,%esi
80106f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1e:	8b 40 38             	mov    0x38(%eax),%eax
80106f21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106f24:	e8 e5 cb ff ff       	call   80103b0e <cpuid>
80106f29:	89 c3                	mov    %eax,%ebx
80106f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2e:	8b 48 34             	mov    0x34(%eax),%ecx
80106f31:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106f34:	8b 45 08             	mov    0x8(%ebp),%eax
80106f37:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106f3a:	e8 6a cc ff ff       	call   80103ba9 <myproc>
80106f3f:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f42:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106f45:	e8 5f cc ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f4a:	8b 40 10             	mov    0x10(%eax),%eax
80106f4d:	56                   	push   %esi
80106f4e:	ff 75 d4             	push   -0x2c(%ebp)
80106f51:	53                   	push   %ebx
80106f52:	ff 75 d0             	push   -0x30(%ebp)
80106f55:	57                   	push   %edi
80106f56:	ff 75 cc             	push   -0x34(%ebp)
80106f59:	50                   	push   %eax
80106f5a:	68 c4 b5 10 80       	push   $0x8010b5c4
80106f5f:	e8 a8 94 ff ff       	call   8010040c <cprintf>
80106f64:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106f67:	e8 3d cc ff ff       	call   80103ba9 <myproc>
80106f6c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f73:	eb 01                	jmp    80106f76 <trap+0x308>
    break;
80106f75:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f76:	e8 2e cc ff ff       	call   80103ba9 <myproc>
80106f7b:	85 c0                	test   %eax,%eax
80106f7d:	74 23                	je     80106fa2 <trap+0x334>
80106f7f:	e8 25 cc ff ff       	call   80103ba9 <myproc>
80106f84:	8b 40 24             	mov    0x24(%eax),%eax
80106f87:	85 c0                	test   %eax,%eax
80106f89:	74 17                	je     80106fa2 <trap+0x334>
80106f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f92:	0f b7 c0             	movzwl %ax,%eax
80106f95:	83 e0 03             	and    $0x3,%eax
80106f98:	83 f8 03             	cmp    $0x3,%eax
80106f9b:	75 05                	jne    80106fa2 <trap+0x334>
    exit();
80106f9d:	e8 93 d1 ff ff       	call   80104135 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106fa2:	e8 02 cc ff ff       	call   80103ba9 <myproc>
80106fa7:	85 c0                	test   %eax,%eax
80106fa9:	74 1d                	je     80106fc8 <trap+0x35a>
80106fab:	e8 f9 cb ff ff       	call   80103ba9 <myproc>
80106fb0:	8b 40 0c             	mov    0xc(%eax),%eax
80106fb3:	83 f8 04             	cmp    $0x4,%eax
80106fb6:	75 10                	jne    80106fc8 <trap+0x35a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80106fbb:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106fbe:	83 f8 20             	cmp    $0x20,%eax
80106fc1:	75 05                	jne    80106fc8 <trap+0x35a>
    yield();
80106fc3:	e8 19 d6 ff ff       	call   801045e1 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106fc8:	e8 dc cb ff ff       	call   80103ba9 <myproc>
80106fcd:	85 c0                	test   %eax,%eax
80106fcf:	74 26                	je     80106ff7 <trap+0x389>
80106fd1:	e8 d3 cb ff ff       	call   80103ba9 <myproc>
80106fd6:	8b 40 24             	mov    0x24(%eax),%eax
80106fd9:	85 c0                	test   %eax,%eax
80106fdb:	74 1a                	je     80106ff7 <trap+0x389>
80106fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106fe0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fe4:	0f b7 c0             	movzwl %ax,%eax
80106fe7:	83 e0 03             	and    $0x3,%eax
80106fea:	83 f8 03             	cmp    $0x3,%eax
80106fed:	75 08                	jne    80106ff7 <trap+0x389>
    exit();
80106fef:	e8 41 d1 ff ff       	call   80104135 <exit>
80106ff4:	eb 01                	jmp    80106ff7 <trap+0x389>
    return;
80106ff6:	90                   	nop
}
80106ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ffa:	5b                   	pop    %ebx
80106ffb:	5e                   	pop    %esi
80106ffc:	5f                   	pop    %edi
80106ffd:	5d                   	pop    %ebp
80106ffe:	c3                   	ret

80106fff <inb>:
{
80106fff:	55                   	push   %ebp
80107000:	89 e5                	mov    %esp,%ebp
80107002:	83 ec 14             	sub    $0x14,%esp
80107005:	8b 45 08             	mov    0x8(%ebp),%eax
80107008:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010700c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107010:	89 c2                	mov    %eax,%edx
80107012:	ec                   	in     (%dx),%al
80107013:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107016:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010701a:	c9                   	leave
8010701b:	c3                   	ret

8010701c <outb>:
{
8010701c:	55                   	push   %ebp
8010701d:	89 e5                	mov    %esp,%ebp
8010701f:	83 ec 08             	sub    $0x8,%esp
80107022:	8b 45 08             	mov    0x8(%ebp),%eax
80107025:	8b 55 0c             	mov    0xc(%ebp),%edx
80107028:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010702c:	89 d0                	mov    %edx,%eax
8010702e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107031:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107035:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107039:	ee                   	out    %al,(%dx)
}
8010703a:	90                   	nop
8010703b:	c9                   	leave
8010703c:	c3                   	ret

8010703d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010703d:	f3 0f 1e fb          	endbr32
80107041:	55                   	push   %ebp
80107042:	89 e5                	mov    %esp,%ebp
80107044:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107047:	6a 00                	push   $0x0
80107049:	68 fa 03 00 00       	push   $0x3fa
8010704e:	e8 c9 ff ff ff       	call   8010701c <outb>
80107053:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107056:	68 80 00 00 00       	push   $0x80
8010705b:	68 fb 03 00 00       	push   $0x3fb
80107060:	e8 b7 ff ff ff       	call   8010701c <outb>
80107065:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107068:	6a 0c                	push   $0xc
8010706a:	68 f8 03 00 00       	push   $0x3f8
8010706f:	e8 a8 ff ff ff       	call   8010701c <outb>
80107074:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107077:	6a 00                	push   $0x0
80107079:	68 f9 03 00 00       	push   $0x3f9
8010707e:	e8 99 ff ff ff       	call   8010701c <outb>
80107083:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107086:	6a 03                	push   $0x3
80107088:	68 fb 03 00 00       	push   $0x3fb
8010708d:	e8 8a ff ff ff       	call   8010701c <outb>
80107092:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107095:	6a 00                	push   $0x0
80107097:	68 fc 03 00 00       	push   $0x3fc
8010709c:	e8 7b ff ff ff       	call   8010701c <outb>
801070a1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070a4:	6a 01                	push   $0x1
801070a6:	68 f9 03 00 00       	push   $0x3f9
801070ab:	e8 6c ff ff ff       	call   8010701c <outb>
801070b0:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070b3:	68 fd 03 00 00       	push   $0x3fd
801070b8:	e8 42 ff ff ff       	call   80106fff <inb>
801070bd:	83 c4 04             	add    $0x4,%esp
801070c0:	3c ff                	cmp    $0xff,%al
801070c2:	74 61                	je     80107125 <uartinit+0xe8>
    return;
  uart = 1;
801070c4:	c7 05 80 e0 18 80 01 	movl   $0x1,0x8018e080
801070cb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070ce:	68 fa 03 00 00       	push   $0x3fa
801070d3:	e8 27 ff ff ff       	call   80106fff <inb>
801070d8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801070db:	68 f8 03 00 00       	push   $0x3f8
801070e0:	e8 1a ff ff ff       	call   80106fff <inb>
801070e5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801070e8:	83 ec 08             	sub    $0x8,%esp
801070eb:	6a 00                	push   $0x0
801070ed:	6a 04                	push   $0x4
801070ef:	e8 18 b6 ff ff       	call   8010270c <ioapicenable>
801070f4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070f7:	c7 45 f4 88 b6 10 80 	movl   $0x8010b688,-0xc(%ebp)
801070fe:	eb 19                	jmp    80107119 <uartinit+0xdc>
    uartputc(*p);
80107100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107103:	0f b6 00             	movzbl (%eax),%eax
80107106:	0f be c0             	movsbl %al,%eax
80107109:	83 ec 0c             	sub    $0xc,%esp
8010710c:	50                   	push   %eax
8010710d:	e8 16 00 00 00       	call   80107128 <uartputc>
80107112:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107115:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711c:	0f b6 00             	movzbl (%eax),%eax
8010711f:	84 c0                	test   %al,%al
80107121:	75 dd                	jne    80107100 <uartinit+0xc3>
80107123:	eb 01                	jmp    80107126 <uartinit+0xe9>
    return;
80107125:	90                   	nop
}
80107126:	c9                   	leave
80107127:	c3                   	ret

80107128 <uartputc>:

void
uartputc(int c)
{
80107128:	f3 0f 1e fb          	endbr32
8010712c:	55                   	push   %ebp
8010712d:	89 e5                	mov    %esp,%ebp
8010712f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107132:	a1 80 e0 18 80       	mov    0x8018e080,%eax
80107137:	85 c0                	test   %eax,%eax
80107139:	74 53                	je     8010718e <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010713b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107142:	eb 11                	jmp    80107155 <uartputc+0x2d>
    microdelay(10);
80107144:	83 ec 0c             	sub    $0xc,%esp
80107147:	6a 0a                	push   $0xa
80107149:	e8 f6 ba ff ff       	call   80102c44 <microdelay>
8010714e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107151:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107155:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107159:	7f 1a                	jg     80107175 <uartputc+0x4d>
8010715b:	83 ec 0c             	sub    $0xc,%esp
8010715e:	68 fd 03 00 00       	push   $0x3fd
80107163:	e8 97 fe ff ff       	call   80106fff <inb>
80107168:	83 c4 10             	add    $0x10,%esp
8010716b:	0f b6 c0             	movzbl %al,%eax
8010716e:	83 e0 20             	and    $0x20,%eax
80107171:	85 c0                	test   %eax,%eax
80107173:	74 cf                	je     80107144 <uartputc+0x1c>
  outb(COM1+0, c);
80107175:	8b 45 08             	mov    0x8(%ebp),%eax
80107178:	0f b6 c0             	movzbl %al,%eax
8010717b:	83 ec 08             	sub    $0x8,%esp
8010717e:	50                   	push   %eax
8010717f:	68 f8 03 00 00       	push   $0x3f8
80107184:	e8 93 fe ff ff       	call   8010701c <outb>
80107189:	83 c4 10             	add    $0x10,%esp
8010718c:	eb 01                	jmp    8010718f <uartputc+0x67>
    return;
8010718e:	90                   	nop
}
8010718f:	c9                   	leave
80107190:	c3                   	ret

80107191 <uartgetc>:

static int
uartgetc(void)
{
80107191:	f3 0f 1e fb          	endbr32
80107195:	55                   	push   %ebp
80107196:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107198:	a1 80 e0 18 80       	mov    0x8018e080,%eax
8010719d:	85 c0                	test   %eax,%eax
8010719f:	75 07                	jne    801071a8 <uartgetc+0x17>
    return -1;
801071a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a6:	eb 2e                	jmp    801071d6 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801071a8:	68 fd 03 00 00       	push   $0x3fd
801071ad:	e8 4d fe ff ff       	call   80106fff <inb>
801071b2:	83 c4 04             	add    $0x4,%esp
801071b5:	0f b6 c0             	movzbl %al,%eax
801071b8:	83 e0 01             	and    $0x1,%eax
801071bb:	85 c0                	test   %eax,%eax
801071bd:	75 07                	jne    801071c6 <uartgetc+0x35>
    return -1;
801071bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c4:	eb 10                	jmp    801071d6 <uartgetc+0x45>
  return inb(COM1+0);
801071c6:	68 f8 03 00 00       	push   $0x3f8
801071cb:	e8 2f fe ff ff       	call   80106fff <inb>
801071d0:	83 c4 04             	add    $0x4,%esp
801071d3:	0f b6 c0             	movzbl %al,%eax
}
801071d6:	c9                   	leave
801071d7:	c3                   	ret

801071d8 <uartintr>:

void
uartintr(void)
{
801071d8:	f3 0f 1e fb          	endbr32
801071dc:	55                   	push   %ebp
801071dd:	89 e5                	mov    %esp,%ebp
801071df:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801071e2:	83 ec 0c             	sub    $0xc,%esp
801071e5:	68 91 71 10 80       	push   $0x80107191
801071ea:	e8 11 96 ff ff       	call   80100800 <consoleintr>
801071ef:	83 c4 10             	add    $0x10,%esp
}
801071f2:	90                   	nop
801071f3:	c9                   	leave
801071f4:	c3                   	ret

801071f5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $0
801071f7:	6a 00                	push   $0x0
  jmp alltraps
801071f9:	e9 7c f8 ff ff       	jmp    80106a7a <alltraps>

801071fe <vector1>:
.globl vector1
vector1:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $1
80107200:	6a 01                	push   $0x1
  jmp alltraps
80107202:	e9 73 f8 ff ff       	jmp    80106a7a <alltraps>

80107207 <vector2>:
.globl vector2
vector2:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $2
80107209:	6a 02                	push   $0x2
  jmp alltraps
8010720b:	e9 6a f8 ff ff       	jmp    80106a7a <alltraps>

80107210 <vector3>:
.globl vector3
vector3:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $3
80107212:	6a 03                	push   $0x3
  jmp alltraps
80107214:	e9 61 f8 ff ff       	jmp    80106a7a <alltraps>

80107219 <vector4>:
.globl vector4
vector4:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $4
8010721b:	6a 04                	push   $0x4
  jmp alltraps
8010721d:	e9 58 f8 ff ff       	jmp    80106a7a <alltraps>

80107222 <vector5>:
.globl vector5
vector5:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $5
80107224:	6a 05                	push   $0x5
  jmp alltraps
80107226:	e9 4f f8 ff ff       	jmp    80106a7a <alltraps>

8010722b <vector6>:
.globl vector6
vector6:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $6
8010722d:	6a 06                	push   $0x6
  jmp alltraps
8010722f:	e9 46 f8 ff ff       	jmp    80106a7a <alltraps>

80107234 <vector7>:
.globl vector7
vector7:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $7
80107236:	6a 07                	push   $0x7
  jmp alltraps
80107238:	e9 3d f8 ff ff       	jmp    80106a7a <alltraps>

8010723d <vector8>:
.globl vector8
vector8:
  pushl $8
8010723d:	6a 08                	push   $0x8
  jmp alltraps
8010723f:	e9 36 f8 ff ff       	jmp    80106a7a <alltraps>

80107244 <vector9>:
.globl vector9
vector9:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $9
80107246:	6a 09                	push   $0x9
  jmp alltraps
80107248:	e9 2d f8 ff ff       	jmp    80106a7a <alltraps>

8010724d <vector10>:
.globl vector10
vector10:
  pushl $10
8010724d:	6a 0a                	push   $0xa
  jmp alltraps
8010724f:	e9 26 f8 ff ff       	jmp    80106a7a <alltraps>

80107254 <vector11>:
.globl vector11
vector11:
  pushl $11
80107254:	6a 0b                	push   $0xb
  jmp alltraps
80107256:	e9 1f f8 ff ff       	jmp    80106a7a <alltraps>

8010725b <vector12>:
.globl vector12
vector12:
  pushl $12
8010725b:	6a 0c                	push   $0xc
  jmp alltraps
8010725d:	e9 18 f8 ff ff       	jmp    80106a7a <alltraps>

80107262 <vector13>:
.globl vector13
vector13:
  pushl $13
80107262:	6a 0d                	push   $0xd
  jmp alltraps
80107264:	e9 11 f8 ff ff       	jmp    80106a7a <alltraps>

80107269 <vector14>:
.globl vector14
vector14:
  pushl $14
80107269:	6a 0e                	push   $0xe
  jmp alltraps
8010726b:	e9 0a f8 ff ff       	jmp    80106a7a <alltraps>

80107270 <vector15>:
.globl vector15
vector15:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $15
80107272:	6a 0f                	push   $0xf
  jmp alltraps
80107274:	e9 01 f8 ff ff       	jmp    80106a7a <alltraps>

80107279 <vector16>:
.globl vector16
vector16:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $16
8010727b:	6a 10                	push   $0x10
  jmp alltraps
8010727d:	e9 f8 f7 ff ff       	jmp    80106a7a <alltraps>

80107282 <vector17>:
.globl vector17
vector17:
  pushl $17
80107282:	6a 11                	push   $0x11
  jmp alltraps
80107284:	e9 f1 f7 ff ff       	jmp    80106a7a <alltraps>

80107289 <vector18>:
.globl vector18
vector18:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $18
8010728b:	6a 12                	push   $0x12
  jmp alltraps
8010728d:	e9 e8 f7 ff ff       	jmp    80106a7a <alltraps>

80107292 <vector19>:
.globl vector19
vector19:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $19
80107294:	6a 13                	push   $0x13
  jmp alltraps
80107296:	e9 df f7 ff ff       	jmp    80106a7a <alltraps>

8010729b <vector20>:
.globl vector20
vector20:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $20
8010729d:	6a 14                	push   $0x14
  jmp alltraps
8010729f:	e9 d6 f7 ff ff       	jmp    80106a7a <alltraps>

801072a4 <vector21>:
.globl vector21
vector21:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $21
801072a6:	6a 15                	push   $0x15
  jmp alltraps
801072a8:	e9 cd f7 ff ff       	jmp    80106a7a <alltraps>

801072ad <vector22>:
.globl vector22
vector22:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $22
801072af:	6a 16                	push   $0x16
  jmp alltraps
801072b1:	e9 c4 f7 ff ff       	jmp    80106a7a <alltraps>

801072b6 <vector23>:
.globl vector23
vector23:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $23
801072b8:	6a 17                	push   $0x17
  jmp alltraps
801072ba:	e9 bb f7 ff ff       	jmp    80106a7a <alltraps>

801072bf <vector24>:
.globl vector24
vector24:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $24
801072c1:	6a 18                	push   $0x18
  jmp alltraps
801072c3:	e9 b2 f7 ff ff       	jmp    80106a7a <alltraps>

801072c8 <vector25>:
.globl vector25
vector25:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $25
801072ca:	6a 19                	push   $0x19
  jmp alltraps
801072cc:	e9 a9 f7 ff ff       	jmp    80106a7a <alltraps>

801072d1 <vector26>:
.globl vector26
vector26:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $26
801072d3:	6a 1a                	push   $0x1a
  jmp alltraps
801072d5:	e9 a0 f7 ff ff       	jmp    80106a7a <alltraps>

801072da <vector27>:
.globl vector27
vector27:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $27
801072dc:	6a 1b                	push   $0x1b
  jmp alltraps
801072de:	e9 97 f7 ff ff       	jmp    80106a7a <alltraps>

801072e3 <vector28>:
.globl vector28
vector28:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $28
801072e5:	6a 1c                	push   $0x1c
  jmp alltraps
801072e7:	e9 8e f7 ff ff       	jmp    80106a7a <alltraps>

801072ec <vector29>:
.globl vector29
vector29:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $29
801072ee:	6a 1d                	push   $0x1d
  jmp alltraps
801072f0:	e9 85 f7 ff ff       	jmp    80106a7a <alltraps>

801072f5 <vector30>:
.globl vector30
vector30:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $30
801072f7:	6a 1e                	push   $0x1e
  jmp alltraps
801072f9:	e9 7c f7 ff ff       	jmp    80106a7a <alltraps>

801072fe <vector31>:
.globl vector31
vector31:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $31
80107300:	6a 1f                	push   $0x1f
  jmp alltraps
80107302:	e9 73 f7 ff ff       	jmp    80106a7a <alltraps>

80107307 <vector32>:
.globl vector32
vector32:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $32
80107309:	6a 20                	push   $0x20
  jmp alltraps
8010730b:	e9 6a f7 ff ff       	jmp    80106a7a <alltraps>

80107310 <vector33>:
.globl vector33
vector33:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $33
80107312:	6a 21                	push   $0x21
  jmp alltraps
80107314:	e9 61 f7 ff ff       	jmp    80106a7a <alltraps>

80107319 <vector34>:
.globl vector34
vector34:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $34
8010731b:	6a 22                	push   $0x22
  jmp alltraps
8010731d:	e9 58 f7 ff ff       	jmp    80106a7a <alltraps>

80107322 <vector35>:
.globl vector35
vector35:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $35
80107324:	6a 23                	push   $0x23
  jmp alltraps
80107326:	e9 4f f7 ff ff       	jmp    80106a7a <alltraps>

8010732b <vector36>:
.globl vector36
vector36:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $36
8010732d:	6a 24                	push   $0x24
  jmp alltraps
8010732f:	e9 46 f7 ff ff       	jmp    80106a7a <alltraps>

80107334 <vector37>:
.globl vector37
vector37:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $37
80107336:	6a 25                	push   $0x25
  jmp alltraps
80107338:	e9 3d f7 ff ff       	jmp    80106a7a <alltraps>

8010733d <vector38>:
.globl vector38
vector38:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $38
8010733f:	6a 26                	push   $0x26
  jmp alltraps
80107341:	e9 34 f7 ff ff       	jmp    80106a7a <alltraps>

80107346 <vector39>:
.globl vector39
vector39:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $39
80107348:	6a 27                	push   $0x27
  jmp alltraps
8010734a:	e9 2b f7 ff ff       	jmp    80106a7a <alltraps>

8010734f <vector40>:
.globl vector40
vector40:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $40
80107351:	6a 28                	push   $0x28
  jmp alltraps
80107353:	e9 22 f7 ff ff       	jmp    80106a7a <alltraps>

80107358 <vector41>:
.globl vector41
vector41:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $41
8010735a:	6a 29                	push   $0x29
  jmp alltraps
8010735c:	e9 19 f7 ff ff       	jmp    80106a7a <alltraps>

80107361 <vector42>:
.globl vector42
vector42:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $42
80107363:	6a 2a                	push   $0x2a
  jmp alltraps
80107365:	e9 10 f7 ff ff       	jmp    80106a7a <alltraps>

8010736a <vector43>:
.globl vector43
vector43:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $43
8010736c:	6a 2b                	push   $0x2b
  jmp alltraps
8010736e:	e9 07 f7 ff ff       	jmp    80106a7a <alltraps>

80107373 <vector44>:
.globl vector44
vector44:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $44
80107375:	6a 2c                	push   $0x2c
  jmp alltraps
80107377:	e9 fe f6 ff ff       	jmp    80106a7a <alltraps>

8010737c <vector45>:
.globl vector45
vector45:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $45
8010737e:	6a 2d                	push   $0x2d
  jmp alltraps
80107380:	e9 f5 f6 ff ff       	jmp    80106a7a <alltraps>

80107385 <vector46>:
.globl vector46
vector46:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $46
80107387:	6a 2e                	push   $0x2e
  jmp alltraps
80107389:	e9 ec f6 ff ff       	jmp    80106a7a <alltraps>

8010738e <vector47>:
.globl vector47
vector47:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $47
80107390:	6a 2f                	push   $0x2f
  jmp alltraps
80107392:	e9 e3 f6 ff ff       	jmp    80106a7a <alltraps>

80107397 <vector48>:
.globl vector48
vector48:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $48
80107399:	6a 30                	push   $0x30
  jmp alltraps
8010739b:	e9 da f6 ff ff       	jmp    80106a7a <alltraps>

801073a0 <vector49>:
.globl vector49
vector49:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $49
801073a2:	6a 31                	push   $0x31
  jmp alltraps
801073a4:	e9 d1 f6 ff ff       	jmp    80106a7a <alltraps>

801073a9 <vector50>:
.globl vector50
vector50:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $50
801073ab:	6a 32                	push   $0x32
  jmp alltraps
801073ad:	e9 c8 f6 ff ff       	jmp    80106a7a <alltraps>

801073b2 <vector51>:
.globl vector51
vector51:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $51
801073b4:	6a 33                	push   $0x33
  jmp alltraps
801073b6:	e9 bf f6 ff ff       	jmp    80106a7a <alltraps>

801073bb <vector52>:
.globl vector52
vector52:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $52
801073bd:	6a 34                	push   $0x34
  jmp alltraps
801073bf:	e9 b6 f6 ff ff       	jmp    80106a7a <alltraps>

801073c4 <vector53>:
.globl vector53
vector53:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $53
801073c6:	6a 35                	push   $0x35
  jmp alltraps
801073c8:	e9 ad f6 ff ff       	jmp    80106a7a <alltraps>

801073cd <vector54>:
.globl vector54
vector54:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $54
801073cf:	6a 36                	push   $0x36
  jmp alltraps
801073d1:	e9 a4 f6 ff ff       	jmp    80106a7a <alltraps>

801073d6 <vector55>:
.globl vector55
vector55:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $55
801073d8:	6a 37                	push   $0x37
  jmp alltraps
801073da:	e9 9b f6 ff ff       	jmp    80106a7a <alltraps>

801073df <vector56>:
.globl vector56
vector56:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $56
801073e1:	6a 38                	push   $0x38
  jmp alltraps
801073e3:	e9 92 f6 ff ff       	jmp    80106a7a <alltraps>

801073e8 <vector57>:
.globl vector57
vector57:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $57
801073ea:	6a 39                	push   $0x39
  jmp alltraps
801073ec:	e9 89 f6 ff ff       	jmp    80106a7a <alltraps>

801073f1 <vector58>:
.globl vector58
vector58:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $58
801073f3:	6a 3a                	push   $0x3a
  jmp alltraps
801073f5:	e9 80 f6 ff ff       	jmp    80106a7a <alltraps>

801073fa <vector59>:
.globl vector59
vector59:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $59
801073fc:	6a 3b                	push   $0x3b
  jmp alltraps
801073fe:	e9 77 f6 ff ff       	jmp    80106a7a <alltraps>

80107403 <vector60>:
.globl vector60
vector60:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $60
80107405:	6a 3c                	push   $0x3c
  jmp alltraps
80107407:	e9 6e f6 ff ff       	jmp    80106a7a <alltraps>

8010740c <vector61>:
.globl vector61
vector61:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $61
8010740e:	6a 3d                	push   $0x3d
  jmp alltraps
80107410:	e9 65 f6 ff ff       	jmp    80106a7a <alltraps>

80107415 <vector62>:
.globl vector62
vector62:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $62
80107417:	6a 3e                	push   $0x3e
  jmp alltraps
80107419:	e9 5c f6 ff ff       	jmp    80106a7a <alltraps>

8010741e <vector63>:
.globl vector63
vector63:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $63
80107420:	6a 3f                	push   $0x3f
  jmp alltraps
80107422:	e9 53 f6 ff ff       	jmp    80106a7a <alltraps>

80107427 <vector64>:
.globl vector64
vector64:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $64
80107429:	6a 40                	push   $0x40
  jmp alltraps
8010742b:	e9 4a f6 ff ff       	jmp    80106a7a <alltraps>

80107430 <vector65>:
.globl vector65
vector65:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $65
80107432:	6a 41                	push   $0x41
  jmp alltraps
80107434:	e9 41 f6 ff ff       	jmp    80106a7a <alltraps>

80107439 <vector66>:
.globl vector66
vector66:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $66
8010743b:	6a 42                	push   $0x42
  jmp alltraps
8010743d:	e9 38 f6 ff ff       	jmp    80106a7a <alltraps>

80107442 <vector67>:
.globl vector67
vector67:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $67
80107444:	6a 43                	push   $0x43
  jmp alltraps
80107446:	e9 2f f6 ff ff       	jmp    80106a7a <alltraps>

8010744b <vector68>:
.globl vector68
vector68:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $68
8010744d:	6a 44                	push   $0x44
  jmp alltraps
8010744f:	e9 26 f6 ff ff       	jmp    80106a7a <alltraps>

80107454 <vector69>:
.globl vector69
vector69:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $69
80107456:	6a 45                	push   $0x45
  jmp alltraps
80107458:	e9 1d f6 ff ff       	jmp    80106a7a <alltraps>

8010745d <vector70>:
.globl vector70
vector70:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $70
8010745f:	6a 46                	push   $0x46
  jmp alltraps
80107461:	e9 14 f6 ff ff       	jmp    80106a7a <alltraps>

80107466 <vector71>:
.globl vector71
vector71:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $71
80107468:	6a 47                	push   $0x47
  jmp alltraps
8010746a:	e9 0b f6 ff ff       	jmp    80106a7a <alltraps>

8010746f <vector72>:
.globl vector72
vector72:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $72
80107471:	6a 48                	push   $0x48
  jmp alltraps
80107473:	e9 02 f6 ff ff       	jmp    80106a7a <alltraps>

80107478 <vector73>:
.globl vector73
vector73:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $73
8010747a:	6a 49                	push   $0x49
  jmp alltraps
8010747c:	e9 f9 f5 ff ff       	jmp    80106a7a <alltraps>

80107481 <vector74>:
.globl vector74
vector74:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $74
80107483:	6a 4a                	push   $0x4a
  jmp alltraps
80107485:	e9 f0 f5 ff ff       	jmp    80106a7a <alltraps>

8010748a <vector75>:
.globl vector75
vector75:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $75
8010748c:	6a 4b                	push   $0x4b
  jmp alltraps
8010748e:	e9 e7 f5 ff ff       	jmp    80106a7a <alltraps>

80107493 <vector76>:
.globl vector76
vector76:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $76
80107495:	6a 4c                	push   $0x4c
  jmp alltraps
80107497:	e9 de f5 ff ff       	jmp    80106a7a <alltraps>

8010749c <vector77>:
.globl vector77
vector77:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $77
8010749e:	6a 4d                	push   $0x4d
  jmp alltraps
801074a0:	e9 d5 f5 ff ff       	jmp    80106a7a <alltraps>

801074a5 <vector78>:
.globl vector78
vector78:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $78
801074a7:	6a 4e                	push   $0x4e
  jmp alltraps
801074a9:	e9 cc f5 ff ff       	jmp    80106a7a <alltraps>

801074ae <vector79>:
.globl vector79
vector79:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $79
801074b0:	6a 4f                	push   $0x4f
  jmp alltraps
801074b2:	e9 c3 f5 ff ff       	jmp    80106a7a <alltraps>

801074b7 <vector80>:
.globl vector80
vector80:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $80
801074b9:	6a 50                	push   $0x50
  jmp alltraps
801074bb:	e9 ba f5 ff ff       	jmp    80106a7a <alltraps>

801074c0 <vector81>:
.globl vector81
vector81:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $81
801074c2:	6a 51                	push   $0x51
  jmp alltraps
801074c4:	e9 b1 f5 ff ff       	jmp    80106a7a <alltraps>

801074c9 <vector82>:
.globl vector82
vector82:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $82
801074cb:	6a 52                	push   $0x52
  jmp alltraps
801074cd:	e9 a8 f5 ff ff       	jmp    80106a7a <alltraps>

801074d2 <vector83>:
.globl vector83
vector83:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $83
801074d4:	6a 53                	push   $0x53
  jmp alltraps
801074d6:	e9 9f f5 ff ff       	jmp    80106a7a <alltraps>

801074db <vector84>:
.globl vector84
vector84:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $84
801074dd:	6a 54                	push   $0x54
  jmp alltraps
801074df:	e9 96 f5 ff ff       	jmp    80106a7a <alltraps>

801074e4 <vector85>:
.globl vector85
vector85:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $85
801074e6:	6a 55                	push   $0x55
  jmp alltraps
801074e8:	e9 8d f5 ff ff       	jmp    80106a7a <alltraps>

801074ed <vector86>:
.globl vector86
vector86:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $86
801074ef:	6a 56                	push   $0x56
  jmp alltraps
801074f1:	e9 84 f5 ff ff       	jmp    80106a7a <alltraps>

801074f6 <vector87>:
.globl vector87
vector87:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $87
801074f8:	6a 57                	push   $0x57
  jmp alltraps
801074fa:	e9 7b f5 ff ff       	jmp    80106a7a <alltraps>

801074ff <vector88>:
.globl vector88
vector88:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $88
80107501:	6a 58                	push   $0x58
  jmp alltraps
80107503:	e9 72 f5 ff ff       	jmp    80106a7a <alltraps>

80107508 <vector89>:
.globl vector89
vector89:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $89
8010750a:	6a 59                	push   $0x59
  jmp alltraps
8010750c:	e9 69 f5 ff ff       	jmp    80106a7a <alltraps>

80107511 <vector90>:
.globl vector90
vector90:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $90
80107513:	6a 5a                	push   $0x5a
  jmp alltraps
80107515:	e9 60 f5 ff ff       	jmp    80106a7a <alltraps>

8010751a <vector91>:
.globl vector91
vector91:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $91
8010751c:	6a 5b                	push   $0x5b
  jmp alltraps
8010751e:	e9 57 f5 ff ff       	jmp    80106a7a <alltraps>

80107523 <vector92>:
.globl vector92
vector92:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $92
80107525:	6a 5c                	push   $0x5c
  jmp alltraps
80107527:	e9 4e f5 ff ff       	jmp    80106a7a <alltraps>

8010752c <vector93>:
.globl vector93
vector93:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $93
8010752e:	6a 5d                	push   $0x5d
  jmp alltraps
80107530:	e9 45 f5 ff ff       	jmp    80106a7a <alltraps>

80107535 <vector94>:
.globl vector94
vector94:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $94
80107537:	6a 5e                	push   $0x5e
  jmp alltraps
80107539:	e9 3c f5 ff ff       	jmp    80106a7a <alltraps>

8010753e <vector95>:
.globl vector95
vector95:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $95
80107540:	6a 5f                	push   $0x5f
  jmp alltraps
80107542:	e9 33 f5 ff ff       	jmp    80106a7a <alltraps>

80107547 <vector96>:
.globl vector96
vector96:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $96
80107549:	6a 60                	push   $0x60
  jmp alltraps
8010754b:	e9 2a f5 ff ff       	jmp    80106a7a <alltraps>

80107550 <vector97>:
.globl vector97
vector97:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $97
80107552:	6a 61                	push   $0x61
  jmp alltraps
80107554:	e9 21 f5 ff ff       	jmp    80106a7a <alltraps>

80107559 <vector98>:
.globl vector98
vector98:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $98
8010755b:	6a 62                	push   $0x62
  jmp alltraps
8010755d:	e9 18 f5 ff ff       	jmp    80106a7a <alltraps>

80107562 <vector99>:
.globl vector99
vector99:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $99
80107564:	6a 63                	push   $0x63
  jmp alltraps
80107566:	e9 0f f5 ff ff       	jmp    80106a7a <alltraps>

8010756b <vector100>:
.globl vector100
vector100:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $100
8010756d:	6a 64                	push   $0x64
  jmp alltraps
8010756f:	e9 06 f5 ff ff       	jmp    80106a7a <alltraps>

80107574 <vector101>:
.globl vector101
vector101:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $101
80107576:	6a 65                	push   $0x65
  jmp alltraps
80107578:	e9 fd f4 ff ff       	jmp    80106a7a <alltraps>

8010757d <vector102>:
.globl vector102
vector102:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $102
8010757f:	6a 66                	push   $0x66
  jmp alltraps
80107581:	e9 f4 f4 ff ff       	jmp    80106a7a <alltraps>

80107586 <vector103>:
.globl vector103
vector103:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $103
80107588:	6a 67                	push   $0x67
  jmp alltraps
8010758a:	e9 eb f4 ff ff       	jmp    80106a7a <alltraps>

8010758f <vector104>:
.globl vector104
vector104:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $104
80107591:	6a 68                	push   $0x68
  jmp alltraps
80107593:	e9 e2 f4 ff ff       	jmp    80106a7a <alltraps>

80107598 <vector105>:
.globl vector105
vector105:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $105
8010759a:	6a 69                	push   $0x69
  jmp alltraps
8010759c:	e9 d9 f4 ff ff       	jmp    80106a7a <alltraps>

801075a1 <vector106>:
.globl vector106
vector106:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $106
801075a3:	6a 6a                	push   $0x6a
  jmp alltraps
801075a5:	e9 d0 f4 ff ff       	jmp    80106a7a <alltraps>

801075aa <vector107>:
.globl vector107
vector107:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $107
801075ac:	6a 6b                	push   $0x6b
  jmp alltraps
801075ae:	e9 c7 f4 ff ff       	jmp    80106a7a <alltraps>

801075b3 <vector108>:
.globl vector108
vector108:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $108
801075b5:	6a 6c                	push   $0x6c
  jmp alltraps
801075b7:	e9 be f4 ff ff       	jmp    80106a7a <alltraps>

801075bc <vector109>:
.globl vector109
vector109:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $109
801075be:	6a 6d                	push   $0x6d
  jmp alltraps
801075c0:	e9 b5 f4 ff ff       	jmp    80106a7a <alltraps>

801075c5 <vector110>:
.globl vector110
vector110:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $110
801075c7:	6a 6e                	push   $0x6e
  jmp alltraps
801075c9:	e9 ac f4 ff ff       	jmp    80106a7a <alltraps>

801075ce <vector111>:
.globl vector111
vector111:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $111
801075d0:	6a 6f                	push   $0x6f
  jmp alltraps
801075d2:	e9 a3 f4 ff ff       	jmp    80106a7a <alltraps>

801075d7 <vector112>:
.globl vector112
vector112:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $112
801075d9:	6a 70                	push   $0x70
  jmp alltraps
801075db:	e9 9a f4 ff ff       	jmp    80106a7a <alltraps>

801075e0 <vector113>:
.globl vector113
vector113:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $113
801075e2:	6a 71                	push   $0x71
  jmp alltraps
801075e4:	e9 91 f4 ff ff       	jmp    80106a7a <alltraps>

801075e9 <vector114>:
.globl vector114
vector114:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $114
801075eb:	6a 72                	push   $0x72
  jmp alltraps
801075ed:	e9 88 f4 ff ff       	jmp    80106a7a <alltraps>

801075f2 <vector115>:
.globl vector115
vector115:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $115
801075f4:	6a 73                	push   $0x73
  jmp alltraps
801075f6:	e9 7f f4 ff ff       	jmp    80106a7a <alltraps>

801075fb <vector116>:
.globl vector116
vector116:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $116
801075fd:	6a 74                	push   $0x74
  jmp alltraps
801075ff:	e9 76 f4 ff ff       	jmp    80106a7a <alltraps>

80107604 <vector117>:
.globl vector117
vector117:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $117
80107606:	6a 75                	push   $0x75
  jmp alltraps
80107608:	e9 6d f4 ff ff       	jmp    80106a7a <alltraps>

8010760d <vector118>:
.globl vector118
vector118:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $118
8010760f:	6a 76                	push   $0x76
  jmp alltraps
80107611:	e9 64 f4 ff ff       	jmp    80106a7a <alltraps>

80107616 <vector119>:
.globl vector119
vector119:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $119
80107618:	6a 77                	push   $0x77
  jmp alltraps
8010761a:	e9 5b f4 ff ff       	jmp    80106a7a <alltraps>

8010761f <vector120>:
.globl vector120
vector120:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $120
80107621:	6a 78                	push   $0x78
  jmp alltraps
80107623:	e9 52 f4 ff ff       	jmp    80106a7a <alltraps>

80107628 <vector121>:
.globl vector121
vector121:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $121
8010762a:	6a 79                	push   $0x79
  jmp alltraps
8010762c:	e9 49 f4 ff ff       	jmp    80106a7a <alltraps>

80107631 <vector122>:
.globl vector122
vector122:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $122
80107633:	6a 7a                	push   $0x7a
  jmp alltraps
80107635:	e9 40 f4 ff ff       	jmp    80106a7a <alltraps>

8010763a <vector123>:
.globl vector123
vector123:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $123
8010763c:	6a 7b                	push   $0x7b
  jmp alltraps
8010763e:	e9 37 f4 ff ff       	jmp    80106a7a <alltraps>

80107643 <vector124>:
.globl vector124
vector124:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $124
80107645:	6a 7c                	push   $0x7c
  jmp alltraps
80107647:	e9 2e f4 ff ff       	jmp    80106a7a <alltraps>

8010764c <vector125>:
.globl vector125
vector125:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $125
8010764e:	6a 7d                	push   $0x7d
  jmp alltraps
80107650:	e9 25 f4 ff ff       	jmp    80106a7a <alltraps>

80107655 <vector126>:
.globl vector126
vector126:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $126
80107657:	6a 7e                	push   $0x7e
  jmp alltraps
80107659:	e9 1c f4 ff ff       	jmp    80106a7a <alltraps>

8010765e <vector127>:
.globl vector127
vector127:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $127
80107660:	6a 7f                	push   $0x7f
  jmp alltraps
80107662:	e9 13 f4 ff ff       	jmp    80106a7a <alltraps>

80107667 <vector128>:
.globl vector128
vector128:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $128
80107669:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010766e:	e9 07 f4 ff ff       	jmp    80106a7a <alltraps>

80107673 <vector129>:
.globl vector129
vector129:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $129
80107675:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010767a:	e9 fb f3 ff ff       	jmp    80106a7a <alltraps>

8010767f <vector130>:
.globl vector130
vector130:
  pushl $0
8010767f:	6a 00                	push   $0x0
  pushl $130
80107681:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107686:	e9 ef f3 ff ff       	jmp    80106a7a <alltraps>

8010768b <vector131>:
.globl vector131
vector131:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $131
8010768d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107692:	e9 e3 f3 ff ff       	jmp    80106a7a <alltraps>

80107697 <vector132>:
.globl vector132
vector132:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $132
80107699:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010769e:	e9 d7 f3 ff ff       	jmp    80106a7a <alltraps>

801076a3 <vector133>:
.globl vector133
vector133:
  pushl $0
801076a3:	6a 00                	push   $0x0
  pushl $133
801076a5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076aa:	e9 cb f3 ff ff       	jmp    80106a7a <alltraps>

801076af <vector134>:
.globl vector134
vector134:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $134
801076b1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076b6:	e9 bf f3 ff ff       	jmp    80106a7a <alltraps>

801076bb <vector135>:
.globl vector135
vector135:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $135
801076bd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801076c2:	e9 b3 f3 ff ff       	jmp    80106a7a <alltraps>

801076c7 <vector136>:
.globl vector136
vector136:
  pushl $0
801076c7:	6a 00                	push   $0x0
  pushl $136
801076c9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801076ce:	e9 a7 f3 ff ff       	jmp    80106a7a <alltraps>

801076d3 <vector137>:
.globl vector137
vector137:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $137
801076d5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801076da:	e9 9b f3 ff ff       	jmp    80106a7a <alltraps>

801076df <vector138>:
.globl vector138
vector138:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $138
801076e1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801076e6:	e9 8f f3 ff ff       	jmp    80106a7a <alltraps>

801076eb <vector139>:
.globl vector139
vector139:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $139
801076ed:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801076f2:	e9 83 f3 ff ff       	jmp    80106a7a <alltraps>

801076f7 <vector140>:
.globl vector140
vector140:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $140
801076f9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801076fe:	e9 77 f3 ff ff       	jmp    80106a7a <alltraps>

80107703 <vector141>:
.globl vector141
vector141:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $141
80107705:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010770a:	e9 6b f3 ff ff       	jmp    80106a7a <alltraps>

8010770f <vector142>:
.globl vector142
vector142:
  pushl $0
8010770f:	6a 00                	push   $0x0
  pushl $142
80107711:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107716:	e9 5f f3 ff ff       	jmp    80106a7a <alltraps>

8010771b <vector143>:
.globl vector143
vector143:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $143
8010771d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107722:	e9 53 f3 ff ff       	jmp    80106a7a <alltraps>

80107727 <vector144>:
.globl vector144
vector144:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $144
80107729:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010772e:	e9 47 f3 ff ff       	jmp    80106a7a <alltraps>

80107733 <vector145>:
.globl vector145
vector145:
  pushl $0
80107733:	6a 00                	push   $0x0
  pushl $145
80107735:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010773a:	e9 3b f3 ff ff       	jmp    80106a7a <alltraps>

8010773f <vector146>:
.globl vector146
vector146:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $146
80107741:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107746:	e9 2f f3 ff ff       	jmp    80106a7a <alltraps>

8010774b <vector147>:
.globl vector147
vector147:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $147
8010774d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107752:	e9 23 f3 ff ff       	jmp    80106a7a <alltraps>

80107757 <vector148>:
.globl vector148
vector148:
  pushl $0
80107757:	6a 00                	push   $0x0
  pushl $148
80107759:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010775e:	e9 17 f3 ff ff       	jmp    80106a7a <alltraps>

80107763 <vector149>:
.globl vector149
vector149:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $149
80107765:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010776a:	e9 0b f3 ff ff       	jmp    80106a7a <alltraps>

8010776f <vector150>:
.globl vector150
vector150:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $150
80107771:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107776:	e9 ff f2 ff ff       	jmp    80106a7a <alltraps>

8010777b <vector151>:
.globl vector151
vector151:
  pushl $0
8010777b:	6a 00                	push   $0x0
  pushl $151
8010777d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107782:	e9 f3 f2 ff ff       	jmp    80106a7a <alltraps>

80107787 <vector152>:
.globl vector152
vector152:
  pushl $0
80107787:	6a 00                	push   $0x0
  pushl $152
80107789:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010778e:	e9 e7 f2 ff ff       	jmp    80106a7a <alltraps>

80107793 <vector153>:
.globl vector153
vector153:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $153
80107795:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010779a:	e9 db f2 ff ff       	jmp    80106a7a <alltraps>

8010779f <vector154>:
.globl vector154
vector154:
  pushl $0
8010779f:	6a 00                	push   $0x0
  pushl $154
801077a1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077a6:	e9 cf f2 ff ff       	jmp    80106a7a <alltraps>

801077ab <vector155>:
.globl vector155
vector155:
  pushl $0
801077ab:	6a 00                	push   $0x0
  pushl $155
801077ad:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077b2:	e9 c3 f2 ff ff       	jmp    80106a7a <alltraps>

801077b7 <vector156>:
.globl vector156
vector156:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $156
801077b9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801077be:	e9 b7 f2 ff ff       	jmp    80106a7a <alltraps>

801077c3 <vector157>:
.globl vector157
vector157:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $157
801077c5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801077ca:	e9 ab f2 ff ff       	jmp    80106a7a <alltraps>

801077cf <vector158>:
.globl vector158
vector158:
  pushl $0
801077cf:	6a 00                	push   $0x0
  pushl $158
801077d1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801077d6:	e9 9f f2 ff ff       	jmp    80106a7a <alltraps>

801077db <vector159>:
.globl vector159
vector159:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $159
801077dd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801077e2:	e9 93 f2 ff ff       	jmp    80106a7a <alltraps>

801077e7 <vector160>:
.globl vector160
vector160:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $160
801077e9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801077ee:	e9 87 f2 ff ff       	jmp    80106a7a <alltraps>

801077f3 <vector161>:
.globl vector161
vector161:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $161
801077f5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801077fa:	e9 7b f2 ff ff       	jmp    80106a7a <alltraps>

801077ff <vector162>:
.globl vector162
vector162:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $162
80107801:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107806:	e9 6f f2 ff ff       	jmp    80106a7a <alltraps>

8010780b <vector163>:
.globl vector163
vector163:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $163
8010780d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107812:	e9 63 f2 ff ff       	jmp    80106a7a <alltraps>

80107817 <vector164>:
.globl vector164
vector164:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $164
80107819:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010781e:	e9 57 f2 ff ff       	jmp    80106a7a <alltraps>

80107823 <vector165>:
.globl vector165
vector165:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $165
80107825:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010782a:	e9 4b f2 ff ff       	jmp    80106a7a <alltraps>

8010782f <vector166>:
.globl vector166
vector166:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $166
80107831:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107836:	e9 3f f2 ff ff       	jmp    80106a7a <alltraps>

8010783b <vector167>:
.globl vector167
vector167:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $167
8010783d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107842:	e9 33 f2 ff ff       	jmp    80106a7a <alltraps>

80107847 <vector168>:
.globl vector168
vector168:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $168
80107849:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010784e:	e9 27 f2 ff ff       	jmp    80106a7a <alltraps>

80107853 <vector169>:
.globl vector169
vector169:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $169
80107855:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010785a:	e9 1b f2 ff ff       	jmp    80106a7a <alltraps>

8010785f <vector170>:
.globl vector170
vector170:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $170
80107861:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107866:	e9 0f f2 ff ff       	jmp    80106a7a <alltraps>

8010786b <vector171>:
.globl vector171
vector171:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $171
8010786d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107872:	e9 03 f2 ff ff       	jmp    80106a7a <alltraps>

80107877 <vector172>:
.globl vector172
vector172:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $172
80107879:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010787e:	e9 f7 f1 ff ff       	jmp    80106a7a <alltraps>

80107883 <vector173>:
.globl vector173
vector173:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $173
80107885:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010788a:	e9 eb f1 ff ff       	jmp    80106a7a <alltraps>

8010788f <vector174>:
.globl vector174
vector174:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $174
80107891:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107896:	e9 df f1 ff ff       	jmp    80106a7a <alltraps>

8010789b <vector175>:
.globl vector175
vector175:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $175
8010789d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078a2:	e9 d3 f1 ff ff       	jmp    80106a7a <alltraps>

801078a7 <vector176>:
.globl vector176
vector176:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $176
801078a9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078ae:	e9 c7 f1 ff ff       	jmp    80106a7a <alltraps>

801078b3 <vector177>:
.globl vector177
vector177:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $177
801078b5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801078ba:	e9 bb f1 ff ff       	jmp    80106a7a <alltraps>

801078bf <vector178>:
.globl vector178
vector178:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $178
801078c1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801078c6:	e9 af f1 ff ff       	jmp    80106a7a <alltraps>

801078cb <vector179>:
.globl vector179
vector179:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $179
801078cd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801078d2:	e9 a3 f1 ff ff       	jmp    80106a7a <alltraps>

801078d7 <vector180>:
.globl vector180
vector180:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $180
801078d9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801078de:	e9 97 f1 ff ff       	jmp    80106a7a <alltraps>

801078e3 <vector181>:
.globl vector181
vector181:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $181
801078e5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801078ea:	e9 8b f1 ff ff       	jmp    80106a7a <alltraps>

801078ef <vector182>:
.globl vector182
vector182:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $182
801078f1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801078f6:	e9 7f f1 ff ff       	jmp    80106a7a <alltraps>

801078fb <vector183>:
.globl vector183
vector183:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $183
801078fd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107902:	e9 73 f1 ff ff       	jmp    80106a7a <alltraps>

80107907 <vector184>:
.globl vector184
vector184:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $184
80107909:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010790e:	e9 67 f1 ff ff       	jmp    80106a7a <alltraps>

80107913 <vector185>:
.globl vector185
vector185:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $185
80107915:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010791a:	e9 5b f1 ff ff       	jmp    80106a7a <alltraps>

8010791f <vector186>:
.globl vector186
vector186:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $186
80107921:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107926:	e9 4f f1 ff ff       	jmp    80106a7a <alltraps>

8010792b <vector187>:
.globl vector187
vector187:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $187
8010792d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107932:	e9 43 f1 ff ff       	jmp    80106a7a <alltraps>

80107937 <vector188>:
.globl vector188
vector188:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $188
80107939:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010793e:	e9 37 f1 ff ff       	jmp    80106a7a <alltraps>

80107943 <vector189>:
.globl vector189
vector189:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $189
80107945:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010794a:	e9 2b f1 ff ff       	jmp    80106a7a <alltraps>

8010794f <vector190>:
.globl vector190
vector190:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $190
80107951:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107956:	e9 1f f1 ff ff       	jmp    80106a7a <alltraps>

8010795b <vector191>:
.globl vector191
vector191:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $191
8010795d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107962:	e9 13 f1 ff ff       	jmp    80106a7a <alltraps>

80107967 <vector192>:
.globl vector192
vector192:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $192
80107969:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010796e:	e9 07 f1 ff ff       	jmp    80106a7a <alltraps>

80107973 <vector193>:
.globl vector193
vector193:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $193
80107975:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010797a:	e9 fb f0 ff ff       	jmp    80106a7a <alltraps>

8010797f <vector194>:
.globl vector194
vector194:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $194
80107981:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107986:	e9 ef f0 ff ff       	jmp    80106a7a <alltraps>

8010798b <vector195>:
.globl vector195
vector195:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $195
8010798d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107992:	e9 e3 f0 ff ff       	jmp    80106a7a <alltraps>

80107997 <vector196>:
.globl vector196
vector196:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $196
80107999:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010799e:	e9 d7 f0 ff ff       	jmp    80106a7a <alltraps>

801079a3 <vector197>:
.globl vector197
vector197:
  pushl $0
801079a3:	6a 00                	push   $0x0
  pushl $197
801079a5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079aa:	e9 cb f0 ff ff       	jmp    80106a7a <alltraps>

801079af <vector198>:
.globl vector198
vector198:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $198
801079b1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079b6:	e9 bf f0 ff ff       	jmp    80106a7a <alltraps>

801079bb <vector199>:
.globl vector199
vector199:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $199
801079bd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801079c2:	e9 b3 f0 ff ff       	jmp    80106a7a <alltraps>

801079c7 <vector200>:
.globl vector200
vector200:
  pushl $0
801079c7:	6a 00                	push   $0x0
  pushl $200
801079c9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801079ce:	e9 a7 f0 ff ff       	jmp    80106a7a <alltraps>

801079d3 <vector201>:
.globl vector201
vector201:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $201
801079d5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801079da:	e9 9b f0 ff ff       	jmp    80106a7a <alltraps>

801079df <vector202>:
.globl vector202
vector202:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $202
801079e1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801079e6:	e9 8f f0 ff ff       	jmp    80106a7a <alltraps>

801079eb <vector203>:
.globl vector203
vector203:
  pushl $0
801079eb:	6a 00                	push   $0x0
  pushl $203
801079ed:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801079f2:	e9 83 f0 ff ff       	jmp    80106a7a <alltraps>

801079f7 <vector204>:
.globl vector204
vector204:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $204
801079f9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801079fe:	e9 77 f0 ff ff       	jmp    80106a7a <alltraps>

80107a03 <vector205>:
.globl vector205
vector205:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $205
80107a05:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a0a:	e9 6b f0 ff ff       	jmp    80106a7a <alltraps>

80107a0f <vector206>:
.globl vector206
vector206:
  pushl $0
80107a0f:	6a 00                	push   $0x0
  pushl $206
80107a11:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a16:	e9 5f f0 ff ff       	jmp    80106a7a <alltraps>

80107a1b <vector207>:
.globl vector207
vector207:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $207
80107a1d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a22:	e9 53 f0 ff ff       	jmp    80106a7a <alltraps>

80107a27 <vector208>:
.globl vector208
vector208:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $208
80107a29:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a2e:	e9 47 f0 ff ff       	jmp    80106a7a <alltraps>

80107a33 <vector209>:
.globl vector209
vector209:
  pushl $0
80107a33:	6a 00                	push   $0x0
  pushl $209
80107a35:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a3a:	e9 3b f0 ff ff       	jmp    80106a7a <alltraps>

80107a3f <vector210>:
.globl vector210
vector210:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $210
80107a41:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a46:	e9 2f f0 ff ff       	jmp    80106a7a <alltraps>

80107a4b <vector211>:
.globl vector211
vector211:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $211
80107a4d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a52:	e9 23 f0 ff ff       	jmp    80106a7a <alltraps>

80107a57 <vector212>:
.globl vector212
vector212:
  pushl $0
80107a57:	6a 00                	push   $0x0
  pushl $212
80107a59:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a5e:	e9 17 f0 ff ff       	jmp    80106a7a <alltraps>

80107a63 <vector213>:
.globl vector213
vector213:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $213
80107a65:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a6a:	e9 0b f0 ff ff       	jmp    80106a7a <alltraps>

80107a6f <vector214>:
.globl vector214
vector214:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $214
80107a71:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a76:	e9 ff ef ff ff       	jmp    80106a7a <alltraps>

80107a7b <vector215>:
.globl vector215
vector215:
  pushl $0
80107a7b:	6a 00                	push   $0x0
  pushl $215
80107a7d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a82:	e9 f3 ef ff ff       	jmp    80106a7a <alltraps>

80107a87 <vector216>:
.globl vector216
vector216:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $216
80107a89:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a8e:	e9 e7 ef ff ff       	jmp    80106a7a <alltraps>

80107a93 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $217
80107a95:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a9a:	e9 db ef ff ff       	jmp    80106a7a <alltraps>

80107a9f <vector218>:
.globl vector218
vector218:
  pushl $0
80107a9f:	6a 00                	push   $0x0
  pushl $218
80107aa1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107aa6:	e9 cf ef ff ff       	jmp    80106a7a <alltraps>

80107aab <vector219>:
.globl vector219
vector219:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $219
80107aad:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107ab2:	e9 c3 ef ff ff       	jmp    80106a7a <alltraps>

80107ab7 <vector220>:
.globl vector220
vector220:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $220
80107ab9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107abe:	e9 b7 ef ff ff       	jmp    80106a7a <alltraps>

80107ac3 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ac3:	6a 00                	push   $0x0
  pushl $221
80107ac5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107aca:	e9 ab ef ff ff       	jmp    80106a7a <alltraps>

80107acf <vector222>:
.globl vector222
vector222:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $222
80107ad1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107ad6:	e9 9f ef ff ff       	jmp    80106a7a <alltraps>

80107adb <vector223>:
.globl vector223
vector223:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $223
80107add:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107ae2:	e9 93 ef ff ff       	jmp    80106a7a <alltraps>

80107ae7 <vector224>:
.globl vector224
vector224:
  pushl $0
80107ae7:	6a 00                	push   $0x0
  pushl $224
80107ae9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107aee:	e9 87 ef ff ff       	jmp    80106a7a <alltraps>

80107af3 <vector225>:
.globl vector225
vector225:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $225
80107af5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107afa:	e9 7b ef ff ff       	jmp    80106a7a <alltraps>

80107aff <vector226>:
.globl vector226
vector226:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $226
80107b01:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b06:	e9 6f ef ff ff       	jmp    80106a7a <alltraps>

80107b0b <vector227>:
.globl vector227
vector227:
  pushl $0
80107b0b:	6a 00                	push   $0x0
  pushl $227
80107b0d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b12:	e9 63 ef ff ff       	jmp    80106a7a <alltraps>

80107b17 <vector228>:
.globl vector228
vector228:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $228
80107b19:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b1e:	e9 57 ef ff ff       	jmp    80106a7a <alltraps>

80107b23 <vector229>:
.globl vector229
vector229:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $229
80107b25:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b2a:	e9 4b ef ff ff       	jmp    80106a7a <alltraps>

80107b2f <vector230>:
.globl vector230
vector230:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $230
80107b31:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b36:	e9 3f ef ff ff       	jmp    80106a7a <alltraps>

80107b3b <vector231>:
.globl vector231
vector231:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $231
80107b3d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b42:	e9 33 ef ff ff       	jmp    80106a7a <alltraps>

80107b47 <vector232>:
.globl vector232
vector232:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $232
80107b49:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b4e:	e9 27 ef ff ff       	jmp    80106a7a <alltraps>

80107b53 <vector233>:
.globl vector233
vector233:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $233
80107b55:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b5a:	e9 1b ef ff ff       	jmp    80106a7a <alltraps>

80107b5f <vector234>:
.globl vector234
vector234:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $234
80107b61:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b66:	e9 0f ef ff ff       	jmp    80106a7a <alltraps>

80107b6b <vector235>:
.globl vector235
vector235:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $235
80107b6d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b72:	e9 03 ef ff ff       	jmp    80106a7a <alltraps>

80107b77 <vector236>:
.globl vector236
vector236:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $236
80107b79:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b7e:	e9 f7 ee ff ff       	jmp    80106a7a <alltraps>

80107b83 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $237
80107b85:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b8a:	e9 eb ee ff ff       	jmp    80106a7a <alltraps>

80107b8f <vector238>:
.globl vector238
vector238:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $238
80107b91:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b96:	e9 df ee ff ff       	jmp    80106a7a <alltraps>

80107b9b <vector239>:
.globl vector239
vector239:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $239
80107b9d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ba2:	e9 d3 ee ff ff       	jmp    80106a7a <alltraps>

80107ba7 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $240
80107ba9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bae:	e9 c7 ee ff ff       	jmp    80106a7a <alltraps>

80107bb3 <vector241>:
.globl vector241
vector241:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $241
80107bb5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107bba:	e9 bb ee ff ff       	jmp    80106a7a <alltraps>

80107bbf <vector242>:
.globl vector242
vector242:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $242
80107bc1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107bc6:	e9 af ee ff ff       	jmp    80106a7a <alltraps>

80107bcb <vector243>:
.globl vector243
vector243:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $243
80107bcd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107bd2:	e9 a3 ee ff ff       	jmp    80106a7a <alltraps>

80107bd7 <vector244>:
.globl vector244
vector244:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $244
80107bd9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107bde:	e9 97 ee ff ff       	jmp    80106a7a <alltraps>

80107be3 <vector245>:
.globl vector245
vector245:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $245
80107be5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107bea:	e9 8b ee ff ff       	jmp    80106a7a <alltraps>

80107bef <vector246>:
.globl vector246
vector246:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $246
80107bf1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107bf6:	e9 7f ee ff ff       	jmp    80106a7a <alltraps>

80107bfb <vector247>:
.globl vector247
vector247:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $247
80107bfd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c02:	e9 73 ee ff ff       	jmp    80106a7a <alltraps>

80107c07 <vector248>:
.globl vector248
vector248:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $248
80107c09:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c0e:	e9 67 ee ff ff       	jmp    80106a7a <alltraps>

80107c13 <vector249>:
.globl vector249
vector249:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $249
80107c15:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c1a:	e9 5b ee ff ff       	jmp    80106a7a <alltraps>

80107c1f <vector250>:
.globl vector250
vector250:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $250
80107c21:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c26:	e9 4f ee ff ff       	jmp    80106a7a <alltraps>

80107c2b <vector251>:
.globl vector251
vector251:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $251
80107c2d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c32:	e9 43 ee ff ff       	jmp    80106a7a <alltraps>

80107c37 <vector252>:
.globl vector252
vector252:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $252
80107c39:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c3e:	e9 37 ee ff ff       	jmp    80106a7a <alltraps>

80107c43 <vector253>:
.globl vector253
vector253:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $253
80107c45:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c4a:	e9 2b ee ff ff       	jmp    80106a7a <alltraps>

80107c4f <vector254>:
.globl vector254
vector254:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $254
80107c51:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c56:	e9 1f ee ff ff       	jmp    80106a7a <alltraps>

80107c5b <vector255>:
.globl vector255
vector255:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $255
80107c5d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c62:	e9 13 ee ff ff       	jmp    80106a7a <alltraps>

80107c67 <lgdt>:
{
80107c67:	55                   	push   %ebp
80107c68:	89 e5                	mov    %esp,%ebp
80107c6a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c70:	83 e8 01             	sub    $0x1,%eax
80107c73:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c77:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c81:	c1 e8 10             	shr    $0x10,%eax
80107c84:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107c88:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c8b:	0f 01 10             	lgdtl  (%eax)
}
80107c8e:	90                   	nop
80107c8f:	c9                   	leave
80107c90:	c3                   	ret

80107c91 <ltr>:
{
80107c91:	55                   	push   %ebp
80107c92:	89 e5                	mov    %esp,%ebp
80107c94:	83 ec 04             	sub    $0x4,%esp
80107c97:	8b 45 08             	mov    0x8(%ebp),%eax
80107c9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ca2:	0f 00 d8             	ltr    %eax
}
80107ca5:	90                   	nop
80107ca6:	c9                   	leave
80107ca7:	c3                   	ret

80107ca8 <lcr3>:

static inline void
lcr3(uint val)
{
80107ca8:	55                   	push   %ebp
80107ca9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107cab:	8b 45 08             	mov    0x8(%ebp),%eax
80107cae:	0f 22 d8             	mov    %eax,%cr3
}
80107cb1:	90                   	nop
80107cb2:	5d                   	pop    %ebp
80107cb3:	c3                   	ret

80107cb4 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cb4:	f3 0f 1e fb          	endbr32
80107cb8:	55                   	push   %ebp
80107cb9:	89 e5                	mov    %esp,%ebp
80107cbb:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107cbe:	e8 4b be ff ff       	call   80103b0e <cpuid>
80107cc3:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107cc9:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
80107cce:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cf1:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf4:	83 ca 0a             	or     $0xa,%edx
80107cf7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d01:	83 ca 10             	or     $0x10,%edx
80107d04:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d0e:	83 e2 9f             	and    $0xffffff9f,%edx
80107d11:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d1b:	83 ca 80             	or     $0xffffff80,%edx
80107d1e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d28:	83 ca 0f             	or     $0xf,%edx
80107d2b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d31:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d35:	83 e2 ef             	and    $0xffffffef,%edx
80107d38:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d42:	83 e2 df             	and    $0xffffffdf,%edx
80107d45:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d4f:	83 ca 40             	or     $0x40,%edx
80107d52:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d58:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d5c:	83 ca 80             	or     $0xffffff80,%edx
80107d5f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d65:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d73:	ff ff 
80107d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d78:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d7f:	00 00 
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d95:	83 e2 f0             	and    $0xfffffff0,%edx
80107d98:	83 ca 02             	or     $0x2,%edx
80107d9b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dab:	83 ca 10             	or     $0x10,%edx
80107dae:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dbe:	83 e2 9f             	and    $0xffffff9f,%edx
80107dc1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dca:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dd1:	83 ca 80             	or     $0xffffff80,%edx
80107dd4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107de4:	83 ca 0f             	or     $0xf,%edx
80107de7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107df7:	83 e2 ef             	and    $0xffffffef,%edx
80107dfa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e03:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e0a:	83 e2 df             	and    $0xffffffdf,%edx
80107e0d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e16:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e1d:	83 ca 40             	or     $0x40,%edx
80107e20:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e29:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e30:	83 ca 80             	or     $0xffffff80,%edx
80107e33:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107e4d:	ff ff 
80107e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e52:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107e59:	00 00 
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e68:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e6f:	83 e2 f0             	and    $0xfffffff0,%edx
80107e72:	83 ca 0a             	or     $0xa,%edx
80107e75:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e85:	83 ca 10             	or     $0x10,%edx
80107e88:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e98:	83 ca 60             	or     $0x60,%edx
80107e9b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eab:	83 ca 80             	or     $0xffffff80,%edx
80107eae:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ebe:	83 ca 0f             	or     $0xf,%edx
80107ec1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ed1:	83 e2 ef             	and    $0xffffffef,%edx
80107ed4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ee4:	83 e2 df             	and    $0xffffffdf,%edx
80107ee7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ef7:	83 ca 40             	or     $0x40,%edx
80107efa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f03:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f0a:	83 ca 80             	or     $0xffffff80,%edx
80107f0d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f27:	ff ff 
80107f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f33:	00 00 
80107f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f38:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f42:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f49:	83 e2 f0             	and    $0xfffffff0,%edx
80107f4c:	83 ca 02             	or     $0x2,%edx
80107f4f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f5f:	83 ca 10             	or     $0x10,%edx
80107f62:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f72:	83 ca 60             	or     $0x60,%edx
80107f75:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f85:	83 ca 80             	or     $0xffffff80,%edx
80107f88:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f91:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f98:	83 ca 0f             	or     $0xf,%edx
80107f9b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fab:	83 e2 ef             	and    $0xffffffef,%edx
80107fae:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fbe:	83 e2 df             	and    $0xffffffdf,%edx
80107fc1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fca:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fd1:	83 ca 40             	or     $0x40,%edx
80107fd4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fe4:	83 ca 80             	or     $0xffffff80,%edx
80107fe7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffa:	83 c0 70             	add    $0x70,%eax
80107ffd:	83 ec 08             	sub    $0x8,%esp
80108000:	6a 30                	push   $0x30
80108002:	50                   	push   %eax
80108003:	e8 5f fc ff ff       	call   80107c67 <lgdt>
80108008:	83 c4 10             	add    $0x10,%esp
}
8010800b:	90                   	nop
8010800c:	c9                   	leave
8010800d:	c3                   	ret

8010800e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010800e:	f3 0f 1e fb          	endbr32
80108012:	55                   	push   %ebp
80108013:	89 e5                	mov    %esp,%ebp
80108015:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108018:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801b:	c1 e8 16             	shr    $0x16,%eax
8010801e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108025:	8b 45 08             	mov    0x8(%ebp),%eax
80108028:	01 d0                	add    %edx,%eax
8010802a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010802d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108030:	8b 00                	mov    (%eax),%eax
80108032:	83 e0 01             	and    $0x1,%eax
80108035:	85 c0                	test   %eax,%eax
80108037:	74 14                	je     8010804d <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803c:	8b 00                	mov    (%eax),%eax
8010803e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108043:	05 00 00 00 80       	add    $0x80000000,%eax
80108048:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010804b:	eb 42                	jmp    8010808f <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010804d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108051:	74 0e                	je     80108061 <walkpgdir+0x53>
80108053:	e8 3a a8 ff ff       	call   80102892 <kalloc>
80108058:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010805b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010805f:	75 07                	jne    80108068 <walkpgdir+0x5a>
      return 0;
80108061:	b8 00 00 00 00       	mov    $0x0,%eax
80108066:	eb 3e                	jmp    801080a6 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108068:	83 ec 04             	sub    $0x4,%esp
8010806b:	68 00 10 00 00       	push   $0x1000
80108070:	6a 00                	push   $0x0
80108072:	ff 75 f4             	push   -0xc(%ebp)
80108075:	e8 44 d5 ff ff       	call   801055be <memset>
8010807a:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108080:	05 00 00 00 80       	add    $0x80000000,%eax
80108085:	83 c8 07             	or     $0x7,%eax
80108088:	89 c2                	mov    %eax,%edx
8010808a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010808f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108092:	c1 e8 0c             	shr    $0xc,%eax
80108095:	25 ff 03 00 00       	and    $0x3ff,%eax
8010809a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a4:	01 d0                	add    %edx,%eax
}
801080a6:	c9                   	leave
801080a7:	c3                   	ret

801080a8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080a8:	f3 0f 1e fb          	endbr32
801080ac:	55                   	push   %ebp
801080ad:	89 e5                	mov    %esp,%ebp
801080af:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801080b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801080c0:	8b 45 10             	mov    0x10(%ebp),%eax
801080c3:	01 d0                	add    %edx,%eax
801080c5:	83 e8 01             	sub    $0x1,%eax
801080c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080d0:	83 ec 04             	sub    $0x4,%esp
801080d3:	6a 01                	push   $0x1
801080d5:	ff 75 f4             	push   -0xc(%ebp)
801080d8:	ff 75 08             	push   0x8(%ebp)
801080db:	e8 2e ff ff ff       	call   8010800e <walkpgdir>
801080e0:	83 c4 10             	add    $0x10,%esp
801080e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080ea:	75 07                	jne    801080f3 <mappages+0x4b>
      return -1;
801080ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080f1:	eb 47                	jmp    8010813a <mappages+0x92>
    if(*pte & PTE_P)
801080f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080f6:	8b 00                	mov    (%eax),%eax
801080f8:	83 e0 01             	and    $0x1,%eax
801080fb:	85 c0                	test   %eax,%eax
801080fd:	74 0d                	je     8010810c <mappages+0x64>
      panic("remap");
801080ff:	83 ec 0c             	sub    $0xc,%esp
80108102:	68 90 b6 10 80       	push   $0x8010b690
80108107:	e8 b9 84 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
8010810c:	8b 45 18             	mov    0x18(%ebp),%eax
8010810f:	0b 45 14             	or     0x14(%ebp),%eax
80108112:	83 c8 01             	or     $0x1,%eax
80108115:	89 c2                	mov    %eax,%edx
80108117:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010811a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108122:	74 10                	je     80108134 <mappages+0x8c>
      break;
    a += PGSIZE;
80108124:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010812b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108132:	eb 9c                	jmp    801080d0 <mappages+0x28>
      break;
80108134:	90                   	nop
  }
  return 0;
80108135:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010813a:	c9                   	leave
8010813b:	c3                   	ret

8010813c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010813c:	f3 0f 1e fb          	endbr32
80108140:	55                   	push   %ebp
80108141:	89 e5                	mov    %esp,%ebp
80108143:	53                   	push   %ebx
80108144:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80108147:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010814e:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108153:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108158:	29 c2                	sub    %eax,%edx
8010815a:	89 d0                	mov    %edx,%eax
8010815c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010815f:	a1 98 9d 19 80       	mov    0x80199d98,%eax
80108164:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108167:	8b 15 98 9d 19 80    	mov    0x80199d98,%edx
8010816d:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108172:	01 d0                	add    %edx,%eax
80108174:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108177:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010817e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108181:	83 c0 30             	add    $0x30,%eax
80108184:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108187:	89 10                	mov    %edx,(%eax)
80108189:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010818c:	89 50 04             	mov    %edx,0x4(%eax)
8010818f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108192:	89 50 08             	mov    %edx,0x8(%eax)
80108195:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108198:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010819b:	e8 f2 a6 ff ff       	call   80102892 <kalloc>
801081a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081a7:	75 07                	jne    801081b0 <setupkvm+0x74>
    return 0;
801081a9:	b8 00 00 00 00       	mov    $0x0,%eax
801081ae:	eb 78                	jmp    80108228 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801081b0:	83 ec 04             	sub    $0x4,%esp
801081b3:	68 00 10 00 00       	push   $0x1000
801081b8:	6a 00                	push   $0x0
801081ba:	ff 75 f0             	push   -0x10(%ebp)
801081bd:	e8 fc d3 ff ff       	call   801055be <memset>
801081c2:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081c5:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
801081cc:	eb 4e                	jmp    8010821c <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d1:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801081d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d7:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	8b 58 08             	mov    0x8(%eax),%ebx
801081e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e3:	8b 40 04             	mov    0x4(%eax),%eax
801081e6:	29 c3                	sub    %eax,%ebx
801081e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081eb:	8b 00                	mov    (%eax),%eax
801081ed:	83 ec 0c             	sub    $0xc,%esp
801081f0:	51                   	push   %ecx
801081f1:	52                   	push   %edx
801081f2:	53                   	push   %ebx
801081f3:	50                   	push   %eax
801081f4:	ff 75 f0             	push   -0x10(%ebp)
801081f7:	e8 ac fe ff ff       	call   801080a8 <mappages>
801081fc:	83 c4 20             	add    $0x20,%esp
801081ff:	85 c0                	test   %eax,%eax
80108201:	79 15                	jns    80108218 <setupkvm+0xdc>
      freevm(pgdir);
80108203:	83 ec 0c             	sub    $0xc,%esp
80108206:	ff 75 f0             	push   -0x10(%ebp)
80108209:	e8 11 05 00 00       	call   8010871f <freevm>
8010820e:	83 c4 10             	add    $0x10,%esp
      return 0;
80108211:	b8 00 00 00 00       	mov    $0x0,%eax
80108216:	eb 10                	jmp    80108228 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108218:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010821c:	81 7d f4 00 05 11 80 	cmpl   $0x80110500,-0xc(%ebp)
80108223:	72 a9                	jb     801081ce <setupkvm+0x92>
    }
  return pgdir;
80108225:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010822b:	c9                   	leave
8010822c:	c3                   	ret

8010822d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010822d:	f3 0f 1e fb          	endbr32
80108231:	55                   	push   %ebp
80108232:	89 e5                	mov    %esp,%ebp
80108234:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108237:	e8 00 ff ff ff       	call   8010813c <setupkvm>
8010823c:	a3 a4 9c 19 80       	mov    %eax,0x80199ca4
  switchkvm();
80108241:	e8 03 00 00 00       	call   80108249 <switchkvm>
}
80108246:	90                   	nop
80108247:	c9                   	leave
80108248:	c3                   	ret

80108249 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108249:	f3 0f 1e fb          	endbr32
8010824d:	55                   	push   %ebp
8010824e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108250:	a1 a4 9c 19 80       	mov    0x80199ca4,%eax
80108255:	05 00 00 00 80       	add    $0x80000000,%eax
8010825a:	50                   	push   %eax
8010825b:	e8 48 fa ff ff       	call   80107ca8 <lcr3>
80108260:	83 c4 04             	add    $0x4,%esp
}
80108263:	90                   	nop
80108264:	c9                   	leave
80108265:	c3                   	ret

80108266 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108266:	f3 0f 1e fb          	endbr32
8010826a:	55                   	push   %ebp
8010826b:	89 e5                	mov    %esp,%ebp
8010826d:	56                   	push   %esi
8010826e:	53                   	push   %ebx
8010826f:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108272:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108276:	75 0d                	jne    80108285 <switchuvm+0x1f>
    panic("switchuvm: no process");
80108278:	83 ec 0c             	sub    $0xc,%esp
8010827b:	68 96 b6 10 80       	push   $0x8010b696
80108280:	e8 40 83 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80108285:	8b 45 08             	mov    0x8(%ebp),%eax
80108288:	8b 40 08             	mov    0x8(%eax),%eax
8010828b:	85 c0                	test   %eax,%eax
8010828d:	75 0d                	jne    8010829c <switchuvm+0x36>
    panic("switchuvm: no kstack");
8010828f:	83 ec 0c             	sub    $0xc,%esp
80108292:	68 ac b6 10 80       	push   $0x8010b6ac
80108297:	e8 29 83 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
8010829c:	8b 45 08             	mov    0x8(%ebp),%eax
8010829f:	8b 40 04             	mov    0x4(%eax),%eax
801082a2:	85 c0                	test   %eax,%eax
801082a4:	75 0d                	jne    801082b3 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801082a6:	83 ec 0c             	sub    $0xc,%esp
801082a9:	68 c1 b6 10 80       	push   $0x8010b6c1
801082ae:	e8 12 83 ff ff       	call   801005c5 <panic>

  pushcli();
801082b3:	e8 f3 d1 ff ff       	call   801054ab <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801082b8:	e8 70 b8 ff ff       	call   80103b2d <mycpu>
801082bd:	89 c3                	mov    %eax,%ebx
801082bf:	e8 69 b8 ff ff       	call   80103b2d <mycpu>
801082c4:	83 c0 08             	add    $0x8,%eax
801082c7:	89 c6                	mov    %eax,%esi
801082c9:	e8 5f b8 ff ff       	call   80103b2d <mycpu>
801082ce:	83 c0 08             	add    $0x8,%eax
801082d1:	c1 e8 10             	shr    $0x10,%eax
801082d4:	88 45 f7             	mov    %al,-0x9(%ebp)
801082d7:	e8 51 b8 ff ff       	call   80103b2d <mycpu>
801082dc:	83 c0 08             	add    $0x8,%eax
801082df:	c1 e8 18             	shr    $0x18,%eax
801082e2:	89 c2                	mov    %eax,%edx
801082e4:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801082eb:	67 00 
801082ed:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801082f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801082f8:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801082fe:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108305:	83 e0 f0             	and    $0xfffffff0,%eax
80108308:	83 c8 09             	or     $0x9,%eax
8010830b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108311:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108318:	83 c8 10             	or     $0x10,%eax
8010831b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108321:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108328:	83 e0 9f             	and    $0xffffff9f,%eax
8010832b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108331:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108338:	83 c8 80             	or     $0xffffff80,%eax
8010833b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108341:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108348:	83 e0 f0             	and    $0xfffffff0,%eax
8010834b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108351:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108358:	83 e0 ef             	and    $0xffffffef,%eax
8010835b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108361:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108368:	83 e0 df             	and    $0xffffffdf,%eax
8010836b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108371:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108378:	83 c8 40             	or     $0x40,%eax
8010837b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108381:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108388:	83 e0 7f             	and    $0x7f,%eax
8010838b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108391:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108397:	e8 91 b7 ff ff       	call   80103b2d <mycpu>
8010839c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083a3:	83 e2 ef             	and    $0xffffffef,%edx
801083a6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801083ac:	e8 7c b7 ff ff       	call   80103b2d <mycpu>
801083b1:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801083b7:	8b 45 08             	mov    0x8(%ebp),%eax
801083ba:	8b 40 08             	mov    0x8(%eax),%eax
801083bd:	89 c3                	mov    %eax,%ebx
801083bf:	e8 69 b7 ff ff       	call   80103b2d <mycpu>
801083c4:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801083ca:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801083cd:	e8 5b b7 ff ff       	call   80103b2d <mycpu>
801083d2:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801083d8:	83 ec 0c             	sub    $0xc,%esp
801083db:	6a 28                	push   $0x28
801083dd:	e8 af f8 ff ff       	call   80107c91 <ltr>
801083e2:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801083e5:	8b 45 08             	mov    0x8(%ebp),%eax
801083e8:	8b 40 04             	mov    0x4(%eax),%eax
801083eb:	05 00 00 00 80       	add    $0x80000000,%eax
801083f0:	83 ec 0c             	sub    $0xc,%esp
801083f3:	50                   	push   %eax
801083f4:	e8 af f8 ff ff       	call   80107ca8 <lcr3>
801083f9:	83 c4 10             	add    $0x10,%esp
  popcli();
801083fc:	e8 fb d0 ff ff       	call   801054fc <popcli>
}
80108401:	90                   	nop
80108402:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108405:	5b                   	pop    %ebx
80108406:	5e                   	pop    %esi
80108407:	5d                   	pop    %ebp
80108408:	c3                   	ret

80108409 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108409:	f3 0f 1e fb          	endbr32
8010840d:	55                   	push   %ebp
8010840e:	89 e5                	mov    %esp,%ebp
80108410:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108413:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010841a:	76 0d                	jbe    80108429 <inituvm+0x20>
    panic("inituvm: more than a page");
8010841c:	83 ec 0c             	sub    $0xc,%esp
8010841f:	68 d5 b6 10 80       	push   $0x8010b6d5
80108424:	e8 9c 81 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80108429:	e8 64 a4 ff ff       	call   80102892 <kalloc>
8010842e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108431:	83 ec 04             	sub    $0x4,%esp
80108434:	68 00 10 00 00       	push   $0x1000
80108439:	6a 00                	push   $0x0
8010843b:	ff 75 f4             	push   -0xc(%ebp)
8010843e:	e8 7b d1 ff ff       	call   801055be <memset>
80108443:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	05 00 00 00 80       	add    $0x80000000,%eax
8010844e:	83 ec 0c             	sub    $0xc,%esp
80108451:	6a 06                	push   $0x6
80108453:	50                   	push   %eax
80108454:	68 00 10 00 00       	push   $0x1000
80108459:	6a 00                	push   $0x0
8010845b:	ff 75 08             	push   0x8(%ebp)
8010845e:	e8 45 fc ff ff       	call   801080a8 <mappages>
80108463:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108466:	83 ec 04             	sub    $0x4,%esp
80108469:	ff 75 10             	push   0x10(%ebp)
8010846c:	ff 75 0c             	push   0xc(%ebp)
8010846f:	ff 75 f4             	push   -0xc(%ebp)
80108472:	e8 0e d2 ff ff       	call   80105685 <memmove>
80108477:	83 c4 10             	add    $0x10,%esp
}
8010847a:	90                   	nop
8010847b:	c9                   	leave
8010847c:	c3                   	ret

8010847d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010847d:	f3 0f 1e fb          	endbr32
80108481:	55                   	push   %ebp
80108482:	89 e5                	mov    %esp,%ebp
80108484:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108487:	8b 45 0c             	mov    0xc(%ebp),%eax
8010848a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010848f:	85 c0                	test   %eax,%eax
80108491:	74 0d                	je     801084a0 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108493:	83 ec 0c             	sub    $0xc,%esp
80108496:	68 f0 b6 10 80       	push   $0x8010b6f0
8010849b:	e8 25 81 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084a7:	e9 8f 00 00 00       	jmp    8010853b <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801084af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b2:	01 d0                	add    %edx,%eax
801084b4:	83 ec 04             	sub    $0x4,%esp
801084b7:	6a 00                	push   $0x0
801084b9:	50                   	push   %eax
801084ba:	ff 75 08             	push   0x8(%ebp)
801084bd:	e8 4c fb ff ff       	call   8010800e <walkpgdir>
801084c2:	83 c4 10             	add    $0x10,%esp
801084c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084cc:	75 0d                	jne    801084db <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801084ce:	83 ec 0c             	sub    $0xc,%esp
801084d1:	68 13 b7 10 80       	push   $0x8010b713
801084d6:	e8 ea 80 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801084db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084de:	8b 00                	mov    (%eax),%eax
801084e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084e8:	8b 45 18             	mov    0x18(%ebp),%eax
801084eb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084ee:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801084f3:	77 0b                	ja     80108500 <loaduvm+0x83>
      n = sz - i;
801084f5:	8b 45 18             	mov    0x18(%ebp),%eax
801084f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084fe:	eb 07                	jmp    80108507 <loaduvm+0x8a>
    else
      n = PGSIZE;
80108500:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108507:	8b 55 14             	mov    0x14(%ebp),%edx
8010850a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850d:	01 d0                	add    %edx,%eax
8010850f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108512:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108518:	ff 75 f0             	push   -0x10(%ebp)
8010851b:	50                   	push   %eax
8010851c:	52                   	push   %edx
8010851d:	ff 75 10             	push   0x10(%ebp)
80108520:	e8 5f 9a ff ff       	call   80101f84 <readi>
80108525:	83 c4 10             	add    $0x10,%esp
80108528:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010852b:	74 07                	je     80108534 <loaduvm+0xb7>
      return -1;
8010852d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108532:	eb 18                	jmp    8010854c <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108534:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108541:	0f 82 65 ff ff ff    	jb     801084ac <loaduvm+0x2f>
  }
  return 0;
80108547:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010854c:	c9                   	leave
8010854d:	c3                   	ret

8010854e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010854e:	f3 0f 1e fb          	endbr32
80108552:	55                   	push   %ebp
80108553:	89 e5                	mov    %esp,%ebp
80108555:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108558:	8b 45 10             	mov    0x10(%ebp),%eax
8010855b:	85 c0                	test   %eax,%eax
8010855d:	79 0a                	jns    80108569 <allocuvm+0x1b>
    return 0;
8010855f:	b8 00 00 00 00       	mov    $0x0,%eax
80108564:	e9 ec 00 00 00       	jmp    80108655 <allocuvm+0x107>
  if(newsz < oldsz)
80108569:	8b 45 10             	mov    0x10(%ebp),%eax
8010856c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010856f:	73 08                	jae    80108579 <allocuvm+0x2b>
    return oldsz;
80108571:	8b 45 0c             	mov    0xc(%ebp),%eax
80108574:	e9 dc 00 00 00       	jmp    80108655 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80108579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010857c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108581:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108586:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108589:	e9 b8 00 00 00       	jmp    80108646 <allocuvm+0xf8>
    mem = kalloc();
8010858e:	e8 ff a2 ff ff       	call   80102892 <kalloc>
80108593:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108596:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010859a:	75 2e                	jne    801085ca <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
8010859c:	83 ec 0c             	sub    $0xc,%esp
8010859f:	68 31 b7 10 80       	push   $0x8010b731
801085a4:	e8 63 7e ff ff       	call   8010040c <cprintf>
801085a9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085ac:	83 ec 04             	sub    $0x4,%esp
801085af:	ff 75 0c             	push   0xc(%ebp)
801085b2:	ff 75 10             	push   0x10(%ebp)
801085b5:	ff 75 08             	push   0x8(%ebp)
801085b8:	e8 9a 00 00 00       	call   80108657 <deallocuvm>
801085bd:	83 c4 10             	add    $0x10,%esp
      return 0;
801085c0:	b8 00 00 00 00       	mov    $0x0,%eax
801085c5:	e9 8b 00 00 00       	jmp    80108655 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801085ca:	83 ec 04             	sub    $0x4,%esp
801085cd:	68 00 10 00 00       	push   $0x1000
801085d2:	6a 00                	push   $0x0
801085d4:	ff 75 f0             	push   -0x10(%ebp)
801085d7:	e8 e2 cf ff ff       	call   801055be <memset>
801085dc:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801085df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801085e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085eb:	83 ec 0c             	sub    $0xc,%esp
801085ee:	6a 06                	push   $0x6
801085f0:	52                   	push   %edx
801085f1:	68 00 10 00 00       	push   $0x1000
801085f6:	50                   	push   %eax
801085f7:	ff 75 08             	push   0x8(%ebp)
801085fa:	e8 a9 fa ff ff       	call   801080a8 <mappages>
801085ff:	83 c4 20             	add    $0x20,%esp
80108602:	85 c0                	test   %eax,%eax
80108604:	79 39                	jns    8010863f <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108606:	83 ec 0c             	sub    $0xc,%esp
80108609:	68 49 b7 10 80       	push   $0x8010b749
8010860e:	e8 f9 7d ff ff       	call   8010040c <cprintf>
80108613:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108616:	83 ec 04             	sub    $0x4,%esp
80108619:	ff 75 0c             	push   0xc(%ebp)
8010861c:	ff 75 10             	push   0x10(%ebp)
8010861f:	ff 75 08             	push   0x8(%ebp)
80108622:	e8 30 00 00 00       	call   80108657 <deallocuvm>
80108627:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010862a:	83 ec 0c             	sub    $0xc,%esp
8010862d:	ff 75 f0             	push   -0x10(%ebp)
80108630:	e8 bf a1 ff ff       	call   801027f4 <kfree>
80108635:	83 c4 10             	add    $0x10,%esp
      return 0;
80108638:	b8 00 00 00 00       	mov    $0x0,%eax
8010863d:	eb 16                	jmp    80108655 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010863f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108649:	3b 45 10             	cmp    0x10(%ebp),%eax
8010864c:	0f 82 3c ff ff ff    	jb     8010858e <allocuvm+0x40>
    }
  }
  return newsz;
80108652:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108655:	c9                   	leave
80108656:	c3                   	ret

80108657 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108657:	f3 0f 1e fb          	endbr32
8010865b:	55                   	push   %ebp
8010865c:	89 e5                	mov    %esp,%ebp
8010865e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108661:	8b 45 10             	mov    0x10(%ebp),%eax
80108664:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108667:	72 08                	jb     80108671 <deallocuvm+0x1a>
    return oldsz;
80108669:	8b 45 0c             	mov    0xc(%ebp),%eax
8010866c:	e9 ac 00 00 00       	jmp    8010871d <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80108671:	8b 45 10             	mov    0x10(%ebp),%eax
80108674:	05 ff 0f 00 00       	add    $0xfff,%eax
80108679:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010867e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108681:	e9 88 00 00 00       	jmp    8010870e <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108689:	83 ec 04             	sub    $0x4,%esp
8010868c:	6a 00                	push   $0x0
8010868e:	50                   	push   %eax
8010868f:	ff 75 08             	push   0x8(%ebp)
80108692:	e8 77 f9 ff ff       	call   8010800e <walkpgdir>
80108697:	83 c4 10             	add    $0x10,%esp
8010869a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010869d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086a1:	75 16                	jne    801086b9 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801086a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a6:	c1 e8 16             	shr    $0x16,%eax
801086a9:	83 c0 01             	add    $0x1,%eax
801086ac:	c1 e0 16             	shl    $0x16,%eax
801086af:	2d 00 10 00 00       	sub    $0x1000,%eax
801086b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086b7:	eb 4e                	jmp    80108707 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
801086b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086bc:	8b 00                	mov    (%eax),%eax
801086be:	83 e0 01             	and    $0x1,%eax
801086c1:	85 c0                	test   %eax,%eax
801086c3:	74 42                	je     80108707 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
801086c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c8:	8b 00                	mov    (%eax),%eax
801086ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086d6:	75 0d                	jne    801086e5 <deallocuvm+0x8e>
        panic("kfree");
801086d8:	83 ec 0c             	sub    $0xc,%esp
801086db:	68 65 b7 10 80       	push   $0x8010b765
801086e0:	e8 e0 7e ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
801086e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e8:	05 00 00 00 80       	add    $0x80000000,%eax
801086ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801086f0:	83 ec 0c             	sub    $0xc,%esp
801086f3:	ff 75 e8             	push   -0x18(%ebp)
801086f6:	e8 f9 a0 ff ff       	call   801027f4 <kfree>
801086fb:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801086fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108701:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108707:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010870e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108711:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108714:	0f 82 6c ff ff ff    	jb     80108686 <deallocuvm+0x2f>
    }
  }
  return newsz;
8010871a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010871d:	c9                   	leave
8010871e:	c3                   	ret

8010871f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010871f:	f3 0f 1e fb          	endbr32
80108723:	55                   	push   %ebp
80108724:	89 e5                	mov    %esp,%ebp
80108726:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108729:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010872d:	75 0d                	jne    8010873c <freevm+0x1d>
    panic("freevm: no pgdir");
8010872f:	83 ec 0c             	sub    $0xc,%esp
80108732:	68 6b b7 10 80       	push   $0x8010b76b
80108737:	e8 89 7e ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010873c:	83 ec 04             	sub    $0x4,%esp
8010873f:	6a 00                	push   $0x0
80108741:	68 00 00 00 80       	push   $0x80000000
80108746:	ff 75 08             	push   0x8(%ebp)
80108749:	e8 09 ff ff ff       	call   80108657 <deallocuvm>
8010874e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108758:	eb 48                	jmp    801087a2 <freevm+0x83>
    if(pgdir[i] & PTE_P){
8010875a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108764:	8b 45 08             	mov    0x8(%ebp),%eax
80108767:	01 d0                	add    %edx,%eax
80108769:	8b 00                	mov    (%eax),%eax
8010876b:	83 e0 01             	and    $0x1,%eax
8010876e:	85 c0                	test   %eax,%eax
80108770:	74 2c                	je     8010879e <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108775:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010877c:	8b 45 08             	mov    0x8(%ebp),%eax
8010877f:	01 d0                	add    %edx,%eax
80108781:	8b 00                	mov    (%eax),%eax
80108783:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108788:	05 00 00 00 80       	add    $0x80000000,%eax
8010878d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108790:	83 ec 0c             	sub    $0xc,%esp
80108793:	ff 75 f0             	push   -0x10(%ebp)
80108796:	e8 59 a0 ff ff       	call   801027f4 <kfree>
8010879b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010879e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087a2:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087a9:	76 af                	jbe    8010875a <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801087ab:	83 ec 0c             	sub    $0xc,%esp
801087ae:	ff 75 08             	push   0x8(%ebp)
801087b1:	e8 3e a0 ff ff       	call   801027f4 <kfree>
801087b6:	83 c4 10             	add    $0x10,%esp
}
801087b9:	90                   	nop
801087ba:	c9                   	leave
801087bb:	c3                   	ret

801087bc <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087bc:	f3 0f 1e fb          	endbr32
801087c0:	55                   	push   %ebp
801087c1:	89 e5                	mov    %esp,%ebp
801087c3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087c6:	83 ec 04             	sub    $0x4,%esp
801087c9:	6a 00                	push   $0x0
801087cb:	ff 75 0c             	push   0xc(%ebp)
801087ce:	ff 75 08             	push   0x8(%ebp)
801087d1:	e8 38 f8 ff ff       	call   8010800e <walkpgdir>
801087d6:	83 c4 10             	add    $0x10,%esp
801087d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087e0:	75 0d                	jne    801087ef <clearpteu+0x33>
    panic("clearpteu");
801087e2:	83 ec 0c             	sub    $0xc,%esp
801087e5:	68 7c b7 10 80       	push   $0x8010b77c
801087ea:	e8 d6 7d ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
801087ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f2:	8b 00                	mov    (%eax),%eax
801087f4:	83 e0 fb             	and    $0xfffffffb,%eax
801087f7:	89 c2                	mov    %eax,%edx
801087f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fc:	89 10                	mov    %edx,(%eax)
}
801087fe:	90                   	nop
801087ff:	c9                   	leave
80108800:	c3                   	ret

80108801 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108801:	f3 0f 1e fb          	endbr32
80108805:	55                   	push   %ebp
80108806:	89 e5                	mov    %esp,%ebp
80108808:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010880b:	e8 2c f9 ff ff       	call   8010813c <setupkvm>
80108810:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108817:	75 0a                	jne    80108823 <copyuvm+0x22>
    return 0;
80108819:	b8 00 00 00 00       	mov    $0x0,%eax
8010881e:	e9 eb 00 00 00       	jmp    8010890e <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108823:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010882a:	e9 b7 00 00 00       	jmp    801088e6 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010882f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108832:	83 ec 04             	sub    $0x4,%esp
80108835:	6a 00                	push   $0x0
80108837:	50                   	push   %eax
80108838:	ff 75 08             	push   0x8(%ebp)
8010883b:	e8 ce f7 ff ff       	call   8010800e <walkpgdir>
80108840:	83 c4 10             	add    $0x10,%esp
80108843:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108846:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010884a:	75 0d                	jne    80108859 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
8010884c:	83 ec 0c             	sub    $0xc,%esp
8010884f:	68 86 b7 10 80       	push   $0x8010b786
80108854:	e8 6c 7d ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80108859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010885c:	8b 00                	mov    (%eax),%eax
8010885e:	83 e0 01             	and    $0x1,%eax
80108861:	85 c0                	test   %eax,%eax
80108863:	75 0d                	jne    80108872 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108865:	83 ec 0c             	sub    $0xc,%esp
80108868:	68 a0 b7 10 80       	push   $0x8010b7a0
8010886d:	e8 53 7d ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108872:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108875:	8b 00                	mov    (%eax),%eax
80108877:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010887c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010887f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108882:	8b 00                	mov    (%eax),%eax
80108884:	25 ff 0f 00 00       	and    $0xfff,%eax
80108889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010888c:	e8 01 a0 ff ff       	call   80102892 <kalloc>
80108891:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108894:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108898:	74 5d                	je     801088f7 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010889a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010889d:	05 00 00 00 80       	add    $0x80000000,%eax
801088a2:	83 ec 04             	sub    $0x4,%esp
801088a5:	68 00 10 00 00       	push   $0x1000
801088aa:	50                   	push   %eax
801088ab:	ff 75 e0             	push   -0x20(%ebp)
801088ae:	e8 d2 cd ff ff       	call   80105685 <memmove>
801088b3:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801088b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801088b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088bc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801088c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c5:	83 ec 0c             	sub    $0xc,%esp
801088c8:	52                   	push   %edx
801088c9:	51                   	push   %ecx
801088ca:	68 00 10 00 00       	push   $0x1000
801088cf:	50                   	push   %eax
801088d0:	ff 75 f0             	push   -0x10(%ebp)
801088d3:	e8 d0 f7 ff ff       	call   801080a8 <mappages>
801088d8:	83 c4 20             	add    $0x20,%esp
801088db:	85 c0                	test   %eax,%eax
801088dd:	78 1b                	js     801088fa <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
801088df:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088ec:	0f 82 3d ff ff ff    	jb     8010882f <copyuvm+0x2e>
      goto bad;
  }
  return d;
801088f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088f5:	eb 17                	jmp    8010890e <copyuvm+0x10d>
      goto bad;
801088f7:	90                   	nop
801088f8:	eb 01                	jmp    801088fb <copyuvm+0xfa>
      goto bad;
801088fa:	90                   	nop

bad:
  freevm(d);
801088fb:	83 ec 0c             	sub    $0xc,%esp
801088fe:	ff 75 f0             	push   -0x10(%ebp)
80108901:	e8 19 fe ff ff       	call   8010871f <freevm>
80108906:	83 c4 10             	add    $0x10,%esp
  return 0;
80108909:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010890e:	c9                   	leave
8010890f:	c3                   	ret

80108910 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108910:	f3 0f 1e fb          	endbr32
80108914:	55                   	push   %ebp
80108915:	89 e5                	mov    %esp,%ebp
80108917:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010891a:	83 ec 04             	sub    $0x4,%esp
8010891d:	6a 00                	push   $0x0
8010891f:	ff 75 0c             	push   0xc(%ebp)
80108922:	ff 75 08             	push   0x8(%ebp)
80108925:	e8 e4 f6 ff ff       	call   8010800e <walkpgdir>
8010892a:	83 c4 10             	add    $0x10,%esp
8010892d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108933:	8b 00                	mov    (%eax),%eax
80108935:	83 e0 01             	and    $0x1,%eax
80108938:	85 c0                	test   %eax,%eax
8010893a:	75 07                	jne    80108943 <uva2ka+0x33>
    return 0;
8010893c:	b8 00 00 00 00       	mov    $0x0,%eax
80108941:	eb 22                	jmp    80108965 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108946:	8b 00                	mov    (%eax),%eax
80108948:	83 e0 04             	and    $0x4,%eax
8010894b:	85 c0                	test   %eax,%eax
8010894d:	75 07                	jne    80108956 <uva2ka+0x46>
    return 0;
8010894f:	b8 00 00 00 00       	mov    $0x0,%eax
80108954:	eb 0f                	jmp    80108965 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108959:	8b 00                	mov    (%eax),%eax
8010895b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108960:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108965:	c9                   	leave
80108966:	c3                   	ret

80108967 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108967:	f3 0f 1e fb          	endbr32
8010896b:	55                   	push   %ebp
8010896c:	89 e5                	mov    %esp,%ebp
8010896e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108971:	8b 45 10             	mov    0x10(%ebp),%eax
80108974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108977:	eb 7f                	jmp    801089f8 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108979:	8b 45 0c             	mov    0xc(%ebp),%eax
8010897c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108981:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108984:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108987:	83 ec 08             	sub    $0x8,%esp
8010898a:	50                   	push   %eax
8010898b:	ff 75 08             	push   0x8(%ebp)
8010898e:	e8 7d ff ff ff       	call   80108910 <uva2ka>
80108993:	83 c4 10             	add    $0x10,%esp
80108996:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108999:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010899d:	75 07                	jne    801089a6 <copyout+0x3f>
      return -1;
8010899f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089a4:	eb 61                	jmp    80108a07 <copyout+0xa0>
    n = PGSIZE - (va - va0);
801089a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a9:	2b 45 0c             	sub    0xc(%ebp),%eax
801089ac:	05 00 10 00 00       	add    $0x1000,%eax
801089b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089b7:	3b 45 14             	cmp    0x14(%ebp),%eax
801089ba:	76 06                	jbe    801089c2 <copyout+0x5b>
      n = len;
801089bc:	8b 45 14             	mov    0x14(%ebp),%eax
801089bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801089c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
801089c8:	89 c2                	mov    %eax,%edx
801089ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089cd:	01 d0                	add    %edx,%eax
801089cf:	83 ec 04             	sub    $0x4,%esp
801089d2:	ff 75 f0             	push   -0x10(%ebp)
801089d5:	ff 75 f4             	push   -0xc(%ebp)
801089d8:	50                   	push   %eax
801089d9:	e8 a7 cc ff ff       	call   80105685 <memmove>
801089de:	83 c4 10             	add    $0x10,%esp
    len -= n;
801089e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089e4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ea:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f0:	05 00 10 00 00       	add    $0x1000,%eax
801089f5:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801089f8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801089fc:	0f 85 77 ff ff ff    	jne    80108979 <copyout+0x12>
  }
  return 0;
80108a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a07:	c9                   	leave
80108a08:	c3                   	ret

80108a09 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108a09:	f3 0f 1e fb          	endbr32
80108a0d:	55                   	push   %ebp
80108a0e:	89 e5                	mov    %esp,%ebp
80108a10:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108a13:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108a1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a1d:	8b 40 08             	mov    0x8(%eax),%eax
80108a20:	05 00 00 00 80       	add    $0x80000000,%eax
80108a25:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108a28:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a32:	8b 40 24             	mov    0x24(%eax),%eax
80108a35:	a3 3c 64 19 80       	mov    %eax,0x8019643c
  ncpu = 0;
80108a3a:	c7 05 94 9d 19 80 00 	movl   $0x0,0x80199d94
80108a41:	00 00 00 

  while(i<madt->len){
80108a44:	90                   	nop
80108a45:	e9 bd 00 00 00       	jmp    80108b07 <mpinit_uefi+0xfe>
    uchar *entry_type = ((uchar *)madt)+i;
80108a4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a50:	01 d0                	add    %edx,%eax
80108a52:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a58:	0f b6 00             	movzbl (%eax),%eax
80108a5b:	0f b6 c0             	movzbl %al,%eax
80108a5e:	83 f8 05             	cmp    $0x5,%eax
80108a61:	0f 87 a0 00 00 00    	ja     80108b07 <mpinit_uefi+0xfe>
80108a67:	8b 04 85 bc b7 10 80 	mov    -0x7fef4844(,%eax,4),%eax
80108a6e:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a74:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108a77:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108a7c:	85 c0                	test   %eax,%eax
80108a7e:	7f 28                	jg     80108aa8 <mpinit_uefi+0x9f>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108a80:	8b 15 94 9d 19 80    	mov    0x80199d94,%edx
80108a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a89:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108a8d:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108a93:	81 c2 e0 9c 19 80    	add    $0x80199ce0,%edx
80108a99:	88 02                	mov    %al,(%edx)
          ncpu++;
80108a9b:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108aa0:	83 c0 01             	add    $0x1,%eax
80108aa3:	a3 94 9d 19 80       	mov    %eax,0x80199d94
        }
        i += lapic_entry->record_len;
80108aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aab:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108aaf:	0f b6 c0             	movzbl %al,%eax
80108ab2:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108ab5:	eb 50                	jmp    80108b07 <mpinit_uefi+0xfe>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ac0:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108ac4:	a2 c0 9c 19 80       	mov    %al,0x80199cc0
        i += ioapic->record_len;
80108ac9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108acc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ad0:	0f b6 c0             	movzbl %al,%eax
80108ad3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108ad6:	eb 2f                	jmp    80108b07 <mpinit_uefi+0xfe>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108adb:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108ade:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ae1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ae5:	0f b6 c0             	movzbl %al,%eax
80108ae8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108aeb:	eb 1a                	jmp    80108b07 <mpinit_uefi+0xfe>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108af3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108afa:	0f b6 c0             	movzbl %al,%eax
80108afd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b00:	eb 05                	jmp    80108b07 <mpinit_uefi+0xfe>

      case 5:
        i = i + 0xC;
80108b02:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108b06:	90                   	nop
  while(i<madt->len){
80108b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0a:	8b 40 04             	mov    0x4(%eax),%eax
80108b0d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108b10:	0f 82 34 ff ff ff    	jb     80108a4a <mpinit_uefi+0x41>
    }
  }

}
80108b16:	90                   	nop
80108b17:	90                   	nop
80108b18:	c9                   	leave
80108b19:	c3                   	ret

80108b1a <inb>:
{
80108b1a:	55                   	push   %ebp
80108b1b:	89 e5                	mov    %esp,%ebp
80108b1d:	83 ec 14             	sub    $0x14,%esp
80108b20:	8b 45 08             	mov    0x8(%ebp),%eax
80108b23:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108b27:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108b2b:	89 c2                	mov    %eax,%edx
80108b2d:	ec                   	in     (%dx),%al
80108b2e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108b31:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108b35:	c9                   	leave
80108b36:	c3                   	ret

80108b37 <outb>:
{
80108b37:	55                   	push   %ebp
80108b38:	89 e5                	mov    %esp,%ebp
80108b3a:	83 ec 08             	sub    $0x8,%esp
80108b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108b47:	89 d0                	mov    %edx,%eax
80108b49:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108b4c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108b50:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108b54:	ee                   	out    %al,(%dx)
}
80108b55:	90                   	nop
80108b56:	c9                   	leave
80108b57:	c3                   	ret

80108b58 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108b58:	f3 0f 1e fb          	endbr32
80108b5c:	55                   	push   %ebp
80108b5d:	89 e5                	mov    %esp,%ebp
80108b5f:	83 ec 28             	sub    $0x28,%esp
80108b62:	8b 45 08             	mov    0x8(%ebp),%eax
80108b65:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108b68:	6a 00                	push   $0x0
80108b6a:	68 fa 03 00 00       	push   $0x3fa
80108b6f:	e8 c3 ff ff ff       	call   80108b37 <outb>
80108b74:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108b77:	68 80 00 00 00       	push   $0x80
80108b7c:	68 fb 03 00 00       	push   $0x3fb
80108b81:	e8 b1 ff ff ff       	call   80108b37 <outb>
80108b86:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108b89:	6a 0c                	push   $0xc
80108b8b:	68 f8 03 00 00       	push   $0x3f8
80108b90:	e8 a2 ff ff ff       	call   80108b37 <outb>
80108b95:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108b98:	6a 00                	push   $0x0
80108b9a:	68 f9 03 00 00       	push   $0x3f9
80108b9f:	e8 93 ff ff ff       	call   80108b37 <outb>
80108ba4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108ba7:	6a 03                	push   $0x3
80108ba9:	68 fb 03 00 00       	push   $0x3fb
80108bae:	e8 84 ff ff ff       	call   80108b37 <outb>
80108bb3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108bb6:	6a 00                	push   $0x0
80108bb8:	68 fc 03 00 00       	push   $0x3fc
80108bbd:	e8 75 ff ff ff       	call   80108b37 <outb>
80108bc2:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108bc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bcc:	eb 11                	jmp    80108bdf <uart_debug+0x87>
80108bce:	83 ec 0c             	sub    $0xc,%esp
80108bd1:	6a 0a                	push   $0xa
80108bd3:	e8 6c a0 ff ff       	call   80102c44 <microdelay>
80108bd8:	83 c4 10             	add    $0x10,%esp
80108bdb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bdf:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108be3:	7f 1a                	jg     80108bff <uart_debug+0xa7>
80108be5:	83 ec 0c             	sub    $0xc,%esp
80108be8:	68 fd 03 00 00       	push   $0x3fd
80108bed:	e8 28 ff ff ff       	call   80108b1a <inb>
80108bf2:	83 c4 10             	add    $0x10,%esp
80108bf5:	0f b6 c0             	movzbl %al,%eax
80108bf8:	83 e0 20             	and    $0x20,%eax
80108bfb:	85 c0                	test   %eax,%eax
80108bfd:	74 cf                	je     80108bce <uart_debug+0x76>
  outb(COM1+0, p);
80108bff:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108c03:	0f b6 c0             	movzbl %al,%eax
80108c06:	83 ec 08             	sub    $0x8,%esp
80108c09:	50                   	push   %eax
80108c0a:	68 f8 03 00 00       	push   $0x3f8
80108c0f:	e8 23 ff ff ff       	call   80108b37 <outb>
80108c14:	83 c4 10             	add    $0x10,%esp
}
80108c17:	90                   	nop
80108c18:	c9                   	leave
80108c19:	c3                   	ret

80108c1a <uart_debugs>:

void uart_debugs(char *p){
80108c1a:	f3 0f 1e fb          	endbr32
80108c1e:	55                   	push   %ebp
80108c1f:	89 e5                	mov    %esp,%ebp
80108c21:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108c24:	eb 1b                	jmp    80108c41 <uart_debugs+0x27>
    uart_debug(*p++);
80108c26:	8b 45 08             	mov    0x8(%ebp),%eax
80108c29:	8d 50 01             	lea    0x1(%eax),%edx
80108c2c:	89 55 08             	mov    %edx,0x8(%ebp)
80108c2f:	0f b6 00             	movzbl (%eax),%eax
80108c32:	0f be c0             	movsbl %al,%eax
80108c35:	83 ec 0c             	sub    $0xc,%esp
80108c38:	50                   	push   %eax
80108c39:	e8 1a ff ff ff       	call   80108b58 <uart_debug>
80108c3e:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108c41:	8b 45 08             	mov    0x8(%ebp),%eax
80108c44:	0f b6 00             	movzbl (%eax),%eax
80108c47:	84 c0                	test   %al,%al
80108c49:	75 db                	jne    80108c26 <uart_debugs+0xc>
  }
}
80108c4b:	90                   	nop
80108c4c:	90                   	nop
80108c4d:	c9                   	leave
80108c4e:	c3                   	ret

80108c4f <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108c4f:	f3 0f 1e fb          	endbr32
80108c53:	55                   	push   %ebp
80108c54:	89 e5                	mov    %esp,%ebp
80108c56:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108c59:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c63:	8b 50 14             	mov    0x14(%eax),%edx
80108c66:	8b 40 10             	mov    0x10(%eax),%eax
80108c69:	a3 98 9d 19 80       	mov    %eax,0x80199d98
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108c6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c71:	8b 50 1c             	mov    0x1c(%eax),%edx
80108c74:	8b 40 18             	mov    0x18(%eax),%eax
80108c77:	a3 a0 9d 19 80       	mov    %eax,0x80199da0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108c7c:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108c81:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108c86:	29 c2                	sub    %eax,%edx
80108c88:	89 d0                	mov    %edx,%eax
80108c8a:	a3 9c 9d 19 80       	mov    %eax,0x80199d9c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108c8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c92:	8b 50 24             	mov    0x24(%eax),%edx
80108c95:	8b 40 20             	mov    0x20(%eax),%eax
80108c98:	a3 a4 9d 19 80       	mov    %eax,0x80199da4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ca0:	8b 50 2c             	mov    0x2c(%eax),%edx
80108ca3:	8b 40 28             	mov    0x28(%eax),%eax
80108ca6:	a3 a8 9d 19 80       	mov    %eax,0x80199da8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108cab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cae:	8b 50 34             	mov    0x34(%eax),%edx
80108cb1:	8b 40 30             	mov    0x30(%eax),%eax
80108cb4:	a3 ac 9d 19 80       	mov    %eax,0x80199dac
}
80108cb9:	90                   	nop
80108cba:	c9                   	leave
80108cbb:	c3                   	ret

80108cbc <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108cbc:	f3 0f 1e fb          	endbr32
80108cc0:	55                   	push   %ebp
80108cc1:	89 e5                	mov    %esp,%ebp
80108cc3:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108cc6:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ccf:	0f af d0             	imul   %eax,%edx
80108cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd5:	01 d0                	add    %edx,%eax
80108cd7:	c1 e0 02             	shl    $0x2,%eax
80108cda:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108cdd:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108ce3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ce6:	01 d0                	add    %edx,%eax
80108ce8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108ceb:	8b 45 10             	mov    0x10(%ebp),%eax
80108cee:	0f b6 10             	movzbl (%eax),%edx
80108cf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108cf4:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108cf6:	8b 45 10             	mov    0x10(%ebp),%eax
80108cf9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108cfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d00:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108d03:	8b 45 10             	mov    0x10(%ebp),%eax
80108d06:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108d0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d0d:	88 50 02             	mov    %dl,0x2(%eax)
}
80108d10:	90                   	nop
80108d11:	c9                   	leave
80108d12:	c3                   	ret

80108d13 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108d13:	f3 0f 1e fb          	endbr32
80108d17:	55                   	push   %ebp
80108d18:	89 e5                	mov    %esp,%ebp
80108d1a:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108d1d:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108d23:	8b 45 08             	mov    0x8(%ebp),%eax
80108d26:	0f af c2             	imul   %edx,%eax
80108d29:	c1 e0 02             	shl    $0x2,%eax
80108d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108d2f:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d38:	29 c2                	sub    %eax,%edx
80108d3a:	89 d0                	mov    %edx,%eax
80108d3c:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108d42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d45:	01 ca                	add    %ecx,%edx
80108d47:	89 d1                	mov    %edx,%ecx
80108d49:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108d4f:	83 ec 04             	sub    $0x4,%esp
80108d52:	50                   	push   %eax
80108d53:	51                   	push   %ecx
80108d54:	52                   	push   %edx
80108d55:	e8 2b c9 ff ff       	call   80105685 <memmove>
80108d5a:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d60:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108d66:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108d6c:	01 d1                	add    %edx,%ecx
80108d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d71:	29 d1                	sub    %edx,%ecx
80108d73:	89 ca                	mov    %ecx,%edx
80108d75:	83 ec 04             	sub    $0x4,%esp
80108d78:	50                   	push   %eax
80108d79:	6a 00                	push   $0x0
80108d7b:	52                   	push   %edx
80108d7c:	e8 3d c8 ff ff       	call   801055be <memset>
80108d81:	83 c4 10             	add    $0x10,%esp
}
80108d84:	90                   	nop
80108d85:	c9                   	leave
80108d86:	c3                   	ret

80108d87 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108d87:	f3 0f 1e fb          	endbr32
80108d8b:	55                   	push   %ebp
80108d8c:	89 e5                	mov    %esp,%ebp
80108d8e:	53                   	push   %ebx
80108d8f:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108d92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d99:	e9 b1 00 00 00       	jmp    80108e4f <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108d9e:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108da5:	e9 97 00 00 00       	jmp    80108e41 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108daa:	8b 45 10             	mov    0x10(%ebp),%eax
80108dad:	83 e8 20             	sub    $0x20,%eax
80108db0:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db6:	01 d0                	add    %edx,%eax
80108db8:	0f b7 84 00 e0 b7 10 	movzwl -0x7fef4820(%eax,%eax,1),%eax
80108dbf:	80 
80108dc0:	0f b7 d0             	movzwl %ax,%edx
80108dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc6:	bb 01 00 00 00       	mov    $0x1,%ebx
80108dcb:	89 c1                	mov    %eax,%ecx
80108dcd:	d3 e3                	shl    %cl,%ebx
80108dcf:	89 d8                	mov    %ebx,%eax
80108dd1:	21 d0                	and    %edx,%eax
80108dd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd9:	ba 01 00 00 00       	mov    $0x1,%edx
80108dde:	89 c1                	mov    %eax,%ecx
80108de0:	d3 e2                	shl    %cl,%edx
80108de2:	89 d0                	mov    %edx,%eax
80108de4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108de7:	75 2b                	jne    80108e14 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108de9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108def:	01 c2                	add    %eax,%edx
80108df1:	b8 0e 00 00 00       	mov    $0xe,%eax
80108df6:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108df9:	89 c1                	mov    %eax,%ecx
80108dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80108dfe:	01 c8                	add    %ecx,%eax
80108e00:	83 ec 04             	sub    $0x4,%esp
80108e03:	68 00 05 11 80       	push   $0x80110500
80108e08:	52                   	push   %edx
80108e09:	50                   	push   %eax
80108e0a:	e8 ad fe ff ff       	call   80108cbc <graphic_draw_pixel>
80108e0f:	83 c4 10             	add    $0x10,%esp
80108e12:	eb 29                	jmp    80108e3d <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108e14:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1a:	01 c2                	add    %eax,%edx
80108e1c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108e21:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108e24:	89 c1                	mov    %eax,%ecx
80108e26:	8b 45 08             	mov    0x8(%ebp),%eax
80108e29:	01 c8                	add    %ecx,%eax
80108e2b:	83 ec 04             	sub    $0x4,%esp
80108e2e:	68 84 e0 18 80       	push   $0x8018e084
80108e33:	52                   	push   %edx
80108e34:	50                   	push   %eax
80108e35:	e8 82 fe ff ff       	call   80108cbc <graphic_draw_pixel>
80108e3a:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108e3d:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108e41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e45:	0f 89 5f ff ff ff    	jns    80108daa <font_render+0x23>
  for(int i=0;i<30;i++){
80108e4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e4f:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108e53:	0f 8e 45 ff ff ff    	jle    80108d9e <font_render+0x17>
      }
    }
  }
}
80108e59:	90                   	nop
80108e5a:	90                   	nop
80108e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e5e:	c9                   	leave
80108e5f:	c3                   	ret

80108e60 <font_render_string>:

void font_render_string(char *string,int row){
80108e60:	f3 0f 1e fb          	endbr32
80108e64:	55                   	push   %ebp
80108e65:	89 e5                	mov    %esp,%ebp
80108e67:	53                   	push   %ebx
80108e68:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108e6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108e72:	eb 33                	jmp    80108ea7 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e77:	8b 45 08             	mov    0x8(%ebp),%eax
80108e7a:	01 d0                	add    %edx,%eax
80108e7c:	0f b6 00             	movzbl (%eax),%eax
80108e7f:	0f be d8             	movsbl %al,%ebx
80108e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e85:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e8b:	89 d0                	mov    %edx,%eax
80108e8d:	c1 e0 04             	shl    $0x4,%eax
80108e90:	29 d0                	sub    %edx,%eax
80108e92:	83 c0 02             	add    $0x2,%eax
80108e95:	83 ec 04             	sub    $0x4,%esp
80108e98:	53                   	push   %ebx
80108e99:	51                   	push   %ecx
80108e9a:	50                   	push   %eax
80108e9b:	e8 e7 fe ff ff       	call   80108d87 <font_render>
80108ea0:	83 c4 10             	add    $0x10,%esp
    i++;
80108ea3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108ea7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80108ead:	01 d0                	add    %edx,%eax
80108eaf:	0f b6 00             	movzbl (%eax),%eax
80108eb2:	84 c0                	test   %al,%al
80108eb4:	74 06                	je     80108ebc <font_render_string+0x5c>
80108eb6:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108eba:	7e b8                	jle    80108e74 <font_render_string+0x14>
  }
}
80108ebc:	90                   	nop
80108ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ec0:	c9                   	leave
80108ec1:	c3                   	ret

80108ec2 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108ec2:	f3 0f 1e fb          	endbr32
80108ec6:	55                   	push   %ebp
80108ec7:	89 e5                	mov    %esp,%ebp
80108ec9:	53                   	push   %ebx
80108eca:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108ecd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ed4:	eb 6b                	jmp    80108f41 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108ed6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108edd:	eb 58                	jmp    80108f37 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108edf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108ee6:	eb 45                	jmp    80108f2d <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108ee8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108eeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef1:	83 ec 0c             	sub    $0xc,%esp
80108ef4:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108ef7:	53                   	push   %ebx
80108ef8:	6a 00                	push   $0x0
80108efa:	51                   	push   %ecx
80108efb:	52                   	push   %edx
80108efc:	50                   	push   %eax
80108efd:	e8 c0 00 00 00       	call   80108fc2 <pci_access_config>
80108f02:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108f05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f08:	0f b7 c0             	movzwl %ax,%eax
80108f0b:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108f10:	74 17                	je     80108f29 <pci_init+0x67>
        pci_init_device(i,j,k);
80108f12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108f15:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1b:	83 ec 04             	sub    $0x4,%esp
80108f1e:	51                   	push   %ecx
80108f1f:	52                   	push   %edx
80108f20:	50                   	push   %eax
80108f21:	e8 4f 01 00 00       	call   80109075 <pci_init_device>
80108f26:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108f29:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f2d:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108f31:	7e b5                	jle    80108ee8 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108f33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f37:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108f3b:	7e a2                	jle    80108edf <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108f3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f41:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f48:	7e 8c                	jle    80108ed6 <pci_init+0x14>
      }
      }
    }
  }
}
80108f4a:	90                   	nop
80108f4b:	90                   	nop
80108f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f4f:	c9                   	leave
80108f50:	c3                   	ret

80108f51 <pci_write_config>:

void pci_write_config(uint config){
80108f51:	f3 0f 1e fb          	endbr32
80108f55:	55                   	push   %ebp
80108f56:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108f58:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5b:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108f60:	89 c0                	mov    %eax,%eax
80108f62:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108f63:	90                   	nop
80108f64:	5d                   	pop    %ebp
80108f65:	c3                   	ret

80108f66 <pci_write_data>:

void pci_write_data(uint config){
80108f66:	f3 0f 1e fb          	endbr32
80108f6a:	55                   	push   %ebp
80108f6b:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f70:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108f75:	89 c0                	mov    %eax,%eax
80108f77:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108f78:	90                   	nop
80108f79:	5d                   	pop    %ebp
80108f7a:	c3                   	ret

80108f7b <pci_read_config>:
uint pci_read_config(){
80108f7b:	f3 0f 1e fb          	endbr32
80108f7f:	55                   	push   %ebp
80108f80:	89 e5                	mov    %esp,%ebp
80108f82:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108f85:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108f8a:	ed                   	in     (%dx),%eax
80108f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108f8e:	83 ec 0c             	sub    $0xc,%esp
80108f91:	68 c8 00 00 00       	push   $0xc8
80108f96:	e8 a9 9c ff ff       	call   80102c44 <microdelay>
80108f9b:	83 c4 10             	add    $0x10,%esp
  return data;
80108f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108fa1:	c9                   	leave
80108fa2:	c3                   	ret

80108fa3 <pci_test>:


void pci_test(){
80108fa3:	f3 0f 1e fb          	endbr32
80108fa7:	55                   	push   %ebp
80108fa8:	89 e5                	mov    %esp,%ebp
80108faa:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108fad:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108fb4:	ff 75 fc             	push   -0x4(%ebp)
80108fb7:	e8 95 ff ff ff       	call   80108f51 <pci_write_config>
80108fbc:	83 c4 04             	add    $0x4,%esp
}
80108fbf:	90                   	nop
80108fc0:	c9                   	leave
80108fc1:	c3                   	ret

80108fc2 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108fc2:	f3 0f 1e fb          	endbr32
80108fc6:	55                   	push   %ebp
80108fc7:	89 e5                	mov    %esp,%ebp
80108fc9:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80108fcf:	c1 e0 10             	shl    $0x10,%eax
80108fd2:	25 00 00 ff 00       	and    $0xff0000,%eax
80108fd7:	89 c2                	mov    %eax,%edx
80108fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fdc:	c1 e0 0b             	shl    $0xb,%eax
80108fdf:	0f b7 c0             	movzwl %ax,%eax
80108fe2:	09 c2                	or     %eax,%edx
80108fe4:	8b 45 10             	mov    0x10(%ebp),%eax
80108fe7:	c1 e0 08             	shl    $0x8,%eax
80108fea:	25 00 07 00 00       	and    $0x700,%eax
80108fef:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108ff1:	8b 45 14             	mov    0x14(%ebp),%eax
80108ff4:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ff9:	09 d0                	or     %edx,%eax
80108ffb:	0d 00 00 00 80       	or     $0x80000000,%eax
80109000:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80109003:	ff 75 f4             	push   -0xc(%ebp)
80109006:	e8 46 ff ff ff       	call   80108f51 <pci_write_config>
8010900b:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010900e:	e8 68 ff ff ff       	call   80108f7b <pci_read_config>
80109013:	8b 55 18             	mov    0x18(%ebp),%edx
80109016:	89 02                	mov    %eax,(%edx)
}
80109018:	90                   	nop
80109019:	c9                   	leave
8010901a:	c3                   	ret

8010901b <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010901b:	f3 0f 1e fb          	endbr32
8010901f:	55                   	push   %ebp
80109020:	89 e5                	mov    %esp,%ebp
80109022:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109025:	8b 45 08             	mov    0x8(%ebp),%eax
80109028:	c1 e0 10             	shl    $0x10,%eax
8010902b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109030:	89 c2                	mov    %eax,%edx
80109032:	8b 45 0c             	mov    0xc(%ebp),%eax
80109035:	c1 e0 0b             	shl    $0xb,%eax
80109038:	0f b7 c0             	movzwl %ax,%eax
8010903b:	09 c2                	or     %eax,%edx
8010903d:	8b 45 10             	mov    0x10(%ebp),%eax
80109040:	c1 e0 08             	shl    $0x8,%eax
80109043:	25 00 07 00 00       	and    $0x700,%eax
80109048:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010904a:	8b 45 14             	mov    0x14(%ebp),%eax
8010904d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109052:	09 d0                	or     %edx,%eax
80109054:	0d 00 00 00 80       	or     $0x80000000,%eax
80109059:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010905c:	ff 75 fc             	push   -0x4(%ebp)
8010905f:	e8 ed fe ff ff       	call   80108f51 <pci_write_config>
80109064:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80109067:	ff 75 18             	push   0x18(%ebp)
8010906a:	e8 f7 fe ff ff       	call   80108f66 <pci_write_data>
8010906f:	83 c4 04             	add    $0x4,%esp
}
80109072:	90                   	nop
80109073:	c9                   	leave
80109074:	c3                   	ret

80109075 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80109075:	f3 0f 1e fb          	endbr32
80109079:	55                   	push   %ebp
8010907a:	89 e5                	mov    %esp,%ebp
8010907c:	53                   	push   %ebx
8010907d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80109080:	8b 45 08             	mov    0x8(%ebp),%eax
80109083:	a2 b0 9d 19 80       	mov    %al,0x80199db0
  dev.device_num = device_num;
80109088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010908b:	a2 b1 9d 19 80       	mov    %al,0x80199db1
  dev.function_num = function_num;
80109090:	8b 45 10             	mov    0x10(%ebp),%eax
80109093:	a2 b2 9d 19 80       	mov    %al,0x80199db2
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80109098:	ff 75 10             	push   0x10(%ebp)
8010909b:	ff 75 0c             	push   0xc(%ebp)
8010909e:	ff 75 08             	push   0x8(%ebp)
801090a1:	68 24 ce 10 80       	push   $0x8010ce24
801090a6:	e8 61 73 ff ff       	call   8010040c <cprintf>
801090ab:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801090ae:	83 ec 0c             	sub    $0xc,%esp
801090b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090b4:	50                   	push   %eax
801090b5:	6a 00                	push   $0x0
801090b7:	ff 75 10             	push   0x10(%ebp)
801090ba:	ff 75 0c             	push   0xc(%ebp)
801090bd:	ff 75 08             	push   0x8(%ebp)
801090c0:	e8 fd fe ff ff       	call   80108fc2 <pci_access_config>
801090c5:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801090c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090cb:	c1 e8 10             	shr    $0x10,%eax
801090ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801090d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090d4:	25 ff ff 00 00       	and    $0xffff,%eax
801090d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801090dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090df:	a3 b4 9d 19 80       	mov    %eax,0x80199db4
  dev.vendor_id = vendor_id;
801090e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e7:	a3 b8 9d 19 80       	mov    %eax,0x80199db8
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801090ec:	83 ec 04             	sub    $0x4,%esp
801090ef:	ff 75 f0             	push   -0x10(%ebp)
801090f2:	ff 75 f4             	push   -0xc(%ebp)
801090f5:	68 58 ce 10 80       	push   $0x8010ce58
801090fa:	e8 0d 73 ff ff       	call   8010040c <cprintf>
801090ff:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80109102:	83 ec 0c             	sub    $0xc,%esp
80109105:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109108:	50                   	push   %eax
80109109:	6a 08                	push   $0x8
8010910b:	ff 75 10             	push   0x10(%ebp)
8010910e:	ff 75 0c             	push   0xc(%ebp)
80109111:	ff 75 08             	push   0x8(%ebp)
80109114:	e8 a9 fe ff ff       	call   80108fc2 <pci_access_config>
80109119:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010911c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010911f:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80109122:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109125:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109128:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010912b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010912e:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109131:	0f b6 c0             	movzbl %al,%eax
80109134:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80109137:	c1 eb 18             	shr    $0x18,%ebx
8010913a:	83 ec 0c             	sub    $0xc,%esp
8010913d:	51                   	push   %ecx
8010913e:	52                   	push   %edx
8010913f:	50                   	push   %eax
80109140:	53                   	push   %ebx
80109141:	68 7c ce 10 80       	push   $0x8010ce7c
80109146:	e8 c1 72 ff ff       	call   8010040c <cprintf>
8010914b:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010914e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109151:	c1 e8 18             	shr    $0x18,%eax
80109154:	a2 bc 9d 19 80       	mov    %al,0x80199dbc
  dev.sub_class = (data>>16)&0xFF;
80109159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010915c:	c1 e8 10             	shr    $0x10,%eax
8010915f:	a2 bd 9d 19 80       	mov    %al,0x80199dbd
  dev.interface = (data>>8)&0xFF;
80109164:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109167:	c1 e8 08             	shr    $0x8,%eax
8010916a:	a2 be 9d 19 80       	mov    %al,0x80199dbe
  dev.revision_id = data&0xFF;
8010916f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109172:	a2 bf 9d 19 80       	mov    %al,0x80199dbf
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80109177:	83 ec 0c             	sub    $0xc,%esp
8010917a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010917d:	50                   	push   %eax
8010917e:	6a 10                	push   $0x10
80109180:	ff 75 10             	push   0x10(%ebp)
80109183:	ff 75 0c             	push   0xc(%ebp)
80109186:	ff 75 08             	push   0x8(%ebp)
80109189:	e8 34 fe ff ff       	call   80108fc2 <pci_access_config>
8010918e:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80109191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109194:	a3 c0 9d 19 80       	mov    %eax,0x80199dc0
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80109199:	83 ec 0c             	sub    $0xc,%esp
8010919c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010919f:	50                   	push   %eax
801091a0:	6a 14                	push   $0x14
801091a2:	ff 75 10             	push   0x10(%ebp)
801091a5:	ff 75 0c             	push   0xc(%ebp)
801091a8:	ff 75 08             	push   0x8(%ebp)
801091ab:	e8 12 fe ff ff       	call   80108fc2 <pci_access_config>
801091b0:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801091b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091b6:	a3 c4 9d 19 80       	mov    %eax,0x80199dc4
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801091bb:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801091c2:	75 5a                	jne    8010921e <pci_init_device+0x1a9>
801091c4:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801091cb:	75 51                	jne    8010921e <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801091cd:	83 ec 0c             	sub    $0xc,%esp
801091d0:	68 c1 ce 10 80       	push   $0x8010cec1
801091d5:	e8 32 72 ff ff       	call   8010040c <cprintf>
801091da:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801091dd:	83 ec 0c             	sub    $0xc,%esp
801091e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091e3:	50                   	push   %eax
801091e4:	68 f0 00 00 00       	push   $0xf0
801091e9:	ff 75 10             	push   0x10(%ebp)
801091ec:	ff 75 0c             	push   0xc(%ebp)
801091ef:	ff 75 08             	push   0x8(%ebp)
801091f2:	e8 cb fd ff ff       	call   80108fc2 <pci_access_config>
801091f7:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801091fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091fd:	83 ec 08             	sub    $0x8,%esp
80109200:	50                   	push   %eax
80109201:	68 db ce 10 80       	push   $0x8010cedb
80109206:	e8 01 72 ff ff       	call   8010040c <cprintf>
8010920b:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010920e:	83 ec 0c             	sub    $0xc,%esp
80109211:	68 b0 9d 19 80       	push   $0x80199db0
80109216:	e8 09 00 00 00       	call   80109224 <i8254_init>
8010921b:	83 c4 10             	add    $0x10,%esp
  }
}
8010921e:	90                   	nop
8010921f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109222:	c9                   	leave
80109223:	c3                   	ret

80109224 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80109224:	f3 0f 1e fb          	endbr32
80109228:	55                   	push   %ebp
80109229:	89 e5                	mov    %esp,%ebp
8010922b:	53                   	push   %ebx
8010922c:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010922f:	8b 45 08             	mov    0x8(%ebp),%eax
80109232:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109236:	0f b6 c8             	movzbl %al,%ecx
80109239:	8b 45 08             	mov    0x8(%ebp),%eax
8010923c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109240:	0f b6 d0             	movzbl %al,%edx
80109243:	8b 45 08             	mov    0x8(%ebp),%eax
80109246:	0f b6 00             	movzbl (%eax),%eax
80109249:	0f b6 c0             	movzbl %al,%eax
8010924c:	83 ec 0c             	sub    $0xc,%esp
8010924f:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80109252:	53                   	push   %ebx
80109253:	6a 04                	push   $0x4
80109255:	51                   	push   %ecx
80109256:	52                   	push   %edx
80109257:	50                   	push   %eax
80109258:	e8 65 fd ff ff       	call   80108fc2 <pci_access_config>
8010925d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80109260:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109263:	83 c8 04             	or     $0x4,%eax
80109266:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80109269:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010926c:	8b 45 08             	mov    0x8(%ebp),%eax
8010926f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109273:	0f b6 c8             	movzbl %al,%ecx
80109276:	8b 45 08             	mov    0x8(%ebp),%eax
80109279:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010927d:	0f b6 d0             	movzbl %al,%edx
80109280:	8b 45 08             	mov    0x8(%ebp),%eax
80109283:	0f b6 00             	movzbl (%eax),%eax
80109286:	0f b6 c0             	movzbl %al,%eax
80109289:	83 ec 0c             	sub    $0xc,%esp
8010928c:	53                   	push   %ebx
8010928d:	6a 04                	push   $0x4
8010928f:	51                   	push   %ecx
80109290:	52                   	push   %edx
80109291:	50                   	push   %eax
80109292:	e8 84 fd ff ff       	call   8010901b <pci_write_config_register>
80109297:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010929a:	8b 45 08             	mov    0x8(%ebp),%eax
8010929d:	8b 40 10             	mov    0x10(%eax),%eax
801092a0:	05 00 00 00 40       	add    $0x40000000,%eax
801092a5:	a3 c8 9d 19 80       	mov    %eax,0x80199dc8
  uint *ctrl = (uint *)base_addr;
801092aa:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801092b2:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092b7:	05 d8 00 00 00       	add    $0xd8,%eax
801092bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801092bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c2:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801092c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cb:	8b 00                	mov    (%eax),%eax
801092cd:	0d 00 00 00 04       	or     $0x4000000,%eax
801092d2:	89 c2                	mov    %eax,%edx
801092d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d7:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801092d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092dc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801092e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e5:	8b 00                	mov    (%eax),%eax
801092e7:	83 c8 40             	or     $0x40,%eax
801092ea:	89 c2                	mov    %eax,%edx
801092ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ef:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801092f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f4:	8b 10                	mov    (%eax),%edx
801092f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801092fb:	83 ec 0c             	sub    $0xc,%esp
801092fe:	68 f0 ce 10 80       	push   $0x8010cef0
80109303:	e8 04 71 ff ff       	call   8010040c <cprintf>
80109308:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010930b:	e8 82 95 ff ff       	call   80102892 <kalloc>
80109310:	a3 cc 9d 19 80       	mov    %eax,0x80199dcc
  *intr_addr = 0;
80109315:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
8010931a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109320:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109325:	83 ec 08             	sub    $0x8,%esp
80109328:	50                   	push   %eax
80109329:	68 12 cf 10 80       	push   $0x8010cf12
8010932e:	e8 d9 70 ff ff       	call   8010040c <cprintf>
80109333:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109336:	e8 50 00 00 00       	call   8010938b <i8254_init_recv>
  i8254_init_send();
8010933b:	e8 6d 03 00 00       	call   801096ad <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80109340:	0f b6 05 07 05 11 80 	movzbl 0x80110507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109347:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010934a:	0f b6 05 06 05 11 80 	movzbl 0x80110506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109351:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109354:	0f b6 05 05 05 11 80 	movzbl 0x80110505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010935b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010935e:	0f b6 05 04 05 11 80 	movzbl 0x80110504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109365:	0f b6 c0             	movzbl %al,%eax
80109368:	83 ec 0c             	sub    $0xc,%esp
8010936b:	53                   	push   %ebx
8010936c:	51                   	push   %ecx
8010936d:	52                   	push   %edx
8010936e:	50                   	push   %eax
8010936f:	68 20 cf 10 80       	push   $0x8010cf20
80109374:	e8 93 70 ff ff       	call   8010040c <cprintf>
80109379:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010937c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80109385:	90                   	nop
80109386:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109389:	c9                   	leave
8010938a:	c3                   	ret

8010938b <i8254_init_recv>:

void i8254_init_recv(){
8010938b:	f3 0f 1e fb          	endbr32
8010938f:	55                   	push   %ebp
80109390:	89 e5                	mov    %esp,%ebp
80109392:	57                   	push   %edi
80109393:	56                   	push   %esi
80109394:	53                   	push   %ebx
80109395:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80109398:	83 ec 0c             	sub    $0xc,%esp
8010939b:	6a 00                	push   $0x0
8010939d:	e8 ec 04 00 00       	call   8010988e <i8254_read_eeprom>
801093a2:	83 c4 10             	add    $0x10,%esp
801093a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801093a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093ab:	a2 88 e0 18 80       	mov    %al,0x8018e088
  mac_addr[1] = data_l>>8;
801093b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093b3:	c1 e8 08             	shr    $0x8,%eax
801093b6:	a2 89 e0 18 80       	mov    %al,0x8018e089
  uint data_m = i8254_read_eeprom(0x1);
801093bb:	83 ec 0c             	sub    $0xc,%esp
801093be:	6a 01                	push   $0x1
801093c0:	e8 c9 04 00 00       	call   8010988e <i8254_read_eeprom>
801093c5:	83 c4 10             	add    $0x10,%esp
801093c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801093cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093ce:	a2 8a e0 18 80       	mov    %al,0x8018e08a
  mac_addr[3] = data_m>>8;
801093d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093d6:	c1 e8 08             	shr    $0x8,%eax
801093d9:	a2 8b e0 18 80       	mov    %al,0x8018e08b
  uint data_h = i8254_read_eeprom(0x2);
801093de:	83 ec 0c             	sub    $0xc,%esp
801093e1:	6a 02                	push   $0x2
801093e3:	e8 a6 04 00 00       	call   8010988e <i8254_read_eeprom>
801093e8:	83 c4 10             	add    $0x10,%esp
801093eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801093ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093f1:	a2 8c e0 18 80       	mov    %al,0x8018e08c
  mac_addr[5] = data_h>>8;
801093f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093f9:	c1 e8 08             	shr    $0x8,%eax
801093fc:	a2 8d e0 18 80       	mov    %al,0x8018e08d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109401:	0f b6 05 8d e0 18 80 	movzbl 0x8018e08d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109408:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010940b:	0f b6 05 8c e0 18 80 	movzbl 0x8018e08c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109412:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109415:	0f b6 05 8b e0 18 80 	movzbl 0x8018e08b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010941c:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010941f:	0f b6 05 8a e0 18 80 	movzbl 0x8018e08a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109426:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80109429:	0f b6 05 89 e0 18 80 	movzbl 0x8018e089,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109430:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109433:	0f b6 05 88 e0 18 80 	movzbl 0x8018e088,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010943a:	0f b6 c0             	movzbl %al,%eax
8010943d:	83 ec 04             	sub    $0x4,%esp
80109440:	57                   	push   %edi
80109441:	56                   	push   %esi
80109442:	53                   	push   %ebx
80109443:	51                   	push   %ecx
80109444:	52                   	push   %edx
80109445:	50                   	push   %eax
80109446:	68 38 cf 10 80       	push   $0x8010cf38
8010944b:	e8 bc 6f ff ff       	call   8010040c <cprintf>
80109450:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109453:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109458:	05 00 54 00 00       	add    $0x5400,%eax
8010945d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80109460:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109465:	05 04 54 00 00       	add    $0x5404,%eax
8010946a:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010946d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109470:	c1 e0 10             	shl    $0x10,%eax
80109473:	0b 45 d8             	or     -0x28(%ebp),%eax
80109476:	89 c2                	mov    %eax,%edx
80109478:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010947b:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010947d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109480:	0d 00 00 00 80       	or     $0x80000000,%eax
80109485:	89 c2                	mov    %eax,%edx
80109487:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010948a:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010948c:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109491:	05 00 52 00 00       	add    $0x5200,%eax
80109496:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80109499:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801094a0:	eb 19                	jmp    801094bb <i8254_init_recv+0x130>
    mta[i] = 0;
801094a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801094a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094ac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801094af:	01 d0                	add    %edx,%eax
801094b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801094b7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801094bb:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801094bf:	7e e1                	jle    801094a2 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801094c1:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094c6:	05 d0 00 00 00       	add    $0xd0,%eax
801094cb:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801094ce:	8b 45 c0             	mov    -0x40(%ebp),%eax
801094d1:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801094d7:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094dc:	05 c8 00 00 00       	add    $0xc8,%eax
801094e1:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801094e4:	8b 45 bc             	mov    -0x44(%ebp),%eax
801094e7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801094ed:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094f2:	05 28 28 00 00       	add    $0x2828,%eax
801094f7:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801094fa:	8b 45 b8             	mov    -0x48(%ebp),%eax
801094fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109503:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109508:	05 00 01 00 00       	add    $0x100,%eax
8010950d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109510:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109513:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109519:	e8 74 93 ff ff       	call   80102892 <kalloc>
8010951e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109521:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109526:	05 00 28 00 00       	add    $0x2800,%eax
8010952b:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010952e:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109533:	05 04 28 00 00       	add    $0x2804,%eax
80109538:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010953b:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109540:	05 08 28 00 00       	add    $0x2808,%eax
80109545:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109548:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010954d:	05 10 28 00 00       	add    $0x2810,%eax
80109552:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109555:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010955a:	05 18 28 00 00       	add    $0x2818,%eax
8010955f:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109562:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109565:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010956b:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010956e:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109570:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109573:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80109579:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010957c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109582:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109585:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010958b:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010958e:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109594:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109597:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010959a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801095a1:	eb 73                	jmp    80109616 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
801095a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095a6:	c1 e0 04             	shl    $0x4,%eax
801095a9:	89 c2                	mov    %eax,%edx
801095ab:	8b 45 98             	mov    -0x68(%ebp),%eax
801095ae:	01 d0                	add    %edx,%eax
801095b0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801095b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095ba:	c1 e0 04             	shl    $0x4,%eax
801095bd:	89 c2                	mov    %eax,%edx
801095bf:	8b 45 98             	mov    -0x68(%ebp),%eax
801095c2:	01 d0                	add    %edx,%eax
801095c4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801095ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095cd:	c1 e0 04             	shl    $0x4,%eax
801095d0:	89 c2                	mov    %eax,%edx
801095d2:	8b 45 98             	mov    -0x68(%ebp),%eax
801095d5:	01 d0                	add    %edx,%eax
801095d7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801095dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095e0:	c1 e0 04             	shl    $0x4,%eax
801095e3:	89 c2                	mov    %eax,%edx
801095e5:	8b 45 98             	mov    -0x68(%ebp),%eax
801095e8:	01 d0                	add    %edx,%eax
801095ea:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801095ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095f1:	c1 e0 04             	shl    $0x4,%eax
801095f4:	89 c2                	mov    %eax,%edx
801095f6:	8b 45 98             	mov    -0x68(%ebp),%eax
801095f9:	01 d0                	add    %edx,%eax
801095fb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801095ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109602:	c1 e0 04             	shl    $0x4,%eax
80109605:	89 c2                	mov    %eax,%edx
80109607:	8b 45 98             	mov    -0x68(%ebp),%eax
8010960a:	01 d0                	add    %edx,%eax
8010960c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109612:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109616:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010961d:	7e 84                	jle    801095a3 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010961f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109626:	eb 57                	jmp    8010967f <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109628:	e8 65 92 ff ff       	call   80102892 <kalloc>
8010962d:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109630:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109634:	75 12                	jne    80109648 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109636:	83 ec 0c             	sub    $0xc,%esp
80109639:	68 58 cf 10 80       	push   $0x8010cf58
8010963e:	e8 c9 6d ff ff       	call   8010040c <cprintf>
80109643:	83 c4 10             	add    $0x10,%esp
      break;
80109646:	eb 3d                	jmp    80109685 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109648:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010964b:	c1 e0 04             	shl    $0x4,%eax
8010964e:	89 c2                	mov    %eax,%edx
80109650:	8b 45 98             	mov    -0x68(%ebp),%eax
80109653:	01 d0                	add    %edx,%eax
80109655:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109658:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010965e:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109660:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109663:	83 c0 01             	add    $0x1,%eax
80109666:	c1 e0 04             	shl    $0x4,%eax
80109669:	89 c2                	mov    %eax,%edx
8010966b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010966e:	01 d0                	add    %edx,%eax
80109670:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109673:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109679:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010967b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010967f:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109683:	7e a3                	jle    80109628 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80109685:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109688:	8b 00                	mov    (%eax),%eax
8010968a:	83 c8 02             	or     $0x2,%eax
8010968d:	89 c2                	mov    %eax,%edx
8010968f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109692:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109694:	83 ec 0c             	sub    $0xc,%esp
80109697:	68 78 cf 10 80       	push   $0x8010cf78
8010969c:	e8 6b 6d ff ff       	call   8010040c <cprintf>
801096a1:	83 c4 10             	add    $0x10,%esp
}
801096a4:	90                   	nop
801096a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801096a8:	5b                   	pop    %ebx
801096a9:	5e                   	pop    %esi
801096aa:	5f                   	pop    %edi
801096ab:	5d                   	pop    %ebp
801096ac:	c3                   	ret

801096ad <i8254_init_send>:

void i8254_init_send(){
801096ad:	f3 0f 1e fb          	endbr32
801096b1:	55                   	push   %ebp
801096b2:	89 e5                	mov    %esp,%ebp
801096b4:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801096b7:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096bc:	05 28 38 00 00       	add    $0x3828,%eax
801096c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801096c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096c7:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801096cd:	e8 c0 91 ff ff       	call   80102892 <kalloc>
801096d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801096d5:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096da:	05 00 38 00 00       	add    $0x3800,%eax
801096df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801096e2:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096e7:	05 04 38 00 00       	add    $0x3804,%eax
801096ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801096ef:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096f4:	05 08 38 00 00       	add    $0x3808,%eax
801096f9:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801096fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ff:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109708:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010970a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010970d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109713:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109716:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010971c:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109721:	05 10 38 00 00       	add    $0x3810,%eax
80109726:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109729:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010972e:	05 18 38 00 00       	add    $0x3818,%eax
80109733:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109736:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109739:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010973f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109742:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109748:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010974b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010974e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109755:	e9 82 00 00 00       	jmp    801097dc <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
8010975a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975d:	c1 e0 04             	shl    $0x4,%eax
80109760:	89 c2                	mov    %eax,%edx
80109762:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109765:	01 d0                	add    %edx,%eax
80109767:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010976e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109771:	c1 e0 04             	shl    $0x4,%eax
80109774:	89 c2                	mov    %eax,%edx
80109776:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109779:	01 d0                	add    %edx,%eax
8010977b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109784:	c1 e0 04             	shl    $0x4,%eax
80109787:	89 c2                	mov    %eax,%edx
80109789:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010978c:	01 d0                	add    %edx,%eax
8010978e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109795:	c1 e0 04             	shl    $0x4,%eax
80109798:	89 c2                	mov    %eax,%edx
8010979a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010979d:	01 d0                	add    %edx,%eax
8010979f:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801097a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a6:	c1 e0 04             	shl    $0x4,%eax
801097a9:	89 c2                	mov    %eax,%edx
801097ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097ae:	01 d0                	add    %edx,%eax
801097b0:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801097b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b7:	c1 e0 04             	shl    $0x4,%eax
801097ba:	89 c2                	mov    %eax,%edx
801097bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097bf:	01 d0                	add    %edx,%eax
801097c1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801097c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c8:	c1 e0 04             	shl    $0x4,%eax
801097cb:	89 c2                	mov    %eax,%edx
801097cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097d0:	01 d0                	add    %edx,%eax
801097d2:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801097d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097dc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801097e3:	0f 8e 71 ff ff ff    	jle    8010975a <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801097e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801097f0:	eb 57                	jmp    80109849 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
801097f2:	e8 9b 90 ff ff       	call   80102892 <kalloc>
801097f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801097fa:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801097fe:	75 12                	jne    80109812 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109800:	83 ec 0c             	sub    $0xc,%esp
80109803:	68 58 cf 10 80       	push   $0x8010cf58
80109808:	e8 ff 6b ff ff       	call   8010040c <cprintf>
8010980d:	83 c4 10             	add    $0x10,%esp
      break;
80109810:	eb 3d                	jmp    8010984f <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109815:	c1 e0 04             	shl    $0x4,%eax
80109818:	89 c2                	mov    %eax,%edx
8010981a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010981d:	01 d0                	add    %edx,%eax
8010981f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109822:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109828:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010982a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010982d:	83 c0 01             	add    $0x1,%eax
80109830:	c1 e0 04             	shl    $0x4,%eax
80109833:	89 c2                	mov    %eax,%edx
80109835:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109838:	01 d0                	add    %edx,%eax
8010983a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010983d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109843:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109845:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109849:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010984d:	7e a3                	jle    801097f2 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010984f:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109854:	05 00 04 00 00       	add    $0x400,%eax
80109859:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010985c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010985f:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109865:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010986a:	05 10 04 00 00       	add    $0x410,%eax
8010986f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109872:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109875:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010987b:	83 ec 0c             	sub    $0xc,%esp
8010987e:	68 98 cf 10 80       	push   $0x8010cf98
80109883:	e8 84 6b ff ff       	call   8010040c <cprintf>
80109888:	83 c4 10             	add    $0x10,%esp

}
8010988b:	90                   	nop
8010988c:	c9                   	leave
8010988d:	c3                   	ret

8010988e <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010988e:	f3 0f 1e fb          	endbr32
80109892:	55                   	push   %ebp
80109893:	89 e5                	mov    %esp,%ebp
80109895:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109898:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010989d:	83 c0 14             	add    $0x14,%eax
801098a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801098a3:	8b 45 08             	mov    0x8(%ebp),%eax
801098a6:	c1 e0 08             	shl    $0x8,%eax
801098a9:	0f b7 c0             	movzwl %ax,%eax
801098ac:	83 c8 01             	or     $0x1,%eax
801098af:	89 c2                	mov    %eax,%edx
801098b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b4:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801098b6:	83 ec 0c             	sub    $0xc,%esp
801098b9:	68 b8 cf 10 80       	push   $0x8010cfb8
801098be:	e8 49 6b ff ff       	call   8010040c <cprintf>
801098c3:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801098c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c9:	8b 00                	mov    (%eax),%eax
801098cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801098ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d1:	83 e0 10             	and    $0x10,%eax
801098d4:	85 c0                	test   %eax,%eax
801098d6:	75 02                	jne    801098da <i8254_read_eeprom+0x4c>
  while(1){
801098d8:	eb dc                	jmp    801098b6 <i8254_read_eeprom+0x28>
      break;
801098da:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801098db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098de:	8b 00                	mov    (%eax),%eax
801098e0:	c1 e8 10             	shr    $0x10,%eax
}
801098e3:	c9                   	leave
801098e4:	c3                   	ret

801098e5 <i8254_recv>:
void i8254_recv(){
801098e5:	f3 0f 1e fb          	endbr32
801098e9:	55                   	push   %ebp
801098ea:	89 e5                	mov    %esp,%ebp
801098ec:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801098ef:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801098f4:	05 10 28 00 00       	add    $0x2810,%eax
801098f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801098fc:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109901:	05 18 28 00 00       	add    $0x2818,%eax
80109906:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109909:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010990e:	05 00 28 00 00       	add    $0x2800,%eax
80109913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109919:	8b 00                	mov    (%eax),%eax
8010991b:	05 00 00 00 80       	add    $0x80000000,%eax
80109920:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109926:	8b 10                	mov    (%eax),%edx
80109928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010992b:	8b 00                	mov    (%eax),%eax
8010992d:	29 c2                	sub    %eax,%edx
8010992f:	89 d0                	mov    %edx,%eax
80109931:	25 ff 00 00 00       	and    $0xff,%eax
80109936:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109939:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010993d:	7e 37                	jle    80109976 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010993f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109942:	8b 00                	mov    (%eax),%eax
80109944:	c1 e0 04             	shl    $0x4,%eax
80109947:	89 c2                	mov    %eax,%edx
80109949:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010994c:	01 d0                	add    %edx,%eax
8010994e:	8b 00                	mov    (%eax),%eax
80109950:	05 00 00 00 80       	add    $0x80000000,%eax
80109955:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010995b:	8b 00                	mov    (%eax),%eax
8010995d:	83 c0 01             	add    $0x1,%eax
80109960:	0f b6 d0             	movzbl %al,%edx
80109963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109966:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109968:	83 ec 0c             	sub    $0xc,%esp
8010996b:	ff 75 e0             	push   -0x20(%ebp)
8010996e:	e8 47 09 00 00       	call   8010a2ba <eth_proc>
80109973:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109976:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109979:	8b 10                	mov    (%eax),%edx
8010997b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997e:	8b 00                	mov    (%eax),%eax
80109980:	39 c2                	cmp    %eax,%edx
80109982:	75 9f                	jne    80109923 <i8254_recv+0x3e>
      (*rdt)--;
80109984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109987:	8b 00                	mov    (%eax),%eax
80109989:	8d 50 ff             	lea    -0x1(%eax),%edx
8010998c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010998f:	89 10                	mov    %edx,(%eax)
  while(1){
80109991:	eb 90                	jmp    80109923 <i8254_recv+0x3e>

80109993 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109993:	f3 0f 1e fb          	endbr32
80109997:	55                   	push   %ebp
80109998:	89 e5                	mov    %esp,%ebp
8010999a:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010999d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099a2:	05 10 38 00 00       	add    $0x3810,%eax
801099a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801099aa:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099af:	05 18 38 00 00       	add    $0x3818,%eax
801099b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801099b7:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099bc:	05 00 38 00 00       	add    $0x3800,%eax
801099c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801099c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099c7:	8b 00                	mov    (%eax),%eax
801099c9:	05 00 00 00 80       	add    $0x80000000,%eax
801099ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801099d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099d4:	8b 10                	mov    (%eax),%edx
801099d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d9:	8b 00                	mov    (%eax),%eax
801099db:	29 c2                	sub    %eax,%edx
801099dd:	89 d0                	mov    %edx,%eax
801099df:	0f b6 c0             	movzbl %al,%eax
801099e2:	ba 00 01 00 00       	mov    $0x100,%edx
801099e7:	29 c2                	sub    %eax,%edx
801099e9:	89 d0                	mov    %edx,%eax
801099eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801099ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f1:	8b 00                	mov    (%eax),%eax
801099f3:	25 ff 00 00 00       	and    $0xff,%eax
801099f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801099fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801099ff:	0f 8e a8 00 00 00    	jle    80109aad <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109a05:	8b 45 08             	mov    0x8(%ebp),%eax
80109a08:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a0b:	89 d1                	mov    %edx,%ecx
80109a0d:	c1 e1 04             	shl    $0x4,%ecx
80109a10:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109a13:	01 ca                	add    %ecx,%edx
80109a15:	8b 12                	mov    (%edx),%edx
80109a17:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109a1d:	83 ec 04             	sub    $0x4,%esp
80109a20:	ff 75 0c             	push   0xc(%ebp)
80109a23:	50                   	push   %eax
80109a24:	52                   	push   %edx
80109a25:	e8 5b bc ff ff       	call   80105685 <memmove>
80109a2a:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109a2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a30:	c1 e0 04             	shl    $0x4,%eax
80109a33:	89 c2                	mov    %eax,%edx
80109a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a38:	01 d0                	add    %edx,%eax
80109a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a3d:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a44:	c1 e0 04             	shl    $0x4,%eax
80109a47:	89 c2                	mov    %eax,%edx
80109a49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a4c:	01 d0                	add    %edx,%eax
80109a4e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109a52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a55:	c1 e0 04             	shl    $0x4,%eax
80109a58:	89 c2                	mov    %eax,%edx
80109a5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a5d:	01 d0                	add    %edx,%eax
80109a5f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109a63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a66:	c1 e0 04             	shl    $0x4,%eax
80109a69:	89 c2                	mov    %eax,%edx
80109a6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a6e:	01 d0                	add    %edx,%eax
80109a70:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a77:	c1 e0 04             	shl    $0x4,%eax
80109a7a:	89 c2                	mov    %eax,%edx
80109a7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a7f:	01 d0                	add    %edx,%eax
80109a81:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a8a:	c1 e0 04             	shl    $0x4,%eax
80109a8d:	89 c2                	mov    %eax,%edx
80109a8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a92:	01 d0                	add    %edx,%eax
80109a94:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9b:	8b 00                	mov    (%eax),%eax
80109a9d:	83 c0 01             	add    $0x1,%eax
80109aa0:	0f b6 d0             	movzbl %al,%edx
80109aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa6:	89 10                	mov    %edx,(%eax)
    return len;
80109aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109aab:	eb 05                	jmp    80109ab2 <i8254_send+0x11f>
  }else{
    return -1;
80109aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109ab2:	c9                   	leave
80109ab3:	c3                   	ret

80109ab4 <i8254_intr>:

void i8254_intr(){
80109ab4:	f3 0f 1e fb          	endbr32
80109ab8:	55                   	push   %ebp
80109ab9:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109abb:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109ac0:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109ac6:	90                   	nop
80109ac7:	5d                   	pop    %ebp
80109ac8:	c3                   	ret

80109ac9 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109ac9:	f3 0f 1e fb          	endbr32
80109acd:	55                   	push   %ebp
80109ace:	89 e5                	mov    %esp,%ebp
80109ad0:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adc:	0f b7 00             	movzwl (%eax),%eax
80109adf:	66 3d 00 01          	cmp    $0x100,%ax
80109ae3:	74 0a                	je     80109aef <arp_proc+0x26>
80109ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109aea:	e9 4f 01 00 00       	jmp    80109c3e <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af2:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109af6:	66 83 f8 08          	cmp    $0x8,%ax
80109afa:	74 0a                	je     80109b06 <arp_proc+0x3d>
80109afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b01:	e9 38 01 00 00       	jmp    80109c3e <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b09:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109b0d:	3c 06                	cmp    $0x6,%al
80109b0f:	74 0a                	je     80109b1b <arp_proc+0x52>
80109b11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b16:	e9 23 01 00 00       	jmp    80109c3e <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b1e:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109b22:	3c 04                	cmp    $0x4,%al
80109b24:	74 0a                	je     80109b30 <arp_proc+0x67>
80109b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b2b:	e9 0e 01 00 00       	jmp    80109c3e <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b33:	83 c0 18             	add    $0x18,%eax
80109b36:	83 ec 04             	sub    $0x4,%esp
80109b39:	6a 04                	push   $0x4
80109b3b:	50                   	push   %eax
80109b3c:	68 04 05 11 80       	push   $0x80110504
80109b41:	e8 e3 ba ff ff       	call   80105629 <memcmp>
80109b46:	83 c4 10             	add    $0x10,%esp
80109b49:	85 c0                	test   %eax,%eax
80109b4b:	74 27                	je     80109b74 <arp_proc+0xab>
80109b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b50:	83 c0 0e             	add    $0xe,%eax
80109b53:	83 ec 04             	sub    $0x4,%esp
80109b56:	6a 04                	push   $0x4
80109b58:	50                   	push   %eax
80109b59:	68 04 05 11 80       	push   $0x80110504
80109b5e:	e8 c6 ba ff ff       	call   80105629 <memcmp>
80109b63:	83 c4 10             	add    $0x10,%esp
80109b66:	85 c0                	test   %eax,%eax
80109b68:	74 0a                	je     80109b74 <arp_proc+0xab>
80109b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b6f:	e9 ca 00 00 00       	jmp    80109c3e <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b77:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b7b:	66 3d 00 01          	cmp    $0x100,%ax
80109b7f:	75 69                	jne    80109bea <arp_proc+0x121>
80109b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b84:	83 c0 18             	add    $0x18,%eax
80109b87:	83 ec 04             	sub    $0x4,%esp
80109b8a:	6a 04                	push   $0x4
80109b8c:	50                   	push   %eax
80109b8d:	68 04 05 11 80       	push   $0x80110504
80109b92:	e8 92 ba ff ff       	call   80105629 <memcmp>
80109b97:	83 c4 10             	add    $0x10,%esp
80109b9a:	85 c0                	test   %eax,%eax
80109b9c:	75 4c                	jne    80109bea <arp_proc+0x121>
    uint send = (uint)kalloc();
80109b9e:	e8 ef 8c ff ff       	call   80102892 <kalloc>
80109ba3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109ba6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109bad:	83 ec 04             	sub    $0x4,%esp
80109bb0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109bb3:	50                   	push   %eax
80109bb4:	ff 75 f0             	push   -0x10(%ebp)
80109bb7:	ff 75 f4             	push   -0xc(%ebp)
80109bba:	e8 33 04 00 00       	call   80109ff2 <arp_reply_pkt_create>
80109bbf:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bc5:	83 ec 08             	sub    $0x8,%esp
80109bc8:	50                   	push   %eax
80109bc9:	ff 75 f0             	push   -0x10(%ebp)
80109bcc:	e8 c2 fd ff ff       	call   80109993 <i8254_send>
80109bd1:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd7:	83 ec 0c             	sub    $0xc,%esp
80109bda:	50                   	push   %eax
80109bdb:	e8 14 8c ff ff       	call   801027f4 <kfree>
80109be0:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109be3:	b8 02 00 00 00       	mov    $0x2,%eax
80109be8:	eb 54                	jmp    80109c3e <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bed:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bf1:	66 3d 00 02          	cmp    $0x200,%ax
80109bf5:	75 42                	jne    80109c39 <arp_proc+0x170>
80109bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bfa:	83 c0 18             	add    $0x18,%eax
80109bfd:	83 ec 04             	sub    $0x4,%esp
80109c00:	6a 04                	push   $0x4
80109c02:	50                   	push   %eax
80109c03:	68 04 05 11 80       	push   $0x80110504
80109c08:	e8 1c ba ff ff       	call   80105629 <memcmp>
80109c0d:	83 c4 10             	add    $0x10,%esp
80109c10:	85 c0                	test   %eax,%eax
80109c12:	75 25                	jne    80109c39 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109c14:	83 ec 0c             	sub    $0xc,%esp
80109c17:	68 bc cf 10 80       	push   $0x8010cfbc
80109c1c:	e8 eb 67 ff ff       	call   8010040c <cprintf>
80109c21:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109c24:	83 ec 0c             	sub    $0xc,%esp
80109c27:	ff 75 f4             	push   -0xc(%ebp)
80109c2a:	e8 b7 01 00 00       	call   80109de6 <arp_table_update>
80109c2f:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109c32:	b8 01 00 00 00       	mov    $0x1,%eax
80109c37:	eb 05                	jmp    80109c3e <arp_proc+0x175>
  }else{
    return -1;
80109c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109c3e:	c9                   	leave
80109c3f:	c3                   	ret

80109c40 <arp_scan>:

void arp_scan(){
80109c40:	f3 0f 1e fb          	endbr32
80109c44:	55                   	push   %ebp
80109c45:	89 e5                	mov    %esp,%ebp
80109c47:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c51:	eb 6f                	jmp    80109cc2 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109c53:	e8 3a 8c ff ff       	call   80102892 <kalloc>
80109c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109c5b:	83 ec 04             	sub    $0x4,%esp
80109c5e:	ff 75 f4             	push   -0xc(%ebp)
80109c61:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c64:	50                   	push   %eax
80109c65:	ff 75 ec             	push   -0x14(%ebp)
80109c68:	e8 62 00 00 00       	call   80109ccf <arp_broadcast>
80109c6d:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109c70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c73:	83 ec 08             	sub    $0x8,%esp
80109c76:	50                   	push   %eax
80109c77:	ff 75 ec             	push   -0x14(%ebp)
80109c7a:	e8 14 fd ff ff       	call   80109993 <i8254_send>
80109c7f:	83 c4 10             	add    $0x10,%esp
80109c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109c85:	eb 22                	jmp    80109ca9 <arp_scan+0x69>
      microdelay(1);
80109c87:	83 ec 0c             	sub    $0xc,%esp
80109c8a:	6a 01                	push   $0x1
80109c8c:	e8 b3 8f ff ff       	call   80102c44 <microdelay>
80109c91:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109c94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c97:	83 ec 08             	sub    $0x8,%esp
80109c9a:	50                   	push   %eax
80109c9b:	ff 75 ec             	push   -0x14(%ebp)
80109c9e:	e8 f0 fc ff ff       	call   80109993 <i8254_send>
80109ca3:	83 c4 10             	add    $0x10,%esp
80109ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109ca9:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109cad:	74 d8                	je     80109c87 <arp_scan+0x47>
    }
    kfree((char *)send);
80109caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cb2:	83 ec 0c             	sub    $0xc,%esp
80109cb5:	50                   	push   %eax
80109cb6:	e8 39 8b ff ff       	call   801027f4 <kfree>
80109cbb:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109cbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109cc2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109cc9:	7e 88                	jle    80109c53 <arp_scan+0x13>
  }
}
80109ccb:	90                   	nop
80109ccc:	90                   	nop
80109ccd:	c9                   	leave
80109cce:	c3                   	ret

80109ccf <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109ccf:	f3 0f 1e fb          	endbr32
80109cd3:	55                   	push   %ebp
80109cd4:	89 e5                	mov    %esp,%ebp
80109cd6:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109cd9:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109cdd:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109ce1:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109ce5:	8b 45 10             	mov    0x10(%ebp),%eax
80109ce8:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109ceb:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109cf2:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109cf8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109cff:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109d05:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d08:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109d14:	8b 45 08             	mov    0x8(%ebp),%eax
80109d17:	83 c0 0e             	add    $0xe,%eax
80109d1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d20:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d27:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d2e:	83 ec 04             	sub    $0x4,%esp
80109d31:	6a 06                	push   $0x6
80109d33:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109d36:	52                   	push   %edx
80109d37:	50                   	push   %eax
80109d38:	e8 48 b9 ff ff       	call   80105685 <memmove>
80109d3d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d43:	83 c0 06             	add    $0x6,%eax
80109d46:	83 ec 04             	sub    $0x4,%esp
80109d49:	6a 06                	push   $0x6
80109d4b:	68 88 e0 18 80       	push   $0x8018e088
80109d50:	50                   	push   %eax
80109d51:	e8 2f b9 ff ff       	call   80105685 <memmove>
80109d56:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d5c:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d64:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6d:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d74:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d7b:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d84:	8d 50 12             	lea    0x12(%eax),%edx
80109d87:	83 ec 04             	sub    $0x4,%esp
80109d8a:	6a 06                	push   $0x6
80109d8c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109d8f:	50                   	push   %eax
80109d90:	52                   	push   %edx
80109d91:	e8 ef b8 ff ff       	call   80105685 <memmove>
80109d96:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d9c:	8d 50 18             	lea    0x18(%eax),%edx
80109d9f:	83 ec 04             	sub    $0x4,%esp
80109da2:	6a 04                	push   $0x4
80109da4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109da7:	50                   	push   %eax
80109da8:	52                   	push   %edx
80109da9:	e8 d7 b8 ff ff       	call   80105685 <memmove>
80109dae:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db4:	83 c0 08             	add    $0x8,%eax
80109db7:	83 ec 04             	sub    $0x4,%esp
80109dba:	6a 06                	push   $0x6
80109dbc:	68 88 e0 18 80       	push   $0x8018e088
80109dc1:	50                   	push   %eax
80109dc2:	e8 be b8 ff ff       	call   80105685 <memmove>
80109dc7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dcd:	83 c0 0e             	add    $0xe,%eax
80109dd0:	83 ec 04             	sub    $0x4,%esp
80109dd3:	6a 04                	push   $0x4
80109dd5:	68 04 05 11 80       	push   $0x80110504
80109dda:	50                   	push   %eax
80109ddb:	e8 a5 b8 ff ff       	call   80105685 <memmove>
80109de0:	83 c4 10             	add    $0x10,%esp
}
80109de3:	90                   	nop
80109de4:	c9                   	leave
80109de5:	c3                   	ret

80109de6 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109de6:	f3 0f 1e fb          	endbr32
80109dea:	55                   	push   %ebp
80109deb:	89 e5                	mov    %esp,%ebp
80109ded:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109df0:	8b 45 08             	mov    0x8(%ebp),%eax
80109df3:	83 c0 0e             	add    $0xe,%eax
80109df6:	83 ec 0c             	sub    $0xc,%esp
80109df9:	50                   	push   %eax
80109dfa:	e8 bc 00 00 00       	call   80109ebb <arp_table_search>
80109dff:	83 c4 10             	add    $0x10,%esp
80109e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109e09:	78 2d                	js     80109e38 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109e0e:	8d 48 08             	lea    0x8(%eax),%ecx
80109e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e14:	89 d0                	mov    %edx,%eax
80109e16:	c1 e0 02             	shl    $0x2,%eax
80109e19:	01 d0                	add    %edx,%eax
80109e1b:	01 c0                	add    %eax,%eax
80109e1d:	01 d0                	add    %edx,%eax
80109e1f:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e24:	83 c0 04             	add    $0x4,%eax
80109e27:	83 ec 04             	sub    $0x4,%esp
80109e2a:	6a 06                	push   $0x6
80109e2c:	51                   	push   %ecx
80109e2d:	50                   	push   %eax
80109e2e:	e8 52 b8 ff ff       	call   80105685 <memmove>
80109e33:	83 c4 10             	add    $0x10,%esp
80109e36:	eb 70                	jmp    80109ea8 <arp_table_update+0xc2>
  }else{
    index += 1;
80109e38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109e3c:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109e42:	8d 48 08             	lea    0x8(%eax),%ecx
80109e45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e48:	89 d0                	mov    %edx,%eax
80109e4a:	c1 e0 02             	shl    $0x2,%eax
80109e4d:	01 d0                	add    %edx,%eax
80109e4f:	01 c0                	add    %eax,%eax
80109e51:	01 d0                	add    %edx,%eax
80109e53:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e58:	83 c0 04             	add    $0x4,%eax
80109e5b:	83 ec 04             	sub    $0x4,%esp
80109e5e:	6a 06                	push   $0x6
80109e60:	51                   	push   %ecx
80109e61:	50                   	push   %eax
80109e62:	e8 1e b8 ff ff       	call   80105685 <memmove>
80109e67:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6d:	8d 48 0e             	lea    0xe(%eax),%ecx
80109e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e73:	89 d0                	mov    %edx,%eax
80109e75:	c1 e0 02             	shl    $0x2,%eax
80109e78:	01 d0                	add    %edx,%eax
80109e7a:	01 c0                	add    %eax,%eax
80109e7c:	01 d0                	add    %edx,%eax
80109e7e:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e83:	83 ec 04             	sub    $0x4,%esp
80109e86:	6a 04                	push   $0x4
80109e88:	51                   	push   %ecx
80109e89:	50                   	push   %eax
80109e8a:	e8 f6 b7 ff ff       	call   80105685 <memmove>
80109e8f:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e95:	89 d0                	mov    %edx,%eax
80109e97:	c1 e0 02             	shl    $0x2,%eax
80109e9a:	01 d0                	add    %edx,%eax
80109e9c:	01 c0                	add    %eax,%eax
80109e9e:	01 d0                	add    %edx,%eax
80109ea0:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109ea5:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109ea8:	83 ec 0c             	sub    $0xc,%esp
80109eab:	68 a0 e0 18 80       	push   $0x8018e0a0
80109eb0:	e8 87 00 00 00       	call   80109f3c <print_arp_table>
80109eb5:	83 c4 10             	add    $0x10,%esp
}
80109eb8:	90                   	nop
80109eb9:	c9                   	leave
80109eba:	c3                   	ret

80109ebb <arp_table_search>:

int arp_table_search(uchar *ip){
80109ebb:	f3 0f 1e fb          	endbr32
80109ebf:	55                   	push   %ebp
80109ec0:	89 e5                	mov    %esp,%ebp
80109ec2:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109ec5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ecc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109ed3:	eb 59                	jmp    80109f2e <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109ed5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ed8:	89 d0                	mov    %edx,%eax
80109eda:	c1 e0 02             	shl    $0x2,%eax
80109edd:	01 d0                	add    %edx,%eax
80109edf:	01 c0                	add    %eax,%eax
80109ee1:	01 d0                	add    %edx,%eax
80109ee3:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109ee8:	83 ec 04             	sub    $0x4,%esp
80109eeb:	6a 04                	push   $0x4
80109eed:	ff 75 08             	push   0x8(%ebp)
80109ef0:	50                   	push   %eax
80109ef1:	e8 33 b7 ff ff       	call   80105629 <memcmp>
80109ef6:	83 c4 10             	add    $0x10,%esp
80109ef9:	85 c0                	test   %eax,%eax
80109efb:	75 05                	jne    80109f02 <arp_table_search+0x47>
      return i;
80109efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f00:	eb 38                	jmp    80109f3a <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109f02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f05:	89 d0                	mov    %edx,%eax
80109f07:	c1 e0 02             	shl    $0x2,%eax
80109f0a:	01 d0                	add    %edx,%eax
80109f0c:	01 c0                	add    %eax,%eax
80109f0e:	01 d0                	add    %edx,%eax
80109f10:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109f15:	0f b6 00             	movzbl (%eax),%eax
80109f18:	84 c0                	test   %al,%al
80109f1a:	75 0e                	jne    80109f2a <arp_table_search+0x6f>
80109f1c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109f20:	75 08                	jne    80109f2a <arp_table_search+0x6f>
      empty = -i;
80109f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f25:	f7 d8                	neg    %eax
80109f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109f2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109f2e:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109f32:	7e a1                	jle    80109ed5 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f37:	83 e8 01             	sub    $0x1,%eax
}
80109f3a:	c9                   	leave
80109f3b:	c3                   	ret

80109f3c <print_arp_table>:

void print_arp_table(){
80109f3c:	f3 0f 1e fb          	endbr32
80109f40:	55                   	push   %ebp
80109f41:	89 e5                	mov    %esp,%ebp
80109f43:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109f46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109f4d:	e9 92 00 00 00       	jmp    80109fe4 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f55:	89 d0                	mov    %edx,%eax
80109f57:	c1 e0 02             	shl    $0x2,%eax
80109f5a:	01 d0                	add    %edx,%eax
80109f5c:	01 c0                	add    %eax,%eax
80109f5e:	01 d0                	add    %edx,%eax
80109f60:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109f65:	0f b6 00             	movzbl (%eax),%eax
80109f68:	84 c0                	test   %al,%al
80109f6a:	74 74                	je     80109fe0 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109f6c:	83 ec 08             	sub    $0x8,%esp
80109f6f:	ff 75 f4             	push   -0xc(%ebp)
80109f72:	68 cf cf 10 80       	push   $0x8010cfcf
80109f77:	e8 90 64 ff ff       	call   8010040c <cprintf>
80109f7c:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109f7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f82:	89 d0                	mov    %edx,%eax
80109f84:	c1 e0 02             	shl    $0x2,%eax
80109f87:	01 d0                	add    %edx,%eax
80109f89:	01 c0                	add    %eax,%eax
80109f8b:	01 d0                	add    %edx,%eax
80109f8d:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109f92:	83 ec 0c             	sub    $0xc,%esp
80109f95:	50                   	push   %eax
80109f96:	e8 5c 02 00 00       	call   8010a1f7 <print_ipv4>
80109f9b:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109f9e:	83 ec 0c             	sub    $0xc,%esp
80109fa1:	68 de cf 10 80       	push   $0x8010cfde
80109fa6:	e8 61 64 ff ff       	call   8010040c <cprintf>
80109fab:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109fae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fb1:	89 d0                	mov    %edx,%eax
80109fb3:	c1 e0 02             	shl    $0x2,%eax
80109fb6:	01 d0                	add    %edx,%eax
80109fb8:	01 c0                	add    %eax,%eax
80109fba:	01 d0                	add    %edx,%eax
80109fbc:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109fc1:	83 c0 04             	add    $0x4,%eax
80109fc4:	83 ec 0c             	sub    $0xc,%esp
80109fc7:	50                   	push   %eax
80109fc8:	e8 7c 02 00 00       	call   8010a249 <print_mac>
80109fcd:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109fd0:	83 ec 0c             	sub    $0xc,%esp
80109fd3:	68 e0 cf 10 80       	push   $0x8010cfe0
80109fd8:	e8 2f 64 ff ff       	call   8010040c <cprintf>
80109fdd:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109fe0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109fe4:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109fe8:	0f 8e 64 ff ff ff    	jle    80109f52 <print_arp_table+0x16>
    }
  }
}
80109fee:	90                   	nop
80109fef:	90                   	nop
80109ff0:	c9                   	leave
80109ff1:	c3                   	ret

80109ff2 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109ff2:	f3 0f 1e fb          	endbr32
80109ff6:	55                   	push   %ebp
80109ff7:	89 e5                	mov    %esp,%ebp
80109ff9:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109ffc:	8b 45 10             	mov    0x10(%ebp),%eax
80109fff:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010a005:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a008:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010a00b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a00e:	83 c0 0e             	add    $0xe,%eax
8010a011:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010a014:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a017:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010a01b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a01e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010a022:	8b 45 08             	mov    0x8(%ebp),%eax
8010a025:	8d 50 08             	lea    0x8(%eax),%edx
8010a028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a02b:	83 ec 04             	sub    $0x4,%esp
8010a02e:	6a 06                	push   $0x6
8010a030:	52                   	push   %edx
8010a031:	50                   	push   %eax
8010a032:	e8 4e b6 ff ff       	call   80105685 <memmove>
8010a037:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010a03a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a03d:	83 c0 06             	add    $0x6,%eax
8010a040:	83 ec 04             	sub    $0x4,%esp
8010a043:	6a 06                	push   $0x6
8010a045:	68 88 e0 18 80       	push   $0x8018e088
8010a04a:	50                   	push   %eax
8010a04b:	e8 35 b6 ff ff       	call   80105685 <memmove>
8010a050:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010a053:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a056:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010a05b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a05e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010a064:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a067:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010a06b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a06e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010a072:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a075:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010a07b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07e:	8d 50 08             	lea    0x8(%eax),%edx
8010a081:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a084:	83 c0 12             	add    $0x12,%eax
8010a087:	83 ec 04             	sub    $0x4,%esp
8010a08a:	6a 06                	push   $0x6
8010a08c:	52                   	push   %edx
8010a08d:	50                   	push   %eax
8010a08e:	e8 f2 b5 ff ff       	call   80105685 <memmove>
8010a093:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010a096:	8b 45 08             	mov    0x8(%ebp),%eax
8010a099:	8d 50 0e             	lea    0xe(%eax),%edx
8010a09c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09f:	83 c0 18             	add    $0x18,%eax
8010a0a2:	83 ec 04             	sub    $0x4,%esp
8010a0a5:	6a 04                	push   $0x4
8010a0a7:	52                   	push   %edx
8010a0a8:	50                   	push   %eax
8010a0a9:	e8 d7 b5 ff ff       	call   80105685 <memmove>
8010a0ae:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010a0b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b4:	83 c0 08             	add    $0x8,%eax
8010a0b7:	83 ec 04             	sub    $0x4,%esp
8010a0ba:	6a 06                	push   $0x6
8010a0bc:	68 88 e0 18 80       	push   $0x8018e088
8010a0c1:	50                   	push   %eax
8010a0c2:	e8 be b5 ff ff       	call   80105685 <memmove>
8010a0c7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010a0ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0cd:	83 c0 0e             	add    $0xe,%eax
8010a0d0:	83 ec 04             	sub    $0x4,%esp
8010a0d3:	6a 04                	push   $0x4
8010a0d5:	68 04 05 11 80       	push   $0x80110504
8010a0da:	50                   	push   %eax
8010a0db:	e8 a5 b5 ff ff       	call   80105685 <memmove>
8010a0e0:	83 c4 10             	add    $0x10,%esp
}
8010a0e3:	90                   	nop
8010a0e4:	c9                   	leave
8010a0e5:	c3                   	ret

8010a0e6 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010a0e6:	f3 0f 1e fb          	endbr32
8010a0ea:	55                   	push   %ebp
8010a0eb:	89 e5                	mov    %esp,%ebp
8010a0ed:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010a0f0:	83 ec 0c             	sub    $0xc,%esp
8010a0f3:	68 e2 cf 10 80       	push   $0x8010cfe2
8010a0f8:	e8 0f 63 ff ff       	call   8010040c <cprintf>
8010a0fd:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010a100:	8b 45 08             	mov    0x8(%ebp),%eax
8010a103:	83 c0 0e             	add    $0xe,%eax
8010a106:	83 ec 0c             	sub    $0xc,%esp
8010a109:	50                   	push   %eax
8010a10a:	e8 e8 00 00 00       	call   8010a1f7 <print_ipv4>
8010a10f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a112:	83 ec 0c             	sub    $0xc,%esp
8010a115:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a11a:	e8 ed 62 ff ff       	call   8010040c <cprintf>
8010a11f:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010a122:	8b 45 08             	mov    0x8(%ebp),%eax
8010a125:	83 c0 08             	add    $0x8,%eax
8010a128:	83 ec 0c             	sub    $0xc,%esp
8010a12b:	50                   	push   %eax
8010a12c:	e8 18 01 00 00       	call   8010a249 <print_mac>
8010a131:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a134:	83 ec 0c             	sub    $0xc,%esp
8010a137:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a13c:	e8 cb 62 ff ff       	call   8010040c <cprintf>
8010a141:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a144:	83 ec 0c             	sub    $0xc,%esp
8010a147:	68 f9 cf 10 80       	push   $0x8010cff9
8010a14c:	e8 bb 62 ff ff       	call   8010040c <cprintf>
8010a151:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010a154:	8b 45 08             	mov    0x8(%ebp),%eax
8010a157:	83 c0 18             	add    $0x18,%eax
8010a15a:	83 ec 0c             	sub    $0xc,%esp
8010a15d:	50                   	push   %eax
8010a15e:	e8 94 00 00 00       	call   8010a1f7 <print_ipv4>
8010a163:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a166:	83 ec 0c             	sub    $0xc,%esp
8010a169:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a16e:	e8 99 62 ff ff       	call   8010040c <cprintf>
8010a173:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010a176:	8b 45 08             	mov    0x8(%ebp),%eax
8010a179:	83 c0 12             	add    $0x12,%eax
8010a17c:	83 ec 0c             	sub    $0xc,%esp
8010a17f:	50                   	push   %eax
8010a180:	e8 c4 00 00 00       	call   8010a249 <print_mac>
8010a185:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a188:	83 ec 0c             	sub    $0xc,%esp
8010a18b:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a190:	e8 77 62 ff ff       	call   8010040c <cprintf>
8010a195:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a198:	83 ec 0c             	sub    $0xc,%esp
8010a19b:	68 10 d0 10 80       	push   $0x8010d010
8010a1a0:	e8 67 62 ff ff       	call   8010040c <cprintf>
8010a1a5:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a1a8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ab:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1af:	66 3d 00 01          	cmp    $0x100,%ax
8010a1b3:	75 12                	jne    8010a1c7 <print_arp_info+0xe1>
8010a1b5:	83 ec 0c             	sub    $0xc,%esp
8010a1b8:	68 1c d0 10 80       	push   $0x8010d01c
8010a1bd:	e8 4a 62 ff ff       	call   8010040c <cprintf>
8010a1c2:	83 c4 10             	add    $0x10,%esp
8010a1c5:	eb 1d                	jmp    8010a1e4 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a1c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ca:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1ce:	66 3d 00 02          	cmp    $0x200,%ax
8010a1d2:	75 10                	jne    8010a1e4 <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a1d4:	83 ec 0c             	sub    $0xc,%esp
8010a1d7:	68 25 d0 10 80       	push   $0x8010d025
8010a1dc:	e8 2b 62 ff ff       	call   8010040c <cprintf>
8010a1e1:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a1e4:	83 ec 0c             	sub    $0xc,%esp
8010a1e7:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a1ec:	e8 1b 62 ff ff       	call   8010040c <cprintf>
8010a1f1:	83 c4 10             	add    $0x10,%esp
}
8010a1f4:	90                   	nop
8010a1f5:	c9                   	leave
8010a1f6:	c3                   	ret

8010a1f7 <print_ipv4>:

void print_ipv4(uchar *ip){
8010a1f7:	f3 0f 1e fb          	endbr32
8010a1fb:	55                   	push   %ebp
8010a1fc:	89 e5                	mov    %esp,%ebp
8010a1fe:	53                   	push   %ebx
8010a1ff:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a202:	8b 45 08             	mov    0x8(%ebp),%eax
8010a205:	83 c0 03             	add    $0x3,%eax
8010a208:	0f b6 00             	movzbl (%eax),%eax
8010a20b:	0f b6 d8             	movzbl %al,%ebx
8010a20e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a211:	83 c0 02             	add    $0x2,%eax
8010a214:	0f b6 00             	movzbl (%eax),%eax
8010a217:	0f b6 c8             	movzbl %al,%ecx
8010a21a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a21d:	83 c0 01             	add    $0x1,%eax
8010a220:	0f b6 00             	movzbl (%eax),%eax
8010a223:	0f b6 d0             	movzbl %al,%edx
8010a226:	8b 45 08             	mov    0x8(%ebp),%eax
8010a229:	0f b6 00             	movzbl (%eax),%eax
8010a22c:	0f b6 c0             	movzbl %al,%eax
8010a22f:	83 ec 0c             	sub    $0xc,%esp
8010a232:	53                   	push   %ebx
8010a233:	51                   	push   %ecx
8010a234:	52                   	push   %edx
8010a235:	50                   	push   %eax
8010a236:	68 2c d0 10 80       	push   $0x8010d02c
8010a23b:	e8 cc 61 ff ff       	call   8010040c <cprintf>
8010a240:	83 c4 20             	add    $0x20,%esp
}
8010a243:	90                   	nop
8010a244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a247:	c9                   	leave
8010a248:	c3                   	ret

8010a249 <print_mac>:

void print_mac(uchar *mac){
8010a249:	f3 0f 1e fb          	endbr32
8010a24d:	55                   	push   %ebp
8010a24e:	89 e5                	mov    %esp,%ebp
8010a250:	57                   	push   %edi
8010a251:	56                   	push   %esi
8010a252:	53                   	push   %ebx
8010a253:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a256:	8b 45 08             	mov    0x8(%ebp),%eax
8010a259:	83 c0 05             	add    $0x5,%eax
8010a25c:	0f b6 00             	movzbl (%eax),%eax
8010a25f:	0f b6 f8             	movzbl %al,%edi
8010a262:	8b 45 08             	mov    0x8(%ebp),%eax
8010a265:	83 c0 04             	add    $0x4,%eax
8010a268:	0f b6 00             	movzbl (%eax),%eax
8010a26b:	0f b6 f0             	movzbl %al,%esi
8010a26e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a271:	83 c0 03             	add    $0x3,%eax
8010a274:	0f b6 00             	movzbl (%eax),%eax
8010a277:	0f b6 d8             	movzbl %al,%ebx
8010a27a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a27d:	83 c0 02             	add    $0x2,%eax
8010a280:	0f b6 00             	movzbl (%eax),%eax
8010a283:	0f b6 c8             	movzbl %al,%ecx
8010a286:	8b 45 08             	mov    0x8(%ebp),%eax
8010a289:	83 c0 01             	add    $0x1,%eax
8010a28c:	0f b6 00             	movzbl (%eax),%eax
8010a28f:	0f b6 d0             	movzbl %al,%edx
8010a292:	8b 45 08             	mov    0x8(%ebp),%eax
8010a295:	0f b6 00             	movzbl (%eax),%eax
8010a298:	0f b6 c0             	movzbl %al,%eax
8010a29b:	83 ec 04             	sub    $0x4,%esp
8010a29e:	57                   	push   %edi
8010a29f:	56                   	push   %esi
8010a2a0:	53                   	push   %ebx
8010a2a1:	51                   	push   %ecx
8010a2a2:	52                   	push   %edx
8010a2a3:	50                   	push   %eax
8010a2a4:	68 44 d0 10 80       	push   $0x8010d044
8010a2a9:	e8 5e 61 ff ff       	call   8010040c <cprintf>
8010a2ae:	83 c4 20             	add    $0x20,%esp
}
8010a2b1:	90                   	nop
8010a2b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a2b5:	5b                   	pop    %ebx
8010a2b6:	5e                   	pop    %esi
8010a2b7:	5f                   	pop    %edi
8010a2b8:	5d                   	pop    %ebp
8010a2b9:	c3                   	ret

8010a2ba <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a2ba:	f3 0f 1e fb          	endbr32
8010a2be:	55                   	push   %ebp
8010a2bf:	89 e5                	mov    %esp,%ebp
8010a2c1:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a2c4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a2ca:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2cd:	83 c0 0e             	add    $0xe,%eax
8010a2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2d6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a2da:	3c 08                	cmp    $0x8,%al
8010a2dc:	75 1b                	jne    8010a2f9 <eth_proc+0x3f>
8010a2de:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2e1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a2e5:	3c 06                	cmp    $0x6,%al
8010a2e7:	75 10                	jne    8010a2f9 <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a2e9:	83 ec 0c             	sub    $0xc,%esp
8010a2ec:	ff 75 f0             	push   -0x10(%ebp)
8010a2ef:	e8 d5 f7 ff ff       	call   80109ac9 <arp_proc>
8010a2f4:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a2f7:	eb 24                	jmp    8010a31d <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a2f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2fc:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a300:	3c 08                	cmp    $0x8,%al
8010a302:	75 19                	jne    8010a31d <eth_proc+0x63>
8010a304:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a307:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a30b:	84 c0                	test   %al,%al
8010a30d:	75 0e                	jne    8010a31d <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a30f:	83 ec 0c             	sub    $0xc,%esp
8010a312:	ff 75 08             	push   0x8(%ebp)
8010a315:	e8 b3 00 00 00       	call   8010a3cd <ipv4_proc>
8010a31a:	83 c4 10             	add    $0x10,%esp
}
8010a31d:	90                   	nop
8010a31e:	c9                   	leave
8010a31f:	c3                   	ret

8010a320 <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a320:	f3 0f 1e fb          	endbr32
8010a324:	55                   	push   %ebp
8010a325:	89 e5                	mov    %esp,%ebp
8010a327:	83 ec 04             	sub    $0x4,%esp
8010a32a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a32d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a331:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a335:	c1 e0 08             	shl    $0x8,%eax
8010a338:	89 c2                	mov    %eax,%edx
8010a33a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a33e:	66 c1 e8 08          	shr    $0x8,%ax
8010a342:	01 d0                	add    %edx,%eax
}
8010a344:	c9                   	leave
8010a345:	c3                   	ret

8010a346 <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a346:	f3 0f 1e fb          	endbr32
8010a34a:	55                   	push   %ebp
8010a34b:	89 e5                	mov    %esp,%ebp
8010a34d:	83 ec 04             	sub    $0x4,%esp
8010a350:	8b 45 08             	mov    0x8(%ebp),%eax
8010a353:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a357:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a35b:	c1 e0 08             	shl    $0x8,%eax
8010a35e:	89 c2                	mov    %eax,%edx
8010a360:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a364:	66 c1 e8 08          	shr    $0x8,%ax
8010a368:	01 d0                	add    %edx,%eax
}
8010a36a:	c9                   	leave
8010a36b:	c3                   	ret

8010a36c <H2N_uint>:

uint H2N_uint(uint value){
8010a36c:	f3 0f 1e fb          	endbr32
8010a370:	55                   	push   %ebp
8010a371:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a373:	8b 45 08             	mov    0x8(%ebp),%eax
8010a376:	c1 e0 18             	shl    $0x18,%eax
8010a379:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a37e:	89 c2                	mov    %eax,%edx
8010a380:	8b 45 08             	mov    0x8(%ebp),%eax
8010a383:	c1 e0 08             	shl    $0x8,%eax
8010a386:	25 00 f0 00 00       	and    $0xf000,%eax
8010a38b:	09 c2                	or     %eax,%edx
8010a38d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a390:	c1 e8 08             	shr    $0x8,%eax
8010a393:	83 e0 0f             	and    $0xf,%eax
8010a396:	01 d0                	add    %edx,%eax
}
8010a398:	5d                   	pop    %ebp
8010a399:	c3                   	ret

8010a39a <N2H_uint>:

uint N2H_uint(uint value){
8010a39a:	f3 0f 1e fb          	endbr32
8010a39e:	55                   	push   %ebp
8010a39f:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a3a1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3a4:	c1 e0 18             	shl    $0x18,%eax
8010a3a7:	89 c2                	mov    %eax,%edx
8010a3a9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ac:	c1 e0 08             	shl    $0x8,%eax
8010a3af:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a3b4:	01 c2                	add    %eax,%edx
8010a3b6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b9:	c1 e8 08             	shr    $0x8,%eax
8010a3bc:	25 00 ff 00 00       	and    $0xff00,%eax
8010a3c1:	01 c2                	add    %eax,%edx
8010a3c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c6:	c1 e8 18             	shr    $0x18,%eax
8010a3c9:	01 d0                	add    %edx,%eax
}
8010a3cb:	5d                   	pop    %ebp
8010a3cc:	c3                   	ret

8010a3cd <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a3cd:	f3 0f 1e fb          	endbr32
8010a3d1:	55                   	push   %ebp
8010a3d2:	89 e5                	mov    %esp,%ebp
8010a3d4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a3d7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3da:	83 c0 0e             	add    $0xe,%eax
8010a3dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a3e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3e3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a3e7:	0f b7 d0             	movzwl %ax,%edx
8010a3ea:	a1 08 05 11 80       	mov    0x80110508,%eax
8010a3ef:	39 c2                	cmp    %eax,%edx
8010a3f1:	74 60                	je     8010a453 <ipv4_proc+0x86>
8010a3f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3f6:	83 c0 0c             	add    $0xc,%eax
8010a3f9:	83 ec 04             	sub    $0x4,%esp
8010a3fc:	6a 04                	push   $0x4
8010a3fe:	50                   	push   %eax
8010a3ff:	68 04 05 11 80       	push   $0x80110504
8010a404:	e8 20 b2 ff ff       	call   80105629 <memcmp>
8010a409:	83 c4 10             	add    $0x10,%esp
8010a40c:	85 c0                	test   %eax,%eax
8010a40e:	74 43                	je     8010a453 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a410:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a413:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a417:	0f b7 c0             	movzwl %ax,%eax
8010a41a:	a3 08 05 11 80       	mov    %eax,0x80110508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a422:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a426:	3c 01                	cmp    $0x1,%al
8010a428:	75 10                	jne    8010a43a <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a42a:	83 ec 0c             	sub    $0xc,%esp
8010a42d:	ff 75 08             	push   0x8(%ebp)
8010a430:	e8 a7 00 00 00       	call   8010a4dc <icmp_proc>
8010a435:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a438:	eb 19                	jmp    8010a453 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a43a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a43d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a441:	3c 06                	cmp    $0x6,%al
8010a443:	75 0e                	jne    8010a453 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a445:	83 ec 0c             	sub    $0xc,%esp
8010a448:	ff 75 08             	push   0x8(%ebp)
8010a44b:	e8 c7 03 00 00       	call   8010a817 <tcp_proc>
8010a450:	83 c4 10             	add    $0x10,%esp
}
8010a453:	90                   	nop
8010a454:	c9                   	leave
8010a455:	c3                   	ret

8010a456 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a456:	f3 0f 1e fb          	endbr32
8010a45a:	55                   	push   %ebp
8010a45b:	89 e5                	mov    %esp,%ebp
8010a45d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a460:	8b 45 08             	mov    0x8(%ebp),%eax
8010a463:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a466:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a469:	0f b6 00             	movzbl (%eax),%eax
8010a46c:	83 e0 0f             	and    $0xf,%eax
8010a46f:	01 c0                	add    %eax,%eax
8010a471:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a474:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a47b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a482:	eb 48                	jmp    8010a4cc <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a484:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a487:	01 c0                	add    %eax,%eax
8010a489:	89 c2                	mov    %eax,%edx
8010a48b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a48e:	01 d0                	add    %edx,%eax
8010a490:	0f b6 00             	movzbl (%eax),%eax
8010a493:	0f b6 c0             	movzbl %al,%eax
8010a496:	c1 e0 08             	shl    $0x8,%eax
8010a499:	89 c2                	mov    %eax,%edx
8010a49b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a49e:	01 c0                	add    %eax,%eax
8010a4a0:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4a6:	01 c8                	add    %ecx,%eax
8010a4a8:	0f b6 00             	movzbl (%eax),%eax
8010a4ab:	0f b6 c0             	movzbl %al,%eax
8010a4ae:	01 d0                	add    %edx,%eax
8010a4b0:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a4b3:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a4ba:	76 0c                	jbe    8010a4c8 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a4bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4bf:	0f b7 c0             	movzwl %ax,%eax
8010a4c2:	83 c0 01             	add    $0x1,%eax
8010a4c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a4c8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a4cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a4d0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a4d3:	7c af                	jl     8010a484 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a4d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4d8:	f7 d0                	not    %eax
}
8010a4da:	c9                   	leave
8010a4db:	c3                   	ret

8010a4dc <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a4dc:	f3 0f 1e fb          	endbr32
8010a4e0:	55                   	push   %ebp
8010a4e1:	89 e5                	mov    %esp,%ebp
8010a4e3:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a4e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4e9:	83 c0 0e             	add    $0xe,%eax
8010a4ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4f2:	0f b6 00             	movzbl (%eax),%eax
8010a4f5:	0f b6 c0             	movzbl %al,%eax
8010a4f8:	83 e0 0f             	and    $0xf,%eax
8010a4fb:	c1 e0 02             	shl    $0x2,%eax
8010a4fe:	89 c2                	mov    %eax,%edx
8010a500:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a503:	01 d0                	add    %edx,%eax
8010a505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a50b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a50f:	84 c0                	test   %al,%al
8010a511:	75 4f                	jne    8010a562 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a513:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a516:	0f b6 00             	movzbl (%eax),%eax
8010a519:	3c 08                	cmp    $0x8,%al
8010a51b:	75 45                	jne    8010a562 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a51d:	e8 70 83 ff ff       	call   80102892 <kalloc>
8010a522:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a525:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a52c:	83 ec 04             	sub    $0x4,%esp
8010a52f:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a532:	50                   	push   %eax
8010a533:	ff 75 ec             	push   -0x14(%ebp)
8010a536:	ff 75 08             	push   0x8(%ebp)
8010a539:	e8 7c 00 00 00       	call   8010a5ba <icmp_reply_pkt_create>
8010a53e:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a541:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a544:	83 ec 08             	sub    $0x8,%esp
8010a547:	50                   	push   %eax
8010a548:	ff 75 ec             	push   -0x14(%ebp)
8010a54b:	e8 43 f4 ff ff       	call   80109993 <i8254_send>
8010a550:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a553:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a556:	83 ec 0c             	sub    $0xc,%esp
8010a559:	50                   	push   %eax
8010a55a:	e8 95 82 ff ff       	call   801027f4 <kfree>
8010a55f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a562:	90                   	nop
8010a563:	c9                   	leave
8010a564:	c3                   	ret

8010a565 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a565:	f3 0f 1e fb          	endbr32
8010a569:	55                   	push   %ebp
8010a56a:	89 e5                	mov    %esp,%ebp
8010a56c:	53                   	push   %ebx
8010a56d:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a570:	8b 45 08             	mov    0x8(%ebp),%eax
8010a573:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a577:	0f b7 c0             	movzwl %ax,%eax
8010a57a:	83 ec 0c             	sub    $0xc,%esp
8010a57d:	50                   	push   %eax
8010a57e:	e8 9d fd ff ff       	call   8010a320 <N2H_ushort>
8010a583:	83 c4 10             	add    $0x10,%esp
8010a586:	0f b7 d8             	movzwl %ax,%ebx
8010a589:	8b 45 08             	mov    0x8(%ebp),%eax
8010a58c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a590:	0f b7 c0             	movzwl %ax,%eax
8010a593:	83 ec 0c             	sub    $0xc,%esp
8010a596:	50                   	push   %eax
8010a597:	e8 84 fd ff ff       	call   8010a320 <N2H_ushort>
8010a59c:	83 c4 10             	add    $0x10,%esp
8010a59f:	0f b7 c0             	movzwl %ax,%eax
8010a5a2:	83 ec 04             	sub    $0x4,%esp
8010a5a5:	53                   	push   %ebx
8010a5a6:	50                   	push   %eax
8010a5a7:	68 63 d0 10 80       	push   $0x8010d063
8010a5ac:	e8 5b 5e ff ff       	call   8010040c <cprintf>
8010a5b1:	83 c4 10             	add    $0x10,%esp
}
8010a5b4:	90                   	nop
8010a5b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a5b8:	c9                   	leave
8010a5b9:	c3                   	ret

8010a5ba <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a5ba:	f3 0f 1e fb          	endbr32
8010a5be:	55                   	push   %ebp
8010a5bf:	89 e5                	mov    %esp,%ebp
8010a5c1:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a5c4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a5ca:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5cd:	83 c0 0e             	add    $0xe,%eax
8010a5d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a5d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5d6:	0f b6 00             	movzbl (%eax),%eax
8010a5d9:	0f b6 c0             	movzbl %al,%eax
8010a5dc:	83 e0 0f             	and    $0xf,%eax
8010a5df:	c1 e0 02             	shl    $0x2,%eax
8010a5e2:	89 c2                	mov    %eax,%edx
8010a5e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5e7:	01 d0                	add    %edx,%eax
8010a5e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a5ec:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a5f2:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5f5:	83 c0 0e             	add    $0xe,%eax
8010a5f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a5fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5fe:	83 c0 14             	add    $0x14,%eax
8010a601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a604:	8b 45 10             	mov    0x10(%ebp),%eax
8010a607:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a610:	8d 50 06             	lea    0x6(%eax),%edx
8010a613:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a616:	83 ec 04             	sub    $0x4,%esp
8010a619:	6a 06                	push   $0x6
8010a61b:	52                   	push   %edx
8010a61c:	50                   	push   %eax
8010a61d:	e8 63 b0 ff ff       	call   80105685 <memmove>
8010a622:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a625:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a628:	83 c0 06             	add    $0x6,%eax
8010a62b:	83 ec 04             	sub    $0x4,%esp
8010a62e:	6a 06                	push   $0x6
8010a630:	68 88 e0 18 80       	push   $0x8018e088
8010a635:	50                   	push   %eax
8010a636:	e8 4a b0 ff ff       	call   80105685 <memmove>
8010a63b:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a63e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a641:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a645:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a648:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a64c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a64f:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a655:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a659:	83 ec 0c             	sub    $0xc,%esp
8010a65c:	6a 54                	push   $0x54
8010a65e:	e8 e3 fc ff ff       	call   8010a346 <H2N_ushort>
8010a663:	83 c4 10             	add    $0x10,%esp
8010a666:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a669:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a66d:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010a674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a677:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a67b:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010a682:	83 c0 01             	add    $0x1,%eax
8010a685:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a68b:	83 ec 0c             	sub    $0xc,%esp
8010a68e:	68 00 40 00 00       	push   $0x4000
8010a693:	e8 ae fc ff ff       	call   8010a346 <H2N_ushort>
8010a698:	83 c4 10             	add    $0x10,%esp
8010a69b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a69e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a6a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6a5:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a6a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6ac:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a6b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6b3:	83 c0 0c             	add    $0xc,%eax
8010a6b6:	83 ec 04             	sub    $0x4,%esp
8010a6b9:	6a 04                	push   $0x4
8010a6bb:	68 04 05 11 80       	push   $0x80110504
8010a6c0:	50                   	push   %eax
8010a6c1:	e8 bf af ff ff       	call   80105685 <memmove>
8010a6c6:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a6c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6cc:	8d 50 0c             	lea    0xc(%eax),%edx
8010a6cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6d2:	83 c0 10             	add    $0x10,%eax
8010a6d5:	83 ec 04             	sub    $0x4,%esp
8010a6d8:	6a 04                	push   $0x4
8010a6da:	52                   	push   %edx
8010a6db:	50                   	push   %eax
8010a6dc:	e8 a4 af ff ff       	call   80105685 <memmove>
8010a6e1:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6e7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a6ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6f0:	83 ec 0c             	sub    $0xc,%esp
8010a6f3:	50                   	push   %eax
8010a6f4:	e8 5d fd ff ff       	call   8010a456 <ipv4_chksum>
8010a6f9:	83 c4 10             	add    $0x10,%esp
8010a6fc:	0f b7 c0             	movzwl %ax,%eax
8010a6ff:	83 ec 0c             	sub    $0xc,%esp
8010a702:	50                   	push   %eax
8010a703:	e8 3e fc ff ff       	call   8010a346 <H2N_ushort>
8010a708:	83 c4 10             	add    $0x10,%esp
8010a70b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a70e:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a712:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a715:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a71b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a71f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a722:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a726:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a729:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a72d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a730:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a734:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a737:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a73b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a73e:	8d 50 08             	lea    0x8(%eax),%edx
8010a741:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a744:	83 c0 08             	add    $0x8,%eax
8010a747:	83 ec 04             	sub    $0x4,%esp
8010a74a:	6a 08                	push   $0x8
8010a74c:	52                   	push   %edx
8010a74d:	50                   	push   %eax
8010a74e:	e8 32 af ff ff       	call   80105685 <memmove>
8010a753:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a756:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a759:	8d 50 10             	lea    0x10(%eax),%edx
8010a75c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a75f:	83 c0 10             	add    $0x10,%eax
8010a762:	83 ec 04             	sub    $0x4,%esp
8010a765:	6a 30                	push   $0x30
8010a767:	52                   	push   %edx
8010a768:	50                   	push   %eax
8010a769:	e8 17 af ff ff       	call   80105685 <memmove>
8010a76e:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a771:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a774:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a77a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a77d:	83 ec 0c             	sub    $0xc,%esp
8010a780:	50                   	push   %eax
8010a781:	e8 1c 00 00 00       	call   8010a7a2 <icmp_chksum>
8010a786:	83 c4 10             	add    $0x10,%esp
8010a789:	0f b7 c0             	movzwl %ax,%eax
8010a78c:	83 ec 0c             	sub    $0xc,%esp
8010a78f:	50                   	push   %eax
8010a790:	e8 b1 fb ff ff       	call   8010a346 <H2N_ushort>
8010a795:	83 c4 10             	add    $0x10,%esp
8010a798:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a79b:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a79f:	90                   	nop
8010a7a0:	c9                   	leave
8010a7a1:	c3                   	ret

8010a7a2 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a7a2:	f3 0f 1e fb          	endbr32
8010a7a6:	55                   	push   %ebp
8010a7a7:	89 e5                	mov    %esp,%ebp
8010a7a9:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a7ac:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a7b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a7b9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a7c0:	eb 48                	jmp    8010a80a <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a7c5:	01 c0                	add    %eax,%eax
8010a7c7:	89 c2                	mov    %eax,%edx
8010a7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7cc:	01 d0                	add    %edx,%eax
8010a7ce:	0f b6 00             	movzbl (%eax),%eax
8010a7d1:	0f b6 c0             	movzbl %al,%eax
8010a7d4:	c1 e0 08             	shl    $0x8,%eax
8010a7d7:	89 c2                	mov    %eax,%edx
8010a7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a7dc:	01 c0                	add    %eax,%eax
8010a7de:	8d 48 01             	lea    0x1(%eax),%ecx
8010a7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7e4:	01 c8                	add    %ecx,%eax
8010a7e6:	0f b6 00             	movzbl (%eax),%eax
8010a7e9:	0f b6 c0             	movzbl %al,%eax
8010a7ec:	01 d0                	add    %edx,%eax
8010a7ee:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a7f1:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a7f8:	76 0c                	jbe    8010a806 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a7fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a7fd:	0f b7 c0             	movzwl %ax,%eax
8010a800:	83 c0 01             	add    $0x1,%eax
8010a803:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a806:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a80a:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a80e:	7e b2                	jle    8010a7c2 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a810:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a813:	f7 d0                	not    %eax
}
8010a815:	c9                   	leave
8010a816:	c3                   	ret

8010a817 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a817:	f3 0f 1e fb          	endbr32
8010a81b:	55                   	push   %ebp
8010a81c:	89 e5                	mov    %esp,%ebp
8010a81e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a821:	8b 45 08             	mov    0x8(%ebp),%eax
8010a824:	83 c0 0e             	add    $0xe,%eax
8010a827:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a82d:	0f b6 00             	movzbl (%eax),%eax
8010a830:	0f b6 c0             	movzbl %al,%eax
8010a833:	83 e0 0f             	and    $0xf,%eax
8010a836:	c1 e0 02             	shl    $0x2,%eax
8010a839:	89 c2                	mov    %eax,%edx
8010a83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a83e:	01 d0                	add    %edx,%eax
8010a840:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a843:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a846:	83 c0 14             	add    $0x14,%eax
8010a849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a84c:	e8 41 80 ff ff       	call   80102892 <kalloc>
8010a851:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a854:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a85b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a85e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a862:	0f b6 c0             	movzbl %al,%eax
8010a865:	83 e0 02             	and    $0x2,%eax
8010a868:	85 c0                	test   %eax,%eax
8010a86a:	74 3d                	je     8010a8a9 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a86c:	83 ec 0c             	sub    $0xc,%esp
8010a86f:	6a 00                	push   $0x0
8010a871:	6a 12                	push   $0x12
8010a873:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a876:	50                   	push   %eax
8010a877:	ff 75 e8             	push   -0x18(%ebp)
8010a87a:	ff 75 08             	push   0x8(%ebp)
8010a87d:	e8 a2 01 00 00       	call   8010aa24 <tcp_pkt_create>
8010a882:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a885:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a888:	83 ec 08             	sub    $0x8,%esp
8010a88b:	50                   	push   %eax
8010a88c:	ff 75 e8             	push   -0x18(%ebp)
8010a88f:	e8 ff f0 ff ff       	call   80109993 <i8254_send>
8010a894:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a897:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010a89c:	83 c0 01             	add    $0x1,%eax
8010a89f:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010a8a4:	e9 69 01 00 00       	jmp    8010aa12 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8ac:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a8b0:	3c 18                	cmp    $0x18,%al
8010a8b2:	0f 85 10 01 00 00    	jne    8010a9c8 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a8b8:	83 ec 04             	sub    $0x4,%esp
8010a8bb:	6a 03                	push   $0x3
8010a8bd:	68 7e d0 10 80       	push   $0x8010d07e
8010a8c2:	ff 75 ec             	push   -0x14(%ebp)
8010a8c5:	e8 5f ad ff ff       	call   80105629 <memcmp>
8010a8ca:	83 c4 10             	add    $0x10,%esp
8010a8cd:	85 c0                	test   %eax,%eax
8010a8cf:	74 74                	je     8010a945 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a8d1:	83 ec 0c             	sub    $0xc,%esp
8010a8d4:	68 82 d0 10 80       	push   $0x8010d082
8010a8d9:	e8 2e 5b ff ff       	call   8010040c <cprintf>
8010a8de:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a8e1:	83 ec 0c             	sub    $0xc,%esp
8010a8e4:	6a 00                	push   $0x0
8010a8e6:	6a 10                	push   $0x10
8010a8e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a8eb:	50                   	push   %eax
8010a8ec:	ff 75 e8             	push   -0x18(%ebp)
8010a8ef:	ff 75 08             	push   0x8(%ebp)
8010a8f2:	e8 2d 01 00 00       	call   8010aa24 <tcp_pkt_create>
8010a8f7:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a8fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8fd:	83 ec 08             	sub    $0x8,%esp
8010a900:	50                   	push   %eax
8010a901:	ff 75 e8             	push   -0x18(%ebp)
8010a904:	e8 8a f0 ff ff       	call   80109993 <i8254_send>
8010a909:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a90c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a90f:	83 c0 36             	add    $0x36,%eax
8010a912:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a915:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a918:	50                   	push   %eax
8010a919:	ff 75 e0             	push   -0x20(%ebp)
8010a91c:	6a 00                	push   $0x0
8010a91e:	6a 00                	push   $0x0
8010a920:	e8 66 04 00 00       	call   8010ad8b <http_proc>
8010a925:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a928:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a92b:	83 ec 0c             	sub    $0xc,%esp
8010a92e:	50                   	push   %eax
8010a92f:	6a 18                	push   $0x18
8010a931:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a934:	50                   	push   %eax
8010a935:	ff 75 e8             	push   -0x18(%ebp)
8010a938:	ff 75 08             	push   0x8(%ebp)
8010a93b:	e8 e4 00 00 00       	call   8010aa24 <tcp_pkt_create>
8010a940:	83 c4 20             	add    $0x20,%esp
8010a943:	eb 62                	jmp    8010a9a7 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a945:	83 ec 0c             	sub    $0xc,%esp
8010a948:	6a 00                	push   $0x0
8010a94a:	6a 10                	push   $0x10
8010a94c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a94f:	50                   	push   %eax
8010a950:	ff 75 e8             	push   -0x18(%ebp)
8010a953:	ff 75 08             	push   0x8(%ebp)
8010a956:	e8 c9 00 00 00       	call   8010aa24 <tcp_pkt_create>
8010a95b:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a95e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a961:	83 ec 08             	sub    $0x8,%esp
8010a964:	50                   	push   %eax
8010a965:	ff 75 e8             	push   -0x18(%ebp)
8010a968:	e8 26 f0 ff ff       	call   80109993 <i8254_send>
8010a96d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a970:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a973:	83 c0 36             	add    $0x36,%eax
8010a976:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a979:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a97c:	50                   	push   %eax
8010a97d:	ff 75 e4             	push   -0x1c(%ebp)
8010a980:	6a 00                	push   $0x0
8010a982:	6a 00                	push   $0x0
8010a984:	e8 02 04 00 00       	call   8010ad8b <http_proc>
8010a989:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a98c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a98f:	83 ec 0c             	sub    $0xc,%esp
8010a992:	50                   	push   %eax
8010a993:	6a 18                	push   $0x18
8010a995:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a998:	50                   	push   %eax
8010a999:	ff 75 e8             	push   -0x18(%ebp)
8010a99c:	ff 75 08             	push   0x8(%ebp)
8010a99f:	e8 80 00 00 00       	call   8010aa24 <tcp_pkt_create>
8010a9a4:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a9a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a9aa:	83 ec 08             	sub    $0x8,%esp
8010a9ad:	50                   	push   %eax
8010a9ae:	ff 75 e8             	push   -0x18(%ebp)
8010a9b1:	e8 dd ef ff ff       	call   80109993 <i8254_send>
8010a9b6:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a9b9:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010a9be:	83 c0 01             	add    $0x1,%eax
8010a9c1:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010a9c6:	eb 4a                	jmp    8010aa12 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a9c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a9cb:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a9cf:	3c 10                	cmp    $0x10,%al
8010a9d1:	75 3f                	jne    8010aa12 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a9d3:	a1 68 e3 18 80       	mov    0x8018e368,%eax
8010a9d8:	83 f8 01             	cmp    $0x1,%eax
8010a9db:	75 35                	jne    8010aa12 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a9dd:	83 ec 0c             	sub    $0xc,%esp
8010a9e0:	6a 00                	push   $0x0
8010a9e2:	6a 01                	push   $0x1
8010a9e4:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a9e7:	50                   	push   %eax
8010a9e8:	ff 75 e8             	push   -0x18(%ebp)
8010a9eb:	ff 75 08             	push   0x8(%ebp)
8010a9ee:	e8 31 00 00 00       	call   8010aa24 <tcp_pkt_create>
8010a9f3:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a9f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a9f9:	83 ec 08             	sub    $0x8,%esp
8010a9fc:	50                   	push   %eax
8010a9fd:	ff 75 e8             	push   -0x18(%ebp)
8010aa00:	e8 8e ef ff ff       	call   80109993 <i8254_send>
8010aa05:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010aa08:	c7 05 68 e3 18 80 00 	movl   $0x0,0x8018e368
8010aa0f:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010aa12:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa15:	83 ec 0c             	sub    $0xc,%esp
8010aa18:	50                   	push   %eax
8010aa19:	e8 d6 7d ff ff       	call   801027f4 <kfree>
8010aa1e:	83 c4 10             	add    $0x10,%esp
}
8010aa21:	90                   	nop
8010aa22:	c9                   	leave
8010aa23:	c3                   	ret

8010aa24 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010aa24:	f3 0f 1e fb          	endbr32
8010aa28:	55                   	push   %ebp
8010aa29:	89 e5                	mov    %esp,%ebp
8010aa2b:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010aa2e:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010aa34:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa37:	83 c0 0e             	add    $0xe,%eax
8010aa3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010aa3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa40:	0f b6 00             	movzbl (%eax),%eax
8010aa43:	0f b6 c0             	movzbl %al,%eax
8010aa46:	83 e0 0f             	and    $0xf,%eax
8010aa49:	c1 e0 02             	shl    $0x2,%eax
8010aa4c:	89 c2                	mov    %eax,%edx
8010aa4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa51:	01 d0                	add    %edx,%eax
8010aa53:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010aa56:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa59:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010aa5c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa5f:	83 c0 0e             	add    $0xe,%eax
8010aa62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010aa65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa68:	83 c0 14             	add    $0x14,%eax
8010aa6b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010aa6e:	8b 45 18             	mov    0x18(%ebp),%eax
8010aa71:	8d 50 36             	lea    0x36(%eax),%edx
8010aa74:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa77:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010aa79:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa7c:	8d 50 06             	lea    0x6(%eax),%edx
8010aa7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa82:	83 ec 04             	sub    $0x4,%esp
8010aa85:	6a 06                	push   $0x6
8010aa87:	52                   	push   %edx
8010aa88:	50                   	push   %eax
8010aa89:	e8 f7 ab ff ff       	call   80105685 <memmove>
8010aa8e:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010aa91:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa94:	83 c0 06             	add    $0x6,%eax
8010aa97:	83 ec 04             	sub    $0x4,%esp
8010aa9a:	6a 06                	push   $0x6
8010aa9c:	68 88 e0 18 80       	push   $0x8018e088
8010aaa1:	50                   	push   %eax
8010aaa2:	e8 de ab ff ff       	call   80105685 <memmove>
8010aaa7:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010aaaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aaad:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010aab1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aab4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010aab8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aabb:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010aabe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aac1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010aac5:	8b 45 18             	mov    0x18(%ebp),%eax
8010aac8:	83 c0 28             	add    $0x28,%eax
8010aacb:	0f b7 c0             	movzwl %ax,%eax
8010aace:	83 ec 0c             	sub    $0xc,%esp
8010aad1:	50                   	push   %eax
8010aad2:	e8 6f f8 ff ff       	call   8010a346 <H2N_ushort>
8010aad7:	83 c4 10             	add    $0x10,%esp
8010aada:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aadd:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010aae1:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010aae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aaeb:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010aaef:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010aaf6:	83 c0 01             	add    $0x1,%eax
8010aaf9:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x0000);
8010aaff:	83 ec 0c             	sub    $0xc,%esp
8010ab02:	6a 00                	push   $0x0
8010ab04:	e8 3d f8 ff ff       	call   8010a346 <H2N_ushort>
8010ab09:	83 c4 10             	add    $0x10,%esp
8010ab0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab0f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010ab13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab16:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010ab1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab1d:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010ab21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab24:	83 c0 0c             	add    $0xc,%eax
8010ab27:	83 ec 04             	sub    $0x4,%esp
8010ab2a:	6a 04                	push   $0x4
8010ab2c:	68 04 05 11 80       	push   $0x80110504
8010ab31:	50                   	push   %eax
8010ab32:	e8 4e ab ff ff       	call   80105685 <memmove>
8010ab37:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010ab3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ab3d:	8d 50 0c             	lea    0xc(%eax),%edx
8010ab40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab43:	83 c0 10             	add    $0x10,%eax
8010ab46:	83 ec 04             	sub    $0x4,%esp
8010ab49:	6a 04                	push   $0x4
8010ab4b:	52                   	push   %edx
8010ab4c:	50                   	push   %eax
8010ab4d:	e8 33 ab ff ff       	call   80105685 <memmove>
8010ab52:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010ab55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab58:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010ab5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab61:	83 ec 0c             	sub    $0xc,%esp
8010ab64:	50                   	push   %eax
8010ab65:	e8 ec f8 ff ff       	call   8010a456 <ipv4_chksum>
8010ab6a:	83 c4 10             	add    $0x10,%esp
8010ab6d:	0f b7 c0             	movzwl %ax,%eax
8010ab70:	83 ec 0c             	sub    $0xc,%esp
8010ab73:	50                   	push   %eax
8010ab74:	e8 cd f7 ff ff       	call   8010a346 <H2N_ushort>
8010ab79:	83 c4 10             	add    $0x10,%esp
8010ab7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab7f:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010ab83:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab86:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010ab8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab8d:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010ab90:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab93:	0f b7 10             	movzwl (%eax),%edx
8010ab96:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab99:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010ab9d:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010aba2:	83 ec 0c             	sub    $0xc,%esp
8010aba5:	50                   	push   %eax
8010aba6:	e8 c1 f7 ff ff       	call   8010a36c <H2N_uint>
8010abab:	83 c4 10             	add    $0x10,%esp
8010abae:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010abb1:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010abb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abb7:	8b 40 04             	mov    0x4(%eax),%eax
8010abba:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010abc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abc3:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010abc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abc9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010abcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abd0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010abd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abd7:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010abdb:	8b 45 14             	mov    0x14(%ebp),%eax
8010abde:	89 c2                	mov    %eax,%edx
8010abe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abe3:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010abe6:	83 ec 0c             	sub    $0xc,%esp
8010abe9:	68 90 38 00 00       	push   $0x3890
8010abee:	e8 53 f7 ff ff       	call   8010a346 <H2N_ushort>
8010abf3:	83 c4 10             	add    $0x10,%esp
8010abf6:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010abf9:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010abfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac00:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010ac06:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac09:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010ac0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ac12:	83 ec 0c             	sub    $0xc,%esp
8010ac15:	50                   	push   %eax
8010ac16:	e8 1f 00 00 00       	call   8010ac3a <tcp_chksum>
8010ac1b:	83 c4 10             	add    $0x10,%esp
8010ac1e:	83 c0 08             	add    $0x8,%eax
8010ac21:	0f b7 c0             	movzwl %ax,%eax
8010ac24:	83 ec 0c             	sub    $0xc,%esp
8010ac27:	50                   	push   %eax
8010ac28:	e8 19 f7 ff ff       	call   8010a346 <H2N_ushort>
8010ac2d:	83 c4 10             	add    $0x10,%esp
8010ac30:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ac33:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010ac37:	90                   	nop
8010ac38:	c9                   	leave
8010ac39:	c3                   	ret

8010ac3a <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010ac3a:	f3 0f 1e fb          	endbr32
8010ac3e:	55                   	push   %ebp
8010ac3f:	89 e5                	mov    %esp,%ebp
8010ac41:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010ac44:	8b 45 08             	mov    0x8(%ebp),%eax
8010ac47:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010ac4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac4d:	83 c0 14             	add    $0x14,%eax
8010ac50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010ac53:	83 ec 04             	sub    $0x4,%esp
8010ac56:	6a 04                	push   $0x4
8010ac58:	68 04 05 11 80       	push   $0x80110504
8010ac5d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ac60:	50                   	push   %eax
8010ac61:	e8 1f aa ff ff       	call   80105685 <memmove>
8010ac66:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010ac69:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac6c:	83 c0 0c             	add    $0xc,%eax
8010ac6f:	83 ec 04             	sub    $0x4,%esp
8010ac72:	6a 04                	push   $0x4
8010ac74:	50                   	push   %eax
8010ac75:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ac78:	83 c0 04             	add    $0x4,%eax
8010ac7b:	50                   	push   %eax
8010ac7c:	e8 04 aa ff ff       	call   80105685 <memmove>
8010ac81:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010ac84:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010ac88:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010ac8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac8f:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010ac93:	0f b7 c0             	movzwl %ax,%eax
8010ac96:	83 ec 0c             	sub    $0xc,%esp
8010ac99:	50                   	push   %eax
8010ac9a:	e8 81 f6 ff ff       	call   8010a320 <N2H_ushort>
8010ac9f:	83 c4 10             	add    $0x10,%esp
8010aca2:	83 e8 14             	sub    $0x14,%eax
8010aca5:	0f b7 c0             	movzwl %ax,%eax
8010aca8:	83 ec 0c             	sub    $0xc,%esp
8010acab:	50                   	push   %eax
8010acac:	e8 95 f6 ff ff       	call   8010a346 <H2N_ushort>
8010acb1:	83 c4 10             	add    $0x10,%esp
8010acb4:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010acb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010acbf:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010acc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010acc5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010accc:	eb 33                	jmp    8010ad01 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010acce:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010acd1:	01 c0                	add    %eax,%eax
8010acd3:	89 c2                	mov    %eax,%edx
8010acd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010acd8:	01 d0                	add    %edx,%eax
8010acda:	0f b6 00             	movzbl (%eax),%eax
8010acdd:	0f b6 c0             	movzbl %al,%eax
8010ace0:	c1 e0 08             	shl    $0x8,%eax
8010ace3:	89 c2                	mov    %eax,%edx
8010ace5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ace8:	01 c0                	add    %eax,%eax
8010acea:	8d 48 01             	lea    0x1(%eax),%ecx
8010aced:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010acf0:	01 c8                	add    %ecx,%eax
8010acf2:	0f b6 00             	movzbl (%eax),%eax
8010acf5:	0f b6 c0             	movzbl %al,%eax
8010acf8:	01 d0                	add    %edx,%eax
8010acfa:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010acfd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ad01:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ad05:	7e c7                	jle    8010acce <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ad07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ad0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad0d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ad14:	eb 33                	jmp    8010ad49 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ad16:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad19:	01 c0                	add    %eax,%eax
8010ad1b:	89 c2                	mov    %eax,%edx
8010ad1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad20:	01 d0                	add    %edx,%eax
8010ad22:	0f b6 00             	movzbl (%eax),%eax
8010ad25:	0f b6 c0             	movzbl %al,%eax
8010ad28:	c1 e0 08             	shl    $0x8,%eax
8010ad2b:	89 c2                	mov    %eax,%edx
8010ad2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad30:	01 c0                	add    %eax,%eax
8010ad32:	8d 48 01             	lea    0x1(%eax),%ecx
8010ad35:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad38:	01 c8                	add    %ecx,%eax
8010ad3a:	0f b6 00             	movzbl (%eax),%eax
8010ad3d:	0f b6 c0             	movzbl %al,%eax
8010ad40:	01 d0                	add    %edx,%eax
8010ad42:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad45:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010ad49:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010ad4d:	0f b7 c0             	movzwl %ax,%eax
8010ad50:	83 ec 0c             	sub    $0xc,%esp
8010ad53:	50                   	push   %eax
8010ad54:	e8 c7 f5 ff ff       	call   8010a320 <N2H_ushort>
8010ad59:	83 c4 10             	add    $0x10,%esp
8010ad5c:	66 d1 e8             	shr    $1,%ax
8010ad5f:	0f b7 c0             	movzwl %ax,%eax
8010ad62:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010ad65:	7c af                	jl     8010ad16 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010ad67:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ad6a:	c1 e8 10             	shr    $0x10,%eax
8010ad6d:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010ad70:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ad73:	f7 d0                	not    %eax
}
8010ad75:	c9                   	leave
8010ad76:	c3                   	ret

8010ad77 <tcp_fin>:

void tcp_fin(){
8010ad77:	f3 0f 1e fb          	endbr32
8010ad7b:	55                   	push   %ebp
8010ad7c:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010ad7e:	c7 05 68 e3 18 80 01 	movl   $0x1,0x8018e368
8010ad85:	00 00 00 
}
8010ad88:	90                   	nop
8010ad89:	5d                   	pop    %ebp
8010ad8a:	c3                   	ret

8010ad8b <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010ad8b:	f3 0f 1e fb          	endbr32
8010ad8f:	55                   	push   %ebp
8010ad90:	89 e5                	mov    %esp,%ebp
8010ad92:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010ad95:	8b 45 10             	mov    0x10(%ebp),%eax
8010ad98:	83 ec 04             	sub    $0x4,%esp
8010ad9b:	6a 00                	push   $0x0
8010ad9d:	68 8b d0 10 80       	push   $0x8010d08b
8010ada2:	50                   	push   %eax
8010ada3:	e8 65 00 00 00       	call   8010ae0d <http_strcpy>
8010ada8:	83 c4 10             	add    $0x10,%esp
8010adab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010adae:	8b 45 10             	mov    0x10(%ebp),%eax
8010adb1:	83 ec 04             	sub    $0x4,%esp
8010adb4:	ff 75 f4             	push   -0xc(%ebp)
8010adb7:	68 9e d0 10 80       	push   $0x8010d09e
8010adbc:	50                   	push   %eax
8010adbd:	e8 4b 00 00 00       	call   8010ae0d <http_strcpy>
8010adc2:	83 c4 10             	add    $0x10,%esp
8010adc5:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010adc8:	8b 45 10             	mov    0x10(%ebp),%eax
8010adcb:	83 ec 04             	sub    $0x4,%esp
8010adce:	ff 75 f4             	push   -0xc(%ebp)
8010add1:	68 b9 d0 10 80       	push   $0x8010d0b9
8010add6:	50                   	push   %eax
8010add7:	e8 31 00 00 00       	call   8010ae0d <http_strcpy>
8010addc:	83 c4 10             	add    $0x10,%esp
8010addf:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ade2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ade5:	83 e0 01             	and    $0x1,%eax
8010ade8:	85 c0                	test   %eax,%eax
8010adea:	74 11                	je     8010adfd <http_proc+0x72>
    char *payload = (char *)send;
8010adec:	8b 45 10             	mov    0x10(%ebp),%eax
8010adef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010adf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010adf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010adf8:	01 d0                	add    %edx,%eax
8010adfa:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010adfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ae00:	8b 45 14             	mov    0x14(%ebp),%eax
8010ae03:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ae05:	e8 6d ff ff ff       	call   8010ad77 <tcp_fin>
}
8010ae0a:	90                   	nop
8010ae0b:	c9                   	leave
8010ae0c:	c3                   	ret

8010ae0d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ae0d:	f3 0f 1e fb          	endbr32
8010ae11:	55                   	push   %ebp
8010ae12:	89 e5                	mov    %esp,%ebp
8010ae14:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ae17:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ae1e:	eb 20                	jmp    8010ae40 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ae20:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae23:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae26:	01 d0                	add    %edx,%eax
8010ae28:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ae2b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae2e:	01 ca                	add    %ecx,%edx
8010ae30:	89 d1                	mov    %edx,%ecx
8010ae32:	8b 55 08             	mov    0x8(%ebp),%edx
8010ae35:	01 ca                	add    %ecx,%edx
8010ae37:	0f b6 00             	movzbl (%eax),%eax
8010ae3a:	88 02                	mov    %al,(%edx)
    i++;
8010ae3c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010ae40:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae43:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae46:	01 d0                	add    %edx,%eax
8010ae48:	0f b6 00             	movzbl (%eax),%eax
8010ae4b:	84 c0                	test   %al,%al
8010ae4d:	75 d1                	jne    8010ae20 <http_strcpy+0x13>
  }
  return i;
8010ae4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010ae52:	c9                   	leave
8010ae53:	c3                   	ret

8010ae54 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010ae54:	f3 0f 1e fb          	endbr32
8010ae58:	55                   	push   %ebp
8010ae59:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010ae5b:	c7 05 70 e3 18 80 c2 	movl   $0x801105c2,0x8018e370
8010ae62:	05 11 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010ae65:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010ae6a:	c1 e8 09             	shr    $0x9,%eax
8010ae6d:	a3 6c e3 18 80       	mov    %eax,0x8018e36c
}
8010ae72:	90                   	nop
8010ae73:	5d                   	pop    %ebp
8010ae74:	c3                   	ret

8010ae75 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010ae75:	f3 0f 1e fb          	endbr32
8010ae79:	55                   	push   %ebp
8010ae7a:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010ae7c:	90                   	nop
8010ae7d:	5d                   	pop    %ebp
8010ae7e:	c3                   	ret

8010ae7f <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010ae7f:	f3 0f 1e fb          	endbr32
8010ae83:	55                   	push   %ebp
8010ae84:	89 e5                	mov    %esp,%ebp
8010ae86:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010ae89:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae8c:	83 c0 0c             	add    $0xc,%eax
8010ae8f:	83 ec 0c             	sub    $0xc,%esp
8010ae92:	50                   	push   %eax
8010ae93:	e8 fe a3 ff ff       	call   80105296 <holdingsleep>
8010ae98:	83 c4 10             	add    $0x10,%esp
8010ae9b:	85 c0                	test   %eax,%eax
8010ae9d:	75 0d                	jne    8010aeac <iderw+0x2d>
    panic("iderw: buf not locked");
8010ae9f:	83 ec 0c             	sub    $0xc,%esp
8010aea2:	68 ca d0 10 80       	push   $0x8010d0ca
8010aea7:	e8 19 57 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010aeac:	8b 45 08             	mov    0x8(%ebp),%eax
8010aeaf:	8b 00                	mov    (%eax),%eax
8010aeb1:	83 e0 06             	and    $0x6,%eax
8010aeb4:	83 f8 02             	cmp    $0x2,%eax
8010aeb7:	75 0d                	jne    8010aec6 <iderw+0x47>
    panic("iderw: nothing to do");
8010aeb9:	83 ec 0c             	sub    $0xc,%esp
8010aebc:	68 e0 d0 10 80       	push   $0x8010d0e0
8010aec1:	e8 ff 56 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010aec6:	8b 45 08             	mov    0x8(%ebp),%eax
8010aec9:	8b 40 04             	mov    0x4(%eax),%eax
8010aecc:	83 f8 01             	cmp    $0x1,%eax
8010aecf:	74 0d                	je     8010aede <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010aed1:	83 ec 0c             	sub    $0xc,%esp
8010aed4:	68 f5 d0 10 80       	push   $0x8010d0f5
8010aed9:	e8 e7 56 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010aede:	8b 45 08             	mov    0x8(%ebp),%eax
8010aee1:	8b 40 08             	mov    0x8(%eax),%eax
8010aee4:	8b 15 6c e3 18 80    	mov    0x8018e36c,%edx
8010aeea:	39 d0                	cmp    %edx,%eax
8010aeec:	72 0d                	jb     8010aefb <iderw+0x7c>
    panic("iderw: block out of range");
8010aeee:	83 ec 0c             	sub    $0xc,%esp
8010aef1:	68 13 d1 10 80       	push   $0x8010d113
8010aef6:	e8 ca 56 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010aefb:	8b 15 70 e3 18 80    	mov    0x8018e370,%edx
8010af01:	8b 45 08             	mov    0x8(%ebp),%eax
8010af04:	8b 40 08             	mov    0x8(%eax),%eax
8010af07:	c1 e0 09             	shl    $0x9,%eax
8010af0a:	01 d0                	add    %edx,%eax
8010af0c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010af0f:	8b 45 08             	mov    0x8(%ebp),%eax
8010af12:	8b 00                	mov    (%eax),%eax
8010af14:	83 e0 04             	and    $0x4,%eax
8010af17:	85 c0                	test   %eax,%eax
8010af19:	74 2b                	je     8010af46 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010af1b:	8b 45 08             	mov    0x8(%ebp),%eax
8010af1e:	8b 00                	mov    (%eax),%eax
8010af20:	83 e0 fb             	and    $0xfffffffb,%eax
8010af23:	89 c2                	mov    %eax,%edx
8010af25:	8b 45 08             	mov    0x8(%ebp),%eax
8010af28:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010af2a:	8b 45 08             	mov    0x8(%ebp),%eax
8010af2d:	83 c0 5c             	add    $0x5c,%eax
8010af30:	83 ec 04             	sub    $0x4,%esp
8010af33:	68 00 02 00 00       	push   $0x200
8010af38:	50                   	push   %eax
8010af39:	ff 75 f4             	push   -0xc(%ebp)
8010af3c:	e8 44 a7 ff ff       	call   80105685 <memmove>
8010af41:	83 c4 10             	add    $0x10,%esp
8010af44:	eb 1a                	jmp    8010af60 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010af46:	8b 45 08             	mov    0x8(%ebp),%eax
8010af49:	83 c0 5c             	add    $0x5c,%eax
8010af4c:	83 ec 04             	sub    $0x4,%esp
8010af4f:	68 00 02 00 00       	push   $0x200
8010af54:	ff 75 f4             	push   -0xc(%ebp)
8010af57:	50                   	push   %eax
8010af58:	e8 28 a7 ff ff       	call   80105685 <memmove>
8010af5d:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010af60:	8b 45 08             	mov    0x8(%ebp),%eax
8010af63:	8b 00                	mov    (%eax),%eax
8010af65:	83 c8 02             	or     $0x2,%eax
8010af68:	89 c2                	mov    %eax,%edx
8010af6a:	8b 45 08             	mov    0x8(%ebp),%eax
8010af6d:	89 10                	mov    %edx,(%eax)
}
8010af6f:	90                   	nop
8010af70:	c9                   	leave
8010af71:	c3                   	ret
