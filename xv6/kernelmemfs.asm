
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
8010006f:	68 00 ab 10 80       	push   $0x8010ab00
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 39 50 00 00       	call   801050b7 <initlock>
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
801000bd:	68 07 ab 10 80       	push   $0x8010ab07
801000c2:	50                   	push   %eax
801000c3:	e8 92 4e 00 00       	call   80104f5a <initsleeplock>
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
80100101:	e8 d3 4f 00 00       	call   801050d9 <acquire>
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
80100140:	e8 02 50 00 00       	call   80105147 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 3f 4e 00 00       	call   80104f96 <acquiresleep>
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
801001c1:	e8 81 4f 00 00       	call   80105147 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 be 4d 00 00       	call   80104f96 <acquiresleep>
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
801001f5:	68 0e ab 10 80       	push   $0x8010ab0e
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
8010022d:	e8 c1 a7 00 00       	call   8010a9f3 <iderw>
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
8010024a:	e8 f9 4d 00 00       	call   80105048 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f ab 10 80       	push   $0x8010ab1f
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
80100278:	e8 76 a7 00 00       	call   8010a9f3 <iderw>
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
80100293:	e8 b0 4d 00 00       	call   80105048 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 ab 10 80       	push   $0x8010ab26
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 3f 4d 00 00       	call   80104ffa <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 0e 4e 00 00       	call   801050d9 <acquire>
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
80100336:	e8 0c 4e 00 00       	call   80105147 <release>
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
80100410:	e8 c4 4c 00 00       	call   801050d9 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d ab 10 80       	push   $0x8010ab2d
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
80100510:	c7 45 ec 36 ab 10 80 	movl   $0x8010ab36,-0x14(%ebp)
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
8010059e:	e8 a4 4b 00 00       	call   80105147 <release>
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
801005c7:	68 3d ab 10 80       	push   $0x8010ab3d
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
801005e6:	68 51 ab 10 80       	push   $0x8010ab51
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 96 4b 00 00       	call   80105199 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 ab 10 80       	push   $0x8010ab53
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
801006a1:	e8 ba 82 00 00       	call   80108960 <graphic_scroll_up>
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
801006f4:	e8 67 82 00 00       	call   80108960 <graphic_scroll_up>
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
80100756:	e8 72 82 00 00       	call   801089cd <font_render>
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
80100793:	e8 42 66 00 00       	call   80106dda <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 35 66 00 00       	call   80106dda <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 28 66 00 00       	call   80106dda <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 18 66 00 00       	call   80106dda <uartputc>
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
801007eb:	e8 e9 48 00 00       	call   801050d9 <acquire>
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
8010096a:	e8 d8 47 00 00       	call   80105147 <release>
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
801009a2:	e8 32 47 00 00       	call   801050d9 <acquire>
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
801009c3:	e8 7f 47 00 00       	call   80105147 <release>
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
80100a6e:	e8 d4 46 00 00       	call   80105147 <release>
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
80100aac:	e8 28 46 00 00       	call   801050d9 <acquire>
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
80100aee:	e8 54 46 00 00       	call   80105147 <release>
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
80100b1c:	68 57 ab 10 80       	push   $0x8010ab57
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 8c 45 00 00       	call   801050b7 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 5f ab 10 80 	movl   $0x8010ab5f,-0xc(%ebp)
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
80100bbf:	68 75 ab 10 80       	push   $0x8010ab75
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
80100c1b:	e8 b6 71 00 00       	call   80107dd6 <setupkvm>
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
80100cc1:	e8 0a 75 00 00       	call   801081d0 <allocuvm>
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
80100d07:	e8 f7 73 00 00       	call   80108103 <loaduvm>
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
80100d76:	e8 55 74 00 00       	call   801081d0 <allocuvm>
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
80100d9a:	e8 93 76 00 00       	call   80108432 <clearpteu>
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
80100dd3:	e8 c5 47 00 00       	call   8010559d <strlen>
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
80100e00:	e8 98 47 00 00       	call   8010559d <strlen>
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
80100e26:	e8 a6 77 00 00       	call   801085d1 <copyout>
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
80100ec2:	e8 0a 77 00 00       	call   801085d1 <copyout>
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
80100f10:	e8 3d 46 00 00       	call   80105552 <safestrcpy>
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
80100f53:	e8 9c 6f 00 00       	call   80107ef4 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 33 74 00 00       	call   80108399 <freevm>
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
80100fa1:	e8 f3 73 00 00       	call   80108399 <freevm>
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
80100fd2:	68 81 ab 10 80       	push   $0x8010ab81
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 d6 40 00 00       	call   801050b7 <initlock>
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
80100ff5:	e8 df 40 00 00       	call   801050d9 <acquire>
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
80101022:	e8 20 41 00 00       	call   80105147 <release>
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
80101045:	e8 fd 40 00 00       	call   80105147 <release>
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
80101062:	e8 72 40 00 00       	call   801050d9 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 88 ab 10 80       	push   $0x8010ab88
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
80101098:	e8 aa 40 00 00       	call   80105147 <release>
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
801010b3:	e8 21 40 00 00       	call   801050d9 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 90 ab 10 80       	push   $0x8010ab90
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
801010f3:	e8 4f 40 00 00       	call   80105147 <release>
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
80101141:	e8 01 40 00 00       	call   80105147 <release>
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
80101290:	68 9a ab 10 80       	push   $0x8010ab9a
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
80101393:	68 a3 ab 10 80       	push   $0x8010aba3
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
801013c9:	68 b3 ab 10 80       	push   $0x8010abb3
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
80101401:	e8 08 40 00 00       	call   8010540e <memmove>
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
80101447:	e8 03 3f 00 00       	call   8010534f <memset>
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
801015a5:	68 c0 ab 10 80       	push   $0x8010abc0
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
80101630:	68 d6 ab 10 80       	push   $0x8010abd6
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
80101694:	68 e9 ab 10 80       	push   $0x8010abe9
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 14 3a 00 00       	call   801050b7 <initlock>
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
801016ca:	68 f0 ab 10 80       	push   $0x8010abf0
801016cf:	50                   	push   %eax
801016d0:	e8 85 38 00 00       	call   80104f5a <initsleeplock>
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
80101729:	68 f8 ab 10 80       	push   $0x8010abf8
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
801017a2:	e8 a8 3b 00 00       	call   8010534f <memset>
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
80101809:	68 4b ac 10 80       	push   $0x8010ac4b
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
801018af:	e8 5a 3b 00 00       	call   8010540e <memmove>
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
801018e4:	e8 f0 37 00 00       	call   801050d9 <acquire>
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
80101932:	e8 10 38 00 00       	call   80105147 <release>
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
8010196e:	68 5d ac 10 80       	push   $0x8010ac5d
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
801019ab:	e8 97 37 00 00       	call   80105147 <release>
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
801019c6:	e8 0e 37 00 00       	call   801050d9 <acquire>
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
801019e5:	e8 5d 37 00 00       	call   80105147 <release>
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
80101a0b:	68 6d ac 10 80       	push   $0x8010ac6d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 72 35 00 00       	call   80104f96 <acquiresleep>
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
80101ac9:	e8 40 39 00 00       	call   8010540e <memmove>
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
80101af8:	68 73 ac 10 80       	push   $0x8010ac73
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
80101b1b:	e8 28 35 00 00       	call   80105048 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 82 ac 10 80       	push   $0x8010ac82
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 ad 34 00 00       	call   80104ffa <releasesleep>
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
80101b63:	e8 2e 34 00 00       	call   80104f96 <acquiresleep>
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
80101b89:	e8 4b 35 00 00       	call   801050d9 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 a0 35 00 00       	call   80105147 <release>
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
80101be9:	e8 0c 34 00 00       	call   80104ffa <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 db 34 00 00       	call   801050d9 <acquire>
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
80101c18:	e8 2a 35 00 00       	call   80105147 <release>
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
80101d5c:	68 8a ac 10 80       	push   $0x8010ac8a
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
80101ffa:	e8 0f 34 00 00       	call   8010540e <memmove>
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
8010214a:	e8 bf 32 00 00       	call   8010540e <memmove>
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
801021ca:	e8 d5 32 00 00       	call   801054a4 <strncmp>
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
801021ea:	68 9d ac 10 80       	push   $0x8010ac9d
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
80102219:	68 af ac 10 80       	push   $0x8010acaf
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
801022ee:	68 be ac 10 80       	push   $0x8010acbe
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
80102329:	e8 cc 31 00 00       	call   801054fa <strncpy>
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
80102355:	68 cb ac 10 80       	push   $0x8010accb
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
801023c7:	e8 42 30 00 00       	call   8010540e <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 2b 30 00 00       	call   8010540e <memmove>
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
801025d5:	68 d4 ac 10 80       	push   $0x8010acd4
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
8010267c:	68 06 ad 10 80       	push   $0x8010ad06
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 2c 2a 00 00       	call   801050b7 <initlock>
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
8010273b:	68 0b ad 10 80       	push   $0x8010ad0b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 f8 2b 00 00       	call   8010534f <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 69 29 00 00       	call   801050d9 <acquire>
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
8010279d:	e8 a5 29 00 00       	call   80105147 <release>
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
801027bf:	e8 15 29 00 00       	call   801050d9 <acquire>
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
801027f0:	e8 52 29 00 00       	call   80105147 <release>
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
80102d14:	e8 9d 26 00 00       	call   801053b6 <memcmp>
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
80102e28:	68 11 ad 10 80       	push   $0x8010ad11
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 80 22 00 00       	call   801050b7 <initlock>
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
80102edd:	e8 2c 25 00 00       	call   8010540e <memmove>
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
8010304c:	e8 88 20 00 00       	call   801050d9 <acquire>
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
801030be:	e8 84 20 00 00       	call   80105147 <release>
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
801030df:	e8 f5 1f 00 00       	call   801050d9 <acquire>
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
80103100:	68 15 ad 10 80       	push   $0x8010ad15
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
8010313e:	e8 04 20 00 00       	call   80105147 <release>
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
80103159:	e8 7b 1f 00 00       	call   801050d9 <acquire>
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
80103183:	e8 bf 1f 00 00       	call   80105147 <release>
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
801031ff:	e8 0a 22 00 00       	call   8010540e <memmove>
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
8010329c:	68 24 ad 10 80       	push   $0x8010ad24
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 3a ad 10 80       	push   $0x8010ad3a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 10 1e 00 00       	call   801050d9 <acquire>
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
80103342:	e8 00 1e 00 00       	call   80105147 <release>
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
80103378:	e8 28 55 00 00       	call   801088a5 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 2c 4b 00 00       	call   80107ec3 <kvmalloc>
  mpinit_uefi();
80103397:	e8 d3 52 00 00       	call   8010866f <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 b4 45 00 00       	call   8010795a <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 39 39 00 00       	call   80106cf3 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 f8 33 00 00       	call   801067bc <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 fd 75 00 00       	call   8010a9d0 <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 0e 57 00 00       	call   80108b00 <pci_init>
  arp_scan();
801033f2:	e8 43 64 00 00       	call   8010983a <arp_scan>
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
80103407:	e8 cf 4a 00 00       	call   80107edb <switchkvm>
  seginit();
8010340c:	e8 49 45 00 00       	call   8010795a <seginit>
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
80103433:	68 55 ad 10 80       	push   $0x8010ad55
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 ed 34 00 00       	call   80106932 <idtinit>
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
80103480:	e8 89 1f 00 00       	call   8010540e <memmove>
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
80103607:	68 69 ad 10 80       	push   $0x8010ad69
8010360c:	50                   	push   %eax
8010360d:	e8 a5 1a 00 00       	call   801050b7 <initlock>
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
801036cc:	e8 08 1a 00 00       	call   801050d9 <acquire>
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
8010373f:	e8 03 1a 00 00       	call   80105147 <release>
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
8010375e:	e8 e4 19 00 00       	call   80105147 <release>
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
80103778:	e8 5c 19 00 00       	call   801050d9 <acquire>
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
801037ac:	e8 96 19 00 00       	call   80105147 <release>
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
8010385c:	e8 e6 18 00 00       	call   80105147 <release>
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
80103879:	e8 5b 18 00 00       	call   801050d9 <acquire>
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
80103896:	e8 ac 18 00 00       	call   80105147 <release>
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
8010395b:	e8 e7 17 00 00       	call   80105147 <release>
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
80103988:	68 70 ad 10 80       	push   $0x8010ad70
8010398d:	68 00 4e 19 80       	push   $0x80194e00
80103992:	e8 20 17 00 00       	call   801050b7 <initlock>
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
801039cf:	68 78 ad 10 80       	push   $0x8010ad78
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
80103a24:	68 9e ad 10 80       	push   $0x8010ad9e
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
80103a36:	e8 09 18 00 00       	call   80105244 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 3d 18 00 00       	call   80105291 <popcli>
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
80103a67:	e8 6d 16 00 00       	call   801050d9 <acquire>
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
80103a97:	e8 ab 16 00 00       	call   80105147 <release>
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
80103b24:	e8 26 18 00 00       	call   8010534f <memset>
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
80103b42:	e8 08 18 00 00       	call   8010534f <memset>
80103b47:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 00 4e 19 80       	push   $0x80194e00
80103b52:	e8 f0 15 00 00       	call   80105147 <release>
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
80103b9f:	ba 76 67 10 80       	mov    $0x80106776,%edx
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
80103bc4:	e8 86 17 00 00       	call   8010534f <memset>
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
80103bf5:	e8 dc 41 00 00       	call   80107dd6 <setupkvm>
80103bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfd:	89 42 04             	mov    %eax,0x4(%edx)
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 40 04             	mov    0x4(%eax),%eax
80103c06:	85 c0                	test   %eax,%eax
80103c08:	75 0d                	jne    80103c17 <userinit+0x38>
    panic("userinit: out of memory?");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 ae ad 10 80       	push   $0x8010adae
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
80103c2c:	e8 62 44 00 00       	call   80108093 <inituvm>
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
80103c4b:	e8 ff 16 00 00       	call   8010534f <memset>
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
80103cc5:	68 c7 ad 10 80       	push   $0x8010adc7
80103cca:	50                   	push   %eax
80103ccb:	e8 82 18 00 00       	call   80105552 <safestrcpy>
80103cd0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cd3:	83 ec 0c             	sub    $0xc,%esp
80103cd6:	68 d0 ad 10 80       	push   $0x8010add0
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
80103cf1:	e8 e3 13 00 00       	call   801050d9 <acquire>
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
80103d2a:	e8 18 14 00 00       	call   80105147 <release>
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
80103d67:	e8 64 44 00 00       	call   801081d0 <allocuvm>
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
80103d9b:	e8 35 45 00 00       	call   801082d5 <deallocuvm>
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
80103dc1:	e8 2e 41 00 00       	call   80107ef4 <switchuvm>
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
80103e09:	e8 65 46 00 00       	call   80108473 <copyuvm>
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
80103f03:	e8 4a 16 00 00       	call   80105552 <safestrcpy>
80103f08:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0e:	8b 40 10             	mov    0x10(%eax),%eax
80103f11:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f14:	83 ec 0c             	sub    $0xc,%esp
80103f17:	68 00 4e 19 80       	push   $0x80194e00
80103f1c:	e8 b8 11 00 00       	call   801050d9 <acquire>
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
80103f44:	68 d4 ad 10 80       	push   $0x8010add4
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
80103f91:	e8 b1 11 00 00       	call   80105147 <release>
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
80103fbf:	68 fe ad 10 80       	push   $0x8010adfe
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
80104045:	e8 8f 10 00 00       	call   801050d9 <acquire>
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
801040dc:	68 0b ae 10 80       	push   $0x8010ae0b
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
801040fc:	e8 d8 0f 00 00       	call   801050d9 <acquire>
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
80104167:	e8 2d 42 00 00       	call   80108399 <freevm>
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
801041a6:	e8 9c 0f 00 00       	call   80105147 <release>
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
801041dd:	e8 65 0f 00 00       	call   80105147 <release>
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
8010422e:	e8 a6 0e 00 00       	call   801050d9 <acquire>
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
8010426f:	e8 80 3c 00 00       	call   80107ef4 <switchuvm>
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
80104292:	e8 2d 13 00 00       	call   801055c4 <swtch>
80104297:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010429a:	e8 3c 3c 00 00       	call   80107edb <switchkvm>

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
80104347:	e8 fb 0d 00 00       	call   80105147 <release>
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
8010436a:	e8 a5 0e 00 00       	call   80105214 <holding>
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	85 c0                	test   %eax,%eax
80104374:	75 0d                	jne    80104383 <sched+0x2f>
    panic("sched ptable.lock");
80104376:	83 ec 0c             	sub    $0xc,%esp
80104379:	68 17 ae 10 80       	push   $0x8010ae17
8010437e:	e8 26 c2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104383:	e8 30 f6 ff ff       	call   801039b8 <mycpu>
80104388:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010438e:	83 f8 01             	cmp    $0x1,%eax
80104391:	74 0d                	je     801043a0 <sched+0x4c>
    panic("sched locks");
80104393:	83 ec 0c             	sub    $0xc,%esp
80104396:	68 29 ae 10 80       	push   $0x8010ae29
8010439b:	e8 09 c2 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	8b 40 0c             	mov    0xc(%eax),%eax
801043a6:	83 f8 04             	cmp    $0x4,%eax
801043a9:	75 0d                	jne    801043b8 <sched+0x64>
    panic("sched running");
801043ab:	83 ec 0c             	sub    $0xc,%esp
801043ae:	68 35 ae 10 80       	push   $0x8010ae35
801043b3:	e8 f1 c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801043b8:	e8 ab f5 ff ff       	call   80103968 <readeflags>
801043bd:	25 00 02 00 00       	and    $0x200,%eax
801043c2:	85 c0                	test   %eax,%eax
801043c4:	74 0d                	je     801043d3 <sched+0x7f>
    panic("sched interruptible");
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 43 ae 10 80       	push   $0x8010ae43
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
801043f4:	e8 cb 11 00 00       	call   801055c4 <swtch>
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
8010441b:	e8 b9 0c 00 00       	call   801050d9 <acquire>
80104420:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104423:	e8 08 f6 ff ff       	call   80103a30 <myproc>
80104428:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010442f:	e8 20 ff ff ff       	call   80104354 <sched>
  release(&ptable.lock);
80104434:	83 ec 0c             	sub    $0xc,%esp
80104437:	68 00 4e 19 80       	push   $0x80194e00
8010443c:	e8 06 0d 00 00       	call   80105147 <release>
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
80104455:	e8 ed 0c 00 00       	call   80105147 <release>
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
801044a4:	68 57 ae 10 80       	push   $0x8010ae57
801044a9:	e8 fb c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801044ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b2:	75 0d                	jne    801044c1 <sleep+0x34>
    panic("sleep without lk");
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	68 5d ae 10 80       	push   $0x8010ae5d
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
801044d2:	e8 02 0c 00 00       	call   801050d9 <acquire>
801044d7:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044da:	83 ec 0c             	sub    $0xc,%esp
801044dd:	ff 75 0c             	push   0xc(%ebp)
801044e0:	e8 62 0c 00 00       	call   80105147 <release>
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
8010451b:	e8 27 0c 00 00       	call   80105147 <release>
80104520:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	ff 75 0c             	push   0xc(%ebp)
80104529:	e8 ab 0b 00 00       	call   801050d9 <acquire>
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
80104582:	e8 52 0b 00 00       	call   801050d9 <acquire>
80104587:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010458a:	83 ec 0c             	sub    $0xc,%esp
8010458d:	ff 75 08             	push   0x8(%ebp)
80104590:	e8 9f ff ff ff       	call   80104534 <wakeup1>
80104595:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104598:	83 ec 0c             	sub    $0xc,%esp
8010459b:	68 00 4e 19 80       	push   $0x80194e00
801045a0:	e8 a2 0b 00 00       	call   80105147 <release>
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
801045b9:	e8 1b 0b 00 00       	call   801050d9 <acquire>
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
801045fc:	e8 46 0b 00 00       	call   80105147 <release>
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
80104620:	e8 22 0b 00 00       	call   80105147 <release>
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
8010467d:	c7 45 ec 6e ae 10 80 	movl   $0x8010ae6e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104687:	8d 50 6c             	lea    0x6c(%eax),%edx
8010468a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468d:	8b 40 10             	mov    0x10(%eax),%eax
80104690:	52                   	push   %edx
80104691:	ff 75 ec             	push   -0x14(%ebp)
80104694:	50                   	push   %eax
80104695:	68 72 ae 10 80       	push   $0x8010ae72
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
801046c3:	e8 d1 0a 00 00       	call   80105199 <getcallerpcs>
801046c8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046d2:	eb 1c                	jmp    801046f0 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046db:	83 ec 08             	sub    $0x8,%esp
801046de:	50                   	push   %eax
801046df:	68 7b ae 10 80       	push   $0x8010ae7b
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
80104704:	68 7f ae 10 80       	push   $0x8010ae7f
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
80104738:	e8 9c 09 00 00       	call   801050d9 <acquire>
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
80104844:	e8 fe 08 00 00       	call   80105147 <release>
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
80104864:	e8 70 08 00 00       	call   801050d9 <acquire>
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
801048d0:	68 81 ae 10 80       	push   $0x8010ae81
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
801048f2:	e8 50 08 00 00       	call   80105147 <release>
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
80104916:	e8 29 09 00 00       	call   80105244 <pushcli>
  mycpu()->sched_policy = policy;
8010491b:	e8 98 f0 ff ff       	call   801039b8 <mycpu>
80104920:	8b 55 08             	mov    0x8(%ebp),%edx
80104923:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104929:	e8 63 09 00 00       	call   80105291 <popcli>

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
80104946:	e8 f9 08 00 00       	call   80105244 <pushcli>
  int policy = mycpu()->sched_policy;
8010494b:	e8 68 f0 ff ff       	call   801039b8 <mycpu>
80104950:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104959:	e8 33 09 00 00       	call   80105291 <popcli>
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
80104b1e:	68 a0 ae 10 80       	push   $0x8010aea0
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
80104b94:	68 c4 ae 10 80       	push   $0x8010aec4
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
80104c40:	68 e8 ae 10 80       	push   $0x8010aee8
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
80104cd2:	e8 1d 32 00 00       	call   80107ef4 <switchuvm>
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
80104d05:	68 18 af 10 80       	push   $0x8010af18
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
80104d23:	e8 9c 08 00 00       	call   801055c4 <swtch>
80104d28:	83 c4 10             	add    $0x10,%esp
  // 유저 공간에서 실행이 끝나고 다시 돌아옴
  switchkvm();
80104d2b:	e8 ab 31 00 00       	call   80107edb <switchkvm>
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
80104db2:	68 3c af 10 80       	push   $0x8010af3c
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
80104de6:	68 5c af 10 80       	push   $0x8010af5c
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
80104e02:	68 98 af 10 80       	push   $0x8010af98
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
  
  apply_priority_boosting();
80104e29:	e8 59 fc ff ff       	call   80104a87 <apply_priority_boosting>
  
  for (int q = 3; q >= 0; q--) {
80104e2e:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
80104e35:	eb 75                	jmp    80104eac <run_mlfq+0x89>
    for (int i = 0; i < NPROC; i++) {
80104e37:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104e3e:	eb 62                	jmp    80104ea2 <run_mlfq+0x7f>
      struct proc *p = mlfq_queues[q][i];
80104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e43:	c1 e0 06             	shl    $0x6,%eax
80104e46:	89 c2                	mov    %eax,%edx
80104e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4b:	01 d0                	add    %edx,%eax
80104e4d:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104e54:	89 45 e8             	mov    %eax,-0x18(%ebp)
      //cprintf("[MLFQ_LOOP] Q%d index %d: pid %d, state %d\n", q, i,
      //  p ? p->pid : -1, p ? p->state : -1);
      if (p == 0 || p->state != RUNNABLE)
80104e57:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104e5b:	74 40                	je     80104e9d <run_mlfq+0x7a>
80104e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104e60:	8b 40 0c             	mov    0xc(%eax),%eax
80104e63:	83 f8 03             	cmp    $0x3,%eax
80104e66:	75 35                	jne    80104e9d <run_mlfq+0x7a>
        continue;
      
      // 실행할 프로세스는 dequeue
      dequeue(q);
80104e68:	83 ec 0c             	sub    $0xc,%esp
80104e6b:	ff 75 f4             	push   -0xc(%ebp)
80104e6e:	e8 6b fb ff ff       	call   801049de <dequeue>
80104e73:	83 c4 10             	add    $0x10,%esp
 
      int slice = get_time_slice(q);
80104e76:	83 ec 0c             	sub    $0xc,%esp
80104e79:	ff 75 f4             	push   -0xc(%ebp)
80104e7c:	e8 00 fe ff ff       	call   80104c81 <get_time_slice>
80104e81:	83 c4 10             	add    $0x10,%esp
80104e84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice);
80104e87:	83 ec 04             	sub    $0x4,%esp
80104e8a:	ff 75 e4             	push   -0x1c(%ebp)
80104e8d:	ff 75 f4             	push   -0xc(%ebp)
80104e90:	ff 75 e8             	push   -0x18(%ebp)
80104e93:	e8 1a fe ff ff       	call   80104cb2 <run_process>
80104e98:	83 c4 10             	add    $0x10,%esp
      goto tick_update; // 한 번만 실행
80104e9b:	eb 16                	jmp    80104eb3 <run_mlfq+0x90>
        continue;
80104e9d:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
80104e9e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ea2:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104ea6:	7e 98                	jle    80104e40 <run_mlfq+0x1d>
  for (int q = 3; q >= 0; q--) {
80104ea8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80104eac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104eb0:	79 85                	jns    80104e37 <run_mlfq+0x14>
    }
  }

tick_update:
80104eb2:	90                   	nop
  // wait tick 증가 (실행 안 된 RUNNABLE 프로세스만)
  for (int i = 0; i < NPROC; i++) {
80104eb3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104eba:	e9 8d 00 00 00       	jmp    80104f4c <run_mlfq+0x129>
    struct proc* p = &ptable.proc[i];
80104ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ec2:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104ec5:	83 c0 30             	add    $0x30,%eax
80104ec8:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104ecd:	83 c0 04             	add    $0x4,%eax
80104ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80104ed3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ed6:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104edd:	85 c0                	test   %eax,%eax
80104edf:	74 66                	je     80104f47 <run_mlfq+0x124>
    if (p->state == RUNNABLE && p != mycpu()->proc) {
80104ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ee4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee7:	83 f8 03             	cmp    $0x3,%eax
80104eea:	75 5c                	jne    80104f48 <run_mlfq+0x125>
80104eec:	e8 c7 ea ff ff       	call   801039b8 <mycpu>
80104ef1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ef7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80104efa:	74 4c                	je     80104f48 <run_mlfq+0x125>
      int q = kernel_pstat.priority[i];
80104efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104eff:	83 e8 80             	sub    $0xffffff80,%eax
80104f02:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104f09:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
80104f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104f19:	01 d0                	add    %edx,%eax
80104f1b:	05 00 02 00 00       	add    $0x200,%eax
80104f20:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104f27:	8d 50 01             	lea    0x1(%eax),%edx
80104f2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f2d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104f34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104f37:	01 c8                	add    %ecx,%eax
80104f39:	05 00 02 00 00       	add    $0x200,%eax
80104f3e:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
80104f45:	eb 01                	jmp    80104f48 <run_mlfq+0x125>
    if (!kernel_pstat.inuse[i]) continue;
80104f47:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104f48:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104f4c:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80104f50:	0f 8e 69 ff ff ff    	jle    80104ebf <run_mlfq+0x9c>
    }
  }
}
80104f56:	90                   	nop
80104f57:	90                   	nop
80104f58:	c9                   	leave
80104f59:	c3                   	ret

80104f5a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104f5a:	55                   	push   %ebp
80104f5b:	89 e5                	mov    %esp,%ebp
80104f5d:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104f60:	8b 45 08             	mov    0x8(%ebp),%eax
80104f63:	83 c0 04             	add    $0x4,%eax
80104f66:	83 ec 08             	sub    $0x8,%esp
80104f69:	68 e4 af 10 80       	push   $0x8010afe4
80104f6e:	50                   	push   %eax
80104f6f:	e8 43 01 00 00       	call   801050b7 <initlock>
80104f74:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104f77:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f7d:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104f80:	8b 45 08             	mov    0x8(%ebp),%eax
80104f83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f89:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104f93:	90                   	nop
80104f94:	c9                   	leave
80104f95:	c3                   	ret

80104f96 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f96:	55                   	push   %ebp
80104f97:	89 e5                	mov    %esp,%ebp
80104f99:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9f:	83 c0 04             	add    $0x4,%eax
80104fa2:	83 ec 0c             	sub    $0xc,%esp
80104fa5:	50                   	push   %eax
80104fa6:	e8 2e 01 00 00       	call   801050d9 <acquire>
80104fab:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104fae:	eb 15                	jmp    80104fc5 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb3:	83 c0 04             	add    $0x4,%eax
80104fb6:	83 ec 08             	sub    $0x8,%esp
80104fb9:	50                   	push   %eax
80104fba:	ff 75 08             	push   0x8(%ebp)
80104fbd:	e8 cb f4 ff ff       	call   8010448d <sleep>
80104fc2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc8:	8b 00                	mov    (%eax),%eax
80104fca:	85 c0                	test   %eax,%eax
80104fcc:	75 e2                	jne    80104fb0 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104fce:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104fd7:	e8 54 ea ff ff       	call   80103a30 <myproc>
80104fdc:	8b 50 10             	mov    0x10(%eax),%edx
80104fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe2:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe8:	83 c0 04             	add    $0x4,%eax
80104feb:	83 ec 0c             	sub    $0xc,%esp
80104fee:	50                   	push   %eax
80104fef:	e8 53 01 00 00       	call   80105147 <release>
80104ff4:	83 c4 10             	add    $0x10,%esp
}
80104ff7:	90                   	nop
80104ff8:	c9                   	leave
80104ff9:	c3                   	ret

80104ffa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104ffa:	55                   	push   %ebp
80104ffb:	89 e5                	mov    %esp,%ebp
80104ffd:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105000:	8b 45 08             	mov    0x8(%ebp),%eax
80105003:	83 c0 04             	add    $0x4,%eax
80105006:	83 ec 0c             	sub    $0xc,%esp
80105009:	50                   	push   %eax
8010500a:	e8 ca 00 00 00       	call   801050d9 <acquire>
8010500f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105012:	8b 45 08             	mov    0x8(%ebp),%eax
80105015:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010501b:	8b 45 08             	mov    0x8(%ebp),%eax
8010501e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105025:	83 ec 0c             	sub    $0xc,%esp
80105028:	ff 75 08             	push   0x8(%ebp)
8010502b:	e8 44 f5 ff ff       	call   80104574 <wakeup>
80105030:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	83 c0 04             	add    $0x4,%eax
80105039:	83 ec 0c             	sub    $0xc,%esp
8010503c:	50                   	push   %eax
8010503d:	e8 05 01 00 00       	call   80105147 <release>
80105042:	83 c4 10             	add    $0x10,%esp
}
80105045:	90                   	nop
80105046:	c9                   	leave
80105047:	c3                   	ret

80105048 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010504e:	8b 45 08             	mov    0x8(%ebp),%eax
80105051:	83 c0 04             	add    $0x4,%eax
80105054:	83 ec 0c             	sub    $0xc,%esp
80105057:	50                   	push   %eax
80105058:	e8 7c 00 00 00       	call   801050d9 <acquire>
8010505d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105060:	8b 45 08             	mov    0x8(%ebp),%eax
80105063:	8b 00                	mov    (%eax),%eax
80105065:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105068:	8b 45 08             	mov    0x8(%ebp),%eax
8010506b:	83 c0 04             	add    $0x4,%eax
8010506e:	83 ec 0c             	sub    $0xc,%esp
80105071:	50                   	push   %eax
80105072:	e8 d0 00 00 00       	call   80105147 <release>
80105077:	83 c4 10             	add    $0x10,%esp
  return r;
8010507a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010507d:	c9                   	leave
8010507e:	c3                   	ret

8010507f <readeflags>:
{
8010507f:	55                   	push   %ebp
80105080:	89 e5                	mov    %esp,%ebp
80105082:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105085:	9c                   	pushf
80105086:	58                   	pop    %eax
80105087:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010508a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010508d:	c9                   	leave
8010508e:	c3                   	ret

8010508f <cli>:
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105092:	fa                   	cli
}
80105093:	90                   	nop
80105094:	5d                   	pop    %ebp
80105095:	c3                   	ret

80105096 <sti>:
{
80105096:	55                   	push   %ebp
80105097:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105099:	fb                   	sti
}
8010509a:	90                   	nop
8010509b:	5d                   	pop    %ebp
8010509c:	c3                   	ret

8010509d <xchg>:
{
8010509d:	55                   	push   %ebp
8010509e:	89 e5                	mov    %esp,%ebp
801050a0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801050a3:	8b 55 08             	mov    0x8(%ebp),%edx
801050a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050ac:	f0 87 02             	lock xchg %eax,(%edx)
801050af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801050b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050b5:	c9                   	leave
801050b6:	c3                   	ret

801050b7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050b7:	55                   	push   %ebp
801050b8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050ba:	8b 45 08             	mov    0x8(%ebp),%eax
801050bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801050c0:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050c3:	8b 45 08             	mov    0x8(%ebp),%eax
801050c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050cc:	8b 45 08             	mov    0x8(%ebp),%eax
801050cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050d6:	90                   	nop
801050d7:	5d                   	pop    %ebp
801050d8:	c3                   	ret

801050d9 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050d9:	55                   	push   %ebp
801050da:	89 e5                	mov    %esp,%ebp
801050dc:	53                   	push   %ebx
801050dd:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050e0:	e8 5f 01 00 00       	call   80105244 <pushcli>
  if(holding(lk)){
801050e5:	8b 45 08             	mov    0x8(%ebp),%eax
801050e8:	83 ec 0c             	sub    $0xc,%esp
801050eb:	50                   	push   %eax
801050ec:	e8 23 01 00 00       	call   80105214 <holding>
801050f1:	83 c4 10             	add    $0x10,%esp
801050f4:	85 c0                	test   %eax,%eax
801050f6:	74 0d                	je     80105105 <acquire+0x2c>
    panic("acquire");
801050f8:	83 ec 0c             	sub    $0xc,%esp
801050fb:	68 ef af 10 80       	push   $0x8010afef
80105100:	e8 a4 b4 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105105:	90                   	nop
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	83 ec 08             	sub    $0x8,%esp
8010510c:	6a 01                	push   $0x1
8010510e:	50                   	push   %eax
8010510f:	e8 89 ff ff ff       	call   8010509d <xchg>
80105114:	83 c4 10             	add    $0x10,%esp
80105117:	85 c0                	test   %eax,%eax
80105119:	75 eb                	jne    80105106 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010511b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105120:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105123:	e8 90 e8 ff ff       	call   801039b8 <mycpu>
80105128:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010512b:	8b 45 08             	mov    0x8(%ebp),%eax
8010512e:	83 c0 0c             	add    $0xc,%eax
80105131:	83 ec 08             	sub    $0x8,%esp
80105134:	50                   	push   %eax
80105135:	8d 45 08             	lea    0x8(%ebp),%eax
80105138:	50                   	push   %eax
80105139:	e8 5b 00 00 00       	call   80105199 <getcallerpcs>
8010513e:	83 c4 10             	add    $0x10,%esp
}
80105141:	90                   	nop
80105142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105145:	c9                   	leave
80105146:	c3                   	ret

80105147 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105147:	55                   	push   %ebp
80105148:	89 e5                	mov    %esp,%ebp
8010514a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010514d:	83 ec 0c             	sub    $0xc,%esp
80105150:	ff 75 08             	push   0x8(%ebp)
80105153:	e8 bc 00 00 00       	call   80105214 <holding>
80105158:	83 c4 10             	add    $0x10,%esp
8010515b:	85 c0                	test   %eax,%eax
8010515d:	75 0d                	jne    8010516c <release+0x25>
    panic("release");
8010515f:	83 ec 0c             	sub    $0xc,%esp
80105162:	68 f7 af 10 80       	push   $0x8010aff7
80105167:	e8 3d b4 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010516c:	8b 45 08             	mov    0x8(%ebp),%eax
8010516f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105176:	8b 45 08             	mov    0x8(%ebp),%eax
80105179:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105180:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105185:	8b 45 08             	mov    0x8(%ebp),%eax
80105188:	8b 55 08             	mov    0x8(%ebp),%edx
8010518b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105191:	e8 fb 00 00 00       	call   80105291 <popcli>
}
80105196:	90                   	nop
80105197:	c9                   	leave
80105198:	c3                   	ret

80105199 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105199:	55                   	push   %ebp
8010519a:	89 e5                	mov    %esp,%ebp
8010519c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010519f:	8b 45 08             	mov    0x8(%ebp),%eax
801051a2:	83 e8 08             	sub    $0x8,%eax
801051a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051a8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051af:	eb 38                	jmp    801051e9 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051b1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051b5:	74 53                	je     8010520a <getcallerpcs+0x71>
801051b7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051be:	76 4a                	jbe    8010520a <getcallerpcs+0x71>
801051c0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051c4:	74 44                	je     8010520a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801051d3:	01 c2                	add    %eax,%edx
801051d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d8:	8b 40 04             	mov    0x4(%eax),%eax
801051db:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801051dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051e0:	8b 00                	mov    (%eax),%eax
801051e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051e5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051e9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051ed:	7e c2                	jle    801051b1 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801051ef:	eb 19                	jmp    8010520a <getcallerpcs+0x71>
    pcs[i] = 0;
801051f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801051fe:	01 d0                	add    %edx,%eax
80105200:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105206:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010520a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010520e:	7e e1                	jle    801051f1 <getcallerpcs+0x58>
}
80105210:	90                   	nop
80105211:	90                   	nop
80105212:	c9                   	leave
80105213:	c3                   	ret

80105214 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105214:	55                   	push   %ebp
80105215:	89 e5                	mov    %esp,%ebp
80105217:	53                   	push   %ebx
80105218:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010521b:	8b 45 08             	mov    0x8(%ebp),%eax
8010521e:	8b 00                	mov    (%eax),%eax
80105220:	85 c0                	test   %eax,%eax
80105222:	74 16                	je     8010523a <holding+0x26>
80105224:	8b 45 08             	mov    0x8(%ebp),%eax
80105227:	8b 58 08             	mov    0x8(%eax),%ebx
8010522a:	e8 89 e7 ff ff       	call   801039b8 <mycpu>
8010522f:	39 c3                	cmp    %eax,%ebx
80105231:	75 07                	jne    8010523a <holding+0x26>
80105233:	b8 01 00 00 00       	mov    $0x1,%eax
80105238:	eb 05                	jmp    8010523f <holding+0x2b>
8010523a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010523f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105242:	c9                   	leave
80105243:	c3                   	ret

80105244 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105244:	55                   	push   %ebp
80105245:	89 e5                	mov    %esp,%ebp
80105247:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010524a:	e8 30 fe ff ff       	call   8010507f <readeflags>
8010524f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105252:	e8 38 fe ff ff       	call   8010508f <cli>
  if(mycpu()->ncli == 0)
80105257:	e8 5c e7 ff ff       	call   801039b8 <mycpu>
8010525c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105262:	85 c0                	test   %eax,%eax
80105264:	75 14                	jne    8010527a <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105266:	e8 4d e7 ff ff       	call   801039b8 <mycpu>
8010526b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010526e:	81 e2 00 02 00 00    	and    $0x200,%edx
80105274:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010527a:	e8 39 e7 ff ff       	call   801039b8 <mycpu>
8010527f:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105285:	83 c2 01             	add    $0x1,%edx
80105288:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010528e:	90                   	nop
8010528f:	c9                   	leave
80105290:	c3                   	ret

80105291 <popcli>:

void
popcli(void)
{
80105291:	55                   	push   %ebp
80105292:	89 e5                	mov    %esp,%ebp
80105294:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105297:	e8 e3 fd ff ff       	call   8010507f <readeflags>
8010529c:	25 00 02 00 00       	and    $0x200,%eax
801052a1:	85 c0                	test   %eax,%eax
801052a3:	74 0d                	je     801052b2 <popcli+0x21>
    panic("popcli - interruptible");
801052a5:	83 ec 0c             	sub    $0xc,%esp
801052a8:	68 ff af 10 80       	push   $0x8010afff
801052ad:	e8 f7 b2 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801052b2:	e8 01 e7 ff ff       	call   801039b8 <mycpu>
801052b7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801052bd:	83 ea 01             	sub    $0x1,%edx
801052c0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801052c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052cc:	85 c0                	test   %eax,%eax
801052ce:	79 0d                	jns    801052dd <popcli+0x4c>
    panic("popcli");
801052d0:	83 ec 0c             	sub    $0xc,%esp
801052d3:	68 16 b0 10 80       	push   $0x8010b016
801052d8:	e8 cc b2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052dd:	e8 d6 e6 ff ff       	call   801039b8 <mycpu>
801052e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052e8:	85 c0                	test   %eax,%eax
801052ea:	75 14                	jne    80105300 <popcli+0x6f>
801052ec:	e8 c7 e6 ff ff       	call   801039b8 <mycpu>
801052f1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801052f7:	85 c0                	test   %eax,%eax
801052f9:	74 05                	je     80105300 <popcli+0x6f>
    sti();
801052fb:	e8 96 fd ff ff       	call   80105096 <sti>
}
80105300:	90                   	nop
80105301:	c9                   	leave
80105302:	c3                   	ret

80105303 <stosb>:
{
80105303:	55                   	push   %ebp
80105304:	89 e5                	mov    %esp,%ebp
80105306:	57                   	push   %edi
80105307:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105308:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010530b:	8b 55 10             	mov    0x10(%ebp),%edx
8010530e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105311:	89 cb                	mov    %ecx,%ebx
80105313:	89 df                	mov    %ebx,%edi
80105315:	89 d1                	mov    %edx,%ecx
80105317:	fc                   	cld
80105318:	f3 aa                	rep stos %al,%es:(%edi)
8010531a:	89 ca                	mov    %ecx,%edx
8010531c:	89 fb                	mov    %edi,%ebx
8010531e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105321:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105324:	90                   	nop
80105325:	5b                   	pop    %ebx
80105326:	5f                   	pop    %edi
80105327:	5d                   	pop    %ebp
80105328:	c3                   	ret

80105329 <stosl>:
{
80105329:	55                   	push   %ebp
8010532a:	89 e5                	mov    %esp,%ebp
8010532c:	57                   	push   %edi
8010532d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010532e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105331:	8b 55 10             	mov    0x10(%ebp),%edx
80105334:	8b 45 0c             	mov    0xc(%ebp),%eax
80105337:	89 cb                	mov    %ecx,%ebx
80105339:	89 df                	mov    %ebx,%edi
8010533b:	89 d1                	mov    %edx,%ecx
8010533d:	fc                   	cld
8010533e:	f3 ab                	rep stos %eax,%es:(%edi)
80105340:	89 ca                	mov    %ecx,%edx
80105342:	89 fb                	mov    %edi,%ebx
80105344:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105347:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010534a:	90                   	nop
8010534b:	5b                   	pop    %ebx
8010534c:	5f                   	pop    %edi
8010534d:	5d                   	pop    %ebp
8010534e:	c3                   	ret

8010534f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010534f:	55                   	push   %ebp
80105350:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105352:	8b 45 08             	mov    0x8(%ebp),%eax
80105355:	83 e0 03             	and    $0x3,%eax
80105358:	85 c0                	test   %eax,%eax
8010535a:	75 43                	jne    8010539f <memset+0x50>
8010535c:	8b 45 10             	mov    0x10(%ebp),%eax
8010535f:	83 e0 03             	and    $0x3,%eax
80105362:	85 c0                	test   %eax,%eax
80105364:	75 39                	jne    8010539f <memset+0x50>
    c &= 0xFF;
80105366:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010536d:	8b 45 10             	mov    0x10(%ebp),%eax
80105370:	c1 e8 02             	shr    $0x2,%eax
80105373:	89 c1                	mov    %eax,%ecx
80105375:	8b 45 0c             	mov    0xc(%ebp),%eax
80105378:	c1 e0 18             	shl    $0x18,%eax
8010537b:	89 c2                	mov    %eax,%edx
8010537d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105380:	c1 e0 10             	shl    $0x10,%eax
80105383:	09 c2                	or     %eax,%edx
80105385:	8b 45 0c             	mov    0xc(%ebp),%eax
80105388:	c1 e0 08             	shl    $0x8,%eax
8010538b:	09 d0                	or     %edx,%eax
8010538d:	0b 45 0c             	or     0xc(%ebp),%eax
80105390:	51                   	push   %ecx
80105391:	50                   	push   %eax
80105392:	ff 75 08             	push   0x8(%ebp)
80105395:	e8 8f ff ff ff       	call   80105329 <stosl>
8010539a:	83 c4 0c             	add    $0xc,%esp
8010539d:	eb 12                	jmp    801053b1 <memset+0x62>
  } else
    stosb(dst, c, n);
8010539f:	8b 45 10             	mov    0x10(%ebp),%eax
801053a2:	50                   	push   %eax
801053a3:	ff 75 0c             	push   0xc(%ebp)
801053a6:	ff 75 08             	push   0x8(%ebp)
801053a9:	e8 55 ff ff ff       	call   80105303 <stosb>
801053ae:	83 c4 0c             	add    $0xc,%esp
  return dst;
801053b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053b4:	c9                   	leave
801053b5:	c3                   	ret

801053b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
801053b9:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053c8:	eb 2e                	jmp    801053f8 <memcmp+0x42>
    if(*s1 != *s2)
801053ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053cd:	0f b6 10             	movzbl (%eax),%edx
801053d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d3:	0f b6 00             	movzbl (%eax),%eax
801053d6:	38 c2                	cmp    %al,%dl
801053d8:	74 16                	je     801053f0 <memcmp+0x3a>
      return *s1 - *s2;
801053da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053dd:	0f b6 00             	movzbl (%eax),%eax
801053e0:	0f b6 d0             	movzbl %al,%edx
801053e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e6:	0f b6 00             	movzbl (%eax),%eax
801053e9:	0f b6 c0             	movzbl %al,%eax
801053ec:	29 c2                	sub    %eax,%edx
801053ee:	eb 1a                	jmp    8010540a <memcmp+0x54>
    s1++, s2++;
801053f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053f4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801053f8:	8b 45 10             	mov    0x10(%ebp),%eax
801053fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801053fe:	89 55 10             	mov    %edx,0x10(%ebp)
80105401:	85 c0                	test   %eax,%eax
80105403:	75 c5                	jne    801053ca <memcmp+0x14>
  }

  return 0;
80105405:	ba 00 00 00 00       	mov    $0x0,%edx
}
8010540a:	89 d0                	mov    %edx,%eax
8010540c:	c9                   	leave
8010540d:	c3                   	ret

8010540e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010540e:	55                   	push   %ebp
8010540f:	89 e5                	mov    %esp,%ebp
80105411:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105414:	8b 45 0c             	mov    0xc(%ebp),%eax
80105417:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010541a:	8b 45 08             	mov    0x8(%ebp),%eax
8010541d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105420:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105423:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105426:	73 54                	jae    8010547c <memmove+0x6e>
80105428:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010542b:	8b 45 10             	mov    0x10(%ebp),%eax
8010542e:	01 d0                	add    %edx,%eax
80105430:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105433:	73 47                	jae    8010547c <memmove+0x6e>
    s += n;
80105435:	8b 45 10             	mov    0x10(%ebp),%eax
80105438:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010543b:	8b 45 10             	mov    0x10(%ebp),%eax
8010543e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105441:	eb 13                	jmp    80105456 <memmove+0x48>
      *--d = *--s;
80105443:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105447:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010544b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010544e:	0f b6 10             	movzbl (%eax),%edx
80105451:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105454:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105456:	8b 45 10             	mov    0x10(%ebp),%eax
80105459:	8d 50 ff             	lea    -0x1(%eax),%edx
8010545c:	89 55 10             	mov    %edx,0x10(%ebp)
8010545f:	85 c0                	test   %eax,%eax
80105461:	75 e0                	jne    80105443 <memmove+0x35>
  if(s < d && s + n > d){
80105463:	eb 24                	jmp    80105489 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105465:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105468:	8d 42 01             	lea    0x1(%edx),%eax
8010546b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010546e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105471:	8d 48 01             	lea    0x1(%eax),%ecx
80105474:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105477:	0f b6 12             	movzbl (%edx),%edx
8010547a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010547c:	8b 45 10             	mov    0x10(%ebp),%eax
8010547f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105482:	89 55 10             	mov    %edx,0x10(%ebp)
80105485:	85 c0                	test   %eax,%eax
80105487:	75 dc                	jne    80105465 <memmove+0x57>

  return dst;
80105489:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010548c:	c9                   	leave
8010548d:	c3                   	ret

8010548e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010548e:	55                   	push   %ebp
8010548f:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105491:	ff 75 10             	push   0x10(%ebp)
80105494:	ff 75 0c             	push   0xc(%ebp)
80105497:	ff 75 08             	push   0x8(%ebp)
8010549a:	e8 6f ff ff ff       	call   8010540e <memmove>
8010549f:	83 c4 0c             	add    $0xc,%esp
}
801054a2:	c9                   	leave
801054a3:	c3                   	ret

801054a4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801054a7:	eb 0c                	jmp    801054b5 <strncmp+0x11>
    n--, p++, q++;
801054a9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801054b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b9:	74 1a                	je     801054d5 <strncmp+0x31>
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
801054be:	0f b6 00             	movzbl (%eax),%eax
801054c1:	84 c0                	test   %al,%al
801054c3:	74 10                	je     801054d5 <strncmp+0x31>
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
801054c8:	0f b6 10             	movzbl (%eax),%edx
801054cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ce:	0f b6 00             	movzbl (%eax),%eax
801054d1:	38 c2                	cmp    %al,%dl
801054d3:	74 d4                	je     801054a9 <strncmp+0x5>
  if(n == 0)
801054d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d9:	75 07                	jne    801054e2 <strncmp+0x3e>
    return 0;
801054db:	ba 00 00 00 00       	mov    $0x0,%edx
801054e0:	eb 14                	jmp    801054f6 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
801054e2:	8b 45 08             	mov    0x8(%ebp),%eax
801054e5:	0f b6 00             	movzbl (%eax),%eax
801054e8:	0f b6 d0             	movzbl %al,%edx
801054eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ee:	0f b6 00             	movzbl (%eax),%eax
801054f1:	0f b6 c0             	movzbl %al,%eax
801054f4:	29 c2                	sub    %eax,%edx
}
801054f6:	89 d0                	mov    %edx,%eax
801054f8:	5d                   	pop    %ebp
801054f9:	c3                   	ret

801054fa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054fa:	55                   	push   %ebp
801054fb:	89 e5                	mov    %esp,%ebp
801054fd:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105500:	8b 45 08             	mov    0x8(%ebp),%eax
80105503:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105506:	90                   	nop
80105507:	8b 45 10             	mov    0x10(%ebp),%eax
8010550a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010550d:	89 55 10             	mov    %edx,0x10(%ebp)
80105510:	85 c0                	test   %eax,%eax
80105512:	7e 2c                	jle    80105540 <strncpy+0x46>
80105514:	8b 55 0c             	mov    0xc(%ebp),%edx
80105517:	8d 42 01             	lea    0x1(%edx),%eax
8010551a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	8d 48 01             	lea    0x1(%eax),%ecx
80105523:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105526:	0f b6 12             	movzbl (%edx),%edx
80105529:	88 10                	mov    %dl,(%eax)
8010552b:	0f b6 00             	movzbl (%eax),%eax
8010552e:	84 c0                	test   %al,%al
80105530:	75 d5                	jne    80105507 <strncpy+0xd>
    ;
  while(n-- > 0)
80105532:	eb 0c                	jmp    80105540 <strncpy+0x46>
    *s++ = 0;
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	8d 50 01             	lea    0x1(%eax),%edx
8010553a:	89 55 08             	mov    %edx,0x8(%ebp)
8010553d:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105540:	8b 45 10             	mov    0x10(%ebp),%eax
80105543:	8d 50 ff             	lea    -0x1(%eax),%edx
80105546:	89 55 10             	mov    %edx,0x10(%ebp)
80105549:	85 c0                	test   %eax,%eax
8010554b:	7f e7                	jg     80105534 <strncpy+0x3a>
  return os;
8010554d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105550:	c9                   	leave
80105551:	c3                   	ret

80105552 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
80105555:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105558:	8b 45 08             	mov    0x8(%ebp),%eax
8010555b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010555e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105562:	7f 05                	jg     80105569 <safestrcpy+0x17>
    return os;
80105564:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105567:	eb 32                	jmp    8010559b <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105569:	90                   	nop
8010556a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010556e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105572:	7e 1e                	jle    80105592 <safestrcpy+0x40>
80105574:	8b 55 0c             	mov    0xc(%ebp),%edx
80105577:	8d 42 01             	lea    0x1(%edx),%eax
8010557a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010557d:	8b 45 08             	mov    0x8(%ebp),%eax
80105580:	8d 48 01             	lea    0x1(%eax),%ecx
80105583:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105586:	0f b6 12             	movzbl (%edx),%edx
80105589:	88 10                	mov    %dl,(%eax)
8010558b:	0f b6 00             	movzbl (%eax),%eax
8010558e:	84 c0                	test   %al,%al
80105590:	75 d8                	jne    8010556a <safestrcpy+0x18>
    ;
  *s = 0;
80105592:	8b 45 08             	mov    0x8(%ebp),%eax
80105595:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105598:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010559b:	c9                   	leave
8010559c:	c3                   	ret

8010559d <strlen>:

int
strlen(const char *s)
{
8010559d:	55                   	push   %ebp
8010559e:	89 e5                	mov    %esp,%ebp
801055a0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055aa:	eb 04                	jmp    801055b0 <strlen+0x13>
801055ac:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055b3:	8b 45 08             	mov    0x8(%ebp),%eax
801055b6:	01 d0                	add    %edx,%eax
801055b8:	0f b6 00             	movzbl (%eax),%eax
801055bb:	84 c0                	test   %al,%al
801055bd:	75 ed                	jne    801055ac <strlen+0xf>
    ;
  return n;
801055bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055c2:	c9                   	leave
801055c3:	c3                   	ret

801055c4 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055c4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055c8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055cc:	55                   	push   %ebp
  pushl %ebx
801055cd:	53                   	push   %ebx
  pushl %esi
801055ce:	56                   	push   %esi
  pushl %edi
801055cf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055d0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055d2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055d4:	5f                   	pop    %edi
  popl %esi
801055d5:	5e                   	pop    %esi
  popl %ebx
801055d6:	5b                   	pop    %ebx
  popl %ebp
801055d7:	5d                   	pop    %ebp
  ret
801055d8:	c3                   	ret

801055d9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055d9:	55                   	push   %ebp
801055da:	89 e5                	mov    %esp,%ebp
801055dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801055df:	e8 4c e4 ff ff       	call   80103a30 <myproc>
801055e4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801055e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ea:	8b 00                	mov    (%eax),%eax
801055ec:	39 45 08             	cmp    %eax,0x8(%ebp)
801055ef:	73 0f                	jae    80105600 <fetchint+0x27>
801055f1:	8b 45 08             	mov    0x8(%ebp),%eax
801055f4:	8d 50 04             	lea    0x4(%eax),%edx
801055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fa:	8b 00                	mov    (%eax),%eax
801055fc:	39 d0                	cmp    %edx,%eax
801055fe:	73 07                	jae    80105607 <fetchint+0x2e>
    return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105605:	eb 0f                	jmp    80105616 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105607:	8b 45 08             	mov    0x8(%ebp),%eax
8010560a:	8b 10                	mov    (%eax),%edx
8010560c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560f:	89 10                	mov    %edx,(%eax)
  return 0;
80105611:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105616:	c9                   	leave
80105617:	c3                   	ret

80105618 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105618:	55                   	push   %ebp
80105619:	89 e5                	mov    %esp,%ebp
8010561b:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010561e:	e8 0d e4 ff ff       	call   80103a30 <myproc>
80105623:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105629:	8b 00                	mov    (%eax),%eax
8010562b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010562e:	72 07                	jb     80105637 <fetchstr+0x1f>
    return -1;
80105630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105635:	eb 41                	jmp    80105678 <fetchstr+0x60>
  *pp = (char*)addr;
80105637:	8b 55 08             	mov    0x8(%ebp),%edx
8010563a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563d:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010563f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105642:	8b 00                	mov    (%eax),%eax
80105644:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564a:	8b 00                	mov    (%eax),%eax
8010564c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010564f:	eb 1a                	jmp    8010566b <fetchstr+0x53>
    if(*s == 0)
80105651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105654:	0f b6 00             	movzbl (%eax),%eax
80105657:	84 c0                	test   %al,%al
80105659:	75 0c                	jne    80105667 <fetchstr+0x4f>
      return s - *pp;
8010565b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565e:	8b 10                	mov    (%eax),%edx
80105660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105663:	29 d0                	sub    %edx,%eax
80105665:	eb 11                	jmp    80105678 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105667:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105671:	72 de                	jb     80105651 <fetchstr+0x39>
  }
  return -1;
80105673:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105678:	c9                   	leave
80105679:	c3                   	ret

8010567a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010567a:	55                   	push   %ebp
8010567b:	89 e5                	mov    %esp,%ebp
8010567d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105680:	e8 ab e3 ff ff       	call   80103a30 <myproc>
80105685:	8b 40 18             	mov    0x18(%eax),%eax
80105688:	8b 40 44             	mov    0x44(%eax),%eax
8010568b:	8b 55 08             	mov    0x8(%ebp),%edx
8010568e:	c1 e2 02             	shl    $0x2,%edx
80105691:	01 d0                	add    %edx,%eax
80105693:	83 c0 04             	add    $0x4,%eax
80105696:	83 ec 08             	sub    $0x8,%esp
80105699:	ff 75 0c             	push   0xc(%ebp)
8010569c:	50                   	push   %eax
8010569d:	e8 37 ff ff ff       	call   801055d9 <fetchint>
801056a2:	83 c4 10             	add    $0x10,%esp
}
801056a5:	c9                   	leave
801056a6:	c3                   	ret

801056a7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056a7:	55                   	push   %ebp
801056a8:	89 e5                	mov    %esp,%ebp
801056aa:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801056ad:	e8 7e e3 ff ff       	call   80103a30 <myproc>
801056b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801056b5:	83 ec 08             	sub    $0x8,%esp
801056b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056bb:	50                   	push   %eax
801056bc:	ff 75 08             	push   0x8(%ebp)
801056bf:	e8 b6 ff ff ff       	call   8010567a <argint>
801056c4:	83 c4 10             	add    $0x10,%esp
801056c7:	85 c0                	test   %eax,%eax
801056c9:	79 07                	jns    801056d2 <argptr+0x2b>
    return -1;
801056cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d0:	eb 3b                	jmp    8010570d <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801056d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056d6:	78 1f                	js     801056f7 <argptr+0x50>
801056d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056db:	8b 00                	mov    (%eax),%eax
801056dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056e0:	39 c2                	cmp    %eax,%edx
801056e2:	73 13                	jae    801056f7 <argptr+0x50>
801056e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e7:	89 c2                	mov    %eax,%edx
801056e9:	8b 45 10             	mov    0x10(%ebp),%eax
801056ec:	01 c2                	add    %eax,%edx
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	8b 00                	mov    (%eax),%eax
801056f3:	39 d0                	cmp    %edx,%eax
801056f5:	73 07                	jae    801056fe <argptr+0x57>
    return -1;
801056f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fc:	eb 0f                	jmp    8010570d <argptr+0x66>
  *pp = (char*)i;
801056fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105701:	89 c2                	mov    %eax,%edx
80105703:	8b 45 0c             	mov    0xc(%ebp),%eax
80105706:	89 10                	mov    %edx,(%eax)
  return 0;
80105708:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010570d:	c9                   	leave
8010570e:	c3                   	ret

8010570f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010570f:	55                   	push   %ebp
80105710:	89 e5                	mov    %esp,%ebp
80105712:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105715:	83 ec 08             	sub    $0x8,%esp
80105718:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010571b:	50                   	push   %eax
8010571c:	ff 75 08             	push   0x8(%ebp)
8010571f:	e8 56 ff ff ff       	call   8010567a <argint>
80105724:	83 c4 10             	add    $0x10,%esp
80105727:	85 c0                	test   %eax,%eax
80105729:	79 07                	jns    80105732 <argstr+0x23>
    return -1;
8010572b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105730:	eb 12                	jmp    80105744 <argstr+0x35>
  return fetchstr(addr, pp);
80105732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105735:	83 ec 08             	sub    $0x8,%esp
80105738:	ff 75 0c             	push   0xc(%ebp)
8010573b:	50                   	push   %eax
8010573c:	e8 d7 fe ff ff       	call   80105618 <fetchstr>
80105741:	83 c4 10             	add    $0x10,%esp
}
80105744:	c9                   	leave
80105745:	c3                   	ret

80105746 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
80105746:	55                   	push   %ebp
80105747:	89 e5                	mov    %esp,%ebp
80105749:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010574c:	e8 df e2 ff ff       	call   80103a30 <myproc>
80105751:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105757:	8b 40 18             	mov    0x18(%eax),%eax
8010575a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010575d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105760:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105764:	7e 2f                	jle    80105795 <syscall+0x4f>
80105766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105769:	83 f8 19             	cmp    $0x19,%eax
8010576c:	77 27                	ja     80105795 <syscall+0x4f>
8010576e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105771:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105778:	85 c0                	test   %eax,%eax
8010577a:	74 19                	je     80105795 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010577c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577f:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105786:	ff d0                	call   *%eax
80105788:	89 c2                	mov    %eax,%edx
8010578a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578d:	8b 40 18             	mov    0x18(%eax),%eax
80105790:	89 50 1c             	mov    %edx,0x1c(%eax)
80105793:	eb 2c                	jmp    801057c1 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105798:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010579b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579e:	8b 40 10             	mov    0x10(%eax),%eax
801057a1:	ff 75 f0             	push   -0x10(%ebp)
801057a4:	52                   	push   %edx
801057a5:	50                   	push   %eax
801057a6:	68 1d b0 10 80       	push   $0x8010b01d
801057ab:	e8 44 ac ff ff       	call   801003f4 <cprintf>
801057b0:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801057b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b6:	8b 40 18             	mov    0x18(%eax),%eax
801057b9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057c0:	90                   	nop
801057c1:	90                   	nop
801057c2:	c9                   	leave
801057c3:	c3                   	ret

801057c4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057c4:	55                   	push   %ebp
801057c5:	89 e5                	mov    %esp,%ebp
801057c7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057ca:	83 ec 08             	sub    $0x8,%esp
801057cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d0:	50                   	push   %eax
801057d1:	ff 75 08             	push   0x8(%ebp)
801057d4:	e8 a1 fe ff ff       	call   8010567a <argint>
801057d9:	83 c4 10             	add    $0x10,%esp
801057dc:	85 c0                	test   %eax,%eax
801057de:	79 07                	jns    801057e7 <argfd+0x23>
    return -1;
801057e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e5:	eb 4f                	jmp    80105836 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801057e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ea:	85 c0                	test   %eax,%eax
801057ec:	78 20                	js     8010580e <argfd+0x4a>
801057ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f1:	83 f8 0f             	cmp    $0xf,%eax
801057f4:	7f 18                	jg     8010580e <argfd+0x4a>
801057f6:	e8 35 e2 ff ff       	call   80103a30 <myproc>
801057fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057fe:	83 c2 08             	add    $0x8,%edx
80105801:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105805:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105808:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010580c:	75 07                	jne    80105815 <argfd+0x51>
    return -1;
8010580e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105813:	eb 21                	jmp    80105836 <argfd+0x72>
  if(pfd)
80105815:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105819:	74 08                	je     80105823 <argfd+0x5f>
    *pfd = fd;
8010581b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010581e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105821:	89 10                	mov    %edx,(%eax)
  if(pf)
80105823:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105827:	74 08                	je     80105831 <argfd+0x6d>
    *pf = f;
80105829:	8b 45 10             	mov    0x10(%ebp),%eax
8010582c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010582f:	89 10                	mov    %edx,(%eax)
  return 0;
80105831:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105836:	c9                   	leave
80105837:	c3                   	ret

80105838 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105838:	55                   	push   %ebp
80105839:	89 e5                	mov    %esp,%ebp
8010583b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010583e:	e8 ed e1 ff ff       	call   80103a30 <myproc>
80105843:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105846:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010584d:	eb 2a                	jmp    80105879 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010584f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105852:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105855:	83 c2 08             	add    $0x8,%edx
80105858:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010585c:	85 c0                	test   %eax,%eax
8010585e:	75 15                	jne    80105875 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105863:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105866:	8d 4a 08             	lea    0x8(%edx),%ecx
80105869:	8b 55 08             	mov    0x8(%ebp),%edx
8010586c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105873:	eb 0f                	jmp    80105884 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105875:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105879:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010587d:	7e d0                	jle    8010584f <fdalloc+0x17>
    }
  }
  return -1;
8010587f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105884:	c9                   	leave
80105885:	c3                   	ret

80105886 <sys_dup>:

int
sys_dup(void)
{
80105886:	55                   	push   %ebp
80105887:	89 e5                	mov    %esp,%ebp
80105889:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010588c:	83 ec 04             	sub    $0x4,%esp
8010588f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105892:	50                   	push   %eax
80105893:	6a 00                	push   $0x0
80105895:	6a 00                	push   $0x0
80105897:	e8 28 ff ff ff       	call   801057c4 <argfd>
8010589c:	83 c4 10             	add    $0x10,%esp
8010589f:	85 c0                	test   %eax,%eax
801058a1:	79 07                	jns    801058aa <sys_dup+0x24>
    return -1;
801058a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a8:	eb 31                	jmp    801058db <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ad:	83 ec 0c             	sub    $0xc,%esp
801058b0:	50                   	push   %eax
801058b1:	e8 82 ff ff ff       	call   80105838 <fdalloc>
801058b6:	83 c4 10             	add    $0x10,%esp
801058b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c0:	79 07                	jns    801058c9 <sys_dup+0x43>
    return -1;
801058c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c7:	eb 12                	jmp    801058db <sys_dup+0x55>
  filedup(f);
801058c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058cc:	83 ec 0c             	sub    $0xc,%esp
801058cf:	50                   	push   %eax
801058d0:	e8 7f b7 ff ff       	call   80101054 <filedup>
801058d5:	83 c4 10             	add    $0x10,%esp
  return fd;
801058d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058db:	c9                   	leave
801058dc:	c3                   	ret

801058dd <sys_read>:

int
sys_read(void)
{
801058dd:	55                   	push   %ebp
801058de:	89 e5                	mov    %esp,%ebp
801058e0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058e3:	83 ec 04             	sub    $0x4,%esp
801058e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e9:	50                   	push   %eax
801058ea:	6a 00                	push   $0x0
801058ec:	6a 00                	push   $0x0
801058ee:	e8 d1 fe ff ff       	call   801057c4 <argfd>
801058f3:	83 c4 10             	add    $0x10,%esp
801058f6:	85 c0                	test   %eax,%eax
801058f8:	78 2e                	js     80105928 <sys_read+0x4b>
801058fa:	83 ec 08             	sub    $0x8,%esp
801058fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105900:	50                   	push   %eax
80105901:	6a 02                	push   $0x2
80105903:	e8 72 fd ff ff       	call   8010567a <argint>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	85 c0                	test   %eax,%eax
8010590d:	78 19                	js     80105928 <sys_read+0x4b>
8010590f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105912:	83 ec 04             	sub    $0x4,%esp
80105915:	50                   	push   %eax
80105916:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105919:	50                   	push   %eax
8010591a:	6a 01                	push   $0x1
8010591c:	e8 86 fd ff ff       	call   801056a7 <argptr>
80105921:	83 c4 10             	add    $0x10,%esp
80105924:	85 c0                	test   %eax,%eax
80105926:	79 07                	jns    8010592f <sys_read+0x52>
    return -1;
80105928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592d:	eb 17                	jmp    80105946 <sys_read+0x69>
  return fileread(f, p, n);
8010592f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105932:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105938:	83 ec 04             	sub    $0x4,%esp
8010593b:	51                   	push   %ecx
8010593c:	52                   	push   %edx
8010593d:	50                   	push   %eax
8010593e:	e8 a1 b8 ff ff       	call   801011e4 <fileread>
80105943:	83 c4 10             	add    $0x10,%esp
}
80105946:	c9                   	leave
80105947:	c3                   	ret

80105948 <sys_write>:

int
sys_write(void)
{
80105948:	55                   	push   %ebp
80105949:	89 e5                	mov    %esp,%ebp
8010594b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010594e:	83 ec 04             	sub    $0x4,%esp
80105951:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105954:	50                   	push   %eax
80105955:	6a 00                	push   $0x0
80105957:	6a 00                	push   $0x0
80105959:	e8 66 fe ff ff       	call   801057c4 <argfd>
8010595e:	83 c4 10             	add    $0x10,%esp
80105961:	85 c0                	test   %eax,%eax
80105963:	78 2e                	js     80105993 <sys_write+0x4b>
80105965:	83 ec 08             	sub    $0x8,%esp
80105968:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010596b:	50                   	push   %eax
8010596c:	6a 02                	push   $0x2
8010596e:	e8 07 fd ff ff       	call   8010567a <argint>
80105973:	83 c4 10             	add    $0x10,%esp
80105976:	85 c0                	test   %eax,%eax
80105978:	78 19                	js     80105993 <sys_write+0x4b>
8010597a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597d:	83 ec 04             	sub    $0x4,%esp
80105980:	50                   	push   %eax
80105981:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105984:	50                   	push   %eax
80105985:	6a 01                	push   $0x1
80105987:	e8 1b fd ff ff       	call   801056a7 <argptr>
8010598c:	83 c4 10             	add    $0x10,%esp
8010598f:	85 c0                	test   %eax,%eax
80105991:	79 07                	jns    8010599a <sys_write+0x52>
    return -1;
80105993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105998:	eb 17                	jmp    801059b1 <sys_write+0x69>
  return filewrite(f, p, n);
8010599a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010599d:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a3:	83 ec 04             	sub    $0x4,%esp
801059a6:	51                   	push   %ecx
801059a7:	52                   	push   %edx
801059a8:	50                   	push   %eax
801059a9:	e8 ee b8 ff ff       	call   8010129c <filewrite>
801059ae:	83 c4 10             	add    $0x10,%esp
}
801059b1:	c9                   	leave
801059b2:	c3                   	ret

801059b3 <sys_close>:

int
sys_close(void)
{
801059b3:	55                   	push   %ebp
801059b4:	89 e5                	mov    %esp,%ebp
801059b6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801059b9:	83 ec 04             	sub    $0x4,%esp
801059bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059c3:	50                   	push   %eax
801059c4:	6a 00                	push   $0x0
801059c6:	e8 f9 fd ff ff       	call   801057c4 <argfd>
801059cb:	83 c4 10             	add    $0x10,%esp
801059ce:	85 c0                	test   %eax,%eax
801059d0:	79 07                	jns    801059d9 <sys_close+0x26>
    return -1;
801059d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d7:	eb 27                	jmp    80105a00 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801059d9:	e8 52 e0 ff ff       	call   80103a30 <myproc>
801059de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059e1:	83 c2 08             	add    $0x8,%edx
801059e4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801059eb:	00 
  fileclose(f);
801059ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	50                   	push   %eax
801059f3:	e8 ad b6 ff ff       	call   801010a5 <fileclose>
801059f8:	83 c4 10             	add    $0x10,%esp
  return 0;
801059fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a00:	c9                   	leave
80105a01:	c3                   	ret

80105a02 <sys_fstat>:

int
sys_fstat(void)
{
80105a02:	55                   	push   %ebp
80105a03:	89 e5                	mov    %esp,%ebp
80105a05:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a08:	83 ec 04             	sub    $0x4,%esp
80105a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a0e:	50                   	push   %eax
80105a0f:	6a 00                	push   $0x0
80105a11:	6a 00                	push   $0x0
80105a13:	e8 ac fd ff ff       	call   801057c4 <argfd>
80105a18:	83 c4 10             	add    $0x10,%esp
80105a1b:	85 c0                	test   %eax,%eax
80105a1d:	78 17                	js     80105a36 <sys_fstat+0x34>
80105a1f:	83 ec 04             	sub    $0x4,%esp
80105a22:	6a 14                	push   $0x14
80105a24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a27:	50                   	push   %eax
80105a28:	6a 01                	push   $0x1
80105a2a:	e8 78 fc ff ff       	call   801056a7 <argptr>
80105a2f:	83 c4 10             	add    $0x10,%esp
80105a32:	85 c0                	test   %eax,%eax
80105a34:	79 07                	jns    80105a3d <sys_fstat+0x3b>
    return -1;
80105a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3b:	eb 13                	jmp    80105a50 <sys_fstat+0x4e>
  return filestat(f, st);
80105a3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a43:	83 ec 08             	sub    $0x8,%esp
80105a46:	52                   	push   %edx
80105a47:	50                   	push   %eax
80105a48:	e8 40 b7 ff ff       	call   8010118d <filestat>
80105a4d:	83 c4 10             	add    $0x10,%esp
}
80105a50:	c9                   	leave
80105a51:	c3                   	ret

80105a52 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a52:	55                   	push   %ebp
80105a53:	89 e5                	mov    %esp,%ebp
80105a55:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a58:	83 ec 08             	sub    $0x8,%esp
80105a5b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a5e:	50                   	push   %eax
80105a5f:	6a 00                	push   $0x0
80105a61:	e8 a9 fc ff ff       	call   8010570f <argstr>
80105a66:	83 c4 10             	add    $0x10,%esp
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	78 15                	js     80105a82 <sys_link+0x30>
80105a6d:	83 ec 08             	sub    $0x8,%esp
80105a70:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a73:	50                   	push   %eax
80105a74:	6a 01                	push   $0x1
80105a76:	e8 94 fc ff ff       	call   8010570f <argstr>
80105a7b:	83 c4 10             	add    $0x10,%esp
80105a7e:	85 c0                	test   %eax,%eax
80105a80:	79 0a                	jns    80105a8c <sys_link+0x3a>
    return -1;
80105a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a87:	e9 68 01 00 00       	jmp    80105bf4 <sys_link+0x1a2>

  begin_op();
80105a8c:	e8 ad d5 ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105a91:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a94:	83 ec 0c             	sub    $0xc,%esp
80105a97:	50                   	push   %eax
80105a98:	e8 88 ca ff ff       	call   80102525 <namei>
80105a9d:	83 c4 10             	add    $0x10,%esp
80105aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aa7:	75 0f                	jne    80105ab8 <sys_link+0x66>
    end_op();
80105aa9:	e8 1c d6 ff ff       	call   801030ca <end_op>
    return -1;
80105aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab3:	e9 3c 01 00 00       	jmp    80105bf4 <sys_link+0x1a2>
  }

  ilock(ip);
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	ff 75 f4             	push   -0xc(%ebp)
80105abe:	e8 2f bf ff ff       	call   801019f2 <ilock>
80105ac3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105acd:	66 83 f8 01          	cmp    $0x1,%ax
80105ad1:	75 1d                	jne    80105af0 <sys_link+0x9e>
    iunlockput(ip);
80105ad3:	83 ec 0c             	sub    $0xc,%esp
80105ad6:	ff 75 f4             	push   -0xc(%ebp)
80105ad9:	e8 45 c1 ff ff       	call   80101c23 <iunlockput>
80105ade:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ae1:	e8 e4 d5 ff ff       	call   801030ca <end_op>
    return -1;
80105ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aeb:	e9 04 01 00 00       	jmp    80105bf4 <sys_link+0x1a2>
  }

  ip->nlink++;
80105af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105af7:	83 c0 01             	add    $0x1,%eax
80105afa:	89 c2                	mov    %eax,%edx
80105afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aff:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	ff 75 f4             	push   -0xc(%ebp)
80105b09:	e8 07 bd ff ff       	call   80101815 <iupdate>
80105b0e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105b11:	83 ec 0c             	sub    $0xc,%esp
80105b14:	ff 75 f4             	push   -0xc(%ebp)
80105b17:	e8 e9 bf ff ff       	call   80101b05 <iunlock>
80105b1c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105b1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b22:	83 ec 08             	sub    $0x8,%esp
80105b25:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b28:	52                   	push   %edx
80105b29:	50                   	push   %eax
80105b2a:	e8 12 ca ff ff       	call   80102541 <nameiparent>
80105b2f:	83 c4 10             	add    $0x10,%esp
80105b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b39:	74 71                	je     80105bac <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	ff 75 f0             	push   -0x10(%ebp)
80105b41:	e8 ac be ff ff       	call   801019f2 <ilock>
80105b46:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4c:	8b 10                	mov    (%eax),%edx
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	8b 00                	mov    (%eax),%eax
80105b53:	39 c2                	cmp    %eax,%edx
80105b55:	75 1d                	jne    80105b74 <sys_link+0x122>
80105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5a:	8b 40 04             	mov    0x4(%eax),%eax
80105b5d:	83 ec 04             	sub    $0x4,%esp
80105b60:	50                   	push   %eax
80105b61:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b64:	50                   	push   %eax
80105b65:	ff 75 f0             	push   -0x10(%ebp)
80105b68:	e8 21 c7 ff ff       	call   8010228e <dirlink>
80105b6d:	83 c4 10             	add    $0x10,%esp
80105b70:	85 c0                	test   %eax,%eax
80105b72:	79 10                	jns    80105b84 <sys_link+0x132>
    iunlockput(dp);
80105b74:	83 ec 0c             	sub    $0xc,%esp
80105b77:	ff 75 f0             	push   -0x10(%ebp)
80105b7a:	e8 a4 c0 ff ff       	call   80101c23 <iunlockput>
80105b7f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b82:	eb 29                	jmp    80105bad <sys_link+0x15b>
  }
  iunlockput(dp);
80105b84:	83 ec 0c             	sub    $0xc,%esp
80105b87:	ff 75 f0             	push   -0x10(%ebp)
80105b8a:	e8 94 c0 ff ff       	call   80101c23 <iunlockput>
80105b8f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b92:	83 ec 0c             	sub    $0xc,%esp
80105b95:	ff 75 f4             	push   -0xc(%ebp)
80105b98:	e8 b6 bf ff ff       	call   80101b53 <iput>
80105b9d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ba0:	e8 25 d5 ff ff       	call   801030ca <end_op>

  return 0;
80105ba5:	b8 00 00 00 00       	mov    $0x0,%eax
80105baa:	eb 48                	jmp    80105bf4 <sys_link+0x1a2>
    goto bad;
80105bac:	90                   	nop

bad:
  ilock(ip);
80105bad:	83 ec 0c             	sub    $0xc,%esp
80105bb0:	ff 75 f4             	push   -0xc(%ebp)
80105bb3:	e8 3a be ff ff       	call   801019f2 <ilock>
80105bb8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbe:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bc2:	83 e8 01             	sub    $0x1,%eax
80105bc5:	89 c2                	mov    %eax,%edx
80105bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bca:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105bce:	83 ec 0c             	sub    $0xc,%esp
80105bd1:	ff 75 f4             	push   -0xc(%ebp)
80105bd4:	e8 3c bc ff ff       	call   80101815 <iupdate>
80105bd9:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105bdc:	83 ec 0c             	sub    $0xc,%esp
80105bdf:	ff 75 f4             	push   -0xc(%ebp)
80105be2:	e8 3c c0 ff ff       	call   80101c23 <iunlockput>
80105be7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bea:	e8 db d4 ff ff       	call   801030ca <end_op>
  return -1;
80105bef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bf4:	c9                   	leave
80105bf5:	c3                   	ret

80105bf6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105bf6:	55                   	push   %ebp
80105bf7:	89 e5                	mov    %esp,%ebp
80105bf9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bfc:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c03:	eb 40                	jmp    80105c45 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c08:	6a 10                	push   $0x10
80105c0a:	50                   	push   %eax
80105c0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c0e:	50                   	push   %eax
80105c0f:	ff 75 08             	push   0x8(%ebp)
80105c12:	e8 c7 c2 ff ff       	call   80101ede <readi>
80105c17:	83 c4 10             	add    $0x10,%esp
80105c1a:	83 f8 10             	cmp    $0x10,%eax
80105c1d:	74 0d                	je     80105c2c <isdirempty+0x36>
      panic("isdirempty: readi");
80105c1f:	83 ec 0c             	sub    $0xc,%esp
80105c22:	68 39 b0 10 80       	push   $0x8010b039
80105c27:	e8 7d a9 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105c2c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c30:	66 85 c0             	test   %ax,%ax
80105c33:	74 07                	je     80105c3c <isdirempty+0x46>
      return 0;
80105c35:	b8 00 00 00 00       	mov    $0x0,%eax
80105c3a:	eb 1b                	jmp    80105c57 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	83 c0 10             	add    $0x10,%eax
80105c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c45:	8b 45 08             	mov    0x8(%ebp),%eax
80105c48:	8b 40 58             	mov    0x58(%eax),%eax
80105c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c4e:	39 c2                	cmp    %eax,%edx
80105c50:	72 b3                	jb     80105c05 <isdirempty+0xf>
  }
  return 1;
80105c52:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c57:	c9                   	leave
80105c58:	c3                   	ret

80105c59 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c59:	55                   	push   %ebp
80105c5a:	89 e5                	mov    %esp,%ebp
80105c5c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c5f:	83 ec 08             	sub    $0x8,%esp
80105c62:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c65:	50                   	push   %eax
80105c66:	6a 00                	push   $0x0
80105c68:	e8 a2 fa ff ff       	call   8010570f <argstr>
80105c6d:	83 c4 10             	add    $0x10,%esp
80105c70:	85 c0                	test   %eax,%eax
80105c72:	79 0a                	jns    80105c7e <sys_unlink+0x25>
    return -1;
80105c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c79:	e9 bf 01 00 00       	jmp    80105e3d <sys_unlink+0x1e4>

  begin_op();
80105c7e:	e8 bb d3 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c83:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c86:	83 ec 08             	sub    $0x8,%esp
80105c89:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c8c:	52                   	push   %edx
80105c8d:	50                   	push   %eax
80105c8e:	e8 ae c8 ff ff       	call   80102541 <nameiparent>
80105c93:	83 c4 10             	add    $0x10,%esp
80105c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c9d:	75 0f                	jne    80105cae <sys_unlink+0x55>
    end_op();
80105c9f:	e8 26 d4 ff ff       	call   801030ca <end_op>
    return -1;
80105ca4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca9:	e9 8f 01 00 00       	jmp    80105e3d <sys_unlink+0x1e4>
  }

  ilock(dp);
80105cae:	83 ec 0c             	sub    $0xc,%esp
80105cb1:	ff 75 f4             	push   -0xc(%ebp)
80105cb4:	e8 39 bd ff ff       	call   801019f2 <ilock>
80105cb9:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105cbc:	83 ec 08             	sub    $0x8,%esp
80105cbf:	68 4b b0 10 80       	push   $0x8010b04b
80105cc4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cc7:	50                   	push   %eax
80105cc8:	e8 ec c4 ff ff       	call   801021b9 <namecmp>
80105ccd:	83 c4 10             	add    $0x10,%esp
80105cd0:	85 c0                	test   %eax,%eax
80105cd2:	0f 84 49 01 00 00    	je     80105e21 <sys_unlink+0x1c8>
80105cd8:	83 ec 08             	sub    $0x8,%esp
80105cdb:	68 4d b0 10 80       	push   $0x8010b04d
80105ce0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ce3:	50                   	push   %eax
80105ce4:	e8 d0 c4 ff ff       	call   801021b9 <namecmp>
80105ce9:	83 c4 10             	add    $0x10,%esp
80105cec:	85 c0                	test   %eax,%eax
80105cee:	0f 84 2d 01 00 00    	je     80105e21 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105cf4:	83 ec 04             	sub    $0x4,%esp
80105cf7:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105cfa:	50                   	push   %eax
80105cfb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cfe:	50                   	push   %eax
80105cff:	ff 75 f4             	push   -0xc(%ebp)
80105d02:	e8 cd c4 ff ff       	call   801021d4 <dirlookup>
80105d07:	83 c4 10             	add    $0x10,%esp
80105d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d11:	0f 84 0d 01 00 00    	je     80105e24 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105d17:	83 ec 0c             	sub    $0xc,%esp
80105d1a:	ff 75 f0             	push   -0x10(%ebp)
80105d1d:	e8 d0 bc ff ff       	call   801019f2 <ilock>
80105d22:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d28:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d2c:	66 85 c0             	test   %ax,%ax
80105d2f:	7f 0d                	jg     80105d3e <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105d31:	83 ec 0c             	sub    $0xc,%esp
80105d34:	68 50 b0 10 80       	push   $0x8010b050
80105d39:	e8 6b a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d41:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d45:	66 83 f8 01          	cmp    $0x1,%ax
80105d49:	75 25                	jne    80105d70 <sys_unlink+0x117>
80105d4b:	83 ec 0c             	sub    $0xc,%esp
80105d4e:	ff 75 f0             	push   -0x10(%ebp)
80105d51:	e8 a0 fe ff ff       	call   80105bf6 <isdirempty>
80105d56:	83 c4 10             	add    $0x10,%esp
80105d59:	85 c0                	test   %eax,%eax
80105d5b:	75 13                	jne    80105d70 <sys_unlink+0x117>
    iunlockput(ip);
80105d5d:	83 ec 0c             	sub    $0xc,%esp
80105d60:	ff 75 f0             	push   -0x10(%ebp)
80105d63:	e8 bb be ff ff       	call   80101c23 <iunlockput>
80105d68:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d6b:	e9 b5 00 00 00       	jmp    80105e25 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105d70:	83 ec 04             	sub    $0x4,%esp
80105d73:	6a 10                	push   $0x10
80105d75:	6a 00                	push   $0x0
80105d77:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d7a:	50                   	push   %eax
80105d7b:	e8 cf f5 ff ff       	call   8010534f <memset>
80105d80:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d83:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d86:	6a 10                	push   $0x10
80105d88:	50                   	push   %eax
80105d89:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d8c:	50                   	push   %eax
80105d8d:	ff 75 f4             	push   -0xc(%ebp)
80105d90:	e8 9e c2 ff ff       	call   80102033 <writei>
80105d95:	83 c4 10             	add    $0x10,%esp
80105d98:	83 f8 10             	cmp    $0x10,%eax
80105d9b:	74 0d                	je     80105daa <sys_unlink+0x151>
    panic("unlink: writei");
80105d9d:	83 ec 0c             	sub    $0xc,%esp
80105da0:	68 62 b0 10 80       	push   $0x8010b062
80105da5:	e8 ff a7 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dad:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105db1:	66 83 f8 01          	cmp    $0x1,%ax
80105db5:	75 21                	jne    80105dd8 <sys_unlink+0x17f>
    dp->nlink--;
80105db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dba:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dbe:	83 e8 01             	sub    $0x1,%eax
80105dc1:	89 c2                	mov    %eax,%edx
80105dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc6:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105dca:	83 ec 0c             	sub    $0xc,%esp
80105dcd:	ff 75 f4             	push   -0xc(%ebp)
80105dd0:	e8 40 ba ff ff       	call   80101815 <iupdate>
80105dd5:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105dd8:	83 ec 0c             	sub    $0xc,%esp
80105ddb:	ff 75 f4             	push   -0xc(%ebp)
80105dde:	e8 40 be ff ff       	call   80101c23 <iunlockput>
80105de3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ded:	83 e8 01             	sub    $0x1,%eax
80105df0:	89 c2                	mov    %eax,%edx
80105df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105df9:	83 ec 0c             	sub    $0xc,%esp
80105dfc:	ff 75 f0             	push   -0x10(%ebp)
80105dff:	e8 11 ba ff ff       	call   80101815 <iupdate>
80105e04:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e07:	83 ec 0c             	sub    $0xc,%esp
80105e0a:	ff 75 f0             	push   -0x10(%ebp)
80105e0d:	e8 11 be ff ff       	call   80101c23 <iunlockput>
80105e12:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e15:	e8 b0 d2 ff ff       	call   801030ca <end_op>

  return 0;
80105e1a:	b8 00 00 00 00       	mov    $0x0,%eax
80105e1f:	eb 1c                	jmp    80105e3d <sys_unlink+0x1e4>
    goto bad;
80105e21:	90                   	nop
80105e22:	eb 01                	jmp    80105e25 <sys_unlink+0x1cc>
    goto bad;
80105e24:	90                   	nop

bad:
  iunlockput(dp);
80105e25:	83 ec 0c             	sub    $0xc,%esp
80105e28:	ff 75 f4             	push   -0xc(%ebp)
80105e2b:	e8 f3 bd ff ff       	call   80101c23 <iunlockput>
80105e30:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e33:	e8 92 d2 ff ff       	call   801030ca <end_op>
  return -1;
80105e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e3d:	c9                   	leave
80105e3e:	c3                   	ret

80105e3f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e3f:	55                   	push   %ebp
80105e40:	89 e5                	mov    %esp,%ebp
80105e42:	83 ec 38             	sub    $0x38,%esp
80105e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e48:	8b 55 10             	mov    0x10(%ebp),%edx
80105e4b:	8b 45 14             	mov    0x14(%ebp),%eax
80105e4e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e52:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e56:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e5a:	83 ec 08             	sub    $0x8,%esp
80105e5d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e60:	50                   	push   %eax
80105e61:	ff 75 08             	push   0x8(%ebp)
80105e64:	e8 d8 c6 ff ff       	call   80102541 <nameiparent>
80105e69:	83 c4 10             	add    $0x10,%esp
80105e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e73:	75 0a                	jne    80105e7f <create+0x40>
    return 0;
80105e75:	b8 00 00 00 00       	mov    $0x0,%eax
80105e7a:	e9 90 01 00 00       	jmp    8010600f <create+0x1d0>
  ilock(dp);
80105e7f:	83 ec 0c             	sub    $0xc,%esp
80105e82:	ff 75 f4             	push   -0xc(%ebp)
80105e85:	e8 68 bb ff ff       	call   801019f2 <ilock>
80105e8a:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e8d:	83 ec 04             	sub    $0x4,%esp
80105e90:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e93:	50                   	push   %eax
80105e94:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e97:	50                   	push   %eax
80105e98:	ff 75 f4             	push   -0xc(%ebp)
80105e9b:	e8 34 c3 ff ff       	call   801021d4 <dirlookup>
80105ea0:	83 c4 10             	add    $0x10,%esp
80105ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eaa:	74 50                	je     80105efc <create+0xbd>
    iunlockput(dp);
80105eac:	83 ec 0c             	sub    $0xc,%esp
80105eaf:	ff 75 f4             	push   -0xc(%ebp)
80105eb2:	e8 6c bd ff ff       	call   80101c23 <iunlockput>
80105eb7:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105eba:	83 ec 0c             	sub    $0xc,%esp
80105ebd:	ff 75 f0             	push   -0x10(%ebp)
80105ec0:	e8 2d bb ff ff       	call   801019f2 <ilock>
80105ec5:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105ec8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ecd:	75 15                	jne    80105ee4 <create+0xa5>
80105ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ed6:	66 83 f8 02          	cmp    $0x2,%ax
80105eda:	75 08                	jne    80105ee4 <create+0xa5>
      return ip;
80105edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edf:	e9 2b 01 00 00       	jmp    8010600f <create+0x1d0>
    iunlockput(ip);
80105ee4:	83 ec 0c             	sub    $0xc,%esp
80105ee7:	ff 75 f0             	push   -0x10(%ebp)
80105eea:	e8 34 bd ff ff       	call   80101c23 <iunlockput>
80105eef:	83 c4 10             	add    $0x10,%esp
    return 0;
80105ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ef7:	e9 13 01 00 00       	jmp    8010600f <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105efc:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f03:	8b 00                	mov    (%eax),%eax
80105f05:	83 ec 08             	sub    $0x8,%esp
80105f08:	52                   	push   %edx
80105f09:	50                   	push   %eax
80105f0a:	e8 30 b8 ff ff       	call   8010173f <ialloc>
80105f0f:	83 c4 10             	add    $0x10,%esp
80105f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f19:	75 0d                	jne    80105f28 <create+0xe9>
    panic("create: ialloc");
80105f1b:	83 ec 0c             	sub    $0xc,%esp
80105f1e:	68 71 b0 10 80       	push   $0x8010b071
80105f23:	e8 81 a6 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105f28:	83 ec 0c             	sub    $0xc,%esp
80105f2b:	ff 75 f0             	push   -0x10(%ebp)
80105f2e:	e8 bf ba ff ff       	call   801019f2 <ilock>
80105f33:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f3d:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f44:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f48:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4f:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105f55:	83 ec 0c             	sub    $0xc,%esp
80105f58:	ff 75 f0             	push   -0x10(%ebp)
80105f5b:	e8 b5 b8 ff ff       	call   80101815 <iupdate>
80105f60:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105f63:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f68:	75 6a                	jne    80105fd4 <create+0x195>
    dp->nlink++;  // for ".."
80105f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f71:	83 c0 01             	add    $0x1,%eax
80105f74:	89 c2                	mov    %eax,%edx
80105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f79:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f7d:	83 ec 0c             	sub    $0xc,%esp
80105f80:	ff 75 f4             	push   -0xc(%ebp)
80105f83:	e8 8d b8 ff ff       	call   80101815 <iupdate>
80105f88:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8e:	8b 40 04             	mov    0x4(%eax),%eax
80105f91:	83 ec 04             	sub    $0x4,%esp
80105f94:	50                   	push   %eax
80105f95:	68 4b b0 10 80       	push   $0x8010b04b
80105f9a:	ff 75 f0             	push   -0x10(%ebp)
80105f9d:	e8 ec c2 ff ff       	call   8010228e <dirlink>
80105fa2:	83 c4 10             	add    $0x10,%esp
80105fa5:	85 c0                	test   %eax,%eax
80105fa7:	78 1e                	js     80105fc7 <create+0x188>
80105fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fac:	8b 40 04             	mov    0x4(%eax),%eax
80105faf:	83 ec 04             	sub    $0x4,%esp
80105fb2:	50                   	push   %eax
80105fb3:	68 4d b0 10 80       	push   $0x8010b04d
80105fb8:	ff 75 f0             	push   -0x10(%ebp)
80105fbb:	e8 ce c2 ff ff       	call   8010228e <dirlink>
80105fc0:	83 c4 10             	add    $0x10,%esp
80105fc3:	85 c0                	test   %eax,%eax
80105fc5:	79 0d                	jns    80105fd4 <create+0x195>
      panic("create dots");
80105fc7:	83 ec 0c             	sub    $0xc,%esp
80105fca:	68 80 b0 10 80       	push   $0x8010b080
80105fcf:	e8 d5 a5 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd7:	8b 40 04             	mov    0x4(%eax),%eax
80105fda:	83 ec 04             	sub    $0x4,%esp
80105fdd:	50                   	push   %eax
80105fde:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fe1:	50                   	push   %eax
80105fe2:	ff 75 f4             	push   -0xc(%ebp)
80105fe5:	e8 a4 c2 ff ff       	call   8010228e <dirlink>
80105fea:	83 c4 10             	add    $0x10,%esp
80105fed:	85 c0                	test   %eax,%eax
80105fef:	79 0d                	jns    80105ffe <create+0x1bf>
    panic("create: dirlink");
80105ff1:	83 ec 0c             	sub    $0xc,%esp
80105ff4:	68 8c b0 10 80       	push   $0x8010b08c
80105ff9:	e8 ab a5 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105ffe:	83 ec 0c             	sub    $0xc,%esp
80106001:	ff 75 f4             	push   -0xc(%ebp)
80106004:	e8 1a bc ff ff       	call   80101c23 <iunlockput>
80106009:	83 c4 10             	add    $0x10,%esp

  return ip;
8010600c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010600f:	c9                   	leave
80106010:	c3                   	ret

80106011 <sys_open>:

int
sys_open(void)
{
80106011:	55                   	push   %ebp
80106012:	89 e5                	mov    %esp,%ebp
80106014:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106017:	83 ec 08             	sub    $0x8,%esp
8010601a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010601d:	50                   	push   %eax
8010601e:	6a 00                	push   $0x0
80106020:	e8 ea f6 ff ff       	call   8010570f <argstr>
80106025:	83 c4 10             	add    $0x10,%esp
80106028:	85 c0                	test   %eax,%eax
8010602a:	78 15                	js     80106041 <sys_open+0x30>
8010602c:	83 ec 08             	sub    $0x8,%esp
8010602f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106032:	50                   	push   %eax
80106033:	6a 01                	push   $0x1
80106035:	e8 40 f6 ff ff       	call   8010567a <argint>
8010603a:	83 c4 10             	add    $0x10,%esp
8010603d:	85 c0                	test   %eax,%eax
8010603f:	79 0a                	jns    8010604b <sys_open+0x3a>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	e9 61 01 00 00       	jmp    801061ac <sys_open+0x19b>

  begin_op();
8010604b:	e8 ee cf ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80106050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106053:	25 00 02 00 00       	and    $0x200,%eax
80106058:	85 c0                	test   %eax,%eax
8010605a:	74 2a                	je     80106086 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010605c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010605f:	6a 00                	push   $0x0
80106061:	6a 00                	push   $0x0
80106063:	6a 02                	push   $0x2
80106065:	50                   	push   %eax
80106066:	e8 d4 fd ff ff       	call   80105e3f <create>
8010606b:	83 c4 10             	add    $0x10,%esp
8010606e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106071:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106075:	75 75                	jne    801060ec <sys_open+0xdb>
      end_op();
80106077:	e8 4e d0 ff ff       	call   801030ca <end_op>
      return -1;
8010607c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106081:	e9 26 01 00 00       	jmp    801061ac <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106086:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106089:	83 ec 0c             	sub    $0xc,%esp
8010608c:	50                   	push   %eax
8010608d:	e8 93 c4 ff ff       	call   80102525 <namei>
80106092:	83 c4 10             	add    $0x10,%esp
80106095:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106098:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010609c:	75 0f                	jne    801060ad <sys_open+0x9c>
      end_op();
8010609e:	e8 27 d0 ff ff       	call   801030ca <end_op>
      return -1;
801060a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a8:	e9 ff 00 00 00       	jmp    801061ac <sys_open+0x19b>
    }
    ilock(ip);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	ff 75 f4             	push   -0xc(%ebp)
801060b3:	e8 3a b9 ff ff       	call   801019f2 <ilock>
801060b8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801060bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060be:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060c2:	66 83 f8 01          	cmp    $0x1,%ax
801060c6:	75 24                	jne    801060ec <sys_open+0xdb>
801060c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060cb:	85 c0                	test   %eax,%eax
801060cd:	74 1d                	je     801060ec <sys_open+0xdb>
      iunlockput(ip);
801060cf:	83 ec 0c             	sub    $0xc,%esp
801060d2:	ff 75 f4             	push   -0xc(%ebp)
801060d5:	e8 49 bb ff ff       	call   80101c23 <iunlockput>
801060da:	83 c4 10             	add    $0x10,%esp
      end_op();
801060dd:	e8 e8 cf ff ff       	call   801030ca <end_op>
      return -1;
801060e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e7:	e9 c0 00 00 00       	jmp    801061ac <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801060ec:	e8 f6 ae ff ff       	call   80100fe7 <filealloc>
801060f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060f8:	74 17                	je     80106111 <sys_open+0x100>
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	ff 75 f0             	push   -0x10(%ebp)
80106100:	e8 33 f7 ff ff       	call   80105838 <fdalloc>
80106105:	83 c4 10             	add    $0x10,%esp
80106108:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010610b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010610f:	79 2e                	jns    8010613f <sys_open+0x12e>
    if(f)
80106111:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106115:	74 0e                	je     80106125 <sys_open+0x114>
      fileclose(f);
80106117:	83 ec 0c             	sub    $0xc,%esp
8010611a:	ff 75 f0             	push   -0x10(%ebp)
8010611d:	e8 83 af ff ff       	call   801010a5 <fileclose>
80106122:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106125:	83 ec 0c             	sub    $0xc,%esp
80106128:	ff 75 f4             	push   -0xc(%ebp)
8010612b:	e8 f3 ba ff ff       	call   80101c23 <iunlockput>
80106130:	83 c4 10             	add    $0x10,%esp
    end_op();
80106133:	e8 92 cf ff ff       	call   801030ca <end_op>
    return -1;
80106138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613d:	eb 6d                	jmp    801061ac <sys_open+0x19b>
  }
  iunlock(ip);
8010613f:	83 ec 0c             	sub    $0xc,%esp
80106142:	ff 75 f4             	push   -0xc(%ebp)
80106145:	e8 bb b9 ff ff       	call   80101b05 <iunlock>
8010614a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010614d:	e8 78 cf ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80106152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106155:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010615b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106161:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106167:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010616e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106171:	83 e0 01             	and    $0x1,%eax
80106174:	85 c0                	test   %eax,%eax
80106176:	0f 94 c0             	sete   %al
80106179:	89 c2                	mov    %eax,%edx
8010617b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106181:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106184:	83 e0 01             	and    $0x1,%eax
80106187:	85 c0                	test   %eax,%eax
80106189:	75 0a                	jne    80106195 <sys_open+0x184>
8010618b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010618e:	83 e0 02             	and    $0x2,%eax
80106191:	85 c0                	test   %eax,%eax
80106193:	74 07                	je     8010619c <sys_open+0x18b>
80106195:	b8 01 00 00 00       	mov    $0x1,%eax
8010619a:	eb 05                	jmp    801061a1 <sys_open+0x190>
8010619c:	b8 00 00 00 00       	mov    $0x0,%eax
801061a1:	89 c2                	mov    %eax,%edx
801061a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a6:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061ac:	c9                   	leave
801061ad:	c3                   	ret

801061ae <sys_mkdir>:

int
sys_mkdir(void)
{
801061ae:	55                   	push   %ebp
801061af:	89 e5                	mov    %esp,%ebp
801061b1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061b4:	e8 85 ce ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061b9:	83 ec 08             	sub    $0x8,%esp
801061bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061bf:	50                   	push   %eax
801061c0:	6a 00                	push   $0x0
801061c2:	e8 48 f5 ff ff       	call   8010570f <argstr>
801061c7:	83 c4 10             	add    $0x10,%esp
801061ca:	85 c0                	test   %eax,%eax
801061cc:	78 1b                	js     801061e9 <sys_mkdir+0x3b>
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	6a 00                	push   $0x0
801061d3:	6a 00                	push   $0x0
801061d5:	6a 01                	push   $0x1
801061d7:	50                   	push   %eax
801061d8:	e8 62 fc ff ff       	call   80105e3f <create>
801061dd:	83 c4 10             	add    $0x10,%esp
801061e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e7:	75 0c                	jne    801061f5 <sys_mkdir+0x47>
    end_op();
801061e9:	e8 dc ce ff ff       	call   801030ca <end_op>
    return -1;
801061ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f3:	eb 18                	jmp    8010620d <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801061f5:	83 ec 0c             	sub    $0xc,%esp
801061f8:	ff 75 f4             	push   -0xc(%ebp)
801061fb:	e8 23 ba ff ff       	call   80101c23 <iunlockput>
80106200:	83 c4 10             	add    $0x10,%esp
  end_op();
80106203:	e8 c2 ce ff ff       	call   801030ca <end_op>
  return 0;
80106208:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010620d:	c9                   	leave
8010620e:	c3                   	ret

8010620f <sys_mknod>:

int
sys_mknod(void)
{
8010620f:	55                   	push   %ebp
80106210:	89 e5                	mov    %esp,%ebp
80106212:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106215:	e8 24 ce ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
8010621a:	83 ec 08             	sub    $0x8,%esp
8010621d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106220:	50                   	push   %eax
80106221:	6a 00                	push   $0x0
80106223:	e8 e7 f4 ff ff       	call   8010570f <argstr>
80106228:	83 c4 10             	add    $0x10,%esp
8010622b:	85 c0                	test   %eax,%eax
8010622d:	78 4f                	js     8010627e <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010622f:	83 ec 08             	sub    $0x8,%esp
80106232:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106235:	50                   	push   %eax
80106236:	6a 01                	push   $0x1
80106238:	e8 3d f4 ff ff       	call   8010567a <argint>
8010623d:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106240:	85 c0                	test   %eax,%eax
80106242:	78 3a                	js     8010627e <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80106244:	83 ec 08             	sub    $0x8,%esp
80106247:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010624a:	50                   	push   %eax
8010624b:	6a 02                	push   $0x2
8010624d:	e8 28 f4 ff ff       	call   8010567a <argint>
80106252:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106255:	85 c0                	test   %eax,%eax
80106257:	78 25                	js     8010627e <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106259:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010625c:	0f bf c8             	movswl %ax,%ecx
8010625f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106262:	0f bf d0             	movswl %ax,%edx
80106265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106268:	51                   	push   %ecx
80106269:	52                   	push   %edx
8010626a:	6a 03                	push   $0x3
8010626c:	50                   	push   %eax
8010626d:	e8 cd fb ff ff       	call   80105e3f <create>
80106272:	83 c4 10             	add    $0x10,%esp
80106275:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106278:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010627c:	75 0c                	jne    8010628a <sys_mknod+0x7b>
    end_op();
8010627e:	e8 47 ce ff ff       	call   801030ca <end_op>
    return -1;
80106283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106288:	eb 18                	jmp    801062a2 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010628a:	83 ec 0c             	sub    $0xc,%esp
8010628d:	ff 75 f4             	push   -0xc(%ebp)
80106290:	e8 8e b9 ff ff       	call   80101c23 <iunlockput>
80106295:	83 c4 10             	add    $0x10,%esp
  end_op();
80106298:	e8 2d ce ff ff       	call   801030ca <end_op>
  return 0;
8010629d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062a2:	c9                   	leave
801062a3:	c3                   	ret

801062a4 <sys_chdir>:

int
sys_chdir(void)
{
801062a4:	55                   	push   %ebp
801062a5:	89 e5                	mov    %esp,%ebp
801062a7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801062aa:	e8 81 d7 ff ff       	call   80103a30 <myproc>
801062af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801062b2:	e8 87 cd ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062b7:	83 ec 08             	sub    $0x8,%esp
801062ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062bd:	50                   	push   %eax
801062be:	6a 00                	push   $0x0
801062c0:	e8 4a f4 ff ff       	call   8010570f <argstr>
801062c5:	83 c4 10             	add    $0x10,%esp
801062c8:	85 c0                	test   %eax,%eax
801062ca:	78 18                	js     801062e4 <sys_chdir+0x40>
801062cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062cf:	83 ec 0c             	sub    $0xc,%esp
801062d2:	50                   	push   %eax
801062d3:	e8 4d c2 ff ff       	call   80102525 <namei>
801062d8:	83 c4 10             	add    $0x10,%esp
801062db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062e2:	75 0c                	jne    801062f0 <sys_chdir+0x4c>
    end_op();
801062e4:	e8 e1 cd ff ff       	call   801030ca <end_op>
    return -1;
801062e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ee:	eb 68                	jmp    80106358 <sys_chdir+0xb4>
  }
  ilock(ip);
801062f0:	83 ec 0c             	sub    $0xc,%esp
801062f3:	ff 75 f0             	push   -0x10(%ebp)
801062f6:	e8 f7 b6 ff ff       	call   801019f2 <ilock>
801062fb:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801062fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106301:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106305:	66 83 f8 01          	cmp    $0x1,%ax
80106309:	74 1a                	je     80106325 <sys_chdir+0x81>
    iunlockput(ip);
8010630b:	83 ec 0c             	sub    $0xc,%esp
8010630e:	ff 75 f0             	push   -0x10(%ebp)
80106311:	e8 0d b9 ff ff       	call   80101c23 <iunlockput>
80106316:	83 c4 10             	add    $0x10,%esp
    end_op();
80106319:	e8 ac cd ff ff       	call   801030ca <end_op>
    return -1;
8010631e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106323:	eb 33                	jmp    80106358 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106325:	83 ec 0c             	sub    $0xc,%esp
80106328:	ff 75 f0             	push   -0x10(%ebp)
8010632b:	e8 d5 b7 ff ff       	call   80101b05 <iunlock>
80106330:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106336:	8b 40 68             	mov    0x68(%eax),%eax
80106339:	83 ec 0c             	sub    $0xc,%esp
8010633c:	50                   	push   %eax
8010633d:	e8 11 b8 ff ff       	call   80101b53 <iput>
80106342:	83 c4 10             	add    $0x10,%esp
  end_op();
80106345:	e8 80 cd ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
8010634a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106350:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106353:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106358:	c9                   	leave
80106359:	c3                   	ret

8010635a <sys_exec>:

int
sys_exec(void)
{
8010635a:	55                   	push   %ebp
8010635b:	89 e5                	mov    %esp,%ebp
8010635d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106363:	83 ec 08             	sub    $0x8,%esp
80106366:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106369:	50                   	push   %eax
8010636a:	6a 00                	push   $0x0
8010636c:	e8 9e f3 ff ff       	call   8010570f <argstr>
80106371:	83 c4 10             	add    $0x10,%esp
80106374:	85 c0                	test   %eax,%eax
80106376:	78 18                	js     80106390 <sys_exec+0x36>
80106378:	83 ec 08             	sub    $0x8,%esp
8010637b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106381:	50                   	push   %eax
80106382:	6a 01                	push   $0x1
80106384:	e8 f1 f2 ff ff       	call   8010567a <argint>
80106389:	83 c4 10             	add    $0x10,%esp
8010638c:	85 c0                	test   %eax,%eax
8010638e:	79 0a                	jns    8010639a <sys_exec+0x40>
    return -1;
80106390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106395:	e9 c6 00 00 00       	jmp    80106460 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010639a:	83 ec 04             	sub    $0x4,%esp
8010639d:	68 80 00 00 00       	push   $0x80
801063a2:	6a 00                	push   $0x0
801063a4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063aa:	50                   	push   %eax
801063ab:	e8 9f ef ff ff       	call   8010534f <memset>
801063b0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801063b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bd:	83 f8 1f             	cmp    $0x1f,%eax
801063c0:	76 0a                	jbe    801063cc <sys_exec+0x72>
      return -1;
801063c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c7:	e9 94 00 00 00       	jmp    80106460 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cf:	c1 e0 02             	shl    $0x2,%eax
801063d2:	89 c2                	mov    %eax,%edx
801063d4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063da:	01 c2                	add    %eax,%edx
801063dc:	83 ec 08             	sub    $0x8,%esp
801063df:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801063e5:	50                   	push   %eax
801063e6:	52                   	push   %edx
801063e7:	e8 ed f1 ff ff       	call   801055d9 <fetchint>
801063ec:	83 c4 10             	add    $0x10,%esp
801063ef:	85 c0                	test   %eax,%eax
801063f1:	79 07                	jns    801063fa <sys_exec+0xa0>
      return -1;
801063f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f8:	eb 66                	jmp    80106460 <sys_exec+0x106>
    if(uarg == 0){
801063fa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106400:	85 c0                	test   %eax,%eax
80106402:	75 27                	jne    8010642b <sys_exec+0xd1>
      argv[i] = 0;
80106404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106407:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010640e:	00 00 00 00 
      break;
80106412:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106416:	83 ec 08             	sub    $0x8,%esp
80106419:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010641f:	52                   	push   %edx
80106420:	50                   	push   %eax
80106421:	e8 64 a7 ff ff       	call   80100b8a <exec>
80106426:	83 c4 10             	add    $0x10,%esp
80106429:	eb 35                	jmp    80106460 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010642b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106431:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106434:	c1 e2 02             	shl    $0x2,%edx
80106437:	01 c2                	add    %eax,%edx
80106439:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010643f:	83 ec 08             	sub    $0x8,%esp
80106442:	52                   	push   %edx
80106443:	50                   	push   %eax
80106444:	e8 cf f1 ff ff       	call   80105618 <fetchstr>
80106449:	83 c4 10             	add    $0x10,%esp
8010644c:	85 c0                	test   %eax,%eax
8010644e:	79 07                	jns    80106457 <sys_exec+0xfd>
      return -1;
80106450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106455:	eb 09                	jmp    80106460 <sys_exec+0x106>
  for(i=0;; i++){
80106457:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010645b:	e9 5a ff ff ff       	jmp    801063ba <sys_exec+0x60>
}
80106460:	c9                   	leave
80106461:	c3                   	ret

80106462 <sys_pipe>:

int
sys_pipe(void)
{
80106462:	55                   	push   %ebp
80106463:	89 e5                	mov    %esp,%ebp
80106465:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106468:	83 ec 04             	sub    $0x4,%esp
8010646b:	6a 08                	push   $0x8
8010646d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106470:	50                   	push   %eax
80106471:	6a 00                	push   $0x0
80106473:	e8 2f f2 ff ff       	call   801056a7 <argptr>
80106478:	83 c4 10             	add    $0x10,%esp
8010647b:	85 c0                	test   %eax,%eax
8010647d:	79 0a                	jns    80106489 <sys_pipe+0x27>
    return -1;
8010647f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106484:	e9 ae 00 00 00       	jmp    80106537 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80106489:	83 ec 08             	sub    $0x8,%esp
8010648c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010648f:	50                   	push   %eax
80106490:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106493:	50                   	push   %eax
80106494:	e8 d4 d0 ff ff       	call   8010356d <pipealloc>
80106499:	83 c4 10             	add    $0x10,%esp
8010649c:	85 c0                	test   %eax,%eax
8010649e:	79 0a                	jns    801064aa <sys_pipe+0x48>
    return -1;
801064a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a5:	e9 8d 00 00 00       	jmp    80106537 <sys_pipe+0xd5>
  fd0 = -1;
801064aa:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064b4:	83 ec 0c             	sub    $0xc,%esp
801064b7:	50                   	push   %eax
801064b8:	e8 7b f3 ff ff       	call   80105838 <fdalloc>
801064bd:	83 c4 10             	add    $0x10,%esp
801064c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c7:	78 18                	js     801064e1 <sys_pipe+0x7f>
801064c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064cc:	83 ec 0c             	sub    $0xc,%esp
801064cf:	50                   	push   %eax
801064d0:	e8 63 f3 ff ff       	call   80105838 <fdalloc>
801064d5:	83 c4 10             	add    $0x10,%esp
801064d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064df:	79 3e                	jns    8010651f <sys_pipe+0xbd>
    if(fd0 >= 0)
801064e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064e5:	78 13                	js     801064fa <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801064e7:	e8 44 d5 ff ff       	call   80103a30 <myproc>
801064ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ef:	83 c2 08             	add    $0x8,%edx
801064f2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801064f9:	00 
    fileclose(rf);
801064fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064fd:	83 ec 0c             	sub    $0xc,%esp
80106500:	50                   	push   %eax
80106501:	e8 9f ab ff ff       	call   801010a5 <fileclose>
80106506:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106509:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010650c:	83 ec 0c             	sub    $0xc,%esp
8010650f:	50                   	push   %eax
80106510:	e8 90 ab ff ff       	call   801010a5 <fileclose>
80106515:	83 c4 10             	add    $0x10,%esp
    return -1;
80106518:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651d:	eb 18                	jmp    80106537 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010651f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106522:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106525:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106527:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010652a:	8d 50 04             	lea    0x4(%eax),%edx
8010652d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106530:	89 02                	mov    %eax,(%edx)
  return 0;
80106532:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106537:	c9                   	leave
80106538:	c3                   	ret

80106539 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
80106539:	55                   	push   %ebp
8010653a:	89 e5                	mov    %esp,%ebp
8010653c:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
8010653f:	83 ec 04             	sub    $0x4,%esp
80106542:	68 00 0c 00 00       	push   $0xc00
80106547:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010654a:	50                   	push   %eax
8010654b:	6a 00                	push   $0x0
8010654d:	e8 55 f1 ff ff       	call   801056a7 <argptr>
80106552:	83 c4 10             	add    $0x10,%esp
80106555:	85 c0                	test   %eax,%eax
80106557:	79 07                	jns    80106560 <sys_getpinfo+0x27>
    return -1;
80106559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655e:	eb 0f                	jmp    8010656f <sys_getpinfo+0x36>
  return getpinfo(ps);
80106560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106563:	83 ec 0c             	sub    $0xc,%esp
80106566:	50                   	push   %eax
80106567:	e8 bd e1 ff ff       	call   80104729 <getpinfo>
8010656c:	83 c4 10             	add    $0x10,%esp
}
8010656f:	c9                   	leave
80106570:	c3                   	ret

80106571 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
80106571:	55                   	push   %ebp
80106572:	89 e5                	mov    %esp,%ebp
80106574:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
80106577:	83 ec 08             	sub    $0x8,%esp
8010657a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010657d:	50                   	push   %eax
8010657e:	6a 00                	push   $0x0
80106580:	e8 f5 f0 ff ff       	call   8010567a <argint>
80106585:	83 c4 10             	add    $0x10,%esp
80106588:	85 c0                	test   %eax,%eax
8010658a:	79 07                	jns    80106593 <sys_setSchedPolicy+0x22>
    return -1;
8010658c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106591:	eb 23                	jmp    801065b6 <sys_setSchedPolicy+0x45>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106596:	83 ec 08             	sub    $0x8,%esp
80106599:	50                   	push   %eax
8010659a:	68 9c b0 10 80       	push   $0x8010b09c
8010659f:	e8 50 9e ff ff       	call   801003f4 <cprintf>
801065a4:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
801065a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065aa:	83 ec 0c             	sub    $0xc,%esp
801065ad:	50                   	push   %eax
801065ae:	e8 4a e3 ff ff       	call   801048fd <set_sched_policy>
801065b3:	83 c4 10             	add    $0x10,%esp
}
801065b6:	c9                   	leave
801065b7:	c3                   	ret

801065b8 <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
801065b8:	55                   	push   %ebp
801065b9:	89 e5                	mov    %esp,%ebp
801065bb:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
801065be:	e8 7d e3 ff ff       	call   80104940 <get_sched_policy>
}
801065c3:	c9                   	leave
801065c4:	c3                   	ret

801065c5 <sys_yield>:
int
sys_yield(void)
{
801065c5:	55                   	push   %ebp
801065c6:	89 e5                	mov    %esp,%ebp
801065c8:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
801065cb:	e8 3d de ff ff       	call   8010440d <yield>
  return 0;
801065d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065d5:	c9                   	leave
801065d6:	c3                   	ret

801065d7 <sys_fork>:

int
sys_fork(void)
{
801065d7:	55                   	push   %ebp
801065d8:	89 e5                	mov    %esp,%ebp
801065da:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065dd:	e8 ee d7 ff ff       	call   80103dd0 <fork>
}
801065e2:	c9                   	leave
801065e3:	c3                   	ret

801065e4 <sys_exit>:

int
sys_exit(void)
{
801065e4:	55                   	push   %ebp
801065e5:	89 e5                	mov    %esp,%ebp
801065e7:	83 ec 08             	sub    $0x8,%esp
  exit();
801065ea:	e8 b5 d9 ff ff       	call   80103fa4 <exit>
  return 0;  // not reached
801065ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f4:	c9                   	leave
801065f5:	c3                   	ret

801065f6 <sys_wait>:

int
sys_wait(void)
{
801065f6:	55                   	push   %ebp
801065f7:	89 e5                	mov    %esp,%ebp
801065f9:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065fc:	e8 e5 da ff ff       	call   801040e6 <wait>
}
80106601:	c9                   	leave
80106602:	c3                   	ret

80106603 <sys_kill>:

int
sys_kill(void)
{
80106603:	55                   	push   %ebp
80106604:	89 e5                	mov    %esp,%ebp
80106606:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106609:	83 ec 08             	sub    $0x8,%esp
8010660c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010660f:	50                   	push   %eax
80106610:	6a 00                	push   $0x0
80106612:	e8 63 f0 ff ff       	call   8010567a <argint>
80106617:	83 c4 10             	add    $0x10,%esp
8010661a:	85 c0                	test   %eax,%eax
8010661c:	79 07                	jns    80106625 <sys_kill+0x22>
    return -1;
8010661e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106623:	eb 0f                	jmp    80106634 <sys_kill+0x31>
  return kill(pid);
80106625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106628:	83 ec 0c             	sub    $0xc,%esp
8010662b:	50                   	push   %eax
8010662c:	e8 7a df ff ff       	call   801045ab <kill>
80106631:	83 c4 10             	add    $0x10,%esp
}
80106634:	c9                   	leave
80106635:	c3                   	ret

80106636 <sys_getpid>:

int
sys_getpid(void)
{
80106636:	55                   	push   %ebp
80106637:	89 e5                	mov    %esp,%ebp
80106639:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010663c:	e8 ef d3 ff ff       	call   80103a30 <myproc>
80106641:	8b 40 10             	mov    0x10(%eax),%eax
}
80106644:	c9                   	leave
80106645:	c3                   	ret

80106646 <sys_sbrk>:

int
sys_sbrk(void)
{
80106646:	55                   	push   %ebp
80106647:	89 e5                	mov    %esp,%ebp
80106649:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010664c:	83 ec 08             	sub    $0x8,%esp
8010664f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106652:	50                   	push   %eax
80106653:	6a 00                	push   $0x0
80106655:	e8 20 f0 ff ff       	call   8010567a <argint>
8010665a:	83 c4 10             	add    $0x10,%esp
8010665d:	85 c0                	test   %eax,%eax
8010665f:	79 07                	jns    80106668 <sys_sbrk+0x22>
    return -1;
80106661:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106666:	eb 27                	jmp    8010668f <sys_sbrk+0x49>
  addr = myproc()->sz;
80106668:	e8 c3 d3 ff ff       	call   80103a30 <myproc>
8010666d:	8b 00                	mov    (%eax),%eax
8010666f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106675:	83 ec 0c             	sub    $0xc,%esp
80106678:	50                   	push   %eax
80106679:	e8 b7 d6 ff ff       	call   80103d35 <growproc>
8010667e:	83 c4 10             	add    $0x10,%esp
80106681:	85 c0                	test   %eax,%eax
80106683:	79 07                	jns    8010668c <sys_sbrk+0x46>
    return -1;
80106685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668a:	eb 03                	jmp    8010668f <sys_sbrk+0x49>
  return addr;
8010668c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010668f:	c9                   	leave
80106690:	c3                   	ret

80106691 <sys_sleep>:

int
sys_sleep(void)
{
80106691:	55                   	push   %ebp
80106692:	89 e5                	mov    %esp,%ebp
80106694:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106697:	83 ec 08             	sub    $0x8,%esp
8010669a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010669d:	50                   	push   %eax
8010669e:	6a 00                	push   $0x0
801066a0:	e8 d5 ef ff ff       	call   8010567a <argint>
801066a5:	83 c4 10             	add    $0x10,%esp
801066a8:	85 c0                	test   %eax,%eax
801066aa:	79 07                	jns    801066b3 <sys_sleep+0x22>
    return -1;
801066ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b1:	eb 76                	jmp    80106729 <sys_sleep+0x98>
  acquire(&tickslock);
801066b3:	83 ec 0c             	sub    $0xc,%esp
801066b6:	68 80 79 19 80       	push   $0x80197980
801066bb:	e8 19 ea ff ff       	call   801050d9 <acquire>
801066c0:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801066c3:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801066c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801066cb:	eb 38                	jmp    80106705 <sys_sleep+0x74>
    if(myproc()->killed){
801066cd:	e8 5e d3 ff ff       	call   80103a30 <myproc>
801066d2:	8b 40 24             	mov    0x24(%eax),%eax
801066d5:	85 c0                	test   %eax,%eax
801066d7:	74 17                	je     801066f0 <sys_sleep+0x5f>
      release(&tickslock);
801066d9:	83 ec 0c             	sub    $0xc,%esp
801066dc:	68 80 79 19 80       	push   $0x80197980
801066e1:	e8 61 ea ff ff       	call   80105147 <release>
801066e6:	83 c4 10             	add    $0x10,%esp
      return -1;
801066e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ee:	eb 39                	jmp    80106729 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801066f0:	83 ec 08             	sub    $0x8,%esp
801066f3:	68 80 79 19 80       	push   $0x80197980
801066f8:	68 b4 79 19 80       	push   $0x801979b4
801066fd:	e8 8b dd ff ff       	call   8010448d <sleep>
80106702:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106705:	a1 b4 79 19 80       	mov    0x801979b4,%eax
8010670a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010670d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106710:	39 d0                	cmp    %edx,%eax
80106712:	72 b9                	jb     801066cd <sys_sleep+0x3c>
  }
  release(&tickslock);
80106714:	83 ec 0c             	sub    $0xc,%esp
80106717:	68 80 79 19 80       	push   $0x80197980
8010671c:	e8 26 ea ff ff       	call   80105147 <release>
80106721:	83 c4 10             	add    $0x10,%esp
  return 0;
80106724:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106729:	c9                   	leave
8010672a:	c3                   	ret

8010672b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106731:	83 ec 0c             	sub    $0xc,%esp
80106734:	68 80 79 19 80       	push   $0x80197980
80106739:	e8 9b e9 ff ff       	call   801050d9 <acquire>
8010673e:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106741:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106746:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106749:	83 ec 0c             	sub    $0xc,%esp
8010674c:	68 80 79 19 80       	push   $0x80197980
80106751:	e8 f1 e9 ff ff       	call   80105147 <release>
80106756:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106759:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010675c:	c9                   	leave
8010675d:	c3                   	ret

8010675e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010675e:	1e                   	push   %ds
  pushl %es
8010675f:	06                   	push   %es
  pushl %fs
80106760:	0f a0                	push   %fs
  pushl %gs
80106762:	0f a8                	push   %gs
  pushal
80106764:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106765:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106769:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010676b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010676d:	54                   	push   %esp
  call trap
8010676e:	e8 d7 01 00 00       	call   8010694a <trap>
  addl $4, %esp
80106773:	83 c4 04             	add    $0x4,%esp

80106776 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106776:	61                   	popa
  popl %gs
80106777:	0f a9                	pop    %gs
  popl %fs
80106779:	0f a1                	pop    %fs
  popl %es
8010677b:	07                   	pop    %es
  popl %ds
8010677c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010677d:	83 c4 08             	add    $0x8,%esp
  iret
80106780:	cf                   	iret

80106781 <lidt>:
{
80106781:	55                   	push   %ebp
80106782:	89 e5                	mov    %esp,%ebp
80106784:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106787:	8b 45 0c             	mov    0xc(%ebp),%eax
8010678a:	83 e8 01             	sub    $0x1,%eax
8010678d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106791:	8b 45 08             	mov    0x8(%ebp),%eax
80106794:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106798:	8b 45 08             	mov    0x8(%ebp),%eax
8010679b:	c1 e8 10             	shr    $0x10,%eax
8010679e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801067a2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067a5:	0f 01 18             	lidtl  (%eax)
}
801067a8:	90                   	nop
801067a9:	c9                   	leave
801067aa:	c3                   	ret

801067ab <rcr2>:

static inline uint
rcr2(void)
{
801067ab:	55                   	push   %ebp
801067ac:	89 e5                	mov    %esp,%ebp
801067ae:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067b1:	0f 20 d0             	mov    %cr2,%eax
801067b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067ba:	c9                   	leave
801067bb:	c3                   	ret

801067bc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067bc:	55                   	push   %ebp
801067bd:	89 e5                	mov    %esp,%ebp
801067bf:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801067c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067c9:	e9 c3 00 00 00       	jmp    80106891 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d1:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801067d8:	89 c2                	mov    %eax,%edx
801067da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067dd:	66 89 14 c5 80 71 19 	mov    %dx,-0x7fe68e80(,%eax,8)
801067e4:	80 
801067e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e8:	66 c7 04 c5 82 71 19 	movw   $0x8,-0x7fe68e7e(,%eax,8)
801067ef:	80 08 00 
801067f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f5:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
801067fc:	80 
801067fd:	83 e2 e0             	and    $0xffffffe0,%edx
80106800:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
80106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680a:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
80106811:	80 
80106812:	83 e2 1f             	and    $0x1f,%edx
80106815:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
8010681c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681f:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106826:	80 
80106827:	83 e2 f0             	and    $0xfffffff0,%edx
8010682a:	83 ca 0e             	or     $0xe,%edx
8010682d:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106837:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
8010683e:	80 
8010683f:	83 e2 ef             	and    $0xffffffef,%edx
80106842:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684c:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106853:	80 
80106854:	83 e2 9f             	and    $0xffffff9f,%edx
80106857:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
8010685e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106861:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106868:	80 
80106869:	83 ca 80             	or     $0xffffff80,%edx
8010686c:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106876:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
8010687d:	c1 e8 10             	shr    $0x10,%eax
80106880:	89 c2                	mov    %eax,%edx
80106882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106885:	66 89 14 c5 86 71 19 	mov    %dx,-0x7fe68e7a(,%eax,8)
8010688c:	80 
  for(i = 0; i < 256; i++)
8010688d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106891:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106898:	0f 8e 30 ff ff ff    	jle    801067ce <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010689e:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801068a3:	66 a3 80 73 19 80    	mov    %ax,0x80197380
801068a9:	66 c7 05 82 73 19 80 	movw   $0x8,0x80197382
801068b0:	08 00 
801068b2:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
801068b9:	83 e0 e0             	and    $0xffffffe0,%eax
801068bc:	a2 84 73 19 80       	mov    %al,0x80197384
801068c1:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
801068c8:	83 e0 1f             	and    $0x1f,%eax
801068cb:	a2 84 73 19 80       	mov    %al,0x80197384
801068d0:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801068d7:	83 c8 0f             	or     $0xf,%eax
801068da:	a2 85 73 19 80       	mov    %al,0x80197385
801068df:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801068e6:	83 e0 ef             	and    $0xffffffef,%eax
801068e9:	a2 85 73 19 80       	mov    %al,0x80197385
801068ee:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801068f5:	83 c8 60             	or     $0x60,%eax
801068f8:	a2 85 73 19 80       	mov    %al,0x80197385
801068fd:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106904:	83 c8 80             	or     $0xffffff80,%eax
80106907:	a2 85 73 19 80       	mov    %al,0x80197385
8010690c:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106911:	c1 e8 10             	shr    $0x10,%eax
80106914:	66 a3 86 73 19 80    	mov    %ax,0x80197386

  initlock(&tickslock, "time");
8010691a:	83 ec 08             	sub    $0x8,%esp
8010691d:	68 c8 b0 10 80       	push   $0x8010b0c8
80106922:	68 80 79 19 80       	push   $0x80197980
80106927:	e8 8b e7 ff ff       	call   801050b7 <initlock>
8010692c:	83 c4 10             	add    $0x10,%esp
}
8010692f:	90                   	nop
80106930:	c9                   	leave
80106931:	c3                   	ret

80106932 <idtinit>:

void
idtinit(void)
{
80106932:	55                   	push   %ebp
80106933:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106935:	68 00 08 00 00       	push   $0x800
8010693a:	68 80 71 19 80       	push   $0x80197180
8010693f:	e8 3d fe ff ff       	call   80106781 <lidt>
80106944:	83 c4 08             	add    $0x8,%esp
}
80106947:	90                   	nop
80106948:	c9                   	leave
80106949:	c3                   	ret

8010694a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010694a:	55                   	push   %ebp
8010694b:	89 e5                	mov    %esp,%ebp
8010694d:	57                   	push   %edi
8010694e:	56                   	push   %esi
8010694f:	53                   	push   %ebx
80106950:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106953:	8b 45 08             	mov    0x8(%ebp),%eax
80106956:	8b 40 30             	mov    0x30(%eax),%eax
80106959:	83 f8 40             	cmp    $0x40,%eax
8010695c:	75 3b                	jne    80106999 <trap+0x4f>
    if(myproc()->killed)
8010695e:	e8 cd d0 ff ff       	call   80103a30 <myproc>
80106963:	8b 40 24             	mov    0x24(%eax),%eax
80106966:	85 c0                	test   %eax,%eax
80106968:	74 05                	je     8010696f <trap+0x25>
      exit();
8010696a:	e8 35 d6 ff ff       	call   80103fa4 <exit>
    myproc()->tf = tf;
8010696f:	e8 bc d0 ff ff       	call   80103a30 <myproc>
80106974:	8b 55 08             	mov    0x8(%ebp),%edx
80106977:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010697a:	e8 c7 ed ff ff       	call   80105746 <syscall>
    if(myproc()->killed)
8010697f:	e8 ac d0 ff ff       	call   80103a30 <myproc>
80106984:	8b 40 24             	mov    0x24(%eax),%eax
80106987:	85 c0                	test   %eax,%eax
80106989:	0f 84 1f 03 00 00    	je     80106cae <trap+0x364>
      exit();
8010698f:	e8 10 d6 ff ff       	call   80103fa4 <exit>
    return;
80106994:	e9 15 03 00 00       	jmp    80106cae <trap+0x364>
  }

  switch(tf->trapno){
80106999:	8b 45 08             	mov    0x8(%ebp),%eax
8010699c:	8b 40 30             	mov    0x30(%eax),%eax
8010699f:	83 e8 20             	sub    $0x20,%eax
801069a2:	83 f8 1f             	cmp    $0x1f,%eax
801069a5:	0f 87 ce 01 00 00    	ja     80106b79 <trap+0x22f>
801069ab:	8b 04 85 9c b1 10 80 	mov    -0x7fef4e64(,%eax,4),%eax
801069b2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801069b4:	e8 e4 cf ff ff       	call   8010399d <cpuid>
801069b9:	85 c0                	test   %eax,%eax
801069bb:	75 3d                	jne    801069fa <trap+0xb0>
      acquire(&tickslock);
801069bd:	83 ec 0c             	sub    $0xc,%esp
801069c0:	68 80 79 19 80       	push   $0x80197980
801069c5:	e8 0f e7 ff ff       	call   801050d9 <acquire>
801069ca:	83 c4 10             	add    $0x10,%esp
      ticks++;
801069cd:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801069d2:	83 c0 01             	add    $0x1,%eax
801069d5:	a3 b4 79 19 80       	mov    %eax,0x801979b4
      wakeup(&ticks);
801069da:	83 ec 0c             	sub    $0xc,%esp
801069dd:	68 b4 79 19 80       	push   $0x801979b4
801069e2:	e8 8d db ff ff       	call   80104574 <wakeup>
801069e7:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801069ea:	83 ec 0c             	sub    $0xc,%esp
801069ed:	68 80 79 19 80       	push   $0x80197980
801069f2:	e8 50 e7 ff ff       	call   80105147 <release>
801069f7:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
801069fa:	e8 31 d0 ff ff       	call   80103a30 <myproc>
801069ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106a02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106a06:	0f 84 f8 00 00 00    	je     80106b04 <trap+0x1ba>
80106a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a0f:	8b 40 0c             	mov    0xc(%eax),%eax
80106a12:	83 f8 04             	cmp    $0x4,%eax
80106a15:	0f 85 e9 00 00 00    	jne    80106b04 <trap+0x1ba>
80106a1b:	e8 98 cf ff ff       	call   801039b8 <mycpu>
80106a20:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106a26:	85 c0                	test   %eax,%eax
80106a28:	0f 84 d6 00 00 00    	je     80106b04 <trap+0x1ba>
      int idx = myproc() - ptable.proc;
80106a2e:	e8 fd cf ff ff       	call   80103a30 <myproc>
80106a33:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80106a38:	c1 f8 02             	sar    $0x2,%eax
80106a3b:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106a41:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a47:	83 e8 80             	sub    $0xffffff80,%eax
80106a4a:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106a51:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a57:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106a5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a61:	01 d0                	add    %edx,%eax
80106a63:	05 00 01 00 00       	add    $0x100,%eax
80106a68:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106a6f:	8d 50 01             	lea    0x1(%eax),%edx
80106a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a75:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a7f:	01 c8                	add    %ecx,%eax
80106a81:	05 00 01 00 00       	add    $0x100,%eax
80106a86:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106a8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106a97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a9a:	01 d0                	add    %edx,%eax
80106a9c:	05 00 01 00 00       	add    $0x100,%eax
80106aa1:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106aa8:	83 f8 01             	cmp    $0x1,%eax
80106aab:	74 22                	je     80106acf <trap+0x185>
80106aad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ab0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106ab7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106aba:	01 d0                	add    %edx,%eax
80106abc:	05 00 01 00 00       	add    $0x100,%eax
80106ac1:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106ac8:	83 e0 07             	and    $0x7,%eax
80106acb:	85 c0                	test   %eax,%eax
80106acd:	75 35                	jne    80106b04 <trap+0x1ba>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106ad2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106ad9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106adc:	01 d0                	add    %edx,%eax
80106ade:	05 00 01 00 00       	add    $0x100,%eax
80106ae3:	8b 1c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106aea:	e8 41 cf ff ff       	call   80103a30 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106aef:	8b 40 10             	mov    0x10(%eax),%eax
80106af2:	53                   	push   %ebx
80106af3:	ff 75 dc             	push   -0x24(%ebp)
80106af6:	50                   	push   %eax
80106af7:	68 d0 b0 10 80       	push   $0x8010b0d0
80106afc:	e8 f3 98 ff ff       	call   801003f4 <cprintf>
80106b01:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106b04:	e8 15 c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106b09:	e9 20 01 00 00       	jmp    80106c2e <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b0e:	e8 da 3e 00 00       	call   8010a9ed <ideintr>
    lapiceoi();
80106b13:	e8 06 c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106b18:	e9 11 01 00 00       	jmp    80106c2e <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b1d:	e8 47 be ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106b22:	e8 f7 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106b27:	e9 02 01 00 00       	jmp    80106c2e <trap+0x2e4>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b2c:	e8 51 03 00 00       	call   80106e82 <uartintr>
    lapiceoi();
80106b31:	e8 e8 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106b36:	e9 f3 00 00 00       	jmp    80106c2e <trap+0x2e4>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106b3b:	e8 76 2b 00 00       	call   801096b6 <i8254_intr>
    lapiceoi();
80106b40:	e8 d9 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106b45:	e9 e4 00 00 00       	jmp    80106c2e <trap+0x2e4>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4d:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106b50:	8b 45 08             	mov    0x8(%ebp),%eax
80106b53:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b57:	0f b7 d8             	movzwl %ax,%ebx
80106b5a:	e8 3e ce ff ff       	call   8010399d <cpuid>
80106b5f:	56                   	push   %esi
80106b60:	53                   	push   %ebx
80106b61:	50                   	push   %eax
80106b62:	68 fc b0 10 80       	push   $0x8010b0fc
80106b67:	e8 88 98 ff ff       	call   801003f4 <cprintf>
80106b6c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106b6f:	e8 aa bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106b74:	e9 b5 00 00 00       	jmp    80106c2e <trap+0x2e4>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106b79:	e8 b2 ce ff ff       	call   80103a30 <myproc>
80106b7e:	85 c0                	test   %eax,%eax
80106b80:	74 11                	je     80106b93 <trap+0x249>
80106b82:	8b 45 08             	mov    0x8(%ebp),%eax
80106b85:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b89:	0f b7 c0             	movzwl %ax,%eax
80106b8c:	83 e0 03             	and    $0x3,%eax
80106b8f:	85 c0                	test   %eax,%eax
80106b91:	75 39                	jne    80106bcc <trap+0x282>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b93:	e8 13 fc ff ff       	call   801067ab <rcr2>
80106b98:	89 c3                	mov    %eax,%ebx
80106b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b9d:	8b 70 38             	mov    0x38(%eax),%esi
80106ba0:	e8 f8 cd ff ff       	call   8010399d <cpuid>
80106ba5:	8b 55 08             	mov    0x8(%ebp),%edx
80106ba8:	8b 52 30             	mov    0x30(%edx),%edx
80106bab:	83 ec 0c             	sub    $0xc,%esp
80106bae:	53                   	push   %ebx
80106baf:	56                   	push   %esi
80106bb0:	50                   	push   %eax
80106bb1:	52                   	push   %edx
80106bb2:	68 20 b1 10 80       	push   $0x8010b120
80106bb7:	e8 38 98 ff ff       	call   801003f4 <cprintf>
80106bbc:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106bbf:	83 ec 0c             	sub    $0xc,%esp
80106bc2:	68 52 b1 10 80       	push   $0x8010b152
80106bc7:	e8 dd 99 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bcc:	e8 da fb ff ff       	call   801067ab <rcr2>
80106bd1:	89 c6                	mov    %eax,%esi
80106bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80106bd6:	8b 40 38             	mov    0x38(%eax),%eax
80106bd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106bdc:	e8 bc cd ff ff       	call   8010399d <cpuid>
80106be1:	89 c3                	mov    %eax,%ebx
80106be3:	8b 45 08             	mov    0x8(%ebp),%eax
80106be6:	8b 48 34             	mov    0x34(%eax),%ecx
80106be9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106bec:	8b 45 08             	mov    0x8(%ebp),%eax
80106bef:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106bf2:	e8 39 ce ff ff       	call   80103a30 <myproc>
80106bf7:	8d 50 6c             	lea    0x6c(%eax),%edx
80106bfa:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106bfd:	e8 2e ce ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c02:	8b 40 10             	mov    0x10(%eax),%eax
80106c05:	56                   	push   %esi
80106c06:	ff 75 d4             	push   -0x2c(%ebp)
80106c09:	53                   	push   %ebx
80106c0a:	ff 75 d0             	push   -0x30(%ebp)
80106c0d:	57                   	push   %edi
80106c0e:	ff 75 cc             	push   -0x34(%ebp)
80106c11:	50                   	push   %eax
80106c12:	68 58 b1 10 80       	push   $0x8010b158
80106c17:	e8 d8 97 ff ff       	call   801003f4 <cprintf>
80106c1c:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106c1f:	e8 0c ce ff ff       	call   80103a30 <myproc>
80106c24:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106c2b:	eb 01                	jmp    80106c2e <trap+0x2e4>
    break;
80106c2d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106c2e:	e8 fd cd ff ff       	call   80103a30 <myproc>
80106c33:	85 c0                	test   %eax,%eax
80106c35:	74 23                	je     80106c5a <trap+0x310>
80106c37:	e8 f4 cd ff ff       	call   80103a30 <myproc>
80106c3c:	8b 40 24             	mov    0x24(%eax),%eax
80106c3f:	85 c0                	test   %eax,%eax
80106c41:	74 17                	je     80106c5a <trap+0x310>
80106c43:	8b 45 08             	mov    0x8(%ebp),%eax
80106c46:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c4a:	0f b7 c0             	movzwl %ax,%eax
80106c4d:	83 e0 03             	and    $0x3,%eax
80106c50:	83 f8 03             	cmp    $0x3,%eax
80106c53:	75 05                	jne    80106c5a <trap+0x310>
    exit();
80106c55:	e8 4a d3 ff ff       	call   80103fa4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106c5a:	e8 d1 cd ff ff       	call   80103a30 <myproc>
80106c5f:	85 c0                	test   %eax,%eax
80106c61:	74 1d                	je     80106c80 <trap+0x336>
80106c63:	e8 c8 cd ff ff       	call   80103a30 <myproc>
80106c68:	8b 40 0c             	mov    0xc(%eax),%eax
80106c6b:	83 f8 04             	cmp    $0x4,%eax
80106c6e:	75 10                	jne    80106c80 <trap+0x336>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106c70:	8b 45 08             	mov    0x8(%ebp),%eax
80106c73:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106c76:	83 f8 20             	cmp    $0x20,%eax
80106c79:	75 05                	jne    80106c80 <trap+0x336>
    yield();
80106c7b:	e8 8d d7 ff ff       	call   8010440d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106c80:	e8 ab cd ff ff       	call   80103a30 <myproc>
80106c85:	85 c0                	test   %eax,%eax
80106c87:	74 26                	je     80106caf <trap+0x365>
80106c89:	e8 a2 cd ff ff       	call   80103a30 <myproc>
80106c8e:	8b 40 24             	mov    0x24(%eax),%eax
80106c91:	85 c0                	test   %eax,%eax
80106c93:	74 1a                	je     80106caf <trap+0x365>
80106c95:	8b 45 08             	mov    0x8(%ebp),%eax
80106c98:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c9c:	0f b7 c0             	movzwl %ax,%eax
80106c9f:	83 e0 03             	and    $0x3,%eax
80106ca2:	83 f8 03             	cmp    $0x3,%eax
80106ca5:	75 08                	jne    80106caf <trap+0x365>
    exit();
80106ca7:	e8 f8 d2 ff ff       	call   80103fa4 <exit>
80106cac:	eb 01                	jmp    80106caf <trap+0x365>
    return;
80106cae:	90                   	nop
}
80106caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cb2:	5b                   	pop    %ebx
80106cb3:	5e                   	pop    %esi
80106cb4:	5f                   	pop    %edi
80106cb5:	5d                   	pop    %ebp
80106cb6:	c3                   	ret

80106cb7 <inb>:
{
80106cb7:	55                   	push   %ebp
80106cb8:	89 e5                	mov    %esp,%ebp
80106cba:	83 ec 14             	sub    $0x14,%esp
80106cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106cc4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106cc8:	89 c2                	mov    %eax,%edx
80106cca:	ec                   	in     (%dx),%al
80106ccb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106cce:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106cd2:	c9                   	leave
80106cd3:	c3                   	ret

80106cd4 <outb>:
{
80106cd4:	55                   	push   %ebp
80106cd5:	89 e5                	mov    %esp,%ebp
80106cd7:	83 ec 08             	sub    $0x8,%esp
80106cda:	8b 55 08             	mov    0x8(%ebp),%edx
80106cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ce0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106ce4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ce7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ceb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106cef:	ee                   	out    %al,(%dx)
}
80106cf0:	90                   	nop
80106cf1:	c9                   	leave
80106cf2:	c3                   	ret

80106cf3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106cf3:	55                   	push   %ebp
80106cf4:	89 e5                	mov    %esp,%ebp
80106cf6:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106cf9:	6a 00                	push   $0x0
80106cfb:	68 fa 03 00 00       	push   $0x3fa
80106d00:	e8 cf ff ff ff       	call   80106cd4 <outb>
80106d05:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d08:	68 80 00 00 00       	push   $0x80
80106d0d:	68 fb 03 00 00       	push   $0x3fb
80106d12:	e8 bd ff ff ff       	call   80106cd4 <outb>
80106d17:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106d1a:	6a 0c                	push   $0xc
80106d1c:	68 f8 03 00 00       	push   $0x3f8
80106d21:	e8 ae ff ff ff       	call   80106cd4 <outb>
80106d26:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106d29:	6a 00                	push   $0x0
80106d2b:	68 f9 03 00 00       	push   $0x3f9
80106d30:	e8 9f ff ff ff       	call   80106cd4 <outb>
80106d35:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d38:	6a 03                	push   $0x3
80106d3a:	68 fb 03 00 00       	push   $0x3fb
80106d3f:	e8 90 ff ff ff       	call   80106cd4 <outb>
80106d44:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106d47:	6a 00                	push   $0x0
80106d49:	68 fc 03 00 00       	push   $0x3fc
80106d4e:	e8 81 ff ff ff       	call   80106cd4 <outb>
80106d53:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d56:	6a 01                	push   $0x1
80106d58:	68 f9 03 00 00       	push   $0x3f9
80106d5d:	e8 72 ff ff ff       	call   80106cd4 <outb>
80106d62:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d65:	68 fd 03 00 00       	push   $0x3fd
80106d6a:	e8 48 ff ff ff       	call   80106cb7 <inb>
80106d6f:	83 c4 04             	add    $0x4,%esp
80106d72:	3c ff                	cmp    $0xff,%al
80106d74:	74 61                	je     80106dd7 <uartinit+0xe4>
    return;
  uart = 1;
80106d76:	c7 05 b8 79 19 80 01 	movl   $0x1,0x801979b8
80106d7d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d80:	68 fa 03 00 00       	push   $0x3fa
80106d85:	e8 2d ff ff ff       	call   80106cb7 <inb>
80106d8a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106d8d:	68 f8 03 00 00       	push   $0x3f8
80106d92:	e8 20 ff ff ff       	call   80106cb7 <inb>
80106d97:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106d9a:	83 ec 08             	sub    $0x8,%esp
80106d9d:	6a 00                	push   $0x0
80106d9f:	6a 04                	push   $0x4
80106da1:	e8 90 b8 ff ff       	call   80102636 <ioapicenable>
80106da6:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106da9:	c7 45 f4 1c b2 10 80 	movl   $0x8010b21c,-0xc(%ebp)
80106db0:	eb 19                	jmp    80106dcb <uartinit+0xd8>
    uartputc(*p);
80106db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db5:	0f b6 00             	movzbl (%eax),%eax
80106db8:	0f be c0             	movsbl %al,%eax
80106dbb:	83 ec 0c             	sub    $0xc,%esp
80106dbe:	50                   	push   %eax
80106dbf:	e8 16 00 00 00       	call   80106dda <uartputc>
80106dc4:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106dc7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dce:	0f b6 00             	movzbl (%eax),%eax
80106dd1:	84 c0                	test   %al,%al
80106dd3:	75 dd                	jne    80106db2 <uartinit+0xbf>
80106dd5:	eb 01                	jmp    80106dd8 <uartinit+0xe5>
    return;
80106dd7:	90                   	nop
}
80106dd8:	c9                   	leave
80106dd9:	c3                   	ret

80106dda <uartputc>:

void
uartputc(int c)
{
80106dda:	55                   	push   %ebp
80106ddb:	89 e5                	mov    %esp,%ebp
80106ddd:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106de0:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106de5:	85 c0                	test   %eax,%eax
80106de7:	74 53                	je     80106e3c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106de9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106df0:	eb 11                	jmp    80106e03 <uartputc+0x29>
    microdelay(10);
80106df2:	83 ec 0c             	sub    $0xc,%esp
80106df5:	6a 0a                	push   $0xa
80106df7:	e8 3d bd ff ff       	call   80102b39 <microdelay>
80106dfc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e03:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e07:	7f 1a                	jg     80106e23 <uartputc+0x49>
80106e09:	83 ec 0c             	sub    $0xc,%esp
80106e0c:	68 fd 03 00 00       	push   $0x3fd
80106e11:	e8 a1 fe ff ff       	call   80106cb7 <inb>
80106e16:	83 c4 10             	add    $0x10,%esp
80106e19:	0f b6 c0             	movzbl %al,%eax
80106e1c:	83 e0 20             	and    $0x20,%eax
80106e1f:	85 c0                	test   %eax,%eax
80106e21:	74 cf                	je     80106df2 <uartputc+0x18>
  outb(COM1+0, c);
80106e23:	8b 45 08             	mov    0x8(%ebp),%eax
80106e26:	0f b6 c0             	movzbl %al,%eax
80106e29:	83 ec 08             	sub    $0x8,%esp
80106e2c:	50                   	push   %eax
80106e2d:	68 f8 03 00 00       	push   $0x3f8
80106e32:	e8 9d fe ff ff       	call   80106cd4 <outb>
80106e37:	83 c4 10             	add    $0x10,%esp
80106e3a:	eb 01                	jmp    80106e3d <uartputc+0x63>
    return;
80106e3c:	90                   	nop
}
80106e3d:	c9                   	leave
80106e3e:	c3                   	ret

80106e3f <uartgetc>:

static int
uartgetc(void)
{
80106e3f:	55                   	push   %ebp
80106e40:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106e42:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106e47:	85 c0                	test   %eax,%eax
80106e49:	75 07                	jne    80106e52 <uartgetc+0x13>
    return -1;
80106e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e50:	eb 2e                	jmp    80106e80 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106e52:	68 fd 03 00 00       	push   $0x3fd
80106e57:	e8 5b fe ff ff       	call   80106cb7 <inb>
80106e5c:	83 c4 04             	add    $0x4,%esp
80106e5f:	0f b6 c0             	movzbl %al,%eax
80106e62:	83 e0 01             	and    $0x1,%eax
80106e65:	85 c0                	test   %eax,%eax
80106e67:	75 07                	jne    80106e70 <uartgetc+0x31>
    return -1;
80106e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e6e:	eb 10                	jmp    80106e80 <uartgetc+0x41>
  return inb(COM1+0);
80106e70:	68 f8 03 00 00       	push   $0x3f8
80106e75:	e8 3d fe ff ff       	call   80106cb7 <inb>
80106e7a:	83 c4 04             	add    $0x4,%esp
80106e7d:	0f b6 c0             	movzbl %al,%eax
}
80106e80:	c9                   	leave
80106e81:	c3                   	ret

80106e82 <uartintr>:

void
uartintr(void)
{
80106e82:	55                   	push   %ebp
80106e83:	89 e5                	mov    %esp,%ebp
80106e85:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106e88:	83 ec 0c             	sub    $0xc,%esp
80106e8b:	68 3f 6e 10 80       	push   $0x80106e3f
80106e90:	e8 41 99 ff ff       	call   801007d6 <consoleintr>
80106e95:	83 c4 10             	add    $0x10,%esp
}
80106e98:	90                   	nop
80106e99:	c9                   	leave
80106e9a:	c3                   	ret

80106e9b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $0
80106e9d:	6a 00                	push   $0x0
  jmp alltraps
80106e9f:	e9 ba f8 ff ff       	jmp    8010675e <alltraps>

80106ea4 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $1
80106ea6:	6a 01                	push   $0x1
  jmp alltraps
80106ea8:	e9 b1 f8 ff ff       	jmp    8010675e <alltraps>

80106ead <vector2>:
.globl vector2
vector2:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $2
80106eaf:	6a 02                	push   $0x2
  jmp alltraps
80106eb1:	e9 a8 f8 ff ff       	jmp    8010675e <alltraps>

80106eb6 <vector3>:
.globl vector3
vector3:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $3
80106eb8:	6a 03                	push   $0x3
  jmp alltraps
80106eba:	e9 9f f8 ff ff       	jmp    8010675e <alltraps>

80106ebf <vector4>:
.globl vector4
vector4:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $4
80106ec1:	6a 04                	push   $0x4
  jmp alltraps
80106ec3:	e9 96 f8 ff ff       	jmp    8010675e <alltraps>

80106ec8 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $5
80106eca:	6a 05                	push   $0x5
  jmp alltraps
80106ecc:	e9 8d f8 ff ff       	jmp    8010675e <alltraps>

80106ed1 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $6
80106ed3:	6a 06                	push   $0x6
  jmp alltraps
80106ed5:	e9 84 f8 ff ff       	jmp    8010675e <alltraps>

80106eda <vector7>:
.globl vector7
vector7:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $7
80106edc:	6a 07                	push   $0x7
  jmp alltraps
80106ede:	e9 7b f8 ff ff       	jmp    8010675e <alltraps>

80106ee3 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ee3:	6a 08                	push   $0x8
  jmp alltraps
80106ee5:	e9 74 f8 ff ff       	jmp    8010675e <alltraps>

80106eea <vector9>:
.globl vector9
vector9:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $9
80106eec:	6a 09                	push   $0x9
  jmp alltraps
80106eee:	e9 6b f8 ff ff       	jmp    8010675e <alltraps>

80106ef3 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ef3:	6a 0a                	push   $0xa
  jmp alltraps
80106ef5:	e9 64 f8 ff ff       	jmp    8010675e <alltraps>

80106efa <vector11>:
.globl vector11
vector11:
  pushl $11
80106efa:	6a 0b                	push   $0xb
  jmp alltraps
80106efc:	e9 5d f8 ff ff       	jmp    8010675e <alltraps>

80106f01 <vector12>:
.globl vector12
vector12:
  pushl $12
80106f01:	6a 0c                	push   $0xc
  jmp alltraps
80106f03:	e9 56 f8 ff ff       	jmp    8010675e <alltraps>

80106f08 <vector13>:
.globl vector13
vector13:
  pushl $13
80106f08:	6a 0d                	push   $0xd
  jmp alltraps
80106f0a:	e9 4f f8 ff ff       	jmp    8010675e <alltraps>

80106f0f <vector14>:
.globl vector14
vector14:
  pushl $14
80106f0f:	6a 0e                	push   $0xe
  jmp alltraps
80106f11:	e9 48 f8 ff ff       	jmp    8010675e <alltraps>

80106f16 <vector15>:
.globl vector15
vector15:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $15
80106f18:	6a 0f                	push   $0xf
  jmp alltraps
80106f1a:	e9 3f f8 ff ff       	jmp    8010675e <alltraps>

80106f1f <vector16>:
.globl vector16
vector16:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $16
80106f21:	6a 10                	push   $0x10
  jmp alltraps
80106f23:	e9 36 f8 ff ff       	jmp    8010675e <alltraps>

80106f28 <vector17>:
.globl vector17
vector17:
  pushl $17
80106f28:	6a 11                	push   $0x11
  jmp alltraps
80106f2a:	e9 2f f8 ff ff       	jmp    8010675e <alltraps>

80106f2f <vector18>:
.globl vector18
vector18:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $18
80106f31:	6a 12                	push   $0x12
  jmp alltraps
80106f33:	e9 26 f8 ff ff       	jmp    8010675e <alltraps>

80106f38 <vector19>:
.globl vector19
vector19:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $19
80106f3a:	6a 13                	push   $0x13
  jmp alltraps
80106f3c:	e9 1d f8 ff ff       	jmp    8010675e <alltraps>

80106f41 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $20
80106f43:	6a 14                	push   $0x14
  jmp alltraps
80106f45:	e9 14 f8 ff ff       	jmp    8010675e <alltraps>

80106f4a <vector21>:
.globl vector21
vector21:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $21
80106f4c:	6a 15                	push   $0x15
  jmp alltraps
80106f4e:	e9 0b f8 ff ff       	jmp    8010675e <alltraps>

80106f53 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $22
80106f55:	6a 16                	push   $0x16
  jmp alltraps
80106f57:	e9 02 f8 ff ff       	jmp    8010675e <alltraps>

80106f5c <vector23>:
.globl vector23
vector23:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $23
80106f5e:	6a 17                	push   $0x17
  jmp alltraps
80106f60:	e9 f9 f7 ff ff       	jmp    8010675e <alltraps>

80106f65 <vector24>:
.globl vector24
vector24:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $24
80106f67:	6a 18                	push   $0x18
  jmp alltraps
80106f69:	e9 f0 f7 ff ff       	jmp    8010675e <alltraps>

80106f6e <vector25>:
.globl vector25
vector25:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $25
80106f70:	6a 19                	push   $0x19
  jmp alltraps
80106f72:	e9 e7 f7 ff ff       	jmp    8010675e <alltraps>

80106f77 <vector26>:
.globl vector26
vector26:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $26
80106f79:	6a 1a                	push   $0x1a
  jmp alltraps
80106f7b:	e9 de f7 ff ff       	jmp    8010675e <alltraps>

80106f80 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $27
80106f82:	6a 1b                	push   $0x1b
  jmp alltraps
80106f84:	e9 d5 f7 ff ff       	jmp    8010675e <alltraps>

80106f89 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $28
80106f8b:	6a 1c                	push   $0x1c
  jmp alltraps
80106f8d:	e9 cc f7 ff ff       	jmp    8010675e <alltraps>

80106f92 <vector29>:
.globl vector29
vector29:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $29
80106f94:	6a 1d                	push   $0x1d
  jmp alltraps
80106f96:	e9 c3 f7 ff ff       	jmp    8010675e <alltraps>

80106f9b <vector30>:
.globl vector30
vector30:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $30
80106f9d:	6a 1e                	push   $0x1e
  jmp alltraps
80106f9f:	e9 ba f7 ff ff       	jmp    8010675e <alltraps>

80106fa4 <vector31>:
.globl vector31
vector31:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $31
80106fa6:	6a 1f                	push   $0x1f
  jmp alltraps
80106fa8:	e9 b1 f7 ff ff       	jmp    8010675e <alltraps>

80106fad <vector32>:
.globl vector32
vector32:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $32
80106faf:	6a 20                	push   $0x20
  jmp alltraps
80106fb1:	e9 a8 f7 ff ff       	jmp    8010675e <alltraps>

80106fb6 <vector33>:
.globl vector33
vector33:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $33
80106fb8:	6a 21                	push   $0x21
  jmp alltraps
80106fba:	e9 9f f7 ff ff       	jmp    8010675e <alltraps>

80106fbf <vector34>:
.globl vector34
vector34:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $34
80106fc1:	6a 22                	push   $0x22
  jmp alltraps
80106fc3:	e9 96 f7 ff ff       	jmp    8010675e <alltraps>

80106fc8 <vector35>:
.globl vector35
vector35:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $35
80106fca:	6a 23                	push   $0x23
  jmp alltraps
80106fcc:	e9 8d f7 ff ff       	jmp    8010675e <alltraps>

80106fd1 <vector36>:
.globl vector36
vector36:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $36
80106fd3:	6a 24                	push   $0x24
  jmp alltraps
80106fd5:	e9 84 f7 ff ff       	jmp    8010675e <alltraps>

80106fda <vector37>:
.globl vector37
vector37:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $37
80106fdc:	6a 25                	push   $0x25
  jmp alltraps
80106fde:	e9 7b f7 ff ff       	jmp    8010675e <alltraps>

80106fe3 <vector38>:
.globl vector38
vector38:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $38
80106fe5:	6a 26                	push   $0x26
  jmp alltraps
80106fe7:	e9 72 f7 ff ff       	jmp    8010675e <alltraps>

80106fec <vector39>:
.globl vector39
vector39:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $39
80106fee:	6a 27                	push   $0x27
  jmp alltraps
80106ff0:	e9 69 f7 ff ff       	jmp    8010675e <alltraps>

80106ff5 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $40
80106ff7:	6a 28                	push   $0x28
  jmp alltraps
80106ff9:	e9 60 f7 ff ff       	jmp    8010675e <alltraps>

80106ffe <vector41>:
.globl vector41
vector41:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $41
80107000:	6a 29                	push   $0x29
  jmp alltraps
80107002:	e9 57 f7 ff ff       	jmp    8010675e <alltraps>

80107007 <vector42>:
.globl vector42
vector42:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $42
80107009:	6a 2a                	push   $0x2a
  jmp alltraps
8010700b:	e9 4e f7 ff ff       	jmp    8010675e <alltraps>

80107010 <vector43>:
.globl vector43
vector43:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $43
80107012:	6a 2b                	push   $0x2b
  jmp alltraps
80107014:	e9 45 f7 ff ff       	jmp    8010675e <alltraps>

80107019 <vector44>:
.globl vector44
vector44:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $44
8010701b:	6a 2c                	push   $0x2c
  jmp alltraps
8010701d:	e9 3c f7 ff ff       	jmp    8010675e <alltraps>

80107022 <vector45>:
.globl vector45
vector45:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $45
80107024:	6a 2d                	push   $0x2d
  jmp alltraps
80107026:	e9 33 f7 ff ff       	jmp    8010675e <alltraps>

8010702b <vector46>:
.globl vector46
vector46:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $46
8010702d:	6a 2e                	push   $0x2e
  jmp alltraps
8010702f:	e9 2a f7 ff ff       	jmp    8010675e <alltraps>

80107034 <vector47>:
.globl vector47
vector47:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $47
80107036:	6a 2f                	push   $0x2f
  jmp alltraps
80107038:	e9 21 f7 ff ff       	jmp    8010675e <alltraps>

8010703d <vector48>:
.globl vector48
vector48:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $48
8010703f:	6a 30                	push   $0x30
  jmp alltraps
80107041:	e9 18 f7 ff ff       	jmp    8010675e <alltraps>

80107046 <vector49>:
.globl vector49
vector49:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $49
80107048:	6a 31                	push   $0x31
  jmp alltraps
8010704a:	e9 0f f7 ff ff       	jmp    8010675e <alltraps>

8010704f <vector50>:
.globl vector50
vector50:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $50
80107051:	6a 32                	push   $0x32
  jmp alltraps
80107053:	e9 06 f7 ff ff       	jmp    8010675e <alltraps>

80107058 <vector51>:
.globl vector51
vector51:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $51
8010705a:	6a 33                	push   $0x33
  jmp alltraps
8010705c:	e9 fd f6 ff ff       	jmp    8010675e <alltraps>

80107061 <vector52>:
.globl vector52
vector52:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $52
80107063:	6a 34                	push   $0x34
  jmp alltraps
80107065:	e9 f4 f6 ff ff       	jmp    8010675e <alltraps>

8010706a <vector53>:
.globl vector53
vector53:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $53
8010706c:	6a 35                	push   $0x35
  jmp alltraps
8010706e:	e9 eb f6 ff ff       	jmp    8010675e <alltraps>

80107073 <vector54>:
.globl vector54
vector54:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $54
80107075:	6a 36                	push   $0x36
  jmp alltraps
80107077:	e9 e2 f6 ff ff       	jmp    8010675e <alltraps>

8010707c <vector55>:
.globl vector55
vector55:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $55
8010707e:	6a 37                	push   $0x37
  jmp alltraps
80107080:	e9 d9 f6 ff ff       	jmp    8010675e <alltraps>

80107085 <vector56>:
.globl vector56
vector56:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $56
80107087:	6a 38                	push   $0x38
  jmp alltraps
80107089:	e9 d0 f6 ff ff       	jmp    8010675e <alltraps>

8010708e <vector57>:
.globl vector57
vector57:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $57
80107090:	6a 39                	push   $0x39
  jmp alltraps
80107092:	e9 c7 f6 ff ff       	jmp    8010675e <alltraps>

80107097 <vector58>:
.globl vector58
vector58:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $58
80107099:	6a 3a                	push   $0x3a
  jmp alltraps
8010709b:	e9 be f6 ff ff       	jmp    8010675e <alltraps>

801070a0 <vector59>:
.globl vector59
vector59:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $59
801070a2:	6a 3b                	push   $0x3b
  jmp alltraps
801070a4:	e9 b5 f6 ff ff       	jmp    8010675e <alltraps>

801070a9 <vector60>:
.globl vector60
vector60:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $60
801070ab:	6a 3c                	push   $0x3c
  jmp alltraps
801070ad:	e9 ac f6 ff ff       	jmp    8010675e <alltraps>

801070b2 <vector61>:
.globl vector61
vector61:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $61
801070b4:	6a 3d                	push   $0x3d
  jmp alltraps
801070b6:	e9 a3 f6 ff ff       	jmp    8010675e <alltraps>

801070bb <vector62>:
.globl vector62
vector62:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $62
801070bd:	6a 3e                	push   $0x3e
  jmp alltraps
801070bf:	e9 9a f6 ff ff       	jmp    8010675e <alltraps>

801070c4 <vector63>:
.globl vector63
vector63:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $63
801070c6:	6a 3f                	push   $0x3f
  jmp alltraps
801070c8:	e9 91 f6 ff ff       	jmp    8010675e <alltraps>

801070cd <vector64>:
.globl vector64
vector64:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $64
801070cf:	6a 40                	push   $0x40
  jmp alltraps
801070d1:	e9 88 f6 ff ff       	jmp    8010675e <alltraps>

801070d6 <vector65>:
.globl vector65
vector65:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $65
801070d8:	6a 41                	push   $0x41
  jmp alltraps
801070da:	e9 7f f6 ff ff       	jmp    8010675e <alltraps>

801070df <vector66>:
.globl vector66
vector66:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $66
801070e1:	6a 42                	push   $0x42
  jmp alltraps
801070e3:	e9 76 f6 ff ff       	jmp    8010675e <alltraps>

801070e8 <vector67>:
.globl vector67
vector67:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $67
801070ea:	6a 43                	push   $0x43
  jmp alltraps
801070ec:	e9 6d f6 ff ff       	jmp    8010675e <alltraps>

801070f1 <vector68>:
.globl vector68
vector68:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $68
801070f3:	6a 44                	push   $0x44
  jmp alltraps
801070f5:	e9 64 f6 ff ff       	jmp    8010675e <alltraps>

801070fa <vector69>:
.globl vector69
vector69:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $69
801070fc:	6a 45                	push   $0x45
  jmp alltraps
801070fe:	e9 5b f6 ff ff       	jmp    8010675e <alltraps>

80107103 <vector70>:
.globl vector70
vector70:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $70
80107105:	6a 46                	push   $0x46
  jmp alltraps
80107107:	e9 52 f6 ff ff       	jmp    8010675e <alltraps>

8010710c <vector71>:
.globl vector71
vector71:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $71
8010710e:	6a 47                	push   $0x47
  jmp alltraps
80107110:	e9 49 f6 ff ff       	jmp    8010675e <alltraps>

80107115 <vector72>:
.globl vector72
vector72:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $72
80107117:	6a 48                	push   $0x48
  jmp alltraps
80107119:	e9 40 f6 ff ff       	jmp    8010675e <alltraps>

8010711e <vector73>:
.globl vector73
vector73:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $73
80107120:	6a 49                	push   $0x49
  jmp alltraps
80107122:	e9 37 f6 ff ff       	jmp    8010675e <alltraps>

80107127 <vector74>:
.globl vector74
vector74:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $74
80107129:	6a 4a                	push   $0x4a
  jmp alltraps
8010712b:	e9 2e f6 ff ff       	jmp    8010675e <alltraps>

80107130 <vector75>:
.globl vector75
vector75:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $75
80107132:	6a 4b                	push   $0x4b
  jmp alltraps
80107134:	e9 25 f6 ff ff       	jmp    8010675e <alltraps>

80107139 <vector76>:
.globl vector76
vector76:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $76
8010713b:	6a 4c                	push   $0x4c
  jmp alltraps
8010713d:	e9 1c f6 ff ff       	jmp    8010675e <alltraps>

80107142 <vector77>:
.globl vector77
vector77:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $77
80107144:	6a 4d                	push   $0x4d
  jmp alltraps
80107146:	e9 13 f6 ff ff       	jmp    8010675e <alltraps>

8010714b <vector78>:
.globl vector78
vector78:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $78
8010714d:	6a 4e                	push   $0x4e
  jmp alltraps
8010714f:	e9 0a f6 ff ff       	jmp    8010675e <alltraps>

80107154 <vector79>:
.globl vector79
vector79:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $79
80107156:	6a 4f                	push   $0x4f
  jmp alltraps
80107158:	e9 01 f6 ff ff       	jmp    8010675e <alltraps>

8010715d <vector80>:
.globl vector80
vector80:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $80
8010715f:	6a 50                	push   $0x50
  jmp alltraps
80107161:	e9 f8 f5 ff ff       	jmp    8010675e <alltraps>

80107166 <vector81>:
.globl vector81
vector81:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $81
80107168:	6a 51                	push   $0x51
  jmp alltraps
8010716a:	e9 ef f5 ff ff       	jmp    8010675e <alltraps>

8010716f <vector82>:
.globl vector82
vector82:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $82
80107171:	6a 52                	push   $0x52
  jmp alltraps
80107173:	e9 e6 f5 ff ff       	jmp    8010675e <alltraps>

80107178 <vector83>:
.globl vector83
vector83:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $83
8010717a:	6a 53                	push   $0x53
  jmp alltraps
8010717c:	e9 dd f5 ff ff       	jmp    8010675e <alltraps>

80107181 <vector84>:
.globl vector84
vector84:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $84
80107183:	6a 54                	push   $0x54
  jmp alltraps
80107185:	e9 d4 f5 ff ff       	jmp    8010675e <alltraps>

8010718a <vector85>:
.globl vector85
vector85:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $85
8010718c:	6a 55                	push   $0x55
  jmp alltraps
8010718e:	e9 cb f5 ff ff       	jmp    8010675e <alltraps>

80107193 <vector86>:
.globl vector86
vector86:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $86
80107195:	6a 56                	push   $0x56
  jmp alltraps
80107197:	e9 c2 f5 ff ff       	jmp    8010675e <alltraps>

8010719c <vector87>:
.globl vector87
vector87:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $87
8010719e:	6a 57                	push   $0x57
  jmp alltraps
801071a0:	e9 b9 f5 ff ff       	jmp    8010675e <alltraps>

801071a5 <vector88>:
.globl vector88
vector88:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $88
801071a7:	6a 58                	push   $0x58
  jmp alltraps
801071a9:	e9 b0 f5 ff ff       	jmp    8010675e <alltraps>

801071ae <vector89>:
.globl vector89
vector89:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $89
801071b0:	6a 59                	push   $0x59
  jmp alltraps
801071b2:	e9 a7 f5 ff ff       	jmp    8010675e <alltraps>

801071b7 <vector90>:
.globl vector90
vector90:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $90
801071b9:	6a 5a                	push   $0x5a
  jmp alltraps
801071bb:	e9 9e f5 ff ff       	jmp    8010675e <alltraps>

801071c0 <vector91>:
.globl vector91
vector91:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $91
801071c2:	6a 5b                	push   $0x5b
  jmp alltraps
801071c4:	e9 95 f5 ff ff       	jmp    8010675e <alltraps>

801071c9 <vector92>:
.globl vector92
vector92:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $92
801071cb:	6a 5c                	push   $0x5c
  jmp alltraps
801071cd:	e9 8c f5 ff ff       	jmp    8010675e <alltraps>

801071d2 <vector93>:
.globl vector93
vector93:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $93
801071d4:	6a 5d                	push   $0x5d
  jmp alltraps
801071d6:	e9 83 f5 ff ff       	jmp    8010675e <alltraps>

801071db <vector94>:
.globl vector94
vector94:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $94
801071dd:	6a 5e                	push   $0x5e
  jmp alltraps
801071df:	e9 7a f5 ff ff       	jmp    8010675e <alltraps>

801071e4 <vector95>:
.globl vector95
vector95:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $95
801071e6:	6a 5f                	push   $0x5f
  jmp alltraps
801071e8:	e9 71 f5 ff ff       	jmp    8010675e <alltraps>

801071ed <vector96>:
.globl vector96
vector96:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $96
801071ef:	6a 60                	push   $0x60
  jmp alltraps
801071f1:	e9 68 f5 ff ff       	jmp    8010675e <alltraps>

801071f6 <vector97>:
.globl vector97
vector97:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $97
801071f8:	6a 61                	push   $0x61
  jmp alltraps
801071fa:	e9 5f f5 ff ff       	jmp    8010675e <alltraps>

801071ff <vector98>:
.globl vector98
vector98:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $98
80107201:	6a 62                	push   $0x62
  jmp alltraps
80107203:	e9 56 f5 ff ff       	jmp    8010675e <alltraps>

80107208 <vector99>:
.globl vector99
vector99:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $99
8010720a:	6a 63                	push   $0x63
  jmp alltraps
8010720c:	e9 4d f5 ff ff       	jmp    8010675e <alltraps>

80107211 <vector100>:
.globl vector100
vector100:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $100
80107213:	6a 64                	push   $0x64
  jmp alltraps
80107215:	e9 44 f5 ff ff       	jmp    8010675e <alltraps>

8010721a <vector101>:
.globl vector101
vector101:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $101
8010721c:	6a 65                	push   $0x65
  jmp alltraps
8010721e:	e9 3b f5 ff ff       	jmp    8010675e <alltraps>

80107223 <vector102>:
.globl vector102
vector102:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $102
80107225:	6a 66                	push   $0x66
  jmp alltraps
80107227:	e9 32 f5 ff ff       	jmp    8010675e <alltraps>

8010722c <vector103>:
.globl vector103
vector103:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $103
8010722e:	6a 67                	push   $0x67
  jmp alltraps
80107230:	e9 29 f5 ff ff       	jmp    8010675e <alltraps>

80107235 <vector104>:
.globl vector104
vector104:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $104
80107237:	6a 68                	push   $0x68
  jmp alltraps
80107239:	e9 20 f5 ff ff       	jmp    8010675e <alltraps>

8010723e <vector105>:
.globl vector105
vector105:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $105
80107240:	6a 69                	push   $0x69
  jmp alltraps
80107242:	e9 17 f5 ff ff       	jmp    8010675e <alltraps>

80107247 <vector106>:
.globl vector106
vector106:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $106
80107249:	6a 6a                	push   $0x6a
  jmp alltraps
8010724b:	e9 0e f5 ff ff       	jmp    8010675e <alltraps>

80107250 <vector107>:
.globl vector107
vector107:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $107
80107252:	6a 6b                	push   $0x6b
  jmp alltraps
80107254:	e9 05 f5 ff ff       	jmp    8010675e <alltraps>

80107259 <vector108>:
.globl vector108
vector108:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $108
8010725b:	6a 6c                	push   $0x6c
  jmp alltraps
8010725d:	e9 fc f4 ff ff       	jmp    8010675e <alltraps>

80107262 <vector109>:
.globl vector109
vector109:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $109
80107264:	6a 6d                	push   $0x6d
  jmp alltraps
80107266:	e9 f3 f4 ff ff       	jmp    8010675e <alltraps>

8010726b <vector110>:
.globl vector110
vector110:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $110
8010726d:	6a 6e                	push   $0x6e
  jmp alltraps
8010726f:	e9 ea f4 ff ff       	jmp    8010675e <alltraps>

80107274 <vector111>:
.globl vector111
vector111:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $111
80107276:	6a 6f                	push   $0x6f
  jmp alltraps
80107278:	e9 e1 f4 ff ff       	jmp    8010675e <alltraps>

8010727d <vector112>:
.globl vector112
vector112:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $112
8010727f:	6a 70                	push   $0x70
  jmp alltraps
80107281:	e9 d8 f4 ff ff       	jmp    8010675e <alltraps>

80107286 <vector113>:
.globl vector113
vector113:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $113
80107288:	6a 71                	push   $0x71
  jmp alltraps
8010728a:	e9 cf f4 ff ff       	jmp    8010675e <alltraps>

8010728f <vector114>:
.globl vector114
vector114:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $114
80107291:	6a 72                	push   $0x72
  jmp alltraps
80107293:	e9 c6 f4 ff ff       	jmp    8010675e <alltraps>

80107298 <vector115>:
.globl vector115
vector115:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $115
8010729a:	6a 73                	push   $0x73
  jmp alltraps
8010729c:	e9 bd f4 ff ff       	jmp    8010675e <alltraps>

801072a1 <vector116>:
.globl vector116
vector116:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $116
801072a3:	6a 74                	push   $0x74
  jmp alltraps
801072a5:	e9 b4 f4 ff ff       	jmp    8010675e <alltraps>

801072aa <vector117>:
.globl vector117
vector117:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $117
801072ac:	6a 75                	push   $0x75
  jmp alltraps
801072ae:	e9 ab f4 ff ff       	jmp    8010675e <alltraps>

801072b3 <vector118>:
.globl vector118
vector118:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $118
801072b5:	6a 76                	push   $0x76
  jmp alltraps
801072b7:	e9 a2 f4 ff ff       	jmp    8010675e <alltraps>

801072bc <vector119>:
.globl vector119
vector119:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $119
801072be:	6a 77                	push   $0x77
  jmp alltraps
801072c0:	e9 99 f4 ff ff       	jmp    8010675e <alltraps>

801072c5 <vector120>:
.globl vector120
vector120:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $120
801072c7:	6a 78                	push   $0x78
  jmp alltraps
801072c9:	e9 90 f4 ff ff       	jmp    8010675e <alltraps>

801072ce <vector121>:
.globl vector121
vector121:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $121
801072d0:	6a 79                	push   $0x79
  jmp alltraps
801072d2:	e9 87 f4 ff ff       	jmp    8010675e <alltraps>

801072d7 <vector122>:
.globl vector122
vector122:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $122
801072d9:	6a 7a                	push   $0x7a
  jmp alltraps
801072db:	e9 7e f4 ff ff       	jmp    8010675e <alltraps>

801072e0 <vector123>:
.globl vector123
vector123:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $123
801072e2:	6a 7b                	push   $0x7b
  jmp alltraps
801072e4:	e9 75 f4 ff ff       	jmp    8010675e <alltraps>

801072e9 <vector124>:
.globl vector124
vector124:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $124
801072eb:	6a 7c                	push   $0x7c
  jmp alltraps
801072ed:	e9 6c f4 ff ff       	jmp    8010675e <alltraps>

801072f2 <vector125>:
.globl vector125
vector125:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $125
801072f4:	6a 7d                	push   $0x7d
  jmp alltraps
801072f6:	e9 63 f4 ff ff       	jmp    8010675e <alltraps>

801072fb <vector126>:
.globl vector126
vector126:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $126
801072fd:	6a 7e                	push   $0x7e
  jmp alltraps
801072ff:	e9 5a f4 ff ff       	jmp    8010675e <alltraps>

80107304 <vector127>:
.globl vector127
vector127:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $127
80107306:	6a 7f                	push   $0x7f
  jmp alltraps
80107308:	e9 51 f4 ff ff       	jmp    8010675e <alltraps>

8010730d <vector128>:
.globl vector128
vector128:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $128
8010730f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107314:	e9 45 f4 ff ff       	jmp    8010675e <alltraps>

80107319 <vector129>:
.globl vector129
vector129:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $129
8010731b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107320:	e9 39 f4 ff ff       	jmp    8010675e <alltraps>

80107325 <vector130>:
.globl vector130
vector130:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $130
80107327:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010732c:	e9 2d f4 ff ff       	jmp    8010675e <alltraps>

80107331 <vector131>:
.globl vector131
vector131:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $131
80107333:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107338:	e9 21 f4 ff ff       	jmp    8010675e <alltraps>

8010733d <vector132>:
.globl vector132
vector132:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $132
8010733f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107344:	e9 15 f4 ff ff       	jmp    8010675e <alltraps>

80107349 <vector133>:
.globl vector133
vector133:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $133
8010734b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107350:	e9 09 f4 ff ff       	jmp    8010675e <alltraps>

80107355 <vector134>:
.globl vector134
vector134:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $134
80107357:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010735c:	e9 fd f3 ff ff       	jmp    8010675e <alltraps>

80107361 <vector135>:
.globl vector135
vector135:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $135
80107363:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107368:	e9 f1 f3 ff ff       	jmp    8010675e <alltraps>

8010736d <vector136>:
.globl vector136
vector136:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $136
8010736f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107374:	e9 e5 f3 ff ff       	jmp    8010675e <alltraps>

80107379 <vector137>:
.globl vector137
vector137:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $137
8010737b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107380:	e9 d9 f3 ff ff       	jmp    8010675e <alltraps>

80107385 <vector138>:
.globl vector138
vector138:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $138
80107387:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010738c:	e9 cd f3 ff ff       	jmp    8010675e <alltraps>

80107391 <vector139>:
.globl vector139
vector139:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $139
80107393:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107398:	e9 c1 f3 ff ff       	jmp    8010675e <alltraps>

8010739d <vector140>:
.globl vector140
vector140:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $140
8010739f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801073a4:	e9 b5 f3 ff ff       	jmp    8010675e <alltraps>

801073a9 <vector141>:
.globl vector141
vector141:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $141
801073ab:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801073b0:	e9 a9 f3 ff ff       	jmp    8010675e <alltraps>

801073b5 <vector142>:
.globl vector142
vector142:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $142
801073b7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801073bc:	e9 9d f3 ff ff       	jmp    8010675e <alltraps>

801073c1 <vector143>:
.globl vector143
vector143:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $143
801073c3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073c8:	e9 91 f3 ff ff       	jmp    8010675e <alltraps>

801073cd <vector144>:
.globl vector144
vector144:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $144
801073cf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073d4:	e9 85 f3 ff ff       	jmp    8010675e <alltraps>

801073d9 <vector145>:
.globl vector145
vector145:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $145
801073db:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801073e0:	e9 79 f3 ff ff       	jmp    8010675e <alltraps>

801073e5 <vector146>:
.globl vector146
vector146:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $146
801073e7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801073ec:	e9 6d f3 ff ff       	jmp    8010675e <alltraps>

801073f1 <vector147>:
.globl vector147
vector147:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $147
801073f3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073f8:	e9 61 f3 ff ff       	jmp    8010675e <alltraps>

801073fd <vector148>:
.globl vector148
vector148:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $148
801073ff:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107404:	e9 55 f3 ff ff       	jmp    8010675e <alltraps>

80107409 <vector149>:
.globl vector149
vector149:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $149
8010740b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107410:	e9 49 f3 ff ff       	jmp    8010675e <alltraps>

80107415 <vector150>:
.globl vector150
vector150:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $150
80107417:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010741c:	e9 3d f3 ff ff       	jmp    8010675e <alltraps>

80107421 <vector151>:
.globl vector151
vector151:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $151
80107423:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107428:	e9 31 f3 ff ff       	jmp    8010675e <alltraps>

8010742d <vector152>:
.globl vector152
vector152:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $152
8010742f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107434:	e9 25 f3 ff ff       	jmp    8010675e <alltraps>

80107439 <vector153>:
.globl vector153
vector153:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $153
8010743b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107440:	e9 19 f3 ff ff       	jmp    8010675e <alltraps>

80107445 <vector154>:
.globl vector154
vector154:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $154
80107447:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010744c:	e9 0d f3 ff ff       	jmp    8010675e <alltraps>

80107451 <vector155>:
.globl vector155
vector155:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $155
80107453:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107458:	e9 01 f3 ff ff       	jmp    8010675e <alltraps>

8010745d <vector156>:
.globl vector156
vector156:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $156
8010745f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107464:	e9 f5 f2 ff ff       	jmp    8010675e <alltraps>

80107469 <vector157>:
.globl vector157
vector157:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $157
8010746b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107470:	e9 e9 f2 ff ff       	jmp    8010675e <alltraps>

80107475 <vector158>:
.globl vector158
vector158:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $158
80107477:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010747c:	e9 dd f2 ff ff       	jmp    8010675e <alltraps>

80107481 <vector159>:
.globl vector159
vector159:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $159
80107483:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107488:	e9 d1 f2 ff ff       	jmp    8010675e <alltraps>

8010748d <vector160>:
.globl vector160
vector160:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $160
8010748f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107494:	e9 c5 f2 ff ff       	jmp    8010675e <alltraps>

80107499 <vector161>:
.globl vector161
vector161:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $161
8010749b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801074a0:	e9 b9 f2 ff ff       	jmp    8010675e <alltraps>

801074a5 <vector162>:
.globl vector162
vector162:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $162
801074a7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801074ac:	e9 ad f2 ff ff       	jmp    8010675e <alltraps>

801074b1 <vector163>:
.globl vector163
vector163:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $163
801074b3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801074b8:	e9 a1 f2 ff ff       	jmp    8010675e <alltraps>

801074bd <vector164>:
.globl vector164
vector164:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $164
801074bf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801074c4:	e9 95 f2 ff ff       	jmp    8010675e <alltraps>

801074c9 <vector165>:
.globl vector165
vector165:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $165
801074cb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074d0:	e9 89 f2 ff ff       	jmp    8010675e <alltraps>

801074d5 <vector166>:
.globl vector166
vector166:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $166
801074d7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801074dc:	e9 7d f2 ff ff       	jmp    8010675e <alltraps>

801074e1 <vector167>:
.globl vector167
vector167:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $167
801074e3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801074e8:	e9 71 f2 ff ff       	jmp    8010675e <alltraps>

801074ed <vector168>:
.globl vector168
vector168:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $168
801074ef:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074f4:	e9 65 f2 ff ff       	jmp    8010675e <alltraps>

801074f9 <vector169>:
.globl vector169
vector169:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $169
801074fb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107500:	e9 59 f2 ff ff       	jmp    8010675e <alltraps>

80107505 <vector170>:
.globl vector170
vector170:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $170
80107507:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010750c:	e9 4d f2 ff ff       	jmp    8010675e <alltraps>

80107511 <vector171>:
.globl vector171
vector171:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $171
80107513:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107518:	e9 41 f2 ff ff       	jmp    8010675e <alltraps>

8010751d <vector172>:
.globl vector172
vector172:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $172
8010751f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107524:	e9 35 f2 ff ff       	jmp    8010675e <alltraps>

80107529 <vector173>:
.globl vector173
vector173:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $173
8010752b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107530:	e9 29 f2 ff ff       	jmp    8010675e <alltraps>

80107535 <vector174>:
.globl vector174
vector174:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $174
80107537:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010753c:	e9 1d f2 ff ff       	jmp    8010675e <alltraps>

80107541 <vector175>:
.globl vector175
vector175:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $175
80107543:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107548:	e9 11 f2 ff ff       	jmp    8010675e <alltraps>

8010754d <vector176>:
.globl vector176
vector176:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $176
8010754f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107554:	e9 05 f2 ff ff       	jmp    8010675e <alltraps>

80107559 <vector177>:
.globl vector177
vector177:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $177
8010755b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107560:	e9 f9 f1 ff ff       	jmp    8010675e <alltraps>

80107565 <vector178>:
.globl vector178
vector178:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $178
80107567:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010756c:	e9 ed f1 ff ff       	jmp    8010675e <alltraps>

80107571 <vector179>:
.globl vector179
vector179:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $179
80107573:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107578:	e9 e1 f1 ff ff       	jmp    8010675e <alltraps>

8010757d <vector180>:
.globl vector180
vector180:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $180
8010757f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107584:	e9 d5 f1 ff ff       	jmp    8010675e <alltraps>

80107589 <vector181>:
.globl vector181
vector181:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $181
8010758b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107590:	e9 c9 f1 ff ff       	jmp    8010675e <alltraps>

80107595 <vector182>:
.globl vector182
vector182:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $182
80107597:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010759c:	e9 bd f1 ff ff       	jmp    8010675e <alltraps>

801075a1 <vector183>:
.globl vector183
vector183:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $183
801075a3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801075a8:	e9 b1 f1 ff ff       	jmp    8010675e <alltraps>

801075ad <vector184>:
.globl vector184
vector184:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $184
801075af:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801075b4:	e9 a5 f1 ff ff       	jmp    8010675e <alltraps>

801075b9 <vector185>:
.globl vector185
vector185:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $185
801075bb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801075c0:	e9 99 f1 ff ff       	jmp    8010675e <alltraps>

801075c5 <vector186>:
.globl vector186
vector186:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $186
801075c7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075cc:	e9 8d f1 ff ff       	jmp    8010675e <alltraps>

801075d1 <vector187>:
.globl vector187
vector187:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $187
801075d3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075d8:	e9 81 f1 ff ff       	jmp    8010675e <alltraps>

801075dd <vector188>:
.globl vector188
vector188:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $188
801075df:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801075e4:	e9 75 f1 ff ff       	jmp    8010675e <alltraps>

801075e9 <vector189>:
.globl vector189
vector189:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $189
801075eb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801075f0:	e9 69 f1 ff ff       	jmp    8010675e <alltraps>

801075f5 <vector190>:
.globl vector190
vector190:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $190
801075f7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075fc:	e9 5d f1 ff ff       	jmp    8010675e <alltraps>

80107601 <vector191>:
.globl vector191
vector191:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $191
80107603:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107608:	e9 51 f1 ff ff       	jmp    8010675e <alltraps>

8010760d <vector192>:
.globl vector192
vector192:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $192
8010760f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107614:	e9 45 f1 ff ff       	jmp    8010675e <alltraps>

80107619 <vector193>:
.globl vector193
vector193:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $193
8010761b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107620:	e9 39 f1 ff ff       	jmp    8010675e <alltraps>

80107625 <vector194>:
.globl vector194
vector194:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $194
80107627:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010762c:	e9 2d f1 ff ff       	jmp    8010675e <alltraps>

80107631 <vector195>:
.globl vector195
vector195:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $195
80107633:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107638:	e9 21 f1 ff ff       	jmp    8010675e <alltraps>

8010763d <vector196>:
.globl vector196
vector196:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $196
8010763f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107644:	e9 15 f1 ff ff       	jmp    8010675e <alltraps>

80107649 <vector197>:
.globl vector197
vector197:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $197
8010764b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107650:	e9 09 f1 ff ff       	jmp    8010675e <alltraps>

80107655 <vector198>:
.globl vector198
vector198:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $198
80107657:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010765c:	e9 fd f0 ff ff       	jmp    8010675e <alltraps>

80107661 <vector199>:
.globl vector199
vector199:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $199
80107663:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107668:	e9 f1 f0 ff ff       	jmp    8010675e <alltraps>

8010766d <vector200>:
.globl vector200
vector200:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $200
8010766f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107674:	e9 e5 f0 ff ff       	jmp    8010675e <alltraps>

80107679 <vector201>:
.globl vector201
vector201:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $201
8010767b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107680:	e9 d9 f0 ff ff       	jmp    8010675e <alltraps>

80107685 <vector202>:
.globl vector202
vector202:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $202
80107687:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010768c:	e9 cd f0 ff ff       	jmp    8010675e <alltraps>

80107691 <vector203>:
.globl vector203
vector203:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $203
80107693:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107698:	e9 c1 f0 ff ff       	jmp    8010675e <alltraps>

8010769d <vector204>:
.globl vector204
vector204:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $204
8010769f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801076a4:	e9 b5 f0 ff ff       	jmp    8010675e <alltraps>

801076a9 <vector205>:
.globl vector205
vector205:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $205
801076ab:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801076b0:	e9 a9 f0 ff ff       	jmp    8010675e <alltraps>

801076b5 <vector206>:
.globl vector206
vector206:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $206
801076b7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801076bc:	e9 9d f0 ff ff       	jmp    8010675e <alltraps>

801076c1 <vector207>:
.globl vector207
vector207:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $207
801076c3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076c8:	e9 91 f0 ff ff       	jmp    8010675e <alltraps>

801076cd <vector208>:
.globl vector208
vector208:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $208
801076cf:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076d4:	e9 85 f0 ff ff       	jmp    8010675e <alltraps>

801076d9 <vector209>:
.globl vector209
vector209:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $209
801076db:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801076e0:	e9 79 f0 ff ff       	jmp    8010675e <alltraps>

801076e5 <vector210>:
.globl vector210
vector210:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $210
801076e7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801076ec:	e9 6d f0 ff ff       	jmp    8010675e <alltraps>

801076f1 <vector211>:
.globl vector211
vector211:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $211
801076f3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076f8:	e9 61 f0 ff ff       	jmp    8010675e <alltraps>

801076fd <vector212>:
.globl vector212
vector212:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $212
801076ff:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107704:	e9 55 f0 ff ff       	jmp    8010675e <alltraps>

80107709 <vector213>:
.globl vector213
vector213:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $213
8010770b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107710:	e9 49 f0 ff ff       	jmp    8010675e <alltraps>

80107715 <vector214>:
.globl vector214
vector214:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $214
80107717:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010771c:	e9 3d f0 ff ff       	jmp    8010675e <alltraps>

80107721 <vector215>:
.globl vector215
vector215:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $215
80107723:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107728:	e9 31 f0 ff ff       	jmp    8010675e <alltraps>

8010772d <vector216>:
.globl vector216
vector216:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $216
8010772f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107734:	e9 25 f0 ff ff       	jmp    8010675e <alltraps>

80107739 <vector217>:
.globl vector217
vector217:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $217
8010773b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107740:	e9 19 f0 ff ff       	jmp    8010675e <alltraps>

80107745 <vector218>:
.globl vector218
vector218:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $218
80107747:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010774c:	e9 0d f0 ff ff       	jmp    8010675e <alltraps>

80107751 <vector219>:
.globl vector219
vector219:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $219
80107753:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107758:	e9 01 f0 ff ff       	jmp    8010675e <alltraps>

8010775d <vector220>:
.globl vector220
vector220:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $220
8010775f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107764:	e9 f5 ef ff ff       	jmp    8010675e <alltraps>

80107769 <vector221>:
.globl vector221
vector221:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $221
8010776b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107770:	e9 e9 ef ff ff       	jmp    8010675e <alltraps>

80107775 <vector222>:
.globl vector222
vector222:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $222
80107777:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010777c:	e9 dd ef ff ff       	jmp    8010675e <alltraps>

80107781 <vector223>:
.globl vector223
vector223:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $223
80107783:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107788:	e9 d1 ef ff ff       	jmp    8010675e <alltraps>

8010778d <vector224>:
.globl vector224
vector224:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $224
8010778f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107794:	e9 c5 ef ff ff       	jmp    8010675e <alltraps>

80107799 <vector225>:
.globl vector225
vector225:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $225
8010779b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801077a0:	e9 b9 ef ff ff       	jmp    8010675e <alltraps>

801077a5 <vector226>:
.globl vector226
vector226:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $226
801077a7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801077ac:	e9 ad ef ff ff       	jmp    8010675e <alltraps>

801077b1 <vector227>:
.globl vector227
vector227:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $227
801077b3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801077b8:	e9 a1 ef ff ff       	jmp    8010675e <alltraps>

801077bd <vector228>:
.globl vector228
vector228:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $228
801077bf:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801077c4:	e9 95 ef ff ff       	jmp    8010675e <alltraps>

801077c9 <vector229>:
.globl vector229
vector229:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $229
801077cb:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077d0:	e9 89 ef ff ff       	jmp    8010675e <alltraps>

801077d5 <vector230>:
.globl vector230
vector230:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $230
801077d7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801077dc:	e9 7d ef ff ff       	jmp    8010675e <alltraps>

801077e1 <vector231>:
.globl vector231
vector231:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $231
801077e3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801077e8:	e9 71 ef ff ff       	jmp    8010675e <alltraps>

801077ed <vector232>:
.globl vector232
vector232:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $232
801077ef:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077f4:	e9 65 ef ff ff       	jmp    8010675e <alltraps>

801077f9 <vector233>:
.globl vector233
vector233:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $233
801077fb:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107800:	e9 59 ef ff ff       	jmp    8010675e <alltraps>

80107805 <vector234>:
.globl vector234
vector234:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $234
80107807:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010780c:	e9 4d ef ff ff       	jmp    8010675e <alltraps>

80107811 <vector235>:
.globl vector235
vector235:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $235
80107813:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107818:	e9 41 ef ff ff       	jmp    8010675e <alltraps>

8010781d <vector236>:
.globl vector236
vector236:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $236
8010781f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107824:	e9 35 ef ff ff       	jmp    8010675e <alltraps>

80107829 <vector237>:
.globl vector237
vector237:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $237
8010782b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107830:	e9 29 ef ff ff       	jmp    8010675e <alltraps>

80107835 <vector238>:
.globl vector238
vector238:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $238
80107837:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010783c:	e9 1d ef ff ff       	jmp    8010675e <alltraps>

80107841 <vector239>:
.globl vector239
vector239:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $239
80107843:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107848:	e9 11 ef ff ff       	jmp    8010675e <alltraps>

8010784d <vector240>:
.globl vector240
vector240:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $240
8010784f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107854:	e9 05 ef ff ff       	jmp    8010675e <alltraps>

80107859 <vector241>:
.globl vector241
vector241:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $241
8010785b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107860:	e9 f9 ee ff ff       	jmp    8010675e <alltraps>

80107865 <vector242>:
.globl vector242
vector242:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $242
80107867:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010786c:	e9 ed ee ff ff       	jmp    8010675e <alltraps>

80107871 <vector243>:
.globl vector243
vector243:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $243
80107873:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107878:	e9 e1 ee ff ff       	jmp    8010675e <alltraps>

8010787d <vector244>:
.globl vector244
vector244:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $244
8010787f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107884:	e9 d5 ee ff ff       	jmp    8010675e <alltraps>

80107889 <vector245>:
.globl vector245
vector245:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $245
8010788b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107890:	e9 c9 ee ff ff       	jmp    8010675e <alltraps>

80107895 <vector246>:
.globl vector246
vector246:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $246
80107897:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010789c:	e9 bd ee ff ff       	jmp    8010675e <alltraps>

801078a1 <vector247>:
.globl vector247
vector247:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $247
801078a3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801078a8:	e9 b1 ee ff ff       	jmp    8010675e <alltraps>

801078ad <vector248>:
.globl vector248
vector248:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $248
801078af:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801078b4:	e9 a5 ee ff ff       	jmp    8010675e <alltraps>

801078b9 <vector249>:
.globl vector249
vector249:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $249
801078bb:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801078c0:	e9 99 ee ff ff       	jmp    8010675e <alltraps>

801078c5 <vector250>:
.globl vector250
vector250:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $250
801078c7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078cc:	e9 8d ee ff ff       	jmp    8010675e <alltraps>

801078d1 <vector251>:
.globl vector251
vector251:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $251
801078d3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078d8:	e9 81 ee ff ff       	jmp    8010675e <alltraps>

801078dd <vector252>:
.globl vector252
vector252:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $252
801078df:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801078e4:	e9 75 ee ff ff       	jmp    8010675e <alltraps>

801078e9 <vector253>:
.globl vector253
vector253:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $253
801078eb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801078f0:	e9 69 ee ff ff       	jmp    8010675e <alltraps>

801078f5 <vector254>:
.globl vector254
vector254:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $254
801078f7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078fc:	e9 5d ee ff ff       	jmp    8010675e <alltraps>

80107901 <vector255>:
.globl vector255
vector255:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $255
80107903:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107908:	e9 51 ee ff ff       	jmp    8010675e <alltraps>

8010790d <lgdt>:
{
8010790d:	55                   	push   %ebp
8010790e:	89 e5                	mov    %esp,%ebp
80107910:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107913:	8b 45 0c             	mov    0xc(%ebp),%eax
80107916:	83 e8 01             	sub    $0x1,%eax
80107919:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010791d:	8b 45 08             	mov    0x8(%ebp),%eax
80107920:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107924:	8b 45 08             	mov    0x8(%ebp),%eax
80107927:	c1 e8 10             	shr    $0x10,%eax
8010792a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010792e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107931:	0f 01 10             	lgdtl  (%eax)
}
80107934:	90                   	nop
80107935:	c9                   	leave
80107936:	c3                   	ret

80107937 <ltr>:
{
80107937:	55                   	push   %ebp
80107938:	89 e5                	mov    %esp,%ebp
8010793a:	83 ec 04             	sub    $0x4,%esp
8010793d:	8b 45 08             	mov    0x8(%ebp),%eax
80107940:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107944:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107948:	0f 00 d8             	ltr    %eax
}
8010794b:	90                   	nop
8010794c:	c9                   	leave
8010794d:	c3                   	ret

8010794e <lcr3>:

static inline void
lcr3(uint val)
{
8010794e:	55                   	push   %ebp
8010794f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107951:	8b 45 08             	mov    0x8(%ebp),%eax
80107954:	0f 22 d8             	mov    %eax,%cr3
}
80107957:	90                   	nop
80107958:	5d                   	pop    %ebp
80107959:	c3                   	ret

8010795a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010795a:	55                   	push   %ebp
8010795b:	89 e5                	mov    %esp,%ebp
8010795d:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107960:	e8 38 c0 ff ff       	call   8010399d <cpuid>
80107965:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010796b:	05 c0 79 19 80       	add    $0x801979c0,%eax
80107970:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107976:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107988:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010798c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107993:	83 e2 f0             	and    $0xfffffff0,%edx
80107996:	83 ca 0a             	or     $0xa,%edx
80107999:	88 50 7d             	mov    %dl,0x7d(%eax)
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079a3:	83 ca 10             	or     $0x10,%edx
801079a6:	88 50 7d             	mov    %dl,0x7d(%eax)
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079b0:	83 e2 9f             	and    $0xffffff9f,%edx
801079b3:	88 50 7d             	mov    %dl,0x7d(%eax)
801079b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079bd:	83 ca 80             	or     $0xffffff80,%edx
801079c0:	88 50 7d             	mov    %dl,0x7d(%eax)
801079c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079ca:	83 ca 0f             	or     $0xf,%edx
801079cd:	88 50 7e             	mov    %dl,0x7e(%eax)
801079d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079d7:	83 e2 ef             	and    $0xffffffef,%edx
801079da:	88 50 7e             	mov    %dl,0x7e(%eax)
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079e4:	83 e2 df             	and    $0xffffffdf,%edx
801079e7:	88 50 7e             	mov    %dl,0x7e(%eax)
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079f1:	83 ca 40             	or     $0x40,%edx
801079f4:	88 50 7e             	mov    %dl,0x7e(%eax)
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079fe:	83 ca 80             	or     $0xffffff80,%edx
80107a01:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a07:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107a15:	ff ff 
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a21:	00 00 
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a30:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a37:	83 e2 f0             	and    $0xfffffff0,%edx
80107a3a:	83 ca 02             	or     $0x2,%edx
80107a3d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a4d:	83 ca 10             	or     $0x10,%edx
80107a50:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a59:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a60:	83 e2 9f             	and    $0xffffff9f,%edx
80107a63:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a73:	83 ca 80             	or     $0xffffff80,%edx
80107a76:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a86:	83 ca 0f             	or     $0xf,%edx
80107a89:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a99:	83 e2 ef             	and    $0xffffffef,%edx
80107a9c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aac:	83 e2 df             	and    $0xffffffdf,%edx
80107aaf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107abf:	83 ca 40             	or     $0x40,%edx
80107ac2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ad2:	83 ca 80             	or     $0xffffff80,%edx
80107ad5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107aef:	ff ff 
80107af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af4:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107afb:	00 00 
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b11:	83 e2 f0             	and    $0xfffffff0,%edx
80107b14:	83 ca 0a             	or     $0xa,%edx
80107b17:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b20:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b27:	83 ca 10             	or     $0x10,%edx
80107b2a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b33:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b3a:	83 ca 60             	or     $0x60,%edx
80107b3d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b46:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b4d:	83 ca 80             	or     $0xffffff80,%edx
80107b50:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b59:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b60:	83 ca 0f             	or     $0xf,%edx
80107b63:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b73:	83 e2 ef             	and    $0xffffffef,%edx
80107b76:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b86:	83 e2 df             	and    $0xffffffdf,%edx
80107b89:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b92:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b99:	83 ca 40             	or     $0x40,%edx
80107b9c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bac:	83 ca 80             	or     $0xffffff80,%edx
80107baf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bc9:	ff ff 
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bd5:	00 00 
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107beb:	83 e2 f0             	and    $0xfffffff0,%edx
80107bee:	83 ca 02             	or     $0x2,%edx
80107bf1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c01:	83 ca 10             	or     $0x10,%edx
80107c04:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c14:	83 ca 60             	or     $0x60,%edx
80107c17:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c20:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c27:	83 ca 80             	or     $0xffffff80,%edx
80107c2a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c33:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c3a:	83 ca 0f             	or     $0xf,%edx
80107c3d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c46:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c4d:	83 e2 ef             	and    $0xffffffef,%edx
80107c50:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c59:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c60:	83 e2 df             	and    $0xffffffdf,%edx
80107c63:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c73:	83 ca 40             	or     $0x40,%edx
80107c76:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c86:	83 ca 80             	or     $0xffffff80,%edx
80107c89:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	83 c0 70             	add    $0x70,%eax
80107c9f:	83 ec 08             	sub    $0x8,%esp
80107ca2:	6a 30                	push   $0x30
80107ca4:	50                   	push   %eax
80107ca5:	e8 63 fc ff ff       	call   8010790d <lgdt>
80107caa:	83 c4 10             	add    $0x10,%esp
}
80107cad:	90                   	nop
80107cae:	c9                   	leave
80107caf:	c3                   	ret

80107cb0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107cb0:	55                   	push   %ebp
80107cb1:	89 e5                	mov    %esp,%ebp
80107cb3:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb9:	c1 e8 16             	shr    $0x16,%eax
80107cbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc6:	01 d0                	add    %edx,%eax
80107cc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cce:	8b 00                	mov    (%eax),%eax
80107cd0:	83 e0 01             	and    $0x1,%eax
80107cd3:	85 c0                	test   %eax,%eax
80107cd5:	74 14                	je     80107ceb <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cda:	8b 00                	mov    (%eax),%eax
80107cdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ce9:	eb 42                	jmp    80107d2d <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ceb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107cef:	74 0e                	je     80107cff <walkpgdir+0x4f>
80107cf1:	e8 b2 aa ff ff       	call   801027a8 <kalloc>
80107cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cfd:	75 07                	jne    80107d06 <walkpgdir+0x56>
      return 0;
80107cff:	b8 00 00 00 00       	mov    $0x0,%eax
80107d04:	eb 3e                	jmp    80107d44 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107d06:	83 ec 04             	sub    $0x4,%esp
80107d09:	68 00 10 00 00       	push   $0x1000
80107d0e:	6a 00                	push   $0x0
80107d10:	ff 75 f4             	push   -0xc(%ebp)
80107d13:	e8 37 d6 ff ff       	call   8010534f <memset>
80107d18:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1e:	05 00 00 00 80       	add    $0x80000000,%eax
80107d23:	83 c8 07             	or     $0x7,%eax
80107d26:	89 c2                	mov    %eax,%edx
80107d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d2b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d30:	c1 e8 0c             	shr    $0xc,%eax
80107d33:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	01 d0                	add    %edx,%eax
}
80107d44:	c9                   	leave
80107d45:	c3                   	ret

80107d46 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d46:	55                   	push   %ebp
80107d47:	89 e5                	mov    %esp,%ebp
80107d49:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d57:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d5a:	8b 45 10             	mov    0x10(%ebp),%eax
80107d5d:	01 d0                	add    %edx,%eax
80107d5f:	83 e8 01             	sub    $0x1,%eax
80107d62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d6a:	83 ec 04             	sub    $0x4,%esp
80107d6d:	6a 01                	push   $0x1
80107d6f:	ff 75 f4             	push   -0xc(%ebp)
80107d72:	ff 75 08             	push   0x8(%ebp)
80107d75:	e8 36 ff ff ff       	call   80107cb0 <walkpgdir>
80107d7a:	83 c4 10             	add    $0x10,%esp
80107d7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d84:	75 07                	jne    80107d8d <mappages+0x47>
      return -1;
80107d86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d8b:	eb 47                	jmp    80107dd4 <mappages+0x8e>
    if(*pte & PTE_P)
80107d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d90:	8b 00                	mov    (%eax),%eax
80107d92:	83 e0 01             	and    $0x1,%eax
80107d95:	85 c0                	test   %eax,%eax
80107d97:	74 0d                	je     80107da6 <mappages+0x60>
      panic("remap");
80107d99:	83 ec 0c             	sub    $0xc,%esp
80107d9c:	68 24 b2 10 80       	push   $0x8010b224
80107da1:	e8 03 88 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107da6:	8b 45 18             	mov    0x18(%ebp),%eax
80107da9:	0b 45 14             	or     0x14(%ebp),%eax
80107dac:	83 c8 01             	or     $0x1,%eax
80107daf:	89 c2                	mov    %eax,%edx
80107db1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107db4:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107dbc:	74 10                	je     80107dce <mappages+0x88>
      break;
    a += PGSIZE;
80107dbe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107dc5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107dcc:	eb 9c                	jmp    80107d6a <mappages+0x24>
      break;
80107dce:	90                   	nop
  }
  return 0;
80107dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dd4:	c9                   	leave
80107dd5:	c3                   	ret

80107dd6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107dd6:	55                   	push   %ebp
80107dd7:	89 e5                	mov    %esp,%ebp
80107dd9:	53                   	push   %ebx
80107dda:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107ddd:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107de4:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107de9:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107dee:	29 c2                	sub    %eax,%edx
80107df0:	89 d0                	mov    %edx,%eax
80107df2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107df5:	a1 7c 7a 19 80       	mov    0x80197a7c,%eax
80107dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107dfd:	8b 15 7c 7a 19 80    	mov    0x80197a7c,%edx
80107e03:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107e08:	01 d0                	add    %edx,%eax
80107e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107e0d:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e17:	83 c0 30             	add    $0x30,%eax
80107e1a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107e1d:	89 10                	mov    %edx,(%eax)
80107e1f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107e22:	89 50 04             	mov    %edx,0x4(%eax)
80107e25:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e28:	89 50 08             	mov    %edx,0x8(%eax)
80107e2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107e2e:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107e31:	e8 72 a9 ff ff       	call   801027a8 <kalloc>
80107e36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e3d:	75 07                	jne    80107e46 <setupkvm+0x70>
    return 0;
80107e3f:	b8 00 00 00 00       	mov    $0x0,%eax
80107e44:	eb 78                	jmp    80107ebe <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107e46:	83 ec 04             	sub    $0x4,%esp
80107e49:	68 00 10 00 00       	push   $0x1000
80107e4e:	6a 00                	push   $0x0
80107e50:	ff 75 f0             	push   -0x10(%ebp)
80107e53:	e8 f7 d4 ff ff       	call   8010534f <memset>
80107e58:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e5b:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107e62:	eb 4e                	jmp    80107eb2 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e67:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	8b 58 08             	mov    0x8(%eax),%ebx
80107e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e79:	8b 40 04             	mov    0x4(%eax),%eax
80107e7c:	29 c3                	sub    %eax,%ebx
80107e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e81:	8b 00                	mov    (%eax),%eax
80107e83:	83 ec 0c             	sub    $0xc,%esp
80107e86:	51                   	push   %ecx
80107e87:	52                   	push   %edx
80107e88:	53                   	push   %ebx
80107e89:	50                   	push   %eax
80107e8a:	ff 75 f0             	push   -0x10(%ebp)
80107e8d:	e8 b4 fe ff ff       	call   80107d46 <mappages>
80107e92:	83 c4 20             	add    $0x20,%esp
80107e95:	85 c0                	test   %eax,%eax
80107e97:	79 15                	jns    80107eae <setupkvm+0xd8>
      freevm(pgdir);
80107e99:	83 ec 0c             	sub    $0xc,%esp
80107e9c:	ff 75 f0             	push   -0x10(%ebp)
80107e9f:	e8 f5 04 00 00       	call   80108399 <freevm>
80107ea4:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ea7:	b8 00 00 00 00       	mov    $0x0,%eax
80107eac:	eb 10                	jmp    80107ebe <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107eae:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107eb2:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107eb9:	72 a9                	jb     80107e64 <setupkvm+0x8e>
    }
  return pgdir;
80107ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107ebe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ec1:	c9                   	leave
80107ec2:	c3                   	ret

80107ec3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107ec3:	55                   	push   %ebp
80107ec4:	89 e5                	mov    %esp,%ebp
80107ec6:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ec9:	e8 08 ff ff ff       	call   80107dd6 <setupkvm>
80107ece:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  switchkvm();
80107ed3:	e8 03 00 00 00       	call   80107edb <switchkvm>
}
80107ed8:	90                   	nop
80107ed9:	c9                   	leave
80107eda:	c3                   	ret

80107edb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107edb:	55                   	push   %ebp
80107edc:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ede:	a1 bc 79 19 80       	mov    0x801979bc,%eax
80107ee3:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee8:	50                   	push   %eax
80107ee9:	e8 60 fa ff ff       	call   8010794e <lcr3>
80107eee:	83 c4 04             	add    $0x4,%esp
}
80107ef1:	90                   	nop
80107ef2:	c9                   	leave
80107ef3:	c3                   	ret

80107ef4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ef4:	55                   	push   %ebp
80107ef5:	89 e5                	mov    %esp,%ebp
80107ef7:	56                   	push   %esi
80107ef8:	53                   	push   %ebx
80107ef9:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107efc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f00:	75 0d                	jne    80107f0f <switchuvm+0x1b>
    panic("switchuvm: no process");
80107f02:	83 ec 0c             	sub    $0xc,%esp
80107f05:	68 2a b2 10 80       	push   $0x8010b22a
80107f0a:	e8 9a 86 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f12:	8b 40 08             	mov    0x8(%eax),%eax
80107f15:	85 c0                	test   %eax,%eax
80107f17:	75 0d                	jne    80107f26 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107f19:	83 ec 0c             	sub    $0xc,%esp
80107f1c:	68 40 b2 10 80       	push   $0x8010b240
80107f21:	e8 83 86 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107f26:	8b 45 08             	mov    0x8(%ebp),%eax
80107f29:	8b 40 04             	mov    0x4(%eax),%eax
80107f2c:	85 c0                	test   %eax,%eax
80107f2e:	75 0d                	jne    80107f3d <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107f30:	83 ec 0c             	sub    $0xc,%esp
80107f33:	68 55 b2 10 80       	push   $0x8010b255
80107f38:	e8 6c 86 ff ff       	call   801005a9 <panic>

  pushcli();
80107f3d:	e8 02 d3 ff ff       	call   80105244 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107f42:	e8 71 ba ff ff       	call   801039b8 <mycpu>
80107f47:	89 c3                	mov    %eax,%ebx
80107f49:	e8 6a ba ff ff       	call   801039b8 <mycpu>
80107f4e:	83 c0 08             	add    $0x8,%eax
80107f51:	89 c6                	mov    %eax,%esi
80107f53:	e8 60 ba ff ff       	call   801039b8 <mycpu>
80107f58:	83 c0 08             	add    $0x8,%eax
80107f5b:	c1 e8 10             	shr    $0x10,%eax
80107f5e:	88 45 f7             	mov    %al,-0x9(%ebp)
80107f61:	e8 52 ba ff ff       	call   801039b8 <mycpu>
80107f66:	83 c0 08             	add    $0x8,%eax
80107f69:	c1 e8 18             	shr    $0x18,%eax
80107f6c:	89 c2                	mov    %eax,%edx
80107f6e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107f75:	67 00 
80107f77:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107f7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107f82:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107f88:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f8f:	83 e0 f0             	and    $0xfffffff0,%eax
80107f92:	83 c8 09             	or     $0x9,%eax
80107f95:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f9b:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fa2:	83 c8 10             	or     $0x10,%eax
80107fa5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107fab:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fb2:	83 e0 9f             	and    $0xffffff9f,%eax
80107fb5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107fbb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fc2:	83 c8 80             	or     $0xffffff80,%eax
80107fc5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107fcb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107fd2:	83 e0 f0             	and    $0xfffffff0,%eax
80107fd5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107fdb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107fe2:	83 e0 ef             	and    $0xffffffef,%eax
80107fe5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107feb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ff2:	83 e0 df             	and    $0xffffffdf,%eax
80107ff5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ffb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108002:	83 c8 40             	or     $0x40,%eax
80108005:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010800b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108012:	83 e0 7f             	and    $0x7f,%eax
80108015:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010801b:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108021:	e8 92 b9 ff ff       	call   801039b8 <mycpu>
80108026:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010802d:	83 e2 ef             	and    $0xffffffef,%edx
80108030:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108036:	e8 7d b9 ff ff       	call   801039b8 <mycpu>
8010803b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108041:	8b 45 08             	mov    0x8(%ebp),%eax
80108044:	8b 40 08             	mov    0x8(%eax),%eax
80108047:	89 c3                	mov    %eax,%ebx
80108049:	e8 6a b9 ff ff       	call   801039b8 <mycpu>
8010804e:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108054:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108057:	e8 5c b9 ff ff       	call   801039b8 <mycpu>
8010805c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108062:	83 ec 0c             	sub    $0xc,%esp
80108065:	6a 28                	push   $0x28
80108067:	e8 cb f8 ff ff       	call   80107937 <ltr>
8010806c:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010806f:	8b 45 08             	mov    0x8(%ebp),%eax
80108072:	8b 40 04             	mov    0x4(%eax),%eax
80108075:	05 00 00 00 80       	add    $0x80000000,%eax
8010807a:	83 ec 0c             	sub    $0xc,%esp
8010807d:	50                   	push   %eax
8010807e:	e8 cb f8 ff ff       	call   8010794e <lcr3>
80108083:	83 c4 10             	add    $0x10,%esp
  popcli();
80108086:	e8 06 d2 ff ff       	call   80105291 <popcli>
}
8010808b:	90                   	nop
8010808c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010808f:	5b                   	pop    %ebx
80108090:	5e                   	pop    %esi
80108091:	5d                   	pop    %ebp
80108092:	c3                   	ret

80108093 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108093:	55                   	push   %ebp
80108094:	89 e5                	mov    %esp,%ebp
80108096:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108099:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080a0:	76 0d                	jbe    801080af <inituvm+0x1c>
    panic("inituvm: more than a page");
801080a2:	83 ec 0c             	sub    $0xc,%esp
801080a5:	68 69 b2 10 80       	push   $0x8010b269
801080aa:	e8 fa 84 ff ff       	call   801005a9 <panic>
  mem = kalloc();
801080af:	e8 f4 a6 ff ff       	call   801027a8 <kalloc>
801080b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801080b7:	83 ec 04             	sub    $0x4,%esp
801080ba:	68 00 10 00 00       	push   $0x1000
801080bf:	6a 00                	push   $0x0
801080c1:	ff 75 f4             	push   -0xc(%ebp)
801080c4:	e8 86 d2 ff ff       	call   8010534f <memset>
801080c9:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801080cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cf:	05 00 00 00 80       	add    $0x80000000,%eax
801080d4:	83 ec 0c             	sub    $0xc,%esp
801080d7:	6a 06                	push   $0x6
801080d9:	50                   	push   %eax
801080da:	68 00 10 00 00       	push   $0x1000
801080df:	6a 00                	push   $0x0
801080e1:	ff 75 08             	push   0x8(%ebp)
801080e4:	e8 5d fc ff ff       	call   80107d46 <mappages>
801080e9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801080ec:	83 ec 04             	sub    $0x4,%esp
801080ef:	ff 75 10             	push   0x10(%ebp)
801080f2:	ff 75 0c             	push   0xc(%ebp)
801080f5:	ff 75 f4             	push   -0xc(%ebp)
801080f8:	e8 11 d3 ff ff       	call   8010540e <memmove>
801080fd:	83 c4 10             	add    $0x10,%esp
}
80108100:	90                   	nop
80108101:	c9                   	leave
80108102:	c3                   	ret

80108103 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108103:	55                   	push   %ebp
80108104:	89 e5                	mov    %esp,%ebp
80108106:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010810c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108111:	85 c0                	test   %eax,%eax
80108113:	74 0d                	je     80108122 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108115:	83 ec 0c             	sub    $0xc,%esp
80108118:	68 84 b2 10 80       	push   $0x8010b284
8010811d:	e8 87 84 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108122:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108129:	e9 8f 00 00 00       	jmp    801081bd <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010812e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108134:	01 d0                	add    %edx,%eax
80108136:	83 ec 04             	sub    $0x4,%esp
80108139:	6a 00                	push   $0x0
8010813b:	50                   	push   %eax
8010813c:	ff 75 08             	push   0x8(%ebp)
8010813f:	e8 6c fb ff ff       	call   80107cb0 <walkpgdir>
80108144:	83 c4 10             	add    $0x10,%esp
80108147:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010814a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010814e:	75 0d                	jne    8010815d <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108150:	83 ec 0c             	sub    $0xc,%esp
80108153:	68 a7 b2 10 80       	push   $0x8010b2a7
80108158:	e8 4c 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010815d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108160:	8b 00                	mov    (%eax),%eax
80108162:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108167:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010816a:	8b 45 18             	mov    0x18(%ebp),%eax
8010816d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108170:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108175:	77 0b                	ja     80108182 <loaduvm+0x7f>
      n = sz - i;
80108177:	8b 45 18             	mov    0x18(%ebp),%eax
8010817a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010817d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108180:	eb 07                	jmp    80108189 <loaduvm+0x86>
    else
      n = PGSIZE;
80108182:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108189:	8b 55 14             	mov    0x14(%ebp),%edx
8010818c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818f:	01 d0                	add    %edx,%eax
80108191:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108194:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010819a:	ff 75 f0             	push   -0x10(%ebp)
8010819d:	50                   	push   %eax
8010819e:	52                   	push   %edx
8010819f:	ff 75 10             	push   0x10(%ebp)
801081a2:	e8 37 9d ff ff       	call   80101ede <readi>
801081a7:	83 c4 10             	add    $0x10,%esp
801081aa:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801081ad:	74 07                	je     801081b6 <loaduvm+0xb3>
      return -1;
801081af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081b4:	eb 18                	jmp    801081ce <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801081b6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c0:	3b 45 18             	cmp    0x18(%ebp),%eax
801081c3:	0f 82 65 ff ff ff    	jb     8010812e <loaduvm+0x2b>
  }
  return 0;
801081c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081ce:	c9                   	leave
801081cf:	c3                   	ret

801081d0 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081d0:	55                   	push   %ebp
801081d1:	89 e5                	mov    %esp,%ebp
801081d3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801081d6:	8b 45 10             	mov    0x10(%ebp),%eax
801081d9:	85 c0                	test   %eax,%eax
801081db:	79 0a                	jns    801081e7 <allocuvm+0x17>
    return 0;
801081dd:	b8 00 00 00 00       	mov    $0x0,%eax
801081e2:	e9 ec 00 00 00       	jmp    801082d3 <allocuvm+0x103>
  if(newsz < oldsz)
801081e7:	8b 45 10             	mov    0x10(%ebp),%eax
801081ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081ed:	73 08                	jae    801081f7 <allocuvm+0x27>
    return oldsz;
801081ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f2:	e9 dc 00 00 00       	jmp    801082d3 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801081f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081fa:	05 ff 0f 00 00       	add    $0xfff,%eax
801081ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108207:	e9 b8 00 00 00       	jmp    801082c4 <allocuvm+0xf4>
    mem = kalloc();
8010820c:	e8 97 a5 ff ff       	call   801027a8 <kalloc>
80108211:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108214:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108218:	75 2e                	jne    80108248 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010821a:	83 ec 0c             	sub    $0xc,%esp
8010821d:	68 c5 b2 10 80       	push   $0x8010b2c5
80108222:	e8 cd 81 ff ff       	call   801003f4 <cprintf>
80108227:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010822a:	83 ec 04             	sub    $0x4,%esp
8010822d:	ff 75 0c             	push   0xc(%ebp)
80108230:	ff 75 10             	push   0x10(%ebp)
80108233:	ff 75 08             	push   0x8(%ebp)
80108236:	e8 9a 00 00 00       	call   801082d5 <deallocuvm>
8010823b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010823e:	b8 00 00 00 00       	mov    $0x0,%eax
80108243:	e9 8b 00 00 00       	jmp    801082d3 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108248:	83 ec 04             	sub    $0x4,%esp
8010824b:	68 00 10 00 00       	push   $0x1000
80108250:	6a 00                	push   $0x0
80108252:	ff 75 f0             	push   -0x10(%ebp)
80108255:	e8 f5 d0 ff ff       	call   8010534f <memset>
8010825a:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010825d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108260:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108269:	83 ec 0c             	sub    $0xc,%esp
8010826c:	6a 06                	push   $0x6
8010826e:	52                   	push   %edx
8010826f:	68 00 10 00 00       	push   $0x1000
80108274:	50                   	push   %eax
80108275:	ff 75 08             	push   0x8(%ebp)
80108278:	e8 c9 fa ff ff       	call   80107d46 <mappages>
8010827d:	83 c4 20             	add    $0x20,%esp
80108280:	85 c0                	test   %eax,%eax
80108282:	79 39                	jns    801082bd <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80108284:	83 ec 0c             	sub    $0xc,%esp
80108287:	68 dd b2 10 80       	push   $0x8010b2dd
8010828c:	e8 63 81 ff ff       	call   801003f4 <cprintf>
80108291:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108294:	83 ec 04             	sub    $0x4,%esp
80108297:	ff 75 0c             	push   0xc(%ebp)
8010829a:	ff 75 10             	push   0x10(%ebp)
8010829d:	ff 75 08             	push   0x8(%ebp)
801082a0:	e8 30 00 00 00       	call   801082d5 <deallocuvm>
801082a5:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801082a8:	83 ec 0c             	sub    $0xc,%esp
801082ab:	ff 75 f0             	push   -0x10(%ebp)
801082ae:	e8 5b a4 ff ff       	call   8010270e <kfree>
801082b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801082b6:	b8 00 00 00 00       	mov    $0x0,%eax
801082bb:	eb 16                	jmp    801082d3 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801082bd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801082ca:	0f 82 3c ff ff ff    	jb     8010820c <allocuvm+0x3c>
    }
  }
  return newsz;
801082d0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082d3:	c9                   	leave
801082d4:	c3                   	ret

801082d5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082d5:	55                   	push   %ebp
801082d6:	89 e5                	mov    %esp,%ebp
801082d8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801082db:	8b 45 10             	mov    0x10(%ebp),%eax
801082de:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082e1:	72 08                	jb     801082eb <deallocuvm+0x16>
    return oldsz;
801082e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e6:	e9 ac 00 00 00       	jmp    80108397 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801082eb:	8b 45 10             	mov    0x10(%ebp),%eax
801082ee:	05 ff 0f 00 00       	add    $0xfff,%eax
801082f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801082fb:	e9 88 00 00 00       	jmp    80108388 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108303:	83 ec 04             	sub    $0x4,%esp
80108306:	6a 00                	push   $0x0
80108308:	50                   	push   %eax
80108309:	ff 75 08             	push   0x8(%ebp)
8010830c:	e8 9f f9 ff ff       	call   80107cb0 <walkpgdir>
80108311:	83 c4 10             	add    $0x10,%esp
80108314:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108317:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010831b:	75 16                	jne    80108333 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010831d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108320:	c1 e8 16             	shr    $0x16,%eax
80108323:	83 c0 01             	add    $0x1,%eax
80108326:	c1 e0 16             	shl    $0x16,%eax
80108329:	2d 00 10 00 00       	sub    $0x1000,%eax
8010832e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108331:	eb 4e                	jmp    80108381 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108336:	8b 00                	mov    (%eax),%eax
80108338:	83 e0 01             	and    $0x1,%eax
8010833b:	85 c0                	test   %eax,%eax
8010833d:	74 42                	je     80108381 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010833f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108342:	8b 00                	mov    (%eax),%eax
80108344:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108349:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010834c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108350:	75 0d                	jne    8010835f <deallocuvm+0x8a>
        panic("kfree");
80108352:	83 ec 0c             	sub    $0xc,%esp
80108355:	68 f9 b2 10 80       	push   $0x8010b2f9
8010835a:	e8 4a 82 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010835f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108362:	05 00 00 00 80       	add    $0x80000000,%eax
80108367:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010836a:	83 ec 0c             	sub    $0xc,%esp
8010836d:	ff 75 e8             	push   -0x18(%ebp)
80108370:	e8 99 a3 ff ff       	call   8010270e <kfree>
80108375:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108381:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010838e:	0f 82 6c ff ff ff    	jb     80108300 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108394:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108397:	c9                   	leave
80108398:	c3                   	ret

80108399 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108399:	55                   	push   %ebp
8010839a:	89 e5                	mov    %esp,%ebp
8010839c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010839f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083a3:	75 0d                	jne    801083b2 <freevm+0x19>
    panic("freevm: no pgdir");
801083a5:	83 ec 0c             	sub    $0xc,%esp
801083a8:	68 ff b2 10 80       	push   $0x8010b2ff
801083ad:	e8 f7 81 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801083b2:	83 ec 04             	sub    $0x4,%esp
801083b5:	6a 00                	push   $0x0
801083b7:	68 00 00 00 80       	push   $0x80000000
801083bc:	ff 75 08             	push   0x8(%ebp)
801083bf:	e8 11 ff ff ff       	call   801082d5 <deallocuvm>
801083c4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801083c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ce:	eb 48                	jmp    80108418 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801083da:	8b 45 08             	mov    0x8(%ebp),%eax
801083dd:	01 d0                	add    %edx,%eax
801083df:	8b 00                	mov    (%eax),%eax
801083e1:	83 e0 01             	and    $0x1,%eax
801083e4:	85 c0                	test   %eax,%eax
801083e6:	74 2c                	je     80108414 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801083e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801083f2:	8b 45 08             	mov    0x8(%ebp),%eax
801083f5:	01 d0                	add    %edx,%eax
801083f7:	8b 00                	mov    (%eax),%eax
801083f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fe:	05 00 00 00 80       	add    $0x80000000,%eax
80108403:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108406:	83 ec 0c             	sub    $0xc,%esp
80108409:	ff 75 f0             	push   -0x10(%ebp)
8010840c:	e8 fd a2 ff ff       	call   8010270e <kfree>
80108411:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108414:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108418:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010841f:	76 af                	jbe    801083d0 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108421:	83 ec 0c             	sub    $0xc,%esp
80108424:	ff 75 08             	push   0x8(%ebp)
80108427:	e8 e2 a2 ff ff       	call   8010270e <kfree>
8010842c:	83 c4 10             	add    $0x10,%esp
}
8010842f:	90                   	nop
80108430:	c9                   	leave
80108431:	c3                   	ret

80108432 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108432:	55                   	push   %ebp
80108433:	89 e5                	mov    %esp,%ebp
80108435:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108438:	83 ec 04             	sub    $0x4,%esp
8010843b:	6a 00                	push   $0x0
8010843d:	ff 75 0c             	push   0xc(%ebp)
80108440:	ff 75 08             	push   0x8(%ebp)
80108443:	e8 68 f8 ff ff       	call   80107cb0 <walkpgdir>
80108448:	83 c4 10             	add    $0x10,%esp
8010844b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010844e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108452:	75 0d                	jne    80108461 <clearpteu+0x2f>
    panic("clearpteu");
80108454:	83 ec 0c             	sub    $0xc,%esp
80108457:	68 10 b3 10 80       	push   $0x8010b310
8010845c:	e8 48 81 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108464:	8b 00                	mov    (%eax),%eax
80108466:	83 e0 fb             	and    $0xfffffffb,%eax
80108469:	89 c2                	mov    %eax,%edx
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	89 10                	mov    %edx,(%eax)
}
80108470:	90                   	nop
80108471:	c9                   	leave
80108472:	c3                   	ret

80108473 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108473:	55                   	push   %ebp
80108474:	89 e5                	mov    %esp,%ebp
80108476:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108479:	e8 58 f9 ff ff       	call   80107dd6 <setupkvm>
8010847e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108481:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108485:	75 0a                	jne    80108491 <copyuvm+0x1e>
    return 0;
80108487:	b8 00 00 00 00       	mov    $0x0,%eax
8010848c:	e9 eb 00 00 00       	jmp    8010857c <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108498:	e9 b7 00 00 00       	jmp    80108554 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010849d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a0:	83 ec 04             	sub    $0x4,%esp
801084a3:	6a 00                	push   $0x0
801084a5:	50                   	push   %eax
801084a6:	ff 75 08             	push   0x8(%ebp)
801084a9:	e8 02 f8 ff ff       	call   80107cb0 <walkpgdir>
801084ae:	83 c4 10             	add    $0x10,%esp
801084b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084b8:	75 0d                	jne    801084c7 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801084ba:	83 ec 0c             	sub    $0xc,%esp
801084bd:	68 1a b3 10 80       	push   $0x8010b31a
801084c2:	e8 e2 80 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801084c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ca:	8b 00                	mov    (%eax),%eax
801084cc:	83 e0 01             	and    $0x1,%eax
801084cf:	85 c0                	test   %eax,%eax
801084d1:	75 0d                	jne    801084e0 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801084d3:	83 ec 0c             	sub    $0xc,%esp
801084d6:	68 34 b3 10 80       	push   $0x8010b334
801084db:	e8 c9 80 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801084e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084e3:	8b 00                	mov    (%eax),%eax
801084e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801084ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f0:	8b 00                	mov    (%eax),%eax
801084f2:	25 ff 0f 00 00       	and    $0xfff,%eax
801084f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801084fa:	e8 a9 a2 ff ff       	call   801027a8 <kalloc>
801084ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108502:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108506:	74 5d                	je     80108565 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108508:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010850b:	05 00 00 00 80       	add    $0x80000000,%eax
80108510:	83 ec 04             	sub    $0x4,%esp
80108513:	68 00 10 00 00       	push   $0x1000
80108518:	50                   	push   %eax
80108519:	ff 75 e0             	push   -0x20(%ebp)
8010851c:	e8 ed ce ff ff       	call   8010540e <memmove>
80108521:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108527:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010852a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108533:	83 ec 0c             	sub    $0xc,%esp
80108536:	52                   	push   %edx
80108537:	51                   	push   %ecx
80108538:	68 00 10 00 00       	push   $0x1000
8010853d:	50                   	push   %eax
8010853e:	ff 75 f0             	push   -0x10(%ebp)
80108541:	e8 00 f8 ff ff       	call   80107d46 <mappages>
80108546:	83 c4 20             	add    $0x20,%esp
80108549:	85 c0                	test   %eax,%eax
8010854b:	78 1b                	js     80108568 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
8010854d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010855a:	0f 82 3d ff ff ff    	jb     8010849d <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108563:	eb 17                	jmp    8010857c <copyuvm+0x109>
      goto bad;
80108565:	90                   	nop
80108566:	eb 01                	jmp    80108569 <copyuvm+0xf6>
      goto bad;
80108568:	90                   	nop

bad:
  freevm(d);
80108569:	83 ec 0c             	sub    $0xc,%esp
8010856c:	ff 75 f0             	push   -0x10(%ebp)
8010856f:	e8 25 fe ff ff       	call   80108399 <freevm>
80108574:	83 c4 10             	add    $0x10,%esp
  return 0;
80108577:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010857c:	c9                   	leave
8010857d:	c3                   	ret

8010857e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010857e:	55                   	push   %ebp
8010857f:	89 e5                	mov    %esp,%ebp
80108581:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108584:	83 ec 04             	sub    $0x4,%esp
80108587:	6a 00                	push   $0x0
80108589:	ff 75 0c             	push   0xc(%ebp)
8010858c:	ff 75 08             	push   0x8(%ebp)
8010858f:	e8 1c f7 ff ff       	call   80107cb0 <walkpgdir>
80108594:	83 c4 10             	add    $0x10,%esp
80108597:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010859a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859d:	8b 00                	mov    (%eax),%eax
8010859f:	83 e0 01             	and    $0x1,%eax
801085a2:	85 c0                	test   %eax,%eax
801085a4:	75 07                	jne    801085ad <uva2ka+0x2f>
    return 0;
801085a6:	b8 00 00 00 00       	mov    $0x0,%eax
801085ab:	eb 22                	jmp    801085cf <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801085ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b0:	8b 00                	mov    (%eax),%eax
801085b2:	83 e0 04             	and    $0x4,%eax
801085b5:	85 c0                	test   %eax,%eax
801085b7:	75 07                	jne    801085c0 <uva2ka+0x42>
    return 0;
801085b9:	b8 00 00 00 00       	mov    $0x0,%eax
801085be:	eb 0f                	jmp    801085cf <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	8b 00                	mov    (%eax),%eax
801085c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ca:	05 00 00 00 80       	add    $0x80000000,%eax
}
801085cf:	c9                   	leave
801085d0:	c3                   	ret

801085d1 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801085d1:	55                   	push   %ebp
801085d2:	89 e5                	mov    %esp,%ebp
801085d4:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801085d7:	8b 45 10             	mov    0x10(%ebp),%eax
801085da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801085dd:	eb 7f                	jmp    8010865e <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801085df:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801085ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ed:	83 ec 08             	sub    $0x8,%esp
801085f0:	50                   	push   %eax
801085f1:	ff 75 08             	push   0x8(%ebp)
801085f4:	e8 85 ff ff ff       	call   8010857e <uva2ka>
801085f9:	83 c4 10             	add    $0x10,%esp
801085fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108603:	75 07                	jne    8010860c <copyout+0x3b>
      return -1;
80108605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010860a:	eb 61                	jmp    8010866d <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010860c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860f:	2b 45 0c             	sub    0xc(%ebp),%eax
80108612:	05 00 10 00 00       	add    $0x1000,%eax
80108617:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010861a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861d:	39 45 14             	cmp    %eax,0x14(%ebp)
80108620:	73 06                	jae    80108628 <copyout+0x57>
      n = len;
80108622:	8b 45 14             	mov    0x14(%ebp),%eax
80108625:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108628:	8b 45 0c             	mov    0xc(%ebp),%eax
8010862b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010862e:	89 c2                	mov    %eax,%edx
80108630:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108633:	01 d0                	add    %edx,%eax
80108635:	83 ec 04             	sub    $0x4,%esp
80108638:	ff 75 f0             	push   -0x10(%ebp)
8010863b:	ff 75 f4             	push   -0xc(%ebp)
8010863e:	50                   	push   %eax
8010863f:	e8 ca cd ff ff       	call   8010540e <memmove>
80108644:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108647:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010864a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010864d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108650:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108653:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108656:	05 00 10 00 00       	add    $0x1000,%eax
8010865b:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010865e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108662:	0f 85 77 ff ff ff    	jne    801085df <copyout+0xe>
  }
  return 0;
80108668:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010866d:	c9                   	leave
8010866e:	c3                   	ret

8010866f <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010866f:	55                   	push   %ebp
80108670:	89 e5                	mov    %esp,%ebp
80108672:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108675:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010867c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010867f:	8b 40 08             	mov    0x8(%eax),%eax
80108682:	05 00 00 00 80       	add    $0x80000000,%eax
80108687:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010868a:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108694:	8b 40 24             	mov    0x24(%eax),%eax
80108697:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
8010869c:	c7 05 74 7a 19 80 00 	movl   $0x0,0x80197a74
801086a3:	00 00 00 

  while(i<madt->len){
801086a6:	e9 bc 00 00 00       	jmp    80108767 <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
801086ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086b1:	01 d0                	add    %edx,%eax
801086b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801086b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b9:	0f b6 00             	movzbl (%eax),%eax
801086bc:	0f b6 c0             	movzbl %al,%eax
801086bf:	83 f8 05             	cmp    $0x5,%eax
801086c2:	0f 87 9f 00 00 00    	ja     80108767 <mpinit_uefi+0xf8>
801086c8:	8b 04 85 50 b3 10 80 	mov    -0x7fef4cb0(,%eax,4),%eax
801086cf:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801086d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801086d7:	a1 74 7a 19 80       	mov    0x80197a74,%eax
801086dc:	85 c0                	test   %eax,%eax
801086de:	7f 28                	jg     80108708 <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801086e0:	8b 15 74 7a 19 80    	mov    0x80197a74,%edx
801086e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086e9:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801086ed:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801086f3:	81 c2 c0 79 19 80    	add    $0x801979c0,%edx
801086f9:	88 02                	mov    %al,(%edx)
          ncpu++;
801086fb:	a1 74 7a 19 80       	mov    0x80197a74,%eax
80108700:	83 c0 01             	add    $0x1,%eax
80108703:	a3 74 7a 19 80       	mov    %eax,0x80197a74
        }
        i += lapic_entry->record_len;
80108708:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010870b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010870f:	0f b6 c0             	movzbl %al,%eax
80108712:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108715:	eb 50                	jmp    80108767 <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010871d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108720:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108724:	a2 78 7a 19 80       	mov    %al,0x80197a78
        i += ioapic->record_len;
80108729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010872c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108730:	0f b6 c0             	movzbl %al,%eax
80108733:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108736:	eb 2f                	jmp    80108767 <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010873e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108741:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108745:	0f b6 c0             	movzbl %al,%eax
80108748:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010874b:	eb 1a                	jmp    80108767 <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010874d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108750:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108753:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108756:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010875a:	0f b6 c0             	movzbl %al,%eax
8010875d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108760:	eb 05                	jmp    80108767 <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
80108762:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108766:	90                   	nop
  while(i<madt->len){
80108767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876a:	8b 40 04             	mov    0x4(%eax),%eax
8010876d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108770:	0f 82 35 ff ff ff    	jb     801086ab <mpinit_uefi+0x3c>
    }
  }

}
80108776:	90                   	nop
80108777:	90                   	nop
80108778:	c9                   	leave
80108779:	c3                   	ret

8010877a <inb>:
{
8010877a:	55                   	push   %ebp
8010877b:	89 e5                	mov    %esp,%ebp
8010877d:	83 ec 14             	sub    $0x14,%esp
80108780:	8b 45 08             	mov    0x8(%ebp),%eax
80108783:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108787:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010878b:	89 c2                	mov    %eax,%edx
8010878d:	ec                   	in     (%dx),%al
8010878e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108791:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108795:	c9                   	leave
80108796:	c3                   	ret

80108797 <outb>:
{
80108797:	55                   	push   %ebp
80108798:	89 e5                	mov    %esp,%ebp
8010879a:	83 ec 08             	sub    $0x8,%esp
8010879d:	8b 55 08             	mov    0x8(%ebp),%edx
801087a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801087a3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801087a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801087aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801087ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801087b2:	ee                   	out    %al,(%dx)
}
801087b3:	90                   	nop
801087b4:	c9                   	leave
801087b5:	c3                   	ret

801087b6 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801087b6:	55                   	push   %ebp
801087b7:	89 e5                	mov    %esp,%ebp
801087b9:	83 ec 28             	sub    $0x28,%esp
801087bc:	8b 45 08             	mov    0x8(%ebp),%eax
801087bf:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801087c2:	6a 00                	push   $0x0
801087c4:	68 fa 03 00 00       	push   $0x3fa
801087c9:	e8 c9 ff ff ff       	call   80108797 <outb>
801087ce:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801087d1:	68 80 00 00 00       	push   $0x80
801087d6:	68 fb 03 00 00       	push   $0x3fb
801087db:	e8 b7 ff ff ff       	call   80108797 <outb>
801087e0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801087e3:	6a 0c                	push   $0xc
801087e5:	68 f8 03 00 00       	push   $0x3f8
801087ea:	e8 a8 ff ff ff       	call   80108797 <outb>
801087ef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801087f2:	6a 00                	push   $0x0
801087f4:	68 f9 03 00 00       	push   $0x3f9
801087f9:	e8 99 ff ff ff       	call   80108797 <outb>
801087fe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108801:	6a 03                	push   $0x3
80108803:	68 fb 03 00 00       	push   $0x3fb
80108808:	e8 8a ff ff ff       	call   80108797 <outb>
8010880d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108810:	6a 00                	push   $0x0
80108812:	68 fc 03 00 00       	push   $0x3fc
80108817:	e8 7b ff ff ff       	call   80108797 <outb>
8010881c:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010881f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108826:	eb 11                	jmp    80108839 <uart_debug+0x83>
80108828:	83 ec 0c             	sub    $0xc,%esp
8010882b:	6a 0a                	push   $0xa
8010882d:	e8 07 a3 ff ff       	call   80102b39 <microdelay>
80108832:	83 c4 10             	add    $0x10,%esp
80108835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108839:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010883d:	7f 1a                	jg     80108859 <uart_debug+0xa3>
8010883f:	83 ec 0c             	sub    $0xc,%esp
80108842:	68 fd 03 00 00       	push   $0x3fd
80108847:	e8 2e ff ff ff       	call   8010877a <inb>
8010884c:	83 c4 10             	add    $0x10,%esp
8010884f:	0f b6 c0             	movzbl %al,%eax
80108852:	83 e0 20             	and    $0x20,%eax
80108855:	85 c0                	test   %eax,%eax
80108857:	74 cf                	je     80108828 <uart_debug+0x72>
  outb(COM1+0, p);
80108859:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010885d:	0f b6 c0             	movzbl %al,%eax
80108860:	83 ec 08             	sub    $0x8,%esp
80108863:	50                   	push   %eax
80108864:	68 f8 03 00 00       	push   $0x3f8
80108869:	e8 29 ff ff ff       	call   80108797 <outb>
8010886e:	83 c4 10             	add    $0x10,%esp
}
80108871:	90                   	nop
80108872:	c9                   	leave
80108873:	c3                   	ret

80108874 <uart_debugs>:

void uart_debugs(char *p){
80108874:	55                   	push   %ebp
80108875:	89 e5                	mov    %esp,%ebp
80108877:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010887a:	eb 1b                	jmp    80108897 <uart_debugs+0x23>
    uart_debug(*p++);
8010887c:	8b 45 08             	mov    0x8(%ebp),%eax
8010887f:	8d 50 01             	lea    0x1(%eax),%edx
80108882:	89 55 08             	mov    %edx,0x8(%ebp)
80108885:	0f b6 00             	movzbl (%eax),%eax
80108888:	0f be c0             	movsbl %al,%eax
8010888b:	83 ec 0c             	sub    $0xc,%esp
8010888e:	50                   	push   %eax
8010888f:	e8 22 ff ff ff       	call   801087b6 <uart_debug>
80108894:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108897:	8b 45 08             	mov    0x8(%ebp),%eax
8010889a:	0f b6 00             	movzbl (%eax),%eax
8010889d:	84 c0                	test   %al,%al
8010889f:	75 db                	jne    8010887c <uart_debugs+0x8>
  }
}
801088a1:	90                   	nop
801088a2:	90                   	nop
801088a3:	c9                   	leave
801088a4:	c3                   	ret

801088a5 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801088a5:	55                   	push   %ebp
801088a6:	89 e5                	mov    %esp,%ebp
801088a8:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801088ab:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801088b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088b5:	8b 50 14             	mov    0x14(%eax),%edx
801088b8:	8b 40 10             	mov    0x10(%eax),%eax
801088bb:	a3 7c 7a 19 80       	mov    %eax,0x80197a7c
  gpu.vram_size = boot_param->graphic_config.frame_size;
801088c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088c3:	8b 50 1c             	mov    0x1c(%eax),%edx
801088c6:	8b 40 18             	mov    0x18(%eax),%eax
801088c9:	a3 84 7a 19 80       	mov    %eax,0x80197a84
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801088ce:	a1 84 7a 19 80       	mov    0x80197a84,%eax
801088d3:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801088d8:	29 c2                	sub    %eax,%edx
801088da:	89 15 80 7a 19 80    	mov    %edx,0x80197a80
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801088e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088e3:	8b 50 24             	mov    0x24(%eax),%edx
801088e6:	8b 40 20             	mov    0x20(%eax),%eax
801088e9:	a3 88 7a 19 80       	mov    %eax,0x80197a88
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801088ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088f1:	8b 50 2c             	mov    0x2c(%eax),%edx
801088f4:	8b 40 28             	mov    0x28(%eax),%eax
801088f7:	a3 8c 7a 19 80       	mov    %eax,0x80197a8c
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801088fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088ff:	8b 50 34             	mov    0x34(%eax),%edx
80108902:	8b 40 30             	mov    0x30(%eax),%eax
80108905:	a3 90 7a 19 80       	mov    %eax,0x80197a90
}
8010890a:	90                   	nop
8010890b:	c9                   	leave
8010890c:	c3                   	ret

8010890d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010890d:	55                   	push   %ebp
8010890e:	89 e5                	mov    %esp,%ebp
80108910:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108913:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
80108919:	8b 45 0c             	mov    0xc(%ebp),%eax
8010891c:	0f af d0             	imul   %eax,%edx
8010891f:	8b 45 08             	mov    0x8(%ebp),%eax
80108922:	01 d0                	add    %edx,%eax
80108924:	c1 e0 02             	shl    $0x2,%eax
80108927:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010892a:	8b 15 80 7a 19 80    	mov    0x80197a80,%edx
80108930:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108933:	01 d0                	add    %edx,%eax
80108935:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108938:	8b 45 10             	mov    0x10(%ebp),%eax
8010893b:	0f b6 10             	movzbl (%eax),%edx
8010893e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108941:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108943:	8b 45 10             	mov    0x10(%ebp),%eax
80108946:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010894a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010894d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108950:	8b 45 10             	mov    0x10(%ebp),%eax
80108953:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108957:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010895a:	88 50 02             	mov    %dl,0x2(%eax)
}
8010895d:	90                   	nop
8010895e:	c9                   	leave
8010895f:	c3                   	ret

80108960 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108960:	55                   	push   %ebp
80108961:	89 e5                	mov    %esp,%ebp
80108963:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108966:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
8010896c:	8b 45 08             	mov    0x8(%ebp),%eax
8010896f:	0f af c2             	imul   %edx,%eax
80108972:	c1 e0 02             	shl    $0x2,%eax
80108975:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108978:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
8010897e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108981:	29 c2                	sub    %eax,%edx
80108983:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
80108989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898c:	01 c8                	add    %ecx,%eax
8010898e:	89 c1                	mov    %eax,%ecx
80108990:	a1 80 7a 19 80       	mov    0x80197a80,%eax
80108995:	83 ec 04             	sub    $0x4,%esp
80108998:	52                   	push   %edx
80108999:	51                   	push   %ecx
8010899a:	50                   	push   %eax
8010899b:	e8 6e ca ff ff       	call   8010540e <memmove>
801089a0:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
801089ac:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
801089b2:	01 d1                	add    %edx,%ecx
801089b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089b7:	29 d1                	sub    %edx,%ecx
801089b9:	89 ca                	mov    %ecx,%edx
801089bb:	83 ec 04             	sub    $0x4,%esp
801089be:	50                   	push   %eax
801089bf:	6a 00                	push   $0x0
801089c1:	52                   	push   %edx
801089c2:	e8 88 c9 ff ff       	call   8010534f <memset>
801089c7:	83 c4 10             	add    $0x10,%esp
}
801089ca:	90                   	nop
801089cb:	c9                   	leave
801089cc:	c3                   	ret

801089cd <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801089cd:	55                   	push   %ebp
801089ce:	89 e5                	mov    %esp,%ebp
801089d0:	53                   	push   %ebx
801089d1:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801089d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089db:	e9 b1 00 00 00       	jmp    80108a91 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801089e0:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801089e7:	e9 97 00 00 00       	jmp    80108a83 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801089ec:	8b 45 10             	mov    0x10(%ebp),%eax
801089ef:	83 e8 20             	sub    $0x20,%eax
801089f2:	6b d0 1e             	imul   $0x1e,%eax,%edx
801089f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f8:	01 d0                	add    %edx,%eax
801089fa:	0f b7 84 00 80 b3 10 	movzwl -0x7fef4c80(%eax,%eax,1),%eax
80108a01:	80 
80108a02:	0f b7 d0             	movzwl %ax,%edx
80108a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a08:	bb 01 00 00 00       	mov    $0x1,%ebx
80108a0d:	89 c1                	mov    %eax,%ecx
80108a0f:	d3 e3                	shl    %cl,%ebx
80108a11:	89 d8                	mov    %ebx,%eax
80108a13:	21 d0                	and    %edx,%eax
80108a15:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a1b:	ba 01 00 00 00       	mov    $0x1,%edx
80108a20:	89 c1                	mov    %eax,%ecx
80108a22:	d3 e2                	shl    %cl,%edx
80108a24:	89 d0                	mov    %edx,%eax
80108a26:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108a29:	75 2b                	jne    80108a56 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a31:	01 c2                	add    %eax,%edx
80108a33:	b8 0e 00 00 00       	mov    $0xe,%eax
80108a38:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108a3b:	89 c1                	mov    %eax,%ecx
80108a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a40:	01 c8                	add    %ecx,%eax
80108a42:	83 ec 04             	sub    $0x4,%esp
80108a45:	68 00 f5 10 80       	push   $0x8010f500
80108a4a:	52                   	push   %edx
80108a4b:	50                   	push   %eax
80108a4c:	e8 bc fe ff ff       	call   8010890d <graphic_draw_pixel>
80108a51:	83 c4 10             	add    $0x10,%esp
80108a54:	eb 29                	jmp    80108a7f <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108a56:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5c:	01 c2                	add    %eax,%edx
80108a5e:	b8 0e 00 00 00       	mov    $0xe,%eax
80108a63:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108a66:	89 c1                	mov    %eax,%ecx
80108a68:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6b:	01 c8                	add    %ecx,%eax
80108a6d:	83 ec 04             	sub    $0x4,%esp
80108a70:	68 94 7a 19 80       	push   $0x80197a94
80108a75:	52                   	push   %edx
80108a76:	50                   	push   %eax
80108a77:	e8 91 fe ff ff       	call   8010890d <graphic_draw_pixel>
80108a7c:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108a7f:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a87:	0f 89 5f ff ff ff    	jns    801089ec <font_render+0x1f>
  for(int i=0;i<30;i++){
80108a8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a91:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108a95:	0f 8e 45 ff ff ff    	jle    801089e0 <font_render+0x13>
      }
    }
  }
}
80108a9b:	90                   	nop
80108a9c:	90                   	nop
80108a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108aa0:	c9                   	leave
80108aa1:	c3                   	ret

80108aa2 <font_render_string>:

void font_render_string(char *string,int row){
80108aa2:	55                   	push   %ebp
80108aa3:	89 e5                	mov    %esp,%ebp
80108aa5:	53                   	push   %ebx
80108aa6:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108aa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108ab0:	eb 33                	jmp    80108ae5 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108ab2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab8:	01 d0                	add    %edx,%eax
80108aba:	0f b6 00             	movzbl (%eax),%eax
80108abd:	0f be d8             	movsbl %al,%ebx
80108ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ac3:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ac9:	89 d0                	mov    %edx,%eax
80108acb:	c1 e0 04             	shl    $0x4,%eax
80108ace:	29 d0                	sub    %edx,%eax
80108ad0:	83 c0 02             	add    $0x2,%eax
80108ad3:	83 ec 04             	sub    $0x4,%esp
80108ad6:	53                   	push   %ebx
80108ad7:	51                   	push   %ecx
80108ad8:	50                   	push   %eax
80108ad9:	e8 ef fe ff ff       	call   801089cd <font_render>
80108ade:	83 c4 10             	add    $0x10,%esp
    i++;
80108ae1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108ae5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80108aeb:	01 d0                	add    %edx,%eax
80108aed:	0f b6 00             	movzbl (%eax),%eax
80108af0:	84 c0                	test   %al,%al
80108af2:	74 06                	je     80108afa <font_render_string+0x58>
80108af4:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108af8:	7e b8                	jle    80108ab2 <font_render_string+0x10>
  }
}
80108afa:	90                   	nop
80108afb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108afe:	c9                   	leave
80108aff:	c3                   	ret

80108b00 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108b00:	55                   	push   %ebp
80108b01:	89 e5                	mov    %esp,%ebp
80108b03:	53                   	push   %ebx
80108b04:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108b07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b0e:	eb 6b                	jmp    80108b7b <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108b10:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b17:	eb 58                	jmp    80108b71 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108b19:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108b20:	eb 45                	jmp    80108b67 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108b22:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108b25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2b:	83 ec 0c             	sub    $0xc,%esp
80108b2e:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108b31:	53                   	push   %ebx
80108b32:	6a 00                	push   $0x0
80108b34:	51                   	push   %ecx
80108b35:	52                   	push   %edx
80108b36:	50                   	push   %eax
80108b37:	e8 b0 00 00 00       	call   80108bec <pci_access_config>
80108b3c:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b42:	0f b7 c0             	movzwl %ax,%eax
80108b45:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108b4a:	74 17                	je     80108b63 <pci_init+0x63>
        pci_init_device(i,j,k);
80108b4c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108b4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b55:	83 ec 04             	sub    $0x4,%esp
80108b58:	51                   	push   %ecx
80108b59:	52                   	push   %edx
80108b5a:	50                   	push   %eax
80108b5b:	e8 37 01 00 00       	call   80108c97 <pci_init_device>
80108b60:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108b63:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108b67:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108b6b:	7e b5                	jle    80108b22 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108b6d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108b71:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108b75:	7e a2                	jle    80108b19 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108b77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b7b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108b82:	7e 8c                	jle    80108b10 <pci_init+0x10>
      }
      }
    }
  }
}
80108b84:	90                   	nop
80108b85:	90                   	nop
80108b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b89:	c9                   	leave
80108b8a:	c3                   	ret

80108b8b <pci_write_config>:

void pci_write_config(uint config){
80108b8b:	55                   	push   %ebp
80108b8c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80108b91:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108b96:	89 c0                	mov    %eax,%eax
80108b98:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108b99:	90                   	nop
80108b9a:	5d                   	pop    %ebp
80108b9b:	c3                   	ret

80108b9c <pci_write_data>:

void pci_write_data(uint config){
80108b9c:	55                   	push   %ebp
80108b9d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80108ba2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108ba7:	89 c0                	mov    %eax,%eax
80108ba9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108baa:	90                   	nop
80108bab:	5d                   	pop    %ebp
80108bac:	c3                   	ret

80108bad <pci_read_config>:
uint pci_read_config(){
80108bad:	55                   	push   %ebp
80108bae:	89 e5                	mov    %esp,%ebp
80108bb0:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108bb3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108bb8:	ed                   	in     (%dx),%eax
80108bb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108bbc:	83 ec 0c             	sub    $0xc,%esp
80108bbf:	68 c8 00 00 00       	push   $0xc8
80108bc4:	e8 70 9f ff ff       	call   80102b39 <microdelay>
80108bc9:	83 c4 10             	add    $0x10,%esp
  return data;
80108bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108bcf:	c9                   	leave
80108bd0:	c3                   	ret

80108bd1 <pci_test>:


void pci_test(){
80108bd1:	55                   	push   %ebp
80108bd2:	89 e5                	mov    %esp,%ebp
80108bd4:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108bd7:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108bde:	ff 75 fc             	push   -0x4(%ebp)
80108be1:	e8 a5 ff ff ff       	call   80108b8b <pci_write_config>
80108be6:	83 c4 04             	add    $0x4,%esp
}
80108be9:	90                   	nop
80108bea:	c9                   	leave
80108beb:	c3                   	ret

80108bec <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108bec:	55                   	push   %ebp
80108bed:	89 e5                	mov    %esp,%ebp
80108bef:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80108bf5:	c1 e0 10             	shl    $0x10,%eax
80108bf8:	25 00 00 ff 00       	and    $0xff0000,%eax
80108bfd:	89 c2                	mov    %eax,%edx
80108bff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c02:	c1 e0 0b             	shl    $0xb,%eax
80108c05:	0f b7 c0             	movzwl %ax,%eax
80108c08:	09 c2                	or     %eax,%edx
80108c0a:	8b 45 10             	mov    0x10(%ebp),%eax
80108c0d:	c1 e0 08             	shl    $0x8,%eax
80108c10:	25 00 07 00 00       	and    $0x700,%eax
80108c15:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108c17:	8b 45 14             	mov    0x14(%ebp),%eax
80108c1a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c1f:	09 d0                	or     %edx,%eax
80108c21:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108c29:	ff 75 f4             	push   -0xc(%ebp)
80108c2c:	e8 5a ff ff ff       	call   80108b8b <pci_write_config>
80108c31:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108c34:	e8 74 ff ff ff       	call   80108bad <pci_read_config>
80108c39:	8b 55 18             	mov    0x18(%ebp),%edx
80108c3c:	89 02                	mov    %eax,(%edx)
}
80108c3e:	90                   	nop
80108c3f:	c9                   	leave
80108c40:	c3                   	ret

80108c41 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108c41:	55                   	push   %ebp
80108c42:	89 e5                	mov    %esp,%ebp
80108c44:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c47:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4a:	c1 e0 10             	shl    $0x10,%eax
80108c4d:	25 00 00 ff 00       	and    $0xff0000,%eax
80108c52:	89 c2                	mov    %eax,%edx
80108c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c57:	c1 e0 0b             	shl    $0xb,%eax
80108c5a:	0f b7 c0             	movzwl %ax,%eax
80108c5d:	09 c2                	or     %eax,%edx
80108c5f:	8b 45 10             	mov    0x10(%ebp),%eax
80108c62:	c1 e0 08             	shl    $0x8,%eax
80108c65:	25 00 07 00 00       	and    $0x700,%eax
80108c6a:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108c6c:	8b 45 14             	mov    0x14(%ebp),%eax
80108c6f:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c74:	09 d0                	or     %edx,%eax
80108c76:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108c7e:	ff 75 fc             	push   -0x4(%ebp)
80108c81:	e8 05 ff ff ff       	call   80108b8b <pci_write_config>
80108c86:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108c89:	ff 75 18             	push   0x18(%ebp)
80108c8c:	e8 0b ff ff ff       	call   80108b9c <pci_write_data>
80108c91:	83 c4 04             	add    $0x4,%esp
}
80108c94:	90                   	nop
80108c95:	c9                   	leave
80108c96:	c3                   	ret

80108c97 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108c97:	55                   	push   %ebp
80108c98:	89 e5                	mov    %esp,%ebp
80108c9a:	53                   	push   %ebx
80108c9b:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca1:	a2 98 7a 19 80       	mov    %al,0x80197a98
  dev.device_num = device_num;
80108ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca9:	a2 99 7a 19 80       	mov    %al,0x80197a99
  dev.function_num = function_num;
80108cae:	8b 45 10             	mov    0x10(%ebp),%eax
80108cb1:	a2 9a 7a 19 80       	mov    %al,0x80197a9a
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108cb6:	ff 75 10             	push   0x10(%ebp)
80108cb9:	ff 75 0c             	push   0xc(%ebp)
80108cbc:	ff 75 08             	push   0x8(%ebp)
80108cbf:	68 c4 c9 10 80       	push   $0x8010c9c4
80108cc4:	e8 2b 77 ff ff       	call   801003f4 <cprintf>
80108cc9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108ccc:	83 ec 0c             	sub    $0xc,%esp
80108ccf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cd2:	50                   	push   %eax
80108cd3:	6a 00                	push   $0x0
80108cd5:	ff 75 10             	push   0x10(%ebp)
80108cd8:	ff 75 0c             	push   0xc(%ebp)
80108cdb:	ff 75 08             	push   0x8(%ebp)
80108cde:	e8 09 ff ff ff       	call   80108bec <pci_access_config>
80108ce3:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ce9:	c1 e8 10             	shr    $0x10,%eax
80108cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cf2:	25 ff ff 00 00       	and    $0xffff,%eax
80108cf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfd:	a3 9c 7a 19 80       	mov    %eax,0x80197a9c
  dev.vendor_id = vendor_id;
80108d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d05:	a3 a0 7a 19 80       	mov    %eax,0x80197aa0
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108d0a:	83 ec 04             	sub    $0x4,%esp
80108d0d:	ff 75 f0             	push   -0x10(%ebp)
80108d10:	ff 75 f4             	push   -0xc(%ebp)
80108d13:	68 f8 c9 10 80       	push   $0x8010c9f8
80108d18:	e8 d7 76 ff ff       	call   801003f4 <cprintf>
80108d1d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108d20:	83 ec 0c             	sub    $0xc,%esp
80108d23:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d26:	50                   	push   %eax
80108d27:	6a 08                	push   $0x8
80108d29:	ff 75 10             	push   0x10(%ebp)
80108d2c:	ff 75 0c             	push   0xc(%ebp)
80108d2f:	ff 75 08             	push   0x8(%ebp)
80108d32:	e8 b5 fe ff ff       	call   80108bec <pci_access_config>
80108d37:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d3d:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108d40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d43:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108d46:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108d49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d4c:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108d4f:	0f b6 c0             	movzbl %al,%eax
80108d52:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108d55:	c1 eb 18             	shr    $0x18,%ebx
80108d58:	83 ec 0c             	sub    $0xc,%esp
80108d5b:	51                   	push   %ecx
80108d5c:	52                   	push   %edx
80108d5d:	50                   	push   %eax
80108d5e:	53                   	push   %ebx
80108d5f:	68 1c ca 10 80       	push   $0x8010ca1c
80108d64:	e8 8b 76 ff ff       	call   801003f4 <cprintf>
80108d69:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d6f:	c1 e8 18             	shr    $0x18,%eax
80108d72:	a2 a4 7a 19 80       	mov    %al,0x80197aa4
  dev.sub_class = (data>>16)&0xFF;
80108d77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d7a:	c1 e8 10             	shr    $0x10,%eax
80108d7d:	a2 a5 7a 19 80       	mov    %al,0x80197aa5
  dev.interface = (data>>8)&0xFF;
80108d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d85:	c1 e8 08             	shr    $0x8,%eax
80108d88:	a2 a6 7a 19 80       	mov    %al,0x80197aa6
  dev.revision_id = data&0xFF;
80108d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d90:	a2 a7 7a 19 80       	mov    %al,0x80197aa7
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108d95:	83 ec 0c             	sub    $0xc,%esp
80108d98:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d9b:	50                   	push   %eax
80108d9c:	6a 10                	push   $0x10
80108d9e:	ff 75 10             	push   0x10(%ebp)
80108da1:	ff 75 0c             	push   0xc(%ebp)
80108da4:	ff 75 08             	push   0x8(%ebp)
80108da7:	e8 40 fe ff ff       	call   80108bec <pci_access_config>
80108dac:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108daf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db2:	a3 a8 7a 19 80       	mov    %eax,0x80197aa8
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108db7:	83 ec 0c             	sub    $0xc,%esp
80108dba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dbd:	50                   	push   %eax
80108dbe:	6a 14                	push   $0x14
80108dc0:	ff 75 10             	push   0x10(%ebp)
80108dc3:	ff 75 0c             	push   0xc(%ebp)
80108dc6:	ff 75 08             	push   0x8(%ebp)
80108dc9:	e8 1e fe ff ff       	call   80108bec <pci_access_config>
80108dce:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd4:	a3 ac 7a 19 80       	mov    %eax,0x80197aac
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108dd9:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108de0:	75 5a                	jne    80108e3c <pci_init_device+0x1a5>
80108de2:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108de9:	75 51                	jne    80108e3c <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108deb:	83 ec 0c             	sub    $0xc,%esp
80108dee:	68 61 ca 10 80       	push   $0x8010ca61
80108df3:	e8 fc 75 ff ff       	call   801003f4 <cprintf>
80108df8:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108dfb:	83 ec 0c             	sub    $0xc,%esp
80108dfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e01:	50                   	push   %eax
80108e02:	68 f0 00 00 00       	push   $0xf0
80108e07:	ff 75 10             	push   0x10(%ebp)
80108e0a:	ff 75 0c             	push   0xc(%ebp)
80108e0d:	ff 75 08             	push   0x8(%ebp)
80108e10:	e8 d7 fd ff ff       	call   80108bec <pci_access_config>
80108e15:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108e18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e1b:	83 ec 08             	sub    $0x8,%esp
80108e1e:	50                   	push   %eax
80108e1f:	68 7b ca 10 80       	push   $0x8010ca7b
80108e24:	e8 cb 75 ff ff       	call   801003f4 <cprintf>
80108e29:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108e2c:	83 ec 0c             	sub    $0xc,%esp
80108e2f:	68 98 7a 19 80       	push   $0x80197a98
80108e34:	e8 09 00 00 00       	call   80108e42 <i8254_init>
80108e39:	83 c4 10             	add    $0x10,%esp
  }
}
80108e3c:	90                   	nop
80108e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e40:	c9                   	leave
80108e41:	c3                   	ret

80108e42 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108e42:	55                   	push   %ebp
80108e43:	89 e5                	mov    %esp,%ebp
80108e45:	53                   	push   %ebx
80108e46:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108e49:	8b 45 08             	mov    0x8(%ebp),%eax
80108e4c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108e50:	0f b6 c8             	movzbl %al,%ecx
80108e53:	8b 45 08             	mov    0x8(%ebp),%eax
80108e56:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108e5a:	0f b6 d0             	movzbl %al,%edx
80108e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e60:	0f b6 00             	movzbl (%eax),%eax
80108e63:	0f b6 c0             	movzbl %al,%eax
80108e66:	83 ec 0c             	sub    $0xc,%esp
80108e69:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108e6c:	53                   	push   %ebx
80108e6d:	6a 04                	push   $0x4
80108e6f:	51                   	push   %ecx
80108e70:	52                   	push   %edx
80108e71:	50                   	push   %eax
80108e72:	e8 75 fd ff ff       	call   80108bec <pci_access_config>
80108e77:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e7d:	83 c8 04             	or     $0x4,%eax
80108e80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108e83:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108e86:	8b 45 08             	mov    0x8(%ebp),%eax
80108e89:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108e8d:	0f b6 c8             	movzbl %al,%ecx
80108e90:	8b 45 08             	mov    0x8(%ebp),%eax
80108e93:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108e97:	0f b6 d0             	movzbl %al,%edx
80108e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80108e9d:	0f b6 00             	movzbl (%eax),%eax
80108ea0:	0f b6 c0             	movzbl %al,%eax
80108ea3:	83 ec 0c             	sub    $0xc,%esp
80108ea6:	53                   	push   %ebx
80108ea7:	6a 04                	push   $0x4
80108ea9:	51                   	push   %ecx
80108eaa:	52                   	push   %edx
80108eab:	50                   	push   %eax
80108eac:	e8 90 fd ff ff       	call   80108c41 <pci_write_config_register>
80108eb1:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb7:	8b 40 10             	mov    0x10(%eax),%eax
80108eba:	05 00 00 00 40       	add    $0x40000000,%eax
80108ebf:	a3 b0 7a 19 80       	mov    %eax,0x80197ab0
  uint *ctrl = (uint *)base_addr;
80108ec4:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108ecc:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108ed1:	05 d8 00 00 00       	add    $0xd8,%eax
80108ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108edc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee5:	8b 00                	mov    (%eax),%eax
80108ee7:	0d 00 00 00 04       	or     $0x4000000,%eax
80108eec:	89 c2                	mov    %eax,%edx
80108eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef1:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ef6:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eff:	8b 00                	mov    (%eax),%eax
80108f01:	83 c8 40             	or     $0x40,%eax
80108f04:	89 c2                	mov    %eax,%edx
80108f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f09:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0e:	8b 10                	mov    (%eax),%edx
80108f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f13:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108f15:	83 ec 0c             	sub    $0xc,%esp
80108f18:	68 90 ca 10 80       	push   $0x8010ca90
80108f1d:	e8 d2 74 ff ff       	call   801003f4 <cprintf>
80108f22:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108f25:	e8 7e 98 ff ff       	call   801027a8 <kalloc>
80108f2a:	a3 bc 7a 19 80       	mov    %eax,0x80197abc
  *intr_addr = 0;
80108f2f:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108f34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108f3a:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108f3f:	83 ec 08             	sub    $0x8,%esp
80108f42:	50                   	push   %eax
80108f43:	68 b2 ca 10 80       	push   $0x8010cab2
80108f48:	e8 a7 74 ff ff       	call   801003f4 <cprintf>
80108f4d:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108f50:	e8 50 00 00 00       	call   80108fa5 <i8254_init_recv>
  i8254_init_send();
80108f55:	e8 69 03 00 00       	call   801092c3 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108f5a:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108f61:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108f64:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108f6b:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108f6e:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108f75:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108f78:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108f7f:	0f b6 c0             	movzbl %al,%eax
80108f82:	83 ec 0c             	sub    $0xc,%esp
80108f85:	53                   	push   %ebx
80108f86:	51                   	push   %ecx
80108f87:	52                   	push   %edx
80108f88:	50                   	push   %eax
80108f89:	68 c0 ca 10 80       	push   $0x8010cac0
80108f8e:	e8 61 74 ff ff       	call   801003f4 <cprintf>
80108f93:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108f9f:	90                   	nop
80108fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108fa3:	c9                   	leave
80108fa4:	c3                   	ret

80108fa5 <i8254_init_recv>:

void i8254_init_recv(){
80108fa5:	55                   	push   %ebp
80108fa6:	89 e5                	mov    %esp,%ebp
80108fa8:	57                   	push   %edi
80108fa9:	56                   	push   %esi
80108faa:	53                   	push   %ebx
80108fab:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108fae:	83 ec 0c             	sub    $0xc,%esp
80108fb1:	6a 00                	push   $0x0
80108fb3:	e8 e8 04 00 00       	call   801094a0 <i8254_read_eeprom>
80108fb8:	83 c4 10             	add    $0x10,%esp
80108fbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108fbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fc1:	a2 b4 7a 19 80       	mov    %al,0x80197ab4
  mac_addr[1] = data_l>>8;
80108fc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fc9:	c1 e8 08             	shr    $0x8,%eax
80108fcc:	a2 b5 7a 19 80       	mov    %al,0x80197ab5
  uint data_m = i8254_read_eeprom(0x1);
80108fd1:	83 ec 0c             	sub    $0xc,%esp
80108fd4:	6a 01                	push   $0x1
80108fd6:	e8 c5 04 00 00       	call   801094a0 <i8254_read_eeprom>
80108fdb:	83 c4 10             	add    $0x10,%esp
80108fde:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108fe1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fe4:	a2 b6 7a 19 80       	mov    %al,0x80197ab6
  mac_addr[3] = data_m>>8;
80108fe9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fec:	c1 e8 08             	shr    $0x8,%eax
80108fef:	a2 b7 7a 19 80       	mov    %al,0x80197ab7
  uint data_h = i8254_read_eeprom(0x2);
80108ff4:	83 ec 0c             	sub    $0xc,%esp
80108ff7:	6a 02                	push   $0x2
80108ff9:	e8 a2 04 00 00       	call   801094a0 <i8254_read_eeprom>
80108ffe:	83 c4 10             	add    $0x10,%esp
80109001:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80109004:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109007:	a2 b8 7a 19 80       	mov    %al,0x80197ab8
  mac_addr[5] = data_h>>8;
8010900c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010900f:	c1 e8 08             	shr    $0x8,%eax
80109012:	a2 b9 7a 19 80       	mov    %al,0x80197ab9
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109017:	0f b6 05 b9 7a 19 80 	movzbl 0x80197ab9,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010901e:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80109021:	0f b6 05 b8 7a 19 80 	movzbl 0x80197ab8,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109028:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010902b:	0f b6 05 b7 7a 19 80 	movzbl 0x80197ab7,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109032:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109035:	0f b6 05 b6 7a 19 80 	movzbl 0x80197ab6,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010903c:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010903f:	0f b6 05 b5 7a 19 80 	movzbl 0x80197ab5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109046:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109049:	0f b6 05 b4 7a 19 80 	movzbl 0x80197ab4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109050:	0f b6 c0             	movzbl %al,%eax
80109053:	83 ec 04             	sub    $0x4,%esp
80109056:	57                   	push   %edi
80109057:	56                   	push   %esi
80109058:	53                   	push   %ebx
80109059:	51                   	push   %ecx
8010905a:	52                   	push   %edx
8010905b:	50                   	push   %eax
8010905c:	68 d8 ca 10 80       	push   $0x8010cad8
80109061:	e8 8e 73 ff ff       	call   801003f4 <cprintf>
80109066:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109069:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010906e:	05 00 54 00 00       	add    $0x5400,%eax
80109073:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80109076:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010907b:	05 04 54 00 00       	add    $0x5404,%eax
80109080:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80109083:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109086:	c1 e0 10             	shl    $0x10,%eax
80109089:	0b 45 d8             	or     -0x28(%ebp),%eax
8010908c:	89 c2                	mov    %eax,%edx
8010908e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80109091:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80109093:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109096:	0d 00 00 00 80       	or     $0x80000000,%eax
8010909b:	89 c2                	mov    %eax,%edx
8010909d:	8b 45 c8             	mov    -0x38(%ebp),%eax
801090a0:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801090a2:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801090a7:	05 00 52 00 00       	add    $0x5200,%eax
801090ac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801090af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801090b6:	eb 19                	jmp    801090d1 <i8254_init_recv+0x12c>
    mta[i] = 0;
801090b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801090bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090c2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801090c5:	01 d0                	add    %edx,%eax
801090c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801090cd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801090d1:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801090d5:	7e e1                	jle    801090b8 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801090d7:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801090dc:	05 d0 00 00 00       	add    $0xd0,%eax
801090e1:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801090e4:	8b 45 c0             	mov    -0x40(%ebp),%eax
801090e7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801090ed:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801090f2:	05 c8 00 00 00       	add    $0xc8,%eax
801090f7:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801090fa:	8b 45 bc             	mov    -0x44(%ebp),%eax
801090fd:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109103:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109108:	05 28 28 00 00       	add    $0x2828,%eax
8010910d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109110:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109113:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109119:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010911e:	05 00 01 00 00       	add    $0x100,%eax
80109123:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109126:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109129:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010912f:	e8 74 96 ff ff       	call   801027a8 <kalloc>
80109134:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109137:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010913c:	05 00 28 00 00       	add    $0x2800,%eax
80109141:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80109144:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109149:	05 04 28 00 00       	add    $0x2804,%eax
8010914e:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80109151:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109156:	05 08 28 00 00       	add    $0x2808,%eax
8010915b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010915e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109163:	05 10 28 00 00       	add    $0x2810,%eax
80109168:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010916b:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109170:	05 18 28 00 00       	add    $0x2818,%eax
80109175:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109178:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010917b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109181:	8b 45 ac             	mov    -0x54(%ebp),%eax
80109184:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109186:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109189:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010918f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80109192:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109198:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010919b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801091a1:	8b 45 9c             	mov    -0x64(%ebp),%eax
801091a4:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801091aa:	8b 45 b0             	mov    -0x50(%ebp),%eax
801091ad:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801091b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801091b7:	eb 73                	jmp    8010922c <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801091b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091bc:	c1 e0 04             	shl    $0x4,%eax
801091bf:	89 c2                	mov    %eax,%edx
801091c1:	8b 45 98             	mov    -0x68(%ebp),%eax
801091c4:	01 d0                	add    %edx,%eax
801091c6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801091cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091d0:	c1 e0 04             	shl    $0x4,%eax
801091d3:	89 c2                	mov    %eax,%edx
801091d5:	8b 45 98             	mov    -0x68(%ebp),%eax
801091d8:	01 d0                	add    %edx,%eax
801091da:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801091e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091e3:	c1 e0 04             	shl    $0x4,%eax
801091e6:	89 c2                	mov    %eax,%edx
801091e8:	8b 45 98             	mov    -0x68(%ebp),%eax
801091eb:	01 d0                	add    %edx,%eax
801091ed:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801091f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091f6:	c1 e0 04             	shl    $0x4,%eax
801091f9:	89 c2                	mov    %eax,%edx
801091fb:	8b 45 98             	mov    -0x68(%ebp),%eax
801091fe:	01 d0                	add    %edx,%eax
80109200:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109204:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109207:	c1 e0 04             	shl    $0x4,%eax
8010920a:	89 c2                	mov    %eax,%edx
8010920c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010920f:	01 d0                	add    %edx,%eax
80109211:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109215:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109218:	c1 e0 04             	shl    $0x4,%eax
8010921b:	89 c2                	mov    %eax,%edx
8010921d:	8b 45 98             	mov    -0x68(%ebp),%eax
80109220:	01 d0                	add    %edx,%eax
80109222:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109228:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010922c:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109233:	7e 84                	jle    801091b9 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109235:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010923c:	eb 57                	jmp    80109295 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010923e:	e8 65 95 ff ff       	call   801027a8 <kalloc>
80109243:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109246:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010924a:	75 12                	jne    8010925e <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
8010924c:	83 ec 0c             	sub    $0xc,%esp
8010924f:	68 f8 ca 10 80       	push   $0x8010caf8
80109254:	e8 9b 71 ff ff       	call   801003f4 <cprintf>
80109259:	83 c4 10             	add    $0x10,%esp
      break;
8010925c:	eb 3d                	jmp    8010929b <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010925e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109261:	c1 e0 04             	shl    $0x4,%eax
80109264:	89 c2                	mov    %eax,%edx
80109266:	8b 45 98             	mov    -0x68(%ebp),%eax
80109269:	01 d0                	add    %edx,%eax
8010926b:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010926e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109274:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109276:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109279:	83 c0 01             	add    $0x1,%eax
8010927c:	c1 e0 04             	shl    $0x4,%eax
8010927f:	89 c2                	mov    %eax,%edx
80109281:	8b 45 98             	mov    -0x68(%ebp),%eax
80109284:	01 d0                	add    %edx,%eax
80109286:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109289:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010928f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109291:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109295:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109299:	7e a3                	jle    8010923e <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
8010929b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010929e:	8b 00                	mov    (%eax),%eax
801092a0:	83 c8 02             	or     $0x2,%eax
801092a3:	89 c2                	mov    %eax,%edx
801092a5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801092a8:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801092aa:	83 ec 0c             	sub    $0xc,%esp
801092ad:	68 18 cb 10 80       	push   $0x8010cb18
801092b2:	e8 3d 71 ff ff       	call   801003f4 <cprintf>
801092b7:	83 c4 10             	add    $0x10,%esp
}
801092ba:	90                   	nop
801092bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801092be:	5b                   	pop    %ebx
801092bf:	5e                   	pop    %esi
801092c0:	5f                   	pop    %edi
801092c1:	5d                   	pop    %ebp
801092c2:	c3                   	ret

801092c3 <i8254_init_send>:

void i8254_init_send(){
801092c3:	55                   	push   %ebp
801092c4:	89 e5                	mov    %esp,%ebp
801092c6:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801092c9:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092ce:	05 28 38 00 00       	add    $0x3828,%eax
801092d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801092d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092d9:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801092df:	e8 c4 94 ff ff       	call   801027a8 <kalloc>
801092e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801092e7:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092ec:	05 00 38 00 00       	add    $0x3800,%eax
801092f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801092f4:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092f9:	05 04 38 00 00       	add    $0x3804,%eax
801092fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109301:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109306:	05 08 38 00 00       	add    $0x3808,%eax
8010930b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010930e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109311:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010931a:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010931c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010931f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109325:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109328:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010932e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109333:	05 10 38 00 00       	add    $0x3810,%eax
80109338:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010933b:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109340:	05 18 38 00 00       	add    $0x3818,%eax
80109345:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109348:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010934b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109351:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109354:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010935a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010935d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109360:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109367:	e9 82 00 00 00       	jmp    801093ee <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
8010936c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936f:	c1 e0 04             	shl    $0x4,%eax
80109372:	89 c2                	mov    %eax,%edx
80109374:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109377:	01 d0                	add    %edx,%eax
80109379:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109383:	c1 e0 04             	shl    $0x4,%eax
80109386:	89 c2                	mov    %eax,%edx
80109388:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010938b:	01 d0                	add    %edx,%eax
8010938d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109396:	c1 e0 04             	shl    $0x4,%eax
80109399:	89 c2                	mov    %eax,%edx
8010939b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010939e:	01 d0                	add    %edx,%eax
801093a0:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801093a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a7:	c1 e0 04             	shl    $0x4,%eax
801093aa:	89 c2                	mov    %eax,%edx
801093ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093af:	01 d0                	add    %edx,%eax
801093b1:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801093b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b8:	c1 e0 04             	shl    $0x4,%eax
801093bb:	89 c2                	mov    %eax,%edx
801093bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093c0:	01 d0                	add    %edx,%eax
801093c2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801093c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c9:	c1 e0 04             	shl    $0x4,%eax
801093cc:	89 c2                	mov    %eax,%edx
801093ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093d1:	01 d0                	add    %edx,%eax
801093d3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801093d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093da:	c1 e0 04             	shl    $0x4,%eax
801093dd:	89 c2                	mov    %eax,%edx
801093df:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093e2:	01 d0                	add    %edx,%eax
801093e4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801093ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093ee:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801093f5:	0f 8e 71 ff ff ff    	jle    8010936c <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801093fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109402:	eb 57                	jmp    8010945b <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109404:	e8 9f 93 ff ff       	call   801027a8 <kalloc>
80109409:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
8010940c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109410:	75 12                	jne    80109424 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109412:	83 ec 0c             	sub    $0xc,%esp
80109415:	68 f8 ca 10 80       	push   $0x8010caf8
8010941a:	e8 d5 6f ff ff       	call   801003f4 <cprintf>
8010941f:	83 c4 10             	add    $0x10,%esp
      break;
80109422:	eb 3d                	jmp    80109461 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109427:	c1 e0 04             	shl    $0x4,%eax
8010942a:	89 c2                	mov    %eax,%edx
8010942c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010942f:	01 d0                	add    %edx,%eax
80109431:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109434:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010943a:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010943c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943f:	83 c0 01             	add    $0x1,%eax
80109442:	c1 e0 04             	shl    $0x4,%eax
80109445:	89 c2                	mov    %eax,%edx
80109447:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010944a:	01 d0                	add    %edx,%eax
8010944c:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010944f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109455:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109457:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010945b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010945f:	7e a3                	jle    80109404 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109461:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109466:	05 00 04 00 00       	add    $0x400,%eax
8010946b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010946e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109471:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109477:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010947c:	05 10 04 00 00       	add    $0x410,%eax
80109481:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109484:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109487:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010948d:	83 ec 0c             	sub    $0xc,%esp
80109490:	68 38 cb 10 80       	push   $0x8010cb38
80109495:	e8 5a 6f ff ff       	call   801003f4 <cprintf>
8010949a:	83 c4 10             	add    $0x10,%esp

}
8010949d:	90                   	nop
8010949e:	c9                   	leave
8010949f:	c3                   	ret

801094a0 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801094a0:	55                   	push   %ebp
801094a1:	89 e5                	mov    %esp,%ebp
801094a3:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801094a6:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094ab:	83 c0 14             	add    $0x14,%eax
801094ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801094b1:	8b 45 08             	mov    0x8(%ebp),%eax
801094b4:	c1 e0 08             	shl    $0x8,%eax
801094b7:	0f b7 c0             	movzwl %ax,%eax
801094ba:	83 c8 01             	or     $0x1,%eax
801094bd:	89 c2                	mov    %eax,%edx
801094bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c2:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801094c4:	83 ec 0c             	sub    $0xc,%esp
801094c7:	68 58 cb 10 80       	push   $0x8010cb58
801094cc:	e8 23 6f ff ff       	call   801003f4 <cprintf>
801094d1:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801094d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d7:	8b 00                	mov    (%eax),%eax
801094d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801094dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094df:	83 e0 10             	and    $0x10,%eax
801094e2:	85 c0                	test   %eax,%eax
801094e4:	75 02                	jne    801094e8 <i8254_read_eeprom+0x48>
  while(1){
801094e6:	eb dc                	jmp    801094c4 <i8254_read_eeprom+0x24>
      break;
801094e8:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801094e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ec:	8b 00                	mov    (%eax),%eax
801094ee:	c1 e8 10             	shr    $0x10,%eax
}
801094f1:	c9                   	leave
801094f2:	c3                   	ret

801094f3 <i8254_recv>:
void i8254_recv(){
801094f3:	55                   	push   %ebp
801094f4:	89 e5                	mov    %esp,%ebp
801094f6:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801094f9:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094fe:	05 10 28 00 00       	add    $0x2810,%eax
80109503:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109506:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010950b:	05 18 28 00 00       	add    $0x2818,%eax
80109510:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109513:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109518:	05 00 28 00 00       	add    $0x2800,%eax
8010951d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109520:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109523:	8b 00                	mov    (%eax),%eax
80109525:	05 00 00 00 80       	add    $0x80000000,%eax
8010952a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010952d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109530:	8b 10                	mov    (%eax),%edx
80109532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109535:	8b 00                	mov    (%eax),%eax
80109537:	29 c2                	sub    %eax,%edx
80109539:	89 d0                	mov    %edx,%eax
8010953b:	25 ff 00 00 00       	and    $0xff,%eax
80109540:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109543:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109547:	7e 37                	jle    80109580 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010954c:	8b 00                	mov    (%eax),%eax
8010954e:	c1 e0 04             	shl    $0x4,%eax
80109551:	89 c2                	mov    %eax,%edx
80109553:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109556:	01 d0                	add    %edx,%eax
80109558:	8b 00                	mov    (%eax),%eax
8010955a:	05 00 00 00 80       	add    $0x80000000,%eax
8010955f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109565:	8b 00                	mov    (%eax),%eax
80109567:	83 c0 01             	add    $0x1,%eax
8010956a:	0f b6 d0             	movzbl %al,%edx
8010956d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109570:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109572:	83 ec 0c             	sub    $0xc,%esp
80109575:	ff 75 e0             	push   -0x20(%ebp)
80109578:	e8 13 09 00 00       	call   80109e90 <eth_proc>
8010957d:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109583:	8b 10                	mov    (%eax),%edx
80109585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109588:	8b 00                	mov    (%eax),%eax
8010958a:	39 c2                	cmp    %eax,%edx
8010958c:	75 9f                	jne    8010952d <i8254_recv+0x3a>
      (*rdt)--;
8010958e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109591:	8b 00                	mov    (%eax),%eax
80109593:	8d 50 ff             	lea    -0x1(%eax),%edx
80109596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109599:	89 10                	mov    %edx,(%eax)
  while(1){
8010959b:	eb 90                	jmp    8010952d <i8254_recv+0x3a>

8010959d <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010959d:	55                   	push   %ebp
8010959e:	89 e5                	mov    %esp,%ebp
801095a0:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801095a3:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801095a8:	05 10 38 00 00       	add    $0x3810,%eax
801095ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801095b0:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801095b5:	05 18 38 00 00       	add    $0x3818,%eax
801095ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801095bd:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801095c2:	05 00 38 00 00       	add    $0x3800,%eax
801095c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801095ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095cd:	8b 00                	mov    (%eax),%eax
801095cf:	05 00 00 00 80       	add    $0x80000000,%eax
801095d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801095d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095da:	8b 10                	mov    (%eax),%edx
801095dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095df:	8b 00                	mov    (%eax),%eax
801095e1:	29 c2                	sub    %eax,%edx
801095e3:	0f b6 c2             	movzbl %dl,%eax
801095e6:	ba 00 01 00 00       	mov    $0x100,%edx
801095eb:	29 c2                	sub    %eax,%edx
801095ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801095f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f3:	8b 00                	mov    (%eax),%eax
801095f5:	25 ff 00 00 00       	and    $0xff,%eax
801095fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801095fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109601:	0f 8e a8 00 00 00    	jle    801096af <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109607:	8b 45 08             	mov    0x8(%ebp),%eax
8010960a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010960d:	89 d1                	mov    %edx,%ecx
8010960f:	c1 e1 04             	shl    $0x4,%ecx
80109612:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109615:	01 ca                	add    %ecx,%edx
80109617:	8b 12                	mov    (%edx),%edx
80109619:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010961f:	83 ec 04             	sub    $0x4,%esp
80109622:	ff 75 0c             	push   0xc(%ebp)
80109625:	50                   	push   %eax
80109626:	52                   	push   %edx
80109627:	e8 e2 bd ff ff       	call   8010540e <memmove>
8010962c:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010962f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109632:	c1 e0 04             	shl    $0x4,%eax
80109635:	89 c2                	mov    %eax,%edx
80109637:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010963a:	01 d0                	add    %edx,%eax
8010963c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010963f:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109643:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109646:	c1 e0 04             	shl    $0x4,%eax
80109649:	89 c2                	mov    %eax,%edx
8010964b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010964e:	01 d0                	add    %edx,%eax
80109650:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109654:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109657:	c1 e0 04             	shl    $0x4,%eax
8010965a:	89 c2                	mov    %eax,%edx
8010965c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010965f:	01 d0                	add    %edx,%eax
80109661:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109665:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109668:	c1 e0 04             	shl    $0x4,%eax
8010966b:	89 c2                	mov    %eax,%edx
8010966d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109670:	01 d0                	add    %edx,%eax
80109672:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109676:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109679:	c1 e0 04             	shl    $0x4,%eax
8010967c:	89 c2                	mov    %eax,%edx
8010967e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109681:	01 d0                	add    %edx,%eax
80109683:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109689:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010968c:	c1 e0 04             	shl    $0x4,%eax
8010968f:	89 c2                	mov    %eax,%edx
80109691:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109694:	01 d0                	add    %edx,%eax
80109696:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010969a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969d:	8b 00                	mov    (%eax),%eax
8010969f:	83 c0 01             	add    $0x1,%eax
801096a2:	0f b6 d0             	movzbl %al,%edx
801096a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a8:	89 10                	mov    %edx,(%eax)
    return len;
801096aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ad:	eb 05                	jmp    801096b4 <i8254_send+0x117>
  }else{
    return -1;
801096af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801096b4:	c9                   	leave
801096b5:	c3                   	ret

801096b6 <i8254_intr>:

void i8254_intr(){
801096b6:	55                   	push   %ebp
801096b7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801096b9:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
801096be:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801096c4:	90                   	nop
801096c5:	5d                   	pop    %ebp
801096c6:	c3                   	ret

801096c7 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801096c7:	55                   	push   %ebp
801096c8:	89 e5                	mov    %esp,%ebp
801096ca:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801096cd:	8b 45 08             	mov    0x8(%ebp),%eax
801096d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801096d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d6:	0f b7 00             	movzwl (%eax),%eax
801096d9:	66 3d 00 01          	cmp    $0x100,%ax
801096dd:	74 0a                	je     801096e9 <arp_proc+0x22>
801096df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096e4:	e9 4f 01 00 00       	jmp    80109838 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801096e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ec:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801096f0:	66 83 f8 08          	cmp    $0x8,%ax
801096f4:	74 0a                	je     80109700 <arp_proc+0x39>
801096f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801096fb:	e9 38 01 00 00       	jmp    80109838 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109703:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109707:	3c 06                	cmp    $0x6,%al
80109709:	74 0a                	je     80109715 <arp_proc+0x4e>
8010970b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109710:	e9 23 01 00 00       	jmp    80109838 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109718:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010971c:	3c 04                	cmp    $0x4,%al
8010971e:	74 0a                	je     8010972a <arp_proc+0x63>
80109720:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109725:	e9 0e 01 00 00       	jmp    80109838 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010972a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010972d:	83 c0 18             	add    $0x18,%eax
80109730:	83 ec 04             	sub    $0x4,%esp
80109733:	6a 04                	push   $0x4
80109735:	50                   	push   %eax
80109736:	68 04 f5 10 80       	push   $0x8010f504
8010973b:	e8 76 bc ff ff       	call   801053b6 <memcmp>
80109740:	83 c4 10             	add    $0x10,%esp
80109743:	85 c0                	test   %eax,%eax
80109745:	74 27                	je     8010976e <arp_proc+0xa7>
80109747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974a:	83 c0 0e             	add    $0xe,%eax
8010974d:	83 ec 04             	sub    $0x4,%esp
80109750:	6a 04                	push   $0x4
80109752:	50                   	push   %eax
80109753:	68 04 f5 10 80       	push   $0x8010f504
80109758:	e8 59 bc ff ff       	call   801053b6 <memcmp>
8010975d:	83 c4 10             	add    $0x10,%esp
80109760:	85 c0                	test   %eax,%eax
80109762:	74 0a                	je     8010976e <arp_proc+0xa7>
80109764:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109769:	e9 ca 00 00 00       	jmp    80109838 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010976e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109771:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109775:	66 3d 00 01          	cmp    $0x100,%ax
80109779:	75 69                	jne    801097e4 <arp_proc+0x11d>
8010977b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977e:	83 c0 18             	add    $0x18,%eax
80109781:	83 ec 04             	sub    $0x4,%esp
80109784:	6a 04                	push   $0x4
80109786:	50                   	push   %eax
80109787:	68 04 f5 10 80       	push   $0x8010f504
8010978c:	e8 25 bc ff ff       	call   801053b6 <memcmp>
80109791:	83 c4 10             	add    $0x10,%esp
80109794:	85 c0                	test   %eax,%eax
80109796:	75 4c                	jne    801097e4 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109798:	e8 0b 90 ff ff       	call   801027a8 <kalloc>
8010979d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801097a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801097a7:	83 ec 04             	sub    $0x4,%esp
801097aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801097ad:	50                   	push   %eax
801097ae:	ff 75 f0             	push   -0x10(%ebp)
801097b1:	ff 75 f4             	push   -0xc(%ebp)
801097b4:	e8 1f 04 00 00       	call   80109bd8 <arp_reply_pkt_create>
801097b9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801097bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097bf:	83 ec 08             	sub    $0x8,%esp
801097c2:	50                   	push   %eax
801097c3:	ff 75 f0             	push   -0x10(%ebp)
801097c6:	e8 d2 fd ff ff       	call   8010959d <i8254_send>
801097cb:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801097ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097d1:	83 ec 0c             	sub    $0xc,%esp
801097d4:	50                   	push   %eax
801097d5:	e8 34 8f ff ff       	call   8010270e <kfree>
801097da:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801097dd:	b8 02 00 00 00       	mov    $0x2,%eax
801097e2:	eb 54                	jmp    80109838 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801097e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097eb:	66 3d 00 02          	cmp    $0x200,%ax
801097ef:	75 42                	jne    80109833 <arp_proc+0x16c>
801097f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f4:	83 c0 18             	add    $0x18,%eax
801097f7:	83 ec 04             	sub    $0x4,%esp
801097fa:	6a 04                	push   $0x4
801097fc:	50                   	push   %eax
801097fd:	68 04 f5 10 80       	push   $0x8010f504
80109802:	e8 af bb ff ff       	call   801053b6 <memcmp>
80109807:	83 c4 10             	add    $0x10,%esp
8010980a:	85 c0                	test   %eax,%eax
8010980c:	75 25                	jne    80109833 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010980e:	83 ec 0c             	sub    $0xc,%esp
80109811:	68 5c cb 10 80       	push   $0x8010cb5c
80109816:	e8 d9 6b ff ff       	call   801003f4 <cprintf>
8010981b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010981e:	83 ec 0c             	sub    $0xc,%esp
80109821:	ff 75 f4             	push   -0xc(%ebp)
80109824:	e8 af 01 00 00       	call   801099d8 <arp_table_update>
80109829:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010982c:	b8 01 00 00 00       	mov    $0x1,%eax
80109831:	eb 05                	jmp    80109838 <arp_proc+0x171>
  }else{
    return -1;
80109833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109838:	c9                   	leave
80109839:	c3                   	ret

8010983a <arp_scan>:

void arp_scan(){
8010983a:	55                   	push   %ebp
8010983b:	89 e5                	mov    %esp,%ebp
8010983d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109840:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109847:	eb 6f                	jmp    801098b8 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109849:	e8 5a 8f ff ff       	call   801027a8 <kalloc>
8010984e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109851:	83 ec 04             	sub    $0x4,%esp
80109854:	ff 75 f4             	push   -0xc(%ebp)
80109857:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010985a:	50                   	push   %eax
8010985b:	ff 75 ec             	push   -0x14(%ebp)
8010985e:	e8 62 00 00 00       	call   801098c5 <arp_broadcast>
80109863:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109866:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109869:	83 ec 08             	sub    $0x8,%esp
8010986c:	50                   	push   %eax
8010986d:	ff 75 ec             	push   -0x14(%ebp)
80109870:	e8 28 fd ff ff       	call   8010959d <i8254_send>
80109875:	83 c4 10             	add    $0x10,%esp
80109878:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010987b:	eb 22                	jmp    8010989f <arp_scan+0x65>
      microdelay(1);
8010987d:	83 ec 0c             	sub    $0xc,%esp
80109880:	6a 01                	push   $0x1
80109882:	e8 b2 92 ff ff       	call   80102b39 <microdelay>
80109887:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010988a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010988d:	83 ec 08             	sub    $0x8,%esp
80109890:	50                   	push   %eax
80109891:	ff 75 ec             	push   -0x14(%ebp)
80109894:	e8 04 fd ff ff       	call   8010959d <i8254_send>
80109899:	83 c4 10             	add    $0x10,%esp
8010989c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010989f:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801098a3:	74 d8                	je     8010987d <arp_scan+0x43>
    }
    kfree((char *)send);
801098a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098a8:	83 ec 0c             	sub    $0xc,%esp
801098ab:	50                   	push   %eax
801098ac:	e8 5d 8e ff ff       	call   8010270e <kfree>
801098b1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801098b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801098b8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801098bf:	7e 88                	jle    80109849 <arp_scan+0xf>
  }
}
801098c1:	90                   	nop
801098c2:	90                   	nop
801098c3:	c9                   	leave
801098c4:	c3                   	ret

801098c5 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801098c5:	55                   	push   %ebp
801098c6:	89 e5                	mov    %esp,%ebp
801098c8:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801098cb:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801098cf:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801098d3:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801098d7:	8b 45 10             	mov    0x10(%ebp),%eax
801098da:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801098dd:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801098e4:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801098ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801098f1:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801098f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801098fa:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109900:	8b 45 08             	mov    0x8(%ebp),%eax
80109903:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109906:	8b 45 08             	mov    0x8(%ebp),%eax
80109909:	83 c0 0e             	add    $0xe,%eax
8010990c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010990f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109912:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109919:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010991d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109920:	83 ec 04             	sub    $0x4,%esp
80109923:	6a 06                	push   $0x6
80109925:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109928:	52                   	push   %edx
80109929:	50                   	push   %eax
8010992a:	e8 df ba ff ff       	call   8010540e <memmove>
8010992f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109935:	83 c0 06             	add    $0x6,%eax
80109938:	83 ec 04             	sub    $0x4,%esp
8010993b:	6a 06                	push   $0x6
8010993d:	68 b4 7a 19 80       	push   $0x80197ab4
80109942:	50                   	push   %eax
80109943:	e8 c6 ba ff ff       	call   8010540e <memmove>
80109948:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010994b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109956:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010995c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010995f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109966:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010996a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996d:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109976:	8d 50 12             	lea    0x12(%eax),%edx
80109979:	83 ec 04             	sub    $0x4,%esp
8010997c:	6a 06                	push   $0x6
8010997e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109981:	50                   	push   %eax
80109982:	52                   	push   %edx
80109983:	e8 86 ba ff ff       	call   8010540e <memmove>
80109988:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010998b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010998e:	8d 50 18             	lea    0x18(%eax),%edx
80109991:	83 ec 04             	sub    $0x4,%esp
80109994:	6a 04                	push   $0x4
80109996:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109999:	50                   	push   %eax
8010999a:	52                   	push   %edx
8010999b:	e8 6e ba ff ff       	call   8010540e <memmove>
801099a0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801099a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a6:	83 c0 08             	add    $0x8,%eax
801099a9:	83 ec 04             	sub    $0x4,%esp
801099ac:	6a 06                	push   $0x6
801099ae:	68 b4 7a 19 80       	push   $0x80197ab4
801099b3:	50                   	push   %eax
801099b4:	e8 55 ba ff ff       	call   8010540e <memmove>
801099b9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801099bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099bf:	83 c0 0e             	add    $0xe,%eax
801099c2:	83 ec 04             	sub    $0x4,%esp
801099c5:	6a 04                	push   $0x4
801099c7:	68 04 f5 10 80       	push   $0x8010f504
801099cc:	50                   	push   %eax
801099cd:	e8 3c ba ff ff       	call   8010540e <memmove>
801099d2:	83 c4 10             	add    $0x10,%esp
}
801099d5:	90                   	nop
801099d6:	c9                   	leave
801099d7:	c3                   	ret

801099d8 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801099d8:	55                   	push   %ebp
801099d9:	89 e5                	mov    %esp,%ebp
801099db:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801099de:	8b 45 08             	mov    0x8(%ebp),%eax
801099e1:	83 c0 0e             	add    $0xe,%eax
801099e4:	83 ec 0c             	sub    $0xc,%esp
801099e7:	50                   	push   %eax
801099e8:	e8 bc 00 00 00       	call   80109aa9 <arp_table_search>
801099ed:	83 c4 10             	add    $0x10,%esp
801099f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801099f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801099f7:	78 2d                	js     80109a26 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801099f9:	8b 45 08             	mov    0x8(%ebp),%eax
801099fc:	8d 48 08             	lea    0x8(%eax),%ecx
801099ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a02:	89 d0                	mov    %edx,%eax
80109a04:	c1 e0 02             	shl    $0x2,%eax
80109a07:	01 d0                	add    %edx,%eax
80109a09:	01 c0                	add    %eax,%eax
80109a0b:	01 d0                	add    %edx,%eax
80109a0d:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109a12:	83 c0 04             	add    $0x4,%eax
80109a15:	83 ec 04             	sub    $0x4,%esp
80109a18:	6a 06                	push   $0x6
80109a1a:	51                   	push   %ecx
80109a1b:	50                   	push   %eax
80109a1c:	e8 ed b9 ff ff       	call   8010540e <memmove>
80109a21:	83 c4 10             	add    $0x10,%esp
80109a24:	eb 70                	jmp    80109a96 <arp_table_update+0xbe>
  }else{
    index += 1;
80109a26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109a2a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a30:	8d 48 08             	lea    0x8(%eax),%ecx
80109a33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a36:	89 d0                	mov    %edx,%eax
80109a38:	c1 e0 02             	shl    $0x2,%eax
80109a3b:	01 d0                	add    %edx,%eax
80109a3d:	01 c0                	add    %eax,%eax
80109a3f:	01 d0                	add    %edx,%eax
80109a41:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109a46:	83 c0 04             	add    $0x4,%eax
80109a49:	83 ec 04             	sub    $0x4,%esp
80109a4c:	6a 06                	push   $0x6
80109a4e:	51                   	push   %ecx
80109a4f:	50                   	push   %eax
80109a50:	e8 b9 b9 ff ff       	call   8010540e <memmove>
80109a55:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109a58:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5b:	8d 48 0e             	lea    0xe(%eax),%ecx
80109a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a61:	89 d0                	mov    %edx,%eax
80109a63:	c1 e0 02             	shl    $0x2,%eax
80109a66:	01 d0                	add    %edx,%eax
80109a68:	01 c0                	add    %eax,%eax
80109a6a:	01 d0                	add    %edx,%eax
80109a6c:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109a71:	83 ec 04             	sub    $0x4,%esp
80109a74:	6a 04                	push   $0x4
80109a76:	51                   	push   %ecx
80109a77:	50                   	push   %eax
80109a78:	e8 91 b9 ff ff       	call   8010540e <memmove>
80109a7d:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109a80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a83:	89 d0                	mov    %edx,%eax
80109a85:	c1 e0 02             	shl    $0x2,%eax
80109a88:	01 d0                	add    %edx,%eax
80109a8a:	01 c0                	add    %eax,%eax
80109a8c:	01 d0                	add    %edx,%eax
80109a8e:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109a93:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109a96:	83 ec 0c             	sub    $0xc,%esp
80109a99:	68 c0 7a 19 80       	push   $0x80197ac0
80109a9e:	e8 83 00 00 00       	call   80109b26 <print_arp_table>
80109aa3:	83 c4 10             	add    $0x10,%esp
}
80109aa6:	90                   	nop
80109aa7:	c9                   	leave
80109aa8:	c3                   	ret

80109aa9 <arp_table_search>:

int arp_table_search(uchar *ip){
80109aa9:	55                   	push   %ebp
80109aaa:	89 e5                	mov    %esp,%ebp
80109aac:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109aaf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ab6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109abd:	eb 59                	jmp    80109b18 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109abf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109ac2:	89 d0                	mov    %edx,%eax
80109ac4:	c1 e0 02             	shl    $0x2,%eax
80109ac7:	01 d0                	add    %edx,%eax
80109ac9:	01 c0                	add    %eax,%eax
80109acb:	01 d0                	add    %edx,%eax
80109acd:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109ad2:	83 ec 04             	sub    $0x4,%esp
80109ad5:	6a 04                	push   $0x4
80109ad7:	ff 75 08             	push   0x8(%ebp)
80109ada:	50                   	push   %eax
80109adb:	e8 d6 b8 ff ff       	call   801053b6 <memcmp>
80109ae0:	83 c4 10             	add    $0x10,%esp
80109ae3:	85 c0                	test   %eax,%eax
80109ae5:	75 05                	jne    80109aec <arp_table_search+0x43>
      return i;
80109ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aea:	eb 38                	jmp    80109b24 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109aec:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109aef:	89 d0                	mov    %edx,%eax
80109af1:	c1 e0 02             	shl    $0x2,%eax
80109af4:	01 d0                	add    %edx,%eax
80109af6:	01 c0                	add    %eax,%eax
80109af8:	01 d0                	add    %edx,%eax
80109afa:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109aff:	0f b6 00             	movzbl (%eax),%eax
80109b02:	84 c0                	test   %al,%al
80109b04:	75 0e                	jne    80109b14 <arp_table_search+0x6b>
80109b06:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109b0a:	75 08                	jne    80109b14 <arp_table_search+0x6b>
      empty = -i;
80109b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b0f:	f7 d8                	neg    %eax
80109b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109b14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109b18:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109b1c:	7e a1                	jle    80109abf <arp_table_search+0x16>
    }
  }
  return empty-1;
80109b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b21:	83 e8 01             	sub    $0x1,%eax
}
80109b24:	c9                   	leave
80109b25:	c3                   	ret

80109b26 <print_arp_table>:

void print_arp_table(){
80109b26:	55                   	push   %ebp
80109b27:	89 e5                	mov    %esp,%ebp
80109b29:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109b33:	e9 92 00 00 00       	jmp    80109bca <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b3b:	89 d0                	mov    %edx,%eax
80109b3d:	c1 e0 02             	shl    $0x2,%eax
80109b40:	01 d0                	add    %edx,%eax
80109b42:	01 c0                	add    %eax,%eax
80109b44:	01 d0                	add    %edx,%eax
80109b46:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109b4b:	0f b6 00             	movzbl (%eax),%eax
80109b4e:	84 c0                	test   %al,%al
80109b50:	74 74                	je     80109bc6 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109b52:	83 ec 08             	sub    $0x8,%esp
80109b55:	ff 75 f4             	push   -0xc(%ebp)
80109b58:	68 6f cb 10 80       	push   $0x8010cb6f
80109b5d:	e8 92 68 ff ff       	call   801003f4 <cprintf>
80109b62:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b68:	89 d0                	mov    %edx,%eax
80109b6a:	c1 e0 02             	shl    $0x2,%eax
80109b6d:	01 d0                	add    %edx,%eax
80109b6f:	01 c0                	add    %eax,%eax
80109b71:	01 d0                	add    %edx,%eax
80109b73:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109b78:	83 ec 0c             	sub    $0xc,%esp
80109b7b:	50                   	push   %eax
80109b7c:	e8 54 02 00 00       	call   80109dd5 <print_ipv4>
80109b81:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109b84:	83 ec 0c             	sub    $0xc,%esp
80109b87:	68 7e cb 10 80       	push   $0x8010cb7e
80109b8c:	e8 63 68 ff ff       	call   801003f4 <cprintf>
80109b91:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109b94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b97:	89 d0                	mov    %edx,%eax
80109b99:	c1 e0 02             	shl    $0x2,%eax
80109b9c:	01 d0                	add    %edx,%eax
80109b9e:	01 c0                	add    %eax,%eax
80109ba0:	01 d0                	add    %edx,%eax
80109ba2:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109ba7:	83 c0 04             	add    $0x4,%eax
80109baa:	83 ec 0c             	sub    $0xc,%esp
80109bad:	50                   	push   %eax
80109bae:	e8 70 02 00 00       	call   80109e23 <print_mac>
80109bb3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109bb6:	83 ec 0c             	sub    $0xc,%esp
80109bb9:	68 80 cb 10 80       	push   $0x8010cb80
80109bbe:	e8 31 68 ff ff       	call   801003f4 <cprintf>
80109bc3:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109bc6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109bca:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109bce:	0f 8e 64 ff ff ff    	jle    80109b38 <print_arp_table+0x12>
    }
  }
}
80109bd4:	90                   	nop
80109bd5:	90                   	nop
80109bd6:	c9                   	leave
80109bd7:	c3                   	ret

80109bd8 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109bd8:	55                   	push   %ebp
80109bd9:	89 e5                	mov    %esp,%ebp
80109bdb:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109bde:	8b 45 10             	mov    0x10(%ebp),%eax
80109be1:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109bed:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bf0:	83 c0 0e             	add    $0xe,%eax
80109bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c00:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109c04:	8b 45 08             	mov    0x8(%ebp),%eax
80109c07:	8d 50 08             	lea    0x8(%eax),%edx
80109c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c0d:	83 ec 04             	sub    $0x4,%esp
80109c10:	6a 06                	push   $0x6
80109c12:	52                   	push   %edx
80109c13:	50                   	push   %eax
80109c14:	e8 f5 b7 ff ff       	call   8010540e <memmove>
80109c19:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c1f:	83 c0 06             	add    $0x6,%eax
80109c22:	83 ec 04             	sub    $0x4,%esp
80109c25:	6a 06                	push   $0x6
80109c27:	68 b4 7a 19 80       	push   $0x80197ab4
80109c2c:	50                   	push   %eax
80109c2d:	e8 dc b7 ff ff       	call   8010540e <memmove>
80109c32:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c38:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c40:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c49:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c50:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c57:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c60:	8d 50 08             	lea    0x8(%eax),%edx
80109c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c66:	83 c0 12             	add    $0x12,%eax
80109c69:	83 ec 04             	sub    $0x4,%esp
80109c6c:	6a 06                	push   $0x6
80109c6e:	52                   	push   %edx
80109c6f:	50                   	push   %eax
80109c70:	e8 99 b7 ff ff       	call   8010540e <memmove>
80109c75:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109c78:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7b:	8d 50 0e             	lea    0xe(%eax),%edx
80109c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c81:	83 c0 18             	add    $0x18,%eax
80109c84:	83 ec 04             	sub    $0x4,%esp
80109c87:	6a 04                	push   $0x4
80109c89:	52                   	push   %edx
80109c8a:	50                   	push   %eax
80109c8b:	e8 7e b7 ff ff       	call   8010540e <memmove>
80109c90:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c96:	83 c0 08             	add    $0x8,%eax
80109c99:	83 ec 04             	sub    $0x4,%esp
80109c9c:	6a 06                	push   $0x6
80109c9e:	68 b4 7a 19 80       	push   $0x80197ab4
80109ca3:	50                   	push   %eax
80109ca4:	e8 65 b7 ff ff       	call   8010540e <memmove>
80109ca9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109caf:	83 c0 0e             	add    $0xe,%eax
80109cb2:	83 ec 04             	sub    $0x4,%esp
80109cb5:	6a 04                	push   $0x4
80109cb7:	68 04 f5 10 80       	push   $0x8010f504
80109cbc:	50                   	push   %eax
80109cbd:	e8 4c b7 ff ff       	call   8010540e <memmove>
80109cc2:	83 c4 10             	add    $0x10,%esp
}
80109cc5:	90                   	nop
80109cc6:	c9                   	leave
80109cc7:	c3                   	ret

80109cc8 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109cc8:	55                   	push   %ebp
80109cc9:	89 e5                	mov    %esp,%ebp
80109ccb:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109cce:	83 ec 0c             	sub    $0xc,%esp
80109cd1:	68 82 cb 10 80       	push   $0x8010cb82
80109cd6:	e8 19 67 ff ff       	call   801003f4 <cprintf>
80109cdb:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109cde:	8b 45 08             	mov    0x8(%ebp),%eax
80109ce1:	83 c0 0e             	add    $0xe,%eax
80109ce4:	83 ec 0c             	sub    $0xc,%esp
80109ce7:	50                   	push   %eax
80109ce8:	e8 e8 00 00 00       	call   80109dd5 <print_ipv4>
80109ced:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109cf0:	83 ec 0c             	sub    $0xc,%esp
80109cf3:	68 80 cb 10 80       	push   $0x8010cb80
80109cf8:	e8 f7 66 ff ff       	call   801003f4 <cprintf>
80109cfd:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109d00:	8b 45 08             	mov    0x8(%ebp),%eax
80109d03:	83 c0 08             	add    $0x8,%eax
80109d06:	83 ec 0c             	sub    $0xc,%esp
80109d09:	50                   	push   %eax
80109d0a:	e8 14 01 00 00       	call   80109e23 <print_mac>
80109d0f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d12:	83 ec 0c             	sub    $0xc,%esp
80109d15:	68 80 cb 10 80       	push   $0x8010cb80
80109d1a:	e8 d5 66 ff ff       	call   801003f4 <cprintf>
80109d1f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109d22:	83 ec 0c             	sub    $0xc,%esp
80109d25:	68 99 cb 10 80       	push   $0x8010cb99
80109d2a:	e8 c5 66 ff ff       	call   801003f4 <cprintf>
80109d2f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109d32:	8b 45 08             	mov    0x8(%ebp),%eax
80109d35:	83 c0 18             	add    $0x18,%eax
80109d38:	83 ec 0c             	sub    $0xc,%esp
80109d3b:	50                   	push   %eax
80109d3c:	e8 94 00 00 00       	call   80109dd5 <print_ipv4>
80109d41:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d44:	83 ec 0c             	sub    $0xc,%esp
80109d47:	68 80 cb 10 80       	push   $0x8010cb80
80109d4c:	e8 a3 66 ff ff       	call   801003f4 <cprintf>
80109d51:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109d54:	8b 45 08             	mov    0x8(%ebp),%eax
80109d57:	83 c0 12             	add    $0x12,%eax
80109d5a:	83 ec 0c             	sub    $0xc,%esp
80109d5d:	50                   	push   %eax
80109d5e:	e8 c0 00 00 00       	call   80109e23 <print_mac>
80109d63:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d66:	83 ec 0c             	sub    $0xc,%esp
80109d69:	68 80 cb 10 80       	push   $0x8010cb80
80109d6e:	e8 81 66 ff ff       	call   801003f4 <cprintf>
80109d73:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109d76:	83 ec 0c             	sub    $0xc,%esp
80109d79:	68 b0 cb 10 80       	push   $0x8010cbb0
80109d7e:	e8 71 66 ff ff       	call   801003f4 <cprintf>
80109d83:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109d86:	8b 45 08             	mov    0x8(%ebp),%eax
80109d89:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d8d:	66 3d 00 01          	cmp    $0x100,%ax
80109d91:	75 12                	jne    80109da5 <print_arp_info+0xdd>
80109d93:	83 ec 0c             	sub    $0xc,%esp
80109d96:	68 bc cb 10 80       	push   $0x8010cbbc
80109d9b:	e8 54 66 ff ff       	call   801003f4 <cprintf>
80109da0:	83 c4 10             	add    $0x10,%esp
80109da3:	eb 1d                	jmp    80109dc2 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109da5:	8b 45 08             	mov    0x8(%ebp),%eax
80109da8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109dac:	66 3d 00 02          	cmp    $0x200,%ax
80109db0:	75 10                	jne    80109dc2 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109db2:	83 ec 0c             	sub    $0xc,%esp
80109db5:	68 c5 cb 10 80       	push   $0x8010cbc5
80109dba:	e8 35 66 ff ff       	call   801003f4 <cprintf>
80109dbf:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109dc2:	83 ec 0c             	sub    $0xc,%esp
80109dc5:	68 80 cb 10 80       	push   $0x8010cb80
80109dca:	e8 25 66 ff ff       	call   801003f4 <cprintf>
80109dcf:	83 c4 10             	add    $0x10,%esp
}
80109dd2:	90                   	nop
80109dd3:	c9                   	leave
80109dd4:	c3                   	ret

80109dd5 <print_ipv4>:

void print_ipv4(uchar *ip){
80109dd5:	55                   	push   %ebp
80109dd6:	89 e5                	mov    %esp,%ebp
80109dd8:	53                   	push   %ebx
80109dd9:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80109ddf:	83 c0 03             	add    $0x3,%eax
80109de2:	0f b6 00             	movzbl (%eax),%eax
80109de5:	0f b6 d8             	movzbl %al,%ebx
80109de8:	8b 45 08             	mov    0x8(%ebp),%eax
80109deb:	83 c0 02             	add    $0x2,%eax
80109dee:	0f b6 00             	movzbl (%eax),%eax
80109df1:	0f b6 c8             	movzbl %al,%ecx
80109df4:	8b 45 08             	mov    0x8(%ebp),%eax
80109df7:	83 c0 01             	add    $0x1,%eax
80109dfa:	0f b6 00             	movzbl (%eax),%eax
80109dfd:	0f b6 d0             	movzbl %al,%edx
80109e00:	8b 45 08             	mov    0x8(%ebp),%eax
80109e03:	0f b6 00             	movzbl (%eax),%eax
80109e06:	0f b6 c0             	movzbl %al,%eax
80109e09:	83 ec 0c             	sub    $0xc,%esp
80109e0c:	53                   	push   %ebx
80109e0d:	51                   	push   %ecx
80109e0e:	52                   	push   %edx
80109e0f:	50                   	push   %eax
80109e10:	68 cc cb 10 80       	push   $0x8010cbcc
80109e15:	e8 da 65 ff ff       	call   801003f4 <cprintf>
80109e1a:	83 c4 20             	add    $0x20,%esp
}
80109e1d:	90                   	nop
80109e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e21:	c9                   	leave
80109e22:	c3                   	ret

80109e23 <print_mac>:

void print_mac(uchar *mac){
80109e23:	55                   	push   %ebp
80109e24:	89 e5                	mov    %esp,%ebp
80109e26:	57                   	push   %edi
80109e27:	56                   	push   %esi
80109e28:	53                   	push   %ebx
80109e29:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2f:	83 c0 05             	add    $0x5,%eax
80109e32:	0f b6 00             	movzbl (%eax),%eax
80109e35:	0f b6 f8             	movzbl %al,%edi
80109e38:	8b 45 08             	mov    0x8(%ebp),%eax
80109e3b:	83 c0 04             	add    $0x4,%eax
80109e3e:	0f b6 00             	movzbl (%eax),%eax
80109e41:	0f b6 f0             	movzbl %al,%esi
80109e44:	8b 45 08             	mov    0x8(%ebp),%eax
80109e47:	83 c0 03             	add    $0x3,%eax
80109e4a:	0f b6 00             	movzbl (%eax),%eax
80109e4d:	0f b6 d8             	movzbl %al,%ebx
80109e50:	8b 45 08             	mov    0x8(%ebp),%eax
80109e53:	83 c0 02             	add    $0x2,%eax
80109e56:	0f b6 00             	movzbl (%eax),%eax
80109e59:	0f b6 c8             	movzbl %al,%ecx
80109e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e5f:	83 c0 01             	add    $0x1,%eax
80109e62:	0f b6 00             	movzbl (%eax),%eax
80109e65:	0f b6 d0             	movzbl %al,%edx
80109e68:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6b:	0f b6 00             	movzbl (%eax),%eax
80109e6e:	0f b6 c0             	movzbl %al,%eax
80109e71:	83 ec 04             	sub    $0x4,%esp
80109e74:	57                   	push   %edi
80109e75:	56                   	push   %esi
80109e76:	53                   	push   %ebx
80109e77:	51                   	push   %ecx
80109e78:	52                   	push   %edx
80109e79:	50                   	push   %eax
80109e7a:	68 e4 cb 10 80       	push   $0x8010cbe4
80109e7f:	e8 70 65 ff ff       	call   801003f4 <cprintf>
80109e84:	83 c4 20             	add    $0x20,%esp
}
80109e87:	90                   	nop
80109e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109e8b:	5b                   	pop    %ebx
80109e8c:	5e                   	pop    %esi
80109e8d:	5f                   	pop    %edi
80109e8e:	5d                   	pop    %ebp
80109e8f:	c3                   	ret

80109e90 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109e90:	55                   	push   %ebp
80109e91:	89 e5                	mov    %esp,%ebp
80109e93:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109e96:	8b 45 08             	mov    0x8(%ebp),%eax
80109e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e9f:	83 c0 0e             	add    $0xe,%eax
80109ea2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ea8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109eac:	3c 08                	cmp    $0x8,%al
80109eae:	75 1b                	jne    80109ecb <eth_proc+0x3b>
80109eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109eb7:	3c 06                	cmp    $0x6,%al
80109eb9:	75 10                	jne    80109ecb <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109ebb:	83 ec 0c             	sub    $0xc,%esp
80109ebe:	ff 75 f0             	push   -0x10(%ebp)
80109ec1:	e8 01 f8 ff ff       	call   801096c7 <arp_proc>
80109ec6:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109ec9:	eb 24                	jmp    80109eef <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ece:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ed2:	3c 08                	cmp    $0x8,%al
80109ed4:	75 19                	jne    80109eef <eth_proc+0x5f>
80109ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109edd:	84 c0                	test   %al,%al
80109edf:	75 0e                	jne    80109eef <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109ee1:	83 ec 0c             	sub    $0xc,%esp
80109ee4:	ff 75 08             	push   0x8(%ebp)
80109ee7:	e8 8d 00 00 00       	call   80109f79 <ipv4_proc>
80109eec:	83 c4 10             	add    $0x10,%esp
}
80109eef:	90                   	nop
80109ef0:	c9                   	leave
80109ef1:	c3                   	ret

80109ef2 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109ef2:	55                   	push   %ebp
80109ef3:	89 e5                	mov    %esp,%ebp
80109ef5:	83 ec 04             	sub    $0x4,%esp
80109ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80109efb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109eff:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109f03:	66 c1 c0 08          	rol    $0x8,%ax
}
80109f07:	c9                   	leave
80109f08:	c3                   	ret

80109f09 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109f09:	55                   	push   %ebp
80109f0a:	89 e5                	mov    %esp,%ebp
80109f0c:	83 ec 04             	sub    $0x4,%esp
80109f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f12:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109f16:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109f1a:	66 c1 c0 08          	rol    $0x8,%ax
}
80109f1e:	c9                   	leave
80109f1f:	c3                   	ret

80109f20 <H2N_uint>:

uint H2N_uint(uint value){
80109f20:	55                   	push   %ebp
80109f21:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109f23:	8b 45 08             	mov    0x8(%ebp),%eax
80109f26:	c1 e0 18             	shl    $0x18,%eax
80109f29:	25 00 00 00 0f       	and    $0xf000000,%eax
80109f2e:	89 c2                	mov    %eax,%edx
80109f30:	8b 45 08             	mov    0x8(%ebp),%eax
80109f33:	c1 e0 08             	shl    $0x8,%eax
80109f36:	25 00 f0 00 00       	and    $0xf000,%eax
80109f3b:	09 c2                	or     %eax,%edx
80109f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f40:	c1 e8 08             	shr    $0x8,%eax
80109f43:	83 e0 0f             	and    $0xf,%eax
80109f46:	01 d0                	add    %edx,%eax
}
80109f48:	5d                   	pop    %ebp
80109f49:	c3                   	ret

80109f4a <N2H_uint>:

uint N2H_uint(uint value){
80109f4a:	55                   	push   %ebp
80109f4b:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f50:	c1 e0 18             	shl    $0x18,%eax
80109f53:	89 c2                	mov    %eax,%edx
80109f55:	8b 45 08             	mov    0x8(%ebp),%eax
80109f58:	c1 e0 08             	shl    $0x8,%eax
80109f5b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109f60:	01 c2                	add    %eax,%edx
80109f62:	8b 45 08             	mov    0x8(%ebp),%eax
80109f65:	c1 e8 08             	shr    $0x8,%eax
80109f68:	25 00 ff 00 00       	and    $0xff00,%eax
80109f6d:	01 c2                	add    %eax,%edx
80109f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f72:	c1 e8 18             	shr    $0x18,%eax
80109f75:	01 d0                	add    %edx,%eax
}
80109f77:	5d                   	pop    %ebp
80109f78:	c3                   	ret

80109f79 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109f79:	55                   	push   %ebp
80109f7a:	89 e5                	mov    %esp,%ebp
80109f7c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f82:	83 c0 0e             	add    $0xe,%eax
80109f85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f8b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f8f:	0f b7 d0             	movzwl %ax,%edx
80109f92:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109f97:	39 c2                	cmp    %eax,%edx
80109f99:	74 60                	je     80109ffb <ipv4_proc+0x82>
80109f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f9e:	83 c0 0c             	add    $0xc,%eax
80109fa1:	83 ec 04             	sub    $0x4,%esp
80109fa4:	6a 04                	push   $0x4
80109fa6:	50                   	push   %eax
80109fa7:	68 04 f5 10 80       	push   $0x8010f504
80109fac:	e8 05 b4 ff ff       	call   801053b6 <memcmp>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	85 c0                	test   %eax,%eax
80109fb6:	74 43                	je     80109ffb <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109fbf:	0f b7 c0             	movzwl %ax,%eax
80109fc2:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fca:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109fce:	3c 01                	cmp    $0x1,%al
80109fd0:	75 10                	jne    80109fe2 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109fd2:	83 ec 0c             	sub    $0xc,%esp
80109fd5:	ff 75 08             	push   0x8(%ebp)
80109fd8:	e8 a3 00 00 00       	call   8010a080 <icmp_proc>
80109fdd:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109fe0:	eb 19                	jmp    80109ffb <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fe5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109fe9:	3c 06                	cmp    $0x6,%al
80109feb:	75 0e                	jne    80109ffb <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109fed:	83 ec 0c             	sub    $0xc,%esp
80109ff0:	ff 75 08             	push   0x8(%ebp)
80109ff3:	e8 b3 03 00 00       	call   8010a3ab <tcp_proc>
80109ff8:	83 c4 10             	add    $0x10,%esp
}
80109ffb:	90                   	nop
80109ffc:	c9                   	leave
80109ffd:	c3                   	ret

80109ffe <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109ffe:	55                   	push   %ebp
80109fff:	89 e5                	mov    %esp,%ebp
8010a001:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a004:	8b 45 08             	mov    0x8(%ebp),%eax
8010a007:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a00a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a00d:	0f b6 00             	movzbl (%eax),%eax
8010a010:	83 e0 0f             	and    $0xf,%eax
8010a013:	01 c0                	add    %eax,%eax
8010a015:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a018:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a01f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a026:	eb 48                	jmp    8010a070 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a028:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a02b:	01 c0                	add    %eax,%eax
8010a02d:	89 c2                	mov    %eax,%edx
8010a02f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a032:	01 d0                	add    %edx,%eax
8010a034:	0f b6 00             	movzbl (%eax),%eax
8010a037:	0f b6 c0             	movzbl %al,%eax
8010a03a:	c1 e0 08             	shl    $0x8,%eax
8010a03d:	89 c2                	mov    %eax,%edx
8010a03f:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a042:	01 c0                	add    %eax,%eax
8010a044:	8d 48 01             	lea    0x1(%eax),%ecx
8010a047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a04a:	01 c8                	add    %ecx,%eax
8010a04c:	0f b6 00             	movzbl (%eax),%eax
8010a04f:	0f b6 c0             	movzbl %al,%eax
8010a052:	01 d0                	add    %edx,%eax
8010a054:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a057:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a05e:	76 0c                	jbe    8010a06c <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a060:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a063:	0f b7 c0             	movzwl %ax,%eax
8010a066:	83 c0 01             	add    $0x1,%eax
8010a069:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a06c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a070:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a074:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a077:	7c af                	jl     8010a028 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010a079:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a07c:	f7 d0                	not    %eax
}
8010a07e:	c9                   	leave
8010a07f:	c3                   	ret

8010a080 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a080:	55                   	push   %ebp
8010a081:	89 e5                	mov    %esp,%ebp
8010a083:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a086:	8b 45 08             	mov    0x8(%ebp),%eax
8010a089:	83 c0 0e             	add    $0xe,%eax
8010a08c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a08f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a092:	0f b6 00             	movzbl (%eax),%eax
8010a095:	0f b6 c0             	movzbl %al,%eax
8010a098:	83 e0 0f             	and    $0xf,%eax
8010a09b:	c1 e0 02             	shl    $0x2,%eax
8010a09e:	89 c2                	mov    %eax,%edx
8010a0a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a3:	01 d0                	add    %edx,%eax
8010a0a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a0a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ab:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a0af:	84 c0                	test   %al,%al
8010a0b1:	75 4f                	jne    8010a102 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a0b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b6:	0f b6 00             	movzbl (%eax),%eax
8010a0b9:	3c 08                	cmp    $0x8,%al
8010a0bb:	75 45                	jne    8010a102 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a0bd:	e8 e6 86 ff ff       	call   801027a8 <kalloc>
8010a0c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a0c5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a0cc:	83 ec 04             	sub    $0x4,%esp
8010a0cf:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a0d2:	50                   	push   %eax
8010a0d3:	ff 75 ec             	push   -0x14(%ebp)
8010a0d6:	ff 75 08             	push   0x8(%ebp)
8010a0d9:	e8 78 00 00 00       	call   8010a156 <icmp_reply_pkt_create>
8010a0de:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a0e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e4:	83 ec 08             	sub    $0x8,%esp
8010a0e7:	50                   	push   %eax
8010a0e8:	ff 75 ec             	push   -0x14(%ebp)
8010a0eb:	e8 ad f4 ff ff       	call   8010959d <i8254_send>
8010a0f0:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a0f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0f6:	83 ec 0c             	sub    $0xc,%esp
8010a0f9:	50                   	push   %eax
8010a0fa:	e8 0f 86 ff ff       	call   8010270e <kfree>
8010a0ff:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a102:	90                   	nop
8010a103:	c9                   	leave
8010a104:	c3                   	ret

8010a105 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a105:	55                   	push   %ebp
8010a106:	89 e5                	mov    %esp,%ebp
8010a108:	53                   	push   %ebx
8010a109:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a10c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a10f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a113:	0f b7 c0             	movzwl %ax,%eax
8010a116:	83 ec 0c             	sub    $0xc,%esp
8010a119:	50                   	push   %eax
8010a11a:	e8 d3 fd ff ff       	call   80109ef2 <N2H_ushort>
8010a11f:	83 c4 10             	add    $0x10,%esp
8010a122:	0f b7 d8             	movzwl %ax,%ebx
8010a125:	8b 45 08             	mov    0x8(%ebp),%eax
8010a128:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a12c:	0f b7 c0             	movzwl %ax,%eax
8010a12f:	83 ec 0c             	sub    $0xc,%esp
8010a132:	50                   	push   %eax
8010a133:	e8 ba fd ff ff       	call   80109ef2 <N2H_ushort>
8010a138:	83 c4 10             	add    $0x10,%esp
8010a13b:	0f b7 c0             	movzwl %ax,%eax
8010a13e:	83 ec 04             	sub    $0x4,%esp
8010a141:	53                   	push   %ebx
8010a142:	50                   	push   %eax
8010a143:	68 03 cc 10 80       	push   $0x8010cc03
8010a148:	e8 a7 62 ff ff       	call   801003f4 <cprintf>
8010a14d:	83 c4 10             	add    $0x10,%esp
}
8010a150:	90                   	nop
8010a151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a154:	c9                   	leave
8010a155:	c3                   	ret

8010a156 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a156:	55                   	push   %ebp
8010a157:	89 e5                	mov    %esp,%ebp
8010a159:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a15c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a15f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a162:	8b 45 08             	mov    0x8(%ebp),%eax
8010a165:	83 c0 0e             	add    $0xe,%eax
8010a168:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a16b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a16e:	0f b6 00             	movzbl (%eax),%eax
8010a171:	0f b6 c0             	movzbl %al,%eax
8010a174:	83 e0 0f             	and    $0xf,%eax
8010a177:	c1 e0 02             	shl    $0x2,%eax
8010a17a:	89 c2                	mov    %eax,%edx
8010a17c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a17f:	01 d0                	add    %edx,%eax
8010a181:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a184:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a187:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a18a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a18d:	83 c0 0e             	add    $0xe,%eax
8010a190:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a196:	83 c0 14             	add    $0x14,%eax
8010a199:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a19c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a19f:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1a8:	8d 50 06             	lea    0x6(%eax),%edx
8010a1ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1ae:	83 ec 04             	sub    $0x4,%esp
8010a1b1:	6a 06                	push   $0x6
8010a1b3:	52                   	push   %edx
8010a1b4:	50                   	push   %eax
8010a1b5:	e8 54 b2 ff ff       	call   8010540e <memmove>
8010a1ba:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a1bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c0:	83 c0 06             	add    $0x6,%eax
8010a1c3:	83 ec 04             	sub    $0x4,%esp
8010a1c6:	6a 06                	push   $0x6
8010a1c8:	68 b4 7a 19 80       	push   $0x80197ab4
8010a1cd:	50                   	push   %eax
8010a1ce:	e8 3b b2 ff ff       	call   8010540e <memmove>
8010a1d3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a1d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1d9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a1dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a1e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a1ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1ed:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a1f1:	83 ec 0c             	sub    $0xc,%esp
8010a1f4:	6a 54                	push   $0x54
8010a1f6:	e8 0e fd ff ff       	call   80109f09 <H2N_ushort>
8010a1fb:	83 c4 10             	add    $0x10,%esp
8010a1fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a201:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a205:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a20c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a20f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a213:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a21a:	83 c0 01             	add    $0x1,%eax
8010a21d:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a223:	83 ec 0c             	sub    $0xc,%esp
8010a226:	68 00 40 00 00       	push   $0x4000
8010a22b:	e8 d9 fc ff ff       	call   80109f09 <H2N_ushort>
8010a230:	83 c4 10             	add    $0x10,%esp
8010a233:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a236:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a23a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a23d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a244:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a248:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a24b:	83 c0 0c             	add    $0xc,%eax
8010a24e:	83 ec 04             	sub    $0x4,%esp
8010a251:	6a 04                	push   $0x4
8010a253:	68 04 f5 10 80       	push   $0x8010f504
8010a258:	50                   	push   %eax
8010a259:	e8 b0 b1 ff ff       	call   8010540e <memmove>
8010a25e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a261:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a264:	8d 50 0c             	lea    0xc(%eax),%edx
8010a267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a26a:	83 c0 10             	add    $0x10,%eax
8010a26d:	83 ec 04             	sub    $0x4,%esp
8010a270:	6a 04                	push   $0x4
8010a272:	52                   	push   %edx
8010a273:	50                   	push   %eax
8010a274:	e8 95 b1 ff ff       	call   8010540e <memmove>
8010a279:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a27c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a288:	83 ec 0c             	sub    $0xc,%esp
8010a28b:	50                   	push   %eax
8010a28c:	e8 6d fd ff ff       	call   80109ffe <ipv4_chksum>
8010a291:	83 c4 10             	add    $0x10,%esp
8010a294:	0f b7 c0             	movzwl %ax,%eax
8010a297:	83 ec 0c             	sub    $0xc,%esp
8010a29a:	50                   	push   %eax
8010a29b:	e8 69 fc ff ff       	call   80109f09 <H2N_ushort>
8010a2a0:	83 c4 10             	add    $0x10,%esp
8010a2a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2a6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a2aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ad:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a2b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a2b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2ba:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a2be:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2c1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a2c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2c8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a2cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2cf:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a2d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2d6:	8d 50 08             	lea    0x8(%eax),%edx
8010a2d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2dc:	83 c0 08             	add    $0x8,%eax
8010a2df:	83 ec 04             	sub    $0x4,%esp
8010a2e2:	6a 08                	push   $0x8
8010a2e4:	52                   	push   %edx
8010a2e5:	50                   	push   %eax
8010a2e6:	e8 23 b1 ff ff       	call   8010540e <memmove>
8010a2eb:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a2ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2f1:	8d 50 10             	lea    0x10(%eax),%edx
8010a2f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2f7:	83 c0 10             	add    $0x10,%eax
8010a2fa:	83 ec 04             	sub    $0x4,%esp
8010a2fd:	6a 30                	push   $0x30
8010a2ff:	52                   	push   %edx
8010a300:	50                   	push   %eax
8010a301:	e8 08 b1 ff ff       	call   8010540e <memmove>
8010a306:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a309:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a30c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a312:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a315:	83 ec 0c             	sub    $0xc,%esp
8010a318:	50                   	push   %eax
8010a319:	e8 1c 00 00 00       	call   8010a33a <icmp_chksum>
8010a31e:	83 c4 10             	add    $0x10,%esp
8010a321:	0f b7 c0             	movzwl %ax,%eax
8010a324:	83 ec 0c             	sub    $0xc,%esp
8010a327:	50                   	push   %eax
8010a328:	e8 dc fb ff ff       	call   80109f09 <H2N_ushort>
8010a32d:	83 c4 10             	add    $0x10,%esp
8010a330:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a333:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a337:	90                   	nop
8010a338:	c9                   	leave
8010a339:	c3                   	ret

8010a33a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a33a:	55                   	push   %ebp
8010a33b:	89 e5                	mov    %esp,%ebp
8010a33d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a340:	8b 45 08             	mov    0x8(%ebp),%eax
8010a343:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a346:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a34d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a354:	eb 48                	jmp    8010a39e <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a356:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a359:	01 c0                	add    %eax,%eax
8010a35b:	89 c2                	mov    %eax,%edx
8010a35d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a360:	01 d0                	add    %edx,%eax
8010a362:	0f b6 00             	movzbl (%eax),%eax
8010a365:	0f b6 c0             	movzbl %al,%eax
8010a368:	c1 e0 08             	shl    $0x8,%eax
8010a36b:	89 c2                	mov    %eax,%edx
8010a36d:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a370:	01 c0                	add    %eax,%eax
8010a372:	8d 48 01             	lea    0x1(%eax),%ecx
8010a375:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a378:	01 c8                	add    %ecx,%eax
8010a37a:	0f b6 00             	movzbl (%eax),%eax
8010a37d:	0f b6 c0             	movzbl %al,%eax
8010a380:	01 d0                	add    %edx,%eax
8010a382:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a385:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a38c:	76 0c                	jbe    8010a39a <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a38e:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a391:	0f b7 c0             	movzwl %ax,%eax
8010a394:	83 c0 01             	add    $0x1,%eax
8010a397:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a39a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a39e:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a3a2:	7e b2                	jle    8010a356 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a3a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a3a7:	f7 d0                	not    %eax
}
8010a3a9:	c9                   	leave
8010a3aa:	c3                   	ret

8010a3ab <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a3ab:	55                   	push   %ebp
8010a3ac:	89 e5                	mov    %esp,%ebp
8010a3ae:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a3b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3b4:	83 c0 0e             	add    $0xe,%eax
8010a3b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a3ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3bd:	0f b6 00             	movzbl (%eax),%eax
8010a3c0:	0f b6 c0             	movzbl %al,%eax
8010a3c3:	83 e0 0f             	and    $0xf,%eax
8010a3c6:	c1 e0 02             	shl    $0x2,%eax
8010a3c9:	89 c2                	mov    %eax,%edx
8010a3cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3ce:	01 d0                	add    %edx,%eax
8010a3d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a3d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3d6:	83 c0 14             	add    $0x14,%eax
8010a3d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a3dc:	e8 c7 83 ff ff       	call   801027a8 <kalloc>
8010a3e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a3e4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a3eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3ee:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3f2:	0f b6 c0             	movzbl %al,%eax
8010a3f5:	83 e0 02             	and    $0x2,%eax
8010a3f8:	85 c0                	test   %eax,%eax
8010a3fa:	74 3d                	je     8010a439 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a3fc:	83 ec 0c             	sub    $0xc,%esp
8010a3ff:	6a 00                	push   $0x0
8010a401:	6a 12                	push   $0x12
8010a403:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a406:	50                   	push   %eax
8010a407:	ff 75 e8             	push   -0x18(%ebp)
8010a40a:	ff 75 08             	push   0x8(%ebp)
8010a40d:	e8 a2 01 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a412:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a415:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a418:	83 ec 08             	sub    $0x8,%esp
8010a41b:	50                   	push   %eax
8010a41c:	ff 75 e8             	push   -0x18(%ebp)
8010a41f:	e8 79 f1 ff ff       	call   8010959d <i8254_send>
8010a424:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a427:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a42c:	83 c0 01             	add    $0x1,%eax
8010a42f:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a434:	e9 69 01 00 00       	jmp    8010a5a2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a43c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a440:	3c 18                	cmp    $0x18,%al
8010a442:	0f 85 10 01 00 00    	jne    8010a558 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a448:	83 ec 04             	sub    $0x4,%esp
8010a44b:	6a 03                	push   $0x3
8010a44d:	68 1e cc 10 80       	push   $0x8010cc1e
8010a452:	ff 75 ec             	push   -0x14(%ebp)
8010a455:	e8 5c af ff ff       	call   801053b6 <memcmp>
8010a45a:	83 c4 10             	add    $0x10,%esp
8010a45d:	85 c0                	test   %eax,%eax
8010a45f:	74 74                	je     8010a4d5 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a461:	83 ec 0c             	sub    $0xc,%esp
8010a464:	68 22 cc 10 80       	push   $0x8010cc22
8010a469:	e8 86 5f ff ff       	call   801003f4 <cprintf>
8010a46e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a471:	83 ec 0c             	sub    $0xc,%esp
8010a474:	6a 00                	push   $0x0
8010a476:	6a 10                	push   $0x10
8010a478:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a47b:	50                   	push   %eax
8010a47c:	ff 75 e8             	push   -0x18(%ebp)
8010a47f:	ff 75 08             	push   0x8(%ebp)
8010a482:	e8 2d 01 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a487:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a48a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a48d:	83 ec 08             	sub    $0x8,%esp
8010a490:	50                   	push   %eax
8010a491:	ff 75 e8             	push   -0x18(%ebp)
8010a494:	e8 04 f1 ff ff       	call   8010959d <i8254_send>
8010a499:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a49c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a49f:	83 c0 36             	add    $0x36,%eax
8010a4a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a4a5:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a4a8:	50                   	push   %eax
8010a4a9:	ff 75 e0             	push   -0x20(%ebp)
8010a4ac:	6a 00                	push   $0x0
8010a4ae:	6a 00                	push   $0x0
8010a4b0:	e8 5a 04 00 00       	call   8010a90f <http_proc>
8010a4b5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a4b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a4bb:	83 ec 0c             	sub    $0xc,%esp
8010a4be:	50                   	push   %eax
8010a4bf:	6a 18                	push   $0x18
8010a4c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4c4:	50                   	push   %eax
8010a4c5:	ff 75 e8             	push   -0x18(%ebp)
8010a4c8:	ff 75 08             	push   0x8(%ebp)
8010a4cb:	e8 e4 00 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a4d0:	83 c4 20             	add    $0x20,%esp
8010a4d3:	eb 62                	jmp    8010a537 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a4d5:	83 ec 0c             	sub    $0xc,%esp
8010a4d8:	6a 00                	push   $0x0
8010a4da:	6a 10                	push   $0x10
8010a4dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4df:	50                   	push   %eax
8010a4e0:	ff 75 e8             	push   -0x18(%ebp)
8010a4e3:	ff 75 08             	push   0x8(%ebp)
8010a4e6:	e8 c9 00 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a4eb:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a4ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a4f1:	83 ec 08             	sub    $0x8,%esp
8010a4f4:	50                   	push   %eax
8010a4f5:	ff 75 e8             	push   -0x18(%ebp)
8010a4f8:	e8 a0 f0 ff ff       	call   8010959d <i8254_send>
8010a4fd:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a500:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a503:	83 c0 36             	add    $0x36,%eax
8010a506:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a509:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a50c:	50                   	push   %eax
8010a50d:	ff 75 e4             	push   -0x1c(%ebp)
8010a510:	6a 00                	push   $0x0
8010a512:	6a 00                	push   $0x0
8010a514:	e8 f6 03 00 00       	call   8010a90f <http_proc>
8010a519:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a51c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a51f:	83 ec 0c             	sub    $0xc,%esp
8010a522:	50                   	push   %eax
8010a523:	6a 18                	push   $0x18
8010a525:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a528:	50                   	push   %eax
8010a529:	ff 75 e8             	push   -0x18(%ebp)
8010a52c:	ff 75 08             	push   0x8(%ebp)
8010a52f:	e8 80 00 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a534:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a537:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a53a:	83 ec 08             	sub    $0x8,%esp
8010a53d:	50                   	push   %eax
8010a53e:	ff 75 e8             	push   -0x18(%ebp)
8010a541:	e8 57 f0 ff ff       	call   8010959d <i8254_send>
8010a546:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a549:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a54e:	83 c0 01             	add    $0x1,%eax
8010a551:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a556:	eb 4a                	jmp    8010a5a2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a55b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a55f:	3c 10                	cmp    $0x10,%al
8010a561:	75 3f                	jne    8010a5a2 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a563:	a1 88 7d 19 80       	mov    0x80197d88,%eax
8010a568:	83 f8 01             	cmp    $0x1,%eax
8010a56b:	75 35                	jne    8010a5a2 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a56d:	83 ec 0c             	sub    $0xc,%esp
8010a570:	6a 00                	push   $0x0
8010a572:	6a 01                	push   $0x1
8010a574:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a577:	50                   	push   %eax
8010a578:	ff 75 e8             	push   -0x18(%ebp)
8010a57b:	ff 75 08             	push   0x8(%ebp)
8010a57e:	e8 31 00 00 00       	call   8010a5b4 <tcp_pkt_create>
8010a583:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a586:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a589:	83 ec 08             	sub    $0x8,%esp
8010a58c:	50                   	push   %eax
8010a58d:	ff 75 e8             	push   -0x18(%ebp)
8010a590:	e8 08 f0 ff ff       	call   8010959d <i8254_send>
8010a595:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a598:	c7 05 88 7d 19 80 00 	movl   $0x0,0x80197d88
8010a59f:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5a5:	83 ec 0c             	sub    $0xc,%esp
8010a5a8:	50                   	push   %eax
8010a5a9:	e8 60 81 ff ff       	call   8010270e <kfree>
8010a5ae:	83 c4 10             	add    $0x10,%esp
}
8010a5b1:	90                   	nop
8010a5b2:	c9                   	leave
8010a5b3:	c3                   	ret

8010a5b4 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a5b4:	55                   	push   %ebp
8010a5b5:	89 e5                	mov    %esp,%ebp
8010a5b7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a5ba:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a5c0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5c3:	83 c0 0e             	add    $0xe,%eax
8010a5c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a5c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5cc:	0f b6 00             	movzbl (%eax),%eax
8010a5cf:	0f b6 c0             	movzbl %al,%eax
8010a5d2:	83 e0 0f             	and    $0xf,%eax
8010a5d5:	c1 e0 02             	shl    $0x2,%eax
8010a5d8:	89 c2                	mov    %eax,%edx
8010a5da:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5dd:	01 d0                	add    %edx,%eax
8010a5df:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a5e2:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a5e8:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5eb:	83 c0 0e             	add    $0xe,%eax
8010a5ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a5f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5f4:	83 c0 14             	add    $0x14,%eax
8010a5f7:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a5fa:	8b 45 18             	mov    0x18(%ebp),%eax
8010a5fd:	8d 50 36             	lea    0x36(%eax),%edx
8010a600:	8b 45 10             	mov    0x10(%ebp),%eax
8010a603:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a605:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a608:	8d 50 06             	lea    0x6(%eax),%edx
8010a60b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a60e:	83 ec 04             	sub    $0x4,%esp
8010a611:	6a 06                	push   $0x6
8010a613:	52                   	push   %edx
8010a614:	50                   	push   %eax
8010a615:	e8 f4 ad ff ff       	call   8010540e <memmove>
8010a61a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a61d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a620:	83 c0 06             	add    $0x6,%eax
8010a623:	83 ec 04             	sub    $0x4,%esp
8010a626:	6a 06                	push   $0x6
8010a628:	68 b4 7a 19 80       	push   $0x80197ab4
8010a62d:	50                   	push   %eax
8010a62e:	e8 db ad ff ff       	call   8010540e <memmove>
8010a633:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a636:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a639:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a63d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a640:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a647:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a64d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a651:	8b 45 18             	mov    0x18(%ebp),%eax
8010a654:	83 c0 28             	add    $0x28,%eax
8010a657:	0f b7 c0             	movzwl %ax,%eax
8010a65a:	83 ec 0c             	sub    $0xc,%esp
8010a65d:	50                   	push   %eax
8010a65e:	e8 a6 f8 ff ff       	call   80109f09 <H2N_ushort>
8010a663:	83 c4 10             	add    $0x10,%esp
8010a666:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a669:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a66d:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a677:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a67b:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a682:	83 c0 01             	add    $0x1,%eax
8010a685:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a68b:	83 ec 0c             	sub    $0xc,%esp
8010a68e:	6a 00                	push   $0x0
8010a690:	e8 74 f8 ff ff       	call   80109f09 <H2N_ushort>
8010a695:	83 c4 10             	add    $0x10,%esp
8010a698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a69b:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a69f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6a2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a6a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6a9:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a6ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6b0:	83 c0 0c             	add    $0xc,%eax
8010a6b3:	83 ec 04             	sub    $0x4,%esp
8010a6b6:	6a 04                	push   $0x4
8010a6b8:	68 04 f5 10 80       	push   $0x8010f504
8010a6bd:	50                   	push   %eax
8010a6be:	e8 4b ad ff ff       	call   8010540e <memmove>
8010a6c3:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a6c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6c9:	8d 50 0c             	lea    0xc(%eax),%edx
8010a6cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6cf:	83 c0 10             	add    $0x10,%eax
8010a6d2:	83 ec 04             	sub    $0x4,%esp
8010a6d5:	6a 04                	push   $0x4
8010a6d7:	52                   	push   %edx
8010a6d8:	50                   	push   %eax
8010a6d9:	e8 30 ad ff ff       	call   8010540e <memmove>
8010a6de:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a6e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6e4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a6ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6ed:	83 ec 0c             	sub    $0xc,%esp
8010a6f0:	50                   	push   %eax
8010a6f1:	e8 08 f9 ff ff       	call   80109ffe <ipv4_chksum>
8010a6f6:	83 c4 10             	add    $0x10,%esp
8010a6f9:	0f b7 c0             	movzwl %ax,%eax
8010a6fc:	83 ec 0c             	sub    $0xc,%esp
8010a6ff:	50                   	push   %eax
8010a700:	e8 04 f8 ff ff       	call   80109f09 <H2N_ushort>
8010a705:	83 c4 10             	add    $0x10,%esp
8010a708:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a70b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a70f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a712:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a716:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a719:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a71c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a71f:	0f b7 10             	movzwl (%eax),%edx
8010a722:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a725:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a729:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a72e:	83 ec 0c             	sub    $0xc,%esp
8010a731:	50                   	push   %eax
8010a732:	e8 e9 f7 ff ff       	call   80109f20 <H2N_uint>
8010a737:	83 c4 10             	add    $0x10,%esp
8010a73a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a73d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a740:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a743:	8b 40 04             	mov    0x4(%eax),%eax
8010a746:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a74c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a74f:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a752:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a755:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a759:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a75c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a760:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a763:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a767:	8b 45 14             	mov    0x14(%ebp),%eax
8010a76a:	89 c2                	mov    %eax,%edx
8010a76c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a76f:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a772:	83 ec 0c             	sub    $0xc,%esp
8010a775:	68 90 38 00 00       	push   $0x3890
8010a77a:	e8 8a f7 ff ff       	call   80109f09 <H2N_ushort>
8010a77f:	83 c4 10             	add    $0x10,%esp
8010a782:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a785:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a789:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a78c:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a792:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a795:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a79b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a79e:	83 ec 0c             	sub    $0xc,%esp
8010a7a1:	50                   	push   %eax
8010a7a2:	e8 1f 00 00 00       	call   8010a7c6 <tcp_chksum>
8010a7a7:	83 c4 10             	add    $0x10,%esp
8010a7aa:	83 c0 08             	add    $0x8,%eax
8010a7ad:	0f b7 c0             	movzwl %ax,%eax
8010a7b0:	83 ec 0c             	sub    $0xc,%esp
8010a7b3:	50                   	push   %eax
8010a7b4:	e8 50 f7 ff ff       	call   80109f09 <H2N_ushort>
8010a7b9:	83 c4 10             	add    $0x10,%esp
8010a7bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a7bf:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a7c3:	90                   	nop
8010a7c4:	c9                   	leave
8010a7c5:	c3                   	ret

8010a7c6 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a7c6:	55                   	push   %ebp
8010a7c7:	89 e5                	mov    %esp,%ebp
8010a7c9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a7cc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a7d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a7d5:	83 c0 14             	add    $0x14,%eax
8010a7d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a7db:	83 ec 04             	sub    $0x4,%esp
8010a7de:	6a 04                	push   $0x4
8010a7e0:	68 04 f5 10 80       	push   $0x8010f504
8010a7e5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a7e8:	50                   	push   %eax
8010a7e9:	e8 20 ac ff ff       	call   8010540e <memmove>
8010a7ee:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a7f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a7f4:	83 c0 0c             	add    $0xc,%eax
8010a7f7:	83 ec 04             	sub    $0x4,%esp
8010a7fa:	6a 04                	push   $0x4
8010a7fc:	50                   	push   %eax
8010a7fd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a800:	83 c0 04             	add    $0x4,%eax
8010a803:	50                   	push   %eax
8010a804:	e8 05 ac ff ff       	call   8010540e <memmove>
8010a809:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a80c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a810:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a814:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a817:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a81b:	0f b7 c0             	movzwl %ax,%eax
8010a81e:	83 ec 0c             	sub    $0xc,%esp
8010a821:	50                   	push   %eax
8010a822:	e8 cb f6 ff ff       	call   80109ef2 <N2H_ushort>
8010a827:	83 c4 10             	add    $0x10,%esp
8010a82a:	83 e8 14             	sub    $0x14,%eax
8010a82d:	0f b7 c0             	movzwl %ax,%eax
8010a830:	83 ec 0c             	sub    $0xc,%esp
8010a833:	50                   	push   %eax
8010a834:	e8 d0 f6 ff ff       	call   80109f09 <H2N_ushort>
8010a839:	83 c4 10             	add    $0x10,%esp
8010a83c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a840:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a847:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a84a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a84d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a854:	eb 33                	jmp    8010a889 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a856:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a859:	01 c0                	add    %eax,%eax
8010a85b:	89 c2                	mov    %eax,%edx
8010a85d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a860:	01 d0                	add    %edx,%eax
8010a862:	0f b6 00             	movzbl (%eax),%eax
8010a865:	0f b6 c0             	movzbl %al,%eax
8010a868:	c1 e0 08             	shl    $0x8,%eax
8010a86b:	89 c2                	mov    %eax,%edx
8010a86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a870:	01 c0                	add    %eax,%eax
8010a872:	8d 48 01             	lea    0x1(%eax),%ecx
8010a875:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a878:	01 c8                	add    %ecx,%eax
8010a87a:	0f b6 00             	movzbl (%eax),%eax
8010a87d:	0f b6 c0             	movzbl %al,%eax
8010a880:	01 d0                	add    %edx,%eax
8010a882:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a885:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a889:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a88d:	7e c7                	jle    8010a856 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a88f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a892:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a895:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a89c:	eb 33                	jmp    8010a8d1 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a89e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a8a1:	01 c0                	add    %eax,%eax
8010a8a3:	89 c2                	mov    %eax,%edx
8010a8a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a8a8:	01 d0                	add    %edx,%eax
8010a8aa:	0f b6 00             	movzbl (%eax),%eax
8010a8ad:	0f b6 c0             	movzbl %al,%eax
8010a8b0:	c1 e0 08             	shl    $0x8,%eax
8010a8b3:	89 c2                	mov    %eax,%edx
8010a8b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a8b8:	01 c0                	add    %eax,%eax
8010a8ba:	8d 48 01             	lea    0x1(%eax),%ecx
8010a8bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a8c0:	01 c8                	add    %ecx,%eax
8010a8c2:	0f b6 00             	movzbl (%eax),%eax
8010a8c5:	0f b6 c0             	movzbl %al,%eax
8010a8c8:	01 d0                	add    %edx,%eax
8010a8ca:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a8cd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a8d1:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a8d5:	0f b7 c0             	movzwl %ax,%eax
8010a8d8:	83 ec 0c             	sub    $0xc,%esp
8010a8db:	50                   	push   %eax
8010a8dc:	e8 11 f6 ff ff       	call   80109ef2 <N2H_ushort>
8010a8e1:	83 c4 10             	add    $0x10,%esp
8010a8e4:	66 d1 e8             	shr    $1,%ax
8010a8e7:	0f b7 c0             	movzwl %ax,%eax
8010a8ea:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a8ed:	7c af                	jl     8010a89e <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a8f2:	c1 e8 10             	shr    $0x10,%eax
8010a8f5:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a8f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a8fb:	f7 d0                	not    %eax
}
8010a8fd:	c9                   	leave
8010a8fe:	c3                   	ret

8010a8ff <tcp_fin>:

void tcp_fin(){
8010a8ff:	55                   	push   %ebp
8010a900:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a902:	c7 05 88 7d 19 80 01 	movl   $0x1,0x80197d88
8010a909:	00 00 00 
}
8010a90c:	90                   	nop
8010a90d:	5d                   	pop    %ebp
8010a90e:	c3                   	ret

8010a90f <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a90f:	55                   	push   %ebp
8010a910:	89 e5                	mov    %esp,%ebp
8010a912:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a915:	8b 45 10             	mov    0x10(%ebp),%eax
8010a918:	83 ec 04             	sub    $0x4,%esp
8010a91b:	6a 00                	push   $0x0
8010a91d:	68 2b cc 10 80       	push   $0x8010cc2b
8010a922:	50                   	push   %eax
8010a923:	e8 65 00 00 00       	call   8010a98d <http_strcpy>
8010a928:	83 c4 10             	add    $0x10,%esp
8010a92b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a92e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a931:	83 ec 04             	sub    $0x4,%esp
8010a934:	ff 75 f4             	push   -0xc(%ebp)
8010a937:	68 3e cc 10 80       	push   $0x8010cc3e
8010a93c:	50                   	push   %eax
8010a93d:	e8 4b 00 00 00       	call   8010a98d <http_strcpy>
8010a942:	83 c4 10             	add    $0x10,%esp
8010a945:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a948:	8b 45 10             	mov    0x10(%ebp),%eax
8010a94b:	83 ec 04             	sub    $0x4,%esp
8010a94e:	ff 75 f4             	push   -0xc(%ebp)
8010a951:	68 59 cc 10 80       	push   $0x8010cc59
8010a956:	50                   	push   %eax
8010a957:	e8 31 00 00 00       	call   8010a98d <http_strcpy>
8010a95c:	83 c4 10             	add    $0x10,%esp
8010a95f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a962:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a965:	83 e0 01             	and    $0x1,%eax
8010a968:	85 c0                	test   %eax,%eax
8010a96a:	74 11                	je     8010a97d <http_proc+0x6e>
    char *payload = (char *)send;
8010a96c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a96f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a972:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a975:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a978:	01 d0                	add    %edx,%eax
8010a97a:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a97d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a980:	8b 45 14             	mov    0x14(%ebp),%eax
8010a983:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a985:	e8 75 ff ff ff       	call   8010a8ff <tcp_fin>
}
8010a98a:	90                   	nop
8010a98b:	c9                   	leave
8010a98c:	c3                   	ret

8010a98d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a98d:	55                   	push   %ebp
8010a98e:	89 e5                	mov    %esp,%ebp
8010a990:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a993:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a99a:	eb 20                	jmp    8010a9bc <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a99c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a99f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a9a2:	01 d0                	add    %edx,%eax
8010a9a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a9a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a9aa:	01 ca                	add    %ecx,%edx
8010a9ac:	89 d1                	mov    %edx,%ecx
8010a9ae:	8b 55 08             	mov    0x8(%ebp),%edx
8010a9b1:	01 ca                	add    %ecx,%edx
8010a9b3:	0f b6 00             	movzbl (%eax),%eax
8010a9b6:	88 02                	mov    %al,(%edx)
    i++;
8010a9b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a9bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a9bf:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a9c2:	01 d0                	add    %edx,%eax
8010a9c4:	0f b6 00             	movzbl (%eax),%eax
8010a9c7:	84 c0                	test   %al,%al
8010a9c9:	75 d1                	jne    8010a99c <http_strcpy+0xf>
  }
  return i;
8010a9cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a9ce:	c9                   	leave
8010a9cf:	c3                   	ret

8010a9d0 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a9d0:	55                   	push   %ebp
8010a9d1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a9d3:	c7 05 90 7d 19 80 c2 	movl   $0x8010f5c2,0x80197d90
8010a9da:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a9dd:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a9e2:	c1 e8 09             	shr    $0x9,%eax
8010a9e5:	a3 8c 7d 19 80       	mov    %eax,0x80197d8c
}
8010a9ea:	90                   	nop
8010a9eb:	5d                   	pop    %ebp
8010a9ec:	c3                   	ret

8010a9ed <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a9ed:	55                   	push   %ebp
8010a9ee:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a9f0:	90                   	nop
8010a9f1:	5d                   	pop    %ebp
8010a9f2:	c3                   	ret

8010a9f3 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a9f3:	55                   	push   %ebp
8010a9f4:	89 e5                	mov    %esp,%ebp
8010a9f6:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a9f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9fc:	83 c0 0c             	add    $0xc,%eax
8010a9ff:	83 ec 0c             	sub    $0xc,%esp
8010aa02:	50                   	push   %eax
8010aa03:	e8 40 a6 ff ff       	call   80105048 <holdingsleep>
8010aa08:	83 c4 10             	add    $0x10,%esp
8010aa0b:	85 c0                	test   %eax,%eax
8010aa0d:	75 0d                	jne    8010aa1c <iderw+0x29>
    panic("iderw: buf not locked");
8010aa0f:	83 ec 0c             	sub    $0xc,%esp
8010aa12:	68 6a cc 10 80       	push   $0x8010cc6a
8010aa17:	e8 8d 5b ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010aa1c:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa1f:	8b 00                	mov    (%eax),%eax
8010aa21:	83 e0 06             	and    $0x6,%eax
8010aa24:	83 f8 02             	cmp    $0x2,%eax
8010aa27:	75 0d                	jne    8010aa36 <iderw+0x43>
    panic("iderw: nothing to do");
8010aa29:	83 ec 0c             	sub    $0xc,%esp
8010aa2c:	68 80 cc 10 80       	push   $0x8010cc80
8010aa31:	e8 73 5b ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010aa36:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa39:	8b 40 04             	mov    0x4(%eax),%eax
8010aa3c:	83 f8 01             	cmp    $0x1,%eax
8010aa3f:	74 0d                	je     8010aa4e <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010aa41:	83 ec 0c             	sub    $0xc,%esp
8010aa44:	68 95 cc 10 80       	push   $0x8010cc95
8010aa49:	e8 5b 5b ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010aa4e:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa51:	8b 40 08             	mov    0x8(%eax),%eax
8010aa54:	8b 15 8c 7d 19 80    	mov    0x80197d8c,%edx
8010aa5a:	39 d0                	cmp    %edx,%eax
8010aa5c:	72 0d                	jb     8010aa6b <iderw+0x78>
    panic("iderw: block out of range");
8010aa5e:	83 ec 0c             	sub    $0xc,%esp
8010aa61:	68 b3 cc 10 80       	push   $0x8010ccb3
8010aa66:	e8 3e 5b ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010aa6b:	8b 15 90 7d 19 80    	mov    0x80197d90,%edx
8010aa71:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa74:	8b 40 08             	mov    0x8(%eax),%eax
8010aa77:	c1 e0 09             	shl    $0x9,%eax
8010aa7a:	01 d0                	add    %edx,%eax
8010aa7c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010aa7f:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa82:	8b 00                	mov    (%eax),%eax
8010aa84:	83 e0 04             	and    $0x4,%eax
8010aa87:	85 c0                	test   %eax,%eax
8010aa89:	74 2b                	je     8010aab6 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010aa8b:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa8e:	8b 00                	mov    (%eax),%eax
8010aa90:	83 e0 fb             	and    $0xfffffffb,%eax
8010aa93:	89 c2                	mov    %eax,%edx
8010aa95:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa98:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010aa9a:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa9d:	83 c0 5c             	add    $0x5c,%eax
8010aaa0:	83 ec 04             	sub    $0x4,%esp
8010aaa3:	68 00 02 00 00       	push   $0x200
8010aaa8:	50                   	push   %eax
8010aaa9:	ff 75 f4             	push   -0xc(%ebp)
8010aaac:	e8 5d a9 ff ff       	call   8010540e <memmove>
8010aab1:	83 c4 10             	add    $0x10,%esp
8010aab4:	eb 1a                	jmp    8010aad0 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010aab6:	8b 45 08             	mov    0x8(%ebp),%eax
8010aab9:	83 c0 5c             	add    $0x5c,%eax
8010aabc:	83 ec 04             	sub    $0x4,%esp
8010aabf:	68 00 02 00 00       	push   $0x200
8010aac4:	ff 75 f4             	push   -0xc(%ebp)
8010aac7:	50                   	push   %eax
8010aac8:	e8 41 a9 ff ff       	call   8010540e <memmove>
8010aacd:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010aad0:	8b 45 08             	mov    0x8(%ebp),%eax
8010aad3:	8b 00                	mov    (%eax),%eax
8010aad5:	83 c8 02             	or     $0x2,%eax
8010aad8:	89 c2                	mov    %eax,%edx
8010aada:	8b 45 08             	mov    0x8(%ebp),%eax
8010aadd:	89 10                	mov    %edx,(%eax)
}
8010aadf:	90                   	nop
8010aae0:	c9                   	leave
8010aae1:	c3                   	ret
