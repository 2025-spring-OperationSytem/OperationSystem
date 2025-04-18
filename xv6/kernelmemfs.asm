
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
8010002d:	b8 00 d0 10 00       	mov    $0x10d000,%eax
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
8010005a:	bc 80 70 19 80       	mov    $0x80197080,%esp
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
8010006f:	68 c0 9f 10 80       	push   $0x80109fc0
80100074:	68 00 c0 18 80       	push   $0x8018c000
80100079:	e8 72 46 00 00       	call   801046f0 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 07 19 80 fc 	movl   $0x801906fc,0x8019074c
80100088:	06 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 07 19 80 fc 	movl   $0x801906fc,0x80190750
80100092:	06 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 c0 18 80 	movl   $0x8018c034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 07 19 80    	mov    0x80190750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 06 19 80 	movl   $0x801906fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 c7 9f 10 80       	push   $0x80109fc7
801000c2:	50                   	push   %eax
801000c3:	e8 cb 44 00 00       	call   80104593 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 07 19 80       	mov    0x80190750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 07 19 80       	mov    %eax,0x80190750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 06 19 80       	mov    $0x801906fc,%eax
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
801000fc:	68 00 c0 18 80       	push   $0x8018c000
80100101:	e8 0c 46 00 00       	call   80104712 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 07 19 80       	mov    0x80190750,%eax
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
8010013b:	68 00 c0 18 80       	push   $0x8018c000
80100140:	e8 3b 46 00 00       	call   80104780 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 78 44 00 00       	call   801045cf <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 06 19 80 	cmpl   $0x801906fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 07 19 80       	mov    0x8019074c,%eax
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
801001bc:	68 00 c0 18 80       	push   $0x8018c000
801001c1:	e8 ba 45 00 00       	call   80104780 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 f7 43 00 00       	call   801045cf <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 06 19 80 	cmpl   $0x801906fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ce 9f 10 80       	push   $0x80109fce
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
8010022d:	e8 86 9c 00 00       	call   80109eb8 <iderw>
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
8010024a:	e8 32 44 00 00       	call   80104681 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 df 9f 10 80       	push   $0x80109fdf
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
80100278:	e8 3b 9c 00 00       	call   80109eb8 <iderw>
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
80100293:	e8 e9 43 00 00       	call   80104681 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 e6 9f 10 80       	push   $0x80109fe6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 78 43 00 00       	call   80104633 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 c0 18 80       	push   $0x8018c000
801002c6:	e8 47 44 00 00       	call   80104712 <acquire>
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
80100305:	8b 15 50 07 19 80    	mov    0x80190750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 06 19 80 	movl   $0x801906fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 07 19 80       	mov    0x80190750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 07 19 80       	mov    %eax,0x80190750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 c0 18 80       	push   $0x8018c000
80100336:	e8 45 44 00 00       	call   80104780 <release>
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
80100395:	0f b6 91 04 c0 10 80 	movzbl -0x7fef3ffc(%ecx),%edx
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
801003fa:	a1 34 0a 19 80       	mov    0x80190a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 0a 19 80       	push   $0x80190a00
80100410:	e8 fd 42 00 00       	call   80104712 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ed 9f 10 80       	push   $0x80109fed
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
80100510:	c7 45 ec f6 9f 10 80 	movl   $0x80109ff6,-0x14(%ebp)
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
80100599:	68 00 0a 19 80       	push   $0x80190a00
8010059e:	e8 dd 41 00 00       	call   80104780 <release>
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
801005b4:	c7 05 34 0a 19 80 00 	movl   $0x0,0x80190a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 39 25 00 00       	call   80102afc <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 fd 9f 10 80       	push   $0x80109ffd
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
801005e6:	68 11 a0 10 80       	push   $0x8010a011
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 cf 41 00 00       	call   801047d2 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 13 a0 10 80       	push   $0x8010a013
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 09 19 80 01 	movl   $0x1,0x801909ec
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
8010064a:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
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
80100673:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 c0 10 80       	mov    %eax,0x8010c000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 c0 10 80       	mov    %eax,0x8010c000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 7f 77 00 00       	call   80107e25 <graphic_scroll_up>
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
801006b7:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 c0 10 80       	mov    %eax,0x8010c000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 c0 10 80       	mov    %eax,0x8010c000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 2c 77 00 00       	call   80107e25 <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
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
8010072b:	8b 0d 00 c0 10 80    	mov    0x8010c000,%ecx
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
80100756:	e8 37 77 00 00       	call   80107e92 <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 c0 10 80       	mov    %eax,0x8010c000
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
80100774:	a1 ec 09 19 80       	mov    0x801909ec,%eax
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
80100793:	e8 06 5b 00 00       	call   8010629e <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 f9 5a 00 00       	call   8010629e <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 ec 5a 00 00       	call   8010629e <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 dc 5a 00 00       	call   8010629e <uartputc>
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
801007e6:	68 00 0a 19 80       	push   $0x80190a00
801007eb:	e8 22 3f 00 00       	call   80104712 <acquire>
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
80100838:	a1 e8 09 19 80       	mov    0x801909e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 09 19 80       	mov    %eax,0x801909e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 09 19 80    	mov    0x801909e8,%edx
8010085b:	a1 e4 09 19 80       	mov    0x801909e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 09 19 80       	mov    0x801909e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 09 19 80 	movzbl -0x7fe6f6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 09 19 80    	mov    0x801909e8,%edx
80100889:	a1 e4 09 19 80       	mov    0x801909e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 09 19 80       	mov    0x801909e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 09 19 80       	mov    %eax,0x801909e8
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
801008c2:	8b 15 e8 09 19 80    	mov    0x801909e8,%edx
801008c8:	a1 e0 09 19 80       	mov    0x801909e0,%eax
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
801008e7:	a1 e8 09 19 80       	mov    0x801909e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 09 19 80    	mov    %edx,0x801909e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 09 19 80    	mov    %dl,-0x7fe6f6a0(%eax)
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
8010091b:	8b 15 e8 09 19 80    	mov    0x801909e8,%edx
80100921:	a1 e0 09 19 80       	mov    0x801909e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 09 19 80       	mov    0x801909e8,%eax
80100932:	a3 e4 09 19 80       	mov    %eax,0x801909e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 09 19 80       	push   $0x801909e0
8010093f:	e8 9a 3a 00 00       	call   801043de <wakeup>
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
80100965:	68 00 0a 19 80       	push   $0x80190a00
8010096a:	e8 11 3e 00 00       	call   80104780 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 1c 3b 00 00       	call   80104499 <procdump>
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
8010099d:	68 00 0a 19 80       	push   $0x80190a00
801009a2:	e8 6b 3d 00 00       	call   80104712 <acquire>
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
801009be:	68 00 0a 19 80       	push   $0x80190a00
801009c3:	e8 b8 3d 00 00       	call   80104780 <release>
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
801009e6:	68 00 0a 19 80       	push   $0x80190a00
801009eb:	68 e0 09 19 80       	push   $0x801909e0
801009f0:	e8 02 39 00 00       	call   801042f7 <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 09 19 80    	mov    0x801909e0,%edx
801009fe:	a1 e4 09 19 80       	mov    0x801909e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 09 19 80       	mov    0x801909e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 09 19 80    	mov    %edx,0x801909e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 09 19 80 	movzbl -0x7fe6f6a0(%eax),%eax
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
80100a33:	a1 e0 09 19 80       	mov    0x801909e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 09 19 80       	mov    %eax,0x801909e0
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
80100a69:	68 00 0a 19 80       	push   $0x80190a00
80100a6e:	e8 0d 3d 00 00       	call   80104780 <release>
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
80100aa7:	68 00 0a 19 80       	push   $0x80190a00
80100aac:	e8 61 3c 00 00       	call   80104712 <acquire>
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
80100ae9:	68 00 0a 19 80       	push   $0x80190a00
80100aee:	e8 8d 3c 00 00       	call   80104780 <release>
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
80100b0f:	c7 05 ec 09 19 80 00 	movl   $0x0,0x801909ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 17 a0 10 80       	push   $0x8010a017
80100b21:	68 00 0a 19 80       	push   $0x80190a00
80100b26:	e8 c5 3b 00 00       	call   801046f0 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 0a 19 80 90 	movl   $0x80100a90,0x80190a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 0a 19 80 80 	movl   $0x80100980,0x80190a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 1f a0 10 80 	movl   $0x8010a01f,-0xc(%ebp)
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
80100b6e:	c7 05 34 0a 19 80 01 	movl   $0x1,0x80190a34
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
80100bbf:	68 35 a0 10 80       	push   $0x8010a035
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
80100c1b:	e8 7a 66 00 00       	call   8010729a <setupkvm>
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
80100cc1:	e8 ce 69 00 00       	call   80107694 <allocuvm>
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
80100d07:	e8 bb 68 00 00       	call   801075c7 <loaduvm>
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
80100d76:	e8 19 69 00 00       	call   80107694 <allocuvm>
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
80100d9a:	e8 57 6b 00 00       	call   801078f6 <clearpteu>
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
80100dd3:	e8 fe 3d 00 00       	call   80104bd6 <strlen>
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
80100e00:	e8 d1 3d 00 00       	call   80104bd6 <strlen>
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
80100e26:	e8 6a 6c 00 00       	call   80107a95 <copyout>
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
80100ec2:	e8 ce 6b 00 00       	call   80107a95 <copyout>
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
80100f10:	e8 76 3c 00 00       	call   80104b8b <safestrcpy>
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
80100f53:	e8 60 64 00 00       	call   801073b8 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 f7 68 00 00       	call   8010785d <freevm>
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
80100fa1:	e8 b7 68 00 00       	call   8010785d <freevm>
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
80100fd2:	68 41 a0 10 80       	push   $0x8010a041
80100fd7:	68 a0 0a 19 80       	push   $0x80190aa0
80100fdc:	e8 0f 37 00 00       	call   801046f0 <initlock>
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
80100ff0:	68 a0 0a 19 80       	push   $0x80190aa0
80100ff5:	e8 18 37 00 00       	call   80104712 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 0a 19 80 	movl   $0x80190ad4,-0xc(%ebp)
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
8010101d:	68 a0 0a 19 80       	push   $0x80190aa0
80101022:	e8 59 37 00 00       	call   80104780 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 14 19 80       	mov    $0x80191434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 0a 19 80       	push   $0x80190aa0
80101045:	e8 36 37 00 00       	call   80104780 <release>
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
8010105d:	68 a0 0a 19 80       	push   $0x80190aa0
80101062:	e8 ab 36 00 00       	call   80104712 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 48 a0 10 80       	push   $0x8010a048
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 0a 19 80       	push   $0x80190aa0
80101098:	e8 e3 36 00 00       	call   80104780 <release>
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
801010ae:	68 a0 0a 19 80       	push   $0x80190aa0
801010b3:	e8 5a 36 00 00       	call   80104712 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 50 a0 10 80       	push   $0x8010a050
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
801010ee:	68 a0 0a 19 80       	push   $0x80190aa0
801010f3:	e8 88 36 00 00       	call   80104780 <release>
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
8010113c:	68 a0 0a 19 80       	push   $0x80190aa0
80101141:	e8 3a 36 00 00       	call   80104780 <release>
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
80101290:	68 5a a0 10 80       	push   $0x8010a05a
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
80101393:	68 63 a0 10 80       	push   $0x8010a063
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
801013c9:	68 73 a0 10 80       	push   $0x8010a073
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
80101401:	e8 41 36 00 00       	call   80104a47 <memmove>
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
80101447:	e8 3c 35 00 00       	call   80104988 <memset>
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
8010149a:	a1 58 14 19 80       	mov    0x80191458,%eax
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
80101570:	a1 40 14 19 80       	mov    0x80191440,%eax
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
80101592:	a1 40 14 19 80       	mov    0x80191440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 80 a0 10 80       	push   $0x8010a080
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
801015ba:	68 40 14 19 80       	push   $0x80191440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 14 19 80       	mov    0x80191458,%eax
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
80101630:	68 96 a0 10 80       	push   $0x8010a096
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
80101694:	68 a9 a0 10 80       	push   $0x8010a0a9
80101699:	68 60 14 19 80       	push   $0x80191460
8010169e:	e8 4d 30 00 00       	call   801046f0 <initlock>
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
801016bf:	05 60 14 19 80       	add    $0x80191460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 b0 a0 10 80       	push   $0x8010a0b0
801016cf:	50                   	push   %eax
801016d0:	e8 be 2e 00 00       	call   80104593 <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 14 19 80       	push   $0x80191440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 14 19 80       	mov    0x80191458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 14 19 80    	mov    0x80191454,%edi
80101703:	8b 35 50 14 19 80    	mov    0x80191450,%esi
80101709:	8b 1d 4c 14 19 80    	mov    0x8019144c,%ebx
8010170f:	8b 0d 48 14 19 80    	mov    0x80191448,%ecx
80101715:	8b 15 44 14 19 80    	mov    0x80191444,%edx
8010171b:	a1 40 14 19 80       	mov    0x80191440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 b8 a0 10 80       	push   $0x8010a0b8
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
80101760:	a1 54 14 19 80       	mov    0x80191454,%eax
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
801017a2:	e8 e1 31 00 00       	call   80104988 <memset>
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
801017f6:	a1 48 14 19 80       	mov    0x80191448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 0b a1 10 80       	push   $0x8010a10b
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
80101826:	a1 54 14 19 80       	mov    0x80191454,%eax
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
801018af:	e8 93 31 00 00       	call   80104a47 <memmove>
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
801018df:	68 60 14 19 80       	push   $0x80191460
801018e4:	e8 29 2e 00 00       	call   80104712 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 14 19 80 	movl   $0x80191494,-0xc(%ebp)
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
8010192d:	68 60 14 19 80       	push   $0x80191460
80101932:	e8 49 2e 00 00       	call   80104780 <release>
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
8010195c:	81 7d f4 b4 30 19 80 	cmpl   $0x801930b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 1d a1 10 80       	push   $0x8010a11d
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
801019a6:	68 60 14 19 80       	push   $0x80191460
801019ab:	e8 d0 2d 00 00       	call   80104780 <release>
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
801019c1:	68 60 14 19 80       	push   $0x80191460
801019c6:	e8 47 2d 00 00       	call   80104712 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 14 19 80       	push   $0x80191460
801019e5:	e8 96 2d 00 00       	call   80104780 <release>
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
80101a0b:	68 2d a1 10 80       	push   $0x8010a12d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 ab 2b 00 00       	call   801045cf <acquiresleep>
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
80101a40:	a1 54 14 19 80       	mov    0x80191454,%eax
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
80101ac9:	e8 79 2f 00 00       	call   80104a47 <memmove>
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
80101af8:	68 33 a1 10 80       	push   $0x8010a133
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
80101b1b:	e8 61 2b 00 00       	call   80104681 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 42 a1 10 80       	push   $0x8010a142
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 e6 2a 00 00       	call   80104633 <releasesleep>
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
80101b63:	e8 67 2a 00 00       	call   801045cf <acquiresleep>
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
80101b84:	68 60 14 19 80       	push   $0x80191460
80101b89:	e8 84 2b 00 00       	call   80104712 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 14 19 80       	push   $0x80191460
80101ba2:	e8 d9 2b 00 00       	call   80104780 <release>
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
80101be9:	e8 45 2a 00 00       	call   80104633 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 14 19 80       	push   $0x80191460
80101bf9:	e8 14 2b 00 00       	call   80104712 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 14 19 80       	push   $0x80191460
80101c18:	e8 63 2b 00 00       	call   80104780 <release>
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
80101d5c:	68 4a a1 10 80       	push   $0x8010a14a
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
80101f12:	8b 04 c5 40 0a 19 80 	mov    -0x7fe6f5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 0a 19 80 	mov    -0x7fe6f5c0(,%eax,8),%eax
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
80101ffa:	e8 48 2a 00 00       	call   80104a47 <memmove>
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
80102067:	8b 04 c5 44 0a 19 80 	mov    -0x7fe6f5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 0a 19 80 	mov    -0x7fe6f5bc(,%eax,8),%eax
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
8010214a:	e8 f8 28 00 00       	call   80104a47 <memmove>
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
801021ca:	e8 0e 29 00 00       	call   80104add <strncmp>
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
801021ea:	68 5d a1 10 80       	push   $0x8010a15d
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
80102219:	68 6f a1 10 80       	push   $0x8010a16f
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
801022ee:	68 7e a1 10 80       	push   $0x8010a17e
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
80102329:	e8 05 28 00 00       	call   80104b33 <strncpy>
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
80102355:	68 8b a1 10 80       	push   $0x8010a18b
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
801023c7:	e8 7b 26 00 00       	call   80104a47 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 64 26 00 00       	call   80104a47 <memmove>
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
8010255f:	a1 b4 30 19 80       	mov    0x801930b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 30 19 80       	mov    0x801930b4,%eax
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
80102576:	a1 b4 30 19 80       	mov    0x801930b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 30 19 80       	mov    0x801930b4,%eax
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
80102594:	c7 05 b4 30 19 80 00 	movl   $0xfec00000,0x801930b4
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
801025c3:	0f b6 05 44 5d 19 80 	movzbl 0x80195d44,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 94 a1 10 80       	push   $0x8010a194
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
8010267c:	68 c6 a1 10 80       	push   $0x8010a1c6
80102681:	68 c0 30 19 80       	push   $0x801930c0
80102686:	e8 65 20 00 00       	call   801046f0 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 30 19 80 00 	movl   $0x0,0x801930f4
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
801026c3:	c7 05 f4 30 19 80 01 	movl   $0x1,0x801930f4
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
80102720:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 cb a1 10 80       	push   $0x8010a1cb
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 31 22 00 00       	call   80104988 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 30 19 80       	mov    0x801930f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 30 19 80       	push   $0x801930c0
8010276b:	e8 a2 1f 00 00       	call   80104712 <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 30 19 80    	mov    0x801930f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 30 19 80       	mov    %eax,0x801930f8
  if(kmem.use_lock)
8010278c:	a1 f4 30 19 80       	mov    0x801930f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 30 19 80       	push   $0x801930c0
8010279d:	e8 de 1f 00 00       	call   80104780 <release>
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
801027ae:	a1 f4 30 19 80       	mov    0x801930f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 30 19 80       	push   $0x801930c0
801027bf:	e8 4e 1f 00 00       	call   80104712 <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 30 19 80       	mov    0x801930f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 30 19 80       	mov    %eax,0x801930f8
  if(kmem.use_lock)
801027df:	a1 f4 30 19 80       	mov    0x801930f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 30 19 80       	push   $0x801930c0
801027f0:	e8 8b 1f 00 00       	call   80104780 <release>
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
8010285d:	a1 fc 30 19 80       	mov    0x801930fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 30 19 80       	mov    %eax,0x801930fc
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
80102880:	a1 fc 30 19 80       	mov    0x801930fc,%eax
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
8010289d:	05 20 c0 10 80       	add    $0x8010c020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 30 19 80       	mov    0x801930fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 30 19 80       	mov    %eax,0x801930fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 30 19 80       	mov    0x801930fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 30 19 80       	mov    0x801930fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 30 19 80       	mov    %eax,0x801930fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 c0 10 80       	add    $0x8010c020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 30 19 80       	mov    0x801930fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 30 19 80       	mov    %eax,0x801930fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 c1 10 80       	add    $0x8010c120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 30 19 80       	mov    0x801930fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 30 19 80       	mov    %eax,0x801930fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 30 19 80       	mov    0x801930fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 c5 10 80 	mov    -0x7fef3ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 30 19 80       	mov    0x801930fc,%eax
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
801029c1:	a1 00 31 19 80       	mov    0x80193100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 31 19 80       	mov    0x80193100,%eax
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
801029e3:	a1 00 31 19 80       	mov    0x80193100,%eax
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
80102a56:	a1 00 31 19 80       	mov    0x80193100,%eax
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
80102ad6:	a1 00 31 19 80       	mov    0x80193100,%eax
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
80102aff:	a1 00 31 19 80       	mov    0x80193100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 31 19 80       	mov    0x80193100,%eax
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
80102b21:	a1 00 31 19 80       	mov    0x80193100,%eax
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
80102d14:	e8 d6 1c 00 00       	call   801049ef <memcmp>
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
80102e28:	68 d1 a1 10 80       	push   $0x8010a1d1
80102e2d:	68 20 31 19 80       	push   $0x80193120
80102e32:	e8 b9 18 00 00       	call   801046f0 <initlock>
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
80102e4f:	a3 54 31 19 80       	mov    %eax,0x80193154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 31 19 80       	mov    %eax,0x80193158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 31 19 80       	mov    %eax,0x80193164
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
80102e7e:	8b 15 54 31 19 80    	mov    0x80193154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 31 19 80       	mov    0x80193164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 31 19 80 	mov    -0x7fe6ced4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 31 19 80       	mov    0x80193164,%eax
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
80102edd:	e8 65 1b 00 00       	call   80104a47 <memmove>
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
80102f13:	a1 68 31 19 80       	mov    0x80193168,%eax
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
80102f2b:	a1 54 31 19 80       	mov    0x80193154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 31 19 80       	mov    0x80193164,%eax
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
80102f55:	a3 68 31 19 80       	mov    %eax,0x80193168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 31 19 80 	mov    %eax,-0x7fe6ced4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 31 19 80       	mov    0x80193168,%eax
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
80102f9f:	a1 54 31 19 80       	mov    0x80193154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 31 19 80       	mov    0x80193164,%eax
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
80102fc4:	8b 15 68 31 19 80    	mov    0x80193168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 31 19 80 	mov    -0x7fe6ced4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 31 19 80       	mov    0x80193168,%eax
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
8010302c:	c7 05 68 31 19 80 00 	movl   $0x0,0x80193168
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
80103047:	68 20 31 19 80       	push   $0x80193120
8010304c:	e8 c1 16 00 00       	call   80104712 <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 31 19 80       	mov    0x80193160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 31 19 80       	push   $0x80193120
80103065:	68 20 31 19 80       	push   $0x80193120
8010306a:	e8 88 12 00 00       	call   801042f7 <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 31 19 80    	mov    0x80193168,%ecx
8010307a:	a1 5c 31 19 80       	mov    0x8019315c,%eax
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
80103095:	68 20 31 19 80       	push   $0x80193120
8010309a:	68 20 31 19 80       	push   $0x80193120
8010309f:	e8 53 12 00 00       	call   801042f7 <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 31 19 80       	mov    0x8019315c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 31 19 80       	mov    %eax,0x8019315c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 31 19 80       	push   $0x80193120
801030be:	e8 bd 16 00 00       	call   80104780 <release>
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
801030da:	68 20 31 19 80       	push   $0x80193120
801030df:	e8 2e 16 00 00       	call   80104712 <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 31 19 80       	mov    0x8019315c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 31 19 80       	mov    %eax,0x8019315c
  if(log.committing)
801030f4:	a1 60 31 19 80       	mov    0x80193160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 d5 a1 10 80       	push   $0x8010a1d5
80103105:	e8 9f d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 31 19 80       	mov    0x8019315c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 31 19 80 01 	movl   $0x1,0x80193160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 31 19 80       	push   $0x80193120
8010312e:	e8 ab 12 00 00       	call   801043de <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 31 19 80       	push   $0x80193120
8010313e:	e8 3d 16 00 00       	call   80104780 <release>
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
80103154:	68 20 31 19 80       	push   $0x80193120
80103159:	e8 b4 15 00 00       	call   80104712 <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 31 19 80 00 	movl   $0x0,0x80193160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 31 19 80       	push   $0x80193120
80103173:	e8 66 12 00 00       	call   801043de <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 31 19 80       	push   $0x80193120
80103183:	e8 f8 15 00 00       	call   80104780 <release>
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
801031a0:	8b 15 54 31 19 80    	mov    0x80193154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 31 19 80       	mov    0x80193164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 31 19 80 	mov    -0x7fe6ced4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 31 19 80       	mov    0x80193164,%eax
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
801031ff:	e8 43 18 00 00       	call   80104a47 <memmove>
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
80103235:	a1 68 31 19 80       	mov    0x80193168,%eax
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
8010324d:	a1 68 31 19 80       	mov    0x80193168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 31 19 80 00 	movl   $0x0,0x80193168
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
8010327d:	a1 68 31 19 80       	mov    0x80193168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 31 19 80    	mov    0x80193168,%edx
8010328d:	a1 58 31 19 80       	mov    0x80193158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 e4 a1 10 80       	push   $0x8010a1e4
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 31 19 80       	mov    0x8019315c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 fa a1 10 80       	push   $0x8010a1fa
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 31 19 80       	push   $0x80193120
801032c4:	e8 49 14 00 00       	call   80104712 <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 31 19 80 	mov    -0x7fe6ced4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 31 19 80       	mov    0x80193168,%eax
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
8010330d:	89 14 85 2c 31 19 80 	mov    %edx,-0x7fe6ced4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 31 19 80       	mov    0x80193168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 31 19 80       	mov    0x80193168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 31 19 80       	mov    %eax,0x80193168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 31 19 80       	push   $0x80193120
80103342:	e8 39 14 00 00       	call   80104780 <release>
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
80103378:	e8 ed 49 00 00       	call   80107d6a <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 80 19 80       	push   $0x80198000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 f0 3f 00 00       	call   80107387 <kvmalloc>
  mpinit_uefi();
80103397:	e8 97 47 00 00       	call   80107b33 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 78 3a 00 00       	call   80106e1e <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 fd 2d 00 00       	call   801061b7 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 c6 29 00 00       	call   80105d8a <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 c2 6a 00 00       	call   80109e95 <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 d3 4b 00 00       	call   80107fc5 <pci_init>
  arp_scan();
801033f2:	e8 08 59 00 00       	call   80108cff <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 61 07 00 00       	call   80103b5d <userinit>

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
80103407:	e8 93 3f 00 00       	call   8010739f <switchkvm>
  seginit();
8010340c:	e8 0d 3a 00 00       	call   80106e1e <seginit>
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
80103433:	68 15 a2 10 80       	push   $0x8010a215
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 bb 2a 00 00       	call   80105f00 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 86 0c 00 00       	call   801040e8 <scheduler>

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
80103478:	68 18 e5 10 80       	push   $0x8010e518
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 c2 15 00 00       	call   80104a47 <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 5a 19 80 	movl   $0x80195a80,-0xc(%ebp)
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
801034c0:	b8 00 d0 10 80       	mov    $0x8010d000,%eax
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
8010350a:	a1 40 5d 19 80       	mov    0x80195d40,%eax
8010350f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103515:	05 80 5a 19 80       	add    $0x80195a80,%eax
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
80103607:	68 29 a2 10 80       	push   $0x8010a229
8010360c:	50                   	push   %eax
8010360d:	e8 de 10 00 00       	call   801046f0 <initlock>
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
801036cc:	e8 41 10 00 00       	call   80104712 <acquire>
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
801036f3:	e8 e6 0c 00 00       	call   801043de <wakeup>
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
80103716:	e8 c3 0c 00 00       	call   801043de <wakeup>
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
8010373f:	e8 3c 10 00 00       	call   80104780 <release>
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
8010375e:	e8 1d 10 00 00       	call   80104780 <release>
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
80103778:	e8 95 0f 00 00       	call   80104712 <acquire>
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
801037ac:	e8 cf 0f 00 00       	call   80104780 <release>
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
801037ca:	e8 0f 0c 00 00       	call   801043de <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 0f 0b 00 00       	call   801042f7 <sleep>
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
8010384d:	e8 8c 0b 00 00       	call   801043de <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 1f 0f 00 00       	call   80104780 <release>
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
80103879:	e8 94 0e 00 00       	call   80104712 <acquire>
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
80103896:	e8 e5 0e 00 00       	call   80104780 <release>
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
801038b9:	e8 39 0a 00 00       	call   801042f7 <sleep>
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
8010394c:	e8 8d 0a 00 00       	call   801043de <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 20 0e 00 00       	call   80104780 <release>
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
80103988:	68 30 a2 10 80       	push   $0x8010a230
8010398d:	68 00 32 19 80       	push   $0x80193200
80103992:	e8 59 0d 00 00       	call   801046f0 <initlock>
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
801039a8:	2d 80 5a 19 80       	sub    $0x80195a80,%eax
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
801039cf:	68 38 a2 10 80       	push   $0x8010a238
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
801039f3:	05 80 5a 19 80       	add    $0x80195a80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 5a 19 80       	add    $0x80195a80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 5d 19 80       	mov    0x80195d40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 5e a2 10 80       	push   $0x8010a25e
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
80103a36:	e8 42 0e 00 00       	call   8010487d <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 76 0e 00 00       	call   801048ca <popcli>
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
80103a62:	68 00 32 19 80       	push   $0x80193200
80103a67:	e8 a6 0c 00 00       	call   80104712 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 32 19 80 	movl   $0x80193234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a86:	81 7d f4 34 52 19 80 	cmpl   $0x80195234,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 32 19 80       	push   $0x80193200
80103a97:	e8 e4 0c 00 00       	call   80104780 <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 b2 00 00 00       	jmp    80103b5b <allocproc+0x102>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 e0 10 80       	mov    0x8010e000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 e0 10 80    	mov    %edx,0x8010e000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac8:	83 ec 0c             	sub    $0xc,%esp
80103acb:	68 00 32 19 80       	push   $0x80193200
80103ad0:	e8 ab 0c 00 00       	call   80104780 <release>
80103ad5:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad8:	e8 cb ec ff ff       	call   801027a8 <kalloc>
80103add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae0:	89 42 08             	mov    %eax,0x8(%edx)
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	8b 40 08             	mov    0x8(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	75 11                	jne    80103afe <allocproc+0xa5>
    p->state = UNUSED;
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af7:	b8 00 00 00 00       	mov    $0x0,%eax
80103afc:	eb 5d                	jmp    80103b5b <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b01:	8b 40 08             	mov    0x8(%eax),%eax
80103b04:	05 00 10 00 00       	add    $0x1000,%eax
80103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b16:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b19:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1d:	ba 44 5d 10 80       	mov    $0x80105d44,%edx
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b27:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b31:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 14                	push   $0x14
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 41 0e 00 00       	call   80104988 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba b1 42 10 80       	mov    $0x801042b1,%edx
80103b55:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5b:	c9                   	leave
80103b5c:	c3                   	ret

80103b5d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b63:	e8 f1 fe ff ff       	call   80103a59 <allocproc>
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	a3 34 52 19 80       	mov    %eax,0x80195234
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 22 37 00 00       	call   8010729a <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 6e a2 10 80       	push   $0x8010a26e
80103b90:	e8 14 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b95:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ba0:	83 ec 04             	sub    $0x4,%esp
80103ba3:	52                   	push   %edx
80103ba4:	68 ec e4 10 80       	push   $0x8010e4ec
80103ba9:	50                   	push   %eax
80103baa:	e8 a8 39 00 00       	call   80107557 <inituvm>
80103baf:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 18             	mov    0x18(%eax),%eax
80103bc1:	83 ec 04             	sub    $0x4,%esp
80103bc4:	6a 4c                	push   $0x4c
80103bc6:	6a 00                	push   $0x0
80103bc8:	50                   	push   %eax
80103bc9:	e8 ba 0d 00 00       	call   80104988 <memset>
80103bce:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	8b 40 18             	mov    0x18(%eax),%eax
80103bd7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 18             	mov    0x18(%eax),%eax
80103be3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	8b 50 18             	mov    0x18(%eax),%edx
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	8b 40 18             	mov    0x18(%eax),%eax
80103bf5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 50 18             	mov    0x18(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 18             	mov    0x18(%eax),%eax
80103c09:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	83 c0 6c             	add    $0x6c,%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	6a 10                	push   $0x10
80103c43:	68 87 a2 10 80       	push   $0x8010a287
80103c48:	50                   	push   %eax
80103c49:	e8 3d 0f 00 00       	call   80104b8b <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 90 a2 10 80       	push   $0x8010a290
80103c59:	e8 c7 e8 ff ff       	call   80102525 <namei>
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c64:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 00 32 19 80       	push   $0x80193200
80103c6f:	e8 9e 0a 00 00       	call   80104712 <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 32 19 80       	push   $0x80193200
80103c89:	e8 f2 0a 00 00       	call   80104780 <release>
80103c8e:	83 c4 10             	add    $0x10,%esp
}
80103c91:	90                   	nop
80103c92:	c9                   	leave
80103c93:	c3                   	ret

80103c94 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c94:	55                   	push   %ebp
80103c95:	89 e5                	mov    %esp,%ebp
80103c97:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9a:	e8 91 fd ff ff       	call   80103a30 <myproc>
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca5:	8b 00                	mov    (%eax),%eax
80103ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cae:	7e 2e                	jle    80103cde <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	01 c2                	add    %eax,%edx
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	8b 40 04             	mov    0x4(%eax),%eax
80103cbe:	83 ec 04             	sub    $0x4,%esp
80103cc1:	52                   	push   %edx
80103cc2:	ff 75 f4             	push   -0xc(%ebp)
80103cc5:	50                   	push   %eax
80103cc6:	e8 c9 39 00 00       	call   80107694 <allocuvm>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd5:	75 3b                	jne    80103d12 <growproc+0x7e>
      return -1;
80103cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdc:	eb 4f                	jmp    80103d2d <growproc+0x99>
  } else if(n < 0){
80103cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce2:	79 2e                	jns    80103d12 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	01 c2                	add    %eax,%edx
80103cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cef:	8b 40 04             	mov    0x4(%eax),%eax
80103cf2:	83 ec 04             	sub    $0x4,%esp
80103cf5:	52                   	push   %edx
80103cf6:	ff 75 f4             	push   -0xc(%ebp)
80103cf9:	50                   	push   %eax
80103cfa:	e8 9a 3a 00 00       	call   80107799 <deallocuvm>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d09:	75 07                	jne    80103d12 <growproc+0x7e>
      return -1;
80103d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d10:	eb 1b                	jmp    80103d2d <growproc+0x99>
  }
  curproc->sz = sz;
80103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1a:	83 ec 0c             	sub    $0xc,%esp
80103d1d:	ff 75 f0             	push   -0x10(%ebp)
80103d20:	e8 93 36 00 00       	call   801073b8 <switchuvm>
80103d25:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2d:	c9                   	leave
80103d2e:	c3                   	ret

80103d2f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	57                   	push   %edi
80103d33:	56                   	push   %esi
80103d34:	53                   	push   %ebx
80103d35:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d38:	e8 f3 fc ff ff       	call   80103a30 <myproc>
80103d3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d40:	e8 14 fd ff ff       	call   80103a59 <allocproc>
80103d45:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4c:	75 0a                	jne    80103d58 <fork+0x29>
    return -1;
80103d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d53:	e9 48 01 00 00       	jmp    80103ea0 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 10                	mov    (%eax),%edx
80103d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d60:	8b 40 04             	mov    0x4(%eax),%eax
80103d63:	83 ec 08             	sub    $0x8,%esp
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 ca 3b 00 00       	call   80107937 <copyuvm>
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d73:	89 42 04             	mov    %eax,0x4(%edx)
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 04             	mov    0x4(%eax),%eax
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 30                	jne    80103db0 <fork+0x81>
    kfree(np->kstack);
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 08             	mov    0x8(%eax),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 7f e9 ff ff       	call   8010270e <kfree>
80103d8f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	e9 f0 00 00 00       	jmp    80103ea0 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db3:	8b 10                	mov    (%eax),%edx
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc6:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcc:	8b 40 18             	mov    0x18(%eax),%eax
80103dcf:	89 c2                	mov    %eax,%edx
80103dd1:	89 cb                	mov    %ecx,%ebx
80103dd3:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd8:	89 d7                	mov    %edx,%edi
80103dda:	89 de                	mov    %ebx,%esi
80103ddc:	89 c1                	mov    %eax,%ecx
80103dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de3:	8b 40 18             	mov    0x18(%eax),%eax
80103de6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df4:	eb 3b                	jmp    80103e31 <fork+0x102>
    if(curproc->ofile[i])
80103df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfc:	83 c2 08             	add    $0x8,%edx
80103dff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e03:	85 c0                	test   %eax,%eax
80103e05:	74 26                	je     80103e2d <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0d:	83 c2 08             	add    $0x8,%edx
80103e10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	50                   	push   %eax
80103e18:	e8 37 d2 ff ff       	call   80101054 <filedup>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e26:	83 c1 08             	add    $0x8,%ecx
80103e29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e35:	7e bf                	jle    80103df6 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3a:	8b 40 68             	mov    0x68(%eax),%eax
80103e3d:	83 ec 0c             	sub    $0xc,%esp
80103e40:	50                   	push   %eax
80103e41:	e8 72 db ff ff       	call   801019b8 <idup>
80103e46:	83 c4 10             	add    $0x10,%esp
80103e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e52:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e58:	83 c0 6c             	add    $0x6c,%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	6a 10                	push   $0x10
80103e60:	52                   	push   %edx
80103e61:	50                   	push   %eax
80103e62:	e8 24 0d 00 00       	call   80104b8b <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 32 19 80       	push   $0x80193200
80103e7b:	e8 92 08 00 00       	call   80104712 <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 32 19 80       	push   $0x80193200
80103e95:	e8 e6 08 00 00       	call   80104780 <release>
80103e9a:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea3:	5b                   	pop    %ebx
80103ea4:	5e                   	pop    %esi
80103ea5:	5f                   	pop    %edi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret

80103ea8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eae:	e8 7d fb ff ff       	call   80103a30 <myproc>
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb6:	a1 34 52 19 80       	mov    0x80195234,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 92 a2 10 80       	push   $0x8010a292
80103ec8:	e8 dc c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ecd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed4:	eb 3f                	jmp    80103f15 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edc:	83 c2 08             	add    $0x8,%edx
80103edf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee3:	85 c0                	test   %eax,%eax
80103ee5:	74 2a                	je     80103f11 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eed:	83 c2 08             	add    $0x8,%edx
80103ef0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 a8 d1 ff ff       	call   801010a5 <fileclose>
80103efd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f06:	83 c2 08             	add    $0x8,%edx
80103f09:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f10:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f15:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f19:	7e bb                	jle    80103ed6 <exit+0x2e>
    }
  }

  begin_op();
80103f1b:	e8 1e f1 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f23:	8b 40 68             	mov    0x68(%eax),%eax
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	50                   	push   %eax
80103f2a:	e8 24 dc ff ff       	call   80101b53 <iput>
80103f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f32:	e8 93 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 00 32 19 80       	push   $0x80193200
80103f49:	e8 c4 07 00 00       	call   80104712 <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 3e 04 00 00       	call   8010439e <wakeup1>
80103f60:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f63:	c7 45 f4 34 32 19 80 	movl   $0x80193234,-0xc(%ebp)
80103f6a:	eb 37                	jmp    80103fa3 <exit+0xfb>
    if(p->parent == curproc){
80103f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6f:	8b 40 14             	mov    0x14(%eax),%eax
80103f72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f75:	75 28                	jne    80103f9f <exit+0xf7>
      p->parent = initproc;
80103f77:	8b 15 34 52 19 80    	mov    0x80195234,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 52 19 80       	mov    0x80195234,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 02 04 00 00       	call   8010439e <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103fa3:	81 7d f4 34 52 19 80 	cmpl   $0x80195234,-0xc(%ebp)
80103faa:	72 c0                	jb     80103f6c <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb6:	e8 03 02 00 00       	call   801041be <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 9f a2 10 80       	push   $0x8010a29f
80103fc3:	e8 e1 c5 ff ff       	call   801005a9 <panic>

80103fc8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd6:	83 ec 0c             	sub    $0xc,%esp
80103fd9:	68 00 32 19 80       	push   $0x80193200
80103fde:	e8 2f 07 00 00       	call   80104712 <acquire>
80103fe3:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fed:	c7 45 f4 34 32 19 80 	movl   $0x80193234,-0xc(%ebp)
80103ff4:	e9 a1 00 00 00       	jmp    8010409a <wait+0xd2>
      if(p->parent != curproc)
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	8b 40 14             	mov    0x14(%eax),%eax
80103fff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104002:	0f 85 8d 00 00 00    	jne    80104095 <wait+0xcd>
        continue;
      havekids = 1;
80104008:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 40 0c             	mov    0xc(%eax),%eax
80104015:	83 f8 05             	cmp    $0x5,%eax
80104018:	75 7c                	jne    80104096 <wait+0xce>
        // Found one.
        pid = p->pid;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	8b 40 10             	mov    0x10(%eax),%eax
80104020:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	8b 40 08             	mov    0x8(%eax),%eax
80104029:	83 ec 0c             	sub    $0xc,%esp
8010402c:	50                   	push   %eax
8010402d:	e8 dc e6 ff ff       	call   8010270e <kfree>
80104032:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	8b 40 04             	mov    0x4(%eax),%eax
80104045:	83 ec 0c             	sub    $0xc,%esp
80104048:	50                   	push   %eax
80104049:	e8 0f 38 00 00       	call   8010785d <freevm>
8010404e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104054:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104079:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	68 00 32 19 80       	push   $0x80193200
80104088:	e8 f3 06 00 00       	call   80104780 <release>
8010408d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104090:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104093:	eb 51                	jmp    801040e6 <wait+0x11e>
        continue;
80104095:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104096:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010409a:	81 7d f4 34 52 19 80 	cmpl   $0x80195234,-0xc(%ebp)
801040a1:	0f 82 52 ff ff ff    	jb     80103ff9 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ab:	74 0a                	je     801040b7 <wait+0xef>
801040ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b0:	8b 40 24             	mov    0x24(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	74 17                	je     801040ce <wait+0x106>
      release(&ptable.lock);
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 00 32 19 80       	push   $0x80193200
801040bf:	e8 bc 06 00 00       	call   80104780 <release>
801040c4:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cc:	eb 18                	jmp    801040e6 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040ce:	83 ec 08             	sub    $0x8,%esp
801040d1:	68 00 32 19 80       	push   $0x80193200
801040d6:	ff 75 ec             	push   -0x14(%ebp)
801040d9:	e8 19 02 00 00       	call   801042f7 <sleep>
801040de:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040e1:	e9 00 ff ff ff       	jmp    80103fe6 <wait+0x1e>
  }
}
801040e6:	c9                   	leave
801040e7:	c3                   	ret

801040e8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e8:	55                   	push   %ebp
801040e9:	89 e5                	mov    %esp,%ebp
801040eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040ee:	e8 c5 f8 ff ff       	call   801039b8 <mycpu>
801040f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104100:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104103:	e8 70 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104108:	83 ec 0c             	sub    $0xc,%esp
8010410b:	68 00 32 19 80       	push   $0x80193200
80104110:	e8 fd 05 00 00       	call   80104712 <acquire>
80104115:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104118:	c7 45 f4 34 32 19 80 	movl   $0x80193234,-0xc(%ebp)
8010411f:	eb 61                	jmp    80104182 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	8b 40 0c             	mov    0xc(%eax),%eax
80104127:	83 f8 03             	cmp    $0x3,%eax
8010412a:	75 51                	jne    8010417d <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010412c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104132:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	ff 75 f4             	push   -0xc(%ebp)
8010413e:	e8 75 32 00 00       	call   801073b8 <switchuvm>
80104143:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	8b 40 1c             	mov    0x1c(%eax),%eax
80104156:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104159:	83 c2 04             	add    $0x4,%edx
8010415c:	83 ec 08             	sub    $0x8,%esp
8010415f:	50                   	push   %eax
80104160:	52                   	push   %edx
80104161:	e8 97 0a 00 00       	call   80104bfd <swtch>
80104166:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104169:	e8 31 32 00 00       	call   8010739f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010416e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104171:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104178:	00 00 00 
8010417b:	eb 01                	jmp    8010417e <scheduler+0x96>
        continue;
8010417d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010417e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104182:	81 7d f4 34 52 19 80 	cmpl   $0x80195234,-0xc(%ebp)
80104189:	72 96                	jb     80104121 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 00 32 19 80       	push   $0x80193200
80104193:	e8 e8 05 00 00       	call   80104780 <release>
80104198:	83 c4 10             	add    $0x10,%esp
    sti();
8010419b:	e9 63 ff ff ff       	jmp    80104103 <scheduler+0x1b>

801041a0 <uthread_init>:
  }
}

int 
uthread_init(int address)
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801041a6:	e8 85 f8 ff ff       	call   80103a30 <myproc>
801041ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
801041ae:	8b 55 08             	mov    0x8(%ebp),%edx
801041b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b4:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
801041b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041bc:	c9                   	leave
801041bd:	c3                   	ret

801041be <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041be:	55                   	push   %ebp
801041bf:	89 e5                	mov    %esp,%ebp
801041c1:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041c4:	e8 67 f8 ff ff       	call   80103a30 <myproc>
801041c9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	68 00 32 19 80       	push   $0x80193200
801041d4:	e8 74 06 00 00       	call   8010484d <holding>
801041d9:	83 c4 10             	add    $0x10,%esp
801041dc:	85 c0                	test   %eax,%eax
801041de:	75 0d                	jne    801041ed <sched+0x2f>
    panic("sched ptable.lock");
801041e0:	83 ec 0c             	sub    $0xc,%esp
801041e3:	68 ab a2 10 80       	push   $0x8010a2ab
801041e8:	e8 bc c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041ed:	e8 c6 f7 ff ff       	call   801039b8 <mycpu>
801041f2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041f8:	83 f8 01             	cmp    $0x1,%eax
801041fb:	74 0d                	je     8010420a <sched+0x4c>
    panic("sched locks");
801041fd:	83 ec 0c             	sub    $0xc,%esp
80104200:	68 bd a2 10 80       	push   $0x8010a2bd
80104205:	e8 9f c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
8010420a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420d:	8b 40 0c             	mov    0xc(%eax),%eax
80104210:	83 f8 04             	cmp    $0x4,%eax
80104213:	75 0d                	jne    80104222 <sched+0x64>
    panic("sched running");
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	68 c9 a2 10 80       	push   $0x8010a2c9
8010421d:	e8 87 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104222:	e8 41 f7 ff ff       	call   80103968 <readeflags>
80104227:	25 00 02 00 00       	and    $0x200,%eax
8010422c:	85 c0                	test   %eax,%eax
8010422e:	74 0d                	je     8010423d <sched+0x7f>
    panic("sched interruptible");
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	68 d7 a2 10 80       	push   $0x8010a2d7
80104238:	e8 6c c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010423d:	e8 76 f7 ff ff       	call   801039b8 <mycpu>
80104242:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104248:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010424b:	e8 68 f7 ff ff       	call   801039b8 <mycpu>
80104250:	8b 40 04             	mov    0x4(%eax),%eax
80104253:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104256:	83 c2 1c             	add    $0x1c,%edx
80104259:	83 ec 08             	sub    $0x8,%esp
8010425c:	50                   	push   %eax
8010425d:	52                   	push   %edx
8010425e:	e8 9a 09 00 00       	call   80104bfd <swtch>
80104263:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104266:	e8 4d f7 ff ff       	call   801039b8 <mycpu>
8010426b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010426e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104274:	90                   	nop
80104275:	c9                   	leave
80104276:	c3                   	ret

80104277 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104277:	55                   	push   %ebp
80104278:	89 e5                	mov    %esp,%ebp
8010427a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010427d:	83 ec 0c             	sub    $0xc,%esp
80104280:	68 00 32 19 80       	push   $0x80193200
80104285:	e8 88 04 00 00       	call   80104712 <acquire>
8010428a:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010428d:	e8 9e f7 ff ff       	call   80103a30 <myproc>
80104292:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104299:	e8 20 ff ff ff       	call   801041be <sched>
  release(&ptable.lock);
8010429e:	83 ec 0c             	sub    $0xc,%esp
801042a1:	68 00 32 19 80       	push   $0x80193200
801042a6:	e8 d5 04 00 00       	call   80104780 <release>
801042ab:	83 c4 10             	add    $0x10,%esp
}
801042ae:	90                   	nop
801042af:	c9                   	leave
801042b0:	c3                   	ret

801042b1 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801042b1:	55                   	push   %ebp
801042b2:	89 e5                	mov    %esp,%ebp
801042b4:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042b7:	83 ec 0c             	sub    $0xc,%esp
801042ba:	68 00 32 19 80       	push   $0x80193200
801042bf:	e8 bc 04 00 00       	call   80104780 <release>
801042c4:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042c7:	a1 04 e0 10 80       	mov    0x8010e004,%eax
801042cc:	85 c0                	test   %eax,%eax
801042ce:	74 24                	je     801042f4 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042d0:	c7 05 04 e0 10 80 00 	movl   $0x0,0x8010e004
801042d7:	00 00 00 
    iinit(ROOTDEV);
801042da:	83 ec 0c             	sub    $0xc,%esp
801042dd:	6a 01                	push   $0x1
801042df:	e8 9d d3 ff ff       	call   80101681 <iinit>
801042e4:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042e7:	83 ec 0c             	sub    $0xc,%esp
801042ea:	6a 01                	push   $0x1
801042ec:	e8 2e eb ff ff       	call   80102e1f <initlog>
801042f1:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042f4:	90                   	nop
801042f5:	c9                   	leave
801042f6:	c3                   	ret

801042f7 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042f7:	55                   	push   %ebp
801042f8:	89 e5                	mov    %esp,%ebp
801042fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042fd:	e8 2e f7 ff ff       	call   80103a30 <myproc>
80104302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104309:	75 0d                	jne    80104318 <sleep+0x21>
    panic("sleep");
8010430b:	83 ec 0c             	sub    $0xc,%esp
8010430e:	68 eb a2 10 80       	push   $0x8010a2eb
80104313:	e8 91 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104318:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010431c:	75 0d                	jne    8010432b <sleep+0x34>
    panic("sleep without lk");
8010431e:	83 ec 0c             	sub    $0xc,%esp
80104321:	68 f1 a2 10 80       	push   $0x8010a2f1
80104326:	e8 7e c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010432b:	81 7d 0c 00 32 19 80 	cmpl   $0x80193200,0xc(%ebp)
80104332:	74 1e                	je     80104352 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104334:	83 ec 0c             	sub    $0xc,%esp
80104337:	68 00 32 19 80       	push   $0x80193200
8010433c:	e8 d1 03 00 00       	call   80104712 <acquire>
80104341:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104344:	83 ec 0c             	sub    $0xc,%esp
80104347:	ff 75 0c             	push   0xc(%ebp)
8010434a:	e8 31 04 00 00       	call   80104780 <release>
8010434f:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	8b 55 08             	mov    0x8(%ebp),%edx
80104358:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104365:	e8 54 fe ff ff       	call   801041be <sched>

  // Tidy up.
  p->chan = 0;
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104374:	81 7d 0c 00 32 19 80 	cmpl   $0x80193200,0xc(%ebp)
8010437b:	74 1e                	je     8010439b <sleep+0xa4>
    release(&ptable.lock);
8010437d:	83 ec 0c             	sub    $0xc,%esp
80104380:	68 00 32 19 80       	push   $0x80193200
80104385:	e8 f6 03 00 00       	call   80104780 <release>
8010438a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010438d:	83 ec 0c             	sub    $0xc,%esp
80104390:	ff 75 0c             	push   0xc(%ebp)
80104393:	e8 7a 03 00 00       	call   80104712 <acquire>
80104398:	83 c4 10             	add    $0x10,%esp
  }
}
8010439b:	90                   	nop
8010439c:	c9                   	leave
8010439d:	c3                   	ret

8010439e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010439e:	55                   	push   %ebp
8010439f:	89 e5                	mov    %esp,%ebp
801043a1:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a4:	c7 45 fc 34 32 19 80 	movl   $0x80193234,-0x4(%ebp)
801043ab:	eb 24                	jmp    801043d1 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
801043ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b0:	8b 40 0c             	mov    0xc(%eax),%eax
801043b3:	83 f8 02             	cmp    $0x2,%eax
801043b6:	75 15                	jne    801043cd <wakeup1+0x2f>
801043b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043bb:	8b 40 20             	mov    0x20(%eax),%eax
801043be:	39 45 08             	cmp    %eax,0x8(%ebp)
801043c1:	75 0a                	jne    801043cd <wakeup1+0x2f>
      p->state = RUNNABLE;
801043c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043c6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043cd:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043d1:	81 7d fc 34 52 19 80 	cmpl   $0x80195234,-0x4(%ebp)
801043d8:	72 d3                	jb     801043ad <wakeup1+0xf>
}
801043da:	90                   	nop
801043db:	90                   	nop
801043dc:	c9                   	leave
801043dd:	c3                   	ret

801043de <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043de:	55                   	push   %ebp
801043df:	89 e5                	mov    %esp,%ebp
801043e1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	68 00 32 19 80       	push   $0x80193200
801043ec:	e8 21 03 00 00       	call   80104712 <acquire>
801043f1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043f4:	83 ec 0c             	sub    $0xc,%esp
801043f7:	ff 75 08             	push   0x8(%ebp)
801043fa:	e8 9f ff ff ff       	call   8010439e <wakeup1>
801043ff:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104402:	83 ec 0c             	sub    $0xc,%esp
80104405:	68 00 32 19 80       	push   $0x80193200
8010440a:	e8 71 03 00 00       	call   80104780 <release>
8010440f:	83 c4 10             	add    $0x10,%esp
}
80104412:	90                   	nop
80104413:	c9                   	leave
80104414:	c3                   	ret

80104415 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104415:	55                   	push   %ebp
80104416:	89 e5                	mov    %esp,%ebp
80104418:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	68 00 32 19 80       	push   $0x80193200
80104423:	e8 ea 02 00 00       	call   80104712 <acquire>
80104428:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010442b:	c7 45 f4 34 32 19 80 	movl   $0x80193234,-0xc(%ebp)
80104432:	eb 45                	jmp    80104479 <kill+0x64>
    if(p->pid == pid){
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104437:	8b 40 10             	mov    0x10(%eax),%eax
8010443a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010443d:	75 36                	jne    80104475 <kill+0x60>
      p->killed = 1;
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104442:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	8b 40 0c             	mov    0xc(%eax),%eax
8010444f:	83 f8 02             	cmp    $0x2,%eax
80104452:	75 0a                	jne    8010445e <kill+0x49>
        p->state = RUNNABLE;
80104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104457:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	68 00 32 19 80       	push   $0x80193200
80104466:	e8 15 03 00 00       	call   80104780 <release>
8010446b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010446e:	b8 00 00 00 00       	mov    $0x0,%eax
80104473:	eb 22                	jmp    80104497 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104475:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104479:	81 7d f4 34 52 19 80 	cmpl   $0x80195234,-0xc(%ebp)
80104480:	72 b2                	jb     80104434 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104482:	83 ec 0c             	sub    $0xc,%esp
80104485:	68 00 32 19 80       	push   $0x80193200
8010448a:	e8 f1 02 00 00       	call   80104780 <release>
8010448f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104497:	c9                   	leave
80104498:	c3                   	ret

80104499 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104499:	55                   	push   %ebp
8010449a:	89 e5                	mov    %esp,%ebp
8010449c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010449f:	c7 45 f0 34 32 19 80 	movl   $0x80193234,-0x10(%ebp)
801044a6:	e9 d7 00 00 00       	jmp    80104582 <procdump+0xe9>
    if(p->state == UNUSED)
801044ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ae:	8b 40 0c             	mov    0xc(%eax),%eax
801044b1:	85 c0                	test   %eax,%eax
801044b3:	0f 84 c4 00 00 00    	je     8010457d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bc:	8b 40 0c             	mov    0xc(%eax),%eax
801044bf:	83 f8 05             	cmp    $0x5,%eax
801044c2:	77 23                	ja     801044e7 <procdump+0x4e>
801044c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c7:	8b 40 0c             	mov    0xc(%eax),%eax
801044ca:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
801044d1:	85 c0                	test   %eax,%eax
801044d3:	74 12                	je     801044e7 <procdump+0x4e>
      state = states[p->state];
801044d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d8:	8b 40 0c             	mov    0xc(%eax),%eax
801044db:	8b 04 85 08 e0 10 80 	mov    -0x7fef1ff8(,%eax,4),%eax
801044e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044e5:	eb 07                	jmp    801044ee <procdump+0x55>
    else
      state = "???";
801044e7:	c7 45 ec 02 a3 10 80 	movl   $0x8010a302,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f1:	8d 50 6c             	lea    0x6c(%eax),%edx
801044f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f7:	8b 40 10             	mov    0x10(%eax),%eax
801044fa:	52                   	push   %edx
801044fb:	ff 75 ec             	push   -0x14(%ebp)
801044fe:	50                   	push   %eax
801044ff:	68 06 a3 10 80       	push   $0x8010a306
80104504:	e8 eb be ff ff       	call   801003f4 <cprintf>
80104509:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010450c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450f:	8b 40 0c             	mov    0xc(%eax),%eax
80104512:	83 f8 02             	cmp    $0x2,%eax
80104515:	75 54                	jne    8010456b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010451a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010451d:	8b 40 0c             	mov    0xc(%eax),%eax
80104520:	83 c0 08             	add    $0x8,%eax
80104523:	89 c2                	mov    %eax,%edx
80104525:	83 ec 08             	sub    $0x8,%esp
80104528:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010452b:	50                   	push   %eax
8010452c:	52                   	push   %edx
8010452d:	e8 a0 02 00 00       	call   801047d2 <getcallerpcs>
80104532:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104535:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010453c:	eb 1c                	jmp    8010455a <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010453e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104541:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104545:	83 ec 08             	sub    $0x8,%esp
80104548:	50                   	push   %eax
80104549:	68 0f a3 10 80       	push   $0x8010a30f
8010454e:	e8 a1 be ff ff       	call   801003f4 <cprintf>
80104553:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104556:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010455a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010455e:	7f 0b                	jg     8010456b <procdump+0xd2>
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104567:	85 c0                	test   %eax,%eax
80104569:	75 d3                	jne    8010453e <procdump+0xa5>
    }
    cprintf("\n");
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	68 13 a3 10 80       	push   $0x8010a313
80104573:	e8 7c be ff ff       	call   801003f4 <cprintf>
80104578:	83 c4 10             	add    $0x10,%esp
8010457b:	eb 01                	jmp    8010457e <procdump+0xe5>
      continue;
8010457d:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010457e:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104582:	81 7d f0 34 52 19 80 	cmpl   $0x80195234,-0x10(%ebp)
80104589:	0f 82 1c ff ff ff    	jb     801044ab <procdump+0x12>
  }
8010458f:	90                   	nop
80104590:	90                   	nop
80104591:	c9                   	leave
80104592:	c3                   	ret

80104593 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104593:	55                   	push   %ebp
80104594:	89 e5                	mov    %esp,%ebp
80104596:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104599:	8b 45 08             	mov    0x8(%ebp),%eax
8010459c:	83 c0 04             	add    $0x4,%eax
8010459f:	83 ec 08             	sub    $0x8,%esp
801045a2:	68 3f a3 10 80       	push   $0x8010a33f
801045a7:	50                   	push   %eax
801045a8:	e8 43 01 00 00       	call   801046f0 <initlock>
801045ad:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045b0:	8b 45 08             	mov    0x8(%ebp),%eax
801045b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801045b6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045b9:	8b 45 08             	mov    0x8(%ebp),%eax
801045bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045c2:	8b 45 08             	mov    0x8(%ebp),%eax
801045c5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045cc:	90                   	nop
801045cd:	c9                   	leave
801045ce:	c3                   	ret

801045cf <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045cf:	55                   	push   %ebp
801045d0:	89 e5                	mov    %esp,%ebp
801045d2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045d5:	8b 45 08             	mov    0x8(%ebp),%eax
801045d8:	83 c0 04             	add    $0x4,%eax
801045db:	83 ec 0c             	sub    $0xc,%esp
801045de:	50                   	push   %eax
801045df:	e8 2e 01 00 00       	call   80104712 <acquire>
801045e4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045e7:	eb 15                	jmp    801045fe <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045e9:	8b 45 08             	mov    0x8(%ebp),%eax
801045ec:	83 c0 04             	add    $0x4,%eax
801045ef:	83 ec 08             	sub    $0x8,%esp
801045f2:	50                   	push   %eax
801045f3:	ff 75 08             	push   0x8(%ebp)
801045f6:	e8 fc fc ff ff       	call   801042f7 <sleep>
801045fb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104601:	8b 00                	mov    (%eax),%eax
80104603:	85 c0                	test   %eax,%eax
80104605:	75 e2                	jne    801045e9 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104607:	8b 45 08             	mov    0x8(%ebp),%eax
8010460a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104610:	e8 1b f4 ff ff       	call   80103a30 <myproc>
80104615:	8b 50 10             	mov    0x10(%eax),%edx
80104618:	8b 45 08             	mov    0x8(%ebp),%eax
8010461b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010461e:	8b 45 08             	mov    0x8(%ebp),%eax
80104621:	83 c0 04             	add    $0x4,%eax
80104624:	83 ec 0c             	sub    $0xc,%esp
80104627:	50                   	push   %eax
80104628:	e8 53 01 00 00       	call   80104780 <release>
8010462d:	83 c4 10             	add    $0x10,%esp
}
80104630:	90                   	nop
80104631:	c9                   	leave
80104632:	c3                   	ret

80104633 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104633:	55                   	push   %ebp
80104634:	89 e5                	mov    %esp,%ebp
80104636:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104639:	8b 45 08             	mov    0x8(%ebp),%eax
8010463c:	83 c0 04             	add    $0x4,%eax
8010463f:	83 ec 0c             	sub    $0xc,%esp
80104642:	50                   	push   %eax
80104643:	e8 ca 00 00 00       	call   80104712 <acquire>
80104648:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010464b:	8b 45 08             	mov    0x8(%ebp),%eax
8010464e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104654:	8b 45 08             	mov    0x8(%ebp),%eax
80104657:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010465e:	83 ec 0c             	sub    $0xc,%esp
80104661:	ff 75 08             	push   0x8(%ebp)
80104664:	e8 75 fd ff ff       	call   801043de <wakeup>
80104669:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010466c:	8b 45 08             	mov    0x8(%ebp),%eax
8010466f:	83 c0 04             	add    $0x4,%eax
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	50                   	push   %eax
80104676:	e8 05 01 00 00       	call   80104780 <release>
8010467b:	83 c4 10             	add    $0x10,%esp
}
8010467e:	90                   	nop
8010467f:	c9                   	leave
80104680:	c3                   	ret

80104681 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104681:	55                   	push   %ebp
80104682:	89 e5                	mov    %esp,%ebp
80104684:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104687:	8b 45 08             	mov    0x8(%ebp),%eax
8010468a:	83 c0 04             	add    $0x4,%eax
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	50                   	push   %eax
80104691:	e8 7c 00 00 00       	call   80104712 <acquire>
80104696:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104699:	8b 45 08             	mov    0x8(%ebp),%eax
8010469c:	8b 00                	mov    (%eax),%eax
8010469e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801046a1:	8b 45 08             	mov    0x8(%ebp),%eax
801046a4:	83 c0 04             	add    $0x4,%eax
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	50                   	push   %eax
801046ab:	e8 d0 00 00 00       	call   80104780 <release>
801046b0:	83 c4 10             	add    $0x10,%esp
  return r;
801046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046b6:	c9                   	leave
801046b7:	c3                   	ret

801046b8 <readeflags>:
{
801046b8:	55                   	push   %ebp
801046b9:	89 e5                	mov    %esp,%ebp
801046bb:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046be:	9c                   	pushf
801046bf:	58                   	pop    %eax
801046c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046c6:	c9                   	leave
801046c7:	c3                   	ret

801046c8 <cli>:
{
801046c8:	55                   	push   %ebp
801046c9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046cb:	fa                   	cli
}
801046cc:	90                   	nop
801046cd:	5d                   	pop    %ebp
801046ce:	c3                   	ret

801046cf <sti>:
{
801046cf:	55                   	push   %ebp
801046d0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046d2:	fb                   	sti
}
801046d3:	90                   	nop
801046d4:	5d                   	pop    %ebp
801046d5:	c3                   	ret

801046d6 <xchg>:
{
801046d6:	55                   	push   %ebp
801046d7:	89 e5                	mov    %esp,%ebp
801046d9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046dc:	8b 55 08             	mov    0x8(%ebp),%edx
801046df:	8b 45 0c             	mov    0xc(%ebp),%eax
801046e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046e5:	f0 87 02             	lock xchg %eax,(%edx)
801046e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046ee:	c9                   	leave
801046ef:	c3                   	ret

801046f0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046f0:	55                   	push   %ebp
801046f1:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801046f9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801046fc:	8b 45 08             	mov    0x8(%ebp),%eax
801046ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104705:	8b 45 08             	mov    0x8(%ebp),%eax
80104708:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010470f:	90                   	nop
80104710:	5d                   	pop    %ebp
80104711:	c3                   	ret

80104712 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104712:	55                   	push   %ebp
80104713:	89 e5                	mov    %esp,%ebp
80104715:	53                   	push   %ebx
80104716:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104719:	e8 5f 01 00 00       	call   8010487d <pushcli>
  if(holding(lk)){
8010471e:	8b 45 08             	mov    0x8(%ebp),%eax
80104721:	83 ec 0c             	sub    $0xc,%esp
80104724:	50                   	push   %eax
80104725:	e8 23 01 00 00       	call   8010484d <holding>
8010472a:	83 c4 10             	add    $0x10,%esp
8010472d:	85 c0                	test   %eax,%eax
8010472f:	74 0d                	je     8010473e <acquire+0x2c>
    panic("acquire");
80104731:	83 ec 0c             	sub    $0xc,%esp
80104734:	68 4a a3 10 80       	push   $0x8010a34a
80104739:	e8 6b be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010473e:	90                   	nop
8010473f:	8b 45 08             	mov    0x8(%ebp),%eax
80104742:	83 ec 08             	sub    $0x8,%esp
80104745:	6a 01                	push   $0x1
80104747:	50                   	push   %eax
80104748:	e8 89 ff ff ff       	call   801046d6 <xchg>
8010474d:	83 c4 10             	add    $0x10,%esp
80104750:	85 c0                	test   %eax,%eax
80104752:	75 eb                	jne    8010473f <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104754:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104759:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010475c:	e8 57 f2 ff ff       	call   801039b8 <mycpu>
80104761:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104764:	8b 45 08             	mov    0x8(%ebp),%eax
80104767:	83 c0 0c             	add    $0xc,%eax
8010476a:	83 ec 08             	sub    $0x8,%esp
8010476d:	50                   	push   %eax
8010476e:	8d 45 08             	lea    0x8(%ebp),%eax
80104771:	50                   	push   %eax
80104772:	e8 5b 00 00 00       	call   801047d2 <getcallerpcs>
80104777:	83 c4 10             	add    $0x10,%esp
}
8010477a:	90                   	nop
8010477b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010477e:	c9                   	leave
8010477f:	c3                   	ret

80104780 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	ff 75 08             	push   0x8(%ebp)
8010478c:	e8 bc 00 00 00       	call   8010484d <holding>
80104791:	83 c4 10             	add    $0x10,%esp
80104794:	85 c0                	test   %eax,%eax
80104796:	75 0d                	jne    801047a5 <release+0x25>
    panic("release");
80104798:	83 ec 0c             	sub    $0xc,%esp
8010479b:	68 52 a3 10 80       	push   $0x8010a352
801047a0:	e8 04 be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801047a5:	8b 45 08             	mov    0x8(%ebp),%eax
801047a8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047af:	8b 45 08             	mov    0x8(%ebp),%eax
801047b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047b9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047be:	8b 45 08             	mov    0x8(%ebp),%eax
801047c1:	8b 55 08             	mov    0x8(%ebp),%edx
801047c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047ca:	e8 fb 00 00 00       	call   801048ca <popcli>
}
801047cf:	90                   	nop
801047d0:	c9                   	leave
801047d1:	c3                   	ret

801047d2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047d2:	55                   	push   %ebp
801047d3:	89 e5                	mov    %esp,%ebp
801047d5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047d8:	8b 45 08             	mov    0x8(%ebp),%eax
801047db:	83 e8 08             	sub    $0x8,%eax
801047de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047e1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047e8:	eb 38                	jmp    80104822 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047ea:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047ee:	74 53                	je     80104843 <getcallerpcs+0x71>
801047f0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047f7:	76 4a                	jbe    80104843 <getcallerpcs+0x71>
801047f9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801047fd:	74 44                	je     80104843 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801047ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104802:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480c:	01 c2                	add    %eax,%edx
8010480e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104811:	8b 40 04             	mov    0x4(%eax),%eax
80104814:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104816:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104819:	8b 00                	mov    (%eax),%eax
8010481b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010481e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104822:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104826:	7e c2                	jle    801047ea <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104828:	eb 19                	jmp    80104843 <getcallerpcs+0x71>
    pcs[i] = 0;
8010482a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010482d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104834:	8b 45 0c             	mov    0xc(%ebp),%eax
80104837:	01 d0                	add    %edx,%eax
80104839:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010483f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104843:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104847:	7e e1                	jle    8010482a <getcallerpcs+0x58>
}
80104849:	90                   	nop
8010484a:	90                   	nop
8010484b:	c9                   	leave
8010484c:	c3                   	ret

8010484d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010484d:	55                   	push   %ebp
8010484e:	89 e5                	mov    %esp,%ebp
80104850:	53                   	push   %ebx
80104851:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104854:	8b 45 08             	mov    0x8(%ebp),%eax
80104857:	8b 00                	mov    (%eax),%eax
80104859:	85 c0                	test   %eax,%eax
8010485b:	74 16                	je     80104873 <holding+0x26>
8010485d:	8b 45 08             	mov    0x8(%ebp),%eax
80104860:	8b 58 08             	mov    0x8(%eax),%ebx
80104863:	e8 50 f1 ff ff       	call   801039b8 <mycpu>
80104868:	39 c3                	cmp    %eax,%ebx
8010486a:	75 07                	jne    80104873 <holding+0x26>
8010486c:	b8 01 00 00 00       	mov    $0x1,%eax
80104871:	eb 05                	jmp    80104878 <holding+0x2b>
80104873:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010487b:	c9                   	leave
8010487c:	c3                   	ret

8010487d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010487d:	55                   	push   %ebp
8010487e:	89 e5                	mov    %esp,%ebp
80104880:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104883:	e8 30 fe ff ff       	call   801046b8 <readeflags>
80104888:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010488b:	e8 38 fe ff ff       	call   801046c8 <cli>
  if(mycpu()->ncli == 0)
80104890:	e8 23 f1 ff ff       	call   801039b8 <mycpu>
80104895:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010489b:	85 c0                	test   %eax,%eax
8010489d:	75 14                	jne    801048b3 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010489f:	e8 14 f1 ff ff       	call   801039b8 <mycpu>
801048a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a7:	81 e2 00 02 00 00    	and    $0x200,%edx
801048ad:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048b3:	e8 00 f1 ff ff       	call   801039b8 <mycpu>
801048b8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048be:	83 c2 01             	add    $0x1,%edx
801048c1:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048c7:	90                   	nop
801048c8:	c9                   	leave
801048c9:	c3                   	ret

801048ca <popcli>:

void
popcli(void)
{
801048ca:	55                   	push   %ebp
801048cb:	89 e5                	mov    %esp,%ebp
801048cd:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048d0:	e8 e3 fd ff ff       	call   801046b8 <readeflags>
801048d5:	25 00 02 00 00       	and    $0x200,%eax
801048da:	85 c0                	test   %eax,%eax
801048dc:	74 0d                	je     801048eb <popcli+0x21>
    panic("popcli - interruptible");
801048de:	83 ec 0c             	sub    $0xc,%esp
801048e1:	68 5a a3 10 80       	push   $0x8010a35a
801048e6:	e8 be bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048eb:	e8 c8 f0 ff ff       	call   801039b8 <mycpu>
801048f0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048f6:	83 ea 01             	sub    $0x1,%edx
801048f9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801048ff:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104905:	85 c0                	test   %eax,%eax
80104907:	79 0d                	jns    80104916 <popcli+0x4c>
    panic("popcli");
80104909:	83 ec 0c             	sub    $0xc,%esp
8010490c:	68 71 a3 10 80       	push   $0x8010a371
80104911:	e8 93 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104916:	e8 9d f0 ff ff       	call   801039b8 <mycpu>
8010491b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104921:	85 c0                	test   %eax,%eax
80104923:	75 14                	jne    80104939 <popcli+0x6f>
80104925:	e8 8e f0 ff ff       	call   801039b8 <mycpu>
8010492a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104930:	85 c0                	test   %eax,%eax
80104932:	74 05                	je     80104939 <popcli+0x6f>
    sti();
80104934:	e8 96 fd ff ff       	call   801046cf <sti>
}
80104939:	90                   	nop
8010493a:	c9                   	leave
8010493b:	c3                   	ret

8010493c <stosb>:
{
8010493c:	55                   	push   %ebp
8010493d:	89 e5                	mov    %esp,%ebp
8010493f:	57                   	push   %edi
80104940:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104941:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104944:	8b 55 10             	mov    0x10(%ebp),%edx
80104947:	8b 45 0c             	mov    0xc(%ebp),%eax
8010494a:	89 cb                	mov    %ecx,%ebx
8010494c:	89 df                	mov    %ebx,%edi
8010494e:	89 d1                	mov    %edx,%ecx
80104950:	fc                   	cld
80104951:	f3 aa                	rep stos %al,%es:(%edi)
80104953:	89 ca                	mov    %ecx,%edx
80104955:	89 fb                	mov    %edi,%ebx
80104957:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010495a:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010495d:	90                   	nop
8010495e:	5b                   	pop    %ebx
8010495f:	5f                   	pop    %edi
80104960:	5d                   	pop    %ebp
80104961:	c3                   	ret

80104962 <stosl>:
{
80104962:	55                   	push   %ebp
80104963:	89 e5                	mov    %esp,%ebp
80104965:	57                   	push   %edi
80104966:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104967:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010496a:	8b 55 10             	mov    0x10(%ebp),%edx
8010496d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104970:	89 cb                	mov    %ecx,%ebx
80104972:	89 df                	mov    %ebx,%edi
80104974:	89 d1                	mov    %edx,%ecx
80104976:	fc                   	cld
80104977:	f3 ab                	rep stos %eax,%es:(%edi)
80104979:	89 ca                	mov    %ecx,%edx
8010497b:	89 fb                	mov    %edi,%ebx
8010497d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104980:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104983:	90                   	nop
80104984:	5b                   	pop    %ebx
80104985:	5f                   	pop    %edi
80104986:	5d                   	pop    %ebp
80104987:	c3                   	ret

80104988 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104988:	55                   	push   %ebp
80104989:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010498b:	8b 45 08             	mov    0x8(%ebp),%eax
8010498e:	83 e0 03             	and    $0x3,%eax
80104991:	85 c0                	test   %eax,%eax
80104993:	75 43                	jne    801049d8 <memset+0x50>
80104995:	8b 45 10             	mov    0x10(%ebp),%eax
80104998:	83 e0 03             	and    $0x3,%eax
8010499b:	85 c0                	test   %eax,%eax
8010499d:	75 39                	jne    801049d8 <memset+0x50>
    c &= 0xFF;
8010499f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049a6:	8b 45 10             	mov    0x10(%ebp),%eax
801049a9:	c1 e8 02             	shr    $0x2,%eax
801049ac:	89 c1                	mov    %eax,%ecx
801049ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b1:	c1 e0 18             	shl    $0x18,%eax
801049b4:	89 c2                	mov    %eax,%edx
801049b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b9:	c1 e0 10             	shl    $0x10,%eax
801049bc:	09 c2                	or     %eax,%edx
801049be:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c1:	c1 e0 08             	shl    $0x8,%eax
801049c4:	09 d0                	or     %edx,%eax
801049c6:	0b 45 0c             	or     0xc(%ebp),%eax
801049c9:	51                   	push   %ecx
801049ca:	50                   	push   %eax
801049cb:	ff 75 08             	push   0x8(%ebp)
801049ce:	e8 8f ff ff ff       	call   80104962 <stosl>
801049d3:	83 c4 0c             	add    $0xc,%esp
801049d6:	eb 12                	jmp    801049ea <memset+0x62>
  } else
    stosb(dst, c, n);
801049d8:	8b 45 10             	mov    0x10(%ebp),%eax
801049db:	50                   	push   %eax
801049dc:	ff 75 0c             	push   0xc(%ebp)
801049df:	ff 75 08             	push   0x8(%ebp)
801049e2:	e8 55 ff ff ff       	call   8010493c <stosb>
801049e7:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049ed:	c9                   	leave
801049ee:	c3                   	ret

801049ef <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049f5:	8b 45 08             	mov    0x8(%ebp),%eax
801049f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801049fe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104a01:	eb 2e                	jmp    80104a31 <memcmp+0x42>
    if(*s1 != *s2)
80104a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a06:	0f b6 10             	movzbl (%eax),%edx
80104a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a0c:	0f b6 00             	movzbl (%eax),%eax
80104a0f:	38 c2                	cmp    %al,%dl
80104a11:	74 16                	je     80104a29 <memcmp+0x3a>
      return *s1 - *s2;
80104a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a16:	0f b6 00             	movzbl (%eax),%eax
80104a19:	0f b6 d0             	movzbl %al,%edx
80104a1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a1f:	0f b6 00             	movzbl (%eax),%eax
80104a22:	0f b6 c0             	movzbl %al,%eax
80104a25:	29 c2                	sub    %eax,%edx
80104a27:	eb 1a                	jmp    80104a43 <memcmp+0x54>
    s1++, s2++;
80104a29:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a2d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a31:	8b 45 10             	mov    0x10(%ebp),%eax
80104a34:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a37:	89 55 10             	mov    %edx,0x10(%ebp)
80104a3a:	85 c0                	test   %eax,%eax
80104a3c:	75 c5                	jne    80104a03 <memcmp+0x14>
  }

  return 0;
80104a3e:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104a43:	89 d0                	mov    %edx,%eax
80104a45:	c9                   	leave
80104a46:	c3                   	ret

80104a47 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a47:	55                   	push   %ebp
80104a48:	89 e5                	mov    %esp,%ebp
80104a4a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a53:	8b 45 08             	mov    0x8(%ebp),%eax
80104a56:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a59:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a5f:	73 54                	jae    80104ab5 <memmove+0x6e>
80104a61:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a64:	8b 45 10             	mov    0x10(%ebp),%eax
80104a67:	01 d0                	add    %edx,%eax
80104a69:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a6c:	73 47                	jae    80104ab5 <memmove+0x6e>
    s += n;
80104a6e:	8b 45 10             	mov    0x10(%ebp),%eax
80104a71:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a74:	8b 45 10             	mov    0x10(%ebp),%eax
80104a77:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a7a:	eb 13                	jmp    80104a8f <memmove+0x48>
      *--d = *--s;
80104a7c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a80:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a87:	0f b6 10             	movzbl (%eax),%edx
80104a8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a8d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a8f:	8b 45 10             	mov    0x10(%ebp),%eax
80104a92:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a95:	89 55 10             	mov    %edx,0x10(%ebp)
80104a98:	85 c0                	test   %eax,%eax
80104a9a:	75 e0                	jne    80104a7c <memmove+0x35>
  if(s < d && s + n > d){
80104a9c:	eb 24                	jmp    80104ac2 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104a9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104aa1:	8d 42 01             	lea    0x1(%edx),%eax
80104aa4:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104aa7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aaa:	8d 48 01             	lea    0x1(%eax),%ecx
80104aad:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ab0:	0f b6 12             	movzbl (%edx),%edx
80104ab3:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ab5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ab8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104abb:	89 55 10             	mov    %edx,0x10(%ebp)
80104abe:	85 c0                	test   %eax,%eax
80104ac0:	75 dc                	jne    80104a9e <memmove+0x57>

  return dst;
80104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ac5:	c9                   	leave
80104ac6:	c3                   	ret

80104ac7 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ac7:	55                   	push   %ebp
80104ac8:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104aca:	ff 75 10             	push   0x10(%ebp)
80104acd:	ff 75 0c             	push   0xc(%ebp)
80104ad0:	ff 75 08             	push   0x8(%ebp)
80104ad3:	e8 6f ff ff ff       	call   80104a47 <memmove>
80104ad8:	83 c4 0c             	add    $0xc,%esp
}
80104adb:	c9                   	leave
80104adc:	c3                   	ret

80104add <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104add:	55                   	push   %ebp
80104ade:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ae0:	eb 0c                	jmp    80104aee <strncmp+0x11>
    n--, p++, q++;
80104ae2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ae6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104aea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104aee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104af2:	74 1a                	je     80104b0e <strncmp+0x31>
80104af4:	8b 45 08             	mov    0x8(%ebp),%eax
80104af7:	0f b6 00             	movzbl (%eax),%eax
80104afa:	84 c0                	test   %al,%al
80104afc:	74 10                	je     80104b0e <strncmp+0x31>
80104afe:	8b 45 08             	mov    0x8(%ebp),%eax
80104b01:	0f b6 10             	movzbl (%eax),%edx
80104b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b07:	0f b6 00             	movzbl (%eax),%eax
80104b0a:	38 c2                	cmp    %al,%dl
80104b0c:	74 d4                	je     80104ae2 <strncmp+0x5>
  if(n == 0)
80104b0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b12:	75 07                	jne    80104b1b <strncmp+0x3e>
    return 0;
80104b14:	ba 00 00 00 00       	mov    $0x0,%edx
80104b19:	eb 14                	jmp    80104b2f <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1e:	0f b6 00             	movzbl (%eax),%eax
80104b21:	0f b6 d0             	movzbl %al,%edx
80104b24:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b27:	0f b6 00             	movzbl (%eax),%eax
80104b2a:	0f b6 c0             	movzbl %al,%eax
80104b2d:	29 c2                	sub    %eax,%edx
}
80104b2f:	89 d0                	mov    %edx,%eax
80104b31:	5d                   	pop    %ebp
80104b32:	c3                   	ret

80104b33 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b33:	55                   	push   %ebp
80104b34:	89 e5                	mov    %esp,%ebp
80104b36:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b39:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b3f:	90                   	nop
80104b40:	8b 45 10             	mov    0x10(%ebp),%eax
80104b43:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b46:	89 55 10             	mov    %edx,0x10(%ebp)
80104b49:	85 c0                	test   %eax,%eax
80104b4b:	7e 2c                	jle    80104b79 <strncpy+0x46>
80104b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b50:	8d 42 01             	lea    0x1(%edx),%eax
80104b53:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b56:	8b 45 08             	mov    0x8(%ebp),%eax
80104b59:	8d 48 01             	lea    0x1(%eax),%ecx
80104b5c:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b5f:	0f b6 12             	movzbl (%edx),%edx
80104b62:	88 10                	mov    %dl,(%eax)
80104b64:	0f b6 00             	movzbl (%eax),%eax
80104b67:	84 c0                	test   %al,%al
80104b69:	75 d5                	jne    80104b40 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b6b:	eb 0c                	jmp    80104b79 <strncpy+0x46>
    *s++ = 0;
80104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b70:	8d 50 01             	lea    0x1(%eax),%edx
80104b73:	89 55 08             	mov    %edx,0x8(%ebp)
80104b76:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b79:	8b 45 10             	mov    0x10(%ebp),%eax
80104b7c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b7f:	89 55 10             	mov    %edx,0x10(%ebp)
80104b82:	85 c0                	test   %eax,%eax
80104b84:	7f e7                	jg     80104b6d <strncpy+0x3a>
  return os;
80104b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b89:	c9                   	leave
80104b8a:	c3                   	ret

80104b8b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b8b:	55                   	push   %ebp
80104b8c:	89 e5                	mov    %esp,%ebp
80104b8e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b91:	8b 45 08             	mov    0x8(%ebp),%eax
80104b94:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b9b:	7f 05                	jg     80104ba2 <safestrcpy+0x17>
    return os;
80104b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba0:	eb 32                	jmp    80104bd4 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ba2:	90                   	nop
80104ba3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ba7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bab:	7e 1e                	jle    80104bcb <safestrcpy+0x40>
80104bad:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bb0:	8d 42 01             	lea    0x1(%edx),%eax
80104bb3:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb9:	8d 48 01             	lea    0x1(%eax),%ecx
80104bbc:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bbf:	0f b6 12             	movzbl (%edx),%edx
80104bc2:	88 10                	mov    %dl,(%eax)
80104bc4:	0f b6 00             	movzbl (%eax),%eax
80104bc7:	84 c0                	test   %al,%al
80104bc9:	75 d8                	jne    80104ba3 <safestrcpy+0x18>
    ;
  *s = 0;
80104bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bce:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bd4:	c9                   	leave
80104bd5:	c3                   	ret

80104bd6 <strlen>:

int
strlen(const char *s)
{
80104bd6:	55                   	push   %ebp
80104bd7:	89 e5                	mov    %esp,%ebp
80104bd9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104be3:	eb 04                	jmp    80104be9 <strlen+0x13>
80104be5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104be9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bec:	8b 45 08             	mov    0x8(%ebp),%eax
80104bef:	01 d0                	add    %edx,%eax
80104bf1:	0f b6 00             	movzbl (%eax),%eax
80104bf4:	84 c0                	test   %al,%al
80104bf6:	75 ed                	jne    80104be5 <strlen+0xf>
    ;
  return n;
80104bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bfb:	c9                   	leave
80104bfc:	c3                   	ret

80104bfd <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104bfd:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c01:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104c05:	55                   	push   %ebp
  pushl %ebx
80104c06:	53                   	push   %ebx
  pushl %esi
80104c07:	56                   	push   %esi
  pushl %edi
80104c08:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c09:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c0b:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c0d:	5f                   	pop    %edi
  popl %esi
80104c0e:	5e                   	pop    %esi
  popl %ebx
80104c0f:	5b                   	pop    %ebx
  popl %ebp
80104c10:	5d                   	pop    %ebp
  ret
80104c11:	c3                   	ret

80104c12 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c12:	55                   	push   %ebp
80104c13:	89 e5                	mov    %esp,%ebp
80104c15:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c18:	e8 13 ee ff ff       	call   80103a30 <myproc>
80104c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	8b 00                	mov    (%eax),%eax
80104c25:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c28:	73 0f                	jae    80104c39 <fetchint+0x27>
80104c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2d:	8d 50 04             	lea    0x4(%eax),%edx
80104c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c33:	8b 00                	mov    (%eax),%eax
80104c35:	39 d0                	cmp    %edx,%eax
80104c37:	73 07                	jae    80104c40 <fetchint+0x2e>
    return -1;
80104c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c3e:	eb 0f                	jmp    80104c4f <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	8b 10                	mov    (%eax),%edx
80104c45:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c48:	89 10                	mov    %edx,(%eax)
  return 0;
80104c4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c4f:	c9                   	leave
80104c50:	c3                   	ret

80104c51 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c57:	e8 d4 ed ff ff       	call   80103a30 <myproc>
80104c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c62:	8b 00                	mov    (%eax),%eax
80104c64:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c67:	72 07                	jb     80104c70 <fetchstr+0x1f>
    return -1;
80104c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6e:	eb 41                	jmp    80104cb1 <fetchstr+0x60>
  *pp = (char*)addr;
80104c70:	8b 55 08             	mov    0x8(%ebp),%edx
80104c73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c76:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7b:	8b 00                	mov    (%eax),%eax
80104c7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c80:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c83:	8b 00                	mov    (%eax),%eax
80104c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c88:	eb 1a                	jmp    80104ca4 <fetchstr+0x53>
    if(*s == 0)
80104c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8d:	0f b6 00             	movzbl (%eax),%eax
80104c90:	84 c0                	test   %al,%al
80104c92:	75 0c                	jne    80104ca0 <fetchstr+0x4f>
      return s - *pp;
80104c94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c97:	8b 10                	mov    (%eax),%edx
80104c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9c:	29 d0                	sub    %edx,%eax
80104c9e:	eb 11                	jmp    80104cb1 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104ca0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104caa:	72 de                	jb     80104c8a <fetchstr+0x39>
  }
  return -1;
80104cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb1:	c9                   	leave
80104cb2:	c3                   	ret

80104cb3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cb3:	55                   	push   %ebp
80104cb4:	89 e5                	mov    %esp,%ebp
80104cb6:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cb9:	e8 72 ed ff ff       	call   80103a30 <myproc>
80104cbe:	8b 40 18             	mov    0x18(%eax),%eax
80104cc1:	8b 40 44             	mov    0x44(%eax),%eax
80104cc4:	8b 55 08             	mov    0x8(%ebp),%edx
80104cc7:	c1 e2 02             	shl    $0x2,%edx
80104cca:	01 d0                	add    %edx,%eax
80104ccc:	83 c0 04             	add    $0x4,%eax
80104ccf:	83 ec 08             	sub    $0x8,%esp
80104cd2:	ff 75 0c             	push   0xc(%ebp)
80104cd5:	50                   	push   %eax
80104cd6:	e8 37 ff ff ff       	call   80104c12 <fetchint>
80104cdb:	83 c4 10             	add    $0x10,%esp
}
80104cde:	c9                   	leave
80104cdf:	c3                   	ret

80104ce0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104ce6:	e8 45 ed ff ff       	call   80103a30 <myproc>
80104ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104cee:	83 ec 08             	sub    $0x8,%esp
80104cf1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cf4:	50                   	push   %eax
80104cf5:	ff 75 08             	push   0x8(%ebp)
80104cf8:	e8 b6 ff ff ff       	call   80104cb3 <argint>
80104cfd:	83 c4 10             	add    $0x10,%esp
80104d00:	85 c0                	test   %eax,%eax
80104d02:	79 07                	jns    80104d0b <argptr+0x2b>
    return -1;
80104d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d09:	eb 3b                	jmp    80104d46 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d0f:	78 1f                	js     80104d30 <argptr+0x50>
80104d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d14:	8b 00                	mov    (%eax),%eax
80104d16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d19:	39 c2                	cmp    %eax,%edx
80104d1b:	73 13                	jae    80104d30 <argptr+0x50>
80104d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d20:	89 c2                	mov    %eax,%edx
80104d22:	8b 45 10             	mov    0x10(%ebp),%eax
80104d25:	01 c2                	add    %eax,%edx
80104d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2a:	8b 00                	mov    (%eax),%eax
80104d2c:	39 d0                	cmp    %edx,%eax
80104d2e:	73 07                	jae    80104d37 <argptr+0x57>
    return -1;
80104d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d35:	eb 0f                	jmp    80104d46 <argptr+0x66>
  *pp = (char*)i;
80104d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3a:	89 c2                	mov    %eax,%edx
80104d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3f:	89 10                	mov    %edx,(%eax)
  return 0;
80104d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d46:	c9                   	leave
80104d47:	c3                   	ret

80104d48 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
80104d4b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d4e:	83 ec 08             	sub    $0x8,%esp
80104d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d54:	50                   	push   %eax
80104d55:	ff 75 08             	push   0x8(%ebp)
80104d58:	e8 56 ff ff ff       	call   80104cb3 <argint>
80104d5d:	83 c4 10             	add    $0x10,%esp
80104d60:	85 c0                	test   %eax,%eax
80104d62:	79 07                	jns    80104d6b <argstr+0x23>
    return -1;
80104d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d69:	eb 12                	jmp    80104d7d <argstr+0x35>
  return fetchstr(addr, pp);
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	83 ec 08             	sub    $0x8,%esp
80104d71:	ff 75 0c             	push   0xc(%ebp)
80104d74:	50                   	push   %eax
80104d75:	e8 d7 fe ff ff       	call   80104c51 <fetchstr>
80104d7a:	83 c4 10             	add    $0x10,%esp
}
80104d7d:	c9                   	leave
80104d7e:	c3                   	ret

80104d7f <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104d7f:	55                   	push   %ebp
80104d80:	89 e5                	mov    %esp,%ebp
80104d82:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d85:	e8 a6 ec ff ff       	call   80103a30 <myproc>
80104d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d90:	8b 40 18             	mov    0x18(%eax),%eax
80104d93:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d96:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d9d:	7e 2f                	jle    80104dce <syscall+0x4f>
80104d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da2:	83 f8 16             	cmp    $0x16,%eax
80104da5:	77 27                	ja     80104dce <syscall+0x4f>
80104da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daa:	8b 04 85 20 e0 10 80 	mov    -0x7fef1fe0(,%eax,4),%eax
80104db1:	85 c0                	test   %eax,%eax
80104db3:	74 19                	je     80104dce <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db8:	8b 04 85 20 e0 10 80 	mov    -0x7fef1fe0(,%eax,4),%eax
80104dbf:	ff d0                	call   *%eax
80104dc1:	89 c2                	mov    %eax,%edx
80104dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc6:	8b 40 18             	mov    0x18(%eax),%eax
80104dc9:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dcc:	eb 2c                	jmp    80104dfa <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd7:	8b 40 10             	mov    0x10(%eax),%eax
80104dda:	ff 75 f0             	push   -0x10(%ebp)
80104ddd:	52                   	push   %edx
80104dde:	50                   	push   %eax
80104ddf:	68 78 a3 10 80       	push   $0x8010a378
80104de4:	e8 0b b6 ff ff       	call   801003f4 <cprintf>
80104de9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104def:	8b 40 18             	mov    0x18(%eax),%eax
80104df2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104df9:	90                   	nop
80104dfa:	90                   	nop
80104dfb:	c9                   	leave
80104dfc:	c3                   	ret

80104dfd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
80104e00:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104e03:	83 ec 08             	sub    $0x8,%esp
80104e06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e09:	50                   	push   %eax
80104e0a:	ff 75 08             	push   0x8(%ebp)
80104e0d:	e8 a1 fe ff ff       	call   80104cb3 <argint>
80104e12:	83 c4 10             	add    $0x10,%esp
80104e15:	85 c0                	test   %eax,%eax
80104e17:	79 07                	jns    80104e20 <argfd+0x23>
    return -1;
80104e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e1e:	eb 4f                	jmp    80104e6f <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e23:	85 c0                	test   %eax,%eax
80104e25:	78 20                	js     80104e47 <argfd+0x4a>
80104e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2a:	83 f8 0f             	cmp    $0xf,%eax
80104e2d:	7f 18                	jg     80104e47 <argfd+0x4a>
80104e2f:	e8 fc eb ff ff       	call   80103a30 <myproc>
80104e34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e37:	83 c2 08             	add    $0x8,%edx
80104e3a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e45:	75 07                	jne    80104e4e <argfd+0x51>
    return -1;
80104e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4c:	eb 21                	jmp    80104e6f <argfd+0x72>
  if(pfd)
80104e4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e52:	74 08                	je     80104e5c <argfd+0x5f>
    *pfd = fd;
80104e54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5a:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e60:	74 08                	je     80104e6a <argfd+0x6d>
    *pf = f;
80104e62:	8b 45 10             	mov    0x10(%ebp),%eax
80104e65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e68:	89 10                	mov    %edx,(%eax)
  return 0;
80104e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e6f:	c9                   	leave
80104e70:	c3                   	ret

80104e71 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e71:	55                   	push   %ebp
80104e72:	89 e5                	mov    %esp,%ebp
80104e74:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e77:	e8 b4 eb ff ff       	call   80103a30 <myproc>
80104e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e86:	eb 2a                	jmp    80104eb2 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e8e:	83 c2 08             	add    $0x8,%edx
80104e91:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e95:	85 c0                	test   %eax,%eax
80104e97:	75 15                	jne    80104eae <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e9f:	8d 4a 08             	lea    0x8(%edx),%ecx
80104ea2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ea5:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eac:	eb 0f                	jmp    80104ebd <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104eae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eb2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eb6:	7e d0                	jle    80104e88 <fdalloc+0x17>
    }
  }
  return -1;
80104eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ebd:	c9                   	leave
80104ebe:	c3                   	ret

80104ebf <sys_dup>:

int
sys_dup(void)
{
80104ebf:	55                   	push   %ebp
80104ec0:	89 e5                	mov    %esp,%ebp
80104ec2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ec5:	83 ec 04             	sub    $0x4,%esp
80104ec8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ecb:	50                   	push   %eax
80104ecc:	6a 00                	push   $0x0
80104ece:	6a 00                	push   $0x0
80104ed0:	e8 28 ff ff ff       	call   80104dfd <argfd>
80104ed5:	83 c4 10             	add    $0x10,%esp
80104ed8:	85 c0                	test   %eax,%eax
80104eda:	79 07                	jns    80104ee3 <sys_dup+0x24>
    return -1;
80104edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee1:	eb 31                	jmp    80104f14 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee6:	83 ec 0c             	sub    $0xc,%esp
80104ee9:	50                   	push   %eax
80104eea:	e8 82 ff ff ff       	call   80104e71 <fdalloc>
80104eef:	83 c4 10             	add    $0x10,%esp
80104ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ef5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ef9:	79 07                	jns    80104f02 <sys_dup+0x43>
    return -1;
80104efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f00:	eb 12                	jmp    80104f14 <sys_dup+0x55>
  filedup(f);
80104f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f05:	83 ec 0c             	sub    $0xc,%esp
80104f08:	50                   	push   %eax
80104f09:	e8 46 c1 ff ff       	call   80101054 <filedup>
80104f0e:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f14:	c9                   	leave
80104f15:	c3                   	ret

80104f16 <sys_read>:

int
sys_read(void)
{
80104f16:	55                   	push   %ebp
80104f17:	89 e5                	mov    %esp,%ebp
80104f19:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f1c:	83 ec 04             	sub    $0x4,%esp
80104f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f22:	50                   	push   %eax
80104f23:	6a 00                	push   $0x0
80104f25:	6a 00                	push   $0x0
80104f27:	e8 d1 fe ff ff       	call   80104dfd <argfd>
80104f2c:	83 c4 10             	add    $0x10,%esp
80104f2f:	85 c0                	test   %eax,%eax
80104f31:	78 2e                	js     80104f61 <sys_read+0x4b>
80104f33:	83 ec 08             	sub    $0x8,%esp
80104f36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f39:	50                   	push   %eax
80104f3a:	6a 02                	push   $0x2
80104f3c:	e8 72 fd ff ff       	call   80104cb3 <argint>
80104f41:	83 c4 10             	add    $0x10,%esp
80104f44:	85 c0                	test   %eax,%eax
80104f46:	78 19                	js     80104f61 <sys_read+0x4b>
80104f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4b:	83 ec 04             	sub    $0x4,%esp
80104f4e:	50                   	push   %eax
80104f4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f52:	50                   	push   %eax
80104f53:	6a 01                	push   $0x1
80104f55:	e8 86 fd ff ff       	call   80104ce0 <argptr>
80104f5a:	83 c4 10             	add    $0x10,%esp
80104f5d:	85 c0                	test   %eax,%eax
80104f5f:	79 07                	jns    80104f68 <sys_read+0x52>
    return -1;
80104f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f66:	eb 17                	jmp    80104f7f <sys_read+0x69>
  return fileread(f, p, n);
80104f68:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f71:	83 ec 04             	sub    $0x4,%esp
80104f74:	51                   	push   %ecx
80104f75:	52                   	push   %edx
80104f76:	50                   	push   %eax
80104f77:	e8 68 c2 ff ff       	call   801011e4 <fileread>
80104f7c:	83 c4 10             	add    $0x10,%esp
}
80104f7f:	c9                   	leave
80104f80:	c3                   	ret

80104f81 <sys_write>:

int
sys_write(void)
{
80104f81:	55                   	push   %ebp
80104f82:	89 e5                	mov    %esp,%ebp
80104f84:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f87:	83 ec 04             	sub    $0x4,%esp
80104f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f8d:	50                   	push   %eax
80104f8e:	6a 00                	push   $0x0
80104f90:	6a 00                	push   $0x0
80104f92:	e8 66 fe ff ff       	call   80104dfd <argfd>
80104f97:	83 c4 10             	add    $0x10,%esp
80104f9a:	85 c0                	test   %eax,%eax
80104f9c:	78 2e                	js     80104fcc <sys_write+0x4b>
80104f9e:	83 ec 08             	sub    $0x8,%esp
80104fa1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fa4:	50                   	push   %eax
80104fa5:	6a 02                	push   $0x2
80104fa7:	e8 07 fd ff ff       	call   80104cb3 <argint>
80104fac:	83 c4 10             	add    $0x10,%esp
80104faf:	85 c0                	test   %eax,%eax
80104fb1:	78 19                	js     80104fcc <sys_write+0x4b>
80104fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb6:	83 ec 04             	sub    $0x4,%esp
80104fb9:	50                   	push   %eax
80104fba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fbd:	50                   	push   %eax
80104fbe:	6a 01                	push   $0x1
80104fc0:	e8 1b fd ff ff       	call   80104ce0 <argptr>
80104fc5:	83 c4 10             	add    $0x10,%esp
80104fc8:	85 c0                	test   %eax,%eax
80104fca:	79 07                	jns    80104fd3 <sys_write+0x52>
    return -1;
80104fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd1:	eb 17                	jmp    80104fea <sys_write+0x69>
  return filewrite(f, p, n);
80104fd3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fd6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdc:	83 ec 04             	sub    $0x4,%esp
80104fdf:	51                   	push   %ecx
80104fe0:	52                   	push   %edx
80104fe1:	50                   	push   %eax
80104fe2:	e8 b5 c2 ff ff       	call   8010129c <filewrite>
80104fe7:	83 c4 10             	add    $0x10,%esp
}
80104fea:	c9                   	leave
80104feb:	c3                   	ret

80104fec <sys_close>:

int
sys_close(void)
{
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104ff2:	83 ec 04             	sub    $0x4,%esp
80104ff5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ff8:	50                   	push   %eax
80104ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ffc:	50                   	push   %eax
80104ffd:	6a 00                	push   $0x0
80104fff:	e8 f9 fd ff ff       	call   80104dfd <argfd>
80105004:	83 c4 10             	add    $0x10,%esp
80105007:	85 c0                	test   %eax,%eax
80105009:	79 07                	jns    80105012 <sys_close+0x26>
    return -1;
8010500b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105010:	eb 27                	jmp    80105039 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105012:	e8 19 ea ff ff       	call   80103a30 <myproc>
80105017:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010501a:	83 c2 08             	add    $0x8,%edx
8010501d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105024:	00 
  fileclose(f);
80105025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105028:	83 ec 0c             	sub    $0xc,%esp
8010502b:	50                   	push   %eax
8010502c:	e8 74 c0 ff ff       	call   801010a5 <fileclose>
80105031:	83 c4 10             	add    $0x10,%esp
  return 0;
80105034:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105039:	c9                   	leave
8010503a:	c3                   	ret

8010503b <sys_fstat>:

int
sys_fstat(void)
{
8010503b:	55                   	push   %ebp
8010503c:	89 e5                	mov    %esp,%ebp
8010503e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105041:	83 ec 04             	sub    $0x4,%esp
80105044:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105047:	50                   	push   %eax
80105048:	6a 00                	push   $0x0
8010504a:	6a 00                	push   $0x0
8010504c:	e8 ac fd ff ff       	call   80104dfd <argfd>
80105051:	83 c4 10             	add    $0x10,%esp
80105054:	85 c0                	test   %eax,%eax
80105056:	78 17                	js     8010506f <sys_fstat+0x34>
80105058:	83 ec 04             	sub    $0x4,%esp
8010505b:	6a 14                	push   $0x14
8010505d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105060:	50                   	push   %eax
80105061:	6a 01                	push   $0x1
80105063:	e8 78 fc ff ff       	call   80104ce0 <argptr>
80105068:	83 c4 10             	add    $0x10,%esp
8010506b:	85 c0                	test   %eax,%eax
8010506d:	79 07                	jns    80105076 <sys_fstat+0x3b>
    return -1;
8010506f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105074:	eb 13                	jmp    80105089 <sys_fstat+0x4e>
  return filestat(f, st);
80105076:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507c:	83 ec 08             	sub    $0x8,%esp
8010507f:	52                   	push   %edx
80105080:	50                   	push   %eax
80105081:	e8 07 c1 ff ff       	call   8010118d <filestat>
80105086:	83 c4 10             	add    $0x10,%esp
}
80105089:	c9                   	leave
8010508a:	c3                   	ret

8010508b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010508b:	55                   	push   %ebp
8010508c:	89 e5                	mov    %esp,%ebp
8010508e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105091:	83 ec 08             	sub    $0x8,%esp
80105094:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105097:	50                   	push   %eax
80105098:	6a 00                	push   $0x0
8010509a:	e8 a9 fc ff ff       	call   80104d48 <argstr>
8010509f:	83 c4 10             	add    $0x10,%esp
801050a2:	85 c0                	test   %eax,%eax
801050a4:	78 15                	js     801050bb <sys_link+0x30>
801050a6:	83 ec 08             	sub    $0x8,%esp
801050a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050ac:	50                   	push   %eax
801050ad:	6a 01                	push   $0x1
801050af:	e8 94 fc ff ff       	call   80104d48 <argstr>
801050b4:	83 c4 10             	add    $0x10,%esp
801050b7:	85 c0                	test   %eax,%eax
801050b9:	79 0a                	jns    801050c5 <sys_link+0x3a>
    return -1;
801050bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c0:	e9 68 01 00 00       	jmp    8010522d <sys_link+0x1a2>

  begin_op();
801050c5:	e8 74 df ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
801050ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050cd:	83 ec 0c             	sub    $0xc,%esp
801050d0:	50                   	push   %eax
801050d1:	e8 4f d4 ff ff       	call   80102525 <namei>
801050d6:	83 c4 10             	add    $0x10,%esp
801050d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050e0:	75 0f                	jne    801050f1 <sys_link+0x66>
    end_op();
801050e2:	e8 e3 df ff ff       	call   801030ca <end_op>
    return -1;
801050e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ec:	e9 3c 01 00 00       	jmp    8010522d <sys_link+0x1a2>
  }

  ilock(ip);
801050f1:	83 ec 0c             	sub    $0xc,%esp
801050f4:	ff 75 f4             	push   -0xc(%ebp)
801050f7:	e8 f6 c8 ff ff       	call   801019f2 <ilock>
801050fc:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801050ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105102:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105106:	66 83 f8 01          	cmp    $0x1,%ax
8010510a:	75 1d                	jne    80105129 <sys_link+0x9e>
    iunlockput(ip);
8010510c:	83 ec 0c             	sub    $0xc,%esp
8010510f:	ff 75 f4             	push   -0xc(%ebp)
80105112:	e8 0c cb ff ff       	call   80101c23 <iunlockput>
80105117:	83 c4 10             	add    $0x10,%esp
    end_op();
8010511a:	e8 ab df ff ff       	call   801030ca <end_op>
    return -1;
8010511f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105124:	e9 04 01 00 00       	jmp    8010522d <sys_link+0x1a2>
  }

  ip->nlink++;
80105129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105130:	83 c0 01             	add    $0x1,%eax
80105133:	89 c2                	mov    %eax,%edx
80105135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105138:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010513c:	83 ec 0c             	sub    $0xc,%esp
8010513f:	ff 75 f4             	push   -0xc(%ebp)
80105142:	e8 ce c6 ff ff       	call   80101815 <iupdate>
80105147:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010514a:	83 ec 0c             	sub    $0xc,%esp
8010514d:	ff 75 f4             	push   -0xc(%ebp)
80105150:	e8 b0 c9 ff ff       	call   80101b05 <iunlock>
80105155:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105158:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010515b:	83 ec 08             	sub    $0x8,%esp
8010515e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105161:	52                   	push   %edx
80105162:	50                   	push   %eax
80105163:	e8 d9 d3 ff ff       	call   80102541 <nameiparent>
80105168:	83 c4 10             	add    $0x10,%esp
8010516b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010516e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105172:	74 71                	je     801051e5 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105174:	83 ec 0c             	sub    $0xc,%esp
80105177:	ff 75 f0             	push   -0x10(%ebp)
8010517a:	e8 73 c8 ff ff       	call   801019f2 <ilock>
8010517f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105185:	8b 10                	mov    (%eax),%edx
80105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518a:	8b 00                	mov    (%eax),%eax
8010518c:	39 c2                	cmp    %eax,%edx
8010518e:	75 1d                	jne    801051ad <sys_link+0x122>
80105190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105193:	8b 40 04             	mov    0x4(%eax),%eax
80105196:	83 ec 04             	sub    $0x4,%esp
80105199:	50                   	push   %eax
8010519a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010519d:	50                   	push   %eax
8010519e:	ff 75 f0             	push   -0x10(%ebp)
801051a1:	e8 e8 d0 ff ff       	call   8010228e <dirlink>
801051a6:	83 c4 10             	add    $0x10,%esp
801051a9:	85 c0                	test   %eax,%eax
801051ab:	79 10                	jns    801051bd <sys_link+0x132>
    iunlockput(dp);
801051ad:	83 ec 0c             	sub    $0xc,%esp
801051b0:	ff 75 f0             	push   -0x10(%ebp)
801051b3:	e8 6b ca ff ff       	call   80101c23 <iunlockput>
801051b8:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051bb:	eb 29                	jmp    801051e6 <sys_link+0x15b>
  }
  iunlockput(dp);
801051bd:	83 ec 0c             	sub    $0xc,%esp
801051c0:	ff 75 f0             	push   -0x10(%ebp)
801051c3:	e8 5b ca ff ff       	call   80101c23 <iunlockput>
801051c8:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051cb:	83 ec 0c             	sub    $0xc,%esp
801051ce:	ff 75 f4             	push   -0xc(%ebp)
801051d1:	e8 7d c9 ff ff       	call   80101b53 <iput>
801051d6:	83 c4 10             	add    $0x10,%esp

  end_op();
801051d9:	e8 ec de ff ff       	call   801030ca <end_op>

  return 0;
801051de:	b8 00 00 00 00       	mov    $0x0,%eax
801051e3:	eb 48                	jmp    8010522d <sys_link+0x1a2>
    goto bad;
801051e5:	90                   	nop

bad:
  ilock(ip);
801051e6:	83 ec 0c             	sub    $0xc,%esp
801051e9:	ff 75 f4             	push   -0xc(%ebp)
801051ec:	e8 01 c8 ff ff       	call   801019f2 <ilock>
801051f1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801051f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051fb:	83 e8 01             	sub    $0x1,%eax
801051fe:	89 c2                	mov    %eax,%edx
80105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105203:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105207:	83 ec 0c             	sub    $0xc,%esp
8010520a:	ff 75 f4             	push   -0xc(%ebp)
8010520d:	e8 03 c6 ff ff       	call   80101815 <iupdate>
80105212:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105215:	83 ec 0c             	sub    $0xc,%esp
80105218:	ff 75 f4             	push   -0xc(%ebp)
8010521b:	e8 03 ca ff ff       	call   80101c23 <iunlockput>
80105220:	83 c4 10             	add    $0x10,%esp
  end_op();
80105223:	e8 a2 de ff ff       	call   801030ca <end_op>
  return -1;
80105228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010522d:	c9                   	leave
8010522e:	c3                   	ret

8010522f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010522f:	55                   	push   %ebp
80105230:	89 e5                	mov    %esp,%ebp
80105232:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105235:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010523c:	eb 40                	jmp    8010527e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010523e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105241:	6a 10                	push   $0x10
80105243:	50                   	push   %eax
80105244:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105247:	50                   	push   %eax
80105248:	ff 75 08             	push   0x8(%ebp)
8010524b:	e8 8e cc ff ff       	call   80101ede <readi>
80105250:	83 c4 10             	add    $0x10,%esp
80105253:	83 f8 10             	cmp    $0x10,%eax
80105256:	74 0d                	je     80105265 <isdirempty+0x36>
      panic("isdirempty: readi");
80105258:	83 ec 0c             	sub    $0xc,%esp
8010525b:	68 94 a3 10 80       	push   $0x8010a394
80105260:	e8 44 b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105265:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105269:	66 85 c0             	test   %ax,%ax
8010526c:	74 07                	je     80105275 <isdirempty+0x46>
      return 0;
8010526e:	b8 00 00 00 00       	mov    $0x0,%eax
80105273:	eb 1b                	jmp    80105290 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105278:	83 c0 10             	add    $0x10,%eax
8010527b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010527e:	8b 45 08             	mov    0x8(%ebp),%eax
80105281:	8b 40 58             	mov    0x58(%eax),%eax
80105284:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105287:	39 c2                	cmp    %eax,%edx
80105289:	72 b3                	jb     8010523e <isdirempty+0xf>
  }
  return 1;
8010528b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105290:	c9                   	leave
80105291:	c3                   	ret

80105292 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105292:	55                   	push   %ebp
80105293:	89 e5                	mov    %esp,%ebp
80105295:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105298:	83 ec 08             	sub    $0x8,%esp
8010529b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010529e:	50                   	push   %eax
8010529f:	6a 00                	push   $0x0
801052a1:	e8 a2 fa ff ff       	call   80104d48 <argstr>
801052a6:	83 c4 10             	add    $0x10,%esp
801052a9:	85 c0                	test   %eax,%eax
801052ab:	79 0a                	jns    801052b7 <sys_unlink+0x25>
    return -1;
801052ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b2:	e9 bf 01 00 00       	jmp    80105476 <sys_unlink+0x1e4>

  begin_op();
801052b7:	e8 82 dd ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052bf:	83 ec 08             	sub    $0x8,%esp
801052c2:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052c5:	52                   	push   %edx
801052c6:	50                   	push   %eax
801052c7:	e8 75 d2 ff ff       	call   80102541 <nameiparent>
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d6:	75 0f                	jne    801052e7 <sys_unlink+0x55>
    end_op();
801052d8:	e8 ed dd ff ff       	call   801030ca <end_op>
    return -1;
801052dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e2:	e9 8f 01 00 00       	jmp    80105476 <sys_unlink+0x1e4>
  }

  ilock(dp);
801052e7:	83 ec 0c             	sub    $0xc,%esp
801052ea:	ff 75 f4             	push   -0xc(%ebp)
801052ed:	e8 00 c7 ff ff       	call   801019f2 <ilock>
801052f2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052f5:	83 ec 08             	sub    $0x8,%esp
801052f8:	68 a6 a3 10 80       	push   $0x8010a3a6
801052fd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105300:	50                   	push   %eax
80105301:	e8 b3 ce ff ff       	call   801021b9 <namecmp>
80105306:	83 c4 10             	add    $0x10,%esp
80105309:	85 c0                	test   %eax,%eax
8010530b:	0f 84 49 01 00 00    	je     8010545a <sys_unlink+0x1c8>
80105311:	83 ec 08             	sub    $0x8,%esp
80105314:	68 a8 a3 10 80       	push   $0x8010a3a8
80105319:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010531c:	50                   	push   %eax
8010531d:	e8 97 ce ff ff       	call   801021b9 <namecmp>
80105322:	83 c4 10             	add    $0x10,%esp
80105325:	85 c0                	test   %eax,%eax
80105327:	0f 84 2d 01 00 00    	je     8010545a <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010532d:	83 ec 04             	sub    $0x4,%esp
80105330:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105333:	50                   	push   %eax
80105334:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105337:	50                   	push   %eax
80105338:	ff 75 f4             	push   -0xc(%ebp)
8010533b:	e8 94 ce ff ff       	call   801021d4 <dirlookup>
80105340:	83 c4 10             	add    $0x10,%esp
80105343:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105346:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010534a:	0f 84 0d 01 00 00    	je     8010545d <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105350:	83 ec 0c             	sub    $0xc,%esp
80105353:	ff 75 f0             	push   -0x10(%ebp)
80105356:	e8 97 c6 ff ff       	call   801019f2 <ilock>
8010535b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010535e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105361:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105365:	66 85 c0             	test   %ax,%ax
80105368:	7f 0d                	jg     80105377 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010536a:	83 ec 0c             	sub    $0xc,%esp
8010536d:	68 ab a3 10 80       	push   $0x8010a3ab
80105372:	e8 32 b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010537e:	66 83 f8 01          	cmp    $0x1,%ax
80105382:	75 25                	jne    801053a9 <sys_unlink+0x117>
80105384:	83 ec 0c             	sub    $0xc,%esp
80105387:	ff 75 f0             	push   -0x10(%ebp)
8010538a:	e8 a0 fe ff ff       	call   8010522f <isdirempty>
8010538f:	83 c4 10             	add    $0x10,%esp
80105392:	85 c0                	test   %eax,%eax
80105394:	75 13                	jne    801053a9 <sys_unlink+0x117>
    iunlockput(ip);
80105396:	83 ec 0c             	sub    $0xc,%esp
80105399:	ff 75 f0             	push   -0x10(%ebp)
8010539c:	e8 82 c8 ff ff       	call   80101c23 <iunlockput>
801053a1:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053a4:	e9 b5 00 00 00       	jmp    8010545e <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053a9:	83 ec 04             	sub    $0x4,%esp
801053ac:	6a 10                	push   $0x10
801053ae:	6a 00                	push   $0x0
801053b0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053b3:	50                   	push   %eax
801053b4:	e8 cf f5 ff ff       	call   80104988 <memset>
801053b9:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053bf:	6a 10                	push   $0x10
801053c1:	50                   	push   %eax
801053c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053c5:	50                   	push   %eax
801053c6:	ff 75 f4             	push   -0xc(%ebp)
801053c9:	e8 65 cc ff ff       	call   80102033 <writei>
801053ce:	83 c4 10             	add    $0x10,%esp
801053d1:	83 f8 10             	cmp    $0x10,%eax
801053d4:	74 0d                	je     801053e3 <sys_unlink+0x151>
    panic("unlink: writei");
801053d6:	83 ec 0c             	sub    $0xc,%esp
801053d9:	68 bd a3 10 80       	push   $0x8010a3bd
801053de:	e8 c6 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053ea:	66 83 f8 01          	cmp    $0x1,%ax
801053ee:	75 21                	jne    80105411 <sys_unlink+0x17f>
    dp->nlink--;
801053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053f7:	83 e8 01             	sub    $0x1,%eax
801053fa:	89 c2                	mov    %eax,%edx
801053fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ff:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105403:	83 ec 0c             	sub    $0xc,%esp
80105406:	ff 75 f4             	push   -0xc(%ebp)
80105409:	e8 07 c4 ff ff       	call   80101815 <iupdate>
8010540e:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105411:	83 ec 0c             	sub    $0xc,%esp
80105414:	ff 75 f4             	push   -0xc(%ebp)
80105417:	e8 07 c8 ff ff       	call   80101c23 <iunlockput>
8010541c:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010541f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105422:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105426:	83 e8 01             	sub    $0x1,%eax
80105429:	89 c2                	mov    %eax,%edx
8010542b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105432:	83 ec 0c             	sub    $0xc,%esp
80105435:	ff 75 f0             	push   -0x10(%ebp)
80105438:	e8 d8 c3 ff ff       	call   80101815 <iupdate>
8010543d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105440:	83 ec 0c             	sub    $0xc,%esp
80105443:	ff 75 f0             	push   -0x10(%ebp)
80105446:	e8 d8 c7 ff ff       	call   80101c23 <iunlockput>
8010544b:	83 c4 10             	add    $0x10,%esp

  end_op();
8010544e:	e8 77 dc ff ff       	call   801030ca <end_op>

  return 0;
80105453:	b8 00 00 00 00       	mov    $0x0,%eax
80105458:	eb 1c                	jmp    80105476 <sys_unlink+0x1e4>
    goto bad;
8010545a:	90                   	nop
8010545b:	eb 01                	jmp    8010545e <sys_unlink+0x1cc>
    goto bad;
8010545d:	90                   	nop

bad:
  iunlockput(dp);
8010545e:	83 ec 0c             	sub    $0xc,%esp
80105461:	ff 75 f4             	push   -0xc(%ebp)
80105464:	e8 ba c7 ff ff       	call   80101c23 <iunlockput>
80105469:	83 c4 10             	add    $0x10,%esp
  end_op();
8010546c:	e8 59 dc ff ff       	call   801030ca <end_op>
  return -1;
80105471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105476:	c9                   	leave
80105477:	c3                   	ret

80105478 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	83 ec 38             	sub    $0x38,%esp
8010547e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105481:	8b 55 10             	mov    0x10(%ebp),%edx
80105484:	8b 45 14             	mov    0x14(%ebp),%eax
80105487:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010548b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010548f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105493:	83 ec 08             	sub    $0x8,%esp
80105496:	8d 45 de             	lea    -0x22(%ebp),%eax
80105499:	50                   	push   %eax
8010549a:	ff 75 08             	push   0x8(%ebp)
8010549d:	e8 9f d0 ff ff       	call   80102541 <nameiparent>
801054a2:	83 c4 10             	add    $0x10,%esp
801054a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ac:	75 0a                	jne    801054b8 <create+0x40>
    return 0;
801054ae:	b8 00 00 00 00       	mov    $0x0,%eax
801054b3:	e9 90 01 00 00       	jmp    80105648 <create+0x1d0>
  ilock(dp);
801054b8:	83 ec 0c             	sub    $0xc,%esp
801054bb:	ff 75 f4             	push   -0xc(%ebp)
801054be:	e8 2f c5 ff ff       	call   801019f2 <ilock>
801054c3:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054c6:	83 ec 04             	sub    $0x4,%esp
801054c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054cc:	50                   	push   %eax
801054cd:	8d 45 de             	lea    -0x22(%ebp),%eax
801054d0:	50                   	push   %eax
801054d1:	ff 75 f4             	push   -0xc(%ebp)
801054d4:	e8 fb cc ff ff       	call   801021d4 <dirlookup>
801054d9:	83 c4 10             	add    $0x10,%esp
801054dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054e3:	74 50                	je     80105535 <create+0xbd>
    iunlockput(dp);
801054e5:	83 ec 0c             	sub    $0xc,%esp
801054e8:	ff 75 f4             	push   -0xc(%ebp)
801054eb:	e8 33 c7 ff ff       	call   80101c23 <iunlockput>
801054f0:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801054f3:	83 ec 0c             	sub    $0xc,%esp
801054f6:	ff 75 f0             	push   -0x10(%ebp)
801054f9:	e8 f4 c4 ff ff       	call   801019f2 <ilock>
801054fe:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105501:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105506:	75 15                	jne    8010551d <create+0xa5>
80105508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010550f:	66 83 f8 02          	cmp    $0x2,%ax
80105513:	75 08                	jne    8010551d <create+0xa5>
      return ip;
80105515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105518:	e9 2b 01 00 00       	jmp    80105648 <create+0x1d0>
    iunlockput(ip);
8010551d:	83 ec 0c             	sub    $0xc,%esp
80105520:	ff 75 f0             	push   -0x10(%ebp)
80105523:	e8 fb c6 ff ff       	call   80101c23 <iunlockput>
80105528:	83 c4 10             	add    $0x10,%esp
    return 0;
8010552b:	b8 00 00 00 00       	mov    $0x0,%eax
80105530:	e9 13 01 00 00       	jmp    80105648 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105535:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553c:	8b 00                	mov    (%eax),%eax
8010553e:	83 ec 08             	sub    $0x8,%esp
80105541:	52                   	push   %edx
80105542:	50                   	push   %eax
80105543:	e8 f7 c1 ff ff       	call   8010173f <ialloc>
80105548:	83 c4 10             	add    $0x10,%esp
8010554b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010554e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105552:	75 0d                	jne    80105561 <create+0xe9>
    panic("create: ialloc");
80105554:	83 ec 0c             	sub    $0xc,%esp
80105557:	68 cc a3 10 80       	push   $0x8010a3cc
8010555c:	e8 48 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105561:	83 ec 0c             	sub    $0xc,%esp
80105564:	ff 75 f0             	push   -0x10(%ebp)
80105567:	e8 86 c4 ff ff       	call   801019f2 <ilock>
8010556c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010556f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105572:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105576:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010557a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105581:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105588:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010558e:	83 ec 0c             	sub    $0xc,%esp
80105591:	ff 75 f0             	push   -0x10(%ebp)
80105594:	e8 7c c2 ff ff       	call   80101815 <iupdate>
80105599:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010559c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801055a1:	75 6a                	jne    8010560d <create+0x195>
    dp->nlink++;  // for ".."
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055aa:	83 c0 01             	add    $0x1,%eax
801055ad:	89 c2                	mov    %eax,%edx
801055af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b2:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055b6:	83 ec 0c             	sub    $0xc,%esp
801055b9:	ff 75 f4             	push   -0xc(%ebp)
801055bc:	e8 54 c2 ff ff       	call   80101815 <iupdate>
801055c1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c7:	8b 40 04             	mov    0x4(%eax),%eax
801055ca:	83 ec 04             	sub    $0x4,%esp
801055cd:	50                   	push   %eax
801055ce:	68 a6 a3 10 80       	push   $0x8010a3a6
801055d3:	ff 75 f0             	push   -0x10(%ebp)
801055d6:	e8 b3 cc ff ff       	call   8010228e <dirlink>
801055db:	83 c4 10             	add    $0x10,%esp
801055de:	85 c0                	test   %eax,%eax
801055e0:	78 1e                	js     80105600 <create+0x188>
801055e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e5:	8b 40 04             	mov    0x4(%eax),%eax
801055e8:	83 ec 04             	sub    $0x4,%esp
801055eb:	50                   	push   %eax
801055ec:	68 a8 a3 10 80       	push   $0x8010a3a8
801055f1:	ff 75 f0             	push   -0x10(%ebp)
801055f4:	e8 95 cc ff ff       	call   8010228e <dirlink>
801055f9:	83 c4 10             	add    $0x10,%esp
801055fc:	85 c0                	test   %eax,%eax
801055fe:	79 0d                	jns    8010560d <create+0x195>
      panic("create dots");
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	68 db a3 10 80       	push   $0x8010a3db
80105608:	e8 9c af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010560d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105610:	8b 40 04             	mov    0x4(%eax),%eax
80105613:	83 ec 04             	sub    $0x4,%esp
80105616:	50                   	push   %eax
80105617:	8d 45 de             	lea    -0x22(%ebp),%eax
8010561a:	50                   	push   %eax
8010561b:	ff 75 f4             	push   -0xc(%ebp)
8010561e:	e8 6b cc ff ff       	call   8010228e <dirlink>
80105623:	83 c4 10             	add    $0x10,%esp
80105626:	85 c0                	test   %eax,%eax
80105628:	79 0d                	jns    80105637 <create+0x1bf>
    panic("create: dirlink");
8010562a:	83 ec 0c             	sub    $0xc,%esp
8010562d:	68 e7 a3 10 80       	push   $0x8010a3e7
80105632:	e8 72 af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105637:	83 ec 0c             	sub    $0xc,%esp
8010563a:	ff 75 f4             	push   -0xc(%ebp)
8010563d:	e8 e1 c5 ff ff       	call   80101c23 <iunlockput>
80105642:	83 c4 10             	add    $0x10,%esp

  return ip;
80105645:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105648:	c9                   	leave
80105649:	c3                   	ret

8010564a <sys_open>:

int
sys_open(void)
{
8010564a:	55                   	push   %ebp
8010564b:	89 e5                	mov    %esp,%ebp
8010564d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105650:	83 ec 08             	sub    $0x8,%esp
80105653:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105656:	50                   	push   %eax
80105657:	6a 00                	push   $0x0
80105659:	e8 ea f6 ff ff       	call   80104d48 <argstr>
8010565e:	83 c4 10             	add    $0x10,%esp
80105661:	85 c0                	test   %eax,%eax
80105663:	78 15                	js     8010567a <sys_open+0x30>
80105665:	83 ec 08             	sub    $0x8,%esp
80105668:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010566b:	50                   	push   %eax
8010566c:	6a 01                	push   $0x1
8010566e:	e8 40 f6 ff ff       	call   80104cb3 <argint>
80105673:	83 c4 10             	add    $0x10,%esp
80105676:	85 c0                	test   %eax,%eax
80105678:	79 0a                	jns    80105684 <sys_open+0x3a>
    return -1;
8010567a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567f:	e9 61 01 00 00       	jmp    801057e5 <sys_open+0x19b>

  begin_op();
80105684:	e8 b5 d9 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010568c:	25 00 02 00 00       	and    $0x200,%eax
80105691:	85 c0                	test   %eax,%eax
80105693:	74 2a                	je     801056bf <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105695:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105698:	6a 00                	push   $0x0
8010569a:	6a 00                	push   $0x0
8010569c:	6a 02                	push   $0x2
8010569e:	50                   	push   %eax
8010569f:	e8 d4 fd ff ff       	call   80105478 <create>
801056a4:	83 c4 10             	add    $0x10,%esp
801056a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ae:	75 75                	jne    80105725 <sys_open+0xdb>
      end_op();
801056b0:	e8 15 da ff ff       	call   801030ca <end_op>
      return -1;
801056b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ba:	e9 26 01 00 00       	jmp    801057e5 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056c2:	83 ec 0c             	sub    $0xc,%esp
801056c5:	50                   	push   %eax
801056c6:	e8 5a ce ff ff       	call   80102525 <namei>
801056cb:	83 c4 10             	add    $0x10,%esp
801056ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d5:	75 0f                	jne    801056e6 <sys_open+0x9c>
      end_op();
801056d7:	e8 ee d9 ff ff       	call   801030ca <end_op>
      return -1;
801056dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e1:	e9 ff 00 00 00       	jmp    801057e5 <sys_open+0x19b>
    }
    ilock(ip);
801056e6:	83 ec 0c             	sub    $0xc,%esp
801056e9:	ff 75 f4             	push   -0xc(%ebp)
801056ec:	e8 01 c3 ff ff       	call   801019f2 <ilock>
801056f1:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056fb:	66 83 f8 01          	cmp    $0x1,%ax
801056ff:	75 24                	jne    80105725 <sys_open+0xdb>
80105701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105704:	85 c0                	test   %eax,%eax
80105706:	74 1d                	je     80105725 <sys_open+0xdb>
      iunlockput(ip);
80105708:	83 ec 0c             	sub    $0xc,%esp
8010570b:	ff 75 f4             	push   -0xc(%ebp)
8010570e:	e8 10 c5 ff ff       	call   80101c23 <iunlockput>
80105713:	83 c4 10             	add    $0x10,%esp
      end_op();
80105716:	e8 af d9 ff ff       	call   801030ca <end_op>
      return -1;
8010571b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105720:	e9 c0 00 00 00       	jmp    801057e5 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105725:	e8 bd b8 ff ff       	call   80100fe7 <filealloc>
8010572a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010572d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105731:	74 17                	je     8010574a <sys_open+0x100>
80105733:	83 ec 0c             	sub    $0xc,%esp
80105736:	ff 75 f0             	push   -0x10(%ebp)
80105739:	e8 33 f7 ff ff       	call   80104e71 <fdalloc>
8010573e:	83 c4 10             	add    $0x10,%esp
80105741:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105744:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105748:	79 2e                	jns    80105778 <sys_open+0x12e>
    if(f)
8010574a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010574e:	74 0e                	je     8010575e <sys_open+0x114>
      fileclose(f);
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	ff 75 f0             	push   -0x10(%ebp)
80105756:	e8 4a b9 ff ff       	call   801010a5 <fileclose>
8010575b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	ff 75 f4             	push   -0xc(%ebp)
80105764:	e8 ba c4 ff ff       	call   80101c23 <iunlockput>
80105769:	83 c4 10             	add    $0x10,%esp
    end_op();
8010576c:	e8 59 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105771:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105776:	eb 6d                	jmp    801057e5 <sys_open+0x19b>
  }
  iunlock(ip);
80105778:	83 ec 0c             	sub    $0xc,%esp
8010577b:	ff 75 f4             	push   -0xc(%ebp)
8010577e:	e8 82 c3 ff ff       	call   80101b05 <iunlock>
80105783:	83 c4 10             	add    $0x10,%esp
  end_op();
80105786:	e8 3f d9 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105797:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010579d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057aa:	83 e0 01             	and    $0x1,%eax
801057ad:	85 c0                	test   %eax,%eax
801057af:	0f 94 c0             	sete   %al
801057b2:	89 c2                	mov    %eax,%edx
801057b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057bd:	83 e0 01             	and    $0x1,%eax
801057c0:	85 c0                	test   %eax,%eax
801057c2:	75 0a                	jne    801057ce <sys_open+0x184>
801057c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c7:	83 e0 02             	and    $0x2,%eax
801057ca:	85 c0                	test   %eax,%eax
801057cc:	74 07                	je     801057d5 <sys_open+0x18b>
801057ce:	b8 01 00 00 00       	mov    $0x1,%eax
801057d3:	eb 05                	jmp    801057da <sys_open+0x190>
801057d5:	b8 00 00 00 00       	mov    $0x0,%eax
801057da:	89 c2                	mov    %eax,%edx
801057dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057df:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057e5:	c9                   	leave
801057e6:	c3                   	ret

801057e7 <sys_mkdir>:

int
sys_mkdir(void)
{
801057e7:	55                   	push   %ebp
801057e8:	89 e5                	mov    %esp,%ebp
801057ea:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057ed:	e8 4c d8 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057f2:	83 ec 08             	sub    $0x8,%esp
801057f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f8:	50                   	push   %eax
801057f9:	6a 00                	push   $0x0
801057fb:	e8 48 f5 ff ff       	call   80104d48 <argstr>
80105800:	83 c4 10             	add    $0x10,%esp
80105803:	85 c0                	test   %eax,%eax
80105805:	78 1b                	js     80105822 <sys_mkdir+0x3b>
80105807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580a:	6a 00                	push   $0x0
8010580c:	6a 00                	push   $0x0
8010580e:	6a 01                	push   $0x1
80105810:	50                   	push   %eax
80105811:	e8 62 fc ff ff       	call   80105478 <create>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105820:	75 0c                	jne    8010582e <sys_mkdir+0x47>
    end_op();
80105822:	e8 a3 d8 ff ff       	call   801030ca <end_op>
    return -1;
80105827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582c:	eb 18                	jmp    80105846 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010582e:	83 ec 0c             	sub    $0xc,%esp
80105831:	ff 75 f4             	push   -0xc(%ebp)
80105834:	e8 ea c3 ff ff       	call   80101c23 <iunlockput>
80105839:	83 c4 10             	add    $0x10,%esp
  end_op();
8010583c:	e8 89 d8 ff ff       	call   801030ca <end_op>
  return 0;
80105841:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105846:	c9                   	leave
80105847:	c3                   	ret

80105848 <sys_mknod>:

int
sys_mknod(void)
{
80105848:	55                   	push   %ebp
80105849:	89 e5                	mov    %esp,%ebp
8010584b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010584e:	e8 eb d7 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105853:	83 ec 08             	sub    $0x8,%esp
80105856:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105859:	50                   	push   %eax
8010585a:	6a 00                	push   $0x0
8010585c:	e8 e7 f4 ff ff       	call   80104d48 <argstr>
80105861:	83 c4 10             	add    $0x10,%esp
80105864:	85 c0                	test   %eax,%eax
80105866:	78 4f                	js     801058b7 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105868:	83 ec 08             	sub    $0x8,%esp
8010586b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010586e:	50                   	push   %eax
8010586f:	6a 01                	push   $0x1
80105871:	e8 3d f4 ff ff       	call   80104cb3 <argint>
80105876:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105879:	85 c0                	test   %eax,%eax
8010587b:	78 3a                	js     801058b7 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010587d:	83 ec 08             	sub    $0x8,%esp
80105880:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105883:	50                   	push   %eax
80105884:	6a 02                	push   $0x2
80105886:	e8 28 f4 ff ff       	call   80104cb3 <argint>
8010588b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010588e:	85 c0                	test   %eax,%eax
80105890:	78 25                	js     801058b7 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105892:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105895:	0f bf c8             	movswl %ax,%ecx
80105898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010589b:	0f bf d0             	movswl %ax,%edx
8010589e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a1:	51                   	push   %ecx
801058a2:	52                   	push   %edx
801058a3:	6a 03                	push   $0x3
801058a5:	50                   	push   %eax
801058a6:	e8 cd fb ff ff       	call   80105478 <create>
801058ab:	83 c4 10             	add    $0x10,%esp
801058ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b5:	75 0c                	jne    801058c3 <sys_mknod+0x7b>
    end_op();
801058b7:	e8 0e d8 ff ff       	call   801030ca <end_op>
    return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c1:	eb 18                	jmp    801058db <sys_mknod+0x93>
  }
  iunlockput(ip);
801058c3:	83 ec 0c             	sub    $0xc,%esp
801058c6:	ff 75 f4             	push   -0xc(%ebp)
801058c9:	e8 55 c3 ff ff       	call   80101c23 <iunlockput>
801058ce:	83 c4 10             	add    $0x10,%esp
  end_op();
801058d1:	e8 f4 d7 ff ff       	call   801030ca <end_op>
  return 0;
801058d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058db:	c9                   	leave
801058dc:	c3                   	ret

801058dd <sys_chdir>:

int
sys_chdir(void)
{
801058dd:	55                   	push   %ebp
801058de:	89 e5                	mov    %esp,%ebp
801058e0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058e3:	e8 48 e1 ff ff       	call   80103a30 <myproc>
801058e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058eb:	e8 4e d7 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058f0:	83 ec 08             	sub    $0x8,%esp
801058f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f6:	50                   	push   %eax
801058f7:	6a 00                	push   $0x0
801058f9:	e8 4a f4 ff ff       	call   80104d48 <argstr>
801058fe:	83 c4 10             	add    $0x10,%esp
80105901:	85 c0                	test   %eax,%eax
80105903:	78 18                	js     8010591d <sys_chdir+0x40>
80105905:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105908:	83 ec 0c             	sub    $0xc,%esp
8010590b:	50                   	push   %eax
8010590c:	e8 14 cc ff ff       	call   80102525 <namei>
80105911:	83 c4 10             	add    $0x10,%esp
80105914:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105917:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010591b:	75 0c                	jne    80105929 <sys_chdir+0x4c>
    end_op();
8010591d:	e8 a8 d7 ff ff       	call   801030ca <end_op>
    return -1;
80105922:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105927:	eb 68                	jmp    80105991 <sys_chdir+0xb4>
  }
  ilock(ip);
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	ff 75 f0             	push   -0x10(%ebp)
8010592f:	e8 be c0 ff ff       	call   801019f2 <ilock>
80105934:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010593e:	66 83 f8 01          	cmp    $0x1,%ax
80105942:	74 1a                	je     8010595e <sys_chdir+0x81>
    iunlockput(ip);
80105944:	83 ec 0c             	sub    $0xc,%esp
80105947:	ff 75 f0             	push   -0x10(%ebp)
8010594a:	e8 d4 c2 ff ff       	call   80101c23 <iunlockput>
8010594f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105952:	e8 73 d7 ff ff       	call   801030ca <end_op>
    return -1;
80105957:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595c:	eb 33                	jmp    80105991 <sys_chdir+0xb4>
  }
  iunlock(ip);
8010595e:	83 ec 0c             	sub    $0xc,%esp
80105961:	ff 75 f0             	push   -0x10(%ebp)
80105964:	e8 9c c1 ff ff       	call   80101b05 <iunlock>
80105969:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010596c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596f:	8b 40 68             	mov    0x68(%eax),%eax
80105972:	83 ec 0c             	sub    $0xc,%esp
80105975:	50                   	push   %eax
80105976:	e8 d8 c1 ff ff       	call   80101b53 <iput>
8010597b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010597e:	e8 47 d7 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105986:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105989:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010598c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105991:	c9                   	leave
80105992:	c3                   	ret

80105993 <sys_exec>:

int
sys_exec(void)
{
80105993:	55                   	push   %ebp
80105994:	89 e5                	mov    %esp,%ebp
80105996:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010599c:	83 ec 08             	sub    $0x8,%esp
8010599f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a2:	50                   	push   %eax
801059a3:	6a 00                	push   $0x0
801059a5:	e8 9e f3 ff ff       	call   80104d48 <argstr>
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	85 c0                	test   %eax,%eax
801059af:	78 18                	js     801059c9 <sys_exec+0x36>
801059b1:	83 ec 08             	sub    $0x8,%esp
801059b4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059ba:	50                   	push   %eax
801059bb:	6a 01                	push   $0x1
801059bd:	e8 f1 f2 ff ff       	call   80104cb3 <argint>
801059c2:	83 c4 10             	add    $0x10,%esp
801059c5:	85 c0                	test   %eax,%eax
801059c7:	79 0a                	jns    801059d3 <sys_exec+0x40>
    return -1;
801059c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ce:	e9 c6 00 00 00       	jmp    80105a99 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059d3:	83 ec 04             	sub    $0x4,%esp
801059d6:	68 80 00 00 00       	push   $0x80
801059db:	6a 00                	push   $0x0
801059dd:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059e3:	50                   	push   %eax
801059e4:	e8 9f ef ff ff       	call   80104988 <memset>
801059e9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f6:	83 f8 1f             	cmp    $0x1f,%eax
801059f9:	76 0a                	jbe    80105a05 <sys_exec+0x72>
      return -1;
801059fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a00:	e9 94 00 00 00       	jmp    80105a99 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a08:	c1 e0 02             	shl    $0x2,%eax
80105a0b:	89 c2                	mov    %eax,%edx
80105a0d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a13:	01 c2                	add    %eax,%edx
80105a15:	83 ec 08             	sub    $0x8,%esp
80105a18:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a1e:	50                   	push   %eax
80105a1f:	52                   	push   %edx
80105a20:	e8 ed f1 ff ff       	call   80104c12 <fetchint>
80105a25:	83 c4 10             	add    $0x10,%esp
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	79 07                	jns    80105a33 <sys_exec+0xa0>
      return -1;
80105a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a31:	eb 66                	jmp    80105a99 <sys_exec+0x106>
    if(uarg == 0){
80105a33:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a39:	85 c0                	test   %eax,%eax
80105a3b:	75 27                	jne    80105a64 <sys_exec+0xd1>
      argv[i] = 0;
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a47:	00 00 00 00 
      break;
80105a4b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4f:	83 ec 08             	sub    $0x8,%esp
80105a52:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a58:	52                   	push   %edx
80105a59:	50                   	push   %eax
80105a5a:	e8 2b b1 ff ff       	call   80100b8a <exec>
80105a5f:	83 c4 10             	add    $0x10,%esp
80105a62:	eb 35                	jmp    80105a99 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a64:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105a6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a6d:	c1 e2 02             	shl    $0x2,%edx
80105a70:	01 c2                	add    %eax,%edx
80105a72:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a78:	83 ec 08             	sub    $0x8,%esp
80105a7b:	52                   	push   %edx
80105a7c:	50                   	push   %eax
80105a7d:	e8 cf f1 ff ff       	call   80104c51 <fetchstr>
80105a82:	83 c4 10             	add    $0x10,%esp
80105a85:	85 c0                	test   %eax,%eax
80105a87:	79 07                	jns    80105a90 <sys_exec+0xfd>
      return -1;
80105a89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8e:	eb 09                	jmp    80105a99 <sys_exec+0x106>
  for(i=0;; i++){
80105a90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a94:	e9 5a ff ff ff       	jmp    801059f3 <sys_exec+0x60>
}
80105a99:	c9                   	leave
80105a9a:	c3                   	ret

80105a9b <sys_pipe>:

int
sys_pipe(void)
{
80105a9b:	55                   	push   %ebp
80105a9c:	89 e5                	mov    %esp,%ebp
80105a9e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105aa1:	83 ec 04             	sub    $0x4,%esp
80105aa4:	6a 08                	push   $0x8
80105aa6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aa9:	50                   	push   %eax
80105aaa:	6a 00                	push   $0x0
80105aac:	e8 2f f2 ff ff       	call   80104ce0 <argptr>
80105ab1:	83 c4 10             	add    $0x10,%esp
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	79 0a                	jns    80105ac2 <sys_pipe+0x27>
    return -1;
80105ab8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abd:	e9 ae 00 00 00       	jmp    80105b70 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ac2:	83 ec 08             	sub    $0x8,%esp
80105ac5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ac8:	50                   	push   %eax
80105ac9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105acc:	50                   	push   %eax
80105acd:	e8 9b da ff ff       	call   8010356d <pipealloc>
80105ad2:	83 c4 10             	add    $0x10,%esp
80105ad5:	85 c0                	test   %eax,%eax
80105ad7:	79 0a                	jns    80105ae3 <sys_pipe+0x48>
    return -1;
80105ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ade:	e9 8d 00 00 00       	jmp    80105b70 <sys_pipe+0xd5>
  fd0 = -1;
80105ae3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105aea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aed:	83 ec 0c             	sub    $0xc,%esp
80105af0:	50                   	push   %eax
80105af1:	e8 7b f3 ff ff       	call   80104e71 <fdalloc>
80105af6:	83 c4 10             	add    $0x10,%esp
80105af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b00:	78 18                	js     80105b1a <sys_pipe+0x7f>
80105b02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	50                   	push   %eax
80105b09:	e8 63 f3 ff ff       	call   80104e71 <fdalloc>
80105b0e:	83 c4 10             	add    $0x10,%esp
80105b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b18:	79 3e                	jns    80105b58 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b1e:	78 13                	js     80105b33 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b20:	e8 0b df ff ff       	call   80103a30 <myproc>
80105b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b28:	83 c2 08             	add    $0x8,%edx
80105b2b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b32:	00 
    fileclose(rf);
80105b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b36:	83 ec 0c             	sub    $0xc,%esp
80105b39:	50                   	push   %eax
80105b3a:	e8 66 b5 ff ff       	call   801010a5 <fileclose>
80105b3f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b45:	83 ec 0c             	sub    $0xc,%esp
80105b48:	50                   	push   %eax
80105b49:	e8 57 b5 ff ff       	call   801010a5 <fileclose>
80105b4e:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b56:	eb 18                	jmp    80105b70 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b5e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b63:	8d 50 04             	lea    0x4(%eax),%edx
80105b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b69:	89 02                	mov    %eax,(%edx)
  return 0;
80105b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b70:	c9                   	leave
80105b71:	c3                   	ret

80105b72 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b72:	55                   	push   %ebp
80105b73:	89 e5                	mov    %esp,%ebp
80105b75:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b78:	e8 b2 e1 ff ff       	call   80103d2f <fork>
}
80105b7d:	c9                   	leave
80105b7e:	c3                   	ret

80105b7f <sys_exit>:

int
sys_exit(void)
{
80105b7f:	55                   	push   %ebp
80105b80:	89 e5                	mov    %esp,%ebp
80105b82:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b85:	e8 1e e3 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b8f:	c9                   	leave
80105b90:	c3                   	ret

80105b91 <sys_wait>:

int
sys_wait(void)
{
80105b91:	55                   	push   %ebp
80105b92:	89 e5                	mov    %esp,%ebp
80105b94:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b97:	e8 2c e4 ff ff       	call   80103fc8 <wait>
}
80105b9c:	c9                   	leave
80105b9d:	c3                   	ret

80105b9e <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105b9e:	55                   	push   %ebp
80105b9f:	89 e5                	mov    %esp,%ebp
80105ba1:	83 ec 18             	sub    $0x18,%esp
    int address;
    if (argint(0, &address) < 0)
80105ba4:	83 ec 08             	sub    $0x8,%esp
80105ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105baa:	50                   	push   %eax
80105bab:	6a 00                	push   $0x0
80105bad:	e8 01 f1 ff ff       	call   80104cb3 <argint>
80105bb2:	83 c4 10             	add    $0x10,%esp
80105bb5:	85 c0                	test   %eax,%eax
80105bb7:	79 07                	jns    80105bc0 <sys_uthread_init+0x22>
        return -1;
80105bb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbe:	eb 0f                	jmp    80105bcf <sys_uthread_init+0x31>
    return uthread_init(address);
80105bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc3:	83 ec 0c             	sub    $0xc,%esp
80105bc6:	50                   	push   %eax
80105bc7:	e8 d4 e5 ff ff       	call   801041a0 <uthread_init>
80105bcc:	83 c4 10             	add    $0x10,%esp
}
80105bcf:	c9                   	leave
80105bd0:	c3                   	ret

80105bd1 <sys_kill>:

int
sys_kill(void)
{
80105bd1:	55                   	push   %ebp
80105bd2:	89 e5                	mov    %esp,%ebp
80105bd4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105bd7:	83 ec 08             	sub    $0x8,%esp
80105bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bdd:	50                   	push   %eax
80105bde:	6a 00                	push   $0x0
80105be0:	e8 ce f0 ff ff       	call   80104cb3 <argint>
80105be5:	83 c4 10             	add    $0x10,%esp
80105be8:	85 c0                	test   %eax,%eax
80105bea:	79 07                	jns    80105bf3 <sys_kill+0x22>
    return -1;
80105bec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf1:	eb 0f                	jmp    80105c02 <sys_kill+0x31>
  return kill(pid);
80105bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf6:	83 ec 0c             	sub    $0xc,%esp
80105bf9:	50                   	push   %eax
80105bfa:	e8 16 e8 ff ff       	call   80104415 <kill>
80105bff:	83 c4 10             	add    $0x10,%esp
}
80105c02:	c9                   	leave
80105c03:	c3                   	ret

80105c04 <sys_getpid>:

int
sys_getpid(void)
{
80105c04:	55                   	push   %ebp
80105c05:	89 e5                	mov    %esp,%ebp
80105c07:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105c0a:	e8 21 de ff ff       	call   80103a30 <myproc>
80105c0f:	8b 40 10             	mov    0x10(%eax),%eax
}
80105c12:	c9                   	leave
80105c13:	c3                   	ret

80105c14 <sys_sbrk>:

int
sys_sbrk(void)
{
80105c14:	55                   	push   %ebp
80105c15:	89 e5                	mov    %esp,%ebp
80105c17:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105c1a:	83 ec 08             	sub    $0x8,%esp
80105c1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c20:	50                   	push   %eax
80105c21:	6a 00                	push   $0x0
80105c23:	e8 8b f0 ff ff       	call   80104cb3 <argint>
80105c28:	83 c4 10             	add    $0x10,%esp
80105c2b:	85 c0                	test   %eax,%eax
80105c2d:	79 07                	jns    80105c36 <sys_sbrk+0x22>
    return -1;
80105c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c34:	eb 27                	jmp    80105c5d <sys_sbrk+0x49>
  addr = myproc()->sz;
80105c36:	e8 f5 dd ff ff       	call   80103a30 <myproc>
80105c3b:	8b 00                	mov    (%eax),%eax
80105c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c43:	83 ec 0c             	sub    $0xc,%esp
80105c46:	50                   	push   %eax
80105c47:	e8 48 e0 ff ff       	call   80103c94 <growproc>
80105c4c:	83 c4 10             	add    $0x10,%esp
80105c4f:	85 c0                	test   %eax,%eax
80105c51:	79 07                	jns    80105c5a <sys_sbrk+0x46>
    return -1;
80105c53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c58:	eb 03                	jmp    80105c5d <sys_sbrk+0x49>
  return addr;
80105c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c5d:	c9                   	leave
80105c5e:	c3                   	ret

80105c5f <sys_sleep>:

int
sys_sleep(void)
{
80105c5f:	55                   	push   %ebp
80105c60:	89 e5                	mov    %esp,%ebp
80105c62:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c65:	83 ec 08             	sub    $0x8,%esp
80105c68:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6b:	50                   	push   %eax
80105c6c:	6a 00                	push   $0x0
80105c6e:	e8 40 f0 ff ff       	call   80104cb3 <argint>
80105c73:	83 c4 10             	add    $0x10,%esp
80105c76:	85 c0                	test   %eax,%eax
80105c78:	79 07                	jns    80105c81 <sys_sleep+0x22>
    return -1;
80105c7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7f:	eb 76                	jmp    80105cf7 <sys_sleep+0x98>
  acquire(&tickslock);
80105c81:	83 ec 0c             	sub    $0xc,%esp
80105c84:	68 40 5a 19 80       	push   $0x80195a40
80105c89:	e8 84 ea ff ff       	call   80104712 <acquire>
80105c8e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c91:	a1 74 5a 19 80       	mov    0x80195a74,%eax
80105c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c99:	eb 38                	jmp    80105cd3 <sys_sleep+0x74>
    if(myproc()->killed){
80105c9b:	e8 90 dd ff ff       	call   80103a30 <myproc>
80105ca0:	8b 40 24             	mov    0x24(%eax),%eax
80105ca3:	85 c0                	test   %eax,%eax
80105ca5:	74 17                	je     80105cbe <sys_sleep+0x5f>
      release(&tickslock);
80105ca7:	83 ec 0c             	sub    $0xc,%esp
80105caa:	68 40 5a 19 80       	push   $0x80195a40
80105caf:	e8 cc ea ff ff       	call   80104780 <release>
80105cb4:	83 c4 10             	add    $0x10,%esp
      return -1;
80105cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbc:	eb 39                	jmp    80105cf7 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105cbe:	83 ec 08             	sub    $0x8,%esp
80105cc1:	68 40 5a 19 80       	push   $0x80195a40
80105cc6:	68 74 5a 19 80       	push   $0x80195a74
80105ccb:	e8 27 e6 ff ff       	call   801042f7 <sleep>
80105cd0:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105cd3:	a1 74 5a 19 80       	mov    0x80195a74,%eax
80105cd8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105cdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cde:	39 d0                	cmp    %edx,%eax
80105ce0:	72 b9                	jb     80105c9b <sys_sleep+0x3c>
  }
  release(&tickslock);
80105ce2:	83 ec 0c             	sub    $0xc,%esp
80105ce5:	68 40 5a 19 80       	push   $0x80195a40
80105cea:	e8 91 ea ff ff       	call   80104780 <release>
80105cef:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf7:	c9                   	leave
80105cf8:	c3                   	ret

80105cf9 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cf9:	55                   	push   %ebp
80105cfa:	89 e5                	mov    %esp,%ebp
80105cfc:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cff:	83 ec 0c             	sub    $0xc,%esp
80105d02:	68 40 5a 19 80       	push   $0x80195a40
80105d07:	e8 06 ea ff ff       	call   80104712 <acquire>
80105d0c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105d0f:	a1 74 5a 19 80       	mov    0x80195a74,%eax
80105d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105d17:	83 ec 0c             	sub    $0xc,%esp
80105d1a:	68 40 5a 19 80       	push   $0x80195a40
80105d1f:	e8 5c ea ff ff       	call   80104780 <release>
80105d24:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2a:	c9                   	leave
80105d2b:	c3                   	ret

80105d2c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d2c:	1e                   	push   %ds
  pushl %es
80105d2d:	06                   	push   %es
  pushl %fs
80105d2e:	0f a0                	push   %fs
  pushl %gs
80105d30:	0f a8                	push   %gs
  pushal
80105d32:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d33:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d37:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d39:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d3b:	54                   	push   %esp
  call trap
80105d3c:	e8 d7 01 00 00       	call   80105f18 <trap>
  addl $4, %esp
80105d41:	83 c4 04             	add    $0x4,%esp

80105d44 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d44:	61                   	popa
  popl %gs
80105d45:	0f a9                	pop    %gs
  popl %fs
80105d47:	0f a1                	pop    %fs
  popl %es
80105d49:	07                   	pop    %es
  popl %ds
80105d4a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d4b:	83 c4 08             	add    $0x8,%esp
  iret
80105d4e:	cf                   	iret

80105d4f <lidt>:
{
80105d4f:	55                   	push   %ebp
80105d50:	89 e5                	mov    %esp,%ebp
80105d52:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d58:	83 e8 01             	sub    $0x1,%eax
80105d5b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80105d62:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d66:	8b 45 08             	mov    0x8(%ebp),%eax
80105d69:	c1 e8 10             	shr    $0x10,%eax
80105d6c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d70:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d73:	0f 01 18             	lidtl  (%eax)
}
80105d76:	90                   	nop
80105d77:	c9                   	leave
80105d78:	c3                   	ret

80105d79 <rcr2>:

static inline uint
rcr2(void)
{
80105d79:	55                   	push   %ebp
80105d7a:	89 e5                	mov    %esp,%ebp
80105d7c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d7f:	0f 20 d0             	mov    %cr2,%eax
80105d82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d88:	c9                   	leave
80105d89:	c3                   	ret

80105d8a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105d90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105d97:	e9 c3 00 00 00       	jmp    80105e5f <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9f:	8b 04 85 7c e0 10 80 	mov    -0x7fef1f84(,%eax,4),%eax
80105da6:	89 c2                	mov    %eax,%edx
80105da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dab:	66 89 14 c5 40 52 19 	mov    %dx,-0x7fe6adc0(,%eax,8)
80105db2:	80 
80105db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db6:	66 c7 04 c5 42 52 19 	movw   $0x8,-0x7fe6adbe(,%eax,8)
80105dbd:	80 08 00 
80105dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc3:	0f b6 14 c5 44 52 19 	movzbl -0x7fe6adbc(,%eax,8),%edx
80105dca:	80 
80105dcb:	83 e2 e0             	and    $0xffffffe0,%edx
80105dce:	88 14 c5 44 52 19 80 	mov    %dl,-0x7fe6adbc(,%eax,8)
80105dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd8:	0f b6 14 c5 44 52 19 	movzbl -0x7fe6adbc(,%eax,8),%edx
80105ddf:	80 
80105de0:	83 e2 1f             	and    $0x1f,%edx
80105de3:	88 14 c5 44 52 19 80 	mov    %dl,-0x7fe6adbc(,%eax,8)
80105dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ded:	0f b6 14 c5 45 52 19 	movzbl -0x7fe6adbb(,%eax,8),%edx
80105df4:	80 
80105df5:	83 e2 f0             	and    $0xfffffff0,%edx
80105df8:	83 ca 0e             	or     $0xe,%edx
80105dfb:	88 14 c5 45 52 19 80 	mov    %dl,-0x7fe6adbb(,%eax,8)
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	0f b6 14 c5 45 52 19 	movzbl -0x7fe6adbb(,%eax,8),%edx
80105e0c:	80 
80105e0d:	83 e2 ef             	and    $0xffffffef,%edx
80105e10:	88 14 c5 45 52 19 80 	mov    %dl,-0x7fe6adbb(,%eax,8)
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	0f b6 14 c5 45 52 19 	movzbl -0x7fe6adbb(,%eax,8),%edx
80105e21:	80 
80105e22:	83 e2 9f             	and    $0xffffff9f,%edx
80105e25:	88 14 c5 45 52 19 80 	mov    %dl,-0x7fe6adbb(,%eax,8)
80105e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2f:	0f b6 14 c5 45 52 19 	movzbl -0x7fe6adbb(,%eax,8),%edx
80105e36:	80 
80105e37:	83 ca 80             	or     $0xffffff80,%edx
80105e3a:	88 14 c5 45 52 19 80 	mov    %dl,-0x7fe6adbb(,%eax,8)
80105e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e44:	8b 04 85 7c e0 10 80 	mov    -0x7fef1f84(,%eax,4),%eax
80105e4b:	c1 e8 10             	shr    $0x10,%eax
80105e4e:	89 c2                	mov    %eax,%edx
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	66 89 14 c5 46 52 19 	mov    %dx,-0x7fe6adba(,%eax,8)
80105e5a:	80 
  for(i = 0; i < 256; i++)
80105e5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e5f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e66:	0f 8e 30 ff ff ff    	jle    80105d9c <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e6c:	a1 7c e1 10 80       	mov    0x8010e17c,%eax
80105e71:	66 a3 40 54 19 80    	mov    %ax,0x80195440
80105e77:	66 c7 05 42 54 19 80 	movw   $0x8,0x80195442
80105e7e:	08 00 
80105e80:	0f b6 05 44 54 19 80 	movzbl 0x80195444,%eax
80105e87:	83 e0 e0             	and    $0xffffffe0,%eax
80105e8a:	a2 44 54 19 80       	mov    %al,0x80195444
80105e8f:	0f b6 05 44 54 19 80 	movzbl 0x80195444,%eax
80105e96:	83 e0 1f             	and    $0x1f,%eax
80105e99:	a2 44 54 19 80       	mov    %al,0x80195444
80105e9e:	0f b6 05 45 54 19 80 	movzbl 0x80195445,%eax
80105ea5:	83 c8 0f             	or     $0xf,%eax
80105ea8:	a2 45 54 19 80       	mov    %al,0x80195445
80105ead:	0f b6 05 45 54 19 80 	movzbl 0x80195445,%eax
80105eb4:	83 e0 ef             	and    $0xffffffef,%eax
80105eb7:	a2 45 54 19 80       	mov    %al,0x80195445
80105ebc:	0f b6 05 45 54 19 80 	movzbl 0x80195445,%eax
80105ec3:	83 c8 60             	or     $0x60,%eax
80105ec6:	a2 45 54 19 80       	mov    %al,0x80195445
80105ecb:	0f b6 05 45 54 19 80 	movzbl 0x80195445,%eax
80105ed2:	83 c8 80             	or     $0xffffff80,%eax
80105ed5:	a2 45 54 19 80       	mov    %al,0x80195445
80105eda:	a1 7c e1 10 80       	mov    0x8010e17c,%eax
80105edf:	c1 e8 10             	shr    $0x10,%eax
80105ee2:	66 a3 46 54 19 80    	mov    %ax,0x80195446

  initlock(&tickslock, "time");
80105ee8:	83 ec 08             	sub    $0x8,%esp
80105eeb:	68 f8 a3 10 80       	push   $0x8010a3f8
80105ef0:	68 40 5a 19 80       	push   $0x80195a40
80105ef5:	e8 f6 e7 ff ff       	call   801046f0 <initlock>
80105efa:	83 c4 10             	add    $0x10,%esp
}
80105efd:	90                   	nop
80105efe:	c9                   	leave
80105eff:	c3                   	ret

80105f00 <idtinit>:

void
idtinit(void)
{
80105f00:	55                   	push   %ebp
80105f01:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f03:	68 00 08 00 00       	push   $0x800
80105f08:	68 40 52 19 80       	push   $0x80195240
80105f0d:	e8 3d fe ff ff       	call   80105d4f <lidt>
80105f12:	83 c4 08             	add    $0x8,%esp
}
80105f15:	90                   	nop
80105f16:	c9                   	leave
80105f17:	c3                   	ret

80105f18 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f18:	55                   	push   %ebp
80105f19:	89 e5                	mov    %esp,%ebp
80105f1b:	57                   	push   %edi
80105f1c:	56                   	push   %esi
80105f1d:	53                   	push   %ebx
80105f1e:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80105f21:	8b 45 08             	mov    0x8(%ebp),%eax
80105f24:	8b 40 30             	mov    0x30(%eax),%eax
80105f27:	83 f8 40             	cmp    $0x40,%eax
80105f2a:	75 3b                	jne    80105f67 <trap+0x4f>
    if(myproc()->killed)
80105f2c:	e8 ff da ff ff       	call   80103a30 <myproc>
80105f31:	8b 40 24             	mov    0x24(%eax),%eax
80105f34:	85 c0                	test   %eax,%eax
80105f36:	74 05                	je     80105f3d <trap+0x25>
      exit();
80105f38:	e8 6b df ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
80105f3d:	e8 ee da ff ff       	call   80103a30 <myproc>
80105f42:	8b 55 08             	mov    0x8(%ebp),%edx
80105f45:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f48:	e8 32 ee ff ff       	call   80104d7f <syscall>
    if(myproc()->killed)
80105f4d:	e8 de da ff ff       	call   80103a30 <myproc>
80105f52:	8b 40 24             	mov    0x24(%eax),%eax
80105f55:	85 c0                	test   %eax,%eax
80105f57:	0f 84 15 02 00 00    	je     80106172 <trap+0x25a>
      exit();
80105f5d:	e8 46 df ff ff       	call   80103ea8 <exit>
    return;
80105f62:	e9 0b 02 00 00       	jmp    80106172 <trap+0x25a>
  }

  switch(tf->trapno){
80105f67:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6a:	8b 40 30             	mov    0x30(%eax),%eax
80105f6d:	83 e8 20             	sub    $0x20,%eax
80105f70:	83 f8 1f             	cmp    $0x1f,%eax
80105f73:	0f 87 c4 00 00 00    	ja     8010603d <trap+0x125>
80105f79:	8b 04 85 a0 a4 10 80 	mov    -0x7fef5b60(,%eax,4),%eax
80105f80:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f82:	e8 16 da ff ff       	call   8010399d <cpuid>
80105f87:	85 c0                	test   %eax,%eax
80105f89:	75 3d                	jne    80105fc8 <trap+0xb0>
      acquire(&tickslock);
80105f8b:	83 ec 0c             	sub    $0xc,%esp
80105f8e:	68 40 5a 19 80       	push   $0x80195a40
80105f93:	e8 7a e7 ff ff       	call   80104712 <acquire>
80105f98:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105f9b:	a1 74 5a 19 80       	mov    0x80195a74,%eax
80105fa0:	83 c0 01             	add    $0x1,%eax
80105fa3:	a3 74 5a 19 80       	mov    %eax,0x80195a74
      wakeup(&ticks);
80105fa8:	83 ec 0c             	sub    $0xc,%esp
80105fab:	68 74 5a 19 80       	push   $0x80195a74
80105fb0:	e8 29 e4 ff ff       	call   801043de <wakeup>
80105fb5:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fb8:	83 ec 0c             	sub    $0xc,%esp
80105fbb:	68 40 5a 19 80       	push   $0x80195a40
80105fc0:	e8 bb e7 ff ff       	call   80104780 <release>
80105fc5:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80105fc8:	e8 51 cb ff ff       	call   80102b1e <lapiceoi>
    break;
80105fcd:	e9 20 01 00 00       	jmp    801060f2 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105fd2:	e8 db 3e 00 00       	call   80109eb2 <ideintr>
    lapiceoi();
80105fd7:	e8 42 cb ff ff       	call   80102b1e <lapiceoi>
    break;
80105fdc:	e9 11 01 00 00       	jmp    801060f2 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80105fe1:	e8 83 c9 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80105fe6:	e8 33 cb ff ff       	call   80102b1e <lapiceoi>
    break;
80105feb:	e9 02 01 00 00       	jmp    801060f2 <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80105ff0:	e8 51 03 00 00       	call   80106346 <uartintr>
    lapiceoi();
80105ff5:	e8 24 cb ff ff       	call   80102b1e <lapiceoi>
    break;
80105ffa:	e9 f3 00 00 00       	jmp    801060f2 <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
80105fff:	e8 77 2b 00 00       	call   80108b7b <i8254_intr>
    lapiceoi();
80106004:	e8 15 cb ff ff       	call   80102b1e <lapiceoi>
    break;
80106009:	e9 e4 00 00 00       	jmp    801060f2 <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010600e:	8b 45 08             	mov    0x8(%ebp),%eax
80106011:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106014:	8b 45 08             	mov    0x8(%ebp),%eax
80106017:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010601b:	0f b7 d8             	movzwl %ax,%ebx
8010601e:	e8 7a d9 ff ff       	call   8010399d <cpuid>
80106023:	56                   	push   %esi
80106024:	53                   	push   %ebx
80106025:	50                   	push   %eax
80106026:	68 00 a4 10 80       	push   $0x8010a400
8010602b:	e8 c4 a3 ff ff       	call   801003f4 <cprintf>
80106030:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106033:	e8 e6 ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106038:	e9 b5 00 00 00       	jmp    801060f2 <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010603d:	e8 ee d9 ff ff       	call   80103a30 <myproc>
80106042:	85 c0                	test   %eax,%eax
80106044:	74 11                	je     80106057 <trap+0x13f>
80106046:	8b 45 08             	mov    0x8(%ebp),%eax
80106049:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010604d:	0f b7 c0             	movzwl %ax,%eax
80106050:	83 e0 03             	and    $0x3,%eax
80106053:	85 c0                	test   %eax,%eax
80106055:	75 39                	jne    80106090 <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106057:	e8 1d fd ff ff       	call   80105d79 <rcr2>
8010605c:	89 c3                	mov    %eax,%ebx
8010605e:	8b 45 08             	mov    0x8(%ebp),%eax
80106061:	8b 70 38             	mov    0x38(%eax),%esi
80106064:	e8 34 d9 ff ff       	call   8010399d <cpuid>
80106069:	8b 55 08             	mov    0x8(%ebp),%edx
8010606c:	8b 52 30             	mov    0x30(%edx),%edx
8010606f:	83 ec 0c             	sub    $0xc,%esp
80106072:	53                   	push   %ebx
80106073:	56                   	push   %esi
80106074:	50                   	push   %eax
80106075:	52                   	push   %edx
80106076:	68 24 a4 10 80       	push   $0x8010a424
8010607b:	e8 74 a3 ff ff       	call   801003f4 <cprintf>
80106080:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	68 56 a4 10 80       	push   $0x8010a456
8010608b:	e8 19 a5 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106090:	e8 e4 fc ff ff       	call   80105d79 <rcr2>
80106095:	89 c6                	mov    %eax,%esi
80106097:	8b 45 08             	mov    0x8(%ebp),%eax
8010609a:	8b 40 38             	mov    0x38(%eax),%eax
8010609d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060a0:	e8 f8 d8 ff ff       	call   8010399d <cpuid>
801060a5:	89 c3                	mov    %eax,%ebx
801060a7:	8b 45 08             	mov    0x8(%ebp),%eax
801060aa:	8b 48 34             	mov    0x34(%eax),%ecx
801060ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801060b0:	8b 45 08             	mov    0x8(%ebp),%eax
801060b3:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801060b6:	e8 75 d9 ff ff       	call   80103a30 <myproc>
801060bb:	8d 50 6c             	lea    0x6c(%eax),%edx
801060be:	89 55 dc             	mov    %edx,-0x24(%ebp)
801060c1:	e8 6a d9 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060c6:	8b 40 10             	mov    0x10(%eax),%eax
801060c9:	56                   	push   %esi
801060ca:	ff 75 e4             	push   -0x1c(%ebp)
801060cd:	53                   	push   %ebx
801060ce:	ff 75 e0             	push   -0x20(%ebp)
801060d1:	57                   	push   %edi
801060d2:	ff 75 dc             	push   -0x24(%ebp)
801060d5:	50                   	push   %eax
801060d6:	68 5c a4 10 80       	push   $0x8010a45c
801060db:	e8 14 a3 ff ff       	call   801003f4 <cprintf>
801060e0:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801060e3:	e8 48 d9 ff ff       	call   80103a30 <myproc>
801060e8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801060ef:	eb 01                	jmp    801060f2 <trap+0x1da>
    break;
801060f1:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801060f2:	e8 39 d9 ff ff       	call   80103a30 <myproc>
801060f7:	85 c0                	test   %eax,%eax
801060f9:	74 23                	je     8010611e <trap+0x206>
801060fb:	e8 30 d9 ff ff       	call   80103a30 <myproc>
80106100:	8b 40 24             	mov    0x24(%eax),%eax
80106103:	85 c0                	test   %eax,%eax
80106105:	74 17                	je     8010611e <trap+0x206>
80106107:	8b 45 08             	mov    0x8(%ebp),%eax
8010610a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010610e:	0f b7 c0             	movzwl %ax,%eax
80106111:	83 e0 03             	and    $0x3,%eax
80106114:	83 f8 03             	cmp    $0x3,%eax
80106117:	75 05                	jne    8010611e <trap+0x206>
    exit();
80106119:	e8 8a dd ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010611e:	e8 0d d9 ff ff       	call   80103a30 <myproc>
80106123:	85 c0                	test   %eax,%eax
80106125:	74 1d                	je     80106144 <trap+0x22c>
80106127:	e8 04 d9 ff ff       	call   80103a30 <myproc>
8010612c:	8b 40 0c             	mov    0xc(%eax),%eax
8010612f:	83 f8 04             	cmp    $0x4,%eax
80106132:	75 10                	jne    80106144 <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106134:	8b 45 08             	mov    0x8(%ebp),%eax
80106137:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010613a:	83 f8 20             	cmp    $0x20,%eax
8010613d:	75 05                	jne    80106144 <trap+0x22c>
    yield();
8010613f:	e8 33 e1 ff ff       	call   80104277 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106144:	e8 e7 d8 ff ff       	call   80103a30 <myproc>
80106149:	85 c0                	test   %eax,%eax
8010614b:	74 26                	je     80106173 <trap+0x25b>
8010614d:	e8 de d8 ff ff       	call   80103a30 <myproc>
80106152:	8b 40 24             	mov    0x24(%eax),%eax
80106155:	85 c0                	test   %eax,%eax
80106157:	74 1a                	je     80106173 <trap+0x25b>
80106159:	8b 45 08             	mov    0x8(%ebp),%eax
8010615c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106160:	0f b7 c0             	movzwl %ax,%eax
80106163:	83 e0 03             	and    $0x3,%eax
80106166:	83 f8 03             	cmp    $0x3,%eax
80106169:	75 08                	jne    80106173 <trap+0x25b>
    exit();
8010616b:	e8 38 dd ff ff       	call   80103ea8 <exit>
80106170:	eb 01                	jmp    80106173 <trap+0x25b>
    return;
80106172:	90                   	nop
80106173:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106176:	5b                   	pop    %ebx
80106177:	5e                   	pop    %esi
80106178:	5f                   	pop    %edi
80106179:	5d                   	pop    %ebp
8010617a:	c3                   	ret

8010617b <inb>:
{
8010617b:	55                   	push   %ebp
8010617c:	89 e5                	mov    %esp,%ebp
8010617e:	83 ec 14             	sub    $0x14,%esp
80106181:	8b 45 08             	mov    0x8(%ebp),%eax
80106184:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106188:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010618c:	89 c2                	mov    %eax,%edx
8010618e:	ec                   	in     (%dx),%al
8010618f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106192:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106196:	c9                   	leave
80106197:	c3                   	ret

80106198 <outb>:
{
80106198:	55                   	push   %ebp
80106199:	89 e5                	mov    %esp,%ebp
8010619b:	83 ec 08             	sub    $0x8,%esp
8010619e:	8b 55 08             	mov    0x8(%ebp),%edx
801061a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801061a8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061ab:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061af:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061b3:	ee                   	out    %al,(%dx)
}
801061b4:	90                   	nop
801061b5:	c9                   	leave
801061b6:	c3                   	ret

801061b7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801061b7:	55                   	push   %ebp
801061b8:	89 e5                	mov    %esp,%ebp
801061ba:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801061bd:	6a 00                	push   $0x0
801061bf:	68 fa 03 00 00       	push   $0x3fa
801061c4:	e8 cf ff ff ff       	call   80106198 <outb>
801061c9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801061cc:	68 80 00 00 00       	push   $0x80
801061d1:	68 fb 03 00 00       	push   $0x3fb
801061d6:	e8 bd ff ff ff       	call   80106198 <outb>
801061db:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801061de:	6a 0c                	push   $0xc
801061e0:	68 f8 03 00 00       	push   $0x3f8
801061e5:	e8 ae ff ff ff       	call   80106198 <outb>
801061ea:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801061ed:	6a 00                	push   $0x0
801061ef:	68 f9 03 00 00       	push   $0x3f9
801061f4:	e8 9f ff ff ff       	call   80106198 <outb>
801061f9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801061fc:	6a 03                	push   $0x3
801061fe:	68 fb 03 00 00       	push   $0x3fb
80106203:	e8 90 ff ff ff       	call   80106198 <outb>
80106208:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010620b:	6a 00                	push   $0x0
8010620d:	68 fc 03 00 00       	push   $0x3fc
80106212:	e8 81 ff ff ff       	call   80106198 <outb>
80106217:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010621a:	6a 01                	push   $0x1
8010621c:	68 f9 03 00 00       	push   $0x3f9
80106221:	e8 72 ff ff ff       	call   80106198 <outb>
80106226:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106229:	68 fd 03 00 00       	push   $0x3fd
8010622e:	e8 48 ff ff ff       	call   8010617b <inb>
80106233:	83 c4 04             	add    $0x4,%esp
80106236:	3c ff                	cmp    $0xff,%al
80106238:	74 61                	je     8010629b <uartinit+0xe4>
    return;
  uart = 1;
8010623a:	c7 05 78 5a 19 80 01 	movl   $0x1,0x80195a78
80106241:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106244:	68 fa 03 00 00       	push   $0x3fa
80106249:	e8 2d ff ff ff       	call   8010617b <inb>
8010624e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106251:	68 f8 03 00 00       	push   $0x3f8
80106256:	e8 20 ff ff ff       	call   8010617b <inb>
8010625b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010625e:	83 ec 08             	sub    $0x8,%esp
80106261:	6a 00                	push   $0x0
80106263:	6a 04                	push   $0x4
80106265:	e8 cc c3 ff ff       	call   80102636 <ioapicenable>
8010626a:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010626d:	c7 45 f4 20 a5 10 80 	movl   $0x8010a520,-0xc(%ebp)
80106274:	eb 19                	jmp    8010628f <uartinit+0xd8>
    uartputc(*p);
80106276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106279:	0f b6 00             	movzbl (%eax),%eax
8010627c:	0f be c0             	movsbl %al,%eax
8010627f:	83 ec 0c             	sub    $0xc,%esp
80106282:	50                   	push   %eax
80106283:	e8 16 00 00 00       	call   8010629e <uartputc>
80106288:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010628b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	0f b6 00             	movzbl (%eax),%eax
80106295:	84 c0                	test   %al,%al
80106297:	75 dd                	jne    80106276 <uartinit+0xbf>
80106299:	eb 01                	jmp    8010629c <uartinit+0xe5>
    return;
8010629b:	90                   	nop
}
8010629c:	c9                   	leave
8010629d:	c3                   	ret

8010629e <uartputc>:

void
uartputc(int c)
{
8010629e:	55                   	push   %ebp
8010629f:	89 e5                	mov    %esp,%ebp
801062a1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801062a4:	a1 78 5a 19 80       	mov    0x80195a78,%eax
801062a9:	85 c0                	test   %eax,%eax
801062ab:	74 53                	je     80106300 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062b4:	eb 11                	jmp    801062c7 <uartputc+0x29>
    microdelay(10);
801062b6:	83 ec 0c             	sub    $0xc,%esp
801062b9:	6a 0a                	push   $0xa
801062bb:	e8 79 c8 ff ff       	call   80102b39 <microdelay>
801062c0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062c7:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801062cb:	7f 1a                	jg     801062e7 <uartputc+0x49>
801062cd:	83 ec 0c             	sub    $0xc,%esp
801062d0:	68 fd 03 00 00       	push   $0x3fd
801062d5:	e8 a1 fe ff ff       	call   8010617b <inb>
801062da:	83 c4 10             	add    $0x10,%esp
801062dd:	0f b6 c0             	movzbl %al,%eax
801062e0:	83 e0 20             	and    $0x20,%eax
801062e3:	85 c0                	test   %eax,%eax
801062e5:	74 cf                	je     801062b6 <uartputc+0x18>
  outb(COM1+0, c);
801062e7:	8b 45 08             	mov    0x8(%ebp),%eax
801062ea:	0f b6 c0             	movzbl %al,%eax
801062ed:	83 ec 08             	sub    $0x8,%esp
801062f0:	50                   	push   %eax
801062f1:	68 f8 03 00 00       	push   $0x3f8
801062f6:	e8 9d fe ff ff       	call   80106198 <outb>
801062fb:	83 c4 10             	add    $0x10,%esp
801062fe:	eb 01                	jmp    80106301 <uartputc+0x63>
    return;
80106300:	90                   	nop
}
80106301:	c9                   	leave
80106302:	c3                   	ret

80106303 <uartgetc>:

static int
uartgetc(void)
{
80106303:	55                   	push   %ebp
80106304:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106306:	a1 78 5a 19 80       	mov    0x80195a78,%eax
8010630b:	85 c0                	test   %eax,%eax
8010630d:	75 07                	jne    80106316 <uartgetc+0x13>
    return -1;
8010630f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106314:	eb 2e                	jmp    80106344 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106316:	68 fd 03 00 00       	push   $0x3fd
8010631b:	e8 5b fe ff ff       	call   8010617b <inb>
80106320:	83 c4 04             	add    $0x4,%esp
80106323:	0f b6 c0             	movzbl %al,%eax
80106326:	83 e0 01             	and    $0x1,%eax
80106329:	85 c0                	test   %eax,%eax
8010632b:	75 07                	jne    80106334 <uartgetc+0x31>
    return -1;
8010632d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106332:	eb 10                	jmp    80106344 <uartgetc+0x41>
  return inb(COM1+0);
80106334:	68 f8 03 00 00       	push   $0x3f8
80106339:	e8 3d fe ff ff       	call   8010617b <inb>
8010633e:	83 c4 04             	add    $0x4,%esp
80106341:	0f b6 c0             	movzbl %al,%eax
}
80106344:	c9                   	leave
80106345:	c3                   	ret

80106346 <uartintr>:

void
uartintr(void)
{
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010634c:	83 ec 0c             	sub    $0xc,%esp
8010634f:	68 03 63 10 80       	push   $0x80106303
80106354:	e8 7d a4 ff ff       	call   801007d6 <consoleintr>
80106359:	83 c4 10             	add    $0x10,%esp
}
8010635c:	90                   	nop
8010635d:	c9                   	leave
8010635e:	c3                   	ret

8010635f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010635f:	6a 00                	push   $0x0
  pushl $0
80106361:	6a 00                	push   $0x0
  jmp alltraps
80106363:	e9 c4 f9 ff ff       	jmp    80105d2c <alltraps>

80106368 <vector1>:
.globl vector1
vector1:
  pushl $0
80106368:	6a 00                	push   $0x0
  pushl $1
8010636a:	6a 01                	push   $0x1
  jmp alltraps
8010636c:	e9 bb f9 ff ff       	jmp    80105d2c <alltraps>

80106371 <vector2>:
.globl vector2
vector2:
  pushl $0
80106371:	6a 00                	push   $0x0
  pushl $2
80106373:	6a 02                	push   $0x2
  jmp alltraps
80106375:	e9 b2 f9 ff ff       	jmp    80105d2c <alltraps>

8010637a <vector3>:
.globl vector3
vector3:
  pushl $0
8010637a:	6a 00                	push   $0x0
  pushl $3
8010637c:	6a 03                	push   $0x3
  jmp alltraps
8010637e:	e9 a9 f9 ff ff       	jmp    80105d2c <alltraps>

80106383 <vector4>:
.globl vector4
vector4:
  pushl $0
80106383:	6a 00                	push   $0x0
  pushl $4
80106385:	6a 04                	push   $0x4
  jmp alltraps
80106387:	e9 a0 f9 ff ff       	jmp    80105d2c <alltraps>

8010638c <vector5>:
.globl vector5
vector5:
  pushl $0
8010638c:	6a 00                	push   $0x0
  pushl $5
8010638e:	6a 05                	push   $0x5
  jmp alltraps
80106390:	e9 97 f9 ff ff       	jmp    80105d2c <alltraps>

80106395 <vector6>:
.globl vector6
vector6:
  pushl $0
80106395:	6a 00                	push   $0x0
  pushl $6
80106397:	6a 06                	push   $0x6
  jmp alltraps
80106399:	e9 8e f9 ff ff       	jmp    80105d2c <alltraps>

8010639e <vector7>:
.globl vector7
vector7:
  pushl $0
8010639e:	6a 00                	push   $0x0
  pushl $7
801063a0:	6a 07                	push   $0x7
  jmp alltraps
801063a2:	e9 85 f9 ff ff       	jmp    80105d2c <alltraps>

801063a7 <vector8>:
.globl vector8
vector8:
  pushl $8
801063a7:	6a 08                	push   $0x8
  jmp alltraps
801063a9:	e9 7e f9 ff ff       	jmp    80105d2c <alltraps>

801063ae <vector9>:
.globl vector9
vector9:
  pushl $0
801063ae:	6a 00                	push   $0x0
  pushl $9
801063b0:	6a 09                	push   $0x9
  jmp alltraps
801063b2:	e9 75 f9 ff ff       	jmp    80105d2c <alltraps>

801063b7 <vector10>:
.globl vector10
vector10:
  pushl $10
801063b7:	6a 0a                	push   $0xa
  jmp alltraps
801063b9:	e9 6e f9 ff ff       	jmp    80105d2c <alltraps>

801063be <vector11>:
.globl vector11
vector11:
  pushl $11
801063be:	6a 0b                	push   $0xb
  jmp alltraps
801063c0:	e9 67 f9 ff ff       	jmp    80105d2c <alltraps>

801063c5 <vector12>:
.globl vector12
vector12:
  pushl $12
801063c5:	6a 0c                	push   $0xc
  jmp alltraps
801063c7:	e9 60 f9 ff ff       	jmp    80105d2c <alltraps>

801063cc <vector13>:
.globl vector13
vector13:
  pushl $13
801063cc:	6a 0d                	push   $0xd
  jmp alltraps
801063ce:	e9 59 f9 ff ff       	jmp    80105d2c <alltraps>

801063d3 <vector14>:
.globl vector14
vector14:
  pushl $14
801063d3:	6a 0e                	push   $0xe
  jmp alltraps
801063d5:	e9 52 f9 ff ff       	jmp    80105d2c <alltraps>

801063da <vector15>:
.globl vector15
vector15:
  pushl $0
801063da:	6a 00                	push   $0x0
  pushl $15
801063dc:	6a 0f                	push   $0xf
  jmp alltraps
801063de:	e9 49 f9 ff ff       	jmp    80105d2c <alltraps>

801063e3 <vector16>:
.globl vector16
vector16:
  pushl $0
801063e3:	6a 00                	push   $0x0
  pushl $16
801063e5:	6a 10                	push   $0x10
  jmp alltraps
801063e7:	e9 40 f9 ff ff       	jmp    80105d2c <alltraps>

801063ec <vector17>:
.globl vector17
vector17:
  pushl $17
801063ec:	6a 11                	push   $0x11
  jmp alltraps
801063ee:	e9 39 f9 ff ff       	jmp    80105d2c <alltraps>

801063f3 <vector18>:
.globl vector18
vector18:
  pushl $0
801063f3:	6a 00                	push   $0x0
  pushl $18
801063f5:	6a 12                	push   $0x12
  jmp alltraps
801063f7:	e9 30 f9 ff ff       	jmp    80105d2c <alltraps>

801063fc <vector19>:
.globl vector19
vector19:
  pushl $0
801063fc:	6a 00                	push   $0x0
  pushl $19
801063fe:	6a 13                	push   $0x13
  jmp alltraps
80106400:	e9 27 f9 ff ff       	jmp    80105d2c <alltraps>

80106405 <vector20>:
.globl vector20
vector20:
  pushl $0
80106405:	6a 00                	push   $0x0
  pushl $20
80106407:	6a 14                	push   $0x14
  jmp alltraps
80106409:	e9 1e f9 ff ff       	jmp    80105d2c <alltraps>

8010640e <vector21>:
.globl vector21
vector21:
  pushl $0
8010640e:	6a 00                	push   $0x0
  pushl $21
80106410:	6a 15                	push   $0x15
  jmp alltraps
80106412:	e9 15 f9 ff ff       	jmp    80105d2c <alltraps>

80106417 <vector22>:
.globl vector22
vector22:
  pushl $0
80106417:	6a 00                	push   $0x0
  pushl $22
80106419:	6a 16                	push   $0x16
  jmp alltraps
8010641b:	e9 0c f9 ff ff       	jmp    80105d2c <alltraps>

80106420 <vector23>:
.globl vector23
vector23:
  pushl $0
80106420:	6a 00                	push   $0x0
  pushl $23
80106422:	6a 17                	push   $0x17
  jmp alltraps
80106424:	e9 03 f9 ff ff       	jmp    80105d2c <alltraps>

80106429 <vector24>:
.globl vector24
vector24:
  pushl $0
80106429:	6a 00                	push   $0x0
  pushl $24
8010642b:	6a 18                	push   $0x18
  jmp alltraps
8010642d:	e9 fa f8 ff ff       	jmp    80105d2c <alltraps>

80106432 <vector25>:
.globl vector25
vector25:
  pushl $0
80106432:	6a 00                	push   $0x0
  pushl $25
80106434:	6a 19                	push   $0x19
  jmp alltraps
80106436:	e9 f1 f8 ff ff       	jmp    80105d2c <alltraps>

8010643b <vector26>:
.globl vector26
vector26:
  pushl $0
8010643b:	6a 00                	push   $0x0
  pushl $26
8010643d:	6a 1a                	push   $0x1a
  jmp alltraps
8010643f:	e9 e8 f8 ff ff       	jmp    80105d2c <alltraps>

80106444 <vector27>:
.globl vector27
vector27:
  pushl $0
80106444:	6a 00                	push   $0x0
  pushl $27
80106446:	6a 1b                	push   $0x1b
  jmp alltraps
80106448:	e9 df f8 ff ff       	jmp    80105d2c <alltraps>

8010644d <vector28>:
.globl vector28
vector28:
  pushl $0
8010644d:	6a 00                	push   $0x0
  pushl $28
8010644f:	6a 1c                	push   $0x1c
  jmp alltraps
80106451:	e9 d6 f8 ff ff       	jmp    80105d2c <alltraps>

80106456 <vector29>:
.globl vector29
vector29:
  pushl $0
80106456:	6a 00                	push   $0x0
  pushl $29
80106458:	6a 1d                	push   $0x1d
  jmp alltraps
8010645a:	e9 cd f8 ff ff       	jmp    80105d2c <alltraps>

8010645f <vector30>:
.globl vector30
vector30:
  pushl $0
8010645f:	6a 00                	push   $0x0
  pushl $30
80106461:	6a 1e                	push   $0x1e
  jmp alltraps
80106463:	e9 c4 f8 ff ff       	jmp    80105d2c <alltraps>

80106468 <vector31>:
.globl vector31
vector31:
  pushl $0
80106468:	6a 00                	push   $0x0
  pushl $31
8010646a:	6a 1f                	push   $0x1f
  jmp alltraps
8010646c:	e9 bb f8 ff ff       	jmp    80105d2c <alltraps>

80106471 <vector32>:
.globl vector32
vector32:
  pushl $0
80106471:	6a 00                	push   $0x0
  pushl $32
80106473:	6a 20                	push   $0x20
  jmp alltraps
80106475:	e9 b2 f8 ff ff       	jmp    80105d2c <alltraps>

8010647a <vector33>:
.globl vector33
vector33:
  pushl $0
8010647a:	6a 00                	push   $0x0
  pushl $33
8010647c:	6a 21                	push   $0x21
  jmp alltraps
8010647e:	e9 a9 f8 ff ff       	jmp    80105d2c <alltraps>

80106483 <vector34>:
.globl vector34
vector34:
  pushl $0
80106483:	6a 00                	push   $0x0
  pushl $34
80106485:	6a 22                	push   $0x22
  jmp alltraps
80106487:	e9 a0 f8 ff ff       	jmp    80105d2c <alltraps>

8010648c <vector35>:
.globl vector35
vector35:
  pushl $0
8010648c:	6a 00                	push   $0x0
  pushl $35
8010648e:	6a 23                	push   $0x23
  jmp alltraps
80106490:	e9 97 f8 ff ff       	jmp    80105d2c <alltraps>

80106495 <vector36>:
.globl vector36
vector36:
  pushl $0
80106495:	6a 00                	push   $0x0
  pushl $36
80106497:	6a 24                	push   $0x24
  jmp alltraps
80106499:	e9 8e f8 ff ff       	jmp    80105d2c <alltraps>

8010649e <vector37>:
.globl vector37
vector37:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $37
801064a0:	6a 25                	push   $0x25
  jmp alltraps
801064a2:	e9 85 f8 ff ff       	jmp    80105d2c <alltraps>

801064a7 <vector38>:
.globl vector38
vector38:
  pushl $0
801064a7:	6a 00                	push   $0x0
  pushl $38
801064a9:	6a 26                	push   $0x26
  jmp alltraps
801064ab:	e9 7c f8 ff ff       	jmp    80105d2c <alltraps>

801064b0 <vector39>:
.globl vector39
vector39:
  pushl $0
801064b0:	6a 00                	push   $0x0
  pushl $39
801064b2:	6a 27                	push   $0x27
  jmp alltraps
801064b4:	e9 73 f8 ff ff       	jmp    80105d2c <alltraps>

801064b9 <vector40>:
.globl vector40
vector40:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $40
801064bb:	6a 28                	push   $0x28
  jmp alltraps
801064bd:	e9 6a f8 ff ff       	jmp    80105d2c <alltraps>

801064c2 <vector41>:
.globl vector41
vector41:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $41
801064c4:	6a 29                	push   $0x29
  jmp alltraps
801064c6:	e9 61 f8 ff ff       	jmp    80105d2c <alltraps>

801064cb <vector42>:
.globl vector42
vector42:
  pushl $0
801064cb:	6a 00                	push   $0x0
  pushl $42
801064cd:	6a 2a                	push   $0x2a
  jmp alltraps
801064cf:	e9 58 f8 ff ff       	jmp    80105d2c <alltraps>

801064d4 <vector43>:
.globl vector43
vector43:
  pushl $0
801064d4:	6a 00                	push   $0x0
  pushl $43
801064d6:	6a 2b                	push   $0x2b
  jmp alltraps
801064d8:	e9 4f f8 ff ff       	jmp    80105d2c <alltraps>

801064dd <vector44>:
.globl vector44
vector44:
  pushl $0
801064dd:	6a 00                	push   $0x0
  pushl $44
801064df:	6a 2c                	push   $0x2c
  jmp alltraps
801064e1:	e9 46 f8 ff ff       	jmp    80105d2c <alltraps>

801064e6 <vector45>:
.globl vector45
vector45:
  pushl $0
801064e6:	6a 00                	push   $0x0
  pushl $45
801064e8:	6a 2d                	push   $0x2d
  jmp alltraps
801064ea:	e9 3d f8 ff ff       	jmp    80105d2c <alltraps>

801064ef <vector46>:
.globl vector46
vector46:
  pushl $0
801064ef:	6a 00                	push   $0x0
  pushl $46
801064f1:	6a 2e                	push   $0x2e
  jmp alltraps
801064f3:	e9 34 f8 ff ff       	jmp    80105d2c <alltraps>

801064f8 <vector47>:
.globl vector47
vector47:
  pushl $0
801064f8:	6a 00                	push   $0x0
  pushl $47
801064fa:	6a 2f                	push   $0x2f
  jmp alltraps
801064fc:	e9 2b f8 ff ff       	jmp    80105d2c <alltraps>

80106501 <vector48>:
.globl vector48
vector48:
  pushl $0
80106501:	6a 00                	push   $0x0
  pushl $48
80106503:	6a 30                	push   $0x30
  jmp alltraps
80106505:	e9 22 f8 ff ff       	jmp    80105d2c <alltraps>

8010650a <vector49>:
.globl vector49
vector49:
  pushl $0
8010650a:	6a 00                	push   $0x0
  pushl $49
8010650c:	6a 31                	push   $0x31
  jmp alltraps
8010650e:	e9 19 f8 ff ff       	jmp    80105d2c <alltraps>

80106513 <vector50>:
.globl vector50
vector50:
  pushl $0
80106513:	6a 00                	push   $0x0
  pushl $50
80106515:	6a 32                	push   $0x32
  jmp alltraps
80106517:	e9 10 f8 ff ff       	jmp    80105d2c <alltraps>

8010651c <vector51>:
.globl vector51
vector51:
  pushl $0
8010651c:	6a 00                	push   $0x0
  pushl $51
8010651e:	6a 33                	push   $0x33
  jmp alltraps
80106520:	e9 07 f8 ff ff       	jmp    80105d2c <alltraps>

80106525 <vector52>:
.globl vector52
vector52:
  pushl $0
80106525:	6a 00                	push   $0x0
  pushl $52
80106527:	6a 34                	push   $0x34
  jmp alltraps
80106529:	e9 fe f7 ff ff       	jmp    80105d2c <alltraps>

8010652e <vector53>:
.globl vector53
vector53:
  pushl $0
8010652e:	6a 00                	push   $0x0
  pushl $53
80106530:	6a 35                	push   $0x35
  jmp alltraps
80106532:	e9 f5 f7 ff ff       	jmp    80105d2c <alltraps>

80106537 <vector54>:
.globl vector54
vector54:
  pushl $0
80106537:	6a 00                	push   $0x0
  pushl $54
80106539:	6a 36                	push   $0x36
  jmp alltraps
8010653b:	e9 ec f7 ff ff       	jmp    80105d2c <alltraps>

80106540 <vector55>:
.globl vector55
vector55:
  pushl $0
80106540:	6a 00                	push   $0x0
  pushl $55
80106542:	6a 37                	push   $0x37
  jmp alltraps
80106544:	e9 e3 f7 ff ff       	jmp    80105d2c <alltraps>

80106549 <vector56>:
.globl vector56
vector56:
  pushl $0
80106549:	6a 00                	push   $0x0
  pushl $56
8010654b:	6a 38                	push   $0x38
  jmp alltraps
8010654d:	e9 da f7 ff ff       	jmp    80105d2c <alltraps>

80106552 <vector57>:
.globl vector57
vector57:
  pushl $0
80106552:	6a 00                	push   $0x0
  pushl $57
80106554:	6a 39                	push   $0x39
  jmp alltraps
80106556:	e9 d1 f7 ff ff       	jmp    80105d2c <alltraps>

8010655b <vector58>:
.globl vector58
vector58:
  pushl $0
8010655b:	6a 00                	push   $0x0
  pushl $58
8010655d:	6a 3a                	push   $0x3a
  jmp alltraps
8010655f:	e9 c8 f7 ff ff       	jmp    80105d2c <alltraps>

80106564 <vector59>:
.globl vector59
vector59:
  pushl $0
80106564:	6a 00                	push   $0x0
  pushl $59
80106566:	6a 3b                	push   $0x3b
  jmp alltraps
80106568:	e9 bf f7 ff ff       	jmp    80105d2c <alltraps>

8010656d <vector60>:
.globl vector60
vector60:
  pushl $0
8010656d:	6a 00                	push   $0x0
  pushl $60
8010656f:	6a 3c                	push   $0x3c
  jmp alltraps
80106571:	e9 b6 f7 ff ff       	jmp    80105d2c <alltraps>

80106576 <vector61>:
.globl vector61
vector61:
  pushl $0
80106576:	6a 00                	push   $0x0
  pushl $61
80106578:	6a 3d                	push   $0x3d
  jmp alltraps
8010657a:	e9 ad f7 ff ff       	jmp    80105d2c <alltraps>

8010657f <vector62>:
.globl vector62
vector62:
  pushl $0
8010657f:	6a 00                	push   $0x0
  pushl $62
80106581:	6a 3e                	push   $0x3e
  jmp alltraps
80106583:	e9 a4 f7 ff ff       	jmp    80105d2c <alltraps>

80106588 <vector63>:
.globl vector63
vector63:
  pushl $0
80106588:	6a 00                	push   $0x0
  pushl $63
8010658a:	6a 3f                	push   $0x3f
  jmp alltraps
8010658c:	e9 9b f7 ff ff       	jmp    80105d2c <alltraps>

80106591 <vector64>:
.globl vector64
vector64:
  pushl $0
80106591:	6a 00                	push   $0x0
  pushl $64
80106593:	6a 40                	push   $0x40
  jmp alltraps
80106595:	e9 92 f7 ff ff       	jmp    80105d2c <alltraps>

8010659a <vector65>:
.globl vector65
vector65:
  pushl $0
8010659a:	6a 00                	push   $0x0
  pushl $65
8010659c:	6a 41                	push   $0x41
  jmp alltraps
8010659e:	e9 89 f7 ff ff       	jmp    80105d2c <alltraps>

801065a3 <vector66>:
.globl vector66
vector66:
  pushl $0
801065a3:	6a 00                	push   $0x0
  pushl $66
801065a5:	6a 42                	push   $0x42
  jmp alltraps
801065a7:	e9 80 f7 ff ff       	jmp    80105d2c <alltraps>

801065ac <vector67>:
.globl vector67
vector67:
  pushl $0
801065ac:	6a 00                	push   $0x0
  pushl $67
801065ae:	6a 43                	push   $0x43
  jmp alltraps
801065b0:	e9 77 f7 ff ff       	jmp    80105d2c <alltraps>

801065b5 <vector68>:
.globl vector68
vector68:
  pushl $0
801065b5:	6a 00                	push   $0x0
  pushl $68
801065b7:	6a 44                	push   $0x44
  jmp alltraps
801065b9:	e9 6e f7 ff ff       	jmp    80105d2c <alltraps>

801065be <vector69>:
.globl vector69
vector69:
  pushl $0
801065be:	6a 00                	push   $0x0
  pushl $69
801065c0:	6a 45                	push   $0x45
  jmp alltraps
801065c2:	e9 65 f7 ff ff       	jmp    80105d2c <alltraps>

801065c7 <vector70>:
.globl vector70
vector70:
  pushl $0
801065c7:	6a 00                	push   $0x0
  pushl $70
801065c9:	6a 46                	push   $0x46
  jmp alltraps
801065cb:	e9 5c f7 ff ff       	jmp    80105d2c <alltraps>

801065d0 <vector71>:
.globl vector71
vector71:
  pushl $0
801065d0:	6a 00                	push   $0x0
  pushl $71
801065d2:	6a 47                	push   $0x47
  jmp alltraps
801065d4:	e9 53 f7 ff ff       	jmp    80105d2c <alltraps>

801065d9 <vector72>:
.globl vector72
vector72:
  pushl $0
801065d9:	6a 00                	push   $0x0
  pushl $72
801065db:	6a 48                	push   $0x48
  jmp alltraps
801065dd:	e9 4a f7 ff ff       	jmp    80105d2c <alltraps>

801065e2 <vector73>:
.globl vector73
vector73:
  pushl $0
801065e2:	6a 00                	push   $0x0
  pushl $73
801065e4:	6a 49                	push   $0x49
  jmp alltraps
801065e6:	e9 41 f7 ff ff       	jmp    80105d2c <alltraps>

801065eb <vector74>:
.globl vector74
vector74:
  pushl $0
801065eb:	6a 00                	push   $0x0
  pushl $74
801065ed:	6a 4a                	push   $0x4a
  jmp alltraps
801065ef:	e9 38 f7 ff ff       	jmp    80105d2c <alltraps>

801065f4 <vector75>:
.globl vector75
vector75:
  pushl $0
801065f4:	6a 00                	push   $0x0
  pushl $75
801065f6:	6a 4b                	push   $0x4b
  jmp alltraps
801065f8:	e9 2f f7 ff ff       	jmp    80105d2c <alltraps>

801065fd <vector76>:
.globl vector76
vector76:
  pushl $0
801065fd:	6a 00                	push   $0x0
  pushl $76
801065ff:	6a 4c                	push   $0x4c
  jmp alltraps
80106601:	e9 26 f7 ff ff       	jmp    80105d2c <alltraps>

80106606 <vector77>:
.globl vector77
vector77:
  pushl $0
80106606:	6a 00                	push   $0x0
  pushl $77
80106608:	6a 4d                	push   $0x4d
  jmp alltraps
8010660a:	e9 1d f7 ff ff       	jmp    80105d2c <alltraps>

8010660f <vector78>:
.globl vector78
vector78:
  pushl $0
8010660f:	6a 00                	push   $0x0
  pushl $78
80106611:	6a 4e                	push   $0x4e
  jmp alltraps
80106613:	e9 14 f7 ff ff       	jmp    80105d2c <alltraps>

80106618 <vector79>:
.globl vector79
vector79:
  pushl $0
80106618:	6a 00                	push   $0x0
  pushl $79
8010661a:	6a 4f                	push   $0x4f
  jmp alltraps
8010661c:	e9 0b f7 ff ff       	jmp    80105d2c <alltraps>

80106621 <vector80>:
.globl vector80
vector80:
  pushl $0
80106621:	6a 00                	push   $0x0
  pushl $80
80106623:	6a 50                	push   $0x50
  jmp alltraps
80106625:	e9 02 f7 ff ff       	jmp    80105d2c <alltraps>

8010662a <vector81>:
.globl vector81
vector81:
  pushl $0
8010662a:	6a 00                	push   $0x0
  pushl $81
8010662c:	6a 51                	push   $0x51
  jmp alltraps
8010662e:	e9 f9 f6 ff ff       	jmp    80105d2c <alltraps>

80106633 <vector82>:
.globl vector82
vector82:
  pushl $0
80106633:	6a 00                	push   $0x0
  pushl $82
80106635:	6a 52                	push   $0x52
  jmp alltraps
80106637:	e9 f0 f6 ff ff       	jmp    80105d2c <alltraps>

8010663c <vector83>:
.globl vector83
vector83:
  pushl $0
8010663c:	6a 00                	push   $0x0
  pushl $83
8010663e:	6a 53                	push   $0x53
  jmp alltraps
80106640:	e9 e7 f6 ff ff       	jmp    80105d2c <alltraps>

80106645 <vector84>:
.globl vector84
vector84:
  pushl $0
80106645:	6a 00                	push   $0x0
  pushl $84
80106647:	6a 54                	push   $0x54
  jmp alltraps
80106649:	e9 de f6 ff ff       	jmp    80105d2c <alltraps>

8010664e <vector85>:
.globl vector85
vector85:
  pushl $0
8010664e:	6a 00                	push   $0x0
  pushl $85
80106650:	6a 55                	push   $0x55
  jmp alltraps
80106652:	e9 d5 f6 ff ff       	jmp    80105d2c <alltraps>

80106657 <vector86>:
.globl vector86
vector86:
  pushl $0
80106657:	6a 00                	push   $0x0
  pushl $86
80106659:	6a 56                	push   $0x56
  jmp alltraps
8010665b:	e9 cc f6 ff ff       	jmp    80105d2c <alltraps>

80106660 <vector87>:
.globl vector87
vector87:
  pushl $0
80106660:	6a 00                	push   $0x0
  pushl $87
80106662:	6a 57                	push   $0x57
  jmp alltraps
80106664:	e9 c3 f6 ff ff       	jmp    80105d2c <alltraps>

80106669 <vector88>:
.globl vector88
vector88:
  pushl $0
80106669:	6a 00                	push   $0x0
  pushl $88
8010666b:	6a 58                	push   $0x58
  jmp alltraps
8010666d:	e9 ba f6 ff ff       	jmp    80105d2c <alltraps>

80106672 <vector89>:
.globl vector89
vector89:
  pushl $0
80106672:	6a 00                	push   $0x0
  pushl $89
80106674:	6a 59                	push   $0x59
  jmp alltraps
80106676:	e9 b1 f6 ff ff       	jmp    80105d2c <alltraps>

8010667b <vector90>:
.globl vector90
vector90:
  pushl $0
8010667b:	6a 00                	push   $0x0
  pushl $90
8010667d:	6a 5a                	push   $0x5a
  jmp alltraps
8010667f:	e9 a8 f6 ff ff       	jmp    80105d2c <alltraps>

80106684 <vector91>:
.globl vector91
vector91:
  pushl $0
80106684:	6a 00                	push   $0x0
  pushl $91
80106686:	6a 5b                	push   $0x5b
  jmp alltraps
80106688:	e9 9f f6 ff ff       	jmp    80105d2c <alltraps>

8010668d <vector92>:
.globl vector92
vector92:
  pushl $0
8010668d:	6a 00                	push   $0x0
  pushl $92
8010668f:	6a 5c                	push   $0x5c
  jmp alltraps
80106691:	e9 96 f6 ff ff       	jmp    80105d2c <alltraps>

80106696 <vector93>:
.globl vector93
vector93:
  pushl $0
80106696:	6a 00                	push   $0x0
  pushl $93
80106698:	6a 5d                	push   $0x5d
  jmp alltraps
8010669a:	e9 8d f6 ff ff       	jmp    80105d2c <alltraps>

8010669f <vector94>:
.globl vector94
vector94:
  pushl $0
8010669f:	6a 00                	push   $0x0
  pushl $94
801066a1:	6a 5e                	push   $0x5e
  jmp alltraps
801066a3:	e9 84 f6 ff ff       	jmp    80105d2c <alltraps>

801066a8 <vector95>:
.globl vector95
vector95:
  pushl $0
801066a8:	6a 00                	push   $0x0
  pushl $95
801066aa:	6a 5f                	push   $0x5f
  jmp alltraps
801066ac:	e9 7b f6 ff ff       	jmp    80105d2c <alltraps>

801066b1 <vector96>:
.globl vector96
vector96:
  pushl $0
801066b1:	6a 00                	push   $0x0
  pushl $96
801066b3:	6a 60                	push   $0x60
  jmp alltraps
801066b5:	e9 72 f6 ff ff       	jmp    80105d2c <alltraps>

801066ba <vector97>:
.globl vector97
vector97:
  pushl $0
801066ba:	6a 00                	push   $0x0
  pushl $97
801066bc:	6a 61                	push   $0x61
  jmp alltraps
801066be:	e9 69 f6 ff ff       	jmp    80105d2c <alltraps>

801066c3 <vector98>:
.globl vector98
vector98:
  pushl $0
801066c3:	6a 00                	push   $0x0
  pushl $98
801066c5:	6a 62                	push   $0x62
  jmp alltraps
801066c7:	e9 60 f6 ff ff       	jmp    80105d2c <alltraps>

801066cc <vector99>:
.globl vector99
vector99:
  pushl $0
801066cc:	6a 00                	push   $0x0
  pushl $99
801066ce:	6a 63                	push   $0x63
  jmp alltraps
801066d0:	e9 57 f6 ff ff       	jmp    80105d2c <alltraps>

801066d5 <vector100>:
.globl vector100
vector100:
  pushl $0
801066d5:	6a 00                	push   $0x0
  pushl $100
801066d7:	6a 64                	push   $0x64
  jmp alltraps
801066d9:	e9 4e f6 ff ff       	jmp    80105d2c <alltraps>

801066de <vector101>:
.globl vector101
vector101:
  pushl $0
801066de:	6a 00                	push   $0x0
  pushl $101
801066e0:	6a 65                	push   $0x65
  jmp alltraps
801066e2:	e9 45 f6 ff ff       	jmp    80105d2c <alltraps>

801066e7 <vector102>:
.globl vector102
vector102:
  pushl $0
801066e7:	6a 00                	push   $0x0
  pushl $102
801066e9:	6a 66                	push   $0x66
  jmp alltraps
801066eb:	e9 3c f6 ff ff       	jmp    80105d2c <alltraps>

801066f0 <vector103>:
.globl vector103
vector103:
  pushl $0
801066f0:	6a 00                	push   $0x0
  pushl $103
801066f2:	6a 67                	push   $0x67
  jmp alltraps
801066f4:	e9 33 f6 ff ff       	jmp    80105d2c <alltraps>

801066f9 <vector104>:
.globl vector104
vector104:
  pushl $0
801066f9:	6a 00                	push   $0x0
  pushl $104
801066fb:	6a 68                	push   $0x68
  jmp alltraps
801066fd:	e9 2a f6 ff ff       	jmp    80105d2c <alltraps>

80106702 <vector105>:
.globl vector105
vector105:
  pushl $0
80106702:	6a 00                	push   $0x0
  pushl $105
80106704:	6a 69                	push   $0x69
  jmp alltraps
80106706:	e9 21 f6 ff ff       	jmp    80105d2c <alltraps>

8010670b <vector106>:
.globl vector106
vector106:
  pushl $0
8010670b:	6a 00                	push   $0x0
  pushl $106
8010670d:	6a 6a                	push   $0x6a
  jmp alltraps
8010670f:	e9 18 f6 ff ff       	jmp    80105d2c <alltraps>

80106714 <vector107>:
.globl vector107
vector107:
  pushl $0
80106714:	6a 00                	push   $0x0
  pushl $107
80106716:	6a 6b                	push   $0x6b
  jmp alltraps
80106718:	e9 0f f6 ff ff       	jmp    80105d2c <alltraps>

8010671d <vector108>:
.globl vector108
vector108:
  pushl $0
8010671d:	6a 00                	push   $0x0
  pushl $108
8010671f:	6a 6c                	push   $0x6c
  jmp alltraps
80106721:	e9 06 f6 ff ff       	jmp    80105d2c <alltraps>

80106726 <vector109>:
.globl vector109
vector109:
  pushl $0
80106726:	6a 00                	push   $0x0
  pushl $109
80106728:	6a 6d                	push   $0x6d
  jmp alltraps
8010672a:	e9 fd f5 ff ff       	jmp    80105d2c <alltraps>

8010672f <vector110>:
.globl vector110
vector110:
  pushl $0
8010672f:	6a 00                	push   $0x0
  pushl $110
80106731:	6a 6e                	push   $0x6e
  jmp alltraps
80106733:	e9 f4 f5 ff ff       	jmp    80105d2c <alltraps>

80106738 <vector111>:
.globl vector111
vector111:
  pushl $0
80106738:	6a 00                	push   $0x0
  pushl $111
8010673a:	6a 6f                	push   $0x6f
  jmp alltraps
8010673c:	e9 eb f5 ff ff       	jmp    80105d2c <alltraps>

80106741 <vector112>:
.globl vector112
vector112:
  pushl $0
80106741:	6a 00                	push   $0x0
  pushl $112
80106743:	6a 70                	push   $0x70
  jmp alltraps
80106745:	e9 e2 f5 ff ff       	jmp    80105d2c <alltraps>

8010674a <vector113>:
.globl vector113
vector113:
  pushl $0
8010674a:	6a 00                	push   $0x0
  pushl $113
8010674c:	6a 71                	push   $0x71
  jmp alltraps
8010674e:	e9 d9 f5 ff ff       	jmp    80105d2c <alltraps>

80106753 <vector114>:
.globl vector114
vector114:
  pushl $0
80106753:	6a 00                	push   $0x0
  pushl $114
80106755:	6a 72                	push   $0x72
  jmp alltraps
80106757:	e9 d0 f5 ff ff       	jmp    80105d2c <alltraps>

8010675c <vector115>:
.globl vector115
vector115:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $115
8010675e:	6a 73                	push   $0x73
  jmp alltraps
80106760:	e9 c7 f5 ff ff       	jmp    80105d2c <alltraps>

80106765 <vector116>:
.globl vector116
vector116:
  pushl $0
80106765:	6a 00                	push   $0x0
  pushl $116
80106767:	6a 74                	push   $0x74
  jmp alltraps
80106769:	e9 be f5 ff ff       	jmp    80105d2c <alltraps>

8010676e <vector117>:
.globl vector117
vector117:
  pushl $0
8010676e:	6a 00                	push   $0x0
  pushl $117
80106770:	6a 75                	push   $0x75
  jmp alltraps
80106772:	e9 b5 f5 ff ff       	jmp    80105d2c <alltraps>

80106777 <vector118>:
.globl vector118
vector118:
  pushl $0
80106777:	6a 00                	push   $0x0
  pushl $118
80106779:	6a 76                	push   $0x76
  jmp alltraps
8010677b:	e9 ac f5 ff ff       	jmp    80105d2c <alltraps>

80106780 <vector119>:
.globl vector119
vector119:
  pushl $0
80106780:	6a 00                	push   $0x0
  pushl $119
80106782:	6a 77                	push   $0x77
  jmp alltraps
80106784:	e9 a3 f5 ff ff       	jmp    80105d2c <alltraps>

80106789 <vector120>:
.globl vector120
vector120:
  pushl $0
80106789:	6a 00                	push   $0x0
  pushl $120
8010678b:	6a 78                	push   $0x78
  jmp alltraps
8010678d:	e9 9a f5 ff ff       	jmp    80105d2c <alltraps>

80106792 <vector121>:
.globl vector121
vector121:
  pushl $0
80106792:	6a 00                	push   $0x0
  pushl $121
80106794:	6a 79                	push   $0x79
  jmp alltraps
80106796:	e9 91 f5 ff ff       	jmp    80105d2c <alltraps>

8010679b <vector122>:
.globl vector122
vector122:
  pushl $0
8010679b:	6a 00                	push   $0x0
  pushl $122
8010679d:	6a 7a                	push   $0x7a
  jmp alltraps
8010679f:	e9 88 f5 ff ff       	jmp    80105d2c <alltraps>

801067a4 <vector123>:
.globl vector123
vector123:
  pushl $0
801067a4:	6a 00                	push   $0x0
  pushl $123
801067a6:	6a 7b                	push   $0x7b
  jmp alltraps
801067a8:	e9 7f f5 ff ff       	jmp    80105d2c <alltraps>

801067ad <vector124>:
.globl vector124
vector124:
  pushl $0
801067ad:	6a 00                	push   $0x0
  pushl $124
801067af:	6a 7c                	push   $0x7c
  jmp alltraps
801067b1:	e9 76 f5 ff ff       	jmp    80105d2c <alltraps>

801067b6 <vector125>:
.globl vector125
vector125:
  pushl $0
801067b6:	6a 00                	push   $0x0
  pushl $125
801067b8:	6a 7d                	push   $0x7d
  jmp alltraps
801067ba:	e9 6d f5 ff ff       	jmp    80105d2c <alltraps>

801067bf <vector126>:
.globl vector126
vector126:
  pushl $0
801067bf:	6a 00                	push   $0x0
  pushl $126
801067c1:	6a 7e                	push   $0x7e
  jmp alltraps
801067c3:	e9 64 f5 ff ff       	jmp    80105d2c <alltraps>

801067c8 <vector127>:
.globl vector127
vector127:
  pushl $0
801067c8:	6a 00                	push   $0x0
  pushl $127
801067ca:	6a 7f                	push   $0x7f
  jmp alltraps
801067cc:	e9 5b f5 ff ff       	jmp    80105d2c <alltraps>

801067d1 <vector128>:
.globl vector128
vector128:
  pushl $0
801067d1:	6a 00                	push   $0x0
  pushl $128
801067d3:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801067d8:	e9 4f f5 ff ff       	jmp    80105d2c <alltraps>

801067dd <vector129>:
.globl vector129
vector129:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $129
801067df:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801067e4:	e9 43 f5 ff ff       	jmp    80105d2c <alltraps>

801067e9 <vector130>:
.globl vector130
vector130:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $130
801067eb:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801067f0:	e9 37 f5 ff ff       	jmp    80105d2c <alltraps>

801067f5 <vector131>:
.globl vector131
vector131:
  pushl $0
801067f5:	6a 00                	push   $0x0
  pushl $131
801067f7:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801067fc:	e9 2b f5 ff ff       	jmp    80105d2c <alltraps>

80106801 <vector132>:
.globl vector132
vector132:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $132
80106803:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106808:	e9 1f f5 ff ff       	jmp    80105d2c <alltraps>

8010680d <vector133>:
.globl vector133
vector133:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $133
8010680f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106814:	e9 13 f5 ff ff       	jmp    80105d2c <alltraps>

80106819 <vector134>:
.globl vector134
vector134:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $134
8010681b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106820:	e9 07 f5 ff ff       	jmp    80105d2c <alltraps>

80106825 <vector135>:
.globl vector135
vector135:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $135
80106827:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010682c:	e9 fb f4 ff ff       	jmp    80105d2c <alltraps>

80106831 <vector136>:
.globl vector136
vector136:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $136
80106833:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106838:	e9 ef f4 ff ff       	jmp    80105d2c <alltraps>

8010683d <vector137>:
.globl vector137
vector137:
  pushl $0
8010683d:	6a 00                	push   $0x0
  pushl $137
8010683f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106844:	e9 e3 f4 ff ff       	jmp    80105d2c <alltraps>

80106849 <vector138>:
.globl vector138
vector138:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $138
8010684b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106850:	e9 d7 f4 ff ff       	jmp    80105d2c <alltraps>

80106855 <vector139>:
.globl vector139
vector139:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $139
80106857:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010685c:	e9 cb f4 ff ff       	jmp    80105d2c <alltraps>

80106861 <vector140>:
.globl vector140
vector140:
  pushl $0
80106861:	6a 00                	push   $0x0
  pushl $140
80106863:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106868:	e9 bf f4 ff ff       	jmp    80105d2c <alltraps>

8010686d <vector141>:
.globl vector141
vector141:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $141
8010686f:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106874:	e9 b3 f4 ff ff       	jmp    80105d2c <alltraps>

80106879 <vector142>:
.globl vector142
vector142:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $142
8010687b:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106880:	e9 a7 f4 ff ff       	jmp    80105d2c <alltraps>

80106885 <vector143>:
.globl vector143
vector143:
  pushl $0
80106885:	6a 00                	push   $0x0
  pushl $143
80106887:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010688c:	e9 9b f4 ff ff       	jmp    80105d2c <alltraps>

80106891 <vector144>:
.globl vector144
vector144:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $144
80106893:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106898:	e9 8f f4 ff ff       	jmp    80105d2c <alltraps>

8010689d <vector145>:
.globl vector145
vector145:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $145
8010689f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068a4:	e9 83 f4 ff ff       	jmp    80105d2c <alltraps>

801068a9 <vector146>:
.globl vector146
vector146:
  pushl $0
801068a9:	6a 00                	push   $0x0
  pushl $146
801068ab:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801068b0:	e9 77 f4 ff ff       	jmp    80105d2c <alltraps>

801068b5 <vector147>:
.globl vector147
vector147:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $147
801068b7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801068bc:	e9 6b f4 ff ff       	jmp    80105d2c <alltraps>

801068c1 <vector148>:
.globl vector148
vector148:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $148
801068c3:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801068c8:	e9 5f f4 ff ff       	jmp    80105d2c <alltraps>

801068cd <vector149>:
.globl vector149
vector149:
  pushl $0
801068cd:	6a 00                	push   $0x0
  pushl $149
801068cf:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801068d4:	e9 53 f4 ff ff       	jmp    80105d2c <alltraps>

801068d9 <vector150>:
.globl vector150
vector150:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $150
801068db:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801068e0:	e9 47 f4 ff ff       	jmp    80105d2c <alltraps>

801068e5 <vector151>:
.globl vector151
vector151:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $151
801068e7:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801068ec:	e9 3b f4 ff ff       	jmp    80105d2c <alltraps>

801068f1 <vector152>:
.globl vector152
vector152:
  pushl $0
801068f1:	6a 00                	push   $0x0
  pushl $152
801068f3:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801068f8:	e9 2f f4 ff ff       	jmp    80105d2c <alltraps>

801068fd <vector153>:
.globl vector153
vector153:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $153
801068ff:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106904:	e9 23 f4 ff ff       	jmp    80105d2c <alltraps>

80106909 <vector154>:
.globl vector154
vector154:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $154
8010690b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106910:	e9 17 f4 ff ff       	jmp    80105d2c <alltraps>

80106915 <vector155>:
.globl vector155
vector155:
  pushl $0
80106915:	6a 00                	push   $0x0
  pushl $155
80106917:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010691c:	e9 0b f4 ff ff       	jmp    80105d2c <alltraps>

80106921 <vector156>:
.globl vector156
vector156:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $156
80106923:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106928:	e9 ff f3 ff ff       	jmp    80105d2c <alltraps>

8010692d <vector157>:
.globl vector157
vector157:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $157
8010692f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106934:	e9 f3 f3 ff ff       	jmp    80105d2c <alltraps>

80106939 <vector158>:
.globl vector158
vector158:
  pushl $0
80106939:	6a 00                	push   $0x0
  pushl $158
8010693b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106940:	e9 e7 f3 ff ff       	jmp    80105d2c <alltraps>

80106945 <vector159>:
.globl vector159
vector159:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $159
80106947:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010694c:	e9 db f3 ff ff       	jmp    80105d2c <alltraps>

80106951 <vector160>:
.globl vector160
vector160:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $160
80106953:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106958:	e9 cf f3 ff ff       	jmp    80105d2c <alltraps>

8010695d <vector161>:
.globl vector161
vector161:
  pushl $0
8010695d:	6a 00                	push   $0x0
  pushl $161
8010695f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106964:	e9 c3 f3 ff ff       	jmp    80105d2c <alltraps>

80106969 <vector162>:
.globl vector162
vector162:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $162
8010696b:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106970:	e9 b7 f3 ff ff       	jmp    80105d2c <alltraps>

80106975 <vector163>:
.globl vector163
vector163:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $163
80106977:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010697c:	e9 ab f3 ff ff       	jmp    80105d2c <alltraps>

80106981 <vector164>:
.globl vector164
vector164:
  pushl $0
80106981:	6a 00                	push   $0x0
  pushl $164
80106983:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106988:	e9 9f f3 ff ff       	jmp    80105d2c <alltraps>

8010698d <vector165>:
.globl vector165
vector165:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $165
8010698f:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106994:	e9 93 f3 ff ff       	jmp    80105d2c <alltraps>

80106999 <vector166>:
.globl vector166
vector166:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $166
8010699b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069a0:	e9 87 f3 ff ff       	jmp    80105d2c <alltraps>

801069a5 <vector167>:
.globl vector167
vector167:
  pushl $0
801069a5:	6a 00                	push   $0x0
  pushl $167
801069a7:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801069ac:	e9 7b f3 ff ff       	jmp    80105d2c <alltraps>

801069b1 <vector168>:
.globl vector168
vector168:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $168
801069b3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801069b8:	e9 6f f3 ff ff       	jmp    80105d2c <alltraps>

801069bd <vector169>:
.globl vector169
vector169:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $169
801069bf:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801069c4:	e9 63 f3 ff ff       	jmp    80105d2c <alltraps>

801069c9 <vector170>:
.globl vector170
vector170:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $170
801069cb:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801069d0:	e9 57 f3 ff ff       	jmp    80105d2c <alltraps>

801069d5 <vector171>:
.globl vector171
vector171:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $171
801069d7:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801069dc:	e9 4b f3 ff ff       	jmp    80105d2c <alltraps>

801069e1 <vector172>:
.globl vector172
vector172:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $172
801069e3:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801069e8:	e9 3f f3 ff ff       	jmp    80105d2c <alltraps>

801069ed <vector173>:
.globl vector173
vector173:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $173
801069ef:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801069f4:	e9 33 f3 ff ff       	jmp    80105d2c <alltraps>

801069f9 <vector174>:
.globl vector174
vector174:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $174
801069fb:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a00:	e9 27 f3 ff ff       	jmp    80105d2c <alltraps>

80106a05 <vector175>:
.globl vector175
vector175:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $175
80106a07:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a0c:	e9 1b f3 ff ff       	jmp    80105d2c <alltraps>

80106a11 <vector176>:
.globl vector176
vector176:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $176
80106a13:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a18:	e9 0f f3 ff ff       	jmp    80105d2c <alltraps>

80106a1d <vector177>:
.globl vector177
vector177:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $177
80106a1f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a24:	e9 03 f3 ff ff       	jmp    80105d2c <alltraps>

80106a29 <vector178>:
.globl vector178
vector178:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $178
80106a2b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a30:	e9 f7 f2 ff ff       	jmp    80105d2c <alltraps>

80106a35 <vector179>:
.globl vector179
vector179:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $179
80106a37:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a3c:	e9 eb f2 ff ff       	jmp    80105d2c <alltraps>

80106a41 <vector180>:
.globl vector180
vector180:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $180
80106a43:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106a48:	e9 df f2 ff ff       	jmp    80105d2c <alltraps>

80106a4d <vector181>:
.globl vector181
vector181:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $181
80106a4f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106a54:	e9 d3 f2 ff ff       	jmp    80105d2c <alltraps>

80106a59 <vector182>:
.globl vector182
vector182:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $182
80106a5b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106a60:	e9 c7 f2 ff ff       	jmp    80105d2c <alltraps>

80106a65 <vector183>:
.globl vector183
vector183:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $183
80106a67:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106a6c:	e9 bb f2 ff ff       	jmp    80105d2c <alltraps>

80106a71 <vector184>:
.globl vector184
vector184:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $184
80106a73:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106a78:	e9 af f2 ff ff       	jmp    80105d2c <alltraps>

80106a7d <vector185>:
.globl vector185
vector185:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $185
80106a7f:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106a84:	e9 a3 f2 ff ff       	jmp    80105d2c <alltraps>

80106a89 <vector186>:
.globl vector186
vector186:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $186
80106a8b:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106a90:	e9 97 f2 ff ff       	jmp    80105d2c <alltraps>

80106a95 <vector187>:
.globl vector187
vector187:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $187
80106a97:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106a9c:	e9 8b f2 ff ff       	jmp    80105d2c <alltraps>

80106aa1 <vector188>:
.globl vector188
vector188:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $188
80106aa3:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106aa8:	e9 7f f2 ff ff       	jmp    80105d2c <alltraps>

80106aad <vector189>:
.globl vector189
vector189:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $189
80106aaf:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ab4:	e9 73 f2 ff ff       	jmp    80105d2c <alltraps>

80106ab9 <vector190>:
.globl vector190
vector190:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $190
80106abb:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ac0:	e9 67 f2 ff ff       	jmp    80105d2c <alltraps>

80106ac5 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $191
80106ac7:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106acc:	e9 5b f2 ff ff       	jmp    80105d2c <alltraps>

80106ad1 <vector192>:
.globl vector192
vector192:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $192
80106ad3:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106ad8:	e9 4f f2 ff ff       	jmp    80105d2c <alltraps>

80106add <vector193>:
.globl vector193
vector193:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $193
80106adf:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ae4:	e9 43 f2 ff ff       	jmp    80105d2c <alltraps>

80106ae9 <vector194>:
.globl vector194
vector194:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $194
80106aeb:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106af0:	e9 37 f2 ff ff       	jmp    80105d2c <alltraps>

80106af5 <vector195>:
.globl vector195
vector195:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $195
80106af7:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106afc:	e9 2b f2 ff ff       	jmp    80105d2c <alltraps>

80106b01 <vector196>:
.globl vector196
vector196:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $196
80106b03:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b08:	e9 1f f2 ff ff       	jmp    80105d2c <alltraps>

80106b0d <vector197>:
.globl vector197
vector197:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $197
80106b0f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b14:	e9 13 f2 ff ff       	jmp    80105d2c <alltraps>

80106b19 <vector198>:
.globl vector198
vector198:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $198
80106b1b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b20:	e9 07 f2 ff ff       	jmp    80105d2c <alltraps>

80106b25 <vector199>:
.globl vector199
vector199:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $199
80106b27:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b2c:	e9 fb f1 ff ff       	jmp    80105d2c <alltraps>

80106b31 <vector200>:
.globl vector200
vector200:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $200
80106b33:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b38:	e9 ef f1 ff ff       	jmp    80105d2c <alltraps>

80106b3d <vector201>:
.globl vector201
vector201:
  pushl $0
80106b3d:	6a 00                	push   $0x0
  pushl $201
80106b3f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b44:	e9 e3 f1 ff ff       	jmp    80105d2c <alltraps>

80106b49 <vector202>:
.globl vector202
vector202:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $202
80106b4b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106b50:	e9 d7 f1 ff ff       	jmp    80105d2c <alltraps>

80106b55 <vector203>:
.globl vector203
vector203:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $203
80106b57:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106b5c:	e9 cb f1 ff ff       	jmp    80105d2c <alltraps>

80106b61 <vector204>:
.globl vector204
vector204:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $204
80106b63:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106b68:	e9 bf f1 ff ff       	jmp    80105d2c <alltraps>

80106b6d <vector205>:
.globl vector205
vector205:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $205
80106b6f:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106b74:	e9 b3 f1 ff ff       	jmp    80105d2c <alltraps>

80106b79 <vector206>:
.globl vector206
vector206:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $206
80106b7b:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106b80:	e9 a7 f1 ff ff       	jmp    80105d2c <alltraps>

80106b85 <vector207>:
.globl vector207
vector207:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $207
80106b87:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106b8c:	e9 9b f1 ff ff       	jmp    80105d2c <alltraps>

80106b91 <vector208>:
.globl vector208
vector208:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $208
80106b93:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106b98:	e9 8f f1 ff ff       	jmp    80105d2c <alltraps>

80106b9d <vector209>:
.globl vector209
vector209:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $209
80106b9f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106ba4:	e9 83 f1 ff ff       	jmp    80105d2c <alltraps>

80106ba9 <vector210>:
.globl vector210
vector210:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $210
80106bab:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106bb0:	e9 77 f1 ff ff       	jmp    80105d2c <alltraps>

80106bb5 <vector211>:
.globl vector211
vector211:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $211
80106bb7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106bbc:	e9 6b f1 ff ff       	jmp    80105d2c <alltraps>

80106bc1 <vector212>:
.globl vector212
vector212:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $212
80106bc3:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106bc8:	e9 5f f1 ff ff       	jmp    80105d2c <alltraps>

80106bcd <vector213>:
.globl vector213
vector213:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $213
80106bcf:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106bd4:	e9 53 f1 ff ff       	jmp    80105d2c <alltraps>

80106bd9 <vector214>:
.globl vector214
vector214:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $214
80106bdb:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106be0:	e9 47 f1 ff ff       	jmp    80105d2c <alltraps>

80106be5 <vector215>:
.globl vector215
vector215:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $215
80106be7:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106bec:	e9 3b f1 ff ff       	jmp    80105d2c <alltraps>

80106bf1 <vector216>:
.globl vector216
vector216:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $216
80106bf3:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106bf8:	e9 2f f1 ff ff       	jmp    80105d2c <alltraps>

80106bfd <vector217>:
.globl vector217
vector217:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $217
80106bff:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c04:	e9 23 f1 ff ff       	jmp    80105d2c <alltraps>

80106c09 <vector218>:
.globl vector218
vector218:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $218
80106c0b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c10:	e9 17 f1 ff ff       	jmp    80105d2c <alltraps>

80106c15 <vector219>:
.globl vector219
vector219:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $219
80106c17:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c1c:	e9 0b f1 ff ff       	jmp    80105d2c <alltraps>

80106c21 <vector220>:
.globl vector220
vector220:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $220
80106c23:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c28:	e9 ff f0 ff ff       	jmp    80105d2c <alltraps>

80106c2d <vector221>:
.globl vector221
vector221:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $221
80106c2f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c34:	e9 f3 f0 ff ff       	jmp    80105d2c <alltraps>

80106c39 <vector222>:
.globl vector222
vector222:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $222
80106c3b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c40:	e9 e7 f0 ff ff       	jmp    80105d2c <alltraps>

80106c45 <vector223>:
.globl vector223
vector223:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $223
80106c47:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106c4c:	e9 db f0 ff ff       	jmp    80105d2c <alltraps>

80106c51 <vector224>:
.globl vector224
vector224:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $224
80106c53:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106c58:	e9 cf f0 ff ff       	jmp    80105d2c <alltraps>

80106c5d <vector225>:
.globl vector225
vector225:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $225
80106c5f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106c64:	e9 c3 f0 ff ff       	jmp    80105d2c <alltraps>

80106c69 <vector226>:
.globl vector226
vector226:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $226
80106c6b:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106c70:	e9 b7 f0 ff ff       	jmp    80105d2c <alltraps>

80106c75 <vector227>:
.globl vector227
vector227:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $227
80106c77:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106c7c:	e9 ab f0 ff ff       	jmp    80105d2c <alltraps>

80106c81 <vector228>:
.globl vector228
vector228:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $228
80106c83:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106c88:	e9 9f f0 ff ff       	jmp    80105d2c <alltraps>

80106c8d <vector229>:
.globl vector229
vector229:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $229
80106c8f:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106c94:	e9 93 f0 ff ff       	jmp    80105d2c <alltraps>

80106c99 <vector230>:
.globl vector230
vector230:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $230
80106c9b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106ca0:	e9 87 f0 ff ff       	jmp    80105d2c <alltraps>

80106ca5 <vector231>:
.globl vector231
vector231:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $231
80106ca7:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106cac:	e9 7b f0 ff ff       	jmp    80105d2c <alltraps>

80106cb1 <vector232>:
.globl vector232
vector232:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $232
80106cb3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106cb8:	e9 6f f0 ff ff       	jmp    80105d2c <alltraps>

80106cbd <vector233>:
.globl vector233
vector233:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $233
80106cbf:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106cc4:	e9 63 f0 ff ff       	jmp    80105d2c <alltraps>

80106cc9 <vector234>:
.globl vector234
vector234:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $234
80106ccb:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106cd0:	e9 57 f0 ff ff       	jmp    80105d2c <alltraps>

80106cd5 <vector235>:
.globl vector235
vector235:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $235
80106cd7:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106cdc:	e9 4b f0 ff ff       	jmp    80105d2c <alltraps>

80106ce1 <vector236>:
.globl vector236
vector236:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $236
80106ce3:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106ce8:	e9 3f f0 ff ff       	jmp    80105d2c <alltraps>

80106ced <vector237>:
.globl vector237
vector237:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $237
80106cef:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106cf4:	e9 33 f0 ff ff       	jmp    80105d2c <alltraps>

80106cf9 <vector238>:
.globl vector238
vector238:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $238
80106cfb:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d00:	e9 27 f0 ff ff       	jmp    80105d2c <alltraps>

80106d05 <vector239>:
.globl vector239
vector239:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $239
80106d07:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d0c:	e9 1b f0 ff ff       	jmp    80105d2c <alltraps>

80106d11 <vector240>:
.globl vector240
vector240:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $240
80106d13:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d18:	e9 0f f0 ff ff       	jmp    80105d2c <alltraps>

80106d1d <vector241>:
.globl vector241
vector241:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $241
80106d1f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d24:	e9 03 f0 ff ff       	jmp    80105d2c <alltraps>

80106d29 <vector242>:
.globl vector242
vector242:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $242
80106d2b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d30:	e9 f7 ef ff ff       	jmp    80105d2c <alltraps>

80106d35 <vector243>:
.globl vector243
vector243:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $243
80106d37:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d3c:	e9 eb ef ff ff       	jmp    80105d2c <alltraps>

80106d41 <vector244>:
.globl vector244
vector244:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $244
80106d43:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106d48:	e9 df ef ff ff       	jmp    80105d2c <alltraps>

80106d4d <vector245>:
.globl vector245
vector245:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $245
80106d4f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106d54:	e9 d3 ef ff ff       	jmp    80105d2c <alltraps>

80106d59 <vector246>:
.globl vector246
vector246:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $246
80106d5b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106d60:	e9 c7 ef ff ff       	jmp    80105d2c <alltraps>

80106d65 <vector247>:
.globl vector247
vector247:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $247
80106d67:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106d6c:	e9 bb ef ff ff       	jmp    80105d2c <alltraps>

80106d71 <vector248>:
.globl vector248
vector248:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $248
80106d73:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106d78:	e9 af ef ff ff       	jmp    80105d2c <alltraps>

80106d7d <vector249>:
.globl vector249
vector249:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $249
80106d7f:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106d84:	e9 a3 ef ff ff       	jmp    80105d2c <alltraps>

80106d89 <vector250>:
.globl vector250
vector250:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $250
80106d8b:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106d90:	e9 97 ef ff ff       	jmp    80105d2c <alltraps>

80106d95 <vector251>:
.globl vector251
vector251:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $251
80106d97:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106d9c:	e9 8b ef ff ff       	jmp    80105d2c <alltraps>

80106da1 <vector252>:
.globl vector252
vector252:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $252
80106da3:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106da8:	e9 7f ef ff ff       	jmp    80105d2c <alltraps>

80106dad <vector253>:
.globl vector253
vector253:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $253
80106daf:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106db4:	e9 73 ef ff ff       	jmp    80105d2c <alltraps>

80106db9 <vector254>:
.globl vector254
vector254:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $254
80106dbb:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106dc0:	e9 67 ef ff ff       	jmp    80105d2c <alltraps>

80106dc5 <vector255>:
.globl vector255
vector255:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $255
80106dc7:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106dcc:	e9 5b ef ff ff       	jmp    80105d2c <alltraps>

80106dd1 <lgdt>:
{
80106dd1:	55                   	push   %ebp
80106dd2:	89 e5                	mov    %esp,%ebp
80106dd4:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dda:	83 e8 01             	sub    $0x1,%eax
80106ddd:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106de1:	8b 45 08             	mov    0x8(%ebp),%eax
80106de4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106de8:	8b 45 08             	mov    0x8(%ebp),%eax
80106deb:	c1 e8 10             	shr    $0x10,%eax
80106dee:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106df2:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106df5:	0f 01 10             	lgdtl  (%eax)
}
80106df8:	90                   	nop
80106df9:	c9                   	leave
80106dfa:	c3                   	ret

80106dfb <ltr>:
{
80106dfb:	55                   	push   %ebp
80106dfc:	89 e5                	mov    %esp,%ebp
80106dfe:	83 ec 04             	sub    $0x4,%esp
80106e01:	8b 45 08             	mov    0x8(%ebp),%eax
80106e04:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e08:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106e0c:	0f 00 d8             	ltr    %eax
}
80106e0f:	90                   	nop
80106e10:	c9                   	leave
80106e11:	c3                   	ret

80106e12 <lcr3>:

static inline void
lcr3(uint val)
{
80106e12:	55                   	push   %ebp
80106e13:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e15:	8b 45 08             	mov    0x8(%ebp),%eax
80106e18:	0f 22 d8             	mov    %eax,%cr3
}
80106e1b:	90                   	nop
80106e1c:	5d                   	pop    %ebp
80106e1d:	c3                   	ret

80106e1e <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106e1e:	55                   	push   %ebp
80106e1f:	89 e5                	mov    %esp,%ebp
80106e21:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106e24:	e8 74 cb ff ff       	call   8010399d <cpuid>
80106e29:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106e2f:	05 80 5a 19 80       	add    $0x80195a80,%eax
80106e34:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e3a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e43:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e4c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e53:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e57:	83 e2 f0             	and    $0xfffffff0,%edx
80106e5a:	83 ca 0a             	or     $0xa,%edx
80106e5d:	88 50 7d             	mov    %dl,0x7d(%eax)
80106e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e63:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e67:	83 ca 10             	or     $0x10,%edx
80106e6a:	88 50 7d             	mov    %dl,0x7d(%eax)
80106e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e70:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e74:	83 e2 9f             	and    $0xffffff9f,%edx
80106e77:	88 50 7d             	mov    %dl,0x7d(%eax)
80106e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e81:	83 ca 80             	or     $0xffffff80,%edx
80106e84:	88 50 7d             	mov    %dl,0x7d(%eax)
80106e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e8a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106e8e:	83 ca 0f             	or     $0xf,%edx
80106e91:	88 50 7e             	mov    %dl,0x7e(%eax)
80106e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e97:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106e9b:	83 e2 ef             	and    $0xffffffef,%edx
80106e9e:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ea8:	83 e2 df             	and    $0xffffffdf,%edx
80106eab:	88 50 7e             	mov    %dl,0x7e(%eax)
80106eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106eb5:	83 ca 40             	or     $0x40,%edx
80106eb8:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ec2:	83 ca 80             	or     $0xffffff80,%edx
80106ec5:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ecb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106ed9:	ff ff 
80106edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ede:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106ee5:	00 00 
80106ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eea:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106efb:	83 e2 f0             	and    $0xfffffff0,%edx
80106efe:	83 ca 02             	or     $0x2,%edx
80106f01:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f11:	83 ca 10             	or     $0x10,%edx
80106f14:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f24:	83 e2 9f             	and    $0xffffff9f,%edx
80106f27:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f30:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f37:	83 ca 80             	or     $0xffffff80,%edx
80106f3a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f43:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f4a:	83 ca 0f             	or     $0xf,%edx
80106f4d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f56:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f5d:	83 e2 ef             	and    $0xffffffef,%edx
80106f60:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f69:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f70:	83 e2 df             	and    $0xffffffdf,%edx
80106f73:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f83:	83 ca 40             	or     $0x40,%edx
80106f86:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f96:	83 ca 80             	or     $0xffffff80,%edx
80106f99:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fac:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106fb3:	ff ff 
80106fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb8:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80106fbf:	00 00 
80106fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc4:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80106fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fce:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80106fd5:	83 e2 f0             	and    $0xfffffff0,%edx
80106fd8:	83 ca 0a             	or     $0xa,%edx
80106fdb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80106fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80106feb:	83 ca 10             	or     $0x10,%edx
80106fee:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80106ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80106ffe:	83 ca 60             	or     $0x60,%edx
80107001:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107011:	83 ca 80             	or     $0xffffff80,%edx
80107014:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010701a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107024:	83 ca 0f             	or     $0xf,%edx
80107027:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010702d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107030:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107037:	83 e2 ef             	and    $0xffffffef,%edx
8010703a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107043:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010704a:	83 e2 df             	and    $0xffffffdf,%edx
8010704d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107056:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010705d:	83 ca 40             	or     $0x40,%edx
80107060:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107069:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107070:	83 ca 80             	or     $0xffffff80,%edx
80107073:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107086:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010708d:	ff ff 
8010708f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107092:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107099:	00 00 
8010709b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801070a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070af:	83 e2 f0             	and    $0xfffffff0,%edx
801070b2:	83 ca 02             	or     $0x2,%edx
801070b5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801070bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070be:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070c5:	83 ca 10             	or     $0x10,%edx
801070c8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801070ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070d8:	83 ca 60             	or     $0x60,%edx
801070db:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801070e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070eb:	83 ca 80             	or     $0xffffff80,%edx
801070ee:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801070f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801070fe:	83 ca 0f             	or     $0xf,%edx
80107101:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107111:	83 e2 ef             	and    $0xffffffef,%edx
80107114:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010711a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107124:	83 e2 df             	and    $0xffffffdf,%edx
80107127:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010712d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107130:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107137:	83 ca 40             	or     $0x40,%edx
8010713a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107143:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010714a:	83 ca 80             	or     $0xffffff80,%edx
8010714d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107156:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010715d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107160:	83 c0 70             	add    $0x70,%eax
80107163:	83 ec 08             	sub    $0x8,%esp
80107166:	6a 30                	push   $0x30
80107168:	50                   	push   %eax
80107169:	e8 63 fc ff ff       	call   80106dd1 <lgdt>
8010716e:	83 c4 10             	add    $0x10,%esp
}
80107171:	90                   	nop
80107172:	c9                   	leave
80107173:	c3                   	ret

80107174 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010717a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010717d:	c1 e8 16             	shr    $0x16,%eax
80107180:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107187:	8b 45 08             	mov    0x8(%ebp),%eax
8010718a:	01 d0                	add    %edx,%eax
8010718c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010718f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107192:	8b 00                	mov    (%eax),%eax
80107194:	83 e0 01             	and    $0x1,%eax
80107197:	85 c0                	test   %eax,%eax
80107199:	74 14                	je     801071af <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010719b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010719e:	8b 00                	mov    (%eax),%eax
801071a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071a5:	05 00 00 00 80       	add    $0x80000000,%eax
801071aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071ad:	eb 42                	jmp    801071f1 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801071af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071b3:	74 0e                	je     801071c3 <walkpgdir+0x4f>
801071b5:	e8 ee b5 ff ff       	call   801027a8 <kalloc>
801071ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071c1:	75 07                	jne    801071ca <walkpgdir+0x56>
      return 0;
801071c3:	b8 00 00 00 00       	mov    $0x0,%eax
801071c8:	eb 3e                	jmp    80107208 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801071ca:	83 ec 04             	sub    $0x4,%esp
801071cd:	68 00 10 00 00       	push   $0x1000
801071d2:	6a 00                	push   $0x0
801071d4:	ff 75 f4             	push   -0xc(%ebp)
801071d7:	e8 ac d7 ff ff       	call   80104988 <memset>
801071dc:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801071df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e2:	05 00 00 00 80       	add    $0x80000000,%eax
801071e7:	83 c8 07             	or     $0x7,%eax
801071ea:	89 c2                	mov    %eax,%edx
801071ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071ef:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801071f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801071f4:	c1 e8 0c             	shr    $0xc,%eax
801071f7:	25 ff 03 00 00       	and    $0x3ff,%eax
801071fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107206:	01 d0                	add    %edx,%eax
}
80107208:	c9                   	leave
80107209:	c3                   	ret

8010720a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010720a:	55                   	push   %ebp
8010720b:	89 e5                	mov    %esp,%ebp
8010720d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107210:	8b 45 0c             	mov    0xc(%ebp),%eax
80107213:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010721b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010721e:	8b 45 10             	mov    0x10(%ebp),%eax
80107221:	01 d0                	add    %edx,%eax
80107223:	83 e8 01             	sub    $0x1,%eax
80107226:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010722b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010722e:	83 ec 04             	sub    $0x4,%esp
80107231:	6a 01                	push   $0x1
80107233:	ff 75 f4             	push   -0xc(%ebp)
80107236:	ff 75 08             	push   0x8(%ebp)
80107239:	e8 36 ff ff ff       	call   80107174 <walkpgdir>
8010723e:	83 c4 10             	add    $0x10,%esp
80107241:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107244:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107248:	75 07                	jne    80107251 <mappages+0x47>
      return -1;
8010724a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010724f:	eb 47                	jmp    80107298 <mappages+0x8e>
    if(*pte & PTE_P)
80107251:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107254:	8b 00                	mov    (%eax),%eax
80107256:	83 e0 01             	and    $0x1,%eax
80107259:	85 c0                	test   %eax,%eax
8010725b:	74 0d                	je     8010726a <mappages+0x60>
      panic("remap");
8010725d:	83 ec 0c             	sub    $0xc,%esp
80107260:	68 28 a5 10 80       	push   $0x8010a528
80107265:	e8 3f 93 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010726a:	8b 45 18             	mov    0x18(%ebp),%eax
8010726d:	0b 45 14             	or     0x14(%ebp),%eax
80107270:	83 c8 01             	or     $0x1,%eax
80107273:	89 c2                	mov    %eax,%edx
80107275:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107278:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107280:	74 10                	je     80107292 <mappages+0x88>
      break;
    a += PGSIZE;
80107282:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107289:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107290:	eb 9c                	jmp    8010722e <mappages+0x24>
      break;
80107292:	90                   	nop
  }
  return 0;
80107293:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107298:	c9                   	leave
80107299:	c3                   	ret

8010729a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010729a:	55                   	push   %ebp
8010729b:	89 e5                	mov    %esp,%ebp
8010729d:	53                   	push   %ebx
8010729e:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801072a1:	c7 45 f4 80 e4 10 80 	movl   $0x8010e480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801072a8:	a1 50 5d 19 80       	mov    0x80195d50,%eax
801072ad:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801072b2:	29 c2                	sub    %eax,%edx
801072b4:	89 d0                	mov    %edx,%eax
801072b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801072b9:	a1 48 5d 19 80       	mov    0x80195d48,%eax
801072be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801072c1:	8b 15 48 5d 19 80    	mov    0x80195d48,%edx
801072c7:	a1 50 5d 19 80       	mov    0x80195d50,%eax
801072cc:	01 d0                	add    %edx,%eax
801072ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
801072d1:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801072d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072db:	83 c0 30             	add    $0x30,%eax
801072de:	8b 55 e0             	mov    -0x20(%ebp),%edx
801072e1:	89 10                	mov    %edx,(%eax)
801072e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801072e6:	89 50 04             	mov    %edx,0x4(%eax)
801072e9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801072ec:	89 50 08             	mov    %edx,0x8(%eax)
801072ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
801072f2:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801072f5:	e8 ae b4 ff ff       	call   801027a8 <kalloc>
801072fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801072fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107301:	75 07                	jne    8010730a <setupkvm+0x70>
    return 0;
80107303:	b8 00 00 00 00       	mov    $0x0,%eax
80107308:	eb 78                	jmp    80107382 <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
8010730a:	83 ec 04             	sub    $0x4,%esp
8010730d:	68 00 10 00 00       	push   $0x1000
80107312:	6a 00                	push   $0x0
80107314:	ff 75 f0             	push   -0x10(%ebp)
80107317:	e8 6c d6 ff ff       	call   80104988 <memset>
8010731c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010731f:	c7 45 f4 80 e4 10 80 	movl   $0x8010e480,-0xc(%ebp)
80107326:	eb 4e                	jmp    80107376 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010732e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107331:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107337:	8b 58 08             	mov    0x8(%eax),%ebx
8010733a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733d:	8b 40 04             	mov    0x4(%eax),%eax
80107340:	29 c3                	sub    %eax,%ebx
80107342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107345:	8b 00                	mov    (%eax),%eax
80107347:	83 ec 0c             	sub    $0xc,%esp
8010734a:	51                   	push   %ecx
8010734b:	52                   	push   %edx
8010734c:	53                   	push   %ebx
8010734d:	50                   	push   %eax
8010734e:	ff 75 f0             	push   -0x10(%ebp)
80107351:	e8 b4 fe ff ff       	call   8010720a <mappages>
80107356:	83 c4 20             	add    $0x20,%esp
80107359:	85 c0                	test   %eax,%eax
8010735b:	79 15                	jns    80107372 <setupkvm+0xd8>
      freevm(pgdir);
8010735d:	83 ec 0c             	sub    $0xc,%esp
80107360:	ff 75 f0             	push   -0x10(%ebp)
80107363:	e8 f5 04 00 00       	call   8010785d <freevm>
80107368:	83 c4 10             	add    $0x10,%esp
      return 0;
8010736b:	b8 00 00 00 00       	mov    $0x0,%eax
80107370:	eb 10                	jmp    80107382 <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107372:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107376:	81 7d f4 e0 e4 10 80 	cmpl   $0x8010e4e0,-0xc(%ebp)
8010737d:	72 a9                	jb     80107328 <setupkvm+0x8e>
    }
  return pgdir;
8010737f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107385:	c9                   	leave
80107386:	c3                   	ret

80107387 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107387:	55                   	push   %ebp
80107388:	89 e5                	mov    %esp,%ebp
8010738a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010738d:	e8 08 ff ff ff       	call   8010729a <setupkvm>
80107392:	a3 7c 5a 19 80       	mov    %eax,0x80195a7c
  switchkvm();
80107397:	e8 03 00 00 00       	call   8010739f <switchkvm>
}
8010739c:	90                   	nop
8010739d:	c9                   	leave
8010739e:	c3                   	ret

8010739f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010739f:	55                   	push   %ebp
801073a0:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073a2:	a1 7c 5a 19 80       	mov    0x80195a7c,%eax
801073a7:	05 00 00 00 80       	add    $0x80000000,%eax
801073ac:	50                   	push   %eax
801073ad:	e8 60 fa ff ff       	call   80106e12 <lcr3>
801073b2:	83 c4 04             	add    $0x4,%esp
}
801073b5:	90                   	nop
801073b6:	c9                   	leave
801073b7:	c3                   	ret

801073b8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801073b8:	55                   	push   %ebp
801073b9:	89 e5                	mov    %esp,%ebp
801073bb:	56                   	push   %esi
801073bc:	53                   	push   %ebx
801073bd:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801073c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801073c4:	75 0d                	jne    801073d3 <switchuvm+0x1b>
    panic("switchuvm: no process");
801073c6:	83 ec 0c             	sub    $0xc,%esp
801073c9:	68 2e a5 10 80       	push   $0x8010a52e
801073ce:	e8 d6 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801073d3:	8b 45 08             	mov    0x8(%ebp),%eax
801073d6:	8b 40 08             	mov    0x8(%eax),%eax
801073d9:	85 c0                	test   %eax,%eax
801073db:	75 0d                	jne    801073ea <switchuvm+0x32>
    panic("switchuvm: no kstack");
801073dd:	83 ec 0c             	sub    $0xc,%esp
801073e0:	68 44 a5 10 80       	push   $0x8010a544
801073e5:	e8 bf 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801073ea:	8b 45 08             	mov    0x8(%ebp),%eax
801073ed:	8b 40 04             	mov    0x4(%eax),%eax
801073f0:	85 c0                	test   %eax,%eax
801073f2:	75 0d                	jne    80107401 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801073f4:	83 ec 0c             	sub    $0xc,%esp
801073f7:	68 59 a5 10 80       	push   $0x8010a559
801073fc:	e8 a8 91 ff ff       	call   801005a9 <panic>

  pushcli();
80107401:	e8 77 d4 ff ff       	call   8010487d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107406:	e8 ad c5 ff ff       	call   801039b8 <mycpu>
8010740b:	89 c3                	mov    %eax,%ebx
8010740d:	e8 a6 c5 ff ff       	call   801039b8 <mycpu>
80107412:	83 c0 08             	add    $0x8,%eax
80107415:	89 c6                	mov    %eax,%esi
80107417:	e8 9c c5 ff ff       	call   801039b8 <mycpu>
8010741c:	83 c0 08             	add    $0x8,%eax
8010741f:	c1 e8 10             	shr    $0x10,%eax
80107422:	88 45 f7             	mov    %al,-0x9(%ebp)
80107425:	e8 8e c5 ff ff       	call   801039b8 <mycpu>
8010742a:	83 c0 08             	add    $0x8,%eax
8010742d:	c1 e8 18             	shr    $0x18,%eax
80107430:	89 c2                	mov    %eax,%edx
80107432:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107439:	67 00 
8010743b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107442:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107446:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010744c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107453:	83 e0 f0             	and    $0xfffffff0,%eax
80107456:	83 c8 09             	or     $0x9,%eax
80107459:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010745f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107466:	83 c8 10             	or     $0x10,%eax
80107469:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010746f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107476:	83 e0 9f             	and    $0xffffff9f,%eax
80107479:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010747f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107486:	83 c8 80             	or     $0xffffff80,%eax
80107489:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010748f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107496:	83 e0 f0             	and    $0xfffffff0,%eax
80107499:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010749f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074a6:	83 e0 ef             	and    $0xffffffef,%eax
801074a9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074af:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074b6:	83 e0 df             	and    $0xffffffdf,%eax
801074b9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074bf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074c6:	83 c8 40             	or     $0x40,%eax
801074c9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074cf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074d6:	83 e0 7f             	and    $0x7f,%eax
801074d9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074df:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801074e5:	e8 ce c4 ff ff       	call   801039b8 <mycpu>
801074ea:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801074f1:	83 e2 ef             	and    $0xffffffef,%edx
801074f4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801074fa:	e8 b9 c4 ff ff       	call   801039b8 <mycpu>
801074ff:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107505:	8b 45 08             	mov    0x8(%ebp),%eax
80107508:	8b 40 08             	mov    0x8(%eax),%eax
8010750b:	89 c3                	mov    %eax,%ebx
8010750d:	e8 a6 c4 ff ff       	call   801039b8 <mycpu>
80107512:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107518:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010751b:	e8 98 c4 ff ff       	call   801039b8 <mycpu>
80107520:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107526:	83 ec 0c             	sub    $0xc,%esp
80107529:	6a 28                	push   $0x28
8010752b:	e8 cb f8 ff ff       	call   80106dfb <ltr>
80107530:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107533:	8b 45 08             	mov    0x8(%ebp),%eax
80107536:	8b 40 04             	mov    0x4(%eax),%eax
80107539:	05 00 00 00 80       	add    $0x80000000,%eax
8010753e:	83 ec 0c             	sub    $0xc,%esp
80107541:	50                   	push   %eax
80107542:	e8 cb f8 ff ff       	call   80106e12 <lcr3>
80107547:	83 c4 10             	add    $0x10,%esp
  popcli();
8010754a:	e8 7b d3 ff ff       	call   801048ca <popcli>
}
8010754f:	90                   	nop
80107550:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107553:	5b                   	pop    %ebx
80107554:	5e                   	pop    %esi
80107555:	5d                   	pop    %ebp
80107556:	c3                   	ret

80107557 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107557:	55                   	push   %ebp
80107558:	89 e5                	mov    %esp,%ebp
8010755a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010755d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107564:	76 0d                	jbe    80107573 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107566:	83 ec 0c             	sub    $0xc,%esp
80107569:	68 6d a5 10 80       	push   $0x8010a56d
8010756e:	e8 36 90 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107573:	e8 30 b2 ff ff       	call   801027a8 <kalloc>
80107578:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010757b:	83 ec 04             	sub    $0x4,%esp
8010757e:	68 00 10 00 00       	push   $0x1000
80107583:	6a 00                	push   $0x0
80107585:	ff 75 f4             	push   -0xc(%ebp)
80107588:	e8 fb d3 ff ff       	call   80104988 <memset>
8010758d:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107593:	05 00 00 00 80       	add    $0x80000000,%eax
80107598:	83 ec 0c             	sub    $0xc,%esp
8010759b:	6a 06                	push   $0x6
8010759d:	50                   	push   %eax
8010759e:	68 00 10 00 00       	push   $0x1000
801075a3:	6a 00                	push   $0x0
801075a5:	ff 75 08             	push   0x8(%ebp)
801075a8:	e8 5d fc ff ff       	call   8010720a <mappages>
801075ad:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801075b0:	83 ec 04             	sub    $0x4,%esp
801075b3:	ff 75 10             	push   0x10(%ebp)
801075b6:	ff 75 0c             	push   0xc(%ebp)
801075b9:	ff 75 f4             	push   -0xc(%ebp)
801075bc:	e8 86 d4 ff ff       	call   80104a47 <memmove>
801075c1:	83 c4 10             	add    $0x10,%esp
}
801075c4:	90                   	nop
801075c5:	c9                   	leave
801075c6:	c3                   	ret

801075c7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801075c7:	55                   	push   %ebp
801075c8:	89 e5                	mov    %esp,%ebp
801075ca:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801075cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801075d0:	25 ff 0f 00 00       	and    $0xfff,%eax
801075d5:	85 c0                	test   %eax,%eax
801075d7:	74 0d                	je     801075e6 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801075d9:	83 ec 0c             	sub    $0xc,%esp
801075dc:	68 88 a5 10 80       	push   $0x8010a588
801075e1:	e8 c3 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801075e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075ed:	e9 8f 00 00 00       	jmp    80107681 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801075f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	01 d0                	add    %edx,%eax
801075fa:	83 ec 04             	sub    $0x4,%esp
801075fd:	6a 00                	push   $0x0
801075ff:	50                   	push   %eax
80107600:	ff 75 08             	push   0x8(%ebp)
80107603:	e8 6c fb ff ff       	call   80107174 <walkpgdir>
80107608:	83 c4 10             	add    $0x10,%esp
8010760b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010760e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107612:	75 0d                	jne    80107621 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107614:	83 ec 0c             	sub    $0xc,%esp
80107617:	68 ab a5 10 80       	push   $0x8010a5ab
8010761c:	e8 88 8f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107621:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107624:	8b 00                	mov    (%eax),%eax
80107626:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010762b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010762e:	8b 45 18             	mov    0x18(%ebp),%eax
80107631:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107634:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107639:	77 0b                	ja     80107646 <loaduvm+0x7f>
      n = sz - i;
8010763b:	8b 45 18             	mov    0x18(%ebp),%eax
8010763e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107641:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107644:	eb 07                	jmp    8010764d <loaduvm+0x86>
    else
      n = PGSIZE;
80107646:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010764d:	8b 55 14             	mov    0x14(%ebp),%edx
80107650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107653:	01 d0                	add    %edx,%eax
80107655:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107658:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010765e:	ff 75 f0             	push   -0x10(%ebp)
80107661:	50                   	push   %eax
80107662:	52                   	push   %edx
80107663:	ff 75 10             	push   0x10(%ebp)
80107666:	e8 73 a8 ff ff       	call   80101ede <readi>
8010766b:	83 c4 10             	add    $0x10,%esp
8010766e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107671:	74 07                	je     8010767a <loaduvm+0xb3>
      return -1;
80107673:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107678:	eb 18                	jmp    80107692 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
8010767a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107684:	3b 45 18             	cmp    0x18(%ebp),%eax
80107687:	0f 82 65 ff ff ff    	jb     801075f2 <loaduvm+0x2b>
  }
  return 0;
8010768d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107692:	c9                   	leave
80107693:	c3                   	ret

80107694 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107694:	55                   	push   %ebp
80107695:	89 e5                	mov    %esp,%ebp
80107697:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010769a:	8b 45 10             	mov    0x10(%ebp),%eax
8010769d:	85 c0                	test   %eax,%eax
8010769f:	79 0a                	jns    801076ab <allocuvm+0x17>
    return 0;
801076a1:	b8 00 00 00 00       	mov    $0x0,%eax
801076a6:	e9 ec 00 00 00       	jmp    80107797 <allocuvm+0x103>
  if(newsz < oldsz)
801076ab:	8b 45 10             	mov    0x10(%ebp),%eax
801076ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801076b1:	73 08                	jae    801076bb <allocuvm+0x27>
    return oldsz;
801076b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801076b6:	e9 dc 00 00 00       	jmp    80107797 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801076bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801076be:	05 ff 0f 00 00       	add    $0xfff,%eax
801076c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801076cb:	e9 b8 00 00 00       	jmp    80107788 <allocuvm+0xf4>
    mem = kalloc();
801076d0:	e8 d3 b0 ff ff       	call   801027a8 <kalloc>
801076d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801076d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076dc:	75 2e                	jne    8010770c <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801076de:	83 ec 0c             	sub    $0xc,%esp
801076e1:	68 c9 a5 10 80       	push   $0x8010a5c9
801076e6:	e8 09 8d ff ff       	call   801003f4 <cprintf>
801076eb:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801076ee:	83 ec 04             	sub    $0x4,%esp
801076f1:	ff 75 0c             	push   0xc(%ebp)
801076f4:	ff 75 10             	push   0x10(%ebp)
801076f7:	ff 75 08             	push   0x8(%ebp)
801076fa:	e8 9a 00 00 00       	call   80107799 <deallocuvm>
801076ff:	83 c4 10             	add    $0x10,%esp
      return 0;
80107702:	b8 00 00 00 00       	mov    $0x0,%eax
80107707:	e9 8b 00 00 00       	jmp    80107797 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010770c:	83 ec 04             	sub    $0x4,%esp
8010770f:	68 00 10 00 00       	push   $0x1000
80107714:	6a 00                	push   $0x0
80107716:	ff 75 f0             	push   -0x10(%ebp)
80107719:	e8 6a d2 ff ff       	call   80104988 <memset>
8010771e:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107724:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	83 ec 0c             	sub    $0xc,%esp
80107730:	6a 06                	push   $0x6
80107732:	52                   	push   %edx
80107733:	68 00 10 00 00       	push   $0x1000
80107738:	50                   	push   %eax
80107739:	ff 75 08             	push   0x8(%ebp)
8010773c:	e8 c9 fa ff ff       	call   8010720a <mappages>
80107741:	83 c4 20             	add    $0x20,%esp
80107744:	85 c0                	test   %eax,%eax
80107746:	79 39                	jns    80107781 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107748:	83 ec 0c             	sub    $0xc,%esp
8010774b:	68 e1 a5 10 80       	push   $0x8010a5e1
80107750:	e8 9f 8c ff ff       	call   801003f4 <cprintf>
80107755:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107758:	83 ec 04             	sub    $0x4,%esp
8010775b:	ff 75 0c             	push   0xc(%ebp)
8010775e:	ff 75 10             	push   0x10(%ebp)
80107761:	ff 75 08             	push   0x8(%ebp)
80107764:	e8 30 00 00 00       	call   80107799 <deallocuvm>
80107769:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010776c:	83 ec 0c             	sub    $0xc,%esp
8010776f:	ff 75 f0             	push   -0x10(%ebp)
80107772:	e8 97 af ff ff       	call   8010270e <kfree>
80107777:	83 c4 10             	add    $0x10,%esp
      return 0;
8010777a:	b8 00 00 00 00       	mov    $0x0,%eax
8010777f:	eb 16                	jmp    80107797 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107781:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010778e:	0f 82 3c ff ff ff    	jb     801076d0 <allocuvm+0x3c>
    }
  }
  return newsz;
80107794:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107797:	c9                   	leave
80107798:	c3                   	ret

80107799 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107799:	55                   	push   %ebp
8010779a:	89 e5                	mov    %esp,%ebp
8010779c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010779f:	8b 45 10             	mov    0x10(%ebp),%eax
801077a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077a5:	72 08                	jb     801077af <deallocuvm+0x16>
    return oldsz;
801077a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801077aa:	e9 ac 00 00 00       	jmp    8010785b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801077af:	8b 45 10             	mov    0x10(%ebp),%eax
801077b2:	05 ff 0f 00 00       	add    $0xfff,%eax
801077b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801077bf:	e9 88 00 00 00       	jmp    8010784c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801077c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c7:	83 ec 04             	sub    $0x4,%esp
801077ca:	6a 00                	push   $0x0
801077cc:	50                   	push   %eax
801077cd:	ff 75 08             	push   0x8(%ebp)
801077d0:	e8 9f f9 ff ff       	call   80107174 <walkpgdir>
801077d5:	83 c4 10             	add    $0x10,%esp
801077d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801077db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801077df:	75 16                	jne    801077f7 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801077e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e4:	c1 e8 16             	shr    $0x16,%eax
801077e7:	83 c0 01             	add    $0x1,%eax
801077ea:	c1 e0 16             	shl    $0x16,%eax
801077ed:	2d 00 10 00 00       	sub    $0x1000,%eax
801077f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077f5:	eb 4e                	jmp    80107845 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801077f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077fa:	8b 00                	mov    (%eax),%eax
801077fc:	83 e0 01             	and    $0x1,%eax
801077ff:	85 c0                	test   %eax,%eax
80107801:	74 42                	je     80107845 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107806:	8b 00                	mov    (%eax),%eax
80107808:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010780d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107810:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107814:	75 0d                	jne    80107823 <deallocuvm+0x8a>
        panic("kfree");
80107816:	83 ec 0c             	sub    $0xc,%esp
80107819:	68 fd a5 10 80       	push   $0x8010a5fd
8010781e:	e8 86 8d ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107823:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107826:	05 00 00 00 80       	add    $0x80000000,%eax
8010782b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010782e:	83 ec 0c             	sub    $0xc,%esp
80107831:	ff 75 e8             	push   -0x18(%ebp)
80107834:	e8 d5 ae ff ff       	call   8010270e <kfree>
80107839:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010783c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010783f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107845:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107852:	0f 82 6c ff ff ff    	jb     801077c4 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107858:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010785b:	c9                   	leave
8010785c:	c3                   	ret

8010785d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010785d:	55                   	push   %ebp
8010785e:	89 e5                	mov    %esp,%ebp
80107860:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107863:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107867:	75 0d                	jne    80107876 <freevm+0x19>
    panic("freevm: no pgdir");
80107869:	83 ec 0c             	sub    $0xc,%esp
8010786c:	68 03 a6 10 80       	push   $0x8010a603
80107871:	e8 33 8d ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107876:	83 ec 04             	sub    $0x4,%esp
80107879:	6a 00                	push   $0x0
8010787b:	68 00 00 00 80       	push   $0x80000000
80107880:	ff 75 08             	push   0x8(%ebp)
80107883:	e8 11 ff ff ff       	call   80107799 <deallocuvm>
80107888:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010788b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107892:	eb 48                	jmp    801078dc <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107897:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010789e:	8b 45 08             	mov    0x8(%ebp),%eax
801078a1:	01 d0                	add    %edx,%eax
801078a3:	8b 00                	mov    (%eax),%eax
801078a5:	83 e0 01             	and    $0x1,%eax
801078a8:	85 c0                	test   %eax,%eax
801078aa:	74 2c                	je     801078d8 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078b6:	8b 45 08             	mov    0x8(%ebp),%eax
801078b9:	01 d0                	add    %edx,%eax
801078bb:	8b 00                	mov    (%eax),%eax
801078bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078c2:	05 00 00 00 80       	add    $0x80000000,%eax
801078c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801078ca:	83 ec 0c             	sub    $0xc,%esp
801078cd:	ff 75 f0             	push   -0x10(%ebp)
801078d0:	e8 39 ae ff ff       	call   8010270e <kfree>
801078d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801078dc:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801078e3:	76 af                	jbe    80107894 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801078e5:	83 ec 0c             	sub    $0xc,%esp
801078e8:	ff 75 08             	push   0x8(%ebp)
801078eb:	e8 1e ae ff ff       	call   8010270e <kfree>
801078f0:	83 c4 10             	add    $0x10,%esp
}
801078f3:	90                   	nop
801078f4:	c9                   	leave
801078f5:	c3                   	ret

801078f6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801078f6:	55                   	push   %ebp
801078f7:	89 e5                	mov    %esp,%ebp
801078f9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801078fc:	83 ec 04             	sub    $0x4,%esp
801078ff:	6a 00                	push   $0x0
80107901:	ff 75 0c             	push   0xc(%ebp)
80107904:	ff 75 08             	push   0x8(%ebp)
80107907:	e8 68 f8 ff ff       	call   80107174 <walkpgdir>
8010790c:	83 c4 10             	add    $0x10,%esp
8010790f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107912:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107916:	75 0d                	jne    80107925 <clearpteu+0x2f>
    panic("clearpteu");
80107918:	83 ec 0c             	sub    $0xc,%esp
8010791b:	68 14 a6 10 80       	push   $0x8010a614
80107920:	e8 84 8c ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	8b 00                	mov    (%eax),%eax
8010792a:	83 e0 fb             	and    $0xfffffffb,%eax
8010792d:	89 c2                	mov    %eax,%edx
8010792f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107932:	89 10                	mov    %edx,(%eax)
}
80107934:	90                   	nop
80107935:	c9                   	leave
80107936:	c3                   	ret

80107937 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107937:	55                   	push   %ebp
80107938:	89 e5                	mov    %esp,%ebp
8010793a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010793d:	e8 58 f9 ff ff       	call   8010729a <setupkvm>
80107942:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107945:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107949:	75 0a                	jne    80107955 <copyuvm+0x1e>
    return 0;
8010794b:	b8 00 00 00 00       	mov    $0x0,%eax
80107950:	e9 eb 00 00 00       	jmp    80107a40 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010795c:	e9 b7 00 00 00       	jmp    80107a18 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107964:	83 ec 04             	sub    $0x4,%esp
80107967:	6a 00                	push   $0x0
80107969:	50                   	push   %eax
8010796a:	ff 75 08             	push   0x8(%ebp)
8010796d:	e8 02 f8 ff ff       	call   80107174 <walkpgdir>
80107972:	83 c4 10             	add    $0x10,%esp
80107975:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107978:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010797c:	75 0d                	jne    8010798b <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010797e:	83 ec 0c             	sub    $0xc,%esp
80107981:	68 1e a6 10 80       	push   $0x8010a61e
80107986:	e8 1e 8c ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
8010798b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010798e:	8b 00                	mov    (%eax),%eax
80107990:	83 e0 01             	and    $0x1,%eax
80107993:	85 c0                	test   %eax,%eax
80107995:	75 0d                	jne    801079a4 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107997:	83 ec 0c             	sub    $0xc,%esp
8010799a:	68 38 a6 10 80       	push   $0x8010a638
8010799f:	e8 05 8c ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801079a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079a7:	8b 00                	mov    (%eax),%eax
801079a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801079b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079b4:	8b 00                	mov    (%eax),%eax
801079b6:	25 ff 0f 00 00       	and    $0xfff,%eax
801079bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801079be:	e8 e5 ad ff ff       	call   801027a8 <kalloc>
801079c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801079ca:	74 5d                	je     80107a29 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801079cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801079cf:	05 00 00 00 80       	add    $0x80000000,%eax
801079d4:	83 ec 04             	sub    $0x4,%esp
801079d7:	68 00 10 00 00       	push   $0x1000
801079dc:	50                   	push   %eax
801079dd:	ff 75 e0             	push   -0x20(%ebp)
801079e0:	e8 62 d0 ff ff       	call   80104a47 <memmove>
801079e5:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801079e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801079eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801079ee:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	83 ec 0c             	sub    $0xc,%esp
801079fa:	52                   	push   %edx
801079fb:	51                   	push   %ecx
801079fc:	68 00 10 00 00       	push   $0x1000
80107a01:	50                   	push   %eax
80107a02:	ff 75 f0             	push   -0x10(%ebp)
80107a05:	e8 00 f8 ff ff       	call   8010720a <mappages>
80107a0a:	83 c4 20             	add    $0x20,%esp
80107a0d:	85 c0                	test   %eax,%eax
80107a0f:	78 1b                	js     80107a2c <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107a11:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a1e:	0f 82 3d ff ff ff    	jb     80107961 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a27:	eb 17                	jmp    80107a40 <copyuvm+0x109>
      goto bad;
80107a29:	90                   	nop
80107a2a:	eb 01                	jmp    80107a2d <copyuvm+0xf6>
      goto bad;
80107a2c:	90                   	nop

bad:
  freevm(d);
80107a2d:	83 ec 0c             	sub    $0xc,%esp
80107a30:	ff 75 f0             	push   -0x10(%ebp)
80107a33:	e8 25 fe ff ff       	call   8010785d <freevm>
80107a38:	83 c4 10             	add    $0x10,%esp
  return 0;
80107a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a40:	c9                   	leave
80107a41:	c3                   	ret

80107a42 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a42:	55                   	push   %ebp
80107a43:	89 e5                	mov    %esp,%ebp
80107a45:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a48:	83 ec 04             	sub    $0x4,%esp
80107a4b:	6a 00                	push   $0x0
80107a4d:	ff 75 0c             	push   0xc(%ebp)
80107a50:	ff 75 08             	push   0x8(%ebp)
80107a53:	e8 1c f7 ff ff       	call   80107174 <walkpgdir>
80107a58:	83 c4 10             	add    $0x10,%esp
80107a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a61:	8b 00                	mov    (%eax),%eax
80107a63:	83 e0 01             	and    $0x1,%eax
80107a66:	85 c0                	test   %eax,%eax
80107a68:	75 07                	jne    80107a71 <uva2ka+0x2f>
    return 0;
80107a6a:	b8 00 00 00 00       	mov    $0x0,%eax
80107a6f:	eb 22                	jmp    80107a93 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a74:	8b 00                	mov    (%eax),%eax
80107a76:	83 e0 04             	and    $0x4,%eax
80107a79:	85 c0                	test   %eax,%eax
80107a7b:	75 07                	jne    80107a84 <uva2ka+0x42>
    return 0;
80107a7d:	b8 00 00 00 00       	mov    $0x0,%eax
80107a82:	eb 0f                	jmp    80107a93 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	8b 00                	mov    (%eax),%eax
80107a89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a8e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107a93:	c9                   	leave
80107a94:	c3                   	ret

80107a95 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107a95:	55                   	push   %ebp
80107a96:	89 e5                	mov    %esp,%ebp
80107a98:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80107a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107aa1:	eb 7f                	jmp    80107b22 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107aae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ab1:	83 ec 08             	sub    $0x8,%esp
80107ab4:	50                   	push   %eax
80107ab5:	ff 75 08             	push   0x8(%ebp)
80107ab8:	e8 85 ff ff ff       	call   80107a42 <uva2ka>
80107abd:	83 c4 10             	add    $0x10,%esp
80107ac0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107ac3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107ac7:	75 07                	jne    80107ad0 <copyout+0x3b>
      return -1;
80107ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ace:	eb 61                	jmp    80107b31 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107ad0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ad3:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ad6:	05 00 10 00 00       	add    $0x1000,%eax
80107adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ae1:	39 45 14             	cmp    %eax,0x14(%ebp)
80107ae4:	73 06                	jae    80107aec <copyout+0x57>
      n = len;
80107ae6:	8b 45 14             	mov    0x14(%ebp),%eax
80107ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107aec:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aef:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107af2:	89 c2                	mov    %eax,%edx
80107af4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107af7:	01 d0                	add    %edx,%eax
80107af9:	83 ec 04             	sub    $0x4,%esp
80107afc:	ff 75 f0             	push   -0x10(%ebp)
80107aff:	ff 75 f4             	push   -0xc(%ebp)
80107b02:	50                   	push   %eax
80107b03:	e8 3f cf ff ff       	call   80104a47 <memmove>
80107b08:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b0e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b14:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b1a:	05 00 10 00 00       	add    $0x1000,%eax
80107b1f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107b22:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107b26:	0f 85 77 ff ff ff    	jne    80107aa3 <copyout+0xe>
  }
  return 0;
80107b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b31:	c9                   	leave
80107b32:	c3                   	ret

80107b33 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107b33:	55                   	push   %ebp
80107b34:	89 e5                	mov    %esp,%ebp
80107b36:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107b39:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107b40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107b43:	8b 40 08             	mov    0x8(%eax),%eax
80107b46:	05 00 00 00 80       	add    $0x80000000,%eax
80107b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107b4e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	8b 40 24             	mov    0x24(%eax),%eax
80107b5b:	a3 00 31 19 80       	mov    %eax,0x80193100
  ncpu = 0;
80107b60:	c7 05 40 5d 19 80 00 	movl   $0x0,0x80195d40
80107b67:	00 00 00 

  while(i<madt->len){
80107b6a:	e9 bd 00 00 00       	jmp    80107c2c <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80107b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107b72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107b75:	01 d0                	add    %edx,%eax
80107b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7d:	0f b6 00             	movzbl (%eax),%eax
80107b80:	0f b6 c0             	movzbl %al,%eax
80107b83:	83 f8 05             	cmp    $0x5,%eax
80107b86:	0f 87 a0 00 00 00    	ja     80107c2c <mpinit_uefi+0xf9>
80107b8c:	8b 04 85 54 a6 10 80 	mov    -0x7fef59ac(,%eax,4),%eax
80107b93:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107b9b:	a1 40 5d 19 80       	mov    0x80195d40,%eax
80107ba0:	83 f8 03             	cmp    $0x3,%eax
80107ba3:	7f 28                	jg     80107bcd <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107ba5:	8b 15 40 5d 19 80    	mov    0x80195d40,%edx
80107bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107bae:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107bb2:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107bb8:	81 c2 80 5a 19 80    	add    $0x80195a80,%edx
80107bbe:	88 02                	mov    %al,(%edx)
          ncpu++;
80107bc0:	a1 40 5d 19 80       	mov    0x80195d40,%eax
80107bc5:	83 c0 01             	add    $0x1,%eax
80107bc8:	a3 40 5d 19 80       	mov    %eax,0x80195d40
        }
        i += lapic_entry->record_len;
80107bcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107bd0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107bd4:	0f b6 c0             	movzbl %al,%eax
80107bd7:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107bda:	eb 50                	jmp    80107c2c <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107be5:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107be9:	a2 44 5d 19 80       	mov    %al,0x80195d44
        i += ioapic->record_len;
80107bee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107bf1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107bf5:	0f b6 c0             	movzbl %al,%eax
80107bf8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107bfb:	eb 2f                	jmp    80107c2c <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c0a:	0f b6 c0             	movzbl %al,%eax
80107c0d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c10:	eb 1a                	jmp    80107c2c <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c15:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c1b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c1f:	0f b6 c0             	movzbl %al,%eax
80107c22:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c25:	eb 05                	jmp    80107c2c <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80107c27:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107c2b:	90                   	nop
  while(i<madt->len){
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	8b 40 04             	mov    0x4(%eax),%eax
80107c32:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107c35:	0f 82 34 ff ff ff    	jb     80107b6f <mpinit_uefi+0x3c>
    }
  }

}
80107c3b:	90                   	nop
80107c3c:	90                   	nop
80107c3d:	c9                   	leave
80107c3e:	c3                   	ret

80107c3f <inb>:
{
80107c3f:	55                   	push   %ebp
80107c40:	89 e5                	mov    %esp,%ebp
80107c42:	83 ec 14             	sub    $0x14,%esp
80107c45:	8b 45 08             	mov    0x8(%ebp),%eax
80107c48:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107c4c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107c50:	89 c2                	mov    %eax,%edx
80107c52:	ec                   	in     (%dx),%al
80107c53:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107c56:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107c5a:	c9                   	leave
80107c5b:	c3                   	ret

80107c5c <outb>:
{
80107c5c:	55                   	push   %ebp
80107c5d:	89 e5                	mov    %esp,%ebp
80107c5f:	83 ec 08             	sub    $0x8,%esp
80107c62:	8b 55 08             	mov    0x8(%ebp),%edx
80107c65:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c68:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107c6c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107c6f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107c73:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107c77:	ee                   	out    %al,(%dx)
}
80107c78:	90                   	nop
80107c79:	c9                   	leave
80107c7a:	c3                   	ret

80107c7b <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107c7b:	55                   	push   %ebp
80107c7c:	89 e5                	mov    %esp,%ebp
80107c7e:	83 ec 28             	sub    $0x28,%esp
80107c81:	8b 45 08             	mov    0x8(%ebp),%eax
80107c84:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107c87:	6a 00                	push   $0x0
80107c89:	68 fa 03 00 00       	push   $0x3fa
80107c8e:	e8 c9 ff ff ff       	call   80107c5c <outb>
80107c93:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107c96:	68 80 00 00 00       	push   $0x80
80107c9b:	68 fb 03 00 00       	push   $0x3fb
80107ca0:	e8 b7 ff ff ff       	call   80107c5c <outb>
80107ca5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107ca8:	6a 0c                	push   $0xc
80107caa:	68 f8 03 00 00       	push   $0x3f8
80107caf:	e8 a8 ff ff ff       	call   80107c5c <outb>
80107cb4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107cb7:	6a 00                	push   $0x0
80107cb9:	68 f9 03 00 00       	push   $0x3f9
80107cbe:	e8 99 ff ff ff       	call   80107c5c <outb>
80107cc3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107cc6:	6a 03                	push   $0x3
80107cc8:	68 fb 03 00 00       	push   $0x3fb
80107ccd:	e8 8a ff ff ff       	call   80107c5c <outb>
80107cd2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107cd5:	6a 00                	push   $0x0
80107cd7:	68 fc 03 00 00       	push   $0x3fc
80107cdc:	e8 7b ff ff ff       	call   80107c5c <outb>
80107ce1:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107ce4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ceb:	eb 11                	jmp    80107cfe <uart_debug+0x83>
80107ced:	83 ec 0c             	sub    $0xc,%esp
80107cf0:	6a 0a                	push   $0xa
80107cf2:	e8 42 ae ff ff       	call   80102b39 <microdelay>
80107cf7:	83 c4 10             	add    $0x10,%esp
80107cfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cfe:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d02:	7f 1a                	jg     80107d1e <uart_debug+0xa3>
80107d04:	83 ec 0c             	sub    $0xc,%esp
80107d07:	68 fd 03 00 00       	push   $0x3fd
80107d0c:	e8 2e ff ff ff       	call   80107c3f <inb>
80107d11:	83 c4 10             	add    $0x10,%esp
80107d14:	0f b6 c0             	movzbl %al,%eax
80107d17:	83 e0 20             	and    $0x20,%eax
80107d1a:	85 c0                	test   %eax,%eax
80107d1c:	74 cf                	je     80107ced <uart_debug+0x72>
  outb(COM1+0, p);
80107d1e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107d22:	0f b6 c0             	movzbl %al,%eax
80107d25:	83 ec 08             	sub    $0x8,%esp
80107d28:	50                   	push   %eax
80107d29:	68 f8 03 00 00       	push   $0x3f8
80107d2e:	e8 29 ff ff ff       	call   80107c5c <outb>
80107d33:	83 c4 10             	add    $0x10,%esp
}
80107d36:	90                   	nop
80107d37:	c9                   	leave
80107d38:	c3                   	ret

80107d39 <uart_debugs>:

void uart_debugs(char *p){
80107d39:	55                   	push   %ebp
80107d3a:	89 e5                	mov    %esp,%ebp
80107d3c:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107d3f:	eb 1b                	jmp    80107d5c <uart_debugs+0x23>
    uart_debug(*p++);
80107d41:	8b 45 08             	mov    0x8(%ebp),%eax
80107d44:	8d 50 01             	lea    0x1(%eax),%edx
80107d47:	89 55 08             	mov    %edx,0x8(%ebp)
80107d4a:	0f b6 00             	movzbl (%eax),%eax
80107d4d:	0f be c0             	movsbl %al,%eax
80107d50:	83 ec 0c             	sub    $0xc,%esp
80107d53:	50                   	push   %eax
80107d54:	e8 22 ff ff ff       	call   80107c7b <uart_debug>
80107d59:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107d5f:	0f b6 00             	movzbl (%eax),%eax
80107d62:	84 c0                	test   %al,%al
80107d64:	75 db                	jne    80107d41 <uart_debugs+0x8>
  }
}
80107d66:	90                   	nop
80107d67:	90                   	nop
80107d68:	c9                   	leave
80107d69:	c3                   	ret

80107d6a <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107d6a:	55                   	push   %ebp
80107d6b:	89 e5                	mov    %esp,%ebp
80107d6d:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107d70:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107d7a:	8b 50 14             	mov    0x14(%eax),%edx
80107d7d:	8b 40 10             	mov    0x10(%eax),%eax
80107d80:	a3 48 5d 19 80       	mov    %eax,0x80195d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107d88:	8b 50 1c             	mov    0x1c(%eax),%edx
80107d8b:	8b 40 18             	mov    0x18(%eax),%eax
80107d8e:	a3 50 5d 19 80       	mov    %eax,0x80195d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107d93:	a1 50 5d 19 80       	mov    0x80195d50,%eax
80107d98:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107d9d:	29 c2                	sub    %eax,%edx
80107d9f:	89 15 4c 5d 19 80    	mov    %edx,0x80195d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107da5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107da8:	8b 50 24             	mov    0x24(%eax),%edx
80107dab:	8b 40 20             	mov    0x20(%eax),%eax
80107dae:	a3 54 5d 19 80       	mov    %eax,0x80195d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107db3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107db6:	8b 50 2c             	mov    0x2c(%eax),%edx
80107db9:	8b 40 28             	mov    0x28(%eax),%eax
80107dbc:	a3 58 5d 19 80       	mov    %eax,0x80195d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dc4:	8b 50 34             	mov    0x34(%eax),%edx
80107dc7:	8b 40 30             	mov    0x30(%eax),%eax
80107dca:	a3 5c 5d 19 80       	mov    %eax,0x80195d5c
}
80107dcf:	90                   	nop
80107dd0:	c9                   	leave
80107dd1:	c3                   	ret

80107dd2 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107dd2:	55                   	push   %ebp
80107dd3:	89 e5                	mov    %esp,%ebp
80107dd5:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107dd8:	8b 15 5c 5d 19 80    	mov    0x80195d5c,%edx
80107dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de1:	0f af d0             	imul   %eax,%edx
80107de4:	8b 45 08             	mov    0x8(%ebp),%eax
80107de7:	01 d0                	add    %edx,%eax
80107de9:	c1 e0 02             	shl    $0x2,%eax
80107dec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107def:	8b 15 4c 5d 19 80    	mov    0x80195d4c,%edx
80107df5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107df8:	01 d0                	add    %edx,%eax
80107dfa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107dfd:	8b 45 10             	mov    0x10(%ebp),%eax
80107e00:	0f b6 10             	movzbl (%eax),%edx
80107e03:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e06:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e08:	8b 45 10             	mov    0x10(%ebp),%eax
80107e0b:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107e0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e12:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107e15:	8b 45 10             	mov    0x10(%ebp),%eax
80107e18:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107e1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e1f:	88 50 02             	mov    %dl,0x2(%eax)
}
80107e22:	90                   	nop
80107e23:	c9                   	leave
80107e24:	c3                   	ret

80107e25 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107e25:	55                   	push   %ebp
80107e26:	89 e5                	mov    %esp,%ebp
80107e28:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107e2b:	8b 15 5c 5d 19 80    	mov    0x80195d5c,%edx
80107e31:	8b 45 08             	mov    0x8(%ebp),%eax
80107e34:	0f af c2             	imul   %edx,%eax
80107e37:	c1 e0 02             	shl    $0x2,%eax
80107e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107e3d:	8b 15 50 5d 19 80    	mov    0x80195d50,%edx
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	29 c2                	sub    %eax,%edx
80107e48:	8b 0d 4c 5d 19 80    	mov    0x80195d4c,%ecx
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	01 c8                	add    %ecx,%eax
80107e53:	89 c1                	mov    %eax,%ecx
80107e55:	a1 4c 5d 19 80       	mov    0x80195d4c,%eax
80107e5a:	83 ec 04             	sub    $0x4,%esp
80107e5d:	52                   	push   %edx
80107e5e:	51                   	push   %ecx
80107e5f:	50                   	push   %eax
80107e60:	e8 e2 cb ff ff       	call   80104a47 <memmove>
80107e65:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	8b 0d 4c 5d 19 80    	mov    0x80195d4c,%ecx
80107e71:	8b 15 50 5d 19 80    	mov    0x80195d50,%edx
80107e77:	01 d1                	add    %edx,%ecx
80107e79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e7c:	29 d1                	sub    %edx,%ecx
80107e7e:	89 ca                	mov    %ecx,%edx
80107e80:	83 ec 04             	sub    $0x4,%esp
80107e83:	50                   	push   %eax
80107e84:	6a 00                	push   $0x0
80107e86:	52                   	push   %edx
80107e87:	e8 fc ca ff ff       	call   80104988 <memset>
80107e8c:	83 c4 10             	add    $0x10,%esp
}
80107e8f:	90                   	nop
80107e90:	c9                   	leave
80107e91:	c3                   	ret

80107e92 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107e92:	55                   	push   %ebp
80107e93:	89 e5                	mov    %esp,%ebp
80107e95:	53                   	push   %ebx
80107e96:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ea0:	e9 b1 00 00 00       	jmp    80107f56 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107ea5:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107eac:	e9 97 00 00 00       	jmp    80107f48 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107eb1:	8b 45 10             	mov    0x10(%ebp),%eax
80107eb4:	83 e8 20             	sub    $0x20,%eax
80107eb7:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	01 d0                	add    %edx,%eax
80107ebf:	0f b7 84 00 80 a6 10 	movzwl -0x7fef5980(%eax,%eax,1),%eax
80107ec6:	80 
80107ec7:	0f b7 d0             	movzwl %ax,%edx
80107eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ecd:	bb 01 00 00 00       	mov    $0x1,%ebx
80107ed2:	89 c1                	mov    %eax,%ecx
80107ed4:	d3 e3                	shl    %cl,%ebx
80107ed6:	89 d8                	mov    %ebx,%eax
80107ed8:	21 d0                	and    %edx,%eax
80107eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee0:	ba 01 00 00 00       	mov    $0x1,%edx
80107ee5:	89 c1                	mov    %eax,%ecx
80107ee7:	d3 e2                	shl    %cl,%edx
80107ee9:	89 d0                	mov    %edx,%eax
80107eeb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107eee:	75 2b                	jne    80107f1b <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107ef0:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef6:	01 c2                	add    %eax,%edx
80107ef8:	b8 0e 00 00 00       	mov    $0xe,%eax
80107efd:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f00:	89 c1                	mov    %eax,%ecx
80107f02:	8b 45 08             	mov    0x8(%ebp),%eax
80107f05:	01 c8                	add    %ecx,%eax
80107f07:	83 ec 04             	sub    $0x4,%esp
80107f0a:	68 e0 e4 10 80       	push   $0x8010e4e0
80107f0f:	52                   	push   %edx
80107f10:	50                   	push   %eax
80107f11:	e8 bc fe ff ff       	call   80107dd2 <graphic_draw_pixel>
80107f16:	83 c4 10             	add    $0x10,%esp
80107f19:	eb 29                	jmp    80107f44 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107f1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	01 c2                	add    %eax,%edx
80107f23:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f28:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f2b:	89 c1                	mov    %eax,%ecx
80107f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f30:	01 c8                	add    %ecx,%eax
80107f32:	83 ec 04             	sub    $0x4,%esp
80107f35:	68 60 5d 19 80       	push   $0x80195d60
80107f3a:	52                   	push   %edx
80107f3b:	50                   	push   %eax
80107f3c:	e8 91 fe ff ff       	call   80107dd2 <graphic_draw_pixel>
80107f41:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107f44:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107f48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f4c:	0f 89 5f ff ff ff    	jns    80107eb1 <font_render+0x1f>
  for(int i=0;i<30;i++){
80107f52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f56:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107f5a:	0f 8e 45 ff ff ff    	jle    80107ea5 <font_render+0x13>
      }
    }
  }
}
80107f60:	90                   	nop
80107f61:	90                   	nop
80107f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f65:	c9                   	leave
80107f66:	c3                   	ret

80107f67 <font_render_string>:

void font_render_string(char *string,int row){
80107f67:	55                   	push   %ebp
80107f68:	89 e5                	mov    %esp,%ebp
80107f6a:	53                   	push   %ebx
80107f6b:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80107f6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80107f75:	eb 33                	jmp    80107faa <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80107f77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f7d:	01 d0                	add    %edx,%eax
80107f7f:	0f b6 00             	movzbl (%eax),%eax
80107f82:	0f be d8             	movsbl %al,%ebx
80107f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f88:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80107f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f8e:	89 d0                	mov    %edx,%eax
80107f90:	c1 e0 04             	shl    $0x4,%eax
80107f93:	29 d0                	sub    %edx,%eax
80107f95:	83 c0 02             	add    $0x2,%eax
80107f98:	83 ec 04             	sub    $0x4,%esp
80107f9b:	53                   	push   %ebx
80107f9c:	51                   	push   %ecx
80107f9d:	50                   	push   %eax
80107f9e:	e8 ef fe ff ff       	call   80107e92 <font_render>
80107fa3:	83 c4 10             	add    $0x10,%esp
    i++;
80107fa6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80107faa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fad:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb0:	01 d0                	add    %edx,%eax
80107fb2:	0f b6 00             	movzbl (%eax),%eax
80107fb5:	84 c0                	test   %al,%al
80107fb7:	74 06                	je     80107fbf <font_render_string+0x58>
80107fb9:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80107fbd:	7e b8                	jle    80107f77 <font_render_string+0x10>
  }
}
80107fbf:	90                   	nop
80107fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fc3:	c9                   	leave
80107fc4:	c3                   	ret

80107fc5 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80107fc5:	55                   	push   %ebp
80107fc6:	89 e5                	mov    %esp,%ebp
80107fc8:	53                   	push   %ebx
80107fc9:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80107fcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fd3:	eb 6b                	jmp    80108040 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80107fd5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80107fdc:	eb 58                	jmp    80108036 <pci_init+0x71>
      for(int k=0;k<8;k++){
80107fde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80107fe5:	eb 45                	jmp    8010802c <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80107fe7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80107fea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	83 ec 0c             	sub    $0xc,%esp
80107ff3:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80107ff6:	53                   	push   %ebx
80107ff7:	6a 00                	push   $0x0
80107ff9:	51                   	push   %ecx
80107ffa:	52                   	push   %edx
80107ffb:	50                   	push   %eax
80107ffc:	e8 b0 00 00 00       	call   801080b1 <pci_access_config>
80108001:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108007:	0f b7 c0             	movzwl %ax,%eax
8010800a:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010800f:	74 17                	je     80108028 <pci_init+0x63>
        pci_init_device(i,j,k);
80108011:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108014:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801a:	83 ec 04             	sub    $0x4,%esp
8010801d:	51                   	push   %ecx
8010801e:	52                   	push   %edx
8010801f:	50                   	push   %eax
80108020:	e8 37 01 00 00       	call   8010815c <pci_init_device>
80108025:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108028:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010802c:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108030:	7e b5                	jle    80107fe7 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108032:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108036:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010803a:	7e a2                	jle    80107fde <pci_init+0x19>
  for(int i=0;i<256;i++){
8010803c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108040:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108047:	7e 8c                	jle    80107fd5 <pci_init+0x10>
      }
      }
    }
  }
}
80108049:	90                   	nop
8010804a:	90                   	nop
8010804b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010804e:	c9                   	leave
8010804f:	c3                   	ret

80108050 <pci_write_config>:

void pci_write_config(uint config){
80108050:	55                   	push   %ebp
80108051:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108053:	8b 45 08             	mov    0x8(%ebp),%eax
80108056:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010805b:	89 c0                	mov    %eax,%eax
8010805d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010805e:	90                   	nop
8010805f:	5d                   	pop    %ebp
80108060:	c3                   	ret

80108061 <pci_write_data>:

void pci_write_data(uint config){
80108061:	55                   	push   %ebp
80108062:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108064:	8b 45 08             	mov    0x8(%ebp),%eax
80108067:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010806c:	89 c0                	mov    %eax,%eax
8010806e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010806f:	90                   	nop
80108070:	5d                   	pop    %ebp
80108071:	c3                   	ret

80108072 <pci_read_config>:
uint pci_read_config(){
80108072:	55                   	push   %ebp
80108073:	89 e5                	mov    %esp,%ebp
80108075:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108078:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010807d:	ed                   	in     (%dx),%eax
8010807e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108081:	83 ec 0c             	sub    $0xc,%esp
80108084:	68 c8 00 00 00       	push   $0xc8
80108089:	e8 ab aa ff ff       	call   80102b39 <microdelay>
8010808e:	83 c4 10             	add    $0x10,%esp
  return data;
80108091:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108094:	c9                   	leave
80108095:	c3                   	ret

80108096 <pci_test>:


void pci_test(){
80108096:	55                   	push   %ebp
80108097:	89 e5                	mov    %esp,%ebp
80108099:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010809c:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801080a3:	ff 75 fc             	push   -0x4(%ebp)
801080a6:	e8 a5 ff ff ff       	call   80108050 <pci_write_config>
801080ab:	83 c4 04             	add    $0x4,%esp
}
801080ae:	90                   	nop
801080af:	c9                   	leave
801080b0:	c3                   	ret

801080b1 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801080b1:	55                   	push   %ebp
801080b2:	89 e5                	mov    %esp,%ebp
801080b4:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801080b7:	8b 45 08             	mov    0x8(%ebp),%eax
801080ba:	c1 e0 10             	shl    $0x10,%eax
801080bd:	25 00 00 ff 00       	and    $0xff0000,%eax
801080c2:	89 c2                	mov    %eax,%edx
801080c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801080c7:	c1 e0 0b             	shl    $0xb,%eax
801080ca:	0f b7 c0             	movzwl %ax,%eax
801080cd:	09 c2                	or     %eax,%edx
801080cf:	8b 45 10             	mov    0x10(%ebp),%eax
801080d2:	c1 e0 08             	shl    $0x8,%eax
801080d5:	25 00 07 00 00       	and    $0x700,%eax
801080da:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801080dc:	8b 45 14             	mov    0x14(%ebp),%eax
801080df:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801080e4:	09 d0                	or     %edx,%eax
801080e6:	0d 00 00 00 80       	or     $0x80000000,%eax
801080eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801080ee:	ff 75 f4             	push   -0xc(%ebp)
801080f1:	e8 5a ff ff ff       	call   80108050 <pci_write_config>
801080f6:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801080f9:	e8 74 ff ff ff       	call   80108072 <pci_read_config>
801080fe:	8b 55 18             	mov    0x18(%ebp),%edx
80108101:	89 02                	mov    %eax,(%edx)
}
80108103:	90                   	nop
80108104:	c9                   	leave
80108105:	c3                   	ret

80108106 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108106:	55                   	push   %ebp
80108107:	89 e5                	mov    %esp,%ebp
80108109:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010810c:	8b 45 08             	mov    0x8(%ebp),%eax
8010810f:	c1 e0 10             	shl    $0x10,%eax
80108112:	25 00 00 ff 00       	and    $0xff0000,%eax
80108117:	89 c2                	mov    %eax,%edx
80108119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811c:	c1 e0 0b             	shl    $0xb,%eax
8010811f:	0f b7 c0             	movzwl %ax,%eax
80108122:	09 c2                	or     %eax,%edx
80108124:	8b 45 10             	mov    0x10(%ebp),%eax
80108127:	c1 e0 08             	shl    $0x8,%eax
8010812a:	25 00 07 00 00       	and    $0x700,%eax
8010812f:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108131:	8b 45 14             	mov    0x14(%ebp),%eax
80108134:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108139:	09 d0                	or     %edx,%eax
8010813b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108140:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108143:	ff 75 fc             	push   -0x4(%ebp)
80108146:	e8 05 ff ff ff       	call   80108050 <pci_write_config>
8010814b:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010814e:	ff 75 18             	push   0x18(%ebp)
80108151:	e8 0b ff ff ff       	call   80108061 <pci_write_data>
80108156:	83 c4 04             	add    $0x4,%esp
}
80108159:	90                   	nop
8010815a:	c9                   	leave
8010815b:	c3                   	ret

8010815c <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010815c:	55                   	push   %ebp
8010815d:	89 e5                	mov    %esp,%ebp
8010815f:	53                   	push   %ebx
80108160:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108163:	8b 45 08             	mov    0x8(%ebp),%eax
80108166:	a2 64 5d 19 80       	mov    %al,0x80195d64
  dev.device_num = device_num;
8010816b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010816e:	a2 65 5d 19 80       	mov    %al,0x80195d65
  dev.function_num = function_num;
80108173:	8b 45 10             	mov    0x10(%ebp),%eax
80108176:	a2 66 5d 19 80       	mov    %al,0x80195d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010817b:	ff 75 10             	push   0x10(%ebp)
8010817e:	ff 75 0c             	push   0xc(%ebp)
80108181:	ff 75 08             	push   0x8(%ebp)
80108184:	68 c4 bc 10 80       	push   $0x8010bcc4
80108189:	e8 66 82 ff ff       	call   801003f4 <cprintf>
8010818e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108191:	83 ec 0c             	sub    $0xc,%esp
80108194:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108197:	50                   	push   %eax
80108198:	6a 00                	push   $0x0
8010819a:	ff 75 10             	push   0x10(%ebp)
8010819d:	ff 75 0c             	push   0xc(%ebp)
801081a0:	ff 75 08             	push   0x8(%ebp)
801081a3:	e8 09 ff ff ff       	call   801080b1 <pci_access_config>
801081a8:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801081ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ae:	c1 e8 10             	shr    $0x10,%eax
801081b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801081b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081b7:	25 ff ff 00 00       	and    $0xffff,%eax
801081bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801081bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c2:	a3 68 5d 19 80       	mov    %eax,0x80195d68
  dev.vendor_id = vendor_id;
801081c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ca:	a3 6c 5d 19 80       	mov    %eax,0x80195d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801081cf:	83 ec 04             	sub    $0x4,%esp
801081d2:	ff 75 f0             	push   -0x10(%ebp)
801081d5:	ff 75 f4             	push   -0xc(%ebp)
801081d8:	68 f8 bc 10 80       	push   $0x8010bcf8
801081dd:	e8 12 82 ff ff       	call   801003f4 <cprintf>
801081e2:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801081e5:	83 ec 0c             	sub    $0xc,%esp
801081e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081eb:	50                   	push   %eax
801081ec:	6a 08                	push   $0x8
801081ee:	ff 75 10             	push   0x10(%ebp)
801081f1:	ff 75 0c             	push   0xc(%ebp)
801081f4:	ff 75 08             	push   0x8(%ebp)
801081f7:	e8 b5 fe ff ff       	call   801080b1 <pci_access_config>
801081fc:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801081ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108202:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108205:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108208:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010820b:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010820e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108211:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108214:	0f b6 c0             	movzbl %al,%eax
80108217:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010821a:	c1 eb 18             	shr    $0x18,%ebx
8010821d:	83 ec 0c             	sub    $0xc,%esp
80108220:	51                   	push   %ecx
80108221:	52                   	push   %edx
80108222:	50                   	push   %eax
80108223:	53                   	push   %ebx
80108224:	68 1c bd 10 80       	push   $0x8010bd1c
80108229:	e8 c6 81 ff ff       	call   801003f4 <cprintf>
8010822e:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108231:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108234:	c1 e8 18             	shr    $0x18,%eax
80108237:	a2 70 5d 19 80       	mov    %al,0x80195d70
  dev.sub_class = (data>>16)&0xFF;
8010823c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010823f:	c1 e8 10             	shr    $0x10,%eax
80108242:	a2 71 5d 19 80       	mov    %al,0x80195d71
  dev.interface = (data>>8)&0xFF;
80108247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824a:	c1 e8 08             	shr    $0x8,%eax
8010824d:	a2 72 5d 19 80       	mov    %al,0x80195d72
  dev.revision_id = data&0xFF;
80108252:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108255:	a2 73 5d 19 80       	mov    %al,0x80195d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010825a:	83 ec 0c             	sub    $0xc,%esp
8010825d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108260:	50                   	push   %eax
80108261:	6a 10                	push   $0x10
80108263:	ff 75 10             	push   0x10(%ebp)
80108266:	ff 75 0c             	push   0xc(%ebp)
80108269:	ff 75 08             	push   0x8(%ebp)
8010826c:	e8 40 fe ff ff       	call   801080b1 <pci_access_config>
80108271:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108274:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108277:	a3 74 5d 19 80       	mov    %eax,0x80195d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010827c:	83 ec 0c             	sub    $0xc,%esp
8010827f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108282:	50                   	push   %eax
80108283:	6a 14                	push   $0x14
80108285:	ff 75 10             	push   0x10(%ebp)
80108288:	ff 75 0c             	push   0xc(%ebp)
8010828b:	ff 75 08             	push   0x8(%ebp)
8010828e:	e8 1e fe ff ff       	call   801080b1 <pci_access_config>
80108293:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108296:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108299:	a3 78 5d 19 80       	mov    %eax,0x80195d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010829e:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801082a5:	75 5a                	jne    80108301 <pci_init_device+0x1a5>
801082a7:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801082ae:	75 51                	jne    80108301 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801082b0:	83 ec 0c             	sub    $0xc,%esp
801082b3:	68 61 bd 10 80       	push   $0x8010bd61
801082b8:	e8 37 81 ff ff       	call   801003f4 <cprintf>
801082bd:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801082c0:	83 ec 0c             	sub    $0xc,%esp
801082c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082c6:	50                   	push   %eax
801082c7:	68 f0 00 00 00       	push   $0xf0
801082cc:	ff 75 10             	push   0x10(%ebp)
801082cf:	ff 75 0c             	push   0xc(%ebp)
801082d2:	ff 75 08             	push   0x8(%ebp)
801082d5:	e8 d7 fd ff ff       	call   801080b1 <pci_access_config>
801082da:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801082dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e0:	83 ec 08             	sub    $0x8,%esp
801082e3:	50                   	push   %eax
801082e4:	68 7b bd 10 80       	push   $0x8010bd7b
801082e9:	e8 06 81 ff ff       	call   801003f4 <cprintf>
801082ee:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801082f1:	83 ec 0c             	sub    $0xc,%esp
801082f4:	68 64 5d 19 80       	push   $0x80195d64
801082f9:	e8 09 00 00 00       	call   80108307 <i8254_init>
801082fe:	83 c4 10             	add    $0x10,%esp
  }
}
80108301:	90                   	nop
80108302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108305:	c9                   	leave
80108306:	c3                   	ret

80108307 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108307:	55                   	push   %ebp
80108308:	89 e5                	mov    %esp,%ebp
8010830a:	53                   	push   %ebx
8010830b:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010830e:	8b 45 08             	mov    0x8(%ebp),%eax
80108311:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108315:	0f b6 c8             	movzbl %al,%ecx
80108318:	8b 45 08             	mov    0x8(%ebp),%eax
8010831b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010831f:	0f b6 d0             	movzbl %al,%edx
80108322:	8b 45 08             	mov    0x8(%ebp),%eax
80108325:	0f b6 00             	movzbl (%eax),%eax
80108328:	0f b6 c0             	movzbl %al,%eax
8010832b:	83 ec 0c             	sub    $0xc,%esp
8010832e:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108331:	53                   	push   %ebx
80108332:	6a 04                	push   $0x4
80108334:	51                   	push   %ecx
80108335:	52                   	push   %edx
80108336:	50                   	push   %eax
80108337:	e8 75 fd ff ff       	call   801080b1 <pci_access_config>
8010833c:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010833f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108342:	83 c8 04             	or     $0x4,%eax
80108345:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108348:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010834b:	8b 45 08             	mov    0x8(%ebp),%eax
8010834e:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108352:	0f b6 c8             	movzbl %al,%ecx
80108355:	8b 45 08             	mov    0x8(%ebp),%eax
80108358:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010835c:	0f b6 d0             	movzbl %al,%edx
8010835f:	8b 45 08             	mov    0x8(%ebp),%eax
80108362:	0f b6 00             	movzbl (%eax),%eax
80108365:	0f b6 c0             	movzbl %al,%eax
80108368:	83 ec 0c             	sub    $0xc,%esp
8010836b:	53                   	push   %ebx
8010836c:	6a 04                	push   $0x4
8010836e:	51                   	push   %ecx
8010836f:	52                   	push   %edx
80108370:	50                   	push   %eax
80108371:	e8 90 fd ff ff       	call   80108106 <pci_write_config_register>
80108376:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108379:	8b 45 08             	mov    0x8(%ebp),%eax
8010837c:	8b 40 10             	mov    0x10(%eax),%eax
8010837f:	05 00 00 00 40       	add    $0x40000000,%eax
80108384:	a3 7c 5d 19 80       	mov    %eax,0x80195d7c
  uint *ctrl = (uint *)base_addr;
80108389:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
8010838e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108391:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108396:	05 d8 00 00 00       	add    $0xd8,%eax
8010839b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010839e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083a1:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801083a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083aa:	8b 00                	mov    (%eax),%eax
801083ac:	0d 00 00 00 04       	or     $0x4000000,%eax
801083b1:	89 c2                	mov    %eax,%edx
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801083b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083bb:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801083c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c4:	8b 00                	mov    (%eax),%eax
801083c6:	83 c8 40             	or     $0x40,%eax
801083c9:	89 c2                	mov    %eax,%edx
801083cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ce:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	8b 10                	mov    (%eax),%edx
801083d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d8:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801083da:	83 ec 0c             	sub    $0xc,%esp
801083dd:	68 90 bd 10 80       	push   $0x8010bd90
801083e2:	e8 0d 80 ff ff       	call   801003f4 <cprintf>
801083e7:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801083ea:	e8 b9 a3 ff ff       	call   801027a8 <kalloc>
801083ef:	a3 88 5d 19 80       	mov    %eax,0x80195d88
  *intr_addr = 0;
801083f4:	a1 88 5d 19 80       	mov    0x80195d88,%eax
801083f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801083ff:	a1 88 5d 19 80       	mov    0x80195d88,%eax
80108404:	83 ec 08             	sub    $0x8,%esp
80108407:	50                   	push   %eax
80108408:	68 b2 bd 10 80       	push   $0x8010bdb2
8010840d:	e8 e2 7f ff ff       	call   801003f4 <cprintf>
80108412:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108415:	e8 50 00 00 00       	call   8010846a <i8254_init_recv>
  i8254_init_send();
8010841a:	e8 69 03 00 00       	call   80108788 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010841f:	0f b6 05 e7 e4 10 80 	movzbl 0x8010e4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108426:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108429:	0f b6 05 e6 e4 10 80 	movzbl 0x8010e4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108430:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108433:	0f b6 05 e5 e4 10 80 	movzbl 0x8010e4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010843a:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010843d:	0f b6 05 e4 e4 10 80 	movzbl 0x8010e4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108444:	0f b6 c0             	movzbl %al,%eax
80108447:	83 ec 0c             	sub    $0xc,%esp
8010844a:	53                   	push   %ebx
8010844b:	51                   	push   %ecx
8010844c:	52                   	push   %edx
8010844d:	50                   	push   %eax
8010844e:	68 c0 bd 10 80       	push   $0x8010bdc0
80108453:	e8 9c 7f ff ff       	call   801003f4 <cprintf>
80108458:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010845b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010845e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108464:	90                   	nop
80108465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108468:	c9                   	leave
80108469:	c3                   	ret

8010846a <i8254_init_recv>:

void i8254_init_recv(){
8010846a:	55                   	push   %ebp
8010846b:	89 e5                	mov    %esp,%ebp
8010846d:	57                   	push   %edi
8010846e:	56                   	push   %esi
8010846f:	53                   	push   %ebx
80108470:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108473:	83 ec 0c             	sub    $0xc,%esp
80108476:	6a 00                	push   $0x0
80108478:	e8 e8 04 00 00       	call   80108965 <i8254_read_eeprom>
8010847d:	83 c4 10             	add    $0x10,%esp
80108480:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108483:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108486:	a2 80 5d 19 80       	mov    %al,0x80195d80
  mac_addr[1] = data_l>>8;
8010848b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010848e:	c1 e8 08             	shr    $0x8,%eax
80108491:	a2 81 5d 19 80       	mov    %al,0x80195d81
  uint data_m = i8254_read_eeprom(0x1);
80108496:	83 ec 0c             	sub    $0xc,%esp
80108499:	6a 01                	push   $0x1
8010849b:	e8 c5 04 00 00       	call   80108965 <i8254_read_eeprom>
801084a0:	83 c4 10             	add    $0x10,%esp
801084a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801084a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084a9:	a2 82 5d 19 80       	mov    %al,0x80195d82
  mac_addr[3] = data_m>>8;
801084ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084b1:	c1 e8 08             	shr    $0x8,%eax
801084b4:	a2 83 5d 19 80       	mov    %al,0x80195d83
  uint data_h = i8254_read_eeprom(0x2);
801084b9:	83 ec 0c             	sub    $0xc,%esp
801084bc:	6a 02                	push   $0x2
801084be:	e8 a2 04 00 00       	call   80108965 <i8254_read_eeprom>
801084c3:	83 c4 10             	add    $0x10,%esp
801084c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801084c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801084cc:	a2 84 5d 19 80       	mov    %al,0x80195d84
  mac_addr[5] = data_h>>8;
801084d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801084d4:	c1 e8 08             	shr    $0x8,%eax
801084d7:	a2 85 5d 19 80       	mov    %al,0x80195d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801084dc:	0f b6 05 85 5d 19 80 	movzbl 0x80195d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801084e3:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801084e6:	0f b6 05 84 5d 19 80 	movzbl 0x80195d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801084ed:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801084f0:	0f b6 05 83 5d 19 80 	movzbl 0x80195d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801084f7:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801084fa:	0f b6 05 82 5d 19 80 	movzbl 0x80195d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108501:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108504:	0f b6 05 81 5d 19 80 	movzbl 0x80195d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010850b:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010850e:	0f b6 05 80 5d 19 80 	movzbl 0x80195d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108515:	0f b6 c0             	movzbl %al,%eax
80108518:	83 ec 04             	sub    $0x4,%esp
8010851b:	57                   	push   %edi
8010851c:	56                   	push   %esi
8010851d:	53                   	push   %ebx
8010851e:	51                   	push   %ecx
8010851f:	52                   	push   %edx
80108520:	50                   	push   %eax
80108521:	68 d8 bd 10 80       	push   $0x8010bdd8
80108526:	e8 c9 7e ff ff       	call   801003f4 <cprintf>
8010852b:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010852e:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108533:	05 00 54 00 00       	add    $0x5400,%eax
80108538:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010853b:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108540:	05 04 54 00 00       	add    $0x5404,%eax
80108545:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010854b:	c1 e0 10             	shl    $0x10,%eax
8010854e:	0b 45 d8             	or     -0x28(%ebp),%eax
80108551:	89 c2                	mov    %eax,%edx
80108553:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108556:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108558:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010855b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108560:	89 c2                	mov    %eax,%edx
80108562:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108565:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108567:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
8010856c:	05 00 52 00 00       	add    $0x5200,%eax
80108571:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108574:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010857b:	eb 19                	jmp    80108596 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010857d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108587:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010858a:	01 d0                	add    %edx,%eax
8010858c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108592:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108596:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010859a:	7e e1                	jle    8010857d <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010859c:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801085a1:	05 d0 00 00 00       	add    $0xd0,%eax
801085a6:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085a9:	8b 45 c0             	mov    -0x40(%ebp),%eax
801085ac:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801085b2:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801085b7:	05 c8 00 00 00       	add    $0xc8,%eax
801085bc:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085bf:	8b 45 bc             	mov    -0x44(%ebp),%eax
801085c2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801085c8:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801085cd:	05 28 28 00 00       	add    $0x2828,%eax
801085d2:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801085d5:	8b 45 b8             	mov    -0x48(%ebp),%eax
801085d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801085de:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801085e3:	05 00 01 00 00       	add    $0x100,%eax
801085e8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801085eb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801085ee:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801085f4:	e8 af a1 ff ff       	call   801027a8 <kalloc>
801085f9:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801085fc:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108601:	05 00 28 00 00       	add    $0x2800,%eax
80108606:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108609:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
8010860e:	05 04 28 00 00       	add    $0x2804,%eax
80108613:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108616:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
8010861b:	05 08 28 00 00       	add    $0x2808,%eax
80108620:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108623:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108628:	05 10 28 00 00       	add    $0x2810,%eax
8010862d:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108630:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108635:	05 18 28 00 00       	add    $0x2818,%eax
8010863a:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010863d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108640:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108646:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108649:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010864b:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010864e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108654:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108657:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010865d:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108660:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108666:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108669:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010866f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108672:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108675:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010867c:	eb 73                	jmp    801086f1 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
8010867e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108681:	c1 e0 04             	shl    $0x4,%eax
80108684:	89 c2                	mov    %eax,%edx
80108686:	8b 45 98             	mov    -0x68(%ebp),%eax
80108689:	01 d0                	add    %edx,%eax
8010868b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108692:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108695:	c1 e0 04             	shl    $0x4,%eax
80108698:	89 c2                	mov    %eax,%edx
8010869a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010869d:	01 d0                	add    %edx,%eax
8010869f:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801086a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086a8:	c1 e0 04             	shl    $0x4,%eax
801086ab:	89 c2                	mov    %eax,%edx
801086ad:	8b 45 98             	mov    -0x68(%ebp),%eax
801086b0:	01 d0                	add    %edx,%eax
801086b2:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801086b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086bb:	c1 e0 04             	shl    $0x4,%eax
801086be:	89 c2                	mov    %eax,%edx
801086c0:	8b 45 98             	mov    -0x68(%ebp),%eax
801086c3:	01 d0                	add    %edx,%eax
801086c5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801086c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086cc:	c1 e0 04             	shl    $0x4,%eax
801086cf:	89 c2                	mov    %eax,%edx
801086d1:	8b 45 98             	mov    -0x68(%ebp),%eax
801086d4:	01 d0                	add    %edx,%eax
801086d6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801086da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086dd:	c1 e0 04             	shl    $0x4,%eax
801086e0:	89 c2                	mov    %eax,%edx
801086e2:	8b 45 98             	mov    -0x68(%ebp),%eax
801086e5:	01 d0                	add    %edx,%eax
801086e7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801086ed:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801086f1:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801086f8:	7e 84                	jle    8010867e <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801086fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108701:	eb 57                	jmp    8010875a <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108703:	e8 a0 a0 ff ff       	call   801027a8 <kalloc>
80108708:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010870b:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010870f:	75 12                	jne    80108723 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108711:	83 ec 0c             	sub    $0xc,%esp
80108714:	68 f8 bd 10 80       	push   $0x8010bdf8
80108719:	e8 d6 7c ff ff       	call   801003f4 <cprintf>
8010871e:	83 c4 10             	add    $0x10,%esp
      break;
80108721:	eb 3d                	jmp    80108760 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108723:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108726:	c1 e0 04             	shl    $0x4,%eax
80108729:	89 c2                	mov    %eax,%edx
8010872b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010872e:	01 d0                	add    %edx,%eax
80108730:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108733:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108739:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010873b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010873e:	83 c0 01             	add    $0x1,%eax
80108741:	c1 e0 04             	shl    $0x4,%eax
80108744:	89 c2                	mov    %eax,%edx
80108746:	8b 45 98             	mov    -0x68(%ebp),%eax
80108749:	01 d0                	add    %edx,%eax
8010874b:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010874e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108754:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108756:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010875a:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010875e:	7e a3                	jle    80108703 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108760:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108763:	8b 00                	mov    (%eax),%eax
80108765:	83 c8 02             	or     $0x2,%eax
80108768:	89 c2                	mov    %eax,%edx
8010876a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010876d:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010876f:	83 ec 0c             	sub    $0xc,%esp
80108772:	68 18 be 10 80       	push   $0x8010be18
80108777:	e8 78 7c ff ff       	call   801003f4 <cprintf>
8010877c:	83 c4 10             	add    $0x10,%esp
}
8010877f:	90                   	nop
80108780:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108783:	5b                   	pop    %ebx
80108784:	5e                   	pop    %esi
80108785:	5f                   	pop    %edi
80108786:	5d                   	pop    %ebp
80108787:	c3                   	ret

80108788 <i8254_init_send>:

void i8254_init_send(){
80108788:	55                   	push   %ebp
80108789:	89 e5                	mov    %esp,%ebp
8010878b:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
8010878e:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108793:	05 28 38 00 00       	add    $0x3828,%eax
80108798:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010879b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879e:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801087a4:	e8 ff 9f ff ff       	call   801027a8 <kalloc>
801087a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801087ac:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801087b1:	05 00 38 00 00       	add    $0x3800,%eax
801087b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801087b9:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801087be:	05 04 38 00 00       	add    $0x3804,%eax
801087c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801087c6:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801087cb:	05 08 38 00 00       	add    $0x3808,%eax
801087d0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801087d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801087dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087df:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801087e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801087ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087ed:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801087f3:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801087f8:	05 10 38 00 00       	add    $0x3810,%eax
801087fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108800:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108805:	05 18 38 00 00       	add    $0x3818,%eax
8010880a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010880d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108810:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108816:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108819:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010881f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108822:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108825:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010882c:	e9 82 00 00 00       	jmp    801088b3 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108834:	c1 e0 04             	shl    $0x4,%eax
80108837:	89 c2                	mov    %eax,%edx
80108839:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010883c:	01 d0                	add    %edx,%eax
8010883e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108848:	c1 e0 04             	shl    $0x4,%eax
8010884b:	89 c2                	mov    %eax,%edx
8010884d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108850:	01 d0                	add    %edx,%eax
80108852:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885b:	c1 e0 04             	shl    $0x4,%eax
8010885e:	89 c2                	mov    %eax,%edx
80108860:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108863:	01 d0                	add    %edx,%eax
80108865:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886c:	c1 e0 04             	shl    $0x4,%eax
8010886f:	89 c2                	mov    %eax,%edx
80108871:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108874:	01 d0                	add    %edx,%eax
80108876:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010887a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887d:	c1 e0 04             	shl    $0x4,%eax
80108880:	89 c2                	mov    %eax,%edx
80108882:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108885:	01 d0                	add    %edx,%eax
80108887:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	c1 e0 04             	shl    $0x4,%eax
80108891:	89 c2                	mov    %eax,%edx
80108893:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108896:	01 d0                	add    %edx,%eax
80108898:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010889c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889f:	c1 e0 04             	shl    $0x4,%eax
801088a2:	89 c2                	mov    %eax,%edx
801088a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088a7:	01 d0                	add    %edx,%eax
801088a9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801088af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088b3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801088ba:	0f 8e 71 ff ff ff    	jle    80108831 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801088c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801088c7:	eb 57                	jmp    80108920 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801088c9:	e8 da 9e ff ff       	call   801027a8 <kalloc>
801088ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801088d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801088d5:	75 12                	jne    801088e9 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801088d7:	83 ec 0c             	sub    $0xc,%esp
801088da:	68 f8 bd 10 80       	push   $0x8010bdf8
801088df:	e8 10 7b ff ff       	call   801003f4 <cprintf>
801088e4:	83 c4 10             	add    $0x10,%esp
      break;
801088e7:	eb 3d                	jmp    80108926 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801088e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ec:	c1 e0 04             	shl    $0x4,%eax
801088ef:	89 c2                	mov    %eax,%edx
801088f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088f4:	01 d0                	add    %edx,%eax
801088f6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801088f9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801088ff:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108904:	83 c0 01             	add    $0x1,%eax
80108907:	c1 e0 04             	shl    $0x4,%eax
8010890a:	89 c2                	mov    %eax,%edx
8010890c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010890f:	01 d0                	add    %edx,%eax
80108911:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108914:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010891a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010891c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108920:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108924:	7e a3                	jle    801088c9 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108926:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
8010892b:	05 00 04 00 00       	add    $0x400,%eax
80108930:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108933:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108936:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010893c:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108941:	05 10 04 00 00       	add    $0x410,%eax
80108946:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108949:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010894c:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108952:	83 ec 0c             	sub    $0xc,%esp
80108955:	68 38 be 10 80       	push   $0x8010be38
8010895a:	e8 95 7a ff ff       	call   801003f4 <cprintf>
8010895f:	83 c4 10             	add    $0x10,%esp

}
80108962:	90                   	nop
80108963:	c9                   	leave
80108964:	c3                   	ret

80108965 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108965:	55                   	push   %ebp
80108966:	89 e5                	mov    %esp,%ebp
80108968:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010896b:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108970:	83 c0 14             	add    $0x14,%eax
80108973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108976:	8b 45 08             	mov    0x8(%ebp),%eax
80108979:	c1 e0 08             	shl    $0x8,%eax
8010897c:	0f b7 c0             	movzwl %ax,%eax
8010897f:	83 c8 01             	or     $0x1,%eax
80108982:	89 c2                	mov    %eax,%edx
80108984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108987:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108989:	83 ec 0c             	sub    $0xc,%esp
8010898c:	68 58 be 10 80       	push   $0x8010be58
80108991:	e8 5e 7a ff ff       	call   801003f4 <cprintf>
80108996:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899c:	8b 00                	mov    (%eax),%eax
8010899e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801089a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a4:	83 e0 10             	and    $0x10,%eax
801089a7:	85 c0                	test   %eax,%eax
801089a9:	75 02                	jne    801089ad <i8254_read_eeprom+0x48>
  while(1){
801089ab:	eb dc                	jmp    80108989 <i8254_read_eeprom+0x24>
      break;
801089ad:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801089ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b1:	8b 00                	mov    (%eax),%eax
801089b3:	c1 e8 10             	shr    $0x10,%eax
}
801089b6:	c9                   	leave
801089b7:	c3                   	ret

801089b8 <i8254_recv>:
void i8254_recv(){
801089b8:	55                   	push   %ebp
801089b9:	89 e5                	mov    %esp,%ebp
801089bb:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801089be:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801089c3:	05 10 28 00 00       	add    $0x2810,%eax
801089c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801089cb:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801089d0:	05 18 28 00 00       	add    $0x2818,%eax
801089d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801089d8:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
801089dd:	05 00 28 00 00       	add    $0x2800,%eax
801089e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801089e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e8:	8b 00                	mov    (%eax),%eax
801089ea:	05 00 00 00 80       	add    $0x80000000,%eax
801089ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801089f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f5:	8b 10                	mov    (%eax),%edx
801089f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089fa:	8b 00                	mov    (%eax),%eax
801089fc:	29 c2                	sub    %eax,%edx
801089fe:	89 d0                	mov    %edx,%eax
80108a00:	25 ff 00 00 00       	and    $0xff,%eax
80108a05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a0c:	7e 37                	jle    80108a45 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a11:	8b 00                	mov    (%eax),%eax
80108a13:	c1 e0 04             	shl    $0x4,%eax
80108a16:	89 c2                	mov    %eax,%edx
80108a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a1b:	01 d0                	add    %edx,%eax
80108a1d:	8b 00                	mov    (%eax),%eax
80108a1f:	05 00 00 00 80       	add    $0x80000000,%eax
80108a24:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2a:	8b 00                	mov    (%eax),%eax
80108a2c:	83 c0 01             	add    $0x1,%eax
80108a2f:	0f b6 d0             	movzbl %al,%edx
80108a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a35:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108a37:	83 ec 0c             	sub    $0xc,%esp
80108a3a:	ff 75 e0             	push   -0x20(%ebp)
80108a3d:	e8 13 09 00 00       	call   80109355 <eth_proc>
80108a42:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a48:	8b 10                	mov    (%eax),%edx
80108a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4d:	8b 00                	mov    (%eax),%eax
80108a4f:	39 c2                	cmp    %eax,%edx
80108a51:	75 9f                	jne    801089f2 <i8254_recv+0x3a>
      (*rdt)--;
80108a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a56:	8b 00                	mov    (%eax),%eax
80108a58:	8d 50 ff             	lea    -0x1(%eax),%edx
80108a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5e:	89 10                	mov    %edx,(%eax)
  while(1){
80108a60:	eb 90                	jmp    801089f2 <i8254_recv+0x3a>

80108a62 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108a62:	55                   	push   %ebp
80108a63:	89 e5                	mov    %esp,%ebp
80108a65:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108a68:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108a6d:	05 10 38 00 00       	add    $0x3810,%eax
80108a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108a75:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108a7a:	05 18 38 00 00       	add    $0x3818,%eax
80108a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108a82:	a1 7c 5d 19 80       	mov    0x80195d7c,%eax
80108a87:	05 00 38 00 00       	add    $0x3800,%eax
80108a8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108a8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a92:	8b 00                	mov    (%eax),%eax
80108a94:	05 00 00 00 80       	add    $0x80000000,%eax
80108a99:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a9f:	8b 10                	mov    (%eax),%edx
80108aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa4:	8b 00                	mov    (%eax),%eax
80108aa6:	29 c2                	sub    %eax,%edx
80108aa8:	0f b6 c2             	movzbl %dl,%eax
80108aab:	ba 00 01 00 00       	mov    $0x100,%edx
80108ab0:	29 c2                	sub    %eax,%edx
80108ab2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab8:	8b 00                	mov    (%eax),%eax
80108aba:	25 ff 00 00 00       	and    $0xff,%eax
80108abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108ac2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108ac6:	0f 8e a8 00 00 00    	jle    80108b74 <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108acc:	8b 45 08             	mov    0x8(%ebp),%eax
80108acf:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108ad2:	89 d1                	mov    %edx,%ecx
80108ad4:	c1 e1 04             	shl    $0x4,%ecx
80108ad7:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108ada:	01 ca                	add    %ecx,%edx
80108adc:	8b 12                	mov    (%edx),%edx
80108ade:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ae4:	83 ec 04             	sub    $0x4,%esp
80108ae7:	ff 75 0c             	push   0xc(%ebp)
80108aea:	50                   	push   %eax
80108aeb:	52                   	push   %edx
80108aec:	e8 56 bf ff ff       	call   80104a47 <memmove>
80108af1:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af7:	c1 e0 04             	shl    $0x4,%eax
80108afa:	89 c2                	mov    %eax,%edx
80108afc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aff:	01 d0                	add    %edx,%eax
80108b01:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b04:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b0b:	c1 e0 04             	shl    $0x4,%eax
80108b0e:	89 c2                	mov    %eax,%edx
80108b10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b13:	01 d0                	add    %edx,%eax
80108b15:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108b19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b1c:	c1 e0 04             	shl    $0x4,%eax
80108b1f:	89 c2                	mov    %eax,%edx
80108b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b24:	01 d0                	add    %edx,%eax
80108b26:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108b2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b2d:	c1 e0 04             	shl    $0x4,%eax
80108b30:	89 c2                	mov    %eax,%edx
80108b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b35:	01 d0                	add    %edx,%eax
80108b37:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b3e:	c1 e0 04             	shl    $0x4,%eax
80108b41:	89 c2                	mov    %eax,%edx
80108b43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b46:	01 d0                	add    %edx,%eax
80108b48:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108b4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b51:	c1 e0 04             	shl    $0x4,%eax
80108b54:	89 c2                	mov    %eax,%edx
80108b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b59:	01 d0                	add    %edx,%eax
80108b5b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b62:	8b 00                	mov    (%eax),%eax
80108b64:	83 c0 01             	add    $0x1,%eax
80108b67:	0f b6 d0             	movzbl %al,%edx
80108b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6d:	89 10                	mov    %edx,(%eax)
    return len;
80108b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b72:	eb 05                	jmp    80108b79 <i8254_send+0x117>
  }else{
    return -1;
80108b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108b79:	c9                   	leave
80108b7a:	c3                   	ret

80108b7b <i8254_intr>:

void i8254_intr(){
80108b7b:	55                   	push   %ebp
80108b7c:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108b7e:	a1 88 5d 19 80       	mov    0x80195d88,%eax
80108b83:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108b89:	90                   	nop
80108b8a:	5d                   	pop    %ebp
80108b8b:	c3                   	ret

80108b8c <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108b8c:	55                   	push   %ebp
80108b8d:	89 e5                	mov    %esp,%ebp
80108b8f:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108b92:	8b 45 08             	mov    0x8(%ebp),%eax
80108b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9b:	0f b7 00             	movzwl (%eax),%eax
80108b9e:	66 3d 00 01          	cmp    $0x100,%ax
80108ba2:	74 0a                	je     80108bae <arp_proc+0x22>
80108ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ba9:	e9 4f 01 00 00       	jmp    80108cfd <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb1:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108bb5:	66 83 f8 08          	cmp    $0x8,%ax
80108bb9:	74 0a                	je     80108bc5 <arp_proc+0x39>
80108bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bc0:	e9 38 01 00 00       	jmp    80108cfd <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108bcc:	3c 06                	cmp    $0x6,%al
80108bce:	74 0a                	je     80108bda <arp_proc+0x4e>
80108bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bd5:	e9 23 01 00 00       	jmp    80108cfd <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bdd:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108be1:	3c 04                	cmp    $0x4,%al
80108be3:	74 0a                	je     80108bef <arp_proc+0x63>
80108be5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bea:	e9 0e 01 00 00       	jmp    80108cfd <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf2:	83 c0 18             	add    $0x18,%eax
80108bf5:	83 ec 04             	sub    $0x4,%esp
80108bf8:	6a 04                	push   $0x4
80108bfa:	50                   	push   %eax
80108bfb:	68 e4 e4 10 80       	push   $0x8010e4e4
80108c00:	e8 ea bd ff ff       	call   801049ef <memcmp>
80108c05:	83 c4 10             	add    $0x10,%esp
80108c08:	85 c0                	test   %eax,%eax
80108c0a:	74 27                	je     80108c33 <arp_proc+0xa7>
80108c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0f:	83 c0 0e             	add    $0xe,%eax
80108c12:	83 ec 04             	sub    $0x4,%esp
80108c15:	6a 04                	push   $0x4
80108c17:	50                   	push   %eax
80108c18:	68 e4 e4 10 80       	push   $0x8010e4e4
80108c1d:	e8 cd bd ff ff       	call   801049ef <memcmp>
80108c22:	83 c4 10             	add    $0x10,%esp
80108c25:	85 c0                	test   %eax,%eax
80108c27:	74 0a                	je     80108c33 <arp_proc+0xa7>
80108c29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c2e:	e9 ca 00 00 00       	jmp    80108cfd <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c36:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108c3a:	66 3d 00 01          	cmp    $0x100,%ax
80108c3e:	75 69                	jne    80108ca9 <arp_proc+0x11d>
80108c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c43:	83 c0 18             	add    $0x18,%eax
80108c46:	83 ec 04             	sub    $0x4,%esp
80108c49:	6a 04                	push   $0x4
80108c4b:	50                   	push   %eax
80108c4c:	68 e4 e4 10 80       	push   $0x8010e4e4
80108c51:	e8 99 bd ff ff       	call   801049ef <memcmp>
80108c56:	83 c4 10             	add    $0x10,%esp
80108c59:	85 c0                	test   %eax,%eax
80108c5b:	75 4c                	jne    80108ca9 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108c5d:	e8 46 9b ff ff       	call   801027a8 <kalloc>
80108c62:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108c65:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108c6c:	83 ec 04             	sub    $0x4,%esp
80108c6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c72:	50                   	push   %eax
80108c73:	ff 75 f0             	push   -0x10(%ebp)
80108c76:	ff 75 f4             	push   -0xc(%ebp)
80108c79:	e8 1f 04 00 00       	call   8010909d <arp_reply_pkt_create>
80108c7e:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108c81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c84:	83 ec 08             	sub    $0x8,%esp
80108c87:	50                   	push   %eax
80108c88:	ff 75 f0             	push   -0x10(%ebp)
80108c8b:	e8 d2 fd ff ff       	call   80108a62 <i8254_send>
80108c90:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c96:	83 ec 0c             	sub    $0xc,%esp
80108c99:	50                   	push   %eax
80108c9a:	e8 6f 9a ff ff       	call   8010270e <kfree>
80108c9f:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108ca2:	b8 02 00 00 00       	mov    $0x2,%eax
80108ca7:	eb 54                	jmp    80108cfd <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cac:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108cb0:	66 3d 00 02          	cmp    $0x200,%ax
80108cb4:	75 42                	jne    80108cf8 <arp_proc+0x16c>
80108cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb9:	83 c0 18             	add    $0x18,%eax
80108cbc:	83 ec 04             	sub    $0x4,%esp
80108cbf:	6a 04                	push   $0x4
80108cc1:	50                   	push   %eax
80108cc2:	68 e4 e4 10 80       	push   $0x8010e4e4
80108cc7:	e8 23 bd ff ff       	call   801049ef <memcmp>
80108ccc:	83 c4 10             	add    $0x10,%esp
80108ccf:	85 c0                	test   %eax,%eax
80108cd1:	75 25                	jne    80108cf8 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108cd3:	83 ec 0c             	sub    $0xc,%esp
80108cd6:	68 5c be 10 80       	push   $0x8010be5c
80108cdb:	e8 14 77 ff ff       	call   801003f4 <cprintf>
80108ce0:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108ce3:	83 ec 0c             	sub    $0xc,%esp
80108ce6:	ff 75 f4             	push   -0xc(%ebp)
80108ce9:	e8 af 01 00 00       	call   80108e9d <arp_table_update>
80108cee:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108cf1:	b8 01 00 00 00       	mov    $0x1,%eax
80108cf6:	eb 05                	jmp    80108cfd <arp_proc+0x171>
  }else{
    return -1;
80108cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108cfd:	c9                   	leave
80108cfe:	c3                   	ret

80108cff <arp_scan>:

void arp_scan(){
80108cff:	55                   	push   %ebp
80108d00:	89 e5                	mov    %esp,%ebp
80108d02:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d0c:	eb 6f                	jmp    80108d7d <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108d0e:	e8 95 9a ff ff       	call   801027a8 <kalloc>
80108d13:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108d16:	83 ec 04             	sub    $0x4,%esp
80108d19:	ff 75 f4             	push   -0xc(%ebp)
80108d1c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108d1f:	50                   	push   %eax
80108d20:	ff 75 ec             	push   -0x14(%ebp)
80108d23:	e8 62 00 00 00       	call   80108d8a <arp_broadcast>
80108d28:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108d2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d2e:	83 ec 08             	sub    $0x8,%esp
80108d31:	50                   	push   %eax
80108d32:	ff 75 ec             	push   -0x14(%ebp)
80108d35:	e8 28 fd ff ff       	call   80108a62 <i8254_send>
80108d3a:	83 c4 10             	add    $0x10,%esp
80108d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d40:	eb 22                	jmp    80108d64 <arp_scan+0x65>
      microdelay(1);
80108d42:	83 ec 0c             	sub    $0xc,%esp
80108d45:	6a 01                	push   $0x1
80108d47:	e8 ed 9d ff ff       	call   80102b39 <microdelay>
80108d4c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d52:	83 ec 08             	sub    $0x8,%esp
80108d55:	50                   	push   %eax
80108d56:	ff 75 ec             	push   -0x14(%ebp)
80108d59:	e8 04 fd ff ff       	call   80108a62 <i8254_send>
80108d5e:	83 c4 10             	add    $0x10,%esp
80108d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d64:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108d68:	74 d8                	je     80108d42 <arp_scan+0x43>
    }
    kfree((char *)send);
80108d6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d6d:	83 ec 0c             	sub    $0xc,%esp
80108d70:	50                   	push   %eax
80108d71:	e8 98 99 ff ff       	call   8010270e <kfree>
80108d76:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108d79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d7d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108d84:	7e 88                	jle    80108d0e <arp_scan+0xf>
  }
}
80108d86:	90                   	nop
80108d87:	90                   	nop
80108d88:	c9                   	leave
80108d89:	c3                   	ret

80108d8a <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108d8a:	55                   	push   %ebp
80108d8b:	89 e5                	mov    %esp,%ebp
80108d8d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108d90:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108d94:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108d98:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108d9c:	8b 45 10             	mov    0x10(%ebp),%eax
80108d9f:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108da2:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108da9:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108daf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108db6:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dbf:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80108dce:	83 c0 0e             	add    $0xe,%eax
80108dd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dde:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de5:	83 ec 04             	sub    $0x4,%esp
80108de8:	6a 06                	push   $0x6
80108dea:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108ded:	52                   	push   %edx
80108dee:	50                   	push   %eax
80108def:	e8 53 bc ff ff       	call   80104a47 <memmove>
80108df4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dfa:	83 c0 06             	add    $0x6,%eax
80108dfd:	83 ec 04             	sub    $0x4,%esp
80108e00:	6a 06                	push   $0x6
80108e02:	68 80 5d 19 80       	push   $0x80195d80
80108e07:	50                   	push   %eax
80108e08:	e8 3a bc ff ff       	call   80104a47 <memmove>
80108e0d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e13:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e24:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e2b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e32:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e3b:	8d 50 12             	lea    0x12(%eax),%edx
80108e3e:	83 ec 04             	sub    $0x4,%esp
80108e41:	6a 06                	push   $0x6
80108e43:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108e46:	50                   	push   %eax
80108e47:	52                   	push   %edx
80108e48:	e8 fa bb ff ff       	call   80104a47 <memmove>
80108e4d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e53:	8d 50 18             	lea    0x18(%eax),%edx
80108e56:	83 ec 04             	sub    $0x4,%esp
80108e59:	6a 04                	push   $0x4
80108e5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e5e:	50                   	push   %eax
80108e5f:	52                   	push   %edx
80108e60:	e8 e2 bb ff ff       	call   80104a47 <memmove>
80108e65:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6b:	83 c0 08             	add    $0x8,%eax
80108e6e:	83 ec 04             	sub    $0x4,%esp
80108e71:	6a 06                	push   $0x6
80108e73:	68 80 5d 19 80       	push   $0x80195d80
80108e78:	50                   	push   %eax
80108e79:	e8 c9 bb ff ff       	call   80104a47 <memmove>
80108e7e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e84:	83 c0 0e             	add    $0xe,%eax
80108e87:	83 ec 04             	sub    $0x4,%esp
80108e8a:	6a 04                	push   $0x4
80108e8c:	68 e4 e4 10 80       	push   $0x8010e4e4
80108e91:	50                   	push   %eax
80108e92:	e8 b0 bb ff ff       	call   80104a47 <memmove>
80108e97:	83 c4 10             	add    $0x10,%esp
}
80108e9a:	90                   	nop
80108e9b:	c9                   	leave
80108e9c:	c3                   	ret

80108e9d <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108e9d:	55                   	push   %ebp
80108e9e:	89 e5                	mov    %esp,%ebp
80108ea0:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea6:	83 c0 0e             	add    $0xe,%eax
80108ea9:	83 ec 0c             	sub    $0xc,%esp
80108eac:	50                   	push   %eax
80108ead:	e8 bc 00 00 00       	call   80108f6e <arp_table_search>
80108eb2:	83 c4 10             	add    $0x10,%esp
80108eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108eb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108ebc:	78 2d                	js     80108eeb <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec1:	8d 48 08             	lea    0x8(%eax),%ecx
80108ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ec7:	89 d0                	mov    %edx,%eax
80108ec9:	c1 e0 02             	shl    $0x2,%eax
80108ecc:	01 d0                	add    %edx,%eax
80108ece:	01 c0                	add    %eax,%eax
80108ed0:	01 d0                	add    %edx,%eax
80108ed2:	05 a0 5d 19 80       	add    $0x80195da0,%eax
80108ed7:	83 c0 04             	add    $0x4,%eax
80108eda:	83 ec 04             	sub    $0x4,%esp
80108edd:	6a 06                	push   $0x6
80108edf:	51                   	push   %ecx
80108ee0:	50                   	push   %eax
80108ee1:	e8 61 bb ff ff       	call   80104a47 <memmove>
80108ee6:	83 c4 10             	add    $0x10,%esp
80108ee9:	eb 70                	jmp    80108f5b <arp_table_update+0xbe>
  }else{
    index += 1;
80108eeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108eef:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef5:	8d 48 08             	lea    0x8(%eax),%ecx
80108ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108efb:	89 d0                	mov    %edx,%eax
80108efd:	c1 e0 02             	shl    $0x2,%eax
80108f00:	01 d0                	add    %edx,%eax
80108f02:	01 c0                	add    %eax,%eax
80108f04:	01 d0                	add    %edx,%eax
80108f06:	05 a0 5d 19 80       	add    $0x80195da0,%eax
80108f0b:	83 c0 04             	add    $0x4,%eax
80108f0e:	83 ec 04             	sub    $0x4,%esp
80108f11:	6a 06                	push   $0x6
80108f13:	51                   	push   %ecx
80108f14:	50                   	push   %eax
80108f15:	e8 2d bb ff ff       	call   80104a47 <memmove>
80108f1a:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f20:	8d 48 0e             	lea    0xe(%eax),%ecx
80108f23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f26:	89 d0                	mov    %edx,%eax
80108f28:	c1 e0 02             	shl    $0x2,%eax
80108f2b:	01 d0                	add    %edx,%eax
80108f2d:	01 c0                	add    %eax,%eax
80108f2f:	01 d0                	add    %edx,%eax
80108f31:	05 a0 5d 19 80       	add    $0x80195da0,%eax
80108f36:	83 ec 04             	sub    $0x4,%esp
80108f39:	6a 04                	push   $0x4
80108f3b:	51                   	push   %ecx
80108f3c:	50                   	push   %eax
80108f3d:	e8 05 bb ff ff       	call   80104a47 <memmove>
80108f42:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108f45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f48:	89 d0                	mov    %edx,%eax
80108f4a:	c1 e0 02             	shl    $0x2,%eax
80108f4d:	01 d0                	add    %edx,%eax
80108f4f:	01 c0                	add    %eax,%eax
80108f51:	01 d0                	add    %edx,%eax
80108f53:	05 aa 5d 19 80       	add    $0x80195daa,%eax
80108f58:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108f5b:	83 ec 0c             	sub    $0xc,%esp
80108f5e:	68 a0 5d 19 80       	push   $0x80195da0
80108f63:	e8 83 00 00 00       	call   80108feb <print_arp_table>
80108f68:	83 c4 10             	add    $0x10,%esp
}
80108f6b:	90                   	nop
80108f6c:	c9                   	leave
80108f6d:	c3                   	ret

80108f6e <arp_table_search>:

int arp_table_search(uchar *ip){
80108f6e:	55                   	push   %ebp
80108f6f:	89 e5                	mov    %esp,%ebp
80108f71:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80108f74:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108f7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f82:	eb 59                	jmp    80108fdd <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80108f84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108f87:	89 d0                	mov    %edx,%eax
80108f89:	c1 e0 02             	shl    $0x2,%eax
80108f8c:	01 d0                	add    %edx,%eax
80108f8e:	01 c0                	add    %eax,%eax
80108f90:	01 d0                	add    %edx,%eax
80108f92:	05 a0 5d 19 80       	add    $0x80195da0,%eax
80108f97:	83 ec 04             	sub    $0x4,%esp
80108f9a:	6a 04                	push   $0x4
80108f9c:	ff 75 08             	push   0x8(%ebp)
80108f9f:	50                   	push   %eax
80108fa0:	e8 4a ba ff ff       	call   801049ef <memcmp>
80108fa5:	83 c4 10             	add    $0x10,%esp
80108fa8:	85 c0                	test   %eax,%eax
80108faa:	75 05                	jne    80108fb1 <arp_table_search+0x43>
      return i;
80108fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faf:	eb 38                	jmp    80108fe9 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80108fb1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fb4:	89 d0                	mov    %edx,%eax
80108fb6:	c1 e0 02             	shl    $0x2,%eax
80108fb9:	01 d0                	add    %edx,%eax
80108fbb:	01 c0                	add    %eax,%eax
80108fbd:	01 d0                	add    %edx,%eax
80108fbf:	05 aa 5d 19 80       	add    $0x80195daa,%eax
80108fc4:	0f b6 00             	movzbl (%eax),%eax
80108fc7:	84 c0                	test   %al,%al
80108fc9:	75 0e                	jne    80108fd9 <arp_table_search+0x6b>
80108fcb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80108fcf:	75 08                	jne    80108fd9 <arp_table_search+0x6b>
      empty = -i;
80108fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd4:	f7 d8                	neg    %eax
80108fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108fd9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108fdd:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80108fe1:	7e a1                	jle    80108f84 <arp_table_search+0x16>
    }
  }
  return empty-1;
80108fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe6:	83 e8 01             	sub    $0x1,%eax
}
80108fe9:	c9                   	leave
80108fea:	c3                   	ret

80108feb <print_arp_table>:

void print_arp_table(){
80108feb:	55                   	push   %ebp
80108fec:	89 e5                	mov    %esp,%ebp
80108fee:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80108ff1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ff8:	e9 92 00 00 00       	jmp    8010908f <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80108ffd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109000:	89 d0                	mov    %edx,%eax
80109002:	c1 e0 02             	shl    $0x2,%eax
80109005:	01 d0                	add    %edx,%eax
80109007:	01 c0                	add    %eax,%eax
80109009:	01 d0                	add    %edx,%eax
8010900b:	05 aa 5d 19 80       	add    $0x80195daa,%eax
80109010:	0f b6 00             	movzbl (%eax),%eax
80109013:	84 c0                	test   %al,%al
80109015:	74 74                	je     8010908b <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109017:	83 ec 08             	sub    $0x8,%esp
8010901a:	ff 75 f4             	push   -0xc(%ebp)
8010901d:	68 6f be 10 80       	push   $0x8010be6f
80109022:	e8 cd 73 ff ff       	call   801003f4 <cprintf>
80109027:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010902a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010902d:	89 d0                	mov    %edx,%eax
8010902f:	c1 e0 02             	shl    $0x2,%eax
80109032:	01 d0                	add    %edx,%eax
80109034:	01 c0                	add    %eax,%eax
80109036:	01 d0                	add    %edx,%eax
80109038:	05 a0 5d 19 80       	add    $0x80195da0,%eax
8010903d:	83 ec 0c             	sub    $0xc,%esp
80109040:	50                   	push   %eax
80109041:	e8 54 02 00 00       	call   8010929a <print_ipv4>
80109046:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109049:	83 ec 0c             	sub    $0xc,%esp
8010904c:	68 7e be 10 80       	push   $0x8010be7e
80109051:	e8 9e 73 ff ff       	call   801003f4 <cprintf>
80109056:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109059:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010905c:	89 d0                	mov    %edx,%eax
8010905e:	c1 e0 02             	shl    $0x2,%eax
80109061:	01 d0                	add    %edx,%eax
80109063:	01 c0                	add    %eax,%eax
80109065:	01 d0                	add    %edx,%eax
80109067:	05 a0 5d 19 80       	add    $0x80195da0,%eax
8010906c:	83 c0 04             	add    $0x4,%eax
8010906f:	83 ec 0c             	sub    $0xc,%esp
80109072:	50                   	push   %eax
80109073:	e8 70 02 00 00       	call   801092e8 <print_mac>
80109078:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010907b:	83 ec 0c             	sub    $0xc,%esp
8010907e:	68 80 be 10 80       	push   $0x8010be80
80109083:	e8 6c 73 ff ff       	call   801003f4 <cprintf>
80109088:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010908b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010908f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109093:	0f 8e 64 ff ff ff    	jle    80108ffd <print_arp_table+0x12>
    }
  }
}
80109099:	90                   	nop
8010909a:	90                   	nop
8010909b:	c9                   	leave
8010909c:	c3                   	ret

8010909d <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010909d:	55                   	push   %ebp
8010909e:	89 e5                	mov    %esp,%ebp
801090a0:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090a3:	8b 45 10             	mov    0x10(%ebp),%eax
801090a6:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801090af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801090b5:	83 c0 0e             	add    $0xe,%eax
801090b8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801090bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090be:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801090c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c5:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801090c9:	8b 45 08             	mov    0x8(%ebp),%eax
801090cc:	8d 50 08             	lea    0x8(%eax),%edx
801090cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d2:	83 ec 04             	sub    $0x4,%esp
801090d5:	6a 06                	push   $0x6
801090d7:	52                   	push   %edx
801090d8:	50                   	push   %eax
801090d9:	e8 69 b9 ff ff       	call   80104a47 <memmove>
801090de:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801090e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e4:	83 c0 06             	add    $0x6,%eax
801090e7:	83 ec 04             	sub    $0x4,%esp
801090ea:	6a 06                	push   $0x6
801090ec:	68 80 5d 19 80       	push   $0x80195d80
801090f1:	50                   	push   %eax
801090f2:	e8 50 b9 ff ff       	call   80104a47 <memmove>
801090f7:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801090fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fd:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109105:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010910b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010910e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109115:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911c:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109122:	8b 45 08             	mov    0x8(%ebp),%eax
80109125:	8d 50 08             	lea    0x8(%eax),%edx
80109128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912b:	83 c0 12             	add    $0x12,%eax
8010912e:	83 ec 04             	sub    $0x4,%esp
80109131:	6a 06                	push   $0x6
80109133:	52                   	push   %edx
80109134:	50                   	push   %eax
80109135:	e8 0d b9 ff ff       	call   80104a47 <memmove>
8010913a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010913d:	8b 45 08             	mov    0x8(%ebp),%eax
80109140:	8d 50 0e             	lea    0xe(%eax),%edx
80109143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109146:	83 c0 18             	add    $0x18,%eax
80109149:	83 ec 04             	sub    $0x4,%esp
8010914c:	6a 04                	push   $0x4
8010914e:	52                   	push   %edx
8010914f:	50                   	push   %eax
80109150:	e8 f2 b8 ff ff       	call   80104a47 <memmove>
80109155:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915b:	83 c0 08             	add    $0x8,%eax
8010915e:	83 ec 04             	sub    $0x4,%esp
80109161:	6a 06                	push   $0x6
80109163:	68 80 5d 19 80       	push   $0x80195d80
80109168:	50                   	push   %eax
80109169:	e8 d9 b8 ff ff       	call   80104a47 <memmove>
8010916e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109174:	83 c0 0e             	add    $0xe,%eax
80109177:	83 ec 04             	sub    $0x4,%esp
8010917a:	6a 04                	push   $0x4
8010917c:	68 e4 e4 10 80       	push   $0x8010e4e4
80109181:	50                   	push   %eax
80109182:	e8 c0 b8 ff ff       	call   80104a47 <memmove>
80109187:	83 c4 10             	add    $0x10,%esp
}
8010918a:	90                   	nop
8010918b:	c9                   	leave
8010918c:	c3                   	ret

8010918d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010918d:	55                   	push   %ebp
8010918e:	89 e5                	mov    %esp,%ebp
80109190:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109193:	83 ec 0c             	sub    $0xc,%esp
80109196:	68 82 be 10 80       	push   $0x8010be82
8010919b:	e8 54 72 ff ff       	call   801003f4 <cprintf>
801091a0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801091a3:	8b 45 08             	mov    0x8(%ebp),%eax
801091a6:	83 c0 0e             	add    $0xe,%eax
801091a9:	83 ec 0c             	sub    $0xc,%esp
801091ac:	50                   	push   %eax
801091ad:	e8 e8 00 00 00       	call   8010929a <print_ipv4>
801091b2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801091b5:	83 ec 0c             	sub    $0xc,%esp
801091b8:	68 80 be 10 80       	push   $0x8010be80
801091bd:	e8 32 72 ff ff       	call   801003f4 <cprintf>
801091c2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801091c5:	8b 45 08             	mov    0x8(%ebp),%eax
801091c8:	83 c0 08             	add    $0x8,%eax
801091cb:	83 ec 0c             	sub    $0xc,%esp
801091ce:	50                   	push   %eax
801091cf:	e8 14 01 00 00       	call   801092e8 <print_mac>
801091d4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801091d7:	83 ec 0c             	sub    $0xc,%esp
801091da:	68 80 be 10 80       	push   $0x8010be80
801091df:	e8 10 72 ff ff       	call   801003f4 <cprintf>
801091e4:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801091e7:	83 ec 0c             	sub    $0xc,%esp
801091ea:	68 99 be 10 80       	push   $0x8010be99
801091ef:	e8 00 72 ff ff       	call   801003f4 <cprintf>
801091f4:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801091f7:	8b 45 08             	mov    0x8(%ebp),%eax
801091fa:	83 c0 18             	add    $0x18,%eax
801091fd:	83 ec 0c             	sub    $0xc,%esp
80109200:	50                   	push   %eax
80109201:	e8 94 00 00 00       	call   8010929a <print_ipv4>
80109206:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109209:	83 ec 0c             	sub    $0xc,%esp
8010920c:	68 80 be 10 80       	push   $0x8010be80
80109211:	e8 de 71 ff ff       	call   801003f4 <cprintf>
80109216:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109219:	8b 45 08             	mov    0x8(%ebp),%eax
8010921c:	83 c0 12             	add    $0x12,%eax
8010921f:	83 ec 0c             	sub    $0xc,%esp
80109222:	50                   	push   %eax
80109223:	e8 c0 00 00 00       	call   801092e8 <print_mac>
80109228:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010922b:	83 ec 0c             	sub    $0xc,%esp
8010922e:	68 80 be 10 80       	push   $0x8010be80
80109233:	e8 bc 71 ff ff       	call   801003f4 <cprintf>
80109238:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010923b:	83 ec 0c             	sub    $0xc,%esp
8010923e:	68 b0 be 10 80       	push   $0x8010beb0
80109243:	e8 ac 71 ff ff       	call   801003f4 <cprintf>
80109248:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010924b:	8b 45 08             	mov    0x8(%ebp),%eax
8010924e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109252:	66 3d 00 01          	cmp    $0x100,%ax
80109256:	75 12                	jne    8010926a <print_arp_info+0xdd>
80109258:	83 ec 0c             	sub    $0xc,%esp
8010925b:	68 bc be 10 80       	push   $0x8010bebc
80109260:	e8 8f 71 ff ff       	call   801003f4 <cprintf>
80109265:	83 c4 10             	add    $0x10,%esp
80109268:	eb 1d                	jmp    80109287 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010926a:	8b 45 08             	mov    0x8(%ebp),%eax
8010926d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109271:	66 3d 00 02          	cmp    $0x200,%ax
80109275:	75 10                	jne    80109287 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109277:	83 ec 0c             	sub    $0xc,%esp
8010927a:	68 c5 be 10 80       	push   $0x8010bec5
8010927f:	e8 70 71 ff ff       	call   801003f4 <cprintf>
80109284:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109287:	83 ec 0c             	sub    $0xc,%esp
8010928a:	68 80 be 10 80       	push   $0x8010be80
8010928f:	e8 60 71 ff ff       	call   801003f4 <cprintf>
80109294:	83 c4 10             	add    $0x10,%esp
}
80109297:	90                   	nop
80109298:	c9                   	leave
80109299:	c3                   	ret

8010929a <print_ipv4>:

void print_ipv4(uchar *ip){
8010929a:	55                   	push   %ebp
8010929b:	89 e5                	mov    %esp,%ebp
8010929d:	53                   	push   %ebx
8010929e:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801092a1:	8b 45 08             	mov    0x8(%ebp),%eax
801092a4:	83 c0 03             	add    $0x3,%eax
801092a7:	0f b6 00             	movzbl (%eax),%eax
801092aa:	0f b6 d8             	movzbl %al,%ebx
801092ad:	8b 45 08             	mov    0x8(%ebp),%eax
801092b0:	83 c0 02             	add    $0x2,%eax
801092b3:	0f b6 00             	movzbl (%eax),%eax
801092b6:	0f b6 c8             	movzbl %al,%ecx
801092b9:	8b 45 08             	mov    0x8(%ebp),%eax
801092bc:	83 c0 01             	add    $0x1,%eax
801092bf:	0f b6 00             	movzbl (%eax),%eax
801092c2:	0f b6 d0             	movzbl %al,%edx
801092c5:	8b 45 08             	mov    0x8(%ebp),%eax
801092c8:	0f b6 00             	movzbl (%eax),%eax
801092cb:	0f b6 c0             	movzbl %al,%eax
801092ce:	83 ec 0c             	sub    $0xc,%esp
801092d1:	53                   	push   %ebx
801092d2:	51                   	push   %ecx
801092d3:	52                   	push   %edx
801092d4:	50                   	push   %eax
801092d5:	68 cc be 10 80       	push   $0x8010becc
801092da:	e8 15 71 ff ff       	call   801003f4 <cprintf>
801092df:	83 c4 20             	add    $0x20,%esp
}
801092e2:	90                   	nop
801092e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092e6:	c9                   	leave
801092e7:	c3                   	ret

801092e8 <print_mac>:

void print_mac(uchar *mac){
801092e8:	55                   	push   %ebp
801092e9:	89 e5                	mov    %esp,%ebp
801092eb:	57                   	push   %edi
801092ec:	56                   	push   %esi
801092ed:	53                   	push   %ebx
801092ee:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801092f1:	8b 45 08             	mov    0x8(%ebp),%eax
801092f4:	83 c0 05             	add    $0x5,%eax
801092f7:	0f b6 00             	movzbl (%eax),%eax
801092fa:	0f b6 f8             	movzbl %al,%edi
801092fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109300:	83 c0 04             	add    $0x4,%eax
80109303:	0f b6 00             	movzbl (%eax),%eax
80109306:	0f b6 f0             	movzbl %al,%esi
80109309:	8b 45 08             	mov    0x8(%ebp),%eax
8010930c:	83 c0 03             	add    $0x3,%eax
8010930f:	0f b6 00             	movzbl (%eax),%eax
80109312:	0f b6 d8             	movzbl %al,%ebx
80109315:	8b 45 08             	mov    0x8(%ebp),%eax
80109318:	83 c0 02             	add    $0x2,%eax
8010931b:	0f b6 00             	movzbl (%eax),%eax
8010931e:	0f b6 c8             	movzbl %al,%ecx
80109321:	8b 45 08             	mov    0x8(%ebp),%eax
80109324:	83 c0 01             	add    $0x1,%eax
80109327:	0f b6 00             	movzbl (%eax),%eax
8010932a:	0f b6 d0             	movzbl %al,%edx
8010932d:	8b 45 08             	mov    0x8(%ebp),%eax
80109330:	0f b6 00             	movzbl (%eax),%eax
80109333:	0f b6 c0             	movzbl %al,%eax
80109336:	83 ec 04             	sub    $0x4,%esp
80109339:	57                   	push   %edi
8010933a:	56                   	push   %esi
8010933b:	53                   	push   %ebx
8010933c:	51                   	push   %ecx
8010933d:	52                   	push   %edx
8010933e:	50                   	push   %eax
8010933f:	68 e4 be 10 80       	push   $0x8010bee4
80109344:	e8 ab 70 ff ff       	call   801003f4 <cprintf>
80109349:	83 c4 20             	add    $0x20,%esp
}
8010934c:	90                   	nop
8010934d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109350:	5b                   	pop    %ebx
80109351:	5e                   	pop    %esi
80109352:	5f                   	pop    %edi
80109353:	5d                   	pop    %ebp
80109354:	c3                   	ret

80109355 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109355:	55                   	push   %ebp
80109356:	89 e5                	mov    %esp,%ebp
80109358:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010935b:	8b 45 08             	mov    0x8(%ebp),%eax
8010935e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109361:	8b 45 08             	mov    0x8(%ebp),%eax
80109364:	83 c0 0e             	add    $0xe,%eax
80109367:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010936a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109371:	3c 08                	cmp    $0x8,%al
80109373:	75 1b                	jne    80109390 <eth_proc+0x3b>
80109375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109378:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010937c:	3c 06                	cmp    $0x6,%al
8010937e:	75 10                	jne    80109390 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109380:	83 ec 0c             	sub    $0xc,%esp
80109383:	ff 75 f0             	push   -0x10(%ebp)
80109386:	e8 01 f8 ff ff       	call   80108b8c <arp_proc>
8010938b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010938e:	eb 24                	jmp    801093b4 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109393:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109397:	3c 08                	cmp    $0x8,%al
80109399:	75 19                	jne    801093b4 <eth_proc+0x5f>
8010939b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093a2:	84 c0                	test   %al,%al
801093a4:	75 0e                	jne    801093b4 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801093a6:	83 ec 0c             	sub    $0xc,%esp
801093a9:	ff 75 08             	push   0x8(%ebp)
801093ac:	e8 8d 00 00 00       	call   8010943e <ipv4_proc>
801093b1:	83 c4 10             	add    $0x10,%esp
}
801093b4:	90                   	nop
801093b5:	c9                   	leave
801093b6:	c3                   	ret

801093b7 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801093b7:	55                   	push   %ebp
801093b8:	89 e5                	mov    %esp,%ebp
801093ba:	83 ec 04             	sub    $0x4,%esp
801093bd:	8b 45 08             	mov    0x8(%ebp),%eax
801093c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801093c4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801093c8:	66 c1 c0 08          	rol    $0x8,%ax
}
801093cc:	c9                   	leave
801093cd:	c3                   	ret

801093ce <H2N_ushort>:

ushort H2N_ushort(ushort value){
801093ce:	55                   	push   %ebp
801093cf:	89 e5                	mov    %esp,%ebp
801093d1:	83 ec 04             	sub    $0x4,%esp
801093d4:	8b 45 08             	mov    0x8(%ebp),%eax
801093d7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801093db:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801093df:	66 c1 c0 08          	rol    $0x8,%ax
}
801093e3:	c9                   	leave
801093e4:	c3                   	ret

801093e5 <H2N_uint>:

uint H2N_uint(uint value){
801093e5:	55                   	push   %ebp
801093e6:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801093e8:	8b 45 08             	mov    0x8(%ebp),%eax
801093eb:	c1 e0 18             	shl    $0x18,%eax
801093ee:	25 00 00 00 0f       	and    $0xf000000,%eax
801093f3:	89 c2                	mov    %eax,%edx
801093f5:	8b 45 08             	mov    0x8(%ebp),%eax
801093f8:	c1 e0 08             	shl    $0x8,%eax
801093fb:	25 00 f0 00 00       	and    $0xf000,%eax
80109400:	09 c2                	or     %eax,%edx
80109402:	8b 45 08             	mov    0x8(%ebp),%eax
80109405:	c1 e8 08             	shr    $0x8,%eax
80109408:	83 e0 0f             	and    $0xf,%eax
8010940b:	01 d0                	add    %edx,%eax
}
8010940d:	5d                   	pop    %ebp
8010940e:	c3                   	ret

8010940f <N2H_uint>:

uint N2H_uint(uint value){
8010940f:	55                   	push   %ebp
80109410:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109412:	8b 45 08             	mov    0x8(%ebp),%eax
80109415:	c1 e0 18             	shl    $0x18,%eax
80109418:	89 c2                	mov    %eax,%edx
8010941a:	8b 45 08             	mov    0x8(%ebp),%eax
8010941d:	c1 e0 08             	shl    $0x8,%eax
80109420:	25 00 00 ff 00       	and    $0xff0000,%eax
80109425:	01 c2                	add    %eax,%edx
80109427:	8b 45 08             	mov    0x8(%ebp),%eax
8010942a:	c1 e8 08             	shr    $0x8,%eax
8010942d:	25 00 ff 00 00       	and    $0xff00,%eax
80109432:	01 c2                	add    %eax,%edx
80109434:	8b 45 08             	mov    0x8(%ebp),%eax
80109437:	c1 e8 18             	shr    $0x18,%eax
8010943a:	01 d0                	add    %edx,%eax
}
8010943c:	5d                   	pop    %ebp
8010943d:	c3                   	ret

8010943e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010943e:	55                   	push   %ebp
8010943f:	89 e5                	mov    %esp,%ebp
80109441:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109444:	8b 45 08             	mov    0x8(%ebp),%eax
80109447:	83 c0 0e             	add    $0xe,%eax
8010944a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010944d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109450:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109454:	0f b7 d0             	movzwl %ax,%edx
80109457:	a1 e8 e4 10 80       	mov    0x8010e4e8,%eax
8010945c:	39 c2                	cmp    %eax,%edx
8010945e:	74 60                	je     801094c0 <ipv4_proc+0x82>
80109460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109463:	83 c0 0c             	add    $0xc,%eax
80109466:	83 ec 04             	sub    $0x4,%esp
80109469:	6a 04                	push   $0x4
8010946b:	50                   	push   %eax
8010946c:	68 e4 e4 10 80       	push   $0x8010e4e4
80109471:	e8 79 b5 ff ff       	call   801049ef <memcmp>
80109476:	83 c4 10             	add    $0x10,%esp
80109479:	85 c0                	test   %eax,%eax
8010947b:	74 43                	je     801094c0 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010947d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109480:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109484:	0f b7 c0             	movzwl %ax,%eax
80109487:	a3 e8 e4 10 80       	mov    %eax,0x8010e4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010948c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109493:	3c 01                	cmp    $0x1,%al
80109495:	75 10                	jne    801094a7 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109497:	83 ec 0c             	sub    $0xc,%esp
8010949a:	ff 75 08             	push   0x8(%ebp)
8010949d:	e8 a3 00 00 00       	call   80109545 <icmp_proc>
801094a2:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801094a5:	eb 19                	jmp    801094c0 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801094a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094aa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094ae:	3c 06                	cmp    $0x6,%al
801094b0:	75 0e                	jne    801094c0 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801094b2:	83 ec 0c             	sub    $0xc,%esp
801094b5:	ff 75 08             	push   0x8(%ebp)
801094b8:	e8 b3 03 00 00       	call   80109870 <tcp_proc>
801094bd:	83 c4 10             	add    $0x10,%esp
}
801094c0:	90                   	nop
801094c1:	c9                   	leave
801094c2:	c3                   	ret

801094c3 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801094c3:	55                   	push   %ebp
801094c4:	89 e5                	mov    %esp,%ebp
801094c6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801094c9:	8b 45 08             	mov    0x8(%ebp),%eax
801094cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801094cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d2:	0f b6 00             	movzbl (%eax),%eax
801094d5:	83 e0 0f             	and    $0xf,%eax
801094d8:	01 c0                	add    %eax,%eax
801094da:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801094dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801094e4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801094eb:	eb 48                	jmp    80109535 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801094ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801094f0:	01 c0                	add    %eax,%eax
801094f2:	89 c2                	mov    %eax,%edx
801094f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f7:	01 d0                	add    %edx,%eax
801094f9:	0f b6 00             	movzbl (%eax),%eax
801094fc:	0f b6 c0             	movzbl %al,%eax
801094ff:	c1 e0 08             	shl    $0x8,%eax
80109502:	89 c2                	mov    %eax,%edx
80109504:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109507:	01 c0                	add    %eax,%eax
80109509:	8d 48 01             	lea    0x1(%eax),%ecx
8010950c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950f:	01 c8                	add    %ecx,%eax
80109511:	0f b6 00             	movzbl (%eax),%eax
80109514:	0f b6 c0             	movzbl %al,%eax
80109517:	01 d0                	add    %edx,%eax
80109519:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010951c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109523:	76 0c                	jbe    80109531 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109525:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109528:	0f b7 c0             	movzwl %ax,%eax
8010952b:	83 c0 01             	add    $0x1,%eax
8010952e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109531:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109539:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010953c:	7c af                	jl     801094ed <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010953e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109541:	f7 d0                	not    %eax
}
80109543:	c9                   	leave
80109544:	c3                   	ret

80109545 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109545:	55                   	push   %ebp
80109546:	89 e5                	mov    %esp,%ebp
80109548:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010954b:	8b 45 08             	mov    0x8(%ebp),%eax
8010954e:	83 c0 0e             	add    $0xe,%eax
80109551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109557:	0f b6 00             	movzbl (%eax),%eax
8010955a:	0f b6 c0             	movzbl %al,%eax
8010955d:	83 e0 0f             	and    $0xf,%eax
80109560:	c1 e0 02             	shl    $0x2,%eax
80109563:	89 c2                	mov    %eax,%edx
80109565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109568:	01 d0                	add    %edx,%eax
8010956a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010956d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109570:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109574:	84 c0                	test   %al,%al
80109576:	75 4f                	jne    801095c7 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010957b:	0f b6 00             	movzbl (%eax),%eax
8010957e:	3c 08                	cmp    $0x8,%al
80109580:	75 45                	jne    801095c7 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109582:	e8 21 92 ff ff       	call   801027a8 <kalloc>
80109587:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010958a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109591:	83 ec 04             	sub    $0x4,%esp
80109594:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109597:	50                   	push   %eax
80109598:	ff 75 ec             	push   -0x14(%ebp)
8010959b:	ff 75 08             	push   0x8(%ebp)
8010959e:	e8 78 00 00 00       	call   8010961b <icmp_reply_pkt_create>
801095a3:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801095a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095a9:	83 ec 08             	sub    $0x8,%esp
801095ac:	50                   	push   %eax
801095ad:	ff 75 ec             	push   -0x14(%ebp)
801095b0:	e8 ad f4 ff ff       	call   80108a62 <i8254_send>
801095b5:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801095b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095bb:	83 ec 0c             	sub    $0xc,%esp
801095be:	50                   	push   %eax
801095bf:	e8 4a 91 ff ff       	call   8010270e <kfree>
801095c4:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801095c7:	90                   	nop
801095c8:	c9                   	leave
801095c9:	c3                   	ret

801095ca <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801095ca:	55                   	push   %ebp
801095cb:	89 e5                	mov    %esp,%ebp
801095cd:	53                   	push   %ebx
801095ce:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801095d1:	8b 45 08             	mov    0x8(%ebp),%eax
801095d4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095d8:	0f b7 c0             	movzwl %ax,%eax
801095db:	83 ec 0c             	sub    $0xc,%esp
801095de:	50                   	push   %eax
801095df:	e8 d3 fd ff ff       	call   801093b7 <N2H_ushort>
801095e4:	83 c4 10             	add    $0x10,%esp
801095e7:	0f b7 d8             	movzwl %ax,%ebx
801095ea:	8b 45 08             	mov    0x8(%ebp),%eax
801095ed:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095f1:	0f b7 c0             	movzwl %ax,%eax
801095f4:	83 ec 0c             	sub    $0xc,%esp
801095f7:	50                   	push   %eax
801095f8:	e8 ba fd ff ff       	call   801093b7 <N2H_ushort>
801095fd:	83 c4 10             	add    $0x10,%esp
80109600:	0f b7 c0             	movzwl %ax,%eax
80109603:	83 ec 04             	sub    $0x4,%esp
80109606:	53                   	push   %ebx
80109607:	50                   	push   %eax
80109608:	68 03 bf 10 80       	push   $0x8010bf03
8010960d:	e8 e2 6d ff ff       	call   801003f4 <cprintf>
80109612:	83 c4 10             	add    $0x10,%esp
}
80109615:	90                   	nop
80109616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109619:	c9                   	leave
8010961a:	c3                   	ret

8010961b <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010961b:	55                   	push   %ebp
8010961c:	89 e5                	mov    %esp,%ebp
8010961e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109621:	8b 45 08             	mov    0x8(%ebp),%eax
80109624:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109627:	8b 45 08             	mov    0x8(%ebp),%eax
8010962a:	83 c0 0e             	add    $0xe,%eax
8010962d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109633:	0f b6 00             	movzbl (%eax),%eax
80109636:	0f b6 c0             	movzbl %al,%eax
80109639:	83 e0 0f             	and    $0xf,%eax
8010963c:	c1 e0 02             	shl    $0x2,%eax
8010963f:	89 c2                	mov    %eax,%edx
80109641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109644:	01 d0                	add    %edx,%eax
80109646:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010964c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010964f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109652:	83 c0 0e             	add    $0xe,%eax
80109655:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010965b:	83 c0 14             	add    $0x14,%eax
8010965e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109661:	8b 45 10             	mov    0x10(%ebp),%eax
80109664:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010966a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966d:	8d 50 06             	lea    0x6(%eax),%edx
80109670:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109673:	83 ec 04             	sub    $0x4,%esp
80109676:	6a 06                	push   $0x6
80109678:	52                   	push   %edx
80109679:	50                   	push   %eax
8010967a:	e8 c8 b3 ff ff       	call   80104a47 <memmove>
8010967f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109682:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109685:	83 c0 06             	add    $0x6,%eax
80109688:	83 ec 04             	sub    $0x4,%esp
8010968b:	6a 06                	push   $0x6
8010968d:	68 80 5d 19 80       	push   $0x80195d80
80109692:	50                   	push   %eax
80109693:	e8 af b3 ff ff       	call   80104a47 <memmove>
80109698:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010969b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010969e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801096a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096a5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801096a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096ac:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801096af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096b2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
801096b6:	83 ec 0c             	sub    $0xc,%esp
801096b9:	6a 54                	push   $0x54
801096bb:	e8 0e fd ff ff       	call   801093ce <H2N_ushort>
801096c0:	83 c4 10             	add    $0x10,%esp
801096c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801096c6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
801096ca:	0f b7 15 60 60 19 80 	movzwl 0x80196060,%edx
801096d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096d4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801096d8:	0f b7 05 60 60 19 80 	movzwl 0x80196060,%eax
801096df:	83 c0 01             	add    $0x1,%eax
801096e2:	66 a3 60 60 19 80    	mov    %ax,0x80196060
  ipv4_send->fragment = H2N_ushort(0x4000);
801096e8:	83 ec 0c             	sub    $0xc,%esp
801096eb:	68 00 40 00 00       	push   $0x4000
801096f0:	e8 d9 fc ff ff       	call   801093ce <H2N_ushort>
801096f5:	83 c4 10             	add    $0x10,%esp
801096f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801096fb:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
801096ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109702:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109709:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010970d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109710:	83 c0 0c             	add    $0xc,%eax
80109713:	83 ec 04             	sub    $0x4,%esp
80109716:	6a 04                	push   $0x4
80109718:	68 e4 e4 10 80       	push   $0x8010e4e4
8010971d:	50                   	push   %eax
8010971e:	e8 24 b3 ff ff       	call   80104a47 <memmove>
80109723:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109729:	8d 50 0c             	lea    0xc(%eax),%edx
8010972c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010972f:	83 c0 10             	add    $0x10,%eax
80109732:	83 ec 04             	sub    $0x4,%esp
80109735:	6a 04                	push   $0x4
80109737:	52                   	push   %edx
80109738:	50                   	push   %eax
80109739:	e8 09 b3 ff ff       	call   80104a47 <memmove>
8010973e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109744:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010974a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010974d:	83 ec 0c             	sub    $0xc,%esp
80109750:	50                   	push   %eax
80109751:	e8 6d fd ff ff       	call   801094c3 <ipv4_chksum>
80109756:	83 c4 10             	add    $0x10,%esp
80109759:	0f b7 c0             	movzwl %ax,%eax
8010975c:	83 ec 0c             	sub    $0xc,%esp
8010975f:	50                   	push   %eax
80109760:	e8 69 fc ff ff       	call   801093ce <H2N_ushort>
80109765:	83 c4 10             	add    $0x10,%esp
80109768:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010976b:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010976f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109772:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109775:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109778:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010977c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010977f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109783:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109786:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010978a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010978d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109791:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109794:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109798:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010979b:	8d 50 08             	lea    0x8(%eax),%edx
8010979e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097a1:	83 c0 08             	add    $0x8,%eax
801097a4:	83 ec 04             	sub    $0x4,%esp
801097a7:	6a 08                	push   $0x8
801097a9:	52                   	push   %edx
801097aa:	50                   	push   %eax
801097ab:	e8 97 b2 ff ff       	call   80104a47 <memmove>
801097b0:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801097b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097b6:	8d 50 10             	lea    0x10(%eax),%edx
801097b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097bc:	83 c0 10             	add    $0x10,%eax
801097bf:	83 ec 04             	sub    $0x4,%esp
801097c2:	6a 30                	push   $0x30
801097c4:	52                   	push   %edx
801097c5:	50                   	push   %eax
801097c6:	e8 7c b2 ff ff       	call   80104a47 <memmove>
801097cb:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
801097ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d1:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
801097d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097da:	83 ec 0c             	sub    $0xc,%esp
801097dd:	50                   	push   %eax
801097de:	e8 1c 00 00 00       	call   801097ff <icmp_chksum>
801097e3:	83 c4 10             	add    $0x10,%esp
801097e6:	0f b7 c0             	movzwl %ax,%eax
801097e9:	83 ec 0c             	sub    $0xc,%esp
801097ec:	50                   	push   %eax
801097ed:	e8 dc fb ff ff       	call   801093ce <H2N_ushort>
801097f2:	83 c4 10             	add    $0x10,%esp
801097f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801097f8:	66 89 42 02          	mov    %ax,0x2(%edx)
}
801097fc:	90                   	nop
801097fd:	c9                   	leave
801097fe:	c3                   	ret

801097ff <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
801097ff:	55                   	push   %ebp
80109800:	89 e5                	mov    %esp,%ebp
80109802:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109805:	8b 45 08             	mov    0x8(%ebp),%eax
80109808:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010980b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109812:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109819:	eb 48                	jmp    80109863 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010981b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010981e:	01 c0                	add    %eax,%eax
80109820:	89 c2                	mov    %eax,%edx
80109822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109825:	01 d0                	add    %edx,%eax
80109827:	0f b6 00             	movzbl (%eax),%eax
8010982a:	0f b6 c0             	movzbl %al,%eax
8010982d:	c1 e0 08             	shl    $0x8,%eax
80109830:	89 c2                	mov    %eax,%edx
80109832:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109835:	01 c0                	add    %eax,%eax
80109837:	8d 48 01             	lea    0x1(%eax),%ecx
8010983a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983d:	01 c8                	add    %ecx,%eax
8010983f:	0f b6 00             	movzbl (%eax),%eax
80109842:	0f b6 c0             	movzbl %al,%eax
80109845:	01 d0                	add    %edx,%eax
80109847:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010984a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109851:	76 0c                	jbe    8010985f <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109853:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109856:	0f b7 c0             	movzwl %ax,%eax
80109859:	83 c0 01             	add    $0x1,%eax
8010985c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010985f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109863:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109867:	7e b2                	jle    8010981b <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109869:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010986c:	f7 d0                	not    %eax
}
8010986e:	c9                   	leave
8010986f:	c3                   	ret

80109870 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109870:	55                   	push   %ebp
80109871:	89 e5                	mov    %esp,%ebp
80109873:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109876:	8b 45 08             	mov    0x8(%ebp),%eax
80109879:	83 c0 0e             	add    $0xe,%eax
8010987c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010987f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109882:	0f b6 00             	movzbl (%eax),%eax
80109885:	0f b6 c0             	movzbl %al,%eax
80109888:	83 e0 0f             	and    $0xf,%eax
8010988b:	c1 e0 02             	shl    $0x2,%eax
8010988e:	89 c2                	mov    %eax,%edx
80109890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109893:	01 d0                	add    %edx,%eax
80109895:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989b:	83 c0 14             	add    $0x14,%eax
8010989e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801098a1:	e8 02 8f ff ff       	call   801027a8 <kalloc>
801098a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801098a9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
801098b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098b7:	0f b6 c0             	movzbl %al,%eax
801098ba:	83 e0 02             	and    $0x2,%eax
801098bd:	85 c0                	test   %eax,%eax
801098bf:	74 3d                	je     801098fe <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
801098c1:	83 ec 0c             	sub    $0xc,%esp
801098c4:	6a 00                	push   $0x0
801098c6:	6a 12                	push   $0x12
801098c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801098cb:	50                   	push   %eax
801098cc:	ff 75 e8             	push   -0x18(%ebp)
801098cf:	ff 75 08             	push   0x8(%ebp)
801098d2:	e8 a2 01 00 00       	call   80109a79 <tcp_pkt_create>
801098d7:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
801098da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801098dd:	83 ec 08             	sub    $0x8,%esp
801098e0:	50                   	push   %eax
801098e1:	ff 75 e8             	push   -0x18(%ebp)
801098e4:	e8 79 f1 ff ff       	call   80108a62 <i8254_send>
801098e9:	83 c4 10             	add    $0x10,%esp
    seq_num++;
801098ec:	a1 64 60 19 80       	mov    0x80196064,%eax
801098f1:	83 c0 01             	add    $0x1,%eax
801098f4:	a3 64 60 19 80       	mov    %eax,0x80196064
801098f9:	e9 69 01 00 00       	jmp    80109a67 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
801098fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109901:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109905:	3c 18                	cmp    $0x18,%al
80109907:	0f 85 10 01 00 00    	jne    80109a1d <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010990d:	83 ec 04             	sub    $0x4,%esp
80109910:	6a 03                	push   $0x3
80109912:	68 1e bf 10 80       	push   $0x8010bf1e
80109917:	ff 75 ec             	push   -0x14(%ebp)
8010991a:	e8 d0 b0 ff ff       	call   801049ef <memcmp>
8010991f:	83 c4 10             	add    $0x10,%esp
80109922:	85 c0                	test   %eax,%eax
80109924:	74 74                	je     8010999a <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109926:	83 ec 0c             	sub    $0xc,%esp
80109929:	68 22 bf 10 80       	push   $0x8010bf22
8010992e:	e8 c1 6a ff ff       	call   801003f4 <cprintf>
80109933:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109936:	83 ec 0c             	sub    $0xc,%esp
80109939:	6a 00                	push   $0x0
8010993b:	6a 10                	push   $0x10
8010993d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109940:	50                   	push   %eax
80109941:	ff 75 e8             	push   -0x18(%ebp)
80109944:	ff 75 08             	push   0x8(%ebp)
80109947:	e8 2d 01 00 00       	call   80109a79 <tcp_pkt_create>
8010994c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010994f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109952:	83 ec 08             	sub    $0x8,%esp
80109955:	50                   	push   %eax
80109956:	ff 75 e8             	push   -0x18(%ebp)
80109959:	e8 04 f1 ff ff       	call   80108a62 <i8254_send>
8010995e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109961:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109964:	83 c0 36             	add    $0x36,%eax
80109967:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010996a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010996d:	50                   	push   %eax
8010996e:	ff 75 e0             	push   -0x20(%ebp)
80109971:	6a 00                	push   $0x0
80109973:	6a 00                	push   $0x0
80109975:	e8 5a 04 00 00       	call   80109dd4 <http_proc>
8010997a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010997d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109980:	83 ec 0c             	sub    $0xc,%esp
80109983:	50                   	push   %eax
80109984:	6a 18                	push   $0x18
80109986:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109989:	50                   	push   %eax
8010998a:	ff 75 e8             	push   -0x18(%ebp)
8010998d:	ff 75 08             	push   0x8(%ebp)
80109990:	e8 e4 00 00 00       	call   80109a79 <tcp_pkt_create>
80109995:	83 c4 20             	add    $0x20,%esp
80109998:	eb 62                	jmp    801099fc <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010999a:	83 ec 0c             	sub    $0xc,%esp
8010999d:	6a 00                	push   $0x0
8010999f:	6a 10                	push   $0x10
801099a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099a4:	50                   	push   %eax
801099a5:	ff 75 e8             	push   -0x18(%ebp)
801099a8:	ff 75 08             	push   0x8(%ebp)
801099ab:	e8 c9 00 00 00       	call   80109a79 <tcp_pkt_create>
801099b0:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
801099b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099b6:	83 ec 08             	sub    $0x8,%esp
801099b9:	50                   	push   %eax
801099ba:	ff 75 e8             	push   -0x18(%ebp)
801099bd:	e8 a0 f0 ff ff       	call   80108a62 <i8254_send>
801099c2:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099c8:	83 c0 36             	add    $0x36,%eax
801099cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
801099ce:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801099d1:	50                   	push   %eax
801099d2:	ff 75 e4             	push   -0x1c(%ebp)
801099d5:	6a 00                	push   $0x0
801099d7:	6a 00                	push   $0x0
801099d9:	e8 f6 03 00 00       	call   80109dd4 <http_proc>
801099de:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
801099e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801099e4:	83 ec 0c             	sub    $0xc,%esp
801099e7:	50                   	push   %eax
801099e8:	6a 18                	push   $0x18
801099ea:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099ed:	50                   	push   %eax
801099ee:	ff 75 e8             	push   -0x18(%ebp)
801099f1:	ff 75 08             	push   0x8(%ebp)
801099f4:	e8 80 00 00 00       	call   80109a79 <tcp_pkt_create>
801099f9:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
801099fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099ff:	83 ec 08             	sub    $0x8,%esp
80109a02:	50                   	push   %eax
80109a03:	ff 75 e8             	push   -0x18(%ebp)
80109a06:	e8 57 f0 ff ff       	call   80108a62 <i8254_send>
80109a0b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a0e:	a1 64 60 19 80       	mov    0x80196064,%eax
80109a13:	83 c0 01             	add    $0x1,%eax
80109a16:	a3 64 60 19 80       	mov    %eax,0x80196064
80109a1b:	eb 4a                	jmp    80109a67 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a20:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a24:	3c 10                	cmp    $0x10,%al
80109a26:	75 3f                	jne    80109a67 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109a28:	a1 68 60 19 80       	mov    0x80196068,%eax
80109a2d:	83 f8 01             	cmp    $0x1,%eax
80109a30:	75 35                	jne    80109a67 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109a32:	83 ec 0c             	sub    $0xc,%esp
80109a35:	6a 00                	push   $0x0
80109a37:	6a 01                	push   $0x1
80109a39:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a3c:	50                   	push   %eax
80109a3d:	ff 75 e8             	push   -0x18(%ebp)
80109a40:	ff 75 08             	push   0x8(%ebp)
80109a43:	e8 31 00 00 00       	call   80109a79 <tcp_pkt_create>
80109a48:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109a4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a4e:	83 ec 08             	sub    $0x8,%esp
80109a51:	50                   	push   %eax
80109a52:	ff 75 e8             	push   -0x18(%ebp)
80109a55:	e8 08 f0 ff ff       	call   80108a62 <i8254_send>
80109a5a:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109a5d:	c7 05 68 60 19 80 00 	movl   $0x0,0x80196068
80109a64:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a6a:	83 ec 0c             	sub    $0xc,%esp
80109a6d:	50                   	push   %eax
80109a6e:	e8 9b 8c ff ff       	call   8010270e <kfree>
80109a73:	83 c4 10             	add    $0x10,%esp
}
80109a76:	90                   	nop
80109a77:	c9                   	leave
80109a78:	c3                   	ret

80109a79 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109a79:	55                   	push   %ebp
80109a7a:	89 e5                	mov    %esp,%ebp
80109a7c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109a85:	8b 45 08             	mov    0x8(%ebp),%eax
80109a88:	83 c0 0e             	add    $0xe,%eax
80109a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a91:	0f b6 00             	movzbl (%eax),%eax
80109a94:	0f b6 c0             	movzbl %al,%eax
80109a97:	83 e0 0f             	and    $0xf,%eax
80109a9a:	c1 e0 02             	shl    $0x2,%eax
80109a9d:	89 c2                	mov    %eax,%edx
80109a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa2:	01 d0                	add    %edx,%eax
80109aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109aad:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ab0:	83 c0 0e             	add    $0xe,%eax
80109ab3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ab9:	83 c0 14             	add    $0x14,%eax
80109abc:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109abf:	8b 45 18             	mov    0x18(%ebp),%eax
80109ac2:	8d 50 36             	lea    0x36(%eax),%edx
80109ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80109ac8:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acd:	8d 50 06             	lea    0x6(%eax),%edx
80109ad0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ad3:	83 ec 04             	sub    $0x4,%esp
80109ad6:	6a 06                	push   $0x6
80109ad8:	52                   	push   %edx
80109ad9:	50                   	push   %eax
80109ada:	e8 68 af ff ff       	call   80104a47 <memmove>
80109adf:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109ae2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ae5:	83 c0 06             	add    $0x6,%eax
80109ae8:	83 ec 04             	sub    $0x4,%esp
80109aeb:	6a 06                	push   $0x6
80109aed:	68 80 5d 19 80       	push   $0x80195d80
80109af2:	50                   	push   %eax
80109af3:	e8 4f af ff ff       	call   80104a47 <memmove>
80109af8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109afe:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b05:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b0c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b12:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109b16:	8b 45 18             	mov    0x18(%ebp),%eax
80109b19:	83 c0 28             	add    $0x28,%eax
80109b1c:	0f b7 c0             	movzwl %ax,%eax
80109b1f:	83 ec 0c             	sub    $0xc,%esp
80109b22:	50                   	push   %eax
80109b23:	e8 a6 f8 ff ff       	call   801093ce <H2N_ushort>
80109b28:	83 c4 10             	add    $0x10,%esp
80109b2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b2e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b32:	0f b7 15 60 60 19 80 	movzwl 0x80196060,%edx
80109b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b3c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b40:	0f b7 05 60 60 19 80 	movzwl 0x80196060,%eax
80109b47:	83 c0 01             	add    $0x1,%eax
80109b4a:	66 a3 60 60 19 80    	mov    %ax,0x80196060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109b50:	83 ec 0c             	sub    $0xc,%esp
80109b53:	6a 00                	push   $0x0
80109b55:	e8 74 f8 ff ff       	call   801093ce <H2N_ushort>
80109b5a:	83 c4 10             	add    $0x10,%esp
80109b5d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b60:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b67:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109b6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6e:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109b72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b75:	83 c0 0c             	add    $0xc,%eax
80109b78:	83 ec 04             	sub    $0x4,%esp
80109b7b:	6a 04                	push   $0x4
80109b7d:	68 e4 e4 10 80       	push   $0x8010e4e4
80109b82:	50                   	push   %eax
80109b83:	e8 bf ae ff ff       	call   80104a47 <memmove>
80109b88:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b8e:	8d 50 0c             	lea    0xc(%eax),%edx
80109b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b94:	83 c0 10             	add    $0x10,%eax
80109b97:	83 ec 04             	sub    $0x4,%esp
80109b9a:	6a 04                	push   $0x4
80109b9c:	52                   	push   %edx
80109b9d:	50                   	push   %eax
80109b9e:	e8 a4 ae ff ff       	call   80104a47 <memmove>
80109ba3:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ba9:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bb2:	83 ec 0c             	sub    $0xc,%esp
80109bb5:	50                   	push   %eax
80109bb6:	e8 08 f9 ff ff       	call   801094c3 <ipv4_chksum>
80109bbb:	83 c4 10             	add    $0x10,%esp
80109bbe:	0f b7 c0             	movzwl %ax,%eax
80109bc1:	83 ec 0c             	sub    $0xc,%esp
80109bc4:	50                   	push   %eax
80109bc5:	e8 04 f8 ff ff       	call   801093ce <H2N_ushort>
80109bca:	83 c4 10             	add    $0x10,%esp
80109bcd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bd0:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bd7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109bdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bde:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109be4:	0f b7 10             	movzwl (%eax),%edx
80109be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109bea:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109bee:	a1 64 60 19 80       	mov    0x80196064,%eax
80109bf3:	83 ec 0c             	sub    $0xc,%esp
80109bf6:	50                   	push   %eax
80109bf7:	e8 e9 f7 ff ff       	call   801093e5 <H2N_uint>
80109bfc:	83 c4 10             	add    $0x10,%esp
80109bff:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c02:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c08:	8b 40 04             	mov    0x4(%eax),%eax
80109c0b:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109c11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c14:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109c17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c1a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109c1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c21:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109c25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c28:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109c2c:	8b 45 14             	mov    0x14(%ebp),%eax
80109c2f:	89 c2                	mov    %eax,%edx
80109c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c34:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109c37:	83 ec 0c             	sub    $0xc,%esp
80109c3a:	68 90 38 00 00       	push   $0x3890
80109c3f:	e8 8a f7 ff ff       	call   801093ce <H2N_ushort>
80109c44:	83 c4 10             	add    $0x10,%esp
80109c47:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c4a:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c51:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c5a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109c60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c63:	83 ec 0c             	sub    $0xc,%esp
80109c66:	50                   	push   %eax
80109c67:	e8 1f 00 00 00       	call   80109c8b <tcp_chksum>
80109c6c:	83 c4 10             	add    $0x10,%esp
80109c6f:	83 c0 08             	add    $0x8,%eax
80109c72:	0f b7 c0             	movzwl %ax,%eax
80109c75:	83 ec 0c             	sub    $0xc,%esp
80109c78:	50                   	push   %eax
80109c79:	e8 50 f7 ff ff       	call   801093ce <H2N_ushort>
80109c7e:	83 c4 10             	add    $0x10,%esp
80109c81:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c84:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109c88:	90                   	nop
80109c89:	c9                   	leave
80109c8a:	c3                   	ret

80109c8b <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109c8b:	55                   	push   %ebp
80109c8c:	89 e5                	mov    %esp,%ebp
80109c8e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109c91:	8b 45 08             	mov    0x8(%ebp),%eax
80109c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109c97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c9a:	83 c0 14             	add    $0x14,%eax
80109c9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109ca0:	83 ec 04             	sub    $0x4,%esp
80109ca3:	6a 04                	push   $0x4
80109ca5:	68 e4 e4 10 80       	push   $0x8010e4e4
80109caa:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cad:	50                   	push   %eax
80109cae:	e8 94 ad ff ff       	call   80104a47 <memmove>
80109cb3:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cb9:	83 c0 0c             	add    $0xc,%eax
80109cbc:	83 ec 04             	sub    $0x4,%esp
80109cbf:	6a 04                	push   $0x4
80109cc1:	50                   	push   %eax
80109cc2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cc5:	83 c0 04             	add    $0x4,%eax
80109cc8:	50                   	push   %eax
80109cc9:	e8 79 ad ff ff       	call   80104a47 <memmove>
80109cce:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109cd1:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109cd5:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109cd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cdc:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109ce0:	0f b7 c0             	movzwl %ax,%eax
80109ce3:	83 ec 0c             	sub    $0xc,%esp
80109ce6:	50                   	push   %eax
80109ce7:	e8 cb f6 ff ff       	call   801093b7 <N2H_ushort>
80109cec:	83 c4 10             	add    $0x10,%esp
80109cef:	83 e8 14             	sub    $0x14,%eax
80109cf2:	0f b7 c0             	movzwl %ax,%eax
80109cf5:	83 ec 0c             	sub    $0xc,%esp
80109cf8:	50                   	push   %eax
80109cf9:	e8 d0 f6 ff ff       	call   801093ce <H2N_ushort>
80109cfe:	83 c4 10             	add    $0x10,%esp
80109d01:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109d0c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109d12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d19:	eb 33                	jmp    80109d4e <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d1e:	01 c0                	add    %eax,%eax
80109d20:	89 c2                	mov    %eax,%edx
80109d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d25:	01 d0                	add    %edx,%eax
80109d27:	0f b6 00             	movzbl (%eax),%eax
80109d2a:	0f b6 c0             	movzbl %al,%eax
80109d2d:	c1 e0 08             	shl    $0x8,%eax
80109d30:	89 c2                	mov    %eax,%edx
80109d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d35:	01 c0                	add    %eax,%eax
80109d37:	8d 48 01             	lea    0x1(%eax),%ecx
80109d3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d3d:	01 c8                	add    %ecx,%eax
80109d3f:	0f b6 00             	movzbl (%eax),%eax
80109d42:	0f b6 c0             	movzbl %al,%eax
80109d45:	01 d0                	add    %edx,%eax
80109d47:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109d4a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d4e:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109d52:	7e c7                	jle    80109d1b <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109d5a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109d61:	eb 33                	jmp    80109d96 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d66:	01 c0                	add    %eax,%eax
80109d68:	89 c2                	mov    %eax,%edx
80109d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d6d:	01 d0                	add    %edx,%eax
80109d6f:	0f b6 00             	movzbl (%eax),%eax
80109d72:	0f b6 c0             	movzbl %al,%eax
80109d75:	c1 e0 08             	shl    $0x8,%eax
80109d78:	89 c2                	mov    %eax,%edx
80109d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d7d:	01 c0                	add    %eax,%eax
80109d7f:	8d 48 01             	lea    0x1(%eax),%ecx
80109d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d85:	01 c8                	add    %ecx,%eax
80109d87:	0f b6 00             	movzbl (%eax),%eax
80109d8a:	0f b6 c0             	movzbl %al,%eax
80109d8d:	01 d0                	add    %edx,%eax
80109d8f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109d92:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109d96:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109d9a:	0f b7 c0             	movzwl %ax,%eax
80109d9d:	83 ec 0c             	sub    $0xc,%esp
80109da0:	50                   	push   %eax
80109da1:	e8 11 f6 ff ff       	call   801093b7 <N2H_ushort>
80109da6:	83 c4 10             	add    $0x10,%esp
80109da9:	66 d1 e8             	shr    $1,%ax
80109dac:	0f b7 c0             	movzwl %ax,%eax
80109daf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109db2:	7c af                	jl     80109d63 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db7:	c1 e8 10             	shr    $0x10,%eax
80109dba:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc0:	f7 d0                	not    %eax
}
80109dc2:	c9                   	leave
80109dc3:	c3                   	ret

80109dc4 <tcp_fin>:

void tcp_fin(){
80109dc4:	55                   	push   %ebp
80109dc5:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109dc7:	c7 05 68 60 19 80 01 	movl   $0x1,0x80196068
80109dce:	00 00 00 
}
80109dd1:	90                   	nop
80109dd2:	5d                   	pop    %ebp
80109dd3:	c3                   	ret

80109dd4 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109dd4:	55                   	push   %ebp
80109dd5:	89 e5                	mov    %esp,%ebp
80109dd7:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109dda:	8b 45 10             	mov    0x10(%ebp),%eax
80109ddd:	83 ec 04             	sub    $0x4,%esp
80109de0:	6a 00                	push   $0x0
80109de2:	68 2b bf 10 80       	push   $0x8010bf2b
80109de7:	50                   	push   %eax
80109de8:	e8 65 00 00 00       	call   80109e52 <http_strcpy>
80109ded:	83 c4 10             	add    $0x10,%esp
80109df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109df3:	8b 45 10             	mov    0x10(%ebp),%eax
80109df6:	83 ec 04             	sub    $0x4,%esp
80109df9:	ff 75 f4             	push   -0xc(%ebp)
80109dfc:	68 3e bf 10 80       	push   $0x8010bf3e
80109e01:	50                   	push   %eax
80109e02:	e8 4b 00 00 00       	call   80109e52 <http_strcpy>
80109e07:	83 c4 10             	add    $0x10,%esp
80109e0a:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109e0d:	8b 45 10             	mov    0x10(%ebp),%eax
80109e10:	83 ec 04             	sub    $0x4,%esp
80109e13:	ff 75 f4             	push   -0xc(%ebp)
80109e16:	68 59 bf 10 80       	push   $0x8010bf59
80109e1b:	50                   	push   %eax
80109e1c:	e8 31 00 00 00       	call   80109e52 <http_strcpy>
80109e21:	83 c4 10             	add    $0x10,%esp
80109e24:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e2a:	83 e0 01             	and    $0x1,%eax
80109e2d:	85 c0                	test   %eax,%eax
80109e2f:	74 11                	je     80109e42 <http_proc+0x6e>
    char *payload = (char *)send;
80109e31:	8b 45 10             	mov    0x10(%ebp),%eax
80109e34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109e37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e3d:	01 d0                	add    %edx,%eax
80109e3f:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109e42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e45:	8b 45 14             	mov    0x14(%ebp),%eax
80109e48:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109e4a:	e8 75 ff ff ff       	call   80109dc4 <tcp_fin>
}
80109e4f:	90                   	nop
80109e50:	c9                   	leave
80109e51:	c3                   	ret

80109e52 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109e52:	55                   	push   %ebp
80109e53:	89 e5                	mov    %esp,%ebp
80109e55:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109e58:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109e5f:	eb 20                	jmp    80109e81 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109e61:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109e64:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e67:	01 d0                	add    %edx,%eax
80109e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109e6c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109e6f:	01 ca                	add    %ecx,%edx
80109e71:	89 d1                	mov    %edx,%ecx
80109e73:	8b 55 08             	mov    0x8(%ebp),%edx
80109e76:	01 ca                	add    %ecx,%edx
80109e78:	0f b6 00             	movzbl (%eax),%eax
80109e7b:	88 02                	mov    %al,(%edx)
    i++;
80109e7d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109e81:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109e84:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e87:	01 d0                	add    %edx,%eax
80109e89:	0f b6 00             	movzbl (%eax),%eax
80109e8c:	84 c0                	test   %al,%al
80109e8e:	75 d1                	jne    80109e61 <http_strcpy+0xf>
  }
  return i;
80109e90:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109e93:	c9                   	leave
80109e94:	c3                   	ret

80109e95 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109e95:	55                   	push   %ebp
80109e96:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109e98:	c7 05 70 60 19 80 a2 	movl   $0x8010e5a2,0x80196070
80109e9f:	e5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109ea2:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109ea7:	c1 e8 09             	shr    $0x9,%eax
80109eaa:	a3 6c 60 19 80       	mov    %eax,0x8019606c
}
80109eaf:	90                   	nop
80109eb0:	5d                   	pop    %ebp
80109eb1:	c3                   	ret

80109eb2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109eb2:	55                   	push   %ebp
80109eb3:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109eb5:	90                   	nop
80109eb6:	5d                   	pop    %ebp
80109eb7:	c3                   	ret

80109eb8 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109eb8:	55                   	push   %ebp
80109eb9:	89 e5                	mov    %esp,%ebp
80109ebb:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80109ec1:	83 c0 0c             	add    $0xc,%eax
80109ec4:	83 ec 0c             	sub    $0xc,%esp
80109ec7:	50                   	push   %eax
80109ec8:	e8 b4 a7 ff ff       	call   80104681 <holdingsleep>
80109ecd:	83 c4 10             	add    $0x10,%esp
80109ed0:	85 c0                	test   %eax,%eax
80109ed2:	75 0d                	jne    80109ee1 <iderw+0x29>
    panic("iderw: buf not locked");
80109ed4:	83 ec 0c             	sub    $0xc,%esp
80109ed7:	68 6a bf 10 80       	push   $0x8010bf6a
80109edc:	e8 c8 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee4:	8b 00                	mov    (%eax),%eax
80109ee6:	83 e0 06             	and    $0x6,%eax
80109ee9:	83 f8 02             	cmp    $0x2,%eax
80109eec:	75 0d                	jne    80109efb <iderw+0x43>
    panic("iderw: nothing to do");
80109eee:	83 ec 0c             	sub    $0xc,%esp
80109ef1:	68 80 bf 10 80       	push   $0x8010bf80
80109ef6:	e8 ae 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109efb:	8b 45 08             	mov    0x8(%ebp),%eax
80109efe:	8b 40 04             	mov    0x4(%eax),%eax
80109f01:	83 f8 01             	cmp    $0x1,%eax
80109f04:	74 0d                	je     80109f13 <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f06:	83 ec 0c             	sub    $0xc,%esp
80109f09:	68 95 bf 10 80       	push   $0x8010bf95
80109f0e:	e8 96 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109f13:	8b 45 08             	mov    0x8(%ebp),%eax
80109f16:	8b 40 08             	mov    0x8(%eax),%eax
80109f19:	8b 15 6c 60 19 80    	mov    0x8019606c,%edx
80109f1f:	39 d0                	cmp    %edx,%eax
80109f21:	72 0d                	jb     80109f30 <iderw+0x78>
    panic("iderw: block out of range");
80109f23:	83 ec 0c             	sub    $0xc,%esp
80109f26:	68 b3 bf 10 80       	push   $0x8010bfb3
80109f2b:	e8 79 66 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109f30:	8b 15 70 60 19 80    	mov    0x80196070,%edx
80109f36:	8b 45 08             	mov    0x8(%ebp),%eax
80109f39:	8b 40 08             	mov    0x8(%eax),%eax
80109f3c:	c1 e0 09             	shl    $0x9,%eax
80109f3f:	01 d0                	add    %edx,%eax
80109f41:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109f44:	8b 45 08             	mov    0x8(%ebp),%eax
80109f47:	8b 00                	mov    (%eax),%eax
80109f49:	83 e0 04             	and    $0x4,%eax
80109f4c:	85 c0                	test   %eax,%eax
80109f4e:	74 2b                	je     80109f7b <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109f50:	8b 45 08             	mov    0x8(%ebp),%eax
80109f53:	8b 00                	mov    (%eax),%eax
80109f55:	83 e0 fb             	and    $0xfffffffb,%eax
80109f58:	89 c2                	mov    %eax,%edx
80109f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5d:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f62:	83 c0 5c             	add    $0x5c,%eax
80109f65:	83 ec 04             	sub    $0x4,%esp
80109f68:	68 00 02 00 00       	push   $0x200
80109f6d:	50                   	push   %eax
80109f6e:	ff 75 f4             	push   -0xc(%ebp)
80109f71:	e8 d1 aa ff ff       	call   80104a47 <memmove>
80109f76:	83 c4 10             	add    $0x10,%esp
80109f79:	eb 1a                	jmp    80109f95 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
80109f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f7e:	83 c0 5c             	add    $0x5c,%eax
80109f81:	83 ec 04             	sub    $0x4,%esp
80109f84:	68 00 02 00 00       	push   $0x200
80109f89:	ff 75 f4             	push   -0xc(%ebp)
80109f8c:	50                   	push   %eax
80109f8d:	e8 b5 aa ff ff       	call   80104a47 <memmove>
80109f92:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
80109f95:	8b 45 08             	mov    0x8(%ebp),%eax
80109f98:	8b 00                	mov    (%eax),%eax
80109f9a:	83 c8 02             	or     $0x2,%eax
80109f9d:	89 c2                	mov    %eax,%edx
80109f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa2:	89 10                	mov    %edx,(%eax)
}
80109fa4:	90                   	nop
80109fa5:	c9                   	leave
80109fa6:	c3                   	ret
