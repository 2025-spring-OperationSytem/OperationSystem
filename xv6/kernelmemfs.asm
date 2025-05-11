
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
80100073:	68 c0 af 10 80       	push   $0x8010afc0
80100078:	68 80 f3 18 80       	push   $0x8018f380
8010007d:	e8 cf 52 00 00       	call   80105351 <initlock>
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
801000c1:	68 c7 af 10 80       	push   $0x8010afc7
801000c6:	50                   	push   %eax
801000c7:	e8 18 51 00 00       	call   801051e4 <initsleeplock>
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
80100109:	e8 69 52 00 00       	call   80105377 <acquire>
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
80100148:	e8 9c 52 00 00       	call   801053e9 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 c5 50 00 00       	call   80105224 <acquiresleep>
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
801001c9:	e8 1b 52 00 00       	call   801053e9 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 44 50 00 00       	call   80105224 <acquiresleep>
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
801001fd:	68 ce af 10 80       	push   $0x8010afce
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
80100239:	e8 89 ac 00 00       	call   8010aec7 <iderw>
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
8010025a:	e8 7f 50 00 00       	call   801052de <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 df af 10 80       	push   $0x8010afdf
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
80100288:	e8 3a ac 00 00       	call   8010aec7 <iderw>
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
801002a7:	e8 32 50 00 00       	call   801052de <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 e6 af 10 80       	push   $0x8010afe6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 bd 4f 00 00       	call   8010528c <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 80 f3 18 80       	push   $0x8018f380
801002da:	e8 98 50 00 00       	call   80105377 <acquire>
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
8010034a:	e8 9a 50 00 00       	call   801053e9 <release>
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
8010042c:	e8 46 4f 00 00       	call   80105377 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ed af 10 80       	push   $0x8010afed
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
8010052c:	c7 45 ec f6 af 10 80 	movl   $0x8010aff6,-0x14(%ebp)
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
801005ba:	e8 2a 4e 00 00       	call   801053e9 <release>
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
801005e7:	68 fd af 10 80       	push   $0x8010affd
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
80100606:	68 11 b0 10 80       	push   $0x8010b011
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 1c 4e 00 00       	call   8010543f <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 13 b0 10 80       	push   $0x8010b013
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
801006c4:	e8 92 86 00 00       	call   80108d5b <graphic_scroll_up>
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
80100717:	e8 3f 86 00 00       	call   80108d5b <graphic_scroll_up>
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
8010077d:	e8 4d 86 00 00       	call   80108dcf <font_render>
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
801007bd:	e8 ae 69 00 00       	call   80107170 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 a1 69 00 00       	call   80107170 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 94 69 00 00       	call   80107170 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 84 69 00 00       	call   80107170 <uartputc>
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
80100819:	e8 59 4b 00 00       	call   80105377 <acquire>
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
8010096f:	e8 25 3e 00 00       	call   80104799 <wakeup>
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
80100992:	e8 52 4a 00 00       	call   801053e9 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 b7 3e 00 00       	call   8010485c <procdump>
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
801009ce:	e8 a4 49 00 00       	call   80105377 <acquire>
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
801009ef:	e8 f5 49 00 00       	call   801053e9 <release>
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
80100a1c:	e8 89 3c 00 00       	call   801046aa <sleep>
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
80100a9a:	e8 4a 49 00 00       	call   801053e9 <release>
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
80100adc:	e8 96 48 00 00       	call   80105377 <acquire>
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
80100b1e:	e8 c6 48 00 00       	call   801053e9 <release>
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
80100b50:	68 17 b0 10 80       	push   $0x8010b017
80100b55:	68 20 e0 18 80       	push   $0x8018e020
80100b5a:	e8 f2 47 00 00       	call   80105351 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 2c 47 19 80 bc 	movl   $0x80100abc,0x8019472c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 28 47 19 80 a8 	movl   $0x801009a8,0x80194728
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 1f b0 10 80 	movl   $0x8010b01f,-0xc(%ebp)
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
80100bf7:	68 35 b0 10 80       	push   $0x8010b035
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
80100c53:	e8 2c 75 00 00       	call   80108184 <setupkvm>
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
80100cf9:	e8 98 78 00 00       	call   80108596 <allocuvm>
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
80100d3f:	e8 81 77 00 00       	call   801084c5 <loaduvm>
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
80100dae:	e8 e3 77 00 00       	call   80108596 <allocuvm>
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
80100dd2:	e8 2d 7a 00 00       	call   80108804 <clearpteu>
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
80100e0b:	e8 5f 4a 00 00       	call   8010586f <strlen>
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
80100e38:	e8 32 4a 00 00       	call   8010586f <strlen>
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
80100e5e:	e8 4c 7b 00 00       	call   801089af <copyout>
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
80100efa:	e8 b0 7a 00 00       	call   801089af <copyout>
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
80100f48:	e8 d4 48 00 00       	call   80105821 <safestrcpy>
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
80100f8b:	e8 1e 73 00 00       	call   801082ae <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 c9 77 00 00       	call   80108767 <freevm>
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
80100fd9:	e8 89 77 00 00       	call   80108767 <freevm>
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
8010100e:	68 41 b0 10 80       	push   $0x8010b041
80101013:	68 80 3d 19 80       	push   $0x80193d80
80101018:	e8 34 43 00 00       	call   80105351 <initlock>
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
80101035:	e8 3d 43 00 00       	call   80105377 <acquire>
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
80101062:	e8 82 43 00 00       	call   801053e9 <release>
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
80101085:	e8 5f 43 00 00       	call   801053e9 <release>
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
801010a6:	e8 cc 42 00 00       	call   80105377 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 48 b0 10 80       	push   $0x8010b048
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
801010dc:	e8 08 43 00 00       	call   801053e9 <release>
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
801010fb:	e8 77 42 00 00       	call   80105377 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 50 b0 10 80       	push   $0x8010b050
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
8010113b:	e8 a9 42 00 00       	call   801053e9 <release>
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
80101189:	e8 5b 42 00 00       	call   801053e9 <release>
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
801012e0:	68 5a b0 10 80       	push   $0x8010b05a
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
801013e7:	68 63 b0 10 80       	push   $0x8010b063
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
8010141d:	68 73 b0 10 80       	push   $0x8010b073
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
80101459:	e8 6f 42 00 00       	call   801056cd <memmove>
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
801014a3:	e8 5e 41 00 00       	call   80105606 <memset>
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
8010160e:	68 80 b0 10 80       	push   $0x8010b080
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
801016a5:	68 96 b0 10 80       	push   $0x8010b096
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
8010170d:	68 a9 b0 10 80       	push   $0x8010b0a9
80101712:	68 a0 47 19 80       	push   $0x801947a0
80101717:	e8 35 3c 00 00       	call   80105351 <initlock>
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
80101743:	68 b0 b0 10 80       	push   $0x8010b0b0
80101748:	50                   	push   %eax
80101749:	e8 96 3a 00 00       	call   801051e4 <initsleeplock>
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
801017a2:	68 b8 b0 10 80       	push   $0x8010b0b8
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
8010181f:	e8 e2 3d 00 00       	call   80105606 <memset>
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
80101887:	68 0b b1 10 80       	push   $0x8010b10b
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
80101931:	e8 97 3d 00 00       	call   801056cd <memmove>
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
8010196a:	e8 08 3a 00 00       	call   80105377 <acquire>
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
801019b8:	e8 2c 3a 00 00       	call   801053e9 <release>
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
801019f4:	68 1d b1 10 80       	push   $0x8010b11d
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
80101a31:	e8 b3 39 00 00       	call   801053e9 <release>
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
80101a50:	e8 22 39 00 00       	call   80105377 <acquire>
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
80101a6f:	e8 75 39 00 00       	call   801053e9 <release>
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
80101a99:	68 2d b1 10 80       	push   $0x8010b12d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 72 37 00 00       	call   80105224 <acquiresleep>
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
80101b57:	e8 71 3b 00 00       	call   801056cd <memmove>
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
80101b86:	68 33 b1 10 80       	push   $0x8010b133
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
80101bad:	e8 2c 37 00 00       	call   801052de <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 42 b1 10 80       	push   $0x8010b142
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 ad 36 00 00       	call   8010528c <releasesleep>
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
80101bf9:	e8 26 36 00 00       	call   80105224 <acquiresleep>
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
80101c1f:	e8 53 37 00 00       	call   80105377 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 a0 47 19 80       	push   $0x801947a0
80101c38:	e8 ac 37 00 00       	call   801053e9 <release>
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
80101c7f:	e8 08 36 00 00       	call   8010528c <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 a0 47 19 80       	push   $0x801947a0
80101c8f:	e8 e3 36 00 00       	call   80105377 <acquire>
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
80101cae:	e8 36 37 00 00       	call   801053e9 <release>
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
80101dfa:	68 4a b1 10 80       	push   $0x8010b14a
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
801020a4:	e8 24 36 00 00       	call   801056cd <memmove>
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
801021f8:	e8 d0 34 00 00       	call   801056cd <memmove>
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
8010227c:	e8 ea 34 00 00       	call   8010576b <strncmp>
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
801022a0:	68 5d b1 10 80       	push   $0x8010b15d
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
801022cf:	68 6f b1 10 80       	push   $0x8010b16f
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
801023a8:	68 7e b1 10 80       	push   $0x8010b17e
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
801023e3:	e8 dd 33 00 00       	call   801057c5 <strncpy>
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
8010240f:	68 8b b1 10 80       	push   $0x8010b18b
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
80102485:	e8 43 32 00 00       	call   801056cd <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 2c 32 00 00       	call   801056cd <memmove>
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
801026ab:	68 94 b1 10 80       	push   $0x8010b194
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
8010275a:	68 c6 b1 10 80       	push   $0x8010b1c6
8010275f:	68 00 64 19 80       	push   $0x80196400
80102764:	e8 e8 2b 00 00       	call   80105351 <initlock>
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
80102825:	68 cb b1 10 80       	push   $0x8010b1cb
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 c5 2d 00 00       	call   80105606 <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 34 64 19 80       	mov    0x80196434,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 00 64 19 80       	push   $0x80196400
80102855:	e8 1d 2b 00 00       	call   80105377 <acquire>
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
80102887:	e8 5d 2b 00 00       	call   801053e9 <release>
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
801028ad:	e8 c5 2a 00 00       	call   80105377 <acquire>
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
801028de:	e8 06 2b 00 00       	call   801053e9 <release>
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
80102e33:	e8 39 28 00 00       	call   80105671 <memcmp>
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
80102f4b:	68 d1 b1 10 80       	push   $0x8010b1d1
80102f50:	68 40 64 19 80       	push   $0x80196440
80102f55:	e8 f7 23 00 00       	call   80105351 <initlock>
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
80103004:	e8 c4 26 00 00       	call   801056cd <memmove>
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
80103183:	e8 ef 21 00 00       	call   80105377 <acquire>
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
801031a1:	e8 04 15 00 00       	call   801046aa <sleep>
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
801031d6:	e8 cf 14 00 00       	call   801046aa <sleep>
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
801031f5:	e8 ef 21 00 00       	call   801053e9 <release>
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
8010321a:	e8 58 21 00 00       	call   80105377 <acquire>
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
8010323b:	68 d5 b1 10 80       	push   $0x8010b1d5
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
80103269:	e8 2b 15 00 00       	call   80104799 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 40 64 19 80       	push   $0x80196440
80103279:	e8 6b 21 00 00       	call   801053e9 <release>
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
80103294:	e8 de 20 00 00       	call   80105377 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 80 64 19 80 00 	movl   $0x0,0x80196480
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 40 64 19 80       	push   $0x80196440
801032ae:	e8 e6 14 00 00       	call   80104799 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 40 64 19 80       	push   $0x80196440
801032be:	e8 26 21 00 00       	call   801053e9 <release>
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
8010333e:	e8 8a 23 00 00       	call   801056cd <memmove>
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
801033e3:	68 e4 b1 10 80       	push   $0x8010b1e4
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 7c 64 19 80       	mov    0x8019647c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 fa b1 10 80       	push   $0x8010b1fa
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 40 64 19 80       	push   $0x80196440
8010340b:	e8 67 1f 00 00       	call   80105377 <acquire>
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
80103489:	e8 5b 1f 00 00       	call   801053e9 <release>
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
801034c3:	e8 cf 57 00 00       	call   80108c97 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 a0 19 80       	push   $0x8019a000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 93 4d 00 00       	call   80108275 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 6a 55 00 00       	call   80108a51 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 0b 48 00 00       	call   80107cfc <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 80 3b 00 00       	call   80107085 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 11 36 00 00       	call   80106b20 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 7e 79 00 00       	call   8010ae9c <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 cd 59 00 00       	call   80108f0a <pci_init>
  arp_scan();
8010353d:	e8 46 67 00 00       	call   80109c88 <arp_scan>
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
80103556:	e8 36 4d 00 00       	call   80108291 <switchkvm>
  seginit();
8010355b:	e8 9c 47 00 00       	call   80107cfc <seginit>
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
80103586:	68 15 b2 10 80       	push   $0x8010b215
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 02 37 00 00       	call   80106c9a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 8a 0e 00 00       	call   8010443f <scheduler>

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
801035d7:	e8 f1 20 00 00       	call   801056cd <memmove>
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
80103768:	68 29 b2 10 80       	push   $0x8010b229
8010376d:	50                   	push   %eax
8010376e:	e8 de 1b 00 00       	call   80105351 <initlock>
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
80103831:	e8 41 1b 00 00       	call   80105377 <acquire>
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
80103858:	e8 3c 0f 00 00       	call   80104799 <wakeup>
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
8010387b:	e8 19 0f 00 00       	call   80104799 <wakeup>
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
801038a4:	e8 40 1b 00 00       	call   801053e9 <release>
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
801038c3:	e8 21 1b 00 00       	call   801053e9 <release>
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
801038e1:	e8 91 1a 00 00       	call   80105377 <acquire>
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
80103915:	e8 cf 1a 00 00       	call   801053e9 <release>
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
80103933:	e8 61 0e 00 00       	call   80104799 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 59 0d 00 00       	call   801046aa <sleep>
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
801039b6:	e8 de 0d 00 00       	call   80104799 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 1f 1a 00 00       	call   801053e9 <release>
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
801039e6:	e8 8c 19 00 00       	call   80105377 <acquire>
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
80103a03:	e8 e1 19 00 00       	call   801053e9 <release>
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
80103a26:	e8 7f 0c 00 00       	call   801046aa <sleep>
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
80103ab9:	e8 db 0c 00 00       	call   80104799 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 1c 19 00 00       	call   801053e9 <release>
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
80103af9:	68 30 b2 10 80       	push   $0x8010b230
80103afe:	68 20 75 19 80       	push   $0x80197520
80103b03:	e8 49 18 00 00       	call   80105351 <initlock>
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
80103b48:	68 38 b2 10 80       	push   $0x8010b238
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
80103b9d:	68 5e b2 10 80       	push   $0x8010b25e
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
80103bb3:	e8 3b 19 00 00       	call   801054f3 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 73 19 00 00       	call   80105544 <popcli>
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
80103be8:	e8 8a 17 00 00       	call   80105377 <acquire>
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
80103c18:	e8 cc 17 00 00       	call   801053e9 <release>
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
80103cae:	e8 53 19 00 00       	call   80105606 <memset>
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
80103ccc:	e8 35 19 00 00       	call   80105606 <memset>
80103cd1:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103cd4:	83 ec 0c             	sub    $0xc,%esp
80103cd7:	68 20 75 19 80       	push   $0x80197520
80103cdc:	e8 08 17 00 00       	call   801053e9 <release>
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
80103d03:	68 70 b2 10 80       	push   $0x8010b270
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
80103d40:	ba da 6a 10 80       	mov    $0x80106ada,%edx
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
80103d65:	e8 9c 18 00 00       	call   80105606 <memset>
80103d6a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d70:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d73:	ba 60 46 10 80       	mov    $0x80104660,%edx
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
80103d9a:	e8 e5 43 00 00       	call   80108184 <setupkvm>
80103d9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da2:	89 42 04             	mov    %eax,0x4(%edx)
80103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da8:	8b 40 04             	mov    0x4(%eax),%eax
80103dab:	85 c0                	test   %eax,%eax
80103dad:	75 0d                	jne    80103dbc <userinit+0x3c>
    panic("userinit: out of memory?");
80103daf:	83 ec 0c             	sub    $0xc,%esp
80103db2:	68 9e b2 10 80       	push   $0x8010b29e
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
80103dd1:	e8 7b 46 00 00       	call   80108451 <inituvm>
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
80103df0:	e8 11 18 00 00       	call   80105606 <memset>
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
80103e6a:	68 b7 b2 10 80       	push   $0x8010b2b7
80103e6f:	50                   	push   %eax
80103e70:	e8 ac 19 00 00       	call   80105821 <safestrcpy>
80103e75:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	68 c0 b2 10 80       	push   $0x8010b2c0
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
80103e96:	e8 dc 14 00 00       	call   80105377 <acquire>
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
80103ebf:	e8 eb 0c 00 00       	call   80104baf <enqueue>
80103ec4:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103ec7:	83 ec 0c             	sub    $0xc,%esp
80103eca:	68 20 75 19 80       	push   $0x80197520
80103ecf:	e8 15 15 00 00       	call   801053e9 <release>
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
80103f10:	e8 81 46 00 00       	call   80108596 <allocuvm>
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
80103f44:	e8 56 47 00 00       	call   8010869f <deallocuvm>
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
80103f6a:	e8 3f 43 00 00       	call   801082ae <switchuvm>
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
80103fa1:	e9 e9 01 00 00       	jmp    8010418f <fork+0x216>
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
80103fb6:	e8 8e 48 00 00       	call   80108849 <copyuvm>
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
80103ff9:	e9 91 01 00 00       	jmp    8010418f <fork+0x216>
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
801040b0:	e8 6c 17 00 00       	call   80105821 <safestrcpy>
801040b5:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801040b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040bb:	8b 40 10             	mov    0x10(%eax),%eax
801040be:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801040c1:	83 ec 0c             	sub    $0xc,%esp
801040c4:	68 20 75 19 80       	push   $0x80197520
801040c9:	e8 a9 12 00 00       	call   80105377 <acquire>
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
80104137:	e8 ca 14 00 00       	call   80105606 <memset>
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
80104155:	e8 ac 14 00 00       	call   80105606 <memset>
8010415a:	83 c4 10             	add    $0x10,%esp

  if (mycpu()->sched_policy > 0)
8010415d:	e8 cb f9 ff ff       	call   80103b2d <mycpu>
80104162:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	7e 10                	jle    8010417c <fork+0x203>
    enqueue(np, 3);
8010416c:	83 ec 08             	sub    $0x8,%esp
8010416f:	6a 03                	push   $0x3
80104171:	ff 75 dc             	push   -0x24(%ebp)
80104174:	e8 36 0a 00 00       	call   80104baf <enqueue>
80104179:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010417c:	83 ec 0c             	sub    $0xc,%esp
8010417f:	68 20 75 19 80       	push   $0x80197520
80104184:	e8 60 12 00 00       	call   801053e9 <release>
80104189:	83 c4 10             	add    $0x10,%esp

  return pid;
8010418c:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010418f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104192:	5b                   	pop    %ebx
80104193:	5e                   	pop    %esi
80104194:	5f                   	pop    %edi
80104195:	5d                   	pop    %ebp
80104196:	c3                   	ret

80104197 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104197:	f3 0f 1e fb          	endbr32
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801041a1:	e8 03 fa ff ff       	call   80103ba9 <myproc>
801041a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801041a9:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
801041ae:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041b1:	75 0d                	jne    801041c0 <exit+0x29>
    panic("init exiting");
801041b3:	83 ec 0c             	sub    $0xc,%esp
801041b6:	68 c2 b2 10 80       	push   $0x8010b2c2
801041bb:	e8 05 c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801041c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801041c7:	eb 3f                	jmp    80104208 <exit+0x71>
    if(curproc->ofile[fd]){
801041c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041cf:	83 c2 08             	add    $0x8,%edx
801041d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041d6:	85 c0                	test   %eax,%eax
801041d8:	74 2a                	je     80104204 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
801041da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041e0:	83 c2 08             	add    $0x8,%edx
801041e3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	50                   	push   %eax
801041eb:	e8 f9 ce ff ff       	call   801010e9 <fileclose>
801041f0:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041f9:	83 c2 08             	add    $0x8,%edx
801041fc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104203:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104204:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104208:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010420c:	7e bb                	jle    801041c9 <exit+0x32>
    }
  }

  begin_op();
8010420e:	e8 5e ef ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
80104213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104216:	8b 40 68             	mov    0x68(%eax),%eax
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	50                   	push   %eax
8010421d:	e8 c3 d9 ff ff       	call   80101be5 <iput>
80104222:	83 c4 10             	add    $0x10,%esp
  end_op();
80104225:	e8 d7 ef ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
8010422a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010422d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104234:	83 ec 0c             	sub    $0xc,%esp
80104237:	68 20 75 19 80       	push   $0x80197520
8010423c:	e8 36 11 00 00       	call   80105377 <acquire>
80104241:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104247:	8b 40 14             	mov    0x14(%eax),%eax
8010424a:	83 ec 0c             	sub    $0xc,%esp
8010424d:	50                   	push   %eax
8010424e:	e8 02 05 00 00       	call   80104755 <wakeup1>
80104253:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104256:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
8010425d:	eb 37                	jmp    80104296 <exit+0xff>
    if(p->parent == curproc){
8010425f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104262:	8b 40 14             	mov    0x14(%eax),%eax
80104265:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104268:	75 28                	jne    80104292 <exit+0xfb>
      p->parent = initproc;
8010426a:	8b 15 7c e0 18 80    	mov    0x8018e07c,%edx
80104270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104273:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104279:	8b 40 0c             	mov    0xc(%eax),%eax
8010427c:	83 f8 05             	cmp    $0x5,%eax
8010427f:	75 11                	jne    80104292 <exit+0xfb>
        wakeup1(initproc);
80104281:	a1 7c e0 18 80       	mov    0x8018e07c,%eax
80104286:	83 ec 0c             	sub    $0xc,%esp
80104289:	50                   	push   %eax
8010428a:	e8 c6 04 00 00       	call   80104755 <wakeup1>
8010428f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104292:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104296:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
8010429d:	72 c0                	jb     8010425f <exit+0xc8>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
8010429f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042a2:	2d 54 75 19 80       	sub    $0x80197554,%eax
801042a7:	c1 f8 02             	sar    $0x2,%eax
801042aa:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801042b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
801042b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042b6:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
801042bd:	00 00 00 00 
  int q;
  q = kernel_pstat.priority[i];
801042c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042c4:	83 e8 80             	sub    $0xffffff80,%eax
801042c7:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
801042ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (get_sched_policy() > 0)
801042d1:	e8 b2 08 00 00       	call   80104b88 <get_sched_policy>
801042d6:	85 c0                	test   %eax,%eax
801042d8:	7e 25                	jle    801042ff <exit+0x168>
  {
    dequeue(q);
801042da:	83 ec 0c             	sub    $0xc,%esp
801042dd:	ff 75 e4             	push   -0x1c(%ebp)
801042e0:	e8 49 09 00 00       	call   80104c2e <dequeue>
801042e5:	83 c4 10             	add    $0x10,%esp
    cprintf("[PROCESS EXIT] pid: %d\n", curproc->pid);
801042e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042eb:	8b 40 10             	mov    0x10(%eax),%eax
801042ee:	83 ec 08             	sub    $0x8,%esp
801042f1:	50                   	push   %eax
801042f2:	68 cf b2 10 80       	push   $0x8010b2cf
801042f7:	e8 10 c1 ff ff       	call   8010040c <cprintf>
801042fc:	83 c4 10             	add    $0x10,%esp
  }
  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801042ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104302:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104309:	e8 57 02 00 00       	call   80104565 <sched>
  panic("zombie exit");
8010430e:	83 ec 0c             	sub    $0xc,%esp
80104311:	68 e7 b2 10 80       	push   $0x8010b2e7
80104316:	e8 aa c2 ff ff       	call   801005c5 <panic>

8010431b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010431b:	f3 0f 1e fb          	endbr32
8010431f:	55                   	push   %ebp
80104320:	89 e5                	mov    %esp,%ebp
80104322:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104325:	e8 7f f8 ff ff       	call   80103ba9 <myproc>
8010432a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010432d:	83 ec 0c             	sub    $0xc,%esp
80104330:	68 20 75 19 80       	push   $0x80197520
80104335:	e8 3d 10 00 00       	call   80105377 <acquire>
8010433a:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010433d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104344:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
8010434b:	e9 a1 00 00 00       	jmp    801043f1 <wait+0xd6>
      if(p->parent != curproc)
80104350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104353:	8b 40 14             	mov    0x14(%eax),%eax
80104356:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104359:	0f 85 8d 00 00 00    	jne    801043ec <wait+0xd1>
        continue;
      havekids = 1;
8010435f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104369:	8b 40 0c             	mov    0xc(%eax),%eax
8010436c:	83 f8 05             	cmp    $0x5,%eax
8010436f:	75 7c                	jne    801043ed <wait+0xd2>
        // Found one.
        pid = p->pid;
80104371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104374:	8b 40 10             	mov    0x10(%eax),%eax
80104377:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437d:	8b 40 08             	mov    0x8(%eax),%eax
80104380:	83 ec 0c             	sub    $0xc,%esp
80104383:	50                   	push   %eax
80104384:	e8 6b e4 ff ff       	call   801027f4 <kfree>
80104389:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	8b 40 04             	mov    0x4(%eax),%eax
8010439c:	83 ec 0c             	sub    $0xc,%esp
8010439f:	50                   	push   %eax
801043a0:	e8 c2 43 00 00       	call   80108767 <freevm>
801043a5:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801043b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801043bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bf:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801043c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c6:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801043cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801043d7:	83 ec 0c             	sub    $0xc,%esp
801043da:	68 20 75 19 80       	push   $0x80197520
801043df:	e8 05 10 00 00       	call   801053e9 <release>
801043e4:	83 c4 10             	add    $0x10,%esp
        return pid;
801043e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043ea:	eb 51                	jmp    8010443d <wait+0x122>
        continue;
801043ec:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043ed:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043f1:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
801043f8:	0f 82 52 ff ff ff    	jb     80104350 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801043fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104402:	74 0a                	je     8010440e <wait+0xf3>
80104404:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104407:	8b 40 24             	mov    0x24(%eax),%eax
8010440a:	85 c0                	test   %eax,%eax
8010440c:	74 17                	je     80104425 <wait+0x10a>
      release(&ptable.lock);
8010440e:	83 ec 0c             	sub    $0xc,%esp
80104411:	68 20 75 19 80       	push   $0x80197520
80104416:	e8 ce 0f 00 00       	call   801053e9 <release>
8010441b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010441e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104423:	eb 18                	jmp    8010443d <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104425:	83 ec 08             	sub    $0x8,%esp
80104428:	68 20 75 19 80       	push   $0x80197520
8010442d:	ff 75 ec             	push   -0x14(%ebp)
80104430:	e8 75 02 00 00       	call   801046aa <sleep>
80104435:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104438:	e9 00 ff ff ff       	jmp    8010433d <wait+0x22>
  }
}
8010443d:	c9                   	leave
8010443e:	c3                   	ret

8010443f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010443f:	f3 0f 1e fb          	endbr32
80104443:	55                   	push   %ebp
80104444:	89 e5                	mov    %esp,%ebp
80104446:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104449:	e8 df f6 ff ff       	call   80103b2d <mycpu>
8010444e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104454:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010445b:	00 00 00 

  for(;;){
    sti();
8010445e:	e8 82 f6 ff ff       	call   80103ae5 <sti>
    acquire(&ptable.lock);
80104463:	83 ec 0c             	sub    $0xc,%esp
80104466:	68 20 75 19 80       	push   $0x80197520
8010446b:	e8 07 0f 00 00       	call   80105377 <acquire>
80104470:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 0) {
80104473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104476:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010447c:	85 c0                	test   %eax,%eax
8010447e:	75 75                	jne    801044f5 <scheduler+0xb6>
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104480:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
80104487:	eb 61                	jmp    801044ea <scheduler+0xab>
        if(p->state != RUNNABLE)
80104489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448c:	8b 40 0c             	mov    0xc(%eax),%eax
8010448f:	83 f8 03             	cmp    $0x3,%eax
80104492:	75 51                	jne    801044e5 <scheduler+0xa6>
          continue;
        c->proc = p;
80104494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104497:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801044a0:	83 ec 0c             	sub    $0xc,%esp
801044a3:	ff 75 f4             	push   -0xc(%ebp)
801044a6:	e8 03 3e 00 00       	call   801082ae <switchuvm>
801044ab:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&(c->scheduler), p->context);
801044b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bb:	8b 40 1c             	mov    0x1c(%eax),%eax
801044be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044c1:	83 c2 04             	add    $0x4,%edx
801044c4:	83 ec 08             	sub    $0x8,%esp
801044c7:	50                   	push   %eax
801044c8:	52                   	push   %edx
801044c9:	e8 cc 13 00 00       	call   8010589a <swtch>
801044ce:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801044d1:	e8 bb 3d 00 00       	call   80108291 <switchkvm>
        c->proc = 0;
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801044e0:	00 00 00 
801044e3:	eb 01                	jmp    801044e6 <scheduler+0xa7>
          continue;
801044e5:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044e6:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044ea:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
801044f1:	72 96                	jb     80104489 <scheduler+0x4a>
801044f3:	eb 5b                	jmp    80104550 <scheduler+0x111>
      //   if(p->state == RUNNABLE && p != c->proc){
      //     int i = p - ptable.proc;
      //     kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
      //   }
      // }
    } else if (c->sched_policy == 1) {
801044f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044fe:	83 f8 01             	cmp    $0x1,%eax
80104501:	75 11                	jne    80104514 <scheduler+0xd5>
      run_mlfq(1, 1);
80104503:	83 ec 08             	sub    $0x8,%esp
80104506:	6a 01                	push   $0x1
80104508:	6a 01                	push   $0x1
8010450a:	e8 7e 0b 00 00       	call   8010508d <run_mlfq>
8010450f:	83 c4 10             	add    $0x10,%esp
80104512:	eb 3c                	jmp    80104550 <scheduler+0x111>
    } else if (c->sched_policy == 2) {
80104514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104517:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010451d:	83 f8 02             	cmp    $0x2,%eax
80104520:	75 11                	jne    80104533 <scheduler+0xf4>
      run_mlfq(0, 1);
80104522:	83 ec 08             	sub    $0x8,%esp
80104525:	6a 01                	push   $0x1
80104527:	6a 00                	push   $0x0
80104529:	e8 5f 0b 00 00       	call   8010508d <run_mlfq>
8010452e:	83 c4 10             	add    $0x10,%esp
80104531:	eb 1d                	jmp    80104550 <scheduler+0x111>
    } else if (c->sched_policy == 3) {
80104533:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104536:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010453c:	83 f8 03             	cmp    $0x3,%eax
8010453f:	75 0f                	jne    80104550 <scheduler+0x111>
      run_mlfq(1, 0);
80104541:	83 ec 08             	sub    $0x8,%esp
80104544:	6a 00                	push   $0x0
80104546:	6a 01                	push   $0x1
80104548:	e8 40 0b 00 00       	call   8010508d <run_mlfq>
8010454d:	83 c4 10             	add    $0x10,%esp
    }
    release(&ptable.lock);
80104550:	83 ec 0c             	sub    $0xc,%esp
80104553:	68 20 75 19 80       	push   $0x80197520
80104558:	e8 8c 0e 00 00       	call   801053e9 <release>
8010455d:	83 c4 10             	add    $0x10,%esp
    sti();
80104560:	e9 f9 fe ff ff       	jmp    8010445e <scheduler+0x1f>

80104565 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104565:	f3 0f 1e fb          	endbr32
80104569:	55                   	push   %ebp
8010456a:	89 e5                	mov    %esp,%ebp
8010456c:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010456f:	e8 35 f6 ff ff       	call   80103ba9 <myproc>
80104574:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104577:	83 ec 0c             	sub    $0xc,%esp
8010457a:	68 20 75 19 80       	push   $0x80197520
8010457f:	e8 3a 0f 00 00       	call   801054be <holding>
80104584:	83 c4 10             	add    $0x10,%esp
80104587:	85 c0                	test   %eax,%eax
80104589:	75 0d                	jne    80104598 <sched+0x33>
    panic("sched ptable.lock");
8010458b:	83 ec 0c             	sub    $0xc,%esp
8010458e:	68 f3 b2 10 80       	push   $0x8010b2f3
80104593:	e8 2d c0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104598:	e8 90 f5 ff ff       	call   80103b2d <mycpu>
8010459d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801045a3:	83 f8 01             	cmp    $0x1,%eax
801045a6:	74 0d                	je     801045b5 <sched+0x50>
    panic("sched locks");
801045a8:	83 ec 0c             	sub    $0xc,%esp
801045ab:	68 05 b3 10 80       	push   $0x8010b305
801045b0:	e8 10 c0 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
801045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b8:	8b 40 0c             	mov    0xc(%eax),%eax
801045bb:	83 f8 04             	cmp    $0x4,%eax
801045be:	75 0d                	jne    801045cd <sched+0x68>
    panic("sched running");
801045c0:	83 ec 0c             	sub    $0xc,%esp
801045c3:	68 11 b3 10 80       	push   $0x8010b311
801045c8:	e8 f8 bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801045cd:	e8 03 f5 ff ff       	call   80103ad5 <readeflags>
801045d2:	25 00 02 00 00       	and    $0x200,%eax
801045d7:	85 c0                	test   %eax,%eax
801045d9:	74 0d                	je     801045e8 <sched+0x83>
    panic("sched interruptible");
801045db:	83 ec 0c             	sub    $0xc,%esp
801045de:	68 1f b3 10 80       	push   $0x8010b31f
801045e3:	e8 dd bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801045e8:	e8 40 f5 ff ff       	call   80103b2d <mycpu>
801045ed:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045f6:	e8 32 f5 ff ff       	call   80103b2d <mycpu>
801045fb:	8b 40 04             	mov    0x4(%eax),%eax
801045fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104601:	83 c2 1c             	add    $0x1c,%edx
80104604:	83 ec 08             	sub    $0x8,%esp
80104607:	50                   	push   %eax
80104608:	52                   	push   %edx
80104609:	e8 8c 12 00 00       	call   8010589a <swtch>
8010460e:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104611:	e8 17 f5 ff ff       	call   80103b2d <mycpu>
80104616:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104619:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010461f:	90                   	nop
80104620:	c9                   	leave
80104621:	c3                   	ret

80104622 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104622:	f3 0f 1e fb          	endbr32
80104626:	55                   	push   %ebp
80104627:	89 e5                	mov    %esp,%ebp
80104629:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010462c:	83 ec 0c             	sub    $0xc,%esp
8010462f:	68 20 75 19 80       	push   $0x80197520
80104634:	e8 3e 0d 00 00       	call   80105377 <acquire>
80104639:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010463c:	e8 68 f5 ff ff       	call   80103ba9 <myproc>
80104641:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104648:	e8 18 ff ff ff       	call   80104565 <sched>
  release(&ptable.lock);
8010464d:	83 ec 0c             	sub    $0xc,%esp
80104650:	68 20 75 19 80       	push   $0x80197520
80104655:	e8 8f 0d 00 00       	call   801053e9 <release>
8010465a:	83 c4 10             	add    $0x10,%esp
}
8010465d:	90                   	nop
8010465e:	c9                   	leave
8010465f:	c3                   	ret

80104660 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104660:	f3 0f 1e fb          	endbr32
80104664:	55                   	push   %ebp
80104665:	89 e5                	mov    %esp,%ebp
80104667:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010466a:	83 ec 0c             	sub    $0xc,%esp
8010466d:	68 20 75 19 80       	push   $0x80197520
80104672:	e8 72 0d 00 00       	call   801053e9 <release>
80104677:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010467a:	a1 04 00 11 80       	mov    0x80110004,%eax
8010467f:	85 c0                	test   %eax,%eax
80104681:	74 24                	je     801046a7 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104683:	c7 05 04 00 11 80 00 	movl   $0x0,0x80110004
8010468a:	00 00 00 
    iinit(ROOTDEV);
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	6a 01                	push   $0x1
80104692:	e8 5f d0 ff ff       	call   801016f6 <iinit>
80104697:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010469a:	83 ec 0c             	sub    $0xc,%esp
8010469d:	6a 01                	push   $0x1
8010469f:	e8 9a e8 ff ff       	call   80102f3e <initlog>
801046a4:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801046a7:	90                   	nop
801046a8:	c9                   	leave
801046a9:	c3                   	ret

801046aa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801046aa:	f3 0f 1e fb          	endbr32
801046ae:	55                   	push   %ebp
801046af:	89 e5                	mov    %esp,%ebp
801046b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801046b4:	e8 f0 f4 ff ff       	call   80103ba9 <myproc>
801046b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801046bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046c0:	75 0d                	jne    801046cf <sleep+0x25>
    panic("sleep");
801046c2:	83 ec 0c             	sub    $0xc,%esp
801046c5:	68 33 b3 10 80       	push   $0x8010b333
801046ca:	e8 f6 be ff ff       	call   801005c5 <panic>

  if(lk == 0)
801046cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046d3:	75 0d                	jne    801046e2 <sleep+0x38>
    panic("sleep without lk");
801046d5:	83 ec 0c             	sub    $0xc,%esp
801046d8:	68 39 b3 10 80       	push   $0x8010b339
801046dd:	e8 e3 be ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801046e2:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
801046e9:	74 1e                	je     80104709 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801046eb:	83 ec 0c             	sub    $0xc,%esp
801046ee:	68 20 75 19 80       	push   $0x80197520
801046f3:	e8 7f 0c 00 00       	call   80105377 <acquire>
801046f8:	83 c4 10             	add    $0x10,%esp
    release(lk);
801046fb:	83 ec 0c             	sub    $0xc,%esp
801046fe:	ff 75 0c             	push   0xc(%ebp)
80104701:	e8 e3 0c 00 00       	call   801053e9 <release>
80104706:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	8b 55 08             	mov    0x8(%ebp),%edx
8010470f:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104715:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010471c:	e8 44 fe ff ff       	call   80104565 <sched>

  // Tidy up.
  p->chan = 0;
80104721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104724:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010472b:	81 7d 0c 20 75 19 80 	cmpl   $0x80197520,0xc(%ebp)
80104732:	74 1e                	je     80104752 <sleep+0xa8>
    release(&ptable.lock);
80104734:	83 ec 0c             	sub    $0xc,%esp
80104737:	68 20 75 19 80       	push   $0x80197520
8010473c:	e8 a8 0c 00 00       	call   801053e9 <release>
80104741:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104744:	83 ec 0c             	sub    $0xc,%esp
80104747:	ff 75 0c             	push   0xc(%ebp)
8010474a:	e8 28 0c 00 00       	call   80105377 <acquire>
8010474f:	83 c4 10             	add    $0x10,%esp
  }
}
80104752:	90                   	nop
80104753:	c9                   	leave
80104754:	c3                   	ret

80104755 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104755:	f3 0f 1e fb          	endbr32
80104759:	55                   	push   %ebp
8010475a:	89 e5                	mov    %esp,%ebp
8010475c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010475f:	c7 45 fc 54 75 19 80 	movl   $0x80197554,-0x4(%ebp)
80104766:	eb 24                	jmp    8010478c <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104768:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010476b:	8b 40 0c             	mov    0xc(%eax),%eax
8010476e:	83 f8 02             	cmp    $0x2,%eax
80104771:	75 15                	jne    80104788 <wakeup1+0x33>
80104773:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104776:	8b 40 20             	mov    0x20(%eax),%eax
80104779:	39 45 08             	cmp    %eax,0x8(%ebp)
8010477c:	75 0a                	jne    80104788 <wakeup1+0x33>
      p->state = RUNNABLE;
8010477e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104781:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104788:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010478c:	81 7d fc 54 94 19 80 	cmpl   $0x80199454,-0x4(%ebp)
80104793:	72 d3                	jb     80104768 <wakeup1+0x13>
}
80104795:	90                   	nop
80104796:	90                   	nop
80104797:	c9                   	leave
80104798:	c3                   	ret

80104799 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104799:	f3 0f 1e fb          	endbr32
8010479d:	55                   	push   %ebp
8010479e:	89 e5                	mov    %esp,%ebp
801047a0:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801047a3:	83 ec 0c             	sub    $0xc,%esp
801047a6:	68 20 75 19 80       	push   $0x80197520
801047ab:	e8 c7 0b 00 00       	call   80105377 <acquire>
801047b0:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801047b3:	83 ec 0c             	sub    $0xc,%esp
801047b6:	ff 75 08             	push   0x8(%ebp)
801047b9:	e8 97 ff ff ff       	call   80104755 <wakeup1>
801047be:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047c1:	83 ec 0c             	sub    $0xc,%esp
801047c4:	68 20 75 19 80       	push   $0x80197520
801047c9:	e8 1b 0c 00 00       	call   801053e9 <release>
801047ce:	83 c4 10             	add    $0x10,%esp
}
801047d1:	90                   	nop
801047d2:	c9                   	leave
801047d3:	c3                   	ret

801047d4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801047d4:	f3 0f 1e fb          	endbr32
801047d8:	55                   	push   %ebp
801047d9:	89 e5                	mov    %esp,%ebp
801047db:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801047de:	83 ec 0c             	sub    $0xc,%esp
801047e1:	68 20 75 19 80       	push   $0x80197520
801047e6:	e8 8c 0b 00 00       	call   80105377 <acquire>
801047eb:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ee:	c7 45 f4 54 75 19 80 	movl   $0x80197554,-0xc(%ebp)
801047f5:	eb 45                	jmp    8010483c <kill+0x68>
    if(p->pid == pid){
801047f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fa:	8b 40 10             	mov    0x10(%eax),%eax
801047fd:	39 45 08             	cmp    %eax,0x8(%ebp)
80104800:	75 36                	jne    80104838 <kill+0x64>
      p->killed = 1;
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010480c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480f:	8b 40 0c             	mov    0xc(%eax),%eax
80104812:	83 f8 02             	cmp    $0x2,%eax
80104815:	75 0a                	jne    80104821 <kill+0x4d>
        p->state = RUNNABLE;
80104817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104821:	83 ec 0c             	sub    $0xc,%esp
80104824:	68 20 75 19 80       	push   $0x80197520
80104829:	e8 bb 0b 00 00       	call   801053e9 <release>
8010482e:	83 c4 10             	add    $0x10,%esp
      return 0;
80104831:	b8 00 00 00 00       	mov    $0x0,%eax
80104836:	eb 22                	jmp    8010485a <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104838:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010483c:	81 7d f4 54 94 19 80 	cmpl   $0x80199454,-0xc(%ebp)
80104843:	72 b2                	jb     801047f7 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104845:	83 ec 0c             	sub    $0xc,%esp
80104848:	68 20 75 19 80       	push   $0x80197520
8010484d:	e8 97 0b 00 00       	call   801053e9 <release>
80104852:	83 c4 10             	add    $0x10,%esp
  return -1;
80104855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010485a:	c9                   	leave
8010485b:	c3                   	ret

8010485c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010485c:	f3 0f 1e fb          	endbr32
80104860:	55                   	push   %ebp
80104861:	89 e5                	mov    %esp,%ebp
80104863:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104866:	c7 45 f0 54 75 19 80 	movl   $0x80197554,-0x10(%ebp)
8010486d:	e9 d7 00 00 00       	jmp    80104949 <procdump+0xed>
    if(p->state == UNUSED)
80104872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104875:	8b 40 0c             	mov    0xc(%eax),%eax
80104878:	85 c0                	test   %eax,%eax
8010487a:	0f 84 c4 00 00 00    	je     80104944 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104883:	8b 40 0c             	mov    0xc(%eax),%eax
80104886:	83 f8 05             	cmp    $0x5,%eax
80104889:	77 23                	ja     801048ae <procdump+0x52>
8010488b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010488e:	8b 40 0c             	mov    0xc(%eax),%eax
80104891:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
80104898:	85 c0                	test   %eax,%eax
8010489a:	74 12                	je     801048ae <procdump+0x52>
      state = states[p->state];
8010489c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489f:	8b 40 0c             	mov    0xc(%eax),%eax
801048a2:	8b 04 85 08 00 11 80 	mov    -0x7feefff8(,%eax,4),%eax
801048a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801048ac:	eb 07                	jmp    801048b5 <procdump+0x59>
    else
      state = "???";
801048ae:	c7 45 ec 4a b3 10 80 	movl   $0x8010b34a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801048b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b8:	8d 50 6c             	lea    0x6c(%eax),%edx
801048bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048be:	8b 40 10             	mov    0x10(%eax),%eax
801048c1:	52                   	push   %edx
801048c2:	ff 75 ec             	push   -0x14(%ebp)
801048c5:	50                   	push   %eax
801048c6:	68 4e b3 10 80       	push   $0x8010b34e
801048cb:	e8 3c bb ff ff       	call   8010040c <cprintf>
801048d0:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801048d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d6:	8b 40 0c             	mov    0xc(%eax),%eax
801048d9:	83 f8 02             	cmp    $0x2,%eax
801048dc:	75 54                	jne    80104932 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801048de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e1:	8b 40 1c             	mov    0x1c(%eax),%eax
801048e4:	8b 40 0c             	mov    0xc(%eax),%eax
801048e7:	83 c0 08             	add    $0x8,%eax
801048ea:	89 c2                	mov    %eax,%edx
801048ec:	83 ec 08             	sub    $0x8,%esp
801048ef:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801048f2:	50                   	push   %eax
801048f3:	52                   	push   %edx
801048f4:	e8 46 0b 00 00       	call   8010543f <getcallerpcs>
801048f9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104903:	eb 1c                	jmp    80104921 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010490c:	83 ec 08             	sub    $0x8,%esp
8010490f:	50                   	push   %eax
80104910:	68 57 b3 10 80       	push   $0x8010b357
80104915:	e8 f2 ba ff ff       	call   8010040c <cprintf>
8010491a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010491d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104921:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104925:	7f 0b                	jg     80104932 <procdump+0xd6>
80104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010492e:	85 c0                	test   %eax,%eax
80104930:	75 d3                	jne    80104905 <procdump+0xa9>
    }
    cprintf("\n");
80104932:	83 ec 0c             	sub    $0xc,%esp
80104935:	68 5b b3 10 80       	push   $0x8010b35b
8010493a:	e8 cd ba ff ff       	call   8010040c <cprintf>
8010493f:	83 c4 10             	add    $0x10,%esp
80104942:	eb 01                	jmp    80104945 <procdump+0xe9>
      continue;
80104944:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104945:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104949:	81 7d f0 54 94 19 80 	cmpl   $0x80199454,-0x10(%ebp)
80104950:	0f 82 1c ff ff ff    	jb     80104872 <procdump+0x16>
  }
}
80104956:	90                   	nop
80104957:	90                   	nop
80104958:	c9                   	leave
80104959:	c3                   	ret

8010495a <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
8010495a:	f3 0f 1e fb          	endbr32
8010495e:	55                   	push   %ebp
8010495f:	89 e5                	mov    %esp,%ebp
80104961:	53                   	push   %ebx
80104962:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104965:	83 ec 0c             	sub    $0xc,%esp
80104968:	68 20 75 19 80       	push   $0x80197520
8010496d:	e8 05 0a 00 00       	call   80105377 <acquire>
80104972:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104975:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010497c:	e9 e6 00 00 00       	jmp    80104a67 <getpinfo+0x10d>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104984:	8b 0c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ecx
8010498b:	8b 45 08             	mov    0x8(%ebp),%eax
8010498e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104991:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104997:	83 c0 40             	add    $0x40,%eax
8010499a:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
801049a1:	8b 45 08             	mov    0x8(%ebp),%eax
801049a4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049a7:	83 c1 40             	add    $0x40,%ecx
801049aa:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
801049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b0:	83 e8 80             	sub    $0xffffff80,%eax
801049b3:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
801049ba:	8b 45 08             	mov    0x8(%ebp),%eax
801049bd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049c0:	83 e9 80             	sub    $0xffffff80,%ecx
801049c3:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
801049c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
801049cc:	05 60 75 19 80       	add    $0x80197560,%eax
801049d1:	8b 00                	mov    (%eax),%eax
801049d3:	89 c1                	mov    %eax,%ecx
801049d5:	8b 45 08             	mov    0x8(%ebp),%eax
801049d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049db:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801049e1:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801049e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049eb:	eb 70                	jmp    80104a5d <getpinfo+0x103>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801049ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049fa:	01 d0                	add    %edx,%eax
801049fc:	05 00 01 00 00       	add    $0x100,%eax
80104a01:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104a08:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a0e:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a15:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a18:	01 d9                	add    %ebx,%ecx
80104a1a:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a20:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
80104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a30:	01 d0                	add    %edx,%eax
80104a32:	05 00 02 00 00       	add    $0x200,%eax
80104a37:	8b 14 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%edx
80104a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a41:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a44:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a4b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a4e:	01 d9                	add    %ebx,%ecx
80104a50:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a56:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104a59:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a5d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a61:	7e 8a                	jle    801049ed <getpinfo+0x93>
  for (int i = 0; i < NPROC; i++) {
80104a63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a67:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a6b:	0f 8e 10 ff ff ff    	jle    80104981 <getpinfo+0x27>
    }
  }
  release(&ptable.lock);
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	68 20 75 19 80       	push   $0x80197520
80104a79:	e8 6b 09 00 00       	call   801053e9 <release>
80104a7e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a89:	c9                   	leave
80104a8a:	c3                   	ret

80104a8b <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
80104a8b:	f3 0f 1e fb          	endbr32
80104a8f:	55                   	push   %ebp
80104a90:	89 e5                	mov    %esp,%ebp
80104a92:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a95:	83 ec 0c             	sub    $0xc,%esp
80104a98:	68 20 75 19 80       	push   $0x80197520
80104a9d:	e8 d5 08 00 00       	call   80105377 <acquire>
80104aa2:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104aac:	eb 7a                	jmp    80104b28 <mlfq_enqueue_all_runnable+0x9d>
    if (!kernel_pstat.inuse[i]) continue;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104ab8:	85 c0                	test   %eax,%eax
80104aba:	74 67                	je     80104b23 <mlfq_enqueue_all_runnable+0x98>
    struct proc *p = &ptable.proc[i];
80104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abf:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104ac2:	83 c0 30             	add    $0x30,%eax
80104ac5:	05 20 75 19 80       	add    $0x80197520,%eax
80104aca:	83 c0 04             	add    $0x4,%eax
80104acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE || p->state == RUNNING) {
80104ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad6:	83 f8 03             	cmp    $0x3,%eax
80104ad9:	74 0b                	je     80104ae6 <mlfq_enqueue_all_runnable+0x5b>
80104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ade:	8b 40 0c             	mov    0xc(%eax),%eax
80104ae1:	83 f8 04             	cmp    $0x4,%eax
80104ae4:	75 3e                	jne    80104b24 <mlfq_enqueue_all_runnable+0x99>
      int q = kernel_pstat.priority[i];
80104ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae9:	83 e8 80             	sub    $0xffffff80,%eax
80104aec:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
80104af6:	83 ec 08             	sub    $0x8,%esp
80104af9:	ff 75 ec             	push   -0x14(%ebp)
80104afc:	ff 75 f0             	push   -0x10(%ebp)
80104aff:	e8 ab 00 00 00       	call   80104baf <enqueue>
80104b04:	83 c4 10             	add    $0x10,%esp
      cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
80104b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b0a:	8b 40 10             	mov    0x10(%eax),%eax
80104b0d:	83 ec 04             	sub    $0x4,%esp
80104b10:	ff 75 ec             	push   -0x14(%ebp)
80104b13:	50                   	push   %eax
80104b14:	68 5d b3 10 80       	push   $0x8010b35d
80104b19:	e8 ee b8 ff ff       	call   8010040c <cprintf>
80104b1e:	83 c4 10             	add    $0x10,%esp
80104b21:	eb 01                	jmp    80104b24 <mlfq_enqueue_all_runnable+0x99>
    if (!kernel_pstat.inuse[i]) continue;
80104b23:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104b24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b28:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104b2c:	7e 80                	jle    80104aae <mlfq_enqueue_all_runnable+0x23>
    }
  }
  release(&ptable.lock);
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	68 20 75 19 80       	push   $0x80197520
80104b36:	e8 ae 08 00 00       	call   801053e9 <release>
80104b3b:	83 c4 10             	add    $0x10,%esp
}
80104b3e:	90                   	nop
80104b3f:	c9                   	leave
80104b40:	c3                   	ret

80104b41 <set_sched_policy>:

int
set_sched_policy(int policy)
{
80104b41:	f3 0f 1e fb          	endbr32
80104b45:	55                   	push   %ebp
80104b46:	89 e5                	mov    %esp,%ebp
80104b48:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104b4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b4f:	78 06                	js     80104b57 <set_sched_policy+0x16>
80104b51:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104b55:	7e 07                	jle    80104b5e <set_sched_policy+0x1d>
    return -1;
80104b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5c:	eb 28                	jmp    80104b86 <set_sched_policy+0x45>

  pushcli(); 
80104b5e:	e8 90 09 00 00       	call   801054f3 <pushcli>
  mycpu()->sched_policy = policy;
80104b63:	e8 c5 ef ff ff       	call   80103b2d <mycpu>
80104b68:	8b 55 08             	mov    0x8(%ebp),%edx
80104b6b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104b71:	e8 ce 09 00 00       	call   80105544 <popcli>

  if (policy > 0)
80104b76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b7a:	7e 05                	jle    80104b81 <set_sched_policy+0x40>
  mlfq_enqueue_all_runnable();
80104b7c:	e8 0a ff ff ff       	call   80104a8b <mlfq_enqueue_all_runnable>

  return 0;
80104b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b86:	c9                   	leave
80104b87:	c3                   	ret

80104b88 <get_sched_policy>:
int
get_sched_policy(void)
{
80104b88:	f3 0f 1e fb          	endbr32
80104b8c:	55                   	push   %ebp
80104b8d:	89 e5                	mov    %esp,%ebp
80104b8f:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
80104b92:	e8 5c 09 00 00       	call   801054f3 <pushcli>
  int policy = mycpu()->sched_policy;
80104b97:	e8 91 ef ff ff       	call   80103b2d <mycpu>
80104b9c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104ba5:	e8 9a 09 00 00       	call   80105544 <popcli>
  return policy;
80104baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bad:	c9                   	leave
80104bae:	c3                   	ret

80104baf <enqueue>:
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void
enqueue(struct proc *p, int level) {
80104baf:	f3 0f 1e fb          	endbr32
80104bb3:	55                   	push   %ebp
80104bb4:	89 e5                	mov    %esp,%ebp
80104bb6:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++)
80104bb9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bc0:	eb 1d                	jmp    80104bdf <enqueue+0x30>
    if (mlfq_queues[level][i] == p) return;
80104bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc5:	c1 e0 06             	shl    $0x6,%eax
80104bc8:	89 c2                	mov    %eax,%edx
80104bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bcd:	01 d0                	add    %edx,%eax
80104bcf:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104bd6:	39 45 08             	cmp    %eax,0x8(%ebp)
80104bd9:	74 50                	je     80104c2b <enqueue+0x7c>
  for (int i = 0; i < NPROC; i++)
80104bdb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bdf:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104be3:	7e dd                	jle    80104bc2 <enqueue+0x13>
  for (int i = 0; i < NPROC; i++)
80104be5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bec:	eb 35                	jmp    80104c23 <enqueue+0x74>
    if (mlfq_queues[level][i] == 0) {
80104bee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf1:	c1 e0 06             	shl    $0x6,%eax
80104bf4:	89 c2                	mov    %eax,%edx
80104bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bf9:	01 d0                	add    %edx,%eax
80104bfb:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c02:	85 c0                	test   %eax,%eax
80104c04:	75 19                	jne    80104c1f <enqueue+0x70>
      mlfq_queues[level][i] = p;
80104c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c09:	c1 e0 06             	shl    $0x6,%eax
80104c0c:	89 c2                	mov    %eax,%edx
80104c0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c11:	01 c2                	add    %eax,%edx
80104c13:	8b 45 08             	mov    0x8(%ebp),%eax
80104c16:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      return;
80104c1d:	eb 0d                	jmp    80104c2c <enqueue+0x7d>
  for (int i = 0; i < NPROC; i++)
80104c1f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c23:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104c27:	7e c5                	jle    80104bee <enqueue+0x3f>
80104c29:	eb 01                	jmp    80104c2c <enqueue+0x7d>
    if (mlfq_queues[level][i] == p) return;
80104c2b:	90                   	nop
    }
}
80104c2c:	c9                   	leave
80104c2d:	c3                   	ret

80104c2e <dequeue>:

struct proc*
dequeue(int level) {
80104c2e:	f3 0f 1e fb          	endbr32
80104c32:	55                   	push   %ebp
80104c33:	89 e5                	mov    %esp,%ebp
80104c35:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
80104c38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for (int i = 0; i < NPROC; i++) {
80104c3f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c46:	e9 81 00 00 00       	jmp    80104ccc <dequeue+0x9e>
    if (mlfq_queues[level][i]) {
80104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4e:	c1 e0 06             	shl    $0x6,%eax
80104c51:	89 c2                	mov    %eax,%edx
80104c53:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c56:	01 d0                	add    %edx,%eax
80104c58:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c5f:	85 c0                	test   %eax,%eax
80104c61:	74 65                	je     80104cc8 <dequeue+0x9a>
      p = mlfq_queues[level][i];
80104c63:	8b 45 08             	mov    0x8(%ebp),%eax
80104c66:	c1 e0 06             	shl    $0x6,%eax
80104c69:	89 c2                	mov    %eax,%edx
80104c6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c6e:	01 d0                	add    %edx,%eax
80104c70:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c77:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104c7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c80:	eb 2d                	jmp    80104caf <dequeue+0x81>
        mlfq_queues[level][j] = mlfq_queues[level][j+1];
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	8d 50 01             	lea    0x1(%eax),%edx
80104c88:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8b:	c1 e0 06             	shl    $0x6,%eax
80104c8e:	01 d0                	add    %edx,%eax
80104c90:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
80104c97:	8b 55 08             	mov    0x8(%ebp),%edx
80104c9a:	89 d1                	mov    %edx,%ecx
80104c9c:	c1 e1 06             	shl    $0x6,%ecx
80104c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ca2:	01 ca                	add    %ecx,%edx
80104ca4:	89 04 95 20 65 19 80 	mov    %eax,-0x7fe69ae0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104cab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104caf:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104cb3:	7e cd                	jle    80104c82 <dequeue+0x54>
      mlfq_queues[level][NPROC - 1] = 0;
80104cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb8:	c1 e0 08             	shl    $0x8,%eax
80104cbb:	05 1c 66 19 80       	add    $0x8019661c,%eax
80104cc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      break;
80104cc6:	eb 0e                	jmp    80104cd6 <dequeue+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104cc8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ccc:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104cd0:	0f 8e 75 ff ff ff    	jle    80104c4b <dequeue+0x1d>
    }
  }
  return p;
80104cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd9:	c9                   	leave
80104cda:	c3                   	ret

80104cdb <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104cdb:	f3 0f 1e fb          	endbr32
80104cdf:	55                   	push   %ebp
80104ce0:	89 e5                	mov    %esp,%ebp
80104ce2:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104ce5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cec:	e9 da 01 00 00       	jmp    80104ecb <apply_priority_boosting+0x1f0>
    if (!kernel_pstat.inuse[i]) continue;
80104cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf4:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104cfb:	85 c0                	test   %eax,%eax
80104cfd:	0f 84 c3 01 00 00    	je     80104ec6 <apply_priority_boosting+0x1eb>
    int q = kernel_pstat.priority[i];
80104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d06:	83 e8 80             	sub    $0xffffff80,%eax
80104d09:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d20:	01 d0                	add    %edx,%eax
80104d22:	05 00 02 00 00       	add    $0x200,%eax
80104d27:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 2 && waited >= 160) {
80104d31:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104d35:	75 70                	jne    80104da7 <apply_priority_boosting+0xcc>
80104d37:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104d3e:	7e 67                	jle    80104da7 <apply_priority_boosting+0xcc>
      kernel_pstat.priority[i] = 3;
80104d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d43:	83 e8 80             	sub    $0xffffff80,%eax
80104d46:	c7 04 85 20 69 19 80 	movl   $0x3,-0x7fe696e0(,%eax,4)
80104d4d:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d54:	c1 e0 04             	shl    $0x4,%eax
80104d57:	05 28 71 19 80       	add    $0x80197128,%eax
80104d5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d65:	83 c0 40             	add    $0x40,%eax
80104d68:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104d6f:	83 ec 04             	sub    $0x4,%esp
80104d72:	ff 75 ec             	push   -0x14(%ebp)
80104d75:	50                   	push   %eax
80104d76:	68 7c b3 10 80       	push   $0x8010b37c
80104d7b:	e8 8c b6 ff ff       	call   8010040c <cprintf>
80104d80:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d86:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104d89:	83 c0 30             	add    $0x30,%eax
80104d8c:	05 20 75 19 80       	add    $0x80197520,%eax
80104d91:	83 c0 04             	add    $0x4,%eax
80104d94:	83 ec 08             	sub    $0x8,%esp
80104d97:	6a 03                	push   $0x3
80104d99:	50                   	push   %eax
80104d9a:	e8 10 fe ff ff       	call   80104baf <enqueue>
80104d9f:	83 c4 10             	add    $0x10,%esp
80104da2:	e9 20 01 00 00       	jmp    80104ec7 <apply_priority_boosting+0x1ec>
    } else if (q == 1 && waited >= 320) {
80104da7:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104dab:	75 70                	jne    80104e1d <apply_priority_boosting+0x142>
80104dad:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104db4:	7e 67                	jle    80104e1d <apply_priority_boosting+0x142>
      kernel_pstat.priority[i] = 2;
80104db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db9:	83 e8 80             	sub    $0xffffff80,%eax
80104dbc:	c7 04 85 20 69 19 80 	movl   $0x2,-0x7fe696e0(,%eax,4)
80104dc3:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	c1 e0 04             	shl    $0x4,%eax
80104dcd:	05 24 71 19 80       	add    $0x80197124,%eax
80104dd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddb:	83 c0 40             	add    $0x40,%eax
80104dde:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104de5:	83 ec 04             	sub    $0x4,%esp
80104de8:	ff 75 ec             	push   -0x14(%ebp)
80104deb:	50                   	push   %eax
80104dec:	68 a0 b3 10 80       	push   $0x8010b3a0
80104df1:	e8 16 b6 ff ff       	call   8010040c <cprintf>
80104df6:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfc:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104dff:	83 c0 30             	add    $0x30,%eax
80104e02:	05 20 75 19 80       	add    $0x80197520,%eax
80104e07:	83 c0 04             	add    $0x4,%eax
80104e0a:	83 ec 08             	sub    $0x8,%esp
80104e0d:	6a 02                	push   $0x2
80104e0f:	50                   	push   %eax
80104e10:	e8 9a fd ff ff       	call   80104baf <enqueue>
80104e15:	83 c4 10             	add    $0x10,%esp
80104e18:	e9 aa 00 00 00       	jmp    80104ec7 <apply_priority_boosting+0x1ec>
    } else if (q == 0 && waited >= 500) {
80104e1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e21:	0f 85 a0 00 00 00    	jne    80104ec7 <apply_priority_boosting+0x1ec>
80104e27:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104e2e:	0f 8e 93 00 00 00    	jle    80104ec7 <apply_priority_boosting+0x1ec>
      int pid = kernel_pstat.pid[i];
80104e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e37:	83 c0 40             	add    $0x40,%eax
80104e3a:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104e41:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e47:	83 c0 40             	add    $0x40,%eax
80104e4a:	c1 e0 04             	shl    $0x4,%eax
80104e4d:	05 20 69 19 80       	add    $0x80196920,%eax
80104e52:	8b 00                	mov    (%eax),%eax
80104e54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5a:	83 e8 80             	sub    $0xffffff80,%eax
80104e5d:	c1 e0 04             	shl    $0x4,%eax
80104e60:	05 20 69 19 80       	add    $0x80196920,%eax
80104e65:	8b 00                	mov    (%eax),%eax
80104e67:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6d:	83 e8 80             	sub    $0xffffff80,%eax
80104e70:	c7 04 85 20 69 19 80 	movl   $0x1,-0x7fe696e0(,%eax,4)
80104e77:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7e:	83 e8 80             	sub    $0xffffff80,%eax
80104e81:	c1 e0 04             	shl    $0x4,%eax
80104e84:	05 20 69 19 80       	add    $0x80196920,%eax
80104e89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104e8f:	ff 75 e4             	push   -0x1c(%ebp)
80104e92:	ff 75 e0             	push   -0x20(%ebp)
80104e95:	ff 75 e8             	push   -0x18(%ebp)
80104e98:	68 c4 b3 10 80       	push   $0x8010b3c4
80104e9d:	e8 6a b5 ff ff       	call   8010040c <cprintf>
80104ea2:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea8:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104eab:	83 c0 30             	add    $0x30,%eax
80104eae:	05 20 75 19 80       	add    $0x80197520,%eax
80104eb3:	83 c0 04             	add    $0x4,%eax
80104eb6:	83 ec 08             	sub    $0x8,%esp
80104eb9:	6a 01                	push   $0x1
80104ebb:	50                   	push   %eax
80104ebc:	e8 ee fc ff ff       	call   80104baf <enqueue>
80104ec1:	83 c4 10             	add    $0x10,%esp
80104ec4:	eb 01                	jmp    80104ec7 <apply_priority_boosting+0x1ec>
    if (!kernel_pstat.inuse[i]) continue;
80104ec6:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104ec7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ecb:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104ecf:	0f 8e 1c fe ff ff    	jle    80104cf1 <apply_priority_boosting+0x16>
    }
  }
}
80104ed5:	90                   	nop
80104ed6:	90                   	nop
80104ed7:	c9                   	leave
80104ed8:	c3                   	ret

80104ed9 <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104ed9:	f3 0f 1e fb          	endbr32
80104edd:	55                   	push   %ebp
80104ede:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104ee0:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104ee4:	75 07                	jne    80104eed <get_time_slice+0x14>
80104ee6:	b8 08 00 00 00       	mov    $0x8,%eax
80104eeb:	eb 1f                	jmp    80104f0c <get_time_slice+0x33>
  if (level == 2) return 16;
80104eed:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104ef1:	75 07                	jne    80104efa <get_time_slice+0x21>
80104ef3:	b8 10 00 00 00       	mov    $0x10,%eax
80104ef8:	eb 12                	jmp    80104f0c <get_time_slice+0x33>
  if (level == 1) return 32;
80104efa:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104efe:	75 07                	jne    80104f07 <get_time_slice+0x2e>
80104f00:	b8 20 00 00 00       	mov    $0x20,%eax
80104f05:	eb 05                	jmp    80104f0c <get_time_slice+0x33>
  return -1; // FIFO (Q0)
80104f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f0c:	5d                   	pop    %ebp
80104f0d:	c3                   	ret

80104f0e <run_process>:

void
run_process(struct proc* p, int q, int slice, int tracking) {
80104f0e:	f3 0f 1e fb          	endbr32
80104f12:	55                   	push   %ebp
80104f13:	89 e5                	mov    %esp,%ebp
80104f15:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104f18:	e8 10 ec ff ff       	call   80103b2d <mycpu>
80104f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f23:	8b 55 08             	mov    0x8(%ebp),%edx
80104f26:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104f2c:	83 ec 0c             	sub    $0xc,%esp
80104f2f:	ff 75 08             	push   0x8(%ebp)
80104f32:	e8 77 33 00 00       	call   801082ae <switchuvm>
80104f37:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
  int i = p - ptable.proc;
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	2d 54 75 19 80       	sub    $0x80197554,%eax
80104f4c:	c1 f8 02             	sar    $0x2,%eax
80104f4f:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104f55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
  swtch(&(c->scheduler), p->context);
80104f58:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f61:	83 c2 04             	add    $0x4,%edx
80104f64:	83 ec 08             	sub    $0x8,%esp
80104f67:	50                   	push   %eax
80104f68:	52                   	push   %edx
80104f69:	e8 2c 09 00 00       	call   8010589a <swtch>
80104f6e:	83 c4 10             	add    $0x10,%esp
  switchkvm();
80104f71:	e8 1b 33 00 00       	call   80108291 <switchkvm>
  c->proc = 0;
80104f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f79:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104f80:	00 00 00 
  if (tracking) kernel_pstat.ticks[i][q]++;
80104f83:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80104f87:	74 39                	je     80104fc2 <run_process+0xb4>
80104f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f93:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f96:	01 d0                	add    %edx,%eax
80104f98:	05 00 01 00 00       	add    $0x100,%eax
80104f9d:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104fa4:	8d 50 01             	lea    0x1(%eax),%edx
80104fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faa:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb4:	01 c8                	add    %ecx,%eax
80104fb6:	05 00 01 00 00       	add    $0x100,%eax
80104fbb:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
  if (slice != -1 && kernel_pstat.ticks[i][q] >= slice && q > 0) {
80104fc2:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104fc6:	0f 84 8d 00 00 00    	je     80105059 <run_process+0x14b>
80104fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd9:	01 d0                	add    %edx,%eax
80104fdb:	05 00 01 00 00       	add    $0x100,%eax
80104fe0:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80104fe7:	39 45 10             	cmp    %eax,0x10(%ebp)
80104fea:	7f 6d                	jg     80105059 <run_process+0x14b>
80104fec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ff0:	7e 67                	jle    80105059 <run_process+0x14b>
    kernel_pstat.priority[i] = q - 1;
80104ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffb:	83 e8 80             	sub    $0xffffff80,%eax
80104ffe:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;
80105005:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105008:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010500f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105012:	01 d0                	add    %edx,%eax
80105014:	05 00 01 00 00       	add    $0x100,%eax
80105019:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80105020:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80105024:	8b 45 0c             	mov    0xc(%ebp),%eax
80105027:	8d 50 ff             	lea    -0x1(%eax),%edx
8010502a:	8b 45 08             	mov    0x8(%ebp),%eax
8010502d:	8b 40 10             	mov    0x10(%eax),%eax
80105030:	52                   	push   %edx
80105031:	ff 75 0c             	push   0xc(%ebp)
80105034:	50                   	push   %eax
80105035:	68 f2 b3 10 80       	push   $0x8010b3f2
8010503a:	e8 cd b3 ff ff       	call   8010040c <cprintf>
8010503f:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
80105042:	8b 45 0c             	mov    0xc(%ebp),%eax
80105045:	83 e8 01             	sub    $0x1,%eax
80105048:	83 ec 08             	sub    $0x8,%esp
8010504b:	50                   	push   %eax
8010504c:	ff 75 08             	push   0x8(%ebp)
8010504f:	e8 5b fb ff ff       	call   80104baf <enqueue>
80105054:	83 c4 10             	add    $0x10,%esp
  //cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
  } else {
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
80105057:	eb 31                	jmp    8010508a <run_process+0x17c>
  } else if (q == 0) {
80105059:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010505d:	74 2b                	je     8010508a <run_process+0x17c>
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
8010505f:	8b 45 08             	mov    0x8(%ebp),%eax
80105062:	8b 40 10             	mov    0x10(%eax),%eax
80105065:	83 ec 04             	sub    $0x4,%esp
80105068:	ff 75 0c             	push   0xc(%ebp)
8010506b:	50                   	push   %eax
8010506c:	68 10 b4 10 80       	push   $0x8010b410
80105071:	e8 96 b3 ff ff       	call   8010040c <cprintf>
80105076:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
80105079:	83 ec 08             	sub    $0x8,%esp
8010507c:	ff 75 0c             	push   0xc(%ebp)
8010507f:	ff 75 08             	push   0x8(%ebp)
80105082:	e8 28 fb ff ff       	call   80104baf <enqueue>
80105087:	83 c4 10             	add    $0x10,%esp
}
8010508a:	90                   	nop
8010508b:	c9                   	leave
8010508c:	c3                   	ret

8010508d <run_mlfq>:

// MLFQ 스케줄러 진입점
void
run_mlfq(int tracking, int boosting) {
8010508d:	f3 0f 1e fb          	endbr32
80105091:	55                   	push   %ebp
80105092:	89 e5                	mov    %esp,%ebp
80105094:	83 ec 28             	sub    $0x28,%esp
  if (boosting)
80105097:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010509b:	74 05                	je     801050a2 <run_mlfq+0x15>
    apply_priority_boosting();
8010509d:	e8 39 fc ff ff       	call   80104cdb <apply_priority_boosting>

  for (int q = 3; q >= 0; q--) {
801050a2:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
801050a9:	eb 7c                	jmp    80105127 <run_mlfq+0x9a>
    for (int i = 0; i < NPROC; i++) {
801050ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050b2:	eb 69                	jmp    8010511d <run_mlfq+0x90>
      struct proc *p = mlfq_queues[q][i];
801050b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b7:	c1 e0 06             	shl    $0x6,%eax
801050ba:	89 c2                	mov    %eax,%edx
801050bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bf:	01 d0                	add    %edx,%eax
801050c1:	8b 04 85 20 65 19 80 	mov    -0x7fe69ae0(,%eax,4),%eax
801050c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (p == 0 || p->state != RUNNABLE)
801050cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801050cf:	74 0b                	je     801050dc <run_mlfq+0x4f>
801050d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801050d4:	8b 40 0c             	mov    0xc(%eax),%eax
801050d7:	83 f8 03             	cmp    $0x3,%eax
801050da:	74 06                	je     801050e2 <run_mlfq+0x55>
    for (int i = 0; i < NPROC; i++) {
801050dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050e0:	eb 3b                	jmp    8010511d <run_mlfq+0x90>
        continue;
      if (q != 0)
801050e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050e6:	74 0e                	je     801050f6 <run_mlfq+0x69>
        dequeue(q);
801050e8:	83 ec 0c             	sub    $0xc,%esp
801050eb:	ff 75 f4             	push   -0xc(%ebp)
801050ee:	e8 3b fb ff ff       	call   80104c2e <dequeue>
801050f3:	83 c4 10             	add    $0x10,%esp
      int slice = get_time_slice(q);
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	ff 75 f4             	push   -0xc(%ebp)
801050fc:	e8 d8 fd ff ff       	call   80104ed9 <get_time_slice>
80105101:	83 c4 10             	add    $0x10,%esp
80105104:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice, tracking);
80105107:	ff 75 08             	push   0x8(%ebp)
8010510a:	ff 75 e4             	push   -0x1c(%ebp)
8010510d:	ff 75 f4             	push   -0xc(%ebp)
80105110:	ff 75 e8             	push   -0x18(%ebp)
80105113:	e8 f6 fd ff ff       	call   80104f0e <run_process>
80105118:	83 c4 10             	add    $0x10,%esp
      goto tick_update;
8010511b:	eb 15                	jmp    80105132 <run_mlfq+0xa5>
    for (int i = 0; i < NPROC; i++) {
8010511d:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80105121:	7e 91                	jle    801050b4 <run_mlfq+0x27>
  for (int q = 3; q >= 0; q--) {
80105123:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80105127:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010512b:	0f 89 7a ff ff ff    	jns    801050ab <run_mlfq+0x1e>
    }
  }

tick_update:
80105131:	90                   	nop
  if (!tracking) return;
80105132:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105136:	0f 84 a5 00 00 00    	je     801051e1 <run_mlfq+0x154>
  for (int i = 0; i < NPROC; i++) {
8010513c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105143:	e9 8d 00 00 00       	jmp    801051d5 <run_mlfq+0x148>
    struct proc* p = &ptable.proc[i];
80105148:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010514b:	6b c0 7c             	imul   $0x7c,%eax,%eax
8010514e:	83 c0 30             	add    $0x30,%eax
80105151:	05 20 75 19 80       	add    $0x80197520,%eax
80105156:	83 c0 04             	add    $0x4,%eax
80105159:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
8010515c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010515f:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105166:	85 c0                	test   %eax,%eax
80105168:	74 66                	je     801051d0 <run_mlfq+0x143>
    if (p->state == RUNNABLE && p != mycpu()->proc) {
8010516a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010516d:	8b 40 0c             	mov    0xc(%eax),%eax
80105170:	83 f8 03             	cmp    $0x3,%eax
80105173:	75 5c                	jne    801051d1 <run_mlfq+0x144>
80105175:	e8 b3 e9 ff ff       	call   80103b2d <mycpu>
8010517a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105180:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80105183:	74 4c                	je     801051d1 <run_mlfq+0x144>
      int q = kernel_pstat.priority[i];
80105185:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105188:	83 e8 80             	sub    $0xffffff80,%eax
8010518b:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80105192:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
80105195:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010519f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801051a2:	01 d0                	add    %edx,%eax
801051a4:	05 00 02 00 00       	add    $0x200,%eax
801051a9:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
801051b0:	8d 50 01             	lea    0x1(%eax),%edx
801051b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051b6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801051bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801051c0:	01 c8                	add    %ecx,%eax
801051c2:	05 00 02 00 00       	add    $0x200,%eax
801051c7:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
801051ce:	eb 01                	jmp    801051d1 <run_mlfq+0x144>
    if (!kernel_pstat.inuse[i]) continue;
801051d0:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
801051d1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801051d5:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
801051d9:	0f 8e 69 ff ff ff    	jle    80105148 <run_mlfq+0xbb>
801051df:	eb 01                	jmp    801051e2 <run_mlfq+0x155>
  if (!tracking) return;
801051e1:	90                   	nop
    }
  }
801051e2:	c9                   	leave
801051e3:	c3                   	ret

801051e4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801051e4:	f3 0f 1e fb          	endbr32
801051e8:	55                   	push   %ebp
801051e9:	89 e5                	mov    %esp,%ebp
801051eb:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	83 c0 04             	add    $0x4,%eax
801051f4:	83 ec 08             	sub    $0x8,%esp
801051f7:	68 5c b4 10 80       	push   $0x8010b45c
801051fc:	50                   	push   %eax
801051fd:	e8 4f 01 00 00       	call   80105351 <initlock>
80105202:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105205:	8b 45 08             	mov    0x8(%ebp),%eax
80105208:	8b 55 0c             	mov    0xc(%ebp),%edx
8010520b:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010520e:	8b 45 08             	mov    0x8(%ebp),%eax
80105211:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105217:	8b 45 08             	mov    0x8(%ebp),%eax
8010521a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105221:	90                   	nop
80105222:	c9                   	leave
80105223:	c3                   	ret

80105224 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105224:	f3 0f 1e fb          	endbr32
80105228:	55                   	push   %ebp
80105229:	89 e5                	mov    %esp,%ebp
8010522b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010522e:	8b 45 08             	mov    0x8(%ebp),%eax
80105231:	83 c0 04             	add    $0x4,%eax
80105234:	83 ec 0c             	sub    $0xc,%esp
80105237:	50                   	push   %eax
80105238:	e8 3a 01 00 00       	call   80105377 <acquire>
8010523d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105240:	eb 15                	jmp    80105257 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105242:	8b 45 08             	mov    0x8(%ebp),%eax
80105245:	83 c0 04             	add    $0x4,%eax
80105248:	83 ec 08             	sub    $0x8,%esp
8010524b:	50                   	push   %eax
8010524c:	ff 75 08             	push   0x8(%ebp)
8010524f:	e8 56 f4 ff ff       	call   801046aa <sleep>
80105254:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105257:	8b 45 08             	mov    0x8(%ebp),%eax
8010525a:	8b 00                	mov    (%eax),%eax
8010525c:	85 c0                	test   %eax,%eax
8010525e:	75 e2                	jne    80105242 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105260:	8b 45 08             	mov    0x8(%ebp),%eax
80105263:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105269:	e8 3b e9 ff ff       	call   80103ba9 <myproc>
8010526e:	8b 50 10             	mov    0x10(%eax),%edx
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105277:	8b 45 08             	mov    0x8(%ebp),%eax
8010527a:	83 c0 04             	add    $0x4,%eax
8010527d:	83 ec 0c             	sub    $0xc,%esp
80105280:	50                   	push   %eax
80105281:	e8 63 01 00 00       	call   801053e9 <release>
80105286:	83 c4 10             	add    $0x10,%esp
}
80105289:	90                   	nop
8010528a:	c9                   	leave
8010528b:	c3                   	ret

8010528c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010528c:	f3 0f 1e fb          	endbr32
80105290:	55                   	push   %ebp
80105291:	89 e5                	mov    %esp,%ebp
80105293:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105296:	8b 45 08             	mov    0x8(%ebp),%eax
80105299:	83 c0 04             	add    $0x4,%eax
8010529c:	83 ec 0c             	sub    $0xc,%esp
8010529f:	50                   	push   %eax
801052a0:	e8 d2 00 00 00       	call   80105377 <acquire>
801052a5:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
801052ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801052b1:	8b 45 08             	mov    0x8(%ebp),%eax
801052b4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801052bb:	83 ec 0c             	sub    $0xc,%esp
801052be:	ff 75 08             	push   0x8(%ebp)
801052c1:	e8 d3 f4 ff ff       	call   80104799 <wakeup>
801052c6:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	83 c0 04             	add    $0x4,%eax
801052cf:	83 ec 0c             	sub    $0xc,%esp
801052d2:	50                   	push   %eax
801052d3:	e8 11 01 00 00       	call   801053e9 <release>
801052d8:	83 c4 10             	add    $0x10,%esp
}
801052db:	90                   	nop
801052dc:	c9                   	leave
801052dd:	c3                   	ret

801052de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801052de:	f3 0f 1e fb          	endbr32
801052e2:	55                   	push   %ebp
801052e3:	89 e5                	mov    %esp,%ebp
801052e5:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801052e8:	8b 45 08             	mov    0x8(%ebp),%eax
801052eb:	83 c0 04             	add    $0x4,%eax
801052ee:	83 ec 0c             	sub    $0xc,%esp
801052f1:	50                   	push   %eax
801052f2:	e8 80 00 00 00       	call   80105377 <acquire>
801052f7:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801052fa:	8b 45 08             	mov    0x8(%ebp),%eax
801052fd:	8b 00                	mov    (%eax),%eax
801052ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105302:	8b 45 08             	mov    0x8(%ebp),%eax
80105305:	83 c0 04             	add    $0x4,%eax
80105308:	83 ec 0c             	sub    $0xc,%esp
8010530b:	50                   	push   %eax
8010530c:	e8 d8 00 00 00       	call   801053e9 <release>
80105311:	83 c4 10             	add    $0x10,%esp
  return r;
80105314:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105317:	c9                   	leave
80105318:	c3                   	ret

80105319 <readeflags>:
{
80105319:	55                   	push   %ebp
8010531a:	89 e5                	mov    %esp,%ebp
8010531c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010531f:	9c                   	pushf
80105320:	58                   	pop    %eax
80105321:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105324:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105327:	c9                   	leave
80105328:	c3                   	ret

80105329 <cli>:
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010532c:	fa                   	cli
}
8010532d:	90                   	nop
8010532e:	5d                   	pop    %ebp
8010532f:	c3                   	ret

80105330 <sti>:
{
80105330:	55                   	push   %ebp
80105331:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105333:	fb                   	sti
}
80105334:	90                   	nop
80105335:	5d                   	pop    %ebp
80105336:	c3                   	ret

80105337 <xchg>:
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010533d:	8b 55 08             	mov    0x8(%ebp),%edx
80105340:	8b 45 0c             	mov    0xc(%ebp),%eax
80105343:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105346:	f0 87 02             	lock xchg %eax,(%edx)
80105349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010534c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010534f:	c9                   	leave
80105350:	c3                   	ret

80105351 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105351:	f3 0f 1e fb          	endbr32
80105355:	55                   	push   %ebp
80105356:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105358:	8b 45 08             	mov    0x8(%ebp),%eax
8010535b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010535e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105361:	8b 45 08             	mov    0x8(%ebp),%eax
80105364:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
8010536d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105374:	90                   	nop
80105375:	5d                   	pop    %ebp
80105376:	c3                   	ret

80105377 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105377:	f3 0f 1e fb          	endbr32
8010537b:	55                   	push   %ebp
8010537c:	89 e5                	mov    %esp,%ebp
8010537e:	53                   	push   %ebx
8010537f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105382:	e8 6c 01 00 00       	call   801054f3 <pushcli>
  if(holding(lk)){
80105387:	8b 45 08             	mov    0x8(%ebp),%eax
8010538a:	83 ec 0c             	sub    $0xc,%esp
8010538d:	50                   	push   %eax
8010538e:	e8 2b 01 00 00       	call   801054be <holding>
80105393:	83 c4 10             	add    $0x10,%esp
80105396:	85 c0                	test   %eax,%eax
80105398:	74 0d                	je     801053a7 <acquire+0x30>
    panic("acquire");
8010539a:	83 ec 0c             	sub    $0xc,%esp
8010539d:	68 67 b4 10 80       	push   $0x8010b467
801053a2:	e8 1e b2 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801053a7:	90                   	nop
801053a8:	8b 45 08             	mov    0x8(%ebp),%eax
801053ab:	83 ec 08             	sub    $0x8,%esp
801053ae:	6a 01                	push   $0x1
801053b0:	50                   	push   %eax
801053b1:	e8 81 ff ff ff       	call   80105337 <xchg>
801053b6:	83 c4 10             	add    $0x10,%esp
801053b9:	85 c0                	test   %eax,%eax
801053bb:	75 eb                	jne    801053a8 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801053bd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801053c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
801053c5:	e8 63 e7 ff ff       	call   80103b2d <mycpu>
801053ca:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801053cd:	8b 45 08             	mov    0x8(%ebp),%eax
801053d0:	83 c0 0c             	add    $0xc,%eax
801053d3:	83 ec 08             	sub    $0x8,%esp
801053d6:	50                   	push   %eax
801053d7:	8d 45 08             	lea    0x8(%ebp),%eax
801053da:	50                   	push   %eax
801053db:	e8 5f 00 00 00       	call   8010543f <getcallerpcs>
801053e0:	83 c4 10             	add    $0x10,%esp
}
801053e3:	90                   	nop
801053e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053e7:	c9                   	leave
801053e8:	c3                   	ret

801053e9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053e9:	f3 0f 1e fb          	endbr32
801053ed:	55                   	push   %ebp
801053ee:	89 e5                	mov    %esp,%ebp
801053f0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801053f3:	83 ec 0c             	sub    $0xc,%esp
801053f6:	ff 75 08             	push   0x8(%ebp)
801053f9:	e8 c0 00 00 00       	call   801054be <holding>
801053fe:	83 c4 10             	add    $0x10,%esp
80105401:	85 c0                	test   %eax,%eax
80105403:	75 0d                	jne    80105412 <release+0x29>
    panic("release");
80105405:	83 ec 0c             	sub    $0xc,%esp
80105408:	68 6f b4 10 80       	push   $0x8010b46f
8010540d:	e8 b3 b1 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80105412:	8b 45 08             	mov    0x8(%ebp),%eax
80105415:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010541c:	8b 45 08             	mov    0x8(%ebp),%eax
8010541f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105426:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010542b:	8b 45 08             	mov    0x8(%ebp),%eax
8010542e:	8b 55 08             	mov    0x8(%ebp),%edx
80105431:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105437:	e8 08 01 00 00       	call   80105544 <popcli>
}
8010543c:	90                   	nop
8010543d:	c9                   	leave
8010543e:	c3                   	ret

8010543f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010543f:	f3 0f 1e fb          	endbr32
80105443:	55                   	push   %ebp
80105444:	89 e5                	mov    %esp,%ebp
80105446:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105449:	8b 45 08             	mov    0x8(%ebp),%eax
8010544c:	83 e8 08             	sub    $0x8,%eax
8010544f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105452:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105459:	eb 38                	jmp    80105493 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010545b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010545f:	74 53                	je     801054b4 <getcallerpcs+0x75>
80105461:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105468:	76 4a                	jbe    801054b4 <getcallerpcs+0x75>
8010546a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010546e:	74 44                	je     801054b4 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105470:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105473:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010547a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547d:	01 c2                	add    %eax,%edx
8010547f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105482:	8b 40 04             	mov    0x4(%eax),%eax
80105485:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105487:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548a:	8b 00                	mov    (%eax),%eax
8010548c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010548f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105493:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105497:	7e c2                	jle    8010545b <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105499:	eb 19                	jmp    801054b4 <getcallerpcs+0x75>
    pcs[i] = 0;
8010549b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010549e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a8:	01 d0                	add    %edx,%eax
801054aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801054b0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054b4:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054b8:	7e e1                	jle    8010549b <getcallerpcs+0x5c>
}
801054ba:	90                   	nop
801054bb:	90                   	nop
801054bc:	c9                   	leave
801054bd:	c3                   	ret

801054be <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054be:	f3 0f 1e fb          	endbr32
801054c2:	55                   	push   %ebp
801054c3:	89 e5                	mov    %esp,%ebp
801054c5:	53                   	push   %ebx
801054c6:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801054c9:	8b 45 08             	mov    0x8(%ebp),%eax
801054cc:	8b 00                	mov    (%eax),%eax
801054ce:	85 c0                	test   %eax,%eax
801054d0:	74 16                	je     801054e8 <holding+0x2a>
801054d2:	8b 45 08             	mov    0x8(%ebp),%eax
801054d5:	8b 58 08             	mov    0x8(%eax),%ebx
801054d8:	e8 50 e6 ff ff       	call   80103b2d <mycpu>
801054dd:	39 c3                	cmp    %eax,%ebx
801054df:	75 07                	jne    801054e8 <holding+0x2a>
801054e1:	b8 01 00 00 00       	mov    $0x1,%eax
801054e6:	eb 05                	jmp    801054ed <holding+0x2f>
801054e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054ed:	83 c4 04             	add    $0x4,%esp
801054f0:	5b                   	pop    %ebx
801054f1:	5d                   	pop    %ebp
801054f2:	c3                   	ret

801054f3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054f3:	f3 0f 1e fb          	endbr32
801054f7:	55                   	push   %ebp
801054f8:	89 e5                	mov    %esp,%ebp
801054fa:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801054fd:	e8 17 fe ff ff       	call   80105319 <readeflags>
80105502:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105505:	e8 1f fe ff ff       	call   80105329 <cli>
  if(mycpu()->ncli == 0)
8010550a:	e8 1e e6 ff ff       	call   80103b2d <mycpu>
8010550f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105515:	85 c0                	test   %eax,%eax
80105517:	75 14                	jne    8010552d <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105519:	e8 0f e6 ff ff       	call   80103b2d <mycpu>
8010551e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105521:	81 e2 00 02 00 00    	and    $0x200,%edx
80105527:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010552d:	e8 fb e5 ff ff       	call   80103b2d <mycpu>
80105532:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105538:	83 c2 01             	add    $0x1,%edx
8010553b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105541:	90                   	nop
80105542:	c9                   	leave
80105543:	c3                   	ret

80105544 <popcli>:

void
popcli(void)
{
80105544:	f3 0f 1e fb          	endbr32
80105548:	55                   	push   %ebp
80105549:	89 e5                	mov    %esp,%ebp
8010554b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010554e:	e8 c6 fd ff ff       	call   80105319 <readeflags>
80105553:	25 00 02 00 00       	and    $0x200,%eax
80105558:	85 c0                	test   %eax,%eax
8010555a:	74 0d                	je     80105569 <popcli+0x25>
    panic("popcli - interruptible");
8010555c:	83 ec 0c             	sub    $0xc,%esp
8010555f:	68 77 b4 10 80       	push   $0x8010b477
80105564:	e8 5c b0 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80105569:	e8 bf e5 ff ff       	call   80103b2d <mycpu>
8010556e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105574:	83 ea 01             	sub    $0x1,%edx
80105577:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010557d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105583:	85 c0                	test   %eax,%eax
80105585:	79 0d                	jns    80105594 <popcli+0x50>
    panic("popcli");
80105587:	83 ec 0c             	sub    $0xc,%esp
8010558a:	68 8e b4 10 80       	push   $0x8010b48e
8010558f:	e8 31 b0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105594:	e8 94 e5 ff ff       	call   80103b2d <mycpu>
80105599:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010559f:	85 c0                	test   %eax,%eax
801055a1:	75 14                	jne    801055b7 <popcli+0x73>
801055a3:	e8 85 e5 ff ff       	call   80103b2d <mycpu>
801055a8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801055ae:	85 c0                	test   %eax,%eax
801055b0:	74 05                	je     801055b7 <popcli+0x73>
    sti();
801055b2:	e8 79 fd ff ff       	call   80105330 <sti>
}
801055b7:	90                   	nop
801055b8:	c9                   	leave
801055b9:	c3                   	ret

801055ba <stosb>:
{
801055ba:	55                   	push   %ebp
801055bb:	89 e5                	mov    %esp,%ebp
801055bd:	57                   	push   %edi
801055be:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055c2:	8b 55 10             	mov    0x10(%ebp),%edx
801055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c8:	89 cb                	mov    %ecx,%ebx
801055ca:	89 df                	mov    %ebx,%edi
801055cc:	89 d1                	mov    %edx,%ecx
801055ce:	fc                   	cld
801055cf:	f3 aa                	rep stos %al,%es:(%edi)
801055d1:	89 ca                	mov    %ecx,%edx
801055d3:	89 fb                	mov    %edi,%ebx
801055d5:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055d8:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055db:	90                   	nop
801055dc:	5b                   	pop    %ebx
801055dd:	5f                   	pop    %edi
801055de:	5d                   	pop    %ebp
801055df:	c3                   	ret

801055e0 <stosl>:
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	57                   	push   %edi
801055e4:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055e8:	8b 55 10             	mov    0x10(%ebp),%edx
801055eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ee:	89 cb                	mov    %ecx,%ebx
801055f0:	89 df                	mov    %ebx,%edi
801055f2:	89 d1                	mov    %edx,%ecx
801055f4:	fc                   	cld
801055f5:	f3 ab                	rep stos %eax,%es:(%edi)
801055f7:	89 ca                	mov    %ecx,%edx
801055f9:	89 fb                	mov    %edi,%ebx
801055fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055fe:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105601:	90                   	nop
80105602:	5b                   	pop    %ebx
80105603:	5f                   	pop    %edi
80105604:	5d                   	pop    %ebp
80105605:	c3                   	ret

80105606 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105606:	f3 0f 1e fb          	endbr32
8010560a:	55                   	push   %ebp
8010560b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010560d:	8b 45 08             	mov    0x8(%ebp),%eax
80105610:	83 e0 03             	and    $0x3,%eax
80105613:	85 c0                	test   %eax,%eax
80105615:	75 43                	jne    8010565a <memset+0x54>
80105617:	8b 45 10             	mov    0x10(%ebp),%eax
8010561a:	83 e0 03             	and    $0x3,%eax
8010561d:	85 c0                	test   %eax,%eax
8010561f:	75 39                	jne    8010565a <memset+0x54>
    c &= 0xFF;
80105621:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105628:	8b 45 10             	mov    0x10(%ebp),%eax
8010562b:	c1 e8 02             	shr    $0x2,%eax
8010562e:	89 c1                	mov    %eax,%ecx
80105630:	8b 45 0c             	mov    0xc(%ebp),%eax
80105633:	c1 e0 18             	shl    $0x18,%eax
80105636:	89 c2                	mov    %eax,%edx
80105638:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563b:	c1 e0 10             	shl    $0x10,%eax
8010563e:	09 c2                	or     %eax,%edx
80105640:	8b 45 0c             	mov    0xc(%ebp),%eax
80105643:	c1 e0 08             	shl    $0x8,%eax
80105646:	09 d0                	or     %edx,%eax
80105648:	0b 45 0c             	or     0xc(%ebp),%eax
8010564b:	51                   	push   %ecx
8010564c:	50                   	push   %eax
8010564d:	ff 75 08             	push   0x8(%ebp)
80105650:	e8 8b ff ff ff       	call   801055e0 <stosl>
80105655:	83 c4 0c             	add    $0xc,%esp
80105658:	eb 12                	jmp    8010566c <memset+0x66>
  } else
    stosb(dst, c, n);
8010565a:	8b 45 10             	mov    0x10(%ebp),%eax
8010565d:	50                   	push   %eax
8010565e:	ff 75 0c             	push   0xc(%ebp)
80105661:	ff 75 08             	push   0x8(%ebp)
80105664:	e8 51 ff ff ff       	call   801055ba <stosb>
80105669:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010566c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010566f:	c9                   	leave
80105670:	c3                   	ret

80105671 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105671:	f3 0f 1e fb          	endbr32
80105675:	55                   	push   %ebp
80105676:	89 e5                	mov    %esp,%ebp
80105678:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010567b:	8b 45 08             	mov    0x8(%ebp),%eax
8010567e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105681:	8b 45 0c             	mov    0xc(%ebp),%eax
80105684:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105687:	eb 30                	jmp    801056b9 <memcmp+0x48>
    if(*s1 != *s2)
80105689:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568c:	0f b6 10             	movzbl (%eax),%edx
8010568f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105692:	0f b6 00             	movzbl (%eax),%eax
80105695:	38 c2                	cmp    %al,%dl
80105697:	74 18                	je     801056b1 <memcmp+0x40>
      return *s1 - *s2;
80105699:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569c:	0f b6 00             	movzbl (%eax),%eax
8010569f:	0f b6 d0             	movzbl %al,%edx
801056a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a5:	0f b6 00             	movzbl (%eax),%eax
801056a8:	0f b6 c0             	movzbl %al,%eax
801056ab:	29 c2                	sub    %eax,%edx
801056ad:	89 d0                	mov    %edx,%eax
801056af:	eb 1a                	jmp    801056cb <memcmp+0x5a>
    s1++, s2++;
801056b1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056b5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801056b9:	8b 45 10             	mov    0x10(%ebp),%eax
801056bc:	8d 50 ff             	lea    -0x1(%eax),%edx
801056bf:	89 55 10             	mov    %edx,0x10(%ebp)
801056c2:	85 c0                	test   %eax,%eax
801056c4:	75 c3                	jne    80105689 <memcmp+0x18>
  }

  return 0;
801056c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056cb:	c9                   	leave
801056cc:	c3                   	ret

801056cd <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056cd:	f3 0f 1e fb          	endbr32
801056d1:	55                   	push   %ebp
801056d2:	89 e5                	mov    %esp,%ebp
801056d4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056dd:	8b 45 08             	mov    0x8(%ebp),%eax
801056e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056e9:	73 54                	jae    8010573f <memmove+0x72>
801056eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056ee:	8b 45 10             	mov    0x10(%ebp),%eax
801056f1:	01 d0                	add    %edx,%eax
801056f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801056f6:	73 47                	jae    8010573f <memmove+0x72>
    s += n;
801056f8:	8b 45 10             	mov    0x10(%ebp),%eax
801056fb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105701:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105704:	eb 13                	jmp    80105719 <memmove+0x4c>
      *--d = *--s;
80105706:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010570a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010570e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105711:	0f b6 10             	movzbl (%eax),%edx
80105714:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105717:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105719:	8b 45 10             	mov    0x10(%ebp),%eax
8010571c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010571f:	89 55 10             	mov    %edx,0x10(%ebp)
80105722:	85 c0                	test   %eax,%eax
80105724:	75 e0                	jne    80105706 <memmove+0x39>
  if(s < d && s + n > d){
80105726:	eb 24                	jmp    8010574c <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105728:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010572b:	8d 42 01             	lea    0x1(%edx),%eax
8010572e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105731:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105734:	8d 48 01             	lea    0x1(%eax),%ecx
80105737:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010573a:	0f b6 12             	movzbl (%edx),%edx
8010573d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010573f:	8b 45 10             	mov    0x10(%ebp),%eax
80105742:	8d 50 ff             	lea    -0x1(%eax),%edx
80105745:	89 55 10             	mov    %edx,0x10(%ebp)
80105748:	85 c0                	test   %eax,%eax
8010574a:	75 dc                	jne    80105728 <memmove+0x5b>

  return dst;
8010574c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010574f:	c9                   	leave
80105750:	c3                   	ret

80105751 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105751:	f3 0f 1e fb          	endbr32
80105755:	55                   	push   %ebp
80105756:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105758:	ff 75 10             	push   0x10(%ebp)
8010575b:	ff 75 0c             	push   0xc(%ebp)
8010575e:	ff 75 08             	push   0x8(%ebp)
80105761:	e8 67 ff ff ff       	call   801056cd <memmove>
80105766:	83 c4 0c             	add    $0xc,%esp
}
80105769:	c9                   	leave
8010576a:	c3                   	ret

8010576b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010576b:	f3 0f 1e fb          	endbr32
8010576f:	55                   	push   %ebp
80105770:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105772:	eb 0c                	jmp    80105780 <strncmp+0x15>
    n--, p++, q++;
80105774:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105778:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010577c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105780:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105784:	74 1a                	je     801057a0 <strncmp+0x35>
80105786:	8b 45 08             	mov    0x8(%ebp),%eax
80105789:	0f b6 00             	movzbl (%eax),%eax
8010578c:	84 c0                	test   %al,%al
8010578e:	74 10                	je     801057a0 <strncmp+0x35>
80105790:	8b 45 08             	mov    0x8(%ebp),%eax
80105793:	0f b6 10             	movzbl (%eax),%edx
80105796:	8b 45 0c             	mov    0xc(%ebp),%eax
80105799:	0f b6 00             	movzbl (%eax),%eax
8010579c:	38 c2                	cmp    %al,%dl
8010579e:	74 d4                	je     80105774 <strncmp+0x9>
  if(n == 0)
801057a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a4:	75 07                	jne    801057ad <strncmp+0x42>
    return 0;
801057a6:	b8 00 00 00 00       	mov    $0x0,%eax
801057ab:	eb 16                	jmp    801057c3 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801057ad:	8b 45 08             	mov    0x8(%ebp),%eax
801057b0:	0f b6 00             	movzbl (%eax),%eax
801057b3:	0f b6 d0             	movzbl %al,%edx
801057b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b9:	0f b6 00             	movzbl (%eax),%eax
801057bc:	0f b6 c0             	movzbl %al,%eax
801057bf:	29 c2                	sub    %eax,%edx
801057c1:	89 d0                	mov    %edx,%eax
}
801057c3:	5d                   	pop    %ebp
801057c4:	c3                   	ret

801057c5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057c5:	f3 0f 1e fb          	endbr32
801057c9:	55                   	push   %ebp
801057ca:	89 e5                	mov    %esp,%ebp
801057cc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057cf:	8b 45 08             	mov    0x8(%ebp),%eax
801057d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057d5:	90                   	nop
801057d6:	8b 45 10             	mov    0x10(%ebp),%eax
801057d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801057dc:	89 55 10             	mov    %edx,0x10(%ebp)
801057df:	85 c0                	test   %eax,%eax
801057e1:	7e 2c                	jle    8010580f <strncpy+0x4a>
801057e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801057e6:	8d 42 01             	lea    0x1(%edx),%eax
801057e9:	89 45 0c             	mov    %eax,0xc(%ebp)
801057ec:	8b 45 08             	mov    0x8(%ebp),%eax
801057ef:	8d 48 01             	lea    0x1(%eax),%ecx
801057f2:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057f5:	0f b6 12             	movzbl (%edx),%edx
801057f8:	88 10                	mov    %dl,(%eax)
801057fa:	0f b6 00             	movzbl (%eax),%eax
801057fd:	84 c0                	test   %al,%al
801057ff:	75 d5                	jne    801057d6 <strncpy+0x11>
    ;
  while(n-- > 0)
80105801:	eb 0c                	jmp    8010580f <strncpy+0x4a>
    *s++ = 0;
80105803:	8b 45 08             	mov    0x8(%ebp),%eax
80105806:	8d 50 01             	lea    0x1(%eax),%edx
80105809:	89 55 08             	mov    %edx,0x8(%ebp)
8010580c:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010580f:	8b 45 10             	mov    0x10(%ebp),%eax
80105812:	8d 50 ff             	lea    -0x1(%eax),%edx
80105815:	89 55 10             	mov    %edx,0x10(%ebp)
80105818:	85 c0                	test   %eax,%eax
8010581a:	7f e7                	jg     80105803 <strncpy+0x3e>
  return os;
8010581c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010581f:	c9                   	leave
80105820:	c3                   	ret

80105821 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105821:	f3 0f 1e fb          	endbr32
80105825:	55                   	push   %ebp
80105826:	89 e5                	mov    %esp,%ebp
80105828:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010582b:	8b 45 08             	mov    0x8(%ebp),%eax
8010582e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105831:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105835:	7f 05                	jg     8010583c <safestrcpy+0x1b>
    return os;
80105837:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583a:	eb 31                	jmp    8010586d <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010583c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105840:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105844:	7e 1e                	jle    80105864 <safestrcpy+0x43>
80105846:	8b 55 0c             	mov    0xc(%ebp),%edx
80105849:	8d 42 01             	lea    0x1(%edx),%eax
8010584c:	89 45 0c             	mov    %eax,0xc(%ebp)
8010584f:	8b 45 08             	mov    0x8(%ebp),%eax
80105852:	8d 48 01             	lea    0x1(%eax),%ecx
80105855:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105858:	0f b6 12             	movzbl (%edx),%edx
8010585b:	88 10                	mov    %dl,(%eax)
8010585d:	0f b6 00             	movzbl (%eax),%eax
80105860:	84 c0                	test   %al,%al
80105862:	75 d8                	jne    8010583c <safestrcpy+0x1b>
    ;
  *s = 0;
80105864:	8b 45 08             	mov    0x8(%ebp),%eax
80105867:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010586a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010586d:	c9                   	leave
8010586e:	c3                   	ret

8010586f <strlen>:

int
strlen(const char *s)
{
8010586f:	f3 0f 1e fb          	endbr32
80105873:	55                   	push   %ebp
80105874:	89 e5                	mov    %esp,%ebp
80105876:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105879:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105880:	eb 04                	jmp    80105886 <strlen+0x17>
80105882:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105886:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105889:	8b 45 08             	mov    0x8(%ebp),%eax
8010588c:	01 d0                	add    %edx,%eax
8010588e:	0f b6 00             	movzbl (%eax),%eax
80105891:	84 c0                	test   %al,%al
80105893:	75 ed                	jne    80105882 <strlen+0x13>
    ;
  return n;
80105895:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105898:	c9                   	leave
80105899:	c3                   	ret

8010589a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010589a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010589e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801058a2:	55                   	push   %ebp
  pushl %ebx
801058a3:	53                   	push   %ebx
  pushl %esi
801058a4:	56                   	push   %esi
  pushl %edi
801058a5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058a6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058a8:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801058aa:	5f                   	pop    %edi
  popl %esi
801058ab:	5e                   	pop    %esi
  popl %ebx
801058ac:	5b                   	pop    %ebx
  popl %ebp
801058ad:	5d                   	pop    %ebp
  ret
801058ae:	c3                   	ret

801058af <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801058af:	f3 0f 1e fb          	endbr32
801058b3:	55                   	push   %ebp
801058b4:	89 e5                	mov    %esp,%ebp
801058b6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801058b9:	e8 eb e2 ff ff       	call   80103ba9 <myproc>
801058be:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801058c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c4:	8b 00                	mov    (%eax),%eax
801058c6:	39 45 08             	cmp    %eax,0x8(%ebp)
801058c9:	73 0f                	jae    801058da <fetchint+0x2b>
801058cb:	8b 45 08             	mov    0x8(%ebp),%eax
801058ce:	8d 50 04             	lea    0x4(%eax),%edx
801058d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d4:	8b 00                	mov    (%eax),%eax
801058d6:	39 c2                	cmp    %eax,%edx
801058d8:	76 07                	jbe    801058e1 <fetchint+0x32>
    return -1;
801058da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058df:	eb 0f                	jmp    801058f0 <fetchint+0x41>
  *ip = *(int*)(addr);
801058e1:	8b 45 08             	mov    0x8(%ebp),%eax
801058e4:	8b 10                	mov    (%eax),%edx
801058e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e9:	89 10                	mov    %edx,(%eax)
  return 0;
801058eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058f0:	c9                   	leave
801058f1:	c3                   	ret

801058f2 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058f2:	f3 0f 1e fb          	endbr32
801058f6:	55                   	push   %ebp
801058f7:	89 e5                	mov    %esp,%ebp
801058f9:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801058fc:	e8 a8 e2 ff ff       	call   80103ba9 <myproc>
80105901:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105907:	8b 00                	mov    (%eax),%eax
80105909:	39 45 08             	cmp    %eax,0x8(%ebp)
8010590c:	72 07                	jb     80105915 <fetchstr+0x23>
    return -1;
8010590e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105913:	eb 43                	jmp    80105958 <fetchstr+0x66>
  *pp = (char*)addr;
80105915:	8b 55 08             	mov    0x8(%ebp),%edx
80105918:	8b 45 0c             	mov    0xc(%ebp),%eax
8010591b:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010591d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105920:	8b 00                	mov    (%eax),%eax
80105922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105925:	8b 45 0c             	mov    0xc(%ebp),%eax
80105928:	8b 00                	mov    (%eax),%eax
8010592a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010592d:	eb 1c                	jmp    8010594b <fetchstr+0x59>
    if(*s == 0)
8010592f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105932:	0f b6 00             	movzbl (%eax),%eax
80105935:	84 c0                	test   %al,%al
80105937:	75 0e                	jne    80105947 <fetchstr+0x55>
      return s - *pp;
80105939:	8b 45 0c             	mov    0xc(%ebp),%eax
8010593c:	8b 00                	mov    (%eax),%eax
8010593e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105941:	29 c2                	sub    %eax,%edx
80105943:	89 d0                	mov    %edx,%eax
80105945:	eb 11                	jmp    80105958 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105947:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010594b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105951:	72 dc                	jb     8010592f <fetchstr+0x3d>
  }
  return -1;
80105953:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105958:	c9                   	leave
80105959:	c3                   	ret

8010595a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010595a:	f3 0f 1e fb          	endbr32
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
80105961:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105964:	e8 40 e2 ff ff       	call   80103ba9 <myproc>
80105969:	8b 40 18             	mov    0x18(%eax),%eax
8010596c:	8b 40 44             	mov    0x44(%eax),%eax
8010596f:	8b 55 08             	mov    0x8(%ebp),%edx
80105972:	c1 e2 02             	shl    $0x2,%edx
80105975:	01 d0                	add    %edx,%eax
80105977:	83 c0 04             	add    $0x4,%eax
8010597a:	83 ec 08             	sub    $0x8,%esp
8010597d:	ff 75 0c             	push   0xc(%ebp)
80105980:	50                   	push   %eax
80105981:	e8 29 ff ff ff       	call   801058af <fetchint>
80105986:	83 c4 10             	add    $0x10,%esp
}
80105989:	c9                   	leave
8010598a:	c3                   	ret

8010598b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010598b:	f3 0f 1e fb          	endbr32
8010598f:	55                   	push   %ebp
80105990:	89 e5                	mov    %esp,%ebp
80105992:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105995:	e8 0f e2 ff ff       	call   80103ba9 <myproc>
8010599a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010599d:	83 ec 08             	sub    $0x8,%esp
801059a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a3:	50                   	push   %eax
801059a4:	ff 75 08             	push   0x8(%ebp)
801059a7:	e8 ae ff ff ff       	call   8010595a <argint>
801059ac:	83 c4 10             	add    $0x10,%esp
801059af:	85 c0                	test   %eax,%eax
801059b1:	79 07                	jns    801059ba <argptr+0x2f>
    return -1;
801059b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b8:	eb 3b                	jmp    801059f5 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801059ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059be:	78 1f                	js     801059df <argptr+0x54>
801059c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c3:	8b 00                	mov    (%eax),%eax
801059c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059c8:	39 d0                	cmp    %edx,%eax
801059ca:	76 13                	jbe    801059df <argptr+0x54>
801059cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cf:	89 c2                	mov    %eax,%edx
801059d1:	8b 45 10             	mov    0x10(%ebp),%eax
801059d4:	01 c2                	add    %eax,%edx
801059d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d9:	8b 00                	mov    (%eax),%eax
801059db:	39 c2                	cmp    %eax,%edx
801059dd:	76 07                	jbe    801059e6 <argptr+0x5b>
    return -1;
801059df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e4:	eb 0f                	jmp    801059f5 <argptr+0x6a>
  *pp = (char*)i;
801059e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e9:	89 c2                	mov    %eax,%edx
801059eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ee:	89 10                	mov    %edx,(%eax)
  return 0;
801059f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f5:	c9                   	leave
801059f6:	c3                   	ret

801059f7 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059f7:	f3 0f 1e fb          	endbr32
801059fb:	55                   	push   %ebp
801059fc:	89 e5                	mov    %esp,%ebp
801059fe:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a01:	83 ec 08             	sub    $0x8,%esp
80105a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a07:	50                   	push   %eax
80105a08:	ff 75 08             	push   0x8(%ebp)
80105a0b:	e8 4a ff ff ff       	call   8010595a <argint>
80105a10:	83 c4 10             	add    $0x10,%esp
80105a13:	85 c0                	test   %eax,%eax
80105a15:	79 07                	jns    80105a1e <argstr+0x27>
    return -1;
80105a17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1c:	eb 12                	jmp    80105a30 <argstr+0x39>
  return fetchstr(addr, pp);
80105a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a21:	83 ec 08             	sub    $0x8,%esp
80105a24:	ff 75 0c             	push   0xc(%ebp)
80105a27:	50                   	push   %eax
80105a28:	e8 c5 fe ff ff       	call   801058f2 <fetchstr>
80105a2d:	83 c4 10             	add    $0x10,%esp
}
80105a30:	c9                   	leave
80105a31:	c3                   	ret

80105a32 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
80105a32:	f3 0f 1e fb          	endbr32
80105a36:	55                   	push   %ebp
80105a37:	89 e5                	mov    %esp,%ebp
80105a39:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105a3c:	e8 68 e1 ff ff       	call   80103ba9 <myproc>
80105a41:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a47:	8b 40 18             	mov    0x18(%eax),%eax
80105a4a:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a54:	7e 2f                	jle    80105a85 <syscall+0x53>
80105a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a59:	83 f8 19             	cmp    $0x19,%eax
80105a5c:	77 27                	ja     80105a85 <syscall+0x53>
80105a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a61:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a68:	85 c0                	test   %eax,%eax
80105a6a:	74 19                	je     80105a85 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6f:	8b 04 85 20 00 11 80 	mov    -0x7feeffe0(,%eax,4),%eax
80105a76:	ff d0                	call   *%eax
80105a78:	89 c2                	mov    %eax,%edx
80105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7d:	8b 40 18             	mov    0x18(%eax),%eax
80105a80:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a83:	eb 2c                	jmp    80105ab1 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a88:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8e:	8b 40 10             	mov    0x10(%eax),%eax
80105a91:	ff 75 f0             	push   -0x10(%ebp)
80105a94:	52                   	push   %edx
80105a95:	50                   	push   %eax
80105a96:	68 95 b4 10 80       	push   $0x8010b495
80105a9b:	e8 6c a9 ff ff       	call   8010040c <cprintf>
80105aa0:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa6:	8b 40 18             	mov    0x18(%eax),%eax
80105aa9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ab0:	90                   	nop
80105ab1:	90                   	nop
80105ab2:	c9                   	leave
80105ab3:	c3                   	ret

80105ab4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ab4:	f3 0f 1e fb          	endbr32
80105ab8:	55                   	push   %ebp
80105ab9:	89 e5                	mov    %esp,%ebp
80105abb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105abe:	83 ec 08             	sub    $0x8,%esp
80105ac1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ac4:	50                   	push   %eax
80105ac5:	ff 75 08             	push   0x8(%ebp)
80105ac8:	e8 8d fe ff ff       	call   8010595a <argint>
80105acd:	83 c4 10             	add    $0x10,%esp
80105ad0:	85 c0                	test   %eax,%eax
80105ad2:	79 07                	jns    80105adb <argfd+0x27>
    return -1;
80105ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad9:	eb 4f                	jmp    80105b2a <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	85 c0                	test   %eax,%eax
80105ae0:	78 20                	js     80105b02 <argfd+0x4e>
80105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae5:	83 f8 0f             	cmp    $0xf,%eax
80105ae8:	7f 18                	jg     80105b02 <argfd+0x4e>
80105aea:	e8 ba e0 ff ff       	call   80103ba9 <myproc>
80105aef:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105af2:	83 c2 08             	add    $0x8,%edx
80105af5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b00:	75 07                	jne    80105b09 <argfd+0x55>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	eb 21                	jmp    80105b2a <argfd+0x76>
  if(pfd)
80105b09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b0d:	74 08                	je     80105b17 <argfd+0x63>
    *pfd = fd;
80105b0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b15:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b1b:	74 08                	je     80105b25 <argfd+0x71>
    *pf = f;
80105b1d:	8b 45 10             	mov    0x10(%ebp),%eax
80105b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b23:	89 10                	mov    %edx,(%eax)
  return 0;
80105b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b2a:	c9                   	leave
80105b2b:	c3                   	ret

80105b2c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b2c:	f3 0f 1e fb          	endbr32
80105b30:	55                   	push   %ebp
80105b31:	89 e5                	mov    %esp,%ebp
80105b33:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105b36:	e8 6e e0 ff ff       	call   80103ba9 <myproc>
80105b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105b3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b45:	eb 2a                	jmp    80105b71 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b4d:	83 c2 08             	add    $0x8,%edx
80105b50:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b54:	85 c0                	test   %eax,%eax
80105b56:	75 15                	jne    80105b6d <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b5e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b61:	8b 55 08             	mov    0x8(%ebp),%edx
80105b64:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6b:	eb 0f                	jmp    80105b7c <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b71:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b75:	7e d0                	jle    80105b47 <fdalloc+0x1b>
    }
  }
  return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b7c:	c9                   	leave
80105b7d:	c3                   	ret

80105b7e <sys_dup>:

int
sys_dup(void)
{
80105b7e:	f3 0f 1e fb          	endbr32
80105b82:	55                   	push   %ebp
80105b83:	89 e5                	mov    %esp,%ebp
80105b85:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b88:	83 ec 04             	sub    $0x4,%esp
80105b8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b8e:	50                   	push   %eax
80105b8f:	6a 00                	push   $0x0
80105b91:	6a 00                	push   $0x0
80105b93:	e8 1c ff ff ff       	call   80105ab4 <argfd>
80105b98:	83 c4 10             	add    $0x10,%esp
80105b9b:	85 c0                	test   %eax,%eax
80105b9d:	79 07                	jns    80105ba6 <sys_dup+0x28>
    return -1;
80105b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba4:	eb 31                	jmp    80105bd7 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	50                   	push   %eax
80105bad:	e8 7a ff ff ff       	call   80105b2c <fdalloc>
80105bb2:	83 c4 10             	add    $0x10,%esp
80105bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bbc:	79 07                	jns    80105bc5 <sys_dup+0x47>
    return -1;
80105bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc3:	eb 12                	jmp    80105bd7 <sys_dup+0x59>
  filedup(f);
80105bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc8:	83 ec 0c             	sub    $0xc,%esp
80105bcb:	50                   	push   %eax
80105bcc:	e8 c3 b4 ff ff       	call   80101094 <filedup>
80105bd1:	83 c4 10             	add    $0x10,%esp
  return fd;
80105bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105bd7:	c9                   	leave
80105bd8:	c3                   	ret

80105bd9 <sys_read>:

int
sys_read(void)
{
80105bd9:	f3 0f 1e fb          	endbr32
80105bdd:	55                   	push   %ebp
80105bde:	89 e5                	mov    %esp,%ebp
80105be0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105be3:	83 ec 04             	sub    $0x4,%esp
80105be6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105be9:	50                   	push   %eax
80105bea:	6a 00                	push   $0x0
80105bec:	6a 00                	push   $0x0
80105bee:	e8 c1 fe ff ff       	call   80105ab4 <argfd>
80105bf3:	83 c4 10             	add    $0x10,%esp
80105bf6:	85 c0                	test   %eax,%eax
80105bf8:	78 2e                	js     80105c28 <sys_read+0x4f>
80105bfa:	83 ec 08             	sub    $0x8,%esp
80105bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c00:	50                   	push   %eax
80105c01:	6a 02                	push   $0x2
80105c03:	e8 52 fd ff ff       	call   8010595a <argint>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	78 19                	js     80105c28 <sys_read+0x4f>
80105c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c12:	83 ec 04             	sub    $0x4,%esp
80105c15:	50                   	push   %eax
80105c16:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c19:	50                   	push   %eax
80105c1a:	6a 01                	push   $0x1
80105c1c:	e8 6a fd ff ff       	call   8010598b <argptr>
80105c21:	83 c4 10             	add    $0x10,%esp
80105c24:	85 c0                	test   %eax,%eax
80105c26:	79 07                	jns    80105c2f <sys_read+0x56>
    return -1;
80105c28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2d:	eb 17                	jmp    80105c46 <sys_read+0x6d>
  return fileread(f, p, n);
80105c2f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c32:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c38:	83 ec 04             	sub    $0x4,%esp
80105c3b:	51                   	push   %ecx
80105c3c:	52                   	push   %edx
80105c3d:	50                   	push   %eax
80105c3e:	e8 ed b5 ff ff       	call   80101230 <fileread>
80105c43:	83 c4 10             	add    $0x10,%esp
}
80105c46:	c9                   	leave
80105c47:	c3                   	ret

80105c48 <sys_write>:

int
sys_write(void)
{
80105c48:	f3 0f 1e fb          	endbr32
80105c4c:	55                   	push   %ebp
80105c4d:	89 e5                	mov    %esp,%ebp
80105c4f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c52:	83 ec 04             	sub    $0x4,%esp
80105c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c58:	50                   	push   %eax
80105c59:	6a 00                	push   $0x0
80105c5b:	6a 00                	push   $0x0
80105c5d:	e8 52 fe ff ff       	call   80105ab4 <argfd>
80105c62:	83 c4 10             	add    $0x10,%esp
80105c65:	85 c0                	test   %eax,%eax
80105c67:	78 2e                	js     80105c97 <sys_write+0x4f>
80105c69:	83 ec 08             	sub    $0x8,%esp
80105c6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6f:	50                   	push   %eax
80105c70:	6a 02                	push   $0x2
80105c72:	e8 e3 fc ff ff       	call   8010595a <argint>
80105c77:	83 c4 10             	add    $0x10,%esp
80105c7a:	85 c0                	test   %eax,%eax
80105c7c:	78 19                	js     80105c97 <sys_write+0x4f>
80105c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c81:	83 ec 04             	sub    $0x4,%esp
80105c84:	50                   	push   %eax
80105c85:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c88:	50                   	push   %eax
80105c89:	6a 01                	push   $0x1
80105c8b:	e8 fb fc ff ff       	call   8010598b <argptr>
80105c90:	83 c4 10             	add    $0x10,%esp
80105c93:	85 c0                	test   %eax,%eax
80105c95:	79 07                	jns    80105c9e <sys_write+0x56>
    return -1;
80105c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9c:	eb 17                	jmp    80105cb5 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ca1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca7:	83 ec 04             	sub    $0x4,%esp
80105caa:	51                   	push   %ecx
80105cab:	52                   	push   %edx
80105cac:	50                   	push   %eax
80105cad:	e8 3a b6 ff ff       	call   801012ec <filewrite>
80105cb2:	83 c4 10             	add    $0x10,%esp
}
80105cb5:	c9                   	leave
80105cb6:	c3                   	ret

80105cb7 <sys_close>:

int
sys_close(void)
{
80105cb7:	f3 0f 1e fb          	endbr32
80105cbb:	55                   	push   %ebp
80105cbc:	89 e5                	mov    %esp,%ebp
80105cbe:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105cc1:	83 ec 04             	sub    $0x4,%esp
80105cc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cc7:	50                   	push   %eax
80105cc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ccb:	50                   	push   %eax
80105ccc:	6a 00                	push   $0x0
80105cce:	e8 e1 fd ff ff       	call   80105ab4 <argfd>
80105cd3:	83 c4 10             	add    $0x10,%esp
80105cd6:	85 c0                	test   %eax,%eax
80105cd8:	79 07                	jns    80105ce1 <sys_close+0x2a>
    return -1;
80105cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdf:	eb 27                	jmp    80105d08 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105ce1:	e8 c3 de ff ff       	call   80103ba9 <myproc>
80105ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ce9:	83 c2 08             	add    $0x8,%edx
80105cec:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cf3:	00 
  fileclose(f);
80105cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf7:	83 ec 0c             	sub    $0xc,%esp
80105cfa:	50                   	push   %eax
80105cfb:	e8 e9 b3 ff ff       	call   801010e9 <fileclose>
80105d00:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d03:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d08:	c9                   	leave
80105d09:	c3                   	ret

80105d0a <sys_fstat>:

int
sys_fstat(void)
{
80105d0a:	f3 0f 1e fb          	endbr32
80105d0e:	55                   	push   %ebp
80105d0f:	89 e5                	mov    %esp,%ebp
80105d11:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d14:	83 ec 04             	sub    $0x4,%esp
80105d17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d1a:	50                   	push   %eax
80105d1b:	6a 00                	push   $0x0
80105d1d:	6a 00                	push   $0x0
80105d1f:	e8 90 fd ff ff       	call   80105ab4 <argfd>
80105d24:	83 c4 10             	add    $0x10,%esp
80105d27:	85 c0                	test   %eax,%eax
80105d29:	78 17                	js     80105d42 <sys_fstat+0x38>
80105d2b:	83 ec 04             	sub    $0x4,%esp
80105d2e:	6a 14                	push   $0x14
80105d30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d33:	50                   	push   %eax
80105d34:	6a 01                	push   $0x1
80105d36:	e8 50 fc ff ff       	call   8010598b <argptr>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	85 c0                	test   %eax,%eax
80105d40:	79 07                	jns    80105d49 <sys_fstat+0x3f>
    return -1;
80105d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d47:	eb 13                	jmp    80105d5c <sys_fstat+0x52>
  return filestat(f, st);
80105d49:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	83 ec 08             	sub    $0x8,%esp
80105d52:	52                   	push   %edx
80105d53:	50                   	push   %eax
80105d54:	e8 7c b4 ff ff       	call   801011d5 <filestat>
80105d59:	83 c4 10             	add    $0x10,%esp
}
80105d5c:	c9                   	leave
80105d5d:	c3                   	ret

80105d5e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d5e:	f3 0f 1e fb          	endbr32
80105d62:	55                   	push   %ebp
80105d63:	89 e5                	mov    %esp,%ebp
80105d65:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d68:	83 ec 08             	sub    $0x8,%esp
80105d6b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d6e:	50                   	push   %eax
80105d6f:	6a 00                	push   $0x0
80105d71:	e8 81 fc ff ff       	call   801059f7 <argstr>
80105d76:	83 c4 10             	add    $0x10,%esp
80105d79:	85 c0                	test   %eax,%eax
80105d7b:	78 15                	js     80105d92 <sys_link+0x34>
80105d7d:	83 ec 08             	sub    $0x8,%esp
80105d80:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d83:	50                   	push   %eax
80105d84:	6a 01                	push   $0x1
80105d86:	e8 6c fc ff ff       	call   801059f7 <argstr>
80105d8b:	83 c4 10             	add    $0x10,%esp
80105d8e:	85 c0                	test   %eax,%eax
80105d90:	79 0a                	jns    80105d9c <sys_link+0x3e>
    return -1;
80105d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d97:	e9 68 01 00 00       	jmp    80105f04 <sys_link+0x1a6>

  begin_op();
80105d9c:	e8 d0 d3 ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105da1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105da4:	83 ec 0c             	sub    $0xc,%esp
80105da7:	50                   	push   %eax
80105da8:	e8 3a c8 ff ff       	call   801025e7 <namei>
80105dad:	83 c4 10             	add    $0x10,%esp
80105db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db7:	75 0f                	jne    80105dc8 <sys_link+0x6a>
    end_op();
80105db9:	e8 43 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc3:	e9 3c 01 00 00       	jmp    80105f04 <sys_link+0x1a6>
  }

  ilock(ip);
80105dc8:	83 ec 0c             	sub    $0xc,%esp
80105dcb:	ff 75 f4             	push   -0xc(%ebp)
80105dce:	e8 a9 bc ff ff       	call   80101a7c <ilock>
80105dd3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ddd:	66 83 f8 01          	cmp    $0x1,%ax
80105de1:	75 1d                	jne    80105e00 <sys_link+0xa2>
    iunlockput(ip);
80105de3:	83 ec 0c             	sub    $0xc,%esp
80105de6:	ff 75 f4             	push   -0xc(%ebp)
80105de9:	e8 cb be ff ff       	call   80101cb9 <iunlockput>
80105dee:	83 c4 10             	add    $0x10,%esp
    end_op();
80105df1:	e8 0b d4 ff ff       	call   80103201 <end_op>
    return -1;
80105df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfb:	e9 04 01 00 00       	jmp    80105f04 <sys_link+0x1a6>
  }

  ip->nlink++;
80105e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e03:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e07:	83 c0 01             	add    $0x1,%eax
80105e0a:	89 c2                	mov    %eax,%edx
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e13:	83 ec 0c             	sub    $0xc,%esp
80105e16:	ff 75 f4             	push   -0xc(%ebp)
80105e19:	e8 75 ba ff ff       	call   80101893 <iupdate>
80105e1e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105e21:	83 ec 0c             	sub    $0xc,%esp
80105e24:	ff 75 f4             	push   -0xc(%ebp)
80105e27:	e8 67 bd ff ff       	call   80101b93 <iunlock>
80105e2c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105e2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e32:	83 ec 08             	sub    $0x8,%esp
80105e35:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e38:	52                   	push   %edx
80105e39:	50                   	push   %eax
80105e3a:	e8 c8 c7 ff ff       	call   80102607 <nameiparent>
80105e3f:	83 c4 10             	add    $0x10,%esp
80105e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e49:	74 71                	je     80105ebc <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105e4b:	83 ec 0c             	sub    $0xc,%esp
80105e4e:	ff 75 f0             	push   -0x10(%ebp)
80105e51:	e8 26 bc ff ff       	call   80101a7c <ilock>
80105e56:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5c:	8b 10                	mov    (%eax),%edx
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	8b 00                	mov    (%eax),%eax
80105e63:	39 c2                	cmp    %eax,%edx
80105e65:	75 1d                	jne    80105e84 <sys_link+0x126>
80105e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6a:	8b 40 04             	mov    0x4(%eax),%eax
80105e6d:	83 ec 04             	sub    $0x4,%esp
80105e70:	50                   	push   %eax
80105e71:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e74:	50                   	push   %eax
80105e75:	ff 75 f0             	push   -0x10(%ebp)
80105e78:	e8 c7 c4 ff ff       	call   80102344 <dirlink>
80105e7d:	83 c4 10             	add    $0x10,%esp
80105e80:	85 c0                	test   %eax,%eax
80105e82:	79 10                	jns    80105e94 <sys_link+0x136>
    iunlockput(dp);
80105e84:	83 ec 0c             	sub    $0xc,%esp
80105e87:	ff 75 f0             	push   -0x10(%ebp)
80105e8a:	e8 2a be ff ff       	call   80101cb9 <iunlockput>
80105e8f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e92:	eb 29                	jmp    80105ebd <sys_link+0x15f>
  }
  iunlockput(dp);
80105e94:	83 ec 0c             	sub    $0xc,%esp
80105e97:	ff 75 f0             	push   -0x10(%ebp)
80105e9a:	e8 1a be ff ff       	call   80101cb9 <iunlockput>
80105e9f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ea2:	83 ec 0c             	sub    $0xc,%esp
80105ea5:	ff 75 f4             	push   -0xc(%ebp)
80105ea8:	e8 38 bd ff ff       	call   80101be5 <iput>
80105ead:	83 c4 10             	add    $0x10,%esp

  end_op();
80105eb0:	e8 4c d3 ff ff       	call   80103201 <end_op>

  return 0;
80105eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80105eba:	eb 48                	jmp    80105f04 <sys_link+0x1a6>
    goto bad;
80105ebc:	90                   	nop

bad:
  ilock(ip);
80105ebd:	83 ec 0c             	sub    $0xc,%esp
80105ec0:	ff 75 f4             	push   -0xc(%ebp)
80105ec3:	e8 b4 bb ff ff       	call   80101a7c <ilock>
80105ec8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ed2:	83 e8 01             	sub    $0x1,%eax
80105ed5:	89 c2                	mov    %eax,%edx
80105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eda:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ede:	83 ec 0c             	sub    $0xc,%esp
80105ee1:	ff 75 f4             	push   -0xc(%ebp)
80105ee4:	e8 aa b9 ff ff       	call   80101893 <iupdate>
80105ee9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105eec:	83 ec 0c             	sub    $0xc,%esp
80105eef:	ff 75 f4             	push   -0xc(%ebp)
80105ef2:	e8 c2 bd ff ff       	call   80101cb9 <iunlockput>
80105ef7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105efa:	e8 02 d3 ff ff       	call   80103201 <end_op>
  return -1;
80105eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f04:	c9                   	leave
80105f05:	c3                   	ret

80105f06 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f06:	f3 0f 1e fb          	endbr32
80105f0a:	55                   	push   %ebp
80105f0b:	89 e5                	mov    %esp,%ebp
80105f0d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f10:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f17:	eb 40                	jmp    80105f59 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1c:	6a 10                	push   $0x10
80105f1e:	50                   	push   %eax
80105f1f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f22:	50                   	push   %eax
80105f23:	ff 75 08             	push   0x8(%ebp)
80105f26:	e8 59 c0 ff ff       	call   80101f84 <readi>
80105f2b:	83 c4 10             	add    $0x10,%esp
80105f2e:	83 f8 10             	cmp    $0x10,%eax
80105f31:	74 0d                	je     80105f40 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105f33:	83 ec 0c             	sub    $0xc,%esp
80105f36:	68 b1 b4 10 80       	push   $0x8010b4b1
80105f3b:	e8 85 a6 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105f40:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f44:	66 85 c0             	test   %ax,%ax
80105f47:	74 07                	je     80105f50 <isdirempty+0x4a>
      return 0;
80105f49:	b8 00 00 00 00       	mov    $0x0,%eax
80105f4e:	eb 1b                	jmp    80105f6b <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f53:	83 c0 10             	add    $0x10,%eax
80105f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f59:	8b 45 08             	mov    0x8(%ebp),%eax
80105f5c:	8b 50 58             	mov    0x58(%eax),%edx
80105f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f62:	39 c2                	cmp    %eax,%edx
80105f64:	77 b3                	ja     80105f19 <isdirempty+0x13>
  }
  return 1;
80105f66:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f6b:	c9                   	leave
80105f6c:	c3                   	ret

80105f6d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f6d:	f3 0f 1e fb          	endbr32
80105f71:	55                   	push   %ebp
80105f72:	89 e5                	mov    %esp,%ebp
80105f74:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f77:	83 ec 08             	sub    $0x8,%esp
80105f7a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f7d:	50                   	push   %eax
80105f7e:	6a 00                	push   $0x0
80105f80:	e8 72 fa ff ff       	call   801059f7 <argstr>
80105f85:	83 c4 10             	add    $0x10,%esp
80105f88:	85 c0                	test   %eax,%eax
80105f8a:	79 0a                	jns    80105f96 <sys_unlink+0x29>
    return -1;
80105f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f91:	e9 bf 01 00 00       	jmp    80106155 <sys_unlink+0x1e8>

  begin_op();
80105f96:	e8 d6 d1 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f9b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f9e:	83 ec 08             	sub    $0x8,%esp
80105fa1:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105fa4:	52                   	push   %edx
80105fa5:	50                   	push   %eax
80105fa6:	e8 5c c6 ff ff       	call   80102607 <nameiparent>
80105fab:	83 c4 10             	add    $0x10,%esp
80105fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb5:	75 0f                	jne    80105fc6 <sys_unlink+0x59>
    end_op();
80105fb7:	e8 45 d2 ff ff       	call   80103201 <end_op>
    return -1;
80105fbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc1:	e9 8f 01 00 00       	jmp    80106155 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105fc6:	83 ec 0c             	sub    $0xc,%esp
80105fc9:	ff 75 f4             	push   -0xc(%ebp)
80105fcc:	e8 ab ba ff ff       	call   80101a7c <ilock>
80105fd1:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105fd4:	83 ec 08             	sub    $0x8,%esp
80105fd7:	68 c3 b4 10 80       	push   $0x8010b4c3
80105fdc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fdf:	50                   	push   %eax
80105fe0:	e8 82 c2 ff ff       	call   80102267 <namecmp>
80105fe5:	83 c4 10             	add    $0x10,%esp
80105fe8:	85 c0                	test   %eax,%eax
80105fea:	0f 84 49 01 00 00    	je     80106139 <sys_unlink+0x1cc>
80105ff0:	83 ec 08             	sub    $0x8,%esp
80105ff3:	68 c5 b4 10 80       	push   $0x8010b4c5
80105ff8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ffb:	50                   	push   %eax
80105ffc:	e8 66 c2 ff ff       	call   80102267 <namecmp>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	85 c0                	test   %eax,%eax
80106006:	0f 84 2d 01 00 00    	je     80106139 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010600c:	83 ec 04             	sub    $0x4,%esp
8010600f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106012:	50                   	push   %eax
80106013:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106016:	50                   	push   %eax
80106017:	ff 75 f4             	push   -0xc(%ebp)
8010601a:	e8 67 c2 ff ff       	call   80102286 <dirlookup>
8010601f:	83 c4 10             	add    $0x10,%esp
80106022:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106025:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106029:	0f 84 0d 01 00 00    	je     8010613c <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010602f:	83 ec 0c             	sub    $0xc,%esp
80106032:	ff 75 f0             	push   -0x10(%ebp)
80106035:	e8 42 ba ff ff       	call   80101a7c <ilock>
8010603a:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010603d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106040:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106044:	66 85 c0             	test   %ax,%ax
80106047:	7f 0d                	jg     80106056 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80106049:	83 ec 0c             	sub    $0xc,%esp
8010604c:	68 c8 b4 10 80       	push   $0x8010b4c8
80106051:	e8 6f a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106059:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010605d:	66 83 f8 01          	cmp    $0x1,%ax
80106061:	75 25                	jne    80106088 <sys_unlink+0x11b>
80106063:	83 ec 0c             	sub    $0xc,%esp
80106066:	ff 75 f0             	push   -0x10(%ebp)
80106069:	e8 98 fe ff ff       	call   80105f06 <isdirempty>
8010606e:	83 c4 10             	add    $0x10,%esp
80106071:	85 c0                	test   %eax,%eax
80106073:	75 13                	jne    80106088 <sys_unlink+0x11b>
    iunlockput(ip);
80106075:	83 ec 0c             	sub    $0xc,%esp
80106078:	ff 75 f0             	push   -0x10(%ebp)
8010607b:	e8 39 bc ff ff       	call   80101cb9 <iunlockput>
80106080:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106083:	e9 b5 00 00 00       	jmp    8010613d <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106088:	83 ec 04             	sub    $0x4,%esp
8010608b:	6a 10                	push   $0x10
8010608d:	6a 00                	push   $0x0
8010608f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106092:	50                   	push   %eax
80106093:	e8 6e f5 ff ff       	call   80105606 <memset>
80106098:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010609b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010609e:	6a 10                	push   $0x10
801060a0:	50                   	push   %eax
801060a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060a4:	50                   	push   %eax
801060a5:	ff 75 f4             	push   -0xc(%ebp)
801060a8:	e8 30 c0 ff ff       	call   801020dd <writei>
801060ad:	83 c4 10             	add    $0x10,%esp
801060b0:	83 f8 10             	cmp    $0x10,%eax
801060b3:	74 0d                	je     801060c2 <sys_unlink+0x155>
    panic("unlink: writei");
801060b5:	83 ec 0c             	sub    $0xc,%esp
801060b8:	68 da b4 10 80       	push   $0x8010b4da
801060bd:	e8 03 a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
801060c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060c9:	66 83 f8 01          	cmp    $0x1,%ax
801060cd:	75 21                	jne    801060f0 <sys_unlink+0x183>
    dp->nlink--;
801060cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060d6:	83 e8 01             	sub    $0x1,%eax
801060d9:	89 c2                	mov    %eax,%edx
801060db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060de:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801060e2:	83 ec 0c             	sub    $0xc,%esp
801060e5:	ff 75 f4             	push   -0xc(%ebp)
801060e8:	e8 a6 b7 ff ff       	call   80101893 <iupdate>
801060ed:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801060f0:	83 ec 0c             	sub    $0xc,%esp
801060f3:	ff 75 f4             	push   -0xc(%ebp)
801060f6:	e8 be bb ff ff       	call   80101cb9 <iunlockput>
801060fb:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801060fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106101:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106105:	83 e8 01             	sub    $0x1,%eax
80106108:	89 c2                	mov    %eax,%edx
8010610a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106111:	83 ec 0c             	sub    $0xc,%esp
80106114:	ff 75 f0             	push   -0x10(%ebp)
80106117:	e8 77 b7 ff ff       	call   80101893 <iupdate>
8010611c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010611f:	83 ec 0c             	sub    $0xc,%esp
80106122:	ff 75 f0             	push   -0x10(%ebp)
80106125:	e8 8f bb ff ff       	call   80101cb9 <iunlockput>
8010612a:	83 c4 10             	add    $0x10,%esp

  end_op();
8010612d:	e8 cf d0 ff ff       	call   80103201 <end_op>

  return 0;
80106132:	b8 00 00 00 00       	mov    $0x0,%eax
80106137:	eb 1c                	jmp    80106155 <sys_unlink+0x1e8>
    goto bad;
80106139:	90                   	nop
8010613a:	eb 01                	jmp    8010613d <sys_unlink+0x1d0>
    goto bad;
8010613c:	90                   	nop

bad:
  iunlockput(dp);
8010613d:	83 ec 0c             	sub    $0xc,%esp
80106140:	ff 75 f4             	push   -0xc(%ebp)
80106143:	e8 71 bb ff ff       	call   80101cb9 <iunlockput>
80106148:	83 c4 10             	add    $0x10,%esp
  end_op();
8010614b:	e8 b1 d0 ff ff       	call   80103201 <end_op>
  return -1;
80106150:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106155:	c9                   	leave
80106156:	c3                   	ret

80106157 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106157:	f3 0f 1e fb          	endbr32
8010615b:	55                   	push   %ebp
8010615c:	89 e5                	mov    %esp,%ebp
8010615e:	83 ec 38             	sub    $0x38,%esp
80106161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106164:	8b 55 10             	mov    0x10(%ebp),%edx
80106167:	8b 45 14             	mov    0x14(%ebp),%eax
8010616a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010616e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106172:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106176:	83 ec 08             	sub    $0x8,%esp
80106179:	8d 45 de             	lea    -0x22(%ebp),%eax
8010617c:	50                   	push   %eax
8010617d:	ff 75 08             	push   0x8(%ebp)
80106180:	e8 82 c4 ff ff       	call   80102607 <nameiparent>
80106185:	83 c4 10             	add    $0x10,%esp
80106188:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010618b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010618f:	75 0a                	jne    8010619b <create+0x44>
    return 0;
80106191:	b8 00 00 00 00       	mov    $0x0,%eax
80106196:	e9 90 01 00 00       	jmp    8010632b <create+0x1d4>
  ilock(dp);
8010619b:	83 ec 0c             	sub    $0xc,%esp
8010619e:	ff 75 f4             	push   -0xc(%ebp)
801061a1:	e8 d6 b8 ff ff       	call   80101a7c <ilock>
801061a6:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801061a9:	83 ec 04             	sub    $0x4,%esp
801061ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061af:	50                   	push   %eax
801061b0:	8d 45 de             	lea    -0x22(%ebp),%eax
801061b3:	50                   	push   %eax
801061b4:	ff 75 f4             	push   -0xc(%ebp)
801061b7:	e8 ca c0 ff ff       	call   80102286 <dirlookup>
801061bc:	83 c4 10             	add    $0x10,%esp
801061bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c6:	74 50                	je     80106218 <create+0xc1>
    iunlockput(dp);
801061c8:	83 ec 0c             	sub    $0xc,%esp
801061cb:	ff 75 f4             	push   -0xc(%ebp)
801061ce:	e8 e6 ba ff ff       	call   80101cb9 <iunlockput>
801061d3:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	ff 75 f0             	push   -0x10(%ebp)
801061dc:	e8 9b b8 ff ff       	call   80101a7c <ilock>
801061e1:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801061e4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061e9:	75 15                	jne    80106200 <create+0xa9>
801061eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ee:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061f2:	66 83 f8 02          	cmp    $0x2,%ax
801061f6:	75 08                	jne    80106200 <create+0xa9>
      return ip;
801061f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fb:	e9 2b 01 00 00       	jmp    8010632b <create+0x1d4>
    iunlockput(ip);
80106200:	83 ec 0c             	sub    $0xc,%esp
80106203:	ff 75 f0             	push   -0x10(%ebp)
80106206:	e8 ae ba ff ff       	call   80101cb9 <iunlockput>
8010620b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010620e:	b8 00 00 00 00       	mov    $0x0,%eax
80106213:	e9 13 01 00 00       	jmp    8010632b <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106218:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010621c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621f:	8b 00                	mov    (%eax),%eax
80106221:	83 ec 08             	sub    $0x8,%esp
80106224:	52                   	push   %edx
80106225:	50                   	push   %eax
80106226:	e8 8d b5 ff ff       	call   801017b8 <ialloc>
8010622b:	83 c4 10             	add    $0x10,%esp
8010622e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106231:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106235:	75 0d                	jne    80106244 <create+0xed>
    panic("create: ialloc");
80106237:	83 ec 0c             	sub    $0xc,%esp
8010623a:	68 e9 b4 10 80       	push   $0x8010b4e9
8010623f:	e8 81 a3 ff ff       	call   801005c5 <panic>

  ilock(ip);
80106244:	83 ec 0c             	sub    $0xc,%esp
80106247:	ff 75 f0             	push   -0x10(%ebp)
8010624a:	e8 2d b8 ff ff       	call   80101a7c <ilock>
8010624f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106255:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106259:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010625d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106260:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106264:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626b:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106271:	83 ec 0c             	sub    $0xc,%esp
80106274:	ff 75 f0             	push   -0x10(%ebp)
80106277:	e8 17 b6 ff ff       	call   80101893 <iupdate>
8010627c:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010627f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106284:	75 6a                	jne    801062f0 <create+0x199>
    dp->nlink++;  // for ".."
80106286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106289:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010628d:	83 c0 01             	add    $0x1,%eax
80106290:	89 c2                	mov    %eax,%edx
80106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106295:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106299:	83 ec 0c             	sub    $0xc,%esp
8010629c:	ff 75 f4             	push   -0xc(%ebp)
8010629f:	e8 ef b5 ff ff       	call   80101893 <iupdate>
801062a4:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062aa:	8b 40 04             	mov    0x4(%eax),%eax
801062ad:	83 ec 04             	sub    $0x4,%esp
801062b0:	50                   	push   %eax
801062b1:	68 c3 b4 10 80       	push   $0x8010b4c3
801062b6:	ff 75 f0             	push   -0x10(%ebp)
801062b9:	e8 86 c0 ff ff       	call   80102344 <dirlink>
801062be:	83 c4 10             	add    $0x10,%esp
801062c1:	85 c0                	test   %eax,%eax
801062c3:	78 1e                	js     801062e3 <create+0x18c>
801062c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c8:	8b 40 04             	mov    0x4(%eax),%eax
801062cb:	83 ec 04             	sub    $0x4,%esp
801062ce:	50                   	push   %eax
801062cf:	68 c5 b4 10 80       	push   $0x8010b4c5
801062d4:	ff 75 f0             	push   -0x10(%ebp)
801062d7:	e8 68 c0 ff ff       	call   80102344 <dirlink>
801062dc:	83 c4 10             	add    $0x10,%esp
801062df:	85 c0                	test   %eax,%eax
801062e1:	79 0d                	jns    801062f0 <create+0x199>
      panic("create dots");
801062e3:	83 ec 0c             	sub    $0xc,%esp
801062e6:	68 f8 b4 10 80       	push   $0x8010b4f8
801062eb:	e8 d5 a2 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f3:	8b 40 04             	mov    0x4(%eax),%eax
801062f6:	83 ec 04             	sub    $0x4,%esp
801062f9:	50                   	push   %eax
801062fa:	8d 45 de             	lea    -0x22(%ebp),%eax
801062fd:	50                   	push   %eax
801062fe:	ff 75 f4             	push   -0xc(%ebp)
80106301:	e8 3e c0 ff ff       	call   80102344 <dirlink>
80106306:	83 c4 10             	add    $0x10,%esp
80106309:	85 c0                	test   %eax,%eax
8010630b:	79 0d                	jns    8010631a <create+0x1c3>
    panic("create: dirlink");
8010630d:	83 ec 0c             	sub    $0xc,%esp
80106310:	68 04 b5 10 80       	push   $0x8010b504
80106315:	e8 ab a2 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
8010631a:	83 ec 0c             	sub    $0xc,%esp
8010631d:	ff 75 f4             	push   -0xc(%ebp)
80106320:	e8 94 b9 ff ff       	call   80101cb9 <iunlockput>
80106325:	83 c4 10             	add    $0x10,%esp

  return ip;
80106328:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010632b:	c9                   	leave
8010632c:	c3                   	ret

8010632d <sys_open>:

int
sys_open(void)
{
8010632d:	f3 0f 1e fb          	endbr32
80106331:	55                   	push   %ebp
80106332:	89 e5                	mov    %esp,%ebp
80106334:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106337:	83 ec 08             	sub    $0x8,%esp
8010633a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010633d:	50                   	push   %eax
8010633e:	6a 00                	push   $0x0
80106340:	e8 b2 f6 ff ff       	call   801059f7 <argstr>
80106345:	83 c4 10             	add    $0x10,%esp
80106348:	85 c0                	test   %eax,%eax
8010634a:	78 15                	js     80106361 <sys_open+0x34>
8010634c:	83 ec 08             	sub    $0x8,%esp
8010634f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106352:	50                   	push   %eax
80106353:	6a 01                	push   $0x1
80106355:	e8 00 f6 ff ff       	call   8010595a <argint>
8010635a:	83 c4 10             	add    $0x10,%esp
8010635d:	85 c0                	test   %eax,%eax
8010635f:	79 0a                	jns    8010636b <sys_open+0x3e>
    return -1;
80106361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106366:	e9 61 01 00 00       	jmp    801064cc <sys_open+0x19f>

  begin_op();
8010636b:	e8 01 ce ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80106370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106373:	25 00 02 00 00       	and    $0x200,%eax
80106378:	85 c0                	test   %eax,%eax
8010637a:	74 2a                	je     801063a6 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
8010637c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010637f:	6a 00                	push   $0x0
80106381:	6a 00                	push   $0x0
80106383:	6a 02                	push   $0x2
80106385:	50                   	push   %eax
80106386:	e8 cc fd ff ff       	call   80106157 <create>
8010638b:	83 c4 10             	add    $0x10,%esp
8010638e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106395:	75 75                	jne    8010640c <sys_open+0xdf>
      end_op();
80106397:	e8 65 ce ff ff       	call   80103201 <end_op>
      return -1;
8010639c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a1:	e9 26 01 00 00       	jmp    801064cc <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801063a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063a9:	83 ec 0c             	sub    $0xc,%esp
801063ac:	50                   	push   %eax
801063ad:	e8 35 c2 ff ff       	call   801025e7 <namei>
801063b2:	83 c4 10             	add    $0x10,%esp
801063b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bc:	75 0f                	jne    801063cd <sys_open+0xa0>
      end_op();
801063be:	e8 3e ce ff ff       	call   80103201 <end_op>
      return -1;
801063c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c8:	e9 ff 00 00 00       	jmp    801064cc <sys_open+0x19f>
    }
    ilock(ip);
801063cd:	83 ec 0c             	sub    $0xc,%esp
801063d0:	ff 75 f4             	push   -0xc(%ebp)
801063d3:	e8 a4 b6 ff ff       	call   80101a7c <ilock>
801063d8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801063db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063de:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801063e2:	66 83 f8 01          	cmp    $0x1,%ax
801063e6:	75 24                	jne    8010640c <sys_open+0xdf>
801063e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063eb:	85 c0                	test   %eax,%eax
801063ed:	74 1d                	je     8010640c <sys_open+0xdf>
      iunlockput(ip);
801063ef:	83 ec 0c             	sub    $0xc,%esp
801063f2:	ff 75 f4             	push   -0xc(%ebp)
801063f5:	e8 bf b8 ff ff       	call   80101cb9 <iunlockput>
801063fa:	83 c4 10             	add    $0x10,%esp
      end_op();
801063fd:	e8 ff cd ff ff       	call   80103201 <end_op>
      return -1;
80106402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106407:	e9 c0 00 00 00       	jmp    801064cc <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010640c:	e8 12 ac ff ff       	call   80101023 <filealloc>
80106411:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106414:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106418:	74 17                	je     80106431 <sys_open+0x104>
8010641a:	83 ec 0c             	sub    $0xc,%esp
8010641d:	ff 75 f0             	push   -0x10(%ebp)
80106420:	e8 07 f7 ff ff       	call   80105b2c <fdalloc>
80106425:	83 c4 10             	add    $0x10,%esp
80106428:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010642b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010642f:	79 2e                	jns    8010645f <sys_open+0x132>
    if(f)
80106431:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106435:	74 0e                	je     80106445 <sys_open+0x118>
      fileclose(f);
80106437:	83 ec 0c             	sub    $0xc,%esp
8010643a:	ff 75 f0             	push   -0x10(%ebp)
8010643d:	e8 a7 ac ff ff       	call   801010e9 <fileclose>
80106442:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	ff 75 f4             	push   -0xc(%ebp)
8010644b:	e8 69 b8 ff ff       	call   80101cb9 <iunlockput>
80106450:	83 c4 10             	add    $0x10,%esp
    end_op();
80106453:	e8 a9 cd ff ff       	call   80103201 <end_op>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 6d                	jmp    801064cc <sys_open+0x19f>
  }
  iunlock(ip);
8010645f:	83 ec 0c             	sub    $0xc,%esp
80106462:	ff 75 f4             	push   -0xc(%ebp)
80106465:	e8 29 b7 ff ff       	call   80101b93 <iunlock>
8010646a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010646d:	e8 8f cd ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80106472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106475:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010647b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106481:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106487:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010648e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106491:	83 e0 01             	and    $0x1,%eax
80106494:	85 c0                	test   %eax,%eax
80106496:	0f 94 c0             	sete   %al
80106499:	89 c2                	mov    %eax,%edx
8010649b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064a4:	83 e0 01             	and    $0x1,%eax
801064a7:	85 c0                	test   %eax,%eax
801064a9:	75 0a                	jne    801064b5 <sys_open+0x188>
801064ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ae:	83 e0 02             	and    $0x2,%eax
801064b1:	85 c0                	test   %eax,%eax
801064b3:	74 07                	je     801064bc <sys_open+0x18f>
801064b5:	b8 01 00 00 00       	mov    $0x1,%eax
801064ba:	eb 05                	jmp    801064c1 <sys_open+0x194>
801064bc:	b8 00 00 00 00       	mov    $0x0,%eax
801064c1:	89 c2                	mov    %eax,%edx
801064c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c6:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064cc:	c9                   	leave
801064cd:	c3                   	ret

801064ce <sys_mkdir>:

int
sys_mkdir(void)
{
801064ce:	f3 0f 1e fb          	endbr32
801064d2:	55                   	push   %ebp
801064d3:	89 e5                	mov    %esp,%ebp
801064d5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064d8:	e8 94 cc ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064dd:	83 ec 08             	sub    $0x8,%esp
801064e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064e3:	50                   	push   %eax
801064e4:	6a 00                	push   $0x0
801064e6:	e8 0c f5 ff ff       	call   801059f7 <argstr>
801064eb:	83 c4 10             	add    $0x10,%esp
801064ee:	85 c0                	test   %eax,%eax
801064f0:	78 1b                	js     8010650d <sys_mkdir+0x3f>
801064f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f5:	6a 00                	push   $0x0
801064f7:	6a 00                	push   $0x0
801064f9:	6a 01                	push   $0x1
801064fb:	50                   	push   %eax
801064fc:	e8 56 fc ff ff       	call   80106157 <create>
80106501:	83 c4 10             	add    $0x10,%esp
80106504:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106507:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010650b:	75 0c                	jne    80106519 <sys_mkdir+0x4b>
    end_op();
8010650d:	e8 ef cc ff ff       	call   80103201 <end_op>
    return -1;
80106512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106517:	eb 18                	jmp    80106531 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106519:	83 ec 0c             	sub    $0xc,%esp
8010651c:	ff 75 f4             	push   -0xc(%ebp)
8010651f:	e8 95 b7 ff ff       	call   80101cb9 <iunlockput>
80106524:	83 c4 10             	add    $0x10,%esp
  end_op();
80106527:	e8 d5 cc ff ff       	call   80103201 <end_op>
  return 0;
8010652c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106531:	c9                   	leave
80106532:	c3                   	ret

80106533 <sys_mknod>:

int
sys_mknod(void)
{
80106533:	f3 0f 1e fb          	endbr32
80106537:	55                   	push   %ebp
80106538:	89 e5                	mov    %esp,%ebp
8010653a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010653d:	e8 2f cc ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106542:	83 ec 08             	sub    $0x8,%esp
80106545:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106548:	50                   	push   %eax
80106549:	6a 00                	push   $0x0
8010654b:	e8 a7 f4 ff ff       	call   801059f7 <argstr>
80106550:	83 c4 10             	add    $0x10,%esp
80106553:	85 c0                	test   %eax,%eax
80106555:	78 4f                	js     801065a6 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106557:	83 ec 08             	sub    $0x8,%esp
8010655a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010655d:	50                   	push   %eax
8010655e:	6a 01                	push   $0x1
80106560:	e8 f5 f3 ff ff       	call   8010595a <argint>
80106565:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106568:	85 c0                	test   %eax,%eax
8010656a:	78 3a                	js     801065a6 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
8010656c:	83 ec 08             	sub    $0x8,%esp
8010656f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106572:	50                   	push   %eax
80106573:	6a 02                	push   $0x2
80106575:	e8 e0 f3 ff ff       	call   8010595a <argint>
8010657a:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010657d:	85 c0                	test   %eax,%eax
8010657f:	78 25                	js     801065a6 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106581:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106584:	0f bf c8             	movswl %ax,%ecx
80106587:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010658a:	0f bf d0             	movswl %ax,%edx
8010658d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106590:	51                   	push   %ecx
80106591:	52                   	push   %edx
80106592:	6a 03                	push   $0x3
80106594:	50                   	push   %eax
80106595:	e8 bd fb ff ff       	call   80106157 <create>
8010659a:	83 c4 10             	add    $0x10,%esp
8010659d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801065a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065a4:	75 0c                	jne    801065b2 <sys_mknod+0x7f>
    end_op();
801065a6:	e8 56 cc ff ff       	call   80103201 <end_op>
    return -1;
801065ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b0:	eb 18                	jmp    801065ca <sys_mknod+0x97>
  }
  iunlockput(ip);
801065b2:	83 ec 0c             	sub    $0xc,%esp
801065b5:	ff 75 f4             	push   -0xc(%ebp)
801065b8:	e8 fc b6 ff ff       	call   80101cb9 <iunlockput>
801065bd:	83 c4 10             	add    $0x10,%esp
  end_op();
801065c0:	e8 3c cc ff ff       	call   80103201 <end_op>
  return 0;
801065c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ca:	c9                   	leave
801065cb:	c3                   	ret

801065cc <sys_chdir>:

int
sys_chdir(void)
{
801065cc:	f3 0f 1e fb          	endbr32
801065d0:	55                   	push   %ebp
801065d1:	89 e5                	mov    %esp,%ebp
801065d3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801065d6:	e8 ce d5 ff ff       	call   80103ba9 <myproc>
801065db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801065de:	e8 8e cb ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065e3:	83 ec 08             	sub    $0x8,%esp
801065e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065e9:	50                   	push   %eax
801065ea:	6a 00                	push   $0x0
801065ec:	e8 06 f4 ff ff       	call   801059f7 <argstr>
801065f1:	83 c4 10             	add    $0x10,%esp
801065f4:	85 c0                	test   %eax,%eax
801065f6:	78 18                	js     80106610 <sys_chdir+0x44>
801065f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065fb:	83 ec 0c             	sub    $0xc,%esp
801065fe:	50                   	push   %eax
801065ff:	e8 e3 bf ff ff       	call   801025e7 <namei>
80106604:	83 c4 10             	add    $0x10,%esp
80106607:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010660a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010660e:	75 0c                	jne    8010661c <sys_chdir+0x50>
    end_op();
80106610:	e8 ec cb ff ff       	call   80103201 <end_op>
    return -1;
80106615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661a:	eb 68                	jmp    80106684 <sys_chdir+0xb8>
  }
  ilock(ip);
8010661c:	83 ec 0c             	sub    $0xc,%esp
8010661f:	ff 75 f0             	push   -0x10(%ebp)
80106622:	e8 55 b4 ff ff       	call   80101a7c <ilock>
80106627:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010662a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010662d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106631:	66 83 f8 01          	cmp    $0x1,%ax
80106635:	74 1a                	je     80106651 <sys_chdir+0x85>
    iunlockput(ip);
80106637:	83 ec 0c             	sub    $0xc,%esp
8010663a:	ff 75 f0             	push   -0x10(%ebp)
8010663d:	e8 77 b6 ff ff       	call   80101cb9 <iunlockput>
80106642:	83 c4 10             	add    $0x10,%esp
    end_op();
80106645:	e8 b7 cb ff ff       	call   80103201 <end_op>
    return -1;
8010664a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664f:	eb 33                	jmp    80106684 <sys_chdir+0xb8>
  }
  iunlock(ip);
80106651:	83 ec 0c             	sub    $0xc,%esp
80106654:	ff 75 f0             	push   -0x10(%ebp)
80106657:	e8 37 b5 ff ff       	call   80101b93 <iunlock>
8010665c:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010665f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106662:	8b 40 68             	mov    0x68(%eax),%eax
80106665:	83 ec 0c             	sub    $0xc,%esp
80106668:	50                   	push   %eax
80106669:	e8 77 b5 ff ff       	call   80101be5 <iput>
8010666e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106671:	e8 8b cb ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80106676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106679:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010667c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010667f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106684:	c9                   	leave
80106685:	c3                   	ret

80106686 <sys_exec>:

int
sys_exec(void)
{
80106686:	f3 0f 1e fb          	endbr32
8010668a:	55                   	push   %ebp
8010668b:	89 e5                	mov    %esp,%ebp
8010668d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106693:	83 ec 08             	sub    $0x8,%esp
80106696:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106699:	50                   	push   %eax
8010669a:	6a 00                	push   $0x0
8010669c:	e8 56 f3 ff ff       	call   801059f7 <argstr>
801066a1:	83 c4 10             	add    $0x10,%esp
801066a4:	85 c0                	test   %eax,%eax
801066a6:	78 18                	js     801066c0 <sys_exec+0x3a>
801066a8:	83 ec 08             	sub    $0x8,%esp
801066ab:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066b1:	50                   	push   %eax
801066b2:	6a 01                	push   $0x1
801066b4:	e8 a1 f2 ff ff       	call   8010595a <argint>
801066b9:	83 c4 10             	add    $0x10,%esp
801066bc:	85 c0                	test   %eax,%eax
801066be:	79 0a                	jns    801066ca <sys_exec+0x44>
    return -1;
801066c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c5:	e9 c6 00 00 00       	jmp    80106790 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801066ca:	83 ec 04             	sub    $0x4,%esp
801066cd:	68 80 00 00 00       	push   $0x80
801066d2:	6a 00                	push   $0x0
801066d4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066da:	50                   	push   %eax
801066db:	e8 26 ef ff ff       	call   80105606 <memset>
801066e0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801066e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ed:	83 f8 1f             	cmp    $0x1f,%eax
801066f0:	76 0a                	jbe    801066fc <sys_exec+0x76>
      return -1;
801066f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f7:	e9 94 00 00 00       	jmp    80106790 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ff:	c1 e0 02             	shl    $0x2,%eax
80106702:	89 c2                	mov    %eax,%edx
80106704:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010670a:	01 c2                	add    %eax,%edx
8010670c:	83 ec 08             	sub    $0x8,%esp
8010670f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106715:	50                   	push   %eax
80106716:	52                   	push   %edx
80106717:	e8 93 f1 ff ff       	call   801058af <fetchint>
8010671c:	83 c4 10             	add    $0x10,%esp
8010671f:	85 c0                	test   %eax,%eax
80106721:	79 07                	jns    8010672a <sys_exec+0xa4>
      return -1;
80106723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106728:	eb 66                	jmp    80106790 <sys_exec+0x10a>
    if(uarg == 0){
8010672a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106730:	85 c0                	test   %eax,%eax
80106732:	75 27                	jne    8010675b <sys_exec+0xd5>
      argv[i] = 0;
80106734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106737:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010673e:	00 00 00 00 
      break;
80106742:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106746:	83 ec 08             	sub    $0x8,%esp
80106749:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010674f:	52                   	push   %edx
80106750:	50                   	push   %eax
80106751:	e8 68 a4 ff ff       	call   80100bbe <exec>
80106756:	83 c4 10             	add    $0x10,%esp
80106759:	eb 35                	jmp    80106790 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
8010675b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106761:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106764:	c1 e2 02             	shl    $0x2,%edx
80106767:	01 c2                	add    %eax,%edx
80106769:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010676f:	83 ec 08             	sub    $0x8,%esp
80106772:	52                   	push   %edx
80106773:	50                   	push   %eax
80106774:	e8 79 f1 ff ff       	call   801058f2 <fetchstr>
80106779:	83 c4 10             	add    $0x10,%esp
8010677c:	85 c0                	test   %eax,%eax
8010677e:	79 07                	jns    80106787 <sys_exec+0x101>
      return -1;
80106780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106785:	eb 09                	jmp    80106790 <sys_exec+0x10a>
  for(i=0;; i++){
80106787:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010678b:	e9 5a ff ff ff       	jmp    801066ea <sys_exec+0x64>
}
80106790:	c9                   	leave
80106791:	c3                   	ret

80106792 <sys_pipe>:

int
sys_pipe(void)
{
80106792:	f3 0f 1e fb          	endbr32
80106796:	55                   	push   %ebp
80106797:	89 e5                	mov    %esp,%ebp
80106799:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010679c:	83 ec 04             	sub    $0x4,%esp
8010679f:	6a 08                	push   $0x8
801067a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067a4:	50                   	push   %eax
801067a5:	6a 00                	push   $0x0
801067a7:	e8 df f1 ff ff       	call   8010598b <argptr>
801067ac:	83 c4 10             	add    $0x10,%esp
801067af:	85 c0                	test   %eax,%eax
801067b1:	79 0a                	jns    801067bd <sys_pipe+0x2b>
    return -1;
801067b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b8:	e9 ae 00 00 00       	jmp    8010686b <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801067bd:	83 ec 08             	sub    $0x8,%esp
801067c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067c3:	50                   	push   %eax
801067c4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067c7:	50                   	push   %eax
801067c8:	e8 fd ce ff ff       	call   801036ca <pipealloc>
801067cd:	83 c4 10             	add    $0x10,%esp
801067d0:	85 c0                	test   %eax,%eax
801067d2:	79 0a                	jns    801067de <sys_pipe+0x4c>
    return -1;
801067d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d9:	e9 8d 00 00 00       	jmp    8010686b <sys_pipe+0xd9>
  fd0 = -1;
801067de:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067e8:	83 ec 0c             	sub    $0xc,%esp
801067eb:	50                   	push   %eax
801067ec:	e8 3b f3 ff ff       	call   80105b2c <fdalloc>
801067f1:	83 c4 10             	add    $0x10,%esp
801067f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067fb:	78 18                	js     80106815 <sys_pipe+0x83>
801067fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106800:	83 ec 0c             	sub    $0xc,%esp
80106803:	50                   	push   %eax
80106804:	e8 23 f3 ff ff       	call   80105b2c <fdalloc>
80106809:	83 c4 10             	add    $0x10,%esp
8010680c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010680f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106813:	79 3e                	jns    80106853 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106815:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106819:	78 13                	js     8010682e <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
8010681b:	e8 89 d3 ff ff       	call   80103ba9 <myproc>
80106820:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106823:	83 c2 08             	add    $0x8,%edx
80106826:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010682d:	00 
    fileclose(rf);
8010682e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106831:	83 ec 0c             	sub    $0xc,%esp
80106834:	50                   	push   %eax
80106835:	e8 af a8 ff ff       	call   801010e9 <fileclose>
8010683a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010683d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106840:	83 ec 0c             	sub    $0xc,%esp
80106843:	50                   	push   %eax
80106844:	e8 a0 a8 ff ff       	call   801010e9 <fileclose>
80106849:	83 c4 10             	add    $0x10,%esp
    return -1;
8010684c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106851:	eb 18                	jmp    8010686b <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106853:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106856:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106859:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010685b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010685e:	8d 50 04             	lea    0x4(%eax),%edx
80106861:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106864:	89 02                	mov    %eax,(%edx)
  return 0;
80106866:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010686b:	c9                   	leave
8010686c:	c3                   	ret

8010686d <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
8010686d:	f3 0f 1e fb          	endbr32
80106871:	55                   	push   %ebp
80106872:	89 e5                	mov    %esp,%ebp
80106874:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
80106877:	83 ec 04             	sub    $0x4,%esp
8010687a:	68 00 0c 00 00       	push   $0xc00
8010687f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106882:	50                   	push   %eax
80106883:	6a 00                	push   $0x0
80106885:	e8 01 f1 ff ff       	call   8010598b <argptr>
8010688a:	83 c4 10             	add    $0x10,%esp
8010688d:	85 c0                	test   %eax,%eax
8010688f:	79 07                	jns    80106898 <sys_getpinfo+0x2b>
    return -1;
80106891:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106896:	eb 0f                	jmp    801068a7 <sys_getpinfo+0x3a>
  return getpinfo(ps);
80106898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689b:	83 ec 0c             	sub    $0xc,%esp
8010689e:	50                   	push   %eax
8010689f:	e8 b6 e0 ff ff       	call   8010495a <getpinfo>
801068a4:	83 c4 10             	add    $0x10,%esp
}
801068a7:	c9                   	leave
801068a8:	c3                   	ret

801068a9 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
801068a9:	f3 0f 1e fb          	endbr32
801068ad:	55                   	push   %ebp
801068ae:	89 e5                	mov    %esp,%ebp
801068b0:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
801068b3:	83 ec 08             	sub    $0x8,%esp
801068b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068b9:	50                   	push   %eax
801068ba:	6a 00                	push   $0x0
801068bc:	e8 99 f0 ff ff       	call   8010595a <argint>
801068c1:	83 c4 10             	add    $0x10,%esp
801068c4:	85 c0                	test   %eax,%eax
801068c6:	79 07                	jns    801068cf <sys_setSchedPolicy+0x26>
    return -1;
801068c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cd:	eb 23                	jmp    801068f2 <sys_setSchedPolicy+0x49>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
801068cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d2:	83 ec 08             	sub    $0x8,%esp
801068d5:	50                   	push   %eax
801068d6:	68 14 b5 10 80       	push   $0x8010b514
801068db:	e8 2c 9b ff ff       	call   8010040c <cprintf>
801068e0:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
801068e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e6:	83 ec 0c             	sub    $0xc,%esp
801068e9:	50                   	push   %eax
801068ea:	e8 52 e2 ff ff       	call   80104b41 <set_sched_policy>
801068ef:	83 c4 10             	add    $0x10,%esp
}
801068f2:	c9                   	leave
801068f3:	c3                   	ret

801068f4 <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
801068f4:	f3 0f 1e fb          	endbr32
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
801068fb:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
801068fe:	e8 85 e2 ff ff       	call   80104b88 <get_sched_policy>
}
80106903:	c9                   	leave
80106904:	c3                   	ret

80106905 <sys_yield>:
int
sys_yield(void)
{
80106905:	f3 0f 1e fb          	endbr32
80106909:	55                   	push   %ebp
8010690a:	89 e5                	mov    %esp,%ebp
8010690c:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
8010690f:	e8 0e dd ff ff       	call   80104622 <yield>
  return 0;
80106914:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106919:	c9                   	leave
8010691a:	c3                   	ret

8010691b <sys_fork>:

int
sys_fork(void)
{
8010691b:	f3 0f 1e fb          	endbr32
8010691f:	55                   	push   %ebp
80106920:	89 e5                	mov    %esp,%ebp
80106922:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106925:	e8 4f d6 ff ff       	call   80103f79 <fork>
}
8010692a:	c9                   	leave
8010692b:	c3                   	ret

8010692c <sys_exit>:

int
sys_exit(void)
{
8010692c:	f3 0f 1e fb          	endbr32
80106930:	55                   	push   %ebp
80106931:	89 e5                	mov    %esp,%ebp
80106933:	83 ec 08             	sub    $0x8,%esp
  exit();
80106936:	e8 5c d8 ff ff       	call   80104197 <exit>
  return 0;  // not reached
8010693b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106940:	c9                   	leave
80106941:	c3                   	ret

80106942 <sys_wait>:

int
sys_wait(void)
{
80106942:	f3 0f 1e fb          	endbr32
80106946:	55                   	push   %ebp
80106947:	89 e5                	mov    %esp,%ebp
80106949:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010694c:	e8 ca d9 ff ff       	call   8010431b <wait>
}
80106951:	c9                   	leave
80106952:	c3                   	ret

80106953 <sys_kill>:

int
sys_kill(void)
{
80106953:	f3 0f 1e fb          	endbr32
80106957:	55                   	push   %ebp
80106958:	89 e5                	mov    %esp,%ebp
8010695a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010695d:	83 ec 08             	sub    $0x8,%esp
80106960:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106963:	50                   	push   %eax
80106964:	6a 00                	push   $0x0
80106966:	e8 ef ef ff ff       	call   8010595a <argint>
8010696b:	83 c4 10             	add    $0x10,%esp
8010696e:	85 c0                	test   %eax,%eax
80106970:	79 07                	jns    80106979 <sys_kill+0x26>
    return -1;
80106972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106977:	eb 0f                	jmp    80106988 <sys_kill+0x35>
  return kill(pid);
80106979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697c:	83 ec 0c             	sub    $0xc,%esp
8010697f:	50                   	push   %eax
80106980:	e8 4f de ff ff       	call   801047d4 <kill>
80106985:	83 c4 10             	add    $0x10,%esp
}
80106988:	c9                   	leave
80106989:	c3                   	ret

8010698a <sys_getpid>:

int
sys_getpid(void)
{
8010698a:	f3 0f 1e fb          	endbr32
8010698e:	55                   	push   %ebp
8010698f:	89 e5                	mov    %esp,%ebp
80106991:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106994:	e8 10 d2 ff ff       	call   80103ba9 <myproc>
80106999:	8b 40 10             	mov    0x10(%eax),%eax
}
8010699c:	c9                   	leave
8010699d:	c3                   	ret

8010699e <sys_sbrk>:

int
sys_sbrk(void)
{
8010699e:	f3 0f 1e fb          	endbr32
801069a2:	55                   	push   %ebp
801069a3:	89 e5                	mov    %esp,%ebp
801069a5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801069a8:	83 ec 08             	sub    $0x8,%esp
801069ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069ae:	50                   	push   %eax
801069af:	6a 00                	push   $0x0
801069b1:	e8 a4 ef ff ff       	call   8010595a <argint>
801069b6:	83 c4 10             	add    $0x10,%esp
801069b9:	85 c0                	test   %eax,%eax
801069bb:	79 07                	jns    801069c4 <sys_sbrk+0x26>
    return -1;
801069bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c2:	eb 27                	jmp    801069eb <sys_sbrk+0x4d>
  addr = myproc()->sz;
801069c4:	e8 e0 d1 ff ff       	call   80103ba9 <myproc>
801069c9:	8b 00                	mov    (%eax),%eax
801069cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801069ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069d1:	83 ec 0c             	sub    $0xc,%esp
801069d4:	50                   	push   %eax
801069d5:	e8 00 d5 ff ff       	call   80103eda <growproc>
801069da:	83 c4 10             	add    $0x10,%esp
801069dd:	85 c0                	test   %eax,%eax
801069df:	79 07                	jns    801069e8 <sys_sbrk+0x4a>
    return -1;
801069e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e6:	eb 03                	jmp    801069eb <sys_sbrk+0x4d>
  return addr;
801069e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069eb:	c9                   	leave
801069ec:	c3                   	ret

801069ed <sys_sleep>:

int
sys_sleep(void)
{
801069ed:	f3 0f 1e fb          	endbr32
801069f1:	55                   	push   %ebp
801069f2:	89 e5                	mov    %esp,%ebp
801069f4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801069f7:	83 ec 08             	sub    $0x8,%esp
801069fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069fd:	50                   	push   %eax
801069fe:	6a 00                	push   $0x0
80106a00:	e8 55 ef ff ff       	call   8010595a <argint>
80106a05:	83 c4 10             	add    $0x10,%esp
80106a08:	85 c0                	test   %eax,%eax
80106a0a:	79 07                	jns    80106a13 <sys_sleep+0x26>
    return -1;
80106a0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a11:	eb 76                	jmp    80106a89 <sys_sleep+0x9c>
  acquire(&tickslock);
80106a13:	83 ec 0c             	sub    $0xc,%esp
80106a16:	68 60 94 19 80       	push   $0x80199460
80106a1b:	e8 57 e9 ff ff       	call   80105377 <acquire>
80106a20:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106a23:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106a2b:	eb 38                	jmp    80106a65 <sys_sleep+0x78>
    if(myproc()->killed){
80106a2d:	e8 77 d1 ff ff       	call   80103ba9 <myproc>
80106a32:	8b 40 24             	mov    0x24(%eax),%eax
80106a35:	85 c0                	test   %eax,%eax
80106a37:	74 17                	je     80106a50 <sys_sleep+0x63>
      release(&tickslock);
80106a39:	83 ec 0c             	sub    $0xc,%esp
80106a3c:	68 60 94 19 80       	push   $0x80199460
80106a41:	e8 a3 e9 ff ff       	call   801053e9 <release>
80106a46:	83 c4 10             	add    $0x10,%esp
      return -1;
80106a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a4e:	eb 39                	jmp    80106a89 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106a50:	83 ec 08             	sub    $0x8,%esp
80106a53:	68 60 94 19 80       	push   $0x80199460
80106a58:	68 a0 9c 19 80       	push   $0x80199ca0
80106a5d:	e8 48 dc ff ff       	call   801046aa <sleep>
80106a62:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106a65:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106a6a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106a6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a70:	39 d0                	cmp    %edx,%eax
80106a72:	72 b9                	jb     80106a2d <sys_sleep+0x40>
  }
  release(&tickslock);
80106a74:	83 ec 0c             	sub    $0xc,%esp
80106a77:	68 60 94 19 80       	push   $0x80199460
80106a7c:	e8 68 e9 ff ff       	call   801053e9 <release>
80106a81:	83 c4 10             	add    $0x10,%esp
  return 0;
80106a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a89:	c9                   	leave
80106a8a:	c3                   	ret

80106a8b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106a8b:	f3 0f 1e fb          	endbr32
80106a8f:	55                   	push   %ebp
80106a90:	89 e5                	mov    %esp,%ebp
80106a92:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106a95:	83 ec 0c             	sub    $0xc,%esp
80106a98:	68 60 94 19 80       	push   $0x80199460
80106a9d:	e8 d5 e8 ff ff       	call   80105377 <acquire>
80106aa2:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106aa5:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106aad:	83 ec 0c             	sub    $0xc,%esp
80106ab0:	68 60 94 19 80       	push   $0x80199460
80106ab5:	e8 2f e9 ff ff       	call   801053e9 <release>
80106aba:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ac0:	c9                   	leave
80106ac1:	c3                   	ret

80106ac2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ac2:	1e                   	push   %ds
  pushl %es
80106ac3:	06                   	push   %es
  pushl %fs
80106ac4:	0f a0                	push   %fs
  pushl %gs
80106ac6:	0f a8                	push   %gs
  pushal
80106ac8:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ac9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106acd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106acf:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106ad1:	54                   	push   %esp
  call trap
80106ad2:	e8 df 01 00 00       	call   80106cb6 <trap>
  addl $4, %esp
80106ad7:	83 c4 04             	add    $0x4,%esp

80106ada <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ada:	61                   	popa
  popl %gs
80106adb:	0f a9                	pop    %gs
  popl %fs
80106add:	0f a1                	pop    %fs
  popl %es
80106adf:	07                   	pop    %es
  popl %ds
80106ae0:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ae1:	83 c4 08             	add    $0x8,%esp
  iret
80106ae4:	cf                   	iret

80106ae5 <lidt>:
{
80106ae5:	55                   	push   %ebp
80106ae6:	89 e5                	mov    %esp,%ebp
80106ae8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aee:	83 e8 01             	sub    $0x1,%eax
80106af1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106af5:	8b 45 08             	mov    0x8(%ebp),%eax
80106af8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106afc:	8b 45 08             	mov    0x8(%ebp),%eax
80106aff:	c1 e8 10             	shr    $0x10,%eax
80106b02:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b06:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b09:	0f 01 18             	lidtl  (%eax)
}
80106b0c:	90                   	nop
80106b0d:	c9                   	leave
80106b0e:	c3                   	ret

80106b0f <rcr2>:

static inline uint
rcr2(void)
{
80106b0f:	55                   	push   %ebp
80106b10:	89 e5                	mov    %esp,%ebp
80106b12:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b15:	0f 20 d0             	mov    %cr2,%eax
80106b18:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b1e:	c9                   	leave
80106b1f:	c3                   	ret

80106b20 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b20:	f3 0f 1e fb          	endbr32
80106b24:	55                   	push   %ebp
80106b25:	89 e5                	mov    %esp,%ebp
80106b27:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b31:	e9 c3 00 00 00       	jmp    80106bf9 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b39:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106b40:	89 c2                	mov    %eax,%edx
80106b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b45:	66 89 14 c5 a0 94 19 	mov    %dx,-0x7fe66b60(,%eax,8)
80106b4c:	80 
80106b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b50:	66 c7 04 c5 a2 94 19 	movw   $0x8,-0x7fe66b5e(,%eax,8)
80106b57:	80 08 00 
80106b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5d:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b64:	80 
80106b65:	83 e2 e0             	and    $0xffffffe0,%edx
80106b68:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b72:	0f b6 14 c5 a4 94 19 	movzbl -0x7fe66b5c(,%eax,8),%edx
80106b79:	80 
80106b7a:	83 e2 1f             	and    $0x1f,%edx
80106b7d:	88 14 c5 a4 94 19 80 	mov    %dl,-0x7fe66b5c(,%eax,8)
80106b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b87:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106b8e:	80 
80106b8f:	83 e2 f0             	and    $0xfffffff0,%edx
80106b92:	83 ca 0e             	or     $0xe,%edx
80106b95:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9f:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106ba6:	80 
80106ba7:	83 e2 ef             	and    $0xffffffef,%edx
80106baa:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb4:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106bbb:	80 
80106bbc:	83 e2 9f             	and    $0xffffff9f,%edx
80106bbf:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc9:	0f b6 14 c5 a5 94 19 	movzbl -0x7fe66b5b(,%eax,8),%edx
80106bd0:	80 
80106bd1:	83 ca 80             	or     $0xffffff80,%edx
80106bd4:	88 14 c5 a5 94 19 80 	mov    %dl,-0x7fe66b5b(,%eax,8)
80106bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bde:	8b 04 85 88 00 11 80 	mov    -0x7feeff78(,%eax,4),%eax
80106be5:	c1 e8 10             	shr    $0x10,%eax
80106be8:	89 c2                	mov    %eax,%edx
80106bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bed:	66 89 14 c5 a6 94 19 	mov    %dx,-0x7fe66b5a(,%eax,8)
80106bf4:	80 
  for(i = 0; i < 256; i++)
80106bf5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bf9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c00:	0f 8e 30 ff ff ff    	jle    80106b36 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c06:	a1 88 01 11 80       	mov    0x80110188,%eax
80106c0b:	66 a3 a0 96 19 80    	mov    %ax,0x801996a0
80106c11:	66 c7 05 a2 96 19 80 	movw   $0x8,0x801996a2
80106c18:	08 00 
80106c1a:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106c21:	83 e0 e0             	and    $0xffffffe0,%eax
80106c24:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106c29:	0f b6 05 a4 96 19 80 	movzbl 0x801996a4,%eax
80106c30:	83 e0 1f             	and    $0x1f,%eax
80106c33:	a2 a4 96 19 80       	mov    %al,0x801996a4
80106c38:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c3f:	83 c8 0f             	or     $0xf,%eax
80106c42:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c47:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c4e:	83 e0 ef             	and    $0xffffffef,%eax
80106c51:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c56:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c5d:	83 c8 60             	or     $0x60,%eax
80106c60:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c65:	0f b6 05 a5 96 19 80 	movzbl 0x801996a5,%eax
80106c6c:	83 c8 80             	or     $0xffffff80,%eax
80106c6f:	a2 a5 96 19 80       	mov    %al,0x801996a5
80106c74:	a1 88 01 11 80       	mov    0x80110188,%eax
80106c79:	c1 e8 10             	shr    $0x10,%eax
80106c7c:	66 a3 a6 96 19 80    	mov    %ax,0x801996a6

  initlock(&tickslock, "time");
80106c82:	83 ec 08             	sub    $0x8,%esp
80106c85:	68 40 b5 10 80       	push   $0x8010b540
80106c8a:	68 60 94 19 80       	push   $0x80199460
80106c8f:	e8 bd e6 ff ff       	call   80105351 <initlock>
80106c94:	83 c4 10             	add    $0x10,%esp
}
80106c97:	90                   	nop
80106c98:	c9                   	leave
80106c99:	c3                   	ret

80106c9a <idtinit>:

void
idtinit(void)
{
80106c9a:	f3 0f 1e fb          	endbr32
80106c9e:	55                   	push   %ebp
80106c9f:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106ca1:	68 00 08 00 00       	push   $0x800
80106ca6:	68 a0 94 19 80       	push   $0x801994a0
80106cab:	e8 35 fe ff ff       	call   80106ae5 <lidt>
80106cb0:	83 c4 08             	add    $0x8,%esp
}
80106cb3:	90                   	nop
80106cb4:	c9                   	leave
80106cb5:	c3                   	ret

80106cb6 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cb6:	f3 0f 1e fb          	endbr32
80106cba:	55                   	push   %ebp
80106cbb:	89 e5                	mov    %esp,%ebp
80106cbd:	57                   	push   %edi
80106cbe:	56                   	push   %esi
80106cbf:	53                   	push   %ebx
80106cc0:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc6:	8b 40 30             	mov    0x30(%eax),%eax
80106cc9:	83 f8 40             	cmp    $0x40,%eax
80106ccc:	75 3b                	jne    80106d09 <trap+0x53>
    if(myproc()->killed)
80106cce:	e8 d6 ce ff ff       	call   80103ba9 <myproc>
80106cd3:	8b 40 24             	mov    0x24(%eax),%eax
80106cd6:	85 c0                	test   %eax,%eax
80106cd8:	74 05                	je     80106cdf <trap+0x29>
      exit();
80106cda:	e8 b8 d4 ff ff       	call   80104197 <exit>
    myproc()->tf = tf;
80106cdf:	e8 c5 ce ff ff       	call   80103ba9 <myproc>
80106ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80106ce7:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cea:	e8 43 ed ff ff       	call   80105a32 <syscall>
    if(myproc()->killed)
80106cef:	e8 b5 ce ff ff       	call   80103ba9 <myproc>
80106cf4:	8b 40 24             	mov    0x24(%eax),%eax
80106cf7:	85 c0                	test   %eax,%eax
80106cf9:	0f 84 3f 03 00 00    	je     8010703e <trap+0x388>
      exit();
80106cff:	e8 93 d4 ff ff       	call   80104197 <exit>
    return;
80106d04:	e9 35 03 00 00       	jmp    8010703e <trap+0x388>
  }

  switch(tf->trapno){
80106d09:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0c:	8b 40 30             	mov    0x30(%eax),%eax
80106d0f:	83 e8 20             	sub    $0x20,%eax
80106d12:	83 f8 1f             	cmp    $0x1f,%eax
80106d15:	0f 87 ee 01 00 00    	ja     80106f09 <trap+0x253>
80106d1b:	8b 04 85 14 b6 10 80 	mov    -0x7fef49ec(,%eax,4),%eax
80106d22:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d25:	e8 e4 cd ff ff       	call   80103b0e <cpuid>
80106d2a:	85 c0                	test   %eax,%eax
80106d2c:	75 3d                	jne    80106d6b <trap+0xb5>
      acquire(&tickslock);
80106d2e:	83 ec 0c             	sub    $0xc,%esp
80106d31:	68 60 94 19 80       	push   $0x80199460
80106d36:	e8 3c e6 ff ff       	call   80105377 <acquire>
80106d3b:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d3e:	a1 a0 9c 19 80       	mov    0x80199ca0,%eax
80106d43:	83 c0 01             	add    $0x1,%eax
80106d46:	a3 a0 9c 19 80       	mov    %eax,0x80199ca0
      wakeup(&ticks);
80106d4b:	83 ec 0c             	sub    $0xc,%esp
80106d4e:	68 a0 9c 19 80       	push   $0x80199ca0
80106d53:	e8 41 da ff ff       	call   80104799 <wakeup>
80106d58:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d5b:	83 ec 0c             	sub    $0xc,%esp
80106d5e:	68 60 94 19 80       	push   $0x80199460
80106d63:	e8 81 e6 ff ff       	call   801053e9 <release>
80106d68:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106d6b:	e8 39 ce ff ff       	call   80103ba9 <myproc>
80106d70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106d73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106d77:	0f 84 17 01 00 00    	je     80106e94 <trap+0x1de>
80106d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d80:	8b 40 0c             	mov    0xc(%eax),%eax
80106d83:	83 f8 04             	cmp    $0x4,%eax
80106d86:	0f 85 08 01 00 00    	jne    80106e94 <trap+0x1de>
80106d8c:	e8 9c cd ff ff       	call   80103b2d <mycpu>
80106d91:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106d97:	85 c0                	test   %eax,%eax
80106d99:	0f 84 f5 00 00 00    	je     80106e94 <trap+0x1de>
      int idx = myproc() - ptable.proc;
80106d9f:	e8 05 ce ff ff       	call   80103ba9 <myproc>
80106da4:	2d 54 75 19 80       	sub    $0x80197554,%eax
80106da9:	c1 f8 02             	sar    $0x2,%eax
80106dac:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106db2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106db8:	83 e8 80             	sub    $0xffffff80,%eax
80106dbb:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106dc2:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106dc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106dcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106dd2:	01 d0                	add    %edx,%eax
80106dd4:	05 00 01 00 00       	add    $0x100,%eax
80106dd9:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106de0:	8d 50 01             	lea    0x1(%eax),%edx
80106de3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106de6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106ded:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106df0:	01 c8                	add    %ecx,%eax
80106df2:	05 00 01 00 00       	add    $0x100,%eax
80106df7:	89 14 85 20 69 19 80 	mov    %edx,-0x7fe696e0(,%eax,4)
      kernel_pstat.wait_ticks[idx][q] = 0; // 실행된 큐의 wait_ticks 초기화화
80106dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e0b:	01 d0                	add    %edx,%eax
80106e0d:	05 00 02 00 00       	add    $0x200,%eax
80106e12:	c7 04 85 20 69 19 80 	movl   $0x0,-0x7fe696e0(,%eax,4)
80106e19:	00 00 00 00 

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e2a:	01 d0                	add    %edx,%eax
80106e2c:	05 00 01 00 00       	add    $0x100,%eax
80106e31:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106e38:	83 f8 01             	cmp    $0x1,%eax
80106e3b:	74 22                	je     80106e5f <trap+0x1a9>
80106e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e4a:	01 d0                	add    %edx,%eax
80106e4c:	05 00 01 00 00       	add    $0x100,%eax
80106e51:	8b 04 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%eax
80106e58:	83 e0 07             	and    $0x7,%eax
80106e5b:	85 c0                	test   %eax,%eax
80106e5d:	75 35                	jne    80106e94 <trap+0x1de>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e62:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106e69:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106e6c:	01 d0                	add    %edx,%eax
80106e6e:	05 00 01 00 00       	add    $0x100,%eax
80106e73:	8b 1c 85 20 69 19 80 	mov    -0x7fe696e0(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106e7a:	e8 2a cd ff ff       	call   80103ba9 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106e7f:	8b 40 10             	mov    0x10(%eax),%eax
80106e82:	53                   	push   %ebx
80106e83:	ff 75 dc             	push   -0x24(%ebp)
80106e86:	50                   	push   %eax
80106e87:	68 48 b5 10 80       	push   $0x8010b548
80106e8c:	e8 7b 95 ff ff       	call   8010040c <cprintf>
80106e91:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106e94:	e8 8c bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e99:	e9 20 01 00 00       	jmp    80106fbe <trap+0x308>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e9e:	e8 1a 40 00 00       	call   8010aebd <ideintr>
    lapiceoi();
80106ea3:	e8 7d bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106ea8:	e9 11 01 00 00       	jmp    80106fbe <trap+0x308>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106ead:	e8 a9 bb ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106eb2:	e8 6e bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106eb7:	e9 02 01 00 00       	jmp    80106fbe <trap+0x308>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ebc:	e8 5f 03 00 00       	call   80107220 <uartintr>
    lapiceoi();
80106ec1:	e8 5f bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106ec6:	e9 f3 00 00 00       	jmp    80106fbe <trap+0x308>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106ecb:	e8 2c 2c 00 00       	call   80109afc <i8254_intr>
    lapiceoi();
80106ed0:	e8 50 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106ed5:	e9 e4 00 00 00       	jmp    80106fbe <trap+0x308>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106eda:	8b 45 08             	mov    0x8(%ebp),%eax
80106edd:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ee7:	0f b7 d8             	movzwl %ax,%ebx
80106eea:	e8 1f cc ff ff       	call   80103b0e <cpuid>
80106eef:	56                   	push   %esi
80106ef0:	53                   	push   %ebx
80106ef1:	50                   	push   %eax
80106ef2:	68 74 b5 10 80       	push   $0x8010b574
80106ef7:	e8 10 95 ff ff       	call   8010040c <cprintf>
80106efc:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106eff:	e8 21 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106f04:	e9 b5 00 00 00       	jmp    80106fbe <trap+0x308>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106f09:	e8 9b cc ff ff       	call   80103ba9 <myproc>
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	74 11                	je     80106f23 <trap+0x26d>
80106f12:	8b 45 08             	mov    0x8(%ebp),%eax
80106f15:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f19:	0f b7 c0             	movzwl %ax,%eax
80106f1c:	83 e0 03             	and    $0x3,%eax
80106f1f:	85 c0                	test   %eax,%eax
80106f21:	75 39                	jne    80106f5c <trap+0x2a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106f23:	e8 e7 fb ff ff       	call   80106b0f <rcr2>
80106f28:	89 c3                	mov    %eax,%ebx
80106f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2d:	8b 70 38             	mov    0x38(%eax),%esi
80106f30:	e8 d9 cb ff ff       	call   80103b0e <cpuid>
80106f35:	8b 55 08             	mov    0x8(%ebp),%edx
80106f38:	8b 52 30             	mov    0x30(%edx),%edx
80106f3b:	83 ec 0c             	sub    $0xc,%esp
80106f3e:	53                   	push   %ebx
80106f3f:	56                   	push   %esi
80106f40:	50                   	push   %eax
80106f41:	52                   	push   %edx
80106f42:	68 98 b5 10 80       	push   $0x8010b598
80106f47:	e8 c0 94 ff ff       	call   8010040c <cprintf>
80106f4c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106f4f:	83 ec 0c             	sub    $0xc,%esp
80106f52:	68 ca b5 10 80       	push   $0x8010b5ca
80106f57:	e8 69 96 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f5c:	e8 ae fb ff ff       	call   80106b0f <rcr2>
80106f61:	89 c6                	mov    %eax,%esi
80106f63:	8b 45 08             	mov    0x8(%ebp),%eax
80106f66:	8b 40 38             	mov    0x38(%eax),%eax
80106f69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106f6c:	e8 9d cb ff ff       	call   80103b0e <cpuid>
80106f71:	89 c3                	mov    %eax,%ebx
80106f73:	8b 45 08             	mov    0x8(%ebp),%eax
80106f76:	8b 48 34             	mov    0x34(%eax),%ecx
80106f79:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7f:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106f82:	e8 22 cc ff ff       	call   80103ba9 <myproc>
80106f87:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f8a:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106f8d:	e8 17 cc ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f92:	8b 40 10             	mov    0x10(%eax),%eax
80106f95:	56                   	push   %esi
80106f96:	ff 75 d4             	push   -0x2c(%ebp)
80106f99:	53                   	push   %ebx
80106f9a:	ff 75 d0             	push   -0x30(%ebp)
80106f9d:	57                   	push   %edi
80106f9e:	ff 75 cc             	push   -0x34(%ebp)
80106fa1:	50                   	push   %eax
80106fa2:	68 d0 b5 10 80       	push   $0x8010b5d0
80106fa7:	e8 60 94 ff ff       	call   8010040c <cprintf>
80106fac:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106faf:	e8 f5 cb ff ff       	call   80103ba9 <myproc>
80106fb4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106fbb:	eb 01                	jmp    80106fbe <trap+0x308>
    break;
80106fbd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106fbe:	e8 e6 cb ff ff       	call   80103ba9 <myproc>
80106fc3:	85 c0                	test   %eax,%eax
80106fc5:	74 23                	je     80106fea <trap+0x334>
80106fc7:	e8 dd cb ff ff       	call   80103ba9 <myproc>
80106fcc:	8b 40 24             	mov    0x24(%eax),%eax
80106fcf:	85 c0                	test   %eax,%eax
80106fd1:	74 17                	je     80106fea <trap+0x334>
80106fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fda:	0f b7 c0             	movzwl %ax,%eax
80106fdd:	83 e0 03             	and    $0x3,%eax
80106fe0:	83 f8 03             	cmp    $0x3,%eax
80106fe3:	75 05                	jne    80106fea <trap+0x334>
    exit();
80106fe5:	e8 ad d1 ff ff       	call   80104197 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106fea:	e8 ba cb ff ff       	call   80103ba9 <myproc>
80106fef:	85 c0                	test   %eax,%eax
80106ff1:	74 1d                	je     80107010 <trap+0x35a>
80106ff3:	e8 b1 cb ff ff       	call   80103ba9 <myproc>
80106ff8:	8b 40 0c             	mov    0xc(%eax),%eax
80106ffb:	83 f8 04             	cmp    $0x4,%eax
80106ffe:	75 10                	jne    80107010 <trap+0x35a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107000:	8b 45 08             	mov    0x8(%ebp),%eax
80107003:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80107006:	83 f8 20             	cmp    $0x20,%eax
80107009:	75 05                	jne    80107010 <trap+0x35a>
    yield();
8010700b:	e8 12 d6 ff ff       	call   80104622 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107010:	e8 94 cb ff ff       	call   80103ba9 <myproc>
80107015:	85 c0                	test   %eax,%eax
80107017:	74 26                	je     8010703f <trap+0x389>
80107019:	e8 8b cb ff ff       	call   80103ba9 <myproc>
8010701e:	8b 40 24             	mov    0x24(%eax),%eax
80107021:	85 c0                	test   %eax,%eax
80107023:	74 1a                	je     8010703f <trap+0x389>
80107025:	8b 45 08             	mov    0x8(%ebp),%eax
80107028:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010702c:	0f b7 c0             	movzwl %ax,%eax
8010702f:	83 e0 03             	and    $0x3,%eax
80107032:	83 f8 03             	cmp    $0x3,%eax
80107035:	75 08                	jne    8010703f <trap+0x389>
    exit();
80107037:	e8 5b d1 ff ff       	call   80104197 <exit>
8010703c:	eb 01                	jmp    8010703f <trap+0x389>
    return;
8010703e:	90                   	nop
}
8010703f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107042:	5b                   	pop    %ebx
80107043:	5e                   	pop    %esi
80107044:	5f                   	pop    %edi
80107045:	5d                   	pop    %ebp
80107046:	c3                   	ret

80107047 <inb>:
{
80107047:	55                   	push   %ebp
80107048:	89 e5                	mov    %esp,%ebp
8010704a:	83 ec 14             	sub    $0x14,%esp
8010704d:	8b 45 08             	mov    0x8(%ebp),%eax
80107050:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107054:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107058:	89 c2                	mov    %eax,%edx
8010705a:	ec                   	in     (%dx),%al
8010705b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010705e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107062:	c9                   	leave
80107063:	c3                   	ret

80107064 <outb>:
{
80107064:	55                   	push   %ebp
80107065:	89 e5                	mov    %esp,%ebp
80107067:	83 ec 08             	sub    $0x8,%esp
8010706a:	8b 45 08             	mov    0x8(%ebp),%eax
8010706d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107070:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107074:	89 d0                	mov    %edx,%eax
80107076:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107079:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010707d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107081:	ee                   	out    %al,(%dx)
}
80107082:	90                   	nop
80107083:	c9                   	leave
80107084:	c3                   	ret

80107085 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107085:	f3 0f 1e fb          	endbr32
80107089:	55                   	push   %ebp
8010708a:	89 e5                	mov    %esp,%ebp
8010708c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010708f:	6a 00                	push   $0x0
80107091:	68 fa 03 00 00       	push   $0x3fa
80107096:	e8 c9 ff ff ff       	call   80107064 <outb>
8010709b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010709e:	68 80 00 00 00       	push   $0x80
801070a3:	68 fb 03 00 00       	push   $0x3fb
801070a8:	e8 b7 ff ff ff       	call   80107064 <outb>
801070ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801070b0:	6a 0c                	push   $0xc
801070b2:	68 f8 03 00 00       	push   $0x3f8
801070b7:	e8 a8 ff ff ff       	call   80107064 <outb>
801070bc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801070bf:	6a 00                	push   $0x0
801070c1:	68 f9 03 00 00       	push   $0x3f9
801070c6:	e8 99 ff ff ff       	call   80107064 <outb>
801070cb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801070ce:	6a 03                	push   $0x3
801070d0:	68 fb 03 00 00       	push   $0x3fb
801070d5:	e8 8a ff ff ff       	call   80107064 <outb>
801070da:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801070dd:	6a 00                	push   $0x0
801070df:	68 fc 03 00 00       	push   $0x3fc
801070e4:	e8 7b ff ff ff       	call   80107064 <outb>
801070e9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070ec:	6a 01                	push   $0x1
801070ee:	68 f9 03 00 00       	push   $0x3f9
801070f3:	e8 6c ff ff ff       	call   80107064 <outb>
801070f8:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070fb:	68 fd 03 00 00       	push   $0x3fd
80107100:	e8 42 ff ff ff       	call   80107047 <inb>
80107105:	83 c4 04             	add    $0x4,%esp
80107108:	3c ff                	cmp    $0xff,%al
8010710a:	74 61                	je     8010716d <uartinit+0xe8>
    return;
  uart = 1;
8010710c:	c7 05 80 e0 18 80 01 	movl   $0x1,0x8018e080
80107113:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107116:	68 fa 03 00 00       	push   $0x3fa
8010711b:	e8 27 ff ff ff       	call   80107047 <inb>
80107120:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107123:	68 f8 03 00 00       	push   $0x3f8
80107128:	e8 1a ff ff ff       	call   80107047 <inb>
8010712d:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107130:	83 ec 08             	sub    $0x8,%esp
80107133:	6a 00                	push   $0x0
80107135:	6a 04                	push   $0x4
80107137:	e8 d0 b5 ff ff       	call   8010270c <ioapicenable>
8010713c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010713f:	c7 45 f4 94 b6 10 80 	movl   $0x8010b694,-0xc(%ebp)
80107146:	eb 19                	jmp    80107161 <uartinit+0xdc>
    uartputc(*p);
80107148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714b:	0f b6 00             	movzbl (%eax),%eax
8010714e:	0f be c0             	movsbl %al,%eax
80107151:	83 ec 0c             	sub    $0xc,%esp
80107154:	50                   	push   %eax
80107155:	e8 16 00 00 00       	call   80107170 <uartputc>
8010715a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010715d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107164:	0f b6 00             	movzbl (%eax),%eax
80107167:	84 c0                	test   %al,%al
80107169:	75 dd                	jne    80107148 <uartinit+0xc3>
8010716b:	eb 01                	jmp    8010716e <uartinit+0xe9>
    return;
8010716d:	90                   	nop
}
8010716e:	c9                   	leave
8010716f:	c3                   	ret

80107170 <uartputc>:

void
uartputc(int c)
{
80107170:	f3 0f 1e fb          	endbr32
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010717a:	a1 80 e0 18 80       	mov    0x8018e080,%eax
8010717f:	85 c0                	test   %eax,%eax
80107181:	74 53                	je     801071d6 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010718a:	eb 11                	jmp    8010719d <uartputc+0x2d>
    microdelay(10);
8010718c:	83 ec 0c             	sub    $0xc,%esp
8010718f:	6a 0a                	push   $0xa
80107191:	e8 ae ba ff ff       	call   80102c44 <microdelay>
80107196:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107199:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010719d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801071a1:	7f 1a                	jg     801071bd <uartputc+0x4d>
801071a3:	83 ec 0c             	sub    $0xc,%esp
801071a6:	68 fd 03 00 00       	push   $0x3fd
801071ab:	e8 97 fe ff ff       	call   80107047 <inb>
801071b0:	83 c4 10             	add    $0x10,%esp
801071b3:	0f b6 c0             	movzbl %al,%eax
801071b6:	83 e0 20             	and    $0x20,%eax
801071b9:	85 c0                	test   %eax,%eax
801071bb:	74 cf                	je     8010718c <uartputc+0x1c>
  outb(COM1+0, c);
801071bd:	8b 45 08             	mov    0x8(%ebp),%eax
801071c0:	0f b6 c0             	movzbl %al,%eax
801071c3:	83 ec 08             	sub    $0x8,%esp
801071c6:	50                   	push   %eax
801071c7:	68 f8 03 00 00       	push   $0x3f8
801071cc:	e8 93 fe ff ff       	call   80107064 <outb>
801071d1:	83 c4 10             	add    $0x10,%esp
801071d4:	eb 01                	jmp    801071d7 <uartputc+0x67>
    return;
801071d6:	90                   	nop
}
801071d7:	c9                   	leave
801071d8:	c3                   	ret

801071d9 <uartgetc>:

static int
uartgetc(void)
{
801071d9:	f3 0f 1e fb          	endbr32
801071dd:	55                   	push   %ebp
801071de:	89 e5                	mov    %esp,%ebp
  if(!uart)
801071e0:	a1 80 e0 18 80       	mov    0x8018e080,%eax
801071e5:	85 c0                	test   %eax,%eax
801071e7:	75 07                	jne    801071f0 <uartgetc+0x17>
    return -1;
801071e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ee:	eb 2e                	jmp    8010721e <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801071f0:	68 fd 03 00 00       	push   $0x3fd
801071f5:	e8 4d fe ff ff       	call   80107047 <inb>
801071fa:	83 c4 04             	add    $0x4,%esp
801071fd:	0f b6 c0             	movzbl %al,%eax
80107200:	83 e0 01             	and    $0x1,%eax
80107203:	85 c0                	test   %eax,%eax
80107205:	75 07                	jne    8010720e <uartgetc+0x35>
    return -1;
80107207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010720c:	eb 10                	jmp    8010721e <uartgetc+0x45>
  return inb(COM1+0);
8010720e:	68 f8 03 00 00       	push   $0x3f8
80107213:	e8 2f fe ff ff       	call   80107047 <inb>
80107218:	83 c4 04             	add    $0x4,%esp
8010721b:	0f b6 c0             	movzbl %al,%eax
}
8010721e:	c9                   	leave
8010721f:	c3                   	ret

80107220 <uartintr>:

void
uartintr(void)
{
80107220:	f3 0f 1e fb          	endbr32
80107224:	55                   	push   %ebp
80107225:	89 e5                	mov    %esp,%ebp
80107227:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010722a:	83 ec 0c             	sub    $0xc,%esp
8010722d:	68 d9 71 10 80       	push   $0x801071d9
80107232:	e8 c9 95 ff ff       	call   80100800 <consoleintr>
80107237:	83 c4 10             	add    $0x10,%esp
}
8010723a:	90                   	nop
8010723b:	c9                   	leave
8010723c:	c3                   	ret

8010723d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $0
8010723f:	6a 00                	push   $0x0
  jmp alltraps
80107241:	e9 7c f8 ff ff       	jmp    80106ac2 <alltraps>

80107246 <vector1>:
.globl vector1
vector1:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $1
80107248:	6a 01                	push   $0x1
  jmp alltraps
8010724a:	e9 73 f8 ff ff       	jmp    80106ac2 <alltraps>

8010724f <vector2>:
.globl vector2
vector2:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $2
80107251:	6a 02                	push   $0x2
  jmp alltraps
80107253:	e9 6a f8 ff ff       	jmp    80106ac2 <alltraps>

80107258 <vector3>:
.globl vector3
vector3:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $3
8010725a:	6a 03                	push   $0x3
  jmp alltraps
8010725c:	e9 61 f8 ff ff       	jmp    80106ac2 <alltraps>

80107261 <vector4>:
.globl vector4
vector4:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $4
80107263:	6a 04                	push   $0x4
  jmp alltraps
80107265:	e9 58 f8 ff ff       	jmp    80106ac2 <alltraps>

8010726a <vector5>:
.globl vector5
vector5:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $5
8010726c:	6a 05                	push   $0x5
  jmp alltraps
8010726e:	e9 4f f8 ff ff       	jmp    80106ac2 <alltraps>

80107273 <vector6>:
.globl vector6
vector6:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $6
80107275:	6a 06                	push   $0x6
  jmp alltraps
80107277:	e9 46 f8 ff ff       	jmp    80106ac2 <alltraps>

8010727c <vector7>:
.globl vector7
vector7:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $7
8010727e:	6a 07                	push   $0x7
  jmp alltraps
80107280:	e9 3d f8 ff ff       	jmp    80106ac2 <alltraps>

80107285 <vector8>:
.globl vector8
vector8:
  pushl $8
80107285:	6a 08                	push   $0x8
  jmp alltraps
80107287:	e9 36 f8 ff ff       	jmp    80106ac2 <alltraps>

8010728c <vector9>:
.globl vector9
vector9:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $9
8010728e:	6a 09                	push   $0x9
  jmp alltraps
80107290:	e9 2d f8 ff ff       	jmp    80106ac2 <alltraps>

80107295 <vector10>:
.globl vector10
vector10:
  pushl $10
80107295:	6a 0a                	push   $0xa
  jmp alltraps
80107297:	e9 26 f8 ff ff       	jmp    80106ac2 <alltraps>

8010729c <vector11>:
.globl vector11
vector11:
  pushl $11
8010729c:	6a 0b                	push   $0xb
  jmp alltraps
8010729e:	e9 1f f8 ff ff       	jmp    80106ac2 <alltraps>

801072a3 <vector12>:
.globl vector12
vector12:
  pushl $12
801072a3:	6a 0c                	push   $0xc
  jmp alltraps
801072a5:	e9 18 f8 ff ff       	jmp    80106ac2 <alltraps>

801072aa <vector13>:
.globl vector13
vector13:
  pushl $13
801072aa:	6a 0d                	push   $0xd
  jmp alltraps
801072ac:	e9 11 f8 ff ff       	jmp    80106ac2 <alltraps>

801072b1 <vector14>:
.globl vector14
vector14:
  pushl $14
801072b1:	6a 0e                	push   $0xe
  jmp alltraps
801072b3:	e9 0a f8 ff ff       	jmp    80106ac2 <alltraps>

801072b8 <vector15>:
.globl vector15
vector15:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $15
801072ba:	6a 0f                	push   $0xf
  jmp alltraps
801072bc:	e9 01 f8 ff ff       	jmp    80106ac2 <alltraps>

801072c1 <vector16>:
.globl vector16
vector16:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $16
801072c3:	6a 10                	push   $0x10
  jmp alltraps
801072c5:	e9 f8 f7 ff ff       	jmp    80106ac2 <alltraps>

801072ca <vector17>:
.globl vector17
vector17:
  pushl $17
801072ca:	6a 11                	push   $0x11
  jmp alltraps
801072cc:	e9 f1 f7 ff ff       	jmp    80106ac2 <alltraps>

801072d1 <vector18>:
.globl vector18
vector18:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $18
801072d3:	6a 12                	push   $0x12
  jmp alltraps
801072d5:	e9 e8 f7 ff ff       	jmp    80106ac2 <alltraps>

801072da <vector19>:
.globl vector19
vector19:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $19
801072dc:	6a 13                	push   $0x13
  jmp alltraps
801072de:	e9 df f7 ff ff       	jmp    80106ac2 <alltraps>

801072e3 <vector20>:
.globl vector20
vector20:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $20
801072e5:	6a 14                	push   $0x14
  jmp alltraps
801072e7:	e9 d6 f7 ff ff       	jmp    80106ac2 <alltraps>

801072ec <vector21>:
.globl vector21
vector21:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $21
801072ee:	6a 15                	push   $0x15
  jmp alltraps
801072f0:	e9 cd f7 ff ff       	jmp    80106ac2 <alltraps>

801072f5 <vector22>:
.globl vector22
vector22:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $22
801072f7:	6a 16                	push   $0x16
  jmp alltraps
801072f9:	e9 c4 f7 ff ff       	jmp    80106ac2 <alltraps>

801072fe <vector23>:
.globl vector23
vector23:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $23
80107300:	6a 17                	push   $0x17
  jmp alltraps
80107302:	e9 bb f7 ff ff       	jmp    80106ac2 <alltraps>

80107307 <vector24>:
.globl vector24
vector24:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $24
80107309:	6a 18                	push   $0x18
  jmp alltraps
8010730b:	e9 b2 f7 ff ff       	jmp    80106ac2 <alltraps>

80107310 <vector25>:
.globl vector25
vector25:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $25
80107312:	6a 19                	push   $0x19
  jmp alltraps
80107314:	e9 a9 f7 ff ff       	jmp    80106ac2 <alltraps>

80107319 <vector26>:
.globl vector26
vector26:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $26
8010731b:	6a 1a                	push   $0x1a
  jmp alltraps
8010731d:	e9 a0 f7 ff ff       	jmp    80106ac2 <alltraps>

80107322 <vector27>:
.globl vector27
vector27:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $27
80107324:	6a 1b                	push   $0x1b
  jmp alltraps
80107326:	e9 97 f7 ff ff       	jmp    80106ac2 <alltraps>

8010732b <vector28>:
.globl vector28
vector28:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $28
8010732d:	6a 1c                	push   $0x1c
  jmp alltraps
8010732f:	e9 8e f7 ff ff       	jmp    80106ac2 <alltraps>

80107334 <vector29>:
.globl vector29
vector29:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $29
80107336:	6a 1d                	push   $0x1d
  jmp alltraps
80107338:	e9 85 f7 ff ff       	jmp    80106ac2 <alltraps>

8010733d <vector30>:
.globl vector30
vector30:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $30
8010733f:	6a 1e                	push   $0x1e
  jmp alltraps
80107341:	e9 7c f7 ff ff       	jmp    80106ac2 <alltraps>

80107346 <vector31>:
.globl vector31
vector31:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $31
80107348:	6a 1f                	push   $0x1f
  jmp alltraps
8010734a:	e9 73 f7 ff ff       	jmp    80106ac2 <alltraps>

8010734f <vector32>:
.globl vector32
vector32:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $32
80107351:	6a 20                	push   $0x20
  jmp alltraps
80107353:	e9 6a f7 ff ff       	jmp    80106ac2 <alltraps>

80107358 <vector33>:
.globl vector33
vector33:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $33
8010735a:	6a 21                	push   $0x21
  jmp alltraps
8010735c:	e9 61 f7 ff ff       	jmp    80106ac2 <alltraps>

80107361 <vector34>:
.globl vector34
vector34:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $34
80107363:	6a 22                	push   $0x22
  jmp alltraps
80107365:	e9 58 f7 ff ff       	jmp    80106ac2 <alltraps>

8010736a <vector35>:
.globl vector35
vector35:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $35
8010736c:	6a 23                	push   $0x23
  jmp alltraps
8010736e:	e9 4f f7 ff ff       	jmp    80106ac2 <alltraps>

80107373 <vector36>:
.globl vector36
vector36:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $36
80107375:	6a 24                	push   $0x24
  jmp alltraps
80107377:	e9 46 f7 ff ff       	jmp    80106ac2 <alltraps>

8010737c <vector37>:
.globl vector37
vector37:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $37
8010737e:	6a 25                	push   $0x25
  jmp alltraps
80107380:	e9 3d f7 ff ff       	jmp    80106ac2 <alltraps>

80107385 <vector38>:
.globl vector38
vector38:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $38
80107387:	6a 26                	push   $0x26
  jmp alltraps
80107389:	e9 34 f7 ff ff       	jmp    80106ac2 <alltraps>

8010738e <vector39>:
.globl vector39
vector39:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $39
80107390:	6a 27                	push   $0x27
  jmp alltraps
80107392:	e9 2b f7 ff ff       	jmp    80106ac2 <alltraps>

80107397 <vector40>:
.globl vector40
vector40:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $40
80107399:	6a 28                	push   $0x28
  jmp alltraps
8010739b:	e9 22 f7 ff ff       	jmp    80106ac2 <alltraps>

801073a0 <vector41>:
.globl vector41
vector41:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $41
801073a2:	6a 29                	push   $0x29
  jmp alltraps
801073a4:	e9 19 f7 ff ff       	jmp    80106ac2 <alltraps>

801073a9 <vector42>:
.globl vector42
vector42:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $42
801073ab:	6a 2a                	push   $0x2a
  jmp alltraps
801073ad:	e9 10 f7 ff ff       	jmp    80106ac2 <alltraps>

801073b2 <vector43>:
.globl vector43
vector43:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $43
801073b4:	6a 2b                	push   $0x2b
  jmp alltraps
801073b6:	e9 07 f7 ff ff       	jmp    80106ac2 <alltraps>

801073bb <vector44>:
.globl vector44
vector44:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $44
801073bd:	6a 2c                	push   $0x2c
  jmp alltraps
801073bf:	e9 fe f6 ff ff       	jmp    80106ac2 <alltraps>

801073c4 <vector45>:
.globl vector45
vector45:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $45
801073c6:	6a 2d                	push   $0x2d
  jmp alltraps
801073c8:	e9 f5 f6 ff ff       	jmp    80106ac2 <alltraps>

801073cd <vector46>:
.globl vector46
vector46:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $46
801073cf:	6a 2e                	push   $0x2e
  jmp alltraps
801073d1:	e9 ec f6 ff ff       	jmp    80106ac2 <alltraps>

801073d6 <vector47>:
.globl vector47
vector47:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $47
801073d8:	6a 2f                	push   $0x2f
  jmp alltraps
801073da:	e9 e3 f6 ff ff       	jmp    80106ac2 <alltraps>

801073df <vector48>:
.globl vector48
vector48:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $48
801073e1:	6a 30                	push   $0x30
  jmp alltraps
801073e3:	e9 da f6 ff ff       	jmp    80106ac2 <alltraps>

801073e8 <vector49>:
.globl vector49
vector49:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $49
801073ea:	6a 31                	push   $0x31
  jmp alltraps
801073ec:	e9 d1 f6 ff ff       	jmp    80106ac2 <alltraps>

801073f1 <vector50>:
.globl vector50
vector50:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $50
801073f3:	6a 32                	push   $0x32
  jmp alltraps
801073f5:	e9 c8 f6 ff ff       	jmp    80106ac2 <alltraps>

801073fa <vector51>:
.globl vector51
vector51:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $51
801073fc:	6a 33                	push   $0x33
  jmp alltraps
801073fe:	e9 bf f6 ff ff       	jmp    80106ac2 <alltraps>

80107403 <vector52>:
.globl vector52
vector52:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $52
80107405:	6a 34                	push   $0x34
  jmp alltraps
80107407:	e9 b6 f6 ff ff       	jmp    80106ac2 <alltraps>

8010740c <vector53>:
.globl vector53
vector53:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $53
8010740e:	6a 35                	push   $0x35
  jmp alltraps
80107410:	e9 ad f6 ff ff       	jmp    80106ac2 <alltraps>

80107415 <vector54>:
.globl vector54
vector54:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $54
80107417:	6a 36                	push   $0x36
  jmp alltraps
80107419:	e9 a4 f6 ff ff       	jmp    80106ac2 <alltraps>

8010741e <vector55>:
.globl vector55
vector55:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $55
80107420:	6a 37                	push   $0x37
  jmp alltraps
80107422:	e9 9b f6 ff ff       	jmp    80106ac2 <alltraps>

80107427 <vector56>:
.globl vector56
vector56:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $56
80107429:	6a 38                	push   $0x38
  jmp alltraps
8010742b:	e9 92 f6 ff ff       	jmp    80106ac2 <alltraps>

80107430 <vector57>:
.globl vector57
vector57:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $57
80107432:	6a 39                	push   $0x39
  jmp alltraps
80107434:	e9 89 f6 ff ff       	jmp    80106ac2 <alltraps>

80107439 <vector58>:
.globl vector58
vector58:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $58
8010743b:	6a 3a                	push   $0x3a
  jmp alltraps
8010743d:	e9 80 f6 ff ff       	jmp    80106ac2 <alltraps>

80107442 <vector59>:
.globl vector59
vector59:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $59
80107444:	6a 3b                	push   $0x3b
  jmp alltraps
80107446:	e9 77 f6 ff ff       	jmp    80106ac2 <alltraps>

8010744b <vector60>:
.globl vector60
vector60:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $60
8010744d:	6a 3c                	push   $0x3c
  jmp alltraps
8010744f:	e9 6e f6 ff ff       	jmp    80106ac2 <alltraps>

80107454 <vector61>:
.globl vector61
vector61:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $61
80107456:	6a 3d                	push   $0x3d
  jmp alltraps
80107458:	e9 65 f6 ff ff       	jmp    80106ac2 <alltraps>

8010745d <vector62>:
.globl vector62
vector62:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $62
8010745f:	6a 3e                	push   $0x3e
  jmp alltraps
80107461:	e9 5c f6 ff ff       	jmp    80106ac2 <alltraps>

80107466 <vector63>:
.globl vector63
vector63:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $63
80107468:	6a 3f                	push   $0x3f
  jmp alltraps
8010746a:	e9 53 f6 ff ff       	jmp    80106ac2 <alltraps>

8010746f <vector64>:
.globl vector64
vector64:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $64
80107471:	6a 40                	push   $0x40
  jmp alltraps
80107473:	e9 4a f6 ff ff       	jmp    80106ac2 <alltraps>

80107478 <vector65>:
.globl vector65
vector65:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $65
8010747a:	6a 41                	push   $0x41
  jmp alltraps
8010747c:	e9 41 f6 ff ff       	jmp    80106ac2 <alltraps>

80107481 <vector66>:
.globl vector66
vector66:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $66
80107483:	6a 42                	push   $0x42
  jmp alltraps
80107485:	e9 38 f6 ff ff       	jmp    80106ac2 <alltraps>

8010748a <vector67>:
.globl vector67
vector67:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $67
8010748c:	6a 43                	push   $0x43
  jmp alltraps
8010748e:	e9 2f f6 ff ff       	jmp    80106ac2 <alltraps>

80107493 <vector68>:
.globl vector68
vector68:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $68
80107495:	6a 44                	push   $0x44
  jmp alltraps
80107497:	e9 26 f6 ff ff       	jmp    80106ac2 <alltraps>

8010749c <vector69>:
.globl vector69
vector69:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $69
8010749e:	6a 45                	push   $0x45
  jmp alltraps
801074a0:	e9 1d f6 ff ff       	jmp    80106ac2 <alltraps>

801074a5 <vector70>:
.globl vector70
vector70:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $70
801074a7:	6a 46                	push   $0x46
  jmp alltraps
801074a9:	e9 14 f6 ff ff       	jmp    80106ac2 <alltraps>

801074ae <vector71>:
.globl vector71
vector71:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $71
801074b0:	6a 47                	push   $0x47
  jmp alltraps
801074b2:	e9 0b f6 ff ff       	jmp    80106ac2 <alltraps>

801074b7 <vector72>:
.globl vector72
vector72:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $72
801074b9:	6a 48                	push   $0x48
  jmp alltraps
801074bb:	e9 02 f6 ff ff       	jmp    80106ac2 <alltraps>

801074c0 <vector73>:
.globl vector73
vector73:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $73
801074c2:	6a 49                	push   $0x49
  jmp alltraps
801074c4:	e9 f9 f5 ff ff       	jmp    80106ac2 <alltraps>

801074c9 <vector74>:
.globl vector74
vector74:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $74
801074cb:	6a 4a                	push   $0x4a
  jmp alltraps
801074cd:	e9 f0 f5 ff ff       	jmp    80106ac2 <alltraps>

801074d2 <vector75>:
.globl vector75
vector75:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $75
801074d4:	6a 4b                	push   $0x4b
  jmp alltraps
801074d6:	e9 e7 f5 ff ff       	jmp    80106ac2 <alltraps>

801074db <vector76>:
.globl vector76
vector76:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $76
801074dd:	6a 4c                	push   $0x4c
  jmp alltraps
801074df:	e9 de f5 ff ff       	jmp    80106ac2 <alltraps>

801074e4 <vector77>:
.globl vector77
vector77:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $77
801074e6:	6a 4d                	push   $0x4d
  jmp alltraps
801074e8:	e9 d5 f5 ff ff       	jmp    80106ac2 <alltraps>

801074ed <vector78>:
.globl vector78
vector78:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $78
801074ef:	6a 4e                	push   $0x4e
  jmp alltraps
801074f1:	e9 cc f5 ff ff       	jmp    80106ac2 <alltraps>

801074f6 <vector79>:
.globl vector79
vector79:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $79
801074f8:	6a 4f                	push   $0x4f
  jmp alltraps
801074fa:	e9 c3 f5 ff ff       	jmp    80106ac2 <alltraps>

801074ff <vector80>:
.globl vector80
vector80:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $80
80107501:	6a 50                	push   $0x50
  jmp alltraps
80107503:	e9 ba f5 ff ff       	jmp    80106ac2 <alltraps>

80107508 <vector81>:
.globl vector81
vector81:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $81
8010750a:	6a 51                	push   $0x51
  jmp alltraps
8010750c:	e9 b1 f5 ff ff       	jmp    80106ac2 <alltraps>

80107511 <vector82>:
.globl vector82
vector82:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $82
80107513:	6a 52                	push   $0x52
  jmp alltraps
80107515:	e9 a8 f5 ff ff       	jmp    80106ac2 <alltraps>

8010751a <vector83>:
.globl vector83
vector83:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $83
8010751c:	6a 53                	push   $0x53
  jmp alltraps
8010751e:	e9 9f f5 ff ff       	jmp    80106ac2 <alltraps>

80107523 <vector84>:
.globl vector84
vector84:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $84
80107525:	6a 54                	push   $0x54
  jmp alltraps
80107527:	e9 96 f5 ff ff       	jmp    80106ac2 <alltraps>

8010752c <vector85>:
.globl vector85
vector85:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $85
8010752e:	6a 55                	push   $0x55
  jmp alltraps
80107530:	e9 8d f5 ff ff       	jmp    80106ac2 <alltraps>

80107535 <vector86>:
.globl vector86
vector86:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $86
80107537:	6a 56                	push   $0x56
  jmp alltraps
80107539:	e9 84 f5 ff ff       	jmp    80106ac2 <alltraps>

8010753e <vector87>:
.globl vector87
vector87:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $87
80107540:	6a 57                	push   $0x57
  jmp alltraps
80107542:	e9 7b f5 ff ff       	jmp    80106ac2 <alltraps>

80107547 <vector88>:
.globl vector88
vector88:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $88
80107549:	6a 58                	push   $0x58
  jmp alltraps
8010754b:	e9 72 f5 ff ff       	jmp    80106ac2 <alltraps>

80107550 <vector89>:
.globl vector89
vector89:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $89
80107552:	6a 59                	push   $0x59
  jmp alltraps
80107554:	e9 69 f5 ff ff       	jmp    80106ac2 <alltraps>

80107559 <vector90>:
.globl vector90
vector90:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $90
8010755b:	6a 5a                	push   $0x5a
  jmp alltraps
8010755d:	e9 60 f5 ff ff       	jmp    80106ac2 <alltraps>

80107562 <vector91>:
.globl vector91
vector91:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $91
80107564:	6a 5b                	push   $0x5b
  jmp alltraps
80107566:	e9 57 f5 ff ff       	jmp    80106ac2 <alltraps>

8010756b <vector92>:
.globl vector92
vector92:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $92
8010756d:	6a 5c                	push   $0x5c
  jmp alltraps
8010756f:	e9 4e f5 ff ff       	jmp    80106ac2 <alltraps>

80107574 <vector93>:
.globl vector93
vector93:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $93
80107576:	6a 5d                	push   $0x5d
  jmp alltraps
80107578:	e9 45 f5 ff ff       	jmp    80106ac2 <alltraps>

8010757d <vector94>:
.globl vector94
vector94:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $94
8010757f:	6a 5e                	push   $0x5e
  jmp alltraps
80107581:	e9 3c f5 ff ff       	jmp    80106ac2 <alltraps>

80107586 <vector95>:
.globl vector95
vector95:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $95
80107588:	6a 5f                	push   $0x5f
  jmp alltraps
8010758a:	e9 33 f5 ff ff       	jmp    80106ac2 <alltraps>

8010758f <vector96>:
.globl vector96
vector96:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $96
80107591:	6a 60                	push   $0x60
  jmp alltraps
80107593:	e9 2a f5 ff ff       	jmp    80106ac2 <alltraps>

80107598 <vector97>:
.globl vector97
vector97:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $97
8010759a:	6a 61                	push   $0x61
  jmp alltraps
8010759c:	e9 21 f5 ff ff       	jmp    80106ac2 <alltraps>

801075a1 <vector98>:
.globl vector98
vector98:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $98
801075a3:	6a 62                	push   $0x62
  jmp alltraps
801075a5:	e9 18 f5 ff ff       	jmp    80106ac2 <alltraps>

801075aa <vector99>:
.globl vector99
vector99:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $99
801075ac:	6a 63                	push   $0x63
  jmp alltraps
801075ae:	e9 0f f5 ff ff       	jmp    80106ac2 <alltraps>

801075b3 <vector100>:
.globl vector100
vector100:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $100
801075b5:	6a 64                	push   $0x64
  jmp alltraps
801075b7:	e9 06 f5 ff ff       	jmp    80106ac2 <alltraps>

801075bc <vector101>:
.globl vector101
vector101:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $101
801075be:	6a 65                	push   $0x65
  jmp alltraps
801075c0:	e9 fd f4 ff ff       	jmp    80106ac2 <alltraps>

801075c5 <vector102>:
.globl vector102
vector102:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $102
801075c7:	6a 66                	push   $0x66
  jmp alltraps
801075c9:	e9 f4 f4 ff ff       	jmp    80106ac2 <alltraps>

801075ce <vector103>:
.globl vector103
vector103:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $103
801075d0:	6a 67                	push   $0x67
  jmp alltraps
801075d2:	e9 eb f4 ff ff       	jmp    80106ac2 <alltraps>

801075d7 <vector104>:
.globl vector104
vector104:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $104
801075d9:	6a 68                	push   $0x68
  jmp alltraps
801075db:	e9 e2 f4 ff ff       	jmp    80106ac2 <alltraps>

801075e0 <vector105>:
.globl vector105
vector105:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $105
801075e2:	6a 69                	push   $0x69
  jmp alltraps
801075e4:	e9 d9 f4 ff ff       	jmp    80106ac2 <alltraps>

801075e9 <vector106>:
.globl vector106
vector106:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $106
801075eb:	6a 6a                	push   $0x6a
  jmp alltraps
801075ed:	e9 d0 f4 ff ff       	jmp    80106ac2 <alltraps>

801075f2 <vector107>:
.globl vector107
vector107:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $107
801075f4:	6a 6b                	push   $0x6b
  jmp alltraps
801075f6:	e9 c7 f4 ff ff       	jmp    80106ac2 <alltraps>

801075fb <vector108>:
.globl vector108
vector108:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $108
801075fd:	6a 6c                	push   $0x6c
  jmp alltraps
801075ff:	e9 be f4 ff ff       	jmp    80106ac2 <alltraps>

80107604 <vector109>:
.globl vector109
vector109:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $109
80107606:	6a 6d                	push   $0x6d
  jmp alltraps
80107608:	e9 b5 f4 ff ff       	jmp    80106ac2 <alltraps>

8010760d <vector110>:
.globl vector110
vector110:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $110
8010760f:	6a 6e                	push   $0x6e
  jmp alltraps
80107611:	e9 ac f4 ff ff       	jmp    80106ac2 <alltraps>

80107616 <vector111>:
.globl vector111
vector111:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $111
80107618:	6a 6f                	push   $0x6f
  jmp alltraps
8010761a:	e9 a3 f4 ff ff       	jmp    80106ac2 <alltraps>

8010761f <vector112>:
.globl vector112
vector112:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $112
80107621:	6a 70                	push   $0x70
  jmp alltraps
80107623:	e9 9a f4 ff ff       	jmp    80106ac2 <alltraps>

80107628 <vector113>:
.globl vector113
vector113:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $113
8010762a:	6a 71                	push   $0x71
  jmp alltraps
8010762c:	e9 91 f4 ff ff       	jmp    80106ac2 <alltraps>

80107631 <vector114>:
.globl vector114
vector114:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $114
80107633:	6a 72                	push   $0x72
  jmp alltraps
80107635:	e9 88 f4 ff ff       	jmp    80106ac2 <alltraps>

8010763a <vector115>:
.globl vector115
vector115:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $115
8010763c:	6a 73                	push   $0x73
  jmp alltraps
8010763e:	e9 7f f4 ff ff       	jmp    80106ac2 <alltraps>

80107643 <vector116>:
.globl vector116
vector116:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $116
80107645:	6a 74                	push   $0x74
  jmp alltraps
80107647:	e9 76 f4 ff ff       	jmp    80106ac2 <alltraps>

8010764c <vector117>:
.globl vector117
vector117:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $117
8010764e:	6a 75                	push   $0x75
  jmp alltraps
80107650:	e9 6d f4 ff ff       	jmp    80106ac2 <alltraps>

80107655 <vector118>:
.globl vector118
vector118:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $118
80107657:	6a 76                	push   $0x76
  jmp alltraps
80107659:	e9 64 f4 ff ff       	jmp    80106ac2 <alltraps>

8010765e <vector119>:
.globl vector119
vector119:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $119
80107660:	6a 77                	push   $0x77
  jmp alltraps
80107662:	e9 5b f4 ff ff       	jmp    80106ac2 <alltraps>

80107667 <vector120>:
.globl vector120
vector120:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $120
80107669:	6a 78                	push   $0x78
  jmp alltraps
8010766b:	e9 52 f4 ff ff       	jmp    80106ac2 <alltraps>

80107670 <vector121>:
.globl vector121
vector121:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $121
80107672:	6a 79                	push   $0x79
  jmp alltraps
80107674:	e9 49 f4 ff ff       	jmp    80106ac2 <alltraps>

80107679 <vector122>:
.globl vector122
vector122:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $122
8010767b:	6a 7a                	push   $0x7a
  jmp alltraps
8010767d:	e9 40 f4 ff ff       	jmp    80106ac2 <alltraps>

80107682 <vector123>:
.globl vector123
vector123:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $123
80107684:	6a 7b                	push   $0x7b
  jmp alltraps
80107686:	e9 37 f4 ff ff       	jmp    80106ac2 <alltraps>

8010768b <vector124>:
.globl vector124
vector124:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $124
8010768d:	6a 7c                	push   $0x7c
  jmp alltraps
8010768f:	e9 2e f4 ff ff       	jmp    80106ac2 <alltraps>

80107694 <vector125>:
.globl vector125
vector125:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $125
80107696:	6a 7d                	push   $0x7d
  jmp alltraps
80107698:	e9 25 f4 ff ff       	jmp    80106ac2 <alltraps>

8010769d <vector126>:
.globl vector126
vector126:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $126
8010769f:	6a 7e                	push   $0x7e
  jmp alltraps
801076a1:	e9 1c f4 ff ff       	jmp    80106ac2 <alltraps>

801076a6 <vector127>:
.globl vector127
vector127:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $127
801076a8:	6a 7f                	push   $0x7f
  jmp alltraps
801076aa:	e9 13 f4 ff ff       	jmp    80106ac2 <alltraps>

801076af <vector128>:
.globl vector128
vector128:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $128
801076b1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801076b6:	e9 07 f4 ff ff       	jmp    80106ac2 <alltraps>

801076bb <vector129>:
.globl vector129
vector129:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $129
801076bd:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801076c2:	e9 fb f3 ff ff       	jmp    80106ac2 <alltraps>

801076c7 <vector130>:
.globl vector130
vector130:
  pushl $0
801076c7:	6a 00                	push   $0x0
  pushl $130
801076c9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801076ce:	e9 ef f3 ff ff       	jmp    80106ac2 <alltraps>

801076d3 <vector131>:
.globl vector131
vector131:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $131
801076d5:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801076da:	e9 e3 f3 ff ff       	jmp    80106ac2 <alltraps>

801076df <vector132>:
.globl vector132
vector132:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $132
801076e1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801076e6:	e9 d7 f3 ff ff       	jmp    80106ac2 <alltraps>

801076eb <vector133>:
.globl vector133
vector133:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $133
801076ed:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076f2:	e9 cb f3 ff ff       	jmp    80106ac2 <alltraps>

801076f7 <vector134>:
.globl vector134
vector134:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $134
801076f9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076fe:	e9 bf f3 ff ff       	jmp    80106ac2 <alltraps>

80107703 <vector135>:
.globl vector135
vector135:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $135
80107705:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010770a:	e9 b3 f3 ff ff       	jmp    80106ac2 <alltraps>

8010770f <vector136>:
.globl vector136
vector136:
  pushl $0
8010770f:	6a 00                	push   $0x0
  pushl $136
80107711:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107716:	e9 a7 f3 ff ff       	jmp    80106ac2 <alltraps>

8010771b <vector137>:
.globl vector137
vector137:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $137
8010771d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107722:	e9 9b f3 ff ff       	jmp    80106ac2 <alltraps>

80107727 <vector138>:
.globl vector138
vector138:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $138
80107729:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010772e:	e9 8f f3 ff ff       	jmp    80106ac2 <alltraps>

80107733 <vector139>:
.globl vector139
vector139:
  pushl $0
80107733:	6a 00                	push   $0x0
  pushl $139
80107735:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010773a:	e9 83 f3 ff ff       	jmp    80106ac2 <alltraps>

8010773f <vector140>:
.globl vector140
vector140:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $140
80107741:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107746:	e9 77 f3 ff ff       	jmp    80106ac2 <alltraps>

8010774b <vector141>:
.globl vector141
vector141:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $141
8010774d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107752:	e9 6b f3 ff ff       	jmp    80106ac2 <alltraps>

80107757 <vector142>:
.globl vector142
vector142:
  pushl $0
80107757:	6a 00                	push   $0x0
  pushl $142
80107759:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010775e:	e9 5f f3 ff ff       	jmp    80106ac2 <alltraps>

80107763 <vector143>:
.globl vector143
vector143:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $143
80107765:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010776a:	e9 53 f3 ff ff       	jmp    80106ac2 <alltraps>

8010776f <vector144>:
.globl vector144
vector144:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $144
80107771:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107776:	e9 47 f3 ff ff       	jmp    80106ac2 <alltraps>

8010777b <vector145>:
.globl vector145
vector145:
  pushl $0
8010777b:	6a 00                	push   $0x0
  pushl $145
8010777d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107782:	e9 3b f3 ff ff       	jmp    80106ac2 <alltraps>

80107787 <vector146>:
.globl vector146
vector146:
  pushl $0
80107787:	6a 00                	push   $0x0
  pushl $146
80107789:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010778e:	e9 2f f3 ff ff       	jmp    80106ac2 <alltraps>

80107793 <vector147>:
.globl vector147
vector147:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $147
80107795:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010779a:	e9 23 f3 ff ff       	jmp    80106ac2 <alltraps>

8010779f <vector148>:
.globl vector148
vector148:
  pushl $0
8010779f:	6a 00                	push   $0x0
  pushl $148
801077a1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801077a6:	e9 17 f3 ff ff       	jmp    80106ac2 <alltraps>

801077ab <vector149>:
.globl vector149
vector149:
  pushl $0
801077ab:	6a 00                	push   $0x0
  pushl $149
801077ad:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801077b2:	e9 0b f3 ff ff       	jmp    80106ac2 <alltraps>

801077b7 <vector150>:
.globl vector150
vector150:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $150
801077b9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801077be:	e9 ff f2 ff ff       	jmp    80106ac2 <alltraps>

801077c3 <vector151>:
.globl vector151
vector151:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $151
801077c5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801077ca:	e9 f3 f2 ff ff       	jmp    80106ac2 <alltraps>

801077cf <vector152>:
.globl vector152
vector152:
  pushl $0
801077cf:	6a 00                	push   $0x0
  pushl $152
801077d1:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801077d6:	e9 e7 f2 ff ff       	jmp    80106ac2 <alltraps>

801077db <vector153>:
.globl vector153
vector153:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $153
801077dd:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801077e2:	e9 db f2 ff ff       	jmp    80106ac2 <alltraps>

801077e7 <vector154>:
.globl vector154
vector154:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $154
801077e9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077ee:	e9 cf f2 ff ff       	jmp    80106ac2 <alltraps>

801077f3 <vector155>:
.globl vector155
vector155:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $155
801077f5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077fa:	e9 c3 f2 ff ff       	jmp    80106ac2 <alltraps>

801077ff <vector156>:
.globl vector156
vector156:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $156
80107801:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107806:	e9 b7 f2 ff ff       	jmp    80106ac2 <alltraps>

8010780b <vector157>:
.globl vector157
vector157:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $157
8010780d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107812:	e9 ab f2 ff ff       	jmp    80106ac2 <alltraps>

80107817 <vector158>:
.globl vector158
vector158:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $158
80107819:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010781e:	e9 9f f2 ff ff       	jmp    80106ac2 <alltraps>

80107823 <vector159>:
.globl vector159
vector159:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $159
80107825:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010782a:	e9 93 f2 ff ff       	jmp    80106ac2 <alltraps>

8010782f <vector160>:
.globl vector160
vector160:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $160
80107831:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107836:	e9 87 f2 ff ff       	jmp    80106ac2 <alltraps>

8010783b <vector161>:
.globl vector161
vector161:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $161
8010783d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107842:	e9 7b f2 ff ff       	jmp    80106ac2 <alltraps>

80107847 <vector162>:
.globl vector162
vector162:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $162
80107849:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010784e:	e9 6f f2 ff ff       	jmp    80106ac2 <alltraps>

80107853 <vector163>:
.globl vector163
vector163:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $163
80107855:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010785a:	e9 63 f2 ff ff       	jmp    80106ac2 <alltraps>

8010785f <vector164>:
.globl vector164
vector164:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $164
80107861:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107866:	e9 57 f2 ff ff       	jmp    80106ac2 <alltraps>

8010786b <vector165>:
.globl vector165
vector165:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $165
8010786d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107872:	e9 4b f2 ff ff       	jmp    80106ac2 <alltraps>

80107877 <vector166>:
.globl vector166
vector166:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $166
80107879:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010787e:	e9 3f f2 ff ff       	jmp    80106ac2 <alltraps>

80107883 <vector167>:
.globl vector167
vector167:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $167
80107885:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010788a:	e9 33 f2 ff ff       	jmp    80106ac2 <alltraps>

8010788f <vector168>:
.globl vector168
vector168:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $168
80107891:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107896:	e9 27 f2 ff ff       	jmp    80106ac2 <alltraps>

8010789b <vector169>:
.globl vector169
vector169:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $169
8010789d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801078a2:	e9 1b f2 ff ff       	jmp    80106ac2 <alltraps>

801078a7 <vector170>:
.globl vector170
vector170:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $170
801078a9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801078ae:	e9 0f f2 ff ff       	jmp    80106ac2 <alltraps>

801078b3 <vector171>:
.globl vector171
vector171:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $171
801078b5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801078ba:	e9 03 f2 ff ff       	jmp    80106ac2 <alltraps>

801078bf <vector172>:
.globl vector172
vector172:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $172
801078c1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801078c6:	e9 f7 f1 ff ff       	jmp    80106ac2 <alltraps>

801078cb <vector173>:
.globl vector173
vector173:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $173
801078cd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801078d2:	e9 eb f1 ff ff       	jmp    80106ac2 <alltraps>

801078d7 <vector174>:
.globl vector174
vector174:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $174
801078d9:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801078de:	e9 df f1 ff ff       	jmp    80106ac2 <alltraps>

801078e3 <vector175>:
.globl vector175
vector175:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $175
801078e5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078ea:	e9 d3 f1 ff ff       	jmp    80106ac2 <alltraps>

801078ef <vector176>:
.globl vector176
vector176:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $176
801078f1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078f6:	e9 c7 f1 ff ff       	jmp    80106ac2 <alltraps>

801078fb <vector177>:
.globl vector177
vector177:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $177
801078fd:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107902:	e9 bb f1 ff ff       	jmp    80106ac2 <alltraps>

80107907 <vector178>:
.globl vector178
vector178:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $178
80107909:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010790e:	e9 af f1 ff ff       	jmp    80106ac2 <alltraps>

80107913 <vector179>:
.globl vector179
vector179:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $179
80107915:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010791a:	e9 a3 f1 ff ff       	jmp    80106ac2 <alltraps>

8010791f <vector180>:
.globl vector180
vector180:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $180
80107921:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107926:	e9 97 f1 ff ff       	jmp    80106ac2 <alltraps>

8010792b <vector181>:
.globl vector181
vector181:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $181
8010792d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107932:	e9 8b f1 ff ff       	jmp    80106ac2 <alltraps>

80107937 <vector182>:
.globl vector182
vector182:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $182
80107939:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010793e:	e9 7f f1 ff ff       	jmp    80106ac2 <alltraps>

80107943 <vector183>:
.globl vector183
vector183:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $183
80107945:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010794a:	e9 73 f1 ff ff       	jmp    80106ac2 <alltraps>

8010794f <vector184>:
.globl vector184
vector184:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $184
80107951:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107956:	e9 67 f1 ff ff       	jmp    80106ac2 <alltraps>

8010795b <vector185>:
.globl vector185
vector185:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $185
8010795d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107962:	e9 5b f1 ff ff       	jmp    80106ac2 <alltraps>

80107967 <vector186>:
.globl vector186
vector186:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $186
80107969:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010796e:	e9 4f f1 ff ff       	jmp    80106ac2 <alltraps>

80107973 <vector187>:
.globl vector187
vector187:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $187
80107975:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010797a:	e9 43 f1 ff ff       	jmp    80106ac2 <alltraps>

8010797f <vector188>:
.globl vector188
vector188:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $188
80107981:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107986:	e9 37 f1 ff ff       	jmp    80106ac2 <alltraps>

8010798b <vector189>:
.globl vector189
vector189:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $189
8010798d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107992:	e9 2b f1 ff ff       	jmp    80106ac2 <alltraps>

80107997 <vector190>:
.globl vector190
vector190:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $190
80107999:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010799e:	e9 1f f1 ff ff       	jmp    80106ac2 <alltraps>

801079a3 <vector191>:
.globl vector191
vector191:
  pushl $0
801079a3:	6a 00                	push   $0x0
  pushl $191
801079a5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801079aa:	e9 13 f1 ff ff       	jmp    80106ac2 <alltraps>

801079af <vector192>:
.globl vector192
vector192:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $192
801079b1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801079b6:	e9 07 f1 ff ff       	jmp    80106ac2 <alltraps>

801079bb <vector193>:
.globl vector193
vector193:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $193
801079bd:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801079c2:	e9 fb f0 ff ff       	jmp    80106ac2 <alltraps>

801079c7 <vector194>:
.globl vector194
vector194:
  pushl $0
801079c7:	6a 00                	push   $0x0
  pushl $194
801079c9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801079ce:	e9 ef f0 ff ff       	jmp    80106ac2 <alltraps>

801079d3 <vector195>:
.globl vector195
vector195:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $195
801079d5:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801079da:	e9 e3 f0 ff ff       	jmp    80106ac2 <alltraps>

801079df <vector196>:
.globl vector196
vector196:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $196
801079e1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801079e6:	e9 d7 f0 ff ff       	jmp    80106ac2 <alltraps>

801079eb <vector197>:
.globl vector197
vector197:
  pushl $0
801079eb:	6a 00                	push   $0x0
  pushl $197
801079ed:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079f2:	e9 cb f0 ff ff       	jmp    80106ac2 <alltraps>

801079f7 <vector198>:
.globl vector198
vector198:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $198
801079f9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079fe:	e9 bf f0 ff ff       	jmp    80106ac2 <alltraps>

80107a03 <vector199>:
.globl vector199
vector199:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $199
80107a05:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107a0a:	e9 b3 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a0f <vector200>:
.globl vector200
vector200:
  pushl $0
80107a0f:	6a 00                	push   $0x0
  pushl $200
80107a11:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107a16:	e9 a7 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a1b <vector201>:
.globl vector201
vector201:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $201
80107a1d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107a22:	e9 9b f0 ff ff       	jmp    80106ac2 <alltraps>

80107a27 <vector202>:
.globl vector202
vector202:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $202
80107a29:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107a2e:	e9 8f f0 ff ff       	jmp    80106ac2 <alltraps>

80107a33 <vector203>:
.globl vector203
vector203:
  pushl $0
80107a33:	6a 00                	push   $0x0
  pushl $203
80107a35:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107a3a:	e9 83 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a3f <vector204>:
.globl vector204
vector204:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $204
80107a41:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107a46:	e9 77 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a4b <vector205>:
.globl vector205
vector205:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $205
80107a4d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a52:	e9 6b f0 ff ff       	jmp    80106ac2 <alltraps>

80107a57 <vector206>:
.globl vector206
vector206:
  pushl $0
80107a57:	6a 00                	push   $0x0
  pushl $206
80107a59:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a5e:	e9 5f f0 ff ff       	jmp    80106ac2 <alltraps>

80107a63 <vector207>:
.globl vector207
vector207:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $207
80107a65:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a6a:	e9 53 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a6f <vector208>:
.globl vector208
vector208:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $208
80107a71:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a76:	e9 47 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a7b <vector209>:
.globl vector209
vector209:
  pushl $0
80107a7b:	6a 00                	push   $0x0
  pushl $209
80107a7d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a82:	e9 3b f0 ff ff       	jmp    80106ac2 <alltraps>

80107a87 <vector210>:
.globl vector210
vector210:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $210
80107a89:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a8e:	e9 2f f0 ff ff       	jmp    80106ac2 <alltraps>

80107a93 <vector211>:
.globl vector211
vector211:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $211
80107a95:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a9a:	e9 23 f0 ff ff       	jmp    80106ac2 <alltraps>

80107a9f <vector212>:
.globl vector212
vector212:
  pushl $0
80107a9f:	6a 00                	push   $0x0
  pushl $212
80107aa1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107aa6:	e9 17 f0 ff ff       	jmp    80106ac2 <alltraps>

80107aab <vector213>:
.globl vector213
vector213:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $213
80107aad:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ab2:	e9 0b f0 ff ff       	jmp    80106ac2 <alltraps>

80107ab7 <vector214>:
.globl vector214
vector214:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $214
80107ab9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107abe:	e9 ff ef ff ff       	jmp    80106ac2 <alltraps>

80107ac3 <vector215>:
.globl vector215
vector215:
  pushl $0
80107ac3:	6a 00                	push   $0x0
  pushl $215
80107ac5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107aca:	e9 f3 ef ff ff       	jmp    80106ac2 <alltraps>

80107acf <vector216>:
.globl vector216
vector216:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $216
80107ad1:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107ad6:	e9 e7 ef ff ff       	jmp    80106ac2 <alltraps>

80107adb <vector217>:
.globl vector217
vector217:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $217
80107add:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107ae2:	e9 db ef ff ff       	jmp    80106ac2 <alltraps>

80107ae7 <vector218>:
.globl vector218
vector218:
  pushl $0
80107ae7:	6a 00                	push   $0x0
  pushl $218
80107ae9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107aee:	e9 cf ef ff ff       	jmp    80106ac2 <alltraps>

80107af3 <vector219>:
.globl vector219
vector219:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $219
80107af5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107afa:	e9 c3 ef ff ff       	jmp    80106ac2 <alltraps>

80107aff <vector220>:
.globl vector220
vector220:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $220
80107b01:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107b06:	e9 b7 ef ff ff       	jmp    80106ac2 <alltraps>

80107b0b <vector221>:
.globl vector221
vector221:
  pushl $0
80107b0b:	6a 00                	push   $0x0
  pushl $221
80107b0d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107b12:	e9 ab ef ff ff       	jmp    80106ac2 <alltraps>

80107b17 <vector222>:
.globl vector222
vector222:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $222
80107b19:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107b1e:	e9 9f ef ff ff       	jmp    80106ac2 <alltraps>

80107b23 <vector223>:
.globl vector223
vector223:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $223
80107b25:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107b2a:	e9 93 ef ff ff       	jmp    80106ac2 <alltraps>

80107b2f <vector224>:
.globl vector224
vector224:
  pushl $0
80107b2f:	6a 00                	push   $0x0
  pushl $224
80107b31:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107b36:	e9 87 ef ff ff       	jmp    80106ac2 <alltraps>

80107b3b <vector225>:
.globl vector225
vector225:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $225
80107b3d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107b42:	e9 7b ef ff ff       	jmp    80106ac2 <alltraps>

80107b47 <vector226>:
.globl vector226
vector226:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $226
80107b49:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b4e:	e9 6f ef ff ff       	jmp    80106ac2 <alltraps>

80107b53 <vector227>:
.globl vector227
vector227:
  pushl $0
80107b53:	6a 00                	push   $0x0
  pushl $227
80107b55:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b5a:	e9 63 ef ff ff       	jmp    80106ac2 <alltraps>

80107b5f <vector228>:
.globl vector228
vector228:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $228
80107b61:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b66:	e9 57 ef ff ff       	jmp    80106ac2 <alltraps>

80107b6b <vector229>:
.globl vector229
vector229:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $229
80107b6d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b72:	e9 4b ef ff ff       	jmp    80106ac2 <alltraps>

80107b77 <vector230>:
.globl vector230
vector230:
  pushl $0
80107b77:	6a 00                	push   $0x0
  pushl $230
80107b79:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b7e:	e9 3f ef ff ff       	jmp    80106ac2 <alltraps>

80107b83 <vector231>:
.globl vector231
vector231:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $231
80107b85:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b8a:	e9 33 ef ff ff       	jmp    80106ac2 <alltraps>

80107b8f <vector232>:
.globl vector232
vector232:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $232
80107b91:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b96:	e9 27 ef ff ff       	jmp    80106ac2 <alltraps>

80107b9b <vector233>:
.globl vector233
vector233:
  pushl $0
80107b9b:	6a 00                	push   $0x0
  pushl $233
80107b9d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ba2:	e9 1b ef ff ff       	jmp    80106ac2 <alltraps>

80107ba7 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $234
80107ba9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107bae:	e9 0f ef ff ff       	jmp    80106ac2 <alltraps>

80107bb3 <vector235>:
.globl vector235
vector235:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $235
80107bb5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107bba:	e9 03 ef ff ff       	jmp    80106ac2 <alltraps>

80107bbf <vector236>:
.globl vector236
vector236:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $236
80107bc1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107bc6:	e9 f7 ee ff ff       	jmp    80106ac2 <alltraps>

80107bcb <vector237>:
.globl vector237
vector237:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $237
80107bcd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107bd2:	e9 eb ee ff ff       	jmp    80106ac2 <alltraps>

80107bd7 <vector238>:
.globl vector238
vector238:
  pushl $0
80107bd7:	6a 00                	push   $0x0
  pushl $238
80107bd9:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107bde:	e9 df ee ff ff       	jmp    80106ac2 <alltraps>

80107be3 <vector239>:
.globl vector239
vector239:
  pushl $0
80107be3:	6a 00                	push   $0x0
  pushl $239
80107be5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107bea:	e9 d3 ee ff ff       	jmp    80106ac2 <alltraps>

80107bef <vector240>:
.globl vector240
vector240:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $240
80107bf1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bf6:	e9 c7 ee ff ff       	jmp    80106ac2 <alltraps>

80107bfb <vector241>:
.globl vector241
vector241:
  pushl $0
80107bfb:	6a 00                	push   $0x0
  pushl $241
80107bfd:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107c02:	e9 bb ee ff ff       	jmp    80106ac2 <alltraps>

80107c07 <vector242>:
.globl vector242
vector242:
  pushl $0
80107c07:	6a 00                	push   $0x0
  pushl $242
80107c09:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107c0e:	e9 af ee ff ff       	jmp    80106ac2 <alltraps>

80107c13 <vector243>:
.globl vector243
vector243:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $243
80107c15:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107c1a:	e9 a3 ee ff ff       	jmp    80106ac2 <alltraps>

80107c1f <vector244>:
.globl vector244
vector244:
  pushl $0
80107c1f:	6a 00                	push   $0x0
  pushl $244
80107c21:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107c26:	e9 97 ee ff ff       	jmp    80106ac2 <alltraps>

80107c2b <vector245>:
.globl vector245
vector245:
  pushl $0
80107c2b:	6a 00                	push   $0x0
  pushl $245
80107c2d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107c32:	e9 8b ee ff ff       	jmp    80106ac2 <alltraps>

80107c37 <vector246>:
.globl vector246
vector246:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $246
80107c39:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107c3e:	e9 7f ee ff ff       	jmp    80106ac2 <alltraps>

80107c43 <vector247>:
.globl vector247
vector247:
  pushl $0
80107c43:	6a 00                	push   $0x0
  pushl $247
80107c45:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c4a:	e9 73 ee ff ff       	jmp    80106ac2 <alltraps>

80107c4f <vector248>:
.globl vector248
vector248:
  pushl $0
80107c4f:	6a 00                	push   $0x0
  pushl $248
80107c51:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c56:	e9 67 ee ff ff       	jmp    80106ac2 <alltraps>

80107c5b <vector249>:
.globl vector249
vector249:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $249
80107c5d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c62:	e9 5b ee ff ff       	jmp    80106ac2 <alltraps>

80107c67 <vector250>:
.globl vector250
vector250:
  pushl $0
80107c67:	6a 00                	push   $0x0
  pushl $250
80107c69:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c6e:	e9 4f ee ff ff       	jmp    80106ac2 <alltraps>

80107c73 <vector251>:
.globl vector251
vector251:
  pushl $0
80107c73:	6a 00                	push   $0x0
  pushl $251
80107c75:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c7a:	e9 43 ee ff ff       	jmp    80106ac2 <alltraps>

80107c7f <vector252>:
.globl vector252
vector252:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $252
80107c81:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c86:	e9 37 ee ff ff       	jmp    80106ac2 <alltraps>

80107c8b <vector253>:
.globl vector253
vector253:
  pushl $0
80107c8b:	6a 00                	push   $0x0
  pushl $253
80107c8d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c92:	e9 2b ee ff ff       	jmp    80106ac2 <alltraps>

80107c97 <vector254>:
.globl vector254
vector254:
  pushl $0
80107c97:	6a 00                	push   $0x0
  pushl $254
80107c99:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c9e:	e9 1f ee ff ff       	jmp    80106ac2 <alltraps>

80107ca3 <vector255>:
.globl vector255
vector255:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $255
80107ca5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107caa:	e9 13 ee ff ff       	jmp    80106ac2 <alltraps>

80107caf <lgdt>:
{
80107caf:	55                   	push   %ebp
80107cb0:	89 e5                	mov    %esp,%ebp
80107cb2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb8:	83 e8 01             	sub    $0x1,%eax
80107cbb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc9:	c1 e8 10             	shr    $0x10,%eax
80107ccc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107cd0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107cd3:	0f 01 10             	lgdtl  (%eax)
}
80107cd6:	90                   	nop
80107cd7:	c9                   	leave
80107cd8:	c3                   	ret

80107cd9 <ltr>:
{
80107cd9:	55                   	push   %ebp
80107cda:	89 e5                	mov    %esp,%ebp
80107cdc:	83 ec 04             	sub    $0x4,%esp
80107cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ce6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107cea:	0f 00 d8             	ltr    %eax
}
80107ced:	90                   	nop
80107cee:	c9                   	leave
80107cef:	c3                   	ret

80107cf0 <lcr3>:

static inline void
lcr3(uint val)
{
80107cf0:	55                   	push   %ebp
80107cf1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf6:	0f 22 d8             	mov    %eax,%cr3
}
80107cf9:	90                   	nop
80107cfa:	5d                   	pop    %ebp
80107cfb:	c3                   	ret

80107cfc <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cfc:	f3 0f 1e fb          	endbr32
80107d00:	55                   	push   %ebp
80107d01:	89 e5                	mov    %esp,%ebp
80107d03:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107d06:	e8 03 be ff ff       	call   80103b0e <cpuid>
80107d0b:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107d11:	05 e0 9c 19 80       	add    $0x80199ce0,%eax
80107d16:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d25:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d39:	83 e2 f0             	and    $0xfffffff0,%edx
80107d3c:	83 ca 0a             	or     $0xa,%edx
80107d3f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d49:	83 ca 10             	or     $0x10,%edx
80107d4c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d52:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d56:	83 e2 9f             	and    $0xffffff9f,%edx
80107d59:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d63:	83 ca 80             	or     $0xffffff80,%edx
80107d66:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d70:	83 ca 0f             	or     $0xf,%edx
80107d73:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d79:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d7d:	83 e2 ef             	and    $0xffffffef,%edx
80107d80:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d86:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d8a:	83 e2 df             	and    $0xffffffdf,%edx
80107d8d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d93:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d97:	83 ca 40             	or     $0x40,%edx
80107d9a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107da4:	83 ca 80             	or     $0xffffff80,%edx
80107da7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dad:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107dbb:	ff ff 
80107dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107dc7:	00 00 
80107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ddd:	83 e2 f0             	and    $0xfffffff0,%edx
80107de0:	83 ca 02             	or     $0x2,%edx
80107de3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107df3:	83 ca 10             	or     $0x10,%edx
80107df6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e06:	83 e2 9f             	and    $0xffffff9f,%edx
80107e09:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107e19:	83 ca 80             	or     $0xffffff80,%edx
80107e1c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e2c:	83 ca 0f             	or     $0xf,%edx
80107e2f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e3f:	83 e2 ef             	and    $0xffffffef,%edx
80107e42:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e52:	83 e2 df             	and    $0xffffffdf,%edx
80107e55:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e65:	83 ca 40             	or     $0x40,%edx
80107e68:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e78:	83 ca 80             	or     $0xffffff80,%edx
80107e7b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107e95:	ff ff 
80107e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9a:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107ea1:	00 00 
80107ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea6:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eb7:	83 e2 f0             	and    $0xfffffff0,%edx
80107eba:	83 ca 0a             	or     $0xa,%edx
80107ebd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ecd:	83 ca 10             	or     $0x10,%edx
80107ed0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ee0:	83 ca 60             	or     $0x60,%edx
80107ee3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eec:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ef3:	83 ca 80             	or     $0xffffff80,%edx
80107ef6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f06:	83 ca 0f             	or     $0xf,%edx
80107f09:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f19:	83 e2 ef             	and    $0xffffffef,%edx
80107f1c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f25:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f2c:	83 e2 df             	and    $0xffffffdf,%edx
80107f2f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f38:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f3f:	83 ca 40             	or     $0x40,%edx
80107f42:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f52:	83 ca 80             	or     $0xffffff80,%edx
80107f55:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f68:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f6f:	ff ff 
80107f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f74:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f7b:	00 00 
80107f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f80:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f91:	83 e2 f0             	and    $0xfffffff0,%edx
80107f94:	83 ca 02             	or     $0x2,%edx
80107f97:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fa7:	83 ca 10             	or     $0x10,%edx
80107faa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fba:	83 ca 60             	or     $0x60,%edx
80107fbd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fcd:	83 ca 80             	or     $0xffffff80,%edx
80107fd0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fe0:	83 ca 0f             	or     $0xf,%edx
80107fe3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ff3:	83 e2 ef             	and    $0xffffffef,%edx
80107ff6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108006:	83 e2 df             	and    $0xffffffdf,%edx
80108009:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010800f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108012:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108019:	83 ca 40             	or     $0x40,%edx
8010801c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108025:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010802c:	83 ca 80             	or     $0xffffff80,%edx
8010802f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010803f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108042:	83 c0 70             	add    $0x70,%eax
80108045:	83 ec 08             	sub    $0x8,%esp
80108048:	6a 30                	push   $0x30
8010804a:	50                   	push   %eax
8010804b:	e8 5f fc ff ff       	call   80107caf <lgdt>
80108050:	83 c4 10             	add    $0x10,%esp
}
80108053:	90                   	nop
80108054:	c9                   	leave
80108055:	c3                   	ret

80108056 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108056:	f3 0f 1e fb          	endbr32
8010805a:	55                   	push   %ebp
8010805b:	89 e5                	mov    %esp,%ebp
8010805d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108060:	8b 45 0c             	mov    0xc(%ebp),%eax
80108063:	c1 e8 16             	shr    $0x16,%eax
80108066:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010806d:	8b 45 08             	mov    0x8(%ebp),%eax
80108070:	01 d0                	add    %edx,%eax
80108072:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108075:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108078:	8b 00                	mov    (%eax),%eax
8010807a:	83 e0 01             	and    $0x1,%eax
8010807d:	85 c0                	test   %eax,%eax
8010807f:	74 14                	je     80108095 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108084:	8b 00                	mov    (%eax),%eax
80108086:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010808b:	05 00 00 00 80       	add    $0x80000000,%eax
80108090:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108093:	eb 42                	jmp    801080d7 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108095:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108099:	74 0e                	je     801080a9 <walkpgdir+0x53>
8010809b:	e8 f2 a7 ff ff       	call   80102892 <kalloc>
801080a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080a7:	75 07                	jne    801080b0 <walkpgdir+0x5a>
      return 0;
801080a9:	b8 00 00 00 00       	mov    $0x0,%eax
801080ae:	eb 3e                	jmp    801080ee <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801080b0:	83 ec 04             	sub    $0x4,%esp
801080b3:	68 00 10 00 00       	push   $0x1000
801080b8:	6a 00                	push   $0x0
801080ba:	ff 75 f4             	push   -0xc(%ebp)
801080bd:	e8 44 d5 ff ff       	call   80105606 <memset>
801080c2:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801080c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c8:	05 00 00 00 80       	add    $0x80000000,%eax
801080cd:	83 c8 07             	or     $0x7,%eax
801080d0:	89 c2                	mov    %eax,%edx
801080d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801080da:	c1 e8 0c             	shr    $0xc,%eax
801080dd:	25 ff 03 00 00       	and    $0x3ff,%eax
801080e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ec:	01 d0                	add    %edx,%eax
}
801080ee:	c9                   	leave
801080ef:	c3                   	ret

801080f0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080f0:	f3 0f 1e fb          	endbr32
801080f4:	55                   	push   %ebp
801080f5:	89 e5                	mov    %esp,%ebp
801080f7:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801080fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801080fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108102:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108105:	8b 55 0c             	mov    0xc(%ebp),%edx
80108108:	8b 45 10             	mov    0x10(%ebp),%eax
8010810b:	01 d0                	add    %edx,%eax
8010810d:	83 e8 01             	sub    $0x1,%eax
80108110:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108115:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108118:	83 ec 04             	sub    $0x4,%esp
8010811b:	6a 01                	push   $0x1
8010811d:	ff 75 f4             	push   -0xc(%ebp)
80108120:	ff 75 08             	push   0x8(%ebp)
80108123:	e8 2e ff ff ff       	call   80108056 <walkpgdir>
80108128:	83 c4 10             	add    $0x10,%esp
8010812b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010812e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108132:	75 07                	jne    8010813b <mappages+0x4b>
      return -1;
80108134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108139:	eb 47                	jmp    80108182 <mappages+0x92>
    if(*pte & PTE_P)
8010813b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010813e:	8b 00                	mov    (%eax),%eax
80108140:	83 e0 01             	and    $0x1,%eax
80108143:	85 c0                	test   %eax,%eax
80108145:	74 0d                	je     80108154 <mappages+0x64>
      panic("remap");
80108147:	83 ec 0c             	sub    $0xc,%esp
8010814a:	68 9c b6 10 80       	push   $0x8010b69c
8010814f:	e8 71 84 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80108154:	8b 45 18             	mov    0x18(%ebp),%eax
80108157:	0b 45 14             	or     0x14(%ebp),%eax
8010815a:	83 c8 01             	or     $0x1,%eax
8010815d:	89 c2                	mov    %eax,%edx
8010815f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108162:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108167:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010816a:	74 10                	je     8010817c <mappages+0x8c>
      break;
    a += PGSIZE;
8010816c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108173:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010817a:	eb 9c                	jmp    80108118 <mappages+0x28>
      break;
8010817c:	90                   	nop
  }
  return 0;
8010817d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108182:	c9                   	leave
80108183:	c3                   	ret

80108184 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108184:	f3 0f 1e fb          	endbr32
80108188:	55                   	push   %ebp
80108189:	89 e5                	mov    %esp,%ebp
8010818b:	53                   	push   %ebx
8010818c:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010818f:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80108196:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
8010819b:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801081a0:	29 c2                	sub    %eax,%edx
801081a2:	89 d0                	mov    %edx,%eax
801081a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801081a7:	a1 98 9d 19 80       	mov    0x80199d98,%eax
801081ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801081af:	8b 15 98 9d 19 80    	mov    0x80199d98,%edx
801081b5:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
801081ba:	01 d0                	add    %edx,%eax
801081bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
801081bf:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801081c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c9:	83 c0 30             	add    $0x30,%eax
801081cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801081cf:	89 10                	mov    %edx,(%eax)
801081d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801081d4:	89 50 04             	mov    %edx,0x4(%eax)
801081d7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801081da:	89 50 08             	mov    %edx,0x8(%eax)
801081dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801081e0:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801081e3:	e8 aa a6 ff ff       	call   80102892 <kalloc>
801081e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ef:	75 07                	jne    801081f8 <setupkvm+0x74>
    return 0;
801081f1:	b8 00 00 00 00       	mov    $0x0,%eax
801081f6:	eb 78                	jmp    80108270 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
801081f8:	83 ec 04             	sub    $0x4,%esp
801081fb:	68 00 10 00 00       	push   $0x1000
80108200:	6a 00                	push   $0x0
80108202:	ff 75 f0             	push   -0x10(%ebp)
80108205:	e8 fc d3 ff ff       	call   80105606 <memset>
8010820a:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010820d:	c7 45 f4 a0 04 11 80 	movl   $0x801104a0,-0xc(%ebp)
80108214:	eb 4e                	jmp    80108264 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108219:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010821c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821f:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108225:	8b 58 08             	mov    0x8(%eax),%ebx
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	8b 40 04             	mov    0x4(%eax),%eax
8010822e:	29 c3                	sub    %eax,%ebx
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	8b 00                	mov    (%eax),%eax
80108235:	83 ec 0c             	sub    $0xc,%esp
80108238:	51                   	push   %ecx
80108239:	52                   	push   %edx
8010823a:	53                   	push   %ebx
8010823b:	50                   	push   %eax
8010823c:	ff 75 f0             	push   -0x10(%ebp)
8010823f:	e8 ac fe ff ff       	call   801080f0 <mappages>
80108244:	83 c4 20             	add    $0x20,%esp
80108247:	85 c0                	test   %eax,%eax
80108249:	79 15                	jns    80108260 <setupkvm+0xdc>
      freevm(pgdir);
8010824b:	83 ec 0c             	sub    $0xc,%esp
8010824e:	ff 75 f0             	push   -0x10(%ebp)
80108251:	e8 11 05 00 00       	call   80108767 <freevm>
80108256:	83 c4 10             	add    $0x10,%esp
      return 0;
80108259:	b8 00 00 00 00       	mov    $0x0,%eax
8010825e:	eb 10                	jmp    80108270 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108260:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108264:	81 7d f4 00 05 11 80 	cmpl   $0x80110500,-0xc(%ebp)
8010826b:	72 a9                	jb     80108216 <setupkvm+0x92>
    }
  return pgdir;
8010826d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108273:	c9                   	leave
80108274:	c3                   	ret

80108275 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108275:	f3 0f 1e fb          	endbr32
80108279:	55                   	push   %ebp
8010827a:	89 e5                	mov    %esp,%ebp
8010827c:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010827f:	e8 00 ff ff ff       	call   80108184 <setupkvm>
80108284:	a3 a4 9c 19 80       	mov    %eax,0x80199ca4
  switchkvm();
80108289:	e8 03 00 00 00       	call   80108291 <switchkvm>
}
8010828e:	90                   	nop
8010828f:	c9                   	leave
80108290:	c3                   	ret

80108291 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108291:	f3 0f 1e fb          	endbr32
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108298:	a1 a4 9c 19 80       	mov    0x80199ca4,%eax
8010829d:	05 00 00 00 80       	add    $0x80000000,%eax
801082a2:	50                   	push   %eax
801082a3:	e8 48 fa ff ff       	call   80107cf0 <lcr3>
801082a8:	83 c4 04             	add    $0x4,%esp
}
801082ab:	90                   	nop
801082ac:	c9                   	leave
801082ad:	c3                   	ret

801082ae <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082ae:	f3 0f 1e fb          	endbr32
801082b2:	55                   	push   %ebp
801082b3:	89 e5                	mov    %esp,%ebp
801082b5:	56                   	push   %esi
801082b6:	53                   	push   %ebx
801082b7:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801082ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082be:	75 0d                	jne    801082cd <switchuvm+0x1f>
    panic("switchuvm: no process");
801082c0:	83 ec 0c             	sub    $0xc,%esp
801082c3:	68 a2 b6 10 80       	push   $0x8010b6a2
801082c8:	e8 f8 82 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801082cd:	8b 45 08             	mov    0x8(%ebp),%eax
801082d0:	8b 40 08             	mov    0x8(%eax),%eax
801082d3:	85 c0                	test   %eax,%eax
801082d5:	75 0d                	jne    801082e4 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801082d7:	83 ec 0c             	sub    $0xc,%esp
801082da:	68 b8 b6 10 80       	push   $0x8010b6b8
801082df:	e8 e1 82 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801082e4:	8b 45 08             	mov    0x8(%ebp),%eax
801082e7:	8b 40 04             	mov    0x4(%eax),%eax
801082ea:	85 c0                	test   %eax,%eax
801082ec:	75 0d                	jne    801082fb <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801082ee:	83 ec 0c             	sub    $0xc,%esp
801082f1:	68 cd b6 10 80       	push   $0x8010b6cd
801082f6:	e8 ca 82 ff ff       	call   801005c5 <panic>

  pushcli();
801082fb:	e8 f3 d1 ff ff       	call   801054f3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108300:	e8 28 b8 ff ff       	call   80103b2d <mycpu>
80108305:	89 c3                	mov    %eax,%ebx
80108307:	e8 21 b8 ff ff       	call   80103b2d <mycpu>
8010830c:	83 c0 08             	add    $0x8,%eax
8010830f:	89 c6                	mov    %eax,%esi
80108311:	e8 17 b8 ff ff       	call   80103b2d <mycpu>
80108316:	83 c0 08             	add    $0x8,%eax
80108319:	c1 e8 10             	shr    $0x10,%eax
8010831c:	88 45 f7             	mov    %al,-0x9(%ebp)
8010831f:	e8 09 b8 ff ff       	call   80103b2d <mycpu>
80108324:	83 c0 08             	add    $0x8,%eax
80108327:	c1 e8 18             	shr    $0x18,%eax
8010832a:	89 c2                	mov    %eax,%edx
8010832c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108333:	67 00 
80108335:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010833c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108340:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108346:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010834d:	83 e0 f0             	and    $0xfffffff0,%eax
80108350:	83 c8 09             	or     $0x9,%eax
80108353:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108359:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108360:	83 c8 10             	or     $0x10,%eax
80108363:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108369:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108370:	83 e0 9f             	and    $0xffffff9f,%eax
80108373:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108379:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108380:	83 c8 80             	or     $0xffffff80,%eax
80108383:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108389:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108390:	83 e0 f0             	and    $0xfffffff0,%eax
80108393:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108399:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801083a0:	83 e0 ef             	and    $0xffffffef,%eax
801083a3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801083a9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801083b0:	83 e0 df             	and    $0xffffffdf,%eax
801083b3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801083b9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801083c0:	83 c8 40             	or     $0x40,%eax
801083c3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801083c9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801083d0:	83 e0 7f             	and    $0x7f,%eax
801083d3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801083d9:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801083df:	e8 49 b7 ff ff       	call   80103b2d <mycpu>
801083e4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083eb:	83 e2 ef             	and    $0xffffffef,%edx
801083ee:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801083f4:	e8 34 b7 ff ff       	call   80103b2d <mycpu>
801083f9:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801083ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108402:	8b 40 08             	mov    0x8(%eax),%eax
80108405:	89 c3                	mov    %eax,%ebx
80108407:	e8 21 b7 ff ff       	call   80103b2d <mycpu>
8010840c:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108412:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108415:	e8 13 b7 ff ff       	call   80103b2d <mycpu>
8010841a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108420:	83 ec 0c             	sub    $0xc,%esp
80108423:	6a 28                	push   $0x28
80108425:	e8 af f8 ff ff       	call   80107cd9 <ltr>
8010842a:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010842d:	8b 45 08             	mov    0x8(%ebp),%eax
80108430:	8b 40 04             	mov    0x4(%eax),%eax
80108433:	05 00 00 00 80       	add    $0x80000000,%eax
80108438:	83 ec 0c             	sub    $0xc,%esp
8010843b:	50                   	push   %eax
8010843c:	e8 af f8 ff ff       	call   80107cf0 <lcr3>
80108441:	83 c4 10             	add    $0x10,%esp
  popcli();
80108444:	e8 fb d0 ff ff       	call   80105544 <popcli>
}
80108449:	90                   	nop
8010844a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010844d:	5b                   	pop    %ebx
8010844e:	5e                   	pop    %esi
8010844f:	5d                   	pop    %ebp
80108450:	c3                   	ret

80108451 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108451:	f3 0f 1e fb          	endbr32
80108455:	55                   	push   %ebp
80108456:	89 e5                	mov    %esp,%ebp
80108458:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010845b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108462:	76 0d                	jbe    80108471 <inituvm+0x20>
    panic("inituvm: more than a page");
80108464:	83 ec 0c             	sub    $0xc,%esp
80108467:	68 e1 b6 10 80       	push   $0x8010b6e1
8010846c:	e8 54 81 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80108471:	e8 1c a4 ff ff       	call   80102892 <kalloc>
80108476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108479:	83 ec 04             	sub    $0x4,%esp
8010847c:	68 00 10 00 00       	push   $0x1000
80108481:	6a 00                	push   $0x0
80108483:	ff 75 f4             	push   -0xc(%ebp)
80108486:	e8 7b d1 ff ff       	call   80105606 <memset>
8010848b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010848e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108491:	05 00 00 00 80       	add    $0x80000000,%eax
80108496:	83 ec 0c             	sub    $0xc,%esp
80108499:	6a 06                	push   $0x6
8010849b:	50                   	push   %eax
8010849c:	68 00 10 00 00       	push   $0x1000
801084a1:	6a 00                	push   $0x0
801084a3:	ff 75 08             	push   0x8(%ebp)
801084a6:	e8 45 fc ff ff       	call   801080f0 <mappages>
801084ab:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801084ae:	83 ec 04             	sub    $0x4,%esp
801084b1:	ff 75 10             	push   0x10(%ebp)
801084b4:	ff 75 0c             	push   0xc(%ebp)
801084b7:	ff 75 f4             	push   -0xc(%ebp)
801084ba:	e8 0e d2 ff ff       	call   801056cd <memmove>
801084bf:	83 c4 10             	add    $0x10,%esp
}
801084c2:	90                   	nop
801084c3:	c9                   	leave
801084c4:	c3                   	ret

801084c5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084c5:	f3 0f 1e fb          	endbr32
801084c9:	55                   	push   %ebp
801084ca:	89 e5                	mov    %esp,%ebp
801084cc:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d2:	25 ff 0f 00 00       	and    $0xfff,%eax
801084d7:	85 c0                	test   %eax,%eax
801084d9:	74 0d                	je     801084e8 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801084db:	83 ec 0c             	sub    $0xc,%esp
801084de:	68 fc b6 10 80       	push   $0x8010b6fc
801084e3:	e8 dd 80 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084ef:	e9 8f 00 00 00       	jmp    80108583 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801084f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fa:	01 d0                	add    %edx,%eax
801084fc:	83 ec 04             	sub    $0x4,%esp
801084ff:	6a 00                	push   $0x0
80108501:	50                   	push   %eax
80108502:	ff 75 08             	push   0x8(%ebp)
80108505:	e8 4c fb ff ff       	call   80108056 <walkpgdir>
8010850a:	83 c4 10             	add    $0x10,%esp
8010850d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108510:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108514:	75 0d                	jne    80108523 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108516:	83 ec 0c             	sub    $0xc,%esp
80108519:	68 1f b7 10 80       	push   $0x8010b71f
8010851e:	e8 a2 80 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108523:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108526:	8b 00                	mov    (%eax),%eax
80108528:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108530:	8b 45 18             	mov    0x18(%ebp),%eax
80108533:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108536:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010853b:	77 0b                	ja     80108548 <loaduvm+0x83>
      n = sz - i;
8010853d:	8b 45 18             	mov    0x18(%ebp),%eax
80108540:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108543:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108546:	eb 07                	jmp    8010854f <loaduvm+0x8a>
    else
      n = PGSIZE;
80108548:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010854f:	8b 55 14             	mov    0x14(%ebp),%edx
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	01 d0                	add    %edx,%eax
80108557:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010855a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108560:	ff 75 f0             	push   -0x10(%ebp)
80108563:	50                   	push   %eax
80108564:	52                   	push   %edx
80108565:	ff 75 10             	push   0x10(%ebp)
80108568:	e8 17 9a ff ff       	call   80101f84 <readi>
8010856d:	83 c4 10             	add    $0x10,%esp
80108570:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108573:	74 07                	je     8010857c <loaduvm+0xb7>
      return -1;
80108575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010857a:	eb 18                	jmp    80108594 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010857c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108586:	3b 45 18             	cmp    0x18(%ebp),%eax
80108589:	0f 82 65 ff ff ff    	jb     801084f4 <loaduvm+0x2f>
  }
  return 0;
8010858f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108594:	c9                   	leave
80108595:	c3                   	ret

80108596 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108596:	f3 0f 1e fb          	endbr32
8010859a:	55                   	push   %ebp
8010859b:	89 e5                	mov    %esp,%ebp
8010859d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801085a0:	8b 45 10             	mov    0x10(%ebp),%eax
801085a3:	85 c0                	test   %eax,%eax
801085a5:	79 0a                	jns    801085b1 <allocuvm+0x1b>
    return 0;
801085a7:	b8 00 00 00 00       	mov    $0x0,%eax
801085ac:	e9 ec 00 00 00       	jmp    8010869d <allocuvm+0x107>
  if(newsz < oldsz)
801085b1:	8b 45 10             	mov    0x10(%ebp),%eax
801085b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085b7:	73 08                	jae    801085c1 <allocuvm+0x2b>
    return oldsz;
801085b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085bc:	e9 dc 00 00 00       	jmp    8010869d <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801085c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c4:	05 ff 0f 00 00       	add    $0xfff,%eax
801085c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085d1:	e9 b8 00 00 00       	jmp    8010868e <allocuvm+0xf8>
    mem = kalloc();
801085d6:	e8 b7 a2 ff ff       	call   80102892 <kalloc>
801085db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085e2:	75 2e                	jne    80108612 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801085e4:	83 ec 0c             	sub    $0xc,%esp
801085e7:	68 3d b7 10 80       	push   $0x8010b73d
801085ec:	e8 1b 7e ff ff       	call   8010040c <cprintf>
801085f1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085f4:	83 ec 04             	sub    $0x4,%esp
801085f7:	ff 75 0c             	push   0xc(%ebp)
801085fa:	ff 75 10             	push   0x10(%ebp)
801085fd:	ff 75 08             	push   0x8(%ebp)
80108600:	e8 9a 00 00 00       	call   8010869f <deallocuvm>
80108605:	83 c4 10             	add    $0x10,%esp
      return 0;
80108608:	b8 00 00 00 00       	mov    $0x0,%eax
8010860d:	e9 8b 00 00 00       	jmp    8010869d <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108612:	83 ec 04             	sub    $0x4,%esp
80108615:	68 00 10 00 00       	push   $0x1000
8010861a:	6a 00                	push   $0x0
8010861c:	ff 75 f0             	push   -0x10(%ebp)
8010861f:	e8 e2 cf ff ff       	call   80105606 <memset>
80108624:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108633:	83 ec 0c             	sub    $0xc,%esp
80108636:	6a 06                	push   $0x6
80108638:	52                   	push   %edx
80108639:	68 00 10 00 00       	push   $0x1000
8010863e:	50                   	push   %eax
8010863f:	ff 75 08             	push   0x8(%ebp)
80108642:	e8 a9 fa ff ff       	call   801080f0 <mappages>
80108647:	83 c4 20             	add    $0x20,%esp
8010864a:	85 c0                	test   %eax,%eax
8010864c:	79 39                	jns    80108687 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010864e:	83 ec 0c             	sub    $0xc,%esp
80108651:	68 55 b7 10 80       	push   $0x8010b755
80108656:	e8 b1 7d ff ff       	call   8010040c <cprintf>
8010865b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010865e:	83 ec 04             	sub    $0x4,%esp
80108661:	ff 75 0c             	push   0xc(%ebp)
80108664:	ff 75 10             	push   0x10(%ebp)
80108667:	ff 75 08             	push   0x8(%ebp)
8010866a:	e8 30 00 00 00       	call   8010869f <deallocuvm>
8010866f:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108672:	83 ec 0c             	sub    $0xc,%esp
80108675:	ff 75 f0             	push   -0x10(%ebp)
80108678:	e8 77 a1 ff ff       	call   801027f4 <kfree>
8010867d:	83 c4 10             	add    $0x10,%esp
      return 0;
80108680:	b8 00 00 00 00       	mov    $0x0,%eax
80108685:	eb 16                	jmp    8010869d <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108687:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010868e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108691:	3b 45 10             	cmp    0x10(%ebp),%eax
80108694:	0f 82 3c ff ff ff    	jb     801085d6 <allocuvm+0x40>
    }
  }
  return newsz;
8010869a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010869d:	c9                   	leave
8010869e:	c3                   	ret

8010869f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010869f:	f3 0f 1e fb          	endbr32
801086a3:	55                   	push   %ebp
801086a4:	89 e5                	mov    %esp,%ebp
801086a6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801086a9:	8b 45 10             	mov    0x10(%ebp),%eax
801086ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086af:	72 08                	jb     801086b9 <deallocuvm+0x1a>
    return oldsz;
801086b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b4:	e9 ac 00 00 00       	jmp    80108765 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
801086b9:	8b 45 10             	mov    0x10(%ebp),%eax
801086bc:	05 ff 0f 00 00       	add    $0xfff,%eax
801086c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801086c9:	e9 88 00 00 00       	jmp    80108756 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
801086ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d1:	83 ec 04             	sub    $0x4,%esp
801086d4:	6a 00                	push   $0x0
801086d6:	50                   	push   %eax
801086d7:	ff 75 08             	push   0x8(%ebp)
801086da:	e8 77 f9 ff ff       	call   80108056 <walkpgdir>
801086df:	83 c4 10             	add    $0x10,%esp
801086e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801086e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086e9:	75 16                	jne    80108701 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801086eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ee:	c1 e8 16             	shr    $0x16,%eax
801086f1:	83 c0 01             	add    $0x1,%eax
801086f4:	c1 e0 16             	shl    $0x16,%eax
801086f7:	2d 00 10 00 00       	sub    $0x1000,%eax
801086fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086ff:	eb 4e                	jmp    8010874f <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80108701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108704:	8b 00                	mov    (%eax),%eax
80108706:	83 e0 01             	and    $0x1,%eax
80108709:	85 c0                	test   %eax,%eax
8010870b:	74 42                	je     8010874f <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
8010870d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108710:	8b 00                	mov    (%eax),%eax
80108712:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108717:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010871a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010871e:	75 0d                	jne    8010872d <deallocuvm+0x8e>
        panic("kfree");
80108720:	83 ec 0c             	sub    $0xc,%esp
80108723:	68 71 b7 10 80       	push   $0x8010b771
80108728:	e8 98 7e ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
8010872d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108730:	05 00 00 00 80       	add    $0x80000000,%eax
80108735:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108738:	83 ec 0c             	sub    $0xc,%esp
8010873b:	ff 75 e8             	push   -0x18(%ebp)
8010873e:	e8 b1 a0 ff ff       	call   801027f4 <kfree>
80108743:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108749:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010874f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108759:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010875c:	0f 82 6c ff ff ff    	jb     801086ce <deallocuvm+0x2f>
    }
  }
  return newsz;
80108762:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108765:	c9                   	leave
80108766:	c3                   	ret

80108767 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108767:	f3 0f 1e fb          	endbr32
8010876b:	55                   	push   %ebp
8010876c:	89 e5                	mov    %esp,%ebp
8010876e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108771:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108775:	75 0d                	jne    80108784 <freevm+0x1d>
    panic("freevm: no pgdir");
80108777:	83 ec 0c             	sub    $0xc,%esp
8010877a:	68 77 b7 10 80       	push   $0x8010b777
8010877f:	e8 41 7e ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108784:	83 ec 04             	sub    $0x4,%esp
80108787:	6a 00                	push   $0x0
80108789:	68 00 00 00 80       	push   $0x80000000
8010878e:	ff 75 08             	push   0x8(%ebp)
80108791:	e8 09 ff ff ff       	call   8010869f <deallocuvm>
80108796:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108799:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087a0:	eb 48                	jmp    801087ea <freevm+0x83>
    if(pgdir[i] & PTE_P){
801087a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087ac:	8b 45 08             	mov    0x8(%ebp),%eax
801087af:	01 d0                	add    %edx,%eax
801087b1:	8b 00                	mov    (%eax),%eax
801087b3:	83 e0 01             	and    $0x1,%eax
801087b6:	85 c0                	test   %eax,%eax
801087b8:	74 2c                	je     801087e6 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801087ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087c4:	8b 45 08             	mov    0x8(%ebp),%eax
801087c7:	01 d0                	add    %edx,%eax
801087c9:	8b 00                	mov    (%eax),%eax
801087cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087d0:	05 00 00 00 80       	add    $0x80000000,%eax
801087d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087d8:	83 ec 0c             	sub    $0xc,%esp
801087db:	ff 75 f0             	push   -0x10(%ebp)
801087de:	e8 11 a0 ff ff       	call   801027f4 <kfree>
801087e3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801087e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087ea:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087f1:	76 af                	jbe    801087a2 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801087f3:	83 ec 0c             	sub    $0xc,%esp
801087f6:	ff 75 08             	push   0x8(%ebp)
801087f9:	e8 f6 9f ff ff       	call   801027f4 <kfree>
801087fe:	83 c4 10             	add    $0x10,%esp
}
80108801:	90                   	nop
80108802:	c9                   	leave
80108803:	c3                   	ret

80108804 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108804:	f3 0f 1e fb          	endbr32
80108808:	55                   	push   %ebp
80108809:	89 e5                	mov    %esp,%ebp
8010880b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010880e:	83 ec 04             	sub    $0x4,%esp
80108811:	6a 00                	push   $0x0
80108813:	ff 75 0c             	push   0xc(%ebp)
80108816:	ff 75 08             	push   0x8(%ebp)
80108819:	e8 38 f8 ff ff       	call   80108056 <walkpgdir>
8010881e:	83 c4 10             	add    $0x10,%esp
80108821:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108824:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108828:	75 0d                	jne    80108837 <clearpteu+0x33>
    panic("clearpteu");
8010882a:	83 ec 0c             	sub    $0xc,%esp
8010882d:	68 88 b7 10 80       	push   $0x8010b788
80108832:	e8 8e 7d ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80108837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883a:	8b 00                	mov    (%eax),%eax
8010883c:	83 e0 fb             	and    $0xfffffffb,%eax
8010883f:	89 c2                	mov    %eax,%edx
80108841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108844:	89 10                	mov    %edx,(%eax)
}
80108846:	90                   	nop
80108847:	c9                   	leave
80108848:	c3                   	ret

80108849 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108849:	f3 0f 1e fb          	endbr32
8010884d:	55                   	push   %ebp
8010884e:	89 e5                	mov    %esp,%ebp
80108850:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108853:	e8 2c f9 ff ff       	call   80108184 <setupkvm>
80108858:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010885b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010885f:	75 0a                	jne    8010886b <copyuvm+0x22>
    return 0;
80108861:	b8 00 00 00 00       	mov    $0x0,%eax
80108866:	e9 eb 00 00 00       	jmp    80108956 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
8010886b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108872:	e9 b7 00 00 00       	jmp    8010892e <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887a:	83 ec 04             	sub    $0x4,%esp
8010887d:	6a 00                	push   $0x0
8010887f:	50                   	push   %eax
80108880:	ff 75 08             	push   0x8(%ebp)
80108883:	e8 ce f7 ff ff       	call   80108056 <walkpgdir>
80108888:	83 c4 10             	add    $0x10,%esp
8010888b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010888e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108892:	75 0d                	jne    801088a1 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108894:	83 ec 0c             	sub    $0xc,%esp
80108897:	68 92 b7 10 80       	push   $0x8010b792
8010889c:	e8 24 7d ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
801088a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a4:	8b 00                	mov    (%eax),%eax
801088a6:	83 e0 01             	and    $0x1,%eax
801088a9:	85 c0                	test   %eax,%eax
801088ab:	75 0d                	jne    801088ba <copyuvm+0x71>
      panic("copyuvm: page not present");
801088ad:	83 ec 0c             	sub    $0xc,%esp
801088b0:	68 ac b7 10 80       	push   $0x8010b7ac
801088b5:	e8 0b 7d ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801088ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088bd:	8b 00                	mov    (%eax),%eax
801088bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801088c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ca:	8b 00                	mov    (%eax),%eax
801088cc:	25 ff 0f 00 00       	and    $0xfff,%eax
801088d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801088d4:	e8 b9 9f ff ff       	call   80102892 <kalloc>
801088d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801088dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088e0:	74 5d                	je     8010893f <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801088e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088e5:	05 00 00 00 80       	add    $0x80000000,%eax
801088ea:	83 ec 04             	sub    $0x4,%esp
801088ed:	68 00 10 00 00       	push   $0x1000
801088f2:	50                   	push   %eax
801088f3:	ff 75 e0             	push   -0x20(%ebp)
801088f6:	e8 d2 cd ff ff       	call   801056cd <memmove>
801088fb:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801088fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108901:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108904:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010890a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890d:	83 ec 0c             	sub    $0xc,%esp
80108910:	52                   	push   %edx
80108911:	51                   	push   %ecx
80108912:	68 00 10 00 00       	push   $0x1000
80108917:	50                   	push   %eax
80108918:	ff 75 f0             	push   -0x10(%ebp)
8010891b:	e8 d0 f7 ff ff       	call   801080f0 <mappages>
80108920:	83 c4 20             	add    $0x20,%esp
80108923:	85 c0                	test   %eax,%eax
80108925:	78 1b                	js     80108942 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80108927:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010892e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108931:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108934:	0f 82 3d ff ff ff    	jb     80108877 <copyuvm+0x2e>
      goto bad;
  }
  return d;
8010893a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010893d:	eb 17                	jmp    80108956 <copyuvm+0x10d>
      goto bad;
8010893f:	90                   	nop
80108940:	eb 01                	jmp    80108943 <copyuvm+0xfa>
      goto bad;
80108942:	90                   	nop

bad:
  freevm(d);
80108943:	83 ec 0c             	sub    $0xc,%esp
80108946:	ff 75 f0             	push   -0x10(%ebp)
80108949:	e8 19 fe ff ff       	call   80108767 <freevm>
8010894e:	83 c4 10             	add    $0x10,%esp
  return 0;
80108951:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108956:	c9                   	leave
80108957:	c3                   	ret

80108958 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108958:	f3 0f 1e fb          	endbr32
8010895c:	55                   	push   %ebp
8010895d:	89 e5                	mov    %esp,%ebp
8010895f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108962:	83 ec 04             	sub    $0x4,%esp
80108965:	6a 00                	push   $0x0
80108967:	ff 75 0c             	push   0xc(%ebp)
8010896a:	ff 75 08             	push   0x8(%ebp)
8010896d:	e8 e4 f6 ff ff       	call   80108056 <walkpgdir>
80108972:	83 c4 10             	add    $0x10,%esp
80108975:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897b:	8b 00                	mov    (%eax),%eax
8010897d:	83 e0 01             	and    $0x1,%eax
80108980:	85 c0                	test   %eax,%eax
80108982:	75 07                	jne    8010898b <uva2ka+0x33>
    return 0;
80108984:	b8 00 00 00 00       	mov    $0x0,%eax
80108989:	eb 22                	jmp    801089ad <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	8b 00                	mov    (%eax),%eax
80108990:	83 e0 04             	and    $0x4,%eax
80108993:	85 c0                	test   %eax,%eax
80108995:	75 07                	jne    8010899e <uva2ka+0x46>
    return 0;
80108997:	b8 00 00 00 00       	mov    $0x0,%eax
8010899c:	eb 0f                	jmp    801089ad <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
8010899e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a1:	8b 00                	mov    (%eax),%eax
801089a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089a8:	05 00 00 00 80       	add    $0x80000000,%eax
}
801089ad:	c9                   	leave
801089ae:	c3                   	ret

801089af <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801089af:	f3 0f 1e fb          	endbr32
801089b3:	55                   	push   %ebp
801089b4:	89 e5                	mov    %esp,%ebp
801089b6:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801089b9:	8b 45 10             	mov    0x10(%ebp),%eax
801089bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801089bf:	eb 7f                	jmp    80108a40 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801089c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801089c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801089cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089cf:	83 ec 08             	sub    $0x8,%esp
801089d2:	50                   	push   %eax
801089d3:	ff 75 08             	push   0x8(%ebp)
801089d6:	e8 7d ff ff ff       	call   80108958 <uva2ka>
801089db:	83 c4 10             	add    $0x10,%esp
801089de:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801089e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089e5:	75 07                	jne    801089ee <copyout+0x3f>
      return -1;
801089e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089ec:	eb 61                	jmp    80108a4f <copyout+0xa0>
    n = PGSIZE - (va - va0);
801089ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f1:	2b 45 0c             	sub    0xc(%ebp),%eax
801089f4:	05 00 10 00 00       	add    $0x1000,%eax
801089f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ff:	3b 45 14             	cmp    0x14(%ebp),%eax
80108a02:	76 06                	jbe    80108a0a <copyout+0x5b>
      n = len;
80108a04:	8b 45 14             	mov    0x14(%ebp),%eax
80108a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a0d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108a10:	89 c2                	mov    %eax,%edx
80108a12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a15:	01 d0                	add    %edx,%eax
80108a17:	83 ec 04             	sub    $0x4,%esp
80108a1a:	ff 75 f0             	push   -0x10(%ebp)
80108a1d:	ff 75 f4             	push   -0xc(%ebp)
80108a20:	50                   	push   %eax
80108a21:	e8 a7 cc ff ff       	call   801056cd <memmove>
80108a26:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a32:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a38:	05 00 10 00 00       	add    $0x1000,%eax
80108a3d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108a40:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a44:	0f 85 77 ff ff ff    	jne    801089c1 <copyout+0x12>
  }
  return 0;
80108a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a4f:	c9                   	leave
80108a50:	c3                   	ret

80108a51 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108a51:	f3 0f 1e fb          	endbr32
80108a55:	55                   	push   %ebp
80108a56:	89 e5                	mov    %esp,%ebp
80108a58:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108a5b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108a62:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a65:	8b 40 08             	mov    0x8(%eax),%eax
80108a68:	05 00 00 00 80       	add    $0x80000000,%eax
80108a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108a70:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7a:	8b 40 24             	mov    0x24(%eax),%eax
80108a7d:	a3 3c 64 19 80       	mov    %eax,0x8019643c
  ncpu = 0;
80108a82:	c7 05 94 9d 19 80 00 	movl   $0x0,0x80199d94
80108a89:	00 00 00 

  while(i<madt->len){
80108a8c:	90                   	nop
80108a8d:	e9 bd 00 00 00       	jmp    80108b4f <mpinit_uefi+0xfe>
    uchar *entry_type = ((uchar *)madt)+i;
80108a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a98:	01 d0                	add    %edx,%eax
80108a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa0:	0f b6 00             	movzbl (%eax),%eax
80108aa3:	0f b6 c0             	movzbl %al,%eax
80108aa6:	83 f8 05             	cmp    $0x5,%eax
80108aa9:	0f 87 a0 00 00 00    	ja     80108b4f <mpinit_uefi+0xfe>
80108aaf:	8b 04 85 c8 b7 10 80 	mov    -0x7fef4838(,%eax,4),%eax
80108ab6:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108abc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108abf:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108ac4:	85 c0                	test   %eax,%eax
80108ac6:	7f 28                	jg     80108af0 <mpinit_uefi+0x9f>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108ac8:	8b 15 94 9d 19 80    	mov    0x80199d94,%edx
80108ace:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ad1:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108ad5:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108adb:	81 c2 e0 9c 19 80    	add    $0x80199ce0,%edx
80108ae1:	88 02                	mov    %al,(%edx)
          ncpu++;
80108ae3:	a1 94 9d 19 80       	mov    0x80199d94,%eax
80108ae8:	83 c0 01             	add    $0x1,%eax
80108aeb:	a3 94 9d 19 80       	mov    %eax,0x80199d94
        }
        i += lapic_entry->record_len;
80108af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108af7:	0f b6 c0             	movzbl %al,%eax
80108afa:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108afd:	eb 50                	jmp    80108b4f <mpinit_uefi+0xfe>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108b05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b08:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b0c:	a2 c0 9c 19 80       	mov    %al,0x80199cc0
        i += ioapic->record_len;
80108b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b18:	0f b6 c0             	movzbl %al,%eax
80108b1b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b1e:	eb 2f                	jmp    80108b4f <mpinit_uefi+0xfe>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b23:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108b26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b29:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b2d:	0f b6 c0             	movzbl %al,%eax
80108b30:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b33:	eb 1a                	jmp    80108b4f <mpinit_uefi+0xfe>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b38:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b3e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b42:	0f b6 c0             	movzbl %al,%eax
80108b45:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108b48:	eb 05                	jmp    80108b4f <mpinit_uefi+0xfe>

      case 5:
        i = i + 0xC;
80108b4a:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108b4e:	90                   	nop
  while(i<madt->len){
80108b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b52:	8b 40 04             	mov    0x4(%eax),%eax
80108b55:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108b58:	0f 82 34 ff ff ff    	jb     80108a92 <mpinit_uefi+0x41>
    }
  }

}
80108b5e:	90                   	nop
80108b5f:	90                   	nop
80108b60:	c9                   	leave
80108b61:	c3                   	ret

80108b62 <inb>:
{
80108b62:	55                   	push   %ebp
80108b63:	89 e5                	mov    %esp,%ebp
80108b65:	83 ec 14             	sub    $0x14,%esp
80108b68:	8b 45 08             	mov    0x8(%ebp),%eax
80108b6b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108b6f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108b73:	89 c2                	mov    %eax,%edx
80108b75:	ec                   	in     (%dx),%al
80108b76:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108b79:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108b7d:	c9                   	leave
80108b7e:	c3                   	ret

80108b7f <outb>:
{
80108b7f:	55                   	push   %ebp
80108b80:	89 e5                	mov    %esp,%ebp
80108b82:	83 ec 08             	sub    $0x8,%esp
80108b85:	8b 45 08             	mov    0x8(%ebp),%eax
80108b88:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b8b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108b8f:	89 d0                	mov    %edx,%eax
80108b91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108b94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108b98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108b9c:	ee                   	out    %al,(%dx)
}
80108b9d:	90                   	nop
80108b9e:	c9                   	leave
80108b9f:	c3                   	ret

80108ba0 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108ba0:	f3 0f 1e fb          	endbr32
80108ba4:	55                   	push   %ebp
80108ba5:	89 e5                	mov    %esp,%ebp
80108ba7:	83 ec 28             	sub    $0x28,%esp
80108baa:	8b 45 08             	mov    0x8(%ebp),%eax
80108bad:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108bb0:	6a 00                	push   $0x0
80108bb2:	68 fa 03 00 00       	push   $0x3fa
80108bb7:	e8 c3 ff ff ff       	call   80108b7f <outb>
80108bbc:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108bbf:	68 80 00 00 00       	push   $0x80
80108bc4:	68 fb 03 00 00       	push   $0x3fb
80108bc9:	e8 b1 ff ff ff       	call   80108b7f <outb>
80108bce:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108bd1:	6a 0c                	push   $0xc
80108bd3:	68 f8 03 00 00       	push   $0x3f8
80108bd8:	e8 a2 ff ff ff       	call   80108b7f <outb>
80108bdd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108be0:	6a 00                	push   $0x0
80108be2:	68 f9 03 00 00       	push   $0x3f9
80108be7:	e8 93 ff ff ff       	call   80108b7f <outb>
80108bec:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108bef:	6a 03                	push   $0x3
80108bf1:	68 fb 03 00 00       	push   $0x3fb
80108bf6:	e8 84 ff ff ff       	call   80108b7f <outb>
80108bfb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108bfe:	6a 00                	push   $0x0
80108c00:	68 fc 03 00 00       	push   $0x3fc
80108c05:	e8 75 ff ff ff       	call   80108b7f <outb>
80108c0a:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108c0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c14:	eb 11                	jmp    80108c27 <uart_debug+0x87>
80108c16:	83 ec 0c             	sub    $0xc,%esp
80108c19:	6a 0a                	push   $0xa
80108c1b:	e8 24 a0 ff ff       	call   80102c44 <microdelay>
80108c20:	83 c4 10             	add    $0x10,%esp
80108c23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c27:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108c2b:	7f 1a                	jg     80108c47 <uart_debug+0xa7>
80108c2d:	83 ec 0c             	sub    $0xc,%esp
80108c30:	68 fd 03 00 00       	push   $0x3fd
80108c35:	e8 28 ff ff ff       	call   80108b62 <inb>
80108c3a:	83 c4 10             	add    $0x10,%esp
80108c3d:	0f b6 c0             	movzbl %al,%eax
80108c40:	83 e0 20             	and    $0x20,%eax
80108c43:	85 c0                	test   %eax,%eax
80108c45:	74 cf                	je     80108c16 <uart_debug+0x76>
  outb(COM1+0, p);
80108c47:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108c4b:	0f b6 c0             	movzbl %al,%eax
80108c4e:	83 ec 08             	sub    $0x8,%esp
80108c51:	50                   	push   %eax
80108c52:	68 f8 03 00 00       	push   $0x3f8
80108c57:	e8 23 ff ff ff       	call   80108b7f <outb>
80108c5c:	83 c4 10             	add    $0x10,%esp
}
80108c5f:	90                   	nop
80108c60:	c9                   	leave
80108c61:	c3                   	ret

80108c62 <uart_debugs>:

void uart_debugs(char *p){
80108c62:	f3 0f 1e fb          	endbr32
80108c66:	55                   	push   %ebp
80108c67:	89 e5                	mov    %esp,%ebp
80108c69:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108c6c:	eb 1b                	jmp    80108c89 <uart_debugs+0x27>
    uart_debug(*p++);
80108c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c71:	8d 50 01             	lea    0x1(%eax),%edx
80108c74:	89 55 08             	mov    %edx,0x8(%ebp)
80108c77:	0f b6 00             	movzbl (%eax),%eax
80108c7a:	0f be c0             	movsbl %al,%eax
80108c7d:	83 ec 0c             	sub    $0xc,%esp
80108c80:	50                   	push   %eax
80108c81:	e8 1a ff ff ff       	call   80108ba0 <uart_debug>
80108c86:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108c89:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8c:	0f b6 00             	movzbl (%eax),%eax
80108c8f:	84 c0                	test   %al,%al
80108c91:	75 db                	jne    80108c6e <uart_debugs+0xc>
  }
}
80108c93:	90                   	nop
80108c94:	90                   	nop
80108c95:	c9                   	leave
80108c96:	c3                   	ret

80108c97 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108c97:	f3 0f 1e fb          	endbr32
80108c9b:	55                   	push   %ebp
80108c9c:	89 e5                	mov    %esp,%ebp
80108c9e:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108ca1:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cab:	8b 50 14             	mov    0x14(%eax),%edx
80108cae:	8b 40 10             	mov    0x10(%eax),%eax
80108cb1:	a3 98 9d 19 80       	mov    %eax,0x80199d98
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108cb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cb9:	8b 50 1c             	mov    0x1c(%eax),%edx
80108cbc:	8b 40 18             	mov    0x18(%eax),%eax
80108cbf:	a3 a0 9d 19 80       	mov    %eax,0x80199da0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108cc4:	a1 a0 9d 19 80       	mov    0x80199da0,%eax
80108cc9:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108cce:	29 c2                	sub    %eax,%edx
80108cd0:	89 d0                	mov    %edx,%eax
80108cd2:	a3 9c 9d 19 80       	mov    %eax,0x80199d9c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108cd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cda:	8b 50 24             	mov    0x24(%eax),%edx
80108cdd:	8b 40 20             	mov    0x20(%eax),%eax
80108ce0:	a3 a4 9d 19 80       	mov    %eax,0x80199da4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ce8:	8b 50 2c             	mov    0x2c(%eax),%edx
80108ceb:	8b 40 28             	mov    0x28(%eax),%eax
80108cee:	a3 a8 9d 19 80       	mov    %eax,0x80199da8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108cf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108cf6:	8b 50 34             	mov    0x34(%eax),%edx
80108cf9:	8b 40 30             	mov    0x30(%eax),%eax
80108cfc:	a3 ac 9d 19 80       	mov    %eax,0x80199dac
}
80108d01:	90                   	nop
80108d02:	c9                   	leave
80108d03:	c3                   	ret

80108d04 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108d04:	f3 0f 1e fb          	endbr32
80108d08:	55                   	push   %ebp
80108d09:	89 e5                	mov    %esp,%ebp
80108d0b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108d0e:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108d14:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d17:	0f af d0             	imul   %eax,%edx
80108d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80108d1d:	01 d0                	add    %edx,%eax
80108d1f:	c1 e0 02             	shl    $0x2,%eax
80108d22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108d25:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108d2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108d2e:	01 d0                	add    %edx,%eax
80108d30:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108d33:	8b 45 10             	mov    0x10(%ebp),%eax
80108d36:	0f b6 10             	movzbl (%eax),%edx
80108d39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d3c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108d3e:	8b 45 10             	mov    0x10(%ebp),%eax
80108d41:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108d45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d48:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108d4b:	8b 45 10             	mov    0x10(%ebp),%eax
80108d4e:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108d52:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108d55:	88 50 02             	mov    %dl,0x2(%eax)
}
80108d58:	90                   	nop
80108d59:	c9                   	leave
80108d5a:	c3                   	ret

80108d5b <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108d5b:	f3 0f 1e fb          	endbr32
80108d5f:	55                   	push   %ebp
80108d60:	89 e5                	mov    %esp,%ebp
80108d62:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108d65:	8b 15 ac 9d 19 80    	mov    0x80199dac,%edx
80108d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d6e:	0f af c2             	imul   %edx,%eax
80108d71:	c1 e0 02             	shl    $0x2,%eax
80108d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108d77:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d80:	29 c2                	sub    %eax,%edx
80108d82:	89 d0                	mov    %edx,%eax
80108d84:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d8d:	01 ca                	add    %ecx,%edx
80108d8f:	89 d1                	mov    %edx,%ecx
80108d91:	8b 15 9c 9d 19 80    	mov    0x80199d9c,%edx
80108d97:	83 ec 04             	sub    $0x4,%esp
80108d9a:	50                   	push   %eax
80108d9b:	51                   	push   %ecx
80108d9c:	52                   	push   %edx
80108d9d:	e8 2b c9 ff ff       	call   801056cd <memmove>
80108da2:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da8:	8b 0d 9c 9d 19 80    	mov    0x80199d9c,%ecx
80108dae:	8b 15 a0 9d 19 80    	mov    0x80199da0,%edx
80108db4:	01 d1                	add    %edx,%ecx
80108db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108db9:	29 d1                	sub    %edx,%ecx
80108dbb:	89 ca                	mov    %ecx,%edx
80108dbd:	83 ec 04             	sub    $0x4,%esp
80108dc0:	50                   	push   %eax
80108dc1:	6a 00                	push   $0x0
80108dc3:	52                   	push   %edx
80108dc4:	e8 3d c8 ff ff       	call   80105606 <memset>
80108dc9:	83 c4 10             	add    $0x10,%esp
}
80108dcc:	90                   	nop
80108dcd:	c9                   	leave
80108dce:	c3                   	ret

80108dcf <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108dcf:	f3 0f 1e fb          	endbr32
80108dd3:	55                   	push   %ebp
80108dd4:	89 e5                	mov    %esp,%ebp
80108dd6:	53                   	push   %ebx
80108dd7:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108dda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108de1:	e9 b1 00 00 00       	jmp    80108e97 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108de6:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108ded:	e9 97 00 00 00       	jmp    80108e89 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108df2:	8b 45 10             	mov    0x10(%ebp),%eax
80108df5:	83 e8 20             	sub    $0x20,%eax
80108df8:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dfe:	01 d0                	add    %edx,%eax
80108e00:	0f b7 84 00 e0 b7 10 	movzwl -0x7fef4820(%eax,%eax,1),%eax
80108e07:	80 
80108e08:	0f b7 d0             	movzwl %ax,%edx
80108e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e0e:	bb 01 00 00 00       	mov    $0x1,%ebx
80108e13:	89 c1                	mov    %eax,%ecx
80108e15:	d3 e3                	shl    %cl,%ebx
80108e17:	89 d8                	mov    %ebx,%eax
80108e19:	21 d0                	and    %edx,%eax
80108e1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e21:	ba 01 00 00 00       	mov    $0x1,%edx
80108e26:	89 c1                	mov    %eax,%ecx
80108e28:	d3 e2                	shl    %cl,%edx
80108e2a:	89 d0                	mov    %edx,%eax
80108e2c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108e2f:	75 2b                	jne    80108e5c <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108e31:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e37:	01 c2                	add    %eax,%edx
80108e39:	b8 0e 00 00 00       	mov    $0xe,%eax
80108e3e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108e41:	89 c1                	mov    %eax,%ecx
80108e43:	8b 45 08             	mov    0x8(%ebp),%eax
80108e46:	01 c8                	add    %ecx,%eax
80108e48:	83 ec 04             	sub    $0x4,%esp
80108e4b:	68 00 05 11 80       	push   $0x80110500
80108e50:	52                   	push   %edx
80108e51:	50                   	push   %eax
80108e52:	e8 ad fe ff ff       	call   80108d04 <graphic_draw_pixel>
80108e57:	83 c4 10             	add    $0x10,%esp
80108e5a:	eb 29                	jmp    80108e85 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e62:	01 c2                	add    %eax,%edx
80108e64:	b8 0e 00 00 00       	mov    $0xe,%eax
80108e69:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108e6c:	89 c1                	mov    %eax,%ecx
80108e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80108e71:	01 c8                	add    %ecx,%eax
80108e73:	83 ec 04             	sub    $0x4,%esp
80108e76:	68 84 e0 18 80       	push   $0x8018e084
80108e7b:	52                   	push   %edx
80108e7c:	50                   	push   %eax
80108e7d:	e8 82 fe ff ff       	call   80108d04 <graphic_draw_pixel>
80108e82:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108e85:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108e89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e8d:	0f 89 5f ff ff ff    	jns    80108df2 <font_render+0x23>
  for(int i=0;i<30;i++){
80108e93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e97:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108e9b:	0f 8e 45 ff ff ff    	jle    80108de6 <font_render+0x17>
      }
    }
  }
}
80108ea1:	90                   	nop
80108ea2:	90                   	nop
80108ea3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ea6:	c9                   	leave
80108ea7:	c3                   	ret

80108ea8 <font_render_string>:

void font_render_string(char *string,int row){
80108ea8:	f3 0f 1e fb          	endbr32
80108eac:	55                   	push   %ebp
80108ead:	89 e5                	mov    %esp,%ebp
80108eaf:	53                   	push   %ebx
80108eb0:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108eb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108eba:	eb 33                	jmp    80108eef <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108ebc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec2:	01 d0                	add    %edx,%eax
80108ec4:	0f b6 00             	movzbl (%eax),%eax
80108ec7:	0f be d8             	movsbl %al,%ebx
80108eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ecd:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ed3:	89 d0                	mov    %edx,%eax
80108ed5:	c1 e0 04             	shl    $0x4,%eax
80108ed8:	29 d0                	sub    %edx,%eax
80108eda:	83 c0 02             	add    $0x2,%eax
80108edd:	83 ec 04             	sub    $0x4,%esp
80108ee0:	53                   	push   %ebx
80108ee1:	51                   	push   %ecx
80108ee2:	50                   	push   %eax
80108ee3:	e8 e7 fe ff ff       	call   80108dcf <font_render>
80108ee8:	83 c4 10             	add    $0x10,%esp
    i++;
80108eeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108eef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef5:	01 d0                	add    %edx,%eax
80108ef7:	0f b6 00             	movzbl (%eax),%eax
80108efa:	84 c0                	test   %al,%al
80108efc:	74 06                	je     80108f04 <font_render_string+0x5c>
80108efe:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108f02:	7e b8                	jle    80108ebc <font_render_string+0x14>
  }
}
80108f04:	90                   	nop
80108f05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f08:	c9                   	leave
80108f09:	c3                   	ret

80108f0a <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108f0a:	f3 0f 1e fb          	endbr32
80108f0e:	55                   	push   %ebp
80108f0f:	89 e5                	mov    %esp,%ebp
80108f11:	53                   	push   %ebx
80108f12:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108f15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f1c:	eb 6b                	jmp    80108f89 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108f1e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f25:	eb 58                	jmp    80108f7f <pci_init+0x75>
      for(int k=0;k<8;k++){
80108f27:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108f2e:	eb 45                	jmp    80108f75 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108f30:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108f33:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f39:	83 ec 0c             	sub    $0xc,%esp
80108f3c:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108f3f:	53                   	push   %ebx
80108f40:	6a 00                	push   $0x0
80108f42:	51                   	push   %ecx
80108f43:	52                   	push   %edx
80108f44:	50                   	push   %eax
80108f45:	e8 c0 00 00 00       	call   8010900a <pci_access_config>
80108f4a:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108f4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f50:	0f b7 c0             	movzwl %ax,%eax
80108f53:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108f58:	74 17                	je     80108f71 <pci_init+0x67>
        pci_init_device(i,j,k);
80108f5a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108f5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f63:	83 ec 04             	sub    $0x4,%esp
80108f66:	51                   	push   %ecx
80108f67:	52                   	push   %edx
80108f68:	50                   	push   %eax
80108f69:	e8 4f 01 00 00       	call   801090bd <pci_init_device>
80108f6e:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108f71:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f75:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108f79:	7e b5                	jle    80108f30 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108f7b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f7f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108f83:	7e a2                	jle    80108f27 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108f85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f89:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f90:	7e 8c                	jle    80108f1e <pci_init+0x14>
      }
      }
    }
  }
}
80108f92:	90                   	nop
80108f93:	90                   	nop
80108f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f97:	c9                   	leave
80108f98:	c3                   	ret

80108f99 <pci_write_config>:

void pci_write_config(uint config){
80108f99:	f3 0f 1e fb          	endbr32
80108f9d:	55                   	push   %ebp
80108f9e:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa3:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108fa8:	89 c0                	mov    %eax,%eax
80108faa:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108fab:	90                   	nop
80108fac:	5d                   	pop    %ebp
80108fad:	c3                   	ret

80108fae <pci_write_data>:

void pci_write_data(uint config){
80108fae:	f3 0f 1e fb          	endbr32
80108fb2:	55                   	push   %ebp
80108fb3:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80108fb8:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108fbd:	89 c0                	mov    %eax,%eax
80108fbf:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108fc0:	90                   	nop
80108fc1:	5d                   	pop    %ebp
80108fc2:	c3                   	ret

80108fc3 <pci_read_config>:
uint pci_read_config(){
80108fc3:	f3 0f 1e fb          	endbr32
80108fc7:	55                   	push   %ebp
80108fc8:	89 e5                	mov    %esp,%ebp
80108fca:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108fcd:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108fd2:	ed                   	in     (%dx),%eax
80108fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108fd6:	83 ec 0c             	sub    $0xc,%esp
80108fd9:	68 c8 00 00 00       	push   $0xc8
80108fde:	e8 61 9c ff ff       	call   80102c44 <microdelay>
80108fe3:	83 c4 10             	add    $0x10,%esp
  return data;
80108fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108fe9:	c9                   	leave
80108fea:	c3                   	ret

80108feb <pci_test>:


void pci_test(){
80108feb:	f3 0f 1e fb          	endbr32
80108fef:	55                   	push   %ebp
80108ff0:	89 e5                	mov    %esp,%ebp
80108ff2:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108ff5:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108ffc:	ff 75 fc             	push   -0x4(%ebp)
80108fff:	e8 95 ff ff ff       	call   80108f99 <pci_write_config>
80109004:	83 c4 04             	add    $0x4,%esp
}
80109007:	90                   	nop
80109008:	c9                   	leave
80109009:	c3                   	ret

8010900a <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010900a:	f3 0f 1e fb          	endbr32
8010900e:	55                   	push   %ebp
8010900f:	89 e5                	mov    %esp,%ebp
80109011:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109014:	8b 45 08             	mov    0x8(%ebp),%eax
80109017:	c1 e0 10             	shl    $0x10,%eax
8010901a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010901f:	89 c2                	mov    %eax,%edx
80109021:	8b 45 0c             	mov    0xc(%ebp),%eax
80109024:	c1 e0 0b             	shl    $0xb,%eax
80109027:	0f b7 c0             	movzwl %ax,%eax
8010902a:	09 c2                	or     %eax,%edx
8010902c:	8b 45 10             	mov    0x10(%ebp),%eax
8010902f:	c1 e0 08             	shl    $0x8,%eax
80109032:	25 00 07 00 00       	and    $0x700,%eax
80109037:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80109039:	8b 45 14             	mov    0x14(%ebp),%eax
8010903c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80109041:	09 d0                	or     %edx,%eax
80109043:	0d 00 00 00 80       	or     $0x80000000,%eax
80109048:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010904b:	ff 75 f4             	push   -0xc(%ebp)
8010904e:	e8 46 ff ff ff       	call   80108f99 <pci_write_config>
80109053:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80109056:	e8 68 ff ff ff       	call   80108fc3 <pci_read_config>
8010905b:	8b 55 18             	mov    0x18(%ebp),%edx
8010905e:	89 02                	mov    %eax,(%edx)
}
80109060:	90                   	nop
80109061:	c9                   	leave
80109062:	c3                   	ret

80109063 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80109063:	f3 0f 1e fb          	endbr32
80109067:	55                   	push   %ebp
80109068:	89 e5                	mov    %esp,%ebp
8010906a:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010906d:	8b 45 08             	mov    0x8(%ebp),%eax
80109070:	c1 e0 10             	shl    $0x10,%eax
80109073:	25 00 00 ff 00       	and    $0xff0000,%eax
80109078:	89 c2                	mov    %eax,%edx
8010907a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010907d:	c1 e0 0b             	shl    $0xb,%eax
80109080:	0f b7 c0             	movzwl %ax,%eax
80109083:	09 c2                	or     %eax,%edx
80109085:	8b 45 10             	mov    0x10(%ebp),%eax
80109088:	c1 e0 08             	shl    $0x8,%eax
8010908b:	25 00 07 00 00       	and    $0x700,%eax
80109090:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80109092:	8b 45 14             	mov    0x14(%ebp),%eax
80109095:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010909a:	09 d0                	or     %edx,%eax
8010909c:	0d 00 00 00 80       	or     $0x80000000,%eax
801090a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801090a4:	ff 75 fc             	push   -0x4(%ebp)
801090a7:	e8 ed fe ff ff       	call   80108f99 <pci_write_config>
801090ac:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801090af:	ff 75 18             	push   0x18(%ebp)
801090b2:	e8 f7 fe ff ff       	call   80108fae <pci_write_data>
801090b7:	83 c4 04             	add    $0x4,%esp
}
801090ba:	90                   	nop
801090bb:	c9                   	leave
801090bc:	c3                   	ret

801090bd <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801090bd:	f3 0f 1e fb          	endbr32
801090c1:	55                   	push   %ebp
801090c2:	89 e5                	mov    %esp,%ebp
801090c4:	53                   	push   %ebx
801090c5:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801090c8:	8b 45 08             	mov    0x8(%ebp),%eax
801090cb:	a2 b0 9d 19 80       	mov    %al,0x80199db0
  dev.device_num = device_num;
801090d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801090d3:	a2 b1 9d 19 80       	mov    %al,0x80199db1
  dev.function_num = function_num;
801090d8:	8b 45 10             	mov    0x10(%ebp),%eax
801090db:	a2 b2 9d 19 80       	mov    %al,0x80199db2
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801090e0:	ff 75 10             	push   0x10(%ebp)
801090e3:	ff 75 0c             	push   0xc(%ebp)
801090e6:	ff 75 08             	push   0x8(%ebp)
801090e9:	68 24 ce 10 80       	push   $0x8010ce24
801090ee:	e8 19 73 ff ff       	call   8010040c <cprintf>
801090f3:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801090f6:	83 ec 0c             	sub    $0xc,%esp
801090f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090fc:	50                   	push   %eax
801090fd:	6a 00                	push   $0x0
801090ff:	ff 75 10             	push   0x10(%ebp)
80109102:	ff 75 0c             	push   0xc(%ebp)
80109105:	ff 75 08             	push   0x8(%ebp)
80109108:	e8 fd fe ff ff       	call   8010900a <pci_access_config>
8010910d:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80109110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109113:	c1 e8 10             	shr    $0x10,%eax
80109116:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80109119:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010911c:	25 ff ff 00 00       	and    $0xffff,%eax
80109121:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80109124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109127:	a3 b4 9d 19 80       	mov    %eax,0x80199db4
  dev.vendor_id = vendor_id;
8010912c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912f:	a3 b8 9d 19 80       	mov    %eax,0x80199db8
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80109134:	83 ec 04             	sub    $0x4,%esp
80109137:	ff 75 f0             	push   -0x10(%ebp)
8010913a:	ff 75 f4             	push   -0xc(%ebp)
8010913d:	68 58 ce 10 80       	push   $0x8010ce58
80109142:	e8 c5 72 ff ff       	call   8010040c <cprintf>
80109147:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010914a:	83 ec 0c             	sub    $0xc,%esp
8010914d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109150:	50                   	push   %eax
80109151:	6a 08                	push   $0x8
80109153:	ff 75 10             	push   0x10(%ebp)
80109156:	ff 75 0c             	push   0xc(%ebp)
80109159:	ff 75 08             	push   0x8(%ebp)
8010915c:	e8 a9 fe ff ff       	call   8010900a <pci_access_config>
80109161:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109164:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109167:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010916a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010916d:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109170:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80109173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109176:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109179:	0f b6 c0             	movzbl %al,%eax
8010917c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010917f:	c1 eb 18             	shr    $0x18,%ebx
80109182:	83 ec 0c             	sub    $0xc,%esp
80109185:	51                   	push   %ecx
80109186:	52                   	push   %edx
80109187:	50                   	push   %eax
80109188:	53                   	push   %ebx
80109189:	68 7c ce 10 80       	push   $0x8010ce7c
8010918e:	e8 79 72 ff ff       	call   8010040c <cprintf>
80109193:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80109196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109199:	c1 e8 18             	shr    $0x18,%eax
8010919c:	a2 bc 9d 19 80       	mov    %al,0x80199dbc
  dev.sub_class = (data>>16)&0xFF;
801091a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091a4:	c1 e8 10             	shr    $0x10,%eax
801091a7:	a2 bd 9d 19 80       	mov    %al,0x80199dbd
  dev.interface = (data>>8)&0xFF;
801091ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091af:	c1 e8 08             	shr    $0x8,%eax
801091b2:	a2 be 9d 19 80       	mov    %al,0x80199dbe
  dev.revision_id = data&0xFF;
801091b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ba:	a2 bf 9d 19 80       	mov    %al,0x80199dbf
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801091bf:	83 ec 0c             	sub    $0xc,%esp
801091c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091c5:	50                   	push   %eax
801091c6:	6a 10                	push   $0x10
801091c8:	ff 75 10             	push   0x10(%ebp)
801091cb:	ff 75 0c             	push   0xc(%ebp)
801091ce:	ff 75 08             	push   0x8(%ebp)
801091d1:	e8 34 fe ff ff       	call   8010900a <pci_access_config>
801091d6:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801091d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091dc:	a3 c0 9d 19 80       	mov    %eax,0x80199dc0
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801091e1:	83 ec 0c             	sub    $0xc,%esp
801091e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091e7:	50                   	push   %eax
801091e8:	6a 14                	push   $0x14
801091ea:	ff 75 10             	push   0x10(%ebp)
801091ed:	ff 75 0c             	push   0xc(%ebp)
801091f0:	ff 75 08             	push   0x8(%ebp)
801091f3:	e8 12 fe ff ff       	call   8010900a <pci_access_config>
801091f8:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801091fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091fe:	a3 c4 9d 19 80       	mov    %eax,0x80199dc4
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80109203:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010920a:	75 5a                	jne    80109266 <pci_init_device+0x1a9>
8010920c:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80109213:	75 51                	jne    80109266 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80109215:	83 ec 0c             	sub    $0xc,%esp
80109218:	68 c1 ce 10 80       	push   $0x8010cec1
8010921d:	e8 ea 71 ff ff       	call   8010040c <cprintf>
80109222:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80109225:	83 ec 0c             	sub    $0xc,%esp
80109228:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010922b:	50                   	push   %eax
8010922c:	68 f0 00 00 00       	push   $0xf0
80109231:	ff 75 10             	push   0x10(%ebp)
80109234:	ff 75 0c             	push   0xc(%ebp)
80109237:	ff 75 08             	push   0x8(%ebp)
8010923a:	e8 cb fd ff ff       	call   8010900a <pci_access_config>
8010923f:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80109242:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109245:	83 ec 08             	sub    $0x8,%esp
80109248:	50                   	push   %eax
80109249:	68 db ce 10 80       	push   $0x8010cedb
8010924e:	e8 b9 71 ff ff       	call   8010040c <cprintf>
80109253:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80109256:	83 ec 0c             	sub    $0xc,%esp
80109259:	68 b0 9d 19 80       	push   $0x80199db0
8010925e:	e8 09 00 00 00       	call   8010926c <i8254_init>
80109263:	83 c4 10             	add    $0x10,%esp
  }
}
80109266:	90                   	nop
80109267:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010926a:	c9                   	leave
8010926b:	c3                   	ret

8010926c <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010926c:	f3 0f 1e fb          	endbr32
80109270:	55                   	push   %ebp
80109271:	89 e5                	mov    %esp,%ebp
80109273:	53                   	push   %ebx
80109274:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80109277:	8b 45 08             	mov    0x8(%ebp),%eax
8010927a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010927e:	0f b6 c8             	movzbl %al,%ecx
80109281:	8b 45 08             	mov    0x8(%ebp),%eax
80109284:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109288:	0f b6 d0             	movzbl %al,%edx
8010928b:	8b 45 08             	mov    0x8(%ebp),%eax
8010928e:	0f b6 00             	movzbl (%eax),%eax
80109291:	0f b6 c0             	movzbl %al,%eax
80109294:	83 ec 0c             	sub    $0xc,%esp
80109297:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010929a:	53                   	push   %ebx
8010929b:	6a 04                	push   $0x4
8010929d:	51                   	push   %ecx
8010929e:	52                   	push   %edx
8010929f:	50                   	push   %eax
801092a0:	e8 65 fd ff ff       	call   8010900a <pci_access_config>
801092a5:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801092a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ab:	83 c8 04             	or     $0x4,%eax
801092ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801092b1:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801092b4:	8b 45 08             	mov    0x8(%ebp),%eax
801092b7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801092bb:	0f b6 c8             	movzbl %al,%ecx
801092be:	8b 45 08             	mov    0x8(%ebp),%eax
801092c1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801092c5:	0f b6 d0             	movzbl %al,%edx
801092c8:	8b 45 08             	mov    0x8(%ebp),%eax
801092cb:	0f b6 00             	movzbl (%eax),%eax
801092ce:	0f b6 c0             	movzbl %al,%eax
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	53                   	push   %ebx
801092d5:	6a 04                	push   $0x4
801092d7:	51                   	push   %ecx
801092d8:	52                   	push   %edx
801092d9:	50                   	push   %eax
801092da:	e8 84 fd ff ff       	call   80109063 <pci_write_config_register>
801092df:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801092e2:	8b 45 08             	mov    0x8(%ebp),%eax
801092e5:	8b 40 10             	mov    0x10(%eax),%eax
801092e8:	05 00 00 00 40       	add    $0x40000000,%eax
801092ed:	a3 c8 9d 19 80       	mov    %eax,0x80199dc8
  uint *ctrl = (uint *)base_addr;
801092f2:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801092fa:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801092ff:	05 d8 00 00 00       	add    $0xd8,%eax
80109304:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80109307:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010930a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80109310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109313:	8b 00                	mov    (%eax),%eax
80109315:	0d 00 00 00 04       	or     $0x4000000,%eax
8010931a:	89 c2                	mov    %eax,%edx
8010931c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010931f:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80109321:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109324:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010932a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932d:	8b 00                	mov    (%eax),%eax
8010932f:	83 c8 40             	or     $0x40,%eax
80109332:	89 c2                	mov    %eax,%edx
80109334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109337:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80109339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933c:	8b 10                	mov    (%eax),%edx
8010933e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109341:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80109343:	83 ec 0c             	sub    $0xc,%esp
80109346:	68 f0 ce 10 80       	push   $0x8010cef0
8010934b:	e8 bc 70 ff ff       	call   8010040c <cprintf>
80109350:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80109353:	e8 3a 95 ff ff       	call   80102892 <kalloc>
80109358:	a3 cc 9d 19 80       	mov    %eax,0x80199dcc
  *intr_addr = 0;
8010935d:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109362:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109368:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
8010936d:	83 ec 08             	sub    $0x8,%esp
80109370:	50                   	push   %eax
80109371:	68 12 cf 10 80       	push   $0x8010cf12
80109376:	e8 91 70 ff ff       	call   8010040c <cprintf>
8010937b:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010937e:	e8 50 00 00 00       	call   801093d3 <i8254_init_recv>
  i8254_init_send();
80109383:	e8 6d 03 00 00       	call   801096f5 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80109388:	0f b6 05 07 05 11 80 	movzbl 0x80110507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010938f:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80109392:	0f b6 05 06 05 11 80 	movzbl 0x80110506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109399:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010939c:	0f b6 05 05 05 11 80 	movzbl 0x80110505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801093a3:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801093a6:	0f b6 05 04 05 11 80 	movzbl 0x80110504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801093ad:	0f b6 c0             	movzbl %al,%eax
801093b0:	83 ec 0c             	sub    $0xc,%esp
801093b3:	53                   	push   %ebx
801093b4:	51                   	push   %ecx
801093b5:	52                   	push   %edx
801093b6:	50                   	push   %eax
801093b7:	68 20 cf 10 80       	push   $0x8010cf20
801093bc:	e8 4b 70 ff ff       	call   8010040c <cprintf>
801093c1:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801093c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801093cd:	90                   	nop
801093ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801093d1:	c9                   	leave
801093d2:	c3                   	ret

801093d3 <i8254_init_recv>:

void i8254_init_recv(){
801093d3:	f3 0f 1e fb          	endbr32
801093d7:	55                   	push   %ebp
801093d8:	89 e5                	mov    %esp,%ebp
801093da:	57                   	push   %edi
801093db:	56                   	push   %esi
801093dc:	53                   	push   %ebx
801093dd:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801093e0:	83 ec 0c             	sub    $0xc,%esp
801093e3:	6a 00                	push   $0x0
801093e5:	e8 ec 04 00 00       	call   801098d6 <i8254_read_eeprom>
801093ea:	83 c4 10             	add    $0x10,%esp
801093ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801093f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093f3:	a2 88 e0 18 80       	mov    %al,0x8018e088
  mac_addr[1] = data_l>>8;
801093f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093fb:	c1 e8 08             	shr    $0x8,%eax
801093fe:	a2 89 e0 18 80       	mov    %al,0x8018e089
  uint data_m = i8254_read_eeprom(0x1);
80109403:	83 ec 0c             	sub    $0xc,%esp
80109406:	6a 01                	push   $0x1
80109408:	e8 c9 04 00 00       	call   801098d6 <i8254_read_eeprom>
8010940d:	83 c4 10             	add    $0x10,%esp
80109410:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80109413:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109416:	a2 8a e0 18 80       	mov    %al,0x8018e08a
  mac_addr[3] = data_m>>8;
8010941b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010941e:	c1 e8 08             	shr    $0x8,%eax
80109421:	a2 8b e0 18 80       	mov    %al,0x8018e08b
  uint data_h = i8254_read_eeprom(0x2);
80109426:	83 ec 0c             	sub    $0xc,%esp
80109429:	6a 02                	push   $0x2
8010942b:	e8 a6 04 00 00       	call   801098d6 <i8254_read_eeprom>
80109430:	83 c4 10             	add    $0x10,%esp
80109433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80109436:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109439:	a2 8c e0 18 80       	mov    %al,0x8018e08c
  mac_addr[5] = data_h>>8;
8010943e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109441:	c1 e8 08             	shr    $0x8,%eax
80109444:	a2 8d e0 18 80       	mov    %al,0x8018e08d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109449:	0f b6 05 8d e0 18 80 	movzbl 0x8018e08d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109450:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80109453:	0f b6 05 8c e0 18 80 	movzbl 0x8018e08c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010945a:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010945d:	0f b6 05 8b e0 18 80 	movzbl 0x8018e08b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109464:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109467:	0f b6 05 8a e0 18 80 	movzbl 0x8018e08a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010946e:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80109471:	0f b6 05 89 e0 18 80 	movzbl 0x8018e089,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109478:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010947b:	0f b6 05 88 e0 18 80 	movzbl 0x8018e088,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109482:	0f b6 c0             	movzbl %al,%eax
80109485:	83 ec 04             	sub    $0x4,%esp
80109488:	57                   	push   %edi
80109489:	56                   	push   %esi
8010948a:	53                   	push   %ebx
8010948b:	51                   	push   %ecx
8010948c:	52                   	push   %edx
8010948d:	50                   	push   %eax
8010948e:	68 38 cf 10 80       	push   $0x8010cf38
80109493:	e8 74 6f ff ff       	call   8010040c <cprintf>
80109498:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010949b:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094a0:	05 00 54 00 00       	add    $0x5400,%eax
801094a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801094a8:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094ad:	05 04 54 00 00       	add    $0x5404,%eax
801094b2:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801094b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801094b8:	c1 e0 10             	shl    $0x10,%eax
801094bb:	0b 45 d8             	or     -0x28(%ebp),%eax
801094be:	89 c2                	mov    %eax,%edx
801094c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801094c3:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801094c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094c8:	0d 00 00 00 80       	or     $0x80000000,%eax
801094cd:	89 c2                	mov    %eax,%edx
801094cf:	8b 45 c8             	mov    -0x38(%ebp),%eax
801094d2:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801094d4:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801094d9:	05 00 52 00 00       	add    $0x5200,%eax
801094de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801094e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801094e8:	eb 19                	jmp    80109503 <i8254_init_recv+0x130>
    mta[i] = 0;
801094ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801094ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094f4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801094f7:	01 d0                	add    %edx,%eax
801094f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801094ff:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80109503:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80109507:	7e e1                	jle    801094ea <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80109509:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010950e:	05 d0 00 00 00       	add    $0xd0,%eax
80109513:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109516:	8b 45 c0             	mov    -0x40(%ebp),%eax
80109519:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010951f:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109524:	05 c8 00 00 00       	add    $0xc8,%eax
80109529:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010952c:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010952f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109535:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010953a:	05 28 28 00 00       	add    $0x2828,%eax
8010953f:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109542:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109545:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010954b:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109550:	05 00 01 00 00       	add    $0x100,%eax
80109555:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109558:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010955b:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109561:	e8 2c 93 ff ff       	call   80102892 <kalloc>
80109566:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109569:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010956e:	05 00 28 00 00       	add    $0x2800,%eax
80109573:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80109576:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010957b:	05 04 28 00 00       	add    $0x2804,%eax
80109580:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80109583:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109588:	05 08 28 00 00       	add    $0x2808,%eax
8010958d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109590:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109595:	05 10 28 00 00       	add    $0x2810,%eax
8010959a:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010959d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801095a2:	05 18 28 00 00       	add    $0x2818,%eax
801095a7:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801095aa:	8b 45 b0             	mov    -0x50(%ebp),%eax
801095ad:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801095b3:	8b 45 ac             	mov    -0x54(%ebp),%eax
801095b6:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801095b8:	8b 45 a8             	mov    -0x58(%ebp),%eax
801095bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801095c1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801095c4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801095ca:	8b 45 a0             	mov    -0x60(%ebp),%eax
801095cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801095d3:	8b 45 9c             	mov    -0x64(%ebp),%eax
801095d6:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801095dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
801095df:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801095e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801095e9:	eb 73                	jmp    8010965e <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
801095eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095ee:	c1 e0 04             	shl    $0x4,%eax
801095f1:	89 c2                	mov    %eax,%edx
801095f3:	8b 45 98             	mov    -0x68(%ebp),%eax
801095f6:	01 d0                	add    %edx,%eax
801095f8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801095ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109602:	c1 e0 04             	shl    $0x4,%eax
80109605:	89 c2                	mov    %eax,%edx
80109607:	8b 45 98             	mov    -0x68(%ebp),%eax
8010960a:	01 d0                	add    %edx,%eax
8010960c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109612:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109615:	c1 e0 04             	shl    $0x4,%eax
80109618:	89 c2                	mov    %eax,%edx
8010961a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010961d:	01 d0                	add    %edx,%eax
8010961f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109625:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109628:	c1 e0 04             	shl    $0x4,%eax
8010962b:	89 c2                	mov    %eax,%edx
8010962d:	8b 45 98             	mov    -0x68(%ebp),%eax
80109630:	01 d0                	add    %edx,%eax
80109632:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109636:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109639:	c1 e0 04             	shl    $0x4,%eax
8010963c:	89 c2                	mov    %eax,%edx
8010963e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109641:	01 d0                	add    %edx,%eax
80109643:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109647:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010964a:	c1 e0 04             	shl    $0x4,%eax
8010964d:	89 c2                	mov    %eax,%edx
8010964f:	8b 45 98             	mov    -0x68(%ebp),%eax
80109652:	01 d0                	add    %edx,%eax
80109654:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010965a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010965e:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109665:	7e 84                	jle    801095eb <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109667:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010966e:	eb 57                	jmp    801096c7 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109670:	e8 1d 92 ff ff       	call   80102892 <kalloc>
80109675:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109678:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010967c:	75 12                	jne    80109690 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
8010967e:	83 ec 0c             	sub    $0xc,%esp
80109681:	68 58 cf 10 80       	push   $0x8010cf58
80109686:	e8 81 6d ff ff       	call   8010040c <cprintf>
8010968b:	83 c4 10             	add    $0x10,%esp
      break;
8010968e:	eb 3d                	jmp    801096cd <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109690:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109693:	c1 e0 04             	shl    $0x4,%eax
80109696:	89 c2                	mov    %eax,%edx
80109698:	8b 45 98             	mov    -0x68(%ebp),%eax
8010969b:	01 d0                	add    %edx,%eax
8010969d:	8b 55 94             	mov    -0x6c(%ebp),%edx
801096a0:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801096a6:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801096a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801096ab:	83 c0 01             	add    $0x1,%eax
801096ae:	c1 e0 04             	shl    $0x4,%eax
801096b1:	89 c2                	mov    %eax,%edx
801096b3:	8b 45 98             	mov    -0x68(%ebp),%eax
801096b6:	01 d0                	add    %edx,%eax
801096b8:	8b 55 94             	mov    -0x6c(%ebp),%edx
801096bb:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801096c1:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801096c3:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801096c7:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801096cb:	7e a3                	jle    80109670 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
801096cd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801096d0:	8b 00                	mov    (%eax),%eax
801096d2:	83 c8 02             	or     $0x2,%eax
801096d5:	89 c2                	mov    %eax,%edx
801096d7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801096da:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801096dc:	83 ec 0c             	sub    $0xc,%esp
801096df:	68 78 cf 10 80       	push   $0x8010cf78
801096e4:	e8 23 6d ff ff       	call   8010040c <cprintf>
801096e9:	83 c4 10             	add    $0x10,%esp
}
801096ec:	90                   	nop
801096ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801096f0:	5b                   	pop    %ebx
801096f1:	5e                   	pop    %esi
801096f2:	5f                   	pop    %edi
801096f3:	5d                   	pop    %ebp
801096f4:	c3                   	ret

801096f5 <i8254_init_send>:

void i8254_init_send(){
801096f5:	f3 0f 1e fb          	endbr32
801096f9:	55                   	push   %ebp
801096fa:	89 e5                	mov    %esp,%ebp
801096fc:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801096ff:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109704:	05 28 38 00 00       	add    $0x3828,%eax
80109709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010970c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010970f:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109715:	e8 78 91 ff ff       	call   80102892 <kalloc>
8010971a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010971d:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109722:	05 00 38 00 00       	add    $0x3800,%eax
80109727:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010972a:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010972f:	05 04 38 00 00       	add    $0x3804,%eax
80109734:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109737:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010973c:	05 08 38 00 00       	add    $0x3808,%eax
80109741:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109744:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109747:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010974d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109750:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109752:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109755:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010975b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010975e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109764:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109769:	05 10 38 00 00       	add    $0x3810,%eax
8010976e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109771:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109776:	05 18 38 00 00       	add    $0x3818,%eax
8010977b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010977e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109781:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109787:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010978a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109790:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109793:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010979d:	e9 82 00 00 00       	jmp    80109824 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801097a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a5:	c1 e0 04             	shl    $0x4,%eax
801097a8:	89 c2                	mov    %eax,%edx
801097aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097ad:	01 d0                	add    %edx,%eax
801097af:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801097b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b9:	c1 e0 04             	shl    $0x4,%eax
801097bc:	89 c2                	mov    %eax,%edx
801097be:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097c1:	01 d0                	add    %edx,%eax
801097c3:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801097c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cc:	c1 e0 04             	shl    $0x4,%eax
801097cf:	89 c2                	mov    %eax,%edx
801097d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097d4:	01 d0                	add    %edx,%eax
801097d6:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801097da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097dd:	c1 e0 04             	shl    $0x4,%eax
801097e0:	89 c2                	mov    %eax,%edx
801097e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097e5:	01 d0                	add    %edx,%eax
801097e7:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801097eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ee:	c1 e0 04             	shl    $0x4,%eax
801097f1:	89 c2                	mov    %eax,%edx
801097f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097f6:	01 d0                	add    %edx,%eax
801097f8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801097fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ff:	c1 e0 04             	shl    $0x4,%eax
80109802:	89 c2                	mov    %eax,%edx
80109804:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109807:	01 d0                	add    %edx,%eax
80109809:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010980d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109810:	c1 e0 04             	shl    $0x4,%eax
80109813:	89 c2                	mov    %eax,%edx
80109815:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109818:	01 d0                	add    %edx,%eax
8010981a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109820:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109824:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010982b:	0f 8e 71 ff ff ff    	jle    801097a2 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109831:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109838:	eb 57                	jmp    80109891 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
8010983a:	e8 53 90 ff ff       	call   80102892 <kalloc>
8010983f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109842:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109846:	75 12                	jne    8010985a <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109848:	83 ec 0c             	sub    $0xc,%esp
8010984b:	68 58 cf 10 80       	push   $0x8010cf58
80109850:	e8 b7 6b ff ff       	call   8010040c <cprintf>
80109855:	83 c4 10             	add    $0x10,%esp
      break;
80109858:	eb 3d                	jmp    80109897 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010985a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010985d:	c1 e0 04             	shl    $0x4,%eax
80109860:	89 c2                	mov    %eax,%edx
80109862:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109865:	01 d0                	add    %edx,%eax
80109867:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010986a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109870:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109875:	83 c0 01             	add    $0x1,%eax
80109878:	c1 e0 04             	shl    $0x4,%eax
8010987b:	89 c2                	mov    %eax,%edx
8010987d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109880:	01 d0                	add    %edx,%eax
80109882:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109885:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010988b:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010988d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109891:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109895:	7e a3                	jle    8010983a <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109897:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010989c:	05 00 04 00 00       	add    $0x400,%eax
801098a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801098a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801098a7:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801098ad:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801098b2:	05 10 04 00 00       	add    $0x410,%eax
801098b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801098ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801098bd:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801098c3:	83 ec 0c             	sub    $0xc,%esp
801098c6:	68 98 cf 10 80       	push   $0x8010cf98
801098cb:	e8 3c 6b ff ff       	call   8010040c <cprintf>
801098d0:	83 c4 10             	add    $0x10,%esp

}
801098d3:	90                   	nop
801098d4:	c9                   	leave
801098d5:	c3                   	ret

801098d6 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801098d6:	f3 0f 1e fb          	endbr32
801098da:	55                   	push   %ebp
801098db:	89 e5                	mov    %esp,%ebp
801098dd:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801098e0:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801098e5:	83 c0 14             	add    $0x14,%eax
801098e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801098eb:	8b 45 08             	mov    0x8(%ebp),%eax
801098ee:	c1 e0 08             	shl    $0x8,%eax
801098f1:	0f b7 c0             	movzwl %ax,%eax
801098f4:	83 c8 01             	or     $0x1,%eax
801098f7:	89 c2                	mov    %eax,%edx
801098f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fc:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801098fe:	83 ec 0c             	sub    $0xc,%esp
80109901:	68 b8 cf 10 80       	push   $0x8010cfb8
80109906:	e8 01 6b ff ff       	call   8010040c <cprintf>
8010990b:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010990e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109911:	8b 00                	mov    (%eax),%eax
80109913:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109919:	83 e0 10             	and    $0x10,%eax
8010991c:	85 c0                	test   %eax,%eax
8010991e:	75 02                	jne    80109922 <i8254_read_eeprom+0x4c>
  while(1){
80109920:	eb dc                	jmp    801098fe <i8254_read_eeprom+0x28>
      break;
80109922:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109926:	8b 00                	mov    (%eax),%eax
80109928:	c1 e8 10             	shr    $0x10,%eax
}
8010992b:	c9                   	leave
8010992c:	c3                   	ret

8010992d <i8254_recv>:
void i8254_recv(){
8010992d:	f3 0f 1e fb          	endbr32
80109931:	55                   	push   %ebp
80109932:	89 e5                	mov    %esp,%ebp
80109934:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109937:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
8010993c:	05 10 28 00 00       	add    $0x2810,%eax
80109941:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109944:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109949:	05 18 28 00 00       	add    $0x2818,%eax
8010994e:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109951:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109956:	05 00 28 00 00       	add    $0x2800,%eax
8010995b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010995e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109961:	8b 00                	mov    (%eax),%eax
80109963:	05 00 00 00 80       	add    $0x80000000,%eax
80109968:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010996b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010996e:	8b 10                	mov    (%eax),%edx
80109970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109973:	8b 00                	mov    (%eax),%eax
80109975:	29 c2                	sub    %eax,%edx
80109977:	89 d0                	mov    %edx,%eax
80109979:	25 ff 00 00 00       	and    $0xff,%eax
8010997e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109981:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109985:	7e 37                	jle    801099be <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010998a:	8b 00                	mov    (%eax),%eax
8010998c:	c1 e0 04             	shl    $0x4,%eax
8010998f:	89 c2                	mov    %eax,%edx
80109991:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109994:	01 d0                	add    %edx,%eax
80109996:	8b 00                	mov    (%eax),%eax
80109998:	05 00 00 00 80       	add    $0x80000000,%eax
8010999d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801099a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a3:	8b 00                	mov    (%eax),%eax
801099a5:	83 c0 01             	add    $0x1,%eax
801099a8:	0f b6 d0             	movzbl %al,%edx
801099ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ae:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801099b0:	83 ec 0c             	sub    $0xc,%esp
801099b3:	ff 75 e0             	push   -0x20(%ebp)
801099b6:	e8 47 09 00 00       	call   8010a302 <eth_proc>
801099bb:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801099be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099c1:	8b 10                	mov    (%eax),%edx
801099c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c6:	8b 00                	mov    (%eax),%eax
801099c8:	39 c2                	cmp    %eax,%edx
801099ca:	75 9f                	jne    8010996b <i8254_recv+0x3e>
      (*rdt)--;
801099cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099cf:	8b 00                	mov    (%eax),%eax
801099d1:	8d 50 ff             	lea    -0x1(%eax),%edx
801099d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099d7:	89 10                	mov    %edx,(%eax)
  while(1){
801099d9:	eb 90                	jmp    8010996b <i8254_recv+0x3e>

801099db <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801099db:	f3 0f 1e fb          	endbr32
801099df:	55                   	push   %ebp
801099e0:	89 e5                	mov    %esp,%ebp
801099e2:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801099e5:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099ea:	05 10 38 00 00       	add    $0x3810,%eax
801099ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801099f2:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
801099f7:	05 18 38 00 00       	add    $0x3818,%eax
801099fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801099ff:	a1 c8 9d 19 80       	mov    0x80199dc8,%eax
80109a04:	05 00 38 00 00       	add    $0x3800,%eax
80109a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109a0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a0f:	8b 00                	mov    (%eax),%eax
80109a11:	05 00 00 00 80       	add    $0x80000000,%eax
80109a16:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a1c:	8b 10                	mov    (%eax),%edx
80109a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a21:	8b 00                	mov    (%eax),%eax
80109a23:	29 c2                	sub    %eax,%edx
80109a25:	89 d0                	mov    %edx,%eax
80109a27:	0f b6 c0             	movzbl %al,%eax
80109a2a:	ba 00 01 00 00       	mov    $0x100,%edx
80109a2f:	29 c2                	sub    %eax,%edx
80109a31:	89 d0                	mov    %edx,%eax
80109a33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a39:	8b 00                	mov    (%eax),%eax
80109a3b:	25 ff 00 00 00       	and    $0xff,%eax
80109a40:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109a43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109a47:	0f 8e a8 00 00 00    	jle    80109af5 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a50:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a53:	89 d1                	mov    %edx,%ecx
80109a55:	c1 e1 04             	shl    $0x4,%ecx
80109a58:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109a5b:	01 ca                	add    %ecx,%edx
80109a5d:	8b 12                	mov    (%edx),%edx
80109a5f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109a65:	83 ec 04             	sub    $0x4,%esp
80109a68:	ff 75 0c             	push   0xc(%ebp)
80109a6b:	50                   	push   %eax
80109a6c:	52                   	push   %edx
80109a6d:	e8 5b bc ff ff       	call   801056cd <memmove>
80109a72:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109a75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a78:	c1 e0 04             	shl    $0x4,%eax
80109a7b:	89 c2                	mov    %eax,%edx
80109a7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a80:	01 d0                	add    %edx,%eax
80109a82:	8b 55 0c             	mov    0xc(%ebp),%edx
80109a85:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109a89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a8c:	c1 e0 04             	shl    $0x4,%eax
80109a8f:	89 c2                	mov    %eax,%edx
80109a91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a94:	01 d0                	add    %edx,%eax
80109a96:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109a9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a9d:	c1 e0 04             	shl    $0x4,%eax
80109aa0:	89 c2                	mov    %eax,%edx
80109aa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aa5:	01 d0                	add    %edx,%eax
80109aa7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aae:	c1 e0 04             	shl    $0x4,%eax
80109ab1:	89 c2                	mov    %eax,%edx
80109ab3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ab6:	01 d0                	add    %edx,%eax
80109ab8:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109abf:	c1 e0 04             	shl    $0x4,%eax
80109ac2:	89 c2                	mov    %eax,%edx
80109ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ac7:	01 d0                	add    %edx,%eax
80109ac9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ad2:	c1 e0 04             	shl    $0x4,%eax
80109ad5:	89 c2                	mov    %eax,%edx
80109ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ada:	01 d0                	add    %edx,%eax
80109adc:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ae3:	8b 00                	mov    (%eax),%eax
80109ae5:	83 c0 01             	add    $0x1,%eax
80109ae8:	0f b6 d0             	movzbl %al,%edx
80109aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aee:	89 10                	mov    %edx,(%eax)
    return len;
80109af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109af3:	eb 05                	jmp    80109afa <i8254_send+0x11f>
  }else{
    return -1;
80109af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109afa:	c9                   	leave
80109afb:	c3                   	ret

80109afc <i8254_intr>:

void i8254_intr(){
80109afc:	f3 0f 1e fb          	endbr32
80109b00:	55                   	push   %ebp
80109b01:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109b03:	a1 cc 9d 19 80       	mov    0x80199dcc,%eax
80109b08:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109b0e:	90                   	nop
80109b0f:	5d                   	pop    %ebp
80109b10:	c3                   	ret

80109b11 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109b11:	f3 0f 1e fb          	endbr32
80109b15:	55                   	push   %ebp
80109b16:	89 e5                	mov    %esp,%ebp
80109b18:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b24:	0f b7 00             	movzwl (%eax),%eax
80109b27:	66 3d 00 01          	cmp    $0x100,%ax
80109b2b:	74 0a                	je     80109b37 <arp_proc+0x26>
80109b2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b32:	e9 4f 01 00 00       	jmp    80109c86 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109b3e:	66 83 f8 08          	cmp    $0x8,%ax
80109b42:	74 0a                	je     80109b4e <arp_proc+0x3d>
80109b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b49:	e9 38 01 00 00       	jmp    80109c86 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b51:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109b55:	3c 06                	cmp    $0x6,%al
80109b57:	74 0a                	je     80109b63 <arp_proc+0x52>
80109b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b5e:	e9 23 01 00 00       	jmp    80109c86 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b66:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109b6a:	3c 04                	cmp    $0x4,%al
80109b6c:	74 0a                	je     80109b78 <arp_proc+0x67>
80109b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109b73:	e9 0e 01 00 00       	jmp    80109c86 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b7b:	83 c0 18             	add    $0x18,%eax
80109b7e:	83 ec 04             	sub    $0x4,%esp
80109b81:	6a 04                	push   $0x4
80109b83:	50                   	push   %eax
80109b84:	68 04 05 11 80       	push   $0x80110504
80109b89:	e8 e3 ba ff ff       	call   80105671 <memcmp>
80109b8e:	83 c4 10             	add    $0x10,%esp
80109b91:	85 c0                	test   %eax,%eax
80109b93:	74 27                	je     80109bbc <arp_proc+0xab>
80109b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b98:	83 c0 0e             	add    $0xe,%eax
80109b9b:	83 ec 04             	sub    $0x4,%esp
80109b9e:	6a 04                	push   $0x4
80109ba0:	50                   	push   %eax
80109ba1:	68 04 05 11 80       	push   $0x80110504
80109ba6:	e8 c6 ba ff ff       	call   80105671 <memcmp>
80109bab:	83 c4 10             	add    $0x10,%esp
80109bae:	85 c0                	test   %eax,%eax
80109bb0:	74 0a                	je     80109bbc <arp_proc+0xab>
80109bb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109bb7:	e9 ca 00 00 00       	jmp    80109c86 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bc3:	66 3d 00 01          	cmp    $0x100,%ax
80109bc7:	75 69                	jne    80109c32 <arp_proc+0x121>
80109bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bcc:	83 c0 18             	add    $0x18,%eax
80109bcf:	83 ec 04             	sub    $0x4,%esp
80109bd2:	6a 04                	push   $0x4
80109bd4:	50                   	push   %eax
80109bd5:	68 04 05 11 80       	push   $0x80110504
80109bda:	e8 92 ba ff ff       	call   80105671 <memcmp>
80109bdf:	83 c4 10             	add    $0x10,%esp
80109be2:	85 c0                	test   %eax,%eax
80109be4:	75 4c                	jne    80109c32 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109be6:	e8 a7 8c ff ff       	call   80102892 <kalloc>
80109beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109bee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109bf5:	83 ec 04             	sub    $0x4,%esp
80109bf8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109bfb:	50                   	push   %eax
80109bfc:	ff 75 f0             	push   -0x10(%ebp)
80109bff:	ff 75 f4             	push   -0xc(%ebp)
80109c02:	e8 33 04 00 00       	call   8010a03a <arp_reply_pkt_create>
80109c07:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c0d:	83 ec 08             	sub    $0x8,%esp
80109c10:	50                   	push   %eax
80109c11:	ff 75 f0             	push   -0x10(%ebp)
80109c14:	e8 c2 fd ff ff       	call   801099db <i8254_send>
80109c19:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1f:	83 ec 0c             	sub    $0xc,%esp
80109c22:	50                   	push   %eax
80109c23:	e8 cc 8b ff ff       	call   801027f4 <kfree>
80109c28:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109c2b:	b8 02 00 00 00       	mov    $0x2,%eax
80109c30:	eb 54                	jmp    80109c86 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c35:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c39:	66 3d 00 02          	cmp    $0x200,%ax
80109c3d:	75 42                	jne    80109c81 <arp_proc+0x170>
80109c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c42:	83 c0 18             	add    $0x18,%eax
80109c45:	83 ec 04             	sub    $0x4,%esp
80109c48:	6a 04                	push   $0x4
80109c4a:	50                   	push   %eax
80109c4b:	68 04 05 11 80       	push   $0x80110504
80109c50:	e8 1c ba ff ff       	call   80105671 <memcmp>
80109c55:	83 c4 10             	add    $0x10,%esp
80109c58:	85 c0                	test   %eax,%eax
80109c5a:	75 25                	jne    80109c81 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109c5c:	83 ec 0c             	sub    $0xc,%esp
80109c5f:	68 bc cf 10 80       	push   $0x8010cfbc
80109c64:	e8 a3 67 ff ff       	call   8010040c <cprintf>
80109c69:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109c6c:	83 ec 0c             	sub    $0xc,%esp
80109c6f:	ff 75 f4             	push   -0xc(%ebp)
80109c72:	e8 b7 01 00 00       	call   80109e2e <arp_table_update>
80109c77:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109c7a:	b8 01 00 00 00       	mov    $0x1,%eax
80109c7f:	eb 05                	jmp    80109c86 <arp_proc+0x175>
  }else{
    return -1;
80109c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109c86:	c9                   	leave
80109c87:	c3                   	ret

80109c88 <arp_scan>:

void arp_scan(){
80109c88:	f3 0f 1e fb          	endbr32
80109c8c:	55                   	push   %ebp
80109c8d:	89 e5                	mov    %esp,%ebp
80109c8f:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109c92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c99:	eb 6f                	jmp    80109d0a <arp_scan+0x82>
    uint send = (uint)kalloc();
80109c9b:	e8 f2 8b ff ff       	call   80102892 <kalloc>
80109ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109ca3:	83 ec 04             	sub    $0x4,%esp
80109ca6:	ff 75 f4             	push   -0xc(%ebp)
80109ca9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109cac:	50                   	push   %eax
80109cad:	ff 75 ec             	push   -0x14(%ebp)
80109cb0:	e8 62 00 00 00       	call   80109d17 <arp_broadcast>
80109cb5:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109cb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cbb:	83 ec 08             	sub    $0x8,%esp
80109cbe:	50                   	push   %eax
80109cbf:	ff 75 ec             	push   -0x14(%ebp)
80109cc2:	e8 14 fd ff ff       	call   801099db <i8254_send>
80109cc7:	83 c4 10             	add    $0x10,%esp
80109cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109ccd:	eb 22                	jmp    80109cf1 <arp_scan+0x69>
      microdelay(1);
80109ccf:	83 ec 0c             	sub    $0xc,%esp
80109cd2:	6a 01                	push   $0x1
80109cd4:	e8 6b 8f ff ff       	call   80102c44 <microdelay>
80109cd9:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109cdc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cdf:	83 ec 08             	sub    $0x8,%esp
80109ce2:	50                   	push   %eax
80109ce3:	ff 75 ec             	push   -0x14(%ebp)
80109ce6:	e8 f0 fc ff ff       	call   801099db <i8254_send>
80109ceb:	83 c4 10             	add    $0x10,%esp
80109cee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109cf1:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109cf5:	74 d8                	je     80109ccf <arp_scan+0x47>
    }
    kfree((char *)send);
80109cf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cfa:	83 ec 0c             	sub    $0xc,%esp
80109cfd:	50                   	push   %eax
80109cfe:	e8 f1 8a ff ff       	call   801027f4 <kfree>
80109d03:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109d06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109d0a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109d11:	7e 88                	jle    80109c9b <arp_scan+0x13>
  }
}
80109d13:	90                   	nop
80109d14:	90                   	nop
80109d15:	c9                   	leave
80109d16:	c3                   	ret

80109d17 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109d17:	f3 0f 1e fb          	endbr32
80109d1b:	55                   	push   %ebp
80109d1c:	89 e5                	mov    %esp,%ebp
80109d1e:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109d21:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109d25:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109d29:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109d2d:	8b 45 10             	mov    0x10(%ebp),%eax
80109d30:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109d33:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109d3a:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109d40:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109d47:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d50:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109d56:	8b 45 08             	mov    0x8(%ebp),%eax
80109d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5f:	83 c0 0e             	add    $0xe,%eax
80109d62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d68:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d6f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d76:	83 ec 04             	sub    $0x4,%esp
80109d79:	6a 06                	push   $0x6
80109d7b:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109d7e:	52                   	push   %edx
80109d7f:	50                   	push   %eax
80109d80:	e8 48 b9 ff ff       	call   801056cd <memmove>
80109d85:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d8b:	83 c0 06             	add    $0x6,%eax
80109d8e:	83 ec 04             	sub    $0x4,%esp
80109d91:	6a 06                	push   $0x6
80109d93:	68 88 e0 18 80       	push   $0x8018e088
80109d98:	50                   	push   %eax
80109d99:	e8 2f b9 ff ff       	call   801056cd <memmove>
80109d9e:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109da4:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dac:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db5:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dbc:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc3:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dcc:	8d 50 12             	lea    0x12(%eax),%edx
80109dcf:	83 ec 04             	sub    $0x4,%esp
80109dd2:	6a 06                	push   $0x6
80109dd4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109dd7:	50                   	push   %eax
80109dd8:	52                   	push   %edx
80109dd9:	e8 ef b8 ff ff       	call   801056cd <memmove>
80109dde:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de4:	8d 50 18             	lea    0x18(%eax),%edx
80109de7:	83 ec 04             	sub    $0x4,%esp
80109dea:	6a 04                	push   $0x4
80109dec:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109def:	50                   	push   %eax
80109df0:	52                   	push   %edx
80109df1:	e8 d7 b8 ff ff       	call   801056cd <memmove>
80109df6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dfc:	83 c0 08             	add    $0x8,%eax
80109dff:	83 ec 04             	sub    $0x4,%esp
80109e02:	6a 06                	push   $0x6
80109e04:	68 88 e0 18 80       	push   $0x8018e088
80109e09:	50                   	push   %eax
80109e0a:	e8 be b8 ff ff       	call   801056cd <memmove>
80109e0f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e15:	83 c0 0e             	add    $0xe,%eax
80109e18:	83 ec 04             	sub    $0x4,%esp
80109e1b:	6a 04                	push   $0x4
80109e1d:	68 04 05 11 80       	push   $0x80110504
80109e22:	50                   	push   %eax
80109e23:	e8 a5 b8 ff ff       	call   801056cd <memmove>
80109e28:	83 c4 10             	add    $0x10,%esp
}
80109e2b:	90                   	nop
80109e2c:	c9                   	leave
80109e2d:	c3                   	ret

80109e2e <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109e2e:	f3 0f 1e fb          	endbr32
80109e32:	55                   	push   %ebp
80109e33:	89 e5                	mov    %esp,%ebp
80109e35:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109e38:	8b 45 08             	mov    0x8(%ebp),%eax
80109e3b:	83 c0 0e             	add    $0xe,%eax
80109e3e:	83 ec 0c             	sub    $0xc,%esp
80109e41:	50                   	push   %eax
80109e42:	e8 bc 00 00 00       	call   80109f03 <arp_table_search>
80109e47:	83 c4 10             	add    $0x10,%esp
80109e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109e4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109e51:	78 2d                	js     80109e80 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e53:	8b 45 08             	mov    0x8(%ebp),%eax
80109e56:	8d 48 08             	lea    0x8(%eax),%ecx
80109e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e5c:	89 d0                	mov    %edx,%eax
80109e5e:	c1 e0 02             	shl    $0x2,%eax
80109e61:	01 d0                	add    %edx,%eax
80109e63:	01 c0                	add    %eax,%eax
80109e65:	01 d0                	add    %edx,%eax
80109e67:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109e6c:	83 c0 04             	add    $0x4,%eax
80109e6f:	83 ec 04             	sub    $0x4,%esp
80109e72:	6a 06                	push   $0x6
80109e74:	51                   	push   %ecx
80109e75:	50                   	push   %eax
80109e76:	e8 52 b8 ff ff       	call   801056cd <memmove>
80109e7b:	83 c4 10             	add    $0x10,%esp
80109e7e:	eb 70                	jmp    80109ef0 <arp_table_update+0xc2>
  }else{
    index += 1;
80109e80:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109e84:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109e87:	8b 45 08             	mov    0x8(%ebp),%eax
80109e8a:	8d 48 08             	lea    0x8(%eax),%ecx
80109e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e90:	89 d0                	mov    %edx,%eax
80109e92:	c1 e0 02             	shl    $0x2,%eax
80109e95:	01 d0                	add    %edx,%eax
80109e97:	01 c0                	add    %eax,%eax
80109e99:	01 d0                	add    %edx,%eax
80109e9b:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109ea0:	83 c0 04             	add    $0x4,%eax
80109ea3:	83 ec 04             	sub    $0x4,%esp
80109ea6:	6a 06                	push   $0x6
80109ea8:	51                   	push   %ecx
80109ea9:	50                   	push   %eax
80109eaa:	e8 1e b8 ff ff       	call   801056cd <memmove>
80109eaf:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80109eb5:	8d 48 0e             	lea    0xe(%eax),%ecx
80109eb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ebb:	89 d0                	mov    %edx,%eax
80109ebd:	c1 e0 02             	shl    $0x2,%eax
80109ec0:	01 d0                	add    %edx,%eax
80109ec2:	01 c0                	add    %eax,%eax
80109ec4:	01 d0                	add    %edx,%eax
80109ec6:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109ecb:	83 ec 04             	sub    $0x4,%esp
80109ece:	6a 04                	push   $0x4
80109ed0:	51                   	push   %ecx
80109ed1:	50                   	push   %eax
80109ed2:	e8 f6 b7 ff ff       	call   801056cd <memmove>
80109ed7:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109eda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109edd:	89 d0                	mov    %edx,%eax
80109edf:	c1 e0 02             	shl    $0x2,%eax
80109ee2:	01 d0                	add    %edx,%eax
80109ee4:	01 c0                	add    %eax,%eax
80109ee6:	01 d0                	add    %edx,%eax
80109ee8:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109eed:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109ef0:	83 ec 0c             	sub    $0xc,%esp
80109ef3:	68 a0 e0 18 80       	push   $0x8018e0a0
80109ef8:	e8 87 00 00 00       	call   80109f84 <print_arp_table>
80109efd:	83 c4 10             	add    $0x10,%esp
}
80109f00:	90                   	nop
80109f01:	c9                   	leave
80109f02:	c3                   	ret

80109f03 <arp_table_search>:

int arp_table_search(uchar *ip){
80109f03:	f3 0f 1e fb          	endbr32
80109f07:	55                   	push   %ebp
80109f08:	89 e5                	mov    %esp,%ebp
80109f0a:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109f0d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109f14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109f1b:	eb 59                	jmp    80109f76 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109f1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f20:	89 d0                	mov    %edx,%eax
80109f22:	c1 e0 02             	shl    $0x2,%eax
80109f25:	01 d0                	add    %edx,%eax
80109f27:	01 c0                	add    %eax,%eax
80109f29:	01 d0                	add    %edx,%eax
80109f2b:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109f30:	83 ec 04             	sub    $0x4,%esp
80109f33:	6a 04                	push   $0x4
80109f35:	ff 75 08             	push   0x8(%ebp)
80109f38:	50                   	push   %eax
80109f39:	e8 33 b7 ff ff       	call   80105671 <memcmp>
80109f3e:	83 c4 10             	add    $0x10,%esp
80109f41:	85 c0                	test   %eax,%eax
80109f43:	75 05                	jne    80109f4a <arp_table_search+0x47>
      return i;
80109f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f48:	eb 38                	jmp    80109f82 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109f4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109f4d:	89 d0                	mov    %edx,%eax
80109f4f:	c1 e0 02             	shl    $0x2,%eax
80109f52:	01 d0                	add    %edx,%eax
80109f54:	01 c0                	add    %eax,%eax
80109f56:	01 d0                	add    %edx,%eax
80109f58:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109f5d:	0f b6 00             	movzbl (%eax),%eax
80109f60:	84 c0                	test   %al,%al
80109f62:	75 0e                	jne    80109f72 <arp_table_search+0x6f>
80109f64:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109f68:	75 08                	jne    80109f72 <arp_table_search+0x6f>
      empty = -i;
80109f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f6d:	f7 d8                	neg    %eax
80109f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109f72:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109f76:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109f7a:	7e a1                	jle    80109f1d <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f7f:	83 e8 01             	sub    $0x1,%eax
}
80109f82:	c9                   	leave
80109f83:	c3                   	ret

80109f84 <print_arp_table>:

void print_arp_table(){
80109f84:	f3 0f 1e fb          	endbr32
80109f88:	55                   	push   %ebp
80109f89:	89 e5                	mov    %esp,%ebp
80109f8b:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109f8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109f95:	e9 92 00 00 00       	jmp    8010a02c <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109f9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f9d:	89 d0                	mov    %edx,%eax
80109f9f:	c1 e0 02             	shl    $0x2,%eax
80109fa2:	01 d0                	add    %edx,%eax
80109fa4:	01 c0                	add    %eax,%eax
80109fa6:	01 d0                	add    %edx,%eax
80109fa8:	05 aa e0 18 80       	add    $0x8018e0aa,%eax
80109fad:	0f b6 00             	movzbl (%eax),%eax
80109fb0:	84 c0                	test   %al,%al
80109fb2:	74 74                	je     8010a028 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109fb4:	83 ec 08             	sub    $0x8,%esp
80109fb7:	ff 75 f4             	push   -0xc(%ebp)
80109fba:	68 cf cf 10 80       	push   $0x8010cfcf
80109fbf:	e8 48 64 ff ff       	call   8010040c <cprintf>
80109fc4:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fca:	89 d0                	mov    %edx,%eax
80109fcc:	c1 e0 02             	shl    $0x2,%eax
80109fcf:	01 d0                	add    %edx,%eax
80109fd1:	01 c0                	add    %eax,%eax
80109fd3:	01 d0                	add    %edx,%eax
80109fd5:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
80109fda:	83 ec 0c             	sub    $0xc,%esp
80109fdd:	50                   	push   %eax
80109fde:	e8 5c 02 00 00       	call   8010a23f <print_ipv4>
80109fe3:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109fe6:	83 ec 0c             	sub    $0xc,%esp
80109fe9:	68 de cf 10 80       	push   $0x8010cfde
80109fee:	e8 19 64 ff ff       	call   8010040c <cprintf>
80109ff3:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ff9:	89 d0                	mov    %edx,%eax
80109ffb:	c1 e0 02             	shl    $0x2,%eax
80109ffe:	01 d0                	add    %edx,%eax
8010a000:	01 c0                	add    %eax,%eax
8010a002:	01 d0                	add    %edx,%eax
8010a004:	05 a0 e0 18 80       	add    $0x8018e0a0,%eax
8010a009:	83 c0 04             	add    $0x4,%eax
8010a00c:	83 ec 0c             	sub    $0xc,%esp
8010a00f:	50                   	push   %eax
8010a010:	e8 7c 02 00 00       	call   8010a291 <print_mac>
8010a015:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010a018:	83 ec 0c             	sub    $0xc,%esp
8010a01b:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a020:	e8 e7 63 ff ff       	call   8010040c <cprintf>
8010a025:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010a028:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010a02c:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010a030:	0f 8e 64 ff ff ff    	jle    80109f9a <print_arp_table+0x16>
    }
  }
}
8010a036:	90                   	nop
8010a037:	90                   	nop
8010a038:	c9                   	leave
8010a039:	c3                   	ret

8010a03a <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010a03a:	f3 0f 1e fb          	endbr32
8010a03e:	55                   	push   %ebp
8010a03f:	89 e5                	mov    %esp,%ebp
8010a041:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010a044:	8b 45 10             	mov    0x10(%ebp),%eax
8010a047:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010a04d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a050:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010a053:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a056:	83 c0 0e             	add    $0xe,%eax
8010a059:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010a05c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a05f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010a063:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a066:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010a06a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a06d:	8d 50 08             	lea    0x8(%eax),%edx
8010a070:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a073:	83 ec 04             	sub    $0x4,%esp
8010a076:	6a 06                	push   $0x6
8010a078:	52                   	push   %edx
8010a079:	50                   	push   %eax
8010a07a:	e8 4e b6 ff ff       	call   801056cd <memmove>
8010a07f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010a082:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a085:	83 c0 06             	add    $0x6,%eax
8010a088:	83 ec 04             	sub    $0x4,%esp
8010a08b:	6a 06                	push   $0x6
8010a08d:	68 88 e0 18 80       	push   $0x8018e088
8010a092:	50                   	push   %eax
8010a093:	e8 35 b6 ff ff       	call   801056cd <memmove>
8010a098:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010a09b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010a0a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a6:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010a0ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0af:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010a0b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b6:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010a0ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0bd:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010a0c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c6:	8d 50 08             	lea    0x8(%eax),%edx
8010a0c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0cc:	83 c0 12             	add    $0x12,%eax
8010a0cf:	83 ec 04             	sub    $0x4,%esp
8010a0d2:	6a 06                	push   $0x6
8010a0d4:	52                   	push   %edx
8010a0d5:	50                   	push   %eax
8010a0d6:	e8 f2 b5 ff ff       	call   801056cd <memmove>
8010a0db:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010a0de:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e1:	8d 50 0e             	lea    0xe(%eax),%edx
8010a0e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0e7:	83 c0 18             	add    $0x18,%eax
8010a0ea:	83 ec 04             	sub    $0x4,%esp
8010a0ed:	6a 04                	push   $0x4
8010a0ef:	52                   	push   %edx
8010a0f0:	50                   	push   %eax
8010a0f1:	e8 d7 b5 ff ff       	call   801056cd <memmove>
8010a0f6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010a0f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0fc:	83 c0 08             	add    $0x8,%eax
8010a0ff:	83 ec 04             	sub    $0x4,%esp
8010a102:	6a 06                	push   $0x6
8010a104:	68 88 e0 18 80       	push   $0x8018e088
8010a109:	50                   	push   %eax
8010a10a:	e8 be b5 ff ff       	call   801056cd <memmove>
8010a10f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010a112:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a115:	83 c0 0e             	add    $0xe,%eax
8010a118:	83 ec 04             	sub    $0x4,%esp
8010a11b:	6a 04                	push   $0x4
8010a11d:	68 04 05 11 80       	push   $0x80110504
8010a122:	50                   	push   %eax
8010a123:	e8 a5 b5 ff ff       	call   801056cd <memmove>
8010a128:	83 c4 10             	add    $0x10,%esp
}
8010a12b:	90                   	nop
8010a12c:	c9                   	leave
8010a12d:	c3                   	ret

8010a12e <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010a12e:	f3 0f 1e fb          	endbr32
8010a132:	55                   	push   %ebp
8010a133:	89 e5                	mov    %esp,%ebp
8010a135:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010a138:	83 ec 0c             	sub    $0xc,%esp
8010a13b:	68 e2 cf 10 80       	push   $0x8010cfe2
8010a140:	e8 c7 62 ff ff       	call   8010040c <cprintf>
8010a145:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010a148:	8b 45 08             	mov    0x8(%ebp),%eax
8010a14b:	83 c0 0e             	add    $0xe,%eax
8010a14e:	83 ec 0c             	sub    $0xc,%esp
8010a151:	50                   	push   %eax
8010a152:	e8 e8 00 00 00       	call   8010a23f <print_ipv4>
8010a157:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a15a:	83 ec 0c             	sub    $0xc,%esp
8010a15d:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a162:	e8 a5 62 ff ff       	call   8010040c <cprintf>
8010a167:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010a16a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a16d:	83 c0 08             	add    $0x8,%eax
8010a170:	83 ec 0c             	sub    $0xc,%esp
8010a173:	50                   	push   %eax
8010a174:	e8 18 01 00 00       	call   8010a291 <print_mac>
8010a179:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a17c:	83 ec 0c             	sub    $0xc,%esp
8010a17f:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a184:	e8 83 62 ff ff       	call   8010040c <cprintf>
8010a189:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a18c:	83 ec 0c             	sub    $0xc,%esp
8010a18f:	68 f9 cf 10 80       	push   $0x8010cff9
8010a194:	e8 73 62 ff ff       	call   8010040c <cprintf>
8010a199:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010a19c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a19f:	83 c0 18             	add    $0x18,%eax
8010a1a2:	83 ec 0c             	sub    $0xc,%esp
8010a1a5:	50                   	push   %eax
8010a1a6:	e8 94 00 00 00       	call   8010a23f <print_ipv4>
8010a1ab:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a1ae:	83 ec 0c             	sub    $0xc,%esp
8010a1b1:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a1b6:	e8 51 62 ff ff       	call   8010040c <cprintf>
8010a1bb:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010a1be:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1c1:	83 c0 12             	add    $0x12,%eax
8010a1c4:	83 ec 0c             	sub    $0xc,%esp
8010a1c7:	50                   	push   %eax
8010a1c8:	e8 c4 00 00 00       	call   8010a291 <print_mac>
8010a1cd:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a1d0:	83 ec 0c             	sub    $0xc,%esp
8010a1d3:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a1d8:	e8 2f 62 ff ff       	call   8010040c <cprintf>
8010a1dd:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a1e0:	83 ec 0c             	sub    $0xc,%esp
8010a1e3:	68 10 d0 10 80       	push   $0x8010d010
8010a1e8:	e8 1f 62 ff ff       	call   8010040c <cprintf>
8010a1ed:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a1f0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1f7:	66 3d 00 01          	cmp    $0x100,%ax
8010a1fb:	75 12                	jne    8010a20f <print_arp_info+0xe1>
8010a1fd:	83 ec 0c             	sub    $0xc,%esp
8010a200:	68 1c d0 10 80       	push   $0x8010d01c
8010a205:	e8 02 62 ff ff       	call   8010040c <cprintf>
8010a20a:	83 c4 10             	add    $0x10,%esp
8010a20d:	eb 1d                	jmp    8010a22c <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a20f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a212:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a216:	66 3d 00 02          	cmp    $0x200,%ax
8010a21a:	75 10                	jne    8010a22c <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a21c:	83 ec 0c             	sub    $0xc,%esp
8010a21f:	68 25 d0 10 80       	push   $0x8010d025
8010a224:	e8 e3 61 ff ff       	call   8010040c <cprintf>
8010a229:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a22c:	83 ec 0c             	sub    $0xc,%esp
8010a22f:	68 e0 cf 10 80       	push   $0x8010cfe0
8010a234:	e8 d3 61 ff ff       	call   8010040c <cprintf>
8010a239:	83 c4 10             	add    $0x10,%esp
}
8010a23c:	90                   	nop
8010a23d:	c9                   	leave
8010a23e:	c3                   	ret

8010a23f <print_ipv4>:

void print_ipv4(uchar *ip){
8010a23f:	f3 0f 1e fb          	endbr32
8010a243:	55                   	push   %ebp
8010a244:	89 e5                	mov    %esp,%ebp
8010a246:	53                   	push   %ebx
8010a247:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a24a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a24d:	83 c0 03             	add    $0x3,%eax
8010a250:	0f b6 00             	movzbl (%eax),%eax
8010a253:	0f b6 d8             	movzbl %al,%ebx
8010a256:	8b 45 08             	mov    0x8(%ebp),%eax
8010a259:	83 c0 02             	add    $0x2,%eax
8010a25c:	0f b6 00             	movzbl (%eax),%eax
8010a25f:	0f b6 c8             	movzbl %al,%ecx
8010a262:	8b 45 08             	mov    0x8(%ebp),%eax
8010a265:	83 c0 01             	add    $0x1,%eax
8010a268:	0f b6 00             	movzbl (%eax),%eax
8010a26b:	0f b6 d0             	movzbl %al,%edx
8010a26e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a271:	0f b6 00             	movzbl (%eax),%eax
8010a274:	0f b6 c0             	movzbl %al,%eax
8010a277:	83 ec 0c             	sub    $0xc,%esp
8010a27a:	53                   	push   %ebx
8010a27b:	51                   	push   %ecx
8010a27c:	52                   	push   %edx
8010a27d:	50                   	push   %eax
8010a27e:	68 2c d0 10 80       	push   $0x8010d02c
8010a283:	e8 84 61 ff ff       	call   8010040c <cprintf>
8010a288:	83 c4 20             	add    $0x20,%esp
}
8010a28b:	90                   	nop
8010a28c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a28f:	c9                   	leave
8010a290:	c3                   	ret

8010a291 <print_mac>:

void print_mac(uchar *mac){
8010a291:	f3 0f 1e fb          	endbr32
8010a295:	55                   	push   %ebp
8010a296:	89 e5                	mov    %esp,%ebp
8010a298:	57                   	push   %edi
8010a299:	56                   	push   %esi
8010a29a:	53                   	push   %ebx
8010a29b:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a29e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a1:	83 c0 05             	add    $0x5,%eax
8010a2a4:	0f b6 00             	movzbl (%eax),%eax
8010a2a7:	0f b6 f8             	movzbl %al,%edi
8010a2aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ad:	83 c0 04             	add    $0x4,%eax
8010a2b0:	0f b6 00             	movzbl (%eax),%eax
8010a2b3:	0f b6 f0             	movzbl %al,%esi
8010a2b6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2b9:	83 c0 03             	add    $0x3,%eax
8010a2bc:	0f b6 00             	movzbl (%eax),%eax
8010a2bf:	0f b6 d8             	movzbl %al,%ebx
8010a2c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c5:	83 c0 02             	add    $0x2,%eax
8010a2c8:	0f b6 00             	movzbl (%eax),%eax
8010a2cb:	0f b6 c8             	movzbl %al,%ecx
8010a2ce:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2d1:	83 c0 01             	add    $0x1,%eax
8010a2d4:	0f b6 00             	movzbl (%eax),%eax
8010a2d7:	0f b6 d0             	movzbl %al,%edx
8010a2da:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2dd:	0f b6 00             	movzbl (%eax),%eax
8010a2e0:	0f b6 c0             	movzbl %al,%eax
8010a2e3:	83 ec 04             	sub    $0x4,%esp
8010a2e6:	57                   	push   %edi
8010a2e7:	56                   	push   %esi
8010a2e8:	53                   	push   %ebx
8010a2e9:	51                   	push   %ecx
8010a2ea:	52                   	push   %edx
8010a2eb:	50                   	push   %eax
8010a2ec:	68 44 d0 10 80       	push   $0x8010d044
8010a2f1:	e8 16 61 ff ff       	call   8010040c <cprintf>
8010a2f6:	83 c4 20             	add    $0x20,%esp
}
8010a2f9:	90                   	nop
8010a2fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a2fd:	5b                   	pop    %ebx
8010a2fe:	5e                   	pop    %esi
8010a2ff:	5f                   	pop    %edi
8010a300:	5d                   	pop    %ebp
8010a301:	c3                   	ret

8010a302 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a302:	f3 0f 1e fb          	endbr32
8010a306:	55                   	push   %ebp
8010a307:	89 e5                	mov    %esp,%ebp
8010a309:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a30c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a30f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a312:	8b 45 08             	mov    0x8(%ebp),%eax
8010a315:	83 c0 0e             	add    $0xe,%eax
8010a318:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a31b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a31e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a322:	3c 08                	cmp    $0x8,%al
8010a324:	75 1b                	jne    8010a341 <eth_proc+0x3f>
8010a326:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a329:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a32d:	3c 06                	cmp    $0x6,%al
8010a32f:	75 10                	jne    8010a341 <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a331:	83 ec 0c             	sub    $0xc,%esp
8010a334:	ff 75 f0             	push   -0x10(%ebp)
8010a337:	e8 d5 f7 ff ff       	call   80109b11 <arp_proc>
8010a33c:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a33f:	eb 24                	jmp    8010a365 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a341:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a344:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a348:	3c 08                	cmp    $0x8,%al
8010a34a:	75 19                	jne    8010a365 <eth_proc+0x63>
8010a34c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a34f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a353:	84 c0                	test   %al,%al
8010a355:	75 0e                	jne    8010a365 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a357:	83 ec 0c             	sub    $0xc,%esp
8010a35a:	ff 75 08             	push   0x8(%ebp)
8010a35d:	e8 b3 00 00 00       	call   8010a415 <ipv4_proc>
8010a362:	83 c4 10             	add    $0x10,%esp
}
8010a365:	90                   	nop
8010a366:	c9                   	leave
8010a367:	c3                   	ret

8010a368 <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a368:	f3 0f 1e fb          	endbr32
8010a36c:	55                   	push   %ebp
8010a36d:	89 e5                	mov    %esp,%ebp
8010a36f:	83 ec 04             	sub    $0x4,%esp
8010a372:	8b 45 08             	mov    0x8(%ebp),%eax
8010a375:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a379:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a37d:	c1 e0 08             	shl    $0x8,%eax
8010a380:	89 c2                	mov    %eax,%edx
8010a382:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a386:	66 c1 e8 08          	shr    $0x8,%ax
8010a38a:	01 d0                	add    %edx,%eax
}
8010a38c:	c9                   	leave
8010a38d:	c3                   	ret

8010a38e <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a38e:	f3 0f 1e fb          	endbr32
8010a392:	55                   	push   %ebp
8010a393:	89 e5                	mov    %esp,%ebp
8010a395:	83 ec 04             	sub    $0x4,%esp
8010a398:	8b 45 08             	mov    0x8(%ebp),%eax
8010a39b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a39f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a3a3:	c1 e0 08             	shl    $0x8,%eax
8010a3a6:	89 c2                	mov    %eax,%edx
8010a3a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a3ac:	66 c1 e8 08          	shr    $0x8,%ax
8010a3b0:	01 d0                	add    %edx,%eax
}
8010a3b2:	c9                   	leave
8010a3b3:	c3                   	ret

8010a3b4 <H2N_uint>:

uint H2N_uint(uint value){
8010a3b4:	f3 0f 1e fb          	endbr32
8010a3b8:	55                   	push   %ebp
8010a3b9:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a3bb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3be:	c1 e0 18             	shl    $0x18,%eax
8010a3c1:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a3c6:	89 c2                	mov    %eax,%edx
8010a3c8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3cb:	c1 e0 08             	shl    $0x8,%eax
8010a3ce:	25 00 f0 00 00       	and    $0xf000,%eax
8010a3d3:	09 c2                	or     %eax,%edx
8010a3d5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3d8:	c1 e8 08             	shr    $0x8,%eax
8010a3db:	83 e0 0f             	and    $0xf,%eax
8010a3de:	01 d0                	add    %edx,%eax
}
8010a3e0:	5d                   	pop    %ebp
8010a3e1:	c3                   	ret

8010a3e2 <N2H_uint>:

uint N2H_uint(uint value){
8010a3e2:	f3 0f 1e fb          	endbr32
8010a3e6:	55                   	push   %ebp
8010a3e7:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a3e9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ec:	c1 e0 18             	shl    $0x18,%eax
8010a3ef:	89 c2                	mov    %eax,%edx
8010a3f1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3f4:	c1 e0 08             	shl    $0x8,%eax
8010a3f7:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a3fc:	01 c2                	add    %eax,%edx
8010a3fe:	8b 45 08             	mov    0x8(%ebp),%eax
8010a401:	c1 e8 08             	shr    $0x8,%eax
8010a404:	25 00 ff 00 00       	and    $0xff00,%eax
8010a409:	01 c2                	add    %eax,%edx
8010a40b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40e:	c1 e8 18             	shr    $0x18,%eax
8010a411:	01 d0                	add    %edx,%eax
}
8010a413:	5d                   	pop    %ebp
8010a414:	c3                   	ret

8010a415 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a415:	f3 0f 1e fb          	endbr32
8010a419:	55                   	push   %ebp
8010a41a:	89 e5                	mov    %esp,%ebp
8010a41c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a41f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a422:	83 c0 0e             	add    $0xe,%eax
8010a425:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a42b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a42f:	0f b7 d0             	movzwl %ax,%edx
8010a432:	a1 08 05 11 80       	mov    0x80110508,%eax
8010a437:	39 c2                	cmp    %eax,%edx
8010a439:	74 60                	je     8010a49b <ipv4_proc+0x86>
8010a43b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a43e:	83 c0 0c             	add    $0xc,%eax
8010a441:	83 ec 04             	sub    $0x4,%esp
8010a444:	6a 04                	push   $0x4
8010a446:	50                   	push   %eax
8010a447:	68 04 05 11 80       	push   $0x80110504
8010a44c:	e8 20 b2 ff ff       	call   80105671 <memcmp>
8010a451:	83 c4 10             	add    $0x10,%esp
8010a454:	85 c0                	test   %eax,%eax
8010a456:	74 43                	je     8010a49b <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a45b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a45f:	0f b7 c0             	movzwl %ax,%eax
8010a462:	a3 08 05 11 80       	mov    %eax,0x80110508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a46a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a46e:	3c 01                	cmp    $0x1,%al
8010a470:	75 10                	jne    8010a482 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a472:	83 ec 0c             	sub    $0xc,%esp
8010a475:	ff 75 08             	push   0x8(%ebp)
8010a478:	e8 a7 00 00 00       	call   8010a524 <icmp_proc>
8010a47d:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a480:	eb 19                	jmp    8010a49b <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a482:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a485:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a489:	3c 06                	cmp    $0x6,%al
8010a48b:	75 0e                	jne    8010a49b <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a48d:	83 ec 0c             	sub    $0xc,%esp
8010a490:	ff 75 08             	push   0x8(%ebp)
8010a493:	e8 c7 03 00 00       	call   8010a85f <tcp_proc>
8010a498:	83 c4 10             	add    $0x10,%esp
}
8010a49b:	90                   	nop
8010a49c:	c9                   	leave
8010a49d:	c3                   	ret

8010a49e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a49e:	f3 0f 1e fb          	endbr32
8010a4a2:	55                   	push   %ebp
8010a4a3:	89 e5                	mov    %esp,%ebp
8010a4a5:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a4a8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4b1:	0f b6 00             	movzbl (%eax),%eax
8010a4b4:	83 e0 0f             	and    $0xf,%eax
8010a4b7:	01 c0                	add    %eax,%eax
8010a4b9:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a4bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a4c3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a4ca:	eb 48                	jmp    8010a514 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a4cf:	01 c0                	add    %eax,%eax
8010a4d1:	89 c2                	mov    %eax,%edx
8010a4d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4d6:	01 d0                	add    %edx,%eax
8010a4d8:	0f b6 00             	movzbl (%eax),%eax
8010a4db:	0f b6 c0             	movzbl %al,%eax
8010a4de:	c1 e0 08             	shl    $0x8,%eax
8010a4e1:	89 c2                	mov    %eax,%edx
8010a4e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a4e6:	01 c0                	add    %eax,%eax
8010a4e8:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4ee:	01 c8                	add    %ecx,%eax
8010a4f0:	0f b6 00             	movzbl (%eax),%eax
8010a4f3:	0f b6 c0             	movzbl %al,%eax
8010a4f6:	01 d0                	add    %edx,%eax
8010a4f8:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a4fb:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a502:	76 0c                	jbe    8010a510 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a504:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a507:	0f b7 c0             	movzwl %ax,%eax
8010a50a:	83 c0 01             	add    $0x1,%eax
8010a50d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a510:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a514:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a518:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a51b:	7c af                	jl     8010a4cc <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a51d:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a520:	f7 d0                	not    %eax
}
8010a522:	c9                   	leave
8010a523:	c3                   	ret

8010a524 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a524:	f3 0f 1e fb          	endbr32
8010a528:	55                   	push   %ebp
8010a529:	89 e5                	mov    %esp,%ebp
8010a52b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a52e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a531:	83 c0 0e             	add    $0xe,%eax
8010a534:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a53a:	0f b6 00             	movzbl (%eax),%eax
8010a53d:	0f b6 c0             	movzbl %al,%eax
8010a540:	83 e0 0f             	and    $0xf,%eax
8010a543:	c1 e0 02             	shl    $0x2,%eax
8010a546:	89 c2                	mov    %eax,%edx
8010a548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a54b:	01 d0                	add    %edx,%eax
8010a54d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a550:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a553:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a557:	84 c0                	test   %al,%al
8010a559:	75 4f                	jne    8010a5aa <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a55b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a55e:	0f b6 00             	movzbl (%eax),%eax
8010a561:	3c 08                	cmp    $0x8,%al
8010a563:	75 45                	jne    8010a5aa <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a565:	e8 28 83 ff ff       	call   80102892 <kalloc>
8010a56a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a56d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a574:	83 ec 04             	sub    $0x4,%esp
8010a577:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a57a:	50                   	push   %eax
8010a57b:	ff 75 ec             	push   -0x14(%ebp)
8010a57e:	ff 75 08             	push   0x8(%ebp)
8010a581:	e8 7c 00 00 00       	call   8010a602 <icmp_reply_pkt_create>
8010a586:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a589:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a58c:	83 ec 08             	sub    $0x8,%esp
8010a58f:	50                   	push   %eax
8010a590:	ff 75 ec             	push   -0x14(%ebp)
8010a593:	e8 43 f4 ff ff       	call   801099db <i8254_send>
8010a598:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a59b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a59e:	83 ec 0c             	sub    $0xc,%esp
8010a5a1:	50                   	push   %eax
8010a5a2:	e8 4d 82 ff ff       	call   801027f4 <kfree>
8010a5a7:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a5aa:	90                   	nop
8010a5ab:	c9                   	leave
8010a5ac:	c3                   	ret

8010a5ad <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a5ad:	f3 0f 1e fb          	endbr32
8010a5b1:	55                   	push   %ebp
8010a5b2:	89 e5                	mov    %esp,%ebp
8010a5b4:	53                   	push   %ebx
8010a5b5:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a5b8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5bb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a5bf:	0f b7 c0             	movzwl %ax,%eax
8010a5c2:	83 ec 0c             	sub    $0xc,%esp
8010a5c5:	50                   	push   %eax
8010a5c6:	e8 9d fd ff ff       	call   8010a368 <N2H_ushort>
8010a5cb:	83 c4 10             	add    $0x10,%esp
8010a5ce:	0f b7 d8             	movzwl %ax,%ebx
8010a5d1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5d4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a5d8:	0f b7 c0             	movzwl %ax,%eax
8010a5db:	83 ec 0c             	sub    $0xc,%esp
8010a5de:	50                   	push   %eax
8010a5df:	e8 84 fd ff ff       	call   8010a368 <N2H_ushort>
8010a5e4:	83 c4 10             	add    $0x10,%esp
8010a5e7:	0f b7 c0             	movzwl %ax,%eax
8010a5ea:	83 ec 04             	sub    $0x4,%esp
8010a5ed:	53                   	push   %ebx
8010a5ee:	50                   	push   %eax
8010a5ef:	68 63 d0 10 80       	push   $0x8010d063
8010a5f4:	e8 13 5e ff ff       	call   8010040c <cprintf>
8010a5f9:	83 c4 10             	add    $0x10,%esp
}
8010a5fc:	90                   	nop
8010a5fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a600:	c9                   	leave
8010a601:	c3                   	ret

8010a602 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a602:	f3 0f 1e fb          	endbr32
8010a606:	55                   	push   %ebp
8010a607:	89 e5                	mov    %esp,%ebp
8010a609:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a60c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a60f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a612:	8b 45 08             	mov    0x8(%ebp),%eax
8010a615:	83 c0 0e             	add    $0xe,%eax
8010a618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a61b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a61e:	0f b6 00             	movzbl (%eax),%eax
8010a621:	0f b6 c0             	movzbl %al,%eax
8010a624:	83 e0 0f             	and    $0xf,%eax
8010a627:	c1 e0 02             	shl    $0x2,%eax
8010a62a:	89 c2                	mov    %eax,%edx
8010a62c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a62f:	01 d0                	add    %edx,%eax
8010a631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a634:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a637:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a63a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a63d:	83 c0 0e             	add    $0xe,%eax
8010a640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a646:	83 c0 14             	add    $0x14,%eax
8010a649:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a64c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a64f:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a655:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a658:	8d 50 06             	lea    0x6(%eax),%edx
8010a65b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a65e:	83 ec 04             	sub    $0x4,%esp
8010a661:	6a 06                	push   $0x6
8010a663:	52                   	push   %edx
8010a664:	50                   	push   %eax
8010a665:	e8 63 b0 ff ff       	call   801056cd <memmove>
8010a66a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a66d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a670:	83 c0 06             	add    $0x6,%eax
8010a673:	83 ec 04             	sub    $0x4,%esp
8010a676:	6a 06                	push   $0x6
8010a678:	68 88 e0 18 80       	push   $0x8018e088
8010a67d:	50                   	push   %eax
8010a67e:	e8 4a b0 ff ff       	call   801056cd <memmove>
8010a683:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a686:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a689:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a68d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a690:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a697:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a69a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a69d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a6a1:	83 ec 0c             	sub    $0xc,%esp
8010a6a4:	6a 54                	push   $0x54
8010a6a6:	e8 e3 fc ff ff       	call   8010a38e <H2N_ushort>
8010a6ab:	83 c4 10             	add    $0x10,%esp
8010a6ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a6b1:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a6b5:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010a6bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6bf:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a6c3:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010a6ca:	83 c0 01             	add    $0x1,%eax
8010a6cd:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a6d3:	83 ec 0c             	sub    $0xc,%esp
8010a6d6:	68 00 40 00 00       	push   $0x4000
8010a6db:	e8 ae fc ff ff       	call   8010a38e <H2N_ushort>
8010a6e0:	83 c4 10             	add    $0x10,%esp
8010a6e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a6e6:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a6ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6ed:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a6f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6f4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a6f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6fb:	83 c0 0c             	add    $0xc,%eax
8010a6fe:	83 ec 04             	sub    $0x4,%esp
8010a701:	6a 04                	push   $0x4
8010a703:	68 04 05 11 80       	push   $0x80110504
8010a708:	50                   	push   %eax
8010a709:	e8 bf af ff ff       	call   801056cd <memmove>
8010a70e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a711:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a714:	8d 50 0c             	lea    0xc(%eax),%edx
8010a717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a71a:	83 c0 10             	add    $0x10,%eax
8010a71d:	83 ec 04             	sub    $0x4,%esp
8010a720:	6a 04                	push   $0x4
8010a722:	52                   	push   %edx
8010a723:	50                   	push   %eax
8010a724:	e8 a4 af ff ff       	call   801056cd <memmove>
8010a729:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a72c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a72f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a735:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a738:	83 ec 0c             	sub    $0xc,%esp
8010a73b:	50                   	push   %eax
8010a73c:	e8 5d fd ff ff       	call   8010a49e <ipv4_chksum>
8010a741:	83 c4 10             	add    $0x10,%esp
8010a744:	0f b7 c0             	movzwl %ax,%eax
8010a747:	83 ec 0c             	sub    $0xc,%esp
8010a74a:	50                   	push   %eax
8010a74b:	e8 3e fc ff ff       	call   8010a38e <H2N_ushort>
8010a750:	83 c4 10             	add    $0x10,%esp
8010a753:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a756:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a75a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a75d:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a760:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a763:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a767:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a76a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a76e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a771:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a775:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a778:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a77c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a77f:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a783:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a786:	8d 50 08             	lea    0x8(%eax),%edx
8010a789:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a78c:	83 c0 08             	add    $0x8,%eax
8010a78f:	83 ec 04             	sub    $0x4,%esp
8010a792:	6a 08                	push   $0x8
8010a794:	52                   	push   %edx
8010a795:	50                   	push   %eax
8010a796:	e8 32 af ff ff       	call   801056cd <memmove>
8010a79b:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a79e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7a1:	8d 50 10             	lea    0x10(%eax),%edx
8010a7a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7a7:	83 c0 10             	add    $0x10,%eax
8010a7aa:	83 ec 04             	sub    $0x4,%esp
8010a7ad:	6a 30                	push   $0x30
8010a7af:	52                   	push   %edx
8010a7b0:	50                   	push   %eax
8010a7b1:	e8 17 af ff ff       	call   801056cd <memmove>
8010a7b6:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a7b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7bc:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a7c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7c5:	83 ec 0c             	sub    $0xc,%esp
8010a7c8:	50                   	push   %eax
8010a7c9:	e8 1c 00 00 00       	call   8010a7ea <icmp_chksum>
8010a7ce:	83 c4 10             	add    $0x10,%esp
8010a7d1:	0f b7 c0             	movzwl %ax,%eax
8010a7d4:	83 ec 0c             	sub    $0xc,%esp
8010a7d7:	50                   	push   %eax
8010a7d8:	e8 b1 fb ff ff       	call   8010a38e <H2N_ushort>
8010a7dd:	83 c4 10             	add    $0x10,%esp
8010a7e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a7e3:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a7e7:	90                   	nop
8010a7e8:	c9                   	leave
8010a7e9:	c3                   	ret

8010a7ea <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a7ea:	f3 0f 1e fb          	endbr32
8010a7ee:	55                   	push   %ebp
8010a7ef:	89 e5                	mov    %esp,%ebp
8010a7f1:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a7f4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a7fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a801:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a808:	eb 48                	jmp    8010a852 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a80d:	01 c0                	add    %eax,%eax
8010a80f:	89 c2                	mov    %eax,%edx
8010a811:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a814:	01 d0                	add    %edx,%eax
8010a816:	0f b6 00             	movzbl (%eax),%eax
8010a819:	0f b6 c0             	movzbl %al,%eax
8010a81c:	c1 e0 08             	shl    $0x8,%eax
8010a81f:	89 c2                	mov    %eax,%edx
8010a821:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a824:	01 c0                	add    %eax,%eax
8010a826:	8d 48 01             	lea    0x1(%eax),%ecx
8010a829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a82c:	01 c8                	add    %ecx,%eax
8010a82e:	0f b6 00             	movzbl (%eax),%eax
8010a831:	0f b6 c0             	movzbl %al,%eax
8010a834:	01 d0                	add    %edx,%eax
8010a836:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a839:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a840:	76 0c                	jbe    8010a84e <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a842:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a845:	0f b7 c0             	movzwl %ax,%eax
8010a848:	83 c0 01             	add    $0x1,%eax
8010a84b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a84e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a852:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a856:	7e b2                	jle    8010a80a <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a858:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a85b:	f7 d0                	not    %eax
}
8010a85d:	c9                   	leave
8010a85e:	c3                   	ret

8010a85f <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a85f:	f3 0f 1e fb          	endbr32
8010a863:	55                   	push   %ebp
8010a864:	89 e5                	mov    %esp,%ebp
8010a866:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a869:	8b 45 08             	mov    0x8(%ebp),%eax
8010a86c:	83 c0 0e             	add    $0xe,%eax
8010a86f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a872:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a875:	0f b6 00             	movzbl (%eax),%eax
8010a878:	0f b6 c0             	movzbl %al,%eax
8010a87b:	83 e0 0f             	and    $0xf,%eax
8010a87e:	c1 e0 02             	shl    $0x2,%eax
8010a881:	89 c2                	mov    %eax,%edx
8010a883:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a886:	01 d0                	add    %edx,%eax
8010a888:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a88b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a88e:	83 c0 14             	add    $0x14,%eax
8010a891:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a894:	e8 f9 7f ff ff       	call   80102892 <kalloc>
8010a899:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a89c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8a6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a8aa:	0f b6 c0             	movzbl %al,%eax
8010a8ad:	83 e0 02             	and    $0x2,%eax
8010a8b0:	85 c0                	test   %eax,%eax
8010a8b2:	74 3d                	je     8010a8f1 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a8b4:	83 ec 0c             	sub    $0xc,%esp
8010a8b7:	6a 00                	push   $0x0
8010a8b9:	6a 12                	push   $0x12
8010a8bb:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a8be:	50                   	push   %eax
8010a8bf:	ff 75 e8             	push   -0x18(%ebp)
8010a8c2:	ff 75 08             	push   0x8(%ebp)
8010a8c5:	e8 a2 01 00 00       	call   8010aa6c <tcp_pkt_create>
8010a8ca:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a8cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8d0:	83 ec 08             	sub    $0x8,%esp
8010a8d3:	50                   	push   %eax
8010a8d4:	ff 75 e8             	push   -0x18(%ebp)
8010a8d7:	e8 ff f0 ff ff       	call   801099db <i8254_send>
8010a8dc:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a8df:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010a8e4:	83 c0 01             	add    $0x1,%eax
8010a8e7:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010a8ec:	e9 69 01 00 00       	jmp    8010aa5a <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8f4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a8f8:	3c 18                	cmp    $0x18,%al
8010a8fa:	0f 85 10 01 00 00    	jne    8010aa10 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a900:	83 ec 04             	sub    $0x4,%esp
8010a903:	6a 03                	push   $0x3
8010a905:	68 7e d0 10 80       	push   $0x8010d07e
8010a90a:	ff 75 ec             	push   -0x14(%ebp)
8010a90d:	e8 5f ad ff ff       	call   80105671 <memcmp>
8010a912:	83 c4 10             	add    $0x10,%esp
8010a915:	85 c0                	test   %eax,%eax
8010a917:	74 74                	je     8010a98d <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a919:	83 ec 0c             	sub    $0xc,%esp
8010a91c:	68 82 d0 10 80       	push   $0x8010d082
8010a921:	e8 e6 5a ff ff       	call   8010040c <cprintf>
8010a926:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a929:	83 ec 0c             	sub    $0xc,%esp
8010a92c:	6a 00                	push   $0x0
8010a92e:	6a 10                	push   $0x10
8010a930:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a933:	50                   	push   %eax
8010a934:	ff 75 e8             	push   -0x18(%ebp)
8010a937:	ff 75 08             	push   0x8(%ebp)
8010a93a:	e8 2d 01 00 00       	call   8010aa6c <tcp_pkt_create>
8010a93f:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a942:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a945:	83 ec 08             	sub    $0x8,%esp
8010a948:	50                   	push   %eax
8010a949:	ff 75 e8             	push   -0x18(%ebp)
8010a94c:	e8 8a f0 ff ff       	call   801099db <i8254_send>
8010a951:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a954:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a957:	83 c0 36             	add    $0x36,%eax
8010a95a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a95d:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a960:	50                   	push   %eax
8010a961:	ff 75 e0             	push   -0x20(%ebp)
8010a964:	6a 00                	push   $0x0
8010a966:	6a 00                	push   $0x0
8010a968:	e8 66 04 00 00       	call   8010add3 <http_proc>
8010a96d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a970:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a973:	83 ec 0c             	sub    $0xc,%esp
8010a976:	50                   	push   %eax
8010a977:	6a 18                	push   $0x18
8010a979:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a97c:	50                   	push   %eax
8010a97d:	ff 75 e8             	push   -0x18(%ebp)
8010a980:	ff 75 08             	push   0x8(%ebp)
8010a983:	e8 e4 00 00 00       	call   8010aa6c <tcp_pkt_create>
8010a988:	83 c4 20             	add    $0x20,%esp
8010a98b:	eb 62                	jmp    8010a9ef <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a98d:	83 ec 0c             	sub    $0xc,%esp
8010a990:	6a 00                	push   $0x0
8010a992:	6a 10                	push   $0x10
8010a994:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a997:	50                   	push   %eax
8010a998:	ff 75 e8             	push   -0x18(%ebp)
8010a99b:	ff 75 08             	push   0x8(%ebp)
8010a99e:	e8 c9 00 00 00       	call   8010aa6c <tcp_pkt_create>
8010a9a3:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a9a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a9a9:	83 ec 08             	sub    $0x8,%esp
8010a9ac:	50                   	push   %eax
8010a9ad:	ff 75 e8             	push   -0x18(%ebp)
8010a9b0:	e8 26 f0 ff ff       	call   801099db <i8254_send>
8010a9b5:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a9b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a9bb:	83 c0 36             	add    $0x36,%eax
8010a9be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a9c1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a9c4:	50                   	push   %eax
8010a9c5:	ff 75 e4             	push   -0x1c(%ebp)
8010a9c8:	6a 00                	push   $0x0
8010a9ca:	6a 00                	push   $0x0
8010a9cc:	e8 02 04 00 00       	call   8010add3 <http_proc>
8010a9d1:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a9d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a9d7:	83 ec 0c             	sub    $0xc,%esp
8010a9da:	50                   	push   %eax
8010a9db:	6a 18                	push   $0x18
8010a9dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a9e0:	50                   	push   %eax
8010a9e1:	ff 75 e8             	push   -0x18(%ebp)
8010a9e4:	ff 75 08             	push   0x8(%ebp)
8010a9e7:	e8 80 00 00 00       	call   8010aa6c <tcp_pkt_create>
8010a9ec:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a9ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a9f2:	83 ec 08             	sub    $0x8,%esp
8010a9f5:	50                   	push   %eax
8010a9f6:	ff 75 e8             	push   -0x18(%ebp)
8010a9f9:	e8 dd ef ff ff       	call   801099db <i8254_send>
8010a9fe:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010aa01:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010aa06:	83 c0 01             	add    $0x1,%eax
8010aa09:	a3 64 e3 18 80       	mov    %eax,0x8018e364
8010aa0e:	eb 4a                	jmp    8010aa5a <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010aa10:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa13:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010aa17:	3c 10                	cmp    $0x10,%al
8010aa19:	75 3f                	jne    8010aa5a <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010aa1b:	a1 68 e3 18 80       	mov    0x8018e368,%eax
8010aa20:	83 f8 01             	cmp    $0x1,%eax
8010aa23:	75 35                	jne    8010aa5a <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010aa25:	83 ec 0c             	sub    $0xc,%esp
8010aa28:	6a 00                	push   $0x0
8010aa2a:	6a 01                	push   $0x1
8010aa2c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010aa2f:	50                   	push   %eax
8010aa30:	ff 75 e8             	push   -0x18(%ebp)
8010aa33:	ff 75 08             	push   0x8(%ebp)
8010aa36:	e8 31 00 00 00       	call   8010aa6c <tcp_pkt_create>
8010aa3b:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010aa3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010aa41:	83 ec 08             	sub    $0x8,%esp
8010aa44:	50                   	push   %eax
8010aa45:	ff 75 e8             	push   -0x18(%ebp)
8010aa48:	e8 8e ef ff ff       	call   801099db <i8254_send>
8010aa4d:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010aa50:	c7 05 68 e3 18 80 00 	movl   $0x0,0x8018e368
8010aa57:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010aa5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa5d:	83 ec 0c             	sub    $0xc,%esp
8010aa60:	50                   	push   %eax
8010aa61:	e8 8e 7d ff ff       	call   801027f4 <kfree>
8010aa66:	83 c4 10             	add    $0x10,%esp
}
8010aa69:	90                   	nop
8010aa6a:	c9                   	leave
8010aa6b:	c3                   	ret

8010aa6c <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010aa6c:	f3 0f 1e fb          	endbr32
8010aa70:	55                   	push   %ebp
8010aa71:	89 e5                	mov    %esp,%ebp
8010aa73:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010aa76:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010aa7c:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa7f:	83 c0 0e             	add    $0xe,%eax
8010aa82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010aa85:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa88:	0f b6 00             	movzbl (%eax),%eax
8010aa8b:	0f b6 c0             	movzbl %al,%eax
8010aa8e:	83 e0 0f             	and    $0xf,%eax
8010aa91:	c1 e0 02             	shl    $0x2,%eax
8010aa94:	89 c2                	mov    %eax,%edx
8010aa96:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa99:	01 d0                	add    %edx,%eax
8010aa9b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010aa9e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aaa1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010aaa4:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aaa7:	83 c0 0e             	add    $0xe,%eax
8010aaaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010aaad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aab0:	83 c0 14             	add    $0x14,%eax
8010aab3:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010aab6:	8b 45 18             	mov    0x18(%ebp),%eax
8010aab9:	8d 50 36             	lea    0x36(%eax),%edx
8010aabc:	8b 45 10             	mov    0x10(%ebp),%eax
8010aabf:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010aac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aac4:	8d 50 06             	lea    0x6(%eax),%edx
8010aac7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aaca:	83 ec 04             	sub    $0x4,%esp
8010aacd:	6a 06                	push   $0x6
8010aacf:	52                   	push   %edx
8010aad0:	50                   	push   %eax
8010aad1:	e8 f7 ab ff ff       	call   801056cd <memmove>
8010aad6:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010aad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aadc:	83 c0 06             	add    $0x6,%eax
8010aadf:	83 ec 04             	sub    $0x4,%esp
8010aae2:	6a 06                	push   $0x6
8010aae4:	68 88 e0 18 80       	push   $0x8018e088
8010aae9:	50                   	push   %eax
8010aaea:	e8 de ab ff ff       	call   801056cd <memmove>
8010aaef:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010aaf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aaf5:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010aaf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aafc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010ab00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab03:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010ab06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab09:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010ab0d:	8b 45 18             	mov    0x18(%ebp),%eax
8010ab10:	83 c0 28             	add    $0x28,%eax
8010ab13:	0f b7 c0             	movzwl %ax,%eax
8010ab16:	83 ec 0c             	sub    $0xc,%esp
8010ab19:	50                   	push   %eax
8010ab1a:	e8 6f f8 ff ff       	call   8010a38e <H2N_ushort>
8010ab1f:	83 c4 10             	add    $0x10,%esp
8010ab22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab25:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010ab29:	0f b7 15 60 e3 18 80 	movzwl 0x8018e360,%edx
8010ab30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab33:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010ab37:	0f b7 05 60 e3 18 80 	movzwl 0x8018e360,%eax
8010ab3e:	83 c0 01             	add    $0x1,%eax
8010ab41:	66 a3 60 e3 18 80    	mov    %ax,0x8018e360
  ipv4_send->fragment = H2N_ushort(0x0000);
8010ab47:	83 ec 0c             	sub    $0xc,%esp
8010ab4a:	6a 00                	push   $0x0
8010ab4c:	e8 3d f8 ff ff       	call   8010a38e <H2N_ushort>
8010ab51:	83 c4 10             	add    $0x10,%esp
8010ab54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010ab57:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010ab5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab5e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010ab62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab65:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010ab69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab6c:	83 c0 0c             	add    $0xc,%eax
8010ab6f:	83 ec 04             	sub    $0x4,%esp
8010ab72:	6a 04                	push   $0x4
8010ab74:	68 04 05 11 80       	push   $0x80110504
8010ab79:	50                   	push   %eax
8010ab7a:	e8 4e ab ff ff       	call   801056cd <memmove>
8010ab7f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010ab82:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ab85:	8d 50 0c             	lea    0xc(%eax),%edx
8010ab88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab8b:	83 c0 10             	add    $0x10,%eax
8010ab8e:	83 ec 04             	sub    $0x4,%esp
8010ab91:	6a 04                	push   $0x4
8010ab93:	52                   	push   %edx
8010ab94:	50                   	push   %eax
8010ab95:	e8 33 ab ff ff       	call   801056cd <memmove>
8010ab9a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010ab9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aba0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010aba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aba9:	83 ec 0c             	sub    $0xc,%esp
8010abac:	50                   	push   %eax
8010abad:	e8 ec f8 ff ff       	call   8010a49e <ipv4_chksum>
8010abb2:	83 c4 10             	add    $0x10,%esp
8010abb5:	0f b7 c0             	movzwl %ax,%eax
8010abb8:	83 ec 0c             	sub    $0xc,%esp
8010abbb:	50                   	push   %eax
8010abbc:	e8 cd f7 ff ff       	call   8010a38e <H2N_ushort>
8010abc1:	83 c4 10             	add    $0x10,%esp
8010abc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010abc7:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010abcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abce:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010abd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abd5:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010abd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abdb:	0f b7 10             	movzwl (%eax),%edx
8010abde:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abe1:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010abe5:	a1 64 e3 18 80       	mov    0x8018e364,%eax
8010abea:	83 ec 0c             	sub    $0xc,%esp
8010abed:	50                   	push   %eax
8010abee:	e8 c1 f7 ff ff       	call   8010a3b4 <H2N_uint>
8010abf3:	83 c4 10             	add    $0x10,%esp
8010abf6:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010abf9:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010abfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010abff:	8b 40 04             	mov    0x4(%eax),%eax
8010ac02:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010ac08:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac0b:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010ac0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac11:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010ac15:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac18:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010ac1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac1f:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010ac23:	8b 45 14             	mov    0x14(%ebp),%eax
8010ac26:	89 c2                	mov    %eax,%edx
8010ac28:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac2b:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010ac2e:	83 ec 0c             	sub    $0xc,%esp
8010ac31:	68 90 38 00 00       	push   $0x3890
8010ac36:	e8 53 f7 ff ff       	call   8010a38e <H2N_ushort>
8010ac3b:	83 c4 10             	add    $0x10,%esp
8010ac3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ac41:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010ac45:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac48:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010ac4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac51:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010ac57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ac5a:	83 ec 0c             	sub    $0xc,%esp
8010ac5d:	50                   	push   %eax
8010ac5e:	e8 1f 00 00 00       	call   8010ac82 <tcp_chksum>
8010ac63:	83 c4 10             	add    $0x10,%esp
8010ac66:	83 c0 08             	add    $0x8,%eax
8010ac69:	0f b7 c0             	movzwl %ax,%eax
8010ac6c:	83 ec 0c             	sub    $0xc,%esp
8010ac6f:	50                   	push   %eax
8010ac70:	e8 19 f7 ff ff       	call   8010a38e <H2N_ushort>
8010ac75:	83 c4 10             	add    $0x10,%esp
8010ac78:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ac7b:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010ac7f:	90                   	nop
8010ac80:	c9                   	leave
8010ac81:	c3                   	ret

8010ac82 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010ac82:	f3 0f 1e fb          	endbr32
8010ac86:	55                   	push   %ebp
8010ac87:	89 e5                	mov    %esp,%ebp
8010ac89:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010ac8c:	8b 45 08             	mov    0x8(%ebp),%eax
8010ac8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010ac92:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac95:	83 c0 14             	add    $0x14,%eax
8010ac98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010ac9b:	83 ec 04             	sub    $0x4,%esp
8010ac9e:	6a 04                	push   $0x4
8010aca0:	68 04 05 11 80       	push   $0x80110504
8010aca5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010aca8:	50                   	push   %eax
8010aca9:	e8 1f aa ff ff       	call   801056cd <memmove>
8010acae:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010acb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010acb4:	83 c0 0c             	add    $0xc,%eax
8010acb7:	83 ec 04             	sub    $0x4,%esp
8010acba:	6a 04                	push   $0x4
8010acbc:	50                   	push   %eax
8010acbd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010acc0:	83 c0 04             	add    $0x4,%eax
8010acc3:	50                   	push   %eax
8010acc4:	e8 04 aa ff ff       	call   801056cd <memmove>
8010acc9:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010accc:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010acd0:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010acd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010acd7:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010acdb:	0f b7 c0             	movzwl %ax,%eax
8010acde:	83 ec 0c             	sub    $0xc,%esp
8010ace1:	50                   	push   %eax
8010ace2:	e8 81 f6 ff ff       	call   8010a368 <N2H_ushort>
8010ace7:	83 c4 10             	add    $0x10,%esp
8010acea:	83 e8 14             	sub    $0x14,%eax
8010aced:	0f b7 c0             	movzwl %ax,%eax
8010acf0:	83 ec 0c             	sub    $0xc,%esp
8010acf3:	50                   	push   %eax
8010acf4:	e8 95 f6 ff ff       	call   8010a38e <H2N_ushort>
8010acf9:	83 c4 10             	add    $0x10,%esp
8010acfc:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010ad00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010ad07:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ad0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010ad0d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010ad14:	eb 33                	jmp    8010ad49 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ad16:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ad19:	01 c0                	add    %eax,%eax
8010ad1b:	89 c2                	mov    %eax,%edx
8010ad1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad20:	01 d0                	add    %edx,%eax
8010ad22:	0f b6 00             	movzbl (%eax),%eax
8010ad25:	0f b6 c0             	movzbl %al,%eax
8010ad28:	c1 e0 08             	shl    $0x8,%eax
8010ad2b:	89 c2                	mov    %eax,%edx
8010ad2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ad30:	01 c0                	add    %eax,%eax
8010ad32:	8d 48 01             	lea    0x1(%eax),%ecx
8010ad35:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad38:	01 c8                	add    %ecx,%eax
8010ad3a:	0f b6 00             	movzbl (%eax),%eax
8010ad3d:	0f b6 c0             	movzbl %al,%eax
8010ad40:	01 d0                	add    %edx,%eax
8010ad42:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010ad45:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ad49:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ad4d:	7e c7                	jle    8010ad16 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ad4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ad52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad55:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ad5c:	eb 33                	jmp    8010ad91 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ad5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad61:	01 c0                	add    %eax,%eax
8010ad63:	89 c2                	mov    %eax,%edx
8010ad65:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad68:	01 d0                	add    %edx,%eax
8010ad6a:	0f b6 00             	movzbl (%eax),%eax
8010ad6d:	0f b6 c0             	movzbl %al,%eax
8010ad70:	c1 e0 08             	shl    $0x8,%eax
8010ad73:	89 c2                	mov    %eax,%edx
8010ad75:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ad78:	01 c0                	add    %eax,%eax
8010ad7a:	8d 48 01             	lea    0x1(%eax),%ecx
8010ad7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ad80:	01 c8                	add    %ecx,%eax
8010ad82:	0f b6 00             	movzbl (%eax),%eax
8010ad85:	0f b6 c0             	movzbl %al,%eax
8010ad88:	01 d0                	add    %edx,%eax
8010ad8a:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ad8d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010ad91:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010ad95:	0f b7 c0             	movzwl %ax,%eax
8010ad98:	83 ec 0c             	sub    $0xc,%esp
8010ad9b:	50                   	push   %eax
8010ad9c:	e8 c7 f5 ff ff       	call   8010a368 <N2H_ushort>
8010ada1:	83 c4 10             	add    $0x10,%esp
8010ada4:	66 d1 e8             	shr    $1,%ax
8010ada7:	0f b7 c0             	movzwl %ax,%eax
8010adaa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010adad:	7c af                	jl     8010ad5e <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010adaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010adb2:	c1 e8 10             	shr    $0x10,%eax
8010adb5:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010adb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010adbb:	f7 d0                	not    %eax
}
8010adbd:	c9                   	leave
8010adbe:	c3                   	ret

8010adbf <tcp_fin>:

void tcp_fin(){
8010adbf:	f3 0f 1e fb          	endbr32
8010adc3:	55                   	push   %ebp
8010adc4:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010adc6:	c7 05 68 e3 18 80 01 	movl   $0x1,0x8018e368
8010adcd:	00 00 00 
}
8010add0:	90                   	nop
8010add1:	5d                   	pop    %ebp
8010add2:	c3                   	ret

8010add3 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010add3:	f3 0f 1e fb          	endbr32
8010add7:	55                   	push   %ebp
8010add8:	89 e5                	mov    %esp,%ebp
8010adda:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010addd:	8b 45 10             	mov    0x10(%ebp),%eax
8010ade0:	83 ec 04             	sub    $0x4,%esp
8010ade3:	6a 00                	push   $0x0
8010ade5:	68 8b d0 10 80       	push   $0x8010d08b
8010adea:	50                   	push   %eax
8010adeb:	e8 65 00 00 00       	call   8010ae55 <http_strcpy>
8010adf0:	83 c4 10             	add    $0x10,%esp
8010adf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010adf6:	8b 45 10             	mov    0x10(%ebp),%eax
8010adf9:	83 ec 04             	sub    $0x4,%esp
8010adfc:	ff 75 f4             	push   -0xc(%ebp)
8010adff:	68 9e d0 10 80       	push   $0x8010d09e
8010ae04:	50                   	push   %eax
8010ae05:	e8 4b 00 00 00       	call   8010ae55 <http_strcpy>
8010ae0a:	83 c4 10             	add    $0x10,%esp
8010ae0d:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010ae10:	8b 45 10             	mov    0x10(%ebp),%eax
8010ae13:	83 ec 04             	sub    $0x4,%esp
8010ae16:	ff 75 f4             	push   -0xc(%ebp)
8010ae19:	68 b9 d0 10 80       	push   $0x8010d0b9
8010ae1e:	50                   	push   %eax
8010ae1f:	e8 31 00 00 00       	call   8010ae55 <http_strcpy>
8010ae24:	83 c4 10             	add    $0x10,%esp
8010ae27:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ae2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ae2d:	83 e0 01             	and    $0x1,%eax
8010ae30:	85 c0                	test   %eax,%eax
8010ae32:	74 11                	je     8010ae45 <http_proc+0x72>
    char *payload = (char *)send;
8010ae34:	8b 45 10             	mov    0x10(%ebp),%eax
8010ae37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010ae3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ae3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ae40:	01 d0                	add    %edx,%eax
8010ae42:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010ae45:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ae48:	8b 45 14             	mov    0x14(%ebp),%eax
8010ae4b:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ae4d:	e8 6d ff ff ff       	call   8010adbf <tcp_fin>
}
8010ae52:	90                   	nop
8010ae53:	c9                   	leave
8010ae54:	c3                   	ret

8010ae55 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ae55:	f3 0f 1e fb          	endbr32
8010ae59:	55                   	push   %ebp
8010ae5a:	89 e5                	mov    %esp,%ebp
8010ae5c:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ae5f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ae66:	eb 20                	jmp    8010ae88 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ae68:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae6b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae6e:	01 d0                	add    %edx,%eax
8010ae70:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ae73:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae76:	01 ca                	add    %ecx,%edx
8010ae78:	89 d1                	mov    %edx,%ecx
8010ae7a:	8b 55 08             	mov    0x8(%ebp),%edx
8010ae7d:	01 ca                	add    %ecx,%edx
8010ae7f:	0f b6 00             	movzbl (%eax),%eax
8010ae82:	88 02                	mov    %al,(%edx)
    i++;
8010ae84:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010ae88:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ae8b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ae8e:	01 d0                	add    %edx,%eax
8010ae90:	0f b6 00             	movzbl (%eax),%eax
8010ae93:	84 c0                	test   %al,%al
8010ae95:	75 d1                	jne    8010ae68 <http_strcpy+0x13>
  }
  return i;
8010ae97:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010ae9a:	c9                   	leave
8010ae9b:	c3                   	ret

8010ae9c <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010ae9c:	f3 0f 1e fb          	endbr32
8010aea0:	55                   	push   %ebp
8010aea1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010aea3:	c7 05 70 e3 18 80 c2 	movl   $0x801105c2,0x8018e370
8010aeaa:	05 11 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010aead:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010aeb2:	c1 e8 09             	shr    $0x9,%eax
8010aeb5:	a3 6c e3 18 80       	mov    %eax,0x8018e36c
}
8010aeba:	90                   	nop
8010aebb:	5d                   	pop    %ebp
8010aebc:	c3                   	ret

8010aebd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010aebd:	f3 0f 1e fb          	endbr32
8010aec1:	55                   	push   %ebp
8010aec2:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010aec4:	90                   	nop
8010aec5:	5d                   	pop    %ebp
8010aec6:	c3                   	ret

8010aec7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010aec7:	f3 0f 1e fb          	endbr32
8010aecb:	55                   	push   %ebp
8010aecc:	89 e5                	mov    %esp,%ebp
8010aece:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010aed1:	8b 45 08             	mov    0x8(%ebp),%eax
8010aed4:	83 c0 0c             	add    $0xc,%eax
8010aed7:	83 ec 0c             	sub    $0xc,%esp
8010aeda:	50                   	push   %eax
8010aedb:	e8 fe a3 ff ff       	call   801052de <holdingsleep>
8010aee0:	83 c4 10             	add    $0x10,%esp
8010aee3:	85 c0                	test   %eax,%eax
8010aee5:	75 0d                	jne    8010aef4 <iderw+0x2d>
    panic("iderw: buf not locked");
8010aee7:	83 ec 0c             	sub    $0xc,%esp
8010aeea:	68 ca d0 10 80       	push   $0x8010d0ca
8010aeef:	e8 d1 56 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010aef4:	8b 45 08             	mov    0x8(%ebp),%eax
8010aef7:	8b 00                	mov    (%eax),%eax
8010aef9:	83 e0 06             	and    $0x6,%eax
8010aefc:	83 f8 02             	cmp    $0x2,%eax
8010aeff:	75 0d                	jne    8010af0e <iderw+0x47>
    panic("iderw: nothing to do");
8010af01:	83 ec 0c             	sub    $0xc,%esp
8010af04:	68 e0 d0 10 80       	push   $0x8010d0e0
8010af09:	e8 b7 56 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010af0e:	8b 45 08             	mov    0x8(%ebp),%eax
8010af11:	8b 40 04             	mov    0x4(%eax),%eax
8010af14:	83 f8 01             	cmp    $0x1,%eax
8010af17:	74 0d                	je     8010af26 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010af19:	83 ec 0c             	sub    $0xc,%esp
8010af1c:	68 f5 d0 10 80       	push   $0x8010d0f5
8010af21:	e8 9f 56 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010af26:	8b 45 08             	mov    0x8(%ebp),%eax
8010af29:	8b 40 08             	mov    0x8(%eax),%eax
8010af2c:	8b 15 6c e3 18 80    	mov    0x8018e36c,%edx
8010af32:	39 d0                	cmp    %edx,%eax
8010af34:	72 0d                	jb     8010af43 <iderw+0x7c>
    panic("iderw: block out of range");
8010af36:	83 ec 0c             	sub    $0xc,%esp
8010af39:	68 13 d1 10 80       	push   $0x8010d113
8010af3e:	e8 82 56 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010af43:	8b 15 70 e3 18 80    	mov    0x8018e370,%edx
8010af49:	8b 45 08             	mov    0x8(%ebp),%eax
8010af4c:	8b 40 08             	mov    0x8(%eax),%eax
8010af4f:	c1 e0 09             	shl    $0x9,%eax
8010af52:	01 d0                	add    %edx,%eax
8010af54:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010af57:	8b 45 08             	mov    0x8(%ebp),%eax
8010af5a:	8b 00                	mov    (%eax),%eax
8010af5c:	83 e0 04             	and    $0x4,%eax
8010af5f:	85 c0                	test   %eax,%eax
8010af61:	74 2b                	je     8010af8e <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010af63:	8b 45 08             	mov    0x8(%ebp),%eax
8010af66:	8b 00                	mov    (%eax),%eax
8010af68:	83 e0 fb             	and    $0xfffffffb,%eax
8010af6b:	89 c2                	mov    %eax,%edx
8010af6d:	8b 45 08             	mov    0x8(%ebp),%eax
8010af70:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010af72:	8b 45 08             	mov    0x8(%ebp),%eax
8010af75:	83 c0 5c             	add    $0x5c,%eax
8010af78:	83 ec 04             	sub    $0x4,%esp
8010af7b:	68 00 02 00 00       	push   $0x200
8010af80:	50                   	push   %eax
8010af81:	ff 75 f4             	push   -0xc(%ebp)
8010af84:	e8 44 a7 ff ff       	call   801056cd <memmove>
8010af89:	83 c4 10             	add    $0x10,%esp
8010af8c:	eb 1a                	jmp    8010afa8 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010af8e:	8b 45 08             	mov    0x8(%ebp),%eax
8010af91:	83 c0 5c             	add    $0x5c,%eax
8010af94:	83 ec 04             	sub    $0x4,%esp
8010af97:	68 00 02 00 00       	push   $0x200
8010af9c:	ff 75 f4             	push   -0xc(%ebp)
8010af9f:	50                   	push   %eax
8010afa0:	e8 28 a7 ff ff       	call   801056cd <memmove>
8010afa5:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010afa8:	8b 45 08             	mov    0x8(%ebp),%eax
8010afab:	8b 00                	mov    (%eax),%eax
8010afad:	83 c8 02             	or     $0x2,%eax
8010afb0:	89 c2                	mov    %eax,%edx
8010afb2:	8b 45 08             	mov    0x8(%ebp),%eax
8010afb5:	89 10                	mov    %edx,(%eax)
}
8010afb7:	90                   	nop
8010afb8:	c9                   	leave
8010afb9:	c3                   	ret
