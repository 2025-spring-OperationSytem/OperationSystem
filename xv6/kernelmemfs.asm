
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
8010005a:	bc a0 8d 19 80       	mov    $0x80198da0,%esp
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
8010006f:	68 80 ab 10 80       	push   $0x8010ab80
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 c6 50 00 00       	call   80105144 <initlock>
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
801000bd:	68 87 ab 10 80       	push   $0x8010ab87
801000c2:	50                   	push   %eax
801000c3:	e8 1f 4f 00 00       	call   80104fe7 <initsleeplock>
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
80100101:	e8 60 50 00 00       	call   80105166 <acquire>
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
80100140:	e8 8f 50 00 00       	call   801051d4 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 cc 4e 00 00       	call   80105023 <acquiresleep>
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
801001c1:	e8 0e 50 00 00       	call   801051d4 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 4b 4e 00 00       	call   80105023 <acquiresleep>
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
801001f5:	68 8e ab 10 80       	push   $0x8010ab8e
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
8010022d:	e8 4e a8 00 00       	call   8010aa80 <iderw>
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
8010024a:	e8 86 4e 00 00       	call   801050d5 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f ab 10 80       	push   $0x8010ab9f
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
80100278:	e8 03 a8 00 00       	call   8010aa80 <iderw>
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
80100293:	e8 3d 4e 00 00       	call   801050d5 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 ab 10 80       	push   $0x8010aba6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 cc 4d 00 00       	call   80105087 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 9b 4e 00 00       	call   80105166 <acquire>
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
80100336:	e8 99 4e 00 00       	call   801051d4 <release>
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
80100410:	e8 51 4d 00 00       	call   80105166 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad ab 10 80       	push   $0x8010abad
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
80100510:	c7 45 ec b6 ab 10 80 	movl   $0x8010abb6,-0x14(%ebp)
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
8010059e:	e8 31 4c 00 00       	call   801051d4 <release>
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
801005c7:	68 bd ab 10 80       	push   $0x8010abbd
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
801005e6:	68 d1 ab 10 80       	push   $0x8010abd1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 23 4c 00 00       	call   80105226 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 ab 10 80       	push   $0x8010abd3
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
801006a1:	e8 47 83 00 00       	call   801089ed <graphic_scroll_up>
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
801006f4:	e8 f4 82 00 00       	call   801089ed <graphic_scroll_up>
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
80100756:	e8 ff 82 00 00       	call   80108a5a <font_render>
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
80100793:	e8 cf 66 00 00       	call   80106e67 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 c2 66 00 00       	call   80106e67 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 b5 66 00 00       	call   80106e67 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 a5 66 00 00       	call   80106e67 <uartputc>
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
801007eb:	e8 76 49 00 00       	call   80105166 <acquire>
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
8010093f:	e8 30 3c 00 00       	call   80104574 <wakeup>
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
8010096a:	e8 65 48 00 00       	call   801051d4 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 b2 3c 00 00       	call   8010462f <procdump>
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
801009a2:	e8 bf 47 00 00       	call   80105166 <acquire>
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
801009c3:	e8 0c 48 00 00       	call   801051d4 <release>
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
801009f0:	e8 98 3a 00 00       	call   8010448d <sleep>
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
80100a6e:	e8 61 47 00 00       	call   801051d4 <release>
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
80100aac:	e8 b5 46 00 00       	call   80105166 <acquire>
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
80100aee:	e8 e1 46 00 00       	call   801051d4 <release>
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
80100b1c:	68 d7 ab 10 80       	push   $0x8010abd7
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 19 46 00 00       	call   80105144 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 df ab 10 80 	movl   $0x8010abdf,-0xc(%ebp)
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
80100bbf:	68 f5 ab 10 80       	push   $0x8010abf5
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
80100c1b:	e8 43 72 00 00       	call   80107e63 <setupkvm>
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
80100cc1:	e8 97 75 00 00       	call   8010825d <allocuvm>
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
80100d07:	e8 84 74 00 00       	call   80108190 <loaduvm>
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
80100d76:	e8 e2 74 00 00       	call   8010825d <allocuvm>
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
80100d9a:	e8 20 77 00 00       	call   801084bf <clearpteu>
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
80100dd3:	e8 52 48 00 00       	call   8010562a <strlen>
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
80100e00:	e8 25 48 00 00       	call   8010562a <strlen>
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
80100e26:	e8 33 78 00 00       	call   8010865e <copyout>
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
80100ec2:	e8 97 77 00 00       	call   8010865e <copyout>
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
80100f10:	e8 ca 46 00 00       	call   801055df <safestrcpy>
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
80100f53:	e8 29 70 00 00       	call   80107f81 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 c0 74 00 00       	call   80108426 <freevm>
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
80100fa1:	e8 80 74 00 00       	call   80108426 <freevm>
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
80100fd2:	68 01 ac 10 80       	push   $0x8010ac01
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 63 41 00 00       	call   80105144 <initlock>
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
80100ff5:	e8 6c 41 00 00       	call   80105166 <acquire>
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
80101022:	e8 ad 41 00 00       	call   801051d4 <release>
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
80101045:	e8 8a 41 00 00       	call   801051d4 <release>
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
80101062:	e8 ff 40 00 00       	call   80105166 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 08 ac 10 80       	push   $0x8010ac08
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
80101098:	e8 37 41 00 00       	call   801051d4 <release>
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
801010b3:	e8 ae 40 00 00       	call   80105166 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 10 ac 10 80       	push   $0x8010ac10
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
801010f3:	e8 dc 40 00 00       	call   801051d4 <release>
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
80101141:	e8 8e 40 00 00       	call   801051d4 <release>
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
80101290:	68 1a ac 10 80       	push   $0x8010ac1a
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
80101393:	68 23 ac 10 80       	push   $0x8010ac23
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
801013c9:	68 33 ac 10 80       	push   $0x8010ac33
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
80101401:	e8 95 40 00 00       	call   8010549b <memmove>
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
80101447:	e8 90 3f 00 00       	call   801053dc <memset>
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
801015a5:	68 40 ac 10 80       	push   $0x8010ac40
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
80101630:	68 56 ac 10 80       	push   $0x8010ac56
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
80101694:	68 69 ac 10 80       	push   $0x8010ac69
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 a1 3a 00 00       	call   80105144 <initlock>
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
801016ca:	68 70 ac 10 80       	push   $0x8010ac70
801016cf:	50                   	push   %eax
801016d0:	e8 12 39 00 00       	call   80104fe7 <initsleeplock>
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
80101729:	68 78 ac 10 80       	push   $0x8010ac78
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
801017a2:	e8 35 3c 00 00       	call   801053dc <memset>
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
80101809:	68 cb ac 10 80       	push   $0x8010accb
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
801018af:	e8 e7 3b 00 00       	call   8010549b <memmove>
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
801018e4:	e8 7d 38 00 00       	call   80105166 <acquire>
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
80101932:	e8 9d 38 00 00       	call   801051d4 <release>
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
8010196e:	68 dd ac 10 80       	push   $0x8010acdd
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
801019ab:	e8 24 38 00 00       	call   801051d4 <release>
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
801019c6:	e8 9b 37 00 00       	call   80105166 <acquire>
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
801019e5:	e8 ea 37 00 00       	call   801051d4 <release>
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
80101a0b:	68 ed ac 10 80       	push   $0x8010aced
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 ff 35 00 00       	call   80105023 <acquiresleep>
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
80101ac9:	e8 cd 39 00 00       	call   8010549b <memmove>
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
80101af8:	68 f3 ac 10 80       	push   $0x8010acf3
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
80101b1b:	e8 b5 35 00 00       	call   801050d5 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 02 ad 10 80       	push   $0x8010ad02
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 3a 35 00 00       	call   80105087 <releasesleep>
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
80101b63:	e8 bb 34 00 00       	call   80105023 <acquiresleep>
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
80101b89:	e8 d8 35 00 00       	call   80105166 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 2d 36 00 00       	call   801051d4 <release>
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
80101be9:	e8 99 34 00 00       	call   80105087 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 68 35 00 00       	call   80105166 <acquire>
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
80101c18:	e8 b7 35 00 00       	call   801051d4 <release>
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
80101d5c:	68 0a ad 10 80       	push   $0x8010ad0a
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
80101ffa:	e8 9c 34 00 00       	call   8010549b <memmove>
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
8010214a:	e8 4c 33 00 00       	call   8010549b <memmove>
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
801021ca:	e8 62 33 00 00       	call   80105531 <strncmp>
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
801021ea:	68 1d ad 10 80       	push   $0x8010ad1d
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
80102219:	68 2f ad 10 80       	push   $0x8010ad2f
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
801022ee:	68 3e ad 10 80       	push   $0x8010ad3e
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
80102329:	e8 59 32 00 00       	call   80105587 <strncpy>
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
80102355:	68 4b ad 10 80       	push   $0x8010ad4b
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
801023c7:	e8 cf 30 00 00       	call   8010549b <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 b8 30 00 00       	call   8010549b <memmove>
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
801025c3:	0f b6 05 78 7a 19 80 	movzbl 0x80197a78,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 54 ad 10 80       	push   $0x8010ad54
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
8010267c:	68 86 ad 10 80       	push   $0x8010ad86
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 b9 2a 00 00       	call   80105144 <initlock>
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
8010273b:	68 8b ad 10 80       	push   $0x8010ad8b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 85 2c 00 00       	call   801053dc <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 f6 29 00 00       	call   80105166 <acquire>
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
8010279d:	e8 32 2a 00 00       	call   801051d4 <release>
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
801027bf:	e8 a2 29 00 00       	call   80105166 <acquire>
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
801027f0:	e8 df 29 00 00       	call   801051d4 <release>
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
80102d14:	e8 2a 27 00 00       	call   80105443 <memcmp>
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
80102e28:	68 91 ad 10 80       	push   $0x8010ad91
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 0d 23 00 00       	call   80105144 <initlock>
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
80102edd:	e8 b9 25 00 00       	call   8010549b <memmove>
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
8010304c:	e8 15 21 00 00       	call   80105166 <acquire>
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
8010306a:	e8 1e 14 00 00       	call   8010448d <sleep>
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
8010309f:	e8 e9 13 00 00       	call   8010448d <sleep>
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
801030be:	e8 11 21 00 00       	call   801051d4 <release>
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
801030df:	e8 82 20 00 00       	call   80105166 <acquire>
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
80103100:	68 95 ad 10 80       	push   $0x8010ad95
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
8010312e:	e8 41 14 00 00       	call   80104574 <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 91 20 00 00       	call   801051d4 <release>
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
80103159:	e8 08 20 00 00       	call   80105166 <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 fc 13 00 00       	call   80104574 <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 4c 20 00 00       	call   801051d4 <release>
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
801031ff:	e8 97 22 00 00       	call   8010549b <memmove>
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
8010329c:	68 a4 ad 10 80       	push   $0x8010ada4
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 ba ad 10 80       	push   $0x8010adba
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 9d 1e 00 00       	call   80105166 <acquire>
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
80103342:	e8 8d 1e 00 00       	call   801051d4 <release>
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
80103378:	e8 b5 55 00 00       	call   80108932 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 b9 4b 00 00       	call   80107f50 <kvmalloc>
  mpinit_uefi();
80103397:	e8 60 53 00 00       	call   801086fc <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 41 46 00 00       	call   801079e7 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 c6 39 00 00       	call   80106d80 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 85 34 00 00       	call   80106849 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 8a 76 00 00       	call   8010aa5d <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 9b 57 00 00       	call   80108b8d <pci_init>
  arp_scan();
801033f2:	e8 d0 64 00 00       	call   801098c7 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 e3 07 00 00       	call   80103bdf <userinit>

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
80103407:	e8 5c 4b 00 00       	call   80107f68 <switchkvm>
  seginit();
8010340c:	e8 d6 45 00 00       	call   801079e7 <seginit>
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
80103433:	68 d5 ad 10 80       	push   $0x8010add5
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 7a 35 00 00       	call   801069bf <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 a4 0d 00 00       	call   80104206 <scheduler>

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
80103478:	68 38 f5 10 80       	push   $0x8010f538
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 16 20 00 00       	call   8010549b <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 c0 79 19 80 	movl   $0x801979c0,-0xc(%ebp)
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
80103503:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
8010350a:	a1 74 7a 19 80       	mov    0x80197a74,%eax
8010350f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103515:	05 c0 79 19 80       	add    $0x801979c0,%eax
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
80103607:	68 e9 ad 10 80       	push   $0x8010ade9
8010360c:	50                   	push   %eax
8010360d:	e8 32 1b 00 00       	call   80105144 <initlock>
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
801036cc:	e8 95 1a 00 00       	call   80105166 <acquire>
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
801036f3:	e8 7c 0e 00 00       	call   80104574 <wakeup>
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
80103716:	e8 59 0e 00 00       	call   80104574 <wakeup>
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
8010373f:	e8 90 1a 00 00       	call   801051d4 <release>
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
8010375e:	e8 71 1a 00 00       	call   801051d4 <release>
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
80103778:	e8 e9 19 00 00       	call   80105166 <acquire>
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
801037ac:	e8 23 1a 00 00       	call   801051d4 <release>
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
801037ca:	e8 a5 0d 00 00       	call   80104574 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 a5 0c 00 00       	call   8010448d <sleep>
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
8010384d:	e8 22 0d 00 00       	call   80104574 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 73 19 00 00       	call   801051d4 <release>
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
80103879:	e8 e8 18 00 00       	call   80105166 <acquire>
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
80103896:	e8 39 19 00 00       	call   801051d4 <release>
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
801038b9:	e8 cf 0b 00 00       	call   8010448d <sleep>
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
8010394c:	e8 23 0c 00 00       	call   80104574 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 74 18 00 00       	call   801051d4 <release>
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
void run_mlfq(void);
void enqueue(struct proc *p, int level);  

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 f0 ad 10 80       	push   $0x8010adf0
8010398d:	68 00 4e 19 80       	push   $0x80194e00
80103992:	e8 ad 17 00 00       	call   80105144 <initlock>
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
801039a8:	2d c0 79 19 80       	sub    $0x801979c0,%eax
801039ad:	c1 f8 02             	sar    $0x2,%eax
801039b0:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
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
801039cf:	68 f8 ad 10 80       	push   $0x8010adf8
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
801039ed:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039f3:	05 c0 79 19 80       	add    $0x801979c0,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0c:	05 c0 79 19 80       	add    $0x801979c0,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 74 7a 19 80       	mov    0x80197a74,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 1e ae 10 80       	push   $0x8010ae1e
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
80103a36:	e8 96 18 00 00       	call   801052d1 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 ca 18 00 00       	call   8010531e <popcli>
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
80103a62:	68 00 4e 19 80       	push   $0x80194e00
80103a67:	e8 fa 16 00 00       	call   80105166 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a86:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 4e 19 80       	push   $0x80194e00
80103a97:	e8 38 17 00 00       	call   801051d4 <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 34 01 00 00       	jmp    80103bdd <allocproc+0x184>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

    
  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
80103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acb:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80103ad0:	c1 f8 02             	sar    $0x2,%eax
80103ad3:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  kernel_pstat.inuse[i] = 1;
80103adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103adf:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80103ae6:	01 00 00 00 
  kernel_pstat.pid[i] = p->pid;
80103aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aed:	8b 40 10             	mov    0x10(%eax),%eax
80103af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103af3:	83 c2 40             	add    $0x40,%edx
80103af6:	89 04 95 00 42 19 80 	mov    %eax,-0x7fe6be00(,%edx,4)
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
80103afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b00:	83 e8 80             	sub    $0xffffff80,%eax
80103b03:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103b0a:	03 00 00 00 
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
80103b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b11:	83 c0 40             	add    $0x40,%eax
80103b14:	c1 e0 04             	shl    $0x4,%eax
80103b17:	05 00 42 19 80       	add    $0x80194200,%eax
80103b1c:	83 ec 04             	sub    $0x4,%esp
80103b1f:	6a 10                	push   $0x10
80103b21:	6a 00                	push   $0x0
80103b23:	50                   	push   %eax
80103b24:	e8 b3 18 00 00       	call   801053dc <memset>
80103b29:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));
80103b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2f:	83 e8 80             	sub    $0xffffff80,%eax
80103b32:	c1 e0 04             	shl    $0x4,%eax
80103b35:	05 00 42 19 80       	add    $0x80194200,%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 10                	push   $0x10
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 95 18 00 00       	call   801053dc <memset>
80103b47:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 00 4e 19 80       	push   $0x80194e00
80103b52:	e8 7d 16 00 00       	call   801051d4 <release>
80103b57:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b5a:	e8 49 ec ff ff       	call   801027a8 <kalloc>
80103b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b62:	89 42 08             	mov    %eax,0x8(%edx)
80103b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b68:	8b 40 08             	mov    0x8(%eax),%eax
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	75 11                	jne    80103b80 <allocproc+0x127>
    p->state = UNUSED;
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b79:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7e:	eb 5d                	jmp    80103bdd <allocproc+0x184>
  }
  sp = p->kstack + KSTACKSIZE;
80103b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b83:	8b 40 08             	mov    0x8(%eax),%eax
80103b86:	05 00 10 00 00       	add    $0x1000,%eax
80103b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b8e:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b98:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b9b:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103b9f:	ba 03 68 10 80       	mov    $0x80106803,%edx
80103ba4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ba7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103ba9:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bb3:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb9:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bbc:	83 ec 04             	sub    $0x4,%esp
80103bbf:	6a 14                	push   $0x14
80103bc1:	6a 00                	push   $0x0
80103bc3:	50                   	push   %eax
80103bc4:	e8 13 18 00 00       	call   801053dc <memset>
80103bc9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bd2:	ba 47 44 10 80       	mov    $0x80104447,%edx
80103bd7:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bdd:	c9                   	leave
80103bde:	c3                   	ret

80103bdf <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103bdf:	55                   	push   %ebp
80103be0:	89 e5                	mov    %esp,%ebp
80103be2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103be5:	e8 6f fe ff ff       	call   80103a59 <allocproc>
80103bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf0:	a3 60 71 19 80       	mov    %eax,0x80197160
  if((p->pgdir = setupkvm()) == 0){
80103bf5:	e8 69 42 00 00       	call   80107e63 <setupkvm>
80103bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfd:	89 42 04             	mov    %eax,0x4(%edx)
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 40 04             	mov    0x4(%eax),%eax
80103c06:	85 c0                	test   %eax,%eax
80103c08:	75 0d                	jne    80103c17 <userinit+0x38>
    panic("userinit: out of memory?");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 2e ae 10 80       	push   $0x8010ae2e
80103c12:	e8 92 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c17:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	8b 40 04             	mov    0x4(%eax),%eax
80103c22:	83 ec 04             	sub    $0x4,%esp
80103c25:	52                   	push   %edx
80103c26:	68 0c f5 10 80       	push   $0x8010f50c
80103c2b:	50                   	push   %eax
80103c2c:	e8 ef 44 00 00       	call   80108120 <inituvm>
80103c31:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c37:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c40:	8b 40 18             	mov    0x18(%eax),%eax
80103c43:	83 ec 04             	sub    $0x4,%esp
80103c46:	6a 4c                	push   $0x4c
80103c48:	6a 00                	push   $0x0
80103c4a:	50                   	push   %eax
80103c4b:	e8 8c 17 00 00       	call   801053dc <memset>
80103c50:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c56:	8b 40 18             	mov    0x18(%eax),%eax
80103c59:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	8b 40 18             	mov    0x18(%eax),%eax
80103c65:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 50 18             	mov    0x18(%eax),%edx
80103c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c74:	8b 40 18             	mov    0x18(%eax),%eax
80103c77:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c7b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8b 50 18             	mov    0x18(%eax),%edx
80103c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c88:	8b 40 18             	mov    0x18(%eax),%eax
80103c8b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c8f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	8b 40 18             	mov    0x18(%eax),%eax
80103c99:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca3:	8b 40 18             	mov    0x18(%eax),%eax
80103ca6:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb0:	8b 40 18             	mov    0x18(%eax),%eax
80103cb3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbd:	83 c0 6c             	add    $0x6c,%eax
80103cc0:	83 ec 04             	sub    $0x4,%esp
80103cc3:	6a 10                	push   $0x10
80103cc5:	68 47 ae 10 80       	push   $0x8010ae47
80103cca:	50                   	push   %eax
80103ccb:	e8 0f 19 00 00       	call   801055df <safestrcpy>
80103cd0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cd3:	83 ec 0c             	sub    $0xc,%esp
80103cd6:	68 50 ae 10 80       	push   $0x8010ae50
80103cdb:	e8 45 e8 ff ff       	call   80102525 <namei>
80103ce0:	83 c4 10             	add    $0x10,%esp
80103ce3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce6:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103ce9:	83 ec 0c             	sub    $0xc,%esp
80103cec:	68 00 4e 19 80       	push   $0x80194e00
80103cf1:	e8 70 14 00 00       	call   80105166 <acquire>
80103cf6:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  if (mycpu()->sched_policy > 0)
80103d03:	e8 b0 fc ff ff       	call   801039b8 <mycpu>
80103d08:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103d0e:	85 c0                	test   %eax,%eax
80103d10:	7e 10                	jle    80103d22 <userinit+0x143>
  enqueue(p, 3);
80103d12:	83 ec 08             	sub    $0x8,%esp
80103d15:	6a 03                	push   $0x3
80103d17:	ff 75 f4             	push   -0xc(%ebp)
80103d1a:	e8 44 0c 00 00       	call   80104963 <enqueue>
80103d1f:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103d22:	83 ec 0c             	sub    $0xc,%esp
80103d25:	68 00 4e 19 80       	push   $0x80194e00
80103d2a:	e8 a5 14 00 00       	call   801051d4 <release>
80103d2f:	83 c4 10             	add    $0x10,%esp
}
80103d32:	90                   	nop
80103d33:	c9                   	leave
80103d34:	c3                   	ret

80103d35 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d35:	55                   	push   %ebp
80103d36:	89 e5                	mov    %esp,%ebp
80103d38:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d3b:	e8 f0 fc ff ff       	call   80103a30 <myproc>
80103d40:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d46:	8b 00                	mov    (%eax),%eax
80103d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d4f:	7e 2e                	jle    80103d7f <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d51:	8b 55 08             	mov    0x8(%ebp),%edx
80103d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d57:	01 c2                	add    %eax,%edx
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	8b 40 04             	mov    0x4(%eax),%eax
80103d5f:	83 ec 04             	sub    $0x4,%esp
80103d62:	52                   	push   %edx
80103d63:	ff 75 f4             	push   -0xc(%ebp)
80103d66:	50                   	push   %eax
80103d67:	e8 f1 44 00 00       	call   8010825d <allocuvm>
80103d6c:	83 c4 10             	add    $0x10,%esp
80103d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d76:	75 3b                	jne    80103db3 <growproc+0x7e>
      return -1;
80103d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d7d:	eb 4f                	jmp    80103dce <growproc+0x99>
  } else if(n < 0){
80103d7f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d83:	79 2e                	jns    80103db3 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d85:	8b 55 08             	mov    0x8(%ebp),%edx
80103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8b:	01 c2                	add    %eax,%edx
80103d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d90:	8b 40 04             	mov    0x4(%eax),%eax
80103d93:	83 ec 04             	sub    $0x4,%esp
80103d96:	52                   	push   %edx
80103d97:	ff 75 f4             	push   -0xc(%ebp)
80103d9a:	50                   	push   %eax
80103d9b:	e8 c2 45 00 00       	call   80108362 <deallocuvm>
80103da0:	83 c4 10             	add    $0x10,%esp
80103da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103da6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103daa:	75 07                	jne    80103db3 <growproc+0x7e>
      return -1;
80103dac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db1:	eb 1b                	jmp    80103dce <growproc+0x99>
  }
  curproc->sz = sz;
80103db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103db9:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103dbb:	83 ec 0c             	sub    $0xc,%esp
80103dbe:	ff 75 f0             	push   -0x10(%ebp)
80103dc1:	e8 bb 41 00 00       	call   80107f81 <switchuvm>
80103dc6:	83 c4 10             	add    $0x10,%esp
  return 0;
80103dc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dce:	c9                   	leave
80103dcf:	c3                   	ret

80103dd0 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
80103dd3:	57                   	push   %edi
80103dd4:	56                   	push   %esi
80103dd5:	53                   	push   %ebx
80103dd6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103dd9:	e8 52 fc ff ff       	call   80103a30 <myproc>
80103dde:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103de1:	e8 73 fc ff ff       	call   80103a59 <allocproc>
80103de6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103de9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103ded:	75 0a                	jne    80103df9 <fork+0x29>
    return -1;
80103def:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103df4:	e9 a3 01 00 00       	jmp    80103f9c <fork+0x1cc>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfc:	8b 10                	mov    (%eax),%edx
80103dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e01:	8b 40 04             	mov    0x4(%eax),%eax
80103e04:	83 ec 08             	sub    $0x8,%esp
80103e07:	52                   	push   %edx
80103e08:	50                   	push   %eax
80103e09:	e8 f2 46 00 00       	call   80108500 <copyuvm>
80103e0e:	83 c4 10             	add    $0x10,%esp
80103e11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e14:	89 42 04             	mov    %eax,0x4(%edx)
80103e17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e1a:	8b 40 04             	mov    0x4(%eax),%eax
80103e1d:	85 c0                	test   %eax,%eax
80103e1f:	75 30                	jne    80103e51 <fork+0x81>
    kfree(np->kstack);
80103e21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e24:	8b 40 08             	mov    0x8(%eax),%eax
80103e27:	83 ec 0c             	sub    $0xc,%esp
80103e2a:	50                   	push   %eax
80103e2b:	e8 de e8 ff ff       	call   8010270e <kfree>
80103e30:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e40:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e4c:	e9 4b 01 00 00       	jmp    80103f9c <fork+0x1cc>
  }
  np->sz = curproc->sz;
80103e51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e54:	8b 10                	mov    (%eax),%edx
80103e56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e59:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e61:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e67:	8b 48 18             	mov    0x18(%eax),%ecx
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 18             	mov    0x18(%eax),%eax
80103e70:	89 c2                	mov    %eax,%edx
80103e72:	89 cb                	mov    %ecx,%ebx
80103e74:	b8 13 00 00 00       	mov    $0x13,%eax
80103e79:	89 d7                	mov    %edx,%edi
80103e7b:	89 de                	mov    %ebx,%esi
80103e7d:	89 c1                	mov    %eax,%ecx
80103e7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e84:	8b 40 18             	mov    0x18(%eax),%eax
80103e87:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e8e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e95:	eb 3b                	jmp    80103ed2 <fork+0x102>
    if(curproc->ofile[i])
80103e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e9d:	83 c2 08             	add    $0x8,%edx
80103ea0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ea4:	85 c0                	test   %eax,%eax
80103ea6:	74 26                	je     80103ece <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eae:	83 c2 08             	add    $0x8,%edx
80103eb1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eb5:	83 ec 0c             	sub    $0xc,%esp
80103eb8:	50                   	push   %eax
80103eb9:	e8 96 d1 ff ff       	call   80101054 <filedup>
80103ebe:	83 c4 10             	add    $0x10,%esp
80103ec1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ec4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103ec7:	83 c1 08             	add    $0x8,%ecx
80103eca:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103ece:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103ed2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ed6:	7e bf                	jle    80103e97 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103edb:	8b 40 68             	mov    0x68(%eax),%eax
80103ede:	83 ec 0c             	sub    $0xc,%esp
80103ee1:	50                   	push   %eax
80103ee2:	e8 d1 da ff ff       	call   801019b8 <idup>
80103ee7:	83 c4 10             	add    $0x10,%esp
80103eea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103eed:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef3:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ef6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ef9:	83 c0 6c             	add    $0x6c,%eax
80103efc:	83 ec 04             	sub    $0x4,%esp
80103eff:	6a 10                	push   $0x10
80103f01:	52                   	push   %edx
80103f02:	50                   	push   %eax
80103f03:	e8 d7 16 00 00       	call   801055df <safestrcpy>
80103f08:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0e:	8b 40 10             	mov    0x10(%eax),%eax
80103f11:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f14:	83 ec 0c             	sub    $0xc,%esp
80103f17:	68 00 4e 19 80       	push   $0x80194e00
80103f1c:	e8 45 12 00 00       	call   80105166 <acquire>
80103f21:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f24:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f27:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  cprintf("[FORK] pid %d created, sched_policy = %d\n", np->pid, mycpu()->sched_policy);
80103f2e:	e8 85 fa ff ff       	call   801039b8 <mycpu>
80103f33:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
80103f39:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f3c:	8b 40 10             	mov    0x10(%eax),%eax
80103f3f:	83 ec 04             	sub    $0x4,%esp
80103f42:	52                   	push   %edx
80103f43:	50                   	push   %eax
80103f44:	68 54 ae 10 80       	push   $0x8010ae54
80103f49:	e8 a6 c4 ff ff       	call   801003f4 <cprintf>
80103f4e:	83 c4 10             	add    $0x10,%esp
  if (cpus[0].sched_policy > 0){
80103f51:	a1 70 7a 19 80       	mov    0x80197a70,%eax
80103f56:	85 c0                	test   %eax,%eax
80103f58:	7e 2f                	jle    80103f89 <fork+0x1b9>
    kernel_pstat.priority[np - ptable.proc] = 3;
80103f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5d:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80103f62:	c1 f8 02             	sar    $0x2,%eax
80103f65:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103f6b:	83 e8 80             	sub    $0xffffff80,%eax
80103f6e:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103f75:	03 00 00 00 
    enqueue(np, 3);
80103f79:	83 ec 08             	sub    $0x8,%esp
80103f7c:	6a 03                	push   $0x3
80103f7e:	ff 75 dc             	push   -0x24(%ebp)
80103f81:	e8 dd 09 00 00       	call   80104963 <enqueue>
80103f86:	83 c4 10             	add    $0x10,%esp
  }
   

  release(&ptable.lock);
80103f89:	83 ec 0c             	sub    $0xc,%esp
80103f8c:	68 00 4e 19 80       	push   $0x80194e00
80103f91:	e8 3e 12 00 00       	call   801051d4 <release>
80103f96:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f99:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f9f:	5b                   	pop    %ebx
80103fa0:	5e                   	pop    %esi
80103fa1:	5f                   	pop    %edi
80103fa2:	5d                   	pop    %ebp
80103fa3:	c3                   	ret

80103fa4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103fa4:	55                   	push   %ebp
80103fa5:	89 e5                	mov    %esp,%ebp
80103fa7:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103faa:	e8 81 fa ff ff       	call   80103a30 <myproc>
80103faf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103fb2:	a1 60 71 19 80       	mov    0x80197160,%eax
80103fb7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fba:	75 0d                	jne    80103fc9 <exit+0x25>
    panic("init exiting");
80103fbc:	83 ec 0c             	sub    $0xc,%esp
80103fbf:	68 7e ae 10 80       	push   $0x8010ae7e
80103fc4:	e8 e0 c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103fc9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fd0:	eb 3f                	jmp    80104011 <exit+0x6d>
    if(curproc->ofile[fd]){
80103fd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fd8:	83 c2 08             	add    $0x8,%edx
80103fdb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fdf:	85 c0                	test   %eax,%eax
80103fe1:	74 2a                	je     8010400d <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fe9:	83 c2 08             	add    $0x8,%edx
80103fec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ff0:	83 ec 0c             	sub    $0xc,%esp
80103ff3:	50                   	push   %eax
80103ff4:	e8 ac d0 ff ff       	call   801010a5 <fileclose>
80103ff9:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104002:	83 c2 08             	add    $0x8,%edx
80104005:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010400c:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010400d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104011:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104015:	7e bb                	jle    80103fd2 <exit+0x2e>
    }
  }

  begin_op();
80104017:	e8 22 f0 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
8010401c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010401f:	8b 40 68             	mov    0x68(%eax),%eax
80104022:	83 ec 0c             	sub    $0xc,%esp
80104025:	50                   	push   %eax
80104026:	e8 28 db ff ff       	call   80101b53 <iput>
8010402b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010402e:	e8 97 f0 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80104033:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104036:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	68 00 4e 19 80       	push   $0x80194e00
80104045:	e8 1c 11 00 00       	call   80105166 <acquire>
8010404a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010404d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104050:	8b 40 14             	mov    0x14(%eax),%eax
80104053:	83 ec 0c             	sub    $0xc,%esp
80104056:	50                   	push   %eax
80104057:	e8 d8 04 00 00       	call   80104534 <wakeup1>
8010405c:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010405f:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80104066:	eb 37                	jmp    8010409f <exit+0xfb>
    if(p->parent == curproc){
80104068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406b:	8b 40 14             	mov    0x14(%eax),%eax
8010406e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104071:	75 28                	jne    8010409b <exit+0xf7>
      p->parent = initproc;
80104073:	8b 15 60 71 19 80    	mov    0x80197160,%edx
80104079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010407f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104082:	8b 40 0c             	mov    0xc(%eax),%eax
80104085:	83 f8 05             	cmp    $0x5,%eax
80104088:	75 11                	jne    8010409b <exit+0xf7>
        wakeup1(initproc);
8010408a:	a1 60 71 19 80       	mov    0x80197160,%eax
8010408f:	83 ec 0c             	sub    $0xc,%esp
80104092:	50                   	push   %eax
80104093:	e8 9c 04 00 00       	call   80104534 <wakeup1>
80104098:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010409b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010409f:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
801040a6:	72 c0                	jb     80104068 <exit+0xc4>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
801040a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ab:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801040b0:	c1 f8 02             	sar    $0x2,%eax
801040b3:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801040b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
801040bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040bf:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
801040c6:	00 00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040cd:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801040d4:	e8 7b 02 00 00       	call   80104354 <sched>
  panic("zombie exit");
801040d9:	83 ec 0c             	sub    $0xc,%esp
801040dc:	68 8b ae 10 80       	push   $0x8010ae8b
801040e1:	e8 c3 c4 ff ff       	call   801005a9 <panic>

801040e6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801040e6:	55                   	push   %ebp
801040e7:	89 e5                	mov    %esp,%ebp
801040e9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040ec:	e8 3f f9 ff ff       	call   80103a30 <myproc>
801040f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801040f4:	83 ec 0c             	sub    $0xc,%esp
801040f7:	68 00 4e 19 80       	push   $0x80194e00
801040fc:	e8 65 10 00 00       	call   80105166 <acquire>
80104101:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104104:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010410b:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80104112:	e9 a1 00 00 00       	jmp    801041b8 <wait+0xd2>
      if(p->parent != curproc)
80104117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411a:	8b 40 14             	mov    0x14(%eax),%eax
8010411d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104120:	0f 85 8d 00 00 00    	jne    801041b3 <wait+0xcd>
        continue;
      havekids = 1;
80104126:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010412d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104130:	8b 40 0c             	mov    0xc(%eax),%eax
80104133:	83 f8 05             	cmp    $0x5,%eax
80104136:	75 7c                	jne    801041b4 <wait+0xce>
        // Found one.
        pid = p->pid;
80104138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413b:	8b 40 10             	mov    0x10(%eax),%eax
8010413e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104144:	8b 40 08             	mov    0x8(%eax),%eax
80104147:	83 ec 0c             	sub    $0xc,%esp
8010414a:	50                   	push   %eax
8010414b:	e8 be e5 ff ff       	call   8010270e <kfree>
80104150:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104156:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010415d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104160:	8b 40 04             	mov    0x4(%eax),%eax
80104163:	83 ec 0c             	sub    $0xc,%esp
80104166:	50                   	push   %eax
80104167:	e8 ba 42 00 00       	call   80108426 <freevm>
8010416c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104172:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104186:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010418a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104197:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010419e:	83 ec 0c             	sub    $0xc,%esp
801041a1:	68 00 4e 19 80       	push   $0x80194e00
801041a6:	e8 29 10 00 00       	call   801051d4 <release>
801041ab:	83 c4 10             	add    $0x10,%esp
        return pid;
801041ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041b1:	eb 51                	jmp    80104204 <wait+0x11e>
        continue;
801041b3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041b4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801041b8:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
801041bf:	0f 82 52 ff ff ff    	jb     80104117 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801041c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041c9:	74 0a                	je     801041d5 <wait+0xef>
801041cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041ce:	8b 40 24             	mov    0x24(%eax),%eax
801041d1:	85 c0                	test   %eax,%eax
801041d3:	74 17                	je     801041ec <wait+0x106>
      release(&ptable.lock);
801041d5:	83 ec 0c             	sub    $0xc,%esp
801041d8:	68 00 4e 19 80       	push   $0x80194e00
801041dd:	e8 f2 0f 00 00       	call   801051d4 <release>
801041e2:	83 c4 10             	add    $0x10,%esp
      return -1;
801041e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ea:	eb 18                	jmp    80104204 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801041ec:	83 ec 08             	sub    $0x8,%esp
801041ef:	68 00 4e 19 80       	push   $0x80194e00
801041f4:	ff 75 ec             	push   -0x14(%ebp)
801041f7:	e8 91 02 00 00       	call   8010448d <sleep>
801041fc:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041ff:	e9 00 ff ff ff       	jmp    80104104 <wait+0x1e>
  }
}
80104204:	c9                   	leave
80104205:	c3                   	ret

80104206 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104206:	55                   	push   %ebp
80104207:	89 e5                	mov    %esp,%ebp
80104209:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010420c:	e8 a7 f7 ff ff       	call   801039b8 <mycpu>
80104211:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104214:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104217:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010421e:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104221:	e8 52 f7 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104226:	83 ec 0c             	sub    $0xc,%esp
80104229:	68 00 4e 19 80       	push   $0x80194e00
8010422e:	e8 33 0f 00 00       	call   80105166 <acquire>
80104233:	83 c4 10             	add    $0x10,%esp
    

    if (mycpu()->sched_policy == 0) {
80104236:	e8 7d f7 ff ff       	call   801039b8 <mycpu>
8010423b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104241:	85 c0                	test   %eax,%eax
80104243:	0f 85 f1 00 00 00    	jne    8010433a <scheduler+0x134>
      // Round Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104249:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80104250:	eb 61                	jmp    801042b3 <scheduler+0xad>
        if(p->state != RUNNABLE)
80104252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104255:	8b 40 0c             	mov    0xc(%eax),%eax
80104258:	83 f8 03             	cmp    $0x3,%eax
8010425b:	75 51                	jne    801042ae <scheduler+0xa8>
          continue;
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        c->proc = p;
8010425d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104260:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104263:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
80104269:	83 ec 0c             	sub    $0xc,%esp
8010426c:	ff 75 f4             	push   -0xc(%ebp)
8010426f:	e8 0d 3d 00 00       	call   80107f81 <switchuvm>
80104274:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104284:	8b 40 1c             	mov    0x1c(%eax),%eax
80104287:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010428a:	83 c2 04             	add    $0x4,%edx
8010428d:	83 ec 08             	sub    $0x8,%esp
80104290:	50                   	push   %eax
80104291:	52                   	push   %edx
80104292:	e8 ba 13 00 00       	call   80105651 <swtch>
80104297:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010429a:	e8 c9 3c 00 00       	call   80107f68 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
8010429f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042a2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042a9:	00 00 00 
801042ac:	eb 01                	jmp    801042af <scheduler+0xa9>
          continue;
801042ae:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042af:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801042b3:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
801042ba:	72 96                	jb     80104252 <scheduler+0x4c>
      }
      // wait_ticks 누적
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042bc:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
801042c3:	eb 6a                	jmp    8010432f <scheduler+0x129>
        if(p->state == RUNNABLE && p != c->proc){
801042c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c8:	8b 40 0c             	mov    0xc(%eax),%eax
801042cb:	83 f8 03             	cmp    $0x3,%eax
801042ce:	75 5b                	jne    8010432b <scheduler+0x125>
801042d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042d3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042dc:	74 4d                	je     8010432b <scheduler+0x125>
          int i = p - ptable.proc;
801042de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e1:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801042e6:	c1 f8 02             	sar    $0x2,%eax
801042e9:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801042ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
          kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
801042f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042f5:	83 e8 80             	sub    $0xffffff80,%eax
801042f8:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801042ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104302:	c1 e2 02             	shl    $0x2,%edx
80104305:	01 c2                	add    %eax,%edx
80104307:	81 c2 00 02 00 00    	add    $0x200,%edx
8010430d:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
80104314:	83 c2 01             	add    $0x1,%edx
80104317:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010431a:	c1 e1 02             	shl    $0x2,%ecx
8010431d:	01 c8                	add    %ecx,%eax
8010431f:	05 00 02 00 00       	add    $0x200,%eax
80104324:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010432b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010432f:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
80104336:	72 8d                	jb     801042c5 <scheduler+0xbf>
80104338:	eb 05                	jmp    8010433f <scheduler+0x139>
        }
      }
    } else {
      // TODO: MLFQ로 넘기기
      run_mlfq();
8010433a:	e8 e4 0a 00 00       	call   80104e23 <run_mlfq>
    }  

    release(&ptable.lock);
8010433f:	83 ec 0c             	sub    $0xc,%esp
80104342:	68 00 4e 19 80       	push   $0x80194e00
80104347:	e8 88 0e 00 00       	call   801051d4 <release>
8010434c:	83 c4 10             	add    $0x10,%esp
    sti();
8010434f:	e9 cd fe ff ff       	jmp    80104221 <scheduler+0x1b>

80104354 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104354:	55                   	push   %ebp
80104355:	89 e5                	mov    %esp,%ebp
80104357:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010435a:	e8 d1 f6 ff ff       	call   80103a30 <myproc>
8010435f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104362:	83 ec 0c             	sub    $0xc,%esp
80104365:	68 00 4e 19 80       	push   $0x80194e00
8010436a:	e8 32 0f 00 00       	call   801052a1 <holding>
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	85 c0                	test   %eax,%eax
80104374:	75 0d                	jne    80104383 <sched+0x2f>
    panic("sched ptable.lock");
80104376:	83 ec 0c             	sub    $0xc,%esp
80104379:	68 97 ae 10 80       	push   $0x8010ae97
8010437e:	e8 26 c2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104383:	e8 30 f6 ff ff       	call   801039b8 <mycpu>
80104388:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010438e:	83 f8 01             	cmp    $0x1,%eax
80104391:	74 0d                	je     801043a0 <sched+0x4c>
    panic("sched locks");
80104393:	83 ec 0c             	sub    $0xc,%esp
80104396:	68 a9 ae 10 80       	push   $0x8010aea9
8010439b:	e8 09 c2 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	8b 40 0c             	mov    0xc(%eax),%eax
801043a6:	83 f8 04             	cmp    $0x4,%eax
801043a9:	75 0d                	jne    801043b8 <sched+0x64>
    panic("sched running");
801043ab:	83 ec 0c             	sub    $0xc,%esp
801043ae:	68 b5 ae 10 80       	push   $0x8010aeb5
801043b3:	e8 f1 c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801043b8:	e8 ab f5 ff ff       	call   80103968 <readeflags>
801043bd:	25 00 02 00 00       	and    $0x200,%eax
801043c2:	85 c0                	test   %eax,%eax
801043c4:	74 0d                	je     801043d3 <sched+0x7f>
    panic("sched interruptible");
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 c3 ae 10 80       	push   $0x8010aec3
801043ce:	e8 d6 c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801043d3:	e8 e0 f5 ff ff       	call   801039b8 <mycpu>
801043d8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801043e1:	e8 d2 f5 ff ff       	call   801039b8 <mycpu>
801043e6:	8b 40 04             	mov    0x4(%eax),%eax
801043e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ec:	83 c2 1c             	add    $0x1c,%edx
801043ef:	83 ec 08             	sub    $0x8,%esp
801043f2:	50                   	push   %eax
801043f3:	52                   	push   %edx
801043f4:	e8 58 12 00 00       	call   80105651 <swtch>
801043f9:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801043fc:	e8 b7 f5 ff ff       	call   801039b8 <mycpu>
80104401:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104404:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010440a:	90                   	nop
8010440b:	c9                   	leave
8010440c:	c3                   	ret

8010440d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010440d:	55                   	push   %ebp
8010440e:	89 e5                	mov    %esp,%ebp
80104410:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104413:	83 ec 0c             	sub    $0xc,%esp
80104416:	68 00 4e 19 80       	push   $0x80194e00
8010441b:	e8 46 0d 00 00       	call   80105166 <acquire>
80104420:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104423:	e8 08 f6 ff ff       	call   80103a30 <myproc>
80104428:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010442f:	e8 20 ff ff ff       	call   80104354 <sched>
  release(&ptable.lock);
80104434:	83 ec 0c             	sub    $0xc,%esp
80104437:	68 00 4e 19 80       	push   $0x80194e00
8010443c:	e8 93 0d 00 00       	call   801051d4 <release>
80104441:	83 c4 10             	add    $0x10,%esp
}
80104444:	90                   	nop
80104445:	c9                   	leave
80104446:	c3                   	ret

80104447 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104447:	55                   	push   %ebp
80104448:	89 e5                	mov    %esp,%ebp
8010444a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010444d:	83 ec 0c             	sub    $0xc,%esp
80104450:	68 00 4e 19 80       	push   $0x80194e00
80104455:	e8 7a 0d 00 00       	call   801051d4 <release>
8010445a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010445d:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104462:	85 c0                	test   %eax,%eax
80104464:	74 24                	je     8010448a <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104466:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010446d:	00 00 00 
    iinit(ROOTDEV);
80104470:	83 ec 0c             	sub    $0xc,%esp
80104473:	6a 01                	push   $0x1
80104475:	e8 07 d2 ff ff       	call   80101681 <iinit>
8010447a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010447d:	83 ec 0c             	sub    $0xc,%esp
80104480:	6a 01                	push   $0x1
80104482:	e8 98 e9 ff ff       	call   80102e1f <initlog>
80104487:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010448a:	90                   	nop
8010448b:	c9                   	leave
8010448c:	c3                   	ret

8010448d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010448d:	55                   	push   %ebp
8010448e:	89 e5                	mov    %esp,%ebp
80104490:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104493:	e8 98 f5 ff ff       	call   80103a30 <myproc>
80104498:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010449b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010449f:	75 0d                	jne    801044ae <sleep+0x21>
    panic("sleep");
801044a1:	83 ec 0c             	sub    $0xc,%esp
801044a4:	68 d7 ae 10 80       	push   $0x8010aed7
801044a9:	e8 fb c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801044ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b2:	75 0d                	jne    801044c1 <sleep+0x34>
    panic("sleep without lk");
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	68 dd ae 10 80       	push   $0x8010aedd
801044bc:	e8 e8 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044c1:	81 7d 0c 00 4e 19 80 	cmpl   $0x80194e00,0xc(%ebp)
801044c8:	74 1e                	je     801044e8 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044ca:	83 ec 0c             	sub    $0xc,%esp
801044cd:	68 00 4e 19 80       	push   $0x80194e00
801044d2:	e8 8f 0c 00 00       	call   80105166 <acquire>
801044d7:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044da:	83 ec 0c             	sub    $0xc,%esp
801044dd:	ff 75 0c             	push   0xc(%ebp)
801044e0:	e8 ef 0c 00 00       	call   801051d4 <release>
801044e5:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044eb:	8b 55 08             	mov    0x8(%ebp),%edx
801044ee:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044fb:	e8 54 fe ff ff       	call   80104354 <sched>

  // Tidy up.
  p->chan = 0;
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010450a:	81 7d 0c 00 4e 19 80 	cmpl   $0x80194e00,0xc(%ebp)
80104511:	74 1e                	je     80104531 <sleep+0xa4>
    release(&ptable.lock);
80104513:	83 ec 0c             	sub    $0xc,%esp
80104516:	68 00 4e 19 80       	push   $0x80194e00
8010451b:	e8 b4 0c 00 00       	call   801051d4 <release>
80104520:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	ff 75 0c             	push   0xc(%ebp)
80104529:	e8 38 0c 00 00       	call   80105166 <acquire>
8010452e:	83 c4 10             	add    $0x10,%esp
  }
}
80104531:	90                   	nop
80104532:	c9                   	leave
80104533:	c3                   	ret

80104534 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104534:	55                   	push   %ebp
80104535:	89 e5                	mov    %esp,%ebp
80104537:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010453a:	c7 45 fc 34 4e 19 80 	movl   $0x80194e34,-0x4(%ebp)
80104541:	eb 24                	jmp    80104567 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104543:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104546:	8b 40 0c             	mov    0xc(%eax),%eax
80104549:	83 f8 02             	cmp    $0x2,%eax
8010454c:	75 15                	jne    80104563 <wakeup1+0x2f>
8010454e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104551:	8b 40 20             	mov    0x20(%eax),%eax
80104554:	39 45 08             	cmp    %eax,0x8(%ebp)
80104557:	75 0a                	jne    80104563 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104559:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010455c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104563:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104567:	81 7d fc 34 6d 19 80 	cmpl   $0x80196d34,-0x4(%ebp)
8010456e:	72 d3                	jb     80104543 <wakeup1+0xf>
}
80104570:	90                   	nop
80104571:	90                   	nop
80104572:	c9                   	leave
80104573:	c3                   	ret

80104574 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104574:	55                   	push   %ebp
80104575:	89 e5                	mov    %esp,%ebp
80104577:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010457a:	83 ec 0c             	sub    $0xc,%esp
8010457d:	68 00 4e 19 80       	push   $0x80194e00
80104582:	e8 df 0b 00 00       	call   80105166 <acquire>
80104587:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010458a:	83 ec 0c             	sub    $0xc,%esp
8010458d:	ff 75 08             	push   0x8(%ebp)
80104590:	e8 9f ff ff ff       	call   80104534 <wakeup1>
80104595:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104598:	83 ec 0c             	sub    $0xc,%esp
8010459b:	68 00 4e 19 80       	push   $0x80194e00
801045a0:	e8 2f 0c 00 00       	call   801051d4 <release>
801045a5:	83 c4 10             	add    $0x10,%esp
}
801045a8:	90                   	nop
801045a9:	c9                   	leave
801045aa:	c3                   	ret

801045ab <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045ab:	55                   	push   %ebp
801045ac:	89 e5                	mov    %esp,%ebp
801045ae:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045b1:	83 ec 0c             	sub    $0xc,%esp
801045b4:	68 00 4e 19 80       	push   $0x80194e00
801045b9:	e8 a8 0b 00 00       	call   80105166 <acquire>
801045be:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c1:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
801045c8:	eb 45                	jmp    8010460f <kill+0x64>
    if(p->pid == pid){
801045ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cd:	8b 40 10             	mov    0x10(%eax),%eax
801045d0:	39 45 08             	cmp    %eax,0x8(%ebp)
801045d3:	75 36                	jne    8010460b <kill+0x60>
      p->killed = 1;
801045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e2:	8b 40 0c             	mov    0xc(%eax),%eax
801045e5:	83 f8 02             	cmp    $0x2,%eax
801045e8:	75 0a                	jne    801045f4 <kill+0x49>
        p->state = RUNNABLE;
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	68 00 4e 19 80       	push   $0x80194e00
801045fc:	e8 d3 0b 00 00       	call   801051d4 <release>
80104601:	83 c4 10             	add    $0x10,%esp
      return 0;
80104604:	b8 00 00 00 00       	mov    $0x0,%eax
80104609:	eb 22                	jmp    8010462d <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010460b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010460f:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
80104616:	72 b2                	jb     801045ca <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104618:	83 ec 0c             	sub    $0xc,%esp
8010461b:	68 00 4e 19 80       	push   $0x80194e00
80104620:	e8 af 0b 00 00       	call   801051d4 <release>
80104625:	83 c4 10             	add    $0x10,%esp
  return -1;
80104628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010462d:	c9                   	leave
8010462e:	c3                   	ret

8010462f <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010462f:	55                   	push   %ebp
80104630:	89 e5                	mov    %esp,%ebp
80104632:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104635:	c7 45 f0 34 4e 19 80 	movl   $0x80194e34,-0x10(%ebp)
8010463c:	e9 d7 00 00 00       	jmp    80104718 <procdump+0xe9>
    if(p->state == UNUSED)
80104641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104644:	8b 40 0c             	mov    0xc(%eax),%eax
80104647:	85 c0                	test   %eax,%eax
80104649:	0f 84 c4 00 00 00    	je     80104713 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010464f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104652:	8b 40 0c             	mov    0xc(%eax),%eax
80104655:	83 f8 05             	cmp    $0x5,%eax
80104658:	77 23                	ja     8010467d <procdump+0x4e>
8010465a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010465d:	8b 40 0c             	mov    0xc(%eax),%eax
80104660:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104667:	85 c0                	test   %eax,%eax
80104669:	74 12                	je     8010467d <procdump+0x4e>
      state = states[p->state];
8010466b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466e:	8b 40 0c             	mov    0xc(%eax),%eax
80104671:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104678:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010467b:	eb 07                	jmp    80104684 <procdump+0x55>
    else
      state = "???";
8010467d:	c7 45 ec ee ae 10 80 	movl   $0x8010aeee,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104687:	8d 50 6c             	lea    0x6c(%eax),%edx
8010468a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468d:	8b 40 10             	mov    0x10(%eax),%eax
80104690:	52                   	push   %edx
80104691:	ff 75 ec             	push   -0x14(%ebp)
80104694:	50                   	push   %eax
80104695:	68 f2 ae 10 80       	push   $0x8010aef2
8010469a:	e8 55 bd ff ff       	call   801003f4 <cprintf>
8010469f:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a5:	8b 40 0c             	mov    0xc(%eax),%eax
801046a8:	83 f8 02             	cmp    $0x2,%eax
801046ab:	75 54                	jne    80104701 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801046b3:	8b 40 0c             	mov    0xc(%eax),%eax
801046b6:	83 c0 08             	add    $0x8,%eax
801046b9:	89 c2                	mov    %eax,%edx
801046bb:	83 ec 08             	sub    $0x8,%esp
801046be:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046c1:	50                   	push   %eax
801046c2:	52                   	push   %edx
801046c3:	e8 5e 0b 00 00       	call   80105226 <getcallerpcs>
801046c8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046d2:	eb 1c                	jmp    801046f0 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046db:	83 ec 08             	sub    $0x8,%esp
801046de:	50                   	push   %eax
801046df:	68 fb ae 10 80       	push   $0x8010aefb
801046e4:	e8 0b bd ff ff       	call   801003f4 <cprintf>
801046e9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046f0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801046f4:	7f 0b                	jg     80104701 <procdump+0xd2>
801046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046fd:	85 c0                	test   %eax,%eax
801046ff:	75 d3                	jne    801046d4 <procdump+0xa5>
    }
    cprintf("\n");
80104701:	83 ec 0c             	sub    $0xc,%esp
80104704:	68 ff ae 10 80       	push   $0x8010aeff
80104709:	e8 e6 bc ff ff       	call   801003f4 <cprintf>
8010470e:	83 c4 10             	add    $0x10,%esp
80104711:	eb 01                	jmp    80104714 <procdump+0xe5>
      continue;
80104713:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104714:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104718:	81 7d f0 34 6d 19 80 	cmpl   $0x80196d34,-0x10(%ebp)
8010471f:	0f 82 1c ff ff ff    	jb     80104641 <procdump+0x12>
  }
}
80104725:	90                   	nop
80104726:	90                   	nop
80104727:	c9                   	leave
80104728:	c3                   	ret

80104729 <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
8010472c:	53                   	push   %ebx
8010472d:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104730:	83 ec 0c             	sub    $0xc,%esp
80104733:	68 00 4e 19 80       	push   $0x80194e00
80104738:	e8 29 0a 00 00       	call   80105166 <acquire>
8010473d:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104747:	e9 e6 00 00 00       	jmp    80104832 <getpinfo+0x109>
    pstat->inuse[i] = kernel_pstat.inuse[i];
8010474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474f:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
80104756:	8b 45 08             	mov    0x8(%ebp),%eax
80104759:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010475c:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
8010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104762:	83 c0 40             	add    $0x40,%eax
80104765:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
8010476c:	8b 45 08             	mov    0x8(%ebp),%eax
8010476f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104772:	83 c1 40             	add    $0x40,%ecx
80104775:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
80104778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477b:	83 e8 80             	sub    $0xffffff80,%eax
8010477e:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104785:	8b 45 08             	mov    0x8(%ebp),%eax
80104788:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010478b:	83 e9 80             	sub    $0xffffff80,%ecx
8010478e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104797:	05 40 4e 19 80       	add    $0x80194e40,%eax
8010479c:	8b 00                	mov    (%eax),%eax
8010479e:	89 c1                	mov    %eax,%ecx
801047a0:	8b 45 08             	mov    0x8(%ebp),%eax
801047a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047a6:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801047ac:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801047af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047b6:	eb 70                	jmp    80104828 <getpinfo+0xff>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801047b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801047c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047c5:	01 d0                	add    %edx,%eax
801047c7:	05 00 01 00 00       	add    $0x100,%eax
801047cc:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
801047d3:	8b 45 08             	mov    0x8(%ebp),%eax
801047d6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047d9:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801047e0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047e3:	01 d9                	add    %ebx,%ecx
801047e5:	81 c1 00 01 00 00    	add    $0x100,%ecx
801047eb:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
801047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801047f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fb:	01 d0                	add    %edx,%eax
801047fd:	05 00 02 00 00       	add    $0x200,%eax
80104802:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104809:	8b 45 08             	mov    0x8(%ebp),%eax
8010480c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010480f:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104816:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104819:	01 d9                	add    %ebx,%ecx
8010481b:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104821:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104824:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104828:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
8010482c:	7e 8a                	jle    801047b8 <getpinfo+0x8f>
  for (int i = 0; i < NPROC; i++) {
8010482e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104832:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104836:	0f 8e 10 ff ff ff    	jle    8010474c <getpinfo+0x23>
    }
  }
  release(&ptable.lock);
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	68 00 4e 19 80       	push   $0x80194e00
80104844:	e8 8b 09 00 00       	call   801051d4 <release>
80104849:	83 c4 10             	add    $0x10,%esp
  return 0;
8010484c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104854:	c9                   	leave
80104855:	c3                   	ret

80104856 <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
80104856:	55                   	push   %ebp
80104857:	89 e5                	mov    %esp,%ebp
80104859:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	68 00 4e 19 80       	push   $0x80194e00
80104864:	e8 fd 08 00 00       	call   80105166 <acquire>
80104869:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
8010486c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104873:	eb 6f                	jmp    801048e4 <mlfq_enqueue_all_runnable+0x8e>
    if (!kernel_pstat.inuse[i]) continue;
80104875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104878:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010487f:	85 c0                	test   %eax,%eax
80104881:	74 5c                	je     801048df <mlfq_enqueue_all_runnable+0x89>
    struct proc *p = &ptable.proc[i];
80104883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104886:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104889:	83 c0 30             	add    $0x30,%eax
8010488c:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104891:	83 c0 04             	add    $0x4,%eax
80104894:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE) {
80104897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489a:	8b 40 0c             	mov    0xc(%eax),%eax
8010489d:	83 f8 03             	cmp    $0x3,%eax
801048a0:	75 3e                	jne    801048e0 <mlfq_enqueue_all_runnable+0x8a>
      int q = kernel_pstat.priority[i];
801048a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a5:	83 e8 80             	sub    $0xffffff80,%eax
801048a8:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801048af:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
801048b2:	83 ec 08             	sub    $0x8,%esp
801048b5:	ff 75 ec             	push   -0x14(%ebp)
801048b8:	ff 75 f0             	push   -0x10(%ebp)
801048bb:	e8 a3 00 00 00       	call   80104963 <enqueue>
801048c0:	83 c4 10             	add    $0x10,%esp
      cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
801048c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c6:	8b 40 10             	mov    0x10(%eax),%eax
801048c9:	83 ec 04             	sub    $0x4,%esp
801048cc:	ff 75 ec             	push   -0x14(%ebp)
801048cf:	50                   	push   %eax
801048d0:	68 01 af 10 80       	push   $0x8010af01
801048d5:	e8 1a bb ff ff       	call   801003f4 <cprintf>
801048da:	83 c4 10             	add    $0x10,%esp
801048dd:	eb 01                	jmp    801048e0 <mlfq_enqueue_all_runnable+0x8a>
    if (!kernel_pstat.inuse[i]) continue;
801048df:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
801048e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801048e4:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801048e8:	7e 8b                	jle    80104875 <mlfq_enqueue_all_runnable+0x1f>
    }
  }
  release(&ptable.lock);
801048ea:	83 ec 0c             	sub    $0xc,%esp
801048ed:	68 00 4e 19 80       	push   $0x80194e00
801048f2:	e8 dd 08 00 00       	call   801051d4 <release>
801048f7:	83 c4 10             	add    $0x10,%esp
}
801048fa:	90                   	nop
801048fb:	c9                   	leave
801048fc:	c3                   	ret

801048fd <set_sched_policy>:

int
set_sched_policy(int policy)
{
801048fd:	55                   	push   %ebp
801048fe:	89 e5                	mov    %esp,%ebp
80104900:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104903:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104907:	78 06                	js     8010490f <set_sched_policy+0x12>
80104909:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
8010490d:	7e 07                	jle    80104916 <set_sched_policy+0x19>
    return -1;
8010490f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104914:	eb 28                	jmp    8010493e <set_sched_policy+0x41>

  pushcli(); 
80104916:	e8 b6 09 00 00       	call   801052d1 <pushcli>
  mycpu()->sched_policy = policy;
8010491b:	e8 98 f0 ff ff       	call   801039b8 <mycpu>
80104920:	8b 55 08             	mov    0x8(%ebp),%edx
80104923:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104929:	e8 f0 09 00 00       	call   8010531e <popcli>

  if (policy > 0)
8010492e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104932:	7e 05                	jle    80104939 <set_sched_policy+0x3c>
  mlfq_enqueue_all_runnable();
80104934:	e8 1d ff ff ff       	call   80104856 <mlfq_enqueue_all_runnable>

  return 0;
80104939:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010493e:	c9                   	leave
8010493f:	c3                   	ret

80104940 <get_sched_policy>:
int
get_sched_policy(void)
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
80104946:	e8 86 09 00 00       	call   801052d1 <pushcli>
  int policy = mycpu()->sched_policy;
8010494b:	e8 68 f0 ff ff       	call   801039b8 <mycpu>
80104950:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104959:	e8 c0 09 00 00       	call   8010531e <popcli>
  return policy;
8010495e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104961:	c9                   	leave
80104962:	c3                   	ret

80104963 <enqueue>:
struct proc* mlfq_queues[4][NPROC];
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void enqueue(struct proc *p, int level) {
80104963:	55                   	push   %ebp
80104964:	89 e5                	mov    %esp,%ebp
80104966:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104969:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104970:	eb 1d                	jmp    8010498f <enqueue+0x2c>
    if (mlfq_queues[level][i] == p) {
80104972:	8b 45 0c             	mov    0xc(%ebp),%eax
80104975:	c1 e0 06             	shl    $0x6,%eax
80104978:	89 c2                	mov    %eax,%edx
8010497a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010497d:	01 d0                	add    %edx,%eax
8010497f:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104986:	39 45 08             	cmp    %eax,0x8(%ebp)
80104989:	74 50                	je     801049db <enqueue+0x78>
  for (int i = 0; i < NPROC; i++) {
8010498b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010498f:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104993:	7e dd                	jle    80104972 <enqueue+0xf>
      //cprintf("[ENQUEUE] DUP PID %d already in Q%d\n", p->pid, level);
      return;
    }
  }
  for (int i = 0; i < NPROC; i++) {
80104995:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010499c:	eb 35                	jmp    801049d3 <enqueue+0x70>
    if (mlfq_queues[level][i] == 0) {
8010499e:	8b 45 0c             	mov    0xc(%ebp),%eax
801049a1:	c1 e0 06             	shl    $0x6,%eax
801049a4:	89 c2                	mov    %eax,%edx
801049a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049a9:	01 d0                	add    %edx,%eax
801049ab:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
801049b2:	85 c0                	test   %eax,%eax
801049b4:	75 19                	jne    801049cf <enqueue+0x6c>
      mlfq_queues[level][i] = p;
801049b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b9:	c1 e0 06             	shl    $0x6,%eax
801049bc:	89 c2                	mov    %eax,%edx
801049be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049c1:	01 c2                	add    %eax,%edx
801049c3:	8b 45 08             	mov    0x8(%ebp),%eax
801049c6:	89 04 95 40 6d 19 80 	mov    %eax,-0x7fe692c0(,%edx,4)
      //cprintf("[ENQUEUE] PID %d → Q%d (inserted)\n", p->pid, level);
      return;
801049cd:	eb 0d                	jmp    801049dc <enqueue+0x79>
  for (int i = 0; i < NPROC; i++) {
801049cf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049d3:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
801049d7:	7e c5                	jle    8010499e <enqueue+0x3b>
801049d9:	eb 01                	jmp    801049dc <enqueue+0x79>
      return;
801049db:	90                   	nop
    }
  }
  //cprintf("[ENQUEUE] Failed: Q%d full\n", level);
}
801049dc:	c9                   	leave
801049dd:	c3                   	ret

801049de <dequeue>:

struct proc* dequeue(int level) {
801049de:	55                   	push   %ebp
801049df:	89 e5                	mov    %esp,%ebp
801049e1:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
801049e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  for (int i = 0; i < NPROC; i++) {
801049eb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801049f2:	e9 81 00 00 00       	jmp    80104a78 <dequeue+0x9a>
    if (mlfq_queues[level][i] != 0) {
801049f7:	8b 45 08             	mov    0x8(%ebp),%eax
801049fa:	c1 e0 06             	shl    $0x6,%eax
801049fd:	89 c2                	mov    %eax,%edx
801049ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a02:	01 d0                	add    %edx,%eax
80104a04:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104a0b:	85 c0                	test   %eax,%eax
80104a0d:	74 65                	je     80104a74 <dequeue+0x96>
      p = mlfq_queues[level][i];
80104a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a12:	c1 e0 06             	shl    $0x6,%eax
80104a15:	89 c2                	mov    %eax,%edx
80104a17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a1a:	01 d0                	add    %edx,%eax
80104a1c:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104a23:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a2c:	eb 2d                	jmp    80104a5b <dequeue+0x7d>
        mlfq_queues[level][j] = mlfq_queues[level][j + 1];
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	8d 50 01             	lea    0x1(%eax),%edx
80104a34:	8b 45 08             	mov    0x8(%ebp),%eax
80104a37:	c1 e0 06             	shl    $0x6,%eax
80104a3a:	01 d0                	add    %edx,%eax
80104a3c:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104a43:	8b 55 08             	mov    0x8(%ebp),%edx
80104a46:	89 d1                	mov    %edx,%ecx
80104a48:	c1 e1 06             	shl    $0x6,%ecx
80104a4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a4e:	01 ca                	add    %ecx,%edx
80104a50:	89 04 95 40 6d 19 80 	mov    %eax,-0x7fe692c0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104a57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a5b:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104a5f:	7e cd                	jle    80104a2e <dequeue+0x50>
      mlfq_queues[level][NPROC - 1] = 0;
80104a61:	8b 45 08             	mov    0x8(%ebp),%eax
80104a64:	c1 e0 08             	shl    $0x8,%eax
80104a67:	05 3c 6e 19 80       	add    $0x80196e3c,%eax
80104a6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      //cprintf("[DEQUEUE] PID %d from Q%d\n", p->pid, level);
      break;
80104a72:	eb 0e                	jmp    80104a82 <dequeue+0xa4>
  for (int i = 0; i < NPROC; i++) {
80104a74:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a78:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104a7c:	0f 8e 75 ff ff ff    	jle    801049f7 <dequeue+0x19>
    }
  }
  return p;
80104a82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a85:	c9                   	leave
80104a86:	c3                   	ret

80104a87 <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104a87:	55                   	push   %ebp
80104a88:	89 e5                	mov    %esp,%ebp
80104a8a:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104a8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a94:	e9 da 01 00 00       	jmp    80104c73 <apply_priority_boosting+0x1ec>
    if (!kernel_pstat.inuse[i]) continue;
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104aa3:	85 c0                	test   %eax,%eax
80104aa5:	0f 84 c3 01 00 00    	je     80104c6e <apply_priority_boosting+0x1e7>
    int q = kernel_pstat.priority[i];
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	83 e8 80             	sub    $0xffffff80,%eax
80104ab1:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104ab8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac8:	01 d0                	add    %edx,%eax
80104aca:	05 00 02 00 00       	add    $0x200,%eax
80104acf:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104ad6:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 2 && waited >= 160) {
80104ad9:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104add:	75 70                	jne    80104b4f <apply_priority_boosting+0xc8>
80104adf:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104ae6:	7e 67                	jle    80104b4f <apply_priority_boosting+0xc8>
      kernel_pstat.priority[i] = 3;
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	83 e8 80             	sub    $0xffffff80,%eax
80104aee:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80104af5:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afc:	c1 e0 04             	shl    $0x4,%eax
80104aff:	05 08 4a 19 80       	add    $0x80194a08,%eax
80104b04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	83 c0 40             	add    $0x40,%eax
80104b10:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b17:	83 ec 04             	sub    $0x4,%esp
80104b1a:	ff 75 ec             	push   -0x14(%ebp)
80104b1d:	50                   	push   %eax
80104b1e:	68 20 af 10 80       	push   $0x8010af20
80104b23:	e8 cc b8 ff ff       	call   801003f4 <cprintf>
80104b28:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104b31:	83 c0 30             	add    $0x30,%eax
80104b34:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104b39:	83 c0 04             	add    $0x4,%eax
80104b3c:	83 ec 08             	sub    $0x8,%esp
80104b3f:	6a 03                	push   $0x3
80104b41:	50                   	push   %eax
80104b42:	e8 1c fe ff ff       	call   80104963 <enqueue>
80104b47:	83 c4 10             	add    $0x10,%esp
80104b4a:	e9 20 01 00 00       	jmp    80104c6f <apply_priority_boosting+0x1e8>
    } else if (q == 1 && waited >= 320) {
80104b4f:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104b53:	75 70                	jne    80104bc5 <apply_priority_boosting+0x13e>
80104b55:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104b5c:	7e 67                	jle    80104bc5 <apply_priority_boosting+0x13e>
      kernel_pstat.priority[i] = 2;
80104b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b61:	83 e8 80             	sub    $0xffffff80,%eax
80104b64:	c7 04 85 00 42 19 80 	movl   $0x2,-0x7fe6be00(,%eax,4)
80104b6b:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b72:	c1 e0 04             	shl    $0x4,%eax
80104b75:	05 04 4a 19 80       	add    $0x80194a04,%eax
80104b7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b83:	83 c0 40             	add    $0x40,%eax
80104b86:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b8d:	83 ec 04             	sub    $0x4,%esp
80104b90:	ff 75 ec             	push   -0x14(%ebp)
80104b93:	50                   	push   %eax
80104b94:	68 44 af 10 80       	push   $0x8010af44
80104b99:	e8 56 b8 ff ff       	call   801003f4 <cprintf>
80104b9e:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104ba7:	83 c0 30             	add    $0x30,%eax
80104baa:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104baf:	83 c0 04             	add    $0x4,%eax
80104bb2:	83 ec 08             	sub    $0x8,%esp
80104bb5:	6a 02                	push   $0x2
80104bb7:	50                   	push   %eax
80104bb8:	e8 a6 fd ff ff       	call   80104963 <enqueue>
80104bbd:	83 c4 10             	add    $0x10,%esp
80104bc0:	e9 aa 00 00 00       	jmp    80104c6f <apply_priority_boosting+0x1e8>
    } else if (q == 0 && waited >= 500) {
80104bc5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bc9:	0f 85 a0 00 00 00    	jne    80104c6f <apply_priority_boosting+0x1e8>
80104bcf:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104bd6:	0f 8e 93 00 00 00    	jle    80104c6f <apply_priority_boosting+0x1e8>
      int pid = kernel_pstat.pid[i];
80104bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdf:	83 c0 40             	add    $0x40,%eax
80104be2:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104be9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	83 c0 40             	add    $0x40,%eax
80104bf2:	c1 e0 04             	shl    $0x4,%eax
80104bf5:	05 00 42 19 80       	add    $0x80194200,%eax
80104bfa:	8b 00                	mov    (%eax),%eax
80104bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c02:	83 e8 80             	sub    $0xffffff80,%eax
80104c05:	c1 e0 04             	shl    $0x4,%eax
80104c08:	05 00 42 19 80       	add    $0x80194200,%eax
80104c0d:	8b 00                	mov    (%eax),%eax
80104c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c15:	83 e8 80             	sub    $0xffffff80,%eax
80104c18:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80104c1f:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c26:	83 e8 80             	sub    $0xffffff80,%eax
80104c29:	c1 e0 04             	shl    $0x4,%eax
80104c2c:	05 00 42 19 80       	add    $0x80194200,%eax
80104c31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104c37:	ff 75 e4             	push   -0x1c(%ebp)
80104c3a:	ff 75 e0             	push   -0x20(%ebp)
80104c3d:	ff 75 e8             	push   -0x18(%ebp)
80104c40:	68 68 af 10 80       	push   $0x8010af68
80104c45:	e8 aa b7 ff ff       	call   801003f4 <cprintf>
80104c4a:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c50:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104c53:	83 c0 30             	add    $0x30,%eax
80104c56:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104c5b:	83 c0 04             	add    $0x4,%eax
80104c5e:	83 ec 08             	sub    $0x8,%esp
80104c61:	6a 01                	push   $0x1
80104c63:	50                   	push   %eax
80104c64:	e8 fa fc ff ff       	call   80104963 <enqueue>
80104c69:	83 c4 10             	add    $0x10,%esp
80104c6c:	eb 01                	jmp    80104c6f <apply_priority_boosting+0x1e8>
    if (!kernel_pstat.inuse[i]) continue;
80104c6e:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104c6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c73:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104c77:	0f 8e 1c fe ff ff    	jle    80104a99 <apply_priority_boosting+0x12>
    }
  }
}
80104c7d:	90                   	nop
80104c7e:	90                   	nop
80104c7f:	c9                   	leave
80104c80:	c3                   	ret

80104c81 <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104c81:	55                   	push   %ebp
80104c82:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104c84:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104c88:	75 07                	jne    80104c91 <get_time_slice+0x10>
80104c8a:	b8 08 00 00 00       	mov    $0x8,%eax
80104c8f:	eb 1f                	jmp    80104cb0 <get_time_slice+0x2f>
  if (level == 2) return 16;
80104c91:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104c95:	75 07                	jne    80104c9e <get_time_slice+0x1d>
80104c97:	b8 10 00 00 00       	mov    $0x10,%eax
80104c9c:	eb 12                	jmp    80104cb0 <get_time_slice+0x2f>
  if (level == 1) return 32;
80104c9e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104ca2:	75 07                	jne    80104cab <get_time_slice+0x2a>
80104ca4:	b8 20 00 00 00       	mov    $0x20,%eax
80104ca9:	eb 05                	jmp    80104cb0 <get_time_slice+0x2f>
  return -1; // FIFO (Q0)
80104cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb0:	5d                   	pop    %ebp
80104cb1:	c3                   	ret

80104cb2 <run_process>:

void run_process(struct proc* p, int q, int slice) {
80104cb2:	55                   	push   %ebp
80104cb3:	89 e5                	mov    %esp,%ebp
80104cb5:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104cb8:	e8 fb ec ff ff       	call   801039b8 <mycpu>
80104cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc3:	8b 55 08             	mov    0x8(%ebp),%edx
80104cc6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104ccc:	83 ec 0c             	sub    $0xc,%esp
80104ccf:	ff 75 08             	push   0x8(%ebp)
80104cd2:	e8 aa 32 00 00       	call   80107f81 <switchuvm>
80104cd7:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104cda:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdd:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

  int i = p - ptable.proc;
80104ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce7:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80104cec:	c1 f8 02             	sar    $0x2,%eax
80104cef:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104cf5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
80104cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfb:	8b 40 10             	mov    0x10(%eax),%eax
80104cfe:	83 ec 04             	sub    $0x4,%esp
80104d01:	ff 75 0c             	push   0xc(%ebp)
80104d04:	50                   	push   %eax
80104d05:	68 98 af 10 80       	push   $0x8010af98
80104d0a:	e8 e5 b6 ff ff       	call   801003f4 <cprintf>
80104d0f:	83 c4 10             	add    $0x10,%esp

  // 실제 프로세스를 실행 (문맥 전환)
  swtch(&(c->scheduler), p->context);
80104d12:	8b 45 08             	mov    0x8(%ebp),%eax
80104d15:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d1b:	83 c2 04             	add    $0x4,%edx
80104d1e:	83 ec 08             	sub    $0x8,%esp
80104d21:	50                   	push   %eax
80104d22:	52                   	push   %edx
80104d23:	e8 29 09 00 00       	call   80105651 <swtch>
80104d28:	83 c4 10             	add    $0x10,%esp
  // 유저 공간에서 실행이 끝나고 다시 돌아옴
  switchkvm();
80104d2b:	e8 38 32 00 00       	call   80107f68 <switchkvm>
  c->proc = 0;
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d3a:	00 00 00 

  int executed = kernel_pstat.ticks[i][q];
80104d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d4a:	01 d0                	add    %edx,%eax
80104d4c:	05 00 01 00 00       	add    $0x100,%eax
80104d51:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104d58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  //cprintf("[CHECK] PID %d total ticks at Q%d = %d (slice = %d)\n", p->pid, q, executed, slice);

  if (slice != -1 && executed >= slice && q > 0) {
80104d5b:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104d5f:	74 75                	je     80104dd6 <run_process+0x124>
80104d61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d64:	3b 45 10             	cmp    0x10(%ebp),%eax
80104d67:	7c 6d                	jl     80104dd6 <run_process+0x124>
80104d69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d6d:	7e 67                	jle    80104dd6 <run_process+0x124>
    kernel_pstat.priority[i] = q - 1;
80104d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d72:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d78:	83 e8 80             	sub    $0xffffff80,%eax
80104d7b:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;  // 현재 큐에서의 실행 시간 초기화
80104d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8f:	01 d0                	add    %edx,%eax
80104d91:	05 00 01 00 00       	add    $0x100,%eax
80104d96:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104d9d:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80104da1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104da7:	8b 45 08             	mov    0x8(%ebp),%eax
80104daa:	8b 40 10             	mov    0x10(%eax),%eax
80104dad:	52                   	push   %edx
80104dae:	ff 75 0c             	push   0xc(%ebp)
80104db1:	50                   	push   %eax
80104db2:	68 bc af 10 80       	push   $0x8010afbc
80104db7:	e8 38 b6 ff ff       	call   801003f4 <cprintf>
80104dbc:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
80104dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc2:	83 e8 01             	sub    $0x1,%eax
80104dc5:	83 ec 08             	sub    $0x8,%esp
80104dc8:	50                   	push   %eax
80104dc9:	ff 75 08             	push   0x8(%ebp)
80104dcc:	e8 92 fb ff ff       	call   80104963 <enqueue>
80104dd1:	83 c4 10             	add    $0x10,%esp
  } else {
    // 타임슬라이스 소진 안 했거나 Q0가 아닌 경우는 재삽입
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
80104dd4:	eb 4a                	jmp    80104e20 <run_process+0x16e>
  } else if (q == 0) {
80104dd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104dda:	75 19                	jne    80104df5 <run_process+0x143>
    cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
80104ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddf:	8b 40 10             	mov    0x10(%eax),%eax
80104de2:	83 ec 08             	sub    $0x8,%esp
80104de5:	50                   	push   %eax
80104de6:	68 dc af 10 80       	push   $0x8010afdc
80104deb:	e8 04 b6 ff ff       	call   801003f4 <cprintf>
80104df0:	83 c4 10             	add    $0x10,%esp
}
80104df3:	eb 2b                	jmp    80104e20 <run_process+0x16e>
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
80104df5:	8b 45 08             	mov    0x8(%ebp),%eax
80104df8:	8b 40 10             	mov    0x10(%eax),%eax
80104dfb:	83 ec 04             	sub    $0x4,%esp
80104dfe:	ff 75 0c             	push   0xc(%ebp)
80104e01:	50                   	push   %eax
80104e02:	68 18 b0 10 80       	push   $0x8010b018
80104e07:	e8 e8 b5 ff ff       	call   801003f4 <cprintf>
80104e0c:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
80104e0f:	83 ec 08             	sub    $0x8,%esp
80104e12:	ff 75 0c             	push   0xc(%ebp)
80104e15:	ff 75 08             	push   0x8(%ebp)
80104e18:	e8 46 fb ff ff       	call   80104963 <enqueue>
80104e1d:	83 c4 10             	add    $0x10,%esp
}
80104e20:	90                   	nop
80104e21:	c9                   	leave
80104e22:	c3                   	ret

80104e23 <run_mlfq>:


// MLFQ 스케줄러 진입점
void run_mlfq(void) {
80104e23:	55                   	push   %ebp
80104e24:	89 e5                	mov    %esp,%ebp
80104e26:	83 ec 28             	sub    $0x28,%esp
  int just_ran_pid = -1;
80104e29:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

  apply_priority_boosting();
80104e30:	e8 52 fc ff ff       	call   80104a87 <apply_priority_boosting>

  for (int q = 3; q >= 0; q--) {
80104e35:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
80104e3c:	eb 7e                	jmp    80104ebc <run_mlfq+0x99>
    for (int i = 0; i < NPROC; i++) {
80104e3e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104e45:	eb 6b                	jmp    80104eb2 <run_mlfq+0x8f>
      struct proc *p = mlfq_queues[q][i];
80104e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4a:	c1 e0 06             	shl    $0x6,%eax
80104e4d:	89 c2                	mov    %eax,%edx
80104e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e52:	01 d0                	add    %edx,%eax
80104e54:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104e5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (p == 0 || p->state != RUNNABLE)
80104e5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104e62:	74 49                	je     80104ead <run_mlfq+0x8a>
80104e64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e67:	8b 40 0c             	mov    0xc(%eax),%eax
80104e6a:	83 f8 03             	cmp    $0x3,%eax
80104e6d:	75 3e                	jne    80104ead <run_mlfq+0x8a>
        continue;

      dequeue(q);
80104e6f:	83 ec 0c             	sub    $0xc,%esp
80104e72:	ff 75 f0             	push   -0x10(%ebp)
80104e75:	e8 64 fb ff ff       	call   801049de <dequeue>
80104e7a:	83 c4 10             	add    $0x10,%esp
      int slice = get_time_slice(q);
80104e7d:	83 ec 0c             	sub    $0xc,%esp
80104e80:	ff 75 f0             	push   -0x10(%ebp)
80104e83:	e8 f9 fd ff ff       	call   80104c81 <get_time_slice>
80104e88:	83 c4 10             	add    $0x10,%esp
80104e8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      run_process(p, q, slice);
80104e8e:	83 ec 04             	sub    $0x4,%esp
80104e91:	ff 75 e0             	push   -0x20(%ebp)
80104e94:	ff 75 f0             	push   -0x10(%ebp)
80104e97:	ff 75 e4             	push   -0x1c(%ebp)
80104e9a:	e8 13 fe ff ff       	call   80104cb2 <run_process>
80104e9f:	83 c4 10             	add    $0x10,%esp
      just_ran_pid = p->pid;
80104ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ea5:	8b 40 10             	mov    0x10(%eax),%eax
80104ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      goto tick_update;
80104eab:	eb 1a                	jmp    80104ec7 <run_mlfq+0xa4>
        continue;
80104ead:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
80104eae:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104eb2:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80104eb6:	7e 8f                	jle    80104e47 <run_mlfq+0x24>
  for (int q = 3; q >= 0; q--) {
80104eb8:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80104ebc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ec0:	0f 89 78 ff ff ff    	jns    80104e3e <run_mlfq+0x1b>
    }
  }

  tick_update:
80104ec6:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104ec7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80104ece:	e9 06 01 00 00       	jmp    80104fd9 <run_mlfq+0x1b6>
    struct proc* p = &ptable.proc[i];
80104ed3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ed6:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104ed9:	83 c0 30             	add    $0x30,%eax
80104edc:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104ee1:	83 c0 04             	add    $0x4,%eax
80104ee4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80104ee7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104eea:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104ef1:	85 c0                	test   %eax,%eax
80104ef3:	0f 84 db 00 00 00    	je     80104fd4 <run_mlfq+0x1b1>
    if (p->state == RUNNABLE && p->pid != just_ran_pid) {
80104ef9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104efc:	8b 40 0c             	mov    0xc(%eax),%eax
80104eff:	83 f8 03             	cmp    $0x3,%eax
80104f02:	0f 85 cd 00 00 00    	jne    80104fd5 <run_mlfq+0x1b2>
80104f08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104f0b:	8b 40 10             	mov    0x10(%eax),%eax
80104f0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104f11:	0f 84 be 00 00 00    	je     80104fd5 <run_mlfq+0x1b2>
      int q = kernel_pstat.priority[i];
80104f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f1a:	83 e8 80             	sub    $0xffffff80,%eax
80104f1d:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104f24:	89 45 d8             	mov    %eax,-0x28(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
80104f27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f31:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104f34:	01 d0                	add    %edx,%eax
80104f36:	05 00 02 00 00       	add    $0x200,%eax
80104f3b:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104f42:	8d 50 01             	lea    0x1(%eax),%edx
80104f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f48:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104f4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104f52:	01 c8                	add    %ecx,%eax
80104f54:	05 00 02 00 00       	add    $0x200,%eax
80104f59:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      if (kernel_pstat.wait_ticks[i][q] % 10 == 0) {  // 확인용: 10tick마다 출력
80104f60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104f6d:	01 d0                	add    %edx,%eax
80104f6f:	05 00 02 00 00       	add    $0x200,%eax
80104f74:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
80104f7b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80104f80:	89 c8                	mov    %ecx,%eax
80104f82:	f7 ea                	imul   %edx
80104f84:	c1 fa 02             	sar    $0x2,%edx
80104f87:	89 c8                	mov    %ecx,%eax
80104f89:	c1 f8 1f             	sar    $0x1f,%eax
80104f8c:	29 c2                	sub    %eax,%edx
80104f8e:	89 d0                	mov    %edx,%eax
80104f90:	c1 e0 02             	shl    $0x2,%eax
80104f93:	01 d0                	add    %edx,%eax
80104f95:	01 c0                	add    %eax,%eax
80104f97:	29 c1                	sub    %eax,%ecx
80104f99:	89 ca                	mov    %ecx,%edx
80104f9b:	85 d2                	test   %edx,%edx
80104f9d:	75 36                	jne    80104fd5 <run_mlfq+0x1b2>
        cprintf("[WAIT] PID %d at Q%d wait_ticks = %d\n", p->pid, q, kernel_pstat.wait_ticks[i][q]);
80104f9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fa2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fa9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104fac:	01 d0                	add    %edx,%eax
80104fae:	05 00 02 00 00       	add    $0x200,%eax
80104fb3:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104fba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104fbd:	8b 40 10             	mov    0x10(%eax),%eax
80104fc0:	52                   	push   %edx
80104fc1:	ff 75 d8             	push   -0x28(%ebp)
80104fc4:	50                   	push   %eax
80104fc5:	68 3c b0 10 80       	push   $0x8010b03c
80104fca:	e8 25 b4 ff ff       	call   801003f4 <cprintf>
80104fcf:	83 c4 10             	add    $0x10,%esp
80104fd2:	eb 01                	jmp    80104fd5 <run_mlfq+0x1b2>
    if (!kernel_pstat.inuse[i]) continue;
80104fd4:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104fd5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104fd9:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104fdd:	0f 8e f0 fe ff ff    	jle    80104ed3 <run_mlfq+0xb0>
      }
    }
  }
}
80104fe3:	90                   	nop
80104fe4:	90                   	nop
80104fe5:	c9                   	leave
80104fe6:	c3                   	ret

80104fe7 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104fe7:	55                   	push   %ebp
80104fe8:	89 e5                	mov    %esp,%ebp
80104fea:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104fed:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff0:	83 c0 04             	add    $0x4,%eax
80104ff3:	83 ec 08             	sub    $0x8,%esp
80104ff6:	68 8c b0 10 80       	push   $0x8010b08c
80104ffb:	50                   	push   %eax
80104ffc:	e8 43 01 00 00       	call   80105144 <initlock>
80105001:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105004:	8b 45 08             	mov    0x8(%ebp),%eax
80105007:	8b 55 0c             	mov    0xc(%ebp),%edx
8010500a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010500d:	8b 45 08             	mov    0x8(%ebp),%eax
80105010:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105016:	8b 45 08             	mov    0x8(%ebp),%eax
80105019:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105020:	90                   	nop
80105021:	c9                   	leave
80105022:	c3                   	ret

80105023 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105023:	55                   	push   %ebp
80105024:	89 e5                	mov    %esp,%ebp
80105026:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105029:	8b 45 08             	mov    0x8(%ebp),%eax
8010502c:	83 c0 04             	add    $0x4,%eax
8010502f:	83 ec 0c             	sub    $0xc,%esp
80105032:	50                   	push   %eax
80105033:	e8 2e 01 00 00       	call   80105166 <acquire>
80105038:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010503b:	eb 15                	jmp    80105052 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
8010503d:	8b 45 08             	mov    0x8(%ebp),%eax
80105040:	83 c0 04             	add    $0x4,%eax
80105043:	83 ec 08             	sub    $0x8,%esp
80105046:	50                   	push   %eax
80105047:	ff 75 08             	push   0x8(%ebp)
8010504a:	e8 3e f4 ff ff       	call   8010448d <sleep>
8010504f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105052:	8b 45 08             	mov    0x8(%ebp),%eax
80105055:	8b 00                	mov    (%eax),%eax
80105057:	85 c0                	test   %eax,%eax
80105059:	75 e2                	jne    8010503d <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010505b:	8b 45 08             	mov    0x8(%ebp),%eax
8010505e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105064:	e8 c7 e9 ff ff       	call   80103a30 <myproc>
80105069:	8b 50 10             	mov    0x10(%eax),%edx
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105072:	8b 45 08             	mov    0x8(%ebp),%eax
80105075:	83 c0 04             	add    $0x4,%eax
80105078:	83 ec 0c             	sub    $0xc,%esp
8010507b:	50                   	push   %eax
8010507c:	e8 53 01 00 00       	call   801051d4 <release>
80105081:	83 c4 10             	add    $0x10,%esp
}
80105084:	90                   	nop
80105085:	c9                   	leave
80105086:	c3                   	ret

80105087 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105087:	55                   	push   %ebp
80105088:	89 e5                	mov    %esp,%ebp
8010508a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010508d:	8b 45 08             	mov    0x8(%ebp),%eax
80105090:	83 c0 04             	add    $0x4,%eax
80105093:	83 ec 0c             	sub    $0xc,%esp
80105096:	50                   	push   %eax
80105097:	e8 ca 00 00 00       	call   80105166 <acquire>
8010509c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010509f:	8b 45 08             	mov    0x8(%ebp),%eax
801050a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050a8:	8b 45 08             	mov    0x8(%ebp),%eax
801050ab:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801050b2:	83 ec 0c             	sub    $0xc,%esp
801050b5:	ff 75 08             	push   0x8(%ebp)
801050b8:	e8 b7 f4 ff ff       	call   80104574 <wakeup>
801050bd:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801050c0:	8b 45 08             	mov    0x8(%ebp),%eax
801050c3:	83 c0 04             	add    $0x4,%eax
801050c6:	83 ec 0c             	sub    $0xc,%esp
801050c9:	50                   	push   %eax
801050ca:	e8 05 01 00 00       	call   801051d4 <release>
801050cf:	83 c4 10             	add    $0x10,%esp
}
801050d2:	90                   	nop
801050d3:	c9                   	leave
801050d4:	c3                   	ret

801050d5 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801050d5:	55                   	push   %ebp
801050d6:	89 e5                	mov    %esp,%ebp
801050d8:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801050db:	8b 45 08             	mov    0x8(%ebp),%eax
801050de:	83 c0 04             	add    $0x4,%eax
801050e1:	83 ec 0c             	sub    $0xc,%esp
801050e4:	50                   	push   %eax
801050e5:	e8 7c 00 00 00       	call   80105166 <acquire>
801050ea:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801050ed:	8b 45 08             	mov    0x8(%ebp),%eax
801050f0:	8b 00                	mov    (%eax),%eax
801050f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801050f5:	8b 45 08             	mov    0x8(%ebp),%eax
801050f8:	83 c0 04             	add    $0x4,%eax
801050fb:	83 ec 0c             	sub    $0xc,%esp
801050fe:	50                   	push   %eax
801050ff:	e8 d0 00 00 00       	call   801051d4 <release>
80105104:	83 c4 10             	add    $0x10,%esp
  return r;
80105107:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010510a:	c9                   	leave
8010510b:	c3                   	ret

8010510c <readeflags>:
{
8010510c:	55                   	push   %ebp
8010510d:	89 e5                	mov    %esp,%ebp
8010510f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105112:	9c                   	pushf
80105113:	58                   	pop    %eax
80105114:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105117:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010511a:	c9                   	leave
8010511b:	c3                   	ret

8010511c <cli>:
{
8010511c:	55                   	push   %ebp
8010511d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010511f:	fa                   	cli
}
80105120:	90                   	nop
80105121:	5d                   	pop    %ebp
80105122:	c3                   	ret

80105123 <sti>:
{
80105123:	55                   	push   %ebp
80105124:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105126:	fb                   	sti
}
80105127:	90                   	nop
80105128:	5d                   	pop    %ebp
80105129:	c3                   	ret

8010512a <xchg>:
{
8010512a:	55                   	push   %ebp
8010512b:	89 e5                	mov    %esp,%ebp
8010512d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105130:	8b 55 08             	mov    0x8(%ebp),%edx
80105133:	8b 45 0c             	mov    0xc(%ebp),%eax
80105136:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105139:	f0 87 02             	lock xchg %eax,(%edx)
8010513c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010513f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105142:	c9                   	leave
80105143:	c3                   	ret

80105144 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105144:	55                   	push   %ebp
80105145:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105147:	8b 45 08             	mov    0x8(%ebp),%eax
8010514a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010514d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105150:	8b 45 08             	mov    0x8(%ebp),%eax
80105153:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105159:	8b 45 08             	mov    0x8(%ebp),%eax
8010515c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105163:	90                   	nop
80105164:	5d                   	pop    %ebp
80105165:	c3                   	ret

80105166 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105166:	55                   	push   %ebp
80105167:	89 e5                	mov    %esp,%ebp
80105169:	53                   	push   %ebx
8010516a:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010516d:	e8 5f 01 00 00       	call   801052d1 <pushcli>
  if(holding(lk)){
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	83 ec 0c             	sub    $0xc,%esp
80105178:	50                   	push   %eax
80105179:	e8 23 01 00 00       	call   801052a1 <holding>
8010517e:	83 c4 10             	add    $0x10,%esp
80105181:	85 c0                	test   %eax,%eax
80105183:	74 0d                	je     80105192 <acquire+0x2c>
    panic("acquire");
80105185:	83 ec 0c             	sub    $0xc,%esp
80105188:	68 97 b0 10 80       	push   $0x8010b097
8010518d:	e8 17 b4 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105192:	90                   	nop
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	83 ec 08             	sub    $0x8,%esp
80105199:	6a 01                	push   $0x1
8010519b:	50                   	push   %eax
8010519c:	e8 89 ff ff ff       	call   8010512a <xchg>
801051a1:	83 c4 10             	add    $0x10,%esp
801051a4:	85 c0                	test   %eax,%eax
801051a6:	75 eb                	jne    80105193 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801051a8:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801051ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
801051b0:	e8 03 e8 ff ff       	call   801039b8 <mycpu>
801051b5:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801051b8:	8b 45 08             	mov    0x8(%ebp),%eax
801051bb:	83 c0 0c             	add    $0xc,%eax
801051be:	83 ec 08             	sub    $0x8,%esp
801051c1:	50                   	push   %eax
801051c2:	8d 45 08             	lea    0x8(%ebp),%eax
801051c5:	50                   	push   %eax
801051c6:	e8 5b 00 00 00       	call   80105226 <getcallerpcs>
801051cb:	83 c4 10             	add    $0x10,%esp
}
801051ce:	90                   	nop
801051cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051d2:	c9                   	leave
801051d3:	c3                   	ret

801051d4 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051d4:	55                   	push   %ebp
801051d5:	89 e5                	mov    %esp,%ebp
801051d7:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801051da:	83 ec 0c             	sub    $0xc,%esp
801051dd:	ff 75 08             	push   0x8(%ebp)
801051e0:	e8 bc 00 00 00       	call   801052a1 <holding>
801051e5:	83 c4 10             	add    $0x10,%esp
801051e8:	85 c0                	test   %eax,%eax
801051ea:	75 0d                	jne    801051f9 <release+0x25>
    panic("release");
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	68 9f b0 10 80       	push   $0x8010b09f
801051f4:	e8 b0 b3 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801051f9:	8b 45 08             	mov    0x8(%ebp),%eax
801051fc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105203:	8b 45 08             	mov    0x8(%ebp),%eax
80105206:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010520d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105212:	8b 45 08             	mov    0x8(%ebp),%eax
80105215:	8b 55 08             	mov    0x8(%ebp),%edx
80105218:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010521e:	e8 fb 00 00 00       	call   8010531e <popcli>
}
80105223:	90                   	nop
80105224:	c9                   	leave
80105225:	c3                   	ret

80105226 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010522c:	8b 45 08             	mov    0x8(%ebp),%eax
8010522f:	83 e8 08             	sub    $0x8,%eax
80105232:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105235:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010523c:	eb 38                	jmp    80105276 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010523e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105242:	74 53                	je     80105297 <getcallerpcs+0x71>
80105244:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010524b:	76 4a                	jbe    80105297 <getcallerpcs+0x71>
8010524d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105251:	74 44                	je     80105297 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105253:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105256:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010525d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105260:	01 c2                	add    %eax,%edx
80105262:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105265:	8b 40 04             	mov    0x4(%eax),%eax
80105268:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010526a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010526d:	8b 00                	mov    (%eax),%eax
8010526f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105272:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105276:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010527a:	7e c2                	jle    8010523e <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010527c:	eb 19                	jmp    80105297 <getcallerpcs+0x71>
    pcs[i] = 0;
8010527e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105281:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528b:	01 d0                	add    %edx,%eax
8010528d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105293:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105297:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010529b:	7e e1                	jle    8010527e <getcallerpcs+0x58>
}
8010529d:	90                   	nop
8010529e:	90                   	nop
8010529f:	c9                   	leave
801052a0:	c3                   	ret

801052a1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
801052a4:	53                   	push   %ebx
801052a5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
801052ab:	8b 00                	mov    (%eax),%eax
801052ad:	85 c0                	test   %eax,%eax
801052af:	74 16                	je     801052c7 <holding+0x26>
801052b1:	8b 45 08             	mov    0x8(%ebp),%eax
801052b4:	8b 58 08             	mov    0x8(%eax),%ebx
801052b7:	e8 fc e6 ff ff       	call   801039b8 <mycpu>
801052bc:	39 c3                	cmp    %eax,%ebx
801052be:	75 07                	jne    801052c7 <holding+0x26>
801052c0:	b8 01 00 00 00       	mov    $0x1,%eax
801052c5:	eb 05                	jmp    801052cc <holding+0x2b>
801052c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052cf:	c9                   	leave
801052d0:	c3                   	ret

801052d1 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801052d7:	e8 30 fe ff ff       	call   8010510c <readeflags>
801052dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801052df:	e8 38 fe ff ff       	call   8010511c <cli>
  if(mycpu()->ncli == 0)
801052e4:	e8 cf e6 ff ff       	call   801039b8 <mycpu>
801052e9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052ef:	85 c0                	test   %eax,%eax
801052f1:	75 14                	jne    80105307 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801052f3:	e8 c0 e6 ff ff       	call   801039b8 <mycpu>
801052f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052fb:	81 e2 00 02 00 00    	and    $0x200,%edx
80105301:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105307:	e8 ac e6 ff ff       	call   801039b8 <mycpu>
8010530c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105312:	83 c2 01             	add    $0x1,%edx
80105315:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010531b:	90                   	nop
8010531c:	c9                   	leave
8010531d:	c3                   	ret

8010531e <popcli>:

void
popcli(void)
{
8010531e:	55                   	push   %ebp
8010531f:	89 e5                	mov    %esp,%ebp
80105321:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105324:	e8 e3 fd ff ff       	call   8010510c <readeflags>
80105329:	25 00 02 00 00       	and    $0x200,%eax
8010532e:	85 c0                	test   %eax,%eax
80105330:	74 0d                	je     8010533f <popcli+0x21>
    panic("popcli - interruptible");
80105332:	83 ec 0c             	sub    $0xc,%esp
80105335:	68 a7 b0 10 80       	push   $0x8010b0a7
8010533a:	e8 6a b2 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
8010533f:	e8 74 e6 ff ff       	call   801039b8 <mycpu>
80105344:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010534a:	83 ea 01             	sub    $0x1,%edx
8010534d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105353:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105359:	85 c0                	test   %eax,%eax
8010535b:	79 0d                	jns    8010536a <popcli+0x4c>
    panic("popcli");
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	68 be b0 10 80       	push   $0x8010b0be
80105365:	e8 3f b2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010536a:	e8 49 e6 ff ff       	call   801039b8 <mycpu>
8010536f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105375:	85 c0                	test   %eax,%eax
80105377:	75 14                	jne    8010538d <popcli+0x6f>
80105379:	e8 3a e6 ff ff       	call   801039b8 <mycpu>
8010537e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105384:	85 c0                	test   %eax,%eax
80105386:	74 05                	je     8010538d <popcli+0x6f>
    sti();
80105388:	e8 96 fd ff ff       	call   80105123 <sti>
}
8010538d:	90                   	nop
8010538e:	c9                   	leave
8010538f:	c3                   	ret

80105390 <stosb>:
{
80105390:	55                   	push   %ebp
80105391:	89 e5                	mov    %esp,%ebp
80105393:	57                   	push   %edi
80105394:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105395:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105398:	8b 55 10             	mov    0x10(%ebp),%edx
8010539b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010539e:	89 cb                	mov    %ecx,%ebx
801053a0:	89 df                	mov    %ebx,%edi
801053a2:	89 d1                	mov    %edx,%ecx
801053a4:	fc                   	cld
801053a5:	f3 aa                	rep stos %al,%es:(%edi)
801053a7:	89 ca                	mov    %ecx,%edx
801053a9:	89 fb                	mov    %edi,%ebx
801053ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053ae:	89 55 10             	mov    %edx,0x10(%ebp)
}
801053b1:	90                   	nop
801053b2:	5b                   	pop    %ebx
801053b3:	5f                   	pop    %edi
801053b4:	5d                   	pop    %ebp
801053b5:	c3                   	ret

801053b6 <stosl>:
{
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
801053b9:	57                   	push   %edi
801053ba:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053be:	8b 55 10             	mov    0x10(%ebp),%edx
801053c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c4:	89 cb                	mov    %ecx,%ebx
801053c6:	89 df                	mov    %ebx,%edi
801053c8:	89 d1                	mov    %edx,%ecx
801053ca:	fc                   	cld
801053cb:	f3 ab                	rep stos %eax,%es:(%edi)
801053cd:	89 ca                	mov    %ecx,%edx
801053cf:	89 fb                	mov    %edi,%ebx
801053d1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053d4:	89 55 10             	mov    %edx,0x10(%ebp)
}
801053d7:	90                   	nop
801053d8:	5b                   	pop    %ebx
801053d9:	5f                   	pop    %edi
801053da:	5d                   	pop    %ebp
801053db:	c3                   	ret

801053dc <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053dc:	55                   	push   %ebp
801053dd:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801053df:	8b 45 08             	mov    0x8(%ebp),%eax
801053e2:	83 e0 03             	and    $0x3,%eax
801053e5:	85 c0                	test   %eax,%eax
801053e7:	75 43                	jne    8010542c <memset+0x50>
801053e9:	8b 45 10             	mov    0x10(%ebp),%eax
801053ec:	83 e0 03             	and    $0x3,%eax
801053ef:	85 c0                	test   %eax,%eax
801053f1:	75 39                	jne    8010542c <memset+0x50>
    c &= 0xFF;
801053f3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801053fa:	8b 45 10             	mov    0x10(%ebp),%eax
801053fd:	c1 e8 02             	shr    $0x2,%eax
80105400:	89 c1                	mov    %eax,%ecx
80105402:	8b 45 0c             	mov    0xc(%ebp),%eax
80105405:	c1 e0 18             	shl    $0x18,%eax
80105408:	89 c2                	mov    %eax,%edx
8010540a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540d:	c1 e0 10             	shl    $0x10,%eax
80105410:	09 c2                	or     %eax,%edx
80105412:	8b 45 0c             	mov    0xc(%ebp),%eax
80105415:	c1 e0 08             	shl    $0x8,%eax
80105418:	09 d0                	or     %edx,%eax
8010541a:	0b 45 0c             	or     0xc(%ebp),%eax
8010541d:	51                   	push   %ecx
8010541e:	50                   	push   %eax
8010541f:	ff 75 08             	push   0x8(%ebp)
80105422:	e8 8f ff ff ff       	call   801053b6 <stosl>
80105427:	83 c4 0c             	add    $0xc,%esp
8010542a:	eb 12                	jmp    8010543e <memset+0x62>
  } else
    stosb(dst, c, n);
8010542c:	8b 45 10             	mov    0x10(%ebp),%eax
8010542f:	50                   	push   %eax
80105430:	ff 75 0c             	push   0xc(%ebp)
80105433:	ff 75 08             	push   0x8(%ebp)
80105436:	e8 55 ff ff ff       	call   80105390 <stosb>
8010543b:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010543e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105441:	c9                   	leave
80105442:	c3                   	ret

80105443 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105443:	55                   	push   %ebp
80105444:	89 e5                	mov    %esp,%ebp
80105446:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105449:	8b 45 08             	mov    0x8(%ebp),%eax
8010544c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010544f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105452:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105455:	eb 2e                	jmp    80105485 <memcmp+0x42>
    if(*s1 != *s2)
80105457:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545a:	0f b6 10             	movzbl (%eax),%edx
8010545d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105460:	0f b6 00             	movzbl (%eax),%eax
80105463:	38 c2                	cmp    %al,%dl
80105465:	74 16                	je     8010547d <memcmp+0x3a>
      return *s1 - *s2;
80105467:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010546a:	0f b6 00             	movzbl (%eax),%eax
8010546d:	0f b6 d0             	movzbl %al,%edx
80105470:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105473:	0f b6 00             	movzbl (%eax),%eax
80105476:	0f b6 c0             	movzbl %al,%eax
80105479:	29 c2                	sub    %eax,%edx
8010547b:	eb 1a                	jmp    80105497 <memcmp+0x54>
    s1++, s2++;
8010547d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105481:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105485:	8b 45 10             	mov    0x10(%ebp),%eax
80105488:	8d 50 ff             	lea    -0x1(%eax),%edx
8010548b:	89 55 10             	mov    %edx,0x10(%ebp)
8010548e:	85 c0                	test   %eax,%eax
80105490:	75 c5                	jne    80105457 <memcmp+0x14>
  }

  return 0;
80105492:	ba 00 00 00 00       	mov    $0x0,%edx
}
80105497:	89 d0                	mov    %edx,%eax
80105499:	c9                   	leave
8010549a:	c3                   	ret

8010549b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010549b:	55                   	push   %ebp
8010549c:	89 e5                	mov    %esp,%ebp
8010549e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054a7:	8b 45 08             	mov    0x8(%ebp),%eax
801054aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054b3:	73 54                	jae    80105509 <memmove+0x6e>
801054b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054b8:	8b 45 10             	mov    0x10(%ebp),%eax
801054bb:	01 d0                	add    %edx,%eax
801054bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801054c0:	73 47                	jae    80105509 <memmove+0x6e>
    s += n;
801054c2:	8b 45 10             	mov    0x10(%ebp),%eax
801054c5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054c8:	8b 45 10             	mov    0x10(%ebp),%eax
801054cb:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054ce:	eb 13                	jmp    801054e3 <memmove+0x48>
      *--d = *--s;
801054d0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801054d4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801054d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054db:	0f b6 10             	movzbl (%eax),%edx
801054de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054e1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801054e3:	8b 45 10             	mov    0x10(%ebp),%eax
801054e6:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e9:	89 55 10             	mov    %edx,0x10(%ebp)
801054ec:	85 c0                	test   %eax,%eax
801054ee:	75 e0                	jne    801054d0 <memmove+0x35>
  if(s < d && s + n > d){
801054f0:	eb 24                	jmp    80105516 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801054f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054f5:	8d 42 01             	lea    0x1(%edx),%eax
801054f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801054fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054fe:	8d 48 01             	lea    0x1(%eax),%ecx
80105501:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105504:	0f b6 12             	movzbl (%edx),%edx
80105507:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105509:	8b 45 10             	mov    0x10(%ebp),%eax
8010550c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010550f:	89 55 10             	mov    %edx,0x10(%ebp)
80105512:	85 c0                	test   %eax,%eax
80105514:	75 dc                	jne    801054f2 <memmove+0x57>

  return dst;
80105516:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105519:	c9                   	leave
8010551a:	c3                   	ret

8010551b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010551b:	55                   	push   %ebp
8010551c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010551e:	ff 75 10             	push   0x10(%ebp)
80105521:	ff 75 0c             	push   0xc(%ebp)
80105524:	ff 75 08             	push   0x8(%ebp)
80105527:	e8 6f ff ff ff       	call   8010549b <memmove>
8010552c:	83 c4 0c             	add    $0xc,%esp
}
8010552f:	c9                   	leave
80105530:	c3                   	ret

80105531 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105534:	eb 0c                	jmp    80105542 <strncmp+0x11>
    n--, p++, q++;
80105536:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010553a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010553e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105542:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105546:	74 1a                	je     80105562 <strncmp+0x31>
80105548:	8b 45 08             	mov    0x8(%ebp),%eax
8010554b:	0f b6 00             	movzbl (%eax),%eax
8010554e:	84 c0                	test   %al,%al
80105550:	74 10                	je     80105562 <strncmp+0x31>
80105552:	8b 45 08             	mov    0x8(%ebp),%eax
80105555:	0f b6 10             	movzbl (%eax),%edx
80105558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555b:	0f b6 00             	movzbl (%eax),%eax
8010555e:	38 c2                	cmp    %al,%dl
80105560:	74 d4                	je     80105536 <strncmp+0x5>
  if(n == 0)
80105562:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105566:	75 07                	jne    8010556f <strncmp+0x3e>
    return 0;
80105568:	ba 00 00 00 00       	mov    $0x0,%edx
8010556d:	eb 14                	jmp    80105583 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
8010556f:	8b 45 08             	mov    0x8(%ebp),%eax
80105572:	0f b6 00             	movzbl (%eax),%eax
80105575:	0f b6 d0             	movzbl %al,%edx
80105578:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557b:	0f b6 00             	movzbl (%eax),%eax
8010557e:	0f b6 c0             	movzbl %al,%eax
80105581:	29 c2                	sub    %eax,%edx
}
80105583:	89 d0                	mov    %edx,%eax
80105585:	5d                   	pop    %ebp
80105586:	c3                   	ret

80105587 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105587:	55                   	push   %ebp
80105588:	89 e5                	mov    %esp,%ebp
8010558a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
80105590:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105593:	90                   	nop
80105594:	8b 45 10             	mov    0x10(%ebp),%eax
80105597:	8d 50 ff             	lea    -0x1(%eax),%edx
8010559a:	89 55 10             	mov    %edx,0x10(%ebp)
8010559d:	85 c0                	test   %eax,%eax
8010559f:	7e 2c                	jle    801055cd <strncpy+0x46>
801055a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801055a4:	8d 42 01             	lea    0x1(%edx),%eax
801055a7:	89 45 0c             	mov    %eax,0xc(%ebp)
801055aa:	8b 45 08             	mov    0x8(%ebp),%eax
801055ad:	8d 48 01             	lea    0x1(%eax),%ecx
801055b0:	89 4d 08             	mov    %ecx,0x8(%ebp)
801055b3:	0f b6 12             	movzbl (%edx),%edx
801055b6:	88 10                	mov    %dl,(%eax)
801055b8:	0f b6 00             	movzbl (%eax),%eax
801055bb:	84 c0                	test   %al,%al
801055bd:	75 d5                	jne    80105594 <strncpy+0xd>
    ;
  while(n-- > 0)
801055bf:	eb 0c                	jmp    801055cd <strncpy+0x46>
    *s++ = 0;
801055c1:	8b 45 08             	mov    0x8(%ebp),%eax
801055c4:	8d 50 01             	lea    0x1(%eax),%edx
801055c7:	89 55 08             	mov    %edx,0x8(%ebp)
801055ca:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801055cd:	8b 45 10             	mov    0x10(%ebp),%eax
801055d0:	8d 50 ff             	lea    -0x1(%eax),%edx
801055d3:	89 55 10             	mov    %edx,0x10(%ebp)
801055d6:	85 c0                	test   %eax,%eax
801055d8:	7f e7                	jg     801055c1 <strncpy+0x3a>
  return os;
801055da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055dd:	c9                   	leave
801055de:	c3                   	ret

801055df <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055df:	55                   	push   %ebp
801055e0:	89 e5                	mov    %esp,%ebp
801055e2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055e5:	8b 45 08             	mov    0x8(%ebp),%eax
801055e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ef:	7f 05                	jg     801055f6 <safestrcpy+0x17>
    return os;
801055f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f4:	eb 32                	jmp    80105628 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801055f6:	90                   	nop
801055f7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ff:	7e 1e                	jle    8010561f <safestrcpy+0x40>
80105601:	8b 55 0c             	mov    0xc(%ebp),%edx
80105604:	8d 42 01             	lea    0x1(%edx),%eax
80105607:	89 45 0c             	mov    %eax,0xc(%ebp)
8010560a:	8b 45 08             	mov    0x8(%ebp),%eax
8010560d:	8d 48 01             	lea    0x1(%eax),%ecx
80105610:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105613:	0f b6 12             	movzbl (%edx),%edx
80105616:	88 10                	mov    %dl,(%eax)
80105618:	0f b6 00             	movzbl (%eax),%eax
8010561b:	84 c0                	test   %al,%al
8010561d:	75 d8                	jne    801055f7 <safestrcpy+0x18>
    ;
  *s = 0;
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105625:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105628:	c9                   	leave
80105629:	c3                   	ret

8010562a <strlen>:

int
strlen(const char *s)
{
8010562a:	55                   	push   %ebp
8010562b:	89 e5                	mov    %esp,%ebp
8010562d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105630:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105637:	eb 04                	jmp    8010563d <strlen+0x13>
80105639:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010563d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105640:	8b 45 08             	mov    0x8(%ebp),%eax
80105643:	01 d0                	add    %edx,%eax
80105645:	0f b6 00             	movzbl (%eax),%eax
80105648:	84 c0                	test   %al,%al
8010564a:	75 ed                	jne    80105639 <strlen+0xf>
    ;
  return n;
8010564c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010564f:	c9                   	leave
80105650:	c3                   	ret

80105651 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105651:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105655:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105659:	55                   	push   %ebp
  pushl %ebx
8010565a:	53                   	push   %ebx
  pushl %esi
8010565b:	56                   	push   %esi
  pushl %edi
8010565c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010565d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010565f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105661:	5f                   	pop    %edi
  popl %esi
80105662:	5e                   	pop    %esi
  popl %ebx
80105663:	5b                   	pop    %ebx
  popl %ebp
80105664:	5d                   	pop    %ebp
  ret
80105665:	c3                   	ret

80105666 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105666:	55                   	push   %ebp
80105667:	89 e5                	mov    %esp,%ebp
80105669:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010566c:	e8 bf e3 ff ff       	call   80103a30 <myproc>
80105671:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105677:	8b 00                	mov    (%eax),%eax
80105679:	39 45 08             	cmp    %eax,0x8(%ebp)
8010567c:	73 0f                	jae    8010568d <fetchint+0x27>
8010567e:	8b 45 08             	mov    0x8(%ebp),%eax
80105681:	8d 50 04             	lea    0x4(%eax),%edx
80105684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105687:	8b 00                	mov    (%eax),%eax
80105689:	39 d0                	cmp    %edx,%eax
8010568b:	73 07                	jae    80105694 <fetchint+0x2e>
    return -1;
8010568d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105692:	eb 0f                	jmp    801056a3 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105694:	8b 45 08             	mov    0x8(%ebp),%eax
80105697:	8b 10                	mov    (%eax),%edx
80105699:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569c:	89 10                	mov    %edx,(%eax)
  return 0;
8010569e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a3:	c9                   	leave
801056a4:	c3                   	ret

801056a5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056a5:	55                   	push   %ebp
801056a6:	89 e5                	mov    %esp,%ebp
801056a8:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801056ab:	e8 80 e3 ff ff       	call   80103a30 <myproc>
801056b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801056b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b6:	8b 00                	mov    (%eax),%eax
801056b8:	39 45 08             	cmp    %eax,0x8(%ebp)
801056bb:	72 07                	jb     801056c4 <fetchstr+0x1f>
    return -1;
801056bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c2:	eb 41                	jmp    80105705 <fetchstr+0x60>
  *pp = (char*)addr;
801056c4:	8b 55 08             	mov    0x8(%ebp),%edx
801056c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ca:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801056cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cf:	8b 00                	mov    (%eax),%eax
801056d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801056d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d7:	8b 00                	mov    (%eax),%eax
801056d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056dc:	eb 1a                	jmp    801056f8 <fetchstr+0x53>
    if(*s == 0)
801056de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e1:	0f b6 00             	movzbl (%eax),%eax
801056e4:	84 c0                	test   %al,%al
801056e6:	75 0c                	jne    801056f4 <fetchstr+0x4f>
      return s - *pp;
801056e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801056eb:	8b 10                	mov    (%eax),%edx
801056ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f0:	29 d0                	sub    %edx,%eax
801056f2:	eb 11                	jmp    80105705 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801056f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801056f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801056fe:	72 de                	jb     801056de <fetchstr+0x39>
  }
  return -1;
80105700:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105705:	c9                   	leave
80105706:	c3                   	ret

80105707 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105707:	55                   	push   %ebp
80105708:	89 e5                	mov    %esp,%ebp
8010570a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010570d:	e8 1e e3 ff ff       	call   80103a30 <myproc>
80105712:	8b 40 18             	mov    0x18(%eax),%eax
80105715:	8b 40 44             	mov    0x44(%eax),%eax
80105718:	8b 55 08             	mov    0x8(%ebp),%edx
8010571b:	c1 e2 02             	shl    $0x2,%edx
8010571e:	01 d0                	add    %edx,%eax
80105720:	83 c0 04             	add    $0x4,%eax
80105723:	83 ec 08             	sub    $0x8,%esp
80105726:	ff 75 0c             	push   0xc(%ebp)
80105729:	50                   	push   %eax
8010572a:	e8 37 ff ff ff       	call   80105666 <fetchint>
8010572f:	83 c4 10             	add    $0x10,%esp
}
80105732:	c9                   	leave
80105733:	c3                   	ret

80105734 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105734:	55                   	push   %ebp
80105735:	89 e5                	mov    %esp,%ebp
80105737:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010573a:	e8 f1 e2 ff ff       	call   80103a30 <myproc>
8010573f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105742:	83 ec 08             	sub    $0x8,%esp
80105745:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105748:	50                   	push   %eax
80105749:	ff 75 08             	push   0x8(%ebp)
8010574c:	e8 b6 ff ff ff       	call   80105707 <argint>
80105751:	83 c4 10             	add    $0x10,%esp
80105754:	85 c0                	test   %eax,%eax
80105756:	79 07                	jns    8010575f <argptr+0x2b>
    return -1;
80105758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010575d:	eb 3b                	jmp    8010579a <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010575f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105763:	78 1f                	js     80105784 <argptr+0x50>
80105765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105768:	8b 00                	mov    (%eax),%eax
8010576a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010576d:	39 c2                	cmp    %eax,%edx
8010576f:	73 13                	jae    80105784 <argptr+0x50>
80105771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105774:	89 c2                	mov    %eax,%edx
80105776:	8b 45 10             	mov    0x10(%ebp),%eax
80105779:	01 c2                	add    %eax,%edx
8010577b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577e:	8b 00                	mov    (%eax),%eax
80105780:	39 d0                	cmp    %edx,%eax
80105782:	73 07                	jae    8010578b <argptr+0x57>
    return -1;
80105784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105789:	eb 0f                	jmp    8010579a <argptr+0x66>
  *pp = (char*)i;
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	89 c2                	mov    %eax,%edx
80105790:	8b 45 0c             	mov    0xc(%ebp),%eax
80105793:	89 10                	mov    %edx,(%eax)
  return 0;
80105795:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010579a:	c9                   	leave
8010579b:	c3                   	ret

8010579c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010579c:	55                   	push   %ebp
8010579d:	89 e5                	mov    %esp,%ebp
8010579f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057a2:	83 ec 08             	sub    $0x8,%esp
801057a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057a8:	50                   	push   %eax
801057a9:	ff 75 08             	push   0x8(%ebp)
801057ac:	e8 56 ff ff ff       	call   80105707 <argint>
801057b1:	83 c4 10             	add    $0x10,%esp
801057b4:	85 c0                	test   %eax,%eax
801057b6:	79 07                	jns    801057bf <argstr+0x23>
    return -1;
801057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bd:	eb 12                	jmp    801057d1 <argstr+0x35>
  return fetchstr(addr, pp);
801057bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c2:	83 ec 08             	sub    $0x8,%esp
801057c5:	ff 75 0c             	push   0xc(%ebp)
801057c8:	50                   	push   %eax
801057c9:	e8 d7 fe ff ff       	call   801056a5 <fetchstr>
801057ce:	83 c4 10             	add    $0x10,%esp
}
801057d1:	c9                   	leave
801057d2:	c3                   	ret

801057d3 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
801057d3:	55                   	push   %ebp
801057d4:	89 e5                	mov    %esp,%ebp
801057d6:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801057d9:	e8 52 e2 ff ff       	call   80103a30 <myproc>
801057de:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801057e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e4:	8b 40 18             	mov    0x18(%eax),%eax
801057e7:	8b 40 1c             	mov    0x1c(%eax),%eax
801057ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057f1:	7e 2f                	jle    80105822 <syscall+0x4f>
801057f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f6:	83 f8 19             	cmp    $0x19,%eax
801057f9:	77 27                	ja     80105822 <syscall+0x4f>
801057fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fe:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105805:	85 c0                	test   %eax,%eax
80105807:	74 19                	je     80105822 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580c:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105813:	ff d0                	call   *%eax
80105815:	89 c2                	mov    %eax,%edx
80105817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581a:	8b 40 18             	mov    0x18(%eax),%eax
8010581d:	89 50 1c             	mov    %edx,0x1c(%eax)
80105820:	eb 2c                	jmp    8010584e <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105825:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582b:	8b 40 10             	mov    0x10(%eax),%eax
8010582e:	ff 75 f0             	push   -0x10(%ebp)
80105831:	52                   	push   %edx
80105832:	50                   	push   %eax
80105833:	68 c5 b0 10 80       	push   $0x8010b0c5
80105838:	e8 b7 ab ff ff       	call   801003f4 <cprintf>
8010583d:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105843:	8b 40 18             	mov    0x18(%eax),%eax
80105846:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010584d:	90                   	nop
8010584e:	90                   	nop
8010584f:	c9                   	leave
80105850:	c3                   	ret

80105851 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105851:	55                   	push   %ebp
80105852:	89 e5                	mov    %esp,%ebp
80105854:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105857:	83 ec 08             	sub    $0x8,%esp
8010585a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010585d:	50                   	push   %eax
8010585e:	ff 75 08             	push   0x8(%ebp)
80105861:	e8 a1 fe ff ff       	call   80105707 <argint>
80105866:	83 c4 10             	add    $0x10,%esp
80105869:	85 c0                	test   %eax,%eax
8010586b:	79 07                	jns    80105874 <argfd+0x23>
    return -1;
8010586d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105872:	eb 4f                	jmp    801058c3 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105877:	85 c0                	test   %eax,%eax
80105879:	78 20                	js     8010589b <argfd+0x4a>
8010587b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587e:	83 f8 0f             	cmp    $0xf,%eax
80105881:	7f 18                	jg     8010589b <argfd+0x4a>
80105883:	e8 a8 e1 ff ff       	call   80103a30 <myproc>
80105888:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010588b:	83 c2 08             	add    $0x8,%edx
8010588e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105892:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105899:	75 07                	jne    801058a2 <argfd+0x51>
    return -1;
8010589b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a0:	eb 21                	jmp    801058c3 <argfd+0x72>
  if(pfd)
801058a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058a6:	74 08                	je     801058b0 <argfd+0x5f>
    *pfd = fd;
801058a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ae:	89 10                	mov    %edx,(%eax)
  if(pf)
801058b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058b4:	74 08                	je     801058be <argfd+0x6d>
    *pf = f;
801058b6:	8b 45 10             	mov    0x10(%ebp),%eax
801058b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058bc:	89 10                	mov    %edx,(%eax)
  return 0;
801058be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058c3:	c9                   	leave
801058c4:	c3                   	ret

801058c5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058c5:	55                   	push   %ebp
801058c6:	89 e5                	mov    %esp,%ebp
801058c8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801058cb:	e8 60 e1 ff ff       	call   80103a30 <myproc>
801058d0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801058d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058da:	eb 2a                	jmp    80105906 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801058dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e2:	83 c2 08             	add    $0x8,%edx
801058e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058e9:	85 c0                	test   %eax,%eax
801058eb:	75 15                	jne    80105902 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801058ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058f3:	8d 4a 08             	lea    0x8(%edx),%ecx
801058f6:	8b 55 08             	mov    0x8(%ebp),%edx
801058f9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801058fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105900:	eb 0f                	jmp    80105911 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105902:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105906:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010590a:	7e d0                	jle    801058dc <fdalloc+0x17>
    }
  }
  return -1;
8010590c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105911:	c9                   	leave
80105912:	c3                   	ret

80105913 <sys_dup>:

int
sys_dup(void)
{
80105913:	55                   	push   %ebp
80105914:	89 e5                	mov    %esp,%ebp
80105916:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105919:	83 ec 04             	sub    $0x4,%esp
8010591c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591f:	50                   	push   %eax
80105920:	6a 00                	push   $0x0
80105922:	6a 00                	push   $0x0
80105924:	e8 28 ff ff ff       	call   80105851 <argfd>
80105929:	83 c4 10             	add    $0x10,%esp
8010592c:	85 c0                	test   %eax,%eax
8010592e:	79 07                	jns    80105937 <sys_dup+0x24>
    return -1;
80105930:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105935:	eb 31                	jmp    80105968 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593a:	83 ec 0c             	sub    $0xc,%esp
8010593d:	50                   	push   %eax
8010593e:	e8 82 ff ff ff       	call   801058c5 <fdalloc>
80105943:	83 c4 10             	add    $0x10,%esp
80105946:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105949:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010594d:	79 07                	jns    80105956 <sys_dup+0x43>
    return -1;
8010594f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105954:	eb 12                	jmp    80105968 <sys_dup+0x55>
  filedup(f);
80105956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105959:	83 ec 0c             	sub    $0xc,%esp
8010595c:	50                   	push   %eax
8010595d:	e8 f2 b6 ff ff       	call   80101054 <filedup>
80105962:	83 c4 10             	add    $0x10,%esp
  return fd;
80105965:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105968:	c9                   	leave
80105969:	c3                   	ret

8010596a <sys_read>:

int
sys_read(void)
{
8010596a:	55                   	push   %ebp
8010596b:	89 e5                	mov    %esp,%ebp
8010596d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105970:	83 ec 04             	sub    $0x4,%esp
80105973:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105976:	50                   	push   %eax
80105977:	6a 00                	push   $0x0
80105979:	6a 00                	push   $0x0
8010597b:	e8 d1 fe ff ff       	call   80105851 <argfd>
80105980:	83 c4 10             	add    $0x10,%esp
80105983:	85 c0                	test   %eax,%eax
80105985:	78 2e                	js     801059b5 <sys_read+0x4b>
80105987:	83 ec 08             	sub    $0x8,%esp
8010598a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010598d:	50                   	push   %eax
8010598e:	6a 02                	push   $0x2
80105990:	e8 72 fd ff ff       	call   80105707 <argint>
80105995:	83 c4 10             	add    $0x10,%esp
80105998:	85 c0                	test   %eax,%eax
8010599a:	78 19                	js     801059b5 <sys_read+0x4b>
8010599c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599f:	83 ec 04             	sub    $0x4,%esp
801059a2:	50                   	push   %eax
801059a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059a6:	50                   	push   %eax
801059a7:	6a 01                	push   $0x1
801059a9:	e8 86 fd ff ff       	call   80105734 <argptr>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	79 07                	jns    801059bc <sys_read+0x52>
    return -1;
801059b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ba:	eb 17                	jmp    801059d3 <sys_read+0x69>
  return fileread(f, p, n);
801059bc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	83 ec 04             	sub    $0x4,%esp
801059c8:	51                   	push   %ecx
801059c9:	52                   	push   %edx
801059ca:	50                   	push   %eax
801059cb:	e8 14 b8 ff ff       	call   801011e4 <fileread>
801059d0:	83 c4 10             	add    $0x10,%esp
}
801059d3:	c9                   	leave
801059d4:	c3                   	ret

801059d5 <sys_write>:

int
sys_write(void)
{
801059d5:	55                   	push   %ebp
801059d6:	89 e5                	mov    %esp,%ebp
801059d8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059db:	83 ec 04             	sub    $0x4,%esp
801059de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059e1:	50                   	push   %eax
801059e2:	6a 00                	push   $0x0
801059e4:	6a 00                	push   $0x0
801059e6:	e8 66 fe ff ff       	call   80105851 <argfd>
801059eb:	83 c4 10             	add    $0x10,%esp
801059ee:	85 c0                	test   %eax,%eax
801059f0:	78 2e                	js     80105a20 <sys_write+0x4b>
801059f2:	83 ec 08             	sub    $0x8,%esp
801059f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059f8:	50                   	push   %eax
801059f9:	6a 02                	push   $0x2
801059fb:	e8 07 fd ff ff       	call   80105707 <argint>
80105a00:	83 c4 10             	add    $0x10,%esp
80105a03:	85 c0                	test   %eax,%eax
80105a05:	78 19                	js     80105a20 <sys_write+0x4b>
80105a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0a:	83 ec 04             	sub    $0x4,%esp
80105a0d:	50                   	push   %eax
80105a0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a11:	50                   	push   %eax
80105a12:	6a 01                	push   $0x1
80105a14:	e8 1b fd ff ff       	call   80105734 <argptr>
80105a19:	83 c4 10             	add    $0x10,%esp
80105a1c:	85 c0                	test   %eax,%eax
80105a1e:	79 07                	jns    80105a27 <sys_write+0x52>
    return -1;
80105a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a25:	eb 17                	jmp    80105a3e <sys_write+0x69>
  return filewrite(f, p, n);
80105a27:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a2a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a30:	83 ec 04             	sub    $0x4,%esp
80105a33:	51                   	push   %ecx
80105a34:	52                   	push   %edx
80105a35:	50                   	push   %eax
80105a36:	e8 61 b8 ff ff       	call   8010129c <filewrite>
80105a3b:	83 c4 10             	add    $0x10,%esp
}
80105a3e:	c9                   	leave
80105a3f:	c3                   	ret

80105a40 <sys_close>:

int
sys_close(void)
{
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105a46:	83 ec 04             	sub    $0x4,%esp
80105a49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a4c:	50                   	push   %eax
80105a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a50:	50                   	push   %eax
80105a51:	6a 00                	push   $0x0
80105a53:	e8 f9 fd ff ff       	call   80105851 <argfd>
80105a58:	83 c4 10             	add    $0x10,%esp
80105a5b:	85 c0                	test   %eax,%eax
80105a5d:	79 07                	jns    80105a66 <sys_close+0x26>
    return -1;
80105a5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a64:	eb 27                	jmp    80105a8d <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105a66:	e8 c5 df ff ff       	call   80103a30 <myproc>
80105a6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a6e:	83 c2 08             	add    $0x8,%edx
80105a71:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a78:	00 
  fileclose(f);
80105a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7c:	83 ec 0c             	sub    $0xc,%esp
80105a7f:	50                   	push   %eax
80105a80:	e8 20 b6 ff ff       	call   801010a5 <fileclose>
80105a85:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a8d:	c9                   	leave
80105a8e:	c3                   	ret

80105a8f <sys_fstat>:

int
sys_fstat(void)
{
80105a8f:	55                   	push   %ebp
80105a90:	89 e5                	mov    %esp,%ebp
80105a92:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a95:	83 ec 04             	sub    $0x4,%esp
80105a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a9b:	50                   	push   %eax
80105a9c:	6a 00                	push   $0x0
80105a9e:	6a 00                	push   $0x0
80105aa0:	e8 ac fd ff ff       	call   80105851 <argfd>
80105aa5:	83 c4 10             	add    $0x10,%esp
80105aa8:	85 c0                	test   %eax,%eax
80105aaa:	78 17                	js     80105ac3 <sys_fstat+0x34>
80105aac:	83 ec 04             	sub    $0x4,%esp
80105aaf:	6a 14                	push   $0x14
80105ab1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab4:	50                   	push   %eax
80105ab5:	6a 01                	push   $0x1
80105ab7:	e8 78 fc ff ff       	call   80105734 <argptr>
80105abc:	83 c4 10             	add    $0x10,%esp
80105abf:	85 c0                	test   %eax,%eax
80105ac1:	79 07                	jns    80105aca <sys_fstat+0x3b>
    return -1;
80105ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac8:	eb 13                	jmp    80105add <sys_fstat+0x4e>
  return filestat(f, st);
80105aca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad0:	83 ec 08             	sub    $0x8,%esp
80105ad3:	52                   	push   %edx
80105ad4:	50                   	push   %eax
80105ad5:	e8 b3 b6 ff ff       	call   8010118d <filestat>
80105ada:	83 c4 10             	add    $0x10,%esp
}
80105add:	c9                   	leave
80105ade:	c3                   	ret

80105adf <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105adf:	55                   	push   %ebp
80105ae0:	89 e5                	mov    %esp,%ebp
80105ae2:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ae5:	83 ec 08             	sub    $0x8,%esp
80105ae8:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105aeb:	50                   	push   %eax
80105aec:	6a 00                	push   $0x0
80105aee:	e8 a9 fc ff ff       	call   8010579c <argstr>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	85 c0                	test   %eax,%eax
80105af8:	78 15                	js     80105b0f <sys_link+0x30>
80105afa:	83 ec 08             	sub    $0x8,%esp
80105afd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b00:	50                   	push   %eax
80105b01:	6a 01                	push   $0x1
80105b03:	e8 94 fc ff ff       	call   8010579c <argstr>
80105b08:	83 c4 10             	add    $0x10,%esp
80105b0b:	85 c0                	test   %eax,%eax
80105b0d:	79 0a                	jns    80105b19 <sys_link+0x3a>
    return -1;
80105b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b14:	e9 68 01 00 00       	jmp    80105c81 <sys_link+0x1a2>

  begin_op();
80105b19:	e8 20 d5 ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105b1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b21:	83 ec 0c             	sub    $0xc,%esp
80105b24:	50                   	push   %eax
80105b25:	e8 fb c9 ff ff       	call   80102525 <namei>
80105b2a:	83 c4 10             	add    $0x10,%esp
80105b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b34:	75 0f                	jne    80105b45 <sys_link+0x66>
    end_op();
80105b36:	e8 8f d5 ff ff       	call   801030ca <end_op>
    return -1;
80105b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b40:	e9 3c 01 00 00       	jmp    80105c81 <sys_link+0x1a2>
  }

  ilock(ip);
80105b45:	83 ec 0c             	sub    $0xc,%esp
80105b48:	ff 75 f4             	push   -0xc(%ebp)
80105b4b:	e8 a2 be ff ff       	call   801019f2 <ilock>
80105b50:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b56:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b5a:	66 83 f8 01          	cmp    $0x1,%ax
80105b5e:	75 1d                	jne    80105b7d <sys_link+0x9e>
    iunlockput(ip);
80105b60:	83 ec 0c             	sub    $0xc,%esp
80105b63:	ff 75 f4             	push   -0xc(%ebp)
80105b66:	e8 b8 c0 ff ff       	call   80101c23 <iunlockput>
80105b6b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b6e:	e8 57 d5 ff ff       	call   801030ca <end_op>
    return -1;
80105b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b78:	e9 04 01 00 00       	jmp    80105c81 <sys_link+0x1a2>
  }

  ip->nlink++;
80105b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b80:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b84:	83 c0 01             	add    $0x1,%eax
80105b87:	89 c2                	mov    %eax,%edx
80105b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	ff 75 f4             	push   -0xc(%ebp)
80105b96:	e8 7a bc ff ff       	call   80101815 <iupdate>
80105b9b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	ff 75 f4             	push   -0xc(%ebp)
80105ba4:	e8 5c bf ff ff       	call   80101b05 <iunlock>
80105ba9:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105bac:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105baf:	83 ec 08             	sub    $0x8,%esp
80105bb2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bb5:	52                   	push   %edx
80105bb6:	50                   	push   %eax
80105bb7:	e8 85 c9 ff ff       	call   80102541 <nameiparent>
80105bbc:	83 c4 10             	add    $0x10,%esp
80105bbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bc6:	74 71                	je     80105c39 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105bc8:	83 ec 0c             	sub    $0xc,%esp
80105bcb:	ff 75 f0             	push   -0x10(%ebp)
80105bce:	e8 1f be ff ff       	call   801019f2 <ilock>
80105bd3:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd9:	8b 10                	mov    (%eax),%edx
80105bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bde:	8b 00                	mov    (%eax),%eax
80105be0:	39 c2                	cmp    %eax,%edx
80105be2:	75 1d                	jne    80105c01 <sys_link+0x122>
80105be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be7:	8b 40 04             	mov    0x4(%eax),%eax
80105bea:	83 ec 04             	sub    $0x4,%esp
80105bed:	50                   	push   %eax
80105bee:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105bf1:	50                   	push   %eax
80105bf2:	ff 75 f0             	push   -0x10(%ebp)
80105bf5:	e8 94 c6 ff ff       	call   8010228e <dirlink>
80105bfa:	83 c4 10             	add    $0x10,%esp
80105bfd:	85 c0                	test   %eax,%eax
80105bff:	79 10                	jns    80105c11 <sys_link+0x132>
    iunlockput(dp);
80105c01:	83 ec 0c             	sub    $0xc,%esp
80105c04:	ff 75 f0             	push   -0x10(%ebp)
80105c07:	e8 17 c0 ff ff       	call   80101c23 <iunlockput>
80105c0c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c0f:	eb 29                	jmp    80105c3a <sys_link+0x15b>
  }
  iunlockput(dp);
80105c11:	83 ec 0c             	sub    $0xc,%esp
80105c14:	ff 75 f0             	push   -0x10(%ebp)
80105c17:	e8 07 c0 ff ff       	call   80101c23 <iunlockput>
80105c1c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105c1f:	83 ec 0c             	sub    $0xc,%esp
80105c22:	ff 75 f4             	push   -0xc(%ebp)
80105c25:	e8 29 bf ff ff       	call   80101b53 <iput>
80105c2a:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c2d:	e8 98 d4 ff ff       	call   801030ca <end_op>

  return 0;
80105c32:	b8 00 00 00 00       	mov    $0x0,%eax
80105c37:	eb 48                	jmp    80105c81 <sys_link+0x1a2>
    goto bad;
80105c39:	90                   	nop

bad:
  ilock(ip);
80105c3a:	83 ec 0c             	sub    $0xc,%esp
80105c3d:	ff 75 f4             	push   -0xc(%ebp)
80105c40:	e8 ad bd ff ff       	call   801019f2 <ilock>
80105c45:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c4f:	83 e8 01             	sub    $0x1,%eax
80105c52:	89 c2                	mov    %eax,%edx
80105c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c57:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c5b:	83 ec 0c             	sub    $0xc,%esp
80105c5e:	ff 75 f4             	push   -0xc(%ebp)
80105c61:	e8 af bb ff ff       	call   80101815 <iupdate>
80105c66:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c69:	83 ec 0c             	sub    $0xc,%esp
80105c6c:	ff 75 f4             	push   -0xc(%ebp)
80105c6f:	e8 af bf ff ff       	call   80101c23 <iunlockput>
80105c74:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c77:	e8 4e d4 ff ff       	call   801030ca <end_op>
  return -1;
80105c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c81:	c9                   	leave
80105c82:	c3                   	ret

80105c83 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c83:	55                   	push   %ebp
80105c84:	89 e5                	mov    %esp,%ebp
80105c86:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c89:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c90:	eb 40                	jmp    80105cd2 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c95:	6a 10                	push   $0x10
80105c97:	50                   	push   %eax
80105c98:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c9b:	50                   	push   %eax
80105c9c:	ff 75 08             	push   0x8(%ebp)
80105c9f:	e8 3a c2 ff ff       	call   80101ede <readi>
80105ca4:	83 c4 10             	add    $0x10,%esp
80105ca7:	83 f8 10             	cmp    $0x10,%eax
80105caa:	74 0d                	je     80105cb9 <isdirempty+0x36>
      panic("isdirempty: readi");
80105cac:	83 ec 0c             	sub    $0xc,%esp
80105caf:	68 e1 b0 10 80       	push   $0x8010b0e1
80105cb4:	e8 f0 a8 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105cb9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105cbd:	66 85 c0             	test   %ax,%ax
80105cc0:	74 07                	je     80105cc9 <isdirempty+0x46>
      return 0;
80105cc2:	b8 00 00 00 00       	mov    $0x0,%eax
80105cc7:	eb 1b                	jmp    80105ce4 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccc:	83 c0 10             	add    $0x10,%eax
80105ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd5:	8b 40 58             	mov    0x58(%eax),%eax
80105cd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cdb:	39 c2                	cmp    %eax,%edx
80105cdd:	72 b3                	jb     80105c92 <isdirempty+0xf>
  }
  return 1;
80105cdf:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ce4:	c9                   	leave
80105ce5:	c3                   	ret

80105ce6 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ce6:	55                   	push   %ebp
80105ce7:	89 e5                	mov    %esp,%ebp
80105ce9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105cec:	83 ec 08             	sub    $0x8,%esp
80105cef:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105cf2:	50                   	push   %eax
80105cf3:	6a 00                	push   $0x0
80105cf5:	e8 a2 fa ff ff       	call   8010579c <argstr>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	85 c0                	test   %eax,%eax
80105cff:	79 0a                	jns    80105d0b <sys_unlink+0x25>
    return -1;
80105d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d06:	e9 bf 01 00 00       	jmp    80105eca <sys_unlink+0x1e4>

  begin_op();
80105d0b:	e8 2e d3 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d10:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d13:	83 ec 08             	sub    $0x8,%esp
80105d16:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d19:	52                   	push   %edx
80105d1a:	50                   	push   %eax
80105d1b:	e8 21 c8 ff ff       	call   80102541 <nameiparent>
80105d20:	83 c4 10             	add    $0x10,%esp
80105d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d2a:	75 0f                	jne    80105d3b <sys_unlink+0x55>
    end_op();
80105d2c:	e8 99 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d36:	e9 8f 01 00 00       	jmp    80105eca <sys_unlink+0x1e4>
  }

  ilock(dp);
80105d3b:	83 ec 0c             	sub    $0xc,%esp
80105d3e:	ff 75 f4             	push   -0xc(%ebp)
80105d41:	e8 ac bc ff ff       	call   801019f2 <ilock>
80105d46:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d49:	83 ec 08             	sub    $0x8,%esp
80105d4c:	68 f3 b0 10 80       	push   $0x8010b0f3
80105d51:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d54:	50                   	push   %eax
80105d55:	e8 5f c4 ff ff       	call   801021b9 <namecmp>
80105d5a:	83 c4 10             	add    $0x10,%esp
80105d5d:	85 c0                	test   %eax,%eax
80105d5f:	0f 84 49 01 00 00    	je     80105eae <sys_unlink+0x1c8>
80105d65:	83 ec 08             	sub    $0x8,%esp
80105d68:	68 f5 b0 10 80       	push   $0x8010b0f5
80105d6d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d70:	50                   	push   %eax
80105d71:	e8 43 c4 ff ff       	call   801021b9 <namecmp>
80105d76:	83 c4 10             	add    $0x10,%esp
80105d79:	85 c0                	test   %eax,%eax
80105d7b:	0f 84 2d 01 00 00    	je     80105eae <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d81:	83 ec 04             	sub    $0x4,%esp
80105d84:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d87:	50                   	push   %eax
80105d88:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d8b:	50                   	push   %eax
80105d8c:	ff 75 f4             	push   -0xc(%ebp)
80105d8f:	e8 40 c4 ff ff       	call   801021d4 <dirlookup>
80105d94:	83 c4 10             	add    $0x10,%esp
80105d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9e:	0f 84 0d 01 00 00    	je     80105eb1 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105da4:	83 ec 0c             	sub    $0xc,%esp
80105da7:	ff 75 f0             	push   -0x10(%ebp)
80105daa:	e8 43 bc ff ff       	call   801019f2 <ilock>
80105daf:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105db9:	66 85 c0             	test   %ax,%ax
80105dbc:	7f 0d                	jg     80105dcb <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105dbe:	83 ec 0c             	sub    $0xc,%esp
80105dc1:	68 f8 b0 10 80       	push   $0x8010b0f8
80105dc6:	e8 de a7 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dce:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dd2:	66 83 f8 01          	cmp    $0x1,%ax
80105dd6:	75 25                	jne    80105dfd <sys_unlink+0x117>
80105dd8:	83 ec 0c             	sub    $0xc,%esp
80105ddb:	ff 75 f0             	push   -0x10(%ebp)
80105dde:	e8 a0 fe ff ff       	call   80105c83 <isdirempty>
80105de3:	83 c4 10             	add    $0x10,%esp
80105de6:	85 c0                	test   %eax,%eax
80105de8:	75 13                	jne    80105dfd <sys_unlink+0x117>
    iunlockput(ip);
80105dea:	83 ec 0c             	sub    $0xc,%esp
80105ded:	ff 75 f0             	push   -0x10(%ebp)
80105df0:	e8 2e be ff ff       	call   80101c23 <iunlockput>
80105df5:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105df8:	e9 b5 00 00 00       	jmp    80105eb2 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105dfd:	83 ec 04             	sub    $0x4,%esp
80105e00:	6a 10                	push   $0x10
80105e02:	6a 00                	push   $0x0
80105e04:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e07:	50                   	push   %eax
80105e08:	e8 cf f5 ff ff       	call   801053dc <memset>
80105e0d:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e10:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e13:	6a 10                	push   $0x10
80105e15:	50                   	push   %eax
80105e16:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	ff 75 f4             	push   -0xc(%ebp)
80105e1d:	e8 11 c2 ff ff       	call   80102033 <writei>
80105e22:	83 c4 10             	add    $0x10,%esp
80105e25:	83 f8 10             	cmp    $0x10,%eax
80105e28:	74 0d                	je     80105e37 <sys_unlink+0x151>
    panic("unlink: writei");
80105e2a:	83 ec 0c             	sub    $0xc,%esp
80105e2d:	68 0a b1 10 80       	push   $0x8010b10a
80105e32:	e8 72 a7 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e3e:	66 83 f8 01          	cmp    $0x1,%ax
80105e42:	75 21                	jne    80105e65 <sys_unlink+0x17f>
    dp->nlink--;
80105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e47:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e4b:	83 e8 01             	sub    $0x1,%eax
80105e4e:	89 c2                	mov    %eax,%edx
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105e57:	83 ec 0c             	sub    $0xc,%esp
80105e5a:	ff 75 f4             	push   -0xc(%ebp)
80105e5d:	e8 b3 b9 ff ff       	call   80101815 <iupdate>
80105e62:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105e65:	83 ec 0c             	sub    $0xc,%esp
80105e68:	ff 75 f4             	push   -0xc(%ebp)
80105e6b:	e8 b3 bd ff ff       	call   80101c23 <iunlockput>
80105e70:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e76:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e7a:	83 e8 01             	sub    $0x1,%eax
80105e7d:	89 c2                	mov    %eax,%edx
80105e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e82:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e86:	83 ec 0c             	sub    $0xc,%esp
80105e89:	ff 75 f0             	push   -0x10(%ebp)
80105e8c:	e8 84 b9 ff ff       	call   80101815 <iupdate>
80105e91:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e94:	83 ec 0c             	sub    $0xc,%esp
80105e97:	ff 75 f0             	push   -0x10(%ebp)
80105e9a:	e8 84 bd ff ff       	call   80101c23 <iunlockput>
80105e9f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ea2:	e8 23 d2 ff ff       	call   801030ca <end_op>

  return 0;
80105ea7:	b8 00 00 00 00       	mov    $0x0,%eax
80105eac:	eb 1c                	jmp    80105eca <sys_unlink+0x1e4>
    goto bad;
80105eae:	90                   	nop
80105eaf:	eb 01                	jmp    80105eb2 <sys_unlink+0x1cc>
    goto bad;
80105eb1:	90                   	nop

bad:
  iunlockput(dp);
80105eb2:	83 ec 0c             	sub    $0xc,%esp
80105eb5:	ff 75 f4             	push   -0xc(%ebp)
80105eb8:	e8 66 bd ff ff       	call   80101c23 <iunlockput>
80105ebd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ec0:	e8 05 d2 ff ff       	call   801030ca <end_op>
  return -1;
80105ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eca:	c9                   	leave
80105ecb:	c3                   	ret

80105ecc <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ecc:	55                   	push   %ebp
80105ecd:	89 e5                	mov    %esp,%ebp
80105ecf:	83 ec 38             	sub    $0x38,%esp
80105ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ed5:	8b 55 10             	mov    0x10(%ebp),%edx
80105ed8:	8b 45 14             	mov    0x14(%ebp),%eax
80105edb:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105edf:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ee3:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ee7:	83 ec 08             	sub    $0x8,%esp
80105eea:	8d 45 de             	lea    -0x22(%ebp),%eax
80105eed:	50                   	push   %eax
80105eee:	ff 75 08             	push   0x8(%ebp)
80105ef1:	e8 4b c6 ff ff       	call   80102541 <nameiparent>
80105ef6:	83 c4 10             	add    $0x10,%esp
80105ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f00:	75 0a                	jne    80105f0c <create+0x40>
    return 0;
80105f02:	b8 00 00 00 00       	mov    $0x0,%eax
80105f07:	e9 90 01 00 00       	jmp    8010609c <create+0x1d0>
  ilock(dp);
80105f0c:	83 ec 0c             	sub    $0xc,%esp
80105f0f:	ff 75 f4             	push   -0xc(%ebp)
80105f12:	e8 db ba ff ff       	call   801019f2 <ilock>
80105f17:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f1a:	83 ec 04             	sub    $0x4,%esp
80105f1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f20:	50                   	push   %eax
80105f21:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f24:	50                   	push   %eax
80105f25:	ff 75 f4             	push   -0xc(%ebp)
80105f28:	e8 a7 c2 ff ff       	call   801021d4 <dirlookup>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f37:	74 50                	je     80105f89 <create+0xbd>
    iunlockput(dp);
80105f39:	83 ec 0c             	sub    $0xc,%esp
80105f3c:	ff 75 f4             	push   -0xc(%ebp)
80105f3f:	e8 df bc ff ff       	call   80101c23 <iunlockput>
80105f44:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105f47:	83 ec 0c             	sub    $0xc,%esp
80105f4a:	ff 75 f0             	push   -0x10(%ebp)
80105f4d:	e8 a0 ba ff ff       	call   801019f2 <ilock>
80105f52:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105f55:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f5a:	75 15                	jne    80105f71 <create+0xa5>
80105f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f63:	66 83 f8 02          	cmp    $0x2,%ax
80105f67:	75 08                	jne    80105f71 <create+0xa5>
      return ip;
80105f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6c:	e9 2b 01 00 00       	jmp    8010609c <create+0x1d0>
    iunlockput(ip);
80105f71:	83 ec 0c             	sub    $0xc,%esp
80105f74:	ff 75 f0             	push   -0x10(%ebp)
80105f77:	e8 a7 bc ff ff       	call   80101c23 <iunlockput>
80105f7c:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f84:	e9 13 01 00 00       	jmp    8010609c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f89:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f90:	8b 00                	mov    (%eax),%eax
80105f92:	83 ec 08             	sub    $0x8,%esp
80105f95:	52                   	push   %edx
80105f96:	50                   	push   %eax
80105f97:	e8 a3 b7 ff ff       	call   8010173f <ialloc>
80105f9c:	83 c4 10             	add    $0x10,%esp
80105f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa6:	75 0d                	jne    80105fb5 <create+0xe9>
    panic("create: ialloc");
80105fa8:	83 ec 0c             	sub    $0xc,%esp
80105fab:	68 19 b1 10 80       	push   $0x8010b119
80105fb0:	e8 f4 a5 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105fb5:	83 ec 0c             	sub    $0xc,%esp
80105fb8:	ff 75 f0             	push   -0x10(%ebp)
80105fbb:	e8 32 ba ff ff       	call   801019f2 <ilock>
80105fc0:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc6:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105fca:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd1:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105fd5:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdc:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105fe2:	83 ec 0c             	sub    $0xc,%esp
80105fe5:	ff 75 f0             	push   -0x10(%ebp)
80105fe8:	e8 28 b8 ff ff       	call   80101815 <iupdate>
80105fed:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ff0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ff5:	75 6a                	jne    80106061 <create+0x195>
    dp->nlink++;  // for ".."
80105ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ffe:	83 c0 01             	add    $0x1,%eax
80106001:	89 c2                	mov    %eax,%edx
80106003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106006:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010600a:	83 ec 0c             	sub    $0xc,%esp
8010600d:	ff 75 f4             	push   -0xc(%ebp)
80106010:	e8 00 b8 ff ff       	call   80101815 <iupdate>
80106015:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106018:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601b:	8b 40 04             	mov    0x4(%eax),%eax
8010601e:	83 ec 04             	sub    $0x4,%esp
80106021:	50                   	push   %eax
80106022:	68 f3 b0 10 80       	push   $0x8010b0f3
80106027:	ff 75 f0             	push   -0x10(%ebp)
8010602a:	e8 5f c2 ff ff       	call   8010228e <dirlink>
8010602f:	83 c4 10             	add    $0x10,%esp
80106032:	85 c0                	test   %eax,%eax
80106034:	78 1e                	js     80106054 <create+0x188>
80106036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106039:	8b 40 04             	mov    0x4(%eax),%eax
8010603c:	83 ec 04             	sub    $0x4,%esp
8010603f:	50                   	push   %eax
80106040:	68 f5 b0 10 80       	push   $0x8010b0f5
80106045:	ff 75 f0             	push   -0x10(%ebp)
80106048:	e8 41 c2 ff ff       	call   8010228e <dirlink>
8010604d:	83 c4 10             	add    $0x10,%esp
80106050:	85 c0                	test   %eax,%eax
80106052:	79 0d                	jns    80106061 <create+0x195>
      panic("create dots");
80106054:	83 ec 0c             	sub    $0xc,%esp
80106057:	68 28 b1 10 80       	push   $0x8010b128
8010605c:	e8 48 a5 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106061:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106064:	8b 40 04             	mov    0x4(%eax),%eax
80106067:	83 ec 04             	sub    $0x4,%esp
8010606a:	50                   	push   %eax
8010606b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010606e:	50                   	push   %eax
8010606f:	ff 75 f4             	push   -0xc(%ebp)
80106072:	e8 17 c2 ff ff       	call   8010228e <dirlink>
80106077:	83 c4 10             	add    $0x10,%esp
8010607a:	85 c0                	test   %eax,%eax
8010607c:	79 0d                	jns    8010608b <create+0x1bf>
    panic("create: dirlink");
8010607e:	83 ec 0c             	sub    $0xc,%esp
80106081:	68 34 b1 10 80       	push   $0x8010b134
80106086:	e8 1e a5 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010608b:	83 ec 0c             	sub    $0xc,%esp
8010608e:	ff 75 f4             	push   -0xc(%ebp)
80106091:	e8 8d bb ff ff       	call   80101c23 <iunlockput>
80106096:	83 c4 10             	add    $0x10,%esp

  return ip;
80106099:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010609c:	c9                   	leave
8010609d:	c3                   	ret

8010609e <sys_open>:

int
sys_open(void)
{
8010609e:	55                   	push   %ebp
8010609f:	89 e5                	mov    %esp,%ebp
801060a1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060a4:	83 ec 08             	sub    $0x8,%esp
801060a7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060aa:	50                   	push   %eax
801060ab:	6a 00                	push   $0x0
801060ad:	e8 ea f6 ff ff       	call   8010579c <argstr>
801060b2:	83 c4 10             	add    $0x10,%esp
801060b5:	85 c0                	test   %eax,%eax
801060b7:	78 15                	js     801060ce <sys_open+0x30>
801060b9:	83 ec 08             	sub    $0x8,%esp
801060bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060bf:	50                   	push   %eax
801060c0:	6a 01                	push   $0x1
801060c2:	e8 40 f6 ff ff       	call   80105707 <argint>
801060c7:	83 c4 10             	add    $0x10,%esp
801060ca:	85 c0                	test   %eax,%eax
801060cc:	79 0a                	jns    801060d8 <sys_open+0x3a>
    return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d3:	e9 61 01 00 00       	jmp    80106239 <sys_open+0x19b>

  begin_op();
801060d8:	e8 61 cf ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
801060dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e0:	25 00 02 00 00       	and    $0x200,%eax
801060e5:	85 c0                	test   %eax,%eax
801060e7:	74 2a                	je     80106113 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801060e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060ec:	6a 00                	push   $0x0
801060ee:	6a 00                	push   $0x0
801060f0:	6a 02                	push   $0x2
801060f2:	50                   	push   %eax
801060f3:	e8 d4 fd ff ff       	call   80105ecc <create>
801060f8:	83 c4 10             	add    $0x10,%esp
801060fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801060fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106102:	75 75                	jne    80106179 <sys_open+0xdb>
      end_op();
80106104:	e8 c1 cf ff ff       	call   801030ca <end_op>
      return -1;
80106109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610e:	e9 26 01 00 00       	jmp    80106239 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106113:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106116:	83 ec 0c             	sub    $0xc,%esp
80106119:	50                   	push   %eax
8010611a:	e8 06 c4 ff ff       	call   80102525 <namei>
8010611f:	83 c4 10             	add    $0x10,%esp
80106122:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106125:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106129:	75 0f                	jne    8010613a <sys_open+0x9c>
      end_op();
8010612b:	e8 9a cf ff ff       	call   801030ca <end_op>
      return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106135:	e9 ff 00 00 00       	jmp    80106239 <sys_open+0x19b>
    }
    ilock(ip);
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	ff 75 f4             	push   -0xc(%ebp)
80106140:	e8 ad b8 ff ff       	call   801019f2 <ilock>
80106145:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010614f:	66 83 f8 01          	cmp    $0x1,%ax
80106153:	75 24                	jne    80106179 <sys_open+0xdb>
80106155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106158:	85 c0                	test   %eax,%eax
8010615a:	74 1d                	je     80106179 <sys_open+0xdb>
      iunlockput(ip);
8010615c:	83 ec 0c             	sub    $0xc,%esp
8010615f:	ff 75 f4             	push   -0xc(%ebp)
80106162:	e8 bc ba ff ff       	call   80101c23 <iunlockput>
80106167:	83 c4 10             	add    $0x10,%esp
      end_op();
8010616a:	e8 5b cf ff ff       	call   801030ca <end_op>
      return -1;
8010616f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106174:	e9 c0 00 00 00       	jmp    80106239 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106179:	e8 69 ae ff ff       	call   80100fe7 <filealloc>
8010617e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106181:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106185:	74 17                	je     8010619e <sys_open+0x100>
80106187:	83 ec 0c             	sub    $0xc,%esp
8010618a:	ff 75 f0             	push   -0x10(%ebp)
8010618d:	e8 33 f7 ff ff       	call   801058c5 <fdalloc>
80106192:	83 c4 10             	add    $0x10,%esp
80106195:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106198:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010619c:	79 2e                	jns    801061cc <sys_open+0x12e>
    if(f)
8010619e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a2:	74 0e                	je     801061b2 <sys_open+0x114>
      fileclose(f);
801061a4:	83 ec 0c             	sub    $0xc,%esp
801061a7:	ff 75 f0             	push   -0x10(%ebp)
801061aa:	e8 f6 ae ff ff       	call   801010a5 <fileclose>
801061af:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801061b2:	83 ec 0c             	sub    $0xc,%esp
801061b5:	ff 75 f4             	push   -0xc(%ebp)
801061b8:	e8 66 ba ff ff       	call   80101c23 <iunlockput>
801061bd:	83 c4 10             	add    $0x10,%esp
    end_op();
801061c0:	e8 05 cf ff ff       	call   801030ca <end_op>
    return -1;
801061c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ca:	eb 6d                	jmp    80106239 <sys_open+0x19b>
  }
  iunlock(ip);
801061cc:	83 ec 0c             	sub    $0xc,%esp
801061cf:	ff 75 f4             	push   -0xc(%ebp)
801061d2:	e8 2e b9 ff ff       	call   80101b05 <iunlock>
801061d7:	83 c4 10             	add    $0x10,%esp
  end_op();
801061da:	e8 eb ce ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
801061df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ee:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801061fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061fe:	83 e0 01             	and    $0x1,%eax
80106201:	85 c0                	test   %eax,%eax
80106203:	0f 94 c0             	sete   %al
80106206:	89 c2                	mov    %eax,%edx
80106208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010620e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106211:	83 e0 01             	and    $0x1,%eax
80106214:	85 c0                	test   %eax,%eax
80106216:	75 0a                	jne    80106222 <sys_open+0x184>
80106218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010621b:	83 e0 02             	and    $0x2,%eax
8010621e:	85 c0                	test   %eax,%eax
80106220:	74 07                	je     80106229 <sys_open+0x18b>
80106222:	b8 01 00 00 00       	mov    $0x1,%eax
80106227:	eb 05                	jmp    8010622e <sys_open+0x190>
80106229:	b8 00 00 00 00       	mov    $0x0,%eax
8010622e:	89 c2                	mov    %eax,%edx
80106230:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106233:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106236:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106239:	c9                   	leave
8010623a:	c3                   	ret

8010623b <sys_mkdir>:

int
sys_mkdir(void)
{
8010623b:	55                   	push   %ebp
8010623c:	89 e5                	mov    %esp,%ebp
8010623e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106241:	e8 f8 cd ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106246:	83 ec 08             	sub    $0x8,%esp
80106249:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010624c:	50                   	push   %eax
8010624d:	6a 00                	push   $0x0
8010624f:	e8 48 f5 ff ff       	call   8010579c <argstr>
80106254:	83 c4 10             	add    $0x10,%esp
80106257:	85 c0                	test   %eax,%eax
80106259:	78 1b                	js     80106276 <sys_mkdir+0x3b>
8010625b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625e:	6a 00                	push   $0x0
80106260:	6a 00                	push   $0x0
80106262:	6a 01                	push   $0x1
80106264:	50                   	push   %eax
80106265:	e8 62 fc ff ff       	call   80105ecc <create>
8010626a:	83 c4 10             	add    $0x10,%esp
8010626d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106270:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106274:	75 0c                	jne    80106282 <sys_mkdir+0x47>
    end_op();
80106276:	e8 4f ce ff ff       	call   801030ca <end_op>
    return -1;
8010627b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106280:	eb 18                	jmp    8010629a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106282:	83 ec 0c             	sub    $0xc,%esp
80106285:	ff 75 f4             	push   -0xc(%ebp)
80106288:	e8 96 b9 ff ff       	call   80101c23 <iunlockput>
8010628d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106290:	e8 35 ce ff ff       	call   801030ca <end_op>
  return 0;
80106295:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010629a:	c9                   	leave
8010629b:	c3                   	ret

8010629c <sys_mknod>:

int
sys_mknod(void)
{
8010629c:	55                   	push   %ebp
8010629d:	89 e5                	mov    %esp,%ebp
8010629f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801062a2:	e8 97 cd ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
801062a7:	83 ec 08             	sub    $0x8,%esp
801062aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ad:	50                   	push   %eax
801062ae:	6a 00                	push   $0x0
801062b0:	e8 e7 f4 ff ff       	call   8010579c <argstr>
801062b5:	83 c4 10             	add    $0x10,%esp
801062b8:	85 c0                	test   %eax,%eax
801062ba:	78 4f                	js     8010630b <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801062bc:	83 ec 08             	sub    $0x8,%esp
801062bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c2:	50                   	push   %eax
801062c3:	6a 01                	push   $0x1
801062c5:	e8 3d f4 ff ff       	call   80105707 <argint>
801062ca:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801062cd:	85 c0                	test   %eax,%eax
801062cf:	78 3a                	js     8010630b <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801062d1:	83 ec 08             	sub    $0x8,%esp
801062d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062d7:	50                   	push   %eax
801062d8:	6a 02                	push   $0x2
801062da:	e8 28 f4 ff ff       	call   80105707 <argint>
801062df:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801062e2:	85 c0                	test   %eax,%eax
801062e4:	78 25                	js     8010630b <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801062e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062e9:	0f bf c8             	movswl %ax,%ecx
801062ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062ef:	0f bf d0             	movswl %ax,%edx
801062f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f5:	51                   	push   %ecx
801062f6:	52                   	push   %edx
801062f7:	6a 03                	push   $0x3
801062f9:	50                   	push   %eax
801062fa:	e8 cd fb ff ff       	call   80105ecc <create>
801062ff:	83 c4 10             	add    $0x10,%esp
80106302:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106309:	75 0c                	jne    80106317 <sys_mknod+0x7b>
    end_op();
8010630b:	e8 ba cd ff ff       	call   801030ca <end_op>
    return -1;
80106310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106315:	eb 18                	jmp    8010632f <sys_mknod+0x93>
  }
  iunlockput(ip);
80106317:	83 ec 0c             	sub    $0xc,%esp
8010631a:	ff 75 f4             	push   -0xc(%ebp)
8010631d:	e8 01 b9 ff ff       	call   80101c23 <iunlockput>
80106322:	83 c4 10             	add    $0x10,%esp
  end_op();
80106325:	e8 a0 cd ff ff       	call   801030ca <end_op>
  return 0;
8010632a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010632f:	c9                   	leave
80106330:	c3                   	ret

80106331 <sys_chdir>:

int
sys_chdir(void)
{
80106331:	55                   	push   %ebp
80106332:	89 e5                	mov    %esp,%ebp
80106334:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106337:	e8 f4 d6 ff ff       	call   80103a30 <myproc>
8010633c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010633f:	e8 fa cc ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106344:	83 ec 08             	sub    $0x8,%esp
80106347:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010634a:	50                   	push   %eax
8010634b:	6a 00                	push   $0x0
8010634d:	e8 4a f4 ff ff       	call   8010579c <argstr>
80106352:	83 c4 10             	add    $0x10,%esp
80106355:	85 c0                	test   %eax,%eax
80106357:	78 18                	js     80106371 <sys_chdir+0x40>
80106359:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010635c:	83 ec 0c             	sub    $0xc,%esp
8010635f:	50                   	push   %eax
80106360:	e8 c0 c1 ff ff       	call   80102525 <namei>
80106365:	83 c4 10             	add    $0x10,%esp
80106368:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010636b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010636f:	75 0c                	jne    8010637d <sys_chdir+0x4c>
    end_op();
80106371:	e8 54 cd ff ff       	call   801030ca <end_op>
    return -1;
80106376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637b:	eb 68                	jmp    801063e5 <sys_chdir+0xb4>
  }
  ilock(ip);
8010637d:	83 ec 0c             	sub    $0xc,%esp
80106380:	ff 75 f0             	push   -0x10(%ebp)
80106383:	e8 6a b6 ff ff       	call   801019f2 <ilock>
80106388:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010638b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106392:	66 83 f8 01          	cmp    $0x1,%ax
80106396:	74 1a                	je     801063b2 <sys_chdir+0x81>
    iunlockput(ip);
80106398:	83 ec 0c             	sub    $0xc,%esp
8010639b:	ff 75 f0             	push   -0x10(%ebp)
8010639e:	e8 80 b8 ff ff       	call   80101c23 <iunlockput>
801063a3:	83 c4 10             	add    $0x10,%esp
    end_op();
801063a6:	e8 1f cd ff ff       	call   801030ca <end_op>
    return -1;
801063ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b0:	eb 33                	jmp    801063e5 <sys_chdir+0xb4>
  }
  iunlock(ip);
801063b2:	83 ec 0c             	sub    $0xc,%esp
801063b5:	ff 75 f0             	push   -0x10(%ebp)
801063b8:	e8 48 b7 ff ff       	call   80101b05 <iunlock>
801063bd:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801063c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c3:	8b 40 68             	mov    0x68(%eax),%eax
801063c6:	83 ec 0c             	sub    $0xc,%esp
801063c9:	50                   	push   %eax
801063ca:	e8 84 b7 ff ff       	call   80101b53 <iput>
801063cf:	83 c4 10             	add    $0x10,%esp
  end_op();
801063d2:	e8 f3 cc ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
801063d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063dd:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063e5:	c9                   	leave
801063e6:	c3                   	ret

801063e7 <sys_exec>:

int
sys_exec(void)
{
801063e7:	55                   	push   %ebp
801063e8:	89 e5                	mov    %esp,%ebp
801063ea:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063f0:	83 ec 08             	sub    $0x8,%esp
801063f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f6:	50                   	push   %eax
801063f7:	6a 00                	push   $0x0
801063f9:	e8 9e f3 ff ff       	call   8010579c <argstr>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	85 c0                	test   %eax,%eax
80106403:	78 18                	js     8010641d <sys_exec+0x36>
80106405:	83 ec 08             	sub    $0x8,%esp
80106408:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010640e:	50                   	push   %eax
8010640f:	6a 01                	push   $0x1
80106411:	e8 f1 f2 ff ff       	call   80105707 <argint>
80106416:	83 c4 10             	add    $0x10,%esp
80106419:	85 c0                	test   %eax,%eax
8010641b:	79 0a                	jns    80106427 <sys_exec+0x40>
    return -1;
8010641d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106422:	e9 c6 00 00 00       	jmp    801064ed <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106427:	83 ec 04             	sub    $0x4,%esp
8010642a:	68 80 00 00 00       	push   $0x80
8010642f:	6a 00                	push   $0x0
80106431:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106437:	50                   	push   %eax
80106438:	e8 9f ef ff ff       	call   801053dc <memset>
8010643d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106440:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644a:	83 f8 1f             	cmp    $0x1f,%eax
8010644d:	76 0a                	jbe    80106459 <sys_exec+0x72>
      return -1;
8010644f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106454:	e9 94 00 00 00       	jmp    801064ed <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645c:	c1 e0 02             	shl    $0x2,%eax
8010645f:	89 c2                	mov    %eax,%edx
80106461:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106467:	01 c2                	add    %eax,%edx
80106469:	83 ec 08             	sub    $0x8,%esp
8010646c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106472:	50                   	push   %eax
80106473:	52                   	push   %edx
80106474:	e8 ed f1 ff ff       	call   80105666 <fetchint>
80106479:	83 c4 10             	add    $0x10,%esp
8010647c:	85 c0                	test   %eax,%eax
8010647e:	79 07                	jns    80106487 <sys_exec+0xa0>
      return -1;
80106480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106485:	eb 66                	jmp    801064ed <sys_exec+0x106>
    if(uarg == 0){
80106487:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010648d:	85 c0                	test   %eax,%eax
8010648f:	75 27                	jne    801064b8 <sys_exec+0xd1>
      argv[i] = 0;
80106491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106494:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010649b:	00 00 00 00 
      break;
8010649f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a3:	83 ec 08             	sub    $0x8,%esp
801064a6:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064ac:	52                   	push   %edx
801064ad:	50                   	push   %eax
801064ae:	e8 d7 a6 ff ff       	call   80100b8a <exec>
801064b3:	83 c4 10             	add    $0x10,%esp
801064b6:	eb 35                	jmp    801064ed <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801064b8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064c1:	c1 e2 02             	shl    $0x2,%edx
801064c4:	01 c2                	add    %eax,%edx
801064c6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064cc:	83 ec 08             	sub    $0x8,%esp
801064cf:	52                   	push   %edx
801064d0:	50                   	push   %eax
801064d1:	e8 cf f1 ff ff       	call   801056a5 <fetchstr>
801064d6:	83 c4 10             	add    $0x10,%esp
801064d9:	85 c0                	test   %eax,%eax
801064db:	79 07                	jns    801064e4 <sys_exec+0xfd>
      return -1;
801064dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e2:	eb 09                	jmp    801064ed <sys_exec+0x106>
  for(i=0;; i++){
801064e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801064e8:	e9 5a ff ff ff       	jmp    80106447 <sys_exec+0x60>
}
801064ed:	c9                   	leave
801064ee:	c3                   	ret

801064ef <sys_pipe>:

int
sys_pipe(void)
{
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064f5:	83 ec 04             	sub    $0x4,%esp
801064f8:	6a 08                	push   $0x8
801064fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064fd:	50                   	push   %eax
801064fe:	6a 00                	push   $0x0
80106500:	e8 2f f2 ff ff       	call   80105734 <argptr>
80106505:	83 c4 10             	add    $0x10,%esp
80106508:	85 c0                	test   %eax,%eax
8010650a:	79 0a                	jns    80106516 <sys_pipe+0x27>
    return -1;
8010650c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106511:	e9 ae 00 00 00       	jmp    801065c4 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80106516:	83 ec 08             	sub    $0x8,%esp
80106519:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010651c:	50                   	push   %eax
8010651d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106520:	50                   	push   %eax
80106521:	e8 47 d0 ff ff       	call   8010356d <pipealloc>
80106526:	83 c4 10             	add    $0x10,%esp
80106529:	85 c0                	test   %eax,%eax
8010652b:	79 0a                	jns    80106537 <sys_pipe+0x48>
    return -1;
8010652d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106532:	e9 8d 00 00 00       	jmp    801065c4 <sys_pipe+0xd5>
  fd0 = -1;
80106537:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010653e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	50                   	push   %eax
80106545:	e8 7b f3 ff ff       	call   801058c5 <fdalloc>
8010654a:	83 c4 10             	add    $0x10,%esp
8010654d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106550:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106554:	78 18                	js     8010656e <sys_pipe+0x7f>
80106556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106559:	83 ec 0c             	sub    $0xc,%esp
8010655c:	50                   	push   %eax
8010655d:	e8 63 f3 ff ff       	call   801058c5 <fdalloc>
80106562:	83 c4 10             	add    $0x10,%esp
80106565:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106568:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010656c:	79 3e                	jns    801065ac <sys_pipe+0xbd>
    if(fd0 >= 0)
8010656e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106572:	78 13                	js     80106587 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106574:	e8 b7 d4 ff ff       	call   80103a30 <myproc>
80106579:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010657c:	83 c2 08             	add    $0x8,%edx
8010657f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106586:	00 
    fileclose(rf);
80106587:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010658a:	83 ec 0c             	sub    $0xc,%esp
8010658d:	50                   	push   %eax
8010658e:	e8 12 ab ff ff       	call   801010a5 <fileclose>
80106593:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106596:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106599:	83 ec 0c             	sub    $0xc,%esp
8010659c:	50                   	push   %eax
8010659d:	e8 03 ab ff ff       	call   801010a5 <fileclose>
801065a2:	83 c4 10             	add    $0x10,%esp
    return -1;
801065a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065aa:	eb 18                	jmp    801065c4 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
801065ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065b2:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065b7:	8d 50 04             	lea    0x4(%eax),%edx
801065ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bd:	89 02                	mov    %eax,(%edx)
  return 0;
801065bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065c4:	c9                   	leave
801065c5:	c3                   	ret

801065c6 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
801065c6:	55                   	push   %ebp
801065c7:	89 e5                	mov    %esp,%ebp
801065c9:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
801065cc:	83 ec 04             	sub    $0x4,%esp
801065cf:	68 00 0c 00 00       	push   $0xc00
801065d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065d7:	50                   	push   %eax
801065d8:	6a 00                	push   $0x0
801065da:	e8 55 f1 ff ff       	call   80105734 <argptr>
801065df:	83 c4 10             	add    $0x10,%esp
801065e2:	85 c0                	test   %eax,%eax
801065e4:	79 07                	jns    801065ed <sys_getpinfo+0x27>
    return -1;
801065e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065eb:	eb 0f                	jmp    801065fc <sys_getpinfo+0x36>
  return getpinfo(ps);
801065ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f0:	83 ec 0c             	sub    $0xc,%esp
801065f3:	50                   	push   %eax
801065f4:	e8 30 e1 ff ff       	call   80104729 <getpinfo>
801065f9:	83 c4 10             	add    $0x10,%esp
}
801065fc:	c9                   	leave
801065fd:	c3                   	ret

801065fe <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
801065fe:	55                   	push   %ebp
801065ff:	89 e5                	mov    %esp,%ebp
80106601:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
80106604:	83 ec 08             	sub    $0x8,%esp
80106607:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010660a:	50                   	push   %eax
8010660b:	6a 00                	push   $0x0
8010660d:	e8 f5 f0 ff ff       	call   80105707 <argint>
80106612:	83 c4 10             	add    $0x10,%esp
80106615:	85 c0                	test   %eax,%eax
80106617:	79 07                	jns    80106620 <sys_setSchedPolicy+0x22>
    return -1;
80106619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661e:	eb 23                	jmp    80106643 <sys_setSchedPolicy+0x45>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106623:	83 ec 08             	sub    $0x8,%esp
80106626:	50                   	push   %eax
80106627:	68 44 b1 10 80       	push   $0x8010b144
8010662c:	e8 c3 9d ff ff       	call   801003f4 <cprintf>
80106631:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
80106634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106637:	83 ec 0c             	sub    $0xc,%esp
8010663a:	50                   	push   %eax
8010663b:	e8 bd e2 ff ff       	call   801048fd <set_sched_policy>
80106640:	83 c4 10             	add    $0x10,%esp
}
80106643:	c9                   	leave
80106644:	c3                   	ret

80106645 <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
80106645:	55                   	push   %ebp
80106646:	89 e5                	mov    %esp,%ebp
80106648:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
8010664b:	e8 f0 e2 ff ff       	call   80104940 <get_sched_policy>
}
80106650:	c9                   	leave
80106651:	c3                   	ret

80106652 <sys_yield>:
int
sys_yield(void)
{
80106652:	55                   	push   %ebp
80106653:	89 e5                	mov    %esp,%ebp
80106655:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
80106658:	e8 b0 dd ff ff       	call   8010440d <yield>
  return 0;
8010665d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106662:	c9                   	leave
80106663:	c3                   	ret

80106664 <sys_fork>:

int
sys_fork(void)
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010666a:	e8 61 d7 ff ff       	call   80103dd0 <fork>
}
8010666f:	c9                   	leave
80106670:	c3                   	ret

80106671 <sys_exit>:

int
sys_exit(void)
{
80106671:	55                   	push   %ebp
80106672:	89 e5                	mov    %esp,%ebp
80106674:	83 ec 08             	sub    $0x8,%esp
  exit();
80106677:	e8 28 d9 ff ff       	call   80103fa4 <exit>
  return 0;  // not reached
8010667c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106681:	c9                   	leave
80106682:	c3                   	ret

80106683 <sys_wait>:

int
sys_wait(void)
{
80106683:	55                   	push   %ebp
80106684:	89 e5                	mov    %esp,%ebp
80106686:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106689:	e8 58 da ff ff       	call   801040e6 <wait>
}
8010668e:	c9                   	leave
8010668f:	c3                   	ret

80106690 <sys_kill>:

int
sys_kill(void)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106696:	83 ec 08             	sub    $0x8,%esp
80106699:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010669c:	50                   	push   %eax
8010669d:	6a 00                	push   $0x0
8010669f:	e8 63 f0 ff ff       	call   80105707 <argint>
801066a4:	83 c4 10             	add    $0x10,%esp
801066a7:	85 c0                	test   %eax,%eax
801066a9:	79 07                	jns    801066b2 <sys_kill+0x22>
    return -1;
801066ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b0:	eb 0f                	jmp    801066c1 <sys_kill+0x31>
  return kill(pid);
801066b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b5:	83 ec 0c             	sub    $0xc,%esp
801066b8:	50                   	push   %eax
801066b9:	e8 ed de ff ff       	call   801045ab <kill>
801066be:	83 c4 10             	add    $0x10,%esp
}
801066c1:	c9                   	leave
801066c2:	c3                   	ret

801066c3 <sys_getpid>:

int
sys_getpid(void)
{
801066c3:	55                   	push   %ebp
801066c4:	89 e5                	mov    %esp,%ebp
801066c6:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801066c9:	e8 62 d3 ff ff       	call   80103a30 <myproc>
801066ce:	8b 40 10             	mov    0x10(%eax),%eax
}
801066d1:	c9                   	leave
801066d2:	c3                   	ret

801066d3 <sys_sbrk>:

int
sys_sbrk(void)
{
801066d3:	55                   	push   %ebp
801066d4:	89 e5                	mov    %esp,%ebp
801066d6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801066d9:	83 ec 08             	sub    $0x8,%esp
801066dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066df:	50                   	push   %eax
801066e0:	6a 00                	push   $0x0
801066e2:	e8 20 f0 ff ff       	call   80105707 <argint>
801066e7:	83 c4 10             	add    $0x10,%esp
801066ea:	85 c0                	test   %eax,%eax
801066ec:	79 07                	jns    801066f5 <sys_sbrk+0x22>
    return -1;
801066ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f3:	eb 27                	jmp    8010671c <sys_sbrk+0x49>
  addr = myproc()->sz;
801066f5:	e8 36 d3 ff ff       	call   80103a30 <myproc>
801066fa:	8b 00                	mov    (%eax),%eax
801066fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106702:	83 ec 0c             	sub    $0xc,%esp
80106705:	50                   	push   %eax
80106706:	e8 2a d6 ff ff       	call   80103d35 <growproc>
8010670b:	83 c4 10             	add    $0x10,%esp
8010670e:	85 c0                	test   %eax,%eax
80106710:	79 07                	jns    80106719 <sys_sbrk+0x46>
    return -1;
80106712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106717:	eb 03                	jmp    8010671c <sys_sbrk+0x49>
  return addr;
80106719:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010671c:	c9                   	leave
8010671d:	c3                   	ret

8010671e <sys_sleep>:

int
sys_sleep(void)
{
8010671e:	55                   	push   %ebp
8010671f:	89 e5                	mov    %esp,%ebp
80106721:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106724:	83 ec 08             	sub    $0x8,%esp
80106727:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010672a:	50                   	push   %eax
8010672b:	6a 00                	push   $0x0
8010672d:	e8 d5 ef ff ff       	call   80105707 <argint>
80106732:	83 c4 10             	add    $0x10,%esp
80106735:	85 c0                	test   %eax,%eax
80106737:	79 07                	jns    80106740 <sys_sleep+0x22>
    return -1;
80106739:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673e:	eb 76                	jmp    801067b6 <sys_sleep+0x98>
  acquire(&tickslock);
80106740:	83 ec 0c             	sub    $0xc,%esp
80106743:	68 80 79 19 80       	push   $0x80197980
80106748:	e8 19 ea ff ff       	call   80105166 <acquire>
8010674d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106750:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106755:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106758:	eb 38                	jmp    80106792 <sys_sleep+0x74>
    if(myproc()->killed){
8010675a:	e8 d1 d2 ff ff       	call   80103a30 <myproc>
8010675f:	8b 40 24             	mov    0x24(%eax),%eax
80106762:	85 c0                	test   %eax,%eax
80106764:	74 17                	je     8010677d <sys_sleep+0x5f>
      release(&tickslock);
80106766:	83 ec 0c             	sub    $0xc,%esp
80106769:	68 80 79 19 80       	push   $0x80197980
8010676e:	e8 61 ea ff ff       	call   801051d4 <release>
80106773:	83 c4 10             	add    $0x10,%esp
      return -1;
80106776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677b:	eb 39                	jmp    801067b6 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010677d:	83 ec 08             	sub    $0x8,%esp
80106780:	68 80 79 19 80       	push   $0x80197980
80106785:	68 b4 79 19 80       	push   $0x801979b4
8010678a:	e8 fe dc ff ff       	call   8010448d <sleep>
8010678f:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106792:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106797:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010679a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010679d:	39 d0                	cmp    %edx,%eax
8010679f:	72 b9                	jb     8010675a <sys_sleep+0x3c>
  }
  release(&tickslock);
801067a1:	83 ec 0c             	sub    $0xc,%esp
801067a4:	68 80 79 19 80       	push   $0x80197980
801067a9:	e8 26 ea ff ff       	call   801051d4 <release>
801067ae:	83 c4 10             	add    $0x10,%esp
  return 0;
801067b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b6:	c9                   	leave
801067b7:	c3                   	ret

801067b8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067b8:	55                   	push   %ebp
801067b9:	89 e5                	mov    %esp,%ebp
801067bb:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801067be:	83 ec 0c             	sub    $0xc,%esp
801067c1:	68 80 79 19 80       	push   $0x80197980
801067c6:	e8 9b e9 ff ff       	call   80105166 <acquire>
801067cb:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801067ce:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801067d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801067d6:	83 ec 0c             	sub    $0xc,%esp
801067d9:	68 80 79 19 80       	push   $0x80197980
801067de:	e8 f1 e9 ff ff       	call   801051d4 <release>
801067e3:	83 c4 10             	add    $0x10,%esp
  return xticks;
801067e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067e9:	c9                   	leave
801067ea:	c3                   	ret

801067eb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801067eb:	1e                   	push   %ds
  pushl %es
801067ec:	06                   	push   %es
  pushl %fs
801067ed:	0f a0                	push   %fs
  pushl %gs
801067ef:	0f a8                	push   %gs
  pushal
801067f1:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801067f2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801067f6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067f8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801067fa:	54                   	push   %esp
  call trap
801067fb:	e8 d7 01 00 00       	call   801069d7 <trap>
  addl $4, %esp
80106800:	83 c4 04             	add    $0x4,%esp

80106803 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106803:	61                   	popa
  popl %gs
80106804:	0f a9                	pop    %gs
  popl %fs
80106806:	0f a1                	pop    %fs
  popl %es
80106808:	07                   	pop    %es
  popl %ds
80106809:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010680a:	83 c4 08             	add    $0x8,%esp
  iret
8010680d:	cf                   	iret

8010680e <lidt>:
{
8010680e:	55                   	push   %ebp
8010680f:	89 e5                	mov    %esp,%ebp
80106811:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106814:	8b 45 0c             	mov    0xc(%ebp),%eax
80106817:	83 e8 01             	sub    $0x1,%eax
8010681a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010681e:	8b 45 08             	mov    0x8(%ebp),%eax
80106821:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106825:	8b 45 08             	mov    0x8(%ebp),%eax
80106828:	c1 e8 10             	shr    $0x10,%eax
8010682b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010682f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106832:	0f 01 18             	lidtl  (%eax)
}
80106835:	90                   	nop
80106836:	c9                   	leave
80106837:	c3                   	ret

80106838 <rcr2>:

static inline uint
rcr2(void)
{
80106838:	55                   	push   %ebp
80106839:	89 e5                	mov    %esp,%ebp
8010683b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010683e:	0f 20 d0             	mov    %cr2,%eax
80106841:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106847:	c9                   	leave
80106848:	c3                   	ret

80106849 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106849:	55                   	push   %ebp
8010684a:	89 e5                	mov    %esp,%ebp
8010684c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010684f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106856:	e9 c3 00 00 00       	jmp    8010691e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010685b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685e:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106865:	89 c2                	mov    %eax,%edx
80106867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686a:	66 89 14 c5 80 71 19 	mov    %dx,-0x7fe68e80(,%eax,8)
80106871:	80 
80106872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106875:	66 c7 04 c5 82 71 19 	movw   $0x8,-0x7fe68e7e(,%eax,8)
8010687c:	80 08 00 
8010687f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106882:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
80106889:	80 
8010688a:	83 e2 e0             	and    $0xffffffe0,%edx
8010688d:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
80106894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106897:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
8010689e:	80 
8010689f:	83 e2 1f             	and    $0x1f,%edx
801068a2:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
801068a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ac:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801068b3:	80 
801068b4:	83 e2 f0             	and    $0xfffffff0,%edx
801068b7:	83 ca 0e             	or     $0xe,%edx
801068ba:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801068c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c4:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801068cb:	80 
801068cc:	83 e2 ef             	and    $0xffffffef,%edx
801068cf:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801068d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d9:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801068e0:	80 
801068e1:	83 e2 9f             	and    $0xffffff9f,%edx
801068e4:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801068eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ee:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801068f5:	80 
801068f6:	83 ca 80             	or     $0xffffff80,%edx
801068f9:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106903:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
8010690a:	c1 e8 10             	shr    $0x10,%eax
8010690d:	89 c2                	mov    %eax,%edx
8010690f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106912:	66 89 14 c5 86 71 19 	mov    %dx,-0x7fe68e7a(,%eax,8)
80106919:	80 
  for(i = 0; i < 256; i++)
8010691a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010691e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106925:	0f 8e 30 ff ff ff    	jle    8010685b <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010692b:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106930:	66 a3 80 73 19 80    	mov    %ax,0x80197380
80106936:	66 c7 05 82 73 19 80 	movw   $0x8,0x80197382
8010693d:	08 00 
8010693f:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
80106946:	83 e0 e0             	and    $0xffffffe0,%eax
80106949:	a2 84 73 19 80       	mov    %al,0x80197384
8010694e:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
80106955:	83 e0 1f             	and    $0x1f,%eax
80106958:	a2 84 73 19 80       	mov    %al,0x80197384
8010695d:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106964:	83 c8 0f             	or     $0xf,%eax
80106967:	a2 85 73 19 80       	mov    %al,0x80197385
8010696c:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106973:	83 e0 ef             	and    $0xffffffef,%eax
80106976:	a2 85 73 19 80       	mov    %al,0x80197385
8010697b:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106982:	83 c8 60             	or     $0x60,%eax
80106985:	a2 85 73 19 80       	mov    %al,0x80197385
8010698a:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106991:	83 c8 80             	or     $0xffffff80,%eax
80106994:	a2 85 73 19 80       	mov    %al,0x80197385
80106999:	a1 88 f1 10 80       	mov    0x8010f188,%eax
8010699e:	c1 e8 10             	shr    $0x10,%eax
801069a1:	66 a3 86 73 19 80    	mov    %ax,0x80197386

  initlock(&tickslock, "time");
801069a7:	83 ec 08             	sub    $0x8,%esp
801069aa:	68 70 b1 10 80       	push   $0x8010b170
801069af:	68 80 79 19 80       	push   $0x80197980
801069b4:	e8 8b e7 ff ff       	call   80105144 <initlock>
801069b9:	83 c4 10             	add    $0x10,%esp
}
801069bc:	90                   	nop
801069bd:	c9                   	leave
801069be:	c3                   	ret

801069bf <idtinit>:

void
idtinit(void)
{
801069bf:	55                   	push   %ebp
801069c0:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801069c2:	68 00 08 00 00       	push   $0x800
801069c7:	68 80 71 19 80       	push   $0x80197180
801069cc:	e8 3d fe ff ff       	call   8010680e <lidt>
801069d1:	83 c4 08             	add    $0x8,%esp
}
801069d4:	90                   	nop
801069d5:	c9                   	leave
801069d6:	c3                   	ret

801069d7 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801069d7:	55                   	push   %ebp
801069d8:	89 e5                	mov    %esp,%ebp
801069da:	57                   	push   %edi
801069db:	56                   	push   %esi
801069dc:	53                   	push   %ebx
801069dd:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801069e0:	8b 45 08             	mov    0x8(%ebp),%eax
801069e3:	8b 40 30             	mov    0x30(%eax),%eax
801069e6:	83 f8 40             	cmp    $0x40,%eax
801069e9:	75 3b                	jne    80106a26 <trap+0x4f>
    if(myproc()->killed)
801069eb:	e8 40 d0 ff ff       	call   80103a30 <myproc>
801069f0:	8b 40 24             	mov    0x24(%eax),%eax
801069f3:	85 c0                	test   %eax,%eax
801069f5:	74 05                	je     801069fc <trap+0x25>
      exit();
801069f7:	e8 a8 d5 ff ff       	call   80103fa4 <exit>
    myproc()->tf = tf;
801069fc:	e8 2f d0 ff ff       	call   80103a30 <myproc>
80106a01:	8b 55 08             	mov    0x8(%ebp),%edx
80106a04:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a07:	e8 c7 ed ff ff       	call   801057d3 <syscall>
    if(myproc()->killed)
80106a0c:	e8 1f d0 ff ff       	call   80103a30 <myproc>
80106a11:	8b 40 24             	mov    0x24(%eax),%eax
80106a14:	85 c0                	test   %eax,%eax
80106a16:	0f 84 1f 03 00 00    	je     80106d3b <trap+0x364>
      exit();
80106a1c:	e8 83 d5 ff ff       	call   80103fa4 <exit>
    return;
80106a21:	e9 15 03 00 00       	jmp    80106d3b <trap+0x364>
  }

  switch(tf->trapno){
80106a26:	8b 45 08             	mov    0x8(%ebp),%eax
80106a29:	8b 40 30             	mov    0x30(%eax),%eax
80106a2c:	83 e8 20             	sub    $0x20,%eax
80106a2f:	83 f8 1f             	cmp    $0x1f,%eax
80106a32:	0f 87 ce 01 00 00    	ja     80106c06 <trap+0x22f>
80106a38:	8b 04 85 44 b2 10 80 	mov    -0x7fef4dbc(,%eax,4),%eax
80106a3f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106a41:	e8 57 cf ff ff       	call   8010399d <cpuid>
80106a46:	85 c0                	test   %eax,%eax
80106a48:	75 3d                	jne    80106a87 <trap+0xb0>
      acquire(&tickslock);
80106a4a:	83 ec 0c             	sub    $0xc,%esp
80106a4d:	68 80 79 19 80       	push   $0x80197980
80106a52:	e8 0f e7 ff ff       	call   80105166 <acquire>
80106a57:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106a5a:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106a5f:	83 c0 01             	add    $0x1,%eax
80106a62:	a3 b4 79 19 80       	mov    %eax,0x801979b4
      wakeup(&ticks);
80106a67:	83 ec 0c             	sub    $0xc,%esp
80106a6a:	68 b4 79 19 80       	push   $0x801979b4
80106a6f:	e8 00 db ff ff       	call   80104574 <wakeup>
80106a74:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106a77:	83 ec 0c             	sub    $0xc,%esp
80106a7a:	68 80 79 19 80       	push   $0x80197980
80106a7f:	e8 50 e7 ff ff       	call   801051d4 <release>
80106a84:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106a87:	e8 a4 cf ff ff       	call   80103a30 <myproc>
80106a8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106a8f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106a93:	0f 84 f8 00 00 00    	je     80106b91 <trap+0x1ba>
80106a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a9c:	8b 40 0c             	mov    0xc(%eax),%eax
80106a9f:	83 f8 04             	cmp    $0x4,%eax
80106aa2:	0f 85 e9 00 00 00    	jne    80106b91 <trap+0x1ba>
80106aa8:	e8 0b cf ff ff       	call   801039b8 <mycpu>
80106aad:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106ab3:	85 c0                	test   %eax,%eax
80106ab5:	0f 84 d6 00 00 00    	je     80106b91 <trap+0x1ba>
      int idx = myproc() - ptable.proc;
80106abb:	e8 70 cf ff ff       	call   80103a30 <myproc>
80106ac0:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80106ac5:	c1 f8 02             	sar    $0x2,%eax
80106ac8:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106ace:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ad4:	83 e8 80             	sub    $0xffffff80,%eax
80106ad7:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106ade:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106ae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ae4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106aeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106aee:	01 d0                	add    %edx,%eax
80106af0:	05 00 01 00 00       	add    $0x100,%eax
80106af5:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106afc:	8d 50 01             	lea    0x1(%eax),%edx
80106aff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b02:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106b09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b0c:	01 c8                	add    %ecx,%eax
80106b0e:	05 00 01 00 00       	add    $0x100,%eax
80106b13:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106b1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b1d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b24:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b27:	01 d0                	add    %edx,%eax
80106b29:	05 00 01 00 00       	add    $0x100,%eax
80106b2e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106b35:	83 f8 01             	cmp    $0x1,%eax
80106b38:	74 22                	je     80106b5c <trap+0x185>
80106b3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b47:	01 d0                	add    %edx,%eax
80106b49:	05 00 01 00 00       	add    $0x100,%eax
80106b4e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106b55:	83 e0 07             	and    $0x7,%eax
80106b58:	85 c0                	test   %eax,%eax
80106b5a:	75 35                	jne    80106b91 <trap+0x1ba>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b5f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b69:	01 d0                	add    %edx,%eax
80106b6b:	05 00 01 00 00       	add    $0x100,%eax
80106b70:	8b 1c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106b77:	e8 b4 ce ff ff       	call   80103a30 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106b7c:	8b 40 10             	mov    0x10(%eax),%eax
80106b7f:	53                   	push   %ebx
80106b80:	ff 75 dc             	push   -0x24(%ebp)
80106b83:	50                   	push   %eax
80106b84:	68 78 b1 10 80       	push   $0x8010b178
80106b89:	e8 66 98 ff ff       	call   801003f4 <cprintf>
80106b8e:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106b91:	e8 88 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106b96:	e9 20 01 00 00       	jmp    80106cbb <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b9b:	e8 da 3e 00 00       	call   8010aa7a <ideintr>
    lapiceoi();
80106ba0:	e8 79 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106ba5:	e9 11 01 00 00       	jmp    80106cbb <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106baa:	e8 ba bd ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106baf:	e8 6a bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106bb4:	e9 02 01 00 00       	jmp    80106cbb <trap+0x2e4>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bb9:	e8 51 03 00 00       	call   80106f0f <uartintr>
    lapiceoi();
80106bbe:	e8 5b bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106bc3:	e9 f3 00 00 00       	jmp    80106cbb <trap+0x2e4>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106bc8:	e8 76 2b 00 00       	call   80109743 <i8254_intr>
    lapiceoi();
80106bcd:	e8 4c bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106bd2:	e9 e4 00 00 00       	jmp    80106cbb <trap+0x2e4>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bda:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106be0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106be4:	0f b7 d8             	movzwl %ax,%ebx
80106be7:	e8 b1 cd ff ff       	call   8010399d <cpuid>
80106bec:	56                   	push   %esi
80106bed:	53                   	push   %ebx
80106bee:	50                   	push   %eax
80106bef:	68 a4 b1 10 80       	push   $0x8010b1a4
80106bf4:	e8 fb 97 ff ff       	call   801003f4 <cprintf>
80106bf9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106bfc:	e8 1d bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106c01:	e9 b5 00 00 00       	jmp    80106cbb <trap+0x2e4>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106c06:	e8 25 ce ff ff       	call   80103a30 <myproc>
80106c0b:	85 c0                	test   %eax,%eax
80106c0d:	74 11                	je     80106c20 <trap+0x249>
80106c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c12:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c16:	0f b7 c0             	movzwl %ax,%eax
80106c19:	83 e0 03             	and    $0x3,%eax
80106c1c:	85 c0                	test   %eax,%eax
80106c1e:	75 39                	jne    80106c59 <trap+0x282>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c20:	e8 13 fc ff ff       	call   80106838 <rcr2>
80106c25:	89 c3                	mov    %eax,%ebx
80106c27:	8b 45 08             	mov    0x8(%ebp),%eax
80106c2a:	8b 70 38             	mov    0x38(%eax),%esi
80106c2d:	e8 6b cd ff ff       	call   8010399d <cpuid>
80106c32:	8b 55 08             	mov    0x8(%ebp),%edx
80106c35:	8b 52 30             	mov    0x30(%edx),%edx
80106c38:	83 ec 0c             	sub    $0xc,%esp
80106c3b:	53                   	push   %ebx
80106c3c:	56                   	push   %esi
80106c3d:	50                   	push   %eax
80106c3e:	52                   	push   %edx
80106c3f:	68 c8 b1 10 80       	push   $0x8010b1c8
80106c44:	e8 ab 97 ff ff       	call   801003f4 <cprintf>
80106c49:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106c4c:	83 ec 0c             	sub    $0xc,%esp
80106c4f:	68 fa b1 10 80       	push   $0x8010b1fa
80106c54:	e8 50 99 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c59:	e8 da fb ff ff       	call   80106838 <rcr2>
80106c5e:	89 c6                	mov    %eax,%esi
80106c60:	8b 45 08             	mov    0x8(%ebp),%eax
80106c63:	8b 40 38             	mov    0x38(%eax),%eax
80106c66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106c69:	e8 2f cd ff ff       	call   8010399d <cpuid>
80106c6e:	89 c3                	mov    %eax,%ebx
80106c70:	8b 45 08             	mov    0x8(%ebp),%eax
80106c73:	8b 48 34             	mov    0x34(%eax),%ecx
80106c76:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106c79:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7c:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106c7f:	e8 ac cd ff ff       	call   80103a30 <myproc>
80106c84:	8d 50 6c             	lea    0x6c(%eax),%edx
80106c87:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106c8a:	e8 a1 cd ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c8f:	8b 40 10             	mov    0x10(%eax),%eax
80106c92:	56                   	push   %esi
80106c93:	ff 75 d4             	push   -0x2c(%ebp)
80106c96:	53                   	push   %ebx
80106c97:	ff 75 d0             	push   -0x30(%ebp)
80106c9a:	57                   	push   %edi
80106c9b:	ff 75 cc             	push   -0x34(%ebp)
80106c9e:	50                   	push   %eax
80106c9f:	68 00 b2 10 80       	push   $0x8010b200
80106ca4:	e8 4b 97 ff ff       	call   801003f4 <cprintf>
80106ca9:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106cac:	e8 7f cd ff ff       	call   80103a30 <myproc>
80106cb1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cb8:	eb 01                	jmp    80106cbb <trap+0x2e4>
    break;
80106cba:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106cbb:	e8 70 cd ff ff       	call   80103a30 <myproc>
80106cc0:	85 c0                	test   %eax,%eax
80106cc2:	74 23                	je     80106ce7 <trap+0x310>
80106cc4:	e8 67 cd ff ff       	call   80103a30 <myproc>
80106cc9:	8b 40 24             	mov    0x24(%eax),%eax
80106ccc:	85 c0                	test   %eax,%eax
80106cce:	74 17                	je     80106ce7 <trap+0x310>
80106cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cd7:	0f b7 c0             	movzwl %ax,%eax
80106cda:	83 e0 03             	and    $0x3,%eax
80106cdd:	83 f8 03             	cmp    $0x3,%eax
80106ce0:	75 05                	jne    80106ce7 <trap+0x310>
    exit();
80106ce2:	e8 bd d2 ff ff       	call   80103fa4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ce7:	e8 44 cd ff ff       	call   80103a30 <myproc>
80106cec:	85 c0                	test   %eax,%eax
80106cee:	74 1d                	je     80106d0d <trap+0x336>
80106cf0:	e8 3b cd ff ff       	call   80103a30 <myproc>
80106cf5:	8b 40 0c             	mov    0xc(%eax),%eax
80106cf8:	83 f8 04             	cmp    $0x4,%eax
80106cfb:	75 10                	jne    80106d0d <trap+0x336>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106d00:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106d03:	83 f8 20             	cmp    $0x20,%eax
80106d06:	75 05                	jne    80106d0d <trap+0x336>
    yield();
80106d08:	e8 00 d7 ff ff       	call   8010440d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d0d:	e8 1e cd ff ff       	call   80103a30 <myproc>
80106d12:	85 c0                	test   %eax,%eax
80106d14:	74 26                	je     80106d3c <trap+0x365>
80106d16:	e8 15 cd ff ff       	call   80103a30 <myproc>
80106d1b:	8b 40 24             	mov    0x24(%eax),%eax
80106d1e:	85 c0                	test   %eax,%eax
80106d20:	74 1a                	je     80106d3c <trap+0x365>
80106d22:	8b 45 08             	mov    0x8(%ebp),%eax
80106d25:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d29:	0f b7 c0             	movzwl %ax,%eax
80106d2c:	83 e0 03             	and    $0x3,%eax
80106d2f:	83 f8 03             	cmp    $0x3,%eax
80106d32:	75 08                	jne    80106d3c <trap+0x365>
    exit();
80106d34:	e8 6b d2 ff ff       	call   80103fa4 <exit>
80106d39:	eb 01                	jmp    80106d3c <trap+0x365>
    return;
80106d3b:	90                   	nop
}
80106d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d3f:	5b                   	pop    %ebx
80106d40:	5e                   	pop    %esi
80106d41:	5f                   	pop    %edi
80106d42:	5d                   	pop    %ebp
80106d43:	c3                   	ret

80106d44 <inb>:
{
80106d44:	55                   	push   %ebp
80106d45:	89 e5                	mov    %esp,%ebp
80106d47:	83 ec 14             	sub    $0x14,%esp
80106d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d51:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d55:	89 c2                	mov    %eax,%edx
80106d57:	ec                   	in     (%dx),%al
80106d58:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d5b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d5f:	c9                   	leave
80106d60:	c3                   	ret

80106d61 <outb>:
{
80106d61:	55                   	push   %ebp
80106d62:	89 e5                	mov    %esp,%ebp
80106d64:	83 ec 08             	sub    $0x8,%esp
80106d67:	8b 55 08             	mov    0x8(%ebp),%edx
80106d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d6d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d71:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d74:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d78:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d7c:	ee                   	out    %al,(%dx)
}
80106d7d:	90                   	nop
80106d7e:	c9                   	leave
80106d7f:	c3                   	ret

80106d80 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d80:	55                   	push   %ebp
80106d81:	89 e5                	mov    %esp,%ebp
80106d83:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d86:	6a 00                	push   $0x0
80106d88:	68 fa 03 00 00       	push   $0x3fa
80106d8d:	e8 cf ff ff ff       	call   80106d61 <outb>
80106d92:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d95:	68 80 00 00 00       	push   $0x80
80106d9a:	68 fb 03 00 00       	push   $0x3fb
80106d9f:	e8 bd ff ff ff       	call   80106d61 <outb>
80106da4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106da7:	6a 0c                	push   $0xc
80106da9:	68 f8 03 00 00       	push   $0x3f8
80106dae:	e8 ae ff ff ff       	call   80106d61 <outb>
80106db3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106db6:	6a 00                	push   $0x0
80106db8:	68 f9 03 00 00       	push   $0x3f9
80106dbd:	e8 9f ff ff ff       	call   80106d61 <outb>
80106dc2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dc5:	6a 03                	push   $0x3
80106dc7:	68 fb 03 00 00       	push   $0x3fb
80106dcc:	e8 90 ff ff ff       	call   80106d61 <outb>
80106dd1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106dd4:	6a 00                	push   $0x0
80106dd6:	68 fc 03 00 00       	push   $0x3fc
80106ddb:	e8 81 ff ff ff       	call   80106d61 <outb>
80106de0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106de3:	6a 01                	push   $0x1
80106de5:	68 f9 03 00 00       	push   $0x3f9
80106dea:	e8 72 ff ff ff       	call   80106d61 <outb>
80106def:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106df2:	68 fd 03 00 00       	push   $0x3fd
80106df7:	e8 48 ff ff ff       	call   80106d44 <inb>
80106dfc:	83 c4 04             	add    $0x4,%esp
80106dff:	3c ff                	cmp    $0xff,%al
80106e01:	74 61                	je     80106e64 <uartinit+0xe4>
    return;
  uart = 1;
80106e03:	c7 05 b8 79 19 80 01 	movl   $0x1,0x801979b8
80106e0a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e0d:	68 fa 03 00 00       	push   $0x3fa
80106e12:	e8 2d ff ff ff       	call   80106d44 <inb>
80106e17:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e1a:	68 f8 03 00 00       	push   $0x3f8
80106e1f:	e8 20 ff ff ff       	call   80106d44 <inb>
80106e24:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106e27:	83 ec 08             	sub    $0x8,%esp
80106e2a:	6a 00                	push   $0x0
80106e2c:	6a 04                	push   $0x4
80106e2e:	e8 03 b8 ff ff       	call   80102636 <ioapicenable>
80106e33:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e36:	c7 45 f4 c4 b2 10 80 	movl   $0x8010b2c4,-0xc(%ebp)
80106e3d:	eb 19                	jmp    80106e58 <uartinit+0xd8>
    uartputc(*p);
80106e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e42:	0f b6 00             	movzbl (%eax),%eax
80106e45:	0f be c0             	movsbl %al,%eax
80106e48:	83 ec 0c             	sub    $0xc,%esp
80106e4b:	50                   	push   %eax
80106e4c:	e8 16 00 00 00       	call   80106e67 <uartputc>
80106e51:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106e54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e5b:	0f b6 00             	movzbl (%eax),%eax
80106e5e:	84 c0                	test   %al,%al
80106e60:	75 dd                	jne    80106e3f <uartinit+0xbf>
80106e62:	eb 01                	jmp    80106e65 <uartinit+0xe5>
    return;
80106e64:	90                   	nop
}
80106e65:	c9                   	leave
80106e66:	c3                   	ret

80106e67 <uartputc>:

void
uartputc(int c)
{
80106e67:	55                   	push   %ebp
80106e68:	89 e5                	mov    %esp,%ebp
80106e6a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e6d:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106e72:	85 c0                	test   %eax,%eax
80106e74:	74 53                	je     80106ec9 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e7d:	eb 11                	jmp    80106e90 <uartputc+0x29>
    microdelay(10);
80106e7f:	83 ec 0c             	sub    $0xc,%esp
80106e82:	6a 0a                	push   $0xa
80106e84:	e8 b0 bc ff ff       	call   80102b39 <microdelay>
80106e89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e90:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e94:	7f 1a                	jg     80106eb0 <uartputc+0x49>
80106e96:	83 ec 0c             	sub    $0xc,%esp
80106e99:	68 fd 03 00 00       	push   $0x3fd
80106e9e:	e8 a1 fe ff ff       	call   80106d44 <inb>
80106ea3:	83 c4 10             	add    $0x10,%esp
80106ea6:	0f b6 c0             	movzbl %al,%eax
80106ea9:	83 e0 20             	and    $0x20,%eax
80106eac:	85 c0                	test   %eax,%eax
80106eae:	74 cf                	je     80106e7f <uartputc+0x18>
  outb(COM1+0, c);
80106eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb3:	0f b6 c0             	movzbl %al,%eax
80106eb6:	83 ec 08             	sub    $0x8,%esp
80106eb9:	50                   	push   %eax
80106eba:	68 f8 03 00 00       	push   $0x3f8
80106ebf:	e8 9d fe ff ff       	call   80106d61 <outb>
80106ec4:	83 c4 10             	add    $0x10,%esp
80106ec7:	eb 01                	jmp    80106eca <uartputc+0x63>
    return;
80106ec9:	90                   	nop
}
80106eca:	c9                   	leave
80106ecb:	c3                   	ret

80106ecc <uartgetc>:

static int
uartgetc(void)
{
80106ecc:	55                   	push   %ebp
80106ecd:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ecf:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106ed4:	85 c0                	test   %eax,%eax
80106ed6:	75 07                	jne    80106edf <uartgetc+0x13>
    return -1;
80106ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106edd:	eb 2e                	jmp    80106f0d <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106edf:	68 fd 03 00 00       	push   $0x3fd
80106ee4:	e8 5b fe ff ff       	call   80106d44 <inb>
80106ee9:	83 c4 04             	add    $0x4,%esp
80106eec:	0f b6 c0             	movzbl %al,%eax
80106eef:	83 e0 01             	and    $0x1,%eax
80106ef2:	85 c0                	test   %eax,%eax
80106ef4:	75 07                	jne    80106efd <uartgetc+0x31>
    return -1;
80106ef6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106efb:	eb 10                	jmp    80106f0d <uartgetc+0x41>
  return inb(COM1+0);
80106efd:	68 f8 03 00 00       	push   $0x3f8
80106f02:	e8 3d fe ff ff       	call   80106d44 <inb>
80106f07:	83 c4 04             	add    $0x4,%esp
80106f0a:	0f b6 c0             	movzbl %al,%eax
}
80106f0d:	c9                   	leave
80106f0e:	c3                   	ret

80106f0f <uartintr>:

void
uartintr(void)
{
80106f0f:	55                   	push   %ebp
80106f10:	89 e5                	mov    %esp,%ebp
80106f12:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f15:	83 ec 0c             	sub    $0xc,%esp
80106f18:	68 cc 6e 10 80       	push   $0x80106ecc
80106f1d:	e8 b4 98 ff ff       	call   801007d6 <consoleintr>
80106f22:	83 c4 10             	add    $0x10,%esp
}
80106f25:	90                   	nop
80106f26:	c9                   	leave
80106f27:	c3                   	ret

80106f28 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $0
80106f2a:	6a 00                	push   $0x0
  jmp alltraps
80106f2c:	e9 ba f8 ff ff       	jmp    801067eb <alltraps>

80106f31 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $1
80106f33:	6a 01                	push   $0x1
  jmp alltraps
80106f35:	e9 b1 f8 ff ff       	jmp    801067eb <alltraps>

80106f3a <vector2>:
.globl vector2
vector2:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $2
80106f3c:	6a 02                	push   $0x2
  jmp alltraps
80106f3e:	e9 a8 f8 ff ff       	jmp    801067eb <alltraps>

80106f43 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $3
80106f45:	6a 03                	push   $0x3
  jmp alltraps
80106f47:	e9 9f f8 ff ff       	jmp    801067eb <alltraps>

80106f4c <vector4>:
.globl vector4
vector4:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $4
80106f4e:	6a 04                	push   $0x4
  jmp alltraps
80106f50:	e9 96 f8 ff ff       	jmp    801067eb <alltraps>

80106f55 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $5
80106f57:	6a 05                	push   $0x5
  jmp alltraps
80106f59:	e9 8d f8 ff ff       	jmp    801067eb <alltraps>

80106f5e <vector6>:
.globl vector6
vector6:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $6
80106f60:	6a 06                	push   $0x6
  jmp alltraps
80106f62:	e9 84 f8 ff ff       	jmp    801067eb <alltraps>

80106f67 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $7
80106f69:	6a 07                	push   $0x7
  jmp alltraps
80106f6b:	e9 7b f8 ff ff       	jmp    801067eb <alltraps>

80106f70 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f70:	6a 08                	push   $0x8
  jmp alltraps
80106f72:	e9 74 f8 ff ff       	jmp    801067eb <alltraps>

80106f77 <vector9>:
.globl vector9
vector9:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $9
80106f79:	6a 09                	push   $0x9
  jmp alltraps
80106f7b:	e9 6b f8 ff ff       	jmp    801067eb <alltraps>

80106f80 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f80:	6a 0a                	push   $0xa
  jmp alltraps
80106f82:	e9 64 f8 ff ff       	jmp    801067eb <alltraps>

80106f87 <vector11>:
.globl vector11
vector11:
  pushl $11
80106f87:	6a 0b                	push   $0xb
  jmp alltraps
80106f89:	e9 5d f8 ff ff       	jmp    801067eb <alltraps>

80106f8e <vector12>:
.globl vector12
vector12:
  pushl $12
80106f8e:	6a 0c                	push   $0xc
  jmp alltraps
80106f90:	e9 56 f8 ff ff       	jmp    801067eb <alltraps>

80106f95 <vector13>:
.globl vector13
vector13:
  pushl $13
80106f95:	6a 0d                	push   $0xd
  jmp alltraps
80106f97:	e9 4f f8 ff ff       	jmp    801067eb <alltraps>

80106f9c <vector14>:
.globl vector14
vector14:
  pushl $14
80106f9c:	6a 0e                	push   $0xe
  jmp alltraps
80106f9e:	e9 48 f8 ff ff       	jmp    801067eb <alltraps>

80106fa3 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $15
80106fa5:	6a 0f                	push   $0xf
  jmp alltraps
80106fa7:	e9 3f f8 ff ff       	jmp    801067eb <alltraps>

80106fac <vector16>:
.globl vector16
vector16:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $16
80106fae:	6a 10                	push   $0x10
  jmp alltraps
80106fb0:	e9 36 f8 ff ff       	jmp    801067eb <alltraps>

80106fb5 <vector17>:
.globl vector17
vector17:
  pushl $17
80106fb5:	6a 11                	push   $0x11
  jmp alltraps
80106fb7:	e9 2f f8 ff ff       	jmp    801067eb <alltraps>

80106fbc <vector18>:
.globl vector18
vector18:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $18
80106fbe:	6a 12                	push   $0x12
  jmp alltraps
80106fc0:	e9 26 f8 ff ff       	jmp    801067eb <alltraps>

80106fc5 <vector19>:
.globl vector19
vector19:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $19
80106fc7:	6a 13                	push   $0x13
  jmp alltraps
80106fc9:	e9 1d f8 ff ff       	jmp    801067eb <alltraps>

80106fce <vector20>:
.globl vector20
vector20:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $20
80106fd0:	6a 14                	push   $0x14
  jmp alltraps
80106fd2:	e9 14 f8 ff ff       	jmp    801067eb <alltraps>

80106fd7 <vector21>:
.globl vector21
vector21:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $21
80106fd9:	6a 15                	push   $0x15
  jmp alltraps
80106fdb:	e9 0b f8 ff ff       	jmp    801067eb <alltraps>

80106fe0 <vector22>:
.globl vector22
vector22:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $22
80106fe2:	6a 16                	push   $0x16
  jmp alltraps
80106fe4:	e9 02 f8 ff ff       	jmp    801067eb <alltraps>

80106fe9 <vector23>:
.globl vector23
vector23:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $23
80106feb:	6a 17                	push   $0x17
  jmp alltraps
80106fed:	e9 f9 f7 ff ff       	jmp    801067eb <alltraps>

80106ff2 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $24
80106ff4:	6a 18                	push   $0x18
  jmp alltraps
80106ff6:	e9 f0 f7 ff ff       	jmp    801067eb <alltraps>

80106ffb <vector25>:
.globl vector25
vector25:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $25
80106ffd:	6a 19                	push   $0x19
  jmp alltraps
80106fff:	e9 e7 f7 ff ff       	jmp    801067eb <alltraps>

80107004 <vector26>:
.globl vector26
vector26:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $26
80107006:	6a 1a                	push   $0x1a
  jmp alltraps
80107008:	e9 de f7 ff ff       	jmp    801067eb <alltraps>

8010700d <vector27>:
.globl vector27
vector27:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $27
8010700f:	6a 1b                	push   $0x1b
  jmp alltraps
80107011:	e9 d5 f7 ff ff       	jmp    801067eb <alltraps>

80107016 <vector28>:
.globl vector28
vector28:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $28
80107018:	6a 1c                	push   $0x1c
  jmp alltraps
8010701a:	e9 cc f7 ff ff       	jmp    801067eb <alltraps>

8010701f <vector29>:
.globl vector29
vector29:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $29
80107021:	6a 1d                	push   $0x1d
  jmp alltraps
80107023:	e9 c3 f7 ff ff       	jmp    801067eb <alltraps>

80107028 <vector30>:
.globl vector30
vector30:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $30
8010702a:	6a 1e                	push   $0x1e
  jmp alltraps
8010702c:	e9 ba f7 ff ff       	jmp    801067eb <alltraps>

80107031 <vector31>:
.globl vector31
vector31:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $31
80107033:	6a 1f                	push   $0x1f
  jmp alltraps
80107035:	e9 b1 f7 ff ff       	jmp    801067eb <alltraps>

8010703a <vector32>:
.globl vector32
vector32:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $32
8010703c:	6a 20                	push   $0x20
  jmp alltraps
8010703e:	e9 a8 f7 ff ff       	jmp    801067eb <alltraps>

80107043 <vector33>:
.globl vector33
vector33:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $33
80107045:	6a 21                	push   $0x21
  jmp alltraps
80107047:	e9 9f f7 ff ff       	jmp    801067eb <alltraps>

8010704c <vector34>:
.globl vector34
vector34:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $34
8010704e:	6a 22                	push   $0x22
  jmp alltraps
80107050:	e9 96 f7 ff ff       	jmp    801067eb <alltraps>

80107055 <vector35>:
.globl vector35
vector35:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $35
80107057:	6a 23                	push   $0x23
  jmp alltraps
80107059:	e9 8d f7 ff ff       	jmp    801067eb <alltraps>

8010705e <vector36>:
.globl vector36
vector36:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $36
80107060:	6a 24                	push   $0x24
  jmp alltraps
80107062:	e9 84 f7 ff ff       	jmp    801067eb <alltraps>

80107067 <vector37>:
.globl vector37
vector37:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $37
80107069:	6a 25                	push   $0x25
  jmp alltraps
8010706b:	e9 7b f7 ff ff       	jmp    801067eb <alltraps>

80107070 <vector38>:
.globl vector38
vector38:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $38
80107072:	6a 26                	push   $0x26
  jmp alltraps
80107074:	e9 72 f7 ff ff       	jmp    801067eb <alltraps>

80107079 <vector39>:
.globl vector39
vector39:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $39
8010707b:	6a 27                	push   $0x27
  jmp alltraps
8010707d:	e9 69 f7 ff ff       	jmp    801067eb <alltraps>

80107082 <vector40>:
.globl vector40
vector40:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $40
80107084:	6a 28                	push   $0x28
  jmp alltraps
80107086:	e9 60 f7 ff ff       	jmp    801067eb <alltraps>

8010708b <vector41>:
.globl vector41
vector41:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $41
8010708d:	6a 29                	push   $0x29
  jmp alltraps
8010708f:	e9 57 f7 ff ff       	jmp    801067eb <alltraps>

80107094 <vector42>:
.globl vector42
vector42:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $42
80107096:	6a 2a                	push   $0x2a
  jmp alltraps
80107098:	e9 4e f7 ff ff       	jmp    801067eb <alltraps>

8010709d <vector43>:
.globl vector43
vector43:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $43
8010709f:	6a 2b                	push   $0x2b
  jmp alltraps
801070a1:	e9 45 f7 ff ff       	jmp    801067eb <alltraps>

801070a6 <vector44>:
.globl vector44
vector44:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $44
801070a8:	6a 2c                	push   $0x2c
  jmp alltraps
801070aa:	e9 3c f7 ff ff       	jmp    801067eb <alltraps>

801070af <vector45>:
.globl vector45
vector45:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $45
801070b1:	6a 2d                	push   $0x2d
  jmp alltraps
801070b3:	e9 33 f7 ff ff       	jmp    801067eb <alltraps>

801070b8 <vector46>:
.globl vector46
vector46:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $46
801070ba:	6a 2e                	push   $0x2e
  jmp alltraps
801070bc:	e9 2a f7 ff ff       	jmp    801067eb <alltraps>

801070c1 <vector47>:
.globl vector47
vector47:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $47
801070c3:	6a 2f                	push   $0x2f
  jmp alltraps
801070c5:	e9 21 f7 ff ff       	jmp    801067eb <alltraps>

801070ca <vector48>:
.globl vector48
vector48:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $48
801070cc:	6a 30                	push   $0x30
  jmp alltraps
801070ce:	e9 18 f7 ff ff       	jmp    801067eb <alltraps>

801070d3 <vector49>:
.globl vector49
vector49:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $49
801070d5:	6a 31                	push   $0x31
  jmp alltraps
801070d7:	e9 0f f7 ff ff       	jmp    801067eb <alltraps>

801070dc <vector50>:
.globl vector50
vector50:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $50
801070de:	6a 32                	push   $0x32
  jmp alltraps
801070e0:	e9 06 f7 ff ff       	jmp    801067eb <alltraps>

801070e5 <vector51>:
.globl vector51
vector51:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $51
801070e7:	6a 33                	push   $0x33
  jmp alltraps
801070e9:	e9 fd f6 ff ff       	jmp    801067eb <alltraps>

801070ee <vector52>:
.globl vector52
vector52:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $52
801070f0:	6a 34                	push   $0x34
  jmp alltraps
801070f2:	e9 f4 f6 ff ff       	jmp    801067eb <alltraps>

801070f7 <vector53>:
.globl vector53
vector53:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $53
801070f9:	6a 35                	push   $0x35
  jmp alltraps
801070fb:	e9 eb f6 ff ff       	jmp    801067eb <alltraps>

80107100 <vector54>:
.globl vector54
vector54:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $54
80107102:	6a 36                	push   $0x36
  jmp alltraps
80107104:	e9 e2 f6 ff ff       	jmp    801067eb <alltraps>

80107109 <vector55>:
.globl vector55
vector55:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $55
8010710b:	6a 37                	push   $0x37
  jmp alltraps
8010710d:	e9 d9 f6 ff ff       	jmp    801067eb <alltraps>

80107112 <vector56>:
.globl vector56
vector56:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $56
80107114:	6a 38                	push   $0x38
  jmp alltraps
80107116:	e9 d0 f6 ff ff       	jmp    801067eb <alltraps>

8010711b <vector57>:
.globl vector57
vector57:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $57
8010711d:	6a 39                	push   $0x39
  jmp alltraps
8010711f:	e9 c7 f6 ff ff       	jmp    801067eb <alltraps>

80107124 <vector58>:
.globl vector58
vector58:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $58
80107126:	6a 3a                	push   $0x3a
  jmp alltraps
80107128:	e9 be f6 ff ff       	jmp    801067eb <alltraps>

8010712d <vector59>:
.globl vector59
vector59:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $59
8010712f:	6a 3b                	push   $0x3b
  jmp alltraps
80107131:	e9 b5 f6 ff ff       	jmp    801067eb <alltraps>

80107136 <vector60>:
.globl vector60
vector60:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $60
80107138:	6a 3c                	push   $0x3c
  jmp alltraps
8010713a:	e9 ac f6 ff ff       	jmp    801067eb <alltraps>

8010713f <vector61>:
.globl vector61
vector61:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $61
80107141:	6a 3d                	push   $0x3d
  jmp alltraps
80107143:	e9 a3 f6 ff ff       	jmp    801067eb <alltraps>

80107148 <vector62>:
.globl vector62
vector62:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $62
8010714a:	6a 3e                	push   $0x3e
  jmp alltraps
8010714c:	e9 9a f6 ff ff       	jmp    801067eb <alltraps>

80107151 <vector63>:
.globl vector63
vector63:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $63
80107153:	6a 3f                	push   $0x3f
  jmp alltraps
80107155:	e9 91 f6 ff ff       	jmp    801067eb <alltraps>

8010715a <vector64>:
.globl vector64
vector64:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $64
8010715c:	6a 40                	push   $0x40
  jmp alltraps
8010715e:	e9 88 f6 ff ff       	jmp    801067eb <alltraps>

80107163 <vector65>:
.globl vector65
vector65:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $65
80107165:	6a 41                	push   $0x41
  jmp alltraps
80107167:	e9 7f f6 ff ff       	jmp    801067eb <alltraps>

8010716c <vector66>:
.globl vector66
vector66:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $66
8010716e:	6a 42                	push   $0x42
  jmp alltraps
80107170:	e9 76 f6 ff ff       	jmp    801067eb <alltraps>

80107175 <vector67>:
.globl vector67
vector67:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $67
80107177:	6a 43                	push   $0x43
  jmp alltraps
80107179:	e9 6d f6 ff ff       	jmp    801067eb <alltraps>

8010717e <vector68>:
.globl vector68
vector68:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $68
80107180:	6a 44                	push   $0x44
  jmp alltraps
80107182:	e9 64 f6 ff ff       	jmp    801067eb <alltraps>

80107187 <vector69>:
.globl vector69
vector69:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $69
80107189:	6a 45                	push   $0x45
  jmp alltraps
8010718b:	e9 5b f6 ff ff       	jmp    801067eb <alltraps>

80107190 <vector70>:
.globl vector70
vector70:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $70
80107192:	6a 46                	push   $0x46
  jmp alltraps
80107194:	e9 52 f6 ff ff       	jmp    801067eb <alltraps>

80107199 <vector71>:
.globl vector71
vector71:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $71
8010719b:	6a 47                	push   $0x47
  jmp alltraps
8010719d:	e9 49 f6 ff ff       	jmp    801067eb <alltraps>

801071a2 <vector72>:
.globl vector72
vector72:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $72
801071a4:	6a 48                	push   $0x48
  jmp alltraps
801071a6:	e9 40 f6 ff ff       	jmp    801067eb <alltraps>

801071ab <vector73>:
.globl vector73
vector73:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $73
801071ad:	6a 49                	push   $0x49
  jmp alltraps
801071af:	e9 37 f6 ff ff       	jmp    801067eb <alltraps>

801071b4 <vector74>:
.globl vector74
vector74:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $74
801071b6:	6a 4a                	push   $0x4a
  jmp alltraps
801071b8:	e9 2e f6 ff ff       	jmp    801067eb <alltraps>

801071bd <vector75>:
.globl vector75
vector75:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $75
801071bf:	6a 4b                	push   $0x4b
  jmp alltraps
801071c1:	e9 25 f6 ff ff       	jmp    801067eb <alltraps>

801071c6 <vector76>:
.globl vector76
vector76:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $76
801071c8:	6a 4c                	push   $0x4c
  jmp alltraps
801071ca:	e9 1c f6 ff ff       	jmp    801067eb <alltraps>

801071cf <vector77>:
.globl vector77
vector77:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $77
801071d1:	6a 4d                	push   $0x4d
  jmp alltraps
801071d3:	e9 13 f6 ff ff       	jmp    801067eb <alltraps>

801071d8 <vector78>:
.globl vector78
vector78:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $78
801071da:	6a 4e                	push   $0x4e
  jmp alltraps
801071dc:	e9 0a f6 ff ff       	jmp    801067eb <alltraps>

801071e1 <vector79>:
.globl vector79
vector79:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $79
801071e3:	6a 4f                	push   $0x4f
  jmp alltraps
801071e5:	e9 01 f6 ff ff       	jmp    801067eb <alltraps>

801071ea <vector80>:
.globl vector80
vector80:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $80
801071ec:	6a 50                	push   $0x50
  jmp alltraps
801071ee:	e9 f8 f5 ff ff       	jmp    801067eb <alltraps>

801071f3 <vector81>:
.globl vector81
vector81:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $81
801071f5:	6a 51                	push   $0x51
  jmp alltraps
801071f7:	e9 ef f5 ff ff       	jmp    801067eb <alltraps>

801071fc <vector82>:
.globl vector82
vector82:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $82
801071fe:	6a 52                	push   $0x52
  jmp alltraps
80107200:	e9 e6 f5 ff ff       	jmp    801067eb <alltraps>

80107205 <vector83>:
.globl vector83
vector83:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $83
80107207:	6a 53                	push   $0x53
  jmp alltraps
80107209:	e9 dd f5 ff ff       	jmp    801067eb <alltraps>

8010720e <vector84>:
.globl vector84
vector84:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $84
80107210:	6a 54                	push   $0x54
  jmp alltraps
80107212:	e9 d4 f5 ff ff       	jmp    801067eb <alltraps>

80107217 <vector85>:
.globl vector85
vector85:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $85
80107219:	6a 55                	push   $0x55
  jmp alltraps
8010721b:	e9 cb f5 ff ff       	jmp    801067eb <alltraps>

80107220 <vector86>:
.globl vector86
vector86:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $86
80107222:	6a 56                	push   $0x56
  jmp alltraps
80107224:	e9 c2 f5 ff ff       	jmp    801067eb <alltraps>

80107229 <vector87>:
.globl vector87
vector87:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $87
8010722b:	6a 57                	push   $0x57
  jmp alltraps
8010722d:	e9 b9 f5 ff ff       	jmp    801067eb <alltraps>

80107232 <vector88>:
.globl vector88
vector88:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $88
80107234:	6a 58                	push   $0x58
  jmp alltraps
80107236:	e9 b0 f5 ff ff       	jmp    801067eb <alltraps>

8010723b <vector89>:
.globl vector89
vector89:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $89
8010723d:	6a 59                	push   $0x59
  jmp alltraps
8010723f:	e9 a7 f5 ff ff       	jmp    801067eb <alltraps>

80107244 <vector90>:
.globl vector90
vector90:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $90
80107246:	6a 5a                	push   $0x5a
  jmp alltraps
80107248:	e9 9e f5 ff ff       	jmp    801067eb <alltraps>

8010724d <vector91>:
.globl vector91
vector91:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $91
8010724f:	6a 5b                	push   $0x5b
  jmp alltraps
80107251:	e9 95 f5 ff ff       	jmp    801067eb <alltraps>

80107256 <vector92>:
.globl vector92
vector92:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $92
80107258:	6a 5c                	push   $0x5c
  jmp alltraps
8010725a:	e9 8c f5 ff ff       	jmp    801067eb <alltraps>

8010725f <vector93>:
.globl vector93
vector93:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $93
80107261:	6a 5d                	push   $0x5d
  jmp alltraps
80107263:	e9 83 f5 ff ff       	jmp    801067eb <alltraps>

80107268 <vector94>:
.globl vector94
vector94:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $94
8010726a:	6a 5e                	push   $0x5e
  jmp alltraps
8010726c:	e9 7a f5 ff ff       	jmp    801067eb <alltraps>

80107271 <vector95>:
.globl vector95
vector95:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $95
80107273:	6a 5f                	push   $0x5f
  jmp alltraps
80107275:	e9 71 f5 ff ff       	jmp    801067eb <alltraps>

8010727a <vector96>:
.globl vector96
vector96:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $96
8010727c:	6a 60                	push   $0x60
  jmp alltraps
8010727e:	e9 68 f5 ff ff       	jmp    801067eb <alltraps>

80107283 <vector97>:
.globl vector97
vector97:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $97
80107285:	6a 61                	push   $0x61
  jmp alltraps
80107287:	e9 5f f5 ff ff       	jmp    801067eb <alltraps>

8010728c <vector98>:
.globl vector98
vector98:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $98
8010728e:	6a 62                	push   $0x62
  jmp alltraps
80107290:	e9 56 f5 ff ff       	jmp    801067eb <alltraps>

80107295 <vector99>:
.globl vector99
vector99:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $99
80107297:	6a 63                	push   $0x63
  jmp alltraps
80107299:	e9 4d f5 ff ff       	jmp    801067eb <alltraps>

8010729e <vector100>:
.globl vector100
vector100:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $100
801072a0:	6a 64                	push   $0x64
  jmp alltraps
801072a2:	e9 44 f5 ff ff       	jmp    801067eb <alltraps>

801072a7 <vector101>:
.globl vector101
vector101:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $101
801072a9:	6a 65                	push   $0x65
  jmp alltraps
801072ab:	e9 3b f5 ff ff       	jmp    801067eb <alltraps>

801072b0 <vector102>:
.globl vector102
vector102:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $102
801072b2:	6a 66                	push   $0x66
  jmp alltraps
801072b4:	e9 32 f5 ff ff       	jmp    801067eb <alltraps>

801072b9 <vector103>:
.globl vector103
vector103:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $103
801072bb:	6a 67                	push   $0x67
  jmp alltraps
801072bd:	e9 29 f5 ff ff       	jmp    801067eb <alltraps>

801072c2 <vector104>:
.globl vector104
vector104:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $104
801072c4:	6a 68                	push   $0x68
  jmp alltraps
801072c6:	e9 20 f5 ff ff       	jmp    801067eb <alltraps>

801072cb <vector105>:
.globl vector105
vector105:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $105
801072cd:	6a 69                	push   $0x69
  jmp alltraps
801072cf:	e9 17 f5 ff ff       	jmp    801067eb <alltraps>

801072d4 <vector106>:
.globl vector106
vector106:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $106
801072d6:	6a 6a                	push   $0x6a
  jmp alltraps
801072d8:	e9 0e f5 ff ff       	jmp    801067eb <alltraps>

801072dd <vector107>:
.globl vector107
vector107:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $107
801072df:	6a 6b                	push   $0x6b
  jmp alltraps
801072e1:	e9 05 f5 ff ff       	jmp    801067eb <alltraps>

801072e6 <vector108>:
.globl vector108
vector108:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $108
801072e8:	6a 6c                	push   $0x6c
  jmp alltraps
801072ea:	e9 fc f4 ff ff       	jmp    801067eb <alltraps>

801072ef <vector109>:
.globl vector109
vector109:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $109
801072f1:	6a 6d                	push   $0x6d
  jmp alltraps
801072f3:	e9 f3 f4 ff ff       	jmp    801067eb <alltraps>

801072f8 <vector110>:
.globl vector110
vector110:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $110
801072fa:	6a 6e                	push   $0x6e
  jmp alltraps
801072fc:	e9 ea f4 ff ff       	jmp    801067eb <alltraps>

80107301 <vector111>:
.globl vector111
vector111:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $111
80107303:	6a 6f                	push   $0x6f
  jmp alltraps
80107305:	e9 e1 f4 ff ff       	jmp    801067eb <alltraps>

8010730a <vector112>:
.globl vector112
vector112:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $112
8010730c:	6a 70                	push   $0x70
  jmp alltraps
8010730e:	e9 d8 f4 ff ff       	jmp    801067eb <alltraps>

80107313 <vector113>:
.globl vector113
vector113:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $113
80107315:	6a 71                	push   $0x71
  jmp alltraps
80107317:	e9 cf f4 ff ff       	jmp    801067eb <alltraps>

8010731c <vector114>:
.globl vector114
vector114:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $114
8010731e:	6a 72                	push   $0x72
  jmp alltraps
80107320:	e9 c6 f4 ff ff       	jmp    801067eb <alltraps>

80107325 <vector115>:
.globl vector115
vector115:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $115
80107327:	6a 73                	push   $0x73
  jmp alltraps
80107329:	e9 bd f4 ff ff       	jmp    801067eb <alltraps>

8010732e <vector116>:
.globl vector116
vector116:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $116
80107330:	6a 74                	push   $0x74
  jmp alltraps
80107332:	e9 b4 f4 ff ff       	jmp    801067eb <alltraps>

80107337 <vector117>:
.globl vector117
vector117:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $117
80107339:	6a 75                	push   $0x75
  jmp alltraps
8010733b:	e9 ab f4 ff ff       	jmp    801067eb <alltraps>

80107340 <vector118>:
.globl vector118
vector118:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $118
80107342:	6a 76                	push   $0x76
  jmp alltraps
80107344:	e9 a2 f4 ff ff       	jmp    801067eb <alltraps>

80107349 <vector119>:
.globl vector119
vector119:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $119
8010734b:	6a 77                	push   $0x77
  jmp alltraps
8010734d:	e9 99 f4 ff ff       	jmp    801067eb <alltraps>

80107352 <vector120>:
.globl vector120
vector120:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $120
80107354:	6a 78                	push   $0x78
  jmp alltraps
80107356:	e9 90 f4 ff ff       	jmp    801067eb <alltraps>

8010735b <vector121>:
.globl vector121
vector121:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $121
8010735d:	6a 79                	push   $0x79
  jmp alltraps
8010735f:	e9 87 f4 ff ff       	jmp    801067eb <alltraps>

80107364 <vector122>:
.globl vector122
vector122:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $122
80107366:	6a 7a                	push   $0x7a
  jmp alltraps
80107368:	e9 7e f4 ff ff       	jmp    801067eb <alltraps>

8010736d <vector123>:
.globl vector123
vector123:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $123
8010736f:	6a 7b                	push   $0x7b
  jmp alltraps
80107371:	e9 75 f4 ff ff       	jmp    801067eb <alltraps>

80107376 <vector124>:
.globl vector124
vector124:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $124
80107378:	6a 7c                	push   $0x7c
  jmp alltraps
8010737a:	e9 6c f4 ff ff       	jmp    801067eb <alltraps>

8010737f <vector125>:
.globl vector125
vector125:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $125
80107381:	6a 7d                	push   $0x7d
  jmp alltraps
80107383:	e9 63 f4 ff ff       	jmp    801067eb <alltraps>

80107388 <vector126>:
.globl vector126
vector126:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $126
8010738a:	6a 7e                	push   $0x7e
  jmp alltraps
8010738c:	e9 5a f4 ff ff       	jmp    801067eb <alltraps>

80107391 <vector127>:
.globl vector127
vector127:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $127
80107393:	6a 7f                	push   $0x7f
  jmp alltraps
80107395:	e9 51 f4 ff ff       	jmp    801067eb <alltraps>

8010739a <vector128>:
.globl vector128
vector128:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $128
8010739c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073a1:	e9 45 f4 ff ff       	jmp    801067eb <alltraps>

801073a6 <vector129>:
.globl vector129
vector129:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $129
801073a8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073ad:	e9 39 f4 ff ff       	jmp    801067eb <alltraps>

801073b2 <vector130>:
.globl vector130
vector130:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $130
801073b4:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073b9:	e9 2d f4 ff ff       	jmp    801067eb <alltraps>

801073be <vector131>:
.globl vector131
vector131:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $131
801073c0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073c5:	e9 21 f4 ff ff       	jmp    801067eb <alltraps>

801073ca <vector132>:
.globl vector132
vector132:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $132
801073cc:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073d1:	e9 15 f4 ff ff       	jmp    801067eb <alltraps>

801073d6 <vector133>:
.globl vector133
vector133:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $133
801073d8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801073dd:	e9 09 f4 ff ff       	jmp    801067eb <alltraps>

801073e2 <vector134>:
.globl vector134
vector134:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $134
801073e4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801073e9:	e9 fd f3 ff ff       	jmp    801067eb <alltraps>

801073ee <vector135>:
.globl vector135
vector135:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $135
801073f0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801073f5:	e9 f1 f3 ff ff       	jmp    801067eb <alltraps>

801073fa <vector136>:
.globl vector136
vector136:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $136
801073fc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107401:	e9 e5 f3 ff ff       	jmp    801067eb <alltraps>

80107406 <vector137>:
.globl vector137
vector137:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $137
80107408:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010740d:	e9 d9 f3 ff ff       	jmp    801067eb <alltraps>

80107412 <vector138>:
.globl vector138
vector138:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $138
80107414:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107419:	e9 cd f3 ff ff       	jmp    801067eb <alltraps>

8010741e <vector139>:
.globl vector139
vector139:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $139
80107420:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107425:	e9 c1 f3 ff ff       	jmp    801067eb <alltraps>

8010742a <vector140>:
.globl vector140
vector140:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $140
8010742c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107431:	e9 b5 f3 ff ff       	jmp    801067eb <alltraps>

80107436 <vector141>:
.globl vector141
vector141:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $141
80107438:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010743d:	e9 a9 f3 ff ff       	jmp    801067eb <alltraps>

80107442 <vector142>:
.globl vector142
vector142:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $142
80107444:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107449:	e9 9d f3 ff ff       	jmp    801067eb <alltraps>

8010744e <vector143>:
.globl vector143
vector143:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $143
80107450:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107455:	e9 91 f3 ff ff       	jmp    801067eb <alltraps>

8010745a <vector144>:
.globl vector144
vector144:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $144
8010745c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107461:	e9 85 f3 ff ff       	jmp    801067eb <alltraps>

80107466 <vector145>:
.globl vector145
vector145:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $145
80107468:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010746d:	e9 79 f3 ff ff       	jmp    801067eb <alltraps>

80107472 <vector146>:
.globl vector146
vector146:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $146
80107474:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107479:	e9 6d f3 ff ff       	jmp    801067eb <alltraps>

8010747e <vector147>:
.globl vector147
vector147:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $147
80107480:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107485:	e9 61 f3 ff ff       	jmp    801067eb <alltraps>

8010748a <vector148>:
.globl vector148
vector148:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $148
8010748c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107491:	e9 55 f3 ff ff       	jmp    801067eb <alltraps>

80107496 <vector149>:
.globl vector149
vector149:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $149
80107498:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010749d:	e9 49 f3 ff ff       	jmp    801067eb <alltraps>

801074a2 <vector150>:
.globl vector150
vector150:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $150
801074a4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074a9:	e9 3d f3 ff ff       	jmp    801067eb <alltraps>

801074ae <vector151>:
.globl vector151
vector151:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $151
801074b0:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074b5:	e9 31 f3 ff ff       	jmp    801067eb <alltraps>

801074ba <vector152>:
.globl vector152
vector152:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $152
801074bc:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074c1:	e9 25 f3 ff ff       	jmp    801067eb <alltraps>

801074c6 <vector153>:
.globl vector153
vector153:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $153
801074c8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074cd:	e9 19 f3 ff ff       	jmp    801067eb <alltraps>

801074d2 <vector154>:
.globl vector154
vector154:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $154
801074d4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074d9:	e9 0d f3 ff ff       	jmp    801067eb <alltraps>

801074de <vector155>:
.globl vector155
vector155:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $155
801074e0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801074e5:	e9 01 f3 ff ff       	jmp    801067eb <alltraps>

801074ea <vector156>:
.globl vector156
vector156:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $156
801074ec:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801074f1:	e9 f5 f2 ff ff       	jmp    801067eb <alltraps>

801074f6 <vector157>:
.globl vector157
vector157:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $157
801074f8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801074fd:	e9 e9 f2 ff ff       	jmp    801067eb <alltraps>

80107502 <vector158>:
.globl vector158
vector158:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $158
80107504:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107509:	e9 dd f2 ff ff       	jmp    801067eb <alltraps>

8010750e <vector159>:
.globl vector159
vector159:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $159
80107510:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107515:	e9 d1 f2 ff ff       	jmp    801067eb <alltraps>

8010751a <vector160>:
.globl vector160
vector160:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $160
8010751c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107521:	e9 c5 f2 ff ff       	jmp    801067eb <alltraps>

80107526 <vector161>:
.globl vector161
vector161:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $161
80107528:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010752d:	e9 b9 f2 ff ff       	jmp    801067eb <alltraps>

80107532 <vector162>:
.globl vector162
vector162:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $162
80107534:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107539:	e9 ad f2 ff ff       	jmp    801067eb <alltraps>

8010753e <vector163>:
.globl vector163
vector163:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $163
80107540:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107545:	e9 a1 f2 ff ff       	jmp    801067eb <alltraps>

8010754a <vector164>:
.globl vector164
vector164:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $164
8010754c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107551:	e9 95 f2 ff ff       	jmp    801067eb <alltraps>

80107556 <vector165>:
.globl vector165
vector165:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $165
80107558:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010755d:	e9 89 f2 ff ff       	jmp    801067eb <alltraps>

80107562 <vector166>:
.globl vector166
vector166:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $166
80107564:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107569:	e9 7d f2 ff ff       	jmp    801067eb <alltraps>

8010756e <vector167>:
.globl vector167
vector167:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $167
80107570:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107575:	e9 71 f2 ff ff       	jmp    801067eb <alltraps>

8010757a <vector168>:
.globl vector168
vector168:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $168
8010757c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107581:	e9 65 f2 ff ff       	jmp    801067eb <alltraps>

80107586 <vector169>:
.globl vector169
vector169:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $169
80107588:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010758d:	e9 59 f2 ff ff       	jmp    801067eb <alltraps>

80107592 <vector170>:
.globl vector170
vector170:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $170
80107594:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107599:	e9 4d f2 ff ff       	jmp    801067eb <alltraps>

8010759e <vector171>:
.globl vector171
vector171:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $171
801075a0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075a5:	e9 41 f2 ff ff       	jmp    801067eb <alltraps>

801075aa <vector172>:
.globl vector172
vector172:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $172
801075ac:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075b1:	e9 35 f2 ff ff       	jmp    801067eb <alltraps>

801075b6 <vector173>:
.globl vector173
vector173:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $173
801075b8:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075bd:	e9 29 f2 ff ff       	jmp    801067eb <alltraps>

801075c2 <vector174>:
.globl vector174
vector174:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $174
801075c4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075c9:	e9 1d f2 ff ff       	jmp    801067eb <alltraps>

801075ce <vector175>:
.globl vector175
vector175:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $175
801075d0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075d5:	e9 11 f2 ff ff       	jmp    801067eb <alltraps>

801075da <vector176>:
.globl vector176
vector176:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $176
801075dc:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801075e1:	e9 05 f2 ff ff       	jmp    801067eb <alltraps>

801075e6 <vector177>:
.globl vector177
vector177:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $177
801075e8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801075ed:	e9 f9 f1 ff ff       	jmp    801067eb <alltraps>

801075f2 <vector178>:
.globl vector178
vector178:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $178
801075f4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801075f9:	e9 ed f1 ff ff       	jmp    801067eb <alltraps>

801075fe <vector179>:
.globl vector179
vector179:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $179
80107600:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107605:	e9 e1 f1 ff ff       	jmp    801067eb <alltraps>

8010760a <vector180>:
.globl vector180
vector180:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $180
8010760c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107611:	e9 d5 f1 ff ff       	jmp    801067eb <alltraps>

80107616 <vector181>:
.globl vector181
vector181:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $181
80107618:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010761d:	e9 c9 f1 ff ff       	jmp    801067eb <alltraps>

80107622 <vector182>:
.globl vector182
vector182:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $182
80107624:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107629:	e9 bd f1 ff ff       	jmp    801067eb <alltraps>

8010762e <vector183>:
.globl vector183
vector183:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $183
80107630:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107635:	e9 b1 f1 ff ff       	jmp    801067eb <alltraps>

8010763a <vector184>:
.globl vector184
vector184:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $184
8010763c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107641:	e9 a5 f1 ff ff       	jmp    801067eb <alltraps>

80107646 <vector185>:
.globl vector185
vector185:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $185
80107648:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010764d:	e9 99 f1 ff ff       	jmp    801067eb <alltraps>

80107652 <vector186>:
.globl vector186
vector186:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $186
80107654:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107659:	e9 8d f1 ff ff       	jmp    801067eb <alltraps>

8010765e <vector187>:
.globl vector187
vector187:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $187
80107660:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107665:	e9 81 f1 ff ff       	jmp    801067eb <alltraps>

8010766a <vector188>:
.globl vector188
vector188:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $188
8010766c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107671:	e9 75 f1 ff ff       	jmp    801067eb <alltraps>

80107676 <vector189>:
.globl vector189
vector189:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $189
80107678:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010767d:	e9 69 f1 ff ff       	jmp    801067eb <alltraps>

80107682 <vector190>:
.globl vector190
vector190:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $190
80107684:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107689:	e9 5d f1 ff ff       	jmp    801067eb <alltraps>

8010768e <vector191>:
.globl vector191
vector191:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $191
80107690:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107695:	e9 51 f1 ff ff       	jmp    801067eb <alltraps>

8010769a <vector192>:
.globl vector192
vector192:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $192
8010769c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076a1:	e9 45 f1 ff ff       	jmp    801067eb <alltraps>

801076a6 <vector193>:
.globl vector193
vector193:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $193
801076a8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076ad:	e9 39 f1 ff ff       	jmp    801067eb <alltraps>

801076b2 <vector194>:
.globl vector194
vector194:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $194
801076b4:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076b9:	e9 2d f1 ff ff       	jmp    801067eb <alltraps>

801076be <vector195>:
.globl vector195
vector195:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $195
801076c0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076c5:	e9 21 f1 ff ff       	jmp    801067eb <alltraps>

801076ca <vector196>:
.globl vector196
vector196:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $196
801076cc:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076d1:	e9 15 f1 ff ff       	jmp    801067eb <alltraps>

801076d6 <vector197>:
.globl vector197
vector197:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $197
801076d8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801076dd:	e9 09 f1 ff ff       	jmp    801067eb <alltraps>

801076e2 <vector198>:
.globl vector198
vector198:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $198
801076e4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801076e9:	e9 fd f0 ff ff       	jmp    801067eb <alltraps>

801076ee <vector199>:
.globl vector199
vector199:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $199
801076f0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801076f5:	e9 f1 f0 ff ff       	jmp    801067eb <alltraps>

801076fa <vector200>:
.globl vector200
vector200:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $200
801076fc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107701:	e9 e5 f0 ff ff       	jmp    801067eb <alltraps>

80107706 <vector201>:
.globl vector201
vector201:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $201
80107708:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010770d:	e9 d9 f0 ff ff       	jmp    801067eb <alltraps>

80107712 <vector202>:
.globl vector202
vector202:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $202
80107714:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107719:	e9 cd f0 ff ff       	jmp    801067eb <alltraps>

8010771e <vector203>:
.globl vector203
vector203:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $203
80107720:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107725:	e9 c1 f0 ff ff       	jmp    801067eb <alltraps>

8010772a <vector204>:
.globl vector204
vector204:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $204
8010772c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107731:	e9 b5 f0 ff ff       	jmp    801067eb <alltraps>

80107736 <vector205>:
.globl vector205
vector205:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $205
80107738:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010773d:	e9 a9 f0 ff ff       	jmp    801067eb <alltraps>

80107742 <vector206>:
.globl vector206
vector206:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $206
80107744:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107749:	e9 9d f0 ff ff       	jmp    801067eb <alltraps>

8010774e <vector207>:
.globl vector207
vector207:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $207
80107750:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107755:	e9 91 f0 ff ff       	jmp    801067eb <alltraps>

8010775a <vector208>:
.globl vector208
vector208:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $208
8010775c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107761:	e9 85 f0 ff ff       	jmp    801067eb <alltraps>

80107766 <vector209>:
.globl vector209
vector209:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $209
80107768:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010776d:	e9 79 f0 ff ff       	jmp    801067eb <alltraps>

80107772 <vector210>:
.globl vector210
vector210:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $210
80107774:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107779:	e9 6d f0 ff ff       	jmp    801067eb <alltraps>

8010777e <vector211>:
.globl vector211
vector211:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $211
80107780:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107785:	e9 61 f0 ff ff       	jmp    801067eb <alltraps>

8010778a <vector212>:
.globl vector212
vector212:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $212
8010778c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107791:	e9 55 f0 ff ff       	jmp    801067eb <alltraps>

80107796 <vector213>:
.globl vector213
vector213:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $213
80107798:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010779d:	e9 49 f0 ff ff       	jmp    801067eb <alltraps>

801077a2 <vector214>:
.globl vector214
vector214:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $214
801077a4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077a9:	e9 3d f0 ff ff       	jmp    801067eb <alltraps>

801077ae <vector215>:
.globl vector215
vector215:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $215
801077b0:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077b5:	e9 31 f0 ff ff       	jmp    801067eb <alltraps>

801077ba <vector216>:
.globl vector216
vector216:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $216
801077bc:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077c1:	e9 25 f0 ff ff       	jmp    801067eb <alltraps>

801077c6 <vector217>:
.globl vector217
vector217:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $217
801077c8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077cd:	e9 19 f0 ff ff       	jmp    801067eb <alltraps>

801077d2 <vector218>:
.globl vector218
vector218:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $218
801077d4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077d9:	e9 0d f0 ff ff       	jmp    801067eb <alltraps>

801077de <vector219>:
.globl vector219
vector219:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $219
801077e0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801077e5:	e9 01 f0 ff ff       	jmp    801067eb <alltraps>

801077ea <vector220>:
.globl vector220
vector220:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $220
801077ec:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801077f1:	e9 f5 ef ff ff       	jmp    801067eb <alltraps>

801077f6 <vector221>:
.globl vector221
vector221:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $221
801077f8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801077fd:	e9 e9 ef ff ff       	jmp    801067eb <alltraps>

80107802 <vector222>:
.globl vector222
vector222:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $222
80107804:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107809:	e9 dd ef ff ff       	jmp    801067eb <alltraps>

8010780e <vector223>:
.globl vector223
vector223:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $223
80107810:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107815:	e9 d1 ef ff ff       	jmp    801067eb <alltraps>

8010781a <vector224>:
.globl vector224
vector224:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $224
8010781c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107821:	e9 c5 ef ff ff       	jmp    801067eb <alltraps>

80107826 <vector225>:
.globl vector225
vector225:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $225
80107828:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010782d:	e9 b9 ef ff ff       	jmp    801067eb <alltraps>

80107832 <vector226>:
.globl vector226
vector226:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $226
80107834:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107839:	e9 ad ef ff ff       	jmp    801067eb <alltraps>

8010783e <vector227>:
.globl vector227
vector227:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $227
80107840:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107845:	e9 a1 ef ff ff       	jmp    801067eb <alltraps>

8010784a <vector228>:
.globl vector228
vector228:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $228
8010784c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107851:	e9 95 ef ff ff       	jmp    801067eb <alltraps>

80107856 <vector229>:
.globl vector229
vector229:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $229
80107858:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010785d:	e9 89 ef ff ff       	jmp    801067eb <alltraps>

80107862 <vector230>:
.globl vector230
vector230:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $230
80107864:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107869:	e9 7d ef ff ff       	jmp    801067eb <alltraps>

8010786e <vector231>:
.globl vector231
vector231:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $231
80107870:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107875:	e9 71 ef ff ff       	jmp    801067eb <alltraps>

8010787a <vector232>:
.globl vector232
vector232:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $232
8010787c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107881:	e9 65 ef ff ff       	jmp    801067eb <alltraps>

80107886 <vector233>:
.globl vector233
vector233:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $233
80107888:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010788d:	e9 59 ef ff ff       	jmp    801067eb <alltraps>

80107892 <vector234>:
.globl vector234
vector234:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $234
80107894:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107899:	e9 4d ef ff ff       	jmp    801067eb <alltraps>

8010789e <vector235>:
.globl vector235
vector235:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $235
801078a0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078a5:	e9 41 ef ff ff       	jmp    801067eb <alltraps>

801078aa <vector236>:
.globl vector236
vector236:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $236
801078ac:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078b1:	e9 35 ef ff ff       	jmp    801067eb <alltraps>

801078b6 <vector237>:
.globl vector237
vector237:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $237
801078b8:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078bd:	e9 29 ef ff ff       	jmp    801067eb <alltraps>

801078c2 <vector238>:
.globl vector238
vector238:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $238
801078c4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078c9:	e9 1d ef ff ff       	jmp    801067eb <alltraps>

801078ce <vector239>:
.globl vector239
vector239:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $239
801078d0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078d5:	e9 11 ef ff ff       	jmp    801067eb <alltraps>

801078da <vector240>:
.globl vector240
vector240:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $240
801078dc:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801078e1:	e9 05 ef ff ff       	jmp    801067eb <alltraps>

801078e6 <vector241>:
.globl vector241
vector241:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $241
801078e8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801078ed:	e9 f9 ee ff ff       	jmp    801067eb <alltraps>

801078f2 <vector242>:
.globl vector242
vector242:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $242
801078f4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801078f9:	e9 ed ee ff ff       	jmp    801067eb <alltraps>

801078fe <vector243>:
.globl vector243
vector243:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $243
80107900:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107905:	e9 e1 ee ff ff       	jmp    801067eb <alltraps>

8010790a <vector244>:
.globl vector244
vector244:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $244
8010790c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107911:	e9 d5 ee ff ff       	jmp    801067eb <alltraps>

80107916 <vector245>:
.globl vector245
vector245:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $245
80107918:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010791d:	e9 c9 ee ff ff       	jmp    801067eb <alltraps>

80107922 <vector246>:
.globl vector246
vector246:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $246
80107924:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107929:	e9 bd ee ff ff       	jmp    801067eb <alltraps>

8010792e <vector247>:
.globl vector247
vector247:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $247
80107930:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107935:	e9 b1 ee ff ff       	jmp    801067eb <alltraps>

8010793a <vector248>:
.globl vector248
vector248:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $248
8010793c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107941:	e9 a5 ee ff ff       	jmp    801067eb <alltraps>

80107946 <vector249>:
.globl vector249
vector249:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $249
80107948:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010794d:	e9 99 ee ff ff       	jmp    801067eb <alltraps>

80107952 <vector250>:
.globl vector250
vector250:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $250
80107954:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107959:	e9 8d ee ff ff       	jmp    801067eb <alltraps>

8010795e <vector251>:
.globl vector251
vector251:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $251
80107960:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107965:	e9 81 ee ff ff       	jmp    801067eb <alltraps>

8010796a <vector252>:
.globl vector252
vector252:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $252
8010796c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107971:	e9 75 ee ff ff       	jmp    801067eb <alltraps>

80107976 <vector253>:
.globl vector253
vector253:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $253
80107978:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010797d:	e9 69 ee ff ff       	jmp    801067eb <alltraps>

80107982 <vector254>:
.globl vector254
vector254:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $254
80107984:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107989:	e9 5d ee ff ff       	jmp    801067eb <alltraps>

8010798e <vector255>:
.globl vector255
vector255:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $255
80107990:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107995:	e9 51 ee ff ff       	jmp    801067eb <alltraps>

8010799a <lgdt>:
{
8010799a:	55                   	push   %ebp
8010799b:	89 e5                	mov    %esp,%ebp
8010799d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801079a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801079a3:	83 e8 01             	sub    $0x1,%eax
801079a6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079aa:	8b 45 08             	mov    0x8(%ebp),%eax
801079ad:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079b1:	8b 45 08             	mov    0x8(%ebp),%eax
801079b4:	c1 e8 10             	shr    $0x10,%eax
801079b7:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801079bb:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079be:	0f 01 10             	lgdtl  (%eax)
}
801079c1:	90                   	nop
801079c2:	c9                   	leave
801079c3:	c3                   	ret

801079c4 <ltr>:
{
801079c4:	55                   	push   %ebp
801079c5:	89 e5                	mov    %esp,%ebp
801079c7:	83 ec 04             	sub    $0x4,%esp
801079ca:	8b 45 08             	mov    0x8(%ebp),%eax
801079cd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079d1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079d5:	0f 00 d8             	ltr    %eax
}
801079d8:	90                   	nop
801079d9:	c9                   	leave
801079da:	c3                   	ret

801079db <lcr3>:

static inline void
lcr3(uint val)
{
801079db:	55                   	push   %ebp
801079dc:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801079de:	8b 45 08             	mov    0x8(%ebp),%eax
801079e1:	0f 22 d8             	mov    %eax,%cr3
}
801079e4:	90                   	nop
801079e5:	5d                   	pop    %ebp
801079e6:	c3                   	ret

801079e7 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801079e7:	55                   	push   %ebp
801079e8:	89 e5                	mov    %esp,%ebp
801079ea:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801079ed:	e8 ab bf ff ff       	call   8010399d <cpuid>
801079f2:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801079f8:	05 c0 79 19 80       	add    $0x801979c0,%eax
801079fd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a03:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a20:	83 e2 f0             	and    $0xfffffff0,%edx
80107a23:	83 ca 0a             	or     $0xa,%edx
80107a26:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a30:	83 ca 10             	or     $0x10,%edx
80107a33:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a3d:	83 e2 9f             	and    $0xffffff9f,%edx
80107a40:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a4a:	83 ca 80             	or     $0xffffff80,%edx
80107a4d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a53:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a57:	83 ca 0f             	or     $0xf,%edx
80107a5a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a60:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a64:	83 e2 ef             	and    $0xffffffef,%edx
80107a67:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a71:	83 e2 df             	and    $0xffffffdf,%edx
80107a74:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a7e:	83 ca 40             	or     $0x40,%edx
80107a81:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a8b:	83 ca 80             	or     $0xffffff80,%edx
80107a8e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107aa2:	ff ff 
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107aae:	00 00 
80107ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab3:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ac4:	83 e2 f0             	and    $0xfffffff0,%edx
80107ac7:	83 ca 02             	or     $0x2,%edx
80107aca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ada:	83 ca 10             	or     $0x10,%edx
80107add:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aed:	83 e2 9f             	and    $0xffffff9f,%edx
80107af0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b00:	83 ca 80             	or     $0xffffff80,%edx
80107b03:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b13:	83 ca 0f             	or     $0xf,%edx
80107b16:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b26:	83 e2 ef             	and    $0xffffffef,%edx
80107b29:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b39:	83 e2 df             	and    $0xffffffdf,%edx
80107b3c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b45:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b4c:	83 ca 40             	or     $0x40,%edx
80107b4f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b5f:	83 ca 80             	or     $0xffffff80,%edx
80107b62:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107b7c:	ff ff 
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107b88:	00 00 
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b97:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b9e:	83 e2 f0             	and    $0xfffffff0,%edx
80107ba1:	83 ca 0a             	or     $0xa,%edx
80107ba4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bad:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bb4:	83 ca 10             	or     $0x10,%edx
80107bb7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bc7:	83 ca 60             	or     $0x60,%edx
80107bca:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bda:	83 ca 80             	or     $0xffffff80,%edx
80107bdd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bed:	83 ca 0f             	or     $0xf,%edx
80107bf0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c00:	83 e2 ef             	and    $0xffffffef,%edx
80107c03:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c13:	83 e2 df             	and    $0xffffffdf,%edx
80107c16:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c26:	83 ca 40             	or     $0x40,%edx
80107c29:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c32:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c39:	83 ca 80             	or     $0xffffff80,%edx
80107c3c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c56:	ff ff 
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c62:	00 00 
80107c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c67:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c78:	83 e2 f0             	and    $0xfffffff0,%edx
80107c7b:	83 ca 02             	or     $0x2,%edx
80107c7e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c87:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c8e:	83 ca 10             	or     $0x10,%edx
80107c91:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ca1:	83 ca 60             	or     $0x60,%edx
80107ca4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cb4:	83 ca 80             	or     $0xffffff80,%edx
80107cb7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cc7:	83 ca 0f             	or     $0xf,%edx
80107cca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cda:	83 e2 ef             	and    $0xffffffef,%edx
80107cdd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ced:	83 e2 df             	and    $0xffffffdf,%edx
80107cf0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d00:	83 ca 40             	or     $0x40,%edx
80107d03:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d13:	83 ca 80             	or     $0xffffff80,%edx
80107d16:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	83 c0 70             	add    $0x70,%eax
80107d2c:	83 ec 08             	sub    $0x8,%esp
80107d2f:	6a 30                	push   $0x30
80107d31:	50                   	push   %eax
80107d32:	e8 63 fc ff ff       	call   8010799a <lgdt>
80107d37:	83 c4 10             	add    $0x10,%esp
}
80107d3a:	90                   	nop
80107d3b:	c9                   	leave
80107d3c:	c3                   	ret

80107d3d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d3d:	55                   	push   %ebp
80107d3e:	89 e5                	mov    %esp,%ebp
80107d40:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d43:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d46:	c1 e8 16             	shr    $0x16,%eax
80107d49:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d50:	8b 45 08             	mov    0x8(%ebp),%eax
80107d53:	01 d0                	add    %edx,%eax
80107d55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5b:	8b 00                	mov    (%eax),%eax
80107d5d:	83 e0 01             	and    $0x1,%eax
80107d60:	85 c0                	test   %eax,%eax
80107d62:	74 14                	je     80107d78 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d67:	8b 00                	mov    (%eax),%eax
80107d69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d6e:	05 00 00 00 80       	add    $0x80000000,%eax
80107d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d76:	eb 42                	jmp    80107dba <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d7c:	74 0e                	je     80107d8c <walkpgdir+0x4f>
80107d7e:	e8 25 aa ff ff       	call   801027a8 <kalloc>
80107d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d8a:	75 07                	jne    80107d93 <walkpgdir+0x56>
      return 0;
80107d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80107d91:	eb 3e                	jmp    80107dd1 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107d93:	83 ec 04             	sub    $0x4,%esp
80107d96:	68 00 10 00 00       	push   $0x1000
80107d9b:	6a 00                	push   $0x0
80107d9d:	ff 75 f4             	push   -0xc(%ebp)
80107da0:	e8 37 d6 ff ff       	call   801053dc <memset>
80107da5:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dab:	05 00 00 00 80       	add    $0x80000000,%eax
80107db0:	83 c8 07             	or     $0x7,%eax
80107db3:	89 c2                	mov    %eax,%edx
80107db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dbd:	c1 e8 0c             	shr    $0xc,%eax
80107dc0:	25 ff 03 00 00       	and    $0x3ff,%eax
80107dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	01 d0                	add    %edx,%eax
}
80107dd1:	c9                   	leave
80107dd2:	c3                   	ret

80107dd3 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107dd3:	55                   	push   %ebp
80107dd4:	89 e5                	mov    %esp,%ebp
80107dd6:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ddc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107de4:	8b 55 0c             	mov    0xc(%ebp),%edx
80107de7:	8b 45 10             	mov    0x10(%ebp),%eax
80107dea:	01 d0                	add    %edx,%eax
80107dec:	83 e8 01             	sub    $0x1,%eax
80107def:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107df7:	83 ec 04             	sub    $0x4,%esp
80107dfa:	6a 01                	push   $0x1
80107dfc:	ff 75 f4             	push   -0xc(%ebp)
80107dff:	ff 75 08             	push   0x8(%ebp)
80107e02:	e8 36 ff ff ff       	call   80107d3d <walkpgdir>
80107e07:	83 c4 10             	add    $0x10,%esp
80107e0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e0d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e11:	75 07                	jne    80107e1a <mappages+0x47>
      return -1;
80107e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e18:	eb 47                	jmp    80107e61 <mappages+0x8e>
    if(*pte & PTE_P)
80107e1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e1d:	8b 00                	mov    (%eax),%eax
80107e1f:	83 e0 01             	and    $0x1,%eax
80107e22:	85 c0                	test   %eax,%eax
80107e24:	74 0d                	je     80107e33 <mappages+0x60>
      panic("remap");
80107e26:	83 ec 0c             	sub    $0xc,%esp
80107e29:	68 cc b2 10 80       	push   $0x8010b2cc
80107e2e:	e8 76 87 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107e33:	8b 45 18             	mov    0x18(%ebp),%eax
80107e36:	0b 45 14             	or     0x14(%ebp),%eax
80107e39:	83 c8 01             	or     $0x1,%eax
80107e3c:	89 c2                	mov    %eax,%edx
80107e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e41:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e49:	74 10                	je     80107e5b <mappages+0x88>
      break;
    a += PGSIZE;
80107e4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e52:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e59:	eb 9c                	jmp    80107df7 <mappages+0x24>
      break;
80107e5b:	90                   	nop
  }
  return 0;
80107e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e61:	c9                   	leave
80107e62:	c3                   	ret

80107e63 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e63:	55                   	push   %ebp
80107e64:	89 e5                	mov    %esp,%ebp
80107e66:	53                   	push   %ebx
80107e67:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107e6a:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107e71:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107e76:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107e7b:	29 c2                	sub    %eax,%edx
80107e7d:	89 d0                	mov    %edx,%eax
80107e7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107e82:	a1 7c 7a 19 80       	mov    0x80197a7c,%eax
80107e87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107e8a:	8b 15 7c 7a 19 80    	mov    0x80197a7c,%edx
80107e90:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107e95:	01 d0                	add    %edx,%eax
80107e97:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107e9a:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea4:	83 c0 30             	add    $0x30,%eax
80107ea7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107eaa:	89 10                	mov    %edx,(%eax)
80107eac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107eaf:	89 50 04             	mov    %edx,0x4(%eax)
80107eb2:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107eb5:	89 50 08             	mov    %edx,0x8(%eax)
80107eb8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107ebb:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107ebe:	e8 e5 a8 ff ff       	call   801027a8 <kalloc>
80107ec3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ec6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eca:	75 07                	jne    80107ed3 <setupkvm+0x70>
    return 0;
80107ecc:	b8 00 00 00 00       	mov    $0x0,%eax
80107ed1:	eb 78                	jmp    80107f4b <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107ed3:	83 ec 04             	sub    $0x4,%esp
80107ed6:	68 00 10 00 00       	push   $0x1000
80107edb:	6a 00                	push   $0x0
80107edd:	ff 75 f0             	push   -0x10(%ebp)
80107ee0:	e8 f7 d4 ff ff       	call   801053dc <memset>
80107ee5:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ee8:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107eef:	eb 4e                	jmp    80107f3f <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef4:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efa:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	8b 58 08             	mov    0x8(%eax),%ebx
80107f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f06:	8b 40 04             	mov    0x4(%eax),%eax
80107f09:	29 c3                	sub    %eax,%ebx
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	8b 00                	mov    (%eax),%eax
80107f10:	83 ec 0c             	sub    $0xc,%esp
80107f13:	51                   	push   %ecx
80107f14:	52                   	push   %edx
80107f15:	53                   	push   %ebx
80107f16:	50                   	push   %eax
80107f17:	ff 75 f0             	push   -0x10(%ebp)
80107f1a:	e8 b4 fe ff ff       	call   80107dd3 <mappages>
80107f1f:	83 c4 20             	add    $0x20,%esp
80107f22:	85 c0                	test   %eax,%eax
80107f24:	79 15                	jns    80107f3b <setupkvm+0xd8>
      freevm(pgdir);
80107f26:	83 ec 0c             	sub    $0xc,%esp
80107f29:	ff 75 f0             	push   -0x10(%ebp)
80107f2c:	e8 f5 04 00 00       	call   80108426 <freevm>
80107f31:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f34:	b8 00 00 00 00       	mov    $0x0,%eax
80107f39:	eb 10                	jmp    80107f4b <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f3b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f3f:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107f46:	72 a9                	jb     80107ef1 <setupkvm+0x8e>
    }
  return pgdir;
80107f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f4e:	c9                   	leave
80107f4f:	c3                   	ret

80107f50 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f50:	55                   	push   %ebp
80107f51:	89 e5                	mov    %esp,%ebp
80107f53:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f56:	e8 08 ff ff ff       	call   80107e63 <setupkvm>
80107f5b:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  switchkvm();
80107f60:	e8 03 00 00 00       	call   80107f68 <switchkvm>
}
80107f65:	90                   	nop
80107f66:	c9                   	leave
80107f67:	c3                   	ret

80107f68 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f68:	55                   	push   %ebp
80107f69:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107f6b:	a1 bc 79 19 80       	mov    0x801979bc,%eax
80107f70:	05 00 00 00 80       	add    $0x80000000,%eax
80107f75:	50                   	push   %eax
80107f76:	e8 60 fa ff ff       	call   801079db <lcr3>
80107f7b:	83 c4 04             	add    $0x4,%esp
}
80107f7e:	90                   	nop
80107f7f:	c9                   	leave
80107f80:	c3                   	ret

80107f81 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f81:	55                   	push   %ebp
80107f82:	89 e5                	mov    %esp,%ebp
80107f84:	56                   	push   %esi
80107f85:	53                   	push   %ebx
80107f86:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107f89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f8d:	75 0d                	jne    80107f9c <switchuvm+0x1b>
    panic("switchuvm: no process");
80107f8f:	83 ec 0c             	sub    $0xc,%esp
80107f92:	68 d2 b2 10 80       	push   $0x8010b2d2
80107f97:	e8 0d 86 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9f:	8b 40 08             	mov    0x8(%eax),%eax
80107fa2:	85 c0                	test   %eax,%eax
80107fa4:	75 0d                	jne    80107fb3 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107fa6:	83 ec 0c             	sub    $0xc,%esp
80107fa9:	68 e8 b2 10 80       	push   $0x8010b2e8
80107fae:	e8 f6 85 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb6:	8b 40 04             	mov    0x4(%eax),%eax
80107fb9:	85 c0                	test   %eax,%eax
80107fbb:	75 0d                	jne    80107fca <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107fbd:	83 ec 0c             	sub    $0xc,%esp
80107fc0:	68 fd b2 10 80       	push   $0x8010b2fd
80107fc5:	e8 df 85 ff ff       	call   801005a9 <panic>

  pushcli();
80107fca:	e8 02 d3 ff ff       	call   801052d1 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107fcf:	e8 e4 b9 ff ff       	call   801039b8 <mycpu>
80107fd4:	89 c3                	mov    %eax,%ebx
80107fd6:	e8 dd b9 ff ff       	call   801039b8 <mycpu>
80107fdb:	83 c0 08             	add    $0x8,%eax
80107fde:	89 c6                	mov    %eax,%esi
80107fe0:	e8 d3 b9 ff ff       	call   801039b8 <mycpu>
80107fe5:	83 c0 08             	add    $0x8,%eax
80107fe8:	c1 e8 10             	shr    $0x10,%eax
80107feb:	88 45 f7             	mov    %al,-0x9(%ebp)
80107fee:	e8 c5 b9 ff ff       	call   801039b8 <mycpu>
80107ff3:	83 c0 08             	add    $0x8,%eax
80107ff6:	c1 e8 18             	shr    $0x18,%eax
80107ff9:	89 c2                	mov    %eax,%edx
80107ffb:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108002:	67 00 
80108004:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010800b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010800f:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108015:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010801c:	83 e0 f0             	and    $0xfffffff0,%eax
8010801f:	83 c8 09             	or     $0x9,%eax
80108022:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108028:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010802f:	83 c8 10             	or     $0x10,%eax
80108032:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108038:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010803f:	83 e0 9f             	and    $0xffffff9f,%eax
80108042:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108048:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010804f:	83 c8 80             	or     $0xffffff80,%eax
80108052:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108058:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010805f:	83 e0 f0             	and    $0xfffffff0,%eax
80108062:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108068:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010806f:	83 e0 ef             	and    $0xffffffef,%eax
80108072:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108078:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010807f:	83 e0 df             	and    $0xffffffdf,%eax
80108082:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108088:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010808f:	83 c8 40             	or     $0x40,%eax
80108092:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108098:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010809f:	83 e0 7f             	and    $0x7f,%eax
801080a2:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080a8:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801080ae:	e8 05 b9 ff ff       	call   801039b8 <mycpu>
801080b3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080ba:	83 e2 ef             	and    $0xffffffef,%edx
801080bd:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801080c3:	e8 f0 b8 ff ff       	call   801039b8 <mycpu>
801080c8:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801080ce:	8b 45 08             	mov    0x8(%ebp),%eax
801080d1:	8b 40 08             	mov    0x8(%eax),%eax
801080d4:	89 c3                	mov    %eax,%ebx
801080d6:	e8 dd b8 ff ff       	call   801039b8 <mycpu>
801080db:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801080e1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801080e4:	e8 cf b8 ff ff       	call   801039b8 <mycpu>
801080e9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801080ef:	83 ec 0c             	sub    $0xc,%esp
801080f2:	6a 28                	push   $0x28
801080f4:	e8 cb f8 ff ff       	call   801079c4 <ltr>
801080f9:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801080fc:	8b 45 08             	mov    0x8(%ebp),%eax
801080ff:	8b 40 04             	mov    0x4(%eax),%eax
80108102:	05 00 00 00 80       	add    $0x80000000,%eax
80108107:	83 ec 0c             	sub    $0xc,%esp
8010810a:	50                   	push   %eax
8010810b:	e8 cb f8 ff ff       	call   801079db <lcr3>
80108110:	83 c4 10             	add    $0x10,%esp
  popcli();
80108113:	e8 06 d2 ff ff       	call   8010531e <popcli>
}
80108118:	90                   	nop
80108119:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010811c:	5b                   	pop    %ebx
8010811d:	5e                   	pop    %esi
8010811e:	5d                   	pop    %ebp
8010811f:	c3                   	ret

80108120 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108120:	55                   	push   %ebp
80108121:	89 e5                	mov    %esp,%ebp
80108123:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108126:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010812d:	76 0d                	jbe    8010813c <inituvm+0x1c>
    panic("inituvm: more than a page");
8010812f:	83 ec 0c             	sub    $0xc,%esp
80108132:	68 11 b3 10 80       	push   $0x8010b311
80108137:	e8 6d 84 ff ff       	call   801005a9 <panic>
  mem = kalloc();
8010813c:	e8 67 a6 ff ff       	call   801027a8 <kalloc>
80108141:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108144:	83 ec 04             	sub    $0x4,%esp
80108147:	68 00 10 00 00       	push   $0x1000
8010814c:	6a 00                	push   $0x0
8010814e:	ff 75 f4             	push   -0xc(%ebp)
80108151:	e8 86 d2 ff ff       	call   801053dc <memset>
80108156:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815c:	05 00 00 00 80       	add    $0x80000000,%eax
80108161:	83 ec 0c             	sub    $0xc,%esp
80108164:	6a 06                	push   $0x6
80108166:	50                   	push   %eax
80108167:	68 00 10 00 00       	push   $0x1000
8010816c:	6a 00                	push   $0x0
8010816e:	ff 75 08             	push   0x8(%ebp)
80108171:	e8 5d fc ff ff       	call   80107dd3 <mappages>
80108176:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108179:	83 ec 04             	sub    $0x4,%esp
8010817c:	ff 75 10             	push   0x10(%ebp)
8010817f:	ff 75 0c             	push   0xc(%ebp)
80108182:	ff 75 f4             	push   -0xc(%ebp)
80108185:	e8 11 d3 ff ff       	call   8010549b <memmove>
8010818a:	83 c4 10             	add    $0x10,%esp
}
8010818d:	90                   	nop
8010818e:	c9                   	leave
8010818f:	c3                   	ret

80108190 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108190:	55                   	push   %ebp
80108191:	89 e5                	mov    %esp,%ebp
80108193:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108196:	8b 45 0c             	mov    0xc(%ebp),%eax
80108199:	25 ff 0f 00 00       	and    $0xfff,%eax
8010819e:	85 c0                	test   %eax,%eax
801081a0:	74 0d                	je     801081af <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	68 2c b3 10 80       	push   $0x8010b32c
801081aa:	e8 fa 83 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801081af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081b6:	e9 8f 00 00 00       	jmp    8010824a <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801081be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c1:	01 d0                	add    %edx,%eax
801081c3:	83 ec 04             	sub    $0x4,%esp
801081c6:	6a 00                	push   $0x0
801081c8:	50                   	push   %eax
801081c9:	ff 75 08             	push   0x8(%ebp)
801081cc:	e8 6c fb ff ff       	call   80107d3d <walkpgdir>
801081d1:	83 c4 10             	add    $0x10,%esp
801081d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081db:	75 0d                	jne    801081ea <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801081dd:	83 ec 0c             	sub    $0xc,%esp
801081e0:	68 4f b3 10 80       	push   $0x8010b34f
801081e5:	e8 bf 83 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801081ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ed:	8b 00                	mov    (%eax),%eax
801081ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081f7:	8b 45 18             	mov    0x18(%ebp),%eax
801081fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801081fd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108202:	77 0b                	ja     8010820f <loaduvm+0x7f>
      n = sz - i;
80108204:	8b 45 18             	mov    0x18(%ebp),%eax
80108207:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010820a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010820d:	eb 07                	jmp    80108216 <loaduvm+0x86>
    else
      n = PGSIZE;
8010820f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108216:	8b 55 14             	mov    0x14(%ebp),%edx
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	01 d0                	add    %edx,%eax
8010821e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108221:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108227:	ff 75 f0             	push   -0x10(%ebp)
8010822a:	50                   	push   %eax
8010822b:	52                   	push   %edx
8010822c:	ff 75 10             	push   0x10(%ebp)
8010822f:	e8 aa 9c ff ff       	call   80101ede <readi>
80108234:	83 c4 10             	add    $0x10,%esp
80108237:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010823a:	74 07                	je     80108243 <loaduvm+0xb3>
      return -1;
8010823c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108241:	eb 18                	jmp    8010825b <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108243:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	3b 45 18             	cmp    0x18(%ebp),%eax
80108250:	0f 82 65 ff ff ff    	jb     801081bb <loaduvm+0x2b>
  }
  return 0;
80108256:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010825b:	c9                   	leave
8010825c:	c3                   	ret

8010825d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010825d:	55                   	push   %ebp
8010825e:	89 e5                	mov    %esp,%ebp
80108260:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108263:	8b 45 10             	mov    0x10(%ebp),%eax
80108266:	85 c0                	test   %eax,%eax
80108268:	79 0a                	jns    80108274 <allocuvm+0x17>
    return 0;
8010826a:	b8 00 00 00 00       	mov    $0x0,%eax
8010826f:	e9 ec 00 00 00       	jmp    80108360 <allocuvm+0x103>
  if(newsz < oldsz)
80108274:	8b 45 10             	mov    0x10(%ebp),%eax
80108277:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010827a:	73 08                	jae    80108284 <allocuvm+0x27>
    return oldsz;
8010827c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010827f:	e9 dc 00 00 00       	jmp    80108360 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108284:	8b 45 0c             	mov    0xc(%ebp),%eax
80108287:	05 ff 0f 00 00       	add    $0xfff,%eax
8010828c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108291:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108294:	e9 b8 00 00 00       	jmp    80108351 <allocuvm+0xf4>
    mem = kalloc();
80108299:	e8 0a a5 ff ff       	call   801027a8 <kalloc>
8010829e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a5:	75 2e                	jne    801082d5 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801082a7:	83 ec 0c             	sub    $0xc,%esp
801082aa:	68 6d b3 10 80       	push   $0x8010b36d
801082af:	e8 40 81 ff ff       	call   801003f4 <cprintf>
801082b4:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801082b7:	83 ec 04             	sub    $0x4,%esp
801082ba:	ff 75 0c             	push   0xc(%ebp)
801082bd:	ff 75 10             	push   0x10(%ebp)
801082c0:	ff 75 08             	push   0x8(%ebp)
801082c3:	e8 9a 00 00 00       	call   80108362 <deallocuvm>
801082c8:	83 c4 10             	add    $0x10,%esp
      return 0;
801082cb:	b8 00 00 00 00       	mov    $0x0,%eax
801082d0:	e9 8b 00 00 00       	jmp    80108360 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801082d5:	83 ec 04             	sub    $0x4,%esp
801082d8:	68 00 10 00 00       	push   $0x1000
801082dd:	6a 00                	push   $0x0
801082df:	ff 75 f0             	push   -0x10(%ebp)
801082e2:	e8 f5 d0 ff ff       	call   801053dc <memset>
801082e7:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801082ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ed:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801082f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f6:	83 ec 0c             	sub    $0xc,%esp
801082f9:	6a 06                	push   $0x6
801082fb:	52                   	push   %edx
801082fc:	68 00 10 00 00       	push   $0x1000
80108301:	50                   	push   %eax
80108302:	ff 75 08             	push   0x8(%ebp)
80108305:	e8 c9 fa ff ff       	call   80107dd3 <mappages>
8010830a:	83 c4 20             	add    $0x20,%esp
8010830d:	85 c0                	test   %eax,%eax
8010830f:	79 39                	jns    8010834a <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80108311:	83 ec 0c             	sub    $0xc,%esp
80108314:	68 85 b3 10 80       	push   $0x8010b385
80108319:	e8 d6 80 ff ff       	call   801003f4 <cprintf>
8010831e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108321:	83 ec 04             	sub    $0x4,%esp
80108324:	ff 75 0c             	push   0xc(%ebp)
80108327:	ff 75 10             	push   0x10(%ebp)
8010832a:	ff 75 08             	push   0x8(%ebp)
8010832d:	e8 30 00 00 00       	call   80108362 <deallocuvm>
80108332:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108335:	83 ec 0c             	sub    $0xc,%esp
80108338:	ff 75 f0             	push   -0x10(%ebp)
8010833b:	e8 ce a3 ff ff       	call   8010270e <kfree>
80108340:	83 c4 10             	add    $0x10,%esp
      return 0;
80108343:	b8 00 00 00 00       	mov    $0x0,%eax
80108348:	eb 16                	jmp    80108360 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
8010834a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108354:	3b 45 10             	cmp    0x10(%ebp),%eax
80108357:	0f 82 3c ff ff ff    	jb     80108299 <allocuvm+0x3c>
    }
  }
  return newsz;
8010835d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108360:	c9                   	leave
80108361:	c3                   	ret

80108362 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108362:	55                   	push   %ebp
80108363:	89 e5                	mov    %esp,%ebp
80108365:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108368:	8b 45 10             	mov    0x10(%ebp),%eax
8010836b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010836e:	72 08                	jb     80108378 <deallocuvm+0x16>
    return oldsz;
80108370:	8b 45 0c             	mov    0xc(%ebp),%eax
80108373:	e9 ac 00 00 00       	jmp    80108424 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108378:	8b 45 10             	mov    0x10(%ebp),%eax
8010837b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108385:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108388:	e9 88 00 00 00       	jmp    80108415 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010838d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108390:	83 ec 04             	sub    $0x4,%esp
80108393:	6a 00                	push   $0x0
80108395:	50                   	push   %eax
80108396:	ff 75 08             	push   0x8(%ebp)
80108399:	e8 9f f9 ff ff       	call   80107d3d <walkpgdir>
8010839e:	83 c4 10             	add    $0x10,%esp
801083a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801083a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083a8:	75 16                	jne    801083c0 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801083aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ad:	c1 e8 16             	shr    $0x16,%eax
801083b0:	83 c0 01             	add    $0x1,%eax
801083b3:	c1 e0 16             	shl    $0x16,%eax
801083b6:	2d 00 10 00 00       	sub    $0x1000,%eax
801083bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083be:	eb 4e                	jmp    8010840e <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801083c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083c3:	8b 00                	mov    (%eax),%eax
801083c5:	83 e0 01             	and    $0x1,%eax
801083c8:	85 c0                	test   %eax,%eax
801083ca:	74 42                	je     8010840e <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801083cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cf:	8b 00                	mov    (%eax),%eax
801083d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083dd:	75 0d                	jne    801083ec <deallocuvm+0x8a>
        panic("kfree");
801083df:	83 ec 0c             	sub    $0xc,%esp
801083e2:	68 a1 b3 10 80       	push   $0x8010b3a1
801083e7:	e8 bd 81 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
801083ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ef:	05 00 00 00 80       	add    $0x80000000,%eax
801083f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083f7:	83 ec 0c             	sub    $0xc,%esp
801083fa:	ff 75 e8             	push   -0x18(%ebp)
801083fd:	e8 0c a3 ff ff       	call   8010270e <kfree>
80108402:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108408:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010840e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010841b:	0f 82 6c ff ff ff    	jb     8010838d <deallocuvm+0x2b>
    }
  }
  return newsz;
80108421:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108424:	c9                   	leave
80108425:	c3                   	ret

80108426 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108426:	55                   	push   %ebp
80108427:	89 e5                	mov    %esp,%ebp
80108429:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010842c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108430:	75 0d                	jne    8010843f <freevm+0x19>
    panic("freevm: no pgdir");
80108432:	83 ec 0c             	sub    $0xc,%esp
80108435:	68 a7 b3 10 80       	push   $0x8010b3a7
8010843a:	e8 6a 81 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010843f:	83 ec 04             	sub    $0x4,%esp
80108442:	6a 00                	push   $0x0
80108444:	68 00 00 00 80       	push   $0x80000000
80108449:	ff 75 08             	push   0x8(%ebp)
8010844c:	e8 11 ff ff ff       	call   80108362 <deallocuvm>
80108451:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010845b:	eb 48                	jmp    801084a5 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108467:	8b 45 08             	mov    0x8(%ebp),%eax
8010846a:	01 d0                	add    %edx,%eax
8010846c:	8b 00                	mov    (%eax),%eax
8010846e:	83 e0 01             	and    $0x1,%eax
80108471:	85 c0                	test   %eax,%eax
80108473:	74 2c                	je     801084a1 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108478:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010847f:	8b 45 08             	mov    0x8(%ebp),%eax
80108482:	01 d0                	add    %edx,%eax
80108484:	8b 00                	mov    (%eax),%eax
80108486:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010848b:	05 00 00 00 80       	add    $0x80000000,%eax
80108490:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108493:	83 ec 0c             	sub    $0xc,%esp
80108496:	ff 75 f0             	push   -0x10(%ebp)
80108499:	e8 70 a2 ff ff       	call   8010270e <kfree>
8010849e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084a5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801084ac:	76 af                	jbe    8010845d <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801084ae:	83 ec 0c             	sub    $0xc,%esp
801084b1:	ff 75 08             	push   0x8(%ebp)
801084b4:	e8 55 a2 ff ff       	call   8010270e <kfree>
801084b9:	83 c4 10             	add    $0x10,%esp
}
801084bc:	90                   	nop
801084bd:	c9                   	leave
801084be:	c3                   	ret

801084bf <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801084bf:	55                   	push   %ebp
801084c0:	89 e5                	mov    %esp,%ebp
801084c2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084c5:	83 ec 04             	sub    $0x4,%esp
801084c8:	6a 00                	push   $0x0
801084ca:	ff 75 0c             	push   0xc(%ebp)
801084cd:	ff 75 08             	push   0x8(%ebp)
801084d0:	e8 68 f8 ff ff       	call   80107d3d <walkpgdir>
801084d5:	83 c4 10             	add    $0x10,%esp
801084d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084df:	75 0d                	jne    801084ee <clearpteu+0x2f>
    panic("clearpteu");
801084e1:	83 ec 0c             	sub    $0xc,%esp
801084e4:	68 b8 b3 10 80       	push   $0x8010b3b8
801084e9:	e8 bb 80 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801084ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f1:	8b 00                	mov    (%eax),%eax
801084f3:	83 e0 fb             	and    $0xfffffffb,%eax
801084f6:	89 c2                	mov    %eax,%edx
801084f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fb:	89 10                	mov    %edx,(%eax)
}
801084fd:	90                   	nop
801084fe:	c9                   	leave
801084ff:	c3                   	ret

80108500 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108500:	55                   	push   %ebp
80108501:	89 e5                	mov    %esp,%ebp
80108503:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108506:	e8 58 f9 ff ff       	call   80107e63 <setupkvm>
8010850b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010850e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108512:	75 0a                	jne    8010851e <copyuvm+0x1e>
    return 0;
80108514:	b8 00 00 00 00       	mov    $0x0,%eax
80108519:	e9 eb 00 00 00       	jmp    80108609 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010851e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108525:	e9 b7 00 00 00       	jmp    801085e1 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	83 ec 04             	sub    $0x4,%esp
80108530:	6a 00                	push   $0x0
80108532:	50                   	push   %eax
80108533:	ff 75 08             	push   0x8(%ebp)
80108536:	e8 02 f8 ff ff       	call   80107d3d <walkpgdir>
8010853b:	83 c4 10             	add    $0x10,%esp
8010853e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108541:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108545:	75 0d                	jne    80108554 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108547:	83 ec 0c             	sub    $0xc,%esp
8010854a:	68 c2 b3 10 80       	push   $0x8010b3c2
8010854f:	e8 55 80 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108554:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108557:	8b 00                	mov    (%eax),%eax
80108559:	83 e0 01             	and    $0x1,%eax
8010855c:	85 c0                	test   %eax,%eax
8010855e:	75 0d                	jne    8010856d <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108560:	83 ec 0c             	sub    $0xc,%esp
80108563:	68 dc b3 10 80       	push   $0x8010b3dc
80108568:	e8 3c 80 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010856d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108570:	8b 00                	mov    (%eax),%eax
80108572:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108577:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010857a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010857d:	8b 00                	mov    (%eax),%eax
8010857f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108584:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108587:	e8 1c a2 ff ff       	call   801027a8 <kalloc>
8010858c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010858f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108593:	74 5d                	je     801085f2 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108595:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108598:	05 00 00 00 80       	add    $0x80000000,%eax
8010859d:	83 ec 04             	sub    $0x4,%esp
801085a0:	68 00 10 00 00       	push   $0x1000
801085a5:	50                   	push   %eax
801085a6:	ff 75 e0             	push   -0x20(%ebp)
801085a9:	e8 ed ce ff ff       	call   8010549b <memmove>
801085ae:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801085b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801085b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801085b7:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801085bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c0:	83 ec 0c             	sub    $0xc,%esp
801085c3:	52                   	push   %edx
801085c4:	51                   	push   %ecx
801085c5:	68 00 10 00 00       	push   $0x1000
801085ca:	50                   	push   %eax
801085cb:	ff 75 f0             	push   -0x10(%ebp)
801085ce:	e8 00 f8 ff ff       	call   80107dd3 <mappages>
801085d3:	83 c4 20             	add    $0x20,%esp
801085d6:	85 c0                	test   %eax,%eax
801085d8:	78 1b                	js     801085f5 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
801085da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085e7:	0f 82 3d ff ff ff    	jb     8010852a <copyuvm+0x2a>
      goto bad;
  }
  return d;
801085ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f0:	eb 17                	jmp    80108609 <copyuvm+0x109>
      goto bad;
801085f2:	90                   	nop
801085f3:	eb 01                	jmp    801085f6 <copyuvm+0xf6>
      goto bad;
801085f5:	90                   	nop

bad:
  freevm(d);
801085f6:	83 ec 0c             	sub    $0xc,%esp
801085f9:	ff 75 f0             	push   -0x10(%ebp)
801085fc:	e8 25 fe ff ff       	call   80108426 <freevm>
80108601:	83 c4 10             	add    $0x10,%esp
  return 0;
80108604:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108609:	c9                   	leave
8010860a:	c3                   	ret

8010860b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010860b:	55                   	push   %ebp
8010860c:	89 e5                	mov    %esp,%ebp
8010860e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108611:	83 ec 04             	sub    $0x4,%esp
80108614:	6a 00                	push   $0x0
80108616:	ff 75 0c             	push   0xc(%ebp)
80108619:	ff 75 08             	push   0x8(%ebp)
8010861c:	e8 1c f7 ff ff       	call   80107d3d <walkpgdir>
80108621:	83 c4 10             	add    $0x10,%esp
80108624:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862a:	8b 00                	mov    (%eax),%eax
8010862c:	83 e0 01             	and    $0x1,%eax
8010862f:	85 c0                	test   %eax,%eax
80108631:	75 07                	jne    8010863a <uva2ka+0x2f>
    return 0;
80108633:	b8 00 00 00 00       	mov    $0x0,%eax
80108638:	eb 22                	jmp    8010865c <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
8010863a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863d:	8b 00                	mov    (%eax),%eax
8010863f:	83 e0 04             	and    $0x4,%eax
80108642:	85 c0                	test   %eax,%eax
80108644:	75 07                	jne    8010864d <uva2ka+0x42>
    return 0;
80108646:	b8 00 00 00 00       	mov    $0x0,%eax
8010864b:	eb 0f                	jmp    8010865c <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010864d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108650:	8b 00                	mov    (%eax),%eax
80108652:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108657:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010865c:	c9                   	leave
8010865d:	c3                   	ret

8010865e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010865e:	55                   	push   %ebp
8010865f:	89 e5                	mov    %esp,%ebp
80108661:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108664:	8b 45 10             	mov    0x10(%ebp),%eax
80108667:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010866a:	eb 7f                	jmp    801086eb <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010866c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010866f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108674:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108677:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867a:	83 ec 08             	sub    $0x8,%esp
8010867d:	50                   	push   %eax
8010867e:	ff 75 08             	push   0x8(%ebp)
80108681:	e8 85 ff ff ff       	call   8010860b <uva2ka>
80108686:	83 c4 10             	add    $0x10,%esp
80108689:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010868c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108690:	75 07                	jne    80108699 <copyout+0x3b>
      return -1;
80108692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108697:	eb 61                	jmp    801086fa <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108699:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010869c:	2b 45 0c             	sub    0xc(%ebp),%eax
8010869f:	05 00 10 00 00       	add    $0x1000,%eax
801086a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086aa:	39 45 14             	cmp    %eax,0x14(%ebp)
801086ad:	73 06                	jae    801086b5 <copyout+0x57>
      n = len;
801086af:	8b 45 14             	mov    0x14(%ebp),%eax
801086b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b8:	2b 45 ec             	sub    -0x14(%ebp),%eax
801086bb:	89 c2                	mov    %eax,%edx
801086bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086c0:	01 d0                	add    %edx,%eax
801086c2:	83 ec 04             	sub    $0x4,%esp
801086c5:	ff 75 f0             	push   -0x10(%ebp)
801086c8:	ff 75 f4             	push   -0xc(%ebp)
801086cb:	50                   	push   %eax
801086cc:	e8 ca cd ff ff       	call   8010549b <memmove>
801086d1:	83 c4 10             	add    $0x10,%esp
    len -= n;
801086d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d7:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086dd:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e3:	05 00 10 00 00       	add    $0x1000,%eax
801086e8:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801086eb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086ef:	0f 85 77 ff ff ff    	jne    8010866c <copyout+0xe>
  }
  return 0;
801086f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086fa:	c9                   	leave
801086fb:	c3                   	ret

801086fc <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801086fc:	55                   	push   %ebp
801086fd:	89 e5                	mov    %esp,%ebp
801086ff:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108702:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108709:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010870c:	8b 40 08             	mov    0x8(%eax),%eax
8010870f:	05 00 00 00 80       	add    $0x80000000,%eax
80108714:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108717:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108721:	8b 40 24             	mov    0x24(%eax),%eax
80108724:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108729:	c7 05 74 7a 19 80 00 	movl   $0x0,0x80197a74
80108730:	00 00 00 

  while(i<madt->len){
80108733:	e9 bc 00 00 00       	jmp    801087f4 <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
80108738:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010873b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010873e:	01 d0                	add    %edx,%eax
80108740:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108746:	0f b6 00             	movzbl (%eax),%eax
80108749:	0f b6 c0             	movzbl %al,%eax
8010874c:	83 f8 05             	cmp    $0x5,%eax
8010874f:	0f 87 9f 00 00 00    	ja     801087f4 <mpinit_uefi+0xf8>
80108755:	8b 04 85 f8 b3 10 80 	mov    -0x7fef4c08(,%eax,4),%eax
8010875c:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010875e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108761:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108764:	a1 74 7a 19 80       	mov    0x80197a74,%eax
80108769:	85 c0                	test   %eax,%eax
8010876b:	7f 28                	jg     80108795 <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010876d:	8b 15 74 7a 19 80    	mov    0x80197a74,%edx
80108773:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108776:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010877a:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108780:	81 c2 c0 79 19 80    	add    $0x801979c0,%edx
80108786:	88 02                	mov    %al,(%edx)
          ncpu++;
80108788:	a1 74 7a 19 80       	mov    0x80197a74,%eax
8010878d:	83 c0 01             	add    $0x1,%eax
80108790:	a3 74 7a 19 80       	mov    %eax,0x80197a74
        }
        i += lapic_entry->record_len;
80108795:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108798:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010879c:	0f b6 c0             	movzbl %al,%eax
8010879f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087a2:	eb 50                	jmp    801087f4 <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801087a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801087aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087ad:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801087b1:	a2 78 7a 19 80       	mov    %al,0x80197a78
        i += ioapic->record_len;
801087b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087b9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087bd:	0f b6 c0             	movzbl %al,%eax
801087c0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087c3:	eb 2f                	jmp    801087f4 <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801087c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801087cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087ce:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087d2:	0f b6 c0             	movzbl %al,%eax
801087d5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087d8:	eb 1a                	jmp    801087f4 <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801087da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801087e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801087e7:	0f b6 c0             	movzbl %al,%eax
801087ea:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801087ed:	eb 05                	jmp    801087f4 <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
801087ef:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801087f3:	90                   	nop
  while(i<madt->len){
801087f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f7:	8b 40 04             	mov    0x4(%eax),%eax
801087fa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801087fd:	0f 82 35 ff ff ff    	jb     80108738 <mpinit_uefi+0x3c>
    }
  }

}
80108803:	90                   	nop
80108804:	90                   	nop
80108805:	c9                   	leave
80108806:	c3                   	ret

80108807 <inb>:
{
80108807:	55                   	push   %ebp
80108808:	89 e5                	mov    %esp,%ebp
8010880a:	83 ec 14             	sub    $0x14,%esp
8010880d:	8b 45 08             	mov    0x8(%ebp),%eax
80108810:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108814:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108818:	89 c2                	mov    %eax,%edx
8010881a:	ec                   	in     (%dx),%al
8010881b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010881e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108822:	c9                   	leave
80108823:	c3                   	ret

80108824 <outb>:
{
80108824:	55                   	push   %ebp
80108825:	89 e5                	mov    %esp,%ebp
80108827:	83 ec 08             	sub    $0x8,%esp
8010882a:	8b 55 08             	mov    0x8(%ebp),%edx
8010882d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108830:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108834:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108837:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010883b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010883f:	ee                   	out    %al,(%dx)
}
80108840:	90                   	nop
80108841:	c9                   	leave
80108842:	c3                   	ret

80108843 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108843:	55                   	push   %ebp
80108844:	89 e5                	mov    %esp,%ebp
80108846:	83 ec 28             	sub    $0x28,%esp
80108849:	8b 45 08             	mov    0x8(%ebp),%eax
8010884c:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010884f:	6a 00                	push   $0x0
80108851:	68 fa 03 00 00       	push   $0x3fa
80108856:	e8 c9 ff ff ff       	call   80108824 <outb>
8010885b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010885e:	68 80 00 00 00       	push   $0x80
80108863:	68 fb 03 00 00       	push   $0x3fb
80108868:	e8 b7 ff ff ff       	call   80108824 <outb>
8010886d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108870:	6a 0c                	push   $0xc
80108872:	68 f8 03 00 00       	push   $0x3f8
80108877:	e8 a8 ff ff ff       	call   80108824 <outb>
8010887c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010887f:	6a 00                	push   $0x0
80108881:	68 f9 03 00 00       	push   $0x3f9
80108886:	e8 99 ff ff ff       	call   80108824 <outb>
8010888b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010888e:	6a 03                	push   $0x3
80108890:	68 fb 03 00 00       	push   $0x3fb
80108895:	e8 8a ff ff ff       	call   80108824 <outb>
8010889a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010889d:	6a 00                	push   $0x0
8010889f:	68 fc 03 00 00       	push   $0x3fc
801088a4:	e8 7b ff ff ff       	call   80108824 <outb>
801088a9:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801088ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088b3:	eb 11                	jmp    801088c6 <uart_debug+0x83>
801088b5:	83 ec 0c             	sub    $0xc,%esp
801088b8:	6a 0a                	push   $0xa
801088ba:	e8 7a a2 ff ff       	call   80102b39 <microdelay>
801088bf:	83 c4 10             	add    $0x10,%esp
801088c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088c6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801088ca:	7f 1a                	jg     801088e6 <uart_debug+0xa3>
801088cc:	83 ec 0c             	sub    $0xc,%esp
801088cf:	68 fd 03 00 00       	push   $0x3fd
801088d4:	e8 2e ff ff ff       	call   80108807 <inb>
801088d9:	83 c4 10             	add    $0x10,%esp
801088dc:	0f b6 c0             	movzbl %al,%eax
801088df:	83 e0 20             	and    $0x20,%eax
801088e2:	85 c0                	test   %eax,%eax
801088e4:	74 cf                	je     801088b5 <uart_debug+0x72>
  outb(COM1+0, p);
801088e6:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801088ea:	0f b6 c0             	movzbl %al,%eax
801088ed:	83 ec 08             	sub    $0x8,%esp
801088f0:	50                   	push   %eax
801088f1:	68 f8 03 00 00       	push   $0x3f8
801088f6:	e8 29 ff ff ff       	call   80108824 <outb>
801088fb:	83 c4 10             	add    $0x10,%esp
}
801088fe:	90                   	nop
801088ff:	c9                   	leave
80108900:	c3                   	ret

80108901 <uart_debugs>:

void uart_debugs(char *p){
80108901:	55                   	push   %ebp
80108902:	89 e5                	mov    %esp,%ebp
80108904:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108907:	eb 1b                	jmp    80108924 <uart_debugs+0x23>
    uart_debug(*p++);
80108909:	8b 45 08             	mov    0x8(%ebp),%eax
8010890c:	8d 50 01             	lea    0x1(%eax),%edx
8010890f:	89 55 08             	mov    %edx,0x8(%ebp)
80108912:	0f b6 00             	movzbl (%eax),%eax
80108915:	0f be c0             	movsbl %al,%eax
80108918:	83 ec 0c             	sub    $0xc,%esp
8010891b:	50                   	push   %eax
8010891c:	e8 22 ff ff ff       	call   80108843 <uart_debug>
80108921:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108924:	8b 45 08             	mov    0x8(%ebp),%eax
80108927:	0f b6 00             	movzbl (%eax),%eax
8010892a:	84 c0                	test   %al,%al
8010892c:	75 db                	jne    80108909 <uart_debugs+0x8>
  }
}
8010892e:	90                   	nop
8010892f:	90                   	nop
80108930:	c9                   	leave
80108931:	c3                   	ret

80108932 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108932:	55                   	push   %ebp
80108933:	89 e5                	mov    %esp,%ebp
80108935:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108938:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010893f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108942:	8b 50 14             	mov    0x14(%eax),%edx
80108945:	8b 40 10             	mov    0x10(%eax),%eax
80108948:	a3 7c 7a 19 80       	mov    %eax,0x80197a7c
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010894d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108950:	8b 50 1c             	mov    0x1c(%eax),%edx
80108953:	8b 40 18             	mov    0x18(%eax),%eax
80108956:	a3 84 7a 19 80       	mov    %eax,0x80197a84
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010895b:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80108960:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108965:	29 c2                	sub    %eax,%edx
80108967:	89 15 80 7a 19 80    	mov    %edx,0x80197a80
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010896d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108970:	8b 50 24             	mov    0x24(%eax),%edx
80108973:	8b 40 20             	mov    0x20(%eax),%eax
80108976:	a3 88 7a 19 80       	mov    %eax,0x80197a88
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010897b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010897e:	8b 50 2c             	mov    0x2c(%eax),%edx
80108981:	8b 40 28             	mov    0x28(%eax),%eax
80108984:	a3 8c 7a 19 80       	mov    %eax,0x80197a8c
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108989:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010898c:	8b 50 34             	mov    0x34(%eax),%edx
8010898f:	8b 40 30             	mov    0x30(%eax),%eax
80108992:	a3 90 7a 19 80       	mov    %eax,0x80197a90
}
80108997:	90                   	nop
80108998:	c9                   	leave
80108999:	c3                   	ret

8010899a <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010899a:	55                   	push   %ebp
8010899b:	89 e5                	mov    %esp,%ebp
8010899d:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801089a0:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
801089a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801089a9:	0f af d0             	imul   %eax,%edx
801089ac:	8b 45 08             	mov    0x8(%ebp),%eax
801089af:	01 d0                	add    %edx,%eax
801089b1:	c1 e0 02             	shl    $0x2,%eax
801089b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801089b7:	8b 15 80 7a 19 80    	mov    0x80197a80,%edx
801089bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089c0:	01 d0                	add    %edx,%eax
801089c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801089c5:	8b 45 10             	mov    0x10(%ebp),%eax
801089c8:	0f b6 10             	movzbl (%eax),%edx
801089cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801089ce:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801089d0:	8b 45 10             	mov    0x10(%ebp),%eax
801089d3:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801089d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801089da:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801089dd:	8b 45 10             	mov    0x10(%ebp),%eax
801089e0:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801089e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801089e7:	88 50 02             	mov    %dl,0x2(%eax)
}
801089ea:	90                   	nop
801089eb:	c9                   	leave
801089ec:	c3                   	ret

801089ed <graphic_scroll_up>:

void graphic_scroll_up(int height){
801089ed:	55                   	push   %ebp
801089ee:	89 e5                	mov    %esp,%ebp
801089f0:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801089f3:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
801089f9:	8b 45 08             	mov    0x8(%ebp),%eax
801089fc:	0f af c2             	imul   %edx,%eax
801089ff:	c1 e0 02             	shl    $0x2,%eax
80108a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108a05:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
80108a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0e:	29 c2                	sub    %eax,%edx
80108a10:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
80108a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a19:	01 c8                	add    %ecx,%eax
80108a1b:	89 c1                	mov    %eax,%ecx
80108a1d:	a1 80 7a 19 80       	mov    0x80197a80,%eax
80108a22:	83 ec 04             	sub    $0x4,%esp
80108a25:	52                   	push   %edx
80108a26:	51                   	push   %ecx
80108a27:	50                   	push   %eax
80108a28:	e8 6e ca ff ff       	call   8010549b <memmove>
80108a2d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a33:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
80108a39:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
80108a3f:	01 d1                	add    %edx,%ecx
80108a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a44:	29 d1                	sub    %edx,%ecx
80108a46:	89 ca                	mov    %ecx,%edx
80108a48:	83 ec 04             	sub    $0x4,%esp
80108a4b:	50                   	push   %eax
80108a4c:	6a 00                	push   $0x0
80108a4e:	52                   	push   %edx
80108a4f:	e8 88 c9 ff ff       	call   801053dc <memset>
80108a54:	83 c4 10             	add    $0x10,%esp
}
80108a57:	90                   	nop
80108a58:	c9                   	leave
80108a59:	c3                   	ret

80108a5a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108a5a:	55                   	push   %ebp
80108a5b:	89 e5                	mov    %esp,%ebp
80108a5d:	53                   	push   %ebx
80108a5e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108a61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a68:	e9 b1 00 00 00       	jmp    80108b1e <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108a6d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108a74:	e9 97 00 00 00       	jmp    80108b10 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108a79:	8b 45 10             	mov    0x10(%ebp),%eax
80108a7c:	83 e8 20             	sub    $0x20,%eax
80108a7f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a85:	01 d0                	add    %edx,%eax
80108a87:	0f b7 84 00 20 b4 10 	movzwl -0x7fef4be0(%eax,%eax,1),%eax
80108a8e:	80 
80108a8f:	0f b7 d0             	movzwl %ax,%edx
80108a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a95:	bb 01 00 00 00       	mov    $0x1,%ebx
80108a9a:	89 c1                	mov    %eax,%ecx
80108a9c:	d3 e3                	shl    %cl,%ebx
80108a9e:	89 d8                	mov    %ebx,%eax
80108aa0:	21 d0                	and    %edx,%eax
80108aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa8:	ba 01 00 00 00       	mov    $0x1,%edx
80108aad:	89 c1                	mov    %eax,%ecx
80108aaf:	d3 e2                	shl    %cl,%edx
80108ab1:	89 d0                	mov    %edx,%eax
80108ab3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108ab6:	75 2b                	jne    80108ae3 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
80108abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abe:	01 c2                	add    %eax,%edx
80108ac0:	b8 0e 00 00 00       	mov    $0xe,%eax
80108ac5:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108ac8:	89 c1                	mov    %eax,%ecx
80108aca:	8b 45 08             	mov    0x8(%ebp),%eax
80108acd:	01 c8                	add    %ecx,%eax
80108acf:	83 ec 04             	sub    $0x4,%esp
80108ad2:	68 00 f5 10 80       	push   $0x8010f500
80108ad7:	52                   	push   %edx
80108ad8:	50                   	push   %eax
80108ad9:	e8 bc fe ff ff       	call   8010899a <graphic_draw_pixel>
80108ade:	83 c4 10             	add    $0x10,%esp
80108ae1:	eb 29                	jmp    80108b0c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae9:	01 c2                	add    %eax,%edx
80108aeb:	b8 0e 00 00 00       	mov    $0xe,%eax
80108af0:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108af3:	89 c1                	mov    %eax,%ecx
80108af5:	8b 45 08             	mov    0x8(%ebp),%eax
80108af8:	01 c8                	add    %ecx,%eax
80108afa:	83 ec 04             	sub    $0x4,%esp
80108afd:	68 94 7a 19 80       	push   $0x80197a94
80108b02:	52                   	push   %edx
80108b03:	50                   	push   %eax
80108b04:	e8 91 fe ff ff       	call   8010899a <graphic_draw_pixel>
80108b09:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108b0c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b14:	0f 89 5f ff ff ff    	jns    80108a79 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108b1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b1e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108b22:	0f 8e 45 ff ff ff    	jle    80108a6d <font_render+0x13>
      }
    }
  }
}
80108b28:	90                   	nop
80108b29:	90                   	nop
80108b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b2d:	c9                   	leave
80108b2e:	c3                   	ret

80108b2f <font_render_string>:

void font_render_string(char *string,int row){
80108b2f:	55                   	push   %ebp
80108b30:	89 e5                	mov    %esp,%ebp
80108b32:	53                   	push   %ebx
80108b33:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108b3d:	eb 33                	jmp    80108b72 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b42:	8b 45 08             	mov    0x8(%ebp),%eax
80108b45:	01 d0                	add    %edx,%eax
80108b47:	0f b6 00             	movzbl (%eax),%eax
80108b4a:	0f be d8             	movsbl %al,%ebx
80108b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b50:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b56:	89 d0                	mov    %edx,%eax
80108b58:	c1 e0 04             	shl    $0x4,%eax
80108b5b:	29 d0                	sub    %edx,%eax
80108b5d:	83 c0 02             	add    $0x2,%eax
80108b60:	83 ec 04             	sub    $0x4,%esp
80108b63:	53                   	push   %ebx
80108b64:	51                   	push   %ecx
80108b65:	50                   	push   %eax
80108b66:	e8 ef fe ff ff       	call   80108a5a <font_render>
80108b6b:	83 c4 10             	add    $0x10,%esp
    i++;
80108b6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b75:	8b 45 08             	mov    0x8(%ebp),%eax
80108b78:	01 d0                	add    %edx,%eax
80108b7a:	0f b6 00             	movzbl (%eax),%eax
80108b7d:	84 c0                	test   %al,%al
80108b7f:	74 06                	je     80108b87 <font_render_string+0x58>
80108b81:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108b85:	7e b8                	jle    80108b3f <font_render_string+0x10>
  }
}
80108b87:	90                   	nop
80108b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b8b:	c9                   	leave
80108b8c:	c3                   	ret

80108b8d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108b8d:	55                   	push   %ebp
80108b8e:	89 e5                	mov    %esp,%ebp
80108b90:	53                   	push   %ebx
80108b91:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108b94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b9b:	eb 6b                	jmp    80108c08 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108b9d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ba4:	eb 58                	jmp    80108bfe <pci_init+0x71>
      for(int k=0;k<8;k++){
80108ba6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108bad:	eb 45                	jmp    80108bf4 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108baf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108bb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb8:	83 ec 0c             	sub    $0xc,%esp
80108bbb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108bbe:	53                   	push   %ebx
80108bbf:	6a 00                	push   $0x0
80108bc1:	51                   	push   %ecx
80108bc2:	52                   	push   %edx
80108bc3:	50                   	push   %eax
80108bc4:	e8 b0 00 00 00       	call   80108c79 <pci_access_config>
80108bc9:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108bcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bcf:	0f b7 c0             	movzwl %ax,%eax
80108bd2:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108bd7:	74 17                	je     80108bf0 <pci_init+0x63>
        pci_init_device(i,j,k);
80108bd9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be2:	83 ec 04             	sub    $0x4,%esp
80108be5:	51                   	push   %ecx
80108be6:	52                   	push   %edx
80108be7:	50                   	push   %eax
80108be8:	e8 37 01 00 00       	call   80108d24 <pci_init_device>
80108bed:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108bf0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108bf4:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108bf8:	7e b5                	jle    80108baf <pci_init+0x22>
    for(int j=0;j<32;j++){
80108bfa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108bfe:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108c02:	7e a2                	jle    80108ba6 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108c04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c08:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c0f:	7e 8c                	jle    80108b9d <pci_init+0x10>
      }
      }
    }
  }
}
80108c11:	90                   	nop
80108c12:	90                   	nop
80108c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c16:	c9                   	leave
80108c17:	c3                   	ret

80108c18 <pci_write_config>:

void pci_write_config(uint config){
80108c18:	55                   	push   %ebp
80108c19:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c1e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108c23:	89 c0                	mov    %eax,%eax
80108c25:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c26:	90                   	nop
80108c27:	5d                   	pop    %ebp
80108c28:	c3                   	ret

80108c29 <pci_write_data>:

void pci_write_data(uint config){
80108c29:	55                   	push   %ebp
80108c2a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c2f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c34:	89 c0                	mov    %eax,%eax
80108c36:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c37:	90                   	nop
80108c38:	5d                   	pop    %ebp
80108c39:	c3                   	ret

80108c3a <pci_read_config>:
uint pci_read_config(){
80108c3a:	55                   	push   %ebp
80108c3b:	89 e5                	mov    %esp,%ebp
80108c3d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108c40:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c45:	ed                   	in     (%dx),%eax
80108c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108c49:	83 ec 0c             	sub    $0xc,%esp
80108c4c:	68 c8 00 00 00       	push   $0xc8
80108c51:	e8 e3 9e ff ff       	call   80102b39 <microdelay>
80108c56:	83 c4 10             	add    $0x10,%esp
  return data;
80108c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108c5c:	c9                   	leave
80108c5d:	c3                   	ret

80108c5e <pci_test>:


void pci_test(){
80108c5e:	55                   	push   %ebp
80108c5f:	89 e5                	mov    %esp,%ebp
80108c61:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108c64:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108c6b:	ff 75 fc             	push   -0x4(%ebp)
80108c6e:	e8 a5 ff ff ff       	call   80108c18 <pci_write_config>
80108c73:	83 c4 04             	add    $0x4,%esp
}
80108c76:	90                   	nop
80108c77:	c9                   	leave
80108c78:	c3                   	ret

80108c79 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108c79:	55                   	push   %ebp
80108c7a:	89 e5                	mov    %esp,%ebp
80108c7c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c82:	c1 e0 10             	shl    $0x10,%eax
80108c85:	25 00 00 ff 00       	and    $0xff0000,%eax
80108c8a:	89 c2                	mov    %eax,%edx
80108c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c8f:	c1 e0 0b             	shl    $0xb,%eax
80108c92:	0f b7 c0             	movzwl %ax,%eax
80108c95:	09 c2                	or     %eax,%edx
80108c97:	8b 45 10             	mov    0x10(%ebp),%eax
80108c9a:	c1 e0 08             	shl    $0x8,%eax
80108c9d:	25 00 07 00 00       	and    $0x700,%eax
80108ca2:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108ca4:	8b 45 14             	mov    0x14(%ebp),%eax
80108ca7:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cac:	09 d0                	or     %edx,%eax
80108cae:	0d 00 00 00 80       	or     $0x80000000,%eax
80108cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108cb6:	ff 75 f4             	push   -0xc(%ebp)
80108cb9:	e8 5a ff ff ff       	call   80108c18 <pci_write_config>
80108cbe:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108cc1:	e8 74 ff ff ff       	call   80108c3a <pci_read_config>
80108cc6:	8b 55 18             	mov    0x18(%ebp),%edx
80108cc9:	89 02                	mov    %eax,(%edx)
}
80108ccb:	90                   	nop
80108ccc:	c9                   	leave
80108ccd:	c3                   	ret

80108cce <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108cce:	55                   	push   %ebp
80108ccf:	89 e5                	mov    %esp,%ebp
80108cd1:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd7:	c1 e0 10             	shl    $0x10,%eax
80108cda:	25 00 00 ff 00       	and    $0xff0000,%eax
80108cdf:	89 c2                	mov    %eax,%edx
80108ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ce4:	c1 e0 0b             	shl    $0xb,%eax
80108ce7:	0f b7 c0             	movzwl %ax,%eax
80108cea:	09 c2                	or     %eax,%edx
80108cec:	8b 45 10             	mov    0x10(%ebp),%eax
80108cef:	c1 e0 08             	shl    $0x8,%eax
80108cf2:	25 00 07 00 00       	and    $0x700,%eax
80108cf7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108cf9:	8b 45 14             	mov    0x14(%ebp),%eax
80108cfc:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d01:	09 d0                	or     %edx,%eax
80108d03:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d08:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108d0b:	ff 75 fc             	push   -0x4(%ebp)
80108d0e:	e8 05 ff ff ff       	call   80108c18 <pci_write_config>
80108d13:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108d16:	ff 75 18             	push   0x18(%ebp)
80108d19:	e8 0b ff ff ff       	call   80108c29 <pci_write_data>
80108d1e:	83 c4 04             	add    $0x4,%esp
}
80108d21:	90                   	nop
80108d22:	c9                   	leave
80108d23:	c3                   	ret

80108d24 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108d24:	55                   	push   %ebp
80108d25:	89 e5                	mov    %esp,%ebp
80108d27:	53                   	push   %ebx
80108d28:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d2e:	a2 98 7a 19 80       	mov    %al,0x80197a98
  dev.device_num = device_num;
80108d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d36:	a2 99 7a 19 80       	mov    %al,0x80197a99
  dev.function_num = function_num;
80108d3b:	8b 45 10             	mov    0x10(%ebp),%eax
80108d3e:	a2 9a 7a 19 80       	mov    %al,0x80197a9a
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108d43:	ff 75 10             	push   0x10(%ebp)
80108d46:	ff 75 0c             	push   0xc(%ebp)
80108d49:	ff 75 08             	push   0x8(%ebp)
80108d4c:	68 64 ca 10 80       	push   $0x8010ca64
80108d51:	e8 9e 76 ff ff       	call   801003f4 <cprintf>
80108d56:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108d59:	83 ec 0c             	sub    $0xc,%esp
80108d5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d5f:	50                   	push   %eax
80108d60:	6a 00                	push   $0x0
80108d62:	ff 75 10             	push   0x10(%ebp)
80108d65:	ff 75 0c             	push   0xc(%ebp)
80108d68:	ff 75 08             	push   0x8(%ebp)
80108d6b:	e8 09 ff ff ff       	call   80108c79 <pci_access_config>
80108d70:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d76:	c1 e8 10             	shr    $0x10,%eax
80108d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d7f:	25 ff ff 00 00       	and    $0xffff,%eax
80108d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8a:	a3 9c 7a 19 80       	mov    %eax,0x80197a9c
  dev.vendor_id = vendor_id;
80108d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d92:	a3 a0 7a 19 80       	mov    %eax,0x80197aa0
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108d97:	83 ec 04             	sub    $0x4,%esp
80108d9a:	ff 75 f0             	push   -0x10(%ebp)
80108d9d:	ff 75 f4             	push   -0xc(%ebp)
80108da0:	68 98 ca 10 80       	push   $0x8010ca98
80108da5:	e8 4a 76 ff ff       	call   801003f4 <cprintf>
80108daa:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108dad:	83 ec 0c             	sub    $0xc,%esp
80108db0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108db3:	50                   	push   %eax
80108db4:	6a 08                	push   $0x8
80108db6:	ff 75 10             	push   0x10(%ebp)
80108db9:	ff 75 0c             	push   0xc(%ebp)
80108dbc:	ff 75 08             	push   0x8(%ebp)
80108dbf:	e8 b5 fe ff ff       	call   80108c79 <pci_access_config>
80108dc4:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108dc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dca:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd0:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108dd3:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd9:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108ddc:	0f b6 c0             	movzbl %al,%eax
80108ddf:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108de2:	c1 eb 18             	shr    $0x18,%ebx
80108de5:	83 ec 0c             	sub    $0xc,%esp
80108de8:	51                   	push   %ecx
80108de9:	52                   	push   %edx
80108dea:	50                   	push   %eax
80108deb:	53                   	push   %ebx
80108dec:	68 bc ca 10 80       	push   $0x8010cabc
80108df1:	e8 fe 75 ff ff       	call   801003f4 <cprintf>
80108df6:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dfc:	c1 e8 18             	shr    $0x18,%eax
80108dff:	a2 a4 7a 19 80       	mov    %al,0x80197aa4
  dev.sub_class = (data>>16)&0xFF;
80108e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e07:	c1 e8 10             	shr    $0x10,%eax
80108e0a:	a2 a5 7a 19 80       	mov    %al,0x80197aa5
  dev.interface = (data>>8)&0xFF;
80108e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e12:	c1 e8 08             	shr    $0x8,%eax
80108e15:	a2 a6 7a 19 80       	mov    %al,0x80197aa6
  dev.revision_id = data&0xFF;
80108e1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e1d:	a2 a7 7a 19 80       	mov    %al,0x80197aa7
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108e22:	83 ec 0c             	sub    $0xc,%esp
80108e25:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e28:	50                   	push   %eax
80108e29:	6a 10                	push   $0x10
80108e2b:	ff 75 10             	push   0x10(%ebp)
80108e2e:	ff 75 0c             	push   0xc(%ebp)
80108e31:	ff 75 08             	push   0x8(%ebp)
80108e34:	e8 40 fe ff ff       	call   80108c79 <pci_access_config>
80108e39:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108e3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e3f:	a3 a8 7a 19 80       	mov    %eax,0x80197aa8
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108e44:	83 ec 0c             	sub    $0xc,%esp
80108e47:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e4a:	50                   	push   %eax
80108e4b:	6a 14                	push   $0x14
80108e4d:	ff 75 10             	push   0x10(%ebp)
80108e50:	ff 75 0c             	push   0xc(%ebp)
80108e53:	ff 75 08             	push   0x8(%ebp)
80108e56:	e8 1e fe ff ff       	call   80108c79 <pci_access_config>
80108e5b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108e5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e61:	a3 ac 7a 19 80       	mov    %eax,0x80197aac
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108e66:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108e6d:	75 5a                	jne    80108ec9 <pci_init_device+0x1a5>
80108e6f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108e76:	75 51                	jne    80108ec9 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108e78:	83 ec 0c             	sub    $0xc,%esp
80108e7b:	68 01 cb 10 80       	push   $0x8010cb01
80108e80:	e8 6f 75 ff ff       	call   801003f4 <cprintf>
80108e85:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108e88:	83 ec 0c             	sub    $0xc,%esp
80108e8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e8e:	50                   	push   %eax
80108e8f:	68 f0 00 00 00       	push   $0xf0
80108e94:	ff 75 10             	push   0x10(%ebp)
80108e97:	ff 75 0c             	push   0xc(%ebp)
80108e9a:	ff 75 08             	push   0x8(%ebp)
80108e9d:	e8 d7 fd ff ff       	call   80108c79 <pci_access_config>
80108ea2:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea8:	83 ec 08             	sub    $0x8,%esp
80108eab:	50                   	push   %eax
80108eac:	68 1b cb 10 80       	push   $0x8010cb1b
80108eb1:	e8 3e 75 ff ff       	call   801003f4 <cprintf>
80108eb6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108eb9:	83 ec 0c             	sub    $0xc,%esp
80108ebc:	68 98 7a 19 80       	push   $0x80197a98
80108ec1:	e8 09 00 00 00       	call   80108ecf <i8254_init>
80108ec6:	83 c4 10             	add    $0x10,%esp
  }
}
80108ec9:	90                   	nop
80108eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ecd:	c9                   	leave
80108ece:	c3                   	ret

80108ecf <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108ecf:	55                   	push   %ebp
80108ed0:	89 e5                	mov    %esp,%ebp
80108ed2:	53                   	push   %ebx
80108ed3:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108edd:	0f b6 c8             	movzbl %al,%ecx
80108ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ee7:	0f b6 d0             	movzbl %al,%edx
80108eea:	8b 45 08             	mov    0x8(%ebp),%eax
80108eed:	0f b6 00             	movzbl (%eax),%eax
80108ef0:	0f b6 c0             	movzbl %al,%eax
80108ef3:	83 ec 0c             	sub    $0xc,%esp
80108ef6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ef9:	53                   	push   %ebx
80108efa:	6a 04                	push   $0x4
80108efc:	51                   	push   %ecx
80108efd:	52                   	push   %edx
80108efe:	50                   	push   %eax
80108eff:	e8 75 fd ff ff       	call   80108c79 <pci_access_config>
80108f04:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f0a:	83 c8 04             	or     $0x4,%eax
80108f0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108f10:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108f13:	8b 45 08             	mov    0x8(%ebp),%eax
80108f16:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f1a:	0f b6 c8             	movzbl %al,%ecx
80108f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f20:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f24:	0f b6 d0             	movzbl %al,%edx
80108f27:	8b 45 08             	mov    0x8(%ebp),%eax
80108f2a:	0f b6 00             	movzbl (%eax),%eax
80108f2d:	0f b6 c0             	movzbl %al,%eax
80108f30:	83 ec 0c             	sub    $0xc,%esp
80108f33:	53                   	push   %ebx
80108f34:	6a 04                	push   $0x4
80108f36:	51                   	push   %ecx
80108f37:	52                   	push   %edx
80108f38:	50                   	push   %eax
80108f39:	e8 90 fd ff ff       	call   80108cce <pci_write_config_register>
80108f3e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108f41:	8b 45 08             	mov    0x8(%ebp),%eax
80108f44:	8b 40 10             	mov    0x10(%eax),%eax
80108f47:	05 00 00 00 40       	add    $0x40000000,%eax
80108f4c:	a3 b0 7a 19 80       	mov    %eax,0x80197ab0
  uint *ctrl = (uint *)base_addr;
80108f51:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108f59:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f5e:	05 d8 00 00 00       	add    $0xd8,%eax
80108f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f69:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f72:	8b 00                	mov    (%eax),%eax
80108f74:	0d 00 00 00 04       	or     $0x4000000,%eax
80108f79:	89 c2                	mov    %eax,%edx
80108f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f83:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8c:	8b 00                	mov    (%eax),%eax
80108f8e:	83 c8 40             	or     $0x40,%eax
80108f91:	89 c2                	mov    %eax,%edx
80108f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f96:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9b:	8b 10                	mov    (%eax),%edx
80108f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108fa2:	83 ec 0c             	sub    $0xc,%esp
80108fa5:	68 30 cb 10 80       	push   $0x8010cb30
80108faa:	e8 45 74 ff ff       	call   801003f4 <cprintf>
80108faf:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108fb2:	e8 f1 97 ff ff       	call   801027a8 <kalloc>
80108fb7:	a3 bc 7a 19 80       	mov    %eax,0x80197abc
  *intr_addr = 0;
80108fbc:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108fc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108fc7:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108fcc:	83 ec 08             	sub    $0x8,%esp
80108fcf:	50                   	push   %eax
80108fd0:	68 52 cb 10 80       	push   $0x8010cb52
80108fd5:	e8 1a 74 ff ff       	call   801003f4 <cprintf>
80108fda:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108fdd:	e8 50 00 00 00       	call   80109032 <i8254_init_recv>
  i8254_init_send();
80108fe2:	e8 69 03 00 00       	call   80109350 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108fe7:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108fee:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108ff1:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ff8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108ffb:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109002:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80109005:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010900c:	0f b6 c0             	movzbl %al,%eax
8010900f:	83 ec 0c             	sub    $0xc,%esp
80109012:	53                   	push   %ebx
80109013:	51                   	push   %ecx
80109014:	52                   	push   %edx
80109015:	50                   	push   %eax
80109016:	68 60 cb 10 80       	push   $0x8010cb60
8010901b:	e8 d4 73 ff ff       	call   801003f4 <cprintf>
80109020:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80109023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109026:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010902c:	90                   	nop
8010902d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109030:	c9                   	leave
80109031:	c3                   	ret

80109032 <i8254_init_recv>:

void i8254_init_recv(){
80109032:	55                   	push   %ebp
80109033:	89 e5                	mov    %esp,%ebp
80109035:	57                   	push   %edi
80109036:	56                   	push   %esi
80109037:	53                   	push   %ebx
80109038:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010903b:	83 ec 0c             	sub    $0xc,%esp
8010903e:	6a 00                	push   $0x0
80109040:	e8 e8 04 00 00       	call   8010952d <i8254_read_eeprom>
80109045:	83 c4 10             	add    $0x10,%esp
80109048:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
8010904b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010904e:	a2 b4 7a 19 80       	mov    %al,0x80197ab4
  mac_addr[1] = data_l>>8;
80109053:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109056:	c1 e8 08             	shr    $0x8,%eax
80109059:	a2 b5 7a 19 80       	mov    %al,0x80197ab5
  uint data_m = i8254_read_eeprom(0x1);
8010905e:	83 ec 0c             	sub    $0xc,%esp
80109061:	6a 01                	push   $0x1
80109063:	e8 c5 04 00 00       	call   8010952d <i8254_read_eeprom>
80109068:	83 c4 10             	add    $0x10,%esp
8010906b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010906e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109071:	a2 b6 7a 19 80       	mov    %al,0x80197ab6
  mac_addr[3] = data_m>>8;
80109076:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109079:	c1 e8 08             	shr    $0x8,%eax
8010907c:	a2 b7 7a 19 80       	mov    %al,0x80197ab7
  uint data_h = i8254_read_eeprom(0x2);
80109081:	83 ec 0c             	sub    $0xc,%esp
80109084:	6a 02                	push   $0x2
80109086:	e8 a2 04 00 00       	call   8010952d <i8254_read_eeprom>
8010908b:	83 c4 10             	add    $0x10,%esp
8010908e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80109091:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109094:	a2 b8 7a 19 80       	mov    %al,0x80197ab8
  mac_addr[5] = data_h>>8;
80109099:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010909c:	c1 e8 08             	shr    $0x8,%eax
8010909f:	a2 b9 7a 19 80       	mov    %al,0x80197ab9
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801090a4:	0f b6 05 b9 7a 19 80 	movzbl 0x80197ab9,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090ab:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801090ae:	0f b6 05 b8 7a 19 80 	movzbl 0x80197ab8,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090b5:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801090b8:	0f b6 05 b7 7a 19 80 	movzbl 0x80197ab7,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090bf:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801090c2:	0f b6 05 b6 7a 19 80 	movzbl 0x80197ab6,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090c9:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801090cc:	0f b6 05 b5 7a 19 80 	movzbl 0x80197ab5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090d3:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801090d6:	0f b6 05 b4 7a 19 80 	movzbl 0x80197ab4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090dd:	0f b6 c0             	movzbl %al,%eax
801090e0:	83 ec 04             	sub    $0x4,%esp
801090e3:	57                   	push   %edi
801090e4:	56                   	push   %esi
801090e5:	53                   	push   %ebx
801090e6:	51                   	push   %ecx
801090e7:	52                   	push   %edx
801090e8:	50                   	push   %eax
801090e9:	68 78 cb 10 80       	push   $0x8010cb78
801090ee:	e8 01 73 ff ff       	call   801003f4 <cprintf>
801090f3:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801090f6:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801090fb:	05 00 54 00 00       	add    $0x5400,%eax
80109100:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80109103:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109108:	05 04 54 00 00       	add    $0x5404,%eax
8010910d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80109110:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109113:	c1 e0 10             	shl    $0x10,%eax
80109116:	0b 45 d8             	or     -0x28(%ebp),%eax
80109119:	89 c2                	mov    %eax,%edx
8010911b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010911e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80109120:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109123:	0d 00 00 00 80       	or     $0x80000000,%eax
80109128:	89 c2                	mov    %eax,%edx
8010912a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010912d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010912f:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109134:	05 00 52 00 00       	add    $0x5200,%eax
80109139:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010913c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80109143:	eb 19                	jmp    8010915e <i8254_init_recv+0x12c>
    mta[i] = 0;
80109145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109148:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010914f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109152:	01 d0                	add    %edx,%eax
80109154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010915a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010915e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80109162:	7e e1                	jle    80109145 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80109164:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109169:	05 d0 00 00 00       	add    $0xd0,%eax
8010916e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109171:	8b 45 c0             	mov    -0x40(%ebp),%eax
80109174:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010917a:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010917f:	05 c8 00 00 00       	add    $0xc8,%eax
80109184:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109187:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010918a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109190:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109195:	05 28 28 00 00       	add    $0x2828,%eax
8010919a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010919d:	8b 45 b8             	mov    -0x48(%ebp),%eax
801091a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801091a6:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091ab:	05 00 01 00 00       	add    $0x100,%eax
801091b0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801091b3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801091b6:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801091bc:	e8 e7 95 ff ff       	call   801027a8 <kalloc>
801091c1:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801091c4:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091c9:	05 00 28 00 00       	add    $0x2800,%eax
801091ce:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801091d1:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091d6:	05 04 28 00 00       	add    $0x2804,%eax
801091db:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801091de:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091e3:	05 08 28 00 00       	add    $0x2808,%eax
801091e8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801091eb:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091f0:	05 10 28 00 00       	add    $0x2810,%eax
801091f5:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801091f8:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091fd:	05 18 28 00 00       	add    $0x2818,%eax
80109202:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109205:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109208:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010920e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80109211:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109213:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109216:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010921c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010921f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109225:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109228:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010922e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80109231:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109237:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010923a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010923d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109244:	eb 73                	jmp    801092b9 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80109246:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109249:	c1 e0 04             	shl    $0x4,%eax
8010924c:	89 c2                	mov    %eax,%edx
8010924e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109251:	01 d0                	add    %edx,%eax
80109253:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010925a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010925d:	c1 e0 04             	shl    $0x4,%eax
80109260:	89 c2                	mov    %eax,%edx
80109262:	8b 45 98             	mov    -0x68(%ebp),%eax
80109265:	01 d0                	add    %edx,%eax
80109267:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010926d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109270:	c1 e0 04             	shl    $0x4,%eax
80109273:	89 c2                	mov    %eax,%edx
80109275:	8b 45 98             	mov    -0x68(%ebp),%eax
80109278:	01 d0                	add    %edx,%eax
8010927a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109280:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109283:	c1 e0 04             	shl    $0x4,%eax
80109286:	89 c2                	mov    %eax,%edx
80109288:	8b 45 98             	mov    -0x68(%ebp),%eax
8010928b:	01 d0                	add    %edx,%eax
8010928d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109291:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109294:	c1 e0 04             	shl    $0x4,%eax
80109297:	89 c2                	mov    %eax,%edx
80109299:	8b 45 98             	mov    -0x68(%ebp),%eax
8010929c:	01 d0                	add    %edx,%eax
8010929e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801092a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092a5:	c1 e0 04             	shl    $0x4,%eax
801092a8:	89 c2                	mov    %eax,%edx
801092aa:	8b 45 98             	mov    -0x68(%ebp),%eax
801092ad:	01 d0                	add    %edx,%eax
801092af:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801092b5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801092b9:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801092c0:	7e 84                	jle    80109246 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801092c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801092c9:	eb 57                	jmp    80109322 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801092cb:	e8 d8 94 ff ff       	call   801027a8 <kalloc>
801092d0:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801092d3:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801092d7:	75 12                	jne    801092eb <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
801092d9:	83 ec 0c             	sub    $0xc,%esp
801092dc:	68 98 cb 10 80       	push   $0x8010cb98
801092e1:	e8 0e 71 ff ff       	call   801003f4 <cprintf>
801092e6:	83 c4 10             	add    $0x10,%esp
      break;
801092e9:	eb 3d                	jmp    80109328 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801092eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801092ee:	c1 e0 04             	shl    $0x4,%eax
801092f1:	89 c2                	mov    %eax,%edx
801092f3:	8b 45 98             	mov    -0x68(%ebp),%eax
801092f6:	01 d0                	add    %edx,%eax
801092f8:	8b 55 94             	mov    -0x6c(%ebp),%edx
801092fb:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109301:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109303:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109306:	83 c0 01             	add    $0x1,%eax
80109309:	c1 e0 04             	shl    $0x4,%eax
8010930c:	89 c2                	mov    %eax,%edx
8010930e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109311:	01 d0                	add    %edx,%eax
80109313:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109316:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010931c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010931e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109322:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109326:	7e a3                	jle    801092cb <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80109328:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010932b:	8b 00                	mov    (%eax),%eax
8010932d:	83 c8 02             	or     $0x2,%eax
80109330:	89 c2                	mov    %eax,%edx
80109332:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109335:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109337:	83 ec 0c             	sub    $0xc,%esp
8010933a:	68 b8 cb 10 80       	push   $0x8010cbb8
8010933f:	e8 b0 70 ff ff       	call   801003f4 <cprintf>
80109344:	83 c4 10             	add    $0x10,%esp
}
80109347:	90                   	nop
80109348:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010934b:	5b                   	pop    %ebx
8010934c:	5e                   	pop    %esi
8010934d:	5f                   	pop    %edi
8010934e:	5d                   	pop    %ebp
8010934f:	c3                   	ret

80109350 <i8254_init_send>:

void i8254_init_send(){
80109350:	55                   	push   %ebp
80109351:	89 e5                	mov    %esp,%ebp
80109353:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109356:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010935b:	05 28 38 00 00       	add    $0x3828,%eax
80109360:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109363:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109366:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010936c:	e8 37 94 ff ff       	call   801027a8 <kalloc>
80109371:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109374:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109379:	05 00 38 00 00       	add    $0x3800,%eax
8010937e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109381:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109386:	05 04 38 00 00       	add    $0x3804,%eax
8010938b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010938e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109393:	05 08 38 00 00       	add    $0x3808,%eax
80109398:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010939b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010939e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801093a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093a7:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801093a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801093b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801093b5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801093bb:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801093c0:	05 10 38 00 00       	add    $0x3810,%eax
801093c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093c8:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801093cd:	05 18 38 00 00       	add    $0x3818,%eax
801093d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801093d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801093de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801093e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801093ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093f4:	e9 82 00 00 00       	jmp    8010947b <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801093f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093fc:	c1 e0 04             	shl    $0x4,%eax
801093ff:	89 c2                	mov    %eax,%edx
80109401:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109404:	01 d0                	add    %edx,%eax
80109406:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010940d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109410:	c1 e0 04             	shl    $0x4,%eax
80109413:	89 c2                	mov    %eax,%edx
80109415:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109418:	01 d0                	add    %edx,%eax
8010941a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109423:	c1 e0 04             	shl    $0x4,%eax
80109426:	89 c2                	mov    %eax,%edx
80109428:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010942b:	01 d0                	add    %edx,%eax
8010942d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109434:	c1 e0 04             	shl    $0x4,%eax
80109437:	89 c2                	mov    %eax,%edx
80109439:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010943c:	01 d0                	add    %edx,%eax
8010943e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109445:	c1 e0 04             	shl    $0x4,%eax
80109448:	89 c2                	mov    %eax,%edx
8010944a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010944d:	01 d0                	add    %edx,%eax
8010944f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109456:	c1 e0 04             	shl    $0x4,%eax
80109459:	89 c2                	mov    %eax,%edx
8010945b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010945e:	01 d0                	add    %edx,%eax
80109460:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109467:	c1 e0 04             	shl    $0x4,%eax
8010946a:	89 c2                	mov    %eax,%edx
8010946c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010946f:	01 d0                	add    %edx,%eax
80109471:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109477:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010947b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109482:	0f 8e 71 ff ff ff    	jle    801093f9 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109488:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010948f:	eb 57                	jmp    801094e8 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109491:	e8 12 93 ff ff       	call   801027a8 <kalloc>
80109496:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109499:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010949d:	75 12                	jne    801094b1 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010949f:	83 ec 0c             	sub    $0xc,%esp
801094a2:	68 98 cb 10 80       	push   $0x8010cb98
801094a7:	e8 48 6f ff ff       	call   801003f4 <cprintf>
801094ac:	83 c4 10             	add    $0x10,%esp
      break;
801094af:	eb 3d                	jmp    801094ee <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801094b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b4:	c1 e0 04             	shl    $0x4,%eax
801094b7:	89 c2                	mov    %eax,%edx
801094b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094bc:	01 d0                	add    %edx,%eax
801094be:	8b 55 cc             	mov    -0x34(%ebp),%edx
801094c1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801094c7:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801094c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094cc:	83 c0 01             	add    $0x1,%eax
801094cf:	c1 e0 04             	shl    $0x4,%eax
801094d2:	89 c2                	mov    %eax,%edx
801094d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094d7:	01 d0                	add    %edx,%eax
801094d9:	8b 55 cc             	mov    -0x34(%ebp),%edx
801094dc:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801094e2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801094e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801094e8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801094ec:	7e a3                	jle    80109491 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801094ee:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094f3:	05 00 04 00 00       	add    $0x400,%eax
801094f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801094fb:	8b 45 c8             	mov    -0x38(%ebp),%eax
801094fe:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109504:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109509:	05 10 04 00 00       	add    $0x410,%eax
8010950e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109511:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109514:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010951a:	83 ec 0c             	sub    $0xc,%esp
8010951d:	68 d8 cb 10 80       	push   $0x8010cbd8
80109522:	e8 cd 6e ff ff       	call   801003f4 <cprintf>
80109527:	83 c4 10             	add    $0x10,%esp

}
8010952a:	90                   	nop
8010952b:	c9                   	leave
8010952c:	c3                   	ret

8010952d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010952d:	55                   	push   %ebp
8010952e:	89 e5                	mov    %esp,%ebp
80109530:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109533:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109538:	83 c0 14             	add    $0x14,%eax
8010953b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010953e:	8b 45 08             	mov    0x8(%ebp),%eax
80109541:	c1 e0 08             	shl    $0x8,%eax
80109544:	0f b7 c0             	movzwl %ax,%eax
80109547:	83 c8 01             	or     $0x1,%eax
8010954a:	89 c2                	mov    %eax,%edx
8010954c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109551:	83 ec 0c             	sub    $0xc,%esp
80109554:	68 f8 cb 10 80       	push   $0x8010cbf8
80109559:	e8 96 6e ff ff       	call   801003f4 <cprintf>
8010955e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109564:	8b 00                	mov    (%eax),%eax
80109566:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956c:	83 e0 10             	and    $0x10,%eax
8010956f:	85 c0                	test   %eax,%eax
80109571:	75 02                	jne    80109575 <i8254_read_eeprom+0x48>
  while(1){
80109573:	eb dc                	jmp    80109551 <i8254_read_eeprom+0x24>
      break;
80109575:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109579:	8b 00                	mov    (%eax),%eax
8010957b:	c1 e8 10             	shr    $0x10,%eax
}
8010957e:	c9                   	leave
8010957f:	c3                   	ret

80109580 <i8254_recv>:
void i8254_recv(){
80109580:	55                   	push   %ebp
80109581:	89 e5                	mov    %esp,%ebp
80109583:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109586:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010958b:	05 10 28 00 00       	add    $0x2810,%eax
80109590:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109593:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109598:	05 18 28 00 00       	add    $0x2818,%eax
8010959d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801095a0:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801095a5:	05 00 28 00 00       	add    $0x2800,%eax
801095aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801095ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095b0:	8b 00                	mov    (%eax),%eax
801095b2:	05 00 00 00 80       	add    $0x80000000,%eax
801095b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801095ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095bd:	8b 10                	mov    (%eax),%edx
801095bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c2:	8b 00                	mov    (%eax),%eax
801095c4:	29 c2                	sub    %eax,%edx
801095c6:	89 d0                	mov    %edx,%eax
801095c8:	25 ff 00 00 00       	and    $0xff,%eax
801095cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801095d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801095d4:	7e 37                	jle    8010960d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801095d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d9:	8b 00                	mov    (%eax),%eax
801095db:	c1 e0 04             	shl    $0x4,%eax
801095de:	89 c2                	mov    %eax,%edx
801095e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095e3:	01 d0                	add    %edx,%eax
801095e5:	8b 00                	mov    (%eax),%eax
801095e7:	05 00 00 00 80       	add    $0x80000000,%eax
801095ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801095ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f2:	8b 00                	mov    (%eax),%eax
801095f4:	83 c0 01             	add    $0x1,%eax
801095f7:	0f b6 d0             	movzbl %al,%edx
801095fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095fd:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801095ff:	83 ec 0c             	sub    $0xc,%esp
80109602:	ff 75 e0             	push   -0x20(%ebp)
80109605:	e8 13 09 00 00       	call   80109f1d <eth_proc>
8010960a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010960d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109610:	8b 10                	mov    (%eax),%edx
80109612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109615:	8b 00                	mov    (%eax),%eax
80109617:	39 c2                	cmp    %eax,%edx
80109619:	75 9f                	jne    801095ba <i8254_recv+0x3a>
      (*rdt)--;
8010961b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961e:	8b 00                	mov    (%eax),%eax
80109620:	8d 50 ff             	lea    -0x1(%eax),%edx
80109623:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109626:	89 10                	mov    %edx,(%eax)
  while(1){
80109628:	eb 90                	jmp    801095ba <i8254_recv+0x3a>

8010962a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010962a:	55                   	push   %ebp
8010962b:	89 e5                	mov    %esp,%ebp
8010962d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109630:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109635:	05 10 38 00 00       	add    $0x3810,%eax
8010963a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010963d:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109642:	05 18 38 00 00       	add    $0x3818,%eax
80109647:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010964a:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010964f:	05 00 38 00 00       	add    $0x3800,%eax
80109654:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109657:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010965a:	8b 00                	mov    (%eax),%eax
8010965c:	05 00 00 00 80       	add    $0x80000000,%eax
80109661:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109667:	8b 10                	mov    (%eax),%edx
80109669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966c:	8b 00                	mov    (%eax),%eax
8010966e:	29 c2                	sub    %eax,%edx
80109670:	0f b6 c2             	movzbl %dl,%eax
80109673:	ba 00 01 00 00       	mov    $0x100,%edx
80109678:	29 c2                	sub    %eax,%edx
8010967a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010967d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109680:	8b 00                	mov    (%eax),%eax
80109682:	25 ff 00 00 00       	and    $0xff,%eax
80109687:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010968a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010968e:	0f 8e a8 00 00 00    	jle    8010973c <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109694:	8b 45 08             	mov    0x8(%ebp),%eax
80109697:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010969a:	89 d1                	mov    %edx,%ecx
8010969c:	c1 e1 04             	shl    $0x4,%ecx
8010969f:	8b 55 e8             	mov    -0x18(%ebp),%edx
801096a2:	01 ca                	add    %ecx,%edx
801096a4:	8b 12                	mov    (%edx),%edx
801096a6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801096ac:	83 ec 04             	sub    $0x4,%esp
801096af:	ff 75 0c             	push   0xc(%ebp)
801096b2:	50                   	push   %eax
801096b3:	52                   	push   %edx
801096b4:	e8 e2 bd ff ff       	call   8010549b <memmove>
801096b9:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801096bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096bf:	c1 e0 04             	shl    $0x4,%eax
801096c2:	89 c2                	mov    %eax,%edx
801096c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096c7:	01 d0                	add    %edx,%eax
801096c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801096cc:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801096d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096d3:	c1 e0 04             	shl    $0x4,%eax
801096d6:	89 c2                	mov    %eax,%edx
801096d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096db:	01 d0                	add    %edx,%eax
801096dd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801096e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096e4:	c1 e0 04             	shl    $0x4,%eax
801096e7:	89 c2                	mov    %eax,%edx
801096e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ec:	01 d0                	add    %edx,%eax
801096ee:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801096f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096f5:	c1 e0 04             	shl    $0x4,%eax
801096f8:	89 c2                	mov    %eax,%edx
801096fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096fd:	01 d0                	add    %edx,%eax
801096ff:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109703:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109706:	c1 e0 04             	shl    $0x4,%eax
80109709:	89 c2                	mov    %eax,%edx
8010970b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010970e:	01 d0                	add    %edx,%eax
80109710:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109716:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109719:	c1 e0 04             	shl    $0x4,%eax
8010971c:	89 c2                	mov    %eax,%edx
8010971e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109721:	01 d0                	add    %edx,%eax
80109723:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972a:	8b 00                	mov    (%eax),%eax
8010972c:	83 c0 01             	add    $0x1,%eax
8010972f:	0f b6 d0             	movzbl %al,%edx
80109732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109735:	89 10                	mov    %edx,(%eax)
    return len;
80109737:	8b 45 0c             	mov    0xc(%ebp),%eax
8010973a:	eb 05                	jmp    80109741 <i8254_send+0x117>
  }else{
    return -1;
8010973c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109741:	c9                   	leave
80109742:	c3                   	ret

80109743 <i8254_intr>:

void i8254_intr(){
80109743:	55                   	push   %ebp
80109744:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109746:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
8010974b:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109751:	90                   	nop
80109752:	5d                   	pop    %ebp
80109753:	c3                   	ret

80109754 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109754:	55                   	push   %ebp
80109755:	89 e5                	mov    %esp,%ebp
80109757:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010975a:	8b 45 08             	mov    0x8(%ebp),%eax
8010975d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109763:	0f b7 00             	movzwl (%eax),%eax
80109766:	66 3d 00 01          	cmp    $0x100,%ax
8010976a:	74 0a                	je     80109776 <arp_proc+0x22>
8010976c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109771:	e9 4f 01 00 00       	jmp    801098c5 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109779:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010977d:	66 83 f8 08          	cmp    $0x8,%ax
80109781:	74 0a                	je     8010978d <arp_proc+0x39>
80109783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109788:	e9 38 01 00 00       	jmp    801098c5 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010978d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109794:	3c 06                	cmp    $0x6,%al
80109796:	74 0a                	je     801097a2 <arp_proc+0x4e>
80109798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010979d:	e9 23 01 00 00       	jmp    801098c5 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801097a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a5:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801097a9:	3c 04                	cmp    $0x4,%al
801097ab:	74 0a                	je     801097b7 <arp_proc+0x63>
801097ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097b2:	e9 0e 01 00 00       	jmp    801098c5 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801097b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ba:	83 c0 18             	add    $0x18,%eax
801097bd:	83 ec 04             	sub    $0x4,%esp
801097c0:	6a 04                	push   $0x4
801097c2:	50                   	push   %eax
801097c3:	68 04 f5 10 80       	push   $0x8010f504
801097c8:	e8 76 bc ff ff       	call   80105443 <memcmp>
801097cd:	83 c4 10             	add    $0x10,%esp
801097d0:	85 c0                	test   %eax,%eax
801097d2:	74 27                	je     801097fb <arp_proc+0xa7>
801097d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d7:	83 c0 0e             	add    $0xe,%eax
801097da:	83 ec 04             	sub    $0x4,%esp
801097dd:	6a 04                	push   $0x4
801097df:	50                   	push   %eax
801097e0:	68 04 f5 10 80       	push   $0x8010f504
801097e5:	e8 59 bc ff ff       	call   80105443 <memcmp>
801097ea:	83 c4 10             	add    $0x10,%esp
801097ed:	85 c0                	test   %eax,%eax
801097ef:	74 0a                	je     801097fb <arp_proc+0xa7>
801097f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097f6:	e9 ca 00 00 00       	jmp    801098c5 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801097fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fe:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109802:	66 3d 00 01          	cmp    $0x100,%ax
80109806:	75 69                	jne    80109871 <arp_proc+0x11d>
80109808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010980b:	83 c0 18             	add    $0x18,%eax
8010980e:	83 ec 04             	sub    $0x4,%esp
80109811:	6a 04                	push   $0x4
80109813:	50                   	push   %eax
80109814:	68 04 f5 10 80       	push   $0x8010f504
80109819:	e8 25 bc ff ff       	call   80105443 <memcmp>
8010981e:	83 c4 10             	add    $0x10,%esp
80109821:	85 c0                	test   %eax,%eax
80109823:	75 4c                	jne    80109871 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109825:	e8 7e 8f ff ff       	call   801027a8 <kalloc>
8010982a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010982d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109834:	83 ec 04             	sub    $0x4,%esp
80109837:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010983a:	50                   	push   %eax
8010983b:	ff 75 f0             	push   -0x10(%ebp)
8010983e:	ff 75 f4             	push   -0xc(%ebp)
80109841:	e8 1f 04 00 00       	call   80109c65 <arp_reply_pkt_create>
80109846:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109849:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010984c:	83 ec 08             	sub    $0x8,%esp
8010984f:	50                   	push   %eax
80109850:	ff 75 f0             	push   -0x10(%ebp)
80109853:	e8 d2 fd ff ff       	call   8010962a <i8254_send>
80109858:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010985b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010985e:	83 ec 0c             	sub    $0xc,%esp
80109861:	50                   	push   %eax
80109862:	e8 a7 8e ff ff       	call   8010270e <kfree>
80109867:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010986a:	b8 02 00 00 00       	mov    $0x2,%eax
8010986f:	eb 54                	jmp    801098c5 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109874:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109878:	66 3d 00 02          	cmp    $0x200,%ax
8010987c:	75 42                	jne    801098c0 <arp_proc+0x16c>
8010987e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109881:	83 c0 18             	add    $0x18,%eax
80109884:	83 ec 04             	sub    $0x4,%esp
80109887:	6a 04                	push   $0x4
80109889:	50                   	push   %eax
8010988a:	68 04 f5 10 80       	push   $0x8010f504
8010988f:	e8 af bb ff ff       	call   80105443 <memcmp>
80109894:	83 c4 10             	add    $0x10,%esp
80109897:	85 c0                	test   %eax,%eax
80109899:	75 25                	jne    801098c0 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010989b:	83 ec 0c             	sub    $0xc,%esp
8010989e:	68 fc cb 10 80       	push   $0x8010cbfc
801098a3:	e8 4c 6b ff ff       	call   801003f4 <cprintf>
801098a8:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801098ab:	83 ec 0c             	sub    $0xc,%esp
801098ae:	ff 75 f4             	push   -0xc(%ebp)
801098b1:	e8 af 01 00 00       	call   80109a65 <arp_table_update>
801098b6:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801098b9:	b8 01 00 00 00       	mov    $0x1,%eax
801098be:	eb 05                	jmp    801098c5 <arp_proc+0x171>
  }else{
    return -1;
801098c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801098c5:	c9                   	leave
801098c6:	c3                   	ret

801098c7 <arp_scan>:

void arp_scan(){
801098c7:	55                   	push   %ebp
801098c8:	89 e5                	mov    %esp,%ebp
801098ca:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801098cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801098d4:	eb 6f                	jmp    80109945 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801098d6:	e8 cd 8e ff ff       	call   801027a8 <kalloc>
801098db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801098de:	83 ec 04             	sub    $0x4,%esp
801098e1:	ff 75 f4             	push   -0xc(%ebp)
801098e4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801098e7:	50                   	push   %eax
801098e8:	ff 75 ec             	push   -0x14(%ebp)
801098eb:	e8 62 00 00 00       	call   80109952 <arp_broadcast>
801098f0:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801098f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098f6:	83 ec 08             	sub    $0x8,%esp
801098f9:	50                   	push   %eax
801098fa:	ff 75 ec             	push   -0x14(%ebp)
801098fd:	e8 28 fd ff ff       	call   8010962a <i8254_send>
80109902:	83 c4 10             	add    $0x10,%esp
80109905:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109908:	eb 22                	jmp    8010992c <arp_scan+0x65>
      microdelay(1);
8010990a:	83 ec 0c             	sub    $0xc,%esp
8010990d:	6a 01                	push   $0x1
8010990f:	e8 25 92 ff ff       	call   80102b39 <microdelay>
80109914:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109917:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010991a:	83 ec 08             	sub    $0x8,%esp
8010991d:	50                   	push   %eax
8010991e:	ff 75 ec             	push   -0x14(%ebp)
80109921:	e8 04 fd ff ff       	call   8010962a <i8254_send>
80109926:	83 c4 10             	add    $0x10,%esp
80109929:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010992c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109930:	74 d8                	je     8010990a <arp_scan+0x43>
    }
    kfree((char *)send);
80109932:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109935:	83 ec 0c             	sub    $0xc,%esp
80109938:	50                   	push   %eax
80109939:	e8 d0 8d ff ff       	call   8010270e <kfree>
8010993e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109941:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109945:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010994c:	7e 88                	jle    801098d6 <arp_scan+0xf>
  }
}
8010994e:	90                   	nop
8010994f:	90                   	nop
80109950:	c9                   	leave
80109951:	c3                   	ret

80109952 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109952:	55                   	push   %ebp
80109953:	89 e5                	mov    %esp,%ebp
80109955:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109958:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010995c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109960:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109964:	8b 45 10             	mov    0x10(%ebp),%eax
80109967:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010996a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109971:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109977:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010997e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109984:	8b 45 0c             	mov    0xc(%ebp),%eax
80109987:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010998d:	8b 45 08             	mov    0x8(%ebp),%eax
80109990:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109993:	8b 45 08             	mov    0x8(%ebp),%eax
80109996:	83 c0 0e             	add    $0xe,%eax
80109999:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010999c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801099a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801099aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ad:	83 ec 04             	sub    $0x4,%esp
801099b0:	6a 06                	push   $0x6
801099b2:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801099b5:	52                   	push   %edx
801099b6:	50                   	push   %eax
801099b7:	e8 df ba ff ff       	call   8010549b <memmove>
801099bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801099bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c2:	83 c0 06             	add    $0x6,%eax
801099c5:	83 ec 04             	sub    $0x4,%esp
801099c8:	6a 06                	push   $0x6
801099ca:	68 b4 7a 19 80       	push   $0x80197ab4
801099cf:	50                   	push   %eax
801099d0:	e8 c6 ba ff ff       	call   8010549b <memmove>
801099d5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801099d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099db:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801099e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099e3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801099e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ec:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801099f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801099f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099fa:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a03:	8d 50 12             	lea    0x12(%eax),%edx
80109a06:	83 ec 04             	sub    $0x4,%esp
80109a09:	6a 06                	push   $0x6
80109a0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109a0e:	50                   	push   %eax
80109a0f:	52                   	push   %edx
80109a10:	e8 86 ba ff ff       	call   8010549b <memmove>
80109a15:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a1b:	8d 50 18             	lea    0x18(%eax),%edx
80109a1e:	83 ec 04             	sub    $0x4,%esp
80109a21:	6a 04                	push   $0x4
80109a23:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a26:	50                   	push   %eax
80109a27:	52                   	push   %edx
80109a28:	e8 6e ba ff ff       	call   8010549b <memmove>
80109a2d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a33:	83 c0 08             	add    $0x8,%eax
80109a36:	83 ec 04             	sub    $0x4,%esp
80109a39:	6a 06                	push   $0x6
80109a3b:	68 b4 7a 19 80       	push   $0x80197ab4
80109a40:	50                   	push   %eax
80109a41:	e8 55 ba ff ff       	call   8010549b <memmove>
80109a46:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a4c:	83 c0 0e             	add    $0xe,%eax
80109a4f:	83 ec 04             	sub    $0x4,%esp
80109a52:	6a 04                	push   $0x4
80109a54:	68 04 f5 10 80       	push   $0x8010f504
80109a59:	50                   	push   %eax
80109a5a:	e8 3c ba ff ff       	call   8010549b <memmove>
80109a5f:	83 c4 10             	add    $0x10,%esp
}
80109a62:	90                   	nop
80109a63:	c9                   	leave
80109a64:	c3                   	ret

80109a65 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109a65:	55                   	push   %ebp
80109a66:	89 e5                	mov    %esp,%ebp
80109a68:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6e:	83 c0 0e             	add    $0xe,%eax
80109a71:	83 ec 0c             	sub    $0xc,%esp
80109a74:	50                   	push   %eax
80109a75:	e8 bc 00 00 00       	call   80109b36 <arp_table_search>
80109a7a:	83 c4 10             	add    $0x10,%esp
80109a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109a80:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109a84:	78 2d                	js     80109ab3 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109a86:	8b 45 08             	mov    0x8(%ebp),%eax
80109a89:	8d 48 08             	lea    0x8(%eax),%ecx
80109a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a8f:	89 d0                	mov    %edx,%eax
80109a91:	c1 e0 02             	shl    $0x2,%eax
80109a94:	01 d0                	add    %edx,%eax
80109a96:	01 c0                	add    %eax,%eax
80109a98:	01 d0                	add    %edx,%eax
80109a9a:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109a9f:	83 c0 04             	add    $0x4,%eax
80109aa2:	83 ec 04             	sub    $0x4,%esp
80109aa5:	6a 06                	push   $0x6
80109aa7:	51                   	push   %ecx
80109aa8:	50                   	push   %eax
80109aa9:	e8 ed b9 ff ff       	call   8010549b <memmove>
80109aae:	83 c4 10             	add    $0x10,%esp
80109ab1:	eb 70                	jmp    80109b23 <arp_table_update+0xbe>
  }else{
    index += 1;
80109ab3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109ab7:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109aba:	8b 45 08             	mov    0x8(%ebp),%eax
80109abd:	8d 48 08             	lea    0x8(%eax),%ecx
80109ac0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ac3:	89 d0                	mov    %edx,%eax
80109ac5:	c1 e0 02             	shl    $0x2,%eax
80109ac8:	01 d0                	add    %edx,%eax
80109aca:	01 c0                	add    %eax,%eax
80109acc:	01 d0                	add    %edx,%eax
80109ace:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109ad3:	83 c0 04             	add    $0x4,%eax
80109ad6:	83 ec 04             	sub    $0x4,%esp
80109ad9:	6a 06                	push   $0x6
80109adb:	51                   	push   %ecx
80109adc:	50                   	push   %eax
80109add:	e8 b9 b9 ff ff       	call   8010549b <memmove>
80109ae2:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae8:	8d 48 0e             	lea    0xe(%eax),%ecx
80109aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109aee:	89 d0                	mov    %edx,%eax
80109af0:	c1 e0 02             	shl    $0x2,%eax
80109af3:	01 d0                	add    %edx,%eax
80109af5:	01 c0                	add    %eax,%eax
80109af7:	01 d0                	add    %edx,%eax
80109af9:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109afe:	83 ec 04             	sub    $0x4,%esp
80109b01:	6a 04                	push   $0x4
80109b03:	51                   	push   %ecx
80109b04:	50                   	push   %eax
80109b05:	e8 91 b9 ff ff       	call   8010549b <memmove>
80109b0a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b10:	89 d0                	mov    %edx,%eax
80109b12:	c1 e0 02             	shl    $0x2,%eax
80109b15:	01 d0                	add    %edx,%eax
80109b17:	01 c0                	add    %eax,%eax
80109b19:	01 d0                	add    %edx,%eax
80109b1b:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109b20:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109b23:	83 ec 0c             	sub    $0xc,%esp
80109b26:	68 c0 7a 19 80       	push   $0x80197ac0
80109b2b:	e8 83 00 00 00       	call   80109bb3 <print_arp_table>
80109b30:	83 c4 10             	add    $0x10,%esp
}
80109b33:	90                   	nop
80109b34:	c9                   	leave
80109b35:	c3                   	ret

80109b36 <arp_table_search>:

int arp_table_search(uchar *ip){
80109b36:	55                   	push   %ebp
80109b37:	89 e5                	mov    %esp,%ebp
80109b39:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109b3c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109b43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109b4a:	eb 59                	jmp    80109ba5 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109b4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109b4f:	89 d0                	mov    %edx,%eax
80109b51:	c1 e0 02             	shl    $0x2,%eax
80109b54:	01 d0                	add    %edx,%eax
80109b56:	01 c0                	add    %eax,%eax
80109b58:	01 d0                	add    %edx,%eax
80109b5a:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109b5f:	83 ec 04             	sub    $0x4,%esp
80109b62:	6a 04                	push   $0x4
80109b64:	ff 75 08             	push   0x8(%ebp)
80109b67:	50                   	push   %eax
80109b68:	e8 d6 b8 ff ff       	call   80105443 <memcmp>
80109b6d:	83 c4 10             	add    $0x10,%esp
80109b70:	85 c0                	test   %eax,%eax
80109b72:	75 05                	jne    80109b79 <arp_table_search+0x43>
      return i;
80109b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b77:	eb 38                	jmp    80109bb1 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109b79:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109b7c:	89 d0                	mov    %edx,%eax
80109b7e:	c1 e0 02             	shl    $0x2,%eax
80109b81:	01 d0                	add    %edx,%eax
80109b83:	01 c0                	add    %eax,%eax
80109b85:	01 d0                	add    %edx,%eax
80109b87:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109b8c:	0f b6 00             	movzbl (%eax),%eax
80109b8f:	84 c0                	test   %al,%al
80109b91:	75 0e                	jne    80109ba1 <arp_table_search+0x6b>
80109b93:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109b97:	75 08                	jne    80109ba1 <arp_table_search+0x6b>
      empty = -i;
80109b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b9c:	f7 d8                	neg    %eax
80109b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ba1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ba5:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109ba9:	7e a1                	jle    80109b4c <arp_table_search+0x16>
    }
  }
  return empty-1;
80109bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bae:	83 e8 01             	sub    $0x1,%eax
}
80109bb1:	c9                   	leave
80109bb2:	c3                   	ret

80109bb3 <print_arp_table>:

void print_arp_table(){
80109bb3:	55                   	push   %ebp
80109bb4:	89 e5                	mov    %esp,%ebp
80109bb6:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109bc0:	e9 92 00 00 00       	jmp    80109c57 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109bc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109bc8:	89 d0                	mov    %edx,%eax
80109bca:	c1 e0 02             	shl    $0x2,%eax
80109bcd:	01 d0                	add    %edx,%eax
80109bcf:	01 c0                	add    %eax,%eax
80109bd1:	01 d0                	add    %edx,%eax
80109bd3:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109bd8:	0f b6 00             	movzbl (%eax),%eax
80109bdb:	84 c0                	test   %al,%al
80109bdd:	74 74                	je     80109c53 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109bdf:	83 ec 08             	sub    $0x8,%esp
80109be2:	ff 75 f4             	push   -0xc(%ebp)
80109be5:	68 0f cc 10 80       	push   $0x8010cc0f
80109bea:	e8 05 68 ff ff       	call   801003f4 <cprintf>
80109bef:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109bf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109bf5:	89 d0                	mov    %edx,%eax
80109bf7:	c1 e0 02             	shl    $0x2,%eax
80109bfa:	01 d0                	add    %edx,%eax
80109bfc:	01 c0                	add    %eax,%eax
80109bfe:	01 d0                	add    %edx,%eax
80109c00:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109c05:	83 ec 0c             	sub    $0xc,%esp
80109c08:	50                   	push   %eax
80109c09:	e8 54 02 00 00       	call   80109e62 <print_ipv4>
80109c0e:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109c11:	83 ec 0c             	sub    $0xc,%esp
80109c14:	68 1e cc 10 80       	push   $0x8010cc1e
80109c19:	e8 d6 67 ff ff       	call   801003f4 <cprintf>
80109c1e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c24:	89 d0                	mov    %edx,%eax
80109c26:	c1 e0 02             	shl    $0x2,%eax
80109c29:	01 d0                	add    %edx,%eax
80109c2b:	01 c0                	add    %eax,%eax
80109c2d:	01 d0                	add    %edx,%eax
80109c2f:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109c34:	83 c0 04             	add    $0x4,%eax
80109c37:	83 ec 0c             	sub    $0xc,%esp
80109c3a:	50                   	push   %eax
80109c3b:	e8 70 02 00 00       	call   80109eb0 <print_mac>
80109c40:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109c43:	83 ec 0c             	sub    $0xc,%esp
80109c46:	68 20 cc 10 80       	push   $0x8010cc20
80109c4b:	e8 a4 67 ff ff       	call   801003f4 <cprintf>
80109c50:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109c53:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109c57:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109c5b:	0f 8e 64 ff ff ff    	jle    80109bc5 <print_arp_table+0x12>
    }
  }
}
80109c61:	90                   	nop
80109c62:	90                   	nop
80109c63:	c9                   	leave
80109c64:	c3                   	ret

80109c65 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109c65:	55                   	push   %ebp
80109c66:	89 e5                	mov    %esp,%ebp
80109c68:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109c6b:	8b 45 10             	mov    0x10(%ebp),%eax
80109c6e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109c74:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c7d:	83 c0 0e             	add    $0xe,%eax
80109c80:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c86:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109c91:	8b 45 08             	mov    0x8(%ebp),%eax
80109c94:	8d 50 08             	lea    0x8(%eax),%edx
80109c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9a:	83 ec 04             	sub    $0x4,%esp
80109c9d:	6a 06                	push   $0x6
80109c9f:	52                   	push   %edx
80109ca0:	50                   	push   %eax
80109ca1:	e8 f5 b7 ff ff       	call   8010549b <memmove>
80109ca6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cac:	83 c0 06             	add    $0x6,%eax
80109caf:	83 ec 04             	sub    $0x4,%esp
80109cb2:	6a 06                	push   $0x6
80109cb4:	68 b4 7a 19 80       	push   $0x80197ab4
80109cb9:	50                   	push   %eax
80109cba:	e8 dc b7 ff ff       	call   8010549b <memmove>
80109cbf:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cc5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ccd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cdd:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ce4:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109cea:	8b 45 08             	mov    0x8(%ebp),%eax
80109ced:	8d 50 08             	lea    0x8(%eax),%edx
80109cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf3:	83 c0 12             	add    $0x12,%eax
80109cf6:	83 ec 04             	sub    $0x4,%esp
80109cf9:	6a 06                	push   $0x6
80109cfb:	52                   	push   %edx
80109cfc:	50                   	push   %eax
80109cfd:	e8 99 b7 ff ff       	call   8010549b <memmove>
80109d02:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109d05:	8b 45 08             	mov    0x8(%ebp),%eax
80109d08:	8d 50 0e             	lea    0xe(%eax),%edx
80109d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d0e:	83 c0 18             	add    $0x18,%eax
80109d11:	83 ec 04             	sub    $0x4,%esp
80109d14:	6a 04                	push   $0x4
80109d16:	52                   	push   %edx
80109d17:	50                   	push   %eax
80109d18:	e8 7e b7 ff ff       	call   8010549b <memmove>
80109d1d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d23:	83 c0 08             	add    $0x8,%eax
80109d26:	83 ec 04             	sub    $0x4,%esp
80109d29:	6a 06                	push   $0x6
80109d2b:	68 b4 7a 19 80       	push   $0x80197ab4
80109d30:	50                   	push   %eax
80109d31:	e8 65 b7 ff ff       	call   8010549b <memmove>
80109d36:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d3c:	83 c0 0e             	add    $0xe,%eax
80109d3f:	83 ec 04             	sub    $0x4,%esp
80109d42:	6a 04                	push   $0x4
80109d44:	68 04 f5 10 80       	push   $0x8010f504
80109d49:	50                   	push   %eax
80109d4a:	e8 4c b7 ff ff       	call   8010549b <memmove>
80109d4f:	83 c4 10             	add    $0x10,%esp
}
80109d52:	90                   	nop
80109d53:	c9                   	leave
80109d54:	c3                   	ret

80109d55 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109d55:	55                   	push   %ebp
80109d56:	89 e5                	mov    %esp,%ebp
80109d58:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109d5b:	83 ec 0c             	sub    $0xc,%esp
80109d5e:	68 22 cc 10 80       	push   $0x8010cc22
80109d63:	e8 8c 66 ff ff       	call   801003f4 <cprintf>
80109d68:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6e:	83 c0 0e             	add    $0xe,%eax
80109d71:	83 ec 0c             	sub    $0xc,%esp
80109d74:	50                   	push   %eax
80109d75:	e8 e8 00 00 00       	call   80109e62 <print_ipv4>
80109d7a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d7d:	83 ec 0c             	sub    $0xc,%esp
80109d80:	68 20 cc 10 80       	push   $0x8010cc20
80109d85:	e8 6a 66 ff ff       	call   801003f4 <cprintf>
80109d8a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d90:	83 c0 08             	add    $0x8,%eax
80109d93:	83 ec 0c             	sub    $0xc,%esp
80109d96:	50                   	push   %eax
80109d97:	e8 14 01 00 00       	call   80109eb0 <print_mac>
80109d9c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d9f:	83 ec 0c             	sub    $0xc,%esp
80109da2:	68 20 cc 10 80       	push   $0x8010cc20
80109da7:	e8 48 66 ff ff       	call   801003f4 <cprintf>
80109dac:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109daf:	83 ec 0c             	sub    $0xc,%esp
80109db2:	68 39 cc 10 80       	push   $0x8010cc39
80109db7:	e8 38 66 ff ff       	call   801003f4 <cprintf>
80109dbc:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc2:	83 c0 18             	add    $0x18,%eax
80109dc5:	83 ec 0c             	sub    $0xc,%esp
80109dc8:	50                   	push   %eax
80109dc9:	e8 94 00 00 00       	call   80109e62 <print_ipv4>
80109dce:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109dd1:	83 ec 0c             	sub    $0xc,%esp
80109dd4:	68 20 cc 10 80       	push   $0x8010cc20
80109dd9:	e8 16 66 ff ff       	call   801003f4 <cprintf>
80109dde:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109de1:	8b 45 08             	mov    0x8(%ebp),%eax
80109de4:	83 c0 12             	add    $0x12,%eax
80109de7:	83 ec 0c             	sub    $0xc,%esp
80109dea:	50                   	push   %eax
80109deb:	e8 c0 00 00 00       	call   80109eb0 <print_mac>
80109df0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109df3:	83 ec 0c             	sub    $0xc,%esp
80109df6:	68 20 cc 10 80       	push   $0x8010cc20
80109dfb:	e8 f4 65 ff ff       	call   801003f4 <cprintf>
80109e00:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109e03:	83 ec 0c             	sub    $0xc,%esp
80109e06:	68 50 cc 10 80       	push   $0x8010cc50
80109e0b:	e8 e4 65 ff ff       	call   801003f4 <cprintf>
80109e10:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109e13:	8b 45 08             	mov    0x8(%ebp),%eax
80109e16:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e1a:	66 3d 00 01          	cmp    $0x100,%ax
80109e1e:	75 12                	jne    80109e32 <print_arp_info+0xdd>
80109e20:	83 ec 0c             	sub    $0xc,%esp
80109e23:	68 5c cc 10 80       	push   $0x8010cc5c
80109e28:	e8 c7 65 ff ff       	call   801003f4 <cprintf>
80109e2d:	83 c4 10             	add    $0x10,%esp
80109e30:	eb 1d                	jmp    80109e4f <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109e32:	8b 45 08             	mov    0x8(%ebp),%eax
80109e35:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e39:	66 3d 00 02          	cmp    $0x200,%ax
80109e3d:	75 10                	jne    80109e4f <print_arp_info+0xfa>
    cprintf("Reply\n");
80109e3f:	83 ec 0c             	sub    $0xc,%esp
80109e42:	68 65 cc 10 80       	push   $0x8010cc65
80109e47:	e8 a8 65 ff ff       	call   801003f4 <cprintf>
80109e4c:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109e4f:	83 ec 0c             	sub    $0xc,%esp
80109e52:	68 20 cc 10 80       	push   $0x8010cc20
80109e57:	e8 98 65 ff ff       	call   801003f4 <cprintf>
80109e5c:	83 c4 10             	add    $0x10,%esp
}
80109e5f:	90                   	nop
80109e60:	c9                   	leave
80109e61:	c3                   	ret

80109e62 <print_ipv4>:

void print_ipv4(uchar *ip){
80109e62:	55                   	push   %ebp
80109e63:	89 e5                	mov    %esp,%ebp
80109e65:	53                   	push   %ebx
80109e66:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109e69:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6c:	83 c0 03             	add    $0x3,%eax
80109e6f:	0f b6 00             	movzbl (%eax),%eax
80109e72:	0f b6 d8             	movzbl %al,%ebx
80109e75:	8b 45 08             	mov    0x8(%ebp),%eax
80109e78:	83 c0 02             	add    $0x2,%eax
80109e7b:	0f b6 00             	movzbl (%eax),%eax
80109e7e:	0f b6 c8             	movzbl %al,%ecx
80109e81:	8b 45 08             	mov    0x8(%ebp),%eax
80109e84:	83 c0 01             	add    $0x1,%eax
80109e87:	0f b6 00             	movzbl (%eax),%eax
80109e8a:	0f b6 d0             	movzbl %al,%edx
80109e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e90:	0f b6 00             	movzbl (%eax),%eax
80109e93:	0f b6 c0             	movzbl %al,%eax
80109e96:	83 ec 0c             	sub    $0xc,%esp
80109e99:	53                   	push   %ebx
80109e9a:	51                   	push   %ecx
80109e9b:	52                   	push   %edx
80109e9c:	50                   	push   %eax
80109e9d:	68 6c cc 10 80       	push   $0x8010cc6c
80109ea2:	e8 4d 65 ff ff       	call   801003f4 <cprintf>
80109ea7:	83 c4 20             	add    $0x20,%esp
}
80109eaa:	90                   	nop
80109eab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109eae:	c9                   	leave
80109eaf:	c3                   	ret

80109eb0 <print_mac>:

void print_mac(uchar *mac){
80109eb0:	55                   	push   %ebp
80109eb1:	89 e5                	mov    %esp,%ebp
80109eb3:	57                   	push   %edi
80109eb4:	56                   	push   %esi
80109eb5:	53                   	push   %ebx
80109eb6:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ebc:	83 c0 05             	add    $0x5,%eax
80109ebf:	0f b6 00             	movzbl (%eax),%eax
80109ec2:	0f b6 f8             	movzbl %al,%edi
80109ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ec8:	83 c0 04             	add    $0x4,%eax
80109ecb:	0f b6 00             	movzbl (%eax),%eax
80109ece:	0f b6 f0             	movzbl %al,%esi
80109ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ed4:	83 c0 03             	add    $0x3,%eax
80109ed7:	0f b6 00             	movzbl (%eax),%eax
80109eda:	0f b6 d8             	movzbl %al,%ebx
80109edd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee0:	83 c0 02             	add    $0x2,%eax
80109ee3:	0f b6 00             	movzbl (%eax),%eax
80109ee6:	0f b6 c8             	movzbl %al,%ecx
80109ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80109eec:	83 c0 01             	add    $0x1,%eax
80109eef:	0f b6 00             	movzbl (%eax),%eax
80109ef2:	0f b6 d0             	movzbl %al,%edx
80109ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef8:	0f b6 00             	movzbl (%eax),%eax
80109efb:	0f b6 c0             	movzbl %al,%eax
80109efe:	83 ec 04             	sub    $0x4,%esp
80109f01:	57                   	push   %edi
80109f02:	56                   	push   %esi
80109f03:	53                   	push   %ebx
80109f04:	51                   	push   %ecx
80109f05:	52                   	push   %edx
80109f06:	50                   	push   %eax
80109f07:	68 84 cc 10 80       	push   $0x8010cc84
80109f0c:	e8 e3 64 ff ff       	call   801003f4 <cprintf>
80109f11:	83 c4 20             	add    $0x20,%esp
}
80109f14:	90                   	nop
80109f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109f18:	5b                   	pop    %ebx
80109f19:	5e                   	pop    %esi
80109f1a:	5f                   	pop    %edi
80109f1b:	5d                   	pop    %ebp
80109f1c:	c3                   	ret

80109f1d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109f1d:	55                   	push   %ebp
80109f1e:	89 e5                	mov    %esp,%ebp
80109f20:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109f23:	8b 45 08             	mov    0x8(%ebp),%eax
80109f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109f29:	8b 45 08             	mov    0x8(%ebp),%eax
80109f2c:	83 c0 0e             	add    $0xe,%eax
80109f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f35:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f39:	3c 08                	cmp    $0x8,%al
80109f3b:	75 1b                	jne    80109f58 <eth_proc+0x3b>
80109f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f40:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f44:	3c 06                	cmp    $0x6,%al
80109f46:	75 10                	jne    80109f58 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109f48:	83 ec 0c             	sub    $0xc,%esp
80109f4b:	ff 75 f0             	push   -0x10(%ebp)
80109f4e:	e8 01 f8 ff ff       	call   80109754 <arp_proc>
80109f53:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109f56:	eb 24                	jmp    80109f7c <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f5b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f5f:	3c 08                	cmp    $0x8,%al
80109f61:	75 19                	jne    80109f7c <eth_proc+0x5f>
80109f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f66:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f6a:	84 c0                	test   %al,%al
80109f6c:	75 0e                	jne    80109f7c <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109f6e:	83 ec 0c             	sub    $0xc,%esp
80109f71:	ff 75 08             	push   0x8(%ebp)
80109f74:	e8 8d 00 00 00       	call   8010a006 <ipv4_proc>
80109f79:	83 c4 10             	add    $0x10,%esp
}
80109f7c:	90                   	nop
80109f7d:	c9                   	leave
80109f7e:	c3                   	ret

80109f7f <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109f7f:	55                   	push   %ebp
80109f80:	89 e5                	mov    %esp,%ebp
80109f82:	83 ec 04             	sub    $0x4,%esp
80109f85:	8b 45 08             	mov    0x8(%ebp),%eax
80109f88:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109f8c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109f90:	66 c1 c0 08          	rol    $0x8,%ax
}
80109f94:	c9                   	leave
80109f95:	c3                   	ret

80109f96 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109f96:	55                   	push   %ebp
80109f97:	89 e5                	mov    %esp,%ebp
80109f99:	83 ec 04             	sub    $0x4,%esp
80109f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fa3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fa7:	66 c1 c0 08          	rol    $0x8,%ax
}
80109fab:	c9                   	leave
80109fac:	c3                   	ret

80109fad <H2N_uint>:

uint H2N_uint(uint value){
80109fad:	55                   	push   %ebp
80109fae:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb3:	c1 e0 18             	shl    $0x18,%eax
80109fb6:	25 00 00 00 0f       	and    $0xf000000,%eax
80109fbb:	89 c2                	mov    %eax,%edx
80109fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc0:	c1 e0 08             	shl    $0x8,%eax
80109fc3:	25 00 f0 00 00       	and    $0xf000,%eax
80109fc8:	09 c2                	or     %eax,%edx
80109fca:	8b 45 08             	mov    0x8(%ebp),%eax
80109fcd:	c1 e8 08             	shr    $0x8,%eax
80109fd0:	83 e0 0f             	and    $0xf,%eax
80109fd3:	01 d0                	add    %edx,%eax
}
80109fd5:	5d                   	pop    %ebp
80109fd6:	c3                   	ret

80109fd7 <N2H_uint>:

uint N2H_uint(uint value){
80109fd7:	55                   	push   %ebp
80109fd8:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109fda:	8b 45 08             	mov    0x8(%ebp),%eax
80109fdd:	c1 e0 18             	shl    $0x18,%eax
80109fe0:	89 c2                	mov    %eax,%edx
80109fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe5:	c1 e0 08             	shl    $0x8,%eax
80109fe8:	25 00 00 ff 00       	and    $0xff0000,%eax
80109fed:	01 c2                	add    %eax,%edx
80109fef:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff2:	c1 e8 08             	shr    $0x8,%eax
80109ff5:	25 00 ff 00 00       	and    $0xff00,%eax
80109ffa:	01 c2                	add    %eax,%edx
80109ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80109fff:	c1 e8 18             	shr    $0x18,%eax
8010a002:	01 d0                	add    %edx,%eax
}
8010a004:	5d                   	pop    %ebp
8010a005:	c3                   	ret

8010a006 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a006:	55                   	push   %ebp
8010a007:	89 e5                	mov    %esp,%ebp
8010a009:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a00c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00f:	83 c0 0e             	add    $0xe,%eax
8010a012:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a015:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a018:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a01c:	0f b7 d0             	movzwl %ax,%edx
8010a01f:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a024:	39 c2                	cmp    %eax,%edx
8010a026:	74 60                	je     8010a088 <ipv4_proc+0x82>
8010a028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a02b:	83 c0 0c             	add    $0xc,%eax
8010a02e:	83 ec 04             	sub    $0x4,%esp
8010a031:	6a 04                	push   $0x4
8010a033:	50                   	push   %eax
8010a034:	68 04 f5 10 80       	push   $0x8010f504
8010a039:	e8 05 b4 ff ff       	call   80105443 <memcmp>
8010a03e:	83 c4 10             	add    $0x10,%esp
8010a041:	85 c0                	test   %eax,%eax
8010a043:	74 43                	je     8010a088 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010a045:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a048:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a04c:	0f b7 c0             	movzwl %ax,%eax
8010a04f:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a054:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a057:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a05b:	3c 01                	cmp    $0x1,%al
8010a05d:	75 10                	jne    8010a06f <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010a05f:	83 ec 0c             	sub    $0xc,%esp
8010a062:	ff 75 08             	push   0x8(%ebp)
8010a065:	e8 a3 00 00 00       	call   8010a10d <icmp_proc>
8010a06a:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a06d:	eb 19                	jmp    8010a088 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a06f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a072:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a076:	3c 06                	cmp    $0x6,%al
8010a078:	75 0e                	jne    8010a088 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010a07a:	83 ec 0c             	sub    $0xc,%esp
8010a07d:	ff 75 08             	push   0x8(%ebp)
8010a080:	e8 b3 03 00 00       	call   8010a438 <tcp_proc>
8010a085:	83 c4 10             	add    $0x10,%esp
}
8010a088:	90                   	nop
8010a089:	c9                   	leave
8010a08a:	c3                   	ret

8010a08b <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a08b:	55                   	push   %ebp
8010a08c:	89 e5                	mov    %esp,%ebp
8010a08e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a091:	8b 45 08             	mov    0x8(%ebp),%eax
8010a094:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a09a:	0f b6 00             	movzbl (%eax),%eax
8010a09d:	83 e0 0f             	and    $0xf,%eax
8010a0a0:	01 c0                	add    %eax,%eax
8010a0a2:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a0a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a0ac:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a0b3:	eb 48                	jmp    8010a0fd <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a0b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a0b8:	01 c0                	add    %eax,%eax
8010a0ba:	89 c2                	mov    %eax,%edx
8010a0bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0bf:	01 d0                	add    %edx,%eax
8010a0c1:	0f b6 00             	movzbl (%eax),%eax
8010a0c4:	0f b6 c0             	movzbl %al,%eax
8010a0c7:	c1 e0 08             	shl    $0x8,%eax
8010a0ca:	89 c2                	mov    %eax,%edx
8010a0cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a0cf:	01 c0                	add    %eax,%eax
8010a0d1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0d7:	01 c8                	add    %ecx,%eax
8010a0d9:	0f b6 00             	movzbl (%eax),%eax
8010a0dc:	0f b6 c0             	movzbl %al,%eax
8010a0df:	01 d0                	add    %edx,%eax
8010a0e1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a0e4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a0eb:	76 0c                	jbe    8010a0f9 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a0ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a0f0:	0f b7 c0             	movzwl %ax,%eax
8010a0f3:	83 c0 01             	add    $0x1,%eax
8010a0f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a0f9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a0fd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a101:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a104:	7c af                	jl     8010a0b5 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010a106:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a109:	f7 d0                	not    %eax
}
8010a10b:	c9                   	leave
8010a10c:	c3                   	ret

8010a10d <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a10d:	55                   	push   %ebp
8010a10e:	89 e5                	mov    %esp,%ebp
8010a110:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a113:	8b 45 08             	mov    0x8(%ebp),%eax
8010a116:	83 c0 0e             	add    $0xe,%eax
8010a119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a11c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a11f:	0f b6 00             	movzbl (%eax),%eax
8010a122:	0f b6 c0             	movzbl %al,%eax
8010a125:	83 e0 0f             	and    $0xf,%eax
8010a128:	c1 e0 02             	shl    $0x2,%eax
8010a12b:	89 c2                	mov    %eax,%edx
8010a12d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a130:	01 d0                	add    %edx,%eax
8010a132:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a135:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a138:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a13c:	84 c0                	test   %al,%al
8010a13e:	75 4f                	jne    8010a18f <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a140:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a143:	0f b6 00             	movzbl (%eax),%eax
8010a146:	3c 08                	cmp    $0x8,%al
8010a148:	75 45                	jne    8010a18f <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a14a:	e8 59 86 ff ff       	call   801027a8 <kalloc>
8010a14f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a152:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a159:	83 ec 04             	sub    $0x4,%esp
8010a15c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a15f:	50                   	push   %eax
8010a160:	ff 75 ec             	push   -0x14(%ebp)
8010a163:	ff 75 08             	push   0x8(%ebp)
8010a166:	e8 78 00 00 00       	call   8010a1e3 <icmp_reply_pkt_create>
8010a16b:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a16e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a171:	83 ec 08             	sub    $0x8,%esp
8010a174:	50                   	push   %eax
8010a175:	ff 75 ec             	push   -0x14(%ebp)
8010a178:	e8 ad f4 ff ff       	call   8010962a <i8254_send>
8010a17d:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a180:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a183:	83 ec 0c             	sub    $0xc,%esp
8010a186:	50                   	push   %eax
8010a187:	e8 82 85 ff ff       	call   8010270e <kfree>
8010a18c:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a18f:	90                   	nop
8010a190:	c9                   	leave
8010a191:	c3                   	ret

8010a192 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a192:	55                   	push   %ebp
8010a193:	89 e5                	mov    %esp,%ebp
8010a195:	53                   	push   %ebx
8010a196:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a199:	8b 45 08             	mov    0x8(%ebp),%eax
8010a19c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1a0:	0f b7 c0             	movzwl %ax,%eax
8010a1a3:	83 ec 0c             	sub    $0xc,%esp
8010a1a6:	50                   	push   %eax
8010a1a7:	e8 d3 fd ff ff       	call   80109f7f <N2H_ushort>
8010a1ac:	83 c4 10             	add    $0x10,%esp
8010a1af:	0f b7 d8             	movzwl %ax,%ebx
8010a1b2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1b5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a1b9:	0f b7 c0             	movzwl %ax,%eax
8010a1bc:	83 ec 0c             	sub    $0xc,%esp
8010a1bf:	50                   	push   %eax
8010a1c0:	e8 ba fd ff ff       	call   80109f7f <N2H_ushort>
8010a1c5:	83 c4 10             	add    $0x10,%esp
8010a1c8:	0f b7 c0             	movzwl %ax,%eax
8010a1cb:	83 ec 04             	sub    $0x4,%esp
8010a1ce:	53                   	push   %ebx
8010a1cf:	50                   	push   %eax
8010a1d0:	68 a3 cc 10 80       	push   $0x8010cca3
8010a1d5:	e8 1a 62 ff ff       	call   801003f4 <cprintf>
8010a1da:	83 c4 10             	add    $0x10,%esp
}
8010a1dd:	90                   	nop
8010a1de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a1e1:	c9                   	leave
8010a1e2:	c3                   	ret

8010a1e3 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a1e3:	55                   	push   %ebp
8010a1e4:	89 e5                	mov    %esp,%ebp
8010a1e6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a1e9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a1ef:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f2:	83 c0 0e             	add    $0xe,%eax
8010a1f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a1f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1fb:	0f b6 00             	movzbl (%eax),%eax
8010a1fe:	0f b6 c0             	movzbl %al,%eax
8010a201:	83 e0 0f             	and    $0xf,%eax
8010a204:	c1 e0 02             	shl    $0x2,%eax
8010a207:	89 c2                	mov    %eax,%edx
8010a209:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a20c:	01 d0                	add    %edx,%eax
8010a20e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a211:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a214:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a217:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a21a:	83 c0 0e             	add    $0xe,%eax
8010a21d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a223:	83 c0 14             	add    $0x14,%eax
8010a226:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a229:	8b 45 10             	mov    0x10(%ebp),%eax
8010a22c:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a232:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a235:	8d 50 06             	lea    0x6(%eax),%edx
8010a238:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a23b:	83 ec 04             	sub    $0x4,%esp
8010a23e:	6a 06                	push   $0x6
8010a240:	52                   	push   %edx
8010a241:	50                   	push   %eax
8010a242:	e8 54 b2 ff ff       	call   8010549b <memmove>
8010a247:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a24a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a24d:	83 c0 06             	add    $0x6,%eax
8010a250:	83 ec 04             	sub    $0x4,%esp
8010a253:	6a 06                	push   $0x6
8010a255:	68 b4 7a 19 80       	push   $0x80197ab4
8010a25a:	50                   	push   %eax
8010a25b:	e8 3b b2 ff ff       	call   8010549b <memmove>
8010a260:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a263:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a266:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a26a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a26d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a271:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a274:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a277:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a27e:	83 ec 0c             	sub    $0xc,%esp
8010a281:	6a 54                	push   $0x54
8010a283:	e8 0e fd ff ff       	call   80109f96 <H2N_ushort>
8010a288:	83 c4 10             	add    $0x10,%esp
8010a28b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a28e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a292:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2a0:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a2a7:	83 c0 01             	add    $0x1,%eax
8010a2aa:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a2b0:	83 ec 0c             	sub    $0xc,%esp
8010a2b3:	68 00 40 00 00       	push   $0x4000
8010a2b8:	e8 d9 fc ff ff       	call   80109f96 <H2N_ushort>
8010a2bd:	83 c4 10             	add    $0x10,%esp
8010a2c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2c3:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a2c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ca:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a2ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a2d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d8:	83 c0 0c             	add    $0xc,%eax
8010a2db:	83 ec 04             	sub    $0x4,%esp
8010a2de:	6a 04                	push   $0x4
8010a2e0:	68 04 f5 10 80       	push   $0x8010f504
8010a2e5:	50                   	push   %eax
8010a2e6:	e8 b0 b1 ff ff       	call   8010549b <memmove>
8010a2eb:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2f1:	8d 50 0c             	lea    0xc(%eax),%edx
8010a2f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f7:	83 c0 10             	add    $0x10,%eax
8010a2fa:	83 ec 04             	sub    $0x4,%esp
8010a2fd:	6a 04                	push   $0x4
8010a2ff:	52                   	push   %edx
8010a300:	50                   	push   %eax
8010a301:	e8 95 b1 ff ff       	call   8010549b <memmove>
8010a306:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a315:	83 ec 0c             	sub    $0xc,%esp
8010a318:	50                   	push   %eax
8010a319:	e8 6d fd ff ff       	call   8010a08b <ipv4_chksum>
8010a31e:	83 c4 10             	add    $0x10,%esp
8010a321:	0f b7 c0             	movzwl %ax,%eax
8010a324:	83 ec 0c             	sub    $0xc,%esp
8010a327:	50                   	push   %eax
8010a328:	e8 69 fc ff ff       	call   80109f96 <H2N_ushort>
8010a32d:	83 c4 10             	add    $0x10,%esp
8010a330:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a333:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33a:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a33d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a340:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a344:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a347:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a34b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a34e:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a352:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a355:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a359:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a35c:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a360:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a363:	8d 50 08             	lea    0x8(%eax),%edx
8010a366:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a369:	83 c0 08             	add    $0x8,%eax
8010a36c:	83 ec 04             	sub    $0x4,%esp
8010a36f:	6a 08                	push   $0x8
8010a371:	52                   	push   %edx
8010a372:	50                   	push   %eax
8010a373:	e8 23 b1 ff ff       	call   8010549b <memmove>
8010a378:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a37b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a37e:	8d 50 10             	lea    0x10(%eax),%edx
8010a381:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a384:	83 c0 10             	add    $0x10,%eax
8010a387:	83 ec 04             	sub    $0x4,%esp
8010a38a:	6a 30                	push   $0x30
8010a38c:	52                   	push   %edx
8010a38d:	50                   	push   %eax
8010a38e:	e8 08 b1 ff ff       	call   8010549b <memmove>
8010a393:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a396:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a399:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a39f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3a2:	83 ec 0c             	sub    $0xc,%esp
8010a3a5:	50                   	push   %eax
8010a3a6:	e8 1c 00 00 00       	call   8010a3c7 <icmp_chksum>
8010a3ab:	83 c4 10             	add    $0x10,%esp
8010a3ae:	0f b7 c0             	movzwl %ax,%eax
8010a3b1:	83 ec 0c             	sub    $0xc,%esp
8010a3b4:	50                   	push   %eax
8010a3b5:	e8 dc fb ff ff       	call   80109f96 <H2N_ushort>
8010a3ba:	83 c4 10             	add    $0x10,%esp
8010a3bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3c0:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a3c4:	90                   	nop
8010a3c5:	c9                   	leave
8010a3c6:	c3                   	ret

8010a3c7 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a3c7:	55                   	push   %ebp
8010a3c8:	89 e5                	mov    %esp,%ebp
8010a3ca:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a3cd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a3d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a3da:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a3e1:	eb 48                	jmp    8010a42b <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a3e6:	01 c0                	add    %eax,%eax
8010a3e8:	89 c2                	mov    %eax,%edx
8010a3ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3ed:	01 d0                	add    %edx,%eax
8010a3ef:	0f b6 00             	movzbl (%eax),%eax
8010a3f2:	0f b6 c0             	movzbl %al,%eax
8010a3f5:	c1 e0 08             	shl    $0x8,%eax
8010a3f8:	89 c2                	mov    %eax,%edx
8010a3fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a3fd:	01 c0                	add    %eax,%eax
8010a3ff:	8d 48 01             	lea    0x1(%eax),%ecx
8010a402:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a405:	01 c8                	add    %ecx,%eax
8010a407:	0f b6 00             	movzbl (%eax),%eax
8010a40a:	0f b6 c0             	movzbl %al,%eax
8010a40d:	01 d0                	add    %edx,%eax
8010a40f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a412:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a419:	76 0c                	jbe    8010a427 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a41b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a41e:	0f b7 c0             	movzwl %ax,%eax
8010a421:	83 c0 01             	add    $0x1,%eax
8010a424:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a427:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a42b:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a42f:	7e b2                	jle    8010a3e3 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a431:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a434:	f7 d0                	not    %eax
}
8010a436:	c9                   	leave
8010a437:	c3                   	ret

8010a438 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a438:	55                   	push   %ebp
8010a439:	89 e5                	mov    %esp,%ebp
8010a43b:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a43e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a441:	83 c0 0e             	add    $0xe,%eax
8010a444:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a44a:	0f b6 00             	movzbl (%eax),%eax
8010a44d:	0f b6 c0             	movzbl %al,%eax
8010a450:	83 e0 0f             	and    $0xf,%eax
8010a453:	c1 e0 02             	shl    $0x2,%eax
8010a456:	89 c2                	mov    %eax,%edx
8010a458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a45b:	01 d0                	add    %edx,%eax
8010a45d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a460:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a463:	83 c0 14             	add    $0x14,%eax
8010a466:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a469:	e8 3a 83 ff ff       	call   801027a8 <kalloc>
8010a46e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a471:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a478:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a47b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a47f:	0f b6 c0             	movzbl %al,%eax
8010a482:	83 e0 02             	and    $0x2,%eax
8010a485:	85 c0                	test   %eax,%eax
8010a487:	74 3d                	je     8010a4c6 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a489:	83 ec 0c             	sub    $0xc,%esp
8010a48c:	6a 00                	push   $0x0
8010a48e:	6a 12                	push   $0x12
8010a490:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a493:	50                   	push   %eax
8010a494:	ff 75 e8             	push   -0x18(%ebp)
8010a497:	ff 75 08             	push   0x8(%ebp)
8010a49a:	e8 a2 01 00 00       	call   8010a641 <tcp_pkt_create>
8010a49f:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a4a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a4a5:	83 ec 08             	sub    $0x8,%esp
8010a4a8:	50                   	push   %eax
8010a4a9:	ff 75 e8             	push   -0x18(%ebp)
8010a4ac:	e8 79 f1 ff ff       	call   8010962a <i8254_send>
8010a4b1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a4b4:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a4b9:	83 c0 01             	add    $0x1,%eax
8010a4bc:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a4c1:	e9 69 01 00 00       	jmp    8010a62f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a4c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4c9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4cd:	3c 18                	cmp    $0x18,%al
8010a4cf:	0f 85 10 01 00 00    	jne    8010a5e5 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a4d5:	83 ec 04             	sub    $0x4,%esp
8010a4d8:	6a 03                	push   $0x3
8010a4da:	68 be cc 10 80       	push   $0x8010ccbe
8010a4df:	ff 75 ec             	push   -0x14(%ebp)
8010a4e2:	e8 5c af ff ff       	call   80105443 <memcmp>
8010a4e7:	83 c4 10             	add    $0x10,%esp
8010a4ea:	85 c0                	test   %eax,%eax
8010a4ec:	74 74                	je     8010a562 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a4ee:	83 ec 0c             	sub    $0xc,%esp
8010a4f1:	68 c2 cc 10 80       	push   $0x8010ccc2
8010a4f6:	e8 f9 5e ff ff       	call   801003f4 <cprintf>
8010a4fb:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a4fe:	83 ec 0c             	sub    $0xc,%esp
8010a501:	6a 00                	push   $0x0
8010a503:	6a 10                	push   $0x10
8010a505:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a508:	50                   	push   %eax
8010a509:	ff 75 e8             	push   -0x18(%ebp)
8010a50c:	ff 75 08             	push   0x8(%ebp)
8010a50f:	e8 2d 01 00 00       	call   8010a641 <tcp_pkt_create>
8010a514:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a517:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a51a:	83 ec 08             	sub    $0x8,%esp
8010a51d:	50                   	push   %eax
8010a51e:	ff 75 e8             	push   -0x18(%ebp)
8010a521:	e8 04 f1 ff ff       	call   8010962a <i8254_send>
8010a526:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a529:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a52c:	83 c0 36             	add    $0x36,%eax
8010a52f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a532:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a535:	50                   	push   %eax
8010a536:	ff 75 e0             	push   -0x20(%ebp)
8010a539:	6a 00                	push   $0x0
8010a53b:	6a 00                	push   $0x0
8010a53d:	e8 5a 04 00 00       	call   8010a99c <http_proc>
8010a542:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a545:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a548:	83 ec 0c             	sub    $0xc,%esp
8010a54b:	50                   	push   %eax
8010a54c:	6a 18                	push   $0x18
8010a54e:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a551:	50                   	push   %eax
8010a552:	ff 75 e8             	push   -0x18(%ebp)
8010a555:	ff 75 08             	push   0x8(%ebp)
8010a558:	e8 e4 00 00 00       	call   8010a641 <tcp_pkt_create>
8010a55d:	83 c4 20             	add    $0x20,%esp
8010a560:	eb 62                	jmp    8010a5c4 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a562:	83 ec 0c             	sub    $0xc,%esp
8010a565:	6a 00                	push   $0x0
8010a567:	6a 10                	push   $0x10
8010a569:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a56c:	50                   	push   %eax
8010a56d:	ff 75 e8             	push   -0x18(%ebp)
8010a570:	ff 75 08             	push   0x8(%ebp)
8010a573:	e8 c9 00 00 00       	call   8010a641 <tcp_pkt_create>
8010a578:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a57b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a57e:	83 ec 08             	sub    $0x8,%esp
8010a581:	50                   	push   %eax
8010a582:	ff 75 e8             	push   -0x18(%ebp)
8010a585:	e8 a0 f0 ff ff       	call   8010962a <i8254_send>
8010a58a:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a58d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a590:	83 c0 36             	add    $0x36,%eax
8010a593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a596:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a599:	50                   	push   %eax
8010a59a:	ff 75 e4             	push   -0x1c(%ebp)
8010a59d:	6a 00                	push   $0x0
8010a59f:	6a 00                	push   $0x0
8010a5a1:	e8 f6 03 00 00       	call   8010a99c <http_proc>
8010a5a6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a5a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a5ac:	83 ec 0c             	sub    $0xc,%esp
8010a5af:	50                   	push   %eax
8010a5b0:	6a 18                	push   $0x18
8010a5b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5b5:	50                   	push   %eax
8010a5b6:	ff 75 e8             	push   -0x18(%ebp)
8010a5b9:	ff 75 08             	push   0x8(%ebp)
8010a5bc:	e8 80 00 00 00       	call   8010a641 <tcp_pkt_create>
8010a5c1:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a5c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5c7:	83 ec 08             	sub    $0x8,%esp
8010a5ca:	50                   	push   %eax
8010a5cb:	ff 75 e8             	push   -0x18(%ebp)
8010a5ce:	e8 57 f0 ff ff       	call   8010962a <i8254_send>
8010a5d3:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a5d6:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a5db:	83 c0 01             	add    $0x1,%eax
8010a5de:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a5e3:	eb 4a                	jmp    8010a62f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a5e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5e8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a5ec:	3c 10                	cmp    $0x10,%al
8010a5ee:	75 3f                	jne    8010a62f <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a5f0:	a1 88 7d 19 80       	mov    0x80197d88,%eax
8010a5f5:	83 f8 01             	cmp    $0x1,%eax
8010a5f8:	75 35                	jne    8010a62f <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a5fa:	83 ec 0c             	sub    $0xc,%esp
8010a5fd:	6a 00                	push   $0x0
8010a5ff:	6a 01                	push   $0x1
8010a601:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a604:	50                   	push   %eax
8010a605:	ff 75 e8             	push   -0x18(%ebp)
8010a608:	ff 75 08             	push   0x8(%ebp)
8010a60b:	e8 31 00 00 00       	call   8010a641 <tcp_pkt_create>
8010a610:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a613:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a616:	83 ec 08             	sub    $0x8,%esp
8010a619:	50                   	push   %eax
8010a61a:	ff 75 e8             	push   -0x18(%ebp)
8010a61d:	e8 08 f0 ff ff       	call   8010962a <i8254_send>
8010a622:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a625:	c7 05 88 7d 19 80 00 	movl   $0x0,0x80197d88
8010a62c:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a62f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a632:	83 ec 0c             	sub    $0xc,%esp
8010a635:	50                   	push   %eax
8010a636:	e8 d3 80 ff ff       	call   8010270e <kfree>
8010a63b:	83 c4 10             	add    $0x10,%esp
}
8010a63e:	90                   	nop
8010a63f:	c9                   	leave
8010a640:	c3                   	ret

8010a641 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a641:	55                   	push   %ebp
8010a642:	89 e5                	mov    %esp,%ebp
8010a644:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a647:	8b 45 08             	mov    0x8(%ebp),%eax
8010a64a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a64d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a650:	83 c0 0e             	add    $0xe,%eax
8010a653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a656:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a659:	0f b6 00             	movzbl (%eax),%eax
8010a65c:	0f b6 c0             	movzbl %al,%eax
8010a65f:	83 e0 0f             	and    $0xf,%eax
8010a662:	c1 e0 02             	shl    $0x2,%eax
8010a665:	89 c2                	mov    %eax,%edx
8010a667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a66a:	01 d0                	add    %edx,%eax
8010a66c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a66f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a672:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a675:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a678:	83 c0 0e             	add    $0xe,%eax
8010a67b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a67e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a681:	83 c0 14             	add    $0x14,%eax
8010a684:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a687:	8b 45 18             	mov    0x18(%ebp),%eax
8010a68a:	8d 50 36             	lea    0x36(%eax),%edx
8010a68d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a690:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a692:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a695:	8d 50 06             	lea    0x6(%eax),%edx
8010a698:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a69b:	83 ec 04             	sub    $0x4,%esp
8010a69e:	6a 06                	push   $0x6
8010a6a0:	52                   	push   %edx
8010a6a1:	50                   	push   %eax
8010a6a2:	e8 f4 ad ff ff       	call   8010549b <memmove>
8010a6a7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a6aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6ad:	83 c0 06             	add    $0x6,%eax
8010a6b0:	83 ec 04             	sub    $0x4,%esp
8010a6b3:	6a 06                	push   $0x6
8010a6b5:	68 b4 7a 19 80       	push   $0x80197ab4
8010a6ba:	50                   	push   %eax
8010a6bb:	e8 db ad ff ff       	call   8010549b <memmove>
8010a6c0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a6c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6c6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a6ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6cd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a6d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6d4:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a6d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6da:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a6de:	8b 45 18             	mov    0x18(%ebp),%eax
8010a6e1:	83 c0 28             	add    $0x28,%eax
8010a6e4:	0f b7 c0             	movzwl %ax,%eax
8010a6e7:	83 ec 0c             	sub    $0xc,%esp
8010a6ea:	50                   	push   %eax
8010a6eb:	e8 a6 f8 ff ff       	call   80109f96 <H2N_ushort>
8010a6f0:	83 c4 10             	add    $0x10,%esp
8010a6f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a6f6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a6fa:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a704:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a708:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a70f:	83 c0 01             	add    $0x1,%eax
8010a712:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a718:	83 ec 0c             	sub    $0xc,%esp
8010a71b:	6a 00                	push   $0x0
8010a71d:	e8 74 f8 ff ff       	call   80109f96 <H2N_ushort>
8010a722:	83 c4 10             	add    $0x10,%esp
8010a725:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a728:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a72c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a72f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a736:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a73a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a73d:	83 c0 0c             	add    $0xc,%eax
8010a740:	83 ec 04             	sub    $0x4,%esp
8010a743:	6a 04                	push   $0x4
8010a745:	68 04 f5 10 80       	push   $0x8010f504
8010a74a:	50                   	push   %eax
8010a74b:	e8 4b ad ff ff       	call   8010549b <memmove>
8010a750:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a753:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a756:	8d 50 0c             	lea    0xc(%eax),%edx
8010a759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a75c:	83 c0 10             	add    $0x10,%eax
8010a75f:	83 ec 04             	sub    $0x4,%esp
8010a762:	6a 04                	push   $0x4
8010a764:	52                   	push   %edx
8010a765:	50                   	push   %eax
8010a766:	e8 30 ad ff ff       	call   8010549b <memmove>
8010a76b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a76e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a771:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a77a:	83 ec 0c             	sub    $0xc,%esp
8010a77d:	50                   	push   %eax
8010a77e:	e8 08 f9 ff ff       	call   8010a08b <ipv4_chksum>
8010a783:	83 c4 10             	add    $0x10,%esp
8010a786:	0f b7 c0             	movzwl %ax,%eax
8010a789:	83 ec 0c             	sub    $0xc,%esp
8010a78c:	50                   	push   %eax
8010a78d:	e8 04 f8 ff ff       	call   80109f96 <H2N_ushort>
8010a792:	83 c4 10             	add    $0x10,%esp
8010a795:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a798:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a79c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a79f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a7a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7a6:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a7a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7ac:	0f b7 10             	movzwl (%eax),%edx
8010a7af:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7b2:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a7b6:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a7bb:	83 ec 0c             	sub    $0xc,%esp
8010a7be:	50                   	push   %eax
8010a7bf:	e8 e9 f7 ff ff       	call   80109fad <H2N_uint>
8010a7c4:	83 c4 10             	add    $0x10,%esp
8010a7c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a7ca:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a7cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7d0:	8b 40 04             	mov    0x4(%eax),%eax
8010a7d3:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a7d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7dc:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a7df:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7e2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a7e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7e9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a7ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7f0:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a7f4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a7f7:	89 c2                	mov    %eax,%edx
8010a7f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7fc:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a7ff:	83 ec 0c             	sub    $0xc,%esp
8010a802:	68 90 38 00 00       	push   $0x3890
8010a807:	e8 8a f7 ff ff       	call   80109f96 <H2N_ushort>
8010a80c:	83 c4 10             	add    $0x10,%esp
8010a80f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a812:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a816:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a819:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a81f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a822:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a82b:	83 ec 0c             	sub    $0xc,%esp
8010a82e:	50                   	push   %eax
8010a82f:	e8 1f 00 00 00       	call   8010a853 <tcp_chksum>
8010a834:	83 c4 10             	add    $0x10,%esp
8010a837:	83 c0 08             	add    $0x8,%eax
8010a83a:	0f b7 c0             	movzwl %ax,%eax
8010a83d:	83 ec 0c             	sub    $0xc,%esp
8010a840:	50                   	push   %eax
8010a841:	e8 50 f7 ff ff       	call   80109f96 <H2N_ushort>
8010a846:	83 c4 10             	add    $0x10,%esp
8010a849:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a84c:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a850:	90                   	nop
8010a851:	c9                   	leave
8010a852:	c3                   	ret

8010a853 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a853:	55                   	push   %ebp
8010a854:	89 e5                	mov    %esp,%ebp
8010a856:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a859:	8b 45 08             	mov    0x8(%ebp),%eax
8010a85c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a85f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a862:	83 c0 14             	add    $0x14,%eax
8010a865:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a868:	83 ec 04             	sub    $0x4,%esp
8010a86b:	6a 04                	push   $0x4
8010a86d:	68 04 f5 10 80       	push   $0x8010f504
8010a872:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a875:	50                   	push   %eax
8010a876:	e8 20 ac ff ff       	call   8010549b <memmove>
8010a87b:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a87e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a881:	83 c0 0c             	add    $0xc,%eax
8010a884:	83 ec 04             	sub    $0x4,%esp
8010a887:	6a 04                	push   $0x4
8010a889:	50                   	push   %eax
8010a88a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a88d:	83 c0 04             	add    $0x4,%eax
8010a890:	50                   	push   %eax
8010a891:	e8 05 ac ff ff       	call   8010549b <memmove>
8010a896:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a899:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a89d:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a8a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8a4:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a8a8:	0f b7 c0             	movzwl %ax,%eax
8010a8ab:	83 ec 0c             	sub    $0xc,%esp
8010a8ae:	50                   	push   %eax
8010a8af:	e8 cb f6 ff ff       	call   80109f7f <N2H_ushort>
8010a8b4:	83 c4 10             	add    $0x10,%esp
8010a8b7:	83 e8 14             	sub    $0x14,%eax
8010a8ba:	0f b7 c0             	movzwl %ax,%eax
8010a8bd:	83 ec 0c             	sub    $0xc,%esp
8010a8c0:	50                   	push   %eax
8010a8c1:	e8 d0 f6 ff ff       	call   80109f96 <H2N_ushort>
8010a8c6:	83 c4 10             	add    $0x10,%esp
8010a8c9:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a8cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a8d4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a8da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a8e1:	eb 33                	jmp    8010a916 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8e6:	01 c0                	add    %eax,%eax
8010a8e8:	89 c2                	mov    %eax,%edx
8010a8ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a8ed:	01 d0                	add    %edx,%eax
8010a8ef:	0f b6 00             	movzbl (%eax),%eax
8010a8f2:	0f b6 c0             	movzbl %al,%eax
8010a8f5:	c1 e0 08             	shl    $0x8,%eax
8010a8f8:	89 c2                	mov    %eax,%edx
8010a8fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8fd:	01 c0                	add    %eax,%eax
8010a8ff:	8d 48 01             	lea    0x1(%eax),%ecx
8010a902:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a905:	01 c8                	add    %ecx,%eax
8010a907:	0f b6 00             	movzbl (%eax),%eax
8010a90a:	0f b6 c0             	movzbl %al,%eax
8010a90d:	01 d0                	add    %edx,%eax
8010a90f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a912:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a916:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a91a:	7e c7                	jle    8010a8e3 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a91c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a91f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a922:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a929:	eb 33                	jmp    8010a95e <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a92b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a92e:	01 c0                	add    %eax,%eax
8010a930:	89 c2                	mov    %eax,%edx
8010a932:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a935:	01 d0                	add    %edx,%eax
8010a937:	0f b6 00             	movzbl (%eax),%eax
8010a93a:	0f b6 c0             	movzbl %al,%eax
8010a93d:	c1 e0 08             	shl    $0x8,%eax
8010a940:	89 c2                	mov    %eax,%edx
8010a942:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a945:	01 c0                	add    %eax,%eax
8010a947:	8d 48 01             	lea    0x1(%eax),%ecx
8010a94a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a94d:	01 c8                	add    %ecx,%eax
8010a94f:	0f b6 00             	movzbl (%eax),%eax
8010a952:	0f b6 c0             	movzbl %al,%eax
8010a955:	01 d0                	add    %edx,%eax
8010a957:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a95a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a95e:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a962:	0f b7 c0             	movzwl %ax,%eax
8010a965:	83 ec 0c             	sub    $0xc,%esp
8010a968:	50                   	push   %eax
8010a969:	e8 11 f6 ff ff       	call   80109f7f <N2H_ushort>
8010a96e:	83 c4 10             	add    $0x10,%esp
8010a971:	66 d1 e8             	shr    $1,%ax
8010a974:	0f b7 c0             	movzwl %ax,%eax
8010a977:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a97a:	7c af                	jl     8010a92b <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a97f:	c1 e8 10             	shr    $0x10,%eax
8010a982:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a985:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a988:	f7 d0                	not    %eax
}
8010a98a:	c9                   	leave
8010a98b:	c3                   	ret

8010a98c <tcp_fin>:

void tcp_fin(){
8010a98c:	55                   	push   %ebp
8010a98d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a98f:	c7 05 88 7d 19 80 01 	movl   $0x1,0x80197d88
8010a996:	00 00 00 
}
8010a999:	90                   	nop
8010a99a:	5d                   	pop    %ebp
8010a99b:	c3                   	ret

8010a99c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a99c:	55                   	push   %ebp
8010a99d:	89 e5                	mov    %esp,%ebp
8010a99f:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a9a2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9a5:	83 ec 04             	sub    $0x4,%esp
8010a9a8:	6a 00                	push   $0x0
8010a9aa:	68 cb cc 10 80       	push   $0x8010cccb
8010a9af:	50                   	push   %eax
8010a9b0:	e8 65 00 00 00       	call   8010aa1a <http_strcpy>
8010a9b5:	83 c4 10             	add    $0x10,%esp
8010a9b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a9bb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9be:	83 ec 04             	sub    $0x4,%esp
8010a9c1:	ff 75 f4             	push   -0xc(%ebp)
8010a9c4:	68 de cc 10 80       	push   $0x8010ccde
8010a9c9:	50                   	push   %eax
8010a9ca:	e8 4b 00 00 00       	call   8010aa1a <http_strcpy>
8010a9cf:	83 c4 10             	add    $0x10,%esp
8010a9d2:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a9d5:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9d8:	83 ec 04             	sub    $0x4,%esp
8010a9db:	ff 75 f4             	push   -0xc(%ebp)
8010a9de:	68 f9 cc 10 80       	push   $0x8010ccf9
8010a9e3:	50                   	push   %eax
8010a9e4:	e8 31 00 00 00       	call   8010aa1a <http_strcpy>
8010a9e9:	83 c4 10             	add    $0x10,%esp
8010a9ec:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9f2:	83 e0 01             	and    $0x1,%eax
8010a9f5:	85 c0                	test   %eax,%eax
8010a9f7:	74 11                	je     8010aa0a <http_proc+0x6e>
    char *payload = (char *)send;
8010a9f9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a9fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a9ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa02:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa05:	01 d0                	add    %edx,%eax
8010aa07:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010aa0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa0d:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa10:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010aa12:	e8 75 ff ff ff       	call   8010a98c <tcp_fin>
}
8010aa17:	90                   	nop
8010aa18:	c9                   	leave
8010aa19:	c3                   	ret

8010aa1a <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010aa1a:	55                   	push   %ebp
8010aa1b:	89 e5                	mov    %esp,%ebp
8010aa1d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010aa20:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010aa27:	eb 20                	jmp    8010aa49 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010aa29:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa2c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa2f:	01 d0                	add    %edx,%eax
8010aa31:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010aa34:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa37:	01 ca                	add    %ecx,%edx
8010aa39:	89 d1                	mov    %edx,%ecx
8010aa3b:	8b 55 08             	mov    0x8(%ebp),%edx
8010aa3e:	01 ca                	add    %ecx,%edx
8010aa40:	0f b6 00             	movzbl (%eax),%eax
8010aa43:	88 02                	mov    %al,(%edx)
    i++;
8010aa45:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010aa49:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aa4c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aa4f:	01 d0                	add    %edx,%eax
8010aa51:	0f b6 00             	movzbl (%eax),%eax
8010aa54:	84 c0                	test   %al,%al
8010aa56:	75 d1                	jne    8010aa29 <http_strcpy+0xf>
  }
  return i;
8010aa58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aa5b:	c9                   	leave
8010aa5c:	c3                   	ret

8010aa5d <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010aa5d:	55                   	push   %ebp
8010aa5e:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010aa60:	c7 05 90 7d 19 80 c2 	movl   $0x8010f5c2,0x80197d90
8010aa67:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010aa6a:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010aa6f:	c1 e8 09             	shr    $0x9,%eax
8010aa72:	a3 8c 7d 19 80       	mov    %eax,0x80197d8c
}
8010aa77:	90                   	nop
8010aa78:	5d                   	pop    %ebp
8010aa79:	c3                   	ret

8010aa7a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010aa7a:	55                   	push   %ebp
8010aa7b:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010aa7d:	90                   	nop
8010aa7e:	5d                   	pop    %ebp
8010aa7f:	c3                   	ret

8010aa80 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010aa80:	55                   	push   %ebp
8010aa81:	89 e5                	mov    %esp,%ebp
8010aa83:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010aa86:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa89:	83 c0 0c             	add    $0xc,%eax
8010aa8c:	83 ec 0c             	sub    $0xc,%esp
8010aa8f:	50                   	push   %eax
8010aa90:	e8 40 a6 ff ff       	call   801050d5 <holdingsleep>
8010aa95:	83 c4 10             	add    $0x10,%esp
8010aa98:	85 c0                	test   %eax,%eax
8010aa9a:	75 0d                	jne    8010aaa9 <iderw+0x29>
    panic("iderw: buf not locked");
8010aa9c:	83 ec 0c             	sub    $0xc,%esp
8010aa9f:	68 0a cd 10 80       	push   $0x8010cd0a
8010aaa4:	e8 00 5b ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010aaa9:	8b 45 08             	mov    0x8(%ebp),%eax
8010aaac:	8b 00                	mov    (%eax),%eax
8010aaae:	83 e0 06             	and    $0x6,%eax
8010aab1:	83 f8 02             	cmp    $0x2,%eax
8010aab4:	75 0d                	jne    8010aac3 <iderw+0x43>
    panic("iderw: nothing to do");
8010aab6:	83 ec 0c             	sub    $0xc,%esp
8010aab9:	68 20 cd 10 80       	push   $0x8010cd20
8010aabe:	e8 e6 5a ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010aac3:	8b 45 08             	mov    0x8(%ebp),%eax
8010aac6:	8b 40 04             	mov    0x4(%eax),%eax
8010aac9:	83 f8 01             	cmp    $0x1,%eax
8010aacc:	74 0d                	je     8010aadb <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010aace:	83 ec 0c             	sub    $0xc,%esp
8010aad1:	68 35 cd 10 80       	push   $0x8010cd35
8010aad6:	e8 ce 5a ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010aadb:	8b 45 08             	mov    0x8(%ebp),%eax
8010aade:	8b 40 08             	mov    0x8(%eax),%eax
8010aae1:	8b 15 8c 7d 19 80    	mov    0x80197d8c,%edx
8010aae7:	39 d0                	cmp    %edx,%eax
8010aae9:	72 0d                	jb     8010aaf8 <iderw+0x78>
    panic("iderw: block out of range");
8010aaeb:	83 ec 0c             	sub    $0xc,%esp
8010aaee:	68 53 cd 10 80       	push   $0x8010cd53
8010aaf3:	e8 b1 5a ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010aaf8:	8b 15 90 7d 19 80    	mov    0x80197d90,%edx
8010aafe:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab01:	8b 40 08             	mov    0x8(%eax),%eax
8010ab04:	c1 e0 09             	shl    $0x9,%eax
8010ab07:	01 d0                	add    %edx,%eax
8010ab09:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010ab0c:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab0f:	8b 00                	mov    (%eax),%eax
8010ab11:	83 e0 04             	and    $0x4,%eax
8010ab14:	85 c0                	test   %eax,%eax
8010ab16:	74 2b                	je     8010ab43 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010ab18:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab1b:	8b 00                	mov    (%eax),%eax
8010ab1d:	83 e0 fb             	and    $0xfffffffb,%eax
8010ab20:	89 c2                	mov    %eax,%edx
8010ab22:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab25:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010ab27:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab2a:	83 c0 5c             	add    $0x5c,%eax
8010ab2d:	83 ec 04             	sub    $0x4,%esp
8010ab30:	68 00 02 00 00       	push   $0x200
8010ab35:	50                   	push   %eax
8010ab36:	ff 75 f4             	push   -0xc(%ebp)
8010ab39:	e8 5d a9 ff ff       	call   8010549b <memmove>
8010ab3e:	83 c4 10             	add    $0x10,%esp
8010ab41:	eb 1a                	jmp    8010ab5d <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010ab43:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab46:	83 c0 5c             	add    $0x5c,%eax
8010ab49:	83 ec 04             	sub    $0x4,%esp
8010ab4c:	68 00 02 00 00       	push   $0x200
8010ab51:	ff 75 f4             	push   -0xc(%ebp)
8010ab54:	50                   	push   %eax
8010ab55:	e8 41 a9 ff ff       	call   8010549b <memmove>
8010ab5a:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010ab5d:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab60:	8b 00                	mov    (%eax),%eax
8010ab62:	83 c8 02             	or     $0x2,%eax
8010ab65:	89 c2                	mov    %eax,%edx
8010ab67:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab6a:	89 10                	mov    %edx,(%eax)
}
8010ab6c:	90                   	nop
8010ab6d:	c9                   	leave
8010ab6e:	c3                   	ret
