
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
8010005a:	bc 80 e3 18 80       	mov    $0x8018e380,%esp
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
80100073:	68 00 af 10 80       	push   $0x8010af00
80100078:	68 80 e3 18 80       	push   $0x8018e380
8010007d:	e8 59 52 00 00       	call   801052db <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 cc 2a 19 80 7c 	movl   $0x80192a7c,0x80192acc
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 d0 2a 19 80 7c 	movl   $0x80192a7c,0x80192ad0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 b4 e3 18 80 	movl   $0x8018e3b4,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 d0 2a 19 80    	mov    0x80192ad0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 7c 2a 19 80 	movl   $0x80192a7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 07 af 10 80       	push   $0x8010af07
801000c6:	50                   	push   %eax
801000c7:	e8 a2 50 00 00       	call   8010516e <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 d0 2a 19 80       	mov    0x80192ad0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 d0 2a 19 80       	mov    %eax,0x80192ad0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 7c 2a 19 80       	mov    $0x80192a7c,%eax
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
80100104:	68 80 e3 18 80       	push   $0x8018e380
80100109:	e8 f3 51 00 00       	call   80105301 <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 d0 2a 19 80       	mov    0x80192ad0,%eax
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
80100143:	68 80 e3 18 80       	push   $0x8018e380
80100148:	e8 26 52 00 00       	call   80105373 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 4f 50 00 00       	call   801051ae <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 7c 2a 19 80 	cmpl   $0x80192a7c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 cc 2a 19 80       	mov    0x80192acc,%eax
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
801001c4:	68 80 e3 18 80       	push   $0x8018e380
801001c9:	e8 a5 51 00 00       	call   80105373 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 ce 4f 00 00       	call   801051ae <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 7c 2a 19 80 	cmpl   $0x80192a7c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 0e af 10 80       	push   $0x8010af0e
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
80100239:	e8 ba ab 00 00       	call   8010adf8 <iderw>
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
8010025a:	e8 09 50 00 00       	call   80105268 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 1f af 10 80       	push   $0x8010af1f
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
80100288:	e8 6b ab 00 00       	call   8010adf8 <iderw>
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
801002a7:	e8 bc 4f 00 00       	call   80105268 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 26 af 10 80       	push   $0x8010af26
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 47 4f 00 00       	call   80105216 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 80 e3 18 80       	push   $0x8018e380
801002da:	e8 22 50 00 00       	call   80105301 <acquire>
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
80100319:	8b 15 d0 2a 19 80    	mov    0x80192ad0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 7c 2a 19 80 	movl   $0x80192a7c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 d0 2a 19 80       	mov    0x80192ad0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 d0 2a 19 80       	mov    %eax,0x80192ad0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 80 e3 18 80       	push   $0x8018e380
8010034a:	e8 24 50 00 00       	call   80105373 <release>
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
8010042c:	e8 d0 4e 00 00       	call   80105301 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 2d af 10 80       	push   $0x8010af2d
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
8010052c:	c7 45 ec 36 af 10 80 	movl   $0x8010af36,-0x14(%ebp)
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
801005ba:	e8 b4 4d 00 00       	call   80105373 <release>
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
801005e7:	68 3d af 10 80       	push   $0x8010af3d
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
80100606:	68 51 af 10 80       	push   $0x8010af51
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 a6 4d 00 00       	call   801053c9 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 53 af 10 80       	push   $0x8010af53
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
801006c4:	e8 c3 85 00 00       	call   80108c8c <graphic_scroll_up>
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
80100717:	e8 70 85 00 00       	call   80108c8c <graphic_scroll_up>
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
8010077d:	e8 7e 85 00 00       	call   80108d00 <font_render>
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
801007bd:	e8 df 68 00 00       	call   801070a1 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 d2 68 00 00       	call   801070a1 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 c5 68 00 00       	call   801070a1 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 b5 68 00 00       	call   801070a1 <uartputc>
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
80100819:	e8 e3 4a 00 00       	call   80105301 <acquire>
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
80100866:	a1 68 2d 19 80       	mov    0x80192d68,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 68 2d 19 80       	mov    %eax,0x80192d68
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 68 2d 19 80    	mov    0x80192d68,%edx
80100889:	a1 64 2d 19 80       	mov    0x80192d64,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 68 2d 19 80       	mov    0x80192d68,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 e0 2c 19 80 	movzbl -0x7fe6d320(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 68 2d 19 80    	mov    0x80192d68,%edx
801008b7:	a1 64 2d 19 80       	mov    0x80192d64,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 68 2d 19 80       	mov    0x80192d68,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 68 2d 19 80       	mov    %eax,0x80192d68
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
801008f0:	8b 15 68 2d 19 80    	mov    0x80192d68,%edx
801008f6:	a1 60 2d 19 80       	mov    0x80192d60,%eax
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
80100917:	a1 68 2d 19 80       	mov    0x80192d68,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 68 2d 19 80    	mov    %edx,0x80192d68
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 e0 2c 19 80    	mov    %dl,-0x7fe6d320(%eax)
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
8010094b:	a1 68 2d 19 80       	mov    0x80192d68,%eax
80100950:	8b 15 60 2d 19 80    	mov    0x80192d60,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 68 2d 19 80       	mov    0x80192d68,%eax
80100962:	a3 64 2d 19 80       	mov    %eax,0x80192d64
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 60 2d 19 80       	push   $0x80192d60
8010096f:	e8 08 3e 00 00       	call   8010477c <wakeup>
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
80100992:	e8 dc 49 00 00       	call   80105373 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 9a 3e 00 00       	call   8010483f <procdump>
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
801009ce:	e8 2e 49 00 00       	call   80105301 <acquire>
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
801009ef:	e8 7f 49 00 00       	call   80105373 <release>
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
80100a17:	68 60 2d 19 80       	push   $0x80192d60
80100a1c:	e8 5c 3c 00 00       	call   8010467d <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 60 2d 19 80    	mov    0x80192d60,%edx
80100a2a:	a1 64 2d 19 80       	mov    0x80192d64,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 60 2d 19 80       	mov    0x80192d60,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 60 2d 19 80    	mov    %edx,0x80192d60
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 e0 2c 19 80 	movzbl -0x7fe6d320(%eax),%eax
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
80100a5f:	a1 60 2d 19 80       	mov    0x80192d60,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 60 2d 19 80       	mov    %eax,0x80192d60
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
80100a9a:	e8 d4 48 00 00       	call   80105373 <release>
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
80100adc:	e8 20 48 00 00       	call   80105301 <acquire>
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
80100b1e:	e8 50 48 00 00       	call   80105373 <release>
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
80100b50:	68 57 af 10 80       	push   $0x8010af57
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 7c 47 00 00       	call   801052db <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 2c 37 19 80 bc 	movl   $0x80100abc,0x8019372c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 28 37 19 80 a8 	movl   $0x801009a8,0x80193728
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 5f af 10 80 	movl   $0x8010af5f,-0xc(%ebp)
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
80100bf7:	68 75 af 10 80       	push   $0x8010af75
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
80100c53:	e8 5d 74 00 00       	call   801080b5 <setupkvm>
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
80100cf9:	e8 c9 77 00 00       	call   801084c7 <allocuvm>
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
80100d3f:	e8 b2 76 00 00       	call   801083f6 <loaduvm>
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
80100dae:	e8 14 77 00 00       	call   801084c7 <allocuvm>
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
80100dd2:	e8 5e 79 00 00       	call   80108735 <clearpteu>
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
80100e0b:	e8 e9 49 00 00       	call   801057f9 <strlen>
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
80100e38:	e8 bc 49 00 00       	call   801057f9 <strlen>
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
80100e5e:	e8 7d 7a 00 00       	call   801088e0 <copyout>
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
80100efa:	e8 e1 79 00 00       	call   801088e0 <copyout>
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
80100f48:	e8 5e 48 00 00       	call   801057ab <safestrcpy>
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
80100f8b:	e8 4f 72 00 00       	call   801081df <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 fa 76 00 00       	call   80108698 <freevm>
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
80100fd9:	e8 ba 76 00 00       	call   80108698 <freevm>
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
8010100e:	68 81 af 10 80       	push   $0x8010af81
80101013:	68 80 2d 19 80       	push   $0x80192d80
80101018:	e8 be 42 00 00       	call   801052db <initlock>
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
80101030:	68 80 2d 19 80       	push   $0x80192d80
80101035:	e8 c7 42 00 00       	call   80105301 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 b4 2d 19 80 	movl   $0x80192db4,-0xc(%ebp)
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
8010105d:	68 80 2d 19 80       	push   $0x80192d80
80101062:	e8 0c 43 00 00       	call   80105373 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 14 37 19 80       	mov    $0x80193714,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 80 2d 19 80       	push   $0x80192d80
80101085:	e8 e9 42 00 00       	call   80105373 <release>
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
801010a1:	68 80 2d 19 80       	push   $0x80192d80
801010a6:	e8 56 42 00 00       	call   80105301 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 88 af 10 80       	push   $0x8010af88
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 80 2d 19 80       	push   $0x80192d80
801010dc:	e8 92 42 00 00       	call   80105373 <release>
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
801010f6:	68 80 2d 19 80       	push   $0x80192d80
801010fb:	e8 01 42 00 00       	call   80105301 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 90 af 10 80       	push   $0x8010af90
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
80101136:	68 80 2d 19 80       	push   $0x80192d80
8010113b:	e8 33 42 00 00       	call   80105373 <release>
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
80101184:	68 80 2d 19 80       	push   $0x80192d80
80101189:	e8 e5 41 00 00       	call   80105373 <release>
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
801012e0:	68 9a af 10 80       	push   $0x8010af9a
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
801013e7:	68 a3 af 10 80       	push   $0x8010afa3
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
8010141d:	68 b3 af 10 80       	push   $0x8010afb3
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
80101459:	e8 f9 41 00 00       	call   80105657 <memmove>
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
801014a3:	e8 e8 40 00 00       	call   80105590 <memset>
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
801014fa:	a1 98 37 19 80       	mov    0x80193798,%eax
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
801015d8:	a1 80 37 19 80       	mov    0x80193780,%eax
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
801015fa:	8b 15 80 37 19 80    	mov    0x80193780,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 c0 af 10 80       	push   $0x8010afc0
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
80101627:	68 80 37 19 80       	push   $0x80193780
8010162c:	ff 75 08             	push   0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 98 37 19 80       	mov    0x80193798,%eax
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
801016a5:	68 d6 af 10 80       	push   $0x8010afd6
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
8010170d:	68 e9 af 10 80       	push   $0x8010afe9
80101712:	68 a0 37 19 80       	push   $0x801937a0
80101717:	e8 bf 3b 00 00       	call   801052db <initlock>
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
80101738:	05 a0 37 19 80       	add    $0x801937a0,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 f0 af 10 80       	push   $0x8010aff0
80101748:	50                   	push   %eax
80101749:	e8 20 3a 00 00       	call   8010516e <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 80 37 19 80       	push   $0x80193780
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 98 37 19 80       	mov    0x80193798,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 94 37 19 80    	mov    0x80193794,%edi
8010177c:	8b 35 90 37 19 80    	mov    0x80193790,%esi
80101782:	8b 1d 8c 37 19 80    	mov    0x8019378c,%ebx
80101788:	8b 0d 88 37 19 80    	mov    0x80193788,%ecx
8010178e:	8b 15 84 37 19 80    	mov    0x80193784,%edx
80101794:	a1 80 37 19 80       	mov    0x80193780,%eax
80101799:	ff 75 d4             	push   -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 f8 af 10 80       	push   $0x8010aff8
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
801017dd:	a1 94 37 19 80       	mov    0x80193794,%eax
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
8010181f:	e8 6c 3d 00 00       	call   80105590 <memset>
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
80101873:	8b 15 88 37 19 80    	mov    0x80193788,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 4b b0 10 80       	push   $0x8010b04b
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
801018a8:	a1 94 37 19 80       	mov    0x80193794,%eax
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
80101931:	e8 21 3d 00 00       	call   80105657 <memmove>
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
80101965:	68 a0 37 19 80       	push   $0x801937a0
8010196a:	e8 92 39 00 00       	call   80105301 <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 d4 37 19 80 	movl   $0x801937d4,-0xc(%ebp)
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
801019b3:	68 a0 37 19 80       	push   $0x801937a0
801019b8:	e8 b6 39 00 00       	call   80105373 <release>
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
801019e2:	81 7d f4 f4 53 19 80 	cmpl   $0x801953f4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 5d b0 10 80       	push   $0x8010b05d
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
80101a2c:	68 a0 37 19 80       	push   $0x801937a0
80101a31:	e8 3d 39 00 00       	call   80105373 <release>
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
80101a4b:	68 a0 37 19 80       	push   $0x801937a0
80101a50:	e8 ac 38 00 00       	call   80105301 <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 a0 37 19 80       	push   $0x801937a0
80101a6f:	e8 ff 38 00 00       	call   80105373 <release>
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
80101a99:	68 6d b0 10 80       	push   $0x8010b06d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 fc 36 00 00       	call   801051ae <acquiresleep>
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
80101ace:	a1 94 37 19 80       	mov    0x80193794,%eax
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
80101b57:	e8 fb 3a 00 00       	call   80105657 <memmove>
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
80101b86:	68 73 b0 10 80       	push   $0x8010b073
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
80101bad:	e8 b6 36 00 00       	call   80105268 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 82 b0 10 80       	push   $0x8010b082
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 37 36 00 00       	call   80105216 <releasesleep>
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
80101bf9:	e8 b0 35 00 00       	call   801051ae <acquiresleep>
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
80101c1a:	68 a0 37 19 80       	push   $0x801937a0
80101c1f:	e8 dd 36 00 00       	call   80105301 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 a0 37 19 80       	push   $0x801937a0
80101c38:	e8 36 37 00 00       	call   80105373 <release>
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
80101c7f:	e8 92 35 00 00       	call   80105216 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 a0 37 19 80       	push   $0x801937a0
80101c8f:	e8 6d 36 00 00       	call   80105301 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 a0 37 19 80       	push   $0x801937a0
80101cae:	e8 c0 36 00 00       	call   80105373 <release>
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
80101dfa:	68 8a b0 10 80       	push   $0x8010b08a
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
80101fbc:	8b 04 c5 20 37 19 80 	mov    -0x7fe6c8e0(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl
80101fd9:	8b 04 c5 20 37 19 80 	mov    -0x7fe6c8e0(,%eax,8),%eax
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
801020a4:	e8 ae 35 00 00       	call   80105657 <memmove>
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
80102115:	8b 04 c5 24 37 19 80 	mov    -0x7fe6c8dc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl
80102132:	8b 04 c5 24 37 19 80 	mov    -0x7fe6c8dc(,%eax,8),%eax
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
801021f8:	e8 5a 34 00 00       	call   80105657 <memmove>
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
8010227c:	e8 74 34 00 00       	call   801056f5 <strncmp>
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
801022a0:	68 9d b0 10 80       	push   $0x8010b09d
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
801022cf:	68 af b0 10 80       	push   $0x8010b0af
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
801023a8:	68 be b0 10 80       	push   $0x8010b0be
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
801023e3:	e8 67 33 00 00       	call   8010574f <strncpy>
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
8010240f:	68 cb b0 10 80       	push   $0x8010b0cb
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
80102485:	e8 cd 31 00 00       	call   80105657 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	push   -0xc(%ebp)
80102499:	ff 75 0c             	push   0xc(%ebp)
8010249c:	e8 b6 31 00 00       	call   80105657 <memmove>
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
8010262d:	a1 f4 53 19 80       	mov    0x801953f4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 f4 53 19 80       	mov    0x801953f4,%eax
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
80102648:	a1 f4 53 19 80       	mov    0x801953f4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 f4 53 19 80       	mov    0x801953f4,%eax
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
8010266a:	c7 05 f4 53 19 80 00 	movl   $0xfec00000,0x801953f4
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
80102699:	0f b6 05 c0 8c 19 80 	movzbl 0x80198cc0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 d4 b0 10 80       	push   $0x8010b0d4
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
8010275a:	68 06 b1 10 80       	push   $0x8010b106
8010275f:	68 00 54 19 80       	push   $0x80195400
80102764:	e8 72 2b 00 00       	call   801052db <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 34 54 19 80 00 	movl   $0x0,0x80195434
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
801027a5:	c7 05 34 54 19 80 01 	movl   $0x1,0x80195434
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
80102825:	68 0b b1 10 80       	push   $0x8010b10b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	push   0x8(%ebp)
8010283c:	e8 4f 2d 00 00       	call   80105590 <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 34 54 19 80       	mov    0x80195434,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 00 54 19 80       	push   $0x80195400
80102855:	e8 a7 2a 00 00       	call   80105301 <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 38 54 19 80    	mov    0x80195438,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 38 54 19 80       	mov    %eax,0x80195438
  if(kmem.use_lock)
80102876:	a1 34 54 19 80       	mov    0x80195434,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 00 54 19 80       	push   $0x80195400
80102887:	e8 e7 2a 00 00       	call   80105373 <release>
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
8010289c:	a1 34 54 19 80       	mov    0x80195434,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 00 54 19 80       	push   $0x80195400
801028ad:	e8 4f 2a 00 00       	call   80105301 <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 38 54 19 80       	mov    0x80195438,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 38 54 19 80       	mov    %eax,0x80195438
  if(kmem.use_lock)
801028cd:	a1 34 54 19 80       	mov    0x80195434,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 00 54 19 80       	push   $0x80195400
801028de:	e8 90 2a 00 00       	call   80105373 <release>
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
80102abd:	a1 3c 54 19 80       	mov    0x8019543c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102ae3:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102b56:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102bd9:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102c06:	a1 3c 54 19 80       	mov    0x8019543c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102c2c:	a1 3c 54 19 80       	mov    0x8019543c,%eax
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
80102e33:	e8 c3 27 00 00       	call   801055fb <memcmp>
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
80102f4b:	68 11 b1 10 80       	push   $0x8010b111
80102f50:	68 40 54 19 80       	push   $0x80195440
80102f55:	e8 81 23 00 00       	call   801052db <initlock>
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
80102f72:	a3 74 54 19 80       	mov    %eax,0x80195474
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 78 54 19 80       	mov    %eax,0x80195478
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 84 54 19 80       	mov    %eax,0x80195484
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
80102fa5:	8b 15 74 54 19 80    	mov    0x80195474,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 84 54 19 80       	mov    0x80195484,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 4c 54 19 80 	mov    -0x7fe6abb4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 84 54 19 80       	mov    0x80195484,%eax
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
80103004:	e8 4e 26 00 00       	call   80105657 <memmove>
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
8010303a:	a1 88 54 19 80       	mov    0x80195488,%eax
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
80103056:	a1 74 54 19 80       	mov    0x80195474,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 84 54 19 80       	mov    0x80195484,%eax
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
80103080:	a3 88 54 19 80       	mov    %eax,0x80195488
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 4c 54 19 80 	mov    %eax,-0x7fe6abb4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 88 54 19 80       	mov    0x80195488,%eax
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
801030ce:	a1 74 54 19 80       	mov    0x80195474,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 84 54 19 80       	mov    0x80195484,%eax
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
801030f3:	8b 15 88 54 19 80    	mov    0x80195488,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 4c 54 19 80 	mov    -0x7fe6abb4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 88 54 19 80       	mov    0x80195488,%eax
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
8010315f:	c7 05 88 54 19 80 00 	movl   $0x0,0x80195488
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
8010317e:	68 40 54 19 80       	push   $0x80195440
80103183:	e8 79 21 00 00       	call   80105301 <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 80 54 19 80       	mov    0x80195480,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 40 54 19 80       	push   $0x80195440
8010319c:	68 40 54 19 80       	push   $0x80195440
801031a1:	e8 d7 14 00 00       	call   8010467d <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 88 54 19 80    	mov    0x80195488,%ecx
801031b1:	a1 7c 54 19 80       	mov    0x8019547c,%eax
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
801031cc:	68 40 54 19 80       	push   $0x80195440
801031d1:	68 40 54 19 80       	push   $0x80195440
801031d6:	e8 a2 14 00 00       	call   8010467d <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 7c 54 19 80       	mov    0x8019547c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 7c 54 19 80       	mov    %eax,0x8019547c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 40 54 19 80       	push   $0x80195440
801031f5:	e8 79 21 00 00       	call   80105373 <release>
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
80103215:	68 40 54 19 80       	push   $0x80195440
8010321a:	e8 e2 20 00 00       	call   80105301 <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 7c 54 19 80       	mov    0x8019547c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 7c 54 19 80       	mov    %eax,0x8019547c
  if(log.committing)
8010322f:	a1 80 54 19 80       	mov    0x80195480,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 15 b1 10 80       	push   $0x8010b115
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 7c 54 19 80       	mov    0x8019547c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 80 54 19 80 01 	movl   $0x1,0x80195480
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 40 54 19 80       	push   $0x80195440
80103269:	e8 0e 15 00 00       	call   8010477c <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 40 54 19 80       	push   $0x80195440
80103279:	e8 f5 20 00 00       	call   80105373 <release>
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
8010328f:	68 40 54 19 80       	push   $0x80195440
80103294:	e8 68 20 00 00       	call   80105301 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 80 54 19 80 00 	movl   $0x0,0x80195480
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 40 54 19 80       	push   $0x80195440
801032ae:	e8 c9 14 00 00       	call   8010477c <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 40 54 19 80       	push   $0x80195440
801032be:	e8 b0 20 00 00       	call   80105373 <release>
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
801032df:	8b 15 74 54 19 80    	mov    0x80195474,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 84 54 19 80       	mov    0x80195484,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 4c 54 19 80 	mov    -0x7fe6abb4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 84 54 19 80       	mov    0x80195484,%eax
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
8010333e:	e8 14 23 00 00       	call   80105657 <memmove>
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
80103374:	a1 88 54 19 80       	mov    0x80195488,%eax
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
80103390:	a1 88 54 19 80       	mov    0x80195488,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 88 54 19 80 00 	movl   $0x0,0x80195488
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
801033c4:	a1 88 54 19 80       	mov    0x80195488,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 88 54 19 80       	mov    0x80195488,%eax
801033d3:	8b 15 78 54 19 80    	mov    0x80195478,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 24 b1 10 80       	push   $0x8010b124
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 7c 54 19 80       	mov    0x8019547c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 3a b1 10 80       	push   $0x8010b13a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 40 54 19 80       	push   $0x80195440
8010340b:	e8 f1 1e 00 00       	call   80105301 <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 4c 54 19 80 	mov    -0x7fe6abb4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 88 54 19 80       	mov    0x80195488,%eax
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
80103454:	89 14 85 4c 54 19 80 	mov    %edx,-0x7fe6abb4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 88 54 19 80       	mov    0x80195488,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 88 54 19 80       	mov    0x80195488,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 88 54 19 80       	mov    %eax,0x80195488
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 40 54 19 80       	push   $0x80195440
80103489:	e8 e5 1e 00 00       	call   80105373 <release>
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
801034c3:	e8 00 57 00 00       	call   80108bc8 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 c4 4c 00 00       	call   801081a6 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 9b 54 00 00       	call   80108982 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 3c 47 00 00       	call   80107c2d <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 b1 3a 00 00       	call   80106fb6 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 9b 35 00 00       	call   80106aaa <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 af 78 00 00       	call   8010adcd <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 fe 58 00 00       	call   80108e3b <pci_init>
  arp_scan();
8010353d:	e8 77 66 00 00       	call   80109bb9 <arp_scan>
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
80103556:	e8 67 4c 00 00       	call   801081c2 <switchkvm>
  seginit();
8010355b:	e8 cd 46 00 00       	call   80107c2d <seginit>
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
80103586:	68 55 b1 10 80       	push   $0x8010b155
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 8c 36 00 00       	call   80106c24 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 5d 0e 00 00       	call   80104412 <scheduler>

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
801035cf:	68 38 f5 10 80       	push   $0x8010f538
801035d4:	ff 75 f0             	push   -0x10(%ebp)
801035d7:	e8 7b 20 00 00       	call   80105657 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 e0 8c 19 80 	movl   $0x80198ce0,-0xc(%ebp)
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
8010365a:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
80103661:	a1 94 8d 19 80       	mov    0x80198d94,%eax
80103666:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010366c:	05 e0 8c 19 80       	add    $0x80198ce0,%eax
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
80103768:	68 69 b1 10 80       	push   $0x8010b169
8010376d:	50                   	push   %eax
8010376e:	e8 68 1b 00 00       	call   801052db <initlock>
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
80103831:	e8 cb 1a 00 00       	call   80105301 <acquire>
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
80103858:	e8 1f 0f 00 00       	call   8010477c <wakeup>
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
8010387b:	e8 fc 0e 00 00       	call   8010477c <wakeup>
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
801038a4:	e8 ca 1a 00 00       	call   80105373 <release>
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
801038c3:	e8 ab 1a 00 00       	call   80105373 <release>
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
801038e1:	e8 1b 1a 00 00       	call   80105301 <acquire>
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
80103915:	e8 59 1a 00 00       	call   80105373 <release>
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
80103933:	e8 44 0e 00 00       	call   8010477c <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 2c 0d 00 00       	call   8010467d <sleep>
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
801039b6:	e8 c1 0d 00 00       	call   8010477c <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 a9 19 00 00       	call   80105373 <release>
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
801039e6:	e8 16 19 00 00       	call   80105301 <acquire>
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
80103a03:	e8 6b 19 00 00       	call   80105373 <release>
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
80103a26:	e8 52 0c 00 00       	call   8010467d <sleep>
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
80103ab9:	e8 be 0c 00 00       	call   8010477c <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 a6 18 00 00       	call   80105373 <release>
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
80103af9:	68 70 b1 10 80       	push   $0x8010b170
80103afe:	68 20 65 19 80       	push   $0x80196520
80103b03:	e8 d3 17 00 00       	call   801052db <initlock>
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
80103b1d:	2d e0 8c 19 80       	sub    $0x80198ce0,%eax
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
80103b48:	68 78 b1 10 80       	push   $0x8010b178
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
80103b6c:	05 e0 8c 19 80       	add    $0x80198ce0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103b85:	05 e0 8c 19 80       	add    $0x80198ce0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 94 8d 19 80       	mov    0x80198d94,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 9e b1 10 80       	push   $0x8010b19e
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
80103bb3:	e8 c5 18 00 00       	call   8010547d <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 fd 18 00 00       	call   801054ce <popcli>
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
80103be3:	68 20 65 19 80       	push   $0x80196520
80103be8:	e8 14 17 00 00       	call   80105301 <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
80103bf7:	eb 0e                	jmp    80103c07 <allocproc+0x31>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 27                	je     80103c2a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103c07:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 20 65 19 80       	push   $0x80196520
80103c18:	e8 56 17 00 00       	call   80105373 <release>
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
80103c39:	8b 15 00 f0 10 80    	mov    0x8010f000,%edx
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	89 50 10             	mov    %edx,0x10(%eax)
  nextpid++;
80103c45:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c4a:	83 c0 01             	add    $0x1,%eax
80103c4d:	a3 00 f0 10 80       	mov    %eax,0x8010f000

  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
80103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c55:	2d 54 65 19 80       	sub    $0x80196554,%eax
80103c5a:	c1 f8 02             	sar    $0x2,%eax
80103c5d:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  kernel_pstat.inuse[i] = 1;
80103c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c69:	c7 04 85 20 59 19 80 	movl   $0x1,-0x7fe6a6e0(,%eax,4)
80103c70:	01 00 00 00 
  kernel_pstat.pid[i] = p->pid;
80103c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c77:	8b 40 10             	mov    0x10(%eax),%eax
80103c7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c7d:	83 c2 40             	add    $0x40,%edx
80103c80:	89 04 95 20 59 19 80 	mov    %eax,-0x7fe6a6e0(,%edx,4)
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
80103c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8a:	83 e8 80             	sub    $0xffffff80,%eax
80103c8d:	c7 04 85 20 59 19 80 	movl   $0x3,-0x7fe6a6e0(,%eax,4)
80103c94:	03 00 00 00 
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
80103c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9b:	83 c0 40             	add    $0x40,%eax
80103c9e:	c1 e0 04             	shl    $0x4,%eax
80103ca1:	05 20 59 19 80       	add    $0x80195920,%eax
80103ca6:	83 ec 04             	sub    $0x4,%esp
80103ca9:	6a 10                	push   $0x10
80103cab:	6a 00                	push   $0x0
80103cad:	50                   	push   %eax
80103cae:	e8 dd 18 00 00       	call   80105590 <memset>
80103cb3:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));
80103cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb9:	83 e8 80             	sub    $0xffffff80,%eax
80103cbc:	c1 e0 04             	shl    $0x4,%eax
80103cbf:	05 20 59 19 80       	add    $0x80195920,%eax
80103cc4:	83 ec 04             	sub    $0x4,%esp
80103cc7:	6a 10                	push   $0x10
80103cc9:	6a 00                	push   $0x0
80103ccb:	50                   	push   %eax
80103ccc:	e8 bf 18 00 00       	call   80105590 <memset>
80103cd1:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103cd4:	83 ec 0c             	sub    $0xc,%esp
80103cd7:	68 20 65 19 80       	push   $0x80196520
80103cdc:	e8 92 16 00 00       	call   80105373 <release>
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
80103d03:	68 b0 b1 10 80       	push   $0x8010b1b0
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
80103d40:	ba 64 6a 10 80       	mov    $0x80106a64,%edx
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
80103d65:	e8 26 18 00 00       	call   80105590 <memset>
80103d6a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d70:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d73:	ba 33 46 10 80       	mov    $0x80104633,%edx
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
80103d95:	a3 7c d0 18 80       	mov    %eax,0x8018d07c
  if((p->pgdir = setupkvm()) == 0){
80103d9a:	e8 16 43 00 00       	call   801080b5 <setupkvm>
80103d9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103da2:	89 42 04             	mov    %eax,0x4(%edx)
80103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da8:	8b 40 04             	mov    0x4(%eax),%eax
80103dab:	85 c0                	test   %eax,%eax
80103dad:	75 0d                	jne    80103dbc <userinit+0x3c>
    panic("userinit: out of memory?");
80103daf:	83 ec 0c             	sub    $0xc,%esp
80103db2:	68 de b1 10 80       	push   $0x8010b1de
80103db7:	e8 09 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103dbc:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	8b 40 04             	mov    0x4(%eax),%eax
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	52                   	push   %edx
80103dcb:	68 0c f5 10 80       	push   $0x8010f50c
80103dd0:	50                   	push   %eax
80103dd1:	e8 ac 45 00 00       	call   80108382 <inituvm>
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
80103df0:	e8 9b 17 00 00       	call   80105590 <memset>
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
80103e6a:	68 f7 b1 10 80       	push   $0x8010b1f7
80103e6f:	50                   	push   %eax
80103e70:	e8 36 19 00 00       	call   801057ab <safestrcpy>
80103e75:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e78:	83 ec 0c             	sub    $0xc,%esp
80103e7b:	68 00 b2 10 80       	push   $0x8010b200
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
80103e91:	68 20 65 19 80       	push   $0x80196520
80103e96:	e8 66 14 00 00       	call   80105301 <acquire>
80103e9b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80103ea8:	83 ec 0c             	sub    $0xc,%esp
80103eab:	68 20 65 19 80       	push   $0x80196520
80103eb0:	e8 be 14 00 00       	call   80105373 <release>
80103eb5:	83 c4 10             	add    $0x10,%esp
}
80103eb8:	90                   	nop
80103eb9:	c9                   	leave
80103eba:	c3                   	ret

80103ebb <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ebb:	f3 0f 1e fb          	endbr32
80103ebf:	55                   	push   %ebp
80103ec0:	89 e5                	mov    %esp,%ebp
80103ec2:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ec5:	e8 df fc ff ff       	call   80103ba9 <myproc>
80103eca:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ed0:	8b 00                	mov    (%eax),%eax
80103ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ed5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ed9:	7e 2e                	jle    80103f09 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103edb:	8b 55 08             	mov    0x8(%ebp),%edx
80103ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee1:	01 c2                	add    %eax,%edx
80103ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee6:	8b 40 04             	mov    0x4(%eax),%eax
80103ee9:	83 ec 04             	sub    $0x4,%esp
80103eec:	52                   	push   %edx
80103eed:	ff 75 f4             	push   -0xc(%ebp)
80103ef0:	50                   	push   %eax
80103ef1:	e8 d1 45 00 00       	call   801084c7 <allocuvm>
80103ef6:	83 c4 10             	add    $0x10,%esp
80103ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f00:	75 3b                	jne    80103f3d <growproc+0x82>
      return -1;
80103f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f07:	eb 4f                	jmp    80103f58 <growproc+0x9d>
  } else if(n < 0){
80103f09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103f0d:	79 2e                	jns    80103f3d <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103f0f:	8b 55 08             	mov    0x8(%ebp),%edx
80103f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f15:	01 c2                	add    %eax,%edx
80103f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f1a:	8b 40 04             	mov    0x4(%eax),%eax
80103f1d:	83 ec 04             	sub    $0x4,%esp
80103f20:	52                   	push   %edx
80103f21:	ff 75 f4             	push   -0xc(%ebp)
80103f24:	50                   	push   %eax
80103f25:	e8 a6 46 00 00       	call   801085d0 <deallocuvm>
80103f2a:	83 c4 10             	add    $0x10,%esp
80103f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f34:	75 07                	jne    80103f3d <growproc+0x82>
      return -1;
80103f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3b:	eb 1b                	jmp    80103f58 <growproc+0x9d>
  }
  curproc->sz = sz;
80103f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f43:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103f45:	83 ec 0c             	sub    $0xc,%esp
80103f48:	ff 75 f0             	push   -0x10(%ebp)
80103f4b:	e8 8f 42 00 00       	call   801081df <switchuvm>
80103f50:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f58:	c9                   	leave
80103f59:	c3                   	ret

80103f5a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f5a:	f3 0f 1e fb          	endbr32
80103f5e:	55                   	push   %ebp
80103f5f:	89 e5                	mov    %esp,%ebp
80103f61:	57                   	push   %edi
80103f62:	56                   	push   %esi
80103f63:	53                   	push   %ebx
80103f64:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f67:	e8 3d fc ff ff       	call   80103ba9 <myproc>
80103f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0) {
80103f6f:	e8 62 fc ff ff       	call   80103bd6 <allocproc>
80103f74:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f7b:	75 0a                	jne    80103f87 <fork+0x2d>
    return -1;
80103f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f82:	e9 e9 01 00 00       	jmp    80104170 <fork+0x216>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
80103f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8a:	8b 10                	mov    (%eax),%edx
80103f8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8f:	8b 40 04             	mov    0x4(%eax),%eax
80103f92:	83 ec 08             	sub    $0x8,%esp
80103f95:	52                   	push   %edx
80103f96:	50                   	push   %eax
80103f97:	e8 de 47 00 00       	call   8010877a <copyuvm>
80103f9c:	83 c4 10             	add    $0x10,%esp
80103f9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fa2:	89 42 04             	mov    %eax,0x4(%edx)
80103fa5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa8:	8b 40 04             	mov    0x4(%eax),%eax
80103fab:	85 c0                	test   %eax,%eax
80103fad:	75 30                	jne    80103fdf <fork+0x85>
    kfree(np->kstack);
80103faf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fb2:	8b 40 08             	mov    0x8(%eax),%eax
80103fb5:	83 ec 0c             	sub    $0xc,%esp
80103fb8:	50                   	push   %eax
80103fb9:	e8 36 e8 ff ff       	call   801027f4 <kfree>
80103fbe:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fda:	e9 91 01 00 00       	jmp    80104170 <fork+0x216>
  }
  np->sz = curproc->sz;
80103fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe2:	8b 10                	mov    (%eax),%edx
80103fe4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe7:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fe9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fec:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103fef:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff5:	8b 48 18             	mov    0x18(%eax),%ecx
80103ff8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffb:	8b 40 18             	mov    0x18(%eax),%eax
80103ffe:	89 c2                	mov    %eax,%edx
80104000:	89 cb                	mov    %ecx,%ebx
80104002:	b8 13 00 00 00       	mov    $0x13,%eax
80104007:	89 d7                	mov    %edx,%edi
80104009:	89 de                	mov    %ebx,%esi
8010400b:	89 c1                	mov    %eax,%ecx
8010400d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010400f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104012:	8b 40 18             	mov    0x18(%eax),%eax
80104015:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
8010401c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104023:	eb 3b                	jmp    80104060 <fork+0x106>
    if (curproc->ofile[i])
80104025:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104028:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010402b:	83 c2 08             	add    $0x8,%edx
8010402e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104032:	85 c0                	test   %eax,%eax
80104034:	74 26                	je     8010405c <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104039:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010403c:	83 c2 08             	add    $0x8,%edx
8010403f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104043:	83 ec 0c             	sub    $0xc,%esp
80104046:	50                   	push   %eax
80104047:	e8 48 d0 ff ff       	call   80101094 <filedup>
8010404c:	83 c4 10             	add    $0x10,%esp
8010404f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104052:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104055:	83 c1 08             	add    $0x8,%ecx
80104058:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
8010405c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104060:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104064:	7e bf                	jle    80104025 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104066:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104069:	8b 40 68             	mov    0x68(%eax),%eax
8010406c:	83 ec 0c             	sub    $0xc,%esp
8010406f:	50                   	push   %eax
80104070:	e8 c9 d9 ff ff       	call   80101a3e <idup>
80104075:	83 c4 10             	add    $0x10,%esp
80104078:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010407b:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010407e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104081:	8d 50 6c             	lea    0x6c(%eax),%edx
80104084:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104087:	83 c0 6c             	add    $0x6c,%eax
8010408a:	83 ec 04             	sub    $0x4,%esp
8010408d:	6a 10                	push   $0x10
8010408f:	52                   	push   %edx
80104090:	50                   	push   %eax
80104091:	e8 15 17 00 00       	call   801057ab <safestrcpy>
80104096:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104099:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010409c:	8b 40 10             	mov    0x10(%eax),%eax
8010409f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801040a2:	83 ec 0c             	sub    $0xc,%esp
801040a5:	68 20 65 19 80       	push   $0x80196520
801040aa:	e8 52 12 00 00       	call   80105301 <acquire>
801040af:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801040b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040b5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // MLFQ용 kernel_pstat 등록
  int idx = np - ptable.proc;
801040bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040bf:	2d 54 65 19 80       	sub    $0x80196554,%eax
801040c4:	c1 f8 02             	sar    $0x2,%eax
801040c7:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801040cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  kernel_pstat.inuse[idx] = 1;
801040d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801040d3:	c7 04 85 20 59 19 80 	movl   $0x1,-0x7fe6a6e0(,%eax,4)
801040da:	01 00 00 00 
  kernel_pstat.pid[idx] = np->pid;
801040de:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040e1:	8b 40 10             	mov    0x10(%eax),%eax
801040e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801040e7:	83 c2 40             	add    $0x40,%edx
801040ea:	89 04 95 20 59 19 80 	mov    %eax,-0x7fe6a6e0(,%edx,4)
  kernel_pstat.priority[idx] = 3;
801040f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801040f4:	83 e8 80             	sub    $0xffffff80,%eax
801040f7:	c7 04 85 20 59 19 80 	movl   $0x3,-0x7fe6a6e0(,%eax,4)
801040fe:	03 00 00 00 
  memset(kernel_pstat.ticks[idx], 0, sizeof(kernel_pstat.ticks[idx]));
80104102:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104105:	83 c0 40             	add    $0x40,%eax
80104108:	c1 e0 04             	shl    $0x4,%eax
8010410b:	05 20 59 19 80       	add    $0x80195920,%eax
80104110:	83 ec 04             	sub    $0x4,%esp
80104113:	6a 10                	push   $0x10
80104115:	6a 00                	push   $0x0
80104117:	50                   	push   %eax
80104118:	e8 73 14 00 00       	call   80105590 <memset>
8010411d:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[idx], 0, sizeof(kernel_pstat.wait_ticks[idx]));
80104120:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104123:	83 e8 80             	sub    $0xffffff80,%eax
80104126:	c1 e0 04             	shl    $0x4,%eax
80104129:	05 20 59 19 80       	add    $0x80195920,%eax
8010412e:	83 ec 04             	sub    $0x4,%esp
80104131:	6a 10                	push   $0x10
80104133:	6a 00                	push   $0x0
80104135:	50                   	push   %eax
80104136:	e8 55 14 00 00       	call   80105590 <memset>
8010413b:	83 c4 10             	add    $0x10,%esp

  if (mycpu()->sched_policy > 0)
8010413e:	e8 ea f9 ff ff       	call   80103b2d <mycpu>
80104143:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	7e 10                	jle    8010415d <fork+0x203>
    enqueue(np, 3);
8010414d:	83 ec 08             	sub    $0x8,%esp
80104150:	6a 03                	push   $0x3
80104152:	ff 75 dc             	push   -0x24(%ebp)
80104155:	e8 1e 0a 00 00       	call   80104b78 <enqueue>
8010415a:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
8010415d:	83 ec 0c             	sub    $0xc,%esp
80104160:	68 20 65 19 80       	push   $0x80196520
80104165:	e8 09 12 00 00       	call   80105373 <release>
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
8010418a:	a1 7c d0 18 80       	mov    0x8018d07c,%eax
8010418f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104192:	75 0d                	jne    801041a1 <exit+0x29>
    panic("init exiting");
80104194:	83 ec 0c             	sub    $0xc,%esp
80104197:	68 02 b2 10 80       	push   $0x8010b202
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
80104218:	68 20 65 19 80       	push   $0x80196520
8010421d:	e8 df 10 00 00       	call   80105301 <acquire>
80104222:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104225:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104228:	8b 40 14             	mov    0x14(%eax),%eax
8010422b:	83 ec 0c             	sub    $0xc,%esp
8010422e:	50                   	push   %eax
8010422f:	e8 f4 04 00 00       	call   80104728 <wakeup1>
80104234:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104237:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
8010423e:	eb 37                	jmp    80104277 <exit+0xff>
    if(p->parent == curproc){
80104240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104243:	8b 40 14             	mov    0x14(%eax),%eax
80104246:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104249:	75 28                	jne    80104273 <exit+0xfb>
      p->parent = initproc;
8010424b:	8b 15 7c d0 18 80    	mov    0x8018d07c,%edx
80104251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104254:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425a:	8b 40 0c             	mov    0xc(%eax),%eax
8010425d:	83 f8 05             	cmp    $0x5,%eax
80104260:	75 11                	jne    80104273 <exit+0xfb>
        wakeup1(initproc);
80104262:	a1 7c d0 18 80       	mov    0x8018d07c,%eax
80104267:	83 ec 0c             	sub    $0xc,%esp
8010426a:	50                   	push   %eax
8010426b:	e8 b8 04 00 00       	call   80104728 <wakeup1>
80104270:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104273:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104277:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
8010427e:	72 c0                	jb     80104240 <exit+0xc8>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
80104280:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104283:	2d 54 65 19 80       	sub    $0x80196554,%eax
80104288:	c1 f8 02             	sar    $0x2,%eax
8010428b:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104291:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int q;
  q = kernel_pstat.priority[i];
80104294:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104297:	83 e8 80             	sub    $0xffffff80,%eax
8010429a:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
801042a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (get_sched_policy() > 0)
801042a4:	e8 a8 08 00 00       	call   80104b51 <get_sched_policy>
801042a9:	85 c0                	test   %eax,%eax
801042ab:	7e 25                	jle    801042d2 <exit+0x15a>
  {
    dequeue(q);
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	ff 75 e4             	push   -0x1c(%ebp)
801042b3:	e8 3f 09 00 00       	call   80104bf7 <dequeue>
801042b8:	83 c4 10             	add    $0x10,%esp
    cprintf("[PROCESS EXIT] pid: %d\n", curproc->pid);
801042bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042be:	8b 40 10             	mov    0x10(%eax),%eax
801042c1:	83 ec 08             	sub    $0x8,%esp
801042c4:	50                   	push   %eax
801042c5:	68 0f b2 10 80       	push   $0x8010b20f
801042ca:	e8 3d c1 ff ff       	call   8010040c <cprintf>
801042cf:	83 c4 10             	add    $0x10,%esp
  }
  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801042d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801042dc:	e8 57 02 00 00       	call   80104538 <sched>
  panic("zombie exit");
801042e1:	83 ec 0c             	sub    $0xc,%esp
801042e4:	68 27 b2 10 80       	push   $0x8010b227
801042e9:	e8 d7 c2 ff ff       	call   801005c5 <panic>

801042ee <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801042ee:	f3 0f 1e fb          	endbr32
801042f2:	55                   	push   %ebp
801042f3:	89 e5                	mov    %esp,%ebp
801042f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801042f8:	e8 ac f8 ff ff       	call   80103ba9 <myproc>
801042fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 20 65 19 80       	push   $0x80196520
80104308:	e8 f4 0f 00 00       	call   80105301 <acquire>
8010430d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104310:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104317:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
8010431e:	e9 a1 00 00 00       	jmp    801043c4 <wait+0xd6>
      if(p->parent != curproc)
80104323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104326:	8b 40 14             	mov    0x14(%eax),%eax
80104329:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010432c:	0f 85 8d 00 00 00    	jne    801043bf <wait+0xd1>
        continue;
      havekids = 1;
80104332:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433c:	8b 40 0c             	mov    0xc(%eax),%eax
8010433f:	83 f8 05             	cmp    $0x5,%eax
80104342:	75 7c                	jne    801043c0 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104347:	8b 40 10             	mov    0x10(%eax),%eax
8010434a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010434d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104350:	8b 40 08             	mov    0x8(%eax),%eax
80104353:	83 ec 0c             	sub    $0xc,%esp
80104356:	50                   	push   %eax
80104357:	e8 98 e4 ff ff       	call   801027f4 <kfree>
8010435c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104362:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436c:	8b 40 04             	mov    0x4(%eax),%eax
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	50                   	push   %eax
80104373:	e8 20 43 00 00       	call   80108698 <freevm>
80104378:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010437b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104388:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010438f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104392:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801043aa:	83 ec 0c             	sub    $0xc,%esp
801043ad:	68 20 65 19 80       	push   $0x80196520
801043b2:	e8 bc 0f 00 00       	call   80105373 <release>
801043b7:	83 c4 10             	add    $0x10,%esp
        return pid;
801043ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043bd:	eb 51                	jmp    80104410 <wait+0x122>
        continue;
801043bf:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043c0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043c4:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
801043cb:	0f 82 52 ff ff ff    	jb     80104323 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801043d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801043d5:	74 0a                	je     801043e1 <wait+0xf3>
801043d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043da:	8b 40 24             	mov    0x24(%eax),%eax
801043dd:	85 c0                	test   %eax,%eax
801043df:	74 17                	je     801043f8 <wait+0x10a>
      release(&ptable.lock);
801043e1:	83 ec 0c             	sub    $0xc,%esp
801043e4:	68 20 65 19 80       	push   $0x80196520
801043e9:	e8 85 0f 00 00       	call   80105373 <release>
801043ee:	83 c4 10             	add    $0x10,%esp
      return -1;
801043f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043f6:	eb 18                	jmp    80104410 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801043f8:	83 ec 08             	sub    $0x8,%esp
801043fb:	68 20 65 19 80       	push   $0x80196520
80104400:	ff 75 ec             	push   -0x14(%ebp)
80104403:	e8 75 02 00 00       	call   8010467d <sleep>
80104408:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010440b:	e9 00 ff ff ff       	jmp    80104310 <wait+0x22>
  }
}
80104410:	c9                   	leave
80104411:	c3                   	ret

80104412 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104412:	f3 0f 1e fb          	endbr32
80104416:	55                   	push   %ebp
80104417:	89 e5                	mov    %esp,%ebp
80104419:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010441c:	e8 0c f7 ff ff       	call   80103b2d <mycpu>
80104421:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104427:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010442e:	00 00 00 

  for(;;){
    sti();
80104431:	e8 af f6 ff ff       	call   80103ae5 <sti>
    acquire(&ptable.lock);
80104436:	83 ec 0c             	sub    $0xc,%esp
80104439:	68 20 65 19 80       	push   $0x80196520
8010443e:	e8 be 0e 00 00       	call   80105301 <acquire>
80104443:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 0) {
80104446:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104449:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010444f:	85 c0                	test   %eax,%eax
80104451:	75 75                	jne    801044c8 <scheduler+0xb6>
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104453:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
8010445a:	eb 61                	jmp    801044bd <scheduler+0xab>
        if(p->state != RUNNABLE)
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	8b 40 0c             	mov    0xc(%eax),%eax
80104462:	83 f8 03             	cmp    $0x3,%eax
80104465:	75 51                	jne    801044b8 <scheduler+0xa6>
          continue;
        c->proc = p;
80104467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010446a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010446d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104473:	83 ec 0c             	sub    $0xc,%esp
80104476:	ff 75 f4             	push   -0xc(%ebp)
80104479:	e8 61 3d 00 00       	call   801081df <switchuvm>
8010447e:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104484:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&(c->scheduler), p->context);
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104491:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104494:	83 c2 04             	add    $0x4,%edx
80104497:	83 ec 08             	sub    $0x8,%esp
8010449a:	50                   	push   %eax
8010449b:	52                   	push   %edx
8010449c:	e8 83 13 00 00       	call   80105824 <swtch>
801044a1:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801044a4:	e8 19 3d 00 00       	call   801081c2 <switchkvm>
        c->proc = 0;
801044a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ac:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801044b3:	00 00 00 
801044b6:	eb 01                	jmp    801044b9 <scheduler+0xa7>
          continue;
801044b8:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044b9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044bd:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
801044c4:	72 96                	jb     8010445c <scheduler+0x4a>
801044c6:	eb 5b                	jmp    80104523 <scheduler+0x111>
      //   if(p->state == RUNNABLE && p != c->proc){
      //     int i = p - ptable.proc;
      //     kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
      //   }
      // }
    } else if (c->sched_policy == 1) {
801044c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044d1:	83 f8 01             	cmp    $0x1,%eax
801044d4:	75 11                	jne    801044e7 <scheduler+0xd5>
      run_mlfq(1, 1);
801044d6:	83 ec 08             	sub    $0x8,%esp
801044d9:	6a 01                	push   $0x1
801044db:	6a 01                	push   $0x1
801044dd:	e8 35 0b 00 00       	call   80105017 <run_mlfq>
801044e2:	83 c4 10             	add    $0x10,%esp
801044e5:	eb 3c                	jmp    80104523 <scheduler+0x111>
    } else if (c->sched_policy == 2) {
801044e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ea:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801044f0:	83 f8 02             	cmp    $0x2,%eax
801044f3:	75 11                	jne    80104506 <scheduler+0xf4>
      run_mlfq(0, 1);
801044f5:	83 ec 08             	sub    $0x8,%esp
801044f8:	6a 01                	push   $0x1
801044fa:	6a 00                	push   $0x0
801044fc:	e8 16 0b 00 00       	call   80105017 <run_mlfq>
80104501:	83 c4 10             	add    $0x10,%esp
80104504:	eb 1d                	jmp    80104523 <scheduler+0x111>
    } else if (c->sched_policy == 3) {
80104506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104509:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010450f:	83 f8 03             	cmp    $0x3,%eax
80104512:	75 0f                	jne    80104523 <scheduler+0x111>
      run_mlfq(1, 0);
80104514:	83 ec 08             	sub    $0x8,%esp
80104517:	6a 00                	push   $0x0
80104519:	6a 01                	push   $0x1
8010451b:	e8 f7 0a 00 00       	call   80105017 <run_mlfq>
80104520:	83 c4 10             	add    $0x10,%esp
    }
    release(&ptable.lock);
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	68 20 65 19 80       	push   $0x80196520
8010452b:	e8 43 0e 00 00       	call   80105373 <release>
80104530:	83 c4 10             	add    $0x10,%esp
    sti();
80104533:	e9 f9 fe ff ff       	jmp    80104431 <scheduler+0x1f>

80104538 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104538:	f3 0f 1e fb          	endbr32
8010453c:	55                   	push   %ebp
8010453d:	89 e5                	mov    %esp,%ebp
8010453f:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104542:	e8 62 f6 ff ff       	call   80103ba9 <myproc>
80104547:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010454a:	83 ec 0c             	sub    $0xc,%esp
8010454d:	68 20 65 19 80       	push   $0x80196520
80104552:	e8 f1 0e 00 00       	call   80105448 <holding>
80104557:	83 c4 10             	add    $0x10,%esp
8010455a:	85 c0                	test   %eax,%eax
8010455c:	75 0d                	jne    8010456b <sched+0x33>
    panic("sched ptable.lock");
8010455e:	83 ec 0c             	sub    $0xc,%esp
80104561:	68 33 b2 10 80       	push   $0x8010b233
80104566:	e8 5a c0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
8010456b:	e8 bd f5 ff ff       	call   80103b2d <mycpu>
80104570:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104576:	83 f8 01             	cmp    $0x1,%eax
80104579:	74 0d                	je     80104588 <sched+0x50>
    panic("sched locks");
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	68 45 b2 10 80       	push   $0x8010b245
80104583:	e8 3d c0 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458b:	8b 40 0c             	mov    0xc(%eax),%eax
8010458e:	83 f8 04             	cmp    $0x4,%eax
80104591:	75 0d                	jne    801045a0 <sched+0x68>
    panic("sched running");
80104593:	83 ec 0c             	sub    $0xc,%esp
80104596:	68 51 b2 10 80       	push   $0x8010b251
8010459b:	e8 25 c0 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801045a0:	e8 30 f5 ff ff       	call   80103ad5 <readeflags>
801045a5:	25 00 02 00 00       	and    $0x200,%eax
801045aa:	85 c0                	test   %eax,%eax
801045ac:	74 0d                	je     801045bb <sched+0x83>
    panic("sched interruptible");
801045ae:	83 ec 0c             	sub    $0xc,%esp
801045b1:	68 5f b2 10 80       	push   $0x8010b25f
801045b6:	e8 0a c0 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801045bb:	e8 6d f5 ff ff       	call   80103b2d <mycpu>
801045c0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801045c9:	e8 5f f5 ff ff       	call   80103b2d <mycpu>
801045ce:	8b 40 04             	mov    0x4(%eax),%eax
801045d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d4:	83 c2 1c             	add    $0x1c,%edx
801045d7:	83 ec 08             	sub    $0x8,%esp
801045da:	50                   	push   %eax
801045db:	52                   	push   %edx
801045dc:	e8 43 12 00 00       	call   80105824 <swtch>
801045e1:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801045e4:	e8 44 f5 ff ff       	call   80103b2d <mycpu>
801045e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045ec:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801045f2:	90                   	nop
801045f3:	c9                   	leave
801045f4:	c3                   	ret

801045f5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801045f5:	f3 0f 1e fb          	endbr32
801045f9:	55                   	push   %ebp
801045fa:	89 e5                	mov    %esp,%ebp
801045fc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801045ff:	83 ec 0c             	sub    $0xc,%esp
80104602:	68 20 65 19 80       	push   $0x80196520
80104607:	e8 f5 0c 00 00       	call   80105301 <acquire>
8010460c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010460f:	e8 95 f5 ff ff       	call   80103ba9 <myproc>
80104614:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010461b:	e8 18 ff ff ff       	call   80104538 <sched>
  release(&ptable.lock);
80104620:	83 ec 0c             	sub    $0xc,%esp
80104623:	68 20 65 19 80       	push   $0x80196520
80104628:	e8 46 0d 00 00       	call   80105373 <release>
8010462d:	83 c4 10             	add    $0x10,%esp
}
80104630:	90                   	nop
80104631:	c9                   	leave
80104632:	c3                   	ret

80104633 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104633:	f3 0f 1e fb          	endbr32
80104637:	55                   	push   %ebp
80104638:	89 e5                	mov    %esp,%ebp
8010463a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010463d:	83 ec 0c             	sub    $0xc,%esp
80104640:	68 20 65 19 80       	push   $0x80196520
80104645:	e8 29 0d 00 00       	call   80105373 <release>
8010464a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010464d:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104652:	85 c0                	test   %eax,%eax
80104654:	74 24                	je     8010467a <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104656:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010465d:	00 00 00 
    iinit(ROOTDEV);
80104660:	83 ec 0c             	sub    $0xc,%esp
80104663:	6a 01                	push   $0x1
80104665:	e8 8c d0 ff ff       	call   801016f6 <iinit>
8010466a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010466d:	83 ec 0c             	sub    $0xc,%esp
80104670:	6a 01                	push   $0x1
80104672:	e8 c7 e8 ff ff       	call   80102f3e <initlog>
80104677:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010467a:	90                   	nop
8010467b:	c9                   	leave
8010467c:	c3                   	ret

8010467d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010467d:	f3 0f 1e fb          	endbr32
80104681:	55                   	push   %ebp
80104682:	89 e5                	mov    %esp,%ebp
80104684:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104687:	e8 1d f5 ff ff       	call   80103ba9 <myproc>
8010468c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010468f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104693:	75 0d                	jne    801046a2 <sleep+0x25>
    panic("sleep");
80104695:	83 ec 0c             	sub    $0xc,%esp
80104698:	68 73 b2 10 80       	push   $0x8010b273
8010469d:	e8 23 bf ff ff       	call   801005c5 <panic>

  if(lk == 0)
801046a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801046a6:	75 0d                	jne    801046b5 <sleep+0x38>
    panic("sleep without lk");
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	68 79 b2 10 80       	push   $0x8010b279
801046b0:	e8 10 bf ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801046b5:	81 7d 0c 20 65 19 80 	cmpl   $0x80196520,0xc(%ebp)
801046bc:	74 1e                	je     801046dc <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801046be:	83 ec 0c             	sub    $0xc,%esp
801046c1:	68 20 65 19 80       	push   $0x80196520
801046c6:	e8 36 0c 00 00       	call   80105301 <acquire>
801046cb:	83 c4 10             	add    $0x10,%esp
    release(lk);
801046ce:	83 ec 0c             	sub    $0xc,%esp
801046d1:	ff 75 0c             	push   0xc(%ebp)
801046d4:	e8 9a 0c 00 00       	call   80105373 <release>
801046d9:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801046dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046df:	8b 55 08             	mov    0x8(%ebp),%edx
801046e2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801046e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801046ef:	e8 44 fe ff ff       	call   80104538 <sched>

  // Tidy up.
  p->chan = 0;
801046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801046fe:	81 7d 0c 20 65 19 80 	cmpl   $0x80196520,0xc(%ebp)
80104705:	74 1e                	je     80104725 <sleep+0xa8>
    release(&ptable.lock);
80104707:	83 ec 0c             	sub    $0xc,%esp
8010470a:	68 20 65 19 80       	push   $0x80196520
8010470f:	e8 5f 0c 00 00       	call   80105373 <release>
80104714:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	ff 75 0c             	push   0xc(%ebp)
8010471d:	e8 df 0b 00 00       	call   80105301 <acquire>
80104722:	83 c4 10             	add    $0x10,%esp
  }
}
80104725:	90                   	nop
80104726:	c9                   	leave
80104727:	c3                   	ret

80104728 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104728:	f3 0f 1e fb          	endbr32
8010472c:	55                   	push   %ebp
8010472d:	89 e5                	mov    %esp,%ebp
8010472f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  enqueue(chan,3);
80104732:	83 ec 08             	sub    $0x8,%esp
80104735:	6a 03                	push   $0x3
80104737:	ff 75 08             	push   0x8(%ebp)
8010473a:	e8 39 04 00 00       	call   80104b78 <enqueue>
8010473f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104742:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
80104749:	eb 24                	jmp    8010476f <wakeup1+0x47>
    if(p->state == SLEEPING && p->chan == chan){
8010474b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474e:	8b 40 0c             	mov    0xc(%eax),%eax
80104751:	83 f8 02             	cmp    $0x2,%eax
80104754:	75 15                	jne    8010476b <wakeup1+0x43>
80104756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104759:	8b 40 20             	mov    0x20(%eax),%eax
8010475c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010475f:	75 0a                	jne    8010476b <wakeup1+0x43>
      p->state = RUNNABLE;
80104761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104764:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010476b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010476f:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
80104776:	72 d3                	jb     8010474b <wakeup1+0x23>
    }
}
80104778:	90                   	nop
80104779:	90                   	nop
8010477a:	c9                   	leave
8010477b:	c3                   	ret

8010477c <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010477c:	f3 0f 1e fb          	endbr32
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	68 20 65 19 80       	push   $0x80196520
8010478e:	e8 6e 0b 00 00       	call   80105301 <acquire>
80104793:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104796:	83 ec 0c             	sub    $0xc,%esp
80104799:	ff 75 08             	push   0x8(%ebp)
8010479c:	e8 87 ff ff ff       	call   80104728 <wakeup1>
801047a1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	68 20 65 19 80       	push   $0x80196520
801047ac:	e8 c2 0b 00 00       	call   80105373 <release>
801047b1:	83 c4 10             	add    $0x10,%esp
}
801047b4:	90                   	nop
801047b5:	c9                   	leave
801047b6:	c3                   	ret

801047b7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801047b7:	f3 0f 1e fb          	endbr32
801047bb:	55                   	push   %ebp
801047bc:	89 e5                	mov    %esp,%ebp
801047be:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801047c1:	83 ec 0c             	sub    $0xc,%esp
801047c4:	68 20 65 19 80       	push   $0x80196520
801047c9:	e8 33 0b 00 00       	call   80105301 <acquire>
801047ce:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047d1:	c7 45 f4 54 65 19 80 	movl   $0x80196554,-0xc(%ebp)
801047d8:	eb 45                	jmp    8010481f <kill+0x68>
    if(p->pid == pid){
801047da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dd:	8b 40 10             	mov    0x10(%eax),%eax
801047e0:	39 45 08             	cmp    %eax,0x8(%ebp)
801047e3:	75 36                	jne    8010481b <kill+0x64>
      p->killed = 1;
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801047ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f2:	8b 40 0c             	mov    0xc(%eax),%eax
801047f5:	83 f8 02             	cmp    $0x2,%eax
801047f8:	75 0a                	jne    80104804 <kill+0x4d>
        p->state = RUNNABLE;
801047fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104804:	83 ec 0c             	sub    $0xc,%esp
80104807:	68 20 65 19 80       	push   $0x80196520
8010480c:	e8 62 0b 00 00       	call   80105373 <release>
80104811:	83 c4 10             	add    $0x10,%esp
      return 0;
80104814:	b8 00 00 00 00       	mov    $0x0,%eax
80104819:	eb 22                	jmp    8010483d <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010481b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010481f:	81 7d f4 54 84 19 80 	cmpl   $0x80198454,-0xc(%ebp)
80104826:	72 b2                	jb     801047da <kill+0x23>
    }
  }
  release(&ptable.lock);
80104828:	83 ec 0c             	sub    $0xc,%esp
8010482b:	68 20 65 19 80       	push   $0x80196520
80104830:	e8 3e 0b 00 00       	call   80105373 <release>
80104835:	83 c4 10             	add    $0x10,%esp
  return -1;
80104838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010483d:	c9                   	leave
8010483e:	c3                   	ret

8010483f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010483f:	f3 0f 1e fb          	endbr32
80104843:	55                   	push   %ebp
80104844:	89 e5                	mov    %esp,%ebp
80104846:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104849:	c7 45 f0 54 65 19 80 	movl   $0x80196554,-0x10(%ebp)
80104850:	e9 d7 00 00 00       	jmp    8010492c <procdump+0xed>
    if(p->state == UNUSED)
80104855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104858:	8b 40 0c             	mov    0xc(%eax),%eax
8010485b:	85 c0                	test   %eax,%eax
8010485d:	0f 84 c4 00 00 00    	je     80104927 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104866:	8b 40 0c             	mov    0xc(%eax),%eax
80104869:	83 f8 05             	cmp    $0x5,%eax
8010486c:	77 23                	ja     80104891 <procdump+0x52>
8010486e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104871:	8b 40 0c             	mov    0xc(%eax),%eax
80104874:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010487b:	85 c0                	test   %eax,%eax
8010487d:	74 12                	je     80104891 <procdump+0x52>
      state = states[p->state];
8010487f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104882:	8b 40 0c             	mov    0xc(%eax),%eax
80104885:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010488c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010488f:	eb 07                	jmp    80104898 <procdump+0x59>
    else
      state = "???";
80104891:	c7 45 ec 8a b2 10 80 	movl   $0x8010b28a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010489e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a1:	8b 40 10             	mov    0x10(%eax),%eax
801048a4:	52                   	push   %edx
801048a5:	ff 75 ec             	push   -0x14(%ebp)
801048a8:	50                   	push   %eax
801048a9:	68 8e b2 10 80       	push   $0x8010b28e
801048ae:	e8 59 bb ff ff       	call   8010040c <cprintf>
801048b3:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801048b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b9:	8b 40 0c             	mov    0xc(%eax),%eax
801048bc:	83 f8 02             	cmp    $0x2,%eax
801048bf:	75 54                	jne    80104915 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801048c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c4:	8b 40 1c             	mov    0x1c(%eax),%eax
801048c7:	8b 40 0c             	mov    0xc(%eax),%eax
801048ca:	83 c0 08             	add    $0x8,%eax
801048cd:	89 c2                	mov    %eax,%edx
801048cf:	83 ec 08             	sub    $0x8,%esp
801048d2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801048d5:	50                   	push   %eax
801048d6:	52                   	push   %edx
801048d7:	e8 ed 0a 00 00       	call   801053c9 <getcallerpcs>
801048dc:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801048df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048e6:	eb 1c                	jmp    80104904 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048eb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801048ef:	83 ec 08             	sub    $0x8,%esp
801048f2:	50                   	push   %eax
801048f3:	68 97 b2 10 80       	push   $0x8010b297
801048f8:	e8 0f bb ff ff       	call   8010040c <cprintf>
801048fd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104900:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104904:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104908:	7f 0b                	jg     80104915 <procdump+0xd6>
8010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104911:	85 c0                	test   %eax,%eax
80104913:	75 d3                	jne    801048e8 <procdump+0xa9>
    }
    cprintf("\n");
80104915:	83 ec 0c             	sub    $0xc,%esp
80104918:	68 9b b2 10 80       	push   $0x8010b29b
8010491d:	e8 ea ba ff ff       	call   8010040c <cprintf>
80104922:	83 c4 10             	add    $0x10,%esp
80104925:	eb 01                	jmp    80104928 <procdump+0xe9>
      continue;
80104927:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104928:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010492c:	81 7d f0 54 84 19 80 	cmpl   $0x80198454,-0x10(%ebp)
80104933:	0f 82 1c ff ff ff    	jb     80104855 <procdump+0x16>
  }
}
80104939:	90                   	nop
8010493a:	90                   	nop
8010493b:	c9                   	leave
8010493c:	c3                   	ret

8010493d <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
8010493d:	f3 0f 1e fb          	endbr32
80104941:	55                   	push   %ebp
80104942:	89 e5                	mov    %esp,%ebp
80104944:	53                   	push   %ebx
80104945:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	68 20 65 19 80       	push   $0x80196520
80104950:	e8 ac 09 00 00       	call   80105301 <acquire>
80104955:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104958:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010495f:	e9 e6 00 00 00       	jmp    80104a4a <getpinfo+0x10d>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104967:	8b 0c 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%ecx
8010496e:	8b 45 08             	mov    0x8(%ebp),%eax
80104971:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104974:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	83 c0 40             	add    $0x40,%eax
8010497d:	8b 14 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%edx
80104984:	8b 45 08             	mov    0x8(%ebp),%eax
80104987:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010498a:	83 c1 40             	add    $0x40,%ecx
8010498d:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
80104990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104993:	83 e8 80             	sub    $0xffffff80,%eax
80104996:	8b 14 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%edx
8010499d:	8b 45 08             	mov    0x8(%ebp),%eax
801049a0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049a3:	83 e9 80             	sub    $0xffffff80,%ecx
801049a6:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
801049a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
801049af:	05 60 65 19 80       	add    $0x80196560,%eax
801049b4:	8b 00                	mov    (%eax),%eax
801049b6:	89 c1                	mov    %eax,%ecx
801049b8:	8b 45 08             	mov    0x8(%ebp),%eax
801049bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049be:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801049c4:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801049c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049ce:	eb 70                	jmp    80104a40 <getpinfo+0x103>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801049d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049dd:	01 d0                	add    %edx,%eax
801049df:	05 00 01 00 00       	add    $0x100,%eax
801049e4:	8b 14 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%edx
801049eb:	8b 45 08             	mov    0x8(%ebp),%eax
801049ee:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801049f1:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801049f8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801049fb:	01 d9                	add    %ebx,%ecx
801049fd:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104a03:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
80104a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a13:	01 d0                	add    %edx,%eax
80104a15:	05 00 02 00 00       	add    $0x200,%eax
80104a1a:	8b 14 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%edx
80104a21:	8b 45 08             	mov    0x8(%ebp),%eax
80104a24:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104a27:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104a2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104a31:	01 d9                	add    %ebx,%ecx
80104a33:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104a39:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104a3c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a40:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104a44:	7e 8a                	jle    801049d0 <getpinfo+0x93>
  for (int i = 0; i < NPROC; i++) {
80104a46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a4a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104a4e:	0f 8e 10 ff ff ff    	jle    80104964 <getpinfo+0x27>
    }
  }
  release(&ptable.lock);
80104a54:	83 ec 0c             	sub    $0xc,%esp
80104a57:	68 20 65 19 80       	push   $0x80196520
80104a5c:	e8 12 09 00 00       	call   80105373 <release>
80104a61:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a6c:	c9                   	leave
80104a6d:	c3                   	ret

80104a6e <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
80104a6e:	f3 0f 1e fb          	endbr32
80104a72:	55                   	push   %ebp
80104a73:	89 e5                	mov    %esp,%ebp
80104a75:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a78:	83 ec 0c             	sub    $0xc,%esp
80104a7b:	68 20 65 19 80       	push   $0x80196520
80104a80:	e8 7c 08 00 00       	call   80105301 <acquire>
80104a85:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104a88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a8f:	eb 60                	jmp    80104af1 <mlfq_enqueue_all_runnable+0x83>
    if (!kernel_pstat.inuse[i]) continue;
80104a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a94:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104a9b:	85 c0                	test   %eax,%eax
80104a9d:	74 4d                	je     80104aec <mlfq_enqueue_all_runnable+0x7e>
    struct proc *p = &ptable.proc[i];
80104a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa2:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104aa5:	83 c0 30             	add    $0x30,%eax
80104aa8:	05 20 65 19 80       	add    $0x80196520,%eax
80104aad:	83 c0 04             	add    $0x4,%eax
80104ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE || p->state == RUNNING) {
80104ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab9:	83 f8 03             	cmp    $0x3,%eax
80104abc:	74 0b                	je     80104ac9 <mlfq_enqueue_all_runnable+0x5b>
80104abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac4:	83 f8 04             	cmp    $0x4,%eax
80104ac7:	75 24                	jne    80104aed <mlfq_enqueue_all_runnable+0x7f>
      int q = kernel_pstat.priority[i];
80104ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acc:	83 e8 80             	sub    $0xffffff80,%eax
80104acf:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104ad6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
80104ad9:	83 ec 08             	sub    $0x8,%esp
80104adc:	ff 75 ec             	push   -0x14(%ebp)
80104adf:	ff 75 f0             	push   -0x10(%ebp)
80104ae2:	e8 91 00 00 00       	call   80104b78 <enqueue>
80104ae7:	83 c4 10             	add    $0x10,%esp
80104aea:	eb 01                	jmp    80104aed <mlfq_enqueue_all_runnable+0x7f>
    if (!kernel_pstat.inuse[i]) continue;
80104aec:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104aed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104af1:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104af5:	7e 9a                	jle    80104a91 <mlfq_enqueue_all_runnable+0x23>
      //cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
    }
  }
  release(&ptable.lock);
80104af7:	83 ec 0c             	sub    $0xc,%esp
80104afa:	68 20 65 19 80       	push   $0x80196520
80104aff:	e8 6f 08 00 00       	call   80105373 <release>
80104b04:	83 c4 10             	add    $0x10,%esp
}
80104b07:	90                   	nop
80104b08:	c9                   	leave
80104b09:	c3                   	ret

80104b0a <set_sched_policy>:

int
set_sched_policy(int policy)
{
80104b0a:	f3 0f 1e fb          	endbr32
80104b0e:	55                   	push   %ebp
80104b0f:	89 e5                	mov    %esp,%ebp
80104b11:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104b14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b18:	78 06                	js     80104b20 <set_sched_policy+0x16>
80104b1a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104b1e:	7e 07                	jle    80104b27 <set_sched_policy+0x1d>
    return -1;
80104b20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b25:	eb 28                	jmp    80104b4f <set_sched_policy+0x45>

  pushcli(); 
80104b27:	e8 51 09 00 00       	call   8010547d <pushcli>
  mycpu()->sched_policy = policy;
80104b2c:	e8 fc ef ff ff       	call   80103b2d <mycpu>
80104b31:	8b 55 08             	mov    0x8(%ebp),%edx
80104b34:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104b3a:	e8 8f 09 00 00       	call   801054ce <popcli>

  if (policy > 0)
80104b3f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104b43:	7e 05                	jle    80104b4a <set_sched_policy+0x40>
  mlfq_enqueue_all_runnable();
80104b45:	e8 24 ff ff ff       	call   80104a6e <mlfq_enqueue_all_runnable>

  return 0;
80104b4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b4f:	c9                   	leave
80104b50:	c3                   	ret

80104b51 <get_sched_policy>:
int
get_sched_policy(void)
{
80104b51:	f3 0f 1e fb          	endbr32
80104b55:	55                   	push   %ebp
80104b56:	89 e5                	mov    %esp,%ebp
80104b58:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
80104b5b:	e8 1d 09 00 00       	call   8010547d <pushcli>
  int policy = mycpu()->sched_policy;
80104b60:	e8 c8 ef ff ff       	call   80103b2d <mycpu>
80104b65:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104b6e:	e8 5b 09 00 00       	call   801054ce <popcli>
  return policy;
80104b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b76:	c9                   	leave
80104b77:	c3                   	ret

80104b78 <enqueue>:
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void
enqueue(struct proc *p, int level) {
80104b78:	f3 0f 1e fb          	endbr32
80104b7c:	55                   	push   %ebp
80104b7d:	89 e5                	mov    %esp,%ebp
80104b7f:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++)
80104b82:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104b89:	eb 1d                	jmp    80104ba8 <enqueue+0x30>
    if (mlfq_queues[level][i] == p) return;
80104b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8e:	c1 e0 06             	shl    $0x6,%eax
80104b91:	89 c2                	mov    %eax,%edx
80104b93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b96:	01 d0                	add    %edx,%eax
80104b98:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80104b9f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ba2:	74 50                	je     80104bf4 <enqueue+0x7c>
  for (int i = 0; i < NPROC; i++)
80104ba4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ba8:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104bac:	7e dd                	jle    80104b8b <enqueue+0x13>
  for (int i = 0; i < NPROC; i++)
80104bae:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bb5:	eb 35                	jmp    80104bec <enqueue+0x74>
    if (mlfq_queues[level][i] == 0) {
80104bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bba:	c1 e0 06             	shl    $0x6,%eax
80104bbd:	89 c2                	mov    %eax,%edx
80104bbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bc2:	01 d0                	add    %edx,%eax
80104bc4:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80104bcb:	85 c0                	test   %eax,%eax
80104bcd:	75 19                	jne    80104be8 <enqueue+0x70>
      mlfq_queues[level][i] = p;
80104bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd2:	c1 e0 06             	shl    $0x6,%eax
80104bd5:	89 c2                	mov    %eax,%edx
80104bd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bda:	01 c2                	add    %eax,%edx
80104bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdf:	89 04 95 20 55 19 80 	mov    %eax,-0x7fe6aae0(,%edx,4)
      return;
80104be6:	eb 0d                	jmp    80104bf5 <enqueue+0x7d>
  for (int i = 0; i < NPROC; i++)
80104be8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bec:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104bf0:	7e c5                	jle    80104bb7 <enqueue+0x3f>
80104bf2:	eb 01                	jmp    80104bf5 <enqueue+0x7d>
    if (mlfq_queues[level][i] == p) return;
80104bf4:	90                   	nop
    }
}
80104bf5:	c9                   	leave
80104bf6:	c3                   	ret

80104bf7 <dequeue>:

struct proc*
dequeue(int level) {
80104bf7:	f3 0f 1e fb          	endbr32
80104bfb:	55                   	push   %ebp
80104bfc:	89 e5                	mov    %esp,%ebp
80104bfe:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
80104c01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for (int i = 0; i < NPROC; i++) {
80104c08:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c0f:	e9 81 00 00 00       	jmp    80104c95 <dequeue+0x9e>
    if (mlfq_queues[level][i]) {
80104c14:	8b 45 08             	mov    0x8(%ebp),%eax
80104c17:	c1 e0 06             	shl    $0x6,%eax
80104c1a:	89 c2                	mov    %eax,%edx
80104c1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c1f:	01 d0                	add    %edx,%eax
80104c21:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80104c28:	85 c0                	test   %eax,%eax
80104c2a:	74 65                	je     80104c91 <dequeue+0x9a>
      p = mlfq_queues[level][i];
80104c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2f:	c1 e0 06             	shl    $0x6,%eax
80104c32:	89 c2                	mov    %eax,%edx
80104c34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c37:	01 d0                	add    %edx,%eax
80104c39:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80104c40:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104c43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c49:	eb 2d                	jmp    80104c78 <dequeue+0x81>
        mlfq_queues[level][j] = mlfq_queues[level][j+1];
80104c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4e:	8d 50 01             	lea    0x1(%eax),%edx
80104c51:	8b 45 08             	mov    0x8(%ebp),%eax
80104c54:	c1 e0 06             	shl    $0x6,%eax
80104c57:	01 d0                	add    %edx,%eax
80104c59:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80104c60:	8b 55 08             	mov    0x8(%ebp),%edx
80104c63:	89 d1                	mov    %edx,%ecx
80104c65:	c1 e1 06             	shl    $0x6,%ecx
80104c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c6b:	01 ca                	add    %ecx,%edx
80104c6d:	89 04 95 20 55 19 80 	mov    %eax,-0x7fe6aae0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104c74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c78:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104c7c:	7e cd                	jle    80104c4b <dequeue+0x54>
      mlfq_queues[level][NPROC - 1] = 0;
80104c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c81:	c1 e0 08             	shl    $0x8,%eax
80104c84:	05 1c 56 19 80       	add    $0x8019561c,%eax
80104c89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      break;
80104c8f:	eb 0e                	jmp    80104c9f <dequeue+0xa8>
  for (int i = 0; i < NPROC; i++) {
80104c91:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c95:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104c99:	0f 8e 75 ff ff ff    	jle    80104c14 <dequeue+0x1d>
    }
  }
  return p;
80104c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ca2:	c9                   	leave
80104ca3:	c3                   	ret

80104ca4 <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104ca4:	f3 0f 1e fb          	endbr32
80104ca8:	55                   	push   %ebp
80104ca9:	89 e5                	mov    %esp,%ebp
80104cab:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104cae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cb5:	e9 d7 01 00 00       	jmp    80104e91 <apply_priority_boosting+0x1ed>
    if (!kernel_pstat.inuse[i]) continue;
80104cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbd:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104cc4:	85 c0                	test   %eax,%eax
80104cc6:	0f 84 c0 01 00 00    	je     80104e8c <apply_priority_boosting+0x1e8>
    int q = kernel_pstat.priority[i];
80104ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccf:	83 e8 80             	sub    $0xffffff80,%eax
80104cd2:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce9:	01 d0                	add    %edx,%eax
80104ceb:	05 00 02 00 00       	add    $0x200,%eax
80104cf0:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 2 && waited >= 80) {
80104cfa:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104cfe:	75 6d                	jne    80104d6d <apply_priority_boosting+0xc9>
80104d00:	83 7d ec 4f          	cmpl   $0x4f,-0x14(%ebp)
80104d04:	7e 67                	jle    80104d6d <apply_priority_boosting+0xc9>
      kernel_pstat.priority[i] = 3;
80104d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d09:	83 e8 80             	sub    $0xffffff80,%eax
80104d0c:	c7 04 85 20 59 19 80 	movl   $0x3,-0x7fe6a6e0(,%eax,4)
80104d13:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1a:	c1 e0 04             	shl    $0x4,%eax
80104d1d:	05 28 61 19 80       	add    $0x80196128,%eax
80104d22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2b:	83 c0 40             	add    $0x40,%eax
80104d2e:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104d35:	83 ec 04             	sub    $0x4,%esp
80104d38:	ff 75 ec             	push   -0x14(%ebp)
80104d3b:	50                   	push   %eax
80104d3c:	68 a0 b2 10 80       	push   $0x8010b2a0
80104d41:	e8 c6 b6 ff ff       	call   8010040c <cprintf>
80104d46:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4c:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104d4f:	83 c0 30             	add    $0x30,%eax
80104d52:	05 20 65 19 80       	add    $0x80196520,%eax
80104d57:	83 c0 04             	add    $0x4,%eax
80104d5a:	83 ec 08             	sub    $0x8,%esp
80104d5d:	6a 03                	push   $0x3
80104d5f:	50                   	push   %eax
80104d60:	e8 13 fe ff ff       	call   80104b78 <enqueue>
80104d65:	83 c4 10             	add    $0x10,%esp
80104d68:	e9 20 01 00 00       	jmp    80104e8d <apply_priority_boosting+0x1e9>
    } else if (q == 1 && waited >= 160) {
80104d6d:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104d71:	75 70                	jne    80104de3 <apply_priority_boosting+0x13f>
80104d73:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104d7a:	7e 67                	jle    80104de3 <apply_priority_boosting+0x13f>
      kernel_pstat.priority[i] = 2;
80104d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7f:	83 e8 80             	sub    $0xffffff80,%eax
80104d82:	c7 04 85 20 59 19 80 	movl   $0x2,-0x7fe6a6e0(,%eax,4)
80104d89:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d90:	c1 e0 04             	shl    $0x4,%eax
80104d93:	05 24 61 19 80       	add    $0x80196124,%eax
80104d98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da1:	83 c0 40             	add    $0x40,%eax
80104da4:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104dab:	83 ec 04             	sub    $0x4,%esp
80104dae:	ff 75 ec             	push   -0x14(%ebp)
80104db1:	50                   	push   %eax
80104db2:	68 c4 b2 10 80       	push   $0x8010b2c4
80104db7:	e8 50 b6 ff ff       	call   8010040c <cprintf>
80104dbc:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104dc5:	83 c0 30             	add    $0x30,%eax
80104dc8:	05 20 65 19 80       	add    $0x80196520,%eax
80104dcd:	83 c0 04             	add    $0x4,%eax
80104dd0:	83 ec 08             	sub    $0x8,%esp
80104dd3:	6a 02                	push   $0x2
80104dd5:	50                   	push   %eax
80104dd6:	e8 9d fd ff ff       	call   80104b78 <enqueue>
80104ddb:	83 c4 10             	add    $0x10,%esp
80104dde:	e9 aa 00 00 00       	jmp    80104e8d <apply_priority_boosting+0x1e9>
    } else if (q == 0 && waited >= 250) {
80104de3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104de7:	0f 85 a0 00 00 00    	jne    80104e8d <apply_priority_boosting+0x1e9>
80104ded:	81 7d ec f9 00 00 00 	cmpl   $0xf9,-0x14(%ebp)
80104df4:	0f 8e 93 00 00 00    	jle    80104e8d <apply_priority_boosting+0x1e9>
      int pid = kernel_pstat.pid[i];
80104dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfd:	83 c0 40             	add    $0x40,%eax
80104e00:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104e07:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0d:	83 c0 40             	add    $0x40,%eax
80104e10:	c1 e0 04             	shl    $0x4,%eax
80104e13:	05 20 59 19 80       	add    $0x80195920,%eax
80104e18:	8b 00                	mov    (%eax),%eax
80104e1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e20:	83 e8 80             	sub    $0xffffff80,%eax
80104e23:	c1 e0 04             	shl    $0x4,%eax
80104e26:	05 20 59 19 80       	add    $0x80195920,%eax
80104e2b:	8b 00                	mov    (%eax),%eax
80104e2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e33:	83 e8 80             	sub    $0xffffff80,%eax
80104e36:	c7 04 85 20 59 19 80 	movl   $0x1,-0x7fe6a6e0(,%eax,4)
80104e3d:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e44:	83 e8 80             	sub    $0xffffff80,%eax
80104e47:	c1 e0 04             	shl    $0x4,%eax
80104e4a:	05 20 59 19 80       	add    $0x80195920,%eax
80104e4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104e55:	ff 75 e4             	push   -0x1c(%ebp)
80104e58:	ff 75 e0             	push   -0x20(%ebp)
80104e5b:	ff 75 e8             	push   -0x18(%ebp)
80104e5e:	68 e8 b2 10 80       	push   $0x8010b2e8
80104e63:	e8 a4 b5 ff ff       	call   8010040c <cprintf>
80104e68:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104e71:	83 c0 30             	add    $0x30,%eax
80104e74:	05 20 65 19 80       	add    $0x80196520,%eax
80104e79:	83 c0 04             	add    $0x4,%eax
80104e7c:	83 ec 08             	sub    $0x8,%esp
80104e7f:	6a 01                	push   $0x1
80104e81:	50                   	push   %eax
80104e82:	e8 f1 fc ff ff       	call   80104b78 <enqueue>
80104e87:	83 c4 10             	add    $0x10,%esp
80104e8a:	eb 01                	jmp    80104e8d <apply_priority_boosting+0x1e9>
    if (!kernel_pstat.inuse[i]) continue;
80104e8c:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104e8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e91:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104e95:	0f 8e 1f fe ff ff    	jle    80104cba <apply_priority_boosting+0x16>
    }
  }
}
80104e9b:	90                   	nop
80104e9c:	90                   	nop
80104e9d:	c9                   	leave
80104e9e:	c3                   	ret

80104e9f <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104e9f:	f3 0f 1e fb          	endbr32
80104ea3:	55                   	push   %ebp
80104ea4:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104ea6:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104eaa:	75 07                	jne    80104eb3 <get_time_slice+0x14>
80104eac:	b8 08 00 00 00       	mov    $0x8,%eax
80104eb1:	eb 1f                	jmp    80104ed2 <get_time_slice+0x33>
  if (level == 2) return 16;
80104eb3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104eb7:	75 07                	jne    80104ec0 <get_time_slice+0x21>
80104eb9:	b8 10 00 00 00       	mov    $0x10,%eax
80104ebe:	eb 12                	jmp    80104ed2 <get_time_slice+0x33>
  if (level == 1) return 32;
80104ec0:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104ec4:	75 07                	jne    80104ecd <get_time_slice+0x2e>
80104ec6:	b8 20 00 00 00       	mov    $0x20,%eax
80104ecb:	eb 05                	jmp    80104ed2 <get_time_slice+0x33>
  return -1; // FIFO (Q0)
80104ecd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed2:	5d                   	pop    %ebp
80104ed3:	c3                   	ret

80104ed4 <run_process>:

void
run_process(struct proc* p, int q, int slice, int tracking) {
80104ed4:	f3 0f 1e fb          	endbr32
80104ed8:	55                   	push   %ebp
80104ed9:	89 e5                	mov    %esp,%ebp
80104edb:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104ede:	e8 4a ec ff ff       	call   80103b2d <mycpu>
80104ee3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee9:	8b 55 08             	mov    0x8(%ebp),%edx
80104eec:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104ef2:	83 ec 0c             	sub    $0xc,%esp
80104ef5:	ff 75 08             	push   0x8(%ebp)
80104ef8:	e8 e2 32 00 00       	call   801081df <switchuvm>
80104efd:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
80104f03:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
  int i = p - ptable.proc;
80104f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0d:	2d 54 65 19 80       	sub    $0x80196554,%eax
80104f12:	c1 f8 02             	sar    $0x2,%eax
80104f15:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104f1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
  swtch(&(c->scheduler), p->context);
80104f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f21:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f27:	83 c2 04             	add    $0x4,%edx
80104f2a:	83 ec 08             	sub    $0x8,%esp
80104f2d:	50                   	push   %eax
80104f2e:	52                   	push   %edx
80104f2f:	e8 f0 08 00 00       	call   80105824 <swtch>
80104f34:	83 c4 10             	add    $0x10,%esp
  switchkvm();
80104f37:	e8 86 32 00 00       	call   801081c2 <switchkvm>
  c->proc = 0;
80104f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104f46:	00 00 00 
  if (tracking) kernel_pstat.ticks[i][q]++;
80104f49:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80104f4d:	74 39                	je     80104f88 <run_process+0xb4>
80104f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5c:	01 d0                	add    %edx,%eax
80104f5e:	05 00 01 00 00       	add    $0x100,%eax
80104f63:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104f6a:	8d 50 01             	lea    0x1(%eax),%edx
80104f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f70:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104f77:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7a:	01 c8                	add    %ecx,%eax
80104f7c:	05 00 01 00 00       	add    $0x100,%eax
80104f81:	89 14 85 20 59 19 80 	mov    %edx,-0x7fe6a6e0(,%eax,4)
  if (slice != -1 && kernel_pstat.ticks[i][q] >= slice && q > 0) {
80104f88:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104f8c:	74 6f                	je     80104ffd <run_process+0x129>
80104f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9b:	01 d0                	add    %edx,%eax
80104f9d:	05 00 01 00 00       	add    $0x100,%eax
80104fa2:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80104fa9:	39 45 10             	cmp    %eax,0x10(%ebp)
80104fac:	7f 4f                	jg     80104ffd <run_process+0x129>
80104fae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fb2:	7e 49                	jle    80104ffd <run_process+0x129>
    kernel_pstat.priority[i] = q - 1;
80104fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb7:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbd:	83 e8 80             	sub    $0xffffff80,%eax
80104fc0:	89 14 85 20 59 19 80 	mov    %edx,-0x7fe6a6e0(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;
80104fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd4:	01 d0                	add    %edx,%eax
80104fd6:	05 00 01 00 00       	add    $0x100,%eax
80104fdb:	c7 04 85 20 59 19 80 	movl   $0x0,-0x7fe6a6e0(,%eax,4)
80104fe2:	00 00 00 00 
    enqueue(p, q - 1);
80104fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe9:	83 e8 01             	sub    $0x1,%eax
80104fec:	83 ec 08             	sub    $0x8,%esp
80104fef:	50                   	push   %eax
80104ff0:	ff 75 08             	push   0x8(%ebp)
80104ff3:	e8 80 fb ff ff       	call   80104b78 <enqueue>
80104ff8:	83 c4 10             	add    $0x10,%esp
  //cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
  } else {
  //  cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
80104ffb:	eb 17                	jmp    80105014 <run_process+0x140>
  } else if (q == 0) {
80104ffd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105001:	74 11                	je     80105014 <run_process+0x140>
    enqueue(p, q);
80105003:	83 ec 08             	sub    $0x8,%esp
80105006:	ff 75 0c             	push   0xc(%ebp)
80105009:	ff 75 08             	push   0x8(%ebp)
8010500c:	e8 67 fb ff ff       	call   80104b78 <enqueue>
80105011:	83 c4 10             	add    $0x10,%esp
}
80105014:	90                   	nop
80105015:	c9                   	leave
80105016:	c3                   	ret

80105017 <run_mlfq>:

// MLFQ 스케줄러 진입점
void
run_mlfq(int tracking, int boosting) {
80105017:	f3 0f 1e fb          	endbr32
8010501b:	55                   	push   %ebp
8010501c:	89 e5                	mov    %esp,%ebp
8010501e:	83 ec 28             	sub    $0x28,%esp
  if (boosting)
80105021:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105025:	74 05                	je     8010502c <run_mlfq+0x15>
    apply_priority_boosting();
80105027:	e8 78 fc ff ff       	call   80104ca4 <apply_priority_boosting>

  for (int q = 3; q >= 0; q--) {
8010502c:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
80105033:	eb 7c                	jmp    801050b1 <run_mlfq+0x9a>
    for (int i = 0; i < NPROC; i++) {
80105035:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010503c:	eb 69                	jmp    801050a7 <run_mlfq+0x90>
      struct proc *p = mlfq_queues[q][i];
8010503e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105041:	c1 e0 06             	shl    $0x6,%eax
80105044:	89 c2                	mov    %eax,%edx
80105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105049:	01 d0                	add    %edx,%eax
8010504b:	8b 04 85 20 55 19 80 	mov    -0x7fe6aae0(,%eax,4),%eax
80105052:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (p == 0 || p->state != RUNNABLE)
80105055:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80105059:	74 0b                	je     80105066 <run_mlfq+0x4f>
8010505b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010505e:	8b 40 0c             	mov    0xc(%eax),%eax
80105061:	83 f8 03             	cmp    $0x3,%eax
80105064:	74 06                	je     8010506c <run_mlfq+0x55>
    for (int i = 0; i < NPROC; i++) {
80105066:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010506a:	eb 3b                	jmp    801050a7 <run_mlfq+0x90>
        continue;
      if (q != 0)
8010506c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105070:	74 0e                	je     80105080 <run_mlfq+0x69>
        dequeue(q);
80105072:	83 ec 0c             	sub    $0xc,%esp
80105075:	ff 75 f4             	push   -0xc(%ebp)
80105078:	e8 7a fb ff ff       	call   80104bf7 <dequeue>
8010507d:	83 c4 10             	add    $0x10,%esp
      int slice = get_time_slice(q);
80105080:	83 ec 0c             	sub    $0xc,%esp
80105083:	ff 75 f4             	push   -0xc(%ebp)
80105086:	e8 14 fe ff ff       	call   80104e9f <get_time_slice>
8010508b:	83 c4 10             	add    $0x10,%esp
8010508e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice, tracking);
80105091:	ff 75 08             	push   0x8(%ebp)
80105094:	ff 75 e4             	push   -0x1c(%ebp)
80105097:	ff 75 f4             	push   -0xc(%ebp)
8010509a:	ff 75 e8             	push   -0x18(%ebp)
8010509d:	e8 32 fe ff ff       	call   80104ed4 <run_process>
801050a2:	83 c4 10             	add    $0x10,%esp
      goto tick_update;
801050a5:	eb 15                	jmp    801050bc <run_mlfq+0xa5>
    for (int i = 0; i < NPROC; i++) {
801050a7:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801050ab:	7e 91                	jle    8010503e <run_mlfq+0x27>
  for (int q = 3; q >= 0; q--) {
801050ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801050b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050b5:	0f 89 7a ff ff ff    	jns    80105035 <run_mlfq+0x1e>
    }
  }

tick_update:
801050bb:	90                   	nop
  if (!tracking) return;
801050bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801050c0:	0f 84 a5 00 00 00    	je     8010516b <run_mlfq+0x154>
  for (int i = 0; i < NPROC; i++) {
801050c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801050cd:	e9 8d 00 00 00       	jmp    8010515f <run_mlfq+0x148>
    struct proc* p = &ptable.proc[i];
801050d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
801050d8:	83 c0 30             	add    $0x30,%eax
801050db:	05 20 65 19 80       	add    $0x80196520,%eax
801050e0:	83 c0 04             	add    $0x4,%eax
801050e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
801050e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050e9:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
801050f0:	85 c0                	test   %eax,%eax
801050f2:	74 66                	je     8010515a <run_mlfq+0x143>
    if (p->state == RUNNABLE && p != mycpu()->proc) {
801050f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050f7:	8b 40 0c             	mov    0xc(%eax),%eax
801050fa:	83 f8 03             	cmp    $0x3,%eax
801050fd:	75 5c                	jne    8010515b <run_mlfq+0x144>
801050ff:	e8 29 ea ff ff       	call   80103b2d <mycpu>
80105104:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010510a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010510d:	74 4c                	je     8010515b <run_mlfq+0x144>
      int q = kernel_pstat.priority[i];
8010510f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105112:	83 e8 80             	sub    $0xffffff80,%eax
80105115:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
8010511c:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
8010511f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105122:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105129:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010512c:	01 d0                	add    %edx,%eax
8010512e:	05 00 02 00 00       	add    $0x200,%eax
80105133:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
8010513a:	8d 50 01             	lea    0x1(%eax),%edx
8010513d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105140:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80105147:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010514a:	01 c8                	add    %ecx,%eax
8010514c:	05 00 02 00 00       	add    $0x200,%eax
80105151:	89 14 85 20 59 19 80 	mov    %edx,-0x7fe6a6e0(,%eax,4)
80105158:	eb 01                	jmp    8010515b <run_mlfq+0x144>
    if (!kernel_pstat.inuse[i]) continue;
8010515a:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
8010515b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010515f:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80105163:	0f 8e 69 ff ff ff    	jle    801050d2 <run_mlfq+0xbb>
80105169:	eb 01                	jmp    8010516c <run_mlfq+0x155>
  if (!tracking) return;
8010516b:	90                   	nop
    }
  }
8010516c:	c9                   	leave
8010516d:	c3                   	ret

8010516e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010516e:	f3 0f 1e fb          	endbr32
80105172:	55                   	push   %ebp
80105173:	89 e5                	mov    %esp,%ebp
80105175:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105178:	8b 45 08             	mov    0x8(%ebp),%eax
8010517b:	83 c0 04             	add    $0x4,%eax
8010517e:	83 ec 08             	sub    $0x8,%esp
80105181:	68 40 b3 10 80       	push   $0x8010b340
80105186:	50                   	push   %eax
80105187:	e8 4f 01 00 00       	call   801052db <initlock>
8010518c:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010518f:	8b 45 08             	mov    0x8(%ebp),%eax
80105192:	8b 55 0c             	mov    0xc(%ebp),%edx
80105195:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105198:	8b 45 08             	mov    0x8(%ebp),%eax
8010519b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051a1:	8b 45 08             	mov    0x8(%ebp),%eax
801051a4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801051ab:	90                   	nop
801051ac:	c9                   	leave
801051ad:	c3                   	ret

801051ae <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801051ae:	f3 0f 1e fb          	endbr32
801051b2:	55                   	push   %ebp
801051b3:	89 e5                	mov    %esp,%ebp
801051b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051b8:	8b 45 08             	mov    0x8(%ebp),%eax
801051bb:	83 c0 04             	add    $0x4,%eax
801051be:	83 ec 0c             	sub    $0xc,%esp
801051c1:	50                   	push   %eax
801051c2:	e8 3a 01 00 00       	call   80105301 <acquire>
801051c7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051ca:	eb 15                	jmp    801051e1 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	83 c0 04             	add    $0x4,%eax
801051d2:	83 ec 08             	sub    $0x8,%esp
801051d5:	50                   	push   %eax
801051d6:	ff 75 08             	push   0x8(%ebp)
801051d9:	e8 9f f4 ff ff       	call   8010467d <sleep>
801051de:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801051e1:	8b 45 08             	mov    0x8(%ebp),%eax
801051e4:	8b 00                	mov    (%eax),%eax
801051e6:	85 c0                	test   %eax,%eax
801051e8:	75 e2                	jne    801051cc <acquiresleep+0x1e>
  }
  lk->locked = 1;
801051ea:	8b 45 08             	mov    0x8(%ebp),%eax
801051ed:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051f3:	e8 b1 e9 ff ff       	call   80103ba9 <myproc>
801051f8:	8b 50 10             	mov    0x10(%eax),%edx
801051fb:	8b 45 08             	mov    0x8(%ebp),%eax
801051fe:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105201:	8b 45 08             	mov    0x8(%ebp),%eax
80105204:	83 c0 04             	add    $0x4,%eax
80105207:	83 ec 0c             	sub    $0xc,%esp
8010520a:	50                   	push   %eax
8010520b:	e8 63 01 00 00       	call   80105373 <release>
80105210:	83 c4 10             	add    $0x10,%esp
}
80105213:	90                   	nop
80105214:	c9                   	leave
80105215:	c3                   	ret

80105216 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105216:	f3 0f 1e fb          	endbr32
8010521a:	55                   	push   %ebp
8010521b:	89 e5                	mov    %esp,%ebp
8010521d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105220:	8b 45 08             	mov    0x8(%ebp),%eax
80105223:	83 c0 04             	add    $0x4,%eax
80105226:	83 ec 0c             	sub    $0xc,%esp
80105229:	50                   	push   %eax
8010522a:	e8 d2 00 00 00       	call   80105301 <acquire>
8010522f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010523b:	8b 45 08             	mov    0x8(%ebp),%eax
8010523e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105245:	83 ec 0c             	sub    $0xc,%esp
80105248:	ff 75 08             	push   0x8(%ebp)
8010524b:	e8 2c f5 ff ff       	call   8010477c <wakeup>
80105250:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105253:	8b 45 08             	mov    0x8(%ebp),%eax
80105256:	83 c0 04             	add    $0x4,%eax
80105259:	83 ec 0c             	sub    $0xc,%esp
8010525c:	50                   	push   %eax
8010525d:	e8 11 01 00 00       	call   80105373 <release>
80105262:	83 c4 10             	add    $0x10,%esp
}
80105265:	90                   	nop
80105266:	c9                   	leave
80105267:	c3                   	ret

80105268 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105268:	f3 0f 1e fb          	endbr32
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
8010526f:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105272:	8b 45 08             	mov    0x8(%ebp),%eax
80105275:	83 c0 04             	add    $0x4,%eax
80105278:	83 ec 0c             	sub    $0xc,%esp
8010527b:	50                   	push   %eax
8010527c:	e8 80 00 00 00       	call   80105301 <acquire>
80105281:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105284:	8b 45 08             	mov    0x8(%ebp),%eax
80105287:	8b 00                	mov    (%eax),%eax
80105289:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010528c:	8b 45 08             	mov    0x8(%ebp),%eax
8010528f:	83 c0 04             	add    $0x4,%eax
80105292:	83 ec 0c             	sub    $0xc,%esp
80105295:	50                   	push   %eax
80105296:	e8 d8 00 00 00       	call   80105373 <release>
8010529b:	83 c4 10             	add    $0x10,%esp
  return r;
8010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052a1:	c9                   	leave
801052a2:	c3                   	ret

801052a3 <readeflags>:
{
801052a3:	55                   	push   %ebp
801052a4:	89 e5                	mov    %esp,%ebp
801052a6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801052a9:	9c                   	pushf
801052aa:	58                   	pop    %eax
801052ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052b1:	c9                   	leave
801052b2:	c3                   	ret

801052b3 <cli>:
{
801052b3:	55                   	push   %ebp
801052b4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052b6:	fa                   	cli
}
801052b7:	90                   	nop
801052b8:	5d                   	pop    %ebp
801052b9:	c3                   	ret

801052ba <sti>:
{
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052bd:	fb                   	sti
}
801052be:	90                   	nop
801052bf:	5d                   	pop    %ebp
801052c0:	c3                   	ret

801052c1 <xchg>:
{
801052c1:	55                   	push   %ebp
801052c2:	89 e5                	mov    %esp,%ebp
801052c4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052c7:	8b 55 08             	mov    0x8(%ebp),%edx
801052ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052d0:	f0 87 02             	lock xchg %eax,(%edx)
801052d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052d9:	c9                   	leave
801052da:	c3                   	ret

801052db <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052db:	f3 0f 1e fb          	endbr32
801052df:	55                   	push   %ebp
801052e0:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801052e8:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052eb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052f4:	8b 45 08             	mov    0x8(%ebp),%eax
801052f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052fe:	90                   	nop
801052ff:	5d                   	pop    %ebp
80105300:	c3                   	ret

80105301 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105301:	f3 0f 1e fb          	endbr32
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	53                   	push   %ebx
80105309:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010530c:	e8 6c 01 00 00       	call   8010547d <pushcli>
  if(holding(lk)){
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
80105314:	83 ec 0c             	sub    $0xc,%esp
80105317:	50                   	push   %eax
80105318:	e8 2b 01 00 00       	call   80105448 <holding>
8010531d:	83 c4 10             	add    $0x10,%esp
80105320:	85 c0                	test   %eax,%eax
80105322:	74 0d                	je     80105331 <acquire+0x30>
    panic("acquire");
80105324:	83 ec 0c             	sub    $0xc,%esp
80105327:	68 4b b3 10 80       	push   $0x8010b34b
8010532c:	e8 94 b2 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105331:	90                   	nop
80105332:	8b 45 08             	mov    0x8(%ebp),%eax
80105335:	83 ec 08             	sub    $0x8,%esp
80105338:	6a 01                	push   $0x1
8010533a:	50                   	push   %eax
8010533b:	e8 81 ff ff ff       	call   801052c1 <xchg>
80105340:	83 c4 10             	add    $0x10,%esp
80105343:	85 c0                	test   %eax,%eax
80105345:	75 eb                	jne    80105332 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105347:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010534c:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010534f:	e8 d9 e7 ff ff       	call   80103b2d <mycpu>
80105354:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105357:	8b 45 08             	mov    0x8(%ebp),%eax
8010535a:	83 c0 0c             	add    $0xc,%eax
8010535d:	83 ec 08             	sub    $0x8,%esp
80105360:	50                   	push   %eax
80105361:	8d 45 08             	lea    0x8(%ebp),%eax
80105364:	50                   	push   %eax
80105365:	e8 5f 00 00 00       	call   801053c9 <getcallerpcs>
8010536a:	83 c4 10             	add    $0x10,%esp
}
8010536d:	90                   	nop
8010536e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105371:	c9                   	leave
80105372:	c3                   	ret

80105373 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105373:	f3 0f 1e fb          	endbr32
80105377:	55                   	push   %ebp
80105378:	89 e5                	mov    %esp,%ebp
8010537a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010537d:	83 ec 0c             	sub    $0xc,%esp
80105380:	ff 75 08             	push   0x8(%ebp)
80105383:	e8 c0 00 00 00       	call   80105448 <holding>
80105388:	83 c4 10             	add    $0x10,%esp
8010538b:	85 c0                	test   %eax,%eax
8010538d:	75 0d                	jne    8010539c <release+0x29>
    panic("release");
8010538f:	83 ec 0c             	sub    $0xc,%esp
80105392:	68 53 b3 10 80       	push   $0x8010b353
80105397:	e8 29 b2 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053a6:	8b 45 08             	mov    0x8(%ebp),%eax
801053a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801053b0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801053b5:	8b 45 08             	mov    0x8(%ebp),%eax
801053b8:	8b 55 08             	mov    0x8(%ebp),%edx
801053bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053c1:	e8 08 01 00 00       	call   801054ce <popcli>
}
801053c6:	90                   	nop
801053c7:	c9                   	leave
801053c8:	c3                   	ret

801053c9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053c9:	f3 0f 1e fb          	endbr32
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
801053d0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053d3:	8b 45 08             	mov    0x8(%ebp),%eax
801053d6:	83 e8 08             	sub    $0x8,%eax
801053d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053dc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053e3:	eb 38                	jmp    8010541d <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053e5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053e9:	74 53                	je     8010543e <getcallerpcs+0x75>
801053eb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053f2:	76 4a                	jbe    8010543e <getcallerpcs+0x75>
801053f4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053f8:	74 44                	je     8010543e <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105404:	8b 45 0c             	mov    0xc(%ebp),%eax
80105407:	01 c2                	add    %eax,%edx
80105409:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010540c:	8b 40 04             	mov    0x4(%eax),%eax
8010540f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105414:	8b 00                	mov    (%eax),%eax
80105416:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105419:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010541d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105421:	7e c2                	jle    801053e5 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105423:	eb 19                	jmp    8010543e <getcallerpcs+0x75>
    pcs[i] = 0;
80105425:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105428:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010542f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105432:	01 d0                	add    %edx,%eax
80105434:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010543a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010543e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105442:	7e e1                	jle    80105425 <getcallerpcs+0x5c>
}
80105444:	90                   	nop
80105445:	90                   	nop
80105446:	c9                   	leave
80105447:	c3                   	ret

80105448 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105448:	f3 0f 1e fb          	endbr32
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	53                   	push   %ebx
80105450:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	8b 00                	mov    (%eax),%eax
80105458:	85 c0                	test   %eax,%eax
8010545a:	74 16                	je     80105472 <holding+0x2a>
8010545c:	8b 45 08             	mov    0x8(%ebp),%eax
8010545f:	8b 58 08             	mov    0x8(%eax),%ebx
80105462:	e8 c6 e6 ff ff       	call   80103b2d <mycpu>
80105467:	39 c3                	cmp    %eax,%ebx
80105469:	75 07                	jne    80105472 <holding+0x2a>
8010546b:	b8 01 00 00 00       	mov    $0x1,%eax
80105470:	eb 05                	jmp    80105477 <holding+0x2f>
80105472:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105477:	83 c4 04             	add    $0x4,%esp
8010547a:	5b                   	pop    %ebx
8010547b:	5d                   	pop    %ebp
8010547c:	c3                   	ret

8010547d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010547d:	f3 0f 1e fb          	endbr32
80105481:	55                   	push   %ebp
80105482:	89 e5                	mov    %esp,%ebp
80105484:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105487:	e8 17 fe ff ff       	call   801052a3 <readeflags>
8010548c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010548f:	e8 1f fe ff ff       	call   801052b3 <cli>
  if(mycpu()->ncli == 0)
80105494:	e8 94 e6 ff ff       	call   80103b2d <mycpu>
80105499:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010549f:	85 c0                	test   %eax,%eax
801054a1:	75 14                	jne    801054b7 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801054a3:	e8 85 e6 ff ff       	call   80103b2d <mycpu>
801054a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ab:	81 e2 00 02 00 00    	and    $0x200,%edx
801054b1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054b7:	e8 71 e6 ff ff       	call   80103b2d <mycpu>
801054bc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054c2:	83 c2 01             	add    $0x1,%edx
801054c5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054cb:	90                   	nop
801054cc:	c9                   	leave
801054cd:	c3                   	ret

801054ce <popcli>:

void
popcli(void)
{
801054ce:	f3 0f 1e fb          	endbr32
801054d2:	55                   	push   %ebp
801054d3:	89 e5                	mov    %esp,%ebp
801054d5:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054d8:	e8 c6 fd ff ff       	call   801052a3 <readeflags>
801054dd:	25 00 02 00 00       	and    $0x200,%eax
801054e2:	85 c0                	test   %eax,%eax
801054e4:	74 0d                	je     801054f3 <popcli+0x25>
    panic("popcli - interruptible");
801054e6:	83 ec 0c             	sub    $0xc,%esp
801054e9:	68 5b b3 10 80       	push   $0x8010b35b
801054ee:	e8 d2 b0 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
801054f3:	e8 35 e6 ff ff       	call   80103b2d <mycpu>
801054f8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054fe:	83 ea 01             	sub    $0x1,%edx
80105501:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105507:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010550d:	85 c0                	test   %eax,%eax
8010550f:	79 0d                	jns    8010551e <popcli+0x50>
    panic("popcli");
80105511:	83 ec 0c             	sub    $0xc,%esp
80105514:	68 72 b3 10 80       	push   $0x8010b372
80105519:	e8 a7 b0 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010551e:	e8 0a e6 ff ff       	call   80103b2d <mycpu>
80105523:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105529:	85 c0                	test   %eax,%eax
8010552b:	75 14                	jne    80105541 <popcli+0x73>
8010552d:	e8 fb e5 ff ff       	call   80103b2d <mycpu>
80105532:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105538:	85 c0                	test   %eax,%eax
8010553a:	74 05                	je     80105541 <popcli+0x73>
    sti();
8010553c:	e8 79 fd ff ff       	call   801052ba <sti>
}
80105541:	90                   	nop
80105542:	c9                   	leave
80105543:	c3                   	ret

80105544 <stosb>:
{
80105544:	55                   	push   %ebp
80105545:	89 e5                	mov    %esp,%ebp
80105547:	57                   	push   %edi
80105548:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105549:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010554c:	8b 55 10             	mov    0x10(%ebp),%edx
8010554f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105552:	89 cb                	mov    %ecx,%ebx
80105554:	89 df                	mov    %ebx,%edi
80105556:	89 d1                	mov    %edx,%ecx
80105558:	fc                   	cld
80105559:	f3 aa                	rep stos %al,%es:(%edi)
8010555b:	89 ca                	mov    %ecx,%edx
8010555d:	89 fb                	mov    %edi,%ebx
8010555f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105562:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105565:	90                   	nop
80105566:	5b                   	pop    %ebx
80105567:	5f                   	pop    %edi
80105568:	5d                   	pop    %ebp
80105569:	c3                   	ret

8010556a <stosl>:
{
8010556a:	55                   	push   %ebp
8010556b:	89 e5                	mov    %esp,%ebp
8010556d:	57                   	push   %edi
8010556e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010556f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105572:	8b 55 10             	mov    0x10(%ebp),%edx
80105575:	8b 45 0c             	mov    0xc(%ebp),%eax
80105578:	89 cb                	mov    %ecx,%ebx
8010557a:	89 df                	mov    %ebx,%edi
8010557c:	89 d1                	mov    %edx,%ecx
8010557e:	fc                   	cld
8010557f:	f3 ab                	rep stos %eax,%es:(%edi)
80105581:	89 ca                	mov    %ecx,%edx
80105583:	89 fb                	mov    %edi,%ebx
80105585:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105588:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010558b:	90                   	nop
8010558c:	5b                   	pop    %ebx
8010558d:	5f                   	pop    %edi
8010558e:	5d                   	pop    %ebp
8010558f:	c3                   	ret

80105590 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105590:	f3 0f 1e fb          	endbr32
80105594:	55                   	push   %ebp
80105595:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105597:	8b 45 08             	mov    0x8(%ebp),%eax
8010559a:	83 e0 03             	and    $0x3,%eax
8010559d:	85 c0                	test   %eax,%eax
8010559f:	75 43                	jne    801055e4 <memset+0x54>
801055a1:	8b 45 10             	mov    0x10(%ebp),%eax
801055a4:	83 e0 03             	and    $0x3,%eax
801055a7:	85 c0                	test   %eax,%eax
801055a9:	75 39                	jne    801055e4 <memset+0x54>
    c &= 0xFF;
801055ab:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055b2:	8b 45 10             	mov    0x10(%ebp),%eax
801055b5:	c1 e8 02             	shr    $0x2,%eax
801055b8:	89 c1                	mov    %eax,%ecx
801055ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801055bd:	c1 e0 18             	shl    $0x18,%eax
801055c0:	89 c2                	mov    %eax,%edx
801055c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c5:	c1 e0 10             	shl    $0x10,%eax
801055c8:	09 c2                	or     %eax,%edx
801055ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cd:	c1 e0 08             	shl    $0x8,%eax
801055d0:	09 d0                	or     %edx,%eax
801055d2:	0b 45 0c             	or     0xc(%ebp),%eax
801055d5:	51                   	push   %ecx
801055d6:	50                   	push   %eax
801055d7:	ff 75 08             	push   0x8(%ebp)
801055da:	e8 8b ff ff ff       	call   8010556a <stosl>
801055df:	83 c4 0c             	add    $0xc,%esp
801055e2:	eb 12                	jmp    801055f6 <memset+0x66>
  } else
    stosb(dst, c, n);
801055e4:	8b 45 10             	mov    0x10(%ebp),%eax
801055e7:	50                   	push   %eax
801055e8:	ff 75 0c             	push   0xc(%ebp)
801055eb:	ff 75 08             	push   0x8(%ebp)
801055ee:	e8 51 ff ff ff       	call   80105544 <stosb>
801055f3:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055f9:	c9                   	leave
801055fa:	c3                   	ret

801055fb <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055fb:	f3 0f 1e fb          	endbr32
801055ff:	55                   	push   %ebp
80105600:	89 e5                	mov    %esp,%ebp
80105602:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105605:	8b 45 08             	mov    0x8(%ebp),%eax
80105608:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010560b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105611:	eb 30                	jmp    80105643 <memcmp+0x48>
    if(*s1 != *s2)
80105613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105616:	0f b6 10             	movzbl (%eax),%edx
80105619:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010561c:	0f b6 00             	movzbl (%eax),%eax
8010561f:	38 c2                	cmp    %al,%dl
80105621:	74 18                	je     8010563b <memcmp+0x40>
      return *s1 - *s2;
80105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105626:	0f b6 00             	movzbl (%eax),%eax
80105629:	0f b6 d0             	movzbl %al,%edx
8010562c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010562f:	0f b6 00             	movzbl (%eax),%eax
80105632:	0f b6 c0             	movzbl %al,%eax
80105635:	29 c2                	sub    %eax,%edx
80105637:	89 d0                	mov    %edx,%eax
80105639:	eb 1a                	jmp    80105655 <memcmp+0x5a>
    s1++, s2++;
8010563b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010563f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105643:	8b 45 10             	mov    0x10(%ebp),%eax
80105646:	8d 50 ff             	lea    -0x1(%eax),%edx
80105649:	89 55 10             	mov    %edx,0x10(%ebp)
8010564c:	85 c0                	test   %eax,%eax
8010564e:	75 c3                	jne    80105613 <memcmp+0x18>
  }

  return 0;
80105650:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105655:	c9                   	leave
80105656:	c3                   	ret

80105657 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105657:	f3 0f 1e fb          	endbr32
8010565b:	55                   	push   %ebp
8010565c:	89 e5                	mov    %esp,%ebp
8010565e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105661:	8b 45 0c             	mov    0xc(%ebp),%eax
80105664:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105667:	8b 45 08             	mov    0x8(%ebp),%eax
8010566a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010566d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105670:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105673:	73 54                	jae    801056c9 <memmove+0x72>
80105675:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105678:	8b 45 10             	mov    0x10(%ebp),%eax
8010567b:	01 d0                	add    %edx,%eax
8010567d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105680:	73 47                	jae    801056c9 <memmove+0x72>
    s += n;
80105682:	8b 45 10             	mov    0x10(%ebp),%eax
80105685:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105688:	8b 45 10             	mov    0x10(%ebp),%eax
8010568b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010568e:	eb 13                	jmp    801056a3 <memmove+0x4c>
      *--d = *--s;
80105690:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105694:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569b:	0f b6 10             	movzbl (%eax),%edx
8010569e:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056a3:	8b 45 10             	mov    0x10(%ebp),%eax
801056a6:	8d 50 ff             	lea    -0x1(%eax),%edx
801056a9:	89 55 10             	mov    %edx,0x10(%ebp)
801056ac:	85 c0                	test   %eax,%eax
801056ae:	75 e0                	jne    80105690 <memmove+0x39>
  if(s < d && s + n > d){
801056b0:	eb 24                	jmp    801056d6 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056b5:	8d 42 01             	lea    0x1(%edx),%eax
801056b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056be:	8d 48 01             	lea    0x1(%eax),%ecx
801056c1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056c4:	0f b6 12             	movzbl (%edx),%edx
801056c7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056c9:	8b 45 10             	mov    0x10(%ebp),%eax
801056cc:	8d 50 ff             	lea    -0x1(%eax),%edx
801056cf:	89 55 10             	mov    %edx,0x10(%ebp)
801056d2:	85 c0                	test   %eax,%eax
801056d4:	75 dc                	jne    801056b2 <memmove+0x5b>

  return dst;
801056d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056d9:	c9                   	leave
801056da:	c3                   	ret

801056db <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056db:	f3 0f 1e fb          	endbr32
801056df:	55                   	push   %ebp
801056e0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056e2:	ff 75 10             	push   0x10(%ebp)
801056e5:	ff 75 0c             	push   0xc(%ebp)
801056e8:	ff 75 08             	push   0x8(%ebp)
801056eb:	e8 67 ff ff ff       	call   80105657 <memmove>
801056f0:	83 c4 0c             	add    $0xc,%esp
}
801056f3:	c9                   	leave
801056f4:	c3                   	ret

801056f5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056f5:	f3 0f 1e fb          	endbr32
801056f9:	55                   	push   %ebp
801056fa:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056fc:	eb 0c                	jmp    8010570a <strncmp+0x15>
    n--, p++, q++;
801056fe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105702:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105706:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010570a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010570e:	74 1a                	je     8010572a <strncmp+0x35>
80105710:	8b 45 08             	mov    0x8(%ebp),%eax
80105713:	0f b6 00             	movzbl (%eax),%eax
80105716:	84 c0                	test   %al,%al
80105718:	74 10                	je     8010572a <strncmp+0x35>
8010571a:	8b 45 08             	mov    0x8(%ebp),%eax
8010571d:	0f b6 10             	movzbl (%eax),%edx
80105720:	8b 45 0c             	mov    0xc(%ebp),%eax
80105723:	0f b6 00             	movzbl (%eax),%eax
80105726:	38 c2                	cmp    %al,%dl
80105728:	74 d4                	je     801056fe <strncmp+0x9>
  if(n == 0)
8010572a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010572e:	75 07                	jne    80105737 <strncmp+0x42>
    return 0;
80105730:	b8 00 00 00 00       	mov    $0x0,%eax
80105735:	eb 16                	jmp    8010574d <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105737:	8b 45 08             	mov    0x8(%ebp),%eax
8010573a:	0f b6 00             	movzbl (%eax),%eax
8010573d:	0f b6 d0             	movzbl %al,%edx
80105740:	8b 45 0c             	mov    0xc(%ebp),%eax
80105743:	0f b6 00             	movzbl (%eax),%eax
80105746:	0f b6 c0             	movzbl %al,%eax
80105749:	29 c2                	sub    %eax,%edx
8010574b:	89 d0                	mov    %edx,%eax
}
8010574d:	5d                   	pop    %ebp
8010574e:	c3                   	ret

8010574f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010574f:	f3 0f 1e fb          	endbr32
80105753:	55                   	push   %ebp
80105754:	89 e5                	mov    %esp,%ebp
80105756:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105759:	8b 45 08             	mov    0x8(%ebp),%eax
8010575c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010575f:	90                   	nop
80105760:	8b 45 10             	mov    0x10(%ebp),%eax
80105763:	8d 50 ff             	lea    -0x1(%eax),%edx
80105766:	89 55 10             	mov    %edx,0x10(%ebp)
80105769:	85 c0                	test   %eax,%eax
8010576b:	7e 2c                	jle    80105799 <strncpy+0x4a>
8010576d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105770:	8d 42 01             	lea    0x1(%edx),%eax
80105773:	89 45 0c             	mov    %eax,0xc(%ebp)
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	8d 48 01             	lea    0x1(%eax),%ecx
8010577c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010577f:	0f b6 12             	movzbl (%edx),%edx
80105782:	88 10                	mov    %dl,(%eax)
80105784:	0f b6 00             	movzbl (%eax),%eax
80105787:	84 c0                	test   %al,%al
80105789:	75 d5                	jne    80105760 <strncpy+0x11>
    ;
  while(n-- > 0)
8010578b:	eb 0c                	jmp    80105799 <strncpy+0x4a>
    *s++ = 0;
8010578d:	8b 45 08             	mov    0x8(%ebp),%eax
80105790:	8d 50 01             	lea    0x1(%eax),%edx
80105793:	89 55 08             	mov    %edx,0x8(%ebp)
80105796:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105799:	8b 45 10             	mov    0x10(%ebp),%eax
8010579c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010579f:	89 55 10             	mov    %edx,0x10(%ebp)
801057a2:	85 c0                	test   %eax,%eax
801057a4:	7f e7                	jg     8010578d <strncpy+0x3e>
  return os;
801057a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057a9:	c9                   	leave
801057aa:	c3                   	ret

801057ab <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057ab:	f3 0f 1e fb          	endbr32
801057af:	55                   	push   %ebp
801057b0:	89 e5                	mov    %esp,%ebp
801057b2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057b5:	8b 45 08             	mov    0x8(%ebp),%eax
801057b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057bf:	7f 05                	jg     801057c6 <safestrcpy+0x1b>
    return os;
801057c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c4:	eb 31                	jmp    801057f7 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057c6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057ce:	7e 1e                	jle    801057ee <safestrcpy+0x43>
801057d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801057d3:	8d 42 01             	lea    0x1(%edx),%eax
801057d6:	89 45 0c             	mov    %eax,0xc(%ebp)
801057d9:	8b 45 08             	mov    0x8(%ebp),%eax
801057dc:	8d 48 01             	lea    0x1(%eax),%ecx
801057df:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057e2:	0f b6 12             	movzbl (%edx),%edx
801057e5:	88 10                	mov    %dl,(%eax)
801057e7:	0f b6 00             	movzbl (%eax),%eax
801057ea:	84 c0                	test   %al,%al
801057ec:	75 d8                	jne    801057c6 <safestrcpy+0x1b>
    ;
  *s = 0;
801057ee:	8b 45 08             	mov    0x8(%ebp),%eax
801057f1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057f7:	c9                   	leave
801057f8:	c3                   	ret

801057f9 <strlen>:

int
strlen(const char *s)
{
801057f9:	f3 0f 1e fb          	endbr32
801057fd:	55                   	push   %ebp
801057fe:	89 e5                	mov    %esp,%ebp
80105800:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105803:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010580a:	eb 04                	jmp    80105810 <strlen+0x17>
8010580c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105810:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105813:	8b 45 08             	mov    0x8(%ebp),%eax
80105816:	01 d0                	add    %edx,%eax
80105818:	0f b6 00             	movzbl (%eax),%eax
8010581b:	84 c0                	test   %al,%al
8010581d:	75 ed                	jne    8010580c <strlen+0x13>
    ;
  return n;
8010581f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105822:	c9                   	leave
80105823:	c3                   	ret

80105824 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105824:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105828:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010582c:	55                   	push   %ebp
  pushl %ebx
8010582d:	53                   	push   %ebx
  pushl %esi
8010582e:	56                   	push   %esi
  pushl %edi
8010582f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105830:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105832:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105834:	5f                   	pop    %edi
  popl %esi
80105835:	5e                   	pop    %esi
  popl %ebx
80105836:	5b                   	pop    %ebx
  popl %ebp
80105837:	5d                   	pop    %ebp
  ret
80105838:	c3                   	ret

80105839 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105839:	f3 0f 1e fb          	endbr32
8010583d:	55                   	push   %ebp
8010583e:	89 e5                	mov    %esp,%ebp
80105840:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105843:	e8 61 e3 ff ff       	call   80103ba9 <myproc>
80105848:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010584b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584e:	8b 00                	mov    (%eax),%eax
80105850:	39 45 08             	cmp    %eax,0x8(%ebp)
80105853:	73 0f                	jae    80105864 <fetchint+0x2b>
80105855:	8b 45 08             	mov    0x8(%ebp),%eax
80105858:	8d 50 04             	lea    0x4(%eax),%edx
8010585b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585e:	8b 00                	mov    (%eax),%eax
80105860:	39 c2                	cmp    %eax,%edx
80105862:	76 07                	jbe    8010586b <fetchint+0x32>
    return -1;
80105864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105869:	eb 0f                	jmp    8010587a <fetchint+0x41>
  *ip = *(int*)(addr);
8010586b:	8b 45 08             	mov    0x8(%ebp),%eax
8010586e:	8b 10                	mov    (%eax),%edx
80105870:	8b 45 0c             	mov    0xc(%ebp),%eax
80105873:	89 10                	mov    %edx,(%eax)
  return 0;
80105875:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010587a:	c9                   	leave
8010587b:	c3                   	ret

8010587c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010587c:	f3 0f 1e fb          	endbr32
80105880:	55                   	push   %ebp
80105881:	89 e5                	mov    %esp,%ebp
80105883:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105886:	e8 1e e3 ff ff       	call   80103ba9 <myproc>
8010588b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010588e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105891:	8b 00                	mov    (%eax),%eax
80105893:	39 45 08             	cmp    %eax,0x8(%ebp)
80105896:	72 07                	jb     8010589f <fetchstr+0x23>
    return -1;
80105898:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589d:	eb 43                	jmp    801058e2 <fetchstr+0x66>
  *pp = (char*)addr;
8010589f:	8b 55 08             	mov    0x8(%ebp),%edx
801058a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058a5:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801058a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058aa:	8b 00                	mov    (%eax),%eax
801058ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058af:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b2:	8b 00                	mov    (%eax),%eax
801058b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b7:	eb 1c                	jmp    801058d5 <fetchstr+0x59>
    if(*s == 0)
801058b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bc:	0f b6 00             	movzbl (%eax),%eax
801058bf:	84 c0                	test   %al,%al
801058c1:	75 0e                	jne    801058d1 <fetchstr+0x55>
      return s - *pp;
801058c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c6:	8b 00                	mov    (%eax),%eax
801058c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058cb:	29 c2                	sub    %eax,%edx
801058cd:	89 d0                	mov    %edx,%eax
801058cf:	eb 11                	jmp    801058e2 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058db:	72 dc                	jb     801058b9 <fetchstr+0x3d>
  }
  return -1;
801058dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058e2:	c9                   	leave
801058e3:	c3                   	ret

801058e4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058e4:	f3 0f 1e fb          	endbr32
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058ee:	e8 b6 e2 ff ff       	call   80103ba9 <myproc>
801058f3:	8b 40 18             	mov    0x18(%eax),%eax
801058f6:	8b 40 44             	mov    0x44(%eax),%eax
801058f9:	8b 55 08             	mov    0x8(%ebp),%edx
801058fc:	c1 e2 02             	shl    $0x2,%edx
801058ff:	01 d0                	add    %edx,%eax
80105901:	83 c0 04             	add    $0x4,%eax
80105904:	83 ec 08             	sub    $0x8,%esp
80105907:	ff 75 0c             	push   0xc(%ebp)
8010590a:	50                   	push   %eax
8010590b:	e8 29 ff ff ff       	call   80105839 <fetchint>
80105910:	83 c4 10             	add    $0x10,%esp
}
80105913:	c9                   	leave
80105914:	c3                   	ret

80105915 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105915:	f3 0f 1e fb          	endbr32
80105919:	55                   	push   %ebp
8010591a:	89 e5                	mov    %esp,%ebp
8010591c:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010591f:	e8 85 e2 ff ff       	call   80103ba9 <myproc>
80105924:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105927:	83 ec 08             	sub    $0x8,%esp
8010592a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592d:	50                   	push   %eax
8010592e:	ff 75 08             	push   0x8(%ebp)
80105931:	e8 ae ff ff ff       	call   801058e4 <argint>
80105936:	83 c4 10             	add    $0x10,%esp
80105939:	85 c0                	test   %eax,%eax
8010593b:	79 07                	jns    80105944 <argptr+0x2f>
    return -1;
8010593d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105942:	eb 3b                	jmp    8010597f <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105944:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105948:	78 1f                	js     80105969 <argptr+0x54>
8010594a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594d:	8b 00                	mov    (%eax),%eax
8010594f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105952:	39 d0                	cmp    %edx,%eax
80105954:	76 13                	jbe    80105969 <argptr+0x54>
80105956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105959:	89 c2                	mov    %eax,%edx
8010595b:	8b 45 10             	mov    0x10(%ebp),%eax
8010595e:	01 c2                	add    %eax,%edx
80105960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105963:	8b 00                	mov    (%eax),%eax
80105965:	39 c2                	cmp    %eax,%edx
80105967:	76 07                	jbe    80105970 <argptr+0x5b>
    return -1;
80105969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596e:	eb 0f                	jmp    8010597f <argptr+0x6a>
  *pp = (char*)i;
80105970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105973:	89 c2                	mov    %eax,%edx
80105975:	8b 45 0c             	mov    0xc(%ebp),%eax
80105978:	89 10                	mov    %edx,(%eax)
  return 0;
8010597a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010597f:	c9                   	leave
80105980:	c3                   	ret

80105981 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105981:	f3 0f 1e fb          	endbr32
80105985:	55                   	push   %ebp
80105986:	89 e5                	mov    %esp,%ebp
80105988:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010598b:	83 ec 08             	sub    $0x8,%esp
8010598e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105991:	50                   	push   %eax
80105992:	ff 75 08             	push   0x8(%ebp)
80105995:	e8 4a ff ff ff       	call   801058e4 <argint>
8010599a:	83 c4 10             	add    $0x10,%esp
8010599d:	85 c0                	test   %eax,%eax
8010599f:	79 07                	jns    801059a8 <argstr+0x27>
    return -1;
801059a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a6:	eb 12                	jmp    801059ba <argstr+0x39>
  return fetchstr(addr, pp);
801059a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ab:	83 ec 08             	sub    $0x8,%esp
801059ae:	ff 75 0c             	push   0xc(%ebp)
801059b1:	50                   	push   %eax
801059b2:	e8 c5 fe ff ff       	call   8010587c <fetchstr>
801059b7:	83 c4 10             	add    $0x10,%esp
}
801059ba:	c9                   	leave
801059bb:	c3                   	ret

801059bc <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
801059bc:	f3 0f 1e fb          	endbr32
801059c0:	55                   	push   %ebp
801059c1:	89 e5                	mov    %esp,%ebp
801059c3:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059c6:	e8 de e1 ff ff       	call   80103ba9 <myproc>
801059cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d1:	8b 40 18             	mov    0x18(%eax),%eax
801059d4:	8b 40 1c             	mov    0x1c(%eax),%eax
801059d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059de:	7e 2f                	jle    80105a0f <syscall+0x53>
801059e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e3:	83 f8 19             	cmp    $0x19,%eax
801059e6:	77 27                	ja     80105a0f <syscall+0x53>
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801059f2:	85 c0                	test   %eax,%eax
801059f4:	74 19                	je     80105a0f <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105a00:	ff d0                	call   *%eax
80105a02:	89 c2                	mov    %eax,%edx
80105a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a07:	8b 40 18             	mov    0x18(%eax),%eax
80105a0a:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a0d:	eb 2c                	jmp    80105a3b <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a12:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a18:	8b 40 10             	mov    0x10(%eax),%eax
80105a1b:	ff 75 f0             	push   -0x10(%ebp)
80105a1e:	52                   	push   %edx
80105a1f:	50                   	push   %eax
80105a20:	68 79 b3 10 80       	push   $0x8010b379
80105a25:	e8 e2 a9 ff ff       	call   8010040c <cprintf>
80105a2a:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a30:	8b 40 18             	mov    0x18(%eax),%eax
80105a33:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a3a:	90                   	nop
80105a3b:	90                   	nop
80105a3c:	c9                   	leave
80105a3d:	c3                   	ret

80105a3e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a3e:	f3 0f 1e fb          	endbr32
80105a42:	55                   	push   %ebp
80105a43:	89 e5                	mov    %esp,%ebp
80105a45:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a48:	83 ec 08             	sub    $0x8,%esp
80105a4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a4e:	50                   	push   %eax
80105a4f:	ff 75 08             	push   0x8(%ebp)
80105a52:	e8 8d fe ff ff       	call   801058e4 <argint>
80105a57:	83 c4 10             	add    $0x10,%esp
80105a5a:	85 c0                	test   %eax,%eax
80105a5c:	79 07                	jns    80105a65 <argfd+0x27>
    return -1;
80105a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a63:	eb 4f                	jmp    80105ab4 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a68:	85 c0                	test   %eax,%eax
80105a6a:	78 20                	js     80105a8c <argfd+0x4e>
80105a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6f:	83 f8 0f             	cmp    $0xf,%eax
80105a72:	7f 18                	jg     80105a8c <argfd+0x4e>
80105a74:	e8 30 e1 ff ff       	call   80103ba9 <myproc>
80105a79:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a7c:	83 c2 08             	add    $0x8,%edx
80105a7f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8a:	75 07                	jne    80105a93 <argfd+0x55>
    return -1;
80105a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a91:	eb 21                	jmp    80105ab4 <argfd+0x76>
  if(pfd)
80105a93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a97:	74 08                	je     80105aa1 <argfd+0x63>
    *pfd = fd;
80105a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a9f:	89 10                	mov    %edx,(%eax)
  if(pf)
80105aa1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105aa5:	74 08                	je     80105aaf <argfd+0x71>
    *pf = f;
80105aa7:	8b 45 10             	mov    0x10(%ebp),%eax
80105aaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aad:	89 10                	mov    %edx,(%eax)
  return 0;
80105aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ab4:	c9                   	leave
80105ab5:	c3                   	ret

80105ab6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ab6:	f3 0f 1e fb          	endbr32
80105aba:	55                   	push   %ebp
80105abb:	89 e5                	mov    %esp,%ebp
80105abd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ac0:	e8 e4 e0 ff ff       	call   80103ba9 <myproc>
80105ac5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ac8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105acf:	eb 2a                	jmp    80105afb <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad7:	83 c2 08             	add    $0x8,%edx
80105ada:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ade:	85 c0                	test   %eax,%eax
80105ae0:	75 15                	jne    80105af7 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ae8:	8d 4a 08             	lea    0x8(%edx),%ecx
80105aeb:	8b 55 08             	mov    0x8(%ebp),%edx
80105aee:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af5:	eb 0f                	jmp    80105b06 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105af7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105afb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105aff:	7e d0                	jle    80105ad1 <fdalloc+0x1b>
    }
  }
  return -1;
80105b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b06:	c9                   	leave
80105b07:	c3                   	ret

80105b08 <sys_dup>:

int
sys_dup(void)
{
80105b08:	f3 0f 1e fb          	endbr32
80105b0c:	55                   	push   %ebp
80105b0d:	89 e5                	mov    %esp,%ebp
80105b0f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b12:	83 ec 04             	sub    $0x4,%esp
80105b15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b18:	50                   	push   %eax
80105b19:	6a 00                	push   $0x0
80105b1b:	6a 00                	push   $0x0
80105b1d:	e8 1c ff ff ff       	call   80105a3e <argfd>
80105b22:	83 c4 10             	add    $0x10,%esp
80105b25:	85 c0                	test   %eax,%eax
80105b27:	79 07                	jns    80105b30 <sys_dup+0x28>
    return -1;
80105b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2e:	eb 31                	jmp    80105b61 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b33:	83 ec 0c             	sub    $0xc,%esp
80105b36:	50                   	push   %eax
80105b37:	e8 7a ff ff ff       	call   80105ab6 <fdalloc>
80105b3c:	83 c4 10             	add    $0x10,%esp
80105b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b46:	79 07                	jns    80105b4f <sys_dup+0x47>
    return -1;
80105b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4d:	eb 12                	jmp    80105b61 <sys_dup+0x59>
  filedup(f);
80105b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b52:	83 ec 0c             	sub    $0xc,%esp
80105b55:	50                   	push   %eax
80105b56:	e8 39 b5 ff ff       	call   80101094 <filedup>
80105b5b:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b61:	c9                   	leave
80105b62:	c3                   	ret

80105b63 <sys_read>:

int
sys_read(void)
{
80105b63:	f3 0f 1e fb          	endbr32
80105b67:	55                   	push   %ebp
80105b68:	89 e5                	mov    %esp,%ebp
80105b6a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b6d:	83 ec 04             	sub    $0x4,%esp
80105b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b73:	50                   	push   %eax
80105b74:	6a 00                	push   $0x0
80105b76:	6a 00                	push   $0x0
80105b78:	e8 c1 fe ff ff       	call   80105a3e <argfd>
80105b7d:	83 c4 10             	add    $0x10,%esp
80105b80:	85 c0                	test   %eax,%eax
80105b82:	78 2e                	js     80105bb2 <sys_read+0x4f>
80105b84:	83 ec 08             	sub    $0x8,%esp
80105b87:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b8a:	50                   	push   %eax
80105b8b:	6a 02                	push   $0x2
80105b8d:	e8 52 fd ff ff       	call   801058e4 <argint>
80105b92:	83 c4 10             	add    $0x10,%esp
80105b95:	85 c0                	test   %eax,%eax
80105b97:	78 19                	js     80105bb2 <sys_read+0x4f>
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	83 ec 04             	sub    $0x4,%esp
80105b9f:	50                   	push   %eax
80105ba0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ba3:	50                   	push   %eax
80105ba4:	6a 01                	push   $0x1
80105ba6:	e8 6a fd ff ff       	call   80105915 <argptr>
80105bab:	83 c4 10             	add    $0x10,%esp
80105bae:	85 c0                	test   %eax,%eax
80105bb0:	79 07                	jns    80105bb9 <sys_read+0x56>
    return -1;
80105bb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb7:	eb 17                	jmp    80105bd0 <sys_read+0x6d>
  return fileread(f, p, n);
80105bb9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bbc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc2:	83 ec 04             	sub    $0x4,%esp
80105bc5:	51                   	push   %ecx
80105bc6:	52                   	push   %edx
80105bc7:	50                   	push   %eax
80105bc8:	e8 63 b6 ff ff       	call   80101230 <fileread>
80105bcd:	83 c4 10             	add    $0x10,%esp
}
80105bd0:	c9                   	leave
80105bd1:	c3                   	ret

80105bd2 <sys_write>:

int
sys_write(void)
{
80105bd2:	f3 0f 1e fb          	endbr32
80105bd6:	55                   	push   %ebp
80105bd7:	89 e5                	mov    %esp,%ebp
80105bd9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bdc:	83 ec 04             	sub    $0x4,%esp
80105bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105be2:	50                   	push   %eax
80105be3:	6a 00                	push   $0x0
80105be5:	6a 00                	push   $0x0
80105be7:	e8 52 fe ff ff       	call   80105a3e <argfd>
80105bec:	83 c4 10             	add    $0x10,%esp
80105bef:	85 c0                	test   %eax,%eax
80105bf1:	78 2e                	js     80105c21 <sys_write+0x4f>
80105bf3:	83 ec 08             	sub    $0x8,%esp
80105bf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf9:	50                   	push   %eax
80105bfa:	6a 02                	push   $0x2
80105bfc:	e8 e3 fc ff ff       	call   801058e4 <argint>
80105c01:	83 c4 10             	add    $0x10,%esp
80105c04:	85 c0                	test   %eax,%eax
80105c06:	78 19                	js     80105c21 <sys_write+0x4f>
80105c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0b:	83 ec 04             	sub    $0x4,%esp
80105c0e:	50                   	push   %eax
80105c0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c12:	50                   	push   %eax
80105c13:	6a 01                	push   $0x1
80105c15:	e8 fb fc ff ff       	call   80105915 <argptr>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	79 07                	jns    80105c28 <sys_write+0x56>
    return -1;
80105c21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c26:	eb 17                	jmp    80105c3f <sys_write+0x6d>
  return filewrite(f, p, n);
80105c28:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c31:	83 ec 04             	sub    $0x4,%esp
80105c34:	51                   	push   %ecx
80105c35:	52                   	push   %edx
80105c36:	50                   	push   %eax
80105c37:	e8 b0 b6 ff ff       	call   801012ec <filewrite>
80105c3c:	83 c4 10             	add    $0x10,%esp
}
80105c3f:	c9                   	leave
80105c40:	c3                   	ret

80105c41 <sys_close>:

int
sys_close(void)
{
80105c41:	f3 0f 1e fb          	endbr32
80105c45:	55                   	push   %ebp
80105c46:	89 e5                	mov    %esp,%ebp
80105c48:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c4b:	83 ec 04             	sub    $0x4,%esp
80105c4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c51:	50                   	push   %eax
80105c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c55:	50                   	push   %eax
80105c56:	6a 00                	push   $0x0
80105c58:	e8 e1 fd ff ff       	call   80105a3e <argfd>
80105c5d:	83 c4 10             	add    $0x10,%esp
80105c60:	85 c0                	test   %eax,%eax
80105c62:	79 07                	jns    80105c6b <sys_close+0x2a>
    return -1;
80105c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c69:	eb 27                	jmp    80105c92 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c6b:	e8 39 df ff ff       	call   80103ba9 <myproc>
80105c70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c73:	83 c2 08             	add    $0x8,%edx
80105c76:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c7d:	00 
  fileclose(f);
80105c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c81:	83 ec 0c             	sub    $0xc,%esp
80105c84:	50                   	push   %eax
80105c85:	e8 5f b4 ff ff       	call   801010e9 <fileclose>
80105c8a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c92:	c9                   	leave
80105c93:	c3                   	ret

80105c94 <sys_fstat>:

int
sys_fstat(void)
{
80105c94:	f3 0f 1e fb          	endbr32
80105c98:	55                   	push   %ebp
80105c99:	89 e5                	mov    %esp,%ebp
80105c9b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c9e:	83 ec 04             	sub    $0x4,%esp
80105ca1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ca4:	50                   	push   %eax
80105ca5:	6a 00                	push   $0x0
80105ca7:	6a 00                	push   $0x0
80105ca9:	e8 90 fd ff ff       	call   80105a3e <argfd>
80105cae:	83 c4 10             	add    $0x10,%esp
80105cb1:	85 c0                	test   %eax,%eax
80105cb3:	78 17                	js     80105ccc <sys_fstat+0x38>
80105cb5:	83 ec 04             	sub    $0x4,%esp
80105cb8:	6a 14                	push   $0x14
80105cba:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cbd:	50                   	push   %eax
80105cbe:	6a 01                	push   $0x1
80105cc0:	e8 50 fc ff ff       	call   80105915 <argptr>
80105cc5:	83 c4 10             	add    $0x10,%esp
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	79 07                	jns    80105cd3 <sys_fstat+0x3f>
    return -1;
80105ccc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd1:	eb 13                	jmp    80105ce6 <sys_fstat+0x52>
  return filestat(f, st);
80105cd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd9:	83 ec 08             	sub    $0x8,%esp
80105cdc:	52                   	push   %edx
80105cdd:	50                   	push   %eax
80105cde:	e8 f2 b4 ff ff       	call   801011d5 <filestat>
80105ce3:	83 c4 10             	add    $0x10,%esp
}
80105ce6:	c9                   	leave
80105ce7:	c3                   	ret

80105ce8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ce8:	f3 0f 1e fb          	endbr32
80105cec:	55                   	push   %ebp
80105ced:	89 e5                	mov    %esp,%ebp
80105cef:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cf2:	83 ec 08             	sub    $0x8,%esp
80105cf5:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cf8:	50                   	push   %eax
80105cf9:	6a 00                	push   $0x0
80105cfb:	e8 81 fc ff ff       	call   80105981 <argstr>
80105d00:	83 c4 10             	add    $0x10,%esp
80105d03:	85 c0                	test   %eax,%eax
80105d05:	78 15                	js     80105d1c <sys_link+0x34>
80105d07:	83 ec 08             	sub    $0x8,%esp
80105d0a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d0d:	50                   	push   %eax
80105d0e:	6a 01                	push   $0x1
80105d10:	e8 6c fc ff ff       	call   80105981 <argstr>
80105d15:	83 c4 10             	add    $0x10,%esp
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	79 0a                	jns    80105d26 <sys_link+0x3e>
    return -1;
80105d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d21:	e9 68 01 00 00       	jmp    80105e8e <sys_link+0x1a6>

  begin_op();
80105d26:	e8 46 d4 ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105d2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d2e:	83 ec 0c             	sub    $0xc,%esp
80105d31:	50                   	push   %eax
80105d32:	e8 b0 c8 ff ff       	call   801025e7 <namei>
80105d37:	83 c4 10             	add    $0x10,%esp
80105d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d41:	75 0f                	jne    80105d52 <sys_link+0x6a>
    end_op();
80105d43:	e8 b9 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4d:	e9 3c 01 00 00       	jmp    80105e8e <sys_link+0x1a6>
  }

  ilock(ip);
80105d52:	83 ec 0c             	sub    $0xc,%esp
80105d55:	ff 75 f4             	push   -0xc(%ebp)
80105d58:	e8 1f bd ff ff       	call   80101a7c <ilock>
80105d5d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d63:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d67:	66 83 f8 01          	cmp    $0x1,%ax
80105d6b:	75 1d                	jne    80105d8a <sys_link+0xa2>
    iunlockput(ip);
80105d6d:	83 ec 0c             	sub    $0xc,%esp
80105d70:	ff 75 f4             	push   -0xc(%ebp)
80105d73:	e8 41 bf ff ff       	call   80101cb9 <iunlockput>
80105d78:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d7b:	e8 81 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d85:	e9 04 01 00 00       	jmp    80105e8e <sys_link+0x1a6>
  }

  ip->nlink++;
80105d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d91:	83 c0 01             	add    $0x1,%eax
80105d94:	89 c2                	mov    %eax,%edx
80105d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d99:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d9d:	83 ec 0c             	sub    $0xc,%esp
80105da0:	ff 75 f4             	push   -0xc(%ebp)
80105da3:	e8 eb ba ff ff       	call   80101893 <iupdate>
80105da8:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105dab:	83 ec 0c             	sub    $0xc,%esp
80105dae:	ff 75 f4             	push   -0xc(%ebp)
80105db1:	e8 dd bd ff ff       	call   80101b93 <iunlock>
80105db6:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105db9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105dbc:	83 ec 08             	sub    $0x8,%esp
80105dbf:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105dc2:	52                   	push   %edx
80105dc3:	50                   	push   %eax
80105dc4:	e8 3e c8 ff ff       	call   80102607 <nameiparent>
80105dc9:	83 c4 10             	add    $0x10,%esp
80105dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dcf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd3:	74 71                	je     80105e46 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dd5:	83 ec 0c             	sub    $0xc,%esp
80105dd8:	ff 75 f0             	push   -0x10(%ebp)
80105ddb:	e8 9c bc ff ff       	call   80101a7c <ilock>
80105de0:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	8b 10                	mov    (%eax),%edx
80105de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105deb:	8b 00                	mov    (%eax),%eax
80105ded:	39 c2                	cmp    %eax,%edx
80105def:	75 1d                	jne    80105e0e <sys_link+0x126>
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	8b 40 04             	mov    0x4(%eax),%eax
80105df7:	83 ec 04             	sub    $0x4,%esp
80105dfa:	50                   	push   %eax
80105dfb:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dfe:	50                   	push   %eax
80105dff:	ff 75 f0             	push   -0x10(%ebp)
80105e02:	e8 3d c5 ff ff       	call   80102344 <dirlink>
80105e07:	83 c4 10             	add    $0x10,%esp
80105e0a:	85 c0                	test   %eax,%eax
80105e0c:	79 10                	jns    80105e1e <sys_link+0x136>
    iunlockput(dp);
80105e0e:	83 ec 0c             	sub    $0xc,%esp
80105e11:	ff 75 f0             	push   -0x10(%ebp)
80105e14:	e8 a0 be ff ff       	call   80101cb9 <iunlockput>
80105e19:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e1c:	eb 29                	jmp    80105e47 <sys_link+0x15f>
  }
  iunlockput(dp);
80105e1e:	83 ec 0c             	sub    $0xc,%esp
80105e21:	ff 75 f0             	push   -0x10(%ebp)
80105e24:	e8 90 be ff ff       	call   80101cb9 <iunlockput>
80105e29:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e2c:	83 ec 0c             	sub    $0xc,%esp
80105e2f:	ff 75 f4             	push   -0xc(%ebp)
80105e32:	e8 ae bd ff ff       	call   80101be5 <iput>
80105e37:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e3a:	e8 c2 d3 ff ff       	call   80103201 <end_op>

  return 0;
80105e3f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e44:	eb 48                	jmp    80105e8e <sys_link+0x1a6>
    goto bad;
80105e46:	90                   	nop

bad:
  ilock(ip);
80105e47:	83 ec 0c             	sub    $0xc,%esp
80105e4a:	ff 75 f4             	push   -0xc(%ebp)
80105e4d:	e8 2a bc ff ff       	call   80101a7c <ilock>
80105e52:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e58:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e5c:	83 e8 01             	sub    $0x1,%eax
80105e5f:	89 c2                	mov    %eax,%edx
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e68:	83 ec 0c             	sub    $0xc,%esp
80105e6b:	ff 75 f4             	push   -0xc(%ebp)
80105e6e:	e8 20 ba ff ff       	call   80101893 <iupdate>
80105e73:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e76:	83 ec 0c             	sub    $0xc,%esp
80105e79:	ff 75 f4             	push   -0xc(%ebp)
80105e7c:	e8 38 be ff ff       	call   80101cb9 <iunlockput>
80105e81:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e84:	e8 78 d3 ff ff       	call   80103201 <end_op>
  return -1;
80105e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e8e:	c9                   	leave
80105e8f:	c3                   	ret

80105e90 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e90:	f3 0f 1e fb          	endbr32
80105e94:	55                   	push   %ebp
80105e95:	89 e5                	mov    %esp,%ebp
80105e97:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e9a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ea1:	eb 40                	jmp    80105ee3 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea6:	6a 10                	push   $0x10
80105ea8:	50                   	push   %eax
80105ea9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105eac:	50                   	push   %eax
80105ead:	ff 75 08             	push   0x8(%ebp)
80105eb0:	e8 cf c0 ff ff       	call   80101f84 <readi>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	83 f8 10             	cmp    $0x10,%eax
80105ebb:	74 0d                	je     80105eca <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ebd:	83 ec 0c             	sub    $0xc,%esp
80105ec0:	68 95 b3 10 80       	push   $0x8010b395
80105ec5:	e8 fb a6 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105eca:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ece:	66 85 c0             	test   %ax,%ax
80105ed1:	74 07                	je     80105eda <isdirempty+0x4a>
      return 0;
80105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ed8:	eb 1b                	jmp    80105ef5 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edd:	83 c0 10             	add    $0x10,%eax
80105ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee6:	8b 50 58             	mov    0x58(%eax),%edx
80105ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eec:	39 c2                	cmp    %eax,%edx
80105eee:	77 b3                	ja     80105ea3 <isdirempty+0x13>
  }
  return 1;
80105ef0:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ef5:	c9                   	leave
80105ef6:	c3                   	ret

80105ef7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ef7:	f3 0f 1e fb          	endbr32
80105efb:	55                   	push   %ebp
80105efc:	89 e5                	mov    %esp,%ebp
80105efe:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f01:	83 ec 08             	sub    $0x8,%esp
80105f04:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f07:	50                   	push   %eax
80105f08:	6a 00                	push   $0x0
80105f0a:	e8 72 fa ff ff       	call   80105981 <argstr>
80105f0f:	83 c4 10             	add    $0x10,%esp
80105f12:	85 c0                	test   %eax,%eax
80105f14:	79 0a                	jns    80105f20 <sys_unlink+0x29>
    return -1;
80105f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1b:	e9 bf 01 00 00       	jmp    801060df <sys_unlink+0x1e8>

  begin_op();
80105f20:	e8 4c d2 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f25:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f28:	83 ec 08             	sub    $0x8,%esp
80105f2b:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f2e:	52                   	push   %edx
80105f2f:	50                   	push   %eax
80105f30:	e8 d2 c6 ff ff       	call   80102607 <nameiparent>
80105f35:	83 c4 10             	add    $0x10,%esp
80105f38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f3f:	75 0f                	jne    80105f50 <sys_unlink+0x59>
    end_op();
80105f41:	e8 bb d2 ff ff       	call   80103201 <end_op>
    return -1;
80105f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4b:	e9 8f 01 00 00       	jmp    801060df <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f50:	83 ec 0c             	sub    $0xc,%esp
80105f53:	ff 75 f4             	push   -0xc(%ebp)
80105f56:	e8 21 bb ff ff       	call   80101a7c <ilock>
80105f5b:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f5e:	83 ec 08             	sub    $0x8,%esp
80105f61:	68 a7 b3 10 80       	push   $0x8010b3a7
80105f66:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f69:	50                   	push   %eax
80105f6a:	e8 f8 c2 ff ff       	call   80102267 <namecmp>
80105f6f:	83 c4 10             	add    $0x10,%esp
80105f72:	85 c0                	test   %eax,%eax
80105f74:	0f 84 49 01 00 00    	je     801060c3 <sys_unlink+0x1cc>
80105f7a:	83 ec 08             	sub    $0x8,%esp
80105f7d:	68 a9 b3 10 80       	push   $0x8010b3a9
80105f82:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f85:	50                   	push   %eax
80105f86:	e8 dc c2 ff ff       	call   80102267 <namecmp>
80105f8b:	83 c4 10             	add    $0x10,%esp
80105f8e:	85 c0                	test   %eax,%eax
80105f90:	0f 84 2d 01 00 00    	je     801060c3 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f96:	83 ec 04             	sub    $0x4,%esp
80105f99:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f9c:	50                   	push   %eax
80105f9d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fa0:	50                   	push   %eax
80105fa1:	ff 75 f4             	push   -0xc(%ebp)
80105fa4:	e8 dd c2 ff ff       	call   80102286 <dirlookup>
80105fa9:	83 c4 10             	add    $0x10,%esp
80105fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105faf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fb3:	0f 84 0d 01 00 00    	je     801060c6 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fb9:	83 ec 0c             	sub    $0xc,%esp
80105fbc:	ff 75 f0             	push   -0x10(%ebp)
80105fbf:	e8 b8 ba ff ff       	call   80101a7c <ilock>
80105fc4:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fca:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fce:	66 85 c0             	test   %ax,%ax
80105fd1:	7f 0d                	jg     80105fe0 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fd3:	83 ec 0c             	sub    $0xc,%esp
80105fd6:	68 ac b3 10 80       	push   $0x8010b3ac
80105fdb:	e8 e5 a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fe7:	66 83 f8 01          	cmp    $0x1,%ax
80105feb:	75 25                	jne    80106012 <sys_unlink+0x11b>
80105fed:	83 ec 0c             	sub    $0xc,%esp
80105ff0:	ff 75 f0             	push   -0x10(%ebp)
80105ff3:	e8 98 fe ff ff       	call   80105e90 <isdirempty>
80105ff8:	83 c4 10             	add    $0x10,%esp
80105ffb:	85 c0                	test   %eax,%eax
80105ffd:	75 13                	jne    80106012 <sys_unlink+0x11b>
    iunlockput(ip);
80105fff:	83 ec 0c             	sub    $0xc,%esp
80106002:	ff 75 f0             	push   -0x10(%ebp)
80106005:	e8 af bc ff ff       	call   80101cb9 <iunlockput>
8010600a:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010600d:	e9 b5 00 00 00       	jmp    801060c7 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106012:	83 ec 04             	sub    $0x4,%esp
80106015:	6a 10                	push   $0x10
80106017:	6a 00                	push   $0x0
80106019:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010601c:	50                   	push   %eax
8010601d:	e8 6e f5 ff ff       	call   80105590 <memset>
80106022:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106025:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106028:	6a 10                	push   $0x10
8010602a:	50                   	push   %eax
8010602b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010602e:	50                   	push   %eax
8010602f:	ff 75 f4             	push   -0xc(%ebp)
80106032:	e8 a6 c0 ff ff       	call   801020dd <writei>
80106037:	83 c4 10             	add    $0x10,%esp
8010603a:	83 f8 10             	cmp    $0x10,%eax
8010603d:	74 0d                	je     8010604c <sys_unlink+0x155>
    panic("unlink: writei");
8010603f:	83 ec 0c             	sub    $0xc,%esp
80106042:	68 be b3 10 80       	push   $0x8010b3be
80106047:	e8 79 a5 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
8010604c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106053:	66 83 f8 01          	cmp    $0x1,%ax
80106057:	75 21                	jne    8010607a <sys_unlink+0x183>
    dp->nlink--;
80106059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106060:	83 e8 01             	sub    $0x1,%eax
80106063:	89 c2                	mov    %eax,%edx
80106065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106068:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010606c:	83 ec 0c             	sub    $0xc,%esp
8010606f:	ff 75 f4             	push   -0xc(%ebp)
80106072:	e8 1c b8 ff ff       	call   80101893 <iupdate>
80106077:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010607a:	83 ec 0c             	sub    $0xc,%esp
8010607d:	ff 75 f4             	push   -0xc(%ebp)
80106080:	e8 34 bc ff ff       	call   80101cb9 <iunlockput>
80106085:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010608f:	83 e8 01             	sub    $0x1,%eax
80106092:	89 c2                	mov    %eax,%edx
80106094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106097:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010609b:	83 ec 0c             	sub    $0xc,%esp
8010609e:	ff 75 f0             	push   -0x10(%ebp)
801060a1:	e8 ed b7 ff ff       	call   80101893 <iupdate>
801060a6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060a9:	83 ec 0c             	sub    $0xc,%esp
801060ac:	ff 75 f0             	push   -0x10(%ebp)
801060af:	e8 05 bc ff ff       	call   80101cb9 <iunlockput>
801060b4:	83 c4 10             	add    $0x10,%esp

  end_op();
801060b7:	e8 45 d1 ff ff       	call   80103201 <end_op>

  return 0;
801060bc:	b8 00 00 00 00       	mov    $0x0,%eax
801060c1:	eb 1c                	jmp    801060df <sys_unlink+0x1e8>
    goto bad;
801060c3:	90                   	nop
801060c4:	eb 01                	jmp    801060c7 <sys_unlink+0x1d0>
    goto bad;
801060c6:	90                   	nop

bad:
  iunlockput(dp);
801060c7:	83 ec 0c             	sub    $0xc,%esp
801060ca:	ff 75 f4             	push   -0xc(%ebp)
801060cd:	e8 e7 bb ff ff       	call   80101cb9 <iunlockput>
801060d2:	83 c4 10             	add    $0x10,%esp
  end_op();
801060d5:	e8 27 d1 ff ff       	call   80103201 <end_op>
  return -1;
801060da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060df:	c9                   	leave
801060e0:	c3                   	ret

801060e1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060e1:	f3 0f 1e fb          	endbr32
801060e5:	55                   	push   %ebp
801060e6:	89 e5                	mov    %esp,%ebp
801060e8:	83 ec 38             	sub    $0x38,%esp
801060eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060ee:	8b 55 10             	mov    0x10(%ebp),%edx
801060f1:	8b 45 14             	mov    0x14(%ebp),%eax
801060f4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060f8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060fc:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106100:	83 ec 08             	sub    $0x8,%esp
80106103:	8d 45 de             	lea    -0x22(%ebp),%eax
80106106:	50                   	push   %eax
80106107:	ff 75 08             	push   0x8(%ebp)
8010610a:	e8 f8 c4 ff ff       	call   80102607 <nameiparent>
8010610f:	83 c4 10             	add    $0x10,%esp
80106112:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106115:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106119:	75 0a                	jne    80106125 <create+0x44>
    return 0;
8010611b:	b8 00 00 00 00       	mov    $0x0,%eax
80106120:	e9 90 01 00 00       	jmp    801062b5 <create+0x1d4>
  ilock(dp);
80106125:	83 ec 0c             	sub    $0xc,%esp
80106128:	ff 75 f4             	push   -0xc(%ebp)
8010612b:	e8 4c b9 ff ff       	call   80101a7c <ilock>
80106130:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106133:	83 ec 04             	sub    $0x4,%esp
80106136:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106139:	50                   	push   %eax
8010613a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010613d:	50                   	push   %eax
8010613e:	ff 75 f4             	push   -0xc(%ebp)
80106141:	e8 40 c1 ff ff       	call   80102286 <dirlookup>
80106146:	83 c4 10             	add    $0x10,%esp
80106149:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010614c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106150:	74 50                	je     801061a2 <create+0xc1>
    iunlockput(dp);
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	ff 75 f4             	push   -0xc(%ebp)
80106158:	e8 5c bb ff ff       	call   80101cb9 <iunlockput>
8010615d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	ff 75 f0             	push   -0x10(%ebp)
80106166:	e8 11 b9 ff ff       	call   80101a7c <ilock>
8010616b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010616e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106173:	75 15                	jne    8010618a <create+0xa9>
80106175:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106178:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010617c:	66 83 f8 02          	cmp    $0x2,%ax
80106180:	75 08                	jne    8010618a <create+0xa9>
      return ip;
80106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106185:	e9 2b 01 00 00       	jmp    801062b5 <create+0x1d4>
    iunlockput(ip);
8010618a:	83 ec 0c             	sub    $0xc,%esp
8010618d:	ff 75 f0             	push   -0x10(%ebp)
80106190:	e8 24 bb ff ff       	call   80101cb9 <iunlockput>
80106195:	83 c4 10             	add    $0x10,%esp
    return 0;
80106198:	b8 00 00 00 00       	mov    $0x0,%eax
8010619d:	e9 13 01 00 00       	jmp    801062b5 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061a2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a9:	8b 00                	mov    (%eax),%eax
801061ab:	83 ec 08             	sub    $0x8,%esp
801061ae:	52                   	push   %edx
801061af:	50                   	push   %eax
801061b0:	e8 03 b6 ff ff       	call   801017b8 <ialloc>
801061b5:	83 c4 10             	add    $0x10,%esp
801061b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061bf:	75 0d                	jne    801061ce <create+0xed>
    panic("create: ialloc");
801061c1:	83 ec 0c             	sub    $0xc,%esp
801061c4:	68 cd b3 10 80       	push   $0x8010b3cd
801061c9:	e8 f7 a3 ff ff       	call   801005c5 <panic>

  ilock(ip);
801061ce:	83 ec 0c             	sub    $0xc,%esp
801061d1:	ff 75 f0             	push   -0x10(%ebp)
801061d4:	e8 a3 b8 ff ff       	call   80101a7c <ilock>
801061d9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061df:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061e3:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ea:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061ee:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f5:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061fb:	83 ec 0c             	sub    $0xc,%esp
801061fe:	ff 75 f0             	push   -0x10(%ebp)
80106201:	e8 8d b6 ff ff       	call   80101893 <iupdate>
80106206:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106209:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010620e:	75 6a                	jne    8010627a <create+0x199>
    dp->nlink++;  // for ".."
80106210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106213:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106217:	83 c0 01             	add    $0x1,%eax
8010621a:	89 c2                	mov    %eax,%edx
8010621c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621f:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106223:	83 ec 0c             	sub    $0xc,%esp
80106226:	ff 75 f4             	push   -0xc(%ebp)
80106229:	e8 65 b6 ff ff       	call   80101893 <iupdate>
8010622e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106234:	8b 40 04             	mov    0x4(%eax),%eax
80106237:	83 ec 04             	sub    $0x4,%esp
8010623a:	50                   	push   %eax
8010623b:	68 a7 b3 10 80       	push   $0x8010b3a7
80106240:	ff 75 f0             	push   -0x10(%ebp)
80106243:	e8 fc c0 ff ff       	call   80102344 <dirlink>
80106248:	83 c4 10             	add    $0x10,%esp
8010624b:	85 c0                	test   %eax,%eax
8010624d:	78 1e                	js     8010626d <create+0x18c>
8010624f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106252:	8b 40 04             	mov    0x4(%eax),%eax
80106255:	83 ec 04             	sub    $0x4,%esp
80106258:	50                   	push   %eax
80106259:	68 a9 b3 10 80       	push   $0x8010b3a9
8010625e:	ff 75 f0             	push   -0x10(%ebp)
80106261:	e8 de c0 ff ff       	call   80102344 <dirlink>
80106266:	83 c4 10             	add    $0x10,%esp
80106269:	85 c0                	test   %eax,%eax
8010626b:	79 0d                	jns    8010627a <create+0x199>
      panic("create dots");
8010626d:	83 ec 0c             	sub    $0xc,%esp
80106270:	68 dc b3 10 80       	push   $0x8010b3dc
80106275:	e8 4b a3 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010627a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627d:	8b 40 04             	mov    0x4(%eax),%eax
80106280:	83 ec 04             	sub    $0x4,%esp
80106283:	50                   	push   %eax
80106284:	8d 45 de             	lea    -0x22(%ebp),%eax
80106287:	50                   	push   %eax
80106288:	ff 75 f4             	push   -0xc(%ebp)
8010628b:	e8 b4 c0 ff ff       	call   80102344 <dirlink>
80106290:	83 c4 10             	add    $0x10,%esp
80106293:	85 c0                	test   %eax,%eax
80106295:	79 0d                	jns    801062a4 <create+0x1c3>
    panic("create: dirlink");
80106297:	83 ec 0c             	sub    $0xc,%esp
8010629a:	68 e8 b3 10 80       	push   $0x8010b3e8
8010629f:	e8 21 a3 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
801062a4:	83 ec 0c             	sub    $0xc,%esp
801062a7:	ff 75 f4             	push   -0xc(%ebp)
801062aa:	e8 0a ba ff ff       	call   80101cb9 <iunlockput>
801062af:	83 c4 10             	add    $0x10,%esp

  return ip;
801062b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062b5:	c9                   	leave
801062b6:	c3                   	ret

801062b7 <sys_open>:

int
sys_open(void)
{
801062b7:	f3 0f 1e fb          	endbr32
801062bb:	55                   	push   %ebp
801062bc:	89 e5                	mov    %esp,%ebp
801062be:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062c1:	83 ec 08             	sub    $0x8,%esp
801062c4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062c7:	50                   	push   %eax
801062c8:	6a 00                	push   $0x0
801062ca:	e8 b2 f6 ff ff       	call   80105981 <argstr>
801062cf:	83 c4 10             	add    $0x10,%esp
801062d2:	85 c0                	test   %eax,%eax
801062d4:	78 15                	js     801062eb <sys_open+0x34>
801062d6:	83 ec 08             	sub    $0x8,%esp
801062d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062dc:	50                   	push   %eax
801062dd:	6a 01                	push   $0x1
801062df:	e8 00 f6 ff ff       	call   801058e4 <argint>
801062e4:	83 c4 10             	add    $0x10,%esp
801062e7:	85 c0                	test   %eax,%eax
801062e9:	79 0a                	jns    801062f5 <sys_open+0x3e>
    return -1;
801062eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f0:	e9 61 01 00 00       	jmp    80106456 <sys_open+0x19f>

  begin_op();
801062f5:	e8 77 ce ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
801062fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062fd:	25 00 02 00 00       	and    $0x200,%eax
80106302:	85 c0                	test   %eax,%eax
80106304:	74 2a                	je     80106330 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106306:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106309:	6a 00                	push   $0x0
8010630b:	6a 00                	push   $0x0
8010630d:	6a 02                	push   $0x2
8010630f:	50                   	push   %eax
80106310:	e8 cc fd ff ff       	call   801060e1 <create>
80106315:	83 c4 10             	add    $0x10,%esp
80106318:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010631b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631f:	75 75                	jne    80106396 <sys_open+0xdf>
      end_op();
80106321:	e8 db ce ff ff       	call   80103201 <end_op>
      return -1;
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632b:	e9 26 01 00 00       	jmp    80106456 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106330:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106333:	83 ec 0c             	sub    $0xc,%esp
80106336:	50                   	push   %eax
80106337:	e8 ab c2 ff ff       	call   801025e7 <namei>
8010633c:	83 c4 10             	add    $0x10,%esp
8010633f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106342:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106346:	75 0f                	jne    80106357 <sys_open+0xa0>
      end_op();
80106348:	e8 b4 ce ff ff       	call   80103201 <end_op>
      return -1;
8010634d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106352:	e9 ff 00 00 00       	jmp    80106456 <sys_open+0x19f>
    }
    ilock(ip);
80106357:	83 ec 0c             	sub    $0xc,%esp
8010635a:	ff 75 f4             	push   -0xc(%ebp)
8010635d:	e8 1a b7 ff ff       	call   80101a7c <ilock>
80106362:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010636c:	66 83 f8 01          	cmp    $0x1,%ax
80106370:	75 24                	jne    80106396 <sys_open+0xdf>
80106372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106375:	85 c0                	test   %eax,%eax
80106377:	74 1d                	je     80106396 <sys_open+0xdf>
      iunlockput(ip);
80106379:	83 ec 0c             	sub    $0xc,%esp
8010637c:	ff 75 f4             	push   -0xc(%ebp)
8010637f:	e8 35 b9 ff ff       	call   80101cb9 <iunlockput>
80106384:	83 c4 10             	add    $0x10,%esp
      end_op();
80106387:	e8 75 ce ff ff       	call   80103201 <end_op>
      return -1;
8010638c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106391:	e9 c0 00 00 00       	jmp    80106456 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106396:	e8 88 ac ff ff       	call   80101023 <filealloc>
8010639b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010639e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a2:	74 17                	je     801063bb <sys_open+0x104>
801063a4:	83 ec 0c             	sub    $0xc,%esp
801063a7:	ff 75 f0             	push   -0x10(%ebp)
801063aa:	e8 07 f7 ff ff       	call   80105ab6 <fdalloc>
801063af:	83 c4 10             	add    $0x10,%esp
801063b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063b9:	79 2e                	jns    801063e9 <sys_open+0x132>
    if(f)
801063bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063bf:	74 0e                	je     801063cf <sys_open+0x118>
      fileclose(f);
801063c1:	83 ec 0c             	sub    $0xc,%esp
801063c4:	ff 75 f0             	push   -0x10(%ebp)
801063c7:	e8 1d ad ff ff       	call   801010e9 <fileclose>
801063cc:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063cf:	83 ec 0c             	sub    $0xc,%esp
801063d2:	ff 75 f4             	push   -0xc(%ebp)
801063d5:	e8 df b8 ff ff       	call   80101cb9 <iunlockput>
801063da:	83 c4 10             	add    $0x10,%esp
    end_op();
801063dd:	e8 1f ce ff ff       	call   80103201 <end_op>
    return -1;
801063e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e7:	eb 6d                	jmp    80106456 <sys_open+0x19f>
  }
  iunlock(ip);
801063e9:	83 ec 0c             	sub    $0xc,%esp
801063ec:	ff 75 f4             	push   -0xc(%ebp)
801063ef:	e8 9f b7 ff ff       	call   80101b93 <iunlock>
801063f4:	83 c4 10             	add    $0x10,%esp
  end_op();
801063f7:	e8 05 ce ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
801063fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ff:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106408:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010640b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010640e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106411:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641b:	83 e0 01             	and    $0x1,%eax
8010641e:	85 c0                	test   %eax,%eax
80106420:	0f 94 c0             	sete   %al
80106423:	89 c2                	mov    %eax,%edx
80106425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106428:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010642b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010642e:	83 e0 01             	and    $0x1,%eax
80106431:	85 c0                	test   %eax,%eax
80106433:	75 0a                	jne    8010643f <sys_open+0x188>
80106435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106438:	83 e0 02             	and    $0x2,%eax
8010643b:	85 c0                	test   %eax,%eax
8010643d:	74 07                	je     80106446 <sys_open+0x18f>
8010643f:	b8 01 00 00 00       	mov    $0x1,%eax
80106444:	eb 05                	jmp    8010644b <sys_open+0x194>
80106446:	b8 00 00 00 00       	mov    $0x0,%eax
8010644b:	89 c2                	mov    %eax,%edx
8010644d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106450:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106453:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106456:	c9                   	leave
80106457:	c3                   	ret

80106458 <sys_mkdir>:

int
sys_mkdir(void)
{
80106458:	f3 0f 1e fb          	endbr32
8010645c:	55                   	push   %ebp
8010645d:	89 e5                	mov    %esp,%ebp
8010645f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106462:	e8 0a cd ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106467:	83 ec 08             	sub    $0x8,%esp
8010646a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646d:	50                   	push   %eax
8010646e:	6a 00                	push   $0x0
80106470:	e8 0c f5 ff ff       	call   80105981 <argstr>
80106475:	83 c4 10             	add    $0x10,%esp
80106478:	85 c0                	test   %eax,%eax
8010647a:	78 1b                	js     80106497 <sys_mkdir+0x3f>
8010647c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647f:	6a 00                	push   $0x0
80106481:	6a 00                	push   $0x0
80106483:	6a 01                	push   $0x1
80106485:	50                   	push   %eax
80106486:	e8 56 fc ff ff       	call   801060e1 <create>
8010648b:	83 c4 10             	add    $0x10,%esp
8010648e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106491:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106495:	75 0c                	jne    801064a3 <sys_mkdir+0x4b>
    end_op();
80106497:	e8 65 cd ff ff       	call   80103201 <end_op>
    return -1;
8010649c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a1:	eb 18                	jmp    801064bb <sys_mkdir+0x63>
  }
  iunlockput(ip);
801064a3:	83 ec 0c             	sub    $0xc,%esp
801064a6:	ff 75 f4             	push   -0xc(%ebp)
801064a9:	e8 0b b8 ff ff       	call   80101cb9 <iunlockput>
801064ae:	83 c4 10             	add    $0x10,%esp
  end_op();
801064b1:	e8 4b cd ff ff       	call   80103201 <end_op>
  return 0;
801064b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064bb:	c9                   	leave
801064bc:	c3                   	ret

801064bd <sys_mknod>:

int
sys_mknod(void)
{
801064bd:	f3 0f 1e fb          	endbr32
801064c1:	55                   	push   %ebp
801064c2:	89 e5                	mov    %esp,%ebp
801064c4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064c7:	e8 a5 cc ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064cc:	83 ec 08             	sub    $0x8,%esp
801064cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064d2:	50                   	push   %eax
801064d3:	6a 00                	push   $0x0
801064d5:	e8 a7 f4 ff ff       	call   80105981 <argstr>
801064da:	83 c4 10             	add    $0x10,%esp
801064dd:	85 c0                	test   %eax,%eax
801064df:	78 4f                	js     80106530 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064e1:	83 ec 08             	sub    $0x8,%esp
801064e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064e7:	50                   	push   %eax
801064e8:	6a 01                	push   $0x1
801064ea:	e8 f5 f3 ff ff       	call   801058e4 <argint>
801064ef:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064f2:	85 c0                	test   %eax,%eax
801064f4:	78 3a                	js     80106530 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064f6:	83 ec 08             	sub    $0x8,%esp
801064f9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064fc:	50                   	push   %eax
801064fd:	6a 02                	push   $0x2
801064ff:	e8 e0 f3 ff ff       	call   801058e4 <argint>
80106504:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106507:	85 c0                	test   %eax,%eax
80106509:	78 25                	js     80106530 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010650b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010650e:	0f bf c8             	movswl %ax,%ecx
80106511:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106514:	0f bf d0             	movswl %ax,%edx
80106517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651a:	51                   	push   %ecx
8010651b:	52                   	push   %edx
8010651c:	6a 03                	push   $0x3
8010651e:	50                   	push   %eax
8010651f:	e8 bd fb ff ff       	call   801060e1 <create>
80106524:	83 c4 10             	add    $0x10,%esp
80106527:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010652a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652e:	75 0c                	jne    8010653c <sys_mknod+0x7f>
    end_op();
80106530:	e8 cc cc ff ff       	call   80103201 <end_op>
    return -1;
80106535:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653a:	eb 18                	jmp    80106554 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010653c:	83 ec 0c             	sub    $0xc,%esp
8010653f:	ff 75 f4             	push   -0xc(%ebp)
80106542:	e8 72 b7 ff ff       	call   80101cb9 <iunlockput>
80106547:	83 c4 10             	add    $0x10,%esp
  end_op();
8010654a:	e8 b2 cc ff ff       	call   80103201 <end_op>
  return 0;
8010654f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106554:	c9                   	leave
80106555:	c3                   	ret

80106556 <sys_chdir>:

int
sys_chdir(void)
{
80106556:	f3 0f 1e fb          	endbr32
8010655a:	55                   	push   %ebp
8010655b:	89 e5                	mov    %esp,%ebp
8010655d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106560:	e8 44 d6 ff ff       	call   80103ba9 <myproc>
80106565:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106568:	e8 04 cc ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010656d:	83 ec 08             	sub    $0x8,%esp
80106570:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106573:	50                   	push   %eax
80106574:	6a 00                	push   $0x0
80106576:	e8 06 f4 ff ff       	call   80105981 <argstr>
8010657b:	83 c4 10             	add    $0x10,%esp
8010657e:	85 c0                	test   %eax,%eax
80106580:	78 18                	js     8010659a <sys_chdir+0x44>
80106582:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106585:	83 ec 0c             	sub    $0xc,%esp
80106588:	50                   	push   %eax
80106589:	e8 59 c0 ff ff       	call   801025e7 <namei>
8010658e:	83 c4 10             	add    $0x10,%esp
80106591:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106594:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106598:	75 0c                	jne    801065a6 <sys_chdir+0x50>
    end_op();
8010659a:	e8 62 cc ff ff       	call   80103201 <end_op>
    return -1;
8010659f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a4:	eb 68                	jmp    8010660e <sys_chdir+0xb8>
  }
  ilock(ip);
801065a6:	83 ec 0c             	sub    $0xc,%esp
801065a9:	ff 75 f0             	push   -0x10(%ebp)
801065ac:	e8 cb b4 ff ff       	call   80101a7c <ilock>
801065b1:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065bb:	66 83 f8 01          	cmp    $0x1,%ax
801065bf:	74 1a                	je     801065db <sys_chdir+0x85>
    iunlockput(ip);
801065c1:	83 ec 0c             	sub    $0xc,%esp
801065c4:	ff 75 f0             	push   -0x10(%ebp)
801065c7:	e8 ed b6 ff ff       	call   80101cb9 <iunlockput>
801065cc:	83 c4 10             	add    $0x10,%esp
    end_op();
801065cf:	e8 2d cc ff ff       	call   80103201 <end_op>
    return -1;
801065d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d9:	eb 33                	jmp    8010660e <sys_chdir+0xb8>
  }
  iunlock(ip);
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	ff 75 f0             	push   -0x10(%ebp)
801065e1:	e8 ad b5 ff ff       	call   80101b93 <iunlock>
801065e6:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ec:	8b 40 68             	mov    0x68(%eax),%eax
801065ef:	83 ec 0c             	sub    $0xc,%esp
801065f2:	50                   	push   %eax
801065f3:	e8 ed b5 ff ff       	call   80101be5 <iput>
801065f8:	83 c4 10             	add    $0x10,%esp
  end_op();
801065fb:	e8 01 cc ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106603:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106606:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106609:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010660e:	c9                   	leave
8010660f:	c3                   	ret

80106610 <sys_exec>:

int
sys_exec(void)
{
80106610:	f3 0f 1e fb          	endbr32
80106614:	55                   	push   %ebp
80106615:	89 e5                	mov    %esp,%ebp
80106617:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010661d:	83 ec 08             	sub    $0x8,%esp
80106620:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106623:	50                   	push   %eax
80106624:	6a 00                	push   $0x0
80106626:	e8 56 f3 ff ff       	call   80105981 <argstr>
8010662b:	83 c4 10             	add    $0x10,%esp
8010662e:	85 c0                	test   %eax,%eax
80106630:	78 18                	js     8010664a <sys_exec+0x3a>
80106632:	83 ec 08             	sub    $0x8,%esp
80106635:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010663b:	50                   	push   %eax
8010663c:	6a 01                	push   $0x1
8010663e:	e8 a1 f2 ff ff       	call   801058e4 <argint>
80106643:	83 c4 10             	add    $0x10,%esp
80106646:	85 c0                	test   %eax,%eax
80106648:	79 0a                	jns    80106654 <sys_exec+0x44>
    return -1;
8010664a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664f:	e9 c6 00 00 00       	jmp    8010671a <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106654:	83 ec 04             	sub    $0x4,%esp
80106657:	68 80 00 00 00       	push   $0x80
8010665c:	6a 00                	push   $0x0
8010665e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106664:	50                   	push   %eax
80106665:	e8 26 ef ff ff       	call   80105590 <memset>
8010666a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010666d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106677:	83 f8 1f             	cmp    $0x1f,%eax
8010667a:	76 0a                	jbe    80106686 <sys_exec+0x76>
      return -1;
8010667c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106681:	e9 94 00 00 00       	jmp    8010671a <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106689:	c1 e0 02             	shl    $0x2,%eax
8010668c:	89 c2                	mov    %eax,%edx
8010668e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106694:	01 c2                	add    %eax,%edx
80106696:	83 ec 08             	sub    $0x8,%esp
80106699:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010669f:	50                   	push   %eax
801066a0:	52                   	push   %edx
801066a1:	e8 93 f1 ff ff       	call   80105839 <fetchint>
801066a6:	83 c4 10             	add    $0x10,%esp
801066a9:	85 c0                	test   %eax,%eax
801066ab:	79 07                	jns    801066b4 <sys_exec+0xa4>
      return -1;
801066ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b2:	eb 66                	jmp    8010671a <sys_exec+0x10a>
    if(uarg == 0){
801066b4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066ba:	85 c0                	test   %eax,%eax
801066bc:	75 27                	jne    801066e5 <sys_exec+0xd5>
      argv[i] = 0;
801066be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c1:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066c8:	00 00 00 00 
      break;
801066cc:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d0:	83 ec 08             	sub    $0x8,%esp
801066d3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066d9:	52                   	push   %edx
801066da:	50                   	push   %eax
801066db:	e8 de a4 ff ff       	call   80100bbe <exec>
801066e0:	83 c4 10             	add    $0x10,%esp
801066e3:	eb 35                	jmp    8010671a <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066e5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066ee:	c1 e2 02             	shl    $0x2,%edx
801066f1:	01 c2                	add    %eax,%edx
801066f3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066f9:	83 ec 08             	sub    $0x8,%esp
801066fc:	52                   	push   %edx
801066fd:	50                   	push   %eax
801066fe:	e8 79 f1 ff ff       	call   8010587c <fetchstr>
80106703:	83 c4 10             	add    $0x10,%esp
80106706:	85 c0                	test   %eax,%eax
80106708:	79 07                	jns    80106711 <sys_exec+0x101>
      return -1;
8010670a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670f:	eb 09                	jmp    8010671a <sys_exec+0x10a>
  for(i=0;; i++){
80106711:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106715:	e9 5a ff ff ff       	jmp    80106674 <sys_exec+0x64>
}
8010671a:	c9                   	leave
8010671b:	c3                   	ret

8010671c <sys_pipe>:

int
sys_pipe(void)
{
8010671c:	f3 0f 1e fb          	endbr32
80106720:	55                   	push   %ebp
80106721:	89 e5                	mov    %esp,%ebp
80106723:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106726:	83 ec 04             	sub    $0x4,%esp
80106729:	6a 08                	push   $0x8
8010672b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010672e:	50                   	push   %eax
8010672f:	6a 00                	push   $0x0
80106731:	e8 df f1 ff ff       	call   80105915 <argptr>
80106736:	83 c4 10             	add    $0x10,%esp
80106739:	85 c0                	test   %eax,%eax
8010673b:	79 0a                	jns    80106747 <sys_pipe+0x2b>
    return -1;
8010673d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106742:	e9 ae 00 00 00       	jmp    801067f5 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106747:	83 ec 08             	sub    $0x8,%esp
8010674a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010674d:	50                   	push   %eax
8010674e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106751:	50                   	push   %eax
80106752:	e8 73 cf ff ff       	call   801036ca <pipealloc>
80106757:	83 c4 10             	add    $0x10,%esp
8010675a:	85 c0                	test   %eax,%eax
8010675c:	79 0a                	jns    80106768 <sys_pipe+0x4c>
    return -1;
8010675e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106763:	e9 8d 00 00 00       	jmp    801067f5 <sys_pipe+0xd9>
  fd0 = -1;
80106768:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010676f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106772:	83 ec 0c             	sub    $0xc,%esp
80106775:	50                   	push   %eax
80106776:	e8 3b f3 ff ff       	call   80105ab6 <fdalloc>
8010677b:	83 c4 10             	add    $0x10,%esp
8010677e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106781:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106785:	78 18                	js     8010679f <sys_pipe+0x83>
80106787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010678a:	83 ec 0c             	sub    $0xc,%esp
8010678d:	50                   	push   %eax
8010678e:	e8 23 f3 ff ff       	call   80105ab6 <fdalloc>
80106793:	83 c4 10             	add    $0x10,%esp
80106796:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106799:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010679d:	79 3e                	jns    801067dd <sys_pipe+0xc1>
    if(fd0 >= 0)
8010679f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a3:	78 13                	js     801067b8 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801067a5:	e8 ff d3 ff ff       	call   80103ba9 <myproc>
801067aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ad:	83 c2 08             	add    $0x8,%edx
801067b0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067b7:	00 
    fileclose(rf);
801067b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067bb:	83 ec 0c             	sub    $0xc,%esp
801067be:	50                   	push   %eax
801067bf:	e8 25 a9 ff ff       	call   801010e9 <fileclose>
801067c4:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ca:	83 ec 0c             	sub    $0xc,%esp
801067cd:	50                   	push   %eax
801067ce:	e8 16 a9 ff ff       	call   801010e9 <fileclose>
801067d3:	83 c4 10             	add    $0x10,%esp
    return -1;
801067d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067db:	eb 18                	jmp    801067f5 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067e3:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067e8:	8d 50 04             	lea    0x4(%eax),%edx
801067eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ee:	89 02                	mov    %eax,(%edx)
  return 0;
801067f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067f5:	c9                   	leave
801067f6:	c3                   	ret

801067f7 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
801067f7:	f3 0f 1e fb          	endbr32
801067fb:	55                   	push   %ebp
801067fc:	89 e5                	mov    %esp,%ebp
801067fe:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
80106801:	83 ec 04             	sub    $0x4,%esp
80106804:	68 00 0c 00 00       	push   $0xc00
80106809:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010680c:	50                   	push   %eax
8010680d:	6a 00                	push   $0x0
8010680f:	e8 01 f1 ff ff       	call   80105915 <argptr>
80106814:	83 c4 10             	add    $0x10,%esp
80106817:	85 c0                	test   %eax,%eax
80106819:	79 07                	jns    80106822 <sys_getpinfo+0x2b>
    return -1;
8010681b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106820:	eb 0f                	jmp    80106831 <sys_getpinfo+0x3a>
  return getpinfo(ps);
80106822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106825:	83 ec 0c             	sub    $0xc,%esp
80106828:	50                   	push   %eax
80106829:	e8 0f e1 ff ff       	call   8010493d <getpinfo>
8010682e:	83 c4 10             	add    $0x10,%esp
}
80106831:	c9                   	leave
80106832:	c3                   	ret

80106833 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
80106833:	f3 0f 1e fb          	endbr32
80106837:	55                   	push   %ebp
80106838:	89 e5                	mov    %esp,%ebp
8010683a:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
8010683d:	83 ec 08             	sub    $0x8,%esp
80106840:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106843:	50                   	push   %eax
80106844:	6a 00                	push   $0x0
80106846:	e8 99 f0 ff ff       	call   801058e4 <argint>
8010684b:	83 c4 10             	add    $0x10,%esp
8010684e:	85 c0                	test   %eax,%eax
80106850:	79 07                	jns    80106859 <sys_setSchedPolicy+0x26>
    return -1;
80106852:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106857:	eb 23                	jmp    8010687c <sys_setSchedPolicy+0x49>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685c:	83 ec 08             	sub    $0x8,%esp
8010685f:	50                   	push   %eax
80106860:	68 f8 b3 10 80       	push   $0x8010b3f8
80106865:	e8 a2 9b ff ff       	call   8010040c <cprintf>
8010686a:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
8010686d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106870:	83 ec 0c             	sub    $0xc,%esp
80106873:	50                   	push   %eax
80106874:	e8 91 e2 ff ff       	call   80104b0a <set_sched_policy>
80106879:	83 c4 10             	add    $0x10,%esp
}
8010687c:	c9                   	leave
8010687d:	c3                   	ret

8010687e <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
8010687e:	f3 0f 1e fb          	endbr32
80106882:	55                   	push   %ebp
80106883:	89 e5                	mov    %esp,%ebp
80106885:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
80106888:	e8 c4 e2 ff ff       	call   80104b51 <get_sched_policy>
}
8010688d:	c9                   	leave
8010688e:	c3                   	ret

8010688f <sys_yield>:
int
sys_yield(void)
{
8010688f:	f3 0f 1e fb          	endbr32
80106893:	55                   	push   %ebp
80106894:	89 e5                	mov    %esp,%ebp
80106896:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
80106899:	e8 57 dd ff ff       	call   801045f5 <yield>
  return 0;
8010689e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068a3:	c9                   	leave
801068a4:	c3                   	ret

801068a5 <sys_fork>:

int
sys_fork(void)
{
801068a5:	f3 0f 1e fb          	endbr32
801068a9:	55                   	push   %ebp
801068aa:	89 e5                	mov    %esp,%ebp
801068ac:	83 ec 08             	sub    $0x8,%esp
  return fork();
801068af:	e8 a6 d6 ff ff       	call   80103f5a <fork>
}
801068b4:	c9                   	leave
801068b5:	c3                   	ret

801068b6 <sys_exit>:

int
sys_exit(void)
{
801068b6:	f3 0f 1e fb          	endbr32
801068ba:	55                   	push   %ebp
801068bb:	89 e5                	mov    %esp,%ebp
801068bd:	83 ec 08             	sub    $0x8,%esp
  exit();
801068c0:	e8 b3 d8 ff ff       	call   80104178 <exit>
  return 0;  // not reached
801068c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068ca:	c9                   	leave
801068cb:	c3                   	ret

801068cc <sys_wait>:

int
sys_wait(void)
{
801068cc:	f3 0f 1e fb          	endbr32
801068d0:	55                   	push   %ebp
801068d1:	89 e5                	mov    %esp,%ebp
801068d3:	83 ec 08             	sub    $0x8,%esp
  return wait();
801068d6:	e8 13 da ff ff       	call   801042ee <wait>
}
801068db:	c9                   	leave
801068dc:	c3                   	ret

801068dd <sys_kill>:

int
sys_kill(void)
{
801068dd:	f3 0f 1e fb          	endbr32
801068e1:	55                   	push   %ebp
801068e2:	89 e5                	mov    %esp,%ebp
801068e4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068e7:	83 ec 08             	sub    $0x8,%esp
801068ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068ed:	50                   	push   %eax
801068ee:	6a 00                	push   $0x0
801068f0:	e8 ef ef ff ff       	call   801058e4 <argint>
801068f5:	83 c4 10             	add    $0x10,%esp
801068f8:	85 c0                	test   %eax,%eax
801068fa:	79 07                	jns    80106903 <sys_kill+0x26>
    return -1;
801068fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106901:	eb 0f                	jmp    80106912 <sys_kill+0x35>
  return kill(pid);
80106903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	50                   	push   %eax
8010690a:	e8 a8 de ff ff       	call   801047b7 <kill>
8010690f:	83 c4 10             	add    $0x10,%esp
}
80106912:	c9                   	leave
80106913:	c3                   	ret

80106914 <sys_getpid>:

int
sys_getpid(void)
{
80106914:	f3 0f 1e fb          	endbr32
80106918:	55                   	push   %ebp
80106919:	89 e5                	mov    %esp,%ebp
8010691b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010691e:	e8 86 d2 ff ff       	call   80103ba9 <myproc>
80106923:	8b 40 10             	mov    0x10(%eax),%eax
}
80106926:	c9                   	leave
80106927:	c3                   	ret

80106928 <sys_sbrk>:

int
sys_sbrk(void)
{
80106928:	f3 0f 1e fb          	endbr32
8010692c:	55                   	push   %ebp
8010692d:	89 e5                	mov    %esp,%ebp
8010692f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106932:	83 ec 08             	sub    $0x8,%esp
80106935:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106938:	50                   	push   %eax
80106939:	6a 00                	push   $0x0
8010693b:	e8 a4 ef ff ff       	call   801058e4 <argint>
80106940:	83 c4 10             	add    $0x10,%esp
80106943:	85 c0                	test   %eax,%eax
80106945:	79 07                	jns    8010694e <sys_sbrk+0x26>
    return -1;
80106947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694c:	eb 27                	jmp    80106975 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010694e:	e8 56 d2 ff ff       	call   80103ba9 <myproc>
80106953:	8b 00                	mov    (%eax),%eax
80106955:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010695b:	83 ec 0c             	sub    $0xc,%esp
8010695e:	50                   	push   %eax
8010695f:	e8 57 d5 ff ff       	call   80103ebb <growproc>
80106964:	83 c4 10             	add    $0x10,%esp
80106967:	85 c0                	test   %eax,%eax
80106969:	79 07                	jns    80106972 <sys_sbrk+0x4a>
    return -1;
8010696b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106970:	eb 03                	jmp    80106975 <sys_sbrk+0x4d>
  return addr;
80106972:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106975:	c9                   	leave
80106976:	c3                   	ret

80106977 <sys_sleep>:

int
sys_sleep(void)
{
80106977:	f3 0f 1e fb          	endbr32
8010697b:	55                   	push   %ebp
8010697c:	89 e5                	mov    %esp,%ebp
8010697e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106981:	83 ec 08             	sub    $0x8,%esp
80106984:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106987:	50                   	push   %eax
80106988:	6a 00                	push   $0x0
8010698a:	e8 55 ef ff ff       	call   801058e4 <argint>
8010698f:	83 c4 10             	add    $0x10,%esp
80106992:	85 c0                	test   %eax,%eax
80106994:	79 07                	jns    8010699d <sys_sleep+0x26>
    return -1;
80106996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699b:	eb 76                	jmp    80106a13 <sys_sleep+0x9c>
  acquire(&tickslock);
8010699d:	83 ec 0c             	sub    $0xc,%esp
801069a0:	68 60 84 19 80       	push   $0x80198460
801069a5:	e8 57 e9 ff ff       	call   80105301 <acquire>
801069aa:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801069ad:	a1 a0 8c 19 80       	mov    0x80198ca0,%eax
801069b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801069b5:	eb 38                	jmp    801069ef <sys_sleep+0x78>
    if(myproc()->killed){
801069b7:	e8 ed d1 ff ff       	call   80103ba9 <myproc>
801069bc:	8b 40 24             	mov    0x24(%eax),%eax
801069bf:	85 c0                	test   %eax,%eax
801069c1:	74 17                	je     801069da <sys_sleep+0x63>
      release(&tickslock);
801069c3:	83 ec 0c             	sub    $0xc,%esp
801069c6:	68 60 84 19 80       	push   $0x80198460
801069cb:	e8 a3 e9 ff ff       	call   80105373 <release>
801069d0:	83 c4 10             	add    $0x10,%esp
      return -1;
801069d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d8:	eb 39                	jmp    80106a13 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801069da:	83 ec 08             	sub    $0x8,%esp
801069dd:	68 60 84 19 80       	push   $0x80198460
801069e2:	68 a0 8c 19 80       	push   $0x80198ca0
801069e7:	e8 91 dc ff ff       	call   8010467d <sleep>
801069ec:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801069ef:	a1 a0 8c 19 80       	mov    0x80198ca0,%eax
801069f4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801069f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069fa:	39 d0                	cmp    %edx,%eax
801069fc:	72 b9                	jb     801069b7 <sys_sleep+0x40>
  }
  release(&tickslock);
801069fe:	83 ec 0c             	sub    $0xc,%esp
80106a01:	68 60 84 19 80       	push   $0x80198460
80106a06:	e8 68 e9 ff ff       	call   80105373 <release>
80106a0b:	83 c4 10             	add    $0x10,%esp
  return 0;
80106a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a13:	c9                   	leave
80106a14:	c3                   	ret

80106a15 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106a15:	f3 0f 1e fb          	endbr32
80106a19:	55                   	push   %ebp
80106a1a:	89 e5                	mov    %esp,%ebp
80106a1c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106a1f:	83 ec 0c             	sub    $0xc,%esp
80106a22:	68 60 84 19 80       	push   $0x80198460
80106a27:	e8 d5 e8 ff ff       	call   80105301 <acquire>
80106a2c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106a2f:	a1 a0 8c 19 80       	mov    0x80198ca0,%eax
80106a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a37:	83 ec 0c             	sub    $0xc,%esp
80106a3a:	68 60 84 19 80       	push   $0x80198460
80106a3f:	e8 2f e9 ff ff       	call   80105373 <release>
80106a44:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a4a:	c9                   	leave
80106a4b:	c3                   	ret

80106a4c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a4c:	1e                   	push   %ds
  pushl %es
80106a4d:	06                   	push   %es
  pushl %fs
80106a4e:	0f a0                	push   %fs
  pushl %gs
80106a50:	0f a8                	push   %gs
  pushal
80106a52:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106a53:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a57:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a59:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a5b:	54                   	push   %esp
  call trap
80106a5c:	e8 df 01 00 00       	call   80106c40 <trap>
  addl $4, %esp
80106a61:	83 c4 04             	add    $0x4,%esp

80106a64 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a64:	61                   	popa
  popl %gs
80106a65:	0f a9                	pop    %gs
  popl %fs
80106a67:	0f a1                	pop    %fs
  popl %es
80106a69:	07                   	pop    %es
  popl %ds
80106a6a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a6b:	83 c4 08             	add    $0x8,%esp
  iret
80106a6e:	cf                   	iret

80106a6f <lidt>:
{
80106a6f:	55                   	push   %ebp
80106a70:	89 e5                	mov    %esp,%ebp
80106a72:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106a75:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a78:	83 e8 01             	sub    $0x1,%eax
80106a7b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a82:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a86:	8b 45 08             	mov    0x8(%ebp),%eax
80106a89:	c1 e8 10             	shr    $0x10,%eax
80106a8c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106a90:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a93:	0f 01 18             	lidtl  (%eax)
}
80106a96:	90                   	nop
80106a97:	c9                   	leave
80106a98:	c3                   	ret

80106a99 <rcr2>:

static inline uint
rcr2(void)
{
80106a99:	55                   	push   %ebp
80106a9a:	89 e5                	mov    %esp,%ebp
80106a9c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a9f:	0f 20 d0             	mov    %cr2,%eax
80106aa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106aa5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106aa8:	c9                   	leave
80106aa9:	c3                   	ret

80106aaa <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106aaa:	f3 0f 1e fb          	endbr32
80106aae:	55                   	push   %ebp
80106aaf:	89 e5                	mov    %esp,%ebp
80106ab1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106abb:	e9 c3 00 00 00       	jmp    80106b83 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac3:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106aca:	89 c2                	mov    %eax,%edx
80106acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acf:	66 89 14 c5 a0 84 19 	mov    %dx,-0x7fe67b60(,%eax,8)
80106ad6:	80 
80106ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ada:	66 c7 04 c5 a2 84 19 	movw   $0x8,-0x7fe67b5e(,%eax,8)
80106ae1:	80 08 00 
80106ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae7:	0f b6 14 c5 a4 84 19 	movzbl -0x7fe67b5c(,%eax,8),%edx
80106aee:	80 
80106aef:	83 e2 e0             	and    $0xffffffe0,%edx
80106af2:	88 14 c5 a4 84 19 80 	mov    %dl,-0x7fe67b5c(,%eax,8)
80106af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afc:	0f b6 14 c5 a4 84 19 	movzbl -0x7fe67b5c(,%eax,8),%edx
80106b03:	80 
80106b04:	83 e2 1f             	and    $0x1f,%edx
80106b07:	88 14 c5 a4 84 19 80 	mov    %dl,-0x7fe67b5c(,%eax,8)
80106b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b11:	0f b6 14 c5 a5 84 19 	movzbl -0x7fe67b5b(,%eax,8),%edx
80106b18:	80 
80106b19:	83 e2 f0             	and    $0xfffffff0,%edx
80106b1c:	83 ca 0e             	or     $0xe,%edx
80106b1f:	88 14 c5 a5 84 19 80 	mov    %dl,-0x7fe67b5b(,%eax,8)
80106b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b29:	0f b6 14 c5 a5 84 19 	movzbl -0x7fe67b5b(,%eax,8),%edx
80106b30:	80 
80106b31:	83 e2 ef             	and    $0xffffffef,%edx
80106b34:	88 14 c5 a5 84 19 80 	mov    %dl,-0x7fe67b5b(,%eax,8)
80106b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3e:	0f b6 14 c5 a5 84 19 	movzbl -0x7fe67b5b(,%eax,8),%edx
80106b45:	80 
80106b46:	83 e2 9f             	and    $0xffffff9f,%edx
80106b49:	88 14 c5 a5 84 19 80 	mov    %dl,-0x7fe67b5b(,%eax,8)
80106b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b53:	0f b6 14 c5 a5 84 19 	movzbl -0x7fe67b5b(,%eax,8),%edx
80106b5a:	80 
80106b5b:	83 ca 80             	or     $0xffffff80,%edx
80106b5e:	88 14 c5 a5 84 19 80 	mov    %dl,-0x7fe67b5b(,%eax,8)
80106b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b68:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106b6f:	c1 e8 10             	shr    $0x10,%eax
80106b72:	89 c2                	mov    %eax,%edx
80106b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b77:	66 89 14 c5 a6 84 19 	mov    %dx,-0x7fe67b5a(,%eax,8)
80106b7e:	80 
  for(i = 0; i < 256; i++)
80106b7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b83:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b8a:	0f 8e 30 ff ff ff    	jle    80106ac0 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b90:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106b95:	66 a3 a0 86 19 80    	mov    %ax,0x801986a0
80106b9b:	66 c7 05 a2 86 19 80 	movw   $0x8,0x801986a2
80106ba2:	08 00 
80106ba4:	0f b6 05 a4 86 19 80 	movzbl 0x801986a4,%eax
80106bab:	83 e0 e0             	and    $0xffffffe0,%eax
80106bae:	a2 a4 86 19 80       	mov    %al,0x801986a4
80106bb3:	0f b6 05 a4 86 19 80 	movzbl 0x801986a4,%eax
80106bba:	83 e0 1f             	and    $0x1f,%eax
80106bbd:	a2 a4 86 19 80       	mov    %al,0x801986a4
80106bc2:	0f b6 05 a5 86 19 80 	movzbl 0x801986a5,%eax
80106bc9:	83 c8 0f             	or     $0xf,%eax
80106bcc:	a2 a5 86 19 80       	mov    %al,0x801986a5
80106bd1:	0f b6 05 a5 86 19 80 	movzbl 0x801986a5,%eax
80106bd8:	83 e0 ef             	and    $0xffffffef,%eax
80106bdb:	a2 a5 86 19 80       	mov    %al,0x801986a5
80106be0:	0f b6 05 a5 86 19 80 	movzbl 0x801986a5,%eax
80106be7:	83 c8 60             	or     $0x60,%eax
80106bea:	a2 a5 86 19 80       	mov    %al,0x801986a5
80106bef:	0f b6 05 a5 86 19 80 	movzbl 0x801986a5,%eax
80106bf6:	83 c8 80             	or     $0xffffff80,%eax
80106bf9:	a2 a5 86 19 80       	mov    %al,0x801986a5
80106bfe:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106c03:	c1 e8 10             	shr    $0x10,%eax
80106c06:	66 a3 a6 86 19 80    	mov    %ax,0x801986a6

  initlock(&tickslock, "time");
80106c0c:	83 ec 08             	sub    $0x8,%esp
80106c0f:	68 24 b4 10 80       	push   $0x8010b424
80106c14:	68 60 84 19 80       	push   $0x80198460
80106c19:	e8 bd e6 ff ff       	call   801052db <initlock>
80106c1e:	83 c4 10             	add    $0x10,%esp
}
80106c21:	90                   	nop
80106c22:	c9                   	leave
80106c23:	c3                   	ret

80106c24 <idtinit>:

void
idtinit(void)
{
80106c24:	f3 0f 1e fb          	endbr32
80106c28:	55                   	push   %ebp
80106c29:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c2b:	68 00 08 00 00       	push   $0x800
80106c30:	68 a0 84 19 80       	push   $0x801984a0
80106c35:	e8 35 fe ff ff       	call   80106a6f <lidt>
80106c3a:	83 c4 08             	add    $0x8,%esp
}
80106c3d:	90                   	nop
80106c3e:	c9                   	leave
80106c3f:	c3                   	ret

80106c40 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c40:	f3 0f 1e fb          	endbr32
80106c44:	55                   	push   %ebp
80106c45:	89 e5                	mov    %esp,%ebp
80106c47:	57                   	push   %edi
80106c48:	56                   	push   %esi
80106c49:	53                   	push   %ebx
80106c4a:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c50:	8b 40 30             	mov    0x30(%eax),%eax
80106c53:	83 f8 40             	cmp    $0x40,%eax
80106c56:	75 3b                	jne    80106c93 <trap+0x53>
    if(myproc()->killed)
80106c58:	e8 4c cf ff ff       	call   80103ba9 <myproc>
80106c5d:	8b 40 24             	mov    0x24(%eax),%eax
80106c60:	85 c0                	test   %eax,%eax
80106c62:	74 05                	je     80106c69 <trap+0x29>
      exit();
80106c64:	e8 0f d5 ff ff       	call   80104178 <exit>
    myproc()->tf = tf;
80106c69:	e8 3b cf ff ff       	call   80103ba9 <myproc>
80106c6e:	8b 55 08             	mov    0x8(%ebp),%edx
80106c71:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c74:	e8 43 ed ff ff       	call   801059bc <syscall>
    if(myproc()->killed)
80106c79:	e8 2b cf ff ff       	call   80103ba9 <myproc>
80106c7e:	8b 40 24             	mov    0x24(%eax),%eax
80106c81:	85 c0                	test   %eax,%eax
80106c83:	0f 84 e6 02 00 00    	je     80106f6f <trap+0x32f>
      exit();
80106c89:	e8 ea d4 ff ff       	call   80104178 <exit>
    return;
80106c8e:	e9 dc 02 00 00       	jmp    80106f6f <trap+0x32f>
  }

  switch(tf->trapno){
80106c93:	8b 45 08             	mov    0x8(%ebp),%eax
80106c96:	8b 40 30             	mov    0x30(%eax),%eax
80106c99:	83 e8 20             	sub    $0x20,%eax
80106c9c:	83 f8 1f             	cmp    $0x1f,%eax
80106c9f:	0f 87 95 01 00 00    	ja     80106e3a <trap+0x1fa>
80106ca5:	8b 04 85 cc b4 10 80 	mov    -0x7fef4b34(,%eax,4),%eax
80106cac:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106caf:	e8 5a ce ff ff       	call   80103b0e <cpuid>
80106cb4:	85 c0                	test   %eax,%eax
80106cb6:	75 3d                	jne    80106cf5 <trap+0xb5>
      acquire(&tickslock);
80106cb8:	83 ec 0c             	sub    $0xc,%esp
80106cbb:	68 60 84 19 80       	push   $0x80198460
80106cc0:	e8 3c e6 ff ff       	call   80105301 <acquire>
80106cc5:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106cc8:	a1 a0 8c 19 80       	mov    0x80198ca0,%eax
80106ccd:	83 c0 01             	add    $0x1,%eax
80106cd0:	a3 a0 8c 19 80       	mov    %eax,0x80198ca0
      wakeup(&ticks);
80106cd5:	83 ec 0c             	sub    $0xc,%esp
80106cd8:	68 a0 8c 19 80       	push   $0x80198ca0
80106cdd:	e8 9a da ff ff       	call   8010477c <wakeup>
80106ce2:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106ce5:	83 ec 0c             	sub    $0xc,%esp
80106ce8:	68 60 84 19 80       	push   $0x80198460
80106ced:	e8 81 e6 ff ff       	call   80105373 <release>
80106cf2:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106cf5:	e8 af ce ff ff       	call   80103ba9 <myproc>
80106cfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106cfd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106d01:	0f 84 be 00 00 00    	je     80106dc5 <trap+0x185>
80106d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d0a:	8b 40 0c             	mov    0xc(%eax),%eax
80106d0d:	83 f8 04             	cmp    $0x4,%eax
80106d10:	0f 85 af 00 00 00    	jne    80106dc5 <trap+0x185>
80106d16:	e8 12 ce ff ff       	call   80103b2d <mycpu>
80106d1b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106d21:	85 c0                	test   %eax,%eax
80106d23:	0f 84 9c 00 00 00    	je     80106dc5 <trap+0x185>
      int idx = myproc() - ptable.proc;
80106d29:	e8 7b ce ff ff       	call   80103ba9 <myproc>
80106d2e:	2d 54 65 19 80       	sub    $0x80196554,%eax
80106d33:	c1 f8 02             	sar    $0x2,%eax
80106d36:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106d3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106d3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d42:	83 e8 80             	sub    $0xffffff80,%eax
80106d45:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80106d4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106d59:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d5c:	01 d0                	add    %edx,%eax
80106d5e:	05 00 01 00 00       	add    $0x100,%eax
80106d63:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80106d6a:	8d 50 01             	lea    0x1(%eax),%edx
80106d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d70:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106d77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d7a:	01 c8                	add    %ecx,%eax
80106d7c:	05 00 01 00 00       	add    $0x100,%eax
80106d81:	89 14 85 20 59 19 80 	mov    %edx,-0x7fe6a6e0(,%eax,4)
      kernel_pstat.wait_ticks[idx][q] = 0; // 실행된 큐의 wait_ticks 초기화화
80106d88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106d8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d95:	01 d0                	add    %edx,%eax
80106d97:	05 00 02 00 00       	add    $0x200,%eax
80106d9c:	c7 04 85 20 59 19 80 	movl   $0x0,-0x7fe6a6e0(,%eax,4)
80106da3:	00 00 00 00 

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106daa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106db1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106db4:	01 d0                	add    %edx,%eax
80106db6:	05 00 01 00 00       	add    $0x100,%eax
80106dbb:	8b 04 85 20 59 19 80 	mov    -0x7fe6a6e0(,%eax,4),%eax
80106dc2:	83 f8 01             	cmp    $0x1,%eax
        // cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
        //         myproc()->pid, q, kernel_pstat.ticks[idx][q]);
      }
    }

    lapiceoi();
80106dc5:	e8 5b be ff ff       	call   80102c25 <lapiceoi>
    break;
80106dca:	e9 20 01 00 00       	jmp    80106eef <trap+0x2af>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106dcf:	e8 1a 40 00 00       	call   8010adee <ideintr>
    lapiceoi();
80106dd4:	e8 4c be ff ff       	call   80102c25 <lapiceoi>
    break;
80106dd9:	e9 11 01 00 00       	jmp    80106eef <trap+0x2af>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106dde:	e8 78 bc ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106de3:	e8 3d be ff ff       	call   80102c25 <lapiceoi>
    break;
80106de8:	e9 02 01 00 00       	jmp    80106eef <trap+0x2af>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ded:	e8 5f 03 00 00       	call   80107151 <uartintr>
    lapiceoi();
80106df2:	e8 2e be ff ff       	call   80102c25 <lapiceoi>
    break;
80106df7:	e9 f3 00 00 00       	jmp    80106eef <trap+0x2af>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106dfc:	e8 2c 2c 00 00       	call   80109a2d <i8254_intr>
    lapiceoi();
80106e01:	e8 1f be ff ff       	call   80102c25 <lapiceoi>
    break;
80106e06:	e9 e4 00 00 00       	jmp    80106eef <trap+0x2af>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e0e:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106e11:	8b 45 08             	mov    0x8(%ebp),%eax
80106e14:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e18:	0f b7 d8             	movzwl %ax,%ebx
80106e1b:	e8 ee cc ff ff       	call   80103b0e <cpuid>
80106e20:	56                   	push   %esi
80106e21:	53                   	push   %ebx
80106e22:	50                   	push   %eax
80106e23:	68 2c b4 10 80       	push   $0x8010b42c
80106e28:	e8 df 95 ff ff       	call   8010040c <cprintf>
80106e2d:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106e30:	e8 f0 bd ff ff       	call   80102c25 <lapiceoi>
    break;
80106e35:	e9 b5 00 00 00       	jmp    80106eef <trap+0x2af>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e3a:	e8 6a cd ff ff       	call   80103ba9 <myproc>
80106e3f:	85 c0                	test   %eax,%eax
80106e41:	74 11                	je     80106e54 <trap+0x214>
80106e43:	8b 45 08             	mov    0x8(%ebp),%eax
80106e46:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e4a:	0f b7 c0             	movzwl %ax,%eax
80106e4d:	83 e0 03             	and    $0x3,%eax
80106e50:	85 c0                	test   %eax,%eax
80106e52:	75 39                	jne    80106e8d <trap+0x24d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e54:	e8 40 fc ff ff       	call   80106a99 <rcr2>
80106e59:	89 c3                	mov    %eax,%ebx
80106e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5e:	8b 70 38             	mov    0x38(%eax),%esi
80106e61:	e8 a8 cc ff ff       	call   80103b0e <cpuid>
80106e66:	8b 55 08             	mov    0x8(%ebp),%edx
80106e69:	8b 52 30             	mov    0x30(%edx),%edx
80106e6c:	83 ec 0c             	sub    $0xc,%esp
80106e6f:	53                   	push   %ebx
80106e70:	56                   	push   %esi
80106e71:	50                   	push   %eax
80106e72:	52                   	push   %edx
80106e73:	68 50 b4 10 80       	push   $0x8010b450
80106e78:	e8 8f 95 ff ff       	call   8010040c <cprintf>
80106e7d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e80:	83 ec 0c             	sub    $0xc,%esp
80106e83:	68 82 b4 10 80       	push   $0x8010b482
80106e88:	e8 38 97 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e8d:	e8 07 fc ff ff       	call   80106a99 <rcr2>
80106e92:	89 c6                	mov    %eax,%esi
80106e94:	8b 45 08             	mov    0x8(%ebp),%eax
80106e97:	8b 40 38             	mov    0x38(%eax),%eax
80106e9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e9d:	e8 6c cc ff ff       	call   80103b0e <cpuid>
80106ea2:	89 c3                	mov    %eax,%ebx
80106ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ea7:	8b 48 34             	mov    0x34(%eax),%ecx
80106eaa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106ead:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb0:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106eb3:	e8 f1 cc ff ff       	call   80103ba9 <myproc>
80106eb8:	8d 50 6c             	lea    0x6c(%eax),%edx
80106ebb:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106ebe:	e8 e6 cc ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ec3:	8b 40 10             	mov    0x10(%eax),%eax
80106ec6:	56                   	push   %esi
80106ec7:	ff 75 d4             	push   -0x2c(%ebp)
80106eca:	53                   	push   %ebx
80106ecb:	ff 75 d0             	push   -0x30(%ebp)
80106ece:	57                   	push   %edi
80106ecf:	ff 75 cc             	push   -0x34(%ebp)
80106ed2:	50                   	push   %eax
80106ed3:	68 88 b4 10 80       	push   $0x8010b488
80106ed8:	e8 2f 95 ff ff       	call   8010040c <cprintf>
80106edd:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ee0:	e8 c4 cc ff ff       	call   80103ba9 <myproc>
80106ee5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106eec:	eb 01                	jmp    80106eef <trap+0x2af>
    break;
80106eee:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eef:	e8 b5 cc ff ff       	call   80103ba9 <myproc>
80106ef4:	85 c0                	test   %eax,%eax
80106ef6:	74 23                	je     80106f1b <trap+0x2db>
80106ef8:	e8 ac cc ff ff       	call   80103ba9 <myproc>
80106efd:	8b 40 24             	mov    0x24(%eax),%eax
80106f00:	85 c0                	test   %eax,%eax
80106f02:	74 17                	je     80106f1b <trap+0x2db>
80106f04:	8b 45 08             	mov    0x8(%ebp),%eax
80106f07:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f0b:	0f b7 c0             	movzwl %ax,%eax
80106f0e:	83 e0 03             	and    $0x3,%eax
80106f11:	83 f8 03             	cmp    $0x3,%eax
80106f14:	75 05                	jne    80106f1b <trap+0x2db>
    exit();
80106f16:	e8 5d d2 ff ff       	call   80104178 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f1b:	e8 89 cc ff ff       	call   80103ba9 <myproc>
80106f20:	85 c0                	test   %eax,%eax
80106f22:	74 1d                	je     80106f41 <trap+0x301>
80106f24:	e8 80 cc ff ff       	call   80103ba9 <myproc>
80106f29:	8b 40 0c             	mov    0xc(%eax),%eax
80106f2c:	83 f8 04             	cmp    $0x4,%eax
80106f2f:	75 10                	jne    80106f41 <trap+0x301>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f31:	8b 45 08             	mov    0x8(%ebp),%eax
80106f34:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f37:	83 f8 20             	cmp    $0x20,%eax
80106f3a:	75 05                	jne    80106f41 <trap+0x301>
    yield();
80106f3c:	e8 b4 d6 ff ff       	call   801045f5 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f41:	e8 63 cc ff ff       	call   80103ba9 <myproc>
80106f46:	85 c0                	test   %eax,%eax
80106f48:	74 26                	je     80106f70 <trap+0x330>
80106f4a:	e8 5a cc ff ff       	call   80103ba9 <myproc>
80106f4f:	8b 40 24             	mov    0x24(%eax),%eax
80106f52:	85 c0                	test   %eax,%eax
80106f54:	74 1a                	je     80106f70 <trap+0x330>
80106f56:	8b 45 08             	mov    0x8(%ebp),%eax
80106f59:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f5d:	0f b7 c0             	movzwl %ax,%eax
80106f60:	83 e0 03             	and    $0x3,%eax
80106f63:	83 f8 03             	cmp    $0x3,%eax
80106f66:	75 08                	jne    80106f70 <trap+0x330>
    exit();
80106f68:	e8 0b d2 ff ff       	call   80104178 <exit>
80106f6d:	eb 01                	jmp    80106f70 <trap+0x330>
    return;
80106f6f:	90                   	nop
}
80106f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f73:	5b                   	pop    %ebx
80106f74:	5e                   	pop    %esi
80106f75:	5f                   	pop    %edi
80106f76:	5d                   	pop    %ebp
80106f77:	c3                   	ret

80106f78 <inb>:
{
80106f78:	55                   	push   %ebp
80106f79:	89 e5                	mov    %esp,%ebp
80106f7b:	83 ec 14             	sub    $0x14,%esp
80106f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f89:	89 c2                	mov    %eax,%edx
80106f8b:	ec                   	in     (%dx),%al
80106f8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f93:	c9                   	leave
80106f94:	c3                   	ret

80106f95 <outb>:
{
80106f95:	55                   	push   %ebp
80106f96:	89 e5                	mov    %esp,%ebp
80106f98:	83 ec 08             	sub    $0x8,%esp
80106f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106fa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106fa5:	89 d0                	mov    %edx,%eax
80106fa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106faa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fb2:	ee                   	out    %al,(%dx)
}
80106fb3:	90                   	nop
80106fb4:	c9                   	leave
80106fb5:	c3                   	ret

80106fb6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fb6:	f3 0f 1e fb          	endbr32
80106fba:	55                   	push   %ebp
80106fbb:	89 e5                	mov    %esp,%ebp
80106fbd:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fc0:	6a 00                	push   $0x0
80106fc2:	68 fa 03 00 00       	push   $0x3fa
80106fc7:	e8 c9 ff ff ff       	call   80106f95 <outb>
80106fcc:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fcf:	68 80 00 00 00       	push   $0x80
80106fd4:	68 fb 03 00 00       	push   $0x3fb
80106fd9:	e8 b7 ff ff ff       	call   80106f95 <outb>
80106fde:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fe1:	6a 0c                	push   $0xc
80106fe3:	68 f8 03 00 00       	push   $0x3f8
80106fe8:	e8 a8 ff ff ff       	call   80106f95 <outb>
80106fed:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ff0:	6a 00                	push   $0x0
80106ff2:	68 f9 03 00 00       	push   $0x3f9
80106ff7:	e8 99 ff ff ff       	call   80106f95 <outb>
80106ffc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fff:	6a 03                	push   $0x3
80107001:	68 fb 03 00 00       	push   $0x3fb
80107006:	e8 8a ff ff ff       	call   80106f95 <outb>
8010700b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010700e:	6a 00                	push   $0x0
80107010:	68 fc 03 00 00       	push   $0x3fc
80107015:	e8 7b ff ff ff       	call   80106f95 <outb>
8010701a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010701d:	6a 01                	push   $0x1
8010701f:	68 f9 03 00 00       	push   $0x3f9
80107024:	e8 6c ff ff ff       	call   80106f95 <outb>
80107029:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010702c:	68 fd 03 00 00       	push   $0x3fd
80107031:	e8 42 ff ff ff       	call   80106f78 <inb>
80107036:	83 c4 04             	add    $0x4,%esp
80107039:	3c ff                	cmp    $0xff,%al
8010703b:	74 61                	je     8010709e <uartinit+0xe8>
    return;
  uart = 1;
8010703d:	c7 05 80 d0 18 80 01 	movl   $0x1,0x8018d080
80107044:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107047:	68 fa 03 00 00       	push   $0x3fa
8010704c:	e8 27 ff ff ff       	call   80106f78 <inb>
80107051:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107054:	68 f8 03 00 00       	push   $0x3f8
80107059:	e8 1a ff ff ff       	call   80106f78 <inb>
8010705e:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107061:	83 ec 08             	sub    $0x8,%esp
80107064:	6a 00                	push   $0x0
80107066:	6a 04                	push   $0x4
80107068:	e8 9f b6 ff ff       	call   8010270c <ioapicenable>
8010706d:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107070:	c7 45 f4 4c b5 10 80 	movl   $0x8010b54c,-0xc(%ebp)
80107077:	eb 19                	jmp    80107092 <uartinit+0xdc>
    uartputc(*p);
80107079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707c:	0f b6 00             	movzbl (%eax),%eax
8010707f:	0f be c0             	movsbl %al,%eax
80107082:	83 ec 0c             	sub    $0xc,%esp
80107085:	50                   	push   %eax
80107086:	e8 16 00 00 00       	call   801070a1 <uartputc>
8010708b:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010708e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107095:	0f b6 00             	movzbl (%eax),%eax
80107098:	84 c0                	test   %al,%al
8010709a:	75 dd                	jne    80107079 <uartinit+0xc3>
8010709c:	eb 01                	jmp    8010709f <uartinit+0xe9>
    return;
8010709e:	90                   	nop
}
8010709f:	c9                   	leave
801070a0:	c3                   	ret

801070a1 <uartputc>:

void
uartputc(int c)
{
801070a1:	f3 0f 1e fb          	endbr32
801070a5:	55                   	push   %ebp
801070a6:	89 e5                	mov    %esp,%ebp
801070a8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801070ab:	a1 80 d0 18 80       	mov    0x8018d080,%eax
801070b0:	85 c0                	test   %eax,%eax
801070b2:	74 53                	je     80107107 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070bb:	eb 11                	jmp    801070ce <uartputc+0x2d>
    microdelay(10);
801070bd:	83 ec 0c             	sub    $0xc,%esp
801070c0:	6a 0a                	push   $0xa
801070c2:	e8 7d bb ff ff       	call   80102c44 <microdelay>
801070c7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070ce:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070d2:	7f 1a                	jg     801070ee <uartputc+0x4d>
801070d4:	83 ec 0c             	sub    $0xc,%esp
801070d7:	68 fd 03 00 00       	push   $0x3fd
801070dc:	e8 97 fe ff ff       	call   80106f78 <inb>
801070e1:	83 c4 10             	add    $0x10,%esp
801070e4:	0f b6 c0             	movzbl %al,%eax
801070e7:	83 e0 20             	and    $0x20,%eax
801070ea:	85 c0                	test   %eax,%eax
801070ec:	74 cf                	je     801070bd <uartputc+0x1c>
  outb(COM1+0, c);
801070ee:	8b 45 08             	mov    0x8(%ebp),%eax
801070f1:	0f b6 c0             	movzbl %al,%eax
801070f4:	83 ec 08             	sub    $0x8,%esp
801070f7:	50                   	push   %eax
801070f8:	68 f8 03 00 00       	push   $0x3f8
801070fd:	e8 93 fe ff ff       	call   80106f95 <outb>
80107102:	83 c4 10             	add    $0x10,%esp
80107105:	eb 01                	jmp    80107108 <uartputc+0x67>
    return;
80107107:	90                   	nop
}
80107108:	c9                   	leave
80107109:	c3                   	ret

8010710a <uartgetc>:

static int
uartgetc(void)
{
8010710a:	f3 0f 1e fb          	endbr32
8010710e:	55                   	push   %ebp
8010710f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107111:	a1 80 d0 18 80       	mov    0x8018d080,%eax
80107116:	85 c0                	test   %eax,%eax
80107118:	75 07                	jne    80107121 <uartgetc+0x17>
    return -1;
8010711a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010711f:	eb 2e                	jmp    8010714f <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107121:	68 fd 03 00 00       	push   $0x3fd
80107126:	e8 4d fe ff ff       	call   80106f78 <inb>
8010712b:	83 c4 04             	add    $0x4,%esp
8010712e:	0f b6 c0             	movzbl %al,%eax
80107131:	83 e0 01             	and    $0x1,%eax
80107134:	85 c0                	test   %eax,%eax
80107136:	75 07                	jne    8010713f <uartgetc+0x35>
    return -1;
80107138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713d:	eb 10                	jmp    8010714f <uartgetc+0x45>
  return inb(COM1+0);
8010713f:	68 f8 03 00 00       	push   $0x3f8
80107144:	e8 2f fe ff ff       	call   80106f78 <inb>
80107149:	83 c4 04             	add    $0x4,%esp
8010714c:	0f b6 c0             	movzbl %al,%eax
}
8010714f:	c9                   	leave
80107150:	c3                   	ret

80107151 <uartintr>:

void
uartintr(void)
{
80107151:	f3 0f 1e fb          	endbr32
80107155:	55                   	push   %ebp
80107156:	89 e5                	mov    %esp,%ebp
80107158:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010715b:	83 ec 0c             	sub    $0xc,%esp
8010715e:	68 0a 71 10 80       	push   $0x8010710a
80107163:	e8 98 96 ff ff       	call   80100800 <consoleintr>
80107168:	83 c4 10             	add    $0x10,%esp
}
8010716b:	90                   	nop
8010716c:	c9                   	leave
8010716d:	c3                   	ret

8010716e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $0
80107170:	6a 00                	push   $0x0
  jmp alltraps
80107172:	e9 d5 f8 ff ff       	jmp    80106a4c <alltraps>

80107177 <vector1>:
.globl vector1
vector1:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $1
80107179:	6a 01                	push   $0x1
  jmp alltraps
8010717b:	e9 cc f8 ff ff       	jmp    80106a4c <alltraps>

80107180 <vector2>:
.globl vector2
vector2:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $2
80107182:	6a 02                	push   $0x2
  jmp alltraps
80107184:	e9 c3 f8 ff ff       	jmp    80106a4c <alltraps>

80107189 <vector3>:
.globl vector3
vector3:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $3
8010718b:	6a 03                	push   $0x3
  jmp alltraps
8010718d:	e9 ba f8 ff ff       	jmp    80106a4c <alltraps>

80107192 <vector4>:
.globl vector4
vector4:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $4
80107194:	6a 04                	push   $0x4
  jmp alltraps
80107196:	e9 b1 f8 ff ff       	jmp    80106a4c <alltraps>

8010719b <vector5>:
.globl vector5
vector5:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $5
8010719d:	6a 05                	push   $0x5
  jmp alltraps
8010719f:	e9 a8 f8 ff ff       	jmp    80106a4c <alltraps>

801071a4 <vector6>:
.globl vector6
vector6:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $6
801071a6:	6a 06                	push   $0x6
  jmp alltraps
801071a8:	e9 9f f8 ff ff       	jmp    80106a4c <alltraps>

801071ad <vector7>:
.globl vector7
vector7:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $7
801071af:	6a 07                	push   $0x7
  jmp alltraps
801071b1:	e9 96 f8 ff ff       	jmp    80106a4c <alltraps>

801071b6 <vector8>:
.globl vector8
vector8:
  pushl $8
801071b6:	6a 08                	push   $0x8
  jmp alltraps
801071b8:	e9 8f f8 ff ff       	jmp    80106a4c <alltraps>

801071bd <vector9>:
.globl vector9
vector9:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $9
801071bf:	6a 09                	push   $0x9
  jmp alltraps
801071c1:	e9 86 f8 ff ff       	jmp    80106a4c <alltraps>

801071c6 <vector10>:
.globl vector10
vector10:
  pushl $10
801071c6:	6a 0a                	push   $0xa
  jmp alltraps
801071c8:	e9 7f f8 ff ff       	jmp    80106a4c <alltraps>

801071cd <vector11>:
.globl vector11
vector11:
  pushl $11
801071cd:	6a 0b                	push   $0xb
  jmp alltraps
801071cf:	e9 78 f8 ff ff       	jmp    80106a4c <alltraps>

801071d4 <vector12>:
.globl vector12
vector12:
  pushl $12
801071d4:	6a 0c                	push   $0xc
  jmp alltraps
801071d6:	e9 71 f8 ff ff       	jmp    80106a4c <alltraps>

801071db <vector13>:
.globl vector13
vector13:
  pushl $13
801071db:	6a 0d                	push   $0xd
  jmp alltraps
801071dd:	e9 6a f8 ff ff       	jmp    80106a4c <alltraps>

801071e2 <vector14>:
.globl vector14
vector14:
  pushl $14
801071e2:	6a 0e                	push   $0xe
  jmp alltraps
801071e4:	e9 63 f8 ff ff       	jmp    80106a4c <alltraps>

801071e9 <vector15>:
.globl vector15
vector15:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $15
801071eb:	6a 0f                	push   $0xf
  jmp alltraps
801071ed:	e9 5a f8 ff ff       	jmp    80106a4c <alltraps>

801071f2 <vector16>:
.globl vector16
vector16:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $16
801071f4:	6a 10                	push   $0x10
  jmp alltraps
801071f6:	e9 51 f8 ff ff       	jmp    80106a4c <alltraps>

801071fb <vector17>:
.globl vector17
vector17:
  pushl $17
801071fb:	6a 11                	push   $0x11
  jmp alltraps
801071fd:	e9 4a f8 ff ff       	jmp    80106a4c <alltraps>

80107202 <vector18>:
.globl vector18
vector18:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $18
80107204:	6a 12                	push   $0x12
  jmp alltraps
80107206:	e9 41 f8 ff ff       	jmp    80106a4c <alltraps>

8010720b <vector19>:
.globl vector19
vector19:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $19
8010720d:	6a 13                	push   $0x13
  jmp alltraps
8010720f:	e9 38 f8 ff ff       	jmp    80106a4c <alltraps>

80107214 <vector20>:
.globl vector20
vector20:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $20
80107216:	6a 14                	push   $0x14
  jmp alltraps
80107218:	e9 2f f8 ff ff       	jmp    80106a4c <alltraps>

8010721d <vector21>:
.globl vector21
vector21:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $21
8010721f:	6a 15                	push   $0x15
  jmp alltraps
80107221:	e9 26 f8 ff ff       	jmp    80106a4c <alltraps>

80107226 <vector22>:
.globl vector22
vector22:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $22
80107228:	6a 16                	push   $0x16
  jmp alltraps
8010722a:	e9 1d f8 ff ff       	jmp    80106a4c <alltraps>

8010722f <vector23>:
.globl vector23
vector23:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $23
80107231:	6a 17                	push   $0x17
  jmp alltraps
80107233:	e9 14 f8 ff ff       	jmp    80106a4c <alltraps>

80107238 <vector24>:
.globl vector24
vector24:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $24
8010723a:	6a 18                	push   $0x18
  jmp alltraps
8010723c:	e9 0b f8 ff ff       	jmp    80106a4c <alltraps>

80107241 <vector25>:
.globl vector25
vector25:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $25
80107243:	6a 19                	push   $0x19
  jmp alltraps
80107245:	e9 02 f8 ff ff       	jmp    80106a4c <alltraps>

8010724a <vector26>:
.globl vector26
vector26:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $26
8010724c:	6a 1a                	push   $0x1a
  jmp alltraps
8010724e:	e9 f9 f7 ff ff       	jmp    80106a4c <alltraps>

80107253 <vector27>:
.globl vector27
vector27:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $27
80107255:	6a 1b                	push   $0x1b
  jmp alltraps
80107257:	e9 f0 f7 ff ff       	jmp    80106a4c <alltraps>

8010725c <vector28>:
.globl vector28
vector28:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $28
8010725e:	6a 1c                	push   $0x1c
  jmp alltraps
80107260:	e9 e7 f7 ff ff       	jmp    80106a4c <alltraps>

80107265 <vector29>:
.globl vector29
vector29:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $29
80107267:	6a 1d                	push   $0x1d
  jmp alltraps
80107269:	e9 de f7 ff ff       	jmp    80106a4c <alltraps>

8010726e <vector30>:
.globl vector30
vector30:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $30
80107270:	6a 1e                	push   $0x1e
  jmp alltraps
80107272:	e9 d5 f7 ff ff       	jmp    80106a4c <alltraps>

80107277 <vector31>:
.globl vector31
vector31:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $31
80107279:	6a 1f                	push   $0x1f
  jmp alltraps
8010727b:	e9 cc f7 ff ff       	jmp    80106a4c <alltraps>

80107280 <vector32>:
.globl vector32
vector32:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $32
80107282:	6a 20                	push   $0x20
  jmp alltraps
80107284:	e9 c3 f7 ff ff       	jmp    80106a4c <alltraps>

80107289 <vector33>:
.globl vector33
vector33:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $33
8010728b:	6a 21                	push   $0x21
  jmp alltraps
8010728d:	e9 ba f7 ff ff       	jmp    80106a4c <alltraps>

80107292 <vector34>:
.globl vector34
vector34:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $34
80107294:	6a 22                	push   $0x22
  jmp alltraps
80107296:	e9 b1 f7 ff ff       	jmp    80106a4c <alltraps>

8010729b <vector35>:
.globl vector35
vector35:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $35
8010729d:	6a 23                	push   $0x23
  jmp alltraps
8010729f:	e9 a8 f7 ff ff       	jmp    80106a4c <alltraps>

801072a4 <vector36>:
.globl vector36
vector36:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $36
801072a6:	6a 24                	push   $0x24
  jmp alltraps
801072a8:	e9 9f f7 ff ff       	jmp    80106a4c <alltraps>

801072ad <vector37>:
.globl vector37
vector37:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $37
801072af:	6a 25                	push   $0x25
  jmp alltraps
801072b1:	e9 96 f7 ff ff       	jmp    80106a4c <alltraps>

801072b6 <vector38>:
.globl vector38
vector38:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $38
801072b8:	6a 26                	push   $0x26
  jmp alltraps
801072ba:	e9 8d f7 ff ff       	jmp    80106a4c <alltraps>

801072bf <vector39>:
.globl vector39
vector39:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $39
801072c1:	6a 27                	push   $0x27
  jmp alltraps
801072c3:	e9 84 f7 ff ff       	jmp    80106a4c <alltraps>

801072c8 <vector40>:
.globl vector40
vector40:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $40
801072ca:	6a 28                	push   $0x28
  jmp alltraps
801072cc:	e9 7b f7 ff ff       	jmp    80106a4c <alltraps>

801072d1 <vector41>:
.globl vector41
vector41:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $41
801072d3:	6a 29                	push   $0x29
  jmp alltraps
801072d5:	e9 72 f7 ff ff       	jmp    80106a4c <alltraps>

801072da <vector42>:
.globl vector42
vector42:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $42
801072dc:	6a 2a                	push   $0x2a
  jmp alltraps
801072de:	e9 69 f7 ff ff       	jmp    80106a4c <alltraps>

801072e3 <vector43>:
.globl vector43
vector43:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $43
801072e5:	6a 2b                	push   $0x2b
  jmp alltraps
801072e7:	e9 60 f7 ff ff       	jmp    80106a4c <alltraps>

801072ec <vector44>:
.globl vector44
vector44:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $44
801072ee:	6a 2c                	push   $0x2c
  jmp alltraps
801072f0:	e9 57 f7 ff ff       	jmp    80106a4c <alltraps>

801072f5 <vector45>:
.globl vector45
vector45:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $45
801072f7:	6a 2d                	push   $0x2d
  jmp alltraps
801072f9:	e9 4e f7 ff ff       	jmp    80106a4c <alltraps>

801072fe <vector46>:
.globl vector46
vector46:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $46
80107300:	6a 2e                	push   $0x2e
  jmp alltraps
80107302:	e9 45 f7 ff ff       	jmp    80106a4c <alltraps>

80107307 <vector47>:
.globl vector47
vector47:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $47
80107309:	6a 2f                	push   $0x2f
  jmp alltraps
8010730b:	e9 3c f7 ff ff       	jmp    80106a4c <alltraps>

80107310 <vector48>:
.globl vector48
vector48:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $48
80107312:	6a 30                	push   $0x30
  jmp alltraps
80107314:	e9 33 f7 ff ff       	jmp    80106a4c <alltraps>

80107319 <vector49>:
.globl vector49
vector49:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $49
8010731b:	6a 31                	push   $0x31
  jmp alltraps
8010731d:	e9 2a f7 ff ff       	jmp    80106a4c <alltraps>

80107322 <vector50>:
.globl vector50
vector50:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $50
80107324:	6a 32                	push   $0x32
  jmp alltraps
80107326:	e9 21 f7 ff ff       	jmp    80106a4c <alltraps>

8010732b <vector51>:
.globl vector51
vector51:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $51
8010732d:	6a 33                	push   $0x33
  jmp alltraps
8010732f:	e9 18 f7 ff ff       	jmp    80106a4c <alltraps>

80107334 <vector52>:
.globl vector52
vector52:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $52
80107336:	6a 34                	push   $0x34
  jmp alltraps
80107338:	e9 0f f7 ff ff       	jmp    80106a4c <alltraps>

8010733d <vector53>:
.globl vector53
vector53:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $53
8010733f:	6a 35                	push   $0x35
  jmp alltraps
80107341:	e9 06 f7 ff ff       	jmp    80106a4c <alltraps>

80107346 <vector54>:
.globl vector54
vector54:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $54
80107348:	6a 36                	push   $0x36
  jmp alltraps
8010734a:	e9 fd f6 ff ff       	jmp    80106a4c <alltraps>

8010734f <vector55>:
.globl vector55
vector55:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $55
80107351:	6a 37                	push   $0x37
  jmp alltraps
80107353:	e9 f4 f6 ff ff       	jmp    80106a4c <alltraps>

80107358 <vector56>:
.globl vector56
vector56:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $56
8010735a:	6a 38                	push   $0x38
  jmp alltraps
8010735c:	e9 eb f6 ff ff       	jmp    80106a4c <alltraps>

80107361 <vector57>:
.globl vector57
vector57:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $57
80107363:	6a 39                	push   $0x39
  jmp alltraps
80107365:	e9 e2 f6 ff ff       	jmp    80106a4c <alltraps>

8010736a <vector58>:
.globl vector58
vector58:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $58
8010736c:	6a 3a                	push   $0x3a
  jmp alltraps
8010736e:	e9 d9 f6 ff ff       	jmp    80106a4c <alltraps>

80107373 <vector59>:
.globl vector59
vector59:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $59
80107375:	6a 3b                	push   $0x3b
  jmp alltraps
80107377:	e9 d0 f6 ff ff       	jmp    80106a4c <alltraps>

8010737c <vector60>:
.globl vector60
vector60:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $60
8010737e:	6a 3c                	push   $0x3c
  jmp alltraps
80107380:	e9 c7 f6 ff ff       	jmp    80106a4c <alltraps>

80107385 <vector61>:
.globl vector61
vector61:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $61
80107387:	6a 3d                	push   $0x3d
  jmp alltraps
80107389:	e9 be f6 ff ff       	jmp    80106a4c <alltraps>

8010738e <vector62>:
.globl vector62
vector62:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $62
80107390:	6a 3e                	push   $0x3e
  jmp alltraps
80107392:	e9 b5 f6 ff ff       	jmp    80106a4c <alltraps>

80107397 <vector63>:
.globl vector63
vector63:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $63
80107399:	6a 3f                	push   $0x3f
  jmp alltraps
8010739b:	e9 ac f6 ff ff       	jmp    80106a4c <alltraps>

801073a0 <vector64>:
.globl vector64
vector64:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $64
801073a2:	6a 40                	push   $0x40
  jmp alltraps
801073a4:	e9 a3 f6 ff ff       	jmp    80106a4c <alltraps>

801073a9 <vector65>:
.globl vector65
vector65:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $65
801073ab:	6a 41                	push   $0x41
  jmp alltraps
801073ad:	e9 9a f6 ff ff       	jmp    80106a4c <alltraps>

801073b2 <vector66>:
.globl vector66
vector66:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $66
801073b4:	6a 42                	push   $0x42
  jmp alltraps
801073b6:	e9 91 f6 ff ff       	jmp    80106a4c <alltraps>

801073bb <vector67>:
.globl vector67
vector67:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $67
801073bd:	6a 43                	push   $0x43
  jmp alltraps
801073bf:	e9 88 f6 ff ff       	jmp    80106a4c <alltraps>

801073c4 <vector68>:
.globl vector68
vector68:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $68
801073c6:	6a 44                	push   $0x44
  jmp alltraps
801073c8:	e9 7f f6 ff ff       	jmp    80106a4c <alltraps>

801073cd <vector69>:
.globl vector69
vector69:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $69
801073cf:	6a 45                	push   $0x45
  jmp alltraps
801073d1:	e9 76 f6 ff ff       	jmp    80106a4c <alltraps>

801073d6 <vector70>:
.globl vector70
vector70:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $70
801073d8:	6a 46                	push   $0x46
  jmp alltraps
801073da:	e9 6d f6 ff ff       	jmp    80106a4c <alltraps>

801073df <vector71>:
.globl vector71
vector71:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $71
801073e1:	6a 47                	push   $0x47
  jmp alltraps
801073e3:	e9 64 f6 ff ff       	jmp    80106a4c <alltraps>

801073e8 <vector72>:
.globl vector72
vector72:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $72
801073ea:	6a 48                	push   $0x48
  jmp alltraps
801073ec:	e9 5b f6 ff ff       	jmp    80106a4c <alltraps>

801073f1 <vector73>:
.globl vector73
vector73:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $73
801073f3:	6a 49                	push   $0x49
  jmp alltraps
801073f5:	e9 52 f6 ff ff       	jmp    80106a4c <alltraps>

801073fa <vector74>:
.globl vector74
vector74:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $74
801073fc:	6a 4a                	push   $0x4a
  jmp alltraps
801073fe:	e9 49 f6 ff ff       	jmp    80106a4c <alltraps>

80107403 <vector75>:
.globl vector75
vector75:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $75
80107405:	6a 4b                	push   $0x4b
  jmp alltraps
80107407:	e9 40 f6 ff ff       	jmp    80106a4c <alltraps>

8010740c <vector76>:
.globl vector76
vector76:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $76
8010740e:	6a 4c                	push   $0x4c
  jmp alltraps
80107410:	e9 37 f6 ff ff       	jmp    80106a4c <alltraps>

80107415 <vector77>:
.globl vector77
vector77:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $77
80107417:	6a 4d                	push   $0x4d
  jmp alltraps
80107419:	e9 2e f6 ff ff       	jmp    80106a4c <alltraps>

8010741e <vector78>:
.globl vector78
vector78:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $78
80107420:	6a 4e                	push   $0x4e
  jmp alltraps
80107422:	e9 25 f6 ff ff       	jmp    80106a4c <alltraps>

80107427 <vector79>:
.globl vector79
vector79:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $79
80107429:	6a 4f                	push   $0x4f
  jmp alltraps
8010742b:	e9 1c f6 ff ff       	jmp    80106a4c <alltraps>

80107430 <vector80>:
.globl vector80
vector80:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $80
80107432:	6a 50                	push   $0x50
  jmp alltraps
80107434:	e9 13 f6 ff ff       	jmp    80106a4c <alltraps>

80107439 <vector81>:
.globl vector81
vector81:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $81
8010743b:	6a 51                	push   $0x51
  jmp alltraps
8010743d:	e9 0a f6 ff ff       	jmp    80106a4c <alltraps>

80107442 <vector82>:
.globl vector82
vector82:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $82
80107444:	6a 52                	push   $0x52
  jmp alltraps
80107446:	e9 01 f6 ff ff       	jmp    80106a4c <alltraps>

8010744b <vector83>:
.globl vector83
vector83:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $83
8010744d:	6a 53                	push   $0x53
  jmp alltraps
8010744f:	e9 f8 f5 ff ff       	jmp    80106a4c <alltraps>

80107454 <vector84>:
.globl vector84
vector84:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $84
80107456:	6a 54                	push   $0x54
  jmp alltraps
80107458:	e9 ef f5 ff ff       	jmp    80106a4c <alltraps>

8010745d <vector85>:
.globl vector85
vector85:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $85
8010745f:	6a 55                	push   $0x55
  jmp alltraps
80107461:	e9 e6 f5 ff ff       	jmp    80106a4c <alltraps>

80107466 <vector86>:
.globl vector86
vector86:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $86
80107468:	6a 56                	push   $0x56
  jmp alltraps
8010746a:	e9 dd f5 ff ff       	jmp    80106a4c <alltraps>

8010746f <vector87>:
.globl vector87
vector87:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $87
80107471:	6a 57                	push   $0x57
  jmp alltraps
80107473:	e9 d4 f5 ff ff       	jmp    80106a4c <alltraps>

80107478 <vector88>:
.globl vector88
vector88:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $88
8010747a:	6a 58                	push   $0x58
  jmp alltraps
8010747c:	e9 cb f5 ff ff       	jmp    80106a4c <alltraps>

80107481 <vector89>:
.globl vector89
vector89:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $89
80107483:	6a 59                	push   $0x59
  jmp alltraps
80107485:	e9 c2 f5 ff ff       	jmp    80106a4c <alltraps>

8010748a <vector90>:
.globl vector90
vector90:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $90
8010748c:	6a 5a                	push   $0x5a
  jmp alltraps
8010748e:	e9 b9 f5 ff ff       	jmp    80106a4c <alltraps>

80107493 <vector91>:
.globl vector91
vector91:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $91
80107495:	6a 5b                	push   $0x5b
  jmp alltraps
80107497:	e9 b0 f5 ff ff       	jmp    80106a4c <alltraps>

8010749c <vector92>:
.globl vector92
vector92:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $92
8010749e:	6a 5c                	push   $0x5c
  jmp alltraps
801074a0:	e9 a7 f5 ff ff       	jmp    80106a4c <alltraps>

801074a5 <vector93>:
.globl vector93
vector93:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $93
801074a7:	6a 5d                	push   $0x5d
  jmp alltraps
801074a9:	e9 9e f5 ff ff       	jmp    80106a4c <alltraps>

801074ae <vector94>:
.globl vector94
vector94:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $94
801074b0:	6a 5e                	push   $0x5e
  jmp alltraps
801074b2:	e9 95 f5 ff ff       	jmp    80106a4c <alltraps>

801074b7 <vector95>:
.globl vector95
vector95:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $95
801074b9:	6a 5f                	push   $0x5f
  jmp alltraps
801074bb:	e9 8c f5 ff ff       	jmp    80106a4c <alltraps>

801074c0 <vector96>:
.globl vector96
vector96:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $96
801074c2:	6a 60                	push   $0x60
  jmp alltraps
801074c4:	e9 83 f5 ff ff       	jmp    80106a4c <alltraps>

801074c9 <vector97>:
.globl vector97
vector97:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $97
801074cb:	6a 61                	push   $0x61
  jmp alltraps
801074cd:	e9 7a f5 ff ff       	jmp    80106a4c <alltraps>

801074d2 <vector98>:
.globl vector98
vector98:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $98
801074d4:	6a 62                	push   $0x62
  jmp alltraps
801074d6:	e9 71 f5 ff ff       	jmp    80106a4c <alltraps>

801074db <vector99>:
.globl vector99
vector99:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $99
801074dd:	6a 63                	push   $0x63
  jmp alltraps
801074df:	e9 68 f5 ff ff       	jmp    80106a4c <alltraps>

801074e4 <vector100>:
.globl vector100
vector100:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $100
801074e6:	6a 64                	push   $0x64
  jmp alltraps
801074e8:	e9 5f f5 ff ff       	jmp    80106a4c <alltraps>

801074ed <vector101>:
.globl vector101
vector101:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $101
801074ef:	6a 65                	push   $0x65
  jmp alltraps
801074f1:	e9 56 f5 ff ff       	jmp    80106a4c <alltraps>

801074f6 <vector102>:
.globl vector102
vector102:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $102
801074f8:	6a 66                	push   $0x66
  jmp alltraps
801074fa:	e9 4d f5 ff ff       	jmp    80106a4c <alltraps>

801074ff <vector103>:
.globl vector103
vector103:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $103
80107501:	6a 67                	push   $0x67
  jmp alltraps
80107503:	e9 44 f5 ff ff       	jmp    80106a4c <alltraps>

80107508 <vector104>:
.globl vector104
vector104:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $104
8010750a:	6a 68                	push   $0x68
  jmp alltraps
8010750c:	e9 3b f5 ff ff       	jmp    80106a4c <alltraps>

80107511 <vector105>:
.globl vector105
vector105:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $105
80107513:	6a 69                	push   $0x69
  jmp alltraps
80107515:	e9 32 f5 ff ff       	jmp    80106a4c <alltraps>

8010751a <vector106>:
.globl vector106
vector106:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $106
8010751c:	6a 6a                	push   $0x6a
  jmp alltraps
8010751e:	e9 29 f5 ff ff       	jmp    80106a4c <alltraps>

80107523 <vector107>:
.globl vector107
vector107:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $107
80107525:	6a 6b                	push   $0x6b
  jmp alltraps
80107527:	e9 20 f5 ff ff       	jmp    80106a4c <alltraps>

8010752c <vector108>:
.globl vector108
vector108:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $108
8010752e:	6a 6c                	push   $0x6c
  jmp alltraps
80107530:	e9 17 f5 ff ff       	jmp    80106a4c <alltraps>

80107535 <vector109>:
.globl vector109
vector109:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $109
80107537:	6a 6d                	push   $0x6d
  jmp alltraps
80107539:	e9 0e f5 ff ff       	jmp    80106a4c <alltraps>

8010753e <vector110>:
.globl vector110
vector110:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $110
80107540:	6a 6e                	push   $0x6e
  jmp alltraps
80107542:	e9 05 f5 ff ff       	jmp    80106a4c <alltraps>

80107547 <vector111>:
.globl vector111
vector111:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $111
80107549:	6a 6f                	push   $0x6f
  jmp alltraps
8010754b:	e9 fc f4 ff ff       	jmp    80106a4c <alltraps>

80107550 <vector112>:
.globl vector112
vector112:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $112
80107552:	6a 70                	push   $0x70
  jmp alltraps
80107554:	e9 f3 f4 ff ff       	jmp    80106a4c <alltraps>

80107559 <vector113>:
.globl vector113
vector113:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $113
8010755b:	6a 71                	push   $0x71
  jmp alltraps
8010755d:	e9 ea f4 ff ff       	jmp    80106a4c <alltraps>

80107562 <vector114>:
.globl vector114
vector114:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $114
80107564:	6a 72                	push   $0x72
  jmp alltraps
80107566:	e9 e1 f4 ff ff       	jmp    80106a4c <alltraps>

8010756b <vector115>:
.globl vector115
vector115:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $115
8010756d:	6a 73                	push   $0x73
  jmp alltraps
8010756f:	e9 d8 f4 ff ff       	jmp    80106a4c <alltraps>

80107574 <vector116>:
.globl vector116
vector116:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $116
80107576:	6a 74                	push   $0x74
  jmp alltraps
80107578:	e9 cf f4 ff ff       	jmp    80106a4c <alltraps>

8010757d <vector117>:
.globl vector117
vector117:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $117
8010757f:	6a 75                	push   $0x75
  jmp alltraps
80107581:	e9 c6 f4 ff ff       	jmp    80106a4c <alltraps>

80107586 <vector118>:
.globl vector118
vector118:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $118
80107588:	6a 76                	push   $0x76
  jmp alltraps
8010758a:	e9 bd f4 ff ff       	jmp    80106a4c <alltraps>

8010758f <vector119>:
.globl vector119
vector119:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $119
80107591:	6a 77                	push   $0x77
  jmp alltraps
80107593:	e9 b4 f4 ff ff       	jmp    80106a4c <alltraps>

80107598 <vector120>:
.globl vector120
vector120:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $120
8010759a:	6a 78                	push   $0x78
  jmp alltraps
8010759c:	e9 ab f4 ff ff       	jmp    80106a4c <alltraps>

801075a1 <vector121>:
.globl vector121
vector121:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $121
801075a3:	6a 79                	push   $0x79
  jmp alltraps
801075a5:	e9 a2 f4 ff ff       	jmp    80106a4c <alltraps>

801075aa <vector122>:
.globl vector122
vector122:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $122
801075ac:	6a 7a                	push   $0x7a
  jmp alltraps
801075ae:	e9 99 f4 ff ff       	jmp    80106a4c <alltraps>

801075b3 <vector123>:
.globl vector123
vector123:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $123
801075b5:	6a 7b                	push   $0x7b
  jmp alltraps
801075b7:	e9 90 f4 ff ff       	jmp    80106a4c <alltraps>

801075bc <vector124>:
.globl vector124
vector124:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $124
801075be:	6a 7c                	push   $0x7c
  jmp alltraps
801075c0:	e9 87 f4 ff ff       	jmp    80106a4c <alltraps>

801075c5 <vector125>:
.globl vector125
vector125:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $125
801075c7:	6a 7d                	push   $0x7d
  jmp alltraps
801075c9:	e9 7e f4 ff ff       	jmp    80106a4c <alltraps>

801075ce <vector126>:
.globl vector126
vector126:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $126
801075d0:	6a 7e                	push   $0x7e
  jmp alltraps
801075d2:	e9 75 f4 ff ff       	jmp    80106a4c <alltraps>

801075d7 <vector127>:
.globl vector127
vector127:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $127
801075d9:	6a 7f                	push   $0x7f
  jmp alltraps
801075db:	e9 6c f4 ff ff       	jmp    80106a4c <alltraps>

801075e0 <vector128>:
.globl vector128
vector128:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $128
801075e2:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075e7:	e9 60 f4 ff ff       	jmp    80106a4c <alltraps>

801075ec <vector129>:
.globl vector129
vector129:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $129
801075ee:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075f3:	e9 54 f4 ff ff       	jmp    80106a4c <alltraps>

801075f8 <vector130>:
.globl vector130
vector130:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $130
801075fa:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075ff:	e9 48 f4 ff ff       	jmp    80106a4c <alltraps>

80107604 <vector131>:
.globl vector131
vector131:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $131
80107606:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010760b:	e9 3c f4 ff ff       	jmp    80106a4c <alltraps>

80107610 <vector132>:
.globl vector132
vector132:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $132
80107612:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107617:	e9 30 f4 ff ff       	jmp    80106a4c <alltraps>

8010761c <vector133>:
.globl vector133
vector133:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $133
8010761e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107623:	e9 24 f4 ff ff       	jmp    80106a4c <alltraps>

80107628 <vector134>:
.globl vector134
vector134:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $134
8010762a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010762f:	e9 18 f4 ff ff       	jmp    80106a4c <alltraps>

80107634 <vector135>:
.globl vector135
vector135:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $135
80107636:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010763b:	e9 0c f4 ff ff       	jmp    80106a4c <alltraps>

80107640 <vector136>:
.globl vector136
vector136:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $136
80107642:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107647:	e9 00 f4 ff ff       	jmp    80106a4c <alltraps>

8010764c <vector137>:
.globl vector137
vector137:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $137
8010764e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107653:	e9 f4 f3 ff ff       	jmp    80106a4c <alltraps>

80107658 <vector138>:
.globl vector138
vector138:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $138
8010765a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010765f:	e9 e8 f3 ff ff       	jmp    80106a4c <alltraps>

80107664 <vector139>:
.globl vector139
vector139:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $139
80107666:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010766b:	e9 dc f3 ff ff       	jmp    80106a4c <alltraps>

80107670 <vector140>:
.globl vector140
vector140:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $140
80107672:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107677:	e9 d0 f3 ff ff       	jmp    80106a4c <alltraps>

8010767c <vector141>:
.globl vector141
vector141:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $141
8010767e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107683:	e9 c4 f3 ff ff       	jmp    80106a4c <alltraps>

80107688 <vector142>:
.globl vector142
vector142:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $142
8010768a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010768f:	e9 b8 f3 ff ff       	jmp    80106a4c <alltraps>

80107694 <vector143>:
.globl vector143
vector143:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $143
80107696:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010769b:	e9 ac f3 ff ff       	jmp    80106a4c <alltraps>

801076a0 <vector144>:
.globl vector144
vector144:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $144
801076a2:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076a7:	e9 a0 f3 ff ff       	jmp    80106a4c <alltraps>

801076ac <vector145>:
.globl vector145
vector145:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $145
801076ae:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076b3:	e9 94 f3 ff ff       	jmp    80106a4c <alltraps>

801076b8 <vector146>:
.globl vector146
vector146:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $146
801076ba:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076bf:	e9 88 f3 ff ff       	jmp    80106a4c <alltraps>

801076c4 <vector147>:
.globl vector147
vector147:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $147
801076c6:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076cb:	e9 7c f3 ff ff       	jmp    80106a4c <alltraps>

801076d0 <vector148>:
.globl vector148
vector148:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $148
801076d2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076d7:	e9 70 f3 ff ff       	jmp    80106a4c <alltraps>

801076dc <vector149>:
.globl vector149
vector149:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $149
801076de:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076e3:	e9 64 f3 ff ff       	jmp    80106a4c <alltraps>

801076e8 <vector150>:
.globl vector150
vector150:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $150
801076ea:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ef:	e9 58 f3 ff ff       	jmp    80106a4c <alltraps>

801076f4 <vector151>:
.globl vector151
vector151:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $151
801076f6:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076fb:	e9 4c f3 ff ff       	jmp    80106a4c <alltraps>

80107700 <vector152>:
.globl vector152
vector152:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $152
80107702:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107707:	e9 40 f3 ff ff       	jmp    80106a4c <alltraps>

8010770c <vector153>:
.globl vector153
vector153:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $153
8010770e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107713:	e9 34 f3 ff ff       	jmp    80106a4c <alltraps>

80107718 <vector154>:
.globl vector154
vector154:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $154
8010771a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010771f:	e9 28 f3 ff ff       	jmp    80106a4c <alltraps>

80107724 <vector155>:
.globl vector155
vector155:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $155
80107726:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010772b:	e9 1c f3 ff ff       	jmp    80106a4c <alltraps>

80107730 <vector156>:
.globl vector156
vector156:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $156
80107732:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107737:	e9 10 f3 ff ff       	jmp    80106a4c <alltraps>

8010773c <vector157>:
.globl vector157
vector157:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $157
8010773e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107743:	e9 04 f3 ff ff       	jmp    80106a4c <alltraps>

80107748 <vector158>:
.globl vector158
vector158:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $158
8010774a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010774f:	e9 f8 f2 ff ff       	jmp    80106a4c <alltraps>

80107754 <vector159>:
.globl vector159
vector159:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $159
80107756:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010775b:	e9 ec f2 ff ff       	jmp    80106a4c <alltraps>

80107760 <vector160>:
.globl vector160
vector160:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $160
80107762:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107767:	e9 e0 f2 ff ff       	jmp    80106a4c <alltraps>

8010776c <vector161>:
.globl vector161
vector161:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $161
8010776e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107773:	e9 d4 f2 ff ff       	jmp    80106a4c <alltraps>

80107778 <vector162>:
.globl vector162
vector162:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $162
8010777a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010777f:	e9 c8 f2 ff ff       	jmp    80106a4c <alltraps>

80107784 <vector163>:
.globl vector163
vector163:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $163
80107786:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010778b:	e9 bc f2 ff ff       	jmp    80106a4c <alltraps>

80107790 <vector164>:
.globl vector164
vector164:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $164
80107792:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107797:	e9 b0 f2 ff ff       	jmp    80106a4c <alltraps>

8010779c <vector165>:
.globl vector165
vector165:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $165
8010779e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077a3:	e9 a4 f2 ff ff       	jmp    80106a4c <alltraps>

801077a8 <vector166>:
.globl vector166
vector166:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $166
801077aa:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077af:	e9 98 f2 ff ff       	jmp    80106a4c <alltraps>

801077b4 <vector167>:
.globl vector167
vector167:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $167
801077b6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077bb:	e9 8c f2 ff ff       	jmp    80106a4c <alltraps>

801077c0 <vector168>:
.globl vector168
vector168:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $168
801077c2:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077c7:	e9 80 f2 ff ff       	jmp    80106a4c <alltraps>

801077cc <vector169>:
.globl vector169
vector169:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $169
801077ce:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077d3:	e9 74 f2 ff ff       	jmp    80106a4c <alltraps>

801077d8 <vector170>:
.globl vector170
vector170:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $170
801077da:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077df:	e9 68 f2 ff ff       	jmp    80106a4c <alltraps>

801077e4 <vector171>:
.globl vector171
vector171:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $171
801077e6:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077eb:	e9 5c f2 ff ff       	jmp    80106a4c <alltraps>

801077f0 <vector172>:
.globl vector172
vector172:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $172
801077f2:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077f7:	e9 50 f2 ff ff       	jmp    80106a4c <alltraps>

801077fc <vector173>:
.globl vector173
vector173:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $173
801077fe:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107803:	e9 44 f2 ff ff       	jmp    80106a4c <alltraps>

80107808 <vector174>:
.globl vector174
vector174:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $174
8010780a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010780f:	e9 38 f2 ff ff       	jmp    80106a4c <alltraps>

80107814 <vector175>:
.globl vector175
vector175:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $175
80107816:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010781b:	e9 2c f2 ff ff       	jmp    80106a4c <alltraps>

80107820 <vector176>:
.globl vector176
vector176:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $176
80107822:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107827:	e9 20 f2 ff ff       	jmp    80106a4c <alltraps>

8010782c <vector177>:
.globl vector177
vector177:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $177
8010782e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107833:	e9 14 f2 ff ff       	jmp    80106a4c <alltraps>

80107838 <vector178>:
.globl vector178
vector178:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $178
8010783a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010783f:	e9 08 f2 ff ff       	jmp    80106a4c <alltraps>

80107844 <vector179>:
.globl vector179
vector179:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $179
80107846:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010784b:	e9 fc f1 ff ff       	jmp    80106a4c <alltraps>

80107850 <vector180>:
.globl vector180
vector180:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $180
80107852:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107857:	e9 f0 f1 ff ff       	jmp    80106a4c <alltraps>

8010785c <vector181>:
.globl vector181
vector181:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $181
8010785e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107863:	e9 e4 f1 ff ff       	jmp    80106a4c <alltraps>

80107868 <vector182>:
.globl vector182
vector182:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $182
8010786a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010786f:	e9 d8 f1 ff ff       	jmp    80106a4c <alltraps>

80107874 <vector183>:
.globl vector183
vector183:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $183
80107876:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010787b:	e9 cc f1 ff ff       	jmp    80106a4c <alltraps>

80107880 <vector184>:
.globl vector184
vector184:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $184
80107882:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107887:	e9 c0 f1 ff ff       	jmp    80106a4c <alltraps>

8010788c <vector185>:
.globl vector185
vector185:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $185
8010788e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107893:	e9 b4 f1 ff ff       	jmp    80106a4c <alltraps>

80107898 <vector186>:
.globl vector186
vector186:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $186
8010789a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010789f:	e9 a8 f1 ff ff       	jmp    80106a4c <alltraps>

801078a4 <vector187>:
.globl vector187
vector187:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $187
801078a6:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078ab:	e9 9c f1 ff ff       	jmp    80106a4c <alltraps>

801078b0 <vector188>:
.globl vector188
vector188:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $188
801078b2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078b7:	e9 90 f1 ff ff       	jmp    80106a4c <alltraps>

801078bc <vector189>:
.globl vector189
vector189:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $189
801078be:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078c3:	e9 84 f1 ff ff       	jmp    80106a4c <alltraps>

801078c8 <vector190>:
.globl vector190
vector190:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $190
801078ca:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078cf:	e9 78 f1 ff ff       	jmp    80106a4c <alltraps>

801078d4 <vector191>:
.globl vector191
vector191:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $191
801078d6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078db:	e9 6c f1 ff ff       	jmp    80106a4c <alltraps>

801078e0 <vector192>:
.globl vector192
vector192:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $192
801078e2:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078e7:	e9 60 f1 ff ff       	jmp    80106a4c <alltraps>

801078ec <vector193>:
.globl vector193
vector193:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $193
801078ee:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078f3:	e9 54 f1 ff ff       	jmp    80106a4c <alltraps>

801078f8 <vector194>:
.globl vector194
vector194:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $194
801078fa:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078ff:	e9 48 f1 ff ff       	jmp    80106a4c <alltraps>

80107904 <vector195>:
.globl vector195
vector195:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $195
80107906:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010790b:	e9 3c f1 ff ff       	jmp    80106a4c <alltraps>

80107910 <vector196>:
.globl vector196
vector196:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $196
80107912:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107917:	e9 30 f1 ff ff       	jmp    80106a4c <alltraps>

8010791c <vector197>:
.globl vector197
vector197:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $197
8010791e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107923:	e9 24 f1 ff ff       	jmp    80106a4c <alltraps>

80107928 <vector198>:
.globl vector198
vector198:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $198
8010792a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010792f:	e9 18 f1 ff ff       	jmp    80106a4c <alltraps>

80107934 <vector199>:
.globl vector199
vector199:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $199
80107936:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010793b:	e9 0c f1 ff ff       	jmp    80106a4c <alltraps>

80107940 <vector200>:
.globl vector200
vector200:
  pushl $0
80107940:	6a 00                	push   $0x0
  pushl $200
80107942:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107947:	e9 00 f1 ff ff       	jmp    80106a4c <alltraps>

8010794c <vector201>:
.globl vector201
vector201:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $201
8010794e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107953:	e9 f4 f0 ff ff       	jmp    80106a4c <alltraps>

80107958 <vector202>:
.globl vector202
vector202:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $202
8010795a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010795f:	e9 e8 f0 ff ff       	jmp    80106a4c <alltraps>

80107964 <vector203>:
.globl vector203
vector203:
  pushl $0
80107964:	6a 00                	push   $0x0
  pushl $203
80107966:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010796b:	e9 dc f0 ff ff       	jmp    80106a4c <alltraps>

80107970 <vector204>:
.globl vector204
vector204:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $204
80107972:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107977:	e9 d0 f0 ff ff       	jmp    80106a4c <alltraps>

8010797c <vector205>:
.globl vector205
vector205:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $205
8010797e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107983:	e9 c4 f0 ff ff       	jmp    80106a4c <alltraps>

80107988 <vector206>:
.globl vector206
vector206:
  pushl $0
80107988:	6a 00                	push   $0x0
  pushl $206
8010798a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010798f:	e9 b8 f0 ff ff       	jmp    80106a4c <alltraps>

80107994 <vector207>:
.globl vector207
vector207:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $207
80107996:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010799b:	e9 ac f0 ff ff       	jmp    80106a4c <alltraps>

801079a0 <vector208>:
.globl vector208
vector208:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $208
801079a2:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079a7:	e9 a0 f0 ff ff       	jmp    80106a4c <alltraps>

801079ac <vector209>:
.globl vector209
vector209:
  pushl $0
801079ac:	6a 00                	push   $0x0
  pushl $209
801079ae:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079b3:	e9 94 f0 ff ff       	jmp    80106a4c <alltraps>

801079b8 <vector210>:
.globl vector210
vector210:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $210
801079ba:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079bf:	e9 88 f0 ff ff       	jmp    80106a4c <alltraps>

801079c4 <vector211>:
.globl vector211
vector211:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $211
801079c6:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079cb:	e9 7c f0 ff ff       	jmp    80106a4c <alltraps>

801079d0 <vector212>:
.globl vector212
vector212:
  pushl $0
801079d0:	6a 00                	push   $0x0
  pushl $212
801079d2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079d7:	e9 70 f0 ff ff       	jmp    80106a4c <alltraps>

801079dc <vector213>:
.globl vector213
vector213:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $213
801079de:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079e3:	e9 64 f0 ff ff       	jmp    80106a4c <alltraps>

801079e8 <vector214>:
.globl vector214
vector214:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $214
801079ea:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ef:	e9 58 f0 ff ff       	jmp    80106a4c <alltraps>

801079f4 <vector215>:
.globl vector215
vector215:
  pushl $0
801079f4:	6a 00                	push   $0x0
  pushl $215
801079f6:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079fb:	e9 4c f0 ff ff       	jmp    80106a4c <alltraps>

80107a00 <vector216>:
.globl vector216
vector216:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $216
80107a02:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a07:	e9 40 f0 ff ff       	jmp    80106a4c <alltraps>

80107a0c <vector217>:
.globl vector217
vector217:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $217
80107a0e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a13:	e9 34 f0 ff ff       	jmp    80106a4c <alltraps>

80107a18 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a18:	6a 00                	push   $0x0
  pushl $218
80107a1a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a1f:	e9 28 f0 ff ff       	jmp    80106a4c <alltraps>

80107a24 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $219
80107a26:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a2b:	e9 1c f0 ff ff       	jmp    80106a4c <alltraps>

80107a30 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $220
80107a32:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a37:	e9 10 f0 ff ff       	jmp    80106a4c <alltraps>

80107a3c <vector221>:
.globl vector221
vector221:
  pushl $0
80107a3c:	6a 00                	push   $0x0
  pushl $221
80107a3e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a43:	e9 04 f0 ff ff       	jmp    80106a4c <alltraps>

80107a48 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $222
80107a4a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a4f:	e9 f8 ef ff ff       	jmp    80106a4c <alltraps>

80107a54 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $223
80107a56:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a5b:	e9 ec ef ff ff       	jmp    80106a4c <alltraps>

80107a60 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $224
80107a62:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a67:	e9 e0 ef ff ff       	jmp    80106a4c <alltraps>

80107a6c <vector225>:
.globl vector225
vector225:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $225
80107a6e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a73:	e9 d4 ef ff ff       	jmp    80106a4c <alltraps>

80107a78 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $226
80107a7a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a7f:	e9 c8 ef ff ff       	jmp    80106a4c <alltraps>

80107a84 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $227
80107a86:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a8b:	e9 bc ef ff ff       	jmp    80106a4c <alltraps>

80107a90 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $228
80107a92:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a97:	e9 b0 ef ff ff       	jmp    80106a4c <alltraps>

80107a9c <vector229>:
.globl vector229
vector229:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $229
80107a9e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107aa3:	e9 a4 ef ff ff       	jmp    80106a4c <alltraps>

80107aa8 <vector230>:
.globl vector230
vector230:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $230
80107aaa:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107aaf:	e9 98 ef ff ff       	jmp    80106a4c <alltraps>

80107ab4 <vector231>:
.globl vector231
vector231:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $231
80107ab6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107abb:	e9 8c ef ff ff       	jmp    80106a4c <alltraps>

80107ac0 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $232
80107ac2:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ac7:	e9 80 ef ff ff       	jmp    80106a4c <alltraps>

80107acc <vector233>:
.globl vector233
vector233:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $233
80107ace:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ad3:	e9 74 ef ff ff       	jmp    80106a4c <alltraps>

80107ad8 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $234
80107ada:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107adf:	e9 68 ef ff ff       	jmp    80106a4c <alltraps>

80107ae4 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $235
80107ae6:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107aeb:	e9 5c ef ff ff       	jmp    80106a4c <alltraps>

80107af0 <vector236>:
.globl vector236
vector236:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $236
80107af2:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107af7:	e9 50 ef ff ff       	jmp    80106a4c <alltraps>

80107afc <vector237>:
.globl vector237
vector237:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $237
80107afe:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b03:	e9 44 ef ff ff       	jmp    80106a4c <alltraps>

80107b08 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $238
80107b0a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b0f:	e9 38 ef ff ff       	jmp    80106a4c <alltraps>

80107b14 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b14:	6a 00                	push   $0x0
  pushl $239
80107b16:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b1b:	e9 2c ef ff ff       	jmp    80106a4c <alltraps>

80107b20 <vector240>:
.globl vector240
vector240:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $240
80107b22:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b27:	e9 20 ef ff ff       	jmp    80106a4c <alltraps>

80107b2c <vector241>:
.globl vector241
vector241:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $241
80107b2e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b33:	e9 14 ef ff ff       	jmp    80106a4c <alltraps>

80107b38 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $242
80107b3a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b3f:	e9 08 ef ff ff       	jmp    80106a4c <alltraps>

80107b44 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $243
80107b46:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b4b:	e9 fc ee ff ff       	jmp    80106a4c <alltraps>

80107b50 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $244
80107b52:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b57:	e9 f0 ee ff ff       	jmp    80106a4c <alltraps>

80107b5c <vector245>:
.globl vector245
vector245:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $245
80107b5e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b63:	e9 e4 ee ff ff       	jmp    80106a4c <alltraps>

80107b68 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $246
80107b6a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b6f:	e9 d8 ee ff ff       	jmp    80106a4c <alltraps>

80107b74 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $247
80107b76:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b7b:	e9 cc ee ff ff       	jmp    80106a4c <alltraps>

80107b80 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $248
80107b82:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b87:	e9 c0 ee ff ff       	jmp    80106a4c <alltraps>

80107b8c <vector249>:
.globl vector249
vector249:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $249
80107b8e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b93:	e9 b4 ee ff ff       	jmp    80106a4c <alltraps>

80107b98 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $250
80107b9a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b9f:	e9 a8 ee ff ff       	jmp    80106a4c <alltraps>

80107ba4 <vector251>:
.globl vector251
vector251:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $251
80107ba6:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107bab:	e9 9c ee ff ff       	jmp    80106a4c <alltraps>

80107bb0 <vector252>:
.globl vector252
vector252:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $252
80107bb2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bb7:	e9 90 ee ff ff       	jmp    80106a4c <alltraps>

80107bbc <vector253>:
.globl vector253
vector253:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $253
80107bbe:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bc3:	e9 84 ee ff ff       	jmp    80106a4c <alltraps>

80107bc8 <vector254>:
.globl vector254
vector254:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $254
80107bca:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bcf:	e9 78 ee ff ff       	jmp    80106a4c <alltraps>

80107bd4 <vector255>:
.globl vector255
vector255:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $255
80107bd6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bdb:	e9 6c ee ff ff       	jmp    80106a4c <alltraps>

80107be0 <lgdt>:
{
80107be0:	55                   	push   %ebp
80107be1:	89 e5                	mov    %esp,%ebp
80107be3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107be6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be9:	83 e8 01             	sub    $0x1,%eax
80107bec:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bfa:	c1 e8 10             	shr    $0x10,%eax
80107bfd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107c01:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c04:	0f 01 10             	lgdtl  (%eax)
}
80107c07:	90                   	nop
80107c08:	c9                   	leave
80107c09:	c3                   	ret

80107c0a <ltr>:
{
80107c0a:	55                   	push   %ebp
80107c0b:	89 e5                	mov    %esp,%ebp
80107c0d:	83 ec 04             	sub    $0x4,%esp
80107c10:	8b 45 08             	mov    0x8(%ebp),%eax
80107c13:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c17:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c1b:	0f 00 d8             	ltr    %eax
}
80107c1e:	90                   	nop
80107c1f:	c9                   	leave
80107c20:	c3                   	ret

80107c21 <lcr3>:

static inline void
lcr3(uint val)
{
80107c21:	55                   	push   %ebp
80107c22:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c24:	8b 45 08             	mov    0x8(%ebp),%eax
80107c27:	0f 22 d8             	mov    %eax,%cr3
}
80107c2a:	90                   	nop
80107c2b:	5d                   	pop    %ebp
80107c2c:	c3                   	ret

80107c2d <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c2d:	f3 0f 1e fb          	endbr32
80107c31:	55                   	push   %ebp
80107c32:	89 e5                	mov    %esp,%ebp
80107c34:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c37:	e8 d2 be ff ff       	call   80103b0e <cpuid>
80107c3c:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107c42:	05 e0 8c 19 80       	add    $0x80198ce0,%eax
80107c47:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c66:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c6a:	83 e2 f0             	and    $0xfffffff0,%edx
80107c6d:	83 ca 0a             	or     $0xa,%edx
80107c70:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c76:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c7a:	83 ca 10             	or     $0x10,%edx
80107c7d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c87:	83 e2 9f             	and    $0xffffff9f,%edx
80107c8a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c90:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c94:	83 ca 80             	or     $0xffffff80,%edx
80107c97:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca1:	83 ca 0f             	or     $0xf,%edx
80107ca4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cae:	83 e2 ef             	and    $0xffffffef,%edx
80107cb1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cbb:	83 e2 df             	and    $0xffffffdf,%edx
80107cbe:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cc8:	83 ca 40             	or     $0x40,%edx
80107ccb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cd5:	83 ca 80             	or     $0xffffff80,%edx
80107cd8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce5:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cec:	ff ff 
80107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf1:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cf8:	00 00 
80107cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfd:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d0e:	83 e2 f0             	and    $0xfffffff0,%edx
80107d11:	83 ca 02             	or     $0x2,%edx
80107d14:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d24:	83 ca 10             	or     $0x10,%edx
80107d27:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d37:	83 e2 9f             	and    $0xffffff9f,%edx
80107d3a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d43:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d4a:	83 ca 80             	or     $0xffffff80,%edx
80107d4d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d56:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d5d:	83 ca 0f             	or     $0xf,%edx
80107d60:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d70:	83 e2 ef             	and    $0xffffffef,%edx
80107d73:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d83:	83 e2 df             	and    $0xffffffdf,%edx
80107d86:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d96:	83 ca 40             	or     $0x40,%edx
80107d99:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107da9:	83 ca 80             	or     $0xffffff80,%edx
80107dac:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db5:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbf:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107dc6:	ff ff 
80107dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcb:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107dd2:	00 00 
80107dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd7:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107de8:	83 e2 f0             	and    $0xfffffff0,%edx
80107deb:	83 ca 0a             	or     $0xa,%edx
80107dee:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dfe:	83 ca 10             	or     $0x10,%edx
80107e01:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e11:	83 ca 60             	or     $0x60,%edx
80107e14:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e24:	83 ca 80             	or     $0xffffff80,%edx
80107e27:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e30:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e37:	83 ca 0f             	or     $0xf,%edx
80107e3a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e43:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e4a:	83 e2 ef             	and    $0xffffffef,%edx
80107e4d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e56:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e5d:	83 e2 df             	and    $0xffffffdf,%edx
80107e60:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e70:	83 ca 40             	or     $0x40,%edx
80107e73:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e83:	83 ca 80             	or     $0xffffff80,%edx
80107e86:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8f:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ea0:	ff ff 
80107ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea5:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107eac:	00 00 
80107eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb1:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ec2:	83 e2 f0             	and    $0xfffffff0,%edx
80107ec5:	83 ca 02             	or     $0x2,%edx
80107ec8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ed8:	83 ca 10             	or     $0x10,%edx
80107edb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eeb:	83 ca 60             	or     $0x60,%edx
80107eee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107efe:	83 ca 80             	or     $0xffffff80,%edx
80107f01:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f11:	83 ca 0f             	or     $0xf,%edx
80107f14:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f24:	83 e2 ef             	and    $0xffffffef,%edx
80107f27:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f30:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f37:	83 e2 df             	and    $0xffffffdf,%edx
80107f3a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f43:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f4a:	83 ca 40             	or     $0x40,%edx
80107f4d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f56:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f5d:	83 ca 80             	or     $0xffffff80,%edx
80107f60:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f69:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f73:	83 c0 70             	add    $0x70,%eax
80107f76:	83 ec 08             	sub    $0x8,%esp
80107f79:	6a 30                	push   $0x30
80107f7b:	50                   	push   %eax
80107f7c:	e8 5f fc ff ff       	call   80107be0 <lgdt>
80107f81:	83 c4 10             	add    $0x10,%esp
}
80107f84:	90                   	nop
80107f85:	c9                   	leave
80107f86:	c3                   	ret

80107f87 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f87:	f3 0f 1e fb          	endbr32
80107f8b:	55                   	push   %ebp
80107f8c:	89 e5                	mov    %esp,%ebp
80107f8e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f94:	c1 e8 16             	shr    $0x16,%eax
80107f97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa1:	01 d0                	add    %edx,%eax
80107fa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa9:	8b 00                	mov    (%eax),%eax
80107fab:	83 e0 01             	and    $0x1,%eax
80107fae:	85 c0                	test   %eax,%eax
80107fb0:	74 14                	je     80107fc6 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb5:	8b 00                	mov    (%eax),%eax
80107fb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fbc:	05 00 00 00 80       	add    $0x80000000,%eax
80107fc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fc4:	eb 42                	jmp    80108008 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fca:	74 0e                	je     80107fda <walkpgdir+0x53>
80107fcc:	e8 c1 a8 ff ff       	call   80102892 <kalloc>
80107fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fd8:	75 07                	jne    80107fe1 <walkpgdir+0x5a>
      return 0;
80107fda:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdf:	eb 3e                	jmp    8010801f <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fe1:	83 ec 04             	sub    $0x4,%esp
80107fe4:	68 00 10 00 00       	push   $0x1000
80107fe9:	6a 00                	push   $0x0
80107feb:	ff 75 f4             	push   -0xc(%ebp)
80107fee:	e8 9d d5 ff ff       	call   80105590 <memset>
80107ff3:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff9:	05 00 00 00 80       	add    $0x80000000,%eax
80107ffe:	83 c8 07             	or     $0x7,%eax
80108001:	89 c2                	mov    %eax,%edx
80108003:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108006:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800b:	c1 e8 0c             	shr    $0xc,%eax
8010800e:	25 ff 03 00 00       	and    $0x3ff,%eax
80108013:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010801a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801d:	01 d0                	add    %edx,%eax
}
8010801f:	c9                   	leave
80108020:	c3                   	ret

80108021 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108021:	f3 0f 1e fb          	endbr32
80108025:	55                   	push   %ebp
80108026:	89 e5                	mov    %esp,%ebp
80108028:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010802b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010802e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108033:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108036:	8b 55 0c             	mov    0xc(%ebp),%edx
80108039:	8b 45 10             	mov    0x10(%ebp),%eax
8010803c:	01 d0                	add    %edx,%eax
8010803e:	83 e8 01             	sub    $0x1,%eax
80108041:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108046:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108049:	83 ec 04             	sub    $0x4,%esp
8010804c:	6a 01                	push   $0x1
8010804e:	ff 75 f4             	push   -0xc(%ebp)
80108051:	ff 75 08             	push   0x8(%ebp)
80108054:	e8 2e ff ff ff       	call   80107f87 <walkpgdir>
80108059:	83 c4 10             	add    $0x10,%esp
8010805c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010805f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108063:	75 07                	jne    8010806c <mappages+0x4b>
      return -1;
80108065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806a:	eb 47                	jmp    801080b3 <mappages+0x92>
    if(*pte & PTE_P)
8010806c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806f:	8b 00                	mov    (%eax),%eax
80108071:	83 e0 01             	and    $0x1,%eax
80108074:	85 c0                	test   %eax,%eax
80108076:	74 0d                	je     80108085 <mappages+0x64>
      panic("remap");
80108078:	83 ec 0c             	sub    $0xc,%esp
8010807b:	68 54 b5 10 80       	push   $0x8010b554
80108080:	e8 40 85 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80108085:	8b 45 18             	mov    0x18(%ebp),%eax
80108088:	0b 45 14             	or     0x14(%ebp),%eax
8010808b:	83 c8 01             	or     $0x1,%eax
8010808e:	89 c2                	mov    %eax,%edx
80108090:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108093:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108098:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010809b:	74 10                	je     801080ad <mappages+0x8c>
      break;
    a += PGSIZE;
8010809d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080a4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080ab:	eb 9c                	jmp    80108049 <mappages+0x28>
      break;
801080ad:	90                   	nop
  }
  return 0;
801080ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080b3:	c9                   	leave
801080b4:	c3                   	ret

801080b5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080b5:	f3 0f 1e fb          	endbr32
801080b9:	55                   	push   %ebp
801080ba:	89 e5                	mov    %esp,%ebp
801080bc:	53                   	push   %ebx
801080bd:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801080c0:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801080c7:	a1 a0 8d 19 80       	mov    0x80198da0,%eax
801080cc:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801080d1:	29 c2                	sub    %eax,%edx
801080d3:	89 d0                	mov    %edx,%eax
801080d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801080d8:	a1 98 8d 19 80       	mov    0x80198d98,%eax
801080dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801080e0:	8b 15 98 8d 19 80    	mov    0x80198d98,%edx
801080e6:	a1 a0 8d 19 80       	mov    0x80198da0,%eax
801080eb:	01 d0                	add    %edx,%eax
801080ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
801080f0:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801080f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fa:	83 c0 30             	add    $0x30,%eax
801080fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108100:	89 10                	mov    %edx,(%eax)
80108102:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108105:	89 50 04             	mov    %edx,0x4(%eax)
80108108:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010810b:	89 50 08             	mov    %edx,0x8(%eax)
8010810e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108111:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80108114:	e8 79 a7 ff ff       	call   80102892 <kalloc>
80108119:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010811c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108120:	75 07                	jne    80108129 <setupkvm+0x74>
    return 0;
80108122:	b8 00 00 00 00       	mov    $0x0,%eax
80108127:	eb 78                	jmp    801081a1 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80108129:	83 ec 04             	sub    $0x4,%esp
8010812c:	68 00 10 00 00       	push   $0x1000
80108131:	6a 00                	push   $0x0
80108133:	ff 75 f0             	push   -0x10(%ebp)
80108136:	e8 55 d4 ff ff       	call   80105590 <memset>
8010813b:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010813e:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80108145:	eb 4e                	jmp    80108195 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814a:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010814d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108150:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108156:	8b 58 08             	mov    0x8(%eax),%ebx
80108159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815c:	8b 40 04             	mov    0x4(%eax),%eax
8010815f:	29 c3                	sub    %eax,%ebx
80108161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108164:	8b 00                	mov    (%eax),%eax
80108166:	83 ec 0c             	sub    $0xc,%esp
80108169:	51                   	push   %ecx
8010816a:	52                   	push   %edx
8010816b:	53                   	push   %ebx
8010816c:	50                   	push   %eax
8010816d:	ff 75 f0             	push   -0x10(%ebp)
80108170:	e8 ac fe ff ff       	call   80108021 <mappages>
80108175:	83 c4 20             	add    $0x20,%esp
80108178:	85 c0                	test   %eax,%eax
8010817a:	79 15                	jns    80108191 <setupkvm+0xdc>
      freevm(pgdir);
8010817c:	83 ec 0c             	sub    $0xc,%esp
8010817f:	ff 75 f0             	push   -0x10(%ebp)
80108182:	e8 11 05 00 00       	call   80108698 <freevm>
80108187:	83 c4 10             	add    $0x10,%esp
      return 0;
8010818a:	b8 00 00 00 00       	mov    $0x0,%eax
8010818f:	eb 10                	jmp    801081a1 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108191:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108195:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
8010819c:	72 a9                	jb     80108147 <setupkvm+0x92>
    }
  return pgdir;
8010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801081a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081a4:	c9                   	leave
801081a5:	c3                   	ret

801081a6 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801081a6:	f3 0f 1e fb          	endbr32
801081aa:	55                   	push   %ebp
801081ab:	89 e5                	mov    %esp,%ebp
801081ad:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801081b0:	e8 00 ff ff ff       	call   801080b5 <setupkvm>
801081b5:	a3 a4 8c 19 80       	mov    %eax,0x80198ca4
  switchkvm();
801081ba:	e8 03 00 00 00       	call   801081c2 <switchkvm>
}
801081bf:	90                   	nop
801081c0:	c9                   	leave
801081c1:	c3                   	ret

801081c2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801081c2:	f3 0f 1e fb          	endbr32
801081c6:	55                   	push   %ebp
801081c7:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801081c9:	a1 a4 8c 19 80       	mov    0x80198ca4,%eax
801081ce:	05 00 00 00 80       	add    $0x80000000,%eax
801081d3:	50                   	push   %eax
801081d4:	e8 48 fa ff ff       	call   80107c21 <lcr3>
801081d9:	83 c4 04             	add    $0x4,%esp
}
801081dc:	90                   	nop
801081dd:	c9                   	leave
801081de:	c3                   	ret

801081df <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081df:	f3 0f 1e fb          	endbr32
801081e3:	55                   	push   %ebp
801081e4:	89 e5                	mov    %esp,%ebp
801081e6:	56                   	push   %esi
801081e7:	53                   	push   %ebx
801081e8:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801081eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081ef:	75 0d                	jne    801081fe <switchuvm+0x1f>
    panic("switchuvm: no process");
801081f1:	83 ec 0c             	sub    $0xc,%esp
801081f4:	68 5a b5 10 80       	push   $0x8010b55a
801081f9:	e8 c7 83 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801081fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108201:	8b 40 08             	mov    0x8(%eax),%eax
80108204:	85 c0                	test   %eax,%eax
80108206:	75 0d                	jne    80108215 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108208:	83 ec 0c             	sub    $0xc,%esp
8010820b:	68 70 b5 10 80       	push   $0x8010b570
80108210:	e8 b0 83 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80108215:	8b 45 08             	mov    0x8(%ebp),%eax
80108218:	8b 40 04             	mov    0x4(%eax),%eax
8010821b:	85 c0                	test   %eax,%eax
8010821d:	75 0d                	jne    8010822c <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010821f:	83 ec 0c             	sub    $0xc,%esp
80108222:	68 85 b5 10 80       	push   $0x8010b585
80108227:	e8 99 83 ff ff       	call   801005c5 <panic>

  pushcli();
8010822c:	e8 4c d2 ff ff       	call   8010547d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108231:	e8 f7 b8 ff ff       	call   80103b2d <mycpu>
80108236:	89 c3                	mov    %eax,%ebx
80108238:	e8 f0 b8 ff ff       	call   80103b2d <mycpu>
8010823d:	83 c0 08             	add    $0x8,%eax
80108240:	89 c6                	mov    %eax,%esi
80108242:	e8 e6 b8 ff ff       	call   80103b2d <mycpu>
80108247:	83 c0 08             	add    $0x8,%eax
8010824a:	c1 e8 10             	shr    $0x10,%eax
8010824d:	88 45 f7             	mov    %al,-0x9(%ebp)
80108250:	e8 d8 b8 ff ff       	call   80103b2d <mycpu>
80108255:	83 c0 08             	add    $0x8,%eax
80108258:	c1 e8 18             	shr    $0x18,%eax
8010825b:	89 c2                	mov    %eax,%edx
8010825d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108264:	67 00 
80108266:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010826d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108271:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108277:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010827e:	83 e0 f0             	and    $0xfffffff0,%eax
80108281:	83 c8 09             	or     $0x9,%eax
80108284:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010828a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108291:	83 c8 10             	or     $0x10,%eax
80108294:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010829a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082a1:	83 e0 9f             	and    $0xffffff9f,%eax
801082a4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801082aa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082b1:	83 c8 80             	or     $0xffffff80,%eax
801082b4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801082ba:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082c1:	83 e0 f0             	and    $0xfffffff0,%eax
801082c4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082ca:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082d1:	83 e0 ef             	and    $0xffffffef,%eax
801082d4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082da:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082e1:	83 e0 df             	and    $0xffffffdf,%eax
801082e4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082ea:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082f1:	83 c8 40             	or     $0x40,%eax
801082f4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082fa:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108301:	83 e0 7f             	and    $0x7f,%eax
80108304:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010830a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108310:	e8 18 b8 ff ff       	call   80103b2d <mycpu>
80108315:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010831c:	83 e2 ef             	and    $0xffffffef,%edx
8010831f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108325:	e8 03 b8 ff ff       	call   80103b2d <mycpu>
8010832a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108330:	8b 45 08             	mov    0x8(%ebp),%eax
80108333:	8b 40 08             	mov    0x8(%eax),%eax
80108336:	89 c3                	mov    %eax,%ebx
80108338:	e8 f0 b7 ff ff       	call   80103b2d <mycpu>
8010833d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108343:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108346:	e8 e2 b7 ff ff       	call   80103b2d <mycpu>
8010834b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108351:	83 ec 0c             	sub    $0xc,%esp
80108354:	6a 28                	push   $0x28
80108356:	e8 af f8 ff ff       	call   80107c0a <ltr>
8010835b:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010835e:	8b 45 08             	mov    0x8(%ebp),%eax
80108361:	8b 40 04             	mov    0x4(%eax),%eax
80108364:	05 00 00 00 80       	add    $0x80000000,%eax
80108369:	83 ec 0c             	sub    $0xc,%esp
8010836c:	50                   	push   %eax
8010836d:	e8 af f8 ff ff       	call   80107c21 <lcr3>
80108372:	83 c4 10             	add    $0x10,%esp
  popcli();
80108375:	e8 54 d1 ff ff       	call   801054ce <popcli>
}
8010837a:	90                   	nop
8010837b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010837e:	5b                   	pop    %ebx
8010837f:	5e                   	pop    %esi
80108380:	5d                   	pop    %ebp
80108381:	c3                   	ret

80108382 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108382:	f3 0f 1e fb          	endbr32
80108386:	55                   	push   %ebp
80108387:	89 e5                	mov    %esp,%ebp
80108389:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010838c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108393:	76 0d                	jbe    801083a2 <inituvm+0x20>
    panic("inituvm: more than a page");
80108395:	83 ec 0c             	sub    $0xc,%esp
80108398:	68 99 b5 10 80       	push   $0x8010b599
8010839d:	e8 23 82 ff ff       	call   801005c5 <panic>
  mem = kalloc();
801083a2:	e8 eb a4 ff ff       	call   80102892 <kalloc>
801083a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801083aa:	83 ec 04             	sub    $0x4,%esp
801083ad:	68 00 10 00 00       	push   $0x1000
801083b2:	6a 00                	push   $0x0
801083b4:	ff 75 f4             	push   -0xc(%ebp)
801083b7:	e8 d4 d1 ff ff       	call   80105590 <memset>
801083bc:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801083bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c2:	05 00 00 00 80       	add    $0x80000000,%eax
801083c7:	83 ec 0c             	sub    $0xc,%esp
801083ca:	6a 06                	push   $0x6
801083cc:	50                   	push   %eax
801083cd:	68 00 10 00 00       	push   $0x1000
801083d2:	6a 00                	push   $0x0
801083d4:	ff 75 08             	push   0x8(%ebp)
801083d7:	e8 45 fc ff ff       	call   80108021 <mappages>
801083dc:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801083df:	83 ec 04             	sub    $0x4,%esp
801083e2:	ff 75 10             	push   0x10(%ebp)
801083e5:	ff 75 0c             	push   0xc(%ebp)
801083e8:	ff 75 f4             	push   -0xc(%ebp)
801083eb:	e8 67 d2 ff ff       	call   80105657 <memmove>
801083f0:	83 c4 10             	add    $0x10,%esp
}
801083f3:	90                   	nop
801083f4:	c9                   	leave
801083f5:	c3                   	ret

801083f6 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083f6:	f3 0f 1e fb          	endbr32
801083fa:	55                   	push   %ebp
801083fb:	89 e5                	mov    %esp,%ebp
801083fd:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108400:	8b 45 0c             	mov    0xc(%ebp),%eax
80108403:	25 ff 0f 00 00       	and    $0xfff,%eax
80108408:	85 c0                	test   %eax,%eax
8010840a:	74 0d                	je     80108419 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
8010840c:	83 ec 0c             	sub    $0xc,%esp
8010840f:	68 b4 b5 10 80       	push   $0x8010b5b4
80108414:	e8 ac 81 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108419:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108420:	e9 8f 00 00 00       	jmp    801084b4 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108425:	8b 55 0c             	mov    0xc(%ebp),%edx
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	01 d0                	add    %edx,%eax
8010842d:	83 ec 04             	sub    $0x4,%esp
80108430:	6a 00                	push   $0x0
80108432:	50                   	push   %eax
80108433:	ff 75 08             	push   0x8(%ebp)
80108436:	e8 4c fb ff ff       	call   80107f87 <walkpgdir>
8010843b:	83 c4 10             	add    $0x10,%esp
8010843e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108441:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108445:	75 0d                	jne    80108454 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108447:	83 ec 0c             	sub    $0xc,%esp
8010844a:	68 d7 b5 10 80       	push   $0x8010b5d7
8010844f:	e8 71 81 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108454:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108457:	8b 00                	mov    (%eax),%eax
80108459:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010845e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108461:	8b 45 18             	mov    0x18(%ebp),%eax
80108464:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108467:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010846c:	77 0b                	ja     80108479 <loaduvm+0x83>
      n = sz - i;
8010846e:	8b 45 18             	mov    0x18(%ebp),%eax
80108471:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108474:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108477:	eb 07                	jmp    80108480 <loaduvm+0x8a>
    else
      n = PGSIZE;
80108479:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108480:	8b 55 14             	mov    0x14(%ebp),%edx
80108483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108486:	01 d0                	add    %edx,%eax
80108488:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010848b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108491:	ff 75 f0             	push   -0x10(%ebp)
80108494:	50                   	push   %eax
80108495:	52                   	push   %edx
80108496:	ff 75 10             	push   0x10(%ebp)
80108499:	e8 e6 9a ff ff       	call   80101f84 <readi>
8010849e:	83 c4 10             	add    $0x10,%esp
801084a1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801084a4:	74 07                	je     801084ad <loaduvm+0xb7>
      return -1;
801084a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084ab:	eb 18                	jmp    801084c5 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801084ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b7:	3b 45 18             	cmp    0x18(%ebp),%eax
801084ba:	0f 82 65 ff ff ff    	jb     80108425 <loaduvm+0x2f>
  }
  return 0;
801084c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084c5:	c9                   	leave
801084c6:	c3                   	ret

801084c7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084c7:	f3 0f 1e fb          	endbr32
801084cb:	55                   	push   %ebp
801084cc:	89 e5                	mov    %esp,%ebp
801084ce:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801084d1:	8b 45 10             	mov    0x10(%ebp),%eax
801084d4:	85 c0                	test   %eax,%eax
801084d6:	79 0a                	jns    801084e2 <allocuvm+0x1b>
    return 0;
801084d8:	b8 00 00 00 00       	mov    $0x0,%eax
801084dd:	e9 ec 00 00 00       	jmp    801085ce <allocuvm+0x107>
  if(newsz < oldsz)
801084e2:	8b 45 10             	mov    0x10(%ebp),%eax
801084e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084e8:	73 08                	jae    801084f2 <allocuvm+0x2b>
    return oldsz;
801084ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ed:	e9 dc 00 00 00       	jmp    801085ce <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801084f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f5:	05 ff 0f 00 00       	add    $0xfff,%eax
801084fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108502:	e9 b8 00 00 00       	jmp    801085bf <allocuvm+0xf8>
    mem = kalloc();
80108507:	e8 86 a3 ff ff       	call   80102892 <kalloc>
8010850c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010850f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108513:	75 2e                	jne    80108543 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108515:	83 ec 0c             	sub    $0xc,%esp
80108518:	68 f5 b5 10 80       	push   $0x8010b5f5
8010851d:	e8 ea 7e ff ff       	call   8010040c <cprintf>
80108522:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108525:	83 ec 04             	sub    $0x4,%esp
80108528:	ff 75 0c             	push   0xc(%ebp)
8010852b:	ff 75 10             	push   0x10(%ebp)
8010852e:	ff 75 08             	push   0x8(%ebp)
80108531:	e8 9a 00 00 00       	call   801085d0 <deallocuvm>
80108536:	83 c4 10             	add    $0x10,%esp
      return 0;
80108539:	b8 00 00 00 00       	mov    $0x0,%eax
8010853e:	e9 8b 00 00 00       	jmp    801085ce <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108543:	83 ec 04             	sub    $0x4,%esp
80108546:	68 00 10 00 00       	push   $0x1000
8010854b:	6a 00                	push   $0x0
8010854d:	ff 75 f0             	push   -0x10(%ebp)
80108550:	e8 3b d0 ff ff       	call   80105590 <memset>
80108555:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010855b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	83 ec 0c             	sub    $0xc,%esp
80108567:	6a 06                	push   $0x6
80108569:	52                   	push   %edx
8010856a:	68 00 10 00 00       	push   $0x1000
8010856f:	50                   	push   %eax
80108570:	ff 75 08             	push   0x8(%ebp)
80108573:	e8 a9 fa ff ff       	call   80108021 <mappages>
80108578:	83 c4 20             	add    $0x20,%esp
8010857b:	85 c0                	test   %eax,%eax
8010857d:	79 39                	jns    801085b8 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010857f:	83 ec 0c             	sub    $0xc,%esp
80108582:	68 0d b6 10 80       	push   $0x8010b60d
80108587:	e8 80 7e ff ff       	call   8010040c <cprintf>
8010858c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010858f:	83 ec 04             	sub    $0x4,%esp
80108592:	ff 75 0c             	push   0xc(%ebp)
80108595:	ff 75 10             	push   0x10(%ebp)
80108598:	ff 75 08             	push   0x8(%ebp)
8010859b:	e8 30 00 00 00       	call   801085d0 <deallocuvm>
801085a0:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801085a3:	83 ec 0c             	sub    $0xc,%esp
801085a6:	ff 75 f0             	push   -0x10(%ebp)
801085a9:	e8 46 a2 ff ff       	call   801027f4 <kfree>
801085ae:	83 c4 10             	add    $0x10,%esp
      return 0;
801085b1:	b8 00 00 00 00       	mov    $0x0,%eax
801085b6:	eb 16                	jmp    801085ce <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801085b8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801085c5:	0f 82 3c ff ff ff    	jb     80108507 <allocuvm+0x40>
    }
  }
  return newsz;
801085cb:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085ce:	c9                   	leave
801085cf:	c3                   	ret

801085d0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085d0:	f3 0f 1e fb          	endbr32
801085d4:	55                   	push   %ebp
801085d5:	89 e5                	mov    %esp,%ebp
801085d7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801085da:	8b 45 10             	mov    0x10(%ebp),%eax
801085dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085e0:	72 08                	jb     801085ea <deallocuvm+0x1a>
    return oldsz;
801085e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e5:	e9 ac 00 00 00       	jmp    80108696 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
801085ea:	8b 45 10             	mov    0x10(%ebp),%eax
801085ed:	05 ff 0f 00 00       	add    $0xfff,%eax
801085f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085fa:	e9 88 00 00 00       	jmp    80108687 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108602:	83 ec 04             	sub    $0x4,%esp
80108605:	6a 00                	push   $0x0
80108607:	50                   	push   %eax
80108608:	ff 75 08             	push   0x8(%ebp)
8010860b:	e8 77 f9 ff ff       	call   80107f87 <walkpgdir>
80108610:	83 c4 10             	add    $0x10,%esp
80108613:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108616:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010861a:	75 16                	jne    80108632 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010861c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861f:	c1 e8 16             	shr    $0x16,%eax
80108622:	83 c0 01             	add    $0x1,%eax
80108625:	c1 e0 16             	shl    $0x16,%eax
80108628:	2d 00 10 00 00       	sub    $0x1000,%eax
8010862d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108630:	eb 4e                	jmp    80108680 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80108632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108635:	8b 00                	mov    (%eax),%eax
80108637:	83 e0 01             	and    $0x1,%eax
8010863a:	85 c0                	test   %eax,%eax
8010863c:	74 42                	je     80108680 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
8010863e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108641:	8b 00                	mov    (%eax),%eax
80108643:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108648:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010864b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010864f:	75 0d                	jne    8010865e <deallocuvm+0x8e>
        panic("kfree");
80108651:	83 ec 0c             	sub    $0xc,%esp
80108654:	68 29 b6 10 80       	push   $0x8010b629
80108659:	e8 67 7f ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
8010865e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108661:	05 00 00 00 80       	add    $0x80000000,%eax
80108666:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108669:	83 ec 0c             	sub    $0xc,%esp
8010866c:	ff 75 e8             	push   -0x18(%ebp)
8010866f:	e8 80 a1 ff ff       	call   801027f4 <kfree>
80108674:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108680:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010868d:	0f 82 6c ff ff ff    	jb     801085ff <deallocuvm+0x2f>
    }
  }
  return newsz;
80108693:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108696:	c9                   	leave
80108697:	c3                   	ret

80108698 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108698:	f3 0f 1e fb          	endbr32
8010869c:	55                   	push   %ebp
8010869d:	89 e5                	mov    %esp,%ebp
8010869f:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801086a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801086a6:	75 0d                	jne    801086b5 <freevm+0x1d>
    panic("freevm: no pgdir");
801086a8:	83 ec 0c             	sub    $0xc,%esp
801086ab:	68 2f b6 10 80       	push   $0x8010b62f
801086b0:	e8 10 7f ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801086b5:	83 ec 04             	sub    $0x4,%esp
801086b8:	6a 00                	push   $0x0
801086ba:	68 00 00 00 80       	push   $0x80000000
801086bf:	ff 75 08             	push   0x8(%ebp)
801086c2:	e8 09 ff ff ff       	call   801085d0 <deallocuvm>
801086c7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086d1:	eb 48                	jmp    8010871b <freevm+0x83>
    if(pgdir[i] & PTE_P){
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086dd:	8b 45 08             	mov    0x8(%ebp),%eax
801086e0:	01 d0                	add    %edx,%eax
801086e2:	8b 00                	mov    (%eax),%eax
801086e4:	83 e0 01             	and    $0x1,%eax
801086e7:	85 c0                	test   %eax,%eax
801086e9:	74 2c                	je     80108717 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801086eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086f5:	8b 45 08             	mov    0x8(%ebp),%eax
801086f8:	01 d0                	add    %edx,%eax
801086fa:	8b 00                	mov    (%eax),%eax
801086fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108701:	05 00 00 00 80       	add    $0x80000000,%eax
80108706:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108709:	83 ec 0c             	sub    $0xc,%esp
8010870c:	ff 75 f0             	push   -0x10(%ebp)
8010870f:	e8 e0 a0 ff ff       	call   801027f4 <kfree>
80108714:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108717:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010871b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108722:	76 af                	jbe    801086d3 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108724:	83 ec 0c             	sub    $0xc,%esp
80108727:	ff 75 08             	push   0x8(%ebp)
8010872a:	e8 c5 a0 ff ff       	call   801027f4 <kfree>
8010872f:	83 c4 10             	add    $0x10,%esp
}
80108732:	90                   	nop
80108733:	c9                   	leave
80108734:	c3                   	ret

80108735 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108735:	f3 0f 1e fb          	endbr32
80108739:	55                   	push   %ebp
8010873a:	89 e5                	mov    %esp,%ebp
8010873c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010873f:	83 ec 04             	sub    $0x4,%esp
80108742:	6a 00                	push   $0x0
80108744:	ff 75 0c             	push   0xc(%ebp)
80108747:	ff 75 08             	push   0x8(%ebp)
8010874a:	e8 38 f8 ff ff       	call   80107f87 <walkpgdir>
8010874f:	83 c4 10             	add    $0x10,%esp
80108752:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108755:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108759:	75 0d                	jne    80108768 <clearpteu+0x33>
    panic("clearpteu");
8010875b:	83 ec 0c             	sub    $0xc,%esp
8010875e:	68 40 b6 10 80       	push   $0x8010b640
80108763:	e8 5d 7e ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80108768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876b:	8b 00                	mov    (%eax),%eax
8010876d:	83 e0 fb             	and    $0xfffffffb,%eax
80108770:	89 c2                	mov    %eax,%edx
80108772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108775:	89 10                	mov    %edx,(%eax)
}
80108777:	90                   	nop
80108778:	c9                   	leave
80108779:	c3                   	ret

8010877a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010877a:	f3 0f 1e fb          	endbr32
8010877e:	55                   	push   %ebp
8010877f:	89 e5                	mov    %esp,%ebp
80108781:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108784:	e8 2c f9 ff ff       	call   801080b5 <setupkvm>
80108789:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010878c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108790:	75 0a                	jne    8010879c <copyuvm+0x22>
    return 0;
80108792:	b8 00 00 00 00       	mov    $0x0,%eax
80108797:	e9 eb 00 00 00       	jmp    80108887 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
8010879c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087a3:	e9 b7 00 00 00       	jmp    8010885f <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	83 ec 04             	sub    $0x4,%esp
801087ae:	6a 00                	push   $0x0
801087b0:	50                   	push   %eax
801087b1:	ff 75 08             	push   0x8(%ebp)
801087b4:	e8 ce f7 ff ff       	call   80107f87 <walkpgdir>
801087b9:	83 c4 10             	add    $0x10,%esp
801087bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087c3:	75 0d                	jne    801087d2 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801087c5:	83 ec 0c             	sub    $0xc,%esp
801087c8:	68 4a b6 10 80       	push   $0x8010b64a
801087cd:	e8 f3 7d ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
801087d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d5:	8b 00                	mov    (%eax),%eax
801087d7:	83 e0 01             	and    $0x1,%eax
801087da:	85 c0                	test   %eax,%eax
801087dc:	75 0d                	jne    801087eb <copyuvm+0x71>
      panic("copyuvm: page not present");
801087de:	83 ec 0c             	sub    $0xc,%esp
801087e1:	68 64 b6 10 80       	push   $0x8010b664
801087e6:	e8 da 7d ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801087eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ee:	8b 00                	mov    (%eax),%eax
801087f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fb:	8b 00                	mov    (%eax),%eax
801087fd:	25 ff 0f 00 00       	and    $0xfff,%eax
80108802:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108805:	e8 88 a0 ff ff       	call   80102892 <kalloc>
8010880a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010880d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108811:	74 5d                	je     80108870 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108813:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108816:	05 00 00 00 80       	add    $0x80000000,%eax
8010881b:	83 ec 04             	sub    $0x4,%esp
8010881e:	68 00 10 00 00       	push   $0x1000
80108823:	50                   	push   %eax
80108824:	ff 75 e0             	push   -0x20(%ebp)
80108827:	e8 2b ce ff ff       	call   80105657 <memmove>
8010882c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010882f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108832:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108835:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010883b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883e:	83 ec 0c             	sub    $0xc,%esp
80108841:	52                   	push   %edx
80108842:	51                   	push   %ecx
80108843:	68 00 10 00 00       	push   $0x1000
80108848:	50                   	push   %eax
80108849:	ff 75 f0             	push   -0x10(%ebp)
8010884c:	e8 d0 f7 ff ff       	call   80108021 <mappages>
80108851:	83 c4 20             	add    $0x20,%esp
80108854:	85 c0                	test   %eax,%eax
80108856:	78 1b                	js     80108873 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80108858:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010885f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108862:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108865:	0f 82 3d ff ff ff    	jb     801087a8 <copyuvm+0x2e>
      goto bad;
  }
  return d;
8010886b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886e:	eb 17                	jmp    80108887 <copyuvm+0x10d>
      goto bad;
80108870:	90                   	nop
80108871:	eb 01                	jmp    80108874 <copyuvm+0xfa>
      goto bad;
80108873:	90                   	nop

bad:
  freevm(d);
80108874:	83 ec 0c             	sub    $0xc,%esp
80108877:	ff 75 f0             	push   -0x10(%ebp)
8010887a:	e8 19 fe ff ff       	call   80108698 <freevm>
8010887f:	83 c4 10             	add    $0x10,%esp
  return 0;
80108882:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108887:	c9                   	leave
80108888:	c3                   	ret

80108889 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108889:	f3 0f 1e fb          	endbr32
8010888d:	55                   	push   %ebp
8010888e:	89 e5                	mov    %esp,%ebp
80108890:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108893:	83 ec 04             	sub    $0x4,%esp
80108896:	6a 00                	push   $0x0
80108898:	ff 75 0c             	push   0xc(%ebp)
8010889b:	ff 75 08             	push   0x8(%ebp)
8010889e:	e8 e4 f6 ff ff       	call   80107f87 <walkpgdir>
801088a3:	83 c4 10             	add    $0x10,%esp
801088a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801088a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ac:	8b 00                	mov    (%eax),%eax
801088ae:	83 e0 01             	and    $0x1,%eax
801088b1:	85 c0                	test   %eax,%eax
801088b3:	75 07                	jne    801088bc <uva2ka+0x33>
    return 0;
801088b5:	b8 00 00 00 00       	mov    $0x0,%eax
801088ba:	eb 22                	jmp    801088de <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
801088bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bf:	8b 00                	mov    (%eax),%eax
801088c1:	83 e0 04             	and    $0x4,%eax
801088c4:	85 c0                	test   %eax,%eax
801088c6:	75 07                	jne    801088cf <uva2ka+0x46>
    return 0;
801088c8:	b8 00 00 00 00       	mov    $0x0,%eax
801088cd:	eb 0f                	jmp    801088de <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
801088cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d2:	8b 00                	mov    (%eax),%eax
801088d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088d9:	05 00 00 00 80       	add    $0x80000000,%eax
}
801088de:	c9                   	leave
801088df:	c3                   	ret

801088e0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088e0:	f3 0f 1e fb          	endbr32
801088e4:	55                   	push   %ebp
801088e5:	89 e5                	mov    %esp,%ebp
801088e7:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088ea:	8b 45 10             	mov    0x10(%ebp),%eax
801088ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088f0:	eb 7f                	jmp    80108971 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801088f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108900:	83 ec 08             	sub    $0x8,%esp
80108903:	50                   	push   %eax
80108904:	ff 75 08             	push   0x8(%ebp)
80108907:	e8 7d ff ff ff       	call   80108889 <uva2ka>
8010890c:	83 c4 10             	add    $0x10,%esp
8010890f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108912:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108916:	75 07                	jne    8010891f <copyout+0x3f>
      return -1;
80108918:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010891d:	eb 61                	jmp    80108980 <copyout+0xa0>
    n = PGSIZE - (va - va0);
8010891f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108922:	2b 45 0c             	sub    0xc(%ebp),%eax
80108925:	05 00 10 00 00       	add    $0x1000,%eax
8010892a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010892d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108930:	3b 45 14             	cmp    0x14(%ebp),%eax
80108933:	76 06                	jbe    8010893b <copyout+0x5b>
      n = len;
80108935:	8b 45 14             	mov    0x14(%ebp),%eax
80108938:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010893b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010893e:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108941:	89 c2                	mov    %eax,%edx
80108943:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108946:	01 d0                	add    %edx,%eax
80108948:	83 ec 04             	sub    $0x4,%esp
8010894b:	ff 75 f0             	push   -0x10(%ebp)
8010894e:	ff 75 f4             	push   -0xc(%ebp)
80108951:	50                   	push   %eax
80108952:	e8 00 cd ff ff       	call   80105657 <memmove>
80108957:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010895a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108963:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108966:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108969:	05 00 10 00 00       	add    $0x1000,%eax
8010896e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108971:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108975:	0f 85 77 ff ff ff    	jne    801088f2 <copyout+0x12>
  }
  return 0;
8010897b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108980:	c9                   	leave
80108981:	c3                   	ret

80108982 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108982:	f3 0f 1e fb          	endbr32
80108986:	55                   	push   %ebp
80108987:	89 e5                	mov    %esp,%ebp
80108989:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010898c:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108993:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108996:	8b 40 08             	mov    0x8(%eax),%eax
80108999:	05 00 00 00 80       	add    $0x80000000,%eax
8010899e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801089a1:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801089a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ab:	8b 40 24             	mov    0x24(%eax),%eax
801089ae:	a3 3c 54 19 80       	mov    %eax,0x8019543c
  ncpu = 0;
801089b3:	c7 05 94 8d 19 80 00 	movl   $0x0,0x80198d94
801089ba:	00 00 00 

  while(i<madt->len){
801089bd:	90                   	nop
801089be:	e9 bd 00 00 00       	jmp    80108a80 <mpinit_uefi+0xfe>
    uchar *entry_type = ((uchar *)madt)+i;
801089c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089c9:	01 d0                	add    %edx,%eax
801089cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801089ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d1:	0f b6 00             	movzbl (%eax),%eax
801089d4:	0f b6 c0             	movzbl %al,%eax
801089d7:	83 f8 05             	cmp    $0x5,%eax
801089da:	0f 87 a0 00 00 00    	ja     80108a80 <mpinit_uefi+0xfe>
801089e0:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
801089e7:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801089ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801089f0:	a1 94 8d 19 80       	mov    0x80198d94,%eax
801089f5:	85 c0                	test   %eax,%eax
801089f7:	7f 28                	jg     80108a21 <mpinit_uefi+0x9f>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801089f9:	8b 15 94 8d 19 80    	mov    0x80198d94,%edx
801089ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a02:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108a06:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108a0c:	81 c2 e0 8c 19 80    	add    $0x80198ce0,%edx
80108a12:	88 02                	mov    %al,(%edx)
          ncpu++;
80108a14:	a1 94 8d 19 80       	mov    0x80198d94,%eax
80108a19:	83 c0 01             	add    $0x1,%eax
80108a1c:	a3 94 8d 19 80       	mov    %eax,0x80198d94
        }
        i += lapic_entry->record_len;
80108a21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a24:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a28:	0f b6 c0             	movzbl %al,%eax
80108a2b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108a2e:	eb 50                	jmp    80108a80 <mpinit_uefi+0xfe>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108a36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a39:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a3d:	a2 c0 8c 19 80       	mov    %al,0x80198cc0
        i += ioapic->record_len;
80108a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a45:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a49:	0f b6 c0             	movzbl %al,%eax
80108a4c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108a4f:	eb 2f                	jmp    80108a80 <mpinit_uefi+0xfe>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a54:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108a57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a5a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a5e:	0f b6 c0             	movzbl %al,%eax
80108a61:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108a64:	eb 1a                	jmp    80108a80 <mpinit_uefi+0xfe>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a73:	0f b6 c0             	movzbl %al,%eax
80108a76:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108a79:	eb 05                	jmp    80108a80 <mpinit_uefi+0xfe>

      case 5:
        i = i + 0xC;
80108a7b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108a7f:	90                   	nop
  while(i<madt->len){
80108a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a83:	8b 40 04             	mov    0x4(%eax),%eax
80108a86:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108a89:	0f 82 34 ff ff ff    	jb     801089c3 <mpinit_uefi+0x41>
    }
  }

}
80108a8f:	90                   	nop
80108a90:	90                   	nop
80108a91:	c9                   	leave
80108a92:	c3                   	ret

80108a93 <inb>:
{
80108a93:	55                   	push   %ebp
80108a94:	89 e5                	mov    %esp,%ebp
80108a96:	83 ec 14             	sub    $0x14,%esp
80108a99:	8b 45 08             	mov    0x8(%ebp),%eax
80108a9c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108aa0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108aa4:	89 c2                	mov    %eax,%edx
80108aa6:	ec                   	in     (%dx),%al
80108aa7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108aaa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108aae:	c9                   	leave
80108aaf:	c3                   	ret

80108ab0 <outb>:
{
80108ab0:	55                   	push   %ebp
80108ab1:	89 e5                	mov    %esp,%ebp
80108ab3:	83 ec 08             	sub    $0x8,%esp
80108ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108abc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108ac0:	89 d0                	mov    %edx,%eax
80108ac2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108ac5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108ac9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108acd:	ee                   	out    %al,(%dx)
}
80108ace:	90                   	nop
80108acf:	c9                   	leave
80108ad0:	c3                   	ret

80108ad1 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108ad1:	f3 0f 1e fb          	endbr32
80108ad5:	55                   	push   %ebp
80108ad6:	89 e5                	mov    %esp,%ebp
80108ad8:	83 ec 28             	sub    $0x28,%esp
80108adb:	8b 45 08             	mov    0x8(%ebp),%eax
80108ade:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108ae1:	6a 00                	push   $0x0
80108ae3:	68 fa 03 00 00       	push   $0x3fa
80108ae8:	e8 c3 ff ff ff       	call   80108ab0 <outb>
80108aed:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108af0:	68 80 00 00 00       	push   $0x80
80108af5:	68 fb 03 00 00       	push   $0x3fb
80108afa:	e8 b1 ff ff ff       	call   80108ab0 <outb>
80108aff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108b02:	6a 0c                	push   $0xc
80108b04:	68 f8 03 00 00       	push   $0x3f8
80108b09:	e8 a2 ff ff ff       	call   80108ab0 <outb>
80108b0e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108b11:	6a 00                	push   $0x0
80108b13:	68 f9 03 00 00       	push   $0x3f9
80108b18:	e8 93 ff ff ff       	call   80108ab0 <outb>
80108b1d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108b20:	6a 03                	push   $0x3
80108b22:	68 fb 03 00 00       	push   $0x3fb
80108b27:	e8 84 ff ff ff       	call   80108ab0 <outb>
80108b2c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108b2f:	6a 00                	push   $0x0
80108b31:	68 fc 03 00 00       	push   $0x3fc
80108b36:	e8 75 ff ff ff       	call   80108ab0 <outb>
80108b3b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108b3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b45:	eb 11                	jmp    80108b58 <uart_debug+0x87>
80108b47:	83 ec 0c             	sub    $0xc,%esp
80108b4a:	6a 0a                	push   $0xa
80108b4c:	e8 f3 a0 ff ff       	call   80102c44 <microdelay>
80108b51:	83 c4 10             	add    $0x10,%esp
80108b54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b58:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108b5c:	7f 1a                	jg     80108b78 <uart_debug+0xa7>
80108b5e:	83 ec 0c             	sub    $0xc,%esp
80108b61:	68 fd 03 00 00       	push   $0x3fd
80108b66:	e8 28 ff ff ff       	call   80108a93 <inb>
80108b6b:	83 c4 10             	add    $0x10,%esp
80108b6e:	0f b6 c0             	movzbl %al,%eax
80108b71:	83 e0 20             	and    $0x20,%eax
80108b74:	85 c0                	test   %eax,%eax
80108b76:	74 cf                	je     80108b47 <uart_debug+0x76>
  outb(COM1+0, p);
80108b78:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108b7c:	0f b6 c0             	movzbl %al,%eax
80108b7f:	83 ec 08             	sub    $0x8,%esp
80108b82:	50                   	push   %eax
80108b83:	68 f8 03 00 00       	push   $0x3f8
80108b88:	e8 23 ff ff ff       	call   80108ab0 <outb>
80108b8d:	83 c4 10             	add    $0x10,%esp
}
80108b90:	90                   	nop
80108b91:	c9                   	leave
80108b92:	c3                   	ret

80108b93 <uart_debugs>:

void uart_debugs(char *p){
80108b93:	f3 0f 1e fb          	endbr32
80108b97:	55                   	push   %ebp
80108b98:	89 e5                	mov    %esp,%ebp
80108b9a:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108b9d:	eb 1b                	jmp    80108bba <uart_debugs+0x27>
    uart_debug(*p++);
80108b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ba2:	8d 50 01             	lea    0x1(%eax),%edx
80108ba5:	89 55 08             	mov    %edx,0x8(%ebp)
80108ba8:	0f b6 00             	movzbl (%eax),%eax
80108bab:	0f be c0             	movsbl %al,%eax
80108bae:	83 ec 0c             	sub    $0xc,%esp
80108bb1:	50                   	push   %eax
80108bb2:	e8 1a ff ff ff       	call   80108ad1 <uart_debug>
80108bb7:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108bba:	8b 45 08             	mov    0x8(%ebp),%eax
80108bbd:	0f b6 00             	movzbl (%eax),%eax
80108bc0:	84 c0                	test   %al,%al
80108bc2:	75 db                	jne    80108b9f <uart_debugs+0xc>
  }
}
80108bc4:	90                   	nop
80108bc5:	90                   	nop
80108bc6:	c9                   	leave
80108bc7:	c3                   	ret

80108bc8 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108bc8:	f3 0f 1e fb          	endbr32
80108bcc:	55                   	push   %ebp
80108bcd:	89 e5                	mov    %esp,%ebp
80108bcf:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108bd2:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108bdc:	8b 50 14             	mov    0x14(%eax),%edx
80108bdf:	8b 40 10             	mov    0x10(%eax),%eax
80108be2:	a3 98 8d 19 80       	mov    %eax,0x80198d98
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108bea:	8b 50 1c             	mov    0x1c(%eax),%edx
80108bed:	8b 40 18             	mov    0x18(%eax),%eax
80108bf0:	a3 a0 8d 19 80       	mov    %eax,0x80198da0
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108bf5:	a1 a0 8d 19 80       	mov    0x80198da0,%eax
80108bfa:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108bff:	29 c2                	sub    %eax,%edx
80108c01:	89 d0                	mov    %edx,%eax
80108c03:	a3 9c 8d 19 80       	mov    %eax,0x80198d9c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108c08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c0b:	8b 50 24             	mov    0x24(%eax),%edx
80108c0e:	8b 40 20             	mov    0x20(%eax),%eax
80108c11:	a3 a4 8d 19 80       	mov    %eax,0x80198da4
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108c16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c19:	8b 50 2c             	mov    0x2c(%eax),%edx
80108c1c:	8b 40 28             	mov    0x28(%eax),%eax
80108c1f:	a3 a8 8d 19 80       	mov    %eax,0x80198da8
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c27:	8b 50 34             	mov    0x34(%eax),%edx
80108c2a:	8b 40 30             	mov    0x30(%eax),%eax
80108c2d:	a3 ac 8d 19 80       	mov    %eax,0x80198dac
}
80108c32:	90                   	nop
80108c33:	c9                   	leave
80108c34:	c3                   	ret

80108c35 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108c35:	f3 0f 1e fb          	endbr32
80108c39:	55                   	push   %ebp
80108c3a:	89 e5                	mov    %esp,%ebp
80108c3c:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108c3f:	8b 15 ac 8d 19 80    	mov    0x80198dac,%edx
80108c45:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c48:	0f af d0             	imul   %eax,%edx
80108c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4e:	01 d0                	add    %edx,%eax
80108c50:	c1 e0 02             	shl    $0x2,%eax
80108c53:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108c56:	8b 15 9c 8d 19 80    	mov    0x80198d9c,%edx
80108c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108c5f:	01 d0                	add    %edx,%eax
80108c61:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108c64:	8b 45 10             	mov    0x10(%ebp),%eax
80108c67:	0f b6 10             	movzbl (%eax),%edx
80108c6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108c6d:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108c6f:	8b 45 10             	mov    0x10(%ebp),%eax
80108c72:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108c76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108c79:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108c7c:	8b 45 10             	mov    0x10(%ebp),%eax
80108c7f:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108c83:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108c86:	88 50 02             	mov    %dl,0x2(%eax)
}
80108c89:	90                   	nop
80108c8a:	c9                   	leave
80108c8b:	c3                   	ret

80108c8c <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108c8c:	f3 0f 1e fb          	endbr32
80108c90:	55                   	push   %ebp
80108c91:	89 e5                	mov    %esp,%ebp
80108c93:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108c96:	8b 15 ac 8d 19 80    	mov    0x80198dac,%edx
80108c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9f:	0f af c2             	imul   %edx,%eax
80108ca2:	c1 e0 02             	shl    $0x2,%eax
80108ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108ca8:	8b 15 a0 8d 19 80    	mov    0x80198da0,%edx
80108cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb1:	29 c2                	sub    %eax,%edx
80108cb3:	89 d0                	mov    %edx,%eax
80108cb5:	8b 0d 9c 8d 19 80    	mov    0x80198d9c,%ecx
80108cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cbe:	01 ca                	add    %ecx,%edx
80108cc0:	89 d1                	mov    %edx,%ecx
80108cc2:	8b 15 9c 8d 19 80    	mov    0x80198d9c,%edx
80108cc8:	83 ec 04             	sub    $0x4,%esp
80108ccb:	50                   	push   %eax
80108ccc:	51                   	push   %ecx
80108ccd:	52                   	push   %edx
80108cce:	e8 84 c9 ff ff       	call   80105657 <memmove>
80108cd3:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd9:	8b 0d 9c 8d 19 80    	mov    0x80198d9c,%ecx
80108cdf:	8b 15 a0 8d 19 80    	mov    0x80198da0,%edx
80108ce5:	01 d1                	add    %edx,%ecx
80108ce7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cea:	29 d1                	sub    %edx,%ecx
80108cec:	89 ca                	mov    %ecx,%edx
80108cee:	83 ec 04             	sub    $0x4,%esp
80108cf1:	50                   	push   %eax
80108cf2:	6a 00                	push   $0x0
80108cf4:	52                   	push   %edx
80108cf5:	e8 96 c8 ff ff       	call   80105590 <memset>
80108cfa:	83 c4 10             	add    $0x10,%esp
}
80108cfd:	90                   	nop
80108cfe:	c9                   	leave
80108cff:	c3                   	ret

80108d00 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108d00:	f3 0f 1e fb          	endbr32
80108d04:	55                   	push   %ebp
80108d05:	89 e5                	mov    %esp,%ebp
80108d07:	53                   	push   %ebx
80108d08:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108d0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d12:	e9 b1 00 00 00       	jmp    80108dc8 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108d17:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108d1e:	e9 97 00 00 00       	jmp    80108dba <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108d23:	8b 45 10             	mov    0x10(%ebp),%eax
80108d26:	83 e8 20             	sub    $0x20,%eax
80108d29:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2f:	01 d0                	add    %edx,%eax
80108d31:	0f b7 84 00 a0 b6 10 	movzwl -0x7fef4960(%eax,%eax,1),%eax
80108d38:	80 
80108d39:	0f b7 d0             	movzwl %ax,%edx
80108d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d3f:	bb 01 00 00 00       	mov    $0x1,%ebx
80108d44:	89 c1                	mov    %eax,%ecx
80108d46:	d3 e3                	shl    %cl,%ebx
80108d48:	89 d8                	mov    %ebx,%eax
80108d4a:	21 d0                	and    %edx,%eax
80108d4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d52:	ba 01 00 00 00       	mov    $0x1,%edx
80108d57:	89 c1                	mov    %eax,%ecx
80108d59:	d3 e2                	shl    %cl,%edx
80108d5b:	89 d0                	mov    %edx,%eax
80108d5d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108d60:	75 2b                	jne    80108d8d <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108d62:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d68:	01 c2                	add    %eax,%edx
80108d6a:	b8 0e 00 00 00       	mov    $0xe,%eax
80108d6f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108d72:	89 c1                	mov    %eax,%ecx
80108d74:	8b 45 08             	mov    0x8(%ebp),%eax
80108d77:	01 c8                	add    %ecx,%eax
80108d79:	83 ec 04             	sub    $0x4,%esp
80108d7c:	68 00 f5 10 80       	push   $0x8010f500
80108d81:	52                   	push   %edx
80108d82:	50                   	push   %eax
80108d83:	e8 ad fe ff ff       	call   80108c35 <graphic_draw_pixel>
80108d88:	83 c4 10             	add    $0x10,%esp
80108d8b:	eb 29                	jmp    80108db6 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d93:	01 c2                	add    %eax,%edx
80108d95:	b8 0e 00 00 00       	mov    $0xe,%eax
80108d9a:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108d9d:	89 c1                	mov    %eax,%ecx
80108d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108da2:	01 c8                	add    %ecx,%eax
80108da4:	83 ec 04             	sub    $0x4,%esp
80108da7:	68 84 d0 18 80       	push   $0x8018d084
80108dac:	52                   	push   %edx
80108dad:	50                   	push   %eax
80108dae:	e8 82 fe ff ff       	call   80108c35 <graphic_draw_pixel>
80108db3:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108db6:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108dba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dbe:	0f 89 5f ff ff ff    	jns    80108d23 <font_render+0x23>
  for(int i=0;i<30;i++){
80108dc4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dc8:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108dcc:	0f 8e 45 ff ff ff    	jle    80108d17 <font_render+0x17>
      }
    }
  }
}
80108dd2:	90                   	nop
80108dd3:	90                   	nop
80108dd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108dd7:	c9                   	leave
80108dd8:	c3                   	ret

80108dd9 <font_render_string>:

void font_render_string(char *string,int row){
80108dd9:	f3 0f 1e fb          	endbr32
80108ddd:	55                   	push   %ebp
80108dde:	89 e5                	mov    %esp,%ebp
80108de0:	53                   	push   %ebx
80108de1:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108deb:	eb 33                	jmp    80108e20 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108df0:	8b 45 08             	mov    0x8(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	0f b6 00             	movzbl (%eax),%eax
80108df8:	0f be d8             	movsbl %al,%ebx
80108dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dfe:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e04:	89 d0                	mov    %edx,%eax
80108e06:	c1 e0 04             	shl    $0x4,%eax
80108e09:	29 d0                	sub    %edx,%eax
80108e0b:	83 c0 02             	add    $0x2,%eax
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	53                   	push   %ebx
80108e12:	51                   	push   %ecx
80108e13:	50                   	push   %eax
80108e14:	e8 e7 fe ff ff       	call   80108d00 <font_render>
80108e19:	83 c4 10             	add    $0x10,%esp
    i++;
80108e1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e23:	8b 45 08             	mov    0x8(%ebp),%eax
80108e26:	01 d0                	add    %edx,%eax
80108e28:	0f b6 00             	movzbl (%eax),%eax
80108e2b:	84 c0                	test   %al,%al
80108e2d:	74 06                	je     80108e35 <font_render_string+0x5c>
80108e2f:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108e33:	7e b8                	jle    80108ded <font_render_string+0x14>
  }
}
80108e35:	90                   	nop
80108e36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e39:	c9                   	leave
80108e3a:	c3                   	ret

80108e3b <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108e3b:	f3 0f 1e fb          	endbr32
80108e3f:	55                   	push   %ebp
80108e40:	89 e5                	mov    %esp,%ebp
80108e42:	53                   	push   %ebx
80108e43:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108e46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e4d:	eb 6b                	jmp    80108eba <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108e4f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e56:	eb 58                	jmp    80108eb0 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108e58:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108e5f:	eb 45                	jmp    80108ea6 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108e61:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108e64:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6a:	83 ec 0c             	sub    $0xc,%esp
80108e6d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108e70:	53                   	push   %ebx
80108e71:	6a 00                	push   $0x0
80108e73:	51                   	push   %ecx
80108e74:	52                   	push   %edx
80108e75:	50                   	push   %eax
80108e76:	e8 c0 00 00 00       	call   80108f3b <pci_access_config>
80108e7b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108e7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e81:	0f b7 c0             	movzwl %ax,%eax
80108e84:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108e89:	74 17                	je     80108ea2 <pci_init+0x67>
        pci_init_device(i,j,k);
80108e8b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108e8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e94:	83 ec 04             	sub    $0x4,%esp
80108e97:	51                   	push   %ecx
80108e98:	52                   	push   %edx
80108e99:	50                   	push   %eax
80108e9a:	e8 4f 01 00 00       	call   80108fee <pci_init_device>
80108e9f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108ea2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108ea6:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108eaa:	7e b5                	jle    80108e61 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108eac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108eb0:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108eb4:	7e a2                	jle    80108e58 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108eb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108eba:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ec1:	7e 8c                	jle    80108e4f <pci_init+0x14>
      }
      }
    }
  }
}
80108ec3:	90                   	nop
80108ec4:	90                   	nop
80108ec5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ec8:	c9                   	leave
80108ec9:	c3                   	ret

80108eca <pci_write_config>:

void pci_write_config(uint config){
80108eca:	f3 0f 1e fb          	endbr32
80108ece:	55                   	push   %ebp
80108ecf:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed4:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108ed9:	89 c0                	mov    %eax,%eax
80108edb:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108edc:	90                   	nop
80108edd:	5d                   	pop    %ebp
80108ede:	c3                   	ret

80108edf <pci_write_data>:

void pci_write_data(uint config){
80108edf:	f3 0f 1e fb          	endbr32
80108ee3:	55                   	push   %ebp
80108ee4:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee9:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108eee:	89 c0                	mov    %eax,%eax
80108ef0:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108ef1:	90                   	nop
80108ef2:	5d                   	pop    %ebp
80108ef3:	c3                   	ret

80108ef4 <pci_read_config>:
uint pci_read_config(){
80108ef4:	f3 0f 1e fb          	endbr32
80108ef8:	55                   	push   %ebp
80108ef9:	89 e5                	mov    %esp,%ebp
80108efb:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108efe:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108f03:	ed                   	in     (%dx),%eax
80108f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108f07:	83 ec 0c             	sub    $0xc,%esp
80108f0a:	68 c8 00 00 00       	push   $0xc8
80108f0f:	e8 30 9d ff ff       	call   80102c44 <microdelay>
80108f14:	83 c4 10             	add    $0x10,%esp
  return data;
80108f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108f1a:	c9                   	leave
80108f1b:	c3                   	ret

80108f1c <pci_test>:


void pci_test(){
80108f1c:	f3 0f 1e fb          	endbr32
80108f20:	55                   	push   %ebp
80108f21:	89 e5                	mov    %esp,%ebp
80108f23:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108f26:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108f2d:	ff 75 fc             	push   -0x4(%ebp)
80108f30:	e8 95 ff ff ff       	call   80108eca <pci_write_config>
80108f35:	83 c4 04             	add    $0x4,%esp
}
80108f38:	90                   	nop
80108f39:	c9                   	leave
80108f3a:	c3                   	ret

80108f3b <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108f3b:	f3 0f 1e fb          	endbr32
80108f3f:	55                   	push   %ebp
80108f40:	89 e5                	mov    %esp,%ebp
80108f42:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108f45:	8b 45 08             	mov    0x8(%ebp),%eax
80108f48:	c1 e0 10             	shl    $0x10,%eax
80108f4b:	25 00 00 ff 00       	and    $0xff0000,%eax
80108f50:	89 c2                	mov    %eax,%edx
80108f52:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f55:	c1 e0 0b             	shl    $0xb,%eax
80108f58:	0f b7 c0             	movzwl %ax,%eax
80108f5b:	09 c2                	or     %eax,%edx
80108f5d:	8b 45 10             	mov    0x10(%ebp),%eax
80108f60:	c1 e0 08             	shl    $0x8,%eax
80108f63:	25 00 07 00 00       	and    $0x700,%eax
80108f68:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80108f6d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108f72:	09 d0                	or     %edx,%eax
80108f74:	0d 00 00 00 80       	or     $0x80000000,%eax
80108f79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108f7c:	ff 75 f4             	push   -0xc(%ebp)
80108f7f:	e8 46 ff ff ff       	call   80108eca <pci_write_config>
80108f84:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108f87:	e8 68 ff ff ff       	call   80108ef4 <pci_read_config>
80108f8c:	8b 55 18             	mov    0x18(%ebp),%edx
80108f8f:	89 02                	mov    %eax,(%edx)
}
80108f91:	90                   	nop
80108f92:	c9                   	leave
80108f93:	c3                   	ret

80108f94 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108f94:	f3 0f 1e fb          	endbr32
80108f98:	55                   	push   %ebp
80108f99:	89 e5                	mov    %esp,%ebp
80108f9b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa1:	c1 e0 10             	shl    $0x10,%eax
80108fa4:	25 00 00 ff 00       	and    $0xff0000,%eax
80108fa9:	89 c2                	mov    %eax,%edx
80108fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fae:	c1 e0 0b             	shl    $0xb,%eax
80108fb1:	0f b7 c0             	movzwl %ax,%eax
80108fb4:	09 c2                	or     %eax,%edx
80108fb6:	8b 45 10             	mov    0x10(%ebp),%eax
80108fb9:	c1 e0 08             	shl    $0x8,%eax
80108fbc:	25 00 07 00 00       	and    $0x700,%eax
80108fc1:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108fc3:	8b 45 14             	mov    0x14(%ebp),%eax
80108fc6:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108fcb:	09 d0                	or     %edx,%eax
80108fcd:	0d 00 00 00 80       	or     $0x80000000,%eax
80108fd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108fd5:	ff 75 fc             	push   -0x4(%ebp)
80108fd8:	e8 ed fe ff ff       	call   80108eca <pci_write_config>
80108fdd:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108fe0:	ff 75 18             	push   0x18(%ebp)
80108fe3:	e8 f7 fe ff ff       	call   80108edf <pci_write_data>
80108fe8:	83 c4 04             	add    $0x4,%esp
}
80108feb:	90                   	nop
80108fec:	c9                   	leave
80108fed:	c3                   	ret

80108fee <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108fee:	f3 0f 1e fb          	endbr32
80108ff2:	55                   	push   %ebp
80108ff3:	89 e5                	mov    %esp,%ebp
80108ff5:	53                   	push   %ebx
80108ff6:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80108ffc:	a2 b0 8d 19 80       	mov    %al,0x80198db0
  dev.device_num = device_num;
80109001:	8b 45 0c             	mov    0xc(%ebp),%eax
80109004:	a2 b1 8d 19 80       	mov    %al,0x80198db1
  dev.function_num = function_num;
80109009:	8b 45 10             	mov    0x10(%ebp),%eax
8010900c:	a2 b2 8d 19 80       	mov    %al,0x80198db2
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80109011:	ff 75 10             	push   0x10(%ebp)
80109014:	ff 75 0c             	push   0xc(%ebp)
80109017:	ff 75 08             	push   0x8(%ebp)
8010901a:	68 e4 cc 10 80       	push   $0x8010cce4
8010901f:	e8 e8 73 ff ff       	call   8010040c <cprintf>
80109024:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80109027:	83 ec 0c             	sub    $0xc,%esp
8010902a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010902d:	50                   	push   %eax
8010902e:	6a 00                	push   $0x0
80109030:	ff 75 10             	push   0x10(%ebp)
80109033:	ff 75 0c             	push   0xc(%ebp)
80109036:	ff 75 08             	push   0x8(%ebp)
80109039:	e8 fd fe ff ff       	call   80108f3b <pci_access_config>
8010903e:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80109041:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109044:	c1 e8 10             	shr    $0x10,%eax
80109047:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010904a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904d:	25 ff ff 00 00       	and    $0xffff,%eax
80109052:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80109055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109058:	a3 b4 8d 19 80       	mov    %eax,0x80198db4
  dev.vendor_id = vendor_id;
8010905d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109060:	a3 b8 8d 19 80       	mov    %eax,0x80198db8
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80109065:	83 ec 04             	sub    $0x4,%esp
80109068:	ff 75 f0             	push   -0x10(%ebp)
8010906b:	ff 75 f4             	push   -0xc(%ebp)
8010906e:	68 18 cd 10 80       	push   $0x8010cd18
80109073:	e8 94 73 ff ff       	call   8010040c <cprintf>
80109078:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010907b:	83 ec 0c             	sub    $0xc,%esp
8010907e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109081:	50                   	push   %eax
80109082:	6a 08                	push   $0x8
80109084:	ff 75 10             	push   0x10(%ebp)
80109087:	ff 75 0c             	push   0xc(%ebp)
8010908a:	ff 75 08             	push   0x8(%ebp)
8010908d:	e8 a9 fe ff ff       	call   80108f3b <pci_access_config>
80109092:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109098:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010909b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010909e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801090a1:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801090a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a7:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801090aa:	0f b6 c0             	movzbl %al,%eax
801090ad:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801090b0:	c1 eb 18             	shr    $0x18,%ebx
801090b3:	83 ec 0c             	sub    $0xc,%esp
801090b6:	51                   	push   %ecx
801090b7:	52                   	push   %edx
801090b8:	50                   	push   %eax
801090b9:	53                   	push   %ebx
801090ba:	68 3c cd 10 80       	push   $0x8010cd3c
801090bf:	e8 48 73 ff ff       	call   8010040c <cprintf>
801090c4:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801090c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ca:	c1 e8 18             	shr    $0x18,%eax
801090cd:	a2 bc 8d 19 80       	mov    %al,0x80198dbc
  dev.sub_class = (data>>16)&0xFF;
801090d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090d5:	c1 e8 10             	shr    $0x10,%eax
801090d8:	a2 bd 8d 19 80       	mov    %al,0x80198dbd
  dev.interface = (data>>8)&0xFF;
801090dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090e0:	c1 e8 08             	shr    $0x8,%eax
801090e3:	a2 be 8d 19 80       	mov    %al,0x80198dbe
  dev.revision_id = data&0xFF;
801090e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090eb:	a2 bf 8d 19 80       	mov    %al,0x80198dbf
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801090f0:	83 ec 0c             	sub    $0xc,%esp
801090f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090f6:	50                   	push   %eax
801090f7:	6a 10                	push   $0x10
801090f9:	ff 75 10             	push   0x10(%ebp)
801090fc:	ff 75 0c             	push   0xc(%ebp)
801090ff:	ff 75 08             	push   0x8(%ebp)
80109102:	e8 34 fe ff ff       	call   80108f3b <pci_access_config>
80109107:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010910a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010910d:	a3 c0 8d 19 80       	mov    %eax,0x80198dc0
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80109112:	83 ec 0c             	sub    $0xc,%esp
80109115:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109118:	50                   	push   %eax
80109119:	6a 14                	push   $0x14
8010911b:	ff 75 10             	push   0x10(%ebp)
8010911e:	ff 75 0c             	push   0xc(%ebp)
80109121:	ff 75 08             	push   0x8(%ebp)
80109124:	e8 12 fe ff ff       	call   80108f3b <pci_access_config>
80109129:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010912c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010912f:	a3 c4 8d 19 80       	mov    %eax,0x80198dc4
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80109134:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010913b:	75 5a                	jne    80109197 <pci_init_device+0x1a9>
8010913d:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80109144:	75 51                	jne    80109197 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80109146:	83 ec 0c             	sub    $0xc,%esp
80109149:	68 81 cd 10 80       	push   $0x8010cd81
8010914e:	e8 b9 72 ff ff       	call   8010040c <cprintf>
80109153:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80109156:	83 ec 0c             	sub    $0xc,%esp
80109159:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010915c:	50                   	push   %eax
8010915d:	68 f0 00 00 00       	push   $0xf0
80109162:	ff 75 10             	push   0x10(%ebp)
80109165:	ff 75 0c             	push   0xc(%ebp)
80109168:	ff 75 08             	push   0x8(%ebp)
8010916b:	e8 cb fd ff ff       	call   80108f3b <pci_access_config>
80109170:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80109173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109176:	83 ec 08             	sub    $0x8,%esp
80109179:	50                   	push   %eax
8010917a:	68 9b cd 10 80       	push   $0x8010cd9b
8010917f:	e8 88 72 ff ff       	call   8010040c <cprintf>
80109184:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80109187:	83 ec 0c             	sub    $0xc,%esp
8010918a:	68 b0 8d 19 80       	push   $0x80198db0
8010918f:	e8 09 00 00 00       	call   8010919d <i8254_init>
80109194:	83 c4 10             	add    $0x10,%esp
  }
}
80109197:	90                   	nop
80109198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010919b:	c9                   	leave
8010919c:	c3                   	ret

8010919d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010919d:	f3 0f 1e fb          	endbr32
801091a1:	55                   	push   %ebp
801091a2:	89 e5                	mov    %esp,%ebp
801091a4:	53                   	push   %ebx
801091a5:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801091a8:	8b 45 08             	mov    0x8(%ebp),%eax
801091ab:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801091af:	0f b6 c8             	movzbl %al,%ecx
801091b2:	8b 45 08             	mov    0x8(%ebp),%eax
801091b5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801091b9:	0f b6 d0             	movzbl %al,%edx
801091bc:	8b 45 08             	mov    0x8(%ebp),%eax
801091bf:	0f b6 00             	movzbl (%eax),%eax
801091c2:	0f b6 c0             	movzbl %al,%eax
801091c5:	83 ec 0c             	sub    $0xc,%esp
801091c8:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801091cb:	53                   	push   %ebx
801091cc:	6a 04                	push   $0x4
801091ce:	51                   	push   %ecx
801091cf:	52                   	push   %edx
801091d0:	50                   	push   %eax
801091d1:	e8 65 fd ff ff       	call   80108f3b <pci_access_config>
801091d6:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801091d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091dc:	83 c8 04             	or     $0x4,%eax
801091df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801091e2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801091e5:	8b 45 08             	mov    0x8(%ebp),%eax
801091e8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801091ec:	0f b6 c8             	movzbl %al,%ecx
801091ef:	8b 45 08             	mov    0x8(%ebp),%eax
801091f2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801091f6:	0f b6 d0             	movzbl %al,%edx
801091f9:	8b 45 08             	mov    0x8(%ebp),%eax
801091fc:	0f b6 00             	movzbl (%eax),%eax
801091ff:	0f b6 c0             	movzbl %al,%eax
80109202:	83 ec 0c             	sub    $0xc,%esp
80109205:	53                   	push   %ebx
80109206:	6a 04                	push   $0x4
80109208:	51                   	push   %ecx
80109209:	52                   	push   %edx
8010920a:	50                   	push   %eax
8010920b:	e8 84 fd ff ff       	call   80108f94 <pci_write_config_register>
80109210:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80109213:	8b 45 08             	mov    0x8(%ebp),%eax
80109216:	8b 40 10             	mov    0x10(%eax),%eax
80109219:	05 00 00 00 40       	add    $0x40000000,%eax
8010921e:	a3 c8 8d 19 80       	mov    %eax,0x80198dc8
  uint *ctrl = (uint *)base_addr;
80109223:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010922b:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109230:	05 d8 00 00 00       	add    $0xd8,%eax
80109235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80109238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923b:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80109241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109244:	8b 00                	mov    (%eax),%eax
80109246:	0d 00 00 00 04       	or     $0x4000000,%eax
8010924b:	89 c2                	mov    %eax,%edx
8010924d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109250:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80109252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109255:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010925b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925e:	8b 00                	mov    (%eax),%eax
80109260:	83 c8 40             	or     $0x40,%eax
80109263:	89 c2                	mov    %eax,%edx
80109265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109268:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010926a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010926d:	8b 10                	mov    (%eax),%edx
8010926f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109272:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80109274:	83 ec 0c             	sub    $0xc,%esp
80109277:	68 b0 cd 10 80       	push   $0x8010cdb0
8010927c:	e8 8b 71 ff ff       	call   8010040c <cprintf>
80109281:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80109284:	e8 09 96 ff ff       	call   80102892 <kalloc>
80109289:	a3 cc 8d 19 80       	mov    %eax,0x80198dcc
  *intr_addr = 0;
8010928e:	a1 cc 8d 19 80       	mov    0x80198dcc,%eax
80109293:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109299:	a1 cc 8d 19 80       	mov    0x80198dcc,%eax
8010929e:	83 ec 08             	sub    $0x8,%esp
801092a1:	50                   	push   %eax
801092a2:	68 d2 cd 10 80       	push   $0x8010cdd2
801092a7:	e8 60 71 ff ff       	call   8010040c <cprintf>
801092ac:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801092af:	e8 50 00 00 00       	call   80109304 <i8254_init_recv>
  i8254_init_send();
801092b4:	e8 6d 03 00 00       	call   80109626 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801092b9:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801092c0:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801092c3:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801092ca:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801092cd:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801092d4:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801092d7:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801092de:	0f b6 c0             	movzbl %al,%eax
801092e1:	83 ec 0c             	sub    $0xc,%esp
801092e4:	53                   	push   %ebx
801092e5:	51                   	push   %ecx
801092e6:	52                   	push   %edx
801092e7:	50                   	push   %eax
801092e8:	68 e0 cd 10 80       	push   $0x8010cde0
801092ed:	e8 1a 71 ff ff       	call   8010040c <cprintf>
801092f2:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801092f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801092fe:	90                   	nop
801092ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109302:	c9                   	leave
80109303:	c3                   	ret

80109304 <i8254_init_recv>:

void i8254_init_recv(){
80109304:	f3 0f 1e fb          	endbr32
80109308:	55                   	push   %ebp
80109309:	89 e5                	mov    %esp,%ebp
8010930b:	57                   	push   %edi
8010930c:	56                   	push   %esi
8010930d:	53                   	push   %ebx
8010930e:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80109311:	83 ec 0c             	sub    $0xc,%esp
80109314:	6a 00                	push   $0x0
80109316:	e8 ec 04 00 00       	call   80109807 <i8254_read_eeprom>
8010931b:	83 c4 10             	add    $0x10,%esp
8010931e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80109321:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109324:	a2 88 d0 18 80       	mov    %al,0x8018d088
  mac_addr[1] = data_l>>8;
80109329:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010932c:	c1 e8 08             	shr    $0x8,%eax
8010932f:	a2 89 d0 18 80       	mov    %al,0x8018d089
  uint data_m = i8254_read_eeprom(0x1);
80109334:	83 ec 0c             	sub    $0xc,%esp
80109337:	6a 01                	push   $0x1
80109339:	e8 c9 04 00 00       	call   80109807 <i8254_read_eeprom>
8010933e:	83 c4 10             	add    $0x10,%esp
80109341:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80109344:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109347:	a2 8a d0 18 80       	mov    %al,0x8018d08a
  mac_addr[3] = data_m>>8;
8010934c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010934f:	c1 e8 08             	shr    $0x8,%eax
80109352:	a2 8b d0 18 80       	mov    %al,0x8018d08b
  uint data_h = i8254_read_eeprom(0x2);
80109357:	83 ec 0c             	sub    $0xc,%esp
8010935a:	6a 02                	push   $0x2
8010935c:	e8 a6 04 00 00       	call   80109807 <i8254_read_eeprom>
80109361:	83 c4 10             	add    $0x10,%esp
80109364:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80109367:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010936a:	a2 8c d0 18 80       	mov    %al,0x8018d08c
  mac_addr[5] = data_h>>8;
8010936f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109372:	c1 e8 08             	shr    $0x8,%eax
80109375:	a2 8d d0 18 80       	mov    %al,0x8018d08d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010937a:	0f b6 05 8d d0 18 80 	movzbl 0x8018d08d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109381:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80109384:	0f b6 05 8c d0 18 80 	movzbl 0x8018d08c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010938b:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010938e:	0f b6 05 8b d0 18 80 	movzbl 0x8018d08b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109395:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109398:	0f b6 05 8a d0 18 80 	movzbl 0x8018d08a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010939f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801093a2:	0f b6 05 89 d0 18 80 	movzbl 0x8018d089,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801093a9:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801093ac:	0f b6 05 88 d0 18 80 	movzbl 0x8018d088,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801093b3:	0f b6 c0             	movzbl %al,%eax
801093b6:	83 ec 04             	sub    $0x4,%esp
801093b9:	57                   	push   %edi
801093ba:	56                   	push   %esi
801093bb:	53                   	push   %ebx
801093bc:	51                   	push   %ecx
801093bd:	52                   	push   %edx
801093be:	50                   	push   %eax
801093bf:	68 f8 cd 10 80       	push   $0x8010cdf8
801093c4:	e8 43 70 ff ff       	call   8010040c <cprintf>
801093c9:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801093cc:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801093d1:	05 00 54 00 00       	add    $0x5400,%eax
801093d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801093d9:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801093de:	05 04 54 00 00       	add    $0x5404,%eax
801093e3:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801093e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093e9:	c1 e0 10             	shl    $0x10,%eax
801093ec:	0b 45 d8             	or     -0x28(%ebp),%eax
801093ef:	89 c2                	mov    %eax,%edx
801093f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801093f4:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801093f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093f9:	0d 00 00 00 80       	or     $0x80000000,%eax
801093fe:	89 c2                	mov    %eax,%edx
80109400:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109403:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80109405:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010940a:	05 00 52 00 00       	add    $0x5200,%eax
8010940f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80109412:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80109419:	eb 19                	jmp    80109434 <i8254_init_recv+0x130>
    mta[i] = 0;
8010941b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010941e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109425:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109428:	01 d0                	add    %edx,%eax
8010942a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80109430:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80109434:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80109438:	7e e1                	jle    8010941b <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010943a:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010943f:	05 d0 00 00 00       	add    $0xd0,%eax
80109444:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109447:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010944a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80109450:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109455:	05 c8 00 00 00       	add    $0xc8,%eax
8010945a:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010945d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109460:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109466:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010946b:	05 28 28 00 00       	add    $0x2828,%eax
80109470:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109473:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109476:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010947c:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109481:	05 00 01 00 00       	add    $0x100,%eax
80109486:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109489:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010948c:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109492:	e8 fb 93 ff ff       	call   80102892 <kalloc>
80109497:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010949a:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010949f:	05 00 28 00 00       	add    $0x2800,%eax
801094a4:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801094a7:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801094ac:	05 04 28 00 00       	add    $0x2804,%eax
801094b1:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801094b4:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801094b9:	05 08 28 00 00       	add    $0x2808,%eax
801094be:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801094c1:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801094c6:	05 10 28 00 00       	add    $0x2810,%eax
801094cb:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801094ce:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801094d3:	05 18 28 00 00       	add    $0x2818,%eax
801094d8:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801094db:	8b 45 b0             	mov    -0x50(%ebp),%eax
801094de:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801094e4:	8b 45 ac             	mov    -0x54(%ebp),%eax
801094e7:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801094e9:	8b 45 a8             	mov    -0x58(%ebp),%eax
801094ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801094f2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801094f5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801094fb:	8b 45 a0             	mov    -0x60(%ebp),%eax
801094fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80109504:	8b 45 9c             	mov    -0x64(%ebp),%eax
80109507:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010950d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109510:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109513:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010951a:	eb 73                	jmp    8010958f <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
8010951c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010951f:	c1 e0 04             	shl    $0x4,%eax
80109522:	89 c2                	mov    %eax,%edx
80109524:	8b 45 98             	mov    -0x68(%ebp),%eax
80109527:	01 d0                	add    %edx,%eax
80109529:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109530:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109533:	c1 e0 04             	shl    $0x4,%eax
80109536:	89 c2                	mov    %eax,%edx
80109538:	8b 45 98             	mov    -0x68(%ebp),%eax
8010953b:	01 d0                	add    %edx,%eax
8010953d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109543:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109546:	c1 e0 04             	shl    $0x4,%eax
80109549:	89 c2                	mov    %eax,%edx
8010954b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010954e:	01 d0                	add    %edx,%eax
80109550:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109556:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109559:	c1 e0 04             	shl    $0x4,%eax
8010955c:	89 c2                	mov    %eax,%edx
8010955e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109561:	01 d0                	add    %edx,%eax
80109563:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109567:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010956a:	c1 e0 04             	shl    $0x4,%eax
8010956d:	89 c2                	mov    %eax,%edx
8010956f:	8b 45 98             	mov    -0x68(%ebp),%eax
80109572:	01 d0                	add    %edx,%eax
80109574:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109578:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010957b:	c1 e0 04             	shl    $0x4,%eax
8010957e:	89 c2                	mov    %eax,%edx
80109580:	8b 45 98             	mov    -0x68(%ebp),%eax
80109583:	01 d0                	add    %edx,%eax
80109585:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010958b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010958f:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109596:	7e 84                	jle    8010951c <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109598:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010959f:	eb 57                	jmp    801095f8 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
801095a1:	e8 ec 92 ff ff       	call   80102892 <kalloc>
801095a6:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801095a9:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801095ad:	75 12                	jne    801095c1 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
801095af:	83 ec 0c             	sub    $0xc,%esp
801095b2:	68 18 ce 10 80       	push   $0x8010ce18
801095b7:	e8 50 6e ff ff       	call   8010040c <cprintf>
801095bc:	83 c4 10             	add    $0x10,%esp
      break;
801095bf:	eb 3d                	jmp    801095fe <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801095c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801095c4:	c1 e0 04             	shl    $0x4,%eax
801095c7:	89 c2                	mov    %eax,%edx
801095c9:	8b 45 98             	mov    -0x68(%ebp),%eax
801095cc:	01 d0                	add    %edx,%eax
801095ce:	8b 55 94             	mov    -0x6c(%ebp),%edx
801095d1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801095d7:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801095d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801095dc:	83 c0 01             	add    $0x1,%eax
801095df:	c1 e0 04             	shl    $0x4,%eax
801095e2:	89 c2                	mov    %eax,%edx
801095e4:	8b 45 98             	mov    -0x68(%ebp),%eax
801095e7:	01 d0                	add    %edx,%eax
801095e9:	8b 55 94             	mov    -0x6c(%ebp),%edx
801095ec:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801095f2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801095f4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801095f8:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801095fc:	7e a3                	jle    801095a1 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
801095fe:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109601:	8b 00                	mov    (%eax),%eax
80109603:	83 c8 02             	or     $0x2,%eax
80109606:	89 c2                	mov    %eax,%edx
80109608:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010960b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010960d:	83 ec 0c             	sub    $0xc,%esp
80109610:	68 38 ce 10 80       	push   $0x8010ce38
80109615:	e8 f2 6d ff ff       	call   8010040c <cprintf>
8010961a:	83 c4 10             	add    $0x10,%esp
}
8010961d:	90                   	nop
8010961e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109621:	5b                   	pop    %ebx
80109622:	5e                   	pop    %esi
80109623:	5f                   	pop    %edi
80109624:	5d                   	pop    %ebp
80109625:	c3                   	ret

80109626 <i8254_init_send>:

void i8254_init_send(){
80109626:	f3 0f 1e fb          	endbr32
8010962a:	55                   	push   %ebp
8010962b:	89 e5                	mov    %esp,%ebp
8010962d:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109630:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109635:	05 28 38 00 00       	add    $0x3828,%eax
8010963a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010963d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109640:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109646:	e8 47 92 ff ff       	call   80102892 <kalloc>
8010964b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010964e:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109653:	05 00 38 00 00       	add    $0x3800,%eax
80109658:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010965b:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109660:	05 04 38 00 00       	add    $0x3804,%eax
80109665:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109668:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010966d:	05 08 38 00 00       	add    $0x3808,%eax
80109672:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109675:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109678:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010967e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109681:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109683:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109686:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010968c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010968f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109695:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010969a:	05 10 38 00 00       	add    $0x3810,%eax
8010969f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801096a2:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801096a7:	05 18 38 00 00       	add    $0x3818,%eax
801096ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801096af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801096b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801096b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801096bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801096c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801096c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801096ce:	e9 82 00 00 00       	jmp    80109755 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801096d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d6:	c1 e0 04             	shl    $0x4,%eax
801096d9:	89 c2                	mov    %eax,%edx
801096db:	8b 45 d0             	mov    -0x30(%ebp),%eax
801096de:	01 d0                	add    %edx,%eax
801096e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	c1 e0 04             	shl    $0x4,%eax
801096ed:	89 c2                	mov    %eax,%edx
801096ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
801096f2:	01 d0                	add    %edx,%eax
801096f4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801096fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fd:	c1 e0 04             	shl    $0x4,%eax
80109700:	89 c2                	mov    %eax,%edx
80109702:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109705:	01 d0                	add    %edx,%eax
80109707:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010970b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010970e:	c1 e0 04             	shl    $0x4,%eax
80109711:	89 c2                	mov    %eax,%edx
80109713:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109716:	01 d0                	add    %edx,%eax
80109718:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010971c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010971f:	c1 e0 04             	shl    $0x4,%eax
80109722:	89 c2                	mov    %eax,%edx
80109724:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109727:	01 d0                	add    %edx,%eax
80109729:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010972d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109730:	c1 e0 04             	shl    $0x4,%eax
80109733:	89 c2                	mov    %eax,%edx
80109735:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109738:	01 d0                	add    %edx,%eax
8010973a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010973e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109741:	c1 e0 04             	shl    $0x4,%eax
80109744:	89 c2                	mov    %eax,%edx
80109746:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109749:	01 d0                	add    %edx,%eax
8010974b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109751:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109755:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010975c:	0f 8e 71 ff ff ff    	jle    801096d3 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109762:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109769:	eb 57                	jmp    801097c2 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
8010976b:	e8 22 91 ff ff       	call   80102892 <kalloc>
80109770:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109773:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109777:	75 12                	jne    8010978b <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109779:	83 ec 0c             	sub    $0xc,%esp
8010977c:	68 18 ce 10 80       	push   $0x8010ce18
80109781:	e8 86 6c ff ff       	call   8010040c <cprintf>
80109786:	83 c4 10             	add    $0x10,%esp
      break;
80109789:	eb 3d                	jmp    801097c8 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010978b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978e:	c1 e0 04             	shl    $0x4,%eax
80109791:	89 c2                	mov    %eax,%edx
80109793:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109796:	01 d0                	add    %edx,%eax
80109798:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010979b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801097a1:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801097a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a6:	83 c0 01             	add    $0x1,%eax
801097a9:	c1 e0 04             	shl    $0x4,%eax
801097ac:	89 c2                	mov    %eax,%edx
801097ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
801097b1:	01 d0                	add    %edx,%eax
801097b3:	8b 55 cc             	mov    -0x34(%ebp),%edx
801097b6:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801097bc:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801097be:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801097c2:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801097c6:	7e a3                	jle    8010976b <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801097c8:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801097cd:	05 00 04 00 00       	add    $0x400,%eax
801097d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801097d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801097d8:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801097de:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
801097e3:	05 10 04 00 00       	add    $0x410,%eax
801097e8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801097eb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801097ee:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801097f4:	83 ec 0c             	sub    $0xc,%esp
801097f7:	68 58 ce 10 80       	push   $0x8010ce58
801097fc:	e8 0b 6c ff ff       	call   8010040c <cprintf>
80109801:	83 c4 10             	add    $0x10,%esp

}
80109804:	90                   	nop
80109805:	c9                   	leave
80109806:	c3                   	ret

80109807 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109807:	f3 0f 1e fb          	endbr32
8010980b:	55                   	push   %ebp
8010980c:	89 e5                	mov    %esp,%ebp
8010980e:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109811:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109816:	83 c0 14             	add    $0x14,%eax
80109819:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010981c:	8b 45 08             	mov    0x8(%ebp),%eax
8010981f:	c1 e0 08             	shl    $0x8,%eax
80109822:	0f b7 c0             	movzwl %ax,%eax
80109825:	83 c8 01             	or     $0x1,%eax
80109828:	89 c2                	mov    %eax,%edx
8010982a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982d:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010982f:	83 ec 0c             	sub    $0xc,%esp
80109832:	68 78 ce 10 80       	push   $0x8010ce78
80109837:	e8 d0 6b ff ff       	call   8010040c <cprintf>
8010983c:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010983f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109842:	8b 00                	mov    (%eax),%eax
80109844:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984a:	83 e0 10             	and    $0x10,%eax
8010984d:	85 c0                	test   %eax,%eax
8010984f:	75 02                	jne    80109853 <i8254_read_eeprom+0x4c>
  while(1){
80109851:	eb dc                	jmp    8010982f <i8254_read_eeprom+0x28>
      break;
80109853:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109857:	8b 00                	mov    (%eax),%eax
80109859:	c1 e8 10             	shr    $0x10,%eax
}
8010985c:	c9                   	leave
8010985d:	c3                   	ret

8010985e <i8254_recv>:
void i8254_recv(){
8010985e:	f3 0f 1e fb          	endbr32
80109862:	55                   	push   %ebp
80109863:	89 e5                	mov    %esp,%ebp
80109865:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109868:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010986d:	05 10 28 00 00       	add    $0x2810,%eax
80109872:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109875:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010987a:	05 18 28 00 00       	add    $0x2818,%eax
8010987f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109882:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109887:	05 00 28 00 00       	add    $0x2800,%eax
8010988c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010988f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109892:	8b 00                	mov    (%eax),%eax
80109894:	05 00 00 00 80       	add    $0x80000000,%eax
80109899:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010989c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989f:	8b 10                	mov    (%eax),%edx
801098a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a4:	8b 00                	mov    (%eax),%eax
801098a6:	29 c2                	sub    %eax,%edx
801098a8:	89 d0                	mov    %edx,%eax
801098aa:	25 ff 00 00 00       	and    $0xff,%eax
801098af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801098b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801098b6:	7e 37                	jle    801098ef <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801098b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098bb:	8b 00                	mov    (%eax),%eax
801098bd:	c1 e0 04             	shl    $0x4,%eax
801098c0:	89 c2                	mov    %eax,%edx
801098c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098c5:	01 d0                	add    %edx,%eax
801098c7:	8b 00                	mov    (%eax),%eax
801098c9:	05 00 00 00 80       	add    $0x80000000,%eax
801098ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801098d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d4:	8b 00                	mov    (%eax),%eax
801098d6:	83 c0 01             	add    $0x1,%eax
801098d9:	0f b6 d0             	movzbl %al,%edx
801098dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098df:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801098e1:	83 ec 0c             	sub    $0xc,%esp
801098e4:	ff 75 e0             	push   -0x20(%ebp)
801098e7:	e8 47 09 00 00       	call   8010a233 <eth_proc>
801098ec:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801098ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f2:	8b 10                	mov    (%eax),%edx
801098f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f7:	8b 00                	mov    (%eax),%eax
801098f9:	39 c2                	cmp    %eax,%edx
801098fb:	75 9f                	jne    8010989c <i8254_recv+0x3e>
      (*rdt)--;
801098fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109900:	8b 00                	mov    (%eax),%eax
80109902:	8d 50 ff             	lea    -0x1(%eax),%edx
80109905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109908:	89 10                	mov    %edx,(%eax)
  while(1){
8010990a:	eb 90                	jmp    8010989c <i8254_recv+0x3e>

8010990c <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010990c:	f3 0f 1e fb          	endbr32
80109910:	55                   	push   %ebp
80109911:	89 e5                	mov    %esp,%ebp
80109913:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109916:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
8010991b:	05 10 38 00 00       	add    $0x3810,%eax
80109920:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109923:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109928:	05 18 38 00 00       	add    $0x3818,%eax
8010992d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109930:	a1 c8 8d 19 80       	mov    0x80198dc8,%eax
80109935:	05 00 38 00 00       	add    $0x3800,%eax
8010993a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010993d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109940:	8b 00                	mov    (%eax),%eax
80109942:	05 00 00 00 80       	add    $0x80000000,%eax
80109947:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010994a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994d:	8b 10                	mov    (%eax),%edx
8010994f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109952:	8b 00                	mov    (%eax),%eax
80109954:	29 c2                	sub    %eax,%edx
80109956:	89 d0                	mov    %edx,%eax
80109958:	0f b6 c0             	movzbl %al,%eax
8010995b:	ba 00 01 00 00       	mov    $0x100,%edx
80109960:	29 c2                	sub    %eax,%edx
80109962:	89 d0                	mov    %edx,%eax
80109964:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996a:	8b 00                	mov    (%eax),%eax
8010996c:	25 ff 00 00 00       	and    $0xff,%eax
80109971:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109974:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109978:	0f 8e a8 00 00 00    	jle    80109a26 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010997e:	8b 45 08             	mov    0x8(%ebp),%eax
80109981:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109984:	89 d1                	mov    %edx,%ecx
80109986:	c1 e1 04             	shl    $0x4,%ecx
80109989:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010998c:	01 ca                	add    %ecx,%edx
8010998e:	8b 12                	mov    (%edx),%edx
80109990:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109996:	83 ec 04             	sub    $0x4,%esp
80109999:	ff 75 0c             	push   0xc(%ebp)
8010999c:	50                   	push   %eax
8010999d:	52                   	push   %edx
8010999e:	e8 b4 bc ff ff       	call   80105657 <memmove>
801099a3:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801099a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099a9:	c1 e0 04             	shl    $0x4,%eax
801099ac:	89 c2                	mov    %eax,%edx
801099ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099b1:	01 d0                	add    %edx,%eax
801099b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801099b6:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801099ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099bd:	c1 e0 04             	shl    $0x4,%eax
801099c0:	89 c2                	mov    %eax,%edx
801099c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099c5:	01 d0                	add    %edx,%eax
801099c7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801099cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099ce:	c1 e0 04             	shl    $0x4,%eax
801099d1:	89 c2                	mov    %eax,%edx
801099d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099d6:	01 d0                	add    %edx,%eax
801099d8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801099dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099df:	c1 e0 04             	shl    $0x4,%eax
801099e2:	89 c2                	mov    %eax,%edx
801099e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099e7:	01 d0                	add    %edx,%eax
801099e9:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801099ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099f0:	c1 e0 04             	shl    $0x4,%eax
801099f3:	89 c2                	mov    %eax,%edx
801099f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099f8:	01 d0                	add    %edx,%eax
801099fa:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109a00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a03:	c1 e0 04             	shl    $0x4,%eax
80109a06:	89 c2                	mov    %eax,%edx
80109a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a0b:	01 d0                	add    %edx,%eax
80109a0d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a14:	8b 00                	mov    (%eax),%eax
80109a16:	83 c0 01             	add    $0x1,%eax
80109a19:	0f b6 d0             	movzbl %al,%edx
80109a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a1f:	89 10                	mov    %edx,(%eax)
    return len;
80109a21:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a24:	eb 05                	jmp    80109a2b <i8254_send+0x11f>
  }else{
    return -1;
80109a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109a2b:	c9                   	leave
80109a2c:	c3                   	ret

80109a2d <i8254_intr>:

void i8254_intr(){
80109a2d:	f3 0f 1e fb          	endbr32
80109a31:	55                   	push   %ebp
80109a32:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109a34:	a1 cc 8d 19 80       	mov    0x80198dcc,%eax
80109a39:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109a3f:	90                   	nop
80109a40:	5d                   	pop    %ebp
80109a41:	c3                   	ret

80109a42 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109a42:	f3 0f 1e fb          	endbr32
80109a46:	55                   	push   %ebp
80109a47:	89 e5                	mov    %esp,%ebp
80109a49:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a55:	0f b7 00             	movzwl (%eax),%eax
80109a58:	66 3d 00 01          	cmp    $0x100,%ax
80109a5c:	74 0a                	je     80109a68 <arp_proc+0x26>
80109a5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a63:	e9 4f 01 00 00       	jmp    80109bb7 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a6b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109a6f:	66 83 f8 08          	cmp    $0x8,%ax
80109a73:	74 0a                	je     80109a7f <arp_proc+0x3d>
80109a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a7a:	e9 38 01 00 00       	jmp    80109bb7 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a82:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109a86:	3c 06                	cmp    $0x6,%al
80109a88:	74 0a                	je     80109a94 <arp_proc+0x52>
80109a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a8f:	e9 23 01 00 00       	jmp    80109bb7 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a97:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109a9b:	3c 04                	cmp    $0x4,%al
80109a9d:	74 0a                	je     80109aa9 <arp_proc+0x67>
80109a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109aa4:	e9 0e 01 00 00       	jmp    80109bb7 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aac:	83 c0 18             	add    $0x18,%eax
80109aaf:	83 ec 04             	sub    $0x4,%esp
80109ab2:	6a 04                	push   $0x4
80109ab4:	50                   	push   %eax
80109ab5:	68 04 f5 10 80       	push   $0x8010f504
80109aba:	e8 3c bb ff ff       	call   801055fb <memcmp>
80109abf:	83 c4 10             	add    $0x10,%esp
80109ac2:	85 c0                	test   %eax,%eax
80109ac4:	74 27                	je     80109aed <arp_proc+0xab>
80109ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac9:	83 c0 0e             	add    $0xe,%eax
80109acc:	83 ec 04             	sub    $0x4,%esp
80109acf:	6a 04                	push   $0x4
80109ad1:	50                   	push   %eax
80109ad2:	68 04 f5 10 80       	push   $0x8010f504
80109ad7:	e8 1f bb ff ff       	call   801055fb <memcmp>
80109adc:	83 c4 10             	add    $0x10,%esp
80109adf:	85 c0                	test   %eax,%eax
80109ae1:	74 0a                	je     80109aed <arp_proc+0xab>
80109ae3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109ae8:	e9 ca 00 00 00       	jmp    80109bb7 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109af4:	66 3d 00 01          	cmp    $0x100,%ax
80109af8:	75 69                	jne    80109b63 <arp_proc+0x121>
80109afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afd:	83 c0 18             	add    $0x18,%eax
80109b00:	83 ec 04             	sub    $0x4,%esp
80109b03:	6a 04                	push   $0x4
80109b05:	50                   	push   %eax
80109b06:	68 04 f5 10 80       	push   $0x8010f504
80109b0b:	e8 eb ba ff ff       	call   801055fb <memcmp>
80109b10:	83 c4 10             	add    $0x10,%esp
80109b13:	85 c0                	test   %eax,%eax
80109b15:	75 4c                	jne    80109b63 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109b17:	e8 76 8d ff ff       	call   80102892 <kalloc>
80109b1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109b1f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109b26:	83 ec 04             	sub    $0x4,%esp
80109b29:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109b2c:	50                   	push   %eax
80109b2d:	ff 75 f0             	push   -0x10(%ebp)
80109b30:	ff 75 f4             	push   -0xc(%ebp)
80109b33:	e8 33 04 00 00       	call   80109f6b <arp_reply_pkt_create>
80109b38:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b3e:	83 ec 08             	sub    $0x8,%esp
80109b41:	50                   	push   %eax
80109b42:	ff 75 f0             	push   -0x10(%ebp)
80109b45:	e8 c2 fd ff ff       	call   8010990c <i8254_send>
80109b4a:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b50:	83 ec 0c             	sub    $0xc,%esp
80109b53:	50                   	push   %eax
80109b54:	e8 9b 8c ff ff       	call   801027f4 <kfree>
80109b59:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109b5c:	b8 02 00 00 00       	mov    $0x2,%eax
80109b61:	eb 54                	jmp    80109bb7 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b66:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b6a:	66 3d 00 02          	cmp    $0x200,%ax
80109b6e:	75 42                	jne    80109bb2 <arp_proc+0x170>
80109b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b73:	83 c0 18             	add    $0x18,%eax
80109b76:	83 ec 04             	sub    $0x4,%esp
80109b79:	6a 04                	push   $0x4
80109b7b:	50                   	push   %eax
80109b7c:	68 04 f5 10 80       	push   $0x8010f504
80109b81:	e8 75 ba ff ff       	call   801055fb <memcmp>
80109b86:	83 c4 10             	add    $0x10,%esp
80109b89:	85 c0                	test   %eax,%eax
80109b8b:	75 25                	jne    80109bb2 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109b8d:	83 ec 0c             	sub    $0xc,%esp
80109b90:	68 7c ce 10 80       	push   $0x8010ce7c
80109b95:	e8 72 68 ff ff       	call   8010040c <cprintf>
80109b9a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109b9d:	83 ec 0c             	sub    $0xc,%esp
80109ba0:	ff 75 f4             	push   -0xc(%ebp)
80109ba3:	e8 b7 01 00 00       	call   80109d5f <arp_table_update>
80109ba8:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109bab:	b8 01 00 00 00       	mov    $0x1,%eax
80109bb0:	eb 05                	jmp    80109bb7 <arp_proc+0x175>
  }else{
    return -1;
80109bb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109bb7:	c9                   	leave
80109bb8:	c3                   	ret

80109bb9 <arp_scan>:

void arp_scan(){
80109bb9:	f3 0f 1e fb          	endbr32
80109bbd:	55                   	push   %ebp
80109bbe:	89 e5                	mov    %esp,%ebp
80109bc0:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109bc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109bca:	eb 6f                	jmp    80109c3b <arp_scan+0x82>
    uint send = (uint)kalloc();
80109bcc:	e8 c1 8c ff ff       	call   80102892 <kalloc>
80109bd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109bd4:	83 ec 04             	sub    $0x4,%esp
80109bd7:	ff 75 f4             	push   -0xc(%ebp)
80109bda:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109bdd:	50                   	push   %eax
80109bde:	ff 75 ec             	push   -0x14(%ebp)
80109be1:	e8 62 00 00 00       	call   80109c48 <arp_broadcast>
80109be6:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bec:	83 ec 08             	sub    $0x8,%esp
80109bef:	50                   	push   %eax
80109bf0:	ff 75 ec             	push   -0x14(%ebp)
80109bf3:	e8 14 fd ff ff       	call   8010990c <i8254_send>
80109bf8:	83 c4 10             	add    $0x10,%esp
80109bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109bfe:	eb 22                	jmp    80109c22 <arp_scan+0x69>
      microdelay(1);
80109c00:	83 ec 0c             	sub    $0xc,%esp
80109c03:	6a 01                	push   $0x1
80109c05:	e8 3a 90 ff ff       	call   80102c44 <microdelay>
80109c0a:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c10:	83 ec 08             	sub    $0x8,%esp
80109c13:	50                   	push   %eax
80109c14:	ff 75 ec             	push   -0x14(%ebp)
80109c17:	e8 f0 fc ff ff       	call   8010990c <i8254_send>
80109c1c:	83 c4 10             	add    $0x10,%esp
80109c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109c22:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109c26:	74 d8                	je     80109c00 <arp_scan+0x47>
    }
    kfree((char *)send);
80109c28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c2b:	83 ec 0c             	sub    $0xc,%esp
80109c2e:	50                   	push   %eax
80109c2f:	e8 c0 8b ff ff       	call   801027f4 <kfree>
80109c34:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109c37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109c3b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109c42:	7e 88                	jle    80109bcc <arp_scan+0x13>
  }
}
80109c44:	90                   	nop
80109c45:	90                   	nop
80109c46:	c9                   	leave
80109c47:	c3                   	ret

80109c48 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109c48:	f3 0f 1e fb          	endbr32
80109c4c:	55                   	push   %ebp
80109c4d:	89 e5                	mov    %esp,%ebp
80109c4f:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109c52:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109c56:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109c5a:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109c5e:	8b 45 10             	mov    0x10(%ebp),%eax
80109c61:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109c64:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109c6b:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109c71:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109c78:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c81:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109c87:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c90:	83 c0 0e             	add    $0xe,%eax
80109c93:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c99:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca0:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ca7:	83 ec 04             	sub    $0x4,%esp
80109caa:	6a 06                	push   $0x6
80109cac:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109caf:	52                   	push   %edx
80109cb0:	50                   	push   %eax
80109cb1:	e8 a1 b9 ff ff       	call   80105657 <memmove>
80109cb6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cbc:	83 c0 06             	add    $0x6,%eax
80109cbf:	83 ec 04             	sub    $0x4,%esp
80109cc2:	6a 06                	push   $0x6
80109cc4:	68 88 d0 18 80       	push   $0x8018d088
80109cc9:	50                   	push   %eax
80109cca:	e8 88 b9 ff ff       	call   80105657 <memmove>
80109ccf:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cdd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ce6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ced:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf4:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cfd:	8d 50 12             	lea    0x12(%eax),%edx
80109d00:	83 ec 04             	sub    $0x4,%esp
80109d03:	6a 06                	push   $0x6
80109d05:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109d08:	50                   	push   %eax
80109d09:	52                   	push   %edx
80109d0a:	e8 48 b9 ff ff       	call   80105657 <memmove>
80109d0f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d15:	8d 50 18             	lea    0x18(%eax),%edx
80109d18:	83 ec 04             	sub    $0x4,%esp
80109d1b:	6a 04                	push   $0x4
80109d1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109d20:	50                   	push   %eax
80109d21:	52                   	push   %edx
80109d22:	e8 30 b9 ff ff       	call   80105657 <memmove>
80109d27:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d2d:	83 c0 08             	add    $0x8,%eax
80109d30:	83 ec 04             	sub    $0x4,%esp
80109d33:	6a 06                	push   $0x6
80109d35:	68 88 d0 18 80       	push   $0x8018d088
80109d3a:	50                   	push   %eax
80109d3b:	e8 17 b9 ff ff       	call   80105657 <memmove>
80109d40:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d46:	83 c0 0e             	add    $0xe,%eax
80109d49:	83 ec 04             	sub    $0x4,%esp
80109d4c:	6a 04                	push   $0x4
80109d4e:	68 04 f5 10 80       	push   $0x8010f504
80109d53:	50                   	push   %eax
80109d54:	e8 fe b8 ff ff       	call   80105657 <memmove>
80109d59:	83 c4 10             	add    $0x10,%esp
}
80109d5c:	90                   	nop
80109d5d:	c9                   	leave
80109d5e:	c3                   	ret

80109d5f <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109d5f:	f3 0f 1e fb          	endbr32
80109d63:	55                   	push   %ebp
80109d64:	89 e5                	mov    %esp,%ebp
80109d66:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109d69:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6c:	83 c0 0e             	add    $0xe,%eax
80109d6f:	83 ec 0c             	sub    $0xc,%esp
80109d72:	50                   	push   %eax
80109d73:	e8 bc 00 00 00       	call   80109e34 <arp_table_search>
80109d78:	83 c4 10             	add    $0x10,%esp
80109d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109d7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109d82:	78 2d                	js     80109db1 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109d84:	8b 45 08             	mov    0x8(%ebp),%eax
80109d87:	8d 48 08             	lea    0x8(%eax),%ecx
80109d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109d8d:	89 d0                	mov    %edx,%eax
80109d8f:	c1 e0 02             	shl    $0x2,%eax
80109d92:	01 d0                	add    %edx,%eax
80109d94:	01 c0                	add    %eax,%eax
80109d96:	01 d0                	add    %edx,%eax
80109d98:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109d9d:	83 c0 04             	add    $0x4,%eax
80109da0:	83 ec 04             	sub    $0x4,%esp
80109da3:	6a 06                	push   $0x6
80109da5:	51                   	push   %ecx
80109da6:	50                   	push   %eax
80109da7:	e8 ab b8 ff ff       	call   80105657 <memmove>
80109dac:	83 c4 10             	add    $0x10,%esp
80109daf:	eb 70                	jmp    80109e21 <arp_table_update+0xc2>
  }else{
    index += 1;
80109db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109db5:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109db8:	8b 45 08             	mov    0x8(%ebp),%eax
80109dbb:	8d 48 08             	lea    0x8(%eax),%ecx
80109dbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109dc1:	89 d0                	mov    %edx,%eax
80109dc3:	c1 e0 02             	shl    $0x2,%eax
80109dc6:	01 d0                	add    %edx,%eax
80109dc8:	01 c0                	add    %eax,%eax
80109dca:	01 d0                	add    %edx,%eax
80109dcc:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109dd1:	83 c0 04             	add    $0x4,%eax
80109dd4:	83 ec 04             	sub    $0x4,%esp
80109dd7:	6a 06                	push   $0x6
80109dd9:	51                   	push   %ecx
80109dda:	50                   	push   %eax
80109ddb:	e8 77 b8 ff ff       	call   80105657 <memmove>
80109de0:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109de3:	8b 45 08             	mov    0x8(%ebp),%eax
80109de6:	8d 48 0e             	lea    0xe(%eax),%ecx
80109de9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109dec:	89 d0                	mov    %edx,%eax
80109dee:	c1 e0 02             	shl    $0x2,%eax
80109df1:	01 d0                	add    %edx,%eax
80109df3:	01 c0                	add    %eax,%eax
80109df5:	01 d0                	add    %edx,%eax
80109df7:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109dfc:	83 ec 04             	sub    $0x4,%esp
80109dff:	6a 04                	push   $0x4
80109e01:	51                   	push   %ecx
80109e02:	50                   	push   %eax
80109e03:	e8 4f b8 ff ff       	call   80105657 <memmove>
80109e08:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109e0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e0e:	89 d0                	mov    %edx,%eax
80109e10:	c1 e0 02             	shl    $0x2,%eax
80109e13:	01 d0                	add    %edx,%eax
80109e15:	01 c0                	add    %eax,%eax
80109e17:	01 d0                	add    %edx,%eax
80109e19:	05 aa d0 18 80       	add    $0x8018d0aa,%eax
80109e1e:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109e21:	83 ec 0c             	sub    $0xc,%esp
80109e24:	68 a0 d0 18 80       	push   $0x8018d0a0
80109e29:	e8 87 00 00 00       	call   80109eb5 <print_arp_table>
80109e2e:	83 c4 10             	add    $0x10,%esp
}
80109e31:	90                   	nop
80109e32:	c9                   	leave
80109e33:	c3                   	ret

80109e34 <arp_table_search>:

int arp_table_search(uchar *ip){
80109e34:	f3 0f 1e fb          	endbr32
80109e38:	55                   	push   %ebp
80109e39:	89 e5                	mov    %esp,%ebp
80109e3b:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109e3e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109e45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e4c:	eb 59                	jmp    80109ea7 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109e4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e51:	89 d0                	mov    %edx,%eax
80109e53:	c1 e0 02             	shl    $0x2,%eax
80109e56:	01 d0                	add    %edx,%eax
80109e58:	01 c0                	add    %eax,%eax
80109e5a:	01 d0                	add    %edx,%eax
80109e5c:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109e61:	83 ec 04             	sub    $0x4,%esp
80109e64:	6a 04                	push   $0x4
80109e66:	ff 75 08             	push   0x8(%ebp)
80109e69:	50                   	push   %eax
80109e6a:	e8 8c b7 ff ff       	call   801055fb <memcmp>
80109e6f:	83 c4 10             	add    $0x10,%esp
80109e72:	85 c0                	test   %eax,%eax
80109e74:	75 05                	jne    80109e7b <arp_table_search+0x47>
      return i;
80109e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e79:	eb 38                	jmp    80109eb3 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109e7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e7e:	89 d0                	mov    %edx,%eax
80109e80:	c1 e0 02             	shl    $0x2,%eax
80109e83:	01 d0                	add    %edx,%eax
80109e85:	01 c0                	add    %eax,%eax
80109e87:	01 d0                	add    %edx,%eax
80109e89:	05 aa d0 18 80       	add    $0x8018d0aa,%eax
80109e8e:	0f b6 00             	movzbl (%eax),%eax
80109e91:	84 c0                	test   %al,%al
80109e93:	75 0e                	jne    80109ea3 <arp_table_search+0x6f>
80109e95:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109e99:	75 08                	jne    80109ea3 <arp_table_search+0x6f>
      empty = -i;
80109e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e9e:	f7 d8                	neg    %eax
80109ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ea3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ea7:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109eab:	7e a1                	jle    80109e4e <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb0:	83 e8 01             	sub    $0x1,%eax
}
80109eb3:	c9                   	leave
80109eb4:	c3                   	ret

80109eb5 <print_arp_table>:

void print_arp_table(){
80109eb5:	f3 0f 1e fb          	endbr32
80109eb9:	55                   	push   %ebp
80109eba:	89 e5                	mov    %esp,%ebp
80109ebc:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109ebf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109ec6:	e9 92 00 00 00       	jmp    80109f5d <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109ecb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ece:	89 d0                	mov    %edx,%eax
80109ed0:	c1 e0 02             	shl    $0x2,%eax
80109ed3:	01 d0                	add    %edx,%eax
80109ed5:	01 c0                	add    %eax,%eax
80109ed7:	01 d0                	add    %edx,%eax
80109ed9:	05 aa d0 18 80       	add    $0x8018d0aa,%eax
80109ede:	0f b6 00             	movzbl (%eax),%eax
80109ee1:	84 c0                	test   %al,%al
80109ee3:	74 74                	je     80109f59 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109ee5:	83 ec 08             	sub    $0x8,%esp
80109ee8:	ff 75 f4             	push   -0xc(%ebp)
80109eeb:	68 8f ce 10 80       	push   $0x8010ce8f
80109ef0:	e8 17 65 ff ff       	call   8010040c <cprintf>
80109ef5:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109efb:	89 d0                	mov    %edx,%eax
80109efd:	c1 e0 02             	shl    $0x2,%eax
80109f00:	01 d0                	add    %edx,%eax
80109f02:	01 c0                	add    %eax,%eax
80109f04:	01 d0                	add    %edx,%eax
80109f06:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109f0b:	83 ec 0c             	sub    $0xc,%esp
80109f0e:	50                   	push   %eax
80109f0f:	e8 5c 02 00 00       	call   8010a170 <print_ipv4>
80109f14:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109f17:	83 ec 0c             	sub    $0xc,%esp
80109f1a:	68 9e ce 10 80       	push   $0x8010ce9e
80109f1f:	e8 e8 64 ff ff       	call   8010040c <cprintf>
80109f24:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f2a:	89 d0                	mov    %edx,%eax
80109f2c:	c1 e0 02             	shl    $0x2,%eax
80109f2f:	01 d0                	add    %edx,%eax
80109f31:	01 c0                	add    %eax,%eax
80109f33:	01 d0                	add    %edx,%eax
80109f35:	05 a0 d0 18 80       	add    $0x8018d0a0,%eax
80109f3a:	83 c0 04             	add    $0x4,%eax
80109f3d:	83 ec 0c             	sub    $0xc,%esp
80109f40:	50                   	push   %eax
80109f41:	e8 7c 02 00 00       	call   8010a1c2 <print_mac>
80109f46:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109f49:	83 ec 0c             	sub    $0xc,%esp
80109f4c:	68 a0 ce 10 80       	push   $0x8010cea0
80109f51:	e8 b6 64 ff ff       	call   8010040c <cprintf>
80109f56:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109f59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109f5d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109f61:	0f 8e 64 ff ff ff    	jle    80109ecb <print_arp_table+0x16>
    }
  }
}
80109f67:	90                   	nop
80109f68:	90                   	nop
80109f69:	c9                   	leave
80109f6a:	c3                   	ret

80109f6b <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109f6b:	f3 0f 1e fb          	endbr32
80109f6f:	55                   	push   %ebp
80109f70:	89 e5                	mov    %esp,%ebp
80109f72:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109f75:	8b 45 10             	mov    0x10(%ebp),%eax
80109f78:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f87:	83 c0 0e             	add    $0xe,%eax
80109f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f90:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f97:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9e:	8d 50 08             	lea    0x8(%eax),%edx
80109fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fa4:	83 ec 04             	sub    $0x4,%esp
80109fa7:	6a 06                	push   $0x6
80109fa9:	52                   	push   %edx
80109faa:	50                   	push   %eax
80109fab:	e8 a7 b6 ff ff       	call   80105657 <memmove>
80109fb0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb6:	83 c0 06             	add    $0x6,%eax
80109fb9:	83 ec 04             	sub    $0x4,%esp
80109fbc:	6a 06                	push   $0x6
80109fbe:	68 88 d0 18 80       	push   $0x8018d088
80109fc3:	50                   	push   %eax
80109fc4:	e8 8e b6 ff ff       	call   80105657 <memmove>
80109fc9:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fcf:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd7:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fe0:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fe7:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fee:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff7:	8d 50 08             	lea    0x8(%eax),%edx
80109ffa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ffd:	83 c0 12             	add    $0x12,%eax
8010a000:	83 ec 04             	sub    $0x4,%esp
8010a003:	6a 06                	push   $0x6
8010a005:	52                   	push   %edx
8010a006:	50                   	push   %eax
8010a007:	e8 4b b6 ff ff       	call   80105657 <memmove>
8010a00c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010a00f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a012:	8d 50 0e             	lea    0xe(%eax),%edx
8010a015:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a018:	83 c0 18             	add    $0x18,%eax
8010a01b:	83 ec 04             	sub    $0x4,%esp
8010a01e:	6a 04                	push   $0x4
8010a020:	52                   	push   %edx
8010a021:	50                   	push   %eax
8010a022:	e8 30 b6 ff ff       	call   80105657 <memmove>
8010a027:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010a02a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a02d:	83 c0 08             	add    $0x8,%eax
8010a030:	83 ec 04             	sub    $0x4,%esp
8010a033:	6a 06                	push   $0x6
8010a035:	68 88 d0 18 80       	push   $0x8018d088
8010a03a:	50                   	push   %eax
8010a03b:	e8 17 b6 ff ff       	call   80105657 <memmove>
8010a040:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010a043:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a046:	83 c0 0e             	add    $0xe,%eax
8010a049:	83 ec 04             	sub    $0x4,%esp
8010a04c:	6a 04                	push   $0x4
8010a04e:	68 04 f5 10 80       	push   $0x8010f504
8010a053:	50                   	push   %eax
8010a054:	e8 fe b5 ff ff       	call   80105657 <memmove>
8010a059:	83 c4 10             	add    $0x10,%esp
}
8010a05c:	90                   	nop
8010a05d:	c9                   	leave
8010a05e:	c3                   	ret

8010a05f <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010a05f:	f3 0f 1e fb          	endbr32
8010a063:	55                   	push   %ebp
8010a064:	89 e5                	mov    %esp,%ebp
8010a066:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010a069:	83 ec 0c             	sub    $0xc,%esp
8010a06c:	68 a2 ce 10 80       	push   $0x8010cea2
8010a071:	e8 96 63 ff ff       	call   8010040c <cprintf>
8010a076:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010a079:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07c:	83 c0 0e             	add    $0xe,%eax
8010a07f:	83 ec 0c             	sub    $0xc,%esp
8010a082:	50                   	push   %eax
8010a083:	e8 e8 00 00 00       	call   8010a170 <print_ipv4>
8010a088:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a08b:	83 ec 0c             	sub    $0xc,%esp
8010a08e:	68 a0 ce 10 80       	push   $0x8010cea0
8010a093:	e8 74 63 ff ff       	call   8010040c <cprintf>
8010a098:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010a09b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a09e:	83 c0 08             	add    $0x8,%eax
8010a0a1:	83 ec 0c             	sub    $0xc,%esp
8010a0a4:	50                   	push   %eax
8010a0a5:	e8 18 01 00 00       	call   8010a1c2 <print_mac>
8010a0aa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a0ad:	83 ec 0c             	sub    $0xc,%esp
8010a0b0:	68 a0 ce 10 80       	push   $0x8010cea0
8010a0b5:	e8 52 63 ff ff       	call   8010040c <cprintf>
8010a0ba:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a0bd:	83 ec 0c             	sub    $0xc,%esp
8010a0c0:	68 b9 ce 10 80       	push   $0x8010ceb9
8010a0c5:	e8 42 63 ff ff       	call   8010040c <cprintf>
8010a0ca:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010a0cd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d0:	83 c0 18             	add    $0x18,%eax
8010a0d3:	83 ec 0c             	sub    $0xc,%esp
8010a0d6:	50                   	push   %eax
8010a0d7:	e8 94 00 00 00       	call   8010a170 <print_ipv4>
8010a0dc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a0df:	83 ec 0c             	sub    $0xc,%esp
8010a0e2:	68 a0 ce 10 80       	push   $0x8010cea0
8010a0e7:	e8 20 63 ff ff       	call   8010040c <cprintf>
8010a0ec:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010a0ef:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0f2:	83 c0 12             	add    $0x12,%eax
8010a0f5:	83 ec 0c             	sub    $0xc,%esp
8010a0f8:	50                   	push   %eax
8010a0f9:	e8 c4 00 00 00       	call   8010a1c2 <print_mac>
8010a0fe:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a101:	83 ec 0c             	sub    $0xc,%esp
8010a104:	68 a0 ce 10 80       	push   $0x8010cea0
8010a109:	e8 fe 62 ff ff       	call   8010040c <cprintf>
8010a10e:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a111:	83 ec 0c             	sub    $0xc,%esp
8010a114:	68 d0 ce 10 80       	push   $0x8010ced0
8010a119:	e8 ee 62 ff ff       	call   8010040c <cprintf>
8010a11e:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a121:	8b 45 08             	mov    0x8(%ebp),%eax
8010a124:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a128:	66 3d 00 01          	cmp    $0x100,%ax
8010a12c:	75 12                	jne    8010a140 <print_arp_info+0xe1>
8010a12e:	83 ec 0c             	sub    $0xc,%esp
8010a131:	68 dc ce 10 80       	push   $0x8010cedc
8010a136:	e8 d1 62 ff ff       	call   8010040c <cprintf>
8010a13b:	83 c4 10             	add    $0x10,%esp
8010a13e:	eb 1d                	jmp    8010a15d <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a140:	8b 45 08             	mov    0x8(%ebp),%eax
8010a143:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a147:	66 3d 00 02          	cmp    $0x200,%ax
8010a14b:	75 10                	jne    8010a15d <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a14d:	83 ec 0c             	sub    $0xc,%esp
8010a150:	68 e5 ce 10 80       	push   $0x8010cee5
8010a155:	e8 b2 62 ff ff       	call   8010040c <cprintf>
8010a15a:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a15d:	83 ec 0c             	sub    $0xc,%esp
8010a160:	68 a0 ce 10 80       	push   $0x8010cea0
8010a165:	e8 a2 62 ff ff       	call   8010040c <cprintf>
8010a16a:	83 c4 10             	add    $0x10,%esp
}
8010a16d:	90                   	nop
8010a16e:	c9                   	leave
8010a16f:	c3                   	ret

8010a170 <print_ipv4>:

void print_ipv4(uchar *ip){
8010a170:	f3 0f 1e fb          	endbr32
8010a174:	55                   	push   %ebp
8010a175:	89 e5                	mov    %esp,%ebp
8010a177:	53                   	push   %ebx
8010a178:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a17b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a17e:	83 c0 03             	add    $0x3,%eax
8010a181:	0f b6 00             	movzbl (%eax),%eax
8010a184:	0f b6 d8             	movzbl %al,%ebx
8010a187:	8b 45 08             	mov    0x8(%ebp),%eax
8010a18a:	83 c0 02             	add    $0x2,%eax
8010a18d:	0f b6 00             	movzbl (%eax),%eax
8010a190:	0f b6 c8             	movzbl %al,%ecx
8010a193:	8b 45 08             	mov    0x8(%ebp),%eax
8010a196:	83 c0 01             	add    $0x1,%eax
8010a199:	0f b6 00             	movzbl (%eax),%eax
8010a19c:	0f b6 d0             	movzbl %al,%edx
8010a19f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a2:	0f b6 00             	movzbl (%eax),%eax
8010a1a5:	0f b6 c0             	movzbl %al,%eax
8010a1a8:	83 ec 0c             	sub    $0xc,%esp
8010a1ab:	53                   	push   %ebx
8010a1ac:	51                   	push   %ecx
8010a1ad:	52                   	push   %edx
8010a1ae:	50                   	push   %eax
8010a1af:	68 ec ce 10 80       	push   $0x8010ceec
8010a1b4:	e8 53 62 ff ff       	call   8010040c <cprintf>
8010a1b9:	83 c4 20             	add    $0x20,%esp
}
8010a1bc:	90                   	nop
8010a1bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a1c0:	c9                   	leave
8010a1c1:	c3                   	ret

8010a1c2 <print_mac>:

void print_mac(uchar *mac){
8010a1c2:	f3 0f 1e fb          	endbr32
8010a1c6:	55                   	push   %ebp
8010a1c7:	89 e5                	mov    %esp,%ebp
8010a1c9:	57                   	push   %edi
8010a1ca:	56                   	push   %esi
8010a1cb:	53                   	push   %ebx
8010a1cc:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a1cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1d2:	83 c0 05             	add    $0x5,%eax
8010a1d5:	0f b6 00             	movzbl (%eax),%eax
8010a1d8:	0f b6 f8             	movzbl %al,%edi
8010a1db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1de:	83 c0 04             	add    $0x4,%eax
8010a1e1:	0f b6 00             	movzbl (%eax),%eax
8010a1e4:	0f b6 f0             	movzbl %al,%esi
8010a1e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ea:	83 c0 03             	add    $0x3,%eax
8010a1ed:	0f b6 00             	movzbl (%eax),%eax
8010a1f0:	0f b6 d8             	movzbl %al,%ebx
8010a1f3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f6:	83 c0 02             	add    $0x2,%eax
8010a1f9:	0f b6 00             	movzbl (%eax),%eax
8010a1fc:	0f b6 c8             	movzbl %al,%ecx
8010a1ff:	8b 45 08             	mov    0x8(%ebp),%eax
8010a202:	83 c0 01             	add    $0x1,%eax
8010a205:	0f b6 00             	movzbl (%eax),%eax
8010a208:	0f b6 d0             	movzbl %al,%edx
8010a20b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a20e:	0f b6 00             	movzbl (%eax),%eax
8010a211:	0f b6 c0             	movzbl %al,%eax
8010a214:	83 ec 04             	sub    $0x4,%esp
8010a217:	57                   	push   %edi
8010a218:	56                   	push   %esi
8010a219:	53                   	push   %ebx
8010a21a:	51                   	push   %ecx
8010a21b:	52                   	push   %edx
8010a21c:	50                   	push   %eax
8010a21d:	68 04 cf 10 80       	push   $0x8010cf04
8010a222:	e8 e5 61 ff ff       	call   8010040c <cprintf>
8010a227:	83 c4 20             	add    $0x20,%esp
}
8010a22a:	90                   	nop
8010a22b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a22e:	5b                   	pop    %ebx
8010a22f:	5e                   	pop    %esi
8010a230:	5f                   	pop    %edi
8010a231:	5d                   	pop    %ebp
8010a232:	c3                   	ret

8010a233 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a233:	f3 0f 1e fb          	endbr32
8010a237:	55                   	push   %ebp
8010a238:	89 e5                	mov    %esp,%ebp
8010a23a:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a23d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a240:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a243:	8b 45 08             	mov    0x8(%ebp),%eax
8010a246:	83 c0 0e             	add    $0xe,%eax
8010a249:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a24c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a24f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a253:	3c 08                	cmp    $0x8,%al
8010a255:	75 1b                	jne    8010a272 <eth_proc+0x3f>
8010a257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a25a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a25e:	3c 06                	cmp    $0x6,%al
8010a260:	75 10                	jne    8010a272 <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a262:	83 ec 0c             	sub    $0xc,%esp
8010a265:	ff 75 f0             	push   -0x10(%ebp)
8010a268:	e8 d5 f7 ff ff       	call   80109a42 <arp_proc>
8010a26d:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a270:	eb 24                	jmp    8010a296 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a272:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a275:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a279:	3c 08                	cmp    $0x8,%al
8010a27b:	75 19                	jne    8010a296 <eth_proc+0x63>
8010a27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a280:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a284:	84 c0                	test   %al,%al
8010a286:	75 0e                	jne    8010a296 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a288:	83 ec 0c             	sub    $0xc,%esp
8010a28b:	ff 75 08             	push   0x8(%ebp)
8010a28e:	e8 b3 00 00 00       	call   8010a346 <ipv4_proc>
8010a293:	83 c4 10             	add    $0x10,%esp
}
8010a296:	90                   	nop
8010a297:	c9                   	leave
8010a298:	c3                   	ret

8010a299 <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a299:	f3 0f 1e fb          	endbr32
8010a29d:	55                   	push   %ebp
8010a29e:	89 e5                	mov    %esp,%ebp
8010a2a0:	83 ec 04             	sub    $0x4,%esp
8010a2a3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a2aa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a2ae:	c1 e0 08             	shl    $0x8,%eax
8010a2b1:	89 c2                	mov    %eax,%edx
8010a2b3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a2b7:	66 c1 e8 08          	shr    $0x8,%ax
8010a2bb:	01 d0                	add    %edx,%eax
}
8010a2bd:	c9                   	leave
8010a2be:	c3                   	ret

8010a2bf <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a2bf:	f3 0f 1e fb          	endbr32
8010a2c3:	55                   	push   %ebp
8010a2c4:	89 e5                	mov    %esp,%ebp
8010a2c6:	83 ec 04             	sub    $0x4,%esp
8010a2c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2cc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a2d0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a2d4:	c1 e0 08             	shl    $0x8,%eax
8010a2d7:	89 c2                	mov    %eax,%edx
8010a2d9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a2dd:	66 c1 e8 08          	shr    $0x8,%ax
8010a2e1:	01 d0                	add    %edx,%eax
}
8010a2e3:	c9                   	leave
8010a2e4:	c3                   	ret

8010a2e5 <H2N_uint>:

uint H2N_uint(uint value){
8010a2e5:	f3 0f 1e fb          	endbr32
8010a2e9:	55                   	push   %ebp
8010a2ea:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a2ec:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ef:	c1 e0 18             	shl    $0x18,%eax
8010a2f2:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a2f7:	89 c2                	mov    %eax,%edx
8010a2f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2fc:	c1 e0 08             	shl    $0x8,%eax
8010a2ff:	25 00 f0 00 00       	and    $0xf000,%eax
8010a304:	09 c2                	or     %eax,%edx
8010a306:	8b 45 08             	mov    0x8(%ebp),%eax
8010a309:	c1 e8 08             	shr    $0x8,%eax
8010a30c:	83 e0 0f             	and    $0xf,%eax
8010a30f:	01 d0                	add    %edx,%eax
}
8010a311:	5d                   	pop    %ebp
8010a312:	c3                   	ret

8010a313 <N2H_uint>:

uint N2H_uint(uint value){
8010a313:	f3 0f 1e fb          	endbr32
8010a317:	55                   	push   %ebp
8010a318:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a31a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a31d:	c1 e0 18             	shl    $0x18,%eax
8010a320:	89 c2                	mov    %eax,%edx
8010a322:	8b 45 08             	mov    0x8(%ebp),%eax
8010a325:	c1 e0 08             	shl    $0x8,%eax
8010a328:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a32d:	01 c2                	add    %eax,%edx
8010a32f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a332:	c1 e8 08             	shr    $0x8,%eax
8010a335:	25 00 ff 00 00       	and    $0xff00,%eax
8010a33a:	01 c2                	add    %eax,%edx
8010a33c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a33f:	c1 e8 18             	shr    $0x18,%eax
8010a342:	01 d0                	add    %edx,%eax
}
8010a344:	5d                   	pop    %ebp
8010a345:	c3                   	ret

8010a346 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a346:	f3 0f 1e fb          	endbr32
8010a34a:	55                   	push   %ebp
8010a34b:	89 e5                	mov    %esp,%ebp
8010a34d:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a350:	8b 45 08             	mov    0x8(%ebp),%eax
8010a353:	83 c0 0e             	add    $0xe,%eax
8010a356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a35c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a360:	0f b7 d0             	movzwl %ax,%edx
8010a363:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a368:	39 c2                	cmp    %eax,%edx
8010a36a:	74 60                	je     8010a3cc <ipv4_proc+0x86>
8010a36c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a36f:	83 c0 0c             	add    $0xc,%eax
8010a372:	83 ec 04             	sub    $0x4,%esp
8010a375:	6a 04                	push   $0x4
8010a377:	50                   	push   %eax
8010a378:	68 04 f5 10 80       	push   $0x8010f504
8010a37d:	e8 79 b2 ff ff       	call   801055fb <memcmp>
8010a382:	83 c4 10             	add    $0x10,%esp
8010a385:	85 c0                	test   %eax,%eax
8010a387:	74 43                	je     8010a3cc <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a38c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a390:	0f b7 c0             	movzwl %ax,%eax
8010a393:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a39b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a39f:	3c 01                	cmp    $0x1,%al
8010a3a1:	75 10                	jne    8010a3b3 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a3a3:	83 ec 0c             	sub    $0xc,%esp
8010a3a6:	ff 75 08             	push   0x8(%ebp)
8010a3a9:	e8 a7 00 00 00       	call   8010a455 <icmp_proc>
8010a3ae:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a3b1:	eb 19                	jmp    8010a3cc <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a3b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3b6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a3ba:	3c 06                	cmp    $0x6,%al
8010a3bc:	75 0e                	jne    8010a3cc <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a3be:	83 ec 0c             	sub    $0xc,%esp
8010a3c1:	ff 75 08             	push   0x8(%ebp)
8010a3c4:	e8 c7 03 00 00       	call   8010a790 <tcp_proc>
8010a3c9:	83 c4 10             	add    $0x10,%esp
}
8010a3cc:	90                   	nop
8010a3cd:	c9                   	leave
8010a3ce:	c3                   	ret

8010a3cf <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a3cf:	f3 0f 1e fb          	endbr32
8010a3d3:	55                   	push   %ebp
8010a3d4:	89 e5                	mov    %esp,%ebp
8010a3d6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a3d9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a3df:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3e2:	0f b6 00             	movzbl (%eax),%eax
8010a3e5:	83 e0 0f             	and    $0xf,%eax
8010a3e8:	01 c0                	add    %eax,%eax
8010a3ea:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a3ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a3f4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a3fb:	eb 48                	jmp    8010a445 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a400:	01 c0                	add    %eax,%eax
8010a402:	89 c2                	mov    %eax,%edx
8010a404:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a407:	01 d0                	add    %edx,%eax
8010a409:	0f b6 00             	movzbl (%eax),%eax
8010a40c:	0f b6 c0             	movzbl %al,%eax
8010a40f:	c1 e0 08             	shl    $0x8,%eax
8010a412:	89 c2                	mov    %eax,%edx
8010a414:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a417:	01 c0                	add    %eax,%eax
8010a419:	8d 48 01             	lea    0x1(%eax),%ecx
8010a41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a41f:	01 c8                	add    %ecx,%eax
8010a421:	0f b6 00             	movzbl (%eax),%eax
8010a424:	0f b6 c0             	movzbl %al,%eax
8010a427:	01 d0                	add    %edx,%eax
8010a429:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a42c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a433:	76 0c                	jbe    8010a441 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a435:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a438:	0f b7 c0             	movzwl %ax,%eax
8010a43b:	83 c0 01             	add    $0x1,%eax
8010a43e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a441:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a445:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a449:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a44c:	7c af                	jl     8010a3fd <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a44e:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a451:	f7 d0                	not    %eax
}
8010a453:	c9                   	leave
8010a454:	c3                   	ret

8010a455 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a455:	f3 0f 1e fb          	endbr32
8010a459:	55                   	push   %ebp
8010a45a:	89 e5                	mov    %esp,%ebp
8010a45c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a45f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a462:	83 c0 0e             	add    $0xe,%eax
8010a465:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a46b:	0f b6 00             	movzbl (%eax),%eax
8010a46e:	0f b6 c0             	movzbl %al,%eax
8010a471:	83 e0 0f             	and    $0xf,%eax
8010a474:	c1 e0 02             	shl    $0x2,%eax
8010a477:	89 c2                	mov    %eax,%edx
8010a479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a47c:	01 d0                	add    %edx,%eax
8010a47e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a481:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a484:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a488:	84 c0                	test   %al,%al
8010a48a:	75 4f                	jne    8010a4db <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a48c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a48f:	0f b6 00             	movzbl (%eax),%eax
8010a492:	3c 08                	cmp    $0x8,%al
8010a494:	75 45                	jne    8010a4db <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a496:	e8 f7 83 ff ff       	call   80102892 <kalloc>
8010a49b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a49e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a4a5:	83 ec 04             	sub    $0x4,%esp
8010a4a8:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a4ab:	50                   	push   %eax
8010a4ac:	ff 75 ec             	push   -0x14(%ebp)
8010a4af:	ff 75 08             	push   0x8(%ebp)
8010a4b2:	e8 7c 00 00 00       	call   8010a533 <icmp_reply_pkt_create>
8010a4b7:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a4ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4bd:	83 ec 08             	sub    $0x8,%esp
8010a4c0:	50                   	push   %eax
8010a4c1:	ff 75 ec             	push   -0x14(%ebp)
8010a4c4:	e8 43 f4 ff ff       	call   8010990c <i8254_send>
8010a4c9:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a4cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4cf:	83 ec 0c             	sub    $0xc,%esp
8010a4d2:	50                   	push   %eax
8010a4d3:	e8 1c 83 ff ff       	call   801027f4 <kfree>
8010a4d8:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a4db:	90                   	nop
8010a4dc:	c9                   	leave
8010a4dd:	c3                   	ret

8010a4de <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a4de:	f3 0f 1e fb          	endbr32
8010a4e2:	55                   	push   %ebp
8010a4e3:	89 e5                	mov    %esp,%ebp
8010a4e5:	53                   	push   %ebx
8010a4e6:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a4e9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ec:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a4f0:	0f b7 c0             	movzwl %ax,%eax
8010a4f3:	83 ec 0c             	sub    $0xc,%esp
8010a4f6:	50                   	push   %eax
8010a4f7:	e8 9d fd ff ff       	call   8010a299 <N2H_ushort>
8010a4fc:	83 c4 10             	add    $0x10,%esp
8010a4ff:	0f b7 d8             	movzwl %ax,%ebx
8010a502:	8b 45 08             	mov    0x8(%ebp),%eax
8010a505:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a509:	0f b7 c0             	movzwl %ax,%eax
8010a50c:	83 ec 0c             	sub    $0xc,%esp
8010a50f:	50                   	push   %eax
8010a510:	e8 84 fd ff ff       	call   8010a299 <N2H_ushort>
8010a515:	83 c4 10             	add    $0x10,%esp
8010a518:	0f b7 c0             	movzwl %ax,%eax
8010a51b:	83 ec 04             	sub    $0x4,%esp
8010a51e:	53                   	push   %ebx
8010a51f:	50                   	push   %eax
8010a520:	68 23 cf 10 80       	push   $0x8010cf23
8010a525:	e8 e2 5e ff ff       	call   8010040c <cprintf>
8010a52a:	83 c4 10             	add    $0x10,%esp
}
8010a52d:	90                   	nop
8010a52e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a531:	c9                   	leave
8010a532:	c3                   	ret

8010a533 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a533:	f3 0f 1e fb          	endbr32
8010a537:	55                   	push   %ebp
8010a538:	89 e5                	mov    %esp,%ebp
8010a53a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a53d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a540:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a543:	8b 45 08             	mov    0x8(%ebp),%eax
8010a546:	83 c0 0e             	add    $0xe,%eax
8010a549:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a54c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a54f:	0f b6 00             	movzbl (%eax),%eax
8010a552:	0f b6 c0             	movzbl %al,%eax
8010a555:	83 e0 0f             	and    $0xf,%eax
8010a558:	c1 e0 02             	shl    $0x2,%eax
8010a55b:	89 c2                	mov    %eax,%edx
8010a55d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a560:	01 d0                	add    %edx,%eax
8010a562:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a565:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a568:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a56b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a56e:	83 c0 0e             	add    $0xe,%eax
8010a571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a577:	83 c0 14             	add    $0x14,%eax
8010a57a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a57d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a580:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a586:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a589:	8d 50 06             	lea    0x6(%eax),%edx
8010a58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a58f:	83 ec 04             	sub    $0x4,%esp
8010a592:	6a 06                	push   $0x6
8010a594:	52                   	push   %edx
8010a595:	50                   	push   %eax
8010a596:	e8 bc b0 ff ff       	call   80105657 <memmove>
8010a59b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a59e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5a1:	83 c0 06             	add    $0x6,%eax
8010a5a4:	83 ec 04             	sub    $0x4,%esp
8010a5a7:	6a 06                	push   $0x6
8010a5a9:	68 88 d0 18 80       	push   $0x8018d088
8010a5ae:	50                   	push   %eax
8010a5af:	e8 a3 b0 ff ff       	call   80105657 <memmove>
8010a5b4:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a5b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5ba:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a5be:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5c1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a5c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5c8:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a5cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5ce:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a5d2:	83 ec 0c             	sub    $0xc,%esp
8010a5d5:	6a 54                	push   $0x54
8010a5d7:	e8 e3 fc ff ff       	call   8010a2bf <H2N_ushort>
8010a5dc:	83 c4 10             	add    $0x10,%esp
8010a5df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a5e2:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a5e6:	0f b7 15 60 d3 18 80 	movzwl 0x8018d360,%edx
8010a5ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5f0:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a5f4:	0f b7 05 60 d3 18 80 	movzwl 0x8018d360,%eax
8010a5fb:	83 c0 01             	add    $0x1,%eax
8010a5fe:	66 a3 60 d3 18 80    	mov    %ax,0x8018d360
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a604:	83 ec 0c             	sub    $0xc,%esp
8010a607:	68 00 40 00 00       	push   $0x4000
8010a60c:	e8 ae fc ff ff       	call   8010a2bf <H2N_ushort>
8010a611:	83 c4 10             	add    $0x10,%esp
8010a614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a617:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a61b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a61e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a625:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a62c:	83 c0 0c             	add    $0xc,%eax
8010a62f:	83 ec 04             	sub    $0x4,%esp
8010a632:	6a 04                	push   $0x4
8010a634:	68 04 f5 10 80       	push   $0x8010f504
8010a639:	50                   	push   %eax
8010a63a:	e8 18 b0 ff ff       	call   80105657 <memmove>
8010a63f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a642:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a645:	8d 50 0c             	lea    0xc(%eax),%edx
8010a648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a64b:	83 c0 10             	add    $0x10,%eax
8010a64e:	83 ec 04             	sub    $0x4,%esp
8010a651:	6a 04                	push   $0x4
8010a653:	52                   	push   %edx
8010a654:	50                   	push   %eax
8010a655:	e8 fd af ff ff       	call   80105657 <memmove>
8010a65a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a65d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a660:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a669:	83 ec 0c             	sub    $0xc,%esp
8010a66c:	50                   	push   %eax
8010a66d:	e8 5d fd ff ff       	call   8010a3cf <ipv4_chksum>
8010a672:	83 c4 10             	add    $0x10,%esp
8010a675:	0f b7 c0             	movzwl %ax,%eax
8010a678:	83 ec 0c             	sub    $0xc,%esp
8010a67b:	50                   	push   %eax
8010a67c:	e8 3e fc ff ff       	call   8010a2bf <H2N_ushort>
8010a681:	83 c4 10             	add    $0x10,%esp
8010a684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a687:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a68b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a68e:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a691:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a694:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a698:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a69b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a69f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6a2:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a6a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6a9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a6ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6b0:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a6b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6b7:	8d 50 08             	lea    0x8(%eax),%edx
8010a6ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6bd:	83 c0 08             	add    $0x8,%eax
8010a6c0:	83 ec 04             	sub    $0x4,%esp
8010a6c3:	6a 08                	push   $0x8
8010a6c5:	52                   	push   %edx
8010a6c6:	50                   	push   %eax
8010a6c7:	e8 8b af ff ff       	call   80105657 <memmove>
8010a6cc:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a6cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6d2:	8d 50 10             	lea    0x10(%eax),%edx
8010a6d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6d8:	83 c0 10             	add    $0x10,%eax
8010a6db:	83 ec 04             	sub    $0x4,%esp
8010a6de:	6a 30                	push   $0x30
8010a6e0:	52                   	push   %edx
8010a6e1:	50                   	push   %eax
8010a6e2:	e8 70 af ff ff       	call   80105657 <memmove>
8010a6e7:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a6ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6ed:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a6f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6f6:	83 ec 0c             	sub    $0xc,%esp
8010a6f9:	50                   	push   %eax
8010a6fa:	e8 1c 00 00 00       	call   8010a71b <icmp_chksum>
8010a6ff:	83 c4 10             	add    $0x10,%esp
8010a702:	0f b7 c0             	movzwl %ax,%eax
8010a705:	83 ec 0c             	sub    $0xc,%esp
8010a708:	50                   	push   %eax
8010a709:	e8 b1 fb ff ff       	call   8010a2bf <H2N_ushort>
8010a70e:	83 c4 10             	add    $0x10,%esp
8010a711:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a714:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a718:	90                   	nop
8010a719:	c9                   	leave
8010a71a:	c3                   	ret

8010a71b <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a71b:	f3 0f 1e fb          	endbr32
8010a71f:	55                   	push   %ebp
8010a720:	89 e5                	mov    %esp,%ebp
8010a722:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a725:	8b 45 08             	mov    0x8(%ebp),%eax
8010a728:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a72b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a732:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a739:	eb 48                	jmp    8010a783 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a73e:	01 c0                	add    %eax,%eax
8010a740:	89 c2                	mov    %eax,%edx
8010a742:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a745:	01 d0                	add    %edx,%eax
8010a747:	0f b6 00             	movzbl (%eax),%eax
8010a74a:	0f b6 c0             	movzbl %al,%eax
8010a74d:	c1 e0 08             	shl    $0x8,%eax
8010a750:	89 c2                	mov    %eax,%edx
8010a752:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a755:	01 c0                	add    %eax,%eax
8010a757:	8d 48 01             	lea    0x1(%eax),%ecx
8010a75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a75d:	01 c8                	add    %ecx,%eax
8010a75f:	0f b6 00             	movzbl (%eax),%eax
8010a762:	0f b6 c0             	movzbl %al,%eax
8010a765:	01 d0                	add    %edx,%eax
8010a767:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a76a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a771:	76 0c                	jbe    8010a77f <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a773:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a776:	0f b7 c0             	movzwl %ax,%eax
8010a779:	83 c0 01             	add    $0x1,%eax
8010a77c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a77f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a783:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a787:	7e b2                	jle    8010a73b <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a789:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a78c:	f7 d0                	not    %eax
}
8010a78e:	c9                   	leave
8010a78f:	c3                   	ret

8010a790 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a790:	f3 0f 1e fb          	endbr32
8010a794:	55                   	push   %ebp
8010a795:	89 e5                	mov    %esp,%ebp
8010a797:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a79a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a79d:	83 c0 0e             	add    $0xe,%eax
8010a7a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7a6:	0f b6 00             	movzbl (%eax),%eax
8010a7a9:	0f b6 c0             	movzbl %al,%eax
8010a7ac:	83 e0 0f             	and    $0xf,%eax
8010a7af:	c1 e0 02             	shl    $0x2,%eax
8010a7b2:	89 c2                	mov    %eax,%edx
8010a7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7b7:	01 d0                	add    %edx,%eax
8010a7b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a7bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7bf:	83 c0 14             	add    $0x14,%eax
8010a7c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a7c5:	e8 c8 80 ff ff       	call   80102892 <kalloc>
8010a7ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a7cd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a7d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7d7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a7db:	0f b6 c0             	movzbl %al,%eax
8010a7de:	83 e0 02             	and    $0x2,%eax
8010a7e1:	85 c0                	test   %eax,%eax
8010a7e3:	74 3d                	je     8010a822 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a7e5:	83 ec 0c             	sub    $0xc,%esp
8010a7e8:	6a 00                	push   $0x0
8010a7ea:	6a 12                	push   $0x12
8010a7ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a7ef:	50                   	push   %eax
8010a7f0:	ff 75 e8             	push   -0x18(%ebp)
8010a7f3:	ff 75 08             	push   0x8(%ebp)
8010a7f6:	e8 a2 01 00 00       	call   8010a99d <tcp_pkt_create>
8010a7fb:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a7fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a801:	83 ec 08             	sub    $0x8,%esp
8010a804:	50                   	push   %eax
8010a805:	ff 75 e8             	push   -0x18(%ebp)
8010a808:	e8 ff f0 ff ff       	call   8010990c <i8254_send>
8010a80d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a810:	a1 64 d3 18 80       	mov    0x8018d364,%eax
8010a815:	83 c0 01             	add    $0x1,%eax
8010a818:	a3 64 d3 18 80       	mov    %eax,0x8018d364
8010a81d:	e9 69 01 00 00       	jmp    8010a98b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a822:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a825:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a829:	3c 18                	cmp    $0x18,%al
8010a82b:	0f 85 10 01 00 00    	jne    8010a941 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a831:	83 ec 04             	sub    $0x4,%esp
8010a834:	6a 03                	push   $0x3
8010a836:	68 3e cf 10 80       	push   $0x8010cf3e
8010a83b:	ff 75 ec             	push   -0x14(%ebp)
8010a83e:	e8 b8 ad ff ff       	call   801055fb <memcmp>
8010a843:	83 c4 10             	add    $0x10,%esp
8010a846:	85 c0                	test   %eax,%eax
8010a848:	74 74                	je     8010a8be <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a84a:	83 ec 0c             	sub    $0xc,%esp
8010a84d:	68 42 cf 10 80       	push   $0x8010cf42
8010a852:	e8 b5 5b ff ff       	call   8010040c <cprintf>
8010a857:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a85a:	83 ec 0c             	sub    $0xc,%esp
8010a85d:	6a 00                	push   $0x0
8010a85f:	6a 10                	push   $0x10
8010a861:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a864:	50                   	push   %eax
8010a865:	ff 75 e8             	push   -0x18(%ebp)
8010a868:	ff 75 08             	push   0x8(%ebp)
8010a86b:	e8 2d 01 00 00       	call   8010a99d <tcp_pkt_create>
8010a870:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a873:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a876:	83 ec 08             	sub    $0x8,%esp
8010a879:	50                   	push   %eax
8010a87a:	ff 75 e8             	push   -0x18(%ebp)
8010a87d:	e8 8a f0 ff ff       	call   8010990c <i8254_send>
8010a882:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a885:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a888:	83 c0 36             	add    $0x36,%eax
8010a88b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a88e:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a891:	50                   	push   %eax
8010a892:	ff 75 e0             	push   -0x20(%ebp)
8010a895:	6a 00                	push   $0x0
8010a897:	6a 00                	push   $0x0
8010a899:	e8 66 04 00 00       	call   8010ad04 <http_proc>
8010a89e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a8a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a8a4:	83 ec 0c             	sub    $0xc,%esp
8010a8a7:	50                   	push   %eax
8010a8a8:	6a 18                	push   $0x18
8010a8aa:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a8ad:	50                   	push   %eax
8010a8ae:	ff 75 e8             	push   -0x18(%ebp)
8010a8b1:	ff 75 08             	push   0x8(%ebp)
8010a8b4:	e8 e4 00 00 00       	call   8010a99d <tcp_pkt_create>
8010a8b9:	83 c4 20             	add    $0x20,%esp
8010a8bc:	eb 62                	jmp    8010a920 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a8be:	83 ec 0c             	sub    $0xc,%esp
8010a8c1:	6a 00                	push   $0x0
8010a8c3:	6a 10                	push   $0x10
8010a8c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a8c8:	50                   	push   %eax
8010a8c9:	ff 75 e8             	push   -0x18(%ebp)
8010a8cc:	ff 75 08             	push   0x8(%ebp)
8010a8cf:	e8 c9 00 00 00       	call   8010a99d <tcp_pkt_create>
8010a8d4:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a8d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8da:	83 ec 08             	sub    $0x8,%esp
8010a8dd:	50                   	push   %eax
8010a8de:	ff 75 e8             	push   -0x18(%ebp)
8010a8e1:	e8 26 f0 ff ff       	call   8010990c <i8254_send>
8010a8e6:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a8e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8ec:	83 c0 36             	add    $0x36,%eax
8010a8ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a8f2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8f5:	50                   	push   %eax
8010a8f6:	ff 75 e4             	push   -0x1c(%ebp)
8010a8f9:	6a 00                	push   $0x0
8010a8fb:	6a 00                	push   $0x0
8010a8fd:	e8 02 04 00 00       	call   8010ad04 <http_proc>
8010a902:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a905:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a908:	83 ec 0c             	sub    $0xc,%esp
8010a90b:	50                   	push   %eax
8010a90c:	6a 18                	push   $0x18
8010a90e:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a911:	50                   	push   %eax
8010a912:	ff 75 e8             	push   -0x18(%ebp)
8010a915:	ff 75 08             	push   0x8(%ebp)
8010a918:	e8 80 00 00 00       	call   8010a99d <tcp_pkt_create>
8010a91d:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a920:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a923:	83 ec 08             	sub    $0x8,%esp
8010a926:	50                   	push   %eax
8010a927:	ff 75 e8             	push   -0x18(%ebp)
8010a92a:	e8 dd ef ff ff       	call   8010990c <i8254_send>
8010a92f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a932:	a1 64 d3 18 80       	mov    0x8018d364,%eax
8010a937:	83 c0 01             	add    $0x1,%eax
8010a93a:	a3 64 d3 18 80       	mov    %eax,0x8018d364
8010a93f:	eb 4a                	jmp    8010a98b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a941:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a944:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a948:	3c 10                	cmp    $0x10,%al
8010a94a:	75 3f                	jne    8010a98b <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a94c:	a1 68 d3 18 80       	mov    0x8018d368,%eax
8010a951:	83 f8 01             	cmp    $0x1,%eax
8010a954:	75 35                	jne    8010a98b <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a956:	83 ec 0c             	sub    $0xc,%esp
8010a959:	6a 00                	push   $0x0
8010a95b:	6a 01                	push   $0x1
8010a95d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a960:	50                   	push   %eax
8010a961:	ff 75 e8             	push   -0x18(%ebp)
8010a964:	ff 75 08             	push   0x8(%ebp)
8010a967:	e8 31 00 00 00       	call   8010a99d <tcp_pkt_create>
8010a96c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a96f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a972:	83 ec 08             	sub    $0x8,%esp
8010a975:	50                   	push   %eax
8010a976:	ff 75 e8             	push   -0x18(%ebp)
8010a979:	e8 8e ef ff ff       	call   8010990c <i8254_send>
8010a97e:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a981:	c7 05 68 d3 18 80 00 	movl   $0x0,0x8018d368
8010a988:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a98b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a98e:	83 ec 0c             	sub    $0xc,%esp
8010a991:	50                   	push   %eax
8010a992:	e8 5d 7e ff ff       	call   801027f4 <kfree>
8010a997:	83 c4 10             	add    $0x10,%esp
}
8010a99a:	90                   	nop
8010a99b:	c9                   	leave
8010a99c:	c3                   	ret

8010a99d <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a99d:	f3 0f 1e fb          	endbr32
8010a9a1:	55                   	push   %ebp
8010a9a2:	89 e5                	mov    %esp,%ebp
8010a9a4:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a9a7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a9ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9b0:	83 c0 0e             	add    $0xe,%eax
8010a9b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a9b9:	0f b6 00             	movzbl (%eax),%eax
8010a9bc:	0f b6 c0             	movzbl %al,%eax
8010a9bf:	83 e0 0f             	and    $0xf,%eax
8010a9c2:	c1 e0 02             	shl    $0x2,%eax
8010a9c5:	89 c2                	mov    %eax,%edx
8010a9c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a9ca:	01 d0                	add    %edx,%eax
8010a9cc:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a9cf:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a9d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a9d5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a9d8:	83 c0 0e             	add    $0xe,%eax
8010a9db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a9de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9e1:	83 c0 14             	add    $0x14,%eax
8010a9e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a9e7:	8b 45 18             	mov    0x18(%ebp),%eax
8010a9ea:	8d 50 36             	lea    0x36(%eax),%edx
8010a9ed:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9f0:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9f5:	8d 50 06             	lea    0x6(%eax),%edx
8010a9f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a9fb:	83 ec 04             	sub    $0x4,%esp
8010a9fe:	6a 06                	push   $0x6
8010aa00:	52                   	push   %edx
8010aa01:	50                   	push   %eax
8010aa02:	e8 50 ac ff ff       	call   80105657 <memmove>
8010aa07:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010aa0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa0d:	83 c0 06             	add    $0x6,%eax
8010aa10:	83 ec 04             	sub    $0x4,%esp
8010aa13:	6a 06                	push   $0x6
8010aa15:	68 88 d0 18 80       	push   $0x8018d088
8010aa1a:	50                   	push   %eax
8010aa1b:	e8 37 ac ff ff       	call   80105657 <memmove>
8010aa20:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010aa23:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa26:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010aa2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa2d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010aa31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa34:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010aa37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa3a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010aa3e:	8b 45 18             	mov    0x18(%ebp),%eax
8010aa41:	83 c0 28             	add    $0x28,%eax
8010aa44:	0f b7 c0             	movzwl %ax,%eax
8010aa47:	83 ec 0c             	sub    $0xc,%esp
8010aa4a:	50                   	push   %eax
8010aa4b:	e8 6f f8 ff ff       	call   8010a2bf <H2N_ushort>
8010aa50:	83 c4 10             	add    $0x10,%esp
8010aa53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aa56:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010aa5a:	0f b7 15 60 d3 18 80 	movzwl 0x8018d360,%edx
8010aa61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa64:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010aa68:	0f b7 05 60 d3 18 80 	movzwl 0x8018d360,%eax
8010aa6f:	83 c0 01             	add    $0x1,%eax
8010aa72:	66 a3 60 d3 18 80    	mov    %ax,0x8018d360
  ipv4_send->fragment = H2N_ushort(0x0000);
8010aa78:	83 ec 0c             	sub    $0xc,%esp
8010aa7b:	6a 00                	push   $0x0
8010aa7d:	e8 3d f8 ff ff       	call   8010a2bf <H2N_ushort>
8010aa82:	83 c4 10             	add    $0x10,%esp
8010aa85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aa88:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010aa8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa8f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010aa93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa96:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010aa9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa9d:	83 c0 0c             	add    $0xc,%eax
8010aaa0:	83 ec 04             	sub    $0x4,%esp
8010aaa3:	6a 04                	push   $0x4
8010aaa5:	68 04 f5 10 80       	push   $0x8010f504
8010aaaa:	50                   	push   %eax
8010aaab:	e8 a7 ab ff ff       	call   80105657 <memmove>
8010aab0:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010aab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aab6:	8d 50 0c             	lea    0xc(%eax),%edx
8010aab9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aabc:	83 c0 10             	add    $0x10,%eax
8010aabf:	83 ec 04             	sub    $0x4,%esp
8010aac2:	6a 04                	push   $0x4
8010aac4:	52                   	push   %edx
8010aac5:	50                   	push   %eax
8010aac6:	e8 8c ab ff ff       	call   80105657 <memmove>
8010aacb:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010aace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aad1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010aad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aada:	83 ec 0c             	sub    $0xc,%esp
8010aadd:	50                   	push   %eax
8010aade:	e8 ec f8 ff ff       	call   8010a3cf <ipv4_chksum>
8010aae3:	83 c4 10             	add    $0x10,%esp
8010aae6:	0f b7 c0             	movzwl %ax,%eax
8010aae9:	83 ec 0c             	sub    $0xc,%esp
8010aaec:	50                   	push   %eax
8010aaed:	e8 cd f7 ff ff       	call   8010a2bf <H2N_ushort>
8010aaf2:	83 c4 10             	add    $0x10,%esp
8010aaf5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aaf8:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010aafc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aaff:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010ab03:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab06:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010ab09:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab0c:	0f b7 10             	movzwl (%eax),%edx
8010ab0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab12:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010ab16:	a1 64 d3 18 80       	mov    0x8018d364,%eax
8010ab1b:	83 ec 0c             	sub    $0xc,%esp
8010ab1e:	50                   	push   %eax
8010ab1f:	e8 c1 f7 ff ff       	call   8010a2e5 <H2N_uint>
8010ab24:	83 c4 10             	add    $0x10,%esp
8010ab27:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ab2a:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010ab2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab30:	8b 40 04             	mov    0x4(%eax),%eax
8010ab33:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010ab39:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab3c:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010ab3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab42:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010ab46:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab49:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010ab4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab50:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010ab54:	8b 45 14             	mov    0x14(%ebp),%eax
8010ab57:	89 c2                	mov    %eax,%edx
8010ab59:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab5c:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010ab5f:	83 ec 0c             	sub    $0xc,%esp
8010ab62:	68 90 38 00 00       	push   $0x3890
8010ab67:	e8 53 f7 ff ff       	call   8010a2bf <H2N_ushort>
8010ab6c:	83 c4 10             	add    $0x10,%esp
8010ab6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ab72:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010ab76:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab79:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010ab7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab82:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010ab88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab8b:	83 ec 0c             	sub    $0xc,%esp
8010ab8e:	50                   	push   %eax
8010ab8f:	e8 1f 00 00 00       	call   8010abb3 <tcp_chksum>
8010ab94:	83 c4 10             	add    $0x10,%esp
8010ab97:	83 c0 08             	add    $0x8,%eax
8010ab9a:	0f b7 c0             	movzwl %ax,%eax
8010ab9d:	83 ec 0c             	sub    $0xc,%esp
8010aba0:	50                   	push   %eax
8010aba1:	e8 19 f7 ff ff       	call   8010a2bf <H2N_ushort>
8010aba6:	83 c4 10             	add    $0x10,%esp
8010aba9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010abac:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010abb0:	90                   	nop
8010abb1:	c9                   	leave
8010abb2:	c3                   	ret

8010abb3 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010abb3:	f3 0f 1e fb          	endbr32
8010abb7:	55                   	push   %ebp
8010abb8:	89 e5                	mov    %esp,%ebp
8010abba:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010abbd:	8b 45 08             	mov    0x8(%ebp),%eax
8010abc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010abc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010abc6:	83 c0 14             	add    $0x14,%eax
8010abc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010abcc:	83 ec 04             	sub    $0x4,%esp
8010abcf:	6a 04                	push   $0x4
8010abd1:	68 04 f5 10 80       	push   $0x8010f504
8010abd6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010abd9:	50                   	push   %eax
8010abda:	e8 78 aa ff ff       	call   80105657 <memmove>
8010abdf:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010abe2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010abe5:	83 c0 0c             	add    $0xc,%eax
8010abe8:	83 ec 04             	sub    $0x4,%esp
8010abeb:	6a 04                	push   $0x4
8010abed:	50                   	push   %eax
8010abee:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010abf1:	83 c0 04             	add    $0x4,%eax
8010abf4:	50                   	push   %eax
8010abf5:	e8 5d aa ff ff       	call   80105657 <memmove>
8010abfa:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010abfd:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010ac01:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010ac05:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ac08:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010ac0c:	0f b7 c0             	movzwl %ax,%eax
8010ac0f:	83 ec 0c             	sub    $0xc,%esp
8010ac12:	50                   	push   %eax
8010ac13:	e8 81 f6 ff ff       	call   8010a299 <N2H_ushort>
8010ac18:	83 c4 10             	add    $0x10,%esp
8010ac1b:	83 e8 14             	sub    $0x14,%eax
8010ac1e:	0f b7 c0             	movzwl %ax,%eax
8010ac21:	83 ec 0c             	sub    $0xc,%esp
8010ac24:	50                   	push   %eax
8010ac25:	e8 95 f6 ff ff       	call   8010a2bf <H2N_ushort>
8010ac2a:	83 c4 10             	add    $0x10,%esp
8010ac2d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010ac31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010ac38:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ac3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010ac3e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010ac45:	eb 33                	jmp    8010ac7a <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ac47:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ac4a:	01 c0                	add    %eax,%eax
8010ac4c:	89 c2                	mov    %eax,%edx
8010ac4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac51:	01 d0                	add    %edx,%eax
8010ac53:	0f b6 00             	movzbl (%eax),%eax
8010ac56:	0f b6 c0             	movzbl %al,%eax
8010ac59:	c1 e0 08             	shl    $0x8,%eax
8010ac5c:	89 c2                	mov    %eax,%edx
8010ac5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ac61:	01 c0                	add    %eax,%eax
8010ac63:	8d 48 01             	lea    0x1(%eax),%ecx
8010ac66:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac69:	01 c8                	add    %ecx,%eax
8010ac6b:	0f b6 00             	movzbl (%eax),%eax
8010ac6e:	0f b6 c0             	movzbl %al,%eax
8010ac71:	01 d0                	add    %edx,%eax
8010ac73:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010ac76:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ac7a:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ac7e:	7e c7                	jle    8010ac47 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ac80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ac83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ac86:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ac8d:	eb 33                	jmp    8010acc2 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ac8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ac92:	01 c0                	add    %eax,%eax
8010ac94:	89 c2                	mov    %eax,%edx
8010ac96:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac99:	01 d0                	add    %edx,%eax
8010ac9b:	0f b6 00             	movzbl (%eax),%eax
8010ac9e:	0f b6 c0             	movzbl %al,%eax
8010aca1:	c1 e0 08             	shl    $0x8,%eax
8010aca4:	89 c2                	mov    %eax,%edx
8010aca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aca9:	01 c0                	add    %eax,%eax
8010acab:	8d 48 01             	lea    0x1(%eax),%ecx
8010acae:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010acb1:	01 c8                	add    %ecx,%eax
8010acb3:	0f b6 00             	movzbl (%eax),%eax
8010acb6:	0f b6 c0             	movzbl %al,%eax
8010acb9:	01 d0                	add    %edx,%eax
8010acbb:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010acbe:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010acc2:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010acc6:	0f b7 c0             	movzwl %ax,%eax
8010acc9:	83 ec 0c             	sub    $0xc,%esp
8010accc:	50                   	push   %eax
8010accd:	e8 c7 f5 ff ff       	call   8010a299 <N2H_ushort>
8010acd2:	83 c4 10             	add    $0x10,%esp
8010acd5:	66 d1 e8             	shr    $1,%ax
8010acd8:	0f b7 c0             	movzwl %ax,%eax
8010acdb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010acde:	7c af                	jl     8010ac8f <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010ace0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ace3:	c1 e8 10             	shr    $0x10,%eax
8010ace6:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010ace9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010acec:	f7 d0                	not    %eax
}
8010acee:	c9                   	leave
8010acef:	c3                   	ret

8010acf0 <tcp_fin>:

void tcp_fin(){
8010acf0:	f3 0f 1e fb          	endbr32
8010acf4:	55                   	push   %ebp
8010acf5:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010acf7:	c7 05 68 d3 18 80 01 	movl   $0x1,0x8018d368
8010acfe:	00 00 00 
}
8010ad01:	90                   	nop
8010ad02:	5d                   	pop    %ebp
8010ad03:	c3                   	ret

8010ad04 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010ad04:	f3 0f 1e fb          	endbr32
8010ad08:	55                   	push   %ebp
8010ad09:	89 e5                	mov    %esp,%ebp
8010ad0b:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010ad0e:	8b 45 10             	mov    0x10(%ebp),%eax
8010ad11:	83 ec 04             	sub    $0x4,%esp
8010ad14:	6a 00                	push   $0x0
8010ad16:	68 4b cf 10 80       	push   $0x8010cf4b
8010ad1b:	50                   	push   %eax
8010ad1c:	e8 65 00 00 00       	call   8010ad86 <http_strcpy>
8010ad21:	83 c4 10             	add    $0x10,%esp
8010ad24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010ad27:	8b 45 10             	mov    0x10(%ebp),%eax
8010ad2a:	83 ec 04             	sub    $0x4,%esp
8010ad2d:	ff 75 f4             	push   -0xc(%ebp)
8010ad30:	68 5e cf 10 80       	push   $0x8010cf5e
8010ad35:	50                   	push   %eax
8010ad36:	e8 4b 00 00 00       	call   8010ad86 <http_strcpy>
8010ad3b:	83 c4 10             	add    $0x10,%esp
8010ad3e:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010ad41:	8b 45 10             	mov    0x10(%ebp),%eax
8010ad44:	83 ec 04             	sub    $0x4,%esp
8010ad47:	ff 75 f4             	push   -0xc(%ebp)
8010ad4a:	68 79 cf 10 80       	push   $0x8010cf79
8010ad4f:	50                   	push   %eax
8010ad50:	e8 31 00 00 00       	call   8010ad86 <http_strcpy>
8010ad55:	83 c4 10             	add    $0x10,%esp
8010ad58:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ad5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ad5e:	83 e0 01             	and    $0x1,%eax
8010ad61:	85 c0                	test   %eax,%eax
8010ad63:	74 11                	je     8010ad76 <http_proc+0x72>
    char *payload = (char *)send;
8010ad65:	8b 45 10             	mov    0x10(%ebp),%eax
8010ad68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010ad6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ad6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ad71:	01 d0                	add    %edx,%eax
8010ad73:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010ad76:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ad79:	8b 45 14             	mov    0x14(%ebp),%eax
8010ad7c:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ad7e:	e8 6d ff ff ff       	call   8010acf0 <tcp_fin>
}
8010ad83:	90                   	nop
8010ad84:	c9                   	leave
8010ad85:	c3                   	ret

8010ad86 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ad86:	f3 0f 1e fb          	endbr32
8010ad8a:	55                   	push   %ebp
8010ad8b:	89 e5                	mov    %esp,%ebp
8010ad8d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ad90:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ad97:	eb 20                	jmp    8010adb9 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ad99:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ad9c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ad9f:	01 d0                	add    %edx,%eax
8010ada1:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ada4:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ada7:	01 ca                	add    %ecx,%edx
8010ada9:	89 d1                	mov    %edx,%ecx
8010adab:	8b 55 08             	mov    0x8(%ebp),%edx
8010adae:	01 ca                	add    %ecx,%edx
8010adb0:	0f b6 00             	movzbl (%eax),%eax
8010adb3:	88 02                	mov    %al,(%edx)
    i++;
8010adb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010adb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010adbc:	8b 45 0c             	mov    0xc(%ebp),%eax
8010adbf:	01 d0                	add    %edx,%eax
8010adc1:	0f b6 00             	movzbl (%eax),%eax
8010adc4:	84 c0                	test   %al,%al
8010adc6:	75 d1                	jne    8010ad99 <http_strcpy+0x13>
  }
  return i;
8010adc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010adcb:	c9                   	leave
8010adcc:	c3                   	ret

8010adcd <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010adcd:	f3 0f 1e fb          	endbr32
8010add1:	55                   	push   %ebp
8010add2:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010add4:	c7 05 70 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d370
8010addb:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010adde:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010ade3:	c1 e8 09             	shr    $0x9,%eax
8010ade6:	a3 6c d3 18 80       	mov    %eax,0x8018d36c
}
8010adeb:	90                   	nop
8010adec:	5d                   	pop    %ebp
8010aded:	c3                   	ret

8010adee <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010adee:	f3 0f 1e fb          	endbr32
8010adf2:	55                   	push   %ebp
8010adf3:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010adf5:	90                   	nop
8010adf6:	5d                   	pop    %ebp
8010adf7:	c3                   	ret

8010adf8 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010adf8:	f3 0f 1e fb          	endbr32
8010adfc:	55                   	push   %ebp
8010adfd:	89 e5                	mov    %esp,%ebp
8010adff:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010ae02:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae05:	83 c0 0c             	add    $0xc,%eax
8010ae08:	83 ec 0c             	sub    $0xc,%esp
8010ae0b:	50                   	push   %eax
8010ae0c:	e8 57 a4 ff ff       	call   80105268 <holdingsleep>
8010ae11:	83 c4 10             	add    $0x10,%esp
8010ae14:	85 c0                	test   %eax,%eax
8010ae16:	75 0d                	jne    8010ae25 <iderw+0x2d>
    panic("iderw: buf not locked");
8010ae18:	83 ec 0c             	sub    $0xc,%esp
8010ae1b:	68 8a cf 10 80       	push   $0x8010cf8a
8010ae20:	e8 a0 57 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010ae25:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae28:	8b 00                	mov    (%eax),%eax
8010ae2a:	83 e0 06             	and    $0x6,%eax
8010ae2d:	83 f8 02             	cmp    $0x2,%eax
8010ae30:	75 0d                	jne    8010ae3f <iderw+0x47>
    panic("iderw: nothing to do");
8010ae32:	83 ec 0c             	sub    $0xc,%esp
8010ae35:	68 a0 cf 10 80       	push   $0x8010cfa0
8010ae3a:	e8 86 57 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010ae3f:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae42:	8b 40 04             	mov    0x4(%eax),%eax
8010ae45:	83 f8 01             	cmp    $0x1,%eax
8010ae48:	74 0d                	je     8010ae57 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010ae4a:	83 ec 0c             	sub    $0xc,%esp
8010ae4d:	68 b5 cf 10 80       	push   $0x8010cfb5
8010ae52:	e8 6e 57 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010ae57:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae5a:	8b 40 08             	mov    0x8(%eax),%eax
8010ae5d:	8b 15 6c d3 18 80    	mov    0x8018d36c,%edx
8010ae63:	39 d0                	cmp    %edx,%eax
8010ae65:	72 0d                	jb     8010ae74 <iderw+0x7c>
    panic("iderw: block out of range");
8010ae67:	83 ec 0c             	sub    $0xc,%esp
8010ae6a:	68 d3 cf 10 80       	push   $0x8010cfd3
8010ae6f:	e8 51 57 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010ae74:	8b 15 70 d3 18 80    	mov    0x8018d370,%edx
8010ae7a:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae7d:	8b 40 08             	mov    0x8(%eax),%eax
8010ae80:	c1 e0 09             	shl    $0x9,%eax
8010ae83:	01 d0                	add    %edx,%eax
8010ae85:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010ae88:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae8b:	8b 00                	mov    (%eax),%eax
8010ae8d:	83 e0 04             	and    $0x4,%eax
8010ae90:	85 c0                	test   %eax,%eax
8010ae92:	74 2b                	je     8010aebf <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010ae94:	8b 45 08             	mov    0x8(%ebp),%eax
8010ae97:	8b 00                	mov    (%eax),%eax
8010ae99:	83 e0 fb             	and    $0xfffffffb,%eax
8010ae9c:	89 c2                	mov    %eax,%edx
8010ae9e:	8b 45 08             	mov    0x8(%ebp),%eax
8010aea1:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010aea3:	8b 45 08             	mov    0x8(%ebp),%eax
8010aea6:	83 c0 5c             	add    $0x5c,%eax
8010aea9:	83 ec 04             	sub    $0x4,%esp
8010aeac:	68 00 02 00 00       	push   $0x200
8010aeb1:	50                   	push   %eax
8010aeb2:	ff 75 f4             	push   -0xc(%ebp)
8010aeb5:	e8 9d a7 ff ff       	call   80105657 <memmove>
8010aeba:	83 c4 10             	add    $0x10,%esp
8010aebd:	eb 1a                	jmp    8010aed9 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010aebf:	8b 45 08             	mov    0x8(%ebp),%eax
8010aec2:	83 c0 5c             	add    $0x5c,%eax
8010aec5:	83 ec 04             	sub    $0x4,%esp
8010aec8:	68 00 02 00 00       	push   $0x200
8010aecd:	ff 75 f4             	push   -0xc(%ebp)
8010aed0:	50                   	push   %eax
8010aed1:	e8 81 a7 ff ff       	call   80105657 <memmove>
8010aed6:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010aed9:	8b 45 08             	mov    0x8(%ebp),%eax
8010aedc:	8b 00                	mov    (%eax),%eax
8010aede:	83 c8 02             	or     $0x2,%eax
8010aee1:	89 c2                	mov    %eax,%edx
8010aee3:	8b 45 08             	mov    0x8(%ebp),%eax
8010aee6:	89 10                	mov    %edx,(%eax)
}
8010aee8:	90                   	nop
8010aee9:	c9                   	leave
8010aeea:	c3                   	ret
