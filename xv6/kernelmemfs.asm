
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
8010005a:	bc 80 81 19 80       	mov    $0x80198180,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 67 33 10 80       	mov    $0x80103367,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 00 a0 10 80       	push   $0x8010a000
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 8a 46 00 00       	call   80104708 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 07 a0 10 80       	push   $0x8010a007
801000c2:	50                   	push   %eax
801000c3:	e8 e3 44 00 00       	call   801045ab <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 24 46 00 00       	call   8010472a <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 53 46 00 00       	call   80104798 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 90 44 00 00       	call   801045e7 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 d2 45 00 00       	call   80104798 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 0f 44 00 00       	call   801045e7 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 0e a0 10 80       	push   $0x8010a00e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 d1 9c 00 00       	call   80109f03 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 4a 44 00 00       	call   80104699 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a0 10 80       	push   $0x8010a01f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 86 9c 00 00       	call   80109f03 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 01 44 00 00       	call   80104699 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a0 10 80       	push   $0x8010a026
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 90 43 00 00       	call   8010464b <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 5f 44 00 00       	call   8010472a <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 5d 44 00 00       	call   80104798 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8b 03 00 00       	call   8010076e <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 15 43 00 00       	call   8010472a <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a0 10 80       	push   $0x8010a02d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 1f 03 00 00       	call   8010076e <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 36 a0 10 80 	movl   $0x8010a036,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 43 02 00 00       	call   8010076e <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 26 02 00 00       	call   8010076e <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 17 02 00 00       	call   8010076e <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 09 02 00 00       	call   8010076e <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 f5 41 00 00       	call   80104798 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave
801005a8:	c3                   	ret

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 39 25 00 00       	call   80102afc <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 3d a0 10 80       	push   $0x8010a03d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 51 a0 10 80       	push   $0x8010a051
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 e7 41 00 00       	call   801047ea <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a0 10 80       	push   $0x8010a053
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	90                   	nop
8010063c:	eb fd                	jmp    8010063b <panic+0x92>

8010063e <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063e:	55                   	push   %ebp
8010063f:	89 e5                	mov    %esp,%ebp
80100641:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 64                	jne    801006ae <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010064a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100650:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	f7 ea                	imul   %edx
80100659:	89 d0                	mov    %edx,%eax
8010065b:	c1 f8 04             	sar    $0x4,%eax
8010065e:	89 ca                	mov    %ecx,%edx
80100660:	c1 fa 1f             	sar    $0x1f,%edx
80100663:	29 d0                	sub    %edx,%eax
80100665:	6b d0 35             	imul   $0x35,%eax,%edx
80100668:	89 c8                	mov    %ecx,%eax
8010066a:	29 d0                	sub    %edx,%eax
8010066c:	ba 35 00 00 00       	mov    $0x35,%edx
80100671:	29 c2                	sub    %eax,%edx
80100673:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 ca 77 00 00       	call   80107e70 <graphic_scroll_up>
801006a6:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a9:	e9 bd 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006ae:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b5:	75 1f                	jne    801006d6 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 77 77 00 00       	call   80107e70 <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100702:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	f7 ea                	imul   %edx
8010070b:	89 d0                	mov    %edx,%eax
8010070d:	c1 f8 04             	sar    $0x4,%eax
80100710:	89 ca                	mov    %ecx,%edx
80100712:	c1 fa 1f             	sar    $0x1f,%edx
80100715:	29 d0                	sub    %edx,%eax
80100717:	6b d0 35             	imul   $0x35,%eax,%edx
8010071a:	89 c8                	mov    %ecx,%eax
8010071c:	29 d0                	sub    %edx,%eax
8010071e:	89 c2                	mov    %eax,%edx
80100720:	c1 e2 04             	shl    $0x4,%edx
80100723:	29 c2                	sub    %eax,%edx
80100725:	8d 42 02             	lea    0x2(%edx),%eax
80100728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072b:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100731:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100736:	89 c8                	mov    %ecx,%eax
80100738:	f7 ea                	imul   %edx
8010073a:	c1 fa 04             	sar    $0x4,%edx
8010073d:	89 c8                	mov    %ecx,%eax
8010073f:	c1 f8 1f             	sar    $0x1f,%eax
80100742:	29 c2                	sub    %eax,%edx
80100744:	6b c2 1e             	imul   $0x1e,%edx,%eax
80100747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074a:	83 ec 04             	sub    $0x4,%esp
8010074d:	ff 75 08             	push   0x8(%ebp)
80100750:	ff 75 f0             	push   -0x10(%ebp)
80100753:	ff 75 f4             	push   -0xc(%ebp)
80100756:	e8 82 77 00 00       	call   80107edd <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076b:	90                   	nop
8010076c:	c9                   	leave
8010076d:	c3                   	ret

8010076e <consputc>:


void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100774:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 08                	je     80100785 <consputc+0x17>
    cli();
8010077d:	e8 bf fb ff ff       	call   80100341 <cli>
    for(;;)
80100782:	90                   	nop
80100783:	eb fd                	jmp    80100782 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 51 5b 00 00       	call   801062e9 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 44 5b 00 00       	call   801062e9 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 37 5b 00 00       	call   801062e9 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 27 5b 00 00       	call   801062e9 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6e fe ff ff       	call   8010063e <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave
801007d5:	c3                   	ret

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 3a 3f 00 00       	call   8010472a <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 58 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 18 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 be fe ff ff       	call   8010076e <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 94 00 00 00       	jmp    8010094c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 8d 00 00 00    	je     8010094f <consoleintr+0x179>
801008c2:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008c8:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008cd:	29 c2                	sub    %eax,%edx
801008cf:	83 fa 7f             	cmp    $0x7f,%edx
801008d2:	77 7b                	ja     8010094f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 62 fe ff ff       	call   8010076e <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100921:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 ac 3a 00 00       	call   801043f0 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	eb 06                	jmp    8010094f <consoleintr+0x179>
      break;
80100949:	90                   	nop
8010094a:	eb 04                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094c:	90                   	nop
8010094d:	eb 01                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094f:	90                   	nop
  while((c = getc()) >= 0){
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	ff d0                	call   *%eax
80100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095c:	0f 89 96 fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100962:	83 ec 0c             	sub    $0xc,%esp
80100965:	68 00 1a 19 80       	push   $0x80191a00
8010096a:	e8 29 3e 00 00       	call   80104798 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 31 3b 00 00       	call   801044ae <procdump>
  }
}
8010097d:	90                   	nop
8010097e:	c9                   	leave
8010097f:	c3                   	ret

80100980 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100980:	55                   	push   %ebp
80100981:	89 e5                	mov    %esp,%ebp
80100983:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 08             	push   0x8(%ebp)
8010098c:	e8 74 11 00 00       	call   80101b05 <iunlock>
80100991:	83 c4 10             	add    $0x10,%esp
  target = n;
80100994:	8b 45 10             	mov    0x10(%ebp),%eax
80100997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010099a:	83 ec 0c             	sub    $0xc,%esp
8010099d:	68 00 1a 19 80       	push   $0x80191a00
801009a2:	e8 83 3d 00 00       	call   8010472a <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 7c 30 00 00       	call   80103a30 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 1a 19 80       	push   $0x80191a00
801009c3:	e8 d0 3d 00 00       	call   80104798 <release>
801009c8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 1c 10 00 00       	call   801019f2 <ilock>
801009d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009de:	e9 ab 00 00 00       	jmp    80100a8e <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009e3:	83 ec 08             	sub    $0x8,%esp
801009e6:	68 00 1a 19 80       	push   $0x80191a00
801009eb:	68 e0 19 19 80       	push   $0x801919e0
801009f0:	e8 11 39 00 00       	call   80104306 <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009fe:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a1f:	0f be c0             	movsbl %al,%eax
80100a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a25:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a29:	75 17                	jne    80100a42 <consoleread+0xc2>
      if(n < target){
80100a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a31:	73 2f                	jae    80100a62 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a33:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a40:	eb 20                	jmp    80100a62 <consoleread+0xe2>
    }
    *dst++ = c;
80100a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a45:	8d 50 01             	lea    0x1(%eax),%edx
80100a48:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a4e:	88 10                	mov    %dl,(%eax)
    --n;
80100a50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a54:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a58:	74 0b                	je     80100a65 <consoleread+0xe5>
  while(n > 0){
80100a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a5e:	7f 98                	jg     801009f8 <consoleread+0x78>
80100a60:	eb 04                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a62:	90                   	nop
80100a63:	eb 01                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a65:	90                   	nop
  }
  release(&cons.lock);
80100a66:	83 ec 0c             	sub    $0xc,%esp
80100a69:	68 00 1a 19 80       	push   $0x80191a00
80100a6e:	e8 25 3d 00 00       	call   80104798 <release>
80100a73:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	push   0x8(%ebp)
80100a7c:	e8 71 0f 00 00       	call   801019f2 <ilock>
80100a81:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a84:	8b 45 10             	mov    0x10(%ebp),%eax
80100a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8a:	29 c2                	sub    %eax,%edx
80100a8c:	89 d0                	mov    %edx,%eax
}
80100a8e:	c9                   	leave
80100a8f:	c3                   	ret

80100a90 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a96:	83 ec 0c             	sub    $0xc,%esp
80100a99:	ff 75 08             	push   0x8(%ebp)
80100a9c:	e8 64 10 00 00       	call   80101b05 <iunlock>
80100aa1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	68 00 1a 19 80       	push   $0x80191a00
80100aac:	e8 79 3c 00 00       	call   8010472a <acquire>
80100ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100abb:	eb 21                	jmp    80100ade <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ac3:	01 d0                	add    %edx,%eax
80100ac5:	0f b6 00             	movzbl (%eax),%eax
80100ac8:	0f be c0             	movsbl %al,%eax
80100acb:	0f b6 c0             	movzbl %al,%eax
80100ace:	83 ec 0c             	sub    $0xc,%esp
80100ad1:	50                   	push   %eax
80100ad2:	e8 97 fc ff ff       	call   8010076e <consputc>
80100ad7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ae4:	7c d7                	jl     80100abd <consolewrite+0x2d>
  release(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 00 1a 19 80       	push   $0x80191a00
80100aee:	e8 a5 3c 00 00       	call   80104798 <release>
80100af3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	ff 75 08             	push   0x8(%ebp)
80100afc:	e8 f1 0e 00 00       	call   801019f2 <ilock>
80100b01:	83 c4 10             	add    $0x10,%esp

  return n;
80100b04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b07:	c9                   	leave
80100b08:	c3                   	ret

80100b09 <consoleinit>:

void
consoleinit(void)
{
80100b09:	55                   	push   %ebp
80100b0a:	89 e5                	mov    %esp,%ebp
80100b0c:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b0f:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 57 a0 10 80       	push   $0x8010a057
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 dd 3b 00 00       	call   80104708 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 5f a0 10 80 	movl   $0x8010a05f,-0xc(%ebp)
80100b49:	eb 19                	jmp    80100b64 <consoleinit+0x5b>
    graphic_putc(*p);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 00             	movzbl (%eax),%eax
80100b51:	0f be c0             	movsbl %al,%eax
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	50                   	push   %eax
80100b58:	e8 e1 fa ff ff       	call   8010063e <graphic_putc>
80100b5d:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b67:	0f b6 00             	movzbl (%eax),%eax
80100b6a:	84 c0                	test   %al,%al
80100b6c:	75 dd                	jne    80100b4b <consoleinit+0x42>
  
  cons.locking = 1;
80100b6e:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 b2 1a 00 00       	call   80102636 <ioapicenable>
80100b84:	83 c4 10             	add    $0x10,%esp
}
80100b87:	90                   	nop
80100b88:	c9                   	leave
80100b89:	c3                   	ret

80100b8a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b8a:	55                   	push   %ebp
80100b8b:	89 e5                	mov    %esp,%ebp
80100b8d:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b93:	e8 98 2e 00 00       	call   80103a30 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 9e 24 00 00       	call   8010303e <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 0e 25 00 00       	call   801030ca <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 75 a0 10 80       	push   $0x8010a075
80100bc4:	e8 2b f8 ff ff       	call   801003f4 <cprintf>
80100bc9:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 f1 03 00 00       	jmp    80100fc7 <exec+0x43d>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 11 0e 00 00       	call   801019f2 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 e0 12 00 00       	call   80101ede <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 34             	cmp    $0x34,%eax
80100c04:	0f 85 66 03 00 00    	jne    80100f70 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 58 03 00 00    	jne    80100f73 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 c5 66 00 00       	call   801072e5 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 49 03 00 00    	je     80100f76 <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 de 00 00 00       	jmp    80100d27 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 80 12 00 00       	call   80101ede <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 0f 03 00 00    	jne    80100f79 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	0f 85 a0 00 00 00    	jne    80100d19 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c79:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c7f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c85:	39 c2                	cmp    %eax,%edx
80100c87:	0f 82 ef 02 00 00    	jb     80100f7c <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c8d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c93:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c99:	01 c2                	add    %eax,%edx
80100c9b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ca1:	39 c2                	cmp    %eax,%edx
80100ca3:	0f 82 d6 02 00 00    	jb     80100f7f <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ca9:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100caf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 ec 04             	sub    $0x4,%esp
80100cba:	50                   	push   %eax
80100cbb:	ff 75 e0             	push   -0x20(%ebp)
80100cbe:	ff 75 d4             	push   -0x2c(%ebp)
80100cc1:	e8 19 6a 00 00       	call   801076df <allocuvm>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 ac 02 00 00    	je     80100f82 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cd6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cdc:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	0f 85 9c 02 00 00    	jne    80100f85 <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce9:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cef:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf5:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	52                   	push   %edx
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	push   -0x28(%ebp)
80100d03:	51                   	push   %ecx
80100d04:	ff 75 d4             	push   -0x2c(%ebp)
80100d07:	e8 06 69 00 00       	call   80107612 <loaduvm>
80100d0c:	83 c4 20             	add    $0x20,%esp
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	0f 88 71 02 00 00    	js     80100f88 <exec+0x3fe>
80100d17:	eb 01                	jmp    80100d1a <exec+0x190>
      continue;
80100d19:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d21:	83 c0 20             	add    $0x20,%eax
80100d24:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d27:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d2e:	0f b7 c0             	movzwl %ax,%eax
80100d31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d34:	0f 8c 0f ff ff ff    	jl     80100c49 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d3a:	83 ec 0c             	sub    $0xc,%esp
80100d3d:	ff 75 d8             	push   -0x28(%ebp)
80100d40:	e8 de 0e 00 00       	call   80101c23 <iunlockput>
80100d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d48:	e8 7d 23 00 00       	call   801030ca <end_op>
  ip = 0;
80100d4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 20 00 00       	add    $0x2000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 64 69 00 00       	call   801076df <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 00 02 00 00    	je     80100f8b <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	83 ec 08             	sub    $0x8,%esp
80100d96:	50                   	push   %eax
80100d97:	ff 75 d4             	push   -0x2c(%ebp)
80100d9a:	e8 a2 6b 00 00       	call   80107941 <clearpteu>
80100d9f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2c0>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 16 3e 00 00       	call   80104bee <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 e9 3d 00 00       	call   80104bee <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 b5 6c 00 00       	call   80107ae0 <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 19 6c 00 00       	call   80107ae0 <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x36d>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x369>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 8e 3c 00 00       	call   80104ba3 <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 ab 64 00 00       	call   80107403 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 42 69 00 00       	call   801078a8 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x43d>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x41f>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 02 69 00 00       	call   801078a8 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x438>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 08 21 00 00       	call   801030ca <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 81 a0 10 80       	push   $0x8010a081
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 27 37 00 00       	call   80104708 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff5:	e8 30 37 00 00       	call   8010472a <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 1a 19 80       	push   $0x80191aa0
80101022:	e8 71 37 00 00       	call   80104798 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 4e 37 00 00       	call   80104798 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 1a 19 80       	push   $0x80191aa0
80101062:	e8 c3 36 00 00       	call   8010472a <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 88 a0 10 80       	push   $0x8010a088
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 1a 19 80       	push   $0x80191aa0
80101098:	e8 fb 36 00 00       	call   80104798 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 1a 19 80       	push   $0x80191aa0
801010b3:	e8 72 36 00 00       	call   8010472a <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 90 a0 10 80       	push   $0x8010a090
801010cd:	e8 d7 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 1a 19 80       	push   $0x80191aa0
801010f3:	e8 a0 36 00 00       	call   80104798 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 1a 19 80       	push   $0x80191aa0
80101141:	e8 52 36 00 00       	call   80104798 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 5a 25 00 00       	call   801036bf <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 c7 1e 00 00       	call   8010303e <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 3f 1f 00 00       	call   801030ca <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 4e 26 00 00       	call   8010386c <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 9a a0 10 80       	push   $0x8010a09a
80101295:	e8 0f f3 ff ff       	call   801005a9 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 93 24 00 00       	call   8010376a <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 22 1d 00 00       	call   8010303e <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 48 1d 00 00       	call   801030ca <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 a3 a0 10 80       	push   $0x8010a0a3
80101398:	e8 0c f2 ff ff       	call   801005a9 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 b3 a0 10 80       	push   $0x8010a0b3
801013ce:	e8 d6 f1 ff ff       	call   801005a9 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 59 36 00 00       	call   80104a5f <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 54 35 00 00       	call   801049a0 <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 1d 1e 00 00       	call   80103277 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 24 19 80       	mov    0x80192458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 51 1d 00 00       	call   80103277 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 24 19 80       	mov    0x80192440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 24 19 80       	mov    0x80192440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 c0 a0 10 80       	push   $0x8010a0c0
801015aa:	e8 fa ef ff ff       	call   801005a9 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 24 19 80       	push   $0x80192440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 24 19 80       	mov    0x80192458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 d6 a0 10 80       	push   $0x8010a0d6
80101635:	e8 6f ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 0a 1c 00 00       	call   80103277 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 e9 a0 10 80       	push   $0x8010a0e9
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 65 30 00 00       	call   80104708 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 24 19 80       	add    $0x80192460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 f0 a0 10 80       	push   $0x8010a0f0
801016cf:	50                   	push   %eax
801016d0:	e8 d6 2e 00 00       	call   801045ab <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 24 19 80       	push   $0x80192440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 24 19 80       	mov    0x80192458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101703:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101709:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010170f:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101715:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010171b:	a1 40 24 19 80       	mov    0x80192440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 f8 a0 10 80       	push   $0x8010a0f8
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 24 19 80       	mov    0x80192454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 f9 31 00 00       	call   801049a0 <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 b8 1a 00 00       	call   80103277 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 24 19 80       	mov    0x80192448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 4b a1 10 80       	push   $0x8010a14b
8010180e:	e8 96 ed ff ff       	call   801005a9 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 24 19 80       	mov    0x80192454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 ab 31 00 00       	call   80104a5f <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 b5 19 00 00       	call   80103277 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 24 19 80       	push   $0x80192460
801018e4:	e8 41 2e 00 00       	call   8010472a <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 24 19 80       	push   $0x80192460
80101932:	e8 61 2e 00 00       	call   80104798 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 5d a1 10 80       	push   $0x8010a15d
80101973:	e8 31 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 e8 2d 00 00       	call   80104798 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 24 19 80       	push   $0x80192460
801019c6:	e8 5f 2d 00 00       	call   8010472a <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 24 19 80       	push   $0x80192460
801019e5:	e8 ae 2d 00 00       	call   80104798 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 6d a1 10 80       	push   $0x8010a16d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 c3 2b 00 00       	call   801045e7 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 91 2f 00 00       	call   80104a5f <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 73 a1 10 80       	push   $0x8010a173
80101afd:	e8 a7 ea ff ff       	call   801005a9 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 79 2b 00 00       	call   80104699 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 82 a1 10 80       	push   $0x8010a182
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 fe 2a 00 00       	call   8010464b <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 7f 2a 00 00       	call   801045e7 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 24 19 80       	push   $0x80192460
80101b89:	e8 9c 2b 00 00       	call   8010472a <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 f1 2b 00 00       	call   80104798 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 5d 2a 00 00       	call   8010464b <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 2c 2b 00 00       	call   8010472a <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 24 19 80       	push   $0x80192460
80101c18:	e8 7b 2b 00 00       	call   80104798 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 34 15 00 00       	call   80103277 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 8a a1 10 80       	push   $0x8010a18a
80101d61:	e8 43 e8 ff ff       	call   801005a9 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 60 2a 00 00       	call   80104a5f <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 10 29 00 00       	call   80104a5f <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 1a 11 00 00       	call   80103277 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 26 29 00 00       	call   80104af5 <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 9d a1 10 80       	push   $0x8010a19d
801021ef:	e8 b5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 af a1 10 80       	push   $0x8010a1af
8010221e:	e8 86 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 be a1 10 80       	push   $0x8010a1be
801022f3:	e8 b1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 1d 28 00 00       	call   80104b4b <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 cb a1 10 80       	push   $0x8010a1cb
8010235a:	e8 4a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 93 26 00 00       	call   80104a5f <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 7c 26 00 00       	call   80104a5f <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 fe 15 00 00       	call   80103a30 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret

80102573 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102576:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102585:	8b 55 0c             	mov    0xc(%ebp),%edx
80102588:	89 50 10             	mov    %edx,0x10(%eax)
}
8010258b:	90                   	nop
8010258c:	5d                   	pop    %ebp
8010258d:	c3                   	ret

8010258e <ioapicinit>:

void
ioapicinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102594:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010259b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010259e:	6a 01                	push   $0x1
801025a0:	e8 b7 ff ff ff       	call   8010255c <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 10             	shr    $0x10,%eax
801025ab:	25 ff 00 00 00       	and    $0xff,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b3:	6a 00                	push   $0x0
801025b5:	e8 a2 ff ff ff       	call   8010255c <ioapicread>
801025ba:	83 c4 04             	add    $0x4,%esp
801025bd:	c1 e8 18             	shr    $0x18,%eax
801025c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c3:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 d4 a1 10 80       	push   $0x8010a1d4
801025da:	e8 15 de ff ff       	call   801003f4 <cprintf>
801025df:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 3f                	jmp    8010262a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 20             	add    $0x20,%eax
801025f1:	0d 00 00 01 00       	or     $0x10000,%eax
801025f6:	89 c2                	mov    %eax,%edx
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 69 ff ff ff       	call   80102573 <ioapicwrite>
8010260a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102610:	83 c0 08             	add    $0x8,%eax
80102613:	01 c0                	add    %eax,%eax
80102615:	83 c0 01             	add    $0x1,%eax
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	6a 00                	push   $0x0
8010261d:	50                   	push   %eax
8010261e:	e8 50 ff ff ff       	call   80102573 <ioapicwrite>
80102623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102630:	7e b9                	jle    801025eb <ioapicinit+0x5d>
  }
}
80102632:	90                   	nop
80102633:	90                   	nop
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 20             	add    $0x20,%eax
8010263f:	89 c2                	mov    %eax,%edx
80102641:	8b 45 08             	mov    0x8(%ebp),%eax
80102644:	83 c0 08             	add    $0x8,%eax
80102647:	01 c0                	add    %eax,%eax
80102649:	52                   	push   %edx
8010264a:	50                   	push   %eax
8010264b:	e8 23 ff ff ff       	call   80102573 <ioapicwrite>
80102650:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	c1 e0 18             	shl    $0x18,%eax
80102659:	89 c2                	mov    %eax,%edx
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	83 c0 08             	add    $0x8,%eax
80102661:	01 c0                	add    %eax,%eax
80102663:	83 c0 01             	add    $0x1,%eax
80102666:	52                   	push   %edx
80102667:	50                   	push   %eax
80102668:	e8 06 ff ff ff       	call   80102573 <ioapicwrite>
8010266d:	83 c4 08             	add    $0x8,%esp
}
80102670:	90                   	nop
80102671:	c9                   	leave
80102672:	c3                   	ret

80102673 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	68 06 a2 10 80       	push   $0x8010a206
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 7d 20 00 00       	call   80104708 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102695:	00 00 00 
  freerange(vstart, vend);
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	ff 75 0c             	push   0xc(%ebp)
8010269e:	ff 75 08             	push   0x8(%ebp)
801026a1:	e8 2a 00 00 00       	call   801026d0 <freerange>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	90                   	nop
801026aa:	c9                   	leave
801026ab:	c3                   	ret

801026ac <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026ac:	55                   	push   %ebp
801026ad:	89 e5                	mov    %esp,%ebp
801026af:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	ff 75 0c             	push   0xc(%ebp)
801026b8:	ff 75 08             	push   0x8(%ebp)
801026bb:	e8 10 00 00 00       	call   801026d0 <freerange>
801026c0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c3:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026ca:	00 00 00 
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026d6:	8b 45 08             	mov    0x8(%ebp),%eax
801026d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e6:	eb 15                	jmp    801026fd <freerange+0x2d>
    kfree(p);
801026e8:	83 ec 0c             	sub    $0xc,%esp
801026eb:	ff 75 f4             	push   -0xc(%ebp)
801026ee:	e8 1b 00 00 00       	call   8010270e <kfree>
801026f3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102700:	05 00 10 00 00       	add    $0x1000,%eax
80102705:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102708:	73 de                	jae    801026e8 <freerange+0x18>
}
8010270a:	90                   	nop
8010270b:	90                   	nop
8010270c:	c9                   	leave
8010270d:	c3                   	ret

8010270e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010270e:	55                   	push   %ebp
8010270f:	89 e5                	mov    %esp,%ebp
80102711:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	25 ff 0f 00 00       	and    $0xfff,%eax
8010271c:	85 c0                	test   %eax,%eax
8010271e:	75 18                	jne    80102738 <kfree+0x2a>
80102720:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 0b a2 10 80       	push   $0x8010a20b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 49 22 00 00       	call   801049a0 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 ba 1f 00 00       	call   8010472a <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010278c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 40 19 80       	push   $0x801940c0
8010279d:	e8 f6 1f 00 00       	call   80104798 <release>
801027a2:	83 c4 10             	add    $0x10,%esp
}
801027a5:	90                   	nop
801027a6:	c9                   	leave
801027a7:	c3                   	ret

801027a8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027ae:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 40 19 80       	push   $0x801940c0
801027bf:	e8 66 1f 00 00       	call   8010472a <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027df:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 40 19 80       	push   $0x801940c0
801027f0:	e8 a3 1f 00 00       	call   80104798 <release>
801027f5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027fb:	c9                   	leave
801027fc:	c3                   	ret

801027fd <inb>:
{
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 14             	sub    $0x14,%esp
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010280e:	89 c2                	mov    %eax,%edx
80102810:	ec                   	in     (%dx),%al
80102811:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102814:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102818:	c9                   	leave
80102819:	c3                   	ret

8010281a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010281a:	55                   	push   %ebp
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102820:	6a 64                	push   $0x64
80102822:	e8 d6 ff ff ff       	call   801027fd <inb>
80102827:	83 c4 04             	add    $0x4,%esp
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	83 e0 01             	and    $0x1,%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 0a                	jne    80102844 <kbdgetc+0x2a>
    return -1;
8010283a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010283f:	e9 23 01 00 00       	jmp    80102967 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102844:	6a 60                	push   $0x60
80102846:	e8 b2 ff ff ff       	call   801027fd <inb>
8010284b:	83 c4 04             	add    $0x4,%esp
8010284e:	0f b6 c0             	movzbl %al,%eax
80102851:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102854:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010285b:	75 17                	jne    80102874 <kbdgetc+0x5a>
    shift |= E0ESC;
8010285d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
8010286f:	e9 f3 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	25 80 00 00 00       	and    $0x80,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 45                	je     801028c5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102880:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102885:	83 e0 40             	and    $0x40,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 08                	jne    80102894 <kbdgetc+0x7a>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	83 e0 7f             	and    $0x7f,%eax
80102892:	eb 03                	jmp    80102897 <kbdgetc+0x7d>
80102894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102897:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293b:	83 e0 08             	and    $0x8,%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 22                	je     80102964 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102942:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102946:	76 0c                	jbe    80102954 <kbdgetc+0x13a>
80102948:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010294c:	77 06                	ja     80102954 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010294e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102952:	eb 10                	jmp    80102964 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102954:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102958:	76 0a                	jbe    80102964 <kbdgetc+0x14a>
8010295a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010295e:	77 04                	ja     80102964 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102960:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102964:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102967:	c9                   	leave
80102968:	c3                   	ret

80102969 <kbdintr>:

void
kbdintr(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 1a 28 10 80       	push   $0x8010281a
80102977:	e8 5a de ff ff       	call   801007d6 <consoleintr>
8010297c:	83 c4 10             	add    $0x10,%esp
}
8010297f:	90                   	nop
80102980:	c9                   	leave
80102981:	c3                   	ret

80102982 <inb>:
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 14             	sub    $0x14,%esp
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102993:	89 c2                	mov    %eax,%edx
80102995:	ec                   	in     (%dx),%al
80102996:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102999:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010299d:	c9                   	leave
8010299e:	c3                   	ret

8010299f <outb>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	83 ec 08             	sub    $0x8,%esp
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029ba:	ee                   	out    %al,(%dx)
}
801029bb:	90                   	nop
801029bc:	c9                   	leave
801029bd:	c3                   	ret

801029be <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d8:	83 c0 20             	add    $0x20,%eax
801029db:	8b 00                	mov    (%eax),%eax
}
801029dd:	90                   	nop
801029de:	5d                   	pop    %ebp
801029df:	c3                   	ret

801029e0 <lapicinit>:

void
lapicinit(void)
{
801029e0:	55                   	push   %ebp
801029e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029e3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	0f 84 09 01 00 00    	je     80102af9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f0:	68 3f 01 00 00       	push   $0x13f
801029f5:	6a 3c                	push   $0x3c
801029f7:	e8 c2 ff ff ff       	call   801029be <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ff:	6a 0b                	push   $0xb
80102a01:	68 f8 00 00 00       	push   $0xf8
80102a06:	e8 b3 ff ff ff       	call   801029be <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0e:	68 20 00 02 00       	push   $0x20020
80102a13:	68 c8 00 00 00       	push   $0xc8
80102a18:	e8 a1 ff ff ff       	call   801029be <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a20:	68 80 96 98 00       	push   $0x989680
80102a25:	68 e0 00 00 00       	push   $0xe0
80102a2a:	e8 8f ff ff ff       	call   801029be <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d4 00 00 00       	push   $0xd4
80102a3c:	e8 7d ff ff ff       	call   801029be <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a44:	68 00 00 01 00       	push   $0x10000
80102a49:	68 d8 00 00 00       	push   $0xd8
80102a4e:	e8 6b ff ff ff       	call   801029be <lapicw>
80102a53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a56:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a5b:	83 c0 30             	add    $0x30,%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102a65:	85 c0                	test   %eax,%eax
80102a67:	74 12                	je     80102a7b <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102a69:	68 00 00 01 00       	push   $0x10000
80102a6e:	68 d0 00 00 00       	push   $0xd0
80102a73:	e8 46 ff ff ff       	call   801029be <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7b:	6a 33                	push   $0x33
80102a7d:	68 dc 00 00 00       	push   $0xdc
80102a82:	e8 37 ff ff ff       	call   801029be <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 28 ff ff ff       	call   801029be <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	68 a0 00 00 00       	push   $0xa0
80102aa0:	e8 19 ff ff ff       	call   801029be <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	6a 2c                	push   $0x2c
80102aac:	e8 0d ff ff ff       	call   801029be <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	68 c4 00 00 00       	push   $0xc4
80102abb:	e8 fe fe ff ff       	call   801029be <lapicw>
80102ac0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac3:	68 00 85 08 00       	push   $0x88500
80102ac8:	68 c0 00 00 00       	push   $0xc0
80102acd:	e8 ec fe ff ff       	call   801029be <lapicw>
80102ad2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad5:	90                   	nop
80102ad6:	a1 00 41 19 80       	mov    0x80194100,%eax
80102adb:	05 00 03 00 00       	add    $0x300,%eax
80102ae0:	8b 00                	mov    (%eax),%eax
80102ae2:	25 00 10 00 00       	and    $0x1000,%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	75 eb                	jne    80102ad6 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aeb:	6a 00                	push   $0x0
80102aed:	6a 20                	push   $0x20
80102aef:	e8 ca fe ff ff       	call   801029be <lapicw>
80102af4:	83 c4 08             	add    $0x8,%esp
80102af7:	eb 01                	jmp    80102afa <lapicinit+0x11a>
    return;
80102af9:	90                   	nop
}
80102afa:	c9                   	leave
80102afb:	c3                   	ret

80102afc <lapicid>:

int
lapicid(void)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aff:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	8b 00                	mov    (%eax),%eax
80102b19:	c1 e8 18             	shr    $0x18,%eax
}
80102b1c:	5d                   	pop    %ebp
80102b1d:	c3                   	ret

80102b1e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b21:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0c                	je     80102b36 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b2a:	6a 00                	push   $0x0
80102b2c:	6a 2c                	push   $0x2c
80102b2e:	e8 8b fe ff ff       	call   801029be <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
}
80102b36:	90                   	nop
80102b37:	c9                   	leave
80102b38:	c3                   	ret

80102b39 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b39:	55                   	push   %ebp
80102b3a:	89 e5                	mov    %esp,%ebp
}
80102b3c:	90                   	nop
80102b3d:	5d                   	pop    %ebp
80102b3e:	c3                   	ret

80102b3f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4b:	6a 0f                	push   $0xf
80102b4d:	6a 70                	push   $0x70
80102b4f:	e8 4b fe ff ff       	call   8010299f <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b57:	6a 0a                	push   $0xa
80102b59:	6a 71                	push   $0x71
80102b5b:	e8 3f fe ff ff       	call   8010299f <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b63:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b75:	c1 e8 04             	shr    $0x4,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7d:	83 c0 02             	add    $0x2,%eax
80102b80:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b83:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b87:	c1 e0 18             	shl    $0x18,%eax
80102b8a:	50                   	push   %eax
80102b8b:	68 c4 00 00 00       	push   $0xc4
80102b90:	e8 29 fe ff ff       	call   801029be <lapicw>
80102b95:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b98:	68 00 c5 00 00       	push   $0xc500
80102b9d:	68 c0 00 00 00       	push   $0xc0
80102ba2:	e8 17 fe ff ff       	call   801029be <lapicw>
80102ba7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102baa:	68 c8 00 00 00       	push   $0xc8
80102baf:	e8 85 ff ff ff       	call   80102b39 <microdelay>
80102bb4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb7:	68 00 85 00 00       	push   $0x8500
80102bbc:	68 c0 00 00 00       	push   $0xc0
80102bc1:	e8 f8 fd ff ff       	call   801029be <lapicw>
80102bc6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc9:	6a 64                	push   $0x64
80102bcb:	e8 69 ff ff ff       	call   80102b39 <microdelay>
80102bd0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bda:	eb 3d                	jmp    80102c19 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be0:	c1 e0 18             	shl    $0x18,%eax
80102be3:	50                   	push   %eax
80102be4:	68 c4 00 00 00       	push   $0xc4
80102be9:	e8 d0 fd ff ff       	call   801029be <lapicw>
80102bee:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf4:	c1 e8 0c             	shr    $0xc,%eax
80102bf7:	80 cc 06             	or     $0x6,%ah
80102bfa:	50                   	push   %eax
80102bfb:	68 c0 00 00 00       	push   $0xc0
80102c00:	e8 b9 fd ff ff       	call   801029be <lapicw>
80102c05:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c08:	68 c8 00 00 00       	push   $0xc8
80102c0d:	e8 27 ff ff ff       	call   80102b39 <microdelay>
80102c12:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c15:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c19:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1d:	7e bd                	jle    80102bdc <lapicstartap+0x9d>
  }
}
80102c1f:	90                   	nop
80102c20:	90                   	nop
80102c21:	c9                   	leave
80102c22:	c3                   	ret

80102c23 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	0f b6 c0             	movzbl %al,%eax
80102c2c:	50                   	push   %eax
80102c2d:	6a 70                	push   $0x70
80102c2f:	e8 6b fd ff ff       	call   8010299f <outb>
80102c34:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c37:	68 c8 00 00 00       	push   $0xc8
80102c3c:	e8 f8 fe ff ff       	call   80102b39 <microdelay>
80102c41:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c44:	6a 71                	push   $0x71
80102c46:	e8 37 fd ff ff       	call   80102982 <inb>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	0f b6 c0             	movzbl %al,%eax
}
80102c51:	c9                   	leave
80102c52:	c3                   	ret

80102c53 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c56:	6a 00                	push   $0x0
80102c58:	e8 c6 ff ff ff       	call   80102c23 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c65:	6a 02                	push   $0x2
80102c67:	e8 b7 ff ff ff       	call   80102c23 <cmos_read>
80102c6c:	83 c4 04             	add    $0x4,%esp
80102c6f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c72:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c75:	6a 04                	push   $0x4
80102c77:	e8 a7 ff ff ff       	call   80102c23 <cmos_read>
80102c7c:	83 c4 04             	add    $0x4,%esp
80102c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c82:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c85:	6a 07                	push   $0x7
80102c87:	e8 97 ff ff ff       	call   80102c23 <cmos_read>
80102c8c:	83 c4 04             	add    $0x4,%esp
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c95:	6a 08                	push   $0x8
80102c97:	e8 87 ff ff ff       	call   80102c23 <cmos_read>
80102c9c:	83 c4 04             	add    $0x4,%esp
80102c9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca2:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca5:	6a 09                	push   $0x9
80102ca7:	e8 77 ff ff ff       	call   80102c23 <cmos_read>
80102cac:	83 c4 04             	add    $0x4,%esp
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb5:	90                   	nop
80102cb6:	c9                   	leave
80102cb7:	c3                   	ret

80102cb8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbe:	6a 0b                	push   $0xb
80102cc0:	e8 5e ff ff ff       	call   80102c23 <cmos_read>
80102cc5:	83 c4 04             	add    $0x4,%esp
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	83 e0 04             	and    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	0f 94 c0             	sete   %al
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdf:	50                   	push   %eax
80102ce0:	e8 6e ff ff ff       	call   80102c53 <fill_rtcdate>
80102ce5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce8:	6a 0a                	push   $0xa
80102cea:	e8 34 ff ff ff       	call   80102c23 <cmos_read>
80102cef:	83 c4 04             	add    $0x4,%esp
80102cf2:	25 80 00 00 00       	and    $0x80,%eax
80102cf7:	85 c0                	test   %eax,%eax
80102cf9:	75 27                	jne    80102d22 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 4f ff ff ff       	call   80102c53 <fill_rtcdate>
80102d04:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d07:	83 ec 04             	sub    $0x4,%esp
80102d0a:	6a 18                	push   $0x18
80102d0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0f:	50                   	push   %eax
80102d10:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d13:	50                   	push   %eax
80102d14:	e8 ee 1c 00 00       	call   80104a07 <memcmp>
80102d19:	83 c4 10             	add    $0x10,%esp
80102d1c:	85 c0                	test   %eax,%eax
80102d1e:	74 05                	je     80102d25 <cmostime+0x6d>
80102d20:	eb ba                	jmp    80102cdc <cmostime+0x24>
        continue;
80102d22:	90                   	nop
    fill_rtcdate(&t1);
80102d23:	eb b7                	jmp    80102cdc <cmostime+0x24>
      break;
80102d25:	90                   	nop
  }

  // convert
  if(bcd) {
80102d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d2a:	0f 84 b4 00 00 00    	je     80102de4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d33:	c1 e8 04             	shr    $0x4,%eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	89 d0                	mov    %edx,%eax
80102d3a:	c1 e0 02             	shl    $0x2,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	01 c0                	add    %eax,%eax
80102d41:	89 c2                	mov    %eax,%edx
80102d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d46:	83 e0 0f             	and    $0xf,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d51:	c1 e8 04             	shr    $0x4,%eax
80102d54:	89 c2                	mov    %eax,%edx
80102d56:	89 d0                	mov    %edx,%eax
80102d58:	c1 e0 02             	shl    $0x2,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	01 c0                	add    %eax,%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d64:	83 e0 0f             	and    $0xf,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6f:	c1 e8 04             	shr    $0x4,%eax
80102d72:	89 c2                	mov    %eax,%edx
80102d74:	89 d0                	mov    %edx,%eax
80102d76:	c1 e0 02             	shl    $0x2,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 c2                	mov    %eax,%edx
80102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d82:	83 e0 0f             	and    $0xf,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8d:	c1 e8 04             	shr    $0x4,%eax
80102d90:	89 c2                	mov    %eax,%edx
80102d92:	89 d0                	mov    %edx,%eax
80102d94:	c1 e0 02             	shl    $0x2,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	01 c0                	add    %eax,%eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102da0:	83 e0 0f             	and    $0xf,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dab:	c1 e8 04             	shr    $0x4,%eax
80102dae:	89 c2                	mov    %eax,%edx
80102db0:	89 d0                	mov    %edx,%eax
80102db2:	c1 e0 02             	shl    $0x2,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	01 c0                	add    %eax,%eax
80102db9:	89 c2                	mov    %eax,%edx
80102dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbe:	83 e0 0f             	and    $0xf,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc9:	c1 e8 04             	shr    $0x4,%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	89 d0                	mov    %edx,%eax
80102dd0:	c1 e0 02             	shl    $0x2,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	01 c0                	add    %eax,%eax
80102dd7:	89 c2                	mov    %eax,%edx
80102dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddc:	83 e0 0f             	and    $0xf,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dea:	89 10                	mov    %edx,(%eax)
80102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102def:	89 50 04             	mov    %edx,0x4(%eax)
80102df2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df5:	89 50 08             	mov    %edx,0x8(%eax)
80102df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfb:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e01:	89 50 10             	mov    %edx,0x10(%eax)
80102e04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	8b 40 14             	mov    0x14(%eax),%eax
80102e10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1c:	90                   	nop
80102e1d:	c9                   	leave
80102e1e:	c3                   	ret

80102e1f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	68 11 a2 10 80       	push   $0x8010a211
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 d1 18 00 00       	call   80104708 <initlock>
80102e37:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e3a:	83 ec 08             	sub    $0x8,%esp
80102e3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e40:	50                   	push   %eax
80102e41:	ff 75 08             	push   0x8(%ebp)
80102e44:	e8 8f e5 ff ff       	call   801013d8 <readsb>
80102e49:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4f:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e64:	e8 b3 01 00 00       	call   8010301c <recover_from_log>
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave
80102e6b:	c3                   	ret

80102e6c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e79:	e9 95 00 00 00       	jmp    80102f13 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	52                   	push   %edx
80102ebb:	50                   	push   %eax
80102ebc:	e8 40 d3 ff ff       	call   80100201 <bread>
80102ec1:	83 c4 10             	add    $0x10,%esp
80102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eca:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ed0:	83 c0 5c             	add    $0x5c,%eax
80102ed3:	83 ec 04             	sub    $0x4,%esp
80102ed6:	68 00 02 00 00       	push   $0x200
80102edb:	52                   	push   %edx
80102edc:	50                   	push   %eax
80102edd:	e8 7d 1b 00 00       	call   80104a5f <memmove>
80102ee2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	ff 75 ec             	push   -0x14(%ebp)
80102eeb:	e8 4a d3 ff ff       	call   8010023a <bwrite>
80102ef0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	ff 75 f0             	push   -0x10(%ebp)
80102ef9:	e8 85 d3 ff ff       	call   80100283 <brelse>
80102efe:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f01:	83 ec 0c             	sub    $0xc,%esp
80102f04:	ff 75 ec             	push   -0x14(%ebp)
80102f07:	e8 77 d3 ff ff       	call   80100283 <brelse>
80102f0c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f13:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1b:	0f 8c 5d ff ff ff    	jl     80102e7e <install_trans+0x12>
  }
}
80102f21:	90                   	nop
80102f22:	90                   	nop
80102f23:	c9                   	leave
80102f24:	c3                   	ret

80102f25 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f25:	55                   	push   %ebp
80102f26:	89 e5                	mov    %esp,%ebp
80102f28:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2b:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f37:	83 ec 08             	sub    $0x8,%esp
80102f3a:	52                   	push   %edx
80102f3b:	50                   	push   %eax
80102f3c:	e8 c0 d2 ff ff       	call   80100201 <bread>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f4a:	83 c0 5c             	add    $0x5c,%eax
80102f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f86:	7c db                	jl     80102f63 <read_head+0x3e>
  }
  brelse(buf);
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	ff 75 f0             	push   -0x10(%ebp)
80102f8e:	e8 f0 d2 ff ff       	call   80100283 <brelse>
80102f93:	83 c4 10             	add    $0x10,%esp
}
80102f96:	90                   	nop
80102f97:	c9                   	leave
80102f98:	c3                   	ret

80102f99 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	52                   	push   %edx
80102faf:	50                   	push   %eax
80102fb0:	e8 4c d2 ff ff       	call   80100201 <bread>
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbe:	83 c0 5c             	add    $0x5c,%eax
80102fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffb:	7c db                	jl     80102fd8 <write_head+0x3f>
  }
  bwrite(buf);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	ff 75 f0             	push   -0x10(%ebp)
80103003:	e8 32 d2 ff ff       	call   8010023a <bwrite>
80103008:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	ff 75 f0             	push   -0x10(%ebp)
80103011:	e8 6d d2 ff ff       	call   80100283 <brelse>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave
8010301b:	c3                   	ret

8010301c <recover_from_log>:

static void
recover_from_log(void)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103022:	e8 fe fe ff ff       	call   80102f25 <read_head>
  install_trans(); // if committed, copy from log to disk
80103027:	e8 40 fe ff ff       	call   80102e6c <install_trans>
  log.lh.n = 0;
8010302c:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103033:	00 00 00 
  write_head(); // clear the log
80103036:	e8 5e ff ff ff       	call   80102f99 <write_head>
}
8010303b:	90                   	nop
8010303c:	c9                   	leave
8010303d:	c3                   	ret

8010303e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 20 41 19 80       	push   $0x80194120
8010304c:	e8 d9 16 00 00       	call   8010472a <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 41 19 80       	mov    0x80194160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 41 19 80       	push   $0x80194120
80103065:	68 20 41 19 80       	push   $0x80194120
8010306a:	e8 97 12 00 00       	call   80104306 <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010307a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307f:	8d 50 01             	lea    0x1(%eax),%edx
80103082:	89 d0                	mov    %edx,%eax
80103084:	c1 e0 02             	shl    $0x2,%eax
80103087:	01 d0                	add    %edx,%eax
80103089:	01 c0                	add    %eax,%eax
8010308b:	01 c8                	add    %ecx,%eax
8010308d:	83 f8 1e             	cmp    $0x1e,%eax
80103090:	7e 17                	jle    801030a9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103092:	83 ec 08             	sub    $0x8,%esp
80103095:	68 20 41 19 80       	push   $0x80194120
8010309a:	68 20 41 19 80       	push   $0x80194120
8010309f:	e8 62 12 00 00       	call   80104306 <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 41 19 80       	push   $0x80194120
801030be:	e8 d5 16 00 00       	call   80104798 <release>
801030c3:	83 c4 10             	add    $0x10,%esp
      break;
801030c6:	90                   	nop
    }
  }
}
801030c7:	90                   	nop
801030c8:	c9                   	leave
801030c9:	c3                   	ret

801030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030ca:	55                   	push   %ebp
801030cb:	89 e5                	mov    %esp,%ebp
801030cd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 20 41 19 80       	push   $0x80194120
801030df:	e8 46 16 00 00       	call   8010472a <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f4:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 15 a2 10 80       	push   $0x8010a215
80103105:	e8 9f d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 41 19 80       	push   $0x80194120
8010312e:	e8 bd 12 00 00       	call   801043f0 <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 55 16 00 00       	call   80104798 <release>
80103143:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010314a:	74 3f                	je     8010318b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314c:	e8 f6 00 00 00       	call   80103247 <commit>
    acquire(&log.lock);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 41 19 80       	push   $0x80194120
80103159:	e8 cc 15 00 00       	call   8010472a <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 78 12 00 00       	call   801043f0 <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 10 16 00 00       	call   80104798 <release>
80103188:	83 c4 10             	add    $0x10,%esp
  }
}
8010318b:	90                   	nop
8010318c:	c9                   	leave
8010318d:	c3                   	ret

8010318e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319b:	e9 95 00 00 00       	jmp    80103235 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031a0:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	52                   	push   %edx
801031dd:	50                   	push   %eax
801031de:	e8 1e d0 ff ff       	call   80100201 <bread>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	83 c0 5c             	add    $0x5c,%eax
801031f5:	83 ec 04             	sub    $0x4,%esp
801031f8:	68 00 02 00 00       	push   $0x200
801031fd:	52                   	push   %edx
801031fe:	50                   	push   %eax
801031ff:	e8 5b 18 00 00       	call   80104a5f <memmove>
80103204:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103207:	83 ec 0c             	sub    $0xc,%esp
8010320a:	ff 75 f0             	push   -0x10(%ebp)
8010320d:	e8 28 d0 ff ff       	call   8010023a <bwrite>
80103212:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	ff 75 ec             	push   -0x14(%ebp)
8010321b:	e8 63 d0 ff ff       	call   80100283 <brelse>
80103220:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	ff 75 f0             	push   -0x10(%ebp)
80103229:	e8 55 d0 ff ff       	call   80100283 <brelse>
8010322e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103235:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323d:	0f 8c 5d ff ff ff    	jl     801031a0 <write_log+0x12>
  }
}
80103243:	90                   	nop
80103244:	90                   	nop
80103245:	c9                   	leave
80103246:	c3                   	ret

80103247 <commit>:

static void
commit()
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326f:	e8 25 fd ff ff       	call   80102f99 <write_head>
  }
}
80103274:	90                   	nop
80103275:	c9                   	leave
80103276:	c3                   	ret

80103277 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103277:	55                   	push   %ebp
80103278:	89 e5                	mov    %esp,%ebp
8010327a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 41 19 80    	mov    0x80194168,%edx
8010328d:	a1 58 41 19 80       	mov    0x80194158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 24 a2 10 80       	push   $0x8010a224
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 3a a2 10 80       	push   $0x8010a23a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 61 14 00 00       	call   8010472a <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032fa:	7c d9                	jl     801032d5 <log_write+0x5e>
801032fc:	eb 01                	jmp    801032ff <log_write+0x88>
      break;
801032fe:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 08             	mov    0x8(%eax),%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	83 c0 10             	add    $0x10,%eax
8010330d:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 41 19 80       	mov    0x80194168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 41 19 80       	push   $0x80194120
80103342:	e8 51 14 00 00       	call   80104798 <release>
80103347:	83 c4 10             	add    $0x10,%esp
}
8010334a:	90                   	nop
8010334b:	c9                   	leave
8010334c:	c3                   	ret

8010334d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335c:	f0 87 02             	lock xchg %eax,(%edx)
8010335f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103365:	c9                   	leave
80103366:	c3                   	ret

80103367 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103367:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336b:	83 e4 f0             	and    $0xfffffff0,%esp
8010336e:	ff 71 fc             	push   -0x4(%ecx)
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	51                   	push   %ecx
80103375:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103378:	e8 38 4a 00 00       	call   80107db5 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 3b 40 00 00       	call   801073d2 <kvmalloc>
  mpinit_uefi();
80103397:	e8 e2 47 00 00       	call   80107b7e <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 c3 3a 00 00       	call   80106e69 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 48 2e 00 00       	call   80106202 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 e3 29 00 00       	call   80105da7 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 0d 6b 00 00       	call   80109ee0 <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 1e 4c 00 00       	call   80108010 <pci_init>
  arp_scan();
801033f2:	e8 53 59 00 00       	call   80108d4a <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 64 07 00 00       	call   80103b60 <userinit>

  mpmain();        // finish this processor's setup
801033fc:	e8 1a 00 00 00       	call   8010341b <mpmain>

80103401 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103407:	e8 de 3f 00 00       	call   801073ea <switchkvm>
  seginit();
8010340c:	e8 58 3a 00 00       	call   80106e69 <seginit>
  lapicinit();
80103411:	e8 ca f5 ff ff       	call   801029e0 <lapicinit>
  mpmain();
80103416:	e8 00 00 00 00       	call   8010341b <mpmain>

8010341b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	53                   	push   %ebx
8010341f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103422:	e8 76 05 00 00       	call   8010399d <cpuid>
80103427:	89 c3                	mov    %eax,%ebx
80103429:	e8 6f 05 00 00       	call   8010399d <cpuid>
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	53                   	push   %ebx
80103432:	50                   	push   %eax
80103433:	68 55 a2 10 80       	push   $0x8010a255
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 d8 2a 00 00       	call   80105f1d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 8f 0c 00 00       	call   801040f1 <scheduler>

80103462 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103462:	55                   	push   %ebp
80103463:	89 e5                	mov    %esp,%ebp
80103465:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103468:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103474:	83 ec 04             	sub    $0x4,%esp
80103477:	50                   	push   %eax
80103478:	68 18 f5 10 80       	push   $0x8010f518
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 da 15 00 00       	call   80104a5f <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 6b 19 80 	movl   $0x80196b80,-0xc(%ebp)
8010348f:	eb 79                	jmp    8010350a <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103491:	e8 22 05 00 00       	call   801039b8 <mycpu>
80103496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103499:	74 67                	je     80103502 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349b:	e8 08 f3 ff ff       	call   801027a8 <kalloc>
801034a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 04             	sub    $0x4,%eax
801034a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b7:	83 e8 08             	sub    $0x8,%eax
801034ba:	c7 00 01 34 10 80    	movl   $0x80103401,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034c0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 e8 0c             	sub    $0xc,%eax
801034d1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 50 f6 ff ff       	call   80102b3f <lapicstartap>
801034ef:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f2:	90                   	nop
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fc:	85 c0                	test   %eax,%eax
801034fe:	74 f3                	je     801034f3 <startothers+0x91>
80103500:	eb 01                	jmp    80103503 <startothers+0xa1>
      continue;
80103502:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103503:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010350a:	a1 40 6e 19 80       	mov    0x80196e40,%eax
8010350f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103515:	05 80 6b 19 80       	add    $0x80196b80,%eax
8010351a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351d:	0f 82 6e ff ff ff    	jb     80103491 <startothers+0x2f>
      ;
  }
}
80103523:	90                   	nop
80103524:	90                   	nop
80103525:	c9                   	leave
80103526:	c3                   	ret

80103527 <outb>:
{
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	8b 55 08             	mov    0x8(%ebp),%edx
80103530:	8b 45 0c             	mov    0xc(%ebp),%eax
80103533:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave
80103545:	c3                   	ret

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d2 ff ff ff       	call   80103527 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 c0 ff ff ff       	call   80103527 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave
8010356c:	c3                   	ret

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 55 da ff ff       	call   80100fe7 <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 3e da ff ff       	call   80100fe7 <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e8 f1 ff ff       	call   801027a8 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 69 a2 10 80       	push   $0x8010a269
8010360c:	50                   	push   %eax
8010360d:	e8 f6 10 00 00       	call   80104708 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 8d f0 ff ff       	call   8010270e <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 0a da ff ff       	call   801010a5 <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 f0 d9 ff ff       	call   801010a5 <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave
801036be:	c3                   	ret

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 59 10 00 00       	call   8010472a <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 f8 0c 00 00       	call   801043f0 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 d5 0c 00 00       	call   801043f0 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 54 10 00 00       	call   80104798 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 bc ef ff ff       	call   8010270e <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 35 10 00 00       	call   80104798 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave
80103769:	c3                   	ret

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 ad 0f 00 00       	call   8010472a <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 e7 0f 00 00       	call   80104798 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 21 0c 00 00       	call   801043f0 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 1e 0b 00 00       	call   80104306 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 9e 0b 00 00       	call   801043f0 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 37 0f 00 00       	call   80104798 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave
8010386b:	c3                   	ret

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 ac 0e 00 00       	call   8010472a <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 fd 0e 00 00       	call   80104798 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 48 0a 00 00       	call   80104306 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 9f 0a 00 00       	call   801043f0 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 38 0e 00 00       	call   80104798 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave
80103967:	c3                   	ret

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave
80103977:	c3                   	ret

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 70 a2 10 80       	push   $0x8010a270
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 71 0d 00 00       	call   80104708 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave
8010399c:	c3                   	ret

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6b 19 80       	sub    $0x80196b80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave
801039b7:	c3                   	ret

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 78 a2 10 80       	push   $0x8010a278
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1e f1 ff ff       	call   80102afc <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6b 19 80       	add    $0x80196b80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6b 19 80       	add    $0x80196b80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 9e a2 10 80       	push   $0x8010a29e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave
80103a2f:	c3                   	ret

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 5a 0e 00 00       	call   80104895 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 8e 0e 00 00       	call   801048e2 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave
80103a58:	c3                   	ret

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 be 0c 00 00       	call   8010472a <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a89:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 f9 0c 00 00       	call   80104798 <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 b2 00 00 00       	jmp    80103b5e <allocproc+0x105>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 c0 0c 00 00       	call   80104798 <release>
80103ad8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103adb:	e8 c8 ec ff ff       	call   801027a8 <kalloc>
80103ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae3:	89 42 08             	mov    %eax,0x8(%edx)
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	8b 40 08             	mov    0x8(%eax),%eax
80103aec:	85 c0                	test   %eax,%eax
80103aee:	75 11                	jne    80103b01 <allocproc+0xa8>
    p->state = UNUSED;
80103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103afa:	b8 00 00 00 00       	mov    $0x0,%eax
80103aff:	eb 5d                	jmp    80103b5e <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	8b 40 08             	mov    0x8(%eax),%eax
80103b07:	05 00 10 00 00       	add    $0x1000,%eax
80103b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b19:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b20:	ba 61 5d 10 80       	mov    $0x80105d61,%edx
80103b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b28:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b2a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b34:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3d:	83 ec 04             	sub    $0x4,%esp
80103b40:	6a 14                	push   $0x14
80103b42:	6a 00                	push   $0x0
80103b44:	50                   	push   %eax
80103b45:	e8 56 0e 00 00       	call   801049a0 <memset>
80103b4a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b53:	ba c0 42 10 80       	mov    $0x801042c0,%edx
80103b58:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5e:	c9                   	leave
80103b5f:	c3                   	ret

80103b60 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b66:	e8 ee fe ff ff       	call   80103a59 <allocproc>
80103b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	a3 34 63 19 80       	mov    %eax,0x80196334
  if((p->pgdir = setupkvm()) == 0){
80103b76:	e8 6a 37 00 00       	call   801072e5 <setupkvm>
80103b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7e:	89 42 04             	mov    %eax,0x4(%edx)
80103b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b84:	8b 40 04             	mov    0x4(%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	75 0d                	jne    80103b98 <userinit+0x38>
    panic("userinit: out of memory?");
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	68 ae a2 10 80       	push   $0x8010a2ae
80103b93:	e8 11 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b98:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba0:	8b 40 04             	mov    0x4(%eax),%eax
80103ba3:	83 ec 04             	sub    $0x4,%esp
80103ba6:	52                   	push   %edx
80103ba7:	68 ec f4 10 80       	push   $0x8010f4ec
80103bac:	50                   	push   %eax
80103bad:	e8 f0 39 00 00       	call   801075a2 <inituvm>
80103bb2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc1:	8b 40 18             	mov    0x18(%eax),%eax
80103bc4:	83 ec 04             	sub    $0x4,%esp
80103bc7:	6a 4c                	push   $0x4c
80103bc9:	6a 00                	push   $0x0
80103bcb:	50                   	push   %eax
80103bcc:	e8 cf 0d 00 00       	call   801049a0 <memset>
80103bd1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd7:	8b 40 18             	mov    0x18(%eax),%eax
80103bda:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be3:	8b 40 18             	mov    0x18(%eax),%eax
80103be6:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	8b 50 18             	mov    0x18(%eax),%edx
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	8b 40 18             	mov    0x18(%eax),%eax
80103bf8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfc:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 50 18             	mov    0x18(%eax),%edx
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	8b 40 18             	mov    0x18(%eax),%eax
80103c0c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c10:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	8b 40 18             	mov    0x18(%eax),%eax
80103c1a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8b 40 18             	mov    0x18(%eax),%eax
80103c27:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	8b 40 18             	mov    0x18(%eax),%eax
80103c34:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	83 c0 6c             	add    $0x6c,%eax
80103c41:	83 ec 04             	sub    $0x4,%esp
80103c44:	6a 10                	push   $0x10
80103c46:	68 c7 a2 10 80       	push   $0x8010a2c7
80103c4b:	50                   	push   %eax
80103c4c:	e8 52 0f 00 00       	call   80104ba3 <safestrcpy>
80103c51:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 d0 a2 10 80       	push   $0x8010a2d0
80103c5c:	e8 c4 e8 ff ff       	call   80102525 <namei>
80103c61:	83 c4 10             	add    $0x10,%esp
80103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c67:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c6a:	83 ec 0c             	sub    $0xc,%esp
80103c6d:	68 00 42 19 80       	push   $0x80194200
80103c72:	e8 b3 0a 00 00       	call   8010472a <acquire>
80103c77:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c84:	83 ec 0c             	sub    $0xc,%esp
80103c87:	68 00 42 19 80       	push   $0x80194200
80103c8c:	e8 07 0b 00 00       	call   80104798 <release>
80103c91:	83 c4 10             	add    $0x10,%esp
}
80103c94:	90                   	nop
80103c95:	c9                   	leave
80103c96:	c3                   	ret

80103c97 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9d:	e8 8e fd ff ff       	call   80103a30 <myproc>
80103ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca8:	8b 00                	mov    (%eax),%eax
80103caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cb1:	7e 2e                	jle    80103ce1 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb9:	01 c2                	add    %eax,%edx
80103cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbe:	8b 40 04             	mov    0x4(%eax),%eax
80103cc1:	83 ec 04             	sub    $0x4,%esp
80103cc4:	52                   	push   %edx
80103cc5:	ff 75 f4             	push   -0xc(%ebp)
80103cc8:	50                   	push   %eax
80103cc9:	e8 11 3a 00 00       	call   801076df <allocuvm>
80103cce:	83 c4 10             	add    $0x10,%esp
80103cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd8:	75 3b                	jne    80103d15 <growproc+0x7e>
      return -1;
80103cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdf:	eb 4f                	jmp    80103d30 <growproc+0x99>
  } else if(n < 0){
80103ce1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce5:	79 2e                	jns    80103d15 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	01 c2                	add    %eax,%edx
80103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf2:	8b 40 04             	mov    0x4(%eax),%eax
80103cf5:	83 ec 04             	sub    $0x4,%esp
80103cf8:	52                   	push   %edx
80103cf9:	ff 75 f4             	push   -0xc(%ebp)
80103cfc:	50                   	push   %eax
80103cfd:	e8 e2 3a 00 00       	call   801077e4 <deallocuvm>
80103d02:	83 c4 10             	add    $0x10,%esp
80103d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0c:	75 07                	jne    80103d15 <growproc+0x7e>
      return -1;
80103d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d13:	eb 1b                	jmp    80103d30 <growproc+0x99>
  }
  curproc->sz = sz;
80103d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d1b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1d:	83 ec 0c             	sub    $0xc,%esp
80103d20:	ff 75 f0             	push   -0x10(%ebp)
80103d23:	e8 db 36 00 00       	call   80107403 <switchuvm>
80103d28:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d30:	c9                   	leave
80103d31:	c3                   	ret

80103d32 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d32:	55                   	push   %ebp
80103d33:	89 e5                	mov    %esp,%ebp
80103d35:	57                   	push   %edi
80103d36:	56                   	push   %esi
80103d37:	53                   	push   %ebx
80103d38:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d3b:	e8 f0 fc ff ff       	call   80103a30 <myproc>
80103d40:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d43:	e8 11 fd ff ff       	call   80103a59 <allocproc>
80103d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d4b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4f:	75 0a                	jne    80103d5b <fork+0x29>
    return -1;
80103d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d56:	e9 48 01 00 00       	jmp    80103ea3 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5e:	8b 10                	mov    (%eax),%edx
80103d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d63:	8b 40 04             	mov    0x4(%eax),%eax
80103d66:	83 ec 08             	sub    $0x8,%esp
80103d69:	52                   	push   %edx
80103d6a:	50                   	push   %eax
80103d6b:	e8 12 3c 00 00       	call   80107982 <copyuvm>
80103d70:	83 c4 10             	add    $0x10,%esp
80103d73:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d76:	89 42 04             	mov    %eax,0x4(%edx)
80103d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7c:	8b 40 04             	mov    0x4(%eax),%eax
80103d7f:	85 c0                	test   %eax,%eax
80103d81:	75 30                	jne    80103db3 <fork+0x81>
    kfree(np->kstack);
80103d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d86:	8b 40 08             	mov    0x8(%eax),%eax
80103d89:	83 ec 0c             	sub    $0xc,%esp
80103d8c:	50                   	push   %eax
80103d8d:	e8 7c e9 ff ff       	call   8010270e <kfree>
80103d92:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dae:	e9 f0 00 00 00       	jmp    80103ea3 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db6:	8b 10                	mov    (%eax),%edx
80103db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbb:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc9:	8b 48 18             	mov    0x18(%eax),%ecx
80103dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcf:	8b 40 18             	mov    0x18(%eax),%eax
80103dd2:	89 c2                	mov    %eax,%edx
80103dd4:	89 cb                	mov    %ecx,%ebx
80103dd6:	b8 13 00 00 00       	mov    $0x13,%eax
80103ddb:	89 d7                	mov    %edx,%edi
80103ddd:	89 de                	mov    %ebx,%esi
80103ddf:	89 c1                	mov    %eax,%ecx
80103de1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de6:	8b 40 18             	mov    0x18(%eax),%eax
80103de9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103df0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df7:	eb 3b                	jmp    80103e34 <fork+0x102>
    if(curproc->ofile[i])
80103df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dff:	83 c2 08             	add    $0x8,%edx
80103e02:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e06:	85 c0                	test   %eax,%eax
80103e08:	74 26                	je     80103e30 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e10:	83 c2 08             	add    $0x8,%edx
80103e13:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	50                   	push   %eax
80103e1b:	e8 34 d2 ff ff       	call   80101054 <filedup>
80103e20:	83 c4 10             	add    $0x10,%esp
80103e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e29:	83 c1 08             	add    $0x8,%ecx
80103e2c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e30:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e34:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e38:	7e bf                	jle    80103df9 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3d:	8b 40 68             	mov    0x68(%eax),%eax
80103e40:	83 ec 0c             	sub    $0xc,%esp
80103e43:	50                   	push   %eax
80103e44:	e8 6f db ff ff       	call   801019b8 <idup>
80103e49:	83 c4 10             	add    $0x10,%esp
80103e4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e55:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5b:	83 c0 6c             	add    $0x6c,%eax
80103e5e:	83 ec 04             	sub    $0x4,%esp
80103e61:	6a 10                	push   $0x10
80103e63:	52                   	push   %edx
80103e64:	50                   	push   %eax
80103e65:	e8 39 0d 00 00       	call   80104ba3 <safestrcpy>
80103e6a:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e70:	8b 40 10             	mov    0x10(%eax),%eax
80103e73:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e76:	83 ec 0c             	sub    $0xc,%esp
80103e79:	68 00 42 19 80       	push   $0x80194200
80103e7e:	e8 a7 08 00 00       	call   8010472a <acquire>
80103e83:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e90:	83 ec 0c             	sub    $0xc,%esp
80103e93:	68 00 42 19 80       	push   $0x80194200
80103e98:	e8 fb 08 00 00       	call   80104798 <release>
80103e9d:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ea0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea6:	5b                   	pop    %ebx
80103ea7:	5e                   	pop    %esi
80103ea8:	5f                   	pop    %edi
80103ea9:	5d                   	pop    %ebp
80103eaa:	c3                   	ret

80103eab <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eab:	55                   	push   %ebp
80103eac:	89 e5                	mov    %esp,%ebp
80103eae:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eb1:	e8 7a fb ff ff       	call   80103a30 <myproc>
80103eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb9:	a1 34 63 19 80       	mov    0x80196334,%eax
80103ebe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ec1:	75 0d                	jne    80103ed0 <exit+0x25>
    panic("init exiting");
80103ec3:	83 ec 0c             	sub    $0xc,%esp
80103ec6:	68 d2 a2 10 80       	push   $0x8010a2d2
80103ecb:	e8 d9 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ed0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed7:	eb 3f                	jmp    80103f18 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edf:	83 c2 08             	add    $0x8,%edx
80103ee2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee6:	85 c0                	test   %eax,%eax
80103ee8:	74 2a                	je     80103f14 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eed:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef0:	83 c2 08             	add    $0x8,%edx
80103ef3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef7:	83 ec 0c             	sub    $0xc,%esp
80103efa:	50                   	push   %eax
80103efb:	e8 a5 d1 ff ff       	call   801010a5 <fileclose>
80103f00:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f09:	83 c2 08             	add    $0x8,%edx
80103f0c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f13:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f18:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f1c:	7e bb                	jle    80103ed9 <exit+0x2e>
    }
  }

  begin_op();
80103f1e:	e8 1b f1 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f26:	8b 40 68             	mov    0x68(%eax),%eax
80103f29:	83 ec 0c             	sub    $0xc,%esp
80103f2c:	50                   	push   %eax
80103f2d:	e8 21 dc ff ff       	call   80101b53 <iput>
80103f32:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f35:	e8 90 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f44:	83 ec 0c             	sub    $0xc,%esp
80103f47:	68 00 42 19 80       	push   $0x80194200
80103f4c:	e8 d9 07 00 00       	call   8010472a <acquire>
80103f51:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f57:	8b 40 14             	mov    0x14(%eax),%eax
80103f5a:	83 ec 0c             	sub    $0xc,%esp
80103f5d:	50                   	push   %eax
80103f5e:	e8 4a 04 00 00       	call   801043ad <wakeup1>
80103f63:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f66:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6d:	eb 3a                	jmp    80103fa9 <exit+0xfe>
    if(p->parent == curproc){
80103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f72:	8b 40 14             	mov    0x14(%eax),%eax
80103f75:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f78:	75 28                	jne    80103fa2 <exit+0xf7>
      p->parent = initproc;
80103f7a:	8b 15 34 63 19 80    	mov    0x80196334,%edx
80103f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f83:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f89:	8b 40 0c             	mov    0xc(%eax),%eax
80103f8c:	83 f8 05             	cmp    $0x5,%eax
80103f8f:	75 11                	jne    80103fa2 <exit+0xf7>
        wakeup1(initproc);
80103f91:	a1 34 63 19 80       	mov    0x80196334,%eax
80103f96:	83 ec 0c             	sub    $0xc,%esp
80103f99:	50                   	push   %eax
80103f9a:	e8 0e 04 00 00       	call   801043ad <wakeup1>
80103f9f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103fa9:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103fb0:	72 bd                	jb     80103f6f <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fbc:	e8 0c 02 00 00       	call   801041cd <sched>
  panic("zombie exit");
80103fc1:	83 ec 0c             	sub    $0xc,%esp
80103fc4:	68 df a2 10 80       	push   $0x8010a2df
80103fc9:	e8 db c5 ff ff       	call   801005a9 <panic>

80103fce <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fd4:	e8 57 fa ff ff       	call   80103a30 <myproc>
80103fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fdc:	83 ec 0c             	sub    $0xc,%esp
80103fdf:	68 00 42 19 80       	push   $0x80194200
80103fe4:	e8 41 07 00 00       	call   8010472a <acquire>
80103fe9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ff3:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ffa:	e9 a4 00 00 00       	jmp    801040a3 <wait+0xd5>
      if(p->parent != curproc)
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104002:	8b 40 14             	mov    0x14(%eax),%eax
80104005:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104008:	0f 85 8d 00 00 00    	jne    8010409b <wait+0xcd>
        continue;
      havekids = 1;
8010400e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	8b 40 0c             	mov    0xc(%eax),%eax
8010401b:	83 f8 05             	cmp    $0x5,%eax
8010401e:	75 7c                	jne    8010409c <wait+0xce>
        // Found one.
        pid = p->pid;
80104020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104023:	8b 40 10             	mov    0x10(%eax),%eax
80104026:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	8b 40 08             	mov    0x8(%eax),%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 d6 e6 ff ff       	call   8010270e <kfree>
80104038:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010403b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	8b 40 04             	mov    0x4(%eax),%eax
8010404b:	83 ec 0c             	sub    $0xc,%esp
8010404e:	50                   	push   %eax
8010404f:	e8 54 38 00 00       	call   801078a8 <freevm>
80104054:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010406b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104086:	83 ec 0c             	sub    $0xc,%esp
80104089:	68 00 42 19 80       	push   $0x80194200
8010408e:	e8 05 07 00 00       	call   80104798 <release>
80104093:	83 c4 10             	add    $0x10,%esp
        return pid;
80104096:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104099:	eb 54                	jmp    801040ef <wait+0x121>
        continue;
8010409b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010409c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801040a3:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
801040aa:	0f 82 4f ff ff ff    	jb     80103fff <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040b4:	74 0a                	je     801040c0 <wait+0xf2>
801040b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b9:	8b 40 24             	mov    0x24(%eax),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	74 17                	je     801040d7 <wait+0x109>
      release(&ptable.lock);
801040c0:	83 ec 0c             	sub    $0xc,%esp
801040c3:	68 00 42 19 80       	push   $0x80194200
801040c8:	e8 cb 06 00 00       	call   80104798 <release>
801040cd:	83 c4 10             	add    $0x10,%esp
      return -1;
801040d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d5:	eb 18                	jmp    801040ef <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040d7:	83 ec 08             	sub    $0x8,%esp
801040da:	68 00 42 19 80       	push   $0x80194200
801040df:	ff 75 ec             	push   -0x14(%ebp)
801040e2:	e8 1f 02 00 00       	call   80104306 <sleep>
801040e7:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040ea:	e9 fd fe ff ff       	jmp    80103fec <wait+0x1e>
  }
}
801040ef:	c9                   	leave
801040f0:	c3                   	ret

801040f1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040f1:	55                   	push   %ebp
801040f2:	89 e5                	mov    %esp,%ebp
801040f4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040f7:	e8 bc f8 ff ff       	call   801039b8 <mycpu>
801040fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104102:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104109:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010410c:	e8 67 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104111:	83 ec 0c             	sub    $0xc,%esp
80104114:	68 00 42 19 80       	push   $0x80194200
80104119:	e8 0c 06 00 00       	call   8010472a <acquire>
8010411e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104121:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104128:	eb 64                	jmp    8010418e <scheduler+0x9d>
      if(p->state != RUNNABLE)
8010412a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412d:	8b 40 0c             	mov    0xc(%eax),%eax
80104130:	83 f8 03             	cmp    $0x3,%eax
80104133:	75 51                	jne    80104186 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104138:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104141:	83 ec 0c             	sub    $0xc,%esp
80104144:	ff 75 f4             	push   -0xc(%ebp)
80104147:	e8 b7 32 00 00       	call   80107403 <switchuvm>
8010414c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010415f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104162:	83 c2 04             	add    $0x4,%edx
80104165:	83 ec 08             	sub    $0x8,%esp
80104168:	50                   	push   %eax
80104169:	52                   	push   %edx
8010416a:	e8 a6 0a 00 00       	call   80104c15 <swtch>
8010416f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104172:	e8 73 32 00 00       	call   801073ea <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104181:	00 00 00 
80104184:	eb 01                	jmp    80104187 <scheduler+0x96>
        continue;
80104186:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104187:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010418e:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104195:	72 93                	jb     8010412a <scheduler+0x39>
    }
    release(&ptable.lock);
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	68 00 42 19 80       	push   $0x80194200
8010419f:	e8 f4 05 00 00       	call   80104798 <release>
801041a4:	83 c4 10             	add    $0x10,%esp
    sti();
801041a7:	e9 60 ff ff ff       	jmp    8010410c <scheduler+0x1b>

801041ac <uthread_init>:
  }
}

int
uthread_init(void (*address)(void))
{
801041ac:	55                   	push   %ebp
801041ad:	89 e5                	mov    %esp,%ebp
801041af:	83 ec 18             	sub    $0x18,%esp
    struct proc* p = myproc();
801041b2:	e8 79 f8 ff ff       	call   80103a30 <myproc>
801041b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p->scheduler = address;
801041ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bd:	8b 55 08             	mov    0x8(%ebp),%edx
801041c0:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    return 0;
801041c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041cb:	c9                   	leave
801041cc:	c3                   	ret

801041cd <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041cd:	55                   	push   %ebp
801041ce:	89 e5                	mov    %esp,%ebp
801041d0:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041d3:	e8 58 f8 ff ff       	call   80103a30 <myproc>
801041d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041db:	83 ec 0c             	sub    $0xc,%esp
801041de:	68 00 42 19 80       	push   $0x80194200
801041e3:	e8 7d 06 00 00       	call   80104865 <holding>
801041e8:	83 c4 10             	add    $0x10,%esp
801041eb:	85 c0                	test   %eax,%eax
801041ed:	75 0d                	jne    801041fc <sched+0x2f>
    panic("sched ptable.lock");
801041ef:	83 ec 0c             	sub    $0xc,%esp
801041f2:	68 eb a2 10 80       	push   $0x8010a2eb
801041f7:	e8 ad c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041fc:	e8 b7 f7 ff ff       	call   801039b8 <mycpu>
80104201:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104207:	83 f8 01             	cmp    $0x1,%eax
8010420a:	74 0d                	je     80104219 <sched+0x4c>
    panic("sched locks");
8010420c:	83 ec 0c             	sub    $0xc,%esp
8010420f:	68 fd a2 10 80       	push   $0x8010a2fd
80104214:	e8 90 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421c:	8b 40 0c             	mov    0xc(%eax),%eax
8010421f:	83 f8 04             	cmp    $0x4,%eax
80104222:	75 0d                	jne    80104231 <sched+0x64>
    panic("sched running");
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	68 09 a3 10 80       	push   $0x8010a309
8010422c:	e8 78 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104231:	e8 32 f7 ff ff       	call   80103968 <readeflags>
80104236:	25 00 02 00 00       	and    $0x200,%eax
8010423b:	85 c0                	test   %eax,%eax
8010423d:	74 0d                	je     8010424c <sched+0x7f>
    panic("sched interruptible");
8010423f:	83 ec 0c             	sub    $0xc,%esp
80104242:	68 17 a3 10 80       	push   $0x8010a317
80104247:	e8 5d c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010424c:	e8 67 f7 ff ff       	call   801039b8 <mycpu>
80104251:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104257:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010425a:	e8 59 f7 ff ff       	call   801039b8 <mycpu>
8010425f:	8b 40 04             	mov    0x4(%eax),%eax
80104262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104265:	83 c2 1c             	add    $0x1c,%edx
80104268:	83 ec 08             	sub    $0x8,%esp
8010426b:	50                   	push   %eax
8010426c:	52                   	push   %edx
8010426d:	e8 a3 09 00 00       	call   80104c15 <swtch>
80104272:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104275:	e8 3e f7 ff ff       	call   801039b8 <mycpu>
8010427a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010427d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104283:	90                   	nop
80104284:	c9                   	leave
80104285:	c3                   	ret

80104286 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104286:	55                   	push   %ebp
80104287:	89 e5                	mov    %esp,%ebp
80104289:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010428c:	83 ec 0c             	sub    $0xc,%esp
8010428f:	68 00 42 19 80       	push   $0x80194200
80104294:	e8 91 04 00 00       	call   8010472a <acquire>
80104299:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010429c:	e8 8f f7 ff ff       	call   80103a30 <myproc>
801042a1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801042a8:	e8 20 ff ff ff       	call   801041cd <sched>
  release(&ptable.lock);
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	68 00 42 19 80       	push   $0x80194200
801042b5:	e8 de 04 00 00       	call   80104798 <release>
801042ba:	83 c4 10             	add    $0x10,%esp
}
801042bd:	90                   	nop
801042be:	c9                   	leave
801042bf:	c3                   	ret

801042c0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801042c0:	55                   	push   %ebp
801042c1:	89 e5                	mov    %esp,%ebp
801042c3:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042c6:	83 ec 0c             	sub    $0xc,%esp
801042c9:	68 00 42 19 80       	push   $0x80194200
801042ce:	e8 c5 04 00 00       	call   80104798 <release>
801042d3:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042d6:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042db:	85 c0                	test   %eax,%eax
801042dd:	74 24                	je     80104303 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042df:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042e6:	00 00 00 
    iinit(ROOTDEV);
801042e9:	83 ec 0c             	sub    $0xc,%esp
801042ec:	6a 01                	push   $0x1
801042ee:	e8 8e d3 ff ff       	call   80101681 <iinit>
801042f3:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	6a 01                	push   $0x1
801042fb:	e8 1f eb ff ff       	call   80102e1f <initlog>
80104300:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104303:	90                   	nop
80104304:	c9                   	leave
80104305:	c3                   	ret

80104306 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104306:	55                   	push   %ebp
80104307:	89 e5                	mov    %esp,%ebp
80104309:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010430c:	e8 1f f7 ff ff       	call   80103a30 <myproc>
80104311:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104314:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104318:	75 0d                	jne    80104327 <sleep+0x21>
    panic("sleep");
8010431a:	83 ec 0c             	sub    $0xc,%esp
8010431d:	68 2b a3 10 80       	push   $0x8010a32b
80104322:	e8 82 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104327:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010432b:	75 0d                	jne    8010433a <sleep+0x34>
    panic("sleep without lk");
8010432d:	83 ec 0c             	sub    $0xc,%esp
80104330:	68 31 a3 10 80       	push   $0x8010a331
80104335:	e8 6f c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010433a:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104341:	74 1e                	je     80104361 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104343:	83 ec 0c             	sub    $0xc,%esp
80104346:	68 00 42 19 80       	push   $0x80194200
8010434b:	e8 da 03 00 00       	call   8010472a <acquire>
80104350:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104353:	83 ec 0c             	sub    $0xc,%esp
80104356:	ff 75 0c             	push   0xc(%ebp)
80104359:	e8 3a 04 00 00       	call   80104798 <release>
8010435e:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104364:	8b 55 08             	mov    0x8(%ebp),%edx
80104367:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104374:	e8 54 fe ff ff       	call   801041cd <sched>

  // Tidy up.
  p->chan = 0;
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104383:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010438a:	74 1e                	je     801043aa <sleep+0xa4>
    release(&ptable.lock);
8010438c:	83 ec 0c             	sub    $0xc,%esp
8010438f:	68 00 42 19 80       	push   $0x80194200
80104394:	e8 ff 03 00 00       	call   80104798 <release>
80104399:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010439c:	83 ec 0c             	sub    $0xc,%esp
8010439f:	ff 75 0c             	push   0xc(%ebp)
801043a2:	e8 83 03 00 00       	call   8010472a <acquire>
801043a7:	83 c4 10             	add    $0x10,%esp
  }
}
801043aa:	90                   	nop
801043ab:	c9                   	leave
801043ac:	c3                   	ret

801043ad <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801043ad:	55                   	push   %ebp
801043ae:	89 e5                	mov    %esp,%ebp
801043b0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b3:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801043ba:	eb 27                	jmp    801043e3 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801043bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043bf:	8b 40 0c             	mov    0xc(%eax),%eax
801043c2:	83 f8 02             	cmp    $0x2,%eax
801043c5:	75 15                	jne    801043dc <wakeup1+0x2f>
801043c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043ca:	8b 40 20             	mov    0x20(%eax),%eax
801043cd:	39 45 08             	cmp    %eax,0x8(%ebp)
801043d0:	75 0a                	jne    801043dc <wakeup1+0x2f>
      p->state = RUNNABLE;
801043d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043d5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043dc:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801043e3:	81 7d fc 34 63 19 80 	cmpl   $0x80196334,-0x4(%ebp)
801043ea:	72 d0                	jb     801043bc <wakeup1+0xf>
}
801043ec:	90                   	nop
801043ed:	90                   	nop
801043ee:	c9                   	leave
801043ef:	c3                   	ret

801043f0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043f6:	83 ec 0c             	sub    $0xc,%esp
801043f9:	68 00 42 19 80       	push   $0x80194200
801043fe:	e8 27 03 00 00       	call   8010472a <acquire>
80104403:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	ff 75 08             	push   0x8(%ebp)
8010440c:	e8 9c ff ff ff       	call   801043ad <wakeup1>
80104411:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104414:	83 ec 0c             	sub    $0xc,%esp
80104417:	68 00 42 19 80       	push   $0x80194200
8010441c:	e8 77 03 00 00       	call   80104798 <release>
80104421:	83 c4 10             	add    $0x10,%esp
}
80104424:	90                   	nop
80104425:	c9                   	leave
80104426:	c3                   	ret

80104427 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104427:	55                   	push   %ebp
80104428:	89 e5                	mov    %esp,%ebp
8010442a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010442d:	83 ec 0c             	sub    $0xc,%esp
80104430:	68 00 42 19 80       	push   $0x80194200
80104435:	e8 f0 02 00 00       	call   8010472a <acquire>
8010443a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010443d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104444:	eb 48                	jmp    8010448e <kill+0x67>
    if(p->pid == pid){
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 10             	mov    0x10(%eax),%eax
8010444c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010444f:	75 36                	jne    80104487 <kill+0x60>
      p->killed = 1;
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010445b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445e:	8b 40 0c             	mov    0xc(%eax),%eax
80104461:	83 f8 02             	cmp    $0x2,%eax
80104464:	75 0a                	jne    80104470 <kill+0x49>
        p->state = RUNNABLE;
80104466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104469:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104470:	83 ec 0c             	sub    $0xc,%esp
80104473:	68 00 42 19 80       	push   $0x80194200
80104478:	e8 1b 03 00 00       	call   80104798 <release>
8010447d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104480:	b8 00 00 00 00       	mov    $0x0,%eax
80104485:	eb 25                	jmp    801044ac <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104487:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010448e:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104495:	72 af                	jb     80104446 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104497:	83 ec 0c             	sub    $0xc,%esp
8010449a:	68 00 42 19 80       	push   $0x80194200
8010449f:	e8 f4 02 00 00       	call   80104798 <release>
801044a4:	83 c4 10             	add    $0x10,%esp
  return -1;
801044a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044ac:	c9                   	leave
801044ad:	c3                   	ret

801044ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801044ae:	55                   	push   %ebp
801044af:	89 e5                	mov    %esp,%ebp
801044b1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044b4:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
801044bb:	e9 da 00 00 00       	jmp    8010459a <procdump+0xec>
    if(p->state == UNUSED)
801044c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c3:	8b 40 0c             	mov    0xc(%eax),%eax
801044c6:	85 c0                	test   %eax,%eax
801044c8:	0f 84 c4 00 00 00    	je     80104592 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d1:	8b 40 0c             	mov    0xc(%eax),%eax
801044d4:	83 f8 05             	cmp    $0x5,%eax
801044d7:	77 23                	ja     801044fc <procdump+0x4e>
801044d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044dc:	8b 40 0c             	mov    0xc(%eax),%eax
801044df:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044e6:	85 c0                	test   %eax,%eax
801044e8:	74 12                	je     801044fc <procdump+0x4e>
      state = states[p->state];
801044ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ed:	8b 40 0c             	mov    0xc(%eax),%eax
801044f0:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044fa:	eb 07                	jmp    80104503 <procdump+0x55>
    else
      state = "???";
801044fc:	c7 45 ec 42 a3 10 80 	movl   $0x8010a342,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104506:	8d 50 6c             	lea    0x6c(%eax),%edx
80104509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450c:	8b 40 10             	mov    0x10(%eax),%eax
8010450f:	52                   	push   %edx
80104510:	ff 75 ec             	push   -0x14(%ebp)
80104513:	50                   	push   %eax
80104514:	68 46 a3 10 80       	push   $0x8010a346
80104519:	e8 d6 be ff ff       	call   801003f4 <cprintf>
8010451e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104524:	8b 40 0c             	mov    0xc(%eax),%eax
80104527:	83 f8 02             	cmp    $0x2,%eax
8010452a:	75 54                	jne    80104580 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010452c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010452f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104532:	8b 40 0c             	mov    0xc(%eax),%eax
80104535:	83 c0 08             	add    $0x8,%eax
80104538:	89 c2                	mov    %eax,%edx
8010453a:	83 ec 08             	sub    $0x8,%esp
8010453d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104540:	50                   	push   %eax
80104541:	52                   	push   %edx
80104542:	e8 a3 02 00 00       	call   801047ea <getcallerpcs>
80104547:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010454a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104551:	eb 1c                	jmp    8010456f <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010455a:	83 ec 08             	sub    $0x8,%esp
8010455d:	50                   	push   %eax
8010455e:	68 4f a3 10 80       	push   $0x8010a34f
80104563:	e8 8c be ff ff       	call   801003f4 <cprintf>
80104568:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010456b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010456f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104573:	7f 0b                	jg     80104580 <procdump+0xd2>
80104575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104578:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010457c:	85 c0                	test   %eax,%eax
8010457e:	75 d3                	jne    80104553 <procdump+0xa5>
    }
    cprintf("\n");
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	68 53 a3 10 80       	push   $0x8010a353
80104588:	e8 67 be ff ff       	call   801003f4 <cprintf>
8010458d:	83 c4 10             	add    $0x10,%esp
80104590:	eb 01                	jmp    80104593 <procdump+0xe5>
      continue;
80104592:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104593:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
8010459a:	81 7d f0 34 63 19 80 	cmpl   $0x80196334,-0x10(%ebp)
801045a1:	0f 82 19 ff ff ff    	jb     801044c0 <procdump+0x12>
  }
}
801045a7:	90                   	nop
801045a8:	90                   	nop
801045a9:	c9                   	leave
801045aa:	c3                   	ret

801045ab <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801045ab:	55                   	push   %ebp
801045ac:	89 e5                	mov    %esp,%ebp
801045ae:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801045b1:	8b 45 08             	mov    0x8(%ebp),%eax
801045b4:	83 c0 04             	add    $0x4,%eax
801045b7:	83 ec 08             	sub    $0x8,%esp
801045ba:	68 7f a3 10 80       	push   $0x8010a37f
801045bf:	50                   	push   %eax
801045c0:	e8 43 01 00 00       	call   80104708 <initlock>
801045c5:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045c8:	8b 45 08             	mov    0x8(%ebp),%eax
801045cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801045ce:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045d1:	8b 45 08             	mov    0x8(%ebp),%eax
801045d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045da:	8b 45 08             	mov    0x8(%ebp),%eax
801045dd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045e4:	90                   	nop
801045e5:	c9                   	leave
801045e6:	c3                   	ret

801045e7 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045e7:	55                   	push   %ebp
801045e8:	89 e5                	mov    %esp,%ebp
801045ea:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045ed:	8b 45 08             	mov    0x8(%ebp),%eax
801045f0:	83 c0 04             	add    $0x4,%eax
801045f3:	83 ec 0c             	sub    $0xc,%esp
801045f6:	50                   	push   %eax
801045f7:	e8 2e 01 00 00       	call   8010472a <acquire>
801045fc:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045ff:	eb 15                	jmp    80104616 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104601:	8b 45 08             	mov    0x8(%ebp),%eax
80104604:	83 c0 04             	add    $0x4,%eax
80104607:	83 ec 08             	sub    $0x8,%esp
8010460a:	50                   	push   %eax
8010460b:	ff 75 08             	push   0x8(%ebp)
8010460e:	e8 f3 fc ff ff       	call   80104306 <sleep>
80104613:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104616:	8b 45 08             	mov    0x8(%ebp),%eax
80104619:	8b 00                	mov    (%eax),%eax
8010461b:	85 c0                	test   %eax,%eax
8010461d:	75 e2                	jne    80104601 <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010461f:	8b 45 08             	mov    0x8(%ebp),%eax
80104622:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104628:	e8 03 f4 ff ff       	call   80103a30 <myproc>
8010462d:	8b 50 10             	mov    0x10(%eax),%edx
80104630:	8b 45 08             	mov    0x8(%ebp),%eax
80104633:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104636:	8b 45 08             	mov    0x8(%ebp),%eax
80104639:	83 c0 04             	add    $0x4,%eax
8010463c:	83 ec 0c             	sub    $0xc,%esp
8010463f:	50                   	push   %eax
80104640:	e8 53 01 00 00       	call   80104798 <release>
80104645:	83 c4 10             	add    $0x10,%esp
}
80104648:	90                   	nop
80104649:	c9                   	leave
8010464a:	c3                   	ret

8010464b <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010464b:	55                   	push   %ebp
8010464c:	89 e5                	mov    %esp,%ebp
8010464e:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104651:	8b 45 08             	mov    0x8(%ebp),%eax
80104654:	83 c0 04             	add    $0x4,%eax
80104657:	83 ec 0c             	sub    $0xc,%esp
8010465a:	50                   	push   %eax
8010465b:	e8 ca 00 00 00       	call   8010472a <acquire>
80104660:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104663:	8b 45 08             	mov    0x8(%ebp),%eax
80104666:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010466c:	8b 45 08             	mov    0x8(%ebp),%eax
8010466f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104676:	83 ec 0c             	sub    $0xc,%esp
80104679:	ff 75 08             	push   0x8(%ebp)
8010467c:	e8 6f fd ff ff       	call   801043f0 <wakeup>
80104681:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104684:	8b 45 08             	mov    0x8(%ebp),%eax
80104687:	83 c0 04             	add    $0x4,%eax
8010468a:	83 ec 0c             	sub    $0xc,%esp
8010468d:	50                   	push   %eax
8010468e:	e8 05 01 00 00       	call   80104798 <release>
80104693:	83 c4 10             	add    $0x10,%esp
}
80104696:	90                   	nop
80104697:	c9                   	leave
80104698:	c3                   	ret

80104699 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104699:	55                   	push   %ebp
8010469a:	89 e5                	mov    %esp,%ebp
8010469c:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010469f:	8b 45 08             	mov    0x8(%ebp),%eax
801046a2:	83 c0 04             	add    $0x4,%eax
801046a5:	83 ec 0c             	sub    $0xc,%esp
801046a8:	50                   	push   %eax
801046a9:	e8 7c 00 00 00       	call   8010472a <acquire>
801046ae:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801046b1:	8b 45 08             	mov    0x8(%ebp),%eax
801046b4:	8b 00                	mov    (%eax),%eax
801046b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801046b9:	8b 45 08             	mov    0x8(%ebp),%eax
801046bc:	83 c0 04             	add    $0x4,%eax
801046bf:	83 ec 0c             	sub    $0xc,%esp
801046c2:	50                   	push   %eax
801046c3:	e8 d0 00 00 00       	call   80104798 <release>
801046c8:	83 c4 10             	add    $0x10,%esp
  return r;
801046cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ce:	c9                   	leave
801046cf:	c3                   	ret

801046d0 <readeflags>:
{
801046d0:	55                   	push   %ebp
801046d1:	89 e5                	mov    %esp,%ebp
801046d3:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046d6:	9c                   	pushf
801046d7:	58                   	pop    %eax
801046d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046de:	c9                   	leave
801046df:	c3                   	ret

801046e0 <cli>:
{
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046e3:	fa                   	cli
}
801046e4:	90                   	nop
801046e5:	5d                   	pop    %ebp
801046e6:	c3                   	ret

801046e7 <sti>:
{
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046ea:	fb                   	sti
}
801046eb:	90                   	nop
801046ec:	5d                   	pop    %ebp
801046ed:	c3                   	ret

801046ee <xchg>:
{
801046ee:	55                   	push   %ebp
801046ef:	89 e5                	mov    %esp,%ebp
801046f1:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046f4:	8b 55 08             	mov    0x8(%ebp),%edx
801046f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801046fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046fd:	f0 87 02             	lock xchg %eax,(%edx)
80104700:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104703:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104706:	c9                   	leave
80104707:	c3                   	ret

80104708 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104708:	55                   	push   %ebp
80104709:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010470b:	8b 45 08             	mov    0x8(%ebp),%eax
8010470e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104711:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104714:	8b 45 08             	mov    0x8(%ebp),%eax
80104717:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010471d:	8b 45 08             	mov    0x8(%ebp),%eax
80104720:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104727:	90                   	nop
80104728:	5d                   	pop    %ebp
80104729:	c3                   	ret

8010472a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010472a:	55                   	push   %ebp
8010472b:	89 e5                	mov    %esp,%ebp
8010472d:	53                   	push   %ebx
8010472e:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104731:	e8 5f 01 00 00       	call   80104895 <pushcli>
  if(holding(lk)){
80104736:	8b 45 08             	mov    0x8(%ebp),%eax
80104739:	83 ec 0c             	sub    $0xc,%esp
8010473c:	50                   	push   %eax
8010473d:	e8 23 01 00 00       	call   80104865 <holding>
80104742:	83 c4 10             	add    $0x10,%esp
80104745:	85 c0                	test   %eax,%eax
80104747:	74 0d                	je     80104756 <acquire+0x2c>
    panic("acquire");
80104749:	83 ec 0c             	sub    $0xc,%esp
8010474c:	68 8a a3 10 80       	push   $0x8010a38a
80104751:	e8 53 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104756:	90                   	nop
80104757:	8b 45 08             	mov    0x8(%ebp),%eax
8010475a:	83 ec 08             	sub    $0x8,%esp
8010475d:	6a 01                	push   $0x1
8010475f:	50                   	push   %eax
80104760:	e8 89 ff ff ff       	call   801046ee <xchg>
80104765:	83 c4 10             	add    $0x10,%esp
80104768:	85 c0                	test   %eax,%eax
8010476a:	75 eb                	jne    80104757 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010476c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104771:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104774:	e8 3f f2 ff ff       	call   801039b8 <mycpu>
80104779:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010477c:	8b 45 08             	mov    0x8(%ebp),%eax
8010477f:	83 c0 0c             	add    $0xc,%eax
80104782:	83 ec 08             	sub    $0x8,%esp
80104785:	50                   	push   %eax
80104786:	8d 45 08             	lea    0x8(%ebp),%eax
80104789:	50                   	push   %eax
8010478a:	e8 5b 00 00 00       	call   801047ea <getcallerpcs>
8010478f:	83 c4 10             	add    $0x10,%esp
}
80104792:	90                   	nop
80104793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104796:	c9                   	leave
80104797:	c3                   	ret

80104798 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104798:	55                   	push   %ebp
80104799:	89 e5                	mov    %esp,%ebp
8010479b:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	ff 75 08             	push   0x8(%ebp)
801047a4:	e8 bc 00 00 00       	call   80104865 <holding>
801047a9:	83 c4 10             	add    $0x10,%esp
801047ac:	85 c0                	test   %eax,%eax
801047ae:	75 0d                	jne    801047bd <release+0x25>
    panic("release");
801047b0:	83 ec 0c             	sub    $0xc,%esp
801047b3:	68 92 a3 10 80       	push   $0x8010a392
801047b8:	e8 ec bd ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801047bd:	8b 45 08             	mov    0x8(%ebp),%eax
801047c0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047d1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047d6:	8b 45 08             	mov    0x8(%ebp),%eax
801047d9:	8b 55 08             	mov    0x8(%ebp),%edx
801047dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047e2:	e8 fb 00 00 00       	call   801048e2 <popcli>
}
801047e7:	90                   	nop
801047e8:	c9                   	leave
801047e9:	c3                   	ret

801047ea <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047ea:	55                   	push   %ebp
801047eb:	89 e5                	mov    %esp,%ebp
801047ed:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047f0:	8b 45 08             	mov    0x8(%ebp),%eax
801047f3:	83 e8 08             	sub    $0x8,%eax
801047f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104800:	eb 38                	jmp    8010483a <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104802:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104806:	74 53                	je     8010485b <getcallerpcs+0x71>
80104808:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010480f:	76 4a                	jbe    8010485b <getcallerpcs+0x71>
80104811:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104815:	74 44                	je     8010485b <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104817:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010481a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104821:	8b 45 0c             	mov    0xc(%ebp),%eax
80104824:	01 c2                	add    %eax,%edx
80104826:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104829:	8b 40 04             	mov    0x4(%eax),%eax
8010482c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010482e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104831:	8b 00                	mov    (%eax),%eax
80104833:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104836:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010483a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010483e:	7e c2                	jle    80104802 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104840:	eb 19                	jmp    8010485b <getcallerpcs+0x71>
    pcs[i] = 0;
80104842:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104845:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010484c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010484f:	01 d0                	add    %edx,%eax
80104851:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104857:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010485b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010485f:	7e e1                	jle    80104842 <getcallerpcs+0x58>
}
80104861:	90                   	nop
80104862:	90                   	nop
80104863:	c9                   	leave
80104864:	c3                   	ret

80104865 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104865:	55                   	push   %ebp
80104866:	89 e5                	mov    %esp,%ebp
80104868:	53                   	push   %ebx
80104869:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010486c:	8b 45 08             	mov    0x8(%ebp),%eax
8010486f:	8b 00                	mov    (%eax),%eax
80104871:	85 c0                	test   %eax,%eax
80104873:	74 16                	je     8010488b <holding+0x26>
80104875:	8b 45 08             	mov    0x8(%ebp),%eax
80104878:	8b 58 08             	mov    0x8(%eax),%ebx
8010487b:	e8 38 f1 ff ff       	call   801039b8 <mycpu>
80104880:	39 c3                	cmp    %eax,%ebx
80104882:	75 07                	jne    8010488b <holding+0x26>
80104884:	b8 01 00 00 00       	mov    $0x1,%eax
80104889:	eb 05                	jmp    80104890 <holding+0x2b>
8010488b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104893:	c9                   	leave
80104894:	c3                   	ret

80104895 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104895:	55                   	push   %ebp
80104896:	89 e5                	mov    %esp,%ebp
80104898:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010489b:	e8 30 fe ff ff       	call   801046d0 <readeflags>
801048a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801048a3:	e8 38 fe ff ff       	call   801046e0 <cli>
  if(mycpu()->ncli == 0)
801048a8:	e8 0b f1 ff ff       	call   801039b8 <mycpu>
801048ad:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048b3:	85 c0                	test   %eax,%eax
801048b5:	75 14                	jne    801048cb <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801048b7:	e8 fc f0 ff ff       	call   801039b8 <mycpu>
801048bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048bf:	81 e2 00 02 00 00    	and    $0x200,%edx
801048c5:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048cb:	e8 e8 f0 ff ff       	call   801039b8 <mycpu>
801048d0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048d6:	83 c2 01             	add    $0x1,%edx
801048d9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048df:	90                   	nop
801048e0:	c9                   	leave
801048e1:	c3                   	ret

801048e2 <popcli>:

void
popcli(void)
{
801048e2:	55                   	push   %ebp
801048e3:	89 e5                	mov    %esp,%ebp
801048e5:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048e8:	e8 e3 fd ff ff       	call   801046d0 <readeflags>
801048ed:	25 00 02 00 00       	and    $0x200,%eax
801048f2:	85 c0                	test   %eax,%eax
801048f4:	74 0d                	je     80104903 <popcli+0x21>
    panic("popcli - interruptible");
801048f6:	83 ec 0c             	sub    $0xc,%esp
801048f9:	68 9a a3 10 80       	push   $0x8010a39a
801048fe:	e8 a6 bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104903:	e8 b0 f0 ff ff       	call   801039b8 <mycpu>
80104908:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010490e:	83 ea 01             	sub    $0x1,%edx
80104911:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104917:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010491d:	85 c0                	test   %eax,%eax
8010491f:	79 0d                	jns    8010492e <popcli+0x4c>
    panic("popcli");
80104921:	83 ec 0c             	sub    $0xc,%esp
80104924:	68 b1 a3 10 80       	push   $0x8010a3b1
80104929:	e8 7b bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010492e:	e8 85 f0 ff ff       	call   801039b8 <mycpu>
80104933:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104939:	85 c0                	test   %eax,%eax
8010493b:	75 14                	jne    80104951 <popcli+0x6f>
8010493d:	e8 76 f0 ff ff       	call   801039b8 <mycpu>
80104942:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104948:	85 c0                	test   %eax,%eax
8010494a:	74 05                	je     80104951 <popcli+0x6f>
    sti();
8010494c:	e8 96 fd ff ff       	call   801046e7 <sti>
}
80104951:	90                   	nop
80104952:	c9                   	leave
80104953:	c3                   	ret

80104954 <stosb>:
{
80104954:	55                   	push   %ebp
80104955:	89 e5                	mov    %esp,%ebp
80104957:	57                   	push   %edi
80104958:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104959:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010495c:	8b 55 10             	mov    0x10(%ebp),%edx
8010495f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104962:	89 cb                	mov    %ecx,%ebx
80104964:	89 df                	mov    %ebx,%edi
80104966:	89 d1                	mov    %edx,%ecx
80104968:	fc                   	cld
80104969:	f3 aa                	rep stos %al,%es:(%edi)
8010496b:	89 ca                	mov    %ecx,%edx
8010496d:	89 fb                	mov    %edi,%ebx
8010496f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104972:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104975:	90                   	nop
80104976:	5b                   	pop    %ebx
80104977:	5f                   	pop    %edi
80104978:	5d                   	pop    %ebp
80104979:	c3                   	ret

8010497a <stosl>:
{
8010497a:	55                   	push   %ebp
8010497b:	89 e5                	mov    %esp,%ebp
8010497d:	57                   	push   %edi
8010497e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010497f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104982:	8b 55 10             	mov    0x10(%ebp),%edx
80104985:	8b 45 0c             	mov    0xc(%ebp),%eax
80104988:	89 cb                	mov    %ecx,%ebx
8010498a:	89 df                	mov    %ebx,%edi
8010498c:	89 d1                	mov    %edx,%ecx
8010498e:	fc                   	cld
8010498f:	f3 ab                	rep stos %eax,%es:(%edi)
80104991:	89 ca                	mov    %ecx,%edx
80104993:	89 fb                	mov    %edi,%ebx
80104995:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104998:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010499b:	90                   	nop
8010499c:	5b                   	pop    %ebx
8010499d:	5f                   	pop    %edi
8010499e:	5d                   	pop    %ebp
8010499f:	c3                   	ret

801049a0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801049a0:	55                   	push   %ebp
801049a1:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
801049a6:	83 e0 03             	and    $0x3,%eax
801049a9:	85 c0                	test   %eax,%eax
801049ab:	75 43                	jne    801049f0 <memset+0x50>
801049ad:	8b 45 10             	mov    0x10(%ebp),%eax
801049b0:	83 e0 03             	and    $0x3,%eax
801049b3:	85 c0                	test   %eax,%eax
801049b5:	75 39                	jne    801049f0 <memset+0x50>
    c &= 0xFF;
801049b7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049be:	8b 45 10             	mov    0x10(%ebp),%eax
801049c1:	c1 e8 02             	shr    $0x2,%eax
801049c4:	89 c1                	mov    %eax,%ecx
801049c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c9:	c1 e0 18             	shl    $0x18,%eax
801049cc:	89 c2                	mov    %eax,%edx
801049ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801049d1:	c1 e0 10             	shl    $0x10,%eax
801049d4:	09 c2                	or     %eax,%edx
801049d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801049d9:	c1 e0 08             	shl    $0x8,%eax
801049dc:	09 d0                	or     %edx,%eax
801049de:	0b 45 0c             	or     0xc(%ebp),%eax
801049e1:	51                   	push   %ecx
801049e2:	50                   	push   %eax
801049e3:	ff 75 08             	push   0x8(%ebp)
801049e6:	e8 8f ff ff ff       	call   8010497a <stosl>
801049eb:	83 c4 0c             	add    $0xc,%esp
801049ee:	eb 12                	jmp    80104a02 <memset+0x62>
  } else
    stosb(dst, c, n);
801049f0:	8b 45 10             	mov    0x10(%ebp),%eax
801049f3:	50                   	push   %eax
801049f4:	ff 75 0c             	push   0xc(%ebp)
801049f7:	ff 75 08             	push   0x8(%ebp)
801049fa:	e8 55 ff ff ff       	call   80104954 <stosb>
801049ff:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104a02:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104a05:	c9                   	leave
80104a06:	c3                   	ret

80104a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104a07:	55                   	push   %ebp
80104a08:	89 e5                	mov    %esp,%ebp
80104a0a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a10:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104a13:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a16:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104a19:	eb 2e                	jmp    80104a49 <memcmp+0x42>
    if(*s1 != *s2)
80104a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a1e:	0f b6 10             	movzbl (%eax),%edx
80104a21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a24:	0f b6 00             	movzbl (%eax),%eax
80104a27:	38 c2                	cmp    %al,%dl
80104a29:	74 16                	je     80104a41 <memcmp+0x3a>
      return *s1 - *s2;
80104a2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a2e:	0f b6 00             	movzbl (%eax),%eax
80104a31:	0f b6 d0             	movzbl %al,%edx
80104a34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a37:	0f b6 00             	movzbl (%eax),%eax
80104a3a:	0f b6 c0             	movzbl %al,%eax
80104a3d:	29 c2                	sub    %eax,%edx
80104a3f:	eb 1a                	jmp    80104a5b <memcmp+0x54>
    s1++, s2++;
80104a41:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a45:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a49:	8b 45 10             	mov    0x10(%ebp),%eax
80104a4c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a4f:	89 55 10             	mov    %edx,0x10(%ebp)
80104a52:	85 c0                	test   %eax,%eax
80104a54:	75 c5                	jne    80104a1b <memcmp+0x14>
  }

  return 0;
80104a56:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104a5b:	89 d0                	mov    %edx,%eax
80104a5d:	c9                   	leave
80104a5e:	c3                   	ret

80104a5f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a5f:	55                   	push   %ebp
80104a60:	89 e5                	mov    %esp,%ebp
80104a62:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a65:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a74:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a77:	73 54                	jae    80104acd <memmove+0x6e>
80104a79:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104a7f:	01 d0                	add    %edx,%eax
80104a81:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a84:	73 47                	jae    80104acd <memmove+0x6e>
    s += n;
80104a86:	8b 45 10             	mov    0x10(%ebp),%eax
80104a89:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a8c:	8b 45 10             	mov    0x10(%ebp),%eax
80104a8f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a92:	eb 13                	jmp    80104aa7 <memmove+0x48>
      *--d = *--s;
80104a94:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a98:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a9f:	0f b6 10             	movzbl (%eax),%edx
80104aa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aa5:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104aa7:	8b 45 10             	mov    0x10(%ebp),%eax
80104aaa:	8d 50 ff             	lea    -0x1(%eax),%edx
80104aad:	89 55 10             	mov    %edx,0x10(%ebp)
80104ab0:	85 c0                	test   %eax,%eax
80104ab2:	75 e0                	jne    80104a94 <memmove+0x35>
  if(s < d && s + n > d){
80104ab4:	eb 24                	jmp    80104ada <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104ab6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ab9:	8d 42 01             	lea    0x1(%edx),%eax
80104abc:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104abf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ac2:	8d 48 01             	lea    0x1(%eax),%ecx
80104ac5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ac8:	0f b6 12             	movzbl (%edx),%edx
80104acb:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104acd:	8b 45 10             	mov    0x10(%ebp),%eax
80104ad0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ad3:	89 55 10             	mov    %edx,0x10(%ebp)
80104ad6:	85 c0                	test   %eax,%eax
80104ad8:	75 dc                	jne    80104ab6 <memmove+0x57>

  return dst;
80104ada:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104add:	c9                   	leave
80104ade:	c3                   	ret

80104adf <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104adf:	55                   	push   %ebp
80104ae0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ae2:	ff 75 10             	push   0x10(%ebp)
80104ae5:	ff 75 0c             	push   0xc(%ebp)
80104ae8:	ff 75 08             	push   0x8(%ebp)
80104aeb:	e8 6f ff ff ff       	call   80104a5f <memmove>
80104af0:	83 c4 0c             	add    $0xc,%esp
}
80104af3:	c9                   	leave
80104af4:	c3                   	ret

80104af5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104af5:	55                   	push   %ebp
80104af6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104af8:	eb 0c                	jmp    80104b06 <strncmp+0x11>
    n--, p++, q++;
80104afa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104afe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104b02:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104b06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b0a:	74 1a                	je     80104b26 <strncmp+0x31>
80104b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0f:	0f b6 00             	movzbl (%eax),%eax
80104b12:	84 c0                	test   %al,%al
80104b14:	74 10                	je     80104b26 <strncmp+0x31>
80104b16:	8b 45 08             	mov    0x8(%ebp),%eax
80104b19:	0f b6 10             	movzbl (%eax),%edx
80104b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1f:	0f b6 00             	movzbl (%eax),%eax
80104b22:	38 c2                	cmp    %al,%dl
80104b24:	74 d4                	je     80104afa <strncmp+0x5>
  if(n == 0)
80104b26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b2a:	75 07                	jne    80104b33 <strncmp+0x3e>
    return 0;
80104b2c:	ba 00 00 00 00       	mov    $0x0,%edx
80104b31:	eb 14                	jmp    80104b47 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104b33:	8b 45 08             	mov    0x8(%ebp),%eax
80104b36:	0f b6 00             	movzbl (%eax),%eax
80104b39:	0f b6 d0             	movzbl %al,%edx
80104b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b3f:	0f b6 00             	movzbl (%eax),%eax
80104b42:	0f b6 c0             	movzbl %al,%eax
80104b45:	29 c2                	sub    %eax,%edx
}
80104b47:	89 d0                	mov    %edx,%eax
80104b49:	5d                   	pop    %ebp
80104b4a:	c3                   	ret

80104b4b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b4b:	55                   	push   %ebp
80104b4c:	89 e5                	mov    %esp,%ebp
80104b4e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b51:	8b 45 08             	mov    0x8(%ebp),%eax
80104b54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b57:	90                   	nop
80104b58:	8b 45 10             	mov    0x10(%ebp),%eax
80104b5b:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b5e:	89 55 10             	mov    %edx,0x10(%ebp)
80104b61:	85 c0                	test   %eax,%eax
80104b63:	7e 2c                	jle    80104b91 <strncpy+0x46>
80104b65:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b68:	8d 42 01             	lea    0x1(%edx),%eax
80104b6b:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b71:	8d 48 01             	lea    0x1(%eax),%ecx
80104b74:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b77:	0f b6 12             	movzbl (%edx),%edx
80104b7a:	88 10                	mov    %dl,(%eax)
80104b7c:	0f b6 00             	movzbl (%eax),%eax
80104b7f:	84 c0                	test   %al,%al
80104b81:	75 d5                	jne    80104b58 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b83:	eb 0c                	jmp    80104b91 <strncpy+0x46>
    *s++ = 0;
80104b85:	8b 45 08             	mov    0x8(%ebp),%eax
80104b88:	8d 50 01             	lea    0x1(%eax),%edx
80104b8b:	89 55 08             	mov    %edx,0x8(%ebp)
80104b8e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b91:	8b 45 10             	mov    0x10(%ebp),%eax
80104b94:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b97:	89 55 10             	mov    %edx,0x10(%ebp)
80104b9a:	85 c0                	test   %eax,%eax
80104b9c:	7f e7                	jg     80104b85 <strncpy+0x3a>
  return os;
80104b9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ba1:	c9                   	leave
80104ba2:	c3                   	ret

80104ba3 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ba3:	55                   	push   %ebp
80104ba4:	89 e5                	mov    %esp,%ebp
80104ba6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104baf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bb3:	7f 05                	jg     80104bba <safestrcpy+0x17>
    return os;
80104bb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb8:	eb 32                	jmp    80104bec <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104bba:	90                   	nop
80104bbb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104bbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bc3:	7e 1e                	jle    80104be3 <safestrcpy+0x40>
80104bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bc8:	8d 42 01             	lea    0x1(%edx),%eax
80104bcb:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bce:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd1:	8d 48 01             	lea    0x1(%eax),%ecx
80104bd4:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bd7:	0f b6 12             	movzbl (%edx),%edx
80104bda:	88 10                	mov    %dl,(%eax)
80104bdc:	0f b6 00             	movzbl (%eax),%eax
80104bdf:	84 c0                	test   %al,%al
80104be1:	75 d8                	jne    80104bbb <safestrcpy+0x18>
    ;
  *s = 0;
80104be3:	8b 45 08             	mov    0x8(%ebp),%eax
80104be6:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104be9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bec:	c9                   	leave
80104bed:	c3                   	ret

80104bee <strlen>:

int
strlen(const char *s)
{
80104bee:	55                   	push   %ebp
80104bef:	89 e5                	mov    %esp,%ebp
80104bf1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bf4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bfb:	eb 04                	jmp    80104c01 <strlen+0x13>
80104bfd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c01:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c04:	8b 45 08             	mov    0x8(%ebp),%eax
80104c07:	01 d0                	add    %edx,%eax
80104c09:	0f b6 00             	movzbl (%eax),%eax
80104c0c:	84 c0                	test   %al,%al
80104c0e:	75 ed                	jne    80104bfd <strlen+0xf>
    ;
  return n;
80104c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c13:	c9                   	leave
80104c14:	c3                   	ret

80104c15 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104c15:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c19:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104c1d:	55                   	push   %ebp
  pushl %ebx
80104c1e:	53                   	push   %ebx
  pushl %esi
80104c1f:	56                   	push   %esi
  pushl %edi
80104c20:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c21:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c23:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c25:	5f                   	pop    %edi
  popl %esi
80104c26:	5e                   	pop    %esi
  popl %ebx
80104c27:	5b                   	pop    %ebx
  popl %ebp
80104c28:	5d                   	pop    %ebp
  ret
80104c29:	c3                   	ret

80104c2a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c30:	e8 fb ed ff ff       	call   80103a30 <myproc>
80104c35:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3b:	8b 00                	mov    (%eax),%eax
80104c3d:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c40:	73 0f                	jae    80104c51 <fetchint+0x27>
80104c42:	8b 45 08             	mov    0x8(%ebp),%eax
80104c45:	8d 50 04             	lea    0x4(%eax),%edx
80104c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4b:	8b 00                	mov    (%eax),%eax
80104c4d:	39 d0                	cmp    %edx,%eax
80104c4f:	73 07                	jae    80104c58 <fetchint+0x2e>
    return -1;
80104c51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c56:	eb 0f                	jmp    80104c67 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c58:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5b:	8b 10                	mov    (%eax),%edx
80104c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c60:	89 10                	mov    %edx,(%eax)
  return 0;
80104c62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c67:	c9                   	leave
80104c68:	c3                   	ret

80104c69 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c69:	55                   	push   %ebp
80104c6a:	89 e5                	mov    %esp,%ebp
80104c6c:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c6f:	e8 bc ed ff ff       	call   80103a30 <myproc>
80104c74:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7a:	8b 00                	mov    (%eax),%eax
80104c7c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c7f:	72 07                	jb     80104c88 <fetchstr+0x1f>
    return -1;
80104c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c86:	eb 41                	jmp    80104cc9 <fetchstr+0x60>
  *pp = (char*)addr;
80104c88:	8b 55 08             	mov    0x8(%ebp),%edx
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8e:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c93:	8b 00                	mov    (%eax),%eax
80104c95:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9b:	8b 00                	mov    (%eax),%eax
80104c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ca0:	eb 1a                	jmp    80104cbc <fetchstr+0x53>
    if(*s == 0)
80104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca5:	0f b6 00             	movzbl (%eax),%eax
80104ca8:	84 c0                	test   %al,%al
80104caa:	75 0c                	jne    80104cb8 <fetchstr+0x4f>
      return s - *pp;
80104cac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104caf:	8b 10                	mov    (%eax),%edx
80104cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb4:	29 d0                	sub    %edx,%eax
80104cb6:	eb 11                	jmp    80104cc9 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104cb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104cc2:	72 de                	jb     80104ca2 <fetchstr+0x39>
  }
  return -1;
80104cc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cc9:	c9                   	leave
80104cca:	c3                   	ret

80104ccb <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ccb:	55                   	push   %ebp
80104ccc:	89 e5                	mov    %esp,%ebp
80104cce:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cd1:	e8 5a ed ff ff       	call   80103a30 <myproc>
80104cd6:	8b 40 18             	mov    0x18(%eax),%eax
80104cd9:	8b 40 44             	mov    0x44(%eax),%eax
80104cdc:	8b 55 08             	mov    0x8(%ebp),%edx
80104cdf:	c1 e2 02             	shl    $0x2,%edx
80104ce2:	01 d0                	add    %edx,%eax
80104ce4:	83 c0 04             	add    $0x4,%eax
80104ce7:	83 ec 08             	sub    $0x8,%esp
80104cea:	ff 75 0c             	push   0xc(%ebp)
80104ced:	50                   	push   %eax
80104cee:	e8 37 ff ff ff       	call   80104c2a <fetchint>
80104cf3:	83 c4 10             	add    $0x10,%esp
}
80104cf6:	c9                   	leave
80104cf7:	c3                   	ret

80104cf8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cf8:	55                   	push   %ebp
80104cf9:	89 e5                	mov    %esp,%ebp
80104cfb:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104cfe:	e8 2d ed ff ff       	call   80103a30 <myproc>
80104d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104d06:	83 ec 08             	sub    $0x8,%esp
80104d09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d0c:	50                   	push   %eax
80104d0d:	ff 75 08             	push   0x8(%ebp)
80104d10:	e8 b6 ff ff ff       	call   80104ccb <argint>
80104d15:	83 c4 10             	add    $0x10,%esp
80104d18:	85 c0                	test   %eax,%eax
80104d1a:	79 07                	jns    80104d23 <argptr+0x2b>
    return -1;
80104d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d21:	eb 3b                	jmp    80104d5e <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d27:	78 1f                	js     80104d48 <argptr+0x50>
80104d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2c:	8b 00                	mov    (%eax),%eax
80104d2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d31:	39 c2                	cmp    %eax,%edx
80104d33:	73 13                	jae    80104d48 <argptr+0x50>
80104d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d38:	89 c2                	mov    %eax,%edx
80104d3a:	8b 45 10             	mov    0x10(%ebp),%eax
80104d3d:	01 c2                	add    %eax,%edx
80104d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d42:	8b 00                	mov    (%eax),%eax
80104d44:	39 d0                	cmp    %edx,%eax
80104d46:	73 07                	jae    80104d4f <argptr+0x57>
    return -1;
80104d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4d:	eb 0f                	jmp    80104d5e <argptr+0x66>
  *pp = (char*)i;
80104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d52:	89 c2                	mov    %eax,%edx
80104d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d57:	89 10                	mov    %edx,(%eax)
  return 0;
80104d59:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d5e:	c9                   	leave
80104d5f:	c3                   	ret

80104d60 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d66:	83 ec 08             	sub    $0x8,%esp
80104d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d6c:	50                   	push   %eax
80104d6d:	ff 75 08             	push   0x8(%ebp)
80104d70:	e8 56 ff ff ff       	call   80104ccb <argint>
80104d75:	83 c4 10             	add    $0x10,%esp
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	79 07                	jns    80104d83 <argstr+0x23>
    return -1;
80104d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d81:	eb 12                	jmp    80104d95 <argstr+0x35>
  return fetchstr(addr, pp);
80104d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d86:	83 ec 08             	sub    $0x8,%esp
80104d89:	ff 75 0c             	push   0xc(%ebp)
80104d8c:	50                   	push   %eax
80104d8d:	e8 d7 fe ff ff       	call   80104c69 <fetchstr>
80104d92:	83 c4 10             	add    $0x10,%esp
}
80104d95:	c9                   	leave
80104d96:	c3                   	ret

80104d97 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104d97:	55                   	push   %ebp
80104d98:	89 e5                	mov    %esp,%ebp
80104d9a:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d9d:	e8 8e ec ff ff       	call   80103a30 <myproc>
80104da2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da8:	8b 40 18             	mov    0x18(%eax),%eax
80104dab:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104db1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104db5:	7e 2f                	jle    80104de6 <syscall+0x4f>
80104db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dba:	83 f8 16             	cmp    $0x16,%eax
80104dbd:	77 27                	ja     80104de6 <syscall+0x4f>
80104dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc2:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dc9:	85 c0                	test   %eax,%eax
80104dcb:	74 19                	je     80104de6 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd0:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dd7:	ff d0                	call   *%eax
80104dd9:	89 c2                	mov    %eax,%edx
80104ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dde:	8b 40 18             	mov    0x18(%eax),%eax
80104de1:	89 50 1c             	mov    %edx,0x1c(%eax)
80104de4:	eb 2c                	jmp    80104e12 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de9:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104def:	8b 40 10             	mov    0x10(%eax),%eax
80104df2:	ff 75 f0             	push   -0x10(%ebp)
80104df5:	52                   	push   %edx
80104df6:	50                   	push   %eax
80104df7:	68 b8 a3 10 80       	push   $0x8010a3b8
80104dfc:	e8 f3 b5 ff ff       	call   801003f4 <cprintf>
80104e01:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e07:	8b 40 18             	mov    0x18(%eax),%eax
80104e0a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104e11:	90                   	nop
80104e12:	90                   	nop
80104e13:	c9                   	leave
80104e14:	c3                   	ret

80104e15 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104e15:	55                   	push   %ebp
80104e16:	89 e5                	mov    %esp,%ebp
80104e18:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104e1b:	83 ec 08             	sub    $0x8,%esp
80104e1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e21:	50                   	push   %eax
80104e22:	ff 75 08             	push   0x8(%ebp)
80104e25:	e8 a1 fe ff ff       	call   80104ccb <argint>
80104e2a:	83 c4 10             	add    $0x10,%esp
80104e2d:	85 c0                	test   %eax,%eax
80104e2f:	79 07                	jns    80104e38 <argfd+0x23>
    return -1;
80104e31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e36:	eb 4f                	jmp    80104e87 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3b:	85 c0                	test   %eax,%eax
80104e3d:	78 20                	js     80104e5f <argfd+0x4a>
80104e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e42:	83 f8 0f             	cmp    $0xf,%eax
80104e45:	7f 18                	jg     80104e5f <argfd+0x4a>
80104e47:	e8 e4 eb ff ff       	call   80103a30 <myproc>
80104e4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e4f:	83 c2 08             	add    $0x8,%edx
80104e52:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e5d:	75 07                	jne    80104e66 <argfd+0x51>
    return -1;
80104e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e64:	eb 21                	jmp    80104e87 <argfd+0x72>
  if(pfd)
80104e66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e6a:	74 08                	je     80104e74 <argfd+0x5f>
    *pfd = fd;
80104e6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e72:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e78:	74 08                	je     80104e82 <argfd+0x6d>
    *pf = f;
80104e7a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e80:	89 10                	mov    %edx,(%eax)
  return 0;
80104e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e87:	c9                   	leave
80104e88:	c3                   	ret

80104e89 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
80104e8c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e8f:	e8 9c eb ff ff       	call   80103a30 <myproc>
80104e94:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e9e:	eb 2a                	jmp    80104eca <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea6:	83 c2 08             	add    $0x8,%edx
80104ea9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ead:	85 c0                	test   %eax,%eax
80104eaf:	75 15                	jne    80104ec6 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb7:	8d 4a 08             	lea    0x8(%edx),%ecx
80104eba:	8b 55 08             	mov    0x8(%ebp),%edx
80104ebd:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec4:	eb 0f                	jmp    80104ed5 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104ec6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eca:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104ece:	7e d0                	jle    80104ea0 <fdalloc+0x17>
    }
  }
  return -1;
80104ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed5:	c9                   	leave
80104ed6:	c3                   	ret

80104ed7 <sys_dup>:

int
sys_dup(void)
{
80104ed7:	55                   	push   %ebp
80104ed8:	89 e5                	mov    %esp,%ebp
80104eda:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104edd:	83 ec 04             	sub    $0x4,%esp
80104ee0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ee3:	50                   	push   %eax
80104ee4:	6a 00                	push   $0x0
80104ee6:	6a 00                	push   $0x0
80104ee8:	e8 28 ff ff ff       	call   80104e15 <argfd>
80104eed:	83 c4 10             	add    $0x10,%esp
80104ef0:	85 c0                	test   %eax,%eax
80104ef2:	79 07                	jns    80104efb <sys_dup+0x24>
    return -1;
80104ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef9:	eb 31                	jmp    80104f2c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	50                   	push   %eax
80104f02:	e8 82 ff ff ff       	call   80104e89 <fdalloc>
80104f07:	83 c4 10             	add    $0x10,%esp
80104f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f11:	79 07                	jns    80104f1a <sys_dup+0x43>
    return -1;
80104f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f18:	eb 12                	jmp    80104f2c <sys_dup+0x55>
  filedup(f);
80104f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1d:	83 ec 0c             	sub    $0xc,%esp
80104f20:	50                   	push   %eax
80104f21:	e8 2e c1 ff ff       	call   80101054 <filedup>
80104f26:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f2c:	c9                   	leave
80104f2d:	c3                   	ret

80104f2e <sys_read>:

int
sys_read(void)
{
80104f2e:	55                   	push   %ebp
80104f2f:	89 e5                	mov    %esp,%ebp
80104f31:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f34:	83 ec 04             	sub    $0x4,%esp
80104f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f3a:	50                   	push   %eax
80104f3b:	6a 00                	push   $0x0
80104f3d:	6a 00                	push   $0x0
80104f3f:	e8 d1 fe ff ff       	call   80104e15 <argfd>
80104f44:	83 c4 10             	add    $0x10,%esp
80104f47:	85 c0                	test   %eax,%eax
80104f49:	78 2e                	js     80104f79 <sys_read+0x4b>
80104f4b:	83 ec 08             	sub    $0x8,%esp
80104f4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f51:	50                   	push   %eax
80104f52:	6a 02                	push   $0x2
80104f54:	e8 72 fd ff ff       	call   80104ccb <argint>
80104f59:	83 c4 10             	add    $0x10,%esp
80104f5c:	85 c0                	test   %eax,%eax
80104f5e:	78 19                	js     80104f79 <sys_read+0x4b>
80104f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f63:	83 ec 04             	sub    $0x4,%esp
80104f66:	50                   	push   %eax
80104f67:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f6a:	50                   	push   %eax
80104f6b:	6a 01                	push   $0x1
80104f6d:	e8 86 fd ff ff       	call   80104cf8 <argptr>
80104f72:	83 c4 10             	add    $0x10,%esp
80104f75:	85 c0                	test   %eax,%eax
80104f77:	79 07                	jns    80104f80 <sys_read+0x52>
    return -1;
80104f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f7e:	eb 17                	jmp    80104f97 <sys_read+0x69>
  return fileread(f, p, n);
80104f80:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f83:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f89:	83 ec 04             	sub    $0x4,%esp
80104f8c:	51                   	push   %ecx
80104f8d:	52                   	push   %edx
80104f8e:	50                   	push   %eax
80104f8f:	e8 50 c2 ff ff       	call   801011e4 <fileread>
80104f94:	83 c4 10             	add    $0x10,%esp
}
80104f97:	c9                   	leave
80104f98:	c3                   	ret

80104f99 <sys_write>:

int
sys_write(void)
{
80104f99:	55                   	push   %ebp
80104f9a:	89 e5                	mov    %esp,%ebp
80104f9c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f9f:	83 ec 04             	sub    $0x4,%esp
80104fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fa5:	50                   	push   %eax
80104fa6:	6a 00                	push   $0x0
80104fa8:	6a 00                	push   $0x0
80104faa:	e8 66 fe ff ff       	call   80104e15 <argfd>
80104faf:	83 c4 10             	add    $0x10,%esp
80104fb2:	85 c0                	test   %eax,%eax
80104fb4:	78 2e                	js     80104fe4 <sys_write+0x4b>
80104fb6:	83 ec 08             	sub    $0x8,%esp
80104fb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fbc:	50                   	push   %eax
80104fbd:	6a 02                	push   $0x2
80104fbf:	e8 07 fd ff ff       	call   80104ccb <argint>
80104fc4:	83 c4 10             	add    $0x10,%esp
80104fc7:	85 c0                	test   %eax,%eax
80104fc9:	78 19                	js     80104fe4 <sys_write+0x4b>
80104fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fce:	83 ec 04             	sub    $0x4,%esp
80104fd1:	50                   	push   %eax
80104fd2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fd5:	50                   	push   %eax
80104fd6:	6a 01                	push   $0x1
80104fd8:	e8 1b fd ff ff       	call   80104cf8 <argptr>
80104fdd:	83 c4 10             	add    $0x10,%esp
80104fe0:	85 c0                	test   %eax,%eax
80104fe2:	79 07                	jns    80104feb <sys_write+0x52>
    return -1;
80104fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe9:	eb 17                	jmp    80105002 <sys_write+0x69>
  return filewrite(f, p, n);
80104feb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fee:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff4:	83 ec 04             	sub    $0x4,%esp
80104ff7:	51                   	push   %ecx
80104ff8:	52                   	push   %edx
80104ff9:	50                   	push   %eax
80104ffa:	e8 9d c2 ff ff       	call   8010129c <filewrite>
80104fff:	83 c4 10             	add    $0x10,%esp
}
80105002:	c9                   	leave
80105003:	c3                   	ret

80105004 <sys_close>:

int
sys_close(void)
{
80105004:	55                   	push   %ebp
80105005:	89 e5                	mov    %esp,%ebp
80105007:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010500a:	83 ec 04             	sub    $0x4,%esp
8010500d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105010:	50                   	push   %eax
80105011:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105014:	50                   	push   %eax
80105015:	6a 00                	push   $0x0
80105017:	e8 f9 fd ff ff       	call   80104e15 <argfd>
8010501c:	83 c4 10             	add    $0x10,%esp
8010501f:	85 c0                	test   %eax,%eax
80105021:	79 07                	jns    8010502a <sys_close+0x26>
    return -1;
80105023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105028:	eb 27                	jmp    80105051 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010502a:	e8 01 ea ff ff       	call   80103a30 <myproc>
8010502f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105032:	83 c2 08             	add    $0x8,%edx
80105035:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010503c:	00 
  fileclose(f);
8010503d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105040:	83 ec 0c             	sub    $0xc,%esp
80105043:	50                   	push   %eax
80105044:	e8 5c c0 ff ff       	call   801010a5 <fileclose>
80105049:	83 c4 10             	add    $0x10,%esp
  return 0;
8010504c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105051:	c9                   	leave
80105052:	c3                   	ret

80105053 <sys_fstat>:

int
sys_fstat(void)
{
80105053:	55                   	push   %ebp
80105054:	89 e5                	mov    %esp,%ebp
80105056:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105059:	83 ec 04             	sub    $0x4,%esp
8010505c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010505f:	50                   	push   %eax
80105060:	6a 00                	push   $0x0
80105062:	6a 00                	push   $0x0
80105064:	e8 ac fd ff ff       	call   80104e15 <argfd>
80105069:	83 c4 10             	add    $0x10,%esp
8010506c:	85 c0                	test   %eax,%eax
8010506e:	78 17                	js     80105087 <sys_fstat+0x34>
80105070:	83 ec 04             	sub    $0x4,%esp
80105073:	6a 14                	push   $0x14
80105075:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105078:	50                   	push   %eax
80105079:	6a 01                	push   $0x1
8010507b:	e8 78 fc ff ff       	call   80104cf8 <argptr>
80105080:	83 c4 10             	add    $0x10,%esp
80105083:	85 c0                	test   %eax,%eax
80105085:	79 07                	jns    8010508e <sys_fstat+0x3b>
    return -1;
80105087:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010508c:	eb 13                	jmp    801050a1 <sys_fstat+0x4e>
  return filestat(f, st);
8010508e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105094:	83 ec 08             	sub    $0x8,%esp
80105097:	52                   	push   %edx
80105098:	50                   	push   %eax
80105099:	e8 ef c0 ff ff       	call   8010118d <filestat>
8010509e:	83 c4 10             	add    $0x10,%esp
}
801050a1:	c9                   	leave
801050a2:	c3                   	ret

801050a3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801050a3:	55                   	push   %ebp
801050a4:	89 e5                	mov    %esp,%ebp
801050a6:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801050a9:	83 ec 08             	sub    $0x8,%esp
801050ac:	8d 45 d8             	lea    -0x28(%ebp),%eax
801050af:	50                   	push   %eax
801050b0:	6a 00                	push   $0x0
801050b2:	e8 a9 fc ff ff       	call   80104d60 <argstr>
801050b7:	83 c4 10             	add    $0x10,%esp
801050ba:	85 c0                	test   %eax,%eax
801050bc:	78 15                	js     801050d3 <sys_link+0x30>
801050be:	83 ec 08             	sub    $0x8,%esp
801050c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050c4:	50                   	push   %eax
801050c5:	6a 01                	push   $0x1
801050c7:	e8 94 fc ff ff       	call   80104d60 <argstr>
801050cc:	83 c4 10             	add    $0x10,%esp
801050cf:	85 c0                	test   %eax,%eax
801050d1:	79 0a                	jns    801050dd <sys_link+0x3a>
    return -1;
801050d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d8:	e9 68 01 00 00       	jmp    80105245 <sys_link+0x1a2>

  begin_op();
801050dd:	e8 5c df ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
801050e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050e5:	83 ec 0c             	sub    $0xc,%esp
801050e8:	50                   	push   %eax
801050e9:	e8 37 d4 ff ff       	call   80102525 <namei>
801050ee:	83 c4 10             	add    $0x10,%esp
801050f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050f8:	75 0f                	jne    80105109 <sys_link+0x66>
    end_op();
801050fa:	e8 cb df ff ff       	call   801030ca <end_op>
    return -1;
801050ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105104:	e9 3c 01 00 00       	jmp    80105245 <sys_link+0x1a2>
  }

  ilock(ip);
80105109:	83 ec 0c             	sub    $0xc,%esp
8010510c:	ff 75 f4             	push   -0xc(%ebp)
8010510f:	e8 de c8 ff ff       	call   801019f2 <ilock>
80105114:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010511e:	66 83 f8 01          	cmp    $0x1,%ax
80105122:	75 1d                	jne    80105141 <sys_link+0x9e>
    iunlockput(ip);
80105124:	83 ec 0c             	sub    $0xc,%esp
80105127:	ff 75 f4             	push   -0xc(%ebp)
8010512a:	e8 f4 ca ff ff       	call   80101c23 <iunlockput>
8010512f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105132:	e8 93 df ff ff       	call   801030ca <end_op>
    return -1;
80105137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513c:	e9 04 01 00 00       	jmp    80105245 <sys_link+0x1a2>
  }

  ip->nlink++;
80105141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105144:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105148:	83 c0 01             	add    $0x1,%eax
8010514b:	89 c2                	mov    %eax,%edx
8010514d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105150:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105154:	83 ec 0c             	sub    $0xc,%esp
80105157:	ff 75 f4             	push   -0xc(%ebp)
8010515a:	e8 b6 c6 ff ff       	call   80101815 <iupdate>
8010515f:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105162:	83 ec 0c             	sub    $0xc,%esp
80105165:	ff 75 f4             	push   -0xc(%ebp)
80105168:	e8 98 c9 ff ff       	call   80101b05 <iunlock>
8010516d:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105170:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105173:	83 ec 08             	sub    $0x8,%esp
80105176:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105179:	52                   	push   %edx
8010517a:	50                   	push   %eax
8010517b:	e8 c1 d3 ff ff       	call   80102541 <nameiparent>
80105180:	83 c4 10             	add    $0x10,%esp
80105183:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105186:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010518a:	74 71                	je     801051fd <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010518c:	83 ec 0c             	sub    $0xc,%esp
8010518f:	ff 75 f0             	push   -0x10(%ebp)
80105192:	e8 5b c8 ff ff       	call   801019f2 <ilock>
80105197:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010519a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010519d:	8b 10                	mov    (%eax),%edx
8010519f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a2:	8b 00                	mov    (%eax),%eax
801051a4:	39 c2                	cmp    %eax,%edx
801051a6:	75 1d                	jne    801051c5 <sys_link+0x122>
801051a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ab:	8b 40 04             	mov    0x4(%eax),%eax
801051ae:	83 ec 04             	sub    $0x4,%esp
801051b1:	50                   	push   %eax
801051b2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801051b5:	50                   	push   %eax
801051b6:	ff 75 f0             	push   -0x10(%ebp)
801051b9:	e8 d0 d0 ff ff       	call   8010228e <dirlink>
801051be:	83 c4 10             	add    $0x10,%esp
801051c1:	85 c0                	test   %eax,%eax
801051c3:	79 10                	jns    801051d5 <sys_link+0x132>
    iunlockput(dp);
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	ff 75 f0             	push   -0x10(%ebp)
801051cb:	e8 53 ca ff ff       	call   80101c23 <iunlockput>
801051d0:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051d3:	eb 29                	jmp    801051fe <sys_link+0x15b>
  }
  iunlockput(dp);
801051d5:	83 ec 0c             	sub    $0xc,%esp
801051d8:	ff 75 f0             	push   -0x10(%ebp)
801051db:	e8 43 ca ff ff       	call   80101c23 <iunlockput>
801051e0:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051e3:	83 ec 0c             	sub    $0xc,%esp
801051e6:	ff 75 f4             	push   -0xc(%ebp)
801051e9:	e8 65 c9 ff ff       	call   80101b53 <iput>
801051ee:	83 c4 10             	add    $0x10,%esp

  end_op();
801051f1:	e8 d4 de ff ff       	call   801030ca <end_op>

  return 0;
801051f6:	b8 00 00 00 00       	mov    $0x0,%eax
801051fb:	eb 48                	jmp    80105245 <sys_link+0x1a2>
    goto bad;
801051fd:	90                   	nop

bad:
  ilock(ip);
801051fe:	83 ec 0c             	sub    $0xc,%esp
80105201:	ff 75 f4             	push   -0xc(%ebp)
80105204:	e8 e9 c7 ff ff       	call   801019f2 <ilock>
80105209:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010520c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105213:	83 e8 01             	sub    $0x1,%eax
80105216:	89 c2                	mov    %eax,%edx
80105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010521f:	83 ec 0c             	sub    $0xc,%esp
80105222:	ff 75 f4             	push   -0xc(%ebp)
80105225:	e8 eb c5 ff ff       	call   80101815 <iupdate>
8010522a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010522d:	83 ec 0c             	sub    $0xc,%esp
80105230:	ff 75 f4             	push   -0xc(%ebp)
80105233:	e8 eb c9 ff ff       	call   80101c23 <iunlockput>
80105238:	83 c4 10             	add    $0x10,%esp
  end_op();
8010523b:	e8 8a de ff ff       	call   801030ca <end_op>
  return -1;
80105240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105245:	c9                   	leave
80105246:	c3                   	ret

80105247 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105247:	55                   	push   %ebp
80105248:	89 e5                	mov    %esp,%ebp
8010524a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010524d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105254:	eb 40                	jmp    80105296 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105259:	6a 10                	push   $0x10
8010525b:	50                   	push   %eax
8010525c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010525f:	50                   	push   %eax
80105260:	ff 75 08             	push   0x8(%ebp)
80105263:	e8 76 cc ff ff       	call   80101ede <readi>
80105268:	83 c4 10             	add    $0x10,%esp
8010526b:	83 f8 10             	cmp    $0x10,%eax
8010526e:	74 0d                	je     8010527d <isdirempty+0x36>
      panic("isdirempty: readi");
80105270:	83 ec 0c             	sub    $0xc,%esp
80105273:	68 d4 a3 10 80       	push   $0x8010a3d4
80105278:	e8 2c b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010527d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105281:	66 85 c0             	test   %ax,%ax
80105284:	74 07                	je     8010528d <isdirempty+0x46>
      return 0;
80105286:	b8 00 00 00 00       	mov    $0x0,%eax
8010528b:	eb 1b                	jmp    801052a8 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010528d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105290:	83 c0 10             	add    $0x10,%eax
80105293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105296:	8b 45 08             	mov    0x8(%ebp),%eax
80105299:	8b 40 58             	mov    0x58(%eax),%eax
8010529c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010529f:	39 c2                	cmp    %eax,%edx
801052a1:	72 b3                	jb     80105256 <isdirempty+0xf>
  }
  return 1;
801052a3:	b8 01 00 00 00       	mov    $0x1,%eax
}
801052a8:	c9                   	leave
801052a9:	c3                   	ret

801052aa <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801052aa:	55                   	push   %ebp
801052ab:	89 e5                	mov    %esp,%ebp
801052ad:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801052b0:	83 ec 08             	sub    $0x8,%esp
801052b3:	8d 45 cc             	lea    -0x34(%ebp),%eax
801052b6:	50                   	push   %eax
801052b7:	6a 00                	push   $0x0
801052b9:	e8 a2 fa ff ff       	call   80104d60 <argstr>
801052be:	83 c4 10             	add    $0x10,%esp
801052c1:	85 c0                	test   %eax,%eax
801052c3:	79 0a                	jns    801052cf <sys_unlink+0x25>
    return -1;
801052c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ca:	e9 bf 01 00 00       	jmp    8010548e <sys_unlink+0x1e4>

  begin_op();
801052cf:	e8 6a dd ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052d7:	83 ec 08             	sub    $0x8,%esp
801052da:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052dd:	52                   	push   %edx
801052de:	50                   	push   %eax
801052df:	e8 5d d2 ff ff       	call   80102541 <nameiparent>
801052e4:	83 c4 10             	add    $0x10,%esp
801052e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052ee:	75 0f                	jne    801052ff <sys_unlink+0x55>
    end_op();
801052f0:	e8 d5 dd ff ff       	call   801030ca <end_op>
    return -1;
801052f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fa:	e9 8f 01 00 00       	jmp    8010548e <sys_unlink+0x1e4>
  }

  ilock(dp);
801052ff:	83 ec 0c             	sub    $0xc,%esp
80105302:	ff 75 f4             	push   -0xc(%ebp)
80105305:	e8 e8 c6 ff ff       	call   801019f2 <ilock>
8010530a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010530d:	83 ec 08             	sub    $0x8,%esp
80105310:	68 e6 a3 10 80       	push   $0x8010a3e6
80105315:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105318:	50                   	push   %eax
80105319:	e8 9b ce ff ff       	call   801021b9 <namecmp>
8010531e:	83 c4 10             	add    $0x10,%esp
80105321:	85 c0                	test   %eax,%eax
80105323:	0f 84 49 01 00 00    	je     80105472 <sys_unlink+0x1c8>
80105329:	83 ec 08             	sub    $0x8,%esp
8010532c:	68 e8 a3 10 80       	push   $0x8010a3e8
80105331:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105334:	50                   	push   %eax
80105335:	e8 7f ce ff ff       	call   801021b9 <namecmp>
8010533a:	83 c4 10             	add    $0x10,%esp
8010533d:	85 c0                	test   %eax,%eax
8010533f:	0f 84 2d 01 00 00    	je     80105472 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105345:	83 ec 04             	sub    $0x4,%esp
80105348:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010534b:	50                   	push   %eax
8010534c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010534f:	50                   	push   %eax
80105350:	ff 75 f4             	push   -0xc(%ebp)
80105353:	e8 7c ce ff ff       	call   801021d4 <dirlookup>
80105358:	83 c4 10             	add    $0x10,%esp
8010535b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010535e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105362:	0f 84 0d 01 00 00    	je     80105475 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105368:	83 ec 0c             	sub    $0xc,%esp
8010536b:	ff 75 f0             	push   -0x10(%ebp)
8010536e:	e8 7f c6 ff ff       	call   801019f2 <ilock>
80105373:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105379:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010537d:	66 85 c0             	test   %ax,%ax
80105380:	7f 0d                	jg     8010538f <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105382:	83 ec 0c             	sub    $0xc,%esp
80105385:	68 eb a3 10 80       	push   $0x8010a3eb
8010538a:	e8 1a b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010538f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105392:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105396:	66 83 f8 01          	cmp    $0x1,%ax
8010539a:	75 25                	jne    801053c1 <sys_unlink+0x117>
8010539c:	83 ec 0c             	sub    $0xc,%esp
8010539f:	ff 75 f0             	push   -0x10(%ebp)
801053a2:	e8 a0 fe ff ff       	call   80105247 <isdirempty>
801053a7:	83 c4 10             	add    $0x10,%esp
801053aa:	85 c0                	test   %eax,%eax
801053ac:	75 13                	jne    801053c1 <sys_unlink+0x117>
    iunlockput(ip);
801053ae:	83 ec 0c             	sub    $0xc,%esp
801053b1:	ff 75 f0             	push   -0x10(%ebp)
801053b4:	e8 6a c8 ff ff       	call   80101c23 <iunlockput>
801053b9:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053bc:	e9 b5 00 00 00       	jmp    80105476 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053c1:	83 ec 04             	sub    $0x4,%esp
801053c4:	6a 10                	push   $0x10
801053c6:	6a 00                	push   $0x0
801053c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053cb:	50                   	push   %eax
801053cc:	e8 cf f5 ff ff       	call   801049a0 <memset>
801053d1:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053d7:	6a 10                	push   $0x10
801053d9:	50                   	push   %eax
801053da:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053dd:	50                   	push   %eax
801053de:	ff 75 f4             	push   -0xc(%ebp)
801053e1:	e8 4d cc ff ff       	call   80102033 <writei>
801053e6:	83 c4 10             	add    $0x10,%esp
801053e9:	83 f8 10             	cmp    $0x10,%eax
801053ec:	74 0d                	je     801053fb <sys_unlink+0x151>
    panic("unlink: writei");
801053ee:	83 ec 0c             	sub    $0xc,%esp
801053f1:	68 fd a3 10 80       	push   $0x8010a3fd
801053f6:	e8 ae b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fe:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105402:	66 83 f8 01          	cmp    $0x1,%ax
80105406:	75 21                	jne    80105429 <sys_unlink+0x17f>
    dp->nlink--;
80105408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010540b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010540f:	83 e8 01             	sub    $0x1,%eax
80105412:	89 c2                	mov    %eax,%edx
80105414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105417:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010541b:	83 ec 0c             	sub    $0xc,%esp
8010541e:	ff 75 f4             	push   -0xc(%ebp)
80105421:	e8 ef c3 ff ff       	call   80101815 <iupdate>
80105426:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	ff 75 f4             	push   -0xc(%ebp)
8010542f:	e8 ef c7 ff ff       	call   80101c23 <iunlockput>
80105434:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010543e:	83 e8 01             	sub    $0x1,%eax
80105441:	89 c2                	mov    %eax,%edx
80105443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105446:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010544a:	83 ec 0c             	sub    $0xc,%esp
8010544d:	ff 75 f0             	push   -0x10(%ebp)
80105450:	e8 c0 c3 ff ff       	call   80101815 <iupdate>
80105455:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105458:	83 ec 0c             	sub    $0xc,%esp
8010545b:	ff 75 f0             	push   -0x10(%ebp)
8010545e:	e8 c0 c7 ff ff       	call   80101c23 <iunlockput>
80105463:	83 c4 10             	add    $0x10,%esp

  end_op();
80105466:	e8 5f dc ff ff       	call   801030ca <end_op>

  return 0;
8010546b:	b8 00 00 00 00       	mov    $0x0,%eax
80105470:	eb 1c                	jmp    8010548e <sys_unlink+0x1e4>
    goto bad;
80105472:	90                   	nop
80105473:	eb 01                	jmp    80105476 <sys_unlink+0x1cc>
    goto bad;
80105475:	90                   	nop

bad:
  iunlockput(dp);
80105476:	83 ec 0c             	sub    $0xc,%esp
80105479:	ff 75 f4             	push   -0xc(%ebp)
8010547c:	e8 a2 c7 ff ff       	call   80101c23 <iunlockput>
80105481:	83 c4 10             	add    $0x10,%esp
  end_op();
80105484:	e8 41 dc ff ff       	call   801030ca <end_op>
  return -1;
80105489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010548e:	c9                   	leave
8010548f:	c3                   	ret

80105490 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 38             	sub    $0x38,%esp
80105496:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105499:	8b 55 10             	mov    0x10(%ebp),%edx
8010549c:	8b 45 14             	mov    0x14(%ebp),%eax
8010549f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801054a3:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801054a7:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801054ab:	83 ec 08             	sub    $0x8,%esp
801054ae:	8d 45 de             	lea    -0x22(%ebp),%eax
801054b1:	50                   	push   %eax
801054b2:	ff 75 08             	push   0x8(%ebp)
801054b5:	e8 87 d0 ff ff       	call   80102541 <nameiparent>
801054ba:	83 c4 10             	add    $0x10,%esp
801054bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054c4:	75 0a                	jne    801054d0 <create+0x40>
    return 0;
801054c6:	b8 00 00 00 00       	mov    $0x0,%eax
801054cb:	e9 90 01 00 00       	jmp    80105660 <create+0x1d0>
  ilock(dp);
801054d0:	83 ec 0c             	sub    $0xc,%esp
801054d3:	ff 75 f4             	push   -0xc(%ebp)
801054d6:	e8 17 c5 ff ff       	call   801019f2 <ilock>
801054db:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054de:	83 ec 04             	sub    $0x4,%esp
801054e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054e4:	50                   	push   %eax
801054e5:	8d 45 de             	lea    -0x22(%ebp),%eax
801054e8:	50                   	push   %eax
801054e9:	ff 75 f4             	push   -0xc(%ebp)
801054ec:	e8 e3 cc ff ff       	call   801021d4 <dirlookup>
801054f1:	83 c4 10             	add    $0x10,%esp
801054f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054fb:	74 50                	je     8010554d <create+0xbd>
    iunlockput(dp);
801054fd:	83 ec 0c             	sub    $0xc,%esp
80105500:	ff 75 f4             	push   -0xc(%ebp)
80105503:	e8 1b c7 ff ff       	call   80101c23 <iunlockput>
80105508:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010550b:	83 ec 0c             	sub    $0xc,%esp
8010550e:	ff 75 f0             	push   -0x10(%ebp)
80105511:	e8 dc c4 ff ff       	call   801019f2 <ilock>
80105516:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105519:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010551e:	75 15                	jne    80105535 <create+0xa5>
80105520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105523:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105527:	66 83 f8 02          	cmp    $0x2,%ax
8010552b:	75 08                	jne    80105535 <create+0xa5>
      return ip;
8010552d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105530:	e9 2b 01 00 00       	jmp    80105660 <create+0x1d0>
    iunlockput(ip);
80105535:	83 ec 0c             	sub    $0xc,%esp
80105538:	ff 75 f0             	push   -0x10(%ebp)
8010553b:	e8 e3 c6 ff ff       	call   80101c23 <iunlockput>
80105540:	83 c4 10             	add    $0x10,%esp
    return 0;
80105543:	b8 00 00 00 00       	mov    $0x0,%eax
80105548:	e9 13 01 00 00       	jmp    80105660 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010554d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105554:	8b 00                	mov    (%eax),%eax
80105556:	83 ec 08             	sub    $0x8,%esp
80105559:	52                   	push   %edx
8010555a:	50                   	push   %eax
8010555b:	e8 df c1 ff ff       	call   8010173f <ialloc>
80105560:	83 c4 10             	add    $0x10,%esp
80105563:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105566:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010556a:	75 0d                	jne    80105579 <create+0xe9>
    panic("create: ialloc");
8010556c:	83 ec 0c             	sub    $0xc,%esp
8010556f:	68 0c a4 10 80       	push   $0x8010a40c
80105574:	e8 30 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105579:	83 ec 0c             	sub    $0xc,%esp
8010557c:	ff 75 f0             	push   -0x10(%ebp)
8010557f:	e8 6e c4 ff ff       	call   801019f2 <ilock>
80105584:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105587:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010558a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010558e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105595:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105599:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010559d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a0:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801055a6:	83 ec 0c             	sub    $0xc,%esp
801055a9:	ff 75 f0             	push   -0x10(%ebp)
801055ac:	e8 64 c2 ff ff       	call   80101815 <iupdate>
801055b1:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801055b4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801055b9:	75 6a                	jne    80105625 <create+0x195>
    dp->nlink++;  // for ".."
801055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055be:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055c2:	83 c0 01             	add    $0x1,%eax
801055c5:	89 c2                	mov    %eax,%edx
801055c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ca:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055ce:	83 ec 0c             	sub    $0xc,%esp
801055d1:	ff 75 f4             	push   -0xc(%ebp)
801055d4:	e8 3c c2 ff ff       	call   80101815 <iupdate>
801055d9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055df:	8b 40 04             	mov    0x4(%eax),%eax
801055e2:	83 ec 04             	sub    $0x4,%esp
801055e5:	50                   	push   %eax
801055e6:	68 e6 a3 10 80       	push   $0x8010a3e6
801055eb:	ff 75 f0             	push   -0x10(%ebp)
801055ee:	e8 9b cc ff ff       	call   8010228e <dirlink>
801055f3:	83 c4 10             	add    $0x10,%esp
801055f6:	85 c0                	test   %eax,%eax
801055f8:	78 1e                	js     80105618 <create+0x188>
801055fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fd:	8b 40 04             	mov    0x4(%eax),%eax
80105600:	83 ec 04             	sub    $0x4,%esp
80105603:	50                   	push   %eax
80105604:	68 e8 a3 10 80       	push   $0x8010a3e8
80105609:	ff 75 f0             	push   -0x10(%ebp)
8010560c:	e8 7d cc ff ff       	call   8010228e <dirlink>
80105611:	83 c4 10             	add    $0x10,%esp
80105614:	85 c0                	test   %eax,%eax
80105616:	79 0d                	jns    80105625 <create+0x195>
      panic("create dots");
80105618:	83 ec 0c             	sub    $0xc,%esp
8010561b:	68 1b a4 10 80       	push   $0x8010a41b
80105620:	e8 84 af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105625:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105628:	8b 40 04             	mov    0x4(%eax),%eax
8010562b:	83 ec 04             	sub    $0x4,%esp
8010562e:	50                   	push   %eax
8010562f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105632:	50                   	push   %eax
80105633:	ff 75 f4             	push   -0xc(%ebp)
80105636:	e8 53 cc ff ff       	call   8010228e <dirlink>
8010563b:	83 c4 10             	add    $0x10,%esp
8010563e:	85 c0                	test   %eax,%eax
80105640:	79 0d                	jns    8010564f <create+0x1bf>
    panic("create: dirlink");
80105642:	83 ec 0c             	sub    $0xc,%esp
80105645:	68 27 a4 10 80       	push   $0x8010a427
8010564a:	e8 5a af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010564f:	83 ec 0c             	sub    $0xc,%esp
80105652:	ff 75 f4             	push   -0xc(%ebp)
80105655:	e8 c9 c5 ff ff       	call   80101c23 <iunlockput>
8010565a:	83 c4 10             	add    $0x10,%esp

  return ip;
8010565d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105660:	c9                   	leave
80105661:	c3                   	ret

80105662 <sys_open>:

int
sys_open(void)
{
80105662:	55                   	push   %ebp
80105663:	89 e5                	mov    %esp,%ebp
80105665:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105668:	83 ec 08             	sub    $0x8,%esp
8010566b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010566e:	50                   	push   %eax
8010566f:	6a 00                	push   $0x0
80105671:	e8 ea f6 ff ff       	call   80104d60 <argstr>
80105676:	83 c4 10             	add    $0x10,%esp
80105679:	85 c0                	test   %eax,%eax
8010567b:	78 15                	js     80105692 <sys_open+0x30>
8010567d:	83 ec 08             	sub    $0x8,%esp
80105680:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105683:	50                   	push   %eax
80105684:	6a 01                	push   $0x1
80105686:	e8 40 f6 ff ff       	call   80104ccb <argint>
8010568b:	83 c4 10             	add    $0x10,%esp
8010568e:	85 c0                	test   %eax,%eax
80105690:	79 0a                	jns    8010569c <sys_open+0x3a>
    return -1;
80105692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105697:	e9 61 01 00 00       	jmp    801057fd <sys_open+0x19b>

  begin_op();
8010569c:	e8 9d d9 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
801056a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056a4:	25 00 02 00 00       	and    $0x200,%eax
801056a9:	85 c0                	test   %eax,%eax
801056ab:	74 2a                	je     801056d7 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801056ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056b0:	6a 00                	push   $0x0
801056b2:	6a 00                	push   $0x0
801056b4:	6a 02                	push   $0x2
801056b6:	50                   	push   %eax
801056b7:	e8 d4 fd ff ff       	call   80105490 <create>
801056bc:	83 c4 10             	add    $0x10,%esp
801056bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056c6:	75 75                	jne    8010573d <sys_open+0xdb>
      end_op();
801056c8:	e8 fd d9 ff ff       	call   801030ca <end_op>
      return -1;
801056cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d2:	e9 26 01 00 00       	jmp    801057fd <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056da:	83 ec 0c             	sub    $0xc,%esp
801056dd:	50                   	push   %eax
801056de:	e8 42 ce ff ff       	call   80102525 <namei>
801056e3:	83 c4 10             	add    $0x10,%esp
801056e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ed:	75 0f                	jne    801056fe <sys_open+0x9c>
      end_op();
801056ef:	e8 d6 d9 ff ff       	call   801030ca <end_op>
      return -1;
801056f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f9:	e9 ff 00 00 00       	jmp    801057fd <sys_open+0x19b>
    }
    ilock(ip);
801056fe:	83 ec 0c             	sub    $0xc,%esp
80105701:	ff 75 f4             	push   -0xc(%ebp)
80105704:	e8 e9 c2 ff ff       	call   801019f2 <ilock>
80105709:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010570c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010570f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105713:	66 83 f8 01          	cmp    $0x1,%ax
80105717:	75 24                	jne    8010573d <sys_open+0xdb>
80105719:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010571c:	85 c0                	test   %eax,%eax
8010571e:	74 1d                	je     8010573d <sys_open+0xdb>
      iunlockput(ip);
80105720:	83 ec 0c             	sub    $0xc,%esp
80105723:	ff 75 f4             	push   -0xc(%ebp)
80105726:	e8 f8 c4 ff ff       	call   80101c23 <iunlockput>
8010572b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010572e:	e8 97 d9 ff ff       	call   801030ca <end_op>
      return -1;
80105733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105738:	e9 c0 00 00 00       	jmp    801057fd <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010573d:	e8 a5 b8 ff ff       	call   80100fe7 <filealloc>
80105742:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105745:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105749:	74 17                	je     80105762 <sys_open+0x100>
8010574b:	83 ec 0c             	sub    $0xc,%esp
8010574e:	ff 75 f0             	push   -0x10(%ebp)
80105751:	e8 33 f7 ff ff       	call   80104e89 <fdalloc>
80105756:	83 c4 10             	add    $0x10,%esp
80105759:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010575c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105760:	79 2e                	jns    80105790 <sys_open+0x12e>
    if(f)
80105762:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105766:	74 0e                	je     80105776 <sys_open+0x114>
      fileclose(f);
80105768:	83 ec 0c             	sub    $0xc,%esp
8010576b:	ff 75 f0             	push   -0x10(%ebp)
8010576e:	e8 32 b9 ff ff       	call   801010a5 <fileclose>
80105773:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105776:	83 ec 0c             	sub    $0xc,%esp
80105779:	ff 75 f4             	push   -0xc(%ebp)
8010577c:	e8 a2 c4 ff ff       	call   80101c23 <iunlockput>
80105781:	83 c4 10             	add    $0x10,%esp
    end_op();
80105784:	e8 41 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578e:	eb 6d                	jmp    801057fd <sys_open+0x19b>
  }
  iunlock(ip);
80105790:	83 ec 0c             	sub    $0xc,%esp
80105793:	ff 75 f4             	push   -0xc(%ebp)
80105796:	e8 6a c3 ff ff       	call   80101b05 <iunlock>
8010579b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010579e:	e8 27 d9 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
801057a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801057ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057b2:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801057b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c2:	83 e0 01             	and    $0x1,%eax
801057c5:	85 c0                	test   %eax,%eax
801057c7:	0f 94 c0             	sete   %al
801057ca:	89 c2                	mov    %eax,%edx
801057cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057cf:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057d5:	83 e0 01             	and    $0x1,%eax
801057d8:	85 c0                	test   %eax,%eax
801057da:	75 0a                	jne    801057e6 <sys_open+0x184>
801057dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057df:	83 e0 02             	and    $0x2,%eax
801057e2:	85 c0                	test   %eax,%eax
801057e4:	74 07                	je     801057ed <sys_open+0x18b>
801057e6:	b8 01 00 00 00       	mov    $0x1,%eax
801057eb:	eb 05                	jmp    801057f2 <sys_open+0x190>
801057ed:	b8 00 00 00 00       	mov    $0x0,%eax
801057f2:	89 c2                	mov    %eax,%edx
801057f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f7:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057fd:	c9                   	leave
801057fe:	c3                   	ret

801057ff <sys_mkdir>:

int
sys_mkdir(void)
{
801057ff:	55                   	push   %ebp
80105800:	89 e5                	mov    %esp,%ebp
80105802:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105805:	e8 34 d8 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010580a:	83 ec 08             	sub    $0x8,%esp
8010580d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105810:	50                   	push   %eax
80105811:	6a 00                	push   $0x0
80105813:	e8 48 f5 ff ff       	call   80104d60 <argstr>
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	85 c0                	test   %eax,%eax
8010581d:	78 1b                	js     8010583a <sys_mkdir+0x3b>
8010581f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105822:	6a 00                	push   $0x0
80105824:	6a 00                	push   $0x0
80105826:	6a 01                	push   $0x1
80105828:	50                   	push   %eax
80105829:	e8 62 fc ff ff       	call   80105490 <create>
8010582e:	83 c4 10             	add    $0x10,%esp
80105831:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105834:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105838:	75 0c                	jne    80105846 <sys_mkdir+0x47>
    end_op();
8010583a:	e8 8b d8 ff ff       	call   801030ca <end_op>
    return -1;
8010583f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105844:	eb 18                	jmp    8010585e <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105846:	83 ec 0c             	sub    $0xc,%esp
80105849:	ff 75 f4             	push   -0xc(%ebp)
8010584c:	e8 d2 c3 ff ff       	call   80101c23 <iunlockput>
80105851:	83 c4 10             	add    $0x10,%esp
  end_op();
80105854:	e8 71 d8 ff ff       	call   801030ca <end_op>
  return 0;
80105859:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010585e:	c9                   	leave
8010585f:	c3                   	ret

80105860 <sys_mknod>:

int
sys_mknod(void)
{
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105866:	e8 d3 d7 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
8010586b:	83 ec 08             	sub    $0x8,%esp
8010586e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105871:	50                   	push   %eax
80105872:	6a 00                	push   $0x0
80105874:	e8 e7 f4 ff ff       	call   80104d60 <argstr>
80105879:	83 c4 10             	add    $0x10,%esp
8010587c:	85 c0                	test   %eax,%eax
8010587e:	78 4f                	js     801058cf <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105880:	83 ec 08             	sub    $0x8,%esp
80105883:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105886:	50                   	push   %eax
80105887:	6a 01                	push   $0x1
80105889:	e8 3d f4 ff ff       	call   80104ccb <argint>
8010588e:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105891:	85 c0                	test   %eax,%eax
80105893:	78 3a                	js     801058cf <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105895:	83 ec 08             	sub    $0x8,%esp
80105898:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010589b:	50                   	push   %eax
8010589c:	6a 02                	push   $0x2
8010589e:	e8 28 f4 ff ff       	call   80104ccb <argint>
801058a3:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801058a6:	85 c0                	test   %eax,%eax
801058a8:	78 25                	js     801058cf <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801058aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058ad:	0f bf c8             	movswl %ax,%ecx
801058b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801058b3:	0f bf d0             	movswl %ax,%edx
801058b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b9:	51                   	push   %ecx
801058ba:	52                   	push   %edx
801058bb:	6a 03                	push   $0x3
801058bd:	50                   	push   %eax
801058be:	e8 cd fb ff ff       	call   80105490 <create>
801058c3:	83 c4 10             	add    $0x10,%esp
801058c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058cd:	75 0c                	jne    801058db <sys_mknod+0x7b>
    end_op();
801058cf:	e8 f6 d7 ff ff       	call   801030ca <end_op>
    return -1;
801058d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d9:	eb 18                	jmp    801058f3 <sys_mknod+0x93>
  }
  iunlockput(ip);
801058db:	83 ec 0c             	sub    $0xc,%esp
801058de:	ff 75 f4             	push   -0xc(%ebp)
801058e1:	e8 3d c3 ff ff       	call   80101c23 <iunlockput>
801058e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801058e9:	e8 dc d7 ff ff       	call   801030ca <end_op>
  return 0;
801058ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058f3:	c9                   	leave
801058f4:	c3                   	ret

801058f5 <sys_chdir>:

int
sys_chdir(void)
{
801058f5:	55                   	push   %ebp
801058f6:	89 e5                	mov    %esp,%ebp
801058f8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058fb:	e8 30 e1 ff ff       	call   80103a30 <myproc>
80105900:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105903:	e8 36 d7 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105908:	83 ec 08             	sub    $0x8,%esp
8010590b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010590e:	50                   	push   %eax
8010590f:	6a 00                	push   $0x0
80105911:	e8 4a f4 ff ff       	call   80104d60 <argstr>
80105916:	83 c4 10             	add    $0x10,%esp
80105919:	85 c0                	test   %eax,%eax
8010591b:	78 18                	js     80105935 <sys_chdir+0x40>
8010591d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	50                   	push   %eax
80105924:	e8 fc cb ff ff       	call   80102525 <namei>
80105929:	83 c4 10             	add    $0x10,%esp
8010592c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010592f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105933:	75 0c                	jne    80105941 <sys_chdir+0x4c>
    end_op();
80105935:	e8 90 d7 ff ff       	call   801030ca <end_op>
    return -1;
8010593a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593f:	eb 68                	jmp    801059a9 <sys_chdir+0xb4>
  }
  ilock(ip);
80105941:	83 ec 0c             	sub    $0xc,%esp
80105944:	ff 75 f0             	push   -0x10(%ebp)
80105947:	e8 a6 c0 ff ff       	call   801019f2 <ilock>
8010594c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010594f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105952:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105956:	66 83 f8 01          	cmp    $0x1,%ax
8010595a:	74 1a                	je     80105976 <sys_chdir+0x81>
    iunlockput(ip);
8010595c:	83 ec 0c             	sub    $0xc,%esp
8010595f:	ff 75 f0             	push   -0x10(%ebp)
80105962:	e8 bc c2 ff ff       	call   80101c23 <iunlockput>
80105967:	83 c4 10             	add    $0x10,%esp
    end_op();
8010596a:	e8 5b d7 ff ff       	call   801030ca <end_op>
    return -1;
8010596f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105974:	eb 33                	jmp    801059a9 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	ff 75 f0             	push   -0x10(%ebp)
8010597c:	e8 84 c1 ff ff       	call   80101b05 <iunlock>
80105981:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	8b 40 68             	mov    0x68(%eax),%eax
8010598a:	83 ec 0c             	sub    $0xc,%esp
8010598d:	50                   	push   %eax
8010598e:	e8 c0 c1 ff ff       	call   80101b53 <iput>
80105993:	83 c4 10             	add    $0x10,%esp
  end_op();
80105996:	e8 2f d7 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
8010599b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059a1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801059a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a9:	c9                   	leave
801059aa:	c3                   	ret

801059ab <sys_exec>:

int
sys_exec(void)
{
801059ab:	55                   	push   %ebp
801059ac:	89 e5                	mov    %esp,%ebp
801059ae:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801059b4:	83 ec 08             	sub    $0x8,%esp
801059b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ba:	50                   	push   %eax
801059bb:	6a 00                	push   $0x0
801059bd:	e8 9e f3 ff ff       	call   80104d60 <argstr>
801059c2:	83 c4 10             	add    $0x10,%esp
801059c5:	85 c0                	test   %eax,%eax
801059c7:	78 18                	js     801059e1 <sys_exec+0x36>
801059c9:	83 ec 08             	sub    $0x8,%esp
801059cc:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059d2:	50                   	push   %eax
801059d3:	6a 01                	push   $0x1
801059d5:	e8 f1 f2 ff ff       	call   80104ccb <argint>
801059da:	83 c4 10             	add    $0x10,%esp
801059dd:	85 c0                	test   %eax,%eax
801059df:	79 0a                	jns    801059eb <sys_exec+0x40>
    return -1;
801059e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e6:	e9 c6 00 00 00       	jmp    80105ab1 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059eb:	83 ec 04             	sub    $0x4,%esp
801059ee:	68 80 00 00 00       	push   $0x80
801059f3:	6a 00                	push   $0x0
801059f5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059fb:	50                   	push   %eax
801059fc:	e8 9f ef ff ff       	call   801049a0 <memset>
80105a01:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105a04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0e:	83 f8 1f             	cmp    $0x1f,%eax
80105a11:	76 0a                	jbe    80105a1d <sys_exec+0x72>
      return -1;
80105a13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a18:	e9 94 00 00 00       	jmp    80105ab1 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a20:	c1 e0 02             	shl    $0x2,%eax
80105a23:	89 c2                	mov    %eax,%edx
80105a25:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a2b:	01 c2                	add    %eax,%edx
80105a2d:	83 ec 08             	sub    $0x8,%esp
80105a30:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a36:	50                   	push   %eax
80105a37:	52                   	push   %edx
80105a38:	e8 ed f1 ff ff       	call   80104c2a <fetchint>
80105a3d:	83 c4 10             	add    $0x10,%esp
80105a40:	85 c0                	test   %eax,%eax
80105a42:	79 07                	jns    80105a4b <sys_exec+0xa0>
      return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a49:	eb 66                	jmp    80105ab1 <sys_exec+0x106>
    if(uarg == 0){
80105a4b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a51:	85 c0                	test   %eax,%eax
80105a53:	75 27                	jne    80105a7c <sys_exec+0xd1>
      argv[i] = 0;
80105a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a58:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a5f:	00 00 00 00 
      break;
80105a63:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a67:	83 ec 08             	sub    $0x8,%esp
80105a6a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a70:	52                   	push   %edx
80105a71:	50                   	push   %eax
80105a72:	e8 13 b1 ff ff       	call   80100b8a <exec>
80105a77:	83 c4 10             	add    $0x10,%esp
80105a7a:	eb 35                	jmp    80105ab1 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a7c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a85:	c1 e2 02             	shl    $0x2,%edx
80105a88:	01 c2                	add    %eax,%edx
80105a8a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a90:	83 ec 08             	sub    $0x8,%esp
80105a93:	52                   	push   %edx
80105a94:	50                   	push   %eax
80105a95:	e8 cf f1 ff ff       	call   80104c69 <fetchstr>
80105a9a:	83 c4 10             	add    $0x10,%esp
80105a9d:	85 c0                	test   %eax,%eax
80105a9f:	79 07                	jns    80105aa8 <sys_exec+0xfd>
      return -1;
80105aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa6:	eb 09                	jmp    80105ab1 <sys_exec+0x106>
  for(i=0;; i++){
80105aa8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105aac:	e9 5a ff ff ff       	jmp    80105a0b <sys_exec+0x60>
}
80105ab1:	c9                   	leave
80105ab2:	c3                   	ret

80105ab3 <sys_pipe>:

int
sys_pipe(void)
{
80105ab3:	55                   	push   %ebp
80105ab4:	89 e5                	mov    %esp,%ebp
80105ab6:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ab9:	83 ec 04             	sub    $0x4,%esp
80105abc:	6a 08                	push   $0x8
80105abe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ac1:	50                   	push   %eax
80105ac2:	6a 00                	push   $0x0
80105ac4:	e8 2f f2 ff ff       	call   80104cf8 <argptr>
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	85 c0                	test   %eax,%eax
80105ace:	79 0a                	jns    80105ada <sys_pipe+0x27>
    return -1;
80105ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad5:	e9 ae 00 00 00       	jmp    80105b88 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ada:	83 ec 08             	sub    $0x8,%esp
80105add:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ae0:	50                   	push   %eax
80105ae1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ae4:	50                   	push   %eax
80105ae5:	e8 83 da ff ff       	call   8010356d <pipealloc>
80105aea:	83 c4 10             	add    $0x10,%esp
80105aed:	85 c0                	test   %eax,%eax
80105aef:	79 0a                	jns    80105afb <sys_pipe+0x48>
    return -1;
80105af1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af6:	e9 8d 00 00 00       	jmp    80105b88 <sys_pipe+0xd5>
  fd0 = -1;
80105afb:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	50                   	push   %eax
80105b09:	e8 7b f3 ff ff       	call   80104e89 <fdalloc>
80105b0e:	83 c4 10             	add    $0x10,%esp
80105b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b18:	78 18                	js     80105b32 <sys_pipe+0x7f>
80105b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b1d:	83 ec 0c             	sub    $0xc,%esp
80105b20:	50                   	push   %eax
80105b21:	e8 63 f3 ff ff       	call   80104e89 <fdalloc>
80105b26:	83 c4 10             	add    $0x10,%esp
80105b29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b30:	79 3e                	jns    80105b70 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b36:	78 13                	js     80105b4b <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b38:	e8 f3 de ff ff       	call   80103a30 <myproc>
80105b3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b40:	83 c2 08             	add    $0x8,%edx
80105b43:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b4a:	00 
    fileclose(rf);
80105b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b4e:	83 ec 0c             	sub    $0xc,%esp
80105b51:	50                   	push   %eax
80105b52:	e8 4e b5 ff ff       	call   801010a5 <fileclose>
80105b57:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b5d:	83 ec 0c             	sub    $0xc,%esp
80105b60:	50                   	push   %eax
80105b61:	e8 3f b5 ff ff       	call   801010a5 <fileclose>
80105b66:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6e:	eb 18                	jmp    80105b88 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b76:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b7b:	8d 50 04             	lea    0x4(%eax),%edx
80105b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b81:	89 02                	mov    %eax,(%edx)
  return 0;
80105b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b88:	c9                   	leave
80105b89:	c3                   	ret

80105b8a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b8a:	55                   	push   %ebp
80105b8b:	89 e5                	mov    %esp,%ebp
80105b8d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b90:	e8 9d e1 ff ff       	call   80103d32 <fork>
}
80105b95:	c9                   	leave
80105b96:	c3                   	ret

80105b97 <sys_exit>:

int
sys_exit(void)
{
80105b97:	55                   	push   %ebp
80105b98:	89 e5                	mov    %esp,%ebp
80105b9a:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b9d:	e8 09 e3 ff ff       	call   80103eab <exit>
  return 0;  // not reached
80105ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba7:	c9                   	leave
80105ba8:	c3                   	ret

80105ba9 <sys_wait>:

int
sys_wait(void)
{
80105ba9:	55                   	push   %ebp
80105baa:	89 e5                	mov    %esp,%ebp
80105bac:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105baf:	e8 1a e4 ff ff       	call   80103fce <wait>
}
80105bb4:	c9                   	leave
80105bb5:	c3                   	ret

80105bb6 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105bb6:	55                   	push   %ebp
80105bb7:	89 e5                	mov    %esp,%ebp
80105bb9:	83 ec 18             	sub    $0x18,%esp
    int addr;
    if (argint(0, &addr) < 0)
80105bbc:	83 ec 08             	sub    $0x8,%esp
80105bbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc2:	50                   	push   %eax
80105bc3:	6a 00                	push   $0x0
80105bc5:	e8 01 f1 ff ff       	call   80104ccb <argint>
80105bca:	83 c4 10             	add    $0x10,%esp
80105bcd:	85 c0                	test   %eax,%eax
80105bcf:	79 07                	jns    80105bd8 <sys_uthread_init+0x22>
        return -1;
80105bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd6:	eb 14                	jmp    80105bec <sys_uthread_init+0x36>

    void (*address)(void) = (void (*)(void)) addr;
80105bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return uthread_init(address);
80105bde:	83 ec 0c             	sub    $0xc,%esp
80105be1:	ff 75 f4             	push   -0xc(%ebp)
80105be4:	e8 c3 e5 ff ff       	call   801041ac <uthread_init>
80105be9:	83 c4 10             	add    $0x10,%esp
}
80105bec:	c9                   	leave
80105bed:	c3                   	ret

80105bee <sys_kill>:

int
sys_kill(void)
{
80105bee:	55                   	push   %ebp
80105bef:	89 e5                	mov    %esp,%ebp
80105bf1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105bf4:	83 ec 08             	sub    $0x8,%esp
80105bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bfa:	50                   	push   %eax
80105bfb:	6a 00                	push   $0x0
80105bfd:	e8 c9 f0 ff ff       	call   80104ccb <argint>
80105c02:	83 c4 10             	add    $0x10,%esp
80105c05:	85 c0                	test   %eax,%eax
80105c07:	79 07                	jns    80105c10 <sys_kill+0x22>
    return -1;
80105c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0e:	eb 0f                	jmp    80105c1f <sys_kill+0x31>
  return kill(pid);
80105c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	50                   	push   %eax
80105c17:	e8 0b e8 ff ff       	call   80104427 <kill>
80105c1c:	83 c4 10             	add    $0x10,%esp
}
80105c1f:	c9                   	leave
80105c20:	c3                   	ret

80105c21 <sys_getpid>:

int
sys_getpid(void)
{
80105c21:	55                   	push   %ebp
80105c22:	89 e5                	mov    %esp,%ebp
80105c24:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105c27:	e8 04 de ff ff       	call   80103a30 <myproc>
80105c2c:	8b 40 10             	mov    0x10(%eax),%eax
}
80105c2f:	c9                   	leave
80105c30:	c3                   	ret

80105c31 <sys_sbrk>:

int
sys_sbrk(void)
{
80105c31:	55                   	push   %ebp
80105c32:	89 e5                	mov    %esp,%ebp
80105c34:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105c37:	83 ec 08             	sub    $0x8,%esp
80105c3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c3d:	50                   	push   %eax
80105c3e:	6a 00                	push   $0x0
80105c40:	e8 86 f0 ff ff       	call   80104ccb <argint>
80105c45:	83 c4 10             	add    $0x10,%esp
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	79 07                	jns    80105c53 <sys_sbrk+0x22>
    return -1;
80105c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c51:	eb 27                	jmp    80105c7a <sys_sbrk+0x49>
  addr = myproc()->sz;
80105c53:	e8 d8 dd ff ff       	call   80103a30 <myproc>
80105c58:	8b 00                	mov    (%eax),%eax
80105c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c60:	83 ec 0c             	sub    $0xc,%esp
80105c63:	50                   	push   %eax
80105c64:	e8 2e e0 ff ff       	call   80103c97 <growproc>
80105c69:	83 c4 10             	add    $0x10,%esp
80105c6c:	85 c0                	test   %eax,%eax
80105c6e:	79 07                	jns    80105c77 <sys_sbrk+0x46>
    return -1;
80105c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c75:	eb 03                	jmp    80105c7a <sys_sbrk+0x49>
  return addr;
80105c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c7a:	c9                   	leave
80105c7b:	c3                   	ret

80105c7c <sys_sleep>:

int
sys_sleep(void)
{
80105c7c:	55                   	push   %ebp
80105c7d:	89 e5                	mov    %esp,%ebp
80105c7f:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c82:	83 ec 08             	sub    $0x8,%esp
80105c85:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c88:	50                   	push   %eax
80105c89:	6a 00                	push   $0x0
80105c8b:	e8 3b f0 ff ff       	call   80104ccb <argint>
80105c90:	83 c4 10             	add    $0x10,%esp
80105c93:	85 c0                	test   %eax,%eax
80105c95:	79 07                	jns    80105c9e <sys_sleep+0x22>
    return -1;
80105c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9c:	eb 76                	jmp    80105d14 <sys_sleep+0x98>
  acquire(&tickslock);
80105c9e:	83 ec 0c             	sub    $0xc,%esp
80105ca1:	68 40 6b 19 80       	push   $0x80196b40
80105ca6:	e8 7f ea ff ff       	call   8010472a <acquire>
80105cab:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105cae:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105cb6:	eb 38                	jmp    80105cf0 <sys_sleep+0x74>
    if(myproc()->killed){
80105cb8:	e8 73 dd ff ff       	call   80103a30 <myproc>
80105cbd:	8b 40 24             	mov    0x24(%eax),%eax
80105cc0:	85 c0                	test   %eax,%eax
80105cc2:	74 17                	je     80105cdb <sys_sleep+0x5f>
      release(&tickslock);
80105cc4:	83 ec 0c             	sub    $0xc,%esp
80105cc7:	68 40 6b 19 80       	push   $0x80196b40
80105ccc:	e8 c7 ea ff ff       	call   80104798 <release>
80105cd1:	83 c4 10             	add    $0x10,%esp
      return -1;
80105cd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd9:	eb 39                	jmp    80105d14 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105cdb:	83 ec 08             	sub    $0x8,%esp
80105cde:	68 40 6b 19 80       	push   $0x80196b40
80105ce3:	68 74 6b 19 80       	push   $0x80196b74
80105ce8:	e8 19 e6 ff ff       	call   80104306 <sleep>
80105ced:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105cf0:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105cf5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105cf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cfb:	39 d0                	cmp    %edx,%eax
80105cfd:	72 b9                	jb     80105cb8 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105cff:	83 ec 0c             	sub    $0xc,%esp
80105d02:	68 40 6b 19 80       	push   $0x80196b40
80105d07:	e8 8c ea ff ff       	call   80104798 <release>
80105d0c:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d14:	c9                   	leave
80105d15:	c3                   	ret

80105d16 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105d16:	55                   	push   %ebp
80105d17:	89 e5                	mov    %esp,%ebp
80105d19:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	68 40 6b 19 80       	push   $0x80196b40
80105d24:	e8 01 ea ff ff       	call   8010472a <acquire>
80105d29:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105d2c:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105d34:	83 ec 0c             	sub    $0xc,%esp
80105d37:	68 40 6b 19 80       	push   $0x80196b40
80105d3c:	e8 57 ea ff ff       	call   80104798 <release>
80105d41:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d47:	c9                   	leave
80105d48:	c3                   	ret

80105d49 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d49:	1e                   	push   %ds
  pushl %es
80105d4a:	06                   	push   %es
  pushl %fs
80105d4b:	0f a0                	push   %fs
  pushl %gs
80105d4d:	0f a8                	push   %gs
  pushal
80105d4f:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d50:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d54:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d56:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d58:	54                   	push   %esp
  call trap
80105d59:	e8 d7 01 00 00       	call   80105f35 <trap>
  addl $4, %esp
80105d5e:	83 c4 04             	add    $0x4,%esp

80105d61 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d61:	61                   	popa
  popl %gs
80105d62:	0f a9                	pop    %gs
  popl %fs
80105d64:	0f a1                	pop    %fs
  popl %es
80105d66:	07                   	pop    %es
  popl %ds
80105d67:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d68:	83 c4 08             	add    $0x8,%esp
  iret
80105d6b:	cf                   	iret

80105d6c <lidt>:
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d75:	83 e8 01             	sub    $0x1,%eax
80105d78:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d83:	8b 45 08             	mov    0x8(%ebp),%eax
80105d86:	c1 e8 10             	shr    $0x10,%eax
80105d89:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d8d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d90:	0f 01 18             	lidtl  (%eax)
}
80105d93:	90                   	nop
80105d94:	c9                   	leave
80105d95:	c3                   	ret

80105d96 <rcr2>:

static inline uint
rcr2(void)
{
80105d96:	55                   	push   %ebp
80105d97:	89 e5                	mov    %esp,%ebp
80105d99:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d9c:	0f 20 d0             	mov    %cr2,%eax
80105d9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105da5:	c9                   	leave
80105da6:	c3                   	ret

80105da7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105da7:	55                   	push   %ebp
80105da8:	89 e5                	mov    %esp,%ebp
80105daa:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105dad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105db4:	e9 c3 00 00 00       	jmp    80105e7c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbc:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105dc3:	89 c2                	mov    %eax,%edx
80105dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc8:	66 89 14 c5 40 63 19 	mov    %dx,-0x7fe69cc0(,%eax,8)
80105dcf:	80 
80105dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd3:	66 c7 04 c5 42 63 19 	movw   $0x8,-0x7fe69cbe(,%eax,8)
80105dda:	80 08 00 
80105ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de0:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105de7:	80 
80105de8:	83 e2 e0             	and    $0xffffffe0,%edx
80105deb:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df5:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105dfc:	80 
80105dfd:	83 e2 1f             	and    $0x1f,%edx
80105e00:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e11:	80 
80105e12:	83 e2 f0             	and    $0xfffffff0,%edx
80105e15:	83 ca 0e             	or     $0xe,%edx
80105e18:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e22:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e29:	80 
80105e2a:	83 e2 ef             	and    $0xffffffef,%edx
80105e2d:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e37:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e3e:	80 
80105e3f:	83 e2 9f             	and    $0xffffff9f,%edx
80105e42:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e53:	80 
80105e54:	83 ca 80             	or     $0xffffff80,%edx
80105e57:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e68:	c1 e8 10             	shr    $0x10,%eax
80105e6b:	89 c2                	mov    %eax,%edx
80105e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e70:	66 89 14 c5 46 63 19 	mov    %dx,-0x7fe69cba(,%eax,8)
80105e77:	80 
  for(i = 0; i < 256; i++)
80105e78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e7c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e83:	0f 8e 30 ff ff ff    	jle    80105db9 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e89:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105e8e:	66 a3 40 65 19 80    	mov    %ax,0x80196540
80105e94:	66 c7 05 42 65 19 80 	movw   $0x8,0x80196542
80105e9b:	08 00 
80105e9d:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105ea4:	83 e0 e0             	and    $0xffffffe0,%eax
80105ea7:	a2 44 65 19 80       	mov    %al,0x80196544
80105eac:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105eb3:	83 e0 1f             	and    $0x1f,%eax
80105eb6:	a2 44 65 19 80       	mov    %al,0x80196544
80105ebb:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105ec2:	83 c8 0f             	or     $0xf,%eax
80105ec5:	a2 45 65 19 80       	mov    %al,0x80196545
80105eca:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105ed1:	83 e0 ef             	and    $0xffffffef,%eax
80105ed4:	a2 45 65 19 80       	mov    %al,0x80196545
80105ed9:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105ee0:	83 c8 60             	or     $0x60,%eax
80105ee3:	a2 45 65 19 80       	mov    %al,0x80196545
80105ee8:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105eef:	83 c8 80             	or     $0xffffff80,%eax
80105ef2:	a2 45 65 19 80       	mov    %al,0x80196545
80105ef7:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105efc:	c1 e8 10             	shr    $0x10,%eax
80105eff:	66 a3 46 65 19 80    	mov    %ax,0x80196546

  initlock(&tickslock, "time");
80105f05:	83 ec 08             	sub    $0x8,%esp
80105f08:	68 38 a4 10 80       	push   $0x8010a438
80105f0d:	68 40 6b 19 80       	push   $0x80196b40
80105f12:	e8 f1 e7 ff ff       	call   80104708 <initlock>
80105f17:	83 c4 10             	add    $0x10,%esp
}
80105f1a:	90                   	nop
80105f1b:	c9                   	leave
80105f1c:	c3                   	ret

80105f1d <idtinit>:

void
idtinit(void)
{
80105f1d:	55                   	push   %ebp
80105f1e:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f20:	68 00 08 00 00       	push   $0x800
80105f25:	68 40 63 19 80       	push   $0x80196340
80105f2a:	e8 3d fe ff ff       	call   80105d6c <lidt>
80105f2f:	83 c4 08             	add    $0x8,%esp
}
80105f32:	90                   	nop
80105f33:	c9                   	leave
80105f34:	c3                   	ret

80105f35 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f35:	55                   	push   %ebp
80105f36:	89 e5                	mov    %esp,%ebp
80105f38:	57                   	push   %edi
80105f39:	56                   	push   %esi
80105f3a:	53                   	push   %ebx
80105f3b:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f41:	8b 40 30             	mov    0x30(%eax),%eax
80105f44:	83 f8 40             	cmp    $0x40,%eax
80105f47:	75 3b                	jne    80105f84 <trap+0x4f>
    if(myproc()->killed)
80105f49:	e8 e2 da ff ff       	call   80103a30 <myproc>
80105f4e:	8b 40 24             	mov    0x24(%eax),%eax
80105f51:	85 c0                	test   %eax,%eax
80105f53:	74 05                	je     80105f5a <trap+0x25>
      exit();
80105f55:	e8 51 df ff ff       	call   80103eab <exit>
    myproc()->tf = tf;
80105f5a:	e8 d1 da ff ff       	call   80103a30 <myproc>
80105f5f:	8b 55 08             	mov    0x8(%ebp),%edx
80105f62:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f65:	e8 2d ee ff ff       	call   80104d97 <syscall>
    if(myproc()->killed)
80105f6a:	e8 c1 da ff ff       	call   80103a30 <myproc>
80105f6f:	8b 40 24             	mov    0x24(%eax),%eax
80105f72:	85 c0                	test   %eax,%eax
80105f74:	0f 84 43 02 00 00    	je     801061bd <trap+0x288>
      exit();
80105f7a:	e8 2c df ff ff       	call   80103eab <exit>
    return;
80105f7f:	e9 39 02 00 00       	jmp    801061bd <trap+0x288>
  }

  switch(tf->trapno){
80105f84:	8b 45 08             	mov    0x8(%ebp),%eax
80105f87:	8b 40 30             	mov    0x30(%eax),%eax
80105f8a:	83 e8 20             	sub    $0x20,%eax
80105f8d:	83 f8 1f             	cmp    $0x1f,%eax
80105f90:	0f 87 f2 00 00 00    	ja     80106088 <trap+0x153>
80105f96:	8b 04 85 e0 a4 10 80 	mov    -0x7fef5b20(,%eax,4),%eax
80105f9d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f9f:	e8 f9 d9 ff ff       	call   8010399d <cpuid>
80105fa4:	85 c0                	test   %eax,%eax
80105fa6:	75 3d                	jne    80105fe5 <trap+0xb0>
      acquire(&tickslock);
80105fa8:	83 ec 0c             	sub    $0xc,%esp
80105fab:	68 40 6b 19 80       	push   $0x80196b40
80105fb0:	e8 75 e7 ff ff       	call   8010472a <acquire>
80105fb5:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105fb8:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105fbd:	83 c0 01             	add    $0x1,%eax
80105fc0:	a3 74 6b 19 80       	mov    %eax,0x80196b74
      wakeup(&ticks);
80105fc5:	83 ec 0c             	sub    $0xc,%esp
80105fc8:	68 74 6b 19 80       	push   $0x80196b74
80105fcd:	e8 1e e4 ff ff       	call   801043f0 <wakeup>
80105fd2:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fd5:	83 ec 0c             	sub    $0xc,%esp
80105fd8:	68 40 6b 19 80       	push   $0x80196b40
80105fdd:	e8 b6 e7 ff ff       	call   80104798 <release>
80105fe2:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80105fe5:	e8 34 cb ff ff       	call   80102b1e <lapiceoi>
    // 추가한 코드
    struct proc* p;
    char* sp;
    p = myproc();
80105fea:	e8 41 da ff ff       	call   80103a30 <myproc>
80105fef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    sp = p->kstack + KSTACKSIZE;
80105ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ff5:	8b 40 08             	mov    0x8(%eax),%eax
80105ff8:	05 00 10 00 00       	add    $0x1000,%eax
80105ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    sp -= 4;
80106000:	83 6d e0 04          	subl   $0x4,-0x20(%ebp)
    *(unsigned int*)sp = (unsigned int)(void*)p->scheduler;
80106004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106007:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010600d:	89 c2                	mov    %eax,%edx
8010600f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106012:	89 10                	mov    %edx,(%eax)
    sp -= 32;
80106014:	83 6d e0 20          	subl   $0x20,-0x20(%ebp)

    break;
80106018:	e9 20 01 00 00       	jmp    8010613d <trap+0x208>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010601d:	e8 db 3e 00 00       	call   80109efd <ideintr>
    lapiceoi();
80106022:	e8 f7 ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106027:	e9 11 01 00 00       	jmp    8010613d <trap+0x208>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010602c:	e8 38 c9 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106031:	e8 e8 ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106036:	e9 02 01 00 00       	jmp    8010613d <trap+0x208>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010603b:	e8 51 03 00 00       	call   80106391 <uartintr>
    lapiceoi();
80106040:	e8 d9 ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106045:	e9 f3 00 00 00       	jmp    8010613d <trap+0x208>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010604a:	e8 77 2b 00 00       	call   80108bc6 <i8254_intr>
    lapiceoi();
8010604f:	e8 ca ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106054:	e9 e4 00 00 00       	jmp    8010613d <trap+0x208>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106059:	8b 45 08             	mov    0x8(%ebp),%eax
8010605c:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010605f:	8b 45 08             	mov    0x8(%ebp),%eax
80106062:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106066:	0f b7 d8             	movzwl %ax,%ebx
80106069:	e8 2f d9 ff ff       	call   8010399d <cpuid>
8010606e:	56                   	push   %esi
8010606f:	53                   	push   %ebx
80106070:	50                   	push   %eax
80106071:	68 40 a4 10 80       	push   $0x8010a440
80106076:	e8 79 a3 ff ff       	call   801003f4 <cprintf>
8010607b:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010607e:	e8 9b ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106083:	e9 b5 00 00 00       	jmp    8010613d <trap+0x208>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106088:	e8 a3 d9 ff ff       	call   80103a30 <myproc>
8010608d:	85 c0                	test   %eax,%eax
8010608f:	74 11                	je     801060a2 <trap+0x16d>
80106091:	8b 45 08             	mov    0x8(%ebp),%eax
80106094:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106098:	0f b7 c0             	movzwl %ax,%eax
8010609b:	83 e0 03             	and    $0x3,%eax
8010609e:	85 c0                	test   %eax,%eax
801060a0:	75 39                	jne    801060db <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801060a2:	e8 ef fc ff ff       	call   80105d96 <rcr2>
801060a7:	89 c3                	mov    %eax,%ebx
801060a9:	8b 45 08             	mov    0x8(%ebp),%eax
801060ac:	8b 70 38             	mov    0x38(%eax),%esi
801060af:	e8 e9 d8 ff ff       	call   8010399d <cpuid>
801060b4:	8b 55 08             	mov    0x8(%ebp),%edx
801060b7:	8b 52 30             	mov    0x30(%edx),%edx
801060ba:	83 ec 0c             	sub    $0xc,%esp
801060bd:	53                   	push   %ebx
801060be:	56                   	push   %esi
801060bf:	50                   	push   %eax
801060c0:	52                   	push   %edx
801060c1:	68 64 a4 10 80       	push   $0x8010a464
801060c6:	e8 29 a3 ff ff       	call   801003f4 <cprintf>
801060cb:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801060ce:	83 ec 0c             	sub    $0xc,%esp
801060d1:	68 96 a4 10 80       	push   $0x8010a496
801060d6:	e8 ce a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060db:	e8 b6 fc ff ff       	call   80105d96 <rcr2>
801060e0:	89 c6                	mov    %eax,%esi
801060e2:	8b 45 08             	mov    0x8(%ebp),%eax
801060e5:	8b 40 38             	mov    0x38(%eax),%eax
801060e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801060eb:	e8 ad d8 ff ff       	call   8010399d <cpuid>
801060f0:	89 c3                	mov    %eax,%ebx
801060f2:	8b 45 08             	mov    0x8(%ebp),%eax
801060f5:	8b 48 34             	mov    0x34(%eax),%ecx
801060f8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801060fb:	8b 45 08             	mov    0x8(%ebp),%eax
801060fe:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106101:	e8 2a d9 ff ff       	call   80103a30 <myproc>
80106106:	8d 50 6c             	lea    0x6c(%eax),%edx
80106109:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010610c:	e8 1f d9 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106111:	8b 40 10             	mov    0x10(%eax),%eax
80106114:	56                   	push   %esi
80106115:	ff 75 d4             	push   -0x2c(%ebp)
80106118:	53                   	push   %ebx
80106119:	ff 75 d0             	push   -0x30(%ebp)
8010611c:	57                   	push   %edi
8010611d:	ff 75 cc             	push   -0x34(%ebp)
80106120:	50                   	push   %eax
80106121:	68 9c a4 10 80       	push   $0x8010a49c
80106126:	e8 c9 a2 ff ff       	call   801003f4 <cprintf>
8010612b:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010612e:	e8 fd d8 ff ff       	call   80103a30 <myproc>
80106133:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010613a:	eb 01                	jmp    8010613d <trap+0x208>
    break;
8010613c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010613d:	e8 ee d8 ff ff       	call   80103a30 <myproc>
80106142:	85 c0                	test   %eax,%eax
80106144:	74 23                	je     80106169 <trap+0x234>
80106146:	e8 e5 d8 ff ff       	call   80103a30 <myproc>
8010614b:	8b 40 24             	mov    0x24(%eax),%eax
8010614e:	85 c0                	test   %eax,%eax
80106150:	74 17                	je     80106169 <trap+0x234>
80106152:	8b 45 08             	mov    0x8(%ebp),%eax
80106155:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106159:	0f b7 c0             	movzwl %ax,%eax
8010615c:	83 e0 03             	and    $0x3,%eax
8010615f:	83 f8 03             	cmp    $0x3,%eax
80106162:	75 05                	jne    80106169 <trap+0x234>
    exit();
80106164:	e8 42 dd ff ff       	call   80103eab <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106169:	e8 c2 d8 ff ff       	call   80103a30 <myproc>
8010616e:	85 c0                	test   %eax,%eax
80106170:	74 1d                	je     8010618f <trap+0x25a>
80106172:	e8 b9 d8 ff ff       	call   80103a30 <myproc>
80106177:	8b 40 0c             	mov    0xc(%eax),%eax
8010617a:	83 f8 04             	cmp    $0x4,%eax
8010617d:	75 10                	jne    8010618f <trap+0x25a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010617f:	8b 45 08             	mov    0x8(%ebp),%eax
80106182:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106185:	83 f8 20             	cmp    $0x20,%eax
80106188:	75 05                	jne    8010618f <trap+0x25a>
    yield();
8010618a:	e8 f7 e0 ff ff       	call   80104286 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010618f:	e8 9c d8 ff ff       	call   80103a30 <myproc>
80106194:	85 c0                	test   %eax,%eax
80106196:	74 26                	je     801061be <trap+0x289>
80106198:	e8 93 d8 ff ff       	call   80103a30 <myproc>
8010619d:	8b 40 24             	mov    0x24(%eax),%eax
801061a0:	85 c0                	test   %eax,%eax
801061a2:	74 1a                	je     801061be <trap+0x289>
801061a4:	8b 45 08             	mov    0x8(%ebp),%eax
801061a7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061ab:	0f b7 c0             	movzwl %ax,%eax
801061ae:	83 e0 03             	and    $0x3,%eax
801061b1:	83 f8 03             	cmp    $0x3,%eax
801061b4:	75 08                	jne    801061be <trap+0x289>
    exit();
801061b6:	e8 f0 dc ff ff       	call   80103eab <exit>
801061bb:	eb 01                	jmp    801061be <trap+0x289>
    return;
801061bd:	90                   	nop
}
801061be:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061c1:	5b                   	pop    %ebx
801061c2:	5e                   	pop    %esi
801061c3:	5f                   	pop    %edi
801061c4:	5d                   	pop    %ebp
801061c5:	c3                   	ret

801061c6 <inb>:
{
801061c6:	55                   	push   %ebp
801061c7:	89 e5                	mov    %esp,%ebp
801061c9:	83 ec 14             	sub    $0x14,%esp
801061cc:	8b 45 08             	mov    0x8(%ebp),%eax
801061cf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801061d3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801061d7:	89 c2                	mov    %eax,%edx
801061d9:	ec                   	in     (%dx),%al
801061da:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801061dd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801061e1:	c9                   	leave
801061e2:	c3                   	ret

801061e3 <outb>:
{
801061e3:	55                   	push   %ebp
801061e4:	89 e5                	mov    %esp,%ebp
801061e6:	83 ec 08             	sub    $0x8,%esp
801061e9:	8b 55 08             	mov    0x8(%ebp),%edx
801061ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801061f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061fe:	ee                   	out    %al,(%dx)
}
801061ff:	90                   	nop
80106200:	c9                   	leave
80106201:	c3                   	ret

80106202 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106202:	55                   	push   %ebp
80106203:	89 e5                	mov    %esp,%ebp
80106205:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106208:	6a 00                	push   $0x0
8010620a:	68 fa 03 00 00       	push   $0x3fa
8010620f:	e8 cf ff ff ff       	call   801061e3 <outb>
80106214:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106217:	68 80 00 00 00       	push   $0x80
8010621c:	68 fb 03 00 00       	push   $0x3fb
80106221:	e8 bd ff ff ff       	call   801061e3 <outb>
80106226:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106229:	6a 0c                	push   $0xc
8010622b:	68 f8 03 00 00       	push   $0x3f8
80106230:	e8 ae ff ff ff       	call   801061e3 <outb>
80106235:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106238:	6a 00                	push   $0x0
8010623a:	68 f9 03 00 00       	push   $0x3f9
8010623f:	e8 9f ff ff ff       	call   801061e3 <outb>
80106244:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106247:	6a 03                	push   $0x3
80106249:	68 fb 03 00 00       	push   $0x3fb
8010624e:	e8 90 ff ff ff       	call   801061e3 <outb>
80106253:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106256:	6a 00                	push   $0x0
80106258:	68 fc 03 00 00       	push   $0x3fc
8010625d:	e8 81 ff ff ff       	call   801061e3 <outb>
80106262:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106265:	6a 01                	push   $0x1
80106267:	68 f9 03 00 00       	push   $0x3f9
8010626c:	e8 72 ff ff ff       	call   801061e3 <outb>
80106271:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106274:	68 fd 03 00 00       	push   $0x3fd
80106279:	e8 48 ff ff ff       	call   801061c6 <inb>
8010627e:	83 c4 04             	add    $0x4,%esp
80106281:	3c ff                	cmp    $0xff,%al
80106283:	74 61                	je     801062e6 <uartinit+0xe4>
    return;
  uart = 1;
80106285:	c7 05 78 6b 19 80 01 	movl   $0x1,0x80196b78
8010628c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010628f:	68 fa 03 00 00       	push   $0x3fa
80106294:	e8 2d ff ff ff       	call   801061c6 <inb>
80106299:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010629c:	68 f8 03 00 00       	push   $0x3f8
801062a1:	e8 20 ff ff ff       	call   801061c6 <inb>
801062a6:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801062a9:	83 ec 08             	sub    $0x8,%esp
801062ac:	6a 00                	push   $0x0
801062ae:	6a 04                	push   $0x4
801062b0:	e8 81 c3 ff ff       	call   80102636 <ioapicenable>
801062b5:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801062b8:	c7 45 f4 60 a5 10 80 	movl   $0x8010a560,-0xc(%ebp)
801062bf:	eb 19                	jmp    801062da <uartinit+0xd8>
    uartputc(*p);
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	0f b6 00             	movzbl (%eax),%eax
801062c7:	0f be c0             	movsbl %al,%eax
801062ca:	83 ec 0c             	sub    $0xc,%esp
801062cd:	50                   	push   %eax
801062ce:	e8 16 00 00 00       	call   801062e9 <uartputc>
801062d3:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801062d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dd:	0f b6 00             	movzbl (%eax),%eax
801062e0:	84 c0                	test   %al,%al
801062e2:	75 dd                	jne    801062c1 <uartinit+0xbf>
801062e4:	eb 01                	jmp    801062e7 <uartinit+0xe5>
    return;
801062e6:	90                   	nop
}
801062e7:	c9                   	leave
801062e8:	c3                   	ret

801062e9 <uartputc>:

void
uartputc(int c)
{
801062e9:	55                   	push   %ebp
801062ea:	89 e5                	mov    %esp,%ebp
801062ec:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801062ef:	a1 78 6b 19 80       	mov    0x80196b78,%eax
801062f4:	85 c0                	test   %eax,%eax
801062f6:	74 53                	je     8010634b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062ff:	eb 11                	jmp    80106312 <uartputc+0x29>
    microdelay(10);
80106301:	83 ec 0c             	sub    $0xc,%esp
80106304:	6a 0a                	push   $0xa
80106306:	e8 2e c8 ff ff       	call   80102b39 <microdelay>
8010630b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010630e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106312:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106316:	7f 1a                	jg     80106332 <uartputc+0x49>
80106318:	83 ec 0c             	sub    $0xc,%esp
8010631b:	68 fd 03 00 00       	push   $0x3fd
80106320:	e8 a1 fe ff ff       	call   801061c6 <inb>
80106325:	83 c4 10             	add    $0x10,%esp
80106328:	0f b6 c0             	movzbl %al,%eax
8010632b:	83 e0 20             	and    $0x20,%eax
8010632e:	85 c0                	test   %eax,%eax
80106330:	74 cf                	je     80106301 <uartputc+0x18>
  outb(COM1+0, c);
80106332:	8b 45 08             	mov    0x8(%ebp),%eax
80106335:	0f b6 c0             	movzbl %al,%eax
80106338:	83 ec 08             	sub    $0x8,%esp
8010633b:	50                   	push   %eax
8010633c:	68 f8 03 00 00       	push   $0x3f8
80106341:	e8 9d fe ff ff       	call   801061e3 <outb>
80106346:	83 c4 10             	add    $0x10,%esp
80106349:	eb 01                	jmp    8010634c <uartputc+0x63>
    return;
8010634b:	90                   	nop
}
8010634c:	c9                   	leave
8010634d:	c3                   	ret

8010634e <uartgetc>:

static int
uartgetc(void)
{
8010634e:	55                   	push   %ebp
8010634f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106351:	a1 78 6b 19 80       	mov    0x80196b78,%eax
80106356:	85 c0                	test   %eax,%eax
80106358:	75 07                	jne    80106361 <uartgetc+0x13>
    return -1;
8010635a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635f:	eb 2e                	jmp    8010638f <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106361:	68 fd 03 00 00       	push   $0x3fd
80106366:	e8 5b fe ff ff       	call   801061c6 <inb>
8010636b:	83 c4 04             	add    $0x4,%esp
8010636e:	0f b6 c0             	movzbl %al,%eax
80106371:	83 e0 01             	and    $0x1,%eax
80106374:	85 c0                	test   %eax,%eax
80106376:	75 07                	jne    8010637f <uartgetc+0x31>
    return -1;
80106378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637d:	eb 10                	jmp    8010638f <uartgetc+0x41>
  return inb(COM1+0);
8010637f:	68 f8 03 00 00       	push   $0x3f8
80106384:	e8 3d fe ff ff       	call   801061c6 <inb>
80106389:	83 c4 04             	add    $0x4,%esp
8010638c:	0f b6 c0             	movzbl %al,%eax
}
8010638f:	c9                   	leave
80106390:	c3                   	ret

80106391 <uartintr>:

void
uartintr(void)
{
80106391:	55                   	push   %ebp
80106392:	89 e5                	mov    %esp,%ebp
80106394:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106397:	83 ec 0c             	sub    $0xc,%esp
8010639a:	68 4e 63 10 80       	push   $0x8010634e
8010639f:	e8 32 a4 ff ff       	call   801007d6 <consoleintr>
801063a4:	83 c4 10             	add    $0x10,%esp
}
801063a7:	90                   	nop
801063a8:	c9                   	leave
801063a9:	c3                   	ret

801063aa <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801063aa:	6a 00                	push   $0x0
  pushl $0
801063ac:	6a 00                	push   $0x0
  jmp alltraps
801063ae:	e9 96 f9 ff ff       	jmp    80105d49 <alltraps>

801063b3 <vector1>:
.globl vector1
vector1:
  pushl $0
801063b3:	6a 00                	push   $0x0
  pushl $1
801063b5:	6a 01                	push   $0x1
  jmp alltraps
801063b7:	e9 8d f9 ff ff       	jmp    80105d49 <alltraps>

801063bc <vector2>:
.globl vector2
vector2:
  pushl $0
801063bc:	6a 00                	push   $0x0
  pushl $2
801063be:	6a 02                	push   $0x2
  jmp alltraps
801063c0:	e9 84 f9 ff ff       	jmp    80105d49 <alltraps>

801063c5 <vector3>:
.globl vector3
vector3:
  pushl $0
801063c5:	6a 00                	push   $0x0
  pushl $3
801063c7:	6a 03                	push   $0x3
  jmp alltraps
801063c9:	e9 7b f9 ff ff       	jmp    80105d49 <alltraps>

801063ce <vector4>:
.globl vector4
vector4:
  pushl $0
801063ce:	6a 00                	push   $0x0
  pushl $4
801063d0:	6a 04                	push   $0x4
  jmp alltraps
801063d2:	e9 72 f9 ff ff       	jmp    80105d49 <alltraps>

801063d7 <vector5>:
.globl vector5
vector5:
  pushl $0
801063d7:	6a 00                	push   $0x0
  pushl $5
801063d9:	6a 05                	push   $0x5
  jmp alltraps
801063db:	e9 69 f9 ff ff       	jmp    80105d49 <alltraps>

801063e0 <vector6>:
.globl vector6
vector6:
  pushl $0
801063e0:	6a 00                	push   $0x0
  pushl $6
801063e2:	6a 06                	push   $0x6
  jmp alltraps
801063e4:	e9 60 f9 ff ff       	jmp    80105d49 <alltraps>

801063e9 <vector7>:
.globl vector7
vector7:
  pushl $0
801063e9:	6a 00                	push   $0x0
  pushl $7
801063eb:	6a 07                	push   $0x7
  jmp alltraps
801063ed:	e9 57 f9 ff ff       	jmp    80105d49 <alltraps>

801063f2 <vector8>:
.globl vector8
vector8:
  pushl $8
801063f2:	6a 08                	push   $0x8
  jmp alltraps
801063f4:	e9 50 f9 ff ff       	jmp    80105d49 <alltraps>

801063f9 <vector9>:
.globl vector9
vector9:
  pushl $0
801063f9:	6a 00                	push   $0x0
  pushl $9
801063fb:	6a 09                	push   $0x9
  jmp alltraps
801063fd:	e9 47 f9 ff ff       	jmp    80105d49 <alltraps>

80106402 <vector10>:
.globl vector10
vector10:
  pushl $10
80106402:	6a 0a                	push   $0xa
  jmp alltraps
80106404:	e9 40 f9 ff ff       	jmp    80105d49 <alltraps>

80106409 <vector11>:
.globl vector11
vector11:
  pushl $11
80106409:	6a 0b                	push   $0xb
  jmp alltraps
8010640b:	e9 39 f9 ff ff       	jmp    80105d49 <alltraps>

80106410 <vector12>:
.globl vector12
vector12:
  pushl $12
80106410:	6a 0c                	push   $0xc
  jmp alltraps
80106412:	e9 32 f9 ff ff       	jmp    80105d49 <alltraps>

80106417 <vector13>:
.globl vector13
vector13:
  pushl $13
80106417:	6a 0d                	push   $0xd
  jmp alltraps
80106419:	e9 2b f9 ff ff       	jmp    80105d49 <alltraps>

8010641e <vector14>:
.globl vector14
vector14:
  pushl $14
8010641e:	6a 0e                	push   $0xe
  jmp alltraps
80106420:	e9 24 f9 ff ff       	jmp    80105d49 <alltraps>

80106425 <vector15>:
.globl vector15
vector15:
  pushl $0
80106425:	6a 00                	push   $0x0
  pushl $15
80106427:	6a 0f                	push   $0xf
  jmp alltraps
80106429:	e9 1b f9 ff ff       	jmp    80105d49 <alltraps>

8010642e <vector16>:
.globl vector16
vector16:
  pushl $0
8010642e:	6a 00                	push   $0x0
  pushl $16
80106430:	6a 10                	push   $0x10
  jmp alltraps
80106432:	e9 12 f9 ff ff       	jmp    80105d49 <alltraps>

80106437 <vector17>:
.globl vector17
vector17:
  pushl $17
80106437:	6a 11                	push   $0x11
  jmp alltraps
80106439:	e9 0b f9 ff ff       	jmp    80105d49 <alltraps>

8010643e <vector18>:
.globl vector18
vector18:
  pushl $0
8010643e:	6a 00                	push   $0x0
  pushl $18
80106440:	6a 12                	push   $0x12
  jmp alltraps
80106442:	e9 02 f9 ff ff       	jmp    80105d49 <alltraps>

80106447 <vector19>:
.globl vector19
vector19:
  pushl $0
80106447:	6a 00                	push   $0x0
  pushl $19
80106449:	6a 13                	push   $0x13
  jmp alltraps
8010644b:	e9 f9 f8 ff ff       	jmp    80105d49 <alltraps>

80106450 <vector20>:
.globl vector20
vector20:
  pushl $0
80106450:	6a 00                	push   $0x0
  pushl $20
80106452:	6a 14                	push   $0x14
  jmp alltraps
80106454:	e9 f0 f8 ff ff       	jmp    80105d49 <alltraps>

80106459 <vector21>:
.globl vector21
vector21:
  pushl $0
80106459:	6a 00                	push   $0x0
  pushl $21
8010645b:	6a 15                	push   $0x15
  jmp alltraps
8010645d:	e9 e7 f8 ff ff       	jmp    80105d49 <alltraps>

80106462 <vector22>:
.globl vector22
vector22:
  pushl $0
80106462:	6a 00                	push   $0x0
  pushl $22
80106464:	6a 16                	push   $0x16
  jmp alltraps
80106466:	e9 de f8 ff ff       	jmp    80105d49 <alltraps>

8010646b <vector23>:
.globl vector23
vector23:
  pushl $0
8010646b:	6a 00                	push   $0x0
  pushl $23
8010646d:	6a 17                	push   $0x17
  jmp alltraps
8010646f:	e9 d5 f8 ff ff       	jmp    80105d49 <alltraps>

80106474 <vector24>:
.globl vector24
vector24:
  pushl $0
80106474:	6a 00                	push   $0x0
  pushl $24
80106476:	6a 18                	push   $0x18
  jmp alltraps
80106478:	e9 cc f8 ff ff       	jmp    80105d49 <alltraps>

8010647d <vector25>:
.globl vector25
vector25:
  pushl $0
8010647d:	6a 00                	push   $0x0
  pushl $25
8010647f:	6a 19                	push   $0x19
  jmp alltraps
80106481:	e9 c3 f8 ff ff       	jmp    80105d49 <alltraps>

80106486 <vector26>:
.globl vector26
vector26:
  pushl $0
80106486:	6a 00                	push   $0x0
  pushl $26
80106488:	6a 1a                	push   $0x1a
  jmp alltraps
8010648a:	e9 ba f8 ff ff       	jmp    80105d49 <alltraps>

8010648f <vector27>:
.globl vector27
vector27:
  pushl $0
8010648f:	6a 00                	push   $0x0
  pushl $27
80106491:	6a 1b                	push   $0x1b
  jmp alltraps
80106493:	e9 b1 f8 ff ff       	jmp    80105d49 <alltraps>

80106498 <vector28>:
.globl vector28
vector28:
  pushl $0
80106498:	6a 00                	push   $0x0
  pushl $28
8010649a:	6a 1c                	push   $0x1c
  jmp alltraps
8010649c:	e9 a8 f8 ff ff       	jmp    80105d49 <alltraps>

801064a1 <vector29>:
.globl vector29
vector29:
  pushl $0
801064a1:	6a 00                	push   $0x0
  pushl $29
801064a3:	6a 1d                	push   $0x1d
  jmp alltraps
801064a5:	e9 9f f8 ff ff       	jmp    80105d49 <alltraps>

801064aa <vector30>:
.globl vector30
vector30:
  pushl $0
801064aa:	6a 00                	push   $0x0
  pushl $30
801064ac:	6a 1e                	push   $0x1e
  jmp alltraps
801064ae:	e9 96 f8 ff ff       	jmp    80105d49 <alltraps>

801064b3 <vector31>:
.globl vector31
vector31:
  pushl $0
801064b3:	6a 00                	push   $0x0
  pushl $31
801064b5:	6a 1f                	push   $0x1f
  jmp alltraps
801064b7:	e9 8d f8 ff ff       	jmp    80105d49 <alltraps>

801064bc <vector32>:
.globl vector32
vector32:
  pushl $0
801064bc:	6a 00                	push   $0x0
  pushl $32
801064be:	6a 20                	push   $0x20
  jmp alltraps
801064c0:	e9 84 f8 ff ff       	jmp    80105d49 <alltraps>

801064c5 <vector33>:
.globl vector33
vector33:
  pushl $0
801064c5:	6a 00                	push   $0x0
  pushl $33
801064c7:	6a 21                	push   $0x21
  jmp alltraps
801064c9:	e9 7b f8 ff ff       	jmp    80105d49 <alltraps>

801064ce <vector34>:
.globl vector34
vector34:
  pushl $0
801064ce:	6a 00                	push   $0x0
  pushl $34
801064d0:	6a 22                	push   $0x22
  jmp alltraps
801064d2:	e9 72 f8 ff ff       	jmp    80105d49 <alltraps>

801064d7 <vector35>:
.globl vector35
vector35:
  pushl $0
801064d7:	6a 00                	push   $0x0
  pushl $35
801064d9:	6a 23                	push   $0x23
  jmp alltraps
801064db:	e9 69 f8 ff ff       	jmp    80105d49 <alltraps>

801064e0 <vector36>:
.globl vector36
vector36:
  pushl $0
801064e0:	6a 00                	push   $0x0
  pushl $36
801064e2:	6a 24                	push   $0x24
  jmp alltraps
801064e4:	e9 60 f8 ff ff       	jmp    80105d49 <alltraps>

801064e9 <vector37>:
.globl vector37
vector37:
  pushl $0
801064e9:	6a 00                	push   $0x0
  pushl $37
801064eb:	6a 25                	push   $0x25
  jmp alltraps
801064ed:	e9 57 f8 ff ff       	jmp    80105d49 <alltraps>

801064f2 <vector38>:
.globl vector38
vector38:
  pushl $0
801064f2:	6a 00                	push   $0x0
  pushl $38
801064f4:	6a 26                	push   $0x26
  jmp alltraps
801064f6:	e9 4e f8 ff ff       	jmp    80105d49 <alltraps>

801064fb <vector39>:
.globl vector39
vector39:
  pushl $0
801064fb:	6a 00                	push   $0x0
  pushl $39
801064fd:	6a 27                	push   $0x27
  jmp alltraps
801064ff:	e9 45 f8 ff ff       	jmp    80105d49 <alltraps>

80106504 <vector40>:
.globl vector40
vector40:
  pushl $0
80106504:	6a 00                	push   $0x0
  pushl $40
80106506:	6a 28                	push   $0x28
  jmp alltraps
80106508:	e9 3c f8 ff ff       	jmp    80105d49 <alltraps>

8010650d <vector41>:
.globl vector41
vector41:
  pushl $0
8010650d:	6a 00                	push   $0x0
  pushl $41
8010650f:	6a 29                	push   $0x29
  jmp alltraps
80106511:	e9 33 f8 ff ff       	jmp    80105d49 <alltraps>

80106516 <vector42>:
.globl vector42
vector42:
  pushl $0
80106516:	6a 00                	push   $0x0
  pushl $42
80106518:	6a 2a                	push   $0x2a
  jmp alltraps
8010651a:	e9 2a f8 ff ff       	jmp    80105d49 <alltraps>

8010651f <vector43>:
.globl vector43
vector43:
  pushl $0
8010651f:	6a 00                	push   $0x0
  pushl $43
80106521:	6a 2b                	push   $0x2b
  jmp alltraps
80106523:	e9 21 f8 ff ff       	jmp    80105d49 <alltraps>

80106528 <vector44>:
.globl vector44
vector44:
  pushl $0
80106528:	6a 00                	push   $0x0
  pushl $44
8010652a:	6a 2c                	push   $0x2c
  jmp alltraps
8010652c:	e9 18 f8 ff ff       	jmp    80105d49 <alltraps>

80106531 <vector45>:
.globl vector45
vector45:
  pushl $0
80106531:	6a 00                	push   $0x0
  pushl $45
80106533:	6a 2d                	push   $0x2d
  jmp alltraps
80106535:	e9 0f f8 ff ff       	jmp    80105d49 <alltraps>

8010653a <vector46>:
.globl vector46
vector46:
  pushl $0
8010653a:	6a 00                	push   $0x0
  pushl $46
8010653c:	6a 2e                	push   $0x2e
  jmp alltraps
8010653e:	e9 06 f8 ff ff       	jmp    80105d49 <alltraps>

80106543 <vector47>:
.globl vector47
vector47:
  pushl $0
80106543:	6a 00                	push   $0x0
  pushl $47
80106545:	6a 2f                	push   $0x2f
  jmp alltraps
80106547:	e9 fd f7 ff ff       	jmp    80105d49 <alltraps>

8010654c <vector48>:
.globl vector48
vector48:
  pushl $0
8010654c:	6a 00                	push   $0x0
  pushl $48
8010654e:	6a 30                	push   $0x30
  jmp alltraps
80106550:	e9 f4 f7 ff ff       	jmp    80105d49 <alltraps>

80106555 <vector49>:
.globl vector49
vector49:
  pushl $0
80106555:	6a 00                	push   $0x0
  pushl $49
80106557:	6a 31                	push   $0x31
  jmp alltraps
80106559:	e9 eb f7 ff ff       	jmp    80105d49 <alltraps>

8010655e <vector50>:
.globl vector50
vector50:
  pushl $0
8010655e:	6a 00                	push   $0x0
  pushl $50
80106560:	6a 32                	push   $0x32
  jmp alltraps
80106562:	e9 e2 f7 ff ff       	jmp    80105d49 <alltraps>

80106567 <vector51>:
.globl vector51
vector51:
  pushl $0
80106567:	6a 00                	push   $0x0
  pushl $51
80106569:	6a 33                	push   $0x33
  jmp alltraps
8010656b:	e9 d9 f7 ff ff       	jmp    80105d49 <alltraps>

80106570 <vector52>:
.globl vector52
vector52:
  pushl $0
80106570:	6a 00                	push   $0x0
  pushl $52
80106572:	6a 34                	push   $0x34
  jmp alltraps
80106574:	e9 d0 f7 ff ff       	jmp    80105d49 <alltraps>

80106579 <vector53>:
.globl vector53
vector53:
  pushl $0
80106579:	6a 00                	push   $0x0
  pushl $53
8010657b:	6a 35                	push   $0x35
  jmp alltraps
8010657d:	e9 c7 f7 ff ff       	jmp    80105d49 <alltraps>

80106582 <vector54>:
.globl vector54
vector54:
  pushl $0
80106582:	6a 00                	push   $0x0
  pushl $54
80106584:	6a 36                	push   $0x36
  jmp alltraps
80106586:	e9 be f7 ff ff       	jmp    80105d49 <alltraps>

8010658b <vector55>:
.globl vector55
vector55:
  pushl $0
8010658b:	6a 00                	push   $0x0
  pushl $55
8010658d:	6a 37                	push   $0x37
  jmp alltraps
8010658f:	e9 b5 f7 ff ff       	jmp    80105d49 <alltraps>

80106594 <vector56>:
.globl vector56
vector56:
  pushl $0
80106594:	6a 00                	push   $0x0
  pushl $56
80106596:	6a 38                	push   $0x38
  jmp alltraps
80106598:	e9 ac f7 ff ff       	jmp    80105d49 <alltraps>

8010659d <vector57>:
.globl vector57
vector57:
  pushl $0
8010659d:	6a 00                	push   $0x0
  pushl $57
8010659f:	6a 39                	push   $0x39
  jmp alltraps
801065a1:	e9 a3 f7 ff ff       	jmp    80105d49 <alltraps>

801065a6 <vector58>:
.globl vector58
vector58:
  pushl $0
801065a6:	6a 00                	push   $0x0
  pushl $58
801065a8:	6a 3a                	push   $0x3a
  jmp alltraps
801065aa:	e9 9a f7 ff ff       	jmp    80105d49 <alltraps>

801065af <vector59>:
.globl vector59
vector59:
  pushl $0
801065af:	6a 00                	push   $0x0
  pushl $59
801065b1:	6a 3b                	push   $0x3b
  jmp alltraps
801065b3:	e9 91 f7 ff ff       	jmp    80105d49 <alltraps>

801065b8 <vector60>:
.globl vector60
vector60:
  pushl $0
801065b8:	6a 00                	push   $0x0
  pushl $60
801065ba:	6a 3c                	push   $0x3c
  jmp alltraps
801065bc:	e9 88 f7 ff ff       	jmp    80105d49 <alltraps>

801065c1 <vector61>:
.globl vector61
vector61:
  pushl $0
801065c1:	6a 00                	push   $0x0
  pushl $61
801065c3:	6a 3d                	push   $0x3d
  jmp alltraps
801065c5:	e9 7f f7 ff ff       	jmp    80105d49 <alltraps>

801065ca <vector62>:
.globl vector62
vector62:
  pushl $0
801065ca:	6a 00                	push   $0x0
  pushl $62
801065cc:	6a 3e                	push   $0x3e
  jmp alltraps
801065ce:	e9 76 f7 ff ff       	jmp    80105d49 <alltraps>

801065d3 <vector63>:
.globl vector63
vector63:
  pushl $0
801065d3:	6a 00                	push   $0x0
  pushl $63
801065d5:	6a 3f                	push   $0x3f
  jmp alltraps
801065d7:	e9 6d f7 ff ff       	jmp    80105d49 <alltraps>

801065dc <vector64>:
.globl vector64
vector64:
  pushl $0
801065dc:	6a 00                	push   $0x0
  pushl $64
801065de:	6a 40                	push   $0x40
  jmp alltraps
801065e0:	e9 64 f7 ff ff       	jmp    80105d49 <alltraps>

801065e5 <vector65>:
.globl vector65
vector65:
  pushl $0
801065e5:	6a 00                	push   $0x0
  pushl $65
801065e7:	6a 41                	push   $0x41
  jmp alltraps
801065e9:	e9 5b f7 ff ff       	jmp    80105d49 <alltraps>

801065ee <vector66>:
.globl vector66
vector66:
  pushl $0
801065ee:	6a 00                	push   $0x0
  pushl $66
801065f0:	6a 42                	push   $0x42
  jmp alltraps
801065f2:	e9 52 f7 ff ff       	jmp    80105d49 <alltraps>

801065f7 <vector67>:
.globl vector67
vector67:
  pushl $0
801065f7:	6a 00                	push   $0x0
  pushl $67
801065f9:	6a 43                	push   $0x43
  jmp alltraps
801065fb:	e9 49 f7 ff ff       	jmp    80105d49 <alltraps>

80106600 <vector68>:
.globl vector68
vector68:
  pushl $0
80106600:	6a 00                	push   $0x0
  pushl $68
80106602:	6a 44                	push   $0x44
  jmp alltraps
80106604:	e9 40 f7 ff ff       	jmp    80105d49 <alltraps>

80106609 <vector69>:
.globl vector69
vector69:
  pushl $0
80106609:	6a 00                	push   $0x0
  pushl $69
8010660b:	6a 45                	push   $0x45
  jmp alltraps
8010660d:	e9 37 f7 ff ff       	jmp    80105d49 <alltraps>

80106612 <vector70>:
.globl vector70
vector70:
  pushl $0
80106612:	6a 00                	push   $0x0
  pushl $70
80106614:	6a 46                	push   $0x46
  jmp alltraps
80106616:	e9 2e f7 ff ff       	jmp    80105d49 <alltraps>

8010661b <vector71>:
.globl vector71
vector71:
  pushl $0
8010661b:	6a 00                	push   $0x0
  pushl $71
8010661d:	6a 47                	push   $0x47
  jmp alltraps
8010661f:	e9 25 f7 ff ff       	jmp    80105d49 <alltraps>

80106624 <vector72>:
.globl vector72
vector72:
  pushl $0
80106624:	6a 00                	push   $0x0
  pushl $72
80106626:	6a 48                	push   $0x48
  jmp alltraps
80106628:	e9 1c f7 ff ff       	jmp    80105d49 <alltraps>

8010662d <vector73>:
.globl vector73
vector73:
  pushl $0
8010662d:	6a 00                	push   $0x0
  pushl $73
8010662f:	6a 49                	push   $0x49
  jmp alltraps
80106631:	e9 13 f7 ff ff       	jmp    80105d49 <alltraps>

80106636 <vector74>:
.globl vector74
vector74:
  pushl $0
80106636:	6a 00                	push   $0x0
  pushl $74
80106638:	6a 4a                	push   $0x4a
  jmp alltraps
8010663a:	e9 0a f7 ff ff       	jmp    80105d49 <alltraps>

8010663f <vector75>:
.globl vector75
vector75:
  pushl $0
8010663f:	6a 00                	push   $0x0
  pushl $75
80106641:	6a 4b                	push   $0x4b
  jmp alltraps
80106643:	e9 01 f7 ff ff       	jmp    80105d49 <alltraps>

80106648 <vector76>:
.globl vector76
vector76:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $76
8010664a:	6a 4c                	push   $0x4c
  jmp alltraps
8010664c:	e9 f8 f6 ff ff       	jmp    80105d49 <alltraps>

80106651 <vector77>:
.globl vector77
vector77:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $77
80106653:	6a 4d                	push   $0x4d
  jmp alltraps
80106655:	e9 ef f6 ff ff       	jmp    80105d49 <alltraps>

8010665a <vector78>:
.globl vector78
vector78:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $78
8010665c:	6a 4e                	push   $0x4e
  jmp alltraps
8010665e:	e9 e6 f6 ff ff       	jmp    80105d49 <alltraps>

80106663 <vector79>:
.globl vector79
vector79:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $79
80106665:	6a 4f                	push   $0x4f
  jmp alltraps
80106667:	e9 dd f6 ff ff       	jmp    80105d49 <alltraps>

8010666c <vector80>:
.globl vector80
vector80:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $80
8010666e:	6a 50                	push   $0x50
  jmp alltraps
80106670:	e9 d4 f6 ff ff       	jmp    80105d49 <alltraps>

80106675 <vector81>:
.globl vector81
vector81:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $81
80106677:	6a 51                	push   $0x51
  jmp alltraps
80106679:	e9 cb f6 ff ff       	jmp    80105d49 <alltraps>

8010667e <vector82>:
.globl vector82
vector82:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $82
80106680:	6a 52                	push   $0x52
  jmp alltraps
80106682:	e9 c2 f6 ff ff       	jmp    80105d49 <alltraps>

80106687 <vector83>:
.globl vector83
vector83:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $83
80106689:	6a 53                	push   $0x53
  jmp alltraps
8010668b:	e9 b9 f6 ff ff       	jmp    80105d49 <alltraps>

80106690 <vector84>:
.globl vector84
vector84:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $84
80106692:	6a 54                	push   $0x54
  jmp alltraps
80106694:	e9 b0 f6 ff ff       	jmp    80105d49 <alltraps>

80106699 <vector85>:
.globl vector85
vector85:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $85
8010669b:	6a 55                	push   $0x55
  jmp alltraps
8010669d:	e9 a7 f6 ff ff       	jmp    80105d49 <alltraps>

801066a2 <vector86>:
.globl vector86
vector86:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $86
801066a4:	6a 56                	push   $0x56
  jmp alltraps
801066a6:	e9 9e f6 ff ff       	jmp    80105d49 <alltraps>

801066ab <vector87>:
.globl vector87
vector87:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $87
801066ad:	6a 57                	push   $0x57
  jmp alltraps
801066af:	e9 95 f6 ff ff       	jmp    80105d49 <alltraps>

801066b4 <vector88>:
.globl vector88
vector88:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $88
801066b6:	6a 58                	push   $0x58
  jmp alltraps
801066b8:	e9 8c f6 ff ff       	jmp    80105d49 <alltraps>

801066bd <vector89>:
.globl vector89
vector89:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $89
801066bf:	6a 59                	push   $0x59
  jmp alltraps
801066c1:	e9 83 f6 ff ff       	jmp    80105d49 <alltraps>

801066c6 <vector90>:
.globl vector90
vector90:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $90
801066c8:	6a 5a                	push   $0x5a
  jmp alltraps
801066ca:	e9 7a f6 ff ff       	jmp    80105d49 <alltraps>

801066cf <vector91>:
.globl vector91
vector91:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $91
801066d1:	6a 5b                	push   $0x5b
  jmp alltraps
801066d3:	e9 71 f6 ff ff       	jmp    80105d49 <alltraps>

801066d8 <vector92>:
.globl vector92
vector92:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $92
801066da:	6a 5c                	push   $0x5c
  jmp alltraps
801066dc:	e9 68 f6 ff ff       	jmp    80105d49 <alltraps>

801066e1 <vector93>:
.globl vector93
vector93:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $93
801066e3:	6a 5d                	push   $0x5d
  jmp alltraps
801066e5:	e9 5f f6 ff ff       	jmp    80105d49 <alltraps>

801066ea <vector94>:
.globl vector94
vector94:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $94
801066ec:	6a 5e                	push   $0x5e
  jmp alltraps
801066ee:	e9 56 f6 ff ff       	jmp    80105d49 <alltraps>

801066f3 <vector95>:
.globl vector95
vector95:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $95
801066f5:	6a 5f                	push   $0x5f
  jmp alltraps
801066f7:	e9 4d f6 ff ff       	jmp    80105d49 <alltraps>

801066fc <vector96>:
.globl vector96
vector96:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $96
801066fe:	6a 60                	push   $0x60
  jmp alltraps
80106700:	e9 44 f6 ff ff       	jmp    80105d49 <alltraps>

80106705 <vector97>:
.globl vector97
vector97:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $97
80106707:	6a 61                	push   $0x61
  jmp alltraps
80106709:	e9 3b f6 ff ff       	jmp    80105d49 <alltraps>

8010670e <vector98>:
.globl vector98
vector98:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $98
80106710:	6a 62                	push   $0x62
  jmp alltraps
80106712:	e9 32 f6 ff ff       	jmp    80105d49 <alltraps>

80106717 <vector99>:
.globl vector99
vector99:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $99
80106719:	6a 63                	push   $0x63
  jmp alltraps
8010671b:	e9 29 f6 ff ff       	jmp    80105d49 <alltraps>

80106720 <vector100>:
.globl vector100
vector100:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $100
80106722:	6a 64                	push   $0x64
  jmp alltraps
80106724:	e9 20 f6 ff ff       	jmp    80105d49 <alltraps>

80106729 <vector101>:
.globl vector101
vector101:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $101
8010672b:	6a 65                	push   $0x65
  jmp alltraps
8010672d:	e9 17 f6 ff ff       	jmp    80105d49 <alltraps>

80106732 <vector102>:
.globl vector102
vector102:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $102
80106734:	6a 66                	push   $0x66
  jmp alltraps
80106736:	e9 0e f6 ff ff       	jmp    80105d49 <alltraps>

8010673b <vector103>:
.globl vector103
vector103:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $103
8010673d:	6a 67                	push   $0x67
  jmp alltraps
8010673f:	e9 05 f6 ff ff       	jmp    80105d49 <alltraps>

80106744 <vector104>:
.globl vector104
vector104:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $104
80106746:	6a 68                	push   $0x68
  jmp alltraps
80106748:	e9 fc f5 ff ff       	jmp    80105d49 <alltraps>

8010674d <vector105>:
.globl vector105
vector105:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $105
8010674f:	6a 69                	push   $0x69
  jmp alltraps
80106751:	e9 f3 f5 ff ff       	jmp    80105d49 <alltraps>

80106756 <vector106>:
.globl vector106
vector106:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $106
80106758:	6a 6a                	push   $0x6a
  jmp alltraps
8010675a:	e9 ea f5 ff ff       	jmp    80105d49 <alltraps>

8010675f <vector107>:
.globl vector107
vector107:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $107
80106761:	6a 6b                	push   $0x6b
  jmp alltraps
80106763:	e9 e1 f5 ff ff       	jmp    80105d49 <alltraps>

80106768 <vector108>:
.globl vector108
vector108:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $108
8010676a:	6a 6c                	push   $0x6c
  jmp alltraps
8010676c:	e9 d8 f5 ff ff       	jmp    80105d49 <alltraps>

80106771 <vector109>:
.globl vector109
vector109:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $109
80106773:	6a 6d                	push   $0x6d
  jmp alltraps
80106775:	e9 cf f5 ff ff       	jmp    80105d49 <alltraps>

8010677a <vector110>:
.globl vector110
vector110:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $110
8010677c:	6a 6e                	push   $0x6e
  jmp alltraps
8010677e:	e9 c6 f5 ff ff       	jmp    80105d49 <alltraps>

80106783 <vector111>:
.globl vector111
vector111:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $111
80106785:	6a 6f                	push   $0x6f
  jmp alltraps
80106787:	e9 bd f5 ff ff       	jmp    80105d49 <alltraps>

8010678c <vector112>:
.globl vector112
vector112:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $112
8010678e:	6a 70                	push   $0x70
  jmp alltraps
80106790:	e9 b4 f5 ff ff       	jmp    80105d49 <alltraps>

80106795 <vector113>:
.globl vector113
vector113:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $113
80106797:	6a 71                	push   $0x71
  jmp alltraps
80106799:	e9 ab f5 ff ff       	jmp    80105d49 <alltraps>

8010679e <vector114>:
.globl vector114
vector114:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $114
801067a0:	6a 72                	push   $0x72
  jmp alltraps
801067a2:	e9 a2 f5 ff ff       	jmp    80105d49 <alltraps>

801067a7 <vector115>:
.globl vector115
vector115:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $115
801067a9:	6a 73                	push   $0x73
  jmp alltraps
801067ab:	e9 99 f5 ff ff       	jmp    80105d49 <alltraps>

801067b0 <vector116>:
.globl vector116
vector116:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $116
801067b2:	6a 74                	push   $0x74
  jmp alltraps
801067b4:	e9 90 f5 ff ff       	jmp    80105d49 <alltraps>

801067b9 <vector117>:
.globl vector117
vector117:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $117
801067bb:	6a 75                	push   $0x75
  jmp alltraps
801067bd:	e9 87 f5 ff ff       	jmp    80105d49 <alltraps>

801067c2 <vector118>:
.globl vector118
vector118:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $118
801067c4:	6a 76                	push   $0x76
  jmp alltraps
801067c6:	e9 7e f5 ff ff       	jmp    80105d49 <alltraps>

801067cb <vector119>:
.globl vector119
vector119:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $119
801067cd:	6a 77                	push   $0x77
  jmp alltraps
801067cf:	e9 75 f5 ff ff       	jmp    80105d49 <alltraps>

801067d4 <vector120>:
.globl vector120
vector120:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $120
801067d6:	6a 78                	push   $0x78
  jmp alltraps
801067d8:	e9 6c f5 ff ff       	jmp    80105d49 <alltraps>

801067dd <vector121>:
.globl vector121
vector121:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $121
801067df:	6a 79                	push   $0x79
  jmp alltraps
801067e1:	e9 63 f5 ff ff       	jmp    80105d49 <alltraps>

801067e6 <vector122>:
.globl vector122
vector122:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $122
801067e8:	6a 7a                	push   $0x7a
  jmp alltraps
801067ea:	e9 5a f5 ff ff       	jmp    80105d49 <alltraps>

801067ef <vector123>:
.globl vector123
vector123:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $123
801067f1:	6a 7b                	push   $0x7b
  jmp alltraps
801067f3:	e9 51 f5 ff ff       	jmp    80105d49 <alltraps>

801067f8 <vector124>:
.globl vector124
vector124:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $124
801067fa:	6a 7c                	push   $0x7c
  jmp alltraps
801067fc:	e9 48 f5 ff ff       	jmp    80105d49 <alltraps>

80106801 <vector125>:
.globl vector125
vector125:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $125
80106803:	6a 7d                	push   $0x7d
  jmp alltraps
80106805:	e9 3f f5 ff ff       	jmp    80105d49 <alltraps>

8010680a <vector126>:
.globl vector126
vector126:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $126
8010680c:	6a 7e                	push   $0x7e
  jmp alltraps
8010680e:	e9 36 f5 ff ff       	jmp    80105d49 <alltraps>

80106813 <vector127>:
.globl vector127
vector127:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $127
80106815:	6a 7f                	push   $0x7f
  jmp alltraps
80106817:	e9 2d f5 ff ff       	jmp    80105d49 <alltraps>

8010681c <vector128>:
.globl vector128
vector128:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $128
8010681e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106823:	e9 21 f5 ff ff       	jmp    80105d49 <alltraps>

80106828 <vector129>:
.globl vector129
vector129:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $129
8010682a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010682f:	e9 15 f5 ff ff       	jmp    80105d49 <alltraps>

80106834 <vector130>:
.globl vector130
vector130:
  pushl $0
80106834:	6a 00                	push   $0x0
  pushl $130
80106836:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010683b:	e9 09 f5 ff ff       	jmp    80105d49 <alltraps>

80106840 <vector131>:
.globl vector131
vector131:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $131
80106842:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106847:	e9 fd f4 ff ff       	jmp    80105d49 <alltraps>

8010684c <vector132>:
.globl vector132
vector132:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $132
8010684e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106853:	e9 f1 f4 ff ff       	jmp    80105d49 <alltraps>

80106858 <vector133>:
.globl vector133
vector133:
  pushl $0
80106858:	6a 00                	push   $0x0
  pushl $133
8010685a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010685f:	e9 e5 f4 ff ff       	jmp    80105d49 <alltraps>

80106864 <vector134>:
.globl vector134
vector134:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $134
80106866:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010686b:	e9 d9 f4 ff ff       	jmp    80105d49 <alltraps>

80106870 <vector135>:
.globl vector135
vector135:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $135
80106872:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106877:	e9 cd f4 ff ff       	jmp    80105d49 <alltraps>

8010687c <vector136>:
.globl vector136
vector136:
  pushl $0
8010687c:	6a 00                	push   $0x0
  pushl $136
8010687e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106883:	e9 c1 f4 ff ff       	jmp    80105d49 <alltraps>

80106888 <vector137>:
.globl vector137
vector137:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $137
8010688a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010688f:	e9 b5 f4 ff ff       	jmp    80105d49 <alltraps>

80106894 <vector138>:
.globl vector138
vector138:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $138
80106896:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010689b:	e9 a9 f4 ff ff       	jmp    80105d49 <alltraps>

801068a0 <vector139>:
.globl vector139
vector139:
  pushl $0
801068a0:	6a 00                	push   $0x0
  pushl $139
801068a2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801068a7:	e9 9d f4 ff ff       	jmp    80105d49 <alltraps>

801068ac <vector140>:
.globl vector140
vector140:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $140
801068ae:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801068b3:	e9 91 f4 ff ff       	jmp    80105d49 <alltraps>

801068b8 <vector141>:
.globl vector141
vector141:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $141
801068ba:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801068bf:	e9 85 f4 ff ff       	jmp    80105d49 <alltraps>

801068c4 <vector142>:
.globl vector142
vector142:
  pushl $0
801068c4:	6a 00                	push   $0x0
  pushl $142
801068c6:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801068cb:	e9 79 f4 ff ff       	jmp    80105d49 <alltraps>

801068d0 <vector143>:
.globl vector143
vector143:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $143
801068d2:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801068d7:	e9 6d f4 ff ff       	jmp    80105d49 <alltraps>

801068dc <vector144>:
.globl vector144
vector144:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $144
801068de:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801068e3:	e9 61 f4 ff ff       	jmp    80105d49 <alltraps>

801068e8 <vector145>:
.globl vector145
vector145:
  pushl $0
801068e8:	6a 00                	push   $0x0
  pushl $145
801068ea:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068ef:	e9 55 f4 ff ff       	jmp    80105d49 <alltraps>

801068f4 <vector146>:
.globl vector146
vector146:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $146
801068f6:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801068fb:	e9 49 f4 ff ff       	jmp    80105d49 <alltraps>

80106900 <vector147>:
.globl vector147
vector147:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $147
80106902:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106907:	e9 3d f4 ff ff       	jmp    80105d49 <alltraps>

8010690c <vector148>:
.globl vector148
vector148:
  pushl $0
8010690c:	6a 00                	push   $0x0
  pushl $148
8010690e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106913:	e9 31 f4 ff ff       	jmp    80105d49 <alltraps>

80106918 <vector149>:
.globl vector149
vector149:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $149
8010691a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010691f:	e9 25 f4 ff ff       	jmp    80105d49 <alltraps>

80106924 <vector150>:
.globl vector150
vector150:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $150
80106926:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010692b:	e9 19 f4 ff ff       	jmp    80105d49 <alltraps>

80106930 <vector151>:
.globl vector151
vector151:
  pushl $0
80106930:	6a 00                	push   $0x0
  pushl $151
80106932:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106937:	e9 0d f4 ff ff       	jmp    80105d49 <alltraps>

8010693c <vector152>:
.globl vector152
vector152:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $152
8010693e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106943:	e9 01 f4 ff ff       	jmp    80105d49 <alltraps>

80106948 <vector153>:
.globl vector153
vector153:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $153
8010694a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010694f:	e9 f5 f3 ff ff       	jmp    80105d49 <alltraps>

80106954 <vector154>:
.globl vector154
vector154:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $154
80106956:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010695b:	e9 e9 f3 ff ff       	jmp    80105d49 <alltraps>

80106960 <vector155>:
.globl vector155
vector155:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $155
80106962:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106967:	e9 dd f3 ff ff       	jmp    80105d49 <alltraps>

8010696c <vector156>:
.globl vector156
vector156:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $156
8010696e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106973:	e9 d1 f3 ff ff       	jmp    80105d49 <alltraps>

80106978 <vector157>:
.globl vector157
vector157:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $157
8010697a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010697f:	e9 c5 f3 ff ff       	jmp    80105d49 <alltraps>

80106984 <vector158>:
.globl vector158
vector158:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $158
80106986:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010698b:	e9 b9 f3 ff ff       	jmp    80105d49 <alltraps>

80106990 <vector159>:
.globl vector159
vector159:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $159
80106992:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106997:	e9 ad f3 ff ff       	jmp    80105d49 <alltraps>

8010699c <vector160>:
.globl vector160
vector160:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $160
8010699e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801069a3:	e9 a1 f3 ff ff       	jmp    80105d49 <alltraps>

801069a8 <vector161>:
.globl vector161
vector161:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $161
801069aa:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801069af:	e9 95 f3 ff ff       	jmp    80105d49 <alltraps>

801069b4 <vector162>:
.globl vector162
vector162:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $162
801069b6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801069bb:	e9 89 f3 ff ff       	jmp    80105d49 <alltraps>

801069c0 <vector163>:
.globl vector163
vector163:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $163
801069c2:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801069c7:	e9 7d f3 ff ff       	jmp    80105d49 <alltraps>

801069cc <vector164>:
.globl vector164
vector164:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $164
801069ce:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801069d3:	e9 71 f3 ff ff       	jmp    80105d49 <alltraps>

801069d8 <vector165>:
.globl vector165
vector165:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $165
801069da:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801069df:	e9 65 f3 ff ff       	jmp    80105d49 <alltraps>

801069e4 <vector166>:
.globl vector166
vector166:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $166
801069e6:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069eb:	e9 59 f3 ff ff       	jmp    80105d49 <alltraps>

801069f0 <vector167>:
.globl vector167
vector167:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $167
801069f2:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801069f7:	e9 4d f3 ff ff       	jmp    80105d49 <alltraps>

801069fc <vector168>:
.globl vector168
vector168:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $168
801069fe:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a03:	e9 41 f3 ff ff       	jmp    80105d49 <alltraps>

80106a08 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $169
80106a0a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a0f:	e9 35 f3 ff ff       	jmp    80105d49 <alltraps>

80106a14 <vector170>:
.globl vector170
vector170:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $170
80106a16:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a1b:	e9 29 f3 ff ff       	jmp    80105d49 <alltraps>

80106a20 <vector171>:
.globl vector171
vector171:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $171
80106a22:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a27:	e9 1d f3 ff ff       	jmp    80105d49 <alltraps>

80106a2c <vector172>:
.globl vector172
vector172:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $172
80106a2e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a33:	e9 11 f3 ff ff       	jmp    80105d49 <alltraps>

80106a38 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $173
80106a3a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a3f:	e9 05 f3 ff ff       	jmp    80105d49 <alltraps>

80106a44 <vector174>:
.globl vector174
vector174:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $174
80106a46:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a4b:	e9 f9 f2 ff ff       	jmp    80105d49 <alltraps>

80106a50 <vector175>:
.globl vector175
vector175:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $175
80106a52:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a57:	e9 ed f2 ff ff       	jmp    80105d49 <alltraps>

80106a5c <vector176>:
.globl vector176
vector176:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $176
80106a5e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a63:	e9 e1 f2 ff ff       	jmp    80105d49 <alltraps>

80106a68 <vector177>:
.globl vector177
vector177:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $177
80106a6a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a6f:	e9 d5 f2 ff ff       	jmp    80105d49 <alltraps>

80106a74 <vector178>:
.globl vector178
vector178:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $178
80106a76:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a7b:	e9 c9 f2 ff ff       	jmp    80105d49 <alltraps>

80106a80 <vector179>:
.globl vector179
vector179:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $179
80106a82:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a87:	e9 bd f2 ff ff       	jmp    80105d49 <alltraps>

80106a8c <vector180>:
.globl vector180
vector180:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $180
80106a8e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106a93:	e9 b1 f2 ff ff       	jmp    80105d49 <alltraps>

80106a98 <vector181>:
.globl vector181
vector181:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $181
80106a9a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106a9f:	e9 a5 f2 ff ff       	jmp    80105d49 <alltraps>

80106aa4 <vector182>:
.globl vector182
vector182:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $182
80106aa6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106aab:	e9 99 f2 ff ff       	jmp    80105d49 <alltraps>

80106ab0 <vector183>:
.globl vector183
vector183:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $183
80106ab2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ab7:	e9 8d f2 ff ff       	jmp    80105d49 <alltraps>

80106abc <vector184>:
.globl vector184
vector184:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $184
80106abe:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ac3:	e9 81 f2 ff ff       	jmp    80105d49 <alltraps>

80106ac8 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $185
80106aca:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106acf:	e9 75 f2 ff ff       	jmp    80105d49 <alltraps>

80106ad4 <vector186>:
.globl vector186
vector186:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $186
80106ad6:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106adb:	e9 69 f2 ff ff       	jmp    80105d49 <alltraps>

80106ae0 <vector187>:
.globl vector187
vector187:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $187
80106ae2:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ae7:	e9 5d f2 ff ff       	jmp    80105d49 <alltraps>

80106aec <vector188>:
.globl vector188
vector188:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $188
80106aee:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106af3:	e9 51 f2 ff ff       	jmp    80105d49 <alltraps>

80106af8 <vector189>:
.globl vector189
vector189:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $189
80106afa:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106aff:	e9 45 f2 ff ff       	jmp    80105d49 <alltraps>

80106b04 <vector190>:
.globl vector190
vector190:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $190
80106b06:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b0b:	e9 39 f2 ff ff       	jmp    80105d49 <alltraps>

80106b10 <vector191>:
.globl vector191
vector191:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $191
80106b12:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b17:	e9 2d f2 ff ff       	jmp    80105d49 <alltraps>

80106b1c <vector192>:
.globl vector192
vector192:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $192
80106b1e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b23:	e9 21 f2 ff ff       	jmp    80105d49 <alltraps>

80106b28 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $193
80106b2a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b2f:	e9 15 f2 ff ff       	jmp    80105d49 <alltraps>

80106b34 <vector194>:
.globl vector194
vector194:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $194
80106b36:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b3b:	e9 09 f2 ff ff       	jmp    80105d49 <alltraps>

80106b40 <vector195>:
.globl vector195
vector195:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $195
80106b42:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b47:	e9 fd f1 ff ff       	jmp    80105d49 <alltraps>

80106b4c <vector196>:
.globl vector196
vector196:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $196
80106b4e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b53:	e9 f1 f1 ff ff       	jmp    80105d49 <alltraps>

80106b58 <vector197>:
.globl vector197
vector197:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $197
80106b5a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b5f:	e9 e5 f1 ff ff       	jmp    80105d49 <alltraps>

80106b64 <vector198>:
.globl vector198
vector198:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $198
80106b66:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b6b:	e9 d9 f1 ff ff       	jmp    80105d49 <alltraps>

80106b70 <vector199>:
.globl vector199
vector199:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $199
80106b72:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b77:	e9 cd f1 ff ff       	jmp    80105d49 <alltraps>

80106b7c <vector200>:
.globl vector200
vector200:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $200
80106b7e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b83:	e9 c1 f1 ff ff       	jmp    80105d49 <alltraps>

80106b88 <vector201>:
.globl vector201
vector201:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $201
80106b8a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b8f:	e9 b5 f1 ff ff       	jmp    80105d49 <alltraps>

80106b94 <vector202>:
.globl vector202
vector202:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $202
80106b96:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106b9b:	e9 a9 f1 ff ff       	jmp    80105d49 <alltraps>

80106ba0 <vector203>:
.globl vector203
vector203:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $203
80106ba2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106ba7:	e9 9d f1 ff ff       	jmp    80105d49 <alltraps>

80106bac <vector204>:
.globl vector204
vector204:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $204
80106bae:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106bb3:	e9 91 f1 ff ff       	jmp    80105d49 <alltraps>

80106bb8 <vector205>:
.globl vector205
vector205:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $205
80106bba:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106bbf:	e9 85 f1 ff ff       	jmp    80105d49 <alltraps>

80106bc4 <vector206>:
.globl vector206
vector206:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $206
80106bc6:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106bcb:	e9 79 f1 ff ff       	jmp    80105d49 <alltraps>

80106bd0 <vector207>:
.globl vector207
vector207:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $207
80106bd2:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106bd7:	e9 6d f1 ff ff       	jmp    80105d49 <alltraps>

80106bdc <vector208>:
.globl vector208
vector208:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $208
80106bde:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106be3:	e9 61 f1 ff ff       	jmp    80105d49 <alltraps>

80106be8 <vector209>:
.globl vector209
vector209:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $209
80106bea:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106bef:	e9 55 f1 ff ff       	jmp    80105d49 <alltraps>

80106bf4 <vector210>:
.globl vector210
vector210:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $210
80106bf6:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106bfb:	e9 49 f1 ff ff       	jmp    80105d49 <alltraps>

80106c00 <vector211>:
.globl vector211
vector211:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $211
80106c02:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c07:	e9 3d f1 ff ff       	jmp    80105d49 <alltraps>

80106c0c <vector212>:
.globl vector212
vector212:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $212
80106c0e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c13:	e9 31 f1 ff ff       	jmp    80105d49 <alltraps>

80106c18 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $213
80106c1a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c1f:	e9 25 f1 ff ff       	jmp    80105d49 <alltraps>

80106c24 <vector214>:
.globl vector214
vector214:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $214
80106c26:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c2b:	e9 19 f1 ff ff       	jmp    80105d49 <alltraps>

80106c30 <vector215>:
.globl vector215
vector215:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $215
80106c32:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c37:	e9 0d f1 ff ff       	jmp    80105d49 <alltraps>

80106c3c <vector216>:
.globl vector216
vector216:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $216
80106c3e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c43:	e9 01 f1 ff ff       	jmp    80105d49 <alltraps>

80106c48 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $217
80106c4a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c4f:	e9 f5 f0 ff ff       	jmp    80105d49 <alltraps>

80106c54 <vector218>:
.globl vector218
vector218:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $218
80106c56:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c5b:	e9 e9 f0 ff ff       	jmp    80105d49 <alltraps>

80106c60 <vector219>:
.globl vector219
vector219:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $219
80106c62:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c67:	e9 dd f0 ff ff       	jmp    80105d49 <alltraps>

80106c6c <vector220>:
.globl vector220
vector220:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $220
80106c6e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c73:	e9 d1 f0 ff ff       	jmp    80105d49 <alltraps>

80106c78 <vector221>:
.globl vector221
vector221:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $221
80106c7a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c7f:	e9 c5 f0 ff ff       	jmp    80105d49 <alltraps>

80106c84 <vector222>:
.globl vector222
vector222:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $222
80106c86:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c8b:	e9 b9 f0 ff ff       	jmp    80105d49 <alltraps>

80106c90 <vector223>:
.globl vector223
vector223:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $223
80106c92:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106c97:	e9 ad f0 ff ff       	jmp    80105d49 <alltraps>

80106c9c <vector224>:
.globl vector224
vector224:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $224
80106c9e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106ca3:	e9 a1 f0 ff ff       	jmp    80105d49 <alltraps>

80106ca8 <vector225>:
.globl vector225
vector225:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $225
80106caa:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106caf:	e9 95 f0 ff ff       	jmp    80105d49 <alltraps>

80106cb4 <vector226>:
.globl vector226
vector226:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $226
80106cb6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106cbb:	e9 89 f0 ff ff       	jmp    80105d49 <alltraps>

80106cc0 <vector227>:
.globl vector227
vector227:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $227
80106cc2:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106cc7:	e9 7d f0 ff ff       	jmp    80105d49 <alltraps>

80106ccc <vector228>:
.globl vector228
vector228:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $228
80106cce:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106cd3:	e9 71 f0 ff ff       	jmp    80105d49 <alltraps>

80106cd8 <vector229>:
.globl vector229
vector229:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $229
80106cda:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106cdf:	e9 65 f0 ff ff       	jmp    80105d49 <alltraps>

80106ce4 <vector230>:
.globl vector230
vector230:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $230
80106ce6:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106ceb:	e9 59 f0 ff ff       	jmp    80105d49 <alltraps>

80106cf0 <vector231>:
.globl vector231
vector231:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $231
80106cf2:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106cf7:	e9 4d f0 ff ff       	jmp    80105d49 <alltraps>

80106cfc <vector232>:
.globl vector232
vector232:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $232
80106cfe:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d03:	e9 41 f0 ff ff       	jmp    80105d49 <alltraps>

80106d08 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $233
80106d0a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d0f:	e9 35 f0 ff ff       	jmp    80105d49 <alltraps>

80106d14 <vector234>:
.globl vector234
vector234:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $234
80106d16:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d1b:	e9 29 f0 ff ff       	jmp    80105d49 <alltraps>

80106d20 <vector235>:
.globl vector235
vector235:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $235
80106d22:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d27:	e9 1d f0 ff ff       	jmp    80105d49 <alltraps>

80106d2c <vector236>:
.globl vector236
vector236:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $236
80106d2e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d33:	e9 11 f0 ff ff       	jmp    80105d49 <alltraps>

80106d38 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $237
80106d3a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d3f:	e9 05 f0 ff ff       	jmp    80105d49 <alltraps>

80106d44 <vector238>:
.globl vector238
vector238:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $238
80106d46:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d4b:	e9 f9 ef ff ff       	jmp    80105d49 <alltraps>

80106d50 <vector239>:
.globl vector239
vector239:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $239
80106d52:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d57:	e9 ed ef ff ff       	jmp    80105d49 <alltraps>

80106d5c <vector240>:
.globl vector240
vector240:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $240
80106d5e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d63:	e9 e1 ef ff ff       	jmp    80105d49 <alltraps>

80106d68 <vector241>:
.globl vector241
vector241:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $241
80106d6a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d6f:	e9 d5 ef ff ff       	jmp    80105d49 <alltraps>

80106d74 <vector242>:
.globl vector242
vector242:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $242
80106d76:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d7b:	e9 c9 ef ff ff       	jmp    80105d49 <alltraps>

80106d80 <vector243>:
.globl vector243
vector243:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $243
80106d82:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d87:	e9 bd ef ff ff       	jmp    80105d49 <alltraps>

80106d8c <vector244>:
.globl vector244
vector244:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $244
80106d8e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106d93:	e9 b1 ef ff ff       	jmp    80105d49 <alltraps>

80106d98 <vector245>:
.globl vector245
vector245:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $245
80106d9a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106d9f:	e9 a5 ef ff ff       	jmp    80105d49 <alltraps>

80106da4 <vector246>:
.globl vector246
vector246:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $246
80106da6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106dab:	e9 99 ef ff ff       	jmp    80105d49 <alltraps>

80106db0 <vector247>:
.globl vector247
vector247:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $247
80106db2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106db7:	e9 8d ef ff ff       	jmp    80105d49 <alltraps>

80106dbc <vector248>:
.globl vector248
vector248:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $248
80106dbe:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106dc3:	e9 81 ef ff ff       	jmp    80105d49 <alltraps>

80106dc8 <vector249>:
.globl vector249
vector249:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $249
80106dca:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106dcf:	e9 75 ef ff ff       	jmp    80105d49 <alltraps>

80106dd4 <vector250>:
.globl vector250
vector250:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $250
80106dd6:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ddb:	e9 69 ef ff ff       	jmp    80105d49 <alltraps>

80106de0 <vector251>:
.globl vector251
vector251:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $251
80106de2:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106de7:	e9 5d ef ff ff       	jmp    80105d49 <alltraps>

80106dec <vector252>:
.globl vector252
vector252:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $252
80106dee:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106df3:	e9 51 ef ff ff       	jmp    80105d49 <alltraps>

80106df8 <vector253>:
.globl vector253
vector253:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $253
80106dfa:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106dff:	e9 45 ef ff ff       	jmp    80105d49 <alltraps>

80106e04 <vector254>:
.globl vector254
vector254:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $254
80106e06:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e0b:	e9 39 ef ff ff       	jmp    80105d49 <alltraps>

80106e10 <vector255>:
.globl vector255
vector255:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $255
80106e12:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e17:	e9 2d ef ff ff       	jmp    80105d49 <alltraps>

80106e1c <lgdt>:
{
80106e1c:	55                   	push   %ebp
80106e1d:	89 e5                	mov    %esp,%ebp
80106e1f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e25:	83 e8 01             	sub    $0x1,%eax
80106e28:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e33:	8b 45 08             	mov    0x8(%ebp),%eax
80106e36:	c1 e8 10             	shr    $0x10,%eax
80106e39:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106e3d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e40:	0f 01 10             	lgdtl  (%eax)
}
80106e43:	90                   	nop
80106e44:	c9                   	leave
80106e45:	c3                   	ret

80106e46 <ltr>:
{
80106e46:	55                   	push   %ebp
80106e47:	89 e5                	mov    %esp,%ebp
80106e49:	83 ec 04             	sub    $0x4,%esp
80106e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e53:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106e57:	0f 00 d8             	ltr    %eax
}
80106e5a:	90                   	nop
80106e5b:	c9                   	leave
80106e5c:	c3                   	ret

80106e5d <lcr3>:

static inline void
lcr3(uint val)
{
80106e5d:	55                   	push   %ebp
80106e5e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e60:	8b 45 08             	mov    0x8(%ebp),%eax
80106e63:	0f 22 d8             	mov    %eax,%cr3
}
80106e66:	90                   	nop
80106e67:	5d                   	pop    %ebp
80106e68:	c3                   	ret

80106e69 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106e69:	55                   	push   %ebp
80106e6a:	89 e5                	mov    %esp,%ebp
80106e6c:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106e6f:	e8 29 cb ff ff       	call   8010399d <cpuid>
80106e74:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106e7a:	05 80 6b 19 80       	add    $0x80196b80,%eax
80106e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e85:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e8e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e97:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ea2:	83 e2 f0             	and    $0xfffffff0,%edx
80106ea5:	83 ca 0a             	or     $0xa,%edx
80106ea8:	88 50 7d             	mov    %dl,0x7d(%eax)
80106eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eae:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106eb2:	83 ca 10             	or     $0x10,%edx
80106eb5:	88 50 7d             	mov    %dl,0x7d(%eax)
80106eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ebf:	83 e2 9f             	and    $0xffffff9f,%edx
80106ec2:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ecc:	83 ca 80             	or     $0xffffff80,%edx
80106ecf:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ed9:	83 ca 0f             	or     $0xf,%edx
80106edc:	88 50 7e             	mov    %dl,0x7e(%eax)
80106edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ee6:	83 e2 ef             	and    $0xffffffef,%edx
80106ee9:	88 50 7e             	mov    %dl,0x7e(%eax)
80106eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ef3:	83 e2 df             	and    $0xffffffdf,%edx
80106ef6:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f00:	83 ca 40             	or     $0x40,%edx
80106f03:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f09:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f0d:	83 ca 80             	or     $0xffffff80,%edx
80106f10:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f16:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f24:	ff ff 
80106f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f29:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f30:	00 00 
80106f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f35:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f46:	83 e2 f0             	and    $0xfffffff0,%edx
80106f49:	83 ca 02             	or     $0x2,%edx
80106f4c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f55:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f5c:	83 ca 10             	or     $0x10,%edx
80106f5f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f68:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f6f:	83 e2 9f             	and    $0xffffff9f,%edx
80106f72:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f82:	83 ca 80             	or     $0xffffff80,%edx
80106f85:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f95:	83 ca 0f             	or     $0xf,%edx
80106f98:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fa8:	83 e2 ef             	and    $0xffffffef,%edx
80106fab:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fbb:	83 e2 df             	and    $0xffffffdf,%edx
80106fbe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fce:	83 ca 40             	or     $0x40,%edx
80106fd1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fda:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fe1:	83 ca 80             	or     $0xffffff80,%edx
80106fe4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fed:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff7:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106ffe:	ff ff 
80107000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107003:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010700a:	00 00 
8010700c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107019:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107020:	83 e2 f0             	and    $0xfffffff0,%edx
80107023:	83 ca 0a             	or     $0xa,%edx
80107026:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010702c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107036:	83 ca 10             	or     $0x10,%edx
80107039:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010703f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107042:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107049:	83 ca 60             	or     $0x60,%edx
8010704c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107055:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010705c:	83 ca 80             	or     $0xffffff80,%edx
8010705f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107068:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010706f:	83 ca 0f             	or     $0xf,%edx
80107072:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107082:	83 e2 ef             	and    $0xffffffef,%edx
80107085:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010708b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107095:	83 e2 df             	and    $0xffffffdf,%edx
80107098:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010709e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070a8:	83 ca 40             	or     $0x40,%edx
801070ab:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070bb:	83 ca 80             	or     $0xffffff80,%edx
801070be:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801070d8:	ff ff 
801070da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070dd:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801070e4:	00 00 
801070e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801070f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070fa:	83 e2 f0             	and    $0xfffffff0,%edx
801070fd:	83 ca 02             	or     $0x2,%edx
80107100:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107109:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107110:	83 ca 10             	or     $0x10,%edx
80107113:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107123:	83 ca 60             	or     $0x60,%edx
80107126:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010712c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107136:	83 ca 80             	or     $0xffffff80,%edx
80107139:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010713f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107142:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107149:	83 ca 0f             	or     $0xf,%edx
8010714c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107155:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010715c:	83 e2 ef             	and    $0xffffffef,%edx
8010715f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107168:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010716f:	83 e2 df             	and    $0xffffffdf,%edx
80107172:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107182:	83 ca 40             	or     $0x40,%edx
80107185:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010718b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107195:	83 ca 80             	or     $0xffffff80,%edx
80107198:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010719e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801071a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ab:	83 c0 70             	add    $0x70,%eax
801071ae:	83 ec 08             	sub    $0x8,%esp
801071b1:	6a 30                	push   $0x30
801071b3:	50                   	push   %eax
801071b4:	e8 63 fc ff ff       	call   80106e1c <lgdt>
801071b9:	83 c4 10             	add    $0x10,%esp
}
801071bc:	90                   	nop
801071bd:	c9                   	leave
801071be:	c3                   	ret

801071bf <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801071bf:	55                   	push   %ebp
801071c0:	89 e5                	mov    %esp,%ebp
801071c2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801071c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801071c8:	c1 e8 16             	shr    $0x16,%eax
801071cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801071d2:	8b 45 08             	mov    0x8(%ebp),%eax
801071d5:	01 d0                	add    %edx,%eax
801071d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801071da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071dd:	8b 00                	mov    (%eax),%eax
801071df:	83 e0 01             	and    $0x1,%eax
801071e2:	85 c0                	test   %eax,%eax
801071e4:	74 14                	je     801071fa <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071e9:	8b 00                	mov    (%eax),%eax
801071eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071f0:	05 00 00 00 80       	add    $0x80000000,%eax
801071f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071f8:	eb 42                	jmp    8010723c <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801071fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071fe:	74 0e                	je     8010720e <walkpgdir+0x4f>
80107200:	e8 a3 b5 ff ff       	call   801027a8 <kalloc>
80107205:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107208:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010720c:	75 07                	jne    80107215 <walkpgdir+0x56>
      return 0;
8010720e:	b8 00 00 00 00       	mov    $0x0,%eax
80107213:	eb 3e                	jmp    80107253 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107215:	83 ec 04             	sub    $0x4,%esp
80107218:	68 00 10 00 00       	push   $0x1000
8010721d:	6a 00                	push   $0x0
8010721f:	ff 75 f4             	push   -0xc(%ebp)
80107222:	e8 79 d7 ff ff       	call   801049a0 <memset>
80107227:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010722a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722d:	05 00 00 00 80       	add    $0x80000000,%eax
80107232:	83 c8 07             	or     $0x7,%eax
80107235:	89 c2                	mov    %eax,%edx
80107237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010723a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010723c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010723f:	c1 e8 0c             	shr    $0xc,%eax
80107242:	25 ff 03 00 00       	and    $0x3ff,%eax
80107247:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010724e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107251:	01 d0                	add    %edx,%eax
}
80107253:	c9                   	leave
80107254:	c3                   	ret

80107255 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107255:	55                   	push   %ebp
80107256:	89 e5                	mov    %esp,%ebp
80107258:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010725b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010725e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107263:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107266:	8b 55 0c             	mov    0xc(%ebp),%edx
80107269:	8b 45 10             	mov    0x10(%ebp),%eax
8010726c:	01 d0                	add    %edx,%eax
8010726e:	83 e8 01             	sub    $0x1,%eax
80107271:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107276:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107279:	83 ec 04             	sub    $0x4,%esp
8010727c:	6a 01                	push   $0x1
8010727e:	ff 75 f4             	push   -0xc(%ebp)
80107281:	ff 75 08             	push   0x8(%ebp)
80107284:	e8 36 ff ff ff       	call   801071bf <walkpgdir>
80107289:	83 c4 10             	add    $0x10,%esp
8010728c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010728f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107293:	75 07                	jne    8010729c <mappages+0x47>
      return -1;
80107295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010729a:	eb 47                	jmp    801072e3 <mappages+0x8e>
    if(*pte & PTE_P)
8010729c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010729f:	8b 00                	mov    (%eax),%eax
801072a1:	83 e0 01             	and    $0x1,%eax
801072a4:	85 c0                	test   %eax,%eax
801072a6:	74 0d                	je     801072b5 <mappages+0x60>
      panic("remap");
801072a8:	83 ec 0c             	sub    $0xc,%esp
801072ab:	68 68 a5 10 80       	push   $0x8010a568
801072b0:	e8 f4 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801072b5:	8b 45 18             	mov    0x18(%ebp),%eax
801072b8:	0b 45 14             	or     0x14(%ebp),%eax
801072bb:	83 c8 01             	or     $0x1,%eax
801072be:	89 c2                	mov    %eax,%edx
801072c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072c3:	89 10                	mov    %edx,(%eax)
    if(a == last)
801072c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801072cb:	74 10                	je     801072dd <mappages+0x88>
      break;
    a += PGSIZE;
801072cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801072d4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801072db:	eb 9c                	jmp    80107279 <mappages+0x24>
      break;
801072dd:	90                   	nop
  }
  return 0;
801072de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072e3:	c9                   	leave
801072e4:	c3                   	ret

801072e5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801072e5:	55                   	push   %ebp
801072e6:	89 e5                	mov    %esp,%ebp
801072e8:	53                   	push   %ebx
801072e9:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801072ec:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801072f3:	a1 50 6e 19 80       	mov    0x80196e50,%eax
801072f8:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801072fd:	29 c2                	sub    %eax,%edx
801072ff:	89 d0                	mov    %edx,%eax
80107301:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107304:	a1 48 6e 19 80       	mov    0x80196e48,%eax
80107309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010730c:	8b 15 48 6e 19 80    	mov    0x80196e48,%edx
80107312:	a1 50 6e 19 80       	mov    0x80196e50,%eax
80107317:	01 d0                	add    %edx,%eax
80107319:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010731c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107326:	83 c0 30             	add    $0x30,%eax
80107329:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010732c:	89 10                	mov    %edx,(%eax)
8010732e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107331:	89 50 04             	mov    %edx,0x4(%eax)
80107334:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107337:	89 50 08             	mov    %edx,0x8(%eax)
8010733a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010733d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107340:	e8 63 b4 ff ff       	call   801027a8 <kalloc>
80107345:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107348:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010734c:	75 07                	jne    80107355 <setupkvm+0x70>
    return 0;
8010734e:	b8 00 00 00 00       	mov    $0x0,%eax
80107353:	eb 78                	jmp    801073cd <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107355:	83 ec 04             	sub    $0x4,%esp
80107358:	68 00 10 00 00       	push   $0x1000
8010735d:	6a 00                	push   $0x0
8010735f:	ff 75 f0             	push   -0x10(%ebp)
80107362:	e8 39 d6 ff ff       	call   801049a0 <memset>
80107367:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010736a:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107371:	eb 4e                	jmp    801073c1 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107376:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737c:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010737f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107382:	8b 58 08             	mov    0x8(%eax),%ebx
80107385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107388:	8b 40 04             	mov    0x4(%eax),%eax
8010738b:	29 c3                	sub    %eax,%ebx
8010738d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107390:	8b 00                	mov    (%eax),%eax
80107392:	83 ec 0c             	sub    $0xc,%esp
80107395:	51                   	push   %ecx
80107396:	52                   	push   %edx
80107397:	53                   	push   %ebx
80107398:	50                   	push   %eax
80107399:	ff 75 f0             	push   -0x10(%ebp)
8010739c:	e8 b4 fe ff ff       	call   80107255 <mappages>
801073a1:	83 c4 20             	add    $0x20,%esp
801073a4:	85 c0                	test   %eax,%eax
801073a6:	79 15                	jns    801073bd <setupkvm+0xd8>
      freevm(pgdir);
801073a8:	83 ec 0c             	sub    $0xc,%esp
801073ab:	ff 75 f0             	push   -0x10(%ebp)
801073ae:	e8 f5 04 00 00       	call   801078a8 <freevm>
801073b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801073b6:	b8 00 00 00 00       	mov    $0x0,%eax
801073bb:	eb 10                	jmp    801073cd <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073bd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801073c1:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801073c8:	72 a9                	jb     80107373 <setupkvm+0x8e>
    }
  return pgdir;
801073ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801073cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801073d0:	c9                   	leave
801073d1:	c3                   	ret

801073d2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801073d2:	55                   	push   %ebp
801073d3:	89 e5                	mov    %esp,%ebp
801073d5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801073d8:	e8 08 ff ff ff       	call   801072e5 <setupkvm>
801073dd:	a3 7c 6b 19 80       	mov    %eax,0x80196b7c
  switchkvm();
801073e2:	e8 03 00 00 00       	call   801073ea <switchkvm>
}
801073e7:	90                   	nop
801073e8:	c9                   	leave
801073e9:	c3                   	ret

801073ea <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801073ea:	55                   	push   %ebp
801073eb:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073ed:	a1 7c 6b 19 80       	mov    0x80196b7c,%eax
801073f2:	05 00 00 00 80       	add    $0x80000000,%eax
801073f7:	50                   	push   %eax
801073f8:	e8 60 fa ff ff       	call   80106e5d <lcr3>
801073fd:	83 c4 04             	add    $0x4,%esp
}
80107400:	90                   	nop
80107401:	c9                   	leave
80107402:	c3                   	ret

80107403 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107403:	55                   	push   %ebp
80107404:	89 e5                	mov    %esp,%ebp
80107406:	56                   	push   %esi
80107407:	53                   	push   %ebx
80107408:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010740b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010740f:	75 0d                	jne    8010741e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107411:	83 ec 0c             	sub    $0xc,%esp
80107414:	68 6e a5 10 80       	push   $0x8010a56e
80107419:	e8 8b 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010741e:	8b 45 08             	mov    0x8(%ebp),%eax
80107421:	8b 40 08             	mov    0x8(%eax),%eax
80107424:	85 c0                	test   %eax,%eax
80107426:	75 0d                	jne    80107435 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107428:	83 ec 0c             	sub    $0xc,%esp
8010742b:	68 84 a5 10 80       	push   $0x8010a584
80107430:	e8 74 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107435:	8b 45 08             	mov    0x8(%ebp),%eax
80107438:	8b 40 04             	mov    0x4(%eax),%eax
8010743b:	85 c0                	test   %eax,%eax
8010743d:	75 0d                	jne    8010744c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010743f:	83 ec 0c             	sub    $0xc,%esp
80107442:	68 99 a5 10 80       	push   $0x8010a599
80107447:	e8 5d 91 ff ff       	call   801005a9 <panic>

  pushcli();
8010744c:	e8 44 d4 ff ff       	call   80104895 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107451:	e8 62 c5 ff ff       	call   801039b8 <mycpu>
80107456:	89 c3                	mov    %eax,%ebx
80107458:	e8 5b c5 ff ff       	call   801039b8 <mycpu>
8010745d:	83 c0 08             	add    $0x8,%eax
80107460:	89 c6                	mov    %eax,%esi
80107462:	e8 51 c5 ff ff       	call   801039b8 <mycpu>
80107467:	83 c0 08             	add    $0x8,%eax
8010746a:	c1 e8 10             	shr    $0x10,%eax
8010746d:	88 45 f7             	mov    %al,-0x9(%ebp)
80107470:	e8 43 c5 ff ff       	call   801039b8 <mycpu>
80107475:	83 c0 08             	add    $0x8,%eax
80107478:	c1 e8 18             	shr    $0x18,%eax
8010747b:	89 c2                	mov    %eax,%edx
8010747d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107484:	67 00 
80107486:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010748d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107491:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107497:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010749e:	83 e0 f0             	and    $0xfffffff0,%eax
801074a1:	83 c8 09             	or     $0x9,%eax
801074a4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074aa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074b1:	83 c8 10             	or     $0x10,%eax
801074b4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074ba:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074c1:	83 e0 9f             	and    $0xffffff9f,%eax
801074c4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074ca:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074d1:	83 c8 80             	or     $0xffffff80,%eax
801074d4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074da:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074e1:	83 e0 f0             	and    $0xfffffff0,%eax
801074e4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074ea:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074f1:	83 e0 ef             	and    $0xffffffef,%eax
801074f4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074fa:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107501:	83 e0 df             	and    $0xffffffdf,%eax
80107504:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010750a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107511:	83 c8 40             	or     $0x40,%eax
80107514:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010751a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107521:	83 e0 7f             	and    $0x7f,%eax
80107524:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010752a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107530:	e8 83 c4 ff ff       	call   801039b8 <mycpu>
80107535:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010753c:	83 e2 ef             	and    $0xffffffef,%edx
8010753f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107545:	e8 6e c4 ff ff       	call   801039b8 <mycpu>
8010754a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107550:	8b 45 08             	mov    0x8(%ebp),%eax
80107553:	8b 40 08             	mov    0x8(%eax),%eax
80107556:	89 c3                	mov    %eax,%ebx
80107558:	e8 5b c4 ff ff       	call   801039b8 <mycpu>
8010755d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107563:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107566:	e8 4d c4 ff ff       	call   801039b8 <mycpu>
8010756b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107571:	83 ec 0c             	sub    $0xc,%esp
80107574:	6a 28                	push   $0x28
80107576:	e8 cb f8 ff ff       	call   80106e46 <ltr>
8010757b:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010757e:	8b 45 08             	mov    0x8(%ebp),%eax
80107581:	8b 40 04             	mov    0x4(%eax),%eax
80107584:	05 00 00 00 80       	add    $0x80000000,%eax
80107589:	83 ec 0c             	sub    $0xc,%esp
8010758c:	50                   	push   %eax
8010758d:	e8 cb f8 ff ff       	call   80106e5d <lcr3>
80107592:	83 c4 10             	add    $0x10,%esp
  popcli();
80107595:	e8 48 d3 ff ff       	call   801048e2 <popcli>
}
8010759a:	90                   	nop
8010759b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010759e:	5b                   	pop    %ebx
8010759f:	5e                   	pop    %esi
801075a0:	5d                   	pop    %ebp
801075a1:	c3                   	ret

801075a2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801075a2:	55                   	push   %ebp
801075a3:	89 e5                	mov    %esp,%ebp
801075a5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801075a8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801075af:	76 0d                	jbe    801075be <inituvm+0x1c>
    panic("inituvm: more than a page");
801075b1:	83 ec 0c             	sub    $0xc,%esp
801075b4:	68 ad a5 10 80       	push   $0x8010a5ad
801075b9:	e8 eb 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
801075be:	e8 e5 b1 ff ff       	call   801027a8 <kalloc>
801075c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801075c6:	83 ec 04             	sub    $0x4,%esp
801075c9:	68 00 10 00 00       	push   $0x1000
801075ce:	6a 00                	push   $0x0
801075d0:	ff 75 f4             	push   -0xc(%ebp)
801075d3:	e8 c8 d3 ff ff       	call   801049a0 <memset>
801075d8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801075db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075de:	05 00 00 00 80       	add    $0x80000000,%eax
801075e3:	83 ec 0c             	sub    $0xc,%esp
801075e6:	6a 06                	push   $0x6
801075e8:	50                   	push   %eax
801075e9:	68 00 10 00 00       	push   $0x1000
801075ee:	6a 00                	push   $0x0
801075f0:	ff 75 08             	push   0x8(%ebp)
801075f3:	e8 5d fc ff ff       	call   80107255 <mappages>
801075f8:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801075fb:	83 ec 04             	sub    $0x4,%esp
801075fe:	ff 75 10             	push   0x10(%ebp)
80107601:	ff 75 0c             	push   0xc(%ebp)
80107604:	ff 75 f4             	push   -0xc(%ebp)
80107607:	e8 53 d4 ff ff       	call   80104a5f <memmove>
8010760c:	83 c4 10             	add    $0x10,%esp
}
8010760f:	90                   	nop
80107610:	c9                   	leave
80107611:	c3                   	ret

80107612 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107612:	55                   	push   %ebp
80107613:	89 e5                	mov    %esp,%ebp
80107615:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107618:	8b 45 0c             	mov    0xc(%ebp),%eax
8010761b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107620:	85 c0                	test   %eax,%eax
80107622:	74 0d                	je     80107631 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107624:	83 ec 0c             	sub    $0xc,%esp
80107627:	68 c8 a5 10 80       	push   $0x8010a5c8
8010762c:	e8 78 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107638:	e9 8f 00 00 00       	jmp    801076cc <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010763d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	01 d0                	add    %edx,%eax
80107645:	83 ec 04             	sub    $0x4,%esp
80107648:	6a 00                	push   $0x0
8010764a:	50                   	push   %eax
8010764b:	ff 75 08             	push   0x8(%ebp)
8010764e:	e8 6c fb ff ff       	call   801071bf <walkpgdir>
80107653:	83 c4 10             	add    $0x10,%esp
80107656:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107659:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010765d:	75 0d                	jne    8010766c <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010765f:	83 ec 0c             	sub    $0xc,%esp
80107662:	68 eb a5 10 80       	push   $0x8010a5eb
80107667:	e8 3d 8f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010766c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010766f:	8b 00                	mov    (%eax),%eax
80107671:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107676:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107679:	8b 45 18             	mov    0x18(%ebp),%eax
8010767c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010767f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107684:	77 0b                	ja     80107691 <loaduvm+0x7f>
      n = sz - i;
80107686:	8b 45 18             	mov    0x18(%ebp),%eax
80107689:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010768c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010768f:	eb 07                	jmp    80107698 <loaduvm+0x86>
    else
      n = PGSIZE;
80107691:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107698:	8b 55 14             	mov    0x14(%ebp),%edx
8010769b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769e:	01 d0                	add    %edx,%eax
801076a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076a3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801076a9:	ff 75 f0             	push   -0x10(%ebp)
801076ac:	50                   	push   %eax
801076ad:	52                   	push   %edx
801076ae:	ff 75 10             	push   0x10(%ebp)
801076b1:	e8 28 a8 ff ff       	call   80101ede <readi>
801076b6:	83 c4 10             	add    $0x10,%esp
801076b9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801076bc:	74 07                	je     801076c5 <loaduvm+0xb3>
      return -1;
801076be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076c3:	eb 18                	jmp    801076dd <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801076c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801076cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cf:	3b 45 18             	cmp    0x18(%ebp),%eax
801076d2:	0f 82 65 ff ff ff    	jb     8010763d <loaduvm+0x2b>
  }
  return 0;
801076d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801076dd:	c9                   	leave
801076de:	c3                   	ret

801076df <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801076df:	55                   	push   %ebp
801076e0:	89 e5                	mov    %esp,%ebp
801076e2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801076e5:	8b 45 10             	mov    0x10(%ebp),%eax
801076e8:	85 c0                	test   %eax,%eax
801076ea:	79 0a                	jns    801076f6 <allocuvm+0x17>
    return 0;
801076ec:	b8 00 00 00 00       	mov    $0x0,%eax
801076f1:	e9 ec 00 00 00       	jmp    801077e2 <allocuvm+0x103>
  if(newsz < oldsz)
801076f6:	8b 45 10             	mov    0x10(%ebp),%eax
801076f9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801076fc:	73 08                	jae    80107706 <allocuvm+0x27>
    return oldsz;
801076fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107701:	e9 dc 00 00 00       	jmp    801077e2 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107706:	8b 45 0c             	mov    0xc(%ebp),%eax
80107709:	05 ff 0f 00 00       	add    $0xfff,%eax
8010770e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107713:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107716:	e9 b8 00 00 00       	jmp    801077d3 <allocuvm+0xf4>
    mem = kalloc();
8010771b:	e8 88 b0 ff ff       	call   801027a8 <kalloc>
80107720:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107723:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107727:	75 2e                	jne    80107757 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107729:	83 ec 0c             	sub    $0xc,%esp
8010772c:	68 09 a6 10 80       	push   $0x8010a609
80107731:	e8 be 8c ff ff       	call   801003f4 <cprintf>
80107736:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107739:	83 ec 04             	sub    $0x4,%esp
8010773c:	ff 75 0c             	push   0xc(%ebp)
8010773f:	ff 75 10             	push   0x10(%ebp)
80107742:	ff 75 08             	push   0x8(%ebp)
80107745:	e8 9a 00 00 00       	call   801077e4 <deallocuvm>
8010774a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010774d:	b8 00 00 00 00       	mov    $0x0,%eax
80107752:	e9 8b 00 00 00       	jmp    801077e2 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107757:	83 ec 04             	sub    $0x4,%esp
8010775a:	68 00 10 00 00       	push   $0x1000
8010775f:	6a 00                	push   $0x0
80107761:	ff 75 f0             	push   -0x10(%ebp)
80107764:	e8 37 d2 ff ff       	call   801049a0 <memset>
80107769:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010776c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010776f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107778:	83 ec 0c             	sub    $0xc,%esp
8010777b:	6a 06                	push   $0x6
8010777d:	52                   	push   %edx
8010777e:	68 00 10 00 00       	push   $0x1000
80107783:	50                   	push   %eax
80107784:	ff 75 08             	push   0x8(%ebp)
80107787:	e8 c9 fa ff ff       	call   80107255 <mappages>
8010778c:	83 c4 20             	add    $0x20,%esp
8010778f:	85 c0                	test   %eax,%eax
80107791:	79 39                	jns    801077cc <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107793:	83 ec 0c             	sub    $0xc,%esp
80107796:	68 21 a6 10 80       	push   $0x8010a621
8010779b:	e8 54 8c ff ff       	call   801003f4 <cprintf>
801077a0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801077a3:	83 ec 04             	sub    $0x4,%esp
801077a6:	ff 75 0c             	push   0xc(%ebp)
801077a9:	ff 75 10             	push   0x10(%ebp)
801077ac:	ff 75 08             	push   0x8(%ebp)
801077af:	e8 30 00 00 00       	call   801077e4 <deallocuvm>
801077b4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801077b7:	83 ec 0c             	sub    $0xc,%esp
801077ba:	ff 75 f0             	push   -0x10(%ebp)
801077bd:	e8 4c af ff ff       	call   8010270e <kfree>
801077c2:	83 c4 10             	add    $0x10,%esp
      return 0;
801077c5:	b8 00 00 00 00       	mov    $0x0,%eax
801077ca:	eb 16                	jmp    801077e2 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801077cc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d6:	3b 45 10             	cmp    0x10(%ebp),%eax
801077d9:	0f 82 3c ff ff ff    	jb     8010771b <allocuvm+0x3c>
    }
  }
  return newsz;
801077df:	8b 45 10             	mov    0x10(%ebp),%eax
}
801077e2:	c9                   	leave
801077e3:	c3                   	ret

801077e4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077e4:	55                   	push   %ebp
801077e5:	89 e5                	mov    %esp,%ebp
801077e7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801077ea:	8b 45 10             	mov    0x10(%ebp),%eax
801077ed:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077f0:	72 08                	jb     801077fa <deallocuvm+0x16>
    return oldsz;
801077f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801077f5:	e9 ac 00 00 00       	jmp    801078a6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801077fa:	8b 45 10             	mov    0x10(%ebp),%eax
801077fd:	05 ff 0f 00 00       	add    $0xfff,%eax
80107802:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107807:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010780a:	e9 88 00 00 00       	jmp    80107897 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010780f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107812:	83 ec 04             	sub    $0x4,%esp
80107815:	6a 00                	push   $0x0
80107817:	50                   	push   %eax
80107818:	ff 75 08             	push   0x8(%ebp)
8010781b:	e8 9f f9 ff ff       	call   801071bf <walkpgdir>
80107820:	83 c4 10             	add    $0x10,%esp
80107823:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107826:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010782a:	75 16                	jne    80107842 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	c1 e8 16             	shr    $0x16,%eax
80107832:	83 c0 01             	add    $0x1,%eax
80107835:	c1 e0 16             	shl    $0x16,%eax
80107838:	2d 00 10 00 00       	sub    $0x1000,%eax
8010783d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107840:	eb 4e                	jmp    80107890 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107845:	8b 00                	mov    (%eax),%eax
80107847:	83 e0 01             	and    $0x1,%eax
8010784a:	85 c0                	test   %eax,%eax
8010784c:	74 42                	je     80107890 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010784e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107851:	8b 00                	mov    (%eax),%eax
80107853:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107858:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010785b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010785f:	75 0d                	jne    8010786e <deallocuvm+0x8a>
        panic("kfree");
80107861:	83 ec 0c             	sub    $0xc,%esp
80107864:	68 3d a6 10 80       	push   $0x8010a63d
80107869:	e8 3b 8d ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010786e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107871:	05 00 00 00 80       	add    $0x80000000,%eax
80107876:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107879:	83 ec 0c             	sub    $0xc,%esp
8010787c:	ff 75 e8             	push   -0x18(%ebp)
8010787f:	e8 8a ae ff ff       	call   8010270e <kfree>
80107884:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010788a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107890:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010789d:	0f 82 6c ff ff ff    	jb     8010780f <deallocuvm+0x2b>
    }
  }
  return newsz;
801078a3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078a6:	c9                   	leave
801078a7:	c3                   	ret

801078a8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801078a8:	55                   	push   %ebp
801078a9:	89 e5                	mov    %esp,%ebp
801078ab:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801078ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078b2:	75 0d                	jne    801078c1 <freevm+0x19>
    panic("freevm: no pgdir");
801078b4:	83 ec 0c             	sub    $0xc,%esp
801078b7:	68 43 a6 10 80       	push   $0x8010a643
801078bc:	e8 e8 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801078c1:	83 ec 04             	sub    $0x4,%esp
801078c4:	6a 00                	push   $0x0
801078c6:	68 00 00 00 80       	push   $0x80000000
801078cb:	ff 75 08             	push   0x8(%ebp)
801078ce:	e8 11 ff ff ff       	call   801077e4 <deallocuvm>
801078d3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078dd:	eb 48                	jmp    80107927 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078e9:	8b 45 08             	mov    0x8(%ebp),%eax
801078ec:	01 d0                	add    %edx,%eax
801078ee:	8b 00                	mov    (%eax),%eax
801078f0:	83 e0 01             	and    $0x1,%eax
801078f3:	85 c0                	test   %eax,%eax
801078f5:	74 2c                	je     80107923 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107901:	8b 45 08             	mov    0x8(%ebp),%eax
80107904:	01 d0                	add    %edx,%eax
80107906:	8b 00                	mov    (%eax),%eax
80107908:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010790d:	05 00 00 00 80       	add    $0x80000000,%eax
80107912:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107915:	83 ec 0c             	sub    $0xc,%esp
80107918:	ff 75 f0             	push   -0x10(%ebp)
8010791b:	e8 ee ad ff ff       	call   8010270e <kfree>
80107920:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107923:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107927:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010792e:	76 af                	jbe    801078df <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107930:	83 ec 0c             	sub    $0xc,%esp
80107933:	ff 75 08             	push   0x8(%ebp)
80107936:	e8 d3 ad ff ff       	call   8010270e <kfree>
8010793b:	83 c4 10             	add    $0x10,%esp
}
8010793e:	90                   	nop
8010793f:	c9                   	leave
80107940:	c3                   	ret

80107941 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107941:	55                   	push   %ebp
80107942:	89 e5                	mov    %esp,%ebp
80107944:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107947:	83 ec 04             	sub    $0x4,%esp
8010794a:	6a 00                	push   $0x0
8010794c:	ff 75 0c             	push   0xc(%ebp)
8010794f:	ff 75 08             	push   0x8(%ebp)
80107952:	e8 68 f8 ff ff       	call   801071bf <walkpgdir>
80107957:	83 c4 10             	add    $0x10,%esp
8010795a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010795d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107961:	75 0d                	jne    80107970 <clearpteu+0x2f>
    panic("clearpteu");
80107963:	83 ec 0c             	sub    $0xc,%esp
80107966:	68 54 a6 10 80       	push   $0x8010a654
8010796b:	e8 39 8c ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	8b 00                	mov    (%eax),%eax
80107975:	83 e0 fb             	and    $0xfffffffb,%eax
80107978:	89 c2                	mov    %eax,%edx
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	89 10                	mov    %edx,(%eax)
}
8010797f:	90                   	nop
80107980:	c9                   	leave
80107981:	c3                   	ret

80107982 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107982:	55                   	push   %ebp
80107983:	89 e5                	mov    %esp,%ebp
80107985:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107988:	e8 58 f9 ff ff       	call   801072e5 <setupkvm>
8010798d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107990:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107994:	75 0a                	jne    801079a0 <copyuvm+0x1e>
    return 0;
80107996:	b8 00 00 00 00       	mov    $0x0,%eax
8010799b:	e9 eb 00 00 00       	jmp    80107a8b <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801079a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079a7:	e9 b7 00 00 00       	jmp    80107a63 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801079ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079af:	83 ec 04             	sub    $0x4,%esp
801079b2:	6a 00                	push   $0x0
801079b4:	50                   	push   %eax
801079b5:	ff 75 08             	push   0x8(%ebp)
801079b8:	e8 02 f8 ff ff       	call   801071bf <walkpgdir>
801079bd:	83 c4 10             	add    $0x10,%esp
801079c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079c7:	75 0d                	jne    801079d6 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801079c9:	83 ec 0c             	sub    $0xc,%esp
801079cc:	68 5e a6 10 80       	push   $0x8010a65e
801079d1:	e8 d3 8b ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801079d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d9:	8b 00                	mov    (%eax),%eax
801079db:	83 e0 01             	and    $0x1,%eax
801079de:	85 c0                	test   %eax,%eax
801079e0:	75 0d                	jne    801079ef <copyuvm+0x6d>
      panic("copyuvm: page not present");
801079e2:	83 ec 0c             	sub    $0xc,%esp
801079e5:	68 78 a6 10 80       	push   $0x8010a678
801079ea:	e8 ba 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801079ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079f2:	8b 00                	mov    (%eax),%eax
801079f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801079fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079ff:	8b 00                	mov    (%eax),%eax
80107a01:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107a09:	e8 9a ad ff ff       	call   801027a8 <kalloc>
80107a0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107a15:	74 5d                	je     80107a74 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a1a:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1f:	83 ec 04             	sub    $0x4,%esp
80107a22:	68 00 10 00 00       	push   $0x1000
80107a27:	50                   	push   %eax
80107a28:	ff 75 e0             	push   -0x20(%ebp)
80107a2b:	e8 2f d0 ff ff       	call   80104a5f <memmove>
80107a30:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107a33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a39:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	83 ec 0c             	sub    $0xc,%esp
80107a45:	52                   	push   %edx
80107a46:	51                   	push   %ecx
80107a47:	68 00 10 00 00       	push   $0x1000
80107a4c:	50                   	push   %eax
80107a4d:	ff 75 f0             	push   -0x10(%ebp)
80107a50:	e8 00 f8 ff ff       	call   80107255 <mappages>
80107a55:	83 c4 20             	add    $0x20,%esp
80107a58:	85 c0                	test   %eax,%eax
80107a5a:	78 1b                	js     80107a77 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107a5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a69:	0f 82 3d ff ff ff    	jb     801079ac <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a72:	eb 17                	jmp    80107a8b <copyuvm+0x109>
      goto bad;
80107a74:	90                   	nop
80107a75:	eb 01                	jmp    80107a78 <copyuvm+0xf6>
      goto bad;
80107a77:	90                   	nop

bad:
  freevm(d);
80107a78:	83 ec 0c             	sub    $0xc,%esp
80107a7b:	ff 75 f0             	push   -0x10(%ebp)
80107a7e:	e8 25 fe ff ff       	call   801078a8 <freevm>
80107a83:	83 c4 10             	add    $0x10,%esp
  return 0;
80107a86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a8b:	c9                   	leave
80107a8c:	c3                   	ret

80107a8d <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a8d:	55                   	push   %ebp
80107a8e:	89 e5                	mov    %esp,%ebp
80107a90:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a93:	83 ec 04             	sub    $0x4,%esp
80107a96:	6a 00                	push   $0x0
80107a98:	ff 75 0c             	push   0xc(%ebp)
80107a9b:	ff 75 08             	push   0x8(%ebp)
80107a9e:	e8 1c f7 ff ff       	call   801071bf <walkpgdir>
80107aa3:	83 c4 10             	add    $0x10,%esp
80107aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aac:	8b 00                	mov    (%eax),%eax
80107aae:	83 e0 01             	and    $0x1,%eax
80107ab1:	85 c0                	test   %eax,%eax
80107ab3:	75 07                	jne    80107abc <uva2ka+0x2f>
    return 0;
80107ab5:	b8 00 00 00 00       	mov    $0x0,%eax
80107aba:	eb 22                	jmp    80107ade <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	8b 00                	mov    (%eax),%eax
80107ac1:	83 e0 04             	and    $0x4,%eax
80107ac4:	85 c0                	test   %eax,%eax
80107ac6:	75 07                	jne    80107acf <uva2ka+0x42>
    return 0;
80107ac8:	b8 00 00 00 00       	mov    $0x0,%eax
80107acd:	eb 0f                	jmp    80107ade <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	8b 00                	mov    (%eax),%eax
80107ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad9:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107ade:	c9                   	leave
80107adf:	c3                   	ret

80107ae0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107ae0:	55                   	push   %ebp
80107ae1:	89 e5                	mov    %esp,%ebp
80107ae3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107ae6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107aec:	eb 7f                	jmp    80107b6d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107aee:	8b 45 0c             	mov    0xc(%ebp),%eax
80107af1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107af6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107afc:	83 ec 08             	sub    $0x8,%esp
80107aff:	50                   	push   %eax
80107b00:	ff 75 08             	push   0x8(%ebp)
80107b03:	e8 85 ff ff ff       	call   80107a8d <uva2ka>
80107b08:	83 c4 10             	add    $0x10,%esp
80107b0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107b0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107b12:	75 07                	jne    80107b1b <copyout+0x3b>
      return -1;
80107b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b19:	eb 61                	jmp    80107b7c <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107b1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b1e:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b21:	05 00 10 00 00       	add    $0x1000,%eax
80107b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b2c:	39 45 14             	cmp    %eax,0x14(%ebp)
80107b2f:	73 06                	jae    80107b37 <copyout+0x57>
      n = len;
80107b31:	8b 45 14             	mov    0x14(%ebp),%eax
80107b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b3a:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b3d:	89 c2                	mov    %eax,%edx
80107b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b42:	01 d0                	add    %edx,%eax
80107b44:	83 ec 04             	sub    $0x4,%esp
80107b47:	ff 75 f0             	push   -0x10(%ebp)
80107b4a:	ff 75 f4             	push   -0xc(%ebp)
80107b4d:	50                   	push   %eax
80107b4e:	e8 0c cf ff ff       	call   80104a5f <memmove>
80107b53:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b59:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b5f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b65:	05 00 10 00 00       	add    $0x1000,%eax
80107b6a:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107b6d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107b71:	0f 85 77 ff ff ff    	jne    80107aee <copyout+0xe>
  }
  return 0;
80107b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b7c:	c9                   	leave
80107b7d:	c3                   	ret

80107b7e <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107b7e:	55                   	push   %ebp
80107b7f:	89 e5                	mov    %esp,%ebp
80107b81:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107b84:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107b8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107b8e:	8b 40 08             	mov    0x8(%eax),%eax
80107b91:	05 00 00 00 80       	add    $0x80000000,%eax
80107b96:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107b99:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba3:	8b 40 24             	mov    0x24(%eax),%eax
80107ba6:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107bab:	c7 05 40 6e 19 80 00 	movl   $0x0,0x80196e40
80107bb2:	00 00 00 

  while(i<madt->len){
80107bb5:	e9 bd 00 00 00       	jmp    80107c77 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80107bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107bbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107bc0:	01 d0                	add    %edx,%eax
80107bc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bc8:	0f b6 00             	movzbl (%eax),%eax
80107bcb:	0f b6 c0             	movzbl %al,%eax
80107bce:	83 f8 05             	cmp    $0x5,%eax
80107bd1:	0f 87 a0 00 00 00    	ja     80107c77 <mpinit_uefi+0xf9>
80107bd7:	8b 04 85 94 a6 10 80 	mov    -0x7fef596c(,%eax,4),%eax
80107bde:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107be6:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107beb:	83 f8 03             	cmp    $0x3,%eax
80107bee:	7f 28                	jg     80107c18 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107bf0:	8b 15 40 6e 19 80    	mov    0x80196e40,%edx
80107bf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107bf9:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107bfd:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107c03:	81 c2 80 6b 19 80    	add    $0x80196b80,%edx
80107c09:	88 02                	mov    %al,(%edx)
          ncpu++;
80107c0b:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107c10:	83 c0 01             	add    $0x1,%eax
80107c13:	a3 40 6e 19 80       	mov    %eax,0x80196e40
        }
        i += lapic_entry->record_len;
80107c18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c1b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c1f:	0f b6 c0             	movzbl %al,%eax
80107c22:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c25:	eb 50                	jmp    80107c77 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c30:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c34:	a2 44 6e 19 80       	mov    %al,0x80196e44
        i += ioapic->record_len;
80107c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c3c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c40:	0f b6 c0             	movzbl %al,%eax
80107c43:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c46:	eb 2f                	jmp    80107c77 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c51:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c55:	0f b6 c0             	movzbl %al,%eax
80107c58:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c5b:	eb 1a                	jmp    80107c77 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107c63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c66:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c6a:	0f b6 c0             	movzbl %al,%eax
80107c6d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c70:	eb 05                	jmp    80107c77 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80107c72:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107c76:	90                   	nop
  while(i<madt->len){
80107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7a:	8b 40 04             	mov    0x4(%eax),%eax
80107c7d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107c80:	0f 82 34 ff ff ff    	jb     80107bba <mpinit_uefi+0x3c>
    }
  }

}
80107c86:	90                   	nop
80107c87:	90                   	nop
80107c88:	c9                   	leave
80107c89:	c3                   	ret

80107c8a <inb>:
{
80107c8a:	55                   	push   %ebp
80107c8b:	89 e5                	mov    %esp,%ebp
80107c8d:	83 ec 14             	sub    $0x14,%esp
80107c90:	8b 45 08             	mov    0x8(%ebp),%eax
80107c93:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107c97:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107c9b:	89 c2                	mov    %eax,%edx
80107c9d:	ec                   	in     (%dx),%al
80107c9e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107ca1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107ca5:	c9                   	leave
80107ca6:	c3                   	ret

80107ca7 <outb>:
{
80107ca7:	55                   	push   %ebp
80107ca8:	89 e5                	mov    %esp,%ebp
80107caa:	83 ec 08             	sub    $0x8,%esp
80107cad:	8b 55 08             	mov    0x8(%ebp),%edx
80107cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107cb7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107cbe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cc2:	ee                   	out    %al,(%dx)
}
80107cc3:	90                   	nop
80107cc4:	c9                   	leave
80107cc5:	c3                   	ret

80107cc6 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107cc6:	55                   	push   %ebp
80107cc7:	89 e5                	mov    %esp,%ebp
80107cc9:	83 ec 28             	sub    $0x28,%esp
80107ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80107ccf:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107cd2:	6a 00                	push   $0x0
80107cd4:	68 fa 03 00 00       	push   $0x3fa
80107cd9:	e8 c9 ff ff ff       	call   80107ca7 <outb>
80107cde:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107ce1:	68 80 00 00 00       	push   $0x80
80107ce6:	68 fb 03 00 00       	push   $0x3fb
80107ceb:	e8 b7 ff ff ff       	call   80107ca7 <outb>
80107cf0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107cf3:	6a 0c                	push   $0xc
80107cf5:	68 f8 03 00 00       	push   $0x3f8
80107cfa:	e8 a8 ff ff ff       	call   80107ca7 <outb>
80107cff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107d02:	6a 00                	push   $0x0
80107d04:	68 f9 03 00 00       	push   $0x3f9
80107d09:	e8 99 ff ff ff       	call   80107ca7 <outb>
80107d0e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d11:	6a 03                	push   $0x3
80107d13:	68 fb 03 00 00       	push   $0x3fb
80107d18:	e8 8a ff ff ff       	call   80107ca7 <outb>
80107d1d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d20:	6a 00                	push   $0x0
80107d22:	68 fc 03 00 00       	push   $0x3fc
80107d27:	e8 7b ff ff ff       	call   80107ca7 <outb>
80107d2c:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d36:	eb 11                	jmp    80107d49 <uart_debug+0x83>
80107d38:	83 ec 0c             	sub    $0xc,%esp
80107d3b:	6a 0a                	push   $0xa
80107d3d:	e8 f7 ad ff ff       	call   80102b39 <microdelay>
80107d42:	83 c4 10             	add    $0x10,%esp
80107d45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d49:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d4d:	7f 1a                	jg     80107d69 <uart_debug+0xa3>
80107d4f:	83 ec 0c             	sub    $0xc,%esp
80107d52:	68 fd 03 00 00       	push   $0x3fd
80107d57:	e8 2e ff ff ff       	call   80107c8a <inb>
80107d5c:	83 c4 10             	add    $0x10,%esp
80107d5f:	0f b6 c0             	movzbl %al,%eax
80107d62:	83 e0 20             	and    $0x20,%eax
80107d65:	85 c0                	test   %eax,%eax
80107d67:	74 cf                	je     80107d38 <uart_debug+0x72>
  outb(COM1+0, p);
80107d69:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107d6d:	0f b6 c0             	movzbl %al,%eax
80107d70:	83 ec 08             	sub    $0x8,%esp
80107d73:	50                   	push   %eax
80107d74:	68 f8 03 00 00       	push   $0x3f8
80107d79:	e8 29 ff ff ff       	call   80107ca7 <outb>
80107d7e:	83 c4 10             	add    $0x10,%esp
}
80107d81:	90                   	nop
80107d82:	c9                   	leave
80107d83:	c3                   	ret

80107d84 <uart_debugs>:

void uart_debugs(char *p){
80107d84:	55                   	push   %ebp
80107d85:	89 e5                	mov    %esp,%ebp
80107d87:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107d8a:	eb 1b                	jmp    80107da7 <uart_debugs+0x23>
    uart_debug(*p++);
80107d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8f:	8d 50 01             	lea    0x1(%eax),%edx
80107d92:	89 55 08             	mov    %edx,0x8(%ebp)
80107d95:	0f b6 00             	movzbl (%eax),%eax
80107d98:	0f be c0             	movsbl %al,%eax
80107d9b:	83 ec 0c             	sub    $0xc,%esp
80107d9e:	50                   	push   %eax
80107d9f:	e8 22 ff ff ff       	call   80107cc6 <uart_debug>
80107da4:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107da7:	8b 45 08             	mov    0x8(%ebp),%eax
80107daa:	0f b6 00             	movzbl (%eax),%eax
80107dad:	84 c0                	test   %al,%al
80107daf:	75 db                	jne    80107d8c <uart_debugs+0x8>
  }
}
80107db1:	90                   	nop
80107db2:	90                   	nop
80107db3:	c9                   	leave
80107db4:	c3                   	ret

80107db5 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107db5:	55                   	push   %ebp
80107db6:	89 e5                	mov    %esp,%ebp
80107db8:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107dbb:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dc5:	8b 50 14             	mov    0x14(%eax),%edx
80107dc8:	8b 40 10             	mov    0x10(%eax),%eax
80107dcb:	a3 48 6e 19 80       	mov    %eax,0x80196e48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dd3:	8b 50 1c             	mov    0x1c(%eax),%edx
80107dd6:	8b 40 18             	mov    0x18(%eax),%eax
80107dd9:	a3 50 6e 19 80       	mov    %eax,0x80196e50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107dde:	a1 50 6e 19 80       	mov    0x80196e50,%eax
80107de3:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107de8:	29 c2                	sub    %eax,%edx
80107dea:	89 15 4c 6e 19 80    	mov    %edx,0x80196e4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107df3:	8b 50 24             	mov    0x24(%eax),%edx
80107df6:	8b 40 20             	mov    0x20(%eax),%eax
80107df9:	a3 54 6e 19 80       	mov    %eax,0x80196e54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e01:	8b 50 2c             	mov    0x2c(%eax),%edx
80107e04:	8b 40 28             	mov    0x28(%eax),%eax
80107e07:	a3 58 6e 19 80       	mov    %eax,0x80196e58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e0f:	8b 50 34             	mov    0x34(%eax),%edx
80107e12:	8b 40 30             	mov    0x30(%eax),%eax
80107e15:	a3 5c 6e 19 80       	mov    %eax,0x80196e5c
}
80107e1a:	90                   	nop
80107e1b:	c9                   	leave
80107e1c:	c3                   	ret

80107e1d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e1d:	55                   	push   %ebp
80107e1e:	89 e5                	mov    %esp,%ebp
80107e20:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e23:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107e29:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2c:	0f af d0             	imul   %eax,%edx
80107e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107e32:	01 d0                	add    %edx,%eax
80107e34:	c1 e0 02             	shl    $0x2,%eax
80107e37:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e3a:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
80107e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e43:	01 d0                	add    %edx,%eax
80107e45:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e48:	8b 45 10             	mov    0x10(%ebp),%eax
80107e4b:	0f b6 10             	movzbl (%eax),%edx
80107e4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e51:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e53:	8b 45 10             	mov    0x10(%ebp),%eax
80107e56:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e5d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107e60:	8b 45 10             	mov    0x10(%ebp),%eax
80107e63:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107e67:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e6a:	88 50 02             	mov    %dl,0x2(%eax)
}
80107e6d:	90                   	nop
80107e6e:	c9                   	leave
80107e6f:	c3                   	ret

80107e70 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107e70:	55                   	push   %ebp
80107e71:	89 e5                	mov    %esp,%ebp
80107e73:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107e76:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7f:	0f af c2             	imul   %edx,%eax
80107e82:	c1 e0 02             	shl    $0x2,%eax
80107e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107e88:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	29 c2                	sub    %eax,%edx
80107e93:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	01 c8                	add    %ecx,%eax
80107e9e:	89 c1                	mov    %eax,%ecx
80107ea0:	a1 4c 6e 19 80       	mov    0x80196e4c,%eax
80107ea5:	83 ec 04             	sub    $0x4,%esp
80107ea8:	52                   	push   %edx
80107ea9:	51                   	push   %ecx
80107eaa:	50                   	push   %eax
80107eab:	e8 af cb ff ff       	call   80104a5f <memmove>
80107eb0:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107ebc:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107ec2:	01 d1                	add    %edx,%ecx
80107ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ec7:	29 d1                	sub    %edx,%ecx
80107ec9:	89 ca                	mov    %ecx,%edx
80107ecb:	83 ec 04             	sub    $0x4,%esp
80107ece:	50                   	push   %eax
80107ecf:	6a 00                	push   $0x0
80107ed1:	52                   	push   %edx
80107ed2:	e8 c9 ca ff ff       	call   801049a0 <memset>
80107ed7:	83 c4 10             	add    $0x10,%esp
}
80107eda:	90                   	nop
80107edb:	c9                   	leave
80107edc:	c3                   	ret

80107edd <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107edd:	55                   	push   %ebp
80107ede:	89 e5                	mov    %esp,%ebp
80107ee0:	53                   	push   %ebx
80107ee1:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107ee4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107eeb:	e9 b1 00 00 00       	jmp    80107fa1 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107ef0:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107ef7:	e9 97 00 00 00       	jmp    80107f93 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107efc:	8b 45 10             	mov    0x10(%ebp),%eax
80107eff:	83 e8 20             	sub    $0x20,%eax
80107f02:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	01 d0                	add    %edx,%eax
80107f0a:	0f b7 84 00 c0 a6 10 	movzwl -0x7fef5940(%eax,%eax,1),%eax
80107f11:	80 
80107f12:	0f b7 d0             	movzwl %ax,%edx
80107f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f18:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f1d:	89 c1                	mov    %eax,%ecx
80107f1f:	d3 e3                	shl    %cl,%ebx
80107f21:	89 d8                	mov    %ebx,%eax
80107f23:	21 d0                	and    %edx,%eax
80107f25:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f2b:	ba 01 00 00 00       	mov    $0x1,%edx
80107f30:	89 c1                	mov    %eax,%ecx
80107f32:	d3 e2                	shl    %cl,%edx
80107f34:	89 d0                	mov    %edx,%eax
80107f36:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f39:	75 2b                	jne    80107f66 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f41:	01 c2                	add    %eax,%edx
80107f43:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f48:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f4b:	89 c1                	mov    %eax,%ecx
80107f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f50:	01 c8                	add    %ecx,%eax
80107f52:	83 ec 04             	sub    $0x4,%esp
80107f55:	68 e0 f4 10 80       	push   $0x8010f4e0
80107f5a:	52                   	push   %edx
80107f5b:	50                   	push   %eax
80107f5c:	e8 bc fe ff ff       	call   80107e1d <graphic_draw_pixel>
80107f61:	83 c4 10             	add    $0x10,%esp
80107f64:	eb 29                	jmp    80107f8f <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107f66:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	01 c2                	add    %eax,%edx
80107f6e:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f73:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f76:	89 c1                	mov    %eax,%ecx
80107f78:	8b 45 08             	mov    0x8(%ebp),%eax
80107f7b:	01 c8                	add    %ecx,%eax
80107f7d:	83 ec 04             	sub    $0x4,%esp
80107f80:	68 60 6e 19 80       	push   $0x80196e60
80107f85:	52                   	push   %edx
80107f86:	50                   	push   %eax
80107f87:	e8 91 fe ff ff       	call   80107e1d <graphic_draw_pixel>
80107f8c:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107f8f:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107f93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f97:	0f 89 5f ff ff ff    	jns    80107efc <font_render+0x1f>
  for(int i=0;i<30;i++){
80107f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fa1:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107fa5:	0f 8e 45 ff ff ff    	jle    80107ef0 <font_render+0x13>
      }
    }
  }
}
80107fab:	90                   	nop
80107fac:	90                   	nop
80107fad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fb0:	c9                   	leave
80107fb1:	c3                   	ret

80107fb2 <font_render_string>:

void font_render_string(char *string,int row){
80107fb2:	55                   	push   %ebp
80107fb3:	89 e5                	mov    %esp,%ebp
80107fb5:	53                   	push   %ebx
80107fb6:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80107fb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80107fc0:	eb 33                	jmp    80107ff5 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80107fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc8:	01 d0                	add    %edx,%eax
80107fca:	0f b6 00             	movzbl (%eax),%eax
80107fcd:	0f be d8             	movsbl %al,%ebx
80107fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd3:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80107fd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fd9:	89 d0                	mov    %edx,%eax
80107fdb:	c1 e0 04             	shl    $0x4,%eax
80107fde:	29 d0                	sub    %edx,%eax
80107fe0:	83 c0 02             	add    $0x2,%eax
80107fe3:	83 ec 04             	sub    $0x4,%esp
80107fe6:	53                   	push   %ebx
80107fe7:	51                   	push   %ecx
80107fe8:	50                   	push   %eax
80107fe9:	e8 ef fe ff ff       	call   80107edd <font_render>
80107fee:	83 c4 10             	add    $0x10,%esp
    i++;
80107ff1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80107ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffb:	01 d0                	add    %edx,%eax
80107ffd:	0f b6 00             	movzbl (%eax),%eax
80108000:	84 c0                	test   %al,%al
80108002:	74 06                	je     8010800a <font_render_string+0x58>
80108004:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108008:	7e b8                	jle    80107fc2 <font_render_string+0x10>
  }
}
8010800a:	90                   	nop
8010800b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010800e:	c9                   	leave
8010800f:	c3                   	ret

80108010 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108010:	55                   	push   %ebp
80108011:	89 e5                	mov    %esp,%ebp
80108013:	53                   	push   %ebx
80108014:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108017:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010801e:	eb 6b                	jmp    8010808b <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108020:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108027:	eb 58                	jmp    80108081 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108029:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108030:	eb 45                	jmp    80108077 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108032:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108035:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	83 ec 0c             	sub    $0xc,%esp
8010803e:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108041:	53                   	push   %ebx
80108042:	6a 00                	push   $0x0
80108044:	51                   	push   %ecx
80108045:	52                   	push   %edx
80108046:	50                   	push   %eax
80108047:	e8 b0 00 00 00       	call   801080fc <pci_access_config>
8010804c:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010804f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108052:	0f b7 c0             	movzwl %ax,%eax
80108055:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010805a:	74 17                	je     80108073 <pci_init+0x63>
        pci_init_device(i,j,k);
8010805c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010805f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108065:	83 ec 04             	sub    $0x4,%esp
80108068:	51                   	push   %ecx
80108069:	52                   	push   %edx
8010806a:	50                   	push   %eax
8010806b:	e8 37 01 00 00       	call   801081a7 <pci_init_device>
80108070:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108073:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108077:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010807b:	7e b5                	jle    80108032 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010807d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108081:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108085:	7e a2                	jle    80108029 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108087:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010808b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108092:	7e 8c                	jle    80108020 <pci_init+0x10>
      }
      }
    }
  }
}
80108094:	90                   	nop
80108095:	90                   	nop
80108096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108099:	c9                   	leave
8010809a:	c3                   	ret

8010809b <pci_write_config>:

void pci_write_config(uint config){
8010809b:	55                   	push   %ebp
8010809c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010809e:	8b 45 08             	mov    0x8(%ebp),%eax
801080a1:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801080a6:	89 c0                	mov    %eax,%eax
801080a8:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080a9:	90                   	nop
801080aa:	5d                   	pop    %ebp
801080ab:	c3                   	ret

801080ac <pci_write_data>:

void pci_write_data(uint config){
801080ac:	55                   	push   %ebp
801080ad:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801080af:	8b 45 08             	mov    0x8(%ebp),%eax
801080b2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080b7:	89 c0                	mov    %eax,%eax
801080b9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080ba:	90                   	nop
801080bb:	5d                   	pop    %ebp
801080bc:	c3                   	ret

801080bd <pci_read_config>:
uint pci_read_config(){
801080bd:	55                   	push   %ebp
801080be:	89 e5                	mov    %esp,%ebp
801080c0:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801080c3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080c8:	ed                   	in     (%dx),%eax
801080c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801080cc:	83 ec 0c             	sub    $0xc,%esp
801080cf:	68 c8 00 00 00       	push   $0xc8
801080d4:	e8 60 aa ff ff       	call   80102b39 <microdelay>
801080d9:	83 c4 10             	add    $0x10,%esp
  return data;
801080dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801080df:	c9                   	leave
801080e0:	c3                   	ret

801080e1 <pci_test>:


void pci_test(){
801080e1:	55                   	push   %ebp
801080e2:	89 e5                	mov    %esp,%ebp
801080e4:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801080e7:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801080ee:	ff 75 fc             	push   -0x4(%ebp)
801080f1:	e8 a5 ff ff ff       	call   8010809b <pci_write_config>
801080f6:	83 c4 04             	add    $0x4,%esp
}
801080f9:	90                   	nop
801080fa:	c9                   	leave
801080fb:	c3                   	ret

801080fc <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801080fc:	55                   	push   %ebp
801080fd:	89 e5                	mov    %esp,%ebp
801080ff:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108102:	8b 45 08             	mov    0x8(%ebp),%eax
80108105:	c1 e0 10             	shl    $0x10,%eax
80108108:	25 00 00 ff 00       	and    $0xff0000,%eax
8010810d:	89 c2                	mov    %eax,%edx
8010810f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108112:	c1 e0 0b             	shl    $0xb,%eax
80108115:	0f b7 c0             	movzwl %ax,%eax
80108118:	09 c2                	or     %eax,%edx
8010811a:	8b 45 10             	mov    0x10(%ebp),%eax
8010811d:	c1 e0 08             	shl    $0x8,%eax
80108120:	25 00 07 00 00       	and    $0x700,%eax
80108125:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108127:	8b 45 14             	mov    0x14(%ebp),%eax
8010812a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010812f:	09 d0                	or     %edx,%eax
80108131:	0d 00 00 00 80       	or     $0x80000000,%eax
80108136:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108139:	ff 75 f4             	push   -0xc(%ebp)
8010813c:	e8 5a ff ff ff       	call   8010809b <pci_write_config>
80108141:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108144:	e8 74 ff ff ff       	call   801080bd <pci_read_config>
80108149:	8b 55 18             	mov    0x18(%ebp),%edx
8010814c:	89 02                	mov    %eax,(%edx)
}
8010814e:	90                   	nop
8010814f:	c9                   	leave
80108150:	c3                   	ret

80108151 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108151:	55                   	push   %ebp
80108152:	89 e5                	mov    %esp,%ebp
80108154:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108157:	8b 45 08             	mov    0x8(%ebp),%eax
8010815a:	c1 e0 10             	shl    $0x10,%eax
8010815d:	25 00 00 ff 00       	and    $0xff0000,%eax
80108162:	89 c2                	mov    %eax,%edx
80108164:	8b 45 0c             	mov    0xc(%ebp),%eax
80108167:	c1 e0 0b             	shl    $0xb,%eax
8010816a:	0f b7 c0             	movzwl %ax,%eax
8010816d:	09 c2                	or     %eax,%edx
8010816f:	8b 45 10             	mov    0x10(%ebp),%eax
80108172:	c1 e0 08             	shl    $0x8,%eax
80108175:	25 00 07 00 00       	and    $0x700,%eax
8010817a:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010817c:	8b 45 14             	mov    0x14(%ebp),%eax
8010817f:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108184:	09 d0                	or     %edx,%eax
80108186:	0d 00 00 00 80       	or     $0x80000000,%eax
8010818b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010818e:	ff 75 fc             	push   -0x4(%ebp)
80108191:	e8 05 ff ff ff       	call   8010809b <pci_write_config>
80108196:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108199:	ff 75 18             	push   0x18(%ebp)
8010819c:	e8 0b ff ff ff       	call   801080ac <pci_write_data>
801081a1:	83 c4 04             	add    $0x4,%esp
}
801081a4:	90                   	nop
801081a5:	c9                   	leave
801081a6:	c3                   	ret

801081a7 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801081a7:	55                   	push   %ebp
801081a8:	89 e5                	mov    %esp,%ebp
801081aa:	53                   	push   %ebx
801081ab:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801081ae:	8b 45 08             	mov    0x8(%ebp),%eax
801081b1:	a2 64 6e 19 80       	mov    %al,0x80196e64
  dev.device_num = device_num;
801081b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b9:	a2 65 6e 19 80       	mov    %al,0x80196e65
  dev.function_num = function_num;
801081be:	8b 45 10             	mov    0x10(%ebp),%eax
801081c1:	a2 66 6e 19 80       	mov    %al,0x80196e66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801081c6:	ff 75 10             	push   0x10(%ebp)
801081c9:	ff 75 0c             	push   0xc(%ebp)
801081cc:	ff 75 08             	push   0x8(%ebp)
801081cf:	68 04 bd 10 80       	push   $0x8010bd04
801081d4:	e8 1b 82 ff ff       	call   801003f4 <cprintf>
801081d9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081e2:	50                   	push   %eax
801081e3:	6a 00                	push   $0x0
801081e5:	ff 75 10             	push   0x10(%ebp)
801081e8:	ff 75 0c             	push   0xc(%ebp)
801081eb:	ff 75 08             	push   0x8(%ebp)
801081ee:	e8 09 ff ff ff       	call   801080fc <pci_access_config>
801081f3:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801081f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f9:	c1 e8 10             	shr    $0x10,%eax
801081fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801081ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108202:	25 ff ff 00 00       	and    $0xffff,%eax
80108207:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010820a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820d:	a3 68 6e 19 80       	mov    %eax,0x80196e68
  dev.vendor_id = vendor_id;
80108212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108215:	a3 6c 6e 19 80       	mov    %eax,0x80196e6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010821a:	83 ec 04             	sub    $0x4,%esp
8010821d:	ff 75 f0             	push   -0x10(%ebp)
80108220:	ff 75 f4             	push   -0xc(%ebp)
80108223:	68 38 bd 10 80       	push   $0x8010bd38
80108228:	e8 c7 81 ff ff       	call   801003f4 <cprintf>
8010822d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108230:	83 ec 0c             	sub    $0xc,%esp
80108233:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108236:	50                   	push   %eax
80108237:	6a 08                	push   $0x8
80108239:	ff 75 10             	push   0x10(%ebp)
8010823c:	ff 75 0c             	push   0xc(%ebp)
8010823f:	ff 75 08             	push   0x8(%ebp)
80108242:	e8 b5 fe ff ff       	call   801080fc <pci_access_config>
80108247:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010824a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824d:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108253:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108256:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108259:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010825c:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010825f:	0f b6 c0             	movzbl %al,%eax
80108262:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108265:	c1 eb 18             	shr    $0x18,%ebx
80108268:	83 ec 0c             	sub    $0xc,%esp
8010826b:	51                   	push   %ecx
8010826c:	52                   	push   %edx
8010826d:	50                   	push   %eax
8010826e:	53                   	push   %ebx
8010826f:	68 5c bd 10 80       	push   $0x8010bd5c
80108274:	e8 7b 81 ff ff       	call   801003f4 <cprintf>
80108279:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010827c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827f:	c1 e8 18             	shr    $0x18,%eax
80108282:	a2 70 6e 19 80       	mov    %al,0x80196e70
  dev.sub_class = (data>>16)&0xFF;
80108287:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010828a:	c1 e8 10             	shr    $0x10,%eax
8010828d:	a2 71 6e 19 80       	mov    %al,0x80196e71
  dev.interface = (data>>8)&0xFF;
80108292:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108295:	c1 e8 08             	shr    $0x8,%eax
80108298:	a2 72 6e 19 80       	mov    %al,0x80196e72
  dev.revision_id = data&0xFF;
8010829d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a0:	a2 73 6e 19 80       	mov    %al,0x80196e73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801082a5:	83 ec 0c             	sub    $0xc,%esp
801082a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082ab:	50                   	push   %eax
801082ac:	6a 10                	push   $0x10
801082ae:	ff 75 10             	push   0x10(%ebp)
801082b1:	ff 75 0c             	push   0xc(%ebp)
801082b4:	ff 75 08             	push   0x8(%ebp)
801082b7:	e8 40 fe ff ff       	call   801080fc <pci_access_config>
801082bc:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801082bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082c2:	a3 74 6e 19 80       	mov    %eax,0x80196e74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801082c7:	83 ec 0c             	sub    $0xc,%esp
801082ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082cd:	50                   	push   %eax
801082ce:	6a 14                	push   $0x14
801082d0:	ff 75 10             	push   0x10(%ebp)
801082d3:	ff 75 0c             	push   0xc(%ebp)
801082d6:	ff 75 08             	push   0x8(%ebp)
801082d9:	e8 1e fe ff ff       	call   801080fc <pci_access_config>
801082de:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801082e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e4:	a3 78 6e 19 80       	mov    %eax,0x80196e78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801082e9:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801082f0:	75 5a                	jne    8010834c <pci_init_device+0x1a5>
801082f2:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801082f9:	75 51                	jne    8010834c <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801082fb:	83 ec 0c             	sub    $0xc,%esp
801082fe:	68 a1 bd 10 80       	push   $0x8010bda1
80108303:	e8 ec 80 ff ff       	call   801003f4 <cprintf>
80108308:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010830b:	83 ec 0c             	sub    $0xc,%esp
8010830e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108311:	50                   	push   %eax
80108312:	68 f0 00 00 00       	push   $0xf0
80108317:	ff 75 10             	push   0x10(%ebp)
8010831a:	ff 75 0c             	push   0xc(%ebp)
8010831d:	ff 75 08             	push   0x8(%ebp)
80108320:	e8 d7 fd ff ff       	call   801080fc <pci_access_config>
80108325:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010832b:	83 ec 08             	sub    $0x8,%esp
8010832e:	50                   	push   %eax
8010832f:	68 bb bd 10 80       	push   $0x8010bdbb
80108334:	e8 bb 80 ff ff       	call   801003f4 <cprintf>
80108339:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010833c:	83 ec 0c             	sub    $0xc,%esp
8010833f:	68 64 6e 19 80       	push   $0x80196e64
80108344:	e8 09 00 00 00       	call   80108352 <i8254_init>
80108349:	83 c4 10             	add    $0x10,%esp
  }
}
8010834c:	90                   	nop
8010834d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108350:	c9                   	leave
80108351:	c3                   	ret

80108352 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108352:	55                   	push   %ebp
80108353:	89 e5                	mov    %esp,%ebp
80108355:	53                   	push   %ebx
80108356:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108359:	8b 45 08             	mov    0x8(%ebp),%eax
8010835c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108360:	0f b6 c8             	movzbl %al,%ecx
80108363:	8b 45 08             	mov    0x8(%ebp),%eax
80108366:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010836a:	0f b6 d0             	movzbl %al,%edx
8010836d:	8b 45 08             	mov    0x8(%ebp),%eax
80108370:	0f b6 00             	movzbl (%eax),%eax
80108373:	0f b6 c0             	movzbl %al,%eax
80108376:	83 ec 0c             	sub    $0xc,%esp
80108379:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010837c:	53                   	push   %ebx
8010837d:	6a 04                	push   $0x4
8010837f:	51                   	push   %ecx
80108380:	52                   	push   %edx
80108381:	50                   	push   %eax
80108382:	e8 75 fd ff ff       	call   801080fc <pci_access_config>
80108387:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010838a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838d:	83 c8 04             	or     $0x4,%eax
80108390:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108393:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108396:	8b 45 08             	mov    0x8(%ebp),%eax
80108399:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010839d:	0f b6 c8             	movzbl %al,%ecx
801083a0:	8b 45 08             	mov    0x8(%ebp),%eax
801083a3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083a7:	0f b6 d0             	movzbl %al,%edx
801083aa:	8b 45 08             	mov    0x8(%ebp),%eax
801083ad:	0f b6 00             	movzbl (%eax),%eax
801083b0:	0f b6 c0             	movzbl %al,%eax
801083b3:	83 ec 0c             	sub    $0xc,%esp
801083b6:	53                   	push   %ebx
801083b7:	6a 04                	push   $0x4
801083b9:	51                   	push   %ecx
801083ba:	52                   	push   %edx
801083bb:	50                   	push   %eax
801083bc:	e8 90 fd ff ff       	call   80108151 <pci_write_config_register>
801083c1:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801083c4:	8b 45 08             	mov    0x8(%ebp),%eax
801083c7:	8b 40 10             	mov    0x10(%eax),%eax
801083ca:	05 00 00 00 40       	add    $0x40000000,%eax
801083cf:	a3 7c 6e 19 80       	mov    %eax,0x80196e7c
  uint *ctrl = (uint *)base_addr;
801083d4:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801083d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801083dc:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801083e1:	05 d8 00 00 00       	add    $0xd8,%eax
801083e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801083e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ec:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801083f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f5:	8b 00                	mov    (%eax),%eax
801083f7:	0d 00 00 00 04       	or     $0x4000000,%eax
801083fc:	89 c2                	mov    %eax,%edx
801083fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108401:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108403:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108406:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010840c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840f:	8b 00                	mov    (%eax),%eax
80108411:	83 c8 40             	or     $0x40,%eax
80108414:	89 c2                	mov    %eax,%edx
80108416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108419:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	8b 10                	mov    (%eax),%edx
80108420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108423:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108425:	83 ec 0c             	sub    $0xc,%esp
80108428:	68 d0 bd 10 80       	push   $0x8010bdd0
8010842d:	e8 c2 7f ff ff       	call   801003f4 <cprintf>
80108432:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108435:	e8 6e a3 ff ff       	call   801027a8 <kalloc>
8010843a:	a3 88 6e 19 80       	mov    %eax,0x80196e88
  *intr_addr = 0;
8010843f:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108444:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010844a:	a1 88 6e 19 80       	mov    0x80196e88,%eax
8010844f:	83 ec 08             	sub    $0x8,%esp
80108452:	50                   	push   %eax
80108453:	68 f2 bd 10 80       	push   $0x8010bdf2
80108458:	e8 97 7f ff ff       	call   801003f4 <cprintf>
8010845d:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108460:	e8 50 00 00 00       	call   801084b5 <i8254_init_recv>
  i8254_init_send();
80108465:	e8 69 03 00 00       	call   801087d3 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010846a:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108471:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108474:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010847b:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010847e:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108485:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108488:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010848f:	0f b6 c0             	movzbl %al,%eax
80108492:	83 ec 0c             	sub    $0xc,%esp
80108495:	53                   	push   %ebx
80108496:	51                   	push   %ecx
80108497:	52                   	push   %edx
80108498:	50                   	push   %eax
80108499:	68 00 be 10 80       	push   $0x8010be00
8010849e:	e8 51 7f ff ff       	call   801003f4 <cprintf>
801084a3:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801084a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801084af:	90                   	nop
801084b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084b3:	c9                   	leave
801084b4:	c3                   	ret

801084b5 <i8254_init_recv>:

void i8254_init_recv(){
801084b5:	55                   	push   %ebp
801084b6:	89 e5                	mov    %esp,%ebp
801084b8:	57                   	push   %edi
801084b9:	56                   	push   %esi
801084ba:	53                   	push   %ebx
801084bb:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801084be:	83 ec 0c             	sub    $0xc,%esp
801084c1:	6a 00                	push   $0x0
801084c3:	e8 e8 04 00 00       	call   801089b0 <i8254_read_eeprom>
801084c8:	83 c4 10             	add    $0x10,%esp
801084cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801084ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084d1:	a2 80 6e 19 80       	mov    %al,0x80196e80
  mac_addr[1] = data_l>>8;
801084d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084d9:	c1 e8 08             	shr    $0x8,%eax
801084dc:	a2 81 6e 19 80       	mov    %al,0x80196e81
  uint data_m = i8254_read_eeprom(0x1);
801084e1:	83 ec 0c             	sub    $0xc,%esp
801084e4:	6a 01                	push   $0x1
801084e6:	e8 c5 04 00 00       	call   801089b0 <i8254_read_eeprom>
801084eb:	83 c4 10             	add    $0x10,%esp
801084ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801084f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084f4:	a2 82 6e 19 80       	mov    %al,0x80196e82
  mac_addr[3] = data_m>>8;
801084f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084fc:	c1 e8 08             	shr    $0x8,%eax
801084ff:	a2 83 6e 19 80       	mov    %al,0x80196e83
  uint data_h = i8254_read_eeprom(0x2);
80108504:	83 ec 0c             	sub    $0xc,%esp
80108507:	6a 02                	push   $0x2
80108509:	e8 a2 04 00 00       	call   801089b0 <i8254_read_eeprom>
8010850e:	83 c4 10             	add    $0x10,%esp
80108511:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108514:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108517:	a2 84 6e 19 80       	mov    %al,0x80196e84
  mac_addr[5] = data_h>>8;
8010851c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010851f:	c1 e8 08             	shr    $0x8,%eax
80108522:	a2 85 6e 19 80       	mov    %al,0x80196e85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108527:	0f b6 05 85 6e 19 80 	movzbl 0x80196e85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010852e:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108531:	0f b6 05 84 6e 19 80 	movzbl 0x80196e84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108538:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010853b:	0f b6 05 83 6e 19 80 	movzbl 0x80196e83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108542:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108545:	0f b6 05 82 6e 19 80 	movzbl 0x80196e82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010854c:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010854f:	0f b6 05 81 6e 19 80 	movzbl 0x80196e81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108556:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108559:	0f b6 05 80 6e 19 80 	movzbl 0x80196e80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108560:	0f b6 c0             	movzbl %al,%eax
80108563:	83 ec 04             	sub    $0x4,%esp
80108566:	57                   	push   %edi
80108567:	56                   	push   %esi
80108568:	53                   	push   %ebx
80108569:	51                   	push   %ecx
8010856a:	52                   	push   %edx
8010856b:	50                   	push   %eax
8010856c:	68 18 be 10 80       	push   $0x8010be18
80108571:	e8 7e 7e ff ff       	call   801003f4 <cprintf>
80108576:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108579:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010857e:	05 00 54 00 00       	add    $0x5400,%eax
80108583:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108586:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010858b:	05 04 54 00 00       	add    $0x5404,%eax
80108590:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108593:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108596:	c1 e0 10             	shl    $0x10,%eax
80108599:	0b 45 d8             	or     -0x28(%ebp),%eax
8010859c:	89 c2                	mov    %eax,%edx
8010859e:	8b 45 cc             	mov    -0x34(%ebp),%eax
801085a1:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801085a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085a6:	0d 00 00 00 80       	or     $0x80000000,%eax
801085ab:	89 c2                	mov    %eax,%edx
801085ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
801085b0:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801085b2:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801085b7:	05 00 52 00 00       	add    $0x5200,%eax
801085bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801085bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801085c6:	eb 19                	jmp    801085e1 <i8254_init_recv+0x12c>
    mta[i] = 0;
801085c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085d2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801085d5:	01 d0                	add    %edx,%eax
801085d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801085dd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801085e1:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801085e5:	7e e1                	jle    801085c8 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801085e7:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801085ec:	05 d0 00 00 00       	add    $0xd0,%eax
801085f1:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085f4:	8b 45 c0             	mov    -0x40(%ebp),%eax
801085f7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801085fd:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108602:	05 c8 00 00 00       	add    $0xc8,%eax
80108607:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010860a:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010860d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108613:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108618:	05 28 28 00 00       	add    $0x2828,%eax
8010861d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108620:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108623:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108629:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010862e:	05 00 01 00 00       	add    $0x100,%eax
80108633:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108636:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108639:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010863f:	e8 64 a1 ff ff       	call   801027a8 <kalloc>
80108644:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108647:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010864c:	05 00 28 00 00       	add    $0x2800,%eax
80108651:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108654:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108659:	05 04 28 00 00       	add    $0x2804,%eax
8010865e:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108661:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108666:	05 08 28 00 00       	add    $0x2808,%eax
8010866b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010866e:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108673:	05 10 28 00 00       	add    $0x2810,%eax
80108678:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010867b:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108680:	05 18 28 00 00       	add    $0x2818,%eax
80108685:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108688:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010868b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108691:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108694:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108696:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108699:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010869f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801086a2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801086a8:	8b 45 a0             	mov    -0x60(%ebp),%eax
801086ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801086b1:	8b 45 9c             	mov    -0x64(%ebp),%eax
801086b4:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801086ba:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086bd:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801086c0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801086c7:	eb 73                	jmp    8010873c <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801086c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086cc:	c1 e0 04             	shl    $0x4,%eax
801086cf:	89 c2                	mov    %eax,%edx
801086d1:	8b 45 98             	mov    -0x68(%ebp),%eax
801086d4:	01 d0                	add    %edx,%eax
801086d6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801086dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086e0:	c1 e0 04             	shl    $0x4,%eax
801086e3:	89 c2                	mov    %eax,%edx
801086e5:	8b 45 98             	mov    -0x68(%ebp),%eax
801086e8:	01 d0                	add    %edx,%eax
801086ea:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801086f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086f3:	c1 e0 04             	shl    $0x4,%eax
801086f6:	89 c2                	mov    %eax,%edx
801086f8:	8b 45 98             	mov    -0x68(%ebp),%eax
801086fb:	01 d0                	add    %edx,%eax
801086fd:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108703:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108706:	c1 e0 04             	shl    $0x4,%eax
80108709:	89 c2                	mov    %eax,%edx
8010870b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010870e:	01 d0                	add    %edx,%eax
80108710:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108714:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108717:	c1 e0 04             	shl    $0x4,%eax
8010871a:	89 c2                	mov    %eax,%edx
8010871c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010871f:	01 d0                	add    %edx,%eax
80108721:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108725:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108728:	c1 e0 04             	shl    $0x4,%eax
8010872b:	89 c2                	mov    %eax,%edx
8010872d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108730:	01 d0                	add    %edx,%eax
80108732:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108738:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010873c:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108743:	7e 84                	jle    801086c9 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108745:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010874c:	eb 57                	jmp    801087a5 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010874e:	e8 55 a0 ff ff       	call   801027a8 <kalloc>
80108753:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108756:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010875a:	75 12                	jne    8010876e <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
8010875c:	83 ec 0c             	sub    $0xc,%esp
8010875f:	68 38 be 10 80       	push   $0x8010be38
80108764:	e8 8b 7c ff ff       	call   801003f4 <cprintf>
80108769:	83 c4 10             	add    $0x10,%esp
      break;
8010876c:	eb 3d                	jmp    801087ab <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010876e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108771:	c1 e0 04             	shl    $0x4,%eax
80108774:	89 c2                	mov    %eax,%edx
80108776:	8b 45 98             	mov    -0x68(%ebp),%eax
80108779:	01 d0                	add    %edx,%eax
8010877b:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010877e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108784:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108786:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108789:	83 c0 01             	add    $0x1,%eax
8010878c:	c1 e0 04             	shl    $0x4,%eax
8010878f:	89 c2                	mov    %eax,%edx
80108791:	8b 45 98             	mov    -0x68(%ebp),%eax
80108794:	01 d0                	add    %edx,%eax
80108796:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108799:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010879f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801087a1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801087a5:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801087a9:	7e a3                	jle    8010874e <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801087ab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087ae:	8b 00                	mov    (%eax),%eax
801087b0:	83 c8 02             	or     $0x2,%eax
801087b3:	89 c2                	mov    %eax,%edx
801087b5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087b8:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801087ba:	83 ec 0c             	sub    $0xc,%esp
801087bd:	68 58 be 10 80       	push   $0x8010be58
801087c2:	e8 2d 7c ff ff       	call   801003f4 <cprintf>
801087c7:	83 c4 10             	add    $0x10,%esp
}
801087ca:	90                   	nop
801087cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801087ce:	5b                   	pop    %ebx
801087cf:	5e                   	pop    %esi
801087d0:	5f                   	pop    %edi
801087d1:	5d                   	pop    %ebp
801087d2:	c3                   	ret

801087d3 <i8254_init_send>:

void i8254_init_send(){
801087d3:	55                   	push   %ebp
801087d4:	89 e5                	mov    %esp,%ebp
801087d6:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801087d9:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801087de:	05 28 38 00 00       	add    $0x3828,%eax
801087e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801087e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e9:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801087ef:	e8 b4 9f ff ff       	call   801027a8 <kalloc>
801087f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801087f7:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801087fc:	05 00 38 00 00       	add    $0x3800,%eax
80108801:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108804:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108809:	05 04 38 00 00       	add    $0x3804,%eax
8010880e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108811:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108816:	05 08 38 00 00       	add    $0x3808,%eax
8010881b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010881e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108821:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108827:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010882a:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010882c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010882f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108835:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108838:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010883e:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108843:	05 10 38 00 00       	add    $0x3810,%eax
80108848:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010884b:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108850:	05 18 38 00 00       	add    $0x3818,%eax
80108855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108858:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010885b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108861:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108864:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010886a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010886d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108870:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108877:	e9 82 00 00 00       	jmp    801088fe <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
8010887c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887f:	c1 e0 04             	shl    $0x4,%eax
80108882:	89 c2                	mov    %eax,%edx
80108884:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108887:	01 d0                	add    %edx,%eax
80108889:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	c1 e0 04             	shl    $0x4,%eax
80108896:	89 c2                	mov    %eax,%edx
80108898:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010889b:	01 d0                	add    %edx,%eax
8010889d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a6:	c1 e0 04             	shl    $0x4,%eax
801088a9:	89 c2                	mov    %eax,%edx
801088ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088ae:	01 d0                	add    %edx,%eax
801088b0:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801088b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b7:	c1 e0 04             	shl    $0x4,%eax
801088ba:	89 c2                	mov    %eax,%edx
801088bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088bf:	01 d0                	add    %edx,%eax
801088c1:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801088c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c8:	c1 e0 04             	shl    $0x4,%eax
801088cb:	89 c2                	mov    %eax,%edx
801088cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088d0:	01 d0                	add    %edx,%eax
801088d2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801088d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d9:	c1 e0 04             	shl    $0x4,%eax
801088dc:	89 c2                	mov    %eax,%edx
801088de:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088e1:	01 d0                	add    %edx,%eax
801088e3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801088e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ea:	c1 e0 04             	shl    $0x4,%eax
801088ed:	89 c2                	mov    %eax,%edx
801088ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088f2:	01 d0                	add    %edx,%eax
801088f4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801088fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088fe:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108905:	0f 8e 71 ff ff ff    	jle    8010887c <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010890b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108912:	eb 57                	jmp    8010896b <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108914:	e8 8f 9e ff ff       	call   801027a8 <kalloc>
80108919:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
8010891c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108920:	75 12                	jne    80108934 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108922:	83 ec 0c             	sub    $0xc,%esp
80108925:	68 38 be 10 80       	push   $0x8010be38
8010892a:	e8 c5 7a ff ff       	call   801003f4 <cprintf>
8010892f:	83 c4 10             	add    $0x10,%esp
      break;
80108932:	eb 3d                	jmp    80108971 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108937:	c1 e0 04             	shl    $0x4,%eax
8010893a:	89 c2                	mov    %eax,%edx
8010893c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010893f:	01 d0                	add    %edx,%eax
80108941:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108944:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010894a:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010894c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010894f:	83 c0 01             	add    $0x1,%eax
80108952:	c1 e0 04             	shl    $0x4,%eax
80108955:	89 c2                	mov    %eax,%edx
80108957:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010895a:	01 d0                	add    %edx,%eax
8010895c:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010895f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108965:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108967:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010896b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010896f:	7e a3                	jle    80108914 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108971:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108976:	05 00 04 00 00       	add    $0x400,%eax
8010897b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010897e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108981:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108987:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010898c:	05 10 04 00 00       	add    $0x410,%eax
80108991:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108994:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108997:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010899d:	83 ec 0c             	sub    $0xc,%esp
801089a0:	68 78 be 10 80       	push   $0x8010be78
801089a5:	e8 4a 7a ff ff       	call   801003f4 <cprintf>
801089aa:	83 c4 10             	add    $0x10,%esp

}
801089ad:	90                   	nop
801089ae:	c9                   	leave
801089af:	c3                   	ret

801089b0 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801089b0:	55                   	push   %ebp
801089b1:	89 e5                	mov    %esp,%ebp
801089b3:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801089b6:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801089bb:	83 c0 14             	add    $0x14,%eax
801089be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801089c1:	8b 45 08             	mov    0x8(%ebp),%eax
801089c4:	c1 e0 08             	shl    $0x8,%eax
801089c7:	0f b7 c0             	movzwl %ax,%eax
801089ca:	83 c8 01             	or     $0x1,%eax
801089cd:	89 c2                	mov    %eax,%edx
801089cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d2:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801089d4:	83 ec 0c             	sub    $0xc,%esp
801089d7:	68 98 be 10 80       	push   $0x8010be98
801089dc:	e8 13 7a ff ff       	call   801003f4 <cprintf>
801089e1:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801089e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e7:	8b 00                	mov    (%eax),%eax
801089e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801089ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ef:	83 e0 10             	and    $0x10,%eax
801089f2:	85 c0                	test   %eax,%eax
801089f4:	75 02                	jne    801089f8 <i8254_read_eeprom+0x48>
  while(1){
801089f6:	eb dc                	jmp    801089d4 <i8254_read_eeprom+0x24>
      break;
801089f8:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801089f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fc:	8b 00                	mov    (%eax),%eax
801089fe:	c1 e8 10             	shr    $0x10,%eax
}
80108a01:	c9                   	leave
80108a02:	c3                   	ret

80108a03 <i8254_recv>:
void i8254_recv(){
80108a03:	55                   	push   %ebp
80108a04:	89 e5                	mov    %esp,%ebp
80108a06:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a09:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a0e:	05 10 28 00 00       	add    $0x2810,%eax
80108a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a16:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a1b:	05 18 28 00 00       	add    $0x2818,%eax
80108a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a23:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a28:	05 00 28 00 00       	add    $0x2800,%eax
80108a2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a33:	8b 00                	mov    (%eax),%eax
80108a35:	05 00 00 00 80       	add    $0x80000000,%eax
80108a3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a40:	8b 10                	mov    (%eax),%edx
80108a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a45:	8b 00                	mov    (%eax),%eax
80108a47:	29 c2                	sub    %eax,%edx
80108a49:	89 d0                	mov    %edx,%eax
80108a4b:	25 ff 00 00 00       	and    $0xff,%eax
80108a50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a57:	7e 37                	jle    80108a90 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5c:	8b 00                	mov    (%eax),%eax
80108a5e:	c1 e0 04             	shl    $0x4,%eax
80108a61:	89 c2                	mov    %eax,%edx
80108a63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a66:	01 d0                	add    %edx,%eax
80108a68:	8b 00                	mov    (%eax),%eax
80108a6a:	05 00 00 00 80       	add    $0x80000000,%eax
80108a6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a75:	8b 00                	mov    (%eax),%eax
80108a77:	83 c0 01             	add    $0x1,%eax
80108a7a:	0f b6 d0             	movzbl %al,%edx
80108a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a80:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108a82:	83 ec 0c             	sub    $0xc,%esp
80108a85:	ff 75 e0             	push   -0x20(%ebp)
80108a88:	e8 13 09 00 00       	call   801093a0 <eth_proc>
80108a8d:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a93:	8b 10                	mov    (%eax),%edx
80108a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a98:	8b 00                	mov    (%eax),%eax
80108a9a:	39 c2                	cmp    %eax,%edx
80108a9c:	75 9f                	jne    80108a3d <i8254_recv+0x3a>
      (*rdt)--;
80108a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa1:	8b 00                	mov    (%eax),%eax
80108aa3:	8d 50 ff             	lea    -0x1(%eax),%edx
80108aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa9:	89 10                	mov    %edx,(%eax)
  while(1){
80108aab:	eb 90                	jmp    80108a3d <i8254_recv+0x3a>

80108aad <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108aad:	55                   	push   %ebp
80108aae:	89 e5                	mov    %esp,%ebp
80108ab0:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ab3:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108ab8:	05 10 38 00 00       	add    $0x3810,%eax
80108abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ac0:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108ac5:	05 18 38 00 00       	add    $0x3818,%eax
80108aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108acd:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108ad2:	05 00 38 00 00       	add    $0x3800,%eax
80108ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108add:	8b 00                	mov    (%eax),%eax
80108adf:	05 00 00 00 80       	add    $0x80000000,%eax
80108ae4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aea:	8b 10                	mov    (%eax),%edx
80108aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aef:	8b 00                	mov    (%eax),%eax
80108af1:	29 c2                	sub    %eax,%edx
80108af3:	0f b6 c2             	movzbl %dl,%eax
80108af6:	ba 00 01 00 00       	mov    $0x100,%edx
80108afb:	29 c2                	sub    %eax,%edx
80108afd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b03:	8b 00                	mov    (%eax),%eax
80108b05:	25 ff 00 00 00       	and    $0xff,%eax
80108b0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108b0d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b11:	0f 8e a8 00 00 00    	jle    80108bbf <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108b17:	8b 45 08             	mov    0x8(%ebp),%eax
80108b1a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b1d:	89 d1                	mov    %edx,%ecx
80108b1f:	c1 e1 04             	shl    $0x4,%ecx
80108b22:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b25:	01 ca                	add    %ecx,%edx
80108b27:	8b 12                	mov    (%edx),%edx
80108b29:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b2f:	83 ec 04             	sub    $0x4,%esp
80108b32:	ff 75 0c             	push   0xc(%ebp)
80108b35:	50                   	push   %eax
80108b36:	52                   	push   %edx
80108b37:	e8 23 bf ff ff       	call   80104a5f <memmove>
80108b3c:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108b3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b42:	c1 e0 04             	shl    $0x4,%eax
80108b45:	89 c2                	mov    %eax,%edx
80108b47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b4a:	01 d0                	add    %edx,%eax
80108b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b4f:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b56:	c1 e0 04             	shl    $0x4,%eax
80108b59:	89 c2                	mov    %eax,%edx
80108b5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b5e:	01 d0                	add    %edx,%eax
80108b60:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108b64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b67:	c1 e0 04             	shl    $0x4,%eax
80108b6a:	89 c2                	mov    %eax,%edx
80108b6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b6f:	01 d0                	add    %edx,%eax
80108b71:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108b75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b78:	c1 e0 04             	shl    $0x4,%eax
80108b7b:	89 c2                	mov    %eax,%edx
80108b7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b80:	01 d0                	add    %edx,%eax
80108b82:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108b86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b89:	c1 e0 04             	shl    $0x4,%eax
80108b8c:	89 c2                	mov    %eax,%edx
80108b8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b91:	01 d0                	add    %edx,%eax
80108b93:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108b99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b9c:	c1 e0 04             	shl    $0x4,%eax
80108b9f:	89 c2                	mov    %eax,%edx
80108ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba4:	01 d0                	add    %edx,%eax
80108ba6:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bad:	8b 00                	mov    (%eax),%eax
80108baf:	83 c0 01             	add    $0x1,%eax
80108bb2:	0f b6 d0             	movzbl %al,%edx
80108bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb8:	89 10                	mov    %edx,(%eax)
    return len;
80108bba:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bbd:	eb 05                	jmp    80108bc4 <i8254_send+0x117>
  }else{
    return -1;
80108bbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108bc4:	c9                   	leave
80108bc5:	c3                   	ret

80108bc6 <i8254_intr>:

void i8254_intr(){
80108bc6:	55                   	push   %ebp
80108bc7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108bc9:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108bce:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108bd4:	90                   	nop
80108bd5:	5d                   	pop    %ebp
80108bd6:	c3                   	ret

80108bd7 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108bd7:	55                   	push   %ebp
80108bd8:	89 e5                	mov    %esp,%ebp
80108bda:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80108be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be6:	0f b7 00             	movzwl (%eax),%eax
80108be9:	66 3d 00 01          	cmp    $0x100,%ax
80108bed:	74 0a                	je     80108bf9 <arp_proc+0x22>
80108bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bf4:	e9 4f 01 00 00       	jmp    80108d48 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfc:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108c00:	66 83 f8 08          	cmp    $0x8,%ax
80108c04:	74 0a                	je     80108c10 <arp_proc+0x39>
80108c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c0b:	e9 38 01 00 00       	jmp    80108d48 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c13:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c17:	3c 06                	cmp    $0x6,%al
80108c19:	74 0a                	je     80108c25 <arp_proc+0x4e>
80108c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c20:	e9 23 01 00 00       	jmp    80108d48 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c28:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c2c:	3c 04                	cmp    $0x4,%al
80108c2e:	74 0a                	je     80108c3a <arp_proc+0x63>
80108c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c35:	e9 0e 01 00 00       	jmp    80108d48 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3d:	83 c0 18             	add    $0x18,%eax
80108c40:	83 ec 04             	sub    $0x4,%esp
80108c43:	6a 04                	push   $0x4
80108c45:	50                   	push   %eax
80108c46:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c4b:	e8 b7 bd ff ff       	call   80104a07 <memcmp>
80108c50:	83 c4 10             	add    $0x10,%esp
80108c53:	85 c0                	test   %eax,%eax
80108c55:	74 27                	je     80108c7e <arp_proc+0xa7>
80108c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c5a:	83 c0 0e             	add    $0xe,%eax
80108c5d:	83 ec 04             	sub    $0x4,%esp
80108c60:	6a 04                	push   $0x4
80108c62:	50                   	push   %eax
80108c63:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c68:	e8 9a bd ff ff       	call   80104a07 <memcmp>
80108c6d:	83 c4 10             	add    $0x10,%esp
80108c70:	85 c0                	test   %eax,%eax
80108c72:	74 0a                	je     80108c7e <arp_proc+0xa7>
80108c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c79:	e9 ca 00 00 00       	jmp    80108d48 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c81:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108c85:	66 3d 00 01          	cmp    $0x100,%ax
80108c89:	75 69                	jne    80108cf4 <arp_proc+0x11d>
80108c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8e:	83 c0 18             	add    $0x18,%eax
80108c91:	83 ec 04             	sub    $0x4,%esp
80108c94:	6a 04                	push   $0x4
80108c96:	50                   	push   %eax
80108c97:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c9c:	e8 66 bd ff ff       	call   80104a07 <memcmp>
80108ca1:	83 c4 10             	add    $0x10,%esp
80108ca4:	85 c0                	test   %eax,%eax
80108ca6:	75 4c                	jne    80108cf4 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108ca8:	e8 fb 9a ff ff       	call   801027a8 <kalloc>
80108cad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108cb0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108cb7:	83 ec 04             	sub    $0x4,%esp
80108cba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cbd:	50                   	push   %eax
80108cbe:	ff 75 f0             	push   -0x10(%ebp)
80108cc1:	ff 75 f4             	push   -0xc(%ebp)
80108cc4:	e8 1f 04 00 00       	call   801090e8 <arp_reply_pkt_create>
80108cc9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ccf:	83 ec 08             	sub    $0x8,%esp
80108cd2:	50                   	push   %eax
80108cd3:	ff 75 f0             	push   -0x10(%ebp)
80108cd6:	e8 d2 fd ff ff       	call   80108aad <i8254_send>
80108cdb:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce1:	83 ec 0c             	sub    $0xc,%esp
80108ce4:	50                   	push   %eax
80108ce5:	e8 24 9a ff ff       	call   8010270e <kfree>
80108cea:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108ced:	b8 02 00 00 00       	mov    $0x2,%eax
80108cf2:	eb 54                	jmp    80108d48 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108cfb:	66 3d 00 02          	cmp    $0x200,%ax
80108cff:	75 42                	jne    80108d43 <arp_proc+0x16c>
80108d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d04:	83 c0 18             	add    $0x18,%eax
80108d07:	83 ec 04             	sub    $0x4,%esp
80108d0a:	6a 04                	push   $0x4
80108d0c:	50                   	push   %eax
80108d0d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d12:	e8 f0 bc ff ff       	call   80104a07 <memcmp>
80108d17:	83 c4 10             	add    $0x10,%esp
80108d1a:	85 c0                	test   %eax,%eax
80108d1c:	75 25                	jne    80108d43 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d1e:	83 ec 0c             	sub    $0xc,%esp
80108d21:	68 9c be 10 80       	push   $0x8010be9c
80108d26:	e8 c9 76 ff ff       	call   801003f4 <cprintf>
80108d2b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d2e:	83 ec 0c             	sub    $0xc,%esp
80108d31:	ff 75 f4             	push   -0xc(%ebp)
80108d34:	e8 af 01 00 00       	call   80108ee8 <arp_table_update>
80108d39:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d3c:	b8 01 00 00 00       	mov    $0x1,%eax
80108d41:	eb 05                	jmp    80108d48 <arp_proc+0x171>
  }else{
    return -1;
80108d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d48:	c9                   	leave
80108d49:	c3                   	ret

80108d4a <arp_scan>:

void arp_scan(){
80108d4a:	55                   	push   %ebp
80108d4b:	89 e5                	mov    %esp,%ebp
80108d4d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d57:	eb 6f                	jmp    80108dc8 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108d59:	e8 4a 9a ff ff       	call   801027a8 <kalloc>
80108d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108d61:	83 ec 04             	sub    $0x4,%esp
80108d64:	ff 75 f4             	push   -0xc(%ebp)
80108d67:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108d6a:	50                   	push   %eax
80108d6b:	ff 75 ec             	push   -0x14(%ebp)
80108d6e:	e8 62 00 00 00       	call   80108dd5 <arp_broadcast>
80108d73:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108d76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d79:	83 ec 08             	sub    $0x8,%esp
80108d7c:	50                   	push   %eax
80108d7d:	ff 75 ec             	push   -0x14(%ebp)
80108d80:	e8 28 fd ff ff       	call   80108aad <i8254_send>
80108d85:	83 c4 10             	add    $0x10,%esp
80108d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d8b:	eb 22                	jmp    80108daf <arp_scan+0x65>
      microdelay(1);
80108d8d:	83 ec 0c             	sub    $0xc,%esp
80108d90:	6a 01                	push   $0x1
80108d92:	e8 a2 9d ff ff       	call   80102b39 <microdelay>
80108d97:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108d9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9d:	83 ec 08             	sub    $0x8,%esp
80108da0:	50                   	push   %eax
80108da1:	ff 75 ec             	push   -0x14(%ebp)
80108da4:	e8 04 fd ff ff       	call   80108aad <i8254_send>
80108da9:	83 c4 10             	add    $0x10,%esp
80108dac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108daf:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108db3:	74 d8                	je     80108d8d <arp_scan+0x43>
    }
    kfree((char *)send);
80108db5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db8:	83 ec 0c             	sub    $0xc,%esp
80108dbb:	50                   	push   %eax
80108dbc:	e8 4d 99 ff ff       	call   8010270e <kfree>
80108dc1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108dc4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dc8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108dcf:	7e 88                	jle    80108d59 <arp_scan+0xf>
  }
}
80108dd1:	90                   	nop
80108dd2:	90                   	nop
80108dd3:	c9                   	leave
80108dd4:	c3                   	ret

80108dd5 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108dd5:	55                   	push   %ebp
80108dd6:	89 e5                	mov    %esp,%ebp
80108dd8:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108ddb:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108ddf:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108de3:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108de7:	8b 45 10             	mov    0x10(%ebp),%eax
80108dea:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108ded:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108df4:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108dfa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e01:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108e07:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e0a:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108e10:	8b 45 08             	mov    0x8(%ebp),%eax
80108e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e16:	8b 45 08             	mov    0x8(%ebp),%eax
80108e19:	83 c0 0e             	add    $0xe,%eax
80108e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e22:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e29:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e30:	83 ec 04             	sub    $0x4,%esp
80108e33:	6a 06                	push   $0x6
80108e35:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e38:	52                   	push   %edx
80108e39:	50                   	push   %eax
80108e3a:	e8 20 bc ff ff       	call   80104a5f <memmove>
80108e3f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e45:	83 c0 06             	add    $0x6,%eax
80108e48:	83 ec 04             	sub    $0x4,%esp
80108e4b:	6a 06                	push   $0x6
80108e4d:	68 80 6e 19 80       	push   $0x80196e80
80108e52:	50                   	push   %eax
80108e53:	e8 07 bc ff ff       	call   80104a5f <memmove>
80108e58:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e66:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e76:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7d:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e86:	8d 50 12             	lea    0x12(%eax),%edx
80108e89:	83 ec 04             	sub    $0x4,%esp
80108e8c:	6a 06                	push   $0x6
80108e8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108e91:	50                   	push   %eax
80108e92:	52                   	push   %edx
80108e93:	e8 c7 bb ff ff       	call   80104a5f <memmove>
80108e98:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e9e:	8d 50 18             	lea    0x18(%eax),%edx
80108ea1:	83 ec 04             	sub    $0x4,%esp
80108ea4:	6a 04                	push   $0x4
80108ea6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ea9:	50                   	push   %eax
80108eaa:	52                   	push   %edx
80108eab:	e8 af bb ff ff       	call   80104a5f <memmove>
80108eb0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb6:	83 c0 08             	add    $0x8,%eax
80108eb9:	83 ec 04             	sub    $0x4,%esp
80108ebc:	6a 06                	push   $0x6
80108ebe:	68 80 6e 19 80       	push   $0x80196e80
80108ec3:	50                   	push   %eax
80108ec4:	e8 96 bb ff ff       	call   80104a5f <memmove>
80108ec9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecf:	83 c0 0e             	add    $0xe,%eax
80108ed2:	83 ec 04             	sub    $0x4,%esp
80108ed5:	6a 04                	push   $0x4
80108ed7:	68 e4 f4 10 80       	push   $0x8010f4e4
80108edc:	50                   	push   %eax
80108edd:	e8 7d bb ff ff       	call   80104a5f <memmove>
80108ee2:	83 c4 10             	add    $0x10,%esp
}
80108ee5:	90                   	nop
80108ee6:	c9                   	leave
80108ee7:	c3                   	ret

80108ee8 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108ee8:	55                   	push   %ebp
80108ee9:	89 e5                	mov    %esp,%ebp
80108eeb:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108eee:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef1:	83 c0 0e             	add    $0xe,%eax
80108ef4:	83 ec 0c             	sub    $0xc,%esp
80108ef7:	50                   	push   %eax
80108ef8:	e8 bc 00 00 00       	call   80108fb9 <arp_table_search>
80108efd:	83 c4 10             	add    $0x10,%esp
80108f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f07:	78 2d                	js     80108f36 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f09:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0c:	8d 48 08             	lea    0x8(%eax),%ecx
80108f0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f12:	89 d0                	mov    %edx,%eax
80108f14:	c1 e0 02             	shl    $0x2,%eax
80108f17:	01 d0                	add    %edx,%eax
80108f19:	01 c0                	add    %eax,%eax
80108f1b:	01 d0                	add    %edx,%eax
80108f1d:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108f22:	83 c0 04             	add    $0x4,%eax
80108f25:	83 ec 04             	sub    $0x4,%esp
80108f28:	6a 06                	push   $0x6
80108f2a:	51                   	push   %ecx
80108f2b:	50                   	push   %eax
80108f2c:	e8 2e bb ff ff       	call   80104a5f <memmove>
80108f31:	83 c4 10             	add    $0x10,%esp
80108f34:	eb 70                	jmp    80108fa6 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f3a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f40:	8d 48 08             	lea    0x8(%eax),%ecx
80108f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f46:	89 d0                	mov    %edx,%eax
80108f48:	c1 e0 02             	shl    $0x2,%eax
80108f4b:	01 d0                	add    %edx,%eax
80108f4d:	01 c0                	add    %eax,%eax
80108f4f:	01 d0                	add    %edx,%eax
80108f51:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108f56:	83 c0 04             	add    $0x4,%eax
80108f59:	83 ec 04             	sub    $0x4,%esp
80108f5c:	6a 06                	push   $0x6
80108f5e:	51                   	push   %ecx
80108f5f:	50                   	push   %eax
80108f60:	e8 fa ba ff ff       	call   80104a5f <memmove>
80108f65:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108f68:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6b:	8d 48 0e             	lea    0xe(%eax),%ecx
80108f6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f71:	89 d0                	mov    %edx,%eax
80108f73:	c1 e0 02             	shl    $0x2,%eax
80108f76:	01 d0                	add    %edx,%eax
80108f78:	01 c0                	add    %eax,%eax
80108f7a:	01 d0                	add    %edx,%eax
80108f7c:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108f81:	83 ec 04             	sub    $0x4,%esp
80108f84:	6a 04                	push   $0x4
80108f86:	51                   	push   %ecx
80108f87:	50                   	push   %eax
80108f88:	e8 d2 ba ff ff       	call   80104a5f <memmove>
80108f8d:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108f90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f93:	89 d0                	mov    %edx,%eax
80108f95:	c1 e0 02             	shl    $0x2,%eax
80108f98:	01 d0                	add    %edx,%eax
80108f9a:	01 c0                	add    %eax,%eax
80108f9c:	01 d0                	add    %edx,%eax
80108f9e:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
80108fa3:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108fa6:	83 ec 0c             	sub    $0xc,%esp
80108fa9:	68 a0 6e 19 80       	push   $0x80196ea0
80108fae:	e8 83 00 00 00       	call   80109036 <print_arp_table>
80108fb3:	83 c4 10             	add    $0x10,%esp
}
80108fb6:	90                   	nop
80108fb7:	c9                   	leave
80108fb8:	c3                   	ret

80108fb9 <arp_table_search>:

int arp_table_search(uchar *ip){
80108fb9:	55                   	push   %ebp
80108fba:	89 e5                	mov    %esp,%ebp
80108fbc:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80108fbf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108fc6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fcd:	eb 59                	jmp    80109028 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80108fcf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fd2:	89 d0                	mov    %edx,%eax
80108fd4:	c1 e0 02             	shl    $0x2,%eax
80108fd7:	01 d0                	add    %edx,%eax
80108fd9:	01 c0                	add    %eax,%eax
80108fdb:	01 d0                	add    %edx,%eax
80108fdd:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108fe2:	83 ec 04             	sub    $0x4,%esp
80108fe5:	6a 04                	push   $0x4
80108fe7:	ff 75 08             	push   0x8(%ebp)
80108fea:	50                   	push   %eax
80108feb:	e8 17 ba ff ff       	call   80104a07 <memcmp>
80108ff0:	83 c4 10             	add    $0x10,%esp
80108ff3:	85 c0                	test   %eax,%eax
80108ff5:	75 05                	jne    80108ffc <arp_table_search+0x43>
      return i;
80108ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ffa:	eb 38                	jmp    80109034 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80108ffc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fff:	89 d0                	mov    %edx,%eax
80109001:	c1 e0 02             	shl    $0x2,%eax
80109004:	01 d0                	add    %edx,%eax
80109006:	01 c0                	add    %eax,%eax
80109008:	01 d0                	add    %edx,%eax
8010900a:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
8010900f:	0f b6 00             	movzbl (%eax),%eax
80109012:	84 c0                	test   %al,%al
80109014:	75 0e                	jne    80109024 <arp_table_search+0x6b>
80109016:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010901a:	75 08                	jne    80109024 <arp_table_search+0x6b>
      empty = -i;
8010901c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901f:	f7 d8                	neg    %eax
80109021:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109024:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109028:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010902c:	7e a1                	jle    80108fcf <arp_table_search+0x16>
    }
  }
  return empty-1;
8010902e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109031:	83 e8 01             	sub    $0x1,%eax
}
80109034:	c9                   	leave
80109035:	c3                   	ret

80109036 <print_arp_table>:

void print_arp_table(){
80109036:	55                   	push   %ebp
80109037:	89 e5                	mov    %esp,%ebp
80109039:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010903c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109043:	e9 92 00 00 00       	jmp    801090da <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109048:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010904b:	89 d0                	mov    %edx,%eax
8010904d:	c1 e0 02             	shl    $0x2,%eax
80109050:	01 d0                	add    %edx,%eax
80109052:	01 c0                	add    %eax,%eax
80109054:	01 d0                	add    %edx,%eax
80109056:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
8010905b:	0f b6 00             	movzbl (%eax),%eax
8010905e:	84 c0                	test   %al,%al
80109060:	74 74                	je     801090d6 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109062:	83 ec 08             	sub    $0x8,%esp
80109065:	ff 75 f4             	push   -0xc(%ebp)
80109068:	68 af be 10 80       	push   $0x8010beaf
8010906d:	e8 82 73 ff ff       	call   801003f4 <cprintf>
80109072:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109075:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109078:	89 d0                	mov    %edx,%eax
8010907a:	c1 e0 02             	shl    $0x2,%eax
8010907d:	01 d0                	add    %edx,%eax
8010907f:	01 c0                	add    %eax,%eax
80109081:	01 d0                	add    %edx,%eax
80109083:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80109088:	83 ec 0c             	sub    $0xc,%esp
8010908b:	50                   	push   %eax
8010908c:	e8 54 02 00 00       	call   801092e5 <print_ipv4>
80109091:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109094:	83 ec 0c             	sub    $0xc,%esp
80109097:	68 be be 10 80       	push   $0x8010bebe
8010909c:	e8 53 73 ff ff       	call   801003f4 <cprintf>
801090a1:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801090a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090a7:	89 d0                	mov    %edx,%eax
801090a9:	c1 e0 02             	shl    $0x2,%eax
801090ac:	01 d0                	add    %edx,%eax
801090ae:	01 c0                	add    %eax,%eax
801090b0:	01 d0                	add    %edx,%eax
801090b2:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
801090b7:	83 c0 04             	add    $0x4,%eax
801090ba:	83 ec 0c             	sub    $0xc,%esp
801090bd:	50                   	push   %eax
801090be:	e8 70 02 00 00       	call   80109333 <print_mac>
801090c3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801090c6:	83 ec 0c             	sub    $0xc,%esp
801090c9:	68 c0 be 10 80       	push   $0x8010bec0
801090ce:	e8 21 73 ff ff       	call   801003f4 <cprintf>
801090d3:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801090d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090da:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801090de:	0f 8e 64 ff ff ff    	jle    80109048 <print_arp_table+0x12>
    }
  }
}
801090e4:	90                   	nop
801090e5:	90                   	nop
801090e6:	c9                   	leave
801090e7:	c3                   	ret

801090e8 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801090e8:	55                   	push   %ebp
801090e9:	89 e5                	mov    %esp,%ebp
801090eb:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090ee:	8b 45 10             	mov    0x10(%ebp),%eax
801090f1:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801090fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109100:	83 c0 0e             	add    $0xe,%eax
80109103:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109109:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010910d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109110:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109114:	8b 45 08             	mov    0x8(%ebp),%eax
80109117:	8d 50 08             	lea    0x8(%eax),%edx
8010911a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911d:	83 ec 04             	sub    $0x4,%esp
80109120:	6a 06                	push   $0x6
80109122:	52                   	push   %edx
80109123:	50                   	push   %eax
80109124:	e8 36 b9 ff ff       	call   80104a5f <memmove>
80109129:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010912c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912f:	83 c0 06             	add    $0x6,%eax
80109132:	83 ec 04             	sub    $0x4,%esp
80109135:	6a 06                	push   $0x6
80109137:	68 80 6e 19 80       	push   $0x80196e80
8010913c:	50                   	push   %eax
8010913d:	e8 1d b9 ff ff       	call   80104a5f <memmove>
80109142:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109148:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010914d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109150:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109159:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010915d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109160:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109167:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010916d:	8b 45 08             	mov    0x8(%ebp),%eax
80109170:	8d 50 08             	lea    0x8(%eax),%edx
80109173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109176:	83 c0 12             	add    $0x12,%eax
80109179:	83 ec 04             	sub    $0x4,%esp
8010917c:	6a 06                	push   $0x6
8010917e:	52                   	push   %edx
8010917f:	50                   	push   %eax
80109180:	e8 da b8 ff ff       	call   80104a5f <memmove>
80109185:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109188:	8b 45 08             	mov    0x8(%ebp),%eax
8010918b:	8d 50 0e             	lea    0xe(%eax),%edx
8010918e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109191:	83 c0 18             	add    $0x18,%eax
80109194:	83 ec 04             	sub    $0x4,%esp
80109197:	6a 04                	push   $0x4
80109199:	52                   	push   %edx
8010919a:	50                   	push   %eax
8010919b:	e8 bf b8 ff ff       	call   80104a5f <memmove>
801091a0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a6:	83 c0 08             	add    $0x8,%eax
801091a9:	83 ec 04             	sub    $0x4,%esp
801091ac:	6a 06                	push   $0x6
801091ae:	68 80 6e 19 80       	push   $0x80196e80
801091b3:	50                   	push   %eax
801091b4:	e8 a6 b8 ff ff       	call   80104a5f <memmove>
801091b9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801091bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091bf:	83 c0 0e             	add    $0xe,%eax
801091c2:	83 ec 04             	sub    $0x4,%esp
801091c5:	6a 04                	push   $0x4
801091c7:	68 e4 f4 10 80       	push   $0x8010f4e4
801091cc:	50                   	push   %eax
801091cd:	e8 8d b8 ff ff       	call   80104a5f <memmove>
801091d2:	83 c4 10             	add    $0x10,%esp
}
801091d5:	90                   	nop
801091d6:	c9                   	leave
801091d7:	c3                   	ret

801091d8 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801091d8:	55                   	push   %ebp
801091d9:	89 e5                	mov    %esp,%ebp
801091db:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801091de:	83 ec 0c             	sub    $0xc,%esp
801091e1:	68 c2 be 10 80       	push   $0x8010bec2
801091e6:	e8 09 72 ff ff       	call   801003f4 <cprintf>
801091eb:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801091ee:	8b 45 08             	mov    0x8(%ebp),%eax
801091f1:	83 c0 0e             	add    $0xe,%eax
801091f4:	83 ec 0c             	sub    $0xc,%esp
801091f7:	50                   	push   %eax
801091f8:	e8 e8 00 00 00       	call   801092e5 <print_ipv4>
801091fd:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109200:	83 ec 0c             	sub    $0xc,%esp
80109203:	68 c0 be 10 80       	push   $0x8010bec0
80109208:	e8 e7 71 ff ff       	call   801003f4 <cprintf>
8010920d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109210:	8b 45 08             	mov    0x8(%ebp),%eax
80109213:	83 c0 08             	add    $0x8,%eax
80109216:	83 ec 0c             	sub    $0xc,%esp
80109219:	50                   	push   %eax
8010921a:	e8 14 01 00 00       	call   80109333 <print_mac>
8010921f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109222:	83 ec 0c             	sub    $0xc,%esp
80109225:	68 c0 be 10 80       	push   $0x8010bec0
8010922a:	e8 c5 71 ff ff       	call   801003f4 <cprintf>
8010922f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109232:	83 ec 0c             	sub    $0xc,%esp
80109235:	68 d9 be 10 80       	push   $0x8010bed9
8010923a:	e8 b5 71 ff ff       	call   801003f4 <cprintf>
8010923f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109242:	8b 45 08             	mov    0x8(%ebp),%eax
80109245:	83 c0 18             	add    $0x18,%eax
80109248:	83 ec 0c             	sub    $0xc,%esp
8010924b:	50                   	push   %eax
8010924c:	e8 94 00 00 00       	call   801092e5 <print_ipv4>
80109251:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109254:	83 ec 0c             	sub    $0xc,%esp
80109257:	68 c0 be 10 80       	push   $0x8010bec0
8010925c:	e8 93 71 ff ff       	call   801003f4 <cprintf>
80109261:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109264:	8b 45 08             	mov    0x8(%ebp),%eax
80109267:	83 c0 12             	add    $0x12,%eax
8010926a:	83 ec 0c             	sub    $0xc,%esp
8010926d:	50                   	push   %eax
8010926e:	e8 c0 00 00 00       	call   80109333 <print_mac>
80109273:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109276:	83 ec 0c             	sub    $0xc,%esp
80109279:	68 c0 be 10 80       	push   $0x8010bec0
8010927e:	e8 71 71 ff ff       	call   801003f4 <cprintf>
80109283:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109286:	83 ec 0c             	sub    $0xc,%esp
80109289:	68 f0 be 10 80       	push   $0x8010bef0
8010928e:	e8 61 71 ff ff       	call   801003f4 <cprintf>
80109293:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109296:	8b 45 08             	mov    0x8(%ebp),%eax
80109299:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010929d:	66 3d 00 01          	cmp    $0x100,%ax
801092a1:	75 12                	jne    801092b5 <print_arp_info+0xdd>
801092a3:	83 ec 0c             	sub    $0xc,%esp
801092a6:	68 fc be 10 80       	push   $0x8010befc
801092ab:	e8 44 71 ff ff       	call   801003f4 <cprintf>
801092b0:	83 c4 10             	add    $0x10,%esp
801092b3:	eb 1d                	jmp    801092d2 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801092b5:	8b 45 08             	mov    0x8(%ebp),%eax
801092b8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092bc:	66 3d 00 02          	cmp    $0x200,%ax
801092c0:	75 10                	jne    801092d2 <print_arp_info+0xfa>
    cprintf("Reply\n");
801092c2:	83 ec 0c             	sub    $0xc,%esp
801092c5:	68 05 bf 10 80       	push   $0x8010bf05
801092ca:	e8 25 71 ff ff       	call   801003f4 <cprintf>
801092cf:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801092d2:	83 ec 0c             	sub    $0xc,%esp
801092d5:	68 c0 be 10 80       	push   $0x8010bec0
801092da:	e8 15 71 ff ff       	call   801003f4 <cprintf>
801092df:	83 c4 10             	add    $0x10,%esp
}
801092e2:	90                   	nop
801092e3:	c9                   	leave
801092e4:	c3                   	ret

801092e5 <print_ipv4>:

void print_ipv4(uchar *ip){
801092e5:	55                   	push   %ebp
801092e6:	89 e5                	mov    %esp,%ebp
801092e8:	53                   	push   %ebx
801092e9:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801092ec:	8b 45 08             	mov    0x8(%ebp),%eax
801092ef:	83 c0 03             	add    $0x3,%eax
801092f2:	0f b6 00             	movzbl (%eax),%eax
801092f5:	0f b6 d8             	movzbl %al,%ebx
801092f8:	8b 45 08             	mov    0x8(%ebp),%eax
801092fb:	83 c0 02             	add    $0x2,%eax
801092fe:	0f b6 00             	movzbl (%eax),%eax
80109301:	0f b6 c8             	movzbl %al,%ecx
80109304:	8b 45 08             	mov    0x8(%ebp),%eax
80109307:	83 c0 01             	add    $0x1,%eax
8010930a:	0f b6 00             	movzbl (%eax),%eax
8010930d:	0f b6 d0             	movzbl %al,%edx
80109310:	8b 45 08             	mov    0x8(%ebp),%eax
80109313:	0f b6 00             	movzbl (%eax),%eax
80109316:	0f b6 c0             	movzbl %al,%eax
80109319:	83 ec 0c             	sub    $0xc,%esp
8010931c:	53                   	push   %ebx
8010931d:	51                   	push   %ecx
8010931e:	52                   	push   %edx
8010931f:	50                   	push   %eax
80109320:	68 0c bf 10 80       	push   $0x8010bf0c
80109325:	e8 ca 70 ff ff       	call   801003f4 <cprintf>
8010932a:	83 c4 20             	add    $0x20,%esp
}
8010932d:	90                   	nop
8010932e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109331:	c9                   	leave
80109332:	c3                   	ret

80109333 <print_mac>:

void print_mac(uchar *mac){
80109333:	55                   	push   %ebp
80109334:	89 e5                	mov    %esp,%ebp
80109336:	57                   	push   %edi
80109337:	56                   	push   %esi
80109338:	53                   	push   %ebx
80109339:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010933c:	8b 45 08             	mov    0x8(%ebp),%eax
8010933f:	83 c0 05             	add    $0x5,%eax
80109342:	0f b6 00             	movzbl (%eax),%eax
80109345:	0f b6 f8             	movzbl %al,%edi
80109348:	8b 45 08             	mov    0x8(%ebp),%eax
8010934b:	83 c0 04             	add    $0x4,%eax
8010934e:	0f b6 00             	movzbl (%eax),%eax
80109351:	0f b6 f0             	movzbl %al,%esi
80109354:	8b 45 08             	mov    0x8(%ebp),%eax
80109357:	83 c0 03             	add    $0x3,%eax
8010935a:	0f b6 00             	movzbl (%eax),%eax
8010935d:	0f b6 d8             	movzbl %al,%ebx
80109360:	8b 45 08             	mov    0x8(%ebp),%eax
80109363:	83 c0 02             	add    $0x2,%eax
80109366:	0f b6 00             	movzbl (%eax),%eax
80109369:	0f b6 c8             	movzbl %al,%ecx
8010936c:	8b 45 08             	mov    0x8(%ebp),%eax
8010936f:	83 c0 01             	add    $0x1,%eax
80109372:	0f b6 00             	movzbl (%eax),%eax
80109375:	0f b6 d0             	movzbl %al,%edx
80109378:	8b 45 08             	mov    0x8(%ebp),%eax
8010937b:	0f b6 00             	movzbl (%eax),%eax
8010937e:	0f b6 c0             	movzbl %al,%eax
80109381:	83 ec 04             	sub    $0x4,%esp
80109384:	57                   	push   %edi
80109385:	56                   	push   %esi
80109386:	53                   	push   %ebx
80109387:	51                   	push   %ecx
80109388:	52                   	push   %edx
80109389:	50                   	push   %eax
8010938a:	68 24 bf 10 80       	push   $0x8010bf24
8010938f:	e8 60 70 ff ff       	call   801003f4 <cprintf>
80109394:	83 c4 20             	add    $0x20,%esp
}
80109397:	90                   	nop
80109398:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010939b:	5b                   	pop    %ebx
8010939c:	5e                   	pop    %esi
8010939d:	5f                   	pop    %edi
8010939e:	5d                   	pop    %ebp
8010939f:	c3                   	ret

801093a0 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801093a0:	55                   	push   %ebp
801093a1:	89 e5                	mov    %esp,%ebp
801093a3:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801093a6:	8b 45 08             	mov    0x8(%ebp),%eax
801093a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801093ac:	8b 45 08             	mov    0x8(%ebp),%eax
801093af:	83 c0 0e             	add    $0xe,%eax
801093b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801093b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093bc:	3c 08                	cmp    $0x8,%al
801093be:	75 1b                	jne    801093db <eth_proc+0x3b>
801093c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093c7:	3c 06                	cmp    $0x6,%al
801093c9:	75 10                	jne    801093db <eth_proc+0x3b>
    arp_proc(pkt_addr);
801093cb:	83 ec 0c             	sub    $0xc,%esp
801093ce:	ff 75 f0             	push   -0x10(%ebp)
801093d1:	e8 01 f8 ff ff       	call   80108bd7 <arp_proc>
801093d6:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801093d9:	eb 24                	jmp    801093ff <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801093db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093de:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093e2:	3c 08                	cmp    $0x8,%al
801093e4:	75 19                	jne    801093ff <eth_proc+0x5f>
801093e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093ed:	84 c0                	test   %al,%al
801093ef:	75 0e                	jne    801093ff <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801093f1:	83 ec 0c             	sub    $0xc,%esp
801093f4:	ff 75 08             	push   0x8(%ebp)
801093f7:	e8 8d 00 00 00       	call   80109489 <ipv4_proc>
801093fc:	83 c4 10             	add    $0x10,%esp
}
801093ff:	90                   	nop
80109400:	c9                   	leave
80109401:	c3                   	ret

80109402 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109402:	55                   	push   %ebp
80109403:	89 e5                	mov    %esp,%ebp
80109405:	83 ec 04             	sub    $0x4,%esp
80109408:	8b 45 08             	mov    0x8(%ebp),%eax
8010940b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010940f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109413:	66 c1 c0 08          	rol    $0x8,%ax
}
80109417:	c9                   	leave
80109418:	c3                   	ret

80109419 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109419:	55                   	push   %ebp
8010941a:	89 e5                	mov    %esp,%ebp
8010941c:	83 ec 04             	sub    $0x4,%esp
8010941f:	8b 45 08             	mov    0x8(%ebp),%eax
80109422:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109426:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010942a:	66 c1 c0 08          	rol    $0x8,%ax
}
8010942e:	c9                   	leave
8010942f:	c3                   	ret

80109430 <H2N_uint>:

uint H2N_uint(uint value){
80109430:	55                   	push   %ebp
80109431:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109433:	8b 45 08             	mov    0x8(%ebp),%eax
80109436:	c1 e0 18             	shl    $0x18,%eax
80109439:	25 00 00 00 0f       	and    $0xf000000,%eax
8010943e:	89 c2                	mov    %eax,%edx
80109440:	8b 45 08             	mov    0x8(%ebp),%eax
80109443:	c1 e0 08             	shl    $0x8,%eax
80109446:	25 00 f0 00 00       	and    $0xf000,%eax
8010944b:	09 c2                	or     %eax,%edx
8010944d:	8b 45 08             	mov    0x8(%ebp),%eax
80109450:	c1 e8 08             	shr    $0x8,%eax
80109453:	83 e0 0f             	and    $0xf,%eax
80109456:	01 d0                	add    %edx,%eax
}
80109458:	5d                   	pop    %ebp
80109459:	c3                   	ret

8010945a <N2H_uint>:

uint N2H_uint(uint value){
8010945a:	55                   	push   %ebp
8010945b:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010945d:	8b 45 08             	mov    0x8(%ebp),%eax
80109460:	c1 e0 18             	shl    $0x18,%eax
80109463:	89 c2                	mov    %eax,%edx
80109465:	8b 45 08             	mov    0x8(%ebp),%eax
80109468:	c1 e0 08             	shl    $0x8,%eax
8010946b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109470:	01 c2                	add    %eax,%edx
80109472:	8b 45 08             	mov    0x8(%ebp),%eax
80109475:	c1 e8 08             	shr    $0x8,%eax
80109478:	25 00 ff 00 00       	and    $0xff00,%eax
8010947d:	01 c2                	add    %eax,%edx
8010947f:	8b 45 08             	mov    0x8(%ebp),%eax
80109482:	c1 e8 18             	shr    $0x18,%eax
80109485:	01 d0                	add    %edx,%eax
}
80109487:	5d                   	pop    %ebp
80109488:	c3                   	ret

80109489 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109489:	55                   	push   %ebp
8010948a:	89 e5                	mov    %esp,%ebp
8010948c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010948f:	8b 45 08             	mov    0x8(%ebp),%eax
80109492:	83 c0 0e             	add    $0xe,%eax
80109495:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010949f:	0f b7 d0             	movzwl %ax,%edx
801094a2:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801094a7:	39 c2                	cmp    %eax,%edx
801094a9:	74 60                	je     8010950b <ipv4_proc+0x82>
801094ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ae:	83 c0 0c             	add    $0xc,%eax
801094b1:	83 ec 04             	sub    $0x4,%esp
801094b4:	6a 04                	push   $0x4
801094b6:	50                   	push   %eax
801094b7:	68 e4 f4 10 80       	push   $0x8010f4e4
801094bc:	e8 46 b5 ff ff       	call   80104a07 <memcmp>
801094c1:	83 c4 10             	add    $0x10,%esp
801094c4:	85 c0                	test   %eax,%eax
801094c6:	74 43                	je     8010950b <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801094c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094cf:	0f b7 c0             	movzwl %ax,%eax
801094d2:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094de:	3c 01                	cmp    $0x1,%al
801094e0:	75 10                	jne    801094f2 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801094e2:	83 ec 0c             	sub    $0xc,%esp
801094e5:	ff 75 08             	push   0x8(%ebp)
801094e8:	e8 a3 00 00 00       	call   80109590 <icmp_proc>
801094ed:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801094f0:	eb 19                	jmp    8010950b <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801094f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094f9:	3c 06                	cmp    $0x6,%al
801094fb:	75 0e                	jne    8010950b <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801094fd:	83 ec 0c             	sub    $0xc,%esp
80109500:	ff 75 08             	push   0x8(%ebp)
80109503:	e8 b3 03 00 00       	call   801098bb <tcp_proc>
80109508:	83 c4 10             	add    $0x10,%esp
}
8010950b:	90                   	nop
8010950c:	c9                   	leave
8010950d:	c3                   	ret

8010950e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010950e:	55                   	push   %ebp
8010950f:	89 e5                	mov    %esp,%ebp
80109511:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109514:	8b 45 08             	mov    0x8(%ebp),%eax
80109517:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010951a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010951d:	0f b6 00             	movzbl (%eax),%eax
80109520:	83 e0 0f             	and    $0xf,%eax
80109523:	01 c0                	add    %eax,%eax
80109525:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109528:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010952f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109536:	eb 48                	jmp    80109580 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109538:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010953b:	01 c0                	add    %eax,%eax
8010953d:	89 c2                	mov    %eax,%edx
8010953f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109542:	01 d0                	add    %edx,%eax
80109544:	0f b6 00             	movzbl (%eax),%eax
80109547:	0f b6 c0             	movzbl %al,%eax
8010954a:	c1 e0 08             	shl    $0x8,%eax
8010954d:	89 c2                	mov    %eax,%edx
8010954f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109552:	01 c0                	add    %eax,%eax
80109554:	8d 48 01             	lea    0x1(%eax),%ecx
80109557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955a:	01 c8                	add    %ecx,%eax
8010955c:	0f b6 00             	movzbl (%eax),%eax
8010955f:	0f b6 c0             	movzbl %al,%eax
80109562:	01 d0                	add    %edx,%eax
80109564:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109567:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010956e:	76 0c                	jbe    8010957c <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109570:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109573:	0f b7 c0             	movzwl %ax,%eax
80109576:	83 c0 01             	add    $0x1,%eax
80109579:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010957c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109580:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109584:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109587:	7c af                	jl     80109538 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109589:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010958c:	f7 d0                	not    %eax
}
8010958e:	c9                   	leave
8010958f:	c3                   	ret

80109590 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109590:	55                   	push   %ebp
80109591:	89 e5                	mov    %esp,%ebp
80109593:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109596:	8b 45 08             	mov    0x8(%ebp),%eax
80109599:	83 c0 0e             	add    $0xe,%eax
8010959c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010959f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a2:	0f b6 00             	movzbl (%eax),%eax
801095a5:	0f b6 c0             	movzbl %al,%eax
801095a8:	83 e0 0f             	and    $0xf,%eax
801095ab:	c1 e0 02             	shl    $0x2,%eax
801095ae:	89 c2                	mov    %eax,%edx
801095b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b3:	01 d0                	add    %edx,%eax
801095b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801095b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095bb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801095bf:	84 c0                	test   %al,%al
801095c1:	75 4f                	jne    80109612 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801095c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c6:	0f b6 00             	movzbl (%eax),%eax
801095c9:	3c 08                	cmp    $0x8,%al
801095cb:	75 45                	jne    80109612 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801095cd:	e8 d6 91 ff ff       	call   801027a8 <kalloc>
801095d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801095d5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801095dc:	83 ec 04             	sub    $0x4,%esp
801095df:	8d 45 e8             	lea    -0x18(%ebp),%eax
801095e2:	50                   	push   %eax
801095e3:	ff 75 ec             	push   -0x14(%ebp)
801095e6:	ff 75 08             	push   0x8(%ebp)
801095e9:	e8 78 00 00 00       	call   80109666 <icmp_reply_pkt_create>
801095ee:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801095f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095f4:	83 ec 08             	sub    $0x8,%esp
801095f7:	50                   	push   %eax
801095f8:	ff 75 ec             	push   -0x14(%ebp)
801095fb:	e8 ad f4 ff ff       	call   80108aad <i8254_send>
80109600:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109603:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109606:	83 ec 0c             	sub    $0xc,%esp
80109609:	50                   	push   %eax
8010960a:	e8 ff 90 ff ff       	call   8010270e <kfree>
8010960f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109612:	90                   	nop
80109613:	c9                   	leave
80109614:	c3                   	ret

80109615 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109615:	55                   	push   %ebp
80109616:	89 e5                	mov    %esp,%ebp
80109618:	53                   	push   %ebx
80109619:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010961c:	8b 45 08             	mov    0x8(%ebp),%eax
8010961f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109623:	0f b7 c0             	movzwl %ax,%eax
80109626:	83 ec 0c             	sub    $0xc,%esp
80109629:	50                   	push   %eax
8010962a:	e8 d3 fd ff ff       	call   80109402 <N2H_ushort>
8010962f:	83 c4 10             	add    $0x10,%esp
80109632:	0f b7 d8             	movzwl %ax,%ebx
80109635:	8b 45 08             	mov    0x8(%ebp),%eax
80109638:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010963c:	0f b7 c0             	movzwl %ax,%eax
8010963f:	83 ec 0c             	sub    $0xc,%esp
80109642:	50                   	push   %eax
80109643:	e8 ba fd ff ff       	call   80109402 <N2H_ushort>
80109648:	83 c4 10             	add    $0x10,%esp
8010964b:	0f b7 c0             	movzwl %ax,%eax
8010964e:	83 ec 04             	sub    $0x4,%esp
80109651:	53                   	push   %ebx
80109652:	50                   	push   %eax
80109653:	68 43 bf 10 80       	push   $0x8010bf43
80109658:	e8 97 6d ff ff       	call   801003f4 <cprintf>
8010965d:	83 c4 10             	add    $0x10,%esp
}
80109660:	90                   	nop
80109661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109664:	c9                   	leave
80109665:	c3                   	ret

80109666 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109666:	55                   	push   %ebp
80109667:	89 e5                	mov    %esp,%ebp
80109669:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010966c:	8b 45 08             	mov    0x8(%ebp),%eax
8010966f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109672:	8b 45 08             	mov    0x8(%ebp),%eax
80109675:	83 c0 0e             	add    $0xe,%eax
80109678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010967b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967e:	0f b6 00             	movzbl (%eax),%eax
80109681:	0f b6 c0             	movzbl %al,%eax
80109684:	83 e0 0f             	and    $0xf,%eax
80109687:	c1 e0 02             	shl    $0x2,%eax
8010968a:	89 c2                	mov    %eax,%edx
8010968c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010968f:	01 d0                	add    %edx,%eax
80109691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109694:	8b 45 0c             	mov    0xc(%ebp),%eax
80109697:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010969a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010969d:	83 c0 0e             	add    $0xe,%eax
801096a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801096a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096a6:	83 c0 14             	add    $0x14,%eax
801096a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801096ac:	8b 45 10             	mov    0x10(%ebp),%eax
801096af:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801096b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b8:	8d 50 06             	lea    0x6(%eax),%edx
801096bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096be:	83 ec 04             	sub    $0x4,%esp
801096c1:	6a 06                	push   $0x6
801096c3:	52                   	push   %edx
801096c4:	50                   	push   %eax
801096c5:	e8 95 b3 ff ff       	call   80104a5f <memmove>
801096ca:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801096cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096d0:	83 c0 06             	add    $0x6,%eax
801096d3:	83 ec 04             	sub    $0x4,%esp
801096d6:	6a 06                	push   $0x6
801096d8:	68 80 6e 19 80       	push   $0x80196e80
801096dd:	50                   	push   %eax
801096de:	e8 7c b3 ff ff       	call   80104a5f <memmove>
801096e3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801096e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096e9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801096ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096f0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801096f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096f7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801096fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096fd:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109701:	83 ec 0c             	sub    $0xc,%esp
80109704:	6a 54                	push   $0x54
80109706:	e8 0e fd ff ff       	call   80109419 <H2N_ushort>
8010970b:	83 c4 10             	add    $0x10,%esp
8010970e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109711:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109715:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
8010971c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010971f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109723:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
8010972a:	83 c0 01             	add    $0x1,%eax
8010972d:	66 a3 60 71 19 80    	mov    %ax,0x80197160
  ipv4_send->fragment = H2N_ushort(0x4000);
80109733:	83 ec 0c             	sub    $0xc,%esp
80109736:	68 00 40 00 00       	push   $0x4000
8010973b:	e8 d9 fc ff ff       	call   80109419 <H2N_ushort>
80109740:	83 c4 10             	add    $0x10,%esp
80109743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109746:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010974a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010974d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109754:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010975b:	83 c0 0c             	add    $0xc,%eax
8010975e:	83 ec 04             	sub    $0x4,%esp
80109761:	6a 04                	push   $0x4
80109763:	68 e4 f4 10 80       	push   $0x8010f4e4
80109768:	50                   	push   %eax
80109769:	e8 f1 b2 ff ff       	call   80104a5f <memmove>
8010976e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109774:	8d 50 0c             	lea    0xc(%eax),%edx
80109777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010977a:	83 c0 10             	add    $0x10,%eax
8010977d:	83 ec 04             	sub    $0x4,%esp
80109780:	6a 04                	push   $0x4
80109782:	52                   	push   %edx
80109783:	50                   	push   %eax
80109784:	e8 d6 b2 ff ff       	call   80104a5f <memmove>
80109789:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010978c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010978f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109798:	83 ec 0c             	sub    $0xc,%esp
8010979b:	50                   	push   %eax
8010979c:	e8 6d fd ff ff       	call   8010950e <ipv4_chksum>
801097a1:	83 c4 10             	add    $0x10,%esp
801097a4:	0f b7 c0             	movzwl %ax,%eax
801097a7:	83 ec 0c             	sub    $0xc,%esp
801097aa:	50                   	push   %eax
801097ab:	e8 69 fc ff ff       	call   80109419 <H2N_ushort>
801097b0:	83 c4 10             	add    $0x10,%esp
801097b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097b6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801097ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097bd:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801097c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097c3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801097c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097ca:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801097ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801097d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097d8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801097dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097df:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801097e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097e6:	8d 50 08             	lea    0x8(%eax),%edx
801097e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097ec:	83 c0 08             	add    $0x8,%eax
801097ef:	83 ec 04             	sub    $0x4,%esp
801097f2:	6a 08                	push   $0x8
801097f4:	52                   	push   %edx
801097f5:	50                   	push   %eax
801097f6:	e8 64 b2 ff ff       	call   80104a5f <memmove>
801097fb:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801097fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109801:	8d 50 10             	lea    0x10(%eax),%edx
80109804:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109807:	83 c0 10             	add    $0x10,%eax
8010980a:	83 ec 04             	sub    $0x4,%esp
8010980d:	6a 30                	push   $0x30
8010980f:	52                   	push   %edx
80109810:	50                   	push   %eax
80109811:	e8 49 b2 ff ff       	call   80104a5f <memmove>
80109816:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010981c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109822:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109825:	83 ec 0c             	sub    $0xc,%esp
80109828:	50                   	push   %eax
80109829:	e8 1c 00 00 00       	call   8010984a <icmp_chksum>
8010982e:	83 c4 10             	add    $0x10,%esp
80109831:	0f b7 c0             	movzwl %ax,%eax
80109834:	83 ec 0c             	sub    $0xc,%esp
80109837:	50                   	push   %eax
80109838:	e8 dc fb ff ff       	call   80109419 <H2N_ushort>
8010983d:	83 c4 10             	add    $0x10,%esp
80109840:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109843:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109847:	90                   	nop
80109848:	c9                   	leave
80109849:	c3                   	ret

8010984a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010984a:	55                   	push   %ebp
8010984b:	89 e5                	mov    %esp,%ebp
8010984d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109850:	8b 45 08             	mov    0x8(%ebp),%eax
80109853:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109856:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010985d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109864:	eb 48                	jmp    801098ae <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109866:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109869:	01 c0                	add    %eax,%eax
8010986b:	89 c2                	mov    %eax,%edx
8010986d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109870:	01 d0                	add    %edx,%eax
80109872:	0f b6 00             	movzbl (%eax),%eax
80109875:	0f b6 c0             	movzbl %al,%eax
80109878:	c1 e0 08             	shl    $0x8,%eax
8010987b:	89 c2                	mov    %eax,%edx
8010987d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109880:	01 c0                	add    %eax,%eax
80109882:	8d 48 01             	lea    0x1(%eax),%ecx
80109885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109888:	01 c8                	add    %ecx,%eax
8010988a:	0f b6 00             	movzbl (%eax),%eax
8010988d:	0f b6 c0             	movzbl %al,%eax
80109890:	01 d0                	add    %edx,%eax
80109892:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109895:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010989c:	76 0c                	jbe    801098aa <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010989e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098a1:	0f b7 c0             	movzwl %ax,%eax
801098a4:	83 c0 01             	add    $0x1,%eax
801098a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098aa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098ae:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801098b2:	7e b2                	jle    80109866 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801098b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098b7:	f7 d0                	not    %eax
}
801098b9:	c9                   	leave
801098ba:	c3                   	ret

801098bb <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801098bb:	55                   	push   %ebp
801098bc:	89 e5                	mov    %esp,%ebp
801098be:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801098c1:	8b 45 08             	mov    0x8(%ebp),%eax
801098c4:	83 c0 0e             	add    $0xe,%eax
801098c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cd:	0f b6 00             	movzbl (%eax),%eax
801098d0:	0f b6 c0             	movzbl %al,%eax
801098d3:	83 e0 0f             	and    $0xf,%eax
801098d6:	c1 e0 02             	shl    $0x2,%eax
801098d9:	89 c2                	mov    %eax,%edx
801098db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098de:	01 d0                	add    %edx,%eax
801098e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801098e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098e6:	83 c0 14             	add    $0x14,%eax
801098e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801098ec:	e8 b7 8e ff ff       	call   801027a8 <kalloc>
801098f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801098f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
801098fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098fe:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109902:	0f b6 c0             	movzbl %al,%eax
80109905:	83 e0 02             	and    $0x2,%eax
80109908:	85 c0                	test   %eax,%eax
8010990a:	74 3d                	je     80109949 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010990c:	83 ec 0c             	sub    $0xc,%esp
8010990f:	6a 00                	push   $0x0
80109911:	6a 12                	push   $0x12
80109913:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109916:	50                   	push   %eax
80109917:	ff 75 e8             	push   -0x18(%ebp)
8010991a:	ff 75 08             	push   0x8(%ebp)
8010991d:	e8 a2 01 00 00       	call   80109ac4 <tcp_pkt_create>
80109922:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109925:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109928:	83 ec 08             	sub    $0x8,%esp
8010992b:	50                   	push   %eax
8010992c:	ff 75 e8             	push   -0x18(%ebp)
8010992f:	e8 79 f1 ff ff       	call   80108aad <i8254_send>
80109934:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109937:	a1 64 71 19 80       	mov    0x80197164,%eax
8010993c:	83 c0 01             	add    $0x1,%eax
8010993f:	a3 64 71 19 80       	mov    %eax,0x80197164
80109944:	e9 69 01 00 00       	jmp    80109ab2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109950:	3c 18                	cmp    $0x18,%al
80109952:	0f 85 10 01 00 00    	jne    80109a68 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109958:	83 ec 04             	sub    $0x4,%esp
8010995b:	6a 03                	push   $0x3
8010995d:	68 5e bf 10 80       	push   $0x8010bf5e
80109962:	ff 75 ec             	push   -0x14(%ebp)
80109965:	e8 9d b0 ff ff       	call   80104a07 <memcmp>
8010996a:	83 c4 10             	add    $0x10,%esp
8010996d:	85 c0                	test   %eax,%eax
8010996f:	74 74                	je     801099e5 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109971:	83 ec 0c             	sub    $0xc,%esp
80109974:	68 62 bf 10 80       	push   $0x8010bf62
80109979:	e8 76 6a ff ff       	call   801003f4 <cprintf>
8010997e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109981:	83 ec 0c             	sub    $0xc,%esp
80109984:	6a 00                	push   $0x0
80109986:	6a 10                	push   $0x10
80109988:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010998b:	50                   	push   %eax
8010998c:	ff 75 e8             	push   -0x18(%ebp)
8010998f:	ff 75 08             	push   0x8(%ebp)
80109992:	e8 2d 01 00 00       	call   80109ac4 <tcp_pkt_create>
80109997:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010999a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010999d:	83 ec 08             	sub    $0x8,%esp
801099a0:	50                   	push   %eax
801099a1:	ff 75 e8             	push   -0x18(%ebp)
801099a4:	e8 04 f1 ff ff       	call   80108aad <i8254_send>
801099a9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099af:	83 c0 36             	add    $0x36,%eax
801099b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
801099b5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801099b8:	50                   	push   %eax
801099b9:	ff 75 e0             	push   -0x20(%ebp)
801099bc:	6a 00                	push   $0x0
801099be:	6a 00                	push   $0x0
801099c0:	e8 5a 04 00 00       	call   80109e1f <http_proc>
801099c5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
801099c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801099cb:	83 ec 0c             	sub    $0xc,%esp
801099ce:	50                   	push   %eax
801099cf:	6a 18                	push   $0x18
801099d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099d4:	50                   	push   %eax
801099d5:	ff 75 e8             	push   -0x18(%ebp)
801099d8:	ff 75 08             	push   0x8(%ebp)
801099db:	e8 e4 00 00 00       	call   80109ac4 <tcp_pkt_create>
801099e0:	83 c4 20             	add    $0x20,%esp
801099e3:	eb 62                	jmp    80109a47 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
801099e5:	83 ec 0c             	sub    $0xc,%esp
801099e8:	6a 00                	push   $0x0
801099ea:	6a 10                	push   $0x10
801099ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099ef:	50                   	push   %eax
801099f0:	ff 75 e8             	push   -0x18(%ebp)
801099f3:	ff 75 08             	push   0x8(%ebp)
801099f6:	e8 c9 00 00 00       	call   80109ac4 <tcp_pkt_create>
801099fb:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
801099fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a01:	83 ec 08             	sub    $0x8,%esp
80109a04:	50                   	push   %eax
80109a05:	ff 75 e8             	push   -0x18(%ebp)
80109a08:	e8 a0 f0 ff ff       	call   80108aad <i8254_send>
80109a0d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a13:	83 c0 36             	add    $0x36,%eax
80109a16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a19:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a1c:	50                   	push   %eax
80109a1d:	ff 75 e4             	push   -0x1c(%ebp)
80109a20:	6a 00                	push   $0x0
80109a22:	6a 00                	push   $0x0
80109a24:	e8 f6 03 00 00       	call   80109e1f <http_proc>
80109a29:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a2f:	83 ec 0c             	sub    $0xc,%esp
80109a32:	50                   	push   %eax
80109a33:	6a 18                	push   $0x18
80109a35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a38:	50                   	push   %eax
80109a39:	ff 75 e8             	push   -0x18(%ebp)
80109a3c:	ff 75 08             	push   0x8(%ebp)
80109a3f:	e8 80 00 00 00       	call   80109ac4 <tcp_pkt_create>
80109a44:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109a47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a4a:	83 ec 08             	sub    $0x8,%esp
80109a4d:	50                   	push   %eax
80109a4e:	ff 75 e8             	push   -0x18(%ebp)
80109a51:	e8 57 f0 ff ff       	call   80108aad <i8254_send>
80109a56:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a59:	a1 64 71 19 80       	mov    0x80197164,%eax
80109a5e:	83 c0 01             	add    $0x1,%eax
80109a61:	a3 64 71 19 80       	mov    %eax,0x80197164
80109a66:	eb 4a                	jmp    80109ab2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a6f:	3c 10                	cmp    $0x10,%al
80109a71:	75 3f                	jne    80109ab2 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109a73:	a1 68 71 19 80       	mov    0x80197168,%eax
80109a78:	83 f8 01             	cmp    $0x1,%eax
80109a7b:	75 35                	jne    80109ab2 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109a7d:	83 ec 0c             	sub    $0xc,%esp
80109a80:	6a 00                	push   $0x0
80109a82:	6a 01                	push   $0x1
80109a84:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a87:	50                   	push   %eax
80109a88:	ff 75 e8             	push   -0x18(%ebp)
80109a8b:	ff 75 08             	push   0x8(%ebp)
80109a8e:	e8 31 00 00 00       	call   80109ac4 <tcp_pkt_create>
80109a93:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109a96:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a99:	83 ec 08             	sub    $0x8,%esp
80109a9c:	50                   	push   %eax
80109a9d:	ff 75 e8             	push   -0x18(%ebp)
80109aa0:	e8 08 f0 ff ff       	call   80108aad <i8254_send>
80109aa5:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109aa8:	c7 05 68 71 19 80 00 	movl   $0x0,0x80197168
80109aaf:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ab5:	83 ec 0c             	sub    $0xc,%esp
80109ab8:	50                   	push   %eax
80109ab9:	e8 50 8c ff ff       	call   8010270e <kfree>
80109abe:	83 c4 10             	add    $0x10,%esp
}
80109ac1:	90                   	nop
80109ac2:	c9                   	leave
80109ac3:	c3                   	ret

80109ac4 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ac4:	55                   	push   %ebp
80109ac5:	89 e5                	mov    %esp,%ebp
80109ac7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109aca:	8b 45 08             	mov    0x8(%ebp),%eax
80109acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad3:	83 c0 0e             	add    $0xe,%eax
80109ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109adc:	0f b6 00             	movzbl (%eax),%eax
80109adf:	0f b6 c0             	movzbl %al,%eax
80109ae2:	83 e0 0f             	and    $0xf,%eax
80109ae5:	c1 e0 02             	shl    $0x2,%eax
80109ae8:	89 c2                	mov    %eax,%edx
80109aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aed:	01 d0                	add    %edx,%eax
80109aef:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109af2:	8b 45 0c             	mov    0xc(%ebp),%eax
80109af5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109af8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109afb:	83 c0 0e             	add    $0xe,%eax
80109afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109b01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b04:	83 c0 14             	add    $0x14,%eax
80109b07:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109b0a:	8b 45 18             	mov    0x18(%ebp),%eax
80109b0d:	8d 50 36             	lea    0x36(%eax),%edx
80109b10:	8b 45 10             	mov    0x10(%ebp),%eax
80109b13:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b18:	8d 50 06             	lea    0x6(%eax),%edx
80109b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b1e:	83 ec 04             	sub    $0x4,%esp
80109b21:	6a 06                	push   $0x6
80109b23:	52                   	push   %edx
80109b24:	50                   	push   %eax
80109b25:	e8 35 af ff ff       	call   80104a5f <memmove>
80109b2a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b30:	83 c0 06             	add    $0x6,%eax
80109b33:	83 ec 04             	sub    $0x4,%esp
80109b36:	6a 06                	push   $0x6
80109b38:	68 80 6e 19 80       	push   $0x80196e80
80109b3d:	50                   	push   %eax
80109b3e:	e8 1c af ff ff       	call   80104a5f <memmove>
80109b43:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b49:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b50:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b57:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b5d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109b61:	8b 45 18             	mov    0x18(%ebp),%eax
80109b64:	83 c0 28             	add    $0x28,%eax
80109b67:	0f b7 c0             	movzwl %ax,%eax
80109b6a:	83 ec 0c             	sub    $0xc,%esp
80109b6d:	50                   	push   %eax
80109b6e:	e8 a6 f8 ff ff       	call   80109419 <H2N_ushort>
80109b73:	83 c4 10             	add    $0x10,%esp
80109b76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b79:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b7d:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
80109b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b87:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b8b:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
80109b92:	83 c0 01             	add    $0x1,%eax
80109b95:	66 a3 60 71 19 80    	mov    %ax,0x80197160
  ipv4_send->fragment = H2N_ushort(0x0000);
80109b9b:	83 ec 0c             	sub    $0xc,%esp
80109b9e:	6a 00                	push   $0x0
80109ba0:	e8 74 f8 ff ff       	call   80109419 <H2N_ushort>
80109ba5:	83 c4 10             	add    $0x10,%esp
80109ba8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bab:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb9:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc0:	83 c0 0c             	add    $0xc,%eax
80109bc3:	83 ec 04             	sub    $0x4,%esp
80109bc6:	6a 04                	push   $0x4
80109bc8:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bcd:	50                   	push   %eax
80109bce:	e8 8c ae ff ff       	call   80104a5f <memmove>
80109bd3:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd9:	8d 50 0c             	lea    0xc(%eax),%edx
80109bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bdf:	83 c0 10             	add    $0x10,%eax
80109be2:	83 ec 04             	sub    $0x4,%esp
80109be5:	6a 04                	push   $0x4
80109be7:	52                   	push   %edx
80109be8:	50                   	push   %eax
80109be9:	e8 71 ae ff ff       	call   80104a5f <memmove>
80109bee:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109bfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfd:	83 ec 0c             	sub    $0xc,%esp
80109c00:	50                   	push   %eax
80109c01:	e8 08 f9 ff ff       	call   8010950e <ipv4_chksum>
80109c06:	83 c4 10             	add    $0x10,%esp
80109c09:	0f b7 c0             	movzwl %ax,%eax
80109c0c:	83 ec 0c             	sub    $0xc,%esp
80109c0f:	50                   	push   %eax
80109c10:	e8 04 f8 ff ff       	call   80109419 <H2N_ushort>
80109c15:	83 c4 10             	add    $0x10,%esp
80109c18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c1b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c22:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c29:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c2f:	0f b7 10             	movzwl (%eax),%edx
80109c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c35:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109c39:	a1 64 71 19 80       	mov    0x80197164,%eax
80109c3e:	83 ec 0c             	sub    $0xc,%esp
80109c41:	50                   	push   %eax
80109c42:	e8 e9 f7 ff ff       	call   80109430 <H2N_uint>
80109c47:	83 c4 10             	add    $0x10,%esp
80109c4a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c4d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c53:	8b 40 04             	mov    0x4(%eax),%eax
80109c56:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109c5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5f:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c65:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109c69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c6c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c73:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109c77:	8b 45 14             	mov    0x14(%ebp),%eax
80109c7a:	89 c2                	mov    %eax,%edx
80109c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c7f:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109c82:	83 ec 0c             	sub    $0xc,%esp
80109c85:	68 90 38 00 00       	push   $0x3890
80109c8a:	e8 8a f7 ff ff       	call   80109419 <H2N_ushort>
80109c8f:	83 c4 10             	add    $0x10,%esp
80109c92:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c95:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109c99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9c:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cae:	83 ec 0c             	sub    $0xc,%esp
80109cb1:	50                   	push   %eax
80109cb2:	e8 1f 00 00 00       	call   80109cd6 <tcp_chksum>
80109cb7:	83 c4 10             	add    $0x10,%esp
80109cba:	83 c0 08             	add    $0x8,%eax
80109cbd:	0f b7 c0             	movzwl %ax,%eax
80109cc0:	83 ec 0c             	sub    $0xc,%esp
80109cc3:	50                   	push   %eax
80109cc4:	e8 50 f7 ff ff       	call   80109419 <H2N_ushort>
80109cc9:	83 c4 10             	add    $0x10,%esp
80109ccc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ccf:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109cd3:	90                   	nop
80109cd4:	c9                   	leave
80109cd5:	c3                   	ret

80109cd6 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109cd6:	55                   	push   %ebp
80109cd7:	89 e5                	mov    %esp,%ebp
80109cd9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80109cdf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ce5:	83 c0 14             	add    $0x14,%eax
80109ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109ceb:	83 ec 04             	sub    $0x4,%esp
80109cee:	6a 04                	push   $0x4
80109cf0:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cf5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cf8:	50                   	push   %eax
80109cf9:	e8 61 ad ff ff       	call   80104a5f <memmove>
80109cfe:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d04:	83 c0 0c             	add    $0xc,%eax
80109d07:	83 ec 04             	sub    $0x4,%esp
80109d0a:	6a 04                	push   $0x4
80109d0c:	50                   	push   %eax
80109d0d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d10:	83 c0 04             	add    $0x4,%eax
80109d13:	50                   	push   %eax
80109d14:	e8 46 ad ff ff       	call   80104a5f <memmove>
80109d19:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109d1c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109d20:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d27:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d2b:	0f b7 c0             	movzwl %ax,%eax
80109d2e:	83 ec 0c             	sub    $0xc,%esp
80109d31:	50                   	push   %eax
80109d32:	e8 cb f6 ff ff       	call   80109402 <N2H_ushort>
80109d37:	83 c4 10             	add    $0x10,%esp
80109d3a:	83 e8 14             	sub    $0x14,%eax
80109d3d:	0f b7 c0             	movzwl %ax,%eax
80109d40:	83 ec 0c             	sub    $0xc,%esp
80109d43:	50                   	push   %eax
80109d44:	e8 d0 f6 ff ff       	call   80109419 <H2N_ushort>
80109d49:	83 c4 10             	add    $0x10,%esp
80109d4c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109d57:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109d5d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d64:	eb 33                	jmp    80109d99 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d69:	01 c0                	add    %eax,%eax
80109d6b:	89 c2                	mov    %eax,%edx
80109d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d70:	01 d0                	add    %edx,%eax
80109d72:	0f b6 00             	movzbl (%eax),%eax
80109d75:	0f b6 c0             	movzbl %al,%eax
80109d78:	c1 e0 08             	shl    $0x8,%eax
80109d7b:	89 c2                	mov    %eax,%edx
80109d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d80:	01 c0                	add    %eax,%eax
80109d82:	8d 48 01             	lea    0x1(%eax),%ecx
80109d85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d88:	01 c8                	add    %ecx,%eax
80109d8a:	0f b6 00             	movzbl (%eax),%eax
80109d8d:	0f b6 c0             	movzbl %al,%eax
80109d90:	01 d0                	add    %edx,%eax
80109d92:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109d95:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d99:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109d9d:	7e c7                	jle    80109d66 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109da2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109da5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109dac:	eb 33                	jmp    80109de1 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109db1:	01 c0                	add    %eax,%eax
80109db3:	89 c2                	mov    %eax,%edx
80109db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db8:	01 d0                	add    %edx,%eax
80109dba:	0f b6 00             	movzbl (%eax),%eax
80109dbd:	0f b6 c0             	movzbl %al,%eax
80109dc0:	c1 e0 08             	shl    $0x8,%eax
80109dc3:	89 c2                	mov    %eax,%edx
80109dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dc8:	01 c0                	add    %eax,%eax
80109dca:	8d 48 01             	lea    0x1(%eax),%ecx
80109dcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd0:	01 c8                	add    %ecx,%eax
80109dd2:	0f b6 00             	movzbl (%eax),%eax
80109dd5:	0f b6 c0             	movzbl %al,%eax
80109dd8:	01 d0                	add    %edx,%eax
80109dda:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ddd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109de1:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109de5:	0f b7 c0             	movzwl %ax,%eax
80109de8:	83 ec 0c             	sub    $0xc,%esp
80109deb:	50                   	push   %eax
80109dec:	e8 11 f6 ff ff       	call   80109402 <N2H_ushort>
80109df1:	83 c4 10             	add    $0x10,%esp
80109df4:	66 d1 e8             	shr    $1,%ax
80109df7:	0f b7 c0             	movzwl %ax,%eax
80109dfa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109dfd:	7c af                	jl     80109dae <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e02:	c1 e8 10             	shr    $0x10,%eax
80109e05:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0b:	f7 d0                	not    %eax
}
80109e0d:	c9                   	leave
80109e0e:	c3                   	ret

80109e0f <tcp_fin>:

void tcp_fin(){
80109e0f:	55                   	push   %ebp
80109e10:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109e12:	c7 05 68 71 19 80 01 	movl   $0x1,0x80197168
80109e19:	00 00 00 
}
80109e1c:	90                   	nop
80109e1d:	5d                   	pop    %ebp
80109e1e:	c3                   	ret

80109e1f <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e1f:	55                   	push   %ebp
80109e20:	89 e5                	mov    %esp,%ebp
80109e22:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e25:	8b 45 10             	mov    0x10(%ebp),%eax
80109e28:	83 ec 04             	sub    $0x4,%esp
80109e2b:	6a 00                	push   $0x0
80109e2d:	68 6b bf 10 80       	push   $0x8010bf6b
80109e32:	50                   	push   %eax
80109e33:	e8 65 00 00 00       	call   80109e9d <http_strcpy>
80109e38:	83 c4 10             	add    $0x10,%esp
80109e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109e3e:	8b 45 10             	mov    0x10(%ebp),%eax
80109e41:	83 ec 04             	sub    $0x4,%esp
80109e44:	ff 75 f4             	push   -0xc(%ebp)
80109e47:	68 7e bf 10 80       	push   $0x8010bf7e
80109e4c:	50                   	push   %eax
80109e4d:	e8 4b 00 00 00       	call   80109e9d <http_strcpy>
80109e52:	83 c4 10             	add    $0x10,%esp
80109e55:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109e58:	8b 45 10             	mov    0x10(%ebp),%eax
80109e5b:	83 ec 04             	sub    $0x4,%esp
80109e5e:	ff 75 f4             	push   -0xc(%ebp)
80109e61:	68 99 bf 10 80       	push   $0x8010bf99
80109e66:	50                   	push   %eax
80109e67:	e8 31 00 00 00       	call   80109e9d <http_strcpy>
80109e6c:	83 c4 10             	add    $0x10,%esp
80109e6f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e75:	83 e0 01             	and    $0x1,%eax
80109e78:	85 c0                	test   %eax,%eax
80109e7a:	74 11                	je     80109e8d <http_proc+0x6e>
    char *payload = (char *)send;
80109e7c:	8b 45 10             	mov    0x10(%ebp),%eax
80109e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e88:	01 d0                	add    %edx,%eax
80109e8a:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e90:	8b 45 14             	mov    0x14(%ebp),%eax
80109e93:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109e95:	e8 75 ff ff ff       	call   80109e0f <tcp_fin>
}
80109e9a:	90                   	nop
80109e9b:	c9                   	leave
80109e9c:	c3                   	ret

80109e9d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109e9d:	55                   	push   %ebp
80109e9e:	89 e5                	mov    %esp,%ebp
80109ea0:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109ea3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109eaa:	eb 20                	jmp    80109ecc <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109eac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109eb2:	01 d0                	add    %edx,%eax
80109eb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109eb7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109eba:	01 ca                	add    %ecx,%edx
80109ebc:	89 d1                	mov    %edx,%ecx
80109ebe:	8b 55 08             	mov    0x8(%ebp),%edx
80109ec1:	01 ca                	add    %ecx,%edx
80109ec3:	0f b6 00             	movzbl (%eax),%eax
80109ec6:	88 02                	mov    %al,(%edx)
    i++;
80109ec8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109ecc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ed2:	01 d0                	add    %edx,%eax
80109ed4:	0f b6 00             	movzbl (%eax),%eax
80109ed7:	84 c0                	test   %al,%al
80109ed9:	75 d1                	jne    80109eac <http_strcpy+0xf>
  }
  return i;
80109edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109ede:	c9                   	leave
80109edf:	c3                   	ret

80109ee0 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109ee0:	55                   	push   %ebp
80109ee1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109ee3:	c7 05 70 71 19 80 a2 	movl   $0x8010f5a2,0x80197170
80109eea:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109eed:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109ef2:	c1 e8 09             	shr    $0x9,%eax
80109ef5:	a3 6c 71 19 80       	mov    %eax,0x8019716c
}
80109efa:	90                   	nop
80109efb:	5d                   	pop    %ebp
80109efc:	c3                   	ret

80109efd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109efd:	55                   	push   %ebp
80109efe:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f00:	90                   	nop
80109f01:	5d                   	pop    %ebp
80109f02:	c3                   	ret

80109f03 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f03:	55                   	push   %ebp
80109f04:	89 e5                	mov    %esp,%ebp
80109f06:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f09:	8b 45 08             	mov    0x8(%ebp),%eax
80109f0c:	83 c0 0c             	add    $0xc,%eax
80109f0f:	83 ec 0c             	sub    $0xc,%esp
80109f12:	50                   	push   %eax
80109f13:	e8 81 a7 ff ff       	call   80104699 <holdingsleep>
80109f18:	83 c4 10             	add    $0x10,%esp
80109f1b:	85 c0                	test   %eax,%eax
80109f1d:	75 0d                	jne    80109f2c <iderw+0x29>
    panic("iderw: buf not locked");
80109f1f:	83 ec 0c             	sub    $0xc,%esp
80109f22:	68 aa bf 10 80       	push   $0x8010bfaa
80109f27:	e8 7d 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f2f:	8b 00                	mov    (%eax),%eax
80109f31:	83 e0 06             	and    $0x6,%eax
80109f34:	83 f8 02             	cmp    $0x2,%eax
80109f37:	75 0d                	jne    80109f46 <iderw+0x43>
    panic("iderw: nothing to do");
80109f39:	83 ec 0c             	sub    $0xc,%esp
80109f3c:	68 c0 bf 10 80       	push   $0x8010bfc0
80109f41:	e8 63 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109f46:	8b 45 08             	mov    0x8(%ebp),%eax
80109f49:	8b 40 04             	mov    0x4(%eax),%eax
80109f4c:	83 f8 01             	cmp    $0x1,%eax
80109f4f:	74 0d                	je     80109f5e <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f51:	83 ec 0c             	sub    $0xc,%esp
80109f54:	68 d5 bf 10 80       	push   $0x8010bfd5
80109f59:	e8 4b 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109f61:	8b 40 08             	mov    0x8(%eax),%eax
80109f64:	8b 15 6c 71 19 80    	mov    0x8019716c,%edx
80109f6a:	39 d0                	cmp    %edx,%eax
80109f6c:	72 0d                	jb     80109f7b <iderw+0x78>
    panic("iderw: block out of range");
80109f6e:	83 ec 0c             	sub    $0xc,%esp
80109f71:	68 f3 bf 10 80       	push   $0x8010bff3
80109f76:	e8 2e 66 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109f7b:	8b 15 70 71 19 80    	mov    0x80197170,%edx
80109f81:	8b 45 08             	mov    0x8(%ebp),%eax
80109f84:	8b 40 08             	mov    0x8(%eax),%eax
80109f87:	c1 e0 09             	shl    $0x9,%eax
80109f8a:	01 d0                	add    %edx,%eax
80109f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f92:	8b 00                	mov    (%eax),%eax
80109f94:	83 e0 04             	and    $0x4,%eax
80109f97:	85 c0                	test   %eax,%eax
80109f99:	74 2b                	je     80109fc6 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9e:	8b 00                	mov    (%eax),%eax
80109fa0:	83 e0 fb             	and    $0xfffffffb,%eax
80109fa3:	89 c2                	mov    %eax,%edx
80109fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa8:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109faa:	8b 45 08             	mov    0x8(%ebp),%eax
80109fad:	83 c0 5c             	add    $0x5c,%eax
80109fb0:	83 ec 04             	sub    $0x4,%esp
80109fb3:	68 00 02 00 00       	push   $0x200
80109fb8:	50                   	push   %eax
80109fb9:	ff 75 f4             	push   -0xc(%ebp)
80109fbc:	e8 9e aa ff ff       	call   80104a5f <memmove>
80109fc1:	83 c4 10             	add    $0x10,%esp
80109fc4:	eb 1a                	jmp    80109fe0 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
80109fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc9:	83 c0 5c             	add    $0x5c,%eax
80109fcc:	83 ec 04             	sub    $0x4,%esp
80109fcf:	68 00 02 00 00       	push   $0x200
80109fd4:	ff 75 f4             	push   -0xc(%ebp)
80109fd7:	50                   	push   %eax
80109fd8:	e8 82 aa ff ff       	call   80104a5f <memmove>
80109fdd:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
80109fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe3:	8b 00                	mov    (%eax),%eax
80109fe5:	83 c8 02             	or     $0x2,%eax
80109fe8:	89 c2                	mov    %eax,%edx
80109fea:	8b 45 08             	mov    0x8(%ebp),%eax
80109fed:	89 10                	mov    %edx,(%eax)
}
80109fef:	90                   	nop
80109ff0:	c9                   	leave
80109ff1:	c3                   	ret
