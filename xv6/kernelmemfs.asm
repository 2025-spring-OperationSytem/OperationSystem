
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
80100073:	68 a0 af 10 80       	push   $0x8010afa0
80100078:	68 80 f3 18 80       	push   $0x8018f380
8010007d:	e8 a5 52 00 00       	call   80105327 <initlock>
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
801000c1:	68 a7 af 10 80       	push   $0x8010afa7
801000c6:	50                   	push   %eax
801000c7:	e8 ee 50 00 00       	call   801051ba <initsleeplock>
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
80100109:	e8 3f 52 00 00       	call   8010534d <acquire>
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
80100148:	e8 72 52 00 00       	call   801053bf <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 9b 50 00 00       	call   801051fa <acquiresleep>
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
801001c9:	e8 f1 51 00 00       	call   801053bf <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 1a 50 00 00       	call   801051fa <acquiresleep>
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
801001fd:	68 ae af 10 80       	push   $0x8010afae
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
80100239:	e8 5f ac 00 00       	call   8010ae9d <iderw>
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
8010025a:	e8 55 50 00 00       	call   801052b4 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 bf af 10 80       	push   $0x8010afbf
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
80100288:	e8 10 ac 00 00       	call   8010ae9d <iderw>
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
801002a7:	e8 08 50 00 00       	call   801052b4 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 c6 af 10 80       	push   $0x8010afc6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 93 4f 00 00       	call   80105262 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 80 f3 18 80       	push   $0x8018f380
801002da:	e8 6e 50 00 00       	call   8010534d <acquire>
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
8010034a:	e8 70 50 00 00       	call   801053bf <release>
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
8010042c:	e8 1c 4f 00 00       	call   8010534d <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 cd af 10 80       	push   $0x8010afcd
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
8010052c:	c7 45 ec d6 af 10 80 	movl   $0x8010afd6,-0x14(%ebp)
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
801005ba:	e8 00 4e 00 00       	call   801053bf <release>
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
801005e7:	68 dd af 10 80       	push   $0x8010afdd
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
80100606:	68 f1 af 10 80       	push   $0x8010aff1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 f2 4d 00 00       	call   80105415 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 f3 af 10 80       	push   $0x8010aff3
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
801006c4:	e8 68 86 00 00       	call   80108d31 <graphic_scroll_up>
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
80100717:	e8 15 86 00 00       	call   80108d31 <graphic_scroll_up>
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
8010077d:	e8 23 86 00 00       	call   80108da5 <font_render>
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
801007bd:	e8 84 69 00 00       	call   80107146 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 77 69 00 00       	call   80107146 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 6a 69 00 00       	call   80107146 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 5a 69 00 00       	call   80107146 <uartputc>
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
80100819:	e8 2f 4b 00 00       	call   8010534d <acquire>
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
8010096f:	e8 06 3e 00 00       	call   8010477a <wakeup>
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
80100992:	e8 28 4a 00 00       	call   801053bf <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 98 3e 00 00       	call   8010483d <procdump>
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
801009ce:	e8 7a 49 00 00       	call   8010534d <acquire>
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
801009ef:	e8 cb 49 00 00       	call   801053bf <release>
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
80100a1c:	e8 6a 3c 00 00       	call   8010468b <sleep>
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
80100a9a:	e8 20 49 00 00       	call   801053bf <release>
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
80100adc:	e8 6c 48 00 00       	call   8010534d <acquire>
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
80100b1e:	e8 9c 48 00 00       	call   801053bf <release>
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
80100b50:	68 f7 af 10 80       	push   $0x8010aff7
80100b55:	68 20 e0 18 80       	push   $0x8018e020
80100b5a:	e8 c8 47 00 00       	call   80105327 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 2c 47 19 80 bc 	movl   $0x80100abc,0x8019472c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 28 47 19 80 a8 	movl   $0x801009a8,0x80194728
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 ff af 10 80 	movl   $0x8010afff,-0xc(%ebp)
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
80100bf7:	68 15 b0 10 80       	push   $0x8010b015
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
80100c53:	e8 02 75 00 00       	call   8010815a <setupkvm>
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
80100cf9:	e8 6e 78 00 00       	call   8010856c <allocuvm>
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
80100d3f:	e8 57 77 00 00       	call   8010849b <loaduvm>
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
80100dae:	e8 b9 77 00 00       	call   8010856c <allocuvm>
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
80100dd2:	e8 03 7a 00 00       	call   801087da <clearpteu>
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
80100e0b:	e8 35 4a 00 00       	call   80105845 <strlen>
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
80100e38:	e8 08 4a 00 00       	call   80105845 <strlen>
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
80100e5e:	e8 22 7b 00 00       	call   80108985 <copyout>
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
80100efa:	e8 86 7a 00 00       	call   80108985 <copyout>
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
80100f48:	e8 aa 48 00 00       	call   801057f7 <safestrcpy>
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
80100f8b:	e8 f4 72 00 00       	call   80108284 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 9f 77 00 00       	call   8010873d <freevm>
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
80100fd9:	e8 5f 77 00 00       	call   8010873d <freevm>
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
8010100e:	68 21 b0 10 80       	push   $0x8010b021
80101013:	68 80 3d 19 80       	push   $0x80193d80
80101018:	e8 0a 43 00 00       	call   80105327 <initlock>
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
80101035:	e8 13 43 00 00       	call   8010534d <acquire>
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
80101062:	e8 58 43 00 00       	call   801053bf <release>
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
80101085:	e8 35 43 00 00       	call   801053bf <release>
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
801010a6:	e8 a2 42 00 00       	call   8010534d <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 28 b0 10 80       	push   $0x8010b028
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
801010dc:	e8 de 42 00 00       	call   801053bf <release>
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
801010fb:	e8 4d 42 00 00       	call   8010534d <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 30 b0 10 80       	push   $0x8010b030
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
8010113b:	e8 7f 42 00 00       	call   801053bf <release>
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
80101189:	e8 31 42 00 00       	call   801053bf <release>
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
801012e0:	68 3a b0 10 80       	push   $0x8010b03a
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
801013e7:	68 43 b0 10 80       	push   $0x8010b043
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
8010141d:	68 53 b0 10 80       	push   $0x8010b053
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
80101459:	e8 45 42 00 00       	call   801056a3 <memmove>
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
801014a3:	e8 34 41 00 00       	call   801055dc <memset>
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
8010160e:	68 60 b0 10 80       	push   $0x8010b060
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
801016a5:	68 76 b0 10 80       	push   $0x8010b076
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
8010170d:	68 89 b0 10 80       	push   $0x8010b089
80101712:	68 a0 47 19 80       	push   $0x801947a0
80101717:	e8 0b 3c 00 00       	call   80105327 <initlock>
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
80101743:	68 90 b0 10 80       	push   $0x8010b090
80101748:	50                   	push   %eax
80101749:	e8 6c 3a 00 00       	call   801051ba <initsleeplock>
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
801017a2:	68 98 b0 10 80       	push   $0x8010b098
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
8010181f:	e8 b8 3d 00 00       	call   801055dc <memset>
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
80101887:	68 eb b0 10 80       	push   $0x8010b0eb
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
80101931:	e8 6d 3d 00 00       	call   801056a3 <memmove>
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
8010196a:	e8 de 39 00 00       	call   8010534d <acquire>
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
801019b8:	e8 02 3a 00 00       	call   801053bf <release>
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
801019f4:	68 fd b0 10 80       	push   $0x8010b0fd
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
80101a31:	e8 89 39 00 00       	call   801053bf <release>
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
80101a50:	e8 f8 38 00 00       	call   8010534d <acquire>
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
80101a6f:	e8 4b 39 00 00       	call   801053bf <release>
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
80101a99:	68 0d b1 10 80       	push   $0x8010b10d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 48 37 00 00       	call   801051fa <acquiresleep>
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
80101b57:	e8 47 3b 00 00       	call   801056a3 <memmove>
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
80101b86:	68 13 b1 10 80       	push   $0x8010b113
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
80101bad:	e8 02 37 00 00       	call   801052b4 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 22 b1 10 80       	push   $0x8010b122
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 83 36 00 00       	call   80105262 <releasesleep>
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
80101bf9:	e8 fc 35 00 00       	call   801051fa <acquiresleep>
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
80101c1f:	e8 29 37 00 00       	call   8010534d <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 a0 47 19 80       	push   $0x801947a0
80101c38:	e8 82 37 00 00       	call   801053bf <release>
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
80101c7f:	e8 de 35 00 00       	call   80105262 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 a0 47 19 80       	push   $0x801947a0
80101c8f:	e8 b9 36 00 00       	call   8010534d <acquire>
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
80101cae:	e8 0c 37 00 00       	call   801053bf <release>
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
80101dfa:	68 2a b1 10 80       	push   $0x8010b12a
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
801020a4:	e8 fa 35 00 00       	call   801056a3 <memmove>
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
801021f8:	e8 a6 34 00 00       	call   801056a3 <memmove>
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
8010227c:	e8 c0 34 00 00       	call   80105741 <strncmp>
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
801022a0:	68 3d b1 10 80       	push   $0x8010b13d
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
801022cf:	68 4f b1 10 80       	push   $0x8010b14f
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
801023a8:	68 5e b1 10 80       	push   $0x8010b15e
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
801023e3:	e8 b3 33 00 00       	call   8010579b <strncpy>
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
8010240f:	68 6b b1 10 80       	push   $0x8010b16b
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
80102485:	e8 19 32 00 00       	call   801056a3 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 02 32 00 00       	call   801056a3 <memmove>
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
801026ab:	68 74 b1 10 80       	push   $0x8010b174
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
8010275a:	68 a6 b1 10 80       	push   $0x8010b1a6
8010275f:	68 00 64 19 80       	push   $0x80196400
80102764:	e8 be 2b 00 00       	call   80105327 <initlock>
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
80102825:	68 ab b1 10 80       	push   $0x8010b1ab
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 9b 2d 00 00       	call   801055dc <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 34 64 19 80       	mov    0x80196434,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 00 64 19 80       	push   $0x80196400
80102855:	e8 f3 2a 00 00       	call   8010534d <acquire>
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
80102887:	e8 33 2b 00 00       	call   801053bf <release>
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
801028ad:	e8 9b 2a 00 00       	call   8010534d <acquire>
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
801028de:	e8 dc 2a 00 00       	call   801053bf <release>
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
80102e33:	e8 0f 28 00 00       	call   80105647 <memcmp>
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
80102f4b:	68 b1 b1 10 80       	push   $0x8010b1b1
80102f50:	68 40 64 19 80       	push   $0x80196440
80102f55:	e8 cd 23 00 00       	call   80105327 <initlock>
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
80103004:	e8 9a 26 00 00       	call   801056a3 <memmove>
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
80103183:	e8 c5 21 00 00       	call   8010534d <acquire>
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
801031a1:	e8 e5 14 00 00       	call   8010468b <sleep>
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
801031d6:	e8 b0 14 00 00       	call   8010468b <sleep>
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
801031f5:	e8 c5 21 00 00       	call   801053bf <release>
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
8010321a:	e8 2e 21 00 00       	call   8010534d <acquire>
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
8010323b:	68 b5 b1 10 80       	push   $0x8010b1b5
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
80103269:	e8 0c 15 00 00       	call   8010477a <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 40 64 19 80       	push   $0x80196440
80103279:	e8 41 21 00 00       	call   801053bf <release>
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
80103294:	e8 b4 20 00 00       	call   8010534d <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 80 64 19 80 00 	movl   $0x0,0x80196480
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 40 64 19 80       	push   $0x80196440
801032ae:	e8 c7 14 00 00       	call   8010477a <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 40 64 19 80       	push   $0x80196440
801032be:	e8 fc 20 00 00       	call   801053bf <release>
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
8010333e:	e8 60 23 00 00       	call   801056a3 <memmove>
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
801033e3:	68 c4 b1 10 80       	push   $0x8010b1c4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 7c 64 19 80       	mov    0x8019647c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 da b1 10 80       	push   $0x8010b1da
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 40 64 19 80       	push   $0x80196440
8010340b:	e8 3d 1f 00 00       	call   8010534d <acquire>
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
80103489:	e8 31 1f 00 00       	call   801053bf <release>
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
801034c3:	e8 a5 57 00 00       	call   80108c6d <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 a0 19 80       	push   $0x8019a000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 69 4d 00 00       	call   8010824b <kvmalloc>
  mpinit_uefi();
801034e2:	e8 40 55 00 00       	call   80108a27 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 e1 47 00 00       	call   80107cd2 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 56 3b 00 00       	call   8010705b <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 e7 35 00 00       	call   80106af6 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 54 79 00 00       	call   8010ae72 <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 a3 59 00 00       	call   80108ee0 <pci_init>
  arp_scan();
8010353d:	e8 1c 67 00 00       	call   80109c5e <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 39 08 00 00       	call   80103d80 <userinit>

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
80103556:	e8 0c 4d 00 00       	call   80108267 <switchkvm>
  seginit();
8010355b:	e8 72 47 00 00       	call   80107cd2 <seginit>
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
80103586:	68 f5 b1 10 80       	push   $0x8010b1f5
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 d8 36 00 00       	call   80106c70 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 6b 0e 00 00       	call   80104420 <scheduler>

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
801035d7:	e8 c7 20 00 00       	call   801056a3 <memmove>
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
80103768:	68 09 b2 10 80       	push   $0x8010b209
8010376d:	50                   	push   %eax
8010376e:	e8 b4 1b 00 00       	call   80105327 <initlock>
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
80103831:	e8 17 1b 00 00       	call   8010534d <acquire>
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
80103858:	e8 1d 0f 00 00       	call   8010477a <wakeup>
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
8010387b:	e8 fa 0e 00 00       	call   8010477a <wakeup>
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
801038a4:	e8 16 1b 00 00       	call   801053bf <release>
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
801038c3:	e8 f7 1a 00 00       	call   801053bf <release>
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
801038e1:	e8 67 1a 00 00       	call   8010534d <acquire>
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
80103915:	e8 a5 1a 00 00       	call   801053bf <release>
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
80103933:	e8 42 0e 00 00       	call   8010477a <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 3a 0d 00 00       	call   8010468b <sleep>
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
801039b6:	e8 bf 0d 00 00       	call   8010477a <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 f5 19 00 00       	call   801053bf <release>
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
801039e6:	e8 62 19 00 00       	call   8010534d <acquire>
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
80103a03:	e8 b7 19 00 00       	call   801053bf <release>
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
80103a26:	e8 60 0c 00 00       	call   8010468b <sleep>
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
80103ab9:	e8 bc 0c 00 00       	call   8010477a <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 f2 18 00 00       	call   801053bf <release>
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
80103af9:	68 10 b2 10 80       	push   $0x8010b210
80103afe:	68 20 75 19 80       	push   $0x80197520
80103b03:	e8 1f 18 00 00       	call   80105327 <initlock>
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
80103b48:	68 18 b2 10 80       	push   $0x8010b218
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
80103b9d:	68 3e b2 10 80       	push   $0x8010b23e
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
80103bb3:	e8 11 19 00 00       	call   801054c9 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 49 19 00 00       	call   8010551a <popcli>
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
80103be8:	e8 60 17 00 00       	call   8010534d <acquire>
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
80103c18:	e8 a2 17 00 00       	call   801053bf <release>
80103c1d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c20:	b8 00 00 00 00       	mov    $0x0,%eax
80103c25:	e9 54 01 00 00       	jmp    80103d7e <allocproc+0x1a8>
      goto found;
80103c2a:	90                   	nop
80103c2b:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid;
80103c39:	8b 15 00 00 11 80    	mov    0x80110000,%edx
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	89 50 10             	mov    %edx,0x10(%eax)
  nextpid++;
80103c45:	a1 00 00 11 80       	mov    0x80110000,%eax
80103c4a:	83 c0 01             	add    $0x1,%eax
80103c4d:	a3 00 00 11 80       	mov    %eax,0x80110000

  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
80103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c55:	2d 54 75 19 80       	sub    $0x80197554,%eax
80103c5a:	c1 f8 02             	sar    $0x2,%eax
80103c5d:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  kernel_pstat.inuse[i] = 1;
80103c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c69:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
80103c70:	01 00 00 00 
  kernel_pstat.pid[i] = p->pid;
80103c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c77:	8b 40 10             	mov    0x10(%eax),%eax
80103c7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c7d:	83 c2 40             	add    $0x40,%edx
80103c80:	89 04 95 20 69 19 80 	mov    %eax,-0x7fe696e0(,%edx,4)
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
80103c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8a:	83 e8 80             	sub    $0xffffff80,%eax
80103c8d:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80103c94:	03 00 00 00 
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
80103c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9b:	83 c0 40             	add    $0x40,%eax
80103c9e:	c1 e0 04             	shl    $0x4,%eax
80103ca1:	05 20 69 19 80       	add    $0x80196920,%eax
80103ca6:	83 ec 04             	sub    $0x4,%esp
80103ca9:	6a 10                	push   $0x10
80103cab:	6a 00                	push   $0x0
80103cad:	50                   	push   %eax
80103cae:	e8 29 19 00 00       	call   801055dc <memset>
80103cb3:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));
80103cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb9:	83 e8 80             	sub    $0xffffff80,%eax
80103cbc:	c1 e0 04             	shl    $0x4,%eax
80103cbf:	05 20 69 19 80       	add    $0x80196920,%eax
80103cc4:	83 ec 04             	sub    $0x4,%esp
80103cc7:	6a 10                	push   $0x10
80103cc9:	6a 00                	push   $0x0
80103ccb:	50                   	push   %eax
80103ccc:	e8 0b 19 00 00       	call   801055dc <memset>
80103cd1:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103cd4:	83 ec 0c             	sub    $0xc,%esp
80103cd7:	68 20 75 19 80       	push   $0x80197520
80103cdc:	e8 de 16 00 00       	call   801053bf <release>
80103ce1:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ce4:	e8 a9 eb ff ff       	call   80102892 <kalloc>
80103ce9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cec:	89 42 08             	mov    %eax,0x8(%edx)
80103cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf2:	8b 40 08             	mov    0x8(%eax),%eax
80103cf5:	85 c0                	test   %eax,%eax
80103cf7:	75 28                	jne    80103d21 <allocproc+0x14b>
    cprintf("[ALLOC ERROR] kstack alloc failed for PID=%d\n", p->pid);
80103cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfc:	8b 40 10             	mov    0x10(%eax),%eax
80103cff:	83 ec 08             	sub    $0x8,%esp
80103d02:	50                   	push   %eax
80103d03:	68 50 b2 10 80       	push   $0x8010b250
80103d08:	e8 ff c6 ff ff       	call   8010040c <cprintf>
80103d0d:	83 c4 10             	add    $0x10,%esp
    p->state = UNUSED;
80103d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d13:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103d1a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1f:	eb 5d                	jmp    80103d7e <allocproc+0x1a8>
  }
  sp = p->kstack + KSTACKSIZE;
80103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d24:	8b 40 08             	mov    0x8(%eax),%eax
80103d27:	05 00 10 00 00       	add    $0x1000,%eax
80103d2c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103d2f:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d39:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103d3c:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103d40:	ba b0 6a 10 80       	mov    $0x80106ab0,%edx
80103d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d48:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d4a:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d51:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103d54:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d5d:	83 ec 04             	sub    $0x4,%esp
80103d60:	6a 14                	push   $0x14
80103d62:	6a 00                	push   $0x0
80103d64:	50                   	push   %eax
80103d65:	e8 72 18 00 00       	call   801055dc <memset>
80103d6a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d70:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d73:	ba 41 46 10 80       	mov    $0x80104641,%edx
80103d78:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d7e:	c9                   	leave
80103d7f:	c3                   	ret

80103d80 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d80:	f3 0f 1e fb          	endbr32
80103d84:	55                   	push   %ebp
80103d85:	89 e5                	mov    %esp,%ebp
80103d87:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d8a:	e8 47 fe ff ff       	call   80103bd6 <allocproc>
80103d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d95:	a3 7c e0 18 80       	mov    %eax,0x8018e07c
  if((p->pgdir = setupkvm()) == 0){
80103d9a:	e8 bb 43 00 00       	call   8010815a <setupkvm>
80103d9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da2:	89 42 04             	mov    %eax,0x4(%edx)
80103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da8:	8b 40 04             	mov    0x4(%eax),%eax
80103dab:	85 c0                	test   %eax,%eax
80103dad:	75 0d                	jne    80103dbc <userinit+0x3c>
    panic("userinit: out of memory?");
80103daf:	83 ec 0c             	sub    $0xc,%esp
80103db2:	68 7e b2 10 80       	push   $0x8010b27e
80103db7:	e8 09 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103dbc:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	8b 40 04             	mov    0x4(%eax),%eax
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	52                   	push   %edx
80103dcb:	68 0c 05 11 80       	push   $0x8011050c
80103dd0:	50                   	push   %eax
80103dd1:	e8 51 46 00 00       	call   80108427 <inituvm>
80103dd6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddc:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de5:	8b 40 18             	mov    0x18(%eax),%eax
80103de8:	83 ec 04             	sub    $0x4,%esp
80103deb:	6a 4c                	push   $0x4c
80103ded:	6a 00                	push   $0x0
80103def:	50                   	push   %eax
80103df0:	e8 e7 17 00 00       	call   801055dc <memset>
80103df5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfb:	8b 40 18             	mov    0x18(%eax),%eax
80103dfe:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e07:	8b 40 18             	mov    0x18(%eax),%eax
80103e0a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e13:	8b 50 18             	mov    0x18(%eax),%edx
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	8b 40 18             	mov    0x18(%eax),%eax
80103e1c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e20:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e27:	8b 50 18             	mov    0x18(%eax),%edx
80103e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2d:	8b 40 18             	mov    0x18(%eax),%eax
80103e30:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e34:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3b:	8b 40 18             	mov    0x18(%eax),%eax
80103e3e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e48:	8b 40 18             	mov    0x18(%eax),%eax
80103e4b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e55:	8b 40 18             	mov    0x18(%eax),%eax
80103e58:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e62:	83 c0 6c             	add    $0x6c,%eax
80103e65:	83 ec 04             	sub    $0x4,%esp
80103e68:	6a 10                	push   $0x10
80103e6a:	68 97 b2 10 80       	push   $0x8010b297
80103e6f:	50                   	push   %eax
80103e70:	e8 82 19 00 00       	call   801057f7 <safestrcpy>
80103e75:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	68 a0 b2 10 80       	push   $0x8010b2a0
80103e80:	e8 62 e7 ff ff       	call   801025e7 <namei>
80103e85:	83 c4 10             	add    $0x10,%esp
80103e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e8b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e8e:	83 ec 0c             	sub    $0xc,%esp
80103e91:	68 20 75 19 80       	push   $0x80197520
80103e96:	e8 b2 14 00 00       	call   8010534d <acquire>
80103e9b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  if (mycpu()->sched_policy > 0)
80103ea8:	e8 80 fc ff ff       	call   80103b2d <mycpu>
80103ead:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103eb3:	85 c0                	test   %eax,%eax
80103eb5:	7e 10                	jle    80103ec7 <userinit+0x147>
  enqueue(p, 3);
80103eb7:	83 ec 08             	sub    $0x8,%esp
80103eba:	6a 03                	push   $0x3
80103ebc:	ff 75 f4             	push   -0xc(%ebp)
80103ebf:	e8 c1 0c 00 00       	call   80104b85 <enqueue>
80103ec4:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103ec7:	83 ec 0c             	sub    $0xc,%esp
80103eca:	68 20 75 19 80       	push   $0x80197520
80103ecf:	e8 eb 14 00 00       	call   801053bf <release>
80103ed4:	83 c4 10             	add    $0x10,%esp
}
80103ed7:	90                   	nop
80103ed8:	c9                   	leave
80103ed9:	c3                   	ret

80103eda <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103eda:	f3 0f 1e fb          	endbr32
80103ede:	55                   	push   %ebp
80103edf:	89 e5                	mov    %esp,%ebp
80103ee1:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ee4:	e8 c0 fc ff ff       	call   80103ba9 <myproc>
80103ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eef:	8b 00                	mov    (%eax),%eax
80103ef1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ef4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ef8:	7e 2e                	jle    80103f28 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103efa:	8b 55 08             	mov    0x8(%ebp),%edx
80103efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f00:	01 c2                	add    %eax,%edx
80103f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f05:	8b 40 04             	mov    0x4(%eax),%eax
80103f08:	83 ec 04             	sub    $0x4,%esp
80103f0b:	52                   	push   %edx
80103f0c:	ff 75 f4             	push   -0xc(%ebp)
80103f0f:	50                   	push   %eax
80103f10:	e8 57 46 00 00       	call   8010856c <allocuvm>
80103f15:	83 c4 10             	add    $0x10,%esp
80103f18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1f:	75 3b                	jne    80103f5c <growproc+0x82>
      return -1;
80103f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f26:	eb 4f                	jmp    80103f77 <growproc+0x9d>
  } else if(n < 0){
80103f28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103f2c:	79 2e                	jns    80103f5c <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103f2e:	8b 55 08             	mov    0x8(%ebp),%edx
80103f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f34:	01 c2                	add    %eax,%edx
80103f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f39:	8b 40 04             	mov    0x4(%eax),%eax
80103f3c:	83 ec 04             	sub    $0x4,%esp
80103f3f:	52                   	push   %edx
80103f40:	ff 75 f4             	push   -0xc(%ebp)
80103f43:	50                   	push   %eax
80103f44:	e8 2c 47 00 00       	call   80108675 <deallocuvm>
80103f49:	83 c4 10             	add    $0x10,%esp
80103f4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f53:	75 07                	jne    80103f5c <growproc+0x82>
      return -1;
80103f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f5a:	eb 1b                	jmp    80103f77 <growproc+0x9d>
  }
  curproc->sz = sz;
80103f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f62:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f64:	83 ec 0c             	sub    $0xc,%esp
80103f67:	ff 75 f0             	push   -0x10(%ebp)
80103f6a:	e8 15 43 00 00       	call   80108284 <switchuvm>
80103f6f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f77:	c9                   	leave
80103f78:	c3                   	ret

80103f79 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f79:	f3 0f 1e fb          	endbr32
80103f7d:	55                   	push   %ebp
80103f7e:	89 e5                	mov    %esp,%ebp
80103f80:	57                   	push   %edi
80103f81:	56                   	push   %esi
80103f82:	53                   	push   %ebx
80103f83:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f86:	e8 1e fc ff ff       	call   80103ba9 <myproc>
80103f8b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0) {
80103f8e:	e8 43 fc ff ff       	call   80103bd6 <allocproc>
80103f93:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f9a:	75 0a                	jne    80103fa6 <fork+0x2d>
    return -1;
80103f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa1:	e9 ca 01 00 00       	jmp    80104170 <fork+0x1f7>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
80103fa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fa9:	8b 10                	mov    (%eax),%edx
80103fab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fae:	8b 40 04             	mov    0x4(%eax),%eax
80103fb1:	83 ec 08             	sub    $0x8,%esp
80103fb4:	52                   	push   %edx
80103fb5:	50                   	push   %eax
80103fb6:	e8 64 48 00 00       	call   8010881f <copyuvm>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fc1:	89 42 04             	mov    %eax,0x4(%edx)
80103fc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc7:	8b 40 04             	mov    0x4(%eax),%eax
80103fca:	85 c0                	test   %eax,%eax
80103fcc:	75 30                	jne    80103ffe <fork+0x85>
    kfree(np->kstack);
80103fce:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fd1:	8b 40 08             	mov    0x8(%eax),%eax
80103fd4:	83 ec 0c             	sub    $0xc,%esp
80103fd7:	50                   	push   %eax
80103fd8:	e8 17 e8 ff ff       	call   801027f4 <kfree>
80103fdd:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fe0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff9:	e9 72 01 00 00       	jmp    80104170 <fork+0x1f7>
  }
  np->sz = curproc->sz;
80103ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104001:	8b 10                	mov    (%eax),%edx
80104003:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104006:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104008:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010400b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010400e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104011:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104014:	8b 48 18             	mov    0x18(%eax),%ecx
80104017:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010401a:	8b 40 18             	mov    0x18(%eax),%eax
8010401d:	89 c2                	mov    %eax,%edx
8010401f:	89 cb                	mov    %ecx,%ebx
80104021:	b8 13 00 00 00       	mov    $0x13,%eax
80104026:	89 d7                	mov    %edx,%edi
80104028:	89 de                	mov    %ebx,%esi
8010402a:	89 c1                	mov    %eax,%ecx
8010402c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010402e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104031:	8b 40 18             	mov    0x18(%eax),%eax
80104034:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
8010403b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104042:	eb 3b                	jmp    8010407f <fork+0x106>
    if (curproc->ofile[i])
80104044:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104047:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010404a:	83 c2 08             	add    $0x8,%edx
8010404d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104051:	85 c0                	test   %eax,%eax
80104053:	74 26                	je     8010407b <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104055:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104058:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010405b:	83 c2 08             	add    $0x8,%edx
8010405e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104062:	83 ec 0c             	sub    $0xc,%esp
80104065:	50                   	push   %eax
80104066:	e8 29 d0 ff ff       	call   80101094 <filedup>
8010406b:	83 c4 10             	add    $0x10,%esp
8010406e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104071:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104074:	83 c1 08             	add    $0x8,%ecx
80104077:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
8010407b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010407f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104083:	7e bf                	jle    80104044 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104085:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104088:	8b 40 68             	mov    0x68(%eax),%eax
8010408b:	83 ec 0c             	sub    $0xc,%esp
8010408e:	50                   	push   %eax
8010408f:	e8 aa d9 ff ff       	call   80101a3e <idup>
80104094:	83 c4 10             	add    $0x10,%esp
80104097:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010409a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010409d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801040a0:	8d 50 6c             	lea    0x6c(%eax),%edx
801040a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040a6:	83 c0 6c             	add    $0x6c,%eax
801040a9:	83 ec 04             	sub    $0x4,%esp
801040ac:	6a 10                	push   $0x10
801040ae:	52                   	push   %edx
801040af:	50                   	push   %eax
801040b0:	e8 42 17 00 00       	call   801057f7 <safestrcpy>
801040b5:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801040b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040bb:	8b 40 10             	mov    0x10(%eax),%eax
801040be:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801040c1:	83 ec 0c             	sub    $0xc,%esp
801040c4:	68 20 75 19 80       	push   $0x80197520
801040c9:	e8 7f 12 00 00       	call   8010534d <acquire>
801040ce:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801040d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040d4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // MLFQ용 kernel_pstat 등록
  int idx = np - ptable.proc;
801040db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040de:	2d 54 75 19 80       	sub    $0x80197554,%eax
801040e3:	c1 f8 02             	sar    $0x2,%eax
801040e6:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801040ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  kernel_pstat.inuse[idx] = 1;
801040ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801040f2:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
801040f9:	01 00 00 00 
  kernel_pstat.pid[idx] = np->pid;
801040fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104100:	8b 40 10             	mov    0x10(%eax),%eax
80104103:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80104106:	83 c2 40             	add    $0x40,%edx
80104109:	89 04 95 20 69 19 80 	mov    %eax,-0x7fe696e0(,%edx,4)
  kernel_pstat.priority[idx] = 3;
80104110:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104113:	83 e8 80             	sub    $0xffffff80,%eax
80104116:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
8010411d:	03 00 00 00 
  memset(kernel_pstat.ticks[idx], 0, sizeof(kernel_pstat.ticks[idx]));
80104121:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104124:	83 c0 40             	add    $0x40,%eax
80104127:	c1 e0 04             	shl    $0x4,%eax
8010412a:	05 20 69 19 80       	add    $0x80196920,%eax
8010412f:	83 ec 04             	sub    $0x4,%esp
80104132:	6a 10                	push   $0x10
80104134:	6a 00                	push   $0x0
80104136:	50                   	push   %eax
80104137:	e8 a0 14 00 00       	call   801055dc <memset>
8010413c:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[idx], 0, sizeof(kernel_pstat.wait_ticks[idx]));
8010413f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104142:	83 e8 80             	sub    $0xffffff80,%eax
80104145:	c1 e0 04             	shl    $0x4,%eax
80104148:	05 20 69 19 80       	add    $0x80196920,%eax
8010414d:	83 ec 04             	sub    $0x4,%esp
80104150:	6a 10                	push   $0x10
80104152:	6a 00                	push   $0x0
80104154:	50                   	push   %eax
80104155:	e8 82 14 00 00       	call   801055dc <memset>
8010415a:	83 c4 10             	add    $0x10,%esp

  // if (mycpu()->sched_policy > 0)
  //   enqueue(np, 3);

  release(&ptable.lock);
8010415d:	83 ec 0c             	sub    $0xc,%esp
80104160:	68 20 75 19 80       	push   $0x80197520
80104165:	e8 55 12 00 00       	call   801053bf <release>
8010416a:	83 c4 10             	add    $0x10,%esp

  return pid;
8010416d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104170:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104173:	5b                   	pop    %ebx
80104174:	5e                   	pop    %esi
80104175:	5f                   	pop    %edi
80104176:	5d                   	pop    %ebp
80104177:	c3                   	ret

80104178 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104178:	f3 0f 1e fb          	endbr32
8010417c:	55                   	push   %ebp
8010417d:	89 e5                	mov    %esp,%ebp
8010417f:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104182:	e8 22 fa ff ff       	call   80103ba9 <myproc>
80104187:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010418a:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
8010418f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104192:	75 0d                	jne    801041a1 <exit+0x29>
    panic("init exiting");
80104194:	83 ec 0c             	sub    $0xc,%esp
80104197:	68 a2 b2 10 80       	push   $0x8010b2a2
8010419c:	e8 24 c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801041a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801041a8:	eb 3f                	jmp    801041e9 <exit+0x71>
    if(curproc->ofile[fd]){
801041aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041b0:	83 c2 08             	add    $0x8,%edx
801041b3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041b7:	85 c0                	test   %eax,%eax
801041b9:	74 2a                	je     801041e5 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801041bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041c1:	83 c2 08             	add    $0x8,%edx
801041c4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041c8:	83 ec 0c             	sub    $0xc,%esp
801041cb:	50                   	push   %eax
801041cc:	e8 18 cf ff ff       	call   801010e9 <fileclose>
801041d1:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041da:	83 c2 08             	add    $0x8,%edx
801041dd:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041e4:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041e5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041e9:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041ed:	7e bb                	jle    801041aa <exit+0x32>
    }
  }

  begin_op();
801041ef:	e8 7d ef ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801041f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f7:	8b 40 68             	mov    0x68(%eax),%eax
801041fa:	83 ec 0c             	sub    $0xc,%esp
801041fd:	50                   	push   %eax
801041fe:	e8 e2 d9 ff ff       	call   80101be5 <iput>
80104203:	83 c4 10             	add    $0x10,%esp
  end_op();
80104206:	e8 f6 ef ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
8010420b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010420e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	68 20 75 19 80       	push   $0x80197520
8010421d:	e8 2b 11 00 00       	call   8010534d <acquire>
80104222:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104225:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104228:	8b 40 14             	mov    0x14(%eax),%eax
8010422b:	83 ec 0c             	sub    $0xc,%esp
8010422e:	50                   	push   %eax
8010422f:	e8 02 05 00 00       	call   80104736 <wakeup1>
80104234:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104237:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
8010423e:	eb 37                	jmp    80104277 <exit+0xff>
    if(p->parent == curproc){
80104240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104243:	8b 40 14             	mov    0x14(%eax),%eax
80104246:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104249:	75 28                	jne    80104273 <exit+0xfb>
      p->parent = initproc;
8010424b:	8b 15 7c e0 18 80    	mov    0x8018e07c,%edx
80104251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104254:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425a:	8b 40 0c             	mov    0xc(%eax),%eax
8010425d:	83 f8 05             	cmp    $0x5,%eax
80104260:	75 11                	jne    80104273 <exit+0xfb>
        wakeup1(initproc);
80104262:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
80104267:	83 ec 0c             	sub    $0xc,%esp
8010426a:	50                   	push   %eax
8010426b:	e8 c6 04 00 00       	call   80104736 <wakeup1>
80104270:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104273:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104277:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
8010427e:	72 c0                	jb     80104240 <exit+0xc8>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
80104280:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104283:	2d 54 75 19 80       	sub    $0x80197554,%eax
80104288:	c1 f8 02             	sar    $0x2,%eax
8010428b:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104291:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
80104294:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104297:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
8010429e:	00 00 00 00 
  int q;
  q = kernel_pstat.priority[i];
801042a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042a5:	83 e8 80             	sub    $0xffffff80,%eax
801042a8:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
801042af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (get_sched_policy() > 0)
801042b2:	e8 a7 08 00 00       	call   80104b5e <get_sched_policy>
801042b7:	85 c0                	test   %eax,%eax
801042b9:	7e 25                	jle    801042e0 <exit+0x168>
  {
    dequeue(q);
801042bb:	83 ec 0c             	sub    $0xc,%esp
801042be:	ff 75 e4             	push   -0x1c(%ebp)
801042c1:	e8 3e 09 00 00       	call   80104c04 <dequeue>
801042c6:	83 c4 10             	add    $0x10,%esp
    cprintf("[PROCESS EXIT] pid: %d\n", curproc->pid);
801042c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042cc:	8b 40 10             	mov    0x10(%eax),%eax
801042cf:	83 ec 08             	sub    $0x8,%esp
801042d2:	50                   	push   %eax
801042d3:	68 af b2 10 80       	push   $0x8010b2af
801042d8:	e8 2f c1 ff ff       	call   8010040c <cprintf>
801042dd:	83 c4 10             	add    $0x10,%esp
  }
  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801042e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042e3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801042ea:	e8 57 02 00 00       	call   80104546 <sched>
  panic("zombie exit");
801042ef:	83 ec 0c             	sub    $0xc,%esp
801042f2:	68 c7 b2 10 80       	push   $0x8010b2c7
801042f7:	e8 c9 c2 ff ff       	call   801005c5 <panic>

801042fc <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801042fc:	f3 0f 1e fb          	endbr32
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104306:	e8 9e f8 ff ff       	call   80103ba9 <myproc>
8010430b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010430e:	83 ec 0c             	sub    $0xc,%esp
80104311:	68 20 75 19 80       	push   $0x80197520
80104316:	e8 32 10 00 00       	call   8010534d <acquire>
8010431b:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010431e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104325:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
8010432c:	e9 a1 00 00 00       	jmp    801043d2 <wait+0xd6>
      if(p->parent != curproc)
80104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104334:	8b 40 14             	mov    0x14(%eax),%eax
80104337:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010433a:	0f 85 8d 00 00 00    	jne    801043cd <wait+0xd1>
        continue;
      havekids = 1;
80104340:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	8b 40 0c             	mov    0xc(%eax),%eax
8010434d:	83 f8 05             	cmp    $0x5,%eax
80104350:	75 7c                	jne    801043ce <wait+0xd2>
        // Found one.
        pid = p->pid;
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	8b 40 10             	mov    0x10(%eax),%eax
80104358:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	8b 40 08             	mov    0x8(%eax),%eax
80104361:	83 ec 0c             	sub    $0xc,%esp
80104364:	50                   	push   %eax
80104365:	e8 8a e4 ff ff       	call   801027f4 <kfree>
8010436a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010436d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104370:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437a:	8b 40 04             	mov    0x4(%eax),%eax
8010437d:	83 ec 0c             	sub    $0xc,%esp
80104380:	50                   	push   %eax
80104381:	e8 b7 43 00 00       	call   8010873d <freevm>
80104386:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010439d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801043a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801043ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801043b8:	83 ec 0c             	sub    $0xc,%esp
801043bb:	68 20 75 19 80       	push   $0x80197520
801043c0:	e8 fa 0f 00 00       	call   801053bf <release>
801043c5:	83 c4 10             	add    $0x10,%esp
        return pid;
801043c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043cb:	eb 51                	jmp    8010441e <wait+0x122>
        continue;
801043cd:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043ce:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043d2:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
801043d9:	0f 82 52 ff ff ff    	jb     80104331 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801043df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801043e3:	74 0a                	je     801043ef <wait+0xf3>
801043e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e8:	8b 40 24             	mov    0x24(%eax),%eax
801043eb:	85 c0                	test   %eax,%eax
801043ed:	74 17                	je     80104406 <wait+0x10a>
      release(&ptable.lock);
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	68 20 75 19 80       	push   $0x80197520
801043f7:	e8 c3 0f 00 00       	call   801053bf <release>
801043fc:	83 c4 10             	add    $0x10,%esp
      return -1;
801043ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104404:	eb 18                	jmp    8010441e <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104406:	83 ec 08             	sub    $0x8,%esp
80104409:	68 20 75 19 80       	push   $0x80197520
8010440e:	ff 75 ec             	push   -0x14(%ebp)
80104411:	e8 75 02 00 00       	call   8010468b <sleep>
80104416:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104419:	e9 00 ff ff ff       	jmp    8010431e <wait+0x22>
  }
}
8010441e:	c9                   	leave
8010441f:	c3                   	ret

80104420 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104420:	f3 0f 1e fb          	endbr32
80104424:	55                   	push   %ebp
80104425:	89 e5                	mov    %esp,%ebp
80104427:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010442a:	e8 fe f6 ff ff       	call   80103b2d <mycpu>
8010442f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104435:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010443c:	00 00 00 

  for(;;){
    sti();
8010443f:	e8 a1 f6 ff ff       	call   80103ae5 <sti>
    acquire(&ptable.lock);
80104444:	83 ec 0c             	sub    $0xc,%esp
80104447:	68 20 75 19 80       	push   $0x80197520
8010444c:	e8 fc 0e 00 00       	call   8010534d <acquire>
80104451:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 0) {
80104454:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104457:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010445d:	85 c0                	test   %eax,%eax
8010445f:	75 75                	jne    801044d6 <scheduler+0xb6>
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104461:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
80104468:	eb 61                	jmp    801044cb <scheduler+0xab>
        if(p->state != RUNNABLE)
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 0c             	mov    0xc(%eax),%eax
80104470:	83 f8 03             	cmp    $0x3,%eax
80104473:	75 51                	jne    801044c6 <scheduler+0xa6>
          continue;
        c->proc = p;
80104475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104478:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104481:	83 ec 0c             	sub    $0xc,%esp
80104484:	ff 75 f4             	push   -0xc(%ebp)
80104487:	e8 f8 3d 00 00       	call   80108284 <switchuvm>
8010448c:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
8010448f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104492:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&(c->scheduler), p->context);
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010449f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044a2:	83 c2 04             	add    $0x4,%edx
801044a5:	83 ec 08             	sub    $0x8,%esp
801044a8:	50                   	push   %eax
801044a9:	52                   	push   %edx
801044aa:	e8 c1 13 00 00       	call   80105870 <swtch>
801044af:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801044b2:	e8 b0 3d 00 00       	call   80108267 <switchkvm>
        c->proc = 0;
801044b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ba:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801044c1:	00 00 00 
801044c4:	eb 01                	jmp    801044c7 <scheduler+0xa7>
          continue;
801044c6:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044c7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044cb:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
801044d2:	72 96                	jb     8010446a <scheduler+0x4a>
801044d4:	eb 5b                	jmp    80104531 <scheduler+0x111>
      //   if(p->state == RUNNABLE && p != c->proc){
      //     int i = p - ptable.proc;
      //     kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
      //   }
      // }
    } else if (c->sched_policy == 1) {
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044df:	83 f8 01             	cmp    $0x1,%eax
801044e2:	75 11                	jne    801044f5 <scheduler+0xd5>
      run_mlfq(1, 1);
801044e4:	83 ec 08             	sub    $0x8,%esp
801044e7:	6a 01                	push   $0x1
801044e9:	6a 01                	push   $0x1
801044eb:	e8 73 0b 00 00       	call   80105063 <run_mlfq>
801044f0:	83 c4 10             	add    $0x10,%esp
801044f3:	eb 3c                	jmp    80104531 <scheduler+0x111>
    } else if (c->sched_policy == 2) {
801044f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044fe:	83 f8 02             	cmp    $0x2,%eax
80104501:	75 11                	jne    80104514 <scheduler+0xf4>
      run_mlfq(0, 1);
80104503:	83 ec 08             	sub    $0x8,%esp
80104506:	6a 01                	push   $0x1
80104508:	6a 00                	push   $0x0
8010450a:	e8 54 0b 00 00       	call   80105063 <run_mlfq>
8010450f:	83 c4 10             	add    $0x10,%esp
80104512:	eb 1d                	jmp    80104531 <scheduler+0x111>
    } else if (c->sched_policy == 3) {
80104514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104517:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010451d:	83 f8 03             	cmp    $0x3,%eax
80104520:	75 0f                	jne    80104531 <scheduler+0x111>
      run_mlfq(1, 0);
80104522:	83 ec 08             	sub    $0x8,%esp
80104525:	6a 00                	push   $0x0
80104527:	6a 01                	push   $0x1
80104529:	e8 35 0b 00 00       	call   80105063 <run_mlfq>
8010452e:	83 c4 10             	add    $0x10,%esp
    }
    release(&ptable.lock);
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	68 20 75 19 80       	push   $0x80197520
80104539:	e8 81 0e 00 00       	call   801053bf <release>
8010453e:	83 c4 10             	add    $0x10,%esp
    sti();
80104541:	e9 f9 fe ff ff       	jmp    8010443f <scheduler+0x1f>

80104546 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104546:	f3 0f 1e fb          	endbr32
8010454a:	55                   	push   %ebp
8010454b:	89 e5                	mov    %esp,%ebp
8010454d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104550:	e8 54 f6 ff ff       	call   80103ba9 <myproc>
80104555:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104558:	83 ec 0c             	sub    $0xc,%esp
8010455b:	68 20 75 19 80       	push   $0x80197520
80104560:	e8 2f 0f 00 00       	call   80105494 <holding>
80104565:	83 c4 10             	add    $0x10,%esp
80104568:	85 c0                	test   %eax,%eax
8010456a:	75 0d                	jne    80104579 <sched+0x33>
    panic("sched ptable.lock");
8010456c:	83 ec 0c             	sub    $0xc,%esp
8010456f:	68 d3 b2 10 80       	push   $0x8010b2d3
80104574:	e8 4c c0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104579:	e8 af f5 ff ff       	call   80103b2d <mycpu>
8010457e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104584:	83 f8 01             	cmp    $0x1,%eax
80104587:	74 0d                	je     80104596 <sched+0x50>
    panic("sched locks");
80104589:	83 ec 0c             	sub    $0xc,%esp
8010458c:	68 e5 b2 10 80       	push   $0x8010b2e5
80104591:	e8 2f c0 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 0c             	mov    0xc(%eax),%eax
8010459c:	83 f8 04             	cmp    $0x4,%eax
8010459f:	75 0d                	jne    801045ae <sched+0x68>
    panic("sched running");
801045a1:	83 ec 0c             	sub    $0xc,%esp
801045a4:	68 f1 b2 10 80       	push   $0x8010b2f1
801045a9:	e8 17 c0 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801045ae:	e8 22 f5 ff ff       	call   80103ad5 <readeflags>
801045b3:	25 00 02 00 00       	and    $0x200,%eax
801045b8:	85 c0                	test   %eax,%eax
801045ba:	74 0d                	je     801045c9 <sched+0x83>
    panic("sched interruptible");
801045bc:	83 ec 0c             	sub    $0xc,%esp
801045bf:	68 ff b2 10 80       	push   $0x8010b2ff
801045c4:	e8 fc bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801045c9:	e8 5f f5 ff ff       	call   80103b2d <mycpu>
801045ce:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045d7:	e8 51 f5 ff ff       	call   80103b2d <mycpu>
801045dc:	8b 40 04             	mov    0x4(%eax),%eax
801045df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e2:	83 c2 1c             	add    $0x1c,%edx
801045e5:	83 ec 08             	sub    $0x8,%esp
801045e8:	50                   	push   %eax
801045e9:	52                   	push   %edx
801045ea:	e8 81 12 00 00       	call   80105870 <swtch>
801045ef:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801045f2:	e8 36 f5 ff ff       	call   80103b2d <mycpu>
801045f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045fa:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104600:	90                   	nop
80104601:	c9                   	leave
80104602:	c3                   	ret

80104603 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104603:	f3 0f 1e fb          	endbr32
80104607:	55                   	push   %ebp
80104608:	89 e5                	mov    %esp,%ebp
8010460a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010460d:	83 ec 0c             	sub    $0xc,%esp
80104610:	68 20 75 19 80       	push   $0x80197520
80104615:	e8 33 0d 00 00       	call   8010534d <acquire>
8010461a:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010461d:	e8 87 f5 ff ff       	call   80103ba9 <myproc>
80104622:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104629:	e8 18 ff ff ff       	call   80104546 <sched>
  release(&ptable.lock);
8010462e:	83 ec 0c             	sub    $0xc,%esp
80104631:	68 20 75 19 80       	push   $0x80197520
80104636:	e8 84 0d 00 00       	call   801053bf <release>
8010463b:	83 c4 10             	add    $0x10,%esp
}
8010463e:	90                   	nop
8010463f:	c9                   	leave
80104640:	c3                   	ret

80104641 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104641:	f3 0f 1e fb          	endbr32
80104645:	55                   	push   %ebp
80104646:	89 e5                	mov    %esp,%ebp
80104648:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010464b:	83 ec 0c             	sub    $0xc,%esp
8010464e:	68 20 75 19 80       	push   $0x80197520
80104653:	e8 67 0d 00 00       	call   801053bf <release>
80104658:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010465b:	a1 04 00 11 80       	mov    0x80110004,%eax
80104660:	85 c0                	test   %eax,%eax
80104662:	74 24                	je     80104688 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104664:	c7 05 04 00 11 80 00 	movl   $0x0,0x80110004
8010466b:	00 00 00 
    iinit(ROOTDEV);
8010466e:	83 ec 0c             	sub    $0xc,%esp
80104671:	6a 01                	push   $0x1
80104673:	e8 7e d0 ff ff       	call   801016f6 <iinit>
80104678:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010467b:	83 ec 0c             	sub    $0xc,%esp
8010467e:	6a 01                	push   $0x1
80104680:	e8 b9 e8 ff ff       	call   80102f3e <initlog>
80104685:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104688:	90                   	nop
80104689:	c9                   	leave
8010468a:	c3                   	ret

8010468b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010468b:	f3 0f 1e fb          	endbr32
8010468f:	55                   	push   %ebp
80104690:	89 e5                	mov    %esp,%ebp
80104692:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104695:	e8 0f f5 ff ff       	call   80103ba9 <myproc>
8010469a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010469d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046a1:	75 0d                	jne    801046b0 <sleep+0x25>
    panic("sleep");
801046a3:	83 ec 0c             	sub    $0xc,%esp
801046a6:	68 13 b3 10 80       	push   $0x8010b313
801046ab:	e8 15 bf ff ff       	call   801005c5 <panic>

  if(lk == 0)
801046b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046b4:	75 0d                	jne    801046c3 <sleep+0x38>
    panic("sleep without lk");
801046b6:	83 ec 0c             	sub    $0xc,%esp
801046b9:	68 19 b3 10 80       	push   $0x8010b319
801046be:	e8 02 bf ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801046c3:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
801046ca:	74 1e                	je     801046ea <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801046cc:	83 ec 0c             	sub    $0xc,%esp
801046cf:	68 20 75 19 80       	push   $0x80197520
801046d4:	e8 74 0c 00 00       	call   8010534d <acquire>
801046d9:	83 c4 10             	add    $0x10,%esp
    release(lk);
801046dc:	83 ec 0c             	sub    $0xc,%esp
801046df:	ff 75 0c             	push   0xc(%ebp)
801046e2:	e8 d8 0c 00 00       	call   801053bf <release>
801046e7:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801046ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ed:	8b 55 08             	mov    0x8(%ebp),%edx
801046f0:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801046fd:	e8 44 fe ff ff       	call   80104546 <sched>

  // Tidy up.
  p->chan = 0;
80104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104705:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010470c:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
80104713:	74 1e                	je     80104733 <sleep+0xa8>
    release(&ptable.lock);
80104715:	83 ec 0c             	sub    $0xc,%esp
80104718:	68 20 75 19 80       	push   $0x80197520
8010471d:	e8 9d 0c 00 00       	call   801053bf <release>
80104722:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	ff 75 0c             	push   0xc(%ebp)
8010472b:	e8 1d 0c 00 00       	call   8010534d <acquire>
80104730:	83 c4 10             	add    $0x10,%esp
  }
}
80104733:	90                   	nop
80104734:	c9                   	leave
80104735:	c3                   	ret

80104736 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104736:	f3 0f 1e fb          	endbr32
8010473a:	55                   	push   %ebp
8010473b:	89 e5                	mov    %esp,%ebp
8010473d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104740:	c7 45 fc 54 75 19 80 	movl   $0x80197554,-0x4(%ebp)
80104747:	eb 24                	jmp    8010476d <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104749:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010474c:	8b 40 0c             	mov    0xc(%eax),%eax
8010474f:	83 f8 02             	cmp    $0x2,%eax
80104752:	75 15                	jne    80104769 <wakeup1+0x33>
80104754:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104757:	8b 40 20             	mov    0x20(%eax),%eax
8010475a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010475d:	75 0a                	jne    80104769 <wakeup1+0x33>
      p->state = RUNNABLE;
8010475f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104762:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104769:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010476d:	81 7d fc 54 94 19 80 	cmpl   $0x80199454,-0x4(%ebp)
80104774:	72 d3                	jb     80104749 <wakeup1+0x13>
}
80104776:	90                   	nop
80104777:	90                   	nop
80104778:	c9                   	leave
80104779:	c3                   	ret

8010477a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010477a:	f3 0f 1e fb          	endbr32
8010477e:	55                   	push   %ebp
8010477f:	89 e5                	mov    %esp,%ebp
80104781:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104784:	83 ec 0c             	sub    $0xc,%esp
80104787:	68 20 75 19 80       	push   $0x80197520
8010478c:	e8 bc 0b 00 00       	call   8010534d <acquire>
80104791:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104794:	83 ec 0c             	sub    $0xc,%esp
80104797:	ff 75 08             	push   0x8(%ebp)
8010479a:	e8 97 ff ff ff       	call   80104736 <wakeup1>
8010479f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047a2:	83 ec 0c             	sub    $0xc,%esp
801047a5:	68 20 75 19 80       	push   $0x80197520
801047aa:	e8 10 0c 00 00       	call   801053bf <release>
801047af:	83 c4 10             	add    $0x10,%esp
}
801047b2:	90                   	nop
801047b3:	c9                   	leave
801047b4:	c3                   	ret

801047b5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801047b5:	f3 0f 1e fb          	endbr32
801047b9:	55                   	push   %ebp
801047ba:	89 e5                	mov    %esp,%ebp
801047bc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801047bf:	83 ec 0c             	sub    $0xc,%esp
801047c2:	68 20 75 19 80       	push   $0x80197520
801047c7:	e8 81 0b 00 00       	call   8010534d <acquire>
801047cc:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047cf:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
801047d6:	eb 45                	jmp    8010481d <kill+0x68>
    if(p->pid == pid){
801047d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047db:	8b 40 10             	mov    0x10(%eax),%eax
801047de:	39 45 08             	cmp    %eax,0x8(%ebp)
801047e1:	75 36                	jne    80104819 <kill+0x64>
      p->killed = 1;
801047e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f0:	8b 40 0c             	mov    0xc(%eax),%eax
801047f3:	83 f8 02             	cmp    $0x2,%eax
801047f6:	75 0a                	jne    80104802 <kill+0x4d>
        p->state = RUNNABLE;
801047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104802:	83 ec 0c             	sub    $0xc,%esp
80104805:	68 20 75 19 80       	push   $0x80197520
8010480a:	e8 b0 0b 00 00       	call   801053bf <release>
8010480f:	83 c4 10             	add    $0x10,%esp
      return 0;
80104812:	b8 00 00 00 00       	mov    $0x0,%eax
80104817:	eb 22                	jmp    8010483b <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104819:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010481d:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
80104824:	72 b2                	jb     801047d8 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104826:	83 ec 0c             	sub    $0xc,%esp
80104829:	68 20 75 19 80       	push   $0x80197520
8010482e:	e8 8c 0b 00 00       	call   801053bf <release>
80104833:	83 c4 10             	add    $0x10,%esp
  return -1;
80104836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010483b:	c9                   	leave
8010483c:	c3                   	ret

8010483d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010483d:	f3 0f 1e fb          	endbr32
80104841:	55                   	push   %ebp
80104842:	89 e5                	mov    %esp,%ebp
80104844:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104847:	c7 45 f0 54 75 19 80 	movl   $0x80197554,-0x10(%ebp)
8010484e:	e9 d7 00 00 00       	jmp    8010492a <procdump+0xed>
    if(p->state == UNUSED)
80104853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104856:	8b 40 0c             	mov    0xc(%eax),%eax
80104859:	85 c0                	test   %eax,%eax
8010485b:	0f 84 c4 00 00 00    	je     80104925 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104861:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104864:	8b 40 0c             	mov    0xc(%eax),%eax
80104867:	83 f8 05             	cmp    $0x5,%eax
8010486a:	77 23                	ja     8010488f <procdump+0x52>
8010486c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486f:	8b 40 0c             	mov    0xc(%eax),%eax
80104872:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
80104879:	85 c0                	test   %eax,%eax
8010487b:	74 12                	je     8010488f <procdump+0x52>
      state = states[p->state];
8010487d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104880:	8b 40 0c             	mov    0xc(%eax),%eax
80104883:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
8010488a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010488d:	eb 07                	jmp    80104896 <procdump+0x59>
    else
      state = "???";
8010488f:	c7 45 ec 2a b3 10 80 	movl   $0x8010b32a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104899:	8d 50 6c             	lea    0x6c(%eax),%edx
8010489c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489f:	8b 40 10             	mov    0x10(%eax),%eax
801048a2:	52                   	push   %edx
801048a3:	ff 75 ec             	push   -0x14(%ebp)
801048a6:	50                   	push   %eax
801048a7:	68 2e b3 10 80       	push   $0x8010b32e
801048ac:	e8 5b bb ff ff       	call   8010040c <cprintf>
801048b1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801048b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b7:	8b 40 0c             	mov    0xc(%eax),%eax
801048ba:	83 f8 02             	cmp    $0x2,%eax
801048bd:	75 54                	jne    80104913 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801048bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c2:	8b 40 1c             	mov    0x1c(%eax),%eax
801048c5:	8b 40 0c             	mov    0xc(%eax),%eax
801048c8:	83 c0 08             	add    $0x8,%eax
801048cb:	89 c2                	mov    %eax,%edx
801048cd:	83 ec 08             	sub    $0x8,%esp
801048d0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801048d3:	50                   	push   %eax
801048d4:	52                   	push   %edx
801048d5:	e8 3b 0b 00 00       	call   80105415 <getcallerpcs>
801048da:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048e4:	eb 1c                	jmp    80104902 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048ed:	83 ec 08             	sub    $0x8,%esp
801048f0:	50                   	push   %eax
801048f1:	68 37 b3 10 80       	push   $0x8010b337
801048f6:	e8 11 bb ff ff       	call   8010040c <cprintf>
801048fb:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104902:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104906:	7f 0b                	jg     80104913 <procdump+0xd6>
80104908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010490f:	85 c0                	test   %eax,%eax
80104911:	75 d3                	jne    801048e6 <procdump+0xa9>
    }
    cprintf("\n");
80104913:	83 ec 0c             	sub    $0xc,%esp
80104916:	68 3b b3 10 80       	push   $0x8010b33b
8010491b:	e8 ec ba ff ff       	call   8010040c <cprintf>
80104920:	83 c4 10             	add    $0x10,%esp
80104923:	eb 01                	jmp    80104926 <procdump+0xe9>
      continue;
80104925:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104926:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010492a:	81 7d f0 54 94 19 80 	cmpl   $0x80199454,-0x10(%ebp)
80104931:	0f 82 1c ff ff ff    	jb     80104853 <procdump+0x16>
  }
}
80104937:	90                   	nop
80104938:	90                   	nop
80104939:	c9                   	leave
8010493a:	c3                   	ret

8010493b <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
8010493b:	f3 0f 1e fb          	endbr32
8010493f:	55                   	push   %ebp
80104940:	89 e5                	mov    %esp,%ebp
80104942:	53                   	push   %ebx
80104943:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 20 75 19 80       	push   $0x80197520
8010494e:	e8 fa 09 00 00       	call   8010534d <acquire>
80104953:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010495d:	e9 e6 00 00 00       	jmp    80104a48 <getpinfo+0x10d>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	8b 0c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ecx
8010496c:	8b 45 08             	mov    0x8(%ebp),%eax
8010496f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104972:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104978:	83 c0 40             	add    $0x40,%eax
8010497b:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104982:	8b 45 08             	mov    0x8(%ebp),%eax
80104985:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104988:	83 c1 40             	add    $0x40,%ecx
8010498b:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
8010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104991:	83 e8 80             	sub    $0xffffff80,%eax
80104994:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049a1:	83 e9 80             	sub    $0xffffff80,%ecx
801049a4:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
801049ad:	05 60 75 19 80       	add    $0x80197560,%eax
801049b2:	8b 00                	mov    (%eax),%eax
801049b4:	89 c1                	mov    %eax,%ecx
801049b6:	8b 45 08             	mov    0x8(%ebp),%eax
801049b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049bc:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801049c2:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801049c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049cc:	eb 70                	jmp    80104a3e <getpinfo+0x103>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801049ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049db:	01 d0                	add    %edx,%eax
801049dd:	05 00 01 00 00       	add    $0x100,%eax
801049e2:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
801049e9:	8b 45 08             	mov    0x8(%ebp),%eax
801049ec:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049ef:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801049f6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801049f9:	01 d9                	add    %ebx,%ecx
801049fb:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a01:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
80104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a11:	01 d0                	add    %edx,%eax
80104a13:	05 00 02 00 00       	add    $0x200,%eax
80104a18:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a22:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a25:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a2c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a2f:	01 d9                	add    %ebx,%ecx
80104a31:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a37:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104a3a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a3e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a42:	7e 8a                	jle    801049ce <getpinfo+0x93>
  for (int i = 0; i < NPROC; i++) {
80104a44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a48:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a4c:	0f 8e 10 ff ff ff    	jle    80104962 <getpinfo+0x27>
    }
  }
  release(&ptable.lock);
80104a52:	83 ec 0c             	sub    $0xc,%esp
80104a55:	68 20 75 19 80       	push   $0x80197520
80104a5a:	e8 60 09 00 00       	call   801053bf <release>
80104a5f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a6a:	c9                   	leave
80104a6b:	c3                   	ret

80104a6c <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
80104a6c:	f3 0f 1e fb          	endbr32
80104a70:	55                   	push   %ebp
80104a71:	89 e5                	mov    %esp,%ebp
80104a73:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a76:	83 ec 0c             	sub    $0xc,%esp
80104a79:	68 20 75 19 80       	push   $0x80197520
80104a7e:	e8 ca 08 00 00       	call   8010534d <acquire>
80104a83:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a8d:	eb 6f                	jmp    80104afe <mlfq_enqueue_all_runnable+0x92>
    if (!kernel_pstat.inuse[i]) continue;
80104a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a92:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104a99:	85 c0                	test   %eax,%eax
80104a9b:	74 5c                	je     80104af9 <mlfq_enqueue_all_runnable+0x8d>
    struct proc *p = &ptable.proc[i];
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104aa3:	83 c0 30             	add    $0x30,%eax
80104aa6:	05 20 75 19 80       	add    $0x80197520,%eax
80104aab:	83 c0 04             	add    $0x4,%eax
80104aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE) {
80104ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab7:	83 f8 03             	cmp    $0x3,%eax
80104aba:	75 3e                	jne    80104afa <mlfq_enqueue_all_runnable+0x8e>
      int q = kernel_pstat.priority[i];
80104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abf:	83 e8 80             	sub    $0xffffff80,%eax
80104ac2:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
80104acc:	83 ec 08             	sub    $0x8,%esp
80104acf:	ff 75 ec             	push   -0x14(%ebp)
80104ad2:	ff 75 f0             	push   -0x10(%ebp)
80104ad5:	e8 ab 00 00 00       	call   80104b85 <enqueue>
80104ada:	83 c4 10             	add    $0x10,%esp
      cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
80104add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ae0:	8b 40 10             	mov    0x10(%eax),%eax
80104ae3:	83 ec 04             	sub    $0x4,%esp
80104ae6:	ff 75 ec             	push   -0x14(%ebp)
80104ae9:	50                   	push   %eax
80104aea:	68 3d b3 10 80       	push   $0x8010b33d
80104aef:	e8 18 b9 ff ff       	call   8010040c <cprintf>
80104af4:	83 c4 10             	add    $0x10,%esp
80104af7:	eb 01                	jmp    80104afa <mlfq_enqueue_all_runnable+0x8e>
    if (!kernel_pstat.inuse[i]) continue;
80104af9:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104afa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104afe:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104b02:	7e 8b                	jle    80104a8f <mlfq_enqueue_all_runnable+0x23>
    }
  }
  release(&ptable.lock);
80104b04:	83 ec 0c             	sub    $0xc,%esp
80104b07:	68 20 75 19 80       	push   $0x80197520
80104b0c:	e8 ae 08 00 00       	call   801053bf <release>
80104b11:	83 c4 10             	add    $0x10,%esp
}
80104b14:	90                   	nop
80104b15:	c9                   	leave
80104b16:	c3                   	ret

80104b17 <set_sched_policy>:

int
set_sched_policy(int policy)
{
80104b17:	f3 0f 1e fb          	endbr32
80104b1b:	55                   	push   %ebp
80104b1c:	89 e5                	mov    %esp,%ebp
80104b1e:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104b21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b25:	78 06                	js     80104b2d <set_sched_policy+0x16>
80104b27:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104b2b:	7e 07                	jle    80104b34 <set_sched_policy+0x1d>
    return -1;
80104b2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b32:	eb 28                	jmp    80104b5c <set_sched_policy+0x45>

  pushcli(); 
80104b34:	e8 90 09 00 00       	call   801054c9 <pushcli>
  mycpu()->sched_policy = policy;
80104b39:	e8 ef ef ff ff       	call   80103b2d <mycpu>
80104b3e:	8b 55 08             	mov    0x8(%ebp),%edx
80104b41:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104b47:	e8 ce 09 00 00       	call   8010551a <popcli>

  if (policy > 0)
80104b4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b50:	7e 05                	jle    80104b57 <set_sched_policy+0x40>
  mlfq_enqueue_all_runnable();
80104b52:	e8 15 ff ff ff       	call   80104a6c <mlfq_enqueue_all_runnable>

  return 0;
80104b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b5c:	c9                   	leave
80104b5d:	c3                   	ret

80104b5e <get_sched_policy>:
int
get_sched_policy(void)
{
80104b5e:	f3 0f 1e fb          	endbr32
80104b62:	55                   	push   %ebp
80104b63:	89 e5                	mov    %esp,%ebp
80104b65:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
80104b68:	e8 5c 09 00 00       	call   801054c9 <pushcli>
  int policy = mycpu()->sched_policy;
80104b6d:	e8 bb ef ff ff       	call   80103b2d <mycpu>
80104b72:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104b7b:	e8 9a 09 00 00       	call   8010551a <popcli>
  return policy;
80104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b83:	c9                   	leave
80104b84:	c3                   	ret

80104b85 <enqueue>:
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void
enqueue(struct proc *p, int level) {
80104b85:	f3 0f 1e fb          	endbr32
80104b89:	55                   	push   %ebp
80104b8a:	89 e5                	mov    %esp,%ebp
80104b8c:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++)
80104b8f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104b96:	eb 1d                	jmp    80104bb5 <enqueue+0x30>
    if (mlfq_queues[level][i] == p) return;
80104b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9b:	c1 e0 06             	shl    $0x6,%eax
80104b9e:	89 c2                	mov    %eax,%edx
80104ba0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba3:	01 d0                	add    %edx,%eax
80104ba5:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104bac:	39 45 08             	cmp    %eax,0x8(%ebp)
80104baf:	74 50                	je     80104c01 <enqueue+0x7c>
  for (int i = 0; i < NPROC; i++)
80104bb1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bb5:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104bb9:	7e dd                	jle    80104b98 <enqueue+0x13>
  for (int i = 0; i < NPROC; i++)
80104bbb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bc2:	eb 35                	jmp    80104bf9 <enqueue+0x74>
    if (mlfq_queues[level][i] == 0) {
80104bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc7:	c1 e0 06             	shl    $0x6,%eax
80104bca:	89 c2                	mov    %eax,%edx
80104bcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bcf:	01 d0                	add    %edx,%eax
80104bd1:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104bd8:	85 c0                	test   %eax,%eax
80104bda:	75 19                	jne    80104bf5 <enqueue+0x70>
      mlfq_queues[level][i] = p;
80104bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bdf:	c1 e0 06             	shl    $0x6,%eax
80104be2:	89 c2                	mov    %eax,%edx
80104be4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104be7:	01 c2                	add    %eax,%edx
80104be9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bec:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      return;
80104bf3:	eb 0d                	jmp    80104c02 <enqueue+0x7d>
  for (int i = 0; i < NPROC; i++)
80104bf5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bf9:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104bfd:	7e c5                	jle    80104bc4 <enqueue+0x3f>
80104bff:	eb 01                	jmp    80104c02 <enqueue+0x7d>
    if (mlfq_queues[level][i] == p) return;
80104c01:	90                   	nop
    }
}
80104c02:	c9                   	leave
80104c03:	c3                   	ret

80104c04 <dequeue>:

struct proc*
dequeue(int level) {
80104c04:	f3 0f 1e fb          	endbr32
80104c08:	55                   	push   %ebp
80104c09:	89 e5                	mov    %esp,%ebp
80104c0b:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
80104c0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for (int i = 0; i < NPROC; i++) {
80104c15:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c1c:	e9 81 00 00 00       	jmp    80104ca2 <dequeue+0x9e>
    if (mlfq_queues[level][i]) {
80104c21:	8b 45 08             	mov    0x8(%ebp),%eax
80104c24:	c1 e0 06             	shl    $0x6,%eax
80104c27:	89 c2                	mov    %eax,%edx
80104c29:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c2c:	01 d0                	add    %edx,%eax
80104c2e:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c35:	85 c0                	test   %eax,%eax
80104c37:	74 65                	je     80104c9e <dequeue+0x9a>
      p = mlfq_queues[level][i];
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	c1 e0 06             	shl    $0x6,%eax
80104c3f:	89 c2                	mov    %eax,%edx
80104c41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c44:	01 d0                	add    %edx,%eax
80104c46:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c4d:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104c50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c56:	eb 2d                	jmp    80104c85 <dequeue+0x81>
        mlfq_queues[level][j] = mlfq_queues[level][j+1];
80104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5b:	8d 50 01             	lea    0x1(%eax),%edx
80104c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c61:	c1 e0 06             	shl    $0x6,%eax
80104c64:	01 d0                	add    %edx,%eax
80104c66:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80104c70:	89 d1                	mov    %edx,%ecx
80104c72:	c1 e1 06             	shl    $0x6,%ecx
80104c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c78:	01 ca                	add    %ecx,%edx
80104c7a:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104c81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c85:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104c89:	7e cd                	jle    80104c58 <dequeue+0x54>
      mlfq_queues[level][NPROC - 1] = 0;
80104c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8e:	c1 e0 08             	shl    $0x8,%eax
80104c91:	05 1c 66 19 80       	add    $0x8019661c,%eax
80104c96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      break;
80104c9c:	eb 0e                	jmp    80104cac <dequeue+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104c9e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ca2:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104ca6:	0f 8e 75 ff ff ff    	jle    80104c21 <dequeue+0x1d>
    }
  }
  return p;
80104cac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104caf:	c9                   	leave
80104cb0:	c3                   	ret

80104cb1 <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104cb1:	f3 0f 1e fb          	endbr32
80104cb5:	55                   	push   %ebp
80104cb6:	89 e5                	mov    %esp,%ebp
80104cb8:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104cbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cc2:	e9 da 01 00 00       	jmp    80104ea1 <apply_priority_boosting+0x1f0>
    if (!kernel_pstat.inuse[i]) continue;
80104cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cca:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104cd1:	85 c0                	test   %eax,%eax
80104cd3:	0f 84 c3 01 00 00    	je     80104e9c <apply_priority_boosting+0x1eb>
    int q = kernel_pstat.priority[i];
80104cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdc:	83 e8 80             	sub    $0xffffff80,%eax
80104cdf:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104ce6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf6:	01 d0                	add    %edx,%eax
80104cf8:	05 00 02 00 00       	add    $0x200,%eax
80104cfd:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d04:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 2 && waited >= 160) {
80104d07:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104d0b:	75 70                	jne    80104d7d <apply_priority_boosting+0xcc>
80104d0d:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104d14:	7e 67                	jle    80104d7d <apply_priority_boosting+0xcc>
      kernel_pstat.priority[i] = 3;
80104d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d19:	83 e8 80             	sub    $0xffffff80,%eax
80104d1c:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80104d23:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2a:	c1 e0 04             	shl    $0x4,%eax
80104d2d:	05 28 71 19 80       	add    $0x80197128,%eax
80104d32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3b:	83 c0 40             	add    $0x40,%eax
80104d3e:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d45:	83 ec 04             	sub    $0x4,%esp
80104d48:	ff 75 ec             	push   -0x14(%ebp)
80104d4b:	50                   	push   %eax
80104d4c:	68 5c b3 10 80       	push   $0x8010b35c
80104d51:	e8 b6 b6 ff ff       	call   8010040c <cprintf>
80104d56:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104d5f:	83 c0 30             	add    $0x30,%eax
80104d62:	05 20 75 19 80       	add    $0x80197520,%eax
80104d67:	83 c0 04             	add    $0x4,%eax
80104d6a:	83 ec 08             	sub    $0x8,%esp
80104d6d:	6a 03                	push   $0x3
80104d6f:	50                   	push   %eax
80104d70:	e8 10 fe ff ff       	call   80104b85 <enqueue>
80104d75:	83 c4 10             	add    $0x10,%esp
80104d78:	e9 20 01 00 00       	jmp    80104e9d <apply_priority_boosting+0x1ec>
    } else if (q == 1 && waited >= 320) {
80104d7d:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104d81:	75 70                	jne    80104df3 <apply_priority_boosting+0x142>
80104d83:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104d8a:	7e 67                	jle    80104df3 <apply_priority_boosting+0x142>
      kernel_pstat.priority[i] = 2;
80104d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8f:	83 e8 80             	sub    $0xffffff80,%eax
80104d92:	c7 04 85 20 69 19 80 	movl   $0x2,-0x7fe696e0(,%eax,4)
80104d99:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da0:	c1 e0 04             	shl    $0x4,%eax
80104da3:	05 24 71 19 80       	add    $0x80197124,%eax
80104da8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db1:	83 c0 40             	add    $0x40,%eax
80104db4:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104dbb:	83 ec 04             	sub    $0x4,%esp
80104dbe:	ff 75 ec             	push   -0x14(%ebp)
80104dc1:	50                   	push   %eax
80104dc2:	68 80 b3 10 80       	push   $0x8010b380
80104dc7:	e8 40 b6 ff ff       	call   8010040c <cprintf>
80104dcc:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd2:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104dd5:	83 c0 30             	add    $0x30,%eax
80104dd8:	05 20 75 19 80       	add    $0x80197520,%eax
80104ddd:	83 c0 04             	add    $0x4,%eax
80104de0:	83 ec 08             	sub    $0x8,%esp
80104de3:	6a 02                	push   $0x2
80104de5:	50                   	push   %eax
80104de6:	e8 9a fd ff ff       	call   80104b85 <enqueue>
80104deb:	83 c4 10             	add    $0x10,%esp
80104dee:	e9 aa 00 00 00       	jmp    80104e9d <apply_priority_boosting+0x1ec>
    } else if (q == 0 && waited >= 500) {
80104df3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104df7:	0f 85 a0 00 00 00    	jne    80104e9d <apply_priority_boosting+0x1ec>
80104dfd:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104e04:	0f 8e 93 00 00 00    	jle    80104e9d <apply_priority_boosting+0x1ec>
      int pid = kernel_pstat.pid[i];
80104e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0d:	83 c0 40             	add    $0x40,%eax
80104e10:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104e17:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1d:	83 c0 40             	add    $0x40,%eax
80104e20:	c1 e0 04             	shl    $0x4,%eax
80104e23:	05 20 69 19 80       	add    $0x80196920,%eax
80104e28:	8b 00                	mov    (%eax),%eax
80104e2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e30:	83 e8 80             	sub    $0xffffff80,%eax
80104e33:	c1 e0 04             	shl    $0x4,%eax
80104e36:	05 20 69 19 80       	add    $0x80196920,%eax
80104e3b:	8b 00                	mov    (%eax),%eax
80104e3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e43:	83 e8 80             	sub    $0xffffff80,%eax
80104e46:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
80104e4d:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e54:	83 e8 80             	sub    $0xffffff80,%eax
80104e57:	c1 e0 04             	shl    $0x4,%eax
80104e5a:	05 20 69 19 80       	add    $0x80196920,%eax
80104e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104e65:	ff 75 e4             	push   -0x1c(%ebp)
80104e68:	ff 75 e0             	push   -0x20(%ebp)
80104e6b:	ff 75 e8             	push   -0x18(%ebp)
80104e6e:	68 a4 b3 10 80       	push   $0x8010b3a4
80104e73:	e8 94 b5 ff ff       	call   8010040c <cprintf>
80104e78:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104e81:	83 c0 30             	add    $0x30,%eax
80104e84:	05 20 75 19 80       	add    $0x80197520,%eax
80104e89:	83 c0 04             	add    $0x4,%eax
80104e8c:	83 ec 08             	sub    $0x8,%esp
80104e8f:	6a 01                	push   $0x1
80104e91:	50                   	push   %eax
80104e92:	e8 ee fc ff ff       	call   80104b85 <enqueue>
80104e97:	83 c4 10             	add    $0x10,%esp
80104e9a:	eb 01                	jmp    80104e9d <apply_priority_boosting+0x1ec>
    if (!kernel_pstat.inuse[i]) continue;
80104e9c:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104e9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea1:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104ea5:	0f 8e 1c fe ff ff    	jle    80104cc7 <apply_priority_boosting+0x16>
    }
  }
}
80104eab:	90                   	nop
80104eac:	90                   	nop
80104ead:	c9                   	leave
80104eae:	c3                   	ret

80104eaf <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104eaf:	f3 0f 1e fb          	endbr32
80104eb3:	55                   	push   %ebp
80104eb4:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104eb6:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104eba:	75 07                	jne    80104ec3 <get_time_slice+0x14>
80104ebc:	b8 08 00 00 00       	mov    $0x8,%eax
80104ec1:	eb 1f                	jmp    80104ee2 <get_time_slice+0x33>
  if (level == 2) return 16;
80104ec3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104ec7:	75 07                	jne    80104ed0 <get_time_slice+0x21>
80104ec9:	b8 10 00 00 00       	mov    $0x10,%eax
80104ece:	eb 12                	jmp    80104ee2 <get_time_slice+0x33>
  if (level == 1) return 32;
80104ed0:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104ed4:	75 07                	jne    80104edd <get_time_slice+0x2e>
80104ed6:	b8 20 00 00 00       	mov    $0x20,%eax
80104edb:	eb 05                	jmp    80104ee2 <get_time_slice+0x33>
  return -1; // FIFO (Q0)
80104edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ee2:	5d                   	pop    %ebp
80104ee3:	c3                   	ret

80104ee4 <run_process>:

void
run_process(struct proc* p, int q, int slice, int tracking) {
80104ee4:	f3 0f 1e fb          	endbr32
80104ee8:	55                   	push   %ebp
80104ee9:	89 e5                	mov    %esp,%ebp
80104eeb:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104eee:	e8 3a ec ff ff       	call   80103b2d <mycpu>
80104ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef9:	8b 55 08             	mov    0x8(%ebp),%edx
80104efc:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	ff 75 08             	push   0x8(%ebp)
80104f08:	e8 77 33 00 00       	call   80108284 <switchuvm>
80104f0d:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104f10:	8b 45 08             	mov    0x8(%ebp),%eax
80104f13:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
  int i = p - ptable.proc;
80104f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1d:	2d 54 75 19 80       	sub    $0x80197554,%eax
80104f22:	c1 f8 02             	sar    $0x2,%eax
80104f25:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
  swtch(&(c->scheduler), p->context);
80104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f31:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f37:	83 c2 04             	add    $0x4,%edx
80104f3a:	83 ec 08             	sub    $0x8,%esp
80104f3d:	50                   	push   %eax
80104f3e:	52                   	push   %edx
80104f3f:	e8 2c 09 00 00       	call   80105870 <swtch>
80104f44:	83 c4 10             	add    $0x10,%esp
  switchkvm();
80104f47:	e8 1b 33 00 00       	call   80108267 <switchkvm>
  c->proc = 0;
80104f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104f56:	00 00 00 
  if (tracking) kernel_pstat.ticks[i][q]++;
80104f59:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80104f5d:	74 39                	je     80104f98 <run_process+0xb4>
80104f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f62:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6c:	01 d0                	add    %edx,%eax
80104f6e:	05 00 01 00 00       	add    $0x100,%eax
80104f73:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104f7a:	8d 50 01             	lea    0x1(%eax),%edx
80104f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f80:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f8a:	01 c8                	add    %ecx,%eax
80104f8c:	05 00 01 00 00       	add    $0x100,%eax
80104f91:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
  if (slice != -1 && kernel_pstat.ticks[i][q] >= slice && q > 0) {
80104f98:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104f9c:	0f 84 8d 00 00 00    	je     8010502f <run_process+0x14b>
80104fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104faf:	01 d0                	add    %edx,%eax
80104fb1:	05 00 01 00 00       	add    $0x100,%eax
80104fb6:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104fbd:	39 45 10             	cmp    %eax,0x10(%ebp)
80104fc0:	7f 6d                	jg     8010502f <run_process+0x14b>
80104fc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fc6:	7e 67                	jle    8010502f <run_process+0x14b>
    kernel_pstat.priority[i] = q - 1;
80104fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fcb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd1:	83 e8 80             	sub    $0xffffff80,%eax
80104fd4:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;
80104fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fde:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe8:	01 d0                	add    %edx,%eax
80104fea:	05 00 01 00 00       	add    $0x100,%eax
80104fef:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80104ff6:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80104ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105000:	8b 45 08             	mov    0x8(%ebp),%eax
80105003:	8b 40 10             	mov    0x10(%eax),%eax
80105006:	52                   	push   %edx
80105007:	ff 75 0c             	push   0xc(%ebp)
8010500a:	50                   	push   %eax
8010500b:	68 d2 b3 10 80       	push   $0x8010b3d2
80105010:	e8 f7 b3 ff ff       	call   8010040c <cprintf>
80105015:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
80105018:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501b:	83 e8 01             	sub    $0x1,%eax
8010501e:	83 ec 08             	sub    $0x8,%esp
80105021:	50                   	push   %eax
80105022:	ff 75 08             	push   0x8(%ebp)
80105025:	e8 5b fb ff ff       	call   80104b85 <enqueue>
8010502a:	83 c4 10             	add    $0x10,%esp
  //cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
  } else {
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
8010502d:	eb 31                	jmp    80105060 <run_process+0x17c>
  } else if (q == 0) {
8010502f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105033:	74 2b                	je     80105060 <run_process+0x17c>
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
80105035:	8b 45 08             	mov    0x8(%ebp),%eax
80105038:	8b 40 10             	mov    0x10(%eax),%eax
8010503b:	83 ec 04             	sub    $0x4,%esp
8010503e:	ff 75 0c             	push   0xc(%ebp)
80105041:	50                   	push   %eax
80105042:	68 f0 b3 10 80       	push   $0x8010b3f0
80105047:	e8 c0 b3 ff ff       	call   8010040c <cprintf>
8010504c:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
8010504f:	83 ec 08             	sub    $0x8,%esp
80105052:	ff 75 0c             	push   0xc(%ebp)
80105055:	ff 75 08             	push   0x8(%ebp)
80105058:	e8 28 fb ff ff       	call   80104b85 <enqueue>
8010505d:	83 c4 10             	add    $0x10,%esp
}
80105060:	90                   	nop
80105061:	c9                   	leave
80105062:	c3                   	ret

80105063 <run_mlfq>:

// MLFQ 스케줄러 진입점
void
run_mlfq(int tracking, int boosting) {
80105063:	f3 0f 1e fb          	endbr32
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	83 ec 28             	sub    $0x28,%esp
  if (boosting)
8010506d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105071:	74 05                	je     80105078 <run_mlfq+0x15>
    apply_priority_boosting();
80105073:	e8 39 fc ff ff       	call   80104cb1 <apply_priority_boosting>

  for (int q = 3; q >= 0; q--) {
80105078:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
8010507f:	eb 7c                	jmp    801050fd <run_mlfq+0x9a>
    for (int i = 0; i < NPROC; i++) {
80105081:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105088:	eb 69                	jmp    801050f3 <run_mlfq+0x90>
      struct proc *p = mlfq_queues[q][i];
8010508a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508d:	c1 e0 06             	shl    $0x6,%eax
80105090:	89 c2                	mov    %eax,%edx
80105092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105095:	01 d0                	add    %edx,%eax
80105097:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
8010509e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (p == 0 || p->state != RUNNABLE)
801050a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801050a5:	74 0b                	je     801050b2 <run_mlfq+0x4f>
801050a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801050aa:	8b 40 0c             	mov    0xc(%eax),%eax
801050ad:	83 f8 03             	cmp    $0x3,%eax
801050b0:	74 06                	je     801050b8 <run_mlfq+0x55>
    for (int i = 0; i < NPROC; i++) {
801050b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050b6:	eb 3b                	jmp    801050f3 <run_mlfq+0x90>
        continue;
      if (q != 0)
801050b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050bc:	74 0e                	je     801050cc <run_mlfq+0x69>
        dequeue(q);
801050be:	83 ec 0c             	sub    $0xc,%esp
801050c1:	ff 75 f4             	push   -0xc(%ebp)
801050c4:	e8 3b fb ff ff       	call   80104c04 <dequeue>
801050c9:	83 c4 10             	add    $0x10,%esp
      int slice = get_time_slice(q);
801050cc:	83 ec 0c             	sub    $0xc,%esp
801050cf:	ff 75 f4             	push   -0xc(%ebp)
801050d2:	e8 d8 fd ff ff       	call   80104eaf <get_time_slice>
801050d7:	83 c4 10             	add    $0x10,%esp
801050da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice, tracking);
801050dd:	ff 75 08             	push   0x8(%ebp)
801050e0:	ff 75 e4             	push   -0x1c(%ebp)
801050e3:	ff 75 f4             	push   -0xc(%ebp)
801050e6:	ff 75 e8             	push   -0x18(%ebp)
801050e9:	e8 f6 fd ff ff       	call   80104ee4 <run_process>
801050ee:	83 c4 10             	add    $0x10,%esp
      goto tick_update;
801050f1:	eb 15                	jmp    80105108 <run_mlfq+0xa5>
    for (int i = 0; i < NPROC; i++) {
801050f3:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801050f7:	7e 91                	jle    8010508a <run_mlfq+0x27>
  for (int q = 3; q >= 0; q--) {
801050f9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801050fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105101:	0f 89 7a ff ff ff    	jns    80105081 <run_mlfq+0x1e>
    }
  }

tick_update:
80105107:	90                   	nop
  if (!tracking) return;
80105108:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010510c:	0f 84 a5 00 00 00    	je     801051b7 <run_mlfq+0x154>
  for (int i = 0; i < NPROC; i++) {
80105112:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105119:	e9 8d 00 00 00       	jmp    801051ab <run_mlfq+0x148>
    struct proc* p = &ptable.proc[i];
8010511e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105121:	6b c0 7c             	imul   $0x7c,%eax,%eax
80105124:	83 c0 30             	add    $0x30,%eax
80105127:	05 20 75 19 80       	add    $0x80197520,%eax
8010512c:	83 c0 04             	add    $0x4,%eax
8010512f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80105132:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105135:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
8010513c:	85 c0                	test   %eax,%eax
8010513e:	74 66                	je     801051a6 <run_mlfq+0x143>
    if (p->state == RUNNABLE && p != mycpu()->proc) {
80105140:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105143:	8b 40 0c             	mov    0xc(%eax),%eax
80105146:	83 f8 03             	cmp    $0x3,%eax
80105149:	75 5c                	jne    801051a7 <run_mlfq+0x144>
8010514b:	e8 dd e9 ff ff       	call   80103b2d <mycpu>
80105150:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105156:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80105159:	74 4c                	je     801051a7 <run_mlfq+0x144>
      int q = kernel_pstat.priority[i];
8010515b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010515e:	83 e8 80             	sub    $0xffffff80,%eax
80105161:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105168:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
8010516b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010516e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105175:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105178:	01 d0                	add    %edx,%eax
8010517a:	05 00 02 00 00       	add    $0x200,%eax
8010517f:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105186:	8d 50 01             	lea    0x1(%eax),%edx
80105189:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010518c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80105193:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105196:	01 c8                	add    %ecx,%eax
80105198:	05 00 02 00 00       	add    $0x200,%eax
8010519d:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
801051a4:	eb 01                	jmp    801051a7 <run_mlfq+0x144>
    if (!kernel_pstat.inuse[i]) continue;
801051a6:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
801051a7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801051ab:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
801051af:	0f 8e 69 ff ff ff    	jle    8010511e <run_mlfq+0xbb>
801051b5:	eb 01                	jmp    801051b8 <run_mlfq+0x155>
  if (!tracking) return;
801051b7:	90                   	nop
    }
  }
801051b8:	c9                   	leave
801051b9:	c3                   	ret

801051ba <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801051ba:	f3 0f 1e fb          	endbr32
801051be:	55                   	push   %ebp
801051bf:	89 e5                	mov    %esp,%ebp
801051c1:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801051c4:	8b 45 08             	mov    0x8(%ebp),%eax
801051c7:	83 c0 04             	add    $0x4,%eax
801051ca:	83 ec 08             	sub    $0x8,%esp
801051cd:	68 3c b4 10 80       	push   $0x8010b43c
801051d2:	50                   	push   %eax
801051d3:	e8 4f 01 00 00       	call   80105327 <initlock>
801051d8:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	8b 55 0c             	mov    0xc(%ebp),%edx
801051e1:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801051e4:	8b 45 08             	mov    0x8(%ebp),%eax
801051e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051ed:	8b 45 08             	mov    0x8(%ebp),%eax
801051f0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801051f7:	90                   	nop
801051f8:	c9                   	leave
801051f9:	c3                   	ret

801051fa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801051fa:	f3 0f 1e fb          	endbr32
801051fe:	55                   	push   %ebp
801051ff:	89 e5                	mov    %esp,%ebp
80105201:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105204:	8b 45 08             	mov    0x8(%ebp),%eax
80105207:	83 c0 04             	add    $0x4,%eax
8010520a:	83 ec 0c             	sub    $0xc,%esp
8010520d:	50                   	push   %eax
8010520e:	e8 3a 01 00 00       	call   8010534d <acquire>
80105213:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105216:	eb 15                	jmp    8010522d <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105218:	8b 45 08             	mov    0x8(%ebp),%eax
8010521b:	83 c0 04             	add    $0x4,%eax
8010521e:	83 ec 08             	sub    $0x8,%esp
80105221:	50                   	push   %eax
80105222:	ff 75 08             	push   0x8(%ebp)
80105225:	e8 61 f4 ff ff       	call   8010468b <sleep>
8010522a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	8b 00                	mov    (%eax),%eax
80105232:	85 c0                	test   %eax,%eax
80105234:	75 e2                	jne    80105218 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105236:	8b 45 08             	mov    0x8(%ebp),%eax
80105239:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010523f:	e8 65 e9 ff ff       	call   80103ba9 <myproc>
80105244:	8b 50 10             	mov    0x10(%eax),%edx
80105247:	8b 45 08             	mov    0x8(%ebp),%eax
8010524a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010524d:	8b 45 08             	mov    0x8(%ebp),%eax
80105250:	83 c0 04             	add    $0x4,%eax
80105253:	83 ec 0c             	sub    $0xc,%esp
80105256:	50                   	push   %eax
80105257:	e8 63 01 00 00       	call   801053bf <release>
8010525c:	83 c4 10             	add    $0x10,%esp
}
8010525f:	90                   	nop
80105260:	c9                   	leave
80105261:	c3                   	ret

80105262 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105262:	f3 0f 1e fb          	endbr32
80105266:	55                   	push   %ebp
80105267:	89 e5                	mov    %esp,%ebp
80105269:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010526c:	8b 45 08             	mov    0x8(%ebp),%eax
8010526f:	83 c0 04             	add    $0x4,%eax
80105272:	83 ec 0c             	sub    $0xc,%esp
80105275:	50                   	push   %eax
80105276:	e8 d2 00 00 00       	call   8010534d <acquire>
8010527b:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010527e:	8b 45 08             	mov    0x8(%ebp),%eax
80105281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105287:	8b 45 08             	mov    0x8(%ebp),%eax
8010528a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105291:	83 ec 0c             	sub    $0xc,%esp
80105294:	ff 75 08             	push   0x8(%ebp)
80105297:	e8 de f4 ff ff       	call   8010477a <wakeup>
8010529c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010529f:	8b 45 08             	mov    0x8(%ebp),%eax
801052a2:	83 c0 04             	add    $0x4,%eax
801052a5:	83 ec 0c             	sub    $0xc,%esp
801052a8:	50                   	push   %eax
801052a9:	e8 11 01 00 00       	call   801053bf <release>
801052ae:	83 c4 10             	add    $0x10,%esp
}
801052b1:	90                   	nop
801052b2:	c9                   	leave
801052b3:	c3                   	ret

801052b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801052b4:	f3 0f 1e fb          	endbr32
801052b8:	55                   	push   %ebp
801052b9:	89 e5                	mov    %esp,%ebp
801052bb:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801052be:	8b 45 08             	mov    0x8(%ebp),%eax
801052c1:	83 c0 04             	add    $0x4,%eax
801052c4:	83 ec 0c             	sub    $0xc,%esp
801052c7:	50                   	push   %eax
801052c8:	e8 80 00 00 00       	call   8010534d <acquire>
801052cd:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801052d0:	8b 45 08             	mov    0x8(%ebp),%eax
801052d3:	8b 00                	mov    (%eax),%eax
801052d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	83 c0 04             	add    $0x4,%eax
801052de:	83 ec 0c             	sub    $0xc,%esp
801052e1:	50                   	push   %eax
801052e2:	e8 d8 00 00 00       	call   801053bf <release>
801052e7:	83 c4 10             	add    $0x10,%esp
  return r;
801052ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052ed:	c9                   	leave
801052ee:	c3                   	ret

801052ef <readeflags>:
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052f5:	9c                   	pushf
801052f6:	58                   	pop    %eax
801052f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052fd:	c9                   	leave
801052fe:	c3                   	ret

801052ff <cli>:
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105302:	fa                   	cli
}
80105303:	90                   	nop
80105304:	5d                   	pop    %ebp
80105305:	c3                   	ret

80105306 <sti>:
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105309:	fb                   	sti
}
8010530a:	90                   	nop
8010530b:	5d                   	pop    %ebp
8010530c:	c3                   	ret

8010530d <xchg>:
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
80105310:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105313:	8b 55 08             	mov    0x8(%ebp),%edx
80105316:	8b 45 0c             	mov    0xc(%ebp),%eax
80105319:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010531c:	f0 87 02             	lock xchg %eax,(%edx)
8010531f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105322:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105325:	c9                   	leave
80105326:	c3                   	ret

80105327 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105327:	f3 0f 1e fb          	endbr32
8010532b:	55                   	push   %ebp
8010532c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010532e:	8b 45 08             	mov    0x8(%ebp),%eax
80105331:	8b 55 0c             	mov    0xc(%ebp),%edx
80105334:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105337:	8b 45 08             	mov    0x8(%ebp),%eax
8010533a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105340:	8b 45 08             	mov    0x8(%ebp),%eax
80105343:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010534a:	90                   	nop
8010534b:	5d                   	pop    %ebp
8010534c:	c3                   	ret

8010534d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010534d:	f3 0f 1e fb          	endbr32
80105351:	55                   	push   %ebp
80105352:	89 e5                	mov    %esp,%ebp
80105354:	53                   	push   %ebx
80105355:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105358:	e8 6c 01 00 00       	call   801054c9 <pushcli>
  if(holding(lk)){
8010535d:	8b 45 08             	mov    0x8(%ebp),%eax
80105360:	83 ec 0c             	sub    $0xc,%esp
80105363:	50                   	push   %eax
80105364:	e8 2b 01 00 00       	call   80105494 <holding>
80105369:	83 c4 10             	add    $0x10,%esp
8010536c:	85 c0                	test   %eax,%eax
8010536e:	74 0d                	je     8010537d <acquire+0x30>
    panic("acquire");
80105370:	83 ec 0c             	sub    $0xc,%esp
80105373:	68 47 b4 10 80       	push   $0x8010b447
80105378:	e8 48 b2 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010537d:	90                   	nop
8010537e:	8b 45 08             	mov    0x8(%ebp),%eax
80105381:	83 ec 08             	sub    $0x8,%esp
80105384:	6a 01                	push   $0x1
80105386:	50                   	push   %eax
80105387:	e8 81 ff ff ff       	call   8010530d <xchg>
8010538c:	83 c4 10             	add    $0x10,%esp
8010538f:	85 c0                	test   %eax,%eax
80105391:	75 eb                	jne    8010537e <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105393:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105398:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010539b:	e8 8d e7 ff ff       	call   80103b2d <mycpu>
801053a0:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801053a3:	8b 45 08             	mov    0x8(%ebp),%eax
801053a6:	83 c0 0c             	add    $0xc,%eax
801053a9:	83 ec 08             	sub    $0x8,%esp
801053ac:	50                   	push   %eax
801053ad:	8d 45 08             	lea    0x8(%ebp),%eax
801053b0:	50                   	push   %eax
801053b1:	e8 5f 00 00 00       	call   80105415 <getcallerpcs>
801053b6:	83 c4 10             	add    $0x10,%esp
}
801053b9:	90                   	nop
801053ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053bd:	c9                   	leave
801053be:	c3                   	ret

801053bf <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053bf:	f3 0f 1e fb          	endbr32
801053c3:	55                   	push   %ebp
801053c4:	89 e5                	mov    %esp,%ebp
801053c6:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801053c9:	83 ec 0c             	sub    $0xc,%esp
801053cc:	ff 75 08             	push   0x8(%ebp)
801053cf:	e8 c0 00 00 00       	call   80105494 <holding>
801053d4:	83 c4 10             	add    $0x10,%esp
801053d7:	85 c0                	test   %eax,%eax
801053d9:	75 0d                	jne    801053e8 <release+0x29>
    panic("release");
801053db:	83 ec 0c             	sub    $0xc,%esp
801053de:	68 4f b4 10 80       	push   $0x8010b44f
801053e3:	e8 dd b1 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
801053e8:	8b 45 08             	mov    0x8(%ebp),%eax
801053eb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053fc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
80105404:	8b 55 08             	mov    0x8(%ebp),%edx
80105407:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010540d:	e8 08 01 00 00       	call   8010551a <popcli>
}
80105412:	90                   	nop
80105413:	c9                   	leave
80105414:	c3                   	ret

80105415 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105415:	f3 0f 1e fb          	endbr32
80105419:	55                   	push   %ebp
8010541a:	89 e5                	mov    %esp,%ebp
8010541c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010541f:	8b 45 08             	mov    0x8(%ebp),%eax
80105422:	83 e8 08             	sub    $0x8,%eax
80105425:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105428:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010542f:	eb 38                	jmp    80105469 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105431:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105435:	74 53                	je     8010548a <getcallerpcs+0x75>
80105437:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010543e:	76 4a                	jbe    8010548a <getcallerpcs+0x75>
80105440:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105444:	74 44                	je     8010548a <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105446:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105449:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105450:	8b 45 0c             	mov    0xc(%ebp),%eax
80105453:	01 c2                	add    %eax,%edx
80105455:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105458:	8b 40 04             	mov    0x4(%eax),%eax
8010545b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010545d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105460:	8b 00                	mov    (%eax),%eax
80105462:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105465:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105469:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010546d:	7e c2                	jle    80105431 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
8010546f:	eb 19                	jmp    8010548a <getcallerpcs+0x75>
    pcs[i] = 0;
80105471:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105474:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010547b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547e:	01 d0                	add    %edx,%eax
80105480:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105486:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010548a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010548e:	7e e1                	jle    80105471 <getcallerpcs+0x5c>
}
80105490:	90                   	nop
80105491:	90                   	nop
80105492:	c9                   	leave
80105493:	c3                   	ret

80105494 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105494:	f3 0f 1e fb          	endbr32
80105498:	55                   	push   %ebp
80105499:	89 e5                	mov    %esp,%ebp
8010549b:	53                   	push   %ebx
8010549c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010549f:	8b 45 08             	mov    0x8(%ebp),%eax
801054a2:	8b 00                	mov    (%eax),%eax
801054a4:	85 c0                	test   %eax,%eax
801054a6:	74 16                	je     801054be <holding+0x2a>
801054a8:	8b 45 08             	mov    0x8(%ebp),%eax
801054ab:	8b 58 08             	mov    0x8(%eax),%ebx
801054ae:	e8 7a e6 ff ff       	call   80103b2d <mycpu>
801054b3:	39 c3                	cmp    %eax,%ebx
801054b5:	75 07                	jne    801054be <holding+0x2a>
801054b7:	b8 01 00 00 00       	mov    $0x1,%eax
801054bc:	eb 05                	jmp    801054c3 <holding+0x2f>
801054be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c3:	83 c4 04             	add    $0x4,%esp
801054c6:	5b                   	pop    %ebx
801054c7:	5d                   	pop    %ebp
801054c8:	c3                   	ret

801054c9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054c9:	f3 0f 1e fb          	endbr32
801054cd:	55                   	push   %ebp
801054ce:	89 e5                	mov    %esp,%ebp
801054d0:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054d3:	e8 17 fe ff ff       	call   801052ef <readeflags>
801054d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801054db:	e8 1f fe ff ff       	call   801052ff <cli>
  if(mycpu()->ncli == 0)
801054e0:	e8 48 e6 ff ff       	call   80103b2d <mycpu>
801054e5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054eb:	85 c0                	test   %eax,%eax
801054ed:	75 14                	jne    80105503 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801054ef:	e8 39 e6 ff ff       	call   80103b2d <mycpu>
801054f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054f7:	81 e2 00 02 00 00    	and    $0x200,%edx
801054fd:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105503:	e8 25 e6 ff ff       	call   80103b2d <mycpu>
80105508:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010550e:	83 c2 01             	add    $0x1,%edx
80105511:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105517:	90                   	nop
80105518:	c9                   	leave
80105519:	c3                   	ret

8010551a <popcli>:

void
popcli(void)
{
8010551a:	f3 0f 1e fb          	endbr32
8010551e:	55                   	push   %ebp
8010551f:	89 e5                	mov    %esp,%ebp
80105521:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105524:	e8 c6 fd ff ff       	call   801052ef <readeflags>
80105529:	25 00 02 00 00       	and    $0x200,%eax
8010552e:	85 c0                	test   %eax,%eax
80105530:	74 0d                	je     8010553f <popcli+0x25>
    panic("popcli - interruptible");
80105532:	83 ec 0c             	sub    $0xc,%esp
80105535:	68 57 b4 10 80       	push   $0x8010b457
8010553a:	e8 86 b0 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
8010553f:	e8 e9 e5 ff ff       	call   80103b2d <mycpu>
80105544:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010554a:	83 ea 01             	sub    $0x1,%edx
8010554d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105553:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105559:	85 c0                	test   %eax,%eax
8010555b:	79 0d                	jns    8010556a <popcli+0x50>
    panic("popcli");
8010555d:	83 ec 0c             	sub    $0xc,%esp
80105560:	68 6e b4 10 80       	push   $0x8010b46e
80105565:	e8 5b b0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010556a:	e8 be e5 ff ff       	call   80103b2d <mycpu>
8010556f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105575:	85 c0                	test   %eax,%eax
80105577:	75 14                	jne    8010558d <popcli+0x73>
80105579:	e8 af e5 ff ff       	call   80103b2d <mycpu>
8010557e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105584:	85 c0                	test   %eax,%eax
80105586:	74 05                	je     8010558d <popcli+0x73>
    sti();
80105588:	e8 79 fd ff ff       	call   80105306 <sti>
}
8010558d:	90                   	nop
8010558e:	c9                   	leave
8010558f:	c3                   	ret

80105590 <stosb>:
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	57                   	push   %edi
80105594:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105595:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105598:	8b 55 10             	mov    0x10(%ebp),%edx
8010559b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559e:	89 cb                	mov    %ecx,%ebx
801055a0:	89 df                	mov    %ebx,%edi
801055a2:	89 d1                	mov    %edx,%ecx
801055a4:	fc                   	cld
801055a5:	f3 aa                	rep stos %al,%es:(%edi)
801055a7:	89 ca                	mov    %ecx,%edx
801055a9:	89 fb                	mov    %edi,%ebx
801055ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055ae:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055b1:	90                   	nop
801055b2:	5b                   	pop    %ebx
801055b3:	5f                   	pop    %edi
801055b4:	5d                   	pop    %ebp
801055b5:	c3                   	ret

801055b6 <stosl>:
{
801055b6:	55                   	push   %ebp
801055b7:	89 e5                	mov    %esp,%ebp
801055b9:	57                   	push   %edi
801055ba:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055be:	8b 55 10             	mov    0x10(%ebp),%edx
801055c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c4:	89 cb                	mov    %ecx,%ebx
801055c6:	89 df                	mov    %ebx,%edi
801055c8:	89 d1                	mov    %edx,%ecx
801055ca:	fc                   	cld
801055cb:	f3 ab                	rep stos %eax,%es:(%edi)
801055cd:	89 ca                	mov    %ecx,%edx
801055cf:	89 fb                	mov    %edi,%ebx
801055d1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055d4:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055d7:	90                   	nop
801055d8:	5b                   	pop    %ebx
801055d9:	5f                   	pop    %edi
801055da:	5d                   	pop    %ebp
801055db:	c3                   	ret

801055dc <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055dc:	f3 0f 1e fb          	endbr32
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801055e3:	8b 45 08             	mov    0x8(%ebp),%eax
801055e6:	83 e0 03             	and    $0x3,%eax
801055e9:	85 c0                	test   %eax,%eax
801055eb:	75 43                	jne    80105630 <memset+0x54>
801055ed:	8b 45 10             	mov    0x10(%ebp),%eax
801055f0:	83 e0 03             	and    $0x3,%eax
801055f3:	85 c0                	test   %eax,%eax
801055f5:	75 39                	jne    80105630 <memset+0x54>
    c &= 0xFF;
801055f7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105601:	c1 e8 02             	shr    $0x2,%eax
80105604:	89 c1                	mov    %eax,%ecx
80105606:	8b 45 0c             	mov    0xc(%ebp),%eax
80105609:	c1 e0 18             	shl    $0x18,%eax
8010560c:	89 c2                	mov    %eax,%edx
8010560e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105611:	c1 e0 10             	shl    $0x10,%eax
80105614:	09 c2                	or     %eax,%edx
80105616:	8b 45 0c             	mov    0xc(%ebp),%eax
80105619:	c1 e0 08             	shl    $0x8,%eax
8010561c:	09 d0                	or     %edx,%eax
8010561e:	0b 45 0c             	or     0xc(%ebp),%eax
80105621:	51                   	push   %ecx
80105622:	50                   	push   %eax
80105623:	ff 75 08             	push   0x8(%ebp)
80105626:	e8 8b ff ff ff       	call   801055b6 <stosl>
8010562b:	83 c4 0c             	add    $0xc,%esp
8010562e:	eb 12                	jmp    80105642 <memset+0x66>
  } else
    stosb(dst, c, n);
80105630:	8b 45 10             	mov    0x10(%ebp),%eax
80105633:	50                   	push   %eax
80105634:	ff 75 0c             	push   0xc(%ebp)
80105637:	ff 75 08             	push   0x8(%ebp)
8010563a:	e8 51 ff ff ff       	call   80105590 <stosb>
8010563f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105642:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105645:	c9                   	leave
80105646:	c3                   	ret

80105647 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105647:	f3 0f 1e fb          	endbr32
8010564b:	55                   	push   %ebp
8010564c:	89 e5                	mov    %esp,%ebp
8010564e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105651:	8b 45 08             	mov    0x8(%ebp),%eax
80105654:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105657:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010565d:	eb 30                	jmp    8010568f <memcmp+0x48>
    if(*s1 != *s2)
8010565f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105662:	0f b6 10             	movzbl (%eax),%edx
80105665:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105668:	0f b6 00             	movzbl (%eax),%eax
8010566b:	38 c2                	cmp    %al,%dl
8010566d:	74 18                	je     80105687 <memcmp+0x40>
      return *s1 - *s2;
8010566f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105672:	0f b6 00             	movzbl (%eax),%eax
80105675:	0f b6 d0             	movzbl %al,%edx
80105678:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010567b:	0f b6 00             	movzbl (%eax),%eax
8010567e:	0f b6 c0             	movzbl %al,%eax
80105681:	29 c2                	sub    %eax,%edx
80105683:	89 d0                	mov    %edx,%eax
80105685:	eb 1a                	jmp    801056a1 <memcmp+0x5a>
    s1++, s2++;
80105687:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010568b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010568f:	8b 45 10             	mov    0x10(%ebp),%eax
80105692:	8d 50 ff             	lea    -0x1(%eax),%edx
80105695:	89 55 10             	mov    %edx,0x10(%ebp)
80105698:	85 c0                	test   %eax,%eax
8010569a:	75 c3                	jne    8010565f <memcmp+0x18>
  }

  return 0;
8010569c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a1:	c9                   	leave
801056a2:	c3                   	ret

801056a3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056a3:	f3 0f 1e fb          	endbr32
801056a7:	55                   	push   %ebp
801056a8:	89 e5                	mov    %esp,%ebp
801056aa:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056b3:	8b 45 08             	mov    0x8(%ebp),%eax
801056b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056bf:	73 54                	jae    80105715 <memmove+0x72>
801056c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056c4:	8b 45 10             	mov    0x10(%ebp),%eax
801056c7:	01 d0                	add    %edx,%eax
801056c9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801056cc:	73 47                	jae    80105715 <memmove+0x72>
    s += n;
801056ce:	8b 45 10             	mov    0x10(%ebp),%eax
801056d1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056d4:	8b 45 10             	mov    0x10(%ebp),%eax
801056d7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056da:	eb 13                	jmp    801056ef <memmove+0x4c>
      *--d = *--s;
801056dc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056e0:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e7:	0f b6 10             	movzbl (%eax),%edx
801056ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056ed:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056ef:	8b 45 10             	mov    0x10(%ebp),%eax
801056f2:	8d 50 ff             	lea    -0x1(%eax),%edx
801056f5:	89 55 10             	mov    %edx,0x10(%ebp)
801056f8:	85 c0                	test   %eax,%eax
801056fa:	75 e0                	jne    801056dc <memmove+0x39>
  if(s < d && s + n > d){
801056fc:	eb 24                	jmp    80105722 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105701:	8d 42 01             	lea    0x1(%edx),%eax
80105704:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105707:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010570a:	8d 48 01             	lea    0x1(%eax),%ecx
8010570d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105710:	0f b6 12             	movzbl (%edx),%edx
80105713:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105715:	8b 45 10             	mov    0x10(%ebp),%eax
80105718:	8d 50 ff             	lea    -0x1(%eax),%edx
8010571b:	89 55 10             	mov    %edx,0x10(%ebp)
8010571e:	85 c0                	test   %eax,%eax
80105720:	75 dc                	jne    801056fe <memmove+0x5b>

  return dst;
80105722:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105725:	c9                   	leave
80105726:	c3                   	ret

80105727 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105727:	f3 0f 1e fb          	endbr32
8010572b:	55                   	push   %ebp
8010572c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010572e:	ff 75 10             	push   0x10(%ebp)
80105731:	ff 75 0c             	push   0xc(%ebp)
80105734:	ff 75 08             	push   0x8(%ebp)
80105737:	e8 67 ff ff ff       	call   801056a3 <memmove>
8010573c:	83 c4 0c             	add    $0xc,%esp
}
8010573f:	c9                   	leave
80105740:	c3                   	ret

80105741 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105741:	f3 0f 1e fb          	endbr32
80105745:	55                   	push   %ebp
80105746:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105748:	eb 0c                	jmp    80105756 <strncmp+0x15>
    n--, p++, q++;
8010574a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010574e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105752:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105756:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010575a:	74 1a                	je     80105776 <strncmp+0x35>
8010575c:	8b 45 08             	mov    0x8(%ebp),%eax
8010575f:	0f b6 00             	movzbl (%eax),%eax
80105762:	84 c0                	test   %al,%al
80105764:	74 10                	je     80105776 <strncmp+0x35>
80105766:	8b 45 08             	mov    0x8(%ebp),%eax
80105769:	0f b6 10             	movzbl (%eax),%edx
8010576c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010576f:	0f b6 00             	movzbl (%eax),%eax
80105772:	38 c2                	cmp    %al,%dl
80105774:	74 d4                	je     8010574a <strncmp+0x9>
  if(n == 0)
80105776:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010577a:	75 07                	jne    80105783 <strncmp+0x42>
    return 0;
8010577c:	b8 00 00 00 00       	mov    $0x0,%eax
80105781:	eb 16                	jmp    80105799 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105783:	8b 45 08             	mov    0x8(%ebp),%eax
80105786:	0f b6 00             	movzbl (%eax),%eax
80105789:	0f b6 d0             	movzbl %al,%edx
8010578c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578f:	0f b6 00             	movzbl (%eax),%eax
80105792:	0f b6 c0             	movzbl %al,%eax
80105795:	29 c2                	sub    %eax,%edx
80105797:	89 d0                	mov    %edx,%eax
}
80105799:	5d                   	pop    %ebp
8010579a:	c3                   	ret

8010579b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010579b:	f3 0f 1e fb          	endbr32
8010579f:	55                   	push   %ebp
801057a0:	89 e5                	mov    %esp,%ebp
801057a2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057a5:	8b 45 08             	mov    0x8(%ebp),%eax
801057a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057ab:	90                   	nop
801057ac:	8b 45 10             	mov    0x10(%ebp),%eax
801057af:	8d 50 ff             	lea    -0x1(%eax),%edx
801057b2:	89 55 10             	mov    %edx,0x10(%ebp)
801057b5:	85 c0                	test   %eax,%eax
801057b7:	7e 2c                	jle    801057e5 <strncpy+0x4a>
801057b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801057bc:	8d 42 01             	lea    0x1(%edx),%eax
801057bf:	89 45 0c             	mov    %eax,0xc(%ebp)
801057c2:	8b 45 08             	mov    0x8(%ebp),%eax
801057c5:	8d 48 01             	lea    0x1(%eax),%ecx
801057c8:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057cb:	0f b6 12             	movzbl (%edx),%edx
801057ce:	88 10                	mov    %dl,(%eax)
801057d0:	0f b6 00             	movzbl (%eax),%eax
801057d3:	84 c0                	test   %al,%al
801057d5:	75 d5                	jne    801057ac <strncpy+0x11>
    ;
  while(n-- > 0)
801057d7:	eb 0c                	jmp    801057e5 <strncpy+0x4a>
    *s++ = 0;
801057d9:	8b 45 08             	mov    0x8(%ebp),%eax
801057dc:	8d 50 01             	lea    0x1(%eax),%edx
801057df:	89 55 08             	mov    %edx,0x8(%ebp)
801057e2:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801057e5:	8b 45 10             	mov    0x10(%ebp),%eax
801057e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801057eb:	89 55 10             	mov    %edx,0x10(%ebp)
801057ee:	85 c0                	test   %eax,%eax
801057f0:	7f e7                	jg     801057d9 <strncpy+0x3e>
  return os;
801057f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f5:	c9                   	leave
801057f6:	c3                   	ret

801057f7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057f7:	f3 0f 1e fb          	endbr32
801057fb:	55                   	push   %ebp
801057fc:	89 e5                	mov    %esp,%ebp
801057fe:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105801:	8b 45 08             	mov    0x8(%ebp),%eax
80105804:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105807:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010580b:	7f 05                	jg     80105812 <safestrcpy+0x1b>
    return os;
8010580d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105810:	eb 31                	jmp    80105843 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105812:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105816:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010581a:	7e 1e                	jle    8010583a <safestrcpy+0x43>
8010581c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010581f:	8d 42 01             	lea    0x1(%edx),%eax
80105822:	89 45 0c             	mov    %eax,0xc(%ebp)
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	8d 48 01             	lea    0x1(%eax),%ecx
8010582b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010582e:	0f b6 12             	movzbl (%edx),%edx
80105831:	88 10                	mov    %dl,(%eax)
80105833:	0f b6 00             	movzbl (%eax),%eax
80105836:	84 c0                	test   %al,%al
80105838:	75 d8                	jne    80105812 <safestrcpy+0x1b>
    ;
  *s = 0;
8010583a:	8b 45 08             	mov    0x8(%ebp),%eax
8010583d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105840:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105843:	c9                   	leave
80105844:	c3                   	ret

80105845 <strlen>:

int
strlen(const char *s)
{
80105845:	f3 0f 1e fb          	endbr32
80105849:	55                   	push   %ebp
8010584a:	89 e5                	mov    %esp,%ebp
8010584c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010584f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105856:	eb 04                	jmp    8010585c <strlen+0x17>
80105858:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010585c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010585f:	8b 45 08             	mov    0x8(%ebp),%eax
80105862:	01 d0                	add    %edx,%eax
80105864:	0f b6 00             	movzbl (%eax),%eax
80105867:	84 c0                	test   %al,%al
80105869:	75 ed                	jne    80105858 <strlen+0x13>
    ;
  return n;
8010586b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010586e:	c9                   	leave
8010586f:	c3                   	ret

80105870 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105870:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105874:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105878:	55                   	push   %ebp
  pushl %ebx
80105879:	53                   	push   %ebx
  pushl %esi
8010587a:	56                   	push   %esi
  pushl %edi
8010587b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010587c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010587e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105880:	5f                   	pop    %edi
  popl %esi
80105881:	5e                   	pop    %esi
  popl %ebx
80105882:	5b                   	pop    %ebx
  popl %ebp
80105883:	5d                   	pop    %ebp
  ret
80105884:	c3                   	ret

80105885 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105885:	f3 0f 1e fb          	endbr32
80105889:	55                   	push   %ebp
8010588a:	89 e5                	mov    %esp,%ebp
8010588c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010588f:	e8 15 e3 ff ff       	call   80103ba9 <myproc>
80105894:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589a:	8b 00                	mov    (%eax),%eax
8010589c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010589f:	73 0f                	jae    801058b0 <fetchint+0x2b>
801058a1:	8b 45 08             	mov    0x8(%ebp),%eax
801058a4:	8d 50 04             	lea    0x4(%eax),%edx
801058a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058aa:	8b 00                	mov    (%eax),%eax
801058ac:	39 c2                	cmp    %eax,%edx
801058ae:	76 07                	jbe    801058b7 <fetchint+0x32>
    return -1;
801058b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b5:	eb 0f                	jmp    801058c6 <fetchint+0x41>
  *ip = *(int*)(addr);
801058b7:	8b 45 08             	mov    0x8(%ebp),%eax
801058ba:	8b 10                	mov    (%eax),%edx
801058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801058bf:	89 10                	mov    %edx,(%eax)
  return 0;
801058c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058c6:	c9                   	leave
801058c7:	c3                   	ret

801058c8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058c8:	f3 0f 1e fb          	endbr32
801058cc:	55                   	push   %ebp
801058cd:	89 e5                	mov    %esp,%ebp
801058cf:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801058d2:	e8 d2 e2 ff ff       	call   80103ba9 <myproc>
801058d7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801058da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058dd:	8b 00                	mov    (%eax),%eax
801058df:	39 45 08             	cmp    %eax,0x8(%ebp)
801058e2:	72 07                	jb     801058eb <fetchstr+0x23>
    return -1;
801058e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e9:	eb 43                	jmp    8010592e <fetchstr+0x66>
  *pp = (char*)addr;
801058eb:	8b 55 08             	mov    0x8(%ebp),%edx
801058ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f1:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f6:	8b 00                	mov    (%eax),%eax
801058f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801058fe:	8b 00                	mov    (%eax),%eax
80105900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105903:	eb 1c                	jmp    80105921 <fetchstr+0x59>
    if(*s == 0)
80105905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105908:	0f b6 00             	movzbl (%eax),%eax
8010590b:	84 c0                	test   %al,%al
8010590d:	75 0e                	jne    8010591d <fetchstr+0x55>
      return s - *pp;
8010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105912:	8b 00                	mov    (%eax),%eax
80105914:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105917:	29 c2                	sub    %eax,%edx
80105919:	89 d0                	mov    %edx,%eax
8010591b:	eb 11                	jmp    8010592e <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
8010591d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105927:	72 dc                	jb     80105905 <fetchstr+0x3d>
  }
  return -1;
80105929:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010592e:	c9                   	leave
8010592f:	c3                   	ret

80105930 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105930:	f3 0f 1e fb          	endbr32
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010593a:	e8 6a e2 ff ff       	call   80103ba9 <myproc>
8010593f:	8b 40 18             	mov    0x18(%eax),%eax
80105942:	8b 40 44             	mov    0x44(%eax),%eax
80105945:	8b 55 08             	mov    0x8(%ebp),%edx
80105948:	c1 e2 02             	shl    $0x2,%edx
8010594b:	01 d0                	add    %edx,%eax
8010594d:	83 c0 04             	add    $0x4,%eax
80105950:	83 ec 08             	sub    $0x8,%esp
80105953:	ff 75 0c             	push   0xc(%ebp)
80105956:	50                   	push   %eax
80105957:	e8 29 ff ff ff       	call   80105885 <fetchint>
8010595c:	83 c4 10             	add    $0x10,%esp
}
8010595f:	c9                   	leave
80105960:	c3                   	ret

80105961 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105961:	f3 0f 1e fb          	endbr32
80105965:	55                   	push   %ebp
80105966:	89 e5                	mov    %esp,%ebp
80105968:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010596b:	e8 39 e2 ff ff       	call   80103ba9 <myproc>
80105970:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105973:	83 ec 08             	sub    $0x8,%esp
80105976:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105979:	50                   	push   %eax
8010597a:	ff 75 08             	push   0x8(%ebp)
8010597d:	e8 ae ff ff ff       	call   80105930 <argint>
80105982:	83 c4 10             	add    $0x10,%esp
80105985:	85 c0                	test   %eax,%eax
80105987:	79 07                	jns    80105990 <argptr+0x2f>
    return -1;
80105989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598e:	eb 3b                	jmp    801059cb <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105990:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105994:	78 1f                	js     801059b5 <argptr+0x54>
80105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105999:	8b 00                	mov    (%eax),%eax
8010599b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010599e:	39 d0                	cmp    %edx,%eax
801059a0:	76 13                	jbe    801059b5 <argptr+0x54>
801059a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a5:	89 c2                	mov    %eax,%edx
801059a7:	8b 45 10             	mov    0x10(%ebp),%eax
801059aa:	01 c2                	add    %eax,%edx
801059ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059af:	8b 00                	mov    (%eax),%eax
801059b1:	39 c2                	cmp    %eax,%edx
801059b3:	76 07                	jbe    801059bc <argptr+0x5b>
    return -1;
801059b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ba:	eb 0f                	jmp    801059cb <argptr+0x6a>
  *pp = (char*)i;
801059bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bf:	89 c2                	mov    %eax,%edx
801059c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801059c4:	89 10                	mov    %edx,(%eax)
  return 0;
801059c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059cb:	c9                   	leave
801059cc:	c3                   	ret

801059cd <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059cd:	f3 0f 1e fb          	endbr32
801059d1:	55                   	push   %ebp
801059d2:	89 e5                	mov    %esp,%ebp
801059d4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059d7:	83 ec 08             	sub    $0x8,%esp
801059da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059dd:	50                   	push   %eax
801059de:	ff 75 08             	push   0x8(%ebp)
801059e1:	e8 4a ff ff ff       	call   80105930 <argint>
801059e6:	83 c4 10             	add    $0x10,%esp
801059e9:	85 c0                	test   %eax,%eax
801059eb:	79 07                	jns    801059f4 <argstr+0x27>
    return -1;
801059ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f2:	eb 12                	jmp    80105a06 <argstr+0x39>
  return fetchstr(addr, pp);
801059f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f7:	83 ec 08             	sub    $0x8,%esp
801059fa:	ff 75 0c             	push   0xc(%ebp)
801059fd:	50                   	push   %eax
801059fe:	e8 c5 fe ff ff       	call   801058c8 <fetchstr>
80105a03:	83 c4 10             	add    $0x10,%esp
}
80105a06:	c9                   	leave
80105a07:	c3                   	ret

80105a08 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
80105a08:	f3 0f 1e fb          	endbr32
80105a0c:	55                   	push   %ebp
80105a0d:	89 e5                	mov    %esp,%ebp
80105a0f:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105a12:	e8 92 e1 ff ff       	call   80103ba9 <myproc>
80105a17:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1d:	8b 40 18             	mov    0x18(%eax),%eax
80105a20:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a2a:	7e 2f                	jle    80105a5b <syscall+0x53>
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	83 f8 19             	cmp    $0x19,%eax
80105a32:	77 27                	ja     80105a5b <syscall+0x53>
80105a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a37:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a3e:	85 c0                	test   %eax,%eax
80105a40:	74 19                	je     80105a5b <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a45:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a4c:	ff d0                	call   *%eax
80105a4e:	89 c2                	mov    %eax,%edx
80105a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a53:	8b 40 18             	mov    0x18(%eax),%eax
80105a56:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a59:	eb 2c                	jmp    80105a87 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	8b 40 10             	mov    0x10(%eax),%eax
80105a67:	ff 75 f0             	push   -0x10(%ebp)
80105a6a:	52                   	push   %edx
80105a6b:	50                   	push   %eax
80105a6c:	68 75 b4 10 80       	push   $0x8010b475
80105a71:	e8 96 a9 ff ff       	call   8010040c <cprintf>
80105a76:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7c:	8b 40 18             	mov    0x18(%eax),%eax
80105a7f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a86:	90                   	nop
80105a87:	90                   	nop
80105a88:	c9                   	leave
80105a89:	c3                   	ret

80105a8a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a8a:	f3 0f 1e fb          	endbr32
80105a8e:	55                   	push   %ebp
80105a8f:	89 e5                	mov    %esp,%ebp
80105a91:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a94:	83 ec 08             	sub    $0x8,%esp
80105a97:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a9a:	50                   	push   %eax
80105a9b:	ff 75 08             	push   0x8(%ebp)
80105a9e:	e8 8d fe ff ff       	call   80105930 <argint>
80105aa3:	83 c4 10             	add    $0x10,%esp
80105aa6:	85 c0                	test   %eax,%eax
80105aa8:	79 07                	jns    80105ab1 <argfd+0x27>
    return -1;
80105aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aaf:	eb 4f                	jmp    80105b00 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	78 20                	js     80105ad8 <argfd+0x4e>
80105ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abb:	83 f8 0f             	cmp    $0xf,%eax
80105abe:	7f 18                	jg     80105ad8 <argfd+0x4e>
80105ac0:	e8 e4 e0 ff ff       	call   80103ba9 <myproc>
80105ac5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ac8:	83 c2 08             	add    $0x8,%edx
80105acb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ad2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ad6:	75 07                	jne    80105adf <argfd+0x55>
    return -1;
80105ad8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105add:	eb 21                	jmp    80105b00 <argfd+0x76>
  if(pfd)
80105adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ae3:	74 08                	je     80105aed <argfd+0x63>
    *pfd = fd;
80105ae5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aeb:	89 10                	mov    %edx,(%eax)
  if(pf)
80105aed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105af1:	74 08                	je     80105afb <argfd+0x71>
    *pf = f;
80105af3:	8b 45 10             	mov    0x10(%ebp),%eax
80105af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af9:	89 10                	mov    %edx,(%eax)
  return 0;
80105afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b00:	c9                   	leave
80105b01:	c3                   	ret

80105b02 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b02:	f3 0f 1e fb          	endbr32
80105b06:	55                   	push   %ebp
80105b07:	89 e5                	mov    %esp,%ebp
80105b09:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105b0c:	e8 98 e0 ff ff       	call   80103ba9 <myproc>
80105b11:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105b14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b1b:	eb 2a                	jmp    80105b47 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b23:	83 c2 08             	add    $0x8,%edx
80105b26:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b2a:	85 c0                	test   %eax,%eax
80105b2c:	75 15                	jne    80105b43 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b34:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b37:	8b 55 08             	mov    0x8(%ebp),%edx
80105b3a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b41:	eb 0f                	jmp    80105b52 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b47:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b4b:	7e d0                	jle    80105b1d <fdalloc+0x1b>
    }
  }
  return -1;
80105b4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b52:	c9                   	leave
80105b53:	c3                   	ret

80105b54 <sys_dup>:

int
sys_dup(void)
{
80105b54:	f3 0f 1e fb          	endbr32
80105b58:	55                   	push   %ebp
80105b59:	89 e5                	mov    %esp,%ebp
80105b5b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b5e:	83 ec 04             	sub    $0x4,%esp
80105b61:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b64:	50                   	push   %eax
80105b65:	6a 00                	push   $0x0
80105b67:	6a 00                	push   $0x0
80105b69:	e8 1c ff ff ff       	call   80105a8a <argfd>
80105b6e:	83 c4 10             	add    $0x10,%esp
80105b71:	85 c0                	test   %eax,%eax
80105b73:	79 07                	jns    80105b7c <sys_dup+0x28>
    return -1;
80105b75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7a:	eb 31                	jmp    80105bad <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7f:	83 ec 0c             	sub    $0xc,%esp
80105b82:	50                   	push   %eax
80105b83:	e8 7a ff ff ff       	call   80105b02 <fdalloc>
80105b88:	83 c4 10             	add    $0x10,%esp
80105b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b92:	79 07                	jns    80105b9b <sys_dup+0x47>
    return -1;
80105b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b99:	eb 12                	jmp    80105bad <sys_dup+0x59>
  filedup(f);
80105b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	50                   	push   %eax
80105ba2:	e8 ed b4 ff ff       	call   80101094 <filedup>
80105ba7:	83 c4 10             	add    $0x10,%esp
  return fd;
80105baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105bad:	c9                   	leave
80105bae:	c3                   	ret

80105baf <sys_read>:

int
sys_read(void)
{
80105baf:	f3 0f 1e fb          	endbr32
80105bb3:	55                   	push   %ebp
80105bb4:	89 e5                	mov    %esp,%ebp
80105bb6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bb9:	83 ec 04             	sub    $0x4,%esp
80105bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bbf:	50                   	push   %eax
80105bc0:	6a 00                	push   $0x0
80105bc2:	6a 00                	push   $0x0
80105bc4:	e8 c1 fe ff ff       	call   80105a8a <argfd>
80105bc9:	83 c4 10             	add    $0x10,%esp
80105bcc:	85 c0                	test   %eax,%eax
80105bce:	78 2e                	js     80105bfe <sys_read+0x4f>
80105bd0:	83 ec 08             	sub    $0x8,%esp
80105bd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bd6:	50                   	push   %eax
80105bd7:	6a 02                	push   $0x2
80105bd9:	e8 52 fd ff ff       	call   80105930 <argint>
80105bde:	83 c4 10             	add    $0x10,%esp
80105be1:	85 c0                	test   %eax,%eax
80105be3:	78 19                	js     80105bfe <sys_read+0x4f>
80105be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be8:	83 ec 04             	sub    $0x4,%esp
80105beb:	50                   	push   %eax
80105bec:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bef:	50                   	push   %eax
80105bf0:	6a 01                	push   $0x1
80105bf2:	e8 6a fd ff ff       	call   80105961 <argptr>
80105bf7:	83 c4 10             	add    $0x10,%esp
80105bfa:	85 c0                	test   %eax,%eax
80105bfc:	79 07                	jns    80105c05 <sys_read+0x56>
    return -1;
80105bfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c03:	eb 17                	jmp    80105c1c <sys_read+0x6d>
  return fileread(f, p, n);
80105c05:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c08:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0e:	83 ec 04             	sub    $0x4,%esp
80105c11:	51                   	push   %ecx
80105c12:	52                   	push   %edx
80105c13:	50                   	push   %eax
80105c14:	e8 17 b6 ff ff       	call   80101230 <fileread>
80105c19:	83 c4 10             	add    $0x10,%esp
}
80105c1c:	c9                   	leave
80105c1d:	c3                   	ret

80105c1e <sys_write>:

int
sys_write(void)
{
80105c1e:	f3 0f 1e fb          	endbr32
80105c22:	55                   	push   %ebp
80105c23:	89 e5                	mov    %esp,%ebp
80105c25:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c28:	83 ec 04             	sub    $0x4,%esp
80105c2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c2e:	50                   	push   %eax
80105c2f:	6a 00                	push   $0x0
80105c31:	6a 00                	push   $0x0
80105c33:	e8 52 fe ff ff       	call   80105a8a <argfd>
80105c38:	83 c4 10             	add    $0x10,%esp
80105c3b:	85 c0                	test   %eax,%eax
80105c3d:	78 2e                	js     80105c6d <sys_write+0x4f>
80105c3f:	83 ec 08             	sub    $0x8,%esp
80105c42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c45:	50                   	push   %eax
80105c46:	6a 02                	push   $0x2
80105c48:	e8 e3 fc ff ff       	call   80105930 <argint>
80105c4d:	83 c4 10             	add    $0x10,%esp
80105c50:	85 c0                	test   %eax,%eax
80105c52:	78 19                	js     80105c6d <sys_write+0x4f>
80105c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c57:	83 ec 04             	sub    $0x4,%esp
80105c5a:	50                   	push   %eax
80105c5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c5e:	50                   	push   %eax
80105c5f:	6a 01                	push   $0x1
80105c61:	e8 fb fc ff ff       	call   80105961 <argptr>
80105c66:	83 c4 10             	add    $0x10,%esp
80105c69:	85 c0                	test   %eax,%eax
80105c6b:	79 07                	jns    80105c74 <sys_write+0x56>
    return -1;
80105c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c72:	eb 17                	jmp    80105c8b <sys_write+0x6d>
  return filewrite(f, p, n);
80105c74:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c77:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7d:	83 ec 04             	sub    $0x4,%esp
80105c80:	51                   	push   %ecx
80105c81:	52                   	push   %edx
80105c82:	50                   	push   %eax
80105c83:	e8 64 b6 ff ff       	call   801012ec <filewrite>
80105c88:	83 c4 10             	add    $0x10,%esp
}
80105c8b:	c9                   	leave
80105c8c:	c3                   	ret

80105c8d <sys_close>:

int
sys_close(void)
{
80105c8d:	f3 0f 1e fb          	endbr32
80105c91:	55                   	push   %ebp
80105c92:	89 e5                	mov    %esp,%ebp
80105c94:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c97:	83 ec 04             	sub    $0x4,%esp
80105c9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c9d:	50                   	push   %eax
80105c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ca1:	50                   	push   %eax
80105ca2:	6a 00                	push   $0x0
80105ca4:	e8 e1 fd ff ff       	call   80105a8a <argfd>
80105ca9:	83 c4 10             	add    $0x10,%esp
80105cac:	85 c0                	test   %eax,%eax
80105cae:	79 07                	jns    80105cb7 <sys_close+0x2a>
    return -1;
80105cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb5:	eb 27                	jmp    80105cde <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105cb7:	e8 ed de ff ff       	call   80103ba9 <myproc>
80105cbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cbf:	83 c2 08             	add    $0x8,%edx
80105cc2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cc9:	00 
  fileclose(f);
80105cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccd:	83 ec 0c             	sub    $0xc,%esp
80105cd0:	50                   	push   %eax
80105cd1:	e8 13 b4 ff ff       	call   801010e9 <fileclose>
80105cd6:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cde:	c9                   	leave
80105cdf:	c3                   	ret

80105ce0 <sys_fstat>:

int
sys_fstat(void)
{
80105ce0:	f3 0f 1e fb          	endbr32
80105ce4:	55                   	push   %ebp
80105ce5:	89 e5                	mov    %esp,%ebp
80105ce7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105cea:	83 ec 04             	sub    $0x4,%esp
80105ced:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cf0:	50                   	push   %eax
80105cf1:	6a 00                	push   $0x0
80105cf3:	6a 00                	push   $0x0
80105cf5:	e8 90 fd ff ff       	call   80105a8a <argfd>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	85 c0                	test   %eax,%eax
80105cff:	78 17                	js     80105d18 <sys_fstat+0x38>
80105d01:	83 ec 04             	sub    $0x4,%esp
80105d04:	6a 14                	push   $0x14
80105d06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d09:	50                   	push   %eax
80105d0a:	6a 01                	push   $0x1
80105d0c:	e8 50 fc ff ff       	call   80105961 <argptr>
80105d11:	83 c4 10             	add    $0x10,%esp
80105d14:	85 c0                	test   %eax,%eax
80105d16:	79 07                	jns    80105d1f <sys_fstat+0x3f>
    return -1;
80105d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1d:	eb 13                	jmp    80105d32 <sys_fstat+0x52>
  return filestat(f, st);
80105d1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d25:	83 ec 08             	sub    $0x8,%esp
80105d28:	52                   	push   %edx
80105d29:	50                   	push   %eax
80105d2a:	e8 a6 b4 ff ff       	call   801011d5 <filestat>
80105d2f:	83 c4 10             	add    $0x10,%esp
}
80105d32:	c9                   	leave
80105d33:	c3                   	ret

80105d34 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d34:	f3 0f 1e fb          	endbr32
80105d38:	55                   	push   %ebp
80105d39:	89 e5                	mov    %esp,%ebp
80105d3b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d3e:	83 ec 08             	sub    $0x8,%esp
80105d41:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d44:	50                   	push   %eax
80105d45:	6a 00                	push   $0x0
80105d47:	e8 81 fc ff ff       	call   801059cd <argstr>
80105d4c:	83 c4 10             	add    $0x10,%esp
80105d4f:	85 c0                	test   %eax,%eax
80105d51:	78 15                	js     80105d68 <sys_link+0x34>
80105d53:	83 ec 08             	sub    $0x8,%esp
80105d56:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d59:	50                   	push   %eax
80105d5a:	6a 01                	push   $0x1
80105d5c:	e8 6c fc ff ff       	call   801059cd <argstr>
80105d61:	83 c4 10             	add    $0x10,%esp
80105d64:	85 c0                	test   %eax,%eax
80105d66:	79 0a                	jns    80105d72 <sys_link+0x3e>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	e9 68 01 00 00       	jmp    80105eda <sys_link+0x1a6>

  begin_op();
80105d72:	e8 fa d3 ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105d77:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d7a:	83 ec 0c             	sub    $0xc,%esp
80105d7d:	50                   	push   %eax
80105d7e:	e8 64 c8 ff ff       	call   801025e7 <namei>
80105d83:	83 c4 10             	add    $0x10,%esp
80105d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d8d:	75 0f                	jne    80105d9e <sys_link+0x6a>
    end_op();
80105d8f:	e8 6d d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d99:	e9 3c 01 00 00       	jmp    80105eda <sys_link+0x1a6>
  }

  ilock(ip);
80105d9e:	83 ec 0c             	sub    $0xc,%esp
80105da1:	ff 75 f4             	push   -0xc(%ebp)
80105da4:	e8 d3 bc ff ff       	call   80101a7c <ilock>
80105da9:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105db3:	66 83 f8 01          	cmp    $0x1,%ax
80105db7:	75 1d                	jne    80105dd6 <sys_link+0xa2>
    iunlockput(ip);
80105db9:	83 ec 0c             	sub    $0xc,%esp
80105dbc:	ff 75 f4             	push   -0xc(%ebp)
80105dbf:	e8 f5 be ff ff       	call   80101cb9 <iunlockput>
80105dc4:	83 c4 10             	add    $0x10,%esp
    end_op();
80105dc7:	e8 35 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd1:	e9 04 01 00 00       	jmp    80105eda <sys_link+0x1a6>
  }

  ip->nlink++;
80105dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ddd:	83 c0 01             	add    $0x1,%eax
80105de0:	89 c2                	mov    %eax,%edx
80105de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105de9:	83 ec 0c             	sub    $0xc,%esp
80105dec:	ff 75 f4             	push   -0xc(%ebp)
80105def:	e8 9f ba ff ff       	call   80101893 <iupdate>
80105df4:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105df7:	83 ec 0c             	sub    $0xc,%esp
80105dfa:	ff 75 f4             	push   -0xc(%ebp)
80105dfd:	e8 91 bd ff ff       	call   80101b93 <iunlock>
80105e02:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105e05:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e08:	83 ec 08             	sub    $0x8,%esp
80105e0b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e0e:	52                   	push   %edx
80105e0f:	50                   	push   %eax
80105e10:	e8 f2 c7 ff ff       	call   80102607 <nameiparent>
80105e15:	83 c4 10             	add    $0x10,%esp
80105e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e1f:	74 71                	je     80105e92 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105e21:	83 ec 0c             	sub    $0xc,%esp
80105e24:	ff 75 f0             	push   -0x10(%ebp)
80105e27:	e8 50 bc ff ff       	call   80101a7c <ilock>
80105e2c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e32:	8b 10                	mov    (%eax),%edx
80105e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e37:	8b 00                	mov    (%eax),%eax
80105e39:	39 c2                	cmp    %eax,%edx
80105e3b:	75 1d                	jne    80105e5a <sys_link+0x126>
80105e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e40:	8b 40 04             	mov    0x4(%eax),%eax
80105e43:	83 ec 04             	sub    $0x4,%esp
80105e46:	50                   	push   %eax
80105e47:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e4a:	50                   	push   %eax
80105e4b:	ff 75 f0             	push   -0x10(%ebp)
80105e4e:	e8 f1 c4 ff ff       	call   80102344 <dirlink>
80105e53:	83 c4 10             	add    $0x10,%esp
80105e56:	85 c0                	test   %eax,%eax
80105e58:	79 10                	jns    80105e6a <sys_link+0x136>
    iunlockput(dp);
80105e5a:	83 ec 0c             	sub    $0xc,%esp
80105e5d:	ff 75 f0             	push   -0x10(%ebp)
80105e60:	e8 54 be ff ff       	call   80101cb9 <iunlockput>
80105e65:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e68:	eb 29                	jmp    80105e93 <sys_link+0x15f>
  }
  iunlockput(dp);
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	ff 75 f0             	push   -0x10(%ebp)
80105e70:	e8 44 be ff ff       	call   80101cb9 <iunlockput>
80105e75:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e78:	83 ec 0c             	sub    $0xc,%esp
80105e7b:	ff 75 f4             	push   -0xc(%ebp)
80105e7e:	e8 62 bd ff ff       	call   80101be5 <iput>
80105e83:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e86:	e8 76 d3 ff ff       	call   80103201 <end_op>

  return 0;
80105e8b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e90:	eb 48                	jmp    80105eda <sys_link+0x1a6>
    goto bad;
80105e92:	90                   	nop

bad:
  ilock(ip);
80105e93:	83 ec 0c             	sub    $0xc,%esp
80105e96:	ff 75 f4             	push   -0xc(%ebp)
80105e99:	e8 de bb ff ff       	call   80101a7c <ilock>
80105e9e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ea8:	83 e8 01             	sub    $0x1,%eax
80105eab:	89 c2                	mov    %eax,%edx
80105ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105eb4:	83 ec 0c             	sub    $0xc,%esp
80105eb7:	ff 75 f4             	push   -0xc(%ebp)
80105eba:	e8 d4 b9 ff ff       	call   80101893 <iupdate>
80105ebf:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ec2:	83 ec 0c             	sub    $0xc,%esp
80105ec5:	ff 75 f4             	push   -0xc(%ebp)
80105ec8:	e8 ec bd ff ff       	call   80101cb9 <iunlockput>
80105ecd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ed0:	e8 2c d3 ff ff       	call   80103201 <end_op>
  return -1;
80105ed5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eda:	c9                   	leave
80105edb:	c3                   	ret

80105edc <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105edc:	f3 0f 1e fb          	endbr32
80105ee0:	55                   	push   %ebp
80105ee1:	89 e5                	mov    %esp,%ebp
80105ee3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ee6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105eed:	eb 40                	jmp    80105f2f <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef2:	6a 10                	push   $0x10
80105ef4:	50                   	push   %eax
80105ef5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ef8:	50                   	push   %eax
80105ef9:	ff 75 08             	push   0x8(%ebp)
80105efc:	e8 83 c0 ff ff       	call   80101f84 <readi>
80105f01:	83 c4 10             	add    $0x10,%esp
80105f04:	83 f8 10             	cmp    $0x10,%eax
80105f07:	74 0d                	je     80105f16 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105f09:	83 ec 0c             	sub    $0xc,%esp
80105f0c:	68 91 b4 10 80       	push   $0x8010b491
80105f11:	e8 af a6 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105f16:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f1a:	66 85 c0             	test   %ax,%ax
80105f1d:	74 07                	je     80105f26 <isdirempty+0x4a>
      return 0;
80105f1f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f24:	eb 1b                	jmp    80105f41 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f29:	83 c0 10             	add    $0x10,%eax
80105f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f32:	8b 50 58             	mov    0x58(%eax),%edx
80105f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f38:	39 c2                	cmp    %eax,%edx
80105f3a:	77 b3                	ja     80105eef <isdirempty+0x13>
  }
  return 1;
80105f3c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f41:	c9                   	leave
80105f42:	c3                   	ret

80105f43 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f43:	f3 0f 1e fb          	endbr32
80105f47:	55                   	push   %ebp
80105f48:	89 e5                	mov    %esp,%ebp
80105f4a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f4d:	83 ec 08             	sub    $0x8,%esp
80105f50:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f53:	50                   	push   %eax
80105f54:	6a 00                	push   $0x0
80105f56:	e8 72 fa ff ff       	call   801059cd <argstr>
80105f5b:	83 c4 10             	add    $0x10,%esp
80105f5e:	85 c0                	test   %eax,%eax
80105f60:	79 0a                	jns    80105f6c <sys_unlink+0x29>
    return -1;
80105f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f67:	e9 bf 01 00 00       	jmp    8010612b <sys_unlink+0x1e8>

  begin_op();
80105f6c:	e8 00 d2 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f71:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f74:	83 ec 08             	sub    $0x8,%esp
80105f77:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f7a:	52                   	push   %edx
80105f7b:	50                   	push   %eax
80105f7c:	e8 86 c6 ff ff       	call   80102607 <nameiparent>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f8b:	75 0f                	jne    80105f9c <sys_unlink+0x59>
    end_op();
80105f8d:	e8 6f d2 ff ff       	call   80103201 <end_op>
    return -1;
80105f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f97:	e9 8f 01 00 00       	jmp    8010612b <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	ff 75 f4             	push   -0xc(%ebp)
80105fa2:	e8 d5 ba ff ff       	call   80101a7c <ilock>
80105fa7:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105faa:	83 ec 08             	sub    $0x8,%esp
80105fad:	68 a3 b4 10 80       	push   $0x8010b4a3
80105fb2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fb5:	50                   	push   %eax
80105fb6:	e8 ac c2 ff ff       	call   80102267 <namecmp>
80105fbb:	83 c4 10             	add    $0x10,%esp
80105fbe:	85 c0                	test   %eax,%eax
80105fc0:	0f 84 49 01 00 00    	je     8010610f <sys_unlink+0x1cc>
80105fc6:	83 ec 08             	sub    $0x8,%esp
80105fc9:	68 a5 b4 10 80       	push   $0x8010b4a5
80105fce:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fd1:	50                   	push   %eax
80105fd2:	e8 90 c2 ff ff       	call   80102267 <namecmp>
80105fd7:	83 c4 10             	add    $0x10,%esp
80105fda:	85 c0                	test   %eax,%eax
80105fdc:	0f 84 2d 01 00 00    	je     8010610f <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fe2:	83 ec 04             	sub    $0x4,%esp
80105fe5:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105fe8:	50                   	push   %eax
80105fe9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fec:	50                   	push   %eax
80105fed:	ff 75 f4             	push   -0xc(%ebp)
80105ff0:	e8 91 c2 ff ff       	call   80102286 <dirlookup>
80105ff5:	83 c4 10             	add    $0x10,%esp
80105ff8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ffb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fff:	0f 84 0d 01 00 00    	je     80106112 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80106005:	83 ec 0c             	sub    $0xc,%esp
80106008:	ff 75 f0             	push   -0x10(%ebp)
8010600b:	e8 6c ba ff ff       	call   80101a7c <ilock>
80106010:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106016:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010601a:	66 85 c0             	test   %ax,%ax
8010601d:	7f 0d                	jg     8010602c <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	68 a8 b4 10 80       	push   $0x8010b4a8
80106027:	e8 99 a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010602c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106033:	66 83 f8 01          	cmp    $0x1,%ax
80106037:	75 25                	jne    8010605e <sys_unlink+0x11b>
80106039:	83 ec 0c             	sub    $0xc,%esp
8010603c:	ff 75 f0             	push   -0x10(%ebp)
8010603f:	e8 98 fe ff ff       	call   80105edc <isdirempty>
80106044:	83 c4 10             	add    $0x10,%esp
80106047:	85 c0                	test   %eax,%eax
80106049:	75 13                	jne    8010605e <sys_unlink+0x11b>
    iunlockput(ip);
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	ff 75 f0             	push   -0x10(%ebp)
80106051:	e8 63 bc ff ff       	call   80101cb9 <iunlockput>
80106056:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106059:	e9 b5 00 00 00       	jmp    80106113 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010605e:	83 ec 04             	sub    $0x4,%esp
80106061:	6a 10                	push   $0x10
80106063:	6a 00                	push   $0x0
80106065:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106068:	50                   	push   %eax
80106069:	e8 6e f5 ff ff       	call   801055dc <memset>
8010606e:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106071:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106074:	6a 10                	push   $0x10
80106076:	50                   	push   %eax
80106077:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010607a:	50                   	push   %eax
8010607b:	ff 75 f4             	push   -0xc(%ebp)
8010607e:	e8 5a c0 ff ff       	call   801020dd <writei>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	83 f8 10             	cmp    $0x10,%eax
80106089:	74 0d                	je     80106098 <sys_unlink+0x155>
    panic("unlink: writei");
8010608b:	83 ec 0c             	sub    $0xc,%esp
8010608e:	68 ba b4 10 80       	push   $0x8010b4ba
80106093:	e8 2d a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80106098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010609f:	66 83 f8 01          	cmp    $0x1,%ax
801060a3:	75 21                	jne    801060c6 <sys_unlink+0x183>
    dp->nlink--;
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060ac:	83 e8 01             	sub    $0x1,%eax
801060af:	89 c2                	mov    %eax,%edx
801060b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801060b8:	83 ec 0c             	sub    $0xc,%esp
801060bb:	ff 75 f4             	push   -0xc(%ebp)
801060be:	e8 d0 b7 ff ff       	call   80101893 <iupdate>
801060c3:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	ff 75 f4             	push   -0xc(%ebp)
801060cc:	e8 e8 bb ff ff       	call   80101cb9 <iunlockput>
801060d1:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801060d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060db:	83 e8 01             	sub    $0x1,%eax
801060de:	89 c2                	mov    %eax,%edx
801060e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801060e7:	83 ec 0c             	sub    $0xc,%esp
801060ea:	ff 75 f0             	push   -0x10(%ebp)
801060ed:	e8 a1 b7 ff ff       	call   80101893 <iupdate>
801060f2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060f5:	83 ec 0c             	sub    $0xc,%esp
801060f8:	ff 75 f0             	push   -0x10(%ebp)
801060fb:	e8 b9 bb ff ff       	call   80101cb9 <iunlockput>
80106100:	83 c4 10             	add    $0x10,%esp

  end_op();
80106103:	e8 f9 d0 ff ff       	call   80103201 <end_op>

  return 0;
80106108:	b8 00 00 00 00       	mov    $0x0,%eax
8010610d:	eb 1c                	jmp    8010612b <sys_unlink+0x1e8>
    goto bad;
8010610f:	90                   	nop
80106110:	eb 01                	jmp    80106113 <sys_unlink+0x1d0>
    goto bad;
80106112:	90                   	nop

bad:
  iunlockput(dp);
80106113:	83 ec 0c             	sub    $0xc,%esp
80106116:	ff 75 f4             	push   -0xc(%ebp)
80106119:	e8 9b bb ff ff       	call   80101cb9 <iunlockput>
8010611e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106121:	e8 db d0 ff ff       	call   80103201 <end_op>
  return -1;
80106126:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010612b:	c9                   	leave
8010612c:	c3                   	ret

8010612d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010612d:	f3 0f 1e fb          	endbr32
80106131:	55                   	push   %ebp
80106132:	89 e5                	mov    %esp,%ebp
80106134:	83 ec 38             	sub    $0x38,%esp
80106137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010613a:	8b 55 10             	mov    0x10(%ebp),%edx
8010613d:	8b 45 14             	mov    0x14(%ebp),%eax
80106140:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106144:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106148:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010614c:	83 ec 08             	sub    $0x8,%esp
8010614f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106152:	50                   	push   %eax
80106153:	ff 75 08             	push   0x8(%ebp)
80106156:	e8 ac c4 ff ff       	call   80102607 <nameiparent>
8010615b:	83 c4 10             	add    $0x10,%esp
8010615e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106161:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106165:	75 0a                	jne    80106171 <create+0x44>
    return 0;
80106167:	b8 00 00 00 00       	mov    $0x0,%eax
8010616c:	e9 90 01 00 00       	jmp    80106301 <create+0x1d4>
  ilock(dp);
80106171:	83 ec 0c             	sub    $0xc,%esp
80106174:	ff 75 f4             	push   -0xc(%ebp)
80106177:	e8 00 b9 ff ff       	call   80101a7c <ilock>
8010617c:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010617f:	83 ec 04             	sub    $0x4,%esp
80106182:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106185:	50                   	push   %eax
80106186:	8d 45 de             	lea    -0x22(%ebp),%eax
80106189:	50                   	push   %eax
8010618a:	ff 75 f4             	push   -0xc(%ebp)
8010618d:	e8 f4 c0 ff ff       	call   80102286 <dirlookup>
80106192:	83 c4 10             	add    $0x10,%esp
80106195:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106198:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619c:	74 50                	je     801061ee <create+0xc1>
    iunlockput(dp);
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	ff 75 f4             	push   -0xc(%ebp)
801061a4:	e8 10 bb ff ff       	call   80101cb9 <iunlockput>
801061a9:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801061ac:	83 ec 0c             	sub    $0xc,%esp
801061af:	ff 75 f0             	push   -0x10(%ebp)
801061b2:	e8 c5 b8 ff ff       	call   80101a7c <ilock>
801061b7:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801061ba:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061bf:	75 15                	jne    801061d6 <create+0xa9>
801061c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061c8:	66 83 f8 02          	cmp    $0x2,%ax
801061cc:	75 08                	jne    801061d6 <create+0xa9>
      return ip;
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	e9 2b 01 00 00       	jmp    80106301 <create+0x1d4>
    iunlockput(ip);
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	ff 75 f0             	push   -0x10(%ebp)
801061dc:	e8 d8 ba ff ff       	call   80101cb9 <iunlockput>
801061e1:	83 c4 10             	add    $0x10,%esp
    return 0;
801061e4:	b8 00 00 00 00       	mov    $0x0,%eax
801061e9:	e9 13 01 00 00       	jmp    80106301 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061ee:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f5:	8b 00                	mov    (%eax),%eax
801061f7:	83 ec 08             	sub    $0x8,%esp
801061fa:	52                   	push   %edx
801061fb:	50                   	push   %eax
801061fc:	e8 b7 b5 ff ff       	call   801017b8 <ialloc>
80106201:	83 c4 10             	add    $0x10,%esp
80106204:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106207:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620b:	75 0d                	jne    8010621a <create+0xed>
    panic("create: ialloc");
8010620d:	83 ec 0c             	sub    $0xc,%esp
80106210:	68 c9 b4 10 80       	push   $0x8010b4c9
80106215:	e8 ab a3 ff ff       	call   801005c5 <panic>

  ilock(ip);
8010621a:	83 ec 0c             	sub    $0xc,%esp
8010621d:	ff 75 f0             	push   -0x10(%ebp)
80106220:	e8 57 b8 ff ff       	call   80101a7c <ilock>
80106225:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010622f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106236:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010623a:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010623e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106241:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106247:	83 ec 0c             	sub    $0xc,%esp
8010624a:	ff 75 f0             	push   -0x10(%ebp)
8010624d:	e8 41 b6 ff ff       	call   80101893 <iupdate>
80106252:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106255:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010625a:	75 6a                	jne    801062c6 <create+0x199>
    dp->nlink++;  // for ".."
8010625c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106263:	83 c0 01             	add    $0x1,%eax
80106266:	89 c2                	mov    %eax,%edx
80106268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010626f:	83 ec 0c             	sub    $0xc,%esp
80106272:	ff 75 f4             	push   -0xc(%ebp)
80106275:	e8 19 b6 ff ff       	call   80101893 <iupdate>
8010627a:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010627d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106280:	8b 40 04             	mov    0x4(%eax),%eax
80106283:	83 ec 04             	sub    $0x4,%esp
80106286:	50                   	push   %eax
80106287:	68 a3 b4 10 80       	push   $0x8010b4a3
8010628c:	ff 75 f0             	push   -0x10(%ebp)
8010628f:	e8 b0 c0 ff ff       	call   80102344 <dirlink>
80106294:	83 c4 10             	add    $0x10,%esp
80106297:	85 c0                	test   %eax,%eax
80106299:	78 1e                	js     801062b9 <create+0x18c>
8010629b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629e:	8b 40 04             	mov    0x4(%eax),%eax
801062a1:	83 ec 04             	sub    $0x4,%esp
801062a4:	50                   	push   %eax
801062a5:	68 a5 b4 10 80       	push   $0x8010b4a5
801062aa:	ff 75 f0             	push   -0x10(%ebp)
801062ad:	e8 92 c0 ff ff       	call   80102344 <dirlink>
801062b2:	83 c4 10             	add    $0x10,%esp
801062b5:	85 c0                	test   %eax,%eax
801062b7:	79 0d                	jns    801062c6 <create+0x199>
      panic("create dots");
801062b9:	83 ec 0c             	sub    $0xc,%esp
801062bc:	68 d8 b4 10 80       	push   $0x8010b4d8
801062c1:	e8 ff a2 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c9:	8b 40 04             	mov    0x4(%eax),%eax
801062cc:	83 ec 04             	sub    $0x4,%esp
801062cf:	50                   	push   %eax
801062d0:	8d 45 de             	lea    -0x22(%ebp),%eax
801062d3:	50                   	push   %eax
801062d4:	ff 75 f4             	push   -0xc(%ebp)
801062d7:	e8 68 c0 ff ff       	call   80102344 <dirlink>
801062dc:	83 c4 10             	add    $0x10,%esp
801062df:	85 c0                	test   %eax,%eax
801062e1:	79 0d                	jns    801062f0 <create+0x1c3>
    panic("create: dirlink");
801062e3:	83 ec 0c             	sub    $0xc,%esp
801062e6:	68 e4 b4 10 80       	push   $0x8010b4e4
801062eb:	e8 d5 a2 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
801062f0:	83 ec 0c             	sub    $0xc,%esp
801062f3:	ff 75 f4             	push   -0xc(%ebp)
801062f6:	e8 be b9 ff ff       	call   80101cb9 <iunlockput>
801062fb:	83 c4 10             	add    $0x10,%esp

  return ip;
801062fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106301:	c9                   	leave
80106302:	c3                   	ret

80106303 <sys_open>:

int
sys_open(void)
{
80106303:	f3 0f 1e fb          	endbr32
80106307:	55                   	push   %ebp
80106308:	89 e5                	mov    %esp,%ebp
8010630a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010630d:	83 ec 08             	sub    $0x8,%esp
80106310:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106313:	50                   	push   %eax
80106314:	6a 00                	push   $0x0
80106316:	e8 b2 f6 ff ff       	call   801059cd <argstr>
8010631b:	83 c4 10             	add    $0x10,%esp
8010631e:	85 c0                	test   %eax,%eax
80106320:	78 15                	js     80106337 <sys_open+0x34>
80106322:	83 ec 08             	sub    $0x8,%esp
80106325:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106328:	50                   	push   %eax
80106329:	6a 01                	push   $0x1
8010632b:	e8 00 f6 ff ff       	call   80105930 <argint>
80106330:	83 c4 10             	add    $0x10,%esp
80106333:	85 c0                	test   %eax,%eax
80106335:	79 0a                	jns    80106341 <sys_open+0x3e>
    return -1;
80106337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633c:	e9 61 01 00 00       	jmp    801064a2 <sys_open+0x19f>

  begin_op();
80106341:	e8 2b ce ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80106346:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106349:	25 00 02 00 00       	and    $0x200,%eax
8010634e:	85 c0                	test   %eax,%eax
80106350:	74 2a                	je     8010637c <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106352:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106355:	6a 00                	push   $0x0
80106357:	6a 00                	push   $0x0
80106359:	6a 02                	push   $0x2
8010635b:	50                   	push   %eax
8010635c:	e8 cc fd ff ff       	call   8010612d <create>
80106361:	83 c4 10             	add    $0x10,%esp
80106364:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106367:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010636b:	75 75                	jne    801063e2 <sys_open+0xdf>
      end_op();
8010636d:	e8 8f ce ff ff       	call   80103201 <end_op>
      return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	e9 26 01 00 00       	jmp    801064a2 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
8010637c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010637f:	83 ec 0c             	sub    $0xc,%esp
80106382:	50                   	push   %eax
80106383:	e8 5f c2 ff ff       	call   801025e7 <namei>
80106388:	83 c4 10             	add    $0x10,%esp
8010638b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010638e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106392:	75 0f                	jne    801063a3 <sys_open+0xa0>
      end_op();
80106394:	e8 68 ce ff ff       	call   80103201 <end_op>
      return -1;
80106399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639e:	e9 ff 00 00 00       	jmp    801064a2 <sys_open+0x19f>
    }
    ilock(ip);
801063a3:	83 ec 0c             	sub    $0xc,%esp
801063a6:	ff 75 f4             	push   -0xc(%ebp)
801063a9:	e8 ce b6 ff ff       	call   80101a7c <ilock>
801063ae:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801063b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801063b8:	66 83 f8 01          	cmp    $0x1,%ax
801063bc:	75 24                	jne    801063e2 <sys_open+0xdf>
801063be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c1:	85 c0                	test   %eax,%eax
801063c3:	74 1d                	je     801063e2 <sys_open+0xdf>
      iunlockput(ip);
801063c5:	83 ec 0c             	sub    $0xc,%esp
801063c8:	ff 75 f4             	push   -0xc(%ebp)
801063cb:	e8 e9 b8 ff ff       	call   80101cb9 <iunlockput>
801063d0:	83 c4 10             	add    $0x10,%esp
      end_op();
801063d3:	e8 29 ce ff ff       	call   80103201 <end_op>
      return -1;
801063d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063dd:	e9 c0 00 00 00       	jmp    801064a2 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063e2:	e8 3c ac ff ff       	call   80101023 <filealloc>
801063e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ee:	74 17                	je     80106407 <sys_open+0x104>
801063f0:	83 ec 0c             	sub    $0xc,%esp
801063f3:	ff 75 f0             	push   -0x10(%ebp)
801063f6:	e8 07 f7 ff ff       	call   80105b02 <fdalloc>
801063fb:	83 c4 10             	add    $0x10,%esp
801063fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106401:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106405:	79 2e                	jns    80106435 <sys_open+0x132>
    if(f)
80106407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010640b:	74 0e                	je     8010641b <sys_open+0x118>
      fileclose(f);
8010640d:	83 ec 0c             	sub    $0xc,%esp
80106410:	ff 75 f0             	push   -0x10(%ebp)
80106413:	e8 d1 ac ff ff       	call   801010e9 <fileclose>
80106418:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010641b:	83 ec 0c             	sub    $0xc,%esp
8010641e:	ff 75 f4             	push   -0xc(%ebp)
80106421:	e8 93 b8 ff ff       	call   80101cb9 <iunlockput>
80106426:	83 c4 10             	add    $0x10,%esp
    end_op();
80106429:	e8 d3 cd ff ff       	call   80103201 <end_op>
    return -1;
8010642e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106433:	eb 6d                	jmp    801064a2 <sys_open+0x19f>
  }
  iunlock(ip);
80106435:	83 ec 0c             	sub    $0xc,%esp
80106438:	ff 75 f4             	push   -0xc(%ebp)
8010643b:	e8 53 b7 ff ff       	call   80101b93 <iunlock>
80106440:	83 c4 10             	add    $0x10,%esp
  end_op();
80106443:	e8 b9 cd ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80106448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106454:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106457:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010645a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106467:	83 e0 01             	and    $0x1,%eax
8010646a:	85 c0                	test   %eax,%eax
8010646c:	0f 94 c0             	sete   %al
8010646f:	89 c2                	mov    %eax,%edx
80106471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106474:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647a:	83 e0 01             	and    $0x1,%eax
8010647d:	85 c0                	test   %eax,%eax
8010647f:	75 0a                	jne    8010648b <sys_open+0x188>
80106481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106484:	83 e0 02             	and    $0x2,%eax
80106487:	85 c0                	test   %eax,%eax
80106489:	74 07                	je     80106492 <sys_open+0x18f>
8010648b:	b8 01 00 00 00       	mov    $0x1,%eax
80106490:	eb 05                	jmp    80106497 <sys_open+0x194>
80106492:	b8 00 00 00 00       	mov    $0x0,%eax
80106497:	89 c2                	mov    %eax,%edx
80106499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010649f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064a2:	c9                   	leave
801064a3:	c3                   	ret

801064a4 <sys_mkdir>:

int
sys_mkdir(void)
{
801064a4:	f3 0f 1e fb          	endbr32
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064ae:	e8 be cc ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064b3:	83 ec 08             	sub    $0x8,%esp
801064b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b9:	50                   	push   %eax
801064ba:	6a 00                	push   $0x0
801064bc:	e8 0c f5 ff ff       	call   801059cd <argstr>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	85 c0                	test   %eax,%eax
801064c6:	78 1b                	js     801064e3 <sys_mkdir+0x3f>
801064c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cb:	6a 00                	push   $0x0
801064cd:	6a 00                	push   $0x0
801064cf:	6a 01                	push   $0x1
801064d1:	50                   	push   %eax
801064d2:	e8 56 fc ff ff       	call   8010612d <create>
801064d7:	83 c4 10             	add    $0x10,%esp
801064da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e1:	75 0c                	jne    801064ef <sys_mkdir+0x4b>
    end_op();
801064e3:	e8 19 cd ff ff       	call   80103201 <end_op>
    return -1;
801064e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ed:	eb 18                	jmp    80106507 <sys_mkdir+0x63>
  }
  iunlockput(ip);
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	ff 75 f4             	push   -0xc(%ebp)
801064f5:	e8 bf b7 ff ff       	call   80101cb9 <iunlockput>
801064fa:	83 c4 10             	add    $0x10,%esp
  end_op();
801064fd:	e8 ff cc ff ff       	call   80103201 <end_op>
  return 0;
80106502:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106507:	c9                   	leave
80106508:	c3                   	ret

80106509 <sys_mknod>:

int
sys_mknod(void)
{
80106509:	f3 0f 1e fb          	endbr32
8010650d:	55                   	push   %ebp
8010650e:	89 e5                	mov    %esp,%ebp
80106510:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106513:	e8 59 cc ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106518:	83 ec 08             	sub    $0x8,%esp
8010651b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010651e:	50                   	push   %eax
8010651f:	6a 00                	push   $0x0
80106521:	e8 a7 f4 ff ff       	call   801059cd <argstr>
80106526:	83 c4 10             	add    $0x10,%esp
80106529:	85 c0                	test   %eax,%eax
8010652b:	78 4f                	js     8010657c <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010652d:	83 ec 08             	sub    $0x8,%esp
80106530:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106533:	50                   	push   %eax
80106534:	6a 01                	push   $0x1
80106536:	e8 f5 f3 ff ff       	call   80105930 <argint>
8010653b:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010653e:	85 c0                	test   %eax,%eax
80106540:	78 3a                	js     8010657c <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106542:	83 ec 08             	sub    $0x8,%esp
80106545:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106548:	50                   	push   %eax
80106549:	6a 02                	push   $0x2
8010654b:	e8 e0 f3 ff ff       	call   80105930 <argint>
80106550:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106553:	85 c0                	test   %eax,%eax
80106555:	78 25                	js     8010657c <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106557:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010655a:	0f bf c8             	movswl %ax,%ecx
8010655d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106560:	0f bf d0             	movswl %ax,%edx
80106563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106566:	51                   	push   %ecx
80106567:	52                   	push   %edx
80106568:	6a 03                	push   $0x3
8010656a:	50                   	push   %eax
8010656b:	e8 bd fb ff ff       	call   8010612d <create>
80106570:	83 c4 10             	add    $0x10,%esp
80106573:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106576:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010657a:	75 0c                	jne    80106588 <sys_mknod+0x7f>
    end_op();
8010657c:	e8 80 cc ff ff       	call   80103201 <end_op>
    return -1;
80106581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106586:	eb 18                	jmp    801065a0 <sys_mknod+0x97>
  }
  iunlockput(ip);
80106588:	83 ec 0c             	sub    $0xc,%esp
8010658b:	ff 75 f4             	push   -0xc(%ebp)
8010658e:	e8 26 b7 ff ff       	call   80101cb9 <iunlockput>
80106593:	83 c4 10             	add    $0x10,%esp
  end_op();
80106596:	e8 66 cc ff ff       	call   80103201 <end_op>
  return 0;
8010659b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065a0:	c9                   	leave
801065a1:	c3                   	ret

801065a2 <sys_chdir>:

int
sys_chdir(void)
{
801065a2:	f3 0f 1e fb          	endbr32
801065a6:	55                   	push   %ebp
801065a7:	89 e5                	mov    %esp,%ebp
801065a9:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801065ac:	e8 f8 d5 ff ff       	call   80103ba9 <myproc>
801065b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801065b4:	e8 b8 cb ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065b9:	83 ec 08             	sub    $0x8,%esp
801065bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065bf:	50                   	push   %eax
801065c0:	6a 00                	push   $0x0
801065c2:	e8 06 f4 ff ff       	call   801059cd <argstr>
801065c7:	83 c4 10             	add    $0x10,%esp
801065ca:	85 c0                	test   %eax,%eax
801065cc:	78 18                	js     801065e6 <sys_chdir+0x44>
801065ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065d1:	83 ec 0c             	sub    $0xc,%esp
801065d4:	50                   	push   %eax
801065d5:	e8 0d c0 ff ff       	call   801025e7 <namei>
801065da:	83 c4 10             	add    $0x10,%esp
801065dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065e4:	75 0c                	jne    801065f2 <sys_chdir+0x50>
    end_op();
801065e6:	e8 16 cc ff ff       	call   80103201 <end_op>
    return -1;
801065eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f0:	eb 68                	jmp    8010665a <sys_chdir+0xb8>
  }
  ilock(ip);
801065f2:	83 ec 0c             	sub    $0xc,%esp
801065f5:	ff 75 f0             	push   -0x10(%ebp)
801065f8:	e8 7f b4 ff ff       	call   80101a7c <ilock>
801065fd:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106603:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106607:	66 83 f8 01          	cmp    $0x1,%ax
8010660b:	74 1a                	je     80106627 <sys_chdir+0x85>
    iunlockput(ip);
8010660d:	83 ec 0c             	sub    $0xc,%esp
80106610:	ff 75 f0             	push   -0x10(%ebp)
80106613:	e8 a1 b6 ff ff       	call   80101cb9 <iunlockput>
80106618:	83 c4 10             	add    $0x10,%esp
    end_op();
8010661b:	e8 e1 cb ff ff       	call   80103201 <end_op>
    return -1;
80106620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106625:	eb 33                	jmp    8010665a <sys_chdir+0xb8>
  }
  iunlock(ip);
80106627:	83 ec 0c             	sub    $0xc,%esp
8010662a:	ff 75 f0             	push   -0x10(%ebp)
8010662d:	e8 61 b5 ff ff       	call   80101b93 <iunlock>
80106632:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106638:	8b 40 68             	mov    0x68(%eax),%eax
8010663b:	83 ec 0c             	sub    $0xc,%esp
8010663e:	50                   	push   %eax
8010663f:	e8 a1 b5 ff ff       	call   80101be5 <iput>
80106644:	83 c4 10             	add    $0x10,%esp
  end_op();
80106647:	e8 b5 cb ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
8010664c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106652:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106655:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010665a:	c9                   	leave
8010665b:	c3                   	ret

8010665c <sys_exec>:

int
sys_exec(void)
{
8010665c:	f3 0f 1e fb          	endbr32
80106660:	55                   	push   %ebp
80106661:	89 e5                	mov    %esp,%ebp
80106663:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106669:	83 ec 08             	sub    $0x8,%esp
8010666c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010666f:	50                   	push   %eax
80106670:	6a 00                	push   $0x0
80106672:	e8 56 f3 ff ff       	call   801059cd <argstr>
80106677:	83 c4 10             	add    $0x10,%esp
8010667a:	85 c0                	test   %eax,%eax
8010667c:	78 18                	js     80106696 <sys_exec+0x3a>
8010667e:	83 ec 08             	sub    $0x8,%esp
80106681:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106687:	50                   	push   %eax
80106688:	6a 01                	push   $0x1
8010668a:	e8 a1 f2 ff ff       	call   80105930 <argint>
8010668f:	83 c4 10             	add    $0x10,%esp
80106692:	85 c0                	test   %eax,%eax
80106694:	79 0a                	jns    801066a0 <sys_exec+0x44>
    return -1;
80106696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010669b:	e9 c6 00 00 00       	jmp    80106766 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801066a0:	83 ec 04             	sub    $0x4,%esp
801066a3:	68 80 00 00 00       	push   $0x80
801066a8:	6a 00                	push   $0x0
801066aa:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066b0:	50                   	push   %eax
801066b1:	e8 26 ef ff ff       	call   801055dc <memset>
801066b6:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801066b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c3:	83 f8 1f             	cmp    $0x1f,%eax
801066c6:	76 0a                	jbe    801066d2 <sys_exec+0x76>
      return -1;
801066c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cd:	e9 94 00 00 00       	jmp    80106766 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d5:	c1 e0 02             	shl    $0x2,%eax
801066d8:	89 c2                	mov    %eax,%edx
801066da:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066e0:	01 c2                	add    %eax,%edx
801066e2:	83 ec 08             	sub    $0x8,%esp
801066e5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066eb:	50                   	push   %eax
801066ec:	52                   	push   %edx
801066ed:	e8 93 f1 ff ff       	call   80105885 <fetchint>
801066f2:	83 c4 10             	add    $0x10,%esp
801066f5:	85 c0                	test   %eax,%eax
801066f7:	79 07                	jns    80106700 <sys_exec+0xa4>
      return -1;
801066f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fe:	eb 66                	jmp    80106766 <sys_exec+0x10a>
    if(uarg == 0){
80106700:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106706:	85 c0                	test   %eax,%eax
80106708:	75 27                	jne    80106731 <sys_exec+0xd5>
      argv[i] = 0;
8010670a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106714:	00 00 00 00 
      break;
80106718:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010671c:	83 ec 08             	sub    $0x8,%esp
8010671f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106725:	52                   	push   %edx
80106726:	50                   	push   %eax
80106727:	e8 92 a4 ff ff       	call   80100bbe <exec>
8010672c:	83 c4 10             	add    $0x10,%esp
8010672f:	eb 35                	jmp    80106766 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106731:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106737:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010673a:	c1 e2 02             	shl    $0x2,%edx
8010673d:	01 c2                	add    %eax,%edx
8010673f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106745:	83 ec 08             	sub    $0x8,%esp
80106748:	52                   	push   %edx
80106749:	50                   	push   %eax
8010674a:	e8 79 f1 ff ff       	call   801058c8 <fetchstr>
8010674f:	83 c4 10             	add    $0x10,%esp
80106752:	85 c0                	test   %eax,%eax
80106754:	79 07                	jns    8010675d <sys_exec+0x101>
      return -1;
80106756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675b:	eb 09                	jmp    80106766 <sys_exec+0x10a>
  for(i=0;; i++){
8010675d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106761:	e9 5a ff ff ff       	jmp    801066c0 <sys_exec+0x64>
}
80106766:	c9                   	leave
80106767:	c3                   	ret

80106768 <sys_pipe>:

int
sys_pipe(void)
{
80106768:	f3 0f 1e fb          	endbr32
8010676c:	55                   	push   %ebp
8010676d:	89 e5                	mov    %esp,%ebp
8010676f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106772:	83 ec 04             	sub    $0x4,%esp
80106775:	6a 08                	push   $0x8
80106777:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010677a:	50                   	push   %eax
8010677b:	6a 00                	push   $0x0
8010677d:	e8 df f1 ff ff       	call   80105961 <argptr>
80106782:	83 c4 10             	add    $0x10,%esp
80106785:	85 c0                	test   %eax,%eax
80106787:	79 0a                	jns    80106793 <sys_pipe+0x2b>
    return -1;
80106789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678e:	e9 ae 00 00 00       	jmp    80106841 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106793:	83 ec 08             	sub    $0x8,%esp
80106796:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106799:	50                   	push   %eax
8010679a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010679d:	50                   	push   %eax
8010679e:	e8 27 cf ff ff       	call   801036ca <pipealloc>
801067a3:	83 c4 10             	add    $0x10,%esp
801067a6:	85 c0                	test   %eax,%eax
801067a8:	79 0a                	jns    801067b4 <sys_pipe+0x4c>
    return -1;
801067aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067af:	e9 8d 00 00 00       	jmp    80106841 <sys_pipe+0xd9>
  fd0 = -1;
801067b4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067be:	83 ec 0c             	sub    $0xc,%esp
801067c1:	50                   	push   %eax
801067c2:	e8 3b f3 ff ff       	call   80105b02 <fdalloc>
801067c7:	83 c4 10             	add    $0x10,%esp
801067ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d1:	78 18                	js     801067eb <sys_pipe+0x83>
801067d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d6:	83 ec 0c             	sub    $0xc,%esp
801067d9:	50                   	push   %eax
801067da:	e8 23 f3 ff ff       	call   80105b02 <fdalloc>
801067df:	83 c4 10             	add    $0x10,%esp
801067e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067e9:	79 3e                	jns    80106829 <sys_pipe+0xc1>
    if(fd0 >= 0)
801067eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ef:	78 13                	js     80106804 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801067f1:	e8 b3 d3 ff ff       	call   80103ba9 <myproc>
801067f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067f9:	83 c2 08             	add    $0x8,%edx
801067fc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106803:	00 
    fileclose(rf);
80106804:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106807:	83 ec 0c             	sub    $0xc,%esp
8010680a:	50                   	push   %eax
8010680b:	e8 d9 a8 ff ff       	call   801010e9 <fileclose>
80106810:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106813:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106816:	83 ec 0c             	sub    $0xc,%esp
80106819:	50                   	push   %eax
8010681a:	e8 ca a8 ff ff       	call   801010e9 <fileclose>
8010681f:	83 c4 10             	add    $0x10,%esp
    return -1;
80106822:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106827:	eb 18                	jmp    80106841 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106829:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010682c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010682f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106831:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106834:	8d 50 04             	lea    0x4(%eax),%edx
80106837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010683a:	89 02                	mov    %eax,(%edx)
  return 0;
8010683c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106841:	c9                   	leave
80106842:	c3                   	ret

80106843 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
80106843:	f3 0f 1e fb          	endbr32
80106847:	55                   	push   %ebp
80106848:	89 e5                	mov    %esp,%ebp
8010684a:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
8010684d:	83 ec 04             	sub    $0x4,%esp
80106850:	68 00 0c 00 00       	push   $0xc00
80106855:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106858:	50                   	push   %eax
80106859:	6a 00                	push   $0x0
8010685b:	e8 01 f1 ff ff       	call   80105961 <argptr>
80106860:	83 c4 10             	add    $0x10,%esp
80106863:	85 c0                	test   %eax,%eax
80106865:	79 07                	jns    8010686e <sys_getpinfo+0x2b>
    return -1;
80106867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686c:	eb 0f                	jmp    8010687d <sys_getpinfo+0x3a>
  return getpinfo(ps);
8010686e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106871:	83 ec 0c             	sub    $0xc,%esp
80106874:	50                   	push   %eax
80106875:	e8 c1 e0 ff ff       	call   8010493b <getpinfo>
8010687a:	83 c4 10             	add    $0x10,%esp
}
8010687d:	c9                   	leave
8010687e:	c3                   	ret

8010687f <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
8010687f:	f3 0f 1e fb          	endbr32
80106883:	55                   	push   %ebp
80106884:	89 e5                	mov    %esp,%ebp
80106886:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
80106889:	83 ec 08             	sub    $0x8,%esp
8010688c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010688f:	50                   	push   %eax
80106890:	6a 00                	push   $0x0
80106892:	e8 99 f0 ff ff       	call   80105930 <argint>
80106897:	83 c4 10             	add    $0x10,%esp
8010689a:	85 c0                	test   %eax,%eax
8010689c:	79 07                	jns    801068a5 <sys_setSchedPolicy+0x26>
    return -1;
8010689e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a3:	eb 23                	jmp    801068c8 <sys_setSchedPolicy+0x49>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
801068a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a8:	83 ec 08             	sub    $0x8,%esp
801068ab:	50                   	push   %eax
801068ac:	68 f4 b4 10 80       	push   $0x8010b4f4
801068b1:	e8 56 9b ff ff       	call   8010040c <cprintf>
801068b6:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
801068b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068bc:	83 ec 0c             	sub    $0xc,%esp
801068bf:	50                   	push   %eax
801068c0:	e8 52 e2 ff ff       	call   80104b17 <set_sched_policy>
801068c5:	83 c4 10             	add    $0x10,%esp
}
801068c8:	c9                   	leave
801068c9:	c3                   	ret

801068ca <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
801068ca:	f3 0f 1e fb          	endbr32
801068ce:	55                   	push   %ebp
801068cf:	89 e5                	mov    %esp,%ebp
801068d1:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
801068d4:	e8 85 e2 ff ff       	call   80104b5e <get_sched_policy>
}
801068d9:	c9                   	leave
801068da:	c3                   	ret

801068db <sys_yield>:
int
sys_yield(void)
{
801068db:	f3 0f 1e fb          	endbr32
801068df:	55                   	push   %ebp
801068e0:	89 e5                	mov    %esp,%ebp
801068e2:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
801068e5:	e8 19 dd ff ff       	call   80104603 <yield>
  return 0;
801068ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068ef:	c9                   	leave
801068f0:	c3                   	ret

801068f1 <sys_fork>:

int
sys_fork(void)
{
801068f1:	f3 0f 1e fb          	endbr32
801068f5:	55                   	push   %ebp
801068f6:	89 e5                	mov    %esp,%ebp
801068f8:	83 ec 08             	sub    $0x8,%esp
  return fork();
801068fb:	e8 79 d6 ff ff       	call   80103f79 <fork>
}
80106900:	c9                   	leave
80106901:	c3                   	ret

80106902 <sys_exit>:

int
sys_exit(void)
{
80106902:	f3 0f 1e fb          	endbr32
80106906:	55                   	push   %ebp
80106907:	89 e5                	mov    %esp,%ebp
80106909:	83 ec 08             	sub    $0x8,%esp
  exit();
8010690c:	e8 67 d8 ff ff       	call   80104178 <exit>
  return 0;  // not reached
80106911:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106916:	c9                   	leave
80106917:	c3                   	ret

80106918 <sys_wait>:

int
sys_wait(void)
{
80106918:	f3 0f 1e fb          	endbr32
8010691c:	55                   	push   %ebp
8010691d:	89 e5                	mov    %esp,%ebp
8010691f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106922:	e8 d5 d9 ff ff       	call   801042fc <wait>
}
80106927:	c9                   	leave
80106928:	c3                   	ret

80106929 <sys_kill>:

int
sys_kill(void)
{
80106929:	f3 0f 1e fb          	endbr32
8010692d:	55                   	push   %ebp
8010692e:	89 e5                	mov    %esp,%ebp
80106930:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106933:	83 ec 08             	sub    $0x8,%esp
80106936:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106939:	50                   	push   %eax
8010693a:	6a 00                	push   $0x0
8010693c:	e8 ef ef ff ff       	call   80105930 <argint>
80106941:	83 c4 10             	add    $0x10,%esp
80106944:	85 c0                	test   %eax,%eax
80106946:	79 07                	jns    8010694f <sys_kill+0x26>
    return -1;
80106948:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694d:	eb 0f                	jmp    8010695e <sys_kill+0x35>
  return kill(pid);
8010694f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106952:	83 ec 0c             	sub    $0xc,%esp
80106955:	50                   	push   %eax
80106956:	e8 5a de ff ff       	call   801047b5 <kill>
8010695b:	83 c4 10             	add    $0x10,%esp
}
8010695e:	c9                   	leave
8010695f:	c3                   	ret

80106960 <sys_getpid>:

int
sys_getpid(void)
{
80106960:	f3 0f 1e fb          	endbr32
80106964:	55                   	push   %ebp
80106965:	89 e5                	mov    %esp,%ebp
80106967:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010696a:	e8 3a d2 ff ff       	call   80103ba9 <myproc>
8010696f:	8b 40 10             	mov    0x10(%eax),%eax
}
80106972:	c9                   	leave
80106973:	c3                   	ret

80106974 <sys_sbrk>:

int
sys_sbrk(void)
{
80106974:	f3 0f 1e fb          	endbr32
80106978:	55                   	push   %ebp
80106979:	89 e5                	mov    %esp,%ebp
8010697b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010697e:	83 ec 08             	sub    $0x8,%esp
80106981:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106984:	50                   	push   %eax
80106985:	6a 00                	push   $0x0
80106987:	e8 a4 ef ff ff       	call   80105930 <argint>
8010698c:	83 c4 10             	add    $0x10,%esp
8010698f:	85 c0                	test   %eax,%eax
80106991:	79 07                	jns    8010699a <sys_sbrk+0x26>
    return -1;
80106993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106998:	eb 27                	jmp    801069c1 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010699a:	e8 0a d2 ff ff       	call   80103ba9 <myproc>
8010699f:	8b 00                	mov    (%eax),%eax
801069a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801069a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a7:	83 ec 0c             	sub    $0xc,%esp
801069aa:	50                   	push   %eax
801069ab:	e8 2a d5 ff ff       	call   80103eda <growproc>
801069b0:	83 c4 10             	add    $0x10,%esp
801069b3:	85 c0                	test   %eax,%eax
801069b5:	79 07                	jns    801069be <sys_sbrk+0x4a>
    return -1;
801069b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bc:	eb 03                	jmp    801069c1 <sys_sbrk+0x4d>
  return addr;
801069be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069c1:	c9                   	leave
801069c2:	c3                   	ret

801069c3 <sys_sleep>:

int
sys_sleep(void)
{
801069c3:	f3 0f 1e fb          	endbr32
801069c7:	55                   	push   %ebp
801069c8:	89 e5                	mov    %esp,%ebp
801069ca:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801069cd:	83 ec 08             	sub    $0x8,%esp
801069d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069d3:	50                   	push   %eax
801069d4:	6a 00                	push   $0x0
801069d6:	e8 55 ef ff ff       	call   80105930 <argint>
801069db:	83 c4 10             	add    $0x10,%esp
801069de:	85 c0                	test   %eax,%eax
801069e0:	79 07                	jns    801069e9 <sys_sleep+0x26>
    return -1;
801069e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e7:	eb 76                	jmp    80106a5f <sys_sleep+0x9c>
  acquire(&tickslock);
801069e9:	83 ec 0c             	sub    $0xc,%esp
801069ec:	68 60 94 19 80       	push   $0x80199460
801069f1:	e8 57 e9 ff ff       	call   8010534d <acquire>
801069f6:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801069f9:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
801069fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106a01:	eb 38                	jmp    80106a3b <sys_sleep+0x78>
    if(myproc()->killed){
80106a03:	e8 a1 d1 ff ff       	call   80103ba9 <myproc>
80106a08:	8b 40 24             	mov    0x24(%eax),%eax
80106a0b:	85 c0                	test   %eax,%eax
80106a0d:	74 17                	je     80106a26 <sys_sleep+0x63>
      release(&tickslock);
80106a0f:	83 ec 0c             	sub    $0xc,%esp
80106a12:	68 60 94 19 80       	push   $0x80199460
80106a17:	e8 a3 e9 ff ff       	call   801053bf <release>
80106a1c:	83 c4 10             	add    $0x10,%esp
      return -1;
80106a1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a24:	eb 39                	jmp    80106a5f <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106a26:	83 ec 08             	sub    $0x8,%esp
80106a29:	68 60 94 19 80       	push   $0x80199460
80106a2e:	68 a0 9c 19 80       	push   $0x80199ca0
80106a33:	e8 53 dc ff ff       	call   8010468b <sleep>
80106a38:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106a3b:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a40:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a46:	39 d0                	cmp    %edx,%eax
80106a48:	72 b9                	jb     80106a03 <sys_sleep+0x40>
  }
  release(&tickslock);
80106a4a:	83 ec 0c             	sub    $0xc,%esp
80106a4d:	68 60 94 19 80       	push   $0x80199460
80106a52:	e8 68 e9 ff ff       	call   801053bf <release>
80106a57:	83 c4 10             	add    $0x10,%esp
  return 0;
80106a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a5f:	c9                   	leave
80106a60:	c3                   	ret

80106a61 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106a61:	f3 0f 1e fb          	endbr32
80106a65:	55                   	push   %ebp
80106a66:	89 e5                	mov    %esp,%ebp
80106a68:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106a6b:	83 ec 0c             	sub    $0xc,%esp
80106a6e:	68 60 94 19 80       	push   $0x80199460
80106a73:	e8 d5 e8 ff ff       	call   8010534d <acquire>
80106a78:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106a7b:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a83:	83 ec 0c             	sub    $0xc,%esp
80106a86:	68 60 94 19 80       	push   $0x80199460
80106a8b:	e8 2f e9 ff ff       	call   801053bf <release>
80106a90:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a96:	c9                   	leave
80106a97:	c3                   	ret

80106a98 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a98:	1e                   	push   %ds
  pushl %es
80106a99:	06                   	push   %es
  pushl %fs
80106a9a:	0f a0                	push   %fs
  pushl %gs
80106a9c:	0f a8                	push   %gs
  pushal
80106a9e:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106a9f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aa3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106aa5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106aa7:	54                   	push   %esp
  call trap
80106aa8:	e8 df 01 00 00       	call   80106c8c <trap>
  addl $4, %esp
80106aad:	83 c4 04             	add    $0x4,%esp

80106ab0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ab0:	61                   	popa
  popl %gs
80106ab1:	0f a9                	pop    %gs
  popl %fs
80106ab3:	0f a1                	pop    %fs
  popl %es
80106ab5:	07                   	pop    %es
  popl %ds
80106ab6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ab7:	83 c4 08             	add    $0x8,%esp
  iret
80106aba:	cf                   	iret

80106abb <lidt>:
{
80106abb:	55                   	push   %ebp
80106abc:	89 e5                	mov    %esp,%ebp
80106abe:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ac4:	83 e8 01             	sub    $0x1,%eax
80106ac7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106acb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ace:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad5:	c1 e8 10             	shr    $0x10,%eax
80106ad8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106adc:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106adf:	0f 01 18             	lidtl  (%eax)
}
80106ae2:	90                   	nop
80106ae3:	c9                   	leave
80106ae4:	c3                   	ret

80106ae5 <rcr2>:

static inline uint
rcr2(void)
{
80106ae5:	55                   	push   %ebp
80106ae6:	89 e5                	mov    %esp,%ebp
80106ae8:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106aeb:	0f 20 d0             	mov    %cr2,%eax
80106aee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106af1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106af4:	c9                   	leave
80106af5:	c3                   	ret

80106af6 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106af6:	f3 0f 1e fb          	endbr32
80106afa:	55                   	push   %ebp
80106afb:	89 e5                	mov    %esp,%ebp
80106afd:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b07:	e9 c3 00 00 00       	jmp    80106bcf <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0f:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106b16:	89 c2                	mov    %eax,%edx
80106b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1b:	66 89 14 c5 a0 94 19 	mov    %dx,-0x7fe66b60(,%eax,8)
80106b22:	80 
80106b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b26:	66 c7 04 c5 a2 94 19 	movw   $0x8,-0x7fe66b5e(,%eax,8)
80106b2d:	80 08 00 
80106b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b33:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b3a:	80 
80106b3b:	83 e2 e0             	and    $0xffffffe0,%edx
80106b3e:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b48:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b4f:	80 
80106b50:	83 e2 1f             	and    $0x1f,%edx
80106b53:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5d:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b64:	80 
80106b65:	83 e2 f0             	and    $0xfffffff0,%edx
80106b68:	83 ca 0e             	or     $0xe,%edx
80106b6b:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b75:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b7c:	80 
80106b7d:	83 e2 ef             	and    $0xffffffef,%edx
80106b80:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8a:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b91:	80 
80106b92:	83 e2 9f             	and    $0xffffff9f,%edx
80106b95:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9f:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106ba6:	80 
80106ba7:	83 ca 80             	or     $0xffffff80,%edx
80106baa:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb4:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106bbb:	c1 e8 10             	shr    $0x10,%eax
80106bbe:	89 c2                	mov    %eax,%edx
80106bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc3:	66 89 14 c5 a6 94 19 	mov    %dx,-0x7fe66b5a(,%eax,8)
80106bca:	80 
  for(i = 0; i < 256; i++)
80106bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bcf:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bd6:	0f 8e 30 ff ff ff    	jle    80106b0c <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bdc:	a1 88 01 11 80       	mov    0x80110188,%eax
80106be1:	66 a3 a0 96 19 80    	mov    %ax,0x801996a0
80106be7:	66 c7 05 a2 96 19 80 	movw   $0x8,0x801996a2
80106bee:	08 00 
80106bf0:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106bf7:	83 e0 e0             	and    $0xffffffe0,%eax
80106bfa:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106bff:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106c06:	83 e0 1f             	and    $0x1f,%eax
80106c09:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106c0e:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c15:	83 c8 0f             	or     $0xf,%eax
80106c18:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c1d:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c24:	83 e0 ef             	and    $0xffffffef,%eax
80106c27:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c2c:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c33:	83 c8 60             	or     $0x60,%eax
80106c36:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c3b:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c42:	83 c8 80             	or     $0xffffff80,%eax
80106c45:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c4a:	a1 88 01 11 80       	mov    0x80110188,%eax
80106c4f:	c1 e8 10             	shr    $0x10,%eax
80106c52:	66 a3 a6 96 19 80    	mov    %ax,0x801996a6

  initlock(&tickslock, "time");
80106c58:	83 ec 08             	sub    $0x8,%esp
80106c5b:	68 20 b5 10 80       	push   $0x8010b520
80106c60:	68 60 94 19 80       	push   $0x80199460
80106c65:	e8 bd e6 ff ff       	call   80105327 <initlock>
80106c6a:	83 c4 10             	add    $0x10,%esp
}
80106c6d:	90                   	nop
80106c6e:	c9                   	leave
80106c6f:	c3                   	ret

80106c70 <idtinit>:

void
idtinit(void)
{
80106c70:	f3 0f 1e fb          	endbr32
80106c74:	55                   	push   %ebp
80106c75:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c77:	68 00 08 00 00       	push   $0x800
80106c7c:	68 a0 94 19 80       	push   $0x801994a0
80106c81:	e8 35 fe ff ff       	call   80106abb <lidt>
80106c86:	83 c4 08             	add    $0x8,%esp
}
80106c89:	90                   	nop
80106c8a:	c9                   	leave
80106c8b:	c3                   	ret

80106c8c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c8c:	f3 0f 1e fb          	endbr32
80106c90:	55                   	push   %ebp
80106c91:	89 e5                	mov    %esp,%ebp
80106c93:	57                   	push   %edi
80106c94:	56                   	push   %esi
80106c95:	53                   	push   %ebx
80106c96:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106c99:	8b 45 08             	mov    0x8(%ebp),%eax
80106c9c:	8b 40 30             	mov    0x30(%eax),%eax
80106c9f:	83 f8 40             	cmp    $0x40,%eax
80106ca2:	75 3b                	jne    80106cdf <trap+0x53>
    if(myproc()->killed)
80106ca4:	e8 00 cf ff ff       	call   80103ba9 <myproc>
80106ca9:	8b 40 24             	mov    0x24(%eax),%eax
80106cac:	85 c0                	test   %eax,%eax
80106cae:	74 05                	je     80106cb5 <trap+0x29>
      exit();
80106cb0:	e8 c3 d4 ff ff       	call   80104178 <exit>
    myproc()->tf = tf;
80106cb5:	e8 ef ce ff ff       	call   80103ba9 <myproc>
80106cba:	8b 55 08             	mov    0x8(%ebp),%edx
80106cbd:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cc0:	e8 43 ed ff ff       	call   80105a08 <syscall>
    if(myproc()->killed)
80106cc5:	e8 df ce ff ff       	call   80103ba9 <myproc>
80106cca:	8b 40 24             	mov    0x24(%eax),%eax
80106ccd:	85 c0                	test   %eax,%eax
80106ccf:	0f 84 3f 03 00 00    	je     80107014 <trap+0x388>
      exit();
80106cd5:	e8 9e d4 ff ff       	call   80104178 <exit>
    return;
80106cda:	e9 35 03 00 00       	jmp    80107014 <trap+0x388>
  }

  switch(tf->trapno){
80106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce2:	8b 40 30             	mov    0x30(%eax),%eax
80106ce5:	83 e8 20             	sub    $0x20,%eax
80106ce8:	83 f8 1f             	cmp    $0x1f,%eax
80106ceb:	0f 87 ee 01 00 00    	ja     80106edf <trap+0x253>
80106cf1:	8b 04 85 f4 b5 10 80 	mov    -0x7fef4a0c(,%eax,4),%eax
80106cf8:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106cfb:	e8 0e ce ff ff       	call   80103b0e <cpuid>
80106d00:	85 c0                	test   %eax,%eax
80106d02:	75 3d                	jne    80106d41 <trap+0xb5>
      acquire(&tickslock);
80106d04:	83 ec 0c             	sub    $0xc,%esp
80106d07:	68 60 94 19 80       	push   $0x80199460
80106d0c:	e8 3c e6 ff ff       	call   8010534d <acquire>
80106d11:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d14:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106d19:	83 c0 01             	add    $0x1,%eax
80106d1c:	a3 a0 9c 19 80       	mov    %eax,0x80199ca0
      wakeup(&ticks);
80106d21:	83 ec 0c             	sub    $0xc,%esp
80106d24:	68 a0 9c 19 80       	push   $0x80199ca0
80106d29:	e8 4c da ff ff       	call   8010477a <wakeup>
80106d2e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d31:	83 ec 0c             	sub    $0xc,%esp
80106d34:	68 60 94 19 80       	push   $0x80199460
80106d39:	e8 81 e6 ff ff       	call   801053bf <release>
80106d3e:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106d41:	e8 63 ce ff ff       	call   80103ba9 <myproc>
80106d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106d49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106d4d:	0f 84 17 01 00 00    	je     80106e6a <trap+0x1de>
80106d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d56:	8b 40 0c             	mov    0xc(%eax),%eax
80106d59:	83 f8 04             	cmp    $0x4,%eax
80106d5c:	0f 85 08 01 00 00    	jne    80106e6a <trap+0x1de>
80106d62:	e8 c6 cd ff ff       	call   80103b2d <mycpu>
80106d67:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106d6d:	85 c0                	test   %eax,%eax
80106d6f:	0f 84 f5 00 00 00    	je     80106e6a <trap+0x1de>
      int idx = myproc() - ptable.proc;
80106d75:	e8 2f ce ff ff       	call   80103ba9 <myproc>
80106d7a:	2d 54 75 19 80       	sub    $0x80197554,%eax
80106d7f:	c1 f8 02             	sar    $0x2,%eax
80106d82:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106d88:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d8e:	83 e8 80             	sub    $0xffffff80,%eax
80106d91:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106d98:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106da8:	01 d0                	add    %edx,%eax
80106daa:	05 00 01 00 00       	add    $0x100,%eax
80106daf:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106db6:	8d 50 01             	lea    0x1(%eax),%edx
80106db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106dbc:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106dc6:	01 c8                	add    %ecx,%eax
80106dc8:	05 00 01 00 00       	add    $0x100,%eax
80106dcd:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
      kernel_pstat.wait_ticks[idx][q] = 0; // 실행된 큐의 wait_ticks 초기화화
80106dd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106dd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106de1:	01 d0                	add    %edx,%eax
80106de3:	05 00 02 00 00       	add    $0x200,%eax
80106de8:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80106def:	00 00 00 00 

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106df3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106df6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e00:	01 d0                	add    %edx,%eax
80106e02:	05 00 01 00 00       	add    $0x100,%eax
80106e07:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106e0e:	83 f8 01             	cmp    $0x1,%eax
80106e11:	74 22                	je     80106e35 <trap+0x1a9>
80106e13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e20:	01 d0                	add    %edx,%eax
80106e22:	05 00 01 00 00       	add    $0x100,%eax
80106e27:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106e2e:	83 e0 07             	and    $0x7,%eax
80106e31:	85 c0                	test   %eax,%eax
80106e33:	75 35                	jne    80106e6a <trap+0x1de>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e42:	01 d0                	add    %edx,%eax
80106e44:	05 00 01 00 00       	add    $0x100,%eax
80106e49:	8b 1c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106e50:	e8 54 cd ff ff       	call   80103ba9 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e55:	8b 40 10             	mov    0x10(%eax),%eax
80106e58:	53                   	push   %ebx
80106e59:	ff 75 dc             	push   -0x24(%ebp)
80106e5c:	50                   	push   %eax
80106e5d:	68 28 b5 10 80       	push   $0x8010b528
80106e62:	e8 a5 95 ff ff       	call   8010040c <cprintf>
80106e67:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106e6a:	e8 b6 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e6f:	e9 20 01 00 00       	jmp    80106f94 <trap+0x308>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e74:	e8 1a 40 00 00       	call   8010ae93 <ideintr>
    lapiceoi();
80106e79:	e8 a7 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e7e:	e9 11 01 00 00       	jmp    80106f94 <trap+0x308>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106e83:	e8 d3 bb ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106e88:	e8 98 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e8d:	e9 02 01 00 00       	jmp    80106f94 <trap+0x308>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106e92:	e8 5f 03 00 00       	call   801071f6 <uartintr>
    lapiceoi();
80106e97:	e8 89 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e9c:	e9 f3 00 00 00       	jmp    80106f94 <trap+0x308>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106ea1:	e8 2c 2c 00 00       	call   80109ad2 <i8254_intr>
    lapiceoi();
80106ea6:	e8 7a bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106eab:	e9 e4 00 00 00       	jmp    80106f94 <trap+0x308>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb3:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ebd:	0f b7 d8             	movzwl %ax,%ebx
80106ec0:	e8 49 cc ff ff       	call   80103b0e <cpuid>
80106ec5:	56                   	push   %esi
80106ec6:	53                   	push   %ebx
80106ec7:	50                   	push   %eax
80106ec8:	68 54 b5 10 80       	push   $0x8010b554
80106ecd:	e8 3a 95 ff ff       	call   8010040c <cprintf>
80106ed2:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106ed5:	e8 4b bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106eda:	e9 b5 00 00 00       	jmp    80106f94 <trap+0x308>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106edf:	e8 c5 cc ff ff       	call   80103ba9 <myproc>
80106ee4:	85 c0                	test   %eax,%eax
80106ee6:	74 11                	je     80106ef9 <trap+0x26d>
80106ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80106eeb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106eef:	0f b7 c0             	movzwl %ax,%eax
80106ef2:	83 e0 03             	and    $0x3,%eax
80106ef5:	85 c0                	test   %eax,%eax
80106ef7:	75 39                	jne    80106f32 <trap+0x2a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ef9:	e8 e7 fb ff ff       	call   80106ae5 <rcr2>
80106efe:	89 c3                	mov    %eax,%ebx
80106f00:	8b 45 08             	mov    0x8(%ebp),%eax
80106f03:	8b 70 38             	mov    0x38(%eax),%esi
80106f06:	e8 03 cc ff ff       	call   80103b0e <cpuid>
80106f0b:	8b 55 08             	mov    0x8(%ebp),%edx
80106f0e:	8b 52 30             	mov    0x30(%edx),%edx
80106f11:	83 ec 0c             	sub    $0xc,%esp
80106f14:	53                   	push   %ebx
80106f15:	56                   	push   %esi
80106f16:	50                   	push   %eax
80106f17:	52                   	push   %edx
80106f18:	68 78 b5 10 80       	push   $0x8010b578
80106f1d:	e8 ea 94 ff ff       	call   8010040c <cprintf>
80106f22:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106f25:	83 ec 0c             	sub    $0xc,%esp
80106f28:	68 aa b5 10 80       	push   $0x8010b5aa
80106f2d:	e8 93 96 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f32:	e8 ae fb ff ff       	call   80106ae5 <rcr2>
80106f37:	89 c6                	mov    %eax,%esi
80106f39:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3c:	8b 40 38             	mov    0x38(%eax),%eax
80106f3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106f42:	e8 c7 cb ff ff       	call   80103b0e <cpuid>
80106f47:	89 c3                	mov    %eax,%ebx
80106f49:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4c:	8b 48 34             	mov    0x34(%eax),%ecx
80106f4f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106f52:	8b 45 08             	mov    0x8(%ebp),%eax
80106f55:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106f58:	e8 4c cc ff ff       	call   80103ba9 <myproc>
80106f5d:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f60:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106f63:	e8 41 cc ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f68:	8b 40 10             	mov    0x10(%eax),%eax
80106f6b:	56                   	push   %esi
80106f6c:	ff 75 d4             	push   -0x2c(%ebp)
80106f6f:	53                   	push   %ebx
80106f70:	ff 75 d0             	push   -0x30(%ebp)
80106f73:	57                   	push   %edi
80106f74:	ff 75 cc             	push   -0x34(%ebp)
80106f77:	50                   	push   %eax
80106f78:	68 b0 b5 10 80       	push   $0x8010b5b0
80106f7d:	e8 8a 94 ff ff       	call   8010040c <cprintf>
80106f82:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106f85:	e8 1f cc ff ff       	call   80103ba9 <myproc>
80106f8a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f91:	eb 01                	jmp    80106f94 <trap+0x308>
    break;
80106f93:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f94:	e8 10 cc ff ff       	call   80103ba9 <myproc>
80106f99:	85 c0                	test   %eax,%eax
80106f9b:	74 23                	je     80106fc0 <trap+0x334>
80106f9d:	e8 07 cc ff ff       	call   80103ba9 <myproc>
80106fa2:	8b 40 24             	mov    0x24(%eax),%eax
80106fa5:	85 c0                	test   %eax,%eax
80106fa7:	74 17                	je     80106fc0 <trap+0x334>
80106fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80106fac:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fb0:	0f b7 c0             	movzwl %ax,%eax
80106fb3:	83 e0 03             	and    $0x3,%eax
80106fb6:	83 f8 03             	cmp    $0x3,%eax
80106fb9:	75 05                	jne    80106fc0 <trap+0x334>
    exit();
80106fbb:	e8 b8 d1 ff ff       	call   80104178 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106fc0:	e8 e4 cb ff ff       	call   80103ba9 <myproc>
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	74 1d                	je     80106fe6 <trap+0x35a>
80106fc9:	e8 db cb ff ff       	call   80103ba9 <myproc>
80106fce:	8b 40 0c             	mov    0xc(%eax),%eax
80106fd1:	83 f8 04             	cmp    $0x4,%eax
80106fd4:	75 10                	jne    80106fe6 <trap+0x35a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd9:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106fdc:	83 f8 20             	cmp    $0x20,%eax
80106fdf:	75 05                	jne    80106fe6 <trap+0x35a>
    yield();
80106fe1:	e8 1d d6 ff ff       	call   80104603 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106fe6:	e8 be cb ff ff       	call   80103ba9 <myproc>
80106feb:	85 c0                	test   %eax,%eax
80106fed:	74 26                	je     80107015 <trap+0x389>
80106fef:	e8 b5 cb ff ff       	call   80103ba9 <myproc>
80106ff4:	8b 40 24             	mov    0x24(%eax),%eax
80106ff7:	85 c0                	test   %eax,%eax
80106ff9:	74 1a                	je     80107015 <trap+0x389>
80106ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ffe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107002:	0f b7 c0             	movzwl %ax,%eax
80107005:	83 e0 03             	and    $0x3,%eax
80107008:	83 f8 03             	cmp    $0x3,%eax
8010700b:	75 08                	jne    80107015 <trap+0x389>
    exit();
8010700d:	e8 66 d1 ff ff       	call   80104178 <exit>
80107012:	eb 01                	jmp    80107015 <trap+0x389>
    return;
80107014:	90                   	nop
}
80107015:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107018:	5b                   	pop    %ebx
80107019:	5e                   	pop    %esi
8010701a:	5f                   	pop    %edi
8010701b:	5d                   	pop    %ebp
8010701c:	c3                   	ret

8010701d <inb>:
{
8010701d:	55                   	push   %ebp
8010701e:	89 e5                	mov    %esp,%ebp
80107020:	83 ec 14             	sub    $0x14,%esp
80107023:	8b 45 08             	mov    0x8(%ebp),%eax
80107026:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010702a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010702e:	89 c2                	mov    %eax,%edx
80107030:	ec                   	in     (%dx),%al
80107031:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107034:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107038:	c9                   	leave
80107039:	c3                   	ret

8010703a <outb>:
{
8010703a:	55                   	push   %ebp
8010703b:	89 e5                	mov    %esp,%ebp
8010703d:	83 ec 08             	sub    $0x8,%esp
80107040:	8b 45 08             	mov    0x8(%ebp),%eax
80107043:	8b 55 0c             	mov    0xc(%ebp),%edx
80107046:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010704a:	89 d0                	mov    %edx,%eax
8010704c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010704f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107053:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107057:	ee                   	out    %al,(%dx)
}
80107058:	90                   	nop
80107059:	c9                   	leave
8010705a:	c3                   	ret

8010705b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010705b:	f3 0f 1e fb          	endbr32
8010705f:	55                   	push   %ebp
80107060:	89 e5                	mov    %esp,%ebp
80107062:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107065:	6a 00                	push   $0x0
80107067:	68 fa 03 00 00       	push   $0x3fa
8010706c:	e8 c9 ff ff ff       	call   8010703a <outb>
80107071:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107074:	68 80 00 00 00       	push   $0x80
80107079:	68 fb 03 00 00       	push   $0x3fb
8010707e:	e8 b7 ff ff ff       	call   8010703a <outb>
80107083:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107086:	6a 0c                	push   $0xc
80107088:	68 f8 03 00 00       	push   $0x3f8
8010708d:	e8 a8 ff ff ff       	call   8010703a <outb>
80107092:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107095:	6a 00                	push   $0x0
80107097:	68 f9 03 00 00       	push   $0x3f9
8010709c:	e8 99 ff ff ff       	call   8010703a <outb>
801070a1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801070a4:	6a 03                	push   $0x3
801070a6:	68 fb 03 00 00       	push   $0x3fb
801070ab:	e8 8a ff ff ff       	call   8010703a <outb>
801070b0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801070b3:	6a 00                	push   $0x0
801070b5:	68 fc 03 00 00       	push   $0x3fc
801070ba:	e8 7b ff ff ff       	call   8010703a <outb>
801070bf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070c2:	6a 01                	push   $0x1
801070c4:	68 f9 03 00 00       	push   $0x3f9
801070c9:	e8 6c ff ff ff       	call   8010703a <outb>
801070ce:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070d1:	68 fd 03 00 00       	push   $0x3fd
801070d6:	e8 42 ff ff ff       	call   8010701d <inb>
801070db:	83 c4 04             	add    $0x4,%esp
801070de:	3c ff                	cmp    $0xff,%al
801070e0:	74 61                	je     80107143 <uartinit+0xe8>
    return;
  uart = 1;
801070e2:	c7 05 80 e0 18 80 01 	movl   $0x1,0x8018e080
801070e9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070ec:	68 fa 03 00 00       	push   $0x3fa
801070f1:	e8 27 ff ff ff       	call   8010701d <inb>
801070f6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801070f9:	68 f8 03 00 00       	push   $0x3f8
801070fe:	e8 1a ff ff ff       	call   8010701d <inb>
80107103:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107106:	83 ec 08             	sub    $0x8,%esp
80107109:	6a 00                	push   $0x0
8010710b:	6a 04                	push   $0x4
8010710d:	e8 fa b5 ff ff       	call   8010270c <ioapicenable>
80107112:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107115:	c7 45 f4 74 b6 10 80 	movl   $0x8010b674,-0xc(%ebp)
8010711c:	eb 19                	jmp    80107137 <uartinit+0xdc>
    uartputc(*p);
8010711e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107121:	0f b6 00             	movzbl (%eax),%eax
80107124:	0f be c0             	movsbl %al,%eax
80107127:	83 ec 0c             	sub    $0xc,%esp
8010712a:	50                   	push   %eax
8010712b:	e8 16 00 00 00       	call   80107146 <uartputc>
80107130:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107133:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713a:	0f b6 00             	movzbl (%eax),%eax
8010713d:	84 c0                	test   %al,%al
8010713f:	75 dd                	jne    8010711e <uartinit+0xc3>
80107141:	eb 01                	jmp    80107144 <uartinit+0xe9>
    return;
80107143:	90                   	nop
}
80107144:	c9                   	leave
80107145:	c3                   	ret

80107146 <uartputc>:

void
uartputc(int c)
{
80107146:	f3 0f 1e fb          	endbr32
8010714a:	55                   	push   %ebp
8010714b:	89 e5                	mov    %esp,%ebp
8010714d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107150:	a1 80 e0 18 80       	mov    0x8018e080,%eax
80107155:	85 c0                	test   %eax,%eax
80107157:	74 53                	je     801071ac <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107159:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107160:	eb 11                	jmp    80107173 <uartputc+0x2d>
    microdelay(10);
80107162:	83 ec 0c             	sub    $0xc,%esp
80107165:	6a 0a                	push   $0xa
80107167:	e8 d8 ba ff ff       	call   80102c44 <microdelay>
8010716c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010716f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107173:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107177:	7f 1a                	jg     80107193 <uartputc+0x4d>
80107179:	83 ec 0c             	sub    $0xc,%esp
8010717c:	68 fd 03 00 00       	push   $0x3fd
80107181:	e8 97 fe ff ff       	call   8010701d <inb>
80107186:	83 c4 10             	add    $0x10,%esp
80107189:	0f b6 c0             	movzbl %al,%eax
8010718c:	83 e0 20             	and    $0x20,%eax
8010718f:	85 c0                	test   %eax,%eax
80107191:	74 cf                	je     80107162 <uartputc+0x1c>
  outb(COM1+0, c);
80107193:	8b 45 08             	mov    0x8(%ebp),%eax
80107196:	0f b6 c0             	movzbl %al,%eax
80107199:	83 ec 08             	sub    $0x8,%esp
8010719c:	50                   	push   %eax
8010719d:	68 f8 03 00 00       	push   $0x3f8
801071a2:	e8 93 fe ff ff       	call   8010703a <outb>
801071a7:	83 c4 10             	add    $0x10,%esp
801071aa:	eb 01                	jmp    801071ad <uartputc+0x67>
    return;
801071ac:	90                   	nop
}
801071ad:	c9                   	leave
801071ae:	c3                   	ret

801071af <uartgetc>:

static int
uartgetc(void)
{
801071af:	f3 0f 1e fb          	endbr32
801071b3:	55                   	push   %ebp
801071b4:	89 e5                	mov    %esp,%ebp
  if(!uart)
801071b6:	a1 80 e0 18 80       	mov    0x8018e080,%eax
801071bb:	85 c0                	test   %eax,%eax
801071bd:	75 07                	jne    801071c6 <uartgetc+0x17>
    return -1;
801071bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c4:	eb 2e                	jmp    801071f4 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801071c6:	68 fd 03 00 00       	push   $0x3fd
801071cb:	e8 4d fe ff ff       	call   8010701d <inb>
801071d0:	83 c4 04             	add    $0x4,%esp
801071d3:	0f b6 c0             	movzbl %al,%eax
801071d6:	83 e0 01             	and    $0x1,%eax
801071d9:	85 c0                	test   %eax,%eax
801071db:	75 07                	jne    801071e4 <uartgetc+0x35>
    return -1;
801071dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e2:	eb 10                	jmp    801071f4 <uartgetc+0x45>
  return inb(COM1+0);
801071e4:	68 f8 03 00 00       	push   $0x3f8
801071e9:	e8 2f fe ff ff       	call   8010701d <inb>
801071ee:	83 c4 04             	add    $0x4,%esp
801071f1:	0f b6 c0             	movzbl %al,%eax
}
801071f4:	c9                   	leave
801071f5:	c3                   	ret

801071f6 <uartintr>:

void
uartintr(void)
{
801071f6:	f3 0f 1e fb          	endbr32
801071fa:	55                   	push   %ebp
801071fb:	89 e5                	mov    %esp,%ebp
801071fd:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107200:	83 ec 0c             	sub    $0xc,%esp
80107203:	68 af 71 10 80       	push   $0x801071af
80107208:	e8 f3 95 ff ff       	call   80100800 <consoleintr>
8010720d:	83 c4 10             	add    $0x10,%esp
}
80107210:	90                   	nop
80107211:	c9                   	leave
80107212:	c3                   	ret

80107213 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $0
80107215:	6a 00                	push   $0x0
  jmp alltraps
80107217:	e9 7c f8 ff ff       	jmp    80106a98 <alltraps>

8010721c <vector1>:
.globl vector1
vector1:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $1
8010721e:	6a 01                	push   $0x1
  jmp alltraps
80107220:	e9 73 f8 ff ff       	jmp    80106a98 <alltraps>

80107225 <vector2>:
.globl vector2
vector2:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $2
80107227:	6a 02                	push   $0x2
  jmp alltraps
80107229:	e9 6a f8 ff ff       	jmp    80106a98 <alltraps>

8010722e <vector3>:
.globl vector3
vector3:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $3
80107230:	6a 03                	push   $0x3
  jmp alltraps
80107232:	e9 61 f8 ff ff       	jmp    80106a98 <alltraps>

80107237 <vector4>:
.globl vector4
vector4:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $4
80107239:	6a 04                	push   $0x4
  jmp alltraps
8010723b:	e9 58 f8 ff ff       	jmp    80106a98 <alltraps>

80107240 <vector5>:
.globl vector5
vector5:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $5
80107242:	6a 05                	push   $0x5
  jmp alltraps
80107244:	e9 4f f8 ff ff       	jmp    80106a98 <alltraps>

80107249 <vector6>:
.globl vector6
vector6:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $6
8010724b:	6a 06                	push   $0x6
  jmp alltraps
8010724d:	e9 46 f8 ff ff       	jmp    80106a98 <alltraps>

80107252 <vector7>:
.globl vector7
vector7:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $7
80107254:	6a 07                	push   $0x7
  jmp alltraps
80107256:	e9 3d f8 ff ff       	jmp    80106a98 <alltraps>

8010725b <vector8>:
.globl vector8
vector8:
  pushl $8
8010725b:	6a 08                	push   $0x8
  jmp alltraps
8010725d:	e9 36 f8 ff ff       	jmp    80106a98 <alltraps>

80107262 <vector9>:
.globl vector9
vector9:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $9
80107264:	6a 09                	push   $0x9
  jmp alltraps
80107266:	e9 2d f8 ff ff       	jmp    80106a98 <alltraps>

8010726b <vector10>:
.globl vector10
vector10:
  pushl $10
8010726b:	6a 0a                	push   $0xa
  jmp alltraps
8010726d:	e9 26 f8 ff ff       	jmp    80106a98 <alltraps>

80107272 <vector11>:
.globl vector11
vector11:
  pushl $11
80107272:	6a 0b                	push   $0xb
  jmp alltraps
80107274:	e9 1f f8 ff ff       	jmp    80106a98 <alltraps>

80107279 <vector12>:
.globl vector12
vector12:
  pushl $12
80107279:	6a 0c                	push   $0xc
  jmp alltraps
8010727b:	e9 18 f8 ff ff       	jmp    80106a98 <alltraps>

80107280 <vector13>:
.globl vector13
vector13:
  pushl $13
80107280:	6a 0d                	push   $0xd
  jmp alltraps
80107282:	e9 11 f8 ff ff       	jmp    80106a98 <alltraps>

80107287 <vector14>:
.globl vector14
vector14:
  pushl $14
80107287:	6a 0e                	push   $0xe
  jmp alltraps
80107289:	e9 0a f8 ff ff       	jmp    80106a98 <alltraps>

8010728e <vector15>:
.globl vector15
vector15:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $15
80107290:	6a 0f                	push   $0xf
  jmp alltraps
80107292:	e9 01 f8 ff ff       	jmp    80106a98 <alltraps>

80107297 <vector16>:
.globl vector16
vector16:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $16
80107299:	6a 10                	push   $0x10
  jmp alltraps
8010729b:	e9 f8 f7 ff ff       	jmp    80106a98 <alltraps>

801072a0 <vector17>:
.globl vector17
vector17:
  pushl $17
801072a0:	6a 11                	push   $0x11
  jmp alltraps
801072a2:	e9 f1 f7 ff ff       	jmp    80106a98 <alltraps>

801072a7 <vector18>:
.globl vector18
vector18:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $18
801072a9:	6a 12                	push   $0x12
  jmp alltraps
801072ab:	e9 e8 f7 ff ff       	jmp    80106a98 <alltraps>

801072b0 <vector19>:
.globl vector19
vector19:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $19
801072b2:	6a 13                	push   $0x13
  jmp alltraps
801072b4:	e9 df f7 ff ff       	jmp    80106a98 <alltraps>

801072b9 <vector20>:
.globl vector20
vector20:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $20
801072bb:	6a 14                	push   $0x14
  jmp alltraps
801072bd:	e9 d6 f7 ff ff       	jmp    80106a98 <alltraps>

801072c2 <vector21>:
.globl vector21
vector21:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $21
801072c4:	6a 15                	push   $0x15
  jmp alltraps
801072c6:	e9 cd f7 ff ff       	jmp    80106a98 <alltraps>

801072cb <vector22>:
.globl vector22
vector22:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $22
801072cd:	6a 16                	push   $0x16
  jmp alltraps
801072cf:	e9 c4 f7 ff ff       	jmp    80106a98 <alltraps>

801072d4 <vector23>:
.globl vector23
vector23:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $23
801072d6:	6a 17                	push   $0x17
  jmp alltraps
801072d8:	e9 bb f7 ff ff       	jmp    80106a98 <alltraps>

801072dd <vector24>:
.globl vector24
vector24:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $24
801072df:	6a 18                	push   $0x18
  jmp alltraps
801072e1:	e9 b2 f7 ff ff       	jmp    80106a98 <alltraps>

801072e6 <vector25>:
.globl vector25
vector25:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $25
801072e8:	6a 19                	push   $0x19
  jmp alltraps
801072ea:	e9 a9 f7 ff ff       	jmp    80106a98 <alltraps>

801072ef <vector26>:
.globl vector26
vector26:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $26
801072f1:	6a 1a                	push   $0x1a
  jmp alltraps
801072f3:	e9 a0 f7 ff ff       	jmp    80106a98 <alltraps>

801072f8 <vector27>:
.globl vector27
vector27:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $27
801072fa:	6a 1b                	push   $0x1b
  jmp alltraps
801072fc:	e9 97 f7 ff ff       	jmp    80106a98 <alltraps>

80107301 <vector28>:
.globl vector28
vector28:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $28
80107303:	6a 1c                	push   $0x1c
  jmp alltraps
80107305:	e9 8e f7 ff ff       	jmp    80106a98 <alltraps>

8010730a <vector29>:
.globl vector29
vector29:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $29
8010730c:	6a 1d                	push   $0x1d
  jmp alltraps
8010730e:	e9 85 f7 ff ff       	jmp    80106a98 <alltraps>

80107313 <vector30>:
.globl vector30
vector30:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $30
80107315:	6a 1e                	push   $0x1e
  jmp alltraps
80107317:	e9 7c f7 ff ff       	jmp    80106a98 <alltraps>

8010731c <vector31>:
.globl vector31
vector31:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $31
8010731e:	6a 1f                	push   $0x1f
  jmp alltraps
80107320:	e9 73 f7 ff ff       	jmp    80106a98 <alltraps>

80107325 <vector32>:
.globl vector32
vector32:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $32
80107327:	6a 20                	push   $0x20
  jmp alltraps
80107329:	e9 6a f7 ff ff       	jmp    80106a98 <alltraps>

8010732e <vector33>:
.globl vector33
vector33:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $33
80107330:	6a 21                	push   $0x21
  jmp alltraps
80107332:	e9 61 f7 ff ff       	jmp    80106a98 <alltraps>

80107337 <vector34>:
.globl vector34
vector34:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $34
80107339:	6a 22                	push   $0x22
  jmp alltraps
8010733b:	e9 58 f7 ff ff       	jmp    80106a98 <alltraps>

80107340 <vector35>:
.globl vector35
vector35:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $35
80107342:	6a 23                	push   $0x23
  jmp alltraps
80107344:	e9 4f f7 ff ff       	jmp    80106a98 <alltraps>

80107349 <vector36>:
.globl vector36
vector36:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $36
8010734b:	6a 24                	push   $0x24
  jmp alltraps
8010734d:	e9 46 f7 ff ff       	jmp    80106a98 <alltraps>

80107352 <vector37>:
.globl vector37
vector37:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $37
80107354:	6a 25                	push   $0x25
  jmp alltraps
80107356:	e9 3d f7 ff ff       	jmp    80106a98 <alltraps>

8010735b <vector38>:
.globl vector38
vector38:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $38
8010735d:	6a 26                	push   $0x26
  jmp alltraps
8010735f:	e9 34 f7 ff ff       	jmp    80106a98 <alltraps>

80107364 <vector39>:
.globl vector39
vector39:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $39
80107366:	6a 27                	push   $0x27
  jmp alltraps
80107368:	e9 2b f7 ff ff       	jmp    80106a98 <alltraps>

8010736d <vector40>:
.globl vector40
vector40:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $40
8010736f:	6a 28                	push   $0x28
  jmp alltraps
80107371:	e9 22 f7 ff ff       	jmp    80106a98 <alltraps>

80107376 <vector41>:
.globl vector41
vector41:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $41
80107378:	6a 29                	push   $0x29
  jmp alltraps
8010737a:	e9 19 f7 ff ff       	jmp    80106a98 <alltraps>

8010737f <vector42>:
.globl vector42
vector42:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $42
80107381:	6a 2a                	push   $0x2a
  jmp alltraps
80107383:	e9 10 f7 ff ff       	jmp    80106a98 <alltraps>

80107388 <vector43>:
.globl vector43
vector43:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $43
8010738a:	6a 2b                	push   $0x2b
  jmp alltraps
8010738c:	e9 07 f7 ff ff       	jmp    80106a98 <alltraps>

80107391 <vector44>:
.globl vector44
vector44:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $44
80107393:	6a 2c                	push   $0x2c
  jmp alltraps
80107395:	e9 fe f6 ff ff       	jmp    80106a98 <alltraps>

8010739a <vector45>:
.globl vector45
vector45:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $45
8010739c:	6a 2d                	push   $0x2d
  jmp alltraps
8010739e:	e9 f5 f6 ff ff       	jmp    80106a98 <alltraps>

801073a3 <vector46>:
.globl vector46
vector46:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $46
801073a5:	6a 2e                	push   $0x2e
  jmp alltraps
801073a7:	e9 ec f6 ff ff       	jmp    80106a98 <alltraps>

801073ac <vector47>:
.globl vector47
vector47:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $47
801073ae:	6a 2f                	push   $0x2f
  jmp alltraps
801073b0:	e9 e3 f6 ff ff       	jmp    80106a98 <alltraps>

801073b5 <vector48>:
.globl vector48
vector48:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $48
801073b7:	6a 30                	push   $0x30
  jmp alltraps
801073b9:	e9 da f6 ff ff       	jmp    80106a98 <alltraps>

801073be <vector49>:
.globl vector49
vector49:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $49
801073c0:	6a 31                	push   $0x31
  jmp alltraps
801073c2:	e9 d1 f6 ff ff       	jmp    80106a98 <alltraps>

801073c7 <vector50>:
.globl vector50
vector50:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $50
801073c9:	6a 32                	push   $0x32
  jmp alltraps
801073cb:	e9 c8 f6 ff ff       	jmp    80106a98 <alltraps>

801073d0 <vector51>:
.globl vector51
vector51:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $51
801073d2:	6a 33                	push   $0x33
  jmp alltraps
801073d4:	e9 bf f6 ff ff       	jmp    80106a98 <alltraps>

801073d9 <vector52>:
.globl vector52
vector52:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $52
801073db:	6a 34                	push   $0x34
  jmp alltraps
801073dd:	e9 b6 f6 ff ff       	jmp    80106a98 <alltraps>

801073e2 <vector53>:
.globl vector53
vector53:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $53
801073e4:	6a 35                	push   $0x35
  jmp alltraps
801073e6:	e9 ad f6 ff ff       	jmp    80106a98 <alltraps>

801073eb <vector54>:
.globl vector54
vector54:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $54
801073ed:	6a 36                	push   $0x36
  jmp alltraps
801073ef:	e9 a4 f6 ff ff       	jmp    80106a98 <alltraps>

801073f4 <vector55>:
.globl vector55
vector55:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $55
801073f6:	6a 37                	push   $0x37
  jmp alltraps
801073f8:	e9 9b f6 ff ff       	jmp    80106a98 <alltraps>

801073fd <vector56>:
.globl vector56
vector56:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $56
801073ff:	6a 38                	push   $0x38
  jmp alltraps
80107401:	e9 92 f6 ff ff       	jmp    80106a98 <alltraps>

80107406 <vector57>:
.globl vector57
vector57:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $57
80107408:	6a 39                	push   $0x39
  jmp alltraps
8010740a:	e9 89 f6 ff ff       	jmp    80106a98 <alltraps>

8010740f <vector58>:
.globl vector58
vector58:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $58
80107411:	6a 3a                	push   $0x3a
  jmp alltraps
80107413:	e9 80 f6 ff ff       	jmp    80106a98 <alltraps>

80107418 <vector59>:
.globl vector59
vector59:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $59
8010741a:	6a 3b                	push   $0x3b
  jmp alltraps
8010741c:	e9 77 f6 ff ff       	jmp    80106a98 <alltraps>

80107421 <vector60>:
.globl vector60
vector60:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $60
80107423:	6a 3c                	push   $0x3c
  jmp alltraps
80107425:	e9 6e f6 ff ff       	jmp    80106a98 <alltraps>

8010742a <vector61>:
.globl vector61
vector61:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $61
8010742c:	6a 3d                	push   $0x3d
  jmp alltraps
8010742e:	e9 65 f6 ff ff       	jmp    80106a98 <alltraps>

80107433 <vector62>:
.globl vector62
vector62:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $62
80107435:	6a 3e                	push   $0x3e
  jmp alltraps
80107437:	e9 5c f6 ff ff       	jmp    80106a98 <alltraps>

8010743c <vector63>:
.globl vector63
vector63:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $63
8010743e:	6a 3f                	push   $0x3f
  jmp alltraps
80107440:	e9 53 f6 ff ff       	jmp    80106a98 <alltraps>

80107445 <vector64>:
.globl vector64
vector64:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $64
80107447:	6a 40                	push   $0x40
  jmp alltraps
80107449:	e9 4a f6 ff ff       	jmp    80106a98 <alltraps>

8010744e <vector65>:
.globl vector65
vector65:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $65
80107450:	6a 41                	push   $0x41
  jmp alltraps
80107452:	e9 41 f6 ff ff       	jmp    80106a98 <alltraps>

80107457 <vector66>:
.globl vector66
vector66:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $66
80107459:	6a 42                	push   $0x42
  jmp alltraps
8010745b:	e9 38 f6 ff ff       	jmp    80106a98 <alltraps>

80107460 <vector67>:
.globl vector67
vector67:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $67
80107462:	6a 43                	push   $0x43
  jmp alltraps
80107464:	e9 2f f6 ff ff       	jmp    80106a98 <alltraps>

80107469 <vector68>:
.globl vector68
vector68:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $68
8010746b:	6a 44                	push   $0x44
  jmp alltraps
8010746d:	e9 26 f6 ff ff       	jmp    80106a98 <alltraps>

80107472 <vector69>:
.globl vector69
vector69:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $69
80107474:	6a 45                	push   $0x45
  jmp alltraps
80107476:	e9 1d f6 ff ff       	jmp    80106a98 <alltraps>

8010747b <vector70>:
.globl vector70
vector70:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $70
8010747d:	6a 46                	push   $0x46
  jmp alltraps
8010747f:	e9 14 f6 ff ff       	jmp    80106a98 <alltraps>

80107484 <vector71>:
.globl vector71
vector71:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $71
80107486:	6a 47                	push   $0x47
  jmp alltraps
80107488:	e9 0b f6 ff ff       	jmp    80106a98 <alltraps>

8010748d <vector72>:
.globl vector72
vector72:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $72
8010748f:	6a 48                	push   $0x48
  jmp alltraps
80107491:	e9 02 f6 ff ff       	jmp    80106a98 <alltraps>

80107496 <vector73>:
.globl vector73
vector73:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $73
80107498:	6a 49                	push   $0x49
  jmp alltraps
8010749a:	e9 f9 f5 ff ff       	jmp    80106a98 <alltraps>

8010749f <vector74>:
.globl vector74
vector74:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $74
801074a1:	6a 4a                	push   $0x4a
  jmp alltraps
801074a3:	e9 f0 f5 ff ff       	jmp    80106a98 <alltraps>

801074a8 <vector75>:
.globl vector75
vector75:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $75
801074aa:	6a 4b                	push   $0x4b
  jmp alltraps
801074ac:	e9 e7 f5 ff ff       	jmp    80106a98 <alltraps>

801074b1 <vector76>:
.globl vector76
vector76:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $76
801074b3:	6a 4c                	push   $0x4c
  jmp alltraps
801074b5:	e9 de f5 ff ff       	jmp    80106a98 <alltraps>

801074ba <vector77>:
.globl vector77
vector77:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $77
801074bc:	6a 4d                	push   $0x4d
  jmp alltraps
801074be:	e9 d5 f5 ff ff       	jmp    80106a98 <alltraps>

801074c3 <vector78>:
.globl vector78
vector78:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $78
801074c5:	6a 4e                	push   $0x4e
  jmp alltraps
801074c7:	e9 cc f5 ff ff       	jmp    80106a98 <alltraps>

801074cc <vector79>:
.globl vector79
vector79:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $79
801074ce:	6a 4f                	push   $0x4f
  jmp alltraps
801074d0:	e9 c3 f5 ff ff       	jmp    80106a98 <alltraps>

801074d5 <vector80>:
.globl vector80
vector80:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $80
801074d7:	6a 50                	push   $0x50
  jmp alltraps
801074d9:	e9 ba f5 ff ff       	jmp    80106a98 <alltraps>

801074de <vector81>:
.globl vector81
vector81:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $81
801074e0:	6a 51                	push   $0x51
  jmp alltraps
801074e2:	e9 b1 f5 ff ff       	jmp    80106a98 <alltraps>

801074e7 <vector82>:
.globl vector82
vector82:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $82
801074e9:	6a 52                	push   $0x52
  jmp alltraps
801074eb:	e9 a8 f5 ff ff       	jmp    80106a98 <alltraps>

801074f0 <vector83>:
.globl vector83
vector83:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $83
801074f2:	6a 53                	push   $0x53
  jmp alltraps
801074f4:	e9 9f f5 ff ff       	jmp    80106a98 <alltraps>

801074f9 <vector84>:
.globl vector84
vector84:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $84
801074fb:	6a 54                	push   $0x54
  jmp alltraps
801074fd:	e9 96 f5 ff ff       	jmp    80106a98 <alltraps>

80107502 <vector85>:
.globl vector85
vector85:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $85
80107504:	6a 55                	push   $0x55
  jmp alltraps
80107506:	e9 8d f5 ff ff       	jmp    80106a98 <alltraps>

8010750b <vector86>:
.globl vector86
vector86:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $86
8010750d:	6a 56                	push   $0x56
  jmp alltraps
8010750f:	e9 84 f5 ff ff       	jmp    80106a98 <alltraps>

80107514 <vector87>:
.globl vector87
vector87:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $87
80107516:	6a 57                	push   $0x57
  jmp alltraps
80107518:	e9 7b f5 ff ff       	jmp    80106a98 <alltraps>

8010751d <vector88>:
.globl vector88
vector88:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $88
8010751f:	6a 58                	push   $0x58
  jmp alltraps
80107521:	e9 72 f5 ff ff       	jmp    80106a98 <alltraps>

80107526 <vector89>:
.globl vector89
vector89:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $89
80107528:	6a 59                	push   $0x59
  jmp alltraps
8010752a:	e9 69 f5 ff ff       	jmp    80106a98 <alltraps>

8010752f <vector90>:
.globl vector90
vector90:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $90
80107531:	6a 5a                	push   $0x5a
  jmp alltraps
80107533:	e9 60 f5 ff ff       	jmp    80106a98 <alltraps>

80107538 <vector91>:
.globl vector91
vector91:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $91
8010753a:	6a 5b                	push   $0x5b
  jmp alltraps
8010753c:	e9 57 f5 ff ff       	jmp    80106a98 <alltraps>

80107541 <vector92>:
.globl vector92
vector92:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $92
80107543:	6a 5c                	push   $0x5c
  jmp alltraps
80107545:	e9 4e f5 ff ff       	jmp    80106a98 <alltraps>

8010754a <vector93>:
.globl vector93
vector93:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $93
8010754c:	6a 5d                	push   $0x5d
  jmp alltraps
8010754e:	e9 45 f5 ff ff       	jmp    80106a98 <alltraps>

80107553 <vector94>:
.globl vector94
vector94:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $94
80107555:	6a 5e                	push   $0x5e
  jmp alltraps
80107557:	e9 3c f5 ff ff       	jmp    80106a98 <alltraps>

8010755c <vector95>:
.globl vector95
vector95:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $95
8010755e:	6a 5f                	push   $0x5f
  jmp alltraps
80107560:	e9 33 f5 ff ff       	jmp    80106a98 <alltraps>

80107565 <vector96>:
.globl vector96
vector96:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $96
80107567:	6a 60                	push   $0x60
  jmp alltraps
80107569:	e9 2a f5 ff ff       	jmp    80106a98 <alltraps>

8010756e <vector97>:
.globl vector97
vector97:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $97
80107570:	6a 61                	push   $0x61
  jmp alltraps
80107572:	e9 21 f5 ff ff       	jmp    80106a98 <alltraps>

80107577 <vector98>:
.globl vector98
vector98:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $98
80107579:	6a 62                	push   $0x62
  jmp alltraps
8010757b:	e9 18 f5 ff ff       	jmp    80106a98 <alltraps>

80107580 <vector99>:
.globl vector99
vector99:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $99
80107582:	6a 63                	push   $0x63
  jmp alltraps
80107584:	e9 0f f5 ff ff       	jmp    80106a98 <alltraps>

80107589 <vector100>:
.globl vector100
vector100:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $100
8010758b:	6a 64                	push   $0x64
  jmp alltraps
8010758d:	e9 06 f5 ff ff       	jmp    80106a98 <alltraps>

80107592 <vector101>:
.globl vector101
vector101:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $101
80107594:	6a 65                	push   $0x65
  jmp alltraps
80107596:	e9 fd f4 ff ff       	jmp    80106a98 <alltraps>

8010759b <vector102>:
.globl vector102
vector102:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $102
8010759d:	6a 66                	push   $0x66
  jmp alltraps
8010759f:	e9 f4 f4 ff ff       	jmp    80106a98 <alltraps>

801075a4 <vector103>:
.globl vector103
vector103:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $103
801075a6:	6a 67                	push   $0x67
  jmp alltraps
801075a8:	e9 eb f4 ff ff       	jmp    80106a98 <alltraps>

801075ad <vector104>:
.globl vector104
vector104:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $104
801075af:	6a 68                	push   $0x68
  jmp alltraps
801075b1:	e9 e2 f4 ff ff       	jmp    80106a98 <alltraps>

801075b6 <vector105>:
.globl vector105
vector105:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $105
801075b8:	6a 69                	push   $0x69
  jmp alltraps
801075ba:	e9 d9 f4 ff ff       	jmp    80106a98 <alltraps>

801075bf <vector106>:
.globl vector106
vector106:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $106
801075c1:	6a 6a                	push   $0x6a
  jmp alltraps
801075c3:	e9 d0 f4 ff ff       	jmp    80106a98 <alltraps>

801075c8 <vector107>:
.globl vector107
vector107:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $107
801075ca:	6a 6b                	push   $0x6b
  jmp alltraps
801075cc:	e9 c7 f4 ff ff       	jmp    80106a98 <alltraps>

801075d1 <vector108>:
.globl vector108
vector108:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $108
801075d3:	6a 6c                	push   $0x6c
  jmp alltraps
801075d5:	e9 be f4 ff ff       	jmp    80106a98 <alltraps>

801075da <vector109>:
.globl vector109
vector109:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $109
801075dc:	6a 6d                	push   $0x6d
  jmp alltraps
801075de:	e9 b5 f4 ff ff       	jmp    80106a98 <alltraps>

801075e3 <vector110>:
.globl vector110
vector110:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $110
801075e5:	6a 6e                	push   $0x6e
  jmp alltraps
801075e7:	e9 ac f4 ff ff       	jmp    80106a98 <alltraps>

801075ec <vector111>:
.globl vector111
vector111:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $111
801075ee:	6a 6f                	push   $0x6f
  jmp alltraps
801075f0:	e9 a3 f4 ff ff       	jmp    80106a98 <alltraps>

801075f5 <vector112>:
.globl vector112
vector112:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $112
801075f7:	6a 70                	push   $0x70
  jmp alltraps
801075f9:	e9 9a f4 ff ff       	jmp    80106a98 <alltraps>

801075fe <vector113>:
.globl vector113
vector113:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $113
80107600:	6a 71                	push   $0x71
  jmp alltraps
80107602:	e9 91 f4 ff ff       	jmp    80106a98 <alltraps>

80107607 <vector114>:
.globl vector114
vector114:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $114
80107609:	6a 72                	push   $0x72
  jmp alltraps
8010760b:	e9 88 f4 ff ff       	jmp    80106a98 <alltraps>

80107610 <vector115>:
.globl vector115
vector115:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $115
80107612:	6a 73                	push   $0x73
  jmp alltraps
80107614:	e9 7f f4 ff ff       	jmp    80106a98 <alltraps>

80107619 <vector116>:
.globl vector116
vector116:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $116
8010761b:	6a 74                	push   $0x74
  jmp alltraps
8010761d:	e9 76 f4 ff ff       	jmp    80106a98 <alltraps>

80107622 <vector117>:
.globl vector117
vector117:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $117
80107624:	6a 75                	push   $0x75
  jmp alltraps
80107626:	e9 6d f4 ff ff       	jmp    80106a98 <alltraps>

8010762b <vector118>:
.globl vector118
vector118:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $118
8010762d:	6a 76                	push   $0x76
  jmp alltraps
8010762f:	e9 64 f4 ff ff       	jmp    80106a98 <alltraps>

80107634 <vector119>:
.globl vector119
vector119:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $119
80107636:	6a 77                	push   $0x77
  jmp alltraps
80107638:	e9 5b f4 ff ff       	jmp    80106a98 <alltraps>

8010763d <vector120>:
.globl vector120
vector120:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $120
8010763f:	6a 78                	push   $0x78
  jmp alltraps
80107641:	e9 52 f4 ff ff       	jmp    80106a98 <alltraps>

80107646 <vector121>:
.globl vector121
vector121:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $121
80107648:	6a 79                	push   $0x79
  jmp alltraps
8010764a:	e9 49 f4 ff ff       	jmp    80106a98 <alltraps>

8010764f <vector122>:
.globl vector122
vector122:
  pushl $0
8010764f:	6a 00                	push   $0x0
  pushl $122
80107651:	6a 7a                	push   $0x7a
  jmp alltraps
80107653:	e9 40 f4 ff ff       	jmp    80106a98 <alltraps>

80107658 <vector123>:
.globl vector123
vector123:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $123
8010765a:	6a 7b                	push   $0x7b
  jmp alltraps
8010765c:	e9 37 f4 ff ff       	jmp    80106a98 <alltraps>

80107661 <vector124>:
.globl vector124
vector124:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $124
80107663:	6a 7c                	push   $0x7c
  jmp alltraps
80107665:	e9 2e f4 ff ff       	jmp    80106a98 <alltraps>

8010766a <vector125>:
.globl vector125
vector125:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $125
8010766c:	6a 7d                	push   $0x7d
  jmp alltraps
8010766e:	e9 25 f4 ff ff       	jmp    80106a98 <alltraps>

80107673 <vector126>:
.globl vector126
vector126:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $126
80107675:	6a 7e                	push   $0x7e
  jmp alltraps
80107677:	e9 1c f4 ff ff       	jmp    80106a98 <alltraps>

8010767c <vector127>:
.globl vector127
vector127:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $127
8010767e:	6a 7f                	push   $0x7f
  jmp alltraps
80107680:	e9 13 f4 ff ff       	jmp    80106a98 <alltraps>

80107685 <vector128>:
.globl vector128
vector128:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $128
80107687:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010768c:	e9 07 f4 ff ff       	jmp    80106a98 <alltraps>

80107691 <vector129>:
.globl vector129
vector129:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $129
80107693:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107698:	e9 fb f3 ff ff       	jmp    80106a98 <alltraps>

8010769d <vector130>:
.globl vector130
vector130:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $130
8010769f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801076a4:	e9 ef f3 ff ff       	jmp    80106a98 <alltraps>

801076a9 <vector131>:
.globl vector131
vector131:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $131
801076ab:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801076b0:	e9 e3 f3 ff ff       	jmp    80106a98 <alltraps>

801076b5 <vector132>:
.globl vector132
vector132:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $132
801076b7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801076bc:	e9 d7 f3 ff ff       	jmp    80106a98 <alltraps>

801076c1 <vector133>:
.globl vector133
vector133:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $133
801076c3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076c8:	e9 cb f3 ff ff       	jmp    80106a98 <alltraps>

801076cd <vector134>:
.globl vector134
vector134:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $134
801076cf:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076d4:	e9 bf f3 ff ff       	jmp    80106a98 <alltraps>

801076d9 <vector135>:
.globl vector135
vector135:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $135
801076db:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801076e0:	e9 b3 f3 ff ff       	jmp    80106a98 <alltraps>

801076e5 <vector136>:
.globl vector136
vector136:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $136
801076e7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801076ec:	e9 a7 f3 ff ff       	jmp    80106a98 <alltraps>

801076f1 <vector137>:
.globl vector137
vector137:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $137
801076f3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801076f8:	e9 9b f3 ff ff       	jmp    80106a98 <alltraps>

801076fd <vector138>:
.globl vector138
vector138:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $138
801076ff:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107704:	e9 8f f3 ff ff       	jmp    80106a98 <alltraps>

80107709 <vector139>:
.globl vector139
vector139:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $139
8010770b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107710:	e9 83 f3 ff ff       	jmp    80106a98 <alltraps>

80107715 <vector140>:
.globl vector140
vector140:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $140
80107717:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010771c:	e9 77 f3 ff ff       	jmp    80106a98 <alltraps>

80107721 <vector141>:
.globl vector141
vector141:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $141
80107723:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107728:	e9 6b f3 ff ff       	jmp    80106a98 <alltraps>

8010772d <vector142>:
.globl vector142
vector142:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $142
8010772f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107734:	e9 5f f3 ff ff       	jmp    80106a98 <alltraps>

80107739 <vector143>:
.globl vector143
vector143:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $143
8010773b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107740:	e9 53 f3 ff ff       	jmp    80106a98 <alltraps>

80107745 <vector144>:
.globl vector144
vector144:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $144
80107747:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010774c:	e9 47 f3 ff ff       	jmp    80106a98 <alltraps>

80107751 <vector145>:
.globl vector145
vector145:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $145
80107753:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107758:	e9 3b f3 ff ff       	jmp    80106a98 <alltraps>

8010775d <vector146>:
.globl vector146
vector146:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $146
8010775f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107764:	e9 2f f3 ff ff       	jmp    80106a98 <alltraps>

80107769 <vector147>:
.globl vector147
vector147:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $147
8010776b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107770:	e9 23 f3 ff ff       	jmp    80106a98 <alltraps>

80107775 <vector148>:
.globl vector148
vector148:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $148
80107777:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010777c:	e9 17 f3 ff ff       	jmp    80106a98 <alltraps>

80107781 <vector149>:
.globl vector149
vector149:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $149
80107783:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107788:	e9 0b f3 ff ff       	jmp    80106a98 <alltraps>

8010778d <vector150>:
.globl vector150
vector150:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $150
8010778f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107794:	e9 ff f2 ff ff       	jmp    80106a98 <alltraps>

80107799 <vector151>:
.globl vector151
vector151:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $151
8010779b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801077a0:	e9 f3 f2 ff ff       	jmp    80106a98 <alltraps>

801077a5 <vector152>:
.globl vector152
vector152:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $152
801077a7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801077ac:	e9 e7 f2 ff ff       	jmp    80106a98 <alltraps>

801077b1 <vector153>:
.globl vector153
vector153:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $153
801077b3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801077b8:	e9 db f2 ff ff       	jmp    80106a98 <alltraps>

801077bd <vector154>:
.globl vector154
vector154:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $154
801077bf:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077c4:	e9 cf f2 ff ff       	jmp    80106a98 <alltraps>

801077c9 <vector155>:
.globl vector155
vector155:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $155
801077cb:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077d0:	e9 c3 f2 ff ff       	jmp    80106a98 <alltraps>

801077d5 <vector156>:
.globl vector156
vector156:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $156
801077d7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801077dc:	e9 b7 f2 ff ff       	jmp    80106a98 <alltraps>

801077e1 <vector157>:
.globl vector157
vector157:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $157
801077e3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801077e8:	e9 ab f2 ff ff       	jmp    80106a98 <alltraps>

801077ed <vector158>:
.globl vector158
vector158:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $158
801077ef:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801077f4:	e9 9f f2 ff ff       	jmp    80106a98 <alltraps>

801077f9 <vector159>:
.globl vector159
vector159:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $159
801077fb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107800:	e9 93 f2 ff ff       	jmp    80106a98 <alltraps>

80107805 <vector160>:
.globl vector160
vector160:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $160
80107807:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010780c:	e9 87 f2 ff ff       	jmp    80106a98 <alltraps>

80107811 <vector161>:
.globl vector161
vector161:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $161
80107813:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107818:	e9 7b f2 ff ff       	jmp    80106a98 <alltraps>

8010781d <vector162>:
.globl vector162
vector162:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $162
8010781f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107824:	e9 6f f2 ff ff       	jmp    80106a98 <alltraps>

80107829 <vector163>:
.globl vector163
vector163:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $163
8010782b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107830:	e9 63 f2 ff ff       	jmp    80106a98 <alltraps>

80107835 <vector164>:
.globl vector164
vector164:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $164
80107837:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010783c:	e9 57 f2 ff ff       	jmp    80106a98 <alltraps>

80107841 <vector165>:
.globl vector165
vector165:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $165
80107843:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107848:	e9 4b f2 ff ff       	jmp    80106a98 <alltraps>

8010784d <vector166>:
.globl vector166
vector166:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $166
8010784f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107854:	e9 3f f2 ff ff       	jmp    80106a98 <alltraps>

80107859 <vector167>:
.globl vector167
vector167:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $167
8010785b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107860:	e9 33 f2 ff ff       	jmp    80106a98 <alltraps>

80107865 <vector168>:
.globl vector168
vector168:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $168
80107867:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010786c:	e9 27 f2 ff ff       	jmp    80106a98 <alltraps>

80107871 <vector169>:
.globl vector169
vector169:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $169
80107873:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107878:	e9 1b f2 ff ff       	jmp    80106a98 <alltraps>

8010787d <vector170>:
.globl vector170
vector170:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $170
8010787f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107884:	e9 0f f2 ff ff       	jmp    80106a98 <alltraps>

80107889 <vector171>:
.globl vector171
vector171:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $171
8010788b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107890:	e9 03 f2 ff ff       	jmp    80106a98 <alltraps>

80107895 <vector172>:
.globl vector172
vector172:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $172
80107897:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010789c:	e9 f7 f1 ff ff       	jmp    80106a98 <alltraps>

801078a1 <vector173>:
.globl vector173
vector173:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $173
801078a3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801078a8:	e9 eb f1 ff ff       	jmp    80106a98 <alltraps>

801078ad <vector174>:
.globl vector174
vector174:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $174
801078af:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801078b4:	e9 df f1 ff ff       	jmp    80106a98 <alltraps>

801078b9 <vector175>:
.globl vector175
vector175:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $175
801078bb:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078c0:	e9 d3 f1 ff ff       	jmp    80106a98 <alltraps>

801078c5 <vector176>:
.globl vector176
vector176:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $176
801078c7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078cc:	e9 c7 f1 ff ff       	jmp    80106a98 <alltraps>

801078d1 <vector177>:
.globl vector177
vector177:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $177
801078d3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801078d8:	e9 bb f1 ff ff       	jmp    80106a98 <alltraps>

801078dd <vector178>:
.globl vector178
vector178:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $178
801078df:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801078e4:	e9 af f1 ff ff       	jmp    80106a98 <alltraps>

801078e9 <vector179>:
.globl vector179
vector179:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $179
801078eb:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801078f0:	e9 a3 f1 ff ff       	jmp    80106a98 <alltraps>

801078f5 <vector180>:
.globl vector180
vector180:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $180
801078f7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801078fc:	e9 97 f1 ff ff       	jmp    80106a98 <alltraps>

80107901 <vector181>:
.globl vector181
vector181:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $181
80107903:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107908:	e9 8b f1 ff ff       	jmp    80106a98 <alltraps>

8010790d <vector182>:
.globl vector182
vector182:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $182
8010790f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107914:	e9 7f f1 ff ff       	jmp    80106a98 <alltraps>

80107919 <vector183>:
.globl vector183
vector183:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $183
8010791b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107920:	e9 73 f1 ff ff       	jmp    80106a98 <alltraps>

80107925 <vector184>:
.globl vector184
vector184:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $184
80107927:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010792c:	e9 67 f1 ff ff       	jmp    80106a98 <alltraps>

80107931 <vector185>:
.globl vector185
vector185:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $185
80107933:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107938:	e9 5b f1 ff ff       	jmp    80106a98 <alltraps>

8010793d <vector186>:
.globl vector186
vector186:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $186
8010793f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107944:	e9 4f f1 ff ff       	jmp    80106a98 <alltraps>

80107949 <vector187>:
.globl vector187
vector187:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $187
8010794b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107950:	e9 43 f1 ff ff       	jmp    80106a98 <alltraps>

80107955 <vector188>:
.globl vector188
vector188:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $188
80107957:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010795c:	e9 37 f1 ff ff       	jmp    80106a98 <alltraps>

80107961 <vector189>:
.globl vector189
vector189:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $189
80107963:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107968:	e9 2b f1 ff ff       	jmp    80106a98 <alltraps>

8010796d <vector190>:
.globl vector190
vector190:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $190
8010796f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107974:	e9 1f f1 ff ff       	jmp    80106a98 <alltraps>

80107979 <vector191>:
.globl vector191
vector191:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $191
8010797b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107980:	e9 13 f1 ff ff       	jmp    80106a98 <alltraps>

80107985 <vector192>:
.globl vector192
vector192:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $192
80107987:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010798c:	e9 07 f1 ff ff       	jmp    80106a98 <alltraps>

80107991 <vector193>:
.globl vector193
vector193:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $193
80107993:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107998:	e9 fb f0 ff ff       	jmp    80106a98 <alltraps>

8010799d <vector194>:
.globl vector194
vector194:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $194
8010799f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801079a4:	e9 ef f0 ff ff       	jmp    80106a98 <alltraps>

801079a9 <vector195>:
.globl vector195
vector195:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $195
801079ab:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801079b0:	e9 e3 f0 ff ff       	jmp    80106a98 <alltraps>

801079b5 <vector196>:
.globl vector196
vector196:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $196
801079b7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801079bc:	e9 d7 f0 ff ff       	jmp    80106a98 <alltraps>

801079c1 <vector197>:
.globl vector197
vector197:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $197
801079c3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079c8:	e9 cb f0 ff ff       	jmp    80106a98 <alltraps>

801079cd <vector198>:
.globl vector198
vector198:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $198
801079cf:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079d4:	e9 bf f0 ff ff       	jmp    80106a98 <alltraps>

801079d9 <vector199>:
.globl vector199
vector199:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $199
801079db:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801079e0:	e9 b3 f0 ff ff       	jmp    80106a98 <alltraps>

801079e5 <vector200>:
.globl vector200
vector200:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $200
801079e7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801079ec:	e9 a7 f0 ff ff       	jmp    80106a98 <alltraps>

801079f1 <vector201>:
.globl vector201
vector201:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $201
801079f3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801079f8:	e9 9b f0 ff ff       	jmp    80106a98 <alltraps>

801079fd <vector202>:
.globl vector202
vector202:
  pushl $0
801079fd:	6a 00                	push   $0x0
  pushl $202
801079ff:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107a04:	e9 8f f0 ff ff       	jmp    80106a98 <alltraps>

80107a09 <vector203>:
.globl vector203
vector203:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $203
80107a0b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107a10:	e9 83 f0 ff ff       	jmp    80106a98 <alltraps>

80107a15 <vector204>:
.globl vector204
vector204:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $204
80107a17:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107a1c:	e9 77 f0 ff ff       	jmp    80106a98 <alltraps>

80107a21 <vector205>:
.globl vector205
vector205:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $205
80107a23:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a28:	e9 6b f0 ff ff       	jmp    80106a98 <alltraps>

80107a2d <vector206>:
.globl vector206
vector206:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $206
80107a2f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a34:	e9 5f f0 ff ff       	jmp    80106a98 <alltraps>

80107a39 <vector207>:
.globl vector207
vector207:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $207
80107a3b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a40:	e9 53 f0 ff ff       	jmp    80106a98 <alltraps>

80107a45 <vector208>:
.globl vector208
vector208:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $208
80107a47:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a4c:	e9 47 f0 ff ff       	jmp    80106a98 <alltraps>

80107a51 <vector209>:
.globl vector209
vector209:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $209
80107a53:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a58:	e9 3b f0 ff ff       	jmp    80106a98 <alltraps>

80107a5d <vector210>:
.globl vector210
vector210:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $210
80107a5f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a64:	e9 2f f0 ff ff       	jmp    80106a98 <alltraps>

80107a69 <vector211>:
.globl vector211
vector211:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $211
80107a6b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a70:	e9 23 f0 ff ff       	jmp    80106a98 <alltraps>

80107a75 <vector212>:
.globl vector212
vector212:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $212
80107a77:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a7c:	e9 17 f0 ff ff       	jmp    80106a98 <alltraps>

80107a81 <vector213>:
.globl vector213
vector213:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $213
80107a83:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a88:	e9 0b f0 ff ff       	jmp    80106a98 <alltraps>

80107a8d <vector214>:
.globl vector214
vector214:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $214
80107a8f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a94:	e9 ff ef ff ff       	jmp    80106a98 <alltraps>

80107a99 <vector215>:
.globl vector215
vector215:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $215
80107a9b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107aa0:	e9 f3 ef ff ff       	jmp    80106a98 <alltraps>

80107aa5 <vector216>:
.globl vector216
vector216:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $216
80107aa7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107aac:	e9 e7 ef ff ff       	jmp    80106a98 <alltraps>

80107ab1 <vector217>:
.globl vector217
vector217:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $217
80107ab3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107ab8:	e9 db ef ff ff       	jmp    80106a98 <alltraps>

80107abd <vector218>:
.globl vector218
vector218:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $218
80107abf:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107ac4:	e9 cf ef ff ff       	jmp    80106a98 <alltraps>

80107ac9 <vector219>:
.globl vector219
vector219:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $219
80107acb:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107ad0:	e9 c3 ef ff ff       	jmp    80106a98 <alltraps>

80107ad5 <vector220>:
.globl vector220
vector220:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $220
80107ad7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107adc:	e9 b7 ef ff ff       	jmp    80106a98 <alltraps>

80107ae1 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $221
80107ae3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107ae8:	e9 ab ef ff ff       	jmp    80106a98 <alltraps>

80107aed <vector222>:
.globl vector222
vector222:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $222
80107aef:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107af4:	e9 9f ef ff ff       	jmp    80106a98 <alltraps>

80107af9 <vector223>:
.globl vector223
vector223:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $223
80107afb:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107b00:	e9 93 ef ff ff       	jmp    80106a98 <alltraps>

80107b05 <vector224>:
.globl vector224
vector224:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $224
80107b07:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107b0c:	e9 87 ef ff ff       	jmp    80106a98 <alltraps>

80107b11 <vector225>:
.globl vector225
vector225:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $225
80107b13:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107b18:	e9 7b ef ff ff       	jmp    80106a98 <alltraps>

80107b1d <vector226>:
.globl vector226
vector226:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $226
80107b1f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b24:	e9 6f ef ff ff       	jmp    80106a98 <alltraps>

80107b29 <vector227>:
.globl vector227
vector227:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $227
80107b2b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b30:	e9 63 ef ff ff       	jmp    80106a98 <alltraps>

80107b35 <vector228>:
.globl vector228
vector228:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $228
80107b37:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b3c:	e9 57 ef ff ff       	jmp    80106a98 <alltraps>

80107b41 <vector229>:
.globl vector229
vector229:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $229
80107b43:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b48:	e9 4b ef ff ff       	jmp    80106a98 <alltraps>

80107b4d <vector230>:
.globl vector230
vector230:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $230
80107b4f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b54:	e9 3f ef ff ff       	jmp    80106a98 <alltraps>

80107b59 <vector231>:
.globl vector231
vector231:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $231
80107b5b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b60:	e9 33 ef ff ff       	jmp    80106a98 <alltraps>

80107b65 <vector232>:
.globl vector232
vector232:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $232
80107b67:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b6c:	e9 27 ef ff ff       	jmp    80106a98 <alltraps>

80107b71 <vector233>:
.globl vector233
vector233:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $233
80107b73:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b78:	e9 1b ef ff ff       	jmp    80106a98 <alltraps>

80107b7d <vector234>:
.globl vector234
vector234:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $234
80107b7f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b84:	e9 0f ef ff ff       	jmp    80106a98 <alltraps>

80107b89 <vector235>:
.globl vector235
vector235:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $235
80107b8b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b90:	e9 03 ef ff ff       	jmp    80106a98 <alltraps>

80107b95 <vector236>:
.globl vector236
vector236:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $236
80107b97:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b9c:	e9 f7 ee ff ff       	jmp    80106a98 <alltraps>

80107ba1 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $237
80107ba3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ba8:	e9 eb ee ff ff       	jmp    80106a98 <alltraps>

80107bad <vector238>:
.globl vector238
vector238:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $238
80107baf:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107bb4:	e9 df ee ff ff       	jmp    80106a98 <alltraps>

80107bb9 <vector239>:
.globl vector239
vector239:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $239
80107bbb:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107bc0:	e9 d3 ee ff ff       	jmp    80106a98 <alltraps>

80107bc5 <vector240>:
.globl vector240
vector240:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $240
80107bc7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bcc:	e9 c7 ee ff ff       	jmp    80106a98 <alltraps>

80107bd1 <vector241>:
.globl vector241
vector241:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $241
80107bd3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107bd8:	e9 bb ee ff ff       	jmp    80106a98 <alltraps>

80107bdd <vector242>:
.globl vector242
vector242:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $242
80107bdf:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107be4:	e9 af ee ff ff       	jmp    80106a98 <alltraps>

80107be9 <vector243>:
.globl vector243
vector243:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $243
80107beb:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107bf0:	e9 a3 ee ff ff       	jmp    80106a98 <alltraps>

80107bf5 <vector244>:
.globl vector244
vector244:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $244
80107bf7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107bfc:	e9 97 ee ff ff       	jmp    80106a98 <alltraps>

80107c01 <vector245>:
.globl vector245
vector245:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $245
80107c03:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107c08:	e9 8b ee ff ff       	jmp    80106a98 <alltraps>

80107c0d <vector246>:
.globl vector246
vector246:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $246
80107c0f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107c14:	e9 7f ee ff ff       	jmp    80106a98 <alltraps>

80107c19 <vector247>:
.globl vector247
vector247:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $247
80107c1b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c20:	e9 73 ee ff ff       	jmp    80106a98 <alltraps>

80107c25 <vector248>:
.globl vector248
vector248:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $248
80107c27:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c2c:	e9 67 ee ff ff       	jmp    80106a98 <alltraps>

80107c31 <vector249>:
.globl vector249
vector249:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $249
80107c33:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c38:	e9 5b ee ff ff       	jmp    80106a98 <alltraps>

80107c3d <vector250>:
.globl vector250
vector250:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $250
80107c3f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c44:	e9 4f ee ff ff       	jmp    80106a98 <alltraps>

80107c49 <vector251>:
.globl vector251
vector251:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $251
80107c4b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c50:	e9 43 ee ff ff       	jmp    80106a98 <alltraps>

80107c55 <vector252>:
.globl vector252
vector252:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $252
80107c57:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c5c:	e9 37 ee ff ff       	jmp    80106a98 <alltraps>

80107c61 <vector253>:
.globl vector253
vector253:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $253
80107c63:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c68:	e9 2b ee ff ff       	jmp    80106a98 <alltraps>

80107c6d <vector254>:
.globl vector254
vector254:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $254
80107c6f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c74:	e9 1f ee ff ff       	jmp    80106a98 <alltraps>

80107c79 <vector255>:
.globl vector255
vector255:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $255
80107c7b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c80:	e9 13 ee ff ff       	jmp    80106a98 <alltraps>

80107c85 <lgdt>:
{
80107c85:	55                   	push   %ebp
80107c86:	89 e5                	mov    %esp,%ebp
80107c88:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c8e:	83 e8 01             	sub    $0x1,%eax
80107c91:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c95:	8b 45 08             	mov    0x8(%ebp),%eax
80107c98:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c9f:	c1 e8 10             	shr    $0x10,%eax
80107ca2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107ca6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107ca9:	0f 01 10             	lgdtl  (%eax)
}
80107cac:	90                   	nop
80107cad:	c9                   	leave
80107cae:	c3                   	ret

80107caf <ltr>:
{
80107caf:	55                   	push   %ebp
80107cb0:	89 e5                	mov    %esp,%ebp
80107cb2:	83 ec 04             	sub    $0x4,%esp
80107cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107cbc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107cc0:	0f 00 d8             	ltr    %eax
}
80107cc3:	90                   	nop
80107cc4:	c9                   	leave
80107cc5:	c3                   	ret

80107cc6 <lcr3>:

static inline void
lcr3(uint val)
{
80107cc6:	55                   	push   %ebp
80107cc7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80107ccc:	0f 22 d8             	mov    %eax,%cr3
}
80107ccf:	90                   	nop
80107cd0:	5d                   	pop    %ebp
80107cd1:	c3                   	ret

80107cd2 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cd2:	f3 0f 1e fb          	endbr32
80107cd6:	55                   	push   %ebp
80107cd7:	89 e5                	mov    %esp,%ebp
80107cd9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107cdc:	e8 2d be ff ff       	call   80103b0e <cpuid>
80107ce1:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107ce7:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
80107cec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d04:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d0f:	83 e2 f0             	and    $0xfffffff0,%edx
80107d12:	83 ca 0a             	or     $0xa,%edx
80107d15:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d1f:	83 ca 10             	or     $0x10,%edx
80107d22:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d28:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d2c:	83 e2 9f             	and    $0xffffff9f,%edx
80107d2f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d39:	83 ca 80             	or     $0xffffff80,%edx
80107d3c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d46:	83 ca 0f             	or     $0xf,%edx
80107d49:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d53:	83 e2 ef             	and    $0xffffffef,%edx
80107d56:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d60:	83 e2 df             	and    $0xffffffdf,%edx
80107d63:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d6d:	83 ca 40             	or     $0x40,%edx
80107d70:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d7a:	83 ca 80             	or     $0xffffff80,%edx
80107d7d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d91:	ff ff 
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d9d:	00 00 
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107db3:	83 e2 f0             	and    $0xfffffff0,%edx
80107db6:	83 ca 02             	or     $0x2,%edx
80107db9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dc9:	83 ca 10             	or     $0x10,%edx
80107dcc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ddc:	83 e2 9f             	and    $0xffffff9f,%edx
80107ddf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107def:	83 ca 80             	or     $0xffffff80,%edx
80107df2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e02:	83 ca 0f             	or     $0xf,%edx
80107e05:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e15:	83 e2 ef             	and    $0xffffffef,%edx
80107e18:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e21:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e28:	83 e2 df             	and    $0xffffffdf,%edx
80107e2b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e3b:	83 ca 40             	or     $0x40,%edx
80107e3e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e47:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e4e:	83 ca 80             	or     $0xffffff80,%edx
80107e51:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107e6b:	ff ff 
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107e77:	00 00 
80107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e86:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e8d:	83 e2 f0             	and    $0xfffffff0,%edx
80107e90:	83 ca 0a             	or     $0xa,%edx
80107e93:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ea3:	83 ca 10             	or     $0x10,%edx
80107ea6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eb6:	83 ca 60             	or     $0x60,%edx
80107eb9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ec9:	83 ca 80             	or     $0xffffff80,%edx
80107ecc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107edc:	83 ca 0f             	or     $0xf,%edx
80107edf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107eef:	83 e2 ef             	and    $0xffffffef,%edx
80107ef2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f02:	83 e2 df             	and    $0xffffffdf,%edx
80107f05:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f15:	83 ca 40             	or     $0x40,%edx
80107f18:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f28:	83 ca 80             	or     $0xffffff80,%edx
80107f2b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f45:	ff ff 
80107f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f51:	00 00 
80107f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f56:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f67:	83 e2 f0             	and    $0xfffffff0,%edx
80107f6a:	83 ca 02             	or     $0x2,%edx
80107f6d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f76:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f7d:	83 ca 10             	or     $0x10,%edx
80107f80:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f89:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f90:	83 ca 60             	or     $0x60,%edx
80107f93:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fa3:	83 ca 80             	or     $0xffffff80,%edx
80107fa6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fb6:	83 ca 0f             	or     $0xf,%edx
80107fb9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fc9:	83 e2 ef             	and    $0xffffffef,%edx
80107fcc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fdc:	83 e2 df             	and    $0xffffffdf,%edx
80107fdf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fef:	83 ca 40             	or     $0x40,%edx
80107ff2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108002:	83 ca 80             	or     $0xffffff80,%edx
80108005:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010800b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108018:	83 c0 70             	add    $0x70,%eax
8010801b:	83 ec 08             	sub    $0x8,%esp
8010801e:	6a 30                	push   $0x30
80108020:	50                   	push   %eax
80108021:	e8 5f fc ff ff       	call   80107c85 <lgdt>
80108026:	83 c4 10             	add    $0x10,%esp
}
80108029:	90                   	nop
8010802a:	c9                   	leave
8010802b:	c3                   	ret

8010802c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010802c:	f3 0f 1e fb          	endbr32
80108030:	55                   	push   %ebp
80108031:	89 e5                	mov    %esp,%ebp
80108033:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108036:	8b 45 0c             	mov    0xc(%ebp),%eax
80108039:	c1 e8 16             	shr    $0x16,%eax
8010803c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108043:	8b 45 08             	mov    0x8(%ebp),%eax
80108046:	01 d0                	add    %edx,%eax
80108048:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010804b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010804e:	8b 00                	mov    (%eax),%eax
80108050:	83 e0 01             	and    $0x1,%eax
80108053:	85 c0                	test   %eax,%eax
80108055:	74 14                	je     8010806b <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805a:	8b 00                	mov    (%eax),%eax
8010805c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108061:	05 00 00 00 80       	add    $0x80000000,%eax
80108066:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108069:	eb 42                	jmp    801080ad <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010806b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010806f:	74 0e                	je     8010807f <walkpgdir+0x53>
80108071:	e8 1c a8 ff ff       	call   80102892 <kalloc>
80108076:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108079:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010807d:	75 07                	jne    80108086 <walkpgdir+0x5a>
      return 0;
8010807f:	b8 00 00 00 00       	mov    $0x0,%eax
80108084:	eb 3e                	jmp    801080c4 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108086:	83 ec 04             	sub    $0x4,%esp
80108089:	68 00 10 00 00       	push   $0x1000
8010808e:	6a 00                	push   $0x0
80108090:	ff 75 f4             	push   -0xc(%ebp)
80108093:	e8 44 d5 ff ff       	call   801055dc <memset>
80108098:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010809b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809e:	05 00 00 00 80       	add    $0x80000000,%eax
801080a3:	83 c8 07             	or     $0x7,%eax
801080a6:	89 c2                	mov    %eax,%edx
801080a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ab:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b0:	c1 e8 0c             	shr    $0xc,%eax
801080b3:	25 ff 03 00 00       	and    $0x3ff,%eax
801080b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c2:	01 d0                	add    %edx,%eax
}
801080c4:	c9                   	leave
801080c5:	c3                   	ret

801080c6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080c6:	f3 0f 1e fb          	endbr32
801080ca:	55                   	push   %ebp
801080cb:	89 e5                	mov    %esp,%ebp
801080cd:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801080d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080db:	8b 55 0c             	mov    0xc(%ebp),%edx
801080de:	8b 45 10             	mov    0x10(%ebp),%eax
801080e1:	01 d0                	add    %edx,%eax
801080e3:	83 e8 01             	sub    $0x1,%eax
801080e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080ee:	83 ec 04             	sub    $0x4,%esp
801080f1:	6a 01                	push   $0x1
801080f3:	ff 75 f4             	push   -0xc(%ebp)
801080f6:	ff 75 08             	push   0x8(%ebp)
801080f9:	e8 2e ff ff ff       	call   8010802c <walkpgdir>
801080fe:	83 c4 10             	add    $0x10,%esp
80108101:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108104:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108108:	75 07                	jne    80108111 <mappages+0x4b>
      return -1;
8010810a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010810f:	eb 47                	jmp    80108158 <mappages+0x92>
    if(*pte & PTE_P)
80108111:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108114:	8b 00                	mov    (%eax),%eax
80108116:	83 e0 01             	and    $0x1,%eax
80108119:	85 c0                	test   %eax,%eax
8010811b:	74 0d                	je     8010812a <mappages+0x64>
      panic("remap");
8010811d:	83 ec 0c             	sub    $0xc,%esp
80108120:	68 7c b6 10 80       	push   $0x8010b67c
80108125:	e8 9b 84 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
8010812a:	8b 45 18             	mov    0x18(%ebp),%eax
8010812d:	0b 45 14             	or     0x14(%ebp),%eax
80108130:	83 c8 01             	or     $0x1,%eax
80108133:	89 c2                	mov    %eax,%edx
80108135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108138:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010813a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108140:	74 10                	je     80108152 <mappages+0x8c>
      break;
    a += PGSIZE;
80108142:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108149:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108150:	eb 9c                	jmp    801080ee <mappages+0x28>
      break;
80108152:	90                   	nop
  }
  return 0;
80108153:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108158:	c9                   	leave
80108159:	c3                   	ret

8010815a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010815a:	f3 0f 1e fb          	endbr32
8010815e:	55                   	push   %ebp
8010815f:	89 e5                	mov    %esp,%ebp
80108161:	53                   	push   %ebx
80108162:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80108165:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010816c:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108171:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108176:	29 c2                	sub    %eax,%edx
80108178:	89 d0                	mov    %edx,%eax
8010817a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010817d:	a1 98 9d 19 80       	mov    0x80199d98,%eax
80108182:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108185:	8b 15 98 9d 19 80    	mov    0x80199d98,%edx
8010818b:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108190:	01 d0                	add    %edx,%eax
80108192:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108195:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010819c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819f:	83 c0 30             	add    $0x30,%eax
801081a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801081a5:	89 10                	mov    %edx,(%eax)
801081a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801081aa:	89 50 04             	mov    %edx,0x4(%eax)
801081ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
801081b0:	89 50 08             	mov    %edx,0x8(%eax)
801081b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801081b6:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801081b9:	e8 d4 a6 ff ff       	call   80102892 <kalloc>
801081be:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081c5:	75 07                	jne    801081ce <setupkvm+0x74>
    return 0;
801081c7:	b8 00 00 00 00       	mov    $0x0,%eax
801081cc:	eb 78                	jmp    80108246 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801081ce:	83 ec 04             	sub    $0x4,%esp
801081d1:	68 00 10 00 00       	push   $0x1000
801081d6:	6a 00                	push   $0x0
801081d8:	ff 75 f0             	push   -0x10(%ebp)
801081db:	e8 fc d3 ff ff       	call   801055dc <memset>
801081e0:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081e3:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
801081ea:	eb 4e                	jmp    8010823a <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ef:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fb:	8b 58 08             	mov    0x8(%eax),%ebx
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	8b 40 04             	mov    0x4(%eax),%eax
80108204:	29 c3                	sub    %eax,%ebx
80108206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108209:	8b 00                	mov    (%eax),%eax
8010820b:	83 ec 0c             	sub    $0xc,%esp
8010820e:	51                   	push   %ecx
8010820f:	52                   	push   %edx
80108210:	53                   	push   %ebx
80108211:	50                   	push   %eax
80108212:	ff 75 f0             	push   -0x10(%ebp)
80108215:	e8 ac fe ff ff       	call   801080c6 <mappages>
8010821a:	83 c4 20             	add    $0x20,%esp
8010821d:	85 c0                	test   %eax,%eax
8010821f:	79 15                	jns    80108236 <setupkvm+0xdc>
      freevm(pgdir);
80108221:	83 ec 0c             	sub    $0xc,%esp
80108224:	ff 75 f0             	push   -0x10(%ebp)
80108227:	e8 11 05 00 00       	call   8010873d <freevm>
8010822c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010822f:	b8 00 00 00 00       	mov    $0x0,%eax
80108234:	eb 10                	jmp    80108246 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108236:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010823a:	81 7d f4 00 05 11 80 	cmpl   $0x80110500,-0xc(%ebp)
80108241:	72 a9                	jb     801081ec <setupkvm+0x92>
    }
  return pgdir;
80108243:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108249:	c9                   	leave
8010824a:	c3                   	ret

8010824b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010824b:	f3 0f 1e fb          	endbr32
8010824f:	55                   	push   %ebp
80108250:	89 e5                	mov    %esp,%ebp
80108252:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108255:	e8 00 ff ff ff       	call   8010815a <setupkvm>
8010825a:	a3 a4 9c 19 80       	mov    %eax,0x80199ca4
  switchkvm();
8010825f:	e8 03 00 00 00       	call   80108267 <switchkvm>
}
80108264:	90                   	nop
80108265:	c9                   	leave
80108266:	c3                   	ret

80108267 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108267:	f3 0f 1e fb          	endbr32
8010826b:	55                   	push   %ebp
8010826c:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010826e:	a1 a4 9c 19 80       	mov    0x80199ca4,%eax
80108273:	05 00 00 00 80       	add    $0x80000000,%eax
80108278:	50                   	push   %eax
80108279:	e8 48 fa ff ff       	call   80107cc6 <lcr3>
8010827e:	83 c4 04             	add    $0x4,%esp
}
80108281:	90                   	nop
80108282:	c9                   	leave
80108283:	c3                   	ret

80108284 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108284:	f3 0f 1e fb          	endbr32
80108288:	55                   	push   %ebp
80108289:	89 e5                	mov    %esp,%ebp
8010828b:	56                   	push   %esi
8010828c:	53                   	push   %ebx
8010828d:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108290:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108294:	75 0d                	jne    801082a3 <switchuvm+0x1f>
    panic("switchuvm: no process");
80108296:	83 ec 0c             	sub    $0xc,%esp
80108299:	68 82 b6 10 80       	push   $0x8010b682
8010829e:	e8 22 83 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801082a3:	8b 45 08             	mov    0x8(%ebp),%eax
801082a6:	8b 40 08             	mov    0x8(%eax),%eax
801082a9:	85 c0                	test   %eax,%eax
801082ab:	75 0d                	jne    801082ba <switchuvm+0x36>
    panic("switchuvm: no kstack");
801082ad:	83 ec 0c             	sub    $0xc,%esp
801082b0:	68 98 b6 10 80       	push   $0x8010b698
801082b5:	e8 0b 83 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801082ba:	8b 45 08             	mov    0x8(%ebp),%eax
801082bd:	8b 40 04             	mov    0x4(%eax),%eax
801082c0:	85 c0                	test   %eax,%eax
801082c2:	75 0d                	jne    801082d1 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801082c4:	83 ec 0c             	sub    $0xc,%esp
801082c7:	68 ad b6 10 80       	push   $0x8010b6ad
801082cc:	e8 f4 82 ff ff       	call   801005c5 <panic>

  pushcli();
801082d1:	e8 f3 d1 ff ff       	call   801054c9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801082d6:	e8 52 b8 ff ff       	call   80103b2d <mycpu>
801082db:	89 c3                	mov    %eax,%ebx
801082dd:	e8 4b b8 ff ff       	call   80103b2d <mycpu>
801082e2:	83 c0 08             	add    $0x8,%eax
801082e5:	89 c6                	mov    %eax,%esi
801082e7:	e8 41 b8 ff ff       	call   80103b2d <mycpu>
801082ec:	83 c0 08             	add    $0x8,%eax
801082ef:	c1 e8 10             	shr    $0x10,%eax
801082f2:	88 45 f7             	mov    %al,-0x9(%ebp)
801082f5:	e8 33 b8 ff ff       	call   80103b2d <mycpu>
801082fa:	83 c0 08             	add    $0x8,%eax
801082fd:	c1 e8 18             	shr    $0x18,%eax
80108300:	89 c2                	mov    %eax,%edx
80108302:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108309:	67 00 
8010830b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108312:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108316:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010831c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108323:	83 e0 f0             	and    $0xfffffff0,%eax
80108326:	83 c8 09             	or     $0x9,%eax
80108329:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010832f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108336:	83 c8 10             	or     $0x10,%eax
80108339:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010833f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108346:	83 e0 9f             	and    $0xffffff9f,%eax
80108349:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010834f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108356:	83 c8 80             	or     $0xffffff80,%eax
80108359:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010835f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108366:	83 e0 f0             	and    $0xfffffff0,%eax
80108369:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010836f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108376:	83 e0 ef             	and    $0xffffffef,%eax
80108379:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010837f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108386:	83 e0 df             	and    $0xffffffdf,%eax
80108389:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010838f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108396:	83 c8 40             	or     $0x40,%eax
80108399:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010839f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801083a6:	83 e0 7f             	and    $0x7f,%eax
801083a9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801083af:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801083b5:	e8 73 b7 ff ff       	call   80103b2d <mycpu>
801083ba:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083c1:	83 e2 ef             	and    $0xffffffef,%edx
801083c4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801083ca:	e8 5e b7 ff ff       	call   80103b2d <mycpu>
801083cf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801083d5:	8b 45 08             	mov    0x8(%ebp),%eax
801083d8:	8b 40 08             	mov    0x8(%eax),%eax
801083db:	89 c3                	mov    %eax,%ebx
801083dd:	e8 4b b7 ff ff       	call   80103b2d <mycpu>
801083e2:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801083e8:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801083eb:	e8 3d b7 ff ff       	call   80103b2d <mycpu>
801083f0:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801083f6:	83 ec 0c             	sub    $0xc,%esp
801083f9:	6a 28                	push   $0x28
801083fb:	e8 af f8 ff ff       	call   80107caf <ltr>
80108400:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108403:	8b 45 08             	mov    0x8(%ebp),%eax
80108406:	8b 40 04             	mov    0x4(%eax),%eax
80108409:	05 00 00 00 80       	add    $0x80000000,%eax
8010840e:	83 ec 0c             	sub    $0xc,%esp
80108411:	50                   	push   %eax
80108412:	e8 af f8 ff ff       	call   80107cc6 <lcr3>
80108417:	83 c4 10             	add    $0x10,%esp
  popcli();
8010841a:	e8 fb d0 ff ff       	call   8010551a <popcli>
}
8010841f:	90                   	nop
80108420:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108423:	5b                   	pop    %ebx
80108424:	5e                   	pop    %esi
80108425:	5d                   	pop    %ebp
80108426:	c3                   	ret

80108427 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108427:	f3 0f 1e fb          	endbr32
8010842b:	55                   	push   %ebp
8010842c:	89 e5                	mov    %esp,%ebp
8010842e:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108431:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108438:	76 0d                	jbe    80108447 <inituvm+0x20>
    panic("inituvm: more than a page");
8010843a:	83 ec 0c             	sub    $0xc,%esp
8010843d:	68 c1 b6 10 80       	push   $0x8010b6c1
80108442:	e8 7e 81 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80108447:	e8 46 a4 ff ff       	call   80102892 <kalloc>
8010844c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010844f:	83 ec 04             	sub    $0x4,%esp
80108452:	68 00 10 00 00       	push   $0x1000
80108457:	6a 00                	push   $0x0
80108459:	ff 75 f4             	push   -0xc(%ebp)
8010845c:	e8 7b d1 ff ff       	call   801055dc <memset>
80108461:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108467:	05 00 00 00 80       	add    $0x80000000,%eax
8010846c:	83 ec 0c             	sub    $0xc,%esp
8010846f:	6a 06                	push   $0x6
80108471:	50                   	push   %eax
80108472:	68 00 10 00 00       	push   $0x1000
80108477:	6a 00                	push   $0x0
80108479:	ff 75 08             	push   0x8(%ebp)
8010847c:	e8 45 fc ff ff       	call   801080c6 <mappages>
80108481:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108484:	83 ec 04             	sub    $0x4,%esp
80108487:	ff 75 10             	push   0x10(%ebp)
8010848a:	ff 75 0c             	push   0xc(%ebp)
8010848d:	ff 75 f4             	push   -0xc(%ebp)
80108490:	e8 0e d2 ff ff       	call   801056a3 <memmove>
80108495:	83 c4 10             	add    $0x10,%esp
}
80108498:	90                   	nop
80108499:	c9                   	leave
8010849a:	c3                   	ret

8010849b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010849b:	f3 0f 1e fb          	endbr32
8010849f:	55                   	push   %ebp
801084a0:	89 e5                	mov    %esp,%ebp
801084a2:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a8:	25 ff 0f 00 00       	and    $0xfff,%eax
801084ad:	85 c0                	test   %eax,%eax
801084af:	74 0d                	je     801084be <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801084b1:	83 ec 0c             	sub    $0xc,%esp
801084b4:	68 dc b6 10 80       	push   $0x8010b6dc
801084b9:	e8 07 81 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084c5:	e9 8f 00 00 00       	jmp    80108559 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801084cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d0:	01 d0                	add    %edx,%eax
801084d2:	83 ec 04             	sub    $0x4,%esp
801084d5:	6a 00                	push   $0x0
801084d7:	50                   	push   %eax
801084d8:	ff 75 08             	push   0x8(%ebp)
801084db:	e8 4c fb ff ff       	call   8010802c <walkpgdir>
801084e0:	83 c4 10             	add    $0x10,%esp
801084e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084ea:	75 0d                	jne    801084f9 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801084ec:	83 ec 0c             	sub    $0xc,%esp
801084ef:	68 ff b6 10 80       	push   $0x8010b6ff
801084f4:	e8 cc 80 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801084f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084fc:	8b 00                	mov    (%eax),%eax
801084fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108503:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108506:	8b 45 18             	mov    0x18(%ebp),%eax
80108509:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010850c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108511:	77 0b                	ja     8010851e <loaduvm+0x83>
      n = sz - i;
80108513:	8b 45 18             	mov    0x18(%ebp),%eax
80108516:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108519:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010851c:	eb 07                	jmp    80108525 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010851e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108525:	8b 55 14             	mov    0x14(%ebp),%edx
80108528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852b:	01 d0                	add    %edx,%eax
8010852d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108530:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108536:	ff 75 f0             	push   -0x10(%ebp)
80108539:	50                   	push   %eax
8010853a:	52                   	push   %edx
8010853b:	ff 75 10             	push   0x10(%ebp)
8010853e:	e8 41 9a ff ff       	call   80101f84 <readi>
80108543:	83 c4 10             	add    $0x10,%esp
80108546:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108549:	74 07                	je     80108552 <loaduvm+0xb7>
      return -1;
8010854b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108550:	eb 18                	jmp    8010856a <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108552:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855c:	3b 45 18             	cmp    0x18(%ebp),%eax
8010855f:	0f 82 65 ff ff ff    	jb     801084ca <loaduvm+0x2f>
  }
  return 0;
80108565:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010856a:	c9                   	leave
8010856b:	c3                   	ret

8010856c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010856c:	f3 0f 1e fb          	endbr32
80108570:	55                   	push   %ebp
80108571:	89 e5                	mov    %esp,%ebp
80108573:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108576:	8b 45 10             	mov    0x10(%ebp),%eax
80108579:	85 c0                	test   %eax,%eax
8010857b:	79 0a                	jns    80108587 <allocuvm+0x1b>
    return 0;
8010857d:	b8 00 00 00 00       	mov    $0x0,%eax
80108582:	e9 ec 00 00 00       	jmp    80108673 <allocuvm+0x107>
  if(newsz < oldsz)
80108587:	8b 45 10             	mov    0x10(%ebp),%eax
8010858a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010858d:	73 08                	jae    80108597 <allocuvm+0x2b>
    return oldsz;
8010858f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108592:	e9 dc 00 00 00       	jmp    80108673 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80108597:	8b 45 0c             	mov    0xc(%ebp),%eax
8010859a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010859f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085a7:	e9 b8 00 00 00       	jmp    80108664 <allocuvm+0xf8>
    mem = kalloc();
801085ac:	e8 e1 a2 ff ff       	call   80102892 <kalloc>
801085b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085b8:	75 2e                	jne    801085e8 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801085ba:	83 ec 0c             	sub    $0xc,%esp
801085bd:	68 1d b7 10 80       	push   $0x8010b71d
801085c2:	e8 45 7e ff ff       	call   8010040c <cprintf>
801085c7:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085ca:	83 ec 04             	sub    $0x4,%esp
801085cd:	ff 75 0c             	push   0xc(%ebp)
801085d0:	ff 75 10             	push   0x10(%ebp)
801085d3:	ff 75 08             	push   0x8(%ebp)
801085d6:	e8 9a 00 00 00       	call   80108675 <deallocuvm>
801085db:	83 c4 10             	add    $0x10,%esp
      return 0;
801085de:	b8 00 00 00 00       	mov    $0x0,%eax
801085e3:	e9 8b 00 00 00       	jmp    80108673 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801085e8:	83 ec 04             	sub    $0x4,%esp
801085eb:	68 00 10 00 00       	push   $0x1000
801085f0:	6a 00                	push   $0x0
801085f2:	ff 75 f0             	push   -0x10(%ebp)
801085f5:	e8 e2 cf ff ff       	call   801055dc <memset>
801085fa:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801085fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108600:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108609:	83 ec 0c             	sub    $0xc,%esp
8010860c:	6a 06                	push   $0x6
8010860e:	52                   	push   %edx
8010860f:	68 00 10 00 00       	push   $0x1000
80108614:	50                   	push   %eax
80108615:	ff 75 08             	push   0x8(%ebp)
80108618:	e8 a9 fa ff ff       	call   801080c6 <mappages>
8010861d:	83 c4 20             	add    $0x20,%esp
80108620:	85 c0                	test   %eax,%eax
80108622:	79 39                	jns    8010865d <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108624:	83 ec 0c             	sub    $0xc,%esp
80108627:	68 35 b7 10 80       	push   $0x8010b735
8010862c:	e8 db 7d ff ff       	call   8010040c <cprintf>
80108631:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108634:	83 ec 04             	sub    $0x4,%esp
80108637:	ff 75 0c             	push   0xc(%ebp)
8010863a:	ff 75 10             	push   0x10(%ebp)
8010863d:	ff 75 08             	push   0x8(%ebp)
80108640:	e8 30 00 00 00       	call   80108675 <deallocuvm>
80108645:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108648:	83 ec 0c             	sub    $0xc,%esp
8010864b:	ff 75 f0             	push   -0x10(%ebp)
8010864e:	e8 a1 a1 ff ff       	call   801027f4 <kfree>
80108653:	83 c4 10             	add    $0x10,%esp
      return 0;
80108656:	b8 00 00 00 00       	mov    $0x0,%eax
8010865b:	eb 16                	jmp    80108673 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010865d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108667:	3b 45 10             	cmp    0x10(%ebp),%eax
8010866a:	0f 82 3c ff ff ff    	jb     801085ac <allocuvm+0x40>
    }
  }
  return newsz;
80108670:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108673:	c9                   	leave
80108674:	c3                   	ret

80108675 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108675:	f3 0f 1e fb          	endbr32
80108679:	55                   	push   %ebp
8010867a:	89 e5                	mov    %esp,%ebp
8010867c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010867f:	8b 45 10             	mov    0x10(%ebp),%eax
80108682:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108685:	72 08                	jb     8010868f <deallocuvm+0x1a>
    return oldsz;
80108687:	8b 45 0c             	mov    0xc(%ebp),%eax
8010868a:	e9 ac 00 00 00       	jmp    8010873b <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
8010868f:	8b 45 10             	mov    0x10(%ebp),%eax
80108692:	05 ff 0f 00 00       	add    $0xfff,%eax
80108697:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010869c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010869f:	e9 88 00 00 00       	jmp    8010872c <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
801086a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a7:	83 ec 04             	sub    $0x4,%esp
801086aa:	6a 00                	push   $0x0
801086ac:	50                   	push   %eax
801086ad:	ff 75 08             	push   0x8(%ebp)
801086b0:	e8 77 f9 ff ff       	call   8010802c <walkpgdir>
801086b5:	83 c4 10             	add    $0x10,%esp
801086b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801086bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086bf:	75 16                	jne    801086d7 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801086c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c4:	c1 e8 16             	shr    $0x16,%eax
801086c7:	83 c0 01             	add    $0x1,%eax
801086ca:	c1 e0 16             	shl    $0x16,%eax
801086cd:	2d 00 10 00 00       	sub    $0x1000,%eax
801086d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086d5:	eb 4e                	jmp    80108725 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
801086d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086da:	8b 00                	mov    (%eax),%eax
801086dc:	83 e0 01             	and    $0x1,%eax
801086df:	85 c0                	test   %eax,%eax
801086e1:	74 42                	je     80108725 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
801086e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e6:	8b 00                	mov    (%eax),%eax
801086e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086f4:	75 0d                	jne    80108703 <deallocuvm+0x8e>
        panic("kfree");
801086f6:	83 ec 0c             	sub    $0xc,%esp
801086f9:	68 51 b7 10 80       	push   $0x8010b751
801086fe:	e8 c2 7e ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80108703:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108706:	05 00 00 00 80       	add    $0x80000000,%eax
8010870b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010870e:	83 ec 0c             	sub    $0xc,%esp
80108711:	ff 75 e8             	push   -0x18(%ebp)
80108714:	e8 db a0 ff ff       	call   801027f4 <kfree>
80108719:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010871c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108725:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010872c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108732:	0f 82 6c ff ff ff    	jb     801086a4 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108738:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010873b:	c9                   	leave
8010873c:	c3                   	ret

8010873d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010873d:	f3 0f 1e fb          	endbr32
80108741:	55                   	push   %ebp
80108742:	89 e5                	mov    %esp,%ebp
80108744:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108747:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010874b:	75 0d                	jne    8010875a <freevm+0x1d>
    panic("freevm: no pgdir");
8010874d:	83 ec 0c             	sub    $0xc,%esp
80108750:	68 57 b7 10 80       	push   $0x8010b757
80108755:	e8 6b 7e ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010875a:	83 ec 04             	sub    $0x4,%esp
8010875d:	6a 00                	push   $0x0
8010875f:	68 00 00 00 80       	push   $0x80000000
80108764:	ff 75 08             	push   0x8(%ebp)
80108767:	e8 09 ff ff ff       	call   80108675 <deallocuvm>
8010876c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010876f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108776:	eb 48                	jmp    801087c0 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80108778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108782:	8b 45 08             	mov    0x8(%ebp),%eax
80108785:	01 d0                	add    %edx,%eax
80108787:	8b 00                	mov    (%eax),%eax
80108789:	83 e0 01             	and    $0x1,%eax
8010878c:	85 c0                	test   %eax,%eax
8010878e:	74 2c                	je     801087bc <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108793:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010879a:	8b 45 08             	mov    0x8(%ebp),%eax
8010879d:	01 d0                	add    %edx,%eax
8010879f:	8b 00                	mov    (%eax),%eax
801087a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087a6:	05 00 00 00 80       	add    $0x80000000,%eax
801087ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087ae:	83 ec 0c             	sub    $0xc,%esp
801087b1:	ff 75 f0             	push   -0x10(%ebp)
801087b4:	e8 3b a0 ff ff       	call   801027f4 <kfree>
801087b9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801087bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087c0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087c7:	76 af                	jbe    80108778 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801087c9:	83 ec 0c             	sub    $0xc,%esp
801087cc:	ff 75 08             	push   0x8(%ebp)
801087cf:	e8 20 a0 ff ff       	call   801027f4 <kfree>
801087d4:	83 c4 10             	add    $0x10,%esp
}
801087d7:	90                   	nop
801087d8:	c9                   	leave
801087d9:	c3                   	ret

801087da <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087da:	f3 0f 1e fb          	endbr32
801087de:	55                   	push   %ebp
801087df:	89 e5                	mov    %esp,%ebp
801087e1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087e4:	83 ec 04             	sub    $0x4,%esp
801087e7:	6a 00                	push   $0x0
801087e9:	ff 75 0c             	push   0xc(%ebp)
801087ec:	ff 75 08             	push   0x8(%ebp)
801087ef:	e8 38 f8 ff ff       	call   8010802c <walkpgdir>
801087f4:	83 c4 10             	add    $0x10,%esp
801087f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087fe:	75 0d                	jne    8010880d <clearpteu+0x33>
    panic("clearpteu");
80108800:	83 ec 0c             	sub    $0xc,%esp
80108803:	68 68 b7 10 80       	push   $0x8010b768
80108808:	e8 b8 7d ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
8010880d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108810:	8b 00                	mov    (%eax),%eax
80108812:	83 e0 fb             	and    $0xfffffffb,%eax
80108815:	89 c2                	mov    %eax,%edx
80108817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010881a:	89 10                	mov    %edx,(%eax)
}
8010881c:	90                   	nop
8010881d:	c9                   	leave
8010881e:	c3                   	ret

8010881f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010881f:	f3 0f 1e fb          	endbr32
80108823:	55                   	push   %ebp
80108824:	89 e5                	mov    %esp,%ebp
80108826:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108829:	e8 2c f9 ff ff       	call   8010815a <setupkvm>
8010882e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108831:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108835:	75 0a                	jne    80108841 <copyuvm+0x22>
    return 0;
80108837:	b8 00 00 00 00       	mov    $0x0,%eax
8010883c:	e9 eb 00 00 00       	jmp    8010892c <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108848:	e9 b7 00 00 00       	jmp    80108904 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010884d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108850:	83 ec 04             	sub    $0x4,%esp
80108853:	6a 00                	push   $0x0
80108855:	50                   	push   %eax
80108856:	ff 75 08             	push   0x8(%ebp)
80108859:	e8 ce f7 ff ff       	call   8010802c <walkpgdir>
8010885e:	83 c4 10             	add    $0x10,%esp
80108861:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108864:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108868:	75 0d                	jne    80108877 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
8010886a:	83 ec 0c             	sub    $0xc,%esp
8010886d:	68 72 b7 10 80       	push   $0x8010b772
80108872:	e8 4e 7d ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80108877:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010887a:	8b 00                	mov    (%eax),%eax
8010887c:	83 e0 01             	and    $0x1,%eax
8010887f:	85 c0                	test   %eax,%eax
80108881:	75 0d                	jne    80108890 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108883:	83 ec 0c             	sub    $0xc,%esp
80108886:	68 8c b7 10 80       	push   $0x8010b78c
8010888b:	e8 35 7d ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108890:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108893:	8b 00                	mov    (%eax),%eax
80108895:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010889a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010889d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a0:	8b 00                	mov    (%eax),%eax
801088a2:	25 ff 0f 00 00       	and    $0xfff,%eax
801088a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801088aa:	e8 e3 9f ff ff       	call   80102892 <kalloc>
801088af:	89 45 e0             	mov    %eax,-0x20(%ebp)
801088b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088b6:	74 5d                	je     80108915 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801088b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088bb:	05 00 00 00 80       	add    $0x80000000,%eax
801088c0:	83 ec 04             	sub    $0x4,%esp
801088c3:	68 00 10 00 00       	push   $0x1000
801088c8:	50                   	push   %eax
801088c9:	ff 75 e0             	push   -0x20(%ebp)
801088cc:	e8 d2 cd ff ff       	call   801056a3 <memmove>
801088d1:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801088d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801088d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088da:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801088e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e3:	83 ec 0c             	sub    $0xc,%esp
801088e6:	52                   	push   %edx
801088e7:	51                   	push   %ecx
801088e8:	68 00 10 00 00       	push   $0x1000
801088ed:	50                   	push   %eax
801088ee:	ff 75 f0             	push   -0x10(%ebp)
801088f1:	e8 d0 f7 ff ff       	call   801080c6 <mappages>
801088f6:	83 c4 20             	add    $0x20,%esp
801088f9:	85 c0                	test   %eax,%eax
801088fb:	78 1b                	js     80108918 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
801088fd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108907:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010890a:	0f 82 3d ff ff ff    	jb     8010884d <copyuvm+0x2e>
      goto bad;
  }
  return d;
80108910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108913:	eb 17                	jmp    8010892c <copyuvm+0x10d>
      goto bad;
80108915:	90                   	nop
80108916:	eb 01                	jmp    80108919 <copyuvm+0xfa>
      goto bad;
80108918:	90                   	nop

bad:
  freevm(d);
80108919:	83 ec 0c             	sub    $0xc,%esp
8010891c:	ff 75 f0             	push   -0x10(%ebp)
8010891f:	e8 19 fe ff ff       	call   8010873d <freevm>
80108924:	83 c4 10             	add    $0x10,%esp
  return 0;
80108927:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010892c:	c9                   	leave
8010892d:	c3                   	ret

8010892e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010892e:	f3 0f 1e fb          	endbr32
80108932:	55                   	push   %ebp
80108933:	89 e5                	mov    %esp,%ebp
80108935:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108938:	83 ec 04             	sub    $0x4,%esp
8010893b:	6a 00                	push   $0x0
8010893d:	ff 75 0c             	push   0xc(%ebp)
80108940:	ff 75 08             	push   0x8(%ebp)
80108943:	e8 e4 f6 ff ff       	call   8010802c <walkpgdir>
80108948:	83 c4 10             	add    $0x10,%esp
8010894b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010894e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108951:	8b 00                	mov    (%eax),%eax
80108953:	83 e0 01             	and    $0x1,%eax
80108956:	85 c0                	test   %eax,%eax
80108958:	75 07                	jne    80108961 <uva2ka+0x33>
    return 0;
8010895a:	b8 00 00 00 00       	mov    $0x0,%eax
8010895f:	eb 22                	jmp    80108983 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108964:	8b 00                	mov    (%eax),%eax
80108966:	83 e0 04             	and    $0x4,%eax
80108969:	85 c0                	test   %eax,%eax
8010896b:	75 07                	jne    80108974 <uva2ka+0x46>
    return 0;
8010896d:	b8 00 00 00 00       	mov    $0x0,%eax
80108972:	eb 0f                	jmp    80108983 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108977:	8b 00                	mov    (%eax),%eax
80108979:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010897e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108983:	c9                   	leave
80108984:	c3                   	ret

80108985 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108985:	f3 0f 1e fb          	endbr32
80108989:	55                   	push   %ebp
8010898a:	89 e5                	mov    %esp,%ebp
8010898c:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010898f:	8b 45 10             	mov    0x10(%ebp),%eax
80108992:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108995:	eb 7f                	jmp    80108a16 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108997:	8b 45 0c             	mov    0xc(%ebp),%eax
8010899a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010899f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801089a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a5:	83 ec 08             	sub    $0x8,%esp
801089a8:	50                   	push   %eax
801089a9:	ff 75 08             	push   0x8(%ebp)
801089ac:	e8 7d ff ff ff       	call   8010892e <uva2ka>
801089b1:	83 c4 10             	add    $0x10,%esp
801089b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801089b7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089bb:	75 07                	jne    801089c4 <copyout+0x3f>
      return -1;
801089bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089c2:	eb 61                	jmp    80108a25 <copyout+0xa0>
    n = PGSIZE - (va - va0);
801089c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c7:	2b 45 0c             	sub    0xc(%ebp),%eax
801089ca:	05 00 10 00 00       	add    $0x1000,%eax
801089cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d5:	3b 45 14             	cmp    0x14(%ebp),%eax
801089d8:	76 06                	jbe    801089e0 <copyout+0x5b>
      n = len;
801089da:	8b 45 14             	mov    0x14(%ebp),%eax
801089dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e3:	2b 45 ec             	sub    -0x14(%ebp),%eax
801089e6:	89 c2                	mov    %eax,%edx
801089e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089eb:	01 d0                	add    %edx,%eax
801089ed:	83 ec 04             	sub    $0x4,%esp
801089f0:	ff 75 f0             	push   -0x10(%ebp)
801089f3:	ff 75 f4             	push   -0xc(%ebp)
801089f6:	50                   	push   %eax
801089f7:	e8 a7 cc ff ff       	call   801056a3 <memmove>
801089fc:	83 c4 10             	add    $0x10,%esp
    len -= n;
801089ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a02:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a08:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a0e:	05 00 10 00 00       	add    $0x1000,%eax
80108a13:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108a16:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a1a:	0f 85 77 ff ff ff    	jne    80108997 <copyout+0x12>
  }
  return 0;
80108a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a25:	c9                   	leave
80108a26:	c3                   	ret

80108a27 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108a27:	f3 0f 1e fb          	endbr32
80108a2b:	55                   	push   %ebp
80108a2c:	89 e5                	mov    %esp,%ebp
80108a2e:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108a31:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a3b:	8b 40 08             	mov    0x8(%eax),%eax
80108a3e:	05 00 00 00 80       	add    $0x80000000,%eax
80108a43:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108a46:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a50:	8b 40 24             	mov    0x24(%eax),%eax
80108a53:	a3 3c 64 19 80       	mov    %eax,0x8019643c
  ncpu = 0;
80108a58:	c7 05 94 9d 19 80 00 	movl   $0x0,0x80199d94
80108a5f:	00 00 00 

  while(i<madt->len){
80108a62:	90                   	nop
80108a63:	e9 bd 00 00 00       	jmp    80108b25 <mpinit_uefi+0xfe>
    uchar *entry_type = ((uchar *)madt)+i;
80108a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a6e:	01 d0                	add    %edx,%eax
80108a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a76:	0f b6 00             	movzbl (%eax),%eax
80108a79:	0f b6 c0             	movzbl %al,%eax
80108a7c:	83 f8 05             	cmp    $0x5,%eax
80108a7f:	0f 87 a0 00 00 00    	ja     80108b25 <mpinit_uefi+0xfe>
80108a85:	8b 04 85 a8 b7 10 80 	mov    -0x7fef4858(,%eax,4),%eax
80108a8c:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a92:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108a95:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108a9a:	85 c0                	test   %eax,%eax
80108a9c:	7f 28                	jg     80108ac6 <mpinit_uefi+0x9f>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108a9e:	8b 15 94 9d 19 80    	mov    0x80199d94,%edx
80108aa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aa7:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108aab:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108ab1:	81 c2 e0 9c 19 80    	add    $0x80199ce0,%edx
80108ab7:	88 02                	mov    %al,(%edx)
          ncpu++;
80108ab9:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108abe:	83 c0 01             	add    $0x1,%eax
80108ac1:	a3 94 9d 19 80       	mov    %eax,0x80199d94
        }
        i += lapic_entry->record_len;
80108ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ac9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108acd:	0f b6 c0             	movzbl %al,%eax
80108ad0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108ad3:	eb 50                	jmp    80108b25 <mpinit_uefi+0xfe>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ade:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108ae2:	a2 c0 9c 19 80       	mov    %al,0x80199cc0
        i += ioapic->record_len;
80108ae7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aea:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108aee:	0f b6 c0             	movzbl %al,%eax
80108af1:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108af4:	eb 2f                	jmp    80108b25 <mpinit_uefi+0xfe>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108afc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b03:	0f b6 c0             	movzbl %al,%eax
80108b06:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b09:	eb 1a                	jmp    80108b25 <mpinit_uefi+0xfe>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b18:	0f b6 c0             	movzbl %al,%eax
80108b1b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b1e:	eb 05                	jmp    80108b25 <mpinit_uefi+0xfe>

      case 5:
        i = i + 0xC;
80108b20:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108b24:	90                   	nop
  while(i<madt->len){
80108b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b28:	8b 40 04             	mov    0x4(%eax),%eax
80108b2b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108b2e:	0f 82 34 ff ff ff    	jb     80108a68 <mpinit_uefi+0x41>
    }
  }

}
80108b34:	90                   	nop
80108b35:	90                   	nop
80108b36:	c9                   	leave
80108b37:	c3                   	ret

80108b38 <inb>:
{
80108b38:	55                   	push   %ebp
80108b39:	89 e5                	mov    %esp,%ebp
80108b3b:	83 ec 14             	sub    $0x14,%esp
80108b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108b41:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108b45:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108b49:	89 c2                	mov    %eax,%edx
80108b4b:	ec                   	in     (%dx),%al
80108b4c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108b4f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108b53:	c9                   	leave
80108b54:	c3                   	ret

80108b55 <outb>:
{
80108b55:	55                   	push   %ebp
80108b56:	89 e5                	mov    %esp,%ebp
80108b58:	83 ec 08             	sub    $0x8,%esp
80108b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108b65:	89 d0                	mov    %edx,%eax
80108b67:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108b6a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108b6e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108b72:	ee                   	out    %al,(%dx)
}
80108b73:	90                   	nop
80108b74:	c9                   	leave
80108b75:	c3                   	ret

80108b76 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108b76:	f3 0f 1e fb          	endbr32
80108b7a:	55                   	push   %ebp
80108b7b:	89 e5                	mov    %esp,%ebp
80108b7d:	83 ec 28             	sub    $0x28,%esp
80108b80:	8b 45 08             	mov    0x8(%ebp),%eax
80108b83:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108b86:	6a 00                	push   $0x0
80108b88:	68 fa 03 00 00       	push   $0x3fa
80108b8d:	e8 c3 ff ff ff       	call   80108b55 <outb>
80108b92:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108b95:	68 80 00 00 00       	push   $0x80
80108b9a:	68 fb 03 00 00       	push   $0x3fb
80108b9f:	e8 b1 ff ff ff       	call   80108b55 <outb>
80108ba4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108ba7:	6a 0c                	push   $0xc
80108ba9:	68 f8 03 00 00       	push   $0x3f8
80108bae:	e8 a2 ff ff ff       	call   80108b55 <outb>
80108bb3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108bb6:	6a 00                	push   $0x0
80108bb8:	68 f9 03 00 00       	push   $0x3f9
80108bbd:	e8 93 ff ff ff       	call   80108b55 <outb>
80108bc2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108bc5:	6a 03                	push   $0x3
80108bc7:	68 fb 03 00 00       	push   $0x3fb
80108bcc:	e8 84 ff ff ff       	call   80108b55 <outb>
80108bd1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108bd4:	6a 00                	push   $0x0
80108bd6:	68 fc 03 00 00       	push   $0x3fc
80108bdb:	e8 75 ff ff ff       	call   80108b55 <outb>
80108be0:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108be3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bea:	eb 11                	jmp    80108bfd <uart_debug+0x87>
80108bec:	83 ec 0c             	sub    $0xc,%esp
80108bef:	6a 0a                	push   $0xa
80108bf1:	e8 4e a0 ff ff       	call   80102c44 <microdelay>
80108bf6:	83 c4 10             	add    $0x10,%esp
80108bf9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bfd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108c01:	7f 1a                	jg     80108c1d <uart_debug+0xa7>
80108c03:	83 ec 0c             	sub    $0xc,%esp
80108c06:	68 fd 03 00 00       	push   $0x3fd
80108c0b:	e8 28 ff ff ff       	call   80108b38 <inb>
80108c10:	83 c4 10             	add    $0x10,%esp
80108c13:	0f b6 c0             	movzbl %al,%eax
80108c16:	83 e0 20             	and    $0x20,%eax
80108c19:	85 c0                	test   %eax,%eax
80108c1b:	74 cf                	je     80108bec <uart_debug+0x76>
  outb(COM1+0, p);
80108c1d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108c21:	0f b6 c0             	movzbl %al,%eax
80108c24:	83 ec 08             	sub    $0x8,%esp
80108c27:	50                   	push   %eax
80108c28:	68 f8 03 00 00       	push   $0x3f8
80108c2d:	e8 23 ff ff ff       	call   80108b55 <outb>
80108c32:	83 c4 10             	add    $0x10,%esp
}
80108c35:	90                   	nop
80108c36:	c9                   	leave
80108c37:	c3                   	ret

80108c38 <uart_debugs>:

void uart_debugs(char *p){
80108c38:	f3 0f 1e fb          	endbr32
80108c3c:	55                   	push   %ebp
80108c3d:	89 e5                	mov    %esp,%ebp
80108c3f:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108c42:	eb 1b                	jmp    80108c5f <uart_debugs+0x27>
    uart_debug(*p++);
80108c44:	8b 45 08             	mov    0x8(%ebp),%eax
80108c47:	8d 50 01             	lea    0x1(%eax),%edx
80108c4a:	89 55 08             	mov    %edx,0x8(%ebp)
80108c4d:	0f b6 00             	movzbl (%eax),%eax
80108c50:	0f be c0             	movsbl %al,%eax
80108c53:	83 ec 0c             	sub    $0xc,%esp
80108c56:	50                   	push   %eax
80108c57:	e8 1a ff ff ff       	call   80108b76 <uart_debug>
80108c5c:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c62:	0f b6 00             	movzbl (%eax),%eax
80108c65:	84 c0                	test   %al,%al
80108c67:	75 db                	jne    80108c44 <uart_debugs+0xc>
  }
}
80108c69:	90                   	nop
80108c6a:	90                   	nop
80108c6b:	c9                   	leave
80108c6c:	c3                   	ret

80108c6d <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108c6d:	f3 0f 1e fb          	endbr32
80108c71:	55                   	push   %ebp
80108c72:	89 e5                	mov    %esp,%ebp
80108c74:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108c77:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108c7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c81:	8b 50 14             	mov    0x14(%eax),%edx
80108c84:	8b 40 10             	mov    0x10(%eax),%eax
80108c87:	a3 98 9d 19 80       	mov    %eax,0x80199d98
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c8f:	8b 50 1c             	mov    0x1c(%eax),%edx
80108c92:	8b 40 18             	mov    0x18(%eax),%eax
80108c95:	a3 a0 9d 19 80       	mov    %eax,0x80199da0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108c9a:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108c9f:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108ca4:	29 c2                	sub    %eax,%edx
80108ca6:	89 d0                	mov    %edx,%eax
80108ca8:	a3 9c 9d 19 80       	mov    %eax,0x80199d9c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cb0:	8b 50 24             	mov    0x24(%eax),%edx
80108cb3:	8b 40 20             	mov    0x20(%eax),%eax
80108cb6:	a3 a4 9d 19 80       	mov    %eax,0x80199da4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cbe:	8b 50 2c             	mov    0x2c(%eax),%edx
80108cc1:	8b 40 28             	mov    0x28(%eax),%eax
80108cc4:	a3 a8 9d 19 80       	mov    %eax,0x80199da8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108cc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ccc:	8b 50 34             	mov    0x34(%eax),%edx
80108ccf:	8b 40 30             	mov    0x30(%eax),%eax
80108cd2:	a3 ac 9d 19 80       	mov    %eax,0x80199dac
}
80108cd7:	90                   	nop
80108cd8:	c9                   	leave
80108cd9:	c3                   	ret

80108cda <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108cda:	f3 0f 1e fb          	endbr32
80108cde:	55                   	push   %ebp
80108cdf:	89 e5                	mov    %esp,%ebp
80108ce1:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108ce4:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ced:	0f af d0             	imul   %eax,%edx
80108cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf3:	01 d0                	add    %edx,%eax
80108cf5:	c1 e0 02             	shl    $0x2,%eax
80108cf8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108cfb:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108d01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108d04:	01 d0                	add    %edx,%eax
80108d06:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108d09:	8b 45 10             	mov    0x10(%ebp),%eax
80108d0c:	0f b6 10             	movzbl (%eax),%edx
80108d0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d12:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108d14:	8b 45 10             	mov    0x10(%ebp),%eax
80108d17:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108d1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d1e:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108d21:	8b 45 10             	mov    0x10(%ebp),%eax
80108d24:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108d28:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d2b:	88 50 02             	mov    %dl,0x2(%eax)
}
80108d2e:	90                   	nop
80108d2f:	c9                   	leave
80108d30:	c3                   	ret

80108d31 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108d31:	f3 0f 1e fb          	endbr32
80108d35:	55                   	push   %ebp
80108d36:	89 e5                	mov    %esp,%ebp
80108d38:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108d3b:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108d41:	8b 45 08             	mov    0x8(%ebp),%eax
80108d44:	0f af c2             	imul   %edx,%eax
80108d47:	c1 e0 02             	shl    $0x2,%eax
80108d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108d4d:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d56:	29 c2                	sub    %eax,%edx
80108d58:	89 d0                	mov    %edx,%eax
80108d5a:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d63:	01 ca                	add    %ecx,%edx
80108d65:	89 d1                	mov    %edx,%ecx
80108d67:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108d6d:	83 ec 04             	sub    $0x4,%esp
80108d70:	50                   	push   %eax
80108d71:	51                   	push   %ecx
80108d72:	52                   	push   %edx
80108d73:	e8 2b c9 ff ff       	call   801056a3 <memmove>
80108d78:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7e:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108d84:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108d8a:	01 d1                	add    %edx,%ecx
80108d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d8f:	29 d1                	sub    %edx,%ecx
80108d91:	89 ca                	mov    %ecx,%edx
80108d93:	83 ec 04             	sub    $0x4,%esp
80108d96:	50                   	push   %eax
80108d97:	6a 00                	push   $0x0
80108d99:	52                   	push   %edx
80108d9a:	e8 3d c8 ff ff       	call   801055dc <memset>
80108d9f:	83 c4 10             	add    $0x10,%esp
}
80108da2:	90                   	nop
80108da3:	c9                   	leave
80108da4:	c3                   	ret

80108da5 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108da5:	f3 0f 1e fb          	endbr32
80108da9:	55                   	push   %ebp
80108daa:	89 e5                	mov    %esp,%ebp
80108dac:	53                   	push   %ebx
80108dad:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108db0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108db7:	e9 b1 00 00 00       	jmp    80108e6d <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108dbc:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108dc3:	e9 97 00 00 00       	jmp    80108e5f <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108dc8:	8b 45 10             	mov    0x10(%ebp),%eax
80108dcb:	83 e8 20             	sub    $0x20,%eax
80108dce:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd4:	01 d0                	add    %edx,%eax
80108dd6:	0f b7 84 00 c0 b7 10 	movzwl -0x7fef4840(%eax,%eax,1),%eax
80108ddd:	80 
80108dde:	0f b7 d0             	movzwl %ax,%edx
80108de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108de4:	bb 01 00 00 00       	mov    $0x1,%ebx
80108de9:	89 c1                	mov    %eax,%ecx
80108deb:	d3 e3                	shl    %cl,%ebx
80108ded:	89 d8                	mov    %ebx,%eax
80108def:	21 d0                	and    %edx,%eax
80108df1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df7:	ba 01 00 00 00       	mov    $0x1,%edx
80108dfc:	89 c1                	mov    %eax,%ecx
80108dfe:	d3 e2                	shl    %cl,%edx
80108e00:	89 d0                	mov    %edx,%eax
80108e02:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108e05:	75 2b                	jne    80108e32 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108e07:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0d:	01 c2                	add    %eax,%edx
80108e0f:	b8 0e 00 00 00       	mov    $0xe,%eax
80108e14:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108e17:	89 c1                	mov    %eax,%ecx
80108e19:	8b 45 08             	mov    0x8(%ebp),%eax
80108e1c:	01 c8                	add    %ecx,%eax
80108e1e:	83 ec 04             	sub    $0x4,%esp
80108e21:	68 00 05 11 80       	push   $0x80110500
80108e26:	52                   	push   %edx
80108e27:	50                   	push   %eax
80108e28:	e8 ad fe ff ff       	call   80108cda <graphic_draw_pixel>
80108e2d:	83 c4 10             	add    $0x10,%esp
80108e30:	eb 29                	jmp    80108e5b <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108e32:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e38:	01 c2                	add    %eax,%edx
80108e3a:	b8 0e 00 00 00       	mov    $0xe,%eax
80108e3f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108e42:	89 c1                	mov    %eax,%ecx
80108e44:	8b 45 08             	mov    0x8(%ebp),%eax
80108e47:	01 c8                	add    %ecx,%eax
80108e49:	83 ec 04             	sub    $0x4,%esp
80108e4c:	68 84 e0 18 80       	push   $0x8018e084
80108e51:	52                   	push   %edx
80108e52:	50                   	push   %eax
80108e53:	e8 82 fe ff ff       	call   80108cda <graphic_draw_pixel>
80108e58:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108e5b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108e5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e63:	0f 89 5f ff ff ff    	jns    80108dc8 <font_render+0x23>
  for(int i=0;i<30;i++){
80108e69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e6d:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108e71:	0f 8e 45 ff ff ff    	jle    80108dbc <font_render+0x17>
      }
    }
  }
}
80108e77:	90                   	nop
80108e78:	90                   	nop
80108e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e7c:	c9                   	leave
80108e7d:	c3                   	ret

80108e7e <font_render_string>:

void font_render_string(char *string,int row){
80108e7e:	f3 0f 1e fb          	endbr32
80108e82:	55                   	push   %ebp
80108e83:	89 e5                	mov    %esp,%ebp
80108e85:	53                   	push   %ebx
80108e86:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108e89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108e90:	eb 33                	jmp    80108ec5 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e95:	8b 45 08             	mov    0x8(%ebp),%eax
80108e98:	01 d0                	add    %edx,%eax
80108e9a:	0f b6 00             	movzbl (%eax),%eax
80108e9d:	0f be d8             	movsbl %al,%ebx
80108ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ea3:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108ea6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ea9:	89 d0                	mov    %edx,%eax
80108eab:	c1 e0 04             	shl    $0x4,%eax
80108eae:	29 d0                	sub    %edx,%eax
80108eb0:	83 c0 02             	add    $0x2,%eax
80108eb3:	83 ec 04             	sub    $0x4,%esp
80108eb6:	53                   	push   %ebx
80108eb7:	51                   	push   %ecx
80108eb8:	50                   	push   %eax
80108eb9:	e8 e7 fe ff ff       	call   80108da5 <font_render>
80108ebe:	83 c4 10             	add    $0x10,%esp
    i++;
80108ec1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108ec5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ecb:	01 d0                	add    %edx,%eax
80108ecd:	0f b6 00             	movzbl (%eax),%eax
80108ed0:	84 c0                	test   %al,%al
80108ed2:	74 06                	je     80108eda <font_render_string+0x5c>
80108ed4:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108ed8:	7e b8                	jle    80108e92 <font_render_string+0x14>
  }
}
80108eda:	90                   	nop
80108edb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ede:	c9                   	leave
80108edf:	c3                   	ret

80108ee0 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108ee0:	f3 0f 1e fb          	endbr32
80108ee4:	55                   	push   %ebp
80108ee5:	89 e5                	mov    %esp,%ebp
80108ee7:	53                   	push   %ebx
80108ee8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108eeb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ef2:	eb 6b                	jmp    80108f5f <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108ef4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108efb:	eb 58                	jmp    80108f55 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108efd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108f04:	eb 45                	jmp    80108f4b <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108f06:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108f09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0f:	83 ec 0c             	sub    $0xc,%esp
80108f12:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108f15:	53                   	push   %ebx
80108f16:	6a 00                	push   $0x0
80108f18:	51                   	push   %ecx
80108f19:	52                   	push   %edx
80108f1a:	50                   	push   %eax
80108f1b:	e8 c0 00 00 00       	call   80108fe0 <pci_access_config>
80108f20:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108f23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f26:	0f b7 c0             	movzwl %ax,%eax
80108f29:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108f2e:	74 17                	je     80108f47 <pci_init+0x67>
        pci_init_device(i,j,k);
80108f30:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108f33:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f39:	83 ec 04             	sub    $0x4,%esp
80108f3c:	51                   	push   %ecx
80108f3d:	52                   	push   %edx
80108f3e:	50                   	push   %eax
80108f3f:	e8 4f 01 00 00       	call   80109093 <pci_init_device>
80108f44:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108f47:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f4b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108f4f:	7e b5                	jle    80108f06 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108f51:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f55:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108f59:	7e a2                	jle    80108efd <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108f5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f5f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f66:	7e 8c                	jle    80108ef4 <pci_init+0x14>
      }
      }
    }
  }
}
80108f68:	90                   	nop
80108f69:	90                   	nop
80108f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f6d:	c9                   	leave
80108f6e:	c3                   	ret

80108f6f <pci_write_config>:

void pci_write_config(uint config){
80108f6f:	f3 0f 1e fb          	endbr32
80108f73:	55                   	push   %ebp
80108f74:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108f76:	8b 45 08             	mov    0x8(%ebp),%eax
80108f79:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108f7e:	89 c0                	mov    %eax,%eax
80108f80:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108f81:	90                   	nop
80108f82:	5d                   	pop    %ebp
80108f83:	c3                   	ret

80108f84 <pci_write_data>:

void pci_write_data(uint config){
80108f84:	f3 0f 1e fb          	endbr32
80108f88:	55                   	push   %ebp
80108f89:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f8e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108f93:	89 c0                	mov    %eax,%eax
80108f95:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108f96:	90                   	nop
80108f97:	5d                   	pop    %ebp
80108f98:	c3                   	ret

80108f99 <pci_read_config>:
uint pci_read_config(){
80108f99:	f3 0f 1e fb          	endbr32
80108f9d:	55                   	push   %ebp
80108f9e:	89 e5                	mov    %esp,%ebp
80108fa0:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108fa3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108fa8:	ed                   	in     (%dx),%eax
80108fa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108fac:	83 ec 0c             	sub    $0xc,%esp
80108faf:	68 c8 00 00 00       	push   $0xc8
80108fb4:	e8 8b 9c ff ff       	call   80102c44 <microdelay>
80108fb9:	83 c4 10             	add    $0x10,%esp
  return data;
80108fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108fbf:	c9                   	leave
80108fc0:	c3                   	ret

80108fc1 <pci_test>:


void pci_test(){
80108fc1:	f3 0f 1e fb          	endbr32
80108fc5:	55                   	push   %ebp
80108fc6:	89 e5                	mov    %esp,%ebp
80108fc8:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108fcb:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108fd2:	ff 75 fc             	push   -0x4(%ebp)
80108fd5:	e8 95 ff ff ff       	call   80108f6f <pci_write_config>
80108fda:	83 c4 04             	add    $0x4,%esp
}
80108fdd:	90                   	nop
80108fde:	c9                   	leave
80108fdf:	c3                   	ret

80108fe0 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108fe0:	f3 0f 1e fb          	endbr32
80108fe4:	55                   	push   %ebp
80108fe5:	89 e5                	mov    %esp,%ebp
80108fe7:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108fea:	8b 45 08             	mov    0x8(%ebp),%eax
80108fed:	c1 e0 10             	shl    $0x10,%eax
80108ff0:	25 00 00 ff 00       	and    $0xff0000,%eax
80108ff5:	89 c2                	mov    %eax,%edx
80108ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ffa:	c1 e0 0b             	shl    $0xb,%eax
80108ffd:	0f b7 c0             	movzwl %ax,%eax
80109000:	09 c2                	or     %eax,%edx
80109002:	8b 45 10             	mov    0x10(%ebp),%eax
80109005:	c1 e0 08             	shl    $0x8,%eax
80109008:	25 00 07 00 00       	and    $0x700,%eax
8010900d:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010900f:	8b 45 14             	mov    0x14(%ebp),%eax
80109012:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109017:	09 d0                	or     %edx,%eax
80109019:	0d 00 00 00 80       	or     $0x80000000,%eax
8010901e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80109021:	ff 75 f4             	push   -0xc(%ebp)
80109024:	e8 46 ff ff ff       	call   80108f6f <pci_write_config>
80109029:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010902c:	e8 68 ff ff ff       	call   80108f99 <pci_read_config>
80109031:	8b 55 18             	mov    0x18(%ebp),%edx
80109034:	89 02                	mov    %eax,(%edx)
}
80109036:	90                   	nop
80109037:	c9                   	leave
80109038:	c3                   	ret

80109039 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80109039:	f3 0f 1e fb          	endbr32
8010903d:	55                   	push   %ebp
8010903e:	89 e5                	mov    %esp,%ebp
80109040:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109043:	8b 45 08             	mov    0x8(%ebp),%eax
80109046:	c1 e0 10             	shl    $0x10,%eax
80109049:	25 00 00 ff 00       	and    $0xff0000,%eax
8010904e:	89 c2                	mov    %eax,%edx
80109050:	8b 45 0c             	mov    0xc(%ebp),%eax
80109053:	c1 e0 0b             	shl    $0xb,%eax
80109056:	0f b7 c0             	movzwl %ax,%eax
80109059:	09 c2                	or     %eax,%edx
8010905b:	8b 45 10             	mov    0x10(%ebp),%eax
8010905e:	c1 e0 08             	shl    $0x8,%eax
80109061:	25 00 07 00 00       	and    $0x700,%eax
80109066:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80109068:	8b 45 14             	mov    0x14(%ebp),%eax
8010906b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109070:	09 d0                	or     %edx,%eax
80109072:	0d 00 00 00 80       	or     $0x80000000,%eax
80109077:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010907a:	ff 75 fc             	push   -0x4(%ebp)
8010907d:	e8 ed fe ff ff       	call   80108f6f <pci_write_config>
80109082:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80109085:	ff 75 18             	push   0x18(%ebp)
80109088:	e8 f7 fe ff ff       	call   80108f84 <pci_write_data>
8010908d:	83 c4 04             	add    $0x4,%esp
}
80109090:	90                   	nop
80109091:	c9                   	leave
80109092:	c3                   	ret

80109093 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80109093:	f3 0f 1e fb          	endbr32
80109097:	55                   	push   %ebp
80109098:	89 e5                	mov    %esp,%ebp
8010909a:	53                   	push   %ebx
8010909b:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010909e:	8b 45 08             	mov    0x8(%ebp),%eax
801090a1:	a2 b0 9d 19 80       	mov    %al,0x80199db0
  dev.device_num = device_num;
801090a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801090a9:	a2 b1 9d 19 80       	mov    %al,0x80199db1
  dev.function_num = function_num;
801090ae:	8b 45 10             	mov    0x10(%ebp),%eax
801090b1:	a2 b2 9d 19 80       	mov    %al,0x80199db2
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801090b6:	ff 75 10             	push   0x10(%ebp)
801090b9:	ff 75 0c             	push   0xc(%ebp)
801090bc:	ff 75 08             	push   0x8(%ebp)
801090bf:	68 04 ce 10 80       	push   $0x8010ce04
801090c4:	e8 43 73 ff ff       	call   8010040c <cprintf>
801090c9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801090cc:	83 ec 0c             	sub    $0xc,%esp
801090cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090d2:	50                   	push   %eax
801090d3:	6a 00                	push   $0x0
801090d5:	ff 75 10             	push   0x10(%ebp)
801090d8:	ff 75 0c             	push   0xc(%ebp)
801090db:	ff 75 08             	push   0x8(%ebp)
801090de:	e8 fd fe ff ff       	call   80108fe0 <pci_access_config>
801090e3:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801090e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090e9:	c1 e8 10             	shr    $0x10,%eax
801090ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801090ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090f2:	25 ff ff 00 00       	and    $0xffff,%eax
801090f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801090fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fd:	a3 b4 9d 19 80       	mov    %eax,0x80199db4
  dev.vendor_id = vendor_id;
80109102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109105:	a3 b8 9d 19 80       	mov    %eax,0x80199db8
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010910a:	83 ec 04             	sub    $0x4,%esp
8010910d:	ff 75 f0             	push   -0x10(%ebp)
80109110:	ff 75 f4             	push   -0xc(%ebp)
80109113:	68 38 ce 10 80       	push   $0x8010ce38
80109118:	e8 ef 72 ff ff       	call   8010040c <cprintf>
8010911d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80109120:	83 ec 0c             	sub    $0xc,%esp
80109123:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109126:	50                   	push   %eax
80109127:	6a 08                	push   $0x8
80109129:	ff 75 10             	push   0x10(%ebp)
8010912c:	ff 75 0c             	push   0xc(%ebp)
8010912f:	ff 75 08             	push   0x8(%ebp)
80109132:	e8 a9 fe ff ff       	call   80108fe0 <pci_access_config>
80109137:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010913a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010913d:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80109140:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109143:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109146:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80109149:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010914c:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010914f:	0f b6 c0             	movzbl %al,%eax
80109152:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80109155:	c1 eb 18             	shr    $0x18,%ebx
80109158:	83 ec 0c             	sub    $0xc,%esp
8010915b:	51                   	push   %ecx
8010915c:	52                   	push   %edx
8010915d:	50                   	push   %eax
8010915e:	53                   	push   %ebx
8010915f:	68 5c ce 10 80       	push   $0x8010ce5c
80109164:	e8 a3 72 ff ff       	call   8010040c <cprintf>
80109169:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010916c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010916f:	c1 e8 18             	shr    $0x18,%eax
80109172:	a2 bc 9d 19 80       	mov    %al,0x80199dbc
  dev.sub_class = (data>>16)&0xFF;
80109177:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010917a:	c1 e8 10             	shr    $0x10,%eax
8010917d:	a2 bd 9d 19 80       	mov    %al,0x80199dbd
  dev.interface = (data>>8)&0xFF;
80109182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109185:	c1 e8 08             	shr    $0x8,%eax
80109188:	a2 be 9d 19 80       	mov    %al,0x80199dbe
  dev.revision_id = data&0xFF;
8010918d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109190:	a2 bf 9d 19 80       	mov    %al,0x80199dbf
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80109195:	83 ec 0c             	sub    $0xc,%esp
80109198:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010919b:	50                   	push   %eax
8010919c:	6a 10                	push   $0x10
8010919e:	ff 75 10             	push   0x10(%ebp)
801091a1:	ff 75 0c             	push   0xc(%ebp)
801091a4:	ff 75 08             	push   0x8(%ebp)
801091a7:	e8 34 fe ff ff       	call   80108fe0 <pci_access_config>
801091ac:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801091af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091b2:	a3 c0 9d 19 80       	mov    %eax,0x80199dc0
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801091b7:	83 ec 0c             	sub    $0xc,%esp
801091ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091bd:	50                   	push   %eax
801091be:	6a 14                	push   $0x14
801091c0:	ff 75 10             	push   0x10(%ebp)
801091c3:	ff 75 0c             	push   0xc(%ebp)
801091c6:	ff 75 08             	push   0x8(%ebp)
801091c9:	e8 12 fe ff ff       	call   80108fe0 <pci_access_config>
801091ce:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801091d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d4:	a3 c4 9d 19 80       	mov    %eax,0x80199dc4
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801091d9:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801091e0:	75 5a                	jne    8010923c <pci_init_device+0x1a9>
801091e2:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801091e9:	75 51                	jne    8010923c <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801091eb:	83 ec 0c             	sub    $0xc,%esp
801091ee:	68 a1 ce 10 80       	push   $0x8010cea1
801091f3:	e8 14 72 ff ff       	call   8010040c <cprintf>
801091f8:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801091fb:	83 ec 0c             	sub    $0xc,%esp
801091fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109201:	50                   	push   %eax
80109202:	68 f0 00 00 00       	push   $0xf0
80109207:	ff 75 10             	push   0x10(%ebp)
8010920a:	ff 75 0c             	push   0xc(%ebp)
8010920d:	ff 75 08             	push   0x8(%ebp)
80109210:	e8 cb fd ff ff       	call   80108fe0 <pci_access_config>
80109215:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80109218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010921b:	83 ec 08             	sub    $0x8,%esp
8010921e:	50                   	push   %eax
8010921f:	68 bb ce 10 80       	push   $0x8010cebb
80109224:	e8 e3 71 ff ff       	call   8010040c <cprintf>
80109229:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010922c:	83 ec 0c             	sub    $0xc,%esp
8010922f:	68 b0 9d 19 80       	push   $0x80199db0
80109234:	e8 09 00 00 00       	call   80109242 <i8254_init>
80109239:	83 c4 10             	add    $0x10,%esp
  }
}
8010923c:	90                   	nop
8010923d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109240:	c9                   	leave
80109241:	c3                   	ret

80109242 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80109242:	f3 0f 1e fb          	endbr32
80109246:	55                   	push   %ebp
80109247:	89 e5                	mov    %esp,%ebp
80109249:	53                   	push   %ebx
8010924a:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010924d:	8b 45 08             	mov    0x8(%ebp),%eax
80109250:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109254:	0f b6 c8             	movzbl %al,%ecx
80109257:	8b 45 08             	mov    0x8(%ebp),%eax
8010925a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010925e:	0f b6 d0             	movzbl %al,%edx
80109261:	8b 45 08             	mov    0x8(%ebp),%eax
80109264:	0f b6 00             	movzbl (%eax),%eax
80109267:	0f b6 c0             	movzbl %al,%eax
8010926a:	83 ec 0c             	sub    $0xc,%esp
8010926d:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80109270:	53                   	push   %ebx
80109271:	6a 04                	push   $0x4
80109273:	51                   	push   %ecx
80109274:	52                   	push   %edx
80109275:	50                   	push   %eax
80109276:	e8 65 fd ff ff       	call   80108fe0 <pci_access_config>
8010927b:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010927e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109281:	83 c8 04             	or     $0x4,%eax
80109284:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80109287:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010928a:	8b 45 08             	mov    0x8(%ebp),%eax
8010928d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109291:	0f b6 c8             	movzbl %al,%ecx
80109294:	8b 45 08             	mov    0x8(%ebp),%eax
80109297:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010929b:	0f b6 d0             	movzbl %al,%edx
8010929e:	8b 45 08             	mov    0x8(%ebp),%eax
801092a1:	0f b6 00             	movzbl (%eax),%eax
801092a4:	0f b6 c0             	movzbl %al,%eax
801092a7:	83 ec 0c             	sub    $0xc,%esp
801092aa:	53                   	push   %ebx
801092ab:	6a 04                	push   $0x4
801092ad:	51                   	push   %ecx
801092ae:	52                   	push   %edx
801092af:	50                   	push   %eax
801092b0:	e8 84 fd ff ff       	call   80109039 <pci_write_config_register>
801092b5:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801092b8:	8b 45 08             	mov    0x8(%ebp),%eax
801092bb:	8b 40 10             	mov    0x10(%eax),%eax
801092be:	05 00 00 00 40       	add    $0x40000000,%eax
801092c3:	a3 c8 9d 19 80       	mov    %eax,0x80199dc8
  uint *ctrl = (uint *)base_addr;
801092c8:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801092d0:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092d5:	05 d8 00 00 00       	add    $0xd8,%eax
801092da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801092dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e0:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801092e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e9:	8b 00                	mov    (%eax),%eax
801092eb:	0d 00 00 00 04       	or     $0x4000000,%eax
801092f0:	89 c2                	mov    %eax,%edx
801092f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f5:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801092f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092fa:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80109300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109303:	8b 00                	mov    (%eax),%eax
80109305:	83 c8 40             	or     $0x40,%eax
80109308:	89 c2                	mov    %eax,%edx
8010930a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930d:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010930f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109312:	8b 10                	mov    (%eax),%edx
80109314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109317:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80109319:	83 ec 0c             	sub    $0xc,%esp
8010931c:	68 d0 ce 10 80       	push   $0x8010ced0
80109321:	e8 e6 70 ff ff       	call   8010040c <cprintf>
80109326:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80109329:	e8 64 95 ff ff       	call   80102892 <kalloc>
8010932e:	a3 cc 9d 19 80       	mov    %eax,0x80199dcc
  *intr_addr = 0;
80109333:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109338:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010933e:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109343:	83 ec 08             	sub    $0x8,%esp
80109346:	50                   	push   %eax
80109347:	68 f2 ce 10 80       	push   $0x8010cef2
8010934c:	e8 bb 70 ff ff       	call   8010040c <cprintf>
80109351:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109354:	e8 50 00 00 00       	call   801093a9 <i8254_init_recv>
  i8254_init_send();
80109359:	e8 6d 03 00 00       	call   801096cb <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010935e:	0f b6 05 07 05 11 80 	movzbl 0x80110507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109365:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80109368:	0f b6 05 06 05 11 80 	movzbl 0x80110506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010936f:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109372:	0f b6 05 05 05 11 80 	movzbl 0x80110505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109379:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010937c:	0f b6 05 04 05 11 80 	movzbl 0x80110504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109383:	0f b6 c0             	movzbl %al,%eax
80109386:	83 ec 0c             	sub    $0xc,%esp
80109389:	53                   	push   %ebx
8010938a:	51                   	push   %ecx
8010938b:	52                   	push   %edx
8010938c:	50                   	push   %eax
8010938d:	68 00 cf 10 80       	push   $0x8010cf00
80109392:	e8 75 70 ff ff       	call   8010040c <cprintf>
80109397:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010939a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801093a3:	90                   	nop
801093a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801093a7:	c9                   	leave
801093a8:	c3                   	ret

801093a9 <i8254_init_recv>:

void i8254_init_recv(){
801093a9:	f3 0f 1e fb          	endbr32
801093ad:	55                   	push   %ebp
801093ae:	89 e5                	mov    %esp,%ebp
801093b0:	57                   	push   %edi
801093b1:	56                   	push   %esi
801093b2:	53                   	push   %ebx
801093b3:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801093b6:	83 ec 0c             	sub    $0xc,%esp
801093b9:	6a 00                	push   $0x0
801093bb:	e8 ec 04 00 00       	call   801098ac <i8254_read_eeprom>
801093c0:	83 c4 10             	add    $0x10,%esp
801093c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801093c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093c9:	a2 88 e0 18 80       	mov    %al,0x8018e088
  mac_addr[1] = data_l>>8;
801093ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093d1:	c1 e8 08             	shr    $0x8,%eax
801093d4:	a2 89 e0 18 80       	mov    %al,0x8018e089
  uint data_m = i8254_read_eeprom(0x1);
801093d9:	83 ec 0c             	sub    $0xc,%esp
801093dc:	6a 01                	push   $0x1
801093de:	e8 c9 04 00 00       	call   801098ac <i8254_read_eeprom>
801093e3:	83 c4 10             	add    $0x10,%esp
801093e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801093e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093ec:	a2 8a e0 18 80       	mov    %al,0x8018e08a
  mac_addr[3] = data_m>>8;
801093f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093f4:	c1 e8 08             	shr    $0x8,%eax
801093f7:	a2 8b e0 18 80       	mov    %al,0x8018e08b
  uint data_h = i8254_read_eeprom(0x2);
801093fc:	83 ec 0c             	sub    $0xc,%esp
801093ff:	6a 02                	push   $0x2
80109401:	e8 a6 04 00 00       	call   801098ac <i8254_read_eeprom>
80109406:	83 c4 10             	add    $0x10,%esp
80109409:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010940c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010940f:	a2 8c e0 18 80       	mov    %al,0x8018e08c
  mac_addr[5] = data_h>>8;
80109414:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109417:	c1 e8 08             	shr    $0x8,%eax
8010941a:	a2 8d e0 18 80       	mov    %al,0x8018e08d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010941f:	0f b6 05 8d e0 18 80 	movzbl 0x8018e08d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109426:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80109429:	0f b6 05 8c e0 18 80 	movzbl 0x8018e08c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109430:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109433:	0f b6 05 8b e0 18 80 	movzbl 0x8018e08b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010943a:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010943d:	0f b6 05 8a e0 18 80 	movzbl 0x8018e08a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109444:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80109447:	0f b6 05 89 e0 18 80 	movzbl 0x8018e089,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010944e:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109451:	0f b6 05 88 e0 18 80 	movzbl 0x8018e088,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109458:	0f b6 c0             	movzbl %al,%eax
8010945b:	83 ec 04             	sub    $0x4,%esp
8010945e:	57                   	push   %edi
8010945f:	56                   	push   %esi
80109460:	53                   	push   %ebx
80109461:	51                   	push   %ecx
80109462:	52                   	push   %edx
80109463:	50                   	push   %eax
80109464:	68 18 cf 10 80       	push   $0x8010cf18
80109469:	e8 9e 6f ff ff       	call   8010040c <cprintf>
8010946e:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109471:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109476:	05 00 54 00 00       	add    $0x5400,%eax
8010947b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010947e:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109483:	05 04 54 00 00       	add    $0x5404,%eax
80109488:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010948b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010948e:	c1 e0 10             	shl    $0x10,%eax
80109491:	0b 45 d8             	or     -0x28(%ebp),%eax
80109494:	89 c2                	mov    %eax,%edx
80109496:	8b 45 cc             	mov    -0x34(%ebp),%eax
80109499:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010949b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010949e:	0d 00 00 00 80       	or     $0x80000000,%eax
801094a3:	89 c2                	mov    %eax,%edx
801094a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801094a8:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801094aa:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094af:	05 00 52 00 00       	add    $0x5200,%eax
801094b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801094b7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801094be:	eb 19                	jmp    801094d9 <i8254_init_recv+0x130>
    mta[i] = 0;
801094c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801094c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094ca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801094cd:	01 d0                	add    %edx,%eax
801094cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801094d5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801094d9:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801094dd:	7e e1                	jle    801094c0 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801094df:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094e4:	05 d0 00 00 00       	add    $0xd0,%eax
801094e9:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801094ec:	8b 45 c0             	mov    -0x40(%ebp),%eax
801094ef:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801094f5:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094fa:	05 c8 00 00 00       	add    $0xc8,%eax
801094ff:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109502:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109505:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010950b:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109510:	05 28 28 00 00       	add    $0x2828,%eax
80109515:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109518:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010951b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109521:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109526:	05 00 01 00 00       	add    $0x100,%eax
8010952b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010952e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109531:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109537:	e8 56 93 ff ff       	call   80102892 <kalloc>
8010953c:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010953f:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109544:	05 00 28 00 00       	add    $0x2800,%eax
80109549:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010954c:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109551:	05 04 28 00 00       	add    $0x2804,%eax
80109556:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80109559:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010955e:	05 08 28 00 00       	add    $0x2808,%eax
80109563:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109566:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010956b:	05 10 28 00 00       	add    $0x2810,%eax
80109570:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109573:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109578:	05 18 28 00 00       	add    $0x2818,%eax
8010957d:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109580:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109583:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109589:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010958c:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010958e:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109591:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80109597:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010959a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801095a0:	8b 45 a0             	mov    -0x60(%ebp),%eax
801095a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801095a9:	8b 45 9c             	mov    -0x64(%ebp),%eax
801095ac:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801095b2:	8b 45 b0             	mov    -0x50(%ebp),%eax
801095b5:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801095b8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801095bf:	eb 73                	jmp    80109634 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
801095c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095c4:	c1 e0 04             	shl    $0x4,%eax
801095c7:	89 c2                	mov    %eax,%edx
801095c9:	8b 45 98             	mov    -0x68(%ebp),%eax
801095cc:	01 d0                	add    %edx,%eax
801095ce:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801095d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095d8:	c1 e0 04             	shl    $0x4,%eax
801095db:	89 c2                	mov    %eax,%edx
801095dd:	8b 45 98             	mov    -0x68(%ebp),%eax
801095e0:	01 d0                	add    %edx,%eax
801095e2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801095e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095eb:	c1 e0 04             	shl    $0x4,%eax
801095ee:	89 c2                	mov    %eax,%edx
801095f0:	8b 45 98             	mov    -0x68(%ebp),%eax
801095f3:	01 d0                	add    %edx,%eax
801095f5:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801095fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095fe:	c1 e0 04             	shl    $0x4,%eax
80109601:	89 c2                	mov    %eax,%edx
80109603:	8b 45 98             	mov    -0x68(%ebp),%eax
80109606:	01 d0                	add    %edx,%eax
80109608:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010960c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010960f:	c1 e0 04             	shl    $0x4,%eax
80109612:	89 c2                	mov    %eax,%edx
80109614:	8b 45 98             	mov    -0x68(%ebp),%eax
80109617:	01 d0                	add    %edx,%eax
80109619:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010961d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109620:	c1 e0 04             	shl    $0x4,%eax
80109623:	89 c2                	mov    %eax,%edx
80109625:	8b 45 98             	mov    -0x68(%ebp),%eax
80109628:	01 d0                	add    %edx,%eax
8010962a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109630:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109634:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010963b:	7e 84                	jle    801095c1 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010963d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109644:	eb 57                	jmp    8010969d <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109646:	e8 47 92 ff ff       	call   80102892 <kalloc>
8010964b:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010964e:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109652:	75 12                	jne    80109666 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109654:	83 ec 0c             	sub    $0xc,%esp
80109657:	68 38 cf 10 80       	push   $0x8010cf38
8010965c:	e8 ab 6d ff ff       	call   8010040c <cprintf>
80109661:	83 c4 10             	add    $0x10,%esp
      break;
80109664:	eb 3d                	jmp    801096a3 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109666:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109669:	c1 e0 04             	shl    $0x4,%eax
8010966c:	89 c2                	mov    %eax,%edx
8010966e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109671:	01 d0                	add    %edx,%eax
80109673:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109676:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010967c:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010967e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109681:	83 c0 01             	add    $0x1,%eax
80109684:	c1 e0 04             	shl    $0x4,%eax
80109687:	89 c2                	mov    %eax,%edx
80109689:	8b 45 98             	mov    -0x68(%ebp),%eax
8010968c:	01 d0                	add    %edx,%eax
8010968e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109691:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109697:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109699:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010969d:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801096a1:	7e a3                	jle    80109646 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
801096a3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801096a6:	8b 00                	mov    (%eax),%eax
801096a8:	83 c8 02             	or     $0x2,%eax
801096ab:	89 c2                	mov    %eax,%edx
801096ad:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801096b0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801096b2:	83 ec 0c             	sub    $0xc,%esp
801096b5:	68 58 cf 10 80       	push   $0x8010cf58
801096ba:	e8 4d 6d ff ff       	call   8010040c <cprintf>
801096bf:	83 c4 10             	add    $0x10,%esp
}
801096c2:	90                   	nop
801096c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801096c6:	5b                   	pop    %ebx
801096c7:	5e                   	pop    %esi
801096c8:	5f                   	pop    %edi
801096c9:	5d                   	pop    %ebp
801096ca:	c3                   	ret

801096cb <i8254_init_send>:

void i8254_init_send(){
801096cb:	f3 0f 1e fb          	endbr32
801096cf:	55                   	push   %ebp
801096d0:	89 e5                	mov    %esp,%ebp
801096d2:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801096d5:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096da:	05 28 38 00 00       	add    $0x3828,%eax
801096df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801096e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096e5:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801096eb:	e8 a2 91 ff ff       	call   80102892 <kalloc>
801096f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801096f3:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801096f8:	05 00 38 00 00       	add    $0x3800,%eax
801096fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109700:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109705:	05 04 38 00 00       	add    $0x3804,%eax
8010970a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010970d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109712:	05 08 38 00 00       	add    $0x3808,%eax
80109717:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010971a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010971d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109723:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109726:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109728:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010972b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109731:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109734:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010973a:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010973f:	05 10 38 00 00       	add    $0x3810,%eax
80109744:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109747:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010974c:	05 18 38 00 00       	add    $0x3818,%eax
80109751:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109754:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109757:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010975d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109760:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109766:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109769:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010976c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109773:	e9 82 00 00 00       	jmp    801097fa <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80109778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977b:	c1 e0 04             	shl    $0x4,%eax
8010977e:	89 c2                	mov    %eax,%edx
80109780:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109783:	01 d0                	add    %edx,%eax
80109785:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010978c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978f:	c1 e0 04             	shl    $0x4,%eax
80109792:	89 c2                	mov    %eax,%edx
80109794:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109797:	01 d0                	add    %edx,%eax
80109799:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010979f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a2:	c1 e0 04             	shl    $0x4,%eax
801097a5:	89 c2                	mov    %eax,%edx
801097a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097aa:	01 d0                	add    %edx,%eax
801097ac:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801097b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b3:	c1 e0 04             	shl    $0x4,%eax
801097b6:	89 c2                	mov    %eax,%edx
801097b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097bb:	01 d0                	add    %edx,%eax
801097bd:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801097c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c4:	c1 e0 04             	shl    $0x4,%eax
801097c7:	89 c2                	mov    %eax,%edx
801097c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097cc:	01 d0                	add    %edx,%eax
801097ce:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801097d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d5:	c1 e0 04             	shl    $0x4,%eax
801097d8:	89 c2                	mov    %eax,%edx
801097da:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097dd:	01 d0                	add    %edx,%eax
801097df:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801097e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e6:	c1 e0 04             	shl    $0x4,%eax
801097e9:	89 c2                	mov    %eax,%edx
801097eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097ee:	01 d0                	add    %edx,%eax
801097f0:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801097f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097fa:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109801:	0f 8e 71 ff ff ff    	jle    80109778 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109807:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010980e:	eb 57                	jmp    80109867 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80109810:	e8 7d 90 ff ff       	call   80102892 <kalloc>
80109815:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109818:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010981c:	75 12                	jne    80109830 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
8010981e:	83 ec 0c             	sub    $0xc,%esp
80109821:	68 38 cf 10 80       	push   $0x8010cf38
80109826:	e8 e1 6b ff ff       	call   8010040c <cprintf>
8010982b:	83 c4 10             	add    $0x10,%esp
      break;
8010982e:	eb 3d                	jmp    8010986d <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109833:	c1 e0 04             	shl    $0x4,%eax
80109836:	89 c2                	mov    %eax,%edx
80109838:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010983b:	01 d0                	add    %edx,%eax
8010983d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109840:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109846:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984b:	83 c0 01             	add    $0x1,%eax
8010984e:	c1 e0 04             	shl    $0x4,%eax
80109851:	89 c2                	mov    %eax,%edx
80109853:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109856:	01 d0                	add    %edx,%eax
80109858:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010985b:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109861:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109863:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109867:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010986b:	7e a3                	jle    80109810 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010986d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109872:	05 00 04 00 00       	add    $0x400,%eax
80109877:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010987a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010987d:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109883:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109888:	05 10 04 00 00       	add    $0x410,%eax
8010988d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109890:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109893:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109899:	83 ec 0c             	sub    $0xc,%esp
8010989c:	68 78 cf 10 80       	push   $0x8010cf78
801098a1:	e8 66 6b ff ff       	call   8010040c <cprintf>
801098a6:	83 c4 10             	add    $0x10,%esp

}
801098a9:	90                   	nop
801098aa:	c9                   	leave
801098ab:	c3                   	ret

801098ac <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801098ac:	f3 0f 1e fb          	endbr32
801098b0:	55                   	push   %ebp
801098b1:	89 e5                	mov    %esp,%ebp
801098b3:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801098b6:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801098bb:	83 c0 14             	add    $0x14,%eax
801098be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801098c1:	8b 45 08             	mov    0x8(%ebp),%eax
801098c4:	c1 e0 08             	shl    $0x8,%eax
801098c7:	0f b7 c0             	movzwl %ax,%eax
801098ca:	83 c8 01             	or     $0x1,%eax
801098cd:	89 c2                	mov    %eax,%edx
801098cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d2:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801098d4:	83 ec 0c             	sub    $0xc,%esp
801098d7:	68 98 cf 10 80       	push   $0x8010cf98
801098dc:	e8 2b 6b ff ff       	call   8010040c <cprintf>
801098e1:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801098e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e7:	8b 00                	mov    (%eax),%eax
801098e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801098ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ef:	83 e0 10             	and    $0x10,%eax
801098f2:	85 c0                	test   %eax,%eax
801098f4:	75 02                	jne    801098f8 <i8254_read_eeprom+0x4c>
  while(1){
801098f6:	eb dc                	jmp    801098d4 <i8254_read_eeprom+0x28>
      break;
801098f8:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801098f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fc:	8b 00                	mov    (%eax),%eax
801098fe:	c1 e8 10             	shr    $0x10,%eax
}
80109901:	c9                   	leave
80109902:	c3                   	ret

80109903 <i8254_recv>:
void i8254_recv(){
80109903:	f3 0f 1e fb          	endbr32
80109907:	55                   	push   %ebp
80109908:	89 e5                	mov    %esp,%ebp
8010990a:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010990d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109912:	05 10 28 00 00       	add    $0x2810,%eax
80109917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010991a:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010991f:	05 18 28 00 00       	add    $0x2818,%eax
80109924:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109927:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010992c:	05 00 28 00 00       	add    $0x2800,%eax
80109931:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109934:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109937:	8b 00                	mov    (%eax),%eax
80109939:	05 00 00 00 80       	add    $0x80000000,%eax
8010993e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109944:	8b 10                	mov    (%eax),%edx
80109946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109949:	8b 00                	mov    (%eax),%eax
8010994b:	29 c2                	sub    %eax,%edx
8010994d:	89 d0                	mov    %edx,%eax
8010994f:	25 ff 00 00 00       	and    $0xff,%eax
80109954:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109957:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010995b:	7e 37                	jle    80109994 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010995d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109960:	8b 00                	mov    (%eax),%eax
80109962:	c1 e0 04             	shl    $0x4,%eax
80109965:	89 c2                	mov    %eax,%edx
80109967:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010996a:	01 d0                	add    %edx,%eax
8010996c:	8b 00                	mov    (%eax),%eax
8010996e:	05 00 00 00 80       	add    $0x80000000,%eax
80109973:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109976:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109979:	8b 00                	mov    (%eax),%eax
8010997b:	83 c0 01             	add    $0x1,%eax
8010997e:	0f b6 d0             	movzbl %al,%edx
80109981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109984:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109986:	83 ec 0c             	sub    $0xc,%esp
80109989:	ff 75 e0             	push   -0x20(%ebp)
8010998c:	e8 47 09 00 00       	call   8010a2d8 <eth_proc>
80109991:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109997:	8b 10                	mov    (%eax),%edx
80109999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999c:	8b 00                	mov    (%eax),%eax
8010999e:	39 c2                	cmp    %eax,%edx
801099a0:	75 9f                	jne    80109941 <i8254_recv+0x3e>
      (*rdt)--;
801099a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a5:	8b 00                	mov    (%eax),%eax
801099a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801099aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ad:	89 10                	mov    %edx,(%eax)
  while(1){
801099af:	eb 90                	jmp    80109941 <i8254_recv+0x3e>

801099b1 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801099b1:	f3 0f 1e fb          	endbr32
801099b5:	55                   	push   %ebp
801099b6:	89 e5                	mov    %esp,%ebp
801099b8:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801099bb:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099c0:	05 10 38 00 00       	add    $0x3810,%eax
801099c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801099c8:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099cd:	05 18 38 00 00       	add    $0x3818,%eax
801099d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801099d5:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099da:	05 00 38 00 00       	add    $0x3800,%eax
801099df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801099e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099e5:	8b 00                	mov    (%eax),%eax
801099e7:	05 00 00 00 80       	add    $0x80000000,%eax
801099ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801099ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f2:	8b 10                	mov    (%eax),%edx
801099f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f7:	8b 00                	mov    (%eax),%eax
801099f9:	29 c2                	sub    %eax,%edx
801099fb:	89 d0                	mov    %edx,%eax
801099fd:	0f b6 c0             	movzbl %al,%eax
80109a00:	ba 00 01 00 00       	mov    $0x100,%edx
80109a05:	29 c2                	sub    %eax,%edx
80109a07:	89 d0                	mov    %edx,%eax
80109a09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0f:	8b 00                	mov    (%eax),%eax
80109a11:	25 ff 00 00 00       	and    $0xff,%eax
80109a16:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109a19:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109a1d:	0f 8e a8 00 00 00    	jle    80109acb <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109a23:	8b 45 08             	mov    0x8(%ebp),%eax
80109a26:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a29:	89 d1                	mov    %edx,%ecx
80109a2b:	c1 e1 04             	shl    $0x4,%ecx
80109a2e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109a31:	01 ca                	add    %ecx,%edx
80109a33:	8b 12                	mov    (%edx),%edx
80109a35:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109a3b:	83 ec 04             	sub    $0x4,%esp
80109a3e:	ff 75 0c             	push   0xc(%ebp)
80109a41:	50                   	push   %eax
80109a42:	52                   	push   %edx
80109a43:	e8 5b bc ff ff       	call   801056a3 <memmove>
80109a48:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a4e:	c1 e0 04             	shl    $0x4,%eax
80109a51:	89 c2                	mov    %eax,%edx
80109a53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a56:	01 d0                	add    %edx,%eax
80109a58:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a5b:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109a5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a62:	c1 e0 04             	shl    $0x4,%eax
80109a65:	89 c2                	mov    %eax,%edx
80109a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a6a:	01 d0                	add    %edx,%eax
80109a6c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a73:	c1 e0 04             	shl    $0x4,%eax
80109a76:	89 c2                	mov    %eax,%edx
80109a78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a7b:	01 d0                	add    %edx,%eax
80109a7d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a84:	c1 e0 04             	shl    $0x4,%eax
80109a87:	89 c2                	mov    %eax,%edx
80109a89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a8c:	01 d0                	add    %edx,%eax
80109a8e:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109a92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a95:	c1 e0 04             	shl    $0x4,%eax
80109a98:	89 c2                	mov    %eax,%edx
80109a9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a9d:	01 d0                	add    %edx,%eax
80109a9f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109aa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aa8:	c1 e0 04             	shl    $0x4,%eax
80109aab:	89 c2                	mov    %eax,%edx
80109aad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ab0:	01 d0                	add    %edx,%eax
80109ab2:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ab9:	8b 00                	mov    (%eax),%eax
80109abb:	83 c0 01             	add    $0x1,%eax
80109abe:	0f b6 d0             	movzbl %al,%edx
80109ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ac4:	89 10                	mov    %edx,(%eax)
    return len;
80109ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ac9:	eb 05                	jmp    80109ad0 <i8254_send+0x11f>
  }else{
    return -1;
80109acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109ad0:	c9                   	leave
80109ad1:	c3                   	ret

80109ad2 <i8254_intr>:

void i8254_intr(){
80109ad2:	f3 0f 1e fb          	endbr32
80109ad6:	55                   	push   %ebp
80109ad7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109ad9:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109ade:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109ae4:	90                   	nop
80109ae5:	5d                   	pop    %ebp
80109ae6:	c3                   	ret

80109ae7 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109ae7:	f3 0f 1e fb          	endbr32
80109aeb:	55                   	push   %ebp
80109aec:	89 e5                	mov    %esp,%ebp
80109aee:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109af1:	8b 45 08             	mov    0x8(%ebp),%eax
80109af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afa:	0f b7 00             	movzwl (%eax),%eax
80109afd:	66 3d 00 01          	cmp    $0x100,%ax
80109b01:	74 0a                	je     80109b0d <arp_proc+0x26>
80109b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b08:	e9 4f 01 00 00       	jmp    80109c5c <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b10:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109b14:	66 83 f8 08          	cmp    $0x8,%ax
80109b18:	74 0a                	je     80109b24 <arp_proc+0x3d>
80109b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b1f:	e9 38 01 00 00       	jmp    80109c5c <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b27:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109b2b:	3c 06                	cmp    $0x6,%al
80109b2d:	74 0a                	je     80109b39 <arp_proc+0x52>
80109b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b34:	e9 23 01 00 00       	jmp    80109c5c <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3c:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109b40:	3c 04                	cmp    $0x4,%al
80109b42:	74 0a                	je     80109b4e <arp_proc+0x67>
80109b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b49:	e9 0e 01 00 00       	jmp    80109c5c <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b51:	83 c0 18             	add    $0x18,%eax
80109b54:	83 ec 04             	sub    $0x4,%esp
80109b57:	6a 04                	push   $0x4
80109b59:	50                   	push   %eax
80109b5a:	68 04 05 11 80       	push   $0x80110504
80109b5f:	e8 e3 ba ff ff       	call   80105647 <memcmp>
80109b64:	83 c4 10             	add    $0x10,%esp
80109b67:	85 c0                	test   %eax,%eax
80109b69:	74 27                	je     80109b92 <arp_proc+0xab>
80109b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6e:	83 c0 0e             	add    $0xe,%eax
80109b71:	83 ec 04             	sub    $0x4,%esp
80109b74:	6a 04                	push   $0x4
80109b76:	50                   	push   %eax
80109b77:	68 04 05 11 80       	push   $0x80110504
80109b7c:	e8 c6 ba ff ff       	call   80105647 <memcmp>
80109b81:	83 c4 10             	add    $0x10,%esp
80109b84:	85 c0                	test   %eax,%eax
80109b86:	74 0a                	je     80109b92 <arp_proc+0xab>
80109b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b8d:	e9 ca 00 00 00       	jmp    80109c5c <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b95:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b99:	66 3d 00 01          	cmp    $0x100,%ax
80109b9d:	75 69                	jne    80109c08 <arp_proc+0x121>
80109b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba2:	83 c0 18             	add    $0x18,%eax
80109ba5:	83 ec 04             	sub    $0x4,%esp
80109ba8:	6a 04                	push   $0x4
80109baa:	50                   	push   %eax
80109bab:	68 04 05 11 80       	push   $0x80110504
80109bb0:	e8 92 ba ff ff       	call   80105647 <memcmp>
80109bb5:	83 c4 10             	add    $0x10,%esp
80109bb8:	85 c0                	test   %eax,%eax
80109bba:	75 4c                	jne    80109c08 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109bbc:	e8 d1 8c ff ff       	call   80102892 <kalloc>
80109bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109bc4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109bcb:	83 ec 04             	sub    $0x4,%esp
80109bce:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109bd1:	50                   	push   %eax
80109bd2:	ff 75 f0             	push   -0x10(%ebp)
80109bd5:	ff 75 f4             	push   -0xc(%ebp)
80109bd8:	e8 33 04 00 00       	call   8010a010 <arp_reply_pkt_create>
80109bdd:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109be3:	83 ec 08             	sub    $0x8,%esp
80109be6:	50                   	push   %eax
80109be7:	ff 75 f0             	push   -0x10(%ebp)
80109bea:	e8 c2 fd ff ff       	call   801099b1 <i8254_send>
80109bef:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bf5:	83 ec 0c             	sub    $0xc,%esp
80109bf8:	50                   	push   %eax
80109bf9:	e8 f6 8b ff ff       	call   801027f4 <kfree>
80109bfe:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109c01:	b8 02 00 00 00       	mov    $0x2,%eax
80109c06:	eb 54                	jmp    80109c5c <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c0f:	66 3d 00 02          	cmp    $0x200,%ax
80109c13:	75 42                	jne    80109c57 <arp_proc+0x170>
80109c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c18:	83 c0 18             	add    $0x18,%eax
80109c1b:	83 ec 04             	sub    $0x4,%esp
80109c1e:	6a 04                	push   $0x4
80109c20:	50                   	push   %eax
80109c21:	68 04 05 11 80       	push   $0x80110504
80109c26:	e8 1c ba ff ff       	call   80105647 <memcmp>
80109c2b:	83 c4 10             	add    $0x10,%esp
80109c2e:	85 c0                	test   %eax,%eax
80109c30:	75 25                	jne    80109c57 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109c32:	83 ec 0c             	sub    $0xc,%esp
80109c35:	68 9c cf 10 80       	push   $0x8010cf9c
80109c3a:	e8 cd 67 ff ff       	call   8010040c <cprintf>
80109c3f:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109c42:	83 ec 0c             	sub    $0xc,%esp
80109c45:	ff 75 f4             	push   -0xc(%ebp)
80109c48:	e8 b7 01 00 00       	call   80109e04 <arp_table_update>
80109c4d:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109c50:	b8 01 00 00 00       	mov    $0x1,%eax
80109c55:	eb 05                	jmp    80109c5c <arp_proc+0x175>
  }else{
    return -1;
80109c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109c5c:	c9                   	leave
80109c5d:	c3                   	ret

80109c5e <arp_scan>:

void arp_scan(){
80109c5e:	f3 0f 1e fb          	endbr32
80109c62:	55                   	push   %ebp
80109c63:	89 e5                	mov    %esp,%ebp
80109c65:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c6f:	eb 6f                	jmp    80109ce0 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109c71:	e8 1c 8c ff ff       	call   80102892 <kalloc>
80109c76:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109c79:	83 ec 04             	sub    $0x4,%esp
80109c7c:	ff 75 f4             	push   -0xc(%ebp)
80109c7f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c82:	50                   	push   %eax
80109c83:	ff 75 ec             	push   -0x14(%ebp)
80109c86:	e8 62 00 00 00       	call   80109ced <arp_broadcast>
80109c8b:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109c8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c91:	83 ec 08             	sub    $0x8,%esp
80109c94:	50                   	push   %eax
80109c95:	ff 75 ec             	push   -0x14(%ebp)
80109c98:	e8 14 fd ff ff       	call   801099b1 <i8254_send>
80109c9d:	83 c4 10             	add    $0x10,%esp
80109ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109ca3:	eb 22                	jmp    80109cc7 <arp_scan+0x69>
      microdelay(1);
80109ca5:	83 ec 0c             	sub    $0xc,%esp
80109ca8:	6a 01                	push   $0x1
80109caa:	e8 95 8f ff ff       	call   80102c44 <microdelay>
80109caf:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109cb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cb5:	83 ec 08             	sub    $0x8,%esp
80109cb8:	50                   	push   %eax
80109cb9:	ff 75 ec             	push   -0x14(%ebp)
80109cbc:	e8 f0 fc ff ff       	call   801099b1 <i8254_send>
80109cc1:	83 c4 10             	add    $0x10,%esp
80109cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109cc7:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109ccb:	74 d8                	je     80109ca5 <arp_scan+0x47>
    }
    kfree((char *)send);
80109ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cd0:	83 ec 0c             	sub    $0xc,%esp
80109cd3:	50                   	push   %eax
80109cd4:	e8 1b 8b ff ff       	call   801027f4 <kfree>
80109cd9:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109cdc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109ce0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109ce7:	7e 88                	jle    80109c71 <arp_scan+0x13>
  }
}
80109ce9:	90                   	nop
80109cea:	90                   	nop
80109ceb:	c9                   	leave
80109cec:	c3                   	ret

80109ced <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109ced:	f3 0f 1e fb          	endbr32
80109cf1:	55                   	push   %ebp
80109cf2:	89 e5                	mov    %esp,%ebp
80109cf4:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109cf7:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109cfb:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109cff:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109d03:	8b 45 10             	mov    0x10(%ebp),%eax
80109d06:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109d09:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109d10:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109d16:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109d1d:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d26:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109d32:	8b 45 08             	mov    0x8(%ebp),%eax
80109d35:	83 c0 0e             	add    $0xe,%eax
80109d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d3e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d45:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4c:	83 ec 04             	sub    $0x4,%esp
80109d4f:	6a 06                	push   $0x6
80109d51:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109d54:	52                   	push   %edx
80109d55:	50                   	push   %eax
80109d56:	e8 48 b9 ff ff       	call   801056a3 <memmove>
80109d5b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d61:	83 c0 06             	add    $0x6,%eax
80109d64:	83 ec 04             	sub    $0x4,%esp
80109d67:	6a 06                	push   $0x6
80109d69:	68 88 e0 18 80       	push   $0x8018e088
80109d6e:	50                   	push   %eax
80109d6f:	e8 2f b9 ff ff       	call   801056a3 <memmove>
80109d74:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d7a:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d82:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8b:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d92:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d99:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109da2:	8d 50 12             	lea    0x12(%eax),%edx
80109da5:	83 ec 04             	sub    $0x4,%esp
80109da8:	6a 06                	push   $0x6
80109daa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109dad:	50                   	push   %eax
80109dae:	52                   	push   %edx
80109daf:	e8 ef b8 ff ff       	call   801056a3 <memmove>
80109db4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dba:	8d 50 18             	lea    0x18(%eax),%edx
80109dbd:	83 ec 04             	sub    $0x4,%esp
80109dc0:	6a 04                	push   $0x4
80109dc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109dc5:	50                   	push   %eax
80109dc6:	52                   	push   %edx
80109dc7:	e8 d7 b8 ff ff       	call   801056a3 <memmove>
80109dcc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd2:	83 c0 08             	add    $0x8,%eax
80109dd5:	83 ec 04             	sub    $0x4,%esp
80109dd8:	6a 06                	push   $0x6
80109dda:	68 88 e0 18 80       	push   $0x8018e088
80109ddf:	50                   	push   %eax
80109de0:	e8 be b8 ff ff       	call   801056a3 <memmove>
80109de5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109deb:	83 c0 0e             	add    $0xe,%eax
80109dee:	83 ec 04             	sub    $0x4,%esp
80109df1:	6a 04                	push   $0x4
80109df3:	68 04 05 11 80       	push   $0x80110504
80109df8:	50                   	push   %eax
80109df9:	e8 a5 b8 ff ff       	call   801056a3 <memmove>
80109dfe:	83 c4 10             	add    $0x10,%esp
}
80109e01:	90                   	nop
80109e02:	c9                   	leave
80109e03:	c3                   	ret

80109e04 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109e04:	f3 0f 1e fb          	endbr32
80109e08:	55                   	push   %ebp
80109e09:	89 e5                	mov    %esp,%ebp
80109e0b:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109e11:	83 c0 0e             	add    $0xe,%eax
80109e14:	83 ec 0c             	sub    $0xc,%esp
80109e17:	50                   	push   %eax
80109e18:	e8 bc 00 00 00       	call   80109ed9 <arp_table_search>
80109e1d:	83 c4 10             	add    $0x10,%esp
80109e20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109e23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109e27:	78 2d                	js     80109e56 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e29:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2c:	8d 48 08             	lea    0x8(%eax),%ecx
80109e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e32:	89 d0                	mov    %edx,%eax
80109e34:	c1 e0 02             	shl    $0x2,%eax
80109e37:	01 d0                	add    %edx,%eax
80109e39:	01 c0                	add    %eax,%eax
80109e3b:	01 d0                	add    %edx,%eax
80109e3d:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e42:	83 c0 04             	add    $0x4,%eax
80109e45:	83 ec 04             	sub    $0x4,%esp
80109e48:	6a 06                	push   $0x6
80109e4a:	51                   	push   %ecx
80109e4b:	50                   	push   %eax
80109e4c:	e8 52 b8 ff ff       	call   801056a3 <memmove>
80109e51:	83 c4 10             	add    $0x10,%esp
80109e54:	eb 70                	jmp    80109ec6 <arp_table_update+0xc2>
  }else{
    index += 1;
80109e56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109e5a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e60:	8d 48 08             	lea    0x8(%eax),%ecx
80109e63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e66:	89 d0                	mov    %edx,%eax
80109e68:	c1 e0 02             	shl    $0x2,%eax
80109e6b:	01 d0                	add    %edx,%eax
80109e6d:	01 c0                	add    %eax,%eax
80109e6f:	01 d0                	add    %edx,%eax
80109e71:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e76:	83 c0 04             	add    $0x4,%eax
80109e79:	83 ec 04             	sub    $0x4,%esp
80109e7c:	6a 06                	push   $0x6
80109e7e:	51                   	push   %ecx
80109e7f:	50                   	push   %eax
80109e80:	e8 1e b8 ff ff       	call   801056a3 <memmove>
80109e85:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109e88:	8b 45 08             	mov    0x8(%ebp),%eax
80109e8b:	8d 48 0e             	lea    0xe(%eax),%ecx
80109e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e91:	89 d0                	mov    %edx,%eax
80109e93:	c1 e0 02             	shl    $0x2,%eax
80109e96:	01 d0                	add    %edx,%eax
80109e98:	01 c0                	add    %eax,%eax
80109e9a:	01 d0                	add    %edx,%eax
80109e9c:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109ea1:	83 ec 04             	sub    $0x4,%esp
80109ea4:	6a 04                	push   $0x4
80109ea6:	51                   	push   %ecx
80109ea7:	50                   	push   %eax
80109ea8:	e8 f6 b7 ff ff       	call   801056a3 <memmove>
80109ead:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109eb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109eb3:	89 d0                	mov    %edx,%eax
80109eb5:	c1 e0 02             	shl    $0x2,%eax
80109eb8:	01 d0                	add    %edx,%eax
80109eba:	01 c0                	add    %eax,%eax
80109ebc:	01 d0                	add    %edx,%eax
80109ebe:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109ec3:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109ec6:	83 ec 0c             	sub    $0xc,%esp
80109ec9:	68 a0 e0 18 80       	push   $0x8018e0a0
80109ece:	e8 87 00 00 00       	call   80109f5a <print_arp_table>
80109ed3:	83 c4 10             	add    $0x10,%esp
}
80109ed6:	90                   	nop
80109ed7:	c9                   	leave
80109ed8:	c3                   	ret

80109ed9 <arp_table_search>:

int arp_table_search(uchar *ip){
80109ed9:	f3 0f 1e fb          	endbr32
80109edd:	55                   	push   %ebp
80109ede:	89 e5                	mov    %esp,%ebp
80109ee0:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109ee3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109eea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109ef1:	eb 59                	jmp    80109f4c <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109ef3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ef6:	89 d0                	mov    %edx,%eax
80109ef8:	c1 e0 02             	shl    $0x2,%eax
80109efb:	01 d0                	add    %edx,%eax
80109efd:	01 c0                	add    %eax,%eax
80109eff:	01 d0                	add    %edx,%eax
80109f01:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109f06:	83 ec 04             	sub    $0x4,%esp
80109f09:	6a 04                	push   $0x4
80109f0b:	ff 75 08             	push   0x8(%ebp)
80109f0e:	50                   	push   %eax
80109f0f:	e8 33 b7 ff ff       	call   80105647 <memcmp>
80109f14:	83 c4 10             	add    $0x10,%esp
80109f17:	85 c0                	test   %eax,%eax
80109f19:	75 05                	jne    80109f20 <arp_table_search+0x47>
      return i;
80109f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f1e:	eb 38                	jmp    80109f58 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109f20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f23:	89 d0                	mov    %edx,%eax
80109f25:	c1 e0 02             	shl    $0x2,%eax
80109f28:	01 d0                	add    %edx,%eax
80109f2a:	01 c0                	add    %eax,%eax
80109f2c:	01 d0                	add    %edx,%eax
80109f2e:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109f33:	0f b6 00             	movzbl (%eax),%eax
80109f36:	84 c0                	test   %al,%al
80109f38:	75 0e                	jne    80109f48 <arp_table_search+0x6f>
80109f3a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109f3e:	75 08                	jne    80109f48 <arp_table_search+0x6f>
      empty = -i;
80109f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f43:	f7 d8                	neg    %eax
80109f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109f48:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109f4c:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109f50:	7e a1                	jle    80109ef3 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f55:	83 e8 01             	sub    $0x1,%eax
}
80109f58:	c9                   	leave
80109f59:	c3                   	ret

80109f5a <print_arp_table>:

void print_arp_table(){
80109f5a:	f3 0f 1e fb          	endbr32
80109f5e:	55                   	push   %ebp
80109f5f:	89 e5                	mov    %esp,%ebp
80109f61:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109f64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109f6b:	e9 92 00 00 00       	jmp    8010a002 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f73:	89 d0                	mov    %edx,%eax
80109f75:	c1 e0 02             	shl    $0x2,%eax
80109f78:	01 d0                	add    %edx,%eax
80109f7a:	01 c0                	add    %eax,%eax
80109f7c:	01 d0                	add    %edx,%eax
80109f7e:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109f83:	0f b6 00             	movzbl (%eax),%eax
80109f86:	84 c0                	test   %al,%al
80109f88:	74 74                	je     80109ffe <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109f8a:	83 ec 08             	sub    $0x8,%esp
80109f8d:	ff 75 f4             	push   -0xc(%ebp)
80109f90:	68 af cf 10 80       	push   $0x8010cfaf
80109f95:	e8 72 64 ff ff       	call   8010040c <cprintf>
80109f9a:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109f9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fa0:	89 d0                	mov    %edx,%eax
80109fa2:	c1 e0 02             	shl    $0x2,%eax
80109fa5:	01 d0                	add    %edx,%eax
80109fa7:	01 c0                	add    %eax,%eax
80109fa9:	01 d0                	add    %edx,%eax
80109fab:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109fb0:	83 ec 0c             	sub    $0xc,%esp
80109fb3:	50                   	push   %eax
80109fb4:	e8 5c 02 00 00       	call   8010a215 <print_ipv4>
80109fb9:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109fbc:	83 ec 0c             	sub    $0xc,%esp
80109fbf:	68 be cf 10 80       	push   $0x8010cfbe
80109fc4:	e8 43 64 ff ff       	call   8010040c <cprintf>
80109fc9:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109fcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fcf:	89 d0                	mov    %edx,%eax
80109fd1:	c1 e0 02             	shl    $0x2,%eax
80109fd4:	01 d0                	add    %edx,%eax
80109fd6:	01 c0                	add    %eax,%eax
80109fd8:	01 d0                	add    %edx,%eax
80109fda:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109fdf:	83 c0 04             	add    $0x4,%eax
80109fe2:	83 ec 0c             	sub    $0xc,%esp
80109fe5:	50                   	push   %eax
80109fe6:	e8 7c 02 00 00       	call   8010a267 <print_mac>
80109feb:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109fee:	83 ec 0c             	sub    $0xc,%esp
80109ff1:	68 c0 cf 10 80       	push   $0x8010cfc0
80109ff6:	e8 11 64 ff ff       	call   8010040c <cprintf>
80109ffb:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109ffe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a002:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010a006:	0f 8e 64 ff ff ff    	jle    80109f70 <print_arp_table+0x16>
    }
  }
}
8010a00c:	90                   	nop
8010a00d:	90                   	nop
8010a00e:	c9                   	leave
8010a00f:	c3                   	ret

8010a010 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010a010:	f3 0f 1e fb          	endbr32
8010a014:	55                   	push   %ebp
8010a015:	89 e5                	mov    %esp,%ebp
8010a017:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010a01a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a01d:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010a023:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a026:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010a029:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a02c:	83 c0 0e             	add    $0xe,%eax
8010a02f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010a032:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a035:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010a039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a03c:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010a040:	8b 45 08             	mov    0x8(%ebp),%eax
8010a043:	8d 50 08             	lea    0x8(%eax),%edx
8010a046:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a049:	83 ec 04             	sub    $0x4,%esp
8010a04c:	6a 06                	push   $0x6
8010a04e:	52                   	push   %edx
8010a04f:	50                   	push   %eax
8010a050:	e8 4e b6 ff ff       	call   801056a3 <memmove>
8010a055:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010a058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a05b:	83 c0 06             	add    $0x6,%eax
8010a05e:	83 ec 04             	sub    $0x4,%esp
8010a061:	6a 06                	push   $0x6
8010a063:	68 88 e0 18 80       	push   $0x8018e088
8010a068:	50                   	push   %eax
8010a069:	e8 35 b6 ff ff       	call   801056a3 <memmove>
8010a06e:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010a071:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a074:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010a079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a07c:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010a082:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a085:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010a089:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a08c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010a090:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a093:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010a099:	8b 45 08             	mov    0x8(%ebp),%eax
8010a09c:	8d 50 08             	lea    0x8(%eax),%edx
8010a09f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a2:	83 c0 12             	add    $0x12,%eax
8010a0a5:	83 ec 04             	sub    $0x4,%esp
8010a0a8:	6a 06                	push   $0x6
8010a0aa:	52                   	push   %edx
8010a0ab:	50                   	push   %eax
8010a0ac:	e8 f2 b5 ff ff       	call   801056a3 <memmove>
8010a0b1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010a0b4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b7:	8d 50 0e             	lea    0xe(%eax),%edx
8010a0ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0bd:	83 c0 18             	add    $0x18,%eax
8010a0c0:	83 ec 04             	sub    $0x4,%esp
8010a0c3:	6a 04                	push   $0x4
8010a0c5:	52                   	push   %edx
8010a0c6:	50                   	push   %eax
8010a0c7:	e8 d7 b5 ff ff       	call   801056a3 <memmove>
8010a0cc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010a0cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0d2:	83 c0 08             	add    $0x8,%eax
8010a0d5:	83 ec 04             	sub    $0x4,%esp
8010a0d8:	6a 06                	push   $0x6
8010a0da:	68 88 e0 18 80       	push   $0x8018e088
8010a0df:	50                   	push   %eax
8010a0e0:	e8 be b5 ff ff       	call   801056a3 <memmove>
8010a0e5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010a0e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0eb:	83 c0 0e             	add    $0xe,%eax
8010a0ee:	83 ec 04             	sub    $0x4,%esp
8010a0f1:	6a 04                	push   $0x4
8010a0f3:	68 04 05 11 80       	push   $0x80110504
8010a0f8:	50                   	push   %eax
8010a0f9:	e8 a5 b5 ff ff       	call   801056a3 <memmove>
8010a0fe:	83 c4 10             	add    $0x10,%esp
}
8010a101:	90                   	nop
8010a102:	c9                   	leave
8010a103:	c3                   	ret

8010a104 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010a104:	f3 0f 1e fb          	endbr32
8010a108:	55                   	push   %ebp
8010a109:	89 e5                	mov    %esp,%ebp
8010a10b:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010a10e:	83 ec 0c             	sub    $0xc,%esp
8010a111:	68 c2 cf 10 80       	push   $0x8010cfc2
8010a116:	e8 f1 62 ff ff       	call   8010040c <cprintf>
8010a11b:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010a11e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a121:	83 c0 0e             	add    $0xe,%eax
8010a124:	83 ec 0c             	sub    $0xc,%esp
8010a127:	50                   	push   %eax
8010a128:	e8 e8 00 00 00       	call   8010a215 <print_ipv4>
8010a12d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a130:	83 ec 0c             	sub    $0xc,%esp
8010a133:	68 c0 cf 10 80       	push   $0x8010cfc0
8010a138:	e8 cf 62 ff ff       	call   8010040c <cprintf>
8010a13d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010a140:	8b 45 08             	mov    0x8(%ebp),%eax
8010a143:	83 c0 08             	add    $0x8,%eax
8010a146:	83 ec 0c             	sub    $0xc,%esp
8010a149:	50                   	push   %eax
8010a14a:	e8 18 01 00 00       	call   8010a267 <print_mac>
8010a14f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a152:	83 ec 0c             	sub    $0xc,%esp
8010a155:	68 c0 cf 10 80       	push   $0x8010cfc0
8010a15a:	e8 ad 62 ff ff       	call   8010040c <cprintf>
8010a15f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a162:	83 ec 0c             	sub    $0xc,%esp
8010a165:	68 d9 cf 10 80       	push   $0x8010cfd9
8010a16a:	e8 9d 62 ff ff       	call   8010040c <cprintf>
8010a16f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010a172:	8b 45 08             	mov    0x8(%ebp),%eax
8010a175:	83 c0 18             	add    $0x18,%eax
8010a178:	83 ec 0c             	sub    $0xc,%esp
8010a17b:	50                   	push   %eax
8010a17c:	e8 94 00 00 00       	call   8010a215 <print_ipv4>
8010a181:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a184:	83 ec 0c             	sub    $0xc,%esp
8010a187:	68 c0 cf 10 80       	push   $0x8010cfc0
8010a18c:	e8 7b 62 ff ff       	call   8010040c <cprintf>
8010a191:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010a194:	8b 45 08             	mov    0x8(%ebp),%eax
8010a197:	83 c0 12             	add    $0x12,%eax
8010a19a:	83 ec 0c             	sub    $0xc,%esp
8010a19d:	50                   	push   %eax
8010a19e:	e8 c4 00 00 00       	call   8010a267 <print_mac>
8010a1a3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a1a6:	83 ec 0c             	sub    $0xc,%esp
8010a1a9:	68 c0 cf 10 80       	push   $0x8010cfc0
8010a1ae:	e8 59 62 ff ff       	call   8010040c <cprintf>
8010a1b3:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a1b6:	83 ec 0c             	sub    $0xc,%esp
8010a1b9:	68 f0 cf 10 80       	push   $0x8010cff0
8010a1be:	e8 49 62 ff ff       	call   8010040c <cprintf>
8010a1c3:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a1c6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1c9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1cd:	66 3d 00 01          	cmp    $0x100,%ax
8010a1d1:	75 12                	jne    8010a1e5 <print_arp_info+0xe1>
8010a1d3:	83 ec 0c             	sub    $0xc,%esp
8010a1d6:	68 fc cf 10 80       	push   $0x8010cffc
8010a1db:	e8 2c 62 ff ff       	call   8010040c <cprintf>
8010a1e0:	83 c4 10             	add    $0x10,%esp
8010a1e3:	eb 1d                	jmp    8010a202 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a1e5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1ec:	66 3d 00 02          	cmp    $0x200,%ax
8010a1f0:	75 10                	jne    8010a202 <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a1f2:	83 ec 0c             	sub    $0xc,%esp
8010a1f5:	68 05 d0 10 80       	push   $0x8010d005
8010a1fa:	e8 0d 62 ff ff       	call   8010040c <cprintf>
8010a1ff:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a202:	83 ec 0c             	sub    $0xc,%esp
8010a205:	68 c0 cf 10 80       	push   $0x8010cfc0
8010a20a:	e8 fd 61 ff ff       	call   8010040c <cprintf>
8010a20f:	83 c4 10             	add    $0x10,%esp
}
8010a212:	90                   	nop
8010a213:	c9                   	leave
8010a214:	c3                   	ret

8010a215 <print_ipv4>:

void print_ipv4(uchar *ip){
8010a215:	f3 0f 1e fb          	endbr32
8010a219:	55                   	push   %ebp
8010a21a:	89 e5                	mov    %esp,%ebp
8010a21c:	53                   	push   %ebx
8010a21d:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a220:	8b 45 08             	mov    0x8(%ebp),%eax
8010a223:	83 c0 03             	add    $0x3,%eax
8010a226:	0f b6 00             	movzbl (%eax),%eax
8010a229:	0f b6 d8             	movzbl %al,%ebx
8010a22c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22f:	83 c0 02             	add    $0x2,%eax
8010a232:	0f b6 00             	movzbl (%eax),%eax
8010a235:	0f b6 c8             	movzbl %al,%ecx
8010a238:	8b 45 08             	mov    0x8(%ebp),%eax
8010a23b:	83 c0 01             	add    $0x1,%eax
8010a23e:	0f b6 00             	movzbl (%eax),%eax
8010a241:	0f b6 d0             	movzbl %al,%edx
8010a244:	8b 45 08             	mov    0x8(%ebp),%eax
8010a247:	0f b6 00             	movzbl (%eax),%eax
8010a24a:	0f b6 c0             	movzbl %al,%eax
8010a24d:	83 ec 0c             	sub    $0xc,%esp
8010a250:	53                   	push   %ebx
8010a251:	51                   	push   %ecx
8010a252:	52                   	push   %edx
8010a253:	50                   	push   %eax
8010a254:	68 0c d0 10 80       	push   $0x8010d00c
8010a259:	e8 ae 61 ff ff       	call   8010040c <cprintf>
8010a25e:	83 c4 20             	add    $0x20,%esp
}
8010a261:	90                   	nop
8010a262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a265:	c9                   	leave
8010a266:	c3                   	ret

8010a267 <print_mac>:

void print_mac(uchar *mac){
8010a267:	f3 0f 1e fb          	endbr32
8010a26b:	55                   	push   %ebp
8010a26c:	89 e5                	mov    %esp,%ebp
8010a26e:	57                   	push   %edi
8010a26f:	56                   	push   %esi
8010a270:	53                   	push   %ebx
8010a271:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a274:	8b 45 08             	mov    0x8(%ebp),%eax
8010a277:	83 c0 05             	add    $0x5,%eax
8010a27a:	0f b6 00             	movzbl (%eax),%eax
8010a27d:	0f b6 f8             	movzbl %al,%edi
8010a280:	8b 45 08             	mov    0x8(%ebp),%eax
8010a283:	83 c0 04             	add    $0x4,%eax
8010a286:	0f b6 00             	movzbl (%eax),%eax
8010a289:	0f b6 f0             	movzbl %al,%esi
8010a28c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a28f:	83 c0 03             	add    $0x3,%eax
8010a292:	0f b6 00             	movzbl (%eax),%eax
8010a295:	0f b6 d8             	movzbl %al,%ebx
8010a298:	8b 45 08             	mov    0x8(%ebp),%eax
8010a29b:	83 c0 02             	add    $0x2,%eax
8010a29e:	0f b6 00             	movzbl (%eax),%eax
8010a2a1:	0f b6 c8             	movzbl %al,%ecx
8010a2a4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a7:	83 c0 01             	add    $0x1,%eax
8010a2aa:	0f b6 00             	movzbl (%eax),%eax
8010a2ad:	0f b6 d0             	movzbl %al,%edx
8010a2b0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2b3:	0f b6 00             	movzbl (%eax),%eax
8010a2b6:	0f b6 c0             	movzbl %al,%eax
8010a2b9:	83 ec 04             	sub    $0x4,%esp
8010a2bc:	57                   	push   %edi
8010a2bd:	56                   	push   %esi
8010a2be:	53                   	push   %ebx
8010a2bf:	51                   	push   %ecx
8010a2c0:	52                   	push   %edx
8010a2c1:	50                   	push   %eax
8010a2c2:	68 24 d0 10 80       	push   $0x8010d024
8010a2c7:	e8 40 61 ff ff       	call   8010040c <cprintf>
8010a2cc:	83 c4 20             	add    $0x20,%esp
}
8010a2cf:	90                   	nop
8010a2d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a2d3:	5b                   	pop    %ebx
8010a2d4:	5e                   	pop    %esi
8010a2d5:	5f                   	pop    %edi
8010a2d6:	5d                   	pop    %ebp
8010a2d7:	c3                   	ret

8010a2d8 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a2d8:	f3 0f 1e fb          	endbr32
8010a2dc:	55                   	push   %ebp
8010a2dd:	89 e5                	mov    %esp,%ebp
8010a2df:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a2e2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a2e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2eb:	83 c0 0e             	add    $0xe,%eax
8010a2ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a2f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2f4:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a2f8:	3c 08                	cmp    $0x8,%al
8010a2fa:	75 1b                	jne    8010a317 <eth_proc+0x3f>
8010a2fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ff:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a303:	3c 06                	cmp    $0x6,%al
8010a305:	75 10                	jne    8010a317 <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a307:	83 ec 0c             	sub    $0xc,%esp
8010a30a:	ff 75 f0             	push   -0x10(%ebp)
8010a30d:	e8 d5 f7 ff ff       	call   80109ae7 <arp_proc>
8010a312:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a315:	eb 24                	jmp    8010a33b <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a31a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a31e:	3c 08                	cmp    $0x8,%al
8010a320:	75 19                	jne    8010a33b <eth_proc+0x63>
8010a322:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a325:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a329:	84 c0                	test   %al,%al
8010a32b:	75 0e                	jne    8010a33b <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a32d:	83 ec 0c             	sub    $0xc,%esp
8010a330:	ff 75 08             	push   0x8(%ebp)
8010a333:	e8 b3 00 00 00       	call   8010a3eb <ipv4_proc>
8010a338:	83 c4 10             	add    $0x10,%esp
}
8010a33b:	90                   	nop
8010a33c:	c9                   	leave
8010a33d:	c3                   	ret

8010a33e <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a33e:	f3 0f 1e fb          	endbr32
8010a342:	55                   	push   %ebp
8010a343:	89 e5                	mov    %esp,%ebp
8010a345:	83 ec 04             	sub    $0x4,%esp
8010a348:	8b 45 08             	mov    0x8(%ebp),%eax
8010a34b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a34f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a353:	c1 e0 08             	shl    $0x8,%eax
8010a356:	89 c2                	mov    %eax,%edx
8010a358:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a35c:	66 c1 e8 08          	shr    $0x8,%ax
8010a360:	01 d0                	add    %edx,%eax
}
8010a362:	c9                   	leave
8010a363:	c3                   	ret

8010a364 <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a364:	f3 0f 1e fb          	endbr32
8010a368:	55                   	push   %ebp
8010a369:	89 e5                	mov    %esp,%ebp
8010a36b:	83 ec 04             	sub    $0x4,%esp
8010a36e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a371:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a375:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a379:	c1 e0 08             	shl    $0x8,%eax
8010a37c:	89 c2                	mov    %eax,%edx
8010a37e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a382:	66 c1 e8 08          	shr    $0x8,%ax
8010a386:	01 d0                	add    %edx,%eax
}
8010a388:	c9                   	leave
8010a389:	c3                   	ret

8010a38a <H2N_uint>:

uint H2N_uint(uint value){
8010a38a:	f3 0f 1e fb          	endbr32
8010a38e:	55                   	push   %ebp
8010a38f:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a391:	8b 45 08             	mov    0x8(%ebp),%eax
8010a394:	c1 e0 18             	shl    $0x18,%eax
8010a397:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a39c:	89 c2                	mov    %eax,%edx
8010a39e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3a1:	c1 e0 08             	shl    $0x8,%eax
8010a3a4:	25 00 f0 00 00       	and    $0xf000,%eax
8010a3a9:	09 c2                	or     %eax,%edx
8010a3ab:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ae:	c1 e8 08             	shr    $0x8,%eax
8010a3b1:	83 e0 0f             	and    $0xf,%eax
8010a3b4:	01 d0                	add    %edx,%eax
}
8010a3b6:	5d                   	pop    %ebp
8010a3b7:	c3                   	ret

8010a3b8 <N2H_uint>:

uint N2H_uint(uint value){
8010a3b8:	f3 0f 1e fb          	endbr32
8010a3bc:	55                   	push   %ebp
8010a3bd:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a3bf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c2:	c1 e0 18             	shl    $0x18,%eax
8010a3c5:	89 c2                	mov    %eax,%edx
8010a3c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ca:	c1 e0 08             	shl    $0x8,%eax
8010a3cd:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a3d2:	01 c2                	add    %eax,%edx
8010a3d4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3d7:	c1 e8 08             	shr    $0x8,%eax
8010a3da:	25 00 ff 00 00       	and    $0xff00,%eax
8010a3df:	01 c2                	add    %eax,%edx
8010a3e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3e4:	c1 e8 18             	shr    $0x18,%eax
8010a3e7:	01 d0                	add    %edx,%eax
}
8010a3e9:	5d                   	pop    %ebp
8010a3ea:	c3                   	ret

8010a3eb <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a3eb:	f3 0f 1e fb          	endbr32
8010a3ef:	55                   	push   %ebp
8010a3f0:	89 e5                	mov    %esp,%ebp
8010a3f2:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a3f5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3f8:	83 c0 0e             	add    $0xe,%eax
8010a3fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a3fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a401:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a405:	0f b7 d0             	movzwl %ax,%edx
8010a408:	a1 08 05 11 80       	mov    0x80110508,%eax
8010a40d:	39 c2                	cmp    %eax,%edx
8010a40f:	74 60                	je     8010a471 <ipv4_proc+0x86>
8010a411:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a414:	83 c0 0c             	add    $0xc,%eax
8010a417:	83 ec 04             	sub    $0x4,%esp
8010a41a:	6a 04                	push   $0x4
8010a41c:	50                   	push   %eax
8010a41d:	68 04 05 11 80       	push   $0x80110504
8010a422:	e8 20 b2 ff ff       	call   80105647 <memcmp>
8010a427:	83 c4 10             	add    $0x10,%esp
8010a42a:	85 c0                	test   %eax,%eax
8010a42c:	74 43                	je     8010a471 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a42e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a431:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a435:	0f b7 c0             	movzwl %ax,%eax
8010a438:	a3 08 05 11 80       	mov    %eax,0x80110508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a440:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a444:	3c 01                	cmp    $0x1,%al
8010a446:	75 10                	jne    8010a458 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a448:	83 ec 0c             	sub    $0xc,%esp
8010a44b:	ff 75 08             	push   0x8(%ebp)
8010a44e:	e8 a7 00 00 00       	call   8010a4fa <icmp_proc>
8010a453:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a456:	eb 19                	jmp    8010a471 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a45b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a45f:	3c 06                	cmp    $0x6,%al
8010a461:	75 0e                	jne    8010a471 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a463:	83 ec 0c             	sub    $0xc,%esp
8010a466:	ff 75 08             	push   0x8(%ebp)
8010a469:	e8 c7 03 00 00       	call   8010a835 <tcp_proc>
8010a46e:	83 c4 10             	add    $0x10,%esp
}
8010a471:	90                   	nop
8010a472:	c9                   	leave
8010a473:	c3                   	ret

8010a474 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a474:	f3 0f 1e fb          	endbr32
8010a478:	55                   	push   %ebp
8010a479:	89 e5                	mov    %esp,%ebp
8010a47b:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a47e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a481:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a484:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a487:	0f b6 00             	movzbl (%eax),%eax
8010a48a:	83 e0 0f             	and    $0xf,%eax
8010a48d:	01 c0                	add    %eax,%eax
8010a48f:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a492:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a499:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a4a0:	eb 48                	jmp    8010a4ea <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a4a5:	01 c0                	add    %eax,%eax
8010a4a7:	89 c2                	mov    %eax,%edx
8010a4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4ac:	01 d0                	add    %edx,%eax
8010a4ae:	0f b6 00             	movzbl (%eax),%eax
8010a4b1:	0f b6 c0             	movzbl %al,%eax
8010a4b4:	c1 e0 08             	shl    $0x8,%eax
8010a4b7:	89 c2                	mov    %eax,%edx
8010a4b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a4bc:	01 c0                	add    %eax,%eax
8010a4be:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4c4:	01 c8                	add    %ecx,%eax
8010a4c6:	0f b6 00             	movzbl (%eax),%eax
8010a4c9:	0f b6 c0             	movzbl %al,%eax
8010a4cc:	01 d0                	add    %edx,%eax
8010a4ce:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a4d1:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a4d8:	76 0c                	jbe    8010a4e6 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a4da:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4dd:	0f b7 c0             	movzwl %ax,%eax
8010a4e0:	83 c0 01             	add    $0x1,%eax
8010a4e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a4e6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a4ea:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a4ee:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a4f1:	7c af                	jl     8010a4a2 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a4f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4f6:	f7 d0                	not    %eax
}
8010a4f8:	c9                   	leave
8010a4f9:	c3                   	ret

8010a4fa <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a4fa:	f3 0f 1e fb          	endbr32
8010a4fe:	55                   	push   %ebp
8010a4ff:	89 e5                	mov    %esp,%ebp
8010a501:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a504:	8b 45 08             	mov    0x8(%ebp),%eax
8010a507:	83 c0 0e             	add    $0xe,%eax
8010a50a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a510:	0f b6 00             	movzbl (%eax),%eax
8010a513:	0f b6 c0             	movzbl %al,%eax
8010a516:	83 e0 0f             	and    $0xf,%eax
8010a519:	c1 e0 02             	shl    $0x2,%eax
8010a51c:	89 c2                	mov    %eax,%edx
8010a51e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a521:	01 d0                	add    %edx,%eax
8010a523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a526:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a529:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a52d:	84 c0                	test   %al,%al
8010a52f:	75 4f                	jne    8010a580 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a531:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a534:	0f b6 00             	movzbl (%eax),%eax
8010a537:	3c 08                	cmp    $0x8,%al
8010a539:	75 45                	jne    8010a580 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a53b:	e8 52 83 ff ff       	call   80102892 <kalloc>
8010a540:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a543:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a54a:	83 ec 04             	sub    $0x4,%esp
8010a54d:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a550:	50                   	push   %eax
8010a551:	ff 75 ec             	push   -0x14(%ebp)
8010a554:	ff 75 08             	push   0x8(%ebp)
8010a557:	e8 7c 00 00 00       	call   8010a5d8 <icmp_reply_pkt_create>
8010a55c:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a55f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a562:	83 ec 08             	sub    $0x8,%esp
8010a565:	50                   	push   %eax
8010a566:	ff 75 ec             	push   -0x14(%ebp)
8010a569:	e8 43 f4 ff ff       	call   801099b1 <i8254_send>
8010a56e:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a571:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a574:	83 ec 0c             	sub    $0xc,%esp
8010a577:	50                   	push   %eax
8010a578:	e8 77 82 ff ff       	call   801027f4 <kfree>
8010a57d:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a580:	90                   	nop
8010a581:	c9                   	leave
8010a582:	c3                   	ret

8010a583 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a583:	f3 0f 1e fb          	endbr32
8010a587:	55                   	push   %ebp
8010a588:	89 e5                	mov    %esp,%ebp
8010a58a:	53                   	push   %ebx
8010a58b:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a58e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a591:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a595:	0f b7 c0             	movzwl %ax,%eax
8010a598:	83 ec 0c             	sub    $0xc,%esp
8010a59b:	50                   	push   %eax
8010a59c:	e8 9d fd ff ff       	call   8010a33e <N2H_ushort>
8010a5a1:	83 c4 10             	add    $0x10,%esp
8010a5a4:	0f b7 d8             	movzwl %ax,%ebx
8010a5a7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5aa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a5ae:	0f b7 c0             	movzwl %ax,%eax
8010a5b1:	83 ec 0c             	sub    $0xc,%esp
8010a5b4:	50                   	push   %eax
8010a5b5:	e8 84 fd ff ff       	call   8010a33e <N2H_ushort>
8010a5ba:	83 c4 10             	add    $0x10,%esp
8010a5bd:	0f b7 c0             	movzwl %ax,%eax
8010a5c0:	83 ec 04             	sub    $0x4,%esp
8010a5c3:	53                   	push   %ebx
8010a5c4:	50                   	push   %eax
8010a5c5:	68 43 d0 10 80       	push   $0x8010d043
8010a5ca:	e8 3d 5e ff ff       	call   8010040c <cprintf>
8010a5cf:	83 c4 10             	add    $0x10,%esp
}
8010a5d2:	90                   	nop
8010a5d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a5d6:	c9                   	leave
8010a5d7:	c3                   	ret

8010a5d8 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a5d8:	f3 0f 1e fb          	endbr32
8010a5dc:	55                   	push   %ebp
8010a5dd:	89 e5                	mov    %esp,%ebp
8010a5df:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a5e2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a5e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5eb:	83 c0 0e             	add    $0xe,%eax
8010a5ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a5f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5f4:	0f b6 00             	movzbl (%eax),%eax
8010a5f7:	0f b6 c0             	movzbl %al,%eax
8010a5fa:	83 e0 0f             	and    $0xf,%eax
8010a5fd:	c1 e0 02             	shl    $0x2,%eax
8010a600:	89 c2                	mov    %eax,%edx
8010a602:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a605:	01 d0                	add    %edx,%eax
8010a607:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a60a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a60d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a610:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a613:	83 c0 0e             	add    $0xe,%eax
8010a616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a61c:	83 c0 14             	add    $0x14,%eax
8010a61f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a622:	8b 45 10             	mov    0x10(%ebp),%eax
8010a625:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a62b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a62e:	8d 50 06             	lea    0x6(%eax),%edx
8010a631:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a634:	83 ec 04             	sub    $0x4,%esp
8010a637:	6a 06                	push   $0x6
8010a639:	52                   	push   %edx
8010a63a:	50                   	push   %eax
8010a63b:	e8 63 b0 ff ff       	call   801056a3 <memmove>
8010a640:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a643:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a646:	83 c0 06             	add    $0x6,%eax
8010a649:	83 ec 04             	sub    $0x4,%esp
8010a64c:	6a 06                	push   $0x6
8010a64e:	68 88 e0 18 80       	push   $0x8018e088
8010a653:	50                   	push   %eax
8010a654:	e8 4a b0 ff ff       	call   801056a3 <memmove>
8010a659:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a65c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a65f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a663:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a666:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a66a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a66d:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a673:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a677:	83 ec 0c             	sub    $0xc,%esp
8010a67a:	6a 54                	push   $0x54
8010a67c:	e8 e3 fc ff ff       	call   8010a364 <H2N_ushort>
8010a681:	83 c4 10             	add    $0x10,%esp
8010a684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a687:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a68b:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010a692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a695:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a699:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010a6a0:	83 c0 01             	add    $0x1,%eax
8010a6a3:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a6a9:	83 ec 0c             	sub    $0xc,%esp
8010a6ac:	68 00 40 00 00       	push   $0x4000
8010a6b1:	e8 ae fc ff ff       	call   8010a364 <H2N_ushort>
8010a6b6:	83 c4 10             	add    $0x10,%esp
8010a6b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a6bc:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a6c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6c3:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a6c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6ca:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a6ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6d1:	83 c0 0c             	add    $0xc,%eax
8010a6d4:	83 ec 04             	sub    $0x4,%esp
8010a6d7:	6a 04                	push   $0x4
8010a6d9:	68 04 05 11 80       	push   $0x80110504
8010a6de:	50                   	push   %eax
8010a6df:	e8 bf af ff ff       	call   801056a3 <memmove>
8010a6e4:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a6e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6ea:	8d 50 0c             	lea    0xc(%eax),%edx
8010a6ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6f0:	83 c0 10             	add    $0x10,%eax
8010a6f3:	83 ec 04             	sub    $0x4,%esp
8010a6f6:	6a 04                	push   $0x4
8010a6f8:	52                   	push   %edx
8010a6f9:	50                   	push   %eax
8010a6fa:	e8 a4 af ff ff       	call   801056a3 <memmove>
8010a6ff:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a702:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a705:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a70b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a70e:	83 ec 0c             	sub    $0xc,%esp
8010a711:	50                   	push   %eax
8010a712:	e8 5d fd ff ff       	call   8010a474 <ipv4_chksum>
8010a717:	83 c4 10             	add    $0x10,%esp
8010a71a:	0f b7 c0             	movzwl %ax,%eax
8010a71d:	83 ec 0c             	sub    $0xc,%esp
8010a720:	50                   	push   %eax
8010a721:	e8 3e fc ff ff       	call   8010a364 <H2N_ushort>
8010a726:	83 c4 10             	add    $0x10,%esp
8010a729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a72c:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a730:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a733:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a736:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a739:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a73d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a740:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a744:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a747:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a74b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a74e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a752:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a755:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a75c:	8d 50 08             	lea    0x8(%eax),%edx
8010a75f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a762:	83 c0 08             	add    $0x8,%eax
8010a765:	83 ec 04             	sub    $0x4,%esp
8010a768:	6a 08                	push   $0x8
8010a76a:	52                   	push   %edx
8010a76b:	50                   	push   %eax
8010a76c:	e8 32 af ff ff       	call   801056a3 <memmove>
8010a771:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a774:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a777:	8d 50 10             	lea    0x10(%eax),%edx
8010a77a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a77d:	83 c0 10             	add    $0x10,%eax
8010a780:	83 ec 04             	sub    $0x4,%esp
8010a783:	6a 30                	push   $0x30
8010a785:	52                   	push   %edx
8010a786:	50                   	push   %eax
8010a787:	e8 17 af ff ff       	call   801056a3 <memmove>
8010a78c:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a78f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a792:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a798:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a79b:	83 ec 0c             	sub    $0xc,%esp
8010a79e:	50                   	push   %eax
8010a79f:	e8 1c 00 00 00       	call   8010a7c0 <icmp_chksum>
8010a7a4:	83 c4 10             	add    $0x10,%esp
8010a7a7:	0f b7 c0             	movzwl %ax,%eax
8010a7aa:	83 ec 0c             	sub    $0xc,%esp
8010a7ad:	50                   	push   %eax
8010a7ae:	e8 b1 fb ff ff       	call   8010a364 <H2N_ushort>
8010a7b3:	83 c4 10             	add    $0x10,%esp
8010a7b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a7b9:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a7bd:	90                   	nop
8010a7be:	c9                   	leave
8010a7bf:	c3                   	ret

8010a7c0 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a7c0:	f3 0f 1e fb          	endbr32
8010a7c4:	55                   	push   %ebp
8010a7c5:	89 e5                	mov    %esp,%ebp
8010a7c7:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a7ca:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a7d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a7d7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a7de:	eb 48                	jmp    8010a828 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a7e3:	01 c0                	add    %eax,%eax
8010a7e5:	89 c2                	mov    %eax,%edx
8010a7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7ea:	01 d0                	add    %edx,%eax
8010a7ec:	0f b6 00             	movzbl (%eax),%eax
8010a7ef:	0f b6 c0             	movzbl %al,%eax
8010a7f2:	c1 e0 08             	shl    $0x8,%eax
8010a7f5:	89 c2                	mov    %eax,%edx
8010a7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a7fa:	01 c0                	add    %eax,%eax
8010a7fc:	8d 48 01             	lea    0x1(%eax),%ecx
8010a7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a802:	01 c8                	add    %ecx,%eax
8010a804:	0f b6 00             	movzbl (%eax),%eax
8010a807:	0f b6 c0             	movzbl %al,%eax
8010a80a:	01 d0                	add    %edx,%eax
8010a80c:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a80f:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a816:	76 0c                	jbe    8010a824 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a818:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a81b:	0f b7 c0             	movzwl %ax,%eax
8010a81e:	83 c0 01             	add    $0x1,%eax
8010a821:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a824:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a828:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a82c:	7e b2                	jle    8010a7e0 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a82e:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a831:	f7 d0                	not    %eax
}
8010a833:	c9                   	leave
8010a834:	c3                   	ret

8010a835 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a835:	f3 0f 1e fb          	endbr32
8010a839:	55                   	push   %ebp
8010a83a:	89 e5                	mov    %esp,%ebp
8010a83c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a83f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a842:	83 c0 0e             	add    $0xe,%eax
8010a845:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a84b:	0f b6 00             	movzbl (%eax),%eax
8010a84e:	0f b6 c0             	movzbl %al,%eax
8010a851:	83 e0 0f             	and    $0xf,%eax
8010a854:	c1 e0 02             	shl    $0x2,%eax
8010a857:	89 c2                	mov    %eax,%edx
8010a859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a85c:	01 d0                	add    %edx,%eax
8010a85e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a861:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a864:	83 c0 14             	add    $0x14,%eax
8010a867:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a86a:	e8 23 80 ff ff       	call   80102892 <kalloc>
8010a86f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a872:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a87c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a880:	0f b6 c0             	movzbl %al,%eax
8010a883:	83 e0 02             	and    $0x2,%eax
8010a886:	85 c0                	test   %eax,%eax
8010a888:	74 3d                	je     8010a8c7 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a88a:	83 ec 0c             	sub    $0xc,%esp
8010a88d:	6a 00                	push   $0x0
8010a88f:	6a 12                	push   $0x12
8010a891:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a894:	50                   	push   %eax
8010a895:	ff 75 e8             	push   -0x18(%ebp)
8010a898:	ff 75 08             	push   0x8(%ebp)
8010a89b:	e8 a2 01 00 00       	call   8010aa42 <tcp_pkt_create>
8010a8a0:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a8a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8a6:	83 ec 08             	sub    $0x8,%esp
8010a8a9:	50                   	push   %eax
8010a8aa:	ff 75 e8             	push   -0x18(%ebp)
8010a8ad:	e8 ff f0 ff ff       	call   801099b1 <i8254_send>
8010a8b2:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a8b5:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010a8ba:	83 c0 01             	add    $0x1,%eax
8010a8bd:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010a8c2:	e9 69 01 00 00       	jmp    8010aa30 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a8c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8ca:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a8ce:	3c 18                	cmp    $0x18,%al
8010a8d0:	0f 85 10 01 00 00    	jne    8010a9e6 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a8d6:	83 ec 04             	sub    $0x4,%esp
8010a8d9:	6a 03                	push   $0x3
8010a8db:	68 5e d0 10 80       	push   $0x8010d05e
8010a8e0:	ff 75 ec             	push   -0x14(%ebp)
8010a8e3:	e8 5f ad ff ff       	call   80105647 <memcmp>
8010a8e8:	83 c4 10             	add    $0x10,%esp
8010a8eb:	85 c0                	test   %eax,%eax
8010a8ed:	74 74                	je     8010a963 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a8ef:	83 ec 0c             	sub    $0xc,%esp
8010a8f2:	68 62 d0 10 80       	push   $0x8010d062
8010a8f7:	e8 10 5b ff ff       	call   8010040c <cprintf>
8010a8fc:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a8ff:	83 ec 0c             	sub    $0xc,%esp
8010a902:	6a 00                	push   $0x0
8010a904:	6a 10                	push   $0x10
8010a906:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a909:	50                   	push   %eax
8010a90a:	ff 75 e8             	push   -0x18(%ebp)
8010a90d:	ff 75 08             	push   0x8(%ebp)
8010a910:	e8 2d 01 00 00       	call   8010aa42 <tcp_pkt_create>
8010a915:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a918:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a91b:	83 ec 08             	sub    $0x8,%esp
8010a91e:	50                   	push   %eax
8010a91f:	ff 75 e8             	push   -0x18(%ebp)
8010a922:	e8 8a f0 ff ff       	call   801099b1 <i8254_send>
8010a927:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a92a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a92d:	83 c0 36             	add    $0x36,%eax
8010a930:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a933:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a936:	50                   	push   %eax
8010a937:	ff 75 e0             	push   -0x20(%ebp)
8010a93a:	6a 00                	push   $0x0
8010a93c:	6a 00                	push   $0x0
8010a93e:	e8 66 04 00 00       	call   8010ada9 <http_proc>
8010a943:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a946:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a949:	83 ec 0c             	sub    $0xc,%esp
8010a94c:	50                   	push   %eax
8010a94d:	6a 18                	push   $0x18
8010a94f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a952:	50                   	push   %eax
8010a953:	ff 75 e8             	push   -0x18(%ebp)
8010a956:	ff 75 08             	push   0x8(%ebp)
8010a959:	e8 e4 00 00 00       	call   8010aa42 <tcp_pkt_create>
8010a95e:	83 c4 20             	add    $0x20,%esp
8010a961:	eb 62                	jmp    8010a9c5 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a963:	83 ec 0c             	sub    $0xc,%esp
8010a966:	6a 00                	push   $0x0
8010a968:	6a 10                	push   $0x10
8010a96a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a96d:	50                   	push   %eax
8010a96e:	ff 75 e8             	push   -0x18(%ebp)
8010a971:	ff 75 08             	push   0x8(%ebp)
8010a974:	e8 c9 00 00 00       	call   8010aa42 <tcp_pkt_create>
8010a979:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a97c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a97f:	83 ec 08             	sub    $0x8,%esp
8010a982:	50                   	push   %eax
8010a983:	ff 75 e8             	push   -0x18(%ebp)
8010a986:	e8 26 f0 ff ff       	call   801099b1 <i8254_send>
8010a98b:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a98e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a991:	83 c0 36             	add    $0x36,%eax
8010a994:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a997:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a99a:	50                   	push   %eax
8010a99b:	ff 75 e4             	push   -0x1c(%ebp)
8010a99e:	6a 00                	push   $0x0
8010a9a0:	6a 00                	push   $0x0
8010a9a2:	e8 02 04 00 00       	call   8010ada9 <http_proc>
8010a9a7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a9aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a9ad:	83 ec 0c             	sub    $0xc,%esp
8010a9b0:	50                   	push   %eax
8010a9b1:	6a 18                	push   $0x18
8010a9b3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a9b6:	50                   	push   %eax
8010a9b7:	ff 75 e8             	push   -0x18(%ebp)
8010a9ba:	ff 75 08             	push   0x8(%ebp)
8010a9bd:	e8 80 00 00 00       	call   8010aa42 <tcp_pkt_create>
8010a9c2:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a9c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a9c8:	83 ec 08             	sub    $0x8,%esp
8010a9cb:	50                   	push   %eax
8010a9cc:	ff 75 e8             	push   -0x18(%ebp)
8010a9cf:	e8 dd ef ff ff       	call   801099b1 <i8254_send>
8010a9d4:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a9d7:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010a9dc:	83 c0 01             	add    $0x1,%eax
8010a9df:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010a9e4:	eb 4a                	jmp    8010aa30 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a9e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a9e9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a9ed:	3c 10                	cmp    $0x10,%al
8010a9ef:	75 3f                	jne    8010aa30 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a9f1:	a1 68 e3 18 80       	mov    0x8018e368,%eax
8010a9f6:	83 f8 01             	cmp    $0x1,%eax
8010a9f9:	75 35                	jne    8010aa30 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a9fb:	83 ec 0c             	sub    $0xc,%esp
8010a9fe:	6a 00                	push   $0x0
8010aa00:	6a 01                	push   $0x1
8010aa02:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010aa05:	50                   	push   %eax
8010aa06:	ff 75 e8             	push   -0x18(%ebp)
8010aa09:	ff 75 08             	push   0x8(%ebp)
8010aa0c:	e8 31 00 00 00       	call   8010aa42 <tcp_pkt_create>
8010aa11:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010aa14:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010aa17:	83 ec 08             	sub    $0x8,%esp
8010aa1a:	50                   	push   %eax
8010aa1b:	ff 75 e8             	push   -0x18(%ebp)
8010aa1e:	e8 8e ef ff ff       	call   801099b1 <i8254_send>
8010aa23:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010aa26:	c7 05 68 e3 18 80 00 	movl   $0x0,0x8018e368
8010aa2d:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010aa30:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa33:	83 ec 0c             	sub    $0xc,%esp
8010aa36:	50                   	push   %eax
8010aa37:	e8 b8 7d ff ff       	call   801027f4 <kfree>
8010aa3c:	83 c4 10             	add    $0x10,%esp
}
8010aa3f:	90                   	nop
8010aa40:	c9                   	leave
8010aa41:	c3                   	ret

8010aa42 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010aa42:	f3 0f 1e fb          	endbr32
8010aa46:	55                   	push   %ebp
8010aa47:	89 e5                	mov    %esp,%ebp
8010aa49:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010aa4c:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010aa52:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa55:	83 c0 0e             	add    $0xe,%eax
8010aa58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010aa5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa5e:	0f b6 00             	movzbl (%eax),%eax
8010aa61:	0f b6 c0             	movzbl %al,%eax
8010aa64:	83 e0 0f             	and    $0xf,%eax
8010aa67:	c1 e0 02             	shl    $0x2,%eax
8010aa6a:	89 c2                	mov    %eax,%edx
8010aa6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa6f:	01 d0                	add    %edx,%eax
8010aa71:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010aa74:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa77:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010aa7a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa7d:	83 c0 0e             	add    $0xe,%eax
8010aa80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010aa83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa86:	83 c0 14             	add    $0x14,%eax
8010aa89:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010aa8c:	8b 45 18             	mov    0x18(%ebp),%eax
8010aa8f:	8d 50 36             	lea    0x36(%eax),%edx
8010aa92:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa95:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010aa97:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa9a:	8d 50 06             	lea    0x6(%eax),%edx
8010aa9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aaa0:	83 ec 04             	sub    $0x4,%esp
8010aaa3:	6a 06                	push   $0x6
8010aaa5:	52                   	push   %edx
8010aaa6:	50                   	push   %eax
8010aaa7:	e8 f7 ab ff ff       	call   801056a3 <memmove>
8010aaac:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010aaaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aab2:	83 c0 06             	add    $0x6,%eax
8010aab5:	83 ec 04             	sub    $0x4,%esp
8010aab8:	6a 06                	push   $0x6
8010aaba:	68 88 e0 18 80       	push   $0x8018e088
8010aabf:	50                   	push   %eax
8010aac0:	e8 de ab ff ff       	call   801056a3 <memmove>
8010aac5:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010aac8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aacb:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010aacf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aad2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010aad6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aad9:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010aadc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aadf:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010aae3:	8b 45 18             	mov    0x18(%ebp),%eax
8010aae6:	83 c0 28             	add    $0x28,%eax
8010aae9:	0f b7 c0             	movzwl %ax,%eax
8010aaec:	83 ec 0c             	sub    $0xc,%esp
8010aaef:	50                   	push   %eax
8010aaf0:	e8 6f f8 ff ff       	call   8010a364 <H2N_ushort>
8010aaf5:	83 c4 10             	add    $0x10,%esp
8010aaf8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aafb:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010aaff:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010ab06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab09:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010ab0d:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010ab14:	83 c0 01             	add    $0x1,%eax
8010ab17:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x0000);
8010ab1d:	83 ec 0c             	sub    $0xc,%esp
8010ab20:	6a 00                	push   $0x0
8010ab22:	e8 3d f8 ff ff       	call   8010a364 <H2N_ushort>
8010ab27:	83 c4 10             	add    $0x10,%esp
8010ab2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab2d:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010ab31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab34:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010ab38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab3b:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010ab3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab42:	83 c0 0c             	add    $0xc,%eax
8010ab45:	83 ec 04             	sub    $0x4,%esp
8010ab48:	6a 04                	push   $0x4
8010ab4a:	68 04 05 11 80       	push   $0x80110504
8010ab4f:	50                   	push   %eax
8010ab50:	e8 4e ab ff ff       	call   801056a3 <memmove>
8010ab55:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010ab58:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ab5b:	8d 50 0c             	lea    0xc(%eax),%edx
8010ab5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab61:	83 c0 10             	add    $0x10,%eax
8010ab64:	83 ec 04             	sub    $0x4,%esp
8010ab67:	6a 04                	push   $0x4
8010ab69:	52                   	push   %edx
8010ab6a:	50                   	push   %eax
8010ab6b:	e8 33 ab ff ff       	call   801056a3 <memmove>
8010ab70:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010ab73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab76:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010ab7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab7f:	83 ec 0c             	sub    $0xc,%esp
8010ab82:	50                   	push   %eax
8010ab83:	e8 ec f8 ff ff       	call   8010a474 <ipv4_chksum>
8010ab88:	83 c4 10             	add    $0x10,%esp
8010ab8b:	0f b7 c0             	movzwl %ax,%eax
8010ab8e:	83 ec 0c             	sub    $0xc,%esp
8010ab91:	50                   	push   %eax
8010ab92:	e8 cd f7 ff ff       	call   8010a364 <H2N_ushort>
8010ab97:	83 c4 10             	add    $0x10,%esp
8010ab9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab9d:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010aba1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aba4:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010aba8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abab:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010abae:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abb1:	0f b7 10             	movzwl (%eax),%edx
8010abb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abb7:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010abbb:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010abc0:	83 ec 0c             	sub    $0xc,%esp
8010abc3:	50                   	push   %eax
8010abc4:	e8 c1 f7 ff ff       	call   8010a38a <H2N_uint>
8010abc9:	83 c4 10             	add    $0x10,%esp
8010abcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010abcf:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010abd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abd5:	8b 40 04             	mov    0x4(%eax),%eax
8010abd8:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010abde:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abe1:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010abe4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abe7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010abeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abee:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010abf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abf5:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010abf9:	8b 45 14             	mov    0x14(%ebp),%eax
8010abfc:	89 c2                	mov    %eax,%edx
8010abfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac01:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010ac04:	83 ec 0c             	sub    $0xc,%esp
8010ac07:	68 90 38 00 00       	push   $0x3890
8010ac0c:	e8 53 f7 ff ff       	call   8010a364 <H2N_ushort>
8010ac11:	83 c4 10             	add    $0x10,%esp
8010ac14:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ac17:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010ac1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac1e:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010ac24:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac27:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010ac2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ac30:	83 ec 0c             	sub    $0xc,%esp
8010ac33:	50                   	push   %eax
8010ac34:	e8 1f 00 00 00       	call   8010ac58 <tcp_chksum>
8010ac39:	83 c4 10             	add    $0x10,%esp
8010ac3c:	83 c0 08             	add    $0x8,%eax
8010ac3f:	0f b7 c0             	movzwl %ax,%eax
8010ac42:	83 ec 0c             	sub    $0xc,%esp
8010ac45:	50                   	push   %eax
8010ac46:	e8 19 f7 ff ff       	call   8010a364 <H2N_ushort>
8010ac4b:	83 c4 10             	add    $0x10,%esp
8010ac4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ac51:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010ac55:	90                   	nop
8010ac56:	c9                   	leave
8010ac57:	c3                   	ret

8010ac58 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010ac58:	f3 0f 1e fb          	endbr32
8010ac5c:	55                   	push   %ebp
8010ac5d:	89 e5                	mov    %esp,%ebp
8010ac5f:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010ac62:	8b 45 08             	mov    0x8(%ebp),%eax
8010ac65:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010ac68:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac6b:	83 c0 14             	add    $0x14,%eax
8010ac6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010ac71:	83 ec 04             	sub    $0x4,%esp
8010ac74:	6a 04                	push   $0x4
8010ac76:	68 04 05 11 80       	push   $0x80110504
8010ac7b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ac7e:	50                   	push   %eax
8010ac7f:	e8 1f aa ff ff       	call   801056a3 <memmove>
8010ac84:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010ac87:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac8a:	83 c0 0c             	add    $0xc,%eax
8010ac8d:	83 ec 04             	sub    $0x4,%esp
8010ac90:	6a 04                	push   $0x4
8010ac92:	50                   	push   %eax
8010ac93:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ac96:	83 c0 04             	add    $0x4,%eax
8010ac99:	50                   	push   %eax
8010ac9a:	e8 04 aa ff ff       	call   801056a3 <memmove>
8010ac9f:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010aca2:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010aca6:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010acaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010acad:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010acb1:	0f b7 c0             	movzwl %ax,%eax
8010acb4:	83 ec 0c             	sub    $0xc,%esp
8010acb7:	50                   	push   %eax
8010acb8:	e8 81 f6 ff ff       	call   8010a33e <N2H_ushort>
8010acbd:	83 c4 10             	add    $0x10,%esp
8010acc0:	83 e8 14             	sub    $0x14,%eax
8010acc3:	0f b7 c0             	movzwl %ax,%eax
8010acc6:	83 ec 0c             	sub    $0xc,%esp
8010acc9:	50                   	push   %eax
8010acca:	e8 95 f6 ff ff       	call   8010a364 <H2N_ushort>
8010accf:	83 c4 10             	add    $0x10,%esp
8010acd2:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010acd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010acdd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ace0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010ace3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010acea:	eb 33                	jmp    8010ad1f <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010acec:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010acef:	01 c0                	add    %eax,%eax
8010acf1:	89 c2                	mov    %eax,%edx
8010acf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010acf6:	01 d0                	add    %edx,%eax
8010acf8:	0f b6 00             	movzbl (%eax),%eax
8010acfb:	0f b6 c0             	movzbl %al,%eax
8010acfe:	c1 e0 08             	shl    $0x8,%eax
8010ad01:	89 c2                	mov    %eax,%edx
8010ad03:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ad06:	01 c0                	add    %eax,%eax
8010ad08:	8d 48 01             	lea    0x1(%eax),%ecx
8010ad0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad0e:	01 c8                	add    %ecx,%eax
8010ad10:	0f b6 00             	movzbl (%eax),%eax
8010ad13:	0f b6 c0             	movzbl %al,%eax
8010ad16:	01 d0                	add    %edx,%eax
8010ad18:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010ad1b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ad1f:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ad23:	7e c7                	jle    8010acec <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ad25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ad28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ad32:	eb 33                	jmp    8010ad67 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ad34:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad37:	01 c0                	add    %eax,%eax
8010ad39:	89 c2                	mov    %eax,%edx
8010ad3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad3e:	01 d0                	add    %edx,%eax
8010ad40:	0f b6 00             	movzbl (%eax),%eax
8010ad43:	0f b6 c0             	movzbl %al,%eax
8010ad46:	c1 e0 08             	shl    $0x8,%eax
8010ad49:	89 c2                	mov    %eax,%edx
8010ad4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad4e:	01 c0                	add    %eax,%eax
8010ad50:	8d 48 01             	lea    0x1(%eax),%ecx
8010ad53:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad56:	01 c8                	add    %ecx,%eax
8010ad58:	0f b6 00             	movzbl (%eax),%eax
8010ad5b:	0f b6 c0             	movzbl %al,%eax
8010ad5e:	01 d0                	add    %edx,%eax
8010ad60:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad63:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010ad67:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010ad6b:	0f b7 c0             	movzwl %ax,%eax
8010ad6e:	83 ec 0c             	sub    $0xc,%esp
8010ad71:	50                   	push   %eax
8010ad72:	e8 c7 f5 ff ff       	call   8010a33e <N2H_ushort>
8010ad77:	83 c4 10             	add    $0x10,%esp
8010ad7a:	66 d1 e8             	shr    $1,%ax
8010ad7d:	0f b7 c0             	movzwl %ax,%eax
8010ad80:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010ad83:	7c af                	jl     8010ad34 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010ad85:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ad88:	c1 e8 10             	shr    $0x10,%eax
8010ad8b:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010ad8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ad91:	f7 d0                	not    %eax
}
8010ad93:	c9                   	leave
8010ad94:	c3                   	ret

8010ad95 <tcp_fin>:

void tcp_fin(){
8010ad95:	f3 0f 1e fb          	endbr32
8010ad99:	55                   	push   %ebp
8010ad9a:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010ad9c:	c7 05 68 e3 18 80 01 	movl   $0x1,0x8018e368
8010ada3:	00 00 00 
}
8010ada6:	90                   	nop
8010ada7:	5d                   	pop    %ebp
8010ada8:	c3                   	ret

8010ada9 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010ada9:	f3 0f 1e fb          	endbr32
8010adad:	55                   	push   %ebp
8010adae:	89 e5                	mov    %esp,%ebp
8010adb0:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010adb3:	8b 45 10             	mov    0x10(%ebp),%eax
8010adb6:	83 ec 04             	sub    $0x4,%esp
8010adb9:	6a 00                	push   $0x0
8010adbb:	68 6b d0 10 80       	push   $0x8010d06b
8010adc0:	50                   	push   %eax
8010adc1:	e8 65 00 00 00       	call   8010ae2b <http_strcpy>
8010adc6:	83 c4 10             	add    $0x10,%esp
8010adc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010adcc:	8b 45 10             	mov    0x10(%ebp),%eax
8010adcf:	83 ec 04             	sub    $0x4,%esp
8010add2:	ff 75 f4             	push   -0xc(%ebp)
8010add5:	68 7e d0 10 80       	push   $0x8010d07e
8010adda:	50                   	push   %eax
8010addb:	e8 4b 00 00 00       	call   8010ae2b <http_strcpy>
8010ade0:	83 c4 10             	add    $0x10,%esp
8010ade3:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010ade6:	8b 45 10             	mov    0x10(%ebp),%eax
8010ade9:	83 ec 04             	sub    $0x4,%esp
8010adec:	ff 75 f4             	push   -0xc(%ebp)
8010adef:	68 99 d0 10 80       	push   $0x8010d099
8010adf4:	50                   	push   %eax
8010adf5:	e8 31 00 00 00       	call   8010ae2b <http_strcpy>
8010adfa:	83 c4 10             	add    $0x10,%esp
8010adfd:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ae00:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ae03:	83 e0 01             	and    $0x1,%eax
8010ae06:	85 c0                	test   %eax,%eax
8010ae08:	74 11                	je     8010ae1b <http_proc+0x72>
    char *payload = (char *)send;
8010ae0a:	8b 45 10             	mov    0x10(%ebp),%eax
8010ae0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010ae10:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ae13:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ae16:	01 d0                	add    %edx,%eax
8010ae18:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010ae1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ae1e:	8b 45 14             	mov    0x14(%ebp),%eax
8010ae21:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ae23:	e8 6d ff ff ff       	call   8010ad95 <tcp_fin>
}
8010ae28:	90                   	nop
8010ae29:	c9                   	leave
8010ae2a:	c3                   	ret

8010ae2b <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ae2b:	f3 0f 1e fb          	endbr32
8010ae2f:	55                   	push   %ebp
8010ae30:	89 e5                	mov    %esp,%ebp
8010ae32:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ae35:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ae3c:	eb 20                	jmp    8010ae5e <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ae3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae41:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae44:	01 d0                	add    %edx,%eax
8010ae46:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ae49:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae4c:	01 ca                	add    %ecx,%edx
8010ae4e:	89 d1                	mov    %edx,%ecx
8010ae50:	8b 55 08             	mov    0x8(%ebp),%edx
8010ae53:	01 ca                	add    %ecx,%edx
8010ae55:	0f b6 00             	movzbl (%eax),%eax
8010ae58:	88 02                	mov    %al,(%edx)
    i++;
8010ae5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010ae5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae61:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae64:	01 d0                	add    %edx,%eax
8010ae66:	0f b6 00             	movzbl (%eax),%eax
8010ae69:	84 c0                	test   %al,%al
8010ae6b:	75 d1                	jne    8010ae3e <http_strcpy+0x13>
  }
  return i;
8010ae6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010ae70:	c9                   	leave
8010ae71:	c3                   	ret

8010ae72 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010ae72:	f3 0f 1e fb          	endbr32
8010ae76:	55                   	push   %ebp
8010ae77:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010ae79:	c7 05 70 e3 18 80 c2 	movl   $0x801105c2,0x8018e370
8010ae80:	05 11 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010ae83:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010ae88:	c1 e8 09             	shr    $0x9,%eax
8010ae8b:	a3 6c e3 18 80       	mov    %eax,0x8018e36c
}
8010ae90:	90                   	nop
8010ae91:	5d                   	pop    %ebp
8010ae92:	c3                   	ret

8010ae93 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010ae93:	f3 0f 1e fb          	endbr32
8010ae97:	55                   	push   %ebp
8010ae98:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010ae9a:	90                   	nop
8010ae9b:	5d                   	pop    %ebp
8010ae9c:	c3                   	ret

8010ae9d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010ae9d:	f3 0f 1e fb          	endbr32
8010aea1:	55                   	push   %ebp
8010aea2:	89 e5                	mov    %esp,%ebp
8010aea4:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010aea7:	8b 45 08             	mov    0x8(%ebp),%eax
8010aeaa:	83 c0 0c             	add    $0xc,%eax
8010aead:	83 ec 0c             	sub    $0xc,%esp
8010aeb0:	50                   	push   %eax
8010aeb1:	e8 fe a3 ff ff       	call   801052b4 <holdingsleep>
8010aeb6:	83 c4 10             	add    $0x10,%esp
8010aeb9:	85 c0                	test   %eax,%eax
8010aebb:	75 0d                	jne    8010aeca <iderw+0x2d>
    panic("iderw: buf not locked");
8010aebd:	83 ec 0c             	sub    $0xc,%esp
8010aec0:	68 aa d0 10 80       	push   $0x8010d0aa
8010aec5:	e8 fb 56 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010aeca:	8b 45 08             	mov    0x8(%ebp),%eax
8010aecd:	8b 00                	mov    (%eax),%eax
8010aecf:	83 e0 06             	and    $0x6,%eax
8010aed2:	83 f8 02             	cmp    $0x2,%eax
8010aed5:	75 0d                	jne    8010aee4 <iderw+0x47>
    panic("iderw: nothing to do");
8010aed7:	83 ec 0c             	sub    $0xc,%esp
8010aeda:	68 c0 d0 10 80       	push   $0x8010d0c0
8010aedf:	e8 e1 56 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010aee4:	8b 45 08             	mov    0x8(%ebp),%eax
8010aee7:	8b 40 04             	mov    0x4(%eax),%eax
8010aeea:	83 f8 01             	cmp    $0x1,%eax
8010aeed:	74 0d                	je     8010aefc <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010aeef:	83 ec 0c             	sub    $0xc,%esp
8010aef2:	68 d5 d0 10 80       	push   $0x8010d0d5
8010aef7:	e8 c9 56 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010aefc:	8b 45 08             	mov    0x8(%ebp),%eax
8010aeff:	8b 40 08             	mov    0x8(%eax),%eax
8010af02:	8b 15 6c e3 18 80    	mov    0x8018e36c,%edx
8010af08:	39 d0                	cmp    %edx,%eax
8010af0a:	72 0d                	jb     8010af19 <iderw+0x7c>
    panic("iderw: block out of range");
8010af0c:	83 ec 0c             	sub    $0xc,%esp
8010af0f:	68 f3 d0 10 80       	push   $0x8010d0f3
8010af14:	e8 ac 56 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010af19:	8b 15 70 e3 18 80    	mov    0x8018e370,%edx
8010af1f:	8b 45 08             	mov    0x8(%ebp),%eax
8010af22:	8b 40 08             	mov    0x8(%eax),%eax
8010af25:	c1 e0 09             	shl    $0x9,%eax
8010af28:	01 d0                	add    %edx,%eax
8010af2a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010af2d:	8b 45 08             	mov    0x8(%ebp),%eax
8010af30:	8b 00                	mov    (%eax),%eax
8010af32:	83 e0 04             	and    $0x4,%eax
8010af35:	85 c0                	test   %eax,%eax
8010af37:	74 2b                	je     8010af64 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010af39:	8b 45 08             	mov    0x8(%ebp),%eax
8010af3c:	8b 00                	mov    (%eax),%eax
8010af3e:	83 e0 fb             	and    $0xfffffffb,%eax
8010af41:	89 c2                	mov    %eax,%edx
8010af43:	8b 45 08             	mov    0x8(%ebp),%eax
8010af46:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010af48:	8b 45 08             	mov    0x8(%ebp),%eax
8010af4b:	83 c0 5c             	add    $0x5c,%eax
8010af4e:	83 ec 04             	sub    $0x4,%esp
8010af51:	68 00 02 00 00       	push   $0x200
8010af56:	50                   	push   %eax
8010af57:	ff 75 f4             	push   -0xc(%ebp)
8010af5a:	e8 44 a7 ff ff       	call   801056a3 <memmove>
8010af5f:	83 c4 10             	add    $0x10,%esp
8010af62:	eb 1a                	jmp    8010af7e <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010af64:	8b 45 08             	mov    0x8(%ebp),%eax
8010af67:	83 c0 5c             	add    $0x5c,%eax
8010af6a:	83 ec 04             	sub    $0x4,%esp
8010af6d:	68 00 02 00 00       	push   $0x200
8010af72:	ff 75 f4             	push   -0xc(%ebp)
8010af75:	50                   	push   %eax
8010af76:	e8 28 a7 ff ff       	call   801056a3 <memmove>
8010af7b:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010af7e:	8b 45 08             	mov    0x8(%ebp),%eax
8010af81:	8b 00                	mov    (%eax),%eax
8010af83:	83 c8 02             	or     $0x2,%eax
8010af86:	89 c2                	mov    %eax,%edx
8010af88:	8b 45 08             	mov    0x8(%ebp),%eax
8010af8b:	89 10                	mov    %edx,(%eax)
}
8010af8d:	90                   	nop
8010af8e:	c9                   	leave
8010af8f:	c3                   	ret
