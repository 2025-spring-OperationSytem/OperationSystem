
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
8010006f:	68 20 aa 10 80       	push   $0x8010aa20
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 a8 4f 00 00       	call   80105026 <initlock>
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
801000bd:	68 27 aa 10 80       	push   $0x8010aa27
801000c2:	50                   	push   %eax
801000c3:	e8 01 4e 00 00       	call   80104ec9 <initsleeplock>
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
80100101:	e8 42 4f 00 00       	call   80105048 <acquire>
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
80100140:	e8 71 4f 00 00       	call   801050b6 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 ae 4d 00 00       	call   80104f05 <acquiresleep>
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
801001c1:	e8 f0 4e 00 00       	call   801050b6 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 2d 4d 00 00       	call   80104f05 <acquiresleep>
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
801001f5:	68 2e aa 10 80       	push   $0x8010aa2e
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
8010022d:	e8 ee a6 00 00       	call   8010a920 <iderw>
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
8010024a:	e8 68 4d 00 00       	call   80104fb7 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f aa 10 80       	push   $0x8010aa3f
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
80100278:	e8 a3 a6 00 00       	call   8010a920 <iderw>
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
80100293:	e8 1f 4d 00 00       	call   80104fb7 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 aa 10 80       	push   $0x8010aa46
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 ae 4c 00 00       	call   80104f69 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 7d 4d 00 00       	call   80105048 <acquire>
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
80100336:	e8 7b 4d 00 00       	call   801050b6 <release>
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
80100410:	e8 33 4c 00 00       	call   80105048 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d aa 10 80       	push   $0x8010aa4d
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
80100510:	c7 45 ec 56 aa 10 80 	movl   $0x8010aa56,-0x14(%ebp)
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
8010059e:	e8 13 4b 00 00       	call   801050b6 <release>
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
801005c7:	68 5d aa 10 80       	push   $0x8010aa5d
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
801005e6:	68 71 aa 10 80       	push   $0x8010aa71
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 05 4b 00 00       	call   80105108 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 aa 10 80       	push   $0x8010aa73
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
801006a1:	e8 e7 81 00 00       	call   8010888d <graphic_scroll_up>
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
801006f4:	e8 94 81 00 00       	call   8010888d <graphic_scroll_up>
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
80100756:	e8 9f 81 00 00       	call   801088fa <font_render>
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
80100793:	e8 6f 65 00 00       	call   80106d07 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 62 65 00 00       	call   80106d07 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 55 65 00 00       	call   80106d07 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 45 65 00 00       	call   80106d07 <uartputc>
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
801007eb:	e8 58 48 00 00       	call   80105048 <acquire>
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
8010096a:	e8 47 47 00 00       	call   801050b6 <release>
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
801009a2:	e8 a1 46 00 00       	call   80105048 <acquire>
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
801009c3:	e8 ee 46 00 00       	call   801050b6 <release>
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
80100a6e:	e8 43 46 00 00       	call   801050b6 <release>
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
80100aac:	e8 97 45 00 00       	call   80105048 <acquire>
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
80100aee:	e8 c3 45 00 00       	call   801050b6 <release>
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
80100b1c:	68 77 aa 10 80       	push   $0x8010aa77
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 fb 44 00 00       	call   80105026 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 7f aa 10 80 	movl   $0x8010aa7f,-0xc(%ebp)
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
80100bbf:	68 95 aa 10 80       	push   $0x8010aa95
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
80100c1b:	e8 e3 70 00 00       	call   80107d03 <setupkvm>
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
80100cc1:	e8 37 74 00 00       	call   801080fd <allocuvm>
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
80100d07:	e8 24 73 00 00       	call   80108030 <loaduvm>
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
80100d76:	e8 82 73 00 00       	call   801080fd <allocuvm>
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
80100d9a:	e8 c0 75 00 00       	call   8010835f <clearpteu>
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
80100dd3:	e8 34 47 00 00       	call   8010550c <strlen>
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
80100e00:	e8 07 47 00 00       	call   8010550c <strlen>
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
80100e26:	e8 d3 76 00 00       	call   801084fe <copyout>
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
80100ec2:	e8 37 76 00 00       	call   801084fe <copyout>
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
80100f10:	e8 ac 45 00 00       	call   801054c1 <safestrcpy>
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
80100f53:	e8 c9 6e 00 00       	call   80107e21 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 60 73 00 00       	call   801082c6 <freevm>
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
80100fa1:	e8 20 73 00 00       	call   801082c6 <freevm>
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
80100fd2:	68 a1 aa 10 80       	push   $0x8010aaa1
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 45 40 00 00       	call   80105026 <initlock>
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
80100ff5:	e8 4e 40 00 00       	call   80105048 <acquire>
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
80101022:	e8 8f 40 00 00       	call   801050b6 <release>
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
80101045:	e8 6c 40 00 00       	call   801050b6 <release>
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
80101062:	e8 e1 3f 00 00       	call   80105048 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 a8 aa 10 80       	push   $0x8010aaa8
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
80101098:	e8 19 40 00 00       	call   801050b6 <release>
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
801010b3:	e8 90 3f 00 00       	call   80105048 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 b0 aa 10 80       	push   $0x8010aab0
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
801010f3:	e8 be 3f 00 00       	call   801050b6 <release>
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
80101141:	e8 70 3f 00 00       	call   801050b6 <release>
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
80101290:	68 ba aa 10 80       	push   $0x8010aaba
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
80101393:	68 c3 aa 10 80       	push   $0x8010aac3
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
801013c9:	68 d3 aa 10 80       	push   $0x8010aad3
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
80101401:	e8 77 3f 00 00       	call   8010537d <memmove>
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
80101447:	e8 72 3e 00 00       	call   801052be <memset>
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
801015a5:	68 e0 aa 10 80       	push   $0x8010aae0
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
80101630:	68 f6 aa 10 80       	push   $0x8010aaf6
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
80101694:	68 09 ab 10 80       	push   $0x8010ab09
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 83 39 00 00       	call   80105026 <initlock>
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
801016ca:	68 10 ab 10 80       	push   $0x8010ab10
801016cf:	50                   	push   %eax
801016d0:	e8 f4 37 00 00       	call   80104ec9 <initsleeplock>
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
80101729:	68 18 ab 10 80       	push   $0x8010ab18
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
801017a2:	e8 17 3b 00 00       	call   801052be <memset>
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
80101809:	68 6b ab 10 80       	push   $0x8010ab6b
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
801018af:	e8 c9 3a 00 00       	call   8010537d <memmove>
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
801018e4:	e8 5f 37 00 00       	call   80105048 <acquire>
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
80101932:	e8 7f 37 00 00       	call   801050b6 <release>
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
8010196e:	68 7d ab 10 80       	push   $0x8010ab7d
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
801019ab:	e8 06 37 00 00       	call   801050b6 <release>
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
801019c6:	e8 7d 36 00 00       	call   80105048 <acquire>
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
801019e5:	e8 cc 36 00 00       	call   801050b6 <release>
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
80101a0b:	68 8d ab 10 80       	push   $0x8010ab8d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 e1 34 00 00       	call   80104f05 <acquiresleep>
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
80101ac9:	e8 af 38 00 00       	call   8010537d <memmove>
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
80101af8:	68 93 ab 10 80       	push   $0x8010ab93
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
80101b1b:	e8 97 34 00 00       	call   80104fb7 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 a2 ab 10 80       	push   $0x8010aba2
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 1c 34 00 00       	call   80104f69 <releasesleep>
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
80101b63:	e8 9d 33 00 00       	call   80104f05 <acquiresleep>
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
80101b89:	e8 ba 34 00 00       	call   80105048 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 0f 35 00 00       	call   801050b6 <release>
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
80101be9:	e8 7b 33 00 00       	call   80104f69 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 4a 34 00 00       	call   80105048 <acquire>
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
80101c18:	e8 99 34 00 00       	call   801050b6 <release>
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
80101d5c:	68 aa ab 10 80       	push   $0x8010abaa
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
80101ffa:	e8 7e 33 00 00       	call   8010537d <memmove>
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
8010214a:	e8 2e 32 00 00       	call   8010537d <memmove>
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
801021ca:	e8 44 32 00 00       	call   80105413 <strncmp>
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
801021ea:	68 bd ab 10 80       	push   $0x8010abbd
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
80102219:	68 cf ab 10 80       	push   $0x8010abcf
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
801022ee:	68 de ab 10 80       	push   $0x8010abde
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
80102329:	e8 3b 31 00 00       	call   80105469 <strncpy>
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
80102355:	68 eb ab 10 80       	push   $0x8010abeb
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
801023c7:	e8 b1 2f 00 00       	call   8010537d <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 9a 2f 00 00       	call   8010537d <memmove>
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
801025d5:	68 f4 ab 10 80       	push   $0x8010abf4
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
8010267c:	68 26 ac 10 80       	push   $0x8010ac26
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 9b 29 00 00       	call   80105026 <initlock>
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
8010273b:	68 2b ac 10 80       	push   $0x8010ac2b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 67 2b 00 00       	call   801052be <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 d8 28 00 00       	call   80105048 <acquire>
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
8010279d:	e8 14 29 00 00       	call   801050b6 <release>
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
801027bf:	e8 84 28 00 00       	call   80105048 <acquire>
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
801027f0:	e8 c1 28 00 00       	call   801050b6 <release>
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
80102d14:	e8 0c 26 00 00       	call   80105325 <memcmp>
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
80102e28:	68 31 ac 10 80       	push   $0x8010ac31
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 ef 21 00 00       	call   80105026 <initlock>
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
80102edd:	e8 9b 24 00 00       	call   8010537d <memmove>
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
8010304c:	e8 f7 1f 00 00       	call   80105048 <acquire>
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
801030be:	e8 f3 1f 00 00       	call   801050b6 <release>
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
801030df:	e8 64 1f 00 00       	call   80105048 <acquire>
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
80103100:	68 35 ac 10 80       	push   $0x8010ac35
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
8010313e:	e8 73 1f 00 00       	call   801050b6 <release>
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
80103159:	e8 ea 1e 00 00       	call   80105048 <acquire>
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
80103183:	e8 2e 1f 00 00       	call   801050b6 <release>
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
801031ff:	e8 79 21 00 00       	call   8010537d <memmove>
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
8010329c:	68 44 ac 10 80       	push   $0x8010ac44
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 5a ac 10 80       	push   $0x8010ac5a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 7f 1d 00 00       	call   80105048 <acquire>
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
80103342:	e8 6f 1d 00 00       	call   801050b6 <release>
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
80103378:	e8 55 54 00 00       	call   801087d2 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 59 4a 00 00       	call   80107df0 <kvmalloc>
  mpinit_uefi();
80103397:	e8 00 52 00 00       	call   8010859c <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 e1 44 00 00       	call   80107887 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 66 38 00 00       	call   80106c20 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 67 33 00 00       	call   8010672b <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 2a 75 00 00       	call   8010a8fd <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 3b 56 00 00       	call   80108a2d <pci_init>
  arp_scan();
801033f2:	e8 70 63 00 00       	call   80109767 <arp_scan>
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
80103407:	e8 fc 49 00 00       	call   80107e08 <switchkvm>
  seginit();
8010340c:	e8 76 44 00 00       	call   80107887 <seginit>
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
80103433:	68 75 ac 10 80       	push   $0x8010ac75
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 5c 34 00 00       	call   801068a1 <idtinit>
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
80103480:	e8 f8 1e 00 00       	call   8010537d <memmove>
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
80103607:	68 89 ac 10 80       	push   $0x8010ac89
8010360c:	50                   	push   %eax
8010360d:	e8 14 1a 00 00       	call   80105026 <initlock>
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
801036cc:	e8 77 19 00 00       	call   80105048 <acquire>
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
8010373f:	e8 72 19 00 00       	call   801050b6 <release>
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
8010375e:	e8 53 19 00 00       	call   801050b6 <release>
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
80103778:	e8 cb 18 00 00       	call   80105048 <acquire>
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
801037ac:	e8 05 19 00 00       	call   801050b6 <release>
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
8010385c:	e8 55 18 00 00       	call   801050b6 <release>
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
80103879:	e8 ca 17 00 00       	call   80105048 <acquire>
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
80103896:	e8 1b 18 00 00       	call   801050b6 <release>
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
8010395b:	e8 56 17 00 00       	call   801050b6 <release>
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
80103988:	68 90 ac 10 80       	push   $0x8010ac90
8010398d:	68 00 4e 19 80       	push   $0x80194e00
80103992:	e8 8f 16 00 00       	call   80105026 <initlock>
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
801039cf:	68 98 ac 10 80       	push   $0x8010ac98
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
80103a24:	68 be ac 10 80       	push   $0x8010acbe
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
80103a36:	e8 78 17 00 00       	call   801051b3 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 ac 17 00 00       	call   80105200 <popcli>
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
80103a67:	e8 dc 15 00 00       	call   80105048 <acquire>
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
80103a97:	e8 1a 16 00 00       	call   801050b6 <release>
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
80103b24:	e8 95 17 00 00       	call   801052be <memset>
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
80103b42:	e8 77 17 00 00       	call   801052be <memset>
80103b47:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 00 4e 19 80       	push   $0x80194e00
80103b52:	e8 5f 15 00 00       	call   801050b6 <release>
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
80103b9f:	ba e5 66 10 80       	mov    $0x801066e5,%edx
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
80103bc4:	e8 f5 16 00 00       	call   801052be <memset>
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
80103bf5:	e8 09 41 00 00       	call   80107d03 <setupkvm>
80103bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfd:	89 42 04             	mov    %eax,0x4(%edx)
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 40 04             	mov    0x4(%eax),%eax
80103c06:	85 c0                	test   %eax,%eax
80103c08:	75 0d                	jne    80103c17 <userinit+0x38>
    panic("userinit: out of memory?");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 ce ac 10 80       	push   $0x8010acce
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
80103c2c:	e8 8f 43 00 00       	call   80107fc0 <inituvm>
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
80103c4b:	e8 6e 16 00 00       	call   801052be <memset>
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
80103cc5:	68 e7 ac 10 80       	push   $0x8010ace7
80103cca:	50                   	push   %eax
80103ccb:	e8 f1 17 00 00       	call   801054c1 <safestrcpy>
80103cd0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cd3:	83 ec 0c             	sub    $0xc,%esp
80103cd6:	68 f0 ac 10 80       	push   $0x8010acf0
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
80103cf1:	e8 52 13 00 00       	call   80105048 <acquire>
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
80103d2a:	e8 87 13 00 00       	call   801050b6 <release>
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
80103d67:	e8 91 43 00 00       	call   801080fd <allocuvm>
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
80103d9b:	e8 62 44 00 00       	call   80108202 <deallocuvm>
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
80103dc1:	e8 5b 40 00 00       	call   80107e21 <switchuvm>
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
80103e09:	e8 92 45 00 00       	call   801083a0 <copyuvm>
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
80103f03:	e8 b9 15 00 00       	call   801054c1 <safestrcpy>
80103f08:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0e:	8b 40 10             	mov    0x10(%eax),%eax
80103f11:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f14:	83 ec 0c             	sub    $0xc,%esp
80103f17:	68 00 4e 19 80       	push   $0x80194e00
80103f1c:	e8 27 11 00 00       	call   80105048 <acquire>
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
80103f44:	68 f4 ac 10 80       	push   $0x8010acf4
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
80103f91:	e8 20 11 00 00       	call   801050b6 <release>
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
80103fbf:	68 1e ad 10 80       	push   $0x8010ad1e
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
80104045:	e8 fe 0f 00 00       	call   80105048 <acquire>
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
801040dc:	68 2b ad 10 80       	push   $0x8010ad2b
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
801040fc:	e8 47 0f 00 00       	call   80105048 <acquire>
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
80104167:	e8 5a 41 00 00       	call   801082c6 <freevm>
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
801041a6:	e8 0b 0f 00 00       	call   801050b6 <release>
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
801041dd:	e8 d4 0e 00 00       	call   801050b6 <release>
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
8010422e:	e8 15 0e 00 00       	call   80105048 <acquire>
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
8010426f:	e8 ad 3b 00 00       	call   80107e21 <switchuvm>
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
80104292:	e8 9c 12 00 00       	call   80105533 <swtch>
80104297:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010429a:	e8 69 3b 00 00       	call   80107e08 <switchkvm>

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
8010433a:	e8 66 0a 00 00       	call   80104da5 <run_mlfq>
    }  

    release(&ptable.lock);
8010433f:	83 ec 0c             	sub    $0xc,%esp
80104342:	68 00 4e 19 80       	push   $0x80194e00
80104347:	e8 6a 0d 00 00       	call   801050b6 <release>
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
8010436a:	e8 14 0e 00 00       	call   80105183 <holding>
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	85 c0                	test   %eax,%eax
80104374:	75 0d                	jne    80104383 <sched+0x2f>
    panic("sched ptable.lock");
80104376:	83 ec 0c             	sub    $0xc,%esp
80104379:	68 37 ad 10 80       	push   $0x8010ad37
8010437e:	e8 26 c2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104383:	e8 30 f6 ff ff       	call   801039b8 <mycpu>
80104388:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010438e:	83 f8 01             	cmp    $0x1,%eax
80104391:	74 0d                	je     801043a0 <sched+0x4c>
    panic("sched locks");
80104393:	83 ec 0c             	sub    $0xc,%esp
80104396:	68 49 ad 10 80       	push   $0x8010ad49
8010439b:	e8 09 c2 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	8b 40 0c             	mov    0xc(%eax),%eax
801043a6:	83 f8 04             	cmp    $0x4,%eax
801043a9:	75 0d                	jne    801043b8 <sched+0x64>
    panic("sched running");
801043ab:	83 ec 0c             	sub    $0xc,%esp
801043ae:	68 55 ad 10 80       	push   $0x8010ad55
801043b3:	e8 f1 c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801043b8:	e8 ab f5 ff ff       	call   80103968 <readeflags>
801043bd:	25 00 02 00 00       	and    $0x200,%eax
801043c2:	85 c0                	test   %eax,%eax
801043c4:	74 0d                	je     801043d3 <sched+0x7f>
    panic("sched interruptible");
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 63 ad 10 80       	push   $0x8010ad63
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
801043f4:	e8 3a 11 00 00       	call   80105533 <swtch>
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
8010441b:	e8 28 0c 00 00       	call   80105048 <acquire>
80104420:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104423:	e8 08 f6 ff ff       	call   80103a30 <myproc>
80104428:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010442f:	e8 20 ff ff ff       	call   80104354 <sched>
  release(&ptable.lock);
80104434:	83 ec 0c             	sub    $0xc,%esp
80104437:	68 00 4e 19 80       	push   $0x80194e00
8010443c:	e8 75 0c 00 00       	call   801050b6 <release>
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
80104455:	e8 5c 0c 00 00       	call   801050b6 <release>
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
801044a4:	68 77 ad 10 80       	push   $0x8010ad77
801044a9:	e8 fb c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801044ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044b2:	75 0d                	jne    801044c1 <sleep+0x34>
    panic("sleep without lk");
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	68 7d ad 10 80       	push   $0x8010ad7d
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
801044d2:	e8 71 0b 00 00       	call   80105048 <acquire>
801044d7:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044da:	83 ec 0c             	sub    $0xc,%esp
801044dd:	ff 75 0c             	push   0xc(%ebp)
801044e0:	e8 d1 0b 00 00       	call   801050b6 <release>
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
8010451b:	e8 96 0b 00 00       	call   801050b6 <release>
80104520:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	ff 75 0c             	push   0xc(%ebp)
80104529:	e8 1a 0b 00 00       	call   80105048 <acquire>
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
80104582:	e8 c1 0a 00 00       	call   80105048 <acquire>
80104587:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010458a:	83 ec 0c             	sub    $0xc,%esp
8010458d:	ff 75 08             	push   0x8(%ebp)
80104590:	e8 9f ff ff ff       	call   80104534 <wakeup1>
80104595:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104598:	83 ec 0c             	sub    $0xc,%esp
8010459b:	68 00 4e 19 80       	push   $0x80194e00
801045a0:	e8 11 0b 00 00       	call   801050b6 <release>
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
801045b9:	e8 8a 0a 00 00       	call   80105048 <acquire>
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
801045fc:	e8 b5 0a 00 00       	call   801050b6 <release>
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
80104620:	e8 91 0a 00 00       	call   801050b6 <release>
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
8010467d:	c7 45 ec 8e ad 10 80 	movl   $0x8010ad8e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104687:	8d 50 6c             	lea    0x6c(%eax),%edx
8010468a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468d:	8b 40 10             	mov    0x10(%eax),%eax
80104690:	52                   	push   %edx
80104691:	ff 75 ec             	push   -0x14(%ebp)
80104694:	50                   	push   %eax
80104695:	68 92 ad 10 80       	push   $0x8010ad92
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
801046c3:	e8 40 0a 00 00       	call   80105108 <getcallerpcs>
801046c8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046d2:	eb 1c                	jmp    801046f0 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046db:	83 ec 08             	sub    $0x8,%esp
801046de:	50                   	push   %eax
801046df:	68 9b ad 10 80       	push   $0x8010ad9b
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
80104704:	68 9f ad 10 80       	push   $0x8010ad9f
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
80104738:	e8 0b 09 00 00       	call   80105048 <acquire>
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
80104844:	e8 6d 08 00 00       	call   801050b6 <release>
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
80104864:	e8 df 07 00 00       	call   80105048 <acquire>
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
801048d0:	68 a1 ad 10 80       	push   $0x8010ada1
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
801048f2:	e8 bf 07 00 00       	call   801050b6 <release>
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
80104916:	e8 98 08 00 00       	call   801051b3 <pushcli>
  mycpu()->sched_policy = policy;
8010491b:	e8 98 f0 ff ff       	call   801039b8 <mycpu>
80104920:	8b 55 08             	mov    0x8(%ebp),%edx
80104923:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104929:	e8 d2 08 00 00       	call   80105200 <popcli>

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
80104946:	e8 68 08 00 00       	call   801051b3 <pushcli>
  int policy = mycpu()->sched_policy;
8010494b:	e8 68 f0 ff ff       	call   801039b8 <mycpu>
80104950:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104959:	e8 a2 08 00 00       	call   80105200 <popcli>
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
80104a8a:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < NPROC; i++) {
80104a8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a94:	e9 5a 01 00 00       	jmp    80104bf3 <apply_priority_boosting+0x16c>
    if (!kernel_pstat.inuse[i]) continue;
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104aa3:	85 c0                	test   %eax,%eax
80104aa5:	0f 84 43 01 00 00    	je     80104bee <apply_priority_boosting+0x167>
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

    if (q == 0 && waited >= 500) {
80104ad9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104add:	75 70                	jne    80104b4f <apply_priority_boosting+0xc8>
80104adf:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104ae6:	7e 67                	jle    80104b4f <apply_priority_boosting+0xc8>
      kernel_pstat.priority[i] = 1;
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	83 e8 80             	sub    $0xffffff80,%eax
80104aee:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80104af5:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afc:	83 e8 80             	sub    $0xffffff80,%eax
80104aff:	c1 e0 04             	shl    $0x4,%eax
80104b02:	05 00 42 19 80       	add    $0x80194200,%eax
80104b07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q0→Q1\n", kernel_pstat.pid[i]);
80104b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b10:	83 c0 40             	add    $0x40,%eax
80104b13:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b1a:	83 ec 08             	sub    $0x8,%esp
80104b1d:	50                   	push   %eax
80104b1e:	68 bf ad 10 80       	push   $0x8010adbf
80104b23:	e8 cc b8 ff ff       	call   801003f4 <cprintf>
80104b28:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 1);
80104b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104b31:	83 c0 30             	add    $0x30,%eax
80104b34:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104b39:	83 c0 04             	add    $0x4,%eax
80104b3c:	83 ec 08             	sub    $0x8,%esp
80104b3f:	6a 01                	push   $0x1
80104b41:	50                   	push   %eax
80104b42:	e8 1c fe ff ff       	call   80104963 <enqueue>
80104b47:	83 c4 10             	add    $0x10,%esp
80104b4a:	e9 a0 00 00 00       	jmp    80104bef <apply_priority_boosting+0x168>
    } else if ((q == 1 && waited >= 320) || (q == 2 && waited >= 160)) {
80104b4f:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104b53:	75 09                	jne    80104b5e <apply_priority_boosting+0xd7>
80104b55:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104b5c:	7f 13                	jg     80104b71 <apply_priority_boosting+0xea>
80104b5e:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104b62:	0f 85 87 00 00 00    	jne    80104bef <apply_priority_boosting+0x168>
80104b68:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104b6f:	7e 7e                	jle    80104bef <apply_priority_boosting+0x168>
      kernel_pstat.priority[i] = q + 1;
80104b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b74:	8d 50 01             	lea    0x1(%eax),%edx
80104b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7a:	83 e8 80             	sub    $0xffffff80,%eax
80104b7d:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      kernel_pstat.wait_ticks[i][q] = 0;
80104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b91:	01 d0                	add    %edx,%eax
80104b93:	05 00 02 00 00       	add    $0x200,%eax
80104b98:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104b9f:	00 00 00 00 
      cprintf("[BOOST] PID %d Q%d→Q%d\n", kernel_pstat.pid[i], q, q + 1);
80104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba6:	8d 50 01             	lea    0x1(%eax),%edx
80104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bac:	83 c0 40             	add    $0x40,%eax
80104baf:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104bb6:	52                   	push   %edx
80104bb7:	ff 75 f0             	push   -0x10(%ebp)
80104bba:	50                   	push   %eax
80104bbb:	68 d7 ad 10 80       	push   $0x8010add7
80104bc0:	e8 2f b8 ff ff       	call   801003f4 <cprintf>
80104bc5:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], q + 1);
80104bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bcb:	8d 50 01             	lea    0x1(%eax),%edx
80104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd1:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104bd4:	83 c0 30             	add    $0x30,%eax
80104bd7:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104bdc:	83 c0 04             	add    $0x4,%eax
80104bdf:	83 ec 08             	sub    $0x8,%esp
80104be2:	52                   	push   %edx
80104be3:	50                   	push   %eax
80104be4:	e8 7a fd ff ff       	call   80104963 <enqueue>
80104be9:	83 c4 10             	add    $0x10,%esp
80104bec:	eb 01                	jmp    80104bef <apply_priority_boosting+0x168>
    if (!kernel_pstat.inuse[i]) continue;
80104bee:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104bef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bf3:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104bf7:	0f 8e 9c fe ff ff    	jle    80104a99 <apply_priority_boosting+0x12>
    }
  }
}
80104bfd:	90                   	nop
80104bfe:	90                   	nop
80104bff:	c9                   	leave
80104c00:	c3                   	ret

80104c01 <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104c01:	55                   	push   %ebp
80104c02:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104c04:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104c08:	75 07                	jne    80104c11 <get_time_slice+0x10>
80104c0a:	b8 08 00 00 00       	mov    $0x8,%eax
80104c0f:	eb 1f                	jmp    80104c30 <get_time_slice+0x2f>
  if (level == 2) return 16;
80104c11:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104c15:	75 07                	jne    80104c1e <get_time_slice+0x1d>
80104c17:	b8 10 00 00 00       	mov    $0x10,%eax
80104c1c:	eb 12                	jmp    80104c30 <get_time_slice+0x2f>
  if (level == 1) return 32;
80104c1e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104c22:	75 07                	jne    80104c2b <get_time_slice+0x2a>
80104c24:	b8 20 00 00 00       	mov    $0x20,%eax
80104c29:	eb 05                	jmp    80104c30 <get_time_slice+0x2f>
  return -1; // FIFO (Q0)
80104c2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c30:	5d                   	pop    %ebp
80104c31:	c3                   	ret

80104c32 <run_process>:

void run_process(struct proc* p, int q, int slice) {
80104c32:	55                   	push   %ebp
80104c33:	89 e5                	mov    %esp,%ebp
80104c35:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104c38:	e8 7b ed ff ff       	call   801039b8 <mycpu>
80104c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c43:	8b 55 08             	mov    0x8(%ebp),%edx
80104c46:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104c4c:	83 ec 0c             	sub    $0xc,%esp
80104c4f:	ff 75 08             	push   0x8(%ebp)
80104c52:	e8 ca 31 00 00       	call   80107e21 <switchuvm>
80104c57:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

  int i = p - ptable.proc;
80104c64:	8b 45 08             	mov    0x8(%ebp),%eax
80104c67:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80104c6c:	c1 f8 02             	sar    $0x2,%eax
80104c6f:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104c75:	89 45 f0             	mov    %eax,-0x10(%ebp)

  cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
80104c78:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7b:	8b 40 10             	mov    0x10(%eax),%eax
80104c7e:	83 ec 04             	sub    $0x4,%esp
80104c81:	ff 75 0c             	push   0xc(%ebp)
80104c84:	50                   	push   %eax
80104c85:	68 f4 ad 10 80       	push   $0x8010adf4
80104c8a:	e8 65 b7 ff ff       	call   801003f4 <cprintf>
80104c8f:	83 c4 10             	add    $0x10,%esp

  // 실제 프로세스를 실행 (문맥 전환)
  swtch(&(c->scheduler), p->context);
80104c92:	8b 45 08             	mov    0x8(%ebp),%eax
80104c95:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c9b:	83 c2 04             	add    $0x4,%edx
80104c9e:	83 ec 08             	sub    $0x8,%esp
80104ca1:	50                   	push   %eax
80104ca2:	52                   	push   %edx
80104ca3:	e8 8b 08 00 00       	call   80105533 <swtch>
80104ca8:	83 c4 10             	add    $0x10,%esp
  // 유저 공간에서 실행이 끝나고 다시 돌아옴
  switchkvm();
80104cab:	e8 58 31 00 00       	call   80107e08 <switchkvm>
  c->proc = 0;
80104cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb3:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cba:	00 00 00 

  int executed = kernel_pstat.ticks[i][q];
80104cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cca:	01 d0                	add    %edx,%eax
80104ccc:	05 00 01 00 00       	add    $0x100,%eax
80104cd1:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104cd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  cprintf("[CHECK] PID %d total ticks at Q%d = %d (slice = %d)\n", p->pid, q, executed, slice);
80104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cde:	8b 40 10             	mov    0x10(%eax),%eax
80104ce1:	83 ec 0c             	sub    $0xc,%esp
80104ce4:	ff 75 10             	push   0x10(%ebp)
80104ce7:	ff 75 ec             	push   -0x14(%ebp)
80104cea:	ff 75 0c             	push   0xc(%ebp)
80104ced:	50                   	push   %eax
80104cee:	68 18 ae 10 80       	push   $0x8010ae18
80104cf3:	e8 fc b6 ff ff       	call   801003f4 <cprintf>
80104cf8:	83 c4 20             	add    $0x20,%esp

  if (slice != -1 && executed >= slice && q > 0) {
80104cfb:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104cff:	74 75                	je     80104d76 <run_process+0x144>
80104d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d04:	3b 45 10             	cmp    0x10(%ebp),%eax
80104d07:	7c 6d                	jl     80104d76 <run_process+0x144>
80104d09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d0d:	7e 67                	jle    80104d76 <run_process+0x144>
    kernel_pstat.priority[i] = q - 1;
80104d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d12:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d18:	83 e8 80             	sub    $0xffffff80,%eax
80104d1b:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;  // 현재 큐에서의 실행 시간 초기화
80104d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d2f:	01 d0                	add    %edx,%eax
80104d31:	05 00 01 00 00       	add    $0x100,%eax
80104d36:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104d3d:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80104d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d44:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d47:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4a:	8b 40 10             	mov    0x10(%eax),%eax
80104d4d:	52                   	push   %edx
80104d4e:	ff 75 0c             	push   0xc(%ebp)
80104d51:	50                   	push   %eax
80104d52:	68 4d ae 10 80       	push   $0x8010ae4d
80104d57:	e8 98 b6 ff ff       	call   801003f4 <cprintf>
80104d5c:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
80104d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d62:	83 e8 01             	sub    $0x1,%eax
80104d65:	83 ec 08             	sub    $0x8,%esp
80104d68:	50                   	push   %eax
80104d69:	ff 75 08             	push   0x8(%ebp)
80104d6c:	e8 f2 fb ff ff       	call   80104963 <enqueue>
80104d71:	83 c4 10             	add    $0x10,%esp
80104d74:	eb 2c                	jmp    80104da2 <run_process+0x170>
  } else {
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
80104d76:	8b 45 08             	mov    0x8(%ebp),%eax
80104d79:	8b 40 10             	mov    0x10(%eax),%eax
80104d7c:	83 ec 04             	sub    $0x4,%esp
80104d7f:	ff 75 0c             	push   0xc(%ebp)
80104d82:	50                   	push   %eax
80104d83:	68 6c ae 10 80       	push   $0x8010ae6c
80104d88:	e8 67 b6 ff ff       	call   801003f4 <cprintf>
80104d8d:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
80104d90:	83 ec 08             	sub    $0x8,%esp
80104d93:	ff 75 0c             	push   0xc(%ebp)
80104d96:	ff 75 08             	push   0x8(%ebp)
80104d99:	e8 c5 fb ff ff       	call   80104963 <enqueue>
80104d9e:	83 c4 10             	add    $0x10,%esp
  }
}
80104da1:	90                   	nop
80104da2:	90                   	nop
80104da3:	c9                   	leave
80104da4:	c3                   	ret

80104da5 <run_mlfq>:


// MLFQ 스케줄러 진입점
void run_mlfq(void) {
80104da5:	55                   	push   %ebp
80104da6:	89 e5                	mov    %esp,%ebp
80104da8:	83 ec 28             	sub    $0x28,%esp
  
  apply_priority_boosting();
80104dab:	e8 d7 fc ff ff       	call   80104a87 <apply_priority_boosting>
  
  for (int q = 3; q >= 0; q--) {
80104db0:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
80104db7:	eb 75                	jmp    80104e2e <run_mlfq+0x89>
    for (int i = 0; i < NPROC; i++) {
80104db9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104dc0:	eb 62                	jmp    80104e24 <run_mlfq+0x7f>
      struct proc *p = mlfq_queues[q][i];
80104dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc5:	c1 e0 06             	shl    $0x6,%eax
80104dc8:	89 c2                	mov    %eax,%edx
80104dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcd:	01 d0                	add    %edx,%eax
80104dcf:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104dd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      //cprintf("[MLFQ_LOOP] Q%d index %d: pid %d, state %d\n", q, i,
      //  p ? p->pid : -1, p ? p->state : -1);
      if (p == 0 || p->state != RUNNABLE)
80104dd9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104ddd:	74 40                	je     80104e1f <run_mlfq+0x7a>
80104ddf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104de2:	8b 40 0c             	mov    0xc(%eax),%eax
80104de5:	83 f8 03             	cmp    $0x3,%eax
80104de8:	75 35                	jne    80104e1f <run_mlfq+0x7a>
        continue;
      
      // 실행할 프로세스는 dequeue
      dequeue(q);
80104dea:	83 ec 0c             	sub    $0xc,%esp
80104ded:	ff 75 f4             	push   -0xc(%ebp)
80104df0:	e8 e9 fb ff ff       	call   801049de <dequeue>
80104df5:	83 c4 10             	add    $0x10,%esp
 
      int slice = get_time_slice(q);
80104df8:	83 ec 0c             	sub    $0xc,%esp
80104dfb:	ff 75 f4             	push   -0xc(%ebp)
80104dfe:	e8 fe fd ff ff       	call   80104c01 <get_time_slice>
80104e03:	83 c4 10             	add    $0x10,%esp
80104e06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice);
80104e09:	83 ec 04             	sub    $0x4,%esp
80104e0c:	ff 75 e4             	push   -0x1c(%ebp)
80104e0f:	ff 75 f4             	push   -0xc(%ebp)
80104e12:	ff 75 e8             	push   -0x18(%ebp)
80104e15:	e8 18 fe ff ff       	call   80104c32 <run_process>
80104e1a:	83 c4 10             	add    $0x10,%esp
      goto tick_update; // 한 번만 실행
80104e1d:	eb 16                	jmp    80104e35 <run_mlfq+0x90>
        continue;
80104e1f:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
80104e20:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104e24:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104e28:	7e 98                	jle    80104dc2 <run_mlfq+0x1d>
  for (int q = 3; q >= 0; q--) {
80104e2a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80104e2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e32:	79 85                	jns    80104db9 <run_mlfq+0x14>
    }
  }

tick_update:
80104e34:	90                   	nop
  // wait tick 증가 (실행 안 된 RUNNABLE 프로세스만)
  for (int i = 0; i < NPROC; i++) {
80104e35:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104e3c:	eb 7d                	jmp    80104ebb <run_mlfq+0x116>
    struct proc* p = &ptable.proc[i];
80104e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e41:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104e44:	83 c0 30             	add    $0x30,%eax
80104e47:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104e4c:	83 c0 04             	add    $0x4,%eax
80104e4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80104e52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e55:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e5c:	85 c0                	test   %eax,%eax
80104e5e:	74 56                	je     80104eb6 <run_mlfq+0x111>
    if (p->state == RUNNABLE) {
80104e60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e63:	8b 40 0c             	mov    0xc(%eax),%eax
80104e66:	83 f8 03             	cmp    $0x3,%eax
80104e69:	75 4c                	jne    80104eb7 <run_mlfq+0x112>
      int q = kernel_pstat.priority[i];
80104e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e6e:	83 e8 80             	sub    $0xffffff80,%eax
80104e71:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e78:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
80104e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104e88:	01 d0                	add    %edx,%eax
80104e8a:	05 00 02 00 00       	add    $0x200,%eax
80104e8f:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e96:	8d 50 01             	lea    0x1(%eax),%edx
80104e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e9c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104ea3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ea6:	01 c8                	add    %ecx,%eax
80104ea8:	05 00 02 00 00       	add    $0x200,%eax
80104ead:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
80104eb4:	eb 01                	jmp    80104eb7 <run_mlfq+0x112>
    if (!kernel_pstat.inuse[i]) continue;
80104eb6:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104eb7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104ebb:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80104ebf:	0f 8e 79 ff ff ff    	jle    80104e3e <run_mlfq+0x99>
    }
  }
}
80104ec5:	90                   	nop
80104ec6:	90                   	nop
80104ec7:	c9                   	leave
80104ec8:	c3                   	ret

80104ec9 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104ec9:	55                   	push   %ebp
80104eca:	89 e5                	mov    %esp,%ebp
80104ecc:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed2:	83 c0 04             	add    $0x4,%eax
80104ed5:	83 ec 08             	sub    $0x8,%esp
80104ed8:	68 b8 ae 10 80       	push   $0x8010aeb8
80104edd:	50                   	push   %eax
80104ede:	e8 43 01 00 00       	call   80105026 <initlock>
80104ee3:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104eec:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104eef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80104efb:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104f02:	90                   	nop
80104f03:	c9                   	leave
80104f04:	c3                   	ret

80104f05 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f05:	55                   	push   %ebp
80104f06:	89 e5                	mov    %esp,%ebp
80104f08:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0e:	83 c0 04             	add    $0x4,%eax
80104f11:	83 ec 0c             	sub    $0xc,%esp
80104f14:	50                   	push   %eax
80104f15:	e8 2e 01 00 00       	call   80105048 <acquire>
80104f1a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f1d:	eb 15                	jmp    80104f34 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f22:	83 c0 04             	add    $0x4,%eax
80104f25:	83 ec 08             	sub    $0x8,%esp
80104f28:	50                   	push   %eax
80104f29:	ff 75 08             	push   0x8(%ebp)
80104f2c:	e8 5c f5 ff ff       	call   8010448d <sleep>
80104f31:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f34:	8b 45 08             	mov    0x8(%ebp),%eax
80104f37:	8b 00                	mov    (%eax),%eax
80104f39:	85 c0                	test   %eax,%eax
80104f3b:	75 e2                	jne    80104f1f <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f40:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f46:	e8 e5 ea ff ff       	call   80103a30 <myproc>
80104f4b:	8b 50 10             	mov    0x10(%eax),%edx
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f54:	8b 45 08             	mov    0x8(%ebp),%eax
80104f57:	83 c0 04             	add    $0x4,%eax
80104f5a:	83 ec 0c             	sub    $0xc,%esp
80104f5d:	50                   	push   %eax
80104f5e:	e8 53 01 00 00       	call   801050b6 <release>
80104f63:	83 c4 10             	add    $0x10,%esp
}
80104f66:	90                   	nop
80104f67:	c9                   	leave
80104f68:	c3                   	ret

80104f69 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f69:	55                   	push   %ebp
80104f6a:	89 e5                	mov    %esp,%ebp
80104f6c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f72:	83 c0 04             	add    $0x4,%eax
80104f75:	83 ec 0c             	sub    $0xc,%esp
80104f78:	50                   	push   %eax
80104f79:	e8 ca 00 00 00       	call   80105048 <acquire>
80104f7e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f81:	8b 45 08             	mov    0x8(%ebp),%eax
80104f84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f94:	83 ec 0c             	sub    $0xc,%esp
80104f97:	ff 75 08             	push   0x8(%ebp)
80104f9a:	e8 d5 f5 ff ff       	call   80104574 <wakeup>
80104f9f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa5:	83 c0 04             	add    $0x4,%eax
80104fa8:	83 ec 0c             	sub    $0xc,%esp
80104fab:	50                   	push   %eax
80104fac:	e8 05 01 00 00       	call   801050b6 <release>
80104fb1:	83 c4 10             	add    $0x10,%esp
}
80104fb4:	90                   	nop
80104fb5:	c9                   	leave
80104fb6:	c3                   	ret

80104fb7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104fb7:	55                   	push   %ebp
80104fb8:	89 e5                	mov    %esp,%ebp
80104fba:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc0:	83 c0 04             	add    $0x4,%eax
80104fc3:	83 ec 0c             	sub    $0xc,%esp
80104fc6:	50                   	push   %eax
80104fc7:	e8 7c 00 00 00       	call   80105048 <acquire>
80104fcc:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd2:	8b 00                	mov    (%eax),%eax
80104fd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fda:	83 c0 04             	add    $0x4,%eax
80104fdd:	83 ec 0c             	sub    $0xc,%esp
80104fe0:	50                   	push   %eax
80104fe1:	e8 d0 00 00 00       	call   801050b6 <release>
80104fe6:	83 c4 10             	add    $0x10,%esp
  return r;
80104fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fec:	c9                   	leave
80104fed:	c3                   	ret

80104fee <readeflags>:
{
80104fee:	55                   	push   %ebp
80104fef:	89 e5                	mov    %esp,%ebp
80104ff1:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ff4:	9c                   	pushf
80104ff5:	58                   	pop    %eax
80104ff6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ff9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ffc:	c9                   	leave
80104ffd:	c3                   	ret

80104ffe <cli>:
{
80104ffe:	55                   	push   %ebp
80104fff:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105001:	fa                   	cli
}
80105002:	90                   	nop
80105003:	5d                   	pop    %ebp
80105004:	c3                   	ret

80105005 <sti>:
{
80105005:	55                   	push   %ebp
80105006:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105008:	fb                   	sti
}
80105009:	90                   	nop
8010500a:	5d                   	pop    %ebp
8010500b:	c3                   	ret

8010500c <xchg>:
{
8010500c:	55                   	push   %ebp
8010500d:	89 e5                	mov    %esp,%ebp
8010500f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105012:	8b 55 08             	mov    0x8(%ebp),%edx
80105015:	8b 45 0c             	mov    0xc(%ebp),%eax
80105018:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010501b:	f0 87 02             	lock xchg %eax,(%edx)
8010501e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105021:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105024:	c9                   	leave
80105025:	c3                   	ret

80105026 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105029:	8b 45 08             	mov    0x8(%ebp),%eax
8010502c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010502f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105032:	8b 45 08             	mov    0x8(%ebp),%eax
80105035:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010503b:	8b 45 08             	mov    0x8(%ebp),%eax
8010503e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105045:	90                   	nop
80105046:	5d                   	pop    %ebp
80105047:	c3                   	ret

80105048 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	53                   	push   %ebx
8010504c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010504f:	e8 5f 01 00 00       	call   801051b3 <pushcli>
  if(holding(lk)){
80105054:	8b 45 08             	mov    0x8(%ebp),%eax
80105057:	83 ec 0c             	sub    $0xc,%esp
8010505a:	50                   	push   %eax
8010505b:	e8 23 01 00 00       	call   80105183 <holding>
80105060:	83 c4 10             	add    $0x10,%esp
80105063:	85 c0                	test   %eax,%eax
80105065:	74 0d                	je     80105074 <acquire+0x2c>
    panic("acquire");
80105067:	83 ec 0c             	sub    $0xc,%esp
8010506a:	68 c3 ae 10 80       	push   $0x8010aec3
8010506f:	e8 35 b5 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105074:	90                   	nop
80105075:	8b 45 08             	mov    0x8(%ebp),%eax
80105078:	83 ec 08             	sub    $0x8,%esp
8010507b:	6a 01                	push   $0x1
8010507d:	50                   	push   %eax
8010507e:	e8 89 ff ff ff       	call   8010500c <xchg>
80105083:	83 c4 10             	add    $0x10,%esp
80105086:	85 c0                	test   %eax,%eax
80105088:	75 eb                	jne    80105075 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010508a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010508f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105092:	e8 21 e9 ff ff       	call   801039b8 <mycpu>
80105097:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010509a:	8b 45 08             	mov    0x8(%ebp),%eax
8010509d:	83 c0 0c             	add    $0xc,%eax
801050a0:	83 ec 08             	sub    $0x8,%esp
801050a3:	50                   	push   %eax
801050a4:	8d 45 08             	lea    0x8(%ebp),%eax
801050a7:	50                   	push   %eax
801050a8:	e8 5b 00 00 00       	call   80105108 <getcallerpcs>
801050ad:	83 c4 10             	add    $0x10,%esp
}
801050b0:	90                   	nop
801050b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050b4:	c9                   	leave
801050b5:	c3                   	ret

801050b6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050b6:	55                   	push   %ebp
801050b7:	89 e5                	mov    %esp,%ebp
801050b9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050bc:	83 ec 0c             	sub    $0xc,%esp
801050bf:	ff 75 08             	push   0x8(%ebp)
801050c2:	e8 bc 00 00 00       	call   80105183 <holding>
801050c7:	83 c4 10             	add    $0x10,%esp
801050ca:	85 c0                	test   %eax,%eax
801050cc:	75 0d                	jne    801050db <release+0x25>
    panic("release");
801050ce:	83 ec 0c             	sub    $0xc,%esp
801050d1:	68 cb ae 10 80       	push   $0x8010aecb
801050d6:	e8 ce b4 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801050db:	8b 45 08             	mov    0x8(%ebp),%eax
801050de:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050e5:	8b 45 08             	mov    0x8(%ebp),%eax
801050e8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801050ef:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801050f4:	8b 45 08             	mov    0x8(%ebp),%eax
801050f7:	8b 55 08             	mov    0x8(%ebp),%edx
801050fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105100:	e8 fb 00 00 00       	call   80105200 <popcli>
}
80105105:	90                   	nop
80105106:	c9                   	leave
80105107:	c3                   	ret

80105108 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105108:	55                   	push   %ebp
80105109:	89 e5                	mov    %esp,%ebp
8010510b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010510e:	8b 45 08             	mov    0x8(%ebp),%eax
80105111:	83 e8 08             	sub    $0x8,%eax
80105114:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105117:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010511e:	eb 38                	jmp    80105158 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105120:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105124:	74 53                	je     80105179 <getcallerpcs+0x71>
80105126:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010512d:	76 4a                	jbe    80105179 <getcallerpcs+0x71>
8010512f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105133:	74 44                	je     80105179 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105135:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105138:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010513f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105142:	01 c2                	add    %eax,%edx
80105144:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105147:	8b 40 04             	mov    0x4(%eax),%eax
8010514a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010514c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514f:	8b 00                	mov    (%eax),%eax
80105151:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105154:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105158:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010515c:	7e c2                	jle    80105120 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010515e:	eb 19                	jmp    80105179 <getcallerpcs+0x71>
    pcs[i] = 0;
80105160:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105163:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010516a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516d:	01 d0                	add    %edx,%eax
8010516f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105175:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105179:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010517d:	7e e1                	jle    80105160 <getcallerpcs+0x58>
}
8010517f:	90                   	nop
80105180:	90                   	nop
80105181:	c9                   	leave
80105182:	c3                   	ret

80105183 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105183:	55                   	push   %ebp
80105184:	89 e5                	mov    %esp,%ebp
80105186:	53                   	push   %ebx
80105187:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	8b 00                	mov    (%eax),%eax
8010518f:	85 c0                	test   %eax,%eax
80105191:	74 16                	je     801051a9 <holding+0x26>
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	8b 58 08             	mov    0x8(%eax),%ebx
80105199:	e8 1a e8 ff ff       	call   801039b8 <mycpu>
8010519e:	39 c3                	cmp    %eax,%ebx
801051a0:	75 07                	jne    801051a9 <holding+0x26>
801051a2:	b8 01 00 00 00       	mov    $0x1,%eax
801051a7:	eb 05                	jmp    801051ae <holding+0x2b>
801051a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051b1:	c9                   	leave
801051b2:	c3                   	ret

801051b3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051b3:	55                   	push   %ebp
801051b4:	89 e5                	mov    %esp,%ebp
801051b6:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801051b9:	e8 30 fe ff ff       	call   80104fee <readeflags>
801051be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801051c1:	e8 38 fe ff ff       	call   80104ffe <cli>
  if(mycpu()->ncli == 0)
801051c6:	e8 ed e7 ff ff       	call   801039b8 <mycpu>
801051cb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051d1:	85 c0                	test   %eax,%eax
801051d3:	75 14                	jne    801051e9 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801051d5:	e8 de e7 ff ff       	call   801039b8 <mycpu>
801051da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051dd:	81 e2 00 02 00 00    	and    $0x200,%edx
801051e3:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801051e9:	e8 ca e7 ff ff       	call   801039b8 <mycpu>
801051ee:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051f4:	83 c2 01             	add    $0x1,%edx
801051f7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801051fd:	90                   	nop
801051fe:	c9                   	leave
801051ff:	c3                   	ret

80105200 <popcli>:

void
popcli(void)
{
80105200:	55                   	push   %ebp
80105201:	89 e5                	mov    %esp,%ebp
80105203:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105206:	e8 e3 fd ff ff       	call   80104fee <readeflags>
8010520b:	25 00 02 00 00       	and    $0x200,%eax
80105210:	85 c0                	test   %eax,%eax
80105212:	74 0d                	je     80105221 <popcli+0x21>
    panic("popcli - interruptible");
80105214:	83 ec 0c             	sub    $0xc,%esp
80105217:	68 d3 ae 10 80       	push   $0x8010aed3
8010521c:	e8 88 b3 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80105221:	e8 92 e7 ff ff       	call   801039b8 <mycpu>
80105226:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010522c:	83 ea 01             	sub    $0x1,%edx
8010522f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105235:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010523b:	85 c0                	test   %eax,%eax
8010523d:	79 0d                	jns    8010524c <popcli+0x4c>
    panic("popcli");
8010523f:	83 ec 0c             	sub    $0xc,%esp
80105242:	68 ea ae 10 80       	push   $0x8010aeea
80105247:	e8 5d b3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010524c:	e8 67 e7 ff ff       	call   801039b8 <mycpu>
80105251:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105257:	85 c0                	test   %eax,%eax
80105259:	75 14                	jne    8010526f <popcli+0x6f>
8010525b:	e8 58 e7 ff ff       	call   801039b8 <mycpu>
80105260:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105266:	85 c0                	test   %eax,%eax
80105268:	74 05                	je     8010526f <popcli+0x6f>
    sti();
8010526a:	e8 96 fd ff ff       	call   80105005 <sti>
}
8010526f:	90                   	nop
80105270:	c9                   	leave
80105271:	c3                   	ret

80105272 <stosb>:
{
80105272:	55                   	push   %ebp
80105273:	89 e5                	mov    %esp,%ebp
80105275:	57                   	push   %edi
80105276:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105277:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010527a:	8b 55 10             	mov    0x10(%ebp),%edx
8010527d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105280:	89 cb                	mov    %ecx,%ebx
80105282:	89 df                	mov    %ebx,%edi
80105284:	89 d1                	mov    %edx,%ecx
80105286:	fc                   	cld
80105287:	f3 aa                	rep stos %al,%es:(%edi)
80105289:	89 ca                	mov    %ecx,%edx
8010528b:	89 fb                	mov    %edi,%ebx
8010528d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105290:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105293:	90                   	nop
80105294:	5b                   	pop    %ebx
80105295:	5f                   	pop    %edi
80105296:	5d                   	pop    %ebp
80105297:	c3                   	ret

80105298 <stosl>:
{
80105298:	55                   	push   %ebp
80105299:	89 e5                	mov    %esp,%ebp
8010529b:	57                   	push   %edi
8010529c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010529d:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a0:	8b 55 10             	mov    0x10(%ebp),%edx
801052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a6:	89 cb                	mov    %ecx,%ebx
801052a8:	89 df                	mov    %ebx,%edi
801052aa:	89 d1                	mov    %edx,%ecx
801052ac:	fc                   	cld
801052ad:	f3 ab                	rep stos %eax,%es:(%edi)
801052af:	89 ca                	mov    %ecx,%edx
801052b1:	89 fb                	mov    %edi,%ebx
801052b3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052b6:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052b9:	90                   	nop
801052ba:	5b                   	pop    %ebx
801052bb:	5f                   	pop    %edi
801052bc:	5d                   	pop    %ebp
801052bd:	c3                   	ret

801052be <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052be:	55                   	push   %ebp
801052bf:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052c1:	8b 45 08             	mov    0x8(%ebp),%eax
801052c4:	83 e0 03             	and    $0x3,%eax
801052c7:	85 c0                	test   %eax,%eax
801052c9:	75 43                	jne    8010530e <memset+0x50>
801052cb:	8b 45 10             	mov    0x10(%ebp),%eax
801052ce:	83 e0 03             	and    $0x3,%eax
801052d1:	85 c0                	test   %eax,%eax
801052d3:	75 39                	jne    8010530e <memset+0x50>
    c &= 0xFF;
801052d5:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052dc:	8b 45 10             	mov    0x10(%ebp),%eax
801052df:	c1 e8 02             	shr    $0x2,%eax
801052e2:	89 c1                	mov    %eax,%ecx
801052e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e7:	c1 e0 18             	shl    $0x18,%eax
801052ea:	89 c2                	mov    %eax,%edx
801052ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ef:	c1 e0 10             	shl    $0x10,%eax
801052f2:	09 c2                	or     %eax,%edx
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	c1 e0 08             	shl    $0x8,%eax
801052fa:	09 d0                	or     %edx,%eax
801052fc:	0b 45 0c             	or     0xc(%ebp),%eax
801052ff:	51                   	push   %ecx
80105300:	50                   	push   %eax
80105301:	ff 75 08             	push   0x8(%ebp)
80105304:	e8 8f ff ff ff       	call   80105298 <stosl>
80105309:	83 c4 0c             	add    $0xc,%esp
8010530c:	eb 12                	jmp    80105320 <memset+0x62>
  } else
    stosb(dst, c, n);
8010530e:	8b 45 10             	mov    0x10(%ebp),%eax
80105311:	50                   	push   %eax
80105312:	ff 75 0c             	push   0xc(%ebp)
80105315:	ff 75 08             	push   0x8(%ebp)
80105318:	e8 55 ff ff ff       	call   80105272 <stosb>
8010531d:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105320:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105323:	c9                   	leave
80105324:	c3                   	ret

80105325 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105325:	55                   	push   %ebp
80105326:	89 e5                	mov    %esp,%ebp
80105328:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010532b:	8b 45 08             	mov    0x8(%ebp),%eax
8010532e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105331:	8b 45 0c             	mov    0xc(%ebp),%eax
80105334:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105337:	eb 2e                	jmp    80105367 <memcmp+0x42>
    if(*s1 != *s2)
80105339:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533c:	0f b6 10             	movzbl (%eax),%edx
8010533f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105342:	0f b6 00             	movzbl (%eax),%eax
80105345:	38 c2                	cmp    %al,%dl
80105347:	74 16                	je     8010535f <memcmp+0x3a>
      return *s1 - *s2;
80105349:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534c:	0f b6 00             	movzbl (%eax),%eax
8010534f:	0f b6 d0             	movzbl %al,%edx
80105352:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105355:	0f b6 00             	movzbl (%eax),%eax
80105358:	0f b6 c0             	movzbl %al,%eax
8010535b:	29 c2                	sub    %eax,%edx
8010535d:	eb 1a                	jmp    80105379 <memcmp+0x54>
    s1++, s2++;
8010535f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105363:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010536d:	89 55 10             	mov    %edx,0x10(%ebp)
80105370:	85 c0                	test   %eax,%eax
80105372:	75 c5                	jne    80105339 <memcmp+0x14>
  }

  return 0;
80105374:	ba 00 00 00 00       	mov    $0x0,%edx
}
80105379:	89 d0                	mov    %edx,%eax
8010537b:	c9                   	leave
8010537c:	c3                   	ret

8010537d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010537d:	55                   	push   %ebp
8010537e:	89 e5                	mov    %esp,%ebp
80105380:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105383:	8b 45 0c             	mov    0xc(%ebp),%eax
80105386:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105389:	8b 45 08             	mov    0x8(%ebp),%eax
8010538c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010538f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105392:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105395:	73 54                	jae    801053eb <memmove+0x6e>
80105397:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010539a:	8b 45 10             	mov    0x10(%ebp),%eax
8010539d:	01 d0                	add    %edx,%eax
8010539f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053a2:	73 47                	jae    801053eb <memmove+0x6e>
    s += n;
801053a4:	8b 45 10             	mov    0x10(%ebp),%eax
801053a7:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053aa:	8b 45 10             	mov    0x10(%ebp),%eax
801053ad:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053b0:	eb 13                	jmp    801053c5 <memmove+0x48>
      *--d = *--s;
801053b2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053b6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053bd:	0f b6 10             	movzbl (%eax),%edx
801053c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053c3:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053c5:	8b 45 10             	mov    0x10(%ebp),%eax
801053c8:	8d 50 ff             	lea    -0x1(%eax),%edx
801053cb:	89 55 10             	mov    %edx,0x10(%ebp)
801053ce:	85 c0                	test   %eax,%eax
801053d0:	75 e0                	jne    801053b2 <memmove+0x35>
  if(s < d && s + n > d){
801053d2:	eb 24                	jmp    801053f8 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053d7:	8d 42 01             	lea    0x1(%edx),%eax
801053da:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e0:	8d 48 01             	lea    0x1(%eax),%ecx
801053e3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801053e6:	0f b6 12             	movzbl (%edx),%edx
801053e9:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053eb:	8b 45 10             	mov    0x10(%ebp),%eax
801053ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f1:	89 55 10             	mov    %edx,0x10(%ebp)
801053f4:	85 c0                	test   %eax,%eax
801053f6:	75 dc                	jne    801053d4 <memmove+0x57>

  return dst;
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053fb:	c9                   	leave
801053fc:	c3                   	ret

801053fd <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053fd:	55                   	push   %ebp
801053fe:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105400:	ff 75 10             	push   0x10(%ebp)
80105403:	ff 75 0c             	push   0xc(%ebp)
80105406:	ff 75 08             	push   0x8(%ebp)
80105409:	e8 6f ff ff ff       	call   8010537d <memmove>
8010540e:	83 c4 0c             	add    $0xc,%esp
}
80105411:	c9                   	leave
80105412:	c3                   	ret

80105413 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105413:	55                   	push   %ebp
80105414:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105416:	eb 0c                	jmp    80105424 <strncmp+0x11>
    n--, p++, q++;
80105418:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010541c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105420:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105424:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105428:	74 1a                	je     80105444 <strncmp+0x31>
8010542a:	8b 45 08             	mov    0x8(%ebp),%eax
8010542d:	0f b6 00             	movzbl (%eax),%eax
80105430:	84 c0                	test   %al,%al
80105432:	74 10                	je     80105444 <strncmp+0x31>
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	0f b6 10             	movzbl (%eax),%edx
8010543a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543d:	0f b6 00             	movzbl (%eax),%eax
80105440:	38 c2                	cmp    %al,%dl
80105442:	74 d4                	je     80105418 <strncmp+0x5>
  if(n == 0)
80105444:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105448:	75 07                	jne    80105451 <strncmp+0x3e>
    return 0;
8010544a:	ba 00 00 00 00       	mov    $0x0,%edx
8010544f:	eb 14                	jmp    80105465 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80105451:	8b 45 08             	mov    0x8(%ebp),%eax
80105454:	0f b6 00             	movzbl (%eax),%eax
80105457:	0f b6 d0             	movzbl %al,%edx
8010545a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010545d:	0f b6 00             	movzbl (%eax),%eax
80105460:	0f b6 c0             	movzbl %al,%eax
80105463:	29 c2                	sub    %eax,%edx
}
80105465:	89 d0                	mov    %edx,%eax
80105467:	5d                   	pop    %ebp
80105468:	c3                   	ret

80105469 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105469:	55                   	push   %ebp
8010546a:	89 e5                	mov    %esp,%ebp
8010546c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010546f:	8b 45 08             	mov    0x8(%ebp),%eax
80105472:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105475:	90                   	nop
80105476:	8b 45 10             	mov    0x10(%ebp),%eax
80105479:	8d 50 ff             	lea    -0x1(%eax),%edx
8010547c:	89 55 10             	mov    %edx,0x10(%ebp)
8010547f:	85 c0                	test   %eax,%eax
80105481:	7e 2c                	jle    801054af <strncpy+0x46>
80105483:	8b 55 0c             	mov    0xc(%ebp),%edx
80105486:	8d 42 01             	lea    0x1(%edx),%eax
80105489:	89 45 0c             	mov    %eax,0xc(%ebp)
8010548c:	8b 45 08             	mov    0x8(%ebp),%eax
8010548f:	8d 48 01             	lea    0x1(%eax),%ecx
80105492:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105495:	0f b6 12             	movzbl (%edx),%edx
80105498:	88 10                	mov    %dl,(%eax)
8010549a:	0f b6 00             	movzbl (%eax),%eax
8010549d:	84 c0                	test   %al,%al
8010549f:	75 d5                	jne    80105476 <strncpy+0xd>
    ;
  while(n-- > 0)
801054a1:	eb 0c                	jmp    801054af <strncpy+0x46>
    *s++ = 0;
801054a3:	8b 45 08             	mov    0x8(%ebp),%eax
801054a6:	8d 50 01             	lea    0x1(%eax),%edx
801054a9:	89 55 08             	mov    %edx,0x8(%ebp)
801054ac:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054af:	8b 45 10             	mov    0x10(%ebp),%eax
801054b2:	8d 50 ff             	lea    -0x1(%eax),%edx
801054b5:	89 55 10             	mov    %edx,0x10(%ebp)
801054b8:	85 c0                	test   %eax,%eax
801054ba:	7f e7                	jg     801054a3 <strncpy+0x3a>
  return os;
801054bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054bf:	c9                   	leave
801054c0:	c3                   	ret

801054c1 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054c1:	55                   	push   %ebp
801054c2:	89 e5                	mov    %esp,%ebp
801054c4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054c7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054d1:	7f 05                	jg     801054d8 <safestrcpy+0x17>
    return os;
801054d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d6:	eb 32                	jmp    8010550a <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801054d8:	90                   	nop
801054d9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054e1:	7e 1e                	jle    80105501 <safestrcpy+0x40>
801054e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801054e6:	8d 42 01             	lea    0x1(%edx),%eax
801054e9:	89 45 0c             	mov    %eax,0xc(%ebp)
801054ec:	8b 45 08             	mov    0x8(%ebp),%eax
801054ef:	8d 48 01             	lea    0x1(%eax),%ecx
801054f2:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054f5:	0f b6 12             	movzbl (%edx),%edx
801054f8:	88 10                	mov    %dl,(%eax)
801054fa:	0f b6 00             	movzbl (%eax),%eax
801054fd:	84 c0                	test   %al,%al
801054ff:	75 d8                	jne    801054d9 <safestrcpy+0x18>
    ;
  *s = 0;
80105501:	8b 45 08             	mov    0x8(%ebp),%eax
80105504:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105507:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010550a:	c9                   	leave
8010550b:	c3                   	ret

8010550c <strlen>:

int
strlen(const char *s)
{
8010550c:	55                   	push   %ebp
8010550d:	89 e5                	mov    %esp,%ebp
8010550f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105512:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105519:	eb 04                	jmp    8010551f <strlen+0x13>
8010551b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010551f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105522:	8b 45 08             	mov    0x8(%ebp),%eax
80105525:	01 d0                	add    %edx,%eax
80105527:	0f b6 00             	movzbl (%eax),%eax
8010552a:	84 c0                	test   %al,%al
8010552c:	75 ed                	jne    8010551b <strlen+0xf>
    ;
  return n;
8010552e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105531:	c9                   	leave
80105532:	c3                   	ret

80105533 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105533:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105537:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010553b:	55                   	push   %ebp
  pushl %ebx
8010553c:	53                   	push   %ebx
  pushl %esi
8010553d:	56                   	push   %esi
  pushl %edi
8010553e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010553f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105541:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105543:	5f                   	pop    %edi
  popl %esi
80105544:	5e                   	pop    %esi
  popl %ebx
80105545:	5b                   	pop    %ebx
  popl %ebp
80105546:	5d                   	pop    %ebp
  ret
80105547:	c3                   	ret

80105548 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105548:	55                   	push   %ebp
80105549:	89 e5                	mov    %esp,%ebp
8010554b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010554e:	e8 dd e4 ff ff       	call   80103a30 <myproc>
80105553:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105559:	8b 00                	mov    (%eax),%eax
8010555b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010555e:	73 0f                	jae    8010556f <fetchint+0x27>
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	8d 50 04             	lea    0x4(%eax),%edx
80105566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105569:	8b 00                	mov    (%eax),%eax
8010556b:	39 d0                	cmp    %edx,%eax
8010556d:	73 07                	jae    80105576 <fetchint+0x2e>
    return -1;
8010556f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105574:	eb 0f                	jmp    80105585 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105576:	8b 45 08             	mov    0x8(%ebp),%eax
80105579:	8b 10                	mov    (%eax),%edx
8010557b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557e:	89 10                	mov    %edx,(%eax)
  return 0;
80105580:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105585:	c9                   	leave
80105586:	c3                   	ret

80105587 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105587:	55                   	push   %ebp
80105588:	89 e5                	mov    %esp,%ebp
8010558a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010558d:	e8 9e e4 ff ff       	call   80103a30 <myproc>
80105592:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105598:	8b 00                	mov    (%eax),%eax
8010559a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010559d:	72 07                	jb     801055a6 <fetchstr+0x1f>
    return -1;
8010559f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a4:	eb 41                	jmp    801055e7 <fetchstr+0x60>
  *pp = (char*)addr;
801055a6:	8b 55 08             	mov    0x8(%ebp),%edx
801055a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ac:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801055ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b1:	8b 00                	mov    (%eax),%eax
801055b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801055b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b9:	8b 00                	mov    (%eax),%eax
801055bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055be:	eb 1a                	jmp    801055da <fetchstr+0x53>
    if(*s == 0)
801055c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c3:	0f b6 00             	movzbl (%eax),%eax
801055c6:	84 c0                	test   %al,%al
801055c8:	75 0c                	jne    801055d6 <fetchstr+0x4f>
      return s - *pp;
801055ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cd:	8b 10                	mov    (%eax),%edx
801055cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d2:	29 d0                	sub    %edx,%eax
801055d4:	eb 11                	jmp    801055e7 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801055d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801055e0:	72 de                	jb     801055c0 <fetchstr+0x39>
  }
  return -1;
801055e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055e7:	c9                   	leave
801055e8:	c3                   	ret

801055e9 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055e9:	55                   	push   %ebp
801055ea:	89 e5                	mov    %esp,%ebp
801055ec:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801055ef:	e8 3c e4 ff ff       	call   80103a30 <myproc>
801055f4:	8b 40 18             	mov    0x18(%eax),%eax
801055f7:	8b 40 44             	mov    0x44(%eax),%eax
801055fa:	8b 55 08             	mov    0x8(%ebp),%edx
801055fd:	c1 e2 02             	shl    $0x2,%edx
80105600:	01 d0                	add    %edx,%eax
80105602:	83 c0 04             	add    $0x4,%eax
80105605:	83 ec 08             	sub    $0x8,%esp
80105608:	ff 75 0c             	push   0xc(%ebp)
8010560b:	50                   	push   %eax
8010560c:	e8 37 ff ff ff       	call   80105548 <fetchint>
80105611:	83 c4 10             	add    $0x10,%esp
}
80105614:	c9                   	leave
80105615:	c3                   	ret

80105616 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105616:	55                   	push   %ebp
80105617:	89 e5                	mov    %esp,%ebp
80105619:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010561c:	e8 0f e4 ff ff       	call   80103a30 <myproc>
80105621:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105624:	83 ec 08             	sub    $0x8,%esp
80105627:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010562a:	50                   	push   %eax
8010562b:	ff 75 08             	push   0x8(%ebp)
8010562e:	e8 b6 ff ff ff       	call   801055e9 <argint>
80105633:	83 c4 10             	add    $0x10,%esp
80105636:	85 c0                	test   %eax,%eax
80105638:	79 07                	jns    80105641 <argptr+0x2b>
    return -1;
8010563a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563f:	eb 3b                	jmp    8010567c <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105645:	78 1f                	js     80105666 <argptr+0x50>
80105647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564a:	8b 00                	mov    (%eax),%eax
8010564c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010564f:	39 c2                	cmp    %eax,%edx
80105651:	73 13                	jae    80105666 <argptr+0x50>
80105653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105656:	89 c2                	mov    %eax,%edx
80105658:	8b 45 10             	mov    0x10(%ebp),%eax
8010565b:	01 c2                	add    %eax,%edx
8010565d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105660:	8b 00                	mov    (%eax),%eax
80105662:	39 d0                	cmp    %edx,%eax
80105664:	73 07                	jae    8010566d <argptr+0x57>
    return -1;
80105666:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010566b:	eb 0f                	jmp    8010567c <argptr+0x66>
  *pp = (char*)i;
8010566d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105670:	89 c2                	mov    %eax,%edx
80105672:	8b 45 0c             	mov    0xc(%ebp),%eax
80105675:	89 10                	mov    %edx,(%eax)
  return 0;
80105677:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010567c:	c9                   	leave
8010567d:	c3                   	ret

8010567e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010567e:	55                   	push   %ebp
8010567f:	89 e5                	mov    %esp,%ebp
80105681:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105684:	83 ec 08             	sub    $0x8,%esp
80105687:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010568a:	50                   	push   %eax
8010568b:	ff 75 08             	push   0x8(%ebp)
8010568e:	e8 56 ff ff ff       	call   801055e9 <argint>
80105693:	83 c4 10             	add    $0x10,%esp
80105696:	85 c0                	test   %eax,%eax
80105698:	79 07                	jns    801056a1 <argstr+0x23>
    return -1;
8010569a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569f:	eb 12                	jmp    801056b3 <argstr+0x35>
  return fetchstr(addr, pp);
801056a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a4:	83 ec 08             	sub    $0x8,%esp
801056a7:	ff 75 0c             	push   0xc(%ebp)
801056aa:	50                   	push   %eax
801056ab:	e8 d7 fe ff ff       	call   80105587 <fetchstr>
801056b0:	83 c4 10             	add    $0x10,%esp
}
801056b3:	c9                   	leave
801056b4:	c3                   	ret

801056b5 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
801056b5:	55                   	push   %ebp
801056b6:	89 e5                	mov    %esp,%ebp
801056b8:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801056bb:	e8 70 e3 ff ff       	call   80103a30 <myproc>
801056c0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801056c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c6:	8b 40 18             	mov    0x18(%eax),%eax
801056c9:	8b 40 1c             	mov    0x1c(%eax),%eax
801056cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d3:	7e 2f                	jle    80105704 <syscall+0x4f>
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	83 f8 19             	cmp    $0x19,%eax
801056db:	77 27                	ja     80105704 <syscall+0x4f>
801056dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e0:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801056e7:	85 c0                	test   %eax,%eax
801056e9:	74 19                	je     80105704 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801056eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ee:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801056f5:	ff d0                	call   *%eax
801056f7:	89 c2                	mov    %eax,%edx
801056f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fc:	8b 40 18             	mov    0x18(%eax),%eax
801056ff:	89 50 1c             	mov    %edx,0x1c(%eax)
80105702:	eb 2c                	jmp    80105730 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105707:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010570a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010570d:	8b 40 10             	mov    0x10(%eax),%eax
80105710:	ff 75 f0             	push   -0x10(%ebp)
80105713:	52                   	push   %edx
80105714:	50                   	push   %eax
80105715:	68 f1 ae 10 80       	push   $0x8010aef1
8010571a:	e8 d5 ac ff ff       	call   801003f4 <cprintf>
8010571f:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105725:	8b 40 18             	mov    0x18(%eax),%eax
80105728:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010572f:	90                   	nop
80105730:	90                   	nop
80105731:	c9                   	leave
80105732:	c3                   	ret

80105733 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105733:	55                   	push   %ebp
80105734:	89 e5                	mov    %esp,%ebp
80105736:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105739:	83 ec 08             	sub    $0x8,%esp
8010573c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010573f:	50                   	push   %eax
80105740:	ff 75 08             	push   0x8(%ebp)
80105743:	e8 a1 fe ff ff       	call   801055e9 <argint>
80105748:	83 c4 10             	add    $0x10,%esp
8010574b:	85 c0                	test   %eax,%eax
8010574d:	79 07                	jns    80105756 <argfd+0x23>
    return -1;
8010574f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105754:	eb 4f                	jmp    801057a5 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105759:	85 c0                	test   %eax,%eax
8010575b:	78 20                	js     8010577d <argfd+0x4a>
8010575d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105760:	83 f8 0f             	cmp    $0xf,%eax
80105763:	7f 18                	jg     8010577d <argfd+0x4a>
80105765:	e8 c6 e2 ff ff       	call   80103a30 <myproc>
8010576a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010576d:	83 c2 08             	add    $0x8,%edx
80105770:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105774:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105777:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010577b:	75 07                	jne    80105784 <argfd+0x51>
    return -1;
8010577d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105782:	eb 21                	jmp    801057a5 <argfd+0x72>
  if(pfd)
80105784:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105788:	74 08                	je     80105792 <argfd+0x5f>
    *pfd = fd;
8010578a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010578d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105790:	89 10                	mov    %edx,(%eax)
  if(pf)
80105792:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105796:	74 08                	je     801057a0 <argfd+0x6d>
    *pf = f;
80105798:	8b 45 10             	mov    0x10(%ebp),%eax
8010579b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579e:	89 10                	mov    %edx,(%eax)
  return 0;
801057a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057a5:	c9                   	leave
801057a6:	c3                   	ret

801057a7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057a7:	55                   	push   %ebp
801057a8:	89 e5                	mov    %esp,%ebp
801057aa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801057ad:	e8 7e e2 ff ff       	call   80103a30 <myproc>
801057b2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801057b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801057bc:	eb 2a                	jmp    801057e8 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801057be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c4:	83 c2 08             	add    $0x8,%edx
801057c7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057cb:	85 c0                	test   %eax,%eax
801057cd:	75 15                	jne    801057e4 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801057cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057d5:	8d 4a 08             	lea    0x8(%edx),%ecx
801057d8:	8b 55 08             	mov    0x8(%ebp),%edx
801057db:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e2:	eb 0f                	jmp    801057f3 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801057e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057e8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801057ec:	7e d0                	jle    801057be <fdalloc+0x17>
    }
  }
  return -1;
801057ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057f3:	c9                   	leave
801057f4:	c3                   	ret

801057f5 <sys_dup>:

int
sys_dup(void)
{
801057f5:	55                   	push   %ebp
801057f6:	89 e5                	mov    %esp,%ebp
801057f8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801057fb:	83 ec 04             	sub    $0x4,%esp
801057fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105801:	50                   	push   %eax
80105802:	6a 00                	push   $0x0
80105804:	6a 00                	push   $0x0
80105806:	e8 28 ff ff ff       	call   80105733 <argfd>
8010580b:	83 c4 10             	add    $0x10,%esp
8010580e:	85 c0                	test   %eax,%eax
80105810:	79 07                	jns    80105819 <sys_dup+0x24>
    return -1;
80105812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105817:	eb 31                	jmp    8010584a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581c:	83 ec 0c             	sub    $0xc,%esp
8010581f:	50                   	push   %eax
80105820:	e8 82 ff ff ff       	call   801057a7 <fdalloc>
80105825:	83 c4 10             	add    $0x10,%esp
80105828:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010582b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582f:	79 07                	jns    80105838 <sys_dup+0x43>
    return -1;
80105831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105836:	eb 12                	jmp    8010584a <sys_dup+0x55>
  filedup(f);
80105838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	50                   	push   %eax
8010583f:	e8 10 b8 ff ff       	call   80101054 <filedup>
80105844:	83 c4 10             	add    $0x10,%esp
  return fd;
80105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010584a:	c9                   	leave
8010584b:	c3                   	ret

8010584c <sys_read>:

int
sys_read(void)
{
8010584c:	55                   	push   %ebp
8010584d:	89 e5                	mov    %esp,%ebp
8010584f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105852:	83 ec 04             	sub    $0x4,%esp
80105855:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105858:	50                   	push   %eax
80105859:	6a 00                	push   $0x0
8010585b:	6a 00                	push   $0x0
8010585d:	e8 d1 fe ff ff       	call   80105733 <argfd>
80105862:	83 c4 10             	add    $0x10,%esp
80105865:	85 c0                	test   %eax,%eax
80105867:	78 2e                	js     80105897 <sys_read+0x4b>
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	6a 02                	push   $0x2
80105872:	e8 72 fd ff ff       	call   801055e9 <argint>
80105877:	83 c4 10             	add    $0x10,%esp
8010587a:	85 c0                	test   %eax,%eax
8010587c:	78 19                	js     80105897 <sys_read+0x4b>
8010587e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105881:	83 ec 04             	sub    $0x4,%esp
80105884:	50                   	push   %eax
80105885:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105888:	50                   	push   %eax
80105889:	6a 01                	push   $0x1
8010588b:	e8 86 fd ff ff       	call   80105616 <argptr>
80105890:	83 c4 10             	add    $0x10,%esp
80105893:	85 c0                	test   %eax,%eax
80105895:	79 07                	jns    8010589e <sys_read+0x52>
    return -1;
80105897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589c:	eb 17                	jmp    801058b5 <sys_read+0x69>
  return fileread(f, p, n);
8010589e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	83 ec 04             	sub    $0x4,%esp
801058aa:	51                   	push   %ecx
801058ab:	52                   	push   %edx
801058ac:	50                   	push   %eax
801058ad:	e8 32 b9 ff ff       	call   801011e4 <fileread>
801058b2:	83 c4 10             	add    $0x10,%esp
}
801058b5:	c9                   	leave
801058b6:	c3                   	ret

801058b7 <sys_write>:

int
sys_write(void)
{
801058b7:	55                   	push   %ebp
801058b8:	89 e5                	mov    %esp,%ebp
801058ba:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058bd:	83 ec 04             	sub    $0x4,%esp
801058c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c3:	50                   	push   %eax
801058c4:	6a 00                	push   $0x0
801058c6:	6a 00                	push   $0x0
801058c8:	e8 66 fe ff ff       	call   80105733 <argfd>
801058cd:	83 c4 10             	add    $0x10,%esp
801058d0:	85 c0                	test   %eax,%eax
801058d2:	78 2e                	js     80105902 <sys_write+0x4b>
801058d4:	83 ec 08             	sub    $0x8,%esp
801058d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058da:	50                   	push   %eax
801058db:	6a 02                	push   $0x2
801058dd:	e8 07 fd ff ff       	call   801055e9 <argint>
801058e2:	83 c4 10             	add    $0x10,%esp
801058e5:	85 c0                	test   %eax,%eax
801058e7:	78 19                	js     80105902 <sys_write+0x4b>
801058e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ec:	83 ec 04             	sub    $0x4,%esp
801058ef:	50                   	push   %eax
801058f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f3:	50                   	push   %eax
801058f4:	6a 01                	push   $0x1
801058f6:	e8 1b fd ff ff       	call   80105616 <argptr>
801058fb:	83 c4 10             	add    $0x10,%esp
801058fe:	85 c0                	test   %eax,%eax
80105900:	79 07                	jns    80105909 <sys_write+0x52>
    return -1;
80105902:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105907:	eb 17                	jmp    80105920 <sys_write+0x69>
  return filewrite(f, p, n);
80105909:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010590c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	83 ec 04             	sub    $0x4,%esp
80105915:	51                   	push   %ecx
80105916:	52                   	push   %edx
80105917:	50                   	push   %eax
80105918:	e8 7f b9 ff ff       	call   8010129c <filewrite>
8010591d:	83 c4 10             	add    $0x10,%esp
}
80105920:	c9                   	leave
80105921:	c3                   	ret

80105922 <sys_close>:

int
sys_close(void)
{
80105922:	55                   	push   %ebp
80105923:	89 e5                	mov    %esp,%ebp
80105925:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105928:	83 ec 04             	sub    $0x4,%esp
8010592b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592e:	50                   	push   %eax
8010592f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105932:	50                   	push   %eax
80105933:	6a 00                	push   $0x0
80105935:	e8 f9 fd ff ff       	call   80105733 <argfd>
8010593a:	83 c4 10             	add    $0x10,%esp
8010593d:	85 c0                	test   %eax,%eax
8010593f:	79 07                	jns    80105948 <sys_close+0x26>
    return -1;
80105941:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105946:	eb 27                	jmp    8010596f <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105948:	e8 e3 e0 ff ff       	call   80103a30 <myproc>
8010594d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105950:	83 c2 08             	add    $0x8,%edx
80105953:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010595a:	00 
  fileclose(f);
8010595b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595e:	83 ec 0c             	sub    $0xc,%esp
80105961:	50                   	push   %eax
80105962:	e8 3e b7 ff ff       	call   801010a5 <fileclose>
80105967:	83 c4 10             	add    $0x10,%esp
  return 0;
8010596a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010596f:	c9                   	leave
80105970:	c3                   	ret

80105971 <sys_fstat>:

int
sys_fstat(void)
{
80105971:	55                   	push   %ebp
80105972:	89 e5                	mov    %esp,%ebp
80105974:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105977:	83 ec 04             	sub    $0x4,%esp
8010597a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597d:	50                   	push   %eax
8010597e:	6a 00                	push   $0x0
80105980:	6a 00                	push   $0x0
80105982:	e8 ac fd ff ff       	call   80105733 <argfd>
80105987:	83 c4 10             	add    $0x10,%esp
8010598a:	85 c0                	test   %eax,%eax
8010598c:	78 17                	js     801059a5 <sys_fstat+0x34>
8010598e:	83 ec 04             	sub    $0x4,%esp
80105991:	6a 14                	push   $0x14
80105993:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105996:	50                   	push   %eax
80105997:	6a 01                	push   $0x1
80105999:	e8 78 fc ff ff       	call   80105616 <argptr>
8010599e:	83 c4 10             	add    $0x10,%esp
801059a1:	85 c0                	test   %eax,%eax
801059a3:	79 07                	jns    801059ac <sys_fstat+0x3b>
    return -1;
801059a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059aa:	eb 13                	jmp    801059bf <sys_fstat+0x4e>
  return filestat(f, st);
801059ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b2:	83 ec 08             	sub    $0x8,%esp
801059b5:	52                   	push   %edx
801059b6:	50                   	push   %eax
801059b7:	e8 d1 b7 ff ff       	call   8010118d <filestat>
801059bc:	83 c4 10             	add    $0x10,%esp
}
801059bf:	c9                   	leave
801059c0:	c3                   	ret

801059c1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059c1:	55                   	push   %ebp
801059c2:	89 e5                	mov    %esp,%ebp
801059c4:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059c7:	83 ec 08             	sub    $0x8,%esp
801059ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059cd:	50                   	push   %eax
801059ce:	6a 00                	push   $0x0
801059d0:	e8 a9 fc ff ff       	call   8010567e <argstr>
801059d5:	83 c4 10             	add    $0x10,%esp
801059d8:	85 c0                	test   %eax,%eax
801059da:	78 15                	js     801059f1 <sys_link+0x30>
801059dc:	83 ec 08             	sub    $0x8,%esp
801059df:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059e2:	50                   	push   %eax
801059e3:	6a 01                	push   $0x1
801059e5:	e8 94 fc ff ff       	call   8010567e <argstr>
801059ea:	83 c4 10             	add    $0x10,%esp
801059ed:	85 c0                	test   %eax,%eax
801059ef:	79 0a                	jns    801059fb <sys_link+0x3a>
    return -1;
801059f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f6:	e9 68 01 00 00       	jmp    80105b63 <sys_link+0x1a2>

  begin_op();
801059fb:	e8 3e d6 ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105a00:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a03:	83 ec 0c             	sub    $0xc,%esp
80105a06:	50                   	push   %eax
80105a07:	e8 19 cb ff ff       	call   80102525 <namei>
80105a0c:	83 c4 10             	add    $0x10,%esp
80105a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a16:	75 0f                	jne    80105a27 <sys_link+0x66>
    end_op();
80105a18:	e8 ad d6 ff ff       	call   801030ca <end_op>
    return -1;
80105a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a22:	e9 3c 01 00 00       	jmp    80105b63 <sys_link+0x1a2>
  }

  ilock(ip);
80105a27:	83 ec 0c             	sub    $0xc,%esp
80105a2a:	ff 75 f4             	push   -0xc(%ebp)
80105a2d:	e8 c0 bf ff ff       	call   801019f2 <ilock>
80105a32:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a38:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a3c:	66 83 f8 01          	cmp    $0x1,%ax
80105a40:	75 1d                	jne    80105a5f <sys_link+0x9e>
    iunlockput(ip);
80105a42:	83 ec 0c             	sub    $0xc,%esp
80105a45:	ff 75 f4             	push   -0xc(%ebp)
80105a48:	e8 d6 c1 ff ff       	call   80101c23 <iunlockput>
80105a4d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a50:	e8 75 d6 ff ff       	call   801030ca <end_op>
    return -1;
80105a55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5a:	e9 04 01 00 00       	jmp    80105b63 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a66:	83 c0 01             	add    $0x1,%eax
80105a69:	89 c2                	mov    %eax,%edx
80105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a72:	83 ec 0c             	sub    $0xc,%esp
80105a75:	ff 75 f4             	push   -0xc(%ebp)
80105a78:	e8 98 bd ff ff       	call   80101815 <iupdate>
80105a7d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a80:	83 ec 0c             	sub    $0xc,%esp
80105a83:	ff 75 f4             	push   -0xc(%ebp)
80105a86:	e8 7a c0 ff ff       	call   80101b05 <iunlock>
80105a8b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a91:	83 ec 08             	sub    $0x8,%esp
80105a94:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a97:	52                   	push   %edx
80105a98:	50                   	push   %eax
80105a99:	e8 a3 ca ff ff       	call   80102541 <nameiparent>
80105a9e:	83 c4 10             	add    $0x10,%esp
80105aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105aa4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aa8:	74 71                	je     80105b1b <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105aaa:	83 ec 0c             	sub    $0xc,%esp
80105aad:	ff 75 f0             	push   -0x10(%ebp)
80105ab0:	e8 3d bf ff ff       	call   801019f2 <ilock>
80105ab5:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abb:	8b 10                	mov    (%eax),%edx
80105abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac0:	8b 00                	mov    (%eax),%eax
80105ac2:	39 c2                	cmp    %eax,%edx
80105ac4:	75 1d                	jne    80105ae3 <sys_link+0x122>
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	8b 40 04             	mov    0x4(%eax),%eax
80105acc:	83 ec 04             	sub    $0x4,%esp
80105acf:	50                   	push   %eax
80105ad0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ad3:	50                   	push   %eax
80105ad4:	ff 75 f0             	push   -0x10(%ebp)
80105ad7:	e8 b2 c7 ff ff       	call   8010228e <dirlink>
80105adc:	83 c4 10             	add    $0x10,%esp
80105adf:	85 c0                	test   %eax,%eax
80105ae1:	79 10                	jns    80105af3 <sys_link+0x132>
    iunlockput(dp);
80105ae3:	83 ec 0c             	sub    $0xc,%esp
80105ae6:	ff 75 f0             	push   -0x10(%ebp)
80105ae9:	e8 35 c1 ff ff       	call   80101c23 <iunlockput>
80105aee:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105af1:	eb 29                	jmp    80105b1c <sys_link+0x15b>
  }
  iunlockput(dp);
80105af3:	83 ec 0c             	sub    $0xc,%esp
80105af6:	ff 75 f0             	push   -0x10(%ebp)
80105af9:	e8 25 c1 ff ff       	call   80101c23 <iunlockput>
80105afe:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b01:	83 ec 0c             	sub    $0xc,%esp
80105b04:	ff 75 f4             	push   -0xc(%ebp)
80105b07:	e8 47 c0 ff ff       	call   80101b53 <iput>
80105b0c:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b0f:	e8 b6 d5 ff ff       	call   801030ca <end_op>

  return 0;
80105b14:	b8 00 00 00 00       	mov    $0x0,%eax
80105b19:	eb 48                	jmp    80105b63 <sys_link+0x1a2>
    goto bad;
80105b1b:	90                   	nop

bad:
  ilock(ip);
80105b1c:	83 ec 0c             	sub    $0xc,%esp
80105b1f:	ff 75 f4             	push   -0xc(%ebp)
80105b22:	e8 cb be ff ff       	call   801019f2 <ilock>
80105b27:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b31:	83 e8 01             	sub    $0x1,%eax
80105b34:	89 c2                	mov    %eax,%edx
80105b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b39:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b3d:	83 ec 0c             	sub    $0xc,%esp
80105b40:	ff 75 f4             	push   -0xc(%ebp)
80105b43:	e8 cd bc ff ff       	call   80101815 <iupdate>
80105b48:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b4b:	83 ec 0c             	sub    $0xc,%esp
80105b4e:	ff 75 f4             	push   -0xc(%ebp)
80105b51:	e8 cd c0 ff ff       	call   80101c23 <iunlockput>
80105b56:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b59:	e8 6c d5 ff ff       	call   801030ca <end_op>
  return -1;
80105b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b63:	c9                   	leave
80105b64:	c3                   	ret

80105b65 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b65:	55                   	push   %ebp
80105b66:	89 e5                	mov    %esp,%ebp
80105b68:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b6b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b72:	eb 40                	jmp    80105bb4 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b77:	6a 10                	push   $0x10
80105b79:	50                   	push   %eax
80105b7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b7d:	50                   	push   %eax
80105b7e:	ff 75 08             	push   0x8(%ebp)
80105b81:	e8 58 c3 ff ff       	call   80101ede <readi>
80105b86:	83 c4 10             	add    $0x10,%esp
80105b89:	83 f8 10             	cmp    $0x10,%eax
80105b8c:	74 0d                	je     80105b9b <isdirempty+0x36>
      panic("isdirempty: readi");
80105b8e:	83 ec 0c             	sub    $0xc,%esp
80105b91:	68 0d af 10 80       	push   $0x8010af0d
80105b96:	e8 0e aa ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105b9b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b9f:	66 85 c0             	test   %ax,%ax
80105ba2:	74 07                	je     80105bab <isdirempty+0x46>
      return 0;
80105ba4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba9:	eb 1b                	jmp    80105bc6 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bae:	83 c0 10             	add    $0x10,%eax
80105bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb7:	8b 40 58             	mov    0x58(%eax),%eax
80105bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bbd:	39 c2                	cmp    %eax,%edx
80105bbf:	72 b3                	jb     80105b74 <isdirempty+0xf>
  }
  return 1;
80105bc1:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bc6:	c9                   	leave
80105bc7:	c3                   	ret

80105bc8 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bc8:	55                   	push   %ebp
80105bc9:	89 e5                	mov    %esp,%ebp
80105bcb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bce:	83 ec 08             	sub    $0x8,%esp
80105bd1:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bd4:	50                   	push   %eax
80105bd5:	6a 00                	push   $0x0
80105bd7:	e8 a2 fa ff ff       	call   8010567e <argstr>
80105bdc:	83 c4 10             	add    $0x10,%esp
80105bdf:	85 c0                	test   %eax,%eax
80105be1:	79 0a                	jns    80105bed <sys_unlink+0x25>
    return -1;
80105be3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be8:	e9 bf 01 00 00       	jmp    80105dac <sys_unlink+0x1e4>

  begin_op();
80105bed:	e8 4c d4 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bf2:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bf5:	83 ec 08             	sub    $0x8,%esp
80105bf8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bfb:	52                   	push   %edx
80105bfc:	50                   	push   %eax
80105bfd:	e8 3f c9 ff ff       	call   80102541 <nameiparent>
80105c02:	83 c4 10             	add    $0x10,%esp
80105c05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c0c:	75 0f                	jne    80105c1d <sys_unlink+0x55>
    end_op();
80105c0e:	e8 b7 d4 ff ff       	call   801030ca <end_op>
    return -1;
80105c13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c18:	e9 8f 01 00 00       	jmp    80105dac <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c1d:	83 ec 0c             	sub    $0xc,%esp
80105c20:	ff 75 f4             	push   -0xc(%ebp)
80105c23:	e8 ca bd ff ff       	call   801019f2 <ilock>
80105c28:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c2b:	83 ec 08             	sub    $0x8,%esp
80105c2e:	68 1f af 10 80       	push   $0x8010af1f
80105c33:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c36:	50                   	push   %eax
80105c37:	e8 7d c5 ff ff       	call   801021b9 <namecmp>
80105c3c:	83 c4 10             	add    $0x10,%esp
80105c3f:	85 c0                	test   %eax,%eax
80105c41:	0f 84 49 01 00 00    	je     80105d90 <sys_unlink+0x1c8>
80105c47:	83 ec 08             	sub    $0x8,%esp
80105c4a:	68 21 af 10 80       	push   $0x8010af21
80105c4f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c52:	50                   	push   %eax
80105c53:	e8 61 c5 ff ff       	call   801021b9 <namecmp>
80105c58:	83 c4 10             	add    $0x10,%esp
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	0f 84 2d 01 00 00    	je     80105d90 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c63:	83 ec 04             	sub    $0x4,%esp
80105c66:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c69:	50                   	push   %eax
80105c6a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c6d:	50                   	push   %eax
80105c6e:	ff 75 f4             	push   -0xc(%ebp)
80105c71:	e8 5e c5 ff ff       	call   801021d4 <dirlookup>
80105c76:	83 c4 10             	add    $0x10,%esp
80105c79:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c7c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c80:	0f 84 0d 01 00 00    	je     80105d93 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c86:	83 ec 0c             	sub    $0xc,%esp
80105c89:	ff 75 f0             	push   -0x10(%ebp)
80105c8c:	e8 61 bd ff ff       	call   801019f2 <ilock>
80105c91:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c97:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c9b:	66 85 c0             	test   %ax,%ax
80105c9e:	7f 0d                	jg     80105cad <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105ca0:	83 ec 0c             	sub    $0xc,%esp
80105ca3:	68 24 af 10 80       	push   $0x8010af24
80105ca8:	e8 fc a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cb4:	66 83 f8 01          	cmp    $0x1,%ax
80105cb8:	75 25                	jne    80105cdf <sys_unlink+0x117>
80105cba:	83 ec 0c             	sub    $0xc,%esp
80105cbd:	ff 75 f0             	push   -0x10(%ebp)
80105cc0:	e8 a0 fe ff ff       	call   80105b65 <isdirempty>
80105cc5:	83 c4 10             	add    $0x10,%esp
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	75 13                	jne    80105cdf <sys_unlink+0x117>
    iunlockput(ip);
80105ccc:	83 ec 0c             	sub    $0xc,%esp
80105ccf:	ff 75 f0             	push   -0x10(%ebp)
80105cd2:	e8 4c bf ff ff       	call   80101c23 <iunlockput>
80105cd7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cda:	e9 b5 00 00 00       	jmp    80105d94 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cdf:	83 ec 04             	sub    $0x4,%esp
80105ce2:	6a 10                	push   $0x10
80105ce4:	6a 00                	push   $0x0
80105ce6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ce9:	50                   	push   %eax
80105cea:	e8 cf f5 ff ff       	call   801052be <memset>
80105cef:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cf2:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cf5:	6a 10                	push   $0x10
80105cf7:	50                   	push   %eax
80105cf8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cfb:	50                   	push   %eax
80105cfc:	ff 75 f4             	push   -0xc(%ebp)
80105cff:	e8 2f c3 ff ff       	call   80102033 <writei>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	83 f8 10             	cmp    $0x10,%eax
80105d0a:	74 0d                	je     80105d19 <sys_unlink+0x151>
    panic("unlink: writei");
80105d0c:	83 ec 0c             	sub    $0xc,%esp
80105d0f:	68 36 af 10 80       	push   $0x8010af36
80105d14:	e8 90 a8 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d20:	66 83 f8 01          	cmp    $0x1,%ax
80105d24:	75 21                	jne    80105d47 <sys_unlink+0x17f>
    dp->nlink--;
80105d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d29:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d2d:	83 e8 01             	sub    $0x1,%eax
80105d30:	89 c2                	mov    %eax,%edx
80105d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d35:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105d39:	83 ec 0c             	sub    $0xc,%esp
80105d3c:	ff 75 f4             	push   -0xc(%ebp)
80105d3f:	e8 d1 ba ff ff       	call   80101815 <iupdate>
80105d44:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d47:	83 ec 0c             	sub    $0xc,%esp
80105d4a:	ff 75 f4             	push   -0xc(%ebp)
80105d4d:	e8 d1 be ff ff       	call   80101c23 <iunlockput>
80105d52:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d58:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d5c:	83 e8 01             	sub    $0x1,%eax
80105d5f:	89 c2                	mov    %eax,%edx
80105d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d64:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d68:	83 ec 0c             	sub    $0xc,%esp
80105d6b:	ff 75 f0             	push   -0x10(%ebp)
80105d6e:	e8 a2 ba ff ff       	call   80101815 <iupdate>
80105d73:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d76:	83 ec 0c             	sub    $0xc,%esp
80105d79:	ff 75 f0             	push   -0x10(%ebp)
80105d7c:	e8 a2 be ff ff       	call   80101c23 <iunlockput>
80105d81:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d84:	e8 41 d3 ff ff       	call   801030ca <end_op>

  return 0;
80105d89:	b8 00 00 00 00       	mov    $0x0,%eax
80105d8e:	eb 1c                	jmp    80105dac <sys_unlink+0x1e4>
    goto bad;
80105d90:	90                   	nop
80105d91:	eb 01                	jmp    80105d94 <sys_unlink+0x1cc>
    goto bad;
80105d93:	90                   	nop

bad:
  iunlockput(dp);
80105d94:	83 ec 0c             	sub    $0xc,%esp
80105d97:	ff 75 f4             	push   -0xc(%ebp)
80105d9a:	e8 84 be ff ff       	call   80101c23 <iunlockput>
80105d9f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105da2:	e8 23 d3 ff ff       	call   801030ca <end_op>
  return -1;
80105da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dac:	c9                   	leave
80105dad:	c3                   	ret

80105dae <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dae:	55                   	push   %ebp
80105daf:	89 e5                	mov    %esp,%ebp
80105db1:	83 ec 38             	sub    $0x38,%esp
80105db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105db7:	8b 55 10             	mov    0x10(%ebp),%edx
80105dba:	8b 45 14             	mov    0x14(%ebp),%eax
80105dbd:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dc1:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dc5:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dc9:	83 ec 08             	sub    $0x8,%esp
80105dcc:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dcf:	50                   	push   %eax
80105dd0:	ff 75 08             	push   0x8(%ebp)
80105dd3:	e8 69 c7 ff ff       	call   80102541 <nameiparent>
80105dd8:	83 c4 10             	add    $0x10,%esp
80105ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de2:	75 0a                	jne    80105dee <create+0x40>
    return 0;
80105de4:	b8 00 00 00 00       	mov    $0x0,%eax
80105de9:	e9 90 01 00 00       	jmp    80105f7e <create+0x1d0>
  ilock(dp);
80105dee:	83 ec 0c             	sub    $0xc,%esp
80105df1:	ff 75 f4             	push   -0xc(%ebp)
80105df4:	e8 f9 bb ff ff       	call   801019f2 <ilock>
80105df9:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dfc:	83 ec 04             	sub    $0x4,%esp
80105dff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e02:	50                   	push   %eax
80105e03:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e06:	50                   	push   %eax
80105e07:	ff 75 f4             	push   -0xc(%ebp)
80105e0a:	e8 c5 c3 ff ff       	call   801021d4 <dirlookup>
80105e0f:	83 c4 10             	add    $0x10,%esp
80105e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e19:	74 50                	je     80105e6b <create+0xbd>
    iunlockput(dp);
80105e1b:	83 ec 0c             	sub    $0xc,%esp
80105e1e:	ff 75 f4             	push   -0xc(%ebp)
80105e21:	e8 fd bd ff ff       	call   80101c23 <iunlockput>
80105e26:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e29:	83 ec 0c             	sub    $0xc,%esp
80105e2c:	ff 75 f0             	push   -0x10(%ebp)
80105e2f:	e8 be bb ff ff       	call   801019f2 <ilock>
80105e34:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e37:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e3c:	75 15                	jne    80105e53 <create+0xa5>
80105e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e41:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e45:	66 83 f8 02          	cmp    $0x2,%ax
80105e49:	75 08                	jne    80105e53 <create+0xa5>
      return ip;
80105e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4e:	e9 2b 01 00 00       	jmp    80105f7e <create+0x1d0>
    iunlockput(ip);
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	ff 75 f0             	push   -0x10(%ebp)
80105e59:	e8 c5 bd ff ff       	call   80101c23 <iunlockput>
80105e5e:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e61:	b8 00 00 00 00       	mov    $0x0,%eax
80105e66:	e9 13 01 00 00       	jmp    80105f7e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e6b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e72:	8b 00                	mov    (%eax),%eax
80105e74:	83 ec 08             	sub    $0x8,%esp
80105e77:	52                   	push   %edx
80105e78:	50                   	push   %eax
80105e79:	e8 c1 b8 ff ff       	call   8010173f <ialloc>
80105e7e:	83 c4 10             	add    $0x10,%esp
80105e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e88:	75 0d                	jne    80105e97 <create+0xe9>
    panic("create: ialloc");
80105e8a:	83 ec 0c             	sub    $0xc,%esp
80105e8d:	68 45 af 10 80       	push   $0x8010af45
80105e92:	e8 12 a7 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105e97:	83 ec 0c             	sub    $0xc,%esp
80105e9a:	ff 75 f0             	push   -0x10(%ebp)
80105e9d:	e8 50 bb ff ff       	call   801019f2 <ilock>
80105ea2:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea8:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105eac:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb3:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eb7:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebe:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105ec4:	83 ec 0c             	sub    $0xc,%esp
80105ec7:	ff 75 f0             	push   -0x10(%ebp)
80105eca:	e8 46 b9 ff ff       	call   80101815 <iupdate>
80105ecf:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ed2:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ed7:	75 6a                	jne    80105f43 <create+0x195>
    dp->nlink++;  // for ".."
80105ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ee0:	83 c0 01             	add    $0x1,%eax
80105ee3:	89 c2                	mov    %eax,%edx
80105ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee8:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105eec:	83 ec 0c             	sub    $0xc,%esp
80105eef:	ff 75 f4             	push   -0xc(%ebp)
80105ef2:	e8 1e b9 ff ff       	call   80101815 <iupdate>
80105ef7:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efd:	8b 40 04             	mov    0x4(%eax),%eax
80105f00:	83 ec 04             	sub    $0x4,%esp
80105f03:	50                   	push   %eax
80105f04:	68 1f af 10 80       	push   $0x8010af1f
80105f09:	ff 75 f0             	push   -0x10(%ebp)
80105f0c:	e8 7d c3 ff ff       	call   8010228e <dirlink>
80105f11:	83 c4 10             	add    $0x10,%esp
80105f14:	85 c0                	test   %eax,%eax
80105f16:	78 1e                	js     80105f36 <create+0x188>
80105f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1b:	8b 40 04             	mov    0x4(%eax),%eax
80105f1e:	83 ec 04             	sub    $0x4,%esp
80105f21:	50                   	push   %eax
80105f22:	68 21 af 10 80       	push   $0x8010af21
80105f27:	ff 75 f0             	push   -0x10(%ebp)
80105f2a:	e8 5f c3 ff ff       	call   8010228e <dirlink>
80105f2f:	83 c4 10             	add    $0x10,%esp
80105f32:	85 c0                	test   %eax,%eax
80105f34:	79 0d                	jns    80105f43 <create+0x195>
      panic("create dots");
80105f36:	83 ec 0c             	sub    $0xc,%esp
80105f39:	68 54 af 10 80       	push   $0x8010af54
80105f3e:	e8 66 a6 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f46:	8b 40 04             	mov    0x4(%eax),%eax
80105f49:	83 ec 04             	sub    $0x4,%esp
80105f4c:	50                   	push   %eax
80105f4d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f50:	50                   	push   %eax
80105f51:	ff 75 f4             	push   -0xc(%ebp)
80105f54:	e8 35 c3 ff ff       	call   8010228e <dirlink>
80105f59:	83 c4 10             	add    $0x10,%esp
80105f5c:	85 c0                	test   %eax,%eax
80105f5e:	79 0d                	jns    80105f6d <create+0x1bf>
    panic("create: dirlink");
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	68 60 af 10 80       	push   $0x8010af60
80105f68:	e8 3c a6 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105f6d:	83 ec 0c             	sub    $0xc,%esp
80105f70:	ff 75 f4             	push   -0xc(%ebp)
80105f73:	e8 ab bc ff ff       	call   80101c23 <iunlockput>
80105f78:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f7e:	c9                   	leave
80105f7f:	c3                   	ret

80105f80 <sys_open>:

int
sys_open(void)
{
80105f80:	55                   	push   %ebp
80105f81:	89 e5                	mov    %esp,%ebp
80105f83:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f86:	83 ec 08             	sub    $0x8,%esp
80105f89:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f8c:	50                   	push   %eax
80105f8d:	6a 00                	push   $0x0
80105f8f:	e8 ea f6 ff ff       	call   8010567e <argstr>
80105f94:	83 c4 10             	add    $0x10,%esp
80105f97:	85 c0                	test   %eax,%eax
80105f99:	78 15                	js     80105fb0 <sys_open+0x30>
80105f9b:	83 ec 08             	sub    $0x8,%esp
80105f9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fa1:	50                   	push   %eax
80105fa2:	6a 01                	push   $0x1
80105fa4:	e8 40 f6 ff ff       	call   801055e9 <argint>
80105fa9:	83 c4 10             	add    $0x10,%esp
80105fac:	85 c0                	test   %eax,%eax
80105fae:	79 0a                	jns    80105fba <sys_open+0x3a>
    return -1;
80105fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb5:	e9 61 01 00 00       	jmp    8010611b <sys_open+0x19b>

  begin_op();
80105fba:	e8 7f d0 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc2:	25 00 02 00 00       	and    $0x200,%eax
80105fc7:	85 c0                	test   %eax,%eax
80105fc9:	74 2a                	je     80105ff5 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fce:	6a 00                	push   $0x0
80105fd0:	6a 00                	push   $0x0
80105fd2:	6a 02                	push   $0x2
80105fd4:	50                   	push   %eax
80105fd5:	e8 d4 fd ff ff       	call   80105dae <create>
80105fda:	83 c4 10             	add    $0x10,%esp
80105fdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fe0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe4:	75 75                	jne    8010605b <sys_open+0xdb>
      end_op();
80105fe6:	e8 df d0 ff ff       	call   801030ca <end_op>
      return -1;
80105feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff0:	e9 26 01 00 00       	jmp    8010611b <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ff5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff8:	83 ec 0c             	sub    $0xc,%esp
80105ffb:	50                   	push   %eax
80105ffc:	e8 24 c5 ff ff       	call   80102525 <namei>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106007:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010600b:	75 0f                	jne    8010601c <sys_open+0x9c>
      end_op();
8010600d:	e8 b8 d0 ff ff       	call   801030ca <end_op>
      return -1;
80106012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106017:	e9 ff 00 00 00       	jmp    8010611b <sys_open+0x19b>
    }
    ilock(ip);
8010601c:	83 ec 0c             	sub    $0xc,%esp
8010601f:	ff 75 f4             	push   -0xc(%ebp)
80106022:	e8 cb b9 ff ff       	call   801019f2 <ilock>
80106027:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010602a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106031:	66 83 f8 01          	cmp    $0x1,%ax
80106035:	75 24                	jne    8010605b <sys_open+0xdb>
80106037:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010603a:	85 c0                	test   %eax,%eax
8010603c:	74 1d                	je     8010605b <sys_open+0xdb>
      iunlockput(ip);
8010603e:	83 ec 0c             	sub    $0xc,%esp
80106041:	ff 75 f4             	push   -0xc(%ebp)
80106044:	e8 da bb ff ff       	call   80101c23 <iunlockput>
80106049:	83 c4 10             	add    $0x10,%esp
      end_op();
8010604c:	e8 79 d0 ff ff       	call   801030ca <end_op>
      return -1;
80106051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106056:	e9 c0 00 00 00       	jmp    8010611b <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010605b:	e8 87 af ff ff       	call   80100fe7 <filealloc>
80106060:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106063:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106067:	74 17                	je     80106080 <sys_open+0x100>
80106069:	83 ec 0c             	sub    $0xc,%esp
8010606c:	ff 75 f0             	push   -0x10(%ebp)
8010606f:	e8 33 f7 ff ff       	call   801057a7 <fdalloc>
80106074:	83 c4 10             	add    $0x10,%esp
80106077:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010607a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010607e:	79 2e                	jns    801060ae <sys_open+0x12e>
    if(f)
80106080:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106084:	74 0e                	je     80106094 <sys_open+0x114>
      fileclose(f);
80106086:	83 ec 0c             	sub    $0xc,%esp
80106089:	ff 75 f0             	push   -0x10(%ebp)
8010608c:	e8 14 b0 ff ff       	call   801010a5 <fileclose>
80106091:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106094:	83 ec 0c             	sub    $0xc,%esp
80106097:	ff 75 f4             	push   -0xc(%ebp)
8010609a:	e8 84 bb ff ff       	call   80101c23 <iunlockput>
8010609f:	83 c4 10             	add    $0x10,%esp
    end_op();
801060a2:	e8 23 d0 ff ff       	call   801030ca <end_op>
    return -1;
801060a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ac:	eb 6d                	jmp    8010611b <sys_open+0x19b>
  }
  iunlock(ip);
801060ae:	83 ec 0c             	sub    $0xc,%esp
801060b1:	ff 75 f4             	push   -0xc(%ebp)
801060b4:	e8 4c ba ff ff       	call   80101b05 <iunlock>
801060b9:	83 c4 10             	add    $0x10,%esp
  end_op();
801060bc:	e8 09 d0 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
801060c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060d0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e0:	83 e0 01             	and    $0x1,%eax
801060e3:	85 c0                	test   %eax,%eax
801060e5:	0f 94 c0             	sete   %al
801060e8:	89 c2                	mov    %eax,%edx
801060ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ed:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f3:	83 e0 01             	and    $0x1,%eax
801060f6:	85 c0                	test   %eax,%eax
801060f8:	75 0a                	jne    80106104 <sys_open+0x184>
801060fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060fd:	83 e0 02             	and    $0x2,%eax
80106100:	85 c0                	test   %eax,%eax
80106102:	74 07                	je     8010610b <sys_open+0x18b>
80106104:	b8 01 00 00 00       	mov    $0x1,%eax
80106109:	eb 05                	jmp    80106110 <sys_open+0x190>
8010610b:	b8 00 00 00 00       	mov    $0x0,%eax
80106110:	89 c2                	mov    %eax,%edx
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106118:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010611b:	c9                   	leave
8010611c:	c3                   	ret

8010611d <sys_mkdir>:

int
sys_mkdir(void)
{
8010611d:	55                   	push   %ebp
8010611e:	89 e5                	mov    %esp,%ebp
80106120:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106123:	e8 16 cf ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106128:	83 ec 08             	sub    $0x8,%esp
8010612b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010612e:	50                   	push   %eax
8010612f:	6a 00                	push   $0x0
80106131:	e8 48 f5 ff ff       	call   8010567e <argstr>
80106136:	83 c4 10             	add    $0x10,%esp
80106139:	85 c0                	test   %eax,%eax
8010613b:	78 1b                	js     80106158 <sys_mkdir+0x3b>
8010613d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106140:	6a 00                	push   $0x0
80106142:	6a 00                	push   $0x0
80106144:	6a 01                	push   $0x1
80106146:	50                   	push   %eax
80106147:	e8 62 fc ff ff       	call   80105dae <create>
8010614c:	83 c4 10             	add    $0x10,%esp
8010614f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106152:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106156:	75 0c                	jne    80106164 <sys_mkdir+0x47>
    end_op();
80106158:	e8 6d cf ff ff       	call   801030ca <end_op>
    return -1;
8010615d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106162:	eb 18                	jmp    8010617c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106164:	83 ec 0c             	sub    $0xc,%esp
80106167:	ff 75 f4             	push   -0xc(%ebp)
8010616a:	e8 b4 ba ff ff       	call   80101c23 <iunlockput>
8010616f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106172:	e8 53 cf ff ff       	call   801030ca <end_op>
  return 0;
80106177:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010617c:	c9                   	leave
8010617d:	c3                   	ret

8010617e <sys_mknod>:

int
sys_mknod(void)
{
8010617e:	55                   	push   %ebp
8010617f:	89 e5                	mov    %esp,%ebp
80106181:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106184:	e8 b5 ce ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80106189:	83 ec 08             	sub    $0x8,%esp
8010618c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010618f:	50                   	push   %eax
80106190:	6a 00                	push   $0x0
80106192:	e8 e7 f4 ff ff       	call   8010567e <argstr>
80106197:	83 c4 10             	add    $0x10,%esp
8010619a:	85 c0                	test   %eax,%eax
8010619c:	78 4f                	js     801061ed <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010619e:	83 ec 08             	sub    $0x8,%esp
801061a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061a4:	50                   	push   %eax
801061a5:	6a 01                	push   $0x1
801061a7:	e8 3d f4 ff ff       	call   801055e9 <argint>
801061ac:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801061af:	85 c0                	test   %eax,%eax
801061b1:	78 3a                	js     801061ed <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801061b3:	83 ec 08             	sub    $0x8,%esp
801061b6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b9:	50                   	push   %eax
801061ba:	6a 02                	push   $0x2
801061bc:	e8 28 f4 ff ff       	call   801055e9 <argint>
801061c1:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061c4:	85 c0                	test   %eax,%eax
801061c6:	78 25                	js     801061ed <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061cb:	0f bf c8             	movswl %ax,%ecx
801061ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061d1:	0f bf d0             	movswl %ax,%edx
801061d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d7:	51                   	push   %ecx
801061d8:	52                   	push   %edx
801061d9:	6a 03                	push   $0x3
801061db:	50                   	push   %eax
801061dc:	e8 cd fb ff ff       	call   80105dae <create>
801061e1:	83 c4 10             	add    $0x10,%esp
801061e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801061e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061eb:	75 0c                	jne    801061f9 <sys_mknod+0x7b>
    end_op();
801061ed:	e8 d8 ce ff ff       	call   801030ca <end_op>
    return -1;
801061f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f7:	eb 18                	jmp    80106211 <sys_mknod+0x93>
  }
  iunlockput(ip);
801061f9:	83 ec 0c             	sub    $0xc,%esp
801061fc:	ff 75 f4             	push   -0xc(%ebp)
801061ff:	e8 1f ba ff ff       	call   80101c23 <iunlockput>
80106204:	83 c4 10             	add    $0x10,%esp
  end_op();
80106207:	e8 be ce ff ff       	call   801030ca <end_op>
  return 0;
8010620c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106211:	c9                   	leave
80106212:	c3                   	ret

80106213 <sys_chdir>:

int
sys_chdir(void)
{
80106213:	55                   	push   %ebp
80106214:	89 e5                	mov    %esp,%ebp
80106216:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106219:	e8 12 d8 ff ff       	call   80103a30 <myproc>
8010621e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106221:	e8 18 ce ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106226:	83 ec 08             	sub    $0x8,%esp
80106229:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010622c:	50                   	push   %eax
8010622d:	6a 00                	push   $0x0
8010622f:	e8 4a f4 ff ff       	call   8010567e <argstr>
80106234:	83 c4 10             	add    $0x10,%esp
80106237:	85 c0                	test   %eax,%eax
80106239:	78 18                	js     80106253 <sys_chdir+0x40>
8010623b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010623e:	83 ec 0c             	sub    $0xc,%esp
80106241:	50                   	push   %eax
80106242:	e8 de c2 ff ff       	call   80102525 <namei>
80106247:	83 c4 10             	add    $0x10,%esp
8010624a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010624d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106251:	75 0c                	jne    8010625f <sys_chdir+0x4c>
    end_op();
80106253:	e8 72 ce ff ff       	call   801030ca <end_op>
    return -1;
80106258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625d:	eb 68                	jmp    801062c7 <sys_chdir+0xb4>
  }
  ilock(ip);
8010625f:	83 ec 0c             	sub    $0xc,%esp
80106262:	ff 75 f0             	push   -0x10(%ebp)
80106265:	e8 88 b7 ff ff       	call   801019f2 <ilock>
8010626a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106270:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106274:	66 83 f8 01          	cmp    $0x1,%ax
80106278:	74 1a                	je     80106294 <sys_chdir+0x81>
    iunlockput(ip);
8010627a:	83 ec 0c             	sub    $0xc,%esp
8010627d:	ff 75 f0             	push   -0x10(%ebp)
80106280:	e8 9e b9 ff ff       	call   80101c23 <iunlockput>
80106285:	83 c4 10             	add    $0x10,%esp
    end_op();
80106288:	e8 3d ce ff ff       	call   801030ca <end_op>
    return -1;
8010628d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106292:	eb 33                	jmp    801062c7 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106294:	83 ec 0c             	sub    $0xc,%esp
80106297:	ff 75 f0             	push   -0x10(%ebp)
8010629a:	e8 66 b8 ff ff       	call   80101b05 <iunlock>
8010629f:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801062a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a5:	8b 40 68             	mov    0x68(%eax),%eax
801062a8:	83 ec 0c             	sub    $0xc,%esp
801062ab:	50                   	push   %eax
801062ac:	e8 a2 b8 ff ff       	call   80101b53 <iput>
801062b1:	83 c4 10             	add    $0x10,%esp
  end_op();
801062b4:	e8 11 ce ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
801062b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062bf:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c7:	c9                   	leave
801062c8:	c3                   	ret

801062c9 <sys_exec>:

int
sys_exec(void)
{
801062c9:	55                   	push   %ebp
801062ca:	89 e5                	mov    %esp,%ebp
801062cc:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062d2:	83 ec 08             	sub    $0x8,%esp
801062d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d8:	50                   	push   %eax
801062d9:	6a 00                	push   $0x0
801062db:	e8 9e f3 ff ff       	call   8010567e <argstr>
801062e0:	83 c4 10             	add    $0x10,%esp
801062e3:	85 c0                	test   %eax,%eax
801062e5:	78 18                	js     801062ff <sys_exec+0x36>
801062e7:	83 ec 08             	sub    $0x8,%esp
801062ea:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062f0:	50                   	push   %eax
801062f1:	6a 01                	push   $0x1
801062f3:	e8 f1 f2 ff ff       	call   801055e9 <argint>
801062f8:	83 c4 10             	add    $0x10,%esp
801062fb:	85 c0                	test   %eax,%eax
801062fd:	79 0a                	jns    80106309 <sys_exec+0x40>
    return -1;
801062ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106304:	e9 c6 00 00 00       	jmp    801063cf <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106309:	83 ec 04             	sub    $0x4,%esp
8010630c:	68 80 00 00 00       	push   $0x80
80106311:	6a 00                	push   $0x0
80106313:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106319:	50                   	push   %eax
8010631a:	e8 9f ef ff ff       	call   801052be <memset>
8010631f:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106322:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632c:	83 f8 1f             	cmp    $0x1f,%eax
8010632f:	76 0a                	jbe    8010633b <sys_exec+0x72>
      return -1;
80106331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106336:	e9 94 00 00 00       	jmp    801063cf <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	c1 e0 02             	shl    $0x2,%eax
80106341:	89 c2                	mov    %eax,%edx
80106343:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106349:	01 c2                	add    %eax,%edx
8010634b:	83 ec 08             	sub    $0x8,%esp
8010634e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106354:	50                   	push   %eax
80106355:	52                   	push   %edx
80106356:	e8 ed f1 ff ff       	call   80105548 <fetchint>
8010635b:	83 c4 10             	add    $0x10,%esp
8010635e:	85 c0                	test   %eax,%eax
80106360:	79 07                	jns    80106369 <sys_exec+0xa0>
      return -1;
80106362:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106367:	eb 66                	jmp    801063cf <sys_exec+0x106>
    if(uarg == 0){
80106369:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010636f:	85 c0                	test   %eax,%eax
80106371:	75 27                	jne    8010639a <sys_exec+0xd1>
      argv[i] = 0;
80106373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106376:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010637d:	00 00 00 00 
      break;
80106381:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106382:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106385:	83 ec 08             	sub    $0x8,%esp
80106388:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010638e:	52                   	push   %edx
8010638f:	50                   	push   %eax
80106390:	e8 f5 a7 ff ff       	call   80100b8a <exec>
80106395:	83 c4 10             	add    $0x10,%esp
80106398:	eb 35                	jmp    801063cf <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010639a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a3:	c1 e2 02             	shl    $0x2,%edx
801063a6:	01 c2                	add    %eax,%edx
801063a8:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063ae:	83 ec 08             	sub    $0x8,%esp
801063b1:	52                   	push   %edx
801063b2:	50                   	push   %eax
801063b3:	e8 cf f1 ff ff       	call   80105587 <fetchstr>
801063b8:	83 c4 10             	add    $0x10,%esp
801063bb:	85 c0                	test   %eax,%eax
801063bd:	79 07                	jns    801063c6 <sys_exec+0xfd>
      return -1;
801063bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c4:	eb 09                	jmp    801063cf <sys_exec+0x106>
  for(i=0;; i++){
801063c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063ca:	e9 5a ff ff ff       	jmp    80106329 <sys_exec+0x60>
}
801063cf:	c9                   	leave
801063d0:	c3                   	ret

801063d1 <sys_pipe>:

int
sys_pipe(void)
{
801063d1:	55                   	push   %ebp
801063d2:	89 e5                	mov    %esp,%ebp
801063d4:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063d7:	83 ec 04             	sub    $0x4,%esp
801063da:	6a 08                	push   $0x8
801063dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063df:	50                   	push   %eax
801063e0:	6a 00                	push   $0x0
801063e2:	e8 2f f2 ff ff       	call   80105616 <argptr>
801063e7:	83 c4 10             	add    $0x10,%esp
801063ea:	85 c0                	test   %eax,%eax
801063ec:	79 0a                	jns    801063f8 <sys_pipe+0x27>
    return -1;
801063ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f3:	e9 ae 00 00 00       	jmp    801064a6 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801063f8:	83 ec 08             	sub    $0x8,%esp
801063fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063fe:	50                   	push   %eax
801063ff:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106402:	50                   	push   %eax
80106403:	e8 65 d1 ff ff       	call   8010356d <pipealloc>
80106408:	83 c4 10             	add    $0x10,%esp
8010640b:	85 c0                	test   %eax,%eax
8010640d:	79 0a                	jns    80106419 <sys_pipe+0x48>
    return -1;
8010640f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106414:	e9 8d 00 00 00       	jmp    801064a6 <sys_pipe+0xd5>
  fd0 = -1;
80106419:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106420:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106423:	83 ec 0c             	sub    $0xc,%esp
80106426:	50                   	push   %eax
80106427:	e8 7b f3 ff ff       	call   801057a7 <fdalloc>
8010642c:	83 c4 10             	add    $0x10,%esp
8010642f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106432:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106436:	78 18                	js     80106450 <sys_pipe+0x7f>
80106438:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643b:	83 ec 0c             	sub    $0xc,%esp
8010643e:	50                   	push   %eax
8010643f:	e8 63 f3 ff ff       	call   801057a7 <fdalloc>
80106444:	83 c4 10             	add    $0x10,%esp
80106447:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010644a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010644e:	79 3e                	jns    8010648e <sys_pipe+0xbd>
    if(fd0 >= 0)
80106450:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106454:	78 13                	js     80106469 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106456:	e8 d5 d5 ff ff       	call   80103a30 <myproc>
8010645b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010645e:	83 c2 08             	add    $0x8,%edx
80106461:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106468:	00 
    fileclose(rf);
80106469:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010646c:	83 ec 0c             	sub    $0xc,%esp
8010646f:	50                   	push   %eax
80106470:	e8 30 ac ff ff       	call   801010a5 <fileclose>
80106475:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647b:	83 ec 0c             	sub    $0xc,%esp
8010647e:	50                   	push   %eax
8010647f:	e8 21 ac ff ff       	call   801010a5 <fileclose>
80106484:	83 c4 10             	add    $0x10,%esp
    return -1;
80106487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648c:	eb 18                	jmp    801064a6 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010648e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106491:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106494:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106499:	8d 50 04             	lea    0x4(%eax),%edx
8010649c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649f:	89 02                	mov    %eax,(%edx)
  return 0;
801064a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a6:	c9                   	leave
801064a7:	c3                   	ret

801064a8 <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
801064ae:	83 ec 04             	sub    $0x4,%esp
801064b1:	68 00 0c 00 00       	push   $0xc00
801064b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064b9:	50                   	push   %eax
801064ba:	6a 00                	push   $0x0
801064bc:	e8 55 f1 ff ff       	call   80105616 <argptr>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	85 c0                	test   %eax,%eax
801064c6:	79 07                	jns    801064cf <sys_getpinfo+0x27>
    return -1;
801064c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cd:	eb 0f                	jmp    801064de <sys_getpinfo+0x36>
  return getpinfo(ps);
801064cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d2:	83 ec 0c             	sub    $0xc,%esp
801064d5:	50                   	push   %eax
801064d6:	e8 4e e2 ff ff       	call   80104729 <getpinfo>
801064db:	83 c4 10             	add    $0x10,%esp
}
801064de:	c9                   	leave
801064df:	c3                   	ret

801064e0 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
801064e3:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
801064e6:	83 ec 08             	sub    $0x8,%esp
801064e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064ec:	50                   	push   %eax
801064ed:	6a 00                	push   $0x0
801064ef:	e8 f5 f0 ff ff       	call   801055e9 <argint>
801064f4:	83 c4 10             	add    $0x10,%esp
801064f7:	85 c0                	test   %eax,%eax
801064f9:	79 07                	jns    80106502 <sys_setSchedPolicy+0x22>
    return -1;
801064fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106500:	eb 23                	jmp    80106525 <sys_setSchedPolicy+0x45>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106505:	83 ec 08             	sub    $0x8,%esp
80106508:	50                   	push   %eax
80106509:	68 70 af 10 80       	push   $0x8010af70
8010650e:	e8 e1 9e ff ff       	call   801003f4 <cprintf>
80106513:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
80106516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106519:	83 ec 0c             	sub    $0xc,%esp
8010651c:	50                   	push   %eax
8010651d:	e8 db e3 ff ff       	call   801048fd <set_sched_policy>
80106522:	83 c4 10             	add    $0x10,%esp
}
80106525:	c9                   	leave
80106526:	c3                   	ret

80106527 <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
80106527:	55                   	push   %ebp
80106528:	89 e5                	mov    %esp,%ebp
8010652a:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
8010652d:	e8 0e e4 ff ff       	call   80104940 <get_sched_policy>
}
80106532:	c9                   	leave
80106533:	c3                   	ret

80106534 <sys_yield>:
int
sys_yield(void)
{
80106534:	55                   	push   %ebp
80106535:	89 e5                	mov    %esp,%ebp
80106537:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
8010653a:	e8 ce de ff ff       	call   8010440d <yield>
  return 0;
8010653f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106544:	c9                   	leave
80106545:	c3                   	ret

80106546 <sys_fork>:

int
sys_fork(void)
{
80106546:	55                   	push   %ebp
80106547:	89 e5                	mov    %esp,%ebp
80106549:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010654c:	e8 7f d8 ff ff       	call   80103dd0 <fork>
}
80106551:	c9                   	leave
80106552:	c3                   	ret

80106553 <sys_exit>:

int
sys_exit(void)
{
80106553:	55                   	push   %ebp
80106554:	89 e5                	mov    %esp,%ebp
80106556:	83 ec 08             	sub    $0x8,%esp
  exit();
80106559:	e8 46 da ff ff       	call   80103fa4 <exit>
  return 0;  // not reached
8010655e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106563:	c9                   	leave
80106564:	c3                   	ret

80106565 <sys_wait>:

int
sys_wait(void)
{
80106565:	55                   	push   %ebp
80106566:	89 e5                	mov    %esp,%ebp
80106568:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010656b:	e8 76 db ff ff       	call   801040e6 <wait>
}
80106570:	c9                   	leave
80106571:	c3                   	ret

80106572 <sys_kill>:

int
sys_kill(void)
{
80106572:	55                   	push   %ebp
80106573:	89 e5                	mov    %esp,%ebp
80106575:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106578:	83 ec 08             	sub    $0x8,%esp
8010657b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010657e:	50                   	push   %eax
8010657f:	6a 00                	push   $0x0
80106581:	e8 63 f0 ff ff       	call   801055e9 <argint>
80106586:	83 c4 10             	add    $0x10,%esp
80106589:	85 c0                	test   %eax,%eax
8010658b:	79 07                	jns    80106594 <sys_kill+0x22>
    return -1;
8010658d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106592:	eb 0f                	jmp    801065a3 <sys_kill+0x31>
  return kill(pid);
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	83 ec 0c             	sub    $0xc,%esp
8010659a:	50                   	push   %eax
8010659b:	e8 0b e0 ff ff       	call   801045ab <kill>
801065a0:	83 c4 10             	add    $0x10,%esp
}
801065a3:	c9                   	leave
801065a4:	c3                   	ret

801065a5 <sys_getpid>:

int
sys_getpid(void)
{
801065a5:	55                   	push   %ebp
801065a6:	89 e5                	mov    %esp,%ebp
801065a8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801065ab:	e8 80 d4 ff ff       	call   80103a30 <myproc>
801065b0:	8b 40 10             	mov    0x10(%eax),%eax
}
801065b3:	c9                   	leave
801065b4:	c3                   	ret

801065b5 <sys_sbrk>:

int
sys_sbrk(void)
{
801065b5:	55                   	push   %ebp
801065b6:	89 e5                	mov    %esp,%ebp
801065b8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065bb:	83 ec 08             	sub    $0x8,%esp
801065be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065c1:	50                   	push   %eax
801065c2:	6a 00                	push   $0x0
801065c4:	e8 20 f0 ff ff       	call   801055e9 <argint>
801065c9:	83 c4 10             	add    $0x10,%esp
801065cc:	85 c0                	test   %eax,%eax
801065ce:	79 07                	jns    801065d7 <sys_sbrk+0x22>
    return -1;
801065d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d5:	eb 27                	jmp    801065fe <sys_sbrk+0x49>
  addr = myproc()->sz;
801065d7:	e8 54 d4 ff ff       	call   80103a30 <myproc>
801065dc:	8b 00                	mov    (%eax),%eax
801065de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e4:	83 ec 0c             	sub    $0xc,%esp
801065e7:	50                   	push   %eax
801065e8:	e8 48 d7 ff ff       	call   80103d35 <growproc>
801065ed:	83 c4 10             	add    $0x10,%esp
801065f0:	85 c0                	test   %eax,%eax
801065f2:	79 07                	jns    801065fb <sys_sbrk+0x46>
    return -1;
801065f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f9:	eb 03                	jmp    801065fe <sys_sbrk+0x49>
  return addr;
801065fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065fe:	c9                   	leave
801065ff:	c3                   	ret

80106600 <sys_sleep>:

int
sys_sleep(void)
{
80106600:	55                   	push   %ebp
80106601:	89 e5                	mov    %esp,%ebp
80106603:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106606:	83 ec 08             	sub    $0x8,%esp
80106609:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010660c:	50                   	push   %eax
8010660d:	6a 00                	push   $0x0
8010660f:	e8 d5 ef ff ff       	call   801055e9 <argint>
80106614:	83 c4 10             	add    $0x10,%esp
80106617:	85 c0                	test   %eax,%eax
80106619:	79 07                	jns    80106622 <sys_sleep+0x22>
    return -1;
8010661b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106620:	eb 76                	jmp    80106698 <sys_sleep+0x98>
  acquire(&tickslock);
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	68 80 79 19 80       	push   $0x80197980
8010662a:	e8 19 ea ff ff       	call   80105048 <acquire>
8010662f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106632:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106637:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010663a:	eb 38                	jmp    80106674 <sys_sleep+0x74>
    if(myproc()->killed){
8010663c:	e8 ef d3 ff ff       	call   80103a30 <myproc>
80106641:	8b 40 24             	mov    0x24(%eax),%eax
80106644:	85 c0                	test   %eax,%eax
80106646:	74 17                	je     8010665f <sys_sleep+0x5f>
      release(&tickslock);
80106648:	83 ec 0c             	sub    $0xc,%esp
8010664b:	68 80 79 19 80       	push   $0x80197980
80106650:	e8 61 ea ff ff       	call   801050b6 <release>
80106655:	83 c4 10             	add    $0x10,%esp
      return -1;
80106658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665d:	eb 39                	jmp    80106698 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010665f:	83 ec 08             	sub    $0x8,%esp
80106662:	68 80 79 19 80       	push   $0x80197980
80106667:	68 b4 79 19 80       	push   $0x801979b4
8010666c:	e8 1c de ff ff       	call   8010448d <sleep>
80106671:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106674:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106679:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010667c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010667f:	39 d0                	cmp    %edx,%eax
80106681:	72 b9                	jb     8010663c <sys_sleep+0x3c>
  }
  release(&tickslock);
80106683:	83 ec 0c             	sub    $0xc,%esp
80106686:	68 80 79 19 80       	push   $0x80197980
8010668b:	e8 26 ea ff ff       	call   801050b6 <release>
80106690:	83 c4 10             	add    $0x10,%esp
  return 0;
80106693:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106698:	c9                   	leave
80106699:	c3                   	ret

8010669a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010669a:	55                   	push   %ebp
8010669b:	89 e5                	mov    %esp,%ebp
8010669d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801066a0:	83 ec 0c             	sub    $0xc,%esp
801066a3:	68 80 79 19 80       	push   $0x80197980
801066a8:	e8 9b e9 ff ff       	call   80105048 <acquire>
801066ad:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801066b0:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801066b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066b8:	83 ec 0c             	sub    $0xc,%esp
801066bb:	68 80 79 19 80       	push   $0x80197980
801066c0:	e8 f1 e9 ff ff       	call   801050b6 <release>
801066c5:	83 c4 10             	add    $0x10,%esp
  return xticks;
801066c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066cb:	c9                   	leave
801066cc:	c3                   	ret

801066cd <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066cd:	1e                   	push   %ds
  pushl %es
801066ce:	06                   	push   %es
  pushl %fs
801066cf:	0f a0                	push   %fs
  pushl %gs
801066d1:	0f a8                	push   %gs
  pushal
801066d3:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801066d4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066d8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066da:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801066dc:	54                   	push   %esp
  call trap
801066dd:	e8 d7 01 00 00       	call   801068b9 <trap>
  addl $4, %esp
801066e2:	83 c4 04             	add    $0x4,%esp

801066e5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066e5:	61                   	popa
  popl %gs
801066e6:	0f a9                	pop    %gs
  popl %fs
801066e8:	0f a1                	pop    %fs
  popl %es
801066ea:	07                   	pop    %es
  popl %ds
801066eb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066ec:	83 c4 08             	add    $0x8,%esp
  iret
801066ef:	cf                   	iret

801066f0 <lidt>:
{
801066f0:	55                   	push   %ebp
801066f1:	89 e5                	mov    %esp,%ebp
801066f3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801066f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801066f9:	83 e8 01             	sub    $0x1,%eax
801066fc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106700:	8b 45 08             	mov    0x8(%ebp),%eax
80106703:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106707:	8b 45 08             	mov    0x8(%ebp),%eax
8010670a:	c1 e8 10             	shr    $0x10,%eax
8010670d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106711:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106714:	0f 01 18             	lidtl  (%eax)
}
80106717:	90                   	nop
80106718:	c9                   	leave
80106719:	c3                   	ret

8010671a <rcr2>:

static inline uint
rcr2(void)
{
8010671a:	55                   	push   %ebp
8010671b:	89 e5                	mov    %esp,%ebp
8010671d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106720:	0f 20 d0             	mov    %cr2,%eax
80106723:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106726:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106729:	c9                   	leave
8010672a:	c3                   	ret

8010672b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106738:	e9 c3 00 00 00       	jmp    80106800 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010673d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106740:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106747:	89 c2                	mov    %eax,%edx
80106749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674c:	66 89 14 c5 80 71 19 	mov    %dx,-0x7fe68e80(,%eax,8)
80106753:	80 
80106754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106757:	66 c7 04 c5 82 71 19 	movw   $0x8,-0x7fe68e7e(,%eax,8)
8010675e:	80 08 00 
80106761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106764:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
8010676b:	80 
8010676c:	83 e2 e0             	and    $0xffffffe0,%edx
8010676f:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
80106776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106779:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
80106780:	80 
80106781:	83 e2 1f             	and    $0x1f,%edx
80106784:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
8010678b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678e:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106795:	80 
80106796:	83 e2 f0             	and    $0xfffffff0,%edx
80106799:	83 ca 0e             	or     $0xe,%edx
8010679c:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801067a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a6:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801067ad:	80 
801067ae:	83 e2 ef             	and    $0xffffffef,%edx
801067b1:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801067b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bb:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801067c2:	80 
801067c3:	83 e2 9f             	and    $0xffffff9f,%edx
801067c6:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801067cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d0:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
801067d7:	80 
801067d8:	83 ca 80             	or     $0xffffff80,%edx
801067db:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
801067e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e5:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801067ec:	c1 e8 10             	shr    $0x10,%eax
801067ef:	89 c2                	mov    %eax,%edx
801067f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f4:	66 89 14 c5 86 71 19 	mov    %dx,-0x7fe68e7a(,%eax,8)
801067fb:	80 
  for(i = 0; i < 256; i++)
801067fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106800:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106807:	0f 8e 30 ff ff ff    	jle    8010673d <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010680d:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106812:	66 a3 80 73 19 80    	mov    %ax,0x80197380
80106818:	66 c7 05 82 73 19 80 	movw   $0x8,0x80197382
8010681f:	08 00 
80106821:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
80106828:	83 e0 e0             	and    $0xffffffe0,%eax
8010682b:	a2 84 73 19 80       	mov    %al,0x80197384
80106830:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
80106837:	83 e0 1f             	and    $0x1f,%eax
8010683a:	a2 84 73 19 80       	mov    %al,0x80197384
8010683f:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106846:	83 c8 0f             	or     $0xf,%eax
80106849:	a2 85 73 19 80       	mov    %al,0x80197385
8010684e:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106855:	83 e0 ef             	and    $0xffffffef,%eax
80106858:	a2 85 73 19 80       	mov    %al,0x80197385
8010685d:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106864:	83 c8 60             	or     $0x60,%eax
80106867:	a2 85 73 19 80       	mov    %al,0x80197385
8010686c:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
80106873:	83 c8 80             	or     $0xffffff80,%eax
80106876:	a2 85 73 19 80       	mov    %al,0x80197385
8010687b:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106880:	c1 e8 10             	shr    $0x10,%eax
80106883:	66 a3 86 73 19 80    	mov    %ax,0x80197386

  initlock(&tickslock, "time");
80106889:	83 ec 08             	sub    $0x8,%esp
8010688c:	68 9c af 10 80       	push   $0x8010af9c
80106891:	68 80 79 19 80       	push   $0x80197980
80106896:	e8 8b e7 ff ff       	call   80105026 <initlock>
8010689b:	83 c4 10             	add    $0x10,%esp
}
8010689e:	90                   	nop
8010689f:	c9                   	leave
801068a0:	c3                   	ret

801068a1 <idtinit>:

void
idtinit(void)
{
801068a1:	55                   	push   %ebp
801068a2:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801068a4:	68 00 08 00 00       	push   $0x800
801068a9:	68 80 71 19 80       	push   $0x80197180
801068ae:	e8 3d fe ff ff       	call   801066f0 <lidt>
801068b3:	83 c4 08             	add    $0x8,%esp
}
801068b6:	90                   	nop
801068b7:	c9                   	leave
801068b8:	c3                   	ret

801068b9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068b9:	55                   	push   %ebp
801068ba:	89 e5                	mov    %esp,%ebp
801068bc:	57                   	push   %edi
801068bd:	56                   	push   %esi
801068be:	53                   	push   %ebx
801068bf:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801068c2:	8b 45 08             	mov    0x8(%ebp),%eax
801068c5:	8b 40 30             	mov    0x30(%eax),%eax
801068c8:	83 f8 40             	cmp    $0x40,%eax
801068cb:	75 3b                	jne    80106908 <trap+0x4f>
    if(myproc()->killed)
801068cd:	e8 5e d1 ff ff       	call   80103a30 <myproc>
801068d2:	8b 40 24             	mov    0x24(%eax),%eax
801068d5:	85 c0                	test   %eax,%eax
801068d7:	74 05                	je     801068de <trap+0x25>
      exit();
801068d9:	e8 c6 d6 ff ff       	call   80103fa4 <exit>
    myproc()->tf = tf;
801068de:	e8 4d d1 ff ff       	call   80103a30 <myproc>
801068e3:	8b 55 08             	mov    0x8(%ebp),%edx
801068e6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801068e9:	e8 c7 ed ff ff       	call   801056b5 <syscall>
    if(myproc()->killed)
801068ee:	e8 3d d1 ff ff       	call   80103a30 <myproc>
801068f3:	8b 40 24             	mov    0x24(%eax),%eax
801068f6:	85 c0                	test   %eax,%eax
801068f8:	0f 84 dd 02 00 00    	je     80106bdb <trap+0x322>
      exit();
801068fe:	e8 a1 d6 ff ff       	call   80103fa4 <exit>
    return;
80106903:	e9 d3 02 00 00       	jmp    80106bdb <trap+0x322>
  }

  switch(tf->trapno){
80106908:	8b 45 08             	mov    0x8(%ebp),%eax
8010690b:	8b 40 30             	mov    0x30(%eax),%eax
8010690e:	83 e8 20             	sub    $0x20,%eax
80106911:	83 f8 1f             	cmp    $0x1f,%eax
80106914:	0f 87 8c 01 00 00    	ja     80106aa6 <trap+0x1ed>
8010691a:	8b 04 85 70 b0 10 80 	mov    -0x7fef4f90(,%eax,4),%eax
80106921:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106923:	e8 75 d0 ff ff       	call   8010399d <cpuid>
80106928:	85 c0                	test   %eax,%eax
8010692a:	75 3d                	jne    80106969 <trap+0xb0>
      acquire(&tickslock);
8010692c:	83 ec 0c             	sub    $0xc,%esp
8010692f:	68 80 79 19 80       	push   $0x80197980
80106934:	e8 0f e7 ff ff       	call   80105048 <acquire>
80106939:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010693c:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106941:	83 c0 01             	add    $0x1,%eax
80106944:	a3 b4 79 19 80       	mov    %eax,0x801979b4
      wakeup(&ticks);
80106949:	83 ec 0c             	sub    $0xc,%esp
8010694c:	68 b4 79 19 80       	push   $0x801979b4
80106951:	e8 1e dc ff ff       	call   80104574 <wakeup>
80106956:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106959:	83 ec 0c             	sub    $0xc,%esp
8010695c:	68 80 79 19 80       	push   $0x80197980
80106961:	e8 50 e7 ff ff       	call   801050b6 <release>
80106966:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106969:	e8 c2 d0 ff ff       	call   80103a30 <myproc>
8010696e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106971:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106975:	0f 84 b6 00 00 00    	je     80106a31 <trap+0x178>
8010697b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010697e:	8b 40 0c             	mov    0xc(%eax),%eax
80106981:	83 f8 04             	cmp    $0x4,%eax
80106984:	0f 85 a7 00 00 00    	jne    80106a31 <trap+0x178>
8010698a:	e8 29 d0 ff ff       	call   801039b8 <mycpu>
8010698f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106995:	85 c0                	test   %eax,%eax
80106997:	0f 84 94 00 00 00    	je     80106a31 <trap+0x178>
      int idx = myproc() - ptable.proc;
8010699d:	e8 8e d0 ff ff       	call   80103a30 <myproc>
801069a2:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801069a7:	c1 f8 02             	sar    $0x2,%eax
801069aa:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801069b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
801069b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069b6:	83 e8 80             	sub    $0xffffff80,%eax
801069b9:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801069c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
801069c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801069cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801069d0:	01 d0                	add    %edx,%eax
801069d2:	05 00 01 00 00       	add    $0x100,%eax
801069d7:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801069de:	8d 50 01             	lea    0x1(%eax),%edx
801069e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069e4:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801069eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801069ee:	01 c8                	add    %ecx,%eax
801069f0:	05 00 01 00 00       	add    $0x100,%eax
801069f5:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",myproc()->pid, q, kernel_pstat.ticks[idx][q]);
801069fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801069ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106a06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a09:	01 d0                	add    %edx,%eax
80106a0b:	05 00 01 00 00       	add    $0x100,%eax
80106a10:	8b 1c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ebx
80106a17:	e8 14 d0 ff ff       	call   80103a30 <myproc>
80106a1c:	8b 40 10             	mov    0x10(%eax),%eax
80106a1f:	53                   	push   %ebx
80106a20:	ff 75 dc             	push   -0x24(%ebp)
80106a23:	50                   	push   %eax
80106a24:	68 a4 af 10 80       	push   $0x8010afa4
80106a29:	e8 c6 99 ff ff       	call   801003f4 <cprintf>
80106a2e:	83 c4 10             	add    $0x10,%esp
    }

    lapiceoi();
80106a31:	e8 e8 c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106a36:	e9 20 01 00 00       	jmp    80106b5b <trap+0x2a2>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a3b:	e8 da 3e 00 00       	call   8010a91a <ideintr>
    lapiceoi();
80106a40:	e8 d9 c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106a45:	e9 11 01 00 00       	jmp    80106b5b <trap+0x2a2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a4a:	e8 1a bf ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106a4f:	e8 ca c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106a54:	e9 02 01 00 00       	jmp    80106b5b <trap+0x2a2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a59:	e8 51 03 00 00       	call   80106daf <uartintr>
    lapiceoi();
80106a5e:	e8 bb c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106a63:	e9 f3 00 00 00       	jmp    80106b5b <trap+0x2a2>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106a68:	e8 76 2b 00 00       	call   801095e3 <i8254_intr>
    lapiceoi();
80106a6d:	e8 ac c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106a72:	e9 e4 00 00 00       	jmp    80106b5b <trap+0x2a2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a77:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7a:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a84:	0f b7 d8             	movzwl %ax,%ebx
80106a87:	e8 11 cf ff ff       	call   8010399d <cpuid>
80106a8c:	56                   	push   %esi
80106a8d:	53                   	push   %ebx
80106a8e:	50                   	push   %eax
80106a8f:	68 d0 af 10 80       	push   $0x8010afd0
80106a94:	e8 5b 99 ff ff       	call   801003f4 <cprintf>
80106a99:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106a9c:	e8 7d c0 ff ff       	call   80102b1e <lapiceoi>
    break;
80106aa1:	e9 b5 00 00 00       	jmp    80106b5b <trap+0x2a2>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106aa6:	e8 85 cf ff ff       	call   80103a30 <myproc>
80106aab:	85 c0                	test   %eax,%eax
80106aad:	74 11                	je     80106ac0 <trap+0x207>
80106aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ab6:	0f b7 c0             	movzwl %ax,%eax
80106ab9:	83 e0 03             	and    $0x3,%eax
80106abc:	85 c0                	test   %eax,%eax
80106abe:	75 39                	jne    80106af9 <trap+0x240>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ac0:	e8 55 fc ff ff       	call   8010671a <rcr2>
80106ac5:	89 c3                	mov    %eax,%ebx
80106ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80106aca:	8b 70 38             	mov    0x38(%eax),%esi
80106acd:	e8 cb ce ff ff       	call   8010399d <cpuid>
80106ad2:	8b 55 08             	mov    0x8(%ebp),%edx
80106ad5:	8b 52 30             	mov    0x30(%edx),%edx
80106ad8:	83 ec 0c             	sub    $0xc,%esp
80106adb:	53                   	push   %ebx
80106adc:	56                   	push   %esi
80106add:	50                   	push   %eax
80106ade:	52                   	push   %edx
80106adf:	68 f4 af 10 80       	push   $0x8010aff4
80106ae4:	e8 0b 99 ff ff       	call   801003f4 <cprintf>
80106ae9:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106aec:	83 ec 0c             	sub    $0xc,%esp
80106aef:	68 26 b0 10 80       	push   $0x8010b026
80106af4:	e8 b0 9a ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106af9:	e8 1c fc ff ff       	call   8010671a <rcr2>
80106afe:	89 c6                	mov    %eax,%esi
80106b00:	8b 45 08             	mov    0x8(%ebp),%eax
80106b03:	8b 40 38             	mov    0x38(%eax),%eax
80106b06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106b09:	e8 8f ce ff ff       	call   8010399d <cpuid>
80106b0e:	89 c3                	mov    %eax,%ebx
80106b10:	8b 45 08             	mov    0x8(%ebp),%eax
80106b13:	8b 48 34             	mov    0x34(%eax),%ecx
80106b16:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106b19:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1c:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106b1f:	e8 0c cf ff ff       	call   80103a30 <myproc>
80106b24:	8d 50 6c             	lea    0x6c(%eax),%edx
80106b27:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106b2a:	e8 01 cf ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b2f:	8b 40 10             	mov    0x10(%eax),%eax
80106b32:	56                   	push   %esi
80106b33:	ff 75 d4             	push   -0x2c(%ebp)
80106b36:	53                   	push   %ebx
80106b37:	ff 75 d0             	push   -0x30(%ebp)
80106b3a:	57                   	push   %edi
80106b3b:	ff 75 cc             	push   -0x34(%ebp)
80106b3e:	50                   	push   %eax
80106b3f:	68 2c b0 10 80       	push   $0x8010b02c
80106b44:	e8 ab 98 ff ff       	call   801003f4 <cprintf>
80106b49:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b4c:	e8 df ce ff ff       	call   80103a30 <myproc>
80106b51:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b58:	eb 01                	jmp    80106b5b <trap+0x2a2>
    break;
80106b5a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b5b:	e8 d0 ce ff ff       	call   80103a30 <myproc>
80106b60:	85 c0                	test   %eax,%eax
80106b62:	74 23                	je     80106b87 <trap+0x2ce>
80106b64:	e8 c7 ce ff ff       	call   80103a30 <myproc>
80106b69:	8b 40 24             	mov    0x24(%eax),%eax
80106b6c:	85 c0                	test   %eax,%eax
80106b6e:	74 17                	je     80106b87 <trap+0x2ce>
80106b70:	8b 45 08             	mov    0x8(%ebp),%eax
80106b73:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b77:	0f b7 c0             	movzwl %ax,%eax
80106b7a:	83 e0 03             	and    $0x3,%eax
80106b7d:	83 f8 03             	cmp    $0x3,%eax
80106b80:	75 05                	jne    80106b87 <trap+0x2ce>
    exit();
80106b82:	e8 1d d4 ff ff       	call   80103fa4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b87:	e8 a4 ce ff ff       	call   80103a30 <myproc>
80106b8c:	85 c0                	test   %eax,%eax
80106b8e:	74 1d                	je     80106bad <trap+0x2f4>
80106b90:	e8 9b ce ff ff       	call   80103a30 <myproc>
80106b95:	8b 40 0c             	mov    0xc(%eax),%eax
80106b98:	83 f8 04             	cmp    $0x4,%eax
80106b9b:	75 10                	jne    80106bad <trap+0x2f4>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba0:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106ba3:	83 f8 20             	cmp    $0x20,%eax
80106ba6:	75 05                	jne    80106bad <trap+0x2f4>
    yield();
80106ba8:	e8 60 d8 ff ff       	call   8010440d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106bad:	e8 7e ce ff ff       	call   80103a30 <myproc>
80106bb2:	85 c0                	test   %eax,%eax
80106bb4:	74 26                	je     80106bdc <trap+0x323>
80106bb6:	e8 75 ce ff ff       	call   80103a30 <myproc>
80106bbb:	8b 40 24             	mov    0x24(%eax),%eax
80106bbe:	85 c0                	test   %eax,%eax
80106bc0:	74 1a                	je     80106bdc <trap+0x323>
80106bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106bc5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bc9:	0f b7 c0             	movzwl %ax,%eax
80106bcc:	83 e0 03             	and    $0x3,%eax
80106bcf:	83 f8 03             	cmp    $0x3,%eax
80106bd2:	75 08                	jne    80106bdc <trap+0x323>
    exit();
80106bd4:	e8 cb d3 ff ff       	call   80103fa4 <exit>
80106bd9:	eb 01                	jmp    80106bdc <trap+0x323>
    return;
80106bdb:	90                   	nop
}
80106bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bdf:	5b                   	pop    %ebx
80106be0:	5e                   	pop    %esi
80106be1:	5f                   	pop    %edi
80106be2:	5d                   	pop    %ebp
80106be3:	c3                   	ret

80106be4 <inb>:
{
80106be4:	55                   	push   %ebp
80106be5:	89 e5                	mov    %esp,%ebp
80106be7:	83 ec 14             	sub    $0x14,%esp
80106bea:	8b 45 08             	mov    0x8(%ebp),%eax
80106bed:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106bf1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106bf5:	89 c2                	mov    %eax,%edx
80106bf7:	ec                   	in     (%dx),%al
80106bf8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106bfb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106bff:	c9                   	leave
80106c00:	c3                   	ret

80106c01 <outb>:
{
80106c01:	55                   	push   %ebp
80106c02:	89 e5                	mov    %esp,%ebp
80106c04:	83 ec 08             	sub    $0x8,%esp
80106c07:	8b 55 08             	mov    0x8(%ebp),%edx
80106c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c0d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c11:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c14:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c18:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c1c:	ee                   	out    %al,(%dx)
}
80106c1d:	90                   	nop
80106c1e:	c9                   	leave
80106c1f:	c3                   	ret

80106c20 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c20:	55                   	push   %ebp
80106c21:	89 e5                	mov    %esp,%ebp
80106c23:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c26:	6a 00                	push   $0x0
80106c28:	68 fa 03 00 00       	push   $0x3fa
80106c2d:	e8 cf ff ff ff       	call   80106c01 <outb>
80106c32:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c35:	68 80 00 00 00       	push   $0x80
80106c3a:	68 fb 03 00 00       	push   $0x3fb
80106c3f:	e8 bd ff ff ff       	call   80106c01 <outb>
80106c44:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106c47:	6a 0c                	push   $0xc
80106c49:	68 f8 03 00 00       	push   $0x3f8
80106c4e:	e8 ae ff ff ff       	call   80106c01 <outb>
80106c53:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106c56:	6a 00                	push   $0x0
80106c58:	68 f9 03 00 00       	push   $0x3f9
80106c5d:	e8 9f ff ff ff       	call   80106c01 <outb>
80106c62:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c65:	6a 03                	push   $0x3
80106c67:	68 fb 03 00 00       	push   $0x3fb
80106c6c:	e8 90 ff ff ff       	call   80106c01 <outb>
80106c71:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106c74:	6a 00                	push   $0x0
80106c76:	68 fc 03 00 00       	push   $0x3fc
80106c7b:	e8 81 ff ff ff       	call   80106c01 <outb>
80106c80:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c83:	6a 01                	push   $0x1
80106c85:	68 f9 03 00 00       	push   $0x3f9
80106c8a:	e8 72 ff ff ff       	call   80106c01 <outb>
80106c8f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c92:	68 fd 03 00 00       	push   $0x3fd
80106c97:	e8 48 ff ff ff       	call   80106be4 <inb>
80106c9c:	83 c4 04             	add    $0x4,%esp
80106c9f:	3c ff                	cmp    $0xff,%al
80106ca1:	74 61                	je     80106d04 <uartinit+0xe4>
    return;
  uart = 1;
80106ca3:	c7 05 b8 79 19 80 01 	movl   $0x1,0x801979b8
80106caa:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106cad:	68 fa 03 00 00       	push   $0x3fa
80106cb2:	e8 2d ff ff ff       	call   80106be4 <inb>
80106cb7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106cba:	68 f8 03 00 00       	push   $0x3f8
80106cbf:	e8 20 ff ff ff       	call   80106be4 <inb>
80106cc4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106cc7:	83 ec 08             	sub    $0x8,%esp
80106cca:	6a 00                	push   $0x0
80106ccc:	6a 04                	push   $0x4
80106cce:	e8 63 b9 ff ff       	call   80102636 <ioapicenable>
80106cd3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cd6:	c7 45 f4 f0 b0 10 80 	movl   $0x8010b0f0,-0xc(%ebp)
80106cdd:	eb 19                	jmp    80106cf8 <uartinit+0xd8>
    uartputc(*p);
80106cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce2:	0f b6 00             	movzbl (%eax),%eax
80106ce5:	0f be c0             	movsbl %al,%eax
80106ce8:	83 ec 0c             	sub    $0xc,%esp
80106ceb:	50                   	push   %eax
80106cec:	e8 16 00 00 00       	call   80106d07 <uartputc>
80106cf1:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106cf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cfb:	0f b6 00             	movzbl (%eax),%eax
80106cfe:	84 c0                	test   %al,%al
80106d00:	75 dd                	jne    80106cdf <uartinit+0xbf>
80106d02:	eb 01                	jmp    80106d05 <uartinit+0xe5>
    return;
80106d04:	90                   	nop
}
80106d05:	c9                   	leave
80106d06:	c3                   	ret

80106d07 <uartputc>:

void
uartputc(int c)
{
80106d07:	55                   	push   %ebp
80106d08:	89 e5                	mov    %esp,%ebp
80106d0a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106d0d:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106d12:	85 c0                	test   %eax,%eax
80106d14:	74 53                	je     80106d69 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d1d:	eb 11                	jmp    80106d30 <uartputc+0x29>
    microdelay(10);
80106d1f:	83 ec 0c             	sub    $0xc,%esp
80106d22:	6a 0a                	push   $0xa
80106d24:	e8 10 be ff ff       	call   80102b39 <microdelay>
80106d29:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d30:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d34:	7f 1a                	jg     80106d50 <uartputc+0x49>
80106d36:	83 ec 0c             	sub    $0xc,%esp
80106d39:	68 fd 03 00 00       	push   $0x3fd
80106d3e:	e8 a1 fe ff ff       	call   80106be4 <inb>
80106d43:	83 c4 10             	add    $0x10,%esp
80106d46:	0f b6 c0             	movzbl %al,%eax
80106d49:	83 e0 20             	and    $0x20,%eax
80106d4c:	85 c0                	test   %eax,%eax
80106d4e:	74 cf                	je     80106d1f <uartputc+0x18>
  outb(COM1+0, c);
80106d50:	8b 45 08             	mov    0x8(%ebp),%eax
80106d53:	0f b6 c0             	movzbl %al,%eax
80106d56:	83 ec 08             	sub    $0x8,%esp
80106d59:	50                   	push   %eax
80106d5a:	68 f8 03 00 00       	push   $0x3f8
80106d5f:	e8 9d fe ff ff       	call   80106c01 <outb>
80106d64:	83 c4 10             	add    $0x10,%esp
80106d67:	eb 01                	jmp    80106d6a <uartputc+0x63>
    return;
80106d69:	90                   	nop
}
80106d6a:	c9                   	leave
80106d6b:	c3                   	ret

80106d6c <uartgetc>:

static int
uartgetc(void)
{
80106d6c:	55                   	push   %ebp
80106d6d:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106d6f:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106d74:	85 c0                	test   %eax,%eax
80106d76:	75 07                	jne    80106d7f <uartgetc+0x13>
    return -1;
80106d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d7d:	eb 2e                	jmp    80106dad <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d7f:	68 fd 03 00 00       	push   $0x3fd
80106d84:	e8 5b fe ff ff       	call   80106be4 <inb>
80106d89:	83 c4 04             	add    $0x4,%esp
80106d8c:	0f b6 c0             	movzbl %al,%eax
80106d8f:	83 e0 01             	and    $0x1,%eax
80106d92:	85 c0                	test   %eax,%eax
80106d94:	75 07                	jne    80106d9d <uartgetc+0x31>
    return -1;
80106d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d9b:	eb 10                	jmp    80106dad <uartgetc+0x41>
  return inb(COM1+0);
80106d9d:	68 f8 03 00 00       	push   $0x3f8
80106da2:	e8 3d fe ff ff       	call   80106be4 <inb>
80106da7:	83 c4 04             	add    $0x4,%esp
80106daa:	0f b6 c0             	movzbl %al,%eax
}
80106dad:	c9                   	leave
80106dae:	c3                   	ret

80106daf <uartintr>:

void
uartintr(void)
{
80106daf:	55                   	push   %ebp
80106db0:	89 e5                	mov    %esp,%ebp
80106db2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106db5:	83 ec 0c             	sub    $0xc,%esp
80106db8:	68 6c 6d 10 80       	push   $0x80106d6c
80106dbd:	e8 14 9a ff ff       	call   801007d6 <consoleintr>
80106dc2:	83 c4 10             	add    $0x10,%esp
}
80106dc5:	90                   	nop
80106dc6:	c9                   	leave
80106dc7:	c3                   	ret

80106dc8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $0
80106dca:	6a 00                	push   $0x0
  jmp alltraps
80106dcc:	e9 fc f8 ff ff       	jmp    801066cd <alltraps>

80106dd1 <vector1>:
.globl vector1
vector1:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $1
80106dd3:	6a 01                	push   $0x1
  jmp alltraps
80106dd5:	e9 f3 f8 ff ff       	jmp    801066cd <alltraps>

80106dda <vector2>:
.globl vector2
vector2:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $2
80106ddc:	6a 02                	push   $0x2
  jmp alltraps
80106dde:	e9 ea f8 ff ff       	jmp    801066cd <alltraps>

80106de3 <vector3>:
.globl vector3
vector3:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $3
80106de5:	6a 03                	push   $0x3
  jmp alltraps
80106de7:	e9 e1 f8 ff ff       	jmp    801066cd <alltraps>

80106dec <vector4>:
.globl vector4
vector4:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $4
80106dee:	6a 04                	push   $0x4
  jmp alltraps
80106df0:	e9 d8 f8 ff ff       	jmp    801066cd <alltraps>

80106df5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $5
80106df7:	6a 05                	push   $0x5
  jmp alltraps
80106df9:	e9 cf f8 ff ff       	jmp    801066cd <alltraps>

80106dfe <vector6>:
.globl vector6
vector6:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $6
80106e00:	6a 06                	push   $0x6
  jmp alltraps
80106e02:	e9 c6 f8 ff ff       	jmp    801066cd <alltraps>

80106e07 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $7
80106e09:	6a 07                	push   $0x7
  jmp alltraps
80106e0b:	e9 bd f8 ff ff       	jmp    801066cd <alltraps>

80106e10 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e10:	6a 08                	push   $0x8
  jmp alltraps
80106e12:	e9 b6 f8 ff ff       	jmp    801066cd <alltraps>

80106e17 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $9
80106e19:	6a 09                	push   $0x9
  jmp alltraps
80106e1b:	e9 ad f8 ff ff       	jmp    801066cd <alltraps>

80106e20 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e20:	6a 0a                	push   $0xa
  jmp alltraps
80106e22:	e9 a6 f8 ff ff       	jmp    801066cd <alltraps>

80106e27 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e27:	6a 0b                	push   $0xb
  jmp alltraps
80106e29:	e9 9f f8 ff ff       	jmp    801066cd <alltraps>

80106e2e <vector12>:
.globl vector12
vector12:
  pushl $12
80106e2e:	6a 0c                	push   $0xc
  jmp alltraps
80106e30:	e9 98 f8 ff ff       	jmp    801066cd <alltraps>

80106e35 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e35:	6a 0d                	push   $0xd
  jmp alltraps
80106e37:	e9 91 f8 ff ff       	jmp    801066cd <alltraps>

80106e3c <vector14>:
.globl vector14
vector14:
  pushl $14
80106e3c:	6a 0e                	push   $0xe
  jmp alltraps
80106e3e:	e9 8a f8 ff ff       	jmp    801066cd <alltraps>

80106e43 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $15
80106e45:	6a 0f                	push   $0xf
  jmp alltraps
80106e47:	e9 81 f8 ff ff       	jmp    801066cd <alltraps>

80106e4c <vector16>:
.globl vector16
vector16:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $16
80106e4e:	6a 10                	push   $0x10
  jmp alltraps
80106e50:	e9 78 f8 ff ff       	jmp    801066cd <alltraps>

80106e55 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e55:	6a 11                	push   $0x11
  jmp alltraps
80106e57:	e9 71 f8 ff ff       	jmp    801066cd <alltraps>

80106e5c <vector18>:
.globl vector18
vector18:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $18
80106e5e:	6a 12                	push   $0x12
  jmp alltraps
80106e60:	e9 68 f8 ff ff       	jmp    801066cd <alltraps>

80106e65 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $19
80106e67:	6a 13                	push   $0x13
  jmp alltraps
80106e69:	e9 5f f8 ff ff       	jmp    801066cd <alltraps>

80106e6e <vector20>:
.globl vector20
vector20:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $20
80106e70:	6a 14                	push   $0x14
  jmp alltraps
80106e72:	e9 56 f8 ff ff       	jmp    801066cd <alltraps>

80106e77 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $21
80106e79:	6a 15                	push   $0x15
  jmp alltraps
80106e7b:	e9 4d f8 ff ff       	jmp    801066cd <alltraps>

80106e80 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $22
80106e82:	6a 16                	push   $0x16
  jmp alltraps
80106e84:	e9 44 f8 ff ff       	jmp    801066cd <alltraps>

80106e89 <vector23>:
.globl vector23
vector23:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $23
80106e8b:	6a 17                	push   $0x17
  jmp alltraps
80106e8d:	e9 3b f8 ff ff       	jmp    801066cd <alltraps>

80106e92 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $24
80106e94:	6a 18                	push   $0x18
  jmp alltraps
80106e96:	e9 32 f8 ff ff       	jmp    801066cd <alltraps>

80106e9b <vector25>:
.globl vector25
vector25:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $25
80106e9d:	6a 19                	push   $0x19
  jmp alltraps
80106e9f:	e9 29 f8 ff ff       	jmp    801066cd <alltraps>

80106ea4 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $26
80106ea6:	6a 1a                	push   $0x1a
  jmp alltraps
80106ea8:	e9 20 f8 ff ff       	jmp    801066cd <alltraps>

80106ead <vector27>:
.globl vector27
vector27:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $27
80106eaf:	6a 1b                	push   $0x1b
  jmp alltraps
80106eb1:	e9 17 f8 ff ff       	jmp    801066cd <alltraps>

80106eb6 <vector28>:
.globl vector28
vector28:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $28
80106eb8:	6a 1c                	push   $0x1c
  jmp alltraps
80106eba:	e9 0e f8 ff ff       	jmp    801066cd <alltraps>

80106ebf <vector29>:
.globl vector29
vector29:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $29
80106ec1:	6a 1d                	push   $0x1d
  jmp alltraps
80106ec3:	e9 05 f8 ff ff       	jmp    801066cd <alltraps>

80106ec8 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $30
80106eca:	6a 1e                	push   $0x1e
  jmp alltraps
80106ecc:	e9 fc f7 ff ff       	jmp    801066cd <alltraps>

80106ed1 <vector31>:
.globl vector31
vector31:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $31
80106ed3:	6a 1f                	push   $0x1f
  jmp alltraps
80106ed5:	e9 f3 f7 ff ff       	jmp    801066cd <alltraps>

80106eda <vector32>:
.globl vector32
vector32:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $32
80106edc:	6a 20                	push   $0x20
  jmp alltraps
80106ede:	e9 ea f7 ff ff       	jmp    801066cd <alltraps>

80106ee3 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $33
80106ee5:	6a 21                	push   $0x21
  jmp alltraps
80106ee7:	e9 e1 f7 ff ff       	jmp    801066cd <alltraps>

80106eec <vector34>:
.globl vector34
vector34:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $34
80106eee:	6a 22                	push   $0x22
  jmp alltraps
80106ef0:	e9 d8 f7 ff ff       	jmp    801066cd <alltraps>

80106ef5 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $35
80106ef7:	6a 23                	push   $0x23
  jmp alltraps
80106ef9:	e9 cf f7 ff ff       	jmp    801066cd <alltraps>

80106efe <vector36>:
.globl vector36
vector36:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $36
80106f00:	6a 24                	push   $0x24
  jmp alltraps
80106f02:	e9 c6 f7 ff ff       	jmp    801066cd <alltraps>

80106f07 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $37
80106f09:	6a 25                	push   $0x25
  jmp alltraps
80106f0b:	e9 bd f7 ff ff       	jmp    801066cd <alltraps>

80106f10 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $38
80106f12:	6a 26                	push   $0x26
  jmp alltraps
80106f14:	e9 b4 f7 ff ff       	jmp    801066cd <alltraps>

80106f19 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $39
80106f1b:	6a 27                	push   $0x27
  jmp alltraps
80106f1d:	e9 ab f7 ff ff       	jmp    801066cd <alltraps>

80106f22 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $40
80106f24:	6a 28                	push   $0x28
  jmp alltraps
80106f26:	e9 a2 f7 ff ff       	jmp    801066cd <alltraps>

80106f2b <vector41>:
.globl vector41
vector41:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $41
80106f2d:	6a 29                	push   $0x29
  jmp alltraps
80106f2f:	e9 99 f7 ff ff       	jmp    801066cd <alltraps>

80106f34 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $42
80106f36:	6a 2a                	push   $0x2a
  jmp alltraps
80106f38:	e9 90 f7 ff ff       	jmp    801066cd <alltraps>

80106f3d <vector43>:
.globl vector43
vector43:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $43
80106f3f:	6a 2b                	push   $0x2b
  jmp alltraps
80106f41:	e9 87 f7 ff ff       	jmp    801066cd <alltraps>

80106f46 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $44
80106f48:	6a 2c                	push   $0x2c
  jmp alltraps
80106f4a:	e9 7e f7 ff ff       	jmp    801066cd <alltraps>

80106f4f <vector45>:
.globl vector45
vector45:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $45
80106f51:	6a 2d                	push   $0x2d
  jmp alltraps
80106f53:	e9 75 f7 ff ff       	jmp    801066cd <alltraps>

80106f58 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $46
80106f5a:	6a 2e                	push   $0x2e
  jmp alltraps
80106f5c:	e9 6c f7 ff ff       	jmp    801066cd <alltraps>

80106f61 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $47
80106f63:	6a 2f                	push   $0x2f
  jmp alltraps
80106f65:	e9 63 f7 ff ff       	jmp    801066cd <alltraps>

80106f6a <vector48>:
.globl vector48
vector48:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $48
80106f6c:	6a 30                	push   $0x30
  jmp alltraps
80106f6e:	e9 5a f7 ff ff       	jmp    801066cd <alltraps>

80106f73 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $49
80106f75:	6a 31                	push   $0x31
  jmp alltraps
80106f77:	e9 51 f7 ff ff       	jmp    801066cd <alltraps>

80106f7c <vector50>:
.globl vector50
vector50:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $50
80106f7e:	6a 32                	push   $0x32
  jmp alltraps
80106f80:	e9 48 f7 ff ff       	jmp    801066cd <alltraps>

80106f85 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $51
80106f87:	6a 33                	push   $0x33
  jmp alltraps
80106f89:	e9 3f f7 ff ff       	jmp    801066cd <alltraps>

80106f8e <vector52>:
.globl vector52
vector52:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $52
80106f90:	6a 34                	push   $0x34
  jmp alltraps
80106f92:	e9 36 f7 ff ff       	jmp    801066cd <alltraps>

80106f97 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $53
80106f99:	6a 35                	push   $0x35
  jmp alltraps
80106f9b:	e9 2d f7 ff ff       	jmp    801066cd <alltraps>

80106fa0 <vector54>:
.globl vector54
vector54:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $54
80106fa2:	6a 36                	push   $0x36
  jmp alltraps
80106fa4:	e9 24 f7 ff ff       	jmp    801066cd <alltraps>

80106fa9 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $55
80106fab:	6a 37                	push   $0x37
  jmp alltraps
80106fad:	e9 1b f7 ff ff       	jmp    801066cd <alltraps>

80106fb2 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $56
80106fb4:	6a 38                	push   $0x38
  jmp alltraps
80106fb6:	e9 12 f7 ff ff       	jmp    801066cd <alltraps>

80106fbb <vector57>:
.globl vector57
vector57:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $57
80106fbd:	6a 39                	push   $0x39
  jmp alltraps
80106fbf:	e9 09 f7 ff ff       	jmp    801066cd <alltraps>

80106fc4 <vector58>:
.globl vector58
vector58:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $58
80106fc6:	6a 3a                	push   $0x3a
  jmp alltraps
80106fc8:	e9 00 f7 ff ff       	jmp    801066cd <alltraps>

80106fcd <vector59>:
.globl vector59
vector59:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $59
80106fcf:	6a 3b                	push   $0x3b
  jmp alltraps
80106fd1:	e9 f7 f6 ff ff       	jmp    801066cd <alltraps>

80106fd6 <vector60>:
.globl vector60
vector60:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $60
80106fd8:	6a 3c                	push   $0x3c
  jmp alltraps
80106fda:	e9 ee f6 ff ff       	jmp    801066cd <alltraps>

80106fdf <vector61>:
.globl vector61
vector61:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $61
80106fe1:	6a 3d                	push   $0x3d
  jmp alltraps
80106fe3:	e9 e5 f6 ff ff       	jmp    801066cd <alltraps>

80106fe8 <vector62>:
.globl vector62
vector62:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $62
80106fea:	6a 3e                	push   $0x3e
  jmp alltraps
80106fec:	e9 dc f6 ff ff       	jmp    801066cd <alltraps>

80106ff1 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $63
80106ff3:	6a 3f                	push   $0x3f
  jmp alltraps
80106ff5:	e9 d3 f6 ff ff       	jmp    801066cd <alltraps>

80106ffa <vector64>:
.globl vector64
vector64:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $64
80106ffc:	6a 40                	push   $0x40
  jmp alltraps
80106ffe:	e9 ca f6 ff ff       	jmp    801066cd <alltraps>

80107003 <vector65>:
.globl vector65
vector65:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $65
80107005:	6a 41                	push   $0x41
  jmp alltraps
80107007:	e9 c1 f6 ff ff       	jmp    801066cd <alltraps>

8010700c <vector66>:
.globl vector66
vector66:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $66
8010700e:	6a 42                	push   $0x42
  jmp alltraps
80107010:	e9 b8 f6 ff ff       	jmp    801066cd <alltraps>

80107015 <vector67>:
.globl vector67
vector67:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $67
80107017:	6a 43                	push   $0x43
  jmp alltraps
80107019:	e9 af f6 ff ff       	jmp    801066cd <alltraps>

8010701e <vector68>:
.globl vector68
vector68:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $68
80107020:	6a 44                	push   $0x44
  jmp alltraps
80107022:	e9 a6 f6 ff ff       	jmp    801066cd <alltraps>

80107027 <vector69>:
.globl vector69
vector69:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $69
80107029:	6a 45                	push   $0x45
  jmp alltraps
8010702b:	e9 9d f6 ff ff       	jmp    801066cd <alltraps>

80107030 <vector70>:
.globl vector70
vector70:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $70
80107032:	6a 46                	push   $0x46
  jmp alltraps
80107034:	e9 94 f6 ff ff       	jmp    801066cd <alltraps>

80107039 <vector71>:
.globl vector71
vector71:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $71
8010703b:	6a 47                	push   $0x47
  jmp alltraps
8010703d:	e9 8b f6 ff ff       	jmp    801066cd <alltraps>

80107042 <vector72>:
.globl vector72
vector72:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $72
80107044:	6a 48                	push   $0x48
  jmp alltraps
80107046:	e9 82 f6 ff ff       	jmp    801066cd <alltraps>

8010704b <vector73>:
.globl vector73
vector73:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $73
8010704d:	6a 49                	push   $0x49
  jmp alltraps
8010704f:	e9 79 f6 ff ff       	jmp    801066cd <alltraps>

80107054 <vector74>:
.globl vector74
vector74:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $74
80107056:	6a 4a                	push   $0x4a
  jmp alltraps
80107058:	e9 70 f6 ff ff       	jmp    801066cd <alltraps>

8010705d <vector75>:
.globl vector75
vector75:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $75
8010705f:	6a 4b                	push   $0x4b
  jmp alltraps
80107061:	e9 67 f6 ff ff       	jmp    801066cd <alltraps>

80107066 <vector76>:
.globl vector76
vector76:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $76
80107068:	6a 4c                	push   $0x4c
  jmp alltraps
8010706a:	e9 5e f6 ff ff       	jmp    801066cd <alltraps>

8010706f <vector77>:
.globl vector77
vector77:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $77
80107071:	6a 4d                	push   $0x4d
  jmp alltraps
80107073:	e9 55 f6 ff ff       	jmp    801066cd <alltraps>

80107078 <vector78>:
.globl vector78
vector78:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $78
8010707a:	6a 4e                	push   $0x4e
  jmp alltraps
8010707c:	e9 4c f6 ff ff       	jmp    801066cd <alltraps>

80107081 <vector79>:
.globl vector79
vector79:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $79
80107083:	6a 4f                	push   $0x4f
  jmp alltraps
80107085:	e9 43 f6 ff ff       	jmp    801066cd <alltraps>

8010708a <vector80>:
.globl vector80
vector80:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $80
8010708c:	6a 50                	push   $0x50
  jmp alltraps
8010708e:	e9 3a f6 ff ff       	jmp    801066cd <alltraps>

80107093 <vector81>:
.globl vector81
vector81:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $81
80107095:	6a 51                	push   $0x51
  jmp alltraps
80107097:	e9 31 f6 ff ff       	jmp    801066cd <alltraps>

8010709c <vector82>:
.globl vector82
vector82:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $82
8010709e:	6a 52                	push   $0x52
  jmp alltraps
801070a0:	e9 28 f6 ff ff       	jmp    801066cd <alltraps>

801070a5 <vector83>:
.globl vector83
vector83:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $83
801070a7:	6a 53                	push   $0x53
  jmp alltraps
801070a9:	e9 1f f6 ff ff       	jmp    801066cd <alltraps>

801070ae <vector84>:
.globl vector84
vector84:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $84
801070b0:	6a 54                	push   $0x54
  jmp alltraps
801070b2:	e9 16 f6 ff ff       	jmp    801066cd <alltraps>

801070b7 <vector85>:
.globl vector85
vector85:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $85
801070b9:	6a 55                	push   $0x55
  jmp alltraps
801070bb:	e9 0d f6 ff ff       	jmp    801066cd <alltraps>

801070c0 <vector86>:
.globl vector86
vector86:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $86
801070c2:	6a 56                	push   $0x56
  jmp alltraps
801070c4:	e9 04 f6 ff ff       	jmp    801066cd <alltraps>

801070c9 <vector87>:
.globl vector87
vector87:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $87
801070cb:	6a 57                	push   $0x57
  jmp alltraps
801070cd:	e9 fb f5 ff ff       	jmp    801066cd <alltraps>

801070d2 <vector88>:
.globl vector88
vector88:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $88
801070d4:	6a 58                	push   $0x58
  jmp alltraps
801070d6:	e9 f2 f5 ff ff       	jmp    801066cd <alltraps>

801070db <vector89>:
.globl vector89
vector89:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $89
801070dd:	6a 59                	push   $0x59
  jmp alltraps
801070df:	e9 e9 f5 ff ff       	jmp    801066cd <alltraps>

801070e4 <vector90>:
.globl vector90
vector90:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $90
801070e6:	6a 5a                	push   $0x5a
  jmp alltraps
801070e8:	e9 e0 f5 ff ff       	jmp    801066cd <alltraps>

801070ed <vector91>:
.globl vector91
vector91:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $91
801070ef:	6a 5b                	push   $0x5b
  jmp alltraps
801070f1:	e9 d7 f5 ff ff       	jmp    801066cd <alltraps>

801070f6 <vector92>:
.globl vector92
vector92:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $92
801070f8:	6a 5c                	push   $0x5c
  jmp alltraps
801070fa:	e9 ce f5 ff ff       	jmp    801066cd <alltraps>

801070ff <vector93>:
.globl vector93
vector93:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $93
80107101:	6a 5d                	push   $0x5d
  jmp alltraps
80107103:	e9 c5 f5 ff ff       	jmp    801066cd <alltraps>

80107108 <vector94>:
.globl vector94
vector94:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $94
8010710a:	6a 5e                	push   $0x5e
  jmp alltraps
8010710c:	e9 bc f5 ff ff       	jmp    801066cd <alltraps>

80107111 <vector95>:
.globl vector95
vector95:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $95
80107113:	6a 5f                	push   $0x5f
  jmp alltraps
80107115:	e9 b3 f5 ff ff       	jmp    801066cd <alltraps>

8010711a <vector96>:
.globl vector96
vector96:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $96
8010711c:	6a 60                	push   $0x60
  jmp alltraps
8010711e:	e9 aa f5 ff ff       	jmp    801066cd <alltraps>

80107123 <vector97>:
.globl vector97
vector97:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $97
80107125:	6a 61                	push   $0x61
  jmp alltraps
80107127:	e9 a1 f5 ff ff       	jmp    801066cd <alltraps>

8010712c <vector98>:
.globl vector98
vector98:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $98
8010712e:	6a 62                	push   $0x62
  jmp alltraps
80107130:	e9 98 f5 ff ff       	jmp    801066cd <alltraps>

80107135 <vector99>:
.globl vector99
vector99:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $99
80107137:	6a 63                	push   $0x63
  jmp alltraps
80107139:	e9 8f f5 ff ff       	jmp    801066cd <alltraps>

8010713e <vector100>:
.globl vector100
vector100:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $100
80107140:	6a 64                	push   $0x64
  jmp alltraps
80107142:	e9 86 f5 ff ff       	jmp    801066cd <alltraps>

80107147 <vector101>:
.globl vector101
vector101:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $101
80107149:	6a 65                	push   $0x65
  jmp alltraps
8010714b:	e9 7d f5 ff ff       	jmp    801066cd <alltraps>

80107150 <vector102>:
.globl vector102
vector102:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $102
80107152:	6a 66                	push   $0x66
  jmp alltraps
80107154:	e9 74 f5 ff ff       	jmp    801066cd <alltraps>

80107159 <vector103>:
.globl vector103
vector103:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $103
8010715b:	6a 67                	push   $0x67
  jmp alltraps
8010715d:	e9 6b f5 ff ff       	jmp    801066cd <alltraps>

80107162 <vector104>:
.globl vector104
vector104:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $104
80107164:	6a 68                	push   $0x68
  jmp alltraps
80107166:	e9 62 f5 ff ff       	jmp    801066cd <alltraps>

8010716b <vector105>:
.globl vector105
vector105:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $105
8010716d:	6a 69                	push   $0x69
  jmp alltraps
8010716f:	e9 59 f5 ff ff       	jmp    801066cd <alltraps>

80107174 <vector106>:
.globl vector106
vector106:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $106
80107176:	6a 6a                	push   $0x6a
  jmp alltraps
80107178:	e9 50 f5 ff ff       	jmp    801066cd <alltraps>

8010717d <vector107>:
.globl vector107
vector107:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $107
8010717f:	6a 6b                	push   $0x6b
  jmp alltraps
80107181:	e9 47 f5 ff ff       	jmp    801066cd <alltraps>

80107186 <vector108>:
.globl vector108
vector108:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $108
80107188:	6a 6c                	push   $0x6c
  jmp alltraps
8010718a:	e9 3e f5 ff ff       	jmp    801066cd <alltraps>

8010718f <vector109>:
.globl vector109
vector109:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $109
80107191:	6a 6d                	push   $0x6d
  jmp alltraps
80107193:	e9 35 f5 ff ff       	jmp    801066cd <alltraps>

80107198 <vector110>:
.globl vector110
vector110:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $110
8010719a:	6a 6e                	push   $0x6e
  jmp alltraps
8010719c:	e9 2c f5 ff ff       	jmp    801066cd <alltraps>

801071a1 <vector111>:
.globl vector111
vector111:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $111
801071a3:	6a 6f                	push   $0x6f
  jmp alltraps
801071a5:	e9 23 f5 ff ff       	jmp    801066cd <alltraps>

801071aa <vector112>:
.globl vector112
vector112:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $112
801071ac:	6a 70                	push   $0x70
  jmp alltraps
801071ae:	e9 1a f5 ff ff       	jmp    801066cd <alltraps>

801071b3 <vector113>:
.globl vector113
vector113:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $113
801071b5:	6a 71                	push   $0x71
  jmp alltraps
801071b7:	e9 11 f5 ff ff       	jmp    801066cd <alltraps>

801071bc <vector114>:
.globl vector114
vector114:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $114
801071be:	6a 72                	push   $0x72
  jmp alltraps
801071c0:	e9 08 f5 ff ff       	jmp    801066cd <alltraps>

801071c5 <vector115>:
.globl vector115
vector115:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $115
801071c7:	6a 73                	push   $0x73
  jmp alltraps
801071c9:	e9 ff f4 ff ff       	jmp    801066cd <alltraps>

801071ce <vector116>:
.globl vector116
vector116:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $116
801071d0:	6a 74                	push   $0x74
  jmp alltraps
801071d2:	e9 f6 f4 ff ff       	jmp    801066cd <alltraps>

801071d7 <vector117>:
.globl vector117
vector117:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $117
801071d9:	6a 75                	push   $0x75
  jmp alltraps
801071db:	e9 ed f4 ff ff       	jmp    801066cd <alltraps>

801071e0 <vector118>:
.globl vector118
vector118:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $118
801071e2:	6a 76                	push   $0x76
  jmp alltraps
801071e4:	e9 e4 f4 ff ff       	jmp    801066cd <alltraps>

801071e9 <vector119>:
.globl vector119
vector119:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $119
801071eb:	6a 77                	push   $0x77
  jmp alltraps
801071ed:	e9 db f4 ff ff       	jmp    801066cd <alltraps>

801071f2 <vector120>:
.globl vector120
vector120:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $120
801071f4:	6a 78                	push   $0x78
  jmp alltraps
801071f6:	e9 d2 f4 ff ff       	jmp    801066cd <alltraps>

801071fb <vector121>:
.globl vector121
vector121:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $121
801071fd:	6a 79                	push   $0x79
  jmp alltraps
801071ff:	e9 c9 f4 ff ff       	jmp    801066cd <alltraps>

80107204 <vector122>:
.globl vector122
vector122:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $122
80107206:	6a 7a                	push   $0x7a
  jmp alltraps
80107208:	e9 c0 f4 ff ff       	jmp    801066cd <alltraps>

8010720d <vector123>:
.globl vector123
vector123:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $123
8010720f:	6a 7b                	push   $0x7b
  jmp alltraps
80107211:	e9 b7 f4 ff ff       	jmp    801066cd <alltraps>

80107216 <vector124>:
.globl vector124
vector124:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $124
80107218:	6a 7c                	push   $0x7c
  jmp alltraps
8010721a:	e9 ae f4 ff ff       	jmp    801066cd <alltraps>

8010721f <vector125>:
.globl vector125
vector125:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $125
80107221:	6a 7d                	push   $0x7d
  jmp alltraps
80107223:	e9 a5 f4 ff ff       	jmp    801066cd <alltraps>

80107228 <vector126>:
.globl vector126
vector126:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $126
8010722a:	6a 7e                	push   $0x7e
  jmp alltraps
8010722c:	e9 9c f4 ff ff       	jmp    801066cd <alltraps>

80107231 <vector127>:
.globl vector127
vector127:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $127
80107233:	6a 7f                	push   $0x7f
  jmp alltraps
80107235:	e9 93 f4 ff ff       	jmp    801066cd <alltraps>

8010723a <vector128>:
.globl vector128
vector128:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $128
8010723c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107241:	e9 87 f4 ff ff       	jmp    801066cd <alltraps>

80107246 <vector129>:
.globl vector129
vector129:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $129
80107248:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010724d:	e9 7b f4 ff ff       	jmp    801066cd <alltraps>

80107252 <vector130>:
.globl vector130
vector130:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $130
80107254:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107259:	e9 6f f4 ff ff       	jmp    801066cd <alltraps>

8010725e <vector131>:
.globl vector131
vector131:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $131
80107260:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107265:	e9 63 f4 ff ff       	jmp    801066cd <alltraps>

8010726a <vector132>:
.globl vector132
vector132:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $132
8010726c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107271:	e9 57 f4 ff ff       	jmp    801066cd <alltraps>

80107276 <vector133>:
.globl vector133
vector133:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $133
80107278:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010727d:	e9 4b f4 ff ff       	jmp    801066cd <alltraps>

80107282 <vector134>:
.globl vector134
vector134:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $134
80107284:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107289:	e9 3f f4 ff ff       	jmp    801066cd <alltraps>

8010728e <vector135>:
.globl vector135
vector135:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $135
80107290:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107295:	e9 33 f4 ff ff       	jmp    801066cd <alltraps>

8010729a <vector136>:
.globl vector136
vector136:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $136
8010729c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072a1:	e9 27 f4 ff ff       	jmp    801066cd <alltraps>

801072a6 <vector137>:
.globl vector137
vector137:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $137
801072a8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072ad:	e9 1b f4 ff ff       	jmp    801066cd <alltraps>

801072b2 <vector138>:
.globl vector138
vector138:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $138
801072b4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072b9:	e9 0f f4 ff ff       	jmp    801066cd <alltraps>

801072be <vector139>:
.globl vector139
vector139:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $139
801072c0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072c5:	e9 03 f4 ff ff       	jmp    801066cd <alltraps>

801072ca <vector140>:
.globl vector140
vector140:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $140
801072cc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801072d1:	e9 f7 f3 ff ff       	jmp    801066cd <alltraps>

801072d6 <vector141>:
.globl vector141
vector141:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $141
801072d8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801072dd:	e9 eb f3 ff ff       	jmp    801066cd <alltraps>

801072e2 <vector142>:
.globl vector142
vector142:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $142
801072e4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801072e9:	e9 df f3 ff ff       	jmp    801066cd <alltraps>

801072ee <vector143>:
.globl vector143
vector143:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $143
801072f0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072f5:	e9 d3 f3 ff ff       	jmp    801066cd <alltraps>

801072fa <vector144>:
.globl vector144
vector144:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $144
801072fc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107301:	e9 c7 f3 ff ff       	jmp    801066cd <alltraps>

80107306 <vector145>:
.globl vector145
vector145:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $145
80107308:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010730d:	e9 bb f3 ff ff       	jmp    801066cd <alltraps>

80107312 <vector146>:
.globl vector146
vector146:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $146
80107314:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107319:	e9 af f3 ff ff       	jmp    801066cd <alltraps>

8010731e <vector147>:
.globl vector147
vector147:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $147
80107320:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107325:	e9 a3 f3 ff ff       	jmp    801066cd <alltraps>

8010732a <vector148>:
.globl vector148
vector148:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $148
8010732c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107331:	e9 97 f3 ff ff       	jmp    801066cd <alltraps>

80107336 <vector149>:
.globl vector149
vector149:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $149
80107338:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010733d:	e9 8b f3 ff ff       	jmp    801066cd <alltraps>

80107342 <vector150>:
.globl vector150
vector150:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $150
80107344:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107349:	e9 7f f3 ff ff       	jmp    801066cd <alltraps>

8010734e <vector151>:
.globl vector151
vector151:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $151
80107350:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107355:	e9 73 f3 ff ff       	jmp    801066cd <alltraps>

8010735a <vector152>:
.globl vector152
vector152:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $152
8010735c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107361:	e9 67 f3 ff ff       	jmp    801066cd <alltraps>

80107366 <vector153>:
.globl vector153
vector153:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $153
80107368:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010736d:	e9 5b f3 ff ff       	jmp    801066cd <alltraps>

80107372 <vector154>:
.globl vector154
vector154:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $154
80107374:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107379:	e9 4f f3 ff ff       	jmp    801066cd <alltraps>

8010737e <vector155>:
.globl vector155
vector155:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $155
80107380:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107385:	e9 43 f3 ff ff       	jmp    801066cd <alltraps>

8010738a <vector156>:
.globl vector156
vector156:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $156
8010738c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107391:	e9 37 f3 ff ff       	jmp    801066cd <alltraps>

80107396 <vector157>:
.globl vector157
vector157:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $157
80107398:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010739d:	e9 2b f3 ff ff       	jmp    801066cd <alltraps>

801073a2 <vector158>:
.globl vector158
vector158:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $158
801073a4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073a9:	e9 1f f3 ff ff       	jmp    801066cd <alltraps>

801073ae <vector159>:
.globl vector159
vector159:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $159
801073b0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073b5:	e9 13 f3 ff ff       	jmp    801066cd <alltraps>

801073ba <vector160>:
.globl vector160
vector160:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $160
801073bc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073c1:	e9 07 f3 ff ff       	jmp    801066cd <alltraps>

801073c6 <vector161>:
.globl vector161
vector161:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $161
801073c8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073cd:	e9 fb f2 ff ff       	jmp    801066cd <alltraps>

801073d2 <vector162>:
.globl vector162
vector162:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $162
801073d4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801073d9:	e9 ef f2 ff ff       	jmp    801066cd <alltraps>

801073de <vector163>:
.globl vector163
vector163:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $163
801073e0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801073e5:	e9 e3 f2 ff ff       	jmp    801066cd <alltraps>

801073ea <vector164>:
.globl vector164
vector164:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $164
801073ec:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073f1:	e9 d7 f2 ff ff       	jmp    801066cd <alltraps>

801073f6 <vector165>:
.globl vector165
vector165:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $165
801073f8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073fd:	e9 cb f2 ff ff       	jmp    801066cd <alltraps>

80107402 <vector166>:
.globl vector166
vector166:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $166
80107404:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107409:	e9 bf f2 ff ff       	jmp    801066cd <alltraps>

8010740e <vector167>:
.globl vector167
vector167:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $167
80107410:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107415:	e9 b3 f2 ff ff       	jmp    801066cd <alltraps>

8010741a <vector168>:
.globl vector168
vector168:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $168
8010741c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107421:	e9 a7 f2 ff ff       	jmp    801066cd <alltraps>

80107426 <vector169>:
.globl vector169
vector169:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $169
80107428:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010742d:	e9 9b f2 ff ff       	jmp    801066cd <alltraps>

80107432 <vector170>:
.globl vector170
vector170:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $170
80107434:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107439:	e9 8f f2 ff ff       	jmp    801066cd <alltraps>

8010743e <vector171>:
.globl vector171
vector171:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $171
80107440:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107445:	e9 83 f2 ff ff       	jmp    801066cd <alltraps>

8010744a <vector172>:
.globl vector172
vector172:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $172
8010744c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107451:	e9 77 f2 ff ff       	jmp    801066cd <alltraps>

80107456 <vector173>:
.globl vector173
vector173:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $173
80107458:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010745d:	e9 6b f2 ff ff       	jmp    801066cd <alltraps>

80107462 <vector174>:
.globl vector174
vector174:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $174
80107464:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107469:	e9 5f f2 ff ff       	jmp    801066cd <alltraps>

8010746e <vector175>:
.globl vector175
vector175:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $175
80107470:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107475:	e9 53 f2 ff ff       	jmp    801066cd <alltraps>

8010747a <vector176>:
.globl vector176
vector176:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $176
8010747c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107481:	e9 47 f2 ff ff       	jmp    801066cd <alltraps>

80107486 <vector177>:
.globl vector177
vector177:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $177
80107488:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010748d:	e9 3b f2 ff ff       	jmp    801066cd <alltraps>

80107492 <vector178>:
.globl vector178
vector178:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $178
80107494:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107499:	e9 2f f2 ff ff       	jmp    801066cd <alltraps>

8010749e <vector179>:
.globl vector179
vector179:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $179
801074a0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074a5:	e9 23 f2 ff ff       	jmp    801066cd <alltraps>

801074aa <vector180>:
.globl vector180
vector180:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $180
801074ac:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074b1:	e9 17 f2 ff ff       	jmp    801066cd <alltraps>

801074b6 <vector181>:
.globl vector181
vector181:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $181
801074b8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074bd:	e9 0b f2 ff ff       	jmp    801066cd <alltraps>

801074c2 <vector182>:
.globl vector182
vector182:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $182
801074c4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074c9:	e9 ff f1 ff ff       	jmp    801066cd <alltraps>

801074ce <vector183>:
.globl vector183
vector183:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $183
801074d0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801074d5:	e9 f3 f1 ff ff       	jmp    801066cd <alltraps>

801074da <vector184>:
.globl vector184
vector184:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $184
801074dc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801074e1:	e9 e7 f1 ff ff       	jmp    801066cd <alltraps>

801074e6 <vector185>:
.globl vector185
vector185:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $185
801074e8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801074ed:	e9 db f1 ff ff       	jmp    801066cd <alltraps>

801074f2 <vector186>:
.globl vector186
vector186:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $186
801074f4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074f9:	e9 cf f1 ff ff       	jmp    801066cd <alltraps>

801074fe <vector187>:
.globl vector187
vector187:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $187
80107500:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107505:	e9 c3 f1 ff ff       	jmp    801066cd <alltraps>

8010750a <vector188>:
.globl vector188
vector188:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $188
8010750c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107511:	e9 b7 f1 ff ff       	jmp    801066cd <alltraps>

80107516 <vector189>:
.globl vector189
vector189:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $189
80107518:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010751d:	e9 ab f1 ff ff       	jmp    801066cd <alltraps>

80107522 <vector190>:
.globl vector190
vector190:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $190
80107524:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107529:	e9 9f f1 ff ff       	jmp    801066cd <alltraps>

8010752e <vector191>:
.globl vector191
vector191:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $191
80107530:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107535:	e9 93 f1 ff ff       	jmp    801066cd <alltraps>

8010753a <vector192>:
.globl vector192
vector192:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $192
8010753c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107541:	e9 87 f1 ff ff       	jmp    801066cd <alltraps>

80107546 <vector193>:
.globl vector193
vector193:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $193
80107548:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010754d:	e9 7b f1 ff ff       	jmp    801066cd <alltraps>

80107552 <vector194>:
.globl vector194
vector194:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $194
80107554:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107559:	e9 6f f1 ff ff       	jmp    801066cd <alltraps>

8010755e <vector195>:
.globl vector195
vector195:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $195
80107560:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107565:	e9 63 f1 ff ff       	jmp    801066cd <alltraps>

8010756a <vector196>:
.globl vector196
vector196:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $196
8010756c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107571:	e9 57 f1 ff ff       	jmp    801066cd <alltraps>

80107576 <vector197>:
.globl vector197
vector197:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $197
80107578:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010757d:	e9 4b f1 ff ff       	jmp    801066cd <alltraps>

80107582 <vector198>:
.globl vector198
vector198:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $198
80107584:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107589:	e9 3f f1 ff ff       	jmp    801066cd <alltraps>

8010758e <vector199>:
.globl vector199
vector199:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $199
80107590:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107595:	e9 33 f1 ff ff       	jmp    801066cd <alltraps>

8010759a <vector200>:
.globl vector200
vector200:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $200
8010759c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075a1:	e9 27 f1 ff ff       	jmp    801066cd <alltraps>

801075a6 <vector201>:
.globl vector201
vector201:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $201
801075a8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075ad:	e9 1b f1 ff ff       	jmp    801066cd <alltraps>

801075b2 <vector202>:
.globl vector202
vector202:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $202
801075b4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075b9:	e9 0f f1 ff ff       	jmp    801066cd <alltraps>

801075be <vector203>:
.globl vector203
vector203:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $203
801075c0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075c5:	e9 03 f1 ff ff       	jmp    801066cd <alltraps>

801075ca <vector204>:
.globl vector204
vector204:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $204
801075cc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801075d1:	e9 f7 f0 ff ff       	jmp    801066cd <alltraps>

801075d6 <vector205>:
.globl vector205
vector205:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $205
801075d8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801075dd:	e9 eb f0 ff ff       	jmp    801066cd <alltraps>

801075e2 <vector206>:
.globl vector206
vector206:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $206
801075e4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801075e9:	e9 df f0 ff ff       	jmp    801066cd <alltraps>

801075ee <vector207>:
.globl vector207
vector207:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $207
801075f0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075f5:	e9 d3 f0 ff ff       	jmp    801066cd <alltraps>

801075fa <vector208>:
.globl vector208
vector208:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $208
801075fc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107601:	e9 c7 f0 ff ff       	jmp    801066cd <alltraps>

80107606 <vector209>:
.globl vector209
vector209:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $209
80107608:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010760d:	e9 bb f0 ff ff       	jmp    801066cd <alltraps>

80107612 <vector210>:
.globl vector210
vector210:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $210
80107614:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107619:	e9 af f0 ff ff       	jmp    801066cd <alltraps>

8010761e <vector211>:
.globl vector211
vector211:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $211
80107620:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107625:	e9 a3 f0 ff ff       	jmp    801066cd <alltraps>

8010762a <vector212>:
.globl vector212
vector212:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $212
8010762c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107631:	e9 97 f0 ff ff       	jmp    801066cd <alltraps>

80107636 <vector213>:
.globl vector213
vector213:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $213
80107638:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010763d:	e9 8b f0 ff ff       	jmp    801066cd <alltraps>

80107642 <vector214>:
.globl vector214
vector214:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $214
80107644:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107649:	e9 7f f0 ff ff       	jmp    801066cd <alltraps>

8010764e <vector215>:
.globl vector215
vector215:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $215
80107650:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107655:	e9 73 f0 ff ff       	jmp    801066cd <alltraps>

8010765a <vector216>:
.globl vector216
vector216:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $216
8010765c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107661:	e9 67 f0 ff ff       	jmp    801066cd <alltraps>

80107666 <vector217>:
.globl vector217
vector217:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $217
80107668:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010766d:	e9 5b f0 ff ff       	jmp    801066cd <alltraps>

80107672 <vector218>:
.globl vector218
vector218:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $218
80107674:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107679:	e9 4f f0 ff ff       	jmp    801066cd <alltraps>

8010767e <vector219>:
.globl vector219
vector219:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $219
80107680:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107685:	e9 43 f0 ff ff       	jmp    801066cd <alltraps>

8010768a <vector220>:
.globl vector220
vector220:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $220
8010768c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107691:	e9 37 f0 ff ff       	jmp    801066cd <alltraps>

80107696 <vector221>:
.globl vector221
vector221:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $221
80107698:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010769d:	e9 2b f0 ff ff       	jmp    801066cd <alltraps>

801076a2 <vector222>:
.globl vector222
vector222:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $222
801076a4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076a9:	e9 1f f0 ff ff       	jmp    801066cd <alltraps>

801076ae <vector223>:
.globl vector223
vector223:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $223
801076b0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076b5:	e9 13 f0 ff ff       	jmp    801066cd <alltraps>

801076ba <vector224>:
.globl vector224
vector224:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $224
801076bc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076c1:	e9 07 f0 ff ff       	jmp    801066cd <alltraps>

801076c6 <vector225>:
.globl vector225
vector225:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $225
801076c8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076cd:	e9 fb ef ff ff       	jmp    801066cd <alltraps>

801076d2 <vector226>:
.globl vector226
vector226:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $226
801076d4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801076d9:	e9 ef ef ff ff       	jmp    801066cd <alltraps>

801076de <vector227>:
.globl vector227
vector227:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $227
801076e0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801076e5:	e9 e3 ef ff ff       	jmp    801066cd <alltraps>

801076ea <vector228>:
.globl vector228
vector228:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $228
801076ec:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076f1:	e9 d7 ef ff ff       	jmp    801066cd <alltraps>

801076f6 <vector229>:
.globl vector229
vector229:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $229
801076f8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076fd:	e9 cb ef ff ff       	jmp    801066cd <alltraps>

80107702 <vector230>:
.globl vector230
vector230:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $230
80107704:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107709:	e9 bf ef ff ff       	jmp    801066cd <alltraps>

8010770e <vector231>:
.globl vector231
vector231:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $231
80107710:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107715:	e9 b3 ef ff ff       	jmp    801066cd <alltraps>

8010771a <vector232>:
.globl vector232
vector232:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $232
8010771c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107721:	e9 a7 ef ff ff       	jmp    801066cd <alltraps>

80107726 <vector233>:
.globl vector233
vector233:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $233
80107728:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010772d:	e9 9b ef ff ff       	jmp    801066cd <alltraps>

80107732 <vector234>:
.globl vector234
vector234:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $234
80107734:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107739:	e9 8f ef ff ff       	jmp    801066cd <alltraps>

8010773e <vector235>:
.globl vector235
vector235:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $235
80107740:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107745:	e9 83 ef ff ff       	jmp    801066cd <alltraps>

8010774a <vector236>:
.globl vector236
vector236:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $236
8010774c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107751:	e9 77 ef ff ff       	jmp    801066cd <alltraps>

80107756 <vector237>:
.globl vector237
vector237:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $237
80107758:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010775d:	e9 6b ef ff ff       	jmp    801066cd <alltraps>

80107762 <vector238>:
.globl vector238
vector238:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $238
80107764:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107769:	e9 5f ef ff ff       	jmp    801066cd <alltraps>

8010776e <vector239>:
.globl vector239
vector239:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $239
80107770:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107775:	e9 53 ef ff ff       	jmp    801066cd <alltraps>

8010777a <vector240>:
.globl vector240
vector240:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $240
8010777c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107781:	e9 47 ef ff ff       	jmp    801066cd <alltraps>

80107786 <vector241>:
.globl vector241
vector241:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $241
80107788:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010778d:	e9 3b ef ff ff       	jmp    801066cd <alltraps>

80107792 <vector242>:
.globl vector242
vector242:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $242
80107794:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107799:	e9 2f ef ff ff       	jmp    801066cd <alltraps>

8010779e <vector243>:
.globl vector243
vector243:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $243
801077a0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077a5:	e9 23 ef ff ff       	jmp    801066cd <alltraps>

801077aa <vector244>:
.globl vector244
vector244:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $244
801077ac:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077b1:	e9 17 ef ff ff       	jmp    801066cd <alltraps>

801077b6 <vector245>:
.globl vector245
vector245:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $245
801077b8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077bd:	e9 0b ef ff ff       	jmp    801066cd <alltraps>

801077c2 <vector246>:
.globl vector246
vector246:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $246
801077c4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077c9:	e9 ff ee ff ff       	jmp    801066cd <alltraps>

801077ce <vector247>:
.globl vector247
vector247:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $247
801077d0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801077d5:	e9 f3 ee ff ff       	jmp    801066cd <alltraps>

801077da <vector248>:
.globl vector248
vector248:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $248
801077dc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801077e1:	e9 e7 ee ff ff       	jmp    801066cd <alltraps>

801077e6 <vector249>:
.globl vector249
vector249:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $249
801077e8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801077ed:	e9 db ee ff ff       	jmp    801066cd <alltraps>

801077f2 <vector250>:
.globl vector250
vector250:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $250
801077f4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077f9:	e9 cf ee ff ff       	jmp    801066cd <alltraps>

801077fe <vector251>:
.globl vector251
vector251:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $251
80107800:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107805:	e9 c3 ee ff ff       	jmp    801066cd <alltraps>

8010780a <vector252>:
.globl vector252
vector252:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $252
8010780c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107811:	e9 b7 ee ff ff       	jmp    801066cd <alltraps>

80107816 <vector253>:
.globl vector253
vector253:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $253
80107818:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010781d:	e9 ab ee ff ff       	jmp    801066cd <alltraps>

80107822 <vector254>:
.globl vector254
vector254:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $254
80107824:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107829:	e9 9f ee ff ff       	jmp    801066cd <alltraps>

8010782e <vector255>:
.globl vector255
vector255:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $255
80107830:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107835:	e9 93 ee ff ff       	jmp    801066cd <alltraps>

8010783a <lgdt>:
{
8010783a:	55                   	push   %ebp
8010783b:	89 e5                	mov    %esp,%ebp
8010783d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107840:	8b 45 0c             	mov    0xc(%ebp),%eax
80107843:	83 e8 01             	sub    $0x1,%eax
80107846:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010784a:	8b 45 08             	mov    0x8(%ebp),%eax
8010784d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107851:	8b 45 08             	mov    0x8(%ebp),%eax
80107854:	c1 e8 10             	shr    $0x10,%eax
80107857:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010785b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010785e:	0f 01 10             	lgdtl  (%eax)
}
80107861:	90                   	nop
80107862:	c9                   	leave
80107863:	c3                   	ret

80107864 <ltr>:
{
80107864:	55                   	push   %ebp
80107865:	89 e5                	mov    %esp,%ebp
80107867:	83 ec 04             	sub    $0x4,%esp
8010786a:	8b 45 08             	mov    0x8(%ebp),%eax
8010786d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107871:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107875:	0f 00 d8             	ltr    %eax
}
80107878:	90                   	nop
80107879:	c9                   	leave
8010787a:	c3                   	ret

8010787b <lcr3>:

static inline void
lcr3(uint val)
{
8010787b:	55                   	push   %ebp
8010787c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010787e:	8b 45 08             	mov    0x8(%ebp),%eax
80107881:	0f 22 d8             	mov    %eax,%cr3
}
80107884:	90                   	nop
80107885:	5d                   	pop    %ebp
80107886:	c3                   	ret

80107887 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107887:	55                   	push   %ebp
80107888:	89 e5                	mov    %esp,%ebp
8010788a:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010788d:	e8 0b c1 ff ff       	call   8010399d <cpuid>
80107892:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107898:	05 c0 79 19 80       	add    $0x801979c0,%eax
8010789d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801078a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ac:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801078b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801078b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078c0:	83 e2 f0             	and    $0xfffffff0,%edx
801078c3:	83 ca 0a             	or     $0xa,%edx
801078c6:	88 50 7d             	mov    %dl,0x7d(%eax)
801078c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078d0:	83 ca 10             	or     $0x10,%edx
801078d3:	88 50 7d             	mov    %dl,0x7d(%eax)
801078d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078dd:	83 e2 9f             	and    $0xffffff9f,%edx
801078e0:	88 50 7d             	mov    %dl,0x7d(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078ea:	83 ca 80             	or     $0xffffff80,%edx
801078ed:	88 50 7d             	mov    %dl,0x7d(%eax)
801078f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078f7:	83 ca 0f             	or     $0xf,%edx
801078fa:	88 50 7e             	mov    %dl,0x7e(%eax)
801078fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107900:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107904:	83 e2 ef             	and    $0xffffffef,%edx
80107907:	88 50 7e             	mov    %dl,0x7e(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107911:	83 e2 df             	and    $0xffffffdf,%edx
80107914:	88 50 7e             	mov    %dl,0x7e(%eax)
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010791e:	83 ca 40             	or     $0x40,%edx
80107921:	88 50 7e             	mov    %dl,0x7e(%eax)
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010792b:	83 ca 80             	or     $0xffffff80,%edx
8010792e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107942:	ff ff 
80107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107947:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010794e:	00 00 
80107950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107953:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010795a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107964:	83 e2 f0             	and    $0xfffffff0,%edx
80107967:	83 ca 02             	or     $0x2,%edx
8010796a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010797a:	83 ca 10             	or     $0x10,%edx
8010797d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107986:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010798d:	83 e2 9f             	and    $0xffffff9f,%edx
80107990:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079a0:	83 ca 80             	or     $0xffffff80,%edx
801079a3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079b3:	83 ca 0f             	or     $0xf,%edx
801079b6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079c6:	83 e2 ef             	and    $0xffffffef,%edx
801079c9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079d9:	83 e2 df             	and    $0xffffffdf,%edx
801079dc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079ec:	83 ca 40             	or     $0x40,%edx
801079ef:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079ff:	83 ca 80             	or     $0xffffff80,%edx
80107a02:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107a1c:	ff ff 
80107a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a21:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107a28:	00 00 
80107a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a37:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a3e:	83 e2 f0             	and    $0xfffffff0,%edx
80107a41:	83 ca 0a             	or     $0xa,%edx
80107a44:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a54:	83 ca 10             	or     $0x10,%edx
80107a57:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a60:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a67:	83 ca 60             	or     $0x60,%edx
80107a6a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a73:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a7a:	83 ca 80             	or     $0xffffff80,%edx
80107a7d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a86:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a8d:	83 ca 0f             	or     $0xf,%edx
80107a90:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a99:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aa0:	83 e2 ef             	and    $0xffffffef,%edx
80107aa3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aac:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ab3:	83 e2 df             	and    $0xffffffdf,%edx
80107ab6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ac6:	83 ca 40             	or     $0x40,%edx
80107ac9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ad9:	83 ca 80             	or     $0xffffff80,%edx
80107adc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107af6:	ff ff 
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b02:	00 00 
80107b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b07:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b11:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b18:	83 e2 f0             	and    $0xfffffff0,%edx
80107b1b:	83 ca 02             	or     $0x2,%edx
80107b1e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b2e:	83 ca 10             	or     $0x10,%edx
80107b31:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b41:	83 ca 60             	or     $0x60,%edx
80107b44:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b54:	83 ca 80             	or     $0xffffff80,%edx
80107b57:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b60:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b67:	83 ca 0f             	or     $0xf,%edx
80107b6a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b73:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b7a:	83 e2 ef             	and    $0xffffffef,%edx
80107b7d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b86:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b8d:	83 e2 df             	and    $0xffffffdf,%edx
80107b90:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b99:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ba0:	83 ca 40             	or     $0x40,%edx
80107ba3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb3:	83 ca 80             	or     $0xffffff80,%edx
80107bb6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbf:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc9:	83 c0 70             	add    $0x70,%eax
80107bcc:	83 ec 08             	sub    $0x8,%esp
80107bcf:	6a 30                	push   $0x30
80107bd1:	50                   	push   %eax
80107bd2:	e8 63 fc ff ff       	call   8010783a <lgdt>
80107bd7:	83 c4 10             	add    $0x10,%esp
}
80107bda:	90                   	nop
80107bdb:	c9                   	leave
80107bdc:	c3                   	ret

80107bdd <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107bdd:	55                   	push   %ebp
80107bde:	89 e5                	mov    %esp,%ebp
80107be0:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be6:	c1 e8 16             	shr    $0x16,%eax
80107be9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf3:	01 d0                	add    %edx,%eax
80107bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bfb:	8b 00                	mov    (%eax),%eax
80107bfd:	83 e0 01             	and    $0x1,%eax
80107c00:	85 c0                	test   %eax,%eax
80107c02:	74 14                	je     80107c18 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c07:	8b 00                	mov    (%eax),%eax
80107c09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80107c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c16:	eb 42                	jmp    80107c5a <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c1c:	74 0e                	je     80107c2c <walkpgdir+0x4f>
80107c1e:	e8 85 ab ff ff       	call   801027a8 <kalloc>
80107c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c2a:	75 07                	jne    80107c33 <walkpgdir+0x56>
      return 0;
80107c2c:	b8 00 00 00 00       	mov    $0x0,%eax
80107c31:	eb 3e                	jmp    80107c71 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c33:	83 ec 04             	sub    $0x4,%esp
80107c36:	68 00 10 00 00       	push   $0x1000
80107c3b:	6a 00                	push   $0x0
80107c3d:	ff 75 f4             	push   -0xc(%ebp)
80107c40:	e8 79 d6 ff ff       	call   801052be <memset>
80107c45:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4b:	05 00 00 00 80       	add    $0x80000000,%eax
80107c50:	83 c8 07             	or     $0x7,%eax
80107c53:	89 c2                	mov    %eax,%edx
80107c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c58:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c5d:	c1 e8 0c             	shr    $0xc,%eax
80107c60:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6f:	01 d0                	add    %edx,%eax
}
80107c71:	c9                   	leave
80107c72:	c3                   	ret

80107c73 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c73:	55                   	push   %ebp
80107c74:	89 e5                	mov    %esp,%ebp
80107c76:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107c79:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c84:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c87:	8b 45 10             	mov    0x10(%ebp),%eax
80107c8a:	01 d0                	add    %edx,%eax
80107c8c:	83 e8 01             	sub    $0x1,%eax
80107c8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c97:	83 ec 04             	sub    $0x4,%esp
80107c9a:	6a 01                	push   $0x1
80107c9c:	ff 75 f4             	push   -0xc(%ebp)
80107c9f:	ff 75 08             	push   0x8(%ebp)
80107ca2:	e8 36 ff ff ff       	call   80107bdd <walkpgdir>
80107ca7:	83 c4 10             	add    $0x10,%esp
80107caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cb1:	75 07                	jne    80107cba <mappages+0x47>
      return -1;
80107cb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cb8:	eb 47                	jmp    80107d01 <mappages+0x8e>
    if(*pte & PTE_P)
80107cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cbd:	8b 00                	mov    (%eax),%eax
80107cbf:	83 e0 01             	and    $0x1,%eax
80107cc2:	85 c0                	test   %eax,%eax
80107cc4:	74 0d                	je     80107cd3 <mappages+0x60>
      panic("remap");
80107cc6:	83 ec 0c             	sub    $0xc,%esp
80107cc9:	68 f8 b0 10 80       	push   $0x8010b0f8
80107cce:	e8 d6 88 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107cd3:	8b 45 18             	mov    0x18(%ebp),%eax
80107cd6:	0b 45 14             	or     0x14(%ebp),%eax
80107cd9:	83 c8 01             	or     $0x1,%eax
80107cdc:	89 c2                	mov    %eax,%edx
80107cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ce1:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ce9:	74 10                	je     80107cfb <mappages+0x88>
      break;
    a += PGSIZE;
80107ceb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107cf2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107cf9:	eb 9c                	jmp    80107c97 <mappages+0x24>
      break;
80107cfb:	90                   	nop
  }
  return 0;
80107cfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d01:	c9                   	leave
80107d02:	c3                   	ret

80107d03 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d03:	55                   	push   %ebp
80107d04:	89 e5                	mov    %esp,%ebp
80107d06:	53                   	push   %ebx
80107d07:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107d0a:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107d11:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107d16:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107d1b:	29 c2                	sub    %eax,%edx
80107d1d:	89 d0                	mov    %edx,%eax
80107d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107d22:	a1 7c 7a 19 80       	mov    0x80197a7c,%eax
80107d27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107d2a:	8b 15 7c 7a 19 80    	mov    0x80197a7c,%edx
80107d30:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107d35:	01 d0                	add    %edx,%eax
80107d37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107d3a:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d44:	83 c0 30             	add    $0x30,%eax
80107d47:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107d4a:	89 10                	mov    %edx,(%eax)
80107d4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107d4f:	89 50 04             	mov    %edx,0x4(%eax)
80107d52:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d55:	89 50 08             	mov    %edx,0x8(%eax)
80107d58:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107d5b:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107d5e:	e8 45 aa ff ff       	call   801027a8 <kalloc>
80107d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d6a:	75 07                	jne    80107d73 <setupkvm+0x70>
    return 0;
80107d6c:	b8 00 00 00 00       	mov    $0x0,%eax
80107d71:	eb 78                	jmp    80107deb <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107d73:	83 ec 04             	sub    $0x4,%esp
80107d76:	68 00 10 00 00       	push   $0x1000
80107d7b:	6a 00                	push   $0x0
80107d7d:	ff 75 f0             	push   -0x10(%ebp)
80107d80:	e8 39 d5 ff ff       	call   801052be <memset>
80107d85:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d88:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107d8f:	eb 4e                	jmp    80107ddf <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d94:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9a:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	8b 58 08             	mov    0x8(%eax),%ebx
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	8b 40 04             	mov    0x4(%eax),%eax
80107da9:	29 c3                	sub    %eax,%ebx
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	8b 00                	mov    (%eax),%eax
80107db0:	83 ec 0c             	sub    $0xc,%esp
80107db3:	51                   	push   %ecx
80107db4:	52                   	push   %edx
80107db5:	53                   	push   %ebx
80107db6:	50                   	push   %eax
80107db7:	ff 75 f0             	push   -0x10(%ebp)
80107dba:	e8 b4 fe ff ff       	call   80107c73 <mappages>
80107dbf:	83 c4 20             	add    $0x20,%esp
80107dc2:	85 c0                	test   %eax,%eax
80107dc4:	79 15                	jns    80107ddb <setupkvm+0xd8>
      freevm(pgdir);
80107dc6:	83 ec 0c             	sub    $0xc,%esp
80107dc9:	ff 75 f0             	push   -0x10(%ebp)
80107dcc:	e8 f5 04 00 00       	call   801082c6 <freevm>
80107dd1:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dd4:	b8 00 00 00 00       	mov    $0x0,%eax
80107dd9:	eb 10                	jmp    80107deb <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ddb:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ddf:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107de6:	72 a9                	jb     80107d91 <setupkvm+0x8e>
    }
  return pgdir;
80107de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107deb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107dee:	c9                   	leave
80107def:	c3                   	ret

80107df0 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107df0:	55                   	push   %ebp
80107df1:	89 e5                	mov    %esp,%ebp
80107df3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107df6:	e8 08 ff ff ff       	call   80107d03 <setupkvm>
80107dfb:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  switchkvm();
80107e00:	e8 03 00 00 00       	call   80107e08 <switchkvm>
}
80107e05:	90                   	nop
80107e06:	c9                   	leave
80107e07:	c3                   	ret

80107e08 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e08:	55                   	push   %ebp
80107e09:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107e0b:	a1 bc 79 19 80       	mov    0x801979bc,%eax
80107e10:	05 00 00 00 80       	add    $0x80000000,%eax
80107e15:	50                   	push   %eax
80107e16:	e8 60 fa ff ff       	call   8010787b <lcr3>
80107e1b:	83 c4 04             	add    $0x4,%esp
}
80107e1e:	90                   	nop
80107e1f:	c9                   	leave
80107e20:	c3                   	ret

80107e21 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e21:	55                   	push   %ebp
80107e22:	89 e5                	mov    %esp,%ebp
80107e24:	56                   	push   %esi
80107e25:	53                   	push   %ebx
80107e26:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107e29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e2d:	75 0d                	jne    80107e3c <switchuvm+0x1b>
    panic("switchuvm: no process");
80107e2f:	83 ec 0c             	sub    $0xc,%esp
80107e32:	68 fe b0 10 80       	push   $0x8010b0fe
80107e37:	e8 6d 87 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3f:	8b 40 08             	mov    0x8(%eax),%eax
80107e42:	85 c0                	test   %eax,%eax
80107e44:	75 0d                	jne    80107e53 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107e46:	83 ec 0c             	sub    $0xc,%esp
80107e49:	68 14 b1 10 80       	push   $0x8010b114
80107e4e:	e8 56 87 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107e53:	8b 45 08             	mov    0x8(%ebp),%eax
80107e56:	8b 40 04             	mov    0x4(%eax),%eax
80107e59:	85 c0                	test   %eax,%eax
80107e5b:	75 0d                	jne    80107e6a <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107e5d:	83 ec 0c             	sub    $0xc,%esp
80107e60:	68 29 b1 10 80       	push   $0x8010b129
80107e65:	e8 3f 87 ff ff       	call   801005a9 <panic>

  pushcli();
80107e6a:	e8 44 d3 ff ff       	call   801051b3 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107e6f:	e8 44 bb ff ff       	call   801039b8 <mycpu>
80107e74:	89 c3                	mov    %eax,%ebx
80107e76:	e8 3d bb ff ff       	call   801039b8 <mycpu>
80107e7b:	83 c0 08             	add    $0x8,%eax
80107e7e:	89 c6                	mov    %eax,%esi
80107e80:	e8 33 bb ff ff       	call   801039b8 <mycpu>
80107e85:	83 c0 08             	add    $0x8,%eax
80107e88:	c1 e8 10             	shr    $0x10,%eax
80107e8b:	88 45 f7             	mov    %al,-0x9(%ebp)
80107e8e:	e8 25 bb ff ff       	call   801039b8 <mycpu>
80107e93:	83 c0 08             	add    $0x8,%eax
80107e96:	c1 e8 18             	shr    $0x18,%eax
80107e99:	89 c2                	mov    %eax,%edx
80107e9b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ea2:	67 00 
80107ea4:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107eab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107eaf:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107eb5:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ebc:	83 e0 f0             	and    $0xfffffff0,%eax
80107ebf:	83 c8 09             	or     $0x9,%eax
80107ec2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ec8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ecf:	83 c8 10             	or     $0x10,%eax
80107ed2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ed8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107edf:	83 e0 9f             	and    $0xffffff9f,%eax
80107ee2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ee8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107eef:	83 c8 80             	or     $0xffffff80,%eax
80107ef2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ef8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107eff:	83 e0 f0             	and    $0xfffffff0,%eax
80107f02:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f08:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f0f:	83 e0 ef             	and    $0xffffffef,%eax
80107f12:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f18:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f1f:	83 e0 df             	and    $0xffffffdf,%eax
80107f22:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f28:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f2f:	83 c8 40             	or     $0x40,%eax
80107f32:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f38:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107f3f:	83 e0 7f             	and    $0x7f,%eax
80107f42:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107f48:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107f4e:	e8 65 ba ff ff       	call   801039b8 <mycpu>
80107f53:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f5a:	83 e2 ef             	and    $0xffffffef,%edx
80107f5d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107f63:	e8 50 ba ff ff       	call   801039b8 <mycpu>
80107f68:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107f71:	8b 40 08             	mov    0x8(%eax),%eax
80107f74:	89 c3                	mov    %eax,%ebx
80107f76:	e8 3d ba ff ff       	call   801039b8 <mycpu>
80107f7b:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107f81:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f84:	e8 2f ba ff ff       	call   801039b8 <mycpu>
80107f89:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f8f:	83 ec 0c             	sub    $0xc,%esp
80107f92:	6a 28                	push   $0x28
80107f94:	e8 cb f8 ff ff       	call   80107864 <ltr>
80107f99:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9f:	8b 40 04             	mov    0x4(%eax),%eax
80107fa2:	05 00 00 00 80       	add    $0x80000000,%eax
80107fa7:	83 ec 0c             	sub    $0xc,%esp
80107faa:	50                   	push   %eax
80107fab:	e8 cb f8 ff ff       	call   8010787b <lcr3>
80107fb0:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fb3:	e8 48 d2 ff ff       	call   80105200 <popcli>
}
80107fb8:	90                   	nop
80107fb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107fbc:	5b                   	pop    %ebx
80107fbd:	5e                   	pop    %esi
80107fbe:	5d                   	pop    %ebp
80107fbf:	c3                   	ret

80107fc0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fc0:	55                   	push   %ebp
80107fc1:	89 e5                	mov    %esp,%ebp
80107fc3:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107fc6:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fcd:	76 0d                	jbe    80107fdc <inituvm+0x1c>
    panic("inituvm: more than a page");
80107fcf:	83 ec 0c             	sub    $0xc,%esp
80107fd2:	68 3d b1 10 80       	push   $0x8010b13d
80107fd7:	e8 cd 85 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107fdc:	e8 c7 a7 ff ff       	call   801027a8 <kalloc>
80107fe1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107fe4:	83 ec 04             	sub    $0x4,%esp
80107fe7:	68 00 10 00 00       	push   $0x1000
80107fec:	6a 00                	push   $0x0
80107fee:	ff 75 f4             	push   -0xc(%ebp)
80107ff1:	e8 c8 d2 ff ff       	call   801052be <memset>
80107ff6:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffc:	05 00 00 00 80       	add    $0x80000000,%eax
80108001:	83 ec 0c             	sub    $0xc,%esp
80108004:	6a 06                	push   $0x6
80108006:	50                   	push   %eax
80108007:	68 00 10 00 00       	push   $0x1000
8010800c:	6a 00                	push   $0x0
8010800e:	ff 75 08             	push   0x8(%ebp)
80108011:	e8 5d fc ff ff       	call   80107c73 <mappages>
80108016:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108019:	83 ec 04             	sub    $0x4,%esp
8010801c:	ff 75 10             	push   0x10(%ebp)
8010801f:	ff 75 0c             	push   0xc(%ebp)
80108022:	ff 75 f4             	push   -0xc(%ebp)
80108025:	e8 53 d3 ff ff       	call   8010537d <memmove>
8010802a:	83 c4 10             	add    $0x10,%esp
}
8010802d:	90                   	nop
8010802e:	c9                   	leave
8010802f:	c3                   	ret

80108030 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108030:	55                   	push   %ebp
80108031:	89 e5                	mov    %esp,%ebp
80108033:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108036:	8b 45 0c             	mov    0xc(%ebp),%eax
80108039:	25 ff 0f 00 00       	and    $0xfff,%eax
8010803e:	85 c0                	test   %eax,%eax
80108040:	74 0d                	je     8010804f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108042:	83 ec 0c             	sub    $0xc,%esp
80108045:	68 58 b1 10 80       	push   $0x8010b158
8010804a:	e8 5a 85 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010804f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108056:	e9 8f 00 00 00       	jmp    801080ea <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010805b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010805e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108061:	01 d0                	add    %edx,%eax
80108063:	83 ec 04             	sub    $0x4,%esp
80108066:	6a 00                	push   $0x0
80108068:	50                   	push   %eax
80108069:	ff 75 08             	push   0x8(%ebp)
8010806c:	e8 6c fb ff ff       	call   80107bdd <walkpgdir>
80108071:	83 c4 10             	add    $0x10,%esp
80108074:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108077:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010807b:	75 0d                	jne    8010808a <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010807d:	83 ec 0c             	sub    $0xc,%esp
80108080:	68 7b b1 10 80       	push   $0x8010b17b
80108085:	e8 1f 85 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010808a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808d:	8b 00                	mov    (%eax),%eax
8010808f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108094:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108097:	8b 45 18             	mov    0x18(%ebp),%eax
8010809a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010809d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080a2:	77 0b                	ja     801080af <loaduvm+0x7f>
      n = sz - i;
801080a4:	8b 45 18             	mov    0x18(%ebp),%eax
801080a7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080ad:	eb 07                	jmp    801080b6 <loaduvm+0x86>
    else
      n = PGSIZE;
801080af:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801080b6:	8b 55 14             	mov    0x14(%ebp),%edx
801080b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bc:	01 d0                	add    %edx,%eax
801080be:	8b 55 e8             	mov    -0x18(%ebp),%edx
801080c1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801080c7:	ff 75 f0             	push   -0x10(%ebp)
801080ca:	50                   	push   %eax
801080cb:	52                   	push   %edx
801080cc:	ff 75 10             	push   0x10(%ebp)
801080cf:	e8 0a 9e ff ff       	call   80101ede <readi>
801080d4:	83 c4 10             	add    $0x10,%esp
801080d7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801080da:	74 07                	je     801080e3 <loaduvm+0xb3>
      return -1;
801080dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080e1:	eb 18                	jmp    801080fb <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801080e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	3b 45 18             	cmp    0x18(%ebp),%eax
801080f0:	0f 82 65 ff ff ff    	jb     8010805b <loaduvm+0x2b>
  }
  return 0;
801080f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080fb:	c9                   	leave
801080fc:	c3                   	ret

801080fd <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080fd:	55                   	push   %ebp
801080fe:	89 e5                	mov    %esp,%ebp
80108100:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108103:	8b 45 10             	mov    0x10(%ebp),%eax
80108106:	85 c0                	test   %eax,%eax
80108108:	79 0a                	jns    80108114 <allocuvm+0x17>
    return 0;
8010810a:	b8 00 00 00 00       	mov    $0x0,%eax
8010810f:	e9 ec 00 00 00       	jmp    80108200 <allocuvm+0x103>
  if(newsz < oldsz)
80108114:	8b 45 10             	mov    0x10(%ebp),%eax
80108117:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010811a:	73 08                	jae    80108124 <allocuvm+0x27>
    return oldsz;
8010811c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811f:	e9 dc 00 00 00       	jmp    80108200 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108124:	8b 45 0c             	mov    0xc(%ebp),%eax
80108127:	05 ff 0f 00 00       	add    $0xfff,%eax
8010812c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108134:	e9 b8 00 00 00       	jmp    801081f1 <allocuvm+0xf4>
    mem = kalloc();
80108139:	e8 6a a6 ff ff       	call   801027a8 <kalloc>
8010813e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108141:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108145:	75 2e                	jne    80108175 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108147:	83 ec 0c             	sub    $0xc,%esp
8010814a:	68 99 b1 10 80       	push   $0x8010b199
8010814f:	e8 a0 82 ff ff       	call   801003f4 <cprintf>
80108154:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108157:	83 ec 04             	sub    $0x4,%esp
8010815a:	ff 75 0c             	push   0xc(%ebp)
8010815d:	ff 75 10             	push   0x10(%ebp)
80108160:	ff 75 08             	push   0x8(%ebp)
80108163:	e8 9a 00 00 00       	call   80108202 <deallocuvm>
80108168:	83 c4 10             	add    $0x10,%esp
      return 0;
8010816b:	b8 00 00 00 00       	mov    $0x0,%eax
80108170:	e9 8b 00 00 00       	jmp    80108200 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108175:	83 ec 04             	sub    $0x4,%esp
80108178:	68 00 10 00 00       	push   $0x1000
8010817d:	6a 00                	push   $0x0
8010817f:	ff 75 f0             	push   -0x10(%ebp)
80108182:	e8 37 d1 ff ff       	call   801052be <memset>
80108187:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010818a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108196:	83 ec 0c             	sub    $0xc,%esp
80108199:	6a 06                	push   $0x6
8010819b:	52                   	push   %edx
8010819c:	68 00 10 00 00       	push   $0x1000
801081a1:	50                   	push   %eax
801081a2:	ff 75 08             	push   0x8(%ebp)
801081a5:	e8 c9 fa ff ff       	call   80107c73 <mappages>
801081aa:	83 c4 20             	add    $0x20,%esp
801081ad:	85 c0                	test   %eax,%eax
801081af:	79 39                	jns    801081ea <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801081b1:	83 ec 0c             	sub    $0xc,%esp
801081b4:	68 b1 b1 10 80       	push   $0x8010b1b1
801081b9:	e8 36 82 ff ff       	call   801003f4 <cprintf>
801081be:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801081c1:	83 ec 04             	sub    $0x4,%esp
801081c4:	ff 75 0c             	push   0xc(%ebp)
801081c7:	ff 75 10             	push   0x10(%ebp)
801081ca:	ff 75 08             	push   0x8(%ebp)
801081cd:	e8 30 00 00 00       	call   80108202 <deallocuvm>
801081d2:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801081d5:	83 ec 0c             	sub    $0xc,%esp
801081d8:	ff 75 f0             	push   -0x10(%ebp)
801081db:	e8 2e a5 ff ff       	call   8010270e <kfree>
801081e0:	83 c4 10             	add    $0x10,%esp
      return 0;
801081e3:	b8 00 00 00 00       	mov    $0x0,%eax
801081e8:	eb 16                	jmp    80108200 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801081ea:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801081f7:	0f 82 3c ff ff ff    	jb     80108139 <allocuvm+0x3c>
    }
  }
  return newsz;
801081fd:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108200:	c9                   	leave
80108201:	c3                   	ret

80108202 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108202:	55                   	push   %ebp
80108203:	89 e5                	mov    %esp,%ebp
80108205:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108208:	8b 45 10             	mov    0x10(%ebp),%eax
8010820b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010820e:	72 08                	jb     80108218 <deallocuvm+0x16>
    return oldsz;
80108210:	8b 45 0c             	mov    0xc(%ebp),%eax
80108213:	e9 ac 00 00 00       	jmp    801082c4 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108218:	8b 45 10             	mov    0x10(%ebp),%eax
8010821b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108220:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108225:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108228:	e9 88 00 00 00       	jmp    801082b5 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010822d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108230:	83 ec 04             	sub    $0x4,%esp
80108233:	6a 00                	push   $0x0
80108235:	50                   	push   %eax
80108236:	ff 75 08             	push   0x8(%ebp)
80108239:	e8 9f f9 ff ff       	call   80107bdd <walkpgdir>
8010823e:	83 c4 10             	add    $0x10,%esp
80108241:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108244:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108248:	75 16                	jne    80108260 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	c1 e8 16             	shr    $0x16,%eax
80108250:	83 c0 01             	add    $0x1,%eax
80108253:	c1 e0 16             	shl    $0x16,%eax
80108256:	2d 00 10 00 00       	sub    $0x1000,%eax
8010825b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010825e:	eb 4e                	jmp    801082ae <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108260:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108263:	8b 00                	mov    (%eax),%eax
80108265:	83 e0 01             	and    $0x1,%eax
80108268:	85 c0                	test   %eax,%eax
8010826a:	74 42                	je     801082ae <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010826c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826f:	8b 00                	mov    (%eax),%eax
80108271:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108276:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108279:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010827d:	75 0d                	jne    8010828c <deallocuvm+0x8a>
        panic("kfree");
8010827f:	83 ec 0c             	sub    $0xc,%esp
80108282:	68 cd b1 10 80       	push   $0x8010b1cd
80108287:	e8 1d 83 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010828c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010828f:	05 00 00 00 80       	add    $0x80000000,%eax
80108294:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108297:	83 ec 0c             	sub    $0xc,%esp
8010829a:	ff 75 e8             	push   -0x18(%ebp)
8010829d:	e8 6c a4 ff ff       	call   8010270e <kfree>
801082a2:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801082a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801082ae:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082bb:	0f 82 6c ff ff ff    	jb     8010822d <deallocuvm+0x2b>
    }
  }
  return newsz;
801082c1:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082c4:	c9                   	leave
801082c5:	c3                   	ret

801082c6 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082c6:	55                   	push   %ebp
801082c7:	89 e5                	mov    %esp,%ebp
801082c9:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801082cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082d0:	75 0d                	jne    801082df <freevm+0x19>
    panic("freevm: no pgdir");
801082d2:	83 ec 0c             	sub    $0xc,%esp
801082d5:	68 d3 b1 10 80       	push   $0x8010b1d3
801082da:	e8 ca 82 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082df:	83 ec 04             	sub    $0x4,%esp
801082e2:	6a 00                	push   $0x0
801082e4:	68 00 00 00 80       	push   $0x80000000
801082e9:	ff 75 08             	push   0x8(%ebp)
801082ec:	e8 11 ff ff ff       	call   80108202 <deallocuvm>
801082f1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082fb:	eb 48                	jmp    80108345 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108300:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108307:	8b 45 08             	mov    0x8(%ebp),%eax
8010830a:	01 d0                	add    %edx,%eax
8010830c:	8b 00                	mov    (%eax),%eax
8010830e:	83 e0 01             	and    $0x1,%eax
80108311:	85 c0                	test   %eax,%eax
80108313:	74 2c                	je     80108341 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108318:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010831f:	8b 45 08             	mov    0x8(%ebp),%eax
80108322:	01 d0                	add    %edx,%eax
80108324:	8b 00                	mov    (%eax),%eax
80108326:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010832b:	05 00 00 00 80       	add    $0x80000000,%eax
80108330:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108333:	83 ec 0c             	sub    $0xc,%esp
80108336:	ff 75 f0             	push   -0x10(%ebp)
80108339:	e8 d0 a3 ff ff       	call   8010270e <kfree>
8010833e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108341:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108345:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010834c:	76 af                	jbe    801082fd <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010834e:	83 ec 0c             	sub    $0xc,%esp
80108351:	ff 75 08             	push   0x8(%ebp)
80108354:	e8 b5 a3 ff ff       	call   8010270e <kfree>
80108359:	83 c4 10             	add    $0x10,%esp
}
8010835c:	90                   	nop
8010835d:	c9                   	leave
8010835e:	c3                   	ret

8010835f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010835f:	55                   	push   %ebp
80108360:	89 e5                	mov    %esp,%ebp
80108362:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108365:	83 ec 04             	sub    $0x4,%esp
80108368:	6a 00                	push   $0x0
8010836a:	ff 75 0c             	push   0xc(%ebp)
8010836d:	ff 75 08             	push   0x8(%ebp)
80108370:	e8 68 f8 ff ff       	call   80107bdd <walkpgdir>
80108375:	83 c4 10             	add    $0x10,%esp
80108378:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010837b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010837f:	75 0d                	jne    8010838e <clearpteu+0x2f>
    panic("clearpteu");
80108381:	83 ec 0c             	sub    $0xc,%esp
80108384:	68 e4 b1 10 80       	push   $0x8010b1e4
80108389:	e8 1b 82 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010838e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108391:	8b 00                	mov    (%eax),%eax
80108393:	83 e0 fb             	and    $0xfffffffb,%eax
80108396:	89 c2                	mov    %eax,%edx
80108398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839b:	89 10                	mov    %edx,(%eax)
}
8010839d:	90                   	nop
8010839e:	c9                   	leave
8010839f:	c3                   	ret

801083a0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
801083a3:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801083a6:	e8 58 f9 ff ff       	call   80107d03 <setupkvm>
801083ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083b2:	75 0a                	jne    801083be <copyuvm+0x1e>
    return 0;
801083b4:	b8 00 00 00 00       	mov    $0x0,%eax
801083b9:	e9 eb 00 00 00       	jmp    801084a9 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801083be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c5:	e9 b7 00 00 00       	jmp    80108481 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	83 ec 04             	sub    $0x4,%esp
801083d0:	6a 00                	push   $0x0
801083d2:	50                   	push   %eax
801083d3:	ff 75 08             	push   0x8(%ebp)
801083d6:	e8 02 f8 ff ff       	call   80107bdd <walkpgdir>
801083db:	83 c4 10             	add    $0x10,%esp
801083de:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083e5:	75 0d                	jne    801083f4 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801083e7:	83 ec 0c             	sub    $0xc,%esp
801083ea:	68 ee b1 10 80       	push   $0x8010b1ee
801083ef:	e8 b5 81 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801083f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f7:	8b 00                	mov    (%eax),%eax
801083f9:	83 e0 01             	and    $0x1,%eax
801083fc:	85 c0                	test   %eax,%eax
801083fe:	75 0d                	jne    8010840d <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108400:	83 ec 0c             	sub    $0xc,%esp
80108403:	68 08 b2 10 80       	push   $0x8010b208
80108408:	e8 9c 81 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010840d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108410:	8b 00                	mov    (%eax),%eax
80108412:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108417:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010841a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841d:	8b 00                	mov    (%eax),%eax
8010841f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108427:	e8 7c a3 ff ff       	call   801027a8 <kalloc>
8010842c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010842f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108433:	74 5d                	je     80108492 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108435:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108438:	05 00 00 00 80       	add    $0x80000000,%eax
8010843d:	83 ec 04             	sub    $0x4,%esp
80108440:	68 00 10 00 00       	push   $0x1000
80108445:	50                   	push   %eax
80108446:	ff 75 e0             	push   -0x20(%ebp)
80108449:	e8 2f cf ff ff       	call   8010537d <memmove>
8010844e:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108451:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108454:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108457:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010845d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	52                   	push   %edx
80108464:	51                   	push   %ecx
80108465:	68 00 10 00 00       	push   $0x1000
8010846a:	50                   	push   %eax
8010846b:	ff 75 f0             	push   -0x10(%ebp)
8010846e:	e8 00 f8 ff ff       	call   80107c73 <mappages>
80108473:	83 c4 20             	add    $0x20,%esp
80108476:	85 c0                	test   %eax,%eax
80108478:	78 1b                	js     80108495 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
8010847a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108484:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108487:	0f 82 3d ff ff ff    	jb     801083ca <copyuvm+0x2a>
      goto bad;
  }
  return d;
8010848d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108490:	eb 17                	jmp    801084a9 <copyuvm+0x109>
      goto bad;
80108492:	90                   	nop
80108493:	eb 01                	jmp    80108496 <copyuvm+0xf6>
      goto bad;
80108495:	90                   	nop

bad:
  freevm(d);
80108496:	83 ec 0c             	sub    $0xc,%esp
80108499:	ff 75 f0             	push   -0x10(%ebp)
8010849c:	e8 25 fe ff ff       	call   801082c6 <freevm>
801084a1:	83 c4 10             	add    $0x10,%esp
  return 0;
801084a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084a9:	c9                   	leave
801084aa:	c3                   	ret

801084ab <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084ab:	55                   	push   %ebp
801084ac:	89 e5                	mov    %esp,%ebp
801084ae:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084b1:	83 ec 04             	sub    $0x4,%esp
801084b4:	6a 00                	push   $0x0
801084b6:	ff 75 0c             	push   0xc(%ebp)
801084b9:	ff 75 08             	push   0x8(%ebp)
801084bc:	e8 1c f7 ff ff       	call   80107bdd <walkpgdir>
801084c1:	83 c4 10             	add    $0x10,%esp
801084c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ca:	8b 00                	mov    (%eax),%eax
801084cc:	83 e0 01             	and    $0x1,%eax
801084cf:	85 c0                	test   %eax,%eax
801084d1:	75 07                	jne    801084da <uva2ka+0x2f>
    return 0;
801084d3:	b8 00 00 00 00       	mov    $0x0,%eax
801084d8:	eb 22                	jmp    801084fc <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dd:	8b 00                	mov    (%eax),%eax
801084df:	83 e0 04             	and    $0x4,%eax
801084e2:	85 c0                	test   %eax,%eax
801084e4:	75 07                	jne    801084ed <uva2ka+0x42>
    return 0;
801084e6:	b8 00 00 00 00       	mov    $0x0,%eax
801084eb:	eb 0f                	jmp    801084fc <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801084ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f0:	8b 00                	mov    (%eax),%eax
801084f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084f7:	05 00 00 00 80       	add    $0x80000000,%eax
}
801084fc:	c9                   	leave
801084fd:	c3                   	ret

801084fe <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801084fe:	55                   	push   %ebp
801084ff:	89 e5                	mov    %esp,%ebp
80108501:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108504:	8b 45 10             	mov    0x10(%ebp),%eax
80108507:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010850a:	eb 7f                	jmp    8010858b <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010850c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010850f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108514:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010851a:	83 ec 08             	sub    $0x8,%esp
8010851d:	50                   	push   %eax
8010851e:	ff 75 08             	push   0x8(%ebp)
80108521:	e8 85 ff ff ff       	call   801084ab <uva2ka>
80108526:	83 c4 10             	add    $0x10,%esp
80108529:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010852c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108530:	75 07                	jne    80108539 <copyout+0x3b>
      return -1;
80108532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108537:	eb 61                	jmp    8010859a <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108539:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853c:	2b 45 0c             	sub    0xc(%ebp),%eax
8010853f:	05 00 10 00 00       	add    $0x1000,%eax
80108544:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854a:	39 45 14             	cmp    %eax,0x14(%ebp)
8010854d:	73 06                	jae    80108555 <copyout+0x57>
      n = len;
8010854f:	8b 45 14             	mov    0x14(%ebp),%eax
80108552:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108555:	8b 45 0c             	mov    0xc(%ebp),%eax
80108558:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010855b:	89 c2                	mov    %eax,%edx
8010855d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108560:	01 d0                	add    %edx,%eax
80108562:	83 ec 04             	sub    $0x4,%esp
80108565:	ff 75 f0             	push   -0x10(%ebp)
80108568:	ff 75 f4             	push   -0xc(%ebp)
8010856b:	50                   	push   %eax
8010856c:	e8 0c ce ff ff       	call   8010537d <memmove>
80108571:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108577:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010857a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108580:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108583:	05 00 10 00 00       	add    $0x1000,%eax
80108588:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010858b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010858f:	0f 85 77 ff ff ff    	jne    8010850c <copyout+0xe>
  }
  return 0;
80108595:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010859a:	c9                   	leave
8010859b:	c3                   	ret

8010859c <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010859c:	55                   	push   %ebp
8010859d:	89 e5                	mov    %esp,%ebp
8010859f:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801085a2:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801085a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085ac:	8b 40 08             	mov    0x8(%eax),%eax
801085af:	05 00 00 00 80       	add    $0x80000000,%eax
801085b4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801085b7:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801085be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c1:	8b 40 24             	mov    0x24(%eax),%eax
801085c4:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801085c9:	c7 05 74 7a 19 80 00 	movl   $0x0,0x80197a74
801085d0:	00 00 00 

  while(i<madt->len){
801085d3:	e9 bc 00 00 00       	jmp    80108694 <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
801085d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085de:	01 d0                	add    %edx,%eax
801085e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801085e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e6:	0f b6 00             	movzbl (%eax),%eax
801085e9:	0f b6 c0             	movzbl %al,%eax
801085ec:	83 f8 05             	cmp    $0x5,%eax
801085ef:	0f 87 9f 00 00 00    	ja     80108694 <mpinit_uefi+0xf8>
801085f5:	8b 04 85 24 b2 10 80 	mov    -0x7fef4ddc(,%eax,4),%eax
801085fc:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801085fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108601:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108604:	a1 74 7a 19 80       	mov    0x80197a74,%eax
80108609:	85 c0                	test   %eax,%eax
8010860b:	7f 28                	jg     80108635 <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010860d:	8b 15 74 7a 19 80    	mov    0x80197a74,%edx
80108613:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108616:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010861a:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108620:	81 c2 c0 79 19 80    	add    $0x801979c0,%edx
80108626:	88 02                	mov    %al,(%edx)
          ncpu++;
80108628:	a1 74 7a 19 80       	mov    0x80197a74,%eax
8010862d:	83 c0 01             	add    $0x1,%eax
80108630:	a3 74 7a 19 80       	mov    %eax,0x80197a74
        }
        i += lapic_entry->record_len;
80108635:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108638:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010863c:	0f b6 c0             	movzbl %al,%eax
8010863f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108642:	eb 50                	jmp    80108694 <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010864a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010864d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108651:	a2 78 7a 19 80       	mov    %al,0x80197a78
        i += ioapic->record_len;
80108656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108659:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010865d:	0f b6 c0             	movzbl %al,%eax
80108660:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108663:	eb 2f                	jmp    80108694 <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108668:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010866b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010866e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108672:	0f b6 c0             	movzbl %al,%eax
80108675:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108678:	eb 1a                	jmp    80108694 <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010867a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108680:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108683:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108687:	0f b6 c0             	movzbl %al,%eax
8010868a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010868d:	eb 05                	jmp    80108694 <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
8010868f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108693:	90                   	nop
  while(i<madt->len){
80108694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108697:	8b 40 04             	mov    0x4(%eax),%eax
8010869a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010869d:	0f 82 35 ff ff ff    	jb     801085d8 <mpinit_uefi+0x3c>
    }
  }

}
801086a3:	90                   	nop
801086a4:	90                   	nop
801086a5:	c9                   	leave
801086a6:	c3                   	ret

801086a7 <inb>:
{
801086a7:	55                   	push   %ebp
801086a8:	89 e5                	mov    %esp,%ebp
801086aa:	83 ec 14             	sub    $0x14,%esp
801086ad:	8b 45 08             	mov    0x8(%ebp),%eax
801086b0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801086b4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801086b8:	89 c2                	mov    %eax,%edx
801086ba:	ec                   	in     (%dx),%al
801086bb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801086be:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801086c2:	c9                   	leave
801086c3:	c3                   	ret

801086c4 <outb>:
{
801086c4:	55                   	push   %ebp
801086c5:	89 e5                	mov    %esp,%ebp
801086c7:	83 ec 08             	sub    $0x8,%esp
801086ca:	8b 55 08             	mov    0x8(%ebp),%edx
801086cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801086d4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801086d7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801086db:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801086df:	ee                   	out    %al,(%dx)
}
801086e0:	90                   	nop
801086e1:	c9                   	leave
801086e2:	c3                   	ret

801086e3 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801086e3:	55                   	push   %ebp
801086e4:	89 e5                	mov    %esp,%ebp
801086e6:	83 ec 28             	sub    $0x28,%esp
801086e9:	8b 45 08             	mov    0x8(%ebp),%eax
801086ec:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801086ef:	6a 00                	push   $0x0
801086f1:	68 fa 03 00 00       	push   $0x3fa
801086f6:	e8 c9 ff ff ff       	call   801086c4 <outb>
801086fb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801086fe:	68 80 00 00 00       	push   $0x80
80108703:	68 fb 03 00 00       	push   $0x3fb
80108708:	e8 b7 ff ff ff       	call   801086c4 <outb>
8010870d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108710:	6a 0c                	push   $0xc
80108712:	68 f8 03 00 00       	push   $0x3f8
80108717:	e8 a8 ff ff ff       	call   801086c4 <outb>
8010871c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010871f:	6a 00                	push   $0x0
80108721:	68 f9 03 00 00       	push   $0x3f9
80108726:	e8 99 ff ff ff       	call   801086c4 <outb>
8010872b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010872e:	6a 03                	push   $0x3
80108730:	68 fb 03 00 00       	push   $0x3fb
80108735:	e8 8a ff ff ff       	call   801086c4 <outb>
8010873a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010873d:	6a 00                	push   $0x0
8010873f:	68 fc 03 00 00       	push   $0x3fc
80108744:	e8 7b ff ff ff       	call   801086c4 <outb>
80108749:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010874c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108753:	eb 11                	jmp    80108766 <uart_debug+0x83>
80108755:	83 ec 0c             	sub    $0xc,%esp
80108758:	6a 0a                	push   $0xa
8010875a:	e8 da a3 ff ff       	call   80102b39 <microdelay>
8010875f:	83 c4 10             	add    $0x10,%esp
80108762:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108766:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010876a:	7f 1a                	jg     80108786 <uart_debug+0xa3>
8010876c:	83 ec 0c             	sub    $0xc,%esp
8010876f:	68 fd 03 00 00       	push   $0x3fd
80108774:	e8 2e ff ff ff       	call   801086a7 <inb>
80108779:	83 c4 10             	add    $0x10,%esp
8010877c:	0f b6 c0             	movzbl %al,%eax
8010877f:	83 e0 20             	and    $0x20,%eax
80108782:	85 c0                	test   %eax,%eax
80108784:	74 cf                	je     80108755 <uart_debug+0x72>
  outb(COM1+0, p);
80108786:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010878a:	0f b6 c0             	movzbl %al,%eax
8010878d:	83 ec 08             	sub    $0x8,%esp
80108790:	50                   	push   %eax
80108791:	68 f8 03 00 00       	push   $0x3f8
80108796:	e8 29 ff ff ff       	call   801086c4 <outb>
8010879b:	83 c4 10             	add    $0x10,%esp
}
8010879e:	90                   	nop
8010879f:	c9                   	leave
801087a0:	c3                   	ret

801087a1 <uart_debugs>:

void uart_debugs(char *p){
801087a1:	55                   	push   %ebp
801087a2:	89 e5                	mov    %esp,%ebp
801087a4:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801087a7:	eb 1b                	jmp    801087c4 <uart_debugs+0x23>
    uart_debug(*p++);
801087a9:	8b 45 08             	mov    0x8(%ebp),%eax
801087ac:	8d 50 01             	lea    0x1(%eax),%edx
801087af:	89 55 08             	mov    %edx,0x8(%ebp)
801087b2:	0f b6 00             	movzbl (%eax),%eax
801087b5:	0f be c0             	movsbl %al,%eax
801087b8:	83 ec 0c             	sub    $0xc,%esp
801087bb:	50                   	push   %eax
801087bc:	e8 22 ff ff ff       	call   801086e3 <uart_debug>
801087c1:	83 c4 10             	add    $0x10,%esp
  while(*p){
801087c4:	8b 45 08             	mov    0x8(%ebp),%eax
801087c7:	0f b6 00             	movzbl (%eax),%eax
801087ca:	84 c0                	test   %al,%al
801087cc:	75 db                	jne    801087a9 <uart_debugs+0x8>
  }
}
801087ce:	90                   	nop
801087cf:	90                   	nop
801087d0:	c9                   	leave
801087d1:	c3                   	ret

801087d2 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801087d2:	55                   	push   %ebp
801087d3:	89 e5                	mov    %esp,%ebp
801087d5:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801087d8:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801087df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087e2:	8b 50 14             	mov    0x14(%eax),%edx
801087e5:	8b 40 10             	mov    0x10(%eax),%eax
801087e8:	a3 7c 7a 19 80       	mov    %eax,0x80197a7c
  gpu.vram_size = boot_param->graphic_config.frame_size;
801087ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087f0:	8b 50 1c             	mov    0x1c(%eax),%edx
801087f3:	8b 40 18             	mov    0x18(%eax),%eax
801087f6:	a3 84 7a 19 80       	mov    %eax,0x80197a84
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801087fb:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80108800:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108805:	29 c2                	sub    %eax,%edx
80108807:	89 15 80 7a 19 80    	mov    %edx,0x80197a80
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010880d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108810:	8b 50 24             	mov    0x24(%eax),%edx
80108813:	8b 40 20             	mov    0x20(%eax),%eax
80108816:	a3 88 7a 19 80       	mov    %eax,0x80197a88
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010881b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010881e:	8b 50 2c             	mov    0x2c(%eax),%edx
80108821:	8b 40 28             	mov    0x28(%eax),%eax
80108824:	a3 8c 7a 19 80       	mov    %eax,0x80197a8c
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108829:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010882c:	8b 50 34             	mov    0x34(%eax),%edx
8010882f:	8b 40 30             	mov    0x30(%eax),%eax
80108832:	a3 90 7a 19 80       	mov    %eax,0x80197a90
}
80108837:	90                   	nop
80108838:	c9                   	leave
80108839:	c3                   	ret

8010883a <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010883a:	55                   	push   %ebp
8010883b:	89 e5                	mov    %esp,%ebp
8010883d:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108840:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
80108846:	8b 45 0c             	mov    0xc(%ebp),%eax
80108849:	0f af d0             	imul   %eax,%edx
8010884c:	8b 45 08             	mov    0x8(%ebp),%eax
8010884f:	01 d0                	add    %edx,%eax
80108851:	c1 e0 02             	shl    $0x2,%eax
80108854:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108857:	8b 15 80 7a 19 80    	mov    0x80197a80,%edx
8010885d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108860:	01 d0                	add    %edx,%eax
80108862:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108865:	8b 45 10             	mov    0x10(%ebp),%eax
80108868:	0f b6 10             	movzbl (%eax),%edx
8010886b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010886e:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108870:	8b 45 10             	mov    0x10(%ebp),%eax
80108873:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108877:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010887a:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010887d:	8b 45 10             	mov    0x10(%ebp),%eax
80108880:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108884:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108887:	88 50 02             	mov    %dl,0x2(%eax)
}
8010888a:	90                   	nop
8010888b:	c9                   	leave
8010888c:	c3                   	ret

8010888d <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010888d:	55                   	push   %ebp
8010888e:	89 e5                	mov    %esp,%ebp
80108890:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108893:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
80108899:	8b 45 08             	mov    0x8(%ebp),%eax
8010889c:	0f af c2             	imul   %edx,%eax
8010889f:	c1 e0 02             	shl    $0x2,%eax
801088a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801088a5:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	29 c2                	sub    %eax,%edx
801088b0:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	01 c8                	add    %ecx,%eax
801088bb:	89 c1                	mov    %eax,%ecx
801088bd:	a1 80 7a 19 80       	mov    0x80197a80,%eax
801088c2:	83 ec 04             	sub    $0x4,%esp
801088c5:	52                   	push   %edx
801088c6:	51                   	push   %ecx
801088c7:	50                   	push   %eax
801088c8:	e8 b0 ca ff ff       	call   8010537d <memmove>
801088cd:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801088d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d3:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
801088d9:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
801088df:	01 d1                	add    %edx,%ecx
801088e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088e4:	29 d1                	sub    %edx,%ecx
801088e6:	89 ca                	mov    %ecx,%edx
801088e8:	83 ec 04             	sub    $0x4,%esp
801088eb:	50                   	push   %eax
801088ec:	6a 00                	push   $0x0
801088ee:	52                   	push   %edx
801088ef:	e8 ca c9 ff ff       	call   801052be <memset>
801088f4:	83 c4 10             	add    $0x10,%esp
}
801088f7:	90                   	nop
801088f8:	c9                   	leave
801088f9:	c3                   	ret

801088fa <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801088fa:	55                   	push   %ebp
801088fb:	89 e5                	mov    %esp,%ebp
801088fd:	53                   	push   %ebx
801088fe:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108901:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108908:	e9 b1 00 00 00       	jmp    801089be <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010890d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108914:	e9 97 00 00 00       	jmp    801089b0 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108919:	8b 45 10             	mov    0x10(%ebp),%eax
8010891c:	83 e8 20             	sub    $0x20,%eax
8010891f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108925:	01 d0                	add    %edx,%eax
80108927:	0f b7 84 00 40 b2 10 	movzwl -0x7fef4dc0(%eax,%eax,1),%eax
8010892e:	80 
8010892f:	0f b7 d0             	movzwl %ax,%edx
80108932:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108935:	bb 01 00 00 00       	mov    $0x1,%ebx
8010893a:	89 c1                	mov    %eax,%ecx
8010893c:	d3 e3                	shl    %cl,%ebx
8010893e:	89 d8                	mov    %ebx,%eax
80108940:	21 d0                	and    %edx,%eax
80108942:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108948:	ba 01 00 00 00       	mov    $0x1,%edx
8010894d:	89 c1                	mov    %eax,%ecx
8010894f:	d3 e2                	shl    %cl,%edx
80108951:	89 d0                	mov    %edx,%eax
80108953:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108956:	75 2b                	jne    80108983 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108958:	8b 55 0c             	mov    0xc(%ebp),%edx
8010895b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895e:	01 c2                	add    %eax,%edx
80108960:	b8 0e 00 00 00       	mov    $0xe,%eax
80108965:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108968:	89 c1                	mov    %eax,%ecx
8010896a:	8b 45 08             	mov    0x8(%ebp),%eax
8010896d:	01 c8                	add    %ecx,%eax
8010896f:	83 ec 04             	sub    $0x4,%esp
80108972:	68 00 f5 10 80       	push   $0x8010f500
80108977:	52                   	push   %edx
80108978:	50                   	push   %eax
80108979:	e8 bc fe ff ff       	call   8010883a <graphic_draw_pixel>
8010897e:	83 c4 10             	add    $0x10,%esp
80108981:	eb 29                	jmp    801089ac <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108983:	8b 55 0c             	mov    0xc(%ebp),%edx
80108986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108989:	01 c2                	add    %eax,%edx
8010898b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108990:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108993:	89 c1                	mov    %eax,%ecx
80108995:	8b 45 08             	mov    0x8(%ebp),%eax
80108998:	01 c8                	add    %ecx,%eax
8010899a:	83 ec 04             	sub    $0x4,%esp
8010899d:	68 94 7a 19 80       	push   $0x80197a94
801089a2:	52                   	push   %edx
801089a3:	50                   	push   %eax
801089a4:	e8 91 fe ff ff       	call   8010883a <graphic_draw_pixel>
801089a9:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801089ac:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801089b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089b4:	0f 89 5f ff ff ff    	jns    80108919 <font_render+0x1f>
  for(int i=0;i<30;i++){
801089ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089be:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801089c2:	0f 8e 45 ff ff ff    	jle    8010890d <font_render+0x13>
      }
    }
  }
}
801089c8:	90                   	nop
801089c9:	90                   	nop
801089ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089cd:	c9                   	leave
801089ce:	c3                   	ret

801089cf <font_render_string>:

void font_render_string(char *string,int row){
801089cf:	55                   	push   %ebp
801089d0:	89 e5                	mov    %esp,%ebp
801089d2:	53                   	push   %ebx
801089d3:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801089d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801089dd:	eb 33                	jmp    80108a12 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801089df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089e2:	8b 45 08             	mov    0x8(%ebp),%eax
801089e5:	01 d0                	add    %edx,%eax
801089e7:	0f b6 00             	movzbl (%eax),%eax
801089ea:	0f be d8             	movsbl %al,%ebx
801089ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801089f0:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801089f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089f6:	89 d0                	mov    %edx,%eax
801089f8:	c1 e0 04             	shl    $0x4,%eax
801089fb:	29 d0                	sub    %edx,%eax
801089fd:	83 c0 02             	add    $0x2,%eax
80108a00:	83 ec 04             	sub    $0x4,%esp
80108a03:	53                   	push   %ebx
80108a04:	51                   	push   %ecx
80108a05:	50                   	push   %eax
80108a06:	e8 ef fe ff ff       	call   801088fa <font_render>
80108a0b:	83 c4 10             	add    $0x10,%esp
    i++;
80108a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108a12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a15:	8b 45 08             	mov    0x8(%ebp),%eax
80108a18:	01 d0                	add    %edx,%eax
80108a1a:	0f b6 00             	movzbl (%eax),%eax
80108a1d:	84 c0                	test   %al,%al
80108a1f:	74 06                	je     80108a27 <font_render_string+0x58>
80108a21:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108a25:	7e b8                	jle    801089df <font_render_string+0x10>
  }
}
80108a27:	90                   	nop
80108a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a2b:	c9                   	leave
80108a2c:	c3                   	ret

80108a2d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108a2d:	55                   	push   %ebp
80108a2e:	89 e5                	mov    %esp,%ebp
80108a30:	53                   	push   %ebx
80108a31:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108a34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a3b:	eb 6b                	jmp    80108aa8 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108a3d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a44:	eb 58                	jmp    80108a9e <pci_init+0x71>
      for(int k=0;k<8;k++){
80108a46:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108a4d:	eb 45                	jmp    80108a94 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108a4f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108a52:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a58:	83 ec 0c             	sub    $0xc,%esp
80108a5b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108a5e:	53                   	push   %ebx
80108a5f:	6a 00                	push   $0x0
80108a61:	51                   	push   %ecx
80108a62:	52                   	push   %edx
80108a63:	50                   	push   %eax
80108a64:	e8 b0 00 00 00       	call   80108b19 <pci_access_config>
80108a69:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108a6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a6f:	0f b7 c0             	movzwl %ax,%eax
80108a72:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108a77:	74 17                	je     80108a90 <pci_init+0x63>
        pci_init_device(i,j,k);
80108a79:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108a7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a82:	83 ec 04             	sub    $0x4,%esp
80108a85:	51                   	push   %ecx
80108a86:	52                   	push   %edx
80108a87:	50                   	push   %eax
80108a88:	e8 37 01 00 00       	call   80108bc4 <pci_init_device>
80108a8d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108a90:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108a94:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108a98:	7e b5                	jle    80108a4f <pci_init+0x22>
    for(int j=0;j<32;j++){
80108a9a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a9e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108aa2:	7e a2                	jle    80108a46 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108aa4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108aa8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108aaf:	7e 8c                	jle    80108a3d <pci_init+0x10>
      }
      }
    }
  }
}
80108ab1:	90                   	nop
80108ab2:	90                   	nop
80108ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ab6:	c9                   	leave
80108ab7:	c3                   	ret

80108ab8 <pci_write_config>:

void pci_write_config(uint config){
80108ab8:	55                   	push   %ebp
80108ab9:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108abb:	8b 45 08             	mov    0x8(%ebp),%eax
80108abe:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108ac3:	89 c0                	mov    %eax,%eax
80108ac5:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108ac6:	90                   	nop
80108ac7:	5d                   	pop    %ebp
80108ac8:	c3                   	ret

80108ac9 <pci_write_data>:

void pci_write_data(uint config){
80108ac9:	55                   	push   %ebp
80108aca:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108acc:	8b 45 08             	mov    0x8(%ebp),%eax
80108acf:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108ad4:	89 c0                	mov    %eax,%eax
80108ad6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108ad7:	90                   	nop
80108ad8:	5d                   	pop    %ebp
80108ad9:	c3                   	ret

80108ada <pci_read_config>:
uint pci_read_config(){
80108ada:	55                   	push   %ebp
80108adb:	89 e5                	mov    %esp,%ebp
80108add:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108ae0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108ae5:	ed                   	in     (%dx),%eax
80108ae6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108ae9:	83 ec 0c             	sub    $0xc,%esp
80108aec:	68 c8 00 00 00       	push   $0xc8
80108af1:	e8 43 a0 ff ff       	call   80102b39 <microdelay>
80108af6:	83 c4 10             	add    $0x10,%esp
  return data;
80108af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108afc:	c9                   	leave
80108afd:	c3                   	ret

80108afe <pci_test>:


void pci_test(){
80108afe:	55                   	push   %ebp
80108aff:	89 e5                	mov    %esp,%ebp
80108b01:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108b04:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108b0b:	ff 75 fc             	push   -0x4(%ebp)
80108b0e:	e8 a5 ff ff ff       	call   80108ab8 <pci_write_config>
80108b13:	83 c4 04             	add    $0x4,%esp
}
80108b16:	90                   	nop
80108b17:	c9                   	leave
80108b18:	c3                   	ret

80108b19 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108b19:	55                   	push   %ebp
80108b1a:	89 e5                	mov    %esp,%ebp
80108b1c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108b22:	c1 e0 10             	shl    $0x10,%eax
80108b25:	25 00 00 ff 00       	and    $0xff0000,%eax
80108b2a:	89 c2                	mov    %eax,%edx
80108b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b2f:	c1 e0 0b             	shl    $0xb,%eax
80108b32:	0f b7 c0             	movzwl %ax,%eax
80108b35:	09 c2                	or     %eax,%edx
80108b37:	8b 45 10             	mov    0x10(%ebp),%eax
80108b3a:	c1 e0 08             	shl    $0x8,%eax
80108b3d:	25 00 07 00 00       	and    $0x700,%eax
80108b42:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108b44:	8b 45 14             	mov    0x14(%ebp),%eax
80108b47:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b4c:	09 d0                	or     %edx,%eax
80108b4e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108b56:	ff 75 f4             	push   -0xc(%ebp)
80108b59:	e8 5a ff ff ff       	call   80108ab8 <pci_write_config>
80108b5e:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108b61:	e8 74 ff ff ff       	call   80108ada <pci_read_config>
80108b66:	8b 55 18             	mov    0x18(%ebp),%edx
80108b69:	89 02                	mov    %eax,(%edx)
}
80108b6b:	90                   	nop
80108b6c:	c9                   	leave
80108b6d:	c3                   	ret

80108b6e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108b6e:	55                   	push   %ebp
80108b6f:	89 e5                	mov    %esp,%ebp
80108b71:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108b74:	8b 45 08             	mov    0x8(%ebp),%eax
80108b77:	c1 e0 10             	shl    $0x10,%eax
80108b7a:	25 00 00 ff 00       	and    $0xff0000,%eax
80108b7f:	89 c2                	mov    %eax,%edx
80108b81:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b84:	c1 e0 0b             	shl    $0xb,%eax
80108b87:	0f b7 c0             	movzwl %ax,%eax
80108b8a:	09 c2                	or     %eax,%edx
80108b8c:	8b 45 10             	mov    0x10(%ebp),%eax
80108b8f:	c1 e0 08             	shl    $0x8,%eax
80108b92:	25 00 07 00 00       	and    $0x700,%eax
80108b97:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108b99:	8b 45 14             	mov    0x14(%ebp),%eax
80108b9c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ba1:	09 d0                	or     %edx,%eax
80108ba3:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ba8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108bab:	ff 75 fc             	push   -0x4(%ebp)
80108bae:	e8 05 ff ff ff       	call   80108ab8 <pci_write_config>
80108bb3:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108bb6:	ff 75 18             	push   0x18(%ebp)
80108bb9:	e8 0b ff ff ff       	call   80108ac9 <pci_write_data>
80108bbe:	83 c4 04             	add    $0x4,%esp
}
80108bc1:	90                   	nop
80108bc2:	c9                   	leave
80108bc3:	c3                   	ret

80108bc4 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108bc4:	55                   	push   %ebp
80108bc5:	89 e5                	mov    %esp,%ebp
80108bc7:	53                   	push   %ebx
80108bc8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80108bce:	a2 98 7a 19 80       	mov    %al,0x80197a98
  dev.device_num = device_num;
80108bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bd6:	a2 99 7a 19 80       	mov    %al,0x80197a99
  dev.function_num = function_num;
80108bdb:	8b 45 10             	mov    0x10(%ebp),%eax
80108bde:	a2 9a 7a 19 80       	mov    %al,0x80197a9a
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108be3:	ff 75 10             	push   0x10(%ebp)
80108be6:	ff 75 0c             	push   0xc(%ebp)
80108be9:	ff 75 08             	push   0x8(%ebp)
80108bec:	68 84 c8 10 80       	push   $0x8010c884
80108bf1:	e8 fe 77 ff ff       	call   801003f4 <cprintf>
80108bf6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108bf9:	83 ec 0c             	sub    $0xc,%esp
80108bfc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bff:	50                   	push   %eax
80108c00:	6a 00                	push   $0x0
80108c02:	ff 75 10             	push   0x10(%ebp)
80108c05:	ff 75 0c             	push   0xc(%ebp)
80108c08:	ff 75 08             	push   0x8(%ebp)
80108c0b:	e8 09 ff ff ff       	call   80108b19 <pci_access_config>
80108c10:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c16:	c1 e8 10             	shr    $0x10,%eax
80108c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c1f:	25 ff ff 00 00       	and    $0xffff,%eax
80108c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2a:	a3 9c 7a 19 80       	mov    %eax,0x80197a9c
  dev.vendor_id = vendor_id;
80108c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c32:	a3 a0 7a 19 80       	mov    %eax,0x80197aa0
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108c37:	83 ec 04             	sub    $0x4,%esp
80108c3a:	ff 75 f0             	push   -0x10(%ebp)
80108c3d:	ff 75 f4             	push   -0xc(%ebp)
80108c40:	68 b8 c8 10 80       	push   $0x8010c8b8
80108c45:	e8 aa 77 ff ff       	call   801003f4 <cprintf>
80108c4a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108c4d:	83 ec 0c             	sub    $0xc,%esp
80108c50:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c53:	50                   	push   %eax
80108c54:	6a 08                	push   $0x8
80108c56:	ff 75 10             	push   0x10(%ebp)
80108c59:	ff 75 0c             	push   0xc(%ebp)
80108c5c:	ff 75 08             	push   0x8(%ebp)
80108c5f:	e8 b5 fe ff ff       	call   80108b19 <pci_access_config>
80108c64:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108c6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c70:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c73:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108c76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c79:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108c7c:	0f b6 c0             	movzbl %al,%eax
80108c7f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108c82:	c1 eb 18             	shr    $0x18,%ebx
80108c85:	83 ec 0c             	sub    $0xc,%esp
80108c88:	51                   	push   %ecx
80108c89:	52                   	push   %edx
80108c8a:	50                   	push   %eax
80108c8b:	53                   	push   %ebx
80108c8c:	68 dc c8 10 80       	push   $0x8010c8dc
80108c91:	e8 5e 77 ff ff       	call   801003f4 <cprintf>
80108c96:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c9c:	c1 e8 18             	shr    $0x18,%eax
80108c9f:	a2 a4 7a 19 80       	mov    %al,0x80197aa4
  dev.sub_class = (data>>16)&0xFF;
80108ca4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca7:	c1 e8 10             	shr    $0x10,%eax
80108caa:	a2 a5 7a 19 80       	mov    %al,0x80197aa5
  dev.interface = (data>>8)&0xFF;
80108caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb2:	c1 e8 08             	shr    $0x8,%eax
80108cb5:	a2 a6 7a 19 80       	mov    %al,0x80197aa6
  dev.revision_id = data&0xFF;
80108cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cbd:	a2 a7 7a 19 80       	mov    %al,0x80197aa7
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108cc2:	83 ec 0c             	sub    $0xc,%esp
80108cc5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cc8:	50                   	push   %eax
80108cc9:	6a 10                	push   $0x10
80108ccb:	ff 75 10             	push   0x10(%ebp)
80108cce:	ff 75 0c             	push   0xc(%ebp)
80108cd1:	ff 75 08             	push   0x8(%ebp)
80108cd4:	e8 40 fe ff ff       	call   80108b19 <pci_access_config>
80108cd9:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cdf:	a3 a8 7a 19 80       	mov    %eax,0x80197aa8
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108ce4:	83 ec 0c             	sub    $0xc,%esp
80108ce7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cea:	50                   	push   %eax
80108ceb:	6a 14                	push   $0x14
80108ced:	ff 75 10             	push   0x10(%ebp)
80108cf0:	ff 75 0c             	push   0xc(%ebp)
80108cf3:	ff 75 08             	push   0x8(%ebp)
80108cf6:	e8 1e fe ff ff       	call   80108b19 <pci_access_config>
80108cfb:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108cfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d01:	a3 ac 7a 19 80       	mov    %eax,0x80197aac
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108d06:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108d0d:	75 5a                	jne    80108d69 <pci_init_device+0x1a5>
80108d0f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108d16:	75 51                	jne    80108d69 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108d18:	83 ec 0c             	sub    $0xc,%esp
80108d1b:	68 21 c9 10 80       	push   $0x8010c921
80108d20:	e8 cf 76 ff ff       	call   801003f4 <cprintf>
80108d25:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108d28:	83 ec 0c             	sub    $0xc,%esp
80108d2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d2e:	50                   	push   %eax
80108d2f:	68 f0 00 00 00       	push   $0xf0
80108d34:	ff 75 10             	push   0x10(%ebp)
80108d37:	ff 75 0c             	push   0xc(%ebp)
80108d3a:	ff 75 08             	push   0x8(%ebp)
80108d3d:	e8 d7 fd ff ff       	call   80108b19 <pci_access_config>
80108d42:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d48:	83 ec 08             	sub    $0x8,%esp
80108d4b:	50                   	push   %eax
80108d4c:	68 3b c9 10 80       	push   $0x8010c93b
80108d51:	e8 9e 76 ff ff       	call   801003f4 <cprintf>
80108d56:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108d59:	83 ec 0c             	sub    $0xc,%esp
80108d5c:	68 98 7a 19 80       	push   $0x80197a98
80108d61:	e8 09 00 00 00       	call   80108d6f <i8254_init>
80108d66:	83 c4 10             	add    $0x10,%esp
  }
}
80108d69:	90                   	nop
80108d6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d6d:	c9                   	leave
80108d6e:	c3                   	ret

80108d6f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108d6f:	55                   	push   %ebp
80108d70:	89 e5                	mov    %esp,%ebp
80108d72:	53                   	push   %ebx
80108d73:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108d76:	8b 45 08             	mov    0x8(%ebp),%eax
80108d79:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108d7d:	0f b6 c8             	movzbl %al,%ecx
80108d80:	8b 45 08             	mov    0x8(%ebp),%eax
80108d83:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108d87:	0f b6 d0             	movzbl %al,%edx
80108d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8d:	0f b6 00             	movzbl (%eax),%eax
80108d90:	0f b6 c0             	movzbl %al,%eax
80108d93:	83 ec 0c             	sub    $0xc,%esp
80108d96:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108d99:	53                   	push   %ebx
80108d9a:	6a 04                	push   $0x4
80108d9c:	51                   	push   %ecx
80108d9d:	52                   	push   %edx
80108d9e:	50                   	push   %eax
80108d9f:	e8 75 fd ff ff       	call   80108b19 <pci_access_config>
80108da4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108daa:	83 c8 04             	or     $0x4,%eax
80108dad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108db0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108db3:	8b 45 08             	mov    0x8(%ebp),%eax
80108db6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108dba:	0f b6 c8             	movzbl %al,%ecx
80108dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108dc4:	0f b6 d0             	movzbl %al,%edx
80108dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80108dca:	0f b6 00             	movzbl (%eax),%eax
80108dcd:	0f b6 c0             	movzbl %al,%eax
80108dd0:	83 ec 0c             	sub    $0xc,%esp
80108dd3:	53                   	push   %ebx
80108dd4:	6a 04                	push   $0x4
80108dd6:	51                   	push   %ecx
80108dd7:	52                   	push   %edx
80108dd8:	50                   	push   %eax
80108dd9:	e8 90 fd ff ff       	call   80108b6e <pci_write_config_register>
80108dde:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108de1:	8b 45 08             	mov    0x8(%ebp),%eax
80108de4:	8b 40 10             	mov    0x10(%eax),%eax
80108de7:	05 00 00 00 40       	add    $0x40000000,%eax
80108dec:	a3 b0 7a 19 80       	mov    %eax,0x80197ab0
  uint *ctrl = (uint *)base_addr;
80108df1:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108df9:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108dfe:	05 d8 00 00 00       	add    $0xd8,%eax
80108e03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e09:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e12:	8b 00                	mov    (%eax),%eax
80108e14:	0d 00 00 00 04       	or     $0x4000000,%eax
80108e19:	89 c2                	mov    %eax,%edx
80108e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e23:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2c:	8b 00                	mov    (%eax),%eax
80108e2e:	83 c8 40             	or     $0x40,%eax
80108e31:	89 c2                	mov    %eax,%edx
80108e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e36:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3b:	8b 10                	mov    (%eax),%edx
80108e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e40:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108e42:	83 ec 0c             	sub    $0xc,%esp
80108e45:	68 50 c9 10 80       	push   $0x8010c950
80108e4a:	e8 a5 75 ff ff       	call   801003f4 <cprintf>
80108e4f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108e52:	e8 51 99 ff ff       	call   801027a8 <kalloc>
80108e57:	a3 bc 7a 19 80       	mov    %eax,0x80197abc
  *intr_addr = 0;
80108e5c:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108e61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108e67:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108e6c:	83 ec 08             	sub    $0x8,%esp
80108e6f:	50                   	push   %eax
80108e70:	68 72 c9 10 80       	push   $0x8010c972
80108e75:	e8 7a 75 ff ff       	call   801003f4 <cprintf>
80108e7a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108e7d:	e8 50 00 00 00       	call   80108ed2 <i8254_init_recv>
  i8254_init_send();
80108e82:	e8 69 03 00 00       	call   801091f0 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108e87:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e8e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108e91:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108e98:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108e9b:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ea2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108ea5:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108eac:	0f b6 c0             	movzbl %al,%eax
80108eaf:	83 ec 0c             	sub    $0xc,%esp
80108eb2:	53                   	push   %ebx
80108eb3:	51                   	push   %ecx
80108eb4:	52                   	push   %edx
80108eb5:	50                   	push   %eax
80108eb6:	68 80 c9 10 80       	push   $0x8010c980
80108ebb:	e8 34 75 ff ff       	call   801003f4 <cprintf>
80108ec0:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108ecc:	90                   	nop
80108ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ed0:	c9                   	leave
80108ed1:	c3                   	ret

80108ed2 <i8254_init_recv>:

void i8254_init_recv(){
80108ed2:	55                   	push   %ebp
80108ed3:	89 e5                	mov    %esp,%ebp
80108ed5:	57                   	push   %edi
80108ed6:	56                   	push   %esi
80108ed7:	53                   	push   %ebx
80108ed8:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108edb:	83 ec 0c             	sub    $0xc,%esp
80108ede:	6a 00                	push   $0x0
80108ee0:	e8 e8 04 00 00       	call   801093cd <i8254_read_eeprom>
80108ee5:	83 c4 10             	add    $0x10,%esp
80108ee8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108eeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108eee:	a2 b4 7a 19 80       	mov    %al,0x80197ab4
  mac_addr[1] = data_l>>8;
80108ef3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ef6:	c1 e8 08             	shr    $0x8,%eax
80108ef9:	a2 b5 7a 19 80       	mov    %al,0x80197ab5
  uint data_m = i8254_read_eeprom(0x1);
80108efe:	83 ec 0c             	sub    $0xc,%esp
80108f01:	6a 01                	push   $0x1
80108f03:	e8 c5 04 00 00       	call   801093cd <i8254_read_eeprom>
80108f08:	83 c4 10             	add    $0x10,%esp
80108f0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108f0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f11:	a2 b6 7a 19 80       	mov    %al,0x80197ab6
  mac_addr[3] = data_m>>8;
80108f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f19:	c1 e8 08             	shr    $0x8,%eax
80108f1c:	a2 b7 7a 19 80       	mov    %al,0x80197ab7
  uint data_h = i8254_read_eeprom(0x2);
80108f21:	83 ec 0c             	sub    $0xc,%esp
80108f24:	6a 02                	push   $0x2
80108f26:	e8 a2 04 00 00       	call   801093cd <i8254_read_eeprom>
80108f2b:	83 c4 10             	add    $0x10,%esp
80108f2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108f31:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f34:	a2 b8 7a 19 80       	mov    %al,0x80197ab8
  mac_addr[5] = data_h>>8;
80108f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f3c:	c1 e8 08             	shr    $0x8,%eax
80108f3f:	a2 b9 7a 19 80       	mov    %al,0x80197ab9
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108f44:	0f b6 05 b9 7a 19 80 	movzbl 0x80197ab9,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f4b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108f4e:	0f b6 05 b8 7a 19 80 	movzbl 0x80197ab8,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f55:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108f58:	0f b6 05 b7 7a 19 80 	movzbl 0x80197ab7,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f5f:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108f62:	0f b6 05 b6 7a 19 80 	movzbl 0x80197ab6,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f69:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108f6c:	0f b6 05 b5 7a 19 80 	movzbl 0x80197ab5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f73:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108f76:	0f b6 05 b4 7a 19 80 	movzbl 0x80197ab4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108f7d:	0f b6 c0             	movzbl %al,%eax
80108f80:	83 ec 04             	sub    $0x4,%esp
80108f83:	57                   	push   %edi
80108f84:	56                   	push   %esi
80108f85:	53                   	push   %ebx
80108f86:	51                   	push   %ecx
80108f87:	52                   	push   %edx
80108f88:	50                   	push   %eax
80108f89:	68 98 c9 10 80       	push   $0x8010c998
80108f8e:	e8 61 74 ff ff       	call   801003f4 <cprintf>
80108f93:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108f96:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f9b:	05 00 54 00 00       	add    $0x5400,%eax
80108fa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108fa3:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108fa8:	05 04 54 00 00       	add    $0x5404,%eax
80108fad:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108fb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fb3:	c1 e0 10             	shl    $0x10,%eax
80108fb6:	0b 45 d8             	or     -0x28(%ebp),%eax
80108fb9:	89 c2                	mov    %eax,%edx
80108fbb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108fbe:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108fc0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fc3:	0d 00 00 00 80       	or     $0x80000000,%eax
80108fc8:	89 c2                	mov    %eax,%edx
80108fca:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108fcd:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108fcf:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108fd4:	05 00 52 00 00       	add    $0x5200,%eax
80108fd9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108fdc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108fe3:	eb 19                	jmp    80108ffe <i8254_init_recv+0x12c>
    mta[i] = 0;
80108fe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fe8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108fef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ff2:	01 d0                	add    %edx,%eax
80108ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ffa:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ffe:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80109002:	7e e1                	jle    80108fe5 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80109004:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109009:	05 d0 00 00 00       	add    $0xd0,%eax
8010900e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109011:	8b 45 c0             	mov    -0x40(%ebp),%eax
80109014:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010901a:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010901f:	05 c8 00 00 00       	add    $0xc8,%eax
80109024:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109027:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010902a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109030:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109035:	05 28 28 00 00       	add    $0x2828,%eax
8010903a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010903d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109040:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109046:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010904b:	05 00 01 00 00       	add    $0x100,%eax
80109050:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109053:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109056:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010905c:	e8 47 97 ff ff       	call   801027a8 <kalloc>
80109061:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109064:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109069:	05 00 28 00 00       	add    $0x2800,%eax
8010906e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80109071:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109076:	05 04 28 00 00       	add    $0x2804,%eax
8010907b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010907e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109083:	05 08 28 00 00       	add    $0x2808,%eax
80109088:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010908b:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109090:	05 10 28 00 00       	add    $0x2810,%eax
80109095:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109098:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010909d:	05 18 28 00 00       	add    $0x2818,%eax
801090a2:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801090a5:	8b 45 b0             	mov    -0x50(%ebp),%eax
801090a8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801090ae:	8b 45 ac             	mov    -0x54(%ebp),%eax
801090b1:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801090b3:	8b 45 a8             	mov    -0x58(%ebp),%eax
801090b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801090bc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801090bf:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801090c5:	8b 45 a0             	mov    -0x60(%ebp),%eax
801090c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801090ce:	8b 45 9c             	mov    -0x64(%ebp),%eax
801090d1:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801090d7:	8b 45 b0             	mov    -0x50(%ebp),%eax
801090da:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801090dd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801090e4:	eb 73                	jmp    80109159 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801090e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090e9:	c1 e0 04             	shl    $0x4,%eax
801090ec:	89 c2                	mov    %eax,%edx
801090ee:	8b 45 98             	mov    -0x68(%ebp),%eax
801090f1:	01 d0                	add    %edx,%eax
801090f3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801090fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090fd:	c1 e0 04             	shl    $0x4,%eax
80109100:	89 c2                	mov    %eax,%edx
80109102:	8b 45 98             	mov    -0x68(%ebp),%eax
80109105:	01 d0                	add    %edx,%eax
80109107:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010910d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109110:	c1 e0 04             	shl    $0x4,%eax
80109113:	89 c2                	mov    %eax,%edx
80109115:	8b 45 98             	mov    -0x68(%ebp),%eax
80109118:	01 d0                	add    %edx,%eax
8010911a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109120:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109123:	c1 e0 04             	shl    $0x4,%eax
80109126:	89 c2                	mov    %eax,%edx
80109128:	8b 45 98             	mov    -0x68(%ebp),%eax
8010912b:	01 d0                	add    %edx,%eax
8010912d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109131:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109134:	c1 e0 04             	shl    $0x4,%eax
80109137:	89 c2                	mov    %eax,%edx
80109139:	8b 45 98             	mov    -0x68(%ebp),%eax
8010913c:	01 d0                	add    %edx,%eax
8010913e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109142:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109145:	c1 e0 04             	shl    $0x4,%eax
80109148:	89 c2                	mov    %eax,%edx
8010914a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010914d:	01 d0                	add    %edx,%eax
8010914f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109155:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109159:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109160:	7e 84                	jle    801090e6 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109162:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109169:	eb 57                	jmp    801091c2 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010916b:	e8 38 96 ff ff       	call   801027a8 <kalloc>
80109170:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109173:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109177:	75 12                	jne    8010918b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109179:	83 ec 0c             	sub    $0xc,%esp
8010917c:	68 b8 c9 10 80       	push   $0x8010c9b8
80109181:	e8 6e 72 ff ff       	call   801003f4 <cprintf>
80109186:	83 c4 10             	add    $0x10,%esp
      break;
80109189:	eb 3d                	jmp    801091c8 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010918b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010918e:	c1 e0 04             	shl    $0x4,%eax
80109191:	89 c2                	mov    %eax,%edx
80109193:	8b 45 98             	mov    -0x68(%ebp),%eax
80109196:	01 d0                	add    %edx,%eax
80109198:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010919b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091a1:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801091a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801091a6:	83 c0 01             	add    $0x1,%eax
801091a9:	c1 e0 04             	shl    $0x4,%eax
801091ac:	89 c2                	mov    %eax,%edx
801091ae:	8b 45 98             	mov    -0x68(%ebp),%eax
801091b1:	01 d0                	add    %edx,%eax
801091b3:	8b 55 94             	mov    -0x6c(%ebp),%edx
801091b6:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801091bc:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801091be:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801091c2:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801091c6:	7e a3                	jle    8010916b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801091c8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801091cb:	8b 00                	mov    (%eax),%eax
801091cd:	83 c8 02             	or     $0x2,%eax
801091d0:	89 c2                	mov    %eax,%edx
801091d2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801091d5:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801091d7:	83 ec 0c             	sub    $0xc,%esp
801091da:	68 d8 c9 10 80       	push   $0x8010c9d8
801091df:	e8 10 72 ff ff       	call   801003f4 <cprintf>
801091e4:	83 c4 10             	add    $0x10,%esp
}
801091e7:	90                   	nop
801091e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801091eb:	5b                   	pop    %ebx
801091ec:	5e                   	pop    %esi
801091ed:	5f                   	pop    %edi
801091ee:	5d                   	pop    %ebp
801091ef:	c3                   	ret

801091f0 <i8254_init_send>:

void i8254_init_send(){
801091f0:	55                   	push   %ebp
801091f1:	89 e5                	mov    %esp,%ebp
801091f3:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801091f6:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801091fb:	05 28 38 00 00       	add    $0x3828,%eax
80109200:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109203:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109206:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010920c:	e8 97 95 ff ff       	call   801027a8 <kalloc>
80109211:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109214:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109219:	05 00 38 00 00       	add    $0x3800,%eax
8010921e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109221:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109226:	05 04 38 00 00       	add    $0x3804,%eax
8010922b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010922e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109233:	05 08 38 00 00       	add    $0x3808,%eax
80109238:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010923b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010923e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109247:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109249:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010924c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109252:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109255:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010925b:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109260:	05 10 38 00 00       	add    $0x3810,%eax
80109265:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109268:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010926d:	05 18 38 00 00       	add    $0x3818,%eax
80109272:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109275:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109278:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010927e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109287:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010928a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010928d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109294:	e9 82 00 00 00       	jmp    8010931b <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929c:	c1 e0 04             	shl    $0x4,%eax
8010929f:	89 c2                	mov    %eax,%edx
801092a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092a4:	01 d0                	add    %edx,%eax
801092a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801092ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b0:	c1 e0 04             	shl    $0x4,%eax
801092b3:	89 c2                	mov    %eax,%edx
801092b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092b8:	01 d0                	add    %edx,%eax
801092ba:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801092c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c3:	c1 e0 04             	shl    $0x4,%eax
801092c6:	89 c2                	mov    %eax,%edx
801092c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092cb:	01 d0                	add    %edx,%eax
801092cd:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801092d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d4:	c1 e0 04             	shl    $0x4,%eax
801092d7:	89 c2                	mov    %eax,%edx
801092d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801092e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e5:	c1 e0 04             	shl    $0x4,%eax
801092e8:	89 c2                	mov    %eax,%edx
801092ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092ed:	01 d0                	add    %edx,%eax
801092ef:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801092f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f6:	c1 e0 04             	shl    $0x4,%eax
801092f9:	89 c2                	mov    %eax,%edx
801092fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092fe:	01 d0                	add    %edx,%eax
80109300:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109307:	c1 e0 04             	shl    $0x4,%eax
8010930a:	89 c2                	mov    %eax,%edx
8010930c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010930f:	01 d0                	add    %edx,%eax
80109311:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109317:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010931b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109322:	0f 8e 71 ff ff ff    	jle    80109299 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109328:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010932f:	eb 57                	jmp    80109388 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109331:	e8 72 94 ff ff       	call   801027a8 <kalloc>
80109336:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109339:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010933d:	75 12                	jne    80109351 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010933f:	83 ec 0c             	sub    $0xc,%esp
80109342:	68 b8 c9 10 80       	push   $0x8010c9b8
80109347:	e8 a8 70 ff ff       	call   801003f4 <cprintf>
8010934c:	83 c4 10             	add    $0x10,%esp
      break;
8010934f:	eb 3d                	jmp    8010938e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109354:	c1 e0 04             	shl    $0x4,%eax
80109357:	89 c2                	mov    %eax,%edx
80109359:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010935c:	01 d0                	add    %edx,%eax
8010935e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109361:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109367:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109369:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936c:	83 c0 01             	add    $0x1,%eax
8010936f:	c1 e0 04             	shl    $0x4,%eax
80109372:	89 c2                	mov    %eax,%edx
80109374:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109377:	01 d0                	add    %edx,%eax
80109379:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010937c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109382:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109384:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109388:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010938c:	7e a3                	jle    80109331 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010938e:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109393:	05 00 04 00 00       	add    $0x400,%eax
80109398:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010939b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010939e:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801093a4:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801093a9:	05 10 04 00 00       	add    $0x410,%eax
801093ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801093b1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801093b4:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801093ba:	83 ec 0c             	sub    $0xc,%esp
801093bd:	68 f8 c9 10 80       	push   $0x8010c9f8
801093c2:	e8 2d 70 ff ff       	call   801003f4 <cprintf>
801093c7:	83 c4 10             	add    $0x10,%esp

}
801093ca:	90                   	nop
801093cb:	c9                   	leave
801093cc:	c3                   	ret

801093cd <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801093cd:	55                   	push   %ebp
801093ce:	89 e5                	mov    %esp,%ebp
801093d0:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801093d3:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801093d8:	83 c0 14             	add    $0x14,%eax
801093db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801093de:	8b 45 08             	mov    0x8(%ebp),%eax
801093e1:	c1 e0 08             	shl    $0x8,%eax
801093e4:	0f b7 c0             	movzwl %ax,%eax
801093e7:	83 c8 01             	or     $0x1,%eax
801093ea:	89 c2                	mov    %eax,%edx
801093ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ef:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801093f1:	83 ec 0c             	sub    $0xc,%esp
801093f4:	68 18 ca 10 80       	push   $0x8010ca18
801093f9:	e8 f6 6f ff ff       	call   801003f4 <cprintf>
801093fe:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109404:	8b 00                	mov    (%eax),%eax
80109406:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010940c:	83 e0 10             	and    $0x10,%eax
8010940f:	85 c0                	test   %eax,%eax
80109411:	75 02                	jne    80109415 <i8254_read_eeprom+0x48>
  while(1){
80109413:	eb dc                	jmp    801093f1 <i8254_read_eeprom+0x24>
      break;
80109415:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109419:	8b 00                	mov    (%eax),%eax
8010941b:	c1 e8 10             	shr    $0x10,%eax
}
8010941e:	c9                   	leave
8010941f:	c3                   	ret

80109420 <i8254_recv>:
void i8254_recv(){
80109420:	55                   	push   %ebp
80109421:	89 e5                	mov    %esp,%ebp
80109423:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109426:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010942b:	05 10 28 00 00       	add    $0x2810,%eax
80109430:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109433:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109438:	05 18 28 00 00       	add    $0x2818,%eax
8010943d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109440:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109445:	05 00 28 00 00       	add    $0x2800,%eax
8010944a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010944d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109450:	8b 00                	mov    (%eax),%eax
80109452:	05 00 00 00 80       	add    $0x80000000,%eax
80109457:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010945a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010945d:	8b 10                	mov    (%eax),%edx
8010945f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109462:	8b 00                	mov    (%eax),%eax
80109464:	29 c2                	sub    %eax,%edx
80109466:	89 d0                	mov    %edx,%eax
80109468:	25 ff 00 00 00       	and    $0xff,%eax
8010946d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109474:	7e 37                	jle    801094ad <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109479:	8b 00                	mov    (%eax),%eax
8010947b:	c1 e0 04             	shl    $0x4,%eax
8010947e:	89 c2                	mov    %eax,%edx
80109480:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109483:	01 d0                	add    %edx,%eax
80109485:	8b 00                	mov    (%eax),%eax
80109487:	05 00 00 00 80       	add    $0x80000000,%eax
8010948c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010948f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109492:	8b 00                	mov    (%eax),%eax
80109494:	83 c0 01             	add    $0x1,%eax
80109497:	0f b6 d0             	movzbl %al,%edx
8010949a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010949d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010949f:	83 ec 0c             	sub    $0xc,%esp
801094a2:	ff 75 e0             	push   -0x20(%ebp)
801094a5:	e8 13 09 00 00       	call   80109dbd <eth_proc>
801094aa:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801094ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b0:	8b 10                	mov    (%eax),%edx
801094b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b5:	8b 00                	mov    (%eax),%eax
801094b7:	39 c2                	cmp    %eax,%edx
801094b9:	75 9f                	jne    8010945a <i8254_recv+0x3a>
      (*rdt)--;
801094bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094be:	8b 00                	mov    (%eax),%eax
801094c0:	8d 50 ff             	lea    -0x1(%eax),%edx
801094c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094c6:	89 10                	mov    %edx,(%eax)
  while(1){
801094c8:	eb 90                	jmp    8010945a <i8254_recv+0x3a>

801094ca <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801094ca:	55                   	push   %ebp
801094cb:	89 e5                	mov    %esp,%ebp
801094cd:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801094d0:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094d5:	05 10 38 00 00       	add    $0x3810,%eax
801094da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801094dd:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094e2:	05 18 38 00 00       	add    $0x3818,%eax
801094e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801094ea:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801094ef:	05 00 38 00 00       	add    $0x3800,%eax
801094f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801094f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094fa:	8b 00                	mov    (%eax),%eax
801094fc:	05 00 00 00 80       	add    $0x80000000,%eax
80109501:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109507:	8b 10                	mov    (%eax),%edx
80109509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950c:	8b 00                	mov    (%eax),%eax
8010950e:	29 c2                	sub    %eax,%edx
80109510:	0f b6 c2             	movzbl %dl,%eax
80109513:	ba 00 01 00 00       	mov    $0x100,%edx
80109518:	29 c2                	sub    %eax,%edx
8010951a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010951d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109520:	8b 00                	mov    (%eax),%eax
80109522:	25 ff 00 00 00       	and    $0xff,%eax
80109527:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010952a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010952e:	0f 8e a8 00 00 00    	jle    801095dc <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109534:	8b 45 08             	mov    0x8(%ebp),%eax
80109537:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010953a:	89 d1                	mov    %edx,%ecx
8010953c:	c1 e1 04             	shl    $0x4,%ecx
8010953f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109542:	01 ca                	add    %ecx,%edx
80109544:	8b 12                	mov    (%edx),%edx
80109546:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010954c:	83 ec 04             	sub    $0x4,%esp
8010954f:	ff 75 0c             	push   0xc(%ebp)
80109552:	50                   	push   %eax
80109553:	52                   	push   %edx
80109554:	e8 24 be ff ff       	call   8010537d <memmove>
80109559:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010955c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010955f:	c1 e0 04             	shl    $0x4,%eax
80109562:	89 c2                	mov    %eax,%edx
80109564:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109567:	01 d0                	add    %edx,%eax
80109569:	8b 55 0c             	mov    0xc(%ebp),%edx
8010956c:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109570:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109573:	c1 e0 04             	shl    $0x4,%eax
80109576:	89 c2                	mov    %eax,%edx
80109578:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010957b:	01 d0                	add    %edx,%eax
8010957d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109581:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109584:	c1 e0 04             	shl    $0x4,%eax
80109587:	89 c2                	mov    %eax,%edx
80109589:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010958c:	01 d0                	add    %edx,%eax
8010958e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109592:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109595:	c1 e0 04             	shl    $0x4,%eax
80109598:	89 c2                	mov    %eax,%edx
8010959a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010959d:	01 d0                	add    %edx,%eax
8010959f:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801095a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095a6:	c1 e0 04             	shl    $0x4,%eax
801095a9:	89 c2                	mov    %eax,%edx
801095ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095ae:	01 d0                	add    %edx,%eax
801095b0:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801095b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801095b9:	c1 e0 04             	shl    $0x4,%eax
801095bc:	89 c2                	mov    %eax,%edx
801095be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095c1:	01 d0                	add    %edx,%eax
801095c3:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801095c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ca:	8b 00                	mov    (%eax),%eax
801095cc:	83 c0 01             	add    $0x1,%eax
801095cf:	0f b6 d0             	movzbl %al,%edx
801095d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d5:	89 10                	mov    %edx,(%eax)
    return len;
801095d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801095da:	eb 05                	jmp    801095e1 <i8254_send+0x117>
  }else{
    return -1;
801095dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801095e1:	c9                   	leave
801095e2:	c3                   	ret

801095e3 <i8254_intr>:

void i8254_intr(){
801095e3:	55                   	push   %ebp
801095e4:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801095e6:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
801095eb:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801095f1:	90                   	nop
801095f2:	5d                   	pop    %ebp
801095f3:	c3                   	ret

801095f4 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801095f4:	55                   	push   %ebp
801095f5:	89 e5                	mov    %esp,%ebp
801095f7:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801095fa:	8b 45 08             	mov    0x8(%ebp),%eax
801095fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109603:	0f b7 00             	movzwl (%eax),%eax
80109606:	66 3d 00 01          	cmp    $0x100,%ax
8010960a:	74 0a                	je     80109616 <arp_proc+0x22>
8010960c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109611:	e9 4f 01 00 00       	jmp    80109765 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109619:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010961d:	66 83 f8 08          	cmp    $0x8,%ax
80109621:	74 0a                	je     8010962d <arp_proc+0x39>
80109623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109628:	e9 38 01 00 00       	jmp    80109765 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010962d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109630:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109634:	3c 06                	cmp    $0x6,%al
80109636:	74 0a                	je     80109642 <arp_proc+0x4e>
80109638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010963d:	e9 23 01 00 00       	jmp    80109765 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109645:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109649:	3c 04                	cmp    $0x4,%al
8010964b:	74 0a                	je     80109657 <arp_proc+0x63>
8010964d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109652:	e9 0e 01 00 00       	jmp    80109765 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010965a:	83 c0 18             	add    $0x18,%eax
8010965d:	83 ec 04             	sub    $0x4,%esp
80109660:	6a 04                	push   $0x4
80109662:	50                   	push   %eax
80109663:	68 04 f5 10 80       	push   $0x8010f504
80109668:	e8 b8 bc ff ff       	call   80105325 <memcmp>
8010966d:	83 c4 10             	add    $0x10,%esp
80109670:	85 c0                	test   %eax,%eax
80109672:	74 27                	je     8010969b <arp_proc+0xa7>
80109674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109677:	83 c0 0e             	add    $0xe,%eax
8010967a:	83 ec 04             	sub    $0x4,%esp
8010967d:	6a 04                	push   $0x4
8010967f:	50                   	push   %eax
80109680:	68 04 f5 10 80       	push   $0x8010f504
80109685:	e8 9b bc ff ff       	call   80105325 <memcmp>
8010968a:	83 c4 10             	add    $0x10,%esp
8010968d:	85 c0                	test   %eax,%eax
8010968f:	74 0a                	je     8010969b <arp_proc+0xa7>
80109691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109696:	e9 ca 00 00 00       	jmp    80109765 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010969b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096a2:	66 3d 00 01          	cmp    $0x100,%ax
801096a6:	75 69                	jne    80109711 <arp_proc+0x11d>
801096a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ab:	83 c0 18             	add    $0x18,%eax
801096ae:	83 ec 04             	sub    $0x4,%esp
801096b1:	6a 04                	push   $0x4
801096b3:	50                   	push   %eax
801096b4:	68 04 f5 10 80       	push   $0x8010f504
801096b9:	e8 67 bc ff ff       	call   80105325 <memcmp>
801096be:	83 c4 10             	add    $0x10,%esp
801096c1:	85 c0                	test   %eax,%eax
801096c3:	75 4c                	jne    80109711 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801096c5:	e8 de 90 ff ff       	call   801027a8 <kalloc>
801096ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801096cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801096d4:	83 ec 04             	sub    $0x4,%esp
801096d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801096da:	50                   	push   %eax
801096db:	ff 75 f0             	push   -0x10(%ebp)
801096de:	ff 75 f4             	push   -0xc(%ebp)
801096e1:	e8 1f 04 00 00       	call   80109b05 <arp_reply_pkt_create>
801096e6:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801096e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096ec:	83 ec 08             	sub    $0x8,%esp
801096ef:	50                   	push   %eax
801096f0:	ff 75 f0             	push   -0x10(%ebp)
801096f3:	e8 d2 fd ff ff       	call   801094ca <i8254_send>
801096f8:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801096fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096fe:	83 ec 0c             	sub    $0xc,%esp
80109701:	50                   	push   %eax
80109702:	e8 07 90 ff ff       	call   8010270e <kfree>
80109707:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010970a:	b8 02 00 00 00       	mov    $0x2,%eax
8010970f:	eb 54                	jmp    80109765 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109714:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109718:	66 3d 00 02          	cmp    $0x200,%ax
8010971c:	75 42                	jne    80109760 <arp_proc+0x16c>
8010971e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109721:	83 c0 18             	add    $0x18,%eax
80109724:	83 ec 04             	sub    $0x4,%esp
80109727:	6a 04                	push   $0x4
80109729:	50                   	push   %eax
8010972a:	68 04 f5 10 80       	push   $0x8010f504
8010972f:	e8 f1 bb ff ff       	call   80105325 <memcmp>
80109734:	83 c4 10             	add    $0x10,%esp
80109737:	85 c0                	test   %eax,%eax
80109739:	75 25                	jne    80109760 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010973b:	83 ec 0c             	sub    $0xc,%esp
8010973e:	68 1c ca 10 80       	push   $0x8010ca1c
80109743:	e8 ac 6c ff ff       	call   801003f4 <cprintf>
80109748:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010974b:	83 ec 0c             	sub    $0xc,%esp
8010974e:	ff 75 f4             	push   -0xc(%ebp)
80109751:	e8 af 01 00 00       	call   80109905 <arp_table_update>
80109756:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109759:	b8 01 00 00 00       	mov    $0x1,%eax
8010975e:	eb 05                	jmp    80109765 <arp_proc+0x171>
  }else{
    return -1;
80109760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109765:	c9                   	leave
80109766:	c3                   	ret

80109767 <arp_scan>:

void arp_scan(){
80109767:	55                   	push   %ebp
80109768:	89 e5                	mov    %esp,%ebp
8010976a:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010976d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109774:	eb 6f                	jmp    801097e5 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109776:	e8 2d 90 ff ff       	call   801027a8 <kalloc>
8010977b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010977e:	83 ec 04             	sub    $0x4,%esp
80109781:	ff 75 f4             	push   -0xc(%ebp)
80109784:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109787:	50                   	push   %eax
80109788:	ff 75 ec             	push   -0x14(%ebp)
8010978b:	e8 62 00 00 00       	call   801097f2 <arp_broadcast>
80109790:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109793:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109796:	83 ec 08             	sub    $0x8,%esp
80109799:	50                   	push   %eax
8010979a:	ff 75 ec             	push   -0x14(%ebp)
8010979d:	e8 28 fd ff ff       	call   801094ca <i8254_send>
801097a2:	83 c4 10             	add    $0x10,%esp
801097a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801097a8:	eb 22                	jmp    801097cc <arp_scan+0x65>
      microdelay(1);
801097aa:	83 ec 0c             	sub    $0xc,%esp
801097ad:	6a 01                	push   $0x1
801097af:	e8 85 93 ff ff       	call   80102b39 <microdelay>
801097b4:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801097b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097ba:	83 ec 08             	sub    $0x8,%esp
801097bd:	50                   	push   %eax
801097be:	ff 75 ec             	push   -0x14(%ebp)
801097c1:	e8 04 fd ff ff       	call   801094ca <i8254_send>
801097c6:	83 c4 10             	add    $0x10,%esp
801097c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801097cc:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801097d0:	74 d8                	je     801097aa <arp_scan+0x43>
    }
    kfree((char *)send);
801097d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097d5:	83 ec 0c             	sub    $0xc,%esp
801097d8:	50                   	push   %eax
801097d9:	e8 30 8f ff ff       	call   8010270e <kfree>
801097de:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801097e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097e5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801097ec:	7e 88                	jle    80109776 <arp_scan+0xf>
  }
}
801097ee:	90                   	nop
801097ef:	90                   	nop
801097f0:	c9                   	leave
801097f1:	c3                   	ret

801097f2 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801097f2:	55                   	push   %ebp
801097f3:	89 e5                	mov    %esp,%ebp
801097f5:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801097f8:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801097fc:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109800:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109804:	8b 45 10             	mov    0x10(%ebp),%eax
80109807:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010980a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109811:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109817:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010981e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109824:	8b 45 0c             	mov    0xc(%ebp),%eax
80109827:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010982d:	8b 45 08             	mov    0x8(%ebp),%eax
80109830:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109833:	8b 45 08             	mov    0x8(%ebp),%eax
80109836:	83 c0 0e             	add    $0xe,%eax
80109839:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010983c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109846:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010984a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984d:	83 ec 04             	sub    $0x4,%esp
80109850:	6a 06                	push   $0x6
80109852:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109855:	52                   	push   %edx
80109856:	50                   	push   %eax
80109857:	e8 21 bb ff ff       	call   8010537d <memmove>
8010985c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010985f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109862:	83 c0 06             	add    $0x6,%eax
80109865:	83 ec 04             	sub    $0x4,%esp
80109868:	6a 06                	push   $0x6
8010986a:	68 b4 7a 19 80       	push   $0x80197ab4
8010986f:	50                   	push   %eax
80109870:	e8 08 bb ff ff       	call   8010537d <memmove>
80109875:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987b:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109883:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010988c:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109893:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010989a:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801098a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a3:	8d 50 12             	lea    0x12(%eax),%edx
801098a6:	83 ec 04             	sub    $0x4,%esp
801098a9:	6a 06                	push   $0x6
801098ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
801098ae:	50                   	push   %eax
801098af:	52                   	push   %edx
801098b0:	e8 c8 ba ff ff       	call   8010537d <memmove>
801098b5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801098b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098bb:	8d 50 18             	lea    0x18(%eax),%edx
801098be:	83 ec 04             	sub    $0x4,%esp
801098c1:	6a 04                	push   $0x4
801098c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801098c6:	50                   	push   %eax
801098c7:	52                   	push   %edx
801098c8:	e8 b0 ba ff ff       	call   8010537d <memmove>
801098cd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801098d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d3:	83 c0 08             	add    $0x8,%eax
801098d6:	83 ec 04             	sub    $0x4,%esp
801098d9:	6a 06                	push   $0x6
801098db:	68 b4 7a 19 80       	push   $0x80197ab4
801098e0:	50                   	push   %eax
801098e1:	e8 97 ba ff ff       	call   8010537d <memmove>
801098e6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ec:	83 c0 0e             	add    $0xe,%eax
801098ef:	83 ec 04             	sub    $0x4,%esp
801098f2:	6a 04                	push   $0x4
801098f4:	68 04 f5 10 80       	push   $0x8010f504
801098f9:	50                   	push   %eax
801098fa:	e8 7e ba ff ff       	call   8010537d <memmove>
801098ff:	83 c4 10             	add    $0x10,%esp
}
80109902:	90                   	nop
80109903:	c9                   	leave
80109904:	c3                   	ret

80109905 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109905:	55                   	push   %ebp
80109906:	89 e5                	mov    %esp,%ebp
80109908:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010990b:	8b 45 08             	mov    0x8(%ebp),%eax
8010990e:	83 c0 0e             	add    $0xe,%eax
80109911:	83 ec 0c             	sub    $0xc,%esp
80109914:	50                   	push   %eax
80109915:	e8 bc 00 00 00       	call   801099d6 <arp_table_search>
8010991a:	83 c4 10             	add    $0x10,%esp
8010991d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109920:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109924:	78 2d                	js     80109953 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109926:	8b 45 08             	mov    0x8(%ebp),%eax
80109929:	8d 48 08             	lea    0x8(%eax),%ecx
8010992c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010992f:	89 d0                	mov    %edx,%eax
80109931:	c1 e0 02             	shl    $0x2,%eax
80109934:	01 d0                	add    %edx,%eax
80109936:	01 c0                	add    %eax,%eax
80109938:	01 d0                	add    %edx,%eax
8010993a:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
8010993f:	83 c0 04             	add    $0x4,%eax
80109942:	83 ec 04             	sub    $0x4,%esp
80109945:	6a 06                	push   $0x6
80109947:	51                   	push   %ecx
80109948:	50                   	push   %eax
80109949:	e8 2f ba ff ff       	call   8010537d <memmove>
8010994e:	83 c4 10             	add    $0x10,%esp
80109951:	eb 70                	jmp    801099c3 <arp_table_update+0xbe>
  }else{
    index += 1;
80109953:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109957:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010995a:	8b 45 08             	mov    0x8(%ebp),%eax
8010995d:	8d 48 08             	lea    0x8(%eax),%ecx
80109960:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109963:	89 d0                	mov    %edx,%eax
80109965:	c1 e0 02             	shl    $0x2,%eax
80109968:	01 d0                	add    %edx,%eax
8010996a:	01 c0                	add    %eax,%eax
8010996c:	01 d0                	add    %edx,%eax
8010996e:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109973:	83 c0 04             	add    $0x4,%eax
80109976:	83 ec 04             	sub    $0x4,%esp
80109979:	6a 06                	push   $0x6
8010997b:	51                   	push   %ecx
8010997c:	50                   	push   %eax
8010997d:	e8 fb b9 ff ff       	call   8010537d <memmove>
80109982:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109985:	8b 45 08             	mov    0x8(%ebp),%eax
80109988:	8d 48 0e             	lea    0xe(%eax),%ecx
8010998b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010998e:	89 d0                	mov    %edx,%eax
80109990:	c1 e0 02             	shl    $0x2,%eax
80109993:	01 d0                	add    %edx,%eax
80109995:	01 c0                	add    %eax,%eax
80109997:	01 d0                	add    %edx,%eax
80109999:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
8010999e:	83 ec 04             	sub    $0x4,%esp
801099a1:	6a 04                	push   $0x4
801099a3:	51                   	push   %ecx
801099a4:	50                   	push   %eax
801099a5:	e8 d3 b9 ff ff       	call   8010537d <memmove>
801099aa:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801099ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099b0:	89 d0                	mov    %edx,%eax
801099b2:	c1 e0 02             	shl    $0x2,%eax
801099b5:	01 d0                	add    %edx,%eax
801099b7:	01 c0                	add    %eax,%eax
801099b9:	01 d0                	add    %edx,%eax
801099bb:	05 ca 7a 19 80       	add    $0x80197aca,%eax
801099c0:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801099c3:	83 ec 0c             	sub    $0xc,%esp
801099c6:	68 c0 7a 19 80       	push   $0x80197ac0
801099cb:	e8 83 00 00 00       	call   80109a53 <print_arp_table>
801099d0:	83 c4 10             	add    $0x10,%esp
}
801099d3:	90                   	nop
801099d4:	c9                   	leave
801099d5:	c3                   	ret

801099d6 <arp_table_search>:

int arp_table_search(uchar *ip){
801099d6:	55                   	push   %ebp
801099d7:	89 e5                	mov    %esp,%ebp
801099d9:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801099dc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801099e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801099ea:	eb 59                	jmp    80109a45 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801099ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801099ef:	89 d0                	mov    %edx,%eax
801099f1:	c1 e0 02             	shl    $0x2,%eax
801099f4:	01 d0                	add    %edx,%eax
801099f6:	01 c0                	add    %eax,%eax
801099f8:	01 d0                	add    %edx,%eax
801099fa:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
801099ff:	83 ec 04             	sub    $0x4,%esp
80109a02:	6a 04                	push   $0x4
80109a04:	ff 75 08             	push   0x8(%ebp)
80109a07:	50                   	push   %eax
80109a08:	e8 18 b9 ff ff       	call   80105325 <memcmp>
80109a0d:	83 c4 10             	add    $0x10,%esp
80109a10:	85 c0                	test   %eax,%eax
80109a12:	75 05                	jne    80109a19 <arp_table_search+0x43>
      return i;
80109a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a17:	eb 38                	jmp    80109a51 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109a19:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109a1c:	89 d0                	mov    %edx,%eax
80109a1e:	c1 e0 02             	shl    $0x2,%eax
80109a21:	01 d0                	add    %edx,%eax
80109a23:	01 c0                	add    %eax,%eax
80109a25:	01 d0                	add    %edx,%eax
80109a27:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109a2c:	0f b6 00             	movzbl (%eax),%eax
80109a2f:	84 c0                	test   %al,%al
80109a31:	75 0e                	jne    80109a41 <arp_table_search+0x6b>
80109a33:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109a37:	75 08                	jne    80109a41 <arp_table_search+0x6b>
      empty = -i;
80109a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a3c:	f7 d8                	neg    %eax
80109a3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109a41:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109a45:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109a49:	7e a1                	jle    801099ec <arp_table_search+0x16>
    }
  }
  return empty-1;
80109a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4e:	83 e8 01             	sub    $0x1,%eax
}
80109a51:	c9                   	leave
80109a52:	c3                   	ret

80109a53 <print_arp_table>:

void print_arp_table(){
80109a53:	55                   	push   %ebp
80109a54:	89 e5                	mov    %esp,%ebp
80109a56:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109a60:	e9 92 00 00 00       	jmp    80109af7 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a68:	89 d0                	mov    %edx,%eax
80109a6a:	c1 e0 02             	shl    $0x2,%eax
80109a6d:	01 d0                	add    %edx,%eax
80109a6f:	01 c0                	add    %eax,%eax
80109a71:	01 d0                	add    %edx,%eax
80109a73:	05 ca 7a 19 80       	add    $0x80197aca,%eax
80109a78:	0f b6 00             	movzbl (%eax),%eax
80109a7b:	84 c0                	test   %al,%al
80109a7d:	74 74                	je     80109af3 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109a7f:	83 ec 08             	sub    $0x8,%esp
80109a82:	ff 75 f4             	push   -0xc(%ebp)
80109a85:	68 2f ca 10 80       	push   $0x8010ca2f
80109a8a:	e8 65 69 ff ff       	call   801003f4 <cprintf>
80109a8f:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a95:	89 d0                	mov    %edx,%eax
80109a97:	c1 e0 02             	shl    $0x2,%eax
80109a9a:	01 d0                	add    %edx,%eax
80109a9c:	01 c0                	add    %eax,%eax
80109a9e:	01 d0                	add    %edx,%eax
80109aa0:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109aa5:	83 ec 0c             	sub    $0xc,%esp
80109aa8:	50                   	push   %eax
80109aa9:	e8 54 02 00 00       	call   80109d02 <print_ipv4>
80109aae:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109ab1:	83 ec 0c             	sub    $0xc,%esp
80109ab4:	68 3e ca 10 80       	push   $0x8010ca3e
80109ab9:	e8 36 69 ff ff       	call   801003f4 <cprintf>
80109abe:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109ac1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ac4:	89 d0                	mov    %edx,%eax
80109ac6:	c1 e0 02             	shl    $0x2,%eax
80109ac9:	01 d0                	add    %edx,%eax
80109acb:	01 c0                	add    %eax,%eax
80109acd:	01 d0                	add    %edx,%eax
80109acf:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109ad4:	83 c0 04             	add    $0x4,%eax
80109ad7:	83 ec 0c             	sub    $0xc,%esp
80109ada:	50                   	push   %eax
80109adb:	e8 70 02 00 00       	call   80109d50 <print_mac>
80109ae0:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109ae3:	83 ec 0c             	sub    $0xc,%esp
80109ae6:	68 40 ca 10 80       	push   $0x8010ca40
80109aeb:	e8 04 69 ff ff       	call   801003f4 <cprintf>
80109af0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109af3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109af7:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109afb:	0f 8e 64 ff ff ff    	jle    80109a65 <print_arp_table+0x12>
    }
  }
}
80109b01:	90                   	nop
80109b02:	90                   	nop
80109b03:	c9                   	leave
80109b04:	c3                   	ret

80109b05 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109b05:	55                   	push   %ebp
80109b06:	89 e5                	mov    %esp,%ebp
80109b08:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109b0b:	8b 45 10             	mov    0x10(%ebp),%eax
80109b0e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109b14:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b1d:	83 c0 0e             	add    $0xe,%eax
80109b20:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b26:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b2d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109b31:	8b 45 08             	mov    0x8(%ebp),%eax
80109b34:	8d 50 08             	lea    0x8(%eax),%edx
80109b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3a:	83 ec 04             	sub    $0x4,%esp
80109b3d:	6a 06                	push   $0x6
80109b3f:	52                   	push   %edx
80109b40:	50                   	push   %eax
80109b41:	e8 37 b8 ff ff       	call   8010537d <memmove>
80109b46:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4c:	83 c0 06             	add    $0x6,%eax
80109b4f:	83 ec 04             	sub    $0x4,%esp
80109b52:	6a 06                	push   $0x6
80109b54:	68 b4 7a 19 80       	push   $0x80197ab4
80109b59:	50                   	push   %eax
80109b5a:	e8 1e b8 ff ff       	call   8010537d <memmove>
80109b5f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b65:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6d:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b76:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b7d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b84:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b8d:	8d 50 08             	lea    0x8(%eax),%edx
80109b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b93:	83 c0 12             	add    $0x12,%eax
80109b96:	83 ec 04             	sub    $0x4,%esp
80109b99:	6a 06                	push   $0x6
80109b9b:	52                   	push   %edx
80109b9c:	50                   	push   %eax
80109b9d:	e8 db b7 ff ff       	call   8010537d <memmove>
80109ba2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba8:	8d 50 0e             	lea    0xe(%eax),%edx
80109bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bae:	83 c0 18             	add    $0x18,%eax
80109bb1:	83 ec 04             	sub    $0x4,%esp
80109bb4:	6a 04                	push   $0x4
80109bb6:	52                   	push   %edx
80109bb7:	50                   	push   %eax
80109bb8:	e8 c0 b7 ff ff       	call   8010537d <memmove>
80109bbd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc3:	83 c0 08             	add    $0x8,%eax
80109bc6:	83 ec 04             	sub    $0x4,%esp
80109bc9:	6a 06                	push   $0x6
80109bcb:	68 b4 7a 19 80       	push   $0x80197ab4
80109bd0:	50                   	push   %eax
80109bd1:	e8 a7 b7 ff ff       	call   8010537d <memmove>
80109bd6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bdc:	83 c0 0e             	add    $0xe,%eax
80109bdf:	83 ec 04             	sub    $0x4,%esp
80109be2:	6a 04                	push   $0x4
80109be4:	68 04 f5 10 80       	push   $0x8010f504
80109be9:	50                   	push   %eax
80109bea:	e8 8e b7 ff ff       	call   8010537d <memmove>
80109bef:	83 c4 10             	add    $0x10,%esp
}
80109bf2:	90                   	nop
80109bf3:	c9                   	leave
80109bf4:	c3                   	ret

80109bf5 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109bf5:	55                   	push   %ebp
80109bf6:	89 e5                	mov    %esp,%ebp
80109bf8:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109bfb:	83 ec 0c             	sub    $0xc,%esp
80109bfe:	68 42 ca 10 80       	push   $0x8010ca42
80109c03:	e8 ec 67 ff ff       	call   801003f4 <cprintf>
80109c08:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c0e:	83 c0 0e             	add    $0xe,%eax
80109c11:	83 ec 0c             	sub    $0xc,%esp
80109c14:	50                   	push   %eax
80109c15:	e8 e8 00 00 00       	call   80109d02 <print_ipv4>
80109c1a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c1d:	83 ec 0c             	sub    $0xc,%esp
80109c20:	68 40 ca 10 80       	push   $0x8010ca40
80109c25:	e8 ca 67 ff ff       	call   801003f4 <cprintf>
80109c2a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c30:	83 c0 08             	add    $0x8,%eax
80109c33:	83 ec 0c             	sub    $0xc,%esp
80109c36:	50                   	push   %eax
80109c37:	e8 14 01 00 00       	call   80109d50 <print_mac>
80109c3c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c3f:	83 ec 0c             	sub    $0xc,%esp
80109c42:	68 40 ca 10 80       	push   $0x8010ca40
80109c47:	e8 a8 67 ff ff       	call   801003f4 <cprintf>
80109c4c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109c4f:	83 ec 0c             	sub    $0xc,%esp
80109c52:	68 59 ca 10 80       	push   $0x8010ca59
80109c57:	e8 98 67 ff ff       	call   801003f4 <cprintf>
80109c5c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c62:	83 c0 18             	add    $0x18,%eax
80109c65:	83 ec 0c             	sub    $0xc,%esp
80109c68:	50                   	push   %eax
80109c69:	e8 94 00 00 00       	call   80109d02 <print_ipv4>
80109c6e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c71:	83 ec 0c             	sub    $0xc,%esp
80109c74:	68 40 ca 10 80       	push   $0x8010ca40
80109c79:	e8 76 67 ff ff       	call   801003f4 <cprintf>
80109c7e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109c81:	8b 45 08             	mov    0x8(%ebp),%eax
80109c84:	83 c0 12             	add    $0x12,%eax
80109c87:	83 ec 0c             	sub    $0xc,%esp
80109c8a:	50                   	push   %eax
80109c8b:	e8 c0 00 00 00       	call   80109d50 <print_mac>
80109c90:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109c93:	83 ec 0c             	sub    $0xc,%esp
80109c96:	68 40 ca 10 80       	push   $0x8010ca40
80109c9b:	e8 54 67 ff ff       	call   801003f4 <cprintf>
80109ca0:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109ca3:	83 ec 0c             	sub    $0xc,%esp
80109ca6:	68 70 ca 10 80       	push   $0x8010ca70
80109cab:	e8 44 67 ff ff       	call   801003f4 <cprintf>
80109cb0:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80109cb6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cba:	66 3d 00 01          	cmp    $0x100,%ax
80109cbe:	75 12                	jne    80109cd2 <print_arp_info+0xdd>
80109cc0:	83 ec 0c             	sub    $0xc,%esp
80109cc3:	68 7c ca 10 80       	push   $0x8010ca7c
80109cc8:	e8 27 67 ff ff       	call   801003f4 <cprintf>
80109ccd:	83 c4 10             	add    $0x10,%esp
80109cd0:	eb 1d                	jmp    80109cef <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cd9:	66 3d 00 02          	cmp    $0x200,%ax
80109cdd:	75 10                	jne    80109cef <print_arp_info+0xfa>
    cprintf("Reply\n");
80109cdf:	83 ec 0c             	sub    $0xc,%esp
80109ce2:	68 85 ca 10 80       	push   $0x8010ca85
80109ce7:	e8 08 67 ff ff       	call   801003f4 <cprintf>
80109cec:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109cef:	83 ec 0c             	sub    $0xc,%esp
80109cf2:	68 40 ca 10 80       	push   $0x8010ca40
80109cf7:	e8 f8 66 ff ff       	call   801003f4 <cprintf>
80109cfc:	83 c4 10             	add    $0x10,%esp
}
80109cff:	90                   	nop
80109d00:	c9                   	leave
80109d01:	c3                   	ret

80109d02 <print_ipv4>:

void print_ipv4(uchar *ip){
80109d02:	55                   	push   %ebp
80109d03:	89 e5                	mov    %esp,%ebp
80109d05:	53                   	push   %ebx
80109d06:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109d09:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0c:	83 c0 03             	add    $0x3,%eax
80109d0f:	0f b6 00             	movzbl (%eax),%eax
80109d12:	0f b6 d8             	movzbl %al,%ebx
80109d15:	8b 45 08             	mov    0x8(%ebp),%eax
80109d18:	83 c0 02             	add    $0x2,%eax
80109d1b:	0f b6 00             	movzbl (%eax),%eax
80109d1e:	0f b6 c8             	movzbl %al,%ecx
80109d21:	8b 45 08             	mov    0x8(%ebp),%eax
80109d24:	83 c0 01             	add    $0x1,%eax
80109d27:	0f b6 00             	movzbl (%eax),%eax
80109d2a:	0f b6 d0             	movzbl %al,%edx
80109d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d30:	0f b6 00             	movzbl (%eax),%eax
80109d33:	0f b6 c0             	movzbl %al,%eax
80109d36:	83 ec 0c             	sub    $0xc,%esp
80109d39:	53                   	push   %ebx
80109d3a:	51                   	push   %ecx
80109d3b:	52                   	push   %edx
80109d3c:	50                   	push   %eax
80109d3d:	68 8c ca 10 80       	push   $0x8010ca8c
80109d42:	e8 ad 66 ff ff       	call   801003f4 <cprintf>
80109d47:	83 c4 20             	add    $0x20,%esp
}
80109d4a:	90                   	nop
80109d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d4e:	c9                   	leave
80109d4f:	c3                   	ret

80109d50 <print_mac>:

void print_mac(uchar *mac){
80109d50:	55                   	push   %ebp
80109d51:	89 e5                	mov    %esp,%ebp
80109d53:	57                   	push   %edi
80109d54:	56                   	push   %esi
80109d55:	53                   	push   %ebx
80109d56:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109d59:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5c:	83 c0 05             	add    $0x5,%eax
80109d5f:	0f b6 00             	movzbl (%eax),%eax
80109d62:	0f b6 f8             	movzbl %al,%edi
80109d65:	8b 45 08             	mov    0x8(%ebp),%eax
80109d68:	83 c0 04             	add    $0x4,%eax
80109d6b:	0f b6 00             	movzbl (%eax),%eax
80109d6e:	0f b6 f0             	movzbl %al,%esi
80109d71:	8b 45 08             	mov    0x8(%ebp),%eax
80109d74:	83 c0 03             	add    $0x3,%eax
80109d77:	0f b6 00             	movzbl (%eax),%eax
80109d7a:	0f b6 d8             	movzbl %al,%ebx
80109d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d80:	83 c0 02             	add    $0x2,%eax
80109d83:	0f b6 00             	movzbl (%eax),%eax
80109d86:	0f b6 c8             	movzbl %al,%ecx
80109d89:	8b 45 08             	mov    0x8(%ebp),%eax
80109d8c:	83 c0 01             	add    $0x1,%eax
80109d8f:	0f b6 00             	movzbl (%eax),%eax
80109d92:	0f b6 d0             	movzbl %al,%edx
80109d95:	8b 45 08             	mov    0x8(%ebp),%eax
80109d98:	0f b6 00             	movzbl (%eax),%eax
80109d9b:	0f b6 c0             	movzbl %al,%eax
80109d9e:	83 ec 04             	sub    $0x4,%esp
80109da1:	57                   	push   %edi
80109da2:	56                   	push   %esi
80109da3:	53                   	push   %ebx
80109da4:	51                   	push   %ecx
80109da5:	52                   	push   %edx
80109da6:	50                   	push   %eax
80109da7:	68 a4 ca 10 80       	push   $0x8010caa4
80109dac:	e8 43 66 ff ff       	call   801003f4 <cprintf>
80109db1:	83 c4 20             	add    $0x20,%esp
}
80109db4:	90                   	nop
80109db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109db8:	5b                   	pop    %ebx
80109db9:	5e                   	pop    %esi
80109dba:	5f                   	pop    %edi
80109dbb:	5d                   	pop    %ebp
80109dbc:	c3                   	ret

80109dbd <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109dbd:	55                   	push   %ebp
80109dbe:	89 e5                	mov    %esp,%ebp
80109dc0:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80109dcc:	83 c0 0e             	add    $0xe,%eax
80109dcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dd5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109dd9:	3c 08                	cmp    $0x8,%al
80109ddb:	75 1b                	jne    80109df8 <eth_proc+0x3b>
80109ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de0:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109de4:	3c 06                	cmp    $0x6,%al
80109de6:	75 10                	jne    80109df8 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109de8:	83 ec 0c             	sub    $0xc,%esp
80109deb:	ff 75 f0             	push   -0x10(%ebp)
80109dee:	e8 01 f8 ff ff       	call   801095f4 <arp_proc>
80109df3:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109df6:	eb 24                	jmp    80109e1c <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dfb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109dff:	3c 08                	cmp    $0x8,%al
80109e01:	75 19                	jne    80109e1c <eth_proc+0x5f>
80109e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e06:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e0a:	84 c0                	test   %al,%al
80109e0c:	75 0e                	jne    80109e1c <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109e0e:	83 ec 0c             	sub    $0xc,%esp
80109e11:	ff 75 08             	push   0x8(%ebp)
80109e14:	e8 8d 00 00 00       	call   80109ea6 <ipv4_proc>
80109e19:	83 c4 10             	add    $0x10,%esp
}
80109e1c:	90                   	nop
80109e1d:	c9                   	leave
80109e1e:	c3                   	ret

80109e1f <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109e1f:	55                   	push   %ebp
80109e20:	89 e5                	mov    %esp,%ebp
80109e22:	83 ec 04             	sub    $0x4,%esp
80109e25:	8b 45 08             	mov    0x8(%ebp),%eax
80109e28:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109e2c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e30:	66 c1 c0 08          	rol    $0x8,%ax
}
80109e34:	c9                   	leave
80109e35:	c3                   	ret

80109e36 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109e36:	55                   	push   %ebp
80109e37:	89 e5                	mov    %esp,%ebp
80109e39:	83 ec 04             	sub    $0x4,%esp
80109e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e3f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109e43:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109e47:	66 c1 c0 08          	rol    $0x8,%ax
}
80109e4b:	c9                   	leave
80109e4c:	c3                   	ret

80109e4d <H2N_uint>:

uint H2N_uint(uint value){
80109e4d:	55                   	push   %ebp
80109e4e:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109e50:	8b 45 08             	mov    0x8(%ebp),%eax
80109e53:	c1 e0 18             	shl    $0x18,%eax
80109e56:	25 00 00 00 0f       	and    $0xf000000,%eax
80109e5b:	89 c2                	mov    %eax,%edx
80109e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e60:	c1 e0 08             	shl    $0x8,%eax
80109e63:	25 00 f0 00 00       	and    $0xf000,%eax
80109e68:	09 c2                	or     %eax,%edx
80109e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6d:	c1 e8 08             	shr    $0x8,%eax
80109e70:	83 e0 0f             	and    $0xf,%eax
80109e73:	01 d0                	add    %edx,%eax
}
80109e75:	5d                   	pop    %ebp
80109e76:	c3                   	ret

80109e77 <N2H_uint>:

uint N2H_uint(uint value){
80109e77:	55                   	push   %ebp
80109e78:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e7d:	c1 e0 18             	shl    $0x18,%eax
80109e80:	89 c2                	mov    %eax,%edx
80109e82:	8b 45 08             	mov    0x8(%ebp),%eax
80109e85:	c1 e0 08             	shl    $0x8,%eax
80109e88:	25 00 00 ff 00       	and    $0xff0000,%eax
80109e8d:	01 c2                	add    %eax,%edx
80109e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109e92:	c1 e8 08             	shr    $0x8,%eax
80109e95:	25 00 ff 00 00       	and    $0xff00,%eax
80109e9a:	01 c2                	add    %eax,%edx
80109e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e9f:	c1 e8 18             	shr    $0x18,%eax
80109ea2:	01 d0                	add    %edx,%eax
}
80109ea4:	5d                   	pop    %ebp
80109ea5:	c3                   	ret

80109ea6 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109ea6:	55                   	push   %ebp
80109ea7:	89 e5                	mov    %esp,%ebp
80109ea9:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109eac:	8b 45 08             	mov    0x8(%ebp),%eax
80109eaf:	83 c0 0e             	add    $0xe,%eax
80109eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ebc:	0f b7 d0             	movzwl %ax,%edx
80109ebf:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109ec4:	39 c2                	cmp    %eax,%edx
80109ec6:	74 60                	je     80109f28 <ipv4_proc+0x82>
80109ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ecb:	83 c0 0c             	add    $0xc,%eax
80109ece:	83 ec 04             	sub    $0x4,%esp
80109ed1:	6a 04                	push   $0x4
80109ed3:	50                   	push   %eax
80109ed4:	68 04 f5 10 80       	push   $0x8010f504
80109ed9:	e8 47 b4 ff ff       	call   80105325 <memcmp>
80109ede:	83 c4 10             	add    $0x10,%esp
80109ee1:	85 c0                	test   %eax,%eax
80109ee3:	74 43                	je     80109f28 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109eec:	0f b7 c0             	movzwl %ax,%eax
80109eef:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109efb:	3c 01                	cmp    $0x1,%al
80109efd:	75 10                	jne    80109f0f <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109eff:	83 ec 0c             	sub    $0xc,%esp
80109f02:	ff 75 08             	push   0x8(%ebp)
80109f05:	e8 a3 00 00 00       	call   80109fad <icmp_proc>
80109f0a:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109f0d:	eb 19                	jmp    80109f28 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f12:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109f16:	3c 06                	cmp    $0x6,%al
80109f18:	75 0e                	jne    80109f28 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109f1a:	83 ec 0c             	sub    $0xc,%esp
80109f1d:	ff 75 08             	push   0x8(%ebp)
80109f20:	e8 b3 03 00 00       	call   8010a2d8 <tcp_proc>
80109f25:	83 c4 10             	add    $0x10,%esp
}
80109f28:	90                   	nop
80109f29:	c9                   	leave
80109f2a:	c3                   	ret

80109f2b <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109f2b:	55                   	push   %ebp
80109f2c:	89 e5                	mov    %esp,%ebp
80109f2e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109f31:	8b 45 08             	mov    0x8(%ebp),%eax
80109f34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f3a:	0f b6 00             	movzbl (%eax),%eax
80109f3d:	83 e0 0f             	and    $0xf,%eax
80109f40:	01 c0                	add    %eax,%eax
80109f42:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109f45:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109f4c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f53:	eb 48                	jmp    80109f9d <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f58:	01 c0                	add    %eax,%eax
80109f5a:	89 c2                	mov    %eax,%edx
80109f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f5f:	01 d0                	add    %edx,%eax
80109f61:	0f b6 00             	movzbl (%eax),%eax
80109f64:	0f b6 c0             	movzbl %al,%eax
80109f67:	c1 e0 08             	shl    $0x8,%eax
80109f6a:	89 c2                	mov    %eax,%edx
80109f6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f6f:	01 c0                	add    %eax,%eax
80109f71:	8d 48 01             	lea    0x1(%eax),%ecx
80109f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f77:	01 c8                	add    %ecx,%eax
80109f79:	0f b6 00             	movzbl (%eax),%eax
80109f7c:	0f b6 c0             	movzbl %al,%eax
80109f7f:	01 d0                	add    %edx,%eax
80109f81:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109f84:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f8b:	76 0c                	jbe    80109f99 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f90:	0f b7 c0             	movzwl %ax,%eax
80109f93:	83 c0 01             	add    $0x1,%eax
80109f96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109f99:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f9d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109fa1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109fa4:	7c af                	jl     80109f55 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109fa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fa9:	f7 d0                	not    %eax
}
80109fab:	c9                   	leave
80109fac:	c3                   	ret

80109fad <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109fad:	55                   	push   %ebp
80109fae:	89 e5                	mov    %esp,%ebp
80109fb0:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb6:	83 c0 0e             	add    $0xe,%eax
80109fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbf:	0f b6 00             	movzbl (%eax),%eax
80109fc2:	0f b6 c0             	movzbl %al,%eax
80109fc5:	83 e0 0f             	and    $0xf,%eax
80109fc8:	c1 e0 02             	shl    $0x2,%eax
80109fcb:	89 c2                	mov    %eax,%edx
80109fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fd0:	01 d0                	add    %edx,%eax
80109fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109fdc:	84 c0                	test   %al,%al
80109fde:	75 4f                	jne    8010a02f <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fe3:	0f b6 00             	movzbl (%eax),%eax
80109fe6:	3c 08                	cmp    $0x8,%al
80109fe8:	75 45                	jne    8010a02f <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109fea:	e8 b9 87 ff ff       	call   801027a8 <kalloc>
80109fef:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ff2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109ff9:	83 ec 04             	sub    $0x4,%esp
80109ffc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109fff:	50                   	push   %eax
8010a000:	ff 75 ec             	push   -0x14(%ebp)
8010a003:	ff 75 08             	push   0x8(%ebp)
8010a006:	e8 78 00 00 00       	call   8010a083 <icmp_reply_pkt_create>
8010a00b:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a00e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a011:	83 ec 08             	sub    $0x8,%esp
8010a014:	50                   	push   %eax
8010a015:	ff 75 ec             	push   -0x14(%ebp)
8010a018:	e8 ad f4 ff ff       	call   801094ca <i8254_send>
8010a01d:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a020:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a023:	83 ec 0c             	sub    $0xc,%esp
8010a026:	50                   	push   %eax
8010a027:	e8 e2 86 ff ff       	call   8010270e <kfree>
8010a02c:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a02f:	90                   	nop
8010a030:	c9                   	leave
8010a031:	c3                   	ret

8010a032 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a032:	55                   	push   %ebp
8010a033:	89 e5                	mov    %esp,%ebp
8010a035:	53                   	push   %ebx
8010a036:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a039:	8b 45 08             	mov    0x8(%ebp),%eax
8010a03c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a040:	0f b7 c0             	movzwl %ax,%eax
8010a043:	83 ec 0c             	sub    $0xc,%esp
8010a046:	50                   	push   %eax
8010a047:	e8 d3 fd ff ff       	call   80109e1f <N2H_ushort>
8010a04c:	83 c4 10             	add    $0x10,%esp
8010a04f:	0f b7 d8             	movzwl %ax,%ebx
8010a052:	8b 45 08             	mov    0x8(%ebp),%eax
8010a055:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a059:	0f b7 c0             	movzwl %ax,%eax
8010a05c:	83 ec 0c             	sub    $0xc,%esp
8010a05f:	50                   	push   %eax
8010a060:	e8 ba fd ff ff       	call   80109e1f <N2H_ushort>
8010a065:	83 c4 10             	add    $0x10,%esp
8010a068:	0f b7 c0             	movzwl %ax,%eax
8010a06b:	83 ec 04             	sub    $0x4,%esp
8010a06e:	53                   	push   %ebx
8010a06f:	50                   	push   %eax
8010a070:	68 c3 ca 10 80       	push   $0x8010cac3
8010a075:	e8 7a 63 ff ff       	call   801003f4 <cprintf>
8010a07a:	83 c4 10             	add    $0x10,%esp
}
8010a07d:	90                   	nop
8010a07e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a081:	c9                   	leave
8010a082:	c3                   	ret

8010a083 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a083:	55                   	push   %ebp
8010a084:	89 e5                	mov    %esp,%ebp
8010a086:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a089:	8b 45 08             	mov    0x8(%ebp),%eax
8010a08c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a08f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a092:	83 c0 0e             	add    $0xe,%eax
8010a095:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09b:	0f b6 00             	movzbl (%eax),%eax
8010a09e:	0f b6 c0             	movzbl %al,%eax
8010a0a1:	83 e0 0f             	and    $0xf,%eax
8010a0a4:	c1 e0 02             	shl    $0x2,%eax
8010a0a7:	89 c2                	mov    %eax,%edx
8010a0a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ac:	01 d0                	add    %edx,%eax
8010a0ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a0b1:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a0b7:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0ba:	83 c0 0e             	add    $0xe,%eax
8010a0bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a0c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0c3:	83 c0 14             	add    $0x14,%eax
8010a0c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a0c9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0cc:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a0d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0d5:	8d 50 06             	lea    0x6(%eax),%edx
8010a0d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0db:	83 ec 04             	sub    $0x4,%esp
8010a0de:	6a 06                	push   $0x6
8010a0e0:	52                   	push   %edx
8010a0e1:	50                   	push   %eax
8010a0e2:	e8 96 b2 ff ff       	call   8010537d <memmove>
8010a0e7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a0ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0ed:	83 c0 06             	add    $0x6,%eax
8010a0f0:	83 ec 04             	sub    $0x4,%esp
8010a0f3:	6a 06                	push   $0x6
8010a0f5:	68 b4 7a 19 80       	push   $0x80197ab4
8010a0fa:	50                   	push   %eax
8010a0fb:	e8 7d b2 ff ff       	call   8010537d <memmove>
8010a100:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a103:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a106:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a10a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a10d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a114:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a11a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a11e:	83 ec 0c             	sub    $0xc,%esp
8010a121:	6a 54                	push   $0x54
8010a123:	e8 0e fd ff ff       	call   80109e36 <H2N_ushort>
8010a128:	83 c4 10             	add    $0x10,%esp
8010a12b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a12e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a132:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a13c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a140:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a147:	83 c0 01             	add    $0x1,%eax
8010a14a:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a150:	83 ec 0c             	sub    $0xc,%esp
8010a153:	68 00 40 00 00       	push   $0x4000
8010a158:	e8 d9 fc ff ff       	call   80109e36 <H2N_ushort>
8010a15d:	83 c4 10             	add    $0x10,%esp
8010a160:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a163:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a16a:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a16e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a171:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a178:	83 c0 0c             	add    $0xc,%eax
8010a17b:	83 ec 04             	sub    $0x4,%esp
8010a17e:	6a 04                	push   $0x4
8010a180:	68 04 f5 10 80       	push   $0x8010f504
8010a185:	50                   	push   %eax
8010a186:	e8 f2 b1 ff ff       	call   8010537d <memmove>
8010a18b:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a18e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a191:	8d 50 0c             	lea    0xc(%eax),%edx
8010a194:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a197:	83 c0 10             	add    $0x10,%eax
8010a19a:	83 ec 04             	sub    $0x4,%esp
8010a19d:	6a 04                	push   $0x4
8010a19f:	52                   	push   %edx
8010a1a0:	50                   	push   %eax
8010a1a1:	e8 d7 b1 ff ff       	call   8010537d <memmove>
8010a1a6:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a1a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1ac:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a1b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b5:	83 ec 0c             	sub    $0xc,%esp
8010a1b8:	50                   	push   %eax
8010a1b9:	e8 6d fd ff ff       	call   80109f2b <ipv4_chksum>
8010a1be:	83 c4 10             	add    $0x10,%esp
8010a1c1:	0f b7 c0             	movzwl %ax,%eax
8010a1c4:	83 ec 0c             	sub    $0xc,%esp
8010a1c7:	50                   	push   %eax
8010a1c8:	e8 69 fc ff ff       	call   80109e36 <H2N_ushort>
8010a1cd:	83 c4 10             	add    $0x10,%esp
8010a1d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1d3:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a1d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1da:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a1dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1e0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a1e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1e7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a1eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ee:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a1f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1f5:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a1f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1fc:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a200:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a203:	8d 50 08             	lea    0x8(%eax),%edx
8010a206:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a209:	83 c0 08             	add    $0x8,%eax
8010a20c:	83 ec 04             	sub    $0x4,%esp
8010a20f:	6a 08                	push   $0x8
8010a211:	52                   	push   %edx
8010a212:	50                   	push   %eax
8010a213:	e8 65 b1 ff ff       	call   8010537d <memmove>
8010a218:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a21b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a21e:	8d 50 10             	lea    0x10(%eax),%edx
8010a221:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a224:	83 c0 10             	add    $0x10,%eax
8010a227:	83 ec 04             	sub    $0x4,%esp
8010a22a:	6a 30                	push   $0x30
8010a22c:	52                   	push   %edx
8010a22d:	50                   	push   %eax
8010a22e:	e8 4a b1 ff ff       	call   8010537d <memmove>
8010a233:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a236:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a239:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a23f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a242:	83 ec 0c             	sub    $0xc,%esp
8010a245:	50                   	push   %eax
8010a246:	e8 1c 00 00 00       	call   8010a267 <icmp_chksum>
8010a24b:	83 c4 10             	add    $0x10,%esp
8010a24e:	0f b7 c0             	movzwl %ax,%eax
8010a251:	83 ec 0c             	sub    $0xc,%esp
8010a254:	50                   	push   %eax
8010a255:	e8 dc fb ff ff       	call   80109e36 <H2N_ushort>
8010a25a:	83 c4 10             	add    $0x10,%esp
8010a25d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a260:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a264:	90                   	nop
8010a265:	c9                   	leave
8010a266:	c3                   	ret

8010a267 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a267:	55                   	push   %ebp
8010a268:	89 e5                	mov    %esp,%ebp
8010a26a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a26d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a270:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a273:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a27a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a281:	eb 48                	jmp    8010a2cb <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a283:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a286:	01 c0                	add    %eax,%eax
8010a288:	89 c2                	mov    %eax,%edx
8010a28a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a28d:	01 d0                	add    %edx,%eax
8010a28f:	0f b6 00             	movzbl (%eax),%eax
8010a292:	0f b6 c0             	movzbl %al,%eax
8010a295:	c1 e0 08             	shl    $0x8,%eax
8010a298:	89 c2                	mov    %eax,%edx
8010a29a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a29d:	01 c0                	add    %eax,%eax
8010a29f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2a5:	01 c8                	add    %ecx,%eax
8010a2a7:	0f b6 00             	movzbl (%eax),%eax
8010a2aa:	0f b6 c0             	movzbl %al,%eax
8010a2ad:	01 d0                	add    %edx,%eax
8010a2af:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a2b2:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a2b9:	76 0c                	jbe    8010a2c7 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a2bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a2be:	0f b7 c0             	movzwl %ax,%eax
8010a2c1:	83 c0 01             	add    $0x1,%eax
8010a2c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a2c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a2cb:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a2cf:	7e b2                	jle    8010a283 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a2d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a2d4:	f7 d0                	not    %eax
}
8010a2d6:	c9                   	leave
8010a2d7:	c3                   	ret

8010a2d8 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a2d8:	55                   	push   %ebp
8010a2d9:	89 e5                	mov    %esp,%ebp
8010a2db:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a2de:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e1:	83 c0 0e             	add    $0xe,%eax
8010a2e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a2e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ea:	0f b6 00             	movzbl (%eax),%eax
8010a2ed:	0f b6 c0             	movzbl %al,%eax
8010a2f0:	83 e0 0f             	and    $0xf,%eax
8010a2f3:	c1 e0 02             	shl    $0x2,%eax
8010a2f6:	89 c2                	mov    %eax,%edx
8010a2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2fb:	01 d0                	add    %edx,%eax
8010a2fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a300:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a303:	83 c0 14             	add    $0x14,%eax
8010a306:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a309:	e8 9a 84 ff ff       	call   801027a8 <kalloc>
8010a30e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a311:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a318:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a31b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a31f:	0f b6 c0             	movzbl %al,%eax
8010a322:	83 e0 02             	and    $0x2,%eax
8010a325:	85 c0                	test   %eax,%eax
8010a327:	74 3d                	je     8010a366 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a329:	83 ec 0c             	sub    $0xc,%esp
8010a32c:	6a 00                	push   $0x0
8010a32e:	6a 12                	push   $0x12
8010a330:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a333:	50                   	push   %eax
8010a334:	ff 75 e8             	push   -0x18(%ebp)
8010a337:	ff 75 08             	push   0x8(%ebp)
8010a33a:	e8 a2 01 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a33f:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a342:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a345:	83 ec 08             	sub    $0x8,%esp
8010a348:	50                   	push   %eax
8010a349:	ff 75 e8             	push   -0x18(%ebp)
8010a34c:	e8 79 f1 ff ff       	call   801094ca <i8254_send>
8010a351:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a354:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a359:	83 c0 01             	add    $0x1,%eax
8010a35c:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a361:	e9 69 01 00 00       	jmp    8010a4cf <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a366:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a369:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a36d:	3c 18                	cmp    $0x18,%al
8010a36f:	0f 85 10 01 00 00    	jne    8010a485 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a375:	83 ec 04             	sub    $0x4,%esp
8010a378:	6a 03                	push   $0x3
8010a37a:	68 de ca 10 80       	push   $0x8010cade
8010a37f:	ff 75 ec             	push   -0x14(%ebp)
8010a382:	e8 9e af ff ff       	call   80105325 <memcmp>
8010a387:	83 c4 10             	add    $0x10,%esp
8010a38a:	85 c0                	test   %eax,%eax
8010a38c:	74 74                	je     8010a402 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a38e:	83 ec 0c             	sub    $0xc,%esp
8010a391:	68 e2 ca 10 80       	push   $0x8010cae2
8010a396:	e8 59 60 ff ff       	call   801003f4 <cprintf>
8010a39b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a39e:	83 ec 0c             	sub    $0xc,%esp
8010a3a1:	6a 00                	push   $0x0
8010a3a3:	6a 10                	push   $0x10
8010a3a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3a8:	50                   	push   %eax
8010a3a9:	ff 75 e8             	push   -0x18(%ebp)
8010a3ac:	ff 75 08             	push   0x8(%ebp)
8010a3af:	e8 2d 01 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a3b4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a3b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3ba:	83 ec 08             	sub    $0x8,%esp
8010a3bd:	50                   	push   %eax
8010a3be:	ff 75 e8             	push   -0x18(%ebp)
8010a3c1:	e8 04 f1 ff ff       	call   801094ca <i8254_send>
8010a3c6:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a3c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3cc:	83 c0 36             	add    $0x36,%eax
8010a3cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a3d2:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a3d5:	50                   	push   %eax
8010a3d6:	ff 75 e0             	push   -0x20(%ebp)
8010a3d9:	6a 00                	push   $0x0
8010a3db:	6a 00                	push   $0x0
8010a3dd:	e8 5a 04 00 00       	call   8010a83c <http_proc>
8010a3e2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a3e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a3e8:	83 ec 0c             	sub    $0xc,%esp
8010a3eb:	50                   	push   %eax
8010a3ec:	6a 18                	push   $0x18
8010a3ee:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3f1:	50                   	push   %eax
8010a3f2:	ff 75 e8             	push   -0x18(%ebp)
8010a3f5:	ff 75 08             	push   0x8(%ebp)
8010a3f8:	e8 e4 00 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a3fd:	83 c4 20             	add    $0x20,%esp
8010a400:	eb 62                	jmp    8010a464 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a402:	83 ec 0c             	sub    $0xc,%esp
8010a405:	6a 00                	push   $0x0
8010a407:	6a 10                	push   $0x10
8010a409:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a40c:	50                   	push   %eax
8010a40d:	ff 75 e8             	push   -0x18(%ebp)
8010a410:	ff 75 08             	push   0x8(%ebp)
8010a413:	e8 c9 00 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a418:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a41b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a41e:	83 ec 08             	sub    $0x8,%esp
8010a421:	50                   	push   %eax
8010a422:	ff 75 e8             	push   -0x18(%ebp)
8010a425:	e8 a0 f0 ff ff       	call   801094ca <i8254_send>
8010a42a:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a42d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a430:	83 c0 36             	add    $0x36,%eax
8010a433:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a436:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a439:	50                   	push   %eax
8010a43a:	ff 75 e4             	push   -0x1c(%ebp)
8010a43d:	6a 00                	push   $0x0
8010a43f:	6a 00                	push   $0x0
8010a441:	e8 f6 03 00 00       	call   8010a83c <http_proc>
8010a446:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a44c:	83 ec 0c             	sub    $0xc,%esp
8010a44f:	50                   	push   %eax
8010a450:	6a 18                	push   $0x18
8010a452:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a455:	50                   	push   %eax
8010a456:	ff 75 e8             	push   -0x18(%ebp)
8010a459:	ff 75 08             	push   0x8(%ebp)
8010a45c:	e8 80 00 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a461:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a464:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a467:	83 ec 08             	sub    $0x8,%esp
8010a46a:	50                   	push   %eax
8010a46b:	ff 75 e8             	push   -0x18(%ebp)
8010a46e:	e8 57 f0 ff ff       	call   801094ca <i8254_send>
8010a473:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a476:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a47b:	83 c0 01             	add    $0x1,%eax
8010a47e:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a483:	eb 4a                	jmp    8010a4cf <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a485:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a488:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a48c:	3c 10                	cmp    $0x10,%al
8010a48e:	75 3f                	jne    8010a4cf <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a490:	a1 88 7d 19 80       	mov    0x80197d88,%eax
8010a495:	83 f8 01             	cmp    $0x1,%eax
8010a498:	75 35                	jne    8010a4cf <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a49a:	83 ec 0c             	sub    $0xc,%esp
8010a49d:	6a 00                	push   $0x0
8010a49f:	6a 01                	push   $0x1
8010a4a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4a4:	50                   	push   %eax
8010a4a5:	ff 75 e8             	push   -0x18(%ebp)
8010a4a8:	ff 75 08             	push   0x8(%ebp)
8010a4ab:	e8 31 00 00 00       	call   8010a4e1 <tcp_pkt_create>
8010a4b0:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a4b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a4b6:	83 ec 08             	sub    $0x8,%esp
8010a4b9:	50                   	push   %eax
8010a4ba:	ff 75 e8             	push   -0x18(%ebp)
8010a4bd:	e8 08 f0 ff ff       	call   801094ca <i8254_send>
8010a4c2:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a4c5:	c7 05 88 7d 19 80 00 	movl   $0x0,0x80197d88
8010a4cc:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a4cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4d2:	83 ec 0c             	sub    $0xc,%esp
8010a4d5:	50                   	push   %eax
8010a4d6:	e8 33 82 ff ff       	call   8010270e <kfree>
8010a4db:	83 c4 10             	add    $0x10,%esp
}
8010a4de:	90                   	nop
8010a4df:	c9                   	leave
8010a4e0:	c3                   	ret

8010a4e1 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a4e1:	55                   	push   %ebp
8010a4e2:	89 e5                	mov    %esp,%ebp
8010a4e4:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a4e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a4ed:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4f0:	83 c0 0e             	add    $0xe,%eax
8010a4f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a4f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4f9:	0f b6 00             	movzbl (%eax),%eax
8010a4fc:	0f b6 c0             	movzbl %al,%eax
8010a4ff:	83 e0 0f             	and    $0xf,%eax
8010a502:	c1 e0 02             	shl    $0x2,%eax
8010a505:	89 c2                	mov    %eax,%edx
8010a507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a50a:	01 d0                	add    %edx,%eax
8010a50c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a50f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a512:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a515:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a518:	83 c0 0e             	add    $0xe,%eax
8010a51b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a51e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a521:	83 c0 14             	add    $0x14,%eax
8010a524:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a527:	8b 45 18             	mov    0x18(%ebp),%eax
8010a52a:	8d 50 36             	lea    0x36(%eax),%edx
8010a52d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a530:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a532:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a535:	8d 50 06             	lea    0x6(%eax),%edx
8010a538:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a53b:	83 ec 04             	sub    $0x4,%esp
8010a53e:	6a 06                	push   $0x6
8010a540:	52                   	push   %edx
8010a541:	50                   	push   %eax
8010a542:	e8 36 ae ff ff       	call   8010537d <memmove>
8010a547:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a54a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a54d:	83 c0 06             	add    $0x6,%eax
8010a550:	83 ec 04             	sub    $0x4,%esp
8010a553:	6a 06                	push   $0x6
8010a555:	68 b4 7a 19 80       	push   $0x80197ab4
8010a55a:	50                   	push   %eax
8010a55b:	e8 1d ae ff ff       	call   8010537d <memmove>
8010a560:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a563:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a566:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a56a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a56d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a574:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a57a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a57e:	8b 45 18             	mov    0x18(%ebp),%eax
8010a581:	83 c0 28             	add    $0x28,%eax
8010a584:	0f b7 c0             	movzwl %ax,%eax
8010a587:	83 ec 0c             	sub    $0xc,%esp
8010a58a:	50                   	push   %eax
8010a58b:	e8 a6 f8 ff ff       	call   80109e36 <H2N_ushort>
8010a590:	83 c4 10             	add    $0x10,%esp
8010a593:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a596:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a59a:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a5a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5a4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a5a8:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a5af:	83 c0 01             	add    $0x1,%eax
8010a5b2:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a5b8:	83 ec 0c             	sub    $0xc,%esp
8010a5bb:	6a 00                	push   $0x0
8010a5bd:	e8 74 f8 ff ff       	call   80109e36 <H2N_ushort>
8010a5c2:	83 c4 10             	add    $0x10,%esp
8010a5c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a5c8:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a5cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5cf:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a5d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5d6:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a5da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5dd:	83 c0 0c             	add    $0xc,%eax
8010a5e0:	83 ec 04             	sub    $0x4,%esp
8010a5e3:	6a 04                	push   $0x4
8010a5e5:	68 04 f5 10 80       	push   $0x8010f504
8010a5ea:	50                   	push   %eax
8010a5eb:	e8 8d ad ff ff       	call   8010537d <memmove>
8010a5f0:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a5f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5f6:	8d 50 0c             	lea    0xc(%eax),%edx
8010a5f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5fc:	83 c0 10             	add    $0x10,%eax
8010a5ff:	83 ec 04             	sub    $0x4,%esp
8010a602:	6a 04                	push   $0x4
8010a604:	52                   	push   %edx
8010a605:	50                   	push   %eax
8010a606:	e8 72 ad ff ff       	call   8010537d <memmove>
8010a60b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a60e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a611:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a61a:	83 ec 0c             	sub    $0xc,%esp
8010a61d:	50                   	push   %eax
8010a61e:	e8 08 f9 ff ff       	call   80109f2b <ipv4_chksum>
8010a623:	83 c4 10             	add    $0x10,%esp
8010a626:	0f b7 c0             	movzwl %ax,%eax
8010a629:	83 ec 0c             	sub    $0xc,%esp
8010a62c:	50                   	push   %eax
8010a62d:	e8 04 f8 ff ff       	call   80109e36 <H2N_ushort>
8010a632:	83 c4 10             	add    $0x10,%esp
8010a635:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a638:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a63c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a63f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a643:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a646:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a649:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a64c:	0f b7 10             	movzwl (%eax),%edx
8010a64f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a652:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a656:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a65b:	83 ec 0c             	sub    $0xc,%esp
8010a65e:	50                   	push   %eax
8010a65f:	e8 e9 f7 ff ff       	call   80109e4d <H2N_uint>
8010a664:	83 c4 10             	add    $0x10,%esp
8010a667:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a66a:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a66d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a670:	8b 40 04             	mov    0x4(%eax),%eax
8010a673:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a679:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a67c:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a67f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a682:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a686:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a689:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a68d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a690:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a694:	8b 45 14             	mov    0x14(%ebp),%eax
8010a697:	89 c2                	mov    %eax,%edx
8010a699:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a69c:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a69f:	83 ec 0c             	sub    $0xc,%esp
8010a6a2:	68 90 38 00 00       	push   $0x3890
8010a6a7:	e8 8a f7 ff ff       	call   80109e36 <H2N_ushort>
8010a6ac:	83 c4 10             	add    $0x10,%esp
8010a6af:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a6b2:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a6b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6b9:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a6bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6c2:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a6c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6cb:	83 ec 0c             	sub    $0xc,%esp
8010a6ce:	50                   	push   %eax
8010a6cf:	e8 1f 00 00 00       	call   8010a6f3 <tcp_chksum>
8010a6d4:	83 c4 10             	add    $0x10,%esp
8010a6d7:	83 c0 08             	add    $0x8,%eax
8010a6da:	0f b7 c0             	movzwl %ax,%eax
8010a6dd:	83 ec 0c             	sub    $0xc,%esp
8010a6e0:	50                   	push   %eax
8010a6e1:	e8 50 f7 ff ff       	call   80109e36 <H2N_ushort>
8010a6e6:	83 c4 10             	add    $0x10,%esp
8010a6e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a6ec:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a6f0:	90                   	nop
8010a6f1:	c9                   	leave
8010a6f2:	c3                   	ret

8010a6f3 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a6f3:	55                   	push   %ebp
8010a6f4:	89 e5                	mov    %esp,%ebp
8010a6f6:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a6f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a6ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a702:	83 c0 14             	add    $0x14,%eax
8010a705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a708:	83 ec 04             	sub    $0x4,%esp
8010a70b:	6a 04                	push   $0x4
8010a70d:	68 04 f5 10 80       	push   $0x8010f504
8010a712:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a715:	50                   	push   %eax
8010a716:	e8 62 ac ff ff       	call   8010537d <memmove>
8010a71b:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a71e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a721:	83 c0 0c             	add    $0xc,%eax
8010a724:	83 ec 04             	sub    $0x4,%esp
8010a727:	6a 04                	push   $0x4
8010a729:	50                   	push   %eax
8010a72a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a72d:	83 c0 04             	add    $0x4,%eax
8010a730:	50                   	push   %eax
8010a731:	e8 47 ac ff ff       	call   8010537d <memmove>
8010a736:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a739:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a73d:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a741:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a744:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a748:	0f b7 c0             	movzwl %ax,%eax
8010a74b:	83 ec 0c             	sub    $0xc,%esp
8010a74e:	50                   	push   %eax
8010a74f:	e8 cb f6 ff ff       	call   80109e1f <N2H_ushort>
8010a754:	83 c4 10             	add    $0x10,%esp
8010a757:	83 e8 14             	sub    $0x14,%eax
8010a75a:	0f b7 c0             	movzwl %ax,%eax
8010a75d:	83 ec 0c             	sub    $0xc,%esp
8010a760:	50                   	push   %eax
8010a761:	e8 d0 f6 ff ff       	call   80109e36 <H2N_ushort>
8010a766:	83 c4 10             	add    $0x10,%esp
8010a769:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a76d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a774:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a777:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a77a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a781:	eb 33                	jmp    8010a7b6 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a783:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a786:	01 c0                	add    %eax,%eax
8010a788:	89 c2                	mov    %eax,%edx
8010a78a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a78d:	01 d0                	add    %edx,%eax
8010a78f:	0f b6 00             	movzbl (%eax),%eax
8010a792:	0f b6 c0             	movzbl %al,%eax
8010a795:	c1 e0 08             	shl    $0x8,%eax
8010a798:	89 c2                	mov    %eax,%edx
8010a79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a79d:	01 c0                	add    %eax,%eax
8010a79f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a7a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7a5:	01 c8                	add    %ecx,%eax
8010a7a7:	0f b6 00             	movzbl (%eax),%eax
8010a7aa:	0f b6 c0             	movzbl %al,%eax
8010a7ad:	01 d0                	add    %edx,%eax
8010a7af:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a7b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a7b6:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a7ba:	7e c7                	jle    8010a783 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a7bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a7c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a7c9:	eb 33                	jmp    8010a7fe <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a7cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7ce:	01 c0                	add    %eax,%eax
8010a7d0:	89 c2                	mov    %eax,%edx
8010a7d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7d5:	01 d0                	add    %edx,%eax
8010a7d7:	0f b6 00             	movzbl (%eax),%eax
8010a7da:	0f b6 c0             	movzbl %al,%eax
8010a7dd:	c1 e0 08             	shl    $0x8,%eax
8010a7e0:	89 c2                	mov    %eax,%edx
8010a7e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a7e5:	01 c0                	add    %eax,%eax
8010a7e7:	8d 48 01             	lea    0x1(%eax),%ecx
8010a7ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a7ed:	01 c8                	add    %ecx,%eax
8010a7ef:	0f b6 00             	movzbl (%eax),%eax
8010a7f2:	0f b6 c0             	movzbl %al,%eax
8010a7f5:	01 d0                	add    %edx,%eax
8010a7f7:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a7fa:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a7fe:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a802:	0f b7 c0             	movzwl %ax,%eax
8010a805:	83 ec 0c             	sub    $0xc,%esp
8010a808:	50                   	push   %eax
8010a809:	e8 11 f6 ff ff       	call   80109e1f <N2H_ushort>
8010a80e:	83 c4 10             	add    $0x10,%esp
8010a811:	66 d1 e8             	shr    $1,%ax
8010a814:	0f b7 c0             	movzwl %ax,%eax
8010a817:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a81a:	7c af                	jl     8010a7cb <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a81f:	c1 e8 10             	shr    $0x10,%eax
8010a822:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a825:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a828:	f7 d0                	not    %eax
}
8010a82a:	c9                   	leave
8010a82b:	c3                   	ret

8010a82c <tcp_fin>:

void tcp_fin(){
8010a82c:	55                   	push   %ebp
8010a82d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a82f:	c7 05 88 7d 19 80 01 	movl   $0x1,0x80197d88
8010a836:	00 00 00 
}
8010a839:	90                   	nop
8010a83a:	5d                   	pop    %ebp
8010a83b:	c3                   	ret

8010a83c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a83c:	55                   	push   %ebp
8010a83d:	89 e5                	mov    %esp,%ebp
8010a83f:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a842:	8b 45 10             	mov    0x10(%ebp),%eax
8010a845:	83 ec 04             	sub    $0x4,%esp
8010a848:	6a 00                	push   $0x0
8010a84a:	68 eb ca 10 80       	push   $0x8010caeb
8010a84f:	50                   	push   %eax
8010a850:	e8 65 00 00 00       	call   8010a8ba <http_strcpy>
8010a855:	83 c4 10             	add    $0x10,%esp
8010a858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a85b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a85e:	83 ec 04             	sub    $0x4,%esp
8010a861:	ff 75 f4             	push   -0xc(%ebp)
8010a864:	68 fe ca 10 80       	push   $0x8010cafe
8010a869:	50                   	push   %eax
8010a86a:	e8 4b 00 00 00       	call   8010a8ba <http_strcpy>
8010a86f:	83 c4 10             	add    $0x10,%esp
8010a872:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a875:	8b 45 10             	mov    0x10(%ebp),%eax
8010a878:	83 ec 04             	sub    $0x4,%esp
8010a87b:	ff 75 f4             	push   -0xc(%ebp)
8010a87e:	68 19 cb 10 80       	push   $0x8010cb19
8010a883:	50                   	push   %eax
8010a884:	e8 31 00 00 00       	call   8010a8ba <http_strcpy>
8010a889:	83 c4 10             	add    $0x10,%esp
8010a88c:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a892:	83 e0 01             	and    $0x1,%eax
8010a895:	85 c0                	test   %eax,%eax
8010a897:	74 11                	je     8010a8aa <http_proc+0x6e>
    char *payload = (char *)send;
8010a899:	8b 45 10             	mov    0x10(%ebp),%eax
8010a89c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a89f:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a8a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8a5:	01 d0                	add    %edx,%eax
8010a8a7:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a8aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a8ad:	8b 45 14             	mov    0x14(%ebp),%eax
8010a8b0:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a8b2:	e8 75 ff ff ff       	call   8010a82c <tcp_fin>
}
8010a8b7:	90                   	nop
8010a8b8:	c9                   	leave
8010a8b9:	c3                   	ret

8010a8ba <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a8ba:	55                   	push   %ebp
8010a8bb:	89 e5                	mov    %esp,%ebp
8010a8bd:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a8c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a8c7:	eb 20                	jmp    8010a8e9 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a8c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a8cc:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a8cf:	01 d0                	add    %edx,%eax
8010a8d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a8d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a8d7:	01 ca                	add    %ecx,%edx
8010a8d9:	89 d1                	mov    %edx,%ecx
8010a8db:	8b 55 08             	mov    0x8(%ebp),%edx
8010a8de:	01 ca                	add    %ecx,%edx
8010a8e0:	0f b6 00             	movzbl (%eax),%eax
8010a8e3:	88 02                	mov    %al,(%edx)
    i++;
8010a8e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a8e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a8ec:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a8ef:	01 d0                	add    %edx,%eax
8010a8f1:	0f b6 00             	movzbl (%eax),%eax
8010a8f4:	84 c0                	test   %al,%al
8010a8f6:	75 d1                	jne    8010a8c9 <http_strcpy+0xf>
  }
  return i;
8010a8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a8fb:	c9                   	leave
8010a8fc:	c3                   	ret

8010a8fd <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a8fd:	55                   	push   %ebp
8010a8fe:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a900:	c7 05 90 7d 19 80 c2 	movl   $0x8010f5c2,0x80197d90
8010a907:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a90a:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a90f:	c1 e8 09             	shr    $0x9,%eax
8010a912:	a3 8c 7d 19 80       	mov    %eax,0x80197d8c
}
8010a917:	90                   	nop
8010a918:	5d                   	pop    %ebp
8010a919:	c3                   	ret

8010a91a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a91a:	55                   	push   %ebp
8010a91b:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a91d:	90                   	nop
8010a91e:	5d                   	pop    %ebp
8010a91f:	c3                   	ret

8010a920 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a920:	55                   	push   %ebp
8010a921:	89 e5                	mov    %esp,%ebp
8010a923:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a926:	8b 45 08             	mov    0x8(%ebp),%eax
8010a929:	83 c0 0c             	add    $0xc,%eax
8010a92c:	83 ec 0c             	sub    $0xc,%esp
8010a92f:	50                   	push   %eax
8010a930:	e8 82 a6 ff ff       	call   80104fb7 <holdingsleep>
8010a935:	83 c4 10             	add    $0x10,%esp
8010a938:	85 c0                	test   %eax,%eax
8010a93a:	75 0d                	jne    8010a949 <iderw+0x29>
    panic("iderw: buf not locked");
8010a93c:	83 ec 0c             	sub    $0xc,%esp
8010a93f:	68 2a cb 10 80       	push   $0x8010cb2a
8010a944:	e8 60 5c ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a949:	8b 45 08             	mov    0x8(%ebp),%eax
8010a94c:	8b 00                	mov    (%eax),%eax
8010a94e:	83 e0 06             	and    $0x6,%eax
8010a951:	83 f8 02             	cmp    $0x2,%eax
8010a954:	75 0d                	jne    8010a963 <iderw+0x43>
    panic("iderw: nothing to do");
8010a956:	83 ec 0c             	sub    $0xc,%esp
8010a959:	68 40 cb 10 80       	push   $0x8010cb40
8010a95e:	e8 46 5c ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a963:	8b 45 08             	mov    0x8(%ebp),%eax
8010a966:	8b 40 04             	mov    0x4(%eax),%eax
8010a969:	83 f8 01             	cmp    $0x1,%eax
8010a96c:	74 0d                	je     8010a97b <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a96e:	83 ec 0c             	sub    $0xc,%esp
8010a971:	68 55 cb 10 80       	push   $0x8010cb55
8010a976:	e8 2e 5c ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a97b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a97e:	8b 40 08             	mov    0x8(%eax),%eax
8010a981:	8b 15 8c 7d 19 80    	mov    0x80197d8c,%edx
8010a987:	39 d0                	cmp    %edx,%eax
8010a989:	72 0d                	jb     8010a998 <iderw+0x78>
    panic("iderw: block out of range");
8010a98b:	83 ec 0c             	sub    $0xc,%esp
8010a98e:	68 73 cb 10 80       	push   $0x8010cb73
8010a993:	e8 11 5c ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a998:	8b 15 90 7d 19 80    	mov    0x80197d90,%edx
8010a99e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9a1:	8b 40 08             	mov    0x8(%eax),%eax
8010a9a4:	c1 e0 09             	shl    $0x9,%eax
8010a9a7:	01 d0                	add    %edx,%eax
8010a9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a9ac:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9af:	8b 00                	mov    (%eax),%eax
8010a9b1:	83 e0 04             	and    $0x4,%eax
8010a9b4:	85 c0                	test   %eax,%eax
8010a9b6:	74 2b                	je     8010a9e3 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a9b8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9bb:	8b 00                	mov    (%eax),%eax
8010a9bd:	83 e0 fb             	and    $0xfffffffb,%eax
8010a9c0:	89 c2                	mov    %eax,%edx
8010a9c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9c5:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a9c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9ca:	83 c0 5c             	add    $0x5c,%eax
8010a9cd:	83 ec 04             	sub    $0x4,%esp
8010a9d0:	68 00 02 00 00       	push   $0x200
8010a9d5:	50                   	push   %eax
8010a9d6:	ff 75 f4             	push   -0xc(%ebp)
8010a9d9:	e8 9f a9 ff ff       	call   8010537d <memmove>
8010a9de:	83 c4 10             	add    $0x10,%esp
8010a9e1:	eb 1a                	jmp    8010a9fd <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a9e3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9e6:	83 c0 5c             	add    $0x5c,%eax
8010a9e9:	83 ec 04             	sub    $0x4,%esp
8010a9ec:	68 00 02 00 00       	push   $0x200
8010a9f1:	ff 75 f4             	push   -0xc(%ebp)
8010a9f4:	50                   	push   %eax
8010a9f5:	e8 83 a9 ff ff       	call   8010537d <memmove>
8010a9fa:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a9fd:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa00:	8b 00                	mov    (%eax),%eax
8010aa02:	83 c8 02             	or     $0x2,%eax
8010aa05:	89 c2                	mov    %eax,%edx
8010aa07:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa0a:	89 10                	mov    %edx,(%eax)
}
8010aa0c:	90                   	nop
8010aa0d:	c9                   	leave
8010aa0e:	c3                   	ret
